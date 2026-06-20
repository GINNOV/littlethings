#include <stdio.h>
#include	<proto/exec.h>
#include	<proto/graphics.h>
#include	<graphics/modeid.h>

struct DisplayInfo DisI;
struct DimensionInfo DimI;
struct MonitorInfo MonI;
struct NameInfo NamI;

//#define	ID	(NTSC_MONITOR_ID|HIRESLACE_KEY)
//#define	ID	0x506a9004
//#define	ID	0x5300c
//#define	ID	0x71000
#define	ID	0x21000
//#define	ID	0x11000
//#define	ID	0x39024

void main(void)
{
	if(GetDisplayInfoData(NULL,(UBYTE *)&DisI,sizeof(struct DisplayInfo),DTAG_DISP,ID)){
		if(GetDisplayInfoData(NULL,(UBYTE *)&DimI,sizeof(struct DimensionInfo),DTAG_DIMS,ID)){
			if(GetDisplayInfoData(NULL,(UBYTE *)&MonI,sizeof(struct MonitorInfo),DTAG_MNTR,ID)){
				if(GetDisplayInfoData(NULL,(UBYTE *)&NamI,sizeof(struct NameInfo),DTAG_NAME,ID)){
					struct Rectangle	*rec;

					printf("Information\n==========\n");
					printf("NameInfo:\n"); 
					printf("\tName: %s\n",NamI.Name);
					printf("\n"); 
					printf("DimensionInfo:\n"); 
					printf("\tMaxDepth: %d\n",DimI.MaxDepth);
					printf("\tMinRaster: (%d,%d)\n",DimI.MinRasterWidth,DimI.MinRasterHeight);
					printf("\tMaxRaster: (%d,%d)\n",DimI.MaxRasterWidth,DimI.MaxRasterHeight);
					rec = &(DimI.Nominal);
					printf("\tOverscan Nominal: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					rec = &(DimI.MaxOScan);
					printf("\tOverscan MaxOScan: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					rec = &(DimI.VideoOScan);
					printf("\tOverscan VideoOScan: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					rec = &(DimI.TxtOScan);
					printf("\tOverscan TxtOScan: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					rec = &(DimI.StdOScan);
					printf("\tOverscan StdOScan: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					printf("\n"); 
					printf("DisplayInfo:\n"); 
					printf("\tNotAvailable: 0x%x\n",DisI.NotAvailable);
					printf("\tPropertyFlags: 0x%lx\n",DisI.PropertyFlags);
					printf("\tResolution: (%d,%d)\n",DisI.Resolution.x,DisI.Resolution.y);
					printf("\tPixelSpeed: %d\n",DisI.PixelSpeed);
					printf("\tNumStdSprites: %d\n",DisI.NumStdSprites);
					printf("\tSpriteResolution: (%d,%d)\n",DisI.SpriteResolution.x,DisI.SpriteResolution.y);
					printf("\tpad: 0x%lx\n",*(ULONG *)&(DisI.pad[0]));
					printf("\tRGB bits: (%d,%d,%d)\n",DisI.RedBits,DisI.GreenBits,DisI.BlueBits);
					printf("\n"); 
					printf("MonitorInfo:\n"); 
					printf("\tViewPosition: (%d,%d)\n",MonI.ViewPosition.x,MonI.ViewPosition.y);
					printf("\tViewResolution: (%d,%d)\n",MonI.ViewResolution.x,MonI.ViewResolution.y);
					rec = &(MonI.ViewPositionRange);
					printf("\tOverscan ViewPositionRange: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					printf("\tTotalRows: %d\n",MonI.TotalRows);
					printf("\tTotalColorClocks: %d\n",MonI.TotalColorClocks);
					printf("\tMinRow: %d\n",MonI.MinRow);
					printf("\tCompatibility: 0x%x\n",MonI.Compatibility);
					printf("\tPad1: 0x%lx\n",*(ULONG *)&(MonI.pad[0]));
					printf("\tPad2: 0x%lx\n",*(ULONG *)&(MonI.pad[4]));
					printf("\tPad3: 0x%lx\n",*(ULONG *)&(MonI.pad[8]));
					printf("\tPad4: 0x%lx\n",*(ULONG *)&(MonI.pad[12]));
					printf("\tPad5: 0x%lx\n",*(ULONG *)&(MonI.pad[16]));
					printf("\tPad6: 0x%lx\n",*(ULONG *)&(MonI.pad[20]));
					printf("\tPad7: 0x%lx\n",*(ULONG *)&(MonI.pad[24]));
					printf("\tPad8: 0x%lx\n",*(ULONG *)&(MonI.pad[28]));
					printf("\tMouseTicks: (%d,%d)\n",MonI.MouseTicks.x,MonI.MouseTicks.y);
					printf("\tDefaultViewPosition: (%d,%d)\n",MonI.DefaultViewPosition.x,MonI.DefaultViewPosition.y);
					printf("\tPreferredModeID: 0x%lx\n",MonI.PreferredModeID);


					printf("\n"); 
					printf("MonitorSpec:\n"); 
					printf("\tratio: (%ld,%ld)\n",MonI.Mspc->ratioh,MonI.Mspc->ratiov);
					printf("\ttotal_rows: %d\n",MonI.Mspc->total_rows);
					printf("\ttotal_colorclocks: %d\n",MonI.Mspc->total_colorclocks);
					printf("\tDeniseMaxDisplayColumn: %d\n",MonI.Mspc->DeniseMaxDisplayColumn);
					printf("\tBeamCon0: 0x%x\n",MonI.Mspc->BeamCon0);
					printf("\tmin_row: %d\n",MonI.Mspc->min_row);
					printf("\tms_OpenCount: %d\n",MonI.Mspc->ms_OpenCount);
					printf("\tms_transform: 0x%lx\n",MonI.Mspc->ms_transform);
					printf("\tms_translate: 0x%lx\n",MonI.Mspc->ms_translate);
					printf("\tms_scale: 0x%lx\n",MonI.Mspc->ms_scale);
					printf("\tms_offset: (%d,%d)\n",MonI.Mspc->ms_xoffset,MonI.Mspc->ms_yoffset);
					rec = &(MonI.Mspc->ms_LegalView);
					printf("\tms_LegalView: (%d,%d) -> (%d,%d)\n",rec->MinX,rec->MinY,rec->MaxX,rec->MaxY);
					printf("\tms_maxoscan: 0x%lx\n",MonI.Mspc->ms_maxoscan);
					printf("\tms_videoscan: 0x%lx\n",MonI.Mspc->ms_videoscan);
					printf("\tDeniseMinDisplayColumn: %d\n",MonI.Mspc->DeniseMinDisplayColumn);
					printf("\tms_MrgCop: 0x%lx\n",MonI.Mspc->ms_MrgCop);
					printf("\tms_LoadView: 0x%lx\n",MonI.Mspc->ms_LoadView);
					printf("\tms_KillView: 0x%lx\n",MonI.Mspc->ms_KillView);
				}else{
					printf("no NameInfo\n");
				}

			}else{
				printf("no MonitorInfo\n");
			}

		}else{
			printf("no DimensionInfo\n");
		}

	}else{
		printf("no DisplayInfo\n");
	}
}
