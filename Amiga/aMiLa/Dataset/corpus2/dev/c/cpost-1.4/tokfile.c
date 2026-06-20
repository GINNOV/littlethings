/*------------------------------------------------------------------
 * tokfile.c :
 *------------------------------------------------------------------
 * 02-13-93 originally by Patrick J. Mueller
 *------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tokfile.h"

/*------------------------------------------------------------------
 * types
 *------------------------------------------------------------------*/
typedef struct
   {
   FILE *fHandle;
   int   index;
   int   length;
   char  line[TOKFILE_MAX_LINE+1];
   } TokFileData;

/*------------------------------------------------------------------
 * open a file to be tokenized
 *------------------------------------------------------------------*/
TokFileInfo TokFileOpen(
   char *fileName
   )
   {
   TokFileData *tfd;

   /*---------------------------------------------------------------
    * allocate memory for handle
    *---------------------------------------------------------------*/
   tfd = malloc(sizeof(TokFileData));
   if (!tfd)
      return NULL;

   memset(tfd,0,sizeof(TokFileData));

   /*---------------------------------------------------------------
    * open the file
    *---------------------------------------------------------------*/
   if (!strcmp(fileName,"-"))
      tfd->fHandle = stdin;
   else
      tfd->fHandle = fopen(fileName,"r");

   if (!tfd->fHandle)
      {
      free(tfd);
      return NULL;
      }

   /*---------------------------------------------------------------
    * return handle
    *---------------------------------------------------------------*/
   return (TokFileInfo) tfd;
   }

#define WHITE_SPACE " \a\b\f\n\r\t\v"

/*------------------------------------------------------------------
 * get the next token from the file
 *------------------------------------------------------------------*/
char *TokFileNext(
   TokFileInfo tfi
   )
   {
   TokFileData *tfd = tfi;
   char        *tok;

   if (!tfd)
      return NULL;

   if (!tfd->fHandle)
      return NULL;

   /*---------------------------------------------------------------
    * loop trying to get the next token
    *---------------------------------------------------------------*/
   while (1)
      {

      /*------------------------------------------------------------
       * do we need to get another line
       *------------------------------------------------------------*/
      while (tfd->index >= tfd->length)
         {
         fgets(tfd->line,TOKFILE_MAX_LINE,tfd->fHandle);

         if (feof(tfd->fHandle))
            {
            fclose(tfd->fHandle);
            free(tfd);
            return NULL;
            }

         tfd->length = strlen(tfd->line);
         tfd->index  = strspn(tfd->line,WHITE_SPACE);

         /*---------------------------------------------------------
          * check for comment
          *---------------------------------------------------------*/
         if ((tfd->index < tfd->length) && ('#' == tfd->line[tfd->index]))
            tfd->index = tfd->length;
         }

      /*------------------------------------------------------------
       * skip past white space
       *------------------------------------------------------------*/
      tfd->index += strspn(tfd->line + tfd->index, WHITE_SPACE);

      if (tfd->index >= tfd->length)
         continue;

      tok = tfd->line + tfd->index;

      /*------------------------------------------------------------
       * skip past non-white space
       *------------------------------------------------------------*/
      tfd->index += strcspn(tfd->line + tfd->index, WHITE_SPACE);

      tfd->line[tfd->index] = 0;

      tfd->index++;

      return tok;
      }

   return NULL;
   }

#define TESTER_NOT
#if defined(TESTER)

int main(void)
   {
   TokFileInfo  tfi;
   char        *token;

   tfi = TokFileOpen("-");

   while (token = TokFileNext(tfi))
      printf("%s\n",token);

   return 0;
   }

#endif
