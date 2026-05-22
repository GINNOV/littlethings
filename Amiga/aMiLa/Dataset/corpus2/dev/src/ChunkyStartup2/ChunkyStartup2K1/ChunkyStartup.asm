;  /    +-----------------------------------------------+   /
; /    /                                               /   /
;/    /                 LINKABLE                      /   /
;    /     Chunkygraphics startup by krabob in 2001  /   /
;   /         a lot Based on Merko's work.          /   /
;  /                                               /   /
; /                                               /   /
;+-----------------------------------------------+   /
; ChunkyStartup.asm
; 23.04.2001
;
; Linkable version, see test.c for example of use
;
;
;       phxass ChunkyStartup.asm I=include: M=68030 TO Chunkystartup.o
;
;
; Sets up a 8Bits chunky screen for you to play around with. :)
;  Now support AGA & CGX with no need of RTG libs !
;   (And by the way, Picasso Systems which emulates CGX !)
;
; Feel free to use this code for whatever you like!
;
;
;
; Features:     · fully OS-legal and multitasking. Try Amiga+M !!
;               · allows the user to select 8bit screenmode
;               · triplebuffering -on aga
;               · puts up a nice errormessage if something goes wrong
;               . AGA-CGX compatible
;               . new 1999 M.Kalms 'scout' c2p to handle all AGA resolutions.
;               . Nice entairtainning and humorous comments
;               . Test both mouse buttons OR "escape" key to quit.
;               . Tested on A1200+AGA+CGXBVision
;               . Tested with MuForce for Hits.
;               . dos.library,graphics.library,intuition,asl already opened
;               . Usable in C or asm, provided with .o and vbcc's .h
;               . some goodies functions to handle memory
;
; Still to do:
;               .Some library base name may not be correct (not tested)
;               .
;
;
; Never forget:
; " The Leviathan's dog has been digivolved into a dead dog. "
;
;--------------------------------------------------------------------+
; The Chunky-to-planar routine is made by M. Kalms.
;
; Comments or questions can be sent to me at
; krabob@online.fr     Krabob.
;
; Merko is *NOT* to be blame for Krabob's bullshits :-)
;
;--------------------------------------------------------------------+
;
; Note that my Assembler (devpac then phxass) was configured non
; case-sensitive:
; the default type must be .w
; The aim was to be clear, not Optimisation.
;
; About the AGA c2p:
; In the Old version, the c2p used could only be performed on
; screens which planes was allocated contiguously, We were forced
; to alloc 8 bitplanes ourselves, create our own bitmap structures,
; and use "ChangeVPBitMap" for triple-buf.
; now that the new c2p only ask for any BitMap struct with
; uncontiguous planes, we only use AllocScreenBuffer and 
; ChangeScreenBuffer for switching screens under AGA.
;--------------------------------------------------------------------+
;
; Note for people that never coded OS-like:
; Using OS-legal Code, you are STRONGLY URGED to:
;       - Use   "call LoadRGB32" from graphics.library to change your
;         palette! look the "graphics" autodoc for a RGB32 format 
;         description. 
;
;       - You can find an AGA Mode by its ModeID, but you can't with
;          CGX screens !!!
;          Use: cybergraphics.library/BestCModeIDTagList
;          to find a CGX ID that fits to your need.        
;           (this method is implemented)

; Feel free to use these codes for whatever you like!

;    +------------------------------------------------------------+
;   /                                                            /
;  /                    Constants Definition                    /
; /                                                            /
;+------------------------------------------------------------+

Own_Dosbase     EQU     0   ; used with a startup.o, DOSBase is already opened.
                            ;setting this to 1 will create&open DOSBase by itself


;    +------------------------------------------------------------+
;   /                                                            /
;  /            Export Useful vars&functions for other modules  /
; /                                                            /
;+------------------------------------------------------------+

        ;-----------------------  libraries opened or not
        XDEF    _Execbase
        XDEF    Execbase

        XDEF    _GfxBase
        XDEF    GfxBase

        XDEF    _IntuitionBase


        IFNE    Own_Dosbase
            XDEF    _DOSBase
        ENDC
        IFEQ    Own_Dosbase
            XREF    _DOSBase
        ENDC

        XDEF    _Aslbase
        XDEF    Aslbase

        XDEF    _Cgxbase
        XDEF    Cgxbase

        ;----------------------- Simple function to use

        ;---- Open all libs, screen stuffs, reset chrono,... return bool
        XDEF    _ChunkyStartupInit
        XDEF    ChunkyStartupInit

        ;---- Close everything opened by...ChunkyStartupInit Display error message if needed.
        XDEF    _ChunkyStartupClose
        XDEF    ChunkyStartupClose

        ;---- Memory handling tools
        XDEF    _AllocRmb
        XDEF    AllocRmb

        XDEF    _LoadRmb
        XDEF    LoadRmb

        ;---- ASk a Screen chunk with good size
        XDEF    _Allocatechunkyforscreen
        XDEF    Allocatechunkyforscreen

        ;----- ask a sure 1/50sec clock from demo start
        XDEF    _GetTaskTime
        XDEF   GetTaskTime

        XDEF    _ResetTaskTime
        XDEF    ResetTaskTime

        ;---- refresh the screen with your chunky screen ScreenWidth * ScreenHeight large.
        ;//     extern  void    ScreenRefresh(UBYTE *ChunkyBuffer);
        XDEF    _ScreenRefresh
        XDEF    ScreenRefresh

        XDEF    _SetScreenPalette
        XDEF    SetScreenPalette
        ;---- Check intuition port's mouse and esckey. return bool (?)
        XDEF    _ListenEnd
        XDEF    ListenEnd

        XDEF    _Exitmessage
        XDEF    Exitmessage

        ;----------------------- Static final datas...
        XDEF    _ScreenWidth            ; extern int ScreenWidth
        XDEF    ScreenWidth
        
        XDEF    _ScreenHeight
        XDEF    ScreenHeight

        ; The window
        XDEF    _TheWindow
        XDEF    TheWindow

        ;The Screen
        XDEF    _TheScreen
        XDEF    TheScreen

;    +------------------------------------------------------------+
;   /                                                            /
;  / AmigaOS Functions Offsets To Libraries and Constants Tags  /
; /                                                            /
;+------------------------------------------------------------+

;       incdir  Includes:Osin/  ;Set this to wherever you have your
                                ;OS-includes.(merko)

        incdir  Include:        ;Krabob's OS-includes. place.

        include exec/types.i                    ;
        include exec/libraries.i                ;libraries structures (for?)
        include exec/memory.i                   ;allocmem flags

        include intuition/screens.i             ;
        include intuition/intuitionbase.i       ; to get "frontmost" screen



        include dos/dostags.i
        include libraries/dosextens.i
        include libraries/asl.i
        include libraries/exec_lib.i
        include libraries/asl_lib.i
        include libraries/dos_lib.i
        include libraries/graphics_lib.i
        include libraries/intuition_lib.i

        include devices/timer.i
        include devices/timer_lib.i
                                                ;or set them in your
        include cybergraphics.i                 ;include:cybergraphics/
        include cybergraphics_lib.i             ;include:libraries/



;    +------------------------------------------------------------+
;   /                                                            /
;  /                    Useful Macros                           /
; /                                                            /
;+------------------------------------------------------------+

call            macro
                jsr     _LVO\1(a6)
                endm
;  +---------------------------------------------+
; /             Our Own allocremember cell      /
;+---------------------------------------------+
 STRUCTURE csac,0
        APTR    csac_NextAlmCell
        ULONG   csac_WholeSize
        ULONG   csac_ChunkSize;
        APTR    csac_Buffer;
 LABEL  csac_SIZEOF



;    +------------------------------------------------------------+
;   /                                                            /
;  /                                                            /
; /                                                            /
;+------------------------------------------------------------+

        section fastkod,code_f

        cnop    0,4     ;align to 4.

;------------------------------------------------------------------
;    /+===================================================+/
;   //                                                   //
;  //           Init all shrdlibs,screen and timer      //
; //                                                   //
;/+===================================================+/
_ChunkyStartupInit
ChunkyStartupInit
        movem.l d1-d7/a0-a6,-(sp)

        ;------- keep the width-height parameters
        movem.l  d0-d1,-(sp)

        ;  +---------------------------------------------+
        ; /  Go Open All needed & Optional libs         /
        ;+---------------------------------------------+
        move.l  4,Execbase
        bsr.w   OpenLibs
        movem.l (sp)+,a3-a4
        tst.l   d0
        beq.w   .bad

        ;  +---------------------------------------------+
        ; /     Find Best Screen ModeID                 /
        ;+---------------------------------------------+
        ;a3 a4 are x length ,y length
        bsr.w   FindaGoodModeID ;not tested for failure

        ;   +---------------------------------------------+
        ;  /  First Open an ASL screen requester...      /
        ; /  Open Screen... Whatever AGA/CGX it is      /
        ;+---------------------------------------------+
        bsr.w   OpenIntuitionscreen
        tst.l   d0
        beq.w   .bad

        ;  +---------------------------------------------+
        ; /  Set demo time                              /
        ;+---------------------------------------------+
        jsr     _ResetTaskTime

        move.l  #0,Exitmessage  ;OK
        moveq.l #-1,d0          ;OK
.bad
        ;d0 is ok if !=0
        movem.l (sp)+,d1-d7/a0-a6       ;//return to C :-)
        rts

;    /+===================================================+/
;   //                                                   //
;  //   Perform Right refresh pass...                   //
; //                                                   //
;/+===================================================+/
_ScreenRefresh
ScreenRefresh
; a0 is chunky screen with right size.
; Stack everything for API Compliance.
        movem.l d0-d7/a0-a6,-(sp)

        ;========= This Func Go perform the ===========
        ;=== Right copy on the Right Hardware ====== 
        ;= From Chunky Screen To a Hidden HARD Screen =

        tst.b   CGXBool
        beq.b   .noCGXRefresh

                move.l  a0,a5   ;Chunky temporized.
                
                ;=== Only draw if screen is frontmost
                move.l  Intuibase,a6
                move.l  ib_FirstScreen(a6),a6   ;frontmost
                move.l  TheScreen,a0
                cmpa.l  a6,a0
                bne.s   .endRefresh

                        ;=== BitMap Locking in order to find
                        ;=== Hardware chunky address & modulo.
                        move.l  Cgxbase,a6              ; !=0

                        move.l  TheScreen,a0
                        move.l  sc_RastPort+rp_BitMap(a0),a0    

                        lea     LockTAG,a1
                        call    LockBitMapTagList
                        beq     .endRefresh
                        move.l  d0,d7
                        move.l  CgxBaseAddress,a1       ; Chunky hardware

                        move.l  a5,a0
                        move.l  _ScreenWidth,d0
                        move.l  _ScreenHeight,d1
                        move.l  CgxBytesPerRow,d2       ; ScreenModulo in bytes.
                        jsr     c2c1x1_cpu              ; Chunky to Chunky...

                ;=== Unlock. 
                move.l  d7,d0
                move.l  Cgxbase,a6              ; !=0
                move.l  d0,a0
                call    UnLockBitMap


.nocgx
        bra.b   .noAGARefresh
.noCGXRefresh
                ;a0 chunky screen.

                ; d0.w  chunkyx [chunky-pixels]
                ; d1.w  chunkyy [chunky-pixels]
                ; d2.w  offsx [screen-pixels]
                ; d3.w  offsy [screen-pixels]
                ; a0    chunkyscreen
                ; a1    BitMap

                move.l  _ScreenWidth,d0
                move.l  _ScreenHeight,d1
                clr.w   d2
                clr.w   d3

                move.l  LogicSt,a1              ;ScreenBuffer
                move.l  sb_BitMap(a1),a1        ;BitMap
                jsr     _c2p1x1_8_c5_bm


                ;// FALSE: now only for aga.
                ;== This Func is a part of the triple-buffer ==
                ;=== It validates the freshly drawn-screen ====
                ;=== to APPEAR at next frame 
                ; (same for AGA and CGX.)
                bsr.w   ScreenSwap

.noAGARefresh
.endRefresh
        movem.l (sp)+,d0-d7/a0-a6       ;//return to C :-)
        rts
;    /+===========================================================+/
;   //                                                           //
;  //   Chunky To Chunky. Width must be multiple of 32 bytes    //
; //    (as on aga versions)                                   //
;/+===========================================================+/
c2c1x1_cpu
;a0 source
;a1 dest.
;d0 width
;d1 height
;d2 modulo

        ; this "copy" function pay attention to the screen "modulo".

        asr.l   #5,d0
        subq.l  #1,d0

        subq.l  #1,d1
bcl_copyCGx_Y
                move.l  a1,a2
                move.w  d0,d3
bcl_copyCGx_X
                        rept    8
                        move.l  (a0)+,(a2)+     ;waaaaaaaa.
                        endr

                dbf.w   d3,bcl_copyCGx_X
                add.l   d2,a1
        dbf.w   d1,bcl_copyCGx_Y

        rts
;    /+===================================================+/
;   //                                                   //
;  //   Triple-Buffer Swap Screen.                      //
; //                                                   //
;/+===================================================+/

ScreenSwap



;       tst.b   BuffersSwapped          ;If we already swapped buffers
;       beq     .dontwait               ;this VBL, it would be silly to
;       move.l  GfxBase,a6              ;remove the buffer that has not
;       call    WaitTOF                 ;been shown yet!
;.dontwait      ; clearly: do WaitTOF only if drawing is speeder than frame rate!
        ; remplacer ça.



        move.l  GfxBase,a6
        call    WaitBlit                ;safer before ChangeScreenBuffer

        move.l  TheScreen,a0
        move.l  LogicSt,a1
        move.l  Intuibase,a6
        call    ChangeScreenBuffer

        move.l  LogicSt,a1              ; is a nice OS Function
        move.l  PhysicSt,LogicSt        ; To make Double/triple buffer.
        move.l  NextSt,PhysicSt
        move.l  a1,NextSt
        
        st.b    BuffersSwapped
        move.l  LogicBM,d3
        move.l  PhysicBM,LogicBM
        move.l  NextBM,PhysicBM
        move.l  d3,NextBM

        rts     

;    /+===================================================+/
;   //                                                   //
;  //   Listen for mouse or keyboard"ESC" to stop       //
; //                                                   //
;/+===================================================+/
_ListenEnd
ListenEnd
       movem.l d1-d7/a0-a6,-(sp)


;note: stack registers for full system-reuse.

        move.l  Execbase,a6
        move.l  TheWindow,a0
        move.l  wd_UserPort(a0),a0              ;Window's msgport to a0
        call    GetMsg                          ;Get message about whether
        tst.l   d0                              ;mouse is clicked in window.
        beq.b   .no_Interactivity               ;test for escape key too !

        move.l  d0,a1
        move.l  im_Class(a1),d6
        move.w  im_Code(a1),d7          ;we keep that.
        call    ReplyMsg                ;a valid GetMsg must ALWAYS     
                                        ;be followed by a ReplyMsg.
        ;--- mouse button
        cmp.l   #IDCMP_MOUSEBUTTONS,d6
        bne.s   .nomouse_Int

        cmp.b   #$68,d7
        bne.s   .no_LMB
        moveq.l #-1,d0
        bra.s   .end
.no_LMB

        cmp.b   #$69,d7
        bne.s   .no_RMB
        moveq.l #-1,d0
        bra.s   .end
.no_RMB
.nomouse_Int
;---------------- escape key
        cmp.l   #IDCMP_RAWKEY,d6
        bne.s   .nokeyboard_Int

        cmp.b   #$45,d7         ;ESC
        bne.s   .no_EscKey
        moveq.l #-1,d0
        bra.s   .end
.no_EscKey
.nokeyboard_Int
.no_Interactivity

; return 0 if quiet.
        moveq.l #0,d0
.end
        movem.l (sp)+,d1-d7/a0-a6       ;//return to C :-)
        rts     
;    /+===================================================+/
;   //                                                   //
;  //           Very Simple Palette Loading..           //
; //                                                   //
;/+===================================================+/
_SetScreenPalette
SetScreenPalette
            movem.l d0-d7/a0-a6,-(sp)

        ;a0 palette
        move.l  a0,a1
        move.l  GfxBase,a6
        move.l  TheScreen,a0
        add.l   #44,a0          ;Screen->ViewPort
        call    LoadRGB32       ;Load a standard LoadRGB32 palette

            movem.l (sp)+,d0-d7/a0-a6       ;//return to C :-)
        rts
;    /+===================================================+/
;   //                                                   //
;  //     Reset our task date                           //
; //                                                   //
;/+===================================================+/
_ResetTaskTime
ResetTaskTime
                movem.l d0-d7/a0-a6,-(sp)


        lea     StartTimeVal,a0

        move.l  TimerDev,a1
        move.l  IO_DEVICE(a1),a6    ;just to get the base !
        call    GetSysTime


.fail
                movem.l (sp)+,d0-d7/a0-a6
        rts
;    /+===================================================+/
;   //                                                   //
;  //     Find an exact synchro date from start         //
; //                                                   //
;/+===================================================+/
_GetTaskTime
GetTaskTime
                movem.l d1-d7/a0-a6,-(sp)

        ; void GetSysTime( struct timeval * ); A0 dest. left unchanged
        ;  TimerBase = tr->tr_node.io_Device;
        ;  GetSysTime(tv);

        lea     NowTimeVal,a0

        move.l  TimerDev,a1
        move.l  IO_DEVICE(a1),a6    ;just to get the base !
        call    GetSysTime

        ;a0 is a0
        lea     StartTimeVal,a1     ;source
        call    SubTime             ;Now-start

        ;------------ make Timeval more useful -> 1/50 hz
        ; *50 +
        ; 1000000
        ;  1000 000 -> 50
        move.l  TV_SECS(a0),d0
        move.l  TV_MICRO(a0),d1     ;[0,999999]=1 sec.
        muls.l  #50,d0
        divs.l  #20000,d1                   ;Sorry !
        add.l   d1,d0
;        SubTime( Dest, Source )
;                 A0    A1
;
;        void SubTime( struct timeval *, struct timeval *);
;
;   FUNCTION
;        This routine subtracts one timeval structure from another.  The
;        results are stored in the destination (Dest - Source -> Dest)
;
;        A0 and A1 will be left unchanged
;StartTimeVal    dcb.b   TV_SIZE,0   ;just 8 bytes :-)
;NowTimeVal      dcb.b   TV_SIZE,0   ;just 8 bytes :-)


.fail
                movem.l (sp)+,d1-d7/a0-a6
        rts
;    /+===================================================+/
;   //                                                   //
;  //       Load a file in an auto -freed memory        //
; //                                                   //
;/+===================================================+/
_LoadRmb
LoadRmb
                movem.l d1-d7/a0-a6,-(sp)

;a0 should be STPTR to 0-ended dosname

        ;---------------- open file handler
        move.l  a0,d1
        move.l  #MODE_OLDFILE,d2
        move.l  _DOSBase,a6
        call    Open
        tst.l   d0
        beq.s   .fail
        move.l  d0,a5       ;a5 file handler

        ;---------------- alloc a temp file info struct
        move.l  #fib_SIZEOF,d0
        move.l  Execbase,a6
        move.l  #MEMF_CLEAR,d1
        call    AllocMem
        tst.l   d0
        beq.s   .fail
        move.l  d0,a4       ;a4 fib*

        ;----------------- Find file size
;;;        move.l  #EMTEST,Exitmessage
        move.l  a5,d1
        move.l  a4,d2
        move.l  _DOSBase,a6
        call    ExamineFH       ;0=nogood
        tst.l   d0
        beq.s   .fail
        move.l  fib_Size(a4),a3
        move.l  a3,Arglist

        ;---------------- free temp file info
        move.l  a4,a1
        move.l  #fib_SIZEOF,d0
        move.l  Execbase,a6
        call    FreeMem

        ;---------------- alloc file buffer (auto-freed)
        move.l  a3,d0
        jsr     _AllocRmb
        tst.l   d0
        beq.s   .fail
        move.l  d0,a4
        ;---------------- load file in buffer
        move.l  a5,d1   ;handler
        move.l  d0,d2   ;buffer
        move.l  a3,d3   ;size
        move.l  _DOSBase,a6
        call    Read

        ;---------------- close handler
        move.l  a5,d1
        call    Close
                ;Hdl= Open(path,MODE_OLDFILE) (check)
                ;ExamineFH(hdl,&fib) (check)
                ;alloc (fib.fib_Size)
                ;read(hdl,buffer,size)
                ;if ok close(hdl)

        move.l  a4,d0
        sub.l   #csac_SIZEOF,d0  ;give the structure first so we can get the size.

        bra.s   .ok
.fail
        moveq.l    #0,d0
.ok
                movem.l (sp)+,d1-d7/a0-a6
        rts
;    /+===================================================+/
;   //                                                   //
;  //           Allocate a allocremenber cell           //
; //                                                   //
;/+===================================================+/
_AllocRmb
AllocRmb
                movem.l d1-d7/a0-a6,-(sp)

;In: d0=size
;

        move.l  d0,d6
        add.l   #csac_SIZEOF,d0
        move.l  d0,d7

        move.l  Execbase,a6
        move.l  #MEMF_CLEAR,d1
        call    AllocMem
        tst.l   d0
        beq.b   .fail
                move.l  d0,a1                   ;chain.
                move.l  FirstAlmCell,a0
                move.l  a0,csac_NextAlmCell(a1)
                move.l  a1,FirstAlmCell
                move.l  d6,csac_ChunkSize(a1)
                move.l  d7,csac_WholeSize(a1)
                add.l   #csac_SIZEOF,d0  ;point chunk itself.
                move.l  d0,csac_Buffer(a1)
        ;// return pointer on the start of the chunk *ubyte.

.fail
                movem.l (sp)+,d1-d7/a0-a6
        rts
;    /+===================================================+/
;   //                                                   //
;  //           Free all allocremenber cell             //
; //                                                   //
;/+===================================================+/
_FreeAllRmb
FreeAllRmb
                movem.l d0-d7/a0-a6,-(sp)

        move.l  Execbase,a6
        move.l  FirstAlmCell,a5

.startfree
        tst.l   a5
        beq.s   .endfreeallrmb


                move.l  csac_NextAlmCell(a5),a4

                        move.l  a5,a1
                        move.l  csac_WholeSize(a5),d0
                        call    FreeMem
 
                move.l  a4,a5

        bra.s   .startfree      
.endfreeallrmb
                movem.l (sp)+,d0-d7/a0-a6

        rts
;    /+===================================================+/
;   //                                                   //
;  //           Allocate Chunky Screen                  //
; //                                                   //
;/+===================================================+/
_Allocatechunkyforscreen
Allocatechunkyforscreen
                movem.l d1-d7/a0-a6,-(sp)
; use other function chainalloc

        move.l  Execbase,a6

        move.l  _ScreenWidth,d0
        move.l  _ScreenHeight,d1
        muls.w  d1,d0   

        jsr     _AllocRmb

;       move.l  d0,4+ChunkyScreen       ;Save size here to avoid mistakes..
;       move.l  #0,d1
;       call    AllocMem
;       tst.l   d0
;       beq.b   .fail
;       move.l  d0,ChunkyScreen

                movem.l (sp)+,d1-d7/a0-a6       ;//return to C :-)
.fail
        rts
;    /+===================================================+/
;   //                                                   //
;  //           A OS-legal test for aga hardware        //
; //(not interesting)                                  //
;/+===================================================+/
Checkspecs
        move.l  GfxBase,a6
        btst    #2,$ec(a6)      ;test for AGA
        rts
;    /+===========================================================+/
;   //                                                           //
;  //   Open all Needed Libraries and Try Optional Ones.        //
; //                                                           //
;/+===========================================================+/
OpenLibs

        ;==== Exec Always needed !
        move.l  #EM0,Exitmessage
        move.l  Execbase,a6
        move    #39,d0          ;version
        lea     IntName,a1
        call    OpenLibrary
        move.l  d0,Intuibase
        tst.l   d0
        beq     .fail

        ;==== Dos needed for VBL task (NO MORE VBLTASK).
        ;==== dos always needed.
        IFNE    Own_Dosbase
            move.l  #EM1,Exitmessage
            move    #36,d0          ;version
            lea     DosName,a1
            call    OpenLibrary
            move.l  d0,_DOSBase
            tst.l   d0
            beq     .fail
        ENDC
        ;==== ASL needed for screen request.
        move.l  #EM2,Exitmessage
        move    #36,d0          ;version
        lea     _AslName,a1
        call    OpenLibrary
        move.l  d0,Aslbase
        tst.l   d0
        beq.b   .fail

        ;==== Graphics always needed.
        move.l  #EM3,Exitmessage
        move    #39,d0          ;version
        lea     GraName,a1
        call    OpenLibrary
        move.l  d0,GfxBase
        tst.l   d0
        beq.b   .fail

        ;==== Cybergraphics.library can be here or NOT !!
        ;==== if d0 = 0, CGX Screens are impossible.
        move    #39,d0          ;version number was not checked.
        lea     Cgxname,a1      ;"39" must work for CGX3 and 4.
        call    OpenLibrary
        move.l  d0,Cgxbase      ;can not cause error.

        ;===== we MUST open timer.device to synchronise the scripts. 
        ; OpenDevice("timer.device",0L, (struct IORequest *) AudioIO ,0L);

        ;== alloc some iorequest

        ;error = OpenDevice(devName, unitNumber, iORequest, flags)
        ;D0                A0       D0          A1         D1

        move.l  #IOTV_SIZE,d0   ;size of "iorequest for timer device" structure.
        jsr     _AllocRmb
        tst.l   d0
        beq.s   .fail
        move.l  d0,TimerDev
        move.l  d0,a1
        
        move.l  Execbase,a6
        lea     Timername,a0
        move.l  #UNIT_MICROHZ,d0        ; It has precision down to about 2 microseconds,...
        clr.l   d1      
        call    OpenDevice
        move.l  d0,TimerDevResult       ;used for closing
        tst.l   d0                      ; 0 if successful
        beq     .nodevice
                clr.l   d0
        bra.s   .yesdevice
.nodevice
                moveq.l #-1,d0  
.yesdevice


;Note: if CGX is not present, 0 is returned as base.
; It can be a nice way to decide if the screen will be
; AGA or CGX.
;
.ok
        moveq.l #-1,d0          ;no error!!!
.fail
        rts
;    /+===========================================================+/
;   //                                                           //
;  //   Find The Best Screen Mode Id. 2 METHODS AVAILABLE !!    //
; //                                                           //
;/+===========================================================+/
FindaGoodModeID
;
; we seek ModeID and a screen size..
;
   ;---------- a3 a4 width,height
   ; if a0 =0 , asl used.


        ;  +---------------------------------------------+
        ; /     METHOD1: ASL REQUESTER                  /
        ;+---------------------------------------------+

;;        IFNE    Mode_by_ASL
        tst.l   a3
        bne.s   .notbyasl

                move.l  Aslbase,a6
                move.l  #2,d0           ;ASL_ScreenModeRequest=2
                lea     Screenrequesttaglist,a0
                call    AllocAslRequest ;Set up a screenmoderequester

                ; return d0: pointer on STRUCTURE ScreenModeRequester

                move.l  d0,d7
                move.l  d0,a0
                move.l  #0,a1
                move.l  Aslbase,a6
                call    AslRequest      ;Put up the requester
                tst.l   d0
                beq.w   .fail
                move.l  d7,a0
                move.l  sm_DisplayID(a0),4+Screentaglist        ;We want the ModeID.
                                                        ;Other info can be
                                                        ;get from sm_...                
;--- bug: READing WIDTH/HEIGHT From THIS STRUCT FAIL
;--- WHEN ID SELECTED BY KEYS. (magic asl patch i guess)
                move.l  sm_DisplayWidth(a0),d0
                and.l   #$ffffffe0,d0           ;we want a multiple of 32 in width.
                move.l  d0,_ScreenWidth
                move.l  sm_DisplayHeight(a0),_ScreenHeight

                ; we get screen width and height given by ASL.

                ;--------- give the size to NewScreen.
                move.l  _ScreenWidth,d0         ;already 32 pxl aligned.
                move.l  _ScreenHeight,d1

                lea     CoolScreen,a1
                move.w  d0,ns_Width(a1)
                move.w  d1,ns_Height(a1)

                move.l  Aslbase,a6          ;bug if not (?)
                call    FreeAslRequest          ;The requester must be freed
                                               ;don't read the struct after that!
                bra.w   .nomethod2
.notbyasl

        ;  +---------------------------------------------+
        ; /     METHOD2: ASK BY A RESOLUTION            /
        ;+---------------------------------------------+
        ; In that case, the function to use are not the same
        ;on AGA and CGX.

                tst.l   Cgxbase
                bne.s   .askforcgx
.askforaga
                move.l  a3,BestIDTag+4      ;corrected by dejko
                move.l  a4,BestIDTag+12

                move.l  GfxBase,a6
                lea     BestIDTag,a0
                call    BestModeIDA
                cmp.l   #INVALID_ID,d0
                beq     .fail
                move.l  d0,4+Screentaglist

                lea     CoolScreen,a0
                move.w  a3,ns_Width(a0)
                move.w  a4,ns_Height(a0)

                bra.s   .asknocgx
.askforcgx              
                move.l  Cgxbase,a6
                lea     BestCGXIDTag,a0
                move.l  a3,4(a0)
                move.l  a4,12(a0)
                call    BestCModeIDTagList      ;very different isn't it ?
                cmp.l   #INVALID_ID,d0
                beq.s   .fail
                move.l  d0,4+Screentaglist


                ; We define the opened CGX screen to take
                ; all the screen width and height
                ; if not, it happens strange things sometimes
                ; using Lock/UnlockBitMap.

                move.l  Cgxbase,a6
                move.l  d0,d1
                move.l  #CYBRIDATTR_WIDTH,d0
                call    GetCyberIDAttr
                lea     CoolScreen,a0
                move.w  d0,ns_Width(a0)

                move.l  #CYBRIDATTR_HEIGHT,d0
                move.l  4+Screentaglist,d1
                call    GetCyberIDAttr
                lea     CoolScreen,a0
                move.w  d0,ns_Height(a0)

;       value = GetCyberIDAttr( Attribute, DisplayModeID )
;          D0                       D0            D1


.asknocgx
                                                ;the resolution is fixed but:
                move.l  a3,d0
                and.l   #$ffffffe0,d0
                ;move.l  #Screen_Width&$ffffffe0,d0 ;we want a multiple of 32 in width.
                move.l  d0,_ScreenWidth
                move.l  a4,_ScreenHeight    ;note: highly optimisable


.nomethod2

        moveq.l #-1,d0  ;OK
.fail
        rts
;    /+===========================================================+/
;   //                                                           //
;  //   Open Intuition screen AGA or CGX                        //
; //                                                           //
;/+===========================================================+/
OpenIntuitionscreen

        bsr.w   Allocatepointer         ;We need a blank pointer
        beq.w   .fail                   ; in both AGA and CGX cases.

        ;---- open screen and window
        move.l  Intuibase,a6
        lea     CoolScreen,a0
        lea     Screentaglist,a1
        call    OpenScreenTagList

        move.l  d0,TheScreen
        tst.l   d0
        beq     .fail
        bsr     Opennicewindow
        beq     .fail

;       sbuffer = AllocScreenBuffer( Screen, BitMap, flags )
;       D0                           A0      A1      D0

        ;if CGX present, use...
                ; IsCyberModeID -- returns whether supplied ModeID is a cybergraphics id.
        ;if no cgx libs were found ->AGA
        move.l  Cgxbase,a6
        tst.l   a6
        beq.s   .nocgxpresent

                move.l  4+Screentaglist,d0
                call    IsCyberModeID
                tst.l   d0
                beq.w   .nocgxpresent                   ; if d0 eq, ModeID is not CGX.

                        st.b    CGXBool                 ;will tell if cgx or aga.
                        bra.s   .ok
.nocgxpresent   ;means aga:

        ;---- alloc screenbuffer for actual screen
        move.l  Intuibase,a6
        move.l  TheScreen,a0
        sub.l   a1,a1
        move.l  #SB_SCREEN_BITMAP,d0
        call    AllocScreenBuffer
        beq     .fail
        move.l  d0,ScreenBuf1   ;scructure ScreenBuffer kept for closing
        move.l  d0,NextSt

        ;---- alloc screen 2 for triple buff.
        move.l  Intuibase,a6
        move.l  TheScreen,a0
        sub.l   a1,a1
        moveq.l #0,d0
        call    AllocScreenBuffer
        beq     .fail
        move.l  d0,ScreenBuf2   ;scructure ScreenBuffer kept for closing
        move.l  d0,LogicSt

        ;---- alloc screen 3 for triple buff.
        move.l  Intuibase,a6
        move.l  TheScreen,a0
        sub.l   a1,a1
        moveq.l #0,d0
        call    AllocScreenBuffer
        beq     .fail
        move.l  d0,ScreenBuf3   ;kept for closing
        move.l  d0,PhysicSt

; Now has come the time to check if the Choosen ModeID is aga or CGX.
.ok

        moveq.l #-1,d0          ;OK
.fail
        rts
;    /+===========================================================+/
;   //                                                           //
;  // Allocate a few empty bytes to figure an invisible pointer //
; //                                                           //
;/+===========================================================+/
Allocatepointer
        move.l  GfxBase,a6      ;Even though we don't want the pointer
        move    #8,d0           ;to be visible, we need one.
        move    #8,d1
        move    d0,Mousepointer+4
        move    d1,Mousepointer+6
        call    AllocRaster
        tst.l   d0
        beq.b   .fail
        move.l  d0,Mousepointer
.fail
        rts
;    /+===========================================================+/
;   //                                                           //
;  //   Open an invisible Intuition Window on the whole screen  //
; //                                                           //
;/+===========================================================+/
Opennicewindow
        ;Open a borderless, invisible window, needed to get
        ;some messages and stuff
        lea     TheWindowtaglist,a1
        move.l  TheScreen,4(a1)
        move.l  #0,a0
        move.l  Intuibase,a6
        call    OpenWindowTagList
        tst.l   d0
        beq.b   .fail
        move.l  d0,TheWindow
        move.l  d0,a0
        move.l  Mousepointer,a1
        move.l  #0,d0
        move.l  #1,d1
        move.l  #0,d2
        move.l  #0,d3
        call    SetPointer      ;Switch to invisible pointer
        move.l  #-1,d0
.fail   rts
;    /+===========================================================+/
;   //                                                           //
;  //           Close Intuition Screen                          //
; //                                                           //
;/+===========================================================+/
CloseIntuitionScreen
        tst.l   TheScreen
        beq.b   .noscreen
        move.l  Intuibase,a6
        tst.l   TheWindow
        beq.b   .nowindow
        move.l  TheWindow,a0
        call    CloseWindow
.nowindow
        move.l  Intuibase,a6
        move.l  TheScreen,a0
        call    CloseScreen

.noscreen


        rts

;    /+===========================================================+/
;   //                                                           //
;  //           Close Everything                                //
; //                                                           //
;/+===========================================================+/
_ChunkyStartupClose
ChunkyStartupClose
        movem.l d0-d7/a0-a6,-(sp)


;       tst.b   Interruptrunning
;       beq.s   .nointerrupt
;       move.b  #2,VBLProcessState
;.wait2 cmp.b   #3,VBLProcessState      ; Wait for VBlank process to end.
;       bne.b   .wait2
;.nointerrupt

        ;======= free 3 ScreenBuffer
        tst.l   ScreenBuf1
        beq.b   .nofreeSB1


                move.l  GfxBase,a6
                call    WaitBlit                ;safer before ChangeScreenBuffer
                ;=== reset original buffer
                move.l  TheScreen,a0
                move.l  ScreenBuf1,a1
                move.l  Intuibase,a6
                call    ChangeScreenBuffer

                move.l  GfxBase,a6
                call    WaitBlit
                move.l  Intuibase,a6
                move.l  TheScreen,a0
                move.l  ScreenBuf1,a1
                call    FreeScreenBuffer
.nofreeSB1
        tst.l   ScreenBuf2
        beq.b   .nofreeSB2
                move.l  Intuibase,a6
                move.l  TheScreen,a0
                move.l  ScreenBuf2,a1
                call    FreeScreenBuffer
.nofreeSB2
        tst.l   ScreenBuf3
        beq.b   .nofreeSB3
                move.l  Intuibase,a6
                move.l  TheScreen,a0
                move.l  ScreenBuf3,a1
                call    FreeScreenBuffer
.nofreeSB3

        bsr.w   CloseIntuitionScreen


        ;======== close timer device
        tst.l   TimerDevResult  
        bne.s   .notimerdevice
                move.l  Execbase,a6
                move.l  TimerDev,a1
                call    CloseDevice
.notimerdevice

        ;========= don't close anything using these buffers after that !
        jsr     _FreeAllRmb     ;Deallocate Chunkybuffer?

        tst.l   Mousepointer    ;Deallokera mousepointerbuffer?
        beq.b   .nofreepointer
        move.l  GfxBase,a6
        move.l  Mousepointer,a0 
        move    Mousepointer+4,d0
        move    Mousepointer+6,d1
        call    FreeRaster
.nofreepointer


        ;==== close all opened libraries ====
        move.l  Execbase,a6
        move.l  GfxBase,a1
        tst.l   a1
        beq.s   .nocloseGfxBase
        call    CloseLibrary
.nocloseGfxBase
        IFNE    Own_Dosbase
            move.l  _DOSBase,a1
            tst.l   a1
            beq.s   .nocloseDOSBase
            call    CloseLibrary
.nocloseDOSBase
        ENDC
        move.l  Aslbase,a1
        tst.l   a1
        beq.s   .nocloseAslbase
        call    CloseLibrary
.nocloseAslbase
        ;==== close cgx if opened
        move.l  Cgxbase,a1
        tst.l   a1
        beq.b   .noclosecgx
        call    CloseLibrary
.noclosecgx

        bsr.b   ShowExitmessage ;Show error message, if an error has occured

        ;==== intuition closed in last to show the error message ====
        move.l  Execbase,a6
        move.l  Intuibase,a1
        call    CloseLibrary

        movem.l (sp)+,d0-d7/a0-a6       ;//return to C :-)
        rts
;    /+===========================================================+/
;   //                                                           //
;  //           Show error message in a window !                //
; //                                                           //
;/+===========================================================+/
ShowExitmessage
        move.l  Exitmessage,a0
        tst.l   a0
        beq.b   .noerror

        lea     StringRequester,a1
        move.l  a0,12(a1)
        move.l  #0,a0
        move.l  #0,a2
        lea     Arglist,a3
        move.l  Intuibase,a6
        call    EasyRequestArgs


;       num = EasyRequestArgs( Window, easyStruct, IDCMP_ptr, ArgList )
;       D0                     A0      A1          A2         A3



.noerror
        rts
;    /+===========================================================+/
;   //                                                           //
;  //   Include Chunky2Planar for AGA                           //
; //                                                           //
;/+===========================================================+/
;-------------------- including other code chunks...
 
        include c2p1x1_8_c5_bm.s        ; resolution-free c2p.

;-------------------- Some resolution-free Effect Sections.
;;        include KRotoZoom.i             ; why not a rtz ?

;;mvtRzm          dcb.b    rzm_SIZEOF,0       ; One Struct to handle movement of the Rotozoom.

;-------------------- Some another nice effect.
;;        include KZoomSprite.i
;screencontext           dcb.b   src_SIZEOF,0    ; One Struct to handle screen for the zoom.
;TextureCtxt             dcb.b   ttc_SIZEOF,0    ; Texture must be described for zoomsprite.
;testx1:         dc.l    80
;testx2:         dc.l    160
;testy1:         dc.l    80
;testy2:         dc.l    160

        
;    /+===========================================================+/
;   //                                                           //
;  //                                                           //
; //                                                           //
;/+===========================================================+/

        section fastdata,data_f
StringRequester dc.l    20
                dc.l    0
                dc.l    Reqtitel
                dc.l    EM0
                dc.l    Reqknapp

Arglist         dc.l    0
                dc.l    777
                dc.l    0


Reqtitel        dc.b    "Error!",0
Reqknapp        dc.b    "Ok",0
                cnop    0,4
_Exitmessage
Exitmessage     dc.l    0       ;0 no mess.
EM0             dc.b    "Couldn't open intuition.library",0
EM1             dc.b    "Couldn't open dos.library",0
EM2             dc.b    "Couldn't open asl.library",0
EM3             dc.b    "Couldn't open graphics.library",0
EM4             dc.b    "AGA chipset required",0
EM5             dc.b    "Couldn't open screen",0
EM6             dc.b    "Couldn't allocate chunkybuffer",0

EMTEST  dc.b    "debug: %ld",0

EMD1    dc.b    "bef open",0
EMD2    dc.b    "bef allocfib",0
EMD3    dc.b    "bef findfilesize",0
EMD4    dc.b    "bef free fib",0
EMD5    dc.b    "bef alloc buffer",0
EMD6    dc.b    "bef read",0



                cnop    0,4

;VBLProcessParams
;       dc.l    NP_Entry,VBlankProcess
;       dc.l    NP_Name,VBLProcessname
;       dc.l    NP_Priority,1

;    /+===========================================================+/
;   //                                                           //
;  //   Structure Used to Open the screen                       //
; //                                                           //
;/+===========================================================+/

CoolScreen      dc      0
                dc      0       ;x,y
                dc      0       ; ns_Width
                dc      0       ; ns_Height
                dc      8       ;depth
                dc.b    0       ;col
                dc.b    1       ;col
                dc      0       ;Viewmodes(lores no sprites)
                dc      SCREENQUIET|CUSTOMSCREEN|AUTOSCROLL ;flag
; $14f  ;quiet,custombitmap,customscreen +  I like aga autoscroll :-)

                dc.l    0       ;Font
                dc.l    0       ;Screentitle
                dc.l    0       ;Gadgets
                dc.l    0       ;Bitmap

Screentaglist   dc.l    SA_DisplayID,0
                dc.l    0,0

;    /+===========================================================+/
;   //                                                           //
;  //   ASL Screen request taglist                              //
; //                                                           //
;/+===========================================================+/
Screenrequesttaglist

                dc.l    ASLSM_TitleText
                dc.l    ScreenReqtitle
                dc.l    ASLSM_MinDepth
                dc.l    8
                dc.l    ASLSM_MaxDepth
                dc.l    8
                dc.l    ASLSM_PropertyFlags     ;|We want all native screenmodes
                dc.l    $00000000               ;|except HAM and dualplayfield.
                dc.l    ASLSM_PropertyMask      ;|Without these four lines, only
                dc.l    $8000000e               ;|'common' modes are selectable.
                                                ;|One would think the OS should
                                                ;|sort out modes which don't
                                                ;|support the specified size,
                                                ;|but this doesn't seem to be
                                                ;|the case. :-(

                                                ;CGX note:
                                                ; it's nice like this
                                                ; because only ask 8 bit CGX screen.
                dc.l    0,0
ScreenReqtitle  dc.b    "Select a screenmode.",0
;    /+===========================================================+/
;   //                                                           //
;  //                                                           //
; //                                                           //
;/+===========================================================+/
                cnop    0,4
TheWindowtaglist
                dc.l    WA_CustomScreen
                dc.l    0
                dc.l    WA_Backdrop
                dc.l    -1
                dc.l    WA_Borderless
                dc.l    -1
                dc.l    WA_Activate
                dc.l    -1
                dc.l    WA_RMBTrap              ;we want to quit with RMB too.
                dc.l    -1
                dc.l    WA_ReportMouse
                dc.l    0
                dc.l    WA_SizeGadget
                dc.l    0
                dc.l    WA_DepthGadget
                dc.l    0
                dc.l    WA_CloseGadget
                dc.l    -1
                dc.l    WA_DragBar
                dc.l    0
                dc.l    WA_IDCMP
                dc.l    IDCMP_MOUSEBUTTONS|IDCMP_RAWKEY ;listen mouse+keys

                dc.l    0,0

VBLProcessname  dc.b    'Chunkyexample VBlank process',0
IntName         dc.b    'intuition.library',0
DosName         dc.b    'dos.library',0
_AslName        dc.b    'asl.library',0
GraName         dc.b    'graphics.library',0
Cgxname:        CGXNAME
Timername       TIMERNAME       

                cnop    0,4

_TheScreen
TheScreen       dc.l    0
                dc.l    0
Mousepointer    dc.l    0
                dc.l    0
;TheDBufInfo    dc.l    0
_TheWindow
TheWindow       dc.l    0


_Execbase
Execbase        dc.l    0

_GfxBase
GfxBase         dc.l    0

_IntuitionBase
_Intuibase
Intuibase       dc.l    0

        IFNE    Own_Dosbase
_DOSBase        dc.l    0
        ENDC

_Aslbase
Aslbase         dc.l    0

_Cgxbase
Cgxbase         dc.l    0

FirstAlmCell    dc.l    0       ; our own allocremember chain
TimerDev        dc.l    0       ; our IORequest handler for timer.device 
TimerDevResult  dc.l    0

KeepExitStack   dc.l    0


PhysicSt        dc.l    0       ;...St= pointer to BitMap structure
PhysicBM        dc.l    0       ;...BM= pointer to hard screen BitMap.
NextSt          dc.l    0
NextBM          dc.l    0
LogicSt         dc.l    0
LogicBM         dc.l    0

ScreenBuf1      dc.l    0
ScreenBuf2      dc.l    0
ScreenBuf3      dc.l    0


ScreenWidth     
_ScreenWidth    dc.l    0

ScreenHeight    
_ScreenHeight   dc.l    0

StartTimeVal    dcb.b   TV_SIZE,0   ;just 8 bytes :-)
NowTimeVal      dcb.b   TV_SIZE,0   ;just 8 bytes :-)



; screen lock tag CGX
LockTAG:        ; passed to cgx/LockBitmapTagList
        dc.l    LBMI_BASEADDRESS,CgxBaseAddress
        dc.l    LBMI_BYTESPERROW,CgxBytesPerRow
        dc.l    0,0
CgxBaseAddress:         dc.l    0
CgxBytesPerRow:         dc.l    0

                                ;If no ASL Req used use "bestmode"
                                ;-- TagList passed to BestModeIDA
BestIDTag       dc.l    BIDTAG_NominalWidth,0   ;filled after
                dc.l    BIDTAG_NominalHeight,0
                dc.l    BIDTAG_Depth,8
                dc.l    0,0

BestCGXIDTag    dc.l    CYBRBIDTG_NominalWidth,0    ;filled after
                dc.l    CYBRBIDTG_NominalHeight,0
                dc.l    CYBRBIDTG_Depth,8
                dc.l    0,0


CGXBool                 dc.b    0
BuffersSwapped          dc.b    0

; DIGIMONS SUCKS !!! 
; POKEMONS RULEZ !!!
