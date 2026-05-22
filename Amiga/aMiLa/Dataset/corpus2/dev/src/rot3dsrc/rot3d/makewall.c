/* this program takes a list of IFF files and generates wall data from them
Iffs must be 288X75X4 and must be of one of the 2 pallettes that you choose.
Walls are converted to our own semi-chunky mode so that the megadraw routine
can digest them easier.  500 converter would want to modify this to create
2 2bitplane chunks.  This program outputs the file walls.c which is then made
into the main program. */

#define DEPTH 4
#define WIDTH 256
#define HEIGHT 128

void BreakWall(struct BitMap *brush);
void PrintWall(struct BitMap *brush,char *name,short num);
void FreePlanes(struct BitMap *brush);

struct BitMap *brush=NULL;
struct ILBM_info *info;
FILE *bfile,*cfile,*hfile,*script;
char *c;
char scanval[100];
BYTE palnums[500];
char Name[100];
char Palette[10];
BYTE palno;

main(int argc,char **argv)
{
	short i,brushno,numbrushes;

	numbrushes=argc-1;
	if (numbrushes==0) {
		printf("Usage: %s <script name>\n",argv[0]);
		exit(1);
	}

	cfile=fopen("walls.c","w");
	if (!cfile)	{
		printf("Could not open walls.c for write\n");
		FreePlanes(brush);
		exit(1);
	}

	bfile=fopen("walls.dat","w");
	if (!bfile)	{
		printf("Could not open walls.dat for write\n");
		FreePlanes(brush);
		fclose(cfile);
		exit(1);
	}

	hfile=fopen("walls.h","w");
	if (!hfile)	{
		printf("Could not open walls.h for write\n");
		FreePlanes(brush);
		fclose(cfile);
		fclose(bfile);
		exit(1);
	}

	script=fopen(argv[1],"r");
	if (!script) {
		printf("Could not open script file %s\n",argv[1]);
		fclose(hfile);
		fclose(cfile);
		fclose(bfile);
		goto QUIT;
	}

	numbrushes=0;

	fprintf(cfile,"#include \"walls.h\"\n");
	while(c=fgets(scanval,98,script)) {
		numbrushes++;
		sscanf(scanval,"%s %s",Name,Palette);
		palno=atoi(Palette);
		printf("%s %d\n",Name,palno);
		info=read_iff(Name);
		if (!info) {
			printf("Could not open %s for read\n",Name);
			fclose(hfile);
			goto QUIT;
		}
		brush=&info->bitmap;
		if(numbrushes==1) {
			if (brush->Depth!=5) {
				printf("Aborting on %s\n",Name);
				printf("brush depth %d != 5\n",brush->Depth);
				FreePlanes(brush);
				goto QUIT;
			}
			fprintf(cfile,"unsigned short palette[] = {");
			for	(i=0; i<(1<<5)*3; i+=3)
			{
				if (!(i%4))	fprintf(cfile,"\n");
				fprintf(cfile,"0x%.4X, ",(info->cmap[i]/16)<<8|
				(info->cmap[i+1]/16)<<4|info->cmap[i+2]/16);
			}
			fprintf(cfile,"\n");
			fprintf(cfile,"};\n");
			FreePlanes(brush);
		} else {
			palnums[numbrushes-2]=palno;
			if (brush->Depth!=4) {
				printf("Aborting on %s\n",Name);
				printf("brush depth %d != DEPTH\n",brush->Depth);
				FreePlanes(brush);
				goto QUIT;
			}
			if (brush->BytesPerRow!=WIDTH/8) {
				printf("Aborting on %s\n",Name);
				printf("brush width %d != WIDTH\n",brush->BytesPerRow*8);
				FreePlanes(brush);
				goto QUIT;
			}
			if (brush->Rows!=HEIGHT) {
				printf("Aborting on %s\n",Name);
				printf("brush rows %d != HEIGHT\n",brush->Rows);
				FreePlanes(brush);
				goto QUIT;
			}

			BreakWall(brush);

			PrintWall(brush,Name,numbrushes-2);

			FreeMem(brush->Planes[0],brush->BytesPerRow*brush->Rows*4);
		}
	}

	fprintf(hfile,"#define NUMWALLS %d\n",numbrushes-1);
	fprintf(hfile,"extern unsigned long *brushmem[NUMWALLS];\n");
	fprintf(hfile,"extern unsigned short palette[];\n");
	fprintf(hfile,"extern char brushpal[];\n");
	fclose(hfile);

	fprintf(cfile,"unsigned long *brushmem[NUMWALLS];\n");
	fprintf(cfile,"char brushpal[%d]= {",numbrushes-1);
	for	(brushno=0;	brushno<numbrushes-1; brushno++) {
		if(!(brushno%8)) fprintf(cfile,"\n");
		fprintf(cfile," %d,",palnums[brushno]);
	}
	fprintf(cfile,"\n};\n");
	fprintf(cfile,"void loadwalls() {\n");
	fprintf(cfile,"\tFILE *file; int i;\n");
	fprintf(cfile,"\tchar *mem;\n");
	fprintf(cfile,"\n");
	fprintf(cfile,"\tmem=(char *)malloc(NUMWALLS*32768);\n");
	fprintf(cfile,"\tif(!mem) exit(1);\n");
	fprintf(cfile,"\tfile=fopen(\"walls.dat\",\"r\");\n");
	fprintf(cfile,"\tfread(mem,32768,NUMWALLS,file);\n");
	fprintf(cfile,"\tfor(i=0;i<NUMWALLS;i++)\n");
	fprintf(cfile,"\t\tbrushmem[i]=(unsigned long *)(mem+i*32768);\n");
	fprintf(cfile,"}\n");


QUIT:

	fclose(script);
	fclose(cfile);
	fclose(bfile);

	exit(0);
}

void PrintWall(struct BitMap *brush,char *name,short num)
{
	short i,j,k;
	ULONG val;

	for (j=0;j<brush->Rows*2;j++) {
		for (k=0;k<brush->BytesPerRow;k++) {
			val=*(ULONG *)(brush->Planes[0]+k*4+j*brush->BytesPerRow*4);
			fwrite((void *)&val,4,1,bfile);
		}
	}
}

void FreePlanes(struct BitMap *brush)
{
	short i;
	for (i=0;i<4;i++)
	{
		FreeMem(brush->Planes[i],brush->BytesPerRow*brush->Rows);
		brush->Planes[i]=0;
	}
}


void BreakWall(struct BitMap *brush)
{
short i,j,k,l,bit;
UBYTE current=0;
PLANEPTR new;
	new = AllocMem(brush->BytesPerRow*brush->Rows*4*2,MEMF_FAST);
	if (!new) {
		printf("Could not get fast ram for brush!\n");
		FreePlanes(brush);
		fclose(cfile);
		exit(1);
	}
	for (j=0;j<brush->Rows;j++)
		for (k=0;k<brush->BytesPerRow;k++) {
			for(bit=7;bit>=0;bit--) {
				current=0;
				for	(i=0;i<4;i++) {
					UBYTE temp;
					temp=*(UBYTE *)(brush->Planes[i]+(j*brush->BytesPerRow+k))&(1<<bit);
					temp=temp>>bit;
					current|=temp<<((i)+2);
				}
				*(UBYTE	*)(new+(7-bit)+k*8+j*brush->BytesPerRow*8)=current;
			}
		}
	FreePlanes(brush);
	brush->Planes[0]=new;
}


void OldBreakWall(struct BitMap *brush)
{
short i,j,k,l;
UBYTE current=0;
PLANEPTR new;

	new = AllocMem(brush->BytesPerRow*brush->Rows*4,MEMF_FAST);
	if (!new) {
		printf("Could not get fast ram for brush!\n");
		FreePlanes(brush);
		fclose(cfile);
		exit(1);
	}

	for (i=0;i<4;i++)
	{
		for (j=0;j<brush->Rows;j++)
			for (k=0;k<brush->BytesPerRow;k++)
			{
				current=*(UBYTE *)(brush->Planes[i]+(j*brush->BytesPerRow+k));
				*(UBYTE *)(new+i+k*4+j*brush->BytesPerRow*4)=current;
			}
	}
	FreePlanes(brush);
	brush->Planes[0]=new;
}
