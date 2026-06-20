/*------------------------------------------------------------------
 * cPost.c  : c language formatter
 *------------------------------------------------------------------
 * 10-10-91 originally by Patrick J. Mueller
 * 12-03-92 converted from cBook to cPost
 *------------------------------------------------------------------*/

#define PROGRAM_VERS  "1.4"
#define PROGRAM_NAME  "cPost"
#define PROGRAM_YEAR  "1994"
#define PROGRAM_AUTH  "Patrick J. Mueller"
#define PROGRAM_ADDR  "(pmuellr@vnet.ibm.com)"
#define PROGRAM_ENVV  "CPOST"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <signal.h>
#include <time.h>

#include "parsearg.h"

#include "ctok.h"
#define DEFINE_GLOBALS
#include "cpost.h"
#include "tokfile.h"

#include "cposthdr.h"

/*---------------------------------------------------------------
 * global variables
 *---------------------------------------------------------------*/
int  AllDone = 0;

static char *ReservedTokens[] =
   {
   /*---------------------------------------------------------------
    * data types
    *---------------------------------------------------------------*/
   "auto", "char", "const", "double", "enum", "extern", "float", "int",
   "long", "register", "short", "signed", "static", "struct", "union",
   "unsigned", "void", "volatile",

   /*---------------------------------------------------------------
    * other keywords
    *---------------------------------------------------------------*/
   "break", "case", "continue", "default", "do", "else", "for", "goto",
   "if", "return", "sizeof", "switch", "typedef", "while",

   /*---------------------------------------------------------------
    * saa c extensions
    *---------------------------------------------------------------*/
   "_Packed","_System","_Optlink", "_Far16", "_Cdecl", "_Pascal"
   };

/*------------------------------------------------------------------
 * c++ reserved words
 *------------------------------------------------------------------*/
static char *CppReservedTokens[] =
   {
   "catch", "class", "delete", "friend", "inline", "new", "operator",
   "private", "protected", "public", "template", "this", "throw", "try",
   "virtual"
   };


/*------------------------------------------------------------------
 * generate an error message and exit
 *------------------------------------------------------------------*/
void cPostError(
   int   exitCode,
   char *format,
   ...
   )
   {
   va_list vlist;

   fprintf(stderr,"%s : ",PROGRAM_NAME);

   va_start(vlist,format);
   vfprintf(stderr,format,vlist);
   va_end(vlist);

   fprintf(stderr,"\n");

   if (exitCode)
      exit(exitCode);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * print some help, assuming me is argv[0]
 *------------------------------------------------------------------*/
static void Usage(void)
   {
   fprintf(stderr,"%s %s by %s %s\n",PROGRAM_NAME,PROGRAM_VERS,PROGRAM_AUTH,PROGRAM_ADDR);
   fprintf(stderr,"\n");
   fprintf(stderr,"usage:\n");
   fprintf(stderr,"   %s <options> <filespec> <filespec> ...\n",PROGRAM_NAME);
   fprintf(stderr,"is used to produce a listing of C language files in PostScript\n");
   fprintf(stderr,"format.  The PostScript output is written to stdout.\n\n");
   fprintf(stderr,"where:\n");
   fprintf(stderr,"   <filespec> is a filespec matching C language files.\n\n");
   fprintf(stderr,"Valid options are:\n");
   fprintf(stderr,"   -b[+|-]             - enable/disable bracketing around braces\n");
   fprintf(stderr,"   -cext1,ext2,...     - treat files with extention ext1 and ext2 as C files\n");
   fprintf(stderr,"   -d[+|-]             - enable/disable duplex\n");
   fprintf(stderr,"   -hext1,ext2,...     - treat files with extention ext1 and ext2 as H files\n");
   fprintf(stderr,"   -ifile1;file2;...   - imbed files into output\n");
   fprintf(stderr,"   -kk1,k2,...         - treat k1, k2 as reserved (key=c++ adds c++ keywords)\n");
   fprintf(stderr,"   -n#                 - separate line numbers from lines with # spaces\n");
   fprintf(stderr,"   -n0                 - do not generate line numbers\n");
   fprintf(stderr,"   -ofile              - output written to file (instead of stdout)\n");
   fprintf(stderr,"   -p[+|-]             - enable/disable page break at functions\n");
   fprintf(stderr,"   -rfile1;file2,...   - replace default PS procs with contents of files\n");
   fprintf(stderr,"   -snt or -stn        - sort files by name/type or type/name\n");
   fprintf(stderr,"   -t#                 - expand tabs to # columns\n");
   fprintf(stderr,"   -wf1,f2;f3,f4       - prepend files f1, f2 to output, append files f3, f4\n");
   fprintf(stderr,"   -xx,y               - coordinates for page adjustment\n");
   fprintf(stderr,"   -ypath              - path to use for temporary files\n");
   fprintf(stderr,"   -?                  - display this help\n\n");
   fprintf(stderr,"Default options are:\n");
   fprintf(stderr,"   -b+ -d- -cc -hh -n2 -p+ -stn -t4 -x0,0\n");
   fprintf(stderr,"Options may also be set in the environment variable %s.\n",PROGRAM_ENVV);

   exit(1);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * add default key words to reserved hash
 *------------------------------------------------------------------*/
void InitializeReservedHash(
   Info *info,
   char *keyList
   )
   {
   int   i;
   char *part;

   /*---------------------------------------------------------------
    * create hash table
    *---------------------------------------------------------------*/
   info->reservedHash = HashCreate(sizeof(char *),
                                  30,
                                  (HashFunc *)IdentHash,
                                  (ListCompareFunc *)IdentCompare,
                                  cPostNoMem);

   if (!info->reservedHash)
      cPostError(1,"error creating reserved word hash table");

   for (i=0; i<sizeof(ReservedTokens)/sizeof(char *); i++)
      if (!HashAdd(info->reservedHash,&(ReservedTokens[i])))
         cPostError(1,"error adding reserved word '%s' to hash table",
                    ReservedTokens[i]);

   /*---------------------------------------------------------------
    * loop through the comma separated keys ...
    *---------------------------------------------------------------*/
   part = strtok(keyList,",");
   while (part)
      {
      /*------------------------------------------------------------
       * special c++ token
       *------------------------------------------------------------*/
      if (!Stricmp("c++",part))
         {
         for (i=0; i<sizeof(CppReservedTokens)/sizeof(char *); i++)
            if (!HashAdd(info->reservedHash,&(CppReservedTokens[i])))
               cPostError(1,"error adding reserved word '%s' to hash table",
                          CppReservedTokens[i]);

         }

      /*------------------------------------------------------------
       * file name
       *------------------------------------------------------------*/
      else if (('@' == part[0]) && (1 != strlen(part)))
         {
         TokFileInfo  tfi;
         char        *key;

         part++;

         tfi = TokFileOpen(part);

         if (!tfi)
            cPostError(0,"error opening file '%s' for reading",part);

         else
            {
            while (NULL != (part = TokFileNext(tfi)))
               {
               key = malloc(1 + strlen(part));
               if (!key)
                  cPostError(1,"out of memory!!");

               strcpy(key,part);

               if (!HashAdd(info->reservedHash,&key))
                  cPostError(0,"error adding reserved word '%s' to hash table; word ignored",
                                key);
               }
            }
         }

      /*------------------------------------------------------------
       * plain old token
       *------------------------------------------------------------*/
      else if (!HashAdd(info->reservedHash,&part))
         {
         cPostError(0,"error adding reserved word '%s' to hash table; word ignored",part);
         }

      part = strtok(NULL,",");
      }
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * clean up file list
 *------------------------------------------------------------------*/
static int CleanUpFileList(
   File     *file,
   Info     *info
   )
   {
   PageEject *pe;

   if (!(info->oDebug & 1) && (file->tempName))
      remove(file->tempName);

   /*---------------------------------------------------------------
    * free up file fields
    *---------------------------------------------------------------*/
   free(file->name);
   free(file->pathName);

   if (*(file->ext))
      free(file->ext);

   if (file->tempName)
      free(file->tempName);

   /*---------------------------------------------------------------
    * free function lists
    *---------------------------------------------------------------*/
   ListDestroy(file->funcDefList);
   ListDestroy(file->funcProList);

   /*---------------------------------------------------------------
    * free page eject list
    *---------------------------------------------------------------*/
   pe = file->breakList;
   while (pe)
      {
      PageEject *next;

      next = pe->next;
      free(pe);
      pe   = next;
      }

   return 0;
   }

/*------------------------------------------------------------------
 * clean up function list
 *------------------------------------------------------------------*/
static int CleanUpFuncList(
   Function *func,
   Info     *info
   )
   {
   ListDestroy(func->callsList);
   ListDestroy(func->calledByList);

   free(func->name);

   return 0;
   }

/*------------------------------------------------------------------
 * atexit processing
 *------------------------------------------------------------------*/
static void RunAtExit(void)
   {

   if (!AllDone)
      fprintf(stderr,"%s : Program terminated.\n",PROGRAM_NAME);

   /*---------------------------------------------------------------
    * erase any temporary files we might have open
    *---------------------------------------------------------------*/
   if (!AllDone)
      fprintf(stderr,"%s : Cleaning up temporary files.\n",PROGRAM_NAME);

   ListIterate(info.fileList,(ListIterateFunc *)CleanUpFileList,&info);

   /*---------------------------------------------------------------
    * destroy file list
    *---------------------------------------------------------------*/
   ListDestroy(info.fileList);

   /*---------------------------------------------------------------
    * destroy hash tables
    *---------------------------------------------------------------*/
   HashDestroy(info.identHash);
   HashDestroy(info.reservedHash);

   /*---------------------------------------------------------------
    * destroy function list
    *---------------------------------------------------------------*/
   ListIterate(info.funcTree,(ListIterateFunc *)CleanUpFuncList,&info);
   ListDestroy(info.funcTree);

   /*---------------------------------------------------------------
    * dump memory (if debug enabled
    *---------------------------------------------------------------*/
#if defined(__DEBUG_ALLOC__)
   _dump_allocated(0);
#endif
   }

/*------------------------------------------------------------------
 * signal handler for program interruption
 *------------------------------------------------------------------*/
#if defined(OPSYS_LINUX)
void SigHandler(int sig)
#else 
void SignalHandler(int sig)
#endif
   {
   exit(1);
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * print function name symbol defintions
 *------------------------------------------------------------------*/
static int PrintFunctionDefinition(
   Function *func,
   Info     *info
   )
   {
   fprintf(info->oFile,
           ".nameit symbol=fn%4.4d gmltype=hp%c size='+%d' text='%s'\n",
           func->id, '2', 3, func->name);

   return 0;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * compute calls and called bys, replace if > than max
 *------------------------------------------------------------------*/
static int CountFunctionRefs(
   Function *func,
   Info     *info
   )
   {
   int count;

   count  = ListCount(func->callsList);
   count += ListCount(func->calledByList);

   if (count > info->count1)
      info->count1 = count;

   return 0;
   }

/*------------------------------------------------------------------
 * get maximum number of calls and called bys for all the functions
 * so figure out which table to use
 *------------------------------------------------------------------*/
int GetMaxFuncTableEntries(
   Info      *info
   )
   {

   info->count1 = 0;

   ListIterate(info->funcTree,
               (ListIterateFunc *)CountFunctionRefs,
               info);

   return info->count1;
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * parse command line for options
 *------------------------------------------------------------------*/
static void GetOptions(
   int   *argc,
   char  *argv[],
   Info  *info
   )
   {
   int            oHelp;
   char          *oBrack;
   char          *oTabs;
   char          *oCtype;
   char          *oHtype;
#if defined(OPSYS_LINUX)
   char          oSort[10];
#else
   char          *oSort;
#endif
   char          *oFile;
   char          *oSpace;
   char          *oKeys;
   char          *oBreak;
   char          *oTemp;
   char          *oImbed;
   char          *oDuplex;
#if defined(OPSYS_LINUX)
   char          oXlate[80];
#else
   char          *oXlate;
#endif
   char          *numLeft;
   char          *s1;
   char          *s2;
   char          *oWrap;
   char          *oRepHdr;

   /*---------------------------------------------------------------
    * parse arguments
    *---------------------------------------------------------------*/
   parsearg(argc,argv,0,PROGRAM_ENVV,"-",
            "? b@ c@ d@ h@ k@ i@ n@ o@ p@ r@ s@ t@ w@ x@ y@",
            &oHelp,&oBrack,&oCtype,&oDuplex,&oHtype,&oKeys,&oImbed,
            &oSpace,&oFile,&oBreak,&oRepHdr,&oSort,&oTabs,&oWrap,
            &oXlate,&oTemp);

   /*---------------------------------------------------------------
    * check parms
    *---------------------------------------------------------------*/
   if (oHelp || (*argc < 2))
      Usage();

   if ('?' == *argv[1])
      Usage();

   /*---------------------------------------------------------------
    * apply option defaults
    *---------------------------------------------------------------*/
   if ((NULL == oBrack ) || ('\0' == *oBrack ))  oBrack  = "+";
   if ((NULL == oCtype ) || ('\0' == *oCtype ))  oCtype  = "c";
   if ((NULL == oDuplex) || ('\0' == *oDuplex))  oDuplex = "-";
   if ((NULL == oHtype ) || ('\0' == *oHtype ))  oHtype  = "h";
   if ((NULL == oKeys  ) || ('\0' == *oKeys  ))  oKeys   = "";
   if ((NULL == oImbed ) || ('\0' == *oImbed ))  oImbed  = "";
   if ((NULL == oSpace ) || ('\0' == *oSpace ))  oSpace  = "2";
   if ((NULL == oFile  ) || ('\0' == *oFile  ))  oFile   = NULL;
   if ((NULL == oBreak ) || ('\0' == *oBreak ))  oBreak  = "+";
   if ((NULL == oRepHdr) || ('\0' == *oRepHdr))  oRepHdr = "";
#if defined(OPSYS_LINUX)
   if ((NULL == oSort  ) || ('\0' == *oSort  ))  strcpy(oSort,"tn");
#else
   if ((NULL == oSort  ) || ('\0' == *oSort  ))  oSort   = "tn";
#endif
   if ((NULL == oTabs  ) || ('\0' == *oTabs  ))  oTabs   = "4";
   if ((NULL == oWrap  ) || ('\0' == *oWrap  ))  oWrap   = "";
#if defined(OPSYS_LINUX)
   if ((NULL == oXlate ) || ('\0' == *oXlate ))  strcpy(oXlate, "0,0");
#else
   if ((NULL == oXlate ) || ('\0' == *oXlate ))  oXlate  = "0,0";
#endif
   if ((NULL == oTemp  ) || ('\0' == *oTemp  ))  oTemp   = "";

   /*---------------------------------------------------------------
    * bracketing option
    *---------------------------------------------------------------*/
   info->oBrack = (int) strtol(oBrack,NULL,10);
   if (0 == info->oBrack)
      {
      if ((1 != strlen(oBrack)) || (NULL == strchr("-+",*oBrack)))
         cPostError(1,"invalid value on -b option");

      if ('+' == *oBrack)
         info->oBrack = 1000;
      else
         info->oBrack = 0;
      }

   /*---------------------------------------------------------------
    * extensions for C files
    *---------------------------------------------------------------*/
   info->oCtype = oCtype;

   /*---------------------------------------------------------------
    * duplex
    *---------------------------------------------------------------*/
   if ((1 != strlen(oDuplex)) || (NULL == strchr("-+",*oDuplex)))
      cPostError(1,"invalid value on -d option");

   info->oDuplex  = ('+' == *oDuplex);

   /*---------------------------------------------------------------
    * extensions for H files
    *---------------------------------------------------------------*/
   info->oHtype = oHtype;

   /*---------------------------------------------------------------
    * reserved words
    *---------------------------------------------------------------*/
   InitializeReservedHash(info,oKeys);

   /*---------------------------------------------------------------
    * imbed option
    *---------------------------------------------------------------*/
   info->oImbed  = oImbed;

   /*---------------------------------------------------------------
    * space option
    *---------------------------------------------------------------*/
   info->oSpace = (int) strtol(oSpace,&numLeft,10);
   if (*numLeft || (info->oSpace < 0))
      cPostError(1,"invalid value on -n option");

   /*---------------------------------------------------------------
    * output file option
    *---------------------------------------------------------------*/
   if (NULL == oFile)
      info->oFile = stdout;
   else
      {
      info->oFile = fopen(oFile,"w");
      if (NULL == info->oFile)
         cPostError(1,"error opening output file %s for writing",oFile);
      }

   /*---------------------------------------------------------------
    * page break option
    *---------------------------------------------------------------*/
   if ((1 != strlen(oBreak)) || (NULL == strchr("-+",*oBreak)))
      cPostError(1,"invalid value on -p option");

   info->oBreak  = ('+' == *oBreak);

   /*---------------------------------------------------------------
    * replace PS header
    *---------------------------------------------------------------*/
   info->oRepHdr = oRepHdr;

   /*---------------------------------------------------------------
    * sort option
    *---------------------------------------------------------------*/
   if ((0 != Stricmp("nt",oSort)) && (0 != Stricmp("tn",oSort)))
      cPostError(1,"invalid value on -s option");

   info->oSort  = Strupr(oSort);


   /*---------------------------------------------------------------
    * tabs option
    *---------------------------------------------------------------*/
   info->oTabs = (int) strtol(oTabs,NULL,10);
   if (0 == info->oTabs)
      cPostError(1,"invalid value on -t option");

   /*---------------------------------------------------------------
    * wrap PS around output
    *---------------------------------------------------------------*/
   info->oWrapB = strtok(oWrap,";");
   info->oWrapA = strtok(NULL,"");

   /*---------------------------------------------------------------
    * translate option
    *---------------------------------------------------------------*/
   s1 = strtok(oXlate,",");
   s2 = strtok(NULL,"");

   if (!s1 || !s2)
      cPostError(1,"invalid value on -x option");

   info->oXlateX = (int) strtol(s1,NULL,10);
   info->oXlateY = (int) strtol(s2,NULL,10);


   /*---------------------------------------------------------------
    * temp path
    *---------------------------------------------------------------*/
   if (!strlen(oTemp))
      info->oTemp = "";

   else
      {
      char c;

      c = oTemp[strlen(oTemp) - 1];
      if (('\\' == c) || ('/' == c))
         info->oTemp = oTemp;
      else
         {
         info->oTemp = malloc(2+strlen(oTemp));
         strcpy(info->oTemp,oTemp);
         strcat(info->oTemp,"/");
         }
      }

   }

/*------------------------------------------------------------------
 * copy one file stream to another
 *------------------------------------------------------------------*/
void copyFile(
   FILE *fileFrom,
   FILE *fileTo
   )
   {
#define BUFFER_SIZE 8192
   char *buffer;

   /*---------------------------------------------------------------
    * allocate buffer
    *---------------------------------------------------------------*/
   buffer = malloc(BUFFER_SIZE);
   if (!buffer)
      cPostError(1,"out of memory!!");

   /*---------------------------------------------------------------
    * copy file buffer at a time
    *---------------------------------------------------------------*/
   while (!feof(fileFrom))
      {
      int count;
      count = fread(buffer,1,BUFFER_SIZE,fileFrom);
      fwrite(buffer,1,count,fileTo);
      }

   /*---------------------------------------------------------------
    * free the buffer
    *---------------------------------------------------------------*/
   free(buffer);
   }

/*------------------------------------------------------------------
 * process the imbed file option
 *------------------------------------------------------------------*/
void processImbedFile(
   char *imbedFileName
   )
   {
   FILE *file;

   /*---------------------------------------------------------------
    * while we have imbedFileNames
    *---------------------------------------------------------------*/
   imbedFileName = strtok(imbedFileName,";,");
   while (imbedFileName)
      {
      /*------------------------------------------------------------
       * open the imbed file
       *------------------------------------------------------------*/
      file = fopen(imbedFileName,"r");

      /*------------------------------------------------------------
       * print error if not found, or copy it in if found
       *------------------------------------------------------------*/
      if (!file)
         cPostError(0,"unable to open file '%s' for reading",imbedFileName);
      else
         {
         copyFile(file,info.oFile);
         fclose(file);
         }

      /*------------------------------------------------------------
       * get next imbed file name
       *------------------------------------------------------------*/
      imbedFileName = strtok(NULL,";,");
      }
   }

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * main program
 *------------------------------------------------------------------*/
int main(
   int   argc,
   char *argv[]
   )
   {
   int        i;
   char       dateStr[30];
   struct tm *tm;
   time_t     t;
   char      *origParms;

   /*---------------------------------------------------------------
    * check for help
    *---------------------------------------------------------------*/
   if ((1 == argc) || ('?' == *(argv[1])))
      Usage();

   /*---------------------------------------------------------------
    * get original parms
    *---------------------------------------------------------------*/
   origParms  = malloc(1);
   *origParms = 0;

   for (i=0; i<argc; i++)
      {
      origParms = realloc(origParms,2 + strlen(origParms) + strlen(argv[i]));
      strcat(origParms," ");
      strcat(origParms,argv[i]);
      }
   /*---------------------------------------------------------------
    * zero out info
    *---------------------------------------------------------------*/
   memset(&info,0,sizeof(info));

   /*---------------------------------------------------------------
    * get options
    *---------------------------------------------------------------*/
   GetOptions(&argc,argv,&info);
   /*---------------------------------------------------------------
    * buffer output
    *---------------------------------------------------------------*/
/* setvbuf(info.oFile,NULL,_IOFBF,32000); */

   /*---------------------------------------------------------------
    * put filenames in a list
    *---------------------------------------------------------------*/
   info.fileList = ListCreate(sizeof(File),
                              (ListCompareFunc *)FileNameCompare,
                              cPostNoMem);
   if (!info.fileList)
      cPostError(1,"error creating list of files");

   for (i=1; i<argc; i++)
      FileSpecAdd(&info,info.fileList,argv[i]);

   /*---------------------------------------------------------------
    * check for no files to process
    *---------------------------------------------------------------*/
   if (!ListCount(info.fileList))
      cPostError(1,"no files to process");

   /*---------------------------------------------------------------
    * intialize rest of info structure
    *---------------------------------------------------------------*/
   info.funcTree  = ListCreate(sizeof(Function),
                               (ListCompareFunc *)FunctionNameCompare,
                               cPostNoMem);
   if (!info.fileList)
      cPostError(1,"error creating list of functions");

   info.identHash   = HashCreate(sizeof(char *),
                                 1000,
                                 (HashFunc *)IdentHash,
                                 (ListCompareFunc *)IdentCompare,
                                 cPostNoMem);


   if (!info.identHash)
      cPostError(1,"error creating global hash table");

   /*---------------------------------------------------------------
    * setup error termination processing
    *---------------------------------------------------------------*/
   atexit(RunAtExit);
#if defined(OPSYS_LINUX)
   signal(SIGINT,  SigHandler);
   signal(SIGTERM, SigHandler);
#else    
   signal(SIGINT,  SignalHandler);
   signal(SIGTERM, SignalHandler);
#endif   

#if defined(OPSYS_OS2) || defined(OPSYS_OS2V2)
   signal(SIGBREAK,SignalHandler);
#endif

   /*---------------------------------------------------------------
    * print header
    *---------------------------------------------------------------*/
   fprintf(info.oFile,"%%! PostScript file generated by %s %s\n\n",
           PROGRAM_NAME,PROGRAM_VERS);

/*------------------------------------------------------------------
 * a macro to write a line to the output file
 *------------------------------------------------------------------*/
#define p(x) fprintf(info.oFile,"%s\n",x);


   /*---------------------------------------------------------------
    * write command line and environment variable setting
    *---------------------------------------------------------------*/
#if defined(ECHO_COMMAND_LINE)
      {
      p("%%-----------------------------------------------------------------")

      fprintf(info.oFile,"%%%% this file created with the command:\n");
      fprintf(info.oFile,"%%%%   %s\n",origParms);
      fprintf(info.oFile,"%%%% the CPOST environment variable ");
      if (!getenv(PROGRAM_ENVV))
         fprintf(info.oFile,"is not set.\n");
      else
         {
         fprintf(info.oFile,"is set to:\n");
         fprintf(info.oFile,"%%%%   %s\n",getenv(PROGRAM_ENVV));
         }

      p("%%-----------------------------------------------------------------")
      p("");
      }
#endif

   /*---------------------------------------------------------------
    * write wrapper prefix
    *---------------------------------------------------------------*/
   if (info.oWrapB && strlen(info.oWrapB))
      processImbedFile(info.oWrapB);

   /*---------------------------------------------------------------
    * get the time
    *---------------------------------------------------------------*/
   t  = time(NULL);
   tm = localtime(&t);
   strftime(dateStr,sizeof(dateStr)-1,"%m/%d/%y   %H:%M:%S",tm);

   p("%%-----------------------------------------------------------------")
   p("%% runtime options and values")
   p("%%-----------------------------------------------------------------")
   p("")
   fprintf(info.oFile,"/printDate (%s) def\n",dateStr);
   fprintf(info.oFile,"/oSpace %d def\n",info.oSpace);
   fprintf(info.oFile,"/oXlate { %d %d translate } def\n",info.oXlateX,info.oXlateY);
   fprintf(info.oFile,"/oDuplex 1 %d eq def\n",info.oDuplex);
   fprintf(info.oFile,"/oNumber 0 %d ne def\n",info.oSpace);
   p("")

   /*---------------------------------------------------------------
    * write replaced header ...
    *---------------------------------------------------------------*/
   if (info.oRepHdr && strlen(info.oRepHdr))
      {
      processImbedFile(info.oImbed);
      p("");
      processImbedFile(info.oRepHdr);
      p("");
      }

   /*---------------------------------------------------------------
    * or default stuff
    *---------------------------------------------------------------*/
   else
      {
      for (i=0; i< sizeof(Header_1)/sizeof(char *); i++)
         p(Header_1[i]);

      p("");
      processImbedFile(info.oImbed);
      p("");

      for (i=0; i< sizeof(Header_2)/sizeof(char *); i++)
         p(Header_2[i]);

      p("");
      }

   /*---------------------------------------------------------------
    * read the files. make copies
    *---------------------------------------------------------------*/
   fprintf(stderr,"Pass 1\n");
   ListIterate(info.fileList,(ListIterateFunc *)Pass1,&info);

   /*---------------------------------------------------------------
    * read the copies. write the output file
    *---------------------------------------------------------------*/
   fprintf(stderr,"Pass 2\n");
   ListIterate(info.fileList,(ListIterateFunc *)Pass2,&info);

   /*---------------------------------------------------------------*
    * print trailing line feed
    *---------------------------------------------------------------*/
   fprintf(info.oFile,"\n");

   /*---------------------------------------------------------------
    * write wrapper suffix
    *---------------------------------------------------------------*/
   if (info.oWrapA && strlen(info.oWrapA))
      processImbedFile(info.oWrapA);

   /*---------------------------------------------------------------
    * close file (another line feed for luck!)
    *---------------------------------------------------------------*/
   fprintf(info.oFile,"\n");
   fclose(info.oFile);

   AllDone = 1;
   return 0;
   }
