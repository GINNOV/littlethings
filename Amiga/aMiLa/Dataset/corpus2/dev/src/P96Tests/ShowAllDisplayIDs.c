/*
	This program shows how the DisplayInfoDataBase is built and
	which modes exist.
	
	by Tobias Abt
	Wed May 19 13:25:18 1999
*/

#include <utility/tagitem.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <proto/graphics.h>
#include <proto/utility.h>

#include <stdio.h>


/* Private format of the entries in the DisplayInfoDataBase.
	This private design is used in Kickstart 3.0 and 3.1.

	The database is built in a three level design:

	The top database node is being pointed to by GfxBase->DisplayInfoDataBase.
	From there the Child pointer leads to the node of the first monitor,
	usually the default monitor. The other fields are not used.

	All monitors (e.g. PAL, NTSC, MULTISYNC) are linked together via the Pred
	and Succ pointers. Each monitor database node Child field points to the
	start of its own database that contains members for each existing DisplayID.
	The Father field points back to the top level database entry.
	The ID field contains the monitor id for that monitor (e.g. NTSC=1, PAL=2).
	The MoreData tag leads to the display info that is specific to all display
	ids of that monitor: the MonitorInfo.

	Each display id has its own database node in the bottom level under its
	monitor, all ids of one monitor are linked via Succ and Pred; Child is
	NULL and Father points back to the monitor database node. ID contains the
	DisplayID for which this database node holds the information and MoreData
	links the display infos DisplayInfo, DimensionInfo, NameInfo (where
	available, does not exist for all DisplayIDs, especially not for those that
	normally don't appear in ScreenMode requesters, like e.g. DualPF modes) and
	VecInfo.
	
	BTW, when you call FindDisplayInfo(ID), you get a pointer to the database
	node of that DisplayID (ground floor).
	
	Warning: not all fields of the display info you find this way look like
	those you get when calling GetDisplayInfoData. Some values are uncooked
	and get evaluated by GetDisplayInfoData when filling your buffer.
*/

struct DataBase {
	struct DataBase	*Succ;
	struct DataBase	*Pred;
	struct DataBase	*Child;
	struct DataBase	*Father;
	ULONG					ID;
	struct TagItem		MoreData;	// ti_Tag = TAG_END or TAG_MORE, ti_Data = Pointer to Info structs
	ULONG					Modes;		// Mode flags for this Display
	ULONG					pad[2];
	struct Rectangle	Dims;
	ULONG					pad2[2];
};

int main(void)
{
	{
		struct DataBase *tldb = GfxBase->DisplayInfoDataBase;
		struct DataBase *fldb, *db;

		for(fldb = tldb->Child; fldb; fldb = fldb->Succ){
			struct TagItem *fltag, *fltstate;
			char *temp;

			printf("%08lx @ %08lx\n", fldb->ID, fldb);
			fltstate = &fldb->MoreData;
			while(fltag = NextTagItem(&fltstate)){
				if(fltag->ti_Tag == DTAG_MNTR){
					temp = "DTAG_MNTR";
				}else{
					temp = "unknown";
				}
				printf("      Tag: %08lx (%s) ID: %08lx\n", fltag->ti_Tag, temp, fltag->ti_Data);
				if(fltag->ti_Tag == DTAG_MNTR){
					struct MonitorInfo *mi = (struct MonitorInfo *)fltag;
					struct MonitorSpec *ms = mi->Mspc;
					if(ms && (ms->ms_Node.xln_Library == (void *)GfxBase)){
						printf("      belongs to graphics.library!\n");
					}else if(ms){
						printf("      xln_Library: %08lx\n", ms->ms_Node.xln_Library);
					}else{
						printf("      no MonitorSpec!\n");
					}
				}
			}
			for(db = fldb->Child; db; db = db->Succ){
				struct TagItem *tag, *tstate;

				printf("   %08lx @ %08lx\n", db->ID, db);
				tstate = &db->MoreData;
				while(tag = NextTagItem(&tstate)){
					switch(tag->ti_Tag){
						case	DTAG_DISP:
							temp = "DTAG_DISP";
							break;
						case	DTAG_DIMS:
							temp = "DTAG_DIMS";
							break;
						case	DTAG_NAME:
							temp = "DTAG_NAME";
							break;
						case	DTAG_VEC:
							temp = "DTAG_VEC";
							break;
						default:
							temp = "unknown";
							break;
					}
					printf("      Tag: %08lx (%s) ID: %08lx\n", tag->ti_Tag, temp, tag->ti_Data);
					if(tag->ti_Tag == DTAG_DISP){
						printf("      %savailable: %04lx\n", ((struct DisplayInfo *)tag)->NotAvailable ? "not " : "", ((struct DisplayInfo *)tag)->NotAvailable);
					}
				}
			}
		}
	}
}
