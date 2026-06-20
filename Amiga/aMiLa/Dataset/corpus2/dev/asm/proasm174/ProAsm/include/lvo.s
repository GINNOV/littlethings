;-------------------------------------------------------------------------------
*                                                                              *
* _LVO Include file                                                            *
*                                                                              *
*                                                                              *
* Filename:      LVO.s                                                         *
* Version:       V39                                                           *
* Last Revision: 16.01.94                                                      *
*                                                                              *
;-------------------------------------------------------------------------------
*                                                                              *
* NOTE:  several library offset had to be renamed to keep the compatibility    *
*        to the original Commodore include files.                              *
*                                                                              *
*        old         acc. library         new               original           *
*        --------------------------------------------------------------------  *
*        _LVOFormat  (req.library)       _LVOrqFormat       (dos.library)      *
*        _LVOStrncmp (arp.library)       _LVOAStrncmp       (locale.library)   *
*        _LVOToUpper (arp.library)       _LVOAToupper       (utility.library)  *
*                                                                              *
*                                                                              *
;-------------------------------------------------------------------------------


/* Supported libraries:
   -----------------------------------------------

   amigaguide.library
   arp.library
   asl.library
   battclock.library
   battmem.library
   bullet.library
   cardres.library
   cia.library
   clist.library
   colorwheel.library
   commodities.library
   console.library
   datatypes.library
   diskfont.library
   disk.library
   dos.library
   dtclass.library
   exec.library
   expansion.library
   gadtools.library
   graphics.library
   icon.library
   iffparse.library
   iff.library
   input.library
   intuition.library
   keymap.library
   layers.library
   lh.library
   locale.library
   mathffp.library
   mathieeedoubbas.library
   mathieeedoubtrans.library
   mathieeesingbas.library
   mathieeesingtrans.library
   mathtrans.library
   misc.library
   potgo.library
   powerpacker.library
   ramdrive.library
   reqtools.library
   rexxsyslib.library
   romboot.library
   timer.library
   toolmanager.fd
   translator.library
   utility.library
   vector.library
   wb.library
   xpkmaster.library
   xpksub.library

*/



;----------------------------------------------------------
*
* AMIGAGUIDE.LIBRARY
*
	IFND	_LVOAGARexxHost
_LVOAGARexxHost			EQU	-30
_LVOLockAmigaGuideBase		EQU	-36
_LVOUnlockAmigaGuideBase	EQU	-42
_LVOamigaguidePrivate1		EQU	-48
_LVOOpenAmigaGuideA		EQU	-54
_LVOOpenAmigaGuideAsyncA	EQU	-60
_LVOCloseAmigaGuide		EQU	-66
_LVOAmigaGuideSignal		EQU	-72
_LVOGetAmigaGuideMsg		EQU	-78
_LVOReplyAmigaGuideMsg		EQU	-84
_LVOSetAmigaGuideContextA	EQU	-90
_LVOSendAmigaGuideContextA	EQU	-96
_LVOSendAmigaGuideCmdA		EQU	-$66
_LVOSetAmigaGuideAttrsA		EQU	-$6c
_LVOGetAmigaGuideAttr		EQU	-$72
_LVOamigaguidePrivate2		EQU	-$78
_LVOamigaguidePrivate3		EQU	-$7e
_LVOamigaguidePrivate4		EQU	-$84
_LVOAddAmigaGuideHostA		EQU	-$8a
_LVORemoveAmigaGuideHostA	EQU	-$90
_LVOamigaguidePrivate5		EQU	-$96
_LVOamigaguidePrivate6		EQU	-$9c
_LVOamigaguidePrivate7		EQU	-$a2
_LVOamigaguidePrivate8		EQU	-$a8
_LVOamigaguidePrivate9		EQU	-$ae
_LVOamigaguidePrivate10		EQU	-$b4
_LVOamigaguidePrivate11		EQU	-$ba
_LVOamigaguidePrivate12		EQU	-$c0
_LVOamigaguidePrivate13		EQU	-$c6
_LVOamigaguidePrivate14		EQU	-$cc
_LVOGetAmigaGuideString		EQU	-$d2

	ENDC

;----------------------------------------------------------
*
* ARP.LIBRARY
*
	IFND	_LVOAddDANode
_LVOOpen			EQU	-30
_LVOClose			EQU	-36
_LVORead			EQU	-42
_LVOWrite			EQU	-48
_LVOInput			EQU	-54
_LVOOutput			EQU	-60
_LVOSeek			EQU	-66
_LVODeleteFile			EQU	-72
_LVORename			EQU	-78
_LVOLock			EQU	-84
_LVOUnLock			EQU	-90
_LVODupLock			EQU	-96
_LVOExamine			EQU	-$66
_LVOExNext			EQU	-$6c
_LVOInfo			EQU	-$72
_LVOCreateDir			EQU	-$78
_LVOCurrentDir			EQU	-$7e
_LVOIoErr			EQU	-$84
_LVOCreateProc			EQU	-$8a
_LVOExit			EQU	-$90
_LVOLoadSeg			EQU	-$96
_LVOUnLoadSeg			EQU	-$9c
_LVOGetPacket			EQU	-$a2
_LVOQueuePacket			EQU	-$a8
_LVODeviceProc			EQU	-$ae
_LVOSetComment			EQU	-$b4
_LVOSetProtection		EQU	-$ba
_LVODateStamp			EQU	-$c0
_LVODelay			EQU	-$c6
_LVOWaitForChar			EQU	-$cc
_LVOParentDir			EQU	-$d2
_LVOIsInteractive		EQU	-$d8
_LVOExecute			EQU	-$de
_LVOPrintf			EQU	-$e4
_LVOFPrintf			EQU	-$ea
_LVOPuts			EQU	-$f0
_LVOReadLine			EQU	-$f6
_LVOGADS			EQU	-$fc
_LVOAtol			EQU	-258
_LVOEscapeString		EQU	-264
_LVOCheckAbort			EQU	-270
_LVOCheckBreak			EQU	-276
_LVOGetenv			EQU	-282
_LVOSetenv			EQU	-288
_LVOFileRequest			EQU	-294
_LVOCloseWindowSafely		EQU	-300
_LVOCreatePort			EQU	-306
_LVODeletePort			EQU	-312
_LVOSendPacket			EQU	-318
_LVOInitStdPacket		EQU	-324
_LVOPathName			EQU	-330
_LVOAssign			EQU	-336
_LVODosAllocMem			EQU	-342
_LVODosFreeMem			EQU	-348
_LVOBtoCStr			EQU	-354
_LVOCtoBstr			EQU	-360
_LVOGetDevInfo			EQU	-366
_LVOFreeTaskResList		EQU	-372
_LVOArpExit			EQU	-378
_LVOArpAlloc			EQU	-384
_LVOArpAllocMem			EQU	-390
_LVOArpOpen			EQU	-396
_LVOArpDupLock			EQU	-402
_LVOArpLock			EQU	-408
_LVORListAlloc			EQU	-414
_LVOFindCLI			EQU	-420
_LVOQSort			EQU	-426
_LVOPatternMatch		EQU	-432
_LVOFindFirst			EQU	-438
_LVOFindNext			EQU	-444
_LVOFreeAnchorChain		EQU	-450
_LVOCompareLock			EQU	-456
_LVOFindTaskResList		EQU	-462
_LVOCreateTaskResList		EQU	-468
_LVOFreeResList			EQU	-474
_LVOFreeTrackedItem		EQU	-480
_LVOGetTracker			EQU	-486
_LVOGetAccess			EQU	-492
_LVOFreeAccess			EQU	-498
_LVOFreeDAList			EQU	-504
_LVOAddDANode			EQU	-510
_LVOAddDADevs			EQU	-516
_LVOStrcmp			EQU	-522
_LVOAStrncmp			EQU	-528
_LVOAToupper			EQU	-534
_LVOSyncRun			EQU	-540
_LVOASyncRun			EQU	-546
_LVOLoadPrg			EQU	-552
_LVOPreParse			EQU	-558
_LVOStamptoStr			EQU	-564
_LVOStrtoStamp			EQU	-570
_LVOObtainResidentPrg		EQU	-576
_LVOAddResidentPrg		EQU	-582
_LVORemResidentPrg		EQU	-588
_LVOUnLoadPrg			EQU	-594
_LVOLMult			EQU	-600
_LVOLDiv			EQU	-606
_LVOLMod			EQU	-612
_LVOCheckSumPrg			EQU	-618
_LVOTackOn			EQU	-624
_LVOBaseName			EQU	-630
_LVOReleaseResidentPrg		EQU	-636

	ENDC

;----------------------------------------------------------
*
* ASL.LIBRARY
*
	IFND	_LVOAllocFileRequest

_LVOAllocFileRequest		EQU	-30
_LVOFreeFileRequest		EQU	-36
_LVORequestFile			EQU	-42
_LVOAllocAslRequest		EQU	-48
_LVOFreeAslRequest		EQU	-54
_LVOAslRequest			EQU	-60

	ENDC

;----------------------------------------------------------
*
* BATTCLOCK.LIBRARY
*
	IFND	_LVOResetBattClock
_LVOResetBattClock		EQU	-6
_LVOReadBattClock		EQU	-$c
_LVOWriteBattClock		EQU	-18
_LVObattclockPrivate1		EQU	-24
_LVObattclockPrivate2		EQU	-30

	ENDC

;----------------------------------------------------------
*
* BATTMEM.LIBRARY
*
	IFND	_LVOObtainBattSemaphore
_LVOObtainBattSemaphore		EQU	-6
_LVOReleaseBattSemaphore	EQU	-$c
_LVOReadBattMem			EQU	-18
_LVOWriteBattMem		EQU	-24

	ENDC

;----------------------------------------------------------
*
* BULLET.LIBRARY
*
	IFND	_LVOOpenEngine
_LVOOpenEngine			EQU	-30
_LVOCloseEngine			EQU	-36
_LVOSetInfoA			EQU	-42
_LVOObtainInfoA			EQU	-48
_LVOReleaseInfoA		EQU	-54
_LVObulletPrivate1		EQU	-60

	ENDC

;----------------------------------------------------------
*
* CARDRES.LIBRARY
*
	IFND	_LVOOwnCard
_LVOOwnCard			EQU	-6
_LVOReleaseCard			EQU	-$c
_LVOGetCardMap			EQU	-18
_LVOBeginCardAccess		EQU	-24
_LVOEndCardAccess		EQU	-30
_LVOReadCardStatus		EQU	-36
_LVOCardResetRemove		EQU	-42
_LVOCardMiscControl		EQU	-48
_LVOCardAccessSpeed		EQU	-54
_LVOCardProgramVoltage		EQU	-60
_LVOCardResetCard		EQU	-66
_LVOCopyTuple			EQU	-72
_LVODeviceTuple			EQU	-78
_LVOIfAmigaXIP			EQU	-84
_LVOCardForceChange		EQU	-90
_LVOCardChangeCount		EQU	-96
_LVOCardInterface		EQU	-$66

	ENDC

;----------------------------------------------------------
*
* CIA.LIBRARY
*
	IFND	_LVOAddICRVector
_LVOAddICRVector		EQU	-6
_LVORemICRVector		EQU	-$c
_LVOAbleICR			EQU	-18
_LVOSetICR			EQU	-24

	ENDC

;----------------------------------------------------------
*
* CLIST.LIBRARY
*
	IFND	_LVOInitCLPool
_LVOInitCLPool			EQU	-30
_LVOAllocCList			EQU	-36
_LVOFreeCList			EQU	-42
_LVOFlushCList			EQU	-48
_LVOSizeCList			EQU	-54
_LVOPutCLChar			EQU	-60
_LVOGetCLChar			EQU	-66
_LVOUnGetCLChar			EQU	-72
_LVOUnPutCLChar			EQU	-78
_LVOPutCLWord			EQU	-84
_LVOGetCLWord			EQU	-90
_LVOUnGetCLWord			EQU	-96
_LVOUnPutCLWord			EQU	-$66
_LVOPutCLBuf			EQU	-$6c
_LVOGetCLBuf			EQU	-$72
_LVOMarkCList			EQU	-$78
_LVOIncrCLMark			EQU	-$7e
_LVOPeekCLMark			EQU	-$84
_LVOSplitCList			EQU	-$8a
_LVOCopyCList			EQU	-$90
_LVOSubCList			EQU	-$96
_LVOConcatCList			EQU	-$9c

	ENDC

;----------------------------------------------------------
*
* COLORWHEEL.LIBRARY
*
	IFND	_LVOConvertHSBToRGB
_LVOConvertHSBToRGB		EQU	-30
_LVOConvertRGBToHSB		EQU	-36

	ENDC

;----------------------------------------------------------
*
* COMMODITIES.LIBRARY
*
	IFND	_LVOCreateCxObj

_LVOCreateCxObj			EQU	-30
_LVOCxBroker			EQU	-36
_LVOActivateCxObj		EQU	-42
_LVODeleteCxObj			EQU	-48
_LVODeleteCxObjAll		EQU	-54
_LVOCxObjType			EQU	-60
_LVOCxObjError			EQU	-66
_LVOClearCxObjError		EQU	-72
_LVOSetCxObjPri			EQU	-78
_LVOAttachCxObj			EQU	-84
_LVOEnqueueCxObj		EQU	-90
_LVOInsertCxObj			EQU	-96
_LVORemoveCxObj			EQU	-102
_LVOcommoditiesPrivate1		EQU	-108
_LVOSetTranslate		EQU	-114
_LVOSetFilter			EQU	-120
_LVOSetFilterIX			EQU	-126
_LVOParseIX			EQU	-132
_LVOCxMsgType			EQU	-138
_LVOCxMsgData			EQU	-144
_LVOCxMsgID			EQU	-150
_LVODivertCxMsg			EQU	-156
_LVORouteCxMsg			EQU	-162
_LVODisposeCxMsg		EQU	-168
_LVOInvertKeyMap		EQU	-174
_LVOAddIEvents			EQU	-180
_LVOcommoditiesPrivate2		EQU	-186
_LVOcommoditiesPrivate3		EQU	-192
_LVOcommoditiesPrivate4		EQU	-198
_LVOMatchIX			EQU	-204
_LVOcommoditiesPrivate5		EQU	-210
_LVOcommoditiesPrivate6		EQU	-216
_LVOcommoditiesPrivate7		EQU	-222
_LVOcommoditiesPrivate8		EQU	-228
_LVOcommoditiesPrivate9		EQU	-234

	ENDC

;----------------------------------------------------------
*
* CONSOLE.DEVICE
*
	IFND	_LVOCDInputHandler

_LVOCDInputHandler		EQU	-42
_LVORawKeyConvert		EQU	-48
_LVOGetConSnip			EQU	-54		;privat
_LVOSetConSnip			EQU	-60		;privat
_LVOAddConSnipHook		EQU	-66		;privat
_LVORemConSnipHook  		EQU	-72		;privat

	ENDC

;----------------------------------------------------------
*
* DATATYPES.LIBRARY
*
	IFND	_LVORLDispatch
_LVORLDispatch			EQU	-30
_LVOObtainDataTypeA		EQU	-36
_LVOReleaseDataType		EQU	-42
_LVONewDTObjectA		EQU	-48
_LVODisposeDTObject		EQU	-54
_LVOSetDTAttrsA			EQU	-60
_LVOGetDTAttrsA			EQU	-66
_LVOAddDTObject			EQU	-72
_LVORefreshDTObjectA		EQU	-78
_LVODoAsyncLayout		EQU	-84
_LVODoDTMethodA			EQU	-90
_LVORemoveDTObject		EQU	-96
_LVOGetDTMethods		EQU	-$66
_LVOGetDTTriggerMethods		EQU	-$6c
_LVOPrintDTObjectA		EQU	-$72
_LVOdatatypesPrivate1		EQU	-$78
_LVOdatatypesPrivate2		EQU	-$7e
_LVOdatatypesPrivate3		EQU	-$84
_LVOGetDTString			EQU	-$8a

	ENDC

;----------------------------------------------------------
*
* DISK.LIBRARY
*
	IFND	_LVOAllocUnit
_LVOAllocUnit			EQU	-6
_LVOFreeUnit			EQU	-$c
_LVOGetUnit			EQU	-18
_LVOGiveUnit			EQU	-24
_LVOGetUnitID			EQU	-30
_LVOReadUnitID			EQU	-36

	ENDC

;----------------------------------------------------------
*
* DISKFONT.LIBRARY
*
	IFND	_LVOOpenDiskFont

_LVOOpenDiskFont		EQU	-30
_LVOAvailFonts			EQU	-36
_LVONewFontContents		EQU	-42
_LVODisposeFontContents		EQU	-48
_LVONewScaledDiskFont		EQU	-54

	ENDC

;----------------------------------------------------------
*
* DOS.LIBRARY
*
	IFND	_LVOOpen

_LVOOpen			EQU	-30
_LVOClose			EQU	-36
_LVORead			EQU	-42
_LVOWrite			EQU	-48
_LVOInput			EQU	-54
_LVOOutput			EQU	-60
_LVOSeek			EQU	-66
_LVODeleteFile			EQU	-72
_LVORename			EQU	-78
_LVOLock			EQU	-84
_LVOUnLock			EQU	-90
_LVODupLock			EQU	-96
_LVOExamine			EQU	-102
_LVOExNext			EQU	-108
_LVOInfo			EQU	-114
_LVOCreateDir			EQU	-120
_LVOCurrentDir			EQU	-126
_LVOIoErr			EQU	-132
_LVOCreateProc			EQU	-138
_LVOExit			EQU	-144
_LVOLoadSeg			EQU	-150
_LVOUnLoadSeg			EQU	-156
_LVOClearVec			EQU	-162
_LVONoReqLoadSeg		EQU	-168
_LVODeviceProc			EQU	-174
_LVOSetComment			EQU	-180
_LVOSetProtection		EQU	-186
_LVODateStamp			EQU	-192
_LVODelay			EQU	-198
_LVOWaitForChar			EQU	-204
_LVOParentDir			EQU	-210
_LVOIsInteractive		EQU	-216
_LVOExecute			EQU	-222
	ENDC

	IFND	_LVOAllocDosObject
_LVOAllocDosObject		EQU	-228
_LVOFreeDosObject		EQU	-234
_LVODoPkt			EQU	-240
_LVOSendPkt			EQU	-246
_LVOWaitPkt			EQU	-252
_LVOReplyPkt			EQU	-258
_LVOAbortPkt			EQU	-264
_LVOLockRecord			EQU	-270
_LVOLockRecords			EQU	-276
_LVOUnLockRecord		EQU	-282
_LVOUnLockRecords		EQU	-288
_LVOSelectInput			EQU	-294
_LVOSelectOutput		EQU	-300
_LVOFGetC			EQU	-306
_LVOFPutC			EQU	-312
_LVOUnGetC			EQU	-318
_LVOFRead			EQU	-324
_LVOFWrite			EQU	-330
_LVOFGets			EQU	-336
_LVOFPuts			EQU	-342
_LVOVFWritef			EQU	-348
_LVOVFPrintf			EQU	-354
_LVOFlush			EQU	-360
_LVOSetVBuf			EQU	-366
_LVODupLockFromFH		EQU	-372
_LVOOpenFromLock		EQU	-378
_LVOParentOfFH			EQU	-384
_LVOExamineFH			EQU	-390
_LVOSetFileDate			EQU	-396
_LVONameFromLock		EQU	-402
_LVONameFromFH			EQU	-408
_LVOSplitName			EQU	-414
_LVOSameLock			EQU	-420
_LVOSetMode			EQU	-426
_LVOExAll			EQU	-432
_LVOReadLink			EQU	-438
_LVOMakeLink			EQU	-444
_LVOChangeMode			EQU	-450
_LVOSetFileSize			EQU	-456
_LVOSetIoErr			EQU	-462
_LVOFault			EQU	-468
_LVOPrintFault			EQU	-474
_LVOErrorReport			EQU	-480
_LVOCli				EQU	-492
_LVOCreateNewProc		EQU	-498
_LVORunCommand			EQU	-504
_LVOGetConsoleTask		EQU	-510
_LVOSetConsoleTask		EQU	-516
_LVOGetFileSysTask		EQU	-522
_LVOSetFileSysTask		EQU	-528
_LVOGetArgStr			EQU	-534
_LVOSetArgStr			EQU	-540
_LVOFindCliProc			EQU	-546
_LVOMaxCli			EQU	-552
_LVOSetCurrentDirName		EQU	-558
_LVOGetCurrentDirName		EQU	-564
_LVOSetProgramName		EQU	-570
_LVOGetProgramName		EQU	-576
_LVOSetPrompt			EQU	-582
_LVOGetPrompt			EQU	-588
_LVOSetProgramDir		EQU	-594
_LVOGetProgramDir		EQU	-600
_LVOSystemTagList		EQU	-606
_LVOAssignLock			EQU	-612
_LVOAssignLate			EQU	-618
_LVOAssignPath			EQU	-624
_LVOAssignAdd			EQU	-630
_LVORemAssignList		EQU	-636
_LVOGetDeviceProc		EQU	-642
_LVOFreeDeviceProc		EQU	-648
_LVOLockDosList			EQU	-654
_LVOUnLockDosList		EQU	-660
_LVOAttemptLockDosList		EQU	-666
_LVORemDosEntry			EQU	-672
_LVOAddDosEntry			EQU	-678
_LVOFindDosEntry		EQU	-684
_LVONextDosEntry		EQU	-690
_LVOMakeDosEntry		EQU	-696
_LVOFreeDosEntry		EQU	-702
_LVOIsFileSystem		EQU	-708
_LVOFormat			EQU	-714
_LVORelabel			EQU	-720
_LVOInhibit			EQU	-726
_LVOAddBuffers			EQU	-732
_LVOCompareDates		EQU	-738
_LVODateToStr			EQU	-744
_LVOStrToDate			EQU	-750
_LVOInternalLoadSeg		EQU	-756
_LVOInternalUnLoadSeg		EQU	-762
_LVONewLoadSeg			EQU	-768
_LVOAddSegment			EQU	-774
_LVOFindSegment			EQU	-780
_LVORemSegment			EQU	-786
_LVOCheckSignal			EQU	-792
_LVOReadArgs			EQU	-798
_LVOFindArg			EQU	-804
_LVOReadItem			EQU	-810
_LVOStrToLong			EQU	-816
_LVOMatchFirst			EQU	-822
_LVOMatchNext			EQU	-828
_LVOMatchEnd			EQU	-834
_LVOParsePattern		EQU	-840
_LVOMatchPattern		EQU	-846
_LVODosNameFromAnchor		EQU	-852
_LVOFreeArgs			EQU	-858
_LVOFilePart			EQU	-870
_LVOPathPart			EQU	-876
_LVOAddPart			EQU	-882
_LVOStartNotify			EQU	-888
_LVOEndNotify			EQU	-894
_LVOSetVar			EQU	-900
_LVOGetVar			EQU	-906
_LVODeleteVar			EQU	-912
_LVOFindVar			EQU	-918
_LVOCliInit			EQU	-924
_LVOCliInitNewcli		EQU	-930
_LVOCliInitRun			EQU	-936
_LVOWriteChars			EQU	-942
_LVOPutStr			EQU	-948
_LVOVPrintf			EQU	-954
_LVOMatchReplace		EQU	-960
_LVOParsePatternNoCase		EQU	-966
_LVOMatchPatternNoCase		EQU	-972
_LVODosGetString		EQU	-978
_LVOSameDevice			EQU	-984

	ENDC

;----------------------------------------------------------
*
* DTCLASS.LIBRARY
*
	IFND	_LVOObtainEngine
_LVOObtainEngine		EQU	-30

	ENDC

;----------------------------------------------------------
*
* EXEC.LIBRARY
*
	IFND	_LVOSupervisor

_LVOSupervisor			EQU	-30
_LVOExitIntr			EQU	-36
_LVOSchedule			EQU	-42
_LVOReSchedule			EQU	-48
_LVOSwitch			EQU	-54
_LVODispatch			EQU	-60
_LVOException			EQU	-66
_LVOInitCode			EQU	-72
_LVOInitStruct			EQU	-78
_LVOMakeLibrary			EQU	-84
_LVOMakeFunctions		EQU	-90
_LVOFindResident		EQU	-96
_LVOInitResident		EQU	-102
_LVOAlert			EQU	-108
_LVODebug			EQU	-114
_LVODisable			EQU	-120
_LVOEnable			EQU	-126
_LVOForbid			EQU	-132
_LVOPermit			EQU	-138
_LVOSetSR			EQU	-144
_LVOSuperState			EQU	-150
_LVOUserState			EQU	-156
_LVOSetIntVector		EQU	-162
_LVOAddIntServer		EQU	-168
_LVORemIntServer		EQU	-174
_LVOCause			EQU	-180
_LVOAllocate			EQU	-186
_LVODeallocate			EQU	-192
_LVOAllocMem			EQU	-198
_LVOAllocAbs			EQU	-204
_LVOFreeMem			EQU	-210
_LVOAvailMem			EQU	-216
_LVOAllocEntry			EQU	-222
_LVOFreeEntry			EQU	-228
_LVOInsert			EQU	-234
_LVOAddHead			EQU	-240
_LVOAddTail			EQU	-246
_LVORemove			EQU	-252
_LVORemHead			EQU	-258
_LVORemTail			EQU	-264
_LVOEnqueue			EQU	-270
_LVOFindName			EQU	-276
_LVOAddTask			EQU	-282
_LVORemTask			EQU	-288
_LVOFindTask			EQU	-294
_LVOSetTaskPri			EQU	-300
_LVOSetSignal			EQU	-306
_LVOSetExcept			EQU	-312
_LVOWait			EQU	-318
_LVOSignal			EQU	-324
_LVOAllocSignal			EQU	-330
_LVOFreeSignal			EQU	-336
_LVOAllocTrap			EQU	-342
_LVOFreeTrap			EQU	-348
_LVOAddPort			EQU	-354
_LVORemPort			EQU	-360
_LVOPutMsg			EQU	-366
_LVOGetMsg			EQU	-372
_LVOReplyMsg			EQU	-378
_LVOWaitPort			EQU	-384
_LVOFindPort			EQU	-390
_LVOAddLibrary			EQU	-396
_LVORemLibrary			EQU	-402
_LVOOldOpenLibrary		EQU	-408
_LVOCloseLibrary		EQU	-414
_LVOSetFunction			EQU	-420
_LVOSumLibrary			EQU	-426
_LVOAddDevice			EQU	-432
_LVORemDevice			EQU	-438
_LVOOpenDevice			EQU	-444
_LVOCloseDevice			EQU	-450
_LVODoIO			EQU	-456
_LVOSendIO			EQU	-462
_LVOCheckIO			EQU	-468
_LVOWaitIO			EQU	-474
_LVOAbortIO			EQU	-480
_LVOAddResource			EQU	-486
_LVORemResource			EQU	-492
_LVOOpenResource		EQU	-498
_LVORawIOInit			EQU	-504
_LVORawMayGetChar		EQU	-510
_LVORawPutChar			EQU	-516
_LVORawDoFmt			EQU	-522
_LVOGetCC			EQU	-528
_LVOTypeOfMem			EQU	-534
_LVOProcedure			EQU	-540
_LVOVacate			EQU	-546
_LVOOpenLibrary			EQU	-552
_LVOInitSemaphore		EQU	-558
_LVOObtainSemaphore		EQU	-564
_LVOReleaseSemaphore		EQU	-570
_LVOAttemptSemaphore		EQU	-576
_LVOObtainSemaphoreList		EQU	-582
_LVOReleaseSemaphoreList 	EQU	-588
_LVOFindSemaphore		EQU	-594
_LVOAddSemaphore		EQU	-600
_LVORemSemaphore		EQU	-606
_LVOSumKickData			EQU	-612
_LVOAddMemList			EQU	-618
_LVOCopyMem			EQU	-624
_LVOCopyMemQuick		EQU	-630
_LVOCacheClearU			EQU	-636
_LVOCacheClearE			EQU	-642
_LVOCacheControl		EQU	-648
_LVOCreateIORequest		EQU	-654
_LVODeleteIORequest		EQU	-660
_LVOCreateMsgPort		EQU	-666
_LVODeleteMsgPort		EQU	-672
_LVOObtainSemaphoreShared 	EQU	-678
_LVOAllocVec			EQU	-684
_LVOFreeVec			EQU	-690
_LVOCreatePrivatePool		EQU	-696
_LVODeletePrivatePool		EQU	-702
_LVOAllocPooled			EQU	-708
_LVOFreePooled			EQU	-714
_LVOExecReserved00		EQU	-720
_LVOColdReboot			EQU	-726
_LVOStackSwap			EQU	-732
_LVOChildFree			EQU	-738
_LVOChildOrphan			EQU	-744
_LVOChildStatus			EQU	-750
_LVOChildWait			EQU	-756
_LVOCachePreDMA			EQU	-762
_LVOCachePostDMA		EQU	-768
_LVOAddMemHandler		EQU	-774
_LVORemMemHandler		EQU	-780
_LVOExecReserved1		EQU	-786
_LVOExecReserved2		EQU	-792
_LVOExecReserved3		EQU	-798
_LVOExecReserved4		EQU	-804
_LVOTaggedOpenLibrary		EQU	-810
	ENDC

;----------------------------------------------------------
*
* EXPANSION.LIBRARY
*
	IFND	_LVOAddConfigDev

_LVOAddConfigDev		EQU	-30
_LVOAddBootNode			EQU	-36
_LVOAllocBoardMem		EQU	-42
_LVOAllocConfigDev		EQU	-48
_LVOAllocExpansionMem		EQU	-54
_LVOConfigBoard			EQU	-60
_LVOConfigChain			EQU	-66
_LVOFindConfigDev		EQU	-72
_LVOFreeBoardMem		EQU	-78
_LVOFreeConfigDev		EQU	-84
_LVOFreeExpansionMem		EQU	-90
_LVOReadExpansionByte		EQU	-96
_LVOReadExpansionRom		EQU	-102
_LVORemConfigDev		EQU	-108
_LVOWriteExpansionByte		EQU	-114
_LVOObtainConfigBinding		EQU	-120
_LVOReleaseConfigBinding 	EQU	-126
_LVOSetCurrentBinding		EQU	-132
_LVOGetCurrentBinding		EQU	-138
_LVOMakeDosNode			EQU	-144
_LVOAddDosNode			EQU	-150
_LVOExpansionReserved26		EQU	-156
_LVOWriteExpansionWord		EQU	-162

	ENDC

;----------------------------------------------------------
*
* GADTOOLS.LIBRARY
*
	IFND	_LVOCreateGadgetA

_LVOCreateGadgetA		EQU	-30
_LVOFreeGadgets			EQU	-36
_LVOGT_SetGadgetAttrsA		EQU	-42
_LVOCreateMenusA		EQU	-48
_LVOFreeMenus			EQU	-54
_LVOLayoutMenuItemsA		EQU	-60
_LVOLayoutMenusA		EQU	-66
_LVOGT_GetIMsg			EQU	-72
_LVOGT_ReplyIMsg		EQU	-78
_LVOGT_RefreshWindow		EQU	-84
_LVOGT_BeginRefresh		EQU	-90
_LVOGT_EndRefresh		EQU	-96
_LVOGT_FilterIMsg		EQU	-102
_LVOGT_PostFilterIMsg		EQU	-108
_LVOCreateContext		EQU	-114
_LVODrawBevelBoxA		EQU	-120
_LVOGetVisualInfoA		EQU	-126
_LVOFreeVisualInfo		EQU	-132
_LVOGTReserved1			EQU	-138
_LVOGTReserved2			EQU	-144
_LVOGTReserved3			EQU	-150
_LVOGTReserved4			EQU	-156
_LVOGTReserved5			EQU	-162
_LVOGTReserved6			EQU	-168
_LVOGT_GetGadgetAttrsA		EQU	-174

	ENDC

;----------------------------------------------------------
*
* GRAPHICS.LIBRARY
*
	IFND	_LVOBltBitMap

_LVOBltBitMap			EQU	-30
_LVOBltTemplate			EQU	-36
_LVOClearEOL			EQU	-42
_LVOClearScreen			EQU	-48
_LVOTextLength			EQU	-54
_LVOText			EQU	-60
_LVOSetFont			EQU	-66
_LVOOpenFont			EQU	-72
_LVOCloseFont			EQU	-78
_LVOAskSoftStyle		EQU	-84
_LVOSetSoftStyle		EQU	-90
_LVOAddBob			EQU	-96
_LVOAddVSprite			EQU	-102
_LVODoCollision			EQU	-108
_LVODrawGList			EQU	-114
_LVOInitGels			EQU	-120
_LVOInitMasks			EQU	-126
_LVORemIBob			EQU	-132
_LVORemVSprite			EQU	-138
_LVOSetCollision		EQU	-144
_LVOSortGList			EQU	-150
_LVOAddAnimOb			EQU	-156
_LVOAnimate			EQU	-162
_LVOGetGBuffers			EQU	-168
_LVOInitGMasks			EQU	-174
_LVODrawEllipse			EQU	-180
_LVOAreaEllipse			EQU	-186
_LVOLoadRGB4			EQU	-192
_LVOInitRastPort		EQU	-198
_LVOInitVPort			EQU	-204
_LVOMrgCop			EQU	-210
_LVOMakeVPort			EQU	-216
_LVOLoadView			EQU	-222
_LVOWaitBlit			EQU	-228
_LVOSetRast			EQU	-234
_LVOMove			EQU	-240
_LVODraw			EQU	-246
_LVOAreaMove			EQU	-252
_LVOAreaDraw			EQU	-258
_LVOAreaEnd			EQU	-264
_LVOWaitTOF			EQU	-270
_LVOQBlit			EQU	-276
_LVOInitArea			EQU	-282
_LVOSetRGB4			EQU	-288
_LVOQBSBlit			EQU	-294
_LVOBltClear			EQU	-300
_LVORectFill			EQU	-306
_LVOBltPattern			EQU	-312
_LVOReadPixel			EQU	-318
_LVOWritePixel			EQU	-324
_LVOFlood			EQU	-330
_LVOPolyDraw			EQU	-336
_LVOSetAPen			EQU	-342
_LVOSetBPen			EQU	-348
_LVOSetDrMd			EQU	-354
_LVOInitView			EQU	-360
_LVOCBump			EQU	-366
_LVOCMove			EQU	-372
_LVOCWait			EQU	-378
_LVOVBeamPos			EQU	-384
_LVOInitBitMap			EQU	-390
_LVOScrollRaster		EQU	-396
_LVOWaitBOVP			EQU	-402
_LVOGetSprite			EQU	-408
_LVOFreeSprite			EQU	-414
_LVOChangeSprite		EQU	-420
_LVOMoveSprite			EQU	-426
_LVOLockLayerRom		EQU	-432
_LVOUnlockLayerRom		EQU	-438
_LVOSyncSBitMap			EQU	-444
_LVOCopySBitMap			EQU	-450
_LVOOwnBlitter			EQU	-456
_LVODisownBlitter		EQU	-462
_LVOInitTmpRas			EQU	-468
_LVOAskFont			EQU	-474
_LVOAddFont			EQU	-480
_LVORemFont			EQU	-486
_LVOAllocRaster			EQU	-492
_LVOFreeRaster			EQU	-498
_LVOAndRectRegion		EQU	-504
_LVOOrRectRegion		EQU	-510
_LVONewRegion			EQU	-516
_LVOClearRectRegion		EQU	-522
_LVOClearRegion			EQU	-528
_LVODisposeRegion		EQU	-534
_LVOFreeVPortCopLists		EQU	-540
_LVOFreeCopList			EQU	-546
_LVOClipBlit			EQU	-552
_LVOXorRectRegion		EQU	-558
_LVOFreeCprList			EQU	-564
_LVOGetColorMap			EQU	-570
_LVOFreeColorMap		EQU	-576
_LVOGetRGB4			EQU	-582
_LVOScrollVPort			EQU	-588
_LVOUCopperListInit		EQU	-594
_LVOFreeGBuffers		EQU	-600
_LVOBltBitMapRastPort		EQU	-606
_LVOOrRegionRegion		EQU	-612
_LVOXorRegionRegion		EQU	-618
_LVOAndRegionRegion		EQU	-624
_LVOSetRGB4CM			EQU	-630
_LVOBltMaskBitMapRastPort 	EQU	-636
_LVOAttemptLockLayerRom		EQU	-654
_LVOGfxNew			EQU	-660
_LVOGfxFree			EQU	-666
_LVOGfxAssociate		EQU	-672
_LVOBitMapScale			EQU	-678
_LVOScalerDiv			EQU	-684
_LVOTextExtent			EQU	-690
_LVOTextFit			EQU	-696
_LVOGfxLookUp			EQU	-702
_LVOVideoControl		EQU	-708
_LVOOpenMonitor			EQU	-714
_LVOCloseMonitor		EQU	-720
_LVOFindDisplayInfo		EQU	-726
_LVONextDisplayInfo		EQU	-732
_LVOAddDisplayInfo		EQU	-738
_LVOAddDisplayInfoData		EQU	-744
_LVOSetDisplayInfoData		EQU	-750
_LVOGetDisplayInfoData		EQU	-756
_LVOFontExtent			EQU	-762
_LVOReadPixelLine8		EQU	-768
_LVOWritePixelLine8		EQU	-774
_LVOReadPixelArray8		EQU	-780
_LVOWritePixelArray8		EQU	-786
_LVOGetVPModeID			EQU	-792
_LVOModeNotAvailable		EQU	-798
_LVOWeighTAMatch		EQU	-804
_LVOEraseRect			EQU	-810
_LVOExtendFont			EQU	-816
_LVOStripFont			EQU	-822
_LVOCalcIVG			EQU	-828 
_LVOAttachPalExtra		EQU	-834 
_LVOObtainBestPenA		EQU	-840 
_LVOGfxInternal3		EQU	-846 
_LVOSetRGB32			EQU	-852 
_LVOGetAPen			EQU	-858 
_LVOGetBPen			EQU	-864 
_LVOGetDrMd			EQU	-870 
_LVOGetOutlinePen		EQU	-876 
_LVOLoadRGB32			EQU	-882 
_LVOSetChipRev			EQU	-888 
_LVOSetABPenDrMd		EQU	-894 
_LVOGetRGB32			EQU	-900 
_LVOGfxSpare1			EQU	-906 
_LVOgraphicsPrivate4		EQU	-912 
_LVOAllocBitMap			EQU	-918 
_LVOFreeBitMap			EQU	-924 
_LVOGetExtSpriteA		EQU	-930 
_LVOCoerceMode			EQU	-936 
_LVOChangeVPBitMap		EQU	-942 
_LVOReleasePen			EQU	-948 
_LVOObtainPen			EQU	-954 
_LVOGetBitMapAttr		EQU	-960 
_LVOAllocDBufInfo		EQU	-966 
_LVOFreeDBufInfo		EQU	-972 
_LVOSetOutlinePen		EQU	-978 
_LVOSetWriteMask		EQU	-984 
_LVOSetMaxPen			EQU	-990 
_LVOSetRGB32CM			EQU	-996 
_LVOScrollRasterBF		EQU	-1002
_LVOFindColor			EQU	-1008
_LVOGfxSpare2			EQU	-1014
_LVOAllocSpriteDataA		EQU	-1020
_LVOChangeExtSpriteA		EQU	-1026
_LVOFreeSpriteData		EQU	-1032
_LVOSetRPAttrsA			EQU	-1038
_LVOGetRPAttrsA			EQU	-1044
_LVOBestModeIDA			EQU	-1050

	ENDC

;----------------------------------------------------------
*
* ICON.LIBRARY
*
	IFND	_LVOGetIcon

_LVOOBSOLETEGetWBObject		EQU	-30
_LVOOBSOLETEPutWBObject		EQU	-36
_LVOGetIcon			EQU	-42
_LVOPutIcon			EQU	-48
_LVOFreeFreeList		EQU	-54
_LVOOBSOLETEFreeWBObject 	EQU	-60
_LVOOBSOLETEAllocWBObject 	EQU	-66
_LVOAddFreeList			EQU	-72
_LVOGetDiskObject		EQU	-78
_LVOPutDiskObject		EQU	-84
_LVOFreeDiskObject		EQU	-90
_LVOFindToolType		EQU	-96
_LVOMatchToolValue		EQU	-102
_LVOBumpRevision		EQU	-108
_LVOFreeAlloc			EQU	-114
_LVOGetDefDiskObject		EQU	-120
_LVOPutDefDiskObject		EQU	-126
_LVOGetDiskObjectNew		EQU	-132
_LVODeleteDiskObject		EQU	-138

	ENDC

;----------------------------------------------------------
*
* IFF.LIBRARY
*
	IFND	_LVOIFFL_OldOpenIFF

_LVOIFFL_OldOpenIFF		EQU	-30
_LVOIFFL_CloseIFF		EQU	-36
_LVOIFFL_FindChunk		EQU	-42
_LVOIFFL_GetBMHD		EQU	-48
_LVOIFFL_GetColorTab		EQU	-54
_LVOIFFL_DecodePic		EQU	-60
_LVOIFFL_SaveBitMap		EQU	-66
_LVOIFFL_SaveClip		EQU	-72
_LVOIFFL_IFFError		EQU	-78
_LVOIFFL_GetViewModes		EQU	-84
_LVOIFFL_OldNewOpenIFF		EQU	-90
_LVOIFFL_ModifyFrame		EQU	-96
_LVOIFFL_OldPPOpenIFF		EQU	-102
_LVOIFFL_OpenIFF		EQU	-120
_LVOIFFL_PushChunk		EQU	-126
_LVOIFFL_PopChunk		EQU	-132
_LVOIFFL_WriteChunkBytes	EQU	-138
_LVOIFFL_CompressBlock		EQU	-144
_LVOIFFL_DecompressBlock	EQU	-150

	ENDC

;----------------------------------------------------------
*
* IFFPARSE.LIBRARY
*
	IFND	_LVOAllocIFF

_LVOAllocIFF			EQU	-30
_LVOOpenIFF			EQU	-36
_LVOParseIFF			EQU	-42
_LVOCloseIFF			EQU	-48
_LVOFreeIFF			EQU	-54
_LVOReadChunkBytes		EQU	-60
_LVOWriteChunkBytes		EQU	-66
_LVOReadChunkRecords		EQU	-72
_LVOWriteChunkRecords		EQU	-78
_LVOPushChunk			EQU	-84
_LVOPopChunk			EQU	-90
_LVOEntryHandler		EQU	-102
_LVOExitHandler			EQU	-108
_LVOPropChunk			EQU	-114
_LVOPropChunks			EQU	-120
_LVOStopChunk			EQU	-126
_LVOStopChunks			EQU	-132
_LVOCollectionChunk		EQU	-138
_LVOCollectionChunks		EQU	-144
_LVOStopOnExit			EQU	-150
_LVOFindProp			EQU	-156
_LVOFindCollection		EQU	-162
_LVOFindPropContext		EQU	-168
_LVOCurrentChunk		EQU	-174
_LVOParentChunk			EQU	-180
_LVOAllocLocalItem		EQU	-186
_LVOLocalItemData		EQU	-192
_LVOSetLocalItemPurge		EQU	-198
_LVOFreeLocalItem		EQU	-204
_LVOFindLocalItem		EQU	-210
_LVOStoreLocalItem		EQU	-216
_LVOStoreItemInContext		EQU	-222
_LVOInitIFF			EQU	-228
_LVOInitIFFasDOS		EQU	-234
_LVOInitIFFasClip		EQU	-240
_LVOOpenClipboard		EQU	-246
_LVOCloseClipboard		EQU	-252
_LVOGoodID			EQU	-258
_LVOGoodType			EQU	-264
_LVOIDtoStr			EQU	-270

	ENDC

;----------------------------------------------------------
*
* INPUT.DEVICE
*
	IFND	_LVOPeekQualifier

_LVOPeekQualifier		EQU	-42

	ENDC

;----------------------------------------------------------
*
* INTUITION.LIBRARY
*
	IFND	_LVOOpenIntuition

_LVOOpenIntuition		EQU	-30
_LVOIntuition			EQU	-36
_LVOAddGadget			EQU	-42
_LVOClearDMRequest		EQU	-48
_LVOClearMenuStrip		EQU	-54
_LVOClearPointer		EQU	-60
_LVOCloseScreen			EQU	-66
_LVOCloseWindow			EQU	-72
_LVOCloseWorkBench		EQU	-78
_LVOCurrentTime			EQU	-84
_LVODisplayAlert		EQU	-90
_LVODisplayBeep			EQU	-96
_LVODoubleClick			EQU	-102
_LVODrawBorder			EQU	-108
_LVODrawImage			EQU	-114
_LVOEndRequest			EQU	-120
_LVOGetDefPrefs			EQU	-126
_LVOGetPrefs			EQU	-132
_LVOInitRequester		EQU	-138
_LVOItemAddress			EQU	-144
_LVOModifyIDCMP			EQU	-150
_LVOModifyProp			EQU	-156
_LVOMoveScreen			EQU	-162
_LVOMoveWindow			EQU	-168
_LVOOffGadget			EQU	-174
_LVOOffMenu			EQU	-180
_LVOOnGadget			EQU	-186
_LVOOnMenu			EQU	-192
_LVOOpenScreen			EQU	-198
_LVOOpenWindow			EQU	-204
_LVOOpenWorkBench		EQU	-210
_LVOPrintIText			EQU	-216
_LVORefreshGadgets		EQU	-222
_LVORemoveGadget		EQU	-228
_LVOReportMouse			EQU	-234
_LVORequest			EQU	-240
_LVOScreenToBack		EQU	-246
_LVOScreenToFront		EQU	-252
_LVOSetDMRequest		EQU	-258
_LVOSetMenuStrip		EQU	-264
_LVOSetPointer			EQU	-270
_LVOSetWindowTitles		EQU	-276
_LVOShowTitle			EQU	-282
_LVOSizeWindow			EQU	-288
_LVOViewAddress			EQU	-294
_LVOViewPortAddress		EQU	-300
_LVOWindowToBack		EQU	-306
_LVOWindowToFront		EQU	-312
_LVOWindowLimits		EQU	-318
_LVOSetPrefs			EQU	-324
_LVOIntuiTextLength		EQU	-330
_LVOWBenchToBack		EQU	-336
_LVOWBenchToFront		EQU	-342
_LVOAutoRequest			EQU	-348
_LVOBeginRefresh		EQU	-354
_LVOBuildSysRequest		EQU	-360
_LVOEndRefresh			EQU	-366
_LVOFreeSysRequest		EQU	-372
_LVOMakeScreen			EQU	-378
_LVOReMakeDisplay		EQU	-384
_LVOReThinkDisplay		EQU	-390
_LVOAllocRemember		EQU	-396
_LVOAlohaWorkBench		EQU	-402
_LVOFreeRemember		EQU	-408
_LVOLockIBase			EQU	-414
_LVOUnlockIBase			EQU	-420
_LVOGetScreenData		EQU	-426
_LVORefreshGList		EQU	-432
_LVOAddGList			EQU	-438
_LVORemoveGList			EQU	-444
_LVOActivateWindow		EQU	-450
_LVORefreshWindowFrame		EQU	-456
_LVOActivateGadget		EQU	-462
_LVONewModifyProp		EQU	-468
_LVOQueryOverscan		EQU	-474
_LVOMoveWindowInFrontOf 	EQU	-480
_LVOChangeWindowBox 		EQU	-486
_LVOSetEditHook			EQU	-492
_LVOSetMouseQueue		EQU	-498
_LVOZipWindow			EQU	-504
_LVOLockPubScreen		EQU	-510
_LVOUnlockPubScreen		EQU	-516
_LVOLockPubScreenList 		EQU	-522
_LVOUnlockPubScreenList 	EQU	-528
_LVONextPubScreen		EQU	-534
_LVOSetDefaultPubScreen 	EQU	-540
_LVOSetPubScreenModes		EQU	-546
_LVOPubScreenStatus		EQU	-552
_LVOObtainGIRPort		EQU	-558
_LVOReleaseGIRPort		EQU	-564
_LVOGadgetMouse			EQU	-570
_LVOSetIPrefs			EQU	-576
_LVOGetDefaultPubScreen 	EQU	-582
_LVOEasyRequestArgs		EQU	-588
_LVOBuildEasyRequestArgs 	EQU	-594
_LVOSysReqHandler		EQU	-600
_LVOOpenWindowTagList		EQU	-606
_LVOOpenScreenTagList		EQU	-612
_LVODrawImageState		EQU	-618
_LVOPointInImage		EQU	-624
_LVOEraseImage			EQU	-630
_LVONewObjectA			EQU	-636
_LVODisposeObject		EQU	-642
_LVOSetAttrsA			EQU	-648
_LVOGetAttr			EQU	-654
_LVOSetGadgetAttrsA		EQU	-660
_LVONextObject			EQU	-666
_LVOFindClass			EQU	-672
_LVOMakeClass			EQU	-678
_LVOAddClass			EQU	-684
_LVOGetScreenDrawInfo		EQU	-690
_LVOFreeScreenDrawInfo		EQU	-696
_LVOResetMenuStrip		EQU	-702
_LVORemoveClass			EQU	-708
_LVOFreeClass			EQU	-714
_LVOlockPubClass		EQU	-720		;intuitionPrivat3
_LVOunlockPubClass 		EQU	-726		;intuitionPrivat4
_LVOAllocScreenBuffer 		EQU	-768
_LVOFreeScreenBuffer 		EQU	-774
_LVOChangeScreenBuffer 		EQU	-780
_LVOScreenDepth 		EQU	-786
_LVOScreenPosition 		EQU	-792
_LVOScrollWindowRaster 		EQU	-798
_LVOLendMenus 			EQU	-804
_LVODoGadgetMethodA 		EQU	-810
_LVOSetWindowPointerA 		EQU	-816
_LVOSetWindowPointer 		EQU	-816
_LVOTimedDisplayAlert 		EQU	-822
_LVOHelpControl			EQU	-828

	ENDC

;----------------------------------------------------------
*
* LAYERS.LIBRARY
*
	IFND	_LVOInitLayers

_LVOInitLayers			EQU	-30
_LVOCreateUpfrontLayer		EQU	-36
_LVOCreateBehindLayer		EQU	-42
_LVOUpfrontLayer		EQU	-48
_LVOBehindLayer			EQU	-54
_LVOMoveLayer			EQU	-60
_LVOSizeLayer			EQU	-66
_LVOScrollLayer			EQU	-72
_LVOBeginUpdate			EQU	-78
_LVOEndUpdate			EQU	-84
_LVODeleteLayer			EQU	-90
_LVOLockLayer			EQU	-96
_LVOUnlockLayer			EQU	-102
_LVOLockLayers			EQU	-108
_LVOUnlockLayers		EQU	-114
_LVOLockLayerInfo		EQU	-120
_LVOSwapBitsRastPortClipRect 	EQU	-126
_LVOWhichLayer			EQU	-132
_LVOUnlockLayerInfo		EQU	-138
_LVONewLayerInfo		EQU	-144
_LVODisposeLayerInfo		EQU	-150
_LVOFattenLayerInfo		EQU	-156
_LVOThinLayerInfo		EQU	-162
_LVOMoveLayerInFrontOf		EQU	-168
_LVOInstallClipRegion		EQU	-174
_LVOMoveSizeLayer		EQU	-180
_LVOCreateUpfrontHookLayer 	EQU	-186
_LVOCreateBehindHookLayer  	EQU	-192
_LVOInstallLayerHook		EQU	-198
_LVOInstallLayerInfoHook   	EQU	-204
_LVOSortLayerCR			EQU	-210
_LVODoHookClipRects		EQU	-216
	ENDC

;----------------------------------------------------------
*
* LH.LIBRARY
*
	IFND	_LVOCreateBuffer
_LVOCreateBuffer		EQU	-30
_LVODeleteBuffer		EQU	-36
_LVOLhEncode			EQU	-42
_LVOLhDecode			EQU	-48

	ENDC

;----------------------------------------------------------
*
* LOCALE.LIBRARY
*
	IFND	_LVOCloseCatalog

_LVOlocalePrivate1		EQU	-30
_LVOCloseCatalog		EQU	-36
_LVOCloseLocale			EQU	-42
_LVOConvToLower			EQU	-48
_LVOConvToUpper			EQU	-54
_LVOFormatDate			EQU	-60
_LVOFormatString		EQU	-66
_LVOGetCatalogStr		EQU	-72
_LVOGetLocaleStr		EQU	-78
_LVOIsAlNum			EQU	-84
_LVOIsAlpha			EQU	-90
_LVOIsCntrl			EQU	-96
_LVOIsDigit			EQU	-102
_LVOIsGraph			EQU	-108
_LVOIsLower			EQU	-114
_LVOIsPrint			EQU	-120
_LVOIsPunct			EQU	-126
_LVOIsSpace			EQU	-132
_LVOIsUpper			EQU	-138
_LVOIsXDigit			EQU	-144
_LVOOpenCatalogA		EQU	-150
_LVOOpenLocale			EQU	-156
_LVOParseDate			EQU	-162
_LVOlocalePrivate2		EQU	-168
_LVOStrConvert			EQU	-174
_LVOStrnCmp			EQU	-180
_LVOlocalePrivate3		EQU	-186
_LVOlocalePrivate4		EQU	-192
_LVOlocalePrivate5		EQU	-198
_LVOlocalePrivate6		EQU	-204
_LVOlocalePrivate7		EQU	-210
_LVOlocalePrivate8		EQU	-216

	ENDC

;----------------------------------------------------------
*
* KEYMAP.LIBRARY
*
	IFND	_LVOSetKeyMapDefault
_LVOSetKeyMapDefault		EQU	-30
_LVOAskKeyMapDefault		EQU	-36
_LVOMapRawKey			EQU	-42
_LVOMapANSI			EQU	-48

	ENDC

;----------------------------------------------------------
*
* MATHFFP.LIBRARY
*
	IFND	_LVOSPFix
_LVOSPFix			EQU	-30
_LVOSPFlt			EQU	-36
_LVOSPCmp			EQU	-42
_LVOSPTst			EQU	-48
_LVOSPAbs			EQU	-54
_LVOSPNeg			EQU	-60
_LVOSPAdd			EQU	-66
_LVOSPSub			EQU	-72
_LVOSPMul			EQU	-78
_LVOSPDiv			EQU	-84
_LVOSPFloor			EQU	-90
_LVOSPCeil			EQU	-96

	ENDC

;----------------------------------------------------------
*
* MATHIEEEDOUBBAS.LIBRARY
*
	IFND	_LVOIEEEDPFix
_LVOIEEEDPFix			EQU	-30
_LVOIEEEDPFlt			EQU	-36
_LVOIEEEDPCmp			EQU	-42
_LVOIEEEDPTst			EQU	-48
_LVOIEEEDPAbs			EQU	-54
_LVOIEEEDPNeg			EQU	-60
_LVOIEEEDPAdd			EQU	-66
_LVOIEEEDPSub			EQU	-72
_LVOIEEEDPMul			EQU	-78
_LVOIEEEDPDiv			EQU	-84
_LVOIEEEDPFloor			EQU	-90
_LVOIEEEDPCeil			EQU	-96

	ENDC

;----------------------------------------------------------
*
* MATHIEEEDOUBTRANS.LIBRARY
*
	IFND	_LVOIEEEDPAtan
_LVOIEEEDPAtan			EQU	-30
_LVOIEEEDPSin			EQU	-36
_LVOIEEEDPCos			EQU	-42
_LVOIEEEDPTan			EQU	-48
_LVOIEEEDPSincos		EQU	-54
_LVOIEEEDPSinh			EQU	-60
_LVOIEEEDPCosh			EQU	-66
_LVOIEEEDPTanh			EQU	-72
_LVOIEEEDPExp			EQU	-78
_LVOIEEEDPLog			EQU	-84
_LVOIEEEDPPow			EQU	-90
_LVOIEEEDPSqrt			EQU	-96
_LVOIEEEDPTieee			EQU	-$66
_LVOIEEEDPFieee			EQU	-$6c
_LVOIEEEDPAsin			EQU	-$72
_LVOIEEEDPAcos			EQU	-$78
_LVOIEEEDPLog10			EQU	-$7e

	ENDC

;----------------------------------------------------------
*
* MATHIEEESINGBAS.LIBRARY
*
	IFND	_LVOIEEESPFix
_LVOIEEESPFix			EQU	-30
_LVOIEEESPFlt			EQU	-36
_LVOIEEESPCmp			EQU	-42
_LVOIEEESPTst			EQU	-48
_LVOIEEESPAbs			EQU	-54
_LVOIEEESPNeg			EQU	-60
_LVOIEEESPAdd			EQU	-66
_LVOIEEESPSub			EQU	-72
_LVOIEEESPMul			EQU	-78
_LVOIEEESPDiv			EQU	-84
_LVOIEEESPFloor			EQU	-90
_LVOIEEESPCeil			EQU	-96

	ENDC

;----------------------------------------------------------
*
* MATHIEEESINGTRANS.LIBRARY
*
	IFND	_LVOIEEESPAtan
_LVOIEEESPAtan			EQU	-30
_LVOIEEESPSin			EQU	-36
_LVOIEEESPCos			EQU	-42
_LVOIEEESPTan			EQU	-48
_LVOIEEESPSincos		EQU	-54
_LVOIEEESPSinh			EQU	-60
_LVOIEEESPCosh			EQU	-66
_LVOIEEESPTanh			EQU	-72
_LVOIEEESPExp			EQU	-78
_LVOIEEESPLog			EQU	-84
_LVOIEEESPPow			EQU	-90
_LVOIEEESPSqrt			EQU	-96
_LVOIEEESPTieee			EQU	-$66
_LVOIEEESPFieee			EQU	-$6c
_LVOIEEESPAsin			EQU	-$72
_LVOIEEESPAcos			EQU	-$78
_LVOIEEESPLog10			EQU	-$7e

	ENDC

;----------------------------------------------------------
*
* MATHTRANS.LIBRARY
*
	IFND	_LVOSPAtan
_LVOSPAtan			EQU	-30
_LVOSPSin			EQU	-36
_LVOSPCos			EQU	-42
_LVOSPTan			EQU	-48
_LVOSPSincos			EQU	-54
_LVOSPSinh			EQU	-60
_LVOSPCosh			EQU	-66
_LVOSPTanh			EQU	-72
_LVOSPExp			EQU	-78
_LVOSPLog			EQU	-84
_LVOSPPow			EQU	-90
_LVOSPSqrt			EQU	-96
_LVOSPTieee			EQU	-$66
_LVOSPFieee			EQU	-$6c
_LVOSPAsin			EQU	-$72
_LVOSPAcos			EQU	-$78
_LVOSPLog10			EQU	-$7e

	ENDC

;----------------------------------------------------------
*
* MISC.LIBRARY
*
	IFND	_LVOAllocMiscResource
_LVOAllocMiscResource		EQU	-6
_LVOFreeMiscResource		EQU	-$c

	ENDC

;----------------------------------------------------------
*
* POTGO.RESOURCE
*

	IFND	_LVOAllocPotBits

_LVOAllocPotBits		EQU	-6
_LVOFreePotBits			EQU	-12
_LVOWritePotgo			EQU	-18

	ENDC

;----------------------------------------------------------
*
* POWERPACKER.LIBRARY
*
	IFND	_LVOppLoadData

_LVOppLoadData			EQU	-30
_LVOppDecrunchBuffer		EQU	-36
_LVOppCalcChecksum		EQU	-42
_LVOppCalcPasskey		EQU	-48
_LVOppDecrypt			EQU	-54
_LVOppGetPassword		EQU	-60
_LVOOBSOLETEppGetString		EQU	-66
_LVOOBSOLETEppGetLong		EQU	-72
_LVOppDecrHdr			EQU	-78
_LVOppCryptDecrHdr		EQU	-84
_LVOppOverlayDecrHdr		EQU	-90
_LVOppAllocCrunchInfo		EQU	-96
_LVOppFreeCrunchInfo		EQU	-102
_LVOppCrunchBuffer		EQU	-108
_LVOppWriteDataHeader		EQU	-114
_LVOppEnterPassword		EQU	-120
_LVOppPasswordCallback		EQU	-126
_LVOppErrorMessage		EQU	-132

	ENDC

;----------------------------------------------------------
*
* RAMDRIVE.LIBRARY
*
	IFND	_LVOKillRAD0

_LVOKillRAD0			EQU	-42
_LVOKillRAD			EQU	-48

	ENDC

;----------------------------------------------------------
*
* REQ.LIBRARY
*
	IFND	_LVOCenter

_LVOCenter			EQU	-30
_LVOSetSize			EQU	-36
_LVOSetLocation			EQU	-42
_LVOReadLocation		EQU	-48
_LVOrqFormat			EQU	-54	;_LVOForma!
_LVOFakeFunction1		EQU	-60
_LVOFakeFunction2		EQU	-66
_LVOFakeFunction3		EQU	-72
_LVOFakeFunction4		EQU	-78
_LVOFileRequester		EQU	-84
_LVOColorRequester		EQU	-90
_LVODrawBox			EQU	-96
_LVOMakeButton			EQU	-102
_LVOMakeScrollBar		EQU	-108
_LVOPurgeFiles			EQU	-114
_LVOGetFontHeightAndWidth	EQU	-120
_LVOMakeGadget			EQU	-126
_LVOMakeString			EQU	-132
_LVOMakeProp			EQU	-138
_LVOLinkGadget			EQU	-144
_LVOLinkStringGadget		EQU	-150
_LVOLinkPropGadget		EQU	-156
_LVOGetString			EQU	-162
_LVORealTimeScroll		EQU	-168
_LVOTextRequest			EQU	-174
_LVOGetLong			EQU	-180
_LVORawKeyToAscii		EQU	-186
_LVOExtendedColorRequester	EQU	-192
_LVONewGetString		EQU	-198

	ENDC

;----------------------------------------------------------
*
* REQTOOLS.LIBRARY
*
	IFND	_LVOrtAllocRequestA

_LVOrtAllocRequestA		EQU	-30
_LVOrtFreeRequest		EQU	-36
_LVOrtFreeReqBuffer		EQU	-42
_LVOrtChangeReqAttrA		EQU	-48
_LVOrtFileRequestA		EQU	-54
_LVOrtFreeFileList		EQU	-60
_LVOrtEZRequestA		EQU	-66
_LVOrtGetStringA		EQU	-72
_LVOrtGetLongA			EQU	-78
_LVOrtInternalGetPasswordA 	EQU	-84
_LVOrtInternalEnterPasswordA 	EQU	-90
_LVOrtFontRequestA		EQU	-96
_LVOrtPaletteRequestA		EQU	-102
_LVOrtReqHandlerA		EQU	-108
_LVOrtSetWaitPointer		EQU	-114
_LVOrtGetVScreenSize		EQU	-120
_LVOrtSetReqPosition		EQU	-126
_LVOrtSpread			EQU	-132
_LVOrtScreenToFrontSafely 	EQU	-138

	ENDC

;----------------------------------------------------------
*
* REXXSYSLIB.LIBRARY
*
	IFND	_LVOCreateArgstring

_LVOCreateArgstring		EQU	-126
_LVODeleteArgstring		EQU	-132
_LVOLengthArgstring		EQU	-138
_LVOCreateRexxMsg		EQU	-144
_LVODeleteRexxMsg		EQU	-150
_LVOClearRexxMsg		EQU	-156
_LVOFillRexxMsg			EQU	-162
_LVOIsRexxMsg			EQU	-168
_LVOLockRexxBase		EQU	-450
_LVOUnlockRexxBase		EQU	-456

	ENDC

;----------------------------------------------------------
*
* ROMBOOT.LIBRARY
*
	IFND	_LVORomBoot
_LVORomBoot			EQU	-30

	ENDC

;----------------------------------------------------------
*
* TIMER.DEVICE
*
	IFND	_LVOAddTime

_LVOAddTime			EQU	-42
_LVOSubTime			EQU	-48
_LVOCmpTime			EQU	-54
_LVOReadEClock			EQU	-60
_LVOGetSysTime			EQU	-66

	ENDC

;----------------------------------------------------------
*
* TOOLMANAGER.LIBRARY
*
	IFND	_LVOQuitToolManager
_LVOReserved1			EQU	-30
_LVOQuitToolManager		EQU	-36
_LVOAllocTMHandle		EQU	-42
_LVOFreeTMHandle		EQU	-48
_LVOCreateTMObjectTagList	EQU	-54
_LVODeleteTMObject		EQU	-60
_LVOChangeTMObjectTagList	EQU	-66

	ENDC

;----------------------------------------------------------
*
* TRANSLATOR.DEVICE
*
	IFND	_LVOTranslate

_LVOTranslate			EQU	-30

	ENDC

;----------------------------------------------------------
*
* UTILITY.LIBRARY
*
	IFND	_LVOFindTagItem

_LVOFindTagItem			EQU	-30
_LVOGetTagData			EQU	-36
_LVOPackBoolTags		EQU	-42
_LVONextTagItem			EQU	-48
_LVOFilterTagChanges		EQU	-54
_LVOMapTags			EQU	-60
_LVOAllocateTagItems		EQU	-66
_LVOCloneTagItems		EQU	-72
_LVOFreeTagItems		EQU	-78
_LVORefreshTagItemClones 	EQU	-84
_LVOTagInArray			EQU	-90
_LVOFilterTagItems		EQU	-96
_LVOCallHookPkt			EQU	-102
_LVOAmiga2Date			EQU	-120
_LVODate2Amiga			EQU	-126
_LVOCheckDate			EQU	-132
_LVOSMult32			EQU	-138
_LVOUMult32			EQU	-144
_LVOSDivMod32			EQU	-150
_LVOUDivMod32			EQU	-156
_LVOStricmp			EQU	-162
_LVOStrnicmp			EQU	-168
_LVOToUpper			EQU	-174
_LVOToLower			EQU	-180
_LVOApplyTagChanges		EQU	-186
_LVOSMult64			EQU	-198
_LVOUMult64			EQU	-204
_LVOPackStructureTags		EQU	-210
_LVOUnpackStructureTags		EQU	-216
_LVOAddNamedObject		EQU	-222
_LVOAllocNamedObjectA		EQU	-228
_LVOAttemptRemNamedObject  	EQU	-234
_LVOFindNamedObject		EQU	-240
_LVOFreeNamedObject		EQU	-246
_LVONamedObjectName		EQU	-252
_LVOReleaseNamedObject		EQU	-258
_LVORemNamedObject		EQU	-264
_LVOGetUniqueID			EQU	-270

	ENDC

;----------------------------------------------------------
*
* VECTOR.LIBRARY
*
	IFND	_LVOSetVBI

_LVOSetVBI			EQU	-30
_LVOInitVBOBs			EQU	-36
_LVOOpenVScreen			EQU	-42
_LVOCloseVScreen		EQU	-48
_LVOUseJoy			EQU	-54
_LVODoAnim			EQU	-60
_LVORotateX			EQU	-66
_LVORotateY			EQU	-72
_LVORotateZ			EQU	-78
_LVOFreeVBOBs			EQU	-84
_LVOAutoScaleOn			EQU	-90
_LVOAutoScaleOff		EQU	-96
_LVOFreeJoy			EQU	-102
_LVOSetColors			EQU	-108

	ENDC

;----------------------------------------------------------
*
* WB.LIBRARY
*
	IFND	_LVOAddAppWindowA
_LVOwbPrivate1			EQU	-30
_LVOwbPrivate2			EQU	-36
_LVOwbPrivate3			EQU	-42
_LVOAddAppWindowA		EQU	-48
_LVORemoveAppWindow		EQU	-54
_LVOAddAppIconA			EQU	-60
_LVORemoveAppIcon		EQU	-66
_LVOAddAppMenuItemA		EQU	-72
_LVORemoveAppMenuItem		EQU	-78
_LVOwbPrivate4			EQU	-84
_LVOWBInfo			EQU	-90

	ENDC

;----------------------------------------------------------
*
* XPKMASTER.LIBRARY
*
	IFND	_LVOXpkPackerInfo

_LVOXpkPackerInfo		EQU	-30
_LVOXpkExamine			EQU	-36
_LVOXpkPack			EQU	-42
_LVOXpkUnpack			EQU	-48
_LVOXpkOpen			EQU	-54
_LVOXpkRead			EQU	-60
_LVOXpkWrite			EQU	-66
_LVOXpkSeek			EQU	-72
_LVOXpkClose			EQU	-78
_LVOXpkQuery			EQU	-84

	ENDC

;----------------------------------------------------------
*
* XPKSUB.LIBRARY
*
	IFND	_LVOXpksPackerInfo

_LVOXpksPackerInfo		EQU	-30
_LVOXpksPackChunk		EQU	-36
_LVOXpksPackFree		EQU	-42
_LVOXpksPackReset		EQU	-48
_LVOXpksUnpackChunk		EQU	-54
_LVOXpksUnpackFree		EQU	-60

	ENDC

;-------------------------------------------------------------------------------
	END
