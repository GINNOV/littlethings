#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <stdarg.h>
#include <math.h>
#include <string.h>
#include <ctype.h>

#define XLOOP(nbre) for(x=0;x<nbre;x++)
#define YLOOP(nbre) for(y=0;y<nbre;y++)
/*==================================================================================*/
typedef struct _Point3D
{
	float x,y,z;
	float u,v;
} Point3D;
/*==================================================================================*/
void DoBoing(char *filename,int xfaces,int yfaces,int xsubfaces,int ysubfaces)
{
FILE*		 fp;
Point3D* P;
int x,y;
int Pxnb,Pynb,Fxnb,Fynb,Fnb,Pnb;
float xstep,ystep;
float ustep,vstep;
float rotx,roty;
float radius;
int i;


	Fxnb=xfaces*xsubfaces;
	Fynb=yfaces*ysubfaces;
	Fnb =Fxnb*Fynb;
	Pxnb=Fxnb+1;
	Pynb=Fynb+1;
	Pnb =Pxnb*Pynb;

	xstep=(2.0*3.14159265)/(float)(Fxnb);	/* 360° /faces */
	ystep=(3.14159265)/(float)(Fynb);		 /*  180° /faces */
	ustep=1.0/(float)(Fxnb);
	vstep=1.0/(float)(Fynb);

	P=malloc(Pxnb*Pynb*sizeof(Point3D));
	if(P==((void*)0)) return;

	fp = fopen(filename, "w");
	if (!fp)
		{ printf( "DoBoing can't open <%s>\n",filename); return; }

	fprintf(fp, "# DoBoing - Alain Thellier - Paris - France\n");
	fprintf(fp, "#   size: %ld(X%ld) X %ld(X%ld) faces\n",xfaces,xsubfaces,yfaces,ysubfaces);

	fprintf(fp, "\nmtllib boingball.mtl\n\n");

	/* do points */
	YLOOP(Pynb)
	XLOOP(Pxnb)
	{
	i=y*Pxnb+x;
	rotx=((float)x)*xstep;
	roty=((float)y)*ystep;
	P[i].x=cos(rotx);
	P[i].z=sin(rotx);
	P[i].y=cos(roty);
	radius=sin(roty);
	P[i].x=radius*P[i].x;
	P[i].z=radius*P[i].z;
	P[i].u=((float)x)*ustep;
	P[i].v=((float)y)*vstep;
	}

	fprintf(fp, "# %ld vertices\n", Pnb);
	XLOOP(Pnb)
		fprintf(fp, "v %2.6f  %2.6f  %2.6f\n",P[x].x,P[x].y,P[x].z);
	fprintf(fp, "\n\n");

	fprintf(fp, "# %ld normals\n", Pnb);	/* math note: for a sphere vertexnormal=vertex */
	XLOOP(Pnb)
		fprintf(fp, "vn %2.6f  %2.6f  %2.6f\n",P[x].x,P[x].y,P[x].z);
	fprintf(fp, "\n\n");

	fprintf(fp, "# %ld UV values\n", Pnb);
	XLOOP(Pnb)
		fprintf(fp, "vt %2.6f  %2.6f\n",P[x].u,P[x].v);
	fprintf(fp, "\n\n");

	fprintf(fp, "# %ld faces = %ld triangles\n", Fnb,Fnb*2);

	fprintf(fp, "g red_faces\n");
	fprintf(fp, "usemtl mat_red\n");

	Fnb=0;
	YLOOP(Fynb)
	XLOOP(Fxnb)
	{
	i=(y*Pxnb+x) + 1;
	if((y/ysubfaces+x/xsubfaces) % 2)
		{fprintf(fp, "f %ld %ld %ld %ld \n",i,i+1,i+Pxnb+1,i+Pxnb);Fnb++;}
	}
	fprintf(fp, "# %ld red faces = %ld triangles\n\n", Fnb,Fnb*2);


	fprintf(fp, "g white_faces\n");
	fprintf(fp, "usemtl mat_white\n");

	Fnb=0;
	YLOOP(Fynb)
	XLOOP(Fxnb)
	{
	i=(y*Pxnb+x) + 1;
	if(!((y/ysubfaces+x/xsubfaces) %2 ))
		{fprintf(fp, "f %ld %ld %ld %ld \n",i,i+1,i+Pxnb+1,i+Pxnb);Fnb++;}
	}
	fprintf(fp, "# %ld red faces = %ld triangles\n\n", Fnb,Fnb*2);

	free(P);
	fclose(fp);
	printf("DoBoing: %s %ld(X%ld) X %ld(X%ld) faces\n",filename,xfaces,xsubfaces,yfaces,ysubfaces);

}
/*==================================================================*/
int main(int argc, char *argv[])
{
char filename[256];
int xfaces,yfaces,xsubfaces,ysubfaces;

	if (argc == 2)
		{
		DoBoing(argv[1],8,6,4,4);
		return(0);
		}

	if (argc >= 6)
		{
		sscanf(argv[2],"%d",&xfaces);
		sscanf(argv[3],"%d",&yfaces);
		sscanf(argv[4],"%d",&xsubfaces);
		sscanf(argv[5],"%d",&ysubfaces);
		DoBoing(argv[1],xfaces,yfaces,xsubfaces,ysubfaces);
		return(0);
		}

	printf("usage: DoBoing filename xfaces yfaces xsubfaces ysubfaces \n");
	return(1);
}
/*==================================================================================*/
