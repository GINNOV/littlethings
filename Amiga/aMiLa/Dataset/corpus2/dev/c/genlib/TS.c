#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <crbinc/inc.h>
#include <crbinc/strutil.h>
#include <crbinc/fileutil.h>
#include <crbinc/matchpat.h>

void ShowFoundMatch(char *BufPos,char *BufBase);

int main(int argc,char *argv[])
{
FILE * FP;
ulong FLen;
char *FBuf,*FBufPtr,*FBufPtrEnd;
char SearchStr[1024];
int SearchStrLen,i;
bool FoundOne=0;
char *FName=NULL;
char *SearchArg=NULL;
bool CaseSensitive = 0;

for(i=1;i<argc && argv[i][0]=='-';i++)
  {
  switch(toupper(argv[i][1]))
    {
    case 'C':
      CaseSensitive = 1;
      break;
    default:
      fprintf(stderr,"Unknown switch: %s\n",argv[i]);
      break;
    }
  }
FName = argv[i++];
SearchArg = argv[i++];

if ( i > argc )
  {
  errputs("TS v1.1 by Charles Bloom, copyright (c) 1995");
  errputs("USAGE: TS [switches] <file> <string>");
  errputs(" <string> may contain Amiga wildcards");
  errputs("if <string> does not contain wildcards, a fast KMP/BM method is used");
  errputs(" <string> may contain C-style escape codes (i.e. \\n)");
  errputs("");
  errputs("[switches] preceded by a '-' are:");
  errputs(" -c : be case sensitive");
  errputs("");
  exit(0);
  }

fprintf(stderr,"TS v1.1 by Charles Bloom,searching:%s\n",argv[1]);

if ( (FP = fopen(FName,"rb")) )
  {
  FLen = FileLengthofFH(FP);
  if ( FBuf = malloc(FLen+2) )
    {
    if ( FRead(FP,FBuf,FLen) == FLen )
      {
      FBuf[FLen] = '\n';
      FBuf[FLen+1] = 0;
      
      if ( strchr(SearchArg,'[') || strchr(SearchArg,'%') )
        strcpy(SearchStr,SearchArg);
      else
        sprintf(SearchStr,SearchArg);
      SearchStrLen = strlen(SearchStr);

      if ( !CaseSensitive )
        { strupr(SearchStr); }

      FBufPtr = FBuf;

      if ( IsWild(SearchStr) )
        {
        /** do it the very slow way **/

        strcat(SearchStr,"*");

        if ( !CaseSensitive )
          {
          int i = FLen;
          while(i--) *FBufPtr++ = toupper(*FBufPtr);
          FBufPtr = FBuf;
          }

        FBufPtrEnd = FBuf + FLen - 1;

        while(FBufPtr<FBufPtrEnd)
          {
          if ( MatchPattern(FBufPtr,SearchStr) )
            {
            FoundOne = 1;
            ShowFoundMatch(FBufPtr,FBuf);
            while(*FBufPtr != '\n') FBufPtr++;
            }
          FBufPtr++;
          }
        }
      else
        {
        char * FBufPtrTail = FBufPtr + SearchStrLen - 1;
        bool IsInSearchStr[256];
        int i;
        char *SearchStrPtr,*SearchStrDone;

        /** do it the fast way **/

        for(i=256;--i;) IsInSearchStr[i]=0;
        IsInSearchStr[0]=0;

        for(SearchStrPtr = SearchStr;*SearchStrPtr;SearchStrPtr++)
          IsInSearchStr[*SearchStrPtr] = 1;

        SearchStrDone = SearchStr + SearchStrLen;

        FBufPtrEnd = FBuf + FLen - SearchStrLen;

        if ( ! CaseSensitive )
          {
          while(FBufPtr<FBufPtrEnd)
            {
            if ( !IsInSearchStr[toupper(*FBufPtrTail)] )
              { FBufPtr += SearchStrLen; FBufPtrTail += SearchStrLen; }
            else
              {
              if ( toupper(*FBufPtr) == *SearchStr )
                {
                FBufPtr++; SearchStrPtr = SearchStr+1;
                while(toupper(*FBufPtr) == *SearchStrPtr++)
                  {
                  FBufPtr++;
                  if ( SearchStrPtr == SearchStrDone )
                    {
                    FoundOne = 1;
                    ShowFoundMatch(FBufPtr,FBuf);
                    SearchStrPtr = SearchStr;
                    while(*FBufPtr++ != '\n') ;
                    }
                  }
                FBufPtrTail = FBufPtr + SearchStrLen - 1;
                }
              else
                { FBufPtr++; FBufPtrTail++; }
              }
            }
          }
        else
          {
          while(FBufPtr<FBufPtrEnd)
            {
            if ( !IsInSearchStr[*FBufPtrTail] )
              { FBufPtr += SearchStrLen; FBufPtrTail += SearchStrLen; }
            else
              {
              if ( *FBufPtr == *SearchStr )
                {
                FBufPtr++; SearchStrPtr = SearchStr+1;
                while(*FBufPtr++ == *SearchStrPtr++)
                  {
                  if ( SearchStrPtr == SearchStrDone )
                    {
                    FoundOne = 1;
                    ShowFoundMatch(FBufPtr,FBuf);
                    SearchStrPtr = SearchStr;
                    }
                  }
                FBufPtrTail = FBufPtr + SearchStrLen - 1;
                }
              else
                { FBufPtr++; FBufPtrTail++; }
              }
            }
          }
        }
      }
    else
      fprintf(stderr,"fread:%s short",FName);

    free(FBuf);
    }
  else
    fprintf(stderr,"malloc :%lu failed",FLen);
  fclose(FP);
  }
else
  fprintf(stderr,"fopen:%s failed",FName);

if ( FoundOne )
  {
  errputs("Press a key to continue");
  getc(stdin);
  }

return(0);
}

void ShowFoundMatch(char *BufPtr,char *BufBase)
{
char FoundLine[1024];
char * FLP;
int LineNumber;

LineNumber = 0;
while ( BufBase < BufPtr )
  if ( *BufBase++ == '\n' ) LineNumber++;

while(*BufPtr != '\n' && BufPtr >= BufBase) BufPtr--;
strncpy(FoundLine,BufPtr+1,1024);

if ( strchr(FoundLine,'\n') )
  *(strchr(FoundLine,'\n')) = 0;
if ( strchr(FoundLine,'\r') )
  *(strchr(FoundLine,'\r')) = 0;

while ( strchr(FoundLine,'\t') ) *(strchr(FoundLine,'\t')) = ' ';

FLP = FoundLine;
while( *FLP == ' ' ) FLP++;

  {
  char *EOLs;
  EOLs = FLP;
  while(*EOLs) EOLs++;
  EOLs--;
  while(*EOLs==' ')EOLs--;
  *(++EOLs) = 0;
  }

printf("%5d:%s\n",LineNumber,FLP);
}
