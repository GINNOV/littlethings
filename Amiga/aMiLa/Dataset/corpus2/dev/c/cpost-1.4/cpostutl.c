/*------------------------------------------------------------------
 * cpostutl.c : utilities for cPost
 *------------------------------------------------------------------
 * 11-23-91 originally by Patrick J. Mueller
 * 12-03-92 converted from cBook to cPost
 *------------------------------------------------------------------*/

#ifdef AMIGA
#define USE_BUILTIN_MATH
#endif /* AMIGA */

#if defined(OPSYS_OS2) || defined(OPSYS_OS2V2)
   #define INCL_BASE
   #include <os2.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include <time.h>

#include "ctok.h"
#include "cpost.h"
#include "tokfile.h"

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * compare two file names
 *------------------------------------------------------------------*/
int FileNameCompare(
   File *file1,
   File *file2
   )
   {
   int   scmp;
   int   i;
   char *name1;
   char *name2;

   /*---------------------------------------------------------------
    * get the base file names
    *---------------------------------------------------------------*/
   name1 = malloc(1+strlen(file1->name));
   name2 = malloc(1+strlen(file2->name));

   if (!name1 || !name2)
      cPostError(1,"out of memory!!!");

   strcpy(name1,file1->name);
   strcpy(name2,file2->name);

   if (strchr(name1,'.')) *strchr(name1,'.') = 0;
   if (strchr(name2,'.')) *strchr(name2,'.') = 0;

   /*---------------------------------------------------------------
    * sort each category
    *---------------------------------------------------------------*/
   for (i=0; i<(int)strlen(info.oSort); i++)
      {
      /*------------------------------------------------------------
       * sort by type
       *------------------------------------------------------------*/
      if ('T' == info.oSort[i])
         {
         if (file1->type < file2->type)
            {
            free(name1);
            free(name2);
            return -1;
            }
         if (file1->type > file2->type)
            {
            free(name1);
            free(name2);
            return  1;
            }

         scmp = Stricmp(file1->ext,file2->ext);
         if (scmp)
            {
            free(name1);
            free(name2);
            return  scmp;
            }
         }

      /*------------------------------------------------------------
       * sort by name
       *------------------------------------------------------------*/
      else if ('N' == info.oSort[i])
         {
         /*---------------------------------------------------------
          * sort by name
          *---------------------------------------------------------*/
         scmp = Stricmp(file1->name,file2->name);
         if (scmp)
            {
            free(name1);
            free(name2);
            return  scmp;
            }
         }
      }

   free(name1);
   free(name2);

   return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * compare two strings indirectly
 *------------------------------------------------------------------*/
int IdentCompare(
   char **str1,
   char **str2
   )
   {
   return strcmp(*str1,*str2);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * compare two function names
 *------------------------------------------------------------------*/
int FunctionNameCompare(
   Function *func1,
   Function *func2
   )
   {
   int cmp;

   cmp = Stricmp(func1->name,func2->name);
   if (cmp) return cmp;

   cmp = strcmp(func1->name,func2->name);
   if (cmp) return cmp;

   return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * compare two function names (via indirection)
 *------------------------------------------------------------------*/
int FunctionNamePtrCompare(
   Function **func1,
   Function **func2
   )
   {
   return FunctionNameCompare(*func1,*func2);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * hash an identifier
 *------------------------------------------------------------------*/
int IdentHash(
   char     **str,
   int        hashSize
   )
   {
   int   hash;
   char *c;

   for (hash=0, c=*str; *c; c++)
      hash +=*c;

   return hash % hashSize;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add a file to the list of files
 *------------------------------------------------------------------*/
void FileAdd(
   Info      *info,
   List      *fileList,
   char      *name,
   char      *pathName,
   char      *fDate,
   char      *fTime
   )
   {
   File  file;
   char *type;
   char *test;
   char *ext;

   /*---------------------------------------------------------------
    * copy the name in
    *---------------------------------------------------------------*/
   file.name = malloc(1+strlen(name));
   if (NULL == file.name)
      cPostError(1,"out of memory!!!");

   strcpy(file.name,name);

   file.pathName = malloc(1+strlen(name)+strlen(pathName));
   if (NULL == file.pathName)
      cPostError(1,"out of memory!!!");

   strcpy(file.pathName,pathName);
   strcat(file.pathName,name);

   strcpy(file.date,fDate);
   strcpy(file.time,fTime);

   /*---------------------------------------------------------------
    * get the extension
    *---------------------------------------------------------------*/
   ext = strchr(file.name,'.');
   if (!ext)
      file.ext = "";
   else
      {
      ext++;
      file.ext = malloc(1+strlen(ext));
      if (!file.ext)
         cPostError(1,"out of memory!!!");

      strcpy(file.ext,ext);

      /*------------------------------------------------------------
       * remove . and anything following it
       *------------------------------------------------------------*/
      if (strchr(file.ext,'.'))
         *strchr(file.ext,'.') = '\0';
      }

   /*---------------------------------------------------------------
    * default the type to 'other'
    *---------------------------------------------------------------*/
   file.type = 2;

   /*---------------------------------------------------------------
    * see if it's an 'H' file
    *---------------------------------------------------------------*/
   type = malloc(1+strlen(info->oHtype));
   if (!type)
      cPostError(1,"out of memory!!!");

   strcpy(type,info->oHtype);
   test = strtok(type,", ");
   while (test)
      {
      if (!Stricmp(file.ext,test))
         file.type = 0;

      test = strtok(NULL,", ");
      }

   free(type);

   /*---------------------------------------------------------------
    * see if it's a 'C' file
    *---------------------------------------------------------------*/
   type = malloc(1+strlen(info->oCtype));
   if (!type)
      cPostError(1,"out of memory!!!");

   strcpy(type,info->oCtype);
   test = strtok(type,", ");
   while (test)
      {
      if (!Stricmp(file.ext,test))
         file.type = 1;

      test = strtok(NULL,", ");
      }

   free(type);

   /*---------------------------------------------------------------
    * set rest of stuff
    *---------------------------------------------------------------*/
   file.line      = NULL;
   file.lines     = 0L;
   file.cline     = 0L;
   file.tempName  = NULL;
   file.breakList = NULL;

   file.funcDefList = ListCreate(sizeof(Function *),
                                 (ListCompareFunc *)FunctionNamePtrCompare,
                                 cPostNoMem);
   if (!file.funcDefList)
      cPostError(1,"error creating function definition list");

   file.funcProList = ListCreate(sizeof(Function *),
                                 (ListCompareFunc *)FunctionNamePtrCompare,
                                 cPostNoMem);
   if (!file.funcProList)
      cPostError(1,"error creating function prototype list");

   /*---------------------------------------------------------------
    * now add it to the list
    *---------------------------------------------------------------*/
   if (ListFind(fileList,&file))
      return;

   if (ListAdd(fileList,&file))
      return;

   /*---------------------------------------------------------------
    * otherwise, error adding it
    *---------------------------------------------------------------*/
   cPostError(1,"error adding file %s to file list",name);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

#if defined(OPSYS_OS2) || defined(OPSYS_OS2V2)
/*------------------------------------------------------------------
 * OS/2 version - add all the files in a file spec to the list
 *------------------------------------------------------------------*/
void FileSpecAddOS2(
   Info      *info,
   List      *fileList,
   char      *fileSpec
   )
   {
   USHORT       rc;
   HDIR         hDir;
#if defined(OPSYS_OS2V2)
   FILEFINDBUF3 ffbuf;
   ULONG        attr;
   ULONG        cnt;
#else
   FILEFINDBUF  ffbuf;
   USHORT       attr;
   USHORT       cnt;
#endif
   int               files;
   static UCHAR      pathName[261];
   char              szTime[9];
   char              szDate[9];

   /*---------------------------------------------------------------
    * get path name of spec
    *---------------------------------------------------------------*/
#if defined(OPSYS_OS2V2)
   rc = DosQueryPathInfo(fileSpec,5,pathName,sizeof(pathName));
#else
   rc = DosQPathInfo(fileSpec,5,pathName,sizeof(pathName),0);
#endif
   if (rc)
      cPostError(1,"error getting path for %s",fileSpec);

   /*---------------------------------------------------------------
    * convert slashes to back slashes
    *---------------------------------------------------------------*/
   while (strchr(pathName,'/'))
      *strchr(pathName,'/') = '\\';

   *(strrchr(pathName,'\\') + 1) = '\0';

   /*---------------------------------------------------------------
    * get the first file
    *---------------------------------------------------------------*/
   hDir = 0xFFFF;
   attr = 0;
   cnt  = 1;

#if defined(OPSYS_OS2V2)
   rc = DosFindFirst(fileSpec,&hDir,attr,&ffbuf,sizeof(ffbuf), &cnt,1);
#else
   rc = DosFindFirst(fileSpec,&hDir,attr,&ffbuf,sizeof(ffbuf), &cnt,0);
#endif

   /*---------------------------------------------------------------
    * continue while we keep getting files
    *---------------------------------------------------------------*/
   for (files=0; 0 == rc; files++)
      {
      sprintf(szDate,"%2.2d/%2.2d/%2.2d",
              (int) ffbuf.fdateLastWrite.month,
              (int) ffbuf.fdateLastWrite.day,
              (int) ffbuf.fdateLastWrite.year+80);

      sprintf(szTime,"%2.2d:%2.2d:%2.2d",
              (int) ffbuf.ftimeLastWrite.hours,
              (int) ffbuf.ftimeLastWrite.minutes,
              (int) ffbuf.ftimeLastWrite.twosecs * 2);

      if (!IsTempFileName(ffbuf.achName))
         FileAdd(info,fileList,ffbuf.achName,pathName,szDate,szTime);

      /*------------------------------------------------------------
       * get next file
       *------------------------------------------------------------*/
      rc = DosFindNext(hDir,&ffbuf,sizeof(ffbuf),&cnt);
      }

   rc = DosFindClose(hDir);
   }

#elif defined(OPSYS_CMS)
/*------------------------------------------------------------------
 * cms version - add all the files in a file spec to the list
 *------------------------------------------------------------------*/
void FileSpecAddCMS(
   Info      *info,
   List      *fileList,
   char      *fileSpec
   )
   {
   int    rc;
   FILE  *stack;
   int    num;
   char  *copy;
   char  *buffer;
   char   fileName[21];
   char  *fileDate;
   char  *fileTime;
   int    i;

#define BUFFER_LEN 1000

   /*---------------------------------------------------------------
    * make copy of spec, and translate '.' to ' '
    *---------------------------------------------------------------*/
   copy = malloc(1+strlen(fileSpec));
   if (!copy)
      cPostError(1,"out of memory!!!");

   strcpy(copy,fileSpec);
   fileSpec = copy;

   /*---------------------------------------------------------------
    * translate '.' to ' '
    *---------------------------------------------------------------*/
   while (strchr(fileSpec,'.'))
      *strchr(fileSpec,'.') = ' ';

   /*---------------------------------------------------------------
    * build command string
    *---------------------------------------------------------------*/
   buffer = malloc(BUFFER_LEN);
   if (!buffer)
      cPostError(1,"out of memory!!!");

   strcpy(buffer,"LISTFILE ");
   strcat(buffer,fileSpec);
   strcat(buffer," ( NOH STACK DATE");

   /*---------------------------------------------------------------
    * set high water mark
    *---------------------------------------------------------------*/
   system("MAKEBUF");

   /*---------------------------------------------------------------
    * run command
    *---------------------------------------------------------------*/
   rc = system(buffer);
   if (rc)
      {
      cPostError(rc,"return code %d from '%s'",rc,buffer);
      exit(rc);
      }

   /*---------------------------------------------------------------
    * see how many stacked
    *---------------------------------------------------------------*/
   num = system("SENTRIES");

   /*---------------------------------------------------------------
    * open the stack
    *---------------------------------------------------------------*/
   stack = fopen("*","r");
   if (!stack)
      {
      cPostError(1,"error opening stack for reading");
      exit(1);
      }

   /*---------------------------------------------------------------
    * read the stack, add files
    *---------------------------------------------------------------*/
   while (num--)
      {
      fgets(buffer,BUFFER_LEN,stack);
      if ('\n' == buffer[strlen(buffer)-1])
         buffer[strlen(buffer)-1] = '\0';

      /*------------------------------------------------------------
       * get the file name
       *------------------------------------------------------------*/
      copy = strtok(buffer," ");
      strcpy(fileName,copy);
      strcat(fileName,".");

      copy = strtok(NULL," ");
      strcat(fileName,copy);
      strcat(fileName,".");

      copy = strtok(NULL," ");
      strcat(fileName,copy);

      /*------------------------------------------------------------
       * get the date and time
       *------------------------------------------------------------*/
      for (i=0; i<4; i++)
         strtok(NULL," ");

      fileDate = strtok(NULL," ");
      fileTime = strtok(NULL," ");

      /*------------------------------------------------------------
       * add file
       *------------------------------------------------------------*/
      FileAdd(info,fileList,fileName,"",fileDate,fileTime);
      }

   /*---------------------------------------------------------------
    * close stack, free memory, leave
    *---------------------------------------------------------------*/
   fclose(stack);
   free(fileSpec);
   free(buffer);

   }

/*------------------------------------------------------------------
 * other operating systems (AIX, DOS, ???)
 *------------------------------------------------------------------*/
#else

#include <sys/types.h>
#include <sys/stat.h>

/*------------------------------------------------------------------
 * get file date and time
 *------------------------------------------------------------------*/
void getFileDateTime(
   char *fileName,
   char *fileDate,
   char *fileTime
   )
   {
   struct stat  s;
   struct tm   *t;

   *fileDate = 0;
   *fileTime = 0;

   if (stat(fileName,&s))
      return;

   t = localtime(&(s.st_mtime));

   sprintf(fileDate,"%2.2d/%2.2d/%2.2d",
           (int) t->tm_mon + 1,
           (int) t->tm_mday,
           (int) t->tm_year % 100);

   sprintf(fileTime,"%2.2d:%2.2d:%2.2d",
           (int) t->tm_hour,
           (int) t->tm_min,
           (int) t->tm_sec);
   }

/*------------------------------------------------------------------
 * generic version - add all the files in a file spec to the list
 *   this will work for AIX
 *------------------------------------------------------------------*/
void FileSpecAddGeneric(
   Info      *info,
   List      *fileList,
   char      *fileSpec
   )
   {
   char        *pathName;
   char        *fileName;
   struct stat  statBuff;
   char         dateBuff[9];
   char         timeBuff[9];

   /*---------------------------------------------------------------
    * get area for path name
    *---------------------------------------------------------------*/
   if (!strchr(fileSpec,'/'))
      {
      pathName = "";
      fileName = fileSpec;
      }

   else
      {
      /*------------------------------------------------------------
       * convert back slashes to slashes
       *------------------------------------------------------------*/
      while (strchr(fileSpec,'\\'))
         *strchr(fileSpec,'\\') = '/';

      /*------------------------------------------------------------
       * get path part of file spec
       *------------------------------------------------------------*/
      pathName = malloc(1+strlen(fileSpec));
      if (!pathName)
         cPostError(1,"out of memory!!!");

      strcpy(pathName,fileSpec);

      *(strrchr(pathName,'/') + 1) = '\0';

      /*------------------------------------------------------------
       * get filename part of file spec
       *------------------------------------------------------------*/
      fileName = malloc(1+strlen(fileSpec));
      if (!fileName)
         cPostError(1,"out of memory!!!");

      strcpy(fileName,fileSpec);
      fileName = strrchr(fileName,'/') + 1;
      }

   /*------------------------------------------------------------
    * get file date and time
    *------------------------------------------------------------*/
   getFileDateTime(fileSpec,dateBuff,timeBuff);

   /*---------------------------------------------------------------
    * add file
    *---------------------------------------------------------------*/
   FileAdd(info,fileList,fileName,pathName,dateBuff,timeBuff);
   }

#endif

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * the router for FileSpecAdd
 *------------------------------------------------------------------*/
void FileSpecAdd(
   Info      *info,
   List      *fileList,
   char      *fileSpec
   )
   {
   TokFileInfo tfi;


   /*---------------------------------------------------------------
    * check for @ files
    *---------------------------------------------------------------*/
   if (('@' == fileSpec[0]) && (1 != strlen(fileSpec)))
      {
      fileSpec++;
      tfi = TokFileOpen(fileSpec);
      if (!tfi)
         {
         cPostError(0,"error opening file '%s' for reading",fileSpec);
         return;
         }

      /*------------------------------------------------------------
       * add filenames from file
       *------------------------------------------------------------*/
      while (NULL != (fileSpec = TokFileNext(tfi)))
         FileSpecAdd(info,fileList,fileSpec);

      return;
      }

   /*---------------------------------------------------------------
    * call the op/sys dependant function
    *---------------------------------------------------------------*/

#if defined(OPSYS_OS2) || defined(OPSYS_OS2V2)

   FileSpecAddOS2(info,fileList,fileSpec);

#elif defined(OPSYS_CMS)

   FileSpecAddCMS(info,fileList,fileSpec);

#else

   FileSpecAddGeneric(info,fileList,fileSpec);

#endif
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * count occurances of a character in a string
 *------------------------------------------------------------------*/
static int strcnt(
   char  c,
   char *string
   )
   {
   int   cnt;

   cnt    = 0;
   string = strchr(string,c);

   while (string)
      {
      cnt++;
      string++;
      string = strchr(string,c);
      }

   return cnt;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * expand tabs
 *------------------------------------------------------------------*/
static char *ExpandTabs(
   char *line,
   int   expand
   )
   {
   int   tabs;
   char *newLine;
   int   lineLen;
   int   col;
   char *c1;
   char *c2;

   /*---------------------------------------------------------------
    * get # of tabs - if no tabs, return line intact
    *---------------------------------------------------------------*/
   tabs = strcnt('\t',line);
   if (!tabs)
      return line;

   /*---------------------------------------------------------------
    * otherwise, allocate space for new line
    *---------------------------------------------------------------*/
   lineLen = strlen(line);
   newLine = malloc(lineLen + 1 + expand * tabs);
   if (!newLine)
      cPostError(1,"out of memory!!!");

   memset(newLine,0,lineLen + 1 + expand * tabs);

   /*---------------------------------------------------------------
    * copy old string to new string, expanding tabs as you go
    *---------------------------------------------------------------*/
   col = 1;
   c1  = line;
   c2  = newLine;
   while (*c1)
      {
      /*------------------------------------------------------------
       * copy non-tab chars into new string
       *------------------------------------------------------------*/
      if ('\t' != *c1)
         {
         *c2++ = *c1++;
         col++;
         }

      else
         {
         c1++;
/*------------------------------------------------------------------
 * art roberts identified this bug in the code and also supplied a
 * fix (below).
 *------------------------------------------------------------------*/
#if 0
         for (i = col%expand; i < (expand+1); i++)
            {
            *c2++ = ' ';
            col++;
            }
#else
         do
            {
            *c2++ = ' ';
            }
         while ((col++ % expand) != 0);
#endif
         }
      }

   /*---------------------------------------------------------------
    * free original line, return new line
    *---------------------------------------------------------------*/
   free(line);
   return newLine;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * read file into array of lines
 *------------------------------------------------------------------*/
File *FileReadLines(
   Info *info,
   File *file
   )
   {
   static char    buffer [MAX_LINE_LEN];
   FILE          *hFile;
   unsigned long  lines;
   char          *line;

   /*---------------------------------------------------------------
    * initialize
    *---------------------------------------------------------------*/
   file->line       = NULL;
   file->lines      = 0;
   file->cline      = 0L;
   file->maxLineLen = 0;
   memset(buffer,'\0',sizeof(buffer));

   /*---------------------------------------------------------------
    * open file
    *---------------------------------------------------------------*/
   if (file->tempName)
      {
      hFile = fopen(file->tempName,"r");
      if (NULL == hFile)
         cPostError(1,"error opening file %s for reading",file->tempName);
      }

   else
      {
      hFile = fopen(file->pathName,"r");
      if (NULL == hFile)
         cPostError(1,"error opening file %s for reading",file->pathName);
      }

   /*---------------------------------------------------------------
    * buffer input
    *---------------------------------------------------------------*/
/* setvbuf(hFile,NULL,_IOFBF,32000); */

   /*---------------------------------------------------------------
    * allocate area for lines
    *---------------------------------------------------------------*/
   lines = FILE_LINES;
   file->line = malloc(((int)lines)*sizeof(char *));
   if (NULL == file->line)
      cPostError(1,"out of memory!!!");

   /*---------------------------------------------------------------
    * loop for each line in the file
    *---------------------------------------------------------------*/
   for (file->lines=0;;file->lines++)
      {
      /*------------------------------------------------------------
       * reallocate buffer if we need to
       *------------------------------------------------------------*/
      if (file->lines >= lines)
         {
         lines += FILE_LINES;
         file->line   = realloc(file->line,((int)lines)*sizeof(char *));
         if (NULL == file->line)
            cPostError(1,"out of memory!!!");
         }

      /*------------------------------------------------------------
       * read a line
       *------------------------------------------------------------*/
#if defined(DO_IT_NO_MORE)
      if (info->indent1)
         {
         buffer[0] = ' ';
         if (!fgets(&(buffer[1]),MAX_LINE_LEN-1,hFile))
            break;
         }

      else
#endif
         {
         if (!fgets(buffer,MAX_LINE_LEN,hFile))
            break;
         }


      /*------------------------------------------------------------
       * malloc space for new line
       *------------------------------------------------------------*/
      line = malloc(1+strlen(buffer));
      if (!line)
         cPostError(1,"out of memory!!!");

      /*------------------------------------------------------------
       * copy line we just got into new line
       *------------------------------------------------------------*/
      strcpy(line,buffer);

      /*---------------------------------------------------------------
       * expand tabs
       *---------------------------------------------------------------*/
      line = ExpandTabs(line,info->oTabs);

      /*------------------------------------------------------------
       * set vars
       *------------------------------------------------------------*/
      file->line[file->lines] = line;
      file->maxLineLen = max(file->maxLineLen,(int)strlen(line));
      }

   /*---------------------------------------------------------------
    * close the file
    *---------------------------------------------------------------*/
   fclose(hFile);

   return file;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * return bytes from the file, conveniently a line at a time
 *------------------------------------------------------------------*/
unsigned long GetBlockOfFile(
   void  *readInfo,
   char **buffer
   )
   {
   File *file;
   file = readInfo;

   if (file->cline >= file->lines)
      return 0L;

   *buffer = file->line[file->cline++];
   return (unsigned long) strlen(*buffer);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * get function (add if needed) from global function table
 *------------------------------------------------------------------*/
Function *GetFunction(
   Info          *info,
   char          *name
   )
   {
   Function  func;
   Function *found;

   func.name = name;

   /*---------------------------------------------------------------
    * look for function
    *---------------------------------------------------------------*/
   found = ListFind(info->funcTree,&func);
   if (found)
      return found;

   /*---------------------------------------------------------------
    * fill in fields if not found
    *---------------------------------------------------------------*/
   func.id           = 0;
   func.spotted      = 0;
   func.callsList    = ListCreate(sizeof(Function *),
                                  (ListCompareFunc *)FunctionNamePtrCompare,
                                  cPostNoMem);
   if (!func.callsList)
      cPostError(1,"error creating function calls list");

   func.calledByList = ListCreate(sizeof(Function *),
                                  (ListCompareFunc *)FunctionNamePtrCompare,
                                  cPostNoMem);
   if (!func.calledByList)
      cPostError(1,"error creating function called by list");

   func.name         = malloc(1+strlen(name));
   if (!func.name)
      cPostError(1,"out of memory!!!");

   strcpy(func.name,name);

   func.lineNo       = 0;
   func.fileName     = "";

   /*---------------------------------------------------------------
    * add it, return pointer
    *---------------------------------------------------------------*/
   if (!ListAdd(info->funcTree,&func))
      cPostError(1,"error adding function to function list");

   found = ListFind(info->funcTree,&func);
   if (!found)
      cPostError(1,"error retrieving function from function list");

   return found;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * prinf function table entry
 *------------------------------------------------------------------*/
static int PrintFunctionTableEntry(
   Function **func,
   Info      *info
   )
   {
   fprintf(info->oFile,":hp2.%s:ehp2.",(*func)->name);

   if ('\0' != *((*func)->fileName))
      {
      fprintf(info->oFile," (%s, page :spotref refid=sp%4.4d.)\n",
                     (*func)->fileName,(*func)->id);
      }

   else
      fprintf(info->oFile,"\n");

   info->count1++;
   return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * print function pointer information
 *------------------------------------------------------------------*/
int PrintFunctionPtrInfo(
   Function **func,
   Info      *info
   )
   {
   return PrintFunctionInfo(*func,info);
   }

/*------------------------------------------------------------------
 * print function information
 *------------------------------------------------------------------*/
int PrintFunctionInfo(
   Function  *func,
   Info      *info
   )
   {

   /*---------------------------------------------------------------
    * print table definition
    *---------------------------------------------------------------*/
   fprintf(info->oFile,":table refid=reftbl.\n");

   /*---------------------------------------------------------------
    * print function name
    *---------------------------------------------------------------*/
   fprintf(info->oFile,":row.:c 5.&fn%4.4d.",func->id);

   if ('\0' != *(func->fileName))
      {
      fprintf(info->oFile," (%s, page :spotref refid=sp%4.4d.)\n",
                     func->fileName,func->id);
      }

   else
      fprintf(info->oFile,"\n");

   /*---------------------------------------------------------------
    * print calls list
    *---------------------------------------------------------------*/
   if (ListCount(func->callsList))
      {
      fprintf(info->oFile,":c 1.calls\n:c 2.");

      info->count1 = 1;
      info->count2 = ListCount(func->callsList);

      ListIterate(func->callsList,
                  (ListIterateFunc *)PrintFunctionTableEntry,
                  info);
      }

   /*---------------------------------------------------------------
    * print called by list
    *---------------------------------------------------------------*/
   if (ListCount(func->calledByList))
      {
      fprintf(info->oFile,":c 3.called\nby\n:c 4.");

      info->count1 = 1;
      info->count2 = ListCount(func->calledByList);

      ListIterate(func->calledByList,
                  (ListIterateFunc *)PrintFunctionTableEntry,
                  info);
      }

   fprintf(info->oFile,":etable.\n");

   return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * generate a temporary file name
 *------------------------------------------------------------------*/
char *TempFileName(
   FILE **file,
   Info  *info
   )
   {
   char       *name;
   static int  counter = 0;

   name = malloc(13 + 1 + strlen(info->oTemp));
   if (!name)
      cPostError(1,"out of memory!!!");

   for(;;)
      {

#if defined(OPSYS_CMS)
      if (*(info->oTemp))
         sprintf(name,"cps%.5d.tmp.%c",counter++,*(info->oTemp));
      else
         sprintf(name,"cps%.5d.tmp",counter++);
#else
      sprintf(name,"%scps%.5d.tmp",info->oTemp,counter++);
#endif

      /*---------------------------------------------------------------
       * open temp file
       *---------------------------------------------------------------*/
      *file = fopen(name,"r");
      if (NULL == *file)
         {
         *file = fopen(name,"w");
         if (NULL != *file)
            return name;
         else
            {
            cPostError(0,"error opening temp file '%s' for writing",name);
            cPostError(1,"check -y value for writable temporary path");
            }
         }

      fclose(*file);
      }

   /*---------------------------------------------------------------
    * can't really get here anymore
    *---------------------------------------------------------------*/
   cPostError(1,"can't create temp file");
   return NULL;
   }

/*------------------------------------------------------------------
 * see if a file is one of our temporary files
 *------------------------------------------------------------------*/
int IsTempFileName(
   char *name
   )
   {
   if (Memicmp(name,"cps",3))
      return 0;

   if (Memicmp(name+8,".tmp",4))
      return 0;

   return 1;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * compare strings case insensitively
 *------------------------------------------------------------------*/
int Stricmp(
   char *str1,
   char *str2
   )
   {
   char c1;
   char c2;

   while (*str1 && *str2)
      {
      c1 = (char) toupper(*str1);
      c2 = (char) toupper(*str2);

      if (c1 < c2)
         return -1;
      else if (c1 > c2)
         return  1;

      str1++; str2++;
      }

   if (!*str1 && !*str2)
      return 0;

   if (*str1)
      return  1;
   else
      return -1;
   }

/*------------------------------------------------------------------
 * compare strings case insensitively
 *------------------------------------------------------------------*/
int Memicmp(
   char *str1,
   char *str2,
   int   len
   )
   {
   char c1;
   char c2;
   int  i;

   for (i=0; i<len; i++)
      {
      c1 = (char) toupper(*str1);
      c2 = (char) toupper(*str2);

      if (c1 < c2)
         return -1;
      else if (c1 > c2)
         return  1;

      str1++; str2++;
      }

   return 0;
   }

/*------------------------------------------------------------------
 * upper case a string
 *------------------------------------------------------------------*/
char *Strupr(
   char *str
   )
   {
   char *orig;
   orig = str;
   
   while (*str)
      {
      *str = (char) toupper(*str);
      str++;
      }

   return orig;
   }

#if 0
/*------------------------------------------------------------------
 * reverse a string
 *------------------------------------------------------------------*/
char *Strrev(
   char *str
   )
   {
   int   len;
   char  temp;
   int   i;

   len = strlen(str);

   for (i=0; i<(len+1)/2-1; i++)
      {
      temp         = str[i];
      str[i]       = str[len-1-i];
      str[len-i-1] = temp;
      }

   return str;
   }
#endif

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * called when out of memory
 *------------------------------------------------------------------*/
void cPostNoMem(void)
   {
   cPostError(1,"out of memory!!!");
   }

