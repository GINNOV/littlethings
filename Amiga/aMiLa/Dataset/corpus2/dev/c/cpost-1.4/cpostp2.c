/*------------------------------------------------------------------
 * cpostp2.c : pass 2 of cPost
 *------------------------------------------------------------------
 * 12-02-91 originally by Patrick J. Mueller
 * 12-03-92 converted from cBook to cPost
 *------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ctok.h"
#include "cpost.h"

/*------------------------------------------------------------------
 * static buffer
 *------------------------------------------------------------------*/
#define BUFFER_LEN  8000
#define BRACKET_LEN  500

static unsigned char Buffer    [BUFFER_LEN];
static unsigned char FuncBuff  [MAX_IDENT_LEN+1];
static unsigned char CurrFunc  [MAX_IDENT_LEN+1];
static unsigned char BrackInfo [BRACKET_LEN];

/*------------------------------------------------------------------
 * global variables
 *------------------------------------------------------------------*/
static FILE           *oFile;
static PageEject      *pageJ;
static char           *Xchars[256];
static unsigned char   currFont;
static unsigned long   lineNo;
static int             col;

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * write out the buffer, translating as we go
 *------------------------------------------------------------------*/
static void WriteOut(
   unsigned char    *buffer,
   int               len
   )
   {
   int         i;
   char       *xlate;

   /*---------------------------------------------------------------
    * print each character in buffer
    *---------------------------------------------------------------*/
   for (i=0; i<len; i++)
      {
      xlate = Xchars[buffer[i]];

      /*------------------------------------------------------------
       * check for end of line
       *------------------------------------------------------------*/
      if ('\n' == buffer[i])
         {
         lineNo++;

         /*---------------------------------------------------------
          * print end of line info
          *---------------------------------------------------------*/
         fprintf(oFile,")] showLine %s\n",BrackInfo);
         BrackInfo[0] = 0;

         /*---------------------------------------------------------
          * see if there is a new function definition
          *---------------------------------------------------------*/
         if (*CurrFunc)
            {
            fprintf(oFile,"/currFunc (%s) def\n",CurrFunc);
            *CurrFunc = 0;
            }

         /*---------------------------------------------------------
          * write page eject if we need to
          *---------------------------------------------------------*/
         if (info.oBreak && pageJ && (pageJ->lineNo == lineNo))
            {
            if (pageJ->next)
               {
               int lines;

               lines = pageJ->next->lineNo - pageJ->lineNo;
               fprintf(oFile,"%d linesFit\n",lines);

               pageJ = pageJ->next;
               }
            }

         /*---------------------------------------------------------
          * print start of line info
          *---------------------------------------------------------*/
         fprintf(oFile,"[%c (",currFont);

         col = 0;
         }

      /*------------------------------------------------------------
       * plain old character
       *------------------------------------------------------------*/
      else if (NULL == xlate)
         {
         col++;

/*       fwrite(&(buffer[i]),1,1,oFile); */
         fputc(buffer[i],oFile);
         }

      /*------------------------------------------------------------
       * character to translate
       *------------------------------------------------------------*/
      else
         {
         char *bChar;
         char  nBuff[20];

         col++;

         /*---------------------------------------------------------
          * check for bracket character
          *---------------------------------------------------------*/
         bChar = NULL;
         switch(buffer[i])
            {
            case '\x01' : bChar = "u"; break;
            case '\x02' : bChar = "m"; break;
            case '\x03' : bChar = "l"; break;
            }

         if (bChar && (strlen(BrackInfo) < BRACKET_LEN - 30))
            {
            sprintf(nBuff,"%d",col);


            strcat(BrackInfo," ");
            strcat(BrackInfo,nBuff);
            strcat(BrackInfo," ");
            strcat(BrackInfo,bChar);
            strcat(BrackInfo,"B");
            }

         /*---------------------------------------------------------
          * print translation
          *---------------------------------------------------------*/
/*       fwrite(xlate,1,strlen(xlate),oFile); */
         fputs(xlate,oFile);
         }
      }
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * pass 2 - add formatting tags
 *------------------------------------------------------------------*/
int Pass2(
   File     *file,
   Info     *info
   )
   {
   Tok           *next;
   unsigned long  offs;
   unsigned long  len;
   FILE          *iFile;
   int            i;

   /*---------------------------------------------------------------
    * initialize some stuff
    *---------------------------------------------------------------*/
   oFile = info->oFile;

   for (i=0; i<256; i++)
      {
      Xchars[i] = NULL;
      }

   Xchars['(']  = "\\(";    /* ( -> \( */
   Xchars[')']  = "\\)";    /* ) -> \) */
   Xchars['\\'] = "\\\\";   /* \ -> \\ */

   Xchars['\x01'] = " ";
   Xchars['\x02'] = " ";
   Xchars['\x03'] = " ";

   /*---------------------------------------------------------------
    * print status and read file
    *---------------------------------------------------------------*/
   fprintf(stderr,"   Reading file %s\n",file->name);
   cParse(file,info);

   /*---------------------------------------------------------------
    * write header
    *---------------------------------------------------------------*/
   fprintf(info->oFile,"\n%%----------------------------------------------\n");

   if (file->date && file->time && *file->date && *file->time)
      fprintf(info->oFile,"(%s) (%s   %s) startFile\n",file->name,
                          file->date,file->time);
   else
      fprintf(info->oFile,"(%s) () startFile\n",file->name);

   /*---------------------------------------------------------------
    * first line processing
    *---------------------------------------------------------------*/
   CurrFunc[0]  = 0;
   BrackInfo[0] = 0;
   fprintf(oFile,"[n (");

   /*---------------------------------------------------------------
    * open the input file
    *---------------------------------------------------------------*/
   if (file->tempName)
      iFile = fopen(file->tempName,"r");
   else
      iFile = fopen(file->pathName,"r");

   if (!iFile)
      cPostError(1,"error opening file for reading");

   /*---------------------------------------------------------------
    * initialize token processing
    *---------------------------------------------------------------*/
   next     = file->tokList;
   pageJ    = file->breakList;
   offs     = 0;
   lineNo   = 0;
   col      = 0;
   currFont = 'n';

   /*---------------------------------------------------------------
    * loop through tokens
    *---------------------------------------------------------------*/
   while (next)
      {
      /*---------------------------------------------------------
       * read boring stuff up to first token
       *---------------------------------------------------------*/
      if (next->tok.offs != offs)
         {
         /*---------------------------------------------------------
          * read and write it
          *---------------------------------------------------------*/
         len = next->tok.offs - offs;
         while (len > BUFFER_LEN)
            {
            fread(Buffer,1,BUFFER_LEN,iFile);
            WriteOut(Buffer,BUFFER_LEN);
            len -= BUFFER_LEN;
            }

         fread(Buffer,1,(int)len,iFile);
         WriteOut(Buffer,(int)len);

         /*------------------------------------------------------
          * update the pointer
          *------------------------------------------------------*/
         offs = next->tok.offs;
         }

      /*---------------------------------------------------------
       * write the token
       *---------------------------------------------------------*/
      switch (next->extType)
         {
         /*---------------------------------------------------------
          * get it's font character
          *---------------------------------------------------------*/
         case TOKEN_RESER     : currFont = 'k'; break;
         case TOKEN_PREPROC   : currFont = 'p'; break;
         case TOKEN_COMMENT   : currFont = 'c'; break;
         case TOKEN_IDENT     : currFont = 'i'; break;
         case TOKEN_FUNDEF    : currFont = 'd'; break;
         case TOKEN_FUNPRO    : currFont = 'f'; break;
         case TOKEN_FUNUSE    : currFont = 'f'; break;
         default :              currFont = 'n'; break;
         }

      /*------------------------------------------------------------
       * copy function name into buffer for function definitions
       *------------------------------------------------------------*/
      if (TOKEN_FUNDEF == next->extType)
         strcpy(CurrFunc,next->str);

      /*------------------------------------------------------
       * read and write token
       *------------------------------------------------------*/
      if (currFont != 'n')
         fprintf(oFile,") %c (",currFont);

      len = next->tok.len;
      while (len > BUFFER_LEN)
         {
         fread(Buffer,1,(int)BUFFER_LEN,iFile);
         WriteOut(Buffer,(int)BUFFER_LEN);
         len -= BUFFER_LEN;
         }

      fread(Buffer,1,(int)len,iFile);
      WriteOut(Buffer,(int)len);

      if (currFont != 'n')
         fprintf(info->oFile,") n (");

      currFont = 'n';

      /*------------------------------------------------------------
       * prepare for next token
       *------------------------------------------------------------*/
      offs += next->tok.len;
      next = next->next;
      }

   /*---------------------------------------------------------------
    * last line processing
    *---------------------------------------------------------------*/
   fprintf(oFile,")] showLine %s\nendFile",BrackInfo);

   /*---------------------------------------------------------------
    * close file
    *---------------------------------------------------------------*/
   fclose(iFile);

   /*---------------------------------------------------------------
    * free parser storage
    *---------------------------------------------------------------*/
   cParseDone(file,info);

   return 0;
   }

