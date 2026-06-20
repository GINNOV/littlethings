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
#include "td.h"
#include "geoa.h"

/************************** test main *******************************/
void main(void) {
  ULONG space,i,ret,offset;
  TDfloat fa3[3];
  STRPTR name,ext;
  UBYTE  outfile[200];
    
  if((space = tdSpaceNew())!=0) {
    printf("Space created\n");

    tdAdd(space,TD_SURFACE);
    i=tdNofGet(space,TD_MATERIAL);
    fa3[0]=1.0,fa3[1]=0.0,fa3[2]=0.0;
    tdMaterialSetfa(space,TD_DIFFUSE,i,fa3);
    tdNameSet(space,TD_MATERIAL,i,"red");
    tdMaterialSetf(space,TD_SHININESS,i,0.8);
    tdMaterialSetf(space,TD_TRANSPARENCY,i,0.2);

    name[0]='\0';
    tdNameGet(space,TD_MATERIAL,i,&name);
    printf("Created surface %s\n",name);

    tdAdd(space,TD_SURFACE);
    i=tdNofGet(space,TD_MATERIAL);
    fa3[0]=0.0,fa3[1]=0.0,fa3[2]=1.0;
    tdMaterialSetfa(space,TD_DIFFUSE,i,fa3);
    tdNameSet(space,TD_MATERIAL,i,"blue");
    tdMaterialSetf(space,TD_SHININESS,i,0.8);
    tdMaterialSetf(space,TD_TRANSPARENCY,i,0.2);

    name[0]='\0';
    tdNameGet(space,TD_MATERIAL,i,&name);
    printf("Created surface %s\n",name);

    tdAdd(space,TD_POLYMESH);
    tdNameSet(space,TD_OBJECT,1,"RedBlue");

    name[0]='\0';
    tdNameGet(space,TD_OBJECT,1,&name);
    printf("Created polymesh %s\n",name);

    tdCurrent(space,TD_OBJECT,1);
      tdCurrent(space,TD_MATERIAL,1);
        tdBegin(space,TD_MATGROUP);
          tdBegin(space,TD_POLYGON);
           tdVertexAdd3f(space,-10.0,-10.0,0.0);
            tdVertexAdd3f(space,10.0,10.0,0.0);
            tdVertexAdd3f(space,-10.0,10.0,0.0);
      tdCurrent(space,TD_MATERIAL,2);
        tdBegin(space,TD_MATGROUP);
          tdBegin(space,TD_POLYGON);
            tdVertexAdd3f(space,-10.0,-10.0,0.0);
            tdVertexAdd3f(space,10.0,-10.0,0.0);
            tdVertexAdd3f(space,10.0,10.0,0.0);
        tdEnd(space,TD_MATGROUP);

      printf("The polymesh has :\n");
      printf(" a total number of vertices        : %ld\n",tdNofGet(space,TD_VERTEX));
      printf(" a total number of polygons        : %ld\n",tdNofGet(space,TD_POLYGON));
      printf(" a total number of material groups : %ld\n",tdNofGet(space,TD_MATGROUP));
    tdEnd(space,TD_OBJECT);

    printf("The space has :\n");
    printf(" a total number of materials       : %ld\n",tdNofGet(space,TD_MATERIAL));

/*    
{
STRPTR *formats=NULL;

printf("Filling arrays : %ld\n",fill3DFormatArrays());

printf("Number of supported 3D savers : %ld\n",tdo3DSaverNofGet());
formats=tdo3DSaverNamesGet();
if(formats!=NULL) {
	i=0;
	printf("Supported savers are :\n\n");
	while(formats[i]!=NULL) {
		printf("   %s -> %s\n",formats[i],tdo3DSaverExtGet(formats[i]));
		i++;
	}
	printf("\n");
}

printf("Saving mesh : %ld\n\n",meshSave3D(mesh,formats[i-1],"ram:test",NULL));

printf("Number of supported 3D loaders : %ld\n",tdo3DLoaderNofGet());
formats=tdo3DLoaderNamesGet();
if(formats!=NULL) {
	i=0;
	printf("Supported loaders are :\n\n");
	while(formats[i]!=NULL) {
		printf("   %s\n",formats[i]);
		i++;
	}
	printf("\n");
}

printf("Loading mesh : %ld\n\n",meshLoad3D(&mesh2,"ram:test",NULL));

free3DFormatArrays();
printf("Arrays free\n");
}
*/


#define INFILE "ram:tank.geo"
#define OUTFILE "ram:pout"


	printf("Trying to load a file\n");
	if((ret=td3XCheckFile(INFILE))==ER_NOERROR) {
		printf("Seems to be a %s file\n",td3XName());
	    if((ret=td3XLoad(space,INFILE,TD_OBJECT,NULL,&offset))==ER_NOERROR) {
		    printf("Total number of objects : %ld\n",tdNofGet(space,TD_OBJECT));
		} else {
			printf("Object not loaded : %ld offset (%ld)\n",ret,offset);
		}
	} else {
		printf("File type not known : %ld\n",ret);
	}

	if((ext=td3XExt())!=NULL) {
		sprintf(outfile,"%s.%s",OUTFILE,ext);
	}
	if((ret=td3XSave(space,outfile,TD_OBJECT,2,NULL))!=ER_NOERROR) printf("Save failed : %ld\n",ret);
	else printf("Saved\n");

	printf("Deleting space\n");
	tdSpaceDelete(space);
  }
}  