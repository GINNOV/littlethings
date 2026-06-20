#include <proto/intuition.h>
#include <intuition/intuition.h>
#include <exec/alerts.h>
#include <exec/memory.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <graphics/text.h>
#include <graphics/gfxbase.h>
#include <string.h>

#include "phonemes.h"
#include "messages.h"

struct sprintfInfo
{
    UBYTE *ptr;
    UBYTE *last;
};

static __asm void stuffChar(register __d0 UBYTE ch,
                            register __a3 struct sprintfInfo *info)
{
    if (info->ptr == info->last)
    {
        *info->ptr = 0;
    }
    else
    {
        *info->ptr++ = ch;
    }
}

static void SPrintfArgs(UBYTE *buffer, LONG length,
                        const UBYTE *format, APTR args)
{
    if (length)
    {
        struct sprintfInfo info;
        
        info.ptr = buffer;
        info.last = buffer + length-1;
        
        RawDoFmt((UBYTE *)format, args, stuffChar, &info);
    }
}

void SPrintf(UBYTE *buffer, LONG length, const UBYTE *format, ...)
{
    SPrintfArgs(buffer,length,format,(APTR)(&format + 1));
}



/* use AutoRequest to implement MyEasyRequest */

#ifdef KS13

#define LEFTEDGE 16

static struct IntuiText *split_lines(UBYTE *text,
    ULONG *width, ULONG *height, struct TextFont *font)
{
    struct IntuiText *list=0, *tail=0;
    ULONG wd = *width;
    ULONG y = *height;
    
    for (;;)
    {
        struct IntuiText *it = AllocVec(sizeof(struct IntuiText), MEMF_ANY);
        
        if (!it) break;
        
        it->FrontPen  = 0;
        it->BackPen = 1;
        it->DrawMode = JAM2;
        it->LeftEdge = LEFTEDGE;
        it->TopEdge = y;
        it->ITextFont = NULL;
        it->IText = text;
        it->NextText = NULL;
        
        if (list) tail->NextText = it; else list = it;
        tail = it;
        
        y += font->tf_YSize;
        
        {
            UBYTE *next = strchr(text,'\n');
            ULONG len;
            
            if (next) *next = 0;
            
            len = strlen(text) * font->tf_XSize;
            if (len > wd) wd = len;
            
            if (!next) break;
            text = next+1;
        }
    }
    
    *width = wd;
    *height = y;
    
    return list;
}

static void free_lines(struct IntuiText *it)
{
    while (it)
    {
        struct IntuiText *next = it->NextText;
        FreeVec(it);
        it = next;
    }
}

#define EasyRequestArgs MyEasyRequestArgs


static LONG MyEasyRequestArgs(struct Window *win, struct EasyStruct *es,
                              ULONG *idcmpPtr, APTR args)
{
    ULONG posflags = 0;
    
    UBYTE *bodytext;
    UBYTE *postext;
    UBYTE *negtext;
    struct TextFont *font;
    
    ULONG width,height;
    
    BOOL rc = 0;
    
    struct IntuiText ipos, ineg, *ibody;
    
    if (!win || !(font = win->IFont))
    {
        font = GfxBase->DefaultFont;
        if (!font) Alert(0);
    }
    
    if (idcmpPtr) posflags = *idcmpPtr;
    
    bodytext = AllocVec(256, MEMF_ANY);
    
    if (bodytext)
    {
        SPrintfArgs(bodytext, 256, es->es_TextFormat, args);
        
        postext = Strdup(es->es_GadgetFormat);
        
        if (postext)
        {
            negtext = strchr(postext, '|');
            
            ipos.FrontPen  = AUTOFRONTPEN;
            ipos.BackPen = AUTOBACKPEN;
            ipos.DrawMode = AUTODRAWMODE;
            ipos.LeftEdge = AUTOLEFTEDGE;
            ipos.TopEdge = AUTOTOPEDGE;
            ipos.ITextFont = AUTOITEXTFONT;
            ipos.IText = postext;
            ipos.NextText = AUTONEXTTEXT;
            
            if (negtext)
            {
                *negtext = 0;
                ineg = ipos;
                ineg.IText = negtext + 1;
            }
            
            height = 5;
            width = 0;
            
            ibody = split_lines(bodytext, &width, &height, font);
            
            height += 36;
            width += (LEFTEDGE*2) + 20; /* for right border */
            
            rc = AutoRequest(win, ibody,
                             negtext ? &ipos : 0,
                             negtext ? &ineg : &ipos,
                posflags, 0, width, height);
            
            free_lines(ibody);
            FreeVec(postext);
        }
        
        FreeVec(bodytext);
    }
    
    return rc;
}

#endif



static const UBYTE copyright[] = {
#include "_copyright.h"
};

PRIVATE void yyerror(Language *lang, int catnum, ...)
{
    UBYTE *fmt = getmsg(catnum);
    
    APTR args = (APTR)(&catnum + 1);
    UBYTE *buffer;
    
    UBYTE *message = getmsg(MSG_ErrLine);
    int length = 16 + strlen(fmt);
    
    if (lang) length += strlen(message) + strlen(lang->name);
    
    buffer = AllocVec(length + sizeof(copyright), MEMF_ANY);
    
    if (buffer)
    {
        struct EasyStruct es = { sizeof(struct EasyStruct), 0 };
        
        UBYTE *p = (UBYTE *)copyright;
        UBYTE *q = buffer;
        
        for (;;)
        {
            UBYTE ch = *p++;
            
            ch ^= 128+16;
            if (!ch) break;
            
            *q++ = ch;
        }
        
        *q = 0;
        
        if (lang) SPrintf(q, length, message, lang->linenum, lang->name);
        strcat(q, fmt);
        
        es.es_Title = "Translator";
        es.es_TextFormat = buffer;
        es.es_GadgetFormat = getmsg(MSG_OK);
        
        EasyRequestArgs(0, &es, 0, args);
        FreeVec(buffer);
    }
    else
    {
        Alert(AT_Recovery | AG_NoMemory | AO_Unknown | AN_Unknown);
    }
}


void doserror(Language *lang, UBYTE *filename)
{
#ifndef KS13
    UBYTE *buffer = AllocVec(80, MEMF_ANY);
    
    if (buffer)
    {
        Fault(IoErr(), filename, buffer, 80);
        yyerror(lang, MSG_String, buffer);
        FreeVec(buffer);
    }
    else
#endif
    {
        yyerror(lang, MSG_FileError, filename);
    }
}




#if 0
PRIVATE void printf_yyerror(Language *lang, int catnum, ...)
{
    UBYTE *fmt = getmsg(catnum);
    
    APTR args = (APTR)(&catnum + 1);
    UBYTE *buffer = 0;
    
    {
        UBYTE *message = getmsg(MSG_ErrLine);
        int length = 16 + strlen(fmt);
        
        if (lang) length += strlen(message) + strlen(lang->name);
        
        buffer = AllocVec(length + sizeof(copyright), MEMF_ANY);
        
        if (buffer)
        {
            UBYTE *p = (UBYTE *)copyright;
            UBYTE *q = buffer;
            
            for (;;)
            {
                UBYTE ch = *p++;
                
                ch ^= 128+16;
                if (!ch) break;
                
                *q++ = ch;
            }
            
            *q = 0;
            
            if (lang) SPrintf(q, length, message, lang->linenum, lang->name);
            strcat(q, fmt);
        }
    }
    
    if (!buffer) buffer = (UBYTE *)fmt;
    
    {
        BPTR out;
        struct Task *me = FindTask(0);
        
        if (me->tc_Node.ln_Type != NT_PROCESS) goto easyreq;
        
        if (out = Output() && IsInteractive(out))
        {
            out = Open("CONSOLE:", MODE_NEWFILE);
            
            if (!out) gotoeasyreq;
            
            if (!IsInteractive(out))
            {
                Close(out);
                goto easyreq;
            }
            
            VFPrintf(out, buffer, args);
            FPrintf(out,"\n");
            Close(out);
        }
    }
    
    if (buffer != fmt) FreeVec(buffer);
}

#endif
