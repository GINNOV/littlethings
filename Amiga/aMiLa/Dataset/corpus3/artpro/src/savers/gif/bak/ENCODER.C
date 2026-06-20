/*
	encoder.c - GIF Encoder and associated routines
	This module is linked as an overlay, use ENTER_OVLY and EXIT_OVLY.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifndef XFRACT
#include <io.h>
#endif
#include "fractint.h"
#include "fractype.h"
#include "prototyp.h"

/* MCP 10-27-91 */
#ifdef WINFRACT
   extern int OperCancelled;
   void OpenStatusBox(void);
   void UpdateStatusBox(unsigned long Partial, unsigned long Total);
   void CloseStatusBox(void);
#endif

extern char s_cantopen[];
extern char s_cantwrite[];
extern char s_cantcreate[];
extern char s_cantunderstand[];
extern char s_cantfind[];
extern char maxfn;
static void _fastcall setup_save_info(struct fractal_info *);
static int inittable(void);
static int _fastcall shftwrite(BYTE *color,int numcolors);
static int _fastcall raster(unsigned int);
static int  _fastcall extend_blk_len(int datalen);
static int _fastcall put_extend_blk(int block_id,int block_len,char far *block_data);
static int  _fastcall store_item_name(char *);

extern int initbatch;
extern char far *resume_info;		/* pointer to resume info if allocated */
extern int  resume_len; 		/* length of resume info */
extern char LName[];
extern char FormName[]; 		/* formula name */
extern char IFSName[];
extern int  active_system;		/* 0=dos, 1=windows */
extern int  far *ranges;
extern int  rangeslen;

extern	int	sxdots,sydots;		/* # of dots on the physical screen    */
extern	int	sxoffs,syoffs;		/* physical top left of logical screen */
extern	int	xdots, ydots;		/* # of dots on the logical screen     */
extern	int	viewwindow;		/* 0 for full screen, 1 for window */
extern	float	finalaspectratio;	/* for view shape and rotation */
extern	int	viewxdots,viewydots;	/* explicit view sizing */
extern	int	colors; 		/* maximum colors available */
extern	int	dotmode;		/* so we can detect disk-video */
extern	char overwrite; 		/* overwrite on/off */
extern	int	resave_flag;		/* resaving after a timed save */
extern	int	started_resaves;
extern	int	timedsave;		/* if doing an auto save */
extern	int	disk16bit;		/* 16 bit continuous potential */

extern BYTE dacbox[256][3];	/* Video-DAC (filled in by SETVIDEO) */
extern	int	gotrealdac;		/* DAC valid? */
extern int	daclearn, daccount;	/* used by the color-cyclers */
extern SEGTYPE	extraseg;		/* used by Save-to-GIF routines */
extern int	debugflag;

extern int	gif87a_flag;		/* if 1, supress GIF extension blocks */

extern int    calc_status;
extern long   calctime;
extern char   stdcalcmode;
extern int    fractype;
extern double xxmin,xxmax;
extern double yymin,yymax;
extern double xx3rd,yy3rd;
extern double param[];
extern int    major_method;		/* inverse julia parms */
extern int    minor_method;
extern int    maxit;			/* try this many iterations */
extern int    fillcolor;		/* fill color: -1 = normal  */
extern int    inside;			/* inside color: 1=blue     */
extern int    outside;			/* outside color, if set    */
extern int    finattract;		/* finite attractor option  */
extern int    forcesymmetry;
extern int    LogFlag;			/* non-zero if logarithmic palettes */
extern int    rflag, rseed;
extern int    periodicitycheck;
extern char   useinitorbit;
extern _CMPLX initorbit;
extern int    pot16bit;
extern float  finalaspectratio;
extern double potparam[3];		/* three potential parameters*/
extern double inversion[];
extern int    decomp[];
extern int    distest;			/* non-zero if distance estimator   */
extern int    distestwidth;
extern int    init3d[20];		/* '3d=nn/nn/nn/...' values */
extern char   floatflag;		/* floating-point fractals? */
extern int    usr_biomorph;
extern int    bailout;			/* user input bailout value */
extern int    previewfactor;
extern int    xtrans;
extern int    ytrans;
extern int    red_crop_left;
extern int    red_crop_right;
extern int    blue_crop_left;
extern int    blue_crop_right;
extern int    red_bright;
extern int    blue_bright;
extern int    xadjust;
extern int    eyeseparation;
extern int    glassestype;
extern int    save_system;
extern int    save_release;
extern int    display3d;		/* 3D display flag: 0 = OFF */
extern int    Ambient;
extern int    RANDOMIZE;
extern int    haze;
extern int    transparent[2];
extern int    rotate_lo,rotate_hi;
extern char   busy;
extern float  screenaspect;
extern     double mxmaxfp;
extern     double mxminfp;
extern     double mymaxfp;
extern     double myminfp;
extern     int zdots;		
extern     float originfp;
extern     float depthfp;	
extern     float heightfp;
extern     float widthfp;	
extern     float distfp;	
extern     float eyesfp;	
extern     int neworbittype;
extern     short juli3Dmode;
	
#ifdef XFRACT
extern int decode_fractal_info();
#endif

/*
			Save-To-Disk Routines (GIF)

GIF and 'Graphics Interchange Format' are trademarks (tm) of Compuserve
Incorporated, an H&R Block Company.


The following routines perform the GIF encoding when the 's' key is pressed.
The routines refer to several variables that are declared elsewhere
[colors, xdots, ydots, and 'dacbox'], and rely on external routines to
actually read and write screen pixels [getcolor(x,y) and putcolor(x,y,color)].
(Writing pixels is just stuffed in here as a sort of visual status report,
and has nothing to do with any GIF function.)	They also rely on the
existence of an externally-defined 64K dataspace and they use the routines
'toextra()' and 'cmpextra()' to deal with that dataspace (in the same manner
as 'memcpy()' and 'memcmp()' would).   Otherwise, they perform a generic
GIF-encoder function.

Note that these routines use small string- and hash-tables, and "flush"
the GIF entries whenever the hash-table gets two-thirds full or the string
table gets full.   They also use the GIF encoding technique of limiting the
encoded string length to a specific size, "adding" a string to the hash table
at that point even if a matching string exists ("adding" is in quotes, because
if a matching string exists we can increment the code counter but safely throw
the duplicate string away, saving both string space and a hash table entry).

   This results in relatively good speed and small data space, but at the
expense of compression efficiency (filesize).	These trade-offs could be
adjusted by modifying the #DEFINEd variables below.

Note that the 'strlocn' and 'teststring' routines are declared
to be external just so that they can be defined (and the space re-used)
elsewhere.  The actual declarations are in the assembler code.

*/

#define MAXTEST   100		/* maximum single string length */
#define MAXSTRING 64000 	/* total space reserved for strings */
				/* maximum number of strings available */
#define MAXENTRY  5003		/* (a prime number is best for hashing) */

#ifndef XFRACT
extern unsigned int strlocn[MAXENTRY];
extern BYTE teststring[MAXTEST];
extern BYTE block[266];   /* GIF-encoded blocks go here */
#else
unsigned int strlocn[10240];
BYTE teststring[MAXTEST];
BYTE block[266];   /* GIF-encoded blocks go here */
#endif

static int numsaves = 0;	/* For adjusting 'save-to-disk' filenames */

static FILE *out;
static int last_colorbar;
static int save16bit;
static int outcolor1s, outcolor2s;

static int lentest, lastentry, numentries, numrealentries;
static unsigned int nextentry;
static int clearcode, endcode;
static unsigned int hashcode;

static BYTE blockcount;
static int startbits, codebits, bytecount, bitcount;

static char paletteBW[] = {			/* B&W palette */
	  0,  0,  0, 63, 63, 63,
	};
static char paletteCGA[] = {			/* 4-color (CGA) palette  */
	  0,  0,  0, 21, 63, 63, 63, 21, 63, 63, 63, 63,
	};
static char paletteEGA[] = {			/* 16-color (EGA/CGA) pal */
	  0,  0,  0,  0,  0, 42,  0, 42,  0,  0, 42, 42,
	 42,  0,  0, 42,  0, 42, 42, 21,  0, 42, 42, 42,
	 21, 21, 21, 21, 21, 63, 21, 63, 21, 21, 63, 63,
	 63, 21, 21, 63, 21, 63, 63, 63, 21, 63, 63, 63,
	};

void encoder_overlay() { }	/* for restore_active_ovly */

int savetodisk(filename)	/* save-to-disk routine */
   char *filename;
   {
   char tmpmsg[41]; /* before openfile in case of overrun */
   char openfile[80], openfiletype[10];
   char tmpfile[80];
   int newfile;
   int i, j, outcolor1, outcolor2, interrupted;

   ENTER_OVLY(OVLY_ENCODER);

restart:

   save16bit = disk16bit;
   if (gif87a_flag) /* not storing non-standard fractal info */
      save16bit = 0;

   strcpy(openfile,filename);		/* decode and open the filename */
   strcpy(openfiletype,DEFAULTFRACTALTYPE);/* determine the file extension */
   if (save16bit)
      strcpy(openfiletype,".pot");
   for (i = 0; i < strlen(openfile); i++)
      if (openfile[i] == '.') {
         strcpy(openfiletype,&openfile[i]);
         openfile[i] = 0;
         }
   if (resave_flag != 1)
      updatesavename(filename); /* for next time */

   strcat(openfile,openfiletype);

   strcpy(tmpfile,openfile);
   if (access(openfile,0) != 0) /* file doesn't exist */
      newfile = 1;
   else { /* file already exists */
      if (overwrite == 0) {
         if (resave_flag == 0)
            goto restart;
         if (started_resaves == 0) { /* first save of a savetime set */
            updatesavename(filename);
            goto restart;
            }
         }
      if (access(openfile,2) != 0) {
         sprintf(tmpmsg,s_cantwrite,openfile);
         stopmsg(0,tmpmsg);
         EXIT_OVLY;
         return -1;
         }
      newfile = 0;
      i = strlen(tmpfile);
      while (--i >= 0 && tmpfile[i] != SLASHC)
         tmpfile[i] = 0;
      strcat(tmpfile,"fractint.tmp");
      }

   started_resaves = (resave_flag == 1) ? 1 : 0;
   if (resave_flag == 2) /* final save of savetime set? */
      resave_flag = 0;

   if ((out=fopen(tmpfile,"wb")) == NULL) {
      sprintf(tmpmsg,s_cantcreate,tmpfile);
      stopmsg(0,tmpmsg);
      EXIT_OVLY;
      return -1;
      }

   if (dotmode == 11) {			/* disk-video */
      char buf[60];
      sprintf(buf,"Saving %s",openfile);
      dvid_status(1,buf);
      }
#ifdef XFRACT
      else {
      putstring(3,0,0,"Saving to:");
      putstring(4,0,0,openfile);
      putstring(5,0,0,"               ");
      }
#endif

   busy = 1;

   if (debugflag != 200)
      interrupted = encoder();
   else
      interrupted = timer(2,NULL);	/* invoke encoder() via timer */

   busy = 0;

   fclose(out);

   if (interrupted) {
      char buf[200];
      sprintf(buf,"Save of %s interrupted.\nCancel to ",openfile);
      if (newfile)
         strcat(buf,"delete the file,\ncontinue to keep the partial image.");
      else
         strcat(buf,"retain the original file,\ncontinue to replace original with new partial image.");
      interrupted = 1;
      if (stopmsg(2,buf) < 0) {
         interrupted = -1;
         unlink(tmpfile);
         }
      }

   if (newfile == 0 && interrupted >= 0) { /* replace the real file */
      unlink(openfile);		/* success assumed since we checked */
      rename(tmpfile,openfile);	/* earlier with access		    */
      }

   if (dotmode != 11) {			/* supress this on disk-video */
      if (active_system == 0) {		/* no bars in Windows version */
         outcolor1 = outcolor1s;
         outcolor2 = outcolor2s;
         for (j = 0; j <= last_colorbar; j++) {
            if ((j & 4) == 0) {
               if (++outcolor1 >= colors) outcolor1 = 0;
               if (++outcolor2 >= colors) outcolor2 = 0;
               }
            for (i = 0; 250*i < xdots; i++) { /* clear vert status bars */
               putcolor(i,j,getcolor(i,j)^outcolor1);
               putcolor(xdots-1-i,j,getcolor(xdots-1-i,j)^outcolor2);
               }
            }
         }
#ifdef XFRACT
         putstring(5,0,0,"Saving done\n");
#endif
      }
   else					/* disk-video */
      dvid_status(1,"");

   if (interrupted) {
      texttempmsg(" *interrupted* save ");
      if (initbatch == 2 || initbatch == 5) initbatch = 3; /* if batch mode, set error level */
      EXIT_OVLY;
      return -1;
      }
   if (timedsave == 0) {
      buzzer(0);
      if (initbatch == 0) {
         sprintf(tmpmsg," File saved as %s ",openfile);
         texttempmsg(tmpmsg);
         }
      }
   EXIT_OVLY;
   return 0;
   }


int encoder()
{
int i, ydot, xdot, color, outcolor1, outcolor2;
int width;
int rownum, rowlimit;
unsigned int hashentry;
BYTE bitsperpixel, x;
int entrynum;
struct fractal_info save_info;

if(initbatch)			/* flush any impending keystrokes */
   while(keypressed())
      getakey();

setup_save_info(&save_info);

#ifndef XFRACT
bitsperpixel = 0;			/* calculate bits / pixel */
for (i = colors; i >= 2; i /= 2 )
	bitsperpixel++;

startbits = bitsperpixel+1;		/* start coding with this many bits */
if (colors == 2)
	startbits++;			/* B&W Klooge */
#else
    if (colors==2) {
        bitsperpixel = 1;
        startbits = 3;
    } else {
        bitsperpixel = 8;
        startbits = 9;
    }
#endif

clearcode = 1 << (startbits - 1);	/* set clear and end codes */
endcode = clearcode+1;

outcolor1 = 0;				/* use these colors to show progress */
outcolor2 = 1;				/* (this has nothing to do with GIF) */
if (colors > 2) {
	outcolor1 = 2;
	outcolor2 = 3;
	}
if (((++numsaves) & 1) == 0) {		    /* reverse the colors on alt saves */
	i = outcolor1;
	outcolor1 = outcolor2;
	outcolor2 = i;
	}
outcolor1s = outcolor1;
outcolor2s = outcolor2;

if (gif87a_flag == 1) {
	if (fwrite("GIF87a",6,1,out) != 1) goto oops;  /* old GIF Signature */
} else {
	if (fwrite("GIF89a",6,1,out) != 1) goto oops;  /* new GIF Signature */
}

width = xdots;
rowlimit = ydots;
if (save16bit) {
	/* pot16bit info is stored as:
	   file:    double width rows, right side of row is low 8 bits
	   diskvid: ydots rows of colors followed by ydots rows of low 8 bits
	   decoder: returns (row of color info then row of low 8 bits) * ydots
	   */
	rowlimit <<= 1;
	width <<= 1;
	}
if (write2(&width,2,1,out) != 1) goto oops;  /* screen descriptor */
if (write2(&ydots,2,1,out) != 1) goto oops;
x = 128 + ((6-1)<<4) + (bitsperpixel-1); /* color resolution == 6 bits worth */
if (write1(&x,1,1,out) != 1) goto oops;
if (fputc(0,out) != 0) goto oops;	/* background color */
i = 0;
/** PB, changed to always store pixel aspect ratio, some utilities
	have been reported to like it **/
/**
if ( finalaspectratio < screenaspect-0.01
  || finalaspectratio > screenaspect+0.01) {
 **/
if (viewwindow				    /* less than full screen?  */
  && (viewxdots == 0 || viewydots == 0))    /* and we picked the dots? */
   i = ((double)sydots / (double)sxdots) * 64.0/screenaspect - 14.5;
else /* must risk loss of precision if numbers low */
   i = (((double)ydots / (double)xdots) / finalaspectratio) * 64 - 14.5;
if (i < 1)   i = 1;
if (i > 255) i = 255;
if (gif87a_flag) i = 0;    /* for some decoders which can't handle aspect */
if (fputc(i,out) != i) goto oops;	/* pixel aspect ratio */

#ifndef XFRACT
if (colors == 256) {			/* write out the 256-color palette */
	if (gotrealdac) { 		/* got a DAC - must be a VGA */
		if (!shftwrite((BYTE *)dacbox,colors)) goto oops;
#else
if (colors > 2) {
        if (gotrealdac) {               /* got a DAC - must be a VGA */
                if (!shftwrite((BYTE *)dacbox,256)) goto oops;
#endif
	 } else {			/* uh oh - better fake it */
		for (i = 0; i < 256; i += 16)
			if (!shftwrite((BYTE *)paletteEGA,16)) goto oops;
		}
	}
if (colors == 2) {			/* write out the B&W palette */
	if (!shftwrite((BYTE *)paletteBW,colors)) goto oops;
	}
#ifndef XFRACT
if (colors == 4) {			/* write out the CGA palette */
	if (!shftwrite(paletteCGA,colors))goto oops;
	}
if (colors == 16) {			/* Either EGA or VGA */
	if (gotrealdac) {
		if (!shftwrite((BYTE *)dacbox,colors))goto oops;
		}
	 else	{			/* no DAC - must be an EGA */
		if (!shftwrite(paletteEGA,colors))goto oops;
		}
	}
#endif

if (fwrite(",",1,1,out) != 1) goto oops;  /* Image Descriptor */
i = 0;
if (write2(&i,2,1,out) != 1) goto oops;
if (write2(&i,2,1,out) != 1) goto oops;
if (write2(&width,2,1,out) != 1) goto oops;
if (write2(&ydots,2,1,out) != 1) goto oops;
if (write1(&i,1,1,out) != 1) goto oops;

bitsperpixel = startbits - 1;		/* raster data starts here */
if (write1(&bitsperpixel,1,1,out) != 1) goto oops;

codebits = startbits;			/* start encoding */

if (!raster(9999)) goto oops;		/* initialize the raster routine */

if (!inittable()) goto oops;		/* initialize the LZW tables */

for ( rownum = 0; rownum < ydots; rownum++
#ifdef WINFRACT
      , UpdateStatusBox(rownum, ydots)
#endif
) {  /* scan through the dots */
    for (ydot = rownum; ydot < rowlimit; ydot += ydots) {
	for (xdot = 0; xdot < xdots; xdot++) {
		if (save16bit == 0 || ydot < ydots)
			color = getcolor(xdot,ydot);
		else
			color = readdisk(xdot+sxoffs,ydot+syoffs);
		teststring[0] = ++lentest;
		teststring[lentest] = color;
		if (lentest == 1) {		/* root entry? */
			lastentry = color;
			continue;
			}
		if (lentest == 2)		/* init   the hash code */
			hashcode = 301 * (teststring[1]+1);
		hashcode *= (color + lentest);	/* update the hash code */
		hashentry = ++hashcode % MAXENTRY;
		for( i = 0; i < MAXENTRY; i++) {
			if (++hashentry >= MAXENTRY) hashentry = 0;
			if (cmpextra(strlocn[hashentry]+sizeof(int),
				(char *)teststring,lentest+1) == 0)
					break;
			if (strlocn[hashentry] == 0) i = MAXENTRY;
			}
		/* found an entry and string length isn't too bad */
		if (strlocn[hashentry] != 0 && lentest < MAXTEST-1-sizeof(int)) {
			fromextra(strlocn[hashentry],(char *)&entrynum,sizeof(int));
			lastentry = entrynum;
			continue;
			}
		if (!raster(lastentry)) goto oops;	/* write entry */
		numentries++;		/* act like you added one, anyway */
		if (strlocn[hashentry] == 0) {	/* add new string, if any */
			entrynum = numentries+endcode;
			strlocn[hashentry] = nextentry;
			toextra(nextentry, (char *)&entrynum,sizeof(int));
			toextra(nextentry+sizeof(int),
				(char *)teststring,lentest+1);
			nextentry += lentest+1+sizeof(int);
			numrealentries++;
			}
		teststring[0] = 1;		/* reset current entry */
		teststring[1] = color;
		lentest = 1;
		lastentry = color;

		if ((numentries+endcode) == (1<<codebits))
			codebits++;		 /* use longer encoding */

		if ( numentries + endcode > 4093 ||	/* out of room? */
			numrealentries > (MAXENTRY*2)/3 ||
			nextentry > MAXSTRING-MAXTEST-1-2*sizeof(int)) {
			if (!raster(lastentry)) goto oops;	/* flush & restart */
			if (!inittable()) goto oops;
			}
		}
	if (dotmode != 11			/* supress this on disk-video */
	    && active_system == 0		/* and in Windows version     */
	    && ydot == rownum) {
		if ((ydot & 4) == 0) {
			if (++outcolor1 >= colors) outcolor1 = 0;
			if (++outcolor2 >= colors) outcolor2 = 0;
			}
		for (i = 0; 250*i < xdots; i++) {	/* display vert status bars */
							/*   (this is NOT GIF-related)	*/
			/* PB Changed following code to xor color, so that
			   image can be restored at end and resumed
			   putcolor(	  i,ydot,outcolor1);
			   putcolor(xdots-1-i,ydot,outcolor2);
			*/
			putcolor(i,ydot,getcolor(i,ydot)^outcolor1);
			putcolor(xdots-1-i,ydot,getcolor(xdots-1-i,ydot)^outcolor2);
			}
		last_colorbar = ydot;
		}
#ifdef WINFRACT
        keypressed();
        if (OperCancelled)
#else
        if (keypressed())                     /* keyboard hit - bail out */
#endif
		ydot = rownum = 9999;
	}
    }

if (!raster(lastentry)) goto oops;	/* tidy up - dump the last code */

if (!raster(endcode)) goto oops;	/* finish the map */

if (fputc(0,out) != 0) goto oops;	/* raster data ends here */

if (gif87a_flag == 0) { /* store non-standard fractal info */
	/* loadfile.c has notes about extension block structure */
	if (ydot >= 9999)
		save_info.calc_status = 0; /* partial save is not resumable */
	save_info.tot_extend_len = 0;
	if (resume_info != NULL && save_info.calc_status == 2) {
		/* resume info block, 002 */
		save_info.tot_extend_len += extend_blk_len(resume_len);
		if (!put_extend_blk(2,resume_len,resume_info))goto oops;
		}
	if (save_info.fractal_type == FORMULA || save_info.fractal_type == FFORMULA)
		save_info.tot_extend_len += store_item_name(FormName);
	if (save_info.fractal_type == LSYSTEM)
		save_info.tot_extend_len += store_item_name(LName);
	if (save_info.fractal_type == IFS || save_info.fractal_type == IFS3D)
		save_info.tot_extend_len += store_item_name(IFSName);
	if (display3d <= 0 && rangeslen) {
		/* ranges block, 004 */
		save_info.tot_extend_len += extend_blk_len(rangeslen*2);
#ifdef XFRACT
		fix_ranges(ranges,rangeslen,0);
		put_extend_blk(4,rangeslen*2,(char far *)ranges);
		fix_ranges(ranges,rangeslen,0);
#else
		if (!put_extend_blk(4,rangeslen*2,(char far *)ranges))
			goto oops;
#endif
		}

	/* main and last block, 001 */
	save_info.tot_extend_len += extend_blk_len(FRACTAL_INFO_SIZE);
#ifdef XFRACT
        decode_fractal_info(&save_info,0);
#endif
	if (!put_extend_blk(1,FRACTAL_INFO_SIZE,(char far *)&save_info)) {
	    goto oops;
	}
	}

if (fwrite(";",1,1,out) != 1) goto oops;          /* GIF Terminator */

return ((ydot < 9999) ? 0 : 1);

oops:
    {
    fflush(out);
    stopmsg(0,"Error Writing to disk (Disk full?)");
    return 1;
    }
}

static int _fastcall shftwrite(BYTE *color,int numcolors)
/* shift IBM colors to GIF */
{
BYTE thiscolor;
int i,j;
for (i = 0; i < numcolors; i++)
	for (j = 0; j < 3; j++) {
		thiscolor = color[3*i+j];
		thiscolor = thiscolor << 2;
		thiscolor += (thiscolor >> 6);
		if (fputc(thiscolor,out) != thiscolor) return(0);
		}
return(1);
}

static int inittable() 		/* routine to init tables */
{
int i;

if (!raster(clearcode)) return(0);	/* signal that table is initialized */

numentries = 0; 			/* initialize the table */
numrealentries = 0;
nextentry = 1;
lentest = 0;
codebits = startbits;

toextra(0,"\0",1);                      /* clear the hash entries */
for (i = 0; i < MAXENTRY; i++)
	strlocn[i] = 0;

return(1);
}

static int _fastcall raster(code)	/* routine to block and output codes */
unsigned int code;
{
unsigned int icode, i, j;

if (code == 9999) {			/* special start-up signal */
	bytecount = 0;
	bitcount = 0;
	for (i = 0; i < 266; i++)
		block[i] = 0;
	return(1);
	}

icode = code << bitcount;		/* update the bit string */
block[bytecount  ] |= (icode & 255);
block[bytecount+1] |= ((icode>>8) & 255);
icode = (code>>8) << bitcount;
block[bytecount+2] |= ((icode>>8) & 255);
bitcount += codebits;
while (bitcount >= 8) { 		/* locate next starting point */
	bitcount -= 8;
	bytecount++;
	}

if (bytecount > 250 || code == endcode) {	/* time to write a block */
	if (code == endcode)
		while (bitcount > 0) {		/* if EOF, find the real end */
			bitcount -= 8;
			bytecount++;
			}
	i = bytecount;
	blockcount = i;
        if (write1(&blockcount,1,1,out) != 1) return(0); /* write the block */
	if (fwrite(block,i,1,out) != 1) return(0);
	bytecount = 0;				/* now re-start the block */
	for (j = 0; j < 5; j++) 		/* (may have leftover bits) */
		block[j] = block[j+i];
	for (j = 5; j < 266; j++)
		block[j] = 0;
	}
return(1);
}


static int _fastcall extend_blk_len(int datalen)
{
   return(datalen + (datalen+254)/255 + 15);
   /*	   data   +	1.per.block   + 14 for id + 1 for null at end  */
}

static int _fastcall put_extend_blk(int block_id,int block_len,char far *block_data)
{
   int i,j;
   char header[15];
   strcpy(header,"!\377\013fractint");
   sprintf(&header[11],"%03u",block_id);
   if (fwrite(header,14,1,out) != 1) return(0);
   i = (block_len + 254) / 255;
   while (--i >= 0) {
      block_len -= (j = min(block_len,255));
      if (fputc(j,out) != j) return(0);
      while (--j >= 0)
	 fputc(*(block_data++),out);
      }
   if (fputc(0,out) != 0) return(0);
   return(1);
}

static int _fastcall store_item_name(char *nameptr)
{
   char tmpname[40];
   strcpy(tmpname,nameptr);
   /* formula/lsys/ifs info block, 003 */
   put_extend_blk(3,40,tmpname);
   return(extend_blk_len(40));
}

static void _fastcall setup_save_info(struct fractal_info *save_info)
{
   int i;

   if(fractype != FORMULA && fractype != FFORMULA)
      maxfn = 0;     
   /* set save parameters in save structure */
   strcpy(save_info->info_id, INFO_ID);
   save_info->version	      = 9; /* file version, independant of system */
   save_info->iterations      = maxit;
   save_info->fractal_type    = fractype;
   save_info->xmin	      = xxmin;
   save_info->xmax	      = xxmax;
   save_info->ymin	      = yymin;
   save_info->ymax	      = yymax;
   save_info->creal	      = param[0];
   save_info->cimag	      = param[1];
   save_info->videomodeax     = videoentry.videomodeax;
   save_info->videomodebx     = videoentry.videomodebx;
   save_info->videomodecx     = videoentry.videomodecx;
   save_info->videomodedx     = videoentry.videomodedx;
   save_info->dotmode	      = videoentry.dotmode % 100;
   save_info->xdots	      = videoentry.xdots;
   save_info->ydots	      = videoentry.ydots;
   save_info->colors	      = videoentry.colors;
   save_info->parm3	      = 0; /* pre version==7 fields */
   save_info->parm4	      = 0;
   save_info->dparm3	      = param[2];
   save_info->dparm4	      = param[3];
   save_info->dparm5	      = param[4];
   save_info->dparm6	      = param[5];
   save_info->dparm7	      = param[6];
   save_info->dparm8	      = param[7];
   save_info->dparm9	      = param[8];
   save_info->dparm10         = param[9];
   save_info->fillcolor	      = fillcolor;
   save_info->potential[0]    = potparam[0];
   save_info->potential[1]    = potparam[1];
   save_info->potential[2]    = potparam[2];
   save_info->rflag	      = rflag;
   save_info->rseed	      = rseed;
   save_info->inside	      = inside;
   save_info->logmap	      = LogFlag;
   save_info->invert[0]       = inversion[0];
   save_info->invert[1]       = inversion[1];
   save_info->invert[2]       = inversion[2];
   save_info->decomp[0]       = decomp[0];
   save_info->biomorph	      = usr_biomorph;
   save_info->symmetry	      = forcesymmetry;
   for (i = 0; i < 16; i++)
      save_info->init3d[i] = init3d[i];
   save_info->previewfactor   = previewfactor;
   save_info->xtrans	      = xtrans;
   save_info->ytrans	      = ytrans;
   save_info->red_crop_left   = red_crop_left;
   save_info->red_crop_right  = red_crop_right;
   save_info->blue_crop_left  = blue_crop_left;
   save_info->blue_crop_right = blue_crop_right;
   save_info->red_bright      = red_bright;
   save_info->blue_bright     = blue_bright;
   save_info->xadjust	      = xadjust;
   save_info->eyeseparation   = eyeseparation;
   save_info->glassestype     = glassestype;
   save_info->outside	      = outside;
   save_info->x3rd	      = xx3rd;
   save_info->y3rd	      = yy3rd;
   save_info->calc_status     = calc_status;
   save_info->stdcalcmode     = stdcalcmode;
   save_info->distest	      = distest;
   save_info->floatflag       = floatflag;
   save_info->bailout	      = bailout;
   save_info->calctime	      = calctime;
   save_info->trigndx[0]      = trigndx[0];
   save_info->trigndx[1]      = trigndx[1];
   save_info->trigndx[2]      = trigndx[2];
   save_info->trigndx[3]      = trigndx[3];
   save_info->finattract      = finattract;
   save_info->initorbit[0]    = initorbit.x;
   save_info->initorbit[1]    = initorbit.y;
   save_info->useinitorbit    = useinitorbit;
   save_info->periodicity     = periodicitycheck;
   save_info->pot16bit	      = disk16bit;
   save_info->faspectratio    = finalaspectratio;
   save_info->system	      = save_system;
   save_info->release	      = save_release;
   save_info->flag3d	      = display3d;
   save_info->ambient	      = Ambient;
   save_info->randomize       = RANDOMIZE;
   save_info->haze	      = haze;
   save_info->transparent[0]  = transparent[0];
   save_info->transparent[1]  = transparent[1];
   save_info->rotate_lo       = rotate_lo;
   save_info->rotate_hi       = rotate_hi;
   save_info->distestwidth    = distestwidth;
   save_info->mxmaxfp         = mxmaxfp;
   save_info->mxminfp         = mxminfp;
   save_info->mymaxfp         = mymaxfp;
   save_info->myminfp         = myminfp;
   save_info->zdots           = zdots;		
   save_info->originfp        = originfp;
   save_info->depthfp         = depthfp;	
   save_info->heightfp        = heightfp;
   save_info->widthfp         = widthfp;	
   save_info->distfp          = distfp;	
   save_info->eyesfp          = eyesfp;	
   save_info->orbittype       = neworbittype;
   save_info->juli3Dmode      = juli3Dmode;
   save_info->maxfn           = maxfn;
   save_info->inversejulia    = (major_method << 8) + minor_method; /* MVS */
   for (i = 0; i < sizeof(save_info->future)/sizeof(short); i++)
      save_info->future[i] = 0;
}
