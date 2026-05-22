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
  TOCLVertex coords[6];
  ULONG ret,index,i;
  ULONG indexes[6];
    
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

    if(MWLMeshNameSet(mesh,"Converter test")) printf("Name not set\n");
    else printf("Name set\n");

    coords[0].x=-10,coords[0].y=-10,coords[0].z=0;
	coords[1].x=10,coords[1].y=10,coords[1].z=0;
	coords[2].x=-10,coords[2].y=10,coords[2].z=0;
    coords[3].x=-10,coords[3].y=-10,coords[3].z=0;
	coords[4].x=10,coords[4].y=-10,coords[4].z=0;
	coords[5].x=10,coords[5].y=10,coords[5].z=0;

    printf("Vertex added %ld / %f %f %f\n",MWLMeshVertexAdd(mesh,&(coords[0]),&(indexes[0])),coords[0].x,coords[0].y,coords[0].z);
    printf("Vertex added %ld / %f %f %f\n",MWLMeshVertexAdd(mesh,&(coords[1]),&(indexes[1])),coords[1].x,coords[1].y,coords[1].z);
    printf("Vertex added %ld / %f %f %f\n",MWLMeshVertexAdd(mesh,&(coords[2]),&(indexes[2])),coords[2].x,coords[2].y,coords[2].z);
    printf("Vertex added %ld / %f %f %f\n",MWLMeshVertexAdd(mesh,&(coords[3]),&(indexes[3])),coords[3].x,coords[3].y,coords[3].z);
    printf("Vertex added %ld / %f %f %f\n",MWLMeshVertexAdd(mesh,&(coords[4]),&(indexes[4])),coords[4].x,coords[4].y,coords[4].z);
    printf("Vertex added %ld / %f %f %f\n",MWLMeshVertexAdd(mesh,&(coords[5]),&(indexes[5])),coords[5].x,coords[5].y,coords[5].z);

	printf("Index list :position / index\n");
	for(i=0;i<6;i++) printf("%ld / %ld\n",i,indexes[i]);

	printf("Research coordinates with indexes : retval / coordinates / index\n");
	for(i=0;i<6;i++) {
		printf("%ld / %f %f %f ",MWLMeshVertexIndexGet(mesh,&(coords[i]),&index),coords[i].x,coords[i].y,coords[i].z);
		printf("%ld\n",index);
	}

	printf("Polygon added %ld\n",MWLMeshPolygonAdd(mesh,mat1));
	printf("Vertex assigned %ld\n",MWLMeshPolygonVertexAssign(mesh,indexes[0]));
	printf("Vertex assigned %ld\n",MWLMeshPolygonVertexAssign(mesh,indexes[1]));
	printf("Vertex assigned %ld\n",MWLMeshPolygonVertexAssign(mesh,indexes[2]));

	printf("Polygon added %ld\n",MWLMeshPolygonAdd(mesh,mat2));
	printf("Vertex assigned %ld\n",MWLMeshPolygonVertexAssign(mesh,indexes[3]));
	printf("Vertex assigned %ld\n",MWLMeshPolygonVertexAssign(mesh,indexes[4]));
	printf("Vertex assigned %ld\n",MWLMeshPolygonVertexAssign(mesh,indexes[5]));

    printf("Total number of vertices : %ld\n",MWLMeshNumberOfVerticesGet(mesh));
    printf("Total number of polygons : %ld\n",MWLMeshNumberOfPolygonsGet(mesh));
    printf("Total number of materials : %ld\n",MWLMeshNumberOfMaterialsGet(mesh));
    
    printf("Triangles added\n");
    if((ret=MWLMeshSave3D(mesh,T3DFGEOA,"ram:pout.geo",NULL))) printf("Object not saved : %ld\n",ret);
//    if((ret=MWLMeshSave2D(mesh,T2DFPSP,"ram:pout.ps",TVWTOP,TDMPOINTS,NULL))) printf("Object not saved : %ld\n",ret);

	printf("Deleting mesh\n");
	MWLMeshDelete(mesh);
  }
}  