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

#if SDL_VIDEO_DRIVER_AMIGAOS4

#include <proto/keymap.h>
#include <proto/textclip.h>
#include <proto/diskfont.h>
#include <proto/locale.h>

#include <diskfont/diskfonttag.h>

#include "SDL_os4video.h"
#include "SDL_os4keyboard.h"

#include "../../events/SDL_keyboard_c.h"
#include "../../events/scancodes_amiga.h"

#include "../../main/amigaos4/SDL_os4debug.h"

static ULONG* unicodeMappingTable;

static SDL_Keycode
OS4_MapRawKey(SDL_VideoDevice *_this, int code)
{
    struct InputEvent ie;
    char buffer[2] = {0, 0};

    ie.ie_Class = IECLASS_RAWKEY;
    ie.ie_SubClass = 0;
    ie.ie_Code = code;
    ie.ie_Qualifier = 0;
    ie.ie_EventAddress = NULL;

    const WORD res = IKeymap->MapRawKey(&ie, buffer, sizeof(buffer), NULL);

    if (res == 1) {
        return buffer[0];
    }

    dprintf("MapRawKey(code %u) returned %d\n", code, res);
    return 0;
}

uint32
OS4_TranslateUnicode(SDL_VideoDevice *_this, uint16 code, uint32 qualifier, APTR iaddress)
{
    struct InputEvent ie;
    char buffer[10];

    ie.ie_Class = IECLASS_RAWKEY;
    ie.ie_SubClass = 0;
    ie.ie_Code  = code & ~(IECODE_UP_PREFIX);
    ie.ie_Qualifier = qualifier;
    ie.ie_EventAddress = iaddress; /* Enables dead key support */

    const WORD res = IKeymap->MapRawKey(&ie, buffer, sizeof(buffer), 0);

    if (res == 1) {
        if (unicodeMappingTable) {
            return unicodeMappingTable[(int)buffer[0]];
        } else if (buffer[0] <= 0x7F) {
            // Return just ASCII values which are valid UTF-8
            return buffer[0];
        } else {
            dprintf("Failed to map ANSI code %u to unicode\n", buffer[0]);
        }
    } else {
        dprintf("MapRawKey(code %u, qualifier %lu) returned %d\n", code, qualifier, res);
    }

    return 0;
}

static void
OS4_UpdateKeymap(SDL_VideoDevice *_this)
{
    SDL_Keymap *keymap = SDL_CreateKeymap(true);

    for (int i = 0; i < SDL_arraysize(amiga_scancode_table); i++) {
        /* Make sure this scancode is a valid character scancode */
        const SDL_Scancode scancode = amiga_scancode_table[i];
        if (scancode == SDL_SCANCODE_UNKNOWN ||
            (SDL_GetKeyFromScancode(scancode, SDL_KMOD_NONE, false) & SDLK_SCANCODE_MASK)) {
            continue;
        }

        SDL_SetKeymapEntry(keymap, scancode, 0, OS4_MapRawKey(_this, i)); // TODO: test me
    }

    SDL_SetKeymap(keymap, false);
}

bool
OS4_SetClipboardText(SDL_VideoDevice *_this, const char *text)
{
    const LONG result = ITextClip->WriteClipVector(text, SDL_strlen(text));

    //dprintf("Result %s\n", result ? "OK" : "NOK");

    return result ? true : false;
}

char *
OS4_GetClipboardText(SDL_VideoDevice *_this)
{
    STRPTR from;
    ULONG size;
    char *to = NULL;

    const LONG result = ITextClip->ReadClipVector(&from, &size);

    //dprintf("Read '%s' (%d bytes) from clipboard\n", from, size);

    if (result) {
        if (size) {
            to = SDL_malloc(++size);

            if (to) {
               SDL_strlcpy(to, from, size);
            } else {
                dprintf("Failed to allocate memory\n");
            }
        } else {
            to = SDL_strdup("");
        }

        ITextClip->DisposeClipVector(from);
    }

    return to;
}

bool
OS4_HasClipboardText(SDL_VideoDevice *_this)
{
    /* This is silly but is there a better way to check? */
    char *to = OS4_GetClipboardText(_this);

    if (to) {
        size_t len = SDL_strlen(to);

        SDL_free(to);

        if (len > 0) {
            return true;
        }
    }

    return false;
}

void
OS4_InitKeyboard(SDL_VideoDevice *_this)
{
    OS4_UpdateKeymap(_this);

    //SDL_SetScancodeName(SDL_SCANCODE_APPLICATION, "Menu");
    SDL_SetScancodeName(SDL_SCANCODE_LGUI, "Left Amiga");
    SDL_SetScancodeName(SDL_SCANCODE_RGUI, "Right Amiga");
    SDL_SetScancodeName(SDL_SCANCODE_LCTRL, "Control");

    if (!unicodeMappingTable) {
        struct Locale *locale = ILocale->OpenLocale(NULL);

        if (locale) {
            const uint32 codeSet = locale->loc_CodeSet ? locale->loc_CodeSet : 4;

            dprintf("Default code set %lu\n", codeSet);

            unicodeMappingTable = (ULONG *)IDiskfont->ObtainCharsetInfo(DFCS_NUMBER, codeSet, DFCS_MAPTABLE);

            if (!unicodeMappingTable) {
                dprintf("Failed to get unicode mapping table\n");
            }

            ILocale->CloseLocale(locale);
        } else {
            dprintf("Failed to open current locale\n");
        }
    }
}

void
OS4_QuitKeyboard(SDL_VideoDevice *_this)
{
}

#endif /* SDL_VIDEO_DRIVER_AMIGAOS4 */
