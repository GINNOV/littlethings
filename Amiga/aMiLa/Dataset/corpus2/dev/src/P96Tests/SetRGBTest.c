/*
	SetRGB32 Test
	by Tobias Abt
	Mon Sep 20 00:09:30 1999
	
	:ts=3
*/

#include <exec/types.h>
#include <dos/rdargs.h>
#include <graphics/modeid.h>
#include <graphics/gfx.h>
#include <intuition/screens.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include <stdio.h>

static BOOL GetHexBinDecStrValue(char *hexstr, LONG *result);

char template[] = "Index, Color";
LONG array[] = { 0, 0 };

#define LINECNT(x) ((sizeof(x)/sizeof(Point))-1)

#define	PatSize	3
//UWORD Muster[(1L<<PatSize)]= { 0x1010, 0x2828, 0x5454, 0xaaaa, 0x5555, 0xaaaa, 0x5454, 0x2828 };
UWORD Muster[(1L<<PatSize)]= { 0x8080, 0x4040, 0xa0a0, 0x5050, 0xa8a8, 0x5454, 0xaaaa, 0x5555 };

int main(void)
{
	struct RDArgs *rda;
	ULONG index = 0;
	ULONG color = 0;
	
	if(rda = ReadArgs(template, array, NULL)){
		if(array[0]){
			GetHexBinDecStrValue((char *)array[0], (LONG *)&index);
		}
		if(array[1]){
			GetHexBinDecStrValue((char *)array[1], (LONG *)&color);
		}
		
		printf("index $%08lx color $%08lx\n", index, color);
		
		SetRGB32(&(IntuitionBase->FirstScreen->ViewPort), index, (color & 0xff0000) << 8, (color & 0xff00) << 16, (color & 0xff) << 24); 
		FreeArgs(rda);
	}
}

static BOOL GetHexBinDecStrValue(char *str, LONG *result)
{
	BOOL	negative;
	register LONG	z=0L;
	register char	b;
	if(str){
		while( *str == ' ' || *str == '\t' ) str++;		// Leerzeichen überlesen
		if(negative = ( *str=='-' ) )	 str++;				// Negativ ?
		if( *str == '$' ){		// Hex ?
			str++;
			while(b = *str++){
				if( (b >= '0') && (b <= '9') ){
					z *= 16;
					z += (ULONG)(b - '0');
				}else{
					b |= ' ';
					if( (b >= 'a') && (b <= 'f') ){
						z *= 16;
						z += (ULONG)(b - 'a' + 10);
					}else{
						return(FALSE);
					}
				}
			}
		}else if( *str == '%' ){		// Bin ??
			str++;
			while(b = *str++){
				if( (b >= '0') && (b <= '1') ){
					z *= 2;
					z += (ULONG)(b - '0');
				}else{
					return(FALSE);
				}
			}
		}else{		// Dec !
			while(b =* str++){
				if( (b >= '0') && (b <= '9') ){
					z =  (z << 3) + z + z;
					z += (ULONG)(b - '0');
				}else return(FALSE);
			}
		}
		*result = (negative ? -z : z);
		return(TRUE);
	}
	return(FALSE);
}
