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
     printf("Usage : %s nofparts\n",argv[0]);
     exit(20);
   }

   nof=atol(argv[1]);

   printf("Ok, trying to create %ld parts\n",nof);

   if((mesh=meshNew())!=0) {

     // creating nof parts, all values remains default
     for(i=0;i<nof;i++) {
       ret=meshPartAdd(mesh);
       if(ret!=RCNOERROR) {
         printf("Error occured : %ld\nDeleting mesh ...",ret);
         meshDelete(mesh);
         printf("\n");
         exit(20);
       }
     }

     printf("Number of parts created  : %ld\n",meshNofPartsGet(mesh));

     printf("Hit return to continue.\n");
     scanf("");

     printf("Deleting mesh ...");
     meshDelete(mesh);
     printf("\n");
  }
}
