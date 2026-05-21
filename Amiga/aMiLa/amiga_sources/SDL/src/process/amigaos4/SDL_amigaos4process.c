/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2026 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "SDL_internal.h"

#ifdef SDL_PROCESS_AMIGAOS4

#include "../SDL_sysprocess.h"
#include "../../io/SDL_iostream_c.h"
#include "../../main/amigaos4/SDL_os4debug.h"

#include <proto/dos.h>
#include <proto/exec.h>

struct SDL_ProcessData {
    uint32 pid;
    int32 exitCode;
};

static void OS4_CleanupStream(void *userdata, void *value)
{
    SDL_Process *process = (SDL_Process *)value;
    const char *property = (const char *)userdata;

    SDL_ClearProperty(process->props, property);
}

static bool OS4_SetupStream(SDL_Process *process, BPTR bptr, const char* name, const char *mode, const char *property)
{
    dprintf("Setting %p (%s) to non-blocking mode\n", (void*)bptr, name);
    const int32 oldBlockingMode = IDOS->SetBlockingMode(bptr, SBM_NON_BLOCKING);

    if (oldBlockingMode <= 0) {
        dprintf("SetBlockingMode() returned %ld (error %ld)\n", oldBlockingMode, IDOS->IoErr());
    }

    SDL_IOStream *io = SDL_IOFromBPTR(bptr, mode, true);
    if (!io) {
        return SDL_SetError("Failed to get iostream for bptr %p", (void *)bptr);
    }

    SDL_SetPointerPropertyWithCleanup(SDL_GetIOProperties(io), "SDL.internal.process", process, OS4_CleanupStream, (void *)property);
    SDL_SetPointerProperty(process->props, property, io);
    return true;
}

static bool OS4_GetStreamBPTR(SDL_PropertiesID props, const char *property, BPTR *result)
{
    SDL_IOStream *io = (SDL_IOStream *)SDL_GetPointerProperty(props, property, NULL);
    if (!io) {
        return SDL_SetError("%s is not set", property);
    }

    BPTR bptr = (BPTR)SDL_GetPointerProperty(SDL_GetIOProperties(io), SDL_PROP_IOSTREAM_AMIGAOS4_POINTER, ZERO);
    if (bptr == ZERO) {
        return SDL_SetError("%s doesn't have SDL_PROP_IOSTREAM_AMIGAOS4_POINTER available", property);
    }

    dprintf("%s, %p\n", property, (void *)bptr);

    *result = bptr;
    return true;
}


static char* OS4_MakeCommandLine(char* const *args)
{
    uint32 index = 0;

    size_t len = 0;

    while(args[index]) {
        len += SDL_strlen(args[index]) + 1;
        index++;
    }

    dprintf("Command buffer length %zu\n", len);

    char *command = SDL_calloc(len, 1);

    if (!command) {
        dprintf("Failed to allocate command line buffer\n");
        return NULL;
    }

    // NOTE: process_testArguments has an array of arguments that may contain whitespace,
    // so that test fails because arguments are not passed as an array here.
    for (index = 0; args[index]; index++) {
        SDL_strlcat(command, args[index], len);

        if (args[index + 1]) {
            SDL_strlcat(command, " ", len);
        }
    }

    dprintf("Command buffer '%s'\n", command);

    return command;
}

static char** OS4_MakeEnvVariables(char **envp)
{
    // Convert from "variable=value" to "variable", "value" form

    uint32 index = 0;
    while (envp[index]) {
        char* p = envp[index++];

        while (*p) {
            if (*p == '=') {
                *p = '\0';
                break;
            }
            p++;
        }
    }

    dprintf("%lu variables found\n", index);

    char** result = SDL_calloc(sizeof(char*) * (2 * index + 1), 1);

    if (result) {
        index = 0;
        while(envp[index]) {
            result[2 * index] = SDL_strdup(envp[index]);
            result[2 * index + 1] = SDL_strdup(envp[index] + SDL_strlen(envp[index]) + 1);
            //dprintf("'%s': '%s'\n", result[2 * index], result[2 * index +1]);
            index++;
        }
    } else {
        dprintf("Failed to allocate memory\n");
    }

    SDL_free(envp);

    return result;
}

static void OS4_FreeEnvVariables(char** variables)
{
    int index = 0;
    while (variables[index]) {
        SDL_free(variables[index]);
        index++;
    }
    SDL_free(variables);
}

static void OS4_FinalCode(int32 returnCode, int32 finalData, struct ExecBase *sysbase)
{
    SDL_ProcessData *data = (SDL_ProcessData *)finalData;
    if (!data) {
        dprintf("NULL pointer");
        return;
    }

    dprintf("Process %lu return code %ld, final data %p\n", data->pid, returnCode, (void *)finalData);

    data->exitCode = returnCode;
}

#define READ_END 0
#define WRITE_END 1

static BPTR OS4_OpenNil()
{
    BPTR file = IDOS->FOpen("NIL:", MODE_OLDFILE, 0);

    if (file) {
        dprintf("Opened NIL: (%p)\n", (void *)file);
    } else {
        dprintf("Failed to open NIL: (error %ld)\n", IDOS->IoErr());
        SDL_SetError("Failed to open NIL:");
    }

    return file;
}

static bool OS4_Close(BPTR *bptr, const char *name)
{
    if (!bptr) {
        dprintf("Nullptr passed\n");
        return false;
    }

    if (!IDOS->FClose(*bptr)) {
        dprintf("Failed to close %s (%p)\n", name, (void *)*bptr);
        return false;
    }

    *bptr = ZERO;
    return true;
}

static bool OS4_CreatePipe(BPTR *pipe, const char *reason)
{
    pipe[WRITE_END] = IDOS->FOpen("PIPE:/100000/UNIQUE", MODE_NEWFILE, 0);

    if (!pipe[WRITE_END]) {
        dprintf("Failed to open %s pipe for writing (error %ld)\n", reason, IDOS->IoErr());
        return SDL_SetError("Failed to open %s pipe\n", reason);
    }

	struct ExamineData *data = IDOS->ExamineObjectTags(EX_FileHandleInput, pipe[WRITE_END], TAG_DONE);

    if (data) {
        char name[256];

        SDL_strlcpy(name, "PIPE:", sizeof(name));
        SDL_strlcat(name, data->Name, sizeof(name));

        IDOS->FreeDosObject(DOS_EXAMINEDATA, data);

        dprintf("Unique %s pipe name '%s'\n", reason, name);

        pipe[READ_END] = IDOS->FOpen(name, MODE_OLDFILE, 0);

        if (!pipe[READ_END]) {
            dprintf("Failed to open %s pipe for reading (error %ld)\n", reason, IDOS->IoErr());
            OS4_Close(&pipe[WRITE_END], "pipe write end");
            return SDL_SetError("Failed to open %s pipe\n", reason);
        }
    } else {
        dprintf("ExamineObjectTags() failed (error %ld)\n", IDOS->IoErr());
        OS4_Close(&pipe[WRITE_END], "pipe write end");
        return SDL_SetError("Failed to open %s pipe\n", reason);
    }

    dprintf("%s pipe opened (read %p, write %p)\n", reason, (void *)pipe[READ_END], (void *)pipe[WRITE_END]);
    return true;
}

bool SDL_SYS_CreateProcessWithProperties(SDL_Process *process, SDL_PropertiesID props)
{
    if (!IDOS) {
        return SDL_SetError("IDOS nullptr");
    }

    char * const *args = SDL_GetPointerProperty(props, SDL_PROP_PROCESS_CREATE_ARGS_POINTER, NULL);

    SDL_ProcessIO stdin_option = (SDL_ProcessIO)SDL_GetNumberProperty(props, SDL_PROP_PROCESS_CREATE_STDIN_NUMBER, SDL_PROCESS_STDIO_NULL);
    SDL_ProcessIO stdout_option = (SDL_ProcessIO)SDL_GetNumberProperty(props, SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER, SDL_PROCESS_STDIO_INHERITED);
    SDL_ProcessIO stderr_option = (SDL_ProcessIO)SDL_GetNumberProperty(props, SDL_PROP_PROCESS_CREATE_STDERR_NUMBER, SDL_PROCESS_STDIO_INHERITED);
    bool redirect_stderr = SDL_GetBooleanProperty(props, SDL_PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN, false) &&
                           !SDL_HasProperty(props, SDL_PROP_PROCESS_CREATE_STDERR_NUMBER);

    SDL_Environment *env = SDL_GetPointerProperty(props, SDL_PROP_PROCESS_CREATE_ENVIRONMENT_POINTER, SDL_GetEnvironment());
    char **envp = SDL_GetEnvironmentVariables(env);
    if (!envp) {
        dprintf("envp NULL\n");
        return false;
    }

    SDL_ProcessData *data = SDL_calloc(1, sizeof(*data));
    if (!data) {
        dprintf("Failed to allocate process data\n");
        SDL_free(envp);
        return SDL_OutOfMemory();
    }

    BPTR lock = IDOS->Lock(args[0], SHARED_LOCK);

    if (lock) {
        IDOS->UnLock(lock);
    } else {
        dprintf("Failed to lock '%s' (%ld)\n", args[0], IDOS->IoErr());
        SDL_free(envp);
        return SDL_SetError("Failed to lock '%s'", args[0]);
    }

    // Background processes don't have access to the terminal
    if (process->background) {
        if (stdin_option == SDL_PROCESS_STDIO_INHERITED) {
            stdin_option = SDL_PROCESS_STDIO_NULL;
        }
        if (stdout_option == SDL_PROCESS_STDIO_INHERITED) {
            stdout_option = SDL_PROCESS_STDIO_NULL;
        }
        if (stderr_option == SDL_PROCESS_STDIO_INHERITED) {
            stderr_option = SDL_PROCESS_STDIO_NULL;
        }
    }

    char *command = OS4_MakeCommandLine(args);
    char **variables = OS4_MakeEnvVariables(envp);

    if (!command) {
        OS4_FreeEnvVariables(variables);
        return SDL_OutOfMemory();
    }

    process->internal = data;

    BPTR stdin_pipe[2] = { ZERO, ZERO };
    BPTR stdout_pipe[2] = { ZERO, ZERO };
    BPTR stderr_pipe[2] = { ZERO, ZERO };

    BPTR inputHandle = ZERO;
    BPTR outputHandle = ZERO;
    BPTR errorHandle = ZERO;

    switch (stdin_option) {
    case SDL_PROCESS_STDIO_REDIRECT:
        BPTR file = ZERO;
        if (OS4_GetStreamBPTR(props, SDL_PROP_PROCESS_CREATE_STDIN_POINTER, &file)) {
            inputHandle = IDOS->DupFileHandle(file);
            dprintf("Redirected input handle %p\n", (void *)inputHandle);
        } else {
            dprintf("Failed to get redirected STDIN BPTR\n");
            goto fail;
        }
        break;
    case SDL_PROCESS_STDIO_APP:
        if (OS4_CreatePipe(stdin_pipe, "stdin")) {
            inputHandle = IDOS->DupFileHandle(stdin_pipe[READ_END]);
            dprintf("input handle %p is stdin_pipe's read end\n", (void *)inputHandle);
        } else {
            goto fail;
        }
        break;
    case SDL_PROCESS_STDIO_NULL:
        inputHandle = OS4_OpenNil();
        if (inputHandle == ZERO) {
            goto fail;
        }
        break;
    case SDL_PROCESS_STDIO_INHERITED:
    default:
        inputHandle = IDOS->DupFileHandle(IDOS->Input());
        if (inputHandle == ZERO) {
            goto fail;
        }
        break;
    }

    switch (stdout_option) {
    case SDL_PROCESS_STDIO_REDIRECT:
        BPTR file = ZERO;
        if (OS4_GetStreamBPTR(props, SDL_PROP_PROCESS_CREATE_STDOUT_POINTER, &file)) {
            outputHandle = IDOS->DupFileHandle(file);
            dprintf("Redirected output handle %p\n", (void *)outputHandle);
        } else {
            dprintf("Failed to get redirected STDOUT BPTR\n");
            goto fail;
        }
        break;
    case SDL_PROCESS_STDIO_APP:
        if (OS4_CreatePipe(stdout_pipe, "stdout")) {
            outputHandle = IDOS->DupFileHandle(stdout_pipe[WRITE_END]);
            dprintf("output handle %p is stdout_pipe's write end\n", (void *)outputHandle);
        } else {
            goto fail;
        }
        break;
    case SDL_PROCESS_STDIO_NULL:
        outputHandle = OS4_OpenNil();
        if (outputHandle == ZERO) {
            goto fail;
        }
        break;
    case SDL_PROCESS_STDIO_INHERITED:
    default:
        outputHandle = IDOS->DupFileHandle(IDOS->Output());
        if (outputHandle == ZERO) {
            dprintf("Failed to duplicate output handle (error %ld)\n", IDOS->IoErr());
        }
        break;
    }

    if (redirect_stderr) {
        errorHandle = IDOS->DupFileHandle(IDOS->Output());
        if (errorHandle == ZERO) {
            dprintf("Failed to duplicate error handle (error %ld)\n", IDOS->IoErr());
        }
    } else {
        switch (stderr_option) {
        case SDL_PROCESS_STDIO_REDIRECT:
            BPTR file = ZERO;
            if (OS4_GetStreamBPTR(props, SDL_PROP_PROCESS_CREATE_STDERR_POINTER, &file)) {
                errorHandle = IDOS->DupFileHandle(file);
                dprintf("Redirected error handle %p\n", (void *)errorHandle);
            } else {
                dprintf("Failed to get redirected STDERR BPTR\n");
                goto fail;
            }
            break;
        case SDL_PROCESS_STDIO_APP:
            if (OS4_CreatePipe(stderr_pipe, "stderr")) {
                errorHandle = IDOS->DupFileHandle(stderr_pipe[WRITE_END]);
                dprintf("error handle is stderr_pipe's write end\n");
            } else {
                goto fail;
            }
            break;
        case SDL_PROCESS_STDIO_NULL:
            errorHandle = OS4_OpenNil();
            if (errorHandle == ZERO) {
                goto fail;
            }
            break;
        case SDL_PROCESS_STDIO_INHERITED:
        default:
            errorHandle = IDOS->DupFileHandle(IDOS->ErrorOutput());
            if (errorHandle == ZERO) {
                dprintf("Failed to duplicate error handle (error %ld)\n", IDOS->IoErr());
            }
            break;
        }
    }

    if (inputHandle == ZERO)  {
        dprintf("input handle ZERO\n");
    }

    if (outputHandle == ZERO) {
        dprintf("output handle ZERO\n");
    }

    if (errorHandle == ZERO) {
        dprintf("error handle ZERO\n");
    }

    dprintf("Process is%s background\n", process->background ? "" : " not");

    const int32 error = IDOS->SystemTags(command,
                                   SYS_Asynch, TRUE,
                                   SYS_Input, inputHandle,
                                   SYS_Output, outputHandle,
                                   SYS_Error, errorHandle,
                                   NP_Child, TRUE,
                                   NP_CloseInput, inputHandle != ZERO,
                                   NP_CloseOutput, outputHandle != ZERO,
                                   NP_CloseError, errorHandle != ZERO,
                                   NP_FinalData, data,
                                   NP_FinalCode, OS4_FinalCode,
                                   NP_LocalVars, variables,
                                   TAG_DONE);

    const int32 ioErr = IDOS->IoErr();

    SDL_free(command);
    OS4_FreeEnvVariables(variables);

    if (error == -1) {
        dprintf("Failed to start process '%s'. SystemTags() returned %ld (error %ld)\n", args[0], error, ioErr);
        return SDL_SetError("Failed to start process '%s'", args[0]);
    }

    data->pid = ioErr; // DOS 51.77
    dprintf("'%s' started with pid %lu\n", args[0], data->pid);

    SDL_SetNumberProperty(process->props, SDL_PROP_PROCESS_PID_NUMBER, data->pid);

    if (stdin_option == SDL_PROCESS_STDIO_APP) {
        if (!OS4_SetupStream(process, stdin_pipe[WRITE_END], "stdin_pipe's write end", "wb", SDL_PROP_PROCESS_STDIN_POINTER)) {
            dprintf("Failed to setup STDIN pointer\n");
            OS4_Close(&stdin_pipe[WRITE_END], "stdin_pipe's write end");
        }
        OS4_Close(&stdin_pipe[READ_END], "stdin_pipe's read end");
    }

    if (stdout_option == SDL_PROCESS_STDIO_APP) {
        if (!OS4_SetupStream(process, stdout_pipe[READ_END], "stdout_pipe's read end", "rb", SDL_PROP_PROCESS_STDOUT_POINTER)) {
            dprintf("Failed to setup STDOUT pointer\n");
            OS4_Close(&stdout_pipe[READ_END], "stdout_pipe's read end");
        }
        OS4_Close(&stdout_pipe[WRITE_END], "stdout_pipe's write end");
    }

    if (stderr_option == SDL_PROCESS_STDIO_APP) {
        if (!OS4_SetupStream(process, stderr_pipe[READ_END], "stderr_pipe's read end", "rb", SDL_PROP_PROCESS_STDERR_POINTER)) {
            dprintf("Failed to setup STDERR pointer\n");
            OS4_Close(&stderr_pipe[READ_END], "stderr_pipe's read end");
        }
        OS4_Close(&stderr_pipe[WRITE_END], "stderr_pipe's write end");
    }

    return true;

fail:
    SDL_free(command);
    OS4_FreeEnvVariables(variables);

    OS4_Close(&stdin_pipe[READ_END], "stdin_pipe read end");
    OS4_Close(&stdin_pipe[WRITE_END], "stdin_pipe write end");

    OS4_Close(&stdout_pipe[READ_END], "stdout_pipe read end");
    OS4_Close(&stdout_pipe[WRITE_END], "stdout_pipe write end");

    OS4_Close(&stderr_pipe[READ_END], "stderr_pipe read end");
    OS4_Close(&stderr_pipe[WRITE_END], "stderr_pipe write end");

    OS4_Close(&inputHandle, "input handle");
    OS4_Close(&outputHandle, "output handle");
    OS4_Close(&errorHandle, "error handle");

    return false;
}

static int32 OS4_ProcessHook(struct Hook *hook, uint32 pid, struct Process *process)
{
    if (pid == process->pr_ProcessID) {
        dprintf("Send SIGBREAKF_C to PID %lu (%p)\n", pid, process);
        IExec->Signal((struct Task*)process, SIGBREAKF_CTRL_C);
        return TRUE;
    }

    return FALSE;
}

bool SDL_SYS_KillProcess(SDL_Process *process, bool force)
{
    if (!IDOS) {
        return SDL_SetError("IDOS nullptr");
    }

    bool result = false;

    const uint32 pid = process->internal->pid;

    static struct Hook hook;
    hook.h_Entry = (APTR)OS4_ProcessHook;

    if (IDOS->ProcessScan(&hook, (APTR)pid, 0 /* reserved */)) {
        dprintf("ProcessScan successful\n");
        result = true;
    } else {
        dprintf("Process %lu not found\n", pid);
    }

    return result;
}

bool SDL_SYS_WaitProcess(SDL_Process *process, bool block, int *exitcode)
{
    if (!IDOS) {
        return SDL_SetError("IDOS nullptr");
    }

    const uint32 pid = process->internal->pid;

    dprintf("Waiting for process %lu (block %d)\n", pid, block);

    if (block) {
        const int32 found = IDOS->WaitForChildExit(pid);
        if (found) {
            dprintf("Found, exitCode %ld\n", process->internal->exitCode);
        } else {
            dprintf("Failed, error %ld\n", IDOS->IoErr());
            //return SDL_SetError("Failed to wait process");
        }
        *exitcode = process->internal->exitCode;
    } else {
        const int32 found = IDOS->CheckForChildExit(pid);
        if (found) {
            dprintf("Process %lu is running\n", pid);
            return false;
        } else {
            dprintf("Process %lu not found, error %ld\n", pid, IDOS->IoErr());
        }
    }
    return true;
}

void SDL_SYS_DestroyProcess(SDL_Process *process)
{
    dprintf("\n");

    SDL_IOStream *io = (SDL_IOStream *)SDL_GetPointerProperty(process->props, SDL_PROP_PROCESS_STDIN_POINTER, NULL);
    if (io) {
        dprintf("Closing STDIN\n");
        SDL_CloseIO(io);
    }

    io = (SDL_IOStream *)SDL_GetPointerProperty(process->props, SDL_PROP_PROCESS_STDOUT_POINTER, NULL);
    if (io) {
        dprintf("Closing STDOUT\n");
        SDL_CloseIO(io);
    }

    io = (SDL_IOStream *)SDL_GetPointerProperty(process->props, SDL_PROP_PROCESS_STDERR_POINTER, NULL);
    if (io) {
        dprintf("Closing STDERR\n");
        SDL_CloseIO(io);
    }

    SDL_free(process->internal);
}

#endif // SDL_PROCESS_AMIGAOS4

