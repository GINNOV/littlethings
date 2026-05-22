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
  ULONG mesh;
  TOCLVertex v1,v2,v3;
  ULONG ret,i;
    
  if((mesh = MWLMeshNew())!=0) {
    printf("Object created\n");

    if(MWLMeshNameSet(mesh,"BigThing")) printf("Name not set\n");
    else printf("Name set\n");

	printf("Adding triangles...");
    v1.x=0.001,v1.y=0.001,v1.z=0.001;
	for(i=0;i<65536;i++) {
		v2.x=v1.x+0.001,v2.y=v1.y+0.001,v2.z=v1.z+0.001;
		v3.x=v1.x+0.002,v3.y=v1.y+0.002,v3.z=v1.z+0.002;

	    v1.x+=0.003,v1.y+=0.003,v1.z+=0.003;
	    MWLMeshTriangleAdd(mesh,0,&v1,&v2,&v3);
	}
    printf(" Done\n");

    printf("Total number of vertices : %ld\n",MWLMeshNumberOfVerticesGet(mesh));
    printf("Total number of polygons : %ld\n",MWLMeshNumberOfPolygonsGet(mesh));
    printf("Total number of materials : %ld\n",MWLMeshNumberOfMaterialsGet(mesh));
    
    printf("Triangles added\n");
    if((ret=MWLMeshSave3D(mesh,T3DFREF4,"ram:pout.r4",NULL))) printf("Object not saved : %ld\n",ret);

	printf("Deleting mesh\n");
	MWLMeshDelete(mesh);
  }
}  