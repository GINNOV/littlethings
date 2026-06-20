/* Repdupes.c */
#include "stack.h"
#include "btree.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

#include <exec/types.h>
#include <dos/dos.h>

/* global */
char    *ver="\0$VER: RepDupes V37.1\0";
BTREE   *myBtree=NULL;
long    files=0,dupes=0,dirs=0;
long    totfiles=0;
int     sw_count=FALSE,sw_long=FALSE;

#define LEN_NAME    96
#define OPT_COUNT   'o'
#define OPT_LONG    'l'
#define OPT_HELP    'h'

void searchdir(UBYTE *dir);

int main(int argc,char *argv[])
{
    char                    opts[]="hofl";
    char                    option,*optdata;
    int                     next;
    char                    pad[LEN_NAME];
        
    next=1;
    while((optdata=argopt(argc,argv,opts,&next,&option))!=NULL)
    {
        switch(option)
        {
                case OPT_HELP:
                    fprintf(stderr,"RepDupes V37.1 by Chris De Maeyer\n");
                    fprintf(stderr,"---------------------------------\n");
                    fprintf(stderr,"FreeWare by Blue Heaven 1994\n");
                    fprintf(stderr,"USAGE  : RepDupes [opts] [path]\n");
                    fprintf(stderr,"Options: -o   only count\n");
                    fprintf(stderr,"         -l   long descriptions\n\n");
                    exit(0);
                    break;
                case OPT_COUNT:
                    sw_count=TRUE;
                    break;
                case OPT_LONG:
                    break;
                default:
                    fprintf(stderr,"Wrong parameter !\n");
                    exit(RETURN_FAIL);
        }
    }
    strcpy(pad,argv[next]);
    if(access(pad,F_OK)!=0)
    {
        fprintf(stderr,"Path not found !\n");
        exit(RETURN_FAIL);
    }

    if((myBtree=BTree_Create(LEN_NAME))==NULL)
    {
        fprintf(stderr,"Couldn't allocate for internal structure !\n");
        exit(RETURN_FAIL);
    }
        
    searchdir(pad);
            
    printf("Found: %ld files, %ld subdirs, %ld duplicates.\n",files,dirs,dupes);
    
    BTree_Free(myBtree);
    exit(0);                                        
}

void searchdir(UBYTE *dir)
{
        struct FileInfoBlock info;
        int error,res;
        UBYTE newDir[LEN_NAME];
        UBYTE zoekDir[LEN_NAME];
        UBYTE newFile[LEN_NAME];
        STACK *myStack=NULL;
        
        strcpy(zoekDir,dir);
        strcat(zoekDir,"/#?");

        if((myStack=Stack_Create(LEN_NAME))==NULL)
        {
            fprintf(stderr,"Couldn't create internal structures !\n");
            return;
        }        
         
        error=dfind(&info,zoekDir,1);
        while(error==0)
        {
                if(info.fib_DirEntryType>0)
                {
                        dirs++;
                        strcpy(newDir,dir);
                        strcat(newDir,info.fib_FileName);
                        Stack_Push(myStack,(void *)newDir);
                }
                else
                {
                      files++;  
                      strcpy(newFile,info.fib_FileName);
                      strupr(newFile);
                      if((res=BTree_Insert(myBtree,(void *)newFile))!=BTREE_OK)
                      {
                            dupes++;
                            if(!sw_count)          
                                printf("%s/%s.\n",dir,info.fib_FileName);
                      }
                }            
                error=dnext(&info);
        }
        while((Stack_Pop(myStack,(UBYTE *)newDir))==STACK_OK)
            searchdir(newDir);
        Stack_Free(myStack);    
}
/* The End */             
