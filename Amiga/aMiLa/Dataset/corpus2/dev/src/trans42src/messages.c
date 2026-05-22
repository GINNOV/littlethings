#include <exec/types.h>
#include <proto/locale.h>
#include <proto/exec.h>

#include "phonemes.h"

PRIVATE UBYTE __far *message[] = {

#define _TEXT_ONLY
#define MSG(name, text) text,
#include "messages.h"

};

#define NUMSTR (sizeof message/sizeof message[0])


PRIVATE UBYTE *getmsg(ULONG num)
{
    if (num >= NUMSTR)
    {
        return "Illegal string number";
    }

#ifndef KS13
    if (LocaleBase)
    {
        return GetCatalogStr(catalog, num, message[num]);
    }
    else
#endif
    {
        return message[num];
    }
}


