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
    "Texture file not found.",
    "OK",
    };

struct EasyStruct AboutWindow =
    {
    sizeof(struct EasyStruct),
    0,
    "About",
    "RocketCar\nVersion 1.2\n\nCopyright © 2002\nby Norman Walter\nAll Rights Reserved\n",
    "OK",
    };
    
struct EasyStruct QuitWindow =
    {
    sizeof(struct EasyStruct),
    0,
    "Quit",
    "Do you really want to quit?",
    "Yes|No",
    };
