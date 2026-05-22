/*------------------------------------------------------------------
 * cpostp1.c : Pass 1 of cPost
 *------------------------------------------------------------------
 * 12-02-91 originally by Patrick J. Mueller
 * 12-03-92 converted from cBook to cPost
 *------------------------------------------------------------------*/

#ifdef AMIGA
#define USE_BUILTIN_MATH
#endif /* AMIGA */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ctok.h"
#include "cpost.h"

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add bracketing starts in front of braces
 *------------------------------------------------------------------*/
static void AddLBracket(
   File *file,
   char *line,
   char *mask,
   int  *maxMask,
   Tok  *tok
   )
   {
   int  lIndent;
   int  rIndent;
   int  place;
   Tok *sib;

   /*---------------------------------------------------------------
    * see if matching bracket is on this line - if so, skip
    *---------------------------------------------------------------*/
   sib = tok->sib;
   if (sib && (sib->tok.line == tok->tok.line))
      return;

   /*---------------------------------------------------------------
    * find minimum indent of left and right brace
    *---------------------------------------------------------------*/
   lIndent = strspn(line," ");
   if (!tok->sib)
      place = lIndent;
   else
      {
      rIndent = strspn(file->line[sib->tok.line-1]," ");
      place = min(lIndent,rIndent);
      }

   /*---------------------------------------------------------------
    * if no indentation on { or }, don't bracket!
    *---------------------------------------------------------------*/
   if (!place)
      return;

   /*---------------------------------------------------------------
    * we'll bracket the column BEFORE this
    *---------------------------------------------------------------*/
   place--;

   /*---------------------------------------------------------------
    * set the mask, maxMask, and write bracket to line
    *---------------------------------------------------------------*/
   mask[place]++;
   *maxMask = max(place,*maxMask);

   if (' ' == line[place])
      line[place] = '\x01';
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add bracketing ends
 *------------------------------------------------------------------*/
static void AddRBracket(
   File *file,
   char *line,
   char *mask,
   int  *maxMask,
   Tok  *tok
   )
   {
   Tok *sib;

   /*---------------------------------------------------------------
    * see if matching bracket is on this line - if so, skip
    *---------------------------------------------------------------*/
   sib = tok->sib;
   if (sib && (sib->tok.line == tok->tok.line))
      return;

   /*---------------------------------------------------------------
    * safety valve
    *---------------------------------------------------------------*/
   if (-1 == *maxMask)
      return;

   /*---------------------------------------------------------
    * add end bracket to line
    *---------------------------------------------------------*/
   if (' ' == line[*maxMask])
      line[*maxMask] = '\x03';

   /*---------------------------------------------------------
    * reset mask and maxMask
    *---------------------------------------------------------*/
   mask[*maxMask]--;
   if (!mask[*maxMask])
      {
      *maxMask -= 1;
      while (-1 != *maxMask)
         if (mask[*maxMask])
            break;
         else
            *maxMask -= 1;
      }
   }


/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add bracketing chars to line based on mask
 *------------------------------------------------------------------*/
static char *AddMBrackets(
   File *file,
   char *line,
   char *mask,
   int   maxMask
   )
   {
   int   i;

   /*------------------------------------------------------------
    * see if we need to make the line longer
    *------------------------------------------------------------*/
   if (maxMask + 1 >= (int) strlen(line))
      {
      char *newLine;

      newLine = malloc(maxMask+3);
      if (!newLine)
         cPostError(1,"out of memory!!!");

      if ('\n' == line[strlen(line)-1])
         line[strlen(line)-1] = ' ';

      memset(newLine,' ',maxMask+1);
      newLine[maxMask+1] = '\n';
      newLine[maxMask+2] = 0;
      memcpy(newLine,line,strlen(line));

      free(line);
      line = newLine;
      }

   /*---------------------------------------------------------------
    * get number of first non-blank column
    *---------------------------------------------------------------*/
   maxMask = min(maxMask,(int)strspn(line," "));

   /*---------------------------------------------------------------
    * for each non-zero entry in mask, write bracket
    *---------------------------------------------------------------*/
   for (i=0; i<=maxMask; i++)
      {
      if (mask[i])
         if (' ' == line[i])
            line[i] = '\02';
      }

   return line;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * strip trailing blanks off a line (that has a \n at the end!!)
 *------------------------------------------------------------------*/
static void StripTrailingBlanks(
   char *line
   )
   {
   int slen;

   slen = strlen(line);
   if ('\n' != line[slen-1])
      {
      fprintf(stderr,"line found without carriage return!!\n");
      return;
      }

   line[slen-1] = ' ';

   while (*line && (' ' == line[slen-1]))
      {
      line[slen-1] = '\0';
      slen--;
      }

   line[slen] = '\n';
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add function information to trees and lists
 *------------------------------------------------------------------*/
static void AddFunctionPrototype(
   Info          *info,
   File          *file,
   char          *name
   )
   {
   Function *func;

   func = GetFunction(info,name);

   if (!ListFind(file->funcProList,&func))
      if (!ListAdd(file->funcProList,&func))
         cPostError(1,"error adding function prototype to list");
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add function information to trees and lists
 *------------------------------------------------------------------*/
static void AddFunctionDefinition(
   Info          *info,
   File          *file,
   char          *name,
   unsigned long  lineNo
   )
   {
   Function *func;

   func = GetFunction(info,name);
   if (!ListFind(file->funcDefList,&func))
      if (!ListAdd(file->funcDefList,&func))
         cPostError(1,"error adding function definition to list");

   func->fileName = file->name;
   func->lineNo   = lineNo;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add function information to trees and lists
 *------------------------------------------------------------------*/
static void AddFunctionUsage(
   Info          *info,
   char          *calleeName,
   char          *callerName
   )
   {
   Function *caller;
   Function *callee;

   callee = GetFunction(info,calleeName);
   caller = GetFunction(info,callerName);

   if (!ListFind(caller->callsList,   &callee))
      if (!ListAdd(caller->callsList,   &callee))
         cPostError(1,"error adding function callee to list");

   if (!ListFind(callee->calledByList,&caller))
      if (!ListAdd(callee->calledByList,&caller))
         cPostError(1,"error adding function caller to list");
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 *
 *------------------------------------------------------------------*/
PageEject *addPageEject(
   File      *file,
   Tok       *tok,
   PageEject *pageJ
   )
   {
   PageEject     *new;
   unsigned long  lineNo;
   char          *line;

   /*---------------------------------------------------------------
    * get space for new node
    *---------------------------------------------------------------*/
   new = malloc(sizeof(PageEject));
   if (!new)
      cPostError(1,"out of memory!!!");

   /*---------------------------------------------------------------
    * link into list
    *---------------------------------------------------------------*/
   if (!pageJ)
      file->breakList = new;
   else
      pageJ->next     = new;

   new->next   = NULL;
   new->lineNo = file->lines;

   /*---------------------------------------------------------------
    * find first non blank line after token
    *---------------------------------------------------------------*/
   lineNo = tok->tok.line;
   if (lineNo >= file->lines)
      return new;

   line = file->line[lineNo];
   while (strspn(line," \n") == strlen(line))
      {
      lineNo++;
      if (lineNo >= file->lines)
         return new;

      line = file->line[lineNo];
      }

   new->lineNo = lineNo;
   return new;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * pass 1 of cPost
 *  - expand tabs, put bracketing around braces, write output files
 *------------------------------------------------------------------*/
int Pass1(
   File     *file,
   Info     *info
   )
   {
   Tok            *next;
   Tok            *def;
   char           *mask;
   char           *this;
   int             lineNo;
   int             i;
   FILE           *tempFile;
   Tok            *stack;
   Tok            *temp;
   int             maxMask;
   int             brackLvl;
   Tok            *lastSemi;
   int             doLastSemi;
   int             inFunc;
   PageEject      *pageJ;

   /*---------------------------------------------------------------
    * print status
    *---------------------------------------------------------------*/
   fprintf(stderr,"   Reading file %s\n",file->name);

   /*---------------------------------------------------------------
    * parse the file
    *---------------------------------------------------------------*/
   info->indent1 = 1;

   cParse(file,info);

   info->indent1 = 0;

   /*---------------------------------------------------------------
    * go down list, adding function information to function tree,
    * and computing bracket information
    *---------------------------------------------------------------*/
   next       = file->tokList;
   def        = NULL;
   stack      = NULL;
   lastSemi   = NULL;
   pageJ      = NULL;
   brackLvl   = 0;
   inFunc     = 0;
   doLastSemi = 1;

   while (next)
      {
      switch(next->extType)
         {
         /*---------------------------------------------------------
          * function stuff
          *---------------------------------------------------------*/
         case TOKEN_FUNPRO:
            AddFunctionPrototype(info,file,next->str);
            break;

         case TOKEN_FUNDEF:
            def = next;
            AddFunctionDefinition(info,file,next->str,next->tok.line);
            inFunc = 1;

            if (doLastSemi && lastSemi)
               {
               pageJ = addPageEject(file,lastSemi,pageJ);

               lastSemi   = NULL;
               doLastSemi = 0;
               }

            break;

         case TOKEN_FUNUSE:
            AddFunctionUsage(info,next->str,def ? def->str : "");
            break;

         /*---------------------------------------------------------
          * semicolons for page breaks
          *---------------------------------------------------------*/
         case TOKEN_SCOLON:
         case TOKEN_PREPROC:
            if (doLastSemi)
               lastSemi = next;
            break;

         /*---------------------------------------------------------
          * bracket stuff
          *---------------------------------------------------------*/
         case TOKEN_LBRACE:
            brackLvl++;
            next->sib   = NULL;
            next->flags = 0;

            /*---------------------------------------------------
             * put { on the stack
             *---------------------------------------------------*/
            next->sib   = stack;
            stack       = next;
            next->flags = 1;

            break;

         case TOKEN_RBRACE:
            next->sib   = NULL;
            next->flags = 0;

               next->extType = TOKEN_RBRACE;

            /*---------------------------------------------------
             * remove { from stack, point { to } and } to {
             *---------------------------------------------------*/
            if (!stack)
               fprintf(stderr,"unmatched } on line %ld\n",next->tok.line);
            else
               {
               temp = stack;
               stack = stack->sib;

               temp->sib   = next;
               next->sib   = temp;
               next->flags = 1;
               }

            if (brackLvl > 0)
               brackLvl--;

            /*------------------------------------------------------
             * add conditional break, if it's time
             *------------------------------------------------------*/
            if (inFunc && !brackLvl)
               {
               pageJ = addPageEject(file,next,pageJ);

               doLastSemi = 0;
               }

            break;
         }

      next = next->next;
      }

   /*---------------------------------------------------------------
    * check for extra { on the stack
    *---------------------------------------------------------------*/
   while (stack)
      {
      fprintf(stderr,"unmatched { on line %ld\n",stack->tok.line);
      stack = stack->sib;
      }

   /*---------------------------------------------------------------
    * now, let's add the bracketing characters
    *---------------------------------------------------------------*/

   /*---------------------------------------------------------------
    * initialize mask
    *---------------------------------------------------------------*/
   mask = malloc(file->maxLineLen+1);
   if (!mask)
      cPostError(1,"out of memory!!!");

   memset(mask,0,file->maxLineLen+1);

   /*---------------------------------------------------------------
    * process each line
    *---------------------------------------------------------------*/
   next    = file->tokList;
   maxMask = -1;
   for (lineNo=0; lineNo < (int)file->lines; lineNo++)
      {
      this = file->line[lineNo];

      /*------------------------------------------------------------
       * go to next token in this line
       *------------------------------------------------------------*/
      while (next && (next->tok.line <  (unsigned long)(lineNo + 1)))
         next = next->next;

      /*------------------------------------------------------------
       * add beginning and ending brackets
       *------------------------------------------------------------*/
      if (info->oBrack)
         {
         while (next && (next->tok.line == (unsigned long)(lineNo + 1)))
            {
            if      ((TOKEN_LBRACE == next->extType) && (next->flags))
               AddLBracket(file,this,mask,&maxMask,next);

            else if ((TOKEN_RBRACE == next->extType) && (next->flags))
               AddRBracket(file,this,mask,&maxMask,next);

            next = next->next;
            }
         }

      /*------------------------------------------------------------
       * add middle brackets
       *------------------------------------------------------------*/
      file->line[lineNo] = AddMBrackets(file,this,mask,maxMask);
      }

   /*---------------------------------------------------------------
    * generate temp file name
    *---------------------------------------------------------------*/
   file->tempName = TempFileName(&tempFile,info);

   /*---------------------------------------------------------------
    * write file to temp file
    *---------------------------------------------------------------*/
   for (i=0; i<(int)file->lines; i++)
      fputs(file->line[i],tempFile);

   fclose(tempFile);

   /*---------------------------------------------------------------
    * let's clean up all the memory we used
    *---------------------------------------------------------------*/
   free(mask);

   /*---------------------------------------------------------------
    * clean out our data structures
    *---------------------------------------------------------------*/
   cParseDone(file,info);

   return 0;
   }

