#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <crbinc/inc.h>

/**

only Amiga and PC paths are supported! no UNIX no Mac !

this doesn't affect you if you don't use CatPaths() or FilePart()
  or libs that use them, such as Walker()

**/

#ifdef _AMIGA /* defined by SAS/C */
#define PathDelim '/'
#else
#define PathDelim '\\'
#endif

void CatPaths(char *Base,char *Add)
{
char * EndBase = &Base[strlen(Base)-1];

if ( *EndBase != ':' && *EndBase != PathDelim )
  {
  EndBase++;
  *EndBase++ = PathDelim;
  *EndBase = 0;
  }
strcat(EndBase,Add);
}

ulong FileLengthofFH(FILE * fh)
{
long start,end;
start = ftell(fh);
fseek(fh,0,SEEK_END);
end = ftell(fh);
fseek(fh,start,SEEK_SET);
return((ulong)end);
}

char * FilePart(char *F);

void PathPartInsert(char *F,char *Insert)
{
char * FP;
strcpy(Insert,F);
FP = FilePart(Insert);
if ( FP ) *FP = 0; 
return;
}

char PathPartRet[1024];
char * PathPart(char *F)
{
PathPartInsert(F,PathPartRet);
return(PathPartRet);
}

char * FilePart(char *F)
{
char *a;

if ( a = strrchr(F,PathDelim) )
  return(a+1);

if ( a = strrchr(F,':') )
  return(a+1);

return(F);
}

bool NameIsDir(char *Name)
{
struct stat st;
char * NamePath;

if ( stat(Name,&st) == 0 )
  {
  if ( S_ISDIR(st.st_mode) ) return(1);
  }

if ( NamePath = malloc(strlen(Name)+1) )
  {
  PathPartInsert(Name,NamePath);
  
  if ( (strlen(Name) - strlen(NamePath)) == 1 )
    {
    if ( stat(NamePath,&st) == 0 )
      {
      if ( S_ISDIR(st.st_mode) )
        { free(NamePath); return(1); }
      }
    }
  free(NamePath);
  }

return(0);
}
