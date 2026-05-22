/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for 
use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
published by Addison-Wesley (ISBN 0-201-56775-X).

The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
information on the correct usage of the techniques and operating system 
functions presented in these examples.  The source and executable code 
of these examples may only be distributed in free electronic form, via 
bulletin board or as part of a fully non-commercial and freely 
redistributable diskette.  Both the source and executable code (including 
comments) must be included, without modification, in any copy.  This 
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.

*/

/* 
appkeymap.c - subroutines to copy the default keymap, modify the copy

Usage: struct KeyMap *appkeymap = CreateAppKeyMap();
       void DeleteAppKeyMap(struct KeyMap *appkeymap);

This example modifies the copied keymap by unmapping all of the
numeric keypad keys.  This creates a good keymap for use with either
keymap.library MapANSI() or commodities InvertString().
If you used a default keymap with the above functions, numeric keypad
raw key values would be returned for keys which are available with
fewer keypresses on numeric pad than on the normal keyboard.
It is generally preferable to have the normal keyboard raw values
since many applications attach special meanings to numeric pad keys.
The AlterAppKeyMap() routine in this module could easilty be modified
to instead set new values for numeric pad or function keys.

IMPORTANT: Do Not Use SetKeyMapDefault() unless you are a system
preferences editor OR an application that takes over the machine.
If you want to use a customized keymap such as this in your
application, open your own Intuition window, attach a console
device to it, and then use the console device SETKEYMAP command
to set your console device unit to your custom keymap.

*/

#include <exec/types.h>
#include <exec/memory.h>
#include <devices/console.h>
#include <devices/keymap.h>

#include <clib/exec_protos.h>
#include <clib/keymap_protos.h>
#include <clib/alib_protos.h>

/* Raw keys we might want to remap which are the same on all keyboards */
#define UP_KEY      0x4C
#define DOWN_KEY    0x4D
#define RIGHT_KEY   0x4E
#define LEFT_KEY    0x4F

#define F1_KEY      0x50
#define F2_KEY      0x51
#define F3_KEY      0x52
#define F4_KEY      0x53
#define F5_KEY      0x54
#define F6_KEY      0x55
#define F7_KEY      0x56
#define F8_KEY      0x57
#define F9_KEY      0x58
#define F10_KEY     0x59

#define N0_KEY      0x0F
#define N1_KEY      0x1D
#define N2_KEY      0x1E
#define N3_KEY      0x1F
#define N4_KEY      0x2D
#define N5_KEY      0x2E
#define N6_KEY      0x2F
#define N7_KEY      0x3D
#define N8_KEY      0x3E
#define N9_KEY      0x3F

#define NPERIOD_KEY 0x3C
#define NOPAREN_KEY 0x5A
#define NCPAREN_KEY 0x5B
#define NSLASH_KEY  0x5C
#define NASTER_KEY  0x5D
#define NMINUS_KEY  0x4A
#define NPLUS_KEY   0x5E
#define NENTER_KEY  0x43

#define RETURN_KEY  0x44
#define HELP_KEY    0x5F


/* Null terminated array of keys our application wants to remap or disable */
UBYTE nullkeys[] =
{ N0_KEY,      N1_KEY,      N2_KEY,      N3_KEY,      N4_KEY,
  N5_KEY,      N6_KEY,      N7_KEY,      N8_KEY,      N9_KEY,
  NPERIOD_KEY, NOPAREN_KEY, NCPAREN_KEY, NSLASH_KEY,
  NASTER_KEY,  NMINUS_KEY,  NPLUS_KEY,   NENTER_KEY,
  0
};

/* Count of elements in keymap arrays */
#define MAP_SIZE  64
#define TYPE_SIZE 64
#define CAPS_SIZE 8
#define REPS_SIZE 8

/* We allocate our Lo and Hi array pairs each as a single array */
struct KeyMapArrays {
   ULONG LHKeyMap[MAP_SIZE << 1];
   UBYTE LHKeyMapTypes[TYPE_SIZE << 1];
   UBYTE LHCapsable[CAPS_SIZE << 1];
   UBYTE LHRepeatable[REPS_SIZE << 1];
   };

static struct KeyMapArrays *karrays;
static struct KeyMap *defkeymap, *appkeymap;
static LONG mapsize;

/* externally callable functions */
struct KeyMap *CreateAppKeyMap(void);
void DeleteAppKeyMap(struct KeyMap *appkeymap);

/* local functions */
static void CopyKeyMap(struct KeyMap *source, struct AppKeyMap *dest);
static void AlterAppKeyMap(struct KeyMap *appkeymap);


struct Library *KeymapBase = NULL;

struct KeyMap *CreateAppKeyMap()
    {
    if(KeymapBase = OpenLibrary("keymap.library",37L))
        {
        /* Get a pointer to the keymap which is set as the system default */
        if(defkeymap = AskKeyMapDefault())
            {
            /* Allocate our KeyMap structures and arrays */
            mapsize = sizeof(struct KeyMap) + sizeof(struct KeyMapArrays);
            if(appkeymap = (struct KeyMap *)AllocMem(mapsize,MEMF_CLEAR))
                {
                /* Init our appkeymap fields to point to our allocated arrays.
                 * Here the  + 1  means  + sizeof(struct KeyMap)  because
                 * we are adding 1 to a pointer to a struct KeyMap.
                 * Each LH array contains a Lo and a Hi array.
                 */
                karrays = (struct KeyMapArrays *)(appkeymap + 1);
                appkeymap->km_LoKeyMap = &karrays->LHKeyMap[0];
                appkeymap->km_HiKeyMap = &karrays->LHKeyMap[MAP_SIZE];
                appkeymap->km_LoKeyMapTypes = &karrays->LHKeyMapTypes[0];
                appkeymap->km_HiKeyMapTypes = &karrays->LHKeyMapTypes[TYPE_SIZE];
                appkeymap->km_LoCapsable = &karrays->LHCapsable[0];
                appkeymap->km_HiCapsable = &karrays->LHCapsable[CAPS_SIZE];
                appkeymap->km_LoRepeatable = &karrays->LHRepeatable[0];
                appkeymap->km_HiRepeatable = &karrays->LHRepeatable[REPS_SIZE];

                /* Copy the user's default system keymap arrays to our appkeymap
                 * arrays to get the proper keymappings for the user's keyboard.
                 */ 
                CopyKeyMap(defkeymap, appkeymap);

                /* Now make our changes to our appkeymap */
                AlterAppKeyMap(appkeymap);
                }
            }
        CloseLibrary(KeymapBase);
        }
    return(appkeymap);
    }


void DeleteAppKeyMap(struct KeyMap *appkeymap)
    {
    if(appkeymap)  FreeMem(appkeymap, mapsize);
    }


static void AlterAppKeyMap(struct KeyMap *appkeymap)
{
ULONG *keymappings;
UBYTE *keymaptypes;
UBYTE rawkeynum;
int i;

/* Our application wants numeric pad keys remapped to nothing
 * so that we can use this keymap with MapANSII and NOT get back
 * raw codes for numeric keypad.
 * Alternately (for example) you could set the types to KCF_STRING
 * and set the mappings to point to null terminated strings.
 */

keymappings = appkeymap->km_LoKeyMap;
keymaptypes = appkeymap->km_LoKeyMapTypes;

for(i=0; rawkeynum = nullkeys[i]; i++)
    {
    /* Because we allocated each of our Lo and Hi array pairs as
     * sequential memory, we can use the RAWKEY values directly
     * to index into our sequential Lo/Hi array
     */
    keymaptypes[rawkeynum] = KCF_NOP;
    }
}


static void CopyKeyMap(struct KeyMap *s, struct KeyMap *d)
{
UBYTE *bb;
ULONG *ll;
int i;

/* Copy keymap s (source) to keymap d (dest) */
for (i=0,ll=s->km_LoKeyMap;i<MAP_SIZE; i++) d->km_LoKeyMap[i] = *ll++;
for (i=0,ll=s->km_HiKeyMap;i<MAP_SIZE; i++) d->km_HiKeyMap[i] = *ll++;

for (i=0, bb=s->km_LoKeyMapTypes; i<TYPE_SIZE; i++) d->km_LoKeyMapTypes[i] = *bb++;
for (i=0, bb=s->km_HiKeyMapTypes; i<TYPE_SIZE; i++) d->km_HiKeyMapTypes[i] = *bb++;

for (i=0, bb=s->km_LoCapsable; i<CAPS_SIZE; i++) d->km_LoCapsable[i] = *bb++;
for (i=0, bb=s->km_HiCapsable; i<CAPS_SIZE; i++) d->km_HiCapsable[i] = *bb++;

for (i=0, bb=s->km_LoRepeatable; i<REPS_SIZE; i++) d->km_LoRepeatable[i] = *bb++;
for (i=0, bb=s->km_HiRepeatable; i<REPS_SIZE; i++) d->km_HiRepeatable[i] = *bb++;
}
