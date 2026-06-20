	IFND	LIBRARIES_CRM_I
LIBRARIES_CRM_I	SET	1

	IFND	EXEC_TYPES_I
	include	exec/types.i
	ENDC
	IFND	UTILITY_TAGITEM_I
	include	utility/tagitem.i
	ENDC

CRMNAME	MACRO
	dc.b	"CrM.library",0
	ENDM

CRMVERSION	equ	4

** Data Header
***************
    STRUCTURE	DataHeader,0
	ULONG	dh_ID
	UWORD	dh_MinSecDist
	ULONG	dh_OriginalLen
	ULONG	dh_CrunchedLen
	LABEL	dh_SIZEOF

** CurrentStats
****************
    STRUCTURE	cmCurrentStats,0
	ULONG	cmcu_ToGo
	ULONG	cmcu_Len
	LABEL	cmcu_SIZEOF

** CrunchStruct(ure)
*********************
    STRUCTURE	cmCrunchStruct,0
	APTR	cmcr_Src		;Source Start
	ULONG	cmcr_SrcLen		;Source Len
	APTR	cmcr_Dest		;Destination Start
	ULONG	cmcr_DestLen		;Destination Len (maximum)
	APTR	cmcr_DataHdr		;DataHeader
	APTR	cmcr_DisplayHook	;Hook to display ToGo/Gain Counters
** Registers hold these values when the Hook is called:
** a0:struct Hook*  a2:struct cmCrunchStruct*  a1:struct cmCurrentStats*
** you have to return TRUE/FALSE in d0 to continue/abort crunching!
	UWORD	cmcr_DisplayStep	;time between 2 calls to the Hook
*******	readonly:
	UWORD	cmcr_Offset		;desired Offset
	UWORD	cmcr_HuffSize		;HuffLen in KBytes
	UWORD	cmcr_Algo		;desired Packalgorithm
	ULONG	cmcr_MaxOffset		;biggest possible Offset (Buffer allocated)
	ULONG	cmcr_RealOffset		;currently used Offset
	ULONG	cmcr_MinSecDist		;MinSecDist for packed Data
	ULONG	cmcr_CrunchedLen	;Length of crunched Data at cmcr_Dest
******* private:
	APTR	cmcr_HuffTabs
	APTR	cmcr_HuffBuf
	ULONG	cmcr_HuffLen
	ULONG	cmcr_SpeedLen
	APTR	cmcr_SpeedTab
	APTR	cmcr_MegaSpeedTab
	BYTE	cmcr_QuitFlag		;readonly: reason for failure
	BYTE	cmcr_OverlayFlag
	BYTE	cmcr_LEDFlashFlag
	BYTE	cmcr_Pad
	LABEL	cmcr_SIZEOF		* upto here: CrunchStruct for User

** Result Codes of cmCheckCrunched()
** and Symbols for the CMCS_Algo Tag
*************************************
cm_Normal	equ	1
cm_LZH		equ	2
cmB_Sample	equ	4
cmF_Sample	equ	1<<cmB_Sample
cmB_PW		equ	5
cmF_PW		equ	1<<cmB_PW
cmB_Overlay	equ	8			;only for the
cmF_Overlay	equ	1<<cmB_Overlay		;CMCS_Algo Tag!
cmB_LEDFlash	equ	9			;only for the
cmF_LEDFlash	equ	1<<cmB_LEDFlash		;CMCS_Algo Tag!

** Use this mask to get the crunch algorithm without any other flags:
cm_AlgoMask	equ	%0000000000001111

** Action Codes for cmProcessPW()
**********************************
cm_AddPW	equ	1
cm_RemovePW	equ	2
cm_RemoveAll	equ	3

** Action Codes for cmCryptData()
**********************************
cm_EnCrypt	equ	4
cm_DeCrypt	equ	5

** Action Codes for cmProcessCrunchStruct()
********************************************
cm_AllocStruct	equ	6
cm_FreeStruct	equ	7

** Tags for cmProcessCrunchStruct()
************************************
CM_TagBase	equ	TAG_USER
CMCS_Algo	equ	CM_TagBase+1		;default: cm_LZH
CMCS_Offset	equ	CM_TagBase+2		;default: $7ffe
CMCS_HuffSize	equ	CM_TagBase+3		;default: 16

** for older Code, _DON'T_ use in new code:
********************************************
dh_OrginalLen	equ	dh_OriginalLen
cm_Sample	equ	16
cm_NormSamp	equ	cm_Normal!cm_Sample
cm_LZHSamp	equ	cm_LZH!cm_Sample
	ENDC	; LIBRARIES_CRM_I
