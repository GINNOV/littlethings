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
   TOCLVertex v1,v2,v3;

  if((mesh = tdoMeshNew())!=RCNOERROR) {

    tdoMeshMaterialAdd(mesh,&mat1);
    color.r=255,color.g=0,color.b=0;
    tdoMeshMaterialAmbientColorSet(mesh,mat1,&color);
    tdoMeshMaterialNameSet(mesh,mat1,"rot");
    tdoMeshMaterialShininessSet(mesh,mat1,1);
    tdoMeshMaterialTransparencySet(mesh,mat1,0);

    tdoMeshMaterialAdd(mesh,&mat2);
    color.r=0,color.g=0,color.b=255;
    tdoMeshMaterialAmbientColorSet(mesh,mat2,&color);
    tdoMeshMaterialNameSet(mesh,mat2,"blau");
    tdoMeshMaterialShininessSet(mesh,mat2,1);
    tdoMeshMaterialTransparencySet(mesh,mat2,0);

    tdoMeshNameSet(mesh,"Quad");
    v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=10,v2.z=0;v3.x=-10,v3.y=10,v3.z=0;
    tdoMeshTriangleAdd(mesh,mat1,&v1,&v2,&v3);
    v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=-10,v2.z=0;v3.x=10,v3.y=10,v3.z=0;
    tdoMeshTriangleAdd(mesh,mat2,&v1,&v2,&v3);

    printf("Total number of vertices : %ld\n",tdoMeshNumberOfVerticesGet(mesh));
    printf("Total number of polygons : %ld\n",tdoMeshNumberOfPolygonsGet(mesh));
    printf("Total number of materials : %ld\n",tdoMeshNumberOfMaterialsGet(mesh));

    printf("%ld\n",tdoMeshSave3D(mesh,T3DFDXF,"ram:pout.dxf"));
  
	tdoMeshDelete(mesh);
  }
   
  CloseLibrary((APTR) tdoBase);

  exit(0);
 }

 printf("\nLibrary opening failed\n");

 exit(20);
}
