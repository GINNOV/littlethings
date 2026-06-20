;/*
   failat 20
   sc gst=include:all.gst parms=register nostackcheck IRA.c
   slink lib:c.o IRA.o IRA20_1.o IRA_2.o to IRA sc sd nd lib lib:sc.lib

   QUIT
   Author   : Tim Ruehsen
   Project  : IRA  -  68000/10/20/30/40 Interactive ReAssembler
   Part     : IRA.c
   Purpose  : Contains most routines and main program
   Version  : $VER: IRA.c V1.05
   Date     : 16.05.1995
   Copyright: (C)1993-1995 Tim Ruehsen
*/



#include "IRA.h"
#define __AMIGADATE__ __DATE__

#if BETA == 0
  CONST TEXT version[]="$VER: IRA V" VERSION "." REVISION " "__AMIGADATE__" (c)1993-95 Tim Ruehsen (SiliconSurfer/PHANTASM)\n\n";
#else
  CONST TEXT version[]="$VER: IRA V" VERSION "." REVISION "beta "__AMIGADATE__" (c)1993-95 Tim Ruehsen (SiliconSurfer/PHANTASM)\n\n";
#endif




extern
CONST TEXT opcode[][8],
      bitshift[][4],
      condcode[][3],
      extension[][3],
      caches[][3],
      bitop[][4],
      memtypename[][7],
      modname[][5],
      bitfield[][5],
      cregname[][6];

extern
CONST UWORD cregflag[18];

extern CONST UWORD  result[],maske[];
extern UWORD sourceadr[],destadr[];
extern CONST TEXT  flags[],cputype[];
extern CONST struct x_adr x_adrs[];
extern TEXT mnebuf[],adrbuf[],dtabuf[];

extern CONST TEXT cpuname[][8];
STATIC UWORD CPUTYPE=M68000;

       UWORD  opcstart[16];
       UWORD  opccount[16];
STATIC UWORD  opcnumber;
       UWORD  SIZEOF_RESULT;
       ULONG  ADRCOUNT;

STATIC UWORD reg1,reg2,adrmode,adrmode2,extens;
STATIC ULONG displace;
STATIC UWORD sigw;
       UWORD *buffer;
STATIC UWORD extra;
       WORD  PASS=-1;


       UWORD *DRelocBuffer;
       ULONG *RelocBuffer,RelocNumber;
       ULONG  LastModul;
STATIC ULONG  FirstModul;
       ULONG *LabelAdr;                  /* uncorrected addresses for labels */
       ULONG *LabelAdr2;                 /*   corrected addresses for labels */
       ULONG  LabelMax=1024;
       ULONG  labcount;
STATIC ULONG *LabelNum;
       ULONG *XRefListe,XRefCount;
STATIC ULONG  p2labind;
       ULONG  LabX_len=400;
       ULONG *RelocAdr,*RelocVal,*RelocMod,relocount;
       ULONG  relocmax=1024;
       LONG  *RelocOff;
       ULONG nextreloc;
       UWORD *memtype;

/* needed for the -BASEREG option */
STATIC UWORD  basereg= 4;
       ULONG  basesec=-1;
STATIC LONG   baseadr;

/* needed for symbol hunks */
STATIC ULONG   SymbolMax = 16;
       ULONG   SymbolCount;
       ULONG  *SymbolValue;
       UBYTE **SymbolName;

/* needed for finding data/code in code sections */
STATIC ULONG  CodeAreas, CodeAreaMax=16;
STATIC ULONG *CodeArea1, *CodeArea2, CodeAreaEnd;
STATIC ULONG  CNFAreas, CNFAreaMax=16;
STATIC ULONG *CNFArea1, *CNFArea2;
STATIC ULONG  CodeAdrs, CodeAdrMax=16;
STATIC ULONG *CodeAdr;

STATIC LONG   LabAdr;
STATIC UWORD  LabAdrFlag;

STATIC UWORD  NearFlag;

STATIC ULONG  sourcetype;
STATIC ULONG  textmethod;
STATIC ULONG  prglen,prgcount,labc1;
       ULONG  prgstart,prgende;
STATIC ULONG  codeentry;
STATIC ULONG  pc;
STATIC ULONG *labelbuf;

STATIC TEXT   configname[32];
STATIC TEXT   sourcename[128],targetname[128],tsname[128];
STATIC TEXT   binname[32],labname[32];

       ULONG  modulcount,modulcnt;
       ULONG *modultab,**modulstrt,*modultype,*moduloffs;

       ULONG  pflags;
STATIC LONG   adrlen;

       FILE  *sourcefile, * binfile, *targetfile;

STATIC FILE *labfile;
STATIC struct List  list;
STATIC struct Node *node;

UBYTE  StdName[STDNAMELENGTH];


extern int
    GetSymbol(ULONG),
    _abort(void);

extern void
      *GetPMem(ULONG),
      *GetNewVarBuffer(void *,ULONG),
       GetLabel(LONG,UWORD),
       GetXref(ULONG),
       GetExtName(ULONG),
       InsertXref(ULONG),
       InsertLabel(LONG),
       InsertReloc(ULONG,ULONG,LONG,ULONG),
       InitOpcode(void),
       ExamineHunks(void),
       SearchRomTag(void),
       WriteTarget(void *,ULONG);

STATIC VOID
       Init(void),
       GetOpcode(void),
       CheckPhase(ULONG adr),
       SectionToArea(void),
       WriteLabel1(ULONG),
       WriteLabel2(ULONG),
       Ausgabe(void),
       ReadObject(void),
       ReadBinary(void),
       ReadExecutable(void),
       InsertCodeArea(ULONG,ULONG),
       DPass0(void),
       DPass1(void),
       DPass2(void);

STATIC int
       DoAdress1(UWORD),
       DoAdress2(UWORD),
       P2WriteReloc(void),
       AutoScan(void);

void
       main(int,char *[]),
       InsertCodeAdr(ULONG),
       InsertSymbol(UBYTE *,ULONG),
       chkabort(void);

int
       P1WriteReloc(void);

extern ULONG
       FileLength(UBYTE *),
       ReadSymbol(FILE *,ULONG *,UBYTE *);

int   ARGC;
char **ARGV;


#if 0
void Freemem(void *ptr,ULONG cnt)
{
	/* printf("Free: %08X  %8ld\n",ptr,cnt); */
	FreeMem(ptr,cnt);
}
#endif

STATIC void GetOpcode()
{
UWORD i;

	/* set the number of the opcode to the maximum (DC.W) as default. */
	opcnumber=SIZEOF_RESULT/sizeof(UWORD)-1;
	for(i=opcstart[sigw>>12];i<opcstart[sigw>>12]+opccount[sigw>>12];i++) {
		if ((sigw&maske[i])==result[i]) {
			if (cputype[i]&CPUTYPE) {
				opcnumber=i;
				break;
			}
		}
	}

	/* split up the opcode */
	reg1=(sigw&0x0e00)>>9;
	reg2=(sigw&0x0007);
	adrmode=(sigw&0x003f);
	if (adrmode<0x38) adrmode=(adrmode>>3);
	else adrmode=7+reg2;
	if (flags[opcnumber]&0x80) extens=flags[opcnumber]&0x03;
	else extens=(sigw&0x00c0)>>6;

}

#if 0
// not used it seems -itix

STATIC void SearchCode(void)
{
ULONG i,j,end;
ULONG ptr;

	end=(prgende-prgstart)/2;

	for(i=0;i<end;i++) {
		if ((buffer[i]==0x4EF9) || (buffer[i]==0x4EB9)) {
			/* Find JSR/JMP Abs.L */
			if ((i+2)<end) {
				ptr=(buffer[i+1]<<16)+buffer[i+2];
				if (ptr>=prgstart && ptr<prgende) {
					InsertCodeAdr(ptr);
					InsertCodeAdr(i*2+prgstart);
					i=i+2;
				}
			}
		} else if ((buffer[i]==0x4EFA) || (buffer[i]==0x4EBA)) {
			/* Find JSR/JMP lab(PC) */
			if ((i+1)<end) {
				ptr=(prgstart+(i+1)*2)+(LONG)buffer[i+1];
				if (ptr>=prgstart && ptr<prgende) {
					InsertCodeAdr(ptr);
					InsertCodeAdr(i*2+prgstart);
					i=i+1;
				}
			}
		}
	}

/*
	for(i=0,j=0;j<modulcount;j++) {
		end=(moduloffs[j]+modultab[j])/2;
		while(i<end) {
			chkabort();
			if ((buffer[i]==0x6000) || (buffer[i]==0x6100)) {
				if ((i+1)<end) {
					ptr=((i+1)*2)+(WORD)buffer[i+1];
					if (ptr>=moduloffs[j] && ptr<end*2) {
						InsertCodeAdr(ptr+prgstart);
						InsertCodeAdr(i*2+prgstart);
						i=i+1;
					}
				}
			}
			i++;
		}
	}
*/
}
#endif

STATIC void PrintAreas(void)
{
ULONG i;

/*	return; */

	printf("CodeAdrs: %lu   CodeAdrMax: %lu\n",CodeAdrs,CodeAdrMax);

	for(i=0;i<CodeAreas;i++)
		printf("CodeArea[%lu]: %08x - %08x\n",i, (unsigned int)CodeArea1[i], (unsigned int)CodeArea2[i]);

	printf("\n\n");

}
STATIC void CNFAreaToCodeArea(void)
{
ULONG i;

	for(i=0;i<CNFAreas;i++)
		InsertCodeArea(CNFArea1[i],CNFArea2[i]);

}

STATIC void InsertCNFArea(ULONG adr1, ULONG adr2)
{
ULONG i;

	if (CNFAreas == 0) {
		CNFArea1[0] = adr1;
		CNFArea2[0] = adr2;
		CNFAreas++;
	}
	else {
		i=0;
		while(adr1 > CNFArea2[i] && i<CNFAreas) i++;
		if (adr1 == CNFArea2[i]) {
			CNFArea2[i] = adr2;
			while (((i+1) < CNFAreas) && (CNFArea2[i] >= CNFArea1[i+1])) {
				CNFArea2[i] = CNFArea2[i+1];
				lmovmem(&CNFArea1[i+2],&CNFArea1[i+1],CNFAreas-i-1);
				lmovmem(&CNFArea2[i+2],&CNFArea2[i+1],CNFAreas-i-1);
				CNFAreas--;
				i++;
			}
		}
		else if ((i != CNFAreas) && (adr2 >= CNFArea1[i]))
			CNFArea1[i] = adr1;
		else {
			lmovmem(&CNFArea1[i],&CNFArea1[i+1],CNFAreas-i);
			lmovmem(&CNFArea2[i],&CNFArea2[i+1],CNFAreas-i);
			CNFArea1[i] = adr1;
			CNFArea2[i] = adr2;
			CNFAreas++;
			if (CNFAreas == CNFAreaMax) {
				CNFArea1 = GetNewVarBuffer(CNFArea1,CNFAreaMax);
				CNFArea2 = GetNewVarBuffer(CNFArea2,CNFAreaMax);
				CNFAreaMax *= 2;
			}
		}
	}
}

STATIC void CreateConfig(void)
{
	ULONG  i;
	FILE  *configfile;
	ULONG  machine = machine;

/*
	while(file=fopen(configname,"r")) {
		fclose(file);
		strcat(configname,"1");
	}
*/

	if (!(configfile=fopen(configname,"w")))
		ExitPrg("Can't open %s",configname);

	/* Specify processor */
	if (CPUTYPE==M68000) machine=68000;
	if (CPUTYPE==M68010) machine=68010;
	if (CPUTYPE==M68020) machine=68020;
	if (CPUTYPE==M68030) machine=68030;
	if (CPUTYPE==M68040) machine=68040;
	if (CPUTYPE==M68060) machine=68060;
	fprintf(configfile,"MACHINE %lu\n",machine);
	if (CPUTYPE==M68881) machine=68881;
	fprintf(configfile,"MACHINE %lu\n",machine);
	if (CPUTYPE==M68851) machine=68851;
	fprintf(configfile,"MACHINE %lu\n",machine);

	fprintf(configfile,"ENTRY $%08X\n",codeentry);

	fprintf(configfile,"OFFSET $%08X\n",prgstart);

	if (pflags&BASEREG2) {
		fprintf(configfile,"BASEREG %u\n",basereg);
		fprintf(configfile,"BASEADR $%lX\n",baseadr);
		fprintf(configfile,"BASESEC %lu\n",basesec);
	}

	for(i=0;i<SymbolCount;i++)
		fprintf(configfile,"SYMBOL %s $%08X\n",SymbolName[i],SymbolValue[i]);

	for(i=0;i<CodeAreas;i++)
		fprintf(configfile,"CODE $%08X - $%08X\n",CodeArea1[i],CodeArea2[i]);

	fputs("END\n",configfile);

	fclose(configfile);
}

STATIC void ReadConfig(void)
{
	FILE *configfile;
	ULONG area1,area2;
	UBYTE buffer[256],*ptr1,*ptr2;
	UBYTE symbol[256];
	ULONG value;
	UWORD i,j;
	ULONG machine;

	if (!(configfile=fopen(configname,"r"))) {
		if (pflags&PREPROC) {
			printf("WARNING: Can't find %s\n",configname);
			return;
		}
		else
			ExitPrg("Can't open %s",configname);
	}

	do {
		if (!(fgets(buffer,255,configfile))) break;
		if (!strnicmp(buffer,"CODE",4)) {
			if ((ptr1 = strchr(buffer,'$'))) stch_l(ptr1+1,(long *)&area1);
			area2 = area1;
			if ((ptr2 = strchr(ptr1+1,'$'))) stch_l(ptr2+1,(long *)&area2);
			if (ptr1) {
				if (area1 < prgstart || area1 > prgende)
					ExitPrg("ERROR: %08x out of range.\n",area1);
				if (ptr2) {
					if (area2 < prgstart || area2 > prgende)
						ExitPrg("ERROR: %08x out of range (%08x-%08x).\n",area2,prgstart,prgende);
					if (area1 > area2) {
						ExitPrg("ERROR: %08x > %08x.\n",area1,area2);
					}
					else
						InsertCNFArea(area1,area2);
					if (area1 < area2) InsertCodeAdr(area1);
				}
				else
					if (area1 < prgende) InsertCodeAdr(area1);
			}
		}
		else if(!strnicmp(buffer,"SYMBOL",6)) {
			for(i=6;isspace(buffer[i]);i++);
			for(j=0;isgraph(buffer[i]);) symbol[j++]=buffer[i++];
			symbol[j]=0;
			while(isspace(buffer[i])) i++;
			if (buffer[i]=='$') stch_l(&buffer[i+1],(long *)&value);
			else value = atoi(&buffer[i+1]);
			if (value < prgstart || value >= prgende)
				ExitPrg("%sERROR: %s=%lu but must be within [%lu,%lu[.\n",buffer,value,prgstart,prgende);
			InsertSymbol(symbol,value);
		}
		else if(!strnicmp(buffer,"MACHINE",7)) {
			machine=atoi(&buffer[7]);
			CPUTYPE=0;
			if (machine==68000) CPUTYPE|=M68000;
			if (machine==68010) CPUTYPE|=M68010;
			if (machine==68020) CPUTYPE|=M68020;
			if (machine==68030) CPUTYPE|=M68030;
			if (machine==68040) CPUTYPE|=M68040;
			if (machine==68060) CPUTYPE|=M68060;
			if (machine==68851) CPUTYPE|=M68851;
			if (machine==68881) CPUTYPE|=M68881;
			if (CPUTYPE==0)
				ExitPrg("%sERROR: unknown processor.\n",buffer);
		}
		else if(!strnicmp(buffer,"OFFSET",6)) {
			if ((ptr1 = strchr(buffer,'$'))) stch_l(ptr1+1,(long *)&prgstart);
			else prgstart=atoi(&buffer[6]);
		}
		else if(!strnicmp(buffer,"ENTRY",5)) {
			if ((ptr1 = strchr(buffer,'$'))) stch_l(ptr1+1,(long *)&codeentry);
			else prgstart=atoi(&buffer[5]);
		}
		else if(!strnicmp(buffer,"BASEREG",7)) {
			if ((ptr1 = strchr(&buffer[7],'a')))
				basereg=atoi(ptr1+1);
			else if ((ptr1 = strchr(&buffer[7],'A')))
				basereg=atoi(ptr1+1);
			else
				basereg=atoi(&buffer[7]);
			if (basereg > 7 )
				ExitPrg("%sERROR: unknown address register.\n",buffer);
			if (!(pflags&BASEREG2)) pflags |= BASEREG1;
		}
		else if(!strnicmp(buffer,"BASEADR",7)) {
			if ((ptr1 = strchr(buffer,'$'))) stch_l(ptr1+1,(long *)&baseadr);
			else baseadr=atoi(&buffer[7]);
			pflags &= (~BASEREG1);
			pflags |= BASEREG2;
		}
		else if(!strnicmp(buffer,"BASESEC",7)) {
			basesec=atoi(&buffer[7]);
			if (basesec >= modulcount)
				ExitPrg("%sERROR: there aren't so many sections.\n",buffer);
			pflags &= (~BASEREG1);
			pflags |= BASEREG2;
		}
	} while (strnicmp(buffer,"END",3));

	fclose(configfile);
}

void InsertSymbol(UBYTE *name, ULONG value)
{
ULONG i;

	// printf("SYMBOL %s = %08X\n",name,value);

	for(i=0;i<SymbolCount;i++)
		if (SymbolValue[i] == value) return;

	SymbolValue[SymbolCount] = value;
	SymbolName[SymbolCount]  = GetPMem(strlen(name)+1);
	strcpy(SymbolName[SymbolCount++], name);

	if (SymbolCount == SymbolMax) {
		SymbolName  = GetNewVarBuffer(SymbolName,  SymbolMax);
		SymbolValue = GetNewVarBuffer(SymbolValue, SymbolMax);
		SymbolMax  *= 2;
	}
}

STATIC ULONG GetCodeAdr(ULONG *ptr)
{
	if (CodeAdrs) {
		*ptr = CodeAdr[0];
		lmovmem(&CodeAdr[1],&CodeAdr[0],CodeAdrs-1);
		CodeAdrs--;
		return(1);
	}
	return(0);
}

void InsertCodeAdr(ULONG adr)
{
ULONG l=0,m,r=CodeAdrs,i;

	/* printf("CODEADR %08X\n",adr); */

	if (!(pflags&PREPROC)) return;

	/* check if label points into an earlier processed code area */
	for(i=0;i<CodeAreas;i++) {
		if ((adr >= CodeArea1[i]) && (adr < CodeArea2[i])) {
			return;
		}
	}

	/* this case occurs pretty often */
	if ((adr > CodeAdr[CodeAdrs-1]) && CodeAdrs) {
		CodeAdr[CodeAdrs++] = adr;
	}
	else {
		/* Binaeres Suchen von adr */
		while (l<r) {
			m=(l+r)/2;
			if (CodeAdr[m] < adr) l=m+1;
			else                  r=m;
		}
		if ((CodeAdr[r] != adr) || (r == CodeAdrs)) {
			lmovmem(&CodeAdr[r],&CodeAdr[r+1],CodeAdrs-r);
			CodeAdr[r] = adr;
			CodeAdrs++;
		}
	}
	if (CodeAdrs == CodeAdrMax) {
		CodeAdr     = GetNewVarBuffer(CodeAdr,CodeAdrMax);
		CodeAdrMax *= 2;
	}
}

STATIC void InsertCodeArea(ULONG adr1, ULONG adr2)
{
ULONG i,j;

	/* printf("ICA: %08X - %08X\n",adr1,adr2); */

	if (CodeAreas == 0) {
		CodeArea1[0] = adr1;
		CodeArea2[0] = adr2;
		CodeAreas++;
	}
	else {
		i=0;
		while(adr1 > CodeArea2[i] && i<CodeAreas) i++;
		if (adr1 == CodeArea2[i]) {
			CodeArea2[i] = adr2;
			while (((i+1) < CodeAreas) && (CodeArea2[i] >= CodeArea1[i+1])) {
				CodeArea2[i] = CodeArea2[i+1];
				lmovmem(&CodeArea1[i+2],&CodeArea1[i+1],CodeAreas-i-1);
				lmovmem(&CodeArea2[i+2],&CodeArea2[i+1],CodeAreas-i-1);
				CodeAreas--;
				i++;
			}
		}
		else if ((i != CodeAreas) && (adr2 >= CodeArea1[i]))
			CodeArea1[i] = adr1;
		else {
			lmovmem(&CodeArea1[i],&CodeArea1[i+1],CodeAreas-i);
			lmovmem(&CodeArea2[i],&CodeArea2[i+1],CodeAreas-i);
			CodeArea1[i] = adr1;
			CodeArea2[i] = adr2;
			CodeAreas++;
			if (CodeAreas == CodeAreaMax) {
				CodeArea1 = GetNewVarBuffer(CodeArea1,CodeAreaMax);
				CodeArea2 = GetNewVarBuffer(CodeArea2,CodeAreaMax);
				CodeAreaMax *= 2;
			}
		}
	}

	fprintf(stderr,"Areas: %4lu  \r",CodeAreas);
	fflush(stderr);

	/* remove all labels that point within a earlier processed code area */
	for(j=0;j<CodeAreas;j++) {
		for(i=0;i<CodeAdrs;) {
			if ((CodeAdr[i] >= CodeArea1[j]) && (CodeAdr[i] < CodeArea2[j])) {
				lmovmem(&CodeAdr[i+1],&CodeAdr[i],CodeAdrs-i-1);
				CodeAdrs--;
			}
			else i++;
		}
	}
/*
	printf("adr1=%08X  adr2=%08X\n",adr1,adr2);
	printf("--------\n");
	PrintAreas();
*/
}

STATIC void SectionToArea(void)
{
ULONG i,j,ptr1;

	if (!(pflags&PREPROC)) {
		for(i=0;i<modulcount;i++) {
			if (modultype[i] == 0x03E9) {
				if (i==0) {
					InsertCodeArea(codeentry,moduloffs[i]+modultab[i]);
				}
				else {
					InsertCodeArea(moduloffs[i],moduloffs[i]+modultab[i]);
				}
			}
		}
	}

	/* need at least one code area for the following algorythm */
	if (CodeAreas == 0) CodeAreas = 1;

	/* splitting code areas where sections begin or end */
	for(i=0;i<modulcount;i++) {
		if (modultab[i] == 0) continue;
		ptr1 = moduloffs[i]+modultab[i];
		if (ptr1 <= CodeArea2[CodeAreas-1]) {
			for(j=0;j<CodeAreas;j++) {
				if (ptr1 < CodeArea2[j]) {
					if (ptr1 == CodeArea1[j]) break;
					lmovmem(&CodeArea1[j],&CodeArea1[j+1],CodeAreas-j);
					lmovmem(&CodeArea2[j],&CodeArea2[j+1],CodeAreas-j);
					if (ptr1 < CodeArea1[j])
						CodeArea1[j] = CodeArea2[j] = ptr1;
					else if (ptr1 > CodeArea1[j])
						CodeArea2[j] = CodeArea1[j+1] = ptr1;
					CodeAreas++;
					if (CodeAreas == CodeAreaMax) {
						CodeArea1 = GetNewVarBuffer(CodeArea1,CodeAreaMax);
						CodeArea2 = GetNewVarBuffer(CodeArea2,CodeAreaMax);
						CodeAreaMax *= 2;
					}
				break;
				}
			}
		}
		else {
			CodeArea2[CodeAreas] = CodeArea1[CodeAreas] = ptr1;
			CodeAreas++;
			if (CodeAreas == CodeAreaMax) {
				CodeArea1 = GetNewVarBuffer(CodeArea1,CodeAreaMax);
				CodeArea2 = GetNewVarBuffer(CodeArea2,CodeAreaMax);
				CodeAreaMax *= 2;
			}
		}
	}

	if (CodeArea1[0] != prgstart) InsertCodeArea(prgstart,prgstart);
}

STATIC void DPass0(void)
{
UWORD  dummy;
UWORD  EndFlag=0;
ULONG  ptr1,ptr2,i;

	PASS = 0;
	ptr2 = (prgende-prgstart)/2;
	if (!(pflags&ROMTAGatZERO) && !(pflags&CONFIG)) InsertCodeAdr(codeentry);
	fprintf(stderr,"Pass 0: scanning for data in code\n");

/*
	for(nextreloc=0;nextreloc<relocount;nextreloc++)
		if (RelocAdr[nextreloc] >= ptr1)
			break;
*/

	while(GetCodeAdr(&ptr1)) {

		prgcount = (ptr1 - prgstart)/2;

		/* find out in which section we are */
		for(modulcnt=0;modulcnt<modulcount;modulcnt++) {
			if ((ptr1 >= moduloffs[modulcnt]) &&
				 (ptr1 <  (moduloffs[modulcnt]+modultab[modulcnt]))) {
				CodeAreaEnd = (moduloffs[modulcnt]+modultab[modulcnt]-prgstart)/2;
				break;
			}
		}

		/* find the first relocation in this code area */
		for(nextreloc=0;nextreloc<relocount;nextreloc++)
			if (RelocAdr[nextreloc] >= ptr1)
				break;

		EndFlag = 0;
		while(EndFlag == 0) {

			if (RelocAdr[nextreloc] == (prgcount*2 + prgstart)) {
				nextreloc++;
				prgcount += 2;
				continue;
			}
			pc = prgcount;
			sigw=(UWORD)buffer[prgcount++];


			GetOpcode();
			if (flags[opcnumber]&0x20) {
				extra=buffer[prgcount];
				if (P1WriteReloc()) continue;
			}

			if (opcnumber == OPC_CMPI) {
				if (CPUTYPE&M020UP) destadr[opcnumber]=0x0bfe;
				else destadr[opcnumber]=0x0bf8;
			} else if (opcnumber==OPC_TST) {
				if (CPUTYPE&M020UP) sourceadr[opcnumber]=0x0fff;
				else sourceadr[opcnumber]=0x0bf8;
			} else if (opcnumber==OPC_BITFIELD) {
				dummy=(sigw&0x0700)>>8;
				if (dummy==2 || dummy==4 || dummy==6 || dummy==7) sourceadr[opcnumber]=0x0a78;
				else sourceadr[opcnumber]=0x0a7e;
			} else if (opcnumber==OPC_C2) {
				if (extra&0x07ff) adrmode=NOADRMODE;
				else {
					reg1=(extra&0x7000)>>12;
					if (extra&0x8000) destadr[opcnumber]=0xa001;
					else destadr[opcnumber]=0xa000;
				}
			} else if (opcnumber==OPC_MOVE162) {
				switch ((buffer[prgcount]&0x0018)>>3) {
					case 0: /* (An)+,(xxx).L */
						sourceadr[opcnumber]=0x8003;
						destadr[opcnumber]  =0x8008;
						break;
					case 1: /* (xxx).L,(An)+ */
						sourceadr[opcnumber]=0x8008;
						destadr[opcnumber]  =0x8003;
						break;
					case 2: /* (An) ,(xxx).L */
						sourceadr[opcnumber]=0x8002;
						destadr[opcnumber]  =0x8008;
						break;
					case 3: /* (xxx).L, (An) */
						sourceadr[opcnumber]=0x8008;
						destadr[opcnumber]  =0x8002;
						break;
				}
			} else if (opcnumber==OPC_MOVES) {
				if (extra&0x0800) {
					sourceadr[opcnumber]=0x8022;
					destadr[opcnumber]  =0x03f8;
				}
				else {
					sourceadr[opcnumber]=0x03f8;
					destadr[opcnumber]  =0x8022;
				}
			}

			if ((flags[opcnumber]&0x40) && extens==3) adrmode=NOADRMODE;

			if (sourceadr[opcnumber])
				if (DoAdress1(sourceadr[opcnumber])) continue;
			if (destadr[opcnumber]) {
				if (opcnumber==OPC_MOVEB || opcnumber==OPC_MOVEW || opcnumber==OPC_MOVEL) {
					adrmode=((sigw&0x01c0)>>3)|reg1;
					if (adrmode<0x38) adrmode=(adrmode>>3);
					else adrmode=7+reg1;
					reg2=reg1;
				}
				if (DoAdress1(destadr[opcnumber])) continue;
				else {
					if (opcnumber==OPC_LEA || opcnumber==OPC_MOVEAL) {
						if (pflags&BASEREG1) {
							if (adrmode2==1 && reg1==basereg)
								printf("BASEREG\t%08X: A%hd\n",pc*2+prgstart,basereg);
						}
					}
				}
			}

			/* Check for data in code */
			/**************************/

/*			printf("adr=%08x  opc=%lu  adrflag=%lu\n",LabAdr,opcnumber,LabAdrFlag); */
			if (LabAdrFlag == 1) {
				if (opcnumber == OPC_BCC  ||
					 opcnumber == OPC_JSR  ||
					 opcnumber == OPC_DBCC ||
					 opcnumber == OPC_JMP  ||
					 opcnumber == OPC_CALLM)
					if ((LabAdr < ptr1) || (LabAdr > (prgcount*2+prgstart)))
						InsertCodeAdr(LabAdr);
				LabAdrFlag = 0;
			}
			if ((((opcnumber == OPC_BCC) && (sigw&0xFF00) == 0x6000)) ||
				opcnumber == OPC_JMP ||
				opcnumber == OPC_RTS ||
				opcnumber == OPC_RTE ||
				opcnumber == OPC_RTR ||
				opcnumber == OPC_RTD ||
				opcnumber == OPC_RTM)
			{
				EndFlag = 1;
				for(i=0;i<CNFAreas;i++) {
					if ((CNFArea1[i] < (prgcount*2+prgstart)) &&
						 (CNFArea2[i] > (prgcount*2+prgstart))) {
						EndFlag = 0;
						break;
					}
				}
				if (EndFlag == 1)
					InsertCodeArea(ptr1, prgcount*2+prgstart);
			}
			if (prgcount == ptr2) {
				InsertCodeArea(ptr1, prgcount*2+prgstart);
				EndFlag = 1;
			}
			if (prgcount > ptr2)
				printf("Watch out: prgcount*2(=%08x) > (prgende-prgstart)(=%08x)\n",prgcount*2,prgende-prgstart);

		}

		/* Speeding up (takes out reduncies in code checking) */
		for(i=0;i<CNFAreas;i++) {
			if (CNFArea2[i] == (prgcount*2+prgstart)) {
				if (CNFArea1[i] <= ptr1) {
					CNFArea2[i] = ptr1;
					break;
				}
			}
		}
	}

	fprintf(stderr,"\n");

/*
	PrintAreas();
*/
	/* preparing sections to be area aligned */
	SectionToArea();

/*	printf("CodeAdrs: %lu   CodeAdrMax: %lu\n",CodeAdrs,CodeAdrMax); */
/*	PrintAreas(); */
}

void main(int argc,char **argv)
{
	ARGC = argc;
	ARGV = argv;

	Init();
	InitOpcode();
	SearchRomTag();
	if (pflags&PREPROC) {
		/* SearchCode(); */
		DPass0();
		CreateConfig();
	} else if (pflags&CONFIG) {
		CNFAreaToCodeArea();
	} else {
		SectionToArea();
	}
	PrintAreas();
	DPass1();
	DPass2();
	ExitPrg("\n");
}

STATIC void DPass2()
{
ULONG  modtype;
UWORD  tflag,text,dummy,flag;
UWORD  longs_per_line;
LONG   dummy1;
ULONG  dummy2 = dummy2;
ULONG  i,j,k,l,m,r,rel,zero,alpha;
UBYTE *buf,*tptr;
ULONG  ptr1,ptr2,end,area;

	PASS = 2;
	LabelAdr2  = GetPMem(LabelMax*4+4);

	if (labcount) { /* Wenn ueberhaupt Labels vorhanden sind */
		fprintf(stderr,"Pass 2: correcting labels\n");
		if (!(labfile = fopen(labname,"r")))
			ExitPrg("Can't open %s\n",labname);

		labelbuf = GetPMem(labc1*sizeof(ULONG));
		fread(labelbuf,4,labc1,labfile);
		fclose(labfile);labfile=0; 
		DeleteFile(labname);
		for(i=0;i<labcount;i++) {
			dummy1 = LabelAdr2[i] = LabelAdr[i];
			if (dummy1 < (LONG)prgstart) LabelAdr2[i]=prgstart;
			for(j=0;j<CodeAreas;j++) {
				if ((dummy1>=CodeArea1[j]) && (dummy1<CodeArea2[j])) {

					/* Binaeres Suchen von dummy1 */
					l=0;r=labc1;
					while (l<r) {
						m=(l+r)/2;
						if ((long)labelbuf[m]<dummy1) l=m+1;
						else                          r=m;
					}
					if (labelbuf[r]!=dummy1 || r==labc1) {
						if (r>0) LabelAdr2[i] = labelbuf[r-1];
						else LabelAdr2[i] = 0;
					}
					break;
				}
			}
		}
		/* Don't free mem, or phase checking won't work !!! */
		/* Freemem(labelbuf,labc1*sizeof(ULONG));labelbuf=0; */
	} /* Ende der Labelbearbeitung */


	if (textmethod) {
		fprintf(stderr,"Pass 2: searching for text\n");

		for(modulcnt=0;modulcnt<modulcount;modulcnt++) {
			modtype = modultype[modulcnt];
			/* BSS hunk --> there is no text */
			if (modtype == 0x03EB) continue;
			if (!modultab[modulcnt]) continue;
			buf=(UBYTE *)buffer+moduloffs[modulcnt];

			for(rel=0,i=0;i<modultab[modulcnt]-1;i++) {
				k=i;text=1;alpha=0;
				while (isprint(buf[k]) || isspace(buf[k])) {
					if (buf[k]>127) {text=0;break;}
					if (isalpha(buf[k]) && isalpha(buf[k+1])) alpha++;
					else if (alpha < 4) alpha=0;
					k++;
				}

				/* there must be more than 4 letters concatenated */
				if (alpha < 4) {i=k;continue;}

				/* text should be null terminated */
				if (buf[k]!=0) {i=k;continue;}

				/* a text must have a minimum length */
				if ((k-i)<=5) {i=k;continue;}

				/* relocations don't have to be in a text */
				while(RelocAdr[rel]<=(i+moduloffs[modulcnt]-4) && rel<relocount) rel++;
				if (rel<relocount) {
					if (RelocAdr[rel]<=(k+moduloffs[modulcnt])) {
						i=k;continue;
					}
				}

				if (text) {

					/* RTS --> seems to be code */
					if (buf[k-2]!=0x4E && buf[k-1]!=0x75) {
					printf("TEXT\t%08x:\n",moduloffs[modulcnt]-prgstart+i);
					printf("\tDC.B\t");
					for(tflag=0,j=i;j<=k;j++) {
						if (isprint(buf[j]) && buf[j]!='\"') {
							if (tflag==0) printf("\"%c",buf[j]);
							if (tflag==1) printf("%c",buf[j]);
							if (tflag==2) printf(",\"%c",buf[j]);
							tflag=1;
						} else {
							if (tflag==0) printf("%d",(int)buf[j]);
							if (tflag==1) printf("\",%d",(int)buf[j]);
							if (tflag==2) printf(",%d",(int)buf[j]);
							tflag=2;
						}
					}
					if (tflag==1) printf("\"\n");
					if (tflag==2) printf("\n");
					}
				}
				i=k;
			}
		}
	}

	fprintf(stderr,"Pass 2: writing mnemonics\n");


	if (!(targetfile = fopen(targetname,"w")))
		ExitPrg("Can't open %s\n",targetname);

	fprintf(targetfile,IDSTRING2,VERSION,REVISION);
	
	/* Write EQU's */
	if (XRefCount) {
		for(i=0;i<XRefCount;i++) {
			adrbuf[0]=0;
			GetExtName(i);
			if (strlen(adrbuf)<8) adrcat("\t");
			fprintf(targetfile,"%s\tEQU\t$%X\n",adrbuf,XRefListe[i]);
		}
		adrbuf[0]=0;
		fprintf(targetfile,"\n\n");
	}

	/* Specify processor */
	if (CPUTYPE&M68000) dummy2=68000;
	if (CPUTYPE&M68010) dummy2=68010;
	if (CPUTYPE&M68020) dummy2=68020;
	if (CPUTYPE&M68030) dummy2=68030;
	if (CPUTYPE&M68040) dummy2=68040;
	if (CPUTYPE&M68060) dummy2=68060;
	if (dummy2 != 68000) {
		fprintf(targetfile,"\tMACHINE\t%ld\n",dummy2);
	}
	if (CPUTYPE&M68881 && !CPUTYPE&(M68040|M68060))
		fprintf(targetfile,"\tFPU\n");
	if (dummy2==68020 && CPUTYPE&M68851)
		fprintf(targetfile,"\tPMMU\n");
	fprintf(targetfile,"\n");

	if (pflags&BASEREG2) {
		fprintf(targetfile,"\tNEAR\tA%hu,%ld\n\n",basereg,basesec);
	}


	/* If splitted, write INCLUDE directives */
	if (pflags&SPLITFILE) {
		for(modulcnt=0;modulcnt<modulcount;modulcnt++) {
			if (!modultab[modulcnt])
				if (!(pflags&KEEP_ZEROHUNKS)) continue;
			fprintf(targetfile,"\tINCLUDE\t\"%s.S%s\"\n",targetname,itoa(modulcnt));
		}
		fprintf(targetfile,"\tEND\n");
		fclose(targetfile);targetfile=0;
	}


	prgcount = 0;
	nextreloc= 0;
	modulcnt = 0xFFFFFFFF;

	for(area=0;area<CodeAreas;area++) {

		while ((moduloffs[modulcnt+1] == CodeArea1[area]) && ((modulcnt+1) < modulcount)) {
			modulcnt++;
			modtype = modultype[modulcnt];
			if (pflags&SPLITFILE) {
				if (targetfile) {
					fclose(targetfile);
				}
				strcpy(tsname,targetname);
				strcat(tsname,".S");
				strcat(tsname,itoa(modulcnt));
				if (!(targetfile = fopen(tsname,"w")))
					ExitPrg("Can't open %s\n",tsname);
			}

			if ((modultab[modulcnt] != 0) || (pflags&KEEP_ZEROHUNKS)) {
				if (memtype[modulcnt])
					fprintf(targetfile,"\n\n\tSECTION S_%ld,%s,%s\n\n",modulcnt,modname[modtype-0x03E9],memtypename[memtype[modulcnt]]);
				else
					fprintf(targetfile,"\n\n\tSECTION S_%ld,%s\n\n",modulcnt,modname[modtype-0x03E9]);
				flag = 1;
				while(LabelAdr2[p2labind]==moduloffs[modulcnt] && p2labind<labcount) {
					if (GetSymbol(LabelAdr[p2labind])) {
						fprintf(targetfile,"%s:\n",adrbuf);
						adrbuf[0]=0;
					}
					else flag = 0;
					p2labind++;
				}
				if (flag == 0)
					fprintf(targetfile,"SECSTRT_%ld:\n",modulcnt);
			}
		}

		dtabuf[0]=0;
		adrbuf[0]=0;
		mnebuf[0]=0;

		/* HERE BEGINS THE CODE PART OF PASS 2 */
		/***************************************/

		CodeAreaEnd = (CodeArea2[area]-prgstart)/2;

		CheckPhase (-1); /* Phasenangleich */ 

		while(prgcount < CodeAreaEnd) {

			CheckPhase(prgcount*2+prgstart);

			WriteLabel2(prgstart+prgcount*2);

			dtacat(itohex(prgstart+prgcount*2,adrlen));
			dtacat(": ");
			if (RelocAdr[nextreloc] == (prgcount*2 + prgstart)) {
				mnecat("DC.L");
				dtacat(itohex(buffer[prgcount],4));
				dtacat(itohex(buffer[prgcount+1],4));
				GetLabel(RelocVal[nextreloc],9999);
				nextreloc++;
				Ausgabe();
				prgcount += 2;
				continue;
			}
			pc = prgcount;
			sigw=buffer[prgcount++];
			dtacat(itohex(sigw,4));


			GetOpcode();
			mnecat(&opcode[opcnumber][0]);
			if (flags[opcnumber]&0x20) {
				extra=buffer[prgcount];
				if (P2WriteReloc()) continue;
			}
			if (flags[opcnumber]&0x10) {
				dummy=(sigw&0x0f00)>>8;
				if (opcnumber==OPC_BCC && dummy<2) dummy+=16;
				mnecat(condcode[dummy]);
			}


			if (opcnumber == OPC_CMPI) {
				if (CPUTYPE&M020UP) destadr[opcnumber]=0x0bfe;
				else destadr[opcnumber]=0x0bf8;
			} else if (opcnumber == OPC_BITSHIFT1) {
				/* SHIFT & ROTATE memory */
				mnecat(bitshift[(sigw>>9)&0x0003]);
				if (sigw&0x0100) mnecat("L");
				else mnecat("R");
			} else if (opcnumber == OPC_BITSHIFT2) {
				/* SHIFT & ROTATE Data Register */
				mnecat(bitshift[(sigw>>3)&0x0003]);
				if (sigw&0x0100) mnecat("L");
				else mnecat("R");
				if (sigw&0x0020) adrcat("D");
				else {
					adrcat("#");
					if (!reg1) reg1=8;
				}
				adrcat(itohex(reg1,1));
				adrcat(",");
			} else if (opcnumber==OPC_TST) {
				if (CPUTYPE&M020UP) sourceadr[opcnumber]=0x0fff;
				else sourceadr[opcnumber]=0x0bf8;
			} else if (opcnumber==OPC_BITFIELD) {
				dummy=(sigw&0x0700)>>8;
				mnecat(bitfield[dummy]);
				if (dummy==2 || dummy==4 || dummy==6 || dummy==7) sourceadr[opcnumber]=0x0a78;
				else sourceadr[opcnumber]=0x0a7e;
			} else if (opcnumber==OPC_C2) {
				if (extra&0x07ff) adrmode=NOADRMODE;
				else {
					if (extra&0x0800) mnecat("HK2");
					else mnecat("MP2");
					reg1=(extra&0x7000)>>12;
					if (extra&0x8000) destadr[opcnumber]=0xa001;
					else destadr[opcnumber]=0xa000;
				}
			} else if (opcnumber==OPC_MOVE162) {
				switch ((buffer[prgcount]&0x0018)>>3) {
					case 0: /* (An)+,(xxx).L */
						sourceadr[opcnumber]=0x8003;
						destadr[opcnumber]  =0x8008;
						break;
					case 1: /* (xxx).L,(An)+ */
						sourceadr[opcnumber]=0x8008;
						destadr[opcnumber]  =0x8003;
						break;
					case 2: /* (An) ,(xxx).L */
						sourceadr[opcnumber]=0x8002;
						destadr[opcnumber]  =0x8008;
						break;
					case 3: /* (xxx).L, (An) */
						sourceadr[opcnumber]=0x8008;
						destadr[opcnumber]  =0x8002;
						break;
				}
			} else if (opcnumber==OPC_MOVES) {
				if (extra&0x0800) {
					sourceadr[opcnumber]=0x8022;
					destadr[opcnumber]  =0x03f8;
				}
				else {
					sourceadr[opcnumber]=0x03f8;
					destadr[opcnumber]  =0x8022;
				}
			}

			if (flags[opcnumber]&0x40) {
				if (extens!=3)
					mnecat(extension[extens]);
				else
					adrmode=NOADRMODE;
			}

			if (sourceadr[opcnumber]) {
				if (DoAdress2(sourceadr[opcnumber])) continue;
				if (opcnumber!=OPC_BITFIELD)
					if (destadr[opcnumber]) adrcat(",");
			}
			if (destadr[opcnumber]) {
				if (opcnumber==OPC_MOVEB || opcnumber==OPC_MOVEW || opcnumber==OPC_MOVEL) {
					adrmode=((sigw&0x01c0)>>3)|reg1;
					if (adrmode<0x38) adrmode=(adrmode>>3);
					else adrmode=7+reg1;
					reg2=reg1;
				}
				if (DoAdress2(destadr[opcnumber])) continue;
				if (opcnumber==OPC_PACK1 || opcnumber==OPC_PACK2 ||
					 opcnumber==OPC_UNPK1 || opcnumber==OPC_UNPK2) {
					adrcat(",#$");
					adrcat(itohex(extra,4));
				}
			}

			if (NearFlag == 1) WriteTarget("\tFAR\n",5);
			Ausgabe();
			if (NearFlag == 1) {WriteTarget("\tNEAR\n",6);NearFlag=0;};

			if (prgcount > CodeAreaEnd)
				printf("P2 Watch out: prgcount*2(=%08x) > (prgende-prgstart)(=%08x)\n",prgcount*2,prgende-prgstart);

		}


		while ((moduloffs[modulcnt+1] == CodeArea2[area]) && ((modulcnt+1) < modulcount)) {
			modulcnt++;
			modtype = modultype[modulcnt];
			if (pflags&SPLITFILE) {
				if (targetfile) {
					fclose(targetfile);
				}
				strcpy(tsname,targetname);
				strcat(tsname,".S");
				strcat(tsname,itoa(modulcnt));
				if (!(targetfile = fopen(tsname,"w")))
					ExitPrg("Can't open %s\n",tsname);
			}
			if ((modultab[modulcnt] != 0) || (pflags&KEEP_ZEROHUNKS)) {
				if (memtype[modulcnt])
					fprintf(targetfile,"\n\n\tSECTION S_%ld,%s,%s\n\n",modulcnt,modname[modtype-0x03E9],memtypename[memtype[modulcnt]]);
				else
					fprintf(targetfile,"\n\n\tSECTION S_%ld,%s\n\n",modulcnt,modname[modtype-0x03E9]);
				flag = 1;
				while(LabelAdr2[p2labind]==moduloffs[modulcnt] && p2labind<labcount) {
					if (GetSymbol(LabelAdr[p2labind])) {
						fprintf(targetfile,"%s:\n",adrbuf);
						adrbuf[0]=0;
					}
					else flag=0;
					p2labind++;
				}
				if (flag == 0)
					fprintf(targetfile,"SECSTRT_%ld:\n",modulcnt);
			}
		}

		/* HERE BEGINS THE DATA PART OF PASS 2 */
		/***************************************/


		ptr1=CodeArea2[area];
		if ((area+1)<CodeAreas) 
			end = CodeArea1[area+1];
		else
			end = prgende;

		while (ptr1 < end) {

			text=0;

			/* write label and/or relocation */
			WriteLabel2(ptr1);
			if (RelocAdr[nextreloc] == ptr1) {
				dtacat(itohex(ptr1,adrlen));
				dtacat(": ");
				dtacat(itohex(buffer[(ptr1-prgstart)/2],4));
				dtacat(itohex(buffer[(ptr1-prgstart+2)/2],4));
				ptr1 += 4;
				ptr2  = ptr1;
				mnecat("DC.L");
				GetLabel(RelocVal[nextreloc],9999);
				nextreloc++;
				Ausgabe();
				continue;
			}

			/* initialize upper textbound */
			ptr2=end;
			if (p2labind < labcount) ptr2=LabelAdr2[p2labind];
			if (nextreloc < relocount && RelocAdr[nextreloc] < ptr2)
				ptr2=RelocAdr[nextreloc];
			if (end < ptr2) ptr2=end;


			buf=(UBYTE *)((ULONG)buffer+ptr1-prgstart);

			/* a text must have a minimum length */
			if ((ptr2-ptr1) > 4) {

				/* I think a text shouldn't begin with a zero-byte */ 
				if (buf[0]!=0) {

				for(j=0,zero=0,text=1;j<(ptr2-ptr1);j++) {
/*					if (buf[j]>127) {text=0;break;} */
					if (buf[j]==0) {
						if ((j+1)<(ptr2-ptr1)) {
							if (buf[j+1]==0) {
								zero++;
								if (zero > 4) {text=0;break;}
							}
							else {
								if (text < 4) text=0;
							}
						}
					} else {
						if (!isprint(buf[j]) &&
							 !isspace(buf[j]) &&
							 buf[j] != 0x1b   &&
							 buf[j] != 0x9b)
							{text=0;break;}
						else {
							text++;
							zero=0;
						}
					}
				}
				if ((buf[j-1] != 0) && (text<6)) text=0;
				if (text < 4) text=0;
				if (zero > 4) text=0;
				if (text) {

					/* write buffer to file */
					if (pflags&ADR_OUTPUT) {
						mnecat(";");
						mnecat(itohex(ptr1,adrlen));
						Ausgabe();
					}


					if ((ptr2-ptr1) > 10000) {
						printf("ptr1=%08x  ptr2=%08x  end=%08x\n",ptr1,ptr2,prgende);
					}

					/* get buffer for string */
					tptr=GetPMem((ptr2-ptr1)*5+6);

					if (pflags&ADR_OUTPUT) {
						for(i=0;i<((ptr2-ptr1-1)/16+1);i++) {
							strcpy(tptr,"\t;DC.B\t");k=7;
							strcpy(&tptr[k++],"$");
							strcpy(&tptr[k],itohex((ULONG)buf[i*16],2));k+=2;
							for(j=i*16+1;j<(ptr2-ptr1) && j<((i+1)*16);j++) {
								strcpy(&tptr[k],",$");k+=2;
								strcpy(&tptr[k],itohex((ULONG)buf[j],2));k+=2;
							}
							tptr[k++]='\n';
							WriteTarget(tptr,k);
						}
					}

					/* create string */
					for(tflag=0,j=0,k=0;j<(ptr2-ptr1);j++) {
						if ((j==0) ||
							 (j>0 && buf[j-1]==0  && buf[j]!=0) ||
							 (j>0 && buf[j-1]==10 && buf[j]!=0 && buf[j]!=10)) {
							if (tflag != 0) tptr[k++]='\n';
							strcpy(&tptr[k],"\tDC.B\t");k+=6;
							tflag=0;
						}
						if (isprint(buf[j])) {
							if (tflag==0) tptr[k++]='\"';
							if (tflag==2) {tptr[k++]=',';tptr[k++]='\"';}
							if (buf[j]=='\"' || buf[j]=='\'') tptr[k++]='\\';
							tptr[k++]=buf[j];
							tflag=1;
						} else {
							if (tflag==1) {tptr[k++]='\"';tptr[k++]=',';}
							if (tflag==2) tptr[k++]=',';
							strcpy(&tptr[k],itoa((ULONG)buf[j]));
							if (buf[j]>99) k+=3;
							else if (buf[j]>9) k+=2;
							else k++;
							tflag=2;
						}
					}
					if (tflag==1) tptr[k++]='\"';
					tptr[k++]='\n';

					/* write string */
					WriteTarget(tptr,k);

					/* free stringbuffer */
					FreeTaskPooled(tptr,(ptr2-ptr1)*5+6);

				}
				}
			}
			if (text == 0) {
				dtacat(itohex(ptr1,adrlen));

				if (((ULONG)buf)&1) {
					if ((*buf)==0) {
						mnecat("DS.B");
						adrcat("1");
					} else {
						mnecat("DC.B");
						adrcat("$");
						adrcat(itohex(*buf,2));
					}
					buf++;
					ptr1++;
					Ausgabe();
				}
				longs_per_line=0;
				while((ptr2-ptr1)>=4) {
					if ((*((ULONG *)buf))==0) {
						if (longs_per_line) Ausgabe();
						longs_per_line=0;
						for(i=0;(ptr2-ptr1)>=4 && (*((ULONG *)buf))==0;ptr1+=4,buf+=4) i++;
						mnecat("DS.L");
						adrcat(itoa(i));
						Ausgabe();
					}
					else {
						if (longs_per_line == 0) {
							mnecat("DC.L");
							adrcat("$");
						} else {
							adrcat(",$");
						}
						adrcat(itohex(*((ULONG *)buf),8));
						longs_per_line++;
						buf+=4;
						ptr1+=4;
						if (longs_per_line == 4) {
							longs_per_line=0;
							Ausgabe();
						}
					}
				}
				if (longs_per_line) Ausgabe();
				if ((ptr2-ptr1) > 1) {
					if ((*((UWORD *)buf))==0) {
						mnecat("DS.W");
						adrcat("1");
					} else {
						mnecat("DC.W");
						adrcat("$");
						adrcat(itohex(*((UWORD *)buf),4));
					}
					buf+=2;
					ptr1+=2;
					Ausgabe();
				}
				if (ptr2-ptr1) {
					if ((*buf)==0) {
						mnecat("DS.B");
						adrcat("1");
					} else {
						mnecat("DC.B");
						adrcat("$");
						adrcat(itohex(*buf,2));
					}
					buf++;
					ptr1++;
					Ausgabe();
				}
			}
			ptr1 = ptr2;
		}

		prgcount = (end-prgstart)/2;


	}

	if (pflags&SPLITFILE) {
		fclose(targetfile);
		targetfile=0;
	}

	/* write last label */
	WriteLabel2(prgstart+prgcount*2);

	if (p2labind != labcount) {
		fprintf(stderr,"labcount=%ld  p2labind=%ld\n",labcount,p2labind);
	}

	if (!(pflags&SPLITFILE))
		WriteTarget("\tEND\n",5);

	fprintf(stderr,"100%%\n\n");
}
STATIC void CheckPhase(ULONG adr)
{
static ULONG lc=0;

	if (labcount) {
		if (adr == -1)
			while (labelbuf[lc] < prgcount*2+prgstart) lc++;
		else {
			if (adr != labelbuf[lc++]) printf("PHASE ERROR: adr=%08x  %08x %08x %08x\n",adr,labelbuf[lc-2],labelbuf[lc-1],labelbuf[lc]);
			while (lc<labc1 && labelbuf[lc]==labelbuf[lc-1]) lc++;
		}
	}

}
STATIC void WriteLabel2(ULONG adr)
{
ULONG index;
UWORD flag;
static ULONG oldadr=0;

	/* output of percent every 2 kb */
	if ((adr-oldadr) >= 2048) {
		fprintf(stderr,"%3d%%\r",((adr-prgstart)*100)/prglen);
		fflush(stderr);
		oldadr = adr;
	}

	/* Labels fuer aktuelle Adresse schreiben */
	if (LabelAdr2[p2labind]<adr && p2labind<labcount) printf("%x adr=%x This=%x\n",p2labind,adr,LabelAdr2[p2labind]);
	if (LabelAdr2[p2labind]==adr && p2labind<labcount) {
		flag = 1;index=p2labind;
		while(LabelAdr2[p2labind]==adr && p2labind<labcount) {
			if (GetSymbol(LabelAdr[p2labind])) {
				fprintf(targetfile,"%s:\n",adrbuf);
				adrbuf[0]=0;
			}
			else
				flag=0;
			p2labind++;
		}
		if (flag == 0)
			fprintf(targetfile,"LAB_%04lX:\n",index);
	}
}
STATIC void Ausgabe(void)
{
WORD i;
	/* Hier findet die Ausgabe statt */
	if (pflags&ADR_OUTPUT) {
		if (dtabuf[0]) {
			i = 3-strlen(adrbuf)/8;
			if (i<=0) adrcat(" ");
			for(;i>0;i--) adrcat("\t");
			fprintf(targetfile,"\t%s\t%s;%s\n",mnebuf,adrbuf,dtabuf);
		}
		else if (adrbuf[0])
			fprintf(targetfile,"\t%s\t%s\n",mnebuf,adrbuf);
		else
			fprintf(targetfile,"\t%s\n",mnebuf);
	}
	else {
		if (adrbuf[0]) fprintf(targetfile,"\t%s\t%s\n",mnebuf,adrbuf);
		else fprintf(targetfile,"\t%s\n",mnebuf);
	}
	dtabuf[0]=0;
	adrbuf[0]=0;
	mnebuf[0]=0;
}
STATIC int P2WriteReloc()
{
	if (RelocAdr[nextreloc] == (prgcount*2 + prgstart)) {
		dtabuf[0]=0;
		mnebuf[0]=0;
		adrbuf[0]=0;
		mnecat("DC.W");
		adrcat("$");
		adrcat(itohex(sigw,4));
		dtacat(itohex(pc*2+prgstart,adrlen));
		prgcount=pc+1;
		Ausgabe();
		return(-1);
	}
	else {
		dtacat(itohex(buffer[prgcount++],4));
		return(0);
	}
}
STATIC UWORD NewAdrModes2(UWORD mode,UWORD reg)
/* AdrType :  6 --> Baseregister An */
/*           10 --> PC-relative     */
{
UWORD buf=buffer[prgcount];
UWORD scale;
UWORD bdsize;
UWORD odsize;
UWORD iis;
UWORD is;
UWORD operand,square1,square2;
LONG  adr = adr;


	#if 0
	if (P2WriteReloc()) return((UWORD)-1);
	#else
	if (P2WriteReloc()) return(0xffff);
	#endif

	/* Achtung: Ungerade Offsets werden vom A68K nicht angenommen */
	if (CPUTYPE&(M68000|M68010)) {
		if (buf&0x0700) return(NOADRMODE);
		else {
			if (mode==10) {
				adr = ((prgcount-1)*2+prgstart+(BYTE)buf);
				if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
					return(NOADRMODE);
			}
			if (pflags&OLDSTYLE) {
				if (mode==10) GetLabel(adr,mode);
				else adrcat(itoa((char)(buf&0x00FF)));
				adrcat("(");
			}
			else {
				adrcat("(");
				if (mode==10) GetLabel(adr,mode);
				else adrcat(itoa((char)(buf&0x00FF)));
				adrcat(",");
			}
			if (mode==6) {
				adrcat("A");
				adrcat(itohex(reg,1));
			}
			else adrcat("PC");
			if (buf&0x8000) adrcat(",A");
			else adrcat(",D");
			adrcat(itohex((buf>>12)&7,1));
			if (buf&0x0800) adrcat(".L");
			/* else adrcat(".W"); */
		}
	}
	else {
		scale =(buf&0x0600)>>9;
		if (buf&0x0100) { /* MC68020 (& up) FULL FORMAT */
			bdsize=(buf&0x0030)>>4;
			odsize=(buf&0x0003);
			iis   =(buf&0x0007);
			is    =(buf&0x0040)>>6;
			operand=square1=square2=0;

			if (mode==10) reg=0;
			if (buf&8)                 return(NOADRMODE);
			if (bdsize==0)             return(NOADRMODE);
			if (is==0 && iis==4)       return(NOADRMODE);
			if (is==1 && iis>=4)       return(NOADRMODE);
/*
			if (is==1 && (buf&0xfe00)) return(NOADRMODE);
			if (buf&0x0080 && reg!=0)  return(NOADRMODE);
*/
			if (bdsize>1)               {operand|=1;square1|=1;}
			if (!(buf&0x0080))          {operand|=2;square1|=2;}
			if (buf&0x0080 && mode==10) {operand|=2;square1|=2;}
			if (is==0 || buf&0xF000) {
				operand|=4;
				if (iis<4) square1|=4;
			}
			if (odsize>1) operand|=8;
			if (iis!=0)   square2=square1;
			else          square1=0;
			operand&=~square1;
			if (!square1) operand|=6;

			adrcat("(");
			if (square1) adrcat("[");
			if ((square1|operand)&1) { /* base displacement */
				if (bdsize==2) {
					if (mode==10 && !(buf&0x0080)) {
						adr = ((prgcount-1)*2+prgstart+(WORD)buffer[prgcount]);
						fprintf(targetfile,"adr=%08x\n",adr);
						if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
							return(NOADRMODE);
						if (P2WriteReloc()) return((UWORD)0xffff);	// -1
						GetLabel(adr,mode);
					}
					else {
						if (P2WriteReloc()) return((UWORD)0xffff);	// -1
						adrcat(itoa((WORD)buffer[prgcount-1]));
					}
				}
				if (bdsize==3) {
					if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
						GetLabel(RelocVal[nextreloc],9999);
						nextreloc++;
						dtacat(itohex(buffer[prgcount++],4));
						dtacat(itohex(buffer[prgcount++],4));
					}
					else {
						dtacat(itohex(buffer[prgcount++],4));
						if (mode==10 && !(buf&0x0080)) {
							adr = ((prgcount-2)*2+prgstart+(buffer[prgcount-1]<<16)+buffer[prgcount]);
							if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
								return(NOADRMODE);
							if (P2WriteReloc()) return((UWORD)0xffff);	// -1
							GetLabel(adr,mode);
							adrcat(".L");
						}
						else {
							if (P2WriteReloc()) return((UWORD)0xffff);	// -1
							adrcat("$");
							adrcat(itohex(buffer[prgcount-2],4));
							adrcat(itohex(buffer[prgcount-1],4));
						}
					}
				}
				square1&=~1;
				operand&=~1;
				if (square2 && !square1) {adrcat("]");square2=0;}
				if (square1 || operand)  adrcat(",");
			}
			/* base register or (Z)PC */
			if ((square1|operand)&2) {
				if (buf&0x0080) adrcat("Z");
				if (mode == 6) {
					adrcat("A");
					adrcat(itohex(reg,1));
				}
				else {
					adrcat("PC");
				}
				square1&=~2;
				operand&=~2;
				if (square2 && !square1) {adrcat("]");square2=0;}
				if (square1 || operand)  adrcat(",");
			}
			/* index register */
			if ((square1|operand)&4) {
				if (is) adrcat("Z");
				if (buf&0x8000) adrcat("A");
				else adrcat("D");
				adrcat(itohex((buf>>12)&7,1));
				if (buf&0x0800) adrcat(".L");
				/* else adrcat(".W"); */
				if (scale) {
					adrcat("*");
					adrcat(itoa(1<<scale));
				}
				square1&=~4;
				operand&=~4;
				if (square2 && !square1) {adrcat("]");square2=0;}
				if (square1 || operand)  adrcat(",");
			}
			/* outer displacement */
			if (operand&8) {
				if (odsize==2) {
					if (P2WriteReloc()) return((UWORD)0xffff);	// -1
					adrcat(itoa((WORD)buffer[prgcount-1]));
				}
				if (odsize==3) {
					if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
						GetLabel(RelocVal[nextreloc],9999);
						nextreloc++;
						dtacat(itohex(buffer[prgcount++],4));
						dtacat(itohex(buffer[prgcount++],4));
					}
					else {
						dtacat(itohex(buffer[prgcount++],4));
						if (P2WriteReloc()) return((UWORD)0xffff);	// -1
						adr=(buffer[prgcount-2]<<16)+buffer[prgcount-1];
						adrcat(itoa(adr));
						adrcat(".L");
/*
						adrcat("$");
						adrcat(itohex(buffer[prgcount-2],4));
						adrcat(itohex(buffer[prgcount-1],4));
*/
					}
				}
			}
		}
		else { /* MC68020 (& up) BRIEF FORMAT */
			if (mode==10) {
				adr = ((prgcount-1)*2+prgstart+(BYTE)buf);
				if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
					return(NOADRMODE);
			}
			if (pflags&OLDSTYLE) {
				if (mode==10) GetLabel(adr,mode);
				else adrcat(itoa((char)(buf&0x00FF)));
				adrcat("(");
			}
			else {
				adrcat("(");
				if (mode==10) GetLabel(adr,mode);
				else adrcat(itoa((char)(buf&0x00FF)));
				adrcat(",");
			}
			if (mode==6) {
				adrcat("A");
				adrcat(itohex(reg,1));
			}
			else adrcat("PC");
			if (buf&0x8000) adrcat(",A");
			else adrcat(",D");
			adrcat(itohex((buf>>12)&7,1));
			if (buf&0x0800) adrcat(".L");
			/* else adrcat(".W"); */
			if (scale) {
				adrcat("*");
				adrcat(itoa(1<<scale));
			}
		}
	}
	adrcat(")");
	return(mode);
}

STATIC int DoAdress2(UWORD adrs)
/* This is for PASS 2 */
{
UWORD i;
UWORD mode=adrmode;
UWORD dummy1;
UWORD buf=buffer[prgcount];
UWORD reg = reg,creg;
LONG  adr = adr;

	if (mode!=NOADRMODE) {
		/* if (mode>0x30) mode=0x07+(mode&0x07); */

		if (adrs&0x2000) reg=reg1;
		else reg=reg2;

		if (adrs&0x8000) mode=adrs&0x00FF;
		else
			if ((adrs&0x0fff)==adrs)
				if (!(adrs&(0x0800>>mode))) mode=NOADRMODE;
	}

	/* Adressierungsart bearbeiten */
	switch (mode) {
		case  0: /* Datenregister direkt */
					adrcat("D");
					adrcat(itohex(reg,1));
					break;
		case  1: /* Adressregister direkt */
					/* Auf Adressregister kann nicht byteweise zugegriffen werden    */
					/* Bei LEA ist extens == 0 (weil ungerade Adressen erlaubt sind) */
					if (extens || opcnumber==OPC_LEA) {
						adrcat("A");
						adrcat(itohex(reg,1));
					}
					else mode=NOADRMODE;
					break;
		case  2: /* Adressregister indirekt */
					adrcat("(A");
					adrcat(itohex(reg,1));
					adrcat(")");
					break;
		case  3: /* (An)+  address register indirect with postincrement */
					adrcat("(A");
					adrcat(itohex(reg,1));
					adrcat(")+");
					break;
		case  4: /* Adressregister indirekt mit Predekrement */
					adrcat("-(A");
					adrcat(itohex(reg,1));
					adrcat(")");
					break;
		case  5: /* (d16,An) Adressregister indirekt mit 16Bit-Offset */
					/* Achtung: Ungerade Offsets werden vom A68K nicht angenommen */
/*
					if (extens && buf&1) mode=NOADRMODE;
					else {
*/
						if (P2WriteReloc()) return(-1);
						dummy1=0;
						if (pflags&BASEREG2 && reg==basereg) {
							adr = prgstart+baseadr+(WORD)buf;
							if (adr>(LONG)(moduloffs[basesec]+modultab[basesec]-2) || adr<(LONG)moduloffs[basesec])
								dummy1=0;
							else dummy1=1;
						}
						if (dummy1) GetLabel(adr,mode);
						else {
							if (pflags&OLDSTYLE) {
								adrcat(itoa((WORD)buf));
								adrcat("(A");
							}
							else {
								adrcat("(");
								adrcat(itoa((WORD)buf));
								adrcat(",A");
							}
							adrcat(itohex(reg,1));
							adrcat(")");
/*						} */
					}
					break;
		case  6: /* (bd,An,Xn.SIZE*SCALE) & ([bd,An,Xn.SIZE*SCALE],od) & ... */
		case 10: /* (bd,PC,Xn.SIZE*SCALE) & ([bd,PC,Xn.SIZE*SCALE],od) & ... */
					if ((mode=NewAdrModes2(mode,reg))==(UWORD)0xffff) return(-1);
					break;
		case  7: /* Absolute Adresse 16Bit */
					adr = (WORD)buf;
					if (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR || opcnumber==OPC_BITSHIFT1))
						mode=NOADRMODE;
					else {
						if (P2WriteReloc()) return(-1);
						/* adrcat("("); */
						/* PEA  wegen den C-Proggies (Stackuebergabe) */
						if (opcnumber == OPC_PEA)	adrcat(itoa(adr));
						else	{
							if (sourcetype == 1 && prgstart && (adr >= prgstart && adr <= prgende))
								GetLabel(adr,mode);
							else
								GetXref(adr);
						}
						/* adrcat(").W"); */
						adrcat(".W");
					}
					break;
		case  8: /* Absolute Adresse 32Bit */
					adr = ((buf<<16) + buffer[prgcount+1]);
					if (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR || opcnumber==OPC_BITSHIFT1))
						mode=NOADRMODE;
					else {
						if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
							if ((pflags&BASEREG2) &&
							    (RelocMod[nextreloc]==basesec))
								NearFlag = 1;
							GetLabel(RelocVal[nextreloc],9999);
							nextreloc++;
						}
						else {
							/* PEA  wegen den C-Proggies (Stackuebergabe) */
							if (opcnumber == OPC_PEA) {
								adrcat("$");
								adrcat(itohex(adr,8));
							}
							else {
								if (sourcetype == 1 && prgstart && (adr >= prgstart && adr <= prgende))
									GetLabel(adr,mode);
								else
									GetXref(adr);
							}
						}
						dtacat(itohex(buffer[prgcount++],4));
						dtacat(itohex(buffer[prgcount++],4));
					}
					break;
		case  9: /* PC - Relativ */
					adr = (prgcount*2+prgstart+(WORD)buf);
					if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR))) mode=NOADRMODE;
					else {
						if (P2WriteReloc()) return(-1);
						if (pflags&OLDSTYLE) {
							GetLabel(adr,mode);
							adrcat("(PC)");
						}
						else {
							adrcat("(");
							GetLabel(adr,mode);
							adrcat(",PC)");
						}
					}
					break;
		case 11: /* IMMEDIATE */
					if (adrs==sourceadr[opcnumber]) {
						if (extens!=3) {
							if (extens==0) {
								if (buf&0xFF00) mode=NOADRMODE;
								else {
									if (P2WriteReloc()) return(-1);
									adrcat("#$");
									adrcat(itohex(buf,2));
								}
							}
							if (extens==1) {
								if (P2WriteReloc()) return(-1);
								adrcat("#$");
								adrcat(itohex(buf,4));
							}
							if (extens==2) {
								/* adr = ((buf<<16) + buffer[prgcount+1]); */
								if (RelocAdr[nextreloc]==(prgcount*2+prgstart+2))
									mode=NOADRMODE;
								else {
									if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
										adrcat("#");
										if ((pflags&BASEREG2) &&
										    (RelocMod[nextreloc]==basesec))
											NearFlag = 1;
										GetLabel(RelocVal[nextreloc],9999);
										nextreloc++;
									}
									else {
										adrcat("#$");
										adrcat(itohex(buf,4));
										adrcat(itohex(buffer[prgcount+1],4));
									}
									dtacat(itohex(buffer[prgcount++],4));
									dtacat(itohex(buffer[prgcount++],4));
								}
							}
						}
						else mode=NOADRMODE;
					}
					else {
						if (extens==0) adrcat("CCR");
						if (extens==1) adrcat("SR");
						if (extens==2) mode=NOADRMODE; /* d=immediate long */
					}
					break;
		case 12: adrcat("CCR");
					break;
		case 13: adrcat("SR");
					break;
		case 14: adrcat("USP");
					break;
		case 15: /* MOVEM */
					if ((dummy1=extra)) {
						i=0;
						if ((opcnumber==OPC_MOVEM1 || opcnumber==OPC_MOVEM3) && !(sigw&0x0018)) {
							while(dummy1) {
								if (dummy1&0x8000) {
									if (i<8) adrcat("D");
									else adrcat("A");
									adrcat(itohex(i&7,1));
									if ((dummy1&0x4000) && (i&7)<7) {
										adrcat("-");
										while((dummy1&0x4000) && (i&7)<7) {
											dummy1<<=1;
											i++;
										}
										if (i<8) adrcat("D");
										else adrcat("A");
										adrcat(itohex(i&7,1));
									}
									if ((UWORD)(dummy1<<1)) adrcat("/");
								}
								i++;
								dummy1<<=1;
							}
						}
						else {
							while(dummy1 || i<16) {
								if (dummy1&0x0001) {
									if (i<8) adrcat("D");
									else adrcat("A");
									adrcat(itohex(i&7,1));
									if ((dummy1&0x0002) && (i&7)<7) {
										adrcat("-");
										while((dummy1&0x0002) && (i&7)<7) {
											dummy1>>=1;
											i++;
										}
										if (i<8) adrcat("D");
										else adrcat("A");
										adrcat(itohex(i&7,1));
									}
									if (dummy1>>1) adrcat("/");
								}
								i++;
								dummy1>>=1;
							}
						}
					}
					else {
						adrcat("(NOREG!)");
					}
					break;
		case 16: /* ADDQ,SUBQ */
					adrcat("#");
					if (!reg) reg=8;
					adrcat(itohex(reg,1));
					break;
		case 17: /* BKPT */
					adrcat("#");
					adrcat(itohex(reg,1));
					break;
		case 18: /* DBcc */
					adr = (prgcount*2+prgstart+(WORD)buf);
					if (adr>(LONG)(moduloffs[modulcnt]+modultab[modulcnt]-2) || adr<(LONG)moduloffs[modulcnt] || adr&1 || !buf)
						mode=NOADRMODE;
					else {
						if (P2WriteReloc()) return(-1);
						GetLabel(adr,mode);
					}
					break;
		case 19: /* TRAP */
					adrcat("#");
					adrcat(itoa(sigw&0xF));
					break;
		case 20: /* moveq */
					adrcat("#");
					adrcat(itoa((char)(sigw&0x00FF)));
					break;
		case 21: /* Bcc */
					if ((sigw&0x00ff)==0x00ff) {
						if (CPUTYPE&M020UP) {
							displace=(buf<<16)|buffer[prgcount+1];
							if (displace!=0 && displace!=2) {
								displace+=prgcount*2;
								if (P2WriteReloc()) return(-1);
								if (P2WriteReloc()) return(-1);
								mnecat(".L");
							}
							else mode=NOADRMODE;
						}
						else mode=NOADRMODE;
					} else if ((sigw&0x00ff)==0x0000) {
						if (buf) {
							displace=(prgcount*2+(WORD)(buf));
							if (P2WriteReloc()) return(-1);
						}
						else mode=NOADRMODE;
					} else {
						mnecat(".S");
						displace=(prgcount*2+(BYTE)(sigw&0x00ff));	// char!!
					}
					adr = prgstart+displace;
					if (adr>(LONG)(moduloffs[modulcnt]+modultab[modulcnt]-2) || adr<(LONG)moduloffs[modulcnt] || adr&1)
						mode=NOADRMODE;
					else GetLabel(adr,mode);
					break;
		case 22: /* LINK , RTD */
					if (buf&1) mode=NOADRMODE;
					else {
						if (P2WriteReloc()) return(-1);
						adrcat("#");
						adrcat(itoa((WORD)buf));
					}
					break;
		case 23: /* BTST,BCLR,... IMMEDIATE&REGISTER,SOURCEOP ONLY */
					mnecat(&bitop[extens][0]);
					if (!extens) destadr[opcnumber]=0x0bfe; /* BTST */
					else destadr[opcnumber]=0x0bf8;        /* sonstige B... */
					if (sigw&0x0100) {
						adrcat("D");
						adrcat(itohex(reg,1));
					}
					else {
						if (P2WriteReloc()) return(-1);
						adrcat("#");
						if (sigw&0x0038) {
							if (buf&0xFFF8) mode=NOADRMODE;
						}
						else {
							if (buf&0xFFE0) mode=NOADRMODE;
						}
						adrcat(itoa(buf));
					}
					extens=0; /* Set extension to BYTE (undefined before) */
					break;
		case 24: /* STOP */
					if (P2WriteReloc()) return(-1);
					adrcat("#$");
					adrcat(itohex(buf,4));
					break;
		case 25: /* BITFIELD */
					adrcat("{");
					reg=(extra&0x07c0)>>6;
					if (extra&0x0800) {
						if (reg>7) mode=NOADRMODE;
						adrcat("D");
					}
					adrcat(itoa(reg));
					adrcat(":");
					reg=(extra&0x001F);
					if (extra&0x0020) {
						if (reg>7) mode=NOADRMODE;
						adrcat("D");
					}
					adrcat(itoa(reg));
					adrcat("}");
					if (((sigw&0x0700)>>8)&1) {
						/* BFEXTU, BFEXTS, BFFFO, BFINS */
						if (extra&0x8000) mode=NOADRMODE;
						adrcat(",D");
						reg=(extra&0x7000)>>12;
						adrcat(itoa(reg));
					}
					else {
						if (extra&0xF000) mode=NOADRMODE;
					}
					break;
		case 26: /* RTM */
					if (sigw&0x0008) adrcat("A");
					else adrcat("D");
					adrcat(itoa(reg2));
					break;
		case 27: /* CAS2  SOURCE/DESTINATION */
					buf=buffer[prgcount];
					if (P2WriteReloc()) return(-1);
					extens=(sigw&0x0600)>>9;
					if (extens==0 || extens==1) mode=NOADRMODE;
					else mnecat(extension[--extens]);
					if (buf&0x0e38 || extra&0x0e38) mode=NOADRMODE;
					else {
						adrcat("D");
						adrcat(itoa(extra&7));
						adrcat(":");
						adrcat("D");
						adrcat(itoa(buf&7));
						adrcat(",");
						adrcat("D");
						adrcat(itoa((extra&0x01c0)>>6));
						adrcat(":");
						adrcat("D");
						adrcat(itoa((buf&0x01c0)>>6));
						adrcat(",");
						if (extra&0x8000) adrcat("(A");
						else adrcat("(D");
						adrcat(itoa((extra&0x7000)>>12));
						adrcat("):(");
						if (buf&0x8000) adrcat("(A");
						else adrcat("(D");
						adrcat(itoa((buf&0x7000)>>12));
						adrcat(")");
					}
					break;
		case 28: /* CAS SOURCE */
					extens=(sigw&0x0600)>>9;
					if (extens==0) mode=NOADRMODE;
					else mnecat(extension[--extens]);
					if (extra&0xfe38) mode=NOADRMODE;
					else {
						adrcat("D");
						adrcat(itoa(extra&7));
						adrcat(",");
						adrcat("D");
						adrcat(itoa((extra&0x01c0)>>6));
					}
					break;
		case 29: /* DIVIDE/MULTIPLY LONG  SIGNED/UNSIGNED */
					if (extra&0x83f8) mode=NOADRMODE;
					else {
						if (extra&0x0800) mnecat("S");
						else mnecat("U");
						if (!(extra&0x0400) && opcnumber==OPC_DIVL) mnecat("L");
						reg=(extra&0x7000)>>12;
						adrcat("D");
						if (reg==(extra&0x0007)) {
							if (opcnumber==OPC_MULL) mode=NOADRMODE;
							else adrcat(itoa(reg));
						}
						else {						
							adrcat(itoa(extra&0x0007));
							adrcat(":D");
							adrcat(itoa(reg));
						}
						mnecat(".L");
					}
					break;
		case 30: /* LINK LONG */
					displace=(buf<<16)|buffer[prgcount+1];
					if (displace&1) mode=NOADRMODE;
					else {
						if (P2WriteReloc()) return(-1);
						if (P2WriteReloc()) return(-1);
						adrcat("#");
						adrcat(itoa(displace));
					}
					break;
		case 31: /* MOVE16 POSTINCREMENT ONLY (DESTINATION) */
					if ((buf&0x8fff)!=0x8000) mode=NOADRMODE;
					else {
						if (P2WriteReloc()) return(-1);
						adrcat("(A");
						adrcat(itoa((buf&0x7000)>>12));
						adrcat(")+");
					}
					break;
		case 32: /* CINV & CPUSH */
					if (sigw&0x0020) mnecat("PUSH");
					else mnecat("INV");
					destadr[opcnumber]=0x8002;
					switch ((sigw&0x0018)>>3) {
						case 0:
							mode=NOADRMODE;
							break;
						case 1:
							mnecat("L");
							break;
						case 2:
							mnecat("P");
							break;
						case 3:
							if (sigw&7) mode=NOADRMODE;
							else {
								mnecat("A");
								destadr[opcnumber]=0x0000;
							}
							break;
					}
					adrcat(caches[(sigw&0x00c0)>>6]);
					break;
		case 33: /* MOVEC */
					if (P2WriteReloc()) return(-1);
					reg =(buf&0x7000)>>12;
					creg=buf&0x0fff;
					if (creg&0x07f8) mode=NOADRMODE;
					else {
						if (sigw&1) {
							if (buf&0x8000) adrcat("A");
							else adrcat("D");
							adrcat(itoa(reg));
							adrcat(",");
						}
						if (creg&0x0800) creg=(creg%8)+9;
						if (CPUTYPE&cregflag[creg]) adrcat(cregname[creg]);
						else mode=NOADRMODE;
						if (!(sigw&1)) {
							adrcat(",");
							if (buf&0x8000) adrcat("A");
							else adrcat("D");
							adrcat(itoa(reg));
						}
					}
					break;
			case 34: /* MOVES */
					if (extra&0x07ff) mode=NOADRMODE;
					else {
						reg=(extra&0x7000)>>12;
						if (extra&0x8000) adrcat("A");
						else adrcat("D");
						adrcat(itoa(reg));
					}
					break;
	}
	if (prgcount > CodeAreaEnd) mode=NOADRMODE;
	if (mode==NOADRMODE) {
		NearFlag =0;
		adrbuf[0]=0;
		mnebuf[0]=0;
		dtabuf[0]=0;
		mnecat("DC.W");
		adrcat("$");
		adrcat(itohex(sigw,4));
		dtacat(itohex(pc*2+prgstart,adrlen));
		prgcount = pc+1;
		Ausgabe();
		return(-1);
	}
	return(0);
}
STATIC void FormatError(void)
{
		fprintf(stderr,"Usage  : IRA");
		fprintf(stderr," [options] <Source> [Target]\n\n");
		fprintf(stderr,"Source : ");
		fprintf(stderr,"\tSpecifies the path of the source.\n");
		fprintf(stderr,"Target : ");
		fprintf(stderr,"\tSpecifies the path of the target.\n");
		fprintf(stderr,"Options:\n");
		fprintf(stderr,"\t-M680x0\t\tx = 0,1,2,3,4: Specifies processor.\n");
		fprintf(stderr,"\t-BINARY\t\tTreat sourcefile as binary.\n");
		fprintf(stderr,"\t-a\t\tAppend address and data to every line.\n");
		fprintf(stderr,"\t-INFO\t\tPrint information about the hunkstructure.\n");
		fprintf(stderr,"\t-OFFSET=<offset>\tSpecifies offset to relocate at.\n");
		fprintf(stderr,"\t-TEXT=<x>\t\tx = 1: Method for searching text.\n");
		fprintf(stderr,"\t-KEEPZH\t\tHunks with zero length are recognised.\n");
		fprintf(stderr,"\t-KEEPBIN\tKeep the file with the binary data.\n");
		fprintf(stderr,"\t-OLDSTYLE\tAdressing modes are M68000 like.\n");
		fprintf(stderr,"\t-NEWSTYLE\tAdressing modes are M68020 like.\n");
		fprintf(stderr,"\t-SPLITFILE\tPut each section in its own file.\n");
		fprintf(stderr,"\t-CONFIG\t\tLoads configfile.\n");
		fprintf(stderr,"\t-PREPROC\tFinds data in code sections. Useful.\n");
		fprintf(stderr,"\t-ENTRY=<offset>\t\tWhere to begin scanning of code.\n");
		fprintf(stderr,"\t-BASEREG[=<x>,<adr>,<sec>]\n");
		fprintf(stderr,"\t\t\tBaserelative mode d16(Ax).\n");
		fprintf(stderr,"\t\t\tx = 0-7: Number of the address register.\n");
		fprintf(stderr,"\t\t\tadr    : Base address.\n");
		fprintf(stderr,"\t\t\tsec    : Section accessed by d16(Ax).\n\n");
		ExitPrg(0);
}
STATIC void Init(void)
{
ULONG  i;
UBYTE  zwbuf[80];
char  *odata,option,*data;
int    nextarg=1;
UWORD  argflag=0,errflag=0;

	NEWLIST(&list);

	if (!ARGC) exit(0); /* Workbench wird noch nicht unterstuetzt */

	#ifdef __SASC
	if (onbreak(_abort)) exit(0);
	#endif

	fprintf(stderr,IDSTRING1,VERSION,REVISION);

	if (ARGC < 2) FormatError();

	while ((odata=argopt(ARGC,ARGV,"",&nextarg,&option))) {
		switch (option) {
			case  'e':
			case  'E':
				if (!strnicmp(odata,"NTRY=",5)) {
					if (odata[5]=='$') stch_l(&odata[6],(long *)&codeentry);
					else stcd_l(&odata[5],(long *)&codeentry);
					if ((LONG)codeentry < 0L) {
						printf("-ENTRY: ENTRY must not be negativ!\n");
						errflag=1;
					}
					break;
				}
				errflag=1;
				break;
			case  's':
			case  'S':
				if (!(stricmp(odata,"PLITFILE"))) {pflags |= SPLITFILE;break;}
				errflag=1;
				break;
			case  'f':
			case  'F':
				if (!(stricmp(odata,"ORCECODE"))) {pflags |= FORCECODE;break;}
				errflag=1;
				break;
			case  'p':
			case  'P':
				if (!(stricmp(odata,"REPROC"))) {pflags |= PREPROC;break;}
				errflag=1;
				break;
			case  't':
			case  'T':
				if (!(stricmp(odata,"EXT=1"))) {textmethod=1;break;}
				errflag=1;
				break;
			case  'm':
			case  'M':
				if (!strcmp(odata,"68000")) {CPUTYPE|=M68000;break;}
				if (!strcmp(odata,"68010")) {CPUTYPE|=M68010;break;}
				if (!strcmp(odata,"68020")) {CPUTYPE|=M68020;break;}
				if (!strcmp(odata,"68030")) {CPUTYPE|=M68030;break;}
				if (!strcmp(odata,"68040")) {CPUTYPE|=M68040;break;}
				if (!strcmp(odata,"68060")) {CPUTYPE|=M68060;break;}
				if (!strcmp(odata,"68881")) {CPUTYPE|=M68881;break;}
				if (!strcmp(odata,"68851")) {CPUTYPE|=M68851;break;}
				errflag=1;
				break;
			case  'a':
			case  'A':
				pflags |= ADR_OUTPUT;
				break;
			case  'O':
			case  'o':
				if (!stricmp(odata,"LDSTYLE")) {argflag=1;break;}
				if (!strnicmp(odata,"FFSET=",6)) {
					if (odata[6]=='$') stch_l(&odata[7],(long *)&prgstart);
					else stcd_l(&odata[6],(long *)&prgstart);
					if ((LONG)prgstart < 0L) {
						printf("-OFFSET: OFFSET must not be negativ!\n");
						errflag=1;
					}
				}
				break;
			case  'I':
			case  'i':
				if (!(strnicmp(odata,"NFO",3))) pflags |= SHOW_RELOCINFO;
				break;
			case  'C':
			case  'c':
				if (!(strnicmp(odata,"ONFIG",5))) {
					pflags |= CONFIG;
					break;
				}
				errflag=1;
				break;
			case  'k':
			case  'K':
				if (!(stricmp(odata,"EEPZH")))  {pflags |= KEEP_ZEROHUNKS;break;}
				if (!(stricmp(odata,"EEPBIN"))) {pflags |= KEEP_BINARY;break;}
				errflag=1;
				break;
			case  'n':
			case  'N':
				if (!(stricmp(odata,"EWSTYLE"))) {argflag=2;break;}
				errflag=1;
				break;
			case  'b':
			case  'B':
				if (!(stricmp(odata,"INARY")))  {sourcetype=1;break;}
				if (!(stricmp(odata,"ASEREG"))) {pflags |= BASEREG1;break;}
				if (!(strnicmp(odata,"ASEREG=",7))) {
					basereg=odata[7]-'0';
					if ((data=strchr(odata,','))) {
						if (data[1]=='$') stch_l(&data[2],(long *)&baseadr);
						else stcd_l(&data[1],(long *)&baseadr);
						pflags |= BASEREG2;
						if ((data=strchr(&data[1],','))) {
							stcd_l(&data[1],(long *)&basesec);
						}
					}
					else pflags |= BASEREG1;
					if (basereg > 7) errflag=1;
					break;
				}
				errflag=1;
				break;
			default:
				errflag=1;
				break;
		}
	}

	if (errflag==1) FormatError();

	if (CPUTYPE&(M68000|M68010)) pflags|=OLDSTYLE;
	if (argflag==1) pflags|= OLDSTYLE;
	if (argflag==2) pflags&=~OLDSTYLE;

	if (nextarg < ARGC)
		strcpy(sourcename,ARGV[nextarg++]);
	else
		ExitPrg("No source specified!\n");

	if (nextarg < ARGC)
		strcpy(targetname,ARGV[nextarg]);
	else {
		strsfn(sourcename,0,0,targetname,0);
		strcat(targetname,".asm");
		while (!stricmp(sourcename,targetname))
			strcat(targetname,"1");
	}

	strsfn(sourcename,0,0,configname,0);
	strcat(configname,".cnf");

	strsfn(sourcename,0,0,binname,0);
	strcat(binname,".bin");
	while(!stricmp(sourcename,binname))
		strcat(binname,"1");

	strcpy(labname,"L_");
	strcat(labname,itohex((long)FindTask(0),8)); /* Namen fuer Zwischenfile */


	if (!sourcetype) sourcetype = AutoScan();  /* Filetyp herausfinden */
	if (sourcetype == 1) relocmax=1;

	LabelAdr    = GetPMem(LabelMax*4);
	RelocAdr    = GetPMem(relocmax*4);
	RelocAdr[0] = 1; /* Marke, falls keine Relokationen vorliegen */
	RelocOff    = GetPMem(relocmax*4);
	RelocVal    = GetPMem(relocmax*4);
	RelocMod    = GetPMem(relocmax*4);
	SymbolName  = GetPMem(SymbolMax*sizeof(UBYTE *));
	SymbolValue = GetPMem(SymbolMax*sizeof(ULONG));
	CodeArea1   = GetPMem(CodeAreaMax*sizeof(ULONG));
	CodeArea2   = GetPMem(CodeAreaMax*sizeof(ULONG));
	CNFArea1    = GetPMem(CNFAreaMax*sizeof(ULONG));
	CNFArea2    = GetPMem(CNFAreaMax*sizeof(ULONG));
	CodeAdr     = GetPMem(CodeAdrMax*sizeof(ULONG));

	if (sourcetype == 2 || sourcetype == 3) {
		if (!(sourcefile = fopen(sourcename,"r")))
			ExitPrg("Can't open %s\n",sourcename);
		if (!(binfile = fopen(binname,"w")))
			ExitPrg("Can't open %s\n",binname);
	}
	if (sourcetype == 1) ReadBinary();
	if (sourcetype == 2) ReadExecutable();
	if (sourcetype == 3) ReadObject();
	if (basesec >= modulcount && basesec != -1)
		ExitPrg("There aren't so many sections (%ld).\n",basesec);

	if (sourcefile) fclose(sourcefile);
	if (binfile)    fclose(binfile);
	binfile = sourcefile = 0;

	prglen = FileLength(binname);

	if (!(binfile = fopen(binname,"r")))
		ExitPrg("Can't open %s\n",binname);
	if (!(labfile = fopen(labname,"w")))
		ExitPrg("Can't open %s\n",labname);

	LabelNum    = GetPMem(modulcount*sizeof(ULONG));
	XRefListe   = GetPMem(LabX_len*sizeof(ULONG));
	buffer      = GetPMem(prglen+4);

	if ((fread(buffer,1,prglen,binfile)) != prglen)
		ExitPrg("Can't read all data!\n");

	prgende = prgstart + prglen;

	if (pflags&CONFIG) ReadConfig();

	prgende = prgstart + prglen;

	adrlen=sprintf(zwbuf,"%x",prgende);

	if (codeentry >= prgende) ExitPrg("ERROR: Entry(=$%08X) is out of range!\n",codeentry);
	if (codeentry < prgstart) codeentry=prgstart;

	printf("SOURCE : %s\n",sourcename);
	printf("TARGET : %s\n",targetname);
	if (pflags&KEEP_BINARY)
		printf("BINARY : %s\n",binname);
	if (pflags&CONFIG)
		printf("CONFIG : %s\n",configname);
	for(i=0;i<5;i++)
		if (CPUTYPE&(1<<i))
			printf("MACHINE: %s\n",cpuname[i]);
	printf("OFFSET : $%08X\n",prgstart);
}

void ExitPrg(CONST_STRPTR errtext, ...)
{
	#ifdef __SASC
	onbreak(0); /* Break-Trap ausklinken */
	#endif

	if (errtext) {
		va_list arguments;
		va_start(arguments,errtext);
		vprintf(errtext,arguments);
		fprintf(stderr, "\n");
		va_end(arguments);
	}

	#ifndef __MORPHOS__
	// closed by libnix
	if (sourcefile) fclose(sourcefile);
	if (binfile)    fclose(binfile);
	if (targetfile) fclose(targetfile);
	if (labfile)    fclose(labfile);
	#endif

	if (labname[0])
	{
		#if 0
		if ((labfile = fopen(labname,"r"))) {
			fclose(labfile);
			remove(labname);
		}
		#else
		DeleteFile(labname);
		#endif
	}
	if (!(pflags&KEEP_BINARY) && binname[0])
	{
		#if 0
		if ((binfile = fopen(binname,"r"))) {
			fclose(binfile);
			remove(binname);
		}
		#else
		DeleteFile(binname);
		#endif
	}

#ifndef __MORPHOS__
	/* MorphOS frees memory automatically on exit */

	if (modulstrt)
	{
		ULONG i;
		for(i=0;i<modulcount;i++) {
			if (modulstrt[i]) FreeTaskPooled(modulstrt[i],modultab[i]);
		}
		FreeTaskPooled(modulstrt,modulcount*sizeof(ULONG *));
	}

	if (memtype)    FreeTaskPooled(memtype  ,modulcount*sizeof(UWORD));
	if (modultab)   FreeTaskPooled(modultab ,modulcount*sizeof(ULONG));
	if (modultype)  FreeTaskPooled(modultype,modulcount*sizeof(ULONG));
	if (moduloffs)  FreeTaskPooled(moduloffs,modulcount*sizeof(ULONG));
	if (labelbuf)   FreeTaskPooled(labelbuf,labc1*sizeof(ULONG));
	if (buffer)     FreeTaskPooled(buffer,prglen+4);
	if (RelocAdr)   FreeTaskPooled(RelocAdr,relocmax*sizeof(ULONG));
	if (RelocMod)   FreeTaskPooled(RelocMod,relocmax*sizeof(ULONG));
	if (RelocOff)   FreeTaskPooled(RelocOff,relocmax*sizeof(LONG));
	if (RelocVal)   FreeTaskPooled(RelocVal,relocmax*sizeof(ULONG));
	if (LabelNum)   FreeTaskPooled(LabelNum,modulcount*sizeof(ULONG));
	if (LabelAdr)   FreeTaskPooled(LabelAdr,LabelMax*sizeof(ULONG));
	if (LabelAdr2)  FreeTaskPooled(LabelAdr2,(LabelMax+1)*sizeof(ULONG));
	if (XRefListe)  FreeTaskPooled(XRefListe,LabX_len*sizeof(ULONG));
	if (RelocBuffer)FreeTaskPooled(RelocBuffer,RelocNumber*sizeof(ULONG));
	if (DRelocBuffer)FreeTaskPooled(DRelocBuffer,RelocNumber*sizeof(UWORD));
	if (CodeArea1)  FreeTaskPooled(CodeArea1,CodeAreaMax*sizeof(ULONG));
	if (CodeArea2)  FreeTaskPooled(CodeArea2,CodeAreaMax*sizeof(ULONG));
	if (CNFArea1)   FreeTaskPooled(CNFArea1,CNFAreaMax*sizeof(ULONG));
	if (CNFArea2)   FreeTaskPooled(CNFArea2,CNFAreaMax*sizeof(ULONG));
	if (CodeAdr)    FreeTaskPooled(CodeAdr,CodeAdrMax*sizeof(ULONG));
	if (SymbolCount) {
		for(i=0;i<SymbolCount;i++)
			if (SymbolName[i]) FreeTaskPooled(SymbolName[i], strlen(SymbolName[i])+1);
		if (SymbolValue) FreeTaskPooled(SymbolValue, SymbolCount*sizeof(ULONG));
		if (SymbolName)  FreeTaskPooled(SymbolName,  SymbolCount*sizeof(UBYTE *));
	}

	while (list.lh_TailPred != (struct Node *)&list)
		FreeTaskPooled(REMHEAD(&list),sizeof(struct Node));
#endif

	exit(0);
}
/* 1. Pass : find out possible addresses for labels */
STATIC void DPass1(void)
{
UWORD dummy;
ULONG i,area,end;

	PASS = 1;
	prgcount = 0;
	nextreloc= 0;
	modulcnt =-1;


	for(area=0;area<CodeAreas;area++) {

		while ((moduloffs[modulcnt+1] == CodeArea1[area]) && ((modulcnt+1) < modulcount))
			modulcnt++;

		/* HERE BEGINS THE CODE PART OF PASS 1 */
		/***************************************/

		CodeAreaEnd = (CodeArea2[area]-prgstart)/2;

		while(prgcount < CodeAreaEnd) {

			WriteLabel1(prgstart+prgcount*2);

			if (RelocAdr[nextreloc] == (prgcount*2 + prgstart)) {
				nextreloc++;
				prgcount += 2;
				continue;
			}
			pc = prgcount;
			sigw=(UWORD)buffer[prgcount++];


			GetOpcode();
			if (flags[opcnumber]&0x20) {
				extra=buffer[prgcount];
				if (P1WriteReloc()) continue;
			}

			if (opcnumber == OPC_CMPI) {
				if (CPUTYPE&M020UP) destadr[opcnumber]=0x0bfe;
				else destadr[opcnumber]=0x0bf8;
			} else if (opcnumber==OPC_TST) {
				if (CPUTYPE&M020UP) sourceadr[opcnumber]=0x0fff;
				else sourceadr[opcnumber]=0x0bf8;
			} else if (opcnumber==OPC_BITFIELD) {
				dummy=(sigw&0x0700)>>8;
				if (dummy==2 || dummy==4 || dummy==6 || dummy==7) sourceadr[opcnumber]=0x0a78;
				else sourceadr[opcnumber]=0x0a7e;
			} else if (opcnumber==OPC_C2) {
				if (extra&0x07ff) adrmode=NOADRMODE;
				else {
					reg1=(extra&0x7000)>>12;
					if (extra&0x8000) destadr[opcnumber]=0xa001;
					else destadr[opcnumber]=0xa000;
				}
			} else if (opcnumber==OPC_MOVE162) {
				switch ((buffer[prgcount]&0x0018)>>3) {
					case 0: /* (An)+,(xxx).L */
						sourceadr[opcnumber]=0x8003;
						destadr[opcnumber]  =0x8008;
						break;
					case 1: /* (xxx).L,(An)+ */
						sourceadr[opcnumber]=0x8008;
						destadr[opcnumber]  =0x8003;
						break;
					case 2: /* (An) ,(xxx).L */
						sourceadr[opcnumber]=0x8002;
						destadr[opcnumber]  =0x8008;
						break;
					case 3: /* (xxx).L, (An) */
						sourceadr[opcnumber]=0x8008;
						destadr[opcnumber]  =0x8002;
						break;
				}
			} else if (opcnumber==OPC_MOVES) {
				if (extra&0x0800) {
					sourceadr[opcnumber]=0x8022;
					destadr[opcnumber]  =0x03f8;
				}
				else {
					sourceadr[opcnumber]=0x03f8;
					destadr[opcnumber]  =0x8022;
				}
			}

			if ((flags[opcnumber]&0x40) && extens==3) adrmode=NOADRMODE;

			if (sourceadr[opcnumber])
				if (DoAdress1(sourceadr[opcnumber])) continue;
			if (destadr[opcnumber]) {
				if (opcnumber==OPC_MOVEB || opcnumber==OPC_MOVEW || opcnumber==OPC_MOVEL) {
					adrmode=((sigw&0x01c0)>>3)|reg1;
					if (adrmode<0x38) adrmode=(adrmode>>3);
					else adrmode=7+reg1;
					reg2=reg1;
				}
				if (DoAdress1(destadr[opcnumber])) continue;
				else {
					if (opcnumber==OPC_LEA || opcnumber==OPC_MOVEAL) {
						if (pflags&BASEREG1) {
							if (adrmode2==1 && reg1==basereg)
								printf("BASEREG\t%08X: A%hd\n",pc*2+prgstart,basereg);
						}
					}
				}
			}

			if (prgcount > CodeAreaEnd)
				printf("P1 Watch out: prgcount*2(=%08x) > (prgende-prgstart)(=%08x)\n",prgcount*2,prgende-prgstart);

		}


		while ((moduloffs[modulcnt+1] == CodeArea2[area]) && ((modulcnt+1) < modulcount))
			modulcnt++;


		/* HERE BEGINS THE DATA PART OF PASS 1 */
		/***************************************/

		if ((area+1)<CodeAreas) 
			end = CodeArea1[area+1];
		else
			end = prgende;

		for(i=CodeArea2[area];i<end;i++) {
			/* WriteLabel1(i); */
			if (RelocAdr[nextreloc] == i) {
				nextreloc ++;
				i += 3;
			}
		}
		prgcount = (end-prgstart)/2;
	}

	fprintf(stderr,"Pass 1: 100%%\n");
	if (relocount != nextreloc) printf("relocount=%lu nextreloc=%lu\n",relocount,nextreloc);
	fclose(labfile);labfile=0;
}
STATIC void WriteLabel1(ULONG adr)
{
static UWORD linecount=200;
	/* Prozentausgabe */
	if (linecount++ >= 200) {
		fprintf(stderr,"Pass 1: %3d%%\r",((adr-prgstart)*100)/prglen);
		fflush(stderr);
		linecount=0;
	}

	if ((fwrite(&adr,4,1,labfile) != 1))
		ExitPrg("Write error !\n");
	labc1++;
}
int P1WriteReloc()
{
	if (RelocAdr[nextreloc] == (prgcount*2 + prgstart)) {
		prgcount=pc+1;
		return(-1);
	}
	else {
		prgcount++;
		return(0);
	}
}
STATIC UWORD NewAdrModes1(UWORD mode, UWORD reg)
/* AdrType :  6 --> Baseregister An */
/*           10 --> PC-relative     */
{
UWORD buf=buffer[prgcount];
UWORD bdsize;
UWORD odsize;
UWORD iis;
UWORD is;
UWORD operand,square1,square2;
LONG  adr;

	if (P1WriteReloc()) return((UWORD)0xffff);

	/* Achtung: Ungerade Offsets werden vom A68K nicht angenommen */
	if (CPUTYPE&(M68000|M68010)) {
		if (buf&0x0700) return(NOADRMODE);
		else {
			if (mode==10) {
				adr = ((prgcount-1)*2+prgstart+(BYTE)buf);
				if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
					return(NOADRMODE);
				InsertLabel(adr);
/*
				LabAdr=adr;
				LabAdrFlag=1;
*/
			}
		}
	}
	else {
		if (buf&0x0100) { /* MC68020 (& up) FULL FORMAT */
			bdsize=(buf&0x0030)>>4;
			odsize=(buf&0x0003);
			iis   =(buf&0x0007);
			is    =(buf&0x0040)>>6;
			operand=square1=square2=0;

			if (mode==10) reg=0;
			if (buf&8)                 return(NOADRMODE);
			if (bdsize==0)             return(NOADRMODE);
			if (is==0 && iis==4)       return(NOADRMODE);
			if (is==1 && iis>=4)       return(NOADRMODE);
/*
			if (is==1 && (buf&0xfe00)) return(NOADRMODE);
			if (buf&0x0080 && reg!=0)  return(NOADRMODE);
*/
			if (bdsize>1)               {operand|=1;square1|=1;}
			if (!(buf&0x0080))          {operand|=2;square1|=2;}
			if (buf&0x0080 && mode==10) {operand|=2;square1|=2;}
			if (is==0 || buf&0xF000) {
				operand|=4;
				if (iis<4) square1|=4;
			}
			if (odsize>1) operand|=8;
			if (iis!=0)   square2=square1;
			else          square1=0;
			operand&=~square1;

			if ((square1|operand)&1) {
				if (bdsize==2) {
					if (mode==10 && !(buf&0x0080)) {
						adr = ((prgcount-1)*2+prgstart+(WORD)buffer[prgcount]);
						if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
							return(NOADRMODE);
						else {
							if (P1WriteReloc()) return((UWORD)0xffff);
							InsertLabel(adr);
						}
					}
					else {
						if (P1WriteReloc()) return((UWORD)0xffff);
					}
				}
				if (bdsize==3) {
					if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
						nextreloc++;
						prgcount+=2;
					}
					else {
						prgcount++;
						if (mode==10 && !(buf&0x0080)) {
							adr = ((prgcount-2)*2+prgstart+(buffer[prgcount-1]<<16)+buffer[prgcount]);
							if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
								return(NOADRMODE);
							if (P1WriteReloc()) return((UWORD)0xffff);
							InsertLabel(adr);
						}
						else {
							if (P1WriteReloc()) return((UWORD)0xffff);
						}
					}
				}
/*
				square1&=~1;
				operand&=~1;
				if (square2 && !square1) {square2=0;}
*/
			}
/*
			if ((square1|operand)&2) {
				square1&=~2;
				operand&=~2;
				if (square2 && !square1) {square2=0;}
			}
			if ((square1|operand)&4) {
				square1&=~4;
				operand&=~4;
				if (square2 && !square1) {square2=0;}
			}
*/
			if (operand&8) {
				if (odsize==2) {
					if (P1WriteReloc()) return((UWORD)0xffff);
				}
				if (odsize==3) {
					if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
						nextreloc++;
						prgcount+=2;
					}
					else {
						prgcount++;
						if (P1WriteReloc()) return((UWORD)0xffff);
					}
				}
			}
		}
		else { /* MC68020 (& up) BRIEF FORMAT */
			if (mode==10) {
				adr = ((prgcount-1)*2+prgstart+(BYTE)buf);
				if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR)))
					return(NOADRMODE);
				InsertLabel(adr);
/*
				LabAdr=adr;
				LabAdrFlag=1;
*/
			}
		}
	}
	return(mode);
}

/* This is for PASS 1 */
STATIC int DoAdress1(UWORD adrs)
{
UWORD mode=adrmode;
UWORD buf=buffer[prgcount];
UWORD reg = reg,creg;
LONG  adr;

	if (mode!=NOADRMODE) {
		/* if (mode>0x30) mode=7+(mode&7); */

		if (adrs&0x2000) reg=reg1;
		else reg=reg2;

		if (adrs&0x8000) adrmode2=mode=adrs&0x00FF;
		else
			if ((adrs&0x0fff)==adrs)
				if (!(adrs&(0x0800>>mode))) adrmode2=mode=NOADRMODE;
	}

	/* Adressierungsart bearbeiten */
	switch (mode) {
		case  1: /* Adressregister direkt */
					/* Auf Adressregister kann nicht byteweise zugegriffen werden    */
					/* Bei LEA ist extens == 0 (weil ungerade Adressen erlaubt sind) */
					if (extens || opcnumber==OPC_LEA) {}
					else mode=NOADRMODE;
					break;
		case  5: /* (d16,An) Adressregister indirekt mit 16Bit-Offset */
					/* Achtung: Ungerade Offsets werden vom A68K nicht angenommen */
/*
					if (extens && buf&1) mode=NOADRMODE;
					else {
*/
						if (P1WriteReloc()) return(-1);
						if (pflags&BASEREG2 && reg==basereg) {
							adr = prgstart+baseadr+(WORD)buf;
							if (adr>(LONG)(moduloffs[basesec]+modultab[basesec]-2) || adr<(LONG)moduloffs[basesec]) {}
							else {
								InsertLabel(adr);
								LabAdr=adr;
								LabAdrFlag=1;
							}
/*						} */
					}
					break;
		case  6: /* Adressreg. ind. mit Adressdistanz und Index */
		case 10: /* D8(PC,Xn) */
					if ((mode=NewAdrModes1(mode,reg))==(UWORD)0xffff) return(-1);
					break;
		case  7: /* Absolute Adresse 16Bit */
					adr = (ULONG)((WORD)buf);
					if (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR || opcnumber==OPC_BITSHIFT1))
						mode=NOADRMODE;
					else {
						if (P1WriteReloc()) return(-1);
						/* PEA  wegen den C-Proggies (Stackuebergabe) */
						if (opcnumber != OPC_PEA) {
							/* Bei Binaerfiles absolute Adr. evtl im Programmbereich */
							if (sourcetype == 1 && prgstart && (adr >= prgstart && adr <= prgende)) {
								InsertLabel(adr);
								LabAdr=adr;
								LabAdrFlag=1;
							}
							else
								InsertXref(adr);
						}
					}
					break;
		case  8: /* Absolute Adresse 32Bit */
					adr = (ULONG)((buf<<16) + buffer[prgcount+1]);
					if (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR || opcnumber==OPC_BITSHIFT1))
						mode=NOADRMODE;
					else {
/* printf(stderr,"RADR=%08x, adr=%08x\n",RelocAdr[nextreloc],(prgcount*2+prgstart)); */
						if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
/* printf("3 RelocAdr[%ld]=$%08X  RelocAdr[%ld]=$%08X\n",nextreloc,nextreloc+1,RelocAdr[nextreloc],RelocAdr[nextreloc+1]); */
							LabAdr=adr;
							LabAdrFlag=1;
							nextreloc++;
						}
						else {
							/* PEA  wegen den C-Proggies (Stackuebergabe) */
							if (opcnumber != OPC_PEA) {
								if (sourcetype == 1 && prgstart && (adr >= prgstart && adr <= prgende)) {
									InsertLabel(adr);
									LabAdr=adr;
									LabAdrFlag=1;
								}
								else
									InsertXref(adr);
							}
						}
						prgcount+=2;
					}
					break;
		case  9: /* PC - Relativ */
					adr = (prgcount*2+prgstart+(WORD)buf);
					if (adr>=(LONG)(moduloffs[modulcnt]+modultab[modulcnt]) || adr<(LONG)(moduloffs[modulcnt]-8) || (adr&1 && (extens || opcnumber==OPC_JMP || opcnumber==OPC_JSR))) mode=NOADRMODE;
					else {
						if (P1WriteReloc()) return(-1);
						InsertLabel(adr);
						LabAdr=adr;
						LabAdrFlag=1;
					}
					break;
		case 11: 
					if (adrs==sourceadr[opcnumber]) {
						if (extens!=3) {
							if (extens==0) {
								if (buf&0xFF00) mode=NOADRMODE;
								else {
									if (P1WriteReloc()) return(-1);
								}
							}
							if (extens==1) {
								if (P1WriteReloc()) return(-1);
							}
							if (extens==2) {
								if (RelocAdr[nextreloc]==(prgcount*2+prgstart+2))
									mode=NOADRMODE;
								else {
									if (RelocAdr[nextreloc]==(prgcount*2+prgstart)) {
/* printf("4 RelocAdr[%ld]=$%08X  RelocAdr[%ld]=$%08X\n",nextreloc,nextreloc+1,RelocAdr[nextreloc],RelocAdr[nextreloc+1]); */
										nextreloc++;
									}
									prgcount += 2;
								}
							}
						}
						else mode=NOADRMODE;
					}
					else if (extens==2) mode=NOADRMODE; /* d=immediate long */
					break;
		case 18: /* DBRA, DB.. */
					adr = (prgcount*2+prgstart+(WORD)buf);
					if (adr>(LONG)(moduloffs[modulcnt]+modultab[modulcnt]-2) || adr<(LONG)moduloffs[modulcnt] || adr&1 || !buf)
						mode=NOADRMODE;
					else {
						if (P1WriteReloc()) return(-1);
						InsertLabel(adr);
						LabAdr=adr;
						LabAdrFlag=1;
					}
					break;
		case 21: /* Bcc */
					if ((sigw&0x00ff)==0x00ff) {
						if (CPUTYPE&M020UP) {
							displace=(buf<<16)|buffer[prgcount+1];
							if (displace!=0 && displace!=2) {
								displace+=prgcount*2;
								if (P1WriteReloc()) return(-1);
								if (P1WriteReloc()) return(-1);
							}
							else mode=NOADRMODE;
						}
						else mode=NOADRMODE;
					} else if ((sigw&0x00ff)==0x0000) {
						if (buf) {
							displace=(prgcount*2+(WORD)(buf));
							if (P1WriteReloc()) return(-1);
						}
						else mode=NOADRMODE;
					} else {
						displace=(prgcount*2+(BYTE)(sigw&0x00ff));	// char!!
					}
					adr = prgstart+displace;
					if (adr>(LONG)(moduloffs[modulcnt]+modultab[modulcnt]-2) || adr<(LONG)moduloffs[modulcnt] || adr&1)
						mode=NOADRMODE;
					else {
						InsertLabel(adr);
						LabAdr=adr;
						LabAdrFlag=1;
					}
					break;
		case 22: /* LINK */
					if (buf&1) mode=NOADRMODE;
					else {
						if (P1WriteReloc()) return(-1);
					}
					break;
		case 24: /* STOP */
					if (P1WriteReloc()) return(-1);
					break;
		case 23: /* BTST,BCLR,... IMMEDIATE&REGISTER,SOURCEOP ONLY */
					if (!extens) destadr[opcnumber]=0x0bfe; /* BTST */
					else destadr[opcnumber]=0x0bf8;         /* sonstige B... */
					if (sigw&0x0100) {}
					else {
						if (P1WriteReloc()) return(-1);
						if (sigw&0x0038) {
							if (buf&0xFFF8) mode=NOADRMODE;
						}
						else {
							if (buf&0xFFE0) mode=NOADRMODE;
						}
					}
					extens=0; /* Set extension to BYTE (undefined before) */
					break;
		case 25: /* BITFIELD */
					reg=(extra&0x07c0)>>6;
					if (extra&0x0800) {
						if (reg>7) mode=NOADRMODE;
					}
					reg=(extra&0x001F);
					if (extra&0x0020) {
						if (reg>7) mode=NOADRMODE;
					}
					if (((sigw&0x0700)>>8)&1) {
						/* BFEXTU, BFEXTS, BFFFO, BFINS */
						if (extra&0x8000) mode=NOADRMODE;
					}
					else {
						if (extra&0xF000) mode=NOADRMODE;
					}
					break;
		case 27: /* CAS2  SOURCE/DESTINATION */
					buf=buffer[prgcount];
					if (P1WriteReloc()) return(-1);
					extens=(sigw&0x0600)>>9;
					if (extens==0 || extens==1) mode=NOADRMODE;
					else extens-=1;
					if (buf&0x0e38 || extra&0x0e38) mode=NOADRMODE;
					break;
		case 28: /* CAS   SOURCE */
					extens=(sigw&0x0600)>>9;
					if (extens==0) mode=NOADRMODE;
					else extens-=1;
					if (extra&0xfe38) mode=NOADRMODE;
					break;
		case 29: /* DIVIDE/MULTIPLY LONG  SIGNED/UNSIGNED */
					if (extra&0x83f8) mode=NOADRMODE;
					else {
						reg=(extra&0x7000)>>12;
						if (reg==(extra&0x0007)) {
							if (opcnumber==OPC_MULL) mode=NOADRMODE;
						}
					}
					break;
		case 30: /* LINK LONG */
					displace=(buf<<16)|buffer[prgcount+1];
					if (displace&1) mode=NOADRMODE;
					else {
						if (P1WriteReloc()) return(-1);
						if (P1WriteReloc()) return(-1);
					}
					break;
		case 31: /* MOVE16 POSTINCREMENT ONLY (DESTINATION) */
					if ((buf&0x8fff)!=0x8000) mode=NOADRMODE;
					else {
						if (P1WriteReloc()) return(-1);
					}
					break;
		case 32: /* CINV & CPUSH */
					destadr[opcnumber]=0x8002;
					switch ((sigw&0x0018)>>3) {
						case 0:
							mode=NOADRMODE;
							break;
						case 3:
							if (sigw&7) mode=NOADRMODE;
							else {
								destadr[opcnumber]=0x0000;
							}
							break;
					}
					break;
		case 33: /* MOVEC */
					if (P1WriteReloc()) return(-1);
					reg =(buf&0x7000)>>12;
					creg=buf&0x0fff;
					if (creg&0x07f8) mode=NOADRMODE;
					else {
						if (creg&0x0800) creg=(creg%8)+9;
						if (CPUTYPE&cregflag[creg]) {}
						else mode=NOADRMODE;
					}
					break;
		case 34: /* MOVES */
					if (extra&0x07ff) mode=NOADRMODE;
					break;
	}
	if (prgcount > CodeAreaEnd) mode=NOADRMODE;
	if (mode==NOADRMODE) {
		prgcount = pc+1;
		return(-1);
	}
	return (0);
}
STATIC int AutoScan(void)
{
FILE  *file;
ULONG  seg;
ULONG  dummy;

	if (!(file = fopen(sourcename,"r")))
		ExitPrg("Can't open %s\n",sourcename);

	/* Header des Sourcefiles pruefen */
	fread(&dummy,4,1,file);
	fclose(file);

	if (dummy == 0x03F3) { /* HUNK_HEADER --> Executablefile */
		if ((seg = LoadSeg(sourcename))) {
			UnLoadSeg(seg);
			if (pflags&SHOW_RELOCINFO) printf("\nExecutable (%s)....:\n",sourcename);
			return (2);
		}
	}
	if (dummy == 0x3E7) { /* HUNK_UNIT --> Objectfile */
		if (pflags&SHOW_RELOCINFO) printf("\nObject (%s)........:\n",sourcename);
		return(3);
	}
	if (pflags&SHOW_RELOCINFO) printf("\nBinary (%s)........:\n",sourcename);
	return (1);
}
STATIC void ReadBinary(void)
{
	pflags |= KEEP_BINARY;

	modulcount = 1; /* Nur 1 Modul */
	memtype    = GetPMem(sizeof(UWORD));
	modultab   = GetPMem(sizeof(ULONG));
	modultype  = GetPMem(sizeof(ULONG));
	moduloffs  = GetPMem(sizeof(ULONG));

	modultab[0]  = FileLength(sourcename);
	moduloffs[0] = prgstart;
	modultype[0] = 0x03E9; /* HUNK_CODE */


   LastModul   = 1;
   FirstModul  = 0;

	strcpy(binname,sourcename);
}
STATIC void ReadObject(void)
{
ULONG hunk,length,i;
ULONG dummy;

	fseek(sourcefile,4,SEEK_SET);
	ReadSymbol(sourcefile,0,0);
	if (pflags&SHOW_RELOCINFO) printf("  Unit    : %s\n",StdName);


	while (fread(&hunk,4,1,sourcefile) == 1) {  /* Modulart (Code,Data,...) */

		if ((hunk>>30) == 3) fread(&length,4,1,sourcefile); /* Aufwaertskompatibel */
		hunk &= 0x0000FFFF;

		switch (hunk) {
			case 0x03E9: /* CODE */
			case 0x03EA: /* DATA */
			case 0x03EB: /* BSS  */
					modulcount++; /* Anzahl der Module +1 */
					fread(&length,4,1,sourcefile); /* Laenge des Moduls */
					node=GetPMem(sizeof(struct Node));
					node->ln_Name = (char *)length;
					ADDTAIL(&list,node);
					if (hunk != 0x03EB)      /* Nur bei Code und Data */
						fseek(sourcefile,length*4,SEEK_CUR); /* Laenge ueberlesen */
				break;
			case 0x03F7: /* HUNK_DREL32  */
			case 0x03F8: /* HUNK_DREL16  */
			case 0x03F9: /* HUNK_DREL8   */
			case 0x03EC: /* HUNK_RELOC32 */
			case 0x03ED: /* HUNK_RELOC16 */
			case 0x03EE: /* HUNK_RELOC8  */
					do {
						/* read number of relocations */
						if ((fread(&length,4,1,sourcefile)) != 1) break;
						if (length) fseek(sourcefile,(length+1)*4,SEEK_CUR);
					} while (length);
				break;
			case 0x03F2: /* HUNK_END   */
				break;
			case 0x03E8: /* HUNK_NAME */
					fread(&length,4,1,sourcefile);
					fseek(sourcefile,length*4,SEEK_CUR);
				break;
			case 0x03F1: /* HUNK_DEBUG */
					fread(&length,4,1,sourcefile);
					fseek(sourcefile,length*4,SEEK_CUR);
				break;
			case 0x03F0: /* HUNK_SYMBOL */
					do {
						if ((fread(&length,4,1,sourcefile)) != 1) break;
						if (length) fseek(sourcefile,(length+1)*4,SEEK_CUR);
					} while (length);
				break;
			case 0x03EF: /* HUNK_EXT */
					do {
						UBYTE type;

						if ((fread(&length,4,1,sourcefile)) != 1) break;
						type = length>>24;
						dummy=length;
						length &= 0x00FFFFFF;
						if (dummy) {
							switch (type) {
								case 0: /* EXT_SYMB */
								case 1: /* EXT_DEF  */
								case 2: /* EXT_ABS  */
								case 3: /* EXT_RES  */
								case 130: /* EXT_COMMON */
									fseek(sourcefile,(length+1)*4,SEEK_CUR);
									if (type==130) {
										fread(&length,4,1,sourcefile);
										fseek(sourcefile,length*4,SEEK_CUR);
									}
									break;
								case 129: /* EXT_REF32  */
								case 131: /* EXT_REF16  */
								case 132: /* EXT_REF8   */
								case 133: /* EXT_DEXT32 */
								case 134: /* EXT_DEXT16 */
								case 135: /* EXT_DEXT8  */
									fseek(sourcefile,length*4,SEEK_CUR);
									fread(&length,4,1,sourcefile);
									fseek(sourcefile,length*4,SEEK_CUR);
									break;
								default:
									ExitPrg("Unknown HUNK_EXT sub-type=%d !\n",type);
									break;
							}
						}
					} while (dummy);
				break;
			default:
					ExitPrg("Hunk...:%08x NOT SUPPORTED.\n",hunk);
				break;

		} /* Ende - Switch() */

	} /* Naechstes Modul einlesen und relocieren. */

	if (pflags&SHOW_RELOCINFO) printf("  Modules : %d\n", (int)modulcount);

	memtype  = GetPMem(modulcount*sizeof(UWORD));
	modultab = GetPMem(modulcount*sizeof(ULONG));
	modultype= GetPMem(modulcount*sizeof(ULONG));
	moduloffs= GetPMem(modulcount*sizeof(ULONG));
	modulstrt= GetPMem(modulcount*sizeof(ULONG *));

	for(i=0;i<modulcount;i++) {
		if (!(node=REMHEAD(&list)))
			ExitPrg("Trouble with exec RemHead !\n");
		modultab[i] = (ULONG)node->ln_Name;
		FreeTaskPooled(node,sizeof(struct Node));
	}

	fseek(sourcefile,4L,SEEK_SET);
	ReadSymbol(sourcefile,0,0);

   LastModul  = modulcount - 1;
   FirstModul = 0;

	ExamineHunks();
}
STATIC void ReadExecutable(void)
{
	ULONG dummy;

	fseek(sourcefile,4L,SEEK_SET);
	/* Librarynamen (wird normal nicht genutzt) ueberlesen */
	while ((dummy=ReadSymbol(sourcefile,0,0)))
		printf("  Library : %s\n",StdName);

	/* Anzahl der Module einlesen */
	fread(&modulcount,4,1,sourcefile);

	if (pflags&SHOW_RELOCINFO) printf("  Modules : %d\n",(int)modulcount);

	/* First und Last einlesen */
	fread(&FirstModul,4,1,sourcefile);
	fread(&LastModul,4,1,sourcefile);

	if (FirstModul) ExitPrg("Can't handle firstmodul != 0 !!\n");

	memtype  = GetPMem(modulcount*sizeof(UWORD));
	modultab = GetPMem(modulcount*sizeof(ULONG));
	modultype= GetPMem(modulcount*sizeof(ULONG));
	moduloffs= GetPMem(modulcount*sizeof(ULONG));
	modulstrt= GetPMem(modulcount*sizeof(ULONG *));

	/* Modultabelle (Modullaengen) einlesen */
	fread(modultab,4,(LastModul-FirstModul+1),sourcefile);

	ExamineHunks();

}
