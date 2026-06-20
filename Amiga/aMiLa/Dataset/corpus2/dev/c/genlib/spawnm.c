
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <crbinc/inc.h>
#include <crbinc/fileutil.h>
#include <crbinc/strutil.h>

#include <crbinc/walker.h>
#include <crbinc/matchpat.h>

/* defaults */
char * PatStr = NULL;
char CommandStr[1024];

bool FileFunc(struct WalkInfo * WI)
{
if ( MatchPatternNoCase(WI->Name,PatStr) )
  {
  long Ret;
  char CommandWork[1024];
  char *CommandWorkPtr=CommandWork,*CommandStrPtr=CommandStr;

  while(*CommandStrPtr)
    {
    if ( *CommandStrPtr == '$' )
      {
      strcpy(CommandWorkPtr,WI->Name);
      while(*CommandWorkPtr) CommandWorkPtr++;
      CommandStrPtr++;
      }
    else if ( *CommandStrPtr == '@' )
      {
      strcpy(CommandWorkPtr,WI->Path);
      while(*CommandWorkPtr) CommandWorkPtr++;
      CommandStrPtr++;
      }
    else if ( *CommandStrPtr == ' ' && CommandStrPtr[1] == '+' )
      {
      CommandStrPtr++;
      }
    else if ( *CommandStrPtr == '+' )
      {
      CommandStrPtr++;
      if (*CommandStrPtr == ' ') CommandStrPtr++;
      }
    else
      {
      *CommandWorkPtr++ = *CommandStrPtr++;
      }
    }
  *CommandWorkPtr = 0;

  Ret = system(CommandWork);
  if ( Ret == -1 )
    {
    perror("system failed");
    return(0);
    }
  else if ( Ret != 0 )
    {
    int c;
    fprintf(stderr,">> %s << failed!\n",CommandWork);
    fprintf(stderr,"Quit(Y) or keep going(N) ?"); fflush(stderr);
    c = getc(stdin);
    if ( c != '\n' ) getc(stdin);
    if ( c == 'n' || c == 'N' ) return(1);
    return(0);
    }
  return(1);
  }
return(1);
}

int main(int argc,char *argv[])
{
int i;
bool RecurseFlag,DoDirsFlag;
char * PatArg = NULL;
bool GotCommand = 0;

DoDirsFlag = RecurseFlag = 0;

if ( argc < 2 || argv[1][0] == '?' || ( argv[1][0] == '-' && argv[1][1] == '?' ) 
    || ( argv[1][0] == '-' && tolower(argv[1][1]) == 'h' ) )
  {
  errputs("SpawnM v1.0 by Charles Bloom, copyright(c) 1996");
  errputs("USAGE: SpawnM [spawnm flags] <taskname> <taskparam1> [taskparam2...]");
  errputs("SpawnM will launch <taskname> for all files in a directory.");
  errputs("SpawnM flags are:");
  errputs("  -r  recurse into subdirectories from current path");
  errputs("  -d  don't exclude directories");
  errputs("");
  errputs("The first pattern-match characters in <params> will be used");
/*
  errputs("subsequent pattern-match characters will be properly renamed"); 
*/
  errputs("");
  errputs("All @ characters will be replaced by the path");
  errputs("All $ characters will be replaced by the file name");
  errputs("All + characters eat the spaces near them");
  errputs(" e.g. spawnm @+ ram:*");
  errputs("note: the combination @$ should be used in conjunction with -d");
  errputs("");
  errputs("use '' around <taskparam> to pass quotes to <taskname>");
  errputs("use quotes around redirection and pipes to pass them <taskname>");
  errputs("");
/**
  errputs(" proper renaming example:");
  errputs("in a dir with files 'ab','ac','bc' ");
  errputs("  spawnm echo > a* *");
  errputs("   > ab b");
  errputs("   > ac c");
  errputs("  spawnm echo > a* b*");
  errputs("   > ab bb");
  errputs("   > ac bc");
  errputs("  spawnm echo > *c a*");
  errputs("   > ac ac");
  errputs("   > bc ac");
**/
  exit(0);
  }

for(i=1;i<argc;i++)
  {
  if ( !GotCommand )
    {
    if ( argv[i][0] == '-' )
      {
      char * ArgStr;
      ArgStr = &argv[i][2];
      if ( *ArgStr == ':' || *ArgStr == '=' ) ArgStr++;
  
      switch(toupper(argv[i][1]))
        {
        case 'D':
          DoDirsFlag = 1;
          errputs("Not excluding dirs");
          break;
  
        case 'R': 
          RecurseFlag = 1;
          errputs("Recursing into directories");
          break;
  
        default:
          printf(">>> unknown switch: %c , ignored\n",argv[i][1]);
          break;
        }
      }
    else
      {
      strcpy(CommandStr,argv[i]);
      GotCommand = 1;
      }
    }
  else
    {
    strcat(CommandStr," ");
    if ( PatArg == NULL && IsWild(argv[i]) )
      {
      PatArg = argv[i];
      strcat(CommandStr,"$");
      }
    else
      strcat(CommandStr,argv[i]);
    }
  }

  {
  char * str = CommandStr;
  while(str=strchr(str,39)) *str='"'; /*39 is '*/
  }

if ( !PatArg )
  {
  errputs("No wilds!");
  exit(10);
  }

PatStr = FilePart(PatArg);
if ( ! WalkDir(PathPart(PatArg),RecurseFlag,DoDirsFlag,
  FileFunc,NULL,NULL) )
  puts(">>>>>>WalkDir error!<<<<<<<");

return(0);
}
