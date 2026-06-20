
		   machine   68020               ;Will only run with 68020+.


;;; "The Player Defines                             ;Type of player,"
opt020 = 1         ;0 = The Player will use MC680x0 code
		   ;1 = MC68020+ or better

start = 0       ;Starting position

fade  = 1       ;0 = Normal, NO master volume control possible
		;1 = Use master volume (P61_Master)

jump = 1        ;0 = do NOT include position jump code (P61_SetPosition)
		;1 = Include

system = 0      ;0 = killer
		;1 = friendly

CIA = 1         ;0 = CIA disabled
		;1 = CIA enabled

exec = 1        ;0 = ExecBase destroyed
		;1 = ExecBase valid

lev6 = 1        ;0 = NonLev6
		;1 = Lev6 used

channels = 4    ;amount of channels to be played

use = $4040945D   ;The Usecode
;;;
						 ;startposition, usecode,
						 ;020 etc.
;;; "Includes                                       ;Needed to make things"

		   Incdir    "!Includes:"
		   Include   "StdLibInc.i"       ;LVOs, ExecBase define.
		   Include   "StdHardInc.i"      ;Registers, Custom define.

		   Incdir    "!Includes:OS3.0/"
		   Include   "exec/memory.i"
		   Include   "exec/ExecBase.i"
		   Include   "graphics/GfxBase.i"
		   Include   "dos/dosextens.i"
		   Include   "devices/input.i"
		   Include   "devices/inputevent.i"
		   Include   "intuition/screens.i"
		   Include   "graphics/videocontrol.i"

		   Incdir    "work:coding/player6.1A/source/Include/"
		   Include   "Player61.i"
;;;
						 ;more readable!
;;; "Exported variables                             ;Variables you use"
		   IFD       noexample
		   xdef      _Startup
		   xdef      _Closedown
		   xdef      _InitDemo
		   xdef      _UninitDemo
		   xdef      _PlayMusic
		   xdef      _StopMusic

		   xdef      _GfxBase
		   xdef      _DosBase
		   xdef      _IntBase
		   xdef      SpriteDummy

		   xdef      P61_Master
		   xdef      P61_Play
		   xdef      P61_Pos
		   xdef      P61_Patt
		   xdef      P61_CRow
		   xdef      P61_E8
		   xdef      P61_VBR

		   xdef      _FastMem
		   xdef      _CPU
		   xdef      _VBR

		   ;SYSOP VARS! - DON'T USE!
		   ;------------------------

		   xdef      OldInt
		   xdef      OldDMA
		   xdef      OldLev3

		   xdef      SyncBit

		   ENDC
;;;
						 ;in your program when
						 ;linked with this program.
						 ;I.e. To get _GfxBase,
						 ;synchronizing with music,
						 ;init demo, fade colours,
						 ;set pointers, play music.
;;; "Loader Defines"
HANDLER_PRI        Equ       127
;;;

		   xref      _Sync

		   Section   code,CODE

		   IFND      noexample
StartOfProgg:
;;; "                 Init"
		   Bsr       _Startup            ;Iconstartup

		   Bsr       _InitDemo
		   Tst.l     d0
		   Bne       Exit
;;;
;;; "                 Play Music"
		   Bsr       _PlayMusic
		   Tst.l     d0
		   Bne       CloseDown
;;;

Loop:              Move.w    #$0000,$dff180
		   Move.w    #$0f00,$dff180
		   Btst      #6,$bfe001
		   Bne       Loop

;;; "                 Stop Music"
		   Bsr       _StopMusic
;;;
;;; "                 Uninit"
CloseDown:         Bsr       _UninitDemo
		   Bsr       _Closedown          ;Iconstartup
;;;

Exit:              Moveq     #0,d0
		   Rts
		   ENDC

		   IFD       kulig
;;; "Install Input Handler"
		; Create main program port
InstallIH:
		Move.l  (_ExecBase).w,a6
		Moveq.l #0,d0                   ; Get port pri
		Lea     nameString(pc),a0       ; Get port name
		bsr     init_crport             ; Create new port
		tst.l   d0                      ; Succeeded?
		beq     ina_err                 ; Skip if not
		Lea     base(pc),a4
		Move.l  d0,mainPort-base(a4)    ; Store port address in memory

		; Create io request
		Move.l  mainPort-base(a4),a0    ; Get port ptr
		move.l  #IOSTD_SIZE,d0          ; Get request size
		bsr     init_crextio            ; Create extio
		tst.l   d0                      ; Succeeded?
		beq     ina_err                 ; Skip if not
		Lea     base(pc),a4
		Move.l  d0,extIO-base(a4)       ; Store ptr in memory

		; Open input.device
		Move.l  (_ExecBase).w,a6        ; Get system base
		Lea     inputName-base(a4),a0   ; Get device name
		move.l  d0,a1                   ; Get extio address
		moveq.l #0,d0                   ; Unit number 0
		move.l  d0,d1                   ; No special flags
		Jsr     _LVOOpenDevice(a6)      ; Open device
		tst.l   d0                      ; Succeeded?
		bne     ina_err                 ; Skip if not
		Move.w  #-1,inputOpen-base(a4)  ; Set input.device open flag

		; Install input handler
		Lea     inputHandler(pc),a0     ; Get input handler info addr
		Lea     ihandler(pc),a2
		Move.l  a2,IS_CODE(a0)          ; Store ptr to routine
		move.l  #0,IS_DATA(a0)          ; No special data ptr
		move.b  #HANDLER_PRI,LN_PRI(a0) ; High priority handler
		Lea     nameString(pc),a2
		Move.l  a2,LN_NAME(a0)          ; Store name of program
		Move.l  extIO-base(a4),a1       ; Get addr of io request
		move.l  a0,IO_DATA(a1)          ; Store handler ptr
		move.w  #IND_ADDHANDLER,IO_COMMAND(a1)  ; Command: add input handler
		Jsr     _LVODoIO(a6)            ; Add handler
		Move.w  #-1,handlerInst-base(a4)        ; Set handler installed flag

		Moveq   #0,d0
		Rts

ina_err:        Bsr     RemoveIH

		Moveq   #1,d0
		Rts
;;;
;;; "Remove Input Handler"
RemoveIH:       Move.l  (_ExecBase).w,a6
		Lea     base(pc),a4
rsa_noint:      Tst.w   handlerInst-base(a4)    ; Handler installed?
		beq     rsa_nohandler           ; Skip if not
		Move.l  extIO-base(a4),a1       ; Get address of io request
		Lea     inputHandler(pc),a2
		Move.l  a2,IO_DATA(a1)          ; Get address of handler info
		move.w  #IND_REMHANDLER,IO_COMMAND(a1)  ; Command for removing handler
		Jsr     _LVODoIO(a6)            ; Remove handler
		
rsa_nohandler:  Tst.w   inputOpen-base(a4)      ; Input device opened?
		beq     rsa_noinput             ; Skip if not
		Move.l  extIO-base(a4),a1       ; Get io request for input.device
		Jsr     _LVOCloseDevice(a6)     ; Close device

rsa_noinput:    Tst.l   extIO-base(a4)          ; Extended io request allocated?
		beq     cla_noreq               ; Skip if not
		Move.l  extIO-base(a4),a0       ; Get extio pointer
		move.l  #IOSTD_SIZE,d0          ; Get req size
		bsr     init_delextio           ; Free struct

cla_noreq:
		Lea     base(pc),a4
		Tst.l   mainPort-base(a4)       ; Port created?
		beq     cla_noport              ; Skip if not
		Move.l  mainPort-base(a4),a0    ; Get port address
		bsr     init_delport            ; Remove it

cla_noport:     Rts
;;;
;;; "  init_crport"
; Create message port and add to system
; d0: Priority
; a0: Ptr to name string
; Returns: Ptr to port or zero if failure
init_crport:    movem.l d2-d3,-(a7)
		move.l  (_ExecBase).w,a6

		; Allocate port signal
		movem.l d0/a0,-(a7)
		moveq.l #-1,d0                  ; Allocate whatever signal
		Jsr     _LVOAllocSignal(a6)     ; Call routine
		move.l  d0,d2
		movem.l (a7)+,d0/a0
		cmp.w   #-1,d2                  ; Allocation successful?
		beq     crp_error0              ; Skip if not

		; Allocate port memory
		movem.l d0/a0,-(a7)
		moveq.l #MP_SIZE,d0
		move.l  #MEMF_CLEAR!MEMF_PUBLIC,d1      ; Clear memory
		Jsr     _LVOAllocMem(a6)        ; Allocate
		move.l  d0,d3
		movem.l (a7)+,d0/a0
		tst.l   d3                      ; Allocation successful?
		beq     crp_error1              ; Skip if not
		move.l  d3,a1

		; Initialize port members
		move.l  a0,LN_NAME(a1)
		move.b  d0,LN_PRI(a1)
		move.b  #NT_MSGPORT,LN_TYPE(a1)
		move.b  #PA_SIGNAL,MP_FLAGS(a1)
		move.b  d2,MP_SIGBIT(a1)
		move.l  a1,-(a7)
		moveq.l #0,d0
		move.l  d0,a1                   ; Zero ptr for own task struct
		Jsr     _LVOFindTask(a6)        ; Get address of current task
		move.l  (a7)+,a1
		move.l  d0,MP_SIGTASK(a1)       ; Store in port

		; Add port to system list
		move.l  a1,-(a7)
		Jsr     _LVOAddPort(a6)
		move.l  (a7)+,a1
		move.l  a1,d0                   ; Get port address
		movem.l (a7)+,d2-d3
		rts

crp_error1:     move.l  d2,d0
		Jsr     _LVOFreeSignal(a6)      ; Free allocated signal
crp_error0:     moveq.l #0,d0                   ; Return error
		movem.l (a7)+,d2-d3
		rts
;;;
;;; "  init_delport"
; Delete message port
; a0: Ptr to message port
init_delport:   move.l  d2,-(a7)
		move.l  (_ExecBase).w,a6

		; Remove port from system list
		move.l  a0,d2                   ; d2 used as temporary storage
		move.l  a0,a1
		Jsr     _LVORemPort(a6)

		; Free port signal
		move.l  d2,a0
		moveq.l #0,d0
		move.b  MP_SIGBIT(a0),d0
		Jsr     _LVOFreeSignal(a6)

		; Free port memory
		move.l  d2,a1
		moveq.l #MP_SIZE,d0
		Jsr     _LVOFreeMem(a6)
		move.l  (a7)+,d2
		rts
;;;
;;; "  init_crextio"
; Create extended io request
; a0: Ptr to reply port for this request
; d0: Size of request struct
; Returns: Ptr to extio struct or zero if failure
init_crextio:   move.l  a2,-(a7)
		move.l  a0,d1                   ; Port present?
		beq     cre_error0              ; Skip if not
		move.l  a0,a2                   ; Store port ptr for later use
		move.l  (_ExecBase).w,a6
		move.l  #MEMF_CLEAR!MEMF_PUBLIC,d1      ; Clear memory
		Jsr     _LVOAllocMem(a6)        ; Allocate extio memory
		tst.l   d0                      ; Succeeded?
		beq     cre_error0              ; Skip if not
		move.l  d0,a0
		move.b  #NT_MESSAGE,LN_TYPE(a0) ; Set node type to message
		move.l  a2,MN_REPLYPORT(a0)     ; Set reply port address
		bra     cre_exit

cre_error0:     moveq.l #0,d0                   ; Return failure
cre_exit:       move.l  (a7)+,a2
		rts
;;;
;;; "  init_delextio"
; Delete extended io request
; a0: Ptr to io request
; d0: Size of request struct
init_delextio:  move.b  #$ff,LN_TYPE(a0)        ; Invalid type number
		move.l  #-1,IO_DEVICE(a0)       ; Invalid device ptr
		move.l  #-1,IO_UNIT(a0)         ; Invalid unit ptr
		move.l  (_ExecBase).w,a6
		move.l  a0,a1                   ; Get extio addr
		Jsr     _LVOFreeMem(a6)         ; Free memory
		rts
;;;
;;; "  ihandler"
; Delink keyboard and mouse events so Intuition won't hear of them
ihandler:       movem.l a0-a2,-(a7)
ih_headloop:    move.b  ie_Class(a0),d0         ; Get event class
		cmp.b   #IECLASS_RAWKEY,d0      ; Is it keypress?
		beq     ih_hrawkey              ; Delink if true
		cmp.b   #IECLASS_RAWMOUSE,d0    ; Is it mouse event?
		beq     ih_hrawmouse            ; Handle if true
		cmp.b   #IECLASS_POINTERPOS,d0  ; Is it mouse event?
		beq     ih_hdlink               ; Delink if true
		cmp.b   #IECLASS_NEWPOINTERPOS,d0       ; Is it mouse event?
		beq     ih_hdlink               ; Delink if true
		bra     ih_nothead              ; Skip to tail processing part
ih_hdlink:      move.l  ie_NextEvent(a0),d0     ; Get address of next event
		move.l  d0,a0                   ; Any more events left?
		bne     ih_headloop             ; Loop if true
		moveq.l #0,d0                   ; All events removed
		movem.l (a7)+,a0-a2
		rts                             ; End routine

		; Handle rawkey events at the head of the chain
ih_hrawkey:     move.l  a0,a2                   ; Move to correct register
		bsr     ih_dorawkey             ; Handle event
		bra     ih_hdlink               ; Delink event

		; Handle rawmouse events at the head of the chain
ih_hrawmouse:   move.l  a0,a2                   ; Move to correct register
		bsr     ih_dorawmouse           ; Handle event
		bra     ih_hdlink               ; Delink event

ih_nothead:     move.l  a0,a1                   ; Store ptr to previous event
		move.l  a0,a2                   ; Store ptr to current event
ih_midloop:     move.l  ie_NextEvent(a2),d0     ; Get address of next event
		move.l  d0,a2                   ; More events to process?
		beq     ih_end                  ; Skip if not
		move.b  ie_Class(a2),d0         ; Get event class
		cmp.b   #IECLASS_RAWKEY,d0      ; Is it keypress?
		beq     ih_mrawkey              ; Delink if true
		cmp.b   #IECLASS_RAWMOUSE,d0    ; Is it mouse event?
		beq     ih_mrawmouse            ; Delink if true
		cmp.b   #IECLASS_POINTERPOS,d0  ; Is it mouse event?
		beq     ih_mdlink               ; Delink if true
		cmp.b   #IECLASS_NEWPOINTERPOS,d0       ; Is it mouse event?
		beq     ih_mdlink               ; Delink if true
		move.l  a2,a1                   ; Store current as previous
		bra     ih_midloop
ih_mdlink:      move.l  ie_NextEvent(a2),ie_NextEvent(a1)       ; Delink event
		bra     ih_midloop

ih_end:         move.l  a0,d0                   ; Store start of chain in return reg
		movem.l (a7)+,a0-a2
		rts                             ; End routine

		; Handle rawkey events at the tail of the chain
ih_mrawkey:     bsr     ih_dorawkey             ; Handle event
		bra     ih_mdlink               ; Delink event

		; Handle rawmouse events at the tail of the chain
ih_mrawmouse:   bsr     ih_dorawmouse           ; Handle event
		bra     ih_mdlink               ; Delink event

; -------------------------------------------------------

; Handles rawmouse events
ih_dorawmouse:  move.w  ie_Code(a2),d0
		cmp.w   #IECODE_LBUTTON,d0      ; Test for left button down
		bne     ihrm_nolbdown           ; Skip if not true
		Lea     base(pc),a4
		Move.w  #-1,lbutton-base(a4)    ; Set left button flag
		bra     ihrm_end

ihrm_nolbdown:  cmp.w   #IECODE_LBUTTON!IECODE_UP_PREFIX,d0     ; Left button up
		bne     ihrm_nolbup             ; Skip if not true
		Lea     base(pc),a4
		Move.w  #0,lbutton-base(a4)     ; Clear left button flag
		bra     ihrm_end

ihrm_nolbup:    cmp.w   #IECODE_RBUTTON,d0      ; Test for right button down
		bne     ihrm_norbdown           ; Skip if not true
		Lea     base(pc),a4
		Move.w  #-1,rbutton-base(a4)    ; Set right button flag
		bra     ihrm_end

ihrm_norbdown:  cmp.w   #IECODE_RBUTTON!IECODE_UP_PREFIX,d0     ; Right button up
		bne     ihrm_norbup             ; Skip if not true
		Lea     base(pc),a4
		Move.w  #0,rbutton-base(a4)     ; Clear left button flag
		bra     ihrm_end

ihrm_norbup:    cmp.w   #IECODE_MBUTTON,d0      ; Test for middle button down
		bne     ihrm_nombdown           ; Skip if not true
		Lea     base(pc),a4
		Move.w  #-1,mbutton-base(a4)    ; Set middle button flag
		bra     ihrm_end

ihrm_nombdown:  cmp.w   #IECODE_MBUTTON!IECODE_UP_PREFIX,d0     ; Middle button up
		bne     ihrm_end                ; Skip if not true
		move.w  #0,mbutton              ; Clear left button flag
ihrm_end:       rts

; -------------------------------------------------------

ih_dorawkey:    move.w  ie_Code(a2),d0          ; Get keycode
		and.w   #IECODE_UP_PREFIX,d0    ; Key released?
		Lea     base(pc),a4
		Bne     ihrk_nokey              ; Skip if true
		Move.w  ie_Code(a2),lastkey-base(a4)       ; Store keycode in memory
		Move.w  ie_Qualifier(a2),lastqual-base(a4) ; Store qualifier
		bra     ihrk_end
ihrk_nokey:     Move.w  #0,lastkey-base(a4)     ; Store no key pressed
		Move.w  #0,lastqual-base(a4)
ihrk_end:       Rts
;;;
;;; "  ihandler data"
lbutton:        Dc.w    0
mbutton:        dc.w    0
rbutton:        dc.w    0               ; State of mouse buttons
mousex:         dc.w    0
mousey:         dc.w    0               ; Mouse position
lastkey:        dc.w    0               ; Last rawkey code
lastqual:       dc.w    0               ; Last rawkey qualifier

mainPort:       Dc.l    0
extIO:          dc.l    0                       ; Extended io request address
inputOpen:      dc.w    0                       ; Input.device open flag
handlerInst:    dc.w    0
inputHandler:   ds.b    IS_SIZE                 ; Input event handler info
nameString:     Dc.b    "PowerLกne",0
inputName:      Dc.b    "input.device",0
		even
;;;
		   ENDC

;;; "FixSprites"

; This bit fixes problems with sprites in V39 kickstart
; it is only called if intuition.library opens, which in this
; case is only if V39 or higher kickstart is installed. If you
; require intuition.library you will need to change the
; openlibrary code to open V33+ Intuition and add a V39 test before
; calling this code (which is only required for V39+ Kickstart)

FixSprites:
	Lea      base(pc),a4

	Move.l   _IntBase-base(a4),a6       ; open intuition.library first!
	Lea      wbname(pc),a0
	jsr      _LVOLockPubScreen(a6)

	tst.l    d0                         ; Could I lock Workbench?
	beq.s    .error                     ; if not, error
	Move.l   d0,wbscreen-base(a4)
	move.l   d0,a0

	move.l   sc_ViewPort+vp_ColorMap(a0),a0
	Lea      taglist(pc),a1
	Move.l   _GfxBase-base(a4),a6       ; open graphics.library first!
	jsr      _LVOVideoControl(a6)       ;

	Move.l   resolution-base(a4),oldres-base(a4)    ; store old resolution

	Move.l   #SPRITERESN_140NS,resolution-base(a4)
	Move.l   #VTAG_SPRITERESN_SET,taglist-base(a4)

	Move.l   wbscreen-base(a4),a0
	move.l   sc_ViewPort+vp_ColorMap(a0),a0
	Lea      taglist(pc),a1
	jsr      _LVOVideoControl(a6)       ; set sprites to lores

	Move.l   wbscreen-base(a4),a0
	Move.l   _IntBase-base(a4),a6
	jsr      _LVOMakeScreen(a6)
	jsr      _LVORethinkDisplay(a6)     ; and rebuild system copperlists

; Sprites are now set back to 140ns in a system friendly manner!

.error
	rts
;;;
;;; "ReturnSprites"
ReturnSprites:
; If you mess with sprite resolution you must return resolution
; back to workbench standard on return! This code will do that...

	Lea      base(pc),a4

	Move.l   wbscreen-base(a4),d0
	beq.s    .error
	move.l   d0,a0

	Move.l   oldres-base(a4),resolution-base(a4)          ; change taglist
	Lea      taglist-base(a4),a1
	move.l   sc_ViewPort+vp_ColorMap(a0),a0
	Move.l   _GfxBase-base(a4),a6
	jsr      _LVOVideoControl(a6)       ; return sprites to normal.

	Move.l   _IntBase-base(a4),a6
	Move.l   wbscreen-base(a4),a0
	jsr      _LVOMakeScreen(a6)         ; and rebuild screen
	jsr      _LVORethinkDisplay(a6)     ; and rebuild system copperlists

	Move.l   wbscreen-base(a4),a1
	sub.l    a0,a0
	jsr      _LVOUnlockPubScreen(a6)

.error
	rts

wbview          dc.l  0
oldres          dc.l  0
wbscreen        dc.l  0

taglist         dc.l  VTAG_SPRITERESN_GET
resolution      dc.l  SPRITERESN_ECS
		dc.l  TAG_DONE,0

wbname          dc.b  "Workbench",0
;;;

;;; "Startup"
_Startup:          Sub.l     a1,a1
		   Move.l    (_ExecBase).w,a6
		   Jsr       _LVOFindTask(a6)
		   Move.l    d0,a4

		   Tst.l     pr_CLI(a4)           ; was it called from CLI?
		   Bne.s     .skip                ; if so, skip this bit...

		   Lea       pr_MsgPort(a4),a0
		   Move.l    (_ExecBase).w,a6
		   Jsr       _LVOWaitPort(a6)
		   Lea       pr_MsgPort(a4),a0
		   Jsr       _LVOGetMsg(a6)


		   Lea      base(pc),a4
		   Move.l    d0,returnMsg-base(a4)

.skip              Rts

returnMsg:         Dc.l      0

;;;
;;; "Closedown"
_Closedown:        Lea     base(pc),a4
		   Tst.l   returnMsg-base(a4)      ; Is there a message?
		   Beq.s   .skip                   ; if not, skip...

		   Move.l  (_ExecBase).w,a6
		   Jsr     _LVOForbid(a6)          ; note! No Permit needed!

		   Move.l  returnMsg(pc),a1
		   Jsr     _LVOReplyMsg(a6)

.skip              Rts
;;;

;;; "Initdemo"
_InitDemo:         Movem.l   d1-d7/a0-a6,-(a7)
		   Bsr       CPUTest
		   Cmp.w     #20,d0
		   Blt       .BadCPU

		   Bsr       CheckRev
		   Cmp.w     #39,d0              ;Lower than 39?
		   Blt       .LowRevision        ;Then branch!

		   Bsr       OpenLibs            ;Else OpenLibs.

		   Bsr       AGATest
		   Tst.l     d0
		   Beq       .BadChipset

		   ;Bsr       CheckFastMem

		   ;Bsr       InstallIH
		   ;Tst.l     d0
		   ;Bne       .NoHandler

		   Bsr       FixSprites

		   Bsr       GetVBR
		   Bsr       BoostCaches

		   Bsr       KillSystem
		   Bsr       SaveView

		   Move.l    _VBR,a0
		   Move.l    $6c(a0),OldLev3
		   Move.l    #DummyLev3,$6c(a0)

		   Movem.l   (a7)+,d1-d7/a0-a6
		   Moveq     #0,d0
		   Rts

.BadCPU            Movem.l   (a7)+,d1-d7/a0-a6
		   Moveq     #1,d0
		   Rts

.LowRevision       Movem.l   (a7)+,d1-d7/a0-a6
		   Moveq     #1,d0
		   Rts

.BadChipset        Bsr       CloseLibs
		   Movem.l   (a7)+,d1-d7/a0-a6
		   Moveq     #1,d0
		   Rts

.NoHandler         Bsr       CloseLibs
		   Movem.l   (a7)+,d1-d7/a0-a6
		   Moveq     #1,d0
		   Rts

;;;
;;; "UninitDemo"
_UninitDemo:       Movem.l   d0-d7/a0-a6,-(a7)
		   Move.l    _VBR,a0
		   Move.l    OldLev3,$6c(a0)

		   Bsr       ReturnSprites
		   Bsr       RestoreView

		   Bsr       FreeSystem

		   Bsr       RestoreCaches

		   ;Move.l    _DosBase,a6
		   ;Move.l    #50,d1
		   ;Jsr       _LVODelay(a6)       ;Wait for inputhandler
						 ;to do its work!

		   ;Bsr       RemoveIH

		   Bsr       CloseLibs           ;Close Down libraries.
		   Movem.l   (a7)+,d0-d7/a0-a6
		   Rts
;;;

;;; "PlayMusic"
_PlayMusic:        Movem.l   d1-d7/a0-a6,-(a7)

		   Bsr       _Sync
		   Move.w    #$0020,$dff09a


		   Lea       P61_data,a0     ;Module
		   Sub.l     a1,a1           ;No separate samples
		   Lea       samples,a2      ;Sample buffer

		   Moveq     #0,d0           ;Auto Detect
		   Bsr       P61_Init

		   Move.w    #$8020,$dff09a

		   Movem.l   (a7)+,d1-d7/a0-a6
		   Rts
;;;
;;; "StopMusic"
_StopMusic:        Movem.l   d0-d7/a0-a6,-(a7)

		   Lea       Custom,a6
		   Bsr       P61_End

		   Movem.l   (a7)+,d0-d7/a0-a6
		   Rts
;;;

		   IFD       kulig
;;; "CheckFastMem"
**************************************************************
* Tests if Fastmem is available. Result stored in _Fastmem.  *
*                                                            *
* IN:              VOID                                      *
* OUT:             d0 - Result:                              *
*                       0 = No fastmem                       *
*                       1 = Fastmem                          *
**************************************************************

CheckFastMem:      Move.l    _ExecBase,a6
		   Lea       base(pc),a4
		   Move.l    #MEMF_FAST,d1
		   Jsr       _LVOAvailMem(a6)
		   Tst.l     d0
		   Beq       .nofast

		   Moveq     #1,d0
		   Move.w    d0,_FastMem-base(a4)
		   Rts

.nofast            Moveq     #0,d0
		   Move.w    d0,_FastMem-base(a4)
		   Rts

;;;
		   ENDC

;;; "CPUTest"
**************************************************************
* Checks which CPU is fitted. Result stored in _CPU.         *
*                                                            *
* IN:              VOID                                      *
* OUT:             d0 - Type of CPU:                         *
*                       0 = 68000                            *
*                       10 = 68010                           *
*                       20 = 68020                           *
*                       30 = 68030                           *
*                       40 = 68040                           *
**************************************************************

CPUTest:           Move.l    _ExecBase,a6
		   Lea       base(pc),a4
		   Move.w    AttnFlags(a6),d0
		   Btst      #AFB_68040,d0
		   Bne       .CPU040
		   Btst      #AFB_68030,d0
		   Bne       .CPU030
		   Btst      #AFB_68020,d0
		   Bne       .CPU020
		   Btst      #AFB_68010,d0
		   Bne       .CPU010

.CPU000:           Moveq     #0,d0
		   Move.w    d0,_CPU-base(a4)
		   Rts

.CPU010:           Moveq     #10,d0
		   Move.w    d0,_CPU-base(a4)
		   Rts

.CPU020:           Moveq     #20,d0
		   Move.w    d0,_CPU-base(a4)
		   Rts

.CPU030:           Moveq     #30,d0
		   Move.w    d0,_CPU-base(a4)
		   Rts

.CPU040:           Moveq     #40,d0
		   Move.w    d0,_CPU-base(a4)
		   Rts

;;;
;;; "AGATest"
**************************************************************
* Checks if machine is equipped with AGA-circuits. Needs     *
* _GfxBase.                                                  *
*                                                            *
* IN:              VOID                                      *
* OUT              d0 - Result:                              *
*                       0 = No AGA                           *
*                       1 = AGA                              *
**************************************************************

AGATest:
		   Lea       base(pc),a4
		   Move.l    _GfxBase-base(a4),a6
		   Move.b    gb_ChipRevBits0(a6),d0
		   And.b     #GFXF_AA_ALICE!GFXF_AA_LISA,d0
		   Cmp.b     #GFXF_AA_ALICE!GFXF_AA_LISA,d0
		   Bne       .NoAGA

		   Moveq     #1,d0
		   Move.w    d0,_AGA
		   Rts

.NoAGA:            Moveq     #0,d0
		   Move.w    d0,_AGA
		   Rts

;;;
;;; "CheckRev"
**************************************************************
* Checks your OS revision.                                   *
*                                                            *
* IN:              VOID                                      *
* OUT:             d0 - Revision                             *
**************************************************************

CheckRev:          Move.l    _ExecBase,a6         ;Get Exec structure.
		   Move.w    LIB_VERSION(a6),d0  ;Get OS-Revision.
		   Lea       base(pc),a4
		   Move.w    d0,_OS-base(a4)

		   Rts
;;;

;;; "OpenLibs"
**************************************************************
* Opens graphics, dos and intuition.library.                 *
* Does NOT test if succed. (Requires that you have tested    *
* (LIB_VERSION=>39) before calling this routine.             *
*                                                            *
* IN:              VOID                                      *
* OUT:             VOID                                      *
**************************************************************

OpenLibs:          Move.l    _ExecBase,a6         ;Get Exec structure.
		   Lea       base(pc),a4

		   Lea       Dosname(pc),a1          ;Point at string.
		   Move.l    #39,d0              ;Lowest version.
		   Jsr       _LVOOpenLibrary(a6) ;Open dos.library.
		   Move.l    d0,_DosBase-base(a4)         ;Save basepointer.

		   Lea       Gfxname(pc),a1          ;Point at string.
		   Move.l    #39,d0              ;Lowest version.
		   Jsr       _LVOOpenLibrary(a6) ;Open graphics.library.
		   Move.l    d0,_GfxBase-base(a4)         ;Save basepointer.

		   Lea       Intname(pc),a1          ;Point at string.
		   Move.l    #39,d0              ;Lowest version.
		   Jsr       _LVOOpenLibrary(a6) ;Open intuition.library.
		   Move.l    d0,_IntBase-base(a4)         ;Save basepointer.

		   Rts
;;;
;;; "CloseLibs"
**************************************************************
* Closes the 3 librarys, previously opened by 'OpenLibs'     *
*                                                            *
* IN:              VOID                                      *
* OUT:             VOID                                      *
**************************************************************

CloseLibs:         Move.l    _ExecBase,a6
		   Lea       base(pc),a4

		   Move.l    _DosBase-base(a4),a1
		   Jsr       _LVOCloseLibrary(a6)

		   Move.l    _GfxBase-base(a4),a1
		   Jsr       _LVOCloseLibrary(a6)

		   Move.l    _IntBase-base(a4),a1
		   Jsr       _LVOCloseLibrary(a6)

		   Rts
;;;

;;; "SaveView (And DMA)"
**************************************************************
* Saves old view and inits a new one. Needs _GfxBase.        *
*                                                            *
* IN:              VOID                                      *
* OUT:             VOID                                      *
**************************************************************

SaveView:
		   Lea       base(pc),a4
		   Move.l    _GfxBase-base(a4),a6
		   Lea       Custom,a5

		   Move.l    gb_ActiView(a6),OldView-base(a4)
		   Move.l    gb_copinit(a6),OldCop-base(a4)

		   Move.w    dmaconr(a5),OldDMA-base(a4)
		   Move.w    #(DMAF_SPRITE!DMAF_COPPER!DMAF_RASTER),dmacon(a5)

		   Sub.l     a1,a1
		   Jsr       _LVOLoadView(a6)
		   Jsr       _LVOWaitTOF(a6)
		   Jsr       _LVOWaitTOF(a6)

		   Lea       DummyCopper,a0
		   Move.l    a0,cop1lc(a5)
		   Move.w    #0,copjmp1(a5)

		   Move.w    #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),dmacon(a5)

		   Rts
;;;
;;; "RestoreView (And DMA)"
**************************************************************
* Restores old view. Needs _GfxBase.                         *
*                                                            *
* IN:              VOID                                      *
* OUT:             VOID                                      *
**************************************************************

RestoreView:       Lea       base(pc),a4
		   Lea       Custom,a5
		   Move.l    _GfxBase-base(a4),a6

		   Move.w    #(DMAF_SPRITE!DMAF_COPPER!DMAF_RASTER),dmacon(a5)

		   Move.l    OldView-base(a4),a1
		   Jsr       _LVOLoadView(a6)
		   Jsr       _LVOWaitTOF(a6)
		   Jsr       _LVOWaitTOF(a6)

		   Move.l    OldCop-base(a4),cop1lc(a5)
		   Move.w    #0,copjmp1(a5)

		   Move.w    OldDMA-base(a4),d0
		   Bset      #15,d0
		   Move.w    d0,dmacon(a5)

		   Rts
;;;

;;; "KillSystem"
KillSystem:        Lea       Custom,a5
		   Move.l    _ExecBase,a6
		   Lea       base(pc),a4

		   Sub.l     a1,a1
		   Jsr       _LVOFindTask(a6)
		   Move.l    d0,a1
		   Moveq     #127,d0
		   Jsr       _LVOSetTaskPri(a6)
		   Move.b    d0,OldPri-base(a4)

		   Jsr       _LVOForbid(a6)              ;Forbid MT

		   Lea       Custom,a5                   ;Disable Interrupts
		   Move.w    intenar(a5),OldInt-base(a4)
		   ;Move.w    #$7fff,intena(a5)
		   ;Jsr       _LVODisable(a6)
		   ;Move.w    #$ffff,intreq(a5)

		   Move.l    _GfxBase-base(a4),a6
		   Jsr       _LVOWaitBlit(a6)
		   Jsr       _LVOOwnBlitter(a6)

		   Rts
;;;
;;; "FreeSystem"
FreeSystem:        Lea       Custom,a5
		   Lea       base(pc),a4

		   Move.l    _GfxBase-base(a4),a6
		   Jsr       _LVOWaitBlit(a6)
		   Jsr       _LVODisownBlitter(a6)

		   Move.w    OldInt-base(a4),d7
		   Bset      #15,d7
		   Move.w    #$7fff,intena(a5)
		   Move.w    d7,intena(a5)

		   Move.l    _ExecBase,a6
		   ;Jsr       _LVOEnable(a6)

		   Jsr       _LVOPermit(a6)

		   Sub.l     a1,a1
		   Jsr       _LVOFindTask(a6)
		   Move.l    d0,a1
		   Move.b    OldPri-base(a4),d0
		   Ext.w     d0
		   Ext.l     d0
		   Jsr       _LVOSetTaskPri(a6)

		   Rts
;;;

;;; "BoostCaches"
BoostCaches:
		   Move.l    _ExecBase,a6
		   Move.l    #CACRF_EnableI!CACRF_IBE!CACRF_EnableD!CACRF_DBE,d0
		   Move.l    #CACRF_EnableI!CACRF_IBE!CACRF_EnableD!CACRF_DBE,d1
		   Jsr       _LVOCacheControl(a6)
		   Lea       base(pc),a4
		   Move.l    d0,OldCache-base(a4)

		   Rts
;;;
;;; "RestoreCaches"
RestoreCaches:
		   Move.l    _ExecBase,a6
		   Lea       base(pc),a4
		   Move.l    OldCache-base(a4),d0
		   Move.l    #$ffffffff,d1
		   Jsr       _LVOCacheControl(a6)

		   Rts
;;;

;;; "GetVBR"
GetVBR:            Move.l    _ExecBase,a6
		   Lea       get_VBR(pc),a5
		   Jsr       _LVOSupervisor(a6)
		   Lea       base(pc),a4
		   Move.l    a0,_VBR-base(a4)
		   Rts
;;;

;;; "Variables"
base:
_GfxBase:          Dc.l      0
_IntBase:          Dc.l      0
_DosBase:          Dc.l      0

OldView:           Dc.l      0
OldCop:            Dc.l      0
OldInt:            Dc.w      0
OldDMA             Dc.w      0
OldPri:            Dc.w      0
OldCache:          Dc.l      0
OldLev3:           Dc.l      0

WindowPtr:         Dc.l      0

Gfxname:           Dc.b      'graphics.library',0
Intname:           Dc.b      'intuition.library',0
Dosname:           Dc.b      'dos.library',0        
		   Even

_FastMem:          Dc.w      0
_CPU:              Dc.w      0
_AGA:              Dc.w      0
_OS:               Dc.w      0
_VBR:              Dc.l      0

SyncBit:           Dc.w      0
;;;
;;; "get_VBR exception"
get_VBR:           Movec.l   VBR,a0
		   Nop
		   Rte
;;;
;;; "DummyLev3"
DummyLev3:         Btst      #5,$dff01f
		   Beq       .novblreq

		   Move.w    #1,SyncBit
.novblreq          Move.w    #%1110000,$dff09c
		   Nop
		   Rte
;;;

;;; "The Player 6.1A code"
*********************************
*        Player 6.1A ฎ          *
*      All in one-version       *
*        Version 610.2          *
*   ฉ 1992-95 Jarno Paananen    *
*     All rights reserved       *
*********************************


******** START OF BINARY FILE **************

P61_motuuli
	bra.w   P61_Init
	ifeq    CIA
	bra.w   P61_Music
	else
	rts
	rts
	endc
	bra.w   P61_End
	rts                             ;no P61_SetRepeat
	rts
	bra.w   P61_SetPosition

P61_Master      dc      64              ;Master volume (0-64)
P61_Tempo       dc      1               ;Use tempo? 0=no,non-zero=yes
P61_Play        dc      1               ;Stop flag (0=stop)
P61_E8          dc      0               ;Info nybble after command E8
P61_VBR         dc.l    0               ;If you're using non-valid execbase
					;put VBR here! (Otherwise 0 assumed)
					;You can also get VBR from here, if
					;using exec-valid version

P61_Pos         dc      0               ;Current song position
P61_Patt        dc      0               ;Current pattern
P61_CRow        dc      0               ;Current pattern row

P61_Temp0Offset
	dc.l    P61_temp0-P61_motuuli
P61_Temp1Offset
	dc.l    P61_temp1-P61_motuuli
P61_Temp2Offset
	dc.l    P61_temp2-P61_motuuli
P61_Temp3Offset
	dc.l    P61_temp3-P61_motuuli

P61_getnote     macro
	moveq   #$7e,d0
	and.b   (a5),d0
	beq.b   .nonote
	ifne    P61_vib
	clr.b   P61_VibPos(a5)
	endc
	ifne    P61_tre
	clr.b   P61_TrePos(a5)
	endc

	ifne    P61_ft
	add     P61_Fine(a5),d0
	endc
	move    d0,P61_Note(a5)
	move    (a2,d0),P61_Period(a5)

.nonote
	endm

	ifeq    system
	ifne    CIA
P61_intti
	movem.l d0-a6,-(sp)
	tst.b   $bfdd00
	lea     $dff000,a6
	move    #$2000,$9c(a6)
	;move    #$fff,$180(a6)
	bsr     P61_Music
	;move    #0,$180(a6)
	movem.l (sp)+,d0-a6
	nop
	rte
	endc
	endc

	ifne    system
P61_lev6server
	movem.l d2-d7/a2-a6,-(sp)
	lea     P61_timeron(pc),a0
	tst     (a0)
	beq.b   P61_ohi

	lea     $dff000,a6
	move    P61_server(pc),d0
	beq.b   P61_musica
	subq    #1,d0
	beq     P61_dmason
	bra     P61_setrepeat

P61_musica
	bsr     P61_Music

P61_ohi movem.l (sp)+,d2-d7/a2-a6
	moveq   #1,d0
	rts
	endc

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ Call P61_Init to initialize the playroutine  ญ
;ญ D0 --> Timer detection (for CIA-version)     ญ
;ญ A0 --> Address to the module                 ญ
;ญ A1 --> Address to samples/0 if in the module ญ
;ญ A2 --> Address to sample buffer              ญ
;ญ D0 <-- 0 if succeeded                        ญ
;ญ A6 <-- $DFF000                               ญ
;ญ              Uses D0-A6                      ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ

P61_Init
	cmp.l   #"P61A",(a0)+
	beq.b   .modok
	subq.l  #4,a0

.modok
	ifne    CIA
	move    d0,-(sp)
	endc

	moveq   #0,d0
	cmp.l   d0,a1
	bne.b   .redirect

	move    (a0),d0
	lea     (a0,d0.l),a1
.redirect
	move.l  a2,a6
	lea     8(a0),a2
	moveq   #$40,d0
	and.b   3(a0),d0
	bne.b   .buffer
	move.l  a1,a6
	subq.l  #4,a2
.buffer

	lea     P61_cn(pc),a3
	moveq   #$1f,d1
	and.b   3(a0),d1
	move.l  a0,-(sp)
	lea     P61_samples(pc),a4
	subq    #1,d1
	moveq   #0,d4
P61_lopos
	move.l  a6,(a4)+
	move    (a2)+,d4
	bpl.b   P61_kook
	neg     d4
	lea     P61_samples-16(pc),a5
	ifeq    opt020
	asl     #4,d4
	move.l  (a5,d4),d6
	else
	add     d4,d4
	move.l  (a5,d4*8),d6
	endc
	move.l  d6,-4(a4)
	move    4(a5,d4),d4
	sub.l   d4,a6
	sub.l   d4,a6
	bra.b   P61_jatk

P61_kook
	move.l  a6,d6
	tst.b   3(a0)
	bpl.b   P61_jatk

	tst.b   (a2)
	bmi.b   P61_jatk

	move    d4,d0
	subq    #2,d0
	bmi.b   P61_jatk

	move.l  a1,a5
	move.b  (a5)+,d2
	sub.b   (a5),d2
	move.b  d2,(a5)+
.loop   sub.b   (a5),d2
	move.b  d2,(a5)+
	sub.b   (a5),d2
	move.b  d2,(a5)+
	dbf     d0,.loop

P61_jatk
	move    d4,(a4)+
	moveq   #0,d2
	move.b  (a2)+,d2
	moveq   #0,d3
	move.b  (a2)+,d3

	moveq   #0,d0
	move    (a2)+,d0
	bmi.b   .norepeat

	move    d4,d5
	sub     d0,d5
	move.l  d6,a5

	add.l   d0,a5
	add.l   d0,a5

	move.l  a5,(a4)+
	move    d5,(a4)+
	bra.b   P61_gene
.norepeat
	move.l  d6,(a4)+
	move    #1,(a4)+
P61_gene
	move    d3,(a4)+
	moveq   #$f,d0
	and     d2,d0
	mulu    #74,d0
	move    d0,(a4)+

	tst     -6(a2)
	bmi.b   .nobuffer

	moveq   #$40,d0
	and.b   3(a0),d0
	beq.b   .nobuffer

	move    d4,d7
	tst.b   d2
	bpl.b   .copy

	subq    #1,d7
	moveq   #0,d5
	moveq   #0,d4
.lo     move.b  (a1)+,d4
	moveq   #$f,d3
	and     d4,d3
	lsr     #4,d4

	sub.b   .table(pc,d4),d5
	move.b  d5,(a6)+
	sub.b   .table(pc,d3),d5
	move.b  d5,(a6)+
	dbf     d7,.lo
	bra.b   .kop

.copy   add     d7,d7
	subq    #1,d7
.cob    move.b  (a1)+,(a6)+
	dbf     d7,.cob
	bra.b   .kop

.table dc.b     0,1,2,4,8,16,32,64,128,-64,-32,-16,-8,-4,-2,-1

.nobuffer
	move.l  d4,d6
	add.l   d6,d6
	add.l   d6,a6
	add.l   d6,a1
.kop    dbf     d1,P61_lopos

	move.l  (sp)+,a0
	and.b   #$7f,3(a0)

	move.l  a2,-(sp)

	lea     P61_temp0(pc),a1
	lea     P61_temp1(pc),a2
	lea     P61_temp2(pc),a4
	lea     P61_temp3(pc),a5
	moveq   #Channel_Block_SIZE/2-2,d0

	moveq   #0,d1
.cl     move    d1,(a1)+
	move    d1,(a2)+
	move    d1,(a4)+
	move    d1,(a5)+
	dbf     d0,.cl

	lea     P61_temp0-P61_cn(a3),a1
	lea     P61_emptysample-P61_cn(a3),a2
	moveq   #channels-1,d0
.loo    move.l  a2,P61_Sample(a2)
	dbf     d0,.loo

	move.l  (sp)+,a2
	move.l  a2,P61_positionbase-P61_cn(a3)

	moveq   #$7f,d1
	and.b   2(a0),d1

	ifeq    opt020
	lsl     #3,d1
	lea     (a2,d1.l),a4
	else
	lea     (a2,d1.l*8),a4
	endc
	move.l  a4,P61_possibase-P61_cn(a3)

	move.l  a4,a1
	moveq   #-1,d0
.search cmp.b   (a1)+,d0
	bne.b   .search
	move.l  a1,P61_patternbase-P61_cn(a3)   
	move.l  a1,d0
	sub.l   a4,d0
	move    d0,P61_slen-P61_cn(a3)

	ifd     start
	lea     start(a4),a4
	endc

	moveq   #0,d0
	move.b  (a4)+,d0
	move.l  a4,P61_spos-P61_cn(a3)
	lsl     #3,d0
	add.l   d0,a2

	move.l  a1,a4
	moveq   #0,d0   
	move    (a2)+,d0
	lea     (a4,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp0-P61_cn(a3)
	move    (a2)+,d0
	lea     (a4,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp1-P61_cn(a3)
	move    (a2)+,d0
	lea     (a4,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp2-P61_cn(a3)
	move    (a2)+,d0
	lea     (a4,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp3-P61_cn(a3)

	lea     P61_setrepeat(pc),a0
	move.l  a0,P61_intaddr-P61_cn(a3)

	move    #63,P61_rowpos-P61_cn(a3)
	move    #6,P61_speed-P61_cn(a3)
	move    #5,P61_speed2-P61_cn(a3)
	clr     P61_speedis1-P61_cn(a3)

	ifne    P61_pl
	clr.l   P61_plcount-P61_cn(a3)
	endc

	ifne    P61_pde
	clr     P61_pdelay-P61_cn(a3)
	clr     P61_pdflag-P61_cn(a3)
	endc
	clr     (a3)

	moveq   #2,d0
	and.b   $bfe001,d0
	move.b  d0,P61_ofilter-P61_cn(a3)
	bset    #1,$bfe001

	ifeq    system
	ifne    exec
	move.l  4.w,a6
	moveq   #0,d0
	btst    d0,297(a6)
	beq.b   .no68010

	lea     P61_liko(pc),a5
	jsr     -$1e(a6)

.no68010
	move.l  d0,P61_VBR-P61_cn(a3)
	endc

	move.l  P61_VBR-P61_cn(a3),a0
	lea     $78(a0),a0
	move.l  a0,P61_vektori-P61_cn(a3)

	move.l  (a0),P61_oldlev6-P61_cn(a3)
	lea     P61_dmason(pc),a1
	move.l  a1,(a0)
	endc

	moveq   #0,d0
	lea     $dff000,a6
	move    d0,$a8(a6)
	move    d0,$b8(a6)
	move    d0,$c8(a6)
	move    d0,$d8(a6)
	move    #$f,$96(a6)

	ifeq    system
	lea     P61_dmason(pc),a1
	move.l  a1,(a0)
	move    #$2000,$9a(a6)      ;!*! Av med external interrupt
	lea     $bfd000,a0
	lea     P61_timers(pc),a1
	move.b  #$7f,$d00(a0)
	move.b  #$10,$e00(a0)
	move.b  #$10,$f00(a0)
	move.b  $400(a0),(a1)+
	move.b  $500(a0),(a1)+
	move.b  $600(a0),(a1)+
	move.b  $700(a0),(a1)
	endc

	ifeq    system!CIA
	move.b  #$82,$d00(a0)
	endc

	ifne    CIA
	move    (sp)+,d0
	subq    #1,d0
	beq.b   P61_ForcePAL
	subq    #1,d0
	beq.b   P61_NTSC
	ifne    exec
	move.l  4.w,a1
	cmp.b   #60,$213(a1)    ;PowerSupplyFrequency
	beq.b   P61_NTSC
	endc
P61_ForcePAL
	move.l  #1773447,d0     ;PAL
	bra.b   P61_setcia
P61_NTSC
	move.l  #1789773,d0     ;NTSC
P61_setcia
	move.l  d0,P61_timer-P61_cn(a3)
	divu    #125,d0
	move    d0,P61_thi2-P61_cn(a3)
	sub     #$1f0*2,d0
	move    d0,P61_thi-P61_cn(a3)

	ifeq    system
	move    P61_thi2-P61_cn(a3),d0
	move.b  d0,$400(a0)
	lsr     #8,d0
	move.b  d0,$500(a0)
	lea     P61_intti(pc),a1
	move.l  a1,P61_tintti-P61_cn(a3)
	move.l  P61_vektori(pc),a2
	move.l  a1,(a2)
	move.b  #$83,$d00(a0)
	move.b  #$11,$e00(a0)
	endc
	endc

	ifeq    system
	move    #$e000,$9a(a6)
	moveq   #0,d0
	rts

	ifne    exec
P61_liko
	dc.l    $4E7A0801               ;MOVEC  VBR,d0
	rte
	endc
	endc

	ifne    system
	move.l  a6,-(sp)

	ifne    CIA
	clr     P61_server-P61_cn(a3)
	else
	move    #1,P61_server-P61_cn(a3)
	endc

	move.l  4.w,a6
	moveq   #-1,d0
	jsr     -$14a(a6)
	move.b  d0,P61_sigbit-P61_cn(a3)
	bmi     P61_err

	lea     P61_allocport(pc),a1
	move.l  a1,P61_portti-P61_cn(a3)
	move.b  d0,15(a1)
	move.l  a1,-(sp)
	suba.l  a1,a1
	jsr     -$126(a6)
	move.l  (sp)+,a1
	move.l  d0,16(a1)
	lea     P61_reqlist(pc),a0
	move.l  a0,(a0)
	addq.l  #4,(a0)
	clr.l   4(a0)
	move.l  a0,8(a0)

	lea     P61_dat(pc),a1
	move.l  a1,P61_reqdata-P61_cn(a3)
	lea     P61_allocreq(pc),a1
	lea     P61_audiodev(pc),a0
	moveq   #0,d0
	moveq   #0,d1
	jsr     -$1bc(a6)
	tst.l   d0
	bne     P61_err
	st.b    P61_audioopen-P61_cn(a3)

	lea     P61_timerint(pc),a1
	move.l  a1,P61_timerdata-P61_cn(a3)
	lea     P61_lev6server(pc),a1
	move.l  a1,P61_timerdata+8-P61_cn(a3)

	moveq   #0,d3
	lea     P61_cianame(pc),a1
P61_openciares
	moveq   #0,d0
	move.l  4.w,a6
	jsr     -$1f2(a6)
	move.l  d0,P61_ciares-P61_cn(a3)
	beq.b   P61_err
	move.l  d0,a6
	lea     P61_timerinterrupt(pc),a1
	moveq   #0,d0
	jsr     -6(a6)
	tst.l   d0
	beq.b   P61_gottimer
	addq.l  #4,d3
	lea     P61_timerinterrupt(pc),a1
	moveq   #1,d0
	jsr     -6(a6)
	tst.l   d0
	bne.b   P61_err

P61_gottimer
	lea     P61_craddr+8(pc),a6
	move.l  P61_ciaaddr(pc,d3),d0
	move.l  d0,(a6)
	sub     #$100,d0
	move.l  d0,-(a6)
	moveq   #2,d3
	btst    #9,d0
	bne.b   P61_timerB
	subq.b  #1,d3
	add     #$100,d0
P61_timerB
	add     #$900,d0
	move.l  d0,-(a6)
	move.l  d0,a0
	and.b   #%10000000,(a0)
	move.b  d3,P61_timeropen-P61_cn(a3)
	moveq   #0,d0
	ifne    CIA
	move.l  P61_craddr+4(pc),a1
	move.b  P61_tlo(pc),(a1)
	move.b  P61_thi(pc),$100(a1)
	endc
	or.b    #$19,(a0)
	st      P61_timeron-P61_cn(a3)
P61_pois
	move.l  (sp)+,a6
	rts

P61_err moveq   #-1,d0
	bra.b   P61_pois
	rts

P61_ciaaddr
	dc.l    $bfd500,$bfd700
	endc

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ      Call P61_End to stop the music          ญ
;ญ   A6 --> Customchip baseaddress ($DFF000)    ญ
;ญ              Uses D0/D1/A0/A1/A3             ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ

P61_End moveq   #0,d0
	move    d0,$a8(a6)
	move    d0,$b8(a6)
	move    d0,$c8(a6)
	move    d0,$d8(a6)
	move    #$f,$96(a6)

	and.b   #~2,$bfe001
	move.b  P61_ofilter(pc),d0
	or.b    d0,$bfe001

	ifeq    system
	move    #$2000,$9a(a6)
	move.l  P61_vektori(pc),a0
	move.l  P61_oldlev6(pc),(a0)
	lea     $bfd000,a0
	lea     P61_timers(pc),a1
	move.b  (a1)+,$400(a0)
	move.b  (a1)+,$500(a0)
	move.b  (a1)+,$600(a0)
	move.b  (a1)+,$700(a0)
	move.b  #$10,$e00(a0)
	move.b  #$10,$f00(a0)

	else

	clr     P61_timeron-P61_cn(a3)
	move.l  a6,-(sp)
	lea     P61_cn(pc),a3
	moveq   #0,d0
	move.b  P61_timeropen(pc),d0
	beq.b   P61_rem1
	move.l  P61_ciares(pc),a6
	lea     P61_timerinterrupt(pc),a1
	subq.b  #1,d0
	jsr     -12(a6)
P61_rem1
	move.l  4.w,a6
	tst.b   P61_audioopen-P61_cn(a3)
	beq.b   P61_rem2
	lea     P61_allocreq(pc),a1
	jsr     -$1c2(a6)
	clr.b   P61_audioopen-P61_cn(a3)
P61_rem2
	moveq   #0,d0
	move.b  P61_sigbit(pc),d0
	bmi.b   P61_rem3
	jsr     -$150(a6)
	st      P61_sigbit-P61_cn(a3)
P61_rem3
	move.l  (sp)+,a6
	endc
	rts

	ifne    fade
P61_mfade
	move    P61_Master(pc),d0
	move    P61_temp0+P61_Shadow(pc),d1
	mulu    d0,d1
	lsr     #6,d1
	move    d1,$a8(a6)

	ifgt    channels-1
	move    P61_temp1+P61_Shadow(pc),d1
	mulu    d0,d1
	lsr     #6,d1
	move    d1,$b8(a6)
	endc

	ifgt    channels-2
	move    P61_temp2+P61_Shadow(pc),d1
	mulu    d0,d1
	lsr     #6,d1
	move    d1,$c8(a6)
	endc

	ifgt    channels-3
	move    P61_temp3+P61_Shadow(pc),d1
	mulu    d0,d1
	lsr     #6,d1
	move    d1,$d8(a6)
	endc
	rts
	endc
	

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ Call P61_SetPosition to jump to a specific   ญ
;ญ            position in the song.             ญ
;ญ D0.l --> Position                            ญ
;ญ Starts from the beginning if out of limits.  ญ
;ญ              Uses A0/A1/A3/D0-D3             ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ

	ifne    jump
P61_SetPosition
	lea     P61_cn(pc),a3
	ifne    P61_pl
	clr     P61_plflag-P61_cn(a3)
	endc
	moveq   #0,d1
	move.b  d0,d1
	move.l  d1,d0
	cmp     P61_slen-P61_cn(a3),d0
	blo.b   .e
	moveq   #0,d0
.e      move    d0,P61_Pos-P61_cn(a3)
	add.l   P61_possibase(pc),d0
	move.l  d0,P61_spos-P61_cn(a3)

	moveq   #64,d0
	move    d0,P61_rowpos-P61_cn(a3)
	clr     P61_CRow-P61_cn(a3)
	move.l  P61_spos(pc),a1
	move.l  P61_patternbase(pc),a0
	addq    #1,P61_Pos-P61_cn(a3)
	move.b  (a1)+,d0
	move.l  a1,P61_spos-P61_cn(a3)
	move.l  P61_positionbase(pc),a1
	move    d0,P61_Patt-P61_cn(a3)
	lsl     #3,d0
	add.l   d0,a1
	movem   (a1),d0-d3
	lea     (a0,d0.l),a1
	move    d1,d0
	move.l  a1,P61_ChaPos+P61_temp0-P61_cn(a3)
	lea     (a0,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp1-P61_cn(a3)
	move    d2,d0
	lea     (a0,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp2-P61_cn(a3)
	move    d3,d0
	add.l   d0,a0
	move.l  a0,P61_ChaPos+P61_temp3-P61_cn(a3)
	rts
	endc

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ Call P61_Music every frame to play the music ญ
;ญ        _NOT_ if CIA-version is used!         ญ
;ญ A6 --> Customchip baseaddress ($DFF000)      ญ
;ญ              Uses A0-A5/D0-D7                ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ

P61_Music
	lea     P61_cn(pc),a3

	tst     P61_Play-P61_cn(a3)
	bne.b   P61_ohitaaa
	ifne    CIA
	ifne    system
	move.l  P61_craddr+4(pc),a0
	move.b  P61_tlo2(pc),(a0)
	move.b  P61_thi2(pc),$100(a0)
	endc
	endc
	rts

P61_ohitaaa
	ifne    fade
	pea     P61_mfade(pc)
	endc

	moveq   #Channel_Block_SIZE,d6
	moveq   #16,d7

	move    (a3),d4
	addq    #1,d4
	cmp     P61_speed(pc),d4
	beq     P61_playtime

	move    d4,(a3)

P61_delay
	ifne    CIA
	ifne    system
	move.l  P61_craddr+4(pc),a0
	move.b  P61_tlo2(pc),(a0)
	move.b  P61_thi2(pc),$100(a0)
	endc
	endc

	lea     P61_temp0(pc),a5
	lea     $a0(a6),a4

	moveq   #channels-1,d5
P61_lopas
	tst     P61_OnOff(a5)
	beq     P61_contfxdone
	moveq   #$f,d0
	and     (a5),d0
	ifeq    opt020
	add     d0,d0
	move    P61_jtab2(pc,d0),d0
	else
	move    P61_jtab2(pc,d0*2),d0
	endc
	jmp     P61_jtab2(pc,d0)

P61_jtab2
	dc      P61_contfxdone-P61_jtab2

	ifne    P61_pu
	dc      P61_portup-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_pd
	dc      P61_portdwn-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_tp
	dc      P61_toneport-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_vib
	dc      P61_vib2-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_tpvs
	dc      P61_tpochvslide-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_vbvs
	dc      P61_vibochvslide-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_tre
	dc      P61_tremo-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	ifne    P61_arp
	dc      P61_arpeggio-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	dc      P61_contfxdone-P61_jtab2

	ifne    P61_vs
	dc      P61_volslide-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc

	dc      P61_contfxdone-P61_jtab2
	dc      P61_contfxdone-P61_jtab2
	dc      P61_contfxdone-P61_jtab2

	ifne    P61_ec
	dc      P61_contecommands-P61_jtab2
	else
	dc      P61_contfxdone-P61_jtab2
	endc
	dc      P61_contfxdone-P61_jtab2

	ifne    P61_ec
P61_contecommands
	move.b  P61_Info(a5),d0
	and     #$f0,d0
	lsr     #3,d0
	move    P61_etab2(pc,d0),d0
	jmp     P61_etab2(pc,d0)

P61_etab2
	dc      P61_contfxdone-P61_etab2

	ifne    P61_fsu
	dc      P61_fineup2-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	ifne    P61_fsd
	dc      P61_finedwn2-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	dc      P61_contfxdone-P61_etab2
	dc      P61_contfxdone-P61_etab2

	dc      P61_contfxdone-P61_etab2
	dc      P61_contfxdone-P61_etab2

	dc      P61_contfxdone-P61_etab2
	dc      P61_contfxdone-P61_etab2

	ifne    P61_rt
	dc      P61_retrig-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	ifne    P61_fvu
	dc      P61_finevup2-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	ifne    P61_fvd
	dc      P61_finevdwn2-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	ifne    P61_nc
	dc      P61_notecut-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	ifne    P61_nd
	dc      P61_notedelay-P61_etab2
	else
	dc      P61_contfxdone-P61_etab2
	endc

	dc      P61_contfxdone-P61_etab2
	dc      P61_contfxdone-P61_etab2
	endc

	ifne    P61_fsu
P61_fineup2
	tst     (a3)
	bne     P61_contfxdone
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	sub     d0,P61_Period(a5)
	moveq   #113,d0
	cmp     P61_Period(a5),d0
	ble.b   .jup
	move    d0,P61_Period(a5)
.jup    move    P61_Period(a5),6(a4)
	bra     P61_contfxdone
	endc

	ifne    P61_fsd
P61_finedwn2
	tst     (a3)
	bne     P61_contfxdone
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	add     d0,P61_Period(a5)
	cmp     #856,P61_Period(a5)
	ble.b   .jup
	move    #856,P61_Period(a5)
.jup    move    P61_Period(a5),6(a4)
	bra     P61_contfxdone
	endc

	ifne    P61_fvu
P61_finevup2
	tst     (a3)
	bne     P61_contfxdone
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	add     d0,P61_Volume(a5)
	moveq   #64,d0
	cmp     P61_Volume(a5),d0
	bge.b   .jup
	move    d0,P61_Volume(a5)
.jup    move    P61_Volume(a5),8(a4)
	bra     P61_contfxdone
	endc

	ifne    P61_fvd
P61_finevdwn2
	tst     (a3)
	bne     P61_contfxdone
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	sub     d0,P61_Volume(a5)
	bpl.b   .jup
	clr     P61_Volume(a5)
.jup    move    P61_Volume(a5),8(a4)
	bra     P61_contfxdone
	endc

	ifne    P61_nc
P61_notecut
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	cmp     (a3),d0
	bne     P61_contfxdone
	ifeq    fade
	clr     8(a4)
	else
	clr     P61_Shadow(a5)        *************************
	endc                          * Congratulations! You  *
	clr     P61_Volume(a5)        * have found the hidden *
	Bra     P61_contfxdone        * message!!! =)         *
	endc                          *************************

	ifne    P61_nd
P61_notedelay
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	cmp     (a3),d0
	bne     P61_contfxdone

	moveq   #$7e,d0
	and.b   (a5),d0
	beq     P61_contfxdone
	move    P61_DMABit(a5),d0
	move    d0,$96(a6)
	or      d0,P61_dma-P61_cn(a3)
	move.l  P61_Sample(a5),a1               ;* Trigger *
	move.l  (a1)+,(a4)+                     ;Pointer
	move    (a1),(a4)+                      ;Length
	move    P61_Period(a5),(a4)
	subq.l  #6,a4

	ifeq    system
	lea     P61_dmason(pc),a1
	move.l  P61_vektori(pc),a0
	move.l  a1,(a0)
	move.b  #$f0,$bfd600
	move.b  #$01,$bfd700
	move.b  #$19,$bfdf00
	else
	move    #1,P61_server-P61_cn(a3)
	move.l  P61_craddr+4(pc),a1
	move.b  #$f0,(a1)
	move.b  #1,$100(a1)
	endc
	bra     P61_contfxdone
	endc

	ifne    P61_rt
P61_retrig
	subq    #1,P61_RetrigCount(a5)
	bne     P61_contfxdone
	move    P61_DMABit(a5),d0
	move    d0,$96(a6)
	or      d0,P61_dma-P61_cn(a3)
	move.l  P61_Sample(a5),a1               ;* Trigger *
	move.l  (a1)+,(a4)                      ;Pointer
	move    (a1),4(a4)                      ;Length

	ifeq    system
	lea     P61_dmason(pc),a1
	move.l  P61_vektori(pc),a0
	move.l  a1,(a0)
	move.b  #$f0,$bfd600
	move.b  #$01,$bfd700
	move.b  #$19,$bfdf00
	else
	move    #1,P61_server-P61_cn(a3)
	move.l  P61_craddr+4(pc),a1
	move.b  #$f0,(a1)
	move.b  #1,$100(a1)
	endc

	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	move    d0,P61_RetrigCount(a5)
	bra     P61_contfxdone
	endc

	ifne    P61_arp
P61_arplist
 dc.b 0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1,-1,0,1

P61_arpeggio
	move    (a3),d0
	move.b  P61_arplist(pc,d0),d0
	beq.b   .arp0
	bmi.b   .arp1

	move.b  P61_Info(a5),d0
	lsr     #4,d0
	bra.b   .arp3

.arp0   move    P61_Note(a5),d0
	move    P61_periods(pc,d0),6(a4)
	bra     P61_contfxdone

.arp1   moveq   #$f,d0
	and.b   P61_Info(a5),d0

.arp3   add     d0,d0
	add     P61_Note(a5),d0
	move    P61_periods(pc,d0),6(a4)
	bra     P61_contfxdone
	endc

P61_periods
	ifne    P61_ft
	Incbin  "/periods"
	else
	Incbin  "/periods.nft"
	endc

	ifne    P61_vs
P61_volslide
	move.b  P61_Info(a5),d0
	sub.b   d0,P61_Volume+1(a5)
	bpl.b   .test
	clr     P61_Volume(a5)
	ifeq    fade
	clr     8(a4)
	else
	clr     P61_Shadow(a5)
	endc
	bra     P61_contfxdone
.test   moveq   #64,d0
	cmp     P61_Volume(a5),d0
	bge.b   .ncs
	move    d0,P61_Volume(a5)
	ifeq    fade
	move    d0,8(a4)
	else
	move    d0,P61_Shadow(a5)
	endc
	bra.b   P61_contfxdone
.ncs
	ifeq    fade
	move    P61_Volume(a5),8(a4)
	else
	move    P61_Volume(a5),P61_Shadow(a5)
	endc
	bra.b   P61_contfxdone
	endc

	ifne    P61_tpvs
P61_tpochvslide
	move.b  P61_Info(a5),d0
	sub.b   d0,P61_Volume+1(a5)
	bpl.b   .test
	clr     P61_Volume(a5)
	ifeq    fade
	clr     8(a4)
	else
	clr     P61_Shadow(a5)
	endc
	bra.b   P61_toneport
.test   moveq   #64,d0
	cmp     P61_Volume(a5),d0
	bge.b   .ncs
	move    d0,P61_Volume(a5)
.ncs
	ifeq    fade
	move    P61_Volume(a5),8(a4)
	else
	move    P61_Volume(a5),P61_Shadow(a5)
	endc
	endc

	ifne    P61_tp
P61_toneport
	move    P61_ToPeriod(a5),d0
	beq.b   P61_contfxdone
	move    P61_TPSpeed(a5),d1
	cmp     P61_Period(a5),d0
	blt.b   .topoup

	add     d1,P61_Period(a5)
	cmp     P61_Period(a5),d0
	bgt.b   .setper
	move    d0,P61_Period(a5)
	clr     P61_ToPeriod(a5)
	move    d0,6(a4)
	bra.b   P61_contfxdone

.topoup
	sub     d1,P61_Period(a5)
	cmp     P61_Period(a5),d0
	blt.b   .setper
	move    d0,P61_Period(a5)
	clr     P61_ToPeriod(a5)
.setper
	move    P61_Period(a5),6(a4)
	else
	nop
	endc

P61_contfxdone
	ifne    P61_il
	bsr     P61_funk2
	endc

	add.l   d6,a5
	add.l   d7,a4
	dbf     d5,P61_lopas

	cmp     P61_speed2(pc),d4
	beq.b   P61_preplay
	rts

	ifne    P61_pu
P61_portup
	moveq   #0,D0
	move.b  P61_Info(a5),d0
	sub     d0,P61_Period(a5)
	moveq   #113,d0
	cmp     P61_Period(a5),d0
	ble.b   .skip
	move    d0,P61_Period(a5)
	move    d0,6(a4)
	bra.b   P61_contfxdone
.skip
	move    P61_Period(a5),6(a4)
	bra.b   P61_contfxdone
	endc

	ifne    P61_pd
P61_portdwn
	moveq   #0,d0
	move.b  P61_Info(a5),d0
	add     d0,P61_Period(a5)
	cmp     #856,P61_Period(a5)
	ble.b   .skip
	move    #856,d0
	move    d0,P61_Period(a5)
	move    d0,6(a4)
	bra.b   P61_contfxdone
.skip
	move    P61_Period(a5),6(a4)
	bra.b   P61_contfxdone
	endc

	ifne    P61_pde
P61_return
	rts

P61_preplay
	tst     P61_pdflag-P61_cn(a3)
	bne.b   P61_return
	else
P61_preplay
	endc

	lea     P61_temp0(pc),a5
	lea     P61_samples-16(pc),a0

	moveq   #channels-1,d5
P61_loaps
	ifne    P61_pl
	lea     P61_TData(a5),a1
	move    2(a5),(a1)+
	move.l  P61_ChaPos(a5),(a1)+
	move.l  P61_TempPos(a5),(a1)+
	move    P61_TempLen(a5),(a1)
	endc

	move.b  P61_Pack(a5),d0
	and.b   #$3f,d0
	beq.b   P61_takeone

	tst.b   P61_Pack(a5)
	bmi.b   .keepsame

	subq.b  #1,P61_Pack(a5)
	clr     P61_OnOff(a5)                   ; Empty row
	add.l   d6,a5
	dbf     d5,P61_loaps
	rts

.keepsame
	subq.b  #1,P61_Pack(a5)
	bra     P61_dko

P61_takeone
	tst.b   P61_TempLen+1(a5)
	beq.b   P61_takenorm

	subq.b  #1,P61_TempLen+1(a5)
	move.l  P61_TempPos(a5),a2

P61_jedi
	move.b  (a2)+,d0
	moveq   #%01100000,d1
	and.b   d0,d1
	cmp.b   #%01100000,d1
	bne.b   .all

	moveq   #%01110000,d1
	and.b   d0,d1
	cmp.b   #%01110000,d1
	bne.b   .cmd

	moveq   #%01111000,d1
	and.b   d0,d1
	cmp.b   #%01111000,d1
	bne.b   .note

.empty  clr     P61_OnOff(a5)                   ; Empty row
	clr     (a5)+
	clr.b   (a5)+
	tst.b   d0
	bpl.b   .ex
	move.b  (a2)+,(a5)                      ; Compression info
	bra.b   .ex

.all    move.b  d0,(a5)+
	ifeq    opt020
	move.b  (a2)+,(a5)+
	move.b  (a2)+,(a5)+
	else
	move    (a2)+,(a5)+
	endc
	tst.b   d0
	bpl.b   .ex
	move.b  (a2)+,(a5)                      ; Compression info
	bra.b   .ex

.cmd    moveq   #$f,d1
	and     d0,d1
	move    d1,(a5)+                        ; cmd
	move.b  (a2)+,(a5)+                     ; info
	tst.b   d0
	bpl.b   .ex
	move.b  (a2)+,(a5)                      ; Compression info
	bra.b   .ex

.note   moveq   #7,d1
	and     d0,d1
	lsl     #8,d1
	move.b  (a2)+,d1
	lsl     #4,d1
	move    d1,(a5)+
	clr.b   (a5)+   
	tst.b   d0
	bpl.b   .ex
	move.b  (a2)+,(a5)                      ; Compression info
.ex     subq.l  #3,a5
	move.l  a2,P61_TempPos(a5)
	bra     P61_dko


P61_takenorm
	move.l  P61_ChaPos(a5),a2

	move.b  (a2)+,d0
	moveq   #%01100000,d1
	and.b   d0,d1
	cmp.b   #%01100000,d1
	bne.b   .all

	moveq   #%01110000,d1
	and.b   d0,d1
	cmp.b   #%01110000,d1
	bne.b   .cmd

	moveq   #%01111000,d1
	and.b   d0,d1
	cmp.b   #%01111000,d1
	bne.b   .note

.empty  clr     P61_OnOff(a5)                   ; Empty row
	clr     (a5)+
	clr.b   (a5)+
	tst.b   d0
	bpl.b   .proccomp
	move.b  (a2)+,(a5)                      ; Compression info
	bra.b   .proccomp


.all    move.b  d0,(a5)+
	ifeq    opt020
	move.b  (a2)+,(a5)+
	move.b  (a2)+,(a5)+
	else
	move    (a2)+,(a5)+
	endc
	tst.b   d0
	bpl.b   .proccomp
	move.b  (a2)+,(a5)                      ; Compression info
	bra.b   .proccomp

.cmd    moveq   #$f,d1
	and     d0,d1
	move    d1,(a5)+                        ; cmd
	move.b  (a2)+,(a5)+                     ; info
	tst.b   d0
	bpl.b   .proccomp
	move.b  (a2)+,(a5)                      ; Compression info
	bra.b   .proccomp

.note   moveq   #7,d1
	and     d0,d1
	lsl     #8,d1
	move.b  (a2)+,d1
	lsl     #4,d1
	move    d1,(a5)+
	clr.b   (a5)+   
	tst.b   d0
	bpl.b   .proccomp
	move.b  (a2)+,(a5)                      ; Compression info

.proccomp
	subq.l  #3,a5
	move.l  a2,P61_ChaPos(a5)

	tst.b   d0
	bpl.b   P61_dko

	move.b  3(a5),d0
	move.b  d0,d1
	and     #%11000000,d1
	beq.b   P61_dko                         ; Empty datas
	cmp.b   #%10000000,d1
	beq.b   P61_dko                         ; Same datas

	clr.b   3(a5)
	and     #$3f,d0
	move.b  d0,P61_TempLen+1(a5)

	cmp.b   #%11000000,d1
	beq.b   .bit16                          ; 16-bit

	moveq   #0,d0                           ; 8-bit
	move.b  (a2)+,d0
	move.l  a2,P61_ChaPos(a5)
	sub.l   d0,a2
	bra     P61_jedi

.bit16  moveq   #0,d0
	ifeq    opt020
	move.b  (a2)+,d0
	lsl     #8,d0
	move.b  (a2)+,d0
	else
	move    (a2)+,d0
	endc

	move.l  a2,P61_ChaPos(a5)
	sub.l   d0,a2
	bra     P61_jedi


P61_dko st      P61_OnOff(a5)
	move    (a5),d0
	and     #$1f0,d0
	beq.b   .koto
	lea     (a0,d0),a1
	move.l  a1,P61_Sample(a5)
	ifne    P61_ft
	move.l  P61_SampleVolume(a1),P61_Volume(a5)
	else
	move    P61_SampleVolume(a1),P61_Volume(a5)
	endc
	ifne    P61_il
	move.l  P61_RepeatOffset(a1),P61_Wave(a5)
	endc
	ifne    P61_sof
	clr     P61_Offset(a5)
	endc

.koto   add.l   d6,a5
	dbf     d5,P61_loaps
	rts

P61_playtime
	clr     (a3)

	ifne    P61_pde
	tst     P61_pdelay-P61_cn(a3)
	beq.b   .djdj
	subq    #1,P61_pdelay-P61_cn(a3)
	bne     P61_delay
	tst     P61_speedis1-P61_cn(a3)
	bne     P61_delay
	clr     P61_pdflag-P61_cn(a3)
	bra     P61_delay
.djdj
	clr     P61_pdflag-P61_cn(a3)
	endc

	tst     P61_speedis1-P61_cn(a3)
	beq.b   .mo
	bsr     P61_preplay

.mo     lea     P61_temp0(pc),a5
	lea     $a0(a6),a4

	ifeq    system
	lea     P61_dmason(pc),a1
	move.l  P61_vektori(pc),a0
	move.l  a1,(a0)
	move.b  #$f0,$bfd600
	move.b  #$01,$bfd700
	move.b  #$19,$bfdf00
	else
	move    #1,P61_server-P61_cn(a3)
	move.l  P61_craddr+4(pc),a1
	move.b  #$f0,(a1)
	move.b  #1,$100(a1)
	endc

	lea     P61_periods(pc),a2

	moveq   #0,d4
	moveq   #channels-1,d5
P61_los tst     P61_OnOff(a5)
	beq.b   P61_nocha

	moveq   #$f,d0
	and     (a5),d0
	lea     P61_jtab(pc),a1
	add     d0,d0
	add.l   d0,a1
	add     (a1),a1
	jmp     (a1)

P61_fxdone
	moveq   #$7e,d0
	and.b   (a5),d0
	beq.b   P61_nocha
	ifne    P61_vib
	clr.b   P61_VibPos(a5)
	endc
	ifne    P61_tre
	clr.b   P61_TrePos(a5)
	endc

	ifne    P61_ft
	add     P61_Fine(a5),d0
	endc
	move    d0,P61_Note(a5)
	move    (a2,d0),P61_Period(a5)

P61_zample
	ifne    P61_sof
	tst     P61_Offset(a5)
	bne     P61_pek
	endc

	or      P61_DMABit(a5),d4
	move    d4,$96(a6)
	move.l  P61_Sample(a5),a1               ;* Trigger *
	move.l  (a1)+,(a4)                      ;Pointer
	move    (a1),4(a4)                      ;Length

P61_nocha
	ifeq    fade
	move.l  P61_Period(a5),6(a4)
	else
	move    P61_Period(a5),6(a4)
	move    P61_Volume(a5),P61_Shadow(a5)
	endc

P61_skip
	ifne    P61_il
	bsr     P61_funk2
	endc

	add.l   d6,a5
	add.l   d7,a4
	dbf     d5,P61_los

	move.b  d4,P61_dma+1-P61_cn(a3)

	ifne    P61_pl
	tst.b   P61_plflag+1-P61_cn(a3)
	beq.b   P61_ohittaa

	lea     P61_temp0(pc),a1
	lea     P61_looppos(pc),a0
	moveq   #channels-1,d0
.talt   move.b  1(a0),3(a1)
	addq.l  #2,a0
	move.l  (a0)+,P61_ChaPos(a1)
	move.l  (a0)+,P61_TempPos(a1)
	move    (a0)+,P61_TempLen(a1)
	add.l   d6,a1
	dbf     d0,.talt

	move    P61_plrowpos(pc),P61_rowpos-P61_cn(a3)
	clr.b   P61_plflag+1-P61_cn(a3)
	moveq   #63,d0
	sub     P61_rowpos-P61_cn(a3),d0
	move    d0,P61_CRow-P61_cn(a3)
	rts
	endc

P61_ohittaa
	subq    #1,P61_rowpos-P61_cn(a3)
	bmi.b   P61_nextpattern
	moveq   #63,d0
	sub     P61_rowpos-P61_cn(a3),d0
	move    d0,P61_CRow-P61_cn(a3)
	rts

P61_nextpattern
	ifne    P61_pl
	clr     P61_plflag-P61_cn(a3)
	endc
	move.l  P61_patternbase(pc),a4
	moveq   #63,d0
	move    d0,P61_rowpos-P61_cn(a3)
	clr     P61_CRow-P61_cn(a3)
	move.l  P61_spos(pc),a1
	addq    #1,P61_Pos-P61_cn(a3)
	move.b  (a1)+,d0
	bpl.b   P61_dk
	move.l  P61_possibase(pc),a1
	move.b  (a1)+,d0
	clr     P61_Pos-P61_cn(a3)
P61_dk  move.l  a1,P61_spos-P61_cn(a3)
	move    d0,P61_Patt-P61_cn(a3)
	lsl     #3,d0
	move.l  P61_positionbase(pc),a1
	add.l   d0,a1

	move    (a1)+,d0
	lea     (a4,d0.l),a2
	move.l  a2,P61_ChaPos+P61_temp0-P61_cn(a3)
	move    (a1)+,d0
	lea     (a4,d0.l),a2
	move.l  a2,P61_ChaPos+P61_temp1-P61_cn(a3)
	move    (a1)+,d0
	lea     (a4,d0.l),a2
	move.l  a2,P61_ChaPos+P61_temp2-P61_cn(a3)
	move    (a1),d0
	add.l   d0,a4
	move.l  a4,P61_ChaPos+P61_temp3-P61_cn(a3)
	rts

	ifne    P61_tp
P61_settoneport
	move.b  P61_Info(a5),d0
	beq.b   P61_toponochange
	move.b  d0,P61_TPSpeed+1(a5)
P61_toponochange
	moveq   #$7e,d0
	and.b   (a5),d0
	beq     P61_nocha
	add     P61_Fine(a5),d0
	move    d0,P61_Note(a5)
	move    (a2,d0),P61_ToPeriod(a5)
	bra     P61_nocha
	endc

	ifne    P61_sof
P61_sampleoffse
	moveq   #0,d1
	move    #$ff00,d1
	and     2(a5),d1
	bne.b   .deq
	move    P61_LOffset(a5),d1
.deq    move    d1,P61_LOffset(a5)
	add     d1,P61_Offset(a5)

	moveq   #$7e,d0
	and.b   (a5),d0
	beq     P61_nocha

	move    P61_Offset(a5),d2
	add     d1,P61_Offset(a5)               ; THIS IS A PT-FEATURE!
	move    d2,d1

	ifne    P61_vib
	clr.b   P61_VibPos(a5)
	endc
	ifne    P61_tre
	clr.b   P61_TrePos(a5)
	endc

	ifne    P61_ft
	add     P61_Fine(a5),d0
	endc
	move    d0,P61_Note(a5)
	move    (a2,d0),P61_Period(a5)
	bra.b   P61_hup

P61_pek moveq   #0,d1
	move    P61_Offset(a5),d1
P61_hup or      P61_DMABit(a5),d4
	move    d4,$96(a6)
	move.l  P61_Sample(a5),a1               ;* Trigger *
	move.l  (a1)+,d0
	add.l   d1,d0
	move.l  d0,(a4)                         ;Pointer
	lsr     #1,d1
	move    (a1),d0
	sub     d1,d0
	bpl.b   P61_offok
	move.l  -4(a1),(a4)                     ;Pointer is over the end
	moveq   #1,d0
P61_offok
	move    d0,4(a4)                        ;Length
	bra     P61_nocha
	endc

	ifne    P61_vl
P61_volum
	move.b  P61_Info(a5),P61_Volume+1(a5)
	bra     P61_fxdone
	endc

	ifne    P61_pj
P61_posjmp
	moveq   #0,d0
	move.b  P61_Info(a5),d0
	cmp     P61_slen-P61_cn(a3),d0
	blo.b   .e
	moveq   #0,d0
.e      move    d0,P61_Pos-P61_cn(a3)
	add.l   P61_possibase(pc),d0
	move.l  d0,P61_spos-P61_cn(a3)
	endc

	ifne    P61_pb
P61_pattbreak
	moveq   #64,d0
	move    d0,P61_rowpos-P61_cn(a3)
	clr     P61_CRow-P61_cn(a3)
	move.l  P61_spos(pc),a1
	move.l  P61_patternbase(pc),a0
	addq    #1,P61_Pos-P61_cn(a3)
	move.b  (a1)+,d0
	bpl.b   P61_dk2
	move.l  P61_possibase(pc),a1
	move.b  (a1)+,d0
	clr     P61_Pos-P61_cn(a3)
P61_dk2 move.l  a1,P61_spos-P61_cn(a3)
	move.l  P61_positionbase(pc),a1
	move    d0,P61_Patt-P61_cn(a3)
	lsl     #3,d0
	add.l   d0,a1
	movem   (a1),d0-d3
	lea     (a0,d0.l),a1
	move    d1,d0
	move.l  a1,P61_ChaPos+P61_temp0-P61_cn(a3)
	lea     (a0,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp1-P61_cn(a3)
	move    d2,d0
	lea     (a0,d0.l),a1
	move.l  a1,P61_ChaPos+P61_temp2-P61_cn(a3)
	move    d3,d0
	add.l   d0,a0
	move.l  a0,P61_ChaPos+P61_temp3-P61_cn(a3)
	bra     P61_fxdone
	endc

	ifne    P61_vib
P61_vibrato
	move.b  P61_Info(a5),d0
	beq     P61_fxdone
	move.b  d0,d1
	move.b  P61_VibCmd(a5),d2
	and.b   #$f,d0
	beq.b   P61_vibskip
	and.b   #$f0,d2
	or.b    d0,d2
P61_vibskip
	and.b   #$f0,d1
	beq.b   P61_vibskip2
	and.b   #$f,d2
	or.b    d1,d2
P61_vibskip2
	move.b  d2,P61_VibCmd(a5)
	bra     P61_fxdone
	endc

	ifne    P61_tre
P61_settremo
	move.b  P61_Info(a5),d0
	beq     P61_fxdone
	move.b  d0,d1
	move.b  P61_TreCmd(a5),d2
	moveq   #$f,d3
	and.b   d3,d0
	beq.b   P61_treskip
	and.b   #$f0,d2
	or.b    d0,d2
P61_treskip
	and.b   #$f0,d1
	beq.b   P61_treskip2
	and.b   d3,d2
	or.b    d1,d2
P61_treskip2
	move.b  d2,P61_TreCmd(a5)
	bra     P61_fxdone
	endc

	ifne    P61_ec
P61_ecommands
	move.b  P61_Info(a5),d0
	and.b   #$f0,d0
	lsr     #3,d0
	move    P61_etab(pc,d0),d0
	jmp     P61_etab(pc,d0)

P61_etab
	ifne    P61_fi
	dc      P61_filter-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_fsu
	dc      P61_fineup-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_fsd
	dc      P61_finedwn-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	dc      P61_fxdone-P61_etab
	dc      P61_fxdone-P61_etab

	ifne    P61_sft
	dc      P61_setfinetune-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_pl
	dc      P61_patternloop-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	dc      P61_fxdone-P61_etab

	ifne    P61_timing
	dc      P61_sete8-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_rt
	dc      P61_setretrig-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_fvu
	dc      P61_finevup-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_fvd
	dc      P61_finevdwn-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	dc      P61_fxdone-P61_etab

	ifne    P61_nd
	dc      P61_ndelay-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_pde
	dc      P61_pattdelay-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc

	ifne    P61_il
	dc      P61_funk-P61_etab
	else
	dc      P61_fxdone-P61_etab
	endc
	endc

	ifne    P61_fi
P61_filter
	move.b  P61_Info(a5),d0
	and.b   #$fd,$bfe001
	or.b    d0,$bfe001
	bra     P61_fxdone
	endc

	ifne    P61_fsu
P61_fineup
	P61_getnote

	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	sub     d0,P61_Period(a5)
	moveq   #113,d0
	cmp     P61_Period(a5),d0
	ble.b   .jup
	move    d0,P61_Period(a5)
.jup    moveq   #$7e,d0
	and.b   (a5),d0
	bne     P61_zample
	bra     P61_nocha
	endc

	ifne    P61_fsd
P61_finedwn
	P61_getnote

	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	add     d0,P61_Period(a5)
	cmp     #856,P61_Period(a5)
	ble.b   .jup
	move    #856,P61_Period(a5)
.jup    moveq   #$7e,d0
	and.b   (a5),d0
	bne     P61_zample
	bra     P61_nocha
	endc

	ifne    P61_sft
P61_setfinetune
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	ifeq    opt020
	add     d0,d0
	move    P61_mulutab(pc,d0),P61_Fine(a5)
	else
	move    P61_mulutab(pc,d0*2),P61_Fine(a5)
	endc
	bra     P61_fxdone

P61_mulutab
	dc      0,74,148,222,296,370,444,518,592,666,740,814,888,962,1036,1110
	endc

	ifne    P61_pl
P61_patternloop
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	beq.b   P61_setloop

	tst.b   P61_plflag-P61_cn(a3)
	bne.b   P61_noset

	move    d0,P61_plcount-P61_cn(a3)
	st.b    P61_plflag-P61_cn(a3)
P61_noset
	tst     P61_plcount-P61_cn(a3)
	bne.b   P61_looppaa
	clr.b   P61_plflag-P61_cn(a3)
	bra     P61_fxdone
	
P61_looppaa
	st.b    P61_plflag+1-P61_cn(a3)
	subq    #1,P61_plcount-P61_cn(a3)
	bra     P61_fxdone

P61_setloop
	tst.b   P61_plflag-P61_cn(a3)
	bne     P61_fxdone
	move    P61_rowpos(pc),P61_plrowpos-P61_cn(a3)
	lea     P61_temp0+P61_TData(pc),a1
	lea     P61_looppos(pc),a0
	moveq   #channels-1,d0
.talt   move.l  (a1)+,(a0)+
	move.l  (a1)+,(a0)+
	move.l  (a1),(a0)+
	subq.l  #8,a1
	add.l   d6,a1
	dbf     d0,.talt
	bra     P61_fxdone
	endc

	ifne    P61_fvu
P61_finevup
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	add     d0,P61_Volume(a5)
	moveq   #64,d0
	cmp     P61_Volume(a5),d0
	bge     P61_fxdone
	move    d0,P61_Volume(a5)
	bra     P61_fxdone
	endc

	ifne    P61_fvd
P61_finevdwn
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	sub     d0,P61_Volume(a5)
	bpl     P61_fxdone
	clr     P61_Volume(a5)
	bra     P61_fxdone
	endc

	ifne    P61_timing
P61_sete8
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	move    d0,P61_E8-P61_cn(a3)
	bra     P61_fxdone
	endc

	ifne    P61_rt
P61_setretrig
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	move    d0,P61_RetrigCount(a5)
	bra     P61_fxdone
	endc

	ifne    P61_nd
P61_ndelay
	moveq   #$7e,d0
	and.b   (a5),d0
	beq     P61_skip
	ifne    P61_vib
	clr.b   P61_VibPos(a5)
	endc
	ifne    P61_tre
	clr.b   P61_TrePos(a5)
	endc
	ifne    P61_ft
	add     P61_Fine(a5),d0
	endc
	move    d0,P61_Note(a5)
	move    (a2,d0),P61_Period(a5)
	ifeq    fade
	move    P61_Volume(a5),8(a4)
	else
	move    P61_Volume(a5),P61_Shadow(a5)
	endc
	bra     P61_skip
	endc

	ifne    P61_pde
P61_pattdelay
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	move    d0,P61_pdelay-P61_cn(a3)
	st      P61_pdflag-P61_cn(a3)
	bra     P61_fxdone
	endc

	ifne    P61_sd
P61_cspeed
	moveq   #0,d0
	move.b  P61_Info(a5),d0

	ifne    CIA
	tst     P61_Tempo-P61_cn(a3)
	beq.b   P61_VBlank
	cmp.b   #32,d0
	bhs.b   P61_STempo
	endc

P61_VBlank
	cmp.b   #1,d0
	beq.b   P61_jkd

	move.b  d0,P61_speed+1-P61_cn(a3)
	subq.b  #1,d0
	move.b  d0,P61_speed2+1-P61_cn(a3)
	clr     P61_speedis1-P61_cn(a3)
	bra     P61_fxdone

P61_jkd move.b  d0,P61_speed+1-P61_cn(a3)
	move.b  d0,P61_speed2+1-P61_cn(a3)
	st      P61_speedis1-P61_cn(a3)
	bra     P61_fxdone


	ifne    CIA
P61_STempo
	move.l  P61_timer(pc),d1
	divu    d0,d1
	move    d1,P61_thi2-P61_cn(a3)
	sub     #$1f0*2,d1
	move    d1,P61_thi-P61_cn(a3)

	ifeq    system
	move    P61_thi2-P61_cn(a3),d1
	move.b  d1,$bfd400
	lsr     #8,d1
	move.b  d1,$bfd500
	endc

	bra     P61_fxdone
	endc
	endc



	ifne    P61_vbvs
P61_vibochvslide
	move.b  P61_Info(a5),d0
	sub.b   d0,P61_Volume+1(a5)
	bpl.b   P61_test62
	clr     P61_Volume(a5)
	ifeq    fade
	clr     8(a4)
	else
	clr     P61_Shadow(a5)
	endc
	bra.b   P61_vib2
P61_test62
	moveq   #64,d0
	cmp     P61_Volume(a5),d0
	bge.b   .ncs2
	move    d0,P61_Volume(a5)
.ncs2
	ifeq    fade
	move    P61_Volume(a5),8(a4)
	else
	move    P61_Volume(a5),P61_Shadow(a5)
	endc
	endc

	ifne    P61_vib
P61_vib2
	move    #$f00,d0
	move    P61_VibCmd(a5),d1
	and     d1,d0
	lsr     #3,d0

	lsr     #2,d1
	and     #$1f,d1
	add     d1,d0

	move    P61_Period(a5),d1
	moveq   #0,d2
	move.b  P61_vibtab(pc,d0),d2

	tst.b   P61_VibPos(a5)
	bmi.b   .vibneg
	add     d2,d1
	bra.b   P61_vib4

.vibneg sub     d2,d1

P61_vib4
	move    d1,6(a4)
	move.b  P61_VibCmd(a5),d0
	lsr.b   #2,d0
	and     #$3c,d0
	add.b   d0,P61_VibPos(a5)
	bra     P61_contfxdone
	endc

	ifne    P61_tre
P61_tremo
	move    #$f00,d0
	move    P61_TreCmd(a5),d1
	and     d1,d0
	lsr     #3,d0
	
	lsr     #2,d1
	and     #$1f,d1
	add     d1,d0

	move    P61_Volume(a5),d1
	moveq   #0,d2
	move.b  P61_vibtab(pc,d0),d2

	tst.b   P61_TrePos(a5)
	bmi.b   .treneg
	add     d2,d1
	cmp     #64,d1
	ble.b   P61_tre4
	moveq   #64,d1
	bra.b   P61_tre4

.treneg sub     d2,d1
	bpl.b   P61_tre4
	moveq   #0,d1
P61_tre4
	ifeq    fade
	move    d1,8(a4)
	else
	move    d1,P61_Shadow(a5)
	endc

	move.b  P61_TreCmd(a5),d0
	lsr.b   #2,d0
	and     #$3c,d0
	add.b   d0,P61_TrePos(a5)
	bra     P61_contfxdone
	endc

	ifne    P61_vib!P61_tre
P61_vibtab      Incbin  "/vibtab"
	endc

	ifne    P61_il
P61_funk
	moveq   #$f,d0
	and.b   P61_Info(a5),d0
	move.b  d0,P61_Funkspd(a5)
	bra     P61_fxdone

P61_funk2
	moveq   #0,d0
	move.b  P61_Funkspd(a5),d0
	beq.b   P61_funkend
	move.b  P61_FunkTable(pc,d0),d0
	add.b   d0,P61_Funkoff(a5)
	bpl.b   P61_funkend
	clr.b   P61_Funkoff(a5)

	move.l  P61_Sample(a5),a1
	move.l  P61_RepeatOffset(a1),d1
	move    P61_RepeatLength(a1),d0
	add.l   d0,d0
	add.l   d1,d0
	move.l  P61_Wave(a5),a0
	addq.l  #1,a0
	cmp.l   d0,a0
	blo.b   P61_funkok
	move.l  d1,a0
P61_funkok
	move.l  a0,P61_Wave(a5)
	not.b   (a0)
P61_funkend
	rts

P61_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	endc

P61_jtab
	dc      P61_fxdone-*
	dc      P61_fxdone-*
	dc      P61_fxdone-*

	ifne    P61_tp
	dc      P61_settoneport-*
	else
	dc      P61_fxdone-*
	endc

	ifne    P61_vib
	dc      P61_vibrato-*
	else
	dc      P61_fxdone-*
	endc

	ifne    P61_tpvs
	dc      P61_toponochange-*
	else
	dc      P61_fxdone-*
	endc

	dc      P61_fxdone-*

	ifne    P61_tre
	dc      P61_settremo-*
	else
	dc      P61_fxdone-*
	endc

	dc      P61_fxdone-*

	ifne    P61_sof
	dc      P61_sampleoffse-*
	else
	dc      P61_fxdone-*
	endc
	dc      P61_fxdone-*

	ifne    P61_pj
	dc      P61_posjmp-*
	else
	dc      P61_fxdone-*
	endc

	ifne    P61_vl
	dc      P61_volum-*
	else
	dc      P61_fxdone-*
	endc

	ifne    P61_pb
	dc      P61_pattbreak-*
	else
	dc      P61_fxdone-*
	endc

	ifne    P61_ec
	dc      P61_ecommands-*
	else
	dc      P61_fxdone-*
	endc
	
	ifne    P61_sd
	dc      P61_cspeed-*
	else
	dc      P61_fxdone-*
	endc


P61_dmason
	ifeq    system
	tst.b   $bfdd00
	move    #$2000,$dff09c
	move.b  #$19,$bfdf00
	move.l  a0,-(sp)
	move.l  P61_vektori(pc),a0
	move.l  P61_intaddr(pc),(a0)
	move.l  (sp)+,a0
	move    P61_dma(pc),$dff096
	nop
	rte

	else

	move    P61_dma(pc),$96(a6)
	lea     P61_server(pc),a3
	addq    #1,(a3)
	move.l  P61_craddr(pc),a0
	move.b  #$19,(a0)
	bra     P61_ohi
	endc


P61_setrepeat
	ifeq    system
	tst.b   $bfdd00
	movem.l a0/a1,-(sp)
	lea     $dff0a0,a1
	move    #$2000,-4(a1)
	else
	lea     $a0(a6),a1
	endc

	move.l  P61_Sample+P61_temp0(pc),a0
	addq.l  #6,a0
	move.l  (a0)+,(a1)+
	move    (a0),(a1)

	ifgt    channels-1
	move.l  P61_Sample+P61_temp1(pc),a0
	addq.l  #6,a0
	move.l  (a0)+,12(a1)
	move    (a0),16(a1)
	endc
	
	ifgt    channels-2
	move.l  P61_Sample+P61_temp2(pc),a0
	addq.l  #6,a0
	move.l  (a0)+,28(a1)
	move    (a0),32(a1)
	endc

	ifgt    channels-3
	move.l  P61_Sample+P61_temp3(pc),a0
	addq.l  #6,a0
	move.l  (a0)+,44(a1)
	move    (a0),48(a1)
	endc

	ifne    system
	ifne    CIA
	lea     P61_server(pc),a3
	clr     (a3)
	move.l  P61_craddr+4(pc),a0
	move.b  P61_tlo(pc),(a0)
	move.b  P61_thi(pc),$100(a0)
	endc
	bra     P61_ohi
	endc

	ifeq    system
	ifne    CIA
	move.l  P61_vektori(pc),a0
	move.l  P61_tintti(pc),(a0)
	endc
	movem.l (sp)+,a0/a1
	nop
	rte
	endc

P61_temp0       dcb.b   Channel_Block_SIZE-2
		dc      1

P61_temp1       dcb.b   Channel_Block_SIZE-2
		dc      2

P61_temp2       dcb.b   Channel_Block_SIZE-2
		dc      4

P61_temp3       dcb.b   Channel_Block_SIZE-2
		dc      8

P61_cn          dc      0
P61_dma         dc      $8200
P61_rowpos      dc      0
P61_slen        dc      0
P61_speed       dc      0
P61_speed2      dc      0
P61_speedis1    dc      0
P61_spos        dc.l    0

	ifeq    system
P61_vektori     dc.l    0
P61_oldlev6     dc.l    0
	endc

P61_ofilter     dc      0
P61_timers      dc.l    0

	ifne    CIA
P61_tintti      dc.l    0
P61_thi         dc.b    0
P61_tlo         dc.b    0
P61_thi2        dc.b    0
P61_tlo2        dc.b    0
P61_timer       dc.l    0
	endc

	ifne    P61_pl
P61_plcount     dc      0
P61_plflag      dc      0
P61_plreset     dc      0
P61_plrowpos    dc      0
P61_looppos     dcb.b   12*channels
	endc

	ifne    P61_pde
P61_pdelay      dc      0
P61_pdflag      dc      0
	endc

P61_samples     dcb.b   16*31
P61_emptysample dcb.b   16
P61_positionbase dc.l   0
P61_possibase   dc.l    0
P61_patternbase dc.l    0
P61_intaddr     dc.l    0

	ifne    system
P61_server      dc      0
P61_miscbase    dc.l    0
P61_audioopen   dc.b    0
P61_sigbit      dc.b    -1
P61_ciares      dc.l    0
P61_craddr      dc.l    0,0,0
P61_dat         dc      $f00
P61_timerinterrupt dc   0,0,0,0,127
P61_timerdata   dc.l    0,0,0
P61_timeron     dc      0
P61_allocport   dc.l    0,0
		dc.b    4,0
		dc.l    0
		dc.b    0,0
		dc.l    0
P61_reqlist     dc.l    0,0,0
		dc.b    5,0
P61_allocreq    dc.l    0,0
		dc      127
		dc.l    0
P61_portti      dc.l    0
		dc      68
		dc.l    0,0,0
		dc      0
P61_reqdata     dc.l    0
		dc.l    1,0,0,0,0,0,0
		dc      0
P61_audiodev    dc.b    'audio.device',0

P61_cianame     dc.b    'ciab.resource',0
P61_timeropen   dc.b    0
P61_timerint    dc.b    'P61_TimerInterrupt',0,0
	endc
P61_etu


******** END OF BINARY FILE **************
;;;

		   Section   chipdata,DATA_C     ;must lie in chipmem

;;; "Dummy Copperlist"
DummyCopper:
		   Dc.w      $0180,$0000
		   IFND      noexample
		   Dc.w      $6c01,$fffe
		   Dc.w      $0180,$0499
		   Dc.w      $7c01,$fffe
		   Dc.w      $0180,$0555
		   ENDC
		   Dc.w      $ffff,$fffe

SpriteDummy:       Dc.l      0,0,0,0
;;;
;;; "Nasty Tune (Including sample data and buffer)"
P61_data:          Incbin    "!intro:loader/P61.mountai"
			     ;GLึM INTE ฤNDRA SAMPLEBUFFERN!!!
			     ; + USECODEN!!!!ฒ

		   Section chipbss,bss_c
samples:           Ds.b      4732
				       ;Uncomment if you have packed samples
				       ;and insert sample buffer length.
;;;
