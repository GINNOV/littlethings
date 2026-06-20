#ifndef cpp_phonemes_h
#define cpp_phonemes_h

#ifndef STRUCT
#define STRUCT(x) typedef struct x x; struct x
#endif

#include <exec/nodes.h>
#include <exec/types.h>

extern UBYTE scopeCode[4];

/*
 * Global list of languages:
 * Forbid() while adding/removing item.
 *
 * This is the ONLY global structure
 * Actually there is other globals stuff.
 * Eventually this will be global for all open instances
 * of the library, as against other values for each instance.
 */

/** ---------------- *** ---------------- **/


#define MAX_LETTERS 23

// READ ONLY Language and sub-parts, except when creating...

STRUCT (Rlist)
{
    struct Rule *head;
    struct Rule *tail;
};

enum {
    
    begin_scope,      // '{'
    end_scope,        // '}'
    before_name,      // '\'
    after_name        // ' '
};


STRUCT (Language)
{
    struct MinNode node;
    
    UBYTE *name;
    
    int linenum;
    int refCount;   // Delete if it reaches 0
    
    struct Rlist Rules[27];
    
    struct charClass *classList;
    
    struct
    {
        char syllable;
        char level;
        
    } stress;
    
    UBYTE maxClasses;
    UBYTE numClasses;
    UBYTE complain;
    
    /* 1 = don't check phonemes
       2 = warn on all bad phonemes
       3 = error on bad phonemes
       
       */
    
    
    UBYTE *separators;
};

STRUCT (Rule)
{
    struct Rule *next;
    
    UBYTE *match;
    UBYTE *suffix;
    UBYTE *phonemes;
    UBYTE prefix[0];
};

STRUCT (classWord)
{
    struct classWord *next;
    UBYTE length;
    UBYTE chars[1];
};

STRUCT (charClass)
{
    UBYTE *name;
    UBYTE letters[MAX_LETTERS+1];
    struct classWord *words;
};


PRIVATE int find_class(Language *, const UBYTE *);
PRIVATE int add_class(Language *, const UBYTE *);
PRIVATE int add_member(Language *, int class, const UBYTE *member);

PRIVATE int add_word(Language *, UBYTE *prefix, UBYTE *match,
                                 UBYTE *suffix, UBYTE *phonemes);

PRIVATE int change_seps(Language *, const UBYTE *);


#define RULE_LIST(ch) (isalpha(ch) ? tolower(ch)-'a'+1 : 0)
#define rule_list(d,ch) d->Rules[RULE_LIST(ch)].head
#define get_class(d,ch) &d->classList[((UBYTE)ch)-1]


/* Accents */

PRIVATE Language *load_accent(STRPTR name);
PRIVATE Language *find_or_load_accent(STRPTR name);
PRIVATE Language *just_find_accent(UBYTE *);

PRIVATE void replace_accent(Language *dialect);
PRIVATE void finished_with_accent(Language *);

PRIVATE Language *create_accent(UBYTE *);
PRIVATE void free_accent(Language *);

PRIVATE Language *find_any_accent(void);
PRIVATE Language *copy_accent(Language *);

/**/


PRIVATE int suffix(const char *str, const char *suf);
PRIVATE UBYTE *Strdup(const UBYTE *);
PRIVATE UBYTE *NamePart(UBYTE *path);
PRIVATE UBYTE *MyFilePart(UBYTE *path);

PRIVATE void uppercase(UBYTE *);


/* Error handling */

PRIVATE void yyerror(Language *, int, ...);

/* Library entry points */

LONG __asm __saveds
TranslateAs(register __a0 STRPTR inputString,
            register __d0 LONG inputLen,
            register __a1 STRPTR outputBuf,
            register __d1 LONG outputLen,
            register __a2 STRPTR language);

LONG __asm __saveds
Translate(register __a0 STRPTR inputString,
          register __d0 LONG inputLen,
          register __a1 STRPTR outputBuf,
          register __d1 LONG outputLen);

LONG __asm __saveds LoadAccent(register __a0 STRPTR);
LONG __asm __saveds SetAccent(register __a0 STRPTR);

void SPrintf(UBYTE *buffer, LONG length, const UBYTE *format, ...);

PRIVATE void free_classes(Language *d);

/*********************/

INTERN __far UBYTE speechPath[];
INTERN __far UBYTE speechExt[];

INTERN struct Locale *locale;
INTERN struct Catalog *catalog;

#define SPECIALS "~+*"

#define NEEDS_QUOTING(ch) strchr(SPECIALS "$1\\", ch)
#define NEEDS_SKIPING(ch) strchr(SPECIALS "1\\", ch)

#ifdef MWDEBUG
#include <memwatch.h>
#endif

#ifdef KS13

APTR MyAllocVec(unsigned long byteSize, unsigned long requirements);
void MyFreeVec(APTR memoryBlock);
BOOL MyAddPart( STRPTR dirname, STRPTR filename, unsigned long size );
LONG MyGetVar(STRPTR name, STRPTR buffer, long size, long flags);

#ifndef MWDEBUG

#define AllocVec(x,y)   MyAllocVec(x,y)
#define FreeVec(x)      MyFreeVec(x)

#endif

#define AddPart(a,b,c)  MyAddPart(a,b,c)
#define GetVar(a,b,c,d) MyGetVar(a,b,c,d)

#define Stricmp(x,y)    stricmp(x,y)
#define ToUpper(x)      toupper(x)

#endif /* !KS13 */

#endif /* !cpp_phonemes_h */
