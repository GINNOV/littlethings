/*
	Disable/Enable DisplayID 
	by Tobias Abt
	Wed May 19 13:16:37 1999
	
	:ts=3
*/

#include <exec/types.h>
#include <dos/rdargs.h>
#include <graphics/modeid.h>

#include <proto/dos.h>
#include <proto/graphics.h>

#include <stdio.h>

/* add these to your pragmas/graphics_pragmas.h include file*/
#pragma libcall GfxBase AddDisplayInfo 2e2 801
#pragma libcall GfxBase AddDisplayInfoData 2e8 2109805
#pragma libcall GfxBase SetDisplayInfoData 2ee 2109805
/** and these to clib/graphics_protos.h **/
DisplayInfoHandle AddDisplayInfo( DisplayInfoHandle handle);
ULONG AddDisplayInfoData( DisplayInfoHandle handle, UBYTE *buf,
	unsigned long size, unsigned long tagID, unsigned long displayID );
ULONG SetDisplayInfoData( DisplayInfoHandle handle, UBYTE *buf,
	unsigned long size, unsigned long tagID, unsigned long displayID );

static BOOL GetHexBinDecStrValue(char *hexstr, LONG *result);

char template[] = "DisplayID,Enable/S";
LONG array[2] = { 0, 0 };

int main(void)
{
	struct RDArgs *rda;
	ULONG DisplayID = INVALID_ID;
	
	BOOL set = FALSE;
	
	if(rda = ReadArgs(template, array, NULL)){
		if(array[0]){
			GetHexBinDecStrValue((char *)array[0], (LONG *)&DisplayID);
			set = TRUE;
		}
		
		if(DisplayID != INVALID_ID){
			struct DisplayInfo dis;
			if(GetDisplayInfoData(NULL, (UBYTE *)&dis, sizeof(dis), DTAG_DISP, DisplayID)){
				if(array[1]){
					/* re-enable */
					dis.NotAvailable &= ~0x1000;
					printf("Re-enabling $%08lx...\n", DisplayID);
				}else{
					/* disable:
						setting the NotAvailable field to non-zero disables the mode
						to be able to undo everything cleanly I use a bit that is not
						used by the OS for that purpose. Which one really does not matter */
					dis.NotAvailable |= 0x1000;
					printf("Disabling $%08lx...\n", DisplayID);
				}
				SetDisplayInfoData(NULL, (UBYTE *)&dis, sizeof(dis), DTAG_DISP, DisplayID);
			}
		}
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
