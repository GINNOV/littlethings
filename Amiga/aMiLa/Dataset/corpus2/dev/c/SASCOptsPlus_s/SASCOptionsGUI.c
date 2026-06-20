/* SCOpts+
   MUI code
*/

#ifndef MAKE_ID
#define MAKE_ID(a,b,c,d) ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))
#endif

/* Libraries */
#include <libraries/mui.h>
#include <libraries/gadtools.h> /* for Barlabel in MenuItem */
#include <exec/memory.h>

/* Prototypes */
#include <proto/muimaster.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include "SASCOptionsGUI.h"
#include "SASCOptionsExtern.h"
#include "Hook_utility.h"

/* Main program application tree */

struct ObjApp * CreateApp(void)
{
	struct ObjApp * Object;

	APTR	MNlabel1MUIPrefs, MNlabel1Project, MNlabel1About, MNlabel1SASCOptions, MNlabel1MUI;
	APTR	MNlabel1Iconify, MNlabel1BarLabel0, MNlabel1Restore, MNlabel1fromSCOPTIONS, MNlabel1fromGlobalDefaultsENV;
	APTR	MNlabel1from, MNlabel1toSASCDefaults, MNlabel1BarLabel1, MNlabel1Save;
	APTR	MNlabel1toSCOPTIONS, MNlabel1asGlobalDefaults, MNlabel1as, MNlabel1BarLabel2, MNlabel1BarLabel3, MNlabel1BarLabel4;
	APTR	MNlabel1Quit, MainWindow, Compiler, CompilerMain, CompilerCycles;
	APTR	Line4, CompilerMisc, REC_label_27, CompilerIncDir, CompIncDirButtons;
	APTR	Line1, CompilerDefine, CompilerDefineButtons, CompilerGSTFile;
	APTR	LA_CompilerGST, CompilerMakeGSTFile, LA_CompilerMakeGST, Message;
	APTR	MessageMain, MessageCycles, MessageMisc, MessageEWI, MessageEWIButtons;
	APTR	Line16, obj_aux0, Line17;
	APTR	obj_aux5, Code, CodeMain, CodeCycles, Line3, CodeMisc, REC_label_28;
	APTR	obj_aux6, obj_aux7, obj_aux8, obj_aux9, obj_aux10, obj_aux11, Line6;
	APTR	obj_aux12, obj_aux13, obj_aux14, obj_aux15, obj_aux16, obj_aux17;
	APTR	Line7, obj_aux18, obj_aux19, ListXREF, ListMain, ListCycles, obj_aux20;
	APTR	obj_aux21, Line9, Line21a, ListMisc, obj_aux22, obj_aux23, Label11;
	APTR	ListXrefListFile, LA_ListXrefListFile, Optimizer, OptimizerMain, OptimizerCycles;
	APTR	obj_aux24, obj_aux25, Line22a, Line12, OptimizerMisc, obj_aux26, obj_aux27;
	APTR	obj_aux28, obj_aux29, obj_aux30, obj_aux31, Prototype, PrototypeMain;
	APTR	obj_aux32, obj_aux33, PrototypeCycles, Line14, PrototypeFile, LA_PrototypeGenProtoFile;
	APTR	Linker, LinkerMain, LinkerCycles, obj_aux34, obj_aux35, Line19, obj_aux36;
	APTR	obj_aux37, obj_aux38, obj_aux39, obj_aux40, obj_aux41, obj_aux42;
	APTR	obj_aux43, Line20, LinkerMisc, LinkerLinkerDefine, SpecialLinkerDefButtons;
	APTR	LinkerObjects, LinkerObjectsButtons, obj_aux44, obj_aux45, Line22;
	APTR	LinkerStartup, LA_LinkerCustom, Map, MapMain;
	APTR	obj_aux48, obj_aux49, Line21, MapMapFileButtons, LA_MapMapFile, Special;
	APTR	SpecialMain, SpecialCycles, Line24a, Line24, SpecialMisc, obj_aux50;
	APTR	obj_aux51, obj_aux52, obj_aux53, obj_aux54, obj_aux55, obj_aux56;
	APTR	obj_aux57, Line26, obj_aux58, obj_aux59, ProgramName, LA_ProgName;
	APTR	Line999, ActionButtons, Space_5, Space_6;

/* function hooks */

	static struct Hook h_ABOUTHook;			/* About Program */
	static struct Hook h_ABOUT_MUIHook;		/* About MUI */
	static struct Hook h_RESTORE_SCOPTSHook;	/* Restore from SCOPTIONS */
	static struct Hook h_RESTORE_ENVHook;		/* Restore from ENV: */
	static struct Hook h_RESTOREHook;		/* Restore from... */
	static struct Hook h_RESTORE_DEFHook;		/* Restore from SAS/C */
	static struct Hook h_SAVE_SCOPTSHook;		/* Save to SCOPTIONS */
	static struct Hook h_SAVE_ENVHook;		/* Save to ENV: */
	static struct Hook h_SAVEHook;			/* Save as... */

	if (!(Object = AllocVec(sizeof(struct ObjApp),MEMF_PUBLIC|MEMF_CLEAR)))
		return(NULL);

	Object->STR_OptionsPanel[0] = "Compiler";
	Object->STR_OptionsPanel[1] = "Message";
	Object->STR_OptionsPanel[2] = "Code";
	Object->STR_OptionsPanel[3] = "ListXREF";
	Object->STR_OptionsPanel[4] = "Optimizer";
	Object->STR_OptionsPanel[5] = "Prototype";
	Object->STR_OptionsPanel[6] = "Linker";
	Object->STR_OptionsPanel[7] = "Map";
	Object->STR_OptionsPanel[8] = "Special";
	Object->STR_OptionsPanel[9] = NULL;
	Object->CompilerDebugContent[0] = "NoDebug";
	Object->CompilerDebugContent[1] = "\033bDebug=LINE";
	Object->CompilerDebugContent[2] = "\033bDebug=SYMBOL";
	Object->CompilerDebugContent[3] = "\033bDebug=SYMBOLFLUSH";
	Object->CompilerDebugContent[4] = "\033bDebug=FULL";
	Object->CompilerDebugContent[5] = "\033bDebug=FULLFLUSH";
	Object->CompilerDebugContent[6] = NULL;
	Object->CompilerIntegersContent[0] = "NoShortIntegers";
	Object->CompilerIntegersContent[1] = "\033bShortIntegers";
	Object->CompilerIntegersContent[2] = NULL;
	Object->CompilerStrContent[0] = "NoStringMerge";
	Object->CompilerStrContent[1] = "\033bStringMerge";
	Object->CompilerStrContent[2] = NULL;
	Object->CompilerUCharContent[0] = "NoUnsignedChar";
	Object->CompilerUCharContent[1] = "\033bUnsignedChar";
	Object->CompilerUCharContent[2] = NULL;
	Object->CompilerCommentContent[0] = "NoCommentNest";
	Object->CompilerCommentContent[1] = "\033bCommentNest";
	Object->CompilerCommentContent[2] = NULL;
	Object->CompilerIconsContent[0] = "Icons";
	Object->CompilerIconsContent[1] = "\033bNoIcons";
	Object->CompilerIconsContent[2] = NULL;
	Object->CompilerModContent[0] = "NoModified";
	Object->CompilerModContent[1] = "\033bModified";
	Object->CompilerModContent[2] = NULL;
	Object->CompilerPPContent[0] = "NoPreProcessOnly";
	Object->CompilerPPContent[1] = "\033bPreProcessOnly";
	Object->CompilerPPContent[2] = NULL;
	Object->CompilerCXXContent[0] = "NoCXXOnly";
	Object->CompilerCXXContent[1] = "\033bCXXOnly";
	Object->CompilerCXXContent[2] = NULL;
	Object->CompilerMemContent[0] = "MemSize=Large";
	Object->CompilerMemContent[1] = "\033bMemSize=Huge";
	Object->CompilerMemContent[2] = "\033bMemSize=Tiny";
	Object->CompilerMemContent[3] = "\033bMemSize=Small";
	Object->CompilerMemContent[4] = "\033bMemSize=Medium";
	Object->CompilerMemContent[5] = NULL;
	Object->CompilerStrConstContent[0] = "NoStringsConst";
	Object->CompilerStrConstContent[1] = "\033bStringsConst";
	Object->CompilerStrConstContent[2] = NULL;
	Object->CompilerWVRContent[0] = "WarnVoidReturn";
	Object->CompilerWVRContent[1] = "\033bNoWarnVoidReturn";
	Object->CompilerWVRContent[2] = NULL;
	Object->CompilerMCCContent[0] = "NoMCConstants";
	Object->CompilerMCCContent[1] = "\033bMCConstants";
	Object->CompilerMCCContent[2] = NULL;
	Object->CompilerMIncludeContent[0] = "MultipleIncludes";
	Object->CompilerMIncludeContent[1] = "\033bNoMultipleIncludes";
	Object->CompilerMIncludeContent[2] = NULL;
	Object->CompilerGSTImmContent[0] = "NoGSTImmediate";
	Object->CompilerGSTImmContent[1] = "\033bGSTImmediate";
	Object->CompilerGSTImmContent[2] = NULL;
	Object->MessageAnsiContent[0] = "NoAnsi";
	Object->MessageAnsiContent[1] = "\033bAnsi";
	Object->MessageAnsiContent[2] = NULL;
	Object->MessageStrictContent[0] = "NoStrict";
	Object->MessageStrictContent[1] = "\033bStrict";
	Object->MessageStrictContent[2] = NULL;
	Object->MessageErrRexxContent[0] = "NoErrorRexx";
	Object->MessageErrRexxContent[1] = "\033bErrorRexx";
	Object->MessageErrRexxContent[2] = NULL;
	Object->MessageErrConContent[0] = "ErrorConsole";
	Object->MessageErrConContent[1] = "\033bNoErrorConsole";
	Object->MessageErrConContent[2] = NULL;
	Object->MessageErrListContent[0] = "ErrorListing";
	Object->MessageErrListContent[1] = "\033bNoErrorListing";
	Object->MessageErrListContent[2] = NULL;
	Object->MessageErrSrcContent[0] = "ErrorSource";
	Object->MessageErrSrcContent[1] = "\033bNoErrorSource";
	Object->MessageErrSrcContent[2] = NULL;
	Object->MessageErrHlContent[0] = "ErrorHighlight";
	Object->MessageErrHlContent[1] = "\033bNoErrorHighlight";
	Object->MessageErrHlContent[2] = NULL;
	Object->MessageStrEqContent[0] = "NoStructEquivalence";
	Object->MessageStrEqContent[1] = "\033bStructEquivalence";
	Object->MessageStrEqContent[2] = NULL;
	Object->MessageOnErrContent[0] = "OnError=STOP";
	Object->MessageOnErrContent[1] = "\033bOnError=CONTINUE";
	Object->MessageOnErrContent[2] = NULL;
	Object->MessageEWIButton_CYCLEContent[0] = "Ignore";
	Object->MessageEWIButton_CYCLEContent[1] = "Warn";
	Object->MessageEWIButton_CYCLEContent[2] = "Error";
	Object->MessageEWIButton_CYCLEContent[3] = NULL;
	Object->CodeMathContent[0] = "NoMath";
	Object->CodeMathContent[1] = "\033bMath=STANDARD";
	Object->CodeMathContent[2] = "\033bMath=IEEE";
	Object->CodeMathContent[3] = "\033bMath=FFP";
	Object->CodeMathContent[4] = "\033bMath=68881";
	Object->CodeMathContent[5] = NULL;
	Object->CodePrecisionContent[0] = "Precision=MIXED";
	Object->CodePrecisionContent[1] = "\033bPrecision=DOUBLE";
	Object->CodePrecisionContent[2] = NULL;
	Object->CodeCPUContent[0] = "CPU=ANY";
	Object->CodeCPUContent[1] = "\033bCPU=68010";
	Object->CodeCPUContent[2] = "\033bCPU=68020";
	Object->CodeCPUContent[3] = "\033bCPU=68030";
	Object->CodeCPUContent[4] = "\033bCPU=68040";
	Object->CodeCPUContent[5] = "\033bCPU=68060";
	Object->CodeCPUContent[6] = NULL;
	Object->CodeParmsContent[0] = "Parms=STACK";
	Object->CodeParmsContent[1] = "\033bParms=REGISTER";
	Object->CodeParmsContent[2] = "\033bParms=BOTH";
	Object->CodeParmsContent[3] = NULL;
	Object->CodeStkExtContent[0] = "NoStackExtend";
	Object->CodeStkExtContent[1] = "\033bStackExtend";
	Object->CodeStkExtContent[2] = NULL;
	Object->CodeStkChkContent[0] = "StackCheck";
	Object->CodeStkChkContent[1] = "\033bNoStackCheck";
	Object->CodeStkChkContent[2] = NULL;
	Object->CodeSaveDSContent[0] = "NoSaveDS";
	Object->CodeSaveDSContent[1] = "\033bSaveDS";
	Object->CodeSaveDSContent[2] = NULL;
	Object->CodeDataMemContent[0] = "DataMem=ANY";
	Object->CodeDataMemContent[1] = "\033bDataMem=FAST";
	Object->CodeDataMemContent[2] = "\033bDataMem=CHIP";
	Object->CodeDataMemContent[3] = NULL;
	Object->CodeAutoRegContent[0] = "AutoRegister";
	Object->CodeAutoRegContent[1] = "\033bNoAutoRegister";
	Object->CodeAutoRegContent[2] = NULL;
	Object->CodeUtilLibContent[0] = "NoUtilLib";
	Object->CodeUtilLibContent[1] = "\033bUtilLib";
	Object->CodeUtilLibContent[2] = NULL;
	Object->CodeConstLibBaseContent[0] = "ConstLibBase";
	Object->CodeConstLibBaseContent[1] = "\033bNoConstLibBase";
	Object->CodeConstLibBaseContent[2] = NULL;
	Object->CodeLibCodeContent[0] = "NoLibCode";
	Object->CodeLibCodeContent[1] = "\033bLibCode";
	Object->CodeLibCodeContent[2] = NULL;
	Object->CodeABSFPContent[0] = "NoAbsFuncPointer";
	Object->CodeABSFPContent[1] = "\033bAbsFuncPointer";
	Object->CodeABSFPContent[2] = NULL;
	Object->CodeDataContent[0] = "Data=NEAR";
	Object->CodeDataContent[1] = "\033bData=FAR";
	Object->CodeDataContent[2] = "\033bData=AUTO";
	Object->CodeDataContent[3] = "\033bData=FARONLY";
	Object->CodeDataContent[4] = NULL;
	Object->CodeCodeContent[0] = "Code=NEAR";
	Object->CodeCodeContent[1] = "\033bCode=FAR";
	Object->CodeCodeContent[2] = NULL;
	Object->CodeStrSectContent[0] = "StrSect=DEFAULT";
	Object->CodeStrSectContent[1] = "\033bStrSect=NEAR";
	Object->CodeStrSectContent[2] = "\033bStrSect=FAR";
	Object->CodeStrSectContent[3] = "\033bStrSect=CODE";
	Object->CodeStrSectContent[4] = NULL;
	Object->CodeCommonContent[0] = "NoCommon";
	Object->CodeCommonContent[1] = "\033bCommon";
	Object->CodeCommonContent[2] = NULL;
	Object->CodeCoverageContent[0] = "NoCoverage";
	Object->CodeCoverageContent[1] = "\033bCoverage";
	Object->CodeCoverageContent[2] = NULL;
	Object->CodeProfileContent[0] = "NoProfile";
	Object->CodeProfileContent[1] = "\033bProfile";
	Object->CodeProfileContent[2] = NULL;
	Object->ListListMacroContent[0] = "NoListMacro";
	Object->ListListMacroContent[1] = "\033bListMacro";
	Object->ListListMacroContent[2] = NULL;
	Object->ListListIncludesContent[0] = "NoListIncludes";
	Object->ListListIncludesContent[1] = "\033bListIncludes";
	Object->ListListIncludesContent[2] = NULL;
	Object->ListListHeadersContent[0] = "ListHeaders";
	Object->ListListHeadersContent[1] = "\033bNoListHeaders";
	Object->ListListHeadersContent[2] = NULL;
	Object->ListListSystemContent[0] = "NoListSystem";
	Object->ListListSystemContent[1] = "\033bListSystem";
	Object->ListListSystemContent[2] = NULL;
	Object->ListListNarrowContent[0] = "ListNarrow";
	Object->ListListNarrowContent[1] = "\033bNoListNarrow";
	Object->ListListNarrowContent[2] = NULL;
	Object->ListErrorListingContent[0] = "ErrorListing";
	Object->ListErrorListingContent[1] = "\033bNoErrorListing";
	Object->ListErrorListingContent[2] = NULL;
	Object->ListXrefSystemContent[0] = "NoXrefSystem";
	Object->ListXrefSystemContent[1] = "\033bXrefSystem";
	Object->ListXrefSystemContent[2] = NULL;
	Object->ListXrefHeadersContent[0] = "NoXrefHeaders";
	Object->ListXrefHeadersContent[1] = "\033bXrefHeaders";
	Object->ListXrefHeadersContent[2] = NULL;
	Object->OptimizerGlobalContent[0] = "OptimizeGlobal";
	Object->OptimizerGlobalContent[1] = "\033bNoOptimizeGlobal";
	Object->OptimizerGlobalContent[2] = NULL;
	Object->OptimizerPeepContent[0] = "OptimizePeep";
	Object->OptimizerPeepContent[1] = "\033bNoOptimizePeep";
	Object->OptimizerPeepContent[2] = NULL;
	Object->OptimizerScheduleContent[0] = "NoOptimizeSchedule";
	Object->OptimizerScheduleContent[1] = "\033bOptimizeSchedule";
	Object->OptimizerScheduleContent[2] = NULL;
	Object->OptimizerInlineContent[0] = "OptInline";
	Object->OptimizerInlineContent[1] = "\033bNoOptInline";
	Object->OptimizerInlineContent[2] = NULL;
	Object->OptimizerInLocalContent[0] = "NoOptInLocal";
	Object->OptimizerInLocalContent[1] = "\033bOptInLocal";
	Object->OptimizerInLocalContent[2] = NULL;
	Object->OptimizerLoopContent[0] = "OptLoop";
	Object->OptimizerLoopContent[1] = "\033bNoOptLoop";
	Object->OptimizerLoopContent[2] = NULL;
	Object->OptimizerSizeContent[0] = "NoOptSize";
	Object->OptimizerSizeContent[1] = "\033bOptSize";
	Object->OptimizerSizeContent[2] = NULL;
	Object->OptimizerTimeContent[0] = "NoOptTime";
	Object->OptimizerTimeContent[1] = "\033bOptTime";
	Object->OptimizerTimeContent[2] = NULL;
	Object->OptimizerAliasContent[0] = "NoOptAlias";
	Object->OptimizerAliasContent[1] = "\033bOptAlias";
	Object->OptimizerAliasContent[2] = NULL;
	Object->PrototypeProtoExternContent[0] = "GenProtoExtern";
	Object->PrototypeProtoExternContent[1] = "\033bNoGenProtoExtern";
	Object->PrototypeProtoExternContent[2] = NULL;
	Object->PrototypeGenProtoStaticContent[0] = "NoGenProtoStatic";
	Object->PrototypeGenProtoStaticContent[1] = "\033bGenProtoStatic";
	Object->PrototypeGenProtoStaticContent[2] = NULL;
	Object->PrototypeGenProtoParmContent[0] = "NoGenProtoParm";
	Object->PrototypeGenProtoParmContent[1] = "\033bGenProtoParm";
	Object->PrototypeGenProtoParmContent[2] = NULL;
	Object->PrototypeGenProtoTypedefContent[0] = "GenProtoTypedef";
	Object->PrototypeGenProtoTypedefContent[1] = "\033bNoGenProtoTypedef";
	Object->PrototypeGenProtoTypedefContent[2] = NULL;
	Object->PrototypeGenProtoDataItemContent[0] = "GenProtoDataItem";
	Object->PrototypeGenProtoDataItemContent[1] = "\033bNoGenProtoDataItem";
	Object->PrototypeGenProtoDataItemContent[2] = NULL;
	Object->LinkerSmallCodeContent[0] = "NoSmallCode";
	Object->LinkerSmallCodeContent[1] = "\033bSmallCode";
	Object->LinkerSmallCodeContent[2] = NULL;
	Object->LinkerSmallDataContent[0] = "NoSmallData";
	Object->LinkerSmallDataContent[1] = "\033bSmallData";
	Object->LinkerSmallDataContent[2] = NULL;
	Object->LinkerAddSymContent[0] = "NoAddSym";
	Object->LinkerAddSymContent[1] = "\033bAddSym";
	Object->LinkerAddSymContent[2] = NULL;
	Object->LinkerStripDebugContent[0] = "NoStripDebug";
	Object->LinkerStripDebugContent[1] = "\033bStripDebug";
	Object->LinkerStripDebugContent[2] = NULL;
	Object->LinkerChkAbortContent[0] = "ChkAbort";
	Object->LinkerChkAbortContent[1] = "\033bNoChkAbort";
	Object->LinkerChkAbortContent[2] = NULL;
	Object->LinkerBatchContent[0] = "NoBatch";
	Object->LinkerBatchContent[1] = "\033bBatch";
	Object->LinkerBatchContent[2] = NULL;
	Object->CY_LinkerStartupContent[0] = "Startup=c";
	Object->CY_LinkerStartupContent[1] = "\033bStartup=cres";
	Object->CY_LinkerStartupContent[2] = "\033bStartup=cback";
	Object->CY_LinkerStartupContent[3] = "\033bStartup=catch";
	Object->CY_LinkerStartupContent[4] = "\033bStartup=catchres";
	Object->CY_LinkerStartupContent[5] = "\033bStartup=libinitr";
	Object->CY_LinkerStartupContent[6] = "\033bStartup=libinit";
	Object->CY_LinkerStartupContent[7] = "\033bStartup=\033icustom";
	Object->CY_LinkerStartupContent[8] = "\033bNoStartup";
	Object->CY_LinkerStartupContent[9] = NULL;
	Object->CY_MapMapHunkContent[0] = "NoMapHunk";
	Object->CY_MapMapHunkContent[1] = "\033bMapHunk";
	Object->CY_MapMapHunkContent[2] = NULL;
	Object->CY_MapMapSymbolsContent[0] = "NoMapSymbols";
	Object->CY_MapMapSymbolsContent[1] = "\033bMapSymbols";
	Object->CY_MapMapSymbolsContent[2] = NULL;
	Object->CY_MapMapLibrariesContent[0] = "NoMapLibraries";
	Object->CY_MapMapLibrariesContent[1] = "\033bMapLibraries";
	Object->CY_MapMapLibrariesContent[2] = NULL;
	Object->CY_MapMapXrefContent[0] = "NoMapXref";
	Object->CY_MapMapXrefContent[1] = "\033bMapXref";
	Object->CY_MapMapXrefContent[2] = NULL;
	Object->CY_MapMapOverlayContent[0] = "NoMapOverlay";
	Object->CY_MapMapOverlayContent[1] = "\033bMapOverlay";
	Object->CY_MapMapOverlayContent[2] = NULL;
	Object->CY_SpecialVerboseContent[0] = "NoVerbose";
	Object->CY_SpecialVerboseContent[1] = "\033bVerbose";
	Object->CY_SpecialVerboseContent[2] = NULL;
	Object->CY_SpecialVersionContent[0] = "Version";
	Object->CY_SpecialVersionContent[1] = "\033bNoVersion";
	Object->CY_SpecialVersionContent[2] = NULL;
	Object->CY_SpecialDollarContent[0] = "NoDollarOK";
	Object->CY_SpecialDollarContent[1] = "\033bDollarOK";
	Object->CY_SpecialDollarContent[2] = NULL;
	Object->CY_SpecialExtDefContent[0] = "ExternalDefinitions";
	Object->CY_SpecialExtDefContent[1] = "\033bNoExternalDefinitions";
	Object->CY_SpecialExtDefContent[2] = NULL;
	Object->CY_SpecialKeepLineContent[0] = "NoKeepLine";
	Object->CY_SpecialKeepLineContent[1] = "\033bKeepLine";
	Object->CY_SpecialKeepLineContent[2] = NULL;
	Object->CY_SpecialOldPPContent[0] = "NoOldPreprocessor";
	Object->CY_SpecialOldPPContent[1] = "\033bOldPreProcessor";
	Object->CY_SpecialOldPPContent[2] = NULL;
	Object->CY_SpecialTrigraphContent[0] = "NoTrigraph";
	Object->CY_SpecialTrigraphContent[1] = "\033bTrigraph";
	Object->CY_SpecialTrigraphContent[2] = NULL;
	Object->CY_SpecialUnderScoreContent[0] = "NoUnderscore";
	Object->CY_SpecialUnderScoreContent[1] = "\033bUnderscore";
	Object->CY_SpecialUnderScoreContent[2] = NULL;

	InstallHook(&h_ABOUTHook,h_ABOUT,NULL);
	InstallHook(&h_ABOUT_MUIHook,h_ABOUT_MUI,NULL);
	InstallHook(&h_RESTORE_SCOPTSHook,h_RESTORE_SCOPTS,NULL);
	InstallHook(&h_RESTORE_ENVHook,h_RESTORE_ENV,NULL);
	InstallHook(&h_RESTOREHook,h_RESTORE,NULL);
	InstallHook(&h_RESTORE_DEFHook,h_RESTORE_DEF,NULL);
	InstallHook(&h_SAVE_SCOPTSHook,h_SAVE_SCOPTS,NULL);
	InstallHook(&h_SAVE_ENVHook,h_SAVE_ENV,NULL);
	InstallHook(&h_SAVEHook,h_SAVE,NULL);

	Object->CompilerDebug = CycleObject,
		MUIA_ShortHelp, "Sets the debugging level of the compiler",
		MUIA_HelpNode, "Debug",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerDebugContent,
	End;

	Object->CompilerIntegers = CycleObject,
		MUIA_ShortHelp, "Enables 16-bit integers",
		MUIA_HelpNode, "ShortIntegers",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerIntegersContent,
	End;

	Object->CompilerStr = CycleObject,
		MUIA_ShortHelp, "Merges all identical string constants in the C source file",
		MUIA_HelpNode, "StringMerge",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerStrContent,
	End;

	Object->CompilerUChar = CycleObject,
		MUIA_ShortHelp, "Makes the default type of char variables unsigned instead of signed",
		MUIA_HelpNode, "UnsignedChar",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerUCharContent,
	End;

	Object->CompilerComment = CycleObject,
		MUIA_ShortHelp, "Allows nested comments",
		MUIA_HelpNode, "CommentNest",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerCommentContent,
	End;

	Object->CompilerIcons = CycleObject,
		MUIA_ShortHelp, "Tells the compiler to create icons for files that it creates",
		MUIA_HelpNode, "Icons",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerIconsContent,
	End;

	Object->CompilerMod = CycleObject,
		MUIA_ShortHelp, "Tells the sc command to process only files that are out of date with respect to their output files",
		MUIA_HelpNode, "Modified",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerModContent,
	End;

	Object->CompilerPP = CycleObject,
		MUIA_ShortHelp, "Tells the compiler to run only the preprocessor on the C source files", 
		MUIA_HelpNode, "PreprocessorOnly",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerPPContent,
	End;

	Object->CompilerCXX = CycleObject,
		MUIA_ShortHelp, "Tells sc to translate the C++ source files into C source files without compiling them",
		MUIA_HelpNode, "CxxOnly",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerCXXContent,
	End;

	Object->CompilerMem = CycleObject,
		MUIA_ShortHelp, "Tells the compiler approximately how much memory you have on your system", 
		MUIA_HelpNode, "MemorySize",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerMemContent,
	End;

	Object->CompilerStrConst = CycleObject,
		MUIA_ShortHelp, "Tells the compiler to consider all string constants to be of type const char *",
		MUIA_HelpNode, "StringsConst",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerStrConstContent,
	End;

	Object->CompilerWVR = CycleObject,
		MUIA_ShortHelp, "Issues a warning message if a function declared as returning an integer actually returns no value",
		MUIA_HelpNode, "WarnVoidReturn",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerWVRContent,
	End;

	Object->CompilerMCC = CycleObject,
		MUIA_ShortHelp, "Allows up to four bytes to appear within single quotes as a character constant",
		MUIA_HelpNode, "MultipleCharacterConstants",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerMCCContent,
	End;

	Object->CompilerMInclude = CycleObject,
		MUIA_ShortHelp, "Tells the compiler to include header files each time they are #included in your program", 
		MUIA_HelpNode, "MultipleIncludes",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerMIncludeContent,
	End;

	Object->CompilerGSTImm = CycleObject,
		MUIA_ShortHelp, "Makes the contents of the GST you specify with the gst option immediately available to the program",
		MUIA_HelpNode, "GSTImmediate",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CompilerGSTImmContent,
	End;
	
	CompilerCycles = GroupObject,
		MUIA_Group_Horiz, TRUE,
		MUIA_HelpNode, "CompilerPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns, 3,
		Child, Object->CompilerDebug,
		Child, Object->CompilerIntegers,
		Child, Object->CompilerStr,
		Child, Object->CompilerUChar,
		Child, Object->CompilerComment,
		Child, Object->CompilerIcons,
		Child, Object->CompilerMod,
		Child, Object->CompilerPP,
		Child, Object->CompilerCXX,
		Child, Object->CompilerMem,
		Child, Object->CompilerStrConst,
		Child, Object->CompilerWVR,
		Child, Object->CompilerMCC,
		Child, Object->CompilerMInclude,
		Child, Object->CompilerGSTImm,
	End;

	Line4 = RectangleObject,
		MUIA_Rectangle_VBar, TRUE,
		/*MUIA_FixWidth, 10,*/
	End;

	REC_label_27 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		/*MUIA_FixHeight, 8,*/
	End;

	Object->LV_CompIncDir = ListObject,
		MUIA_ShortHelp, "Adds the specified directory to the list of directories that you want the compiler to search for #include files",
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_Frame, MUIV_Frame_InputList,
	End;

	Object->LV_CompIncDir = ListviewObject,
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_Listview_List, Object->LV_CompIncDir,
	End;

	Object->STR_PA_CompilerIncDir = String("", 80);

	Object->PA_CompilerIncDir = PopButton(MUII_PopDrawer);

	Object->PA_CompilerIncDir = PopaslObject,
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_Disabled, TRUE,
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_CompilerIncDir,
		MUIA_Popstring_Button, Object->PA_CompilerIncDir,
	End;

	Object->BT_CompIncDir_Add = TextObject,
		MUIA_ShortHelp, "Add an #include directory\nto the list",
		ButtonFrame,
		MUIA_Weight, 20,
		MUIA_Background, MUII_ButtonBack,
		MUIA_Text_Contents, "Add",
		MUIA_Text_PreParse, "\033c",
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	Object->BT_CompIncDir_Del = TextObject,
		MUIA_ShortHelp, "Remove an #include directory\nfrom the list",
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Weight, 20,
		MUIA_Background, MUII_ButtonBack,
		MUIA_Text_Contents, "Del",
		MUIA_Text_PreParse, "\033c",
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	CompIncDirButtons = GroupObject,
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, Object->PA_CompilerIncDir,
		Child, Object->BT_CompIncDir_Add,
		Child, Object->BT_CompIncDir_Del,
	End;

	CompilerIncDir = GroupObject,
		MUIA_HelpNode, "IncludeDirectory",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_FrameTitle, "IncludeDirectory",
		Child, Object->LV_CompIncDir,
		Child, CompIncDirButtons,
	End;

	Line1 = RectangleObject,
		MUIA_Rectangle_HBar, FALSE,
		/*MUIA_FixHeight, 8,*/
	End;

	Object->LV_CompDefine = ListObject,
		MUIA_HelpNode, "Define",
		MUIA_Frame, MUIV_Frame_InputList,
	End;

	Object->LV_CompDefine = ListviewObject,
		MUIA_HelpNode, "Define",
		MUIA_Listview_List, Object->LV_CompDefine,
	End;

	Object->STR_CompDefine = StringObject,
		MUIA_Disabled, TRUE,
		MUIA_Weight, 60,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "Define",
		MUIA_String_MaxLen, 140,
	End;

	Object->BT_CompDefine_Add = TextObject,
		ButtonFrame,
		MUIA_Weight, 20,
		MUIA_Background, MUII_ButtonBack,
		MUIA_Text_Contents, "Add",
		MUIA_Text_PreParse, "\033c",
		MUIA_HelpNode, "Define",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	Object->BT_CompInclude_Del = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Weight, 20,
		MUIA_Background, MUII_ButtonBack,
		MUIA_Text_Contents, "Del",
		MUIA_Text_PreParse, "\033c",
		MUIA_HelpNode, "Define",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	CompilerDefineButtons = GroupObject,
		MUIA_HelpNode, "Define",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, Object->STR_CompDefine,
		Child, Object->BT_CompDefine_Add,
		Child, Object->BT_CompInclude_Del,
	End;

	CompilerDefine = GroupObject,
		MUIA_HelpNode, "Define",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_FrameTitle, "Define",
		Child, Object->LV_CompDefine,
		Child, CompilerDefineButtons,
	End;

	LA_CompilerGST = Label("GST");

	Object->STR_PA_CompilerGST = String("", 80);

	Object->PA_CompilerGST = PopButton(MUII_PopFile);

	Object->PA_CompilerGST = PopaslObject,
		MUIA_HelpNode, "GST",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_CompilerGST,
		MUIA_Popstring_Button, Object->PA_CompilerGST,
	End;

	CompilerGSTFile = GroupObject,
		MUIA_HelpNode, "GST",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LA_CompilerGST,
		Child, Object->PA_CompilerGST,
	End;

	LA_CompilerMakeGST = Label("MakeGST");

	Object->STR_PA_CompilerMakeGST = String("", 80);

	Object->PA_CompilerMakeGST = PopButton(MUII_PopFile);

	Object->PA_CompilerMakeGST = PopaslObject,
		MUIA_HelpNode, "MakeGlobalSymbolTable",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_CompilerMakeGST,
		MUIA_Popstring_Button, Object->PA_CompilerMakeGST,
	End;

	CompilerMakeGSTFile = GroupObject,
		MUIA_HelpNode, "MakeGlobalSymbolTable",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LA_CompilerMakeGST,
		Child, Object->PA_CompilerMakeGST,
	End;

	CompilerMisc = GroupObject,
		MUIA_HelpNode, "CompilerPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		MUIA_Group_Columns, 2,
		Child, CompilerIncDir,
		Child, CompilerDefine,
		Child, CompilerGSTFile,
		Child, CompilerMakeGSTFile,
	End;

	CompilerMain = GroupObject,
		HVSpace, TRUE,
		MUIA_HelpNode, "CompilerPanel",
		MUIA_Group_Horiz, FALSE,
		Child, CompilerCycles,
		Child, CompilerMisc,
	End;

	Compiler = GroupObject,
		MUIA_HelpNode, "CompilerPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Compiler Options",
		Child, CompilerMain,
	End;

	Object->MessageAnsi = CycleObject,
		MUIA_HelpNode, "ANSI",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageAnsiContent,
	End;

	Object->MessageStrict = CycleObject,
		MUIA_HelpNode, "Strict",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageStrictContent,
	End;

	Object->MessageErrRexx = CycleObject,
		MUIA_HelpNode, "ErrorRexx",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageErrRexxContent,
	End;

	Object->MessageErrCon = CycleObject,
		MUIA_HelpNode, "ErrorConsole",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageErrConContent,
	End;

	Object->MessageErrList = CycleObject,
		MUIA_HelpNode, "ErrorList",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageErrListContent,
	End;

	Object->MessageErrSrc = CycleObject,
		MUIA_HelpNode, "ErrorSource",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageErrSrcContent,
	End;

	Object->MessageErrHl = CycleObject,
		MUIA_HelpNode, "ErrorHighlight",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageErrHlContent,
	End;

	Object->MessageStrEq = CycleObject,
		MUIA_HelpNode, "StructureEquivalence",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageStrEqContent,
	End;

	Object->MessageOnErr = CycleObject,
		MUIA_HelpNode, "OnError",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageOnErrContent,
	End;

	MessageCycles = GroupObject,
		MUIA_HelpNode, "MessagePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns, 2,
		Child, Object->MessageAnsi,
		Child, Object->MessageStrict,
		Child, Object->MessageErrRexx,
		Child, Object->MessageErrCon,
		Child, Object->MessageErrList,
		Child, Object->MessageErrSrc,
		Child, Object->MessageErrHl,
		Child, Object->MessageStrEq,
		Child, Object->MessageOnErr,
	End;

	Object->LV_MessageEWI = ListObject,
		MUIA_Frame, MUIV_Frame_InputList,
	End;

	Object->LV_MessageEWI = ListviewObject,
		MUIA_Listview_List, Object->LV_MessageEWI,
	End;

	Object->STR_MessageEWI = StringObject,
		MUIA_Disabled, TRUE,
		MUIA_Weight, 40,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_String_Accept, "-0123456789",
		MUIA_String_MaxLen, 5,
	End;

	Object->MessageEWIButton_CYCLE = CycleObject,
		MUIA_Disabled, TRUE,
		MUIA_Weight, 20,
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->MessageEWIButton_CYCLEContent,
	End;

	Object->BT_MessageEWI_Add = TextObject,
		ButtonFrame,
		MUIA_Weight, 20,
		MUIA_Background, MUII_ButtonBack,
		MUIA_Text_Contents, "Add",
		MUIA_Text_PreParse, "\033c",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	Object->BT_MessageEWI_Del = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Weight, 20,
		MUIA_Background, MUII_ButtonBack,
		MUIA_Text_Contents, "Del",
		MUIA_Text_PreParse, "\033c",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	MessageEWIButtons = GroupObject,
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, Object->STR_MessageEWI,
		Child, Object->MessageEWIButton_CYCLE,
		Child, Object->BT_MessageEWI_Add,
		Child, Object->BT_MessageEWI_Del,
	End;

	MessageEWI = GroupObject,
		MUIA_Background, MUII_BACKGROUND,
		MUIA_FrameTitle, "Error/Warning/Ignore",
		Child, Object->LV_MessageEWI,
		Child, MessageEWIButtons,
	End;

	Object->STR_MessageMaxErr = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "MaximumErrors",
		MUIA_String_Accept, "-0123456789",
		MUIA_String_MaxLen, 6,
	End;

	Object->STR_MessageMaxWarn = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "MaximumWarnings",
		MUIA_String_Accept, "-0123456789",
		MUIA_String_MaxLen, 6,
	End;
	
	Object->STR_MessagePubScr = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "PubScreen",
	End;
	
	obj_aux0 = GroupObject,
		MUIA_Group_Columns, 2,
		Child, Label2("MaxError"),
		Child, Object->STR_MessageMaxErr,
		Child, Label2("MaxWarn"),
		Child, Object->STR_MessageMaxWarn,
		Child, Label2("PubScreen"),
		Child, Object->STR_MessagePubScr,
	End;

	MessageMisc = GroupObject,
		MUIA_HelpNode, "MessagePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, obj_aux0,
		Child, MessageEWI,
	End;

	MessageMain = GroupObject,
		MUIA_HelpNode, "MessagePanel",
		MUIA_Group_Horiz, FALSE,
		Child, MessageCycles,
		Child, MessageMisc,
	End;

	Message = GroupObject,
		MUIA_HelpNode, "MessagePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Diagnostic Message Options",
		Child, MessageMain,
	End;

	Object->CodeMath = CycleObject,
		MUIA_HelpNode, "Math",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeMathContent,
	End;

	Object->CodePrecision = CycleObject,
		MUIA_HelpNode, "Precision",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodePrecisionContent,
	End;

	Object->CodeCPU = CycleObject,
		MUIA_HelpNode, "CPU",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeCPUContent,
	End;

	Object->CodeParms = CycleObject,
		MUIA_HelpNode, "Parameters",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeParmsContent,
	End;

	Object->CodeStkExt = CycleObject,
		MUIA_HelpNode, "StackExtend",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeStkExtContent,
	End;

	Object->CodeStkChk = CycleObject,
		MUIA_HelpNode, "StackCheck",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeStkChkContent,
	End;

	Object->CodeSaveDS = CycleObject,
		MUIA_HelpNode, "Saveds",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeSaveDSContent,
	End;

	Object->CodeDataMem = CycleObject,
		MUIA_HelpNode, "DataMemory",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeDataMemContent,
	End;

	Object->CodeAutoReg = CycleObject,
		MUIA_HelpNode, "AutoRegister",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeAutoRegContent,
	End;

	Object->CodeUtilLib = CycleObject,
		MUIA_HelpNode, "UtilityLibrary",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeUtilLibContent,
	End;

	Object->CodeConstLibBase = CycleObject,
		MUIA_HelpNode, "ConstLibBase",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeConstLibBaseContent,
	End;

	Object->CodeLibCode = CycleObject,
		MUIA_HelpNode, "LibCode",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeLibCodeContent,
	End;

	Object->CodeABSFP = CycleObject,
		MUIA_HelpNode, "AbsFuncPointer",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeABSFPContent,
	End;

	Object->CodeData = CycleObject,
		MUIA_HelpNode, "Data",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeDataContent,
	End;

	Object->CodeCode = CycleObject,
		MUIA_HelpNode, "Code",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeCodeContent,
	End;

	Object->CodeStrSect = CycleObject,
		MUIA_HelpNode, "StringSection",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeStrSectContent,
	End;

	Object->CodeCommon = CycleObject,
		MUIA_HelpNode, "Common",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeCommonContent,
	End;

	Object->CodeCoverage = CycleObject,
		MUIA_HelpNode, "Coverage",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeCoverageContent,
	End;

	Object->CodeProfile = CycleObject,
		MUIA_HelpNode, "Profile",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CodeProfileContent,
	End;

	CodeCycles = GroupObject,
		MUIA_HelpNode, "CodePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns, 3,
		Child, Object->CodeMath,
		Child, Object->CodePrecision,
		Child, Object->CodeCPU,
		Child, Object->CodeParms,
		Child, Object->CodeStkExt,
		Child, Object->CodeStkChk,
		Child, Object->CodeSaveDS,
		Child, Object->CodeDataMem,
		Child, Object->CodeAutoReg,
		Child, Object->CodeUtilLib,
		Child, Object->CodeConstLibBase,
		Child, Object->CodeLibCode,
		Child, Object->CodeABSFP,
		Child, Object->CodeData,
		Child, Object->CodeCode,
		Child, Object->CodeStrSect,
		Child, Object->CodeCommon,
		Child, Object->CodeCoverage,
		Child, Object->CodeProfile,
	End;

	Line3 = RectangleObject,
		MUIA_Rectangle_VBar, TRUE,
		MUIA_FixWidth, 10,
	End;

	REC_label_28 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->STR_CodeCodeName = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "CodeName",
	End;
	
	Object->STR_CodeDataName = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "DataName",
	End;

	Object->STR_CodeBSSName = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "BSSName",
	End;
	
	obj_aux6 = GroupObject,
		MUIA_HelpNode, "CodeName",
		MUIA_Group_Horiz, TRUE,
		MUIA_Group_Columns, 2,
		Child, Label2("CodeName"),
		Child, Object->STR_CodeCodeName,
		Child, Label2("DataName"),
		Child, Object->STR_CodeDataName,
		Child, Label2("BSSName"),
		Child, Object->STR_CodeBSSName,
	End;

	Object->STR_CodeObjName = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "ObjectName",
	End;

	Object->STR_CodeObjLib = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "ObjectLibrary",
	End;

	/*Object->STR_CodeSourceIs1 = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "SourceIs",
	End;*/
	
	Object->STR_CodeSourceIs = PopaslObject,
		MUIA_HelpNode, "SourceIs",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, String("", 192),
		MUIA_Popstring_Button, PopButton(MUII_PopFile),
	End;
	

	obj_aux12 = GroupObject,
		MUIA_HelpNode, "ObjectName",
		MUIA_Group_Horiz, TRUE,
		MUIA_Group_Columns, 2,
		Child, Label2("ObjectName"),
		Child, Object->STR_CodeObjName,
		Child, Label2("ObjectLib"),
		Child, Object->STR_CodeObjLib,
		Child, Label2("SourceIs"),
		Child, Object->STR_CodeSourceIs,
	End;

	Object->STR_CodeDis = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "DisAssemble",
	End;

	obj_aux18 = GroupObject,
		MUIA_HelpNode, "DisAssemble",
		MUIA_Group_Columns, 2,
		Child, Label2("DisAssem"),
		Child, Object->STR_CodeDis,
	End;

	CodeMisc = GroupObject,
		MUIA_HelpNode, "CodePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		MUIA_Group_Columns, 2,
		Child, obj_aux6,
		Child, obj_aux12,
	End;

	CodeMain = GroupObject,
		MUIA_HelpNode, "CodePanel",
		MUIA_Group_Horiz, FALSE,
		Child, CodeCycles,
		Child, CodeMisc,
		Child, obj_aux18,
	End;

	Code = GroupObject,
		MUIA_HelpNode, "CodePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Code Generation Options",
		Child, CodeMain,
	End;

	Object->CH_ListList = CheckMark(FALSE);

	obj_aux21 = Label2("List");

	obj_aux20 = GroupObject,
		MUIA_HelpNode, "List",
		MUIA_Group_Columns, 2,
		Child, obj_aux21,
		Child, Object->CH_ListList,
	End;

	Line9 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->ListListMacro = CycleObject,
		MUIA_HelpNode, "ListMacros",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListListMacroContent,
	End;

	Object->ListListIncludes = CycleObject,
		MUIA_HelpNode, "ListIncludes",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListListIncludesContent,
	End;

	Object->ListListHeaders = CycleObject,
		MUIA_HelpNode, "ListHeaders",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListListHeadersContent,
	End;

	Object->ListListSystem = CycleObject,
		MUIA_HelpNode, "ListSystem",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListListSystemContent,
	End;

	Object->ListListNarrow = CycleObject,
		MUIA_HelpNode, "ListNarrow",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListListNarrowContent,
	End;

	Object->ListErrorListing = CycleObject,
		MUIA_HelpNode, "ErrorList",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListErrorListingContent,
	End;

	ListCycles = GroupObject,
		MUIA_HelpNode, "List",
		MUIA_Background, MUII_BACKGROUND,
		Child, obj_aux20,
		Child, Line9,
		Child, Object->ListListMacro,
		Child, Object->ListListIncludes,
		Child, Object->ListListHeaders,
		Child, Object->ListListSystem,
		Child, Object->ListListNarrow,
		Child, Object->ListErrorListing,
	End;

	Line21a = RectangleObject,
		MUIA_Rectangle_VBar, TRUE,
		MUIA_FixWidth, 10,
	End;

	Object->CH_ListXREF = CheckMark(FALSE);

	obj_aux23 = Label2("XREF");

	obj_aux22 = GroupObject,
		MUIA_HelpNode, "XReference",
		MUIA_Group_Columns, 2,
		Child, obj_aux23,
		Child, Object->CH_ListXREF,
	End;

	Label11 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->ListXrefSystem = CycleObject,
		MUIA_HelpNode, "XReferenceSystem",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListXrefSystemContent,
	End;

	Object->ListXrefHeaders = CycleObject,
		MUIA_HelpNode, "XReferenceHeaders",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->ListXrefHeadersContent,
	End;

	ListMisc = GroupObject,
		MUIA_HelpNode, "XReference",
		MUIA_Background, MUII_BACKGROUND,
		Child, obj_aux22,
		Child, Label11,
		Child, Object->ListXrefSystem,
		Child, Object->ListXrefHeaders,
	End;

	ListMain = GroupObject,
		MUIA_HelpNode, "ListPanel",
		MUIA_Group_Horiz, TRUE,
		Child, ListCycles,
		Child, Line21a,
		Child, ListMisc,
	End;

	LA_ListXrefListFile = Label("ListFile");

	Object->STR_PA_ListXrefListFile = String("", 80);

	Object->PA_ListXrefListFile = PopButton(MUII_PopFile);

	Object->PA_ListXrefListFile = PopaslObject,
		MUIA_HelpNode, "ListFile",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_ListXrefListFile,
		MUIA_Popstring_Button, Object->PA_ListXrefListFile,
	End;

	ListXrefListFile = GroupObject,
		MUIA_HelpNode, "ListFile",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LA_ListXrefListFile,
		Child, Object->PA_ListXrefListFile,
	End;

	ListXREF = GroupObject,
		MUIA_HelpNode, "ListPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Listing/Cross Reference Options",
		Child, ListMain,
		Child, ListXrefListFile,
	End;

	Object->CH_Optimize = CheckMark(FALSE);

	obj_aux25 = Label2("Optimize");

	obj_aux24 = GroupObject,
		MUIA_HelpNode, "Optimize",
		MUIA_Group_Columns, 2,
		Child, obj_aux25,
		Child, Object->CH_Optimize,
	End;

	Line22a = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->OptimizerGlobal = CycleObject,
		MUIA_HelpNode, "OptimizerGlobal",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerGlobalContent,
	End;

	Object->OptimizerPeep = CycleObject,
		MUIA_HelpNode, "OptimizerPeephole",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerPeepContent,
	End;

	Object->OptimizerSchedule = CycleObject,
		MUIA_HelpNode, "OptimizerSchedule",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerScheduleContent,
	End;

	Object->OptimizerInline = CycleObject,
		MUIA_HelpNode, "OptimizerInline",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerInlineContent,
	End;

	Object->OptimizerInLocal = CycleObject,
		MUIA_HelpNode, "OptimizerInLocal",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerInLocalContent,
	End;

	Object->OptimizerLoop = CycleObject,
		MUIA_HelpNode, "OptimizerLoop",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerLoopContent,
	End;

	Object->OptimizerSize = CycleObject,
		MUIA_HelpNode, "OptimizerSize",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerSizeContent,
	End;

	Object->OptimizerTime = CycleObject,
		MUIA_HelpNode, "OptimizerTime",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerTimeContent,
	End;

	Object->OptimizerAlias = CycleObject,
		MUIA_HelpNode, "OptimizerAlias",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->OptimizerAliasContent,
	End;

	OptimizerCycles = GroupObject,
		MUIA_HelpNode, "OptimizerPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns, 2,
		Child, Object->OptimizerGlobal,
		Child, Object->OptimizerPeep,
		Child, Object->OptimizerSchedule,
		Child, Object->OptimizerInline,
		Child, Object->OptimizerInLocal,
		Child, Object->OptimizerLoop,
		Child, Object->OptimizerSize,
		Child, Object->OptimizerTime,
		Child, Object->OptimizerAlias,
	End;

	Object->SL_OptimizerOptComp = SliderObject,
		MUIA_HelpNode, "OptimizerComplexity",
		MUIA_Background, MUII_SHADOWBACK,
		MUIA_Frame, MUIV_Frame_Slider,
		MUIA_Slider_Min, 0,
		MUIA_Slider_Max, 256,
		MUIA_Slider_Level, 0,
	End;

	obj_aux27 = Label2("OptComp");

	obj_aux26 = GroupObject,
		MUIA_Group_Columns, 2,
		Child, obj_aux27,
		Child, Object->SL_OptimizerOptComp,
	End;

	Object->SL_OptimizerOptDepth = SliderObject,
		MUIA_HelpNode, "OptimizerDepth",
		MUIA_Background, MUII_SHADOWBACK,
		MUIA_Frame, MUIV_Frame_Slider,
		MUIA_Slider_Min, 0,
		MUIA_Slider_Max, 256,
		MUIA_Slider_Level, 0,
	End;

	obj_aux29 = Label2("OptDepth");

	obj_aux28 = GroupObject,
		MUIA_Group_Columns, 2,
		Child, obj_aux29,
		Child, Object->SL_OptimizerOptDepth,
	End;

	Object->SL_OptimizerOptRDepth = SliderObject,
		MUIA_HelpNode, "OptimizerRecurDepth",
		MUIA_Background, MUII_SHADOWBACK,
		MUIA_Frame, MUIV_Frame_Slider,
		MUIA_Slider_Min, 0,
		MUIA_Slider_Max, 256,
		MUIA_Slider_Level, 0,
	End;

	obj_aux31 = Label2("OptRDepth");

	obj_aux30 = GroupObject,
		MUIA_Group_Columns, 2,
		Child, obj_aux31,
		Child, Object->SL_OptimizerOptRDepth,
	End;

	OptimizerMisc = GroupObject,
		MUIA_HelpNode, "OptimizerPanel",
		MUIA_Background, MUII_BACKGROUND,
		Child, obj_aux26,
		Child, obj_aux28,
		Child, obj_aux30,
	End;

	OptimizerMain = GroupObject,
		MUIA_HelpNode, "OptimizerPanel",
		MUIA_Group_Horiz, FALSE,
		Child, obj_aux24,
		Child, Line22a,
		Child, OptimizerCycles,
		Child, OptimizerMisc,
	End;

	Optimizer = GroupObject,
		MUIA_HelpNode, "OptimizerPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Optimizer Options",
		Child, OptimizerMain,
	End;

	Object->CH_PrototypeGenProto = CheckMark(FALSE);

	obj_aux33 = Label2("GenProto");

	obj_aux32 = GroupObject,
		MUIA_HelpNode, "GenProtos",
		MUIA_Group_Columns, 2,
		Child, obj_aux33,
		Child, Object->CH_PrototypeGenProto,
	End;

	Object->PrototypeProtoExtern = CycleObject,
		MUIA_HelpNode, "GenProtoExterns",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->PrototypeProtoExternContent,
	End;

	Object->PrototypeGenProtoStatic = CycleObject,
		MUIA_HelpNode, "GenProtoStatics",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->PrototypeGenProtoStaticContent,
	End;

	Object->PrototypeGenProtoParm = CycleObject,
		MUIA_HelpNode, "GenProtoParameters",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->PrototypeGenProtoParmContent,
	End;

	Object->PrototypeGenProtoTypedef = CycleObject,
		MUIA_HelpNode, "GenProtoTypedefs",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->PrototypeGenProtoTypedefContent,
	End;

	Object->PrototypeGenProtoDataItem = CycleObject,
		MUIA_HelpNode, "GenProtoDataItems",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->PrototypeGenProtoDataItemContent,
	End;

	PrototypeCycles = GroupObject,
		MUIA_HelpNode, "PrototypePanel",
		MUIA_Background, MUII_BACKGROUND,
		Child, Object->PrototypeProtoExtern,
		Child, Object->PrototypeGenProtoStatic,
		Child, Object->PrototypeGenProtoParm,
		Child, Object->PrototypeGenProtoTypedef,
		Child, Object->PrototypeGenProtoDataItem,
	End;

	Line14 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	PrototypeMain = GroupObject,
		MUIA_HelpNode, "PrototypePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, FALSE,
		Child, obj_aux32,
		Child, Line14,
		Child, PrototypeCycles,
	End;

	LA_PrototypeGenProtoFile = Label("GenProtoFile");

	Object->STR_PA_PrototypeGenProtoFile = String("", 80);

	Object->PA_PrototypeGenProtoFile = PopButton(MUII_PopFile);

	Object->PA_PrototypeGenProtoFile = PopaslObject,
		MUIA_HelpNode, "GenProtoFile",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_PrototypeGenProtoFile,
		MUIA_Popstring_Button, Object->PA_PrototypeGenProtoFile,
	End;

	PrototypeFile = GroupObject,
		MUIA_HelpNode, "GenProtoFile",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LA_PrototypeGenProtoFile,
		Child, Object->PA_PrototypeGenProtoFile,
	End;

	Prototype = GroupObject,
		MUIA_HelpNode, "PrototypePanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Prototype Generation Options",
		Child, PrototypeMain,
		Child, PrototypeFile,
	End;

	Object->CH_Linker = CheckMark(FALSE);

	obj_aux35 = Label2("Link");

	obj_aux34 = GroupObject,
		MUIA_HelpNode, "Link",
		MUIA_Group_Columns, 2,
		Child, obj_aux35,
		Child, Object->CH_Linker,
	End;

	Line19 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->LinkerSmallCode = CycleObject,
		MUIA_HelpNode, "SmallCode",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->LinkerSmallCodeContent,
	End;

	Object->LinkerSmallData = CycleObject,
		MUIA_HelpNode, "SmallData",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->LinkerSmallDataContent,
	End;

	Object->LinkerAddSym = CycleObject,
		MUIA_HelpNode, "AddSymbols",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->LinkerAddSymContent,
	End;

	Object->LinkerStripDebug = CycleObject,
		MUIA_HelpNode, "StripDebug",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->LinkerStripDebugContent,
	End;

	Object->LinkerChkAbort = CycleObject,
		MUIA_HelpNode, "LinkerChkAbort",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->LinkerChkAbortContent,
	End;

	Object->LinkerBatch = CycleObject,
		MUIA_HelpNode, "Batch",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->LinkerBatchContent,
	End;

	Object->STR_LinkerLibVer = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "LibVersion",
		MUIA_String_Accept, "0123456789",
		MUIA_String_MaxLen, 6,
		MUIA_Disabled, TRUE,
	End;

	obj_aux37 = Label2("LibVer");

	obj_aux36 = GroupObject,
		MUIA_HelpNode, "LibVersion",
		MUIA_Group_Columns, 2,
		Child, obj_aux37,
		Child, Object->STR_LinkerLibVer,
	End;

	Object->STR_LinkerLibRev = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "LibRevision",
		MUIA_String_Accept, "0123456789",
		MUIA_String_MaxLen, 6,
		MUIA_Disabled, TRUE,
	End;

	obj_aux39 = Label2("LibRev");

	obj_aux38 = GroupObject,
		MUIA_HelpNode, "LibRevision",
		MUIA_Group_Columns, 2,
		Child, obj_aux39,
		Child, Object->STR_LinkerLibRev,
	End;

	Object->STR_LinkerLibPrefix = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "LibPrefix",
		MUIA_Disabled, TRUE,
	End;

	obj_aux41 = Label2("LibPrefix");

	obj_aux40 = GroupObject,
		MUIA_HelpNode, "LibPrefix",
		MUIA_Group_Columns, 2,
		Child, obj_aux41,
		Child, Object->STR_LinkerLibPrefix,
	End;

	Object->STR_LinkerLibFD = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "LibFD",
		MUIA_String_MaxLen, 140,
		MUIA_Disabled, TRUE,
	End;

	obj_aux43 = Label2("LibFD");

	obj_aux42 = GroupObject,
		MUIA_HelpNode, "LibFD",
		MUIA_Group_Columns, 2,
		Child, obj_aux43,
		Child, Object->STR_LinkerLibFD,
	End;

	LinkerCycles = GroupObject,
		MUIA_HelpNode, "LinkerPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns, 2,
		Child, Object->LinkerSmallCode,
		Child, Object->LinkerSmallData,
		Child, Object->LinkerAddSym,
		Child, Object->LinkerStripDebug,
		Child, Object->LinkerChkAbort,
		Child, Object->LinkerBatch,
		Child, obj_aux36,
		Child, obj_aux38,
		Child, obj_aux40,
		Child, obj_aux42,
	End;

	Line20 = RectangleObject,
		MUIA_Rectangle_VBar, TRUE,
		MUIA_FixWidth, 10,
	End;

	Object->LV_SpecialLinkerDefine = ListObject,
		MUIA_Frame, MUIV_Frame_InputList,
	End;

	Object->LV_SpecialLinkerDefine = ListviewObject,
		MUIA_HelpNode, "LinkerDefine",
		MUIA_Listview_List, Object->LV_SpecialLinkerDefine,
	End;

	Object->STR_LinkerLinkerDefine = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "LinkerDefine",
		MUIA_String_MaxLen, 100,
	End;

	Object->BT_SpecialLinkDefAdd = SimpleButton("Add");

	Object->BT_SpecialLinkDefDel = SimpleButton("Del");
	
	SpecialLinkerDefButtons = GroupObject,
		MUIA_HelpNode, "LinkerDefine",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, Object->STR_LinkerLinkerDefine,
		Child, Object->BT_SpecialLinkDefAdd,
		Child, Object->BT_SpecialLinkDefDel,
	End;

	LinkerLinkerDefine = GroupObject,
		MUIA_HelpNode, "LinkerDefine",
		MUIA_FrameTitle, "LinkerDefine",
		Child, Object->LV_SpecialLinkerDefine,
		Child, SpecialLinkerDefButtons,
	End;

	Object->LV_LinkerObjects = ListObject,
		MUIA_Frame, MUIV_Frame_InputList,
	End;

	Object->LV_LinkerObjects = ListviewObject,
		MUIA_HelpNode, "Library",
		MUIA_Listview_List, Object->LV_LinkerObjects,
	End;

	Object->STR_PA_LinkerObjects = String("", 80);

	Object->PA_LinkerObjects = PopButton(MUII_PopFile);

	Object->PA_LinkerObjects = PopaslObject,
		MUIA_HelpNode, "Library",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_LinkerObjects,
		MUIA_Popstring_Button, Object->PA_LinkerObjects,
	End;

	Object->BT_LinkerLinkerObjAdd = SimpleButton("Add");
	Object->BT_LinkerLinkerObjDel = SimpleButton("Del");
	
	LinkerObjectsButtons = GroupObject,
		MUIA_HelpNode, "Library",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, Object->PA_LinkerObjects,
		Child, Object->BT_LinkerLinkerObjAdd,
		Child, Object->BT_LinkerLinkerObjDel,
	End;

	Object->STR_LinkerLinkerOpts = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "LinkerOptions",
	End;

	obj_aux45 = Label2("LinkerOpts");

	obj_aux44 = GroupObject,
		MUIA_HelpNode, "LinkerOptions",
		MUIA_Group_Columns, 2,
		Child, obj_aux45,
		Child, Object->STR_LinkerLinkerOpts,
	End;

	Line22 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	LA_LinkerCustom = Label("Custom");

	Object->STR_PA_LinkerCustomStartup = String("", 80);

	Object->PA_LinkerCustom = PopButton(MUII_PopFile);

	Object->PA_LinkerCustom = PopaslObject,
		MUIA_HelpNode, "Custom",
		MUIA_Popasl_Type, 0,
		MUIA_Disabled, TRUE,
		MUIA_Popstring_String, Object->STR_PA_LinkerCustomStartup,
		MUIA_Popstring_Button, Object->PA_LinkerCustom,
	End;

	LinkerStartup = GroupObject,
		MUIA_HelpNode, "Custom",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LA_LinkerCustom,
		Child, Object->PA_LinkerCustom,
	End;

	Object->CY_LinkerStartup = CycleObject,
		MUIA_HelpNode, "Startup",
		MUIA_Disabled, FALSE,
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_LinkerStartupContent,
	End;

	LinkerObjects = GroupObject,
		MUIA_HelpNode, "LinkerObjects",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_FrameTitle, "Libraries/Objects",
		Child, Object->LV_LinkerObjects,
		Child, LinkerObjectsButtons,
	End;

	LinkerMisc = GroupObject,
		MUIA_HelpNode, "LinkerMisc",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LinkerLinkerDefine,
		Child, LinkerObjects,
	End;

	LinkerMain = GroupObject,
		MUIA_HelpNode, "LinkerMain",
		MUIA_Group_Horiz, FALSE,
		Child, obj_aux34,
		Child, Line19,
		Child, LinkerCycles,
		Child, LinkerMisc,
		Child, Object->CY_LinkerStartup,
		Child, LinkerStartup,
		Child, obj_aux44,
	End;

	Linker = GroupObject,
		MUIA_HelpNode, "Linker",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Linker Options",
		Child, LinkerMain,
	End;

	Object->CH_MapMap = CheckMark(FALSE);

	obj_aux49 = Label2("Map");

	obj_aux48 = GroupObject,
		MUIA_HelpNode, "Map",
		MUIA_Group_Columns, 2,
		Child, obj_aux49,
		Child, Object->CH_MapMap,
	End;

	Line21 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->CY_MapMapHunk = CycleObject,
		MUIA_HelpNode, "MapHunk",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_MapMapHunkContent,
	End;

	Object->CY_MapMapSymbols = CycleObject,
		MUIA_HelpNode, "MapSymbols",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_MapMapSymbolsContent,
	End;

	Object->CY_MapMapLibraries = CycleObject,
		MUIA_HelpNode, "MapLib",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_MapMapLibrariesContent,
	End;

	Object->CY_MapMapXref = CycleObject,
		MUIA_HelpNode, "MapXreference",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_MapMapXrefContent,
	End;

	Object->CY_MapMapOverlay = CycleObject,
		MUIA_HelpNode, "MapOverlay",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_MapMapOverlayContent,
	End;

	LA_MapMapFile = Label("MapFile");

	Object->STR_PA_MapMapFile = String("", 80);

	Object->PA_MapMapFile = PopButton(MUII_PopFile);

	Object->PA_MapMapFile = PopaslObject,
		MUIA_HelpNode, "MapFile",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_MapMapFile,
		MUIA_Popstring_Button, Object->PA_MapMapFile,
	End;

	MapMapFileButtons = GroupObject,
		MUIA_HelpNode, "MapFile",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Horiz, TRUE,
		Child, LA_MapMapFile,
		Child, Object->PA_MapMapFile,
	End;

	MapMain = GroupObject,
		MUIA_HelpNode, "MapPanel",
		Child, obj_aux48,
		Child, Line21,
		Child, Object->CY_MapMapHunk,
		Child, Object->CY_MapMapSymbols,
		Child, Object->CY_MapMapLibraries,
		Child, Object->CY_MapMapXref,
		Child, Object->CY_MapMapOverlay,
		Child, MapMapFileButtons,
	End;

	Map = GroupObject,
		HVSpace, TRUE,
		MUIA_HelpNode, "MapPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Map Options",
		Child, MapMain,
	End;

	Object->CY_SpecialVerbose = CycleObject,
		MUIA_HelpNode, "Verbose",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialVerboseContent,
	End;

	Object->CY_SpecialVersion = CycleObject,
		MUIA_HelpNode, "Version",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialVersionContent,
	End;

	Object->CY_SpecialDollar = CycleObject,
		MUIA_HelpNode, "DollarOK",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialDollarContent,
	End;

	Object->CY_SpecialExtDef = CycleObject,
		MUIA_HelpNode, "ExternalDefs",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialExtDefContent,
	End;

	Object->CY_SpecialKeepLine = CycleObject,
		MUIA_HelpNode, "KeepLine",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialKeepLineContent,
	End;

	Object->CY_SpecialOldPP = CycleObject,
		MUIA_HelpNode, "OldPreProcessor",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialOldPPContent,
	End;

	Object->CY_SpecialTrigraph = CycleObject,
		MUIA_HelpNode, "Trigraph",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialTrigraphContent,
	End;

	Object->CY_SpecialUnderScore = CycleObject,
		MUIA_HelpNode, "Underscore",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_Cycle_Entries, Object->CY_SpecialUnderScoreContent,
	End;

	SpecialCycles = GroupObject,
		MUIA_HelpNode, "SpecialPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns, 2,
		MUIA_Group_SameSize, TRUE,
		Child, Object->CY_SpecialVerbose,
		Child, Object->CY_SpecialVersion,
		Child, Object->CY_SpecialDollar,
		Child, Object->CY_SpecialExtDef,
		Child, Object->CY_SpecialKeepLine,
		Child, Object->CY_SpecialOldPP,
		Child, Object->CY_SpecialTrigraph,
		Child, Object->CY_SpecialUnderScore,
	End;

	Object->STR_SpecialArgSize = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "ArgumentSize",
		MUIA_String_Accept, "-0123456789",
		MUIA_String_MaxLen, 8,
	End;

	obj_aux51 = Label2("ArgumentSize");

	obj_aux50 = GroupObject,
		MUIA_HelpNode, "ArgumentSize",
		MUIA_Group_Columns, 2,
		Child, obj_aux51,
		Child, Object->STR_SpecialArgSize,
	End;

	Object->STR_SpecialFindSymbol = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "FindSymbol",
		MUIA_String_MaxLen, 90,
	End;

	obj_aux53 = Label2("FindSymbol");

	obj_aux52 = GroupObject,
		MUIA_HelpNode, "FindSymbol",
		MUIA_Group_Columns, 2,
		Child, obj_aux53,
		Child, Object->STR_SpecialFindSymbol,
	End;

	Object->STR_SpecialIdLength = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "IdentifierLength",
		MUIA_String_Accept, "-0123456789",
		MUIA_String_MaxLen, 10,
	End;

	obj_aux55 = Label2("IdentifierLength");

	obj_aux54 = GroupObject,
		MUIA_HelpNode, "IdentifierLength",
		MUIA_Group_Columns, 2,
		Child, obj_aux55,
		Child, Object->STR_SpecialIdLength,
	End;

	Object->STR_SpecialPPBufSize = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "PreprocessorBuffer",
		MUIA_String_Accept, "-0123456789",
		MUIA_String_MaxLen, 10,
	End;

	obj_aux57 = Label2("PreProcessorBuffer");

	obj_aux56 = GroupObject,
		MUIA_HelpNode, "PreprocessorBuffer",
		MUIA_Group_Columns, 2,
		Child, obj_aux57,
		Child, Object->STR_SpecialPPBufSize,
	End;

	SpecialMisc = GroupObject,
		MUIA_HelpNode, "SpecialPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Group_Columns,2,
		MUIA_Group_SameSize, TRUE,
		Child, obj_aux50,
		Child, obj_aux52,
		Child, obj_aux54,
		Child, obj_aux56,
	End;

	SpecialMain = GroupObject,
		MUIA_HelpNode, "SpecialPanel",
		MUIA_Group_Horiz, FALSE,
		Child, SpecialCycles,
		Child, SpecialMisc,
	End;

	Line26 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->CH_SpecialResetOpts = CheckMark(FALSE);

	obj_aux59 = Label2("Reset Options");

	obj_aux58 = GroupObject,
		MUIA_HelpNode, "ResetOptions",
		MUIA_Group_Columns, 2,
		Child, obj_aux59,
		Child, Object->CH_SpecialResetOpts,
	End;

	Special = GroupObject,
		MUIA_HelpNode, "SpecialPanel",
		MUIA_Background, MUII_BACKGROUND,
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Special Options",
		MUIA_Group_Horiz, FALSE,
		MUIA_Group_SameWidth, TRUE,
		Child, SpecialMain,
		Child, Line26,
		Child, obj_aux58,
	End;

	Object->OptionsPanel = RegisterObject,
		MUIA_Register_Titles, Object->STR_OptionsPanel,
		MUIA_HelpNode, "MainPanel",
		MUIA_Frame, MUIV_Frame_Virtual,
		MUIA_FrameTitle, "System Options",
		Child, Compiler,
		Child, Message,
		Child, Code,
		Child, ListXREF,
		Child, Optimizer,
		Child, Prototype,
		Child, Linker,
		Child, Map,
		Child, Special,
	End;

	LA_ProgName = Label("Program Name");

	Object->STR_PA_ProgramName = String("", 80);

	Object->PA_ProgramName = PopButton(MUII_PopFile);

	Object->PA_ProgramName = PopaslObject,
		MUIA_HelpNode, "ProgramName",
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, Object->STR_PA_ProgramName,
		MUIA_Popstring_Button, Object->PA_ProgramName,
	End;

	ProgramName = GroupObject,
		HVSpace, TRUE,
		MUIA_HelpNode, "ProgramName",
		MUIA_Frame, MUIV_Frame_String,
		MUIA_Group_Horiz, TRUE,
		Child, LA_ProgName,
		Child, Object->PA_ProgramName,
	End;

	Line999 = RectangleObject,
		MUIA_Rectangle_HBar, TRUE,
		MUIA_FixHeight, 8,
	End;

	Object->BT_SaveOpts = SimpleButton("Sa_ve");

	Space_5 = HVSpace;

	Object->BT_SaveDefOpts = SimpleButton("Save Defaul_t");

	Space_6 = HVSpace;

	Object->BT_Cancel = SimpleButton("Ca_ncel");

	ActionButtons = GroupObject,
		HVSpace, TRUE,
		MUIA_HelpNode, "MainPanel",
		MUIA_Group_Horiz, TRUE,
		Child, Object->BT_SaveOpts,
		Child, Space_5,
		Child, Object->BT_SaveDefOpts,
		Child, Space_6,
		Child, Object->BT_Cancel,
	End;

	MainWindow = GroupObject,
		HVSpace, TRUE,
		MUIA_Frame, MUIV_Frame_Virtual,
		Child, Object->OptionsPanel,
		Child, ProgramName,
		Child, Line999,
		Child, ActionButtons,
	End;

	MNlabel1SASCOptions = MenuitemObject,
		MUIA_Menuitem_Title, "SAS/C Options+",
		MUIA_Menuitem_Shortcut, "?",
	End;

	MNlabel1MUI = MenuitemObject,
		MUIA_Menuitem_Title, "MUI",
	End;

	MNlabel1About = MenuitemObject,
		MUIA_Menuitem_Title, "About",
		MUIA_Family_Child, MNlabel1SASCOptions,
		MUIA_Family_Child, MNlabel1MUI,
	End;

	MNlabel1BarLabel0 = MUI_MakeObject(MUIO_Menuitem, NM_BARLABEL, 0, 0, 0);

	MNlabel1fromSCOPTIONS = MenuitemObject,
		MUIA_Menuitem_Title, "from SCOPTIONS",
	End;

	MNlabel1fromGlobalDefaultsENV = MenuitemObject,
		MUIA_Menuitem_Title, "from Global Defaults (ENV:)",
	End;

	MNlabel1from = MenuitemObject,
		MUIA_Menuitem_Title, "from...",
	End;

	MNlabel1toSASCDefaults = MenuitemObject,
		MUIA_Menuitem_Title, "to SAS/C Defaults",
	End;

	MNlabel1Restore = MenuitemObject,
		MUIA_Menuitem_Title, "Restore",
		MUIA_Family_Child, MNlabel1fromSCOPTIONS,
		MUIA_Family_Child, MNlabel1fromGlobalDefaultsENV,
		MUIA_Family_Child, MNlabel1from,
		MUIA_Family_Child, MNlabel1toSASCDefaults,
	End;

	MNlabel1BarLabel1 = MUI_MakeObject(MUIO_Menuitem, NM_BARLABEL, 0, 0, 0);

	MNlabel1toSCOPTIONS = MenuitemObject,
		MUIA_Menuitem_Title, "to SCOPTIONS",
	End;

	MNlabel1asGlobalDefaults = MenuitemObject,
		MUIA_Menuitem_Title, "as Global Defaults",
	End;

	MNlabel1as = MenuitemObject,
		MUIA_Menuitem_Title, "as...",
	End;

	MNlabel1Save = MenuitemObject,
		MUIA_Menuitem_Title, "Save",
		MUIA_Family_Child, MNlabel1toSCOPTIONS,
		MUIA_Family_Child, MNlabel1asGlobalDefaults,
		MUIA_Family_Child, MNlabel1as,
	End;

	MNlabel1BarLabel2 = MUI_MakeObject(MUIO_Menuitem, NM_BARLABEL, 0, 0, 0);

	MNlabel1BarLabel3 = MUI_MakeObject(MUIO_Menuitem, NM_BARLABEL, 0, 0, 0);

	MNlabel1BarLabel4 = MUI_MakeObject(MUIO_Menuitem, NM_BARLABEL, 0, 0, 0);
	
	MNlabel1MUIPrefs = MenuitemObject,
		MUIA_Menuitem_Title, "MUI Preferences...",
	End;

	MNlabel1Iconify = MenuitemObject,
		MUIA_Menuitem_Title, "Iconify",
		MUIA_Menuitem_Shortcut, "H",
	End;
	
	MNlabel1Quit = MenuitemObject,
		MUIA_Menuitem_Title, "Quit",
		MUIA_Menuitem_Shortcut, "Q",
	End;

	MNlabel1Project = MenuitemObject,
		MUIA_Menuitem_Title, "Project",
		MUIA_Family_Child, MNlabel1About,
		MUIA_Family_Child, MNlabel1BarLabel0,
		MUIA_Family_Child, MNlabel1Restore,
		MUIA_Family_Child, MNlabel1BarLabel1,
		MUIA_Family_Child, MNlabel1Save,
		MUIA_Family_Child, MNlabel1BarLabel2,
		MUIA_Family_Child, MNlabel1MUIPrefs,
		MUIA_Family_Child, MNlabel1BarLabel3,
		MUIA_Family_Child, MNlabel1Iconify,
		MUIA_Family_Child, MNlabel1BarLabel4,
		MUIA_Family_Child, MNlabel1Quit,
	End;

	Object->ProgramMenu = MenustripObject,
		MUIA_Family_Child, MNlabel1Project,
	End;

	Object->SCOPTS_MainWin = WindowObject,
		MUIA_HelpNode, "Main",
		MUIA_Window_Title, "SAS/C ® Compiler Options",
		MUIA_Window_Menustrip, Object->ProgramMenu,
		MUIA_Window_ID, MAKE_ID('0', 'W', 'I', 'N'),
		MUIA_Window_CloseGadget, FALSE,
		MUIA_Window_ScreenTitle, "SCOpts+ for SAS/C v6r59+ ("__DATE__"). © 1997, Infinity Labs Development.",
		WindowContents, MainWindow,
	End;

	Object->App = ApplicationObject,
		MUIA_Application_Author, "Manolis S. Pappas",
		MUIA_Application_Base, "SCOpts+",
		MUIA_Application_Title, "SCOpts+",
		MUIA_Application_Version, "$VER: SCOpts+ for SAS/C r6.59+",
		MUIA_Application_Copyright, "© 1997, Infinity Labs Development",
		MUIA_Application_Description, "Extended SAS/C Options Preferences",
		MUIA_Application_UseRexx, FALSE,
		MUIA_Application_HelpFile, "sc:help/sc.guide",
		SubWindow, Object->SCOPTS_MainWin,
	End;


	if (!Object->App)
	{
		FreeVec(Object);
		return(NULL);
	}

	DoMethod(MNlabel1MUIPrefs,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_Application_OpenConfigWindow,0
		);
		
	DoMethod(MNlabel1Iconify,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Iconified, TRUE
		);
		
	DoMethod(MNlabel1SASCOptions,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_ABOUTHook
		);

	DoMethod(MNlabel1MUI,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_ABOUT_MUIHook
		);

	DoMethod(MNlabel1fromSCOPTIONS,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1fromSCOPTIONS,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_RESTORE_SCOPTSHook
		);

	DoMethod(MNlabel1fromSCOPTIONS,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1fromGlobalDefaultsENV,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1fromGlobalDefaultsENV,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_RESTORE_ENVHook
		);

	DoMethod(MNlabel1fromGlobalDefaultsENV,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1from,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1from,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_RESTOREHook
		);

	DoMethod(MNlabel1from,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1toSASCDefaults,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1toSASCDefaults,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_RESTORE_DEFHook
		);

	DoMethod(MNlabel1toSASCDefaults,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1toSCOPTIONS,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1toSCOPTIONS,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_SAVE_SCOPTSHook
		);

	DoMethod(MNlabel1toSCOPTIONS,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1asGlobalDefaults,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1asGlobalDefaults,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_SAVE_ENVHook
		);

	DoMethod(MNlabel1asGlobalDefaults,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1as,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(MNlabel1as,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_CallHook, &h_SAVEHook
		);

	DoMethod(MNlabel1as,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(MNlabel1Quit,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->SCOPTS_MainWin,
		3,
		MUIM_Set, MUIA_Window_Open, FALSE
		);

	DoMethod(MNlabel1Quit,
		MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime,
		Object->App,
		2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit
		);

	DoMethod(Object->BT_CompIncDir_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->PA_CompilerIncDir,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_CompIncDir_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_CompIncDir_Del,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_CompIncDir_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->PA_CompilerIncDir,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_CompIncDir_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_CompIncDir_Del,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_CompDefine_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->STR_CompDefine,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_CompDefine_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_CompInclude_Del,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_CompInclude_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->STR_CompDefine,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_CompInclude_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_CompInclude_Del,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_MessageEWI_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->STR_MessageEWI,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_MessageEWI_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->MessageEWIButton_CYCLE,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_MessageEWI_Add,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_MessageEWI_Del,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_MessageEWI_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->STR_MessageEWI,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_MessageEWI_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->MessageEWIButton_CYCLE,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_MessageEWI_Del,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_MessageEWI_Del,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->CH_Linker,
		MUIM_Notify, MUIA_Selected, TRUE,
		Object->LinkerSmallCode,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_SpecialLinkDefAdd,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_SpecialLinkDefDel,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_SpecialLinkDefAdd,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->STR_LinkerLinkerDefine,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(Object->BT_SpecialLinkDefDel,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->BT_SpecialLinkDefDel,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_SpecialLinkDefDel,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->STR_LinkerLinkerDefine,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(Object->BT_SaveOpts,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->SCOPTS_MainWin,
		2,
		MUIM_CallHook, &h_SAVE_SCOPTSHook
		);

	DoMethod(Object->BT_SaveOpts,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->SCOPTS_MainWin,
		3,
		MUIM_Set, MUIA_Window_Open, FALSE
		);

	DoMethod(Object->BT_SaveOpts,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->App,
		2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit
		);

	DoMethod(Object->BT_SaveDefOpts,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->SCOPTS_MainWin,
		2,
		MUIM_CallHook, &h_SAVE_ENVHook
		);

	DoMethod(Object->BT_SaveDefOpts,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->SCOPTS_MainWin,
		3,
		MUIM_Set, MUIA_Window_Open, FALSE
		);

	DoMethod(Object->BT_SaveDefOpts,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->App,
		2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit
		);

	DoMethod(Object->BT_Cancel,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->SCOPTS_MainWin,
		3,
		MUIM_Set, MUIA_Window_Open, FALSE
		);

	DoMethod(Object->BT_Cancel,
		MUIM_Notify, MUIA_Pressed, FALSE,
		Object->App,
		2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit
		);

	DoMethod(Object->SCOPTS_MainWin,
		MUIM_Window_SetCycleChain, Object->OptionsPanel,
		Object->CompilerDebug,
		Object->CompilerIntegers,
		Object->CompilerStr,
		Object->CompilerUChar,
		Object->CompilerComment,
		Object->CompilerIcons,
		Object->CompilerMod,
		Object->CompilerPP,
		Object->CompilerCXX,
		Object->CompilerMem,
		Object->CompilerStrConst,
		Object->CompilerWVR,
		Object->CompilerMCC,
		Object->CompilerMInclude,
		Object->CompilerGSTImm,
		Object->LV_CompIncDir,
		Object->PA_CompilerIncDir,
		Object->BT_CompIncDir_Add,
		Object->BT_CompIncDir_Del,
		Object->LV_CompDefine,
		Object->STR_CompDefine,
		Object->BT_CompDefine_Add,
		Object->BT_CompInclude_Del,
		Object->PA_CompilerGST,
		Object->PA_CompilerMakeGST,
		Object->MessageAnsi,
		Object->MessageStrict,
		Object->MessageErrRexx,
		Object->MessageErrCon,
		Object->MessageErrList,
		Object->MessageErrSrc,
		Object->MessageErrHl,
		Object->MessageStrEq,
		Object->MessageOnErr,
		Object->LV_MessageEWI,
		Object->STR_MessageEWI,
		Object->MessageEWIButton_CYCLE,
		Object->BT_MessageEWI_Add,
		Object->BT_MessageEWI_Del,
		Object->STR_MessageMaxErr,
		Object->STR_MessageMaxWarn,
		Object->STR_MessagePubScr,
		Object->CodeMath,
		Object->CodePrecision,
		Object->CodeCPU,
		Object->CodeParms,
		Object->CodeStkExt,
		Object->CodeStkChk,
		Object->CodeSaveDS,
		Object->CodeDataMem,
		Object->CodeAutoReg,
		Object->CodeUtilLib,
		Object->CodeConstLibBase,
		Object->CodeLibCode,
		Object->CodeABSFP,
		Object->CodeData,
		Object->CodeCode,
		Object->CodeStrSect,
		Object->CodeCommon,
		Object->CodeCoverage,
		Object->CodeProfile,
		Object->STR_CodeCodeName,
		Object->STR_CodeDataName,
		Object->STR_CodeBSSName,
		Object->STR_CodeObjName,
		Object->STR_CodeObjLib,
		Object->STR_CodeSourceIs,
		Object->STR_CodeDis,
		Object->CH_ListList,
		Object->ListListMacro,
		Object->ListListIncludes,
		Object->ListListHeaders,
		Object->ListListSystem,
		Object->ListListNarrow,
		Object->ListErrorListing,
		Object->CH_ListXREF,
		Object->ListXrefSystem,
		Object->ListXrefHeaders,
		Object->PA_ListXrefListFile,
		Object->CH_Optimize,
		Object->OptimizerGlobal,
		Object->OptimizerPeep,
		Object->OptimizerSchedule,
		Object->OptimizerInline,
		Object->OptimizerInLocal,
		Object->OptimizerLoop,
		Object->OptimizerSize,
		Object->OptimizerTime,
		Object->OptimizerAlias,
		Object->SL_OptimizerOptComp,
		Object->SL_OptimizerOptDepth,
		Object->SL_OptimizerOptRDepth,
		Object->CH_PrototypeGenProto,
		Object->PrototypeProtoExtern,
		Object->PrototypeGenProtoStatic,
		Object->PrototypeGenProtoParm,
		Object->PrototypeGenProtoTypedef,
		Object->PrototypeGenProtoDataItem,
		Object->PA_PrototypeGenProtoFile,
		Object->CH_Linker,
		Object->LinkerSmallCode,
		Object->LinkerSmallData,
		Object->LinkerAddSym,
		Object->LinkerStripDebug,
		Object->LinkerChkAbort,
		Object->LinkerBatch,
		Object->STR_LinkerLibVer,
		Object->STR_LinkerLibRev,
		Object->STR_LinkerLibPrefix,
		Object->STR_LinkerLibFD,
		Object->LV_SpecialLinkerDefine,
		Object->STR_LinkerLinkerDefine,
		Object->BT_SpecialLinkDefAdd,
		Object->BT_SpecialLinkDefDel,
		Object->LV_LinkerObjects,
		Object->PA_LinkerObjects,
		Object->BT_LinkerLinkerObjAdd,
		Object->BT_LinkerLinkerObjDel,
		Object->STR_LinkerLinkerOpts,
		Object->CY_LinkerStartup,
		Object->STR_LinkerCustomStartup,
		Object->CH_MapMap,
		Object->CY_MapMapHunk,
		Object->CY_MapMapSymbols,
		Object->CY_MapMapLibraries,
		Object->CY_MapMapXref,
		Object->CY_MapMapOverlay,
		Object->PA_MapMapFile,
		Object->CY_SpecialVerbose,
		Object->CY_SpecialVersion,
		Object->CY_SpecialDollar,
		Object->CY_SpecialExtDef,
		Object->CY_SpecialKeepLine,
		Object->CY_SpecialOldPP,
		Object->CY_SpecialTrigraph,
		Object->CY_SpecialUnderScore,
		Object->STR_SpecialArgSize,
		Object->STR_SpecialFindSymbol,
		Object->STR_SpecialIdLength,
		Object->STR_SpecialPPBufSize,
		Object->CH_SpecialResetOpts,
		Object->PA_ProgramName,
		Object->BT_SaveOpts,
		Object->BT_SaveDefOpts,
		Object->BT_Cancel,
		0
		);

	set(Object->SCOPTS_MainWin,
		MUIA_Window_Open, TRUE
		);


	return(Object);
}

void DisposeApp(struct ObjApp * Object)
{
	MUI_DisposeObject(Object->App);
	FreeVec(Object);
}
