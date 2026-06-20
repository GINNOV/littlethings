#include <proto/utility.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <exec/memory.h>
#include <dos/dostags.h>
#include <devices/timer.h>

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <dos.h>

#include "phonemes.h"
#include "messages.h"

#define RETZ(p) if (!(p)) return 0



void doserror(Language *lang, UBYTE *filename);


STATIC UBYTE *spaces(UBYTE *buf)
{
    while (isspace(*buf)) buf++;
    return buf;
}


static char expand_escaped_char(char **ptr)
{
    int ch = *(*ptr)++;
    
    switch (ch)
    {
        case 'n':
        return '\n';
        
        case 'r':
        return '\r';
        
        case 't':
        return '\t';
        
        case 'a':
        return '\a';
        
        case 'b':
        return '\b';
        
        case 0:
        (*ptr)--;
        return 0;
        
        default:
        return (char)ch;
    }
}


STATIC UBYTE *word(UBYTE **str)
{
    UBYTE *cmd = spaces(*str);
    UBYTE *end = strchr(cmd,' ');
    
    if (end)
    {
        *end = 0;
        *str = end+1;
        return cmd;
    }
    else
    {
        if (!cmd[0]) return 0;
        *str = cmd+strlen(cmd);
        
        return cmd;
    }
}

/*
 *   dst : must be at least as lonf as buf.
 */


typedef enum
{
    parse_text,
    parse_pattern,
    parse_phonemes
    
} slashType;
    

STATIC UBYTE *parse_line(Language *lang, UBYTE *buf, UBYTE last,
                         slashType slashp,
                         UBYTE *dst, size_t size)
{
    UBYTE *maxdest = dst + size - 2;
    UBYTE started = 0;
    
    for (;;)
    {
        UBYTE ch = *buf++;
        
        if (ch == last && !started)
        {
          done:
            
            *dst = 0;
            if (!ch) buf--;
            return buf;
        }
        
        if (!started && isspace(ch)) /* requires unsigned! */
        {
            continue;
        }
        
        if (dst == maxdest)
        {
          too_long:
            yyerror(lang, MSG_TooLong);
            return 0;
        }
        
        if (ch == 0)
        {
            if (!started && last == ' ') goto done;
            
          unexpected_eol:
            
            yyerror(lang, MSG_EOL);
            return 0;
        }
        
        if (ch == started)
        {
            if (started == '}') *dst++ = ch;
            started = 0;
        }
        else if (!started && ch == '"')
        {
            started = '"';
        }
        else if (!started && ch == '{' && slashp == parse_phonemes)
        {
            *dst++ = ch;
            started = '}';
        }
        else if (ch == '(')
        {
            UBYTE *end;
            UBYTE class;
            
            if (slashp != parse_pattern)
            {
                yyerror(lang, MSG_UnexpectedClass);
                return 0;
            }
            
            end = strchr(buf, ')');
            
            if (!end)
            {
                yyerror(lang, MSG_NoParen);
                return 0;
            }
            
            *end = 0;
            
            if (strchr(SPECIALS, end[-1]))
            {
                *dst++ = end[-1];
                end[-1] = 0;
            }
            else
            {
                *dst++ = '1';
            }
            
            class = find_class(lang,buf);
            
            if (!class)
            {
                yyerror(lang, MSG_ClassUndefined, buf);
                return 0;
            }
            else
            {
                *dst++ = class;
            }
            
            buf = end+1;
        }
        else if (ch == '$' && slashp != parse_phonemes)
        {
            if (slashp != parse_pattern)
            {
                yyerror(lang, MSG_UnexpectedDollar);
                return 0;
            }
            
            *dst++ = '$';
        }
        else if (ch == '\\' && slashp != parse_phonemes)
        {
            ch = expand_escaped_char(&buf);
            if (ch == 0) goto unexpected_eol;
            
            if (slashp == parse_pattern && NEEDS_QUOTING(ch)) *dst++ = '\\';
            *dst++ = ch;
        }
        else
        {
            if (slashp == parse_pattern && NEEDS_QUOTING(ch)) *dst++ = '\\';
            *dst++ = ch;
        }
    }
}





STATIC int command(Language *lang, UBYTE *buf)
{
    UBYTE *cmd = word(&buf);
    
    if (!cmd)
    {
        yyerror(lang, MSG_NoCommand);
        return 0;
    }
    else if (!strcmp(cmd,"stress"))
    {
        cmd = word(&buf);
        
        if (!cmd)
        {
            yyerror(lang, MSG_BadArg);
            return 0;
        }
        
        lang->stress.syllable = atoi(cmd);
        return 1;
    }
    else if (!strcmp(cmd,"emphasis"))
    {
        cmd = word(&buf);
        
        if (!cmd)
        {
            yyerror(lang, MSG_BadArg);
            return 0;
        }
        
        lang->stress.level = atoi(cmd);
        return 1;
    }
    else if (!strcmp(cmd,"complain"))
    {
        int level;
        
        cmd = word(&buf);
        
        if (!cmd)
        {
            err:
            yyerror(lang, MSG_BadArg);
            return 0;
        }
        
        level = atoi(cmd);
        
        if (level<1 || level>3) goto err;
        
        lang->complain = level;
        return 1;
    }
    else if (!strcmp(cmd,"separator"))
    {
        UBYTE seps[64];
        RETZ (buf = parse_line(lang, buf, ' ', parse_text, seps, sizeof seps));
        return change_seps(lang,seps);
    }
    else if (!strcmp(cmd,"class"))
    {
        int class;
        
        cmd = word(&buf);
        
        if (!cmd)
        {
            yyerror(lang, MSG_BadArg);
            return 0;
        }
        
        if (find_class(lang,cmd))
        {
            yyerror(lang, MSG_ClassAlready, cmd);
            return 0;
        }
        
        RETZ (class = add_class(lang,cmd));
        
        for (;;)
        {
            UBYTE member[32];
            
            buf = spaces(buf);
            if (*buf == 0) break;
            
            RETZ (buf = parse_line(lang, buf, ' ', parse_text, member, sizeof member));
            
            uppercase(member);
            
            RETZ (add_member(lang, class, member));
        }
        
        return 1;
    }
    else
    {
        yyerror(lang, MSG_UnknownCommand, cmd);
        return 0;
    }
}

/*
    (class+)
    (class*)
    (class)
    "quoted"
    \q
    abc
    <spaces ignored>

`Compiled' to:

'+'     '1-255 class'
'~'     '1-255 class'
'*'     '1-255 class'
'1'     '1-255 class'
'\'     <quoted-literal-char>
' '     <start of word (space) >
<any>   <literal-char>

*/

STATIC void upperpat(UBYTE *p)
{
    for (;;)
    {
        UBYTE ch = p[0];
        
        if (!ch) break;
        
        if (NEEDS_SKIPING(ch)) p++;
        else
        {
            p[0] = ToUpper(ch);
        }
        
        p++;
    }
}



STATIC void reverse(UBYTE *buf)
{
    int n = strlen(buf);
    
    UBYTE *a = buf;
    UBYTE *b = buf + n - 1;
    
    while (a<b)
    {
        UBYTE tmp = *a;
        
        *a = *b;
        *b = tmp;
        
        a++;
        b--;
    }
    
    a = buf + n - 1;
    
    while (a>buf)
    {
        UBYTE ch = *a--;
        
        if (NEEDS_SKIPING(ch))
        {
            a[1] = a[0];
            a[0] = ch;
            
            a--;
        }
    }
}


STATIC int check_phonemes(Language *lang, UBYTE *ph)
{
    int vowel = 0;
    
    for (;;)
    {
        UBYTE ch = *ph++;
        
        if (!ch) break;
        
        if (isdigit(ch))
        {
            if (!vowel) goto error;
            vowel = 0;
        }
        else
        {
            vowel = 0;
            
            if (!strchr("MFVBKLYJPG().,?-`# ", ch))
            {
                switch (ch)
                {
                    case 'S':
                    case 'T':
                    case 'Z':
                    case 'W':
                    if (*ph == 'H') ph++;
                    break;
                    
                    case 'D':
                    if (*ph == 'H') ph++;
                    else if (*ph == 'X') ph++;
                    break;
                    
                    case 'N':
                    case 'Q':
                    case 'R':       // RX is not documented!
                    case 'L':       // LX is not documented!
                    if (*ph == 'X') ph++;
                    break;
                    
                    case '/':
                    if (*ph != 'H' && *ph != 'C') goto error;
                    ph++;
                    break;
                    
                    default:
                    
                    if (!*ph)
                    {
                        error:
                        yyerror(lang, MSG_Illegal, ph-1);
                        return 0;
                    }
                    else
                    {
                        UBYTE chs[3];
                        static const UBYTE ps[] =
                            "CHIYEHAAAOERAXIHAEAHUHOHIXEYOYOWAYAWUWULILUMIMUNIN";
                            UBYTE *p;
                        
                        chs[0] = ch;
                        chs[1] = *ph;
                        chs[2] = 0;
                        
                        p = strstr(ps, chs);
                        if (!p || ((p-ps)&1)) goto error;
                        
                        if (strchr("AEIOU", ch)) vowel = 1;
                        ph++;
                    }
                }
            }
        }
    }
    
    return 1;
}

STATIC int rule(Language *lang, UBYTE *buf)
{
    UBYTE prefix[64];
    UBYTE suffix[64];
    
    UBYTE match[64];
    UBYTE phonemes[64];
    
    RETZ (buf = parse_line(lang, buf, '[', parse_pattern, prefix, sizeof prefix));
    RETZ (buf = parse_line(lang, buf, ']', parse_text, match, sizeof match));
    RETZ (buf = parse_line(lang, buf, '=', parse_pattern, suffix, sizeof suffix));
    RETZ (buf = parse_line(lang, buf, 0,   parse_phonemes, phonemes, sizeof phonemes));
    
    upperpat(prefix);
    uppercase(match);
    upperpat(suffix);
    reverse(prefix);
    
    if (phonemes[0] == '{')
    {
        if (phonemes[strlen(phonemes)-1] != '}')
        {
            yyerror(lang,MSG_BadRecurse);
            return 0;
        }
        
        uppercase(phonemes);
    }
    else
    {
        if (lang->complain != 1 &&
            !check_phonemes(lang,phonemes))
        {
            if (lang->complain == 3) return 0;
        }
    }
    
    RETZ (add_word(lang, prefix, match, suffix, phonemes));
    
    return 1;
}

STATIC int process_line(Language *lang, UBYTE *buffer)
{
    UBYTE *buf = spaces(buffer);
    UBYTE ch = buf[0];
    
    lang->linenum++;
    
    if (ch == '%')
    {
        if (!command(lang,buf+1)) return 0;
    }
    else if (ch != '#' && ch != 0)
    {
        if (!rule(lang,buf)) return 0;
    }
    
    return 1;
}


STATIC int input_rules(Language *lang, BPTR in, UBYTE *filename)
{
    int rc = 0;
    int length = -1;
    
#ifndef KS13
    struct FileInfoBlock *fib;
    
    fib = AllocVec(sizeof(struct FileInfoBlock), MEMF_CLEAR);
    
    if (!fib)
    {
        yyerror(0, MSG_NoMemory);
    }
    else
    {
        if (!ExamineFH(in, fib))
        {
            doserror(0,filename);
        }
        else
        {
            length = fib->fib_Size;
        }
        
        FreeVec(fib);
    }
    
#else
    
    Seek(in,0,OFFSET_END);
    length = Seek(in,0,OFFSET_BEGINNING);
    
#endif
    
    if (length >= 0)
    {
        UBYTE *mem = AllocVec(length+1, MEMF_ANY);
        
        lang->linenum = 0;
    
        if (!mem)
        {
            yyerror(lang, MSG_NoMemory);
        }
        else
        {
            if (Read(in, mem, length) != length)
            {
                doserror(lang, filename);
            }
            else
            {
                UBYTE *p, *next;
                
                rc = 1;
                
                mem[length] = 0;
                p = mem;
                
                for (;;)
                {
                    for (next = p; *next && *next != '\n'; next++);
                    
                    if (*next) *next = 0; else next = 0;
                    
                    if (!process_line(lang,p))
                    {
                        rc = 0;
                        break;
                    }
                    
                    if (!next) break;
                    p=next+1;
                }
                
                lang->linenum = -1;
            }
            
            FreeVec(mem);
        }
    }
    
    return rc;
}


#ifndef KS13

INTERN void read_process(void);

STATIC Language *task_load_accent(UBYTE *name)
{
    struct Process *proc = 0;
    Language *lang = 0;
    
    BYTE signum = AllocSignal(-1);
    
    if (signum != -1)
    {
        int len = strlen(name) + 1 + 16 + 1 + 16 + 1;
        UBYTE *args = AllocVec(len, MEMF_ANY);
        
        if (args)
        {
            ULONG signal = 1 << signum;
            
            SPrintf(args, len, "%lx %lx %s", FindTask(0), signal, name);
            
            proc = CreateNewProcTags(
                NP_Entry,       read_process,
                NP_StackSize,   4000,
                NP_Name,        args,
            TAG_DONE);
            
            if (proc)
            {
                Wait(signal);
                lang = just_find_accent(name);
            }
            
            FreeVec(args);
        }
        
        FreeSignal(signum);
    }
    
    if (!proc) yyerror(0, MSG_NotLoaded, name);
    
    return lang;
}

#endif

Language *load_accent(STRPTR name)
{
    BPTR in=0;
    Language *lang=0;
    
    if (FindTask(0)->tc_Node.ln_Type != NT_PROCESS)
    {
#ifdef KS13
        yyerror(0, MSG_NotLoaded, name);
        return 0;
#else
        return task_load_accent(name);
#endif
    }
    
    /* called by a process... */
    
    if (stpbrk(name,".:/")) in = Open(name, MODE_OLDFILE);
    
    if (!in)
    {
        UBYTE *ptr = MyFilePart(name);
        
        int len = strlen(ptr) + strlen(speechPath) + strlen(speechExt) + 2;
        UBYTE *mem = AllocVec(len, MEMF_ANY);
        
        if (mem)
        {
            strcpy(mem,speechPath);
            
            if (AddPart(mem, ptr, len))
            {
                if (!suffix(mem, speechExt)) strcat(mem, speechExt);
                in = Open(mem, MODE_OLDFILE);
            }
            
            FreeVec(mem);
        }
    }
    
    if (!in)
    {
        doserror(0,name);
    }
    else
    {
        lang = create_accent(name);
        
        if (lang)
        {
            if (!input_rules(lang,in,name))
            {
                free_accent(lang);
                lang = 0;
            }
            
            Close(in);
        }
    }
    
    return lang;
}

