#include <exec/types.h>

#include <exec/execbase.h>

#include <graphics/view.h>
#include <graphics/gfxbase.h>
#include <graphics/displayinfo.h>

#define __USE_SYSBASE
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/dos.h>

#include <stdio.h>

struct DataBase {
	struct DataBase	*Succ;
	struct DataBase	*Pred;
	struct DataBase	*Child;
	struct DataBase	*Father;
	ULONG					ID;
	struct TagItem		MoreData;	// ti_Tag = TAG_END or TAG_MORE, ti_Data = Pointer to Info structs
//	ULONG					Type;
//	ULONG					**Info;
	ULONG					SubID;
};

void ScanEntry(struct DataBase *db);

int Depth=0;
char Spaces[]="         ";

int main(int argc, char ** argv){
	struct DataBase *gdb;
	for(gdb=(struct DataBase *)GfxBase->DisplayInfoDataBase;gdb;gdb=gdb->Succ){
		ScanEntry(gdb);
	}
}

void ScanEntry(struct DataBase *db)
{
	struct DataBase *sdb;
	Depth++;
//	printf("%sLevel %d: ID %08lx - SubID %08lx\n",&Spaces[9-3*(Depth-1)],Depth,db->ID,db->SubID);
	if(db->MoreData.ti_Tag==TAG_MORE){
		struct TagItem *ti=(struct TagItem *)db->MoreData.ti_Data;
		for(;ti->ti_Tag;){
			if(ti->ti_Tag==TAG_MORE){
				ti=(struct TagItem *)ti->ti_Data;
			}else if(ti->ti_Tag==TAG_SKIP){
				ti+=ti->ti_Data+1;
			}else{
//				printf("%sTag %08lx - Data %08lx\n",&Spaces[6-3*(Depth-1)],ti->ti_Tag,ti->ti_Data);
				switch(ti->ti_Tag){
					case DTAG_DISP:
//						printf("%s%s:\n",&Spaces[6-3*(Depth-1)],"DisplayInfo");
						break;
					case DTAG_DIMS:
//						printf("%s%s:\n",&Spaces[6-3*(Depth-1)],"DimensionInfo");
						break;
					case DTAG_MNTR:
						printf("%s%s: %s %ldx%ld\n",&Spaces[6-3*(Depth-1)],"MonitorInfo",
								((struct MonitorInfo *)(&(ti->ti_Tag)))->Mspc->ms_Node.xln_Name,
								((struct Rect32 *)&(((struct MonitorInfo *)(&(ti->ti_Tag)))->pad))->MaxX,
								((struct Rect32 *)&(((struct MonitorInfo *)(&(ti->ti_Tag)))->pad))->MaxY);
						break;
					case DTAG_NAME:
//						printf("%s%s: %s\n",&Spaces[6-3*(Depth-1)],"NameInfo",
//								((UBYTE *)&(((struct NameInfo *)(&(ti->ti_Tag)))->Name)));
						break;
					case DTAG_VEC:
//						printf("%s%s:\n",&Spaces[6-3*(Depth-1)],"VecInfo");
						break;
					default:
//						printf("%s%s:\n",&Spaces[6-3*(Depth-1)],"Unknown");
						break;
				}
				ti++;
			}
		}
	}
/*
	if(db->Info)
		printf("%sInfo  %08lx %08lx %08lx %08lx\n"
				,&Spaces[9-3*(Depth-1)],db->Info[0],db->Info[1],db->Info[2],db->Info[3]);
*/
	if(Depth < 2){
		for(sdb=db->Child;sdb;sdb=sdb->Succ){
			ScanEntry(sdb);
		}
	}
	Depth--;
}
