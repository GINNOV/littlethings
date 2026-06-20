
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <libraries/delfina.h>
#include <exec/interrupts.h>
#include <stdio.h>
#include <dos/dos.h>

#include "delfph.h"

/* (note: tabsize=4) */


/* prototypes */
BOOL InitDelfina(void);
void CleanupDelfina(void);
BOOL StartDelfina(int, int, int, int);
void StopDelfina(void);
int DelfPacket(void *,int,ULONG *);
int GetClosestDelfRate(int , int *, int *);

/* seven FIR lowpass filters, 33 taps. */
#define TAPS 33

int d_fir2[TAPS]={0x2cd0, 0x33c7, 0xffff9bdb, 0xffffbac7, 0xe45d,
	0x3261, 0xfffe45b1, 0x540d, 0x2db6c, 0xfffe4d8d,
	0xfffbd861, 0x49f49, 0x560c8, 0xfff4cf9e, 0xfff9bd9e,
	0x27e542, 0x469469, 0x27e542, 0xfff9bd9e, 0xfff4cf9e,
	0x560c8, 0x49f49, 0xfffbd861, 0xfffe4d8d, 0x2db6c,
	0x540d, 0xfffe45b1, 0x3261, 0xe45d, 0xffffbac7,
	0xffff9bdb, 0x33c7, 0x2cd0 };
	
int d_fir3[TAPS]={0x202d, 0x4d23, 0xfffffc7f, 0xffff5e4b, 0xffff92c1,
	0xf6b1, 0x163a0, 0xffff1eef, 0xfffd112c, 0xffffcf4e,
	0x4df15, 0x31e72, 0xfff93064, 0xfff5ed69, 0x840fc,
	0x277b75, 0x373633, 0x277b75, 0x840fc, 0xfff5ed69,
	0xfff93064, 0x31e72, 0x4df15, 0xffffcf4e, 0xfffd112c,
	0xffff1eef, 0x163a0, 0xf6b1, 0xffff92c1, 0xffff5e4b,
	0xfffffc7f, 0x4d23, 0x202d };
	
int d_fir4[TAPS]={0x2165, 0x33c9, 0xb8d, 0xffff90ce, 0xffff1551,
	0xffff3f90, 0x7132, 0x21110, 0x28cd8, 0x8462,
	0xfffc76e2, 0xfff96c09, 0xfffb7b5f, 0x4c37d, 0x1306a1,
	0x201c6f, 0x256a61, 0x201c6f, 0x1306a1, 0x4c37d,
	0xfffb7b5f, 0xfff96c09, 0xfffc76e2, 0x8462, 0x28cd8,
	0x21110, 0x7132, 0xffff3f90, 0xffff1551, 0xffff90ce,
	0xb8d, 0x33c9, 0x2165 };
	
int d_fir5[TAPS]={0xfffff453, 0xffffbfdf, 0xffff918d, 0xffff947d, 0xa7b,
	0xe904, 0x1b2ac, 0x19835, 0x4dc, 0xfffd4c27,
	0xfffaf62b, 0xfffb408d, 0xffffe705, 0x8d8b2, 0x13b901,
	0x1cabd2, 0x20223e, 0x1cabd2, 0x13b901, 0x8d8b2,
	0xffffe705, 0xfffb408d, 0xfffaf62b, 0xfffd4c27, 0x4dc,
	0x19835, 0x1b2ac, 0xe904, 0xa7b, 0xffff947d,
	0xffff918d, 0xffffbfdf, 0xfffff453 };
	
int d_fir6[TAPS]={0xffffdf1d, 0xffffc175, 0xffffbf0e, 0x4a8, 0x9a59,
	0x13f81, 0x16de8, 0x9e44, 0xfffeb963, 0xfffc7301,
	0xfffb3fe4, 0xfffcc54b, 0x1f380, 0xa4424, 0x139add,
	0x1afa46, 0x1dc756, 0x1afa46, 0x139add, 0xa4424,
	0x1f380, 0xfffcc54b, 0xfffb3fe4, 0xfffc7301, 0xfffeb963,
	0x9e44, 0x16de8, 0x13f81, 0x9a59, 0x4a8,
	0xffffbf0e, 0xffffc175, 0xffffdf1d };
	
int d_fir7[TAPS]={0xffffed47, 0x172a, 0x5a1d, 0xb53d, 0xf3ac,
	0xcaff, 0x11b, 0xfffe9ecb, 0xfffd138e, 0xfffc2f17,
	0xfffce3ea, 0xffffe201, 0x532d2, 0xc0786, 0x12dbab,
	0x17e98c, 0x19c6e3, 0x17e98c, 0x12dbab, 0xc0786,
	0x532d2, 0xffffe201, 0xfffce3ea, 0xfffc2f17, 0xfffd138e,
	0xfffe9ecb, 0x11b, 0xcaff, 0xf3ac, 0xb53d,
	0x5a1d, 0x172a, 0xffffed47 };
	
int d_fir8[TAPS]={0x2ab1, 0x5e23, 0x9a09, 0xb6de, 0x8687,
	0xffffe6ea, 0xfffedd9e, 0xfffdacaf, 0xfffcd31c, 0xfffcf150,
	0xfffe9517, 0x1fd6b, 0x6ed43, 0xca374, 0x1200e3,
	0x15d523, 0x1738a9, 0x15d523, 0x1200e3, 0xca374,
	0x6ed43, 0x1fd6b, 0xfffe9517, 0xfffcf150, 0xfffcd31c,
	0xfffdacaf, 0xfffedd9e, 0xffffe6ea, 0x8687, 0xb6de,
	0x9a09, 0x5e23, 0x2ab1 };
		
int *d_firs[7] = {d_fir2, d_fir3, d_fir4, d_fir5, d_fir6, d_fir7, d_fir8 };		

/* internal variables, don't worry about these.. :) */		
struct Library *DelfinaBase;
extern int delfcode;
struct Interrupt delfint;
struct DelfPrg *delfprg;
int delfopen=0,delfbuf,delfrecbuf,delfcopyflags;
int d_freqtab[28] = {8000, 9600, 8000, 16000, 9600, 8000, 9600, 27429, 27429,
	8000, 27429, 9600, 16000, 27429, 48000, 32000, 27429, 8000, 27429, 9600,
	32000, 48000, 27429, 16000, 48000, 27429, 32000, 48000 };
int d_divtab[28] = {5, 5, 4, 7, 4, 3, 3, 8, 7, 2, 6, 2, 3, 5, 8, 5, 4, 1, 
					3, 1, 3, 4, 2, 1, 2, 1, 1, 1 };


/* some more important variables: */

int delfsig  = 0;	/* signal _mask_ to wait, pass this directly to Wait() */
int delfrate = 0;       /* the actual sample rate currently in use */



/*****************************************************************
	Init Delfina stuff. 
	
	Opens delfina.library etc. Call this function only once, when
	amiphone is started (or when user selects Delfina as sampler).
	This function will also allocate 'delfsig' signal bit (See above)
	
	Result: TRUE if succeeded, FALSE if not
	
	Usually only fails if Delfina board is not installed.
******************************************************************/
BOOL InitDelfina(void)
{
	if (delfopen) { /* just a check, if we are called multiple times */
		delfopen++;
		 return(TRUE);	
	}
	
/* open library */	
	if (!(DelfinaBase=OpenLibrary("delfina.library",2))) return(FALSE);
		
/* add program */		
	if (!(delfprg=Delf_AddPrg(&delfcode))) {
		CloseLibrary(DelfinaBase); DelfinaBase = NULL;
		return(FALSE);
	}
		
/* create intserver, allocate sigbit */		
	memset(&delfint,0,sizeof(struct Interrupt));
	if (!Delf_AddIntServer(delfprg->prog,&delfint)) {
		Delf_RemPrg(delfprg);delfprg=NULL;
		CloseLibrary(DelfinaBase); DelfinaBase = NULL;
		return(FALSE);
	}
	delfsig=(int)delfint.is_Data;	
	
	delfopen++;
	return(TRUE);
}

	
	
	
/*****************************************************************
	Cleanup Delfina stuff	
	
	Deallocates everything that was allocated in InitDelfina().
	Call this in exit of amiphone, or when user deselects Delfina
	as sampler.. 
******************************************************************/
void CleanupDelfina(void)
{
	if (--delfopen) return;
	
	Delf_RemIntServer(delfprg->prog);
	Delf_RemPrg(delfprg);
	CloseLibrary(DelfinaBase);
}




/*****************************************************************
	Start recording.
	
	Inputs:
		samplerate	= sample rate in Hz. The closest available
					  freq will be returned in delfrate
					  
		bufsize		= packet size in SAMPLES. Must be a multiple 			  
					  of 8!
					  
		compr		= compression mode. 0=none (8bit signed),			  
					  1=adpcm2, 2=adpcm3
					  
		ch			= input channel, 0=left, 1=right
		
	Result: TRUE if succeeded, FALSE if not	
******************************************************************/

BOOL StartDelfina(int samplerate, int bufsize, int compr, int ch)
{
	int freq,div;
	
/* find the closest frequency, and freq and div values. */
	delfrate = GetClosestDelfRate(samplerate, &freq, &div);
	
/* allocate delfina's data buffer */	
	if (compr) 
		delfbuf=Delf_AllocMem(bufsize/4,DMEMF_YDATA|DMEMF_ALIGN_8K);
	else
		delfbuf=Delf_AllocMem(bufsize,DMEMF_YDATA|DMEMF_ALIGN_8K);
		
	if (!delfbuf) 
	{
		printf("Delf_AllocMem 1 failed!\n");
		return(FALSE);
	}

/* allocate delfina's rec buffer */
	delfrecbuf=Delf_AllocMem(bufsize*2*div,DMEMF_LDATA);
	if (!delfrecbuf) {
		Delf_FreeMem(delfbuf,DMEMF_YDATA);
		printf("Delf_AllocMem 2 failed!\n");
		return(FALSE);
	}
	
/* tell parameters to DSP code */		
	Delf_Run(delfprg->prog,0,0,delfbuf,bufsize,compr,div-1);
	
/* setup fir filter */	
	if (div>1)
		Delf_CopyMem((ULONG)d_firs[div-2],delfprg->ldata,TAPS*4,DCPF_XDATA|DCPF_32BIT|DCPF_TO_DELFINA);
		
/* allocate audio, start recording */
	if (!Delf_AllocAudio(delfrecbuf,delfrecbuf,bufsize*2*div,delfprg->prog+2+(ch ? 0:2))) {
		Delf_FreeMem(delfrecbuf,DMEMF_LDATA);
		Delf_FreeMem(delfbuf,DMEMF_YDATA);
		printf("Delf_AllocAudio Failed!\n");
		return(FALSE);
	}
	
/* set frequency */	
	{
		struct TagItem tagitems[2];
		tagitems[0].ti_Tag = DA_Freq;  tagitems[0].ti_Data = freq;
		tagitems[1].ti_Tag = TAG_DONE; tagitems[1].ti_Data = NULL;
		Delf_SetAttrsA(tagitems);
	}
	
/* setup copy flags for DelfPacket */	
	if (compr==2) delfcopyflags=DCPF_YDATA|DCPF_TO_AMY|DCPF_24BIT;
	else	      delfcopyflags=DCPF_YDATA|DCPF_TO_AMY|DCPF_16BIT;
	
	return(TRUE);
}



/* This function pulled out of StartDelfina().  Returns the "virtual" sampling
   rate that is closest to the desired rate (ulIdealRate).  If non-NULL,
   *pnOptSetFreq is set to the actual sampling rate that would be used,
   and *pnOptSetDiv is set to the division rate (every n'th byte kept, wheere
   n==*pnOptSetDiv). */
int GetClosestDelfRate(int nIdealRate, int * pnOptSetFreq, int * pnOptSetDiv)
{	
	int x, min=10000;
	int freq, div;
	
	for (x=0;x<28;x++) {
		if (abs(nIdealRate-d_freqtab[x]/d_divtab[x])<min) {
			freq = d_freqtab[x];
			div  = d_divtab[x];
			min=abs(nIdealRate-freq/div);
		}
	}
	if (pnOptSetFreq) *pnOptSetFreq = freq;
	if (pnOptSetDiv)  *pnOptSetDiv  = div;
	return(freq/div);
}





/*****************************************************************
	Stop recording
	
	Deallocates everything that StartDelfina() allocated.
******************************************************************/
void StopDelfina(void)
{
	Delf_FreeAudio();
	Delf_FreeMem(delfrecbuf,DMEMF_LDATA);
	Delf_FreeMem(delfbuf,DMEMF_YDATA);
}



/*****************************************************************
	Copy packet data from delfina

	Use this function to get the packet data. New packet data is 
	available when you receive the 'delfsig' signal, so your main
	loop may be something like this:
	
	
	for (;;) {
		Wait(delfsig);
		DelfPacket(tempbuf);
		Transmit(tempbuf);
	}
	
	Input:
		buf  = pointer to buffer where the packet will be copied.
		size = packet size in bytes
		setJoinCode = pointer to a ULONG that will be filled in
			      with the current ADPCM JoinCode.
			      
	Result:	
		sum of all samples. If you want to know the average volume,
		divide this by the number of samples in the packet.. 
		
	Note: since this function really just calls Delf_CopyMem, you	
	may want to implement this as macro instead.. 
	
	
******************************************************************/
int DelfPacket(void *buf, int size, ULONG * setJoinCode)
{
	int estmax,delta,vol,currbuf;

	currbuf=Delf_Peek(delfprg->xdata+3,DMEMF_XDATA);
	Delf_CopyMem(currbuf,(ULONG)buf,size,delfcopyflags);
	
	vol=Delf_Peek(delfprg->xdata,DMEMF_XDATA);
	estmax=Delf_Peek(delfprg->xdata+1,DMEMF_XDATA);
	delta=Delf_Peek(delfprg->xdata+2,DMEMF_XDATA);
	*setJoinCode = (delta<<16) | (estmax & 0xffff);
	
	return(vol);
}