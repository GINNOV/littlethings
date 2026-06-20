#include <exec/types.h>
#include <exec/memory.h>

#include <pragma/exec_lib.h>

#include <stdio.h>
#include <stdlib.h>


#include "td.h"

void main(long argc, char **argv)
{
   ULONG space,i,j,n,k,nof,value,txb;
   TDfloat ff,fa3[3];
   TDdouble da3[3],dx,dy,dz;
   TDenum type;
   STRPTR name;
   TDvectord dv,dv1,dv2,dv3,dv4;
   TDvectorf fv;

   if((space=tdSpaceNew())!=0) {

     tdNameGet(space,TD_SPACE,0,&name);
     printf("Name : (%s)\n",name);

     tdNameSet(space,TD_SPACE,0,"Esel");

     tdNameGet(space,TD_SPACE,0,&name);
     printf("Name : (%s)\n",name);

     tdAdd(space,TD_TEXTURE);
     i=tdNofGet(space,TD_MATERIAL);
     tdNameSet(space,TD_MATERIAL,i,"mauer");

     tdAdd(space,TD_SURFACE);
     i=tdNofGet(space,TD_MATERIAL);
     fa3[0]=1.0,fa3[1]=0.0,fa3[2]=0.0;
     tdMaterialSetfa(space,TD_DIFFUSE,i,fa3);
     tdNameSet(space,TD_MATERIAL,i,"rot");
     tdMaterialSetf(space,TD_SHININESS,i,0.8);
     tdMaterialSetf(space,TD_TRANSPARENCY,i,0.2);

     tdAdd(space,TD_SURFACE);
     i=tdNofGet(space,TD_MATERIAL);
     fa3[0]=0.0,fa3[1]=0.0,fa3[2]=1.0;
     tdMaterialSetfa(space,TD_DIFFUSE,i,fa3);
     tdNameSet(space,TD_MATERIAL,i,"blau");
     tdMaterialSetf(space,TD_SHININESS,i,0.4);
     tdMaterialSetf(space,TD_TRANSPARENCY,i,0.7);

     tdAdd(space,TD_SURFACE);
     i=tdNofGet(space,TD_MATERIAL);
     fa3[0]=0.0,fa3[1]=1.0,fa3[2]=0.0;
     tdMaterialSetfa(space,TD_DIFFUSE,i,fa3);
     tdNameSet(space,TD_MATERIAL,i,"grün");
     tdMaterialSetf(space,TD_SHININESS,i,0.4);
     tdMaterialSetf(space,TD_TRANSPARENCY,i,0.7);

     tdAdd(space,TD_TEXBINDING);
     txb=tdNofGet(space,TD_OBJECT);
     tdNameSet(space,TD_OBJECT,txb,"Mauerposition");

     printf("Number of materials : %ld\n",nof=tdNofGet(space,TD_MATERIAL));

     for(i=1;i<=nof;i++) {
       name[0]='\0'; fa3[0]=0; fa3[1]=0; fa3[2]=0; ff=0.0;

       tdNameGet(space,TD_MATERIAL,i,&name);
       tdTypeGet(space,TD_MATERIAL,i,&type);
       switch(type) {
         case TD_SURFACE :
           printf("  surface at index : %ld\n",i);
           printf("  name  : (%s)\n",name);
           tdMaterialGetfa(space,TD_AMBIENT,i,fa3);
           printf("  ambient color %6.3g %6.3g %6.3g\n",fa3[0],fa3[1],fa3[2]);
           tdMaterialGetfa(space,TD_DIFFUSE,i,fa3);
           printf("  diffuse color %6.3g %6.3g %6.3g\n",fa3[0],fa3[1],fa3[2]);
           tdMaterialGetf(space,TD_SHININESS,i,&ff);
           printf("  shininess    %6.3g\n",ff);
           tdMaterialGetf(space,TD_TRANSPARENCY,i,&ff);
           printf("  transparency %6.3g\n",ff);

           break;
         case TD_TEXTURE :
           printf("  texture at index : %ld\n",i);
           printf("  name  : (%s)\n",name);
       }
     }

     tdAdd(space,TD_CUBE);
     i=tdNofGet(space,TD_OBJECT);
     fa3[0]=2.0;fa3[1]=4.0;fa3[2]=3.0;
     tdObjectSetfa(space,TD_CUBE,i,fa3);
     fa3[0]=1.1;fa3[1]=1.2;fa3[2]=1.3;
     tdObjectSetfa(space,TD_ORIGIN,i,fa3);
     fa3[0]=2.1;fa3[1]=2.2;fa3[2]=2.3;
     tdObjectSetfa(space,TD_SCALE,i,fa3);
     fa3[0]=3.1;fa3[1]=3.2;fa3[2]=3.3;
     tdObjectSetfa(space,TD_ROTATION,i,fa3);

     tdAdd(space,TD_POLYMESH);
     i=tdNofGet(space,TD_OBJECT);
     tdNameSet(space,TD_OBJECT,i,"Testobjekt");

     tdCurrent(space,TD_OBJECT,i);
       tdCurrent(space,TD_MATERIAL,tdNofGet(space,TD_MATERIAL));
         tdBegin(space,TD_MATGROUP);
           tdBegin(space,TD_POLYGON);
             tdVertexAdd3f(space,10.1,10.0,9.9);
             tdVertexAdd3f(space,9.8,9.7,9.6);
             tdVertexAdd3f(space,9.5,9.4,9.3);
             tdVertexAdd3f(space,9.2,9.1,9.0);
           tdBegin(space,TD_POLYGON);
             da3[0]=1.1;da3[1]=1.2;da3[2]=1.3;
             tdVertexAdd3da(space,da3);
             da3[0]=1.4;da3[1]=1.5;da3[2]=1.6;
             tdVertexAdd3da(space,da3);
             da3[0]=1.7;da3[1]=1.8;da3[2]=1.9;
             tdVertexAdd3da(space,da3);
           tdEnd(space,TD_POLYGON);
       tdCurrent(space,TD_MATERIAL,1);
         tdBegin(space,TD_MATGROUP);  
           dv1.x=30.1,dv1.y=30.1,dv1.z=30.2;
           dv2.x=30.3,dv2.y=30.4,dv2.z=30.5;
           dv3.x=30.6,dv3.y=30.7,dv3.z=30.8;
           dv4.x=30.9,dv4.y=30.0,dv4.z=30.01;
           tdQuadAdd4dv(space,&dv1,&dv2,&dv3,&dv4);
           tdChildSetl(space,TD_MATERIAL,2);
           tdChildSetl(space,TD_TEXBINDING,txb);
         tdEnd(space,TD_MATGROUP);
       tdEnd(space,TD_MATERIAL);
     tdEnd(space,TD_OBJECT);

     printf("Number of objects : %ld\n",nof=tdNofGet(space,TD_OBJECT));

     for(i=1;i<=nof;i++) {
       name[0]='\0'; da3[0]=0; da3[1]=0; da3[2]=0;type=0;

       tdNameGet(space,TD_OBJECT,i,&name);
       printf("->index : %ld\n",i);
       printf("  name  : (%s)\n",name);
       tdObjectGetda(space,TD_ORIGIN,i,da3);
       printf("Object its origin   %6.3g %6.3g %6.3g\n",da3[0],da3[1],da3[2]);
       tdObjectGetda(space,TD_SCALE,i,da3);
       printf("Object its scale    %6.3g %6.3g %6.3g\n",da3[0],da3[1],da3[2]);
       tdObjectGetda(space,TD_ROTATION,i,da3);
       printf("Object its rotation %6.3g %6.3g %6.3g\n",da3[0],da3[1],da3[2]);
       tdTypeGet(space,TD_OBJECT,i,&type);
       switch(type) {
         case TD_TEXBINDING :
           printf("Texture binding\n");
			break;
         case TD_CUBE :
           tdObjectGetfa(space,TD_CUBE,i,fa3);
           printf("Cube\n xyz %6.3g %6.3g %6.3g\n",fa3[0],fa3[1],fa3[2]);
			break;
         case TD_POLYMESH :
           tdCurrent(space,TD_OBJECT,i);
           printf("polygons : %ld\n",tdNofGet(space,TD_POLYGON));
           printf("vertices : %ld\n",tdNofGet(space,TD_VERTEX));

           for(k=1;k<=tdNofGet(space,TD_MATGROUP);k++) {
             tdCurrent(space,TD_MATGROUP,k);

             printf(" matgroup %ld\n",k);
             tdChildGetl(space,TD_MATERIAL,&value);
             printf("  materialindex : %ld\n",value);
             tdChildGetl(space,TD_TEXBINDING,&value);
             printf("  texbindex     : %ld\n",value);
             printf("  polygons : %ld\n",tdNofGet(space,TD_POLYGON));
             printf("  vertices : %ld\n",tdNofGet(space,TD_VERTEX));

             for(j=1;j<=tdNofGet(space,TD_POLYGON);j++) {
               printf(" polygon %ld\n",j);
               tdCurrent(space,TD_POLYGON,j);
               for(n=1;n<=tdNofGet(space,TD_VERTEX);n++) {
                 printf("  vertices : %ld\n",tdNofGet(space,TD_VERTEX));
                 dv.x=0.0;dv.y=0.0;dv.z=0.0;
                 dx=0.0;dy=0.0;dz=0.0;

                 tdVertexGetdv(space,n,&dv);
                 tdVertexGet3d(space,n,&dx,&dy,&dz);
                 printf("  ->index : %ld\n",n);
                 printf("         VGet Get\n");
                 printf("    x  : %0.4g  %0.4g\n",dv.x,dx);
                 printf("    y  : %0.4g  %0.4g\n",dv.y,dy);
                 printf("    z  : %0.4g  %0.4g\n",dv.z,dz);
               }
               tdEnd(space,TD_POLYGON);
             }
             tdEnd(space,TD_MATGROUP);
           }
           
           printf("Number of polygons in the object : %ld\n",tdNofGet(space,TD_POLYGON));

           tdVertexAdd3f(space,1.1,1.2,1.3);
           dv.x=2.1;dv.y=2.2;dv.z=2.3;
           tdVertexAdddv(space,&dv);

           printf("Number of vertices  : %ld\n",tdNofGet(space,TD_VERTEX));
           for(i=1;i<=tdNofGet(space,TD_VERTEX);i++) {
      
             fv.x=0.0;fv.y=0.0;fv.z=0.0;
             dx=0.0;dy=0.0;dz=0.0;

             tdVertexGetfv(space,i,&fv);
             tdVertexGet3fa(space,i,fa3);
             printf("->index : %ld\n",i);
             printf("       VGet Get\n");
             printf("  x  : %0.4g  %0.4g\n",fv.x,fa3[0]);
             printf("  y  : %0.4g  %0.4g\n",fv.y,fa3[1]);
             printf("  z  : %0.4g  %0.4g\n",fv.z,fa3[2]);
           }

           tdEnd(space,TD_OBJECT);

         break;
       }
     }

     tdSpaceDelete(space);
   } else {
     printf("Could not create the space.\n");
   }
}
