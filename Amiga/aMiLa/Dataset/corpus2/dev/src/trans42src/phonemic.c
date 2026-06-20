#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <proto/dos.h>
#include <proto/utility.h>
#include <proto/exec.h>
#include <proto/locale.h>
#include <libraries/locale.h>

#include <exec/memory.h>

#include "phonemes.h"
#include "messages.h"
#include "stack.h"

#include "accents.c"

// SAS/C strchr has a bug.

char *strchr(const char *dummy_str, int dummy_ch)
{
    /* This fixes a notorious bug with ch above 128 */
    
    const UBYTE *str = (UBYTE *)dummy_str;
    UBYTE ch = (UBYTE)dummy_ch;
    
    for (;;)
    {
        if (*str == 0) return 0;
        if (*str == ch) return (char *)str;
        str++;
    }
}


STATIC UBYTE *match_pattern(charClass *class, UBYTE *text, short dir)
{
    struct classWord *word;
    
    /* Longest first!! */
    
    for (word = class->words; word; word=word->next)
    {
        UBYTE *p = text;
        UBYTE *q = word->chars;
        
        if (dir<0) q += word->length; else q++;
        
        for (;;)
        {
            if (*q == 0)
            {
                return p;
            }
            
            if (*p != *q) break;
            
            p += dir;
            q += dir;
        }
    }
    
    /* Then smallest */
    
    if (strchr(class->letters, text[0]))
    {
        return text + dir;
    }
    
    return 0;
}



STATIC int anymatch(UBYTE *pattern, UBYTE *context, short dir)
        /* pattern; first UBYTE of pattern to match in text */
        /* context; last UBYTE of text to be matched */
{
    UBYTE *pat;
    UBYTE *text;
    
    pat = pattern;
    text = context;
    
    for (;;)
    {
        UBYTE ch = *pat++;
        
        switch (ch)
        {
            case 0:
            return 1;
            
            case '\\':
            {
                ch = *pat++;
                
                if (ch != *text) return 0;
                text += dir;
            }
            break;
            
            case '+':   /* one or more */
            {
                ch = *pat++;
                
                text = match_pattern(get_class(curLang,ch),text,dir);
                if (!text) return 0;
                
                for (;;)
                {
                    UBYTE *p = match_pattern(get_class(curLang,ch),text,dir);
                    if (!p) break;
                    text = p;
                }
            }
            break;
            
            case '*':   /* zero or more */
            {
                ch = *pat++;
                
                for (;;)
                {
                    UBYTE *p = match_pattern(get_class(curLang,ch),text,dir);
                    if (!p) break;
                    text = p;
                }
            }
            break;
            
            case '1':   /* just one */
            {
                ch = *pat++;
                
                text = match_pattern(get_class(curLang,ch),text,dir);
                
                if (!text) return 0;
            }
            break;
            
            case '~':   /* none! */
            {
                ch = *pat++;
                
                if (match_pattern(get_class(curLang,ch),text,dir)) return 0;
            }
            break;
            
            case '$':
            {
                if (!strchr(curLang->separators, *text)) return 0;
                text += dir;
            }
            break;
            
            default:    /* exact match */
            {
                if (ch != *text) return 0;
                text += dir;
            }
            break;
        }
    }
}


STATIC UBYTE *find_rule(void)
{
    UBYTE *buf = src.cur;
    UBYTE *de_acc = buf;
    
    struct Rule *rule;
    
    again:
    
    rule = rule_list(curLang,*buf);
    
    for (; rule; rule=rule->next)   /* Search for the rule */
    {
        UBYTE *match = rule->match;
        UBYTE *end;
        
        for (end=buf; *match; match++, end++)
        {
            if (*end != *match) break;
        }
        
        if (*match) continue;    /* found missmatch */
        
        if (!anymatch(rule->prefix, buf-1, -1)) continue;
        if (!anymatch(rule->suffix, end, 1)) continue;
        
        src.cur = end;
        return rule->phonemes;
    }
    
#if 0 // ndef KS13
    
    if (locale)     /* Try again un-accented */
    {
        UBYTE newbuf[4];
        UBYTE oldbuf[2];
        
        oldbuf[0] = *buf;
        oldbuf[1] = 0;
        
        StrConvert(locale,oldbuf,newbuf,sizeof newbuf-1,SC_COLLATE1);
        
        /* converts "{" -> "a" and "|" -> "b", etc (wierd!!!!) */
        
        if (newbuf[0] && oldbuf[0] != newbuf[0])
        {
            *buf = newbuf[0];
            goto again;
        }
    }
    else
#endif
    
    if ((UBYTE)*de_acc > 128+32)
    {
        int n = (UBYTE)*de_acc;
        int p = unaccented[n - (128+32)];
        
        if (n != p)
        {
            *de_acc++ = p;
            goto again;
        }
    }
    
    src.cur = buf+1; /* Skip it! */
    return "";
}


#define MAX_SYLLABLES 32
#define MAX_RECURSION 32

struct {
    
    UBYTE *space;   // Position of last space in output.
    
    UBYTE *bufPtr;  // Start of output buffer
    UBYTE *bufEnd;  // end of buffer - 2
    
    int syllable;   // Syllable count in output.
    UBYTE *position[MAX_SYLLABLES];     // positions of each syllable.
    
} dest;




int output_phoneme(UBYTE *ph)
{
    UBYTE *buf = dest.bufPtr;
    
    for (;;)
    {
        UBYTE ch = *ph++;
        
        if (!ch)
        {
            dest.bufPtr = buf;
            return 1;
        }
        
        if (buf == dest.bufEnd)
        {
            dest.bufPtr = buf;
            return 0;
        }
        
        if (isdigit(ch))
        {
            *buf++ = ch;
            dest.syllable = MAX_SYLLABLES+1;
        }
        else if (ch == '`')
        {
            dest.syllable = MAX_SYLLABLES+1;
        }
        else if (curLang->stress.syllable && strchr("AEIOU",ch) && *ph && *ph!='X')
        {
            if (dest.syllable < MAX_SYLLABLES)
            {
                dest.position[dest.syllable] = buf;
            }
            
            dest.syllable++;
            
            *buf++ = ch;
            *buf++ = *ph++;
        }
        else if (strchr("# .?),-",ch))
        {
            int mark;
            UBYTE *p;
            
            if (!curLang->stress.syllable ||
                !dest.syllable ||
                dest.syllable > MAX_SYLLABLES)
            {
                goto nostress;
            }
            
            if (curLang->stress.syllable < 0)
            {
                mark = dest.syllable + curLang->stress.syllable;
                if (mark<0) goto nostress;            // mark = 0; ???
            }
            else
            {
                mark = curLang->stress.syllable-1;
                if (mark >= dest.syllable) goto nostress;  // mark = syllable-1; ???
            }
            
            p = dest.position[mark];
            
            if (p+2 == buf)
            {
                *buf++ = '0' + curLang->stress.level;
            }
            else if (!isdigit((UBYTE)p[2]))
            {
                memmove(p+3, p+2, buf-(p+2));
                p[2] = '0' + curLang->stress.level;
                buf++;
            }
            
            nostress:
            
            if (ch != '#') *buf++ = ch;
            
            dest.syllable = 0;
        }
        else
        {
            *buf++ = ch;
        }
    }
}


STATIC LONG to_phonemes(void)
{
    while (src.cur[0])
    {
        UBYTE *ph;
        UBYTE *temp;
        
        if (src.cur[0] == scopeCode[begin_scope])
        {
            src.cur++;
            push_accent(0);
            continue;
        }
        else if (src.cur[0] == scopeCode[end_scope])
        {
            int bool = output_phoneme("#");
            
            src.cur++;
            pop_accent();
            
            if (!bool) goto end;
            continue;
        }
        else if (src.cur[0] == scopeCode[before_name])
        {
            UBYTE *end;
            UBYTE *next;
            
            if (scopeCode[after_name])
            {
                end = strchr(src.cur, scopeCode[after_name]);
                if (end) next = end+1;
            }
#ifndef KS13
            else if (locale)
            {
                end = src.cur+1;
                while (IsAlNum(locale,*end)) end++;
                next = end;
            }
#endif
            else
            {
                end = src.cur+1;
                while (isalnum(*end)) end++;
                next = end;
            }
            
            if (end)
            {
                UBYTE before = *end;
                int bool;
                
                if (*next && *next == scopeCode[begin_scope])
                {
                    push_accent(0);
                    next++;
                }
                
                *end = 0;
                
                bool = output_phoneme("#");
                
                if (!change_accent(src.cur+1))
                {
                    *end = before;
                    break;
                }
                
                *end = before;
                src.cur = next;
                
                if (!bool) goto end;
                continue;
            }
        }
        
        temp = src.cur;
        
        ph = find_rule();
        
        if (ph[0] == '{')
        {
            if (push_accent(1))
            {
                if (is_lowlevel(temp))
                {
                    src.space = temp;
                    dest.space = dest.bufPtr;
                }
                
                src.cur = ph+1;
            }
        }
        else
        {
            if (!output_phoneme(ph))
            {
                end:
                
                if (src.space && src.space != src.base)
                {
                    src.cur = src.space;
                    dest.bufPtr = dest.space;
                }
                else while (!is_lowlevel(src.cur))
                {
                    if (!pop_accent()) break;
                }
                
                *dest.bufPtr = 0;
                
                return src.base - src.cur;
            }
            
            if (strlen(ph) &&
                strchr(" .?-,)", ph[strlen(ph)-1]) &&
                is_lowlevel(src.cur))
            {
                src.space = src.cur;
                dest.space = dest.bufPtr;
            }
        }
    }
    
    *dest.bufPtr = 0;
    
    return 0;
}


LONG __asm __saveds TranslateAs(register __a0 STRPTR inputString,
                                register __d0 LONG inputLen,
                                register __a1 STRPTR outputBuf,
                                register __d1 LONG outputLen,
                                register __a2 STRPTR languageFile)
{
    SetAccent(languageFile);
    return Translate(inputString,inputLen,outputBuf,outputLen);
}

static UBYTE *alloc_input(UBYTE *inputString, LONG inputLen)
{
    UBYTE *tempBuf = AllocVec(inputLen+4, MEMF_ANY);
    
    if (tempBuf)
    {
        /* Preceed text with a NULL and SPACE */
        
        tempBuf[0] = 0;
        tempBuf[1] = ' ';
        
        memcpy(tempBuf+2, inputString, inputLen);
        
        tempBuf[inputLen+2] = ' ';
        tempBuf[inputLen+3] = 0;
        
        /* Terminated text with a SPACE and NULL */
        
        uppercase(tempBuf+2);
    }
    
    return tempBuf;
}


LONG __asm __saveds Translate(register __a0 STRPTR inputString,
                              register __d0 LONG inputLen,
                              register __a1 STRPTR outputBuf,
                              register __d1 LONG outputLen)
{
    UBYTE *tempBuf;
    
    LONG rc = 0;
    
    if (outputLen != 0) outputBuf[0] = 0;
    if (outputLen < 2) return 0;
    
    /* No returns from here... */
    
    dest.bufPtr = outputBuf;
    dest.bufEnd = outputBuf + outputLen - 2;
    dest.syllable = 0;
    dest.space = 0;
    
    if (tempBuf = alloc_input(inputString,inputLen))
    {
        if (current_accent(tempBuf+2))
        {
            rc = to_phonemes();
            clear_lowlevel_refs();
        }
        
        FreeVec(tempBuf);
    }
    
    return rc;
}


/*
**      English to Phoneme translation.
**
**      Rules are made up of four parts:
**      
**              The left context.
**              The text to match.
**              The right context.
**              The phonemes to substitute for the matched text.
**
**      Procedure:
**
**              Seperate each block of letters (apostrophes included) 
**              and add a space on each side.  For each unmatched 
**              letter in the word, look through the rules where the 
**              text to match starts with the letter in the word.  If 
**              the text to match is found and the right and left 
**              context patterns also match, output the phonemes for 
**              that rule and skip to the next unmatched letter.
**
**
**      Special Context Symbols:
**
**              +       One or more of the following class
**              *       Zero or more of the following class
**              1       Exactly one of the following class
**              \       Quoted literal char
**              other   Literal char
**              
**      The first three are followed by a byte 1-255 which corresponds
**      to the class 0-254.
*/
