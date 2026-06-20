#include <proto/utility.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/locale.h>
#include <exec/memory.h>

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#include "phonemes.h"
#include "messages.h"
#include "stack.h"

PRIVATE UBYTE __far speechPath[] = "LOCALE:Accents/";
PRIVATE UBYTE __far speechExt[] = ".accent";
PRIVATE UBYTE __far copyright[]="$COPYRIGHT:© 1995 Francesco Devitt$";

/* Not in LibGlobal because should be per open-library instance */

UBYTE scopeCode[4];

#ifndef MWDEBUG

struct DosLibrary *DOSBase;

#endif
struct IntuitionBase *IntuitionBase;

#ifdef KS13
#define LIBVER 33

struct GfxBase *GfxBase;

#else
#define LIBVER 37

struct Library *UtilityBase;
struct Library *LocaleBase;

struct Locale *locale;
struct Catalog *catalog;
    
#endif


void KPrintF(const char *fmt,...);
#define DBUG(x) KPrintf(x)


int __saveds __asm __UserLibInit(register __a6 struct MyLibrary *libbase)
{
    scopeCode[before_name] = '\\';
    scopeCode[after_name] = 0;
    scopeCode[begin_scope] = '{';
    scopeCode[end_scope] = '}';
    
#ifndef KS13
    if (LocaleBase = OpenLibrary("locale.library", 38))
    {
        locale = OpenLocale(0);     /* Guaranteed a valid return */
        
        catalog = OpenCatalog(0, "Sys/translator.catalog",
            OC_BuiltInLanguage, "english",
        TAG_DONE);
    }
#endif

#ifndef MWDEBUG

    DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", LIBVER);
    
    if (DOSBase)
#endif
    {
        IntuitionBase = (APTR)OpenLibrary("intuition.library", LIBVER);
        
        if (IntuitionBase)
        {
#ifndef KS13
            if (UtilityBase = OpenLibrary("utility.library", LIBVER))
#else
            if (GfxBase = (APTR)OpenLibrary("graphics.library", LIBVER))
#endif
            {
                return 0;
            }
            
            CloseLibrary((APTR)IntuitionBase);
        }
        
#ifndef MWDEBUG
        CloseLibrary((struct Library *)DOSBase);
#endif
    }

#ifndef KS13    
    CloseCatalog(catalog);
    CloseLocale(locale);
    if (LocaleBase) CloseLibrary(LocaleBase);
#endif
    
    return 1;
}

void __saveds __asm __UserLibCleanup(register __a6 struct MyLibrary *libbase)
{
    free_accent_stack();
    
#ifndef KS13
    CloseCatalog(catalog);
    CloseLocale(locale);
    
    if (LocaleBase) CloseLibrary(LocaleBase);
    
    CloseLibrary(UtilityBase);
#else
    CloseLibrary((APTR)GfxBase);
#endif

    CloseLibrary((APTR)IntuitionBase);
    
#ifndef MWDEBUG
    CloseLibrary((APTR)DOSBase);
#endif
}





PRIVATE int find_class(Language *d, const UBYTE *str)
{
    int n;
    
    for (n = 0; n<d->numClasses; n++)
    {
        if (!Stricmp((STRPTR)str, d->classList[n].name)) return n+1;
    }
    
    return 0;
}

PRIVATE int add_class(Language *d, const UBYTE *str)
{
    UBYTE *p;
    
    if (d->numClasses == d->maxClasses)
    {
        int newsize = d->numClasses * 2;
        
        struct charClass *newclass;
        
        if (!newsize) newsize = 16;
        else if (newsize > 255)
        {
            newsize=255;
            if (d->numClasses == 255)
            {
                yyerror(d, MSG_MaxClasses);
                return 0;
            }
        }
        
        newclass = AllocVec(newsize*sizeof(struct charClass), MEMF_ANY);
        
        if (!newclass)
        {
            yyerror(d, MSG_NoMemory);
            return 0;
        }
        
        memcpy(newclass, d->classList, d->numClasses*sizeof(struct charClass));
        
        if (d->classList) FreeVec(d->classList);
        
        d->classList = newclass;
        d->maxClasses = newsize;
    }
    
    p = Strdup(str);
    
    if (!p)
    {
        yyerror(d, MSG_NoMemory);
        return 0;
    }
    
    d->classList[d->numClasses].name = p;
    d->classList[d->numClasses].words = 0;
    d->classList[d->numClasses].letters[0] = 0;
    
    return ++(d->numClasses);
}

PRIVATE int add_member(Language *lang, int classnum, const UBYTE *memb)
{
    struct charClass *list = &lang->classList[classnum-1];
    struct classWord *w, **prev;
    
    int len = strlen(memb);
    
    if (len == 1)
    {
        int n = strlen(list->letters);
        
        if (n < MAX_LETTERS-1)
        {
            list->letters[n] = memb[0];
            list->letters[n+1] = 0;
            
            return 1;
        }
    }
    
    
    /* Now, they needed to be added so that the LONGEST
       are first in the list. Ie: we match as much as possible. */
    
    prev = &list->words;
    
    while (w = *prev)
    {
        if (w->length <= len) break;
        prev = &w->next;
    }
    
    w = AllocVec(sizeof (struct classWord) + strlen(memb) + 1, MEMF_ANY);
    
    if (!w)
    {
        yyerror(lang, MSG_NoMemory);
        return 0;
    }
    
    w->next = *prev;
    *prev = w;
    
    strcpy(w->chars+1,memb);
    w->chars[0] = 0;
    w->length = len;
    
    return 1;
}

STATIC const UBYTE staticSeps[] = " .?!:;,()\n\t\\{}";


void free_classes(Language *d)
{
    int n;
    
    for (n = 0; n<d->numClasses; n++)
    {
        struct charClass *list = &d->classList[n];
        struct classWord *word, *next;
        
        FreeVec(list->name);
        
        for (word = list->words; word; word=next)
        {
            next = word->next;
            FreeVec(word);
        }
    }
    
    if (d->classList) FreeVec(d->classList);
    if (d->separators != staticSeps) FreeVec(d->separators);
    
    d->classList = 0;
    d->numClasses = 0;
    d->separators = (UBYTE *)staticSeps;
}

STATIC void free_patterns(Language *d)
{
    int n;
    
    for (n=0; n<27; n++)
    {
        struct Rule *rule, *next;
        
        for (rule = d->Rules[n].head; rule; rule=next)
        {
            next = rule->next;
            FreeVec(rule);
        }
    }
}


PRIVATE void free_accent(Language *d)
{
    free_classes(d);
    free_patterns(d);
    
    FreeVec(d->name);
    FreeVec(d);
}



PRIVATE int change_seps(Language *lang, const UBYTE *s)
{
    UBYTE *p = Strdup(s);
    
    if (!p)
    {
        yyerror(lang, MSG_NoMemory);
        return 0;
    }
    
    if (lang->separators != staticSeps) FreeVec(lang->separators);
    lang->separators = p;
    
    return 1;
}


PRIVATE Language *create_accent(UBYTE *name)
{
    Language *d;
    
    d = AllocVec(sizeof(Language), MEMF_CLEAR);
    if (!d) return 0;
    
    d->name = NamePart(name);
    
    if (!d->name)
    {
        FreeVec(d);
        return 0;
    }
    
    d->refCount = 1;
    
    d->stress.syllable = 1;
    d->stress.level = 4;
    d->complain = 3;
    
    d->separators = (UBYTE *)staticSeps;
    
    return d;
}



STATIC UBYTE *endcopy(UBYTE *dest, const UBYTE *src)
{
    for (;;)
    {
        UBYTE ch = *src++;
        
        if (!ch)
        {
            *dest++ = 0;
            return dest;
        }
        
        *dest++ = ch;
    }
}


PRIVATE int add_word(Language *d, UBYTE *prefix, UBYTE *match,
                                  UBYTE *suffix, UBYTE *phonemes)
{
    struct Rlist *list;
    struct Rule *r;
    UBYTE *p;
    
    if (match[0] == 0)
    {
        yyerror(d, MSG_EmptyMatch);
        return 0;
    }
    
    r = AllocVec(sizeof(struct Rule) + 4
        + strlen(prefix) + strlen(match) + strlen(suffix) + strlen(phonemes),
        MEMF_ANY);
    
    if (!r)
    {
        yyerror(d, MSG_NoMemory);
        return 0;
    }
    
    list = &d->Rules[RULE_LIST(match[0])];
    
    p = r->prefix;
    
    p = endcopy(p, prefix);
    p = endcopy(r->match = p, match);
    p = endcopy(r->suffix = p, suffix);
    
    strcpy(r->phonemes = p, phonemes);
    
    if (list->head) list->tail->next = r; else list->head = r;
    
    list->tail = r;
    r->next = 0;
    
    return 1;
}


// Replaces a language with a disc version.
// Returns 0 on error.

LONG __asm __saveds LoadAccent(register __a0 STRPTR name)
{
    Language *lang;
    
    lang = load_accent(name);
    
    if (lang)
    {
        replace_accent(lang);
        finished_with_accent(lang);
    }
    
    return (lang != 0);
}

