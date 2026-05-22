#include <exec/types.h>
#include <exec/memory.h>

#include <tdo/tdo.h>

#include <pragma/exec_lib.h>
#include <pragma/tdo_lib.h>

#include <stdio.h>
#include <stdlib.h>

struct tdoBase *tdoBase = NULL;

void main(long argc, char **argv)
{
 tdoBase = (APTR) OpenLibrary("tdo.library", 0);
 if(tdoBase)
 {
   ULONG mesh,mat1,mat2;
   TOCLColor color;
   STRPTR name,copy;

   if((mesh=tdoMeshNew())!=0) {

     tdoMeshNameGet(mesh,&name);
     tdoMeshCopyrightGet(mesh,&copy);
     printf("Name : (%s) Copyright : (%s)\n",name,copy);

     tdoMeshNameSet(mesh,"Esel");
     tdoMeshCopyrightSet(mesh,"Kuh");

     tdoMeshNameGet(mesh,&name);
     tdoMeshCopyrightGet(mesh,&copy);
     printf("Name : (%s) Copyright : (%s)\n",name,copy);

     tdoMaterialAdd(mesh,&mat1);
     color.r=255,color.g=0,color.b=0;
     tdoMaterialAmbientColorSet(mesh,mat1,&color);
     tdoMaterialNameSet(mesh,mat1,"rot");
     tdoMaterialNameGet(mesh,mat1,&name);
     printf("Material name : (%s)\n",name);
     tdoMaterialShininessSet(mesh,mat1,1);
     tdoMaterialTransparencySet(mesh,mat1,0);

     tdoMaterialAdd(mesh,&mat2);
     color.r=0,color.g=0,color.b=255;
     tdoMaterialAmbientColorSet(mesh,mat2,&color);
     tdoMaterialNameSet(mesh,mat2,"blau");
     tdoMaterialNameGet(mesh,mat2,&name);
     printf("Material name : (%s)\n",name);
     tdoMaterialShininessSet(mesh,mat2,1);
     tdoMaterialTransparencySet(mesh,mat2,0);

     printf("Number of materials : %ld\n",tdoMeshNofMaterialsGet(mesh));
     printf("Number of parts     : %ld\n",tdoMeshNofPartsGet(mesh));
     printf("Number of polygons  : %ld\n",tdoMeshNofPolygonsGet(mesh));
     printf("Number of vertices  : %ld\n",tdoMeshNofVerticesGet(mesh));

     tdoMeshDelete(mesh);
  }
   
  CloseLibrary((APTR) tdoBase);

  exit(0);
 }

 printf("\nLibrary opening failed\n");

 exit(20);
}
