/*------------------------------------------------------------------
 * cPostPar.c : higher level parser for cPost
 *------------------------------------------------------------------
 * 03-19-92 originally by Patrick J. Mueller
 * 12-03-92 converted from cBook to cPost
 *------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ctok.h"
#include "cpost.h"

/*------------------------------------------------------------------
 * is string a C keyword
 *------------------------------------------------------------------*/
static int IsKeyword(
   Info *info,
   char *str
   )
   {
   if (HashFind(info->reservedHash,&str))
      return 1;
   else
      return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add function information to tokens in list
 *------------------------------------------------------------------*/
static void AddFunctionInfoToTokens(
   File *file
   )
   {
   Tok *next;
   Tok *func;

   /*---------------------------------------------------------------
    * loop through the file
    *---------------------------------------------------------------*/
   next = file->tokList;
   while (NULL != next)
      {
      /*------------------------------------------------------------
       * continue reading till we have an identifier
       *------------------------------------------------------------*/
      if (TOKEN_IDENT != next->extType)
         {
         next = next->next;
         continue;
         }

      /*---------------------------------------------------------
       * if next token is (, this is a function name!
       *---------------------------------------------------------*/
      func = next;
      next = next->next;
      if (NULL == next)
         return;

      while ((TOKEN_COMMENT == next->extType) ||
             (TOKEN_PREPROC == next->extType))
         {
         next = next->next;

         if (NULL == next)
            return;
         }

      if (TOKEN_LPAREN == next->extType)
         {

         /*------------------------------------------------------
          * if we're in braces, it's usage
          *------------------------------------------------------*/
         if (next->nestBrace > 0)
            func->extType = TOKEN_FUNUSE;

         /*------------------------------------------------------
          * otherwise it's a prototype or definition
          *------------------------------------------------------*/
         else
            {
            /*---------------------------------------------------
             * get to the top level parenthesis
             *---------------------------------------------------*/
            while (next->nestParen > 0)
               {
               next = next->next;
               if (NULL == next)
                  return;
               }

            /*---------------------------------------------------
             * if next token is ;, it's a prototype, otherwise
             * it's a definition - we'll assume it's a prototype
             * though
             *---------------------------------------------------*/
            func->extType = TOKEN_FUNPRO;

            next = next->next;
            if (NULL == next)
               return;

            while ((TOKEN_COMMENT == next->extType) ||
                   (TOKEN_PREPROC == next->extType))
               {
               next = next->next;

               if (NULL == next)
                  return;
               }

            if      (TOKEN_SCOLON == next->extType)
               func->extType = TOKEN_FUNPRO;
            else if (TOKEN_COMMA  == next->extType)
               func->extType = TOKEN_FUNPRO;
            else
               func->extType = TOKEN_FUNDEF;
            }
         }
      }
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * function that walks over hash table - for each thing in hash
 * table, see if it's a function - if not, release the strings
 * storage - otherwise add to the info hash table
 *------------------------------------------------------------------*/
static int CleanUpHashTableWalker(
   char **ident,
   Info  *info
   )
   {
   Function  func;
   Function *found;

   func.name = *ident;

   /*---------------------------------------------------------------
    * see if it's a function
    *---------------------------------------------------------------*/
   found = ListFind(info->funcTree,&func);

   /*---------------------------------------------------------------
    * if not found, release string storage
    *---------------------------------------------------------------*/
   if (!found)
      {
      free(*ident);
      return 0;
      }

   /*---------------------------------------------------------------
    * see if it's already in the info hash table
    *---------------------------------------------------------------*/
   if (HashFind(info->identHash,ident))
      {
      free(*ident);
      return 0;
      }

   /*---------------------------------------------------------------
    * if not, add it
    *---------------------------------------------------------------*/
   if (!HashAdd(info->identHash,ident))
      cPostError(1,"error adding identifier to global hash table");

   return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * parse the file for functions
 *------------------------------------------------------------------*/
void cParse(
   File     *file,
   Info     *info
   )
   {
   void          *hTokenizer;
   Tok           *next;
   Tok           *prev;
   Tok           *fnc;
   static char    tmpIdent [MAX_IDENT_LEN + 1];
   char          *ptmpIdent  =   tmpIdent;
   char         **pptmpIdent = &ptmpIdent;
   char         **tempStr;

   /*---------------------------------------------------------------
    * read the file
    *---------------------------------------------------------------*/
   if (NULL == FileReadLines(info,file))
      cPostError(1,"unable to read file");

   file->identHash = HashCreate(sizeof(char *),
                                1000,
                                (HashFunc *)IdentHash,
                                (ListCompareFunc *)IdentCompare,
                                cPostNoMem);
   if (!file->identHash)
      cPostError(1,"error creating hash table");

   /*------------------------------------------------------------
    * initialize tokenization
    *------------------------------------------------------------*/
   hTokenizer      = CTokInit(GetBlockOfFile,file);
   if (!hTokenizer)
      cPostError(1,"error initializing tokenization");

   file->tokList   = NULL;
   next            = malloc(sizeof(Tok));
   if (!next)
      cPostError(1,"out of memory!!!");

   next->next      = NULL;
   next->nestParen = 0;
   next->nestBrace = 0;
   next->str       = NULL;

   prev = NULL;

   fnc = NULL;

   /*------------------------------------------------------------
    * build list of tokens
    *------------------------------------------------------------*/
   CTokGet(hTokenizer,&(next->tok));
   while (TOKEN_EOF != next->tok.type)
      {

      /*------------------------------------------------------------
       * get a little more info
       *------------------------------------------------------------*/
      next->extType = next->tok.type;

      if (TOKEN_OPER == next->extType)
         {
         switch(next->tok.ident[0])
            {
            case '{':
               next->extType = TOKEN_LBRACE;
               next->nestBrace++;

               if (next->nestParen)
                  {
                  fprintf(stderr,"unmatched ( on or before "
                                 "line %ld\n",next->tok.line);
                  next->nestParen = 0;
                  }
               break;

            case '}':
               next->extType = TOKEN_RBRACE;
               next->nestBrace--;

               if (next->nestParen)
                  {
                  fprintf(stderr,"unmatched ( on or before "
                                 "line %ld\n",next->tok.line);
                  next->nestParen = 0;
                  }
               break;

            case '(':
               next->extType = TOKEN_LPAREN;
               next->nestParen++;

               /*---------------------------------------------------
                * add the identifier before this, if there was one
                *---------------------------------------------------*/
               if (!fnc)
                  break;

               /*------------------------------------------------------
                * get string from hash or add it
                *------------------------------------------------------*/
               tempStr = HashFind(file->identHash,pptmpIdent);
               if (tempStr)
                  fnc->str = *tempStr;
               else
                  {
                  fnc->str = malloc(1+strlen(tmpIdent));
                  if (!fnc->str)
                     cPostError(1,"out of memory!!!");

                  strcpy(fnc->str,tmpIdent);
                  if (!HashAdd(file->identHash,&(fnc->str)))
                     cPostError(1,"error adding identifier to file hash table");
                  }

               fnc = NULL;
               break;

            case ')':
               next->extType = TOKEN_RPAREN;

               if (next->nestParen)
                  next->nestParen--;
               else
                  {
                  fprintf(stderr,"unnested ) on "
                                 "line %ld\n",next->tok.line);
                  next->nestParen = 0;
                  }

               break;

            case ';':
               next->extType = TOKEN_SCOLON;
               break;

            case ',':
               next->extType = TOKEN_COMMA;
               break;
            }
         }

      else if (TOKEN_IDENT == next->extType)
         {

         if (IsKeyword(info,next->tok.ident))
            next->extType = TOKEN_RESER;
         else
            {
            strcpy(tmpIdent,next->tok.ident);
            fnc = next;
            }
         }

      /*------------------------------------------------------------
       * link into list
       *------------------------------------------------------------*/
      if (NULL == file->tokList)
         file->tokList = next;
      else
         prev->next = next;

      /*------------------------------------------------------------
       * get next token
       *------------------------------------------------------------*/
      prev            = next;
      next            = malloc(sizeof(Tok));
      if (!next)
         cPostError(1,"out of memory!!!");

      next->next      = NULL;
      next->nestParen = prev->nestParen;
      next->nestBrace = prev->nestBrace;
      next->str       = NULL;

      CTokGet(hTokenizer,&(next->tok));
      }

   /*---------------------------------------------------------------
    * free the last hanging token
    *---------------------------------------------------------------*/
   free(next);

   /*------------------------------------------------------------
    * terminate tokenization
    *------------------------------------------------------------*/
   CTokTerm(hTokenizer);

   /*---------------------------------------------------------------
    * analyze the tokens
    *---------------------------------------------------------------*/
   AddFunctionInfoToTokens(file);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * clean up after parsing file for functions
 *------------------------------------------------------------------*/
void cParseDone(
   File     *file,
   Info     *info
   )
   {
   Tok *tok;
   Tok *next;
   int  i;

   /*---------------------------------------------------------------
    * walk over old hash table, adding functions to info hash table
    * and freeing non-function strings
    *---------------------------------------------------------------*/
   HashIterate(file->identHash,(ListIterateFunc *)CleanUpHashTableWalker,info);

   /*---------------------------------------------------------------
    * destroy the file hash table
    *---------------------------------------------------------------*/
   HashDestroy(file->identHash);

   /*---------------------------------------------------------------
    * now clean up token list
    *---------------------------------------------------------------*/
   tok = file->tokList;

   /*---------------------------------------------------------------
    * loop through tokens and free 'um
    *---------------------------------------------------------------*/
   while (tok)
      {
      next = tok->next;
      free(tok);
      tok = next;
      }

   /*---------------------------------------------------------------
    * release file storage
    *---------------------------------------------------------------*/
   for (i=0; i<(int)file->lines; i++)
      free(file->line[i]);

   free(file->line);
   }
