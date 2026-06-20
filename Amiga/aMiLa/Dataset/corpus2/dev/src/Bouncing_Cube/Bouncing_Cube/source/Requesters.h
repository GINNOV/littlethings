/* AmigaOS includes */
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

int answer;
struct Library *IntuitionBase;

/* Structures for requesters */

struct EasyStruct ReqWindow =
    {
    sizeof(struct EasyStruct),
    0,
    "Error",
    "Could not load texture file.",
    "sucks!",
    };

struct EasyStruct AboutWindow =
    {
    sizeof(struct EasyStruct),
    0,
    "About",
    "Bouncing Cube\nVersion 1.0\n\nCopyright © 2002\nby Norman Walter\nAll Rights Reserved\n\nhttp://www.norman-interactive.com\n",
    "rulez!",
    };
    
struct EasyStruct QuitWindow =
    {
    sizeof(struct EasyStruct),
    0,
    "Quit",
    "Do you really want to quit?",
    "Yep|Nope",
    };
