#include <exec/types.h>
#include <exec/memory.h>

#include <pragma/exec_lib.h>

#include <stdio.h>
#include <stdlib.h>


#include "tdo.h"

void main(int argc, char **argv)
{
   ULONG mesh,i,ret,nof;

   // check for arguments
   if(argc!=2) {
     printf("Usage : %s nofvertices\n",argv[0]);
     exit(20);
   }

   nof=atol(argv[1]);

   printf("Ok, trying to create %ld vertices\n",nof);

   if((mesh=meshNew())!=0) {

     // creating nof vertices, all values remains default
     for(i=0;i<nof;i++) {
       ret=meshVertexAdd(mesh,1.1,2.2,3.3);
       if(ret!=RCNOERROR) {
         printf("Error occured : %ld\nDeleting mesh ...",ret);
         meshDelete(mesh);
         printf("\n");
         exit(20);
       }
     }

     printf("Number of vertices created  : %ld\n",meshNofVerticesGet(mesh));

     printf("Hit return to continue.\n");
     scanf("");

     printf("Deleting mesh ...");
     meshDelete(mesh);
     printf("\n");
  }
}
