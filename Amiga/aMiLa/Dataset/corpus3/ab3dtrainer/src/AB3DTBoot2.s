
	OPT O+,W-
;	OUTPUT GAMES:AB3D/AB3DTBoot
	OUTPUT PROJ:AB3DTrainer/dist/AB3DTrainer/AB3DTBoot

;----------------------------------------------------------------------
	;For NewStartup

StartSkip:	equ 1	;0=WB/CLI, 1=CLI only (eg. from AsmOne)
Processor:	equ 0	;0/680x0 (= 0 is faster than 68000)
MathProc:	equ 0	;FPU: 0(none)/68881/68882/68040

;-----------------

EXECCALL:	MACRO
	move.l $4.w,a6
	jsr _LVO\1(a6)
	ENDM

DOSCALL:	MACRO
	LibBase dos
	jsr _LVO\1(a6)
	ENDM

LOWCALL:	MACRO
	LibBase lowlevel
	jsr _LVO\1(a6)
	ENDM

CALLA6:	MACRO
	jsr _LVO\1(a6)
	ENDM

;----------------------------------------------------------------------

NumTrainers:	equ 4		;Number of trainers
NumVersions:	equ 3		;Number of versions we know about
	
	INCLUDE exec/execbase.i
 	INCLUDE include:dos/dosextens.i
 	INCLUDE include:libraries/lowlevel.i
 	INCLUDE include:LVOs.i
	INCLUDE INCLUDE:NewStartup39.s

	;Build version string
	dc.b "$VER: AB3D Trainer loader v3.01 ("
	INCLUDE ENV:BuildTimeS.s
	dc.b ") © 1997 John Girvin",13,10,0
	EVEN

Init:	TaskName "AB3DTBoot"	;Set taskname

	DefLib dos,36	;Open the libs we need
	DefLib graphics,0
	DefLib lowlevel,0
	DefEnd		;ALWAYS REQUIRED!!!

;------------------------------------------------------------------------------

Start:	cmp.w	#NumTrainers*2+1,d0	;Right no of params?
	bne	.notrainers		;Skip if not (no trainers)

	lea	.trainflag_tab(pc),a1
	moveq	#NumTrainers-1,d1

.trloop:	movem.l	d1/a1,-(a7)		;Get next argv
	NextArg
	movem.l	(a7)+,d1/a1
	tst.l d0			;Anything?
	beq	.paramdone		;Skip if not

	move.l	d0,a0		;a0=argv
	moveq	#0,d0		;Get parameter in d0
	move.b	(a0),d0
	sub.w	#"0",d0		;Convert to number

	;Set all flags for this trainer
	REPT NumVersions
	move.l	(a1)+,a0
	move.w	d0,(a0)
	ENDR

	dbf 	d1,.trloop
	bra.s	.paramdone
;---

.notrainers:	lea	.trainflag_tab(pc),a1
	moveq	#NumTrainers-1,d0
.nt_loop:
	REPT NumVersions
	move.l	(a1)+,a0
	clr.w	(a0)
	ENDR
	dbf 	d0,.nt_loop

;---
;	Add AB3D1: and AB3D2: assigns to current dir

.paramdone:	move.l #CWDName,d1		;Get name of current dir
	moveq #40,d2
	DOSCALL GetCurrentDirName
	tst.l d0
	beq ass_err

	move.l #Ass1Name,d1		;Add AB3D1:
	move.l #CWDName,d2
	DOSCALL AssignPath

	move.l #Ass2Name,d1		;Add AB3D2:
	move.l #CWDName,d2
	DOSCALL AssignPath

;---
;	Check AB3D1: and AB3D2: exist

	moveq #LDF_ASSIGNS|LDF_READ,d1	;Lock list of names
	DOSCALL LockDosList		;d0=list pointer
	move.l d0,-(a7)

	move.l d0,d1			;See if AB3D1: exists
	move.l #Ass1Name,d2
	moveq #LDF_ASSIGNS,d3
	DOSCALL FindDosEntry
	move.l (a7)+,d1		;d1=doslist
	move.l d0,-(a7)		;Save return code on stack

	move.l #Ass2Name,d2		;See if AB3D2: exists
	moveq #LDF_ASSIGNS,d3
	DOSCALL FindDosEntry
	move.l d0,-(a7)

	moveq #LDF_ASSIGNS|LDF_READ,d1	;Unlock the list
	DOSCALL UnLockDosList

	movem.l (a7)+,d0-1		;d0-1 = result codes
	tst.l d0			;Exit if assigns not added
	beq ass_err
	tst.l d1
	beq ass_err

;---
;	Load and run the HackAB3D executable if reqd

	tst.w .trf_v1hab3d	;Required?
	beq.s .loadexe	;Skip if not

	move.l #HackName,d1	;Load the HackAB3D exe
	DOSCALL LoadSeg
	move.l d0,HSegList
	beq.s .loadexe

	lsl.l #2,d0
	addq.l #4,d0
	move.l d0,a0		;a0=start of code
	jsr (a0)		;Call HackAB3D

	move.l HSegList(pc),d1	;Unload the HackAB3D exe
	DOSCALL UnLoadSeg

;---
;	Load the main "abd.pk" or "abd" executable

.loadexe:	move.l #FileName1,d1	;Try "abd.pk" first
	DOSCALL LoadSeg
	tst.l d0
	bne.s .exeloaded

	move.l #FileName2,d1	;Didnt work, try "abd"
	DOSCALL LoadSeg
	tst.l d0
	beq loadseg_err

.exeloaded:	;Executable loaded, d0=SegList
	move.l d0,SegList

	lsl.l #2,d0		;Get pointer to first hunk's data
	addq.l #4,d0
	move.l d0,a0		;a0=start of code
	move.l a0,-(a7)	;Save it

;---
;	Set controller type to joypad if requested

	move.w .trf_v1joypad(pc),d0	;Required?
	beq.s .nojoypad		;Skip if not

	cmp.w #1,d0			;Joystick?
	lea JoyStickTags(pc),a1
	beq.s .setcontroller		;Skip if yes

	lea JoyPadTags(pc),a1

.setcontroller:
	moveq #1,d0			;Set joypad attributes
	LOWCALL SetJoyPortAttrsA

.nojoypad:

;---
;	SetFunction AddIntServer to jump to me

	move.l 4.w,a1	  ;a1=exec lib base
	move.l #_LVOAddIntServer,a0 ;a0=function offset
	move.l #.patch_1,d0	  ;d0=new function
	EXECCALL SetFunction
	move.l d0,OldAddIntServer+2

	EXECCALL CacheClearU	;Clear the caches (just did a self-modify)

;---
;	Start abd.pk

	LibBase graphics
	sub.l a1,a1		; clear a1
	CALLA6 LoadView 	; Flush View to nothing
	CALLA6 WaitTOF 	; Wait once
	CALLA6 WaitTOF 	; Wait again.

	moveq #1,d0		;Start the game (doesnt return)
	lea FakeParam(pc),a0
	rts

;------------------------------------------------------------------------------

	;Called from AddIntServer

.patch_1:	jsr OldAddIntServer	;Do real AddIntServer stuff

	tst.w .p1_beentrained	;Exit if already trained
	bne.s .p1_done2

	;Check this was called from AB3DTBoot
	movem.l d0-7/a0-6,-(a7)

	LibBase exec		;Get current task pointer
	CALLA6 Forbid
	move.l ThisTask(a6),-(a7)
	CALLA6 Permit

	move.l (a7)+,a0	;a0=task pointer
	move.l LN_NAME(a0),a0	;a0=pointer to task name
	lea .p1_taskname(pc),a1	;a1=pointer to correct name
	moveq #.p1_taskname_e-.p1_taskname-1,d0

.p1_cmploop: cmp.b (a0)+,(a1)+	;Compare names
	dbne d0,.p1_cmploop
	tst.w d0		;Exit if not matching
	bpl.s .p1_done

.p1_namematch;
	;Apply trainers, (a7)=exe address+$36
	st .p1_beentrained
	bsr.s .p1_dotrainers
	
.p1_done:	movem.l (a7)+,d0-7/a0-6
.p1_done2:	rts

;---

.p1_dotrainers:
	;Apply trainers, (a7)=exe address+$36

	move.l 4+$3c(a7),a0	;Get a0=exe address
	lea -$36(a0),a0

	;Get version of game wot is loaded
	move.w $5484(a0),d0

	cmp.w #$9579,d0
	beq.s .p1dt_isv1
	cmp.w #$33c0,d0
	beq.s .p1dt_isv2

.p1dt_isv3:	lea .trainer_v3(pc),a1
	bra.s .p1dt_gottrainertab

.p1dt_isv2:	lea .trainer_v2(pc),a1
	bra.s .p1dt_gottrainertab

.p1dt_isv1:	lea .trainer_v1(pc),a1

.p1dt_gottrainertab:
	;a0=exe address, a1=trainer table

	moveq #NumTrainers-1,d7	;d7=no of trainers-1

.p1dt_loop:	tst.w (a1)+		;Use this trainer?
	bne.s .p1dt_active	;Skip if yes

	;Trainer inactive...just read over its data
.p1dt_skiploop:
	tst.l (a1)+
	beq.s .p1dt_next
	addq.l #4,a1
	bra.s .p1dt_skiploop

.p1dt_active:
	;Trainer active...apply the pokes, with checks!

.p1dt_pokeloop:
	move.l (a1)+,d0	;d0=offset
	beq.s .p1dt_next	;Back to start if done

	move.l a0,a2		;a2=base address
	add.l d0,a2		;a2=poke address

	move.w (a2),d0	;d0=current contents
	cmp.w (a1)+,d0	;What we expect?
	bne.s .p1dt_pokeerr	;Skip if not

	move.w (a1)+,(a2)	;Do the poke
	bra.s .p1dt_pokeloop

.p1dt_next:	dbf d7,.p1dt_loop
.p1dt_pokeerr:
	rts
;---

.p1_beentrained:	dc.w 0		;Set NZ after game is patched

.p1_taskname:	dc.b "AB3DTBoot",0	;Correct name of task
.p1_taskname_e:
		EVEN

;------------------------------------------------------------------------------

	CNOP 0,4
.trainflag_tab:
	dc.l .trf_v1nrg
	dc.l .trf_v2nrg
	dc.l .trf_v3nrg
	dc.l .trf_v1ammo
	dc.l .trf_v2ammo
	dc.l .trf_v3ammo
	dc.l .trf_v1hab3d
	dc.l .trf_v2hab3d
	dc.l .trf_v3hab3d
	dc.l .trf_v1joypad
	dc.l .trf_v2joypad
	dc.l .trf_v3joypad

	;Trainer:
	;  Flag.w
	;  Poke 1:
	;    Pointer to base pointer
	;    Offset.l
	;    Correct value.w
	;    Trained value.w
	;  ...
	;  Poke n:
	;    Pointer to base pointer
	;    Offset.l
	;    Correct value.w
	;    Trained value.w
	;  0.l


.trainer_v1:	;Version 1 trainers
	;Original game unpacked

	;Infinite energy
.trf_v1nrg:	dc.w 0

	dc.l $5484
	dc.w $9579,$6004

	dc.l $5576
	dc.w $9579,$6004

	dc.l 0

	;Infinite ammo
.trf_v1ammo:	dc.w 0

	dc.l $bff2
	dc.w $9441,$4e71

	dc.l $c46a
	dc.w $9441,$4e71

	dc.l 0

	;Use HackAB3D (fake trainer)
.trf_v1hab3d:
	dc.w 0
	dc.l 0

	;Use joypad (fake trainer)
.trf_v1joypad:
	dc.w 0
	dc.l 0



.trainer_v2:	;Version 2 trainers
	;8-channel patch game unpacked

	;Infinite energy
.trf_v2nrg:	dc.w 0
	dc.l $56a4
	dc.w $9579,$6004

	dc.l $5796
	dc.w $9579,$6004

	dc.l 0

	;Infinite ammo
.trf_v2ammo:	dc.w 0

	dc.l $c20a
	dc.w $9441,$4e71

	dc.l $c682
	dc.w $9441,$4e71

	dc.l 0

	;Use HackAB3D (fake trainer)
.trf_v2hab3d:
	dc.w 0
	dc.l 0

	;Use joypad (fake trainer)
.trf_v2joypad:
	dc.w 0
	dc.l 0



.trainer_v3:	;Version 3 trainers
	;CD32 version

	;Infinite energy
.trf_v3nrg:	dc.w 0

	dc.l $3dd2
	dc.w $4a79,$8179
	dc.l $3dd8
	dc.w $6f00,$4e71
	dc.l $3dda
	dc.w $51d4,$4e71

	dc.l $3ddc
	dc.w $4a79,$8179
	dc.l $3de2
	dc.w $6f00,$4e71
	dc.l $3de4
	dc.w $51ca,$4e71

	dc.l 0

	;Infinite ammo
.trf_v3ammo:	dc.w 0

	dc.l $c3a4
	dc.w $9441,$4e71

	dc.l $c81c
	dc.w $9441,$4e71

	dc.l 0

	;Use HackAB3D (fake trainer)
.trf_v3hab3d:
	dc.w 0
	dc.l 0

	;Use joypad (fake trainer)
.trf_v3joypad:
	dc.w 0
	dc.l 0

;------------------------------------------------------------------------------

ass_err:	move.l #.as_msg,d2
	move.l #.as_msge-.as_msg,d3
	bsr LA_Message

	moveq #20,d0
	rts

.as_msg:	dc.b " - could not make 'AB3D1:' or 'AB3D2:' assigns!",13,10,0
.as_msge:
	EVEN

;------------------------------------------------------------------------------

loadseg_err:	move.l #.ls_msg,d2
	move.l #.ls_msge-.ls_msg,d3
	bsr.s LA_Message

	moveq #20,d0
	rts

.ls_msg:	dc.b " - could not load 'abd.pk' or 'abd' executable!",13,10,0
.ls_msge:
	EVEN

;------------------------------------------------------------------------------

LA_Message:	;Print "loading aborted" message and reason
;Entry:	d2=reason message, d3=reason length

	movem.l 	d2/d3,-(a7)		;Save reason message regs

	move.l 	#.la_name,d1		;Setup output to current cli
	move.l 	#MODE_OLDFILE,d2
	DOSCALL 	Open
	tst.l 	d0		;exit if error (we're _really_ in trouble!)
	beq.s 	.la_out
	move.l 	d0,.la_handle

	move.l	#.la_msg_s,d2	;Print "Loading aborted" text
	move.l	#.la_msg_e-.la_msg_s,d3
	move.l 	d0,d1
	DOSCALL 	Write

	move.l 	.la_handle(pc),d1	;Output reason text
	movem.l 	(a7),d2/d3
	DOSCALL 	Write

	move.l 	.la_handle(pc),d1	;close output to cli
	DOSCALL 	Close

.la_out:	addq.l 	#8,a7
	rts

.la_handle:	dc.l	0
.la_name:	dc.b	"CON:50/50/500/80/AB3DTBoot FATAL ERROR!/CLOSE/WAIT",0

.la_msg_s:	dc.b	13,10,"AB3D loading aborted because:",13,10,0
.la_msg_e:
	EVEN

;-----------------------------------------------------
	
	CNOP 0,4
SegList:	dc.l	0
HSegList:	dc.l	0
ExeAddr:	dc.l	0
FakeParam:	dc.b	$0a,00
	
	CNOP 0,4
JoyPadTags:	;Tags to force controller type to joypad
	dc.l	SJA_Type,SJA_TYPE_GAMECTLR
	dc.l	TAG_DONE,TAG_DONE

JoyStickTags:
	;Tags to force controller type to joystick
	dc.l	SJA_Type,SJA_TYPE_JOYSTK
	dc.l	TAG_DONE,TAG_DONE

OldAddIntServer:
	;Old AddIntServer JMP, self modifying
	jmp	0.l

FileName1:	dc.b	"abd.pk",0
FileName2:	dc.b	"abd",0
HackName:	dc.b	"HackAB3D",0
Ass1Name:	dc.b	"AB3D1",0
Ass2Name:	dc.b	"AB3D2",0
CWDName:	dcb.b	40
	EVEN

;-----------------------------------------------------
