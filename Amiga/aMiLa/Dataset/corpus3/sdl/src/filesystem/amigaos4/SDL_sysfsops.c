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

#if defined(SDL_FSOPS_AMIGAOS4)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
// System dependent filesystem routines

#include "../SDL_sysfilesystem.h"
#include "SDL_sysfilesystem_amigaos4.h"
#include "../../main/amigaos4/SDL_os4debug.h"

#include <proto/dos.h>

bool SDL_SYS_EnumerateDirectory(const char *path, SDL_EnumerateDirectoryCallback cb, void *userdata)
{
    if (!IDOS) {
        dprintf("IDOS nullptr\n");
        return false;
    }

    if (!cb) {
        dprintf("Callback nullptr\n");
        return false;
    }

    // TODO: volumes when path is empty?

    if (*path == '\0') {
        return false;
    }

    APTR context = IDOS->ObtainDirContextTags(EX_StringNameInput, path, EX_DataFields, (EXF_NAME|EXF_LINK|EXF_TYPE), TAG_DONE);

    bool success = true;

    if (context) {
        char dirname[1024];
        const size_t len = strlen(path);
        const char last = path[len - 1];
        const bool hasSeparator = (last == ':') || (last == '/');

        snprintf(dirname, sizeof(dirname), "%s%s", path, hasSeparator ? "" : "/");

        struct ExamineData *data;

        while ((data = IDOS->ExamineDir(context))) {
            // TODO: link handling
            if (EXD_IS_FILE(data) || EXD_IS_DIRECTORY(data)) {
                const int result = cb(userdata, dirname, data->Name);
                if (result == SDL_ENUM_SUCCESS) {
                    dprintf("Enumerating dir '%s' stopped after item '%s'\n", dirname, data->Name);
                    success = true;
                    break;
                } else if (result == SDL_ENUM_FAILURE) {
                    dprintf("Callback returned error while enumerating dir '%s', item '%s'\n", dirname, data->Name);
                    SDL_SetError("Callback returned error");
                    success = false;
                    break;
                }
            }
        }

        const int32 err = IDOS->IoErr();

        if (ERROR_NO_MORE_ENTRIES != err) {
            dprintf("Error %ld while examining path '%s'\n", err, path);
            SDL_SetError("Error while examining path");
            success = false;
        }

        IDOS->ReleaseDirContext(context);
    } else {
        dprintf("Failed to obtain dir context for '%s' (err %ld)\n", path, IDOS->IoErr());
        SDL_SetError("Failed to obtain dir context");
        success = false;
    }

    return success;
}

bool SDL_SYS_RemovePath(const char *path)
{
    if (!IDOS) {
        dprintf("IDOS nullptr\n");
        return false;
    }

    const int32 success = IDOS->Delete(path);

    if (success) {
        dprintf("'%s' deleted\n", path);
    } else {
        const int32 err = IDOS->IoErr();
        dprintf("Failed to delete '%s' (err %ld)\n", path, err);
        if (err == ERROR_OBJECT_NOT_FOUND) {
            dprintf("Object doesn't exist -> success\n");
        } else {
            return SDL_SetError("Failed to delete path");
        }
    }

    return true;
}

bool SDL_SYS_RenamePath(const char *oldpath, const char *newpath)
{
    if (!IDOS) {
        dprintf("IDOS nullptr\n");
        return false;
    }

    const int32 success = IDOS->Rename(oldpath, newpath);

    if (success) {
        dprintf("'%s' renamed to '%s'\n", oldpath, newpath);
    } else {
        dprintf("Failed to rename '%s' to '%s' (err %ld)\n", oldpath, newpath, IDOS->IoErr());
        return SDL_SetError("Failed to rename path");
    }

    return true;
}

bool SDL_SYS_CopyFile(const char *oldpath, const char *newpath)
{
    if (!IDOS) {
        dprintf("IDOS nullptr\n");
        return false;
    }

    char buffer[1024];
    snprintf(buffer, sizeof(buffer), "Copy CLONE BUFFER=32768 %s %s", oldpath, newpath);

    const int32 result = IDOS->SystemTags(buffer, TAG_DONE);

    if (result == 0) {
        dprintf("File %s copied to %s\n", oldpath, newpath);
        return true;
    }

    dprintf("System(%s) failed with %ld\n", buffer, result);
    return false;
}

bool SDL_SYS_CreateDirectory(const char *path)
{
    return OS4_CreateDirTree(path);
}

bool SDL_SYS_GetPathInfo(const char *path, SDL_PathInfo *info)
{
    if (!IDOS) {
        dprintf("IDOS nullptr\n");
        return false;
    }

    struct ExamineData *data = IDOS->ExamineObjectTags(EX_StringNameInput, path, TAG_DONE);

    if (data) {
        if (EXD_IS_FILE(data)) {
            info->type = SDL_PATHTYPE_FILE;
            info->size = data->FileSize;
        } else if (EXD_IS_DIRECTORY(data)) {
            info->type = SDL_PATHTYPE_DIRECTORY;
        } else {
            info->type = SDL_PATHTYPE_OTHER;
        }

        // TODO: time fields are nanoseconds since Jan 1, 1970.

        IDOS->FreeDosObject(DOS_EXAMINEDATA, data);
    } else {
        dprintf("Failed to examine object '%s' (err %ld)\n", path, IDOS->IoErr());
        SDL_SetError("Failed to examine object");
        info->type = SDL_PATHTYPE_NONE;
        return false;
    }

    return true;
}

#endif // SDL_FSOPS_AMIGAOS4

