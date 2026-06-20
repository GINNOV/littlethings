
	
		; *** EXEC - Library ***
		; (Release 3.0)
		
execbase     = 4

Supervisor	=	-30
InitCode	=	-72
InitStruct	=	-78
MakeLibrary	=	-84
MakeFunctions	=	-90
FindResident	=	-96
InitResident	=	-102
Alert		=	-108
Debug		=	-114
Disable		=	-120
Enable		=	-126
Forbid		=	-132
Permit		=	-138
SetSR		=	-144
SuperState	=	-150
UserState	=	-156
SetIntVector	=	-162
AddIntServer	=	-168
RemIntServer	=	-174
Cause		=	-180
Allocate	=	-186
Deallocate	=	-192
AllocMem	=	-198
AllocAbs	=	-204
FreeMem		=	-210
AvailMem	=	-216
AllocEntry	=	-222
FreeEntry	=	-228
Insert		=	-234
AddHead		=	-240
AddTail		=	-246
Remove		=	-252
RemHead		=	-258
RemTail		=	-264
Enqueue		=	-270
FindName	=	-276
AddTask		=	-282
RemTask		=	-288
FindTask	=	-294
SetTaskPri	=	-300
SetSignal	=	-306
SetExcept	=	-312
Wait		=	-318
Signal		=	-324
AllocSignal	=	-330
FreeSignal	=	-336
AllocTrap	=	-342
FreeTrap	=	-348
AddPort		=	-354
RemPort		=	-360
PutMsg		=	-366
GetMsg		=	-372
ReplyMsg	=	-378
WaitPort	=	-384
FindPort	=	-390
AddLibrary	=	-396
RemLibrary	=	-402
OldOpenLibrary	=	-408
CloseLibrary	=	-414
SetFunction	=	-420
SumLibrary	=	-426
AddDevice	=	-432
RemDevice	=	-438
OpenDevice	=	-444
CloseDevice	=	-450
DoIO		=	-456
SendIO		=	-462
CheckIO		=	-468
WaitIO		=	-474
AbortIO		=	-480
AddResource	=	-486
RemResource	=	-492
OpenResource	=	-498
RawDoFmt	=	-522
GetCC		=	-528
TypeOfMem	=	-534
Procure		=	-540
Vacate		=	-546
OpenLibrary	=	-552
InitSemaphore	=	-558
ObtainSemaphore	=	-564
ReleaseSemaphore=	-570
AttemptSemaphore=	-576
ObtainSemaphoreList=	-582
ReleaseSemaphoreList=	-588
FindSemaphore	=	-594
AddSemaphore	=	-600
RemSemaphore	=	-606
SumKickData	=	-612
AddMemList	=	-618
CopyMem		=	-624
CopyMemQuick	=	-630
CacheClearU	=	-636
CacheClearE	=	-642
CacheControl	=	-648
CreateIOREQUest	=	-654
DeleteIORequest	=	-660
CreateMsgPort	=	-666
DeleteMsgPort	=	-672
ObtainSemaphoreShared=	-678
AllocVec	=	-684
FreeVec		=	-690
CreatePool	=	-696
DeletePool	=	-702
AllocPooled	=	-708
FreePooled	=	-714
AttemptSemaphoreShared=	-720
ColdReboot	=	-726
StackSwap	=	-732
ChildFree	=	-738
ChildOrphan	=	-744
ChildStatus	=	-750
ChildWait	=	-756
CachePreDMA	=	-762
CachePostDMA	=	-768
AddMemHandler	=	-774
RemMemHandler	=	-780

		; *** DOS - Library ***
		; (Release 3.0)

Open	=	-30
Close	=	-36
Read	=	-42
Write	=	-48
Input	=	-54
Output	=	-60
Seek	=	-66
DeleteFile	=	-72
Rename	=	-78
Lock	=	-84
UnLock	=	-90
DupLock	=	-96
Examine	=	-102
ExNext	=	-108
Info	=	-114
CreateDir	=	-120
CurrentDir	=	-126
IoErr	=	-132
CreateProc	=	-138
Exit	=	-144
LoadSeg	=	-150
UnLoadSeg	=	-156
DeviceProc	=	-174
SetComment	=	-180
SetProtection	=	-186
DateStamp	=	-192
Delay	=	-198
WaitForChar	=	-204
ParentDir	=	-210
IsInteractive	=	-216
Execute	=	-222
AllocDosObject	=	-228
FreeDosObject	=	-234
DoPkt	=	-240
SendPkt	=	-246
WaitPkt	=	-252
ReplyPkt	=	-258
AbortPkt	=	-264
LockRecord	=	-270
LockRecords	=	-276
UnLockRecord	=	-282
UnLockRecords	=	-288
SelectInput	=	-294
SelectOutput	=	-300
FGetC	=	-306
FPutC	=	-312
UnGetC	=	-318
FRead	=	-324
FWrite	=	-330
FGets	=	-336
FPuts	=	-342
VFWritef	=	-348
VFPrintf	=	-354
Flush	=	-360
SetVBuf	=	-366
DupLockFromFH	=	-372
OpenFromLock	=	-378
ParentOfFH	=	-384
ExamineFH	=	-390
SetFileDate	=	-396
NameFromLock	=	-402
NameFromFH	=	-408
SplitName	=	-414
SameLock	=	-420
SetMode	=	-426
ExAll	=	-432
ReadLink	=	-438
MakeLink	=	-444
ChangeMode	=	-450
SetFileSize	=	-456
SetIoErr	=	-462
Fault	=	-468
PrintFault	=	-474
ErrorReport	=	-480
Cli	=	-492
CreateNewProc	=	-498
RunCommand	=	-504
GetConsoleTask	=	-510
SetConsoleTask	=	-516
GetFileSysTask	=	-522
SetFileSysTask	=	-528
GetArgStr	=	-534
SetArgStr	=	-540
FindCliProc	=	-546
MaxCli	=	-552
SetCurrentDirName	=	-558
GetCurrentDirName	=	-564
SetProgramName	=	-570
GetProgramName	=	-576
SetPrompt	=	-582
GetPrompt	=	-588
SetProgramDir	=	-594
GetProgramDir	=	-600
SystemTagList	=	-606
AssignLock	=	-612
AssignLate	=	-618
AssignPath	=	-624
AssignAdd	=	-630
RemAssignList	=	-636
GetDeviceProc	=	-642
FreeDeviceProc	=	-648
LockDosList	=	-654
UnLockDosList	=	-660
AttemptLockDosList	=	-666
RemDosEntry	=	-672
AddDosEntry	=	-678
FindDosEntry	=	-684
NextDosEntry	=	-690
MakeDosEntry	=	-696
FreeDosEntry	=	-702
IsFileSystem	=	-708
Format	=	-714
Relabel	=	-720
Inhibit	=	-726
AddBuffers	=	-732
CompareDates	=	-738
DateToStr	=	-744
StrToDate	=	-750
InternalLoadSeg	=	-756
InternalUnLoadSeg	=	-762
NewLoadSeg	=	-768
AddSegment	=	-774
FindSegment	=	-780
RemSegment	=	-786
CheckSignal	=	-792
ReadArgs	=	-798
FindArg	=	-804
ReadItem	=	-810
StrToLong	=	-816
MatchFirst	=	-822
MatchNext	=	-828
MatchEnd	=	-834
ParsePattern	=	-840
MatchPattern	=	-846
FreeArgs	=	-858
FilePart	=	-870
PathPart	=	-876
AddPart	=	-882
StartNotify	=	-888
EndNotify	=	-894
SetVar	=	-900
GetVar	=	-906
DeleteVar	=	-912
FindVar	=	-918
CliInitNewcli	=	-930
CliInitRun	=	-936
WriteChars	=	-942
PutStr	=	-948
VPrintf	=	-954
ParsePatternNoCase	=	-966
MatchPatternNoCase	=	-972
SameDevice	=	-984
ExAllEnd	=	-990
SetOwner	=	-996

mode_new     = 1006
mode_old     = 1005

Offset_Beginning = -1
Offset_end       = 1
Offset_Current   = 0

Access_read	 = -2
Access_Write     = -1

DosTrue		 = -1
DosFalse	 = 0

True=Dostrue
False=DosFalse
Null=0

HIRES      = $8000
JAM1       = 0
JAM2       = 1
COMPLEMENT = 2
INVERSVID  = 4


; ---===* DISKFONT.LIBRARY *===----

OpenDiskfont = -30

		; *** ASL - LIBRARY ***
		; (Release 2.0)

AllocFileRequest = -30
FreeFileRequest  = -36 
RequestFile 	   = -42
AllocAslRequest    = -48
FreeAslRequest     = -54
AslRequest 	   = -60

		; *** INTUITION - Library ***
		; (Release 3.0)

OpenIntuition	=	-30
Intuition	=	-36
AddGadget	=	-42
ClearDMREQUest	=	-48
ClearMenuStrip	=	-54
ClearPointer	=	-60
CloseScreen	=	-66
CloseWindow	=	-72
CloseWorkBench	=	-78
CurrentTime	=	-84
DisplayAlert	=	-90
DisplayBeep	=	-96
DoubleClick	=	-102
DrawBorder	=	-108
DrawImage	=	-114
EndREQUest	=	-120
GetDefPrefs	=	-126
GetPrefs	=	-132
InitREQUester	=	-138
ItemAddress	=	-144
ModifyIDCMP	=	-150
ModifyProp	=	-156
MoveScreen	=	-162
MoveWindow	=	-168
OffGadget	=	-174
OffMenu		=	-180
OnGadget	=	-186
OnMenu		=	-192
OpenScreen	=	-198
OpenWindow	=	-204
OpenWorkBench	=	-210
PrintIText	=	-216
RefreshGadgets	=	-222
RemoveGadget	=	-228
ReportMouse	=	-234
REQUest		=	-240
ScreenToBack	=	-246
ScreenToFront	=	-252
SetDMREQUest	=	-258
SetMenuStrip	=	-264
SetPointer	=	-270
SetWindowTitles	=	-276
IShowTitle	=	-282
SizeWindow	=	-288
ViewAddress	=	-294
ViewPortAddress	=	-300
WindowToBack	=	-306
WindowToFront	=	-312
WindowLimits	=	-318
SetPrefs	=	-324
IntuiTextLength	=	-330
WBenchToBack	=	-336
WBenchToFront	=	-342
AutoREQUest	=	-348
BeginRefresh	=	-354
BuildSysREQUest	=	-360
EndRefresh	=	-366
FreeSysREQUest	=	-372
MakeScreen	=	-378
RemakeDisplay	=	-384
RethinkDisplay	=	-390
AllocRemember	=	-396
AlohaWorkbench	=	-402
FreeRemember	=	-408
LockIBase	=	-414
UnlockIBase	=	-420
GetScreenData	=	-426
RefreshGList	=	-432
AddGList	=	-438
RemoveGList	=	-444
ActivateWindow	=	-450
RefreshWindowframe=	-456
ActivateGadget	=	-462
NewModifyProp	=	-468
QueryOverscan	=	-474
MoveWindowInFrontOf=	-480
ChangeWindowBox	=	-486
SetEditHook	=	-492
SetMousEQUeue	=	-498
ZipWindow	=	-504
LockPubScreen	=	-510
UnlockPubScreen	=	-516
LockPubScreenList=	-522
UnlockPubScreenList=	-528
NextPubScreen	=	-534
SetDefaultPubScreen=	-540
SetPubScreenModes=	-546
PubScreenStatus	=	-552
ObtainGIRPort	=	-558
ReleaseGIRPort	=	-564
GadgetMouse	=	-570
GetDefaultPubScreen=	-582
EasyREQUestArgs	=	-588
BuildEasyREQUestArgs=	-594
SysReqHandler	=	-600
OpenWindowTagList=	-606
OpenScreenTagList=	-612
DrawImageState	=	-618
PointInImage	=	-624
EraseImage	=	-630
NewObjectA	=	-636
DisposeObject	=	-642
SetAttrsA	=	-648
GetAttr		=	-654
SetGadgetAttrsA	=	-660
NextObject	=	-666
MakeClass	=	-678
AddClass	=	-684
GetScreenDrawInfo=	-690
FreeScreenDrawInfo=	-696
ResetMenuStrip	=	-702
RemoveClass	=	-708
FreeClass	=	-714
AllocScreenBuffer=	-768
FreeScreenBuffer=	-774
ChangeScreenBuffer=	-780
ScreenDepth	=	-786
ScreenPosition	=	-792
ScrollWindowRaster=	-798
LendMenus	=	-804
DoGadgetMethodA	=	-810
SetWindowPointerA=	-816
TimedDisplayAlert=	-822
HelpControl	=	-828

		; *** GRAPHICS - Library ***
		; (Release 3.0)

BltBitMap	=	-30
BltTemplate	=	-36
ClearEOL	=	-42
ClearScreen	=	-48
TextLength	=	-54
Text		=	-60
SetFont		=	-66
OpenFont	=	-72
CloseFont	=	-78
AskSoftStyle	=	-84
SetSoftStyle	=	-90
AddBob		=	-96
AddVSprite	=	-102
DoCollision	=	-108
DrawGList	=	-114
InitGels	=	-120
InitMasks	=	-126
RemIBob		=	-132
RemVSprite	=	-138
SetCollision	=	-144
SortGList	=	-150
AddAnimOb	=	-156
Animate		=	-162
GetGBuffers	=	-168
InitGMasks	=	-174
DrawEllipse	=	-180
AreaEllipse	=	-186
LoadRGB4	=	-192
InitRastPort	=	-198
InitVPort	=	-204
MrgCop		=	-210
MakeVPort	=	-216
LoadView	=	-222
WaitBlit	=	-228
SetRast		=	-234
Move		=	-240
Draw		=	-246
AreaMove	=	-252
AreaDraw	=	-258
AreaEnd		=	-264
WaitTOF		=	-270
QBlit		=	-276
InitArea	=	-282
SetRGB4		=	-288
QBSBlit		=	-294
BltClear	=	-300
RectFill	=	-306
BltPattern	=	-312
ReadPixel	=	-318
WritePixel	=	-324
Flood		=	-330
PolyDraw	=	-336
SetAPen		=	-342
SetBPen		=	-348
SetDrMd		=	-354
InitView	=	-360
CBump		=	-366
CMove		=	-372
CWait		=	-378
VBeamPos	=	-384
InitBitMap	=	-390
ScrollRaster	=	-396
WaitBOVP	=	-402
GetSprite	=	-408
FreeSprite	=	-414
ChangeSprite	=	-420
MoveSprite	=	-426
LockLayerRom	=	-432
UnlockLayerRom	=	-438
SyncSBitMap	=	-444
CopySBitMap	=	-450
OwnBlitter	=	-456
DisownBlitter	=	-462
InitTmpRas	=	-468
AskFont		=	-474
AddFont		=	-480
RemFont		=	-486
AllocRaster	=	-492
FreeRaster	=	-498
AndRectRegion	=	-504
OrRectRegion	=	-510
NewRegion	=	-516
ClearRectRegion	=	-522
ClearRegion	=	-528
DisposeRegion	=	-534
FreeVPortCopLists=	-540
FreeCopList	=	-546
ClipBlit	=	-552
XorRectRegion	=	-558
FreeCprList	=	-564
GetColorMap	=	-570
FreeColorMap	=	-576
GetRGB4		=	-582
ScrollVPort	=	-588
UCopperListInit	=	-594
FreeGBuffers	=	-600
BltBitMapRastPort=	-606
OrRegionRegion	=	-612
XorRegionRegion	=	-618
AndRegionRegion	=	-624
SetRGB4CM	=	-630
BltMaskBitMapRastPort=	-636
GfxInternal1	=	-642
GfxInternal2	=	-648
AttemptLockLayerRom=	-654
GfxNew		=	-660
GfxFree		=	-666
GfxAssociate	=	-672
BitMapScale	=	-678
ScalerDiv	=	-684
TextExtent	=	-690
TextFit		=	-696
GfxLookUp	=	-702
VideoControl	=	-708
OpenMonitor	=	-714
CloseMonitor	=	-720
FindDisplayInfo	=	-726
NextDisplayInfo	=	-732
GetDisplayInfoData=	-756
FontExtent	=	-762
ReadPixelLine8	=	-768
WritePixelLine8	=	-774
ReadPixelArray8	=	-780
WritePixelArray8=	-786
GetVPModeID	=	-792
ModeNotAvailable=	-798
WeighTAMatch	=	-804
EraseRect	=	-810
ExtendFont	=	-816
StripFont	=	-822
CalcIVG		=	-828
AttachPalExtra	=	-834
ObtainBestPenA	=	-840
GfxInternal3	=	-846
SetRGB32	=	-852
GetAPen		=	-858
GetBPen		=	-864
GetDrMd		=	-870
GetOutlinePen	=	-876
LoadRGB32	=	-882
SetChipRev	=	-888
SetABPenDrMd	=	-894
GetRGB32	=	-900
GfxSpare1	=	-906
AllocBitMap	=	-918
FreeBitMap	=	-924
GetExtSpriteA	=	-930
CoerceMode	=	-936
ChangeVPBitMap	=	-942
ReleasePen	=	-948
ObtainPen	=	-954
GetBitMapAttr	=	-960
AllocDBufInfo	=	-966
FreeDBufInfo	=	-972
SetOutlinePen	=	-978
SetWriteMask	=	-984
SetMaxPen	=	-990
SetRGB32CM	=	-996
ScrollRasterBF	=	-1002
FindColor	=	-1008
GfxSpare2	=	-1014
AllocSpriteDataA=	-1020
ChangeExtSpriteA=	-1026
FreeSpriteData	=	-1032
SetRPAttrsA	=	-1038
GetRPAttrsA	=	-1044
BestModeIDA	=	-1050

; Tags are a general mechanism of extensible data arrays for parameter
; specification and property inquiry. In practice, tags are used in arrays,
; or chain of arrays.

;   STRUCTURE TagItem,0
;	ULONG	ti_Tag		; identifies the type of the data
;	ULONG	ti_Data		; type-specific data
;   LABEL ti_SIZEOF

; constants for Tag.ti_Tag, control tag values
TAG_DONE   = 0  ; terminates array of TagItems. ti_Data unused
TAG_END	   = 0  ; synonym for TAG_DONE
TAG_IGNORE = 1  ; ignore this item, not end of array
TAG_MORE   = 2  ; ti_Data is pointer to another array of TagItems
		  ; note that this tag terminates the current array
TAG_SKIP   = 3  ; skip this and the next ti_Data items

; Tag filter logic specifiers for use with FilterTagItems()

TAGFILTER_AND = 0	; exclude everything but filter hits
TAGFILTER_NOT = 1	; exclude only filter hits

TAG_USER   = $80000000

; --- FLAGS SET BY INTUITION -------------------------------------------------

; The SCREENTYPE bits are reserved for describing various Screen types
; available under Intuition.  

SCREENTYPE	=	$000F	; all the screens types available 

; --- the definitions for the Screen Type ------------------------------------

WBENCHSCREEN	=	$0001	; identifies the Workbench screen
PUBLICSCREEN	=	$0002	; public shared (custom) screen
CUSTOMSCREEN	=	$000F	; for that special look

SHOWTITLE	=	$0010	; this gets set by a call to ShowTitle() 

BEEPING    	=	$0020	; set when Screen is beeping 

CUSTOMBITMAP	=	$0040	; if you are supplying your own BitMap

SCREENBEHIND	=	$0080	; if you want your screen to open behind
				; already open screens

SCREENQUIET	=	$0100	; if you do not want Intuition to render
				; into your screen (gadgets, title)

SCREENHIRES	=	$0200	; do not use lowres gadgets (set by intuition)

STDSCREENHEIGHT	=	-1	; supply in NewScreen.Height
STDSCREENWIDTH	=	-1	; supply in NewScreen.Width

NS_EXTENDED	=	$1000	; means ns_Extenion is valid
AUTOSCROLL	=	$4000	; automatic scrolling of large raster

* New for V39:
PENSHARED	=	$0400	; Screen opener set {SA_SharePens,TRUE}

* Screen attribute tag ID's.  These are used in the ti_Tag field of
* TagItem arrays passed to OpenScreenTagList() (or in the
* ExtNewScreen.Extension field).

* Screen attribute tags.  Please use these versions, not those in
* iobsolete.h.

 TAGPointer=TAG_USER+33
*
*   these items specify items equivalent to fields in NewScreen
    SA_Left=	TAGPointer  ; traditional screen positions and dimensions
    SA_Top=	TagPointer+1
    SA_Width=	TAGPointer+2
    SA_Height=	TAGPointer+3
    SA_Depth=	TAGPointer+4; screen bitmap depth
    SA_DetailPen=TAGPointer+5; serves as default for windows, too
    SA_BlockPen=TAGPointer+6
    SA_Title=	TAGPointer+7    ; default screen title

    SA_Colors=	TAGPointer+8	; ti_Data is an array of struct ColorSpec,
              			; terminated by ColorIndex = -1.  Specifies
				; initial screen palette colors.
				; Also see SA_Colors32 for use under V39.

    SA_ErrorCode=TAGPointer+9	; ti_Data points to LONG error code (values
    				; below)
    SA_Font=	TAGPointer+10 	; equiv. to NewScreen.Font
    SA_SysFont=	TAGPointer+11	; Selects one of the preferences system fonts:
				;	0 - old DefaultFont, fixed-width
				;	1 - WB Screen preferred font


    SA_Type=	TAGPointer+12	; ti_Data is PUBLICSCREEN or CUSTOMSCREEN.
    				; For other fields of NewScreen.Type, see
    				; individual tags,eg. SA_Behind, SA_Quiet.

    SA_BitMap=	TAGPointer+13	; ti_Data is pointer to custom BitMap.	This
				; implies type of CUSTOMBITMAP

    SA_PubName=	TAGPointer+14	; presence of this tag means that the screen
				; is to be a public screen.  Please specify
				; BEFORE the two tags below

    SA_PubSig=	TAGPointer+15
    SA_PubTask=	TAGPointer+16	; Task ID and signal for being notified that
				; the last window has closed on a public screen


    SA_DisplayID=TAGPointer+17	; ti_Data is new extended display ID from
				; <graphics/displayinfo.i> (V37) or from
				; <graphics/modeid.i> (V39 and up)

    SA_DClip=	TAGPointer+18	; ti_Data points to a rectangle which defines
				; screen display clip region

    SA_Overscan=TAGPointer+19	; Set to one of the OSCAN_
				; specifiers below to get a system standard
				; overscan region for your display clip,
				; screen dimensions |unless otherwise specified
				; and automatically centered position (partial
				; support only so far).

    SA_Obsolete1=TAGPointer+20  ; obsolete S_MONITORNAME

*   booleans *

    SA_ShowTitle=TAGPointer+21	; boolean equivalent to flag SHOWTITLE
    SA_Behind=	TAGPointer+22	; boolean equivalent to flag SCREENBEHIND
    SA_Quiet=	TAGPointer+23	; boolean equivalent to flag SCREENQUIET
    SA_AutoScroll=TAGPointer+24	; boolean equivalent to flag AUTOSCROLL
    SA_Pens=	TAGPointer+25  ; array as in DrawInfo, terminated by -1
    SA_FullPalette=TAGPointer+26; boolean: initialize color table to entire
				;  preferences palette (32 for V36), rather
				; than compatible pens 0-3, 17-19, with
				; remaining palette as returned by 
				; GetColorMap()


    SA_ColorMapEntries=TAGPointer+27 ; New for V39:
			             ; Allows you to override the number of 
			             ; entries in the ColorMap for your screen.
			             ; Intuition normally allocates (1<<depth) 
			             ; or 32, whichever is more, but you may 
			             ; require even more if you use certain 
			             ; V39 graphics.library features (eg. 
			             ; palette-banking).

    SA_Parent=	TAGPointer+28	; New for V39:
				; ti_Data is a pointer to a "parent" screen to
				; attach this one to.  Attached screens slide
				; and depth-arrange together.

    SA_Draggable=TAGPointer+29	; New for V39:
				; Boolean tag allowing non-draggable screens.
				; Do not use without good reason!
				; (Defaults to TRUE).

    SA_Exclusive=TAGPointer+30  ; New for V39:
				; Boolean tag allowing screens that won't share
				; the display.  Use sparingly!  Starting with
				; 3.01,attached screens may be SA_Exclusive. 
				; Setting SA_Exclusive for each screen will 
				; produce an exclusive family.   
				; (Defaults to FALSE).

     SA_SharePens=TAGPointer+31	; New for V39:
				; For those pens in the screen's 
				; DrawInfo->dri_Pens,Intuition obtains them 
				; in shared mode (see graphics.library/
				; ObtainPen()).  For compatibility, Intuition
				; obtains the other pens of a public screen as
				; PEN_EXCLUSIVE.  Screens that wish to manage
				; the pens themselves should generally set
				; this tag to TRUE.  This instructs Intuition
				; to leave the other pens unallocated.

    SA_BackFill=TAGPointer+32 	; New for V39:
				; provides a "backfill hook" for your screen's
				; Layer_Info.
				; See layers.library/InstallLayerInfoHook()

    SA_Interleaved=TAGPointer+33; New for V39:
				; Boolean tag requesting that the bitmap
				; allocated for you be interleaved.
				; (Defaults to FALSE).

    SA_Colors32=TAGPointer+34	; New for V39:
				; Tag to set the screen's initial palette 
				; colors at 32 bits-per-gun.ti_Data is a 
				; pointer to a table to be passed to the
				; graphics.library/LoadRGB32() function.
				; This format supports both runs of color
				; registers and sparse registers.  See the
				; autodoc for that function for full details.
				; Any color set here has precedence over
				; the same register set by SA_Colors.

    SA_VideoControl=TAGPointer+35; New for V39:
				; ti_Data is a pointer to a taglist that 
				; Intuition will pass to graphics.library/
				; VideoControl(), upon opening the screen.

    SA_FrontChild=TAGPointer+36	; New for V39:
				; ti_Data is a pointer to an already open 
				; screen that is to be the child of the 
				; screen being opened.The child screen will
				; be moved to the front of its family.

    SA_BackChild=TAGPointer+37	; New for V39:
				; ti_Data is a pointer to an already open 
				; screen that is to be the child of the 
				; screen being opened.  The child screen will 
				; be moved to the back of its family.

    SA_LikeWorkbench=TAGPointer+38; New for V39:
				; Set ti_Data to 1 to request a screen which
				; is just like the Workbench.  This gives
				; you the same screen mode, depth, size,
				; colors, etc., as the Workbench screen.

    SA_Reserved=TAGPointer+39 	; Reserved for private Intuition use

    SA_MinimizeISG=TAGPointer+40; New for V40:
				; For compatibility, Intuition always ensures
				; that the inter-screen gap is at least three
				; non-interlaced lines.  If your application
				; would look best with the smallest possible
				; inter-screen gap, set ti_Data to TRUE.
				; If you use the new graphics VideoControl()
				; VC_NoColorPaletteLoad tag for your screen's
				; ViewPort, you should also set this tag.



* OpenScreen error codes, which are returned in the (optional) LONG
* pointed to by ti_Data for the SA_ErrorCode tag item

OSERR_NOMONITOR		= (1)	; named monitor spec not available
OSERR_NOCHIPS		= (2)	; you need newer custom chips	
OSERR_NOMEM		= (3)	; couldn't get normal memory
OSERR_NOCHIPMEM		= (4)	; couldn't get chipmem
OSERR_PUBNOTUNIQUE	= (5)	; public screen name already used
OSERR_UNKNOWNMODE	= (6)	; don't recognize mode asked for
OSERR_TOODEEP		= (7)	; Screen deeper than HW supports
OSERR_ATTACHFAIL	= (8)	; Failed to attach screens
OSERR_NOTAVAILABLE	= (9) ; Mode not available for other reason


INVALID_ID			=	~0
MONITOR_ID_MASK			=	$FFFF1000

DEFAULT_MONITOR_ID		=	$00000000
NTSC_MONITOR_ID			=	$00011000
PAL_MONITOR_ID			=	$00021000

** the following 22 composite keys are for Modes on the default Monitor.
** NTSC & PAL "flavors" of these particular keys may be made by or'ing
** the NTSC or PAL MONITOR_ID with the desired MODE_KEY...
**
** For example, to specifically open a PAL HAM interlaced ViewPort
** (or intuition screen), you would use the modeid of
** (PAL_MONITOR_ID | HAMLACE_KEY)
**

LORES_KEY			=	$00000000 
HIRES_KEY			=	$00008000 
SUPER_KEY			=	$00008020 
HAM_KEY				=	$00000800 
LORESLACE_KEY			=	$00000004 
HIRESLACE_KEY			=	$00008004 
SUPERLACE_KEY			=	$00008024 
HAMLACE_KEY			=	$00000804 
LORESDPF_KEY			=	$00000400 
HIRESDPF_KEY			=	$00008400 
SUPERDPF_KEY			=	$00008420 
LORESLACEDPF_KEY		=	$00000404 
HIRESLACEDPF_KEY		=	$00008404 
SUPERLACEDPF_KEY		=	$00008424 
LORESDPF2_KEY			=	$00000440 
HIRESDPF2_KEY			=	$00008440 
SUPERDPF2_KEY			=	$00008460 
LORESLACEDPF2_KEY		=	$00000444 
HIRESLACEDPF2_KEY		=	$00008444 
SUPERLACEDPF2_KEY		=	$00008464 
EXTRAHALFBRITE_KEY		=	$00000080 
EXTRAHALFBRITELACE_KEY		=	$00000084 
* New for AA ChipSet (V39)
HIRESHAM_KEY			=	$00008800
SUPERHAM_KEY			=	$00008820
HIRESEHB_KEY			=	$00008080
SUPEREHB_KEY			=	$000080a0
HIRESHAMLACE_KEY		=	$00008804
SUPERHAMLACE_KEY		=	$00008824
HIRESEHBLACE_KEY		=	$00008084
SUPEREHBLACE_KEY		=	$000080a4
* New for V40
LORESSDBL_KEY			=	$00000008
LORESHAMSDBL_KEY		=	$00000808
LORESEHBSDBL_KEY		=	$00000088
HIRESHAMSDBL_KEY		=	$00008808

