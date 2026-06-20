/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    gadgets.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Oct-93
    Modified: 30-Sep-95
    NO TABS
    _______________________________________________________________________
*/
#ifndef ABACKUP_GADGETS_H
#define ABACKUP_GADGETS_H

struct Gadget *GList = NULL,
	      **Gads = NULL;

struct TagItem GATags[] = {{GT_Underscore,	'_'          },
			   {TAG_DONE}},
	       NMTags[] = {{GTNM_Border,	TRUE	     },
			   {GTNM_Justification, GTJ_RIGHT    },
			   {GTNM_Clipped,	TRUE	     },
			   {TAG_DONE}},
	       TXTags[] = {{GTTX_Border,	TRUE	     },
			   {TAG_DONE}},
	       TRTags[] = {{GTTX_Justification, GTJ_RIGHT    },
			   {GTTX_Clipped,	TRUE	     },
			   {TAG_MORE,		(ULONG)TXTags}},
	       TCTags[] = {{GTTX_Justification, GTJ_CENTER    },
			   {GTTX_Clipped,	TRUE	     },
			   {TAG_MORE,		(ULONG)TXTags}};
//___________________________________________________________________ Main menu:

struct MinGadget MG_Main[] = {
 {6, 3,209,12,BUTTON_KIND,MSG_BACKUP_FILES     ,PLACETEXT_IN,GATags},
 {6,16,209,12,BUTTON_KIND,MSG_BACKUP_PARTITIONS,PLACETEXT_IN,GATags},
 {6,29,209,12,BUTTON_KIND,MSG_RESTORE	       ,PLACETEXT_IN,GATags},
 {6,42,209,12,BUTTON_KIND,MSG_VERIFY	       ,PLACETEXT_IN,GATags},
 {6,55,209,12,BUTTON_KIND,MSG_REBUILD_CATALOG  ,PLACETEXT_IN,GATags},
 {6,73,209,12,BUTTON_KIND,MSG_PREFERENCES      ,PLACETEXT_IN,GATags}
};
//________________________________________________ Load Tree and Catalog window:

struct TagItem TXTreeStatus[] = {{GTTX_Text,	      NULL	},
				 {GTTX_Justification, GTJ_CENTER},
				 {GTTX_Clipped,       TRUE	},
				 {TAG_DONE}},
	       TXDirTree[]    = {{GTTX_Text, NULL		},
				 {TAG_MORE,  (ULONG)TXTags      }};
struct MinGadget MG_LoadTree[] = {
 { 6, 3,270,12,TEXT_KIND  ,MSG_VOID ,PLACETEXT_ABOVE,TXTreeStatus},
 { 6,15,270,12,TEXT_KIND  ,MSG_VOID ,PLACETEXT_ABOVE,TXDirTree	 },
 {97,33, 87,12,BUTTON_KIND,MSG_ABORT,PLACETEXT_IN   ,GATags	 }
};
//_________________________________________________________ Informations window:

TEXT TFiles[20],TBytes[20];

struct TagItem TXSource[]   = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TXTags   }},
	       TXFiles[]    = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TRTags   }},
	       TXSize[]     = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TRTags   }},
	       TXDate[]     = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TCTags   }},
	       TXTime[]     = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TCTags   }},
	       TXCompress[] = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TXTags   }},
	       TXComment[]  = {{GTTX_Text,	    NULL	    },
			       {TAG_MORE,	    (ULONG)TXTags   }};

struct MinGadget MG_Infos[] = {
 {118, 3,292,12,TEXT_KIND  ,MSG_SOURCE	      ,PLACETEXT_LEFT,TXSource	},
 {118,16,112,12,TEXT_KIND  ,MSG_FILES	      ,PLACETEXT_LEFT,TXFiles	},
 {118,29,112,12,TEXT_KIND  ,MSG_BACKUP_SIZE   ,PLACETEXT_LEFT,TXSize	},
 {322,16, 88,12,TEXT_KIND  ,MSG_BACKUP_DATE   ,PLACETEXT_LEFT,TXDate	},
 {322,29, 88,12,TEXT_KIND  ,MSG_BACKUP_TIME   ,PLACETEXT_LEFT,TXTime	},
 {118,42,292,12,TEXT_KIND  ,MSG_COMPRESSION   ,PLACETEXT_LEFT,TXCompress},
 {118,55,292,12,TEXT_KIND  ,MSG_BACKUP_COMMENT,PLACETEXT_LEFT,TXComment },
 {  6,73, 87,12,BUTTON_KIND,MSG_CONTINUE      ,PLACETEXT_IN  ,GATags	},
 {323,73, 87,12,BUTTON_KIND,MSG_ABORT	      ,PLACETEXT_IN  ,GATags	}
};
//____________________________________________________________ Selection window:

STRPTR Filter[] = {(STRPTR)MSG_INCLUDE,(STRPTR)MSG_EXCLUDE,NULL};

struct TagItem TXBytes[]     = {{GTTX_Text,    NULL		},
				{TAG_DONE}},
	       TXDir[]	     = {{GTTX_Text,    NULL		},
				{GTTX_Border,  TRUE		},
				{TAG_DONE}},
	       CYFilter[]    = {{GTCY_Labels,  (ULONG)&Filter[0]},
				{GTCY_Active,  0L		},
				{TAG_MORE,     (ULONG)GATags    }},
	       CBRecursive[] = {{GTCB_Checked, TRUE		},
				{GTCB_Scaled,  TRUE		},
				{TAG_MORE,     (ULONG)GATags    }},
	       BUByDate[]    = {{GA_Disabled,  TRUE		},
				{TAG_MORE,     (ULONG)GATags    }},
	       BUByBits[]    = {{GA_Disabled,  TRUE		},
				{TAG_MORE,     (ULONG)GATags    }},
	       BURoot[]      = {{GA_Disabled,  TRUE		},
				{TAG_MORE,     (ULONG)GATags    }},
	       BUParent[]    = {{GA_Disabled,  TRUE		},
				{TAG_MORE,     (ULONG)GATags    }},
	       SCFileList[]  = {{GA_Immediate, TRUE		},
				{GTSC_Top,     0L		},
				{GTSC_Total,   0L		},
				{GTSC_Visible, 0L		},
				{GTSC_Arrows,  9L		},
				{PGA_Freedom,  LORIENT_VERT	},
				{TAG_DONE}};

struct MinGadget MG_Selection[] = {
 {102,	3,112, 12,TEXT_KIND    ,NULL	     ,PLACETEXT_LEFT ,TXFiles	 },
 {102, 16,112, 12,TEXT_KIND    ,MSG_SIZE     ,PLACETEXT_LEFT ,TXSize	 },
 {218, 16, 86, 12,TEXT_KIND    ,MSG_VOID     ,0 	     ,TXBytes	 },
 {102, 29,433, 12,TEXT_KIND    ,MSG_DIRECTORY,PLACETEXT_LEFT ,TXDir	 },

 {304, 17, 26, 11,CHECKBOX_KIND,MSG_RECURSIVE,PLACETEXT_RIGHT,CBRecursive},

 {304,	3,140, 13,CYCLE_KIND   ,MSG_FILTER   ,PLACETEXT_LEFT ,CYFilter	 },

 {448,	3, 87, 12,BUTTON_KIND  ,MSG_ALL      ,PLACETEXT_IN   ,GATags	 },
 {448, 16, 87, 12,BUTTON_KIND  ,MSG_REVERSE  ,PLACETEXT_IN   ,GATags	 },

 {539,	3, 87, 12,BUTTON_KIND  ,MSG_BYNAME   ,PLACETEXT_IN   ,GATags	 },
 {539, 16, 87, 12,BUTTON_KIND  ,MSG_BYDATE   ,PLACETEXT_IN   ,BUByDate	 },
 {539, 29, 87, 12,BUTTON_KIND  ,MSG_BYBITS   ,PLACETEXT_IN   ,BUByBits	 },

 {  6, 47, 87, 12,BUTTON_KIND  ,MSG_ROOT     ,PLACETEXT_IN   ,BURoot	 },
 { 94, 47,532, 12,BUTTON_KIND  ,MSG_PARENT   ,PLACETEXT_IN   ,BUParent	 },
 {608, 59, 18,152,SCROLLER_KIND,MSG_VOID     ,0 	     ,SCFileList },

 {  6,217, 87, 12,BUTTON_KIND  ,MSG_VOID     ,PLACETEXT_IN   ,GATags	 },
 {224,217,209, 12,BUTTON_KIND  ,MSG_PREFERENCES,PLACETEXT_IN ,GATags	 },
 {539,217, 87, 12,BUTTON_KIND  ,MSG_CANCEL   ,PLACETEXT_IN   ,GATags	 }
};

//______________________________________________________________ Monitor window:

struct TagItem TXGauge[] = {{GTTX_Justification, GTJ_CENTER   },
			    {GTTX_Clipped,	 TRUE	      },
			    {TAG_MORE,		 (ULONG)TXTags}};

struct TagItem TXSavedFiles[]  = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TRTags }},
	       TXLeftFiles[]   = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TRTags }},
	       TXDestination[] = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TXTags }},
	       TXSavedSize[]   = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TRTags }},
	       TXLeftSize[]    = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TRTags }},
	       TXSavedBytes[]  = {{GTTX_Text,	NULL	      },
				  {TAG_DONE}},
	       TXLeftBytes[]   = {{GTTX_Text,	NULL	      },
				  {TAG_DONE}},
	       TXSavedGauge[]  = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TXGauge}},
	       TXLeftGauge[]   = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TXGauge}},
	       TXCompGauge[]   = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TXGauge}},
	       TXDiskGauge[]   = {{GTTX_Text,	NULL	      },
				  {TAG_MORE,	(ULONG)TXGauge}},
	       TXReport[]      = {{GTTX_Text,	NULL	      },
				  {GTTX_Border, TRUE	      },
				  {TAG_DONE}},
	       NMDiskNumber[]  = {{GTNM_Number, NULL	      },
				  {TAG_MORE,	(ULONG)NMTags }};

struct MinGadget MG_Monitor[] = {
 {126,	3, 87,12,TEXT_KIND  ,MSG_VOID	    ,PLACETEXT_LEFT ,TXSavedFiles },
 {126, 16, 87,12,TEXT_KIND  ,MSG_LEFT	    ,PLACETEXT_LEFT ,TXLeftFiles  },
 {126, 29, 87,12,NUMBER_KIND,MSG_DISKNUMBER ,PLACETEXT_LEFT ,NMDiskNumber },
 {126, 42,314,12,TEXT_KIND  ,NULL	    ,PLACETEXT_LEFT ,TXDestination},

 {215,	3,112,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXSavedSize  },
 {215, 16,112,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXLeftSize   },
 {215, 29,112,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXTime	  },

 {331,	3, 86,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXSavedBytes },
 {331, 16, 86,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXLeftBytes  },

 {442,	3,184,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXSavedGauge },
 {442, 16,184,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXLeftGauge  },
 {442, 29,184,12,TEXT_KIND  ,MSG_COMPRESSION,PLACETEXT_LEFT ,TXCompGauge  },
 {442, 42,184,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXDiskGauge  },

 { 95,217,442,12,TEXT_KIND  ,MSG_VOID	    ,0		    ,TXReport	  },

 {  6,217, 87,12,BUTTON_KIND,MSG_PAUSE	    ,PLACETEXT_IN   ,GATags	  },
 {539,217, 87,12,BUTTON_KIND,MSG_ABORT	    ,PLACETEXT_IN   ,GATags	  }
};

//_______________________________________________________________ ArcReq window:

STRPTR DevsLb[] =
{
  (STRPTR)MSG_ARC_FROM_DEVICE,
  (STRPTR)MSG_ARC_FROM_FILE,
  (STRPTR)MSG_ARC_FROM_TAPE,
  NULL
} ;

struct TagItem	STTags[] = { { GTST_MaxChars,	 256L } ,
			     { TAG_MORE,	 (ULONG)GATags } },
		LVTags[] = { { GTLV_ScrollWidth, 18L } ,
			     { LAYOUTA_Spacing,  1L  } ,
			     { TAG_MORE,	 (ULONG)GATags } },
		CYDevs[] = { { GTCY_Labels,	 (ULONG)&DevsLb[0] } ,
			     { GTCY_Active,	 0L } ,
			     { TAG_MORE,	 (ULONG)GATags } } ,
		LVDLst[] = { { GA_Disabled,	 FALSE } ,
			     { GTLV_Labels,	 NULL  } ,
			     { TAG_MORE,	 (ULONG)LVTags } },
		LVDevs[] = { { GA_Disabled,	 FALSE } ,
			     { GTLV_Labels,	 NULL  } ,
			     { TAG_MORE,	 (ULONG)LVTags } },
		CBCatF[] = { { GTCB_Checked,	 FALSE } ,
			     { GTCB_Scaled,	 TRUE  } ,
			     { TAG_MORE,	 (ULONG)GATags } },
		STArcF[] = { { GA_Disabled,	 FALSE } ,
			     { GTST_String,	 NULL  } ,
			     { TAG_MORE,	 (ULONG)STTags } } ;

struct MinGadget MG_ArcReq[] =
{
 {140,	4,256,13,CYCLE_KIND   ,MSG_ARC_TYPE   ,PLACETEXT_LEFT ,CYDevs },
 {140, 17,128,40,LISTVIEW_KIND,MSG_VOID       ,NULL	      ,LVDLst },
 {268, 17,128,40,LISTVIEW_KIND,MSG_VOID       ,NULL	      ,LVDevs },
 {140, 58,234,14,STRING_KIND  ,MSG_ARC_FILE   ,PLACETEXT_LEFT ,STArcF },
 {376, 58, 20,14,GENERIC_KIND ,MSG_VOID       ,NULL	      ,NULL   },
 { 16, 70, 26,11,CHECKBOX_KIND,MSG_ARC_CATFILE,PLACETEXT_RIGHT,CBCatF },
 {  6, 88, 87,12,BUTTON_KIND  ,MSG_OK	      ,PLACETEXT_IN   ,GATags },
 {320, 88, 87,12,BUTTON_KIND  ,MSG_CANCEL     ,PLACETEXT_IN   ,GATags }
} ;

//__________________________________________________________________ BevelBoxes:

struct BBox MainBox[]	   =  {{0,  0,221, 70,FALSE},
			       {0, 70,221, 18,FALSE}},
	    LoadTreeBox[]  =  {{0,  0,282, 30,FALSE},
			       {0, 30,282, 18,FALSE}},
	    InfosBox[]	   =  {{0,  0,416, 70,FALSE},
			       {0, 70,416, 18,FALSE}},
	    SelectionBox[] =  {{0,  0,632, 44,FALSE},
			       {0, 44,632,170,FALSE},
			       {0,214,632, 18,FALSE},
			       {6, 59,602,152,FALSE}},
	    MonitorBox[]   =  {{0,  0,632, 57,FALSE},
			       {0, 57,632,157,FALSE},
			       {0,214,632, 18,FALSE},
			       {6, 60,620,151,TRUE }},
	    ArcReqBox[]    =  {{0,  0,414, 70,FALSE},
			       {0, 70,414, 18,FALSE},
			       {0, 88,414, 18,FALSE}};


#endif // ABACKUP_GADGETS_H
