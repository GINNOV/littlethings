#include <exec/types.h>
#include <exec/memory.h>

#include <pragma/exec_lib.h>

#include <stdio.h>
#include <stdlib.h>


#include "td.h"

void main(long argc, char **argv)
{
   ULONG space,i,txb;
   TDfloat fa3[3];
   TDvectord dv1,dv2,dv3,dv4;

   if((space=tdSpaceNew())!=0) {

     tdNameSet(space,TD_SPACE,0,"Texturtests");

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

     tdAdd(space,TD_TEXBINDING);
     txb=tdNofGet(space,TD_OBJECT);
     tdNameSet(space,TD_OBJECT,txb,"Mauerposition");

     tdAdd(space,TD_CUBE);
     i=tdNofGet(space,TD_OBJECT);
     tdNameSet(space,TD_OBJECT,i,"Würfel");
     fa3[0]=2.0;fa3[1]=4.0;fa3[2]=3.0;
     tdObjectSetfa(space,TD_CUBE,i,fa3);

     tdAdd(space,TD_POLYMESH);
     i=tdNofGet(space,TD_OBJECT);
     tdNameSet(space,TD_OBJECT,i,"Testobjekt");

     tdCurrent(space,TD_OBJECT,i);
       tdBegin(space,TD_MATGROUP);  
         dv1.x=30.1,dv1.y=30.1,dv1.z=30.2;
         dv2.x=30.3,dv2.y=30.4,dv2.z=30.5;
         dv3.x=30.6,dv3.y=30.7,dv3.z=30.8;
         dv4.x=30.9,dv4.y=30.0,dv4.z=30.01;
         tdQuadAdd4dv(space,&dv1,&dv2,&dv3,&dv4);
         tdChildSetl(space,TD_MATERIAL,2);
         tdChildSetl(space,TD_TEXBINDING,txb);
       tdEnd(space,TD_MATGROUP);
     tdEnd(space,TD_OBJECT);

     tdSpaceDelete(space);
   } else {
     printf("Could not create the space.\n");
   }
}
