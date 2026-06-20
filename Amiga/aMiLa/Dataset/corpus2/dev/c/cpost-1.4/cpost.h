/*------------------------------------------------------------------
 * cpost.h : include file for cPost
 *------------------------------------------------------------------
 * 10-10-91 originally by Patrick J. Mueller
 * 12-03-92 converted from cBook to cPost
 *------------------------------------------------------------------*/

#include "list.h"
#include "hash.h"

/*------------------------------------------------------------------
 * additional token types
 *------------------------------------------------------------------*/
#define TOKEN_LBRACE -1
#define TOKEN_RBRACE -2
#define TOKEN_LPAREN -3
#define TOKEN_RPAREN -4

#define TOKEN_FUNPRO -5
#define TOKEN_FUNUSE -6
#define TOKEN_FUNDEF -7

#define TOKEN_RESER  -8

#define TOKEN_SCOLON -9
#define TOKEN_COMMA  -10

/*------------------------------------------------------------------
 * number of lines to buffer in at a time
 *------------------------------------------------------------------*/
#define FILE_LINES 256

/*------------------------------------------------------------------
 * max length of line
 *------------------------------------------------------------------*/
#define MAX_LINE_LEN 4096

/*------------------------------------------------------------------
 * typedefs
 *------------------------------------------------------------------*/

/*------------------------------------------------------------------
 * page eject
 *------------------------------------------------------------------*/
typedef struct PageEject
   {
   unsigned long     lineNo;
   struct PageEject *next;
   } PageEject;

/*------------------------------------------------------------------
 * token structure
 *------------------------------------------------------------------*/
typedef struct Tok
   {
   int         nestParen;
   int         nestBrace;
   int         extType;
   int         flags;
   char       *str;
   struct Tok *sib;
   struct Tok *next;
   Token       tok;
   } Tok;

/*------------------------------------------------------------------
 * a file entry for a list of files
 *------------------------------------------------------------------*/
typedef struct File
   {
   char            *name;
   char            *pathName;
   char            *tempName;
   char            *ext;
   int              type;
   int              maxLineLen;
   char           **line;
   unsigned long    lines;
   unsigned long    cline;
   List            *funcDefList;
   List            *funcProList;
   Tok             *tokList;
   char             date[9];
   char             time[9];
   Hash            *identHash;
   PageEject       *breakList;
   } File;

/*------------------------------------------------------------------
 * information about a function
 *------------------------------------------------------------------*/
typedef struct Function
   {
   char            *name;
   char            *fileName;
   unsigned long    lineNo;
   int              id;
   int              spotted;
   List            *callsList;
   List            *calledByList;
   } Function;

/*------------------------------------------------------------------
 * formatting options
 *------------------------------------------------------------------*/
typedef struct
   {
   char *fontNormal   ; int sizeNormal   ;
   char *fontKeyword  ; int sizeKeyword  ;
   char *fontFunction ; int sizeFunction ;
   char *fontComment  ; int sizeComment  ;
   char *fontPreproc  ; int sizePreproc  ;
   char *fontLineNo   ; int sizeLineNo   ;

   char *fontHeader;

   int   pageLen;
   int   pageWid;

   int   hMargin;
   int   tMargin;
   int   bMargin;
   int   lMargin;
   } Format;

/*------------------------------------------------------------------
 * global control block
 *------------------------------------------------------------------*/
typedef struct Info
   {
   List            *fileList;
   List            *funcTree;
   FILE            *oFile;
   Hash            *identHash;
   Hash            *reservedHash;
   int              indent1;
   int              count1;
   int              count2;
   Format           format;

   char            *oHtype;
   char            *oCtype;
   int              oTabs;
   char            *oTemp;
   int              oDebug;
   char            *oSort;
   int              oBrack;
   int              oDuplex;
   char            *oImbed;
   int              oSpace;
   int              oBreak;
   int              oXlateX;
   int              oXlateY;
   char            *oWrapB;
   char            *oWrapA;
   char            *oRepHdr;
   } Info;

/*------------------------------------------------------------------
 * global variables
 *------------------------------------------------------------------*/
#if defined(DEFINE_GLOBALS)
          Info info;
#else
   extern Info info;
#endif

/*------------------------------------------------------------------
 * some stuff for c/370
 *------------------------------------------------------------------*/
#if defined(OPSYS_CMS)
   #define FileNameCompare              fncomp
   #define FileSpecAdd                  fsadd
   #define FileReadLines                frline
   #define GetBlockOfFile               gbofile
   #define InitCAttrs                   icattr
   #define FunctionNameCompare          fnccomp
   #define FunctionNamePtrCompare       fncpcomp
   #define GetFunction                  getfnc
   #define PrintFunctionPtrInfo         pfpinf
   #define PrintFunctionInfo            pfinf
   #define TempFileName                 tfname
   #define IsTempFileName               itfname
   #define cPostError                   cperror
#endif

#if !defined(max)
   #define max(x,y) ((x) > (y) ? (x) : (y))
#endif

#if !defined(min)
   #define min(x,y) ((x) < (y) ? (x) : (y))
#endif

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * pass 1 of cPost
 *------------------------------------------------------------------*/
int Pass1(
   File     *file,
   Info     *info
   );

/*------------------------------------------------------------------
 * pass 2 of cPost
 *------------------------------------------------------------------*/
int Pass2(
   File     *file,
   Info     *info
   );

/*-/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\-*/
/*-\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-*/

/*------------------------------------------------------------------
 * utility functions
 *------------------------------------------------------------------*/

/*------------------------------------------------------------------
 * compare two file names
 *------------------------------------------------------------------*/
int FileNameCompare(
   File *name1,
   File *name2
   );

/*------------------------------------------------------------------
 * add a file name to the filename list
 *------------------------------------------------------------------*/
void FileSpecAdd(
   Info      *info,
   List      *fileList,
   char      *fileSpec
   );

/*------------------------------------------------------------------
 * hash an identifier
 *------------------------------------------------------------------*/
int IdentHash(
   char     **str,
   int        hashSize
   );

/*------------------------------------------------------------------
 * compare two strings indirectly
 *------------------------------------------------------------------*/
int IdentCompare(
   char **str1,
   char **str2
   );

/*------------------------------------------------------------------
 * read file into array of lines
 *------------------------------------------------------------------*/
File *FileReadLines(
   Info *info,
   File *file
   );

/*------------------------------------------------------------------
 * return bytes from the file, conveniently a line at a time
 *------------------------------------------------------------------*/
unsigned long GetBlockOfFile(
   void  *readInfo,
   char **buffer
   );

/*------------------------------------------------------------------
 * compare two function names
 *------------------------------------------------------------------*/
int FunctionNameCompare(
   Function *func1,
   Function *func2
   );

int FunctionNamePtrCompare(
   Function **func1,
   Function **func2
   );

/*------------------------------------------------------------------
 * get function (add if needed) from global function table
 *------------------------------------------------------------------*/
Function *GetFunction(
   Info          *info,
   char          *name
   );

/*------------------------------------------------------------------
 * dump function information
 *------------------------------------------------------------------*/
int PrintFunctionPtrInfo(
   Function **func,
   Info      *info
   );

/*------------------------------------------------------------------
 * dump function information
 *------------------------------------------------------------------*/
int PrintFunctionInfo(
   Function *func,
   Info     *info
   );

/*------------------------------------------------------------------
 * generate a temporary file name
 *------------------------------------------------------------------*/
char *TempFileName(
   FILE **file,
   Info  *info
   );

/*------------------------------------------------------------------
 * check for temporary file name
 *------------------------------------------------------------------*/
int IsTempFileName(
   char *name
   );

/*------------------------------------------------------------------
 * compare strings case insensitively
 *------------------------------------------------------------------*/
int Stricmp(
   char *str1,
   char *str2
   );

/*------------------------------------------------------------------
 * compare strings case insensitively
 *------------------------------------------------------------------*/
int Memicmp(
   char *str1,
   char *str2,
   int   len
   );

/*------------------------------------------------------------------
 * upper case a string
 *------------------------------------------------------------------*/
char *Strupr(
   char *str
   );

/*------------------------------------------------------------------
 * reverse a string
 *------------------------------------------------------------------*/
char *Strrev(
   char *str
   );

/*------------------------------------------------------------------
 * generate an error message and exit
 *------------------------------------------------------------------*/
void cPostError(
   int   exitCode,
   char *format,
   ...
   );

/*------------------------------------------------------------------
 * print out of memory message and exit
 *------------------------------------------------------------------*/
void cPostNoMem(
   void
   );

/*------------------------------------------------------------------
 * parse file
 *------------------------------------------------------------------*/
void cParse(
   File     *file,
   Info     *info
   );

/*------------------------------------------------------------------
 * clean up after parsing file
 *------------------------------------------------------------------*/
void cParseDone(
   File     *file,
   Info     *info
   );

