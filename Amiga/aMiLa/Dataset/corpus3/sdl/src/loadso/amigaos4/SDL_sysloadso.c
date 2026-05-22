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

#ifdef SDL_LOADSO_AMIGAOS4

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* System dependent library loading routines                           */

#include <proto/elf.h>
#include <proto/dos.h>

#include <SDL3/SDL_loadso.h>
#include "../../video/amigaos4/SDL_os4library.h"

#include "../../main/amigaos4/SDL_os4debug.h"

typedef struct SDL_SharedObject {
    Elf32_Handle elf_handle;
    APTR shared_object;
} SDL_SharedObject;

SDL_SharedObject *
SDL_LoadObject(const char *sofile)
{
    if (!IElf) {
        dprintf("IElf nullptr\n");
        return NULL;
    }

    SDL_SharedObject *handle = SDL_malloc(sizeof(SDL_SharedObject));

    if (handle) {
        BPTR seglist = IDOS->GetProcSegList(NULL, GPSLF_RUN);

        if (seglist) {
            Elf32_Handle eh = NULL;

            IDOS->GetSegListInfoTags(seglist, GSLI_ElfHandle, &eh, TAG_DONE);

            dprintf("Elf handle %p\n", eh);

            if (eh) {
                APTR so = IElf->DLOpen(eh, sofile, 0);

                if (so) {
                    dprintf("'%s' loaded\n", sofile);

                    handle->elf_handle = eh;
                    handle->shared_object = so;

                    return handle;
                } else {
                    dprintf("DLOpen failed for '%s'\n", sofile);
                    SDL_SetError("DLOpen failed for '%s'", sofile);
                }
            } else {
                dprintf("Failed to get elf handle of running task\n");
                SDL_SetError("Failed to get elf handle");
            }
        } else {
            dprintf("Failed to get seglist\n");
            SDL_SetError("Failed to get seglist");
        }

        SDL_free(handle);
    }

    return NULL;
}

SDL_FunctionPointer
SDL_LoadFunction(SDL_SharedObject *handle, const char *name)
{
    void *symbol = NULL;

    if (!IElf) {
        dprintf("IElf nullptr\n");
        return NULL;
    }

    if (handle) {
        APTR address = NULL;
        Elf32_Error result = IElf->DLSym(handle->elf_handle, handle->shared_object, name, &address);

        if (result == ELF32_NO_ERROR) {
            symbol = address;
            dprintf("Symbol '%s' found at %p\n", name, address);
        } else {
            dprintf("Symbol '%s' not found\n", name);
            SDL_SetError("Symbol '%s' not found", name);
        }
    }

    return symbol;
}

void
SDL_UnloadObject(SDL_SharedObject *handle)
{
    if (!IElf) {
        dprintf("IElf nullptr\n");
        return;
    }

    if (handle) {
#ifdef DEBUG
        Elf32_Error result =
#endif
        IElf->DLClose(handle->elf_handle, handle->shared_object);

        dprintf("DLClose %s\n", (result == ELF32_NO_ERROR) ? "OK" : "failed" );

/* BUG: testloadso crashes on Final Edition...removed this block for now, until a solution is found.
        IElf->CloseElfTags(
            oh->elf_handle,
            TAG_DONE);
*/
        SDL_free(handle);
    }
}

#endif /* SDL_LOADSO_AMIGAOS4 */
