/*
 * Program: TIM2BMP
 * Author:  Raul Sobon (Cheekyboy@2-hot.com)
 *			http://cheekyboy.home.ml.org/
 *			My playstation page is "http://play-station.home.ml.org"
 * Date:	21/March/1997
 * Desc:	This program converts any/most .TIM PSX files as best as it can
 *			to either 4/8/24bit .BMP files, NOTE: 16bit .TIM files are automaticly
 *			converted to 24bit BMP because there is no such thing as 16bit BMP
 *
 * Note:	To all who have Sonys source code and/or full stucture definitions, stuff
 *			your NDA etc... its only a bloody file format nothing special. This bit of
 *			engineered code that was done by trial/error and experimentation of other not
 *			so 'good' converters is 100% free for all and no crappy NDA attached! Also
 *			its BMPs are not upside down as others are.
 *			Feel free to port this to other unix's/ Macs / Windows/ Amigas whatever...
 *			just note that CPU endians change from one to another.
 *
 *
 * History:	21/Mar/1997 - First code and stuff
 *			22/Mar/1997 - Made it read the whole source and output right side up BMP
 *			23/Mar/1997 - Fixed problems with some pics not being in x16 width which
 *							would be all skewed up!
 *			24/Mar/1997 - Added support for RAW pictures with no headers.
 *							code assumes 320x256, but you can submit any X/Y size.
 *							Many .PIC or .RAW pics have worked fine :)
 *
 *
 *
 *
 *
 *
 */

#include <stdio.h>
#include <string.h>

typedef unsigned long DWORD;
typedef long LONG;
typedef short WORD;
typedef short UINT;
typedef unsigned char BYTE;


static char ver[]={ "$VER: Tim2Bmp Version 1.00 (23/Mar/1997)" };
/* --- Conversion util funcs --- */

/* swap word little -> big endian */
short swapw( short word )
{
	short a,b;

	a = word;
	b = a;
	a = a>>8;
	a |= (b<<8);
	return a;
}

/* swap long little -> big endian */
long swapl( long dword )
{
	long x;
	short a,b;

	x = dword;
	a = (x&0xffff);
	b = (x>>16);
	a = swapw( a ); b = swapw( b );
	return ((a<<16) | (b));
}

/* 0rrrrrgg gggbbbbb */
void conv16to24bit( short word, BYTE *rgb )
{
	BYTE	r,g,b;
	r = (word>>10);
	g = (word>>5)&0x1f;
	b = (word)&0x1f;
	rgb[0] = r<<3;
	rgb[1] = g<<3;
	rgb[2] = b<<3;

}



/*
 *  .BMP Structures and keywords...
 */

#define BMFH_SIZE		(14)
typedef struct tagBITMAPFILEHEADER {    /* bmfh (14) */
    UINT    bfType;		/*Specifies the type of file. This member must be BM. */
    DWORD   bfSize;		/*Specifies the size of the file, in bytes. */
    UINT    bfReserved1;	/* 0 */
    UINT    bfReserved2;	/* 0 */
    DWORD   bfOffBits;		/*Specifies the byte offset from the BITMAPFILEHEADER structure*/
    				/*to the actual bitmap data in the file.*/
} BITMAPFILEHEADER;
                    
#define BMIH_SIZE		(40)
typedef struct tagBITMAPINFOHEADER {    /* bmih */
    DWORD   biSize;		/*Specifies the number of bytes required by the BITMAPINFOHEADER structure.*/
    LONG    biWidth;		/*pixels*/
    LONG    biHeight;
    WORD    biPlanes;		/*must be 1 */
    WORD    biBitCount;		/*1,4,8,24 */
    DWORD   biCompression;	/*0 */
    DWORD   biSizeImage;
    LONG    biXPelsPerMeter;
    LONG    biYPelsPerMeter;
    DWORD   biClrUsed;
    DWORD   biClrImportant;
} BITMAPINFOHEADER;
                                            
#define RGB_SIZE		(4*256)
typedef struct tagRGBQUAD {     /* rgbq */
    BYTE    rgbBlue;
    BYTE    rgbGreen;
    BYTE    rgbRed;
    BYTE    rgbReserved;
} RGBQUAD;

#define	TOTAL_HEADER_SIZE	(BMFH_SIZE + BMIH_SIZE + RGB_SIZE)
                                                            
struct BMP {
	BITMAPFILEHEADER bmfh;
	BITMAPINFOHEADER bmih;
}	main_bmp;


#define WRITEVAR(fd, value)	fwrite( &value, sizeof(value), 1, fd )
/* printf("%08lx size=%d\n",value, sizeof(value));
*/



/*
 *   .TIM File structures and keywords
 */

#define	TIM_ID1		0x10000000		/* TIM ID	 */
#define	TIM_4Bit	0x08000000		/* USE CLUT  */
#define	TIM_8Bit	0x09000000		/* USE CLUT  */
#define	TIM_16Bit	0x02000000		/* NO CLUT   */

struct TIM_Header {
	long	id1;
	long	type;
	long	nextlen;
} tim_header;

struct TIM_ClutInfo {
	long	flags;
	short	ncols;
	short	npals;
	short	Clut16Bit[256];
} tim_clutinfo;

struct TIM_DimInfo {
	short	yskip;
	short	xskip;
	short	xsize;
	short	ysize;
} tim_diminfo;






/* fill out the BMP header and write each variable to file */
void WriteBMPHeader( FILE *fd, long xsize, long ysize, long depth )
{
	BYTE	rgbq[4];
	short	col;

	main_bmp.bmfh.bfType = swapw('BM');
	main_bmp.bmfh.bfSize = TOTAL_HEADER_SIZE + (xsize*ysize*depth)/8;
	main_bmp.bmfh.bfReserved1 = main_bmp.bmfh.bfReserved2 = 0;
	main_bmp.bmfh.bfOffBits = TOTAL_HEADER_SIZE;

	WRITEVAR( fd, main_bmp.bmfh.bfType );
	WRITEVAR( fd, main_bmp.bmfh.bfSize );
	WRITEVAR( fd, main_bmp.bmfh.bfReserved1 );
	WRITEVAR( fd, main_bmp.bmfh.bfReserved2 );
	WRITEVAR( fd, main_bmp.bmfh.bfOffBits );

	main_bmp.bmih.biSize = BMIH_SIZE;
	main_bmp.bmih.biWidth = xsize;
	main_bmp.bmih.biHeight = ysize;
	main_bmp.bmih.biPlanes = 1;
	main_bmp.bmih.biBitCount = depth;
	main_bmp.bmih.biCompression = 0;
	main_bmp.bmih.biSizeImage = (xsize*ysize*depth)/8;
	main_bmp.bmih.biXPelsPerMeter = 2835;
	main_bmp.bmih.biYPelsPerMeter = 2835;
	if ( depth == 4 )
		main_bmp.bmih.biClrUsed = 16;
	if ( depth == 8 )
		main_bmp.bmih.biClrUsed = 256;
	if ( depth > 8 )
		main_bmp.bmih.biClrUsed = 0;
	main_bmp.bmih.biClrImportant = 0;

	WRITEVAR( fd, main_bmp.bmih.biSize );
	WRITEVAR( fd, main_bmp.bmih.biWidth );
	WRITEVAR( fd, main_bmp.bmih.biHeight );
	WRITEVAR( fd, main_bmp.bmih.biPlanes );
	WRITEVAR( fd, main_bmp.bmih.biBitCount );
	WRITEVAR( fd, main_bmp.bmih.biCompression );
	WRITEVAR( fd, main_bmp.bmih.biSizeImage );
	WRITEVAR( fd, main_bmp.bmih.biXPelsPerMeter );
	WRITEVAR( fd, main_bmp.bmih.biYPelsPerMeter );
	WRITEVAR( fd, main_bmp.bmih.biClrUsed );
	WRITEVAR( fd, main_bmp.bmih.biClrImportant );

	/* write converted CLUT RGB table (psx uses 15bit RGB) */
	for ( col=0; col <256; col++){
		conv16to24bit( tim_clutinfo.Clut16Bit[col], &rgbq[0] );
		rgbq[3]=0;
		WRITEVAR( fd, rgbq );
	}
}

long ConvertTIM( char *s, char *d)
{
	FILE	*fs, *fd;
	long	err,bpp;
	long	length=0,timtype;
	short	xsize,xwords,xl;
	short	ysize,yl;
	short	xskip=0, xpixelskip=0;
	BYTE 	*src, *srcptr;
	
	if ( (fs=fopen( s, "r" )) ){
		if ( (fd=fopen( d, "w+" )) ){
			err = fread( &tim_header, sizeof( struct TIM_Header ),1, fs );
			if ( swapl(tim_header.id1) == TIM_ID1 ){
				printf("Decoding PSX.TIM\t");	/* process source .tim */
				length = tim_header.nextlen;
				timtype = swapl(tim_header.type);

				/* if cluts are available, read them */
				if ( timtype == TIM_4Bit ){
					bpp = 4;
					fread( &tim_clutinfo, length-4, 1, fs );
					fread( &length, 4, 1, fs );
					printf( "4bit CLUT (%d colors)\n", tim_clutinfo.ncols );
				} else
				if ( timtype == TIM_8Bit ){
					bpp = 8;
					fread( &tim_clutinfo, length-4, 1, fs );
					fread( &length, 4, 1, fs );
					printf( "8bit CLUT (%d colors)\n", tim_clutinfo.ncols );
				} else
				if ( timtype == TIM_16Bit ){
					bpp = 24;
					printf( "16bit -> 24bit (TrueColor)\n");
				}

				fread( &tim_diminfo, sizeof( struct TIM_DimInfo ), 1, fs );

				xwords = tim_diminfo.xsize;
				ysize = tim_diminfo.ysize;
				if ( timtype == TIM_4Bit )	xsize = xwords*4; else
				if ( timtype == TIM_8Bit )	xsize = xwords*2; else
				if ( timtype == TIM_16Bit )	xsize = xwords;

				/** fix wrong width skewing errors **/
				if ( (xsize%16) != 0 ){
					xskip = (((xsize>>4)+1)<<4) - xsize;
					xsize = (((xsize>>4)+1)<<4);
					if ( timtype == TIM_4Bit )	xpixelskip = xskip/2; else
					if ( timtype == TIM_8Bit )	xpixelskip = xskip; else
					if ( timtype == TIM_16Bit )	xpixelskip = xskip;
				}

				printf( "%ld bytes, (%d x %d) skip=%d\n", length, xsize, ysize, xskip );
				WriteBMPHeader( fd, xsize, ysize, bpp );	/* write bmp header */

				if( (src=(BYTE*)malloc( length )) ){
				  BYTE	pixel[4];
				  long	index;

				  fread( src, length, 1 , fs );		/* read source bitmap */

				  for ( yl=ysize-1; yl>=0 ; yl--){
					index = ( yl * (2*xwords) );
					srcptr = src + index;

					/* convert the source pixels to dest and write them */
					for ( xl=0; xl < xwords ; xl++){
						if ( timtype == TIM_4Bit ){
							fwrite( srcptr, 2, 1, fd );
							srcptr+=2;
						} else
						if ( timtype == TIM_8Bit ){
							fwrite( srcptr, 2, 1, fd );
							srcptr+=2;
						} else
						if ( timtype == TIM_16Bit ){
							conv16to24bit( *(short *)(srcptr), &pixel[0] );
							fwrite( &pixel[0], 3, 1, fd );
							srcptr+=2;
						}
					}
					if ( xskip ){	/* handle incorrect width TIMs */
						for( xl=0; xl<xpixelskip; xl++){
							if ( timtype == TIM_16Bit ){
								conv16to24bit( *(short *)(srcptr-2), &pixel[0] );
								fwrite( &pixel[0], 3, 1, fd );
							} else
								fwrite( srcptr-2, 1, 1, fd );
						}
					}
					printf("Converting line %d    \n\033[A", yl );
				  }
				  free(src);
				} else printf("cant allocate %ld RAM\n", length );
			} else printf("%s is not a valid TIM file", s );
			fclose(fd);
		} else printf("cant open dest file %s\n", d );
		fclose(fs);
	} else printf("cant open source file %s\n", s );
	printf( "\n" );
	return length;
}


long flen( FILE *fs )
{
	long len;
	
	fseek( fs,0,SEEK_END );
	len = ftell( fs );
	fseek( fs,0,SEEK_SET );
	return len;
}


long ConvertRAW( char *s, char *d, long width, long height )
{
	FILE	*fs, *fd;
	long	bpp,length,err;
	short	xsize,xwords,xl;
	short	ysize,yl;
	BYTE 	*src, *srcptr;
	
	if ( (fs=fopen( s, "r" )) ){
		if ( (fd=fopen( d, "w+" )) ){
				printf("Decoding PSX.RAW\t");	/* process source RAW .pic */

				bpp = 24;
				printf( "16bit -> 24bit (TrueColor)\n");

				length = flen(fs);
				xsize = width;
				xwords = width;
				ysize = height;

				printf( "%ld bytes, (%d x %d)\n", length, xsize, ysize );
				WriteBMPHeader( fd, xsize, ysize, bpp );	/* write bmp header */

				if( (src=(BYTE*)malloc( length )) ){
				  BYTE	pixel[4];
				  long	index;

				  err = fread( src, 1, length, fs );		/* read source bitmap */

				  for ( yl=ysize-1; yl>=0 ; yl--){
					index = ( yl * (2*xwords) );
					srcptr = src + index;

					/* convert the source pixels to dest and write them */
					for ( xl=0; xl < xwords ; xl++){
						conv16to24bit( *(short *)(srcptr), &pixel[0] );
						fwrite( &pixel[0], 3, 1, fd );
						srcptr+=2;
					}
					printf("Converting line %d    \n\033[A", yl );
				  }
				  free(src);
				} else printf("cant allocate %ld RAM\n", length );
				fclose(fd);
		} else printf("cant open dest file %s\n", d );
		fclose(fs);
	} else printf("cant open source file %s\n", s );
	printf( "\n" );

	return length;
}



/*
 * Main -- Raul Sobons TIM2BMP converter, if its 16bit,make it 24bit
 *
 *
 */
int main ( int argc,char **argv )
{
	long	x=320,y=256,depth;

	if ( argc >= 6 ){
		x = atoi( argv[5] );
		ConvertRAW( argv[1], argv[2], x, y );
	} else
	if ( argc >= 5 ){
		x = atoi( argv[4] );
		ConvertRAW( argv[1], argv[2], x, y );
	} else
	if ( argc >= 4 ){
		x = atoi( argv[3] );
		ConvertRAW( argv[1], argv[2], x, y );
	} else
	if ( argc >= 3 ){
		if ( ConvertTIM( argv[1], argv[2] ) == 0 ){
			if ( ConvertRAW( argv[1], argv[2], x, y ) == 0 ){
				return 1;
			}
		}
	} else
	if ( argc >= 2 ){
		printf( "dest file not specified, defaulting to /tmp/psx.bmp" );
		if ( ConvertTIM( argv[1], "/tmp/psx.bmp" ) == 0 ){
			return 1;
		}
	} else
	if ( argc >= 1 ){
		printf( "Usage: %s Source.TIM Dest.BMP [raw xsize] [raw ysize]\n\tThis converts *ANY* .TIM PSX file into a valid BMP file.\n\t(c) Mar/1997 - Raul Sobon (cheekyboy@2-hot.com)\n\t%s\n",argv[0], ver);
	}

	return 0;
}



