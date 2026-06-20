#include "stack.h"
#include "phonemes.h"
#include "messages.h"

#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/memory.h>
#include <string.h>


STRUCT (accentStack)
{
    Language *lang;
    UBYTE *src;
    
    accentStack *next;
};


Language *curLang;
struct srcInfo src;

static accentStack *accstk;
static int srcDepth=0;

/* The global structures */

int is_lowlevel(UBYTE *ptr)
{
    return (ptr >= src.base &&
            ptr <= src.end);
}


void clear_lowlevel_refs(void)
{
    accentStack *stk;
    
    while (accstk && !is_lowlevel(accstk->src))
    {
        pop_accent();
    }
    
    for (stk = accstk; stk; stk=stk->next)
    {
        if (stk->src && is_lowlevel(stk->src)) stk->src = 0;
    }
}


int push_accent(int pushSrc)
{
    if (srcDepth >= 64)
    {
        yyerror(curLang, MSG_Overflow);
    }
    else
    {
        accentStack *stk = AllocVec(sizeof *stk,MEMF_ANY);
        
        if (stk)
        {
            stk->next = accstk;
            if (pushSrc) stk->src = src.cur; else stk->src = 0;
            
            srcDepth++;
            
            stk->lang = copy_accent(curLang);
            accstk = stk;
            return 1;
        }
    }
    
    return 0;
}


int pop_accent(void)
{
    accentStack *stk;
    
    if (stk = accstk)
    {
        accstk = stk->next;
        
        finished_with_accent(curLang);
        
        curLang = stk->lang;
        if (stk->src) src.cur = stk->src;
        
        FreeVec(stk);
        srcDepth--;
        
        return 1;
    }
    
    return 0;
}


void free_accent_stack(void)
{
    while (pop_accent());
    if (curLang) finished_with_accent(curLang);
    curLang = 0;
}



int change_accent(STRPTR name)
{
    Language *lang = find_or_load_accent(name);
    
    if (lang)
    {
        finished_with_accent(curLang);
        curLang = lang;
        return 1;
    }
    
    finished_with_accent(lang);
    return 0;
}


LONG __asm __saveds SetAccent(register __a0 STRPTR name)
{
    Language *n = find_or_load_accent(name);
    
    if (n)
    {
        free_accent_stack();
        curLang = n;
    }
    
    return (n != 0);
}




static void LoadEnv(void)
{
    BPTR in = Open("ENV:Sys/Translator.prefs", MODE_OLDFILE);
    
    if (in)
    {
        UBYTE buffer[128];
        int len;
        
        len = Read(in, buffer, sizeof buffer-1);
        
        if (len>0)
        {
            UBYTE *p;
            
            buffer[len] = 0;
            
            if (p = strchr(buffer, '\n'))
            {
                *p++ = 0;
                
                if ((p - buffer) + 4 == len)
                {
                    
                    memcpy(scopeCode, p, 4);
                    curLang = find_or_load_accent(buffer);
                }
            }
        }
        
        Close(in);
    }
}

int current_accent(UBYTE *start)
{
    if (!curLang)
    {
        if (FindTask(0)->tc_Node.ln_Type == NT_PROCESS)
        {
            LoadEnv();
            if (!curLang) curLang = find_or_load_accent("american");
        }
        
        if (!curLang) curLang = find_any_accent();
    }
    
    if (!curLang) return 0;
    
    src.space = 0;
    
    src.base = start;
    src.cur = start;
    
    src.end = src.base + strlen(start);
    
    return 1;
}




