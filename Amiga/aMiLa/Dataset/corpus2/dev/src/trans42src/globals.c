#include <proto/exec.h>
#include <proto/locale.h>
#include <proto/utility.h>
#include <exec/memory.h>
#include <string.h>

#include "globals.h"
#include "phonemes.h"
#include "messages.h"


static volatile globalPart *LibGlobal;

#ifdef _SASC
#pragma msg 104 ignore
#endif

void KPrintF(const char *fmt,...);
#define DBUG(x) KPrintf x


void  __saveds __asm
__SetLibGlobals(register __a6 struct MyLibrary *libbase,
                register __a0 globalPart *g)
{
    LibGlobal = g;
}


// Called before all else except __SetLibGlobals

int __saveds __asm __InitLibGlobals(register __a6 struct MyLibrary *libbase)
{
    LibGlobal->semaphore = AllocVec(sizeof(struct SignalSemaphore),
        MEMF_CLEAR | MEMF_PUBLIC);
    
    if (LibGlobal->semaphore)
    {
        NewList((struct List *)&LibGlobal->languages);
        InitSemaphore(LibGlobal->semaphore);
        return 0;
    }
    
    return 1;
}

void __saveds __asm __CleanupLibGlobals(register __a6 struct MyLibrary *libbase)
{
    Language *m, *next;
    
    for (m = (Language *)LibGlobal->languages.mlh_Head;
         m->node.mln_Succ;
         m = next)
    {
        next = (Language *)m->node.mln_Succ;
        
        if (m && m->refCount == 1)
        {
            free_accent(m);
        }
        else
        {
            yyerror(0, MSG_CorruptList);
            break;
        }
    }
    
    FreeVec(LibGlobal->semaphore);
}

/* Free what I can -- ie: cached languages */

void __saveds __asm __UserLibExpunge(register __a6 struct Library *libbase)
{
    if (AttemptSemaphore(LibGlobal->semaphore))
    {
        Language *m, *next;
        
        for (m = (Language *)LibGlobal->languages.mlh_Head;
             m->node.mln_Succ;
             m = next)
        {
            next = (Language *)m->node.mln_Succ;
            
            if (m->refCount == 1)   // Only the list holds it
            {
                Remove((struct Node *)m);
                free_accent(m);
            }
        }
        
        ReleaseSemaphore(LibGlobal->semaphore);
    }
}

PRIVATE void replace_accent(Language *dialect)
{
    Language *m, *free_me=0;
    UBYTE *name = dialect->name;
    
    /* Search list -- delete any with same name
       (and free if usecount is zero) */
    
    ObtainSemaphore(LibGlobal->semaphore);
    
    for (m = (Language *)LibGlobal->languages.mlh_Head;
         m->node.mln_Succ;
         m = (Language *)m->node.mln_Succ)
    {
        if (!Stricmp(m->name, name))
        {
            if (--m->refCount == 0) free_me = m;
            
            Remove((struct Node *)m);
            break;
        }
    }
    
    AddHead((struct List *)&LibGlobal->languages, (struct Node *)dialect);
    dialect->refCount++;
    
    ReleaseSemaphore(LibGlobal->semaphore);
    
    if (free_me) free_accent(free_me);
}


PRIVATE Language *just_find_accent(UBYTE *name)
{
    Language *m;
    
    name = NamePart(name);
    if (!name) return 0;
    
    ObtainSemaphore(LibGlobal->semaphore);
    
    for (m = (Language *)LibGlobal->languages.mlh_Head;
         m->node.mln_Succ;
         m = (Language *)m->node.mln_Succ)
    {
        if (!Stricmp(m->name, name))
        {
            m->refCount++;
            ReleaseSemaphore(LibGlobal->semaphore);
            
            FreeVec(name);
            return m;
        }
    }
    
    ReleaseSemaphore(LibGlobal->semaphore);
    
    FreeVec(name);
    return 0;
}


PRIVATE Language *find_any_accent(void)
{
    Language *m;
    
    ObtainSemaphore(LibGlobal->semaphore);
    
    m = (Language *)LibGlobal->languages.mlh_Head;
    
    if (m->node.mln_Succ)
    {
        m->refCount++;
    }
    else
    {
        m = 0;
    }
    
    ReleaseSemaphore(LibGlobal->semaphore);
    return m;
}



PRIVATE Language *find_or_load_accent(STRPTR name)
{
    Language *lang = just_find_accent(name);
    
    if (lang) return lang;
    
    lang = load_accent(name);
    if (!lang) return 0;
    
    replace_accent(lang);
    return lang;
}


PRIVATE Language *copy_accent(Language *dialect)
{
    ObtainSemaphore(LibGlobal->semaphore);
    dialect->refCount++;
    ReleaseSemaphore(LibGlobal->semaphore);
    
    return dialect;
}



PRIVATE void finished_with_accent(Language *dialect)
{
    int count;
    
    ObtainSemaphore(LibGlobal->semaphore);
    count = --dialect->refCount;
    ReleaseSemaphore(LibGlobal->semaphore);
    
    if (!count)
    {
        free_accent(dialect);
    }
}

