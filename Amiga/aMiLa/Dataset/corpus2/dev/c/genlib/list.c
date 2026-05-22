
/***

todo: support columns

      support %t and %a

****/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <crbinc/inc.h>
#include <crbinc/fileutil.h>
#include <crbinc/strutil.h>

#include <crbinc/walker.h>
#include <crbinc/matchpat.h>
#include <crbinc/sortnods.h>

/* defaults */
char * PatStr = "*";
bool ShowDirNames=0,ShowDirStats = 0;
int NumFileColumns=2,NumDirColumns=1;
char * DirFormatStr  = " %f (dir)";
char * FileFormatStr = "%f  %7z";

char DIR_HEADER = 'a';
char FILE_HEADER = 'b'; /* sets sort order : dirs first or files first */

/* globals */
SortNode * SortNodeBase = NULL;
int NumSpaces;
int FileColumnWidth,DirColumnWidth;
int FileNameWidth=30,DirNameWidth;
ulong DirNumFiles,DirNumDirs,DirTotSize;

void DirStartFunc(char * FullPath,int NestLevel)
{
int i = NestLevel<<1;
NumSpaces = i + 3;

if ( ShowDirNames )
  {
  puts("");
  while(i--) putc(' ',stdout);
  printf("%-s\n",FullPath);
  }
DirNumFiles=DirNumDirs=DirTotSize=0;
}

void DirDoneFunc(void)
{
SortNode *CurSortNode,*NextSortNode;
int i;
Sort_List(&SortNodeBase);
CurSortNode = SortNodeBase;
while(CurSortNode)
  {
  for(i=NumSpaces;i--;) putc(' ',stdout);
  printf("%-s\n",(((char *)CurSortNode->Data)+1));
  NextSortNode = CurSortNode->Next;
  free(CurSortNode->Data);
  free(CurSortNode);
  CurSortNode = NextSortNode;
  }
SortNodeBase = NULL;

if ( ShowDirStats )
  {
  for(i=NumSpaces-1;i--;) putc(' ',stdout);
  printf("%lu dirs - %lu files - %lu bytes occupied\n",DirNumDirs,DirNumFiles,DirTotSize);
  }
}

bool FileFunc(struct WalkInfo * WI)
{
if ( MatchPatternNoCase(WI->Name,PatStr) )
  {
  SortNode *CurSortNode;
  if ( CurSortNode = malloc(sizeof(SortNode)) )
    {
    if ( CurSortNode->Data = malloc(strlen(WI->Name)+128) )
      {
      char *OutStr = (char *)CurSortNode->Data;
      if ( WI->IsDir )
        {
        char *DirFormatStrPtr;
        *OutStr++ = DIR_HEADER;

        DirNumDirs++;

        DirFormatStrPtr = DirFormatStr;
        while(*DirFormatStrPtr)
          {
          if ( *DirFormatStrPtr == '%' )
            {
            DirFormatStrPtr++;
            if ( *DirFormatStrPtr == 'f' || *DirFormatStrPtr == 'F' )
              {
              char * InsStr = WI->Name;
              while(*InsStr) *OutStr++ = *InsStr++;
              }
            DirFormatStrPtr++;
            }
          else
            *OutStr++ = *DirFormatStrPtr++;
          }
        *OutStr = 0;
        }
      else
        {
        char *FileFormatStrPtr,*InsStr;
        int StrLen;

        DirNumFiles++;
        DirTotSize += WI->Size;

        *OutStr++ = FILE_HEADER;

        FileFormatStrPtr = FileFormatStr;
        while(*FileFormatStrPtr)
          {
          if ( *FileFormatStrPtr == '%' )
            {
            FileFormatStrPtr++;
            switch(*FileFormatStrPtr)
              {
              case 'F':
              case 'f':
                FileFormatStrPtr++;
                InsStr = WI->Name;
                StrLen=0;
                while ( *InsStr ) { *OutStr++ = *InsStr++; StrLen++; }
                while ( StrLen < FileNameWidth ) { *OutStr++ = ' '; StrLen++; }
                break;
              case 'P':
              case 'p':
                FileFormatStrPtr++;
                InsStr = WI->Path;
                while(*InsStr) *OutStr++ = *InsStr++;
                break;
              case 'T':
              case 't':
                FileFormatStrPtr++;
                InsStr = "time"; /*<>*/
                while(*InsStr) *OutStr++ = *InsStr++;
                break;
              case 'A':
              case 'a':
                FileFormatStrPtr++;
                InsStr = "att"; /*<>*/
                while(*InsStr) *OutStr++ = *InsStr++;
                break;

              default: /* %+-nU */
                {
                char * Upos;
                Upos = strchr(FileFormatStrPtr,'u');
                if ( Upos && (Upos - FileFormatStrPtr) < 5 )
                  {
                  char SaveC = *(Upos + 1); *(Upos + 1) = 0;
                  sprintf(OutStr,FileFormatStrPtr-1,(ulong)WI->Size);
                  FileFormatStrPtr = Upos + 1;
                  *FileFormatStrPtr = SaveC;
                  while(*OutStr) OutStr++;
                  }
                else
                  {
                  FileFormatStrPtr++;
                  }
                break;
                }
              }
            }
          else
            {
            *OutStr++ = *FileFormatStrPtr++;
            }
          }
        *OutStr = 0;
        }

      CurSortNode->Index = *((ulong *)CurSortNode->Data);
      CurSortNode->MoreIndexPtr = (((ubyte *)CurSortNode->Data)+4);
      CurSortNode->Next = SortNodeBase;
      SortNodeBase = CurSortNode;
      }
    else free(CurSortNode);
    }
  }

return(1);
}

int main(int argc,char *argv[])
{
int i,numdirs;
bool RecurseFlag,WantsHelp;
char FileFormatWork[1024];

RecurseFlag = 0;
WantsHelp = 0;
numdirs = argc-1;

for(i=1;i<argc;i++)
  {
  if ( argv[i][0] == '-' )
    {
    char * ArgStr;
    numdirs--;
    ArgStr = &argv[i][2];
    if ( *ArgStr == ':' || *ArgStr == '=' ) ArgStr++;

    switch(toupper(argv[i][1]))
      {
      case '?':
      case 'H':
        WantsHelp = 1;
        break;

      case 'S':
        ShowDirStats = 1;
        break;

      case 'R': 
        RecurseFlag = 1;
        break;

      case 'F':
        FileFormatStr = ArgStr;
        break;

      case 'D':
        DirFormatStr = ArgStr;
        break;

      case 'C':
        if ( toupper(argv[i][2]) == 'F' )
          {
          ArgStr = &argv[i][3];
          if ( *ArgStr == ':' || *ArgStr == '=' ) ArgStr++;
          NumFileColumns = atoi(ArgStr);
          }
        else if ( toupper(argv[i][2]) == 'D' )
          {
          ArgStr = &argv[i][3];
          if ( *ArgStr == ':' || *ArgStr == '=' ) ArgStr++;
          NumDirColumns = atoi(ArgStr);
          }
        else
          NumFileColumns = NumDirColumns = atoi(ArgStr);
        break;

      default:
        printf(">>> unknown switch: %c , ignored\n",argv[i][1]);
        break;
      }
    }
  }

if ( WantsHelp )
  {
  puts("List v1.0 by Charles Bloom, copyright (c) 1996");
  puts(" a powerful, flexible dir lister, inspired by the Amiga");
  puts(" ");
  puts("USAGE : List -[switches] [path1] [path2] ..");
  puts(" switches are preceded by a '-' and may be anywhere");
  puts(" if no paths are specified, the current dir is shown");
  puts(" paths may contain powerful Amiga-style intelligent wildcards");
  puts(" ");
  puts("SWITCHES:");
  puts(" s       : show entire-dir stats (numfiles,total size)");
  puts(" r       : recurse into subdirectories");
  puts(" c<#>    : set number of columns");
  puts(" cf<#>   :  set number of columns for file display");
  puts(" cd<#>   : set number of columns for dir display");
  puts(" f<Str>  : file list format string");
  puts(" d<Str>  : file list format string");
  puts(" ");

  puts("Press a key for more");
  getc(stdin);

  puts("FORMAT STRINGS:");
  puts(" use quotes around format strings to preserve spaces");
  puts(" %f      : inserts file name");
  puts(" %p      : insert file path (with ending delimiter)");
  puts(" %z      : inserts file size");
  puts(" %t      : inserts file date/time");
  puts(" %a      : inserts file attributes");
  puts("only %f is active for directories");
  puts("C-style formating is supported on %z (i.e. %-5z)");
  puts(" ");
  printf("Default DirFormat : '%s'  , %d columns",DirFormatStr,NumDirColumns);
  printf("Default FileFormat : '%s' , %d columns",FileFormatStr,NumFileColumns);
  puts(" ");
  exit(0);
  }

if ( RecurseFlag || numdirs > 1 )
  ShowDirNames = 1;
else
  ShowDirNames = 0;

FileColumnWidth = 70/NumFileColumns;
DirColumnWidth = 70/NumDirColumns;

/* int FileNameWidth,DirNameWidth; <> 
  set = columnwidth - NumCharsNotF 
must count %z, etc. chars & literals
*/

if ( strichr(FileFormatStr,'z') )
  {
  char * Zpos = FileFormatWork;
  strcpy(FileFormatWork,FileFormatStr);
  while( Zpos = strichr(Zpos,'z') )
    {
    *Zpos = 'u';
    strins(Zpos,"l");
    }
  FileFormatStr = FileFormatWork;
  }

if ( numdirs == 0 )
  {
  PatStr = "*";
  if ( ! WalkDir(NULL,RecurseFlag,1,FileFunc,DirStartFunc,DirDoneFunc) )
    puts(">>>>>>WalkDir error!<<<<<<<");
  }
else
  {
  for(i=1;i<argc;i++)
    {
    if ( argv[i][0] != '-' )
      {
      PatStr = FilePart(argv[i]);
      if ( *PatStr == 0 ) PatStr = "*";
      if ( ! WalkDir(PathPart(argv[i]),RecurseFlag,1,
        FileFunc,DirStartFunc,DirDoneFunc) )
        puts(">>>>>>WalkDir error!<<<<<<<");
      }
    }
  }

return(0);
}
