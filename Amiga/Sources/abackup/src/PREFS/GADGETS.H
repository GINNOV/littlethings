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
#ifndef ABPREFS_GADGETS_H
#define ABPREFS_GADGETS_H
/*      ___________________

	ABackup Prefs
	gadgets.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 13-Aug-93
	Modified: 18-Jan-98
	___________________
*/

struct Gadget   *GList = NULL,
				**Gads = NULL;

// shared strings and tag items:
STRPTR  RpToLb[] = {(STRPTR)MSG_PRINTER,
					(STRPTR)MSG_FILE,
					NULL},
		RpTpLb[] = {(STRPTR)MSG_SHORT,
					(STRPTR)MSG_LONG,
					NULL};

struct TagItem  GATags[] = {{GT_Underscore,     		'_'     			},
							{TAG_DONE}},
				CBTags[] = {{GTCB_Scaled,       		TRUE    		},
							{TAG_MORE,      			(ULONG)GATags   }},
				SLTags[] = {{GTSL_LevelPlace,   	PLACETEXT_RIGHT },
							{GA_RelVerify,  		TRUE    		},
							{TAG_MORE,      			(ULONG)GATags   }},
				INTags[] = {{STRINGA_Justification,     STRINGRIGHT     	},
							{TAG_MORE,      			(ULONG)GATags   }},
				STTags[] = {{GTST_MaxChars,     		256L    		},
							{TAG_MORE,      			(ULONG)GATags   }},
				TXTags[] = {{GTTX_Border,       		TRUE    		},
							{TAG_DONE}},
				LVTags[] = {{GTLV_ScrollWidth,  	18L     			},
							{LAYOUTA_Spacing,       	1L      			},
							{TAG_MORE,      			(ULONG)GATags   }};
//_________________________________________________________________ Main window:

STATIC struct MinGadget MGMain[] = {
 {  4,61, 87,12,BUTTON_KIND,MSG_SAVE    		,PLACETEXT_IN,GATags},
 {160,61, 87,12,BUTTON_KIND,MSG_USE     			,PLACETEXT_IN,GATags},
 {311,61, 87,12,BUTTON_KIND,MSG_CANCEL  		,PLACETEXT_IN,GATags},

 { 10, 5,190,12,BUTTON_KIND,MSG_BACKUP  		,PLACETEXT_IN,GATags},
 { 10,18,190,12,BUTTON_KIND,MSG_RESTORE 		,PLACETEXT_IN,GATags},
 { 10,31,190,12,BUTTON_KIND,MSG_VERIFY  		,PLACETEXT_IN,GATags},
 { 10,44,190,12,BUTTON_KIND,MSG_COMPRESSION     	,PLACETEXT_IN,GATags},

 {202, 5,190,12,BUTTON_KIND,MSG_TAPE    		,PLACETEXT_IN,GATags},
 {202,18,190,12,BUTTON_KIND,MSG_GUI     			,PLACETEXT_IN,GATags},
 {202,31,190,12,BUTTON_KIND,MSG_EXTERNAL_PROGS  ,PLACETEXT_IN,GATags},
 {202,44,190,12,BUTTON_KIND,MSG_MISCELLANEOUS   ,PLACETEXT_IN,GATags}
};
//_____________________________________________________________________ Devices:

STRPTR  DevsLb[] = {(STRPTR)MSG_TO_DEVICE,
					(STRPTR)MSG_TO_FILE,
					(STRPTR)MSG_TO_TAPE,
					NULL};

struct TagItem  CYDevs[] = {{GTCY_Labels,       	(ULONG)&DevsLb[0]       },
							{GTCY_Active,   	0L      				},
							{TAG_MORE,      		(ULONG)GATags   	}},
				LVDLst[] = {{GA_Disabled,       	FALSE   			},
							{GTLV_Labels,   	NULL    			},
							{TAG_MORE,      		(ULONG)LVTags   	}},
				LVDevs[] = {{GA_Disabled,       	FALSE   			},
							{GTLV_Labels,   	NULL    			},
							{TAG_MORE,      		(ULONG)LVTags   	}},
				STArcF[] = {{GA_Disabled,       	FALSE   			},
							{GTST_String,   	NULL    			},
							{TAG_MORE,      		(ULONG)STTags   	}};
//______________________________________________________________ Backup options:

struct TagItem  SLBuff[] = {{GTSL_Min,  		32L     				},
							{GTSL_Max,      		NULL    			},
							{GTSL_Level,    	NULL    			},
							{GTSL_LevelFormat,      NULL    			},
							{GTSL_MaxLevelLen,      16L     				},
							{TAG_MORE,      		(ULONG)SLTags   	}},
				STLogF[] = {{GTST_String,       	NULL    			},
							{TAG_MORE,      		(ULONG)STTags   	}},
				STDCom[] = {{GA_Disabled,       	FALSE   			},
							{GTST_String,   	NULL    			},
							{GTST_MaxChars, 	80L     				},
							{TAG_MORE,      		(ULONG)GATags   	}},
				CBBRep[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CYBRTo[] = {{GA_Disabled,       	TRUE    			},
							{GTCY_Labels,   	(ULONG)&RpToLb[0]       },
							{GTCY_Active,   	0L      				},
							{TAG_DONE}},
				CYBRTp[] = {{GA_Disabled,       	TRUE    			},
							{GTCY_Labels,   	(ULONG)&RpTpLb[0]       },
							{GTCY_Active,   	1L      				},
							{TAG_DONE}},
				CBVeri[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBTask[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBBLnk[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBAddC[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBAddI[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBComp[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBCCat[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBCrpt[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBABit[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBDupC[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}},
				CBIgnS[] = {{GTCB_Checked,      	FALSE   			},
							{TAG_MORE,      		(ULONG)CBTags   	}};

STATIC struct MinGadget MGBackup[] = {
 {  4,159, 87,12,BUTTON_KIND    ,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {541,159, 87,12,BUTTON_KIND    ,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 {152,  8,256,13,CYCLE_KIND     	,MSG_BACKUP_TO  	,PLACETEXT_LEFT ,CYDevs },
 {152, 21,128,40,LISTVIEW_KIND  ,MSG_DEVICES    	,PLACETEXT_LEFT ,LVDLst },
 {280, 21,128,40,LISTVIEW_KIND  ,MSG_VOID       		,NULL   		,LVDevs },
 {152, 62,234,14,STRING_KIND    ,MSG_ARCHIVE_FILE       ,PLACETEXT_LEFT ,STArcF },
 {388, 62, 20,14,GENERIC_KIND   ,MSG_VOID       		,NULL   		,NULL   },

 {152, 84,127,11,SLIDER_KIND    ,MSG_BUFFER_SIZE	,PLACETEXT_LEFT ,SLBuff },
 {152, 96,234,14,STRING_KIND    ,MSG_LOG_FILE   	,PLACETEXT_LEFT ,STLogF },
 {388, 96, 20,14,GENERIC_KIND   ,MSG_VOID       		,NULL   		,NULL   },
 {152,111,256,14,STRING_KIND    ,MSG_DEFAULT_COMMENT,PLACETEXT_LEFT     ,STDCom },

 { 16,128, 26,11,CHECKBOX_KIND  ,MSG_REPORT     		,PLACETEXT_RIGHT,CBBRep },
 {152,126,127,13,CYCLE_KIND     	,MSG_VOID       		,NULL   		,CYBRTo },
 {281,126,127,13,CYCLE_KIND     	,MSG_VOID       		,NULL   		,CYBRTp },

 {424,  8, 26,11,CHECKBOX_KIND  ,MSG_BACKUP_VERIFY      ,PLACETEXT_RIGHT,CBVeri },
 {424, 20, 26,11,CHECKBOX_KIND  ,MSG_CHILD_TASK 	,PLACETEXT_RIGHT,CBTask },
 {424, 32, 26,11,CHECKBOX_KIND  ,MSG_BACKUP_LINKS       ,PLACETEXT_RIGHT,CBBLnk },
 {424, 44, 26,11,CHECKBOX_KIND  ,MSG_ADD_COMMENT	,PLACETEXT_RIGHT,CBAddC },
 {424, 56, 26,11,CHECKBOX_KIND  ,MSG_ADD_ICON   	,PLACETEXT_RIGHT,CBAddI },
 {424, 68, 26,11,CHECKBOX_KIND  ,MSG_COMPRESS   	,PLACETEXT_RIGHT,CBComp },
 {424, 80, 26,11,CHECKBOX_KIND  ,MSG_COMPRESS_CAT       ,PLACETEXT_RIGHT,CBCCat },
 {424, 92, 26,11,CHECKBOX_KIND  ,MSG_ENCRYPT    	,PLACETEXT_RIGHT,CBCrpt },
 {424,104, 26,11,CHECKBOX_KIND  ,MSG_SET_ARCHIVE_BIT    ,PLACETEXT_RIGHT,CBABit },
 {424,116, 26,11,CHECKBOX_KIND  ,MSG_DUP_CATALOG	,PLACETEXT_RIGHT,CBDupC },
 {424,128, 26,11,CHECKBOX_KIND  ,MSG_IGNORE_SKIPME      ,PLACETEXT_RIGHT,CBIgnS }
};
//_____________________________________________________________ Restore options:

STRPTR  ExiFLb[] = {(STRPTR)MSG_ALWAYS_REPLACE,
					(STRPTR)MSG_NEVER_REPLACE,
					(STRPTR)MSG_ASK_REPLACE,
					(STRPTR)MSG_REPLACE_OLDEST,
					(STRPTR)MSG_RENAME_FILE,
					NULL},
		BadFLb[]  = {(STRPTR)MSG_ALWAYS_DELETE,
					(STRPTR)MSG_NEVER_DELETE,
					(STRPTR)MSG_ASK_DELETE,
					NULL};

struct TagItem  STRtTo[] = {{GTST_String,       NULL    			},
							{TAG_MORE,      	(ULONG)STTags   	}},
				CYExiF[] = {{GTCY_Labels,       (ULONG)&ExiFLb[0]       },
							{GTCY_Active,   1L      				},
							{TAG_MORE,      	(ULONG)GATags   	}},
				CYBadF[] = {{GTCY_Labels,       (ULONG)&BadFLb[0]       },
							{GTCY_Active,   0L      				},
							{TAG_MORE,      	(ULONG)GATags   	}},
				CBRRep[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CYRRTo[] = {{GA_Disabled,       TRUE    			},
							{GTCY_Labels,   (ULONG)&RpToLb[0]       },
							{GTCY_Active,   0L      				},
							{TAG_DONE}},
				CYRRTp[] = {{GA_Disabled,       TRUE    			},
							{GTCY_Labels,   (ULONG)&RpTpLb[0]       },
							{GTCY_Active,   1L      				},
							{TAG_DONE}},
				CBTree[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CBDate[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CBRLnk[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CBEmpt[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CBCatF[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}};

STATIC struct MinGadget MGRestore[] = {
 {  4,155, 87,12,BUTTON_KIND    ,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {541,155, 87,12,BUTTON_KIND    ,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 {152,  8,256,13,CYCLE_KIND     	,MSG_RESTORE_FROM       ,PLACETEXT_LEFT ,CYDevs },
 {152, 21,128,40,LISTVIEW_KIND  ,MSG_DEVICES    	,PLACETEXT_LEFT ,LVDLst },
 {280, 21,128,40,LISTVIEW_KIND  ,MSG_VOID       		,NULL   		,LVDevs },
 {152, 62,234,14,STRING_KIND    ,MSG_ARCHIVE_FILE       ,PLACETEXT_LEFT ,STArcF },
 {388, 62, 20,14,GENERIC_KIND   ,MSG_VOID       		,NULL   		,NULL   },

 {152, 84,234,14,STRING_KIND    ,MSG_RESTORE_TO 	,PLACETEXT_LEFT ,STRtTo },
 {388, 84, 20,14,GENERIC_KIND   ,MSG_VOID       		,NULL   		,NULL   },

 {152,106,256,13,CYCLE_KIND     	,MSG_EXISTING_FILES     ,PLACETEXT_LEFT ,CYExiF },
 {152,120,256,13,CYCLE_KIND     	,MSG_BAD_FILES  	,PLACETEXT_LEFT ,CYBadF },

 { 16,136, 26,11,CHECKBOX_KIND  ,MSG_REPORT     		,PLACETEXT_RIGHT,CBRRep },
 {152,134,127,13,CYCLE_KIND     	,MSG_VOID       		,NULL   		,CYRRTo },
 {281,134,127,13,CYCLE_KIND     	,MSG_VOID       		,NULL   		,CYRRTp },

 {424,  8, 26,11,CHECKBOX_KIND  ,MSG_TREE       		,PLACETEXT_RIGHT,CBTree },
 {424, 20, 26,11,CHECKBOX_KIND  ,MSG_RESTORE_DATE       ,PLACETEXT_RIGHT,CBDate },
 {424, 32, 26,11,CHECKBOX_KIND  ,MSG_RESTORE_LINKS      ,PLACETEXT_RIGHT,CBRLnk },
 {424, 44, 26,11,CHECKBOX_KIND  ,MSG_EMPTY_DIRS 	,PLACETEXT_RIGHT,CBEmpt },
 {424, 56, 26,11,CHECKBOX_KIND  ,MSG_USE_CAT_FILE       ,PLACETEXT_RIGHT,CBCatF }
};
//______________________________________________________________ Verify options:

struct TagItem  CBVRep[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CYVRTo[] = {{GA_Disabled,       TRUE    			},
							{GTCY_Labels,   (ULONG)&RpToLb[0]       },
							{GTCY_Active,   0L      				},
							{TAG_DONE}},
				CYVRTp[] = {{GA_Disabled,       TRUE    			},
							{GTCY_Labels,   (ULONG)&RpTpLb[0]       },
							{GTCY_Active,   1L      				},
							{TAG_DONE}},
				CBVCom[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CBVSel[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				CBVIgD[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}};

STATIC struct MinGadget MGVerify[] = {
 {  4,60, 87,12,BUTTON_KIND     	,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {333,60, 87,12,BUTTON_KIND     	,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 { 16, 8, 26,11,CHECKBOX_KIND   ,MSG_REPORT     		,PLACETEXT_RIGHT,CBVRep },
 {152, 8,127,13,CYCLE_KIND      	,MSG_VOID       		,NULL   		,CYVRTo },
 {281, 8,127,13,CYCLE_KIND      	,MSG_VOID       		,NULL   		,CYVRTp },

 { 16,29, 26,11,CHECKBOX_KIND   ,MSG_COMPARE_DATA       ,PLACETEXT_RIGHT,CBVCom },
 { 16,41, 26,11,CHECKBOX_KIND   ,MSG_SELECT_FILES       ,PLACETEXT_RIGHT,CBVSel },
 {214,29, 26,11,CHECKBOX_KIND   ,MSG_IGNORE_DATE	,PLACETEXT_RIGHT,CBVIgD }
};
//_________________________________________________________ Compression options:

STRPTR  CompLb[] = {(STRPTR)MSG_INTERNAL,
					(STRPTR)MSG_EXTERNAL,
					(STRPTR)MSG_XPK_LIBRARY,
					NULL};

struct TagItem  CYComp[] = {{GTCY_Labels,       	(ULONG)&CompLb[0]       },
							{GTCY_Active,   	0L      				},
							{TAG_MORE,      		(ULONG)GATags   	}},
				LVXpk[]  = {{GA_Disabled,       	FALSE   			},
							{GTLV_Top,      		0       				},
							{GTLV_MakeVisible,      0       				},
							{GTLV_Labels,   	NULL    			},
							{GTLV_ShowSelected,     NULL    			},
							{GTLV_Selected, 	1L      				},
							{TAG_MORE,      		(ULONG)LVTags   	}},
				SLXMod[] = {{GA_Disabled,       	TRUE    			},
							{GTSL_Max,      		NULL    			},
							{GTSL_Level,    	NULL    			},
							{GTSL_LevelFormat,      (ULONG)"%3lu"   	},
							{GTSL_MaxLevelLen,      4L      				},
							{TAG_MORE,      		(ULONG)SLTags   	}},
				TXXMod[] = {{GTTX_Text, 		NULL    			},
							{TAG_MORE,      		(ULONG)TXTags   	}},
				TXXRat[] = {{GTTX_Text, 		NULL    			},
							{TAG_DONE}},
				TXXPSp[] = {{GTTX_Text, 		NULL    			},
							{TAG_DONE}},
				TXXUSp[] = {{GTTX_Text, 		NULL    			},
							{TAG_DONE}},
				STComp[] = {{GA_Disabled,       	TRUE    			},
							{GTST_String,   	NULL    			},
							{TAG_MORE,      		(ULONG)STTags   	}},
				STDcmp[] = {{GA_Disabled,       	TRUE    			},
							{GTST_String,   	NULL    			},
							{TAG_MORE,      		(ULONG)STTags   	}},
				LVCFlt[] = {{GTLV_Top,  		0       				},
							{GTLV_MakeVisible,      0       				},
							{GTLV_Labels,   	NULL    			},
							{GTLV_ShowSelected,     1L      				},
							{GTLV_Selected, 	~0      				},
							{TAG_MORE,      		(ULONG)LVTags   	}},
				STCFlt[] = {{GTST_MaxChars,     	32L     				},
							{TAG_MORE,      		(ULONG)GATags   	}};

struct MinGadget	MGCompress[] = {
 {  4,167, 87, 14,BUTTON_KIND   ,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {422,167, 87, 14,BUTTON_KIND   ,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 {127,  5,273, 14,CYCLE_KIND    ,MSG_COMPRESS_METHOD,PLACETEXT_LEFT     ,CYComp },

 {127, 23,267, 56,LISTVIEW_KIND ,MSG_XPK_LIBS   	,PLACETEXT_LEFT ,LVXpk  },
 {127, 73,130, 12,SLIDER_KIND   ,MSG_XPK_MODE   	,PLACETEXT_LEFT ,SLXMod },
 {294, 73,100, 12,TEXT_KIND     	,MSG_VOID       		,NULL   		,TXXMod },
 {311, 86, 79, 12,TEXT_KIND     	,MSG_COMPRESS_RATIO     ,NULL   		,TXXRat },
 {311, 98, 79, 12,TEXT_KIND     	,MSG_PACKING_SPEED      ,PLACETEXT_LEFT ,TXXPSp },
 {311,110, 79, 12,TEXT_KIND     	,MSG_UNPACKING_SPEED,PLACETEXT_LEFT     ,TXXUSp },

 {127,130,245, 14,STRING_KIND   ,MSG_EXTERNAL_COMP      ,PLACETEXT_LEFT ,STComp },
 {127,145,245, 14,STRING_KIND   ,MSG_EXTERNAL_DECOMP,PLACETEXT_LEFT     ,STDcmp },
 {374,130, 20, 14,GENERIC_KIND  ,MSG_VOID       		,NULL   		,NULL   },
 {374,145, 20, 14,GENERIC_KIND  ,MSG_VOID       		,NULL   		,NULL   },

 {410, 23, 87, 14,STRING_KIND   ,MSG_VOID       		,NULL   		,STCFlt },
 {410, 23, 87,128,LISTVIEW_KIND ,MSG_FILTER     		,PLACETEXT_ABOVE,LVCFlt },
 {410,145, 87, 14,BUTTON_KIND   ,MSG_DELETE     		,PLACETEXT_IN   ,GATags }
};
//________________________________________________________________ Tape options:

struct TagItem  STDevD[] = {{GTST_String,       NULL    		},
							{GTST_MaxChars, 30L     			},
							{TAG_MORE,      	(ULONG)GATags   }},
				INScsi[] = {{GTIN_Number,       NULL    		},
							{GTIN_MaxChars, 1L      			},
							{TAG_MORE,      	(ULONG)INTags   }},
				INBloc[] = {{GTIN_Number,       NULL    		},
							{GTIN_MaxChars, 5L      			},
							{TAG_MORE,      	(ULONG)INTags   }},
				CBRwnd[] = {{GTCB_Checked,      FALSE   		},
							{TAG_MORE,      	(ULONG)CBTags   }},
				CBEjct[] = {{GTCB_Checked,      FALSE   		},
							{TAG_MORE,      	(ULONG)CBTags   }},
				CBARet[] = {{GTCB_Checked,      FALSE   		},
							{TAG_MORE,      	(ULONG)CBTags   }},
				CBFMTBuf[] = {{GTCB_Checked,      FALSE 		  },
							{TAG_MORE,      	(ULONG)CBTags   }},
				BUScsi[] = {{GA_Disabled,       TRUE    		},
							{TAG_MORE,      	(ULONG)GATags   }};

STATIC struct MinGadget MGTape[] = {
 {  4,76, 87,12,BUTTON_KIND     	,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {333,76, 87,12,BUTTON_KIND     	,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 {152, 8,256,14,STRING_KIND     	,MSG_DEVICE_DRIVER      ,PLACETEXT_LEFT ,STDevD },
 {152,23, 28,14,INTEGER_KIND    ,MSG_SCSI_PORT  	,PLACETEXT_LEFT ,INScsi },
 {348,23, 60,14,INTEGER_KIND    ,MSG_BLOCK_SIZE 	,PLACETEXT_LEFT ,INBloc },

 { 16,45, 26,11,CHECKBOX_KIND   ,MSG_REWIND     		,PLACETEXT_RIGHT,CBRwnd },
 { 16,57, 26,11,CHECKBOX_KIND   ,MSG_EJECT      		,PLACETEXT_RIGHT,CBEjct },
 {214,45, 26,11,CHECKBOX_KIND   ,MSG_AUTO_RETENTION     ,PLACETEXT_RIGHT,CBARet },
 {214,57, 26,11,CHECKBOX_KIND   ,MSG_FASTMEM_TBUFFER    ,PLACETEXT_RIGHT,CBFMTBuf },

 {152,76,120,12,BUTTON_KIND     	,MSG_SCSI_INQUIRY       ,PLACETEXT_IN   ,BUScsi }
};
//_________________________________________________________________ GUI options:

STRPTR  ScTpLb[] = {(STRPTR)MSG_WORKBENCH,
					(STRPTR)MSG_CUSTOM,
					(STRPTR)MSG_PUBLIC,
					NULL};

struct TagItem  CYScTp[] = {{GTCY_Labels,       		(ULONG)&ScTpLb[0]       },
							{GTCY_Active,   		0L      				},
							{TAG_MORE,      			(ULONG)GATags   	}},
				STPbSc[] = {{GA_Disabled,       		TRUE    			},
							{GTST_String,   		NULL    			},
							{GTST_MaxChars, 		MAXPUBSCREENNAME	},
							{TAG_MORE,      			(ULONG)GATags   	}},
				TXSMod[] = {{GTTX_Text, 			NULL    			},
							{TAG_MORE,      			(ULONG)TXTags   	}},
				STSFnt[] = {{GTST_String,       		NULL    			},
							{GTST_MaxChars, 		MAXFONTNAME     		},
							{TAG_MORE,      			(ULONG)GATags   	}},
				INSFnt[] = {{GTIN_Number,       		NULL    			},
							{GTIN_MaxChars, 		5L      				},
							{TAG_MORE,      			(ULONG)INTags   	}},
				STTFnt[] = {{GTST_String,       		NULL    			},
							{GTST_MaxChars, 		MAXFONTNAME     		},
							{TAG_MORE,      			(ULONG)GATags   	}},
				INTFnt[] = {{GTIN_Number,       		NULL    			},
							{GTIN_MaxChars, 		5L      				},
							{TAG_MORE,      			(ULONG)INTags   	}};

STATIC struct MinGadget MGGUI[] = {
 {  4,96, 87,12,BUTTON_KIND     ,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {333,96, 87,12,BUTTON_KIND     ,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 {197, 8,211,13,CYCLE_KIND      ,MSG_SCREEN_TYPE	,PLACETEXT_LEFT ,CYScTp },
 {197,22,211,14,STRING_KIND     ,MSG_PUBSCREEN_NAME     ,PLACETEXT_LEFT ,STPbSc },
 { 16,37,370,14,TEXT_KIND       ,MSG_VOID       		,NULL   		,TXSMod },
 {388,37, 20,14,GENERIC_KIND,MSG_VOID   		,NULL   		,NULL   },

 {197,59,143,14,STRING_KIND     ,MSG_SCREENFONT_NAME,PLACETEXT_LEFT     ,STSFnt },
 {342,59, 44,14,INTEGER_KIND,MSG_VOID   		,NULL   		,INSFnt },
 {388,59, 20,14,GENERIC_KIND,MSG_VOID   		,NULL   		,NULL   },

 {197,74,143,14,STRING_KIND     ,MSG_TEXTFONT_NAME      ,PLACETEXT_LEFT ,STTFnt },
 {342,74, 44,14,INTEGER_KIND,MSG_VOID   		,NULL   		,INTFnt },
 {388,74, 20,14,GENERIC_KIND,MSG_VOID   		,NULL   		,NULL   },

 {152,96,120,12,BUTTON_KIND     ,MSG_PALETTE    	,PLACETEXT_IN   ,GATags }
};
//___________________________________________________ External programs options:

struct TagItem  STAsci[] = {{GTST_String,       NULL    		},
							{TAG_MORE,      	(ULONG)STTags   }},
				STIlbm[] = {{GTST_String,       NULL    		},
							{TAG_MORE,      	(ULONG)STTags   }},
				STOthr[] = {{GTST_String,       NULL    		},
							{TAG_MORE,      	(ULONG)STTags   }},
				CBAsyn[] = {{GTCB_Checked,      FALSE   		},
							{TAG_MORE,      	(ULONG)CBTags   }},
				CBConf[] = {{GTCB_Checked,      FALSE   		},
							{TAG_MORE,      	(ULONG)CBTags   }};

STATIC struct MinGadget MGExternal[] = {
 {  4,91, 87,12,BUTTON_KIND     	,MSG_OK 		,PLACETEXT_IN   ,GATags },
 {333,91, 87,12,BUTTON_KIND     	,MSG_CANCEL     	,PLACETEXT_IN   ,GATags },

 {112, 8,274,14,STRING_KIND     	,MSG_ASCII      	,PLACETEXT_LEFT ,STAsci },
 {112,23,274,14,STRING_KIND     	,MSG_ILBM       	,PLACETEXT_LEFT ,STIlbm },
 {112,38,274,14,STRING_KIND     	,MSG_OTHERS     	,PLACETEXT_LEFT ,STOthr },

 {388, 8, 20,14,GENERIC_KIND    ,MSG_VOID       	,NULL   		,NULL   },
 {388,23, 20,14,GENERIC_KIND    ,MSG_VOID       	,NULL   		,NULL   },
 {388,38, 20,14,GENERIC_KIND    ,MSG_VOID       	,NULL   		,NULL   },

 { 16,60, 26,11,CHECKBOX_KIND   ,MSG_ASYNCHRO   ,PLACETEXT_RIGHT,CBAsyn },
 { 16,72, 26,11,CHECKBOX_KIND   ,MSG_CONFIRM    ,PLACETEXT_RIGHT,CBConf }
};
//_______________________________________________________ Miscellaneous options:

STRPTR  AlrtLb[] = {(STRPTR)MSG_BEEP,
					(STRPTR)MSG_FLASH,
					(STRPTR)MSG_BOTH,
					(STRPTR)MSG_NONE,
					NULL},
		FSzeLb[] = {(STRPTR)MSG_AUTOMATIC,
					(STRPTR)MSG_BYTES,
					(STRPTR)MSG_KILOBYTES,
					(STRPTR)MSG_MEGABYTES,
					NULL};

struct TagItem  CYAlrt[] = {{GTCY_Labels,       (ULONG)&AlrtLb[0]       },
							{GTCY_Active,   0L      				},
							{TAG_MORE,      	(ULONG)GATags   	}},
				CYFSze[] = {{GTCY_Labels,       (ULONG)&FSzeLb[0]       },
							{GTCY_Active,   0L      				},
							{TAG_MORE,      	(ULONG)GATags   	}},
				STTemp[] = {{GTST_String,       NULL    			},
							{TAG_MORE,      	(ULONG)STTags   	}},
				STSele[] = {{GTST_String,       NULL    			},
							{TAG_MORE,      	(ULONG)STTags   	}},
				CBPrLb[] = {{GTCB_Checked,      FALSE   			},
							{TAG_MORE,      	(ULONG)CBTags   	}},
				INLign[] = {{GA_Disabled,       TRUE    			},
							{GTIN_Number,   NULL    			},
							{GTIN_MaxChars, 3L      				},
							{TAG_MORE,      	(ULONG)INTags   	}};

STATIC struct MinGadget MGMisc[] = {
 {  4,107, 87,12,BUTTON_KIND    ,MSG_OK 			,PLACETEXT_IN   ,GATags },
 {333,107, 87,12,BUTTON_KIND    ,MSG_CANCEL     		,PLACETEXT_IN   ,GATags },

 {219,  8,189,13,CYCLE_KIND     	,MSG_ALERT      		,PLACETEXT_LEFT ,CYAlrt },
 {219, 22,189,13,CYCLE_KIND     	,MSG_FILES_SIZE 	,PLACETEXT_LEFT ,CYFSze },
 {219, 36,167,14,STRING_KIND    ,MSG_TEMP_DIRECTORY     ,PLACETEXT_LEFT ,STTemp },
 {219, 51,167,14,STRING_KIND    ,MSG_SELECTION_PATH     ,PLACETEXT_LEFT ,STSele },
 {388, 36, 20,14,GENERIC_KIND   ,MSG_VOID       		,NULL   		,NULL   },
 {388, 51, 20,14,GENERIC_KIND   ,MSG_VOID       		,NULL   		,NULL   },

 { 16, 73, 26,11,CHECKBOX_KIND  ,MSG_PRINT_LABELS       ,PLACETEXT_RIGHT,CBPrLb },
 {364, 85, 44,14,INTEGER_KIND   ,MSG_LABELS_LENGTH      ,PLACETEXT_LEFT ,INLign }
};

#endif  // ABPREFS_GADGETS_H
