/*--------------------------------------------------------------*/ 
/*								*/ 
/*			bmprintc.c				*/ 
/*								*/ 
/* print out a C-language representation of data for bitmap	*/ 
/*								*/  
/* By Jerry Morrison and Steve Shaw, Electronic Arts.		*/ 
/* This software is in the public domain.			*/ 
/*								*/ 
/* This version for the Commodore-Amiga computer.		*/ 
/* Cleaned up and modified a bit by Chuck McManis, Aug 1988	*/ 
/* Modified 05/91 by CBM for use with iffparse modules          */
/*								*/ 
/*--------------------------------------------------------------*/ 
 
#include "iffp/ilbmapp.h"
#include <stdio.h> 
 
#define NO  0 
#define YES 1 

void PSprite(struct BitMap *bm, FILE *fp, UBYTE *name, int p, BOOL dohead);
void PrCRLF(FILE *fp);
void PrintBob(struct BitMap *bm, FILE *fp, UBYTE *name);
void PrintSprite(struct BitMap *bm, FILE *fp, UBYTE *name,
		 BOOL attach, BOOL dohdr);

static BOOL doCRLF; 
char sp_colors[] = ".oO@";

void PrCRLF(FILE *fp)  
{ 
	if (doCRLF)  
		fprintf(fp, "%c%c", 0xD, 0xA);  
	else 
		fprintf(fp, "\n"); 
} 
     
void PrintBob(struct BitMap *bm, FILE *fp, UBYTE *name)  
{ 
	register UWORD 	*wp;	/* Pointer to the bitmap data */ 
 
	short 	p,i,j,nb;	/* temporaries */ 
	short 	nwords = (bm->BytesPerRow/2)*bm->Rows; 
	 
	fprintf(fp, "/*----- bitmap : w = %ld, h = %ld ------ */", 
		    bm->BytesPerRow*8, bm->Rows); 
 
	PrCRLF(fp); 
	 
	for (p = 0; p < bm->Depth; ++p) {	/* For each bit plane */ 
		wp = (UWORD *)bm->Planes[p]; 
		fprintf(fp, "/*------ plane # %ld: --------*/", p); 
		PrCRLF(fp); 
		fprintf(fp, "UWORD %s%c[%ld] = { ", name, (p?('0'+p):' '), nwords); 
		PrCRLF(fp); 
		for (j = 0; j < bm->Rows; j++, wp += (bm->BytesPerRow >> 1)) {  
			fprintf(fp, "	"); 
			for (nb = 0; nb < (bm->BytesPerRow) >> 1; nb++) 
				fprintf(fp, "0x%04x,", *(wp+nb)); 
			if (bm->BytesPerRow <= 6) { 
 				fprintf(fp, "\t/* "); 
				for (nb = 0; nb < (bm->BytesPerRow) >> 1; nb++) 
					for (i=0 ; i<16; i++) 
						fprintf(fp, "%c", 
					    (((*(wp+nb)>>(15-i))&1) ? '*' : '.')); 
				fprintf(fp, " */"); 
			} 
			PrCRLF(fp); 
		 
		} 
		fprintf(fp,"	};"); 
		PrCRLF(fp); 
	} 
} 



void PSprite(struct BitMap *bm, FILE *fp, UBYTE *name, int p, BOOL dohead)  
{ 
	UWORD 	*wp0, *wp1;	/* Pointer temporaries 	*/ 
	short 	i, j, nwords,	/* Counter temporaries 	*/ 
		color;		/* pixel color		*/ 
	short 	wplen = bm->BytesPerRow/2; 
 
	nwords =  2*bm->Rows + (dohead?4:0); 
	wp0 = (UWORD *)bm->Planes[p]; 
	wp1 = (UWORD *)bm->Planes[p+1]; 
 
	fprintf(fp, "UWORD %s[%ld] = {", name, nwords); 
	PrCRLF(fp); 
 
	if (dohead) { 
		fprintf(fp,"  0x0000, 0x0000, /* VStart, VStop */"); 
		PrCRLF(fp); 
	} 
	for (j=0 ; j < bm->Rows; j++) { 
		fprintf(fp, "  0x%04x, 0x%04x", *wp0, *wp1); 
		if (dohead || (j != bm->Rows-1)) { 
			fprintf(fp, ","); 
		} 
		fprintf(fp, "\t/*  "); 
		for (i = 0; i < 16; i++) { 
			color = ((*wp1 >> (14-i)) & 2) + ((*wp0 >> (15-i)) & 1); 
			fprintf(fp, "%c", sp_colors[color]); 
		} 
		fprintf(fp,"  */"); 
		PrCRLF(fp); 
		wp0 += wplen; 
		wp1 += wplen; 
	} 
	if (dohead)  
		fprintf(fp, "  0x0000, 0x0000 }; /* End of Sprite */"); 
	else  
		fprintf(fp," };");	 
	PrCRLF(fp); 
	PrCRLF(fp); 
} 
 
void PrintSprite(struct BitMap *bm, FILE *fp, UBYTE *name,
		 BOOL attach, BOOL dohdr)
{ 
	fprintf(fp,"/*----- Sprite format: h = %ld ------ */", bm->Rows); 
	PrCRLF(fp); 
 
	if (bm->Depth > 1) { 
		fprintf(fp, "/*--Sprite containing lower order two planes:   */"); 
		PrCRLF(fp); 
		PSprite(bm, fp, name, 0, dohdr); 
	} 
	if (attach && (bm->Depth > 3) ) { 
		strcat(name, "1"); 
		fprintf(fp, "/*--Sprite containing higher order two planes:   */"); 
		PrCRLF(fp); 
		PSprite(bm, fp, name, 2, dohdr); 
	}  
} 
 
#define BOB 	0 
#define SPRITE 	1 

/* BMPrintCRep
 * Passed pointer to BitMap structure, C filehandle opened for write,
 * name associated with file, and string describing the output
 * format desired (see cases below), outputs C representation of the ILBM.
 */
void BMPrintCRep(struct BitMap *bm, FILE *fp, UBYTE *name, UBYTE *fmt)  
{ 
	BOOL attach, doHdr; 
	char c; 
	SHORT type; 
 
	doCRLF = NO; 
	doHdr = YES; 
	type = BOB; 
	attach = NO; 
	while ( (c=*fmt++) != 0 )  
		switch (c) { 
			case 'b':  
				type = BOB;  
				break; 
			case 's':  
				type = SPRITE; 
				attach = NO;  
				break; 
			case 'a':  
				type = SPRITE;  
				attach = YES;  
				break; 
			case 'n':  
				doHdr = NO;  
				break; 
			case 'c':  
				doCRLF = YES;  
				break; 
		} 
	switch(type) { 
		case BOB:  
			PrintBob(bm, fp, name);  
			break; 
		case SPRITE:   
			PrintSprite(bm, fp, name, attach, doHdr); 
			break; 
	} 
}

