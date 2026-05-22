
#include <proto/exec.h>
#include <proto/utility.h>

#include <exec/interrupts.h>
#include <stdio.h>
#include <dos/dos.h>

#define BUFSIZE 1024
//#define PACKETSIZE BUFSIZE  		/* no compr */
//#define PACKETSIZE BUFSIZE/4		/* adpcm1 */
#define PACKETSIZE BUFSIZE*3/8	/* adpcm2 */
#define COMPR 2

/* prototypes */
BOOL InitDelfina(void);
void CleanupDelfina(void);
BOOL StartDelfina(int, int, int);
void StopDelfina(void);
int DelfPacket(void *,int);


char diskbuf[PACKETSIZE];
extern int delfrate, delfsig;

int main(char **argv, int argc)
{
	FILE *fh;
	int rate,sigmask;
	
	if (argc!=3) {
		printf("Usage: delfphone <samplerate> <outfile>\n");
		return(10);
	}
	
/* get samplerate*/	
	rate=atoi(argv[1]);
	
/* open output file */
	if (!(fh=fopen(argv[2],"wb"))) {
		printf("no file!\n");
		return(10);
	}
	
/*	Init delfina stuff */
	if (!InitDelfina()) {
		printf("Delfina init failed!\n");
		fclose(fh);
		return(10);
	}
	if (!StartDelfina(rate,BUFSIZE,COMPR)) {
		printf("Delfina startup failed!\n");
		CleanupDelfina();
		fclose(fh);
		return(10);
	}
	
/* write header */	
	fwrite("ADPCM3",6,1,fh);
	fwrite(&delfrate,4,1,fh);
	printf("Actual samplerate: %d\n",delfrate);
	
/* main loop */	
	sigmask=delfsig | SIGBREAKF_CTRL_C;
	
	while (!(Wait(sigmask) & SIGBREAKF_CTRL_C)) {
		DelfPacket(diskbuf,PACKETSIZE);
		fwrite(diskbuf,PACKETSIZE,1,fh);
	}		
		
	StopDelfina();	
	CleanupDelfina();
	fclose(fh);
}
