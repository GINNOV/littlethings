/****************************************************************/
/* showlib.c                                                    */
/****************************************************************/
/*                                                              */
/* Tiny tool used to dump library and device offsets            */
/* Usefull with resource to track location of functions         */
/*                                                              */
/* Usage: showlib show all libraries and devices                */
/*                                                              */
/*        showlib intuition.library (guess what it do ?)        */
/*        showlib timer.device (guess what it do ?)             */
/*                                                              */
/****************************************************************/
/* Gilles Pelletier                                             */
/*                                                              */
/* Many thanks to Fredrik Wikstrom and Hubert Maier for their   */
/* tests on OS4.0                                               */
/****************************************************************/
/*                                                              */
/* Modification history                                         */
/* ====================                                         */
/* 29-Feb-2008 mighty crash with arguments                      */
/*             more efficient list run                          */
/*             wrong count of functions                         */
/* 26-Feb-2008 Aminet release for all                           */
/* 14-Feb-2008 system device list                               */
/* 05-Dec-1999 function name, using .fd files                   */
/* 23-Nov-1997 library list and jump addresses                  */
/* 10-Jan-1990 library list                                     */
/****************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include <ctype.h>
#include <string.h>

#define __USE_BASETYPE__
#include <exec/execbase.h>

#include <proto/exec.h>

void vectorname(char *, char *) ;
extern char **loadstrings(char*, int) ;
extern void freestrings(char**, int) ;

extern struct ExecBase *SysBase;

struct Vector
{
  UWORD jmpcode ;
  ULONG jmpptr ;
} ;


void printlibheader(struct Library *lib)
{
  char name[255] ;
  char *pc ;

  printf("0x%08lx ", lib) ;
  name[0] = 0 ;
  pc = lib->lib_Node.ln_Name ;
  if (pc != NULL)
  {
    strcpy(name, pc) ;
  }
  printf( "%s %ld.%ld\n", name, lib->lib_Version, lib->lib_Revision) ;

  name[0] = 0 ;
  pc = lib->lib_IdString ;
  if (pc != NULL)
  {
    strcpy(name, pc) ;

    if (1)
    {
      int i ;
      int len ;

      /* Remove all non printable characters */
      pc = &name[0] ;
      len = strlen(name) ;
      for (i=0; i<len; i++)
      {
        if (isprint(*pc))
        {
        }
        else
        {
          *pc = ' ' ;
        }
        pc ++ ; 
      }
    }
  }
  printf("%s\n", name) ;

  printf( "Flags=0x%02x ", lib->lib_Flags) ;
  printf( "NegSize %d ", lib->lib_NegSize) ;
  printf( "PosSize %d\n", lib->lib_PosSize) ;  
  printf("CheckSum 0x%08lx ", lib->lib_Sum) ;
  printf("OpenCnt %d\n", lib->lib_OpenCnt) ;     
}

void printvect(struct Library *lib)
{
  char buffer[255] ;
  int i ;
  int NbFunc ;
  int cnt ;
  struct Vector *ptr ;
  char **strs ;
  
 
  NbFunc = lib->lib_NegSize / 6 ;
  ptr = (struct Vector*) lib ;
  ptr -- ;
  cnt = -6 ;
  
  strs = loadstrings(lib->lib_Node.ln_Name, NbFunc) ;
    
  for ( i = 0; i < NbFunc; i++ )
  {
    if (strs != NULL)
    {
      if (strs[i] != NULL)
      {
        vectorname(buffer, strs[i]) ; 
      }
      else
      {
        sprintf(buffer, "%3d ? ", i+1 ) ;
      }
    }
    else
    {
      sprintf(buffer, "%3d (%ld) :", i+1, cnt ) ;
    }

    printf("%-40.40s", buffer) ;
    printf( " %+4d %04x %08lx\n",
              cnt,
              ptr->jmpcode,
              ptr->jmpptr) ;
              
    ptr-- ;
    cnt -= 6 ;
  }
  
  if (strs != NULL)
  {
    freestrings(strs, NbFunc) ;   
  }
}

void printinfo(struct Library *lib)
{
  printlibheader(lib) ;
  printvect(lib) ;  
}

int main(int argc, char *argv[])
{
  
  struct Library *lib ;

  if (argc < 2)
  {
    /* no argument, print the entire list of libraries and devices */
    /* Libs */
    lib = (struct Library *)SysBase->LibList.lh_Head ;
    while (lib->lib_Node.ln_Succ != NULL)
    {
      printinfo(lib) ;
      printf("\n") ;
      lib = (struct Library*)lib->lib_Node.ln_Succ ;  
    }

    /* Devices */
    lib = (struct Library*)SysBase->DeviceList.lh_Head ;
    while (lib->lib_Node.ln_Succ != NULL)
    {
      printinfo(lib) ;
      printf("\n") ;
      lib = (struct Library *)lib->lib_Node.ln_Succ ;
    }    
  }
  else
  {
    /* try to find the first name found into argument list */
    lib = (struct Library *)FindName(&SysBase->LibList, argv[1]) ;
    if (lib == NULL)
    {
      lib = (struct Library *)FindName(&SysBase->DeviceList, argv[1]) ;
    }

    if( lib == NULL)
    {
      printf("\"%s\" not found\n", argv[1]) ;
    }
    else
    {
      printinfo(lib) ;
    }
  }

  return 0 ;     
}
