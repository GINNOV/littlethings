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
     printf("Usage : %s nofpolys\n",argv[0]);
     exit(20);
   }

   nof=atol(argv[1]);

   printf("Ok, trying to create %ld polygons\n",nof);

   if((mesh=meshNew())!=0) {

     // creating two part for the polygons
     ret=meshPartAdd(mesh);
     if(ret!=RCNOERROR) {
         printf("Error occured while creating the first part: %ld\nDeleting mesh ...",ret);
         meshDelete(mesh);
         printf("\n");
         exit(20);
     }
     ret=meshPartAdd(mesh);
     if(ret!=RCNOERROR) {
         printf("Error occured while creating the second part: %ld\nDeleting mesh ...",ret);
         meshDelete(mesh);
         printf("\n");
         exit(20);
     }

     // creating nof polygons, all values remains default
     for(i=0;i<nof;i++) {
       ret=meshPartPolygonBegin(mesh,(i%2)+1);
       if(ret!=RCNOERROR) {
         printf("Error occured : %ld\nDeleting mesh ...",ret);
         meshDelete(mesh);
         printf("\n");
         exit(20);
       }
     }

     printf("Number of parts created     : %ld\n",meshNofPartsGet(mesh));
     printf("Number of polygons created  : %ld\n",meshNofPolygonsGet(mesh));
     for(i=1;i<=meshNofPartsGet(mesh);i++) {
         printf("Number of polygons in part %ld : %ld\n",i,meshPartNofPolygonsGet(mesh,i));
     }

     printf("Hit return to continue.\n");
     scanf("");

     printf("Deleting mesh ...");
     meshDelete(mesh);
     printf("\n");
  }
}
