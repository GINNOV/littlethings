#include <exec/types.h>
#include <exec/memory.h>

#include <pragma/exec_lib.h>

#include <stdio.h>
#include <stdlib.h>


#include "td.h"

void main(int argc, char **argv)
{
   ULONG  space,i,nof;
   TDenum ret;
   STRPTR name;

   // check for arguments
   if(argc!=2) {
     printf("Usage : %s nofmeshs\n",argv[0]);
     exit(20);
   }

   nof=atol(argv[1]);

   printf("Ok, trying to create %ld meshs\n",nof);

   if((space=tdSpaceNew())!=0) {

     tdNameSet(space,TD_SPACE,1234,"Erster Space");

     // creating nof materials, all values remains default
     for(i=0;i<nof;i++) {
       ret=tdAdd(space,TD_POLYMESH);
       if(ret!=NOERROR) {
         printf("Error occured : %ld\nDeleting space ...",ret);
         tdSpaceDelete(space);
         printf("\n");
         exit(20);
       }
     }

     printf("Number of meshs created  : %ld\n",tdNofGet(space,TD_MESH));

     name=NULL;
     ret=tdNameGet(space,TD_SPACE,65432,&name);
     printf("Space its name : %s\n",name);

     printf("Hit return to continue.\n");
     scanf("");

     printf("Deleting space ...");
     tdSpaceDelete(space);
     printf("\n");
  }
}
