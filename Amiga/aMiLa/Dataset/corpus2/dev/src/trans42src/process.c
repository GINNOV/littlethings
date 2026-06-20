#ifndef KS13

#include <proto/dos.h>
#include <proto/exec.h>
#include <string.h>
#include <stdlib.h>
#include <exec/alerts.h>

#include "DIST:Include/clib/translator_protos.h"
#include "DIST:Include/pragmas/translator_pragmas.h"


static UBYTE *read_hex(UBYTE *str, ULONG *result)
{
    ULONG val = 0;
    UBYTE hexs[] = "0123456789ABCDEF";
    
    for (;;)
    {
        UBYTE *ptr;
        UBYTE ch = *str++;
        
        if (ch == ' ')
        {
            *result = val;
            return str;
        }
        
        ptr = strchr(hexs,ch);
        
        if (!ptr)
        {
            struct ExecBase *SysBase = *(struct ExecBase **)4;
            Alert(AN_Unknown | AG_BadParm | AO_Unknown);
            
            *result = 0;
            
            /* Hopefully this will put up a requestor:
               Please insert volume "** BAD TASKNAME:" ??? */
            
            return "** BAD TASKNAME:";
        }
        
        val = (val << 4) + (ptr - hexs);
    }
}


PRIVATE void read_process(void)
{
    struct ExecBase *SysBase = *(struct ExecBase **)4;
    struct Library *TranslatorBase;
    
    struct Task *me = FindTask(0);
    
    /*
     * Process name contains information, separated by spaces:
     *
     *   <parent-task-address> <signal-number> <filename>
     *
     *   ie: "36F0B0 80000000 dh1:langs/svenska.accent"
     */
    
    struct Task *parent;
    ULONG signal;
    
    UBYTE *name = me->tc_Node.ln_Name;
    
    name = read_hex(name, (ULONG *)&parent);
    name = read_hex(name, &signal);
    
    if (TranslatorBase = OpenLibrary("translator.library", 42))
    {
        LoadAccent(name);
        CloseLibrary(TranslatorBase);
    }
    else
    {
        Alert(AN_Unknown | AG_OpenLib | AO_Unknown);
    }
    
    Signal(parent, signal);
}

#endif
