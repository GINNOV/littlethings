/*
** ANSI standart includes
*/
#include <stdio.h>

/*
** Amiga includes
*/

/*
** Amiga libraries includes
*/

/*
** Project includes
*/
#include </meshlib.h>

/************************** test main *******************************/
void main(void) {
  ULONG mesh,mat1,mat2;
  TOCLColor color;
  TOCLVertex v1,v2,v3;
  ULONG ret;
    
  if((mesh = MWLMeshNew())!=0) {
    printf("Object created\n");


    if((MWLMeshMaterialAdd(mesh,&mat1))!=RCNOERROR) {
      printf("Could not create a new material\n");
    }
    color.r=255,color.g=0,color.b=0;
    MWLMeshMaterialAmbientColorSet(mesh,mat1,&color);
    MWLMeshMaterialNameSet(mesh,mat1,"rot");
    MWLMeshMaterialShininessSet(mesh,mat1,1);
    MWLMeshMaterialTransparencySet(mesh,mat1,0);
    printf("Material created\n");

    if((MWLMeshMaterialAdd(mesh,&mat2))!=RCNOERROR) {
      printf("Could not create a new material\n");
    }
    color.r=0,color.g=0,color.b=255;
    MWLMeshMaterialAmbientColorSet(mesh,mat2,&color);
    MWLMeshMaterialNameSet(mesh,mat2,"blau");
    MWLMeshMaterialShininessSet(mesh,mat2,1);
    MWLMeshMaterialTransparencySet(mesh,mat2,0);
    printf("Material created\n");
/*
    if((MWLMeshMaterialAdd(mesh))!=0) {
      printf("Could not create a new material\n");
    }
    color.r=0,color.g=255,color.b=0;
    MWLMeshMaterialAmbientColorSet(mesh,&color);
    MWLMeshMaterialShininessSet(mesh,1);
    MWLMeshMaterialTransparencySet(mesh,0);
    printf("Material created\n");

    if((MWLMeshMaterialAdd(mesh))!=0) {
      printf("Could not create a new material\n");
    }
    color.r=255,color.g=0,color.b=255;
    MWLMeshMaterialAmbientColorSet(mesh,&color);
    MWLMeshMaterialShininessSet(mesh,1);
    MWLMeshMaterialTransparencySet(mesh,0);
    printf("Material created\n");
*/

//star
//    if(MWLMeshNameSet(mesh,"Star")) printf("Name not set\n");
//    else printf("Name set\n");
//    printf("PolygonAdd %d\n",MWLMeshPolygonAdd(mesh,1));        
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,10,0,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,2,2,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,0,10,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,-2,2,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,-10,0,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,-2,-2,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,0,-10,0));
//    printf("VertexAdd %d\n",MWLMeshPolygonVertexAdd(mesh,2,-2,0));

//quad
    if(MWLMeshNameSet(mesh,"Quad")) printf("Name not set\n");
    else printf("Name set\n");
    v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=10,v2.z=0;v3.x=-10,v3.y=10,v3.z=0;
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,1,&v1,&v2,&v3));
    v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=-10,v2.z=0;v3.x=10,v3.y=10,v3.z=0;
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,2,&v1,&v2,&v3));

//Pyramide
/*    if(MWLMeshNameSet(mesh,"Pyramide")) printf("Name not set\n");
    else printf("Name set\n");
    
	if(MWLMeshCopyrightSet(mesh,"Copyright by Bluem")) printf("Copyright not set\n");
	else printf("Copyright set\n");
    
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,1,-10,-10,-10,10,-10,-10,0,0,10));
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,2,10,-10,-10,10,10,-10,0,0,10));
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,3,10,10,-10,-10,10,-10,0,0,10));
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,4,-10,10,-10,-10,-10,-10,0,0,10));
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,1,-10,-10,-10,-10,10,-10,10,10,-10));
    printf("TriangleAdd %d\n",MWLMeshTriangleAdd(mesh,0,10,10,-10,10,-10,-10,-10,-10,-10));
*/
    printf("Total number of vertices : %ld\n",MWLMeshNumberOfVerticesGet(mesh));
    printf("Total number of polygons : %ld\n",MWLMeshNumberOfPolygonsGet(mesh));
    printf("Total number of materials : %ld\n",MWLMeshNumberOfMaterialsGet(mesh));
    
    printf("Triangles added\n");

    if((ret=MWLMeshSave3D(mesh,T3DFDXF,"ram:pout.dxf",NULL))) printf("Object not saved : %ld\n",ret);
//    if((ret=MWLMeshSave2D(mesh,T2DFPSP,"ram:pout.ps",TVWTOP,TDMGRIDBW,NULL))) printf("Object not saved : %ld\n",ret);

	printf("Deleting mesh\n");
	MWLMeshDelete(mesh);
  }
}  