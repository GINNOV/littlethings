/* A quick program to read in an AmiPhone voice file and output
   an 8-bit raw sound file */

#include <stdio.h>
#include <stdlib.h>
#include <exec/types.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <libraries/dos.h>
#include <intuition/intuition.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <string.h>
#include <time.h>

#include "codec.h"
#include "amiphonepacket.h"

#define UNLESS(x) if(!(x))

#define MAGIC_WORD "APHN"

char szInFile[300];
char szOutFile[300];

static BOOL IsAmiPhoneFile(FILE * fpIn);
static BOOL LoadBuffer(FILE * fpIn, struct AmiPhoneSendBuffer * pIn, struct AmiPhoneSendBuffer * pOut, FILE * fpOut);
static void ConvertPhoneToRaw(FILE * fpIn, FILE * fpOut);

static UBYTE ver[] = "$VER: PhoneUtil1.0";

int main(int argc, char **argv)
{	
	FILE * fpIn, * fpOut;

	/* If '?' force format prompt & quit */
	if ((argc==2)&&(*argv[1] == '?')) argc=1;
	
	if ((argc != 2)&&(argc != 3))
	{
		printf("format: PhoneUtil <inputfile> [outputfile]\n");
		exit(5);
	}
	
	strncpy(szInFile,argv[1],sizeof(szInFile));
	if (argc == 3) strncpy(szOutFile,argv[2],sizeof(szOutFile));
 	else
 	{
 		strncpy(szOutFile,argv[1],sizeof(szOutFile));
 		strncat(szOutFile, ".raw",sizeof(szOutFile));
 	}

	UNLESS(fpIn = fopen(szInFile,"rb"))
	{
		printf("Couldn't open input file [%s]\n",szInFile);
		exit(5);
	}
	UNLESS(fpOut = fopen(szOutFile,"wb"))
	{
		printf("Couldn't open output file [%s]\n",szOutFile);
		fclose(fpIn);
		exit(5);
	}
	 	
 	if (IsAmiPhoneFile(fpIn)) 
 	{
 		printf("Converting [%s] (AmiPhone format) to [%s] (raw sound file)\n", szInFile, szOutFile);
		ConvertPhoneToRaw(fpIn, fpOut); 		
 	}
 	else 
 	{
 		printf("raw->AmiPhone isn't supported yet!\n");
 	}
 	
 	fclose(fpIn);
 	fclose(fpOut);
}


static BOOL IsAmiPhoneFile(FILE * fpIn)
{	
	BOOL BResult;
	char szBuf[5];
	
	fread(szBuf,4,1,fpIn);
	BResult = (strncmp(szBuf,MAGIC_WORD,4) == 0);
	return(BResult);
}


static void ConvertPhoneToRaw(FILE * fpIn, FILE * fpOut)
{
	struct AmiPhoneSendBuffer * pInBuf, * pOutBuf;

	UNLESS(pInBuf = AllocMem(sizeof(struct AmiPhoneSendBuffer), MEMF_ANY))
	{
		printf("Couldn't allocate conversion input buffer!\n");
		return;
	}
	UNLESS(pOutBuf = AllocMem(sizeof(struct AmiPhoneSendBuffer), MEMF_ANY))
	{
		printf("Couldn't allocate conversion output buffer!\n");
		FreeMem(pInBuf,sizeof(struct AmiPhoneSendBuffer));
		return;
	}
	
	while(LoadBuffer(fpIn, pInBuf, pOutBuf, fpOut)) {}	
	
	FreeMem(pInBuf, sizeof(struct AmiPhoneSendBuffer));
	FreeMem(pOutBuf, sizeof(struct AmiPhoneSendBuffer));
}


static BOOL LoadBuffer(FILE * fpIn, struct AmiPhoneSendBuffer * pIn, struct AmiPhoneSendBuffer * pOut, FILE * fpOut)
{
	int nTemp;
	static long lLast = 9999999L;
	
	/* load in packet header to get data size */
	nTemp = fread(&pIn->header,1,sizeof(struct AmiPhonePacketHeader),fpIn);
	if (nTemp < sizeof(struct AmiPhonePacketHeader)) return(FALSE);
	
	/* do some sanity checking on our header */
	if (pIn->header.ubCommand != PHONECOMMAND_DATA)
	{
		printf("LoadBuffer:  chunk wasn't data! [%i]\n",pIn->header.ubCommand);
		return(FALSE);
	}
	if ((pIn->header.ubType < COMPRESS_NONE)||(pIn->header.ubType >= COMPRESS_MAX))
	{
		printf("LoadBuffer:  Bad compression method! [%i]\n",pIn->header.ubType);
		return(FALSE);
	}	
	if ((pIn->header.ulBPS < MIN_SAMPLE_RATE)||(pIn->header.ulBPS > ABSOLUTE_MAX_SAMPLE_RATE))
	{
		printf("LoadBuffer:  Bad sampling rate! [%u]\n",pIn->header.ulBPS);
		return(FALSE);
	}

	/* load in data to data section of our load buffer */
	nTemp = fread(pIn->ubData, 1, pIn->header.ulDataLen, fpIn);	
	if (nTemp < pIn->header.ulDataLen) 
	{
		printf("LoadBuffer: Couldn't read packet data.\n");
		return(FALSE);
	}

	fwrite(pOut->ubData, 1, DecompressData(pIn->ubData, 
		pOut->ubData, pIn->header.ubType, pIn->header.ulDataLen, 
		pIn->header.ulJoinCode), fpOut);
	lLast = pIn->header.lSeqNum;	
	return(TRUE);
}