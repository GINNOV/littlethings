; ===================================================================
;
;                                 S O S
;   
;                         Sanity Operating System
;
;                                 V 2.6
;
;
;             small macro language and environment starndard
;
; ===================================================================



*#***** sosmacros.i/ *******************************************************
*
*   NAME
*
*   SYNOPSIS
*
*   FUNCTION
*
*   INPUTS
*
*   RESULT
*
*   ERRORS
*
*   EXAMPLE
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
****************************************************************************


; ===================================================================
;
;  BPLCON0 - Genlock adaptions
;
; ===================================================================

******* sosmacros.i/GENLOCK **********************************************
*
*   NAME
*	GENLOCK -- Adept copperlist for genlock usage.
*
*   SYNOPSIS
*	GENLOCK CLabel    (MACRO)
*
*   FUNCTION
*	if you set the number of planes, you will usuallly write something
*	like
*
*		dc.w	$0100,$a200		; 2 planes hires
*
*	in your copperlist. But if a genlock is attached to your Amiga,
*	you will have to enable it by writing:
*
*		dc.w	$0100,$a302		; genlock enables
*
*	If you write this on an Amiga without genlock, your computer
*	will crash since there are no syncronisations signals from
*	the genlock.
*	The GENLOCK and GENLOCK2 macro will change the copperlist
*	to reflect the state of the genlock bits. In future you should
*	write
*
*		dc.w	$0100,$a000		; 2 planes hires
*
*	all other bits will be set by the Macro. Since the operating-
*	system is used to determine weather a genlock is used, there 
*	might arise problems since early versions of Kickstart had
*	a bug in the genlock detection.
*
*   INPUTS
*	CLabel - Label to a coppermove instruction that changes BPLCON0.
*
*   EXAMPLE (untested!)
*	here     GENLOCK  genlock1      ; adept first cmove
*	         GENLOCK2 genlock2      ; more cmoves
*	         GENLOCK2 genlock3 
*	         ....
*	         move.w   #$3000,d2     ; enale 3 planes lores
*	         GENLOCK  d2;           ; adept (ATTENTION! SEMIKOLON important)
*	         move.w   d2,genlock2+2 ; and write..
*	         ....
*	Clist    dc.w     D0180,$f0f
*	genlock1 dc.w     $0100,$2000   ; 2 planes Lores
*	         ...
*	genlock2 dc.w     $0100,$0000   ; of
*	         ...
*	genlock3 dc.w     $0100,$a000   ; 2 planes hires
*
*   NOTES
*	if you want to change a register, you must write a semicolon
*	behind the register to avoid the build in "+2".
*
*	If you want to change many positions in the copperlist, you
*	can use the GENLOCK2 macro for all subsequent positions.
*
*	In case of trouble just look in the macro definition. These
*	macros were included to make genlock adaption as easy as possible.
*	But this hasn't stopped us (Chaos/Mr. Pet) to forget it many times.
*
*   BUGS
*
****************************************************************************


GENLOCK	MACRO	; Copperlabel
	jsr	_GetPISS(a6)
	move.w	PISS_BPLCON0(a0),d0
	or.w	d0,\1+2
	ENDM

; Fals weitere Anpassungen nötig sind:

GENLOCK2	MACRO	; Copperlabel
	or.w	d0,\1+2
	ENDM

; ===================================================================
;
;  Environment Sync Macros
;
; ===================================================================

; The PISS allows you to create environment variables. You can use
; whatever structure you like for environments, but the structure 
; discribed here has been used by Chaos/Mr. Pet and is well tested.
; It allows simple creation of trackmos by simply linking effects.
; see main documentation and the RAW demo handler for full discussion.

; All ENV-Macros need a5 set to your variables as discribed in the 
; main documentation and the demo sources to work properly. You must
; provide some variables and labels:

; SOSBase	rs.l	1		; variable relative to a5
; DBUGBase	rs.l	1		; variable relative to a5
; Vars		ds.b	VARS_SIZEOF	; where the a5-variables are put

; ===================================================================

		rsreset
ENV_Flags	rs.l	1	; see below
ENV_Job		rs.l	1	; environment-job
				; usually debugger
ENV_Do		rs.l	1	; environment-irq
				; usually music
ENV_Tick	rs.w	1	; general vbl-counter
ENV_LastTick	rs.w	1	; last tick of effect
ENV_FirstTick	rs.w	1	; first tick of effect
ENV_TotalTicks	rs.w	1	; #ticks of this effect
ENV_MemoryPool	rs.l	1	; should be 0 or point to at least 64 K chip
ENV_Debugger	rs.l	1
ENV_SIZEOF	rs.l	0

ENVFb_Code	equ	0	; _Job and _Do used
ENVFb_Timer	equ	1	; _Ticks used
ENVFb_Memory	equ	2	; Memorypool installed

ENVFf_Code	equ	1
ENVFf_Timer	equ	2
ENVFf_Memory	equ	4

ENVFf_Normal	equ	ENVFf_Code+ENVFf_Timer

******* sosmacros.i/--background-- ****************************************
*
*	All ENV-Macros must be called with a5 pointing to Vars.
*
***************************************************************************


******* sosmacros.i/ENVINIT ************************************************
*
*   NAME
*	ENVINIT -- Initialise standard environment system
*
*   SYNOPSIS
*	ENVINIT EnvFlags,Time    (MACRO)
*
*   FUNCTION
*	Try to find environments. If the environments are already
*	set, use them. If one of the features you requested for your
*	environment is not available (such as the memory pool) it will
*	be created and added to the environment.
*
*	The standard environment will abort the demo if you press the
*	right mousebutton. If you define the label NORMBX this feature 
*	will be suppresed. Don't forget this for the final demo.
*
*   INPUTS
*	EnvFlags         - What features should be installed?
*	    ENVFf_Code   - Code for Job and Irq (specify this allways!)
*	    ENVFf_Timer  - Initialise timer. 
*	    ENVFf_Memory - Allocate memory pool.
*       Time             - How many ticks the demo should run by default.
*
*   EXAMPLE
*	         RSRESET
*	SOSBase  RS.l     1
*	DBUGBase RS.l     1
*	         ...
*
*	         ...
*	         ENVINIT  ENVFf_Code+ENVFf_Timer,$400  ; init environment
*	         ...
*	         ENVWAIT                ; wait for starting tick
*	         ...
*	         jsr      SetInt(a6)    ; set your irq
*
*	Loop     bsr      Jobs          ; main loop
*	         ENVEND   Loop   
*	         moveq    #0,d0         ; end
*	         rts
*
*	MainIrq  movem.l  ...           ; interrupt
*	         lea      Vars,a5       ; a5 variables
*	         move.l   SOSBase(a5),a6; set library base
*	       
*	         ENVDO                  ; ENV. interrupt (music)
*	         ...
*	         nop
*	         rte
*
*   BUGS
*
*   SEE ALSO
*	ENVVARS,ENVINIT,ENVWAIT,ENVDO
*
****************************************************************************

ENVINIT	MACRO

	move.l	a2,-(a7)
	jsr	_GetPISS(a6)		; Hole Env.
	move.l	a0,a2
	move.l	PISS_Environment(a2),a0
	move.l	a0,d0
	bne.s	.\@1			; vorhanden, OK
	moveq	#ENV_SIZEOF,d0		; Alloc Env.
	moveq	#MAT_PUBLIC,d1
	jsr	_AllocMem(a6)
	move.l	d0,a0			; Clr Mem
	moveq	#ENV_SIZEOF/4-1,d1
.\@clr	clr.l	(a0)+
	dbf	d1,.\@clr
	move.l	d0,PISS_Environment(a2)
.\@1	move.l	d0,a2			; a2 = Env
	move.l	a2,Env(a5)		; Setze Env

	IFNE	\1&ENVFf_Memory
	tst.l	ENV_MemoryPool(a2)	; Hole evt. Speicher
	bne.s	.\@2
	move.l	#$10000,d0
	move.l	#MAT_CHIP,d1
	jsr	_AllocBlock(a6)
	move.l	d0,ENV_MemoryPool(a2)
.\@2	;
	ENDC

	IFNE	\1&ENVFf_Timer
	tst.w	ENV_LastTick(a2)		; Setze Timer
	bne.s	.\@3
	move.w	#\2,ENV_LastTick(a2)
	move.w	#\2,ENV_TotalTicks(a2)
.\@3
	ENDC
	IFNE	\1&ENVFf_Code
	tst.l	ENV_Job(a2)		; Setze Job
	bne.s	.\@4
	DEBLOAD				; Load Debugger
	move.l	#.\@Job,ENV_Job(a2)
.\@4	tst.l	ENV_Do(a2)		; Serze Irq
	bne.s	.\@5
	move.l	#.\@Do,ENV_Do(a2)
	bra.s	.\@5
	ENDC

.\@Job	move.l	a5,-(a7)
	lea	Vars,a5
	DEBJOB
	move.l	(a7)+,a5
	rts
.\@Do	move.l	a5,-(a7)
	lea	Vars,a5
	move.l	Env(a5),a0
	IFND	NORMBX
	btst	#2,$dff016
	bne.s	.2
	move.w	ENV_LastTick(a0),ENV_Tick(a0)
	move.l	(a7)+,a5
	rts
	ENDC
.2	move.l	(a7)+,a5
	addq.w	#1,ENV_Tick(a0)
	rts
.\@5	move.l	(a7)+,a2
	ENDM


******* sosmacros.i/ENVWAIT *******************************************************
*
*   NAME
*	ENVWAIT -- Warte for starting tick.
*
*   SYNOPSIS
*	ENVWAIT   (MACRO)
*
*   FUNCTION
*	Wait for the exact timer tick that should start the part.
*	This moment can be set in ENV_FirstTick by the loader.
*	The default value is 0
*
*   EXAMPLE
*	see ENVINIT
*
*   BUGS
*
*   SEE ALSO
*	ENVVARS, ENVINIT, ENVDO, ENVEND
*
****************************************************************************

; Warte bis Startsignal gegeben wurde

ENVWAIT	MACRO
\@xxx	move.l	Env(a5),a0		; Do Job
	move.l	ENV_Job(a0),a0
	jsr	(a0)
	move.l	Env(a5),a0
	move.w	ENV_Tick(a0),d0
	cmp.w	ENV_FirstTick(a0),d0
	blo.s	\@xxx
	ENDM


******* sosmacros.i/ENVDO *****************************************************
*
*   NAME
*	ENVDO -- Environment interrupt routine.
*
*   SYNOPSIS
*	ENVDO  label           (MACRO)
*
*   FUNCTION
*	Call the Environment interrupt code, usually the replay.
*	Increase the ENV_Tick timer.
*
*	If DEBUG is defined, the routine will check the left mousebutton.
*	If it is pressed and you set the label behind your main routine,
*	your main routine will be called only every 16th frame (see
*	examble at ENVINIT). Set the label directly after the ENVDO-macro
*	to disable this feature.
*
*   EXAMPLE
*	siehe ENVINIT
*
*   BUGS
*
*   SEE ALSO
*	ENVVARS, ENVINIT, ENVWAIT, ENVCODE
*
****************************************************************************

; Führe Interrupt-Routine aus. Alle Register werden verändert

ENVDO	MACRO
	move.l	Env(a5),a0
	move.l	ENV_Do(a0),a0
	jsr	(a0)
	IFD	DEBUG
	lea	.IrqCnt(pc),a0
	addq.w	#1,(a0)
	btst	#6,$bfe001
	bne.s	.ok
	moveq	#$f,d0
	and.w	(a0),d0
	bne	\1
	bra.s	.ok
.IrqCnt	dc.w	0
.ok	;
	ENDC
	ENDM


******* sosmacros.i/ENVEND *************************************************
*
*   NAME
*	ENVEND -- Warte auf Ende
*
*   SYNOPSIS
*	ENVEND loop  (MACRO)
*
*   FUNCTION
*	Wait for the end tick of the demo. Call the ENV_Job field.
*	If the demo is not finished, jump back to the loop-label.
*
*   INPUTS
*	loop  - Label for loop.
*   
*   EXAMPLE
*	siehe ENVINIT
*
*   BUGS
*
*   SEE ALSO
*	ENVVARS, ENVINIT, ENVWAIT, ENVCODE, ENVDO
*
****************************************************************************

; Warte auf ende der Aktion. Springe, wenn nicht zuende zum angegebenen 
; Label. Tue Job

ENVEND	MACRO
	move.l	Env(a5),a0		; Do Job
	move.l	ENV_Job(a0),a0
	jsr	(a0)
	move.l	Env(a5),a0		; Wait
	move.w	ENV_Tick(a0),d0
	cmp.w	ENV_LastTick(a0),d0
	blo	\1
	ENDM



; ===================================================================
;
;  Debugger Macros
;
; ===================================================================
;
; Zwei Macros zum starten des kleinen Debuggers.
; Das erste läedt ihn, daß zweite muß im Mainloop laufen.
; Das Label "Debugger" wird gebraucht!
; Beide Proigramme benötigen SOSBase in a6!


*****i* sosmacros.i/DEBLOAD ************************************************
*
*   NAME
*	DEBLOAD -- Lade kleinen Debugger
*
*   SYNOPSIS
*	DEBLOAD   (MACRO)
*
*   FUNCTION
*	Lade den Debugger.
*
*   NOTES
*	Ist in den Standart-Environment enthalten.
*
*   BUGS
*
****************************************************************************

DEBLOAD	MACRO
	move.l	#'DBUG',d0
	jsr	_OpenLibrary(a6)
	move.l	Env(a5),a1
	move.l	a0,ENV_Debugger(a1)
	ENDM


*****i* sosmacros.i/DEBJOB *************************************************
*
*   NAME
*	DEBJOB -- Rufe Debugger auf.
*
*   SYNOPSIS
*	DEBJOB  (MACRO)
*
*   FUNCTION
*	Rufe den Debugger auf. Dieser testet, ob seine Aktivierungsaktion
*	vollzogen wurde. Wenn nein, springt er gleich wieder zurück.
*	Der momentane (v2.0) Standartdebugger läßt sich mit 
*	Feuerknopf+Taste aufrufen. Feuerknopf+Help zeigt eine Hilfe an.
*
*   NOTES
*	Diese Routine darf nicht aus dem Interrupt aufgerufen werden.
*	Siehe debugger.doc und mod3.doc
*
*	Sie benötitgt einen Zeiger auf die SOSBase in a6 und 
*	einen auf den Variablenraum in a5
*
*   BUGS
*
****************************************************************************

DEBJOB	MACRO
	move.l	Env(a5),a4
	move.l	ENV_Debugger(a4),a4
	jsr	LIB_First(a4)
	ENDM





; ===================================================================
;
;  Helpfull macros for calling SOS-routines
;
; ===================================================================

******* sosmacros.i/SETINT *************************************************
*
*   NAME
*	SETINT -- Set Interrupt and Copper                         (v1.8)
*
*   SYNOPSIS
*	SETINT Copper,Irq,Enable   (MACRO)
*
*   FUNCTION
*	Switch from one environment containing Copperlist and
*	interrupts to another. Be shure that a copperinterrupt
*	is called with the accociated copperlist.
*
*	This routine will wait until the next frame to ensure 
*	smooth transitions.
*
*	If you want the debugger to work properly, you MUST use
*	this function to change the COP1LC-register. You may 
*	only access this register manually if you do some kind 
*	of copper-doublebuffering. If you change from one effect
*	to the other you MUST call SetInt.
*
*	If the debugger is called, it can not find out what
*	copperlist you have set by peeking the hardware. It uses
*	the SetDefault(), ClrDefault() mechanism to set it's own
*	Copperlist and restore the old one, and these function
*	rely totally on SetInt to find out your copperlist.
*	If you change the copperlist manually, you must remember that
*	after calling the debugger the copperlist you set with SetInt
*	will be restored. Please design your Copper-doublebuffering
*	carefully to handle these errors correct and ALLWAYS use
*	SetInt() when you change from one part to another.
*
*	This function is the most important function in SOS!
*
*   INPUTS
*	Enable   - Interrupt Enable, a comnbination of $0010, $0020 and
*	           $0040 for copper, vertical blanking and blitter
*	           interrupt. $0000 when no change of interrupts is
*	           desired.
*	Copper   - Pointer to Clist or 0 (use old one)
*	Irq      - Pointer to your IRQ code, unimportant if Enable=0.
*
*   NOTES
*	This routine may NOT be called from interrupt. Use 
*	SetIntFast() instead!.
*
*   BUGS
*
*   SEE ALSO
*	ClrInt(), SetDefault(), ClrDefault()
*
****************************************************************************

SETINT	MACRO
	lea	\1,a0
	lea	\2,a1
	moveq	#\3,d0
	jsr	_SetInt(a6)
	ENDM

******* sosmacros.i/SETCADR ************************************************
*
*   NAME
*	SETCADR -- Initialisiere Adresse(n) in einer Copperliste.    (v1.8)
*
*   SYNOPSIS
*	SETCADR Copper,Plane,Offset,Count
*
*   FUNCTION
*	Sets several bitplane- or spritepointer in a copperlist.
*
*   INPUTS
*	Copper   - Adresse of the first CMOVE-command.
*	Plane    - Value that is stored in the Copperlist
*	Offset   - Offset from one plane to another.
*	Count    - Number of adresses to write.
*	Register - Number of the first Register.
*
*   EXAMPLE (not tested)
*	Initialise an interleaved bitplane lores, 40 bytes, 5 planes.
*
*	         SETCADR  CopPln,#PlaneDat+64,40,5,$e0
*	         SETCCOL  CopCol,PlaneDat,0,32
*	         SETCSPR  CopSpr
*	              ...
*	         dc.w     $0108,40*4        ; set modulo
*	         dc.w     $010a,40*4
*	CopPln   dcb.l    10                ; BPLxPT's 
*	CopSpr   dcb.l    16                ; SPRxPT's
*	CopCol   dcb.l    32                ; COLORxx's
*	              ...
*	PlaneDat INCBIN   'picture.raw'     ; palette and planes
*
*   BUGS
*
*   SEE ALSO
*	SetCopCol()
*
****************************************************************************

SETCADR	MACRO
	move.l	\2,d0
	lea	\1,a0
	move.l	#\3,d1
	moveq	#\4,d2
	move.w	#\5,d3
	jsr	_SetCopperAdr(a6)
	ENDM

******* sosmacros.i/SETCSPR ************************************************
*
*   NAME
*	SETCSPR -- Reset spritepointer                    (v1.8)
*
*   SYNOPSIS
*	SETCSPR Sprites            (MACRO)
*
*   FUNCTION
*	This macro sets all 8 spritepointers to an adress that holds 
*	zero in a copperlist. You must provide a label called Zeros
*	that declares a longword 0 in chipmemory.
*
*   INPUTS
*	Sprites   - label to 64 free bytes in a copperlist
*
*   NOTES
*	This macro calls SetCopperAdr().
*
*   EXAMPLE
*	siehe SETCADR
*
*   BUGS
*
*   SEE ALSO
*	SetCopperAdr(), SetCopperCol()
*
****************************************************************************

SETCSPR	MACRO
	lea	\1,a0
	move.l	#Zeros,d0
	moveq	#0,d1
	moveq	#8,d2
	move.w	#$120,d3
	jsr	_SetCopperAdr(a6)
	ENDM

******* sosmacros.i/SETCCOL ************************************************
*
*   NAME
*	SETCCOL -- Initialisiere colors in copperlist.   (v1.8)
*
*   SYNOPSIS
*	SETCCOL Copper,Colors,Register,Count      (MACRO)
*
*   FUNCTION
*	Initialises some CMOVE-commands that could set up a 
*	color palette.
*
*   INPUTS
*	Copper   - Where to write the copperlist
*	Colors   - Pointer to palette
*	Register - First colorregister from 0 to 31 (!).
*	Count    - Number of colorregisters to set.
*
*   EXAMPLE
*	siehe SETCADR
*
*   BUGS
*
*   SEE ALSO
*	SetCopperCol()
*
****************************************************************************

SETCCOL	MACRO
	lea	\1,a0
	lea	\2,a1
	moveq	#\3,d0
	moveq	#\4,d1
	jsr	_SetCopperCol(a6)
	ENDM

******* sosmacros.i/GENSINUS ***********************************************
*
*   NAME
*	GenSinus -- Generate sinelist.      (MACRO)                 (v1.8)
*
*   SYNOPSIS
*	GenSinus Adresse,Format,Range,Size,Quaters
*
*   FUNCTION
*	Create a sinelist in memory. This is done by interpolating
*	a build in sine list of 256 Words length.
*
*	The accuracy is an error of 0.5 for a range from $7fff to -$8000.
*	This should be sufficiant for all your needs. Using the 
*	sinelist generator will save you some memory and is more
*	comfortable then working with extern sinelist generators.
*
*	The macro needs a variable called SINEBase relative to a5 that
*	holds the adress of a loaded SINE.soslibrary.
*
*   INPUTS
*	Adresse  - Pointer to free memory
*	Format   - SINE_WORD or SINE_BYTE
*	Range    - Half amplitude of the sinewave as potenz of 2
*	           See notes.
*	Size     - Number of elements for each sine quarter as potenz of 2
*	           See notes.
*	Quaters  - number of sine quarters (4 for full sinus, 5 for 
*	           combined sinus/cosinus table.
*
*   NOTES
*	Sizes are encoded like this.
*
*	Potenz   Elemtens per quarter       Minimum  Maximum
*	-----------------------------------------------------
*	2        4                          -3       3
*	4        16                         -15      15
*	8        256                        -255     255
*	9        512                        -511     511
*	10       1024                       -1023    1023 
*	11       2048                       -2047    2047 
*	12       4096                       -4095    4095 
*	13       8192                       -8191    8191 
*	14       16384                      -15383   15383
*	15       32768                      -32767   32767
*
*   BUGS
*
****************************************************************************

GENSINUS	MACRO
	move.l	a4,-(a7)
	move.l	SINEBase(a5),a4
	lea	.\@tags(pc),a0
	jsr	_GenSinusTags(a4)
	bra.s	.\@skip

.\@tags	STAGITEM	ST_ADRESS,\1
	STAGITEM	ST_FORMAT,\2
	STAGITEM	ST_RANGEPOT,\3
	STAGITEM	ST_SIZEPOT,\4
	STAGITEM	ST_QUARTERS,\5
	STAGITEM	ST_START,0\6
	STAGDONE

.\@skip	move.l	(a7)+,a4
	ENDM

******* sosmacros.i/CLRFAST ************************************************
*
*   NAME
*	CLRFAST -- Easy memory clearer.                        (v1.8)
*
*   SYNOPSIS
*	CLRFAST Adress,Size
*
*   FUNCTION
*	Clear memory in a fast to type and fast to execute way.
*	The memoryarea must meet the following conditions:
*	- Adress must be even
*	- Size must be a multiple of 4
*	- Size must not be larger then 256 KBytes
*	- Size must not be 0
*
*   INPUTS
*	Adresse  - Label of memory to clear.
*	Länge    - Size of memory to clear.
*
*   BUGS
*
****************************************************************************

CLRFAST	MACRO				; Lösche Speicher bis 256K
	lea	\1,a0
	move.w	#\2/4-1,d0
	moveq	#0,d1
.\@clr	move.l	d1,(a0)+
	dbf	d0,.\@clr
	ENDM

; ===================================================================
;
;  Sections
;
; ===================================================================

******* sosmacros.i/SEC-diverse- *******************************************
*
*   NAME
*	SECCODE   -- Start code section
*	SECBSS    -- Start BSS section
*	SECCODE_C -- Start code section Chipmem
*	SECBSS_C  -- Start BSS section Chipmem
*
*   SYNOPSIS
*	SECCODE
*	SECBSS
*	SECCODE_C
*	SECBSS_C
*
*   FUNCTION
*	These macros are simpler to type then the corresponding 
*	Section-commands. 
*
*	A special feature has been introduced. If you define the
*	CHIPMEM label, all sections will be forced to chipmemory. 
*	This allows you to check how slow your routine gets on 
*	a computer that has no fastmemory if your development 
*	computer has fast memory. You should allways spread the
*	version with CHIPMEM reset, just to be shure.
*
*   BUGS
*
****************************************************************************

SECCODE	MACRO
	IFD	CHIPMEM
	SECTION	'code',CODE_C	; Chipmem!
	ENDC
	IFND	CHIPMEM
	SECTION	'code',CODE
	ENDC
	ENDM

SECBSS	MACRO
	IFD	CHIPMEM
	SECTION	'bss',BSS_C	; Chipmem!
	ENDC
	IFND	CHIPMEM
	SECTION	'bss',BSS
	ENDC
	ENDM

SECCODE_C MACRO
	SECTION	'code_c',CODE_C
	ENDM

SECBSS_C	MACRO
	SECTION	'bss_c',BSS_C
	ENDM


******* sosmacros.i/OPENLIB *************************************************
*
*   NAME
*	OPENLIB -- Load library
*
*   SYNOPSIS
*	LibBase=OPENLIB NAME   (MACRO)
*	a0
*
*   FUNCTION
*	Load a library and return a pointer to it. This function also
*	sets a label relative to a5 called NAMEBase that can be used
*	for further Library calls.
*
*	Remember that most extern library want thier library pointer in a4!
*	Remember that all libraries are deletet from memory with
*	ClrDefault(), ClrInt().
*
*   INPUTS
*	'NAME'   - 4 letter ASCII literal of the library name
*
*   RESULT
*	LibBase  - Pointer to library.
*
*   BUGS
*
*   SEE ALSO
*	ClrInt(), SetDefault(), ClrDefault()
*
****************************************************************************

OPENLIB	MACRO
	move.l	#'\1',d0
	jsr	_OpenLibrary(a6)
	move.l	d0,a0
	move.l	a0,\1Base(a5)
	ENDM
