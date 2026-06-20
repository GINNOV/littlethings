******************************************************************
*
*
* Copyright (C) 1986, Commodore Amiga Inc.  All rights reserved.
* Permission granted for non-commercial use
*
*****************************************************************
*
* ramdev.i -- external declarations for skeleton ramdisk device
*
*****************************************************************


;--- Assemble-time options
INFO_LEVEL  EQU 0     ; Specify amount of debugging info desired
		      ; If > 0 you must link with debug.lib!
		      ; You will need to run a terminal program to
		      ; set the baud rate.
*INTRRUPT   SET 1     ; Remove "*" to enable fake interrupt code
AUTOMOUNT   EQU 0     ; Work with the "mount" command if 0
		      ; Do it automatically if 1

;--- stack size and priority for the process we will create
MYPROCSTACKSIZE   EQU	$900
MYPROCPRI	  EQU	0   ;Devices are often 5, NOT higher

;--- Base constants
NUMBEROFTRACKS EQU  40	;<<<< Change THIS to change size of ramdisk <<<<
SECTOR	       EQU  512 ;# bytes per sector
SECSHIFT       EQU  9	;Shift count to convert byte # to sector #
SECTORSPER     EQU  10	;# Sectors per "track"

RAMSIZE       EQU   SECTOR*NUMBEROFTRACKS*SECTORSPER
		    ; Use this much RAM per unit
BYTESPERTRACK EQU   SECTORSPER*SECTOR

IAMPULLING    EQU   7	  ; "I am pulling the interrupt" bit of INTCRL1
INTENABLE     EQU   4	  ; "Interrupt Enable" bit of INTCRL2
INTCTRL1      EQU   $40   ; Interrupt control register offset on board
INTCTRL2      EQU   $42   ; Interrupt control register offset on board
INTACK	      EQU   $50   ; My board's interrupt reset address
;-----------------------------------------------------------------------
;
; device command definitions (copied from devices/trackdisk.i)
;
;-----------------------------------------------------------------------
   BITDEF  TD,EXTCOM,15      ; for "extended" commands !!!

   DEVINIT
   DEVCMD   CMD_MOTOR	     ; control the disk's motor (NO-OP)
   DEVCMD   CMD_SEEK	     ; explicit seek (NO-OP)
   DEVCMD   CMD_FORMAT	     ; format disk - equated to WRITE for RAMDISK
   DEVCMD   CMD_REMOVE	     ; notify when disk changes (NO-OP)
   DEVCMD   CMD_CHANGENUM    ; number of disk changes (always 0)
   DEVCMD   CMD_CHANGESTATE  ; is there a disk in the drive? (always TRUE)
   DEVCMD   CMD_PROTSTATUS   ; is the disk write protected? (always FALSE)
   DEVCMD   CMD_RAWREAD      ; Not supported
   DEVCMD   CMD_RAWWRITE     ; Not supported
   DEVCMD   CMD_GETDRIVETYPE ; Get drive type
   DEVCMD   CMD_GETNUMTRACKS ; Get number of tracks
   DEVCMD   CMD_ADDCHANGEINT ; Add disk change interrupt (NO-OP)
   DEVCMD   CMD_REMCHANGEINT ; Remove disk change interrupt ( NO-OP)
   DEVCMD   MYDEV_END	     ; place marker -- first illegal command #

DRIVE3_5	EQU	1
DRIVE5_25	EQU	2
;-----------------------------------------------------------------------
;
; Layout of parameter packet for MakeDosNode
;
;-----------------------------------------------------------------------

    STRUCTURE MkDosNodePkt,0
   APTR    mdn_dosName	 ; Pointer to DOS file handler name
   APTR    mdn_execName   ; Pointer to device driver name
   ULONG   mdn_unit   ; Unit number
   ULONG   mdn_flags   ; OpenDevice flags
   ULONG   mdn_tableSize   ; Environment size
   ULONG   mdn_sizeBlock   ; # longwords in a block
   ULONG   mdn_secOrg	; sector origin -- unused
   ULONG   mdn_numHeads   ; number of surfaces
   ULONG   mdn_secsPerBlk   ; secs per logical block -- unused
   ULONG   mdn_blkTrack   ; secs per track
   ULONG   mdn_resBlks	 ; reserved blocks -- MUST be at least 1!
   ULONG   mdn_prefac	; unused
   ULONG   mdn_interleave   ; interleave
   ULONG   mdn_lowCyl	; lower cylinder
   ULONG   mdn_upperCyl   ; upper cylinder
   ULONG   mdn_numBuffers   ; number of buffers
   ULONG   mdn_memBufType   ; Type of memory for AmigaDOS buffers
   STRUCT  mdn_dName,5	 ; DOS file handler name "RAM0"
   LABEL   mdn_Sizeof	; Size of this structure

;-----------------------------------------------------------------------
;
; device data structures
;
;-----------------------------------------------------------------------
; maximum number of units in this device
MD_NUMUNITS   EQU   4

    STRUCTURE MyDev,LIB_SIZE
   UBYTE   md_Flags
   UBYTE   md_Pad1
   ;now longword aligned
   ULONG   md_SysLib
   ULONG   md_SegList
   ULONG   md_Base	; Base address of this device's expansion board
   STRUCT  md_Units,MD_NUMUNITS*4
   LABEL   MyDev_Sizeof

   STRUCTURE MyDevUnit,UNIT_SIZE   ;Odd # longwords
   UBYTE    mdu_UnitNum
   UBYTE    mdu_SigBit	    ; Signal bit allocated for interrupts
   ;Now longword aligned!
   APTR     mdu_Device
   STRUCT   mdu_stack,MYPROCSTACKSIZE
   STRUCT   mdu_tcb,TC_SIZE	; Task Control Block (TCB) for disk task
   ULONG    mdu_SigMask 	; Signal these bits on interrupt
   IFD	 INTRRUPT
    STRUCT   mdu_is,IS_SIZE	 ; Interrupt structure
    UWORD    mdu_pad1		;Longword align
   ENDC
   STRUCT   mdu_RAM,RAMSIZE	; RAM used to simulate disk
   LABEL    MyDevUnit_Sizeof

   ;------ state bit for unit stopped
   BITDEF   MDU,STOPPED,2

MYDEVNAME   MACRO
      DC.B   'ramdev.device',0
      ENDM
