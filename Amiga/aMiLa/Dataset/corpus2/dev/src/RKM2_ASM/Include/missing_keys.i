	IFND    MISSING_KEYS_I
MISSING_KEYS_I  SET     1
**
**	$VER: missing keys.i 1.0 (17.4.2001)
**	Includes Release 40.15
**
**	Interface definitions for Missing Keys applications
**
**	Written By: John White, 17.4.2001
**	This include is PUBLIC DOMAIN
**


; ======================================================================== 
; === PortMessage ======================================================= 
; ======================================================================== 
;
;
;

	STRUCTURE PortMessage,0

	STRUCT pm_ExecMessage,MN_SIZE

	; the Missing Keys command to issue
	WORD pm_Command

	; the Missing Keys action to take on the pm_Command
	WORD pm_Action

	; the same as TV_SECS
	LONG pm_Seconds

	; the same as TV_MICRO
	LONG pm_Micros

	; the Data field is for any Missing Keys data value/s
	BYTE pm_Data

	; the Status field is for any Missing Keys data value/s
	BYTE pm_Status

	; the String pointer is for any Missing Keys text message/s
	APTR pm_String

	; the Memory pointer is for any Missing Keys memory/functions
	APTR pm_Memory

	; the Code is for any Missing Keys code/memory/functions/etc use
	LONG pm_Code

	LABEL  pm_SIZEOF


; --- pm_Command Bits ------------------------------------------------------

PMCOMMAND_SETGAMEPORT		EQU	$0001
PMCOMMAND_SETCONTROLLER		EQU	$0002
PMCOMMAND_SETKEYREPEATTIME	EQU	$0004
PMCOMMAND_SETKEYPRESSTIME	EQU	$0008
PMCOMMAND_USENUMERICPAD		EQU	$0010
PMCOMMAND_GETSTATUS		EQU	$0020
PMCOMMAND_SETBORDER		EQU	$0040
PMCOMMAND_DISKDRIVECLICK	EQU	$0080
PMCOMMAND_QUIT			EQU	$FFFF

; --- pm_Action Bits ------------------------------------------------------
;
; --- Set GamePort --------------------------------------------------------

PMGAMEPORT_MOUSEINMPORT		EQU	$0001
PMGAMEPORT_MOUSEINJPORT		EQU	$0002

; --- Set Controller ------------------------------------------------------

PMCONTROLLER_NOCONTROLLER	EQU	$0000
PMCONTROLLER_MOUSE		EQU	$0001
PMCONTROLLER_RELATIVEJOYSTICK	EQU	$0002
PMCONTROLLER_ABSOLUTEJOYSTICK	EQU	$0003

; --- Set Border ----------------------------------------------------------

PMBORDER_OFF			EQU	$0001
PMBORDER_ON			EQU	$0002

; --- DiskDrive Click -----------------------------------------------------

PMDF0CLICK_OFF			EQU	$0001
PMDF1CLICK_OFF			EQU	$0002
PMDF2CLICK_OFF			EQU	$0004
PMDF3CLICK_OFF			EQU	$0008
PMDF0CLICK_ON			EQU	$0010
PMDF1CLICK_ON			EQU	$0020
PMDF2CLICK_ON			EQU	$0040
PMDF3CLICK_ON			EQU	$0080


	ENDC