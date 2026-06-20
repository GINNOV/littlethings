#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <crbinc/inc.h>
#include <crbinc/fileutil.h>

struct WalkInfo
  {
  char * Name;
  char * Path; /* contains ending path delimiter */
  int NestLevel;
  bool IsDir;
  ulong Size;
  ulong Attr;
  ulong Date;
  };

struct WalkState
  {
  struct WalkState * Next;
  char Path[1024];
  int NestLevel;
  };

typedef bool (*FileFuncType)(struct WalkInfo * WI); /* returns KeepGoing */
typedef bool (*DirStartFuncType)(char * FullPath,int NestLevel);
typedef bool (*DirDoneFuncType)(void);

bool WalkDir(char *StartPath,bool RecurseFlag,bool DoDirs,
  FileFuncType FileFunc,DirStartFuncType DirStartFunc,DirDoneFuncType DirDoneFunc)
{
struct WalkState *CurState,*NextState,*GotState;
DIR * DFD;
struct dirent * DE;
struct stat EntryStat;
struct WalkInfo EntryWI;
bool Ok = 1;
char WasInDir[1024];
bool KeepGoing=1;

if ( !getcwd(WasInDir,1024) )
  return(0);

if ( (CurState = malloc(sizeof(struct WalkState))) == NULL )
  return(0);
CurState->Next = NULL;
CurState->NestLevel = 0;

if ( !StartPath )
  {
  strcpy(CurState->Path,WasInDir);
  }
else
  {
  chdir(StartPath);
  if ( !getcwd(CurState->Path,1024) )
    { free(CurState); return(0); }
  }

while( CurState )
  {
  GotState = CurState;
  CurState = CurState->Next;

  if ( KeepGoing )
    {
    if ( DFD = opendir(GotState->Path) )
      {
      if ( chdir(GotState->Path) == 0 )
        {
        if ( DirStartFunc ) KeepGoing = (*DirStartFunc)(GotState->Path,GotState->NestLevel);
  
        CatPaths(GotState->Path,"");

        while ( KeepGoing && (DE = readdir(DFD)) )
          {
          if ( stat(DE->d_name,&EntryStat) == 0 )
            {
        
            EntryWI.Name = DE->d_name;
            EntryWI.Path = GotState->Path;
            EntryWI.NestLevel = GotState->NestLevel;
            EntryWI.Size = EntryStat.st_size; /* <> not accurate on PCs */
            EntryWI.Attr = EntryStat.st_mode;
            EntryWI.Date = EntryStat.st_mtime;
            EntryWI.IsDir = S_ISDIR(EntryStat.st_mode);

            if ( DoDirs || !EntryWI.IsDir )
              KeepGoing = (*FileFunc)(&EntryWI);
  
            if ( KeepGoing )
              {
              if ( EntryWI.IsDir && RecurseFlag )
                {
                if ( (NextState = malloc(sizeof(struct WalkState))) != NULL )
                  {
                  NextState->NestLevel = GotState->NestLevel + 1;
                  strcpy(NextState->Path,GotState->Path);
                  strcat(NextState->Path,EntryWI.Name);
                  NextState->Next = CurState;
                  CurState = NextState;
                  }
                else Ok = 0;
                }
              }
            }
          else Ok = 0;
          }
        closedir(DFD); DFD = NULL;
        if ( KeepGoing )
          {
          if ( DirDoneFunc ) KeepGoing = (*DirDoneFunc)();
          }
        }
      else Ok = 0;
  
      if ( DFD) closedir(DFD);
      }
    else Ok = 0;
    }

  free(GotState);
  }

chdir(WasInDir);

return(Ok);
}

/***

normal WalkDir processes directories, then steps into them

this version processes all directories, then steps back from the deepest

this is needed by Delete

**/

bool WalkDir_DeepFirst(char *StartPath,bool RecurseFlag,bool DoDirs,
  FileFuncType FileFunc,DirStartFuncType DirStartFunc,DirDoneFuncType DirDoneFunc)
{
struct WalkState *CurState,*NextState,*GotState;
DIR * DFD;
struct dirent * DE;
struct stat EntryStat;
struct WalkInfo EntryWI;
bool Ok = 1;
char WasInDir[1024];
bool KeepGoing=1;

if ( !getcwd(WasInDir,1024) )
  return(0);

if ( (CurState = malloc(sizeof(struct WalkState))) == NULL )
  return(0);
CurState->Next = NULL;
CurState->NestLevel = -1;

if ( !StartPath )
  {
  strcpy(CurState->Path,WasInDir);
  }
else
  {
  chdir(StartPath);
  if ( !getcwd(CurState->Path,1024) )
    { free(CurState); return(0); }
  }

if ( RecurseFlag)
  {
  struct WalkState * ListHead = CurState;
  GotState = CurState;

  do
    {

    if ( KeepGoing )
      {
      if ( DFD = opendir(GotState->Path) )
        {
        if ( chdir(GotState->Path) == 0 )
          {
  
          while ( DE = readdir(DFD) )
            {
            if ( stat(DE->d_name,&EntryStat) == 0 )
              {
              if ( S_ISDIR(EntryStat.st_mode) )
                {
                if ( (NextState = malloc(sizeof(struct WalkState))) != NULL )
                  {
                  NextState->NestLevel = GotState->NestLevel - 1;
                  strcpy(NextState->Path,GotState->Path);
  
                  CatPaths(GotState->Path,"");
      
                  strcat(NextState->Path,DE->d_name);
                  NextState->Next = ListHead;
                  ListHead = NextState;
                          }
                }
              }
            else Ok = 0;
            }
          }
        else Ok = 0;
    
        closedir(DFD);
        }
      else Ok = 0;
      }

    GotState->NestLevel *= -1;
  
    CurState = ListHead;
    while ( CurState && CurState->NestLevel > 0 )
      CurState = CurState->Next;

    GotState = CurState;

    } while ( GotState );

  CurState = ListHead;
  }

while( CurState )
  {
  GotState = CurState;
  CurState = CurState->Next;

  if ( KeepGoing )
    {
    if ( DFD = opendir(GotState->Path) )
      {
      if ( chdir(GotState->Path) == 0 )
        {
        if ( DirStartFunc ) KeepGoing = (*DirStartFunc)(GotState->Path,GotState->NestLevel);

        CatPaths(GotState->Path,"");
  
        while ( KeepGoing && (DE = readdir(DFD)) )
          {
          if ( stat(DE->d_name,&EntryStat) == 0 )
            {
            EntryWI.Name = DE->d_name;
            EntryWI.Path = GotState->Path;
            EntryWI.NestLevel = GotState->NestLevel;
            EntryWI.Size = EntryStat.st_size; /* <> not accurate on PCs */
            EntryWI.Attr = EntryStat.st_mode;
            EntryWI.Date = EntryStat.st_mtime;
            EntryWI.IsDir = S_ISDIR(EntryStat.st_mode);
        
            if ( DoDirs || !EntryWI.IsDir )
              KeepGoing = (*FileFunc)(&EntryWI);
            }
          else Ok = 0;
          }

        closedir(DFD); DFD = NULL;
        if ( KeepGoing )
          if ( DirDoneFunc ) KeepGoing = (*DirDoneFunc)();
        }
      else Ok = 0;
  
      if ( DFD) closedir(DFD);
      }
    else Ok = 0;
    }

  free(GotState);
  }

chdir(WasInDir);

return(Ok);
}

bool WalkDir_TwoPass(char *StartPath,bool RecurseFlag,bool DoDirs,
  FileFuncType FileFunc,DirStartFuncType DirStartFunc,DirDoneFuncType DirDoneFunc)
{
struct WalkState *CurState,*NextState,*GotState;
DIR * DFD;
struct dirent * DE;
struct stat EntryStat;
struct WalkInfo EntryWI;
bool Ok = 1;
char WasInDir[1024],CurPath[1024];
bool KeepGoing=1;

if ( !getcwd(WasInDir,1024) )
  return(0);

if ( (CurState = malloc(sizeof(struct WalkState))) == NULL )
  return(0);
CurState->Next = NULL;
CurState->NestLevel = 0;

if ( !StartPath )
  {
  strcpy(CurState->Path,WasInDir);
  }
else
  {
  chdir(StartPath);
  if ( !getcwd(CurState->Path,1024) )
    { free(CurState); return(0); }
  }

while( CurState )
  {
  GotState = CurState;
  CurState = CurState->Next;

  /** pass 1 : do FileFuncs **/

  if ( KeepGoing )
    {
    if ( DFD = opendir(GotState->Path) )
      {
      if ( chdir(GotState->Path) == 0 )
        {
        if ( DirStartFunc ) KeepGoing = (*DirStartFunc)(GotState->Path,GotState->NestLevel);

        strcpy(CurPath,GotState->Path);
        CatPaths(CurPath,"");
  
        while ( KeepGoing && (DE = readdir(DFD)) )
          {
          if ( stat(DE->d_name,&EntryStat) == 0 )
            {
        
            EntryWI.Name = DE->d_name;
            EntryWI.Path = CurPath;
            EntryWI.NestLevel = GotState->NestLevel;
            EntryWI.Size = EntryStat.st_size; /* <> not accurate on PCs */
            EntryWI.Attr = EntryStat.st_mode;
            EntryWI.Date = EntryStat.st_mtime;
            EntryWI.IsDir = S_ISDIR(EntryStat.st_mode);

            if ( DoDirs || !EntryWI.IsDir )
              KeepGoing = (*FileFunc)(&EntryWI);
            }
          else Ok = 0;
          }
        closedir(DFD); DFD = NULL;
        if ( KeepGoing )
          {
          if ( DirDoneFunc ) KeepGoing = (*DirDoneFunc)();
          }
        }
      else Ok = 0;
  
      if ( DFD) closedir(DFD);
      }
    else Ok = 0;
    }

  /** pass 2 : build recurse info **/

  if ( KeepGoing && RecurseFlag )
    {
    if ( DFD = opendir(GotState->Path) )
      {
      while ( KeepGoing && (DE = readdir(DFD)) )
        {
        if ( NameIsDir(DE->d_name) )
          {
          if ( (NextState = malloc(sizeof(struct WalkState))) != NULL )
            {
            NextState->NestLevel = GotState->NestLevel + 1;
            strcpy(NextState->Path,CurPath);
            strcat(NextState->Path,EntryWI.Name);
            NextState->Next = CurState;
            CurState = NextState;
            }
          else Ok = 0;
          }
        }
      closedir(DFD);
      }
    else Ok = 0;
    }

  free(GotState);
  }

chdir(WasInDir);

return(Ok);
}
