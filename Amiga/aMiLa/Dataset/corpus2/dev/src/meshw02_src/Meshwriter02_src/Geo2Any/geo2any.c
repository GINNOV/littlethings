/*
**      $VER: geo2any.c 1.00 (28.3.99)
**
**      Sample converter program which convertes VideoScape ascii (GEO)
**      files with the help of the MeshWriter library.
**
**      Based on the idea from Stephan Bodmer which made not only Geo2Vrml,
**      but the VrmlViewer and VrmlEditor too. Go and get them !!
**
**      Stephan Bielmann
*/

/*
** ANSI standart includes
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifndef WITHMWLLIB
#include "/meshlib.h"
#else
#include <meshwriter/meshwriter.h>
#include <pragma/meshwriter_lib.h>
#include <clib/exec_protos.h>
struct MeshWriterBase *MeshWriterBase = NULL;
#endif

FILE *fp=NULL;
unsigned long *indexlist=NULL;
ULONG mesh;
TOCLColor colorTbl[] = {
{  0,  0,  0},{  0,  0,178},{  0,178,  0},{  0,178,178},{178,  0,  0},{255,127,255},
{204,153,102},{127,127,127},{  0,  0,  0},{102,102,255},{102,255,102},{  0,255,100},
{255,102,102},{255,204,255},{255,255,  0},{255,255,255}
};
ULONG materials[16];

void finish() {
        free(indexlist);
        fclose(fp);
        MWLMeshDelete(mesh);
#ifdef WITHMWLLIB
        CloseLibrary((APTR) MeshWriterBase);
#endif

        exit(0);
}

void initmaterials() {
        long i;
        
		for(i=0;i<16;i++) {
				MWLMeshMaterialAdd(mesh,&(materials[i]));
				MWLMeshMaterialDiffuseColorSet(mesh,materials[i],&(colorTbl[i]));
        }
}

void main(int argc, char *argv[]) {
        char header[10];
        unsigned long vertices=0,polygons=0,material=0;
        unsigned long linecounter=0,ret;
        unsigned long points[1000];
        long i;
        STRPTR *fileformats=NULL;
        TOCLVertex v;

#ifdef WITHMWLLIB
        if (!(MeshWriterBase = (APTR) OpenLibrary("meshwriter.library", 0)))
        {
                printf("Could not open the meshwriter.library\n");
                exit(30);
        }
#endif
    
        printf("\nThis tool is using MeshWriter.library by Stephan Bielmann.\n\n");

        if(argc!=4) {
                printf("Usage %s inputfile outputfile formatid\n\n",argv[0]);

                fileformats=MWL3DFileFormatNamesGet();
                printf("Valid format id's are :\n");
                i=0;
                while(fileformats!=NULL && fileformats[i]!=NULL) {
                        printf("%2ld : %s\n",MWL3DFileFormatIDGet(fileformats[i]),fileformats[i]);
                        i++;
                }
                printf("\n");

                exit(0);
        }

        mesh=MWLMeshNew();
        if(mesh==0) {
                printf("Could not creat a new mesh.\n");
                exit(0);
        }

        initmaterials();

        fp=fopen(argv[1],"r");
        if(fp==NULL) {
                printf("Could not open the input file.\n");
                exit(0);
        }

        fscanf(fp,"%4s",header);
        if(strncmp(header,"3DG1",4)!=0) {
                printf("Inputfile is not a GEO ascii file.\n");
                finish();
        }
        
        linecounter++;
        printf("Inputfile is a GEO ascii file.\n");

        fscanf(fp,"%ld",&vertices);
        if(vertices==0) {
                printf("No vertices were found in the inputfile.\n");
                finish();
        }
        
        linecounter++;
        printf("Found %ld vertices.\nProcessing the vertices.\n",vertices);

        indexlist=malloc(sizeof(unsigned long)*vertices);
        if(indexlist==NULL) {
                printf("Not enough memory to allocate the indexlist.\n");
                finish();
        }

        for(i=0;i<vertices;i++,linecounter++) {
                // GEO z equals to the libraries y
                if(fscanf(fp,"%f %f %f",&v.x,&v.z,&v.y)==EOF) {
                        printf("Error while reading the vertices, at line %ld.\n",i+1);
                        finish();
                }

        ret=MWLMeshVertexAdd(mesh,&v,&(indexlist[i]));
                if(ret!=RCNOERROR) {
                        printf("Could not add a new vertex %ld.\n",ret);
                        finish();
                }
        }

        printf("Processing the polygons.\n");

        while(fscanf(fp,"%ld",&polygons)!=EOF) {
                MWLMeshPolygonAdd(mesh,0);
                // we limit us to 200 points per polygon, as in the library itself
                for(i=0;i<polygons&&i<200;i++) {
                        if(fscanf(fp,"%ld",&(points[i]))==EOF) {
                                printf("Error while reading the polygon information, at line %ld.\n",linecounter);
                                finish();
                        } else {
                                if(points[i]>=vertices) {
                                        printf("A polygon its vertex index is not valid %ld at line %ld.\n",points[i],linecounter);
                                        finish();
                                }
                        }
                }

                // remember, GEO is clockwise, the library counterclockwise
                for(i=polygons-1;i>=0;i--) {
                        ret=MWLMeshPolygonVertexAssign(mesh,indexlist[points[i]]);
                        if(ret!=RCNOERROR) {
                                printf("Could not assign a vertex to the polygo %ld.\n",ret);
                                finish();
                        }
                }

                if(fscanf(fp,"%ld",&material)==EOF) {
                        printf("Error while reading the material information, at line %ld.\n",linecounter);
                        finish();
                } else {
                        // we are using only 16 out of 256 colors.
                        MWLMeshPolygonMaterialSet(mesh,materials[material%16]);
                }

                linecounter++;
        }

        printf("Found %ld polygons.\n",linecounter-2-vertices);

        printf("Inputfile processed.\n");

        printf("Writing the outputfile.\n");
        ret=MWLMeshSave3D(mesh,atoi(argv[3]),argv[2],NULL);
        if(ret!=RCNOERROR) {
                printf("Could not save the outputfile %ld.\n",ret);
        }

        printf("Cleaning up.\n");
        MWLMeshDelete(mesh);
        free(indexlist);
        fclose(fp);

        printf("Finished.\n\n");

#ifdef WITHMWLLIB
        CloseLibrary((APTR) MeshWriterBase);
#endif
}  
