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
  ULONG meshhandle,mathandle1,mathandle2,mathandle3,retval,i,id,dm;
  TOCLColor c,color;
  TOCLVertex v1,v2,v3,vertex;
  STRPTR string=NULL,*array=NULL;
  TOCLFloat fval;
  char buffer[100];

  printf("\nTesting all MeshWriter functions\n");
  printf("--------------------------------\n\n");
  
  printf("MWLMeshNew()\t\t\t\t\t\t\t%ld\n",meshhandle = MWLMeshNew());

  retval=MWLMeshMaterialAdd(meshhandle,&mathandle1);
  printf("MWLMeshMaterialAdd(meshhandle,&mathandle1)\t\t\t");
  if(retval==RCNOERROR) printf("%ld\n",mathandle1);
  else printf("ERROR %ld\n",retval);
  printf("MWLMeshMaterialNameSet(meshhandle,mathandle1,\"red\")\t\t%ld\n",MWLMeshMaterialNameSet(meshhandle,mathandle1,"red"));
  printf("MWLMeshMaterialNameGet(meshhandle,mathandle1,string)\t\t");
  retval=MWLMeshMaterialNameGet(meshhandle,mathandle1,&string);
  if(retval==RCNOERROR) printf("%s\n",string);
  else printf("%ld\n",retval);
  c.r=255,c.g=0,c.b=0;
  printf("MWLMeshMaterialAmbientColorSet(meshhandle,mathandle1,&color)\t%ld\n",MWLMeshMaterialAmbientColorSet(meshhandle,mathandle1,&c));
  printf("MWLMeshMaterialAmbientColorGet(meshhandle,mathandle1,&color)\t");
  retval=MWLMeshMaterialAmbientColorGet(meshhandle,mathandle1,&color);
  if(retval==RCNOERROR) printf("%d %d %d\n",color.r,color.g,color.b);
  else printf("%ld\n",retval);
  printf("MWLMeshMaterialShininessSet(meshhandle,mathandle1,1)\t\t%ld\n",MWLMeshMaterialShininessSet(meshhandle,mathandle1,1));
  printf("MWLMeshMaterialShininessGet(meshhandle,mathandle1,&floatvalue)\t");
  retval=MWLMeshMaterialShininessGet(meshhandle,mathandle1,&fval);
  if(retval==RCNOERROR) printf("%g\n",fval);
  else printf("%ld\n",retval);
  printf("MWLMeshMaterialTransparencySet(meshhandle,mathandle1,0)\t\t%ld\n",MWLMeshMaterialTransparencySet(meshhandle,mathandle1,0));
  printf("MWLMeshMaterialTransparencyGet(meshhandle,mathandle1,&fval)\t");
  retval=MWLMeshMaterialTransparencyGet(meshhandle,mathandle1,&fval);
  if(retval==RCNOERROR) printf("%g\n",fval);
  else printf("%ld\n",retval);

  retval=MWLMeshMaterialAdd(meshhandle,&mathandle2);
  printf("MWLMeshMaterialAdd(meshhandle,&mathandle2)\t\t\t");
  if(retval==RCNOERROR) printf("%ld\n",mathandle2);
  else printf("ERROR %ld\n",retval);
  printf("MWLMeshMaterialNameSet(meshhandle,mathandle2,\"blue\")\t\t%ld\n",MWLMeshMaterialNameSet(meshhandle,mathandle2,"blue"));
  printf("MWLMeshMaterialNameGet(meshhandle,mathandle2,string)\t\t");
  retval=MWLMeshMaterialNameGet(meshhandle,mathandle2,&string);
  if(retval==RCNOERROR) printf("%s\n",string);
  else printf("%ld\n",retval);
  c.r=0,c.g=0,c.b=255;
  printf("MWLMeshMaterialAmbientColorSet(meshhandle,mathandle2,&color)\t%ld\n",MWLMeshMaterialAmbientColorSet(meshhandle,mathandle2,&c));
  printf("MWLMeshMaterialAmbientColorGet(meshhandle,mathandle2,&color)\t");
  retval=MWLMeshMaterialAmbientColorGet(meshhandle,mathandle2,&color);
  if(retval==RCNOERROR) printf("%d %d %d\n",color.r,color.g,color.b);
  else printf("%ld\n",retval);
  printf("MWLMeshMaterialShininessSet(meshhandle,mathandle2,1)\t\t%ld\n",MWLMeshMaterialShininessSet(meshhandle,mathandle2,1));
  printf("MWLMeshMaterialShininessGet(meshhandle,mathandle2,&fval)\t");
  retval=MWLMeshMaterialShininessGet(meshhandle,mathandle2,&fval);
  if(retval==RCNOERROR) printf("%g\n",fval);
  else printf("%ld\n",retval);
  printf("MWLMeshMaterialTransparencySet(meshhandle,mathandle2,0)\t\t%ld\n",MWLMeshMaterialTransparencySet(meshhandle,mathandle2,0));
  printf("MWLMeshMaterialTransparencyGet(meshhandle,mathandle2,&fval)\t");
  retval=MWLMeshMaterialTransparencyGet(meshhandle,mathandle2,&fval);
  if(retval==RCNOERROR) printf("%g\n",fval);
  else printf("%ld\n",retval);

  retval=MWLMeshMaterialAdd(meshhandle,&mathandle3);
  printf("MWLMeshMaterialAdd(meshhandle,&mathand3e1)\t\t\t");
  if(retval==RCNOERROR) printf("%ld\n",mathandle3);
  else printf("ERROR %ld\n",retval);
  printf("MWLMeshMaterialNameSet(meshhandle,mathandle3,\"green\")\t\t%ld\n",MWLMeshMaterialNameSet(meshhandle,mathandle3,"green"));
  printf("MWLMeshMaterialNameGet(meshhandle,mathandle3,string)\t\t");
  retval=MWLMeshMaterialNameGet(meshhandle,mathandle3,&string);
  if(retval==RCNOERROR) printf("%s\n",string);
  else printf("%ld\n",retval);
  c.r=0,c.g=255,c.b=0;
  printf("MWLMeshMaterialAmbientColorSet(meshhandle,mathandle3,&color)\t%ld\n",MWLMeshMaterialAmbientColorSet(meshhandle,mathandle3,&c));
  printf("MWLMeshMaterialAmbientColorGet(meshhandle,mathandle3,&color)\t");
  retval=MWLMeshMaterialAmbientColorGet(meshhandle,mathandle3,&color);
  if(retval==RCNOERROR) printf("%d %d %d\n",color.r,color.g,color.b);
  else printf("%ld\n",retval);
  printf("MWLMeshMaterialShininessSet(meshhandle,mathandle3,1)\t\t%ld\n",MWLMeshMaterialShininessSet(meshhandle,mathandle3,1));
  printf("MWLMeshMaterialShininessGet(meshhandle,mathandle3,&fval)\t");
  retval=MWLMeshMaterialShininessGet(meshhandle,mathandle3,&fval);
  if(retval==RCNOERROR) printf("%g\n",fval);
  else printf("%ld\n",retval);
  printf("MWLMeshMaterialTransparencySet(meshhandle,mathandle3,0)\t\t%ld\n",MWLMeshMaterialTransparencySet(meshhandle,mathandle3,0));
  printf("MWLMeshMaterialTransparencyGet(meshhandle,mathandle3,&fval)\t");
  retval=MWLMeshMaterialTransparencyGet(meshhandle,mathandle3,&fval);
  if(retval==RCNOERROR) printf("%g\n",fval);
  else printf("%ld\n",retval);

  printf("MWLMeshCopyrightSet(meshhandle,\"Copyright\")\t\t\t%ld\n",MWLMeshCopyrightSet(meshhandle,"Copyright"));
  printf("MWLMeshCopyrightGet(meshhandle,string)\t\t\t\t");
  retval=MWLMeshCopyrightGet(meshhandle,&string);
  if(retval==RCNOERROR) printf("%s\n",string);
  else printf("%ld\n",retval);
    
  printf("MWLMeshNameSet(meshhandle,\"ObjectName\")\t\t\t\t%ld\n",MWLMeshNameSet(meshhandle,"ObjectName"));
  printf("MWLMeshNameGet(meshhandle,string)\t\t\t\t");
  retval=MWLMeshNameGet(meshhandle,&string);
  if(retval==RCNOERROR) printf("%s\n",string);
  else printf("%ld\n",retval);

  v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=10,v2.z=0;v3.x=-10,v3.y=10,v3.z=0;
  printf("MWLMeshTriangleAdd(meshhandle,1,&v1,&v2,&v3)\t\t\t%ld\n",MWLMeshTriangleAdd(meshhandle,1,&v1,&v2,&v3));
  v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=-10,v2.z=0;v3.x=10,v3.y=10,v3.z=0;
  printf("MWLMeshTriangleAdd(meshhandle,2,&v1,&v2,&v3)\t\t\t%ld\n",MWLMeshTriangleAdd(meshhandle,2,&v1,&v2,&v3));

  printf("MWLMeshPolygonAdd(meshhandle,0)\t\t\t\t\t%ld\n",MWLMeshPolygonAdd(meshhandle,0));
  printf("MWLMeshPolygonMaterialSet(meshhandle,3)\t\t\t\t%ld\n",MWLMeshPolygonMaterialSet(meshhandle,3));
  v1.x=-10,v1.y=-10,v1.z=0;v2.x=-10,v2.y=10,v2.z=0;v3.x=-20,v3.y=-10,v3.z=0;
  printf("MWLMeshPolygonVertexAdd(meshhandle,&v1)\t\t\t\t%ld\n",MWLMeshPolygonVertexAdd(meshhandle,&v1));
  printf("MWLMeshPolygonVertexAdd(meshhandle,&v2)\t\t\t\t%ld\n",MWLMeshPolygonVertexAdd(meshhandle,&v2));
  printf("MWLMeshPolygonVertexAdd(meshhandle,&v3)\t\t\t\t%ld\n",MWLMeshPolygonVertexAdd(meshhandle,&v3));

  printf("MWLMeshNumberOfMaterialsGet(meshhandle)\t\t\t\t%ld\n",MWLMeshNumberOfMaterialsGet(meshhandle));
  printf("MWLMeshNumberOfPolygonsGet(meshhandle)\t\t\t\t%ld\n",MWLMeshNumberOfPolygonsGet(meshhandle));
  printf("MWLMeshNumberOfVerticesGet(meshhandle)\t\t\t\t%ld\n",MWLMeshNumberOfVerticesGet(meshhandle));


  printf("MWLMeshCameraLightDefaultSet(meshhandle)\t\t\t%ld\n",MWLMeshCameraLightDefaultSet(meshhandle));

  printf("MWLMeshCameraPositionGet(meshhandle,&vertex)\t\t\t");
  retval=MWLMeshCameraPositionGet(meshhandle,&vertex);
  if(retval==RCNOERROR) printf("%g %g %g\n",vertex.x,vertex.y,vertex.z);
  else printf("%ld\n",retval);  
  printf("MWLMeshCameraLookAtGet(meshhandle,&vertex)\t\t\t");  
  retval=MWLMeshCameraLookAtGet(meshhandle,&vertex);
  if(retval==RCNOERROR) printf("%g %g %g\n",vertex.x,vertex.y,vertex.z);
  else printf("%ld\n",retval);
  printf("MWLMeshLightPositionGet(meshhandle,&vertex)\t\t\t");
  retval=MWLMeshLightPositionGet(meshhandle,&vertex);
  if(retval==RCNOERROR) printf("%g %g %g\n",vertex.x,vertex.y,vertex.z);
  else printf("%ld\n",retval);
  printf("MWLMeshLightColorGet(meshhandle,&color)\t\t\t\t");
  retval=MWLMeshLightColorGet(meshhandle,&color);
  if(retval==RCNOERROR) printf("%d %d %d\n",color.r,color.g,color.b);
  else printf("%ld\n",retval);
  
  vertex.x=0,vertex.y=0,vertex.z=100;
  printf("MWLMeshCameraPositionSet(meshhandle,&vertex)\t\t\t%ld\n",MWLMeshCameraPositionSet(meshhandle,&vertex));
  vertex.x=0,vertex.y=0,vertex.z=0;
  printf("MWLMeshCameraLookAtSet(meshhandle,&vertex)\t\t\t%ld\n",MWLMeshCameraLookAtSet(meshhandle,&vertex));
  vertex.x=0,vertex.y=0,vertex.z=101;
  printf("MWLMeshLightPositionSet(meshhandle,&vertex)\t\t\t%ld\n",MWLMeshLightPositionSet(meshhandle,&vertex));
  color.r=150,color.g=150,color.b=150;
  printf("MWLMeshLightColorSet(meshhandle,&color)\t\t\t\t%ld\n",MWLMeshLightColorSet(meshhandle,&color));

  printf("MWLMeshCameraPositionGet(meshhandle,&vertex)\t\t\t");
  retval=MWLMeshCameraPositionGet(meshhandle,&vertex);
  if(retval==RCNOERROR) printf("%g %g %g\n",vertex.x,vertex.y,vertex.z);
  else printf("%ld\n",retval);
  printf("MWLMeshCameraLookAtGet(meshhandle,&vertex)\t\t\t");  
  retval=MWLMeshCameraLookAtGet(meshhandle,&vertex);
  if(retval==RCNOERROR) printf("%g %g %g\n",vertex.x,vertex.y,vertex.z);
  else printf("%ld\n",retval);
  printf("MWLMeshLightPositionGet(meshhandle,&vertex)\t\t\t");
  retval=MWLMeshLightPositionGet(meshhandle,&vertex);
  if(retval==RCNOERROR) printf("%g %g %g\n",vertex.x,vertex.y,vertex.z);
  else printf("%ld\n",retval);
  printf("MWLMeshLightColorGet(meshhandle,&color)\t\t\t\t");
  retval=MWLMeshLightColorGet(meshhandle,&color);
  if(retval==RCNOERROR) printf("%d %d %d\n",color.r,color.g,color.b);
  else printf("%ld\n",retval);

  printf("\nSaving in all 3D formats, this means %ld times\n\n",MWL3DFileFormatNumberOfGet());

  printf("MWL3DFileFormatNamesGet()\t\t\t\t\t");
  array = MWL3DFileFormatNamesGet();
  if(array!=NULL && array[0]!=NULL) printf("Names found\n");
  else printf("No names found\n");

  printf("\n");
  i=0;
  while(array!=NULL && array[i]!=NULL) {
    printf("MWL3DFileFormatIDGet(\"%s\")\t\t\t\t%ld\n",array[i],id=MWL3DFileFormatIDGet(array[i]));
    printf("MWL3DFileFormatExtensionGet(%ld)\t\t\t\t\t%s\n",id,MWL3DFileFormatExtensionGet(id));

    sprintf(buffer,"ram:%ld.%s",id,MWL3DFileFormatExtensionGet(id));

    printf("MWLMeshSave3D(meshhandle,id,\"%s\",NULL)\t\t\t%ld\n",buffer,MWLMeshSave3D(meshhandle,id,buffer,NULL));

    i++;
  }

  printf("\nSaving in all 2D formats, this means %ld times\n\n",MWL2DFileFormatNumberOfGet());

  printf("Number of drawing modes is %ld\n\n",MWLDrawModeNumberOfGet());
  printf("MWLDrawModeNamesGet()\t\t\t\t\t\t");
  array = MWLDrawModeNamesGet();
  if(array!=NULL && array[0]!=NULL) printf("Names found\n");
  else printf("No names found\n");

  if(array!=NULL && array[0]!=NULL) {
    printf("MWLDrawModeIDGet(\"%s\")\t\t\t\t\t%ld\n",array[0],dm=MWLDrawModeIDGet(array[0]));
    
    printf("MWL2DFileFormatNamesGet()\t\t\t\t\t");
    array = MWL2DFileFormatNamesGet();
    if(array!=NULL && array[0]!=NULL) printf("Names found\n");
    else printf("No names found\n");


    printf("\n");
    i=0;
    while(array!=NULL && array[i]!=NULL) {
      printf("MWL2DFileFormatIDGet(\"%s\")\t\t\t%ld\n",array[i],id=MWL2DFileFormatIDGet(array[i]));
      printf("MWL2DFileFormatExtensionGet(%ld)\t\t\t\t\t%s\n",id,MWL2DFileFormatExtensionGet(id));

      sprintf(buffer,"ram:%ld.%s",id,MWL2DFileFormatExtensionGet(id));

      printf("MWLMeshSave2D(meshhandle,id,\"%s\",TVWPERSP,dmNULL)\t\t%ld\n",buffer,MWLMeshSave2D(meshhandle,id,buffer,TVWPERSP,dm,NULL));

      i++;
    }
  }
  
  printf("\nMWLMeshDelete(meshhandle)\t\t\t\t\t%ld\n",MWLMeshDelete(meshhandle));
  meshhandle=0;
}
