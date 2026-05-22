#include <exec/types.h>

#include <exec/execbase.h>

#include <graphics/view.h>
#include <graphics/displayinfo.h>

#define __USE_SYSBASE
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/dos.h>

#include <stdio.h>

int main(int argc, char ** argv){
	ULONG ID = INVALID_ID, last = INVALID_ID;
	ULONG *array;
	DisplayInfoHandle dih;

	struct DisplayInfo dis;
	struct DimensionInfo dim;
	struct MonitorInfo mon;
	struct NameInfo nam;
	struct VecInfo vec;
	
	ULONG	disl, diml, monl, naml, vecl;
	
	do{
		ID = NextDisplayInfo(ID);
		if(ID == INVALID_ID)	break;

		if(last != INVALID_ID)
			printf("*****************************************************************************************************\n");
		last=ID;

		dih = FindDisplayInfo(ID);
		if(dih){
			disl = GetDisplayInfoData(dih, (UBYTE *)&dis, sizeof(dis), DTAG_DISP, NULL);
			diml = GetDisplayInfoData(dih, (UBYTE *)&dim, sizeof(dim), DTAG_DIMS, NULL);
			monl = GetDisplayInfoData(dih, (UBYTE *)&mon, sizeof(mon), DTAG_MNTR, NULL);
			naml = GetDisplayInfoData(dih, (UBYTE *)&nam, sizeof(nam), DTAG_NAME, NULL);
			vecl = GetDisplayInfoData(dih, (UBYTE *)&vec, sizeof(vec), DTAG_VEC, NULL);
/*
			GetDisplayInfoData(NULL,(UBYTE *)&dis,sizeof(dis),DTAG_DISP,ID);
			GetDisplayInfoData(NULL,(UBYTE *)&dim,sizeof(dim),DTAG_DIMS,ID);
			GetDisplayInfoData(NULL,(UBYTE *)&mon,sizeof(mon),DTAG_MNTR,ID);
			GetDisplayInfoData(NULL,(UBYTE *)&nam,sizeof(nam),DTAG_NAME,ID);
			GetDisplayInfoData(NULL,(UBYTE *)&vec,sizeof(vec),DTAG_VEC,ID);
*/
			array=(ULONG *)dih;

			if(naml > 0) printf("\n+++ Name: %s +++\n",nam.Name);

			printf("ID: %08lx - @ %08lx\n   %08lx %08lx %08lx %08lx\n   %08lx %08lx %08lx %08lx\n   %08lx %08lx %08lx %08lx\n   %08lx %08lx\n",ID,dih,array[0],array[1],array[2],array[3],array[4],array[5],array[6],array[7],array[8],array[9],array[10],array[11],array[12],array[13]);
			if(disl > 0){
				printf("DisplayInfo:\n");
					printf("QueryHeader: %08lx %08lx %08lx %08lx\n",dis.Header.StructID,dis.Header.DisplayID,dis.Header.SkipID,dis.Header.Length);
					printf("NotAvailable: %04x\nPropertyFlags: %08lx <=>  ",dis.NotAvailable,dis.PropertyFlags);
					if(dis.PropertyFlags & DIPF_IS_LACE)					printf("LACE ");
					if(dis.PropertyFlags & DIPF_IS_DUALPF)					printf("DUALPF ");
					if(dis.PropertyFlags & DIPF_IS_PF2PRI)					printf("PF2PRI ");
					if(dis.PropertyFlags & DIPF_IS_HAM)						printf("HAM ");
					if(dis.PropertyFlags & DIPF_IS_ECS)						printf("ECS ");
					if(dis.PropertyFlags & DIPF_IS_AA)						printf("AA ");
					if(dis.PropertyFlags & DIPF_IS_PAL)						printf("PAL ");
					if(dis.PropertyFlags & DIPF_IS_SPRITES)				printf("SPRITES ");
					if(dis.PropertyFlags & DIPF_IS_GENLOCK)				printf("GENLOCK ");
					if(dis.PropertyFlags & DIPF_IS_WB)						printf("WB ");
					if(dis.PropertyFlags & DIPF_IS_DRAGGABLE)				printf("DRAGGABLE ");
					if(dis.PropertyFlags & DIPF_IS_PANELLED)				printf("PANELLED ");
					if(dis.PropertyFlags & DIPF_IS_BEAMSYNC)				printf("BEAMSYNC ");
					if(dis.PropertyFlags & DIPF_IS_EXTRAHALFBRITE)		printf("EXTRAHALFBRITE ");
					if(dis.PropertyFlags & DIPF_IS_SPRITES_ATT)			printf("SPRITES_ATT ");
					if(dis.PropertyFlags & DIPF_IS_SPRITES_CHNG_RES)	printf("SPRITES_CHNG_RES ");
					if(dis.PropertyFlags & DIPF_IS_SPRITES_BORDER)		printf("SPRITES_BORDER ");
					if(dis.PropertyFlags & DIPF_IS_SCANDBL)				printf("SCANDBL ");
					if(dis.PropertyFlags & DIPF_IS_SPRITES_CHNG_BASE)	printf("SPRITES_CHNG_BASE ");
					if(dis.PropertyFlags & DIPF_IS_SPRITES_CHNG_PRI)	printf("SPRITES_CHNG_PRI ");
					if(dis.PropertyFlags & DIPF_IS_DBUFFER)				printf("DBUFFER ");
					if(dis.PropertyFlags & DIPF_IS_PROGBEAM)				printf("PROGBEAM ");
					if(dis.PropertyFlags & DIPF_IS_FOREIGN)				printf("FOREIGN ");
					printf("\n");
					printf("Resolution: %dx%d - PixelSpeed: %dns\n",dis.Resolution.x,dis.Resolution.y,dis.PixelSpeed);
					printf("NumStdSprites: %d - SpriteResolution: %dx%d\n",dis.NumStdSprites,dis.SpriteResolution.x,dis.SpriteResolution.y);
					printf("PaletteRange: %d - RedBits: %d - GreenBits: %d - BlueBits: %d\n",dis.PaletteRange,dis.RedBits,dis.GreenBits,dis.BlueBits);
					printf("pad: %08lx - pad2: %x %x %x %x %x\n",dis.pad,dis.pad2[0],dis.pad2[1],dis.pad2[2],dis.pad2[3],dis.pad2[4]);
//					printf("reserved: %08lx %08lx\n",dis.reserved[0],dis.reserved[1]);
					printf("\n");
			}

			if(diml > 0){
				printf("DimensionInfo:\n");
					printf("QueryHeader: %08lx %08lx %08lx %08lx\n",dim.Header.StructID,dim.Header.DisplayID,dim.Header.SkipID,dim.Header.Length);
					printf("MaxDepth: %d - MinRasterWidth: %d - MinRasterHeight: %d - MaxRasterWidth: %d - MaxRasterHeight: %d\n",dim.MaxDepth,dim.MinRasterWidth,dim.MinRasterHeight,dim.MaxRasterWidth,dim.MaxRasterHeight);
					printf("Nominal:    (%dx%d) - (%dx%d)\n",dim.Nominal.MinX,dim.Nominal.MinY,dim.Nominal.MaxX,dim.Nominal.MaxY);
					printf("MaxOScan:   (%dx%d) - (%dx%d)\n",dim.MaxOScan.MinX,dim.MaxOScan.MinY,dim.MaxOScan.MaxX,dim.MaxOScan.MaxY);
					printf("VideoOScan: (%dx%d) - (%dx%d)\n",dim.VideoOScan.MinX,dim.VideoOScan.MinY,dim.VideoOScan.MaxX,dim.VideoOScan.MaxY);
					printf("TxtOScan:   (%dx%d) - (%dx%d)\n",dim.TxtOScan.MinX,dim.TxtOScan.MinY,dim.TxtOScan.MaxX,dim.TxtOScan.MaxY);
					printf("StdOScan:   (%dx%d) - (%dx%d)\n",dim.StdOScan.MinX,dim.StdOScan.MinY,dim.StdOScan.MaxX,dim.StdOScan.MaxY);
					printf("pad: %x %x %x %x %x %x %x %x %x %x %x %x %x %x\n",
						dim.pad[0],dim.pad[1],dim.pad[2],dim.pad[3],dim.pad[4],dim.pad[5],dim.pad[6],dim.pad[7],dim.pad[8],dim.pad[9],dim.pad[10],dim.pad[11],dim.pad[12],dim.pad[13]);
	/*
					printf("pad: %08lx %08lx %08lx %04x\n",
						((ULONG *)dim.pad)[0],((ULONG *)dim.pad)[1],((ULONG *)dim.pad)[2],((UWORD *)dim.pad)[6]);
					printf("pad: %08lx %08lx %08lx %04x\n",
						*(ULONG *)&(dim.pad[0]),*(ULONG *)&(dim.pad[4]),*(ULONG *)&(dim.pad[8]),*(ULONG *)&(dim.pad[12]));
	*/
//					printf("reserved: %08lx %08lx\n",dim.reserved[0],dim.reserved[1]);
					printf("\n");
			}

			if(monl > 0){
				printf("MonitorInfo:\n");
					printf("QueryHeader: %08lx %08lx %08lx %08lx\n",mon.Header.StructID,mon.Header.DisplayID,mon.Header.SkipID,mon.Header.Length);
					printf("MonitorSpec: %08lx\n",mon.Mspc);
					printf("ViewPosition:   %dx%d\n",mon.ViewPosition.x,mon.ViewPosition.y);
					printf("ViewResolution: %dx%d\n",mon.ViewResolution.x,mon.ViewResolution.y);
					printf("ViewPositionRange: (%dx%d) - (%dx%d)\n",mon.ViewPositionRange.MinX,mon.ViewPositionRange.MinY,mon.ViewPositionRange.MaxX,mon.ViewPositionRange.MaxY);
					printf("TotalRows: %d - TotalColorClocks: %d - MinRow: %d\n",mon.TotalRows,mon.TotalColorClocks,mon.MinRow);
					printf("Compatibility: %s\n",(mon.Compatibility == MCOMPAT_MIXED) ? "MCOMPAT_MIXED" : ((mon.Compatibility == MCOMPAT_SELF) ? "MCOMPAT_SELF" : "MCOMPAT_NOBODY"));
					printf("pad: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",mon.pad[0],mon.pad[1],mon.pad[2],mon.pad[3],mon.pad[4],mon.pad[5],mon.pad[6],mon.pad[7]);
					printf("MouseTicks: (%dx%d)\n",mon.MouseTicks.x,mon.MouseTicks.y);
					printf("DefaultViewPosition: (%dx%d)\n",mon.DefaultViewPosition.x,mon.DefaultViewPosition.y);
					printf("PreferredModeID: %08lx\n",mon.PreferredModeID);
//					printf("reserved: %08lx %08lx\n",mon.reserved[0],mon.reserved[1]);
					printf("\n");
			
				if(mon.Mspc){
					printf("MonitorSpec:\n");
						printf("Flags: %x <=> ",mon.Mspc->ms_Flags);
						if(mon.Mspc->ms_Flags & REQUEST_NTSC)					printf("REQUEST_NTSC ");
						if(mon.Mspc->ms_Flags & REQUEST_PAL)					printf("REQUEST_PAL ");
						if(mon.Mspc->ms_Flags & REQUEST_SPECIAL)				printf("REQUEST_SPECIAL ");
						if(mon.Mspc->ms_Flags & REQUEST_A2024)					printf("REQUEST_A2024 ");
						printf("\n");
						printf("BeamCon0: %x\n",mon.Mspc->BeamCon0);
						printf("Ratio: (%ldx%ld)\n",mon.Mspc->ratioh,mon.Mspc->ratiov);
						printf("Total rows: %d\n",mon.Mspc->total_rows);
						printf("Total colorclocks: %d\n",mon.Mspc->total_colorclocks);
						printf("Min row: %d\n",mon.Mspc->min_row);
						printf("xln_Library: %08lx\n",mon.Mspc->ms_Node.xln_Library);
						printf("\n");
				}
	
				if(mon.Mspc && (mon.Mspc->ms_Special)){
					printf("SpecialMonitor:\n");
						printf("Functions: do_monitor %08lx r1 %08lx r2 %08lx r3 %08lx\n",mon.Mspc->ms_Special->do_monitor,mon.Mspc->ms_Special->reserved1,mon.Mspc->ms_Special->reserved2,mon.Mspc->ms_Special->reserved3);
						printf("HBlank: (%dx%d)\n",mon.Mspc->ms_Special->hblank.asi_Start, mon.Mspc->ms_Special->hblank.asi_Stop);
						printf("VBlank: (%dx%d)\n",mon.Mspc->ms_Special->vblank.asi_Start, mon.Mspc->ms_Special->vblank.asi_Stop);
						printf("HSync: (%dx%d)\n",mon.Mspc->ms_Special->hsync.asi_Start, mon.Mspc->ms_Special->hsync.asi_Stop);
						printf("VSync: (%dx%d)\n",mon.Mspc->ms_Special->vsync.asi_Start, mon.Mspc->ms_Special->vsync.asi_Stop);
						printf("\n");
				}
			}

			if(naml > 0){
				printf("NameInfo:\n");
					printf("QueryHeader: %08lx %08lx %08lx %08lx\n",nam.Header.StructID,nam.Header.DisplayID,nam.Header.SkipID,nam.Header.Length);
					printf("Name: %s\n",nam.Name);
//					printf("reserved: %08lx %08lx\n",nam.reserved[0],nam.reserved[1]);
					printf("\n");
			}

			if(vecl > 0){
				printf("VecInfo:\n");
					printf("QueryHeader: %08lx %08lx %08lx %08lx\n",vec.Header.StructID,vec.Header.DisplayID,vec.Header.SkipID,vec.Header.Length);
					printf("Vec:  %08lx\n",vec.Vec);
					printf("Data: %08lx\n",vec.Data);
					printf("Type: %04lx\n",vec.Type);
					printf("pad:  %04lx %04lx %04lx\n",vec.pad[0],vec.pad[1],vec.pad[2]);
//					printf("reserved: %08lx %08lx\n",vec.reserved[0],vec.reserved[1]);
					printf("\n");
	
	/*
					printf(": %dx%d - %dx%d\n",..MinX,..MinY,..MaxX,..MaxY);
					printf(": %dx%d\n",mon..x,mon..y);
					printf("\n");
	*/
			}
		}
	}while(1);
	return(0);
}
