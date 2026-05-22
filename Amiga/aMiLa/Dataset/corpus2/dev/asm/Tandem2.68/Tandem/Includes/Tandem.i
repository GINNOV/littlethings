* tandem.library.asm  revision 2.62 3.24.00    *  n.b. See also VERSION in
* Tandem.i            revision 2.62 3.24.00    *  tandem.library section!!
* Front.i             revision 2.62 3.24.00    *  (extract from Tandem.i)

 include 'IncAll.i'        ;get AmigaOS includes & FDs

************************* set what assembled ***************************

xxp_what: EQU  2  ;set:  0=tandem.library  1=front.i  2=tandem.i

* If xxp_what=1, remove all lines from line starting with *####....

************************* data & structures ****************************

 IFNE xxp_what             ;#^1 only assemble this if not in tandem.library

* begin warmup ready to call Program
TLColdstart:
 tst.l (a7)                ;always NE (but tandem sets EQ if debugging)
 sub.l #1024,a7            ;create instance of xxp_tndm
 move.l a7,a4              ;a4 points to xxp_tndm
 seq d7                    ;D7=-1 if debugging, else 0
 ext.w d7

 move.l a7,a6              ;clear the xxp_tndm structure
 add.w #1024,a6
.clrr:
 clr.l -(a6)
 cmp.l a4,a6
 bne .clrr

 move.w d7,xxp_tand(a4)    ;xxp_tand=-1 if debugging, else 0
 move.l a0,xxp_A0D0+0(a4)  ;save CLI parameters addr & len
 move.l d0,xxp_A0D0+4(a4)

 move.l _AbsExecBase,a6
 move.l a6,xxp_sysb(a4)    ;set xxp_sysb
 sub.l a1,a1               ;for current task..
 jsr _LVOFindTask(a6)      ;.. find own Process structure
 move.l d0,a2              ;(A2) = our own Process structure
 tst.l pr_CLI(a2)          ;pr_CLI<>0 if from CLI
 bne.s .cli                ;go if from CLI

 lea pr_MsgPort(a2),a0     ;wait for workbench startup message to arrive
 jsr _LVOWaitPort(a6)
 lea pr_MsgPort(a2),a0     ;get workbench startup message now it's here
 jsr _LVOGetMsg(a6)
 move.l d0,xxp_bnch(a4)    ;remember the message, for replying &c

.cli:
 move.l #strings,xxp_strg(a4)    ;Program must contain 'strings: DC.B 0'

 moveq #-1,d7              ;will be 0 if dos.library < xxp_lver
 lea .dosn,a1              ;open dos.library
 moveq #xxp_lver,d0        ;at least version xxp_lver
 jsr _LVOOpenLibrary(a6)
 move.l d0,xxp_dosb(a4)    ;set dosbase
 bne.s .doso               ;go if dos.library open

 moveq #0,d7               ;signal libraries < version xxp_lver
 moveq #0,d0               ;open earlier dos.library so can report error
 lea .dosn,a1
 jsr _LVOOpenLibrary(a6)
 move.l d0,xxp_dosb(a4)
 beq .kill                 ;go if can't open earlier dos.library (unlikely)

.doso:
 move.l d0,a6              ;ready A6 for dos.library calls
 tst.l xxp_bnch(a4)        ;go if workbench
 bne.s .bench

 jsr _LVOInput(a6)         ;if CLI, xxp_iput = CLI input stream
 move.l d0,xxp_iput(a4)
 jsr _LVOOutput(a6)        ;if CLI, xxp_oput = CLI output stream
 move.l d0,xxp_oput(a4)
 bra.s .both               ;& continue

.bench:
 move.l #.conn,d1          ;if workbench, open a console
 move.l #MODE_NEWFILE,d2
 jsr _LVOOpen(a6)
 move.l d0,xxp_iput(a4)    ;if workbench, xxp_iput = console
 move.l d0,xxp_oput(a4)    ;if workbench, xxp_oput = console
 beq .kill                 ;abort if can't open console (unlikely)

.both:
 tst.w d7                  ;report & quit if dos.library < xxp_lver
 beq .badv

 move.l xxp_sysb(a4),a6    ;open other libraries
 lea .intn,a1
 moveq #xxp_lver,d0
 jsr _LVOOpenLibrary(a6)   ;intuition.library
 move.l d0,xxp_intb(a4)
 beq .badv
 lea .gfxn,a1              ;graphics.library
 moveq #xxp_lver,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,xxp_gfxb(a4)
 beq .badv
 lea .asln,a1              ;asl.library
 moveq #xxp_lver,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,xxp_aslb(a4)
 beq .badv
 lea .gadn,a1              ;gadtools.library
 moveq #xxp_lver,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,xxp_gadb(a4)
 beq .badv

 move.l xxp_dosb(a4),a6    ;CD to progdir, set xxp_cdir
 jsr _LVOGetProgramDir(a6)
 move.l d0,d1
 jsr _LVOCurrentDir(a6)
 move.l d0,xxp_cdir(a4)    ;save aboriginal CD
 move.l xxp_sysb(a4),a6

 IFEQ xxp_what-1           ;#^2  Only open tandem.library if in Front.i
 lea .tann,a1
 moveq #xxp_tver,d0
 jsr _LVOOpenLibrary(a6)
 bsr .abdir
 move.l d0,xxp_tanb(a4)
 beq.s .badt               ;quit if can't
 ENDC                      ;^2

 IFEQ xxp_what-2           ;#^3    ;} (dummy xxp_tanb if in tandem.i)
 move.l #TLEndcode+24,xxp_tanb(a4) ;} (as if in tandem.library)
 bsr .abdir
 ENDC                      ;#^3

 move.l 1028(a4),d0        ;get val above root of stack (=size if CLI)
 sub.l #1036,d0            ;adjust for Front.i usage
 move.l d0,-(a7)           ;put CLI stack size above return addr of Program
 move.l xxp_A0D0+0(a4),a0  ;restore A0,D0 as called (meaningful if CLI)
 move.l xxp_A0D0+4(a4),d0
 jsr Program               ;* do user program (A4=xxp_tndm, A6=xxp_sysb)
 addq.l #4,a7              ;slough stack size

 move.l a7,a4              ;reload A4 with xxp_tndm
 bsr .abdir                ;back to aboriginal CD (if changed by Program)
 move.l xxp_tanb(a4),a6
 jsr _LVOTLWclose(a6)      ;call TLWclose (closes everything in xxp_tndm)
 moveq #0,d0               ;signal ok
 tst.w xxp_ackn(a4)
 beq .wrap                 ;ok if ack=0

 move.l #.brep,d2          ;else, wait for acknowledge, return bad
 move.l #.dosn-.brep,d3
 bra.s .bad

.badt:                     ;branch here if can't open tandem.library
 move.l #.trep,d2
 move.l #.lrep-.trep,d3
 bra.s .bad

.badv:                     ;branch here if library version < xxp_lver
 move.l #.lrep,d2
 move.l #.dosn-.lrep,d3

.bad:
 move.l xxp_oput(a4),d1    ;send error message
 move.l xxp_dosb(a4),a6
 jsr _LVOWrite(a6)
 move.l a4,d2              ;wait for acknowledge
 moveq #10,d3
 move.l xxp_iput(a4),d1
 jsr _LVORead(a6)

.kill:
 moveq #-1,d0              ;signal bad (can't open console/libraries)

.wrap:
 move.l d0,-(a7)           ;remember error code
 move.l xxp_sysb(a4),a6

 IFEQ xxp_what-1           ;#^4
 move.l xxp_tanb(a4),d0    ;(only close tandem.library if xxp_what=1)
 bsr .clib                 ;(uses dummy tanbase if xxp_what=2)
 ENDC                      ;#^4

 move.l xxp_gadb(a4),d0    ;close libraries (exc dos.library)
 bsr .clib
 move.l xxp_intb(a4),d0
 bsr .clib
 move.l xxp_aslb(a4),d0
 bsr .clib
 move.l xxp_gfxb(a4),d0
 bsr .clib

 tst.l xxp_bnch(a4)        ;go if CLI
 beq.s .ccli

 move.l xxp_oput(a4),d1    ;close console if open
 beq.s .ccon
 move.l xxp_dosb(a4),a6
 jsr _LVOClose(a6)
.ccon:
 move.l xxp_sysb(a4),a6    ;reply to workbench startup message
 jsr _LVOForbid(a6)
 move.l xxp_bnch(a4),a1
 jsr _LVOReplyMsg(a6)

.ccli:
 move.l xxp_dosb(a4),d0    ;close dos.library
 bsr .clib
 move.l (a7)+,d0           ;error code (0 if ok, -1 if bad) in D0
 add.l #1024,a7            ;restore stack
 rts                       ;exit back to workbench/CLI

.clib:                     ;** close a library - base at d0 (EQ if unopened)
 beq.s .clibq
 move.l d0,a1
 jsr _LVOCloseLibrary(a6)
.clibq:
 rts

.abdir:                    ;** CD back to aboriginal CD
 movem.l d0-d1/a0-a1/a6,-(a7)
 move.l xxp_dosb(a4),a6
 move.l xxp_cdir(a4),d1
 jsr _LVOCurrentDir(a6)
 movem.l (a7)+,d0-d1/a0-a1/a6
 rts

.trep: dc.b 'Error: can''t open tandem.library',$0A                ;}
 dc.b '(Press <return> to acknowledge)',$0A,0                      ;} do
.lrep: dc.b 'Error: must be release 2.04+ of operating system',$0A ;} not
.brep: dc.b '(Press <return> to acknowledge)',$0A,0                ;} inter-
.dosn: dc.b 'dos.library',0                                        ;} pose
.intn: dc.b 'intuition.library',0
.gfxn: dc.b 'graphics.library',0
.asln: dc.b 'asl.library',0
.gadn: dc.b 'gadtools.library',0
.conn: dc.b 'CON:20/10/320/50/Console',0
.tann: dc.b 'tandem.library',0
 ds.w 0

 ENDC                      ;#^1

                           ;** This is the end of Front.i **
                           ;If saving INC:Front.i, first chop off this line
                           ;and all subsequent lines (& set xxp_what EQU 1)

*#######################################################################

 IFEQ xxp_what             ;#^5 if xxp_what=0, assemble as tandem.library

 STRUCTURE TandemBase,LIB_SIZE ;this section based on sample in RKM
 UBYTE sb_Flags
 UBYTE sb_pad
 ULONG sb_SysLib           ;this is longword aligned
 ULONG sb_DosLib
 ULONG sb_SegList
 LABEL TandemBase_SIZEOF

SAMPLENAME: MACRO
 DC.B 'tandem.library',0
 ENDM

VERSION: EQU 37
REVISION: EQU 262

DATE: MACRO
 dc.b '3.24.00'
 ENDM

VERS: MACRO
 dc.b 'tandem 37.262'
 ENDM

VSTRING: MACRO
 dc.b 'tandem 37.262 (3.24.00)',13,10,0
 ENDM

VERSTAG: MACRO
 dc.b 0,'$VER: tandem 37.262 (3.24.00)',0
 ENDM

* dummy entry point - return with error
 moveq #-1,d0
 rts

* library priority (always 0)
MYPRI: equ 0

* this is the RomTag structure for the library
RomTag:                    ;STRUCTURE RT,0
 dc.w RTC_MATCHWORD        ;UWORD RT_MATCHWORD
 dc.l RomTag               ;APTR RT_MATCHTAG
 dc.l TLEndcode            ;APTR RT_ENDSKIP
 dc.b RTF_AUTOINIT         ;UBYTE RT_FLAGS
 dc.b VERSION              ;UBYTE RT_VERSION
 dc.b NT_LIBRARY           ;UBYTE RT_TYPE
 dc.b MYPRI                ;BYTE RT_PRI
 dc.l LibName              ;APTR RT_NAME
 dc.l IDString             ;APTR RT_IDSTRING
 dc.l InitTable            ;APTR RT_INIT

IDString: VSTRING
LibName: SAMPLENAME
dosName: DOSNAME
 ds.w 0

InitTable:
 dc.l TandemBase_SIZEOF
 dc.l funcTable
 dc.l dataTable
 dc.l initRoutine

funcTable:
 dc.l Open
 dc.l Close
 dc.l Expunge
 dc.l 0

 dc.l TLFsub
 dc.l TLStrbuf
 dc.l TLStra0
 dc.l TLError
 dc.l TLOpenread
 dc.l TLOpenwrite
 dc.l TLWritefile
 dc.l TLReadfile
 dc.l TLClosefile
 dc.l TLAschex
 dc.l TLHexasc
 dc.l TLOutput
 dc.l TLInput
 dc.l TLPublic
 dc.l TLChip
 dc.l TLProgdir
 dc.l TLKeyboard
 dc.l TLWindow
 dc.l TLWclose
 dc.l TLText
 dc.l TLTsize
 dc.l TLWfront
 dc.l TLGetfont
 dc.l TLNewfont
 dc.l TLButmon
 dc.l TLAslfont
 dc.l TLAslfile
 dc.l TLWslof
 dc.l TLReqbev
 dc.l TLReqarea
 dc.l TLReqcls
 dc.l TLReqfull
 dc.l TLReqchoose
 dc.l TLReqinput
 dc.l TLReqedit
 dc.l TLReqshow
 dc.l TLAssdev
 dc.l TLReqmenu
 dc.l TLReqmuset
 dc.l TLReqmuclr
 dc.l TLReqinfo
 dc.l TLWpoll
 dc.l TLTrim
 dc.l TLWsub
 dc.l TLWpop
 dc.l TLMultiline
 dc.l TLWupdate
 dc.l TLWcheck
 dc.l TLFloat
 dc.l TLBusy
 dc.l TLUnbusy
 dc.l TLReqcolor
 dc.l TLOnmenu
 dc.l TLOffmenu
 dc.l TLPrefdir
 dc.l TLPreffil
 dc.l TLButstr
 dc.l TLButprt
 dc.l TLButtxt
 dc.l TLSlider
 dc.l TLPassword
 dc.l TLSlimon
 dc.l TLReqredi
 dc.l TLReqchek
 dc.l TLReqon
 dc.l TLReqoff
 dc.l TLGetilbm
 dc.l TLPutilbm
 dc.l TLResize
 dc.l TLProgress
 dc.l TLData
 dc.l TLEllipse
 dc.l TLGetarea
 dc.l TLHexasc16
 dc.l TLDropdown
 dc.l TLReqfont
 dc.l TLWscroll
 dc.l TLPrefs
 dc.l TLMget
 dc.l TLTabs
 dc.l TLTabmon
 dc.l TLPict

 dc.l -1

dataTable:
 INITBYTE LN_TYPE,NT_LIBRARY
 INITLONG LN_NAME,LibName
 INITBYTE LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
 INITWORD LIB_VERSION,VERSION
 INITWORD LIB_REVISION,REVISION
 INITLONG LIB_IDSTRING,IDString
 DC.L 0

* this routine gets called after the library has been allocated
* A6=sysbase  A0=segment list  D0=library pointer
initRoutine:
 move.l a5,-(a7)           ;save a5
 move.l d0,a5              ;library pointer to a5
 move.l a6,sb_SysLib(a5)   ;set sb_SysLib
 move.l a0,sb_SegList(a5)  ;save a pointer to my loaded code
 lea dosName(pc),a1
 moveq #0,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,sb_DosLib(a5)   ;set sb_DosLib
 bne.s 1$
 ALERT AG_OpenLib!AO_DOSLib ;(crash if can't open dos.library)
1$:
 move.l a5,d0
 move.l (a7)+,a5
 rts

* this is called when the user opens library
* a6=my library ptr  d0=version
Open:
 addq.w #1,LIB_OPENCNT(a6) ;bump opener count
 bclr #LIBB_DELEXP,sb_Flags(a6) ;stop delayed expunge
 move.l a6,d0              ;signals that open was successful
 rts

* this gets called when the user closes the library
* A6=my library pointer
Close:
 moveq #0,d0               ;return value
 subq.w #1,LIB_OPENCNT(a6) ;reduce opener count
 bne.s 1$                  ;go if still some users
 btst #LIBB_DELEXP,sb_Flags(a6) ;is there a delayed expunge pending?
 beq.s 1$                  ;no, go
 bsr Expunge               ;yes, expunge me
1$:
 rts

* expunge the library
* A6=tandem.library pointer
Expunge:
 movem.l d2/a5-a6,-(a7)
 move.l a6,a5
 move.l sb_SysLib(a5),a6
 tst.w LIB_OPENCNT(a5)
 beq.s 1$
 bset #LIBB_DELEXP,sb_Flags(a5)
 moveq #0,d0
 bra.s 2$
1$:
 move.l sb_SegList(a5),d2
 move.l a5,a1
 jsr _LVORemove(a6)
 move.l sb_DosLib(a5),a1
 jsr _LVOCloseLibrary(a6)
 moveq #0,d0
 move.l a5,a1
 move.w LIB_NEGSIZE(a5),d0
 sub.l d0,a1
 add.w LIB_POSSIZE(a5),d0
 jsr _LVOFreeMem(a6)
 move.l d2,d0
2$:
 movem.l (a7)+,d2/a5-a6
 rts

 ENDC                      ;#^5

********************* subroutines that do the work **********************

*>>>> edit a string in xxp_AcWind
TLReqedit:

;on call:      D0 = lhs of tablet
;              D1 = top of tablet
;              A0 = tags (all start with xxp_x....)

; xxp_chnd     bit 31     1 if text/styl changed
; on return    bit 16-30  offset
;              bit 15     1 if continuation line in FWork+512,768
;              bit 14     1 if cursor is in continuation line
;              bit 13     1 if line is complemented
;              bit 12     1 if return code = 8-11 (i.e. error conditions)
;              bit 11     1 if force proportional font -> fixed
;              bit 10     1 if justification changed
;              bit 8-9    00 ljust   01 cent   10 rjust   11 full just

; return       0 Return pressed   5 Click off tablet   10 Bad fixed offset
; codes in     1 Esc pressed      6 Menu select        11 Can't attach font
; D0           2 No print         7 Unrec keyboard     12 Window resized
;              3 No cursor        8 Window too narrow  13 Window close
; (8-11 EQ)    4 Contin line      9 Window too shallow 14 Window inact

; on return:   all regs saved except return code in D0
;              xxp_chnd as above                 } But see exception
;              xxp_valu has value if task = 3/4  } below
;              xxp_crsr has cursor (if any)
;              xxp_kybd has last keyboard entry (if any)
;              xxp_FWork     has text   (cont if any in xxp_FWork+512)
;              xxp_FWork+256 has styl   (cont if any in xxp_FWork+768)

; exception    xxp_valu   = chrs in text
; to above     xxp_valu+2 = text width in pixels (see caution below)
; for nprt     xxp_chnd   = lhs of crsr (if any)
;              xxp_chnd+2 = rhs of crsr (if any)

;** caution: text with crsr can have different length from without crsr **

;* internal structure of xxp_FWork

;current, previous & original text & styl  (used only if text can change)
.txte: equ 0                    ;text being edited
.styl: equ 256                  ;styl being edited
.rdot: equ 512                  ;redo text
.rdos: equ 768                  ;redo styl
.orgt: equ 1024                 ;orig text
.orgs: equ 1280                 ;orig styl

;tablet dimensions
.tabx: equ 1536                 ;.L tablet xpos
.taby: equ 1540                 ;.L tablet ypos
.tabw: equ 1544                 ;.L tablet width
.tabh: equ 1548                 ;.L tablet height

;text and styl pointers
.txip: equ 1552                 ;.L text address (= .text if dynamic)
.stip: equ 1556                 ;.L styl address (= .styl if dynamic)

;sundry data
.ulin: equ 1560                 ;.W font underline ypos
.mxjs: equ 1562                 ;.W max fjust quotient
.tbmx: equ 1564                 ;.W max tab width (or max possible if 0)
.comp: equ 1566                 ;.W complement line if -1 else 0
.task: equ 1568                 ;.W task number
.offs: equ 1570                 ;.W operative offset
.offf: equ 1572                 ;.W -1 if offset fixed
.forb: equ 1574                 ;.W forbid bits
.ltyp: equ 1576                 ;.W current ltyp
.crsr: equ 1578                 ;.W cursor posn or -1 if none
.maxc: equ 1580                 ;.W max characters per line
.maxw: equ 1582                 ;.W max line width or 0 if none
.prev: equ 1584                 ;.W pixels in tablet from previous echo
.this: equ 1586                 ;.W pixels in tablet from this echo
.chrs: equ 1588                 ;.W current chrs in line
.wdth: equ 1590                 ;.W current line width
.cslf: equ 1592                 ;.W current crsr lhs
.csrt: equ 1594                 ;.W current crsr rhs
.font: equ 1596                 ;.W font number
.ftyp: equ 1598                 ;.W current font style
.cspc: equ 1600                 ;.W initial character spacing
.clr0: equ 1602                 ;.W cache of window pens
.csrc: equ 1604                 ;.W chr under cursor (0 if space appended)
.rdcs: equ 1606                 ;.W redo crsr posn
.ogcs: equ 1608                 ;.W orig crsr posn
.ljsr: equ 1610                 ;.W ljust remainder
.kybd: equ 1612                 ;.W crsr xpos in pixels, if 0 use xxp_xcrsr
.nprt: equ 1614                 ;.W don't print if -1 else 0
.iclr: equ 1616                 ;.W clear tablet initially if -1 else 0
.toff: equ 1618                 ;.W text offset set by .totl
.ftvl: equ 1620                 ;.L font pointer
.fty2: equ 1624                 ;.W current font style for xxp_WPort
.minx: equ 1626                 ;.W minx from TextExtent
.tral: equ 1628                 ;.W strip trailing spaces if -1 else 0
.rdch: equ 1630                 ;.L redo xxp_chnd
.ogch: equ 1634                 ;.L orig xxp_chnd
.rdty: equ 1638                 ;.W redo .ltyp
.ogty: equ 1640                 ;.W orig .ltyp
.rdcp: equ 1642                 ;.W redo .comp
.ogcp: equ 1644                 ;.W orig .comp
.code: equ 1646                 ;.W return code
.same: equ 1648                 ;(unused)
.ina4: equ 1650                 ;.W -1 if xxp_xtext was A4
.cura: equ 1652                 ;.L .stip crsr addr (used by .fore)
.bmpa: equ 1656                 ;.L .stip jbump addr (used by .fore)
.shad: equ 1660                 ;.L xxp_xshdv data: 0,pen,dy,dx
.resz: equ 1664                 ;.W -1 if can resize window
.menu: equ 1666                 ;.W menu number of LineFormat menu, else -2
.ifix: equ 1668                 ;.W -1 if input font proportional
.ifxv: equ 1670                 ;.W XSize to force upon prop -> fixed
.ifof: equ 1672                 ;.W .ifix amt bumped by latest .fore call
.styb: equ 1674                 ;.W 0, or xxp_xstyb input
.jam1: equ 1676                 ;.W 0, or -1 if jam1
.case: equ 1678                 ;.W case: 0normal, 1ucase 2lcase 3smallcaps
.revs: equ 1680                 ;.W reverse: 0normal, -1right to left

;a partial xxp_wsuw for rendering (xxp_WPort+4 bytes)
.wsuw: equ 1684                 ;part xxp_wsuw for ERport

.limt: equ .wsuw+44             ;limit of xxp_FWork data (s/be <= 1800)


;*** TLReqedit - save properties of calling window (restored at end)

 movem.l d0-d7/a0-a6,-(a7)      ;saves all except return code in D0
 move.l xxp_strg(a4),-(a7)
 move.l xxp_Help(a4),-(a7)
 move.l xxp_AcWind(a4),a5       ;* a5 = active window } Throughout
 move.l xxp_FWork(a4),a6        ;* a6 = xxp_FWork     } TLreqedit
 move.l xxp_FrontPen(a5),-(a7)
 move.l xxp_IText(a5),-(a7)
 move.w #-1,xxp_Attc(a5)
 move.l xxp_Fnum(a5),-(a7)
 move.l xxp_Fsty(a5),-(a7)


;*** TLReqedit - input d0,d1 to .tabx,.taby

 clr.l .tabx(a6)           ;input d0,d1 to .tabx, .taby
 move.w d0,.tabx+2(a6)
 clr.l .taby(a6)
 move.w d1,.taby+2(a6)


;*** TLReqedit - process tags

 move.l a6,a1              ;clear .tabw -> .limt
 add.w #.tabw,a1
 move.w #.limt-.tabw-1,d2
.tag0:
 clr.b (a1)+               ;clear data area of FWork
 dbra d2,.tag0

 move.w #5,.mxjs(a6)       ;set defaults (all other defaults = 0)
 move.w #254,.maxc(a6)
 move.w #-1,.tral(a6)
 move.w xxp_Fnum(a5),.font(a6)
 move.w xxp_Tspc(a5),.cspc(a6)
 move.w xxp_FrontPen(a5),.clr0(a6)
 move.l xxp_shad(a5),.shad(a6)
 move.w #-1,.forb(a6)
 move.l a4,.txip(a6)
 move.w #-2,.menu(a6)

 clr.l xxp_chnd(a4)        ;initialise xxp_chnd (tags will update)

.tags:                     ;* collect tags...
 move.l (a0)+,d2           ;d2 = tag num
 beq .ntag                 ;go if tags all got
 move.l (a0)+,d3           ;d3 = tag data
 subq.w #2,d2              ;go to whichever tag
 bcs .xtex
 beq .xsty
 subq.w #2,d2
 bcs .xmxt
 beq .xmxc
 subq.w #2,d2
 bcs .xmxw
 beq .xcrs
 subq.w #2,d2
 bcs .xofs
 beq .xfor
 subq.w #2,d2
 bcs .xtsk
 beq .xcmp
 subq.w #2,d2
 bcs .xnpr
 beq .xfon
 subq.w #2,d2
 bcs .xcsp
 beq .xmxj
 subq.w #2,d2
 bcs .xlty
 beq .xkbd
 subq.w #2,d2
 bcs .tags                 ;(17 unused)
 beq .xclr
 subq.w #2,d2
 bcs .xtrl
 beq .xshd
 subq.w #2,d2
 bcs .xrsz
 beq .xmen
 subq.w #2,d2
 bcs .xpns
 beq .xfix
 subq.w #2,d2
 bcs .xjam
 beq .xcas
 subq.w #2,d2
 bcs .xstb
 beq .xrvs
 bra .tags

.xtex:                     ;replace FWork defaults with tag data
 move.l d3,.txip(a6)
 bra .tags
.xsty:
 move.l d3,.stip(a6)
 bra .tags
.xmxt:
 move.w d3,.tbmx(a6)
 bra .tags
.xmxc:
 move.w d3,.maxc(a6)
 bra .tags
.xmxw:
 move.w d3,.maxw(a6)
 bra .tags
.xcrs:
 move.w d3,.crsr(a6)
 bpl .tags
 move.w #3,.code(a6)       ;if tagged no crsr, return code = 3
 bra .tags
.xofs:
 clr.w .offf(a6)           ;no fixed if d3 = -1
 clr.w .offs(a6)
 tst.w d3
 bmi .tags
 subq.w #1,.offf(a6)       ;else, offset is fixed
 move.w d3,.offs(a6)
 bra .tags
.xfor:
 move.w d3,.forb(a6)
 bra .tags
.xtsk:
 move.w d3,.task(a6)
 bra .tags
.xcmp:
 move.w d3,.comp(a6)
 bpl .tags
 bset #5,xxp_chnd+2(a4)    ;xxp_chnd bit 13 if comp
 bra .tags
.xnpr:
 move.w d3,.nprt(a6)
 bra .tags
.xfon:
 move.w d3,.font(a6)
 bra .tags
.xcsp:
 move.w d3,.cspc(a6)
 bra .tags
.xmxj:
 move.w d3,.mxjs(a6)
 bra .tags
.xlty:
 move.w d3,.ltyp(a6)
 and.b #$FC,xxp_chnd+2(a4)
 or.b d3,xxp_chnd+2(a4)    ;note ltyp in xxp_chnd
 bra .tags
.xkbd:
 move.w d3,.kybd(a6)
 bra .tags
.xclr:
 move.w d3,.iclr(a6)
 bra .tags
.xtrl:
 move.w d3,.tral(a6)
 bra .tags
.xshd:
 move.l d3,.shad(a6)
 bra .tags
.xrsz:
 move.w d3,.resz(a6)
 bra .tags
.xmen:
 move.w d3,.menu(a6)
 bra .tags
.xpns:
 move.w d3,.clr0(a6)
 bra .tags
.xfix:
 move.w d3,.ifix(a6)
 bpl .tags
 bset #3,xxp_chnd+2(a4)
 bra .tags
.xjam:
 move.w d3,.jam1(a6)
 bra .tags
.xcas:
 move.w d3,.case(a6)
 bra .tags
.xstb:
 move.w d3,.styb(a6)
 bra .tags
.xrvs:
 move.w d3,.revs(a6)
 bra .tags


;*** TLReqedit - other setting up ***

;exit to         .dm00      continue
;                .dm03      comtinue (nprt)
;                .badf      can't attach font
;internal bsr's   none

.ntag:                     ;tags all done

 cmp.l .txip(a6),a4        ;set .ina4 if input text is in a4
 bne.s .nta4
 subq.w #1,.ina4(a6)

.nta4:                     ;set up redo things if applicable
 tst.l .txip(a6)           ;set .txip, .stip
 bne.s .txig
 move.l a6,.txip(a6)       ;if no txip, assume FWork
 bra.s .txgt

.txig:                     ;see if stip to be tfr'ed to FWork
 tst.w .revs(a6)
 bmi.s .txty               ;yes if reversed
 tst.w .case(a6)
 bne.s .txty               ;yes if .case<>0
 tst.w .crsr(a6)
 bmi.s .txgt               ;no if no crsr
 tst.w .nprt(a6)
 bmi.s .txgt               ;no if nprt
 cmp.l .txip(a6),a6
 beq.s .txgt               ;no if already at FWork

.txty:
 move.l .txip(a6),a0       ;tfr text to FWork
 move.l a6,.txip(a6)       ;note new .txip
 move.l a6,a1
.txtf:
 move.b (a0)+,(a1)+        ;tfr text to FWork
 bne .txtf

.txgt:
 move.l a6,a3              ;a3 = FWork+256 = where styl goes (if changeable)
 add.w #256,a3
 tst.l .stip(a6)           ;.stip specified?
 bne.s .stig               ;yes, go

 move.l a3,.stip(a6)       ;fill styl with 0 or as per xxp_xstyb
 move.l .txip(a6),a0       ;(as many bytes as text bytes + 1)
 move.b .styb+1(a6),d0
.st00:
 move.b d0,(a3)+
 tst.b (a0)+
 bne .st00
 bra.s .stgt

.stig:                     ;see if tfr sty to FWork+256
 tst.w .revs(a6)
 bmi.s .stty               ;yes if reversed
 cmpi.w #3,.case(a6)
 bne.s .stty               ;yes if .case<>3 (small caps)
 tst.w .crsr(a6)
 bmi.s .stgt               ;not if no crsr
 tst.w .nprt(a6)
 bmi.s .stgt               ;not if nprt
 cmp.l .stip(a6),a3
 beq.s .stgt               ;not if already at FWork+256

.stty:                     ;tfr sty to FWork+256
 move.l .stip(a6),a0
 move.l .txip(a6),a1
 move.l a3,.stip(a6)       ;note new .stip
.sttf:
 move.b (a0)+,(a3)+        ;tfr input styl to FWork+256
 tst.b (a1)+               ;(as many bytes as text bytes + 1)
 bne .sttf

.stgt:                     ;see if save input data in .orig
 tst.w .crsr(a6)
 bmi.s .help               ;no if no crsr
 tst.w .nprt(a6)
 bmi.s .help               ;no if nprt

 move.l .txip(a6),a0       ;save input data in .orig
 move.l .stip(a6),a1
 move.l a6,a2
 add.w #.orgt,a2
 move.l a6,a3
 add.w #.orgs,a3
.ortf:
 move.b (a1),512(a1)
 move.b (a1)+,(a3)+        ;.stip to .orgs
 move.b (a0),512(a0)
 move.b (a0)+,(a2)+        ;.txip to .orgt
 bne .ortf

 move.w .crsr(a6),.ogcs(a6) ;set other .orig data
 move.w .crsr(a6),.rdcs(a6)
 move.w .ltyp(a6),.ogty(a6)
 move.w .ltyp(a6),.rdty(a6)
 move.w .comp(a6),.ogcp(a6)
 move.w .comp(a6),.rdcp(a6)
 move.l xxp_chnd(a4),.ogch(a6)
 move.l xxp_chnd(a4),.rdch(a6)

.help:                     ;attach default help if none already
 tst.l xxp_Help(a4)
 bne.s .icas
 move.l #.str,xxp_strg(a4)
 move.l #$00010012,xxp_Help(a4)

.icas:
 tst.w .case(a6)           ;go if no xxp_xcase
 beq.s .data
 move.l .txip(a6),a0

 cmp.w #2,.case(a6)
 bcs.s .ucas               ;go if ucase
 beq.s .lcas               ;go if lcase

 move.l .stip(a6),a1       ;here if small caps
.scap:
 move.b (a0)+,d0           ;get next chr,styl
 beq.s .data
 move.b (a1)+,d1
 cmp.b #'a',d0             ;go unless a-z
 bcs .scap
 cmp.b #'z'+1,d0
 bcc .scap
 add.b #'A'-'a',d0
 move.b d0,-1(a0)          ;a-z -> A-Z
 and.b #$C3,d1
 or.b #$10,d1
 move.b d1,-1(a1)          ;make subscript
 bra .scap

.ucas:                     ;here if ucase
 move.b (a0)+,d0
 beq.s .data
 cmp.b #'a',d0
 bcs .ucas
 cmp.b #'z'+1,d0
 bcc .ucas
 add.b #'A'-'a',d0
 move.b d0,-1(a0)
 bra .ucas

.lcas:                     ;here if lcase
 move.b (a0)+,d0
 beq.s .data
 cmp.b #'A',d0
 bcs .lcas
 cmp.b #'Z'+1,d0
 bcc .lcas
 add.b #'a'-'A',d0
 move.b d0,-1(a0)
 bra .lcas

.data:                     ;initialise other data
 move.w .ltyp(a6),d0
 and.w #3,d0               ;initial ltyp to bits 8-9 of xxh_chnd
 or.b d0,xxp_chnd+2(a4)
 clr.w xxp_crsr(a4)
 move.w .crsr(a6),xxp_crsr+2(a4)

 move.w .font(a6),d0       ;set font...
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont             ;attach font to window
 beq .badf                 ;bad if can't

 move.w .ifix(a6),d1       ;d1 = ifix requested by tags
 clr.w .ifix(a6)           ;will leave ifix = 0 if font fixed already
 move.l xxp_FSuite(a4),a3
 move.w xxp_Fnum(a5),d2
 mulu #xxp_fsiz,d2
 move.l xxp_plain(a3,d2.w),a3
 btst #5,tf_Flags(a3)      ;font fixed?
 beq.s .fxtf               ;yes, go
 subq.w #1,.ifix(a6)       ;set ifix = -1, set ifxv
 move.w tf_XSize(a3),.ifxv(a6)
 tst.w d1                  ;did tags want ifix off?
 beq.s .fxtf               ;no, go
 addq.w #2,.ifix(a6)       ;yes, switch ifix on
.fxtf:

 move.l a6,a3              ;set up .wsuw
 add.w #.wsuw,a3
 clr.l xxp_LeftEdge(a3)
 move.w xxp_Fnum(a5),xxp_Fnum(a3)
 move.w #-1,xxp_Attc(a3)
 move.l xxp_ERport(a4),xxp_WPort(a3)
 clr.l .tabw(a6)           ;initialise tablet area
 clr.l .tabh(a6)
 bsr TLTvert               ;get font height
 move.w d6,.tabh+2(a6)     ;.tabh, .ulin = font height, baseline
 move.w d7,.ulin(a6)


;*** TLReqedit - ready to go to .dims

 moveq #0,d7               ;d7 = 0 = 1st time thru
 tst.w .nprt(a6)
 bmi.s .dm03               ;don't check window size if no print
 bra.s .dm00


;*** TLreqedit - check tablet size, crsr posn &c ***  (Recycling point)

;entry points:    .dims    not 1st time thru
;                 .dm00    1st time thru
;                 .dm03    1st time thru, and nprt
;exits are to:    .echo    all ok
;                 .badx    window too narrow
;                 .bady    window too shallow
;                 .bado    bad offset
;                 .trnc    line too long
;                 .badr    window resized
;internal bsr's   .totl

.dims:                     ;* here if not 1st time thru
 moveq #-1,d7              ;d7 = -1 = not 1st time thru

 bsr TLWCheck              ;window dims ok?
 beq.s .dmok               ;go if window unchanged
 bra.s .dm01               ;else, check that resizing allowed

.dm00:                     ;* here if 1st time thru
 bsr TLWCheck              ;go if window size same as known to caller
 beq.s .dm03

.dm01:                     ;* window has been resized
 tst.w .resz(a6)           ;is that permitted?
 beq .badr                 ;no, abort - go to .badr
 bsr TLWupdate             ;* update window dims

.dm03:                     ;* do this stuff 1st time thru or window resized
 move.w .taby+2(a6),d0
 add.w .tabh+2(a6),d0      ;d0 = tablet bot
 cmp.w xxp_PHeight(a5),d0  ;printable height >= tablet bot?
 bgt .bady                 ;no, stop - window too shallow

 move.w xxp_PWidth(a5),d0  ;d0 = printable width - tablet left
 sub.w .tabx+2(a6),d0      ;   = max available tablet width
 ble .badx                 ;stop if window too narrow

 tst.w .tbmx(a6)
 beq.s .tbwd               ;go if .tbmx undefined
 cmp.w .tbmx(a6),d0
 bcs.s .tbwd               ;go if max available width < max allowable width
 move.w .tbmx(a6),d0       ;else, d0 = max allowable width
.tbwd:

 move.w d0,.tabw+2(a6)     ;set tablet width
 move.w d0,.prev(a6)       ;force clearing of tablet
 tst.w d7
 bne.s .dmok               ;go if not 1st time thru
 tst.w .iclr(a6)
 bmi.s .dmok               ;clear initially if xxp_xiclr
 clr.w .prev(a6)           ;else, don't clear tablet

.dmok:                     ;* check line width & crsr position, set offset
 clr.l .cura(a6)           ;switch off .cura, .bmpa
 clr.l .bmpa(a6)

 bsr .totl                 ;pre-scan line (without crsr)
 move.w d7,.wdth(a6)       ;put width in .wdth
 move.w d5,.chrs(a6)       ;put chrs in .chrs

 tst.w .maxw(a6)
 beq.s .cmxc               ;go if .maxw undefined
 cmp.w .maxw(a6),d7        ;check line length...
 bgt .trnc                 ;go truncate if total width > .maxw
.cmxc:
 cmp.w .maxc(a6),d5
 bgt .trnc                 ;go truncate if chrs in line > .maxc

 tst.w .crsr(a6)
 bpl.s .crsy               ;go if crsr exists
 tst.w .offf(a6)
 bmi.s .echo               ;no crsr: go if fixed offset
 clr.w .offs(a6)           ;else, offset = 0
 bra.s .echo

.crsy:
 cmp.w .crsr(a6),d5        ;check crsr posn...
 bcc.s .crsf               ;yes, go
 move.w d5,.crsr(a6)       ;no, fix crsr

.crsf:                     ;set crsr posn...
 moveq #0,d0
 move.w .crsr(a6),d0       ;d0 = crsr tab
 move.l .stip(a6),a0
 move.l a0,.cura(a6)       ;cause .fore to isolate the cursor byte
 add.l d0,.cura(a6)
 move.l .txip(a6),a1
 move.b 1(a1,d0.w),.csrc+1(a6)
 move.b 0(a1,d0.w),.csrc(a6) ;save chr under crsr
 bne.s .offc               ;go if not eol
 move.b #$20,0(a1,d0.w)    ;if eol, append a space
 clr.b 1(a1,d0.w)

.offc:                     ;check offset...
 bsr .totl                 ;again pre-scan line, with cursor
 move.w d7,.wdth(a6)       ;note width with csrs (can be > without)
 move.w d6,.cslf(a6)       ;note crsr lhs
 move.w d4,.csrt(a6)       ;note crsr rhs
 tst.w .nprt(a6)
 bmi.s .echo               ;no need to check offset if nprt
 sub.w .tabw+2(a6),d4      ;set d4 = mimimum offset; d6 = maximum offset
 bcc.s .offt               ;(minimum = crsr rhs - tablet width)
 moveq #0,d4               ;(maximum = crsr lhs)

.offt:
 tst.w .offf(a6)           ;ok if offset not fixed
 bpl.s .offg
 cmp.w .offs(a6),d4        ;bad if minimum offset > fixed offset
 bgt .bado
 cmp.w .offs(a6),d6        ;bad if maximum offset < fixed offset
 blt .bado
 bra.s .echo
.offg:                     ;set offset...
 move.w d4,.offs(a6)       ;if offset unfixed, set to minimum


;*** TLReqedit - print the text on the tablet ***

;exit points     .dims    recycle - window resized
;                .exnp    quit if .nprt
;internal bsr's  .prpq    .fore   .forp   .preb
;                .prcp    .text   .prpv

.echo:                     ;* echo the text in the tablet
 tst.w .nprt(a6)
 bmi .exnp                 ;go if no print

 bsr .swap                 ;(swap if reverse text)

 move.l .txip(a6),a0       ;a0 scans text
 move.l .stip(a6),a1       ;a1 scans styl
 clr.w .this(a6)
 moveq #0,d6
 move.w .ljsr(a6),d6       ;d6 = fjust remainder set by .totl
 bmi.s .echf               ;go if none
 move.l a1,.bmpa(a6)       ;set .bmpa
 add.l d6,.bmpa(a6)
.echf:
 move.w .toff(a6),d6       ;d6 = text offset so far (<>0 if centre,rjust)
 beq.s .prcu               ;go if offset = 0
 cmp.w .offs(a6),d6
 ble.s .prcu               ;go if text offset <= tablet offset
 bsr .prpq                 ;clear text offset on tablet
 beq .prbd                 ;bad if can't
.prcu:                     ;* print next segment
 tst.b (a0)
 beq .prqt                 ;done if no more segments
 cmp.l .bmpa(a6),a1        ;full just remainder here?
 bne.s .prnb               ;no, go
 subq.w #1,xxp_Tspc(a5)    ;dec Tspc after full just remainder
.prnb:
 bsr .fore                 ;set a2,a3 = end of segment, d0 = length
 cmp.w #xxp_ewiv,d0        ;wider than xxp_EBmap?
 ble.s .prok               ;no, continue
.prch:
 move.l a2,d0              ;yes, take first half of string
 sub.l a0,d0
 lsr.l #1,d0
 sub.l d0,a2
 sub.l d0,a3
 bsr .forp                 ;get its len
 cmp.w #xxp_ewiv,d0
 bgt .prch                 ;until len <= xxp_EBmap
.prok:
 move.w d6,d1              ;d6 = lhs of segment, d1 = rhs of segment
 add.w d0,d1
 cmp.w .offs(a6),d1        ;rhs segment < lhs tablet?
 bcs .prnx                 ;yes, skip to next segment
 cmp.w .offs(a6),d6        ;lhs segment >= lhs tablet?
 bcc.s .prpt               ;yes, go
 move.w .offs(a6),d2
 add.w .tabw+2(a6),d2      ;d2 = rhs of tablet
 cmp.w d2,d1               ;rhs segment >= rhs tablet?
 bcc.s .pral               ;yes, go
 bsr .preb                 ;lhs seg < lhs tab and rhs seg < rhs tab..
 move.w .offs(a6),d2       ;print on EBmap
 sub.w d6,d2               ;copy from: lhs tab - lhs seg
 moveq #0,d3               ;copy to:   lhs tab
 move.w d1,d4              ;width:     rhs seg - lhs tab
 sub.w .offs(a6),d4
 move.w d4,.this(a6)       ;.this = width copied
 bsr .prcp                 ;copy
 beq .prbd                 ;bad if can't
 bra .prnx                 ;to next segment
.pral:                     ;* lhs seg < lhs tab and rhs seg >= rhs tab..
 bsr .preb                 ;print on EBmap
 move.w .offs(a6),d2
 sub.w d6,d2               ;copy from: lhs tab - lhs seg
 move.w .tabx+2(a6),d3     ;copy to:   lhs tab
 move.w .tabw+2(a6),d4     ;width:     tab width
 move.w d4,.this(a6)       ;.this = width copied
 bsr .prcp                 ;copy to tablet
 beq .prbd                 ;bad if can't
 bra .prqt                 ;printing done
.prpt:                     ;* lhs segment >= lhs tablet..
 move.w .offs(a6),d2
 add.w .tabw+2(a6),d2      ;d2 = rhs of tablet
 cmp.w d1,d2               ;rhs tablet >= rhs segment?
 bcc.s .prsm               ;yes, go
 bsr .preb                 ;* lhs seg >= lhs tab and rhs seg > rhs tab..
 moveq #0,d2               ;print on EBmap
 move.w d6,d3              ;copy from: lhs seg
 sub.w .offs(a6),d3        ;copy to:   lhs tab - lhs seg
 move.w .tabw+2(a6),d4     ;width:     rhs tab - lhs seg
 sub.w d3,d4
 add.w d4,.this(a6)        ;add width to .this
 bsr .prcp                 ;copy to tablet
 beq .prbd                 ;bad if can't
 bra.s .prqt               ;printing done
.prsm:                     ;* lhs seg >= lhs tab and rhs seg <= rhs tab..
 tst.b (a2)
 bne.s .ntlt
 tst.w xxp_Tspc(a5)        ;(use EBmap if Tspc at end)
 bne.s .tilt
.ntlt:
 bsr .text                 ;print on tablet to:  lhs seg - lhs tab
 beq .prbd                 ;try again if can't
 add.w d0,.this(a6)        ;add width printed to .this
 bra.s .prnx               ;to next segment
.tilt:
 bsr .preb                 ;print to EBmap
 moveq #0,d2
 move.l d6,d3
 sub.w .offs(a6),d3
 move.l d0,d4
 bsr .prcp                 ;copy to tablet
 beq .prbd                 ;try again if can't
 add.w d0,.this(a6)        ;add width printed to .this
.prnx:                     ;* to next segment
 move.w d1,d6              ;d6 = its xpos
 move.l a2,a0              ;a0 = its text
 move.l a3,a1              ;a1 = its styl
 bra .prcu                 ;go see if any & print it

.prbd:                     ;* printing failed (window resized)
 bsr .swap                 ;un-swap if reverse
 move.w .crsr(a6),d0
 bmi .dims                 ;go if no crsr
 move.l .txip(a6),a0       ;else, restore chr under crsr
 move.b .csrc+1(a6),1(a0,d0.w)
 move.b .csrc(a6),0(a0,d0.w)
 bra .dims                 ;& retry at new size

.prqt:                     ;* printed ok
 move.w .prev(a6),d0       ;.prev > .this?
 cmp.w .this(a6),d0        ;no, go (no need to clear remainder of .prev)
 ble.s .ecqt
 bsr .prpv                 ;clear between .this & .prev
 beq .prbd                 ;bad if can't - window resized

.ecqt:                     ;* exit from .echo
 bsr .swap                 ;un-swap if reverse



;*** TLReqedit - wait for user response ***

;exits:           recycle back to .dims (via .kill if crsr off & close down)
;                .exit
;                .totl

.prgd:
 move.w .crsr(a6),d0
 bmi .exit                 ;if no crsr, quit
 move.l .txip(a6),a0
 move.b .csrc+1(a6),1(a0,d0.w)
 move.b .csrc(a6),0(a0,d0.w) ;restore chr under crsr
 move.w .this(a6),.prev(a6) ;set prev for next echo
 moveq #0,d1
 move.w .kybd(a6),d1       ;was xxp_xkybd set?
 beq.s .wait               ;no, go
 clr.w .kybd(a6)           ;yes, stop it from being invoked again
 cmp.w .tabw+2(a6),d1      ;go provided d1 < tablet rhs
 bcs .clkp                 ;(act as if clicked there)

.wait:
 jsr TLWfront
 bsr TLKeyboard            ;* wait for user response
 cmp.b #$95,d0             ;go if menu selected undo
 bne.s .knbu
 cmp.w .menu(a6),d1        ;(unless no/wrong menu strip)
 bne.s .knbu
 cmp.b #5,d2
 beq .ckil
.knbu:
 btst #3,d3                ;go if not ctrl
 beq.s .kgcu
 btst #0,d3                ;go if not shift
 beq.s .kgcu
 cmp.b #21,d0              ;if shift/ctrl/u (undo), go without backup
 beq .shct
.kgcu:
 move.l xxp_FWork(a4),a0   ;else backup in case shift/ctrl/u next time
 move.l a0,a1
 add.w #256,a1
 move.l a0,a2
 add.w #512,a2
 move.l a0,a3
 add.w #768,a3
.kgbu:
 move.b (a1)+,(a3)+
 move.b (a0)+,(a2)+
 bne .kgbu
 move.w .crsr(a6),.rdcs(a6)
 move.w .ltyp(a6),.rdty(a6)
 move.w .comp(a6),.rdcp(a6)
 move.l xxp_chnd(a4),.rdch(a6)
 cmp.b #$95,d0             ;menu selection
 beq .mens
 btst #3,d3                ;ctrl keys
 bne .ctrl
 btst #6,d3                ;left amiga
 bne .lfam
 btst #7,d3                ;right amiga
 bne .rtam
 cmp.b #$0D,d0             ;return
 beq .teol
 cmp.b #$1B,d0             ;Esc
 beq .escp
 cmp.b #$93,d0             ;Close window
 beq .clwd
 cmp.b #$97,d0             ;Inactive window
 beq .inac
 cmp.b #$8C,d0             ;tab key
 beq .tabk

 tst.w .revs(a6)           ;(if reverse, mirror the arrows keys)
 beq.s .arrs
 cmp.b #$91,d0
 beq .rtar
 cmp.b #$90,d0
 beq .lfar

.arrs:
 cmp.b #$91,d0             ;left arrow
 beq .lfar
 cmp.b #$90,d0             ;right arrow
 beq .rtar
 cmp.b #$80,d0             ;left mouse
 beq .clik
 cmp.b #$8D,d0             ;del
 beq .del
 cmp.b #$8B,d0             ;backspace
 beq .bs
 cmp.b #$96,d0             ;size window
 beq .dims
 cmp.b #$97,d0             ;active window (ignore)
 beq .wait
 cmp.w #160,d0             ;reject, unless an ascii chr
 bcc.s .asci
 cmp.w #32,d0
 bcs .unrc
 cmp.w #127,d0
 bcc .unrc
.asci:                     ;* asci chr pressed
 cmp.w #2,.task(a6)
 bcs.s .ascy               ;go unless num/hex
 cmp.b #'0',d0
 bcs .wait                 ;reject if < 0
 cmp.b #'9'+1,d0
 bcs.s .ascy               ;accept if 0-9
 cmp.w #2,.task(a6)
 beq .wait                 ;if num, reject if not 0-9
 cmp.b #'a',d0
 bcs.s .asch
 cmp.b #'g',d0
 bcc .wait
 sub.b #'a'-'A',d0         ;convert a-f to A-F
.asch:
 cmp.b #'A',d0             ;if hex, accept also A-F
 bcs .wait
 cmp.b #'G',d0
 bcc .wait
.ascy:
 bset #7,xxp_chnd(a4)      ;note text changed
 move.l .txip(a6),a0       ;a0 scans text
 clr.b 254(a0)             ;(max after insertion 255 chrs)
 move.l a0,a1
 add.w .crsr(a6),a1        ;a1 = insertion point
.asce:
 tst.b (a0)+               ;find eol
 bne .asce
 move.l .stip(a6),a2       ;a2 = corresponding styl byte to a0
 add.l a0,a2
 sub.l .txip(a6),a2
.hole:
 move.b -1(a2),(a2)        ;shift all text & styl a byte fwd
 move.b -1(a0),(a0)
 subq.l #1,a2
 subq.l #1,a0
 cmp.l a1,a0               ;until insertion point reached
 bne .hole
 move.b d0,(a0)            ;insert character
 addq.w #1,.crsr(a6)       ;bump crsr
 bra .dims                 ;& recycle
.del:                      ;* del pressed
 bset #7,xxp_chnd(a4)
 btst #0,d3
 bne.s .shdl               ;go if shifted
 move.l .txip(a6),a0
 add.w .crsr(a6),a0        ;a0 points to crsr text
 tst.b (a0)
 beq .wait                 ;ignore if no chr under crsr
 move.l .stip(a6),a1
 add.w .crsr(a6),a1        ;a1 points to crsr styl
.delc:
 move.b 1(a1),(a1)         ;move a chr back
 move.b 1(a0),(a0)
 addq.l #1,a0
 addq.l #1,a1
 bne .delc                 ;until eol
 bra .dims
.shdl:                     ;* shift/del
 move.l .txip(a6),a0
 add.w .crsr(a6),a0
 clr.b (a0)                ;delete all from crsr chr
 bra .dims
.bs:                       ;* backspace pressed
 bset #7,xxp_chnd(a4)
 btst #0,d3
 bne.s .shbs               ;go if shifted
 subq.w #1,.crsr(a6)
 bcc .del                  ;backspace, then as del
 clr.w .crsr(a6)
 bra .del
.shbs:                     ;* shift backspace
 move.l .txip(a6),a0
 move.l .stip(a6),a1
 move.l a0,a2
 add.w .crsr(a6),a2
 move.l a1,a3
 add.w .crsr(a6),a3
.sbsc:
 move.b (a3)+,(a1)+        ;delete all behind crsr
 move.b (a2)+,(a0)+
 bne .sbsc
 clr.w .crsr(a6)
 bra .dims
.teol:                     ;* return pressed
 clr.w .code(a6)           ;return code = 0
 cmp.w #1,.task(a6)        ;contin line allowed?
 bne.s .kill               ;no, go
 move.w #4,.code(a6)       ;return code = 4
 bset #7,xxp_chnd(a4)      ;note text changed
 bset #7,xxp_chnd+2(a4)    ;note contin line exists
 bset #6,xxp_chnd+2(a4)    ;note crsr in contin line
 move.w .crsr(a6),d0       ;d0 = old crsr
 clr.w .crsr(a6)           ;new crsr = 0 in contin line
 move.l .txip(a6),a0       ;contin text from txip+crsr to FWork+512
 move.l .stip(a6),a1       ;contin styl from stip+crsr to FWork+768
 add.w d0,a0
 add.w d0,a1
 move.l xxp_FWork(a4),a2
 move.l a2,a3
 add.w #512,a2
 add.w #768,a3
 move.l a0,d0              ;remember split point
.teot:
 move.b (a1)+,(a3)+        ;text to contin line
 move.b (a0)+,(a2)+        ;styl to contin line
 bne .teot
 move.l d0,a0              ;delimit old line
 clr.b (a0)
 bra.s .kill
.clwd:                     ;* close window pressed
 move.w #13,.code(a6)      ;return code = 13
 bra.s .kill
.inac:                     ;* inactive window pressed
 move.w #14,.code(a6)      ;return code = 14
 bra.s .kill

.escp:                     ;* Esc pressed
 move.w #1,.code(a6)       ;return code = 1

.kill:                     ;* redo with crsr off, then quit
 bsr .tidy
 clr.l xxp_crsr(a4)
 move.w .crsr(a6),xxp_crsr+2(a4) ;set crsr
 move.w #-1,.crsr(a6)      ;crsr off to print w'out crsr & quit
 tst.w .tral(a6)
 beq .dims                 ;go if not removing trailing spaces
 move.l .txip(a6),a0       ;remove trailing spaces...
 move.l a0,a1
.klc0:
 tst.b (a1)+               ;find eol
 bne .klc0
 subq.l #1,a1              ;a1 moves back from eol
.klc1:
 clr.b (a1)                ;delimit where reached
 cmp.l a1,a0               ;go if line empty
 beq .dims
 cmp.b #32,-(a1)           ;trailing space?
 beq .klc1                 ;yes, chop it
 bra .dims

.tabk:                     ;* tab key  ^^^^
 move.w .crsr(a6),d0
 and.l #$FFF8,d0
 addq.w #8,d0              ;d0 to next div by 8 tab

 move.l d1,-(a7)
 move.w #253,d1            ;d1 = 253 or max line width - 1 if any
 tst.w .maxc(a6)
 beq.s .tklm
 move.w .maxc(a6),d1
 subq.w #1,d1
.tklm:
 cmp.w d1,d0
 bls.s .tkpt
 move.w d1,d0              ;max value of d0 is 254 / max line width
.tkpt:
 move.l (a7)+,d1
 move.w d0,.crsr(a6)       ;set new crsr posn

 move.l .txip(a6),a0       ;point a0 to eol
 move.l a0,a1
 add.w .crsr(a6),a1        ;a1 is where crsr is
.tkeo:
 tst.b (a0)+
 bne .tkeo
 subq.l #1,a0
 cmp.l a1,a0               ;ok if a0 >= a1 (eol >= crsr)
 bcc .dims

 bset #7,xxp_chnd(a4)      ;else insert spaces: note text changed

 move.l .stip(a6),a2       ;point a2 to corresponding stip to a0
 add.l a0,a2
 sub.l .txip(a6),a2
 move.b (a2),d0            ;d0 = styl to copy forward
.tksp:
 move.b d0,(a2)+           ;copy styl forward, append a space
 move.b #' ',(a0)+
 cmp.l a1,a0               ;are we at new tab posn yet?
 bcs .tksp                 ;no, keep inserting
 clr.b (a0)                ;yes, delimit line there
 bra .dims

.lfar:                     ;* left arrow
 btst #0,d3
 bne.s .shla               ;go if shift
 subq.w #1,.crsr(a6)
 bcc .dims
.shla:
 clr.w .crsr(a6)
 bra .dims
.rtar:                     ;* right arrow
 btst #0,d3
 bne.s .shra               ;go if shift
 addq.w #1,.crsr(a6)
 bra .dims
.shra:
 move.w #$7FFF,.crsr(a6)
 bra .dims
.ctrl:                     ;* ctrl keys
 btst #0,d3
 bne .shct                 ;go if shifted
 cmp.b #2,d0
 beq .cbol                 ;ctrl/b -> bold
 cmp.b #3,d0
 beq .ccnt                 ;ctrl/c -> cent
 cmp.b #5,d0
 beq .cun2                 ;ctrl/e -> overline
 cmp.b #6,d0
 beq .cun3                 ;ctrl/f -> under + over line
 cmp.b #7,d0
 beq .cun4                 ;ctrl/g -> double underline
 cmp.b #8,d0
 beq .cun5                 ;ctrl/h -> overline + double underline
 cmp.b #9,d0
 beq .citl                 ;ctrl/i -> ital
 cmp.b #10,d0
 beq .cfjs                 ;ctrl/j -> fjust
 cmp.b #12,d0
 beq .cljs                 ;ctrl/l -> ljust
 cmp.b #15,d0
 beq .cout                 ;ctrl/o -> dotted underline
 cmp.b #16,d0
 beq .fixt                 ;crtl/p -> fix font
 cmp.b #18,d0
 beq .crjs                 ;ctrl/r -> rjust
 cmp.b #19,d0
 beq .cshd                 ;ctrl/s -> shadow colr
 cmp.b #21,d0
 beq .cund                 ;ctrl/u -> underline
 cmp.b #22,d0
 beq .thru                 ;ctrl/v -> strike thru
 cmp.b #23,d0
 beq .cwid                 ;ctrl/w -> wide
 cmp.b #24,d0
 beq .cxxx                 ;ctrl/x -> x out
 cmp.b #$8E,d0
 beq .csup                 ;ctrl/up -> superscript
 cmp.b #$8F,d0
 beq .csub                 ;ctrl/dn -> subscript
 bra .unre

.shct:                     ;* shift / Ctrl here
 cmp.b #3,d0
 beq .ccl4                 ;shift/ctrl/c -> complement
 cmp.b #18,d0
 beq .crst                 ;shift/ctrl/r -> restore
 cmp.b #19,d0
 beq .cspf                 ;shift/ctrl/s -> space fill
 cmp.b #21,d0
 beq .ckil                 ;shift/ctrl/u -> undo
 bra .unre
.ccl4:                     ;comp on/off
 btst #2,.forb(a6)
 bne .beep                 ;go if forbidden
 bset #7,xxp_chnd(a4)
 eori.w #-1,.comp(a6)      ;switch .comp
 bchg #5,xxp_chnd+2(a4)
 bra .dims
.cbol:                     ;bold
 btst #0,.forb+1(a6)
 bne .beep                 ;go if forbidden
 moveq #0,d0               ;else, swap bit 0
 bra .cwdp
.ccnt:                     ;centre
 btst #0,.forb(a6)
 bne .beep                 ;go if forbidden
 moveq #1,d0               ;.styl = 1
 bra .cjpk
.citl:                     ;italic
 btst #1,.forb+1(a6)
 bne .beep                 ;go if forbidden
 moveq #1,d0               ;else, swap bit 1
 bra .cwdp
.cfjs:                     ;fjust
 btst #7,.forb+1(a6)
 bne .beep                 ;bad if forbidden
 moveq #3,d0               ;.styl = 3
 bra.s .cjpk
.ckil:                     ;undo
 move.l xxp_FWork(a4),a0
 move.l a0,a1
 add.w #256,a1
 move.l a0,a2
 add.w #512,a2
 move.l a0,a3
 add.w #768,a3
 move.w #255,d1
.cklc:
 move.b (a3),d0
 move.b (a1),(a3)+
 move.b d0,(a1)+
 move.b (a2),d0
 move.b (a0),(a2)+
 move.b d0,(a0)+
 dbra d1,.cklc
 move.w .rdcs(a6),d0
 move.w .crsr(a6),.rdcs(a6)
 move.w d0,.crsr(a6)
 move.w .rdty(a6),d0
 move.w .ltyp(a6),.rdty(a6)
 move.w d0,.ltyp(a6)
 move.w .rdcp(a6),d0
 move.w .comp(a6),.rdcp(a6)
 move.w d0,.comp(a6)
 move.l .rdch(a6),d0
 move.l xxp_chnd(a4),.rdch(a6)
 move.l d0,xxp_chnd(a6)
 bra .dims
.cljs:                     ;ljust
 btst #1,.forb(a6)
 bne .beep                 ;go if forbidden
 moveq #0,d0               ;.styl = 0
.cjpk:
 bset #7,xxp_chnd(a4)
 bset #2,xxp_chnd+2(a4)    ;set bit 10 of xxp_chnd ( = ltyp changed)
 and.b #$FC,xxp_chnd+2(a4)
 or.b d0,xxp_chnd+2(a4)    ;note new ltyp in xxp_chnd
 move.w d0,.ltyp(a6)       ;fix .ltyp
 bra .dims
.crst:                     ;restore
 move.l xxp_FWork(a4),a0
 move.l a0,a1
 add.w #256,a1
 move.l a0,a2
 add.w #1024,a2
 move.l a0,a3
 add.w #1280,a3
.cstc:
 move.b (a3)+,(a1)+
 move.b (a2)+,(a0)+
 bne .cstc
 move.w .ogcs(a6),.crsr(a6)
 move.w .ogty(a6),.ltyp(a6)
 move.w .ogcp(a6),.comp(a6)
 move.l .ogch(a6),xxp_chnd(a4)
 bra .dims
.crjs:                     ;rjust
 btst #6,.forb+1(a6)
 bne .beep                 ;go if forbidden
 moveq #2,d0               ;.styl = 2
 bra .cjpk
.cspf:                     ;space fill
 cmp.b #255,.chrs(a6)
 beq .dims                 ;don't do if already 255 chrs
 move.l .txip(a6),a0
 move.l .stip(a6),a1
 add.w .crsr(a6),a0        ;a0,a1 = addr of crsr in text,styl
 add.w .crsr(a6),a1
.cspt:
 move.l a0,a2              ;a2,a3 scan fwd
 move.l a1,a3
.cspe:
 addq.l #1,a3              ;find eol
 tst.b (a2)+
 bne .cspe
.csph:
 move.b -1(a3),(a3)        ;shift fwd back to crsr
 move.b -1(a2),(a2)
 subq.l #1,a3
 subq.l #1,a2
 cmp.l a0,a2
 bne .csph
 move.b #' ',(a2)          ;fill with a space
 bsr .totl                 ;get text width
 tst.w .maxw(a6)
 beq.w .cspw               ;go if no width limit
 cmp.w .maxw(a6),d7        ;too wide?
 bgt.s .cspg               ;yes, go
.cspw:
 cmp.w .maxc(a6),d5        ;too many chrs?
 bgt.s .cspg               ;yes, go
 addq.w #1,.crsr(a6)       ;no, bump crsr
 bra .cspt                 ;& continue
.cspg:
 move.b 1(a3),(a3)         ;remove final space
 move.b 1(a2),(a2)
 beq .dims                 ;& recycle
 addq.l #1,a3
 addq.l #1,a2
 bra .cspg

.cund:                     ;underline
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$04,d0             ;bitmask ..0001..
 bra .cwd2

.cun2:                     ;overline
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$0C,d0             ;bitmask ..0011..
 bra .cwd2

.cun3:                     ;under + over
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$14,d0             ;bitmask ..0101..
 bra .cwd2

.cun4:                     ;dbl under
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$18,d0             ;bitmask ..0110..
 bra .cwd2

.cun5:                     ;dbl under + over
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$1C,d0             ;bitmask ..0111..
 bra .cwd2

.csup:                     ;superscript
 btst #3,.forb(a6)
 bne .beep                 ;go if forbidden
 moveq #$08,d0             ;bitmask  ..0010..
 move.l xxp_FSuite(a4),a0
 move.w .font(a6),d1
 mulu #xxp_fsiz,d1
 add.l d1,a0
 tst.l xxp_ital(a0)        ;check half height exists
 bne .cwd2
 move.w .font(a6),d0
 bsr TLSuper               ;else, create half height
 beq .beep                 ;bad if can't
 moveq #$08,d0
 bra .cwd2

.csub:                     ;subscript
 btst #3,.forb(a6)
 bne .beep                 ;go if forbidden
 moveq #$10,d0             ;bitmask ..0100..
 move.l xxp_FSuite(a4),a0
 move.w .font(a6),d1
 add.l d1,a0
 tst.l xxp_ital(a0)        ;check half height exists
 bne .cwd2
 move.w .font(a6),d0
 bsr TLSuper               ;else, create half height
 beq .beep                 ;bad if can't
 moveq #$10,d0
 bra .cwd2

.cout:                     ;dotted underline
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$20,d0             ;bitmask ..1000..
 bra .cwd2

.thru:                     ;strike thru
 btst #2,.forb+1(a6)
 bne .beep
 moveq #$24,d0             ;bitmask ..1001..
 bra .cwd2

.cshd:                     ;shadow
 btst #5,.forb+1(a6)
 bne .beep                 ;go if forbidden
 moveq #6,d0               ;else, swap bit 6
 bra .cwdp

.cwid:                     ;wide
 btst #3,.forb+1(a6)
 bne .beep                 ;go if forbidden
 moveq #7,d0               ;else, swap bit 7
 move.l xxp_FSuite(a4),a0
 move.w .font(a6),d1
 mulu #xxp_fsiz,d1
 add.l d1,a0
 tst.l xxp_bold(a0)        ;check double width exists
 bne.s .cwdp
 move.w .font(a6),d0
 bsr TLWide                ;else, create double width
 beq .beep                 ;bad if can't
 moveq #7,d0

.cwdp:                     ;change styl bitnum d0
 bset #7,xxp_chnd(a4)      ;note changed
 move.l .txip(a6),a0
 add.w .crsr(a6),a0        ;a0 scans text
 move.l .stip(a6),a1
 add.w .crsr(a6),a1        ;a1 scans styl
.cwdd:
 bchg d0,(a1)+             ;swap next styl bit
 tst.b (a0)+               ;until eol
 bne .cwdd
 bra .dims

.cwd2:                     ;move und/up/sub forward  d0=bits 2-5
 bset #7,xxp_chnd(a4)      ;note changed
 move.l .txip(a6),a0
 add.w .crsr(a0),a0        ;a0 scans text
 move.l .stip(a6),a1
 add.w .crsr(a6),a1        ;a1 scans style
 move.b (a1),d1
 and.b #$3C,d1             ;get bits 2-5 of style bit
 cmp.b d0,d1               ;same as mask?
 bne.s .cw2d               ;no, use mask
 moveq #0,d0               ;else, switch bits 2-5 off
.cw2d:
 move.b (a1),d1            ;get styl byte
 and.b #$C3,d1             ;kill bits 2-5
 or.b d0,d1                ;insert new bits 2-5
 move.b d1,(a1)+           ;save new styl byte
 tst.b (a0)+
 bne .cw2d                 ;until eol
 bra .dims

.fixt:                     ;fixed/proportional
 tst.w  .ifix(a6)
 beq .wait                 ;go if font always fixed
 btst #4,.forb+1(a6)
 bne .beep
 bset #7,xxp_chnd(a4)
 tst.w .ifix(a6)
 bmi.s .fxfx
 bclr #3,xxp_chnd+2(a4)    ;clear bit 11
 move.w #-1,.ifix(a6)      ;switch prop(-1)/fixed(+1)
 bra .dims
.fxfx:
 bset #3,xxp_chnd+2(a4)    ;set bit 11
 move.w #1,.ifix(a6)
 bra .dims

.cxxx:                     ;x out
 bset #7,xxp_chnd(a4)
 move.l .txip(a6),a0
 clr.b (a0)
 bra .dims

.beep:                     ;here if action forbidden
 movem.l d0-d1/a0-a1/a6,-(a7)
 move.l xxp_Screen(a4),a0
 move.l xxp_intb(a4),a6
 jsr _LVODisplayBeep(a6)
 movem.l (a7)+,d0-d1/a0-a1/a6
 bra .dims
.mens:                     ;* menu selection
 cmp.w .menu(a6),d1
 bne .menn                 ;only if menu = xxp_xmenu
 tst.w d2
 bmi .wait
 beq.s .men1               ; 1 -> font style sub-menu
 cmp.w #2,d2
 bcs .men2                 ; 2 -> underline style sub-menu
 beq .men3
 cmp.w #4,d2               ; 3 -> justification sub-menu
 bcs .ccl4                 ; 4 complement
 beq .cxxx                 ; 5 erase
 cmp.w #6,d2
 bcs .ckil                 ; 6 undo
 beq .crst                 ; 7 restore
 cmp.w #8,d2
 bcs .cspf                 ; 8 space-fill
 bra .wait
.men1:
 tst.w d3
 bmi .wait
 beq .cbol                 ; 1,1 bold
 cmp.w #2,d3
 bcs .citl                 ; 1,2 italic
 beq .cwid                 ; 1,3 wide
 cmp.w #4,d3
 bcs .cshd                 ; 1,4 shadow
 beq .csup                 ; 1,5 superscript
 cmp.w #6,d3
 bcs .csub                 ; 1,6 subscript
 bra .wait

.men2:
 tst.w d3
 bcs .wait
 beq .cund                 ; 2,1 single underline
 cmp.w #2,d3
 bcs .cun2                 ; 2,2 overline
 beq .cun3                 ; 2,3 over+underline
 cmp.w #4,d3
 bcs .cun4                 ; 2,4 dbl underline
 beq .cun5                 ; 2,5 double under + overline
 cmp.w #6,d3
 bcs .cout                 ; 2,6 dotted underline
 beq .thru                 ; 2,7 strike thru
 bra .wait

.men3:
 tst.w d3
 bcs .wait
 beq .crjs                 ; 3,1 right justify
 cmp.w #2,d3
 bcs .cfjs                 ; 3,2 full justify
 beq .ccnt                 ; 3,3 centre
 cmp.w #4,d3
 bcs .cljs                 ; 3,4 left justify
 beq .fixt                 ; 3,5 force fixed
 bra .wait
.menn:
 btst #4,.forb(a6)
 bne .wait                 ;ignore if return forbidden
 move.w #6,.code(a6)       ;return code = 6
 bra .kill
.lfam:                     ;* left amiga keys  (all unrecognised)
.rtam:                     ;* right amiga keys (all unrecognised)
.unrc:                     ;* unrecognised TLKeyboard (not menu, ctrl)
 btst #6,.forb(a6)
 bne .wait                 ;don't return if forbid
 bra.s .unry               ;else quit
.unre:
 btst #5,.forb(a6)         ;don't return if forbid
 bne .wait
.unry:
 move.w #7,.code(a6)       ;return code = 7
 bra .kill
.offw:                     ;* clicked off tablet
 move.w #5,.code(a6)       ;return code = 5
 bra .kill
.clik:                     ;* line clicked
 sub.w xxp_LeftEdge(a5),d1 ;make d1,d2 (coords) rel to printable area
 bcs .offw                 ;go if off printable area
 sub.w xxp_TopEdge(a5),d2
 bcs .offw
 sub.w .tabx+2(a6),d1      ;make d1,d2 rel to tablet
 bcs .offw                 ;go if off tablet
 sub.w .taby+2(a6),d2
 bcs .offw
 cmp.w .tabw+2(a6),d1
 bcc .offw
 cmp.w .tabh+2(a6),d2
 bcc .offw

.clkp:
 move.w #-1,.crsr(a6)      ;try increasing text width until d1 < crsr rhs
.clkn:
 addq.w #1,.crsr(a6)       ;crsr = 0+
 moveq #0,d0
 move.w .crsr(a6),d0       ;d0 = proposed crsr
 cmp.w .chrs(a6),d0        ;crsr >= chrs?
 bcc .dims                 ;yes, put crsr here
 move.l .stip(a6),a0       ;a0 = text
 move.l a0,.cura(a6)       ;set proposed crsr
 add.l d0,.cura(a6)

 bsr .swap
 bsr .totl                 ;get cursor posn (swap if reversed)
 bsr .swap

 tst.w .revs(a6)           ;go if not reversed
 beq.s .clkk

 cmp.w d6,d1               ;xpos of clik >= lhs crsr?
 bcs .clkn                 ;no, keep looking
 bra .dims                 ;yes, put crsr here

.clkk:
 cmp.w d4,d1               ;xpos of clik < rhs crsr?
 bcc .clkn                 ;no, keep looking
 bra .dims                 ;yes, put crsr here

;*** TLReqedit - line too long, & error conditions ***

; exits           .dims     recycle
;                 .kill     quit (with contin line)

.trnc:                     ;* truncate line
 bset #7,xxp_chnd(a4)      ;set bit 31 of chnd = text changed
 move.l .txip(a6),a0
.tueo:
 tst.b (a0)+
 bne .tueo
 subq.l #1,a0              ;point a0 to line delimiter
 cmp.w #1,.task(a6)
 beq.s .cont               ;go if continuation line
.chop:
 clr.b -(a0)               ;remove final chr
 bra .dims                 ;& try again
.cont:
 move.w #4,.code(a6)
 move.l a0,a1
.cons:
 cmp.b #32,-(a1)           ;find last space in text
 beq.s .cogt
 cmp.l .txip(a6),a1        ;if no spaces, simply chop last chr
 bne .cons
 bra .chop                 ;(truncate if no space found)
.cogt:
 move.l a1,a0              ;a0 = space
 move.l a0,d0
 sub.l .txip(a6),d0        ;d0 = tab of space
 move.l .stip(a6),a1
 add.l d0,a1               ;a1 = styl of space
 clr.b (a0)+               ;delimit line, point a0 to text after
 addq.l #1,a1              ;point a1 to styl after
 moveq #0,d1
 move.w .crsr(a6),d1       ;d1 = crsr
 cmp.w d0,d1
 bcs.s .col1               ;go if crsr on 1st line
 sub.w d0,d1
 subq.w #1,d1              ;make crsr rel to 2nd line
 bcc.s .col2
 moveq #0,d1
.col2:
 bset #6,xxp_chnd+2(a4)    ;set bit 14 on xxp_chnd (=crsr on contin line)
.col1:
 move.w d1,.crsr(a6)       ;set crsr
 move.l a6,a2
 add.w #.rdot,a2
 move.l a6,a3
 add.w #.rdos,a3
.cotf:
 move.b (a1)+,(a3)+        ;tfr 2nd line text to FWork+512
 move.b (a0)+,(a2)+        ;tfr 2nd line styl to FWork+768
 bne .cotf
 bset #7,xxp_chnd+2(a4)    ;set bit 15 of xxp_chnd = contin line exists
 bra .kill

.exnp:                     ;* exit without printing
 move.w #2,.code(a6)       ;return code = 2
 move.w .chrs(a6),xxp_valu(a4)
 move.w .wdth(a6),xxp_valu+2(a4)
 move.w .cslf(a6),xxp_chnd(a4)
 move.w .csrt(a6),xxp_chnd+2(a4)
 clr.l xxp_crsr(a4)
 move.w .crsr(a6),xxp_crsr+2(a4)
 bmi .wrap                 ;go if no crsr

 move.l .txip(a6),a0       ;restore chr under crsr
 move.w .crsr(a6),d0
 move.b .csrc+1(a6),1(a0,d0.w)
 move.b .csrc(a6),0(a0,d0.w)
 bra .wrap

.badr:                     ;* exit: resized & xxp_xresz = 0
 move.w #12,.code(a6)
 bra.s .badw

.bado:                     ;* exit: can't obey fixed offset
 move.w #10,.code(a6)      ;return code = 10
 move.w .crsr(a6),d0
 bmi.s .badw               ;go if no crsr
 move.l .txip(a6),a0       ;else, restore chr under crsr
 move.b .csrc+1(a6),1(a0,d0.w)
 move.b .csrc(a6),0(a0,d0.w)
 bra.s .badw

.badx:                     ;* exit: window too narrow
 move.w #8,.code(a6)       ;return code = 8
 bra.s .badw

.bady:                     ;* exit: window too shallow
 move.w #9,.code(a6)       ;return code = 9
 bra.s .badw

.badf:                     ;* exit: can't attach font
 move.w #11,.code(a6)      ;return code = 11

.badw:                     ;* wrap up after bad exit
 bset #4,xxp_chnd+2(a4)    ;set bit 12 of xxp_chnd for retn codes 8-11
 clr.l xxp_crsr(a4)        ;record final crsr
 move.w .crsr(a6),xxp_crsr+2(a4)

*** TLreqedit - close down ***

;exits            none
;internal bsr's   none

.exit:                     ;* exit from TLReqedit
 move.w .offs(a6),d0
 or.w xxp_chnd(a4),d0
 move.w d0,xxp_chnd(a4)    ;offset to xxp_chnd bits 16-30
 cmp.w #3,.task(a6)
 beq.s .exhx               ;if task = 3, get hex value
 cmp.w #2,.task(a6)
 bne.s .wrap               ;if task = 2, get dec value
 move.l .txip(a6),a0       ;* get decimal value to xxp_valu
 moveq #0,d0
 moveq #0,d1
.exnd:
 move.b (a0)+,d1
 sub.b #'0',d1
 bcs.s .exvl
 cmp.b #10,d1
 bcc.s .exvl
 move.l d0,d2
 lsl.l #2,d0
 add.l d2,d0
 lsl.l #1,d0
 add.l d1,d0
 bra .exnd
.exhx:                     ;* get hex value to xxp_valu
 move.l .txip(a6),a0
 moveq #0,d0
 moveq #0,d1
.exnh:
 move.b (a0)+,d1
 sub.b #'0',d1
 bcs.s .exvl
 cmp.b #10,d1
 bcs.s .excl
 sub.b #'A'-':',d1
 cmp.b #16,d1
 bcc.s .exvl
.excl:
 lsl.l #4,d0
 add.l d1,d0
 bra .exnh
.exvl:
 move.l d0,xxp_valu(a4)
.wrap:                     ;* embed Ctrl's if required

.wpcu:
 tst.w .ina4(a6)           ;* if input was a4, put output to a4
 beq.s .excu
 move.l .txip(a6),a0
 cmp.l a0,a4
 beq.s .excu
 move.l a4,a1
.wptf:
 move.b (a0)+,(a1)+
 bne .wptf

.excu:                     ;* clear stack, exit from TLReqedit
 move.l (a7)+,xxp_Fsty(a5)
 move.l (a7)+,xxp_Fnum(a5)
 move.l (a7)+,xxp_IText(a5)
 move.l (a7)+,xxp_FrontPen(a5)
 move.l (a7)+,xxp_Help(a4)
 move.l (a7)+,xxp_strg(a4)
 move.w #-1,xxp_Attc(a5)
 clr.l (a7)
 move.w .code(a6),2(a7)    ;put return code in stack D0
 movem.l (a7)+,d0-d7/a0-a6
 cmp.w #8,d0               ;to .badd if D0 is 8-11 (error condition)
 bcs.s .good
 cmp.w #12,d0
 bcc.s .badd

.good:
 tst.l (a7)                ;NE = good (D0 not 8-11)
 rts

.badd:
 cmp.w d0,d0               ;EQ = bad  (D0 8-11)
 rts

;*** TLReqedit - internal subroutines ***

.preb:                     ;** print segment to EBmap
 move.l a3,-(a7)
 move.l a6,a3
 add.w #.wsuw,a3
 move.w xxp_Tspc(a5),xxp_Tspc(a3)
 move.l xxp_xmin(a5),xxp_xmin(a3)
 move.l a3,a5
 move.l (a7)+,a3
 bsr.s .text
 move.l xxp_AcWind(a4),a5
 rts

.text:                     ;** print text

;on call:  a0-a2 = text  a1-a3 = styl
;          a5 = xxp_AcWind, or part xxp_wsuw with xxp_ERport
;          d6 = xpos rel to tablet left (if a5 = AcWind)
;          d0 = text width

 movem.l d0-d3/a0-a3/a6,-(a7) ;save all

 move.w .clr0(a6),xxp_FrontPen(a5) ;set pens

 move.b xxp_BackPen(a5),d3 ;remember background pen

 move.b #RP_JAM2,xxp_DrawMode(a5) ;set draw mode
 tst.w .jam1(a6)
 beq.s .txmd
 move.b #RP_JAM1,xxp_DrawMode(a5) ;(jam1 if xxp_xjam1)
.txmd:

 cmp.l .cura(a6),a1         ;if printing crsr, swap pens
 bne.s .txtc
 move.b xxp_FrontPen(a5),d0
 move.b xxp_BackPen(a5),xxp_FrontPen(a5)
 move.b d0,xxp_BackPen(a5)
.txtc:

 tst.w .comp(a6)           ;if complementing line, comp pens
 bpl.s .txtm
 eori.w #-1,xxp_FrontPen(a5)
.txtm:

 moveq #0,d0               ;set xxp_Fsty
 move.b (a1),d0
 move.w d0,xxp_Fsty(a5)

 move.l a1,a3              ;save styl pointer in a3
 move.l xxp_WPort(a5),a1   ;a1 = WPort/ERport
 move.w xxp_Tspc(a5),rp_TxSpacing(a1) ;set TxSpacing
 bsr TLWfont               ;attach font,pens to rastport if required
 bsr TLWpens

 moveq #0,d0               ;* get coords of print posn in rastport
 moveq #0,d1
 cmp.l xxp_AcWind(a4),a5   ;at 0,0 if ERport
 bne.s .move
 move.w .tabx+2(a6),d0     ;else, at .tabx, .taby
 add.w d6,d0               ;add xpos within .tabx
 sub.w .offs(a6),d0        ;sub offset
 move.w .taby+2(a6),d1
 add.w xxp_LeftEdge(a5),d0 ;posn rel to printable area of window
 add.w xxp_TopEdge(a5),d1
.move:

 add.w .ulin(a6),d1        ;d1 is posn of underline
 add.w xxp_xmin(a5),d0     ;add xmin (set by .fore)

 tst.w .ifix(a6)           ;see if we are forcing fixed width
 ble.s .nfix
 tst.w .ifof(a6)           ;go if no bumping of width was required
 beq.s .nfix

 tst.w .jam1(a6)           ;go if jam1
 bne.s .nfix

 movem.l a0-a1/d0-d4,-(a7) ;clear rhs of fixed width by amt bumped
 moveq #0,d4               ;d4 = background pen
 move.b d3,d4              ;d0,d1 = text print posn
 sub.w .ulin(a6),d1        ;d0,d1 = tablet print posn topleft
 move.l 28(a7),d2          ;d2 = stack d0 = text segment width
 move.l .tabh(a6),d3       ;d3 = tablet height
 bset #29,d0               ;use d4 for pen
 bsr TLWCheck              ;abort if window resized
 beq.s .nfxc
 add.w #28,a7
 bra .txtb
.nfxc
 move.l xxp_WPort(a5),a0
 bset #31,d1
 bsr TLReqarea             ;clear area where chr width bumped
 bsr TLWpens               ;restore pens after TLReqarea
 movem.l (a7)+,a0-a1/d0-d4
.nfix:

 btst #5,(a3)              ;see if super/sub
 bne .movr
 btst #2,(a3)              ;not if bit 2 or 5 set
 bne .movr
 btst #3,(a3)              ;go if not superscript
 beq .msbr
 btst #4,(a3)
 bne .movr

 move.l a1,-(a7)           ;* reposn, clear for superscript
 movem.l a0/d0-d4,-(a7)    ;a1/a0/d0-d4 = 28 bytes added to stack
 move.l xxp_FSuite(a4),a0
 move.w .font(a6),d4
 mulu #xxp_fsiz,d4
 add.l d4,a0
 tst.b (a3)                ;go unless super + wide
 bpl.s .movn
 move.l xxp_boit(a0),d4    ;get half height + wide font
 bne.s .movk               ;go if opened, else use unwide
.movn:
 move.l xxp_ital(a0),d4    ;get half height font
 bne.s .movk
 move.l xxp_plain(a0),d4   ;(or full height if it wasn't opened)
.movk:
 move.l d4,a1              ;a1 = half height font

 tst.w .jam1(a6)           ;go if jam1 (don't clear superscript area)
 bne.s .mvcc

 moveq #0,d4
 move.b d3,d4              ;d4 = background pen
 move.l (a7),d0            ;get stack print posns
 move.l 4(a7),d1
 sub.w .ulin(a6),d1        ;d0,d1 = print posn topleft
 move.l 28(a7),d2          ;d2 = stack d0 = text segment width
 move.l .tabh(a6),d3       ;d3 = text height
 bset #29,d0
 move.l xxp_WPort(a5),a0
 bset #31,d1
 bsr TLWCheck              ;abort if window resized
 beq.s .movc
 add.w #28,a7
 bra .txtb
.movc
 bsr TLReqarea             ;clear area where superscript printed
 bsr TLWpens               ;restore pen after TLReqarea

.mvcc:
 movem.l (a7)+,a0/d0-d4
 sub.w .ulin(a6),d1        ;sub full height baseline
 add.w tf_Baseline(a1),d1  ;add half height baseline
 move.l (a7)+,a1
 bra .movr

.msbr:
 btst #4,(a3)              ;go unless subscript
 beq .movr

 move.l a1,-(a7)           ;* reposn, clear for subscript
 movem.l a0/d0-d4,-(a7)    ;a1/a0/d0-d4 = 28 bytes added to stack
 move.l xxp_FSuite(a4),a0
 move.w .font(a6),d4
 mulu #xxp_fsiz,d4
 add.l d4,a0
 tst.b (a3)                ;go unless sub + wide
 bpl.s .msbn
 move.l xxp_boit(a0),d4    ;get half height + wide font
 bne.s .msbk               ;go if opened, else use unwide
.msbn:
 move.l xxp_ital(a0),d4    ;get half height font
 bne.s .msbk
 move.l xxp_plain(a0),d4   ;(or full height if it wasn't opened)
.msbk:
 move.l d4,a1              ;a1 = half height font

 tst.w .jam1(a6)           ;go if jam1 (don't clear subscript area)
 bne.s .mscc

 moveq #0,d4
 move.b d3,d4              ;d4 = background pen
 move.l (a7),d0            ;get stack print posns
 move.l 4(a7),d1
 sub.w .ulin(a6),d1        ;d0,d1 = print posn topleft
 move.l 28(a7),d2          ;d2 = stack d0 = text segment width
 move.l .tabh(a6),d3       ;d3 = text height
 bset #29,d0
 move.l xxp_WPort(a5),a0
 bset #31,d1
 bsr TLWCheck              ;abort if window resized
 beq.s .msbc
 add.w #28,a7
 bra .txtb
.msbc
 bsr TLReqarea             ;clear area where subscript printed
 bsr TLWpens               ;restore pen after TLReqarea

.mscc:
 movem.l (a7)+,a0/d0-d4
 cmp.w #3,.case(a6)        ;keep baseline if small caps
 beq.s .yscp
 sub.w .ulin(a6),d1        ;sub full height baseline
 add.l .tabh(a6),d1        ;to bottom of tablet
 sub.w tf_YSize(a1),d1     ;to top of half height text
 add.w tf_Baseline(a1),d1  ;add half height baseline
.yscp:
 move.l (a7)+,a1

.movr:                     ;* move rastport print posn
 move.l xxp_gfxb(a4),a6
 move.l d0,d2              ;d2 = xpos printed at
 movem.l d1/a0-a1,-(a7)
 jsr _LVOMove(a6)
 movem.l (a7)+,d1/a0-a1
 move.l a2,d0
 sub.l a0,d0               ;d0 = no. of chrs

 btst #6,(a3)              ;go if not shadow print
 beq .txdo

 move.l xxp_FrontPen(a5),-(a7) ;* shadow print
 movem.l d0-d5/a0-a1,-(a7)
 move.l xxp_FWork(a4),a6
 move.b .shad+1(a6),xxp_FrontPen(a5) ;front pen for shadow
 move.l xxp_gfxb(a4),a6
 bsr TLWpens               ;set shadow pens
 bsr TLWCheck
 bne .shbd                 ;bad if resized
 jsr _LVOText(a6)          ;print shadow text
 movem.l (a7)+,d0-d5/a0-a1
 movem.l d0-d5/a0-a1,-(a7)
 move.w rp_cp_x(a1),d4     ;d2 = lhs, d4 = rhs
 subq.w #1,d4
 move.l d1,d3              ;d3 = top
 move.l rp_Font(a1),a0
 sub.w tf_Baseline(a0),d3  ;d3 rel to top of text
 move.l d3,d5
 add.w tf_YSize(a0),d5     ;d5 = bot
 subq.w #1,d5
 move.l xxp_FWork(a4),a6   ;d0,d1 = dx,dy from xxp_xshdv
 moveq #0,d0
 move.b .shad+3(a6),d0
 ext.w d0
 neg.w d0
 moveq #0,d1
 move.b .shad+2(a6),d1
 ext.w d1
 neg.w d1
 move.l xxp_gfxb(a4),a6
 bsr TLWCheck
 bne.s .shbd               ;bad if resized
 jsr _LVOScrollRaster(a6)  ;scroll shadow
 movem.l (a7)+,d0-d5/a0-a1
 move.l (a7),xxp_FrontPen(a5) ;original pens, jam1
 movem.l d0-d5/a0-a1,-(a7)
 move.b #RP_JAM1,xxp_DrawMode(a5)
 movem.l d0-d1/a0-a1,-(a7)
 move.l d2,d0
 jsr _LVOMove(a6)          ;move back to start of text
 movem.l (a7)+,d0-d1/a0-a1
 bsr TLWpens
 bsr TLWCheck              ;bad if resized
 bne.s .shbd
 jsr _LVOText(a6)          ;jam1 text over shadow
 movem.l (a7)+,d0-d5/a0-a1
 move.l (a7)+,xxp_FrontPen(a5) ;restore pens, drawmode
 bra.s .txun
.shbd:
 movem.l (a7)+,d0-d5/a0-a1
 move.l (a7)+,xxp_FrontPen(a5)
 bra .txtb

.txdo:
 bsr TLWCheck              ;* go if window resized
 bne .txtb

 jsr _LVOText(a6)          ;* print the text

.txun:
 move.b (a3),d0            ;get underlining bits
 and.b #$3C,d0
 beq .txtg                 ;go if none
 cmp.b #$08,d0
 beq .txtg                 ;go if super/subscript
 cmp.b #$10,d0
 beq .txtg

.yund:                     ;* under/overlining

 move.l xxp_WPort(a5),a1   ;get posn for single underline
 move.l rp_Font(a1),a0
 move.w tf_Baseline(a0),d0
 addq.w #1,d0
 cmp.w tf_YSize(a0),d0
 bcc .txtg                 ;none if no room for underline (unlikely)

 move.w rp_cp_x(a1),d0
 cmp.w d0,d2               ;none if text width = 0 (unlikely)
 beq .txtg

 subq.w #1,d0              ;d0,d3 = rhs xpos of text
 move.w d0,d3
 move.w rp_cp_y(a1),d1     ;} d2=lhs d3=rhs d1=baseline a1=port

 btst #5,(a3)              ;go if not bit 5
 beq.s .sngr
 btst #2,(a3)              ;bit 5+2 = strike thru
 bne .sthr
 move.w #$CCCC,rp_LinePtrn(a1) ;bit 5 = dotted under
 bra.s .sing

.sngr:                     ;overline only has .01.
 btst #4,(a3)
 bne.s .sing
 btst #3,(a3)
 bne.s .over               ;go if overline only

.sing:                     ;do a single underline
 addq.w #1,d1              ;go to 1 pixel under .ulin
 movem.l d1/a1,-(a7)
 jsr _LVOMove(a6)          ;move to end of underline
 movem.l (a7)+,d1/a1
 move.l d2,d0              ;d0 = start of underline
 bsr TLWCheck              ;bad if window resized
 bne .ttbr
 movem.l d1/a1,-(a7)
 jsr _LVODraw(a6)          ;draw underline
 movem.l (a7)+,d1/a1
 move.w #-1,rp_LinePtrn(a1)

 subq.w #1,d1              ;} d2=lhs d3=rhs d1=baseline a1=port
 btst #5,(a3)
 bne .txtg
 btst #3,(a3)              ;go unless double underline
 beq.s .over

 btst #4,(a3)              ;do a double underline
 beq.s .over
 move.l rp_Font(a1),a0
 move.w tf_Baseline(a0),d0
 addq.w #3,d0
 cmp.w tf_YSize(a0),d0
 bcc.s .over               ;not if no room for double underline
 move.w d2,d0
 addq.w #3,d1              ;go to 2 pixels under 1st underline
 movem.l d1/a1,-(a7)
 jsr _LVOMove(a6)          ;move to start of 2nd underline
 movem.l (a7)+,d1/a1
 move.l d3,d0              ;d0 = rhs of underline
 bsr TLWCheck              ;bad if window resized
 bne .txtb
 movem.l d1/a1,-(a7)
 jsr _LVODraw(a6)          ;draw 2nd underline
 movem.l (a7)+,d1/a1
 subq.w #3,d1              ;} d2=lhs d2=rhs d1=baseline a1=port

.over:
 btst #2,(a3)              ;go unless overline
 beq .txtg
 btst #3,(a3)
 bne.s .ovry
 btst #4,(a3)
 beq.s .txtg
.ovry:

 move.l rp_Font(a1),a0     ;draw an overline
 sub.w tf_Baseline(a0),d1  ;d1 = top of text
 movem.l d0-d5/a1,-(a7)
 move.l d3,d4              ;scroll text down a pixel
 move.l d1,d3
 move.l d1,d5
 add.w tf_YSize(a0),d5
 subq.w #1,d5
 moveq #0,d0
 moveq #-1,d1
 bsr TLWCheck
 bne.s .ovrb
 jsr _LVOScrollRaster(a6)
 movem.l (a7)+,d0-d5/a1
 movem.l d0-d5/a1,-(a7)    ;draw the overline
 move.l d2,d0
 movem.l d1/a1,-(a7)
 jsr _LVOMove(a6)
 movem.l (a7)+,d1/a1
 move.l d3,d0
 bsr TLWCheck
 bne.s .ovrb
 jsr _LVODraw(a6)
 movem.l (a7)+,d0-d5/a1
 bra.s .txtg
.ovrb:
 movem.l (a7)+,d0-d5/a1
 bra.s .txtb

.sthr:                     ;draw a strike thru
 move.l rp_Font(a1),a0
 move.w tf_Baseline(a0),d0
 lsr.w #1,d0
 sub.w d0,d1
 move.l d2,d0
 movem.l d1/a1,-(a7)
 jsr _LVOMove(a6)
 movem.l (a7)+,d1/a1
 move.l d3,d0
 bsr TLWCheck
 bne.s .txtb
 jsr _LVODraw(a6)

.txtg:                     ;* quit from .text
 moveq #-1,d0              ;NE if good
 movem.l (a7)+,d0-d3/a0-a3/a6
 rts

.ttbr:
 move.w #-1,rp_LinePtrn(a1)

.txtb:
 moveq #0,d0               ;EQ if bad (window resized)
 movem.l (a7)+,d0-d3/a0-a3/a6
 rts

.prcp:                     ;** copy EBmap to tablet from d2 to d3 width d4
 movem.l d0-d6/a0-a1/a6,-(a7) ;save all
 move.l d2,d0              ;d0,d1 = from
 moveq #0,d1
 move.l d3,d2              ;d2,d3 = to
 add.w xxp_LeftEdge(a5),d2
 add.w .tabx+2(a6),d2
 moveq #0,d3
 add.w xxp_TopEdge(a5),d3
 add.w .taby+2(a6),d3
 move.l .tabh(a6),d5       ;d4,d5 = dims
 move.l xxp_EBmap(a4),a0   ;a0 = ebmap
 move.l xxp_WPort(a5),a1   ;a1 = rastport
 move.l xxp_gfxb(a4),a6
 move.w #$00C0,d6          ;d6 = JAM2
 bsr TLWCheck
 bne.s .prpb               ;bad if window resized
 jsr _LVOBltBitMapRastPort(a6) ;do the blit
.prpg:
 moveq #-1,d0              ;NE if good
 movem.l (a7)+,d0-d6/a0-a1/a6
 rts
.prbg:
 movem.l (a7)+,d0-d1/a0-a1
.prpb:
 moveq #0,d0               ;EQ if bad (window resized)
 movem.l (a7)+,d0-d6/a0-a1/a6
 rts

.prpq:                     ;** clear any of centre/clear offset on tablet
 movem.l d0-d3/a0-a1/a6,-(a7) ;adds 28+rts = 32 bytes to stack
 move.l d6,d2
 sub.w .offs(a6),d2        ;text offset - tab offset = amt to clear
 move.w d2,.this(a6)       ;.this = width cleared
 cmp.w .prev(a6),d2        ;is this < .prev ?
 bcs.s .prqc               ;yes, ok
 move.w .prev(a6),d2       ;no, only do .prev
 beq.s .prqg               ;or, nothing if .prev = 0
.prqc:
 move.l xxp_gfxb(a4),a6
 moveq #0,d0               ;foreground pen to 0, draw mode to jam2
 move.l xxp_WPort(a5),a1
 jsr _LVOSetAPen(a6)
 moveq #RP_JAM2,d0
 move.l xxp_WPort(a5),a1
 jsr _LVOSetDrMd(a6)
 move.l xxp_FWork(a4),a6
 move.l .tabx(a6),d0       ;d0 = lhs of tablet (rel to window)
 add.w xxp_LeftEdge(a5),d0
 add.w d0,d2
 subq.w #1,d2              ;d2 = rhs of area to be cleared
 move.l .taby(a6),d1       ;d1 = top of tablet (rel to window)
 add.w xxp_TopEdge(a5),d1
 move.l d1,d3
 add.l .tabh(a6),d3        ;d3 = bot of tablet
 subq.w #1,d3
 move.l xxp_WPort(a5),a1
 move.l xxp_gfxb(a4),a6
 bsr TLWCheck              ;go if can't (window resized)
 bne.s .prqb
 jsr _LVORectFill(a6)
.prqg:
 moveq #-1,d0
 movem.l (a7)+,d0-d3/a0-a1/a6 ;NE if ok
 rts
.prqb:
 moveq #0,d0
 movem.l (a7)+,d0-d3/a0-a1/a6 ;EQ if bad (window resized)
 rts

.prpv:                     ;** clear tablet between .this and .prev
 movem.l d0-d3/a0-a1/a6,-(a7) ;adds 28+rts = 32 bytes to stack
 moveq #0,d0
 move.b .clr0+1(a6),d0     ;background colour to foreground, drmd to jam2
 move.l xxp_WPort(a5),a1
 move.l xxp_gfxb(a4),a6
 jsr _LVOSetAPen(a6)
 moveq #RP_JAM2,d0
 move.l xxp_WPort(a5),a1
 jsr _LVOSetDrMd(a6)
 move.l xxp_FWork(a4),a6
 move.l .tabx(a6),d0       ;d0 = lhs of tablet (rel to window)
 add.w xxp_LeftEdge(a5),d0
 move.w d0,d2
 add.w .this(a6),d0        ;lhs from lhs + .this
 add.w .prev(a6),d2        ;rhs to lhs + .prev - 1
 subq.w #1,d2
 move.l .taby(a6),d1       ;d1 = top of tablet (rel to window)
 add.w xxp_TopEdge(a5),d1
 move.l d1,d3
 add.l .tabh(a6),d3        ;d3 = bot of tablet
 subq.w #1,d3
 move.l xxp_WPort(a5),a1
 move.l xxp_gfxb(a4),a6
 bsr TLWCheck              ;go if can't (window resized)
 bne.s .prvb
 jsr _LVORectFill(a6)
.prvg:
 moveq #-1,d0
 movem.l (a7)+,d0-d3/a0-a1/a6 ;NE if ok
 rts
.prvb:
 moveq #0,d0
 movem.l (a7)+,d0-d3/a0-a1/a6 ;EQ if bad (window resized)
 rts

.totl:                     ;** pre-scan the text

;saves all except results in d4-d7
;if no crsr bit is set in styl, d4 & d6 will be -1

; returns d7 = width (in pixels)
;         d6 = crsr lhs (-1 if no crsr)
;         d4 = crsr rhs (-1 if no crsr
;         d5 = no. of chrs
; if ltyp = centre/rjust, puts initial offset in .toff
; if ltyp = fjust, fixes Tspc and puts just remainder in .ljsr

 movem.l d0-d3/a0-a3,-(a7) ;save all except d4-d7
 move.w #-1,.ljsr(a6)      ;so far, no fjust remainder
 move.l .txip(a6),a0       ;a0 scans text
 move.l .stip(a6),a1       ;a1 scans styl
 move.w .cspc(a6),xxp_Tspc(a5) ;initialise xxp_Tspc
 moveq #-1,d6              ;d6,d4 will hold crsr lhs,rhs
 moveq #-1,d4
 moveq #0,d7               ;d7 holds total
.ttnx:
 tst.b (a0)                ;go if eol
 beq.s .ttqt
 bsr .fore                 ;get len of next segment
 cmp.l .cura(a6),a1
 bne.s .ttnc
 move.l d7,d6              ;d6 = crsr lhs
 move.l d7,d4
 add.l d0,d4               ;d4 = crsr rhs
 move.l a0,d3
 sub.l .txip(a6),d3        ;d3 = chrs before crsr
.ttnc:
 add.l d0,d7               ;bump total width
 move.l a2,a0              ;point a0,a1 to next segment
 move.l a3,a1
 bra .ttnx                 ;& continue
.ttqt:
 clr.w .toff(a6)           ;text offset = 0 pro-tem
 move.l a0,d5              ;d5 = chrs
 sub.l .txip(a6),d5
 tst.w .maxw(a6)           ;go if .maxw undefined
 beq .ttdn
 cmp.w .maxw(a6),d7        ;go if width >= .maxw
 bcc .ttdn
 cmp.w #1,.ltyp(a6)
 bcs .ttdn                 ;go if ljust
 beq.s .ttct               ;go if centre
 cmp.w #2,.ltyp(a6)
 beq.s .ttrj               ;go if rjust
 moveq #0,d0
 move.w .maxw(a6),d0
 sub.w d7,d0               ;adjust for full just:  d0 = total to spread
 move.w d5,d1
 subq.w #1,d1              ;d1 = no. of gaps
 ble.s .ttdn               ;go if <1
 divu d1,d0                ;d0 = quotient
 tst.w .mxjs(a6)
 beq.s .mxj0               ;force if mxjs = 0
 cmp.w .mxjs(a6),d0
 bcc.s .ttdn               ;go if >= .mxjs
.mxj0:
 move.w .maxw(a6),d7       ;width now = .maxw
 addq.w #1,d0
 add.w d0,xxp_Tspc(a5)     ;bump Tspc by quotient + 1
 subq.w #1,d0
 swap d0
 move.w d0,.ljsr(a6)       ;put remainder in .ljsr
 swap d0
 tst.l d6                  ;go if no crsr
 bmi.s .ttdn
 move.w d0,d1              ;adjust posn of crsr...
 mulu d3,d1                ;d1 = crsr * quot
 add.w d1,d6               ;which add to crsr start, end
 add.w d1,d4
 addq.w #1,d3
 cmp.w d5,d3
 bcc.s .ttrm
 add.w d0,d4               ;add bits/chr to crsr end, unless crsr is at end
.ttrm:
 subq.w #1,d3
 swap d0                   ;d0 = remainder
 move.w d0,d1
 cmp.w d3,d1               ;d1 = least of crsr tab, remainder
 ble.s .ttcy
 move.w d3,d1
.ttcy:
 add.w d1,d6               ;which add to crsr lhs, rhs
 add.w d1,d4
 cmp.w d3,d0               ;is remainder > crsr tab?
 ble.s .ttdn               ;yes, go
 addq.w #1,d4              ;no, add 1 to crsr rhs
 bra.s .ttdn
.ttct:                     ;adjust for centre
 move.w .maxw(a6),d0
 sub.w d7,d0
 lsr.w #1,d0               ;d0 = half unused dots
.ttfx:
 add.w d0,.toff(a6)        ;put offset in xxp_valu
 add.w d0,d4               ;add to posn of everything
 add.w d0,d6
 add.w d0,d7
 bra.s .ttdn
.ttrj:                     ;adjust for right just
 move.w .maxw(a6),d0
 sub.w d7,d0               ;d0 = unused dots
 bra .ttfx                 ;add to everything
.ttdn:
 movem.l (a7)+,d0-d3/a0-a3
 rts

.fore:                     ;** find end, length of segment at a0,a1
 move.l a0,a2              ;saves all except d0,a2,a3
 move.l a1,a3              ;a2,a3 scans chrs
 move.b (a1),d0            ;d0 = 1st chr styl
 addq.l #1,a2
 addq.l #1,a3              ;past 1st chr
 tst.w .ifix(a6)
 bgt.s .forp               ;first chr alone if forcing prop to be fixed
 cmp.l .cura(a6),a1
 bne.s .frcc               ;first chr alone if cursor
 bra.s .forp
.forc:
 addq.l #1,a2              ;find last chr of segment...
 addq.l #1,a3
.frcc:
 tst.b (a2)                ;eol follows?
 beq.s .forp               ;yes, end of segment
 cmp.l .cura(a6),a3        ;crsr chr follows?
 beq.s .forp               ;yes, segment ends
 cmp.l .bmpa(a6),a3        ;fjust bump follows?
 beq.s .forp               ;yes, segment ends
 cmp.b (a3),d0             ;same styl follows?
 beq .forc                 ;yes, segment continues

.forp:                     ;** alt entry point to .fore - a2,a3 already set
 movem.l d1/a1,-(a7)       ;save all except result in d0 (a2,a3 preserved)
 move.l a2,d0              ;set d0 = no. of chrs
 sub.l a0,d0
 moveq #0,d1               ;set xxp_Fsty
 move.b (a1),d1
 move.w d1,xxp_Fsty(a5)
 move.l xxp_WPort(a5),a1   ;a1 = WPort/ERport
 move.w xxp_Tspc(a5),rp_TxSpacing(a1) ;set TxSpacing
 bsr TLWfont               ;attach font to rastport if required
 move.l xxp_gfxb(a4),a6

 movem.l a0-a2,-(a7)       ;* get text extent
 sub.w #te_SIZEOF,a7
 move.l a7,a2
 jsr _LVOTextExtent(a6)
 moveq #0,d0
 move.w te_Width(a7),d0
 move.w te_Extent+4(a7),d1
 addq.w #1,d1
 sub.w d0,d1
 bcc.s .emax
 moveq #0,d1
.emax:
; btst #6,xxp_Fsty+1(a5)
; beq.s .emxg
; add.b xxp_shad+3(a5),d1   ;if shadow, add dx to xmax (no, don't, problems)
.emxg:
 move.w d1,xxp_xmax(a5)    ;set xxp_xmax
 neg.w te_Extent(a7)
 bpl.s .emin
 clr.w te_Extent(a7)
.emin:
 move.w te_Extent(a7),xxp_xmin(a5) ;set xxp_xmin
 add.w #te_SIZEOF,a7
 movem.l (a7)+,a0-a2
 move.l xxp_FWork(a4),a6
 add.w xxp_xmax(a5),d0     ;bump length by xmax, xmin
 add.w xxp_xmin(a5),d0

 tst.w .ifix(a6)           ;if forcing prop to be fixed, adjust len
 ble.s .pfgd
 clr.w .ifof(a6)           ;ifof = 0 if no adjustment made
 cmp.w .ifxv(a6),d0
 bcc.s .pfgd               ;go if width >= tf_XSize of font
 neg.w d0
 add.w .ifxv(a6),d0
 move.w d0,.ifof(a6)       ;else, set ifof = amount by which width bumped
 move.w .ifxv(a6),d0       ;& set width to tf_XSize of font

.pfgd:
 tst.b (a2)
 bne.s .pfin
 sub.w xxp_Tspc(a5),d0     ;sub Tspc from after last chr
.pfin:
 movem.l (a7)+,d1/a1       ;a2,a3 = end of string, d0 = width
 rts

.tidy:                     ;** tidy FWork+768
 tst.b xxp_chnd+2(a4)
 bpl.s .tyqt               ;go if no contin line
 movem.l d0/a0-a2,-(a7)    ;saves all
 move.l xxp_FWork(a4),a0
 move.l a0,a1
 add.w #512,a0             ;a0 = contin text
 add.w #768,a1             ;a1 = contin styl
 clr.b -1(a1)
 move.l a1,a2              ;a2 = limit of contin styl
 add.w #256,a2
.tyeo:
 addq.l #1,a1              ;find corresponding styl to
 tst.b (a0)+               ;end of text
 bne .tyeo
 subq.l #1,a1              ;a1 = byte after end of styl
 move.b -1(a1),d0          ;d0 = last byte of styl (od 0 if null)
.tytd:
 move.b d0,(a1)+           ;continue last byte of styl to eol
 cmp.l a2,a1
 bcs .tytd
 movem.l (a7)+,d0/a0-a2
.tyqt:
 rts


; TLReqedit subroutine - swap text around for reverse printing
; (note: if crsr is at eol, it has a spc poked there before .swap called)

.swap:
 tst.w .revs(a6)           ;go if printing not reversed
 beq.s .szqt

 movem.l d0-d1/a0-a3,-(a7) ;save all

 move.l xxp_FWork(a4),a0   ;tfr chrs from FWork,FWork+256 to buff,buff+256
 move.l a0,a1
 add.w #256,a1
 move.l a4,a2
 move.l a2,a3
 add.w #256,a3
.swtf:
 move.b (a1)+,(a3)+
 move.b (a0)+,(a2)+
 bne .swtf

 subq.l #2,a2              ;a2 points to last chr of text
 subq.l #1,a3              ;a3 points to delimiter of styl
 move.l xxp_FWork(a4),a0   ;a0 points to FWork
 move.l a0,a1
 add.w #256,a1             ;a1 points to styl

 tst.w .crsr(a6)           ;go if no crsr
 bmi.s .swnc
 move.l a2,d0              ;move crsr to mirror image
 sub.l a4,d0
 sub.w .crsr(a6),d0
 move.w d0,.crsr(a6)
 add.l a1,d0
 move.l d0,.cura(a6)       ;fix .cura
.swnc:

 move.l .bmpa(a6),d1       ;fix .bmpa, if any
 beq.s .swnb
 sub.l a1,d1
 move.l a2,d0
 sub.l a4,d0
 sub.w d1,d0
 add.l a1,d0
 move.l d1,.bmpa(a6)
.swnb:

 addq.l #1,a2              ;point a2 to delimiter of text
.swpt:
 move.b -(a2),(a0)+        ;tfr text backward to FWork
 move.b -(a3),(a1)+        ;tfr styl backward to FWork+256
 cmp.l a2,a4
 bne .swpt                 ;until everything reversed

 movem.l (a7)+,d0-d1/a0-a3

.szqt:
 rts


; local strings for TLReqedit
.str: dc.b 0
 dc.b 'The following keyboard options MAY be currently available...',0 ;1
 dc.b '(The screen will beep if you choose a currently forbidden option)',0
 dc.b ' ',0 ;3
 dc.b 'Del        Delete a character      Crtl L  Left justify line',0 ;4
 dc.b 'Shift Del  Delete line forward     Ctrl R  Right justify line',0 ;5
 dc.b 'Backspace  Cursor left, Delete     Ctrl J  Full justify line',0 ;6
 dc.b 'Shift Bsp  Delete line backward    Ctrl C  Centre line',0 ;7
 dc.b 'Tab        To line start/end       Ctrl P  Force Fixed',0 ;8
 dc.b '                                   Ctrl B  Bold font on/off',0 ;9
 dc.b 'Ctrl X     X-out (erase) line      Ctrl I  Italic font on/off',0 ;10
 dc.b '                                   Ctrl O  Dotted underline',0
 dc.b 'Return   Exit line/Accept          Ctrl S  Shadow font',0
 dc.b 'Esc      Exit line/Cancel          Ctrl W  Wide font',0 ;13
 dc.b '                                   Ctrl U  Underline',0 ;14
 dc.b 'Shift Ctrl S  Space fill           Ctrl Up arrow  Superscript',0 ;15
 dc.b 'Shift Ctrl C  Complement line      Ctrl Down arr  Subscript',0 ;16
 dc.b 'Shift Ctrl U  Undo last action     Ctrl E,F,G,H various underline',0
 dc.b 'Shift Ctrl R  Restore (undo all)   Ctrl V  Strike through',0 ;18
 ds.w 0


*>>>> enter a password    (D0=maxlen)
TLPassword:
 move.l xxp_strg(a4),-(a7)
 movem.l d0-d7/a0-a6,-(a7) ;save all except result in D0
 move.l a7,xxp_Stak(a4)
 clr.l xxp_kybd(a4)        ;(result will be here)
 sub.w #xxp_WPort+4,a7     ;create dummy part xxp_wsuw
 move.l d0,d7              ;d7 = input d0

 move.l a7,a5              ;a5 points to dummy part xxp_wsuw
 bsr TLReqredi             ;set pop window, default values to xxp_prfp
 beq .quit                 ;go if TLReqredi fails - unlikely

 move.l d7,d2              ;d2 = width
 mulu #8,d2
 addq.l #4,d2
 cmpi.w #64,d2
 bcc.s .cry
 moveq #64,d2
.cry:
 addq.w #8,d2
 moveq #24,d3              ;d3 = height
 bsr TLReqchek             ;check req size & position
 beq .quit                 ;go if won't fit

 tst.w xxp_ReqNull(a4)     ;quit ok if ReqNull=0
 beq .quit

 bsr TLReqon               ;open requester window
 beq .quit                 ;go if can't

 TLnewfont #0,#0,#0        ;use Topaz/8, zero spacing
 clr.w xxp_Tspc(a5)

 move.l #.str,xxp_strg(a4)
 move.w #$0103,xxp_FrontPen(a5)
 moveq #1,d0
 bsr TLStrbuf
 TLtext #4,#2
 move.l d7,d4
 mulu #8,d4
 addq.w #4,d4
 TLreqbev #4,#12,d4,#10
 subq.w #8,d4

 bsr TLHook2

 clr.b (a4)
 move.b #$FF,0(a4,d7.w)    ;so far, buff is not full

.echo:                     ;echo input so far
 move.l #$0D,xxp_kybd(a4)
 tst.b 0(a4,d7.w)
 beq .clos                 ;quit automatically if buff full

 TLreqarea #6,#13,d4,#8
 move.l a4,a0
 moveq #6,d1
 moveq #13,d2
.echc:
 tst.b (a0)+
 beq.s .crsr
 TLpict #11,d1,d2
 addq.w #8,d1
 bra .echc
.crsr:
 move.l d1,d0
 bset #29,d0
 TLreqarea d1,d2,#8,#8,#1

.wait:
 move.l xxp_Help(a4),-(a7)
 move.w #2,xxp_Help(a4)
 move.w #5,xxp_Help+2(a4)
.wthp:
 bsr TLKeyboard
 move.l (a7)+,xxp_Help(a4)

 move.l d0,xxp_kybd(a4)
 cmp.b #$1B,d0
 beq.s .clos
 cmp.b #$0D,d0
 beq.s .clos

 move.l a4,a0
.fore:
 tst.b (a0)+
 bne .fore
 subq.l #1,a0

 cmp.b #$8B,d0
 beq.s .back
 cmp.b #32,d0
 bcs .wait
 cmp.b #127,d0
 bcs.s .put
 cmp.b #160,d0
 bcs .wait
.put:
 move.b d0,(a0)+
 clr.b (a0)
 bra .echo

.back:
 cmp.l a4,a0
 beq .wait
 clr.b -(a0)
 bra .echo

.clos:
 bsr TLReqoff              ;close requester window

.quit:
 move.w #-1,xxp_ReqNull(a4) ;leave ReqNull<>0
 bsr TLWslof
 add.w #xxp_WPort+4,a7
 movem.l (a7)+,d0-d7/a0-a6
 move.l (a7)+,xxp_strg(a4)
 move.l xxp_kybd(a4),d0     ;* EQ,D0=0 if bad, D0=$1B if canc, D0=$0D if ok
 rts                        ;* The typed-in password (if any) is in buff

.str: dc.b 0                ;local strings
 dc.b 'Password',0 ;1
 dc.b 'Input the password...',0 ;2
 dc.b '1. Type any typeable characters',0 ;3
 dc.b '2. Press the backspace key to backspace',0 ;4
 dc.b '3. Press the <Esc> key to cancel',0 ;5
 dc.b '4. Press the <Return> key when you''ve typed your password',0 ;6
 ds.w 0


*>>>> set tandem.library prefs (D0=0 set up, +1 palette disable -1 else)
TLPrefs:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 tst.l d0
 bne .intr                 ;go if interacting

; initial setup (called by TLWindow)

 move.l #xxp_ypsz,d0       ;create xxp_pref memory
 bsr TLPublic
 move.l d0,xxp_pref(a4)    ;pref size = xxp_ypsz
 beq.s .intq

 lea .fact,a0              ;tfr factory settings to xxp_pref
 move.l xxp_pref(a4),a1
 moveq #(xxp_ypsz/4)-1,d0
.ftfr:
 move.l (a0)+,(a1)+        ;tfr factory settings to xxp_pref
 dbra d0,.ftfr

 move.l a4,a0              ;attempt to lock ENV:Tandem/GUI
 move.l #'ENV:',(a0)+
 move.l #'Tand',(a0)+
 move.l #'em/G',(a0)+
 move.w #'UI',(a0)+
 clr.b (a0)
 move.l xxp_dosb(a4),a6
 move.l a4,d1
 moveq #ACCESS_READ,d2
 jsr _LVOLock(a6)
 move.l d0,d1
 beq.s .fgdd               ;go if can't (no GUI prefs exist)
 jsr _LVOUnLock(a6)        ;unlock

 bsr TLOpenread            ;open ENV:Tandem/GUI
 beq.s .fgdd
 move.l a4,d2              ;read into buff
 move.l #xxp_ypsz+2,d3
 bsr TLReadfile
 beq.s .fgdd               ;go if bad
 bsr TLClosefile           ;close
 subq.l #2,d3
 cmp.l d0,d3
 bne.s .fgdd               ;discard if wrong filesize
 subq.w #1,d0
 move.l a4,a0
 move.l xxp_pref(a4),a1
.fgtf:
 move.b (a0)+,(a1)+        ;tfr prefs as read to xxp_prefs
 dbra d0,.fgtf

.fgdd:
 clr.l xxp_errn(a4)        ;error only if out of mem
 moveq #-1,d0
 bra.s .intq               ;(ignore errors reading prefs file)

.bad0:
 moveq #0,d0

.intq:
 movem.l (a7)+,d0-d7/a0-a6 ;EQ if bad (i.e. out of public mem)
 rts

; set preferences interactively

.intr:
 move.l xxp_strg(a4),-(a7) ;save global strings
 move.l #.str,xxp_strg(a4) ;install local strings
 move.l xxp_Active-2(a4),-(a7) ;save active window (if any) in lsw
 move.l xxp_Help(a4),-(a7) ;save callimg help
 move.w #74,xxp_Help(a4)   ;install help
 move.w #22,xxp_Help+2(a4)
 clr.l xxp_errn(a4)

 sub.w #xxp_ypsz+4,a7      ;copy of prefs in stack
 move.l d0,xxp_ypsz(a7)    ;remember input d0
 move.l a7,a6              ;a6 points to prefs
 move.l xxp_pref(a4),a0
 move.l a6,a1
 moveq #(xxp_ypsz/4)-1,d0  ;copy xxp_prefs to stack
.tfri:
 move.l (a0)+,(a1)+
 dbra d0,.tfri

 moveq #74,d0              ;preliminary info
 moveq #22,d1
 moveq #0,d2
 bsr TLReqinfo

 move.l xxp_WSuite(a4),a0  ;find an unused window
 moveq #0,d0
.fndw:
 tst.l xxp_Window(a0)
 beq.s .gtwd
 add.w #xxp_siz2,a0
 addq.w #1,d0
 cmp.w #10,d0
 bne .fndw

 moveq #96,d0              ;report & quit if no unused windows (unlikely)
 moveq #1,d1
 bsr TLReqinfo
 bra .done

.gtwd:                     ;open the TLprefs window
 moveq #0,d1
 moveq #0,d2
 move.l #188,d3
 move.l #114,d4
 move.l d3,d5
 move.l d4,d6
 moveq #1,d7               ;usual flags for requester
 bsr TLWindow              ;open requester window
 beq .bad                  ;go if can't
 move.l xxp_AcWind(a4),a5

 moveq #0,d0               ;put border around it
 moveq #0,d1
 move.l d3,d2
 move.l d4,d3
 bsr TLReqbev

; draw the main window

.main
 moveq #2,d0               ;colour the window
 moveq #1,d1
 move.l #184,d2
 moveq #112,d3
 moveq #3,d4
 bset #29,d0
 bsr TLReqarea

 move.l xxp_AcWind(a4),a5  ;draw the text
 move.w #$0203,xxp_FrontPen(a5)
 moveq #3,d1
 moveq #1,d2
 moveq #10,d3
.mnln:
 move.l d2,d0
 bsr TLStrbuf
 moveq #10,d0
 bsr TLText
 move.b #1,xxp_FrontPen(a5)
 add.w #10,d1
 addq.w #1,d2
 dbra d3,.mnln

 moveq #6,d0               ;draw the bevs
 moveq #12,d1
 move.l #176,d2
 moveq #10,d3
 moveq #5,d4
.mnbx:
 bsr TLReqbev
 add.w #10,d1
 dbra d4,.mnbx
 add.w #10,d1
 bsr TLReqbev
 add.w #10,d1
 bsr TLReqbev
 add.w #10,d1

 move.w #59,d2             ;draw save/use/canc bevs
 bsr TLReqbev
 add.w d2,d0
 bsr TLReqbev
 add.w d2,d0
 subq.w #1,d2
 bsr TLReqbev

.wait:                     ;get user response to main window
 bsr TLWfront
 bsr TLKeyboard
 cmp.b #$1B,d0             ;cancel if Esc
 beq .canc
 cmp.b #$80,d0             ;else reject unless lmb
 bne .wait
 subq.w #6,d1
 bcs .wait
 cmp.w #177,d1
 bcc .wait

 move.l d2,d7              ;go to .bots, .font, or d7=0-5 for whichever
 sub.w #12,d7
 bcs .wait
 divu #10,d7
 and.l #$0000FFFF,d7
 cmp.w #7,d7               ;go if palette box
 beq .palt
 cmp.w #8,d7
 beq .tour
 cmp.w #9,d7               ;go if save/use/cancel
 beq .bots
 cmp.w #6,d7               ;else accept rows 0-5 only
 bcc .wait

; d7 = 0-5 for whichever requester

 moveq #6,d0               ;clear bots area (bevs overlap)
 moveq #102,d1
 move.l #176,d2
 moveq #10,d3
 moveq #3,d4
 bset #29,d0
 bsr TLReqarea

 move.l xxp_AcWind(a4),a5  ;draw title
 move.w #$0203,xxp_FrontPen(a5)
 move.l d7,d0
 addq.w #2,d0
 bsr TLStrbuf
 moveq #10,d0
 moveq #3,d1
 bsr TLText
 subq.b #1,xxp_FrontPen(a5)

 moveq #13,d1              ;draw text
 moveq #12,d2
 moveq #9,d3
.rqln:
 move.l d2,d0
 cmp.w #8,d3               ;if title..
 bne.s .rqs0
 cmp.w #3,d7               ;  if prog, -> progress pen
 bne.s .rqs0
 moveq #22,d0
.rqs0:
 cmp.w #6,d3               ;if horz
 bne.s .rqs1
 cmp.w #3,d7               ;  if prog,data,show -> null
 bcc.s .rqsz
.rqs1:
 cmp.w #5,d3               ;if vert
 bne.s .rqs2
 cmp.w #3,d7               ;  if prog,data,show -> null
 bcc.s .rqsz
.rqs2:
 cmp.w #2,d3               ;always if factory,bots
 bcs.s .rqsy
 cmp.w #4,d3
 bcs.s .rqs3
 bne.s .rqsy
 cmp.w #3,d7
 beq.s .rqsz               ;  if prog -> null
 cmp.w #5,d7
 bne.s .rqs3               ;  if show -> data font
 moveq #23,d0
 bra.s .rqsy
.rqs3:                     ;if font size, spacing
 cmp.w #3,d7
 beq.s .rqsz               ;  if prog -> null
 cmp.w #5,d7
 bne.s .rqsy               ;  if show -> null
.rqsz:
 moveq #26,d0
.rqsy:
 bsr TLStrbuf
 moveq #10,d0
 bsr TLText
 add.w #10,d1
 addq.w #1,d2
 dbra d3,.rqln

 moveq #6,d0               ;draw bevs
 moveq #12,d1
 move.l #176,d2
 moveq #10,d3
 moveq #8,d4
.rqbx:
 bsr TLReqbev
 add.w #10,d1
 dbra d4,.rqbx

 moveq #88,d2              ;draw View/OK bevs
 bsr TLReqbev
 add.w d2,d0
 bsr TLReqbev

.rqwt:                     ;wait for response to req window
 bsr TLWfront
 bsr TLKeyboard
 cmp.b #$1B,d0             ;to main in Esc
 beq .main
 cmp.b #$80,d0             ;else reject unless lmb
 bne .rqwt
 subq.w #6,d1
 bcs .rqwt
 cmp.w #177,d1
 bcc .rqwt

 move.l d2,d6              ;d6 = row clicked
 sub.w #12,d6
 bmi .rqwt
 divu #10,d6
 cmp.w #9,d6
 bcc .rqbt

 move.l xxp_pref(a4),a3    ;d6=0-8 for row clicked, d7=0-5 for type
 add.w #xxp_ychs,a3        ;point a3 to xxp_pref for that type
 move.w d7,d0
 mulu #8,d0
 add.l d0,a3
 cmp.b #8,d6               ;go if factory
 beq .pfct
 cmp.b #3,d7               ;if prog...
 bne.s .bra0
 cmp.b #1,d6               ;  go if prog pen
 beq .pgpn
.bra0:
 cmp.b #3,d6               ;go if bg/ttl/txt pen
 bcs .ppen
 bne.s .bra1               ;if horz...
 cmp.b #3,d7
 bcc .rqwt                 ;  ignore if prog/data/show
 bra .phrz                 ;  else get horz
.bra1:
 cmp.b #5,d6
 bcc.s .bra2               ;if vert...
 cmp.w #3,d7
 bcc .rqwt                 ;  ignore if prog/data/show
 bra .pvrt                 ;  else get vert
.bra2:
 bne.s .bra3               ;if font...
 cmp.b #3,d7
 beq .rqwt                 ;  ignore if prog
 cmp.b #5,d7
 beq .sdft                 ;  if show -> get show data font
 bra .pfnt                 ;  else get font
.bra3:
 cmp.b #3,d7               ;no styl/spc for prog
 beq .rqwt
 cmp.b #5,d7               ;no styl/spc for show
 beq .rqwt
 cmp.b #7,d6               ;go if font spc
 bcc.s .pspc

.psty:                     ;get font style
 bsr .back
 moveq #108,d0
 moveq #7,d1
 moveq #1,d2
 bsr TLReqinfo             ;give instructions
 bsr .back
 moveq #122,d0
 moveq #5,d1
 bsr TLReqchoose           ;choose style
 sub.w #1,d0
 bmi .rqwt                 ;go if bad or cancel
 cmp.w #4,d0
 bcc .rqwt
 move.l xxp_pref(a4),a0
 move.b d0,xxp_ysty(a0)    ;put in prefs
 move.l d0,d1              ;attach to prefs window
 moveq #10,d0
 moveq #1,d2
 bsr TLNewfont
 bne .ftpk                 ;go if ok
 bsr .back
 moveq #57,d0
 moveq #3,d1
 moveq #0,d2
 bsr TLReqinfo             ;warn user if can't open font (unlikely)
 bra .rqwt

.pspc:                     ;get font spacing
 bsr .back
 moveq #115,d0
 moveq #7,d1
 moveq #1,d2
 bsr TLReqinfo             ;instructions

 bsr .back                 ;get input
 clr.b (a4)
 move.w #128,d0
 moveq #-1,d1
 moveq #1,d2
 moveq #0,d3
 bsr TLReqinput
 beq .rqwt
 move.l xxp_valu(a4),d0

 move.l xxp_pref(a4),a0    ;install new value
 move.b d0,xxp_yspc(a0)
 move.l xxp_AcWind(a4),a5
 move.w d0,xxp_RTspc(a5)
 bra .ftpk                 ;go report

.pfnt:                     ;get font
 bsr .back
 moveq #48,d0
 moveq #8,d1
 moveq #0,d2
 bsr TLReqinfo             ;show info
 moveq #10,d0
 bsr TLAslfont             ;put up requester
 bne.s .fpcu               ;go if ok
 tst.l xxp_errn(a4)
 beq .rqwt                 ;go if cancel
 bsr .back
 moveq #56,d0
 moveq #1,d1
 moveq #0,d2
 bsr TLReqinfo             ;display info if bad
 bra .rqwt
.fpcu:
 move.l xxp_pref(a4),a0    ;attach new font to window prefs data
 moveq #10,d0
 moveq #0,d1
 move.b xxp_ysty(a0),d1
 moveq #1,d2
 bsr TLNewfont
 bne.s .fpgd               ;go if ok
 moveq #57,d0
 moveq #3,d1
 moveq #0,d2
 bsr TLReqinfo             ;warn user if can't open font (unlikely)
.fpgd:
 move.l xxp_FSuite(a4),a0  ;tfr new font to xxp_pref
 add.w #10*xxp_fsiz,a0
 move.l xxp_pref(a4),a1
 move.w 4(a0),xxp_yhgt(a1)
 addq.l #8,a0
.fptf:
 move.b (a0)+,(a1)+
 bne .fptf
.ftpk:
 bsr .back
 moveq #60,d0
 moveq #3,d1
 moveq #0,d2
 bsr TLReqinfo
 bra .rqwt

.phrz:                     ;get horz
 move.w #129,d0
 moveq #3,d4               ;d0=header, d4=3 for horz
.phpk:                     ;vert joins here
 bsr .back
 clr.b (a4)                ;get horz/vert
 moveq #-1,d1
 moveq #1,d2
 moveq #0,d3
 bsr TLReqinput
 beq .rqwt
 move.l xxp_valu(a4),d0

 move.l xxp_pref(a4),a0    ;instal horz/vert
 move.l d7,d1
 lsl.w #3,d1
 add.l d1,a0
 add.w #xxp_ychs,a0
 move.b d0,0(a0,d4.w)
 bra .view                 ;go report

.pvrt:                     ;get vert
 move.w #130,d0
 moveq #4,d4               ;d4=4 for vert
 bra .phpk                 ;go join horz routine

.ppen:                     ;get bg/ttl/txt pen
 move.l xxp_strg(a4),-(a7)
 sub.w #256,a7             ;put instructions in stack
 move.l a7,a1
 clr.b (a1)+
 moveq #104,d0
 bsr TLStra0
.ppt0:
 move.b (a0)+,(a1)+        ;str 104
 bne .ppt0
 move.l d7,d0
 addq.w #2,d0
 bsr TLStra0
.ppt1:
 move.b (a0)+,(a1)+        ;req type
 bne .ppt1
 move.l d6,d0
 add.w #12,d0
 cmp.w #15,d0
 bne.s .ppcy
 moveq #22,d0
.ppcy:
 bsr TLStra0
.ppt2:
 move.b (a0)+,(a1)+        ;which pen
 bne .ppt2
 moveq #105,d0
 moveq #2,d1
 bsr TLStra0
.ppt3:
 move.b (a0)+,(a1)+        ;str 105-7
 bne .ppt3
 dbra d1,.ppt3
 moveq #1,d0
 moveq #6,d1
 moveq #1,d2
 move.l a7,xxp_strg(a4)
 bsr TLReqinfo             ;put instructions
 add.w #256,a7
 move.l (a7)+,xxp_strg(a4)
 moveq #0,d0               ;put color req (0 = pen only)
 bsr TLReqcolor
 subq.w #1,d0
 bmi .rqwt                 ;go if cancel
 move.l xxp_pref(a4),a0
 add.w #xxp_ychs,a0
 move.l d7,d1
 lsl.w #3,d1
 add.w d1,a0
 move.b d0,0(a0,d6.w)      ;put pen
 bra .view                 ;view requester with new pen

.pgpn:                     ;prog pen
 moveq #3,d6
 bra .ppen

.pfct:                     ;factory settings
 bsr .back
 move.w #138,d0
 moveq #2,d1
 moveq #2,d2
 bsr TLReqinfo             ;caution
 cmp.w #1,d0               ;ignore unless OK
 bne .rqwt

 lea .fact,a0              ;factory settings to xxp_pref
 move.l xxp_pref(a4),a1
 moveq #(xxp_ypsz/4)-1,d0
.pfc0:
 move.l (a0)+,(a1)+
 dbra d0,.pfc0

 move.l xxp_pref(a4),a0    ;get & open font 10
 moveq #10,d0
 moveq #8,d1
 move.l xxp_pref(a4),a0
 bsr TLGetfont
 move.l xxp_FSuite(a4),a0
 add.w #xxp_fsiz*10,a0
 bsr TLOfont

 moveq #10,d0              ;attach font 10 to reqs
 moveq #0,d1
 moveq #1,d2
 bsr TLNewfont

 move.l xxp_pref(a4),a0    ;get & open font 11
 add.w #xxp_yfsh,a0
 moveq #11,d0
 moveq #8,d1
 bsr TLGetfont
 move.l xxp_FSuite(a4),a0
 add.w #xxp_fsiz*11,a0
 bsr TLOfont

 move.l xxp_AcWind(a4),a5  ;update req data in current window
 move.l xxp_pref(a4),a0
 clr.w xxp_RFsty(a5)
 clr.w xxp_RTspc(a5)
 bra .rqwt

.sdft:                     ;get show data font
 bsr .back
 move.w #131,d0            ;instructions
 moveq #4,d1
 moveq #0,d2
 bsr TLReqinfo
 moveq #11,d0              ;get new font 11
 bsr TLAslfont
 bne.s .sdcu               ;go if ok
 tst.l xxp_errn(a4)
 beq .rqwt                 ;go if cancel
 bsr .back
.sdfl:
 moveq #56,d0
 moveq #1,d1
 moveq #0,d2
 bsr TLReqinfo             ;display info if bad
 bra .rqwt
.sdcu:
 move.l xxp_FSuite(a4),a0  ;tfr new font to xxp_pref
 add.w #11*xxp_fsiz,a0
 move.w #8,4(a0)           ;height always = 8
 move.l a0,a2
 addq.l #8,a2
 move.l xxp_pref(a4),a1    ;tfr fontname to pref
 add.w #xxp_yfsh,a1
.sdtf:
 move.b (a2)+,(a1)+
 bne .sdtf
 bsr TLOfont               ;open font 11
 bne.s .sdop               ;go if ok
 bsr .back
 move.w #135,d0
 moveq #1,d1
 moveq #0,d2
 bsr TLReqinfo             ;report can't open
.sdop:
 move.l xxp_FSuite(a4),a0
 add.w #xxp_fsiz*11,a0
 move.l 8(a0),a1
 btst #5,tf_Flags(a1)      ;go unless proportional
 beq .view
 bsr .back
 move.w #136,d0            ;report can't use proportional
 moveq #2,d1
 moveq #0,d2
 bsr TLReqinfo
 bra .view                 ;go view show requester as amended

.rqbt:                     ;req window bottom line clicked
 cmp.w #88,d1
 bcc .main                 ;to main if OK clicked

.view:
 cmp.w #1,d7               ;req window View box clicked
 bcs.s .chos
 beq .inpt
 cmp.w #3,d7
 bcs .info
 beq .prog
 cmp.w #5,d7
 bcs .data
 bra .show

.tour:                    ;tour of requesters
 bsr .chsd
 bsr .chs2
 bsr .inpd
 bsr .inf1
 bsr .inf2
 bsr .infd
 bsr .prgd
 bsr .datd
 bsr .shwd
 bra .wait

.chos:                     ;view choose req
 bsr.s .chsd
 bra .rqwt

.chsd:                     ;do a choose req
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 moveq #27,d0
 moveq #2,d1
 bsr TLReqchoose
 move.l (a7)+,xxp_Help(a4)
 rts

.chs2:                     ;do choose req - type 2
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 moveq #27,d0
 bsr TLStrbuf
 moveq #0,d1
 bsr TLReqchoose
 move.l (a7)+,xxp_Help(a4)
 rts

.inpt:                     ;view input req
 bsr.w .inpd
 bra .rqwt

.inpd:                     ;do input req
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 move.l #'Prom',(a4)
 move.w #'pt',4(a4)
 clr.b 6(a4)
 moveq #30,d0
 moveq #0,d1
 moveq #20,d2
 moveq #0,d3
 bsr TLReqinput
 move.l (a7)+,xxp_Help(a4)
 rts

.info:                     ;view info req
 bsr.s .infd
 bra .rqwt

.infd:                     ;do info req - type 3
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 moveq #31,d0
 moveq #6,d1
 moveq #3,d2
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 rts

.inf1:                     ;do info req - type 1
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 moveq #98,d0
 moveq #3,d1
 moveq #1,d2
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 rts

.inf2:                     ;do info req - type 2
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 moveq #101,d0
 moveq #3,d1
 moveq #2,d2
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 rts

.prog:                     ;view progress bar
 bsr.s .prgd
 bra .rqwt

.prgd:                     ;do progress bar
 bsr .back

 moveq #41,d0              ;make TLData window to hold progress bar
 moveq #5,d1
 bsr TLData

 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont
 move.l xxp_AcWind(a4),a5
 clr.w xxp_RTspc(a5)

 move.l #6,xxp_prgd(a4)    ;set up TLProgress
 move.l #26,xxp_prgd+4(a4)
 move.l #96,xxp_prgd+8(a4)
 move.l #10,xxp_prgd+12(a4)

 bsr TLBusy
 moveq #0,d0               ;do for 0-50
 moveq #50,d1
 moveq #-1,d2
 move.l xxp_gfxb(a4),a6
.pgcc:
 jsr TLProgress
 movem.l d0-d2,-(a7)
 moveq #3,d2               ;inc d2 to make slower
.pgwt:
 jsr _LVOWaitTOF(a6)
 dbra d2,.pgwt
 movem.l (a7)+,d0-d2
 addq.l #1,d0
 cmp.w #51,d0
 bne .pgcc
 moveq #15,d2               ;pause at end
.pgp1:
 jsr _LVOWaitTOF(a6)
 dbra d2,.pgp1
 bsr TLUnbusy

 bsr TLReqoff
 rts

.data:                     ;view data window
 bsr.s .datd
 bra .rqwt

.datd:                     ;do data window
 bsr .back
 moveq #37,d0
 moveq #4,d1
 bsr TLData
 bsr TLBusy
 move.l xxp_gfxb(a4),a6
 move.w #200,d2
.datw:
 jsr _LVOWaitTOF(a6)
 subq.w #1,d2
 bne .datw
 bsr TLUnbusy
 bsr TLReqoff
 rts

.show:                     ;view show req
 bsr.s .shwd
 bra .rqwt

.shwd:                     ;do dhow rea
 bsr .back
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 moveq #46,d0
 moveq #120,d1
 moveq #10,d2
 bset #31,d2
 moveq #0,d3
 lea .shhk,a0
 bsr TLReqshow
 move.l (a7)+,xxp_Help(a4)
 rts

.shhk:                     ;** hook for view TLReqshow
 move.l a4,a0
 move.l #'Stri',(a0)+
 move.l #'ng  ',(a0)+      ;line = 'String  ....'
 bsr TLHexasc
 clr.b (a0)
 move.l a4,a0
 rts

.palt:                     ;palette box clicked
 tst.l xxp_ypsz(a7)
 bmi.s .pltc               ;go if permitted
 moveq #47,d0
 moveq #1,d1
 moveq #0,d2
 bsr TLReqinfo             ;else report forbidden
 bra .wait
.pltc:
 moveq #2,d0               ; 2 = choose palette only
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqcolor
 move.l (a7)+,xxp_Help(a4)
 bra .wait

.bots:                     ;save/use/canc clicked
 cmp.w #118,d1
 bcc .canc                 ;go if cancel
 moveq #0,d7
 cmp.w #59,d1
 bcc.s .use                ;go if use (d7 = 0)
 moveq #-1,d7              ;else save (d7 = -1)
.use:

 moveq #24,d0              ;create ENV:Tandem & ENVARC:Tandem if necessary
 bsr TLStra0
 move.l d7,d0
 bsr TLPrefdir
 moveq #25,d0              ;save prefs in ENV:Tandem/GUI [+ ENVARC: if save]
 bsr TLStra0
 move.l d7,d0
 move.l xxp_pref(a4),d2
 move.l #xxp_ypsz,d3
 bsr TLPreffil
 bsr .back

 moveq #64,d0              ;report Use/Save consequences
 moveq #10,d1
 moveq #0,d2
 bsr TLReqinfo
 bra.s .wrap

.canc:                     ;cancel
 move.l a7,a0
 move.l xxp_pref(a4),a1
 moveq #(xxp_ypsz/4)-1,d0
.keep:
 move.l (a0)+,(a1)+        ;restore aboriginal contents to xxp_pref
 dbra d0,.keep
 move.l xxp_pref(a4),a0    ;restore aboriginal pref font to font 9
 moveq #9,d0
 move.w xxp_yhgt(a0),d1
 bsr TLGetfont
 add.w #xxp_yfsh,a0        ;restore aboriginal show data font to font 8
 moveq #8,d0
 moveq #8,d1
 bsr TLGetfont

.wrap:
 move.w xxp_Active(a4),d0  ;close the Prefs window
 bsr TLWsub
 tst.l xxp_errn(a4)        ;go if no error
 beq.s .done

.bad:                      ;report error in monitor & if possible choose req
 bsr TLError

.done:                     ;close down
 add.w #xxp_ypsz+4,a7
 move.l (a7)+,xxp_Help(a4)
 move.l (a7)+,d0           ;retrieve calling active window in lsw
 tst.w d0
 bmi.s .quit               ;go if none
 bsr TLWpop                ;pop calling window
 move.l xxp_pref(a4),a0
 moveq #10,d0              ;attach xxp_pref font to req fonts data
 moveq #0,d1
 move.b xxp_ysty(a0),d1
 moveq #1,d2
 bsr TLNewfont
 moveq #0,d0
 move.b xxp_yspc(a0),d0
 move.l xxp_AcWind(a4),a0
 move.w d0,xxp_RTspc(a0)
.quit:
 bsr TLWslof
 move.l (a7)+,xxp_strg(a4) ;retrieve global strings
 movem.l (a7)+,d0-d7/a0-a6 ;xxp_errn<>0 if bad
 rts

.back:                     ;** prefs window to back
 movem.l d0-d1/a0-a1/a6,-(a7)
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 jsr _LVOWindowToBack(a6)
 movem.l (a7)+,d0-d1/a0-a1/a6
 rts

.str: dc.b 0
 dc.b 'GUI Preferences      ',0 ;1
 dc.b 'Choose requester     ',0 ;2
 dc.b 'Input requester      ',0 ;3
 dc.b 'Info requester       ',0 ;4
 dc.b 'Progress bar         ',0 ;5
 dc.b 'Data window          ',0 ;6
 dc.b 'Show requester       ',0 ;7
 dc.b '                     ',0 ;8
 dc.b 'Colour palette       ',0 ;9
 dc.b 'View all reqs &c     ',0 ;10
 dc.b ' Save    Use   Cancel',0 ;11

 dc.b 'Background pen       ',0 ;12
 dc.b 'Title pen            ',0 ;13
 dc.b 'Text pen             ',0 ;14
 dc.b 'Horizontal gaps      ',0 ;15
 dc.b 'Vertical gaps        ',0 ;16
 dc.b 'Font name,size       ',0 ;17
 dc.b '     style           ',0 ;18
 dc.b '     space           ',0 ;19
 dc.b 'Factory settings     ',0 ;20
 dc.b '   View        OK    ',0 ;21
 dc.b 'Progress pen         ',0 ;22
 dc.b 'Data font            ',0 ;23
 dc.b 'Tandem',0 ;24
 dc.b 'Tandem/GUI',0 ;25
 dc.b '                     ',0 ;26
 dc.b 'I''m a Choose Requester',0 ;27
 dc.b 'Choice 1',0 ;28
 dc.b 'Choice 2',0 ;29
 dc.b 'I''m an Input Requester',0 ;30
 dc.b 'I''m a type 3 info window...',0 ;31
 dc.b 'Type 1 has just an OK button,',0 ;32
 dc.b 'Type 2 has OK + Cancel buttons.',0 ;33
 dc.b 'Type 3 or more custom buttons.',0 ;34
 dc.b 'As you see below, I have 6.',0 ;35
 dc.b '£\!!\!?\?!\??\$',0 ;36
 dc.b 'I''m a data window...',0 ;37
 dc.b 'I''ll sit here a couple of',0 ;38
 dc.b 'seconds, and then I''ll',0 ;39
 dc.b 'disappear...',0 ;40
 dc.b 'Hereon is a progress bar...',0 ;41
 dc.b ' ',0 ;42
 dc.b ' ',0 ;43
 dc.b ' ',0 ;44
 dc.b ' ',0 ;45
 dc.b 'I''m a show requester',0 ;46
 dc.b 'Can''t alter palette: this option is currently disabled',0 ;47
 dc.b 'Selecting a font....',0 ;48
 dc.b 'The font you select will apply to all of these',0 ;49
 dc.b 'requester &c types:',0 ;50
 dc.b ' ',0 ;51
 dc.b '  Choose requester',0 ;52
 dc.b '  Input requester',0 ;53
 dc.b '  Info requester',0 ;54
 dc.b '  Data window',0 ;55
 dc.b 'Error: can''t open ASL requester (out of memory?)',0 ;56
 dc.b 'Caution: can''t open font selected - probably memory shortage.',0 ;57
 dc.b 'Suggest you save prefs, then close unnecessary tasks or reboot.',0
 dc.b 'Else when you view requesters, they may not manifest the new font.',0
 dc.b 'Hopefully....',0 ;60
 dc.b 'The new font is visible',0 ;61
 dc.b 'on this info requester.',0 ;62
 dc.b ' ',0 ;63
 dc.b 'Save/Use selected...',0 ;64
 dc.b 'Your new preferences will',0 ;65
 dc.b 'be available to the window',0 ;66
 dc.b '(if any) which caused this',0 ;67
 dc.b 'setting of prefs to occur,',0 ;68
 dc.b 'along with windows opened',0 ;69
 dc.b 'under tandem.library from',0 ;70
 dc.b 'now on. Of course, some',0 ;71
 dc.b 'programs will sometimes',0 ;72
 dc.b 'override the preferences.',0 ;73
 dc.b 'You are invited to set preferences for tandem.library....',0 ;74
 dc.b 'The program that invoked this requester is running a library',0 ;75
 dc.b 'called "tandem.library". The program may well cause the',0 ;76
 dc.b 'following sorts of things to appear:',0 ;77
 dc.b ' ',0 ;78
 dc.b '  Choose requesters  used for selecting among alternatives.',0 ;79
 dc.b '  Input requesters   used for getting you to input data.',0 ;80
 dc.b '  Info requesters    used to tell you data, and perhaps',0 ;81
 dc.b '                     make a decision (this is an info requester).',0
 dc.b '  Progress bars      to report progress while the program is busy.',0
 dc.b '  Data windows       to put up data, etc. for your perusal.',0 ;84
 dc.b '  Show requesters    to allow you to see dynamically constructed',0
 dc.b '                     data, and scroll & seek among it.',0 ;86
 dc.b ' ',0 ;87
 dc.b 'After you click "OK" (below), you can choose to alter the look of',0
 dc.b 'any of the above, and also to adjust this screen"s colour palette.',0
 dc.b 'You can set colour pens for the requesters, and "horz gaps" and',0
 dc.b '"Vert gaps" to adjust their setting out, and also choose a font,',0
 dc.b 'font style and character spacing for their text. (n.b. not all',0
 dc.b 'programs respect your prefs at all times). When you are setting',0
 dc.b 'prefs for a requester &c. type, you can click "View" to see how it',0
 dc.b 'looks so far. When all done, click "Use", "Save" or "Cancel".',0 ;95
 dc.b 'Can''t do GUI prefs - too many system resources in use',0 ;96
 dc.b 'Type 2 choose requester - 1 line of dynamic info',0 ;97
 dc.b 'Type 1 info requester...',0 ;98
 dc.b 'Lines of data and',0 ;99
 dc.b 'and OK button',0 ;100
 dc.b 'Type 2 info requester...',0 ;101
 dc.b 'Lines of data and',0 ;102
 dc.b 'OK and Cancel buttons',0 ;103
 dc.b 'Choose a pen for...',0 ;104
 dc.b 'When color requester appears, click whichever color.',0 ;105
 dc.b 'It will then appear at the bottom of the requester.',0 ;106
 dc.b 'Finally, click Use or Cancel.',0 ;107
 dc.b 'Selecting a font style...',0 ;108
 dc.b 'The style you select will apply to all of:',0 ;109
 dc.b ' ',0 ;110
 dc.b '  Choose requester',0 ;111
 dc.b '  Input requester',0 ;112
 dc.b '  Info requester',0 ;113
 dc.b '  Data window',0 ;114
 dc.b 'Setting a text spacing...',0 ;115
 dc.b 'the spacing you choose will apply ot all of:',0 ;116
 dc.b ' ',0 ;117
 dc.b '  Choose requester',0 ;118
 dc.b '  Input requester',0 ;119
 dc.b '  Info requester',0 ;120
 dc.b '  Data window',0 ;121
 dc.b 'Select font style:',0 ;122
 dc.b 'Plain',0 ;123
 dc.b 'Bold',0 ;124
 dc.b 'Italic',0 ;125
 dc.b 'Bold + Italic',0 ;126
 dc.b 'Cancel',0 ;127
 dc.b 'Text spacing (0-9, usually 0 for small fonts)',0 ;128
 dc.b 'Specify horizontal gap (0-9, usally 2)',0 ;129
 dc.b 'Specify vertical gap (0-9, usually 1)',0 ;130
 dc.b 'Specify show requester font',0 ;131
 dc.b 'The font height will always be 8. Only choose',0 ;132
 dc.b 'fonts narrower than Topaz/8, not proportional.',0 ;133
 dc.b 'Or, for maximum readability, choose Topaz/8.',0 ;134
 dc.b 'Error: can''t open the show requester data font',0 ;135
 dc.b 'Error: you have chosen a proportional font.',0 ;136
 dc.b 'Show requesters will not use the font you have chosen.',0 ;137
 dc.b 'Set all tandem.library prefs to factory settings...',0 ;138
 dc.b 'Caution: ALL existing preferences will be over-written.',0 ;139

 ds.w 0

.fact:                     ;factory pref settings
 dc.b 'topaz.font',0,0     ;req font
 dc.l 0,0,0,0,0
 dc.w 8                    ;ht=8
 dc.b 0,0                  ;styl=0, spac=0
 dc.b 'topaz.font',0,0     ;show data font
 dc.l 0,0,0,0,0
 dc.b 3,2,1,2,1,0,0,0      ;choose: pens 3,2,1; gaps 2,1
 dc.b 3,2,1,2,1,0,0,0      ;input
 dc.b 3,2,1,2,1,0,0,0      ;info
 dc.b 0,0,1,3,0,0,0,0      ;prog pens 0,,1,3
 dc.b 3,2,1,0,0,0,0,0      ;data
 dc.b 3,2,1,0,0,0,0,0      ;show

*>>>> put string D0 in buff, set d0 to bytes transferred
TLStrbuf:
 movem.l a0-a1,-(a7) ;saves all regs except D0
 bsr TLStra0
 move.l a4,a1
 moveq #-1,d0        ;(byte count excludes null delimiter)
.tfr:
 addq.l #1,d0
 move.b (a0)+,(a1)+
 bne .tfr
 movem.l (a7)+,a0-a1
 rts

*>>>> point A0 to string D0
TLStra0:
 move.l d0,-(a7) ;saves all except A0
 move.l xxp_strg(a4),a0
 subq.w #1,d0
.seek:
 tst.b (a0)+
 bne .seek
 dbra d0,.seek
 move.l (a7)+,d0
 rts

*>>>> call IoErr, DOS number to D0, call Fault to put error report in buff

; 1. Sends DOS error report (if <>0) to output stream
; 2. Puts meaning of xxp_errn in buff (n.b. xxp_errn = 0 = "Cancelled")
; 3. If xxp_errn<>0, sends buff to output stream
;    (useful if out of chip ram, since at least monitor shows it)
; 4. Returns DOS error number from step 1. in D0

TLError:
 movem.l d0-d4/a0-a1/a6,-(a7) ;saves all regs except D0
 move.l xxp_dosb(a4),a6
 jsr _LVOIoErr(a6)         ;D0=error number
 move.l d0,(a7)            ;put error number in return D0
 beq.s .errn               ;don't report if = 0
 move.l d0,d1
 moveq #0,d2
 move.l a4,d3
 moveq #80,d4
 jsr _LVOFault(a6)         ;DOS error report to buff if <>
 bsr TLOutput              ;send to output stream
.errn:
 clr.b (a4)                ;return null in (a4) if bad error number
 move.l xxp_errn(a4),d0
.last:
 cmp.w #42,d0
 bcc.s .wrap
 lea .errs,a0              ;find xxp_errn'th entry in table
.nern:
 tst.b (a0)+
 bne .nern
 dbra d0,.nern
 move.l a4,a1              ;tfr to buff
 move.l #'Erro',(a1)+
 move.w #'r ',(a1)+
.tfr:
 move.b (a0)+,(a1)+
 bne .tfr
 tst.l xxp_errn(a4)        ;put in error stream, unless errn = 0
 beq.s .wrap
 bsr TLOutput
.wrap:
 movem.l (a7)+,d0-d4/a0-a1/a6
 rts

;tandem error codes
.errs: dc.b 0
 dc.b '0  Cancel selected',0
 dc.b '1  Out of Public memory',0
 dc.b '2  Out of chip memory',0
 dc.b '3  Can''t open file for reading',0
 dc.b '4  Can''t open file for writing',0
 dc.b '5  Can''t read file',0
 dc.b '6  Can''t write file',0
 dc.b '7  Can''t lock public screen',0
 dc.b '8  Font operation failed - Can''t open diskfont.library',0
 dc.b '9  Can''t get screen vi for gadtools.library',0
 dc.b '10  Can''t open font',0
 dc.b '11  Object won''t fit in window',0
 dc.b '12  Can''t open half-height font (super/sub script)',0
 dc.b '13  Can''t make double width font - Can''t create FONTS:Temporary',0
 dc.b '14  Can''t make double width font - Can''t open FONTS:Temporary',0
 dc.b '15  Can''t make dble width font - Can''t write to FONTS:Temporary',0
 dc.b '16  Can''t make double width font - NewFontContents failed',0
 dc.b '17  Font operation failed - Can''t lock FONTS:',0
 dc.b '18  Can''t make double width font - Can''t open Temporary.font',0
 dc.b '19  Can''t make double width font - Can''t write to Temporary.font',0
 dc.b '20  Can''t make double width font - Can''t re-open Temporary.font',0
 dc.b '21  Requester won''t fit in screen/window',0
 dc.b '22  Needs intuition.library v. 39+ (Amiga OS release 3.0+)',0
 dc.b '23  Can''t create a prefs dir',0
 dc.b '24  Can''t create a prefs file',0
 dc.b '25  Can''t open ILBM file',0
 dc.b '26  Not an IFF file',0
 dc.b '27  Not an ILBM file',0
 dc.b '28  Garbled ILBM contents',0
 dc.b '29  Unrecognised ILBM compression method',0
 dc.b '30  LayoutMenusA failed (unlikely)',0
 dc.b '31  Edit error - window too narrow',0
 dc.b '32  Edit error - window too shallow',0
 dc.b '33  Edit error - can''t obey fixed offset',0
 dc.b '34  Edit error - can''t attach font',0
 dc.b '35  Operation cancelled because window resized',0
 dc.b '36  Can''t make screen rendering objects (out of memory)',0
 dc.b '37  Can''t get screen DrawInfo (out of memory)',0
 dc.b '38  Can''t make window scroller rendering object (out of mem)',0
 dc.b '39  Can''t put up font selector - too many windows already opened',0
 dc.b '40  Can''t open printer device',0
 dc.b '41  Error in sending characters to printer',0

; set D0 at .last to highest legal error number + 1

 ds.w 0

*>>>> open a file for reading
TLOpenread:
 movem.l d1-d2/a0-a1/a6,-(a7) ;save all except d0
 clr.l xxp_errn(a4)
 move.l xxp_dosb(a4),a6
 move.l a4,d1
 move.l #MODE_OLDFILE,d2
 jsr _LVOOpen(a6)
 move.l d0,xxp_hndl(a4)    ;sv handle
 bne.s .done
 addq.l #3,xxp_errn(a4)
 moveq #0,d0
.done:
 movem.l (a7)+,d1-d2/a0-a1/a6 ;EQ, D0=0 if bad
 rts

*>>>> open a file for writing
TLOpenwrite:
 movem.l d1-d2/a0-a1/a6,-(a7) ;save all except d0
 clr.l xxp_errn(a4)
 move.l xxp_dosb(a4),a6
 move.l a4,d1
 move.l #MODE_NEWFILE,d2
 jsr _LVOOpen(a6)
 move.l d0,xxp_hndl(a4)     ;sv handle
 bne.s .done
 addq.l #4,xxp_errn(a4)
 moveq #0,d0
.done:
 movem.l (a7)+,d1-d2/a0-a1/a6 ;EQ, D0=0 if bad
 rts

*>>>> write D3 bytes at (D2) to xxp_hndl; Error called if bad
TLWritefile:
 movem.l d1/a0-a1/a6,-(a7) ;saves all except D0
 clr.l xxp_errn(a4)        ;errn=0 if no error
 move.l xxp_dosb(a4),a6
 move.l xxp_hndl(a4),d1
 jsr _LVOWrite(a6)
 cmp.l d0,d3               ;bad if bytes written <> D3
 beq.s .done
 bsr TLClosefile           ;(closefile if bad)
 addq.l #6,xxp_errn(a4)
.done:
 tst.l xxp_errn(a4)
 eori.w #-1,ccr
 movem.l (a7)+,d1/a0-a1/a6 ;EQ, errn<>0 if bad, D0 = bytes written
 rts

*>>>> read max D3 bytes to (D2) from xxp_hndl; sets D0=bytes read; EQ if bad
TLReadfile:
 movem.l d1/a0-a1/a6,-(a7) ;save all except D0
 clr.l xxp_errn(a4)        ;errn=0 if no error
 move.l xxp_dosb(a4),a6
 move.l xxp_hndl(a4),d1
 jsr _LVORead(a6)
 tst.l d0
 bge.s .done               ;D0=bytes read (if D0=0, eof, treat as good)
 bsr TLClosefile           ;(closefile if bad)
 addq.l #5,xxp_errn(a4)
 moveq #0,d0
.done:
 tst.l xxp_errn(a4)
 eori.w #-1,ccr
 movem.l (a7)+,d1/a0-a1/a6 ;EQ, errn<> if bad, else D0 = bytes read
 rts

*>>>> close file
TLClosefile:
 movem.l d0-d1/a0-a1/a6,-(a7) ;save all regs
 move.l xxp_dosb(a4),a6
 move.l xxp_hndl(a4),d1
 beq.s .done               ;can call if xxp_hndl=0
 jsr _LVOClose(a6)
 clr.l xxp_hndl(a4)        ;sets hndl=0
.done:
 movem.l (a7)+,d0-d1/a0-a1/a6
 rts

*>>>> ASCII to hex conversion (unsigned double integer)
; does not check for CS if >$FFFFFFFF; not highly optimised
; Call: A0=string addr (if no number there A0 returns unchanged, D0=0)
; value in D0  A0 points to 1st non-numeric chr
TLAschex:
 move.l d1,-(a7) ;save all except D0,A0
.spcs:
 cmp.b #' ',(a0)+ ;skip leading spaces
 beq .spcs
 subq.l #1,a0
 clr.l d0
 clr.l d1
.chr:
 move.b (a0)+,d1 ;get next character
 sub.b #'0',d1   ;(stop if not 0-9)(only works for unsigned integers)
 bcs.s .eoe
 cmp.b #10,d1
 bcc.s .eoe
 move.l d0,-(a7)
 lsl.l #2,d0
 add.l (a7)+,d0 ;result is modulo $100000000
 lsl.l #1,d0
 add.l d1,d0
 bra .chr
.eoe:
 subq.l #1,a0   ;a0 points to delimiter
 move.l (a7)+,d1
 rts

*>>>> hex to ASCII conversion (unsigned double integer left justified)
; not highly optimised for small values
; Call: value in D0; A0 is where to put result
; Back: A0 points past last character
TLHexasc:
 movem.l a1/d0-d4,-(a7) ;save all except A0
 moveq #1,d4
 moveq #0,d3     ;d3<>0 after 1st non-zero chr sent
 lea .k,a1
 move.l (a1)+,d1 ;d1=next decimal digit, starting 1E9
.digt:
 moveq #'0'-1,d2 ;d2 holds ascii of next digit
.bump:
 addq.b #1,d2
 sub.l d1,d0
 bcc .bump
 add.l d1,d0     ;d0=remainder so far
 tst.w d3
 bne.s .send     ;if chr(s) already sent, send even if 0
 cmp.b #'0',d2   ;else don't send
 beq.s .next
 moveq #-1,d3    ;remember that we have sent
.send:
 move.b d2,(a0)+ ;send a digit
.next:
 move.l (a1)+,d1 ;get next decimal digit
 cmp.l d4,d1
 bgt .digt       ;go if >1E0
 bne.s .done     ;quit if 0 (delimiter)
 moveq #-1,d3    ;if sending last digit, for to send, even if none sent yet
 bra .digt
.done:
 movem.l (a7)+,a1/d0-d4
 rts

.k: dc.l 1000000000,100000000,10000000,1000000,100000,10000,1000,100,10,1,0

*>>>> output from buff to output handle (temporarily append $0A)
TLOutput:
 movem.l d1-d3/a0-a1/a6,-(a7) ;save all registers except D0
 move.l xxp_dosb(a4),a6
 move.l xxp_oput(a4),d1
 move.l a4,d2              ;D2=buff
 move.l d2,a0              ;count bytes
.eos:
 tst.b (a0)+               ;find end of string
 bne .eos
 move.b #$0A,-1(a0)        ;replace its 0 with a $0A
 move.l a0,d3
 sub.l d2,d3               ;D3=chrs to be sent
 jsr _LVOWrite(a6)
 add.l d2,d3               ;restore the 0
 move.l d3,a0
 clr.b -(a0)
 movem.l (a7)+,d1-d3/a0-a1/a6 ;D0 = value returned by _LVOWrite
 rts

*>>>> input from input handle to buff; null delimit - i.e. chop off $0A
TLInput:
 movem.l d1-d3/a0-a1/a6,-(a7) ;save all except d0
 move.l xxp_dosb(a4),a6
 move.l xxp_iput(a4),d1
 move.l a4,d2                 ;D2=buff
 move.l #500,d3               ;D3=max input (will be much less,surely)
 jsr _LVORead(a6)
 tst.l d0
 ble.s .done
 move.l d2,a0
 clr.b -1(a0,d0.w)            ;null delimit if D0>0 (i.e. chop off $0A)
.done:
 movem.l (a7)+,d1-d3/a0-a1/a6 ;d0=value returned by Read (characters+1)
 rts

*>>>> create D0 bytes of public memory
TLPublic:
 movem.l d1/a0-a1/a6,-(a7) ;save all except d0
 move.l xxp_intb(a4),a6
 move.l #MEMF_PUBLIC,d1
 move.l a4,a0
 add.l #xxp_memk,a0
 jsr _LVOAllocRemember(a6) ;(Front.i will finally call FreeRemember)
 tst.l d0
 movem.l (a7)+,d1/a0-a1/a6 ;D0=address; 0 if out of mem
 rts

*>>>> create D0 bytes of chip memory
TLChip:
 movem.l d1/a0-a1/a6,-(a7) ;save all except d0
 move.l xxp_intb(a4),a6
 move.l #MEMF_CHIP,d1
 move.l a4,a0
 add.l #xxp_memk,a0
 jsr _LVOAllocRemember(a6) ;(Front.i will finally call FreeRemember)
 tst.l d0
 movem.l (a7)+,d1/a0-a1/a6 ;D0=address; 0 if out of mem
 rts

*>>>> CD to program's progdir
TLProgdir:
 movem.l d0-d1/a0-a1/a6,-(a7)
 move.l xxp_dosb(a4),a6
 jsr _LVOGetProgramDir(a6)
 move.l d0,d1
 jsr _LVOCurrentDir(a6)
 movem.l (a7)+,d0-d1/a0-a1/a6
 rts

*>>>> get IDCMP from xxp_Window [xxp_Active must be GE]
TLKeyboard:
 movem.l a0-a1/a5-a6,-(a7)  ;saves all except d0-d3
 move.l xxp_AcWind(a4),a5   ;a5=current window in WSuite
.get:
 move.l xxp_Window(a5),a1   ;get popped window
 move.l wd_UserPort(a1),a0
 move.l xxp_sysb(a4),a6
 jsr _LVOWaitPort(a6)       ;wait for IDCMP
 bsr TLMget                 ;get & process
 tst.l d0
 beq .get                   ;retry if null (can't happen?)
 movem.l (a7)+,a0-a1/a5-a6
 rts

*>>>> get window message (if any) from window a1
TLMmess:
 movem.l a0-a1/a6,-(a7)    ;save all except results in D0-D4
 move.l xxp_gadb(a4),a6
 move.l wd_UserPort(a1),a0
 jsr _LVOGT_GetIMsg(a6)    ;get IDCMP
 tst.l d0
 beq.s .done               ;go if none
 move.l d0,a0
 move.l xxp_mesg(a4),a1
 moveq #im_SIZEOF-1,d1
.cach:
 move.b (a0)+,(a1)+        ;keep copy of message in xxp_mesg
 dbra d1,.cach
 move.l d0,a1
 move.l im_Class(a1),d4    ;d4=class
 moveq #0,d0               ;d0=code
 moveq #0,d1               ;d1=mousex
 moveq #0,d2               ;d2=mousey
 moveq #0,d3               ;d3=qualifier
 move.w im_Code(a1),d0
 move.w im_Qualifier(a1),d3
 move.w im_MouseX(a1),d1
 move.w im_MouseY(a1),d2
 movem.l d0-d1,-(a7)
 jsr _LVOGT_ReplyIMsg(a6)   ;reply
 moveq #-1,d0               ;set NE
 movem.l (a7)+,d0-d1
.done:
 movem.l (a7)+,a0-a1/a6     ;EQ if none (else, message in d0-d4)
 rts

*>>>> get, reply & process an IDCMP from currently popped (D0=0 if none)
TLMget:
 movem.l d4-d7/a0-a6,-(a7)  ;save all exc results in D0-D3
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a1
 bsr TLMmess                ;any message?
 beq .done                  ;no, go (D0=0)
 btst #1,d3
 beq.s .shft
 bset #0,d3                 ;both shifts bit 0
.shft:
 btst #5,d3
 beq.s .alt                 ;both alts bit 4
 bset #4,d3
.alt:
 cmp.l #IDCMP_VANILLAKEY,d4
 beq .asci
 cmp.l #IDCMP_RAWKEY,d4
 beq .rawkey
 move.l d4,d5
 and.l #IDCMP_CLOSEWINDOW,d5
 bne .close
 move.l d4,d5
 and.l #IDCMP_IDCMPUPDATE,d5
 bne .scrl
 move.l d4,d5
 and.l #IDCMP_GADGETUP,d5
 bne .gadup
 move.l d4,d5
 and.l #IDCMP_MENUPICK,d5
 bne .mupik
 move.l d4,d5
 and.l #IDCMP_REFRESHWINDOW,d5
 bne .refresh
 move.l d4,d5
 and.l #IDCMP_ACTIVEWINDOW,d5
 bne .null ;slough active window
 move.l d4,d5
 and.l #IDCMP_INACTIVEWINDOW,d5
 bne .inact
 move.l d4,d5
 and.l #IDCMP_NEWSIZE,d5
 bne .size
 move.l d4,d5
 and.l #IDCMP_MOUSEBUTTONS,d5
 beq .null
 cmp.w #$68,d0 ;accept only leftmouse down of mousebuttons
 bne .null
 move.l #128,d0
 bra .done
.asci:
 and.l #$000000FF,d0
 cmp.b #$08,d0
 bne.s .ctrh
 btst #3,d3   ; 8=bs, unless Ctrl/h
 beq.s .bs
.ctrh:
 cmp.b #$7F,d0
 beq.s .del
 cmp.b #$09,d0
 bne .done
 btst #3,d3   ; 9=tab, unless Ctrl/i
 beq.s .tab
 bra.s .done
.del:
 move.b #$8D,d0
 bra.s .done
.bs:
 move.b #$8B,d0
 bra.s .done
.tab:
 move.b #$8C,d0
 bra.s .done
.rawkey:
 and.l #$000000FF,d0  ;rawkey: recycle if keydown or blank keys
 cmp.b #$5F,d0
 beq.s .help
 cmp.b #$4C,d0
 beq.s .up
 cmp.b #$4D,d0
 beq.s .down
 cmp.b #$4F,d0
 beq.s .left
 cmp.b #$4E,d0
 beq.s .right
 cmp.b #$50,d0
 bcs .null
 cmp.b #$5A,d0
 bcc .null
 add.b #$31,d0        ;function keys
 bra.s .done
.help:
 move.b #$92,d0
 bsr TLHelp
 moveq #0,d0
 bra.s .done
.up:
 move.b #$8E,d0
 bra.s .done
.down:
 move.b #$8F,d0
 bra.s .done
.left:
 move.b #$91,d0
 bra.s .done
.right:
 move.b #$90,d0
.done:
 movem.l (a7)+,d4-d7/a0-a6
 move.l d0,xxp_kybd(a4)    ;save results in D0-D3, & xxp_kybd+0,4,8,12
 move.l d1,xxp_kybd+4(a4)
 move.l d2,xxp_kybd+8(a4)
 move.l d3,xxp_kybd+12(a4)
 tst.l d0                  ;EQ if none
 rts

.null:
 moveq #0,d0
 bra .done

.close:
 move.l #$93,d0
 bra .done

.gadup:
 move.l #$94,d0
 bra .done

.mupik:
 move.w d0,d1  ;D1=menu number (-1=none)
 and.l #31,d1
 cmp.w #31,d1
 bne.s .item
 moveq #-1,d1
.item:
 move.w d0,d2  ;D2=item number (-1=none)
 ror.w #5,d2
 and.l #63,d2
 cmp.w #63,d2
 bne.s .subitem
 moveq #-1,d2
.subitem:
 move.w d0,d3  ;D3=sub-item number (-1=none)
 rol.w #5,d3
 and.l #31,d3
 move.l #$95,d0
 cmp.w #31,d3
 bne .done
 moveq #-1,d3
 bra .done

.refresh:
 tst.l xxp_Refr(a5)           ;get xxp_Refr (=refresh subroutine)
 beq .null                    ;go if none
 bsr TLWupdate                ;update window dims
 bsr TLReqcls
 movem.l d0-d7/a0-a6,-(a7)    ;call xxp_Refr
 move.l xxp_Refr(a5),a0
 jsr (a0)
 movem.l (a7)+,d0-d7/a0-a6
 bra .null                 ;& return null if refresh message

.size:
 move.l #$96,d0
 bra .done

.inact:
 move.l #$97,d0
 bra .done

.scrl:                     ;* here if boopsi - see if scroll, else $99
 move.l #$98,d0
 move.l xxp_scrl(a5),d4    ;ignore if no scrollers
 beq .done
 move.l d4,a0              ;a0 = scroller data
 move.l xxp_slid(a4),a1    ;a1 = sys object data
 move.l xxp_mesg(a4),a2
 move.l im_Seconds(a2),d4  ;d4,d5 = message time
 move.l im_Micros(a2),d5
 sub.l xxp_asec(a1),d4     ;subtract arrival time of prev boopsi
 sub.l xxp_amic(a1),d5
 bcc.s .mic0
 add.l #1000000,d5
 subq.l #1,d4
.mic0:
 sub.l xxp_psec(a1),d4     ;subtract prefs keyboard rept time
 bcs .null                 ;reject message if before keyboard rept time
 sub.l xxp_pmic(a1),d5
 bcc.s .mic1
 subq.l #1,d4
 bcs .null
.mic1:
 move.l im_Seconds(a2),xxp_asec(a1) ;keep message arrival time for next
 move.l im_Micros(a2),xxp_amic(a1)
 sub.w xxp_LeftEdge(a5),d1 ;d1 = pointer xpos rel to left border
 bmi .scry
 sub.w xxp_TopEdge(a5),d2  ;d2 = pointer ypos rel to top border
 bmi .scry
 cmp.w xxp_PWidth(a5),d1   ;if in right border, see if ^V
 bcc.s .vert
 cmp.w xxp_PHeight(a5),d2  ;if in bot border, see if <>
 bcs .scry
 move.w xxp_PWidth(a5),d4
 move.l xxp_rtob(a1),a2
 sub.w ig_Width(a2),d4
 cmp.w d4,d1
 bcc.s .rtob
 sub.w ig_Width(a2),d4
 cmp.w d4,d1
 bcc.s .lfob
 bra .scry
.vert:
 move.w xxp_PHeight(a5),d4
 cmp.w d4,d2
 bcc .scry
 move.l xxp_upob(a1),a2
 sub.w ig_Height(a2),d4
 cmp.w d4,d2
 bcc.s .dnob
 sub.w ig_Height(a2),d4
 cmp.w d4,d2
 bcc.s .upob
 bra.s .scry

.lfob:                     ;left object clicked
 tst.w d3
 beq .null                 ;(ignore mouse up)
 tst.l xxp_hztp(a0)
 beq .null                 ;(null if can't move left)
 moveq #1,d3               ;d3 = 1 = <
 subq.l #1,xxp_hztp(a0)
 bra.s .obfx

.rtob:                     ;right object clicked
 tst.w d3
 beq .null
 move.l xxp_hztt(a0),d4
 sub.l xxp_hzvs(a0),d4
 cmp.l xxp_hztp(a0),d4
 ble .null
 moveq #2,d3               ;d3 = 2 = >
 addq.l #1,xxp_hztp(a0)
 bra.s .obfx

.upob:                     ;up object clicked
 tst.w d3
 beq .null
 tst.l xxp_vttp(a0)
 beq .null
 subq.l #1,xxp_vttp(a0)
 moveq #3,d3               ;d3 = 3 = ^
 bra.s .obfx

.dnob:                     ;down object clicked
 tst.w d3
 beq .null
 move.l xxp_vttt(a0),d4
 sub.l xxp_vtvs(a0),d4
 cmp.l xxp_vttp(a0),d4
 ble .null
 moveq #4,d3               ;d3 = 4 = V
 addq.l #1,xxp_vttp(a0)

.obfx:                     ;<>^V clicked - re-render slider
 moveq #0,d0
 moveq #0,d1
 bsr TLWscroll             ;fix slider
 bra.s .scyc
.scry:                     ;return scroller data
 moveq #-1,d0
 moveq #0,d1
 bsr TLWscroll             ;get tops
 moveq #0,d3               ;d3 = 0 if slider
.scyc:
 move.l #$98,d0            ;d0 = $98
 move.l xxp_hztp(a0),d1    ;d1 = horiz top
 move.l xxp_vttp(a0),d2    ;d2 = vert top
 bra .done


*>>>> open a window &/or initialise everything

;d0 = window num (if -1, don't open one)
;d1,d2 d3,d4 d5,d6 = posn, minsize, maxsize } unused if d0 = -1, which
;d7 = flags (0,1 for defaults)(-1 = sliders)} simply initialises everything
;a0 = title (undef if borderless)           }

TLWindow:
 movem.l d0-d7/a0-a6,-(a7) ;save all registers except result in D0
 clr.l xxp_errn(a4)

; if TLscreen has not been called, attach default public screen

 tst.l xxp_Screen(a4)
 bne.s .scgot
 move.l xxp_intb(a4),a6
 sub.l a0,a0
 jsr _LVOLockPubScreen(a6)
 move.l d0,xxp_Screen(a4)
 beq .bad1                 ;bad if can't lock (unlikely)
 move.w #-1,xxp_Public(a4) ;set to unlock on close-down
.scgot:

 tst.w xxp_Public(a4)      ;go if everything initialised
 bgt .redi

; initialise everything (note: TLColdstart zeroised everything already)

 move.l xxp_Screen(a4),a5  ;set screen data   (xxp_Width,Depth,Height)
 moveq #0,d0
 move.w sc_Width(a5),d0
 move.l d0,xxp_Width(a4)
 move.w sc_Height(a5),d0
 move.l d0,xxp_Height(a4)
 moveq #0,d0
 move.l sc_RastPort+rp_BitMap(a5),a0
 move.b bm_Depth(a0),d0
 move.l d0,xxp_Depth(a4)

 move.l xxp_intb(a4),a6    ;load system prefs for printer data
 move.l #pf_SIZEOF,d0
 sub.l d0,a7
 move.l a7,a0
 jsr _LVOGetPrefs(a6)
 move.b pf_PaperLength+1(a7),xxp_lppg(a4) ;get prefs lines/page
 subq.b #8,xxp_lppg(a4)    ;allow 8 lines runoff
 moveq #80,d0
 move.b pf_PrintLeftMargin+1(a7),d1 ;get prefs left margin
 move.b d1,xxp_marg(a4)
 add.b pf_PrintRightMargin+1(a7),d1
 sub.b d1,d0
 move.b d0,xxp_cpln(a4)    ;get prefs chrs per line
 add.l #pf_SIZEOF,a7
 move.b #-1,xxp_pica(a4)   ;default pica

 move.w #-1,xxp_Active(a4) ;no window yet active
 addq.w #2,xxp_Public(a4)  ;set xxp_Public (scrn on exit: 1=unlock 2=close)

 move.l xxp_intb(a4),a0    ;make busy sprite for TLBusy/Unbusy
 cmp.w #39,LIB_VERSION(a0)
 bcc.s .bsuq               ;go if OS3.0+
 moveq #.bsue-.bsu,d1
 move.l d1,d0
 bsr TLChip
 move.l d0,xxp_busy(a4)    ;create chip ram for busymem
 beq .bad4                 ;EQ, busymem=0 if failed (unlikely)
 move.l d0,a1              ;tfr .bsu data to busymem
 lea .bsu,a0
 subq.l #1,d1
.tfr:
 move.b (a0)+,(a1)+
 dbra d1,.tfr
.bsuq:

 move.l #256,d0            ;* put .pix data in chip ram
 bsr TLChip
 beq .bad4                 ;bad if out of chip ram
 move.l d0,d4              ;d4 = chip mem address
 move.l #rp_SIZEOF+bm_SIZEOF,d0
 bsr TLPublic
 move.l d0,d3              ;d3 = rastport+bitmap address
 beq .bad2                 ;bad if out of public mem
 move.l d0,xxp_pixx(a4)
 move.l xxp_gfxb(a4),a6
 move.l d0,a1
 jsr _LVOInitRastPort(a6)  ;init the rastport
 move.l d3,a0
 add.w #rp_SIZEOF,a0       ;init the bitmap
 moveq #2,d0
 move.l #128,d1
 moveq #8,d2
 jsr _LVOInitBitMap(a6)
 move.l d3,a0              ;a0 = bitmap
 add.w #rp_SIZEOF,a0
 move.l d3,a1              ;a1 = rasport
 move.l a0,rp_BitMap(a1)   ;point rasport to bitmap
 move.l d4,a1              ;d4,a1 = chip mem
 move.l d4,bm_Planes(a0)   ;init bitmap 1st plane
 add.l #128,d4
 move.l d4,bm_Planes+4(a0) ;init bitmap 2nd plane
 moveq #63,d0
 lea .pix,a0               ;tfr pix data to chip ram
.pixt:
 move.l (a0)+,(a1)+
 dbra d0,.pixt

 moveq #0,d0               ;set up xxp_pref
 bsr TLPrefs
 beq .bad2

 move.w #-1,xxp_ReqNull(a4)
 move.l #-1,xxp_lcom(a4)

 move.l #1024,d0           ;mem for xxp_gide
 bsr TLPublic
 move.l d0,xxp_gide(a4)
 beq .bad2                 ;bad if can't
 move.l #xxp_siz4+xxp_siz5+im_SIZEOF,d0 ;mem for xxp_FWork,FSuite,mesg
 bsr TLPublic
 move.l d0,xxp_FSuite(a4)
 beq .bad2                 ;bad if can't
 move.l d0,a0              ;a0=start of FSuite
 move.l d0,a1              ;a1 clears FSuite
 add.l #xxp_siz4,d0
 move.l d0,xxp_FWork(a4)   ;set FWork
 add.l #xxp_siz5,d0
 move.l d0,xxp_mesg(a4)    ;set mesg
 move.w #(xxp_siz4/4)-1,d0
.fclr:
 clr.l (a1)+               ;clear FSuite
 dbra d0,.fclr
 move.l a0,a1              ;font 0 is topaz/8
 addq.l #8,a1
 move.l a1,(a0)
 move.w #8,ta_YSize(a0)
 move.l #'topa',(a1)+
 move.l #'z.fo',(a1)+
 move.w #'nt',(a1)
 bsr TLOfont               ;open Topaz/8
 beq .badc                 ;bad if can't (can't happen?)

 move.l xxp_FSuite(a4),a0  ;prefs req font to font 10
 moveq #10,d0
 mulu #xxp_fsiz,d0
 add.l d0,a0
 move.l a0,a1
 addq.l #8,a1
 move.l a1,(a0)
 move.l xxp_pref(a4),a2
 move.w xxp_yhgt(a2),ta_YSize(a0)
.fnt9:
 move.b (a2)+,(a1)+
 bne .fnt9
 bsr TLOfont

 move.l xxp_FSuite(a4),a0  ;prefs TLReqshow font to font 11
 moveq #11,d0
 mulu #xxp_fsiz,d0
 add.l d0,a0
 move.l a0,a1
 addq.l #8,a1
 move.l a1,(a0)
 move.l xxp_pref(a4),a2
 add.w #xxp_yfsh,a2
 move.w #8,ta_YSize(a0)
.fnt8:
 move.b (a2)+,(a1)+
 bne .fnt8
 bsr TLOfont

 subq.l #4,a7              ;set xxp_vi
 move.l #TAG_DONE,(a7)
 move.l xxp_gadb(a4),a6
 move.l xxp_Screen(a4),a0
 move.l a7,a1
 jsr _LVOGetVisualInfoA(a6)
 move.l d0,xxp_vi(a4)
 addq.l #4,a7
 beq .bad3                 ;bad if can't get xxp_vi (unlikely)

 move.l #xxp_ewiv,xxp_ewid(a4)  ;set up xxp_ERport, xxp_EBmap
 move.l #xxp_ehgv,xxp_ehgt(a4)
 move.l #bm_SIZEOF+rp_SIZEOF,d0
 bsr TLPublic
 move.l d0,xxp_EBmap(a4)
 beq .bad2                 ;go if out of mem
 add.l #bm_SIZEOF,d0
 move.l d0,xxp_ERport(a4)
 move.l xxp_gfxb(a4),a6    ;initialise bitmaps
 move.l xxp_Depth(a4),d0
 move.l xxp_ewid(a4),d1    ;max edit width
 move.l xxp_ehgt(a4),d2    ;max font height
 move.l xxp_EBmap(a4),a0
 jsr _LVOInitBitMap(a6)
 move.l xxp_ERport(a4),a1  ;initialise ERport
 move.l a1,a2
 jsr _LVOInitRastPort(a6)
 move.l xxp_EBmap(a4),rp_BitMap(a2) ;EBmap to ERport
 move.l xxp_ewid(a4),d6    ;set d6=bytes in EBmap plane
 mulu xxp_ehgt+2(a4),d6
 lsr.l #3,d6
 move.l xxp_Depth(a4),d4   ;d4 counts bitplanes
 subq.w #1,d4
 move.l xxp_EBmap(a4),a3   ;a3 points to bitmap mem planes
 add.l #bm_Planes,a3
.plane:
 move.l d6,d0
 bsr TLChip
 move.l d0,(a3)+           ;create next EBmap plane
 beq .bad4
 dbra d4,.plane

 move.l #xxp_siz3,d0       ;set up xxp_WSuite
 bsr TLPublic
 move.l d0,xxp_WSuite(a4)
 beq .bad2
 move.l d0,a0              ;clear xxp_WSuite
 move.w #(xxp_siz3/4)-1,d0
.wclr:
 clr.l (a0)+
 dbra d0,.wclr

 movem.l (a7)+,d0-d7/a0-a6 ;restore regs for opening window
 movem.l d0-d7/a0-a6,-(a7)

; everything initialised: now open window

.redi:
 tst.w d0                  ;if d0=-1, do not open a window
 bmi .wrap

 sub.l a3,a3               ;a3 = 0 if no scrollers
 addq.l #1,d7              ;go unless d7 = -1 = scrollers wanted
 bne.s .nflz
 bsr TLSlir                ;if d7 was -1, set up a3 = scrollers
 beq .badc                 ;bad if can't
 moveq #1,d7               ;sliders set up: continue as if d7 was 0
.nflz:

 subq.l #1,d7              ;if d7 was -1/0/1 use standard flags
 bne.s .nfl0
 move.l #.flg1,d7          ;if d7=0, use .flg1
.nfl0:
 cmp.l #1,d7               ;if d7=1, use .flg2
 bne.s .nfl1
 move.l #.flg2,d7
.nfl1:

 move.l xxp_intb(a4),a6    ;if window unsizeable, no size & zoom gadgets
 cmp.w d3,d5
 bne.s .tags
 cmp.w d4,d6
 bne.s .tags
 and.l #-1-WFLG_SIZEGADGET-WFLG_HASZOOM,d7
.tags:

 sub.l #12*8+4,a7          ;room for 12 tags
 move.l a7,a1
 move.l #WA_Left,(a1)+     ; 1st tag: left posn
 move.l d1,(a1)+
 move.l #WA_Top,(a1)+      ; 2nd tag: top posn
 move.l d2,(a1)+
 move.l #WA_Width,(a1)+    ; 3rd tag: width (=max)
 move.l d5,(a1)+
 tst.w d5                  ;ok if width > 0
 bpl.s .nmxx
 addq.w #1,d5              ;ok if width = -1
 beq.s .nmxx
 subq.w #1,d5
 neg.w d5
 ext.l d5
 move.l #WA_InnerWidth,-8(a1) ;else, treat -1 * d5 as inner width
 move.l d5,-4(a1)
.nmxx:
 move.l #WA_Height,(a1)+   ; 4th tag: height (=max)
 move.l d6,(a1)+
 tst.w d6
 bpl.s .nmxy               ;ok if ht > 0
 addq.w #1,d6
 beq.s .nmxy               ;ok if ht = -1
 subq.w #1,d6
 neg.w d6
 ext.l d6
 move.l #WA_InnerHeight,-8(a1) ;else, treat -1 * d6 as inner height
 move.l d6,-4(a1)
.nmxy:
 move.l #WA_Flags,(a1)+    ; 5th tag: flags
 move.l d7,(a1)+
 move.l #WA_IDCMP,(a1)+    ; 6th tag: IDCMP
 move.l #.idcm,(a1)+
 and.l #WFLG_BORDERLESS,d7
 bne.s .ntit
 move.l #WA_Title,(a1)+    ; 7th tag: window title (no title if borderless)
 move.l a0,(a1)+
.ntit:
 move.l #WA_CustomScreen,(a1)+ ; 8th tag: screen pointer
 move.l xxp_Screen(a4),(a1)+
 tst.w d3
 bmi.s .nmnx
 move.l #WA_MinWidth,(a1)+ ; 9th tag: minimum width
 move.l d3,(a1)+
.nmnx:
 tst.w d4
 bmi.s .nmny
 move.l #WA_MinHeight,(a1)+ ; 10th tag: minimum height
 move.l d4,(a1)+
.nmny:
 cmp.l #0,a3
 beq.s .ngad
 move.l #WA_Gadgets,(a1)+  ; 11th tag: gadgets (if scrollers)
 move.l xxp_gadg(a4),(a1)+
 move.l #WA_AutoAdjust,(a1)+ ; 12th tag: auto adjust (set TRUE)
 move.l #-1,(a1)+
.ngad:
 move.l #TAG_DONE,(a1)
 move.l d0,d7              ;d7=window num
 sub.l a0,a0
 move.l a7,a1
 jsr _LVOOpenWindowTagList(a6) ;open window
 add.l #12*8+4,a7          ;discard flags, restore stack
 tst.l d0
 beq .bad4                 ;go if out of chip ram

 move.w d7,xxp_Active(a4)  ;create WSuite entry for window
 move.l xxp_WSuite(a4),a5
 mulu #xxp_siz2,d7
 add.l d7,a5
 move.l a5,xxp_AcWind(a4)
 move.l d0,a0              ;a0=window
 move.l a0,xxp_Window(a5)
 move.w #.frbk,xxp_FrontPen(a5) ;set defaults for printing data
 move.b #.mode,xxp_DrawMode(a5)
 clr.b xxp_Kludge(a5)
 clr.l xxp_LeftEdge(a5)    ;set left edge,topedge within border
 move.b wd_BorderLeft(a0),xxp_LeftEdge+1(a5)
 move.b wd_BorderTop(a0),xxp_TopEdge+1(a5)
 clr.w xxp_Fnum(a5)        ;initially font 0 ( = Topaz/8 set below)
 move.w #-1,xxp_Attc(a5)   ;Fsty inoperative (new Fnum attached)
 move.l a4,xxp_IText(a5)   ;text normally read from buff
 clr.w xxp_Fsty(a5)        ;default font style = plain
 clr.w xxp_Tspc(a5)        ;default text spacing = 0
 bsr TLWupdate             ;set PWidth,PHeight
 move.l wd_RPort(a0),a1
 move.l a1,xxp_WPort(a5)
 clr.l xxp_Menu(a5)        ;clear menu pointer
 clr.w xxp_Menuon(a5)      ;menu not on
 move.l #$00020102,xxp_shad(a5) ;shadow font default

 clr.l xxp_Mmem(a5)               ;} Defaults in case this window
 move.l #10000,xxp_Mmsz(a5)       ;} used for TLMultiline
 move.w #76,xxp_Mmxc(a5)          ;}

 move.l xxp_LeftEdge(a5),xxp_ReqLeft(a5) ;default requester posn
 clr.l xxp_Refr(a5)        ;clear refresh pointer

 clr.l xxp_RFont(a5)       ;clear req,help fonts & tspaces
 clr.l xxp_HFont(a5)
 clr.l xxp_RTspc(a5)
 clr.l xxp_RFsty(a5)
 move.l a3,xxp_scrl(a5)    ;xxp_scrl = xxp_scro structure, or 0

 moveq #0,d0               ;attach Topaz/8 plain to ITextFont
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont
 beq.s .bad4               ;bad if can't (unlikely)

 move.l xxp_FSuite(a4),a0  ;attach font 10 to requester
 add.w #10*xxp_fsiz,a0
 tst.l (a0)
 beq.s .f9no               ;go if no font 10
 move.l xxp_pref(a4),a0
 move.b xxp_yspc(a0),xxp_RTspc+1(a5) ;use prefs tspc (if font 10 exists)
 moveq #10,d0
 moveq #0,d1
 move.b xxp_ysty(a0),d1
 moveq #1,d2
 bsr TLNewfont
 bne.s .help               ;go if succeeds
.f9no:
 moveq #0,d0               ;else attach Topaz/8 plain to requester
 moveq #0,d1
 moveq #1,d2
 bsr TLNewfont
.help:

 moveq #0,d0               ;attach Topaz/8 plain to help
 moveq #0,d1
 moveq #2,d2
 bsr TLNewfont

.wrap:
 move.l #-1,(a7)           ;stack D0 = -1 if good
 bra.s .done

.bad1:
 moveq #7,d0               ;can't lock default screen (unlikely)
 bra.s .bad
.bad2:
 moveq #1,d0               ;out of public mem (unlikely)
 bra.s .bad
.bad3:
 moveq #9,d0               ;can't get xxp_vi (unlikely)
 bra.s .bad
.bad4:
 moveq #2,d0               ;out of chip mem
.bad:
 move.l d0,xxp_errn(a4)
.badc:
 clr.l (a7)                ;stack D0 = 0 if bad

.done:
 movem.l (a7)+,d0-d7/a0-a6 ;EQ, D0=0 if bad
 rts

; constants for window
.pens: dc.l -1     ;default pens structure
.frbk: EQU $0100   ;font & back pens
.mode: EQU RP_JAM2 ;draw mode

; idcmp for window
.idc0: EQU IDCMP_CLOSEWINDOW!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_IDCMPUPDATE
.idc1: EQU .idc0!IDCMP_ACTIVEWINDOW!IDCMP_INACTIVEWINDOW!IDCMP_REFRESHWINDOW
.idcm: EQU .idc1!IDCMP_MOUSEBUTTONS!IDCMP_MENUPICK!IDCMP_NEWSIZE

; default flags if D7=0 (normal windows)
.flg0: EQU WFLG_SIZEGADGET!WFLG_DRAGBAR!WFLG_CLOSEGADGET!WFLG_DEPTHGADGET
.flg1: EQU .flg0!WFLG_SMART_REFRESH!WFLG_ACTIVATE!WFLG_HASZOOM

; default flags if D7=1 (windows 10,11)
.flg2: EQU WFLG_BORDERLESS!WFLG_ACTIVATE!WFLG_SMART_REFRESH

; busy sprite data: 4nulls, 4bytes/line (X16 lines), 4 nulls
.bsu:
 dc.w $0000,$0000,$0400,$07c0,$0000,$07c0,$0100,$0380
 dc.w $0000,$07e0,$07c0,$1ff8,$1ff0,$3fec,$3ff8,$7fde
 dc.w $3ff8,$7fbe,$7ffc,$ff7f,$7efc,$ffff,$7ffc,$ffff
 dc.w $3ff8,$7ffe,$3ff8,$7ffe,$1ff0,$3ffc,$07c0,$1ff8
 dc.w $0000,$07e0,$0000,$0000
.bsue:

;pictures for tabs, &c
;tabs: topl,over,under,topr,botl,botr,<,>,^,v,tick,dot
.pix:
 dc.b $00,$00,$00,$00,$3F,$FF,$EF,$F3,$EF,$C7,$FF,$FF,$FF,$00,$00,$00
 dc.b $00,$C0,$C0,$C0,$3F,$FF,$DF,$FB,$DF,$DF,$FF,$F3,$FF,$00,$00,$00
 dc.b $07,$F9,$C7,$F8,$3F,$FF,$1F,$F8,$BF,$DF,$FF,$F3,$FF,$00,$00,$00
 dc.b $0F,$FD,$8F,$FC,$8F,$FE,$7F,$FE,$7F,$DF,$FF,$FF,$FF,$00,$00,$00
 dc.b $1F,$FF,$9F,$FE,$4F,$FE,$7F,$FE,$DF,$7F,$FF,$FF,$FF,$00,$00,$00
 dc.b $3F,$FF,$3F,$FF,$27,$FC,$FF,$FF,$DF,$BF,$FF,$CF,$FF,$00,$00,$00
 dc.b $3F,$FF,$3F,$FF,$0C,$F0,$FF,$FF,$DF,$DF,$FF,$CF,$FF,$00,$00,$00
 dc.b $3F,$FF,$3F,$FF,$01,$80,$FF,$FF,$FF,$EF,$FF,$FF,$FF,$00,$00,$00

 dc.b $01,$80,$01,$80,$FF,$FC,$FF,$FF,$F7,$FF,$FC,$E1,$FF,$00,$00,$00
 dc.b $0F,$31,$0F,$30,$FF,$FC,$E7,$E7,$E3,$E3,$FC,$CC,$C3,$00,$00,$00
 dc.b $3F,$C7,$BF,$C4,$FF,$FC,$E3,$C7,$C1,$E3,$F9,$CC,$99,$00,$00,$00
 dc.b $7F,$F3,$7F,$F2,$EF,$F8,$81,$81,$80,$E3,$F9,$E1,$01,$00,$00,$00
 dc.b $7F,$F9,$FF,$F8,$3F,$F0,$80,$01,$E3,$80,$F3,$87,$89,$00,$00,$00
 dc.b $FF,$FC,$FF,$FC,$1F,$E0,$81,$81,$E3,$C1,$33,$33,$D9,$00,$00,$00
 dc.b $FF,$FC,$FF,$FC,$03,$00,$E3,$C7,$E3,$E3,$87,$33,$03,$00,$00,$00
 dc.b $FF,$FC,$FF,$FC,$00,$00,$E7,$E7,$E3,$F7,$E7,$87,$FF,$00,$00,$00

*>>>> shut down everything started by TLWindow
TLWclose:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;saves all regs
 bsr TLClosefile           ;close xxp_hndl if open

 move.l xxp_splc(a4),d0    ;remove spell.library resources
 beq.s .splc2              ;go if splc unset
 move.l d0,a5              ;a5 = xxp_Spel
 move.l xxp_sysb(a4),a6
 move.l xxp_dptr(a5),d0    ;go if xxp_dptr unset
 beq.s .splc1
 move.l d0,a1              ;free xxp_dptr
 jsr _LVOFreeVec(a6)
 clr.l xxp_dptr(a5)
.splc1:
 move.l xxp_pptr(a5),d0    ;go if xxp_pptr unset
 beq.s .splc2
 move.l d0,a1
 jsr _LVOFreeVec(a6)       ;free xxp_pptr
 clr.l xxp_pptr(a5)
.splc2:

 tst.l xxp_Screen(a4)      ;go if no screen ever attached
 beq.s .quit
 tst.w xxp_Public(a4)      ;go if initialised
 bgt.s .init
 addq.w #2,xxp_Public(a4)  ;go close/unlock screen
 bra.s .unlk
.init:

 tst.l xxp_WSuite(a4)      ;close window 0-9 (if open) if WSuite exists
 beq.s .nsui
 moveq #9,d0
.nxsui:
 bsr TLWsub
 dbra d0,.nxsui
.nsui:

 tst.l xxp_FSuite(a4)      ;close font 0-9 (if open) if FSuite exists
 beq.s .nfsu
 moveq #9,d0
.nxfsu:
 bsr TLFsub
 dbra d0,.nxfsu
.nfsu:

 bsr TLSlik                ;free xxp_slid if any

 move.l xxp_vi(a4),d0      ;free xxp_vi (if any)
 beq.s .unlk
 move.l d0,a0
 move.l xxp_gadb(a4),a6
 jsr _LVOFreeVisualInfo(a6)
.unlk:

 move.l xxp_intb(a4),a6    ;close/unlock screen
 cmp.w #2,xxp_Public(a4)   ;go if screen to be closed
 beq.s .clos
 sub.l a0,a0               ;unlock screen, leave unclosed
 move.l xxp_Screen(a4),a1
 jsr _LVOUnlockPubScreen(a6)
 bra.s .quit
.clos:
 move.l xxp_Screen(a4),a0  ;close screen
 jsr _LVOCloseScreen(a6)
.quit:

 clr.l xxp_Screen(a4)      ;note that nothing now initialised

 move.l a4,a0              ;free remember if xxp_memk was used
 add.l #xxp_memk,a0
 tst.l (a0)
 beq.s .cmem
 move.l xxp_intb(a4),a6
 moveq #-1,d0
 move.l a0,-(a7)
 jsr _LVOFreeRemember(a6)
 move.l (a7)+,a0
 clr.l (a0)                ;note xxp_memk now cleared

.cmem:
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts


*>>>> set up xxp_slis structure, pointed to by xxp_slid
TLSlis:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 clr.l xxp_errn(a4)
 moveq #xxp_slsz,d0        ;create mem for xxp_slis structure
 bsr TLPublic
 beq .bad1                 ;bad if can't
 move.l d0,xxp_slid(a4)    ;point xxp_slid to xxp_slis structure
 move.l d0,a3              ;a3 = xxp_slis
 move.l a3,a0
 moveq #xxp_slsz,d0
 subq.w #1,d0
.clr:
 clr.b (a0)+               ;clear the structure
 dbra d0,.clr
 move.l a3,a0              ;get prefs data to xxp_psec,mic
 add.w #xxp_psec-pf_KeyRptSpeed,a0
 moveq #pf_KeyRptDelay,d0
 move.l xxp_intb(a4),a6
 jsr _LVOGetPrefs(a6)
 move.l xxp_Screen(a4),a0  ;DrawInfo to xxp_draw
 jsr _LVOGetScreenDrawInfo(a6)
 move.l d0,xxp_draw(a3)
 beq .bad3
 moveq #SIZEIMAGE,d0       ;size object
 bsr.s .Objt
 move.l d0,xxp_szob(a3)
 beq.s .bad2
 moveq #LEFTIMAGE,d0       ;left object
 bsr.s .Objt
 move.l d0,xxp_lfob(a3)
 beq.s .bad2
 moveq #RIGHTIMAGE,d0      ;right object
 bsr.s .Objt
 move.l d0,xxp_rtob(a3)
 beq.s .bad2
 moveq #UPIMAGE,d0         ;up object
 bsr.s .Objt
 move.l d0,xxp_upob(a3)
 beq.s .bad2
 moveq #DOWNIMAGE,d0       ;down object
 bsr.s .Objt
 move.l d0,xxp_dnob(a3)
 beq.s .bad2
 moveq #CHECKIMAGE,d0      ;check object
 bsr.s .Objt
 move.l d0,xxp_ckob(a3)
 beq.s .bad2
 moveq #-1,d0              ;quit ok
 bra.s .quit
.bad1:                     ;bad 1: out of public ram
 addq.w #1,xxp_errn+2(a4)
 bra.s .bad
.bad2
 move.w #36,xxp_errn+2(a4) ;bad 2: can't create rendering objects
 bra.s .bad
.bad3:                     ;bad 3: can't get screen DrawInfo
 move.w #37,xxp_errn+2(a4)
.bad:
 bsr TLSlik                ;remove everything if bad
 moveq #0,d0               ;EQ if bad
.quit:
 movem.l (a7)+,d0-d7/a0-a6
 rts

.Objt                      ;** create system image object,  D0 = which
 movem.l d1-d7/a0-a6,-(a7) ;save all except result in D0
 sub.l a0,a0               ;a0 = class = null
 lea .inam,a1              ;a1 = class name (since a0 null)
 sub.w #28,a7              ;room for 3 tags
 move.l a7,a2
 move.l #SYSIA_DrawInfo,(a2)+ ;tag 1: Draw Info
 move.l xxp_draw(a3),(a2)+
 move.l #SYSIA_Which,(a2)+    ;tag 2: Which = D0 on call
 move.l d0,(a2)+
 move.l #SYSIA_Size,(a2)+     ;tag 3: size = SYSISIZE_MEDRES
 move.l #SYSISIZE_MEDRES,(a2)+
 clr.l (a2)                ;delimit tags
 move.l a7,a2              ;a2 = tags
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)    ;get object pointer
 add.w #28,a7              ;discard tags
 movem.l (a7)+,d1-d7/a0-a6
 rts

.inam: dc.b "sysiclass",0
 ds.w 0

*>>>> remove xxp_slis structure from xxp_slid
TLSlik:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l xxp_slid(a4),d0
 beq.s .done               ;go if already doesn't exist
 move.l d0,a3
 move.l xxp_intb(a4),a6
 move.l xxp_szob(a3),d0
 move.l d0,a0
 beq.s .draw
 jsr _LVODisposeObject(a6)
 move.l xxp_lfob(a3),d0
 move.l d0,a0
 beq.s .draw
 jsr _LVODisposeObject(a6)
 move.l xxp_rtob(a3),d0
 move.l d0,a0
 beq.s .draw
 jsr _LVODisposeObject(a6)
 move.l xxp_upob(a3),d0
 move.l d0,a0
 beq.s .draw
 jsr _LVODisposeObject(a6)
 move.l xxp_dnob(a3),d0
 move.l d0,a0
 beq.s .draw
 jsr _LVODisposeObject(a6)
 move.l xxp_ckob(a3),d0
 move.l d0,a0
 beq.s .draw
 jsr _LVODisposeObject(a6)
.draw:
 move.l xxp_Screen(a4),a0  ;dispose of sceen's DrawInfo
 move.l xxp_draw(a3),d0
 move.l d0,a1
 beq.s .done
 jsr _LVOFreeScreenDrawInfo(a6)
.done:
 clr.l xxp_slid(a4)        ;note xxp_slis doesn't exist
 movem.l (a7)+,d0-d7/a0-a6 ;(FreeMem will release its memory)
 rts

*>>>> set up window sliders
TLSlir:
 movem.l d0-d7/a0-a2/a4-a6,-(a7) ;save all exc result in a3
 clr.l xxp_errn(a4)
 tst.l xxp_slid(a4)        ;slid already exists?
 bne.s .cont               ;yes, go
 bsr TLSlis                ;no, set up slid
 beq .done                 ;go if can't
.cont:
 moveq #xxp_scrs,d0
 bsr TLPublic
 beq .bad1
 move.l d0,a3              ;a3 = xxp_slir structure
 move.l xxp_slid(a4),a2    ;a2 = xxp_slis structure

 move.l xxp_szob(a2),a0    ;set d7 = max ht of left, right, size objects
 moveq #0,d7
 move.w ig_Height(a0),d7
 move.l xxp_lfob(a2),a0
 cmp.w ig_Height(a0),d7
 bcc.s .mxh1
 move.w ig_Height(a0),d7
.mxh1:
 move.l xxp_rtob(a2),a0
 cmp.w ig_Height(a0),d7
 bcc.s .mxh2
 move.w ig_Height(a0),d7
.mxh2:

 moveq #0,d6               ;set d6 = max wd of up, down, size objects
 move.l xxp_szob(a2),a0
 move.w ig_Width(a0),d6
 move.l xxp_upob(a2),a0
 cmp.w ig_Width(a0),d6
 bcc.s .mxw1
 move.w ig_Width(a0),d6
.mxw1:
 move.l xxp_dnob(a2),a0
 cmp.w ig_Width(a0),d6
 bcc.s .mxw2
 move.w ig_Width(a0),d6
.mxw2:

 move.l xxp_Screen(a4),a0  ;set d4 = screen top + font height + 1
 moveq #0,d4
 move.b sc_WBorTop(a0),d4
 move.l sc_Font(a0),a0
 add.w ta_YSize(a0),d4
 addq.w #1,d4

 sub.w #200,a7             ;room for tags
 move.l a7,a6
 move.l #PGA_Freedom,(a6)+ ;tag 1: freedom = horizontal
 move.l #FREEHORIZ,(a6)+
 move.l #GA_LEFT,(a6)+     ;tag 2: left = 3
 move.l #3,(a6)+
 move.l #GA_RelBottom,(a6)+ ;tag 3: relbottom = 3 - D7
 moveq #3,d0
 sub.l d7,d0
 move.l d0,(a6)+
 move.l #GA_RelWidth,(a6)+ ;tag 4: relwidth = -(lfob wd + rtob wd + d6 +5)
 moveq #-5,d0
 sub.l d6,d0
 moveq #0,d1
 move.l xxp_lfob(a2),a0
 move.w ig_Width(a0),d1
 move.l xxp_rtob(a2),a0
 add.w ig_Width(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_Height,(a6)+   ;tag 5: height = d7 - 4
 move.l d7,d0
 subq.l #4,d0
 move.l d0,(a6)+
 move.l #GA_BottomBorder,(a6)+  ;tag 6: bottom border = 1
 move.l #1,(a6)+
 move.l #GA_ID,(a6)+       ;tag 7: id = 50
 move.l #50,(a6)+
 move.l #PGA_Total,(a6)+   ;tag 8: total = 256 pro-tem
 move.l #256,(a6)+
 move.l #256,xxp_hztt(a3)
 move.l #PGA_Visible,(a6)+ ;tag 9: visible = 256 pro-tem
 move.l #256,(a6)+
 move.l #256,xxp_hzvs(a3)
 move.l #PGA_Top,(a6)+     ;tag 10: top = 0 pro-tem
 clr.l (a6)+
 clr.l xxp_hztp(a3)
 move.l #PGA_Borderless,(a6)+   ;tag 11: borderless = 1
 move.l #1,(a6)+
 move.l #ICA_TARGET,(a6)+  ;tag 12: target = ictarget
 move.l #ICTARGET_IDCMP,(a6)+
 move.l #PGA_NewLook,(a6)+ ;tag 13 newlook = true
 move.l #1,(a6)+
 clr.l (a6)

 sub.l a0,a0               ;create horz scroller object
 lea .gcls,a1
 move.l a7,a2
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)
 add.w #200,a7
 move.l d0,xxp_scoh(a3)
 beq .bad2a

 sub.w #200,a7             ;tags for < button
 move.l a7,a6
 move.l xxp_slid(a4),a2

 move.l #GA_Image,(a6)+    ;tag 1: image = lfob
 move.l xxp_lfob(a2),(a6)+
 move.l #GA_RelRight,(a6)+ ;tag 2: rel right = -(lfob wd + rtob wd + d6 - 1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_lfob(a2),a0
 move.w ig_Width(a0),d1
 move.l xxp_rtob(a2),a0
 add.w ig_Width(a0),d1
 sub.l d1,d0
 sub.l d6,d0
 move.l d0,(a6)+
 move.l #GA_RelBottom,(a6)+ ;tag 3: rel bottom = -(lfob ht -1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_lfob(a2),a0
 move.w ig_Height(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_BottomBorder,(a6)+ ;tag 4: bottom border = 1
 move.l #1,(a6)+
 move.l #GA_Previous,(a6)+  ;tag 5: previous = slider ob
 move.l xxp_scoh(a3),(a6)+
 move.l #GA_ID,(a6)+        ;tag 6: id = 51
 move.l #51,(a6)+
 move.l #ICA_TARGET,(a6)+   ;tag 7: target = idcmp
 move.l #ICTARGET_IDCMP,(a6)+
 clr.l (a6)

 sub.l a0,a0               ;make < button
 lea .bcls,a1
 move.l a7,a2
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)
 add.w #200,a7
 move.l d0,xxp_slfo(a3)
 beq .bad2b

 sub.w #200,a7             ;tags for > button
 move.l a7,a6
 move.l xxp_slid(a4),a2

 move.l #GA_Image,(a6)+    ;tag 1: image = right object
 move.l xxp_rtob(a2),(a6)+
 move.l #GA_RelRight,(a6)+ ;tag 2: rel right = -(rtob wd + d6 - 1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_rtob(a2),a0
 move.w ig_Width(a0),d1
 add.l d6,d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_RelBottom,(a6)+ ;tag 3: rel bottom = -(rtob ht - 1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_rtob(a2),a0
 move.w ig_Height(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_BottomBorder,(a6)+ ;tag 4: bottom border = 1
 move.l #1,(a6)+
 move.l #GA_Previous,(a6)+ ;tag 5: previous = left gadget
 move.l xxp_slfo(a3),(a6)+
 move.l #GA_ID,(a6)+       ;tag 6: id = 52
 move.l #52,(a6)+
 move.l #ICA_TARGET,(a6)+  ;tag 7: target = idcmp
 move.l #ICTARGET_IDCMP,(a6)+
 clr.l (a6)

 sub.l a0,a0               ;make > button
 lea .bcls,a1
 move.l a7,a2
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)
 add.w #200,a7
 move.l d0,xxp_srto(a3)
 beq .bad2c

 sub.w #200,a7             ;tags for vertical slider
 move.l a7,a6
 move.l xxp_slid(a4),a2

 move.l #PGA_Freedom,(a6)+ ;tag 1: freedom = vertical
 move.l #FREEVERT,(a6)+
 move.l #GA_Top,(a6)+      ;tag 2: top = d4 + 1
 move.l d4,d0
 addq.l #1,d0
 move.l d0,(a6)+
 move.l #GA_RelRight,(a6)+ ;tag 3: rel right = -(d6 - 4)
 moveq #4,d0
 sub.l d6,d0
 addq.l #1,d0              ;why needed?????????????
 move.l d0,(a6)+
 move.l #GA_RelHeight,(a6)+ ;tag 4: rel height = -(sz+up+dn ht + 2 + d4)
 moveq #-2,d0
 moveq #0,d1
 move.l xxp_szob(a2),a0
 move.w ig_Height(a0),d1
 move.l xxp_upob(a2),a0
 add.w ig_Height(a0),d1
 move.l xxp_dnob(a2),a0
 add.w ig_Height(a0),d1
 sub.l d1,d0
 sub.l d4,d0
 move.l d0,(a6)+
 move.l #GA_Width,(a6)+    ;tag 5: width = d6 - 6
 move.l d6,d0
 subq.l #6,d0
 subq.l #2,d0              ;why needed ?????????
 move.l d0,(a6)+
 move.l #GA_RightBorder,(a6)+ ;tag 6: right border = 1
 move.l #1,(a6)+
 move.l #GA_ID,(a6)+       ;tag 7: id = 53
 move.l #53,(a6)+
 move.l #PGA_Total,(a6)+   ;tag 8: total = 256
 move.l #256,(a6)+
 move.l #256,xxp_vttt(a3)
 move.l #PGA_Visible,(a6)+ ;tag 9: visible = 256
 move.l #256,(a6)+
 move.l #256,xxp_vtvs(a3)
 move.l #PGA_Top,(a6)+     ;tag 10: top = 0
 clr.l (a6)+
 clr.l xxp_vttp(a3)
 move.l #PGA_Borderless,(a6)+   ;tag 11: borderless = 1
 move.l #1,(a6)+
 move.l #ICA_TARGET,(a6)+  ;tag 12: target = idcmp
 move.l #ICTARGET_IDCMP,(a6)+
 move.l #PGA_NewLook,(a6)+ ;tag 13 newlook = true
 move.l #1,(a6)+
 clr.l (a6)

 sub.l a0,a0               ;make vertical slider
 lea .gcls,a1
 move.l a7,a2
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)
 add.w #200,a7
 move.l d0,xxp_scov(a3)
 beq .bad2d

 sub.w #200,a7             ;tags for ^ button
 move.l a7,a6
 move.l xxp_slid(a4),a2

 move.l #GA_Image,(a6)+    ;tag 1: image = up object
 move.l xxp_upob(a2),(a6)+
 move.l #GA_RelRight,(a6)+ ;tag 2: rel right = -(upob wd - 1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_upob(a2),a0
 move.w ig_Width(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_RelBottom,(a6)+    ;tag 3: rel bottom = -(up+dn+sz ob - 1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_upob(a2),a0
 move.w ig_Height(a0),d1
 move.l xxp_dnob(a2),a0
 add.w ig_Height(a0),d1
 move.l xxp_szob(a2),a0
 add.w ig_Height(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_RightBorder,(a6)+  ;tag 4: right border = 1
 move.l #1,(a6)+
 move.l #GA_Previous,(a6)+ ;tag 5: previous = vert slider
 move.l xxp_scov(a3),(a6)+
 move.l #GA_ID,(a6)+       ;tag 6: id = 54
 move.l #54,(a6)+
 move.l #ICA_TARGET,(a6)+  ;tag 7: target = idcmp
 move.l #ICTARGET_IDCMP,(a6)+
 clr.l (a6)

 sub.l a0,a0               ;make ^ button
 lea .bcls,a1
 move.l a7,a2
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)
 add.w #200,a7
 move.l d0,xxp_supo(a3)
 beq .bad2e

 sub.w #200,a7             ;tags for V button
 move.l a7,a6
 move.l xxp_slid(a4),a2

 move.l #GA_Image,(a6)+    ;tag 1: image = down object
 move.l xxp_dnob(a2),(a6)+
 move.l #GA_RelRight,(a6)+ ;tag 2: rel right = -(dnob wd - 1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_dnob(a2),a0
 move.w ig_Width(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_RelBottom,(a6)+    ;tag 3: rel bottom = -(dn+sz ob ht -1)
 moveq #1,d0
 moveq #0,d1
 move.l xxp_dnob(a2),a0
 move.w ig_Height(a0),d1
 move.l xxp_szob(a2),a0
 add.w ig_Height(a0),d1
 sub.l d1,d0
 move.l d0,(a6)+
 move.l #GA_RightBorder,(a6)+  ;tag 4: right border = 1
 move.l #1,(a6)+
 move.l #GA_Previous,(a6)+ ;tag 5: previous = ^ button
 move.l xxp_supo(a3),(a6)+
 move.l #GA_ID,(a6)+       ;tag 6: id = 55
 move.l #55,(a6)+
 move.l #ICA_TARGET,(a6)+  ;tag 7: target = idcmp
 move.l #ICTARGET_IDCMP,(a6)+
 clr.l (a6)

 sub.l a0,a0               ;make V object
 lea .bcls,a1
 move.l a7,a2
 move.l xxp_intb(a4),a6
 jsr _LVONewObjectA(a6)
 add.w #200,a7
 move.l d0,xxp_sdno(a3)
 beq .bad2f

 move.l xxp_gadb(a4),a6    ;get gadet context
 move.l a4,a0
 add.w #xxp_gadg,a0
 clr.l (a0)
 jsr _LVOCreateContext(a6)
 tst.l d0
 beq .bad2g

 move.l xxp_gadg(a4),a0      ;daisy chain gadgets together...
 move.l a0,xxp_gcnt(a3)
 move.l gg_NextGadget(a0),d0 ;a0 = start gadget; d0 = gadget delimiter

 move.l xxp_scoh(a3),a2      ;start gad -> horiz scroller
 move.l a2,gg_NextGadget(a0)
 move.l a2,a0
 move.l xxp_slfo(a3),a2      ;horiz slider -> left button
 move.l a2,gg_NextGadget(a0)
 move.l a2,a0
 move.l xxp_srto(a3),a2      ;left button -> right button
 move.l a2,gg_NextGadget(a0)
 move.l a2,a0
 move.l xxp_scov(a3),a2      ;vert slider -> right button
 move.l a2,gg_NextGadget(a0)
 move.l a2,a0
 move.l xxp_supo(a3),a2      ;up button -> vert slider
 move.l a2,gg_NextGadget(a0)
 move.l a2,a0
 move.l xxp_sdno(a3),a2      ;down button -> up button
 move.l a2,gg_NextGadget(a0)
 move.l a2,a0
 move.l d0,gg_NextGadget(a0) ;terminator -> down button

 bra.s .done               ;return good

.bad1:                     ;bad 1: out of public mem
 addq.w #1,xxp_errn+2(a4)
 bra.s .done
.bad2g:
 move.l xxp_sdno(a3),a0
 jsr _LVODisposeObject(a6)
.bad2f:
 move.l xxp_supo(a3),a0
 jsr _LVODisposeObject(a6)
.bad2e:
 move.l xxp_scov(a3),a0
 jsr _LVODisposeObject(a6)
.bad2d:
 move.l xxp_srto(a3),a0
 jsr _LVODisposeObject(a6)
.bad2c:
 move.l xxp_slfo(a3),a0
 jsr _LVODisposeObject(a6)
.bad2b:
 move.l xxp_scoh(a3),a0
 jsr _LVODisposeObject(a6)
.bad2a:
 move.w #38,xxp_errn+2(a4)
.done:
 tst.l xxp_errn(a4)                   ;EQ if bad
 eori.w #-1,ccr
 bne.s .quit
 sub.l a3,a3                          ;a3 = 0 if bad
 moveq #0,d0
.quit:
 movem.l (a7)+,d0-d7/a0-a2/a4-a6      ;xxp_scro struct in a3 if good
 rts

.gcls: dc.b "propgclass",0
.bcls: dc.b "buttongclass",0
  ds.w 0

*>>>> print IText of currently popped window at position D0,D1
TLText:
 movem.l d0-d1/a0-a1/a5-a6,-(a7)      ;save all registers
 move.l xxp_gfxb(a4),a6

 move.l xxp_AcWind(a4),a5   ;a5 = window
 add.w xxp_LeftEdge(a5),d0  ;make d0,d1 rel to printable area of window
 add.w xxp_TopEdge(a5),d1
 move.l xxp_WPort(a5),a1    ;set a1 = rastport

 bsr TLWfont                ;check font, soft style
 bsr TLWpens                ;set pens, draw mode

 move.l rp_Font(a1),a0
 add.w tf_Baseline(a0),d1   ;make d1 rel to baseline

 jsr _LVOMove(a6)           ;posn rastport for Text

 move.l xxp_IText(a5),a0    ;a0 = text
 move.l a0,a1
 moveq #-1,d0
.lgth:
 addq.l #1,d0               ;d0 = text length
 tst.b (a1)+
 bne .lgth

 move.l xxp_WPort(a5),a1    ;a1 = RastPort
 move.w xxp_Tspc(a5),rp_TxSpacing(a1) ;fix text spacing
 bsr TLItal                 ;fix xpos if ital

 jsr _LVOText(a6)
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

*>>>> fix xpos of italic text   (all regs must be ready for TLText)
TLItal:
 btst #1,xxp_Fsty+1(a5)     ;quit quickly unless italic
 beq.s .quit
 movem.l d0-d1/a0-a2,-(a7)  ;save all
 sub.w #te_SIZEOF,a7
 move.l a7,a2
 move.l a1,-(a7)
 jsr _LVOTextExtent(a6)     ;get text extent
 move.l (a7)+,a1
 tst.w te_Extent(a7)        ;text minx
 bpl.s .done                ;ignore if >= 0
 move.w rp_cp_x(a1),d0
 sub.w te_Extent(a7),d0     ;bump xpos by xmin
 move.w rp_cp_y(a1),d1
 jsr _LVOMove(a6)           ;move right by xmin
.done:
 add.w #te_SIZEOF,a7
 movem.l (a7)+,d0-d1/a0-a2
.quit:
 rts

*>>>> for IText: sets D4=pixel width  D5=no.chrs  D6=YSize  D7=BaseLine
TLTsize:
 move.l a5,-(a7)          ;save all exc D4-D7
 move.l xxp_AcWind(a4),a5 ;A5=currently popped window
 bsr.s TLThorz            ;get D4-D5
 bsr.s TLTvert            ;get D6-D7
 movem.l (a7)+,a5
 rts

*>>>> A5 is xxp_wsuw: get TLTsize data, add xxp_xmin,xxp_xmax
TLTszdo:
 bsr.s TLThorz              ;get D4-D5
 add.w xxp_xmin(a5),d4
 add.w xxp_xmax(a5),d4
 bsr.s TLTvert              ;get D6-D7
 rts

*>>>> A5=xxp_wsuw:  set D4=width of text, D5=no. of chrs

; returns d4 = extent of text (including italic tilt, &c)
;         xxp_xmin   = xmin (+ve), if TextExtent returned xmin -ve, else 0
;         xxp_xmax   = xmax+1- d4, if TextExtent returned xmax+1 > d4
;         d5 = number of characters

TLThorz:
 movem.l d0-d1/a0-a2/a6,-(a7) ;save all regs except D4,D5
 bsr TLWfont                ;attach font,style to xxp_WPort if required
 move.l xxp_IText(a5),a0    ;a0 = text
 move.l a0,a1
 moveq #-1,d5
.count:
 addq.l #1,d5               ;* d5 = number of characters
 tst.b (a1)+
 bne .count
 move.l xxp_WPort(a5),a1    ;a1 = WPort
 move.w xxp_Tspc(a5),rp_TxSpacing(a1)
 sub.w #te_SIZEOF,a7
 move.l a7,a2
 move.l xxp_gfxb(a4),a6
 move.l d5,d0
 jsr _LVOTextExtent(a6)     ;get TextExtent
 moveq #0,d4
 move.w te_Width(a7),d4     ;* d4 = te_Width
 bpl.s .lhs                 ;  (i.e. the nominal text width)
 neg.w d4
 neg.w te_Extent+4(a7)
 neg.w te_Extent(a7)
.lhs:
 move.w te_Extent(a7),d0
 ble.s .xmin
 moveq #0,d0
.xmin:
 neg.w d0
 move.w d0,xxp_xmin(a5)     ;* xxp_xmin = xmin (+ve), or 0 if xmin > 0
 move.w te_Extent+4(a7),d0  ;  (i.e. xxp_xmin = underlap)
 addq.w #1,d0
 sub.w d4,d0
 bpl.s .xmax
 moveq #0,d0
.xmax:
 move.w d0,xxp_xmax(a5)     ;* xxp_xmax = xmax+1-d4, or 0 if d4 > xmax+1
 add.w #te_SIZEOF,a7        ;  (i.e. xxp_xmax = overlap)
 movem.l (a7)+,d0-d1/a0-a2/a6
 rts

*>>>> A5=IntuiText:  set D6 = height of text  D7 = baseline
TLTvert:
 movem.l a0-a1,-(a7)       ;save all regs except result in D6,D7
 bsr TLWfont               ;ensure font attached
 move.l xxp_FSuite(a4),a0  ;look up FSuite entry
 move.w xxp_Fnum(a5),d7
 mulu #xxp_fsiz,d7
 move.l xxp_plain(a0,d7.l),a1 ;a1 = font
 moveq #0,d6
 moveq #0,d7
 move.w tf_YSize(a1),d6    ;* d6 = YSize
 move.w tf_Baseline(a1),d7 ;* d7 = Baseline
 movem.l (a7)+,a0-a1
 rts

*>>>> put font data in TextAttr   A0=FontName, D0=number D1=height
TLGetfont:
 bsr TLFsub               ;removes old version (if any)
 movem.l d0/a0-a1,-(a7)   ;saves all
 move.l xxp_FSuite(a4),a1 ;a1 = FSuite entry
 mulu #xxp_fsiz,d0
 add.l d0,a1
 clr.w ta_Style(a1)       ;ta_Style,ta_Flags = 0
 move.w d1,ta_YSize(a1)   ;put height to ta_YSize
 addq.l #8,a1             ;point to name (ta_SIZEOF = 8)
 move.l a1,-8(a1)         ;put name back at ta_Name
.tfr:
 move.b (a0)+,(a1)+       ;put name (e.g. Topaz.font)
 bne .tfr
 movem.l (a7)+,d0/a0-a1
 rts

*>>>> call TLNewfont for any xxp_wsuw window a5
TLAnyfont:
 move.l xxp_AcWind(a4),-(a7)
 move.l a5,xxp_AcWind(a4)
 bsr.s TLNewfont
 move.l xxp_AcWind(a4),a5
 move.l (a7)+,xxp_AcWind(a4)
 tst.l d0                  ;EQ if bad
 rts

*>>>> attach font to popped window  D0=num D1=styl D2: 0=window 1=req 2=help
TLNewfont:
 movem.l d0/a0/a5,-(a7)    ;save all except result in D0
 move.l xxp_FSuite(a4),a0
 mulu #xxp_fsiz,d0         ;* point a0 to FSuite entry
 add.l d0,a0
 tst.l xxp_plain(a0)       ;go if plain open
 bne.s .opln
 bsr TLOfont               ;open the font
 beq .bad
.opln:
 btst #2,d1                ;(not super/subscript if underline)
 bne.s .wide
 btst #3,d1                ;to .supr if super/subscript
 beq.s .subt
 btst #4,d1
 bne.s .wide               ;(but not if both)
 bra.s .supr
.subt:
 btst #4,d1
 beq.s .wide
.supr:
 tst.b d1                  ;to wide if sup/sub + wide
 bmi.s .wide
 tst.l xxp_ital(a0)        ;go if half height open
 bne.s .open
 move.l (a7),d0            ;d0 = font num
 bsr TLSuper               ;open half height font
 beq.s .bad
 bra.s .open
.wide:
 tst.b d1                  ;go if not double width
 bpl.s .open
 tst.l xxp_bold(a0)        ;go if double width open
 bne.s .open
 move.l (a7),d0            ;d0 = font num
 bsr TLWide                ;open double width
 beq.s .bad
.open:                     ;* font is open
 move.l (a7),d0            ;d0 = font num
 move.l xxp_AcWind(a4),a5  ;a5 = active window
 cmp.w #1,d2               ;test input d2
 beq.s .req                ;go if req
 bcc.s .hlp                ;go if help
 move.w d1,xxp_Fsty(a5)    ;* window: set Fsty
 tst.w xxp_Attc(a5)
 bmi.s .set                ;force attach if attach undefined
 cmp.w xxp_Fnum(a5),d0
 beq.s .good               ;done if attached, & same Fnum
.set:
 move.w d0,xxp_Fnum(a5)    ;note new Fnum
 move.w #-1,xxp_Attc(a5)   ;force attach font next print
 bra.s .good
.req:                      ;* requester
 move.w d0,xxp_RFont(a5)
 move.w d1,xxp_RFsty(a5)
 bra.s .good
.hlp:                      ;* help
 move.w d0,xxp_HFont(a5)
 move.w d1,xxp_HFsty(a5)
.good:                     ;report success
 moveq #-1,d0
 bra.s .done
.bad:
 moveq #0,d0
.done:
 move.l d0,(a7)            ;result in d0:  EQ=bad  MI=good
 movem.l (a7)+,d0/a0/a5
 rts

*>>>> open a font at a0 in xxp_FSuite
TLOfont:
 movem.l d0-d1/a0-a1/a6,-(a7) ;save all
 clr.l xxp_errn(a4)
 move.l xxp_sysb(a4),a6
 lea .libn,a1
 moveq #36,d0
 jsr _LVOOpenLibrary(a6)   ;open diskfont.library
 tst.l d0
 beq.s .bad1               ;go if can't open diskfont.library
 move.l d0,a6
 move.l 8(a7),a0           ;open diskfont
 jsr _LVOOpenDiskFont(a6)  ;open font
 move.l d0,-(a7)           ;save result of OpenDiskFont
 move.l a6,a1
 move.l xxp_sysb(a4),a6
 jsr _LVOCloseLibrary(a6)  ;close diskfont.library
 move.l (a7)+,d0           ;d0 = diskfont
 beq.s .bad2               ;bad if open failed
 move.l 8(a7),a0           ;a0 = FSuite entry
 move.l d0,xxp_plain(a0)   ;save font as opened
 moveq #-1,d0
 bra.s .done
.bad1:                     ;bad 1: can't open diskfont.library
 moveq #8,d0
 bra.s .bad
.bad2:                     ;bad 2: can't open font
 moveq #10,d0
.bad:
 move.l d0,xxp_errn(a4)
 moveq #0,d0
.done:
 movem.l (a7)+,d0-d1/a0-a1/a6 ;EQ=bad, NE=good
 rts

.libn: dc.b 'diskfont.library',0
 ds.w 0

*>>>> attach Font/Fontstyle to a5's xxp_WPort if required
TLWfont:
 move.l d7,-(a7)           ;save all
 move.w xxp_Fsty(a5),d7    ;already attached?
 cmp.w xxp_Attc(a5),d7     ;yes, return quickly
 beq .done

 movem.l d0-d1/a0-a1/a6,-(a7)
 move.l xxp_gfxb(a4),a6

 move.l xxp_FSuite(a4),a1  ;look up the font in FSuite
 move.w xxp_Fnum(a5),d0
 move.w d0,d1
 mulu #xxp_fsiz,d1
 move.l xxp_plain(a1,d1.l),a0 ;a0 = the font

 btst #2,d7
 bne.s .dble               ;(not super or sub if underline)
 btst #3,d7
 beq.s .supx               ;go if not superscript
 btst #4,d7
 beq.s .supr
 bra.s .dble               ;(not super or sub if both set)
.supx:
 btst #4,d7
 beq.s .dble
.supr:                     ;if super/subscript, use half-height font
 tst.b d7
 bpl.s .supn               ;go unless sup/sub + wide
 tst.l xxp_boit(a1,d1.l)
 bne.s .boit               ;go if sup/sub + wide already opened
 tst.l xxp_bold(a1,d1.l)
 bne.s .supn               ;if wide open, but sup/sub not, open failed
 bsr TLWide                ;open wide, sup/sub + wide
 tst.l xxp_boit(a1,d1.l)
 beq.s .supn               ;go if open sup/sub + wide failed
.boit:
 move.l xxp_boit(a1,d1.l),a0 ;get sup/sub + wide font
 bra.s .sngl
.supn:
 tst.l xxp_ital(a1,d1.l)
 bne.s .supp
 bsr TLSuper               ;open half height font if required
 beq.s .sngl
.supp:
 move.l xxp_ital(a1,d1.l),a0
 bra.s .sngl
.dble:                     ;if double, use double width font
 tst.b d7
 bpl.s .sngl
 tst.l xxp_bold(a1,d1.l)
 bne.s .dblp
 bsr TLWide                ;open double width font if required
 beq.s .sngl
.dblp:
 move.l xxp_bold(a1,d1.l),a0

.sngl:
 move.l xxp_WPort(a5),a1
 jsr _LVOSetFont(a6)       ;set the font to the WPort
 move.w d7,xxp_Attc(a5)    ;set the style in Attc
 beq.s .good               ;go if style is plain

 moveq #0,d0
 move.w d7,d0
 and.w #3,d0
 lsl.w #1,d0
 move.l d0,d1
 move.l xxp_WPort(a5),a1
 jsr _LVOSetSoftStyle(a6)  ;set the soft style of the attached font

.good:
 movem.l (a7)+,d0-d1/a0-a1/a6

.done:
 move.l (a7)+,d7
 rts

*>>>> attach pens & drmode to a5's xxp_WPort if required
TLWpens:
 move.l a1,-(a7)            ;save all
 move.l d0,-(a7)
 move.l xxp_WPort(a5),a1    ;a1 = WPort
 move.w rp_FgPen(a1),d0
 cmp.w xxp_FrontPen(a5),d0
 bne.s .cont                ;continue if APen/BPen different
 move.b rp_DrawMode(a1),d0  ;compare drawmode
 cmp.b xxp_DrawMode(a5),d0
 beq.s .done                ;quit quickly if pens, drawmode already set

.cont:
 movem.l d1/a0/a6,-(a7)
 move.l xxp_gfxb(a4),a6
 moveq #0,d0
 move.b xxp_FrontPen(a5),d0
 cmp.b rp_FgPen(a1),d0
 beq.s .penb                ;go if PenA same
 jsr _LVOSetAPen(a6)        ;else SetAPen
 move.l xxp_WPort(a5),a1

.penb:
 moveq #0,d0
 move.b xxp_BackPen(a5),d0
 cmp.b rp_BgPen(a1),d0
 beq.s .drmd                ;go if PenB same
 jsr _LVOSetBPen(a6)        ;else SetBPen
 move.l xxp_WPort(a5),a1

.drmd:
 moveq #0,d0
 move.b xxp_DrawMode(a5),d0
 cmp.b rp_DrawMode(a1),d0
 beq.s .good                ;go if DrawMode same
 jsr _LVOSetDrMd(a6)        ;else SetDrMd

.good:
 movem.l (a7)+,d1/a0/a6

.done:
 move.l (a7)+,d0
 move.l (a7)+,a1
 rts

*>>>> close font no. d0 (all styles) - ok if never opened
TLFsub:
 movem.l d0-d2/a0-a6,-(a7) ;save all
 move.l xxp_gfxb(a4),a6
 move.l xxp_WSuite(a4),a0  ;check not used in window suite
 moveq #11,d1
.chek:
 tst.l xxp_Window(a0)      ;go if window not open
 beq.s .nxck
 cmp.w xxp_Fnum(a0),d0     ;main window using?
 bne.s .req
 clr.w xxp_Fnum(a0)        ;yes, Topaz/8 it
 move.w #-1,xxp_Attc(a0)
.req:
 cmp.w xxp_RFont(a0),d0    ;req window using?
 bne.s .hlp
 clr.w xxp_RFont(a0)       ;yes, Topaz/8 it
.hlp:
 cmp.w xxp_HFont(a0),d0    ;help window using?
 bne.s .nxck
 clr.w xxp_HFont(a0)       ;yes, Topaz/8 it
.nxck:
 add.l #xxp_siz2,a0        ;to next window
 dbra d1,.chek
 move.l xxp_FSuite(a4),a3  ;point to FSuite entry
 mulu #xxp_fsiz,d0
 add.l d0,a3
 clr.l (a3)                ;clear 1st long to show doesn't exist
 move.l xxp_plain(a3),d0   ;get font address
 beq.s .done               ;go if none
 move.l d0,a1
 jsr _LVOCloseFont(a6)     ;close it
 clr.l xxp_plain(a3)       ;flag closed
 move.l xxp_bold(a3),d0    ;was double width opened?
 beq.s .ital               ;no, go
 move.l d0,a1
 jsr _LVOCloseFont(a6)     ;yes, close it
 clr.l xxp_bold(a3)        ;flag closed
.ital:
 move.l xxp_ital(a3),d0    ;was superscript opened?
 beq.s .boit               ;no, go
 move.l d0,a1
 jsr _LVOCloseFont(a6)     ;yes, close it
 clr.l xxp_ital(a3)        ;flag closed
.boit:
 move.l xxp_boit(a3),d0    ;was wide/supr opened?
 beq.s .done               ;no, go
 move.l d0,a1
 jsr _LVOCloseFont(a6)     ;yes, close it
 clr.l xxp_boit(a3)        ;flag closed
.done:
 movem.l (a7)+,d0-d2/a0-a6
 rts

*>>>> select and load font D0
TLAslfont:
 movem.l d1-d7/a0-a6,-(a7) ;save all except d0
 clr.l xxp_errn(a4)
 move.l d0,d7              ;save font num
 move.l xxp_AcWind(a4),a5  ;a5=WSuite ptr
 move.l xxp_aslb(a4),a6
 sub.l #4,a7               ;null taglist to AllocAslRequest
 move.l a7,a0
 move.l #TAG_DONE,(a0)
 moveq #ASL_FontRequest,d0
 jsr _LVOAllocAslRequest(a6)
 add.l #4,a7
 tst.l d0
 beq .bad                  ;bad if can't allocate file request
 move.l d0,a0              ;FontRequester structure to A0 for AslRequest
 move.l d0,a3              ;a3=FontRequester structure
 sub.l #8*8+4,a7           ;room for 8 tags
 move.l a7,a1
 move.l #ASL_Hail,(a1)+      ; 1 prompt
 move.l #.hail,(a1)+
 move.l #ASL_Window,(a1)+    ; 2 window
 move.l xxp_Window(a5),(a1)+
 move.l #ASL_LeftEdge,(a1)+  ; 3 left edge
 move.l #4,(a1)+
 move.l #ASL_TopEdge,(a1)+   ; 4 top edge
 move.l #11,(a1)+
 move.l #ASL_Width,(a1)+     ; 5 width
 move.l #320,(a1)+
 move.l #ASL_Height,(a1)+    ; 6 height
 move.l xxp_Height(a4),d0
 sub.w #22,d0
 move.l d0,(a1)+
 move.l #ASL_MaxHeight,(a1)+ ; 7 MaxHeight
 move.l xxp_ehgt(a4),(a1)+
 move.l #TAG_DONE,(a1)
 move.l a7,a1 ;point to tags
 clr.l d0
 jsr _LVOAslRequest(a6)
 add.l #8*8+4,a7           ;discard tags
 tst.l d0
 beq.s .canc               ;go if cancel selected
 move.l fo_Attr+ta_Name(a3),a0  ;a0=font name
 move.w fo_Attr+ta_YSize(a3),d1 ;d1=ysize
 move.l d7,d0              ;d0=suite num
 bsr TLGetfont             ;put in suite (& close old version if exists)
 moveq #-1,d0              ;signal good
 bra.s .free
.bad:
 addq.l #2,xxp_errn(a4)    ;d0=0, errn=2 if can't open requester
 moveq #0,d0
 bra.s .quit
.canc:
 moveq #0,d0               ;d0=0, errn=0 if cancel
.free:
 move.l d0,-(a7)
 move.l a3,a0
 move.l xxp_aslb(a4),a6    ;free the AslRequest
 jsr _LVOFreeAslRequest(a6)
 move.l (a7)+,d0
.quit:
 movem.l (a7)+,d1-d7/a0-a6
 rts

.hail: dc.b 'Select a Font',0 ;hail for requester
 ds.w 0

*>>>> do file requester d0=strnum of hail a0=file a1=dir  d1= -1save +1load
TLAslfile:
 movem.l d1-d7/a0-a6,-(a7) ;saves all except D0
 movem.l d0-d1/a0-a1,-(a7)
 clr.l xxp_errn(a4)
 move.l xxp_aslb(a4),a6
 jsr _LVOAllocFileRequest(a6)
 move.l d0,d7        ;request struct to d7
 movem.l (a7)+,d0-d1/a0-a1
 beq .quit           ;bad if can't allocate file request
 subq.l #8,a7        ;OKText to stack
 move.l a7,d6        ;d6=OKText
 clr.b 4(a7)
 move.l #'Save',(a7)
 cmp.w #-1,d1
 beq.s .ldsv
 move.l #'Load',(a7)
.ldsv:
 move.l a0,a2         ;point a2 to hail
 bsr TLStra0
 exg a0,a2
 sub.l #10*8+4,a7     ;room for 10 tags
 move.l a7,a3
 move.l #ASL_Hail,(a3)+      ; 1
 move.l a2,(a3)+
 move.l #ASL_File,(a3)+      ; 2
 move.l a0,(a3)+
 move.l #ASL_Dir,(a3)+       ; 3
 move.l a1,(a3)+
 tst.l xxp_Screen(a4)        ;go if no screen
 beq.s .scrn
 tst.w xxp_Public(a4)        ;go if never initialised
 ble.s .scrn
 tst.w xxp_Active(a4)        ;go if no window active
 bmi.s .scrn
 move.l xxp_AcWind(a4),a5    ;attach asl to active window
 move.l #ASL_Window,(a3)+    ; 4
 move.l xxp_Window(a5),(a3)+
 move.l #ASL_Width,(a3)+     ; 5
 move.l #320,(a3)+
 move.l #ASL_Height,(a3)+    ; 6
 move.l xxp_Height(a4),d0
 sub.w #22,d0
 move.l d0,(a3)+
 move.l #ASL_TopEdge,(a3)+   ; 7
 move.l #11,(a3)+
 move.l #ASL_LeftEdge,(a3)+  ; 8
 move.l #4,(a3)+
.scrn:
 move.l #ASL_OKText,(a3)+    ; 9
 move.l d6,(a3)+
 cmp.w #-1,d1
 bne.s .tags
 move.l #ASL_FuncFlags,(a3)+ ; 10 (only send if save)
 move.l #FILF_SAVE,(a3)+
.tags:
 move.l #TAG_DONE,(a3)
 movem.l a0-a1,-(a7)
 move.l d7,a0
 move.l a7,a1             ;point to tags
 jsr _LVOAslRequest(a6)
 movem.l (a7)+,a0-a1      ;a0=file a1=dir
 add.l #10*8+4+8,a7       ;discard tags,OKText
 tst.l d0
 beq .canc
 move.l d7,a6             ;a6=FileRequester
 move.l rf_Dir(a6),a2     ;a2=new dir - put in direct & buff
 move.l a4,a3             ;point a3 to buff
 move.l a3,d1             ;d1=buff for AddPart
.infil:
 move.b (a2),(a1)+
 move.b (a2)+,(a3)+
 bne .infil
 move.l rf_File(a6),a2    ;a2=new file - put in file
 move.l a0,d2             ;d2=file part for AddPart
.fpart:
 move.b (a2)+,(a0)+
 bne .fpart
 move.l xxp_dosb(a4),a6
 move.w #200,d3
 jsr _LVOAddPart(a6)      ;path in buff (AddPart can't fail)
 bsr .free                ;free file request
 moveq #-1,d0             ;signal good
 movem.l (a7)+,d1-d7/a0-a6 ;NE if good
 rts
.canc:
 bsr .free                 ;cancel: close file request
 moveq #0,d0
 movem.l (a7)+,d1-d7/a0-a6 ;D0=0, errn=0 if cancel
 rts
.quit:
 addq.l #2,xxp_errn(a4)
 moveq #0,d0
 movem.l (a7)+,d1-d7/a0-a6 ;D0=0, errn=2 if can't open requester
 rts
.free:                     ;** free file request
 move.l xxp_aslb(a4),a6
 move.l d7,a0
 jsr _LVOFreeFileRequest(a6)
 rts

*>>>> draw a bevelled box  posn d0,d1  size d2,d3

; If bit 31 of D1 set, rastport in A0 (else, use AcWind)
; If bit 31 of D0 set, recessed
; If bit 30 of D0 set, unbevelled
; If bit 29 of D0 set, D4,D5 contain the pen (D4=dark, D5=light)

TLReqbev:
 clr.l -(a7)               ;A7 + 60,62 = 0
 movem.l d0-d7/a0-a6,-(a7) ;save all regs
 clr.l xxp_errn(a4)

 tst.l d1                  ;go if writing to window
 bpl.s .wind

 bclr #31,d1               ;* writing to rastport...  when 4(a7) is MI
 move.l a0,a2              ;a2 = rastport
 bra.s .both

.wind:                     ;* writing to window...    when 4(a7) is PL
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a2   ;a2 = window's rastport
 move.w xxp_PWidth(a5),d6
 sub.w d0,d6               ;d6 = max allowable width
 bmi .done                 ;done if off rhs
 cmp.w d2,d6
 bcc.s .wdok
 move.w d6,d2              ;trim if too wide, & set 60(a7)<>
 subq.w #1,60(a7)
.wdok:
 move.w xxp_PHeight(a5),d6 ;d6 = max allowable height
 sub.w d1,d6               ;done if off bot
 bmi .done
 cmp.w d3,d6
 bcc.s .htok
 move.w d6,d3              ;trim if too high, & set 62(a7)<>
 subq.w #1,62(a7)
.htok:
 add.w xxp_LeftEdge(a5),d0 ;offset d0,d1 by left & top borders
 add.w xxp_TopEdge(a5),d1

.both:                     ;d2,d3 = rhs,bot pixel posns
 add.w d0,d2
 subq.w #1,d2
 add.w d1,d3
 subq.w #1,d3

 btst #29,d0               ;if D0 bit 29 unset, pens 1,2
 bne.s .clok
 moveq #1,d4               ;d4 = dark pen
 moveq #2,d5               ;d5 = light pen
.clok:
 tst.l d0                  ;if D0 bit 30 set, recessed -> swap pens
 bpl.s .nrec
 exg d4,d5
.nrec:
 btst #30,d0               ;if bit 30 set, box -> both pens are dark pen
 beq.s .nbox
 move.l d4,d5
.nbox:

 and.l #$FFFF,d0
 move.l d0,d6              ;d6 = lhs   d2 = rhs
 move.l d1,d7              ;d7 = top   d3 = bot

 move.l xxp_gfxb(a4),a6    ;set light pen, jam2
 moveq #0,d0
 move.b d5,d0
 move.l a2,a1
 jsr _LVOSetAPen(a6)
 move.l a2,a1
 moveq #RP_JAM2,d0
 jsr _LVOSetDrMd(a6)

 cmp.w d2,d6               ;go if only 1 pixel either way
 beq.s .box1
 cmp.w d3,d7
 beq.s .box1

 move.l d6,d0              ;move to 1 pixel SE from top left
 addq.l #1,d0
 move.l d7,d1
 addq.l #1,d1
 move.l a2,a1
 jsr _LVOMove(a6)
 move.l d6,d0              ;point to 1 pixel NE from bot left
 addq.l #1,d0
 move.l d3,d1
 tst.w 62(a7)              ;if bot trimmed, 1 pixel E
 bne.s .box0
 subq.l #1,d1
.box0:
 move.l a2,a1
 tst.w 4(a7)               ;bad if window & resized
 bmi.s .do0
 bsr TLWCheck
 bne .bad
.do0:
 jsr _LVODraw(a6)          ;* draw left inner line

.box1:                     ;move to bottom left
 move.l d6,d0
 move.l d3,d1
 move.l a2,a1
 jsr _LVOMove(a6)          ;* move to bottom left

 cmp.w d3,d7               ;go if height = 1 (when also at top left)
 beq.s .box2

 move.l d6,d0              ;point to top left
 move.l d7,d1
 move.l a2,a1
 tst.w 4(a7)               ;bad if window & resized
 bmi.s .do1
 bsr TLWCheck
 bne .bad
.do1:
 jsr _LVODraw(a6)          ;* draw from bottom left to top left

 cmp.w d2,d6               ;quit if width = 1
 beq .done

.box2:                     ;point to 1 pixel W of top right
 move.l d2,d0
 tst.w 60(a7)
 bmi.s .box3               ;top right if trimmed horz
 cmp.w d3,d7
 beq.s .box3               ;top right if height = 1
 subq.w #1,d0
.box3:
 move.l d7,d1
 move.l a2,a1
 tst.w 4(a7)               ; bad if window & resized
 bmi.s .do2
 bsr TLWCheck
 bne .bad
.do2:
 jsr _LVODraw(a6)          ;* draw from top left to top right

 cmp.w d3,d7               ;quit if height = 1
 beq .done

 moveq #0,d0               ;* set dark pen
 move.b d4,d0
 move.l a2,a1
 jsr _LVOSetAPen(a6)

 tst.w 60(a7)              ;if trimmed horz, move to bot right & skip
 beq.s .cnt1
 move.l d2,d0
 move.l d3,d1
 move.l a2,a1
 jsr _LVOMove(a6)
 bra.s .pik1

.cnt1:                     ;point to top right
 move.l d2,d0
 move.l d7,d1
 move.l a2,a1
 jsr _LVOMove(a6)          ;* move to top right

 move.l d2,d0              ;point to bot right
 move.l d3,d1
 move.l a2,a1
 tst.w 4(a7)               ;bad if window & resized
 bmi.s .do3
 bsr TLWCheck
 bne.s .bad
.do3:
 jsr _LVODraw(a6)          ;* draw rhs

.pik1:                     ;go if trimmed vert
 tst.w 62(a7)
 bne.s .pik2

 move.l d6,d0              ;point 1 pixel E of bottom left
 addq.l #1,d0
 move.l d3,d1
 move.l a2,a1
 tst.w 4(a7)               ;bad if window resized
 bmi.s .do4
 bsr TLWCheck
 bne.s .bad
.do4:
 jsr _LVODraw(a6)          ;* draw bottom line

.pik2:
 tst.w 60(a7)              ;done if trimmed horz
 bne.s .done

 move.l d2,d0              ;move to 1 pixel SW of top right
 subq.l #1,d0
 move.l d7,d1
 addq.l #1,d1
 move.l a2,a1
 jsr _LVOMove(a6)          ;* move to top of right inside line

 move.l d2,d0              ;point to 1 pixel NW of bot right
 subq.l #1,d0
 move.l d3,d1
 subq.w #1,d1
 move.l a2,a1
 tst.w 4(a7)               ;bad if window & resized
 bmi.s .do6
 bsr TLWCheck
 bne.s .bad
.do6:
 jsr _LVODraw(a6)          ;* draw right inside line
 bra.s .done

.bad:                      ;bad: window resized
 move.w #35,xxp_errn+2(a4)

.done:
 movem.l (a7)+,d0-d7/a0-a6
 addq.l #4,a7
 tst.l xxp_errn(a4)        ;EQ, xxp_errn<>0 if bad
 eori.w #-1,CCR
 rts

*>>>> draw an area  posn D0,D1  size D2,D3    EQ if resized

; if bit 29 of D0 set, colour in D4   (else xxp_Backpen window, 0 rastport)
; if bit 31 of D1 set, rastport in A0 (else is AcWind)

TLReqarea:
 movem.l d0-d5/a0-a1/a5-a6,-(a7) ;saves all regs
 clr.l xxp_errn(a4)

 tst.l d1                  ;go if drawing to window
 bpl.s .wind

 bclr #31,d1               ;* drawing to rastport
 move.l a0,a1
 btst #29,d0
 bne.s .both
 moveq #0,d4               ;pen = 0 if not specified
 bra.s .both

.wind:                     ;* drawing to window
 move.l xxp_AcWind(a4),a5
 move.w xxp_PWidth(a5),d5  ;d5 = max allowable width
 sub.w d0,d5
 bcs.s .done               ;quit if off rhs
 cmp.w d2,d5
 bcc.s .xwok
 move.w d5,d2              ;trim if width > max allowable
.xwok:
 move.w xxp_PHeight(a5),d5 ;d5 = max allowable height
 sub.w d1,d5
 bcs.s .done               ;quit if off bottom
 cmp.w d3,d5
 bcc.s .yhok
 move.w d5,d3              ;trim if height > max allowable
.yhok:
 add.w xxp_LeftEdge(a5),d0 ;make d0,d1 rel to window border
 add.w xxp_TopEdge(a5),d1
 move.l xxp_WPort(a5),a1
 btst #29,d0
 bne.s .both
 move.b xxp_BackPen(a5),d4 ;pen = back pen if not specified

.both:                     ;prepare d2,d3 for rectfill
 add.w d0,d2
 subq.w #1,d2
 add.w d1,d3
 subq.w #1,d3

 move.l xxp_gfxb(a4),a6    ;set pen A to D4
 movem.l d0-d1/a1,-(a7)
 moveq #0,d0
 move.b d4,d0
 jsr _LVOSetAPen(a6)
 movem.l (a7)+,d0-d1/a1

 tst.l 4(a7)               ;if window, bad if resized
 bmi.s .do
 bsr TLWCheck
 bne.s .bad
.do
 jsr _LVORectFill(a6)      ;draw the area
 bra.s .done

.bad:
 move.w #35,xxp_errn+2(a4)

.done:
 movem.l (a7)+,d0-d5/a0-a1/a5-a6
 tst.l xxp_errn(a4)
 eori.w #1,CCR            ;xxp_errn<>0, EQ if bad
 rts

*>>>> clear Window (calls TLWupdate)
TLReqcls:
 movem.l d0-d7/a0-a6,-(a7)   ;saves all regs
 move.l xxp_AcWind(a4),a5
 bsr TLWupdate
 moveq #0,d0
 moveq #0,d1
 move.w xxp_PWidth(a5),d2
 move.w xxp_PHeight(a5),d3
 moveq #0,d4
 bset #29,d0
 bsr TLReqarea
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> make window full size
TLReqfull:
 movem.l d0-d3/a0-a1/a5-a6,-(a7) ;saves all regs
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 bsr TLWfront
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 move.l xxp_Window(a5),a0
 move.w wd_MaxWidth(a0),d2
 move.w wd_MaxHeight(a0),d3
 jsr _LVOChangeWindowBox(a6)     ;request change to full size
.wait:
 move.l xxp_gfxb(a4),a6
 jsr _LVOWaitTOF(a6)             ;wait until change takes effect
 move.l xxp_Window(a5),a0
 move.w wd_Width(a0),d0
 cmp.w wd_MaxWidth(a0),d0
 bne .wait
 move.w wd_Height(a0),d0
 cmp.w wd_MaxHeight(a0),d0
 bne .wait
 bsr TLWupdate
 movem.l (a7)+,d0-d3/a0-a1/a5-a6
 rts

*>>>> update window printable area
TLWupdate:
 movem.l d0/a0/a5,-(a7)      ;saves all regs
 move.l xxp_AcWind(a4),a5    ;a5=window in WSuite
 move.l xxp_Window(a5),a0    ;a0=window
 move.l wd_Width(a0),xxp_Wcheck(a5) ;save init window dims
 moveq #0,d0                 ;update xxp_PWidth,Height
 move.b wd_BorderLeft(a0),d0
 add.b wd_BorderRight(a0),d0
 neg.w d0
 add.w xxp_Wcheck(a5),d0
 move.w d0,xxp_PWidth(a5)
 moveq #0,d0
 move.b wd_BorderTop(a0),d0
 add.b wd_BorderBottom(a0),d0
 neg.w d0
 add.w xxp_Wcheck+2(a5),d0
 move.w d0,xxp_PHeight(a5)
.done:
 movem.l (a7)+,d0/a0/a5
 rts

*>>>> set d0<>0 if window size has changed since TLWupdate called
TLWcheck:
 movem.l a0/a5,-(a7)       ;saves all exc d0
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 move.l wd_Width(a0),d0
 sub.l xxp_Wcheck(a5),d0   ;D0=diff in window size
 movem.l (a7)+,a0/a5
 rts

*>>>> Internal call of TLWcheck
TLWCheck:
 movem.l d0-d1,-(a7)
 bsr TLWcheck
 tst.l d0                  ;NE if size changed
 movem.l (a7)+,d0-d1
 rts

*>>>> set xxp_Pop for requesters, & call TLReqint (part xxp_wsuw in a5)
TLReqredi:
 movem.l d0-d1/a0,-(a7)    ;saves all

 move.l #$03020100,xxp_prfp(a4) ;defaults to prfp for custom requesters
 clr.l xxp_prfp+4(a4)
 move.w xxp_Active(a4),xxp_Pop(a4) ;set xxp_Pop

 move.b xxp_prfp+1(a4),xxp_FrontPen(a5) ;fix data in dummy wsuw
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 move.b #RP_JAM2,xxp_DrawMode(a5)       ;jam2
 clr.l xxp_LeftEdge(a5)                 ;posn 0,0

 move.w #10,xxp_Fnum(a5)   ;set prefs fnum,fsty,tspc
 move.l xxp_pref(a4),a0    ;(will be over-ridden if pop window)
 clr.w xxp_Fsty(a5)
 move.b xxp_ysty(a0),xxp_Fsty+1(a5)
 clr.w xxp_Tspc(a5)
 move.b xxp_yspc(a0),xxp_Tspc+1(a5)
 move.l xxp_FSuite(a4),a0
 tst.l xxp_fsiz*10(a0)
 bne.s .f0
 clr.w xxp_Fnum(a5)        ;(or Topaz/8 if no font 10)
 clr.w xxp_Fsty(a5)
 clr.w xxp_Tspc(a5)
.f0:

 move.w #-1,xxp_Attc(a5)
 move.w xxp_Pop(a4),d0     ;get pop window
 bmi.s .fsty               ;go if none
 mulu #xxp_siz2,d0         ;a0=pop window
 move.l xxp_WSuite(a4),a0
 add.l d0,a0
 move.w xxp_RTspc(a0),xxp_Tspc(a5)  ;but if pop window, use its fnum &c
 move.w xxp_RFsty(a0),xxp_Fsty(a5)
 move.w xxp_RFont(a0),xxp_Fnum(a5)
.fsty:

 move.l a4,xxp_IText(a5)   ;text from buff

 move.l xxp_ERport(a4),xxp_WPort(a5)  ;use xxp_ERport as sub for xxp_WPort
 movem.l (a7)+,d0-d1/a0
 rts

*>>>> choose from D1 choices: D0=str num of header, then D1 choices
; (if D1=0, 1 choice only, in buff, D0 ignored)
TLReqchoose:

 move.l xxp_butx(a4),-(a7) ;save button data
 move.l xxp_buty(a4),-(a7)
 move.l xxp_butw(a4),-(a7)
 move.l xxp_buth(a4),-(a7)
 move.l xxp_btdx(a4),-(a7)
 move.l xxp_btdy(a4),-(a7)
 move.l xxp_butk(a4),-(a7)
 move.l xxp_butl(a4),-(a7)

 movem.l d0-d7/a0-a6,-(a7) ;save all except result in D0
 move.l a7,xxp_Stak(a4)
 move.l xxp_strg(a4),-(a7) ;save global strings
 movem.l d0-d1,-(a7)       ;save input d0,1
 sub.w #100,a7             ;room for dummy strings if D1=-1
 sub.w #xxp_WPort+4,a7     ;room for dummy part xxp_Wsuw

 move.l a7,a5              ;a5 points to dummy IntuiText
 bsr TLReqredi             ;set pop window
 beq .bad                  ;bad if can't - unlikely

 move.l xxp_pref(a4),a0    ;get prefs data
 move.l xxp_ychs(a0),xxp_prfp(a4)
 move.l xxp_ychs+4(a0),xxp_prfp+4(a4)

 tst.w d1                  ;if D1=-0, make dummy strings in stack
 bne.s .rcyc
 move.l a7,a1
 add.w #xxp_WPort+4,a1
 move.l a1,xxp_strg(a4)
 clr.b (a1)+
 lea .ack,a0
.dum0:
 move.b (a0)+,(a1)+
 bne .dum0
 move.l a4,a0
 clr.b 76(a0)
.dum1:
 move.b (a0)+,(a1)+
 bne .dum1
 move.l #1,xxp_WPort+104(a7) ;& as if input was 1,1 in dummy strings
 move.l #1,xxp_WPort+108(a7)

.rcyc:                     ;* here to try if will fit
 move.l xxp_WPort+104(a7),d0
 move.l xxp_WPort+108(a7),d1 ;retrieve input d0,d1

 bsr TLStra0               ;get button dimensions
 move.l a0,a1
 lea .fns,a0
 move.l xxp_AcWind(a4),-(a7)
 move.l a5,xxp_AcWind(a4)
 bsr TLButstr
 move.l (a7)+,xxp_AcWind(a4)

 move.l a1,a0

 move.l #1,xxp_butk(a4)    ;complete button data
 move.l d1,xxp_butl(a4)
 move.l #2,xxp_butx(a4)
 move.l xxp_buth(a4),xxp_buty(a4)
 addq.l #1,xxp_buty(a4)
 clr.l xxp_btdx(a4)
 move.l xxp_buth(a4),xxp_btdy(a4)
 moveq #0,d3
 move.b xxp_prfp+3(a4),d3  ;width + pref horz
 add.l d3,xxp_butx(a4)
 move.b xxp_prfp+4(a4),d3  ;dy + pref vert
 add.l d3,xxp_btdy(a4)

 move.l d1,d3              ;set D2 = wdth of widest of header-butw, strings
 moveq #0,d2
 move.l a1,xxp_IText(a5)
 bsr TLTszdo
 sub.l xxp_butw(a4),d4
 bcc.s .widp
 bra.s .widc
.wide:
 move.l a1,xxp_IText(a5)
 bsr TLTszdo
 cmp.w d4,d2
 bcc.s .widc
.widp:
 move.w d4,d2
.widc:
 tst.b (a1)+
 bne .widc
 dbra d3,.wide
 add.l xxp_butx(a4),d2     ;add button offset
 add.l xxp_butw(a4),d2     ;add button width
 addq.l #6,d2              ;add (button) - 2 - (text) - 4 - (rhs)

 cmp.l xxp_Width(a4),d2    ;go unless too wide
 ble.s .wdok
 tst.b xxp_prfp+3(a4)
 beq.s .wfx1
 subq.b #1,xxp_prfp+3(a4)      ;if horz gap <> 0, dec horz gap & retry
 bra .rcyc
.wfx1:
 tst.w xxp_Tspc(a5)        ;if Tspc <> 0, dec Tspc & retry
 beq.s .wfx2
 subq.w #1,xxp_Tspc(a5)
 bra .rcyc
.wfx2:
 tst.w xxp_Fnum(a5)        ;if Fnum <> 0, retry w. Fnum = 0
 beq.s .wdok               ;(else, will be bad)

.pfxf:
 moveq #0,d0               ;attach font 0 to dummy xxp_wsuw
 moveq #0,d1               ;(will be passed on by TLReqon)
 moveq #0,d2
 bsr TLAnyfont
 bne .rcyc
.wdok:

 move.l xxp_btdy(a4),d3    ;calculate requester height
 addq.w #1,d1
 mulu d1,d3
 subq.w #1,d1
 moveq #0,d0               ;d3 = btdy * no. of lines - pref vert
 move.b xxp_prfp+4(a4),d0
 sub.l d0,d3
 addq.l #2,d3              ;add  (top) - 1 - (title) - 0 - (...) - 1 - (bot)

 cmp.l xxp_Height(a4),d3   ;go unless requester too deep
 ble.s .htok
 tst.b xxp_prfp+4(a4)      ;if  horz vert <> 0, dec horz vert & retry
 beq.s .hfx1
 subq.b #1,xxp_prfp+4(a4)
 bra .rcyc
.hfx1:
 tst.w xxp_Fnum(a5)        ;if Fnum <> 0, retry w. Fnum = 0
 bne .pfxf                 ;(else, will be bad)
.htok:

 bsr TLReqchek             ;check requester size & posn
 beq .bad
 tst.w xxp_ReqNull(a4)     ;go if null
 beq .null

 bsr TLReqon               ;window on
 beq .bad                  ;go if can't
 move.l d1,d2              ;d2 = no. of strings

 bsr TLButprt              ;print buttons & buttons text
 move.l a0,a1
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 lea .fns,a0
 bsr TLButtxt              ;print buttons text
 move.l a1,a0

 moveq #2,d0               ;print header
 add.l xxp_butx(a4),d0
 moveq #2,d1
 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)
 move.l a1,xxp_IText(a5)
 bsr TLText
 add.l xxp_butw(a4),d0
 moveq #0,d3
 move.b xxp_prfp+4(a4),d3
 sub.l d3,d1
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 bra.s .fore

.strg:                     ;print strings
 move.l a1,xxp_IText(a5)
 bsr TLText
.fore:
 tst.b (a1)+
 bne .fore
 add.l xxp_btdy(a4),d1
 dbra d2,.strg

 bsr TLHook2               ;call xxp_hook2 if any
 move.l xxp_WPort+112(a7),xxp_strg(a4) ;restore xxp_strg from stack

.wait:
 move.l xxp_strg(a4),-(a7) ;attach default help if none
 move.l xxp_Help(a4),-(a7)
 bne.s .wtdo
 move.l #.str,xxp_strg(a4)
 move.l #$00010009,xxp_Help(a4)
.wtdo:
 bsr TLWfront
 bsr TLKeyboard            ;wait for response
 move.l (a7)+,xxp_Help(a4)
 move.l (a7)+,xxp_strg(a4)
 cmp.b #$81,d0             ;go if not Fn key
 bcs.s .clik
 sub.b #$81,d0
 cmp.w xxp_butl+2(a4),d0
 bcc .wait
 addq.w #1,d0
 bra.s .close              ;D0=choice
.clik:
 cmp.b #$80,d0             ;redo if not lmb
 bne .wait
 bsr TLButmon              ;D0=1+ if button clicked
 tst.w d0
 beq .wait                 ;go if not in button
.close:
 bsr TLReqoff              ;close requester window, pop old window if any
 bra.s .done

.bad:                      ;bad if too big / can't open window
 moveq #0,d0
 bra.s .done

.null:                     ;here if xxp_ReqNull was 0
 subq.w #1,xxp_ReqNull(a4) ;leave xxp_ReqNull <> 0
 moveq #1,d0               ;dummy choice = 1

.done:
 bsr TLWslof               ;clear all message buffers
 add.w #xxp_WPort+4,a7     ;remove dummy IntuiText
 add.w #100,a7             ;slough dummy strings
 addq.l #8,a7              ;slough input d0,d1
 move.l (a7)+,xxp_strg(a4) ;restore global strings
 move.l d0,(a7)

 movem.l (a7)+,d0-d7/a0-a6

 move.l (a7)+,xxp_butl(a4) ;restore button data
 move.l (a7)+,xxp_butk(a4)
 move.l (a7)+,xxp_btdy(a4)
 move.l (a7)+,xxp_btdx(a4)
 move.l (a7)+,xxp_buth(a4)
 move.l (a7)+,xxp_butw(a4)
 move.l (a7)+,xxp_buty(a4)
 move.l (a7)+,xxp_butx(a4)

 tst.l d0                  ;EQ, D0=0 if bad, else 1+ = choice
 rts

.str: dc.b 0
 dc.b 'You are requested to choose 1 item from the list of alternatives.',0
 dc.b 'Make your choice by clicking one of the left hand buttons.',0 ;2
 dc.b 'Or, you can press a Function key as shown within the button.',0 ;3
 dc.b 0 ;4
 dc.b '(If there are more than 9 choices you can only choose among the',0 ;5
 dc.b 'first 9 by means of Function keys.)',0 ;6
 dc.b 0 ;7
 dc.b '(If you have attached hotkeys to the Function keys, then of course',0
 dc.b 'you should choose by clicking a button, not by function key.)',0 ;9
 ds.w 0

.ack: dc.b 'Click to acknowledge',0
.fns: dc.b 'F1\F2\F3\F4\F5\F6\F7\F8\F9\F0',0
 ds.w 0

*>>>> input a string/num  D0=header strnum D1=0str/-1num/+1hex D2=num chrs
;                         D3=0 calculate width;  D3<>0 =width
TLReqinput:
 move.l xxp_butx(a4),-(a7) ;save button data
 move.l xxp_buty(a4),-(a7)
 move.l xxp_butw(a4),-(a7)
 move.l xxp_buth(a4),-(a7)
 move.l xxp_btdx(a4),-(a7)
 move.l xxp_btdy(a4),-(a7)
 move.l xxp_butk(a4),-(a7)
 move.l xxp_butl(a4),-(a7)

 movem.l d0-d7/a0-a6,-(a7) ;save all except result in D0
 move.l a7,xxp_Stak(a4)
 clr.l xxp_errn(a4)
 sub.w #xxp_WPort+4,a7     ;create dummy part xxp_wsuw

 move.l a7,a5              ;set pop window
 bsr TLReqredi
 beq .bad

 move.l xxp_pref(a4),a0    ;prefs to prfp
 move.l xxp_yinp(a0),xxp_prfp(a4)
 move.l xxp_yinp+4(a0),xxp_prfp+4(a4)

.rcyc:                     ;see if will fit...
 move.l xxp_WPort+4(a7),d0
 move.l xxp_WPort+8(a7),d1
 move.l xxp_WPort+12(a7),d2
 move.l xxp_WPort+16(a7),d3

 moveq #0,d4               ;set d3 to minimum tablet width
 move.w d3,d4
 bne.s .wdgt               ;go if set in D3
 move.l (a4),-(a7)
 move.b #'N',(a4)
 clr.b 1(a4)
 move.l a4,xxp_IText(a5)
 bsr TLTszdo               ;else set width to D2+1 ens
 move.l (a7)+,(a4)
 addq.w #1,d2
 mulu d2,d4
 subq.w #1,d2
.wdgt:
 move.l d4,d3              ;d3 = minimum tablet width

 bsr TLStra0               ;set d6 to header width, a3 to header
 move.l a0,a3
 move.l a0,xxp_IText(a5)
 bsr TLTszdo               ;set D4 to header width, D6 to header height
 move.l d3,d7              ;set D7 to tablet width

 lea .oc,a0                ;set D2 = requester width
 move.l xxp_AcWind(a4),-(a7)
 move.l a5,xxp_AcWind(a4)
 bsr TLButstr              ;set: butw,buth
 move.l (a7)+,xxp_AcWind(a4)
 move.l d4,d0              ;d0 = greater of tablet box width, header width
 cmp.l d7,d0
 bcc.s .maxw
 move.l d7,d0
.maxw:
 bsr TLButfix              ;get requester width to D2, set: butx,btdx

 cmp.l xxp_Width(a4),d2    ;go unless too wide
 ble.s .vert
 tst.b xxp_prfp+3(a4)      ;if pref horz <> 0, retry w. pref horz - 1
 beq.s .pfx1
 subq.b #1,xxp_prfp+3(a4)
 bra .rcyc
.pfx1:
 tst.w xxp_Tspc(a5)        ;if Tspc <> 0, retry w. Tspc - 1
 beq.s .pfx2
 subq.w #1,xxp_Tspc(a5)
 bra .rcyc
.pfx2:
 tst.w xxp_Fnum(a5)        ;if Fnum <> 0, retry w. Fnum = 0
 beq.s .vert               ;(else, will be too wide)
.pfxf:
 moveq #0,d0               ;attach font 0 to dummy xxp_wsuw
 moveq #0,d1               ;(will be passed on by TLReqon)
 moveq #0,d2
 bsr TLAnyfont
 bne .rcyc

.vert:
 move.l d6,d3              ;set D3 = requester height...
 asl.w #1,d3
 addq.l #5,d3              ;d3=requester height before butts
 moveq #0,d5
 move.b xxp_prfp+4(a4),d5  ;d5 = pref vert
 add.l d5,d3               ;gap above buts
 move.l d3,xxp_buty(a4)    ;set buty
 clr.l xxp_btdy(a4)
 add.l xxp_buth(a4),d3
 add.l d5,d3               ;gap below buts
 tst.w d5
 beq.s .botg
 addq.l #1,d3              ;add 1 if pref vert <> 0
.botg:

 cmp.l xxp_Height(a4),d3   ;go if shallow enough
 ble.s .test
 tst.b xxp_prfp+4(a4)      ;if pref vert <> 0, dec pref vert & retry
 beq.s .hfx1
 subq.b #1,xxp_prfp+4(a4)
 bra .rcyc
.hfx1:
 tst.w xxp_Fnum(a5)        ;if Fnum <> 0, set Fnum = 0 & restry
 bne .pfxf                 ;(else will be too deep)

.test:
 bsr TLReqchek             ;fix requesters dims, &c
 beq .bad                  ;go if won't fit

 tst.w xxp_ReqNull(a4)     ;quit if ReqNull=0
 beq .null

 bsr TLReqon               ;open requester window
 beq .bad                  ;go if can't

 bsr TLButprt              ;draw requester buttons
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 lea .oc,a0
 bsr TLButtxt              ;print button text

 moveq #4,d0               ;print title
 moveq #2,d1
 move.l a3,xxp_IText(a5)
 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)
 bsr TLText
 move.l a4,xxp_IText(a5)
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)

 moveq #0,d0               ;draw tablet box
 moveq #0,d1
 move.b xxp_prfp+3(a4),d1
 beq.s .nulp
 addq.l #2,d1
 add.l d1,d0
.nulp:
 sub.l d1,d2
 sub.l d1,d2
 moveq #3,d1
 add.l d6,d1
 move.l d6,d3
 addq.l #2,d3
 bsr TLReqbev

 subq.w #2,d3              ;D0-D3 = tablet for TLreqedit
 subq.w #8,d2
 addq.w #4,d0
 addq.w #1,d1

 bsr TLHook2               ;call xxp_hook2 if any

.wait:                     ;edit the tablet...
 bsr TLWfront

 moveq #0,d6               ;set d6 to task type
 tst.l xxp_WPort+8(a7)     ;initial d1: 0=str -1=num 1=hex)
 beq.s .str                ;d6=0 for str
 bmi.s .num
 moveq #3,d6               ;d6=3 for hex
 bra.s .str
.num:
 moveq #2,d6               ;d6=2 for num
.str:

 move.l xxp_WPort+12(a7),d7  ;d7 = initial d2 = max chrs

 move.l xxp_Help(a4),-(a7) ;attach default help if none
 move.l xxp_strg(a4),-(a7)
 tst.l xxp_Help(a4)
 bne.s .wtdo
 move.l #.strs,xxp_strg(a4)
 move.w #1,xxp_Help(a4)
 move.w #20,xxp_Help+2(a4)
.wtdo:

 sub.w #44,a7              ;room for 5 tags for TLReqedit
 move.l a7,a0
 move.l #xxp_xmaxt,(a0)+   ;tag 1: tablet width
 move.l d2,(a0)+
 move.l #xxp_xmaxc,(a0)+   ;tag 2: max chrs
 move.l d7,(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: crsr (to rhs)
 move.l #$7FFF,(a0)+
 move.l #xxp_xtask,(a0)+   ;tag 4: task
 move.l d6,(a0)+
 move.l #xxp_xforb,(a0)+   ;tag 5: enable return if unrec input
 move.l #$0000BFFF,(a0)+   ;       (to collect LfAm/b, LfAm/v)
 clr.l (a0)
 move.l a7,a0
 move.l d0,-(a7)
 bsr TLReqedit             ;d0=lhs, d1=top: get user input
 move.l (a7)+,d0
 add.w #44,a7              ;remove tags

 move.l (a7)+,xxp_strg(a4)
 move.l (a7)+,xxp_Help(a4)

 move.l xxp_kybd(a4),d7    ;d7=last chr input
 cmp.w #$1B,d7             ;go if Esc
 beq.s .canc
 cmp.w #$0D,d7             ;go if return
 beq.s .good
 btst #6,xxp_kybd+15(a4)
 beq.s .wtck               ;go unless Left Amiga
 cmp.b #'b',d7
 beq.s .canc               ;LfAm / b -> Cancel
 cmp.b #'v',d7
 beq.s .good               ;LfAm / v -> OK
.wtck:
 cmp.w #$80,d7             ;recycle unless Esc/Return/lmb
 bne .wait

 movem.l d1-d2,-(a7)       ;lmb clicked
 move.l xxp_kybd+4(a4),d1  ;get pointer posn
 move.l xxp_kybd+8(a4),d2
 bsr TLButmon              ;calc which box (if any)
 movem.l (a7)+,d1-d2
 tst.w d0                  ;retry if neither box clicked
 beq .wait

 subq.l #2,d0              ;go if cancel box clicked
 beq.s .canc

.good:                     ;here if OK chosen
 bsr TLReqoff

.null:                     ;here if ReqNull=0
 moveq #-1,d0
 bra.s .done

.canc:                     ;here if Cancel chosen
 bsr TLReqoff

.bad:                      ;if cancel:  D0=0, xxp_errn=0
 moveq #0,d0               ;if bad:     D0=0, xxp_errn<>0

.done:
 move.w #-1,xxp_ReqNull(a4)
 bsr TLWslof
 add.w #xxp_WPort+4,a7
 move.l d0,(a7)
 movem.l (a7)+,d0-d7/a0-a6

 move.l (a7)+,xxp_butl(a4) ;restore button data
 move.l (a7)+,xxp_butk(a4)
 move.l (a7)+,xxp_btdy(a4)
 move.l (a7)+,xxp_btdx(a4)
 move.l (a7)+,xxp_buth(a4)
 move.l (a7)+,xxp_butw(a4)
 move.l (a7)+,xxp_buty(a4)
 move.l (a7)+,xxp_butx(a4)
 tst.l d0                  ;EQ, D0=0 if bad
 rts

.oc: dc.b 'OK\Cancel',0

.strs: dc.b 0
 dc.b 'This requester is used by you to send information to the computer.',0
 dc.b 'Simply type information into the box which contains the cursor. If',0
 dc.b 'something already appears there (called a "prompt") you can return',0
 dc.b 'it unchanged, or alter it and then return it as your input.',0
 dc.b 0
 dc.b 'When the box contains what you want it to, click "OK" (or press',0
 dc.b 'the Return key) to return it. Alternately, click "Cancel" (or',0
 dc.b 'press the Esc key) to send no message at all, and cancel.',0
 dc.b 0
 dc.b 'If you are asked for a number, you may only type characters 0-9.',0
 dc.b 'If you are asked for a hex number, you may only type 0-9 or A-F.',0
 dc.b 0
 dc.b 'Here are some special keyboard combinations:',0
 dc.b '   Shift with backspace    delete all characters before cursor',0
 dc.b '   Shift with Del          delete all characters from cursor on',0
 dc.b '   Ctrl with A             cursor to start of line',0
 dc.b '   Ctrl with Z             cursor to end of line',0
 dc.b '   Ctrl with X             delete all characters in line',0
 dc.b '   Shift with Ctrl with U  cancel effect of previous keystroke',0
 dc.b '   Shift with Ctrl with R  restore the prompt to aboriginal state',0
 ds.w 0


*>>>> make a super/subscript copy of font d0
TLSuper:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 clr.l xxp_errn(a4)
 move.l xxp_FSuite(a4),a3  ;point a3 to FSuite entry d0
 mulu #xxp_fsiz,d0
 add.l d0,a3
 move.w ta_YSize(a3),d7    ;d7 = normal font height
 move.w d7,d0
 bsr TLYhalf               ;make d0 half height
 move.w d0,ta_YSize(a3)    ;set YSize to half height
 lea .libn,a1
 moveq #0,d0
 move.l xxp_sysb(a4),a6
 jsr _LVOOpenLibrary(a6)   ;open diskfont.library
 tst.l d0
 beq.s .bad1               ;bad if can't
 move.l d0,a6
 move.l a3,a0
 jsr _LVOOpenDiskFont(a6)  ;open half height font
 move.l d0,d2              ;result in d2
 move.l a6,a1
 move.l xxp_sysb(a4),a6    ;close diskfont.lbrary
 jsr _LVOCloseLibrary(a6)
 move.l d2,xxp_ital(a3)    ;put half height font to xxp_ital
 beq.s .bad2
 moveq #-1,d0
 bra.s .done
.bad1:                     ;bad 1: can't open diskfont.library (unlikely)
 moveq #8,d0
 bra.s .bad
.bad2:                     ;bad 2: can't open half-height font
 moveq #12,d0
.bad:
 move.l d0,xxp_errn(a4)    ;error code to xxp_errn
 clr.l d0
.done:
 move.w d7,ta_YSize(a3)    ;restore YSize
 tst.l d0
 movem.l (a7)+,d0-d7/a0-a6 ;EQ if bad
 rts

.libn: dc.b 'diskfont.library',0
 ds.w 0

*>>>> make YSize in D0 to be height for Super/Subscript
TLYhalf:
 lsr.w #1,d0
 cmp.w #6,d0
 bcc.s .half
 moveq #6,d0
.half:
 rts

*>>>> make a double width copy of font d0
TLWide:
 move.l xxp_strg(a4),-(a7) ;attach local strings
 clr.l xxp_errn(a4)
 move.l #.str,xxp_strg(a4)
 movem.l d0-d7/a0-a6,-(a7) ;save all

 subq.l #8,a7              ;lock on FONTS:Temporary, FONTS: here
 clr.l (a7)                ;(512(a7) will hold lock on FONTS:Temporary)
 clr.l 4(a7)               ;(516(a7) will hold lock on FONTS:)
 sub.w #512,a7             ;* table for CharData translation

 move.l xxp_FSuite(a4),a0  ;* a5 = single width font
 mulu #xxp_fsiz,d0
 move.l xxp_plain(a0,d0.l),a5

 move.l a7,a1              ;a1 puts to table
 moveq #0,d4               ;d4 values 0-255
 move.w #255,d2            ;d2 counts table entries
.tabl:
 move.b d4,d0              ;d0 gets input bytes
 moveq #0,d1               ;d1 puts output bytes
 moveq #7,d3               ;d3 counts bits
.bits:                     ;for all set bits...
 lsr.b #1,d0               ;get next input bit
 bcc.s .bit0
 or.w #3,d1                ;set rightmost 2 if rightmost 1 set
.bit0:
 ror.w #2,d1               ;shift around (1st 2 end up at 0,1)
 dbra d3,.bits             ;until all bits shifted out -> in
 move.w d1,(a1)+           ;put output word
 addq.b #1,d4              ;bump input byte value
 dbra d2,.tabl             ;until table complete

 bsr .dell                 ;* delete existing Temorary.font if any

 moveq #2,d0               ;* create new FONTS:Temporary dir
 bsr TLStrbuf
 move.l a4,d1
 move.l xxp_dosb(a4),a6
 jsr _LVOCreateDir(a6)
 move.l d0,512(a7)         ;save lock
 beq .bad1                 ;bad if can't (unlikely)

 move.l a4,a0              ;* open output file
 add.w #13,a0
 move.b #'/',(a0)+         ;append /[YSize] to dirname
 moveq #0,d0
 move.w tf_YSize(a5),d0
 bsr TLHexasc
 clr.b (a0)
 bsr TLOpenwrite           ;open it for writing
 beq .bad2                 ;bad if can't

 lea .frnt,a0              ;* copy .frnt & c. to buff
 move.l a4,a1
 move.w #.back-.frnt-1,d1
.tfr1:
 move.b (a0)+,(a1)+
 dbra d1,.tfr1

 move.l a4,a0
 add.w #.fnth-.frnt+$0023,a0
 moveq #0,d0
 move.w tf_YSize(a5),d0
 bsr TLHexasc              ;append [YSize] to filename in .fnth

 move.l a4,a3
 add.w #.font-.frnt-tf_YSize,a3   ;a3= font structure in output
 move.l tf_YSize(a5),tf_YSize(a3) ;copy YSize,Style,Flags
 move.b #FPF_DESIGNED!FPF_DISKFONT,tf_Flags(a3)
 tst.l tf_CharSpace(a5)
 beq.s .flgs
 or.b #FPF_PROPORTIONAL,tf_Flags(a3)
.flgs:
 move.w tf_XSize(a5),d0
 asl.w #1,d0
 move.w d0,tf_XSize(a3)                 ;copy & double XSize
 move.l tf_Baseline(a5),tf_Baseline(a3) ;copy Baseline,BoldSmear
 clr.w tf_Accessors(a3)                 ;Accessors = 0
 move.w tf_LoChar(a5),tf_LoChar(a3)     ;LoChar,HiChar
 move.w tf_Modulo(a5),d0
 asl.w #1,d0
 move.w d0,tf_Modulo(a3)                ;copy & double Modulo
 moveq #0,d7
 move.b tf_HiChar(a5),d7   ;d7 = no. of glyphs
 sub.b tf_LoChar(a5),d7
 addq.w #1,d7
 move.l #.back1-.fnth,d0   ;d0 = rel addr where CharData will be
 move.l d0,tf_CharData(a3) ;put CharData relative address
 move.w tf_Modulo(a3),d1
 mulu tf_YSize(a3),d1      ;CharData size = Modulo * YSize
 add.l d1,d0
 move.l d0,tf_CharLoc(a3)  ;put CharLoc relative address
 move.l d7,d1
 lsl.l #2,d1               ;CharLoc size = Glyphs * 4
 add.l d1,d0
 lsr.l #1,d1
 btst #1,d1                ;d1 = Glyphs * 2, rounded up to even longwords
 beq.s .cry1
 addq.l #2,d1
.cry1:
 clr.l tf_CharSpace(a3)    ;if input CharSpace = 0, so does output
 tst.l tf_CharSpace(a5)
 beq.s .krns
 move.l d0,tf_CharSpace(a3)   ;put rel addr to CharSpace
 add.l d1,d0                  ;add Glyphs * 2 to output size
.krns:
 clr.l tf_CharKern(a3)     ;if input CharKern = 0, so does output
 tst.l tf_CharKern(a5)
 beq.s .krnf
 move.l d0,tf_CharKern(a3)    ;put rel addr to CharSpace
 add.l d1,d0                  ;add glyphs * 2 to output size
.krnf:
 lsr.l #2,d0               ;d0 = longwords from .fnth
 move.l d0,$0014(a4)       ;poke hunk size
 move.l d0,$001C(a4)

 move.l a4,d2              ;save from .frnt to .back1
 move.l #.back1-.frnt,d3
 bsr TLWritefile
 beq .bad3                 ;bad if can't
 bsr .buff                 ;set up outfile buffer

 move.w tf_Modulo(a5),d6   ;* send CharData
 mulu tf_YSize(a3),d6      ;d6 = bytes in old CharData
 move.l tf_CharData(a5),a0 ;a0 gets from old CharData
.cdat:
 moveq #0,d1
 move.b (a0)+,d1           ;get next byte of CharData
 lsl.w #1,d1               ;find  posn in lookup table in stack
 move.w 0(a7,d1.w),d0      ;send to outfile (1 byte -> 1 word)
 bsr .file
 beq .bad3                 ;bad if can't
 subq.l #1,d6              ;until all new CharData sent
 bne .cdat
 bsr .flsh                 ;flush unsent bytes from buff
 beq .bad3                 ;bad if can't

 move.l d7,d6              ;* send CharLoc
 subq.w #1,d6              ;d6 counts
 move.l tf_CharLoc(a5),a0  ;a0 sends old CharLoc
.cloc:
 move.l (a0)+,d0           ;get next old
 swap d0                   ;get msw
 asl.w #1,d0                 ;double it
 bsr .file                 ;send it
 beq .bad3                 ;bad if can't
 swap d0                   ;get lsw
 asl.w #1,d0               ;double it
 bsr .file                 ;send it
 beq .bad3                 ;bad if can't
 dbra d6,.cloc
 bsr .flsh                 ;flush unsent bytes
 beq .bad3

 move.l tf_CharSpace(a5),d0 ;* send CharSpace
 beq.s .clkr               ;go if none
 move.l d0,a0              ;a0 sends old CharSpace
 move.l d7,d6              ;d6 counts
 subq.w #1,d6
.clcs:
 move.w (a0)+,d0           ;get next old
 asl.w #1,d0               ;double it
 bsr .file                 ;send it
 beq .bad3                 ;bad if can't
 dbra d6,.clcs
 bsr .flsh                 ;flush unsent bytes, longword fill
 beq .bad3

.clkr:                     ;* send CharKern
 move.l tf_CharKern(a5),d0
 beq.s .clkd               ;go if none
 move.l d0,a0              ;a0 sends old CharKern
 move.l d7,d6              ;d6 counts
 subq.w #1,d6
.clkn:
 move.w (a0)+,d0           ;get next old
 asl.w #1,d0               ;double it
 bsr .file                 ;send it
 beq .bad3                 ;bad if can't
 dbra d6,.clkn
 bsr .flsh                 ;flush unsent bytes, longword fill
 beq .bad3

.clkd:                     ;* send .back1, .back2
 lea .back1,a0             ;send 1st long of .back1
 move.l a4,a1
 move.l (a0)+,(a1)+
 addq.l #4,a0
 move.l #4,(a1)+           ;send 4 pro-tem = reloc count
 moveq #4,d0
.bax:
 move.l (a0)+,(a1)+        ;send hunk num & 4 relocs
 dbra d0,.bax
 tst.l tf_CharSpace(a5)    ;go if no CharSpace
 beq.s .bxc1
 move.l (a0),(a1)+         ;else send CharSpace reloc
 addq.l #1,4(a4)           ;& bump reloc count
.bxc1:
 tst.l tf_CharKern(a5)     ;go if no CharKern
 beq.s .bxc2
 move.l 4(a0),(a1)+        ;else send CharKern reloc
 addq.l #1,4(a4)           ;& bump reloc count
.bxc2:
 addq.l #8,a0
 move.l (a0)+,(a1)+        ;send relocs delim & hunk_end
 move.l (a0)+,(a1)+
 move.l a4,d2
 move.l a1,d3
 sub.l d2,d3
 bsr TLWritefile           ;write .back1 - .back
 beq .bad3                 ;bad if can't

 bsr TLClosefile           ;* close file - created ok

 move.l xxp_dosb(a4),a6    ;* unlock Temporary
 move.l 512(a7),d1
 jsr _LVOUnLock(a6)
 clr.l 512(a7)

 moveq #5,d0               ;* lock FONTS:
 bsr TLStrbuf
 move.l a4,d1
 moveq #ACCESS_READ,d2
 jsr _LVOLock(a6)
 move.l d0,516(a7)
 beq .bad7

 moveq #3,d0               ;* open diskfont.library
 bsr TLStrbuf
 move.l xxp_sysb(a4),a6
 move.l a4,a1
 moveq #34,d0
 jsr _LVOOpenLibrary(a6)
 tst.l d0
 beq .bad4                 ;bad if can't (unlikely)
 move.l d0,a6

 moveq #4,d0               ;* create Temporary.font file
 bsr TLStrbuf
 move.l 516(a7),a0
 move.l a4,a1
 jsr _LVONewFontContents(a6)
 move.l d0,d2              ;d2 = fontContentsHeader
 beq .bad5                 ;bad if NewFontContents failed
 moveq #7,d0
 bsr TLStrbuf
 bsr TLOpenwrite           ;open Temporary.font
 beq .bad8                 ;bad if can't
 move.l d2,a0
 move.w fch_NumEntries(a0),d3
 mulu #tfc_SIZEOF,d3
 addq.l #fch_FC,d3
 bsr TLWritefile           ;write NewFontContents
 beq .bad9                 ;bad if can't
 bsr TLClosefile           ;close Temporary.font
 move.l d2,a1
 jsr _LVODisposeFontContents(a6)

 moveq #7,d0               ;* load Temporary/[YSize]
 bsr TLStrbuf
 move.l a4,a0              ;make textattr at buff+20
 add.w #20,a0
 move.l a4,ta_Name(a0)
 move.w tf_YSize(a5),ta_YSize(a0)
 clr.w ta_Style(a0)
 jsr _LVOOpenDiskFont(a6)
 move.l d0,d7              ;d7 = result of OpenDiskFont (full height)
 move.l a4,a0
 add.w #20,a0
 move.w ta_YSize(a0),d0
 bsr TLYhalf               ;make d0 half hright
 move.w d0,ta_YSize(a0)
 jsr _LVOOpenDiskFont(a6)
 move.l d0,d6              ;d6 = result of OpenDiskFont (half height)

 move.l a6,a1              ;* close diskfont.library
 move.l xxp_sysb(a4),a6
 jsr _LVOCloseLibrary(a6)

 move.l xxp_FSuite(a4),a0  ;* put font in FSuite
 move.l 520(a7),d1
 mulu #xxp_fsiz,d1
 move.l d7,xxp_bold(a0,d1.l)
 beq .bad10                ;bad if OpenDiskFont failed
 move.l d6,xxp_boit(a0,d1.l)
 moveq #-1,d0              ;else, report success
 bra.s .done

.bad1:                     ;* can't create FONTS:Temporary
 moveq #13,d0
 bra.s .bad

.bad2:                     ;* can't open FONTS:Temporary/[YSize]
 moveq #14,d0
 bra.s .bad

.bad3:                     ;* can't write to FONTS:Temporary/[YSize]
 moveq #15,d0
 bra.s .bad

.bad4:                     ;* can't open diskfont.library (v. 34+)
 moveq #8,d0
 bra.s .bad

.bad5:                     ;* new font contents failed
 move.l a6,a1
 move.l xxp_sysb(a4),a6
 jsr _LVOCloseLibrary(a6)
 moveq #16,d0
 bra.s .bad

.bad6:                     ;* can't open doubled font (out of public ram?)
 moveq #1,d0
 bra.s .bad

.bad7:                     ;* can't lock FONTS: (unlikely)
 moveq #17,d0
 bra.s .bad

.bad8:                     ;* can't open Temporary.font for writing
 move.l d2,a1
 jsr _LVODisposeFontContents(a6)
 move.l a6,a1
 move.l xxp_sysb(a4),a6
 jsr _LVOCloseLibrary(a6)
 moveq #18,d0
 bra.s .bad

.bad9:                     ;* can't write to Temporary.font
 move.l d2,a1
 jsr _LVODisposeFontContents(a6)
 move.l a6,a1
 move.l xxp_sysb(a4),a6
 jsr _LVOCloseLibrary(a6)
 moveq #19,d0
 bra.s .bad

.bad10:                    ;* can't open Temporary/[YSize] as created
 moveq #20,d0

.bad:
 move.l d0,xxp_errn(a4)
 moveq #0,d0

.done:                     ;* close down
 bsr.s .kill               ;remove locks, if any
 bsr.w .dell               ;remove Temorary.font, if any
 add.w #512,a7
 add.l #8,a7
 tst.l d0                  ;NE=good  EQ=bad
 movem.l (a7)+,d0-d7/a0-a6
 move.l (a7)+,xxp_strg(a4)
 rts

.kill:                     ;** remove locks, if they exist
 movem.l d0-d3/a0-a1/a6,-(a7) ;save all (add 28 to stack, +rts = 32)
 move.l xxp_dosb(a4),a6
 move.l 512+32(a7),d1      ;if locked, unlock FONTS:Temorary
 beq.s .klu1
 jsr _LVOUnLock(a6)
 clr.l 512+32(a7)
.klu1:
 move.l 516+32(a7),d1      ;if locked, unlock FONTS:
 beq.s .klu2
 jsr _LVOUnLock(a6)
 clr.l 516+32(a7)
.klu2:
 movem.l (a7)+,d0-d3/a0-a1/a6
 rts

.dell:                     ;** delete Temporary.font
 movem.l d0-d3/a0-a1/a6,-(a7)
 move.l xxp_dosb(a4),a6
 moveq #1,d0               ;* delete existing FONTS:Temporary (if any)
 bsr.s .kldo
 moveq #6,d0               ;* delete existing FONT:Temporary.font (if any)
 bsr.s .kldo
 movem.l (a7)+,d0-d3/a0-a1/a6
 rts

.kldo:                     ;** execute dos command in string D0
 bsr TLStrbuf
 move.l a4,d1
 moveq #0,d2
 moveq #0,d3
 jsr _LVOExecute(a6)
 rts

.buff:                     ;** set up buff as outfile buffer
 move.l a4,128(a4)         ;buff+128 = pointer
 rts

.file:                     ;** send a word to the outfile buffer
 movem.l d0-d3/a0,-(a7)    ;save all
 move.l 128(a4),a0
 move.w d0,(a0)+           ;send word to buff
 move.l a0,128(a4)
 sub.w #128,a0             ;buff full?
 cmp.l a4,a0
 bcs.s .filg               ;no, go
 move.l a4,d2
 move.l #128,d3
 bsr TLWritefile           ;yes, send to file
 beq.s .fild               ;bad if can't
 move.l a4,128(a4)         ;restart pointer
.filg:
 moveq #-1,d0              ;NE = good
.fild:                     ;EQ = bad
 movem.l (a7)+,a0/d0-d3
 rts

.flsh:                     ;** longword align & flush the outfiel buffer
 movem.l d0-d3/a0,-(a7)    ;save all
 move.l 128(a4),a0         ;a0 = pointer so far
.flal:
 move.l a0,d3              ;get length to save
 clr.w (a0)+               ;(clr fwd in case aligning)
 sub.l a4,d3               ;d3 = len to save
 beq.s .flgd               ;go if nil
 move.l d3,d2
 and.l #3,d2               ;lonword aligned?
 bne .flal                 ;no, send a(nother) null
 move.l a4,d2
 bsr TLWritefile           ;send buff contents
 beq.s .flbd               ;bad if can't
 move.l a4,128(a4)         ;restart pointer
.flgd:
 moveq #-1,d0              ;NE = good
 bra.s .fldn
.flbd:
 moveq #0,d0               ;EQ = bad
.fldn:
 movem.l (a7)+,a0/d0-d3
 rts

.str: dc.b 0
 dc.b 'DELETE RAM:Temporary ALL >NIL:',0 ;1
 dc.b 'RAM:Temporary',0 ;2
 dc.b 'diskfont.library',0 ;3
 dc.b 'Temporary.font',0 ;4
 dc.b 'RAM:',0 ;5
 dc.b 'DELETE RAM:Temporary.font >NIL:',0 ;6
 dc.b 'RAM:Temporary.font',0 ;7
 ds.w 0

.frnt:                     ;* front end of file
 dc.l $000003F3            ;$0000 hunk_header
 dc.l $00000000            ;$0004 name delim
 dc.l $00000001            ;$0008 table size
 dc.l $00000000            ;$000C F
 dc.l $00000000            ;$0010 L
 ds.l 1                    ;$0014 *** poke longwords in .fnth -> .back here
 dc.l $000003E9            ;$0018 hunk_code
 ds.l 1                    ;$001C *** poke longwords in .fnth -> .back here
.fnth:
 dc.w $70FF                ;$0000 MOVEQ #-1,D0
 dc.w $4E75                ;$0002 RTS
 dc.l 0                    ;$0004 LN_Succ                  }  LN_SIZE
 dc.l 0                    ;$0008 LN_Pred                  }
 dc.b NT_FONT              ;$000C LN_Type                  }
 dc.b 0                    ;$000D LN_Pri                   }
 dc.l $0000001A            ;$000E rel address of font name }
 dc.w DFH_ID               ;$0012 FileID
 dc.w 1                    ;$0014 Revision
 dc.l 0                    ;$0016 Segment
 dc.b 'Temporary'          ;$001A font name
 dc.b 0,0,0,0,0,0,0        ;$0023 poke length in ASCII here
 dc.l 0,0,0,0              ;$002A fill to MAXFONTNAME
 dc.l 0                    ;$003A LN_Succ
 dc.l 0                    ;$003E LN_Pred
 dc.b NT_FONT              ;$0042 LN_Type
 dc.b 0                    ;$0043 LN_Pri
 dc.l $0000001A            ;$0044 rel address of font name (-42)
 dc.l 0                    ;$0048 MN_ReplyPort
 dc.w 0                    ;$004C OS1.4
.font:
 ds.w 1                    ;$004E tf_YSize    *** poke YSize here
 ds.b 1                    ;$0050 tf_Style
 ds.b 1                    ;$0051 tf_Flags
 ds.w 1                    ;$0052 tf_XSize
 ds.w 1                    ;$0054 tf_Baseline
 dc.w 1                    ;$0056 tf_BoldSmear
 ds.w 1                    ;$0058 tf_Accessors
 ds.b 1                    ;$005A tf_LoChar
 ds.b 1                    ;$005B tf_HiChar
 ds.l 1                    ;$005C tf_CharData  *** rel addr here
 ds.w 1                    ;$0060 tf_Modulo
 ds.l 1                    ;$0062 tf_FontLoc   *** rel addr here
 ds.l 1                    ;$0066 tf_CharSpace *** rel addr / 0 here
 ds.l 1                    ;$006A tf_CharKern  *** rel addr / 0 here
 dc.w 0                    ;$006E longword fill

;then follow:
;  CharData       tf_Modulo * tf_YSize
;  CharLoc        1 longword / chr
;  CharSpace      1 word / chr
;  Charkern       1 word / chr

.back1:                    ;$0000 append after font
 dc.l $000003EC            ;$0004 hunk_reloc
 ds.l 1                    ;$0008 relocs       *** poke 4-6 here
 dc.l $00000000            ;$000C hunk number
 dc.l $0000000E            ;$0010 font name
 dc.l $00000044            ;$0014 font name
 dc.l $0000005C            ;$0018 font data
 dc.l $00000062            ;$001C font loc
 dc.l $00000066            ;$0020 }            *** optional,
 dc.l $0000006A            ;$0024 }                tf_CharSpace/Kern if<>0

.back2:
 dc.l $00000000            ;$0000 no more reloc hunk
 dc.l $000003F2            ;$0004 hunk_end
.back:


*>>>> select a font from FSuite, & change FSuite items if appropriate

;D0 = forbids:  bit 0-9 to forbid load/close of font 0-9
;returns D0 = 1-10 if font chosen, D0=0 if cancel
;        EQ, errn<> if bad

TLReqfont:
 move.l xxp_strg(a4),-(a7) ;save global strings
 move.l #.str,xxp_strg(a4)
 move.l xxp_Help(a4),-(a7) ;install local help
 move.w #5,xxp_Help(a4)
 move.w #18,xxp_Help+2(a4)
 movem.l d0-d7/a0-a6,-(a7) ;save all except result in D0
 clr.l xxp_errn(a4)
 moveq #0,d7               ;d7 = return code (0 in case bad/cancel)
 moveq #0,d6               ;d6 top half = currently viewing
 move.w d0,d6              ;d6 bot half = forbids
 sub.w #xxp_WPort+4,a7     ;room for dummy part xxp_Wsuw

 move.l a7,a5              ;a5 points to dummy IntuiText
 bsr TLReqredi             ;set pop window
 beq .done                 ;bad if can't - unlikely

 move.l xxp_pref(a4),a0    ;get prefs data
 move.l xxp_ychs(a0),xxp_prfp(a4)
 move.l xxp_ychs+4(a0),xxp_prfp+4(a4)

 move.l #640,d2            ;check requester size & posn
 move.l #142,d3
 bsr TLReqchek
 beq .done                 ;bad if can't - unlikely

 bsr TLReqon               ;window on
 beq .done                 ;bad if can't

.rcyc:                     ;redraw all

 moveq #2,d0
 bset #29,d0
 moveq #1,d1
 move.l #636,d2
 move.l #140,d3
 moveq #0,d4
 move.b xxp_prfp(a4),d4    ;background colour from xxp_prfp
 bsr TLReqarea

 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 moveq #1,d0               ;print hail
 bsr TLStrbuf
 moveq #4,d0
 moveq #1,d1
 bsr TLTrim

 moveq #3,d0               ;fnum currently showing
 bsr TLStrbuf
 swap d6
 move.b d6,5(a4)
 add.b #'0',5(a4)
 swap d6
 move.l #132,d0
 moveq #120,d1
 bsr TLTrim

 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 moveq #2,d0
 bsr TLStrbuf              ;str for fonts table
 move.l xxp_FSuite(a4),a0  ;a0 scans FSuite
 moveq #10,d1              ;d1 = ypos
 moveq #10,d3              ;d3 = box height
 moveq #9,d4               ;d4 counts fonts
 move.l d6,d5              ;d5 = forbids
.fnum:
 addq.w #1,d1
 moveq #4,d0               ;text
 bsr TLTrim
 subq.w #1,d1
 moveq #16,d0              ;choose box
 tst.l (a0)
 bne.s .fnul
 bset #31,d0               ;can't choose if font null
.fnul:
 moveq #56,d2
 bsr TLReqbev
 add.w d2,d0               ;view box
 bsr TLReqbev
 bclr #31,d0
 add.w d2,d0               ;fname box
 move.w #264,d2
 cmp.w #9,d4
 beq.s .fnrc               ;can never change font 0
 ror.w #1,d5
 bcc.s .fnmb               ;recess if load/reload this font forbidden
.fnrc:
 bset #31,d0
.fnmb:
 bsr TLReqbev
 addq.b #1,(a4)            ;bump fnum
 add.w #10,d1              ;bump ypos
 add.w #xxp_fsiz,a0        ;to next font
 dbra d4,.fnum             ;until all done

 move.l xxp_FSuite(a4),a2  ;print fnames...
 moveq #11,d1              ;d1 = ypos
 moveq #9,d2               ;d2 counts
.fnam:
 tst.l (a2)                ;go if font null
 beq.s .fnxn
 move.l a2,a1              ;name to buff
 addq.l #8,a1
 move.l a4,a0
.fntf:
 move.b (a1)+,(a0)+
 bne .fntf
 clr.b 32(a4)
 move.l #132,d0            ;print fname
 bsr TLTrim

 moveq #0,d0               ;print fsiz
 move.w 4(a2),d0
 move.l a4,a0
 move.b #32,(a0)+
 bsr TLHexasc
 clr.b (a0)
 clr.b 4(a4)
 move.l #356,d0
 bsr TLTrim

.fnxn:
 add.w #10,d1              ;bump ypos
 add.w #xxp_fsiz,a2        ;to next font
 dbra d2,.fnam             ;until all printed

 move.l #400,d0            ;box around show area
 bset #31,d0
 move.l #232,d2
 moveq #10,d1
 move.l #128,d3
 bsr TLReqbev

 moveq #0,d0               ;show sample text
 swap d6
 move.w d6,d0              ;get fnum
 swap d6
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont             ;set the font
 bne.s .shwr               ;go if ok
.zap:
 swap d6
 clr.w d6                  ;else zap it & recyc
 swap d6
 bra .rcyc
.shwr:
 moveq #4,d0               ;tfr sample text to buff
 bsr TLStrbuf
.wdth:
 movem.l d6-d7,-(a7)       ;get its width
 bsr TLTsize
 movem.l (a7)+,d6-d7
 cmp.w #229,d4             ;does it fit?
 bcs.s .wdok               ;yes, go
 move.l a4,a0
.chop:
 tst.b (a0)+               ;no, truncate it
 bne .chop
 subq.l #1,a0
 cmp.l a4,a0               ;no chrs fit? (unlikely)
 beq .zap                  ;yes, go zap
 clr.b -1(a0)              ;else, truncate, see if fits now
 bra .wdth
.wdok:
 move.l #402,d0            ;print the sample (as possible truncated)
 moveq #11,d1
 bsr TLTrim

 moveq #0,d0               ;restore to font 0
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont

.wait:                     ;wait for response
 bsr TLWfront
 bsr TLKeyboard

 cmp.b #$1B,d0             ;cancelled if Esc
 beq .good

 cmp.b #$80,d0             ;else accept only lmb
 bne .wait
 sub.w #10,d2              ;set d2 = fnum (0-9)
 bcs .wait
 divu #10,d2
 cmp.w #10,d2
 bcc .wait
 sub.w #16,d1
 bcs .wait
 sub.w #56,d1              ;go if choose
 bcs .chos
 sub.w #56,d1              ;go if view
 bcs .view
 sub.w #265,d1             ;go unless fname
 bcc .wait

 btst d2,d6                ;fname (load/reload) chosen - go if forbidden
 bne.s .errr
 moveq #0,d0               ;fnum to d0
 move.w d2,d0
 beq.s .errr               ;bad if 0 (always forbidden)
 bsr TLAslfont             ;get new font
 beq.s .errr               ;go if bad/forbidden

.view:                     ;view a font
 move.l xxp_FSuite(a4),a0
 move.w d2,d0
 mulu #xxp_fsiz,d0         ;go if that font null
 tst.l 0(a0,d0.l)
 beq.s .errr
 swap d6
 move.w d2,d6              ;set view to loaded/clicked font
 swap d6
 bra .rcyc

.chos:                     ;font chosen...
 move.l xxp_FSuite(a4),a0
 move.w d2,d0
 mulu #xxp_fsiz,d0         ;go if that font null
 tst.l 0(a0,d0.l)
 beq.s .errr
 move.w d2,d7
 addq.l #1,d7              ;else that fnum+1 to d7 (= value returned)
 bra.s .good

.errr:
 movem.l d0-d1/a0-a1/a6,-(a7) ;if error, beep & recycle
 move.l xxp_intb(a4),a6
 move.l xxp_Screen(a4),a0
 jsr _LVODisplayBeep(a6)
 movem.l (a7)+,d0-d1/a0-a1/a6
 bra .rcyc

.good:
 bsr TLReqoff              ;close requester window, pop old window if any

.done:
 bsr TLWslof               ;clear all message buffers
 add.w #xxp_WPort+4,a7     ;remove dummy IntuiText
 move.l d7,(a7)            ;return code to stack d0

 movem.l (a7)+,d0-d7/a0-a6 ;D0=0 if bad/cancel, else 1+=choice
 move.l (a7)+,xxp_Help(a4)
 move.l (a7)+,xxp_strg(a4)
 rts

.str: dc.b 0
 dc.b 'Choose (&/or load) a font...       (Press <Help> for assistance)',0
 dc.b '0 Choose  View',0 ;2
 dc.b 'Font . currently viewing',0 ;3
 dc.b 'AaBbCc012;,!',0 ;4
 dc.b 'You are required to select a font...',0 ;5
 dc.b 'If you do not wish to select a font, press the <esc> key.',0 ;6
 dc.b 'The requester has at its left a list of fonts, numbered 0 to 9.',0 ;7
 dc.b 'Then, there are "Choose" & "View" buttons, followed by a button',0 ;8
 dc.b 'with the font name and height (if any) on it. If that button is',0 ;9
 dc.b 'blank, it does not currently exist, and you cannot currently',0 ;10
 dc.b 'choose it. You may click the font name and height button, to load',0
 dc.b 'another font. When you do, an ASL font selector comes up. If the',0
 dc.b 'button was not blank, the font that was there before will be',0 ;13
 dc.b 'replaced by the font you choose. If the font name & height button',0
 dc.b 'is recessed (font 0''s button is always recessed) then you cannot',0
 dc.b 'load/reload that font.',0 ;16
 dc.b 'If you click the "View" button of a font, some sample text in that',0
 dc.b 'font will appear in the big box at the right of the requester.',0 ;18
 dc.b 'If you click a "Choose" button, then you will thereby choose that',0
 dc.b 'font, and the requester will close. But if a choose button is',0 ;20
 dc.b 'recessed, you cannot choose that font, since its name and size',0 ;21
 dc.b 'button is currently blank.',0 ;22
 ds.w 0

*>>>> convert hex to ascii in hex format
; value in d0
; put to (a0)+
; d1 = format:  0=left justify  1-8 = 1-8 digits
TLHexasc16:
 tst.w d1                  ;go if left justify
 beq.s .ljst
 movem.l d0-d2,-(a7)       ;save all except a0 pushed past
 moveq #8,d2
 sub.l d1,d2
 lsl.w #2,d2
 rol.l d2,d0               ;roll past unshown digits
 subq.w #1,d1              ;go do digits
 bra.s .jdgt
.ljst:                     ;* left justify
 tst.l d0
 beq.s .zero               ;go if zero
 movem.l d0-d2,-(a7)
 moveq #8,d1               ;shift until a non-zero digit found
.ljtr:
 subq.w #1,d1
 rol.l #4,d0
 move.b d0,d2
 and.b #15,d2
 beq .ljtr
 ror.l #4,d0               ;d1 = remaining digits - 1
.jdgt:
 rol.l #4,d0               ;* get next digit
 move.b d0,d2
 and.b #15,d2
 add.b #'0',d2             ;make into ascii
 cmp.b #':',d2
 bcs.s .jcry
 add.b #'A'-':',d2
.jcry:
 move.b d2,(a0)+           ;put digit
 dbra d1,.jdgt
 movem.l (a7)+,d0-d2
 rts
.zero:                     ;* left justify, d0=0
 move.b #'0',(a0)+
 rts


*>>>> find if an assign exists
TLAssdev:
 movem.l d1-d7/a0-a6,-(a7)       ;save all regs except d0
 move.l xxp_dosb(a4),a6          ;a6=dosbase
 move.l #LDF_READ!LDF_ASSIGNS,d7 ;D7=flags
 move.l d7,d1
** Do NOT single step or breakpoint herein ***
 jsr _LVOLockDosList(a6)                    ;*  lock DOS list
 move.l d0,d1                               ;*  d1=list code
 move.l a4,d2                               ;*  d2=name (w'out :)
 move.l d7,d3                               ;*  d3=flags
 jsr _LVOFindDosEntry(a6)                   ;*  in dos list?
 tst.l d0                                   ;*  EQ if doesn't exist
 beq.s .no                                  ;*
 move.l d0,a0                               ;*  else, point to node
 move.l dol_Lock(a0),d1                     ;*  get its lock
 jsr _LVODupLock(a6)                        ;*  & duplicate it
.no:                                        ;*
 move.l d0,-(a7)                            ;*  save 0/duplicate lock
 move.l d7,d1                               ;*  reset flags
 jsr _LVOUnLockDosList(a6)                  ;*  unlock doslist
**********************************************
 move.l (a7)+,d0                  ;d0 is duplicate lock, or zero
 beq.s .quit                      ;quit if doesn't exist (when D0=0)
 move.l d0,d1
 move.l d1,-(a7)
 move.l a4,d2
 move.l #150,d3
 jsr _LVONameFromLock(a6)         ;put name in buff
 move.l (a7)+,d1
 jsr _LVOUnLock(a6)               ;unlock the duplicate lock
 moveq #-1,d0                     ;d0<>0 if exists
.quit:
 movem.l (a7)+,d1-d7/a0-a6
 rts

*>>>> set up xxp_Menu, given NewMenu structure in A0

; Note: the TLnm structure can be re-used - although it is modified by
; TLReqmenu, it can be re-called, and will not be re-modified; thus this
; does not stop the library from being re-entrant, but it must be in RAM.

TLReqmenu:
 movem.l d1-d7/a0-a6,-(a7) ;save all regs exc d0
 clr.l xxp_errn(a4)
 move.l xxp_AcWind(a4),a5
 move.l a0,a1              ;tidy up the NewMenu structure...
 move.l a0,a2              ;a2 saves a0
 sub.l a3,a3               ;(a3 will be string of hotkey letters in order)
.item:
 cmp.b #NM_END,gnm_Type(a1) ;done if NM_END
 beq.s .redi
 move.l gnm_Label(a1),d0   ;get label
 beq.s .hotky              ;go if none (can't happen?)
 cmp.l #1025,d0
 bcc.s .hotky              ;go if not 0<label<1025
 bsr TLStra0
 move.l a0,gnm_Label(a1)   ;else point label to that string number
.hotky:
 move.l gnm_CommKey(a1),d0 ;get hotkey
 beq.s .fwd
 cmp.l #1025,d0            ;go if not 0<hotkey<1025
 bcc.s .fwd
 move.l a3,d1              ;hotkeys already started?
 bne.s .nxky               ;yes, go
 bsr TLStra0               ;no, point a3 to hotkey string
 move.l a0,a3
.nxky:
 move.l a3,gnm_CommKey(a1) ;point to hotkey
 addq.l #1,a3              ;& bump hotkey pointer
.fwd:
 add.l #gnm_SIZEOF,a1      ;to next menu item
 bra .item
.redi:
 move.l a2,a0              ;NewMenu ok - restore A0
 subq.l #4,a7
 clr.l (a7)                ;(null taglist)
 move.l a7,a1
 move.l xxp_gadb(a4),a6
 jsr _LVOCreateMenusA(a6)
 move.l d0,xxp_Menu(a5)    ;create xxp_Menu
 addq.l #4,a7
 beq.s .bad1               ;go if can't (unlikely)
 move.l d0,a0
 move.l xxp_vi(a4),a1
 subq.l #4,a7
 clr.l (a7)                ;(null taglist)
 move.l a7,a2
 jsr _LVOLayoutMenusA(a6)  ;layout menus
 addq.l #4,a7
 tst.l d0
 beq.s .bad2               ;bad if can't (unlikely)
 moveq #-1,d0
 bra.s .quit
.bad1:                     ;bad - out of public memory
 addq.l #1,xxp_errn(a4)
 bra.s .bad
.bad2:                     ;bad - LayoutMenusA failed
 move.w #30,xxp_errn+2(a4)
.bad:
 moveq #0,d0
.quit:
 movem.l (a7)+,d1-d7/a0-a6 ;D0=0, EQ if bad
 rts

*>>>> attach xxp_Menu to xxp_Window (call Reqmenu first)
TLReqmuset:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;save all regs
 move.l xxp_AcWind(a4),a5
 move.l xxp_intb(a4),a6
 move.l xxp_Menu(a5),a1
 move.l xxp_Window(a5),a0
 jsr _LVOSetMenuStrip(a6)
 subq.w #1,xxp_Menuon(a5)
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

*>>>> detatch xxp_Menu from xxp_Window (call Reqmuset first)
TLReqmuclr:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;save all regs
 move.l xxp_AcWind(a4),a5
 tst.l xxp_Menu(a5)   ;go if menu does not exist/not attached
 beq.s .done
 tst.w xxp_Menuon(a5)
 beq.s .done
 move.l xxp_intb(a4),a6
 move.l xxp_Window(a5),a0
 jsr _LVOClearMenuStrip(a6)
 clr.w xxp_Menuon(a5)
.done:
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

*>>>> show information D0=1st str, D1=no. of strings
; D2:  1=ok box  2=ok & canc boxes   3=custom boxes in last str
TLReqinfo:
 move.l xxp_butx(a4),-(a7) ;save button data
 move.l xxp_buty(a4),-(a7)
 move.l xxp_butw(a4),-(a7)
 move.l xxp_buth(a4),-(a7)
 move.l xxp_btdx(a4),-(a7)
 move.l xxp_btdy(a4),-(a7)
 move.l xxp_butk(a4),-(a7)
 move.l xxp_butl(a4),-(a7)

 movem.l d0-d7/a0-a6,-(a7)
 move.l a7,xxp_Stak(a4)
 movem.l d0-d1,-(a7)    ;save input d0-d1
 move.l #.ok,-(a7)      ;addr of boxes string here
 sub.w #xxp_WPort+4,a7  ;create dummy part xxp_wsuw

 move.l a7,a5           ;a5 points to dummy IntuiText
 bsr TLReqredi          ;set pop window
 beq .bad               ;(go if init fails - unlikely)

 move.l xxp_pref(a4),a0 ;prefs to prfp
 move.l xxp_yinf(a0),xxp_prfp(a4)
 move.l xxp_yinf+4(a0),xxp_prfp+4(a4)
 cmp.l #2,d2            ;boxes str address to stack
 bcs.s .rcyc
 bne.s .boxs
 move.l #.oc,xxp_WPort+4(a7)
 bra.s .rcyc
.boxs:
 subq.w #1,d1
 subq.l #1,xxp_WPort+12(a7) ;(1 string less in both d1, & d1 in stack)
 add.w d1,d0
 bsr TLStra0
 move.l a0,xxp_WPort+4(a7)

.rcyc:
 move.l xxp_WPort+8(a7),d0 ;restore input d0,d1 - see if fits
 move.l xxp_WPort+12(a7),d1
 move.l xxp_WPort+4(a7),a0 ;set button size & num
 move.l xxp_AcWind(a4),-(a7)
 move.l a5,xxp_AcWind(a4)
 bsr TLButstr
 move.l (a7)+,xxp_AcWind(a4)

 bsr TLStra0            ;set D2 to max string width
 move.l a0,a3
 moveq #0,d2
 move.w d1,d0
 subq.w #1,d0
.scan:
 move.l a0,xxp_IText(a5)
 bsr TLTszdo            ;get size of next string
 cmp.w d4,d2
 bcc.s .maxw
 move.w d4,d2
.maxw:
 tst.b (a0)+
 bne .maxw
 dbra d0,.scan          ;until all string widths scanned

 move.l d2,d0           ;set D2 to requester width
 bsr TLButfix

 cmp.l xxp_Width(a4),d2 ;retry &c if too wide
 ble.s .gtht
 tst.b xxp_prfp+3(a4)   ;retry w. horz=0 if horz<>0
 beq.s .wdt1
 subq.b #1,xxp_prfp+3(a4)
 bra .rcyc
.wdt1:
 tst.w xxp_Tspc(a5)     ;retry w. Tspc=0 if Tspc<>0
 beq.s .wdt2
 subq.w #1,xxp_Tspc(a5)
 bra .rcyc
.wdt2:
 tst.w xxp_Fnum(a5)     ;retry w. Fnum=0 if Fnum<>0
 beq.s .gtht            ;(else, will be too big to fit)
.fon0:
 moveq #0,d0            ;attach font 0 to dummy xxp_wsuw
 moveq #0,d1            ;(will be passed on by TLReqon)
 moveq #0,d2
 bsr TLAnyfont
 bne .rcyc

.gtht:
 move.w d6,d3           ;set d3 = requester height
 mulu d1,d3             ;d3=character ht * lines
 addq.l #4,d3           ;d3=requester height (before buttons)
 move.l d3,xxp_buty(a4)
 clr.l xxp_btdy(a4)
 add.l xxp_buth(a4),d3
 moveq #0,d0
 move.b xxp_prfp+4(a4),d0  ;d0 = pref vert
 beq.s .htgt
 addq.w #1,d3           ;inc height by 1 if pref vert <> 0
.htgt:
 add.l d0,d3

 cmp.l xxp_Height(a4),d3 ;go if fits on screen
 ble.s .chek
 tst.b xxp_prfp+4(a4)   ;if not, redo with vert=0 if vert <>0
 beq.s .vtt1
 subq.b #1,xxp_prfp+4(a4)
 bra .rcyc
.vtt1:
 tst.w xxp_Fnum(a5)     ;redo with Fnum=0 if Fnum<>0
 bne .fon0              ;(else will be too big)

.chek:
 bsr TLReqchek          ;check req dims, &c
 beq .bad               ;go if won't fit

 tst.w xxp_ReqNull(a4)  ;go if ReqNull=0
 beq .wrap

 bsr TLReqon            ;open requester window
 beq .bad               ;go if can't
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)

 bsr TLButprt           ;draw buttons & text therein
 move.l xxp_WPort+4(a7),a0
 bsr TLButtxt
 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)

 move.l d1,d3             ;print strings
 subq.w #1,d3
 moveq #4,d0
 moveq #2,d1
.prnt:
 move.l a3,xxp_IText(a5)
 bsr TLText
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 add.w d6,d1
.eos:
 tst.b (a3)+
 bne .eos
 dbra d3,.prnt

 bsr TLHook2

.wait:
 move.l xxp_strg(a4),-(a7) ;if no help, attach default
 move.l xxp_Help(a4),-(a7)
 bne.s .wtdo
 move.l #.str,xxp_strg(a4)
 move.l #$00010003,xxp_Help(a4)
 cmp.w #1,xxp_butk+2(a4)
 beq.s .wtdo
 addq.w #3,xxp_Help(a4)
.wtdo:
 bsr TLWfront           ;get keyboard
 bsr TLKeyboard
 move.l (a7)+,xxp_Help(a4)
 move.l (a7)+,xxp_strg(a4)

 cmpi.l #2,xxp_butk(a4) ;bra according to number of buttons
 beq.s .wt2
 bcc.s .wt3

 cmp.b #$0D,d0         ;one button: return 1 if <Return>
 beq.s .rt1
 bra.s .wt3

.wt2:
 btst #6,d3            ;two buttons: return 1 if LfAm / v
 beq.s .wt3            ;             return 2 if LfAm / b
 cmp.b #'v',d0
 beq.s .rt1
 cmp.b #'b',d0
 beq.s .rt2
 bra.s .wt3

.rt1:
 moveq #1,d0
 bra.s .func

.rt2:
 moveq #2,d0
 bra.s .func

.wt3:
 sub.w #$80,d0          ;go if F1+
 bgt.s .func
 bne .wait              ;retry if not lmb

 bsr TLButmon           ;D0=which of buttons
 tst.w d0
 beq .wait              ;retry if none
 bra.s .clos

.func:
 cmp.l xxp_butk(a4),d0  ;accept F1+ if in range: F1+ sets D0=1+
 bgt .wait

.clos:
 bsr TLReqoff           ;close req window
 bra.s .wrap            ;return ok

.bad:
 moveq #0,d0            ;too big/can't open window

.wrap:
 move.w #-1,xxp_ReqNull(a4) ;leave ReqNull<>0
 bsr TLWslof
 tst.l d0               ;EQ, D0=0 if bad
 add.w #xxp_WPort+4,a7
 add.w #12,a7
 move.l d0,(a7)
 movem.l (a7)+,d0-d7/a0-a6

 move.l (a7)+,xxp_butl(a4) ;restore button data
 move.l (a7)+,xxp_butk(a4)
 move.l (a7)+,xxp_btdy(a4)
 move.l (a7)+,xxp_btdx(a4)
 move.l (a7)+,xxp_buth(a4)
 move.l (a7)+,xxp_butw(a4)
 move.l (a7)+,xxp_buty(a4)
 move.l (a7)+,xxp_butx(a4)
 tst.l d0                  ;EQ, D0=0 if bad
 rts

.str: dc.b 0
 dc.b 'This requester contains information for your perusal.',0 ;1
 dc.b 'When you have read it, click the "OK" button at the bottom',0 ;2
 dc.b 'of the requester.',0 ;3
 dc.b 'This requester contains information so you can choose.',0 ;5
 dc.b 'To make your choice, click one of the buttons at the bottom',0 ;6
 dc.b 'of the requester (or press F1+)(if 2 buttons Left Amiga v/b).',0 ;7

.ok: dc.b 'OK',0        ;boxes if D2=1
.oc: dc.b 'OK\Cancel',0 ;boxes if D2=2
 ds.w 0

*>>>> Display a set of lines with dynamically calculated contents
TLReqshow:

* On call:  D0=hail  D1= total lines  D2 = lines on window  D3 = topline
;           Set bit 31 of D2 for dumb seek, bits 31,30 of D2 for smart seek
;           A0 = Callback routine address

* User sets xxp_Hook with a callback routine...
;
; If TLReqshow wants to show a line, it sets D0 = linum
; Caller sends back:  A0 points to line
;
; If user clicks line, TLReqshow sends D0 = linum, with bit 31 set
; Caller sends back:  D0 < 0   for nothing
;                     D0 = 0   quit (quits "bad", with xxp_errn = 0)
;                     D0 = 1   redo no line comp'ed
;                     D0 = 2   redo with that line comp'ed
;                     D0 = 3   redo with new D1,D3
;
; Smart search, TLreqshow sets D0 = linum, D1: 1/2/3 = for/back/left
; Caller sends back:  D0 = -2  do dumb search
;                     D0 = -1  string (in xxp_patt) unfound
;                     D0 = 0+  = new topline

; TLReqshow - push calling regs, set xxp_Stak

 move.l xxp_butx(a4),-(a7) ;save button data
 move.l xxp_buty(a4),-(a7)
 move.l xxp_butw(a4),-(a7)
 move.l xxp_buth(a4),-(a7)
 move.l xxp_btdx(a4),-(a7)
 move.l xxp_btdy(a4),-(a7)
 move.l xxp_butk(a4),-(a7)
 move.l xxp_butl(a4),-(a7)

 move.l xxp_slix(a4),-(a7) ;save slider data
 move.l xxp_sliy(a4),-(a7)
 move.l xxp_sliw(a4),-(a7)
 move.l xxp_slih(a4),-(a7)
 move.l xxp_tops(a4),-(a7)
 move.l xxp_totl(a4),-(a7)
 move.l xxp_strs(a4),-(a7)
 move.l xxp_hook(a4),-(a7)

 movem.l d0-d7/a0-a6,-(a7) ;saves all except result in d0
 move.l a7,xxp_Stak(a4)    ;point to where caller regs stored
 clr.l xxp_errn(a4)        ;no error so far

; TLReqshow -  create requester window

 move.l a0,xxp_Hook(a4)    ;* input A0 = caller hook address, to xxp_Hook
 sub.w #xxp_WPort+4,a7     ;* create dummy part xxp_wsuw

 move.l a7,a5              ;a5 points to dummy IntuiText
 bsr TLReqredi             ;set pop window
 beq .bad0                 ;* go if TLReqredi fails - unlikely

 move.l xxp_pref(a4),a0    ;prefs to prfp
 move.l xxp_yshw(a0),xxp_prfp(a4)
 move.l xxp_yshw+4(a0),xxp_prfp+4(a4)

 bsr TLStrbuf              ;* input D0 = hail strnum; tfr hail to xxp_buff
 move.l d3,xxp_tops(a4)    ;* input D3 = init topline, to xxp_tops
 move.l d1,xxp_totl(a4)    ;* input D1 = total strings, to xxp_totl
 move.l #11,xxp_buth(a4)   ;set up data for drawing buttons
 move.l #206,xxp_butw(a4)  ;(buttons width = 206 if no seeking)
 move.l #3,xxp_butk(a4)    ;(3 buttons if not seeking)
 move.l #1,xxp_butl(a4)    ;(1 row of buttons)

 tst.l d2                  ;* bit 31 of d2 set? (yes = seek)
 bpl.s .nosk               ;go if no seeking
 bclr #31,d2               ;clear bit 31 of d2
 clr.b xxp_patt+31(a4)     ;xxp_patt+31 = 0 if dumb seek
 btst #30,d2               ;* bit 30 of d2 set? (yes = smart seek)
 beq.s .dumsk              ;go if dumb seeking
 bclr #30,d2               ;clear bit 30 of d2
 subq.b #1,xxp_patt+31(a4) ;xxp_patt+31 = -1 if smart seek
.dumsk:
 move.l #103,xxp_butw(a4)  ;(buttons width = 103 if seeking)
 move.l #6,xxp_butk(a4)    ;(6 buttons if seeking)
 clr.b xxp_patt(a4)        ;so far, no search pattern
.nosk:

 move.l d2,xxp_strs(a4)    ;* input D2 = strs on window, to xxp_strs
 move.l d2,d3
 move.l #640,d2            ;d2=req width (always 640)
 lsl.l #3,d3
 add.l #11,d3              ;d3=req height without bot butts (8 * D2 + 11)
 clr.l xxp_butx(a4)        ;(buttons xpos = 0)
 move.l xxp_butw(a4),xxp_btdx(a4) ;(buttons dx = width, i.e. all touch)
 clr.l xxp_btdy(a4)        ;(buttons dy =0, undefined since 1 row)
 move.l d3,xxp_buty(a4)    ;(buttons ypos = 8 * D2 + 11)
 add.l #11,d3              ;d3=req height (8 * D2 + 22)
 move.l a4,xxp_IText(a5)   ;set for printing

 bsr TLReqchek             ;* fix requester dims, &c
 beq .bad1                 ;* go if TLReqchek fails (only if too big D2)

 tst.w xxp_ReqNull(a4)     ;* quit if ReqNull = 0
 beq .null

 bsr TLReqon               ;* create requester window
 beq .bad0                 ;quit if can't (out of chip ram)
 move.l xxp_AcWind(a4),a5  ;a5 now points to actual window

 clr.w xxp_Tspc(a5)        ;Reqshow uses Fnum=11 Fsty=0 Tspc=0
 moveq #11,d0
 move.l xxp_FSuite(a4),a0
 tst.l xxp_fsiz*11(a0)     ;or, Fnum=0 if no font 11, or font 8 height <> 8
 beq.s .fnt0
 cmp.w #8,xxp_fsiz*11+4(a0)
 beq.s .fnt8
.fnt0:
 moveq #0,d0
.fnt8:
 move.l d0,d3              ;recall fnum
 moveq #0,d1               ;attach font
 moveq #0,d2
 bsr TLNewfont
 bne.s .fnto               ;go if success
 tst.w d3
 bne .fnt0                 ;if can't, retry if wasn't font 0
 bra .bad0                 ;bad if can't even open font 0 (impossible?)
.fnto:

 move.l xxp_FSuite(a4),a0  ;get font, ensure fixed
 mulu #xxp_fsiz,d3
 beq.s .fixt               ;(always fixed width 8 if font 0)
 add.l d3,a0
 move.l xxp_plain(a0),a2   ;a2 = font
 btst #5,tf_Flags(a2)      ;reject font if proportional
 bne .fnt0

 move.w tf_XSize(a2),d0    ;set xxp_rinf,slix,sliw
 bne.s .some
.fixt:
 moveq #8,d0               ;(set 8 if 0 - can't happen?)
.some:
 move.l #622,d1            ;minimum slider width 18
 divu d0,d1                ;d1 = chrs that will fit
 and.l #$0000FFFF,d1
 mulu d1,d0                ;d0 = total chrs width
 add.l a4,d1
 move.l d1,xxp_rinf(a4)    ;set rinf = buff data cutoff point
 addq.l #2,d0
 move.l d0,xxp_slix(a4)    ;set slix
 neg.l d0
 add.l #640,d0
 move.l d0,xxp_sliw(a4)    ;set sliw

 moveq #4,d0               ;print hail
 moveq #2,d1
 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 bsr TLText

 bsr TLButprt              ;draw buttons

 lea .prmp0,a0             ;draw buttono text
 cmp.l #3,xxp_butk(a4)
 beq.s .butt
 lea .prmp1,a0
.butt:
 bsr TLButtxt              ;draw button text

 clr.l xxp_sliy(a4)        ;set up slider
 move.l xxp_reqh(a4),xxp_slih(a4)

 move.l #.echo,xxp_hook(a4) ;TLSlider callback hook to .echo

; TLReqshow - recycle here if new topline

.rcyc:
 move.l xxp_Stak(a4),-(a7) ;(preserve Stak for caller of TLReqshow)
 bsr TLSlider              ;redraw lines in window, slider (calls .echo)
 move.l (a7)+,xxp_Stak(a4)

; TLReqshow - recycle here to wait for input

.wait:
 move.l xxp_Help(a4),-(a7) ;attach default string if required
 move.l xxp_strg(a4),-(a7)
 tst.l xxp_Help(a4)        ;go if help set
 bne.s .wtdo
 move.l #.strs,xxp_strg(a4) ;else use default help
 move.w #1,xxp_Help(a4)
 move.w #20,xxp_Help+2(a4)
 cmp.l #6,xxp_butk(a4)
 beq.s .wtdo
 subq.w #5,xxp_Help+2(a4)
.wtdo:
 bsr TLWfront
 bsr TLKeyboard            ;wait for keyboard (discards mouseups)
 move.l (a7)+,xxp_strg(a4)
 move.l (a7)+,xxp_Help(a4)


; TLReqshow - process keyboard input

 cmp.b #$1B,d0             ;quit if Esc
 beq .good
 cmp.b #$8E,d0             ;up arrow
 beq .up
 cmp.b #$8F,d0             ;down arrow
 beq .down
 cmp.b #$80,d0
 bne .wait                 ;discard if not mousedown
.clik:                     ;* user has pressed lmb
 move.l xxp_Stak(a4),-(a7) ;keep xxp_Stak for caller to TLReqshow
 bsr TLSlimon              ;do slider if clicked
 move.l (a7)+,xxp_Stak(a4)
 tst.l d0
 bne .wait

 move.l d2,d0              ;else, see if a line clicked
 sub.w #11,d0
 bcs .wait
 lsr.l #3,d0
 cmp.l xxp_strs(a4),d0     ;d0=line rel to window
 bcs .clikt                ;go if a line clicked

 bsr TLButmon              ;see if a button clicked
 beq .wait                 ;go if not
 cmp.w #2,d0
 bcs .strt                 ;go if start button
 beq .endl                 ;go if end button
 cmp.l #3,xxp_butk(a4)
 beq .good                 ;quit if only 3 buttons (=can't seek)
 cmp.w #6,d0
 bcs .seek                 ;go if seek fore/back/left
 bra .good                 ;go if quit

; TLReqshow - line clicked

.clikt:                    ;D0=line num clicked rel to tops
 add.l xxp_tops(a4),d0     ;D0=line no. clicked
 cmp.l xxp_totl(a4),d0     ;go if no such line
 bcc .wait
 bset #31,d0               ;set bit 31 to show Hook that clicked
 movem.l d0/a4-a5,-(a7)
 move.l xxp_Hook(a4),a0
 jsr (a0)
 move.l d0,d2              ;D2 = code returned by Hook
 movem.l (a7)+,d0/a4-a5
 bmi .wait                 ;if hook = <0, do nothing
 beq .bad2                 ;if hook = 0, quit "bad" but with xxp_errn=0
 bclr #31,d0               ;D0 = line clicked
 move.l #-1,xxp_lcom(a4)   ;nothing as yet comp
 cmp.l #2,d2
 bcs .rcyc                 ;if hook = 1, redo w'out comp
 bne.s .rdrw
 move.l d0,xxp_lcom(a4)    ;if hook = 2, redo with comp
 bra .rcyc
.rdrw:                     ;if hook = 3, redraw with new D1,D3 (& no comp)
 move.l d1,xxp_totl(a4)
 move.l d3,xxp_tops(a4)
 bra .rcyc

; TLReqshow - up arrow pressed

.up:
 btst #0,d3                ;if shift, -> up a window full
 bne.s .upw
 tst.l xxp_tops(a4)        ;ignore if already at top
 beq .wait
 subq.l #1,xxp_tops(a4)    ;dec topline
 bra .rcyc
.upw:                      ;* up a window full
 move.l xxp_tops(a4),d0
 beq .wait                 ;ignore if already at top
 sub.l xxp_strs(a4),d0
 addq.l #1,d0              ;allow 1 line overlap
 bpl.s .upwc
 moveq #0,d0
.upwc:
 move.l d0,xxp_tops(a4)    ;re-do with new xxp_tops
 bra .rcyc

; TLReqshow - down arrow pressed

.down:                     ;* down arrow
 move.l xxp_tops(a4),d0
 addq.l #1,d0              ;d0 = proposed next topline
 cmp.l xxp_totl(a4),d0
 bcc .wait                 ;ignore if past end
 btst #0,d3
 bne.s .dnw                ;down a window full if shift
 move.l d0,xxp_tops(a4)    ;else, down a line
 bra .rcyc
.dnw:                      ;* down a window full
 move.l xxp_strs(a4),d7
 subq.l #1,d7
 add.l d7,d0
.dncu:
 subq.l #1,d0              ;allow 1 line overlap
 cmp.l xxp_totl(a4),d0
 bcc .dncu
 move.l d0,xxp_tops(a4)    ;set new xxp_tops
 bra .rcyc

; TLReqshow - end button clicked

.endl:
 move.l xxp_totl(a4),d0
 sub.l xxp_strs(a4),d0
 bcc .skgd

; TLReqshow - start button clicked

.strt:
 moveq #0,d0
 bra .skgd

; TLReqshow - seek fwd/back/left clicked

.seek:                     ;d0: 3=fore 4=back 5=left
 bsr .rqstr                ;get string sought to xxp_patt
 tst.b xxp_patt(a4)
 beq .wait                 ;go if cancel/null
 bsr TLBusy
 move.l d0,d1              ;d1 = 3/4/5 = fore/back/left
 tst.b xxp_patt+31(a4)     ;go if dumb seek
 beq.s .dumb

 move.l xxp_tops(a4),d0    ;* smart search: start from tops
 bset #31,d0
 bset #30,d0               ;set bits 31,30
 move.l xxp_Hook(a4),a0
 movem.l d1/a4-a5,-(a7)
 jsr (a0)                  ;call hook
 movem.l (a7)+,d1/a4-a5
 addq.l #2,d0
 beq.s .dumb               ;do dumb search after all if d0 = -2
 subq.l #1,d0
 beq .unsk                 ;can't find if d0 = -1
 subq.l #1,d0
 bra .skgd                 ;else, found - result in D0

.dumb:                     ;* dumb search: d1 = 3/4/5
 move.l a4,a3
 add.w #xxp_patt,a3
 move.b (a3)+,d7           ;a3=sought+1, d7=1st chr
 cmp.w #4,d1
 bcs.s .fore               ;go if seek fore
 beq.s .back               ;go if seek back

 moveq #0,d0               ;* seek left...
.skln:
 movem.l d0/d7/a3-a5,-(a7)
 move.l xxp_Hook(a4),a0
 jsr (a0)                  ;get next
 movem.l (a7)+,d0/d7/a3-a5
 cmp.b (a0)+,d7            ;frst chr same?
 bne.s .skld               ;no, to next line
 bsr .skcm                 ;matched rest
 beq .skgd                 ;go if got
.skld:
 addq.l #1,d0              ;to next line
 cmp.l xxp_totl(a4),d0
 bne .skln                 ;& try it
 bra .unsk                 ;bad if no more

.fore:                     ;* seek fore
 move.l xxp_tops(a4),d0    ;start from tops
 bra.s .forf
.forn:
 bsr .skcl                 ;see if line matches
 beq.s .skgd               ;go if yes
.forf:
 addq.l #1,d0              ;fore a line
 cmp.l xxp_totl(a4),d0
 bne .forn                 ;& try it
 bra.s .unsk               ;bad if no more

.back:                     ;seek back
 move.l xxp_tops(a4),d0    ;start from tops
 bra.s .bacb
.bakn:
 bsr .skcl                 ;see if line matches
 beq.s .skgd               ;go if yes
.bacb:
 subq.l #1,d0              ;back a line
 bcc .bakn                 ;& try it
 bra.s .unsk               ;bad if no more

.skgd:                     ;* seek found
 move.l d0,xxp_tops(a4)
 bsr TLUnbusy
 bra .rcyc

.unsk:                     ;* seek unfound
 bsr TLUnbusy
 move.l xxp_intb(a4),a6    ;beep
 move.l xxp_Screen(a4),a0
 jsr _LVODisplayBeep(a6)
 bra .wait

; TLReqshow - Quit bad

.bad0:                    ;* bad 0 - out of chip ram
 addq.l #2,xxp_errn(a4)
 moveq #0,d0
 bra.s .wrpc
.bad1:                    ;* bad 1 - window won't fit (bad input D2)
 move.w #21,xxp_errn+2(a4)
 moveq #0,d0
 bra.s .wrpc
.bad2:                    ;* "bad" 2 - hook returns quit (leaves xxp_errn=0)
 moveq #0,d0
 bra.s .wrap

; TLReqshow - Quit good

.null:                     ;* return good: xxp_ReqNull set
 moveq #-1,d0
 bra.s .wrpc
.good:                     ;* return good: Esc or Quit button pressed
 moveq #-1,d0
.wrap:
 bsr TLReqoff              ;requester off
.wrpc:
 bsr TLWslof               ;clear keyboard queues
 move.w #-1,xxp_ReqNull(a4) ;always return with xxp_ReqNull off
 add.w #xxp_WPort+4,a7     ;clear stack
 move.l d0,(a7)
 movem.l (a7)+,d0-d7/a0-a6

 move.l (a7)+,xxp_hook(a4) ;restore slider data
 move.l (a7)+,xxp_strs(a4)
 move.l (a7)+,xxp_totl(a4)
 move.l (a7)+,xxp_tops(a4)
 move.l (a7)+,xxp_slih(a4)
 move.l (a7)+,xxp_sliw(a4)
 move.l (a7)+,xxp_sliy(a4)
 move.l (a7)+,xxp_slix(a4)

 move.l (a7)+,xxp_butl(a4) ;restore button data
 move.l (a7)+,xxp_butk(a4)
 move.l (a7)+,xxp_btdy(a4)
 move.l (a7)+,xxp_btdx(a4)
 move.l (a7)+,xxp_buth(a4)
 move.l (a7)+,xxp_butw(a4)
 move.l (a7)+,xxp_buty(a4)
 move.l (a7)+,xxp_butx(a4)

 tst.l d0                  ;EQ, D0=0 if bad
 rts

;*********************** TLReqshow Subroutines *************************

; TLReqshow Subroutine - compare a whole line

.skcl:                     ;** compare whole line
 movem.l d0/d7/a3-a5,-(a7) ;d0=linum, d7=1st chr, a3=rest of str
 move.l xxp_Hook(a4),a0
 jsr (a0)
 movem.l (a7)+,d0/d7/a3-a5
.skcf:
 tst.b (a0)                ;return NE if eol
 beq.s .skcq
 cmp.b (a0)+,d7            ;cmp next chr
 bne .skcf                 ;go if unmatched
 bsr.s .skcm               ;compare rest
 bne .skcf                 ;go if unmatched
 rts                       ;return EQ if matched
.skcq
 moveq #-1,d1              ;NE if unmatched
 rts

; TLReqshow Subroutine - compare a line from (A0)

.skcm:                     ;** compare line from (a0)
 move.l a0,a1              ;use a1,a2
 move.l a3,a2
.skcp:
 tst.b (a2)                ;go if end of patt (matched)
 beq.s .skcg
 cmpm.b (a2)+,(a1)+        ;cmp next chr
 beq .skcp                 ;go unless diff
.skcg:                     ;EQ if matched
 rts

; TLReqshow Subroutine - get string for seeking

.rqstr:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l a4,xxp_IText(a5)   ;point to buffer for echoing
 moveq #12,d0              ;make area for input
 moveq #14,d1
 move.l #264,d2
 moveq #19,d3
 moveq #0,d4
 move.b xxp_prfp+1(a4),d4
 bset #29,d0
 bsr TLReqarea
 bclr #29,d0
 bsr TLReqbev
 lea .prmp2,a0             ;get instructions
 move.l a4,a1
.rqtf:
 move.b (a0)+,(a1)+
 bne .rqtf
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 move.b xxp_prfp+1(a4),xxp_BackPen(a5)
 moveq #16,d0
 moveq #16,d1
 bsr TLText                ;print instructions
 clr.b (a4)                ;tags &c for TLReqedit
 addq.l #8,d1
 sub.w #32,a7
 move.l a7,a0
 move.l #xxp_xtext,(a0)+
 move.l a4,(a0)+
 move.l #xxp_xmaxt,(a0)+
 move.l #240,(a0)+
 move.l #xxp_xmaxc,(a0)+
 move.l #28,(a0)+
 clr.l (a0)
 move.l a7,a0
 bsr TLWfront
 jsr TLReqedit
 add.w #32,a7
 tst.b (a4)
 beq.s .rqdn               ;if null input, use old patt
 move.l a4,a0              ;else, put input into patt
 move.l a4,a1
 add.l #xxp_patt,a1
.rqt2:
 move.b (a0)+,(a1)+
 bne .rqt2
.rqdn:
 bsr .echo                 ;reshow overlaid lines
 movem.l (a7)+,d0-d7/a0-a6
 rts

; TLReqshow - smooth redraw for xxp_Hook

.echo:
 moveq #11,d1              ;d1 = ypos
 move.l xxp_tops(a4),d2    ;d2 = linum
 move.l xxp_totl(a4),d3    ;d3 = total lines
 move.l xxp_lcom(a4),d4    ;d4 = comp line (if any)
 move.w xxp_strs+2(a4),d5  ;d5 counts lines
 subq.w #1,d5

 move.l xxp_rinf(a4),a3    ;a3 = extent of buff data lines

.eclc:
 move.l a4,a1              ;send blank line if past last line
 cmp.l d3,d2
 bcc.s .ecev

 movem.l d1-d6/a3-a5,-(a7) ;get line
 move.l xxp_Hook(a4),a0
 move.l d2,d0
 jsr (a0)
 movem.l (a7)+,d1-d6/a3-a5

 move.l a4,a1              ;tfr line to buff
.ectf:
 move.b (a0)+,(a1)+
 bne .ectf

 subq.l #1,a1              ;blank fill until past rinf
 move.l a1,d0
 lsr.w #1,d0
 bcc.s .ecev
 move.b #' ',(a1)+
.ecev:
 move.l #'    ',(a1)+
 cmp.l a3,a1
 bcs .ecev

 clr.b (a3)                ;chop off to length rinf

 moveq #2,d0               ;d0 = xpos
 move.l a4,xxp_IText(a5)   ;point to text
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 cmp.l d4,d2
 bne.s .ecpr
 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)
.ecpr:
 bsr TLText                ;print line

 addq.w #8,d1              ;bump ypos
 addq.l #1,d2              ;bump linum
 dbra d5,.eclc
 rts

********************** TLReqshow - Data Section **********************

.prmp0: dc.b 'Start\End\Quit',0
.prmp1: dc.b 'Start\End\Seek fore\Seek back\Seek left\Quit',0
.prmp2: dc.b 'String sought:',0

.strs: dc.b 0 ;dummy strings for help
 dc.b 'Use the slider at the right for scanning the strings displayed.',0
 dc.b 0
 dc.b 'If appropriate, you can click a line to highlight it, or again',0
 dc.b 'to remove the highlight. One line at a time can be highlighted.',0
 dc.b 0
 dc.b 'The up and down arrows move up and down a step. You can click',0
 dc.b 'them with the shift key held down to move up/down a window-full.',0
 dc.b 0
 dc.b 'You can also press the up/down arrow buttons to move up/down, and',0
 dc.b 'with shift to move up/down a window-full. If you are looking at',0
 dc.b 'a very large array of lines, then use the slider for coarse',0
 dc.b 'positioning, and up/down arrow buttons with shift for fine tuning.',0
 dc.b 0
 dc.b 'The Start and End buttons go to start and end as expected. Press',0
 dc.b 'the Quit button or press Esc to exit from the requester.',0
 dc.b 0
 dc.b 'The "Seek fore" & "Seek back" buttons allow you to input a string',0
 dc.b 'which will be sought fwd or back. If unfound, there will be a',0
 dc.b 'beep. You can also press "Seek left" which will find the first',0
 dc.b 'line after the start with the sought string at its left.',0

 ds.w 0

*>>>> show data until TLReqoff is called  D0=1st string, D1=no. of strings
TLData:
 movem.l d0-d7/a0-a6,-(a7) ;save all except result in d0
 move.l a7,xxp_Stak(a4)
 sub.w #xxp_WPort+4,a7     ;create dummy part xxp_wsuw

 move.l a7,a5
 bsr TLReqredi             ;set things up
 beq .bad                  ;bad if can't (unlikely)

 move.l xxp_pref(a4),a0    ;get pref data
 move.l xxp_ydat(a0),xxp_prfp(a4)
 move.l xxp_ydat+4(a0),xxp_prfp+4(a4)

 move.l xxp_WPort+4(a7),d0 ;find required width of the requester (stack d0)
 bsr TLStra0               ;point a0 to 1st string
 move.l xxp_WPort+8(a7),d0 ;get stack d1
 move.l d0,d3              ;d3 = no. of strings
 subq.w #1,d0              ;d0 = no. of strings-1
 moveq #0,d2               ;set d2 to max string width
.scan:
 move.l a0,xxp_IText(a5)
 bsr TLTszdo               ;d4 = size of next string; d6 = height
 cmp.w d2,d4
 bcs.s .maxw
 move.w d4,d2
.maxw:
 tst.b (a0)+               ;to next string
 bne .maxw
 dbra d0,.scan             ;until all string widths scanned
 addq.w #8,d2              ;d2 = requester width
 mulu d6,d3                ;d3 = requester height
 addq.w #4,d3
 bsr TLReqchek             ;check size ok
 beq .bad                  ;bad if not
 tst.w xxp_ReqNull(a4)     ;go if null
 beq .null
 bsr TLReqon               ;requester on
 beq .bad                  ;bad if can't
 move.l xxp_WPort+4(a7),d4 ;d4 counts string number
 move.l xxp_WPort+8(a7),d7 ;d7 counts strings
 subq.w #1,d7
 moveq #2,d5               ;d5 = ypos  d6 = string height
 move.l xxp_AcWind(a4),a5
 move.b xxp_prfp+1(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
.prnt:
 move.l d4,d0              ;next string to buff
 bsr TLStrbuf
 moveq #4,d0               ;print at 4,d5
 move.l d5,d1
 bsr TLText
 addq.w #1,d4              ;bump string num
 add.w d6,d5               ;bump ypos
 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)
 move.b xxp_prfp(a4),xxp_BackPen(a5)
 dbra d7,.prnt             ;until all done

.good:
 bsr TLHook2

.null:
 moveq #-1,d0              ;report success
 bra.s .done

.bad:
 moveq #0,d0

.done:
 move.w #-1,xxp_ReqNull(a4)
 add.w #xxp_WPort+4,a7     ;remove workspace    ***  User must call
 move.l d0,(a7)            ;result in stack d0  ***  TLReqoff
 movem.l (a7)+,d0-d7/a0-a6 ;D0=-1 ok, D0=0 bad
 rts

*>>>> make a requester window  a5=dummy xxp_wsuw entry,  uses xxp_reqx,y,w,h
TLReqon:
 movem.l d0-d7/a0-a4,-(a7) ;save all regs exc a5 (points a5 to WSuite)
 clr.l xxp_errn(a4)

 moveq #10,d0              ;open window 10 for requester
 move.l xxp_reqx(a4),d1
 move.l xxp_reqy(a4),d2
 move.l xxp_reqw(a4),d3
 move.l xxp_reqh(a4),d4
 move.l d3,d5
 move.l d4,d6
 moveq #1,d7               ;usual flags for requester
 bsr TLWindow              ;open requester window
 beq.s .bad                ;go if can't

 move.l a5,a0              ;a0 = dummy xxp_wsuw entry
 move.l xxp_AcWind(a4),a5  ;point to real xxp_wsuw entry entry
 move.w xxp_Tspc(a0),xxp_Tspc(a5)
 moveq #0,d0
 move.w xxp_Fnum(a0),d0    ;attach dummy Wsuw entry to req window
 moveq #0,d1
 move.w xxp_Fsty(a0),d1
 moveq #0,d2
 bsr TLNewfont

 moveq #0,d0               ;draw background & border
 moveq #0,d1
 move.l xxp_reqw(a4),d2
 move.l xxp_reqh(a4),d3
 moveq #0,d4
 move.b xxp_prfp(a4),d4    ;background colour from xxp_prfp
 bset #29,d0
 bsr TLReqarea
 bclr #29,d0
 bsr TLReqbev

 move.l xxp_hook1(a4),d0   ;call xxp_hook1, if any
 beq.s .good
 movem.l a0/a2-a6,-(a7)
 move.l d0,a0
 jsr (a0)
 movem.l (a7)+,a0/a2-a6
 clr.l xxp_hook1(a4)

.good:
 moveq #-1,d0              ;NE if ok
 bra.s .done

.bad:
 addq.l #2,xxp_errn(a4)
 moveq #0,d0

.done:
 movem.l (a7)+,d0-d7/a0-a4 ;EQ, errn<>0 if bad
 rts

*>>>> close requester window
TLReqoff:
 movem.l d0/a5,-(a7)      ;save all
 moveq #0,d0
 move.w xxp_Pop(a4),d0    ;get window to be popped
 move.l d0,a5
 moveq #10,d0             ;close requester window
 bsr TLWsub
 move.l a5,d0
 move.w d0,xxp_Active(a4) ;restore xxp_Active
 bmi.s .quit              ;go if no window was active
 bsr TLWpop               ;pop formerly active window
.quit:
 movem.l (a7)+,d0/a5
 rts

*>>>> check that requester size is ok    D2,D3=proposed width,height
TLReqchek:
 movem.l d0-d4/a0/a5,-(a7) ;saves all
 clr.l xxp_errn(a4)
 moveq #0,d0               ;set d0,d1=left, top
 moveq #0,d1
 tst.w xxp_Pop(a4)         ;go if no calling window, when use screen topleft
 bmi.s .ncur
 move.l xxp_AcWind(a4),a5  ;posn rel to calling window
 move.l xxp_Window(a5),a0
 move.w wd_LeftEdge(a0),d0
 move.w wd_TopEdge(a0),d1
 add.w xxp_ReqLeft(a5),d0
 add.w xxp_ReqTop(a5),d1
.ncur:
 move.l xxp_Width(a4),d4   ;check width
 sub.w d2,d4
 bcs.s .fixy
 cmp.w d4,d0
 bcs.s .hght
 move.w d4,d0              ;adjust left if required
.hght:
 move.l xxp_Height(a4),d4  ;check height
 sub.w d3,d4
 bcs.s .fixy
 cmp.w d4,d1
 bcs.s .fixh
 move.w d4,d1              ;adjust height if required
.fixh:
 move.l d0,xxp_reqx(a4)
 move.l d1,xxp_reqy(a4)
 move.l d2,xxp_reqw(a4)
 move.l d3,xxp_reqh(a4)
 move.l xxp_hook0(a4),d0   ;go if xxp_hook0 unset
 beq.s .hook
 movem.l d5-d7/a1-a4/a6,-(a7) ;call xxp_hook0
 move.l d0,a0
 jsr (a0)
 movem.l (a7)+,d5-d7/a1-a4/a6
 clr.l xxp_hook0(a4)
.hook:
 moveq #-1,d4
 movem.l (a7)+,d0-d4/a0/a5
 rts
.fixy:
 move.w #21,xxp_errn+2(a4)   ;if bad, errn=21
 moveq #0,d4
 movem.l (a7)+,d0-d4/a0/a5 ;EQ if bad
 rts

*>>>> call xxp_hook2 (if applic) when requester drawn
TLHook2:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l xxp_hook2(a4),d0   ;go if no xxp_hook2
 beq.s .done
 move.l d0,a0              ;call xxp_hook2
 jsr (a0)
.done:
 movem.l (a7)+,d0-d7/a0-a6
 clr.l xxp_hook2(a4)
 rts

*>>>> print buttons
TLButprt:
 movem.l d0-d5,-(a7)       ;saves all
 move.l xxp_buty(a4),d1    ;d0-d3=TLReqbev data
 move.l xxp_butw(a4),d2
 move.l xxp_buth(a4),d3
 move.l xxp_butl(a4),d5    ;d5 counts rows
 subq.w #1,d5
.butr:
 move.l xxp_butx(a4),d0
 move.l xxp_butk(a4),d4    ;d4 counts colms
 subq.w #1,d4
.butn:
 bsr TLReqbev
 add.l xxp_btdx(a4),d0
 dbra d4,.butn
 add.l xxp_btdy(a4),d1
 dbra d5,.butr
 movem.l (a7)+,d0-d5       ;xxp_errn=0 if drawn ok
 rts


*>>>> print txt in requester buttons  a0=string w. \ separators
;Caution: uses jam1
TLButtxt:
 movem.l d0-d7/a0-a6,-(a7) ;save all regs
 move.l xxp_AcWind(a4),a5
 move.l xxp_FrontPen(a5),-(a7)
 move.l xxp_IText(a5),-(a7)
 sub.w #84,a7              ;space to tfr strings

 move.l a7,xxp_IText(a5)

 move.b #RP_JAM1,xxp_DrawMode(a5) ;use jam1 in case tspc operlaps end of box

 move.l a7,a2
 add.w #81,a2              ;a2 = limit of stack string space

 move.l xxp_buty(a4),d1    ;d1=ypos
 move.l xxp_butl(a4),d5    ;d5 counts rows
 subq.w #1,d5

.butr:                     ;print next row...
 move.l xxp_butx(a4),d0    ;d0=xpos
 move.l xxp_butk(a4),d7    ;d7 counts cols
 subq.w #1,d7

.butn:                     ;print next button in row...
 move.l a7,a1
.str:
 move.b (a0)+,(a1)+        ;tfr next string to stack
 beq.s .xdim
 cmp.b #'\',-1(a1)
 beq.s .xdmc
 cmp.l a2,a1
 bcs .str
 subq.l #1,a1              ;max len = 80 chrs
 bra .str
.xdim:
 subq.l #1,a0              ;backspace if eos in case not enough strings
.xdmc:
 clr.b -(a1)               ;delimit string

 movem.l d5/d7,-(a7)       ;size string
 bsr TLTszdo
 sub.w xxp_Tspc(a5),d4
 movem.l (a7)+,d5/d7

 move.l xxp_butw(a4),d2    ;centre text horizontally
 sub.w d4,d2
 lsr.w #1,d2
 add.w d2,d0

 move.l xxp_buth(a4),d3    ;centre text vertically
 sub.w d6,d3
 lsr.w #1,d3
 add.w d3,d1

 bsr TLText                ;print text
 sub.w d2,d0
 sub.w d3,d1

 add.l xxp_btdx(a4),d0     ;point to next xpos, do next button
 dbra d7,.butn

 add.l xxp_btdy(a4),d1     ;point to next ypos, do next row
 dbra d5,.butr

 add.w #84,a7
 move.l (a7)+,xxp_IText(a5)
 move.l (a7)+,xxp_FrontPen(a5)
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> set button size & number data  a0=string w. \ separators
TLButstr:
 movem.l d0-d7/a0-a6,-(a7) ;saves all regs (IntuitText now at 64(A7))
 move.l xxp_AcWind(a4),a5
 move.l xxp_IText(a5),-(a7)
 sub.w #84,a7              ;buffer to hold strings

 move.l a7,xxp_IText(a5)
 move.l a7,a2
 add.w #81,a2              ;max string len 80 chrs

 moveq #0,d0               ;d0 holds number
 moveq #0,d1               ;d1 holds max width

.butn:                     ;examine next button
 addq.w #1,d0
 move.l a7,a1
.str:
 move.b (a0)+,(a1)+        ;tfr to buffer
 beq.s .xsiz
 cmp.b #'\',-1(a1)
 beq.s .xsiz
 cmp.l a2,a1
 bcs .str
 subq.l #1,a1              ;max len 80 chrs
 bra .str
.xsiz:
 clr.b -(a1)

 bsr TLTszdo               ;get text width
 cmp.w d4,d1
 bcc.s .xmax
 move.w d4,d1              ;widest to d1
.xmax:

 tst.b -1(a0)              ;until eos
 bne .butn

 addq.l #8,d1              ;d1 = button width of widest
 addq.l #2,d6              ;d6=button height
 move.l d1,xxp_butw(a4)
 move.l d6,xxp_buth(a4)
 move.l d0,xxp_butk(a4)    ;cols = no. of strings } Assumes horizontal row.
 move.l #1,xxp_butl(a4)    ;rows = 1              } Swap these if vertical.

 add.w #84,a7
 move.l (a7)+,xxp_IText(a5)
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> spread horz buttons; sets D2 to required wdth (on call, d0=strng wdth)
TLButfix:
 movem.l d0-d1,-(a7)       ;save all exc d2

.try:
 move.l (a7),d0            ;d0 = string width
 moveq #0,d1               ;set d1 = pref horz, butw+d1 in xxp_btdx
 move.b xxp_prfp+3(a4),d1
 addq.l #8,d0              ;add 8 to string for edge clearances
 move.l d1,xxp_butx(a4)    ;butx = 0 or d1+2
 beq.s .tryc
 addq.l #2,xxp_butx(a4)    ;if d1<>0, bump also past lhs border
.tryc:

 move.l xxp_butw(a4),d2    ;set btdx = D2 = (butw + horz)
 add.l d1,d2
 move.l d2,xxp_btdx(a4)

 mulu xxp_butk+2(a4),d2    ;set D2 = tot width = (butw + horz)*butk + horz
 add.l d1,d2
 tst.l d1
 beq.s .totl
 addq.l #4,d2              ;if horz<>0, add 4
.totl:                     ;D2 = total width implied by butw,horz & butk

 cmp.l d0,d2               ;done if total width >= string width + 8
 bcc.s .done

 sub.l d2,d0               ;else, distribute excess (rounded up) to butw
 add.l xxp_butk(a4),d0
 subq.l #1,d0
 divu xxp_butk+2(a4),d0
 add.w d0,xxp_butw+2(a4)
 bra .try                  ;& try again

.done:
 movem.l (a7)+,d0-d1       ;result in D2
 rts

*>>>> set D0=0, or 1+ if mousex,y among buttons (on call D1,d2 = pnter pos)
TLButmon:
 movem.l d1-d3/a5,-(a7)    ;save all exc result in d0
 move.l xxp_AcWind(a4),a5
 sub.w xxp_LeftEdge(a5),d1
 sub.w xxp_TopEdge(a5),d2

 moveq #1,d0               ;d0 counts button num (1+)

 sub.w xxp_butx+2(a4),d1   ;d1 rel to left of buttons
 bmi.s .no                 ;go if pointer left of buttons
 sub.w xxp_buty+2(a4),d2   ;d2 rel to right of buttons
 bmi.s .no                 ;go if pointer above buttons

 move.w xxp_butl+2(a4),d3  ;d3 counts rows
 bra.s .nxrw

.row:                      ;to next row..
 add.w xxp_butk+2(a4),d0   ;bump count by number of colms
 sub.w xxp_btdy+2(a4),d2   ;to next row
 bmi.s .no                 ;go if above next row

.nxrw:
 cmp.w xxp_buth+2(a4),d2   ;go if within this row
 ble.s .cols
 dbra d3,.row              ;to next row
 bra.s .no                 ;no if below last row

.cols:
 move.w xxp_butk+2(a4),d3  ;d3 counts colms
 bra.s .nxcl

.colm:
 addq.w #1,d0              ;bump button count
 sub.w xxp_btdx+2(a4),d1   ;to next column
 bmi.s .no                 ;go if left of next row

.nxcl:
 cmp.w xxp_butw+2(a4),d1   ;yes if within button
 ble.s .yes
 dbra d3,.colm             ;no if past last column

.no:
 moveq #0,d0

.yes:
 tst.l d0                  ;NE if we found a button
 movem.l (a7)+,d1-d3/a5
 rts

*>>>> draw a slider: a5=WSuite
TLSlider:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l a7,xxp_Stak(a4)    ;point to cached caller regs for hook to pick up

 move.l xxp_slix(a4),d0    ;d0-d3 = area covered
 move.l xxp_sliy(a4),d1
 move.l xxp_sliw(a4),d2
 move.l xxp_slih(a4),d3

 cmp.w d3,d2               ;go if vertical
 bmi.s .vert

 moveq #0,d4               ;clear slide area
 bset #29,d0
 sub.w #40,d2
 bsr TLReqarea
 bclr #29,d0
 bsr TLReqbev
 bset #29,d0
 add.w d2,d0               ;colour <> boxes
 moveq #40,d2
 moveq #3,d4
 bsr TLReqarea

 bclr #29,d0               ;draw bevs
 moveq #20,d2
 bsr TLReqbev
 add.w d2,d0
 bsr TLReqbev

 move.l d1,d2              ;draw <>
 move.l d0,d1
 sub.w #14,d1
 move.l xxp_slih(a4),d0
 subq.w #8,d0
 lsr.w #1,d0
 add.w d0,d2
 moveq #7,d0
 bsr TLPict
 add.w #20,d1
 moveq #6,d0
 bsr TLPict

 bra.s .done

.vert:

 moveq #0,d4               ;clear slide area
 bset #29,d0
 sub.w #24,d3
 bsr TLReqarea
 bclr #29,d0
 bsr TLReqbev
 bset #29,d0
 add.w d3,d1               ;colour <> boxes
 moveq #24,d3
 moveq #3,d4
 bsr TLReqarea

 bclr #29,d0               ;draw bevs
 moveq #12,d3
 bsr TLReqbev
 add.w d3,d1
 bsr TLReqbev

 move.l d1,d2              ;draw ^v
 move.l d0,d1
 sub.w #10,d2
 move.l xxp_sliw(a4),d0
 subq.w #8,d0
 lsr.w #1,d0
 add.w d0,d1
 moveq #8,d0
 bsr TLPict
 add.w #12,d2
 moveq #9,d0
 bsr TLPict

.done:                     ;xxp_errn=0 if drawn ok

 bsr TLSlide               ;draw the slide

 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> calculate the slide length & position
TLSlide:
 movem.l d0-d7,-(a7)       ;save all
 moveq #0,d5               ;d5 = sense: 0=horz, -1=vert

 move.l xxp_sliw(a4),d0    ;set d0 = Hg len in pixels
 cmp.l xxp_slih(a4),d0
 bcs.s .vert
 sub.w #44,d0
 bra.s .both

.vert:
 moveq #-1,d5
 move.l xxp_slih(a4),d0
 sub.w #26,d0

.both:
 bsr TLSlic               ;set d6 = slide, d7=tops  in pixels, validate tops

.draw:                    ;* draw slide & either side of it
 tst.w d5
 bmi.s .dwvt              ;go if vertical

 move.l d0,d5             ;* draw horz     d5 = totl pixels

 move.l xxp_slix(a4),d0   ;draw left of slide
 bset #29,d0
 addq.w #2,d0
 move.l xxp_sliy(a4),d1
 addq.w #1,d1
 move.l xxp_slih(a4),d3
 subq.w #2,d3
 move.l d7,d2
 beq.s .dwh1              ;(none left if tops=0)
 moveq #0,d4
 bsr TLReqarea

.dwh1:                    ;draw slide
 add.w d2,d0
 move.w d6,d2
 moveq #2,d4
 bsr TLReqarea

 add.w d2,d0              ;draw right of slide
 move.l d5,d2
 add.l xxp_slix(a4),d2
 addq.l #2,d2
 sub.w d0,d2
 ble.s .hook              ;go if none right
 moveq #0,d4
 bsr TLReqarea
 bra.s .hook

.dwvt:                    ;* draw vertical slide
 move.l d0,d5

 move.l xxp_slix(a4),d0   ;draw above slide
 bset #29,d0
 addq.w #2,d0
 move.l xxp_sliy(a4),d1
 addq.w #1,d1
 move.l xxp_sliw(a4),d2
 subq.w #4,d2
 move.l d7,d3
 beq.s .dwv1              ;go if none above
 moveq #0,d4
 bsr TLReqarea

.dwv1:                    ;draw slide
 add.l d3,d1
 move.l d6,d3
 moveq #2,d4
 bsr TLReqarea

 add.l d3,d1              ;draw below slide
 move.l d5,d3
 add.l xxp_sliy(a4),d3
 addq.l #1,d3
 sub.l d1,d3
 beq.s .hook              ;go if none below
 moveq #0,d4
 bsr TLReqarea

.hook:                    ;call user hook
 move.l xxp_hook(a4),d0
 beq.s .done
 movem.l a0-a6,-(a7)
 move.l d0,a0
 jsr (a0)
 movem.l (a7)+,a0-a6

.done:
 movem.l (a7)+,d0-d7
 rts

*>>>> calculate slider dimensions
; D0 on call = totl in pixels
; sets  D6 = slide in pixels
;       D7 = tops in pixels   (also validates xxp_tops)
TLSlic:
 movem.l d1/d4,-(a7)      ;saves all exc results in D6,D7

.both:
 move.l xxp_totl(a4),d1   ;d1 = totl
 move.l xxp_strs(a4),d6   ;d6 = strs
 move.l xxp_tops(a4),d7   ;d7 = tops

 move.l d1,d4             ;* validate tops
 sub.l d6,d4              ;set d4 = totl - strs - tops
 sub.l d7,d4
 bcc.s .scal              ;ok if tops <= totl - strs
 add.l d7,d4
 move.l d4,xxp_tops(a4)   ;else, set tops = totl - strs
 bra .both                ;& reset d1,d6,d7

.scal:
 swap d1                  ;scale strs,totl until totl is word length
 tst.w d1
 beq.s .scok

.half:
 swap d1
 lsr.l #1,d1
 lsr.l #1,d6
 lsr.l #1,d7
 bra .scal

.scok:
 swap d1

 mulu d0,d6               ;slide size in pixels = strs * pixels / totl
 divu d1,d6
 and.l #$0000FFFF,d6      ;remove remainder

 cmp.w #3,d6
 bcc.s .tops
 moveq #3,d6              ;minimum slide size = 3

.tops:
 mulu d0,d7               ;tops in pixels = tops * pixels / totl
 divu d1,d7
 and.l #$0000FFFF,d7

 tst.w d4                 ;if tops = totl - strs, tops pixels = 0
 bne.s .nonz
 move.l d0,d7
 sub.l d6,d7
.nonz:

 move.w d0,d4             ;tops pixels s/be <= Hg pixels - slide pixels
 sub.w d6,d4
 cmp.w d7,d4
 bcc.s .done
 move.w d4,d7

.done:
 movem.l (a7)+,d1/d4
 rts

*>>>> see if click in slider; on call d1-d3=TLKeyboard d0 was $80
; returns -1 if in was in slider, else 0
TLSlimon:
 movem.l d0-d7/a0-a6,-(a7) ;save all except result in d0
 move.l a7,xxp_Stak(a4)    ;point xxp_Stak to cached regs for hook to use
 move.l xxp_AcWind(a4),a5

 sub.w xxp_LeftEdge(a5),d1 ;make d1,d2 rel to slider
 sub.w xxp_slix+2(a4),d1
 bmi .no                   ;go if clicked outside slider
 cmp.w xxp_sliw+2(a4),d1
 bgt .no
 sub.w xxp_TopEdge(a5),d2
 sub.w xxp_sliy+2(a4),d2
 bmi .no
 cmp.w xxp_slih+2(a4),d2
 bgt .no

 moveq #0,d4               ;d4 = -1 if recycling

.rcyc:
 move.l xxp_sliw(a4),d0    ;go if vert
 cmp.l xxp_slih(a4),d0
 bcs.s .vert

 tst.w d4
 bne.s .hrzf
 sub.w #20,d0              ;horz..
 cmp.w d0,d1
 bcc .more                 ;go if >
 sub.w #20,d0
 cmp.w d0,d1               ;go if <
 bcc .less
.hrzf:
 subq.w #2,d1
 bcc.s .hrzc
 moveq #0,d1
.hrzc:
 subq.w #4,d0              ;d0 = totl in pixels
 bra.s .both

.vert:
 move.l xxp_slih(a4),d0
 move.l d2,d1
 tst.w d4
 bne.s .vrtf
 sub.w #12,d0              ;vert..
 cmp.w d0,d1
 bcc .more                 ;go if v
 sub.w #12,d0
 cmp.w d0,d1               ;go if ^
 bcc .less
.vrtf:
 subq.w #1,d1
 bcc.s .vrtc
 moveq #0,d1
.vrtc:
 subq.w #2,d0              ;d0 = totl in pixels

.both:
 bsr TLSlic                ;sets d6=slide, d7=tops  in pixels

 tst.w d4                  ;go if rcyc
 bne.s .slim
 cmp.w d7,d1
 bcs .lpag                 ;if left/above slide, back a page
 add.w d6,d7
 cmp.w d7,d1
 bgt .mpag                 ;if right/below slide, forward a page
 sub.w d6,d7

.slim:                     ;pointer is on slide (d0=totl,d1=pntr)
 moveq #0,d2
 move.l xxp_totl(a4),d3

.scal:                     ;scale total down d2 steps to make word size
 swap d3
 tst.w d3
 beq.s .scok
 addq.w #1,d2
 swap d3
 lsr.l #1,d3
 bra .scal
.scok:
 swap d3

 mulu d3,d1                ;make d1 to be in terms of totl
 divu d0,d1
 and.l #$0000FFFF,d1
 bra.s .unsf

.unsc:                     ;scale d1 up d2 steps
 lsl.l #1,d1
.unsf:
 dbra d2,.unsc

 move.l xxp_strs(a4),d2    ;sutbract strs/2 from d1 to make ptr half up slid
 lsr.l #1,d2
 sub.l d2,d1
 bcc.s .scld
 moveq #0,d1

.scld:
 move.l d1,xxp_tops(a4)    ;set tops to new value
 bsr TLSlide               ;go validate tops, draw slide there

 move.l xxp_gfxb(a4),a6    ;avoid busy wait
 jsr _LVOWaitTOF(a6)
 move.l xxp_Window(a5),a1  ;get window structure
 bsr TLMmess               ;any messages?

 beq.s .none               ;no, keep going

 bra .yes                  ;yes, quit (assume mouse up)

.none:
 moveq #-1,d4              ;make d1,d2 rel to slider area
 move.l xxp_Window(a5),a1
 moveq #0,d1
 moveq #0,d2
 move.w wd_MouseX(a1),d1
 move.w wd_MouseY(a1),d2

 move.l xxp_sliw(a4),d0
 cmp.l xxp_slih(a4),d0
 bcs.s .nnc1

 sub.w xxp_LeftEdge(a5),d1
 sub.w xxp_slix+2(a4),d1
 subq.w #2,d1
 bpl.s .nnc0
 moveq #0,d1
.nnc0:
 sub.w #44,d0
 cmp.w d1,d0
 bcc.s .nnc3
 move.w d0,d1
 bra.s .nnc3

.nnc1:
 move.l xxp_slih(a4),d0
 move.l d2,d1
 sub.w xxp_TopEdge(a5),d1
 sub.w xxp_sliy+2(a4),d1
 subq.w #1,d1
 bpl.s .nnc2
 moveq #0,d1
.nnc2:
 sub.w #26,d0
 cmp.w d1,d0
 bcc .nnc3
 move.w d0,d1

.nnc3:
 bsr TLSlic
 bra .slim

.lpag:
 move.l xxp_strs(a4),d0
 bra.s .lesc
.less:
 moveq #1,d0
.lesc:
 sub.l d0,xxp_tops(a4)
 bcc.s .udlr
 clr.l xxp_tops(a4)
 bra.s .udlr

.mpag:
 move.l xxp_strs(a4),d0
 bra.s .morc
.more:
 moveq #1,d0
.morc:
 add.l d0,xxp_tops(a4)

.udlr:
 bsr TLSlide

.yes:
 moveq #-1,d0              ;signal yes we were
 bra.s .quit

.no:
 moveq #0,d0               ;signal no we weren't

.quit:
 move.l d0,(a7)            ;result to d0 in stack
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> wait for any windw to be active, pop it (IDCMP_ACTIVEWINDOW discarded)
TLWpoll:
 movem.l a0-a6,-(a7)    ;save all except D0-D3
.poll:
 moveq #0,d5            ;d5=wnum
 move.l xxp_WSuite(a4),a5 ;a5=suite pointer
.next:
 move.l xxp_Window(a5),d0 ;go if no window
 beq.s .skip
 move.l d0,a1           ;any message? (if yes, presumably Active Window)
 bsr TLMmess
 bne.s .actv            ;yes, go
.skip:
 add.l #xxp_siz2,a5     ;to next window
 addq.w #1,d5
 cmp.w #10,d5           ;until all looked at
 bne .next
 move.l xxp_gfxb(a4),a6
 jsr _LVOWaitTOF(a6)    ;pause to avoid busy wait
 bra .poll              ;poll the windows again
.actv:
 move.l d0,a0           ;save d0
 move.l d5,d0
 bsr TLWpop             ;pop the window
 move.l a0,d0           ;restore d0
 movem.l (a7)+,a0-a6    ;D5=window num; TLMmess in D0-D4
 rts

*>>>> clear all messages waiting at all windows
TLWslof:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l xxp_gfxb(a4),a6    ;pause for messages to arrive
 jsr _LVOWaitTOF(a6)
 jsr _LVOWaitTOF(a6)
.scan:
 move.l xxp_WSuite(a4),a5 ;a5 scans WSuite
 moveq #9,d7              ;d7 counts windows
.next:
 move.l xxp_Window(a5),d0 ;get next window
 beq.s .slof              ;go if none
 move.l d0,a1
 bsr TLMmess              ;get messages waiting none at any window
 bne .scan
.slof:
 add.l #xxp_siz2,a5       ;to next until all done
 dbra d7,.next
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> make sure current is at front
TLWfront:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;save all
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 jsr _LVOWindowToFront(a6)
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

*>>>> put current at back
TLWback:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;save all
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 jsr _LVOWindowToBack(a6)
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

*>>>> create a help requester if xxp_Help set (called ONLY by TLKeyboard)

; help 1st str, num strs in xxp_Help(a4),xxp_Help+2(a4)
; if no help, xxp_Help(a4) = 0
; if bit 31 of xxp_Help(a4) set, forbidden (to prevent recursive calls)

TLHelp:
 tst.l xxp_Screen(a4)      ;no help if all unitialised
 beq .quit
 tst.w xxp_Public(a4)
 ble .quit
 tst.w xxp_Active(a4)      ;no help if no window active
 bmi .quit
 tst.l xxp_Help(a4)        ;go if no help, or help forbidden
 ble .quit

 move.l xxp_butx(a4),-(a7) ;save button data
 move.l xxp_buty(a4),-(a7)
 move.l xxp_butw(a4),-(a7)
 move.l xxp_buth(a4),-(a7)
 move.l xxp_btdx(a4),-(a7)
 move.l xxp_btdy(a4),-(a7)
 move.l xxp_butk(a4),-(a7)
 move.l xxp_butl(a4),-(a7)

 movem.l d0-d7/a0-a6,-(a7) ;save all

 move.w xxp_Pop(a4),d0     ;save pop
 move.l d0,-(a7)
 move.l (a4),-(a7)         ;leave buff unchanged
 move.l 4(a4),-(a7)
 move.l 8(a4),-(a7)

 move.l a4,a0              ;save reqx to butl
 add.w #xxp_reqx,a0
 moveq #11,d0
.save:
 move.l (a0)+,-(a7)
 dbra d0,.save

 sub.w #xxp_WPort+4,a7     ;create dummy part xxp_wsuw

 move.l a7,a5              ;set all part_wsuw data
 move.w xxp_Active(a4),xxp_Pop(a4)
 move.w #$0103,xxp_FrontPen(a5)
 move.b #RP_JAM2,xxp_DrawMode(a5)
 clr.l xxp_LeftEdge(a5)
 move.l xxp_AcWind(a4),a1
 move.w xxp_HTspc(a1),xxp_Tspc(a5)
 move.w xxp_HFsty(a1),xxp_Fsty(a5)
 move.w xxp_HFont(a1),xxp_Fnum(a5)
 move.w #-1,xxp_Attc(a5)
 move.l a4,xxp_IText(a5)
 move.l xxp_ERport(a4),xxp_WPort(a5)  ;use xxp_ERport as dummy xxp_WPort

.rcyc:                     ;* set size of requester
 move.l a4,a0              ;set minimum xxp_butw,xxp_buth
 move.w #'OK',(a0)
 clr.b 2(a0)               ;OK if no guide
 tst.w xxp_Help+2(a4)
 bpl.s .buts
 move.l #'Guid',(a0)       ;else Guide\OK
 move.l #'e\OK',4(a0)
 clr.b 8(a0)
.buts:
 move.l xxp_AcWind(a4),-(a7)
 move.l a5,xxp_AcWind(a4)
 bsr TLButstr
 move.l (a7)+,xxp_AcWind(a4)

 move.w xxp_Help(a4),d0    ;point a3 to strings
 bsr TLStra0
 move.l a0,a3              ;a0 scans strings
 move.w xxp_Help+2(a4),d1  ;d1 counts strings
 bclr #15,d1
 subq.w #1,d1
 moveq #0,d3               ;set d3 to max string width
.maxw:
 move.l a0,xxp_IText(a5)
 bsr TLTszdo
.maxc:
 tst.b (a0)+
 bne .maxc
 cmp.w d4,d3
 bcc.s .maxx
 move.w d4,d3
.maxx:
 dbra d1,.maxw

 addq.w #8,d3              ;d3 = max string width + 8 = req width for strs
 move.w xxp_butw+2(a4),d2  ;d2 = req width for buts
 addq.w #2,d2              ; (6 ea side + 2 between)
 mulu xxp_butk+2(a4),d2
 add.w #10,d2
 cmp.w d3,d2
 bcc.s .butf
 move.w d3,d2              ;d2 = required req width

.butf:                     ;complete the data for buts
 move.l d2,d0
 sub.w #12,d0
 move.w d0,xxp_butw+2(a4)  ;if 1 button, butw = width - 12
 cmp.w #1,xxp_butk+2(a4)
 beq.s .buth
 subq.w #2,d0
 lsr.w #1,d0
 move.w d0,xxp_butw+2(a4)  ;else, = (width - 14)/2
 addq.w #2,d0
 move.l d0,xxp_btdx(a4)    ;& btdx = butw + 2
.buth:
 move.l #6,xxp_butx(a4)    ;butx = 6

 move.w xxp_Help+2(a4),d3  ;calulate req height
 bclr #15,d3
 mulu d6,d3                ;= strs * str ht
 addq.w #3,d3              ;+ 2 at top, 1 below text
 move.l d3,xxp_buty(a4)    ;set buty
 add.l xxp_buth(a4),d3     ;+ buth
 addq.l #2,d3              ;+ 2 at bot

 cmp.l xxp_Width(a4),d2    ;go if requester not too wide
 ble.s .gtht
 tst.w xxp_Tspc(a5)        ;retry w. Tspc-1 if Tspc<>0
 beq.s .wdt2
 subq.w #1,xxp_Tspc(a5)
 bra .rcyc
.wdt2:
 tst.w xxp_Fnum(a5)        ;retry w. Fnum=0 if Fnum<>0
 beq.s .gtht               ;(else, will be too big to fit)
.fon0:
 moveq #0,d0               ;attach font 0 to dummy xxp_wsuw
 moveq #0,d1               ;(will be passed on by TLReqon)
 moveq #0,d2
 bsr TLAnyfont
 bne .rcyc

.gtht:
 cmp.l xxp_Height(a4),d3   ;go if requester not too high
 ble.s .chek
 tst.w xxp_Fnum(a5)        ;redo with Fnum=0 if Fnum<>0
 bne .fon0                 ;(else will be too big)

.chek:
 bsr TLReqchek             ;check req dims, &c
 beq .wrap                 ;go if won't fit

 moveq #11,d0              ;open window 11 for requester
 move.l xxp_reqx(a4),d1
 move.l xxp_reqy(a4),d2
 move.l xxp_reqw(a4),d3
 move.l xxp_reqh(a4),d4
 move.l d3,d5
 move.l d6,a2              ;(save d6)
 move.l d4,d6
 moveq #1,d7               ;usual flags for requester
 bsr TLWindow              ;open requester window
 beq .wrap                 ;go if can't
 move.l a2,d6              ;(restore d6)

 move.l a5,a0              ;a0 = dummy xxp_wsuw entry
 move.l xxp_AcWind(a4),a5  ;point to real xxp_wsuw entry entry
 move.w xxp_Tspc(a0),xxp_Tspc(a5)
 moveq #0,d0
 move.w xxp_Fnum(a0),d0    ;attach dummy wsuw font to req window
 moveq #0,d1
 move.w xxp_Fsty(a0),d1
 moveq #0,d2
 bsr TLNewfont

 moveq #0,d0               ;draw background & border
 moveq #0,d1
 move.l xxp_reqw(a4),d2
 move.l xxp_reqh(a4),d3
 moveq #3,d4
 bset #29,d0
 bsr TLReqarea
 bclr #29,d0
 bsr TLReqbev

 move.w #$0103,xxp_FrontPen(a5)

 bsr TLButprt              ;draw buttons & text therein
 move.l a4,a0
 move.w #'OK',(a0)
 clr.b 2(a0)
 tst.w xxp_Help+2(a4)
 bpl.s .btts
 move.l #'Guid',(a0)
 move.l #'e\OK',4(a0)
 clr.b 8(a0)
.btts:
 bsr TLButtxt

 move.w #$0203,xxp_FrontPen(a5) ;draw strings
 moveq #4,d0
 moveq #2,d1
 move.w xxp_Help+2(a4),d2
 bclr #15,d2
 subq.w #1,d2
.prnt:
 move.l a3,xxp_IText(a5)
 bsr TLText
 move.b #1,xxp_FrontPen(a5)
 add.w d6,d1
.pfwd:
 tst.b (a3)+
 bne .pfwd
 dbra d2,.prnt

 bset #7,xxp_Help(a4)      ;disable recursive help calls

.wait:
 bsr TLWfront              ;get keyboard
 bsr TLKeyboard

 tst.b xxp_Help+2(a4)      ;go if OK only
 bpl.s .ngui

 cmp.b #$0D,d0             ;to guide if Enter,F1
 beq.s .guid
 cmp.b #$81,d0
 beq.s .guid
 cmp.b #$82,d0             ;quit if F2
 beq.s .clos
 btst #6,d3
 beq.s .ngui               ;go unless Left Amiga
 cmp.b #'b',d0
 beq.s .clos               ;LfAm / b -> OK
 cmp.b #'v',d0
 beq.s .guid               ;LfAm / v -> guide

.ngui:
 cmp.b #$0D,d0             ;quit if Enter (& 1 button)
 beq.s .clos
 cmp.b #$81,d0             ;quit if F1 (& 1 button)
 beq.s .clos
 cmp.b #$1B,d0             ;quit if Esc
 beq.s .clos

 cmp.b #$80,d0             ;else accept only lmb
 bne .wait

 bsr TLButmon              ;monitor buttons
 beq .wait                 ;go if none
 cmp.b #2,d0
 beq.s .clos               ;quit if 2nd button
 tst.b xxp_Help+2(a4)
 bpl.s .clos               ;quit if 1st button, & 1 button

.guid:                     ;here if guide
 bsr TLGuide
 bra .wait

.clos:
 moveq #0,d0
 move.w xxp_Pop(a4),d0    ;get window to be popped
 move.l d0,a5
 moveq #11,d0             ;close requester window
 bsr TLWsub
 move.l a5,d0
 move.w d0,xxp_Active(a4) ;restore xxp_Active
 bsr TLWpop               ;pop formerly active window

 bclr #7,xxp_Help(a4)      ;re-enable help

.wrap:
 add.w #xxp_WPort+4,a7

 move.l a4,a0              ;restore reqx to butl
 add.w #xxp_butl+4,a0
 moveq #11,d0
.load:
 move.l (a7)+,-(a0)
 dbra d0,.load

 move.l (a7)+,8(a4)        ;restore buff (left unchanged)
 move.l (a7)+,4(a4)
 move.l (a7)+,(a4)
 move.l (a7)+,d0           ;restore pop
 move.w d0,xxp_Pop(a4)

 movem.l (a7)+,d0-d7/a0-a6

 move.l (a7)+,xxp_butl(a4) ;restore button data
 move.l (a7)+,xxp_butk(a4)
 move.l (a7)+,xxp_btdy(a4)
 move.l (a7)+,xxp_btdx(a4)
 move.l (a7)+,xxp_buth(a4)
 move.l (a7)+,xxp_butw(a4)
 move.l (a7)+,xxp_buty(a4)
 move.l (a7)+,xxp_butx(a4)

.quit:
 rts

*>>>> View Multiline.guide (called by TLHelp,TLMultiline)

; Set xxp_guid,xxp_path & set bit 7 of xxp_Help+2 to put Guide\OK on help.

TLGuide:

; offsets to xxp_gide workspace
.lock: equ 1008            ;lock on CD
.aggb: equ 1016            ;amigaguide.library base
.hndl: equ 1012            ;amigaguide handle
.name: equ 100             ;CD name (max 130 bytes)

 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l xxp_gide(a4),a5    ;a5 = 1024 byte workspace

 move.l xxp_dosb(a4),a6    ;lock CD
 move.l a5,d1
 add.l #.name,d1
 move.l #130,d2
 jsr _LVOGetCurrentDirName(a6)
 move.l a5,d1
 add.l #.name,d1
 moveq #ACCESS_READ,d2
 jsr _LVOLock(a6)
 move.l d0,.lock(a5)
 beq .gubd                 ;bad if can't

 move.l xxp_sysb(a4),a6    ;open amigaguide.library
 lea .s136,a1
 moveq #37,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,.aggb(a5)
 beq.s .gubd               ;bad if can't

 move.l .aggb(a5),a6       ;make a NewAmigaGuide structure
 move.l a5,a0
 move.w #NewAmigaGuide_SIZEOF-1,d0
.gung:
 clr.b (a0)+               ;clear the structure
 dbra d0,.gung
 move.l a7,a0              ;a0 points to it
 move.l xxp_guid(a4),nag_Name(a0)
 move.l xxp_node(a4),nag_Node(a0)
 move.l .lock(a5),nag_Lock(a0)
 move.l xxp_Screen(a4),nag_Screen(a0)

 sub.l a1,a1               ;open the amigaguide
 moveq #0,d0
 jsr _LVOOpenAmigaGuideA(A6)
 move.l d0,.hndl(a5)       ;cache handle
 bne.s .guok               ;go if open

 move.l xxp_intb(a4),a6    ;beep if can't
 move.l xxp_Screen(a4),a0
 jsr _LVODisplayBeep(a6)
 bra.s .gub0

.guok:
 move.l .aggb(a5),a6       ;close the amigaguide
 move.l .hndl(a5),a0
 jsr _LVOCloseAmigaGuide(a6)
.gub0:

 move.l xxp_sysb(a4),a6    ;close amigaguide.library
 move.l .aggb(a5),a1
 jsr _LVOCloseLibrary(a6)

.guqt:                     ;unlock CD
 move.l xxp_dosb(a4),a6
 move.l .lock(a5),d1
 jsr _LVOUnLock(a6)
 bra.s .gufn

.gubd:                     ;here if bad (beep)
 move.l xxp_intb(a4),a6
 move.l xxp_Screen(a4),a0
 jsr _LVODisplayBeep(a6)

.gufn:
 movem.l (a7)+,d0-d7/a0-a6
 rts

.s136: dc.b 'amigaguide.library',0
 ds.w 0

*>>>> same as TLText, but quits if window resized, trims to fit (slower)

; quits with error if window resized
; if won't fit horizontally, trims to fit  (no error)
; if won't fit vertically, doensn't print  (no error)

TLTrim:
 movem.l d0-d7/a0-a6,-(a7) ;save all regs
 move.l a4,a3
.eol:
 tst.b (a3)+               ;point a3 to end of string
 bne .eol
 subq.l #1,a3
 move.b (a3),d3            ;d3 = chr where trimmed
 clr.l xxp_errn(a4)
 move.l xxp_gfxb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 move.w xxp_Tspc(a5),rp_TxSpacing(a1)
.try:
 move.l (a7),d0            ;set d0,d1 for next try
 move.l 4(a7),d1
 bsr TLTszdo               ;attach font if required, text size data to d4-d7
 add.w xxp_xmin(a5),d0
 sub.w xxp_xmin(a5),d4     ;adjust lhs, remaining width for underflow
 add d1,d6
 cmp.w xxp_PHeight(a5),d6  ;quit if window too shallow
 bgt.s .done
 add.w d0,d4
 cmp.w xxp_PWidth(a5),d4   ;go print if window wide enough
 ble.s .cont
 cmp.l a3,a4               ;quit if no chrs will fit
 beq.s .done
 move.b d3,(a3)            ;restore prvious trim chr
 subq.l #1,a3              ;one less chr
 move.b (a3),d3            ;keep trim chr
 clr.b (a3)                ;trim it
 bra .try                  ;& try again
.cont:
 bsr TLWpens               ;attach pens if required
 add.w xxp_LeftEdge(a5),d0 ;make d0,d1 rel to edges of window rastport
 add.w xxp_TopEdge(a5),d1
 add.w d7,d1               ;make d1 point to baseline
 jsr _LVOMove(a6)          ;print posn on rastport
 move.l d5,d0              ;d0 = no. of chrs
 move.l a4,a0              ;a0 points to text
 move.l xxp_WPort(a5),a1   ;a1 = rastport
 bsr TLWCheck              ;bad if window resized
 bne.s .bad
 jsr _LVOText(a6)          ;print
 bra.s .done

.bad:                      ;bad: window resized
 move.w #35,xxp_errn+2(a4)

.done:
 move.b d3,(a3)            ;un-trim the text
 movem.l (a7)+,d0-d7/a0-a6
 tst.l xxp_errn(a4)
 eori.w #-1,CCR            ;xxp_errn<>0, EQ if bad
 rts

*>>>> close window D0 in the suite (can call if already closed)
TLWsub:
 movem.l d0-d2/a0-a2/a5-a6,-(a7) ;save all regs

 cmp.w xxp_Active(a4),d0   ;update xxp_Active if affected
 bne.s .pass
 move.w #-1,xxp_Active(a4)
.pass:

 move.l xxp_WSuite(a4),a5  ;point to WSuite entry
 mulu #xxp_siz2,d0
 add.l d0,a5
 tst.l xxp_Window(a5)      ;go if already closed
 beq .done

 move.l xxp_Mmem(a5),d0    ;close Multiline mem if any
 beq.s .muon
 move.l xxp_sysb(a4),a6
 move.l d0,a1
 jsr _LVOFreeVec(a6)

.muon:
 move.l xxp_intb(a4),a6    ;detach menu if attached
 tst.l xxp_Menu(a5)
 beq.s .clos
 tst.w xxp_Menuon(a5)
 beq.s .clos
 move.l xxp_Window(a5),a0
 jsr _LVOClearMenuStrip(a6)
.clos:
 move.l xxp_Window(a5),a1
 movem.l d0-d4,-(a7)
 bsr TLMmess
 movem.l (a7)+,d0-d4
 bne .clos

 move.l xxp_Window(a5),a0  ;close window
 jsr _LVOCloseWindow(a6)
 clr.l xxp_Window(a5)      ;flag as closed
 move.l xxp_Menu(a5),d0    ;free xxp_Menu (if any)
 beq.s .wrap
 move.l xxp_gadb(a4),a6
 move.l d0,a0
 jsr _LVOFreeMenus(a6)
.wrap:

 move.l xxp_scrl(a5),d0    ;go if no scrollers
 beq.s .done
 move.l d0,a2
 moveq #5,d2
 move.l xxp_intb(a4),a6
.frob:                     ;free scroller objects
 move.l (a2)+,a0
 jsr _LVODisposeObject(a6)
 dbra d2,.frob
 move.l xxp_scrl(a5),a2    ;free context gadget
 move.l xxp_gcnt(a2),a0
 clr.l gg_NextGadget(a0)
 move.l xxp_gadb(a4),a6
 jsr _LVOFreeGadgets(a6)

.done:
 movem.l (a7)+,d0-d2/a0-a2/a5-a6
 rts

*>>>> put suite window D0 in xxPram, bring it to front & activate it
; ok to call if window D0 already popped
; (calls TLWslof to stop churning)
TLWpop:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;save all regs
 move.w d0,xxp_Active(a4)    ;note new pop
 move.l xxp_WSuite(a4),a5    ;point to new window
 mulu #xxp_siz2,d0
 add.l d0,a5
 move.l a5,xxp_AcWind(a4)    ;update xxp_AcWind
 bsr TLWfront
 move.l xxp_WPort(a5),a0     ;get rastport
 move.l xxp_Window(a5),a0    ;activate popped window
 move.l xxp_intb(a4),a6
 jsr _LVOActivateWindow(a6)
 bsr TLWslof                 ;slough all idcmp's
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

*>>>> transform ASCII at (a0) into a 68881-type .P in (a1)

; return code d0: 0=ok 1=no digits in mantissa 2=bad exp 3=no digits after E
; 3(a1)=0 on return if zero

TLFloat:
 movem.l d4-d7/a2,-(a7) ;save all exc d0, a0 bypasses
 clr.l (a1)         ;initialise output
 clr.l 4(a1)
 clr.l 8(a1)
 cmp.b #'+',(a0)
 beq.s .sign
 cmp.b #'-',(a0)
 bne.s .plus
 bset #7,(a1)       ;bit 95=1 if -ve
.sign:
 addq.l #1,a0       ;bypass sign if any
.plus:
 move.l a0,a2       ;a2 tests that mantissa exists
 addq.l #1,a2
 moveq #0,d7        ;d7 counts power
 moveq #'.',d6      ;d6=.   for finding .
 moveq #'0',d5      ;d5='0' for conv ascii to hex/bcd
 moveq #10,d4       ;d4=10  for conv ascii to hex/bcd
.lead:
 cmp.b (a0)+,d5     ;skip leading zeroes
 beq .lead
 cmp.b -1(a0),d6    ;leading .?
 bne.s .some        ;no, start scanning mantissa
 addq.l #1,a2       ;allow for . in a2
.point:
 subq.w #1,d7       ;exp=-1 if leading . plus no. of further leading 0's
 cmp.b (a0)+,d5
 beq .point
.some:
 move.b -1(a0),d0   ;get first non-0 digit
 sub.b d5,d0        ;if none, then zero
 bcs.s .zero
 cmp.b d4,d0
 bcs.s .mant        ;go if 1-9 (1st digit of mantissa)
.zero:
 cmp.l a0,a2        ;bad if no mantissa
 beq .bad1
 cmp.b #'E'-'0',d0  ;here if zero: if has exp, slough it
 beq.s .zeroe
 cmp.b #'e'-'0',d0
 bne.s .zeroq
.zeroe:
 move.b (a0),d0
 cmp.b #'+',d0
 beq.s .zeros
 cmp.b #'-',d0
 bne.s .zerox
.zeros:
 addq.l #1,a0
.zerox:
 move.b (a0)+,d0
 sub.b d5,d0
 bcs.s .zeroq
 cmp.b d4,d0
 bcs .zerox
.zeroq:
 subq.l #1,a0       ;point to delimiter
 clr.b (a1)         ;make zero
 moveq #0,d0        ;flag ok
 movem.l (a7)+,d4-d7/a2
 rts
.mant:
 move.l a1,a2       ;a2 puts digits
 addq.l #3,a2
 move.b d0,(a2)+    ;put 1st chr of mantissa
 moveq #7,d1        ;d1 counts mantissa bytes (8 bytes=16 digits)
 tst.w d7
 bne.s .ptgt        ;go if . already found
.digt:              ;get digits in pairs into (a2)
 move.b (a0)+,d0    ;frst digit
 sub.b d5,d0
 bcs.s .ptgt1       ;if <'0', see if . (frst)
 cmp.b d4,d0
 bcc.s .exp         ;if >'0', see if E/e
 lsl.b #4,d0
 move.b d0,(a2)     ;put in ms nybble
 addq.w #1,d7       ;bump exp for each digit before .
 move.b (a0)+,d0    ;scnd digit
 sub.b d5,d0
 bcs.s .ptgt2       ;if <'0', see if . (scnd)
 cmp.b d4,d0
 bcc.s .exp         ;if >'0', see if E/e
 or.b d0,(a2)+      ;or into ls nybble
 addq.w #1,d7       ;bump exp for each digit before .
 dbra d1,.digt
 subq.w #1,d7       ;if 17 digits already, slough further
.noslof:
 addq.w #1,d7       ;bump exp for each sloughed digit
 move.b (a0)+,d0
 sub.b d5,d0
 bcs .calc          ;no E/e if <'0'
 cmp.b d4,d0
 bcs .noslof
 bra.s .exp         ;if >'0', try E/e
.ptgt2:
 cmp.b #'.'-'0',d0  ;if . pick up . digits in 2nd digt
 beq.s .ptp
 bra .calc          ;else, no E/e
.ptgt1:
 cmp.b #'.'-'0',d0  ;if . pick up . digits in 1st digt
 bne .calc          ;else, no E/e
.ptgt:              ;get digits after . in pairs
 move.b (a0)+,d0    ;frst digit
 sub.b d5,d0
 bcs .calc          ;if <'0', no E/e
 cmp.b d4,d0
 bcc.s .exp         ;if >'0', try E/e
 lsl.b #4,d0
 move.b d0,(a2)     ;put ms nybble
.ptp:
 move.b (a0)+,d0    ;scnd digit
 sub.b d5,d0
 bcs.s .calc        ;if <'0', no E/e
 cmp.b d4,d0
 bcc.s .exp         ;if >'0', try E/e
 or.b d0,(a2)+      ;put ls bybble
 dbra d1,.ptgt
.slof:              ;slough digits after 17th
 move.b (a0)+,d0
 sub.b d5,d0
 bcs.s .calc        ;no E/e if <'0'
 cmp.b d4,d0
 bcs .slof          ;if >'0', try E/e
.exp:
 cmp.b #'E'-'0',d0  ;seek exp if E/e
 beq.s .expg
 cmp.b #'e'-'0',d0
 bne.s .calc
.expg:
 moveq #0,d6        ;d6 will be <> if Ennn exp -ve
 cmp.b #'+',(a0)
 beq.s .jump
 cmp.b #'-',(a0)
 bne.s .expr
 moveq #-1,d6       ;d6=-1 if nnn -ve
.jump:
 addq.l #1,a0
.expr:
 moveq #0,d1
 move.b (a0)+,d1    ;frst n to d1
 sub.b d5,d1
 bcs .bad3          ;bad if none
 cmp.b d4,d1
 bcc .bad3
 moveq #0,d0        ;scnd digit
 move.b (a0)+,d0
 sub.b d5,d0
 bcs.s .calcr       ;go if none
 cmp.b d4,d0
 bcc.s .calcr
 mulu #10,d1        ;else into d1
 add.w d0,d1
 move.b (a0)+,d0    ;thrd digit
 sub.b d5,d0
 bcs.s .calcr       ;go if none
 cmp.b d4,d0
 bcc.s .calcr
 mulu #10,d1        ;else into d1
 add.w d0,d1
 move.b (a0)+,d0    ;get delimiter
 sub.b d5,d0
 bcs.s .calcr
 cmp.b d4,d0
 bcc .bad2          ;bad if 0-9 (exp overflow)
.calcr:
 tst.w d6           ;add E+nnn to, or sub E-nnn from, mantissa exp
 bpl.s .plmi
 sub.w d1,d7
 bra.s .calcc
.plmi:
 add.w d1,d7
.calc:
 tst.w d7           ;see if exp +ve
.calcc:
 bpl.s .calcp       ;yes, go
 bset #6,(a1)       ;no, set bit 94
 neg.w d7           ;& make exp +ve
.calcp:
 divu #100,d7       ;get hundreds
 cmp.b #10,d7
 beq .bad2          ;(bad of exp>999)
 or.b d7,(a1)       ;put 1st nybble to bits 88+
 clr.w d7
 swap d7            ;get mod 100
 divu #10,d7        ;get tens
 rol.w #4,d7
 move.b d7,1(a1)    ;put 2nd nybble to bits 84+
 swap d7            ;get units
 or.b d7,1(a1)      ;put 3rd nybble to bits 80+
 subq.l #1,a0       ;point to delimiter
 moveq #0,d0        ;D0=0 good
 movem.l (a7)+,d4-d7/a2
 rts
.bad1:              ;D0=1 no digits in mantissa
 moveq #1,d0
 movem.l (a7)+,d4-d7/a2
 rts
.bad2:              ;D0=2 exponent out of range
 moveq #2,d0
 movem.l (a7)+,d4-d7/a2
 rts
.bad3:              ;D0=3 no digits after E
 moveq #3,d0
 movem.l (a7)+,d4-d7/a2
 rts

*>>>> put busy pointer in current TL window (call Busysetup first)
TLBusy:
 movem.l d0-d3/a0-a1/a5-a6,-(a7) ;save all
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0 ;get window
 cmp.w #39,LIB_VERSION(a6)
 bcc.s .v39               ;use v.39 method if available
 move.l xxp_busy(a4),d0
 beq.s .quit              ;go if Busysetup failed
 move.l d0,a1             ;a1 points to sprite data
 moveq #16,d0             ;width,height,hotpoint
 moveq #16,d1
 moveq #0,d2
 moveq #0,d3
 jsr _LVOSetPointer(a6)   ;change pointer
 bra.s .quit
.v39:                     ;here if 3.0+ (v.39+)
 lea .tags,a1
 jsr _LVOSetWindowPointerA(a6)
.quit:
 movem.l (a7)+,d0-d3/a0-a1/a5-a6
 rts

.tags:                    ;tags for busy pointer (v39+ method)
 dc.l WA_BusyPointer,1    ;this uses the prefs busy pointer
 dc.l WA_PointerDelay,1   ;this stops the change if the delay is very short
 dc.l TAG_DONE

*>>>> return window pointer to un-busy (ok to call if TLBusy never called)
; doesn't matter if window closed without calling this first
TLUnbusy:
 movem.l d0-d1/a0-a1/a5-a6,-(a7) ;save all
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0 ;get window
 cmp.w #39,LIB_VERSION(a6)
 bcc.s .v39               ;go if v39+ (3.0+)
 jsr _LVOClearPointer(a6) ;restore pointer
 bra.s .quit
.v39:
 lea .tags,a1
 jsr _LVOSetWindowPointerA(a6)
.quit:
 movem.l (a7)+,d0-d1/a0-a1/a5-a6
 rts

.tags:
   dc.l  WA_Pointer,0    ;tag for normal pointer
   dc.l  TAG_DONE


*>>>> put up a color requester (bad if <OS3.0)

; D0 on call:  0 = pen select only
;              1 = pen select + palette enabled
;              2 = palette only
;             -1 = load prefs palette, don't put up requester

; (if D0=-1, can call if xxp_Screen(a4) exists, but TLWindow never called)

TLReqcolor:
 tst.l d0                 ;go put up requester if required
 bpl .requ

; TLReqcolor - here if no requester required (D0 = -1)

 movem.l d0-d7/a0-a6,-(a7) ;save all

 move.l xxp_sysb(a4),a6
 move.l #3084,d0           ;= 4 + 12*256 + 4
 moveq #MEMF_PUBLIC,d1
 jsr _LVOAllocVec(a6)
 tst.l d0
 beq.s .subd
 move.l d0,a3              ;a3 = mem for rgb values

 move.w #256,(a3)          ;init rgb mem
 clr.w 2(a3)
 clr.l 3076(a3)

 move.l a4,a0              ;read ENV:Tandem/Color (if exists)
 move.l #'ENV:',(a0)+
 move.l #'Tand',(a0)+
 move.l #'em/C',(a0)+
 move.l #'olor',(a0)+
 clr.b (a0)
 bsr TLOpenread
 beq.s .suok
 move.l a3,d2
 addq.l #4,d2
 move.l #3072,d3
 bsr TLReadfile
 beq.s .suok
 bsr TLClosefile

 move.l xxp_gfxb(a4),a6    ;set colours as read
 move.l xxp_Screen(a4),a0
 add.l #sc_ViewPort,a0
 move.l a3,a1
 jsr _LVOLoadRGB32(a6)

.suok:
 move.l a3,a1              ;release rgb mem
 move.l xxp_sysb(a4),a6
 jsr _LVOFreeVec(a6)

.subd:
 movem.l (a7)+,d0-d7/a0-a6
 rts

; TLReqcolor - here if requester required (D0 = 0/1/2)

.requ:
 move.l xxp_Help(a4),-(a7)
 move.l xxp_strg(a4),-(a7)

 move.l xxp_butx(a4),-(a7) ;save button data
 move.l xxp_buty(a4),-(a7)
 move.l xxp_butw(a4),-(a7)
 move.l xxp_buth(a4),-(a7)
 move.l xxp_btdx(a4),-(a7)
 move.l xxp_btdy(a4),-(a7)
 move.l xxp_butk(a4),-(a7)
 move.l xxp_butl(a4),-(a7)

 move.l xxp_slix(a4),-(a7) ;save slider data
 move.l xxp_sliy(a4),-(a7)
 move.l xxp_sliw(a4),-(a7)
 move.l xxp_slih(a4),-(a7)
 move.l xxp_tops(a4),-(a7)
 move.l xxp_totl(a4),-(a7)
 move.l xxp_strs(a4),-(a7)
 move.l xxp_hook(a4),-(a7)

 movem.l d1-d7/a0-a6,-(a7) ;save all regs except D0
 clr.l xxp_errn(a4)
 move.l d0,xxp_butl(a4)    ;(save input d0 here)
 sub.w #xxp_WPort+4,a7     ;create dummy part xxp_wsuw

 move.l xxp_sysb(a4),a6
 cmp.w #39,LIB_VERSION(a6) ;bad if not OS3.0+
 bcs .v39

 move.l #6156,d0           ;= 2*(256*4*3+4)+4 (3 longwords/color; max 256)
 moveq #MEMF_PUBLIC,d1
 jsr _LVOAllocVec(a6)
 tst.l d0
 beq .oom
 move.l d0,a3              ;a3 = mem for rgb values

 move.l a7,a5              ;a5 points to dummy part xxp_wsuw
 bsr TLReqredi             ;set pop window
 beq .bad                  ;(go if init fails - unlikely)

 move.l xxp_Depth(a4),d4   ;colour buttons: set d6=rows,d7=clms
 lea .tabl,a0
 lsl.w #1,d4
 moveq #0,d6
 moveq #0,d7
 move.b 0(a0,d4.w),d6
 move.b 1(a0,d4.w),d7

 move.l #292,d2            ;set req size
 move.l #156,d3
 bsr TLReqchek             ;check requester size &c
 beq .bad

 tst.w xxp_ReqNull(a4)     ;go if null
 beq .null

 bsr TLReqon               ;window on
 beq .bad                  ;go if can't

 move.l xxp_gfxb(a4),a6    ;get existing colormap info
 move.l xxp_Screen(a4),a1
 add.l #sc_ViewPort,a1
 move.l vp_ColorMap(a1),a0
 moveq #1,d1
 move.l xxp_Depth(a4),d0
 rol.l d0,d1               ;d1=no. of colors
 moveq #0,d0
 move.l a3,a1
 move.w d1,(a1)+           ;put in LoadRGB32 format
 clr.w (a1)+
 jsr _LVOGetRGB32(a6)
 move.l a3,a0
 move.l a3,a1
 add.l #3076,a1            ;put in 2nd half in case cancel
 move.w (a3),d0            ;put guns
 mulu #3,d0                ;cols*3+1 longwords

.bkup:
 move.l (a0)+,(a1)+        ;put in canc data
 dbra d0,.bkup
 clr.l (a1)                ;delimit canc data

 move.l xxp_AcWind(a4),a5  ;a5=WSuite
 clr.w xxp_Tspc(a5)        ;Reqcolor always uses Topaz/8 plain spc0
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont

 move.l #.strs,xxp_strg(a4)
 move.l xxp_butl(a4),d0    ;set help for whichever task
 mulu #18,d0
 addq.l #1,d0
 move.w d0,xxp_Help(a4)
 move.w #18,xxp_Help+2(a4)

.rcyc:                     ;* redraw requester
 bsr .clir

 moveq #55,d0              ;print hail
 cmp.l #2,xxp_butl(a4)
 bne.s .st55
 moveq #56,d0
.st55:
 bsr TLStrbuf
 moveq #4,d0
 moveq #2,d1
 move.w #$0203,xxp_FrontPen(a5)
 bsr TLText

 moveq #0,d0               ;bev around colors
 moveq #11,d1
 move.l #292,d2
 moveq #90,d3
 bsr TLReqbev

 move.l #2,xxp_butx(a4)    ;set button sizes
 move.l #12,xxp_buty(a4)
 move.l #288,d0
 divu d7,d0
 move.l d0,xxp_butw(a4)
 move.l d0,xxp_btdx(a4)
 moveq #88,d0
 divu d6,d0
 move.l d0,xxp_buth(a4)
 clr.l xxp_btdy(a4)

 move.l d6,-(a7)           ;fill each button with its pen color
 subq.w #1,d6
 move.l xxp_buty(a4),d1
 move.l xxp_butw(a4),d2
 move.l xxp_buth(a4),d3
 moveq #0,d4
.row:
 move.l xxp_butx(a4),d0
 move.l d7,d5
 subq.w #1,d5
.colm:
 bset #29,d0
 bsr TLReqarea
 bclr #29,d0
 addq.w #1,d4
 add.l xxp_btdx(a4),d0
 dbra d5,.colm
 add.l xxp_buth(a4),d1
 dbra d6,.row
 move.l (a7)+,d6

 move.l #256,xxp_totl(a4)  ;ready to draw sliders
 move.l #1,xxp_strs(a4)
 moveq #0,d0
 moveq #101,d1
 moveq #40,d2
 moveq #11,d3
 bsr TLReqbev
 move.l #40,xxp_slix(a4)
 move.l #252,xxp_sliw(a4)
 move.l d3,xxp_slih(a4)
 moveq #112,d1
 bsr TLReqbev
 moveq #123,d1
 bsr TLReqbev

 moveq #0,d0               ;draw use/cancel buttons
 move.l #134,d1
 moveq #56,d2
 moveq #11,d3
 bsr TLReqbev
 move.l #236,d0
 bsr TLReqbev
 move.w #$0103,xxp_FrontPen(a5)
 moveq #4,d0
 addq.w #2,d1
 move.l #'Choo',(a4)
 move.w #'se',4(a4)
 clr.b 6(a4)
 bsr TLText
 move.l #'Canc',(a4)
 move.w #'el',4(a4)
 move.l #240,d0
 bsr TLText

 moveq #0,d0               ;draw ld/sv buttons
 move.l #145,d1
 moveq #56,d2
 moveq #11,d3
 bsr TLReqbev
 move.l #236,d0
 bsr TLReqbev
 moveq #12,d0
 addq.w #2,d1
 move.l #'Save',(a4)
 clr.b 4(a4)
 bsr TLText
 move.l #'Load',(a4)
 move.l #248,d0
 bsr TLText

 moveq #56,d0             ;box around chosen pen
 move.l #134,d1
 move.l #180,d2
 moveq #22,d3
 bsr TLReqbev

 moveq #0,d4              ;intial pen

.colr:
 moveq #58,d0             ;* fill bot area with pen d4
 move.l #135,d1
 move.l #176,d2
 moveq #20,d3
 bset #29,d0
 bsr TLReqarea

 move.l d4,d0             ;initialise sliders for this pen
 mulu #12,d0
 clr.l 58(a4)             ;(d5=0 for hook)
 move.l #101,xxp_sliy(a4)
 move.l a3,50(a4)         ;(a3 data for hook)
 move.l d4,54(a4)         ;(d4 data for hook)
 move.l #.hook,xxp_hook(a4)
 clr.l xxp_tops(a4)
 move.b 4(a3,d0.w),xxp_tops+3(a4)
 bsr TLSlider
 addq.l #1,58(a4)         ;(d5=1 for hook)
 move.l #112,xxp_sliy(a4)
 clr.l xxp_tops(a4)
 move.b 8(a3,d0.w),xxp_tops+3(a4)
 bsr TLSlider
 addq.l #1,58(a4)          ;(d5=2 for hook)
 move.l #123,xxp_sliy(a4)
 clr.l xxp_tops(a4)
 move.b 12(a3,d0.w),xxp_tops+3(a4)
 bsr TLSlider

.wait:                     ;* wait for response
 bsr TLWfront
 bsr TLKeyboard

 cmp.b #$1B,d0
 beq .canc                 ;cancel if Esc
 cmp.b #$0D,d0
 beq .choo                 ;choose if Return
 cmp.b #$80,d0
 bne .wait                 ;go if not click
 cmp.w #145,d2             ;go if not load/save
 bcs.s .ucol
 cmp.w #56,d1              ;go if save button
 bcs .sav

 cmp.w #236,d1             ;go if load button, else keep waiting
 bcs .wait
 tst.l xxp_butl(a4)
 beq .bpdo                 ;go beep if choose only
 bsr .load
 bra .rcyc                 ;else load & redraw window

.ucol:
 cmp.w #134,d2
 bcs.s .ccol               ;go if not bot buts
 cmp.w #56,d1
 bcs .choo                 ;go if choose button
 cmp.w #236,d1
 bcc .canc                 ;go if cancel button
 bra .wait                 ;else keep waiting

.ccol:
 cmp.w #11,d2              ;go if pens not clicked
 bcs .wait
 cmp.w #101,d2
 bcc .csli
 sub.w #11,d2              ;d2 rel to pens box
 divu xxp_buth+2(a4),d2    ;d2=row num
 cmp.w d6,d2               ;go if > num of rows
 bcc .wait
 mulu d7,d2                ;get clms*rownum
 subq.w #2,d1
 bcs .wait                 ;d1 rel to pens box
 divu xxp_butw+2(a4),d1    ;d1=clm num
 cmp.w d7,d1
 bcc .wait                 ;go if > num of clms
 add.w d1,d2               ;d2=pen num
 move.w d2,d4              ;d4=pen num
 bra .colr                 ;go put this pen at bottom

.csli:
 move.l d4,d0              ;d0 ready to point to color
 mulu #12,d0
 cmp.w #40,d1              ;here if slides area
 bcs .wait                 ;go if left of slides
 cmp.w #134,d2
 bcc .wait                 ;go if below slides

 tst.l xxp_butl(a4)        ;beep if palette forbidden
 beq .bpdo

 cmp.w #112,d2
 bcs.s .csl0               ;bra to whichever slider
 cmp.w #123,d2
 bcs.s .csl1
 bra.s .csl2

.csl0:
 clr.l 58(a4)              ;d5=0/1/2 for r/g/b
 move.l #101,xxp_sliy(a4)  ;put sliy for slider
 clr.l xxp_tops(a4)
 move.b 4(a3,d0.l),xxp_tops+3(a4) ;initialise tops
 bra.s .cslc

.csl1:
 move.l #1,58(a4)
 move.l #112,xxp_sliy(a4)
 clr.l xxp_tops(a4)
 move.b 8(a3,d0.l),xxp_tops+3(a4)
 bra.s .cslc

.csl2:
 move.l #2,58(a4)
 move.l #123,xxp_sliy(a4)
 clr.l xxp_tops(a4)
 move.b 12(a3,d0.l),xxp_tops+3(a4)

.cslc:
 move.l #.hook,xxp_hook(a4) ;set hook
 bsr TLSlimon              ;update r/g/b
 bra .wait                 ;& recyc

.sav:                      ;* save selected
 tst.l xxp_butl(a4)
 beq.s .bpdo               ;go if choose only

 bsr .pref
 cmp.w #1,d0
 bgt .rcyc
 beq.s .use

 moveq #-1,d0              ;save to ENV:, ENVARC:
 bra.s .usep

.use:                      ;save to ENV:
 moveq #0,d0

.usep:
 bsr .save                 ;save prefs
 cmp.l #2,xxp_butl(a4)
 beq.s .close              ;quit if save only
 bra .rcyc                 ;else redraw & continue

.choo:                     ;* chose chosen
 cmp.l #2,xxp_butl(a4)
 bne.s .close              ;go unless palette only

.bpdo:                     ;beep & keep waiting
 bsr .beep
 bra .wait

.canc:                     ;* cancel chosen
 tst.l xxp_butl(a4)        ;(colors ok if D0 was 0)
 beq.s .cncp

 move.l xxp_gfxb(a4),a6    ;restore colors to at start
 move.l xxp_Screen(a4),a0
 add.l #sc_ViewPort,a0
 move.l a3,a1
 add.l #3076,a1
 jsr _LVOLoadRGB32(a6)

.cncp:
 moveq #-1,d4              ;xxp_errn = 0 if cancel

.close:
 bsr TLReqoff              ;close requester window, pop old window if any
 bra.s .done

.bad:
 moveq #-1,d4              ;too big/can't open window
 bra.s .done

.null:
 subq.w #1,xxp_ReqNull(a4) ;clear ReqNull
 moveq #0,d4               ;dummy choice=1
 bra.s .done

.oom:
 move.l #1,xxp_errn(a4)    ;out of public ram
 bra.s .badp

.v39:
 move.l #22,xxp_errn(a4)   ;needs lib vers 39+

.badp:
 moveq #-1,d4
 bra.s .pop

.done:
 move.l a3,a1              ;release rgb mem
 move.l xxp_sysb(a4),a6
 jsr _LVOFreeVec(a6)

.pop:
 move.l d4,d0              ;D0=0 if bad/cancel, else 1+=choice
 addq.l #1,d0
 bsr TLWslof               ;clear all message buffers
 add.w #xxp_WPort+4,a7     ;discard dummy IntuiText
 movem.l (a7)+,d1-d7/a0-a6

 move.l (a7)+,xxp_hook(a4) ;restore slider data
 move.l (a7)+,xxp_strs(a4)
 move.l (a7)+,xxp_totl(a4)
 move.l (a7)+,xxp_tops(a4)
 move.l (a7)+,xxp_slih(a4)
 move.l (a7)+,xxp_sliw(a4)
 move.l (a7)+,xxp_sliy(a4)
 move.l (a7)+,xxp_slix(a4)

 move.l (a7)+,xxp_butl(a4) ;restore button data
 move.l (a7)+,xxp_butk(a4)
 move.l (a7)+,xxp_btdy(a4)
 move.l (a7)+,xxp_btdx(a4)
 move.l (a7)+,xxp_buth(a4)
 move.l (a7)+,xxp_butw(a4)
 move.l (a7)+,xxp_buty(a4)
 move.l (a7)+,xxp_butx(a4)

 move.l (a7)+,xxp_strg(a4)
 move.l (a7)+,xxp_Help(a4)

 tst.l d0                  ;EQ, D0=0 if bad, else 1+ = choice
 rts

; TLReqcolor subroutine - load color map

.load:                     ;** here to load
 movem.l d0-d7/a0-a6,-(a7)

 move.l a4,a0
 add.l #104,a0             ;see that ENV:Tandem exists
 move.l #'Tand',(a0)
 move.w #'em',4(a0)
 clr.b 6(a0)
 moveq #0,d0
 bsr TLPrefdir
 beq .ldqt                 ;go if fails (unlikely)

 move.l #'/Col',6(a0)      ;see that ENV:Tandem/Colors exists
 move.l #'ors ',10(a0)
 clr.b 13(a0)
 moveq #0,d0
 bsr TLPrefdir
 beq .ldqt                 ;go if fails (unlikely)

 subq.l #4,a0
 move.l #'ENV:',(a0)       ;ENV:Tandem/Color at a0 = a4+100
 move.l a0,a1
 add.l #130,a1             ;fname at a4+230
 clr.b (a1)

 moveq #70,d0              ;get filename
 moveq #1,d1
 exg a0,a1
 bsr TLAslfile
 exg a0,a1
 tst.l d0
 beq.s .ldqt               ;go if asl failed/cancelled

 bsr TLOpenread            ;open file
 beq.s .ldqt               ;quit if can't

 move.l a3,d2              ;read up to 2^planes X 3 longwords bytes at a3+4
 addq.l #4,d2
 moveq #1,d3
 move.l xxp_Depth(a4),d0
 rol.l d0,d3               ;d3=no. of colors
 mulu #12,d3               ;d3=bytes in colour table
 bsr TLReadfile
 beq.s .ldqt               ;go if bad read
 bsr TLClosefile           ;close file

 move.l xxp_gfxb(a4),a6    ;set colours as read
 move.l xxp_Screen(a4),a0
 add.l #sc_ViewPort,a0
 move.l a3,a1
 move.l 3076(a3),-(a7)
 clr.l 3076(a3)
 jsr _LVOLoadRGB32(a6)
 move.l (a7)+,3076(a3)
 bra.s .ldbk

.ldqt:
 bsr .beep                 ;beep if load failed

.ldbk:
 movem.l (a7)+,d0-d7/a0-a6
 rts

; TLReqcolor "subroutine" - hook for slider

.hook:                     ;** process the slider
 move.l 50(a4),a3          ;retrieve data stored here by caller to TLSlider
 move.l 54(a4),d4
 move.l 58(a4),d5
 move.l d5,d0              ;point to color in pens data
 lsl.l #2,d0
 move.l d4,d1
 mulu #12,d1
 add.l d1,d0
 move.b xxp_tops+3(a4),4(a3,d0.w) ;put tops there
 move.b xxp_tops+3(a4),5(a3,d0.w)
 move.b xxp_tops+3(a4),6(a3,d0.w)
 move.b xxp_tops+3(a4),7(a3,d0.w)
 move.l xxp_gfxb(a4),a6
 move.l xxp_Screen(a4),a0  ;update this pen
 add.l #sc_ViewPort,a0
 move.l a4,a1              ;place data in buff
 move.w #1,(a1)
 move.w d4,2(a1)
 move.l d4,d0
 mulu #12,d0
 move.l 4(a3,d0.w),4(a4)
 move.l 8(a3,d0.w),8(a4)
 move.l 12(a3,d0.w),12(a4)
 clr.l 16(a4)
 jsr _LVOLoadRGB32(a6)
 move.l xxp_tops(a4),d0    ;put tops in box
 move.l a4,a0
 move.l #'    ',(a4)
 clr.b 4(a4)
 bsr TLHexasc
 move.w #$0103,xxp_FrontPen(a5)
 move.l d5,d1
 mulu #11,d1
 add.w #103,d1
 moveq #4,d0
 bsr TLText
 rts

; TLReqcolor subroutine - save color prefs

.save:                     ;** save cols d0=0use -1save a3=map (3076 bytes)
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l d0,d7              ;d7= -1save 0use

 move.l a4,a0
 add.l #104,a0             ;see that ENV:Tandem exists
 move.l #'Tand',(a0)
 move.w #'em',4(a0)
 clr.b 6(a0)
 bsr TLPrefdir
 beq .svbd                 ;go if fails (unlikely)

 move.l #'/Col',6(a0)      ;save as Tandem/Color  (= operative pref)
 move.w #'or',10(a0)
 clr.w 12(a0)
 move.l a3,d2              ;d2 = save from = colour table in a3+4
 addq.l #4,d2
 move.l #3072,d3           ;d3 = bytes = 256 * 12
 move.l d7,d0              ;d0 = -1 save  0 use
 bsr TLPreffil
 beq .svbd                 ;go if can't

 move.l d7,d0              ;see that ENV:Tandem/Colors exists
 move.b #'s',12(a0)
 bsr TLPrefdir
 beq .svbd                 ;go if fails (unlikely)

 subq.l #4,a0
 move.l #'ENV:',(a0)       ;ENV:Tandem/Colors at a0 = a4+100
 move.l a0,a1
 add.l #130,a1             ;get fname at a4+230
 clr.b (a1)
 moveq #69,d0              ;hail = string 69
 moveq #-1,d1              ;d1=-1 for asl save
 exg a0,a1
 bsr TLAslfile             ;get filename
 exg a0,a1

 tst.l d0
 beq.s .svbd               ;go if asl failed(unlikely)/cancelled

.fgot:
 cmp.l #'ENV:',(a0)+
 bne.s .svbd               ;quit if user muddled up volume

 move.l a0,a2              ;create path without vol in a0
.sva1:
 tst.b (a2)+               ;find end of dir
 bne .sva1
 move.b #'/',-1(a2)        ;append /
.sva2:
 move.b (a1)+,(a2)+        ;append filepart
 bne .sva2
 move.l d7,d0              ;save/use 3072 bytes from a3+4
 bsr TLPreffil             ;save as filename in ENV:Tandem/Colors
                           ;(no report if can't)
.svbd:
 movem.l (a7)+,d0-d7/a0-a6
 rts

; TLReqcolor subroutine - beep

.beep:
 movem.l d0-d1/a0-a1/a6,-(a7)
 move.l xxp_intb(a4),a6
 move.l xxp_Screen(a4),a0
 jsr _LVODisplayBeep(a6)
 movem.l (a7)+,d0-d1/a0-a1/a6
 rts

; TLReqcolor subroutine - clear requester

.clir:
 moveq #0,d0
 moveq #0,d1
 move.l #292,d2
 move.l #156,d3
 moveq #3,d4
 bset #29,d0
 bsr TLReqarea
 bclr #29,d0
 bsr TLReqbev
 rts

; TLreqcolor subroutine - choose Save/Use/Cancel

.pref:
 bsr .clir
 moveq #68,d0
 bsr TLStrbuf
 moveq #4,d0
 move.l #147,d1
 bsr TLText
 moveq #0,d0
 subq.w #1,d1
 moveq #97,d2
 moveq #10,d3
 bsr TLReqbev
 add.l d2,d0
 bsr TLReqbev
 add.l d2,d0
 addq.l #1,d2
 bsr TLReqbev

 move.l xxp_AcWind(a4),a5
 move.w #$0203,xxp_FrontPen(a5)
 moveq #2,d1
 moveq #57,d2
.prfp:
 move.l d2,d0
 bsr TLStrbuf
 moveq #4,d0
 bsr TLText
 move.b #$01,xxp_FrontPen(a5)
 addq.w #8,d1
 addq.w #1,d2
 cmp.w #68,d2
 bne .prfp

.prfw:
 bsr TLKeyboard
 cmp.b #$1B,d0
 beq.s .prfc
 cmp.b #$80,d0
 bne .prfw
 cmp.w #146,d2
 bcs .prfw
 cmp.w #194,d1
 bcc.s .prfc
 cmp.w #97,d1
 bcc.s .prfu

.prfs:
 moveq #0,d0
 rts

.prfu:
 moveq #1,d0
 rts

.prfc:
 moveq #2,d0
 rts

.strc: dc.b 0,'Select a name for the palette',0
.tabl: dc.b 0,0,1,2,1,4,1,8,2,8,4,8,8,8,8,16,8,32 ;cols,rows for planes

.strs: dc.b 0
 dc.b 'You are required to choose a pen',0 ;1    [task 0 help]
 dc.b 0 ;2
 dc.b 'First, click any of the colours in',0 ;3
 dc.b 'the table of colours. It will',0 ;4
 dc.b 'appear in the box at the bottom of  ',0 ;5
 dc.b 'the requester. If you want decide',0 ;6
 dc.b 'to choose it, click the "Choose"',0 ;7
 dc.b 'box, or else you can try another',0 ;8
 dc.b 'of the colours in the table.',0 ;9
 dc.b 0 ;10
 dc.b 'Else, click "Cancel" if you ',0 ;11
 dc.b 'decide you don''t want to choose a',0 ;12
 dc.b 'pen.',0 ;13
 dc.b 0 ;14
 dc.b 0 ;15
 dc.b 0 ;16
 dc.b 0 ;17
 dc.b 0 ;18

 dc.b 'Choose a pen ...',0 ;19               [task 1 help]
 dc.b 0 ;20
 dc.b 'Click any colour in the table to',0 ;21
 dc.b 'place it in the bottom box. Click   ',0 ;22
 dc.b '"Choose" to choose it.',0 ;23
 dc.b 'Else, click "Cancel" if you don''t',0 ;24
 dc.b 'want to make a choice.',0 ;25
 dc.b 0 ;26
 dc.b 'You can also load a palette with',0 ;27
 dc.b 'the "Load" button.',0 ;28
 dc.b 0 ;29
 dc.b 'You can adjust individual pens by',0 ;30
 dc.b 'clicking them into the bottom box',0 ;31
 dc.b '& using the sliders.',0 ;32
 dc.b 0 ;33
 dc.b 'If you click "Save" you can also ',0 ;34
 dc.b 'set the colour palette preferences.',0 ;35
 dc.b 0 ;36

 dc.b 'Adjust the colour palette ...',0 ;37    [task 2 help]
 dc.b 0 ;38
 dc.b 'Click any of the colours in the',0 ;39
 dc.b 'colour table to put it in the',0 ;40
 dc.b 'bottom box. When there, you can',0 ;41
 dc.b 'adjust it using the sliders.',0 ;42
 dc.b 0 ;43
 dc.b 'You can also load a palette that',0 ;44
 dc.b 'has previously been saved by',0 ;45
 dc.b 'clicking the "Load" button.',0 ;46
 dc.b 0 ;47
 dc.b 'Finally, click "Save" to keep the   ',0 ;48
 dc.b 'palette & perhaps save it to disk.',0 ;49
 dc.b 0 ;50
 dc.b 'Else, click Cancel (or press Esc)',0 ;51
 dc.b 'to cancel all changes.',0 ;52
 dc.b 0 ;53
 dc.b 0 ;54

 dc.b 'Choose a pen (<Help> available)',0 ;55
 dc.b 'Colour palette (<Help> available)',0;56

 dc.b 'You have chosen "Save"....',0 ;57
 dc.b 0 ;58
 dc.b 'You may choose "Save" below to',0 ;59
 dc.b 'save the palette in preferences',0 ;60
 dc.b '(permanently) for this program.',0 ;61
 dc.b 0 ;62
 dc.b 'Or, choose "Use" the palette',0 ;63
 dc.b 'temporarily for this program.',0 ;64
 dc.b 0 ;65
 dc.b 'Or, choose "Cancel" to cancel all',0 ;66
 dc.b 'changes to the palette.',0 ;67
 dc.b '   Save          Use       Cancel',0 ;68

 dc.b 'Specify a name for the color map...',0 ;69
 dc.b 'Choose a color map to load...',0 ;70
 ds.w 0

*>>>> create a prefs dir (unless already exists) a0=dirname d0: 0=use -1=sav
TLPrefdir:
 movem.l d1-d7/a0-a6,-(a7) ;save all
 clr.l xxp_errn(a4)
 sub.l #132,a7             ;workspace in stack
 move.l a7,a5
 move.l d0,d3              ;d3=0/-1
 move.l a0,a2              ;a2=dir
 move.l xxp_dosb(a4),a6    ;a6=dosbase
 move.l a5,a1              ;ENV: in buffer
 move.l #'ENV:',(a1)+
 bsr.s .item               ;create in ENV:
 beq.s .quit               ;go if can't
 tst.l d3
 beq.s .quit               ;go if use
 move.l a5,a1
 move.l #'ENVA',(a1)+      ;ENVARC: in buffer
 move.l #'RC: ',(a1)+
 subq.l #1,a1
 bsr.s .item               ;create in ENVARC:
.quit:
 tst.l d0
 add.l #132,a7
 movem.l (a7)+,d1-d7/a0-a6 ;EQ, D0=0 if bad
 rts
.item:                     ;** save in ENV/ENVARC
 move.l a2,a0              ;append dirname to dev
.dir:
 move.b (a0)+,(a1)+
 bne .dir
 move.l a5,d1              ;try to lock dir
 moveq #ACCESS_READ,d2
 jsr _LVOLock(a6)
 move.l d0,d1
 bne.s .good               ;go if exists
 move.l a5,d1
 jsr _LVOCreateDir(a6)     ;else, create it
 move.l d0,d1
 bne.s .good
 move.w #23,xxp_errn+2(a4) ;bad if can't create it
 moveq #0,d0
 rts
.good:
 jsr _LVOUnLock(a6)
 moveq #-1,d0
 rts

*>>>> save a prefs file (call TLPrefdir first with all except filepart)
; a0=path to be appended to ENV: or ENVARC:  D0: 0=use -1=save
; d2,d3=where, bytes
TLPreffil:
 movem.l d1-d7/a0-a6,-(a7) ;save all exc d0
 clr.l xxp_errn(a4)
 sub.l #132,a7             ;create workspace
 move.l a7,a5
 move.l a0,a2              ;a2=path
 move.l d0,d4              ;d3=0/-1
 move.l a5,a1              ;try to save in ENV:
 move.l #'ENV:',(a1)+
 bsr.s .save
 beq.s .done               ;bad if can't
 tst.l d4
 beq.s .done               ;done if use
 move.l a5,a1              ;try to save in ENVARC:
 move.l #'ENVA',(a1)+
 move.l #'RC: ',(a1)+
 subq.l #1,a1
 bsr.s .save               ;bad if can't
.done:
 tst.l d0
 add.l #132,a7
 movem.l (a7)+,d1-d7/a0-a6 ;EQ, D0=0 if bad
 rts

.save:                     ;** append path to vol & save (NE if ok)
 move.l a2,a0
.tfr:
 move.b (a0)+,(a1)+
 bne .tfr
 movem.l d1-d2/a0-a1/a6,-(a7) ;open file; name in (a5)
 move.l xxp_dosb(a4),a6
 move.l a5,d1
 move.l #MODE_NEWFILE,d2
 jsr _LVOOpen(a6)
 move.l d0,xxp_hndl(a4)     ;sv handle
 beq.s .bad
 movem.l (a7)+,d1-d2/a0-a1/a6
 beq.s .bad
 bsr TLWritefile
 beq.s .badc
 bsr TLClosefile

.good:
 moveq #-1,d0
 rts

.bad:
 movem.l (a7)+,d1-d2/a0-a1/a6
.badc:
 move.w #24,xxp_errn+2(a4) ;EQ, D0=0 if bad
 moveq #0,d0
 rts


*>>>> menu item on  d0=strip d1=item(-1 if none) d2=sub-item(-1 if none)
TLOnmenu:
 movem.l d0-d2/a0-a1/a5-a6,-(a7)
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 and.l #31,d0
 and.w #63,d1
 rol.w #5,d1
 or.w d1,d0
 and.w #31,d2
 ror.w #5,d2
 or.w d2,d0
 jsr _LVOOnMenu(a6)
 movem.l (a7)+,d0-d2/a0-a1/a5-a6
 rts


*>>>> menu item on  d0=strip d1=item(-1 if none) d2=sub-item(-1 if none)
TLOffmenu:
 movem.l d0-d2/a0-a1/a5-a6,-(a7)
 move.l xxp_intb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 and.l #31,d0
 and.w #63,d1
 rol.w #5,d1
 or.w d1,d0
 and.w #31,d2
 ror.w #5,d2
 or.w d2,d0
 jsr _LVOOffMenu(a6)
 movem.l (a7)+,d0-d2/a0-a1/a5-a6
 rts


*>>>> get an ILBM file into a bitmap

; D0: -1=load BMHD,CMAP and BODY.  0=load BMHD/CMAP only
; D1 = maxnum of bitplanes to load (set bit 31 to use public mem, else chip)

; A1    = 790 byte buffer for BMHD,CMAP
;         (loads BMHD in bytes 0-19, CMAPsize in bytes 20-21, CMAP in 22+)
;         (loads CMAP as 3 bytes per colour, so 256 colours = 768 bytes)

; returns A0 = address of bitmap created (unless D0 was 0)

; ***** Important!! *******
; The Bitmap & its bitplanes will be created by _LVOAllocVec,
; NOT TLpublic/TLchip. When finished with it, pass its address to TLfreebmap

TLGetilbm
 movem.l d0-d7/a0-a6,-(a7) ;save all, exc if result in A0
 clr.l xxp_errn(a4)

 bsr TLOpenread            ;open file
 beq .bad1                 ;bad if can't

 moveq #12,d3              ;read file header
 moveq #12,d7
 bsr .read
 beq .bad

 cmp.l #'FORM',(a4)        ;validate header, initiate byte count
 bne .bad2
 cmp.l #'ILBM',8(a4)
 bne .bad3
 move.l 4(a4),d7
 subq.l #4,d7
 ble .bad4

 moveq #0,d6               ;d6 = 0 until BMHD found
 clr.w 20(a1)              ;buffer+20 = CMAP size (0 if none)

.chnk:                     ;* scan chunks for CMAP,BMHD,BODY (ignore others)
 moveq #8,d3               ;read next chunk...
 bsr .read                 ;get chunk header
 beq .bad                  ;bad if can't
 move.l 4(a4),d3           ;d3=chunk size
 beq .chnk                 ;ignore if null size
 cmp.l d3,d7
 bcs .bad4                 ;bad if less bytes left than chunk size

 cmp.l #'CMAP',(a4)
 beq .cmap                 ;go if CMAP
 cmp.l #'BODY',(a4)
 beq .body                 ;go if BODY
 cmp.l #'BMHD',(a4)
 beq.s .bmhd               ;go if BMHD

 bsr .skip                 ;discard all other chunks
 sub.l d3,d7
 bra .chnk

.bmhd:                     ;* bmhd found
 tst.l d6
 bne .bad4                 ;bad if duplicate BMHD
 moveq #-1,d6              ;flag found
 cmp.l #20,d3
 bne .bad4                 ;bad unless size=20
 move.l a1,d2
 bsr .rdcu                 ;read into a1 buffer
 beq .bad
 cmp.b #1,10(a1)
 bhi .bad5                 ;bad unless compression = 0(none), 1(cmpbyterun)
 tst.b 8(a1)
 beq .bad4
 cmp.b #9,8(a1)            ;bad if planes=0, or >8
 bcc .bad4
 tst.w (a1)                ;bad if width=0, or >2048
 beq .bad4
 cmp.w #2049,d0
 bcc .bad4
 tst.w 2(a1)               ;bad if height=0, or >2048
 beq .bad4
 cmp.w #2049,2(a1)
 bcc .bad4
 bra .chnk                 ;to next chunk

.cmap:                     ;* cmap found
 tst.w 20(a1)
 bne .bad4                 ;bad if duplicate cmap
 cmp.l #768,d3
 bhi .bad4                 ;bad if > 256*3 bytes
 move.w d3,20(a1)          ;put CMAP size in 20(a1)
 move.l a1,d2
 add.l #22,d2
 bsr .rdcu                 ;read into 22(a1)
 beq .bad                  ;bad if can't
 bra .chnk                 ;to next chunk

.body:                     ;* body found
 tst.l d6
 beq .bad4                 ;bad if bmhd absent
 cmp.l d7,d3
 bhi .bad4                 ;bad if chunk size > remaining bytes
 tst.l (a7)
 beq .done                 ;done if load BMHD,CMAP only

 move.l 4(a7),d5           ;set d5 = planes in bitmap
 cmp.b 8(a1),d5
 ble.s .rows
 move.b 8(a1),d5
.rows:

 moveq #0,d6
 move.w (a1),d6            ;set d6 = bytes per row in bitplanes
 add.w #15,d6
 lsr.w #4,d6
 lsl.w #1,d6

 move.l xxp_sysb(a4),a6    ;create bitmap, point A3 to bitmap
 moveq #bm_SIZEOF,d0
 moveq #MEMF_PUBLIC,d1
 move.l a1,-(a7)
 jsr _LVOAllocVec(a6)
 move.l (a7)+,a1
 tst.l d0
 beq .bad7
 move.l d0,a3

 move.l a3,a2              ;fill in bitmap elements
 move.w d6,(a2)+           ;bm_BytesPerRow
 move.w 2(a1),(a2)+        ;bm_Rows
 clr.b (a2)+               ;bm_Flags
 move.b d5,(a2)+           ;bm_Depth
 clr.w (a2)+               ;bm_Pad

 move.w d5,d2              ;allocate bitplanes - d2 counts
 subq.w #1,d2
 move.w 2(a1),d3           ;d3 = bytes each bitplane
 mulu d6,d3
 move.l a4,a5              ;(set up bitplane pointers at buff+480)
 add.w #480,a5
.bmap:                     ;for each plane...
 move.l d3,d0
 moveq #MEMF_CHIP,d1
 tst.l 4(a7)
 bpl.s .chip
 moveq #MEMF_PUBLIC,d1     ;(if input D1 had bit 31, use public mem)
.chip:
 move.l a1,-(a7)
 jsr _LVOAllocVec(a6)      ;allocate mem
 move.l (a7)+,a1
 tst.l d0
 beq.s .bmbd               ;go if can't
 move.l d0,(a2)+           ;else, put in next pointer
 move.l d0,(a5)+           ;& in bitplane pointers
 dbra d2,.bmap             ;until all allocated
 bra.s .bmok               ;go bitmap is ready

.bmbd:
 bsr .kill                 ;kill partially allocated bitmap
 bra .bad6                 ;& go report out of chip ram

.bmok:
 tst.b 10(a1)              ;go if compressed
 bne.s .comr

 move.l d6,d3              ;* read uncompressed  - d3 = bytes per row
 move.w 2(a1),d6
 subq.w #1,d6              ;d6 counts scanlines
.slin:                     ;for each scanline...

 move.l a4,a5              ;point to bitplane pointers
 add.w #480,a5
 move.w d5,d4              ;d4 counts bitplanes
 subq.w #1,d4

.slip:                     ;read a bitplane
 move.l (a5),d2            ;d2 = where
 bsr TLReadfile            ;read it
 beq .badr                 ;bad if can't
 add.l d3,(a5)+            ;bump pointer
 dbra d4,.slip             ;until all bitplanes read

 moveq #0,d4
 move.b 8(a1),d4           ;d4 = bitplanes in file
 sub.w d5,d4               ;sub bitplanes read
 beq.s .slis               ;go if all read
 mulu d3,d4                ;else, * bytes per plane = bytes to skip
 exg d3,d4
 bsr .skip                 ;skip unwanted bitplanes
 exg d3,d4

.slis:
 dbra d6,.slin             ;until all scanlines done
 move.l a3,32(a7)          ;put bitmap into stack a0 (= result)
 bra .done                 ;return ok

.comr:                     ;* read compressed

 move.l a4,a6              ;init input buffer pointer
 clr.w 478(a4)
 move.l d6,d3              ;d3 = bytes per row
 move.w 2(a1),d6
 subq.w #1,d6              ;d6 counts scanlines
.comn:                     ;for each scanline...

 move.l a4,a5              ;point to bitplane pointers
 add.w #480,a5
 move.w d5,d4              ;d4 counts bitplanes
 subq.w #1,d4

.comp:                     ;read a bitplane
 move.l (a5),a2            ;d2 = where
 move.w d3,d1              ;d1 counts bytes in row

.item:
 bsr .byte                 ;check input buffer
 beq.s .badr               ;go if bad read
 moveq #0,d0
 move.b (a6)+,d0           ;get next type of thing
 bmi.s .mult
 sub.w d0,d1
 subq.w #1,d1
 bmi .bad4
 move.w d0,d7
.iget:
 bsr .byte
 beq.s .badr
 move.b (a6)+,(a2)+
 dbra d7,.iget
 tst.w d1
 bne .item
 bra.s .itfn

.mult:
 neg.b d0
 bmi .item
 sub.w d0,d1
 subq.w #1,d1
 bmi .bad4
 move.w d0,d7
 bsr.s .byte
 beq.s .badr
 move.b (a6)+,d0
.mulp:
 move.b d0,(a2)+
 dbra d7,.mulp
 tst.w d1
 bne .item

.itfn:
 add.l d3,(a5)+            ;bump pointer
 dbra d4,.comp             ;until all bitplanes read

 moveq #0,d4
 move.b 8(a1),d4           ;d4 = bitplanes in file
 sub.w d5,d4               ;subtract bitplanes read
 beq.s .coms               ;go if all read
 mulu d3,d4                ;else, * bytes per plane = bytes to skip
 exg d3,d4
 bsr .skip                 ;skip unwanted bitplanes
 exg d3,d4

.coms:
 dbra d6,.comn             ;until all scanlines done
 move.l a3,32(a7)          ;put bitmap into stack a0 (= result)
 bra.s .done               ;return ok

.badr:                     ;here if bitplane reading fails
 bsr .kilr
 bra.s .bad
.bad1:                     ;can't open file
 moveq #25,d0
 bra.s .bad
.bad2:                     ;not IFF
 moveq #26,d0
 bra.s .bad
.bad3:                     ;not ILBM
 moveq #27,d0
 bra.s .bad
.bad4:                     ;garbled
 moveq #28,d0
 bra.s .bad
.bad5:                     ;unrecognised compression mode
 moveq #29,d0
 bra.s .bad
.bad6:                     ;out of chip RAM
 moveq #2,d0
 bra.s .bad
.bad7:                     ;out of public RAM
 moveq #1,d0
.bad:
 move.l d0,xxp_errn(a4)

.done:
 bsr TLClosefile           ;close file if still open
 movem.l (a7)+,d0-d7/a0-a6
 tst.l xxp_errn(a4)
 eori.w #-1,CCR            ;EQ, errn<> if bad
 rts

; subroutine for TLGetilbm - check compressed input buffer non-empty

.byte:
 subq.w #1,478(a4)         ;dec input buffer count
 ble.s .bytf
 rts                       ;return if some, NE
.bytf:
 bne.s .bytr               ;go replenish if none
 eori.w #-1,CCR            ;set NE
 rts
.bytr:
 movem.l d0/d2-d3,-(a7)    ;replenish input buffer
 move.l #478,d3            ;read 478 (ok if <478 still there)
 move.w d3,478(a4)         ;replenish buffer count
 move.l a4,d2              ;read to buff
 move.l a4,a6              ;a6 points to input buffer
 bsr TLReadfile            ;read
 movem.l (a7)+,d0/d2-d3
 bne .byte
 rts                       ;EQ if bad

; subroutine for TLGetilbm - read d3 bytes to xxp_buff, d7 is countdown

.read:                     ;** 1st entry point - read to (a4)
 move.l a4,d2
.rdcu:                     ;** 2nd entry point - read to (d2)
 bsr TLReadfile
 beq .rbad
 cmp.l d0,d3               ;bad if d3 bytes not read
 bne.s .rbad
 sub.l d0,d7               ;dec countdown
 bcc.s .rdon
.rbad:
 move.w #28,xxp_errn+2(a4)
.rdon:
 tst.w xxp_errn+2(a4)
 eori.w #-1,CCR            ;EQ, errn<> if bad
 rts

; subroutine for TLGetilbm - skip d3 bytes forward in file

.skip:
 movem.l d0-d3/a0-a1/a6,-(a7) ;save all exc d7 updated
 move.l xxp_dosb(a4),a6
 move.l xxp_hndl(a4),d1
 move.l d3,d2
 moveq #OFFSET_CURRENT,d3  ;seek d3 past current posn
 jsr _LVOSeek(a6)
 movem.l (a7)+,d0-d3/a0-a1/a6
 rts

; subroutine for TLGetilbm - kill bitmap  (at a3)

.kilr:                     ;** 1st entry point - kill entire
 move.l a3,a2
 add.w #bm_Planes,a2       ;point a2 past last plane
 moveq #0,d0
 move.b bm_Depth(a3),d0
 lsl.l #2,d0
 add.l d0,a2

.kill:                     ;** 2nd entry point - a2 points past last plane
 add.w #bm_Planes,a3
 cmpa.l a3,a2              ;go if all deallocated
 sub.w #bm_Planes,a3
 beq.s .kldn
 move.l -(a2),a1           ;free bitplanes in reverse order
 move.l xxp_sysb(a4),a6
 jsr _LVOFreeVec(a6)
 bra .kill
.kldn:
 move.l a3,a1              ;deallocate bitmap itself
 jsr _LVOFreeVec(a6)
 rts


*>>>> put a bitmap to an ILBM file
; D0,D1 = topleft  }these will be validated; D0 will be rounded up div by 8
; D2,D3 = size     }either 0 for whole bmap; D2 will be rounded up div by 16
; A0    = bitmap
; makes CMAP from xxp_Screen colours)(none if bmap planes > screen planes)
; fname in buff
; returns D0=0 if bad, error in xxp_errn
TLPutilbm:
 movem.l d0-d7/a0-a6,-(a7) ;save all exc d0
 movem.l d0-d3,-(a7)       ;working values of d0-d3
 move.l a0,a5              ;a5 = bitmap
 bsr TLBusy
 clr.l xxp_errn(a4)
 move.w (a0),d4            ;* validate d0-d3 (in stack working vals)
 lsl.w #3,d4               ;d4=bitmap width in pixels
 tst.w d2
 bne.s .val1               ;go if d2<>0
 move.w d4,d2              ;if d2=0, use bitmap width
.val1:
 add.w #15,d2              ;make sure d2 divisible by 16
 and.w #$FFF0,d2
 bne.s .val2
 moveq #16,d2              ;(min width 16)
.val2:
 cmp.w d4,d2               ;go if d2 <= bitmap width
 bls.s .val3
 move.w d4,d2              ;else, let d2 = bitmap width
.val3:
 move.w d2,8+2(a7)         ;store corrected d2
 sub.w d2,d4               ;d4 = max possible d0
 cmp.w d4,d0
 bls.s .val4               ;go if d0 <= max possible
 move.w d4,d0              ;else, let d0 = max possible
.val4:
 move.w d0,0+2(a7)         ;store corrected d0
 move.w 2(a0),d4           ;d4 = bitmap height
 tst.w d3
 bne.s .val5               ;go if input d3 <> 0
 move.w d4,d3              ;else, let d3 = bitmap height
.val5:
 cmp.w d4,d3               ;go if d3 <= bitmap height
 bls.s .val6
 move.w d4,d3              ;else d3 = bitmap height
.val6:
 move.w d3,12+2(a7)        ;store corrected d3
 sub.w d3,d4               ;d4 = max possible d1
 cmp.w d4,d1
 bls.s .val7               ;go if d1 <= max possible
 move.w d4,d1              ;else, let d1 = max possible
.val7:
 move.w d1,4+2(a7)         ;store corrected d1
 moveq #0,d7               ;* get colour map from screen
 move.b bm_Depth(a5),d7    ;d7 = no. of planes in bitmap
 moveq #1,d6
 lsl.w d7,d6               ;d6 = no. of colours
 move.l d6,d0
 mulu #12,d0               ;(colour map has 12 bytes per colour)
 move.l xxp_sysb(a4),a6
 moveq #MEMF_PUBLIC,d1
 jsr _LVOAllocVec(a6)
 move.l d0,a3              ;a3 = mem for colour map (0 if none)
 tst.l d0
 beq .bad0
 move.l xxp_Screen(a4),a1  ;get screen colours into colour map
 add.l #sc_ViewPort,a1
 move.l vp_ColorMap(a1),a0 ;a0=colour map
 move.l a3,a1              ;a1=table in stack
 moveq #0,d0               ;get from colour 0
 move.l d6,d1              ;get no. of colours
 move.l xxp_gfxb(a4),a6
 jsr _LVOGetRGB32(a6)      ;get CMAP data from xxp_Screen
 move.l a3,a0              ;a3 gets RGB32 data
 move.l a3,a1              ;a1 puts in CMP format
 move.w d6,d1
 subq.w #1,d1
.cmap:
 move.l (a0)+,d0
 move.b d0,(a1)+
 move.l (a0)+,d0
 move.b d0,(a1)+
 move.l (a0)+,d0
 move.b d0,(a1)+
 dbra d1,.cmap
 move.l a1,d5              ;d5 = bytes in CMAP
 sub.l a3,d5
 addq.w #3,d5              ;round d5 up to nearest longword
 and.w #$FFFC,d5
 move.w 8+2(a7),d4         ;d4 = bytes in BODY
 lsr.w #3,d4
 mulu d7,d4
 mulu 12+2(a7),d4
 bsr TLOpenwrite           ;* open file
 beq .bad1                 ;bad if can't
 move.l a4,a0              ;* create header in buff
 move.l #'FORM',(a0)+      ; 0
 move.l #48,(a0)           ; 4  next 40 + BODY header = 48
 add.l d4,(a0)             ;    + bytes in BODY
 add.l d5,(a0)+            ;    + bytes in CMAP
 move.l #'ILBM',(a0)+      ; 8
 move.l #'BMHD',(a0)+      ; 12
 move.l #20,(a0)+          ; 16
 move.w 8+2(a7),(a0)+      ; 20 width
 move.w 12+2(a7),(a0)+     ;    height
 clr.l (a0)+               ; 24 null posn
 move.b d7,(a0)+           ; 28 planes
 clr.b (a0)+               ;    null masking
 clr.w (a0)+               ;    null compression,pad
 clr.w (a0)+               ; 32 null transparent
 move.w #$0A0B,(a0)+       ;    nominal aspect ration
 move.l 20(a4),(a0)+       ; 36 page size = pic size
 move.l #'CMAP',(a0)+      ; 40
 move.l d5,(a0)+           ; 44 CMAP size
 move.l a4,d2
 moveq #48,d3              ;* send the above 48 bytes
 bsr TLWritefile
 beq .bad2
 move.l a3,d2              ;* send CMAP
 move.l d5,d3
 bsr TLWritefile
 beq .bad2
 move.l #'BODY',(a4)       ;* send BODY header
 move.l d4,4(a4)
 move.l a4,d2
 moveq #8,d3
 bsr TLWritefile
 beq .bad2
 moveq #0,d4
 move.w bm_BytesPerRow(a5),d4 ;* send BODY
 mulu 4+2(a7),d4
 moveq #0,d5
 move.w 0+2(a7),d5
 lsr.w #3,d5
 add.l d5,d4               ;d4 = displacement (bytesperrow*ypos + xpos/8)
 move.w 12+2(a7),d5
 subq.w #1,d5              ;d5 counts rows
.row:
 move.l a5,a0              ;a0 gets planes
 add.w #bm_Planes,a0
 move.w d7,d6              ;d6 counts planes
 subq.w #1,d6
.plan:
 move.l (a0)+,d2           ;get plane
 add.l d4,d2               ;add disp
 moveq #0,d3
 move.w 8+2(a7),d3         ;send width/8 bytes
 lsr.w #3,d3
 bsr TLWritefile
 beq .bad2
 dbra d6,.plan
 add.w bm_BytesPerRow(a5),d4 ;bump disp after each row
 dbra d5,.row
.good:
 moveq #-1,d0              ;D0<>0 if ok
 bra.s .wrap
.bad0:                     ;* out of public memory (unlikely)
 moveq #1,d0
 bra.s .bad
.bad1:                     ;* can't open file
 moveq #4,d0
 bra.s .bad
.bad2:                     ;* can't write file
 moveq #6,d0
.bad:
 move.l d0,xxp_errn(a4)    ;set error code (0 if good)
 moveq #0,d0               ;D0=0 if bad
.wrap:
 add.w #16,a7              ;discard working values of d0-d3
 move.l d0,16(a7)          ;return d0 value
 move.l a3,d0
 beq.s .done               ;free the bitmap memory (if any)
 move.l xxp_sysb(a4),a6
 move.l d0,a1
 jsr _LVOFreeVec(a6)
.done:
 bsr TLClosefile           ;close file if open
 bsr TLUnbusy
 tst.l (a0)                ;EQ if bad
 movem.l (a7)+,d0-d7/a0-a6
 rts


*>>>> resize a region of a rastport

; D0,D1 = topleft
; D2,D3 = old size
; D4,D5 = new size
; D6    = pen to fill exposed blank areas
; A0    = rastport (if bit 31 of d0 set, else 0)

TLResize:
 movem.l d0-d7/a0-a6,-(a7) ;save all regs
 clr.l xxp_errn(a4)
 move.l xxp_gfxb(a4),a6

 sub.l a5,a5               ;a5 = 0 if not to window
 move.l a0,a3              ;a3 = rastport to draw to
 tst.l d1
 bmi.s .rpor
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a3
 bclr #31,d1
 add.w xxp_LeftEdge(a5),d0 ;if window, offset d0,d1 by edges
 add.w xxp_TopEdge(a5),d1
.rpor:

 movem.l d0-d1,-(a7)       ;set pen & drawmode for clearing exposed areas
 move.l d6,d0
 move.l a3,a1
 jsr _LVOSetAPen(a6)
 moveq #RP_JAM2,d0
 move.l 8(a7),a0
 jsr _LVOSetDrMd(a6)
 movem.l (a7)+,d0-d1

 movem.l d0-d5,-(a7)       ;keep d0-d5 for vert

 move.l a3,a0              ;regs for ClipBlit
 move.l a3,a1
 sub.l a2,a2

 cmp.w d2,d4               ;* horz: go if wider/narrower/same width
 beq .hzeq
 bcc .hzgt

.hzlt:                     ;* shrink horizontal
 move.l d2,d6
 subq.w #1,d6              ;d6 = old width - 1
 move.l d4,d7
 subq.w #1,d7              ;d7 = new width - 1
 move.l d3,d5              ;d5 = (old) height
 move.w d6,d3              ;d3 counts through old width
 moveq #0,d4               ;d4 moves along old xpos
 moveq #-1,d2              ;d2 = previous new xpos

.lhnx:
 movem.l d0-d7/a0-a1,-(a7)
 move.l d4,d2              ;d4 = old xpos
 mulu d7,d2
 divu d6,d2                ;d2 = new xpos
 and.l #$0000FFFF,d2
 move.w #$00C0,d6          ;minterm = jam 2
 cmp.l 8(a7),d2
 bne.s .lhj2               ;go if new xpos <> previous new xpos
 move.w #$00E0,d6          ;else, minterm = jam 1
.lhj2:
 move.l d2,8(a7)           ;note new xpos for next time
 cmp.l d2,d4
 beq.s .lhfw               ;go if old xpos = new xpos
 add.l d0,d2               ;d2 = to xpos
 add.l d4,d0               ;d0 = from ypos
 moveq #1,d4               ;copy a single file
 move.l d1,d3              ;d3 = to ypos
 moveq #-1,d7              ;copy all planes
 cmpa.w #0,a5
 beq.s .clp0
 bsr TLWCheck
 bne .bad
.clp0:
 jsr _LVOClipBlit(a6)

.lhfw:
 movem.l (a7)+,d0-d7/a0-a1
 addq.w #1,d4              ;bump old xpos
 dbra d3,.lhnx             ;until all done

 add.w d7,d0               ;clear exposed area: d0 = its lhs
 addq.l #1,d0
 sub.l d7,d6               ;d2 = its rhs
 move.l d0,d2
 add.w d6,d2
 subq.w #1,d2
 move.l d5,d3
 add.w d1,d3               ;d1 = its top
 subq.w #1,d3              ;d3 = its bot
 move.l a0,-(a7)
 cmp.w #0,a5
 beq.s .clp1
 bsr TLWCheck
 bne .bad
.clp1:
 jsr _LVORectFill(a6)      ;fill exposed area with BgPen
 move.l (a7)+,a0
 bra .hzeq

.hzgt:                     ;* expand horizontal
 move.l d2,d6
 subq.w #1,d6              ;d6 = old width - 1
 move.l d4,d7
 subq.w #1,d7              ;d7 = new width - 1
 move.l d3,d5              ;d5 = (old) height
 move.l d1,d3              ;d3 = ypos to
 move.l d7,d4              ;d4 counts along new xpos

.mhnx:
 movem.l d0-d7/a0-a1,-(a7)
 move.l d4,d2              ;d2 = old xpos to put to new xpos
 mulu d6,d2
 divu d7,d2
 and.l #$0000FFFF,d2
 cmp.w d2,d4               ;go if same
 beq.s .mhfw
 add.w d0,d4
 add.w d2,d0               ;d0 = from xpos
 move.w d4,d2              ;d2 = to xpos
 moveq #1,d4
 move.w #$00C0,d6          ;d6 = JAM2
 moveq #-1,d7
 cmp.w #0,a5
 beq.s .clp2
 bsr TLWCheck
 bne .bad
.clp2:
 jsr _LVOClipBlit(a6)      ;tfr the line
.mhfw:
 movem.l (a7)+,d0-d7/a0-a1
 subq.l #1,d4              ;until all done
 bpl .mhnx

.hzeq:

 movem.l (a7)+,d0-d5       ;restore d0-d5 from before horz

 cmp.w d3,d5               ;* vertical: compare new height - old height
 beq .quit
 bcc .vtgt

.vtlt:                     ;* reduce vertical
 move.l d3,d6
 subq.w #1,d6              ;d6 = old height - 1
 move.l d5,d7
 subq.w #1,d7              ;d7 = new height - 1         d4 = (new) width
 move.w d6,d2              ;d3 counts through old height
 moveq #0,d5               ;d5 moves along old ypos
 moveq #-1,d3              ;d3 = previous new ypos

.lvnx:
 movem.l d0-d7/a0-a1,-(a7)
 move.l d5,d3              ;d5 = old ypos
 mulu d7,d3
 divu d6,d3                ;d3 = new xpos
 and.l #$0000FFFF,d3
 move.w #$00C0,d6          ;minterm = jam 2
 cmp.l 12(a7),d3
 bne.s .lvj2               ;go if new ypos <> previous new ypos
 move.w #$00E0,d6          ;else, minterm = jam 1
.lvj2:
 move.l d3,12(a7)          ;note new ypos for next time
 cmp.l d3,d5
 beq.s .lvfw               ;go if old ypos = new ypos
 add.l d1,d3               ;d3 = to ypos
 add.l d5,d1               ;d1 = from ypos
 moveq #1,d5               ;copy a single rank
 move.l d0,d2              ;d2 = to xpos
 moveq #-1,d7              ;copy all planes
 cmp.w #0,a5
 beq.s .clp3
 bsr TLWCheck
 bne .bad
.clp3:
 jsr _LVOClipBlit(a6)
.lvfw:
 movem.l (a7)+,d0-d7/a0-a1

 addq.w #1,d5              ;bump old ypos
 dbra d2,.lvnx             ;until all done

 add.w d7,d1               ;clear exposed area: d1 = its top
 addq.l #1,d1
 sub.l d7,d6               ;d3 = its bot
 move.l d1,d3
 add.w d6,d3
 subq.w #1,d3
 move.l d4,d2
 add.w d0,d2               ;d0 = its lhs
 subq.w #1,d2              ;d2 = its rhs
 move.l a0,-(a7)
 cmp.w #0,d5
 beq.s .clp4
 bsr TLWCheck
 bne.s .bad
.clp4:
 jsr _LVORectFill(a6)      ;fill exposed area with BgPen
 move.l (a7)+,a0
 bra .quit

.vtgt:                     ;* expand vertical
 move.l d3,d6
 subq.w #1,d6              ;d6 = old height - 1
 move.l d5,d7
 subq.w #1,d7              ;d7 = new height - 1       d4 = (new) width
 move.l d0,d2              ;d2 = xpos to
 move.l d7,d5              ;d5 counts along new ypos

.mvnx:
 movem.l d0-d7/a0-a1,-(a7)
 move.l d5,d3              ;d3 = old ypos to put to new ypos
 mulu d6,d3
 divu d7,d3
 and.l #$0000FFFF,d3
 cmp.w d3,d5               ;go if same
 beq.s .mvfw
 add.w d1,d5
 add.w d3,d1               ;d1 = from ypos
 move.w d5,d3              ;d3 = to ypos
 moveq #1,d5
 move.w #$00C0,d6          ;d6 = JAM2
 moveq #-1,d7
 cmp.w #0,a5
 beq.s .clp5
 bsr TLWCheck
 bne.s .bad
.clp5:
 jsr _LVOClipBlit(a6)      ;tfr the line
.mvfw:
 movem.l (a7)+,d0-d7/a0-a1

 subq.l #1,d5              ;until all done
 bpl .mvnx
 bra.s .quit

.bad:                      ;bad if window resized
 move.w #35,xxp_errn+2(a4)

.quit:
 movem.l (a7)+,d0-d7/a0-a6
 tst.l xxp_errn(a4)
 eori.w #-1,CCR            ;EQ, errn<> if bad (i.e. window resized)
 rts


*>>>> draw an ellipse - clipped if required

; D0 = x centre  (bit 31 of D0 set if solid, else outline)
; D1 = y centre  (bit 31 of D1 set if rastport, else use AcWind)
; D2 = x radius
; D3 = y radius
; D4 = xmin
; D5 = ymin
; D6 = xmax
; D7 = ymax
; A0 = rastport if D1 bit 31 set, else ignored

TLEllipse:

; stack offsets
.xval: equ 60              ;xval for dots
.yval: equ 64              ;yval for dots
.a2b2: equ 68              ;a^2 * b^2 } for calulating dot posns
.a2x2: equ 72              ;a^2 * 2   }
.aint: equ 76
.ind0: equ 80              ;input d0
.ind1: equ 84              ;input d1

 movem.l d0-d1,-(a7)       ;save input d0 prior to modifying it
 clr.l xxp_errn(a4)
 bclr #31,d0               ;clear bit 31 of input d0,d1
 bclr #31,d1
 sub.w #20,a7              ;a7+60 = .xval  etc.
 movem.l d0-d7/a0-a6,-(a7) ;save all (60 bytes)

 move.l xxp_gfxb(a4),a6    ;if window, xxp_FrontPen in its rastport
 tst.l .ind1(a7)
 bmi.s .penc
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 moveq #0,d0
 move.b xxp_FrontPen(a5),d0
 jsr _LVOSetAPen(a6)
.penc:

 sub.l a3,a3               ;a3 = 0 if solid, else a3 = 1
 tst.l .ind0(a7)
 bmi.s .redi
 addq.l #1,a3

.redi:
 move.l 8(a7),d2
 move.l 12(a7),d3

 moveq #-1,d7              ;d7 = scale
 move.l d2,d6
 mulu d3,d6                ;d6 = X * Y (scale so X * Y < $10000)
 swap d6
 lsl.w #1,d6               ;d6 = upper word of product * 2
.scal:
 addq.l #1,d7              ;d7 = scale factor (0+)
 lsr.w #1,d6               ;shift upper word of product until clear
 bne .scal
 lsr.l d7,d2               ;scale d2 down d7 places, so X * Y < $10000

 move.l d2,d0              ;d0 = a
 move.l d3,d1              ;d1 = b

 cmpa.w #0,a3
 bne.s .sw0
 exg d0,d1                 ;if a3 = 0, switch a,b
.sw0
 move.l d0,.aint(a7)

 clr.l .xval(a7)
 subq.l #1,.xval(a7)       ;xval = -1
 move.l d1,.yval(a7)       ;yval = b
 move.l d1,d6
 mulu d1,d6
 move.l d6,d4              ;d4 = +b²
 move.l d6,d5              ;d5 = -3b²
 mulu #3,d5
 neg.l d5
 lsl.l #1,d6               ;d6 = 2b²
 move.l d0,d3              ;d1 = a²b²    (d3 = ab)
 mulu d1,d3
 move.l d3,d1
 mulu d3,d1
 move.l d1,.a2b2(a7)       ;save a²b²
 mulu d0,d3
 lsl.l #1,d3               ;(d3 = 2ba²)
 move.l d0,d2
 mulu d0,d2
 add.l d2,d3               ;d3 = 2ba²+a²
 lsl.l #1,d2               ;(d2 = 2a²)
 move.l d2,.a2x2(a7)       ;save 2a²
 move.l d1,d2              ;d2 = b²a²

.dotx:                     ;* to next xdot
 addq.l #1,.xval(a7)       ;xval = 0        1             2
 add.l d6,d5               ;d5   = -b²      b²            3b²
 add.l d5,d4               ;d4   = 0        1b²           4b²

.doty:                     ;find corresponding ydot
 move.l .a2b2(a7),d0       ;is yval too big?
 sub.l d4,d0               ;(equation of ellipse: a²b²-b²x²-a²y²=0)
 sub.l d2,d0
 bcc.s .dotr               ;not too big, accept
 subq.l #1,.yval(a7)       ;yval = b        b-1           b-2
 bmi.s .dotf               ;go if yval underflow (can't happen?)
 sub.l .a2x2(a7),d3        ;d3   = 2ba²+a²  2ba²-a²       2ba²-3a²
 sub.l d3,d2               ;d2   = b²a²     b²a²-2ba²+a²  b²a²-4ba²+4a²
 bra .doty
.dotf:
 addq.l #1,.yval(a7)

.dotr:                     ;* we have found our next coordinate pair....
 move.l .xval(a7),d0       ;d0 = xval
 move.l .yval(a7),d1       ;d1 = yval
 lsl.l d7,d0               ;scale xval
 movem.l d0-d7/a0-a1,-(a7) ;stack increases by 40 bytes

 move.l d0,d6              ;d6 = x coord
 move.l d1,d7              ;d7 = y coord

 cmpa.w #0,a3              ;if a3 = 0, switch coords
 bne.s .sw1
 exg d6,d7
.sw1:

 move.l 40+16(a7),d2       ;d2 = xmin
 move.l 40+20(a7),d3       ;d3 = ymin
 move.l 40+24(a7),d4       ;d4 = xmax
 move.l 40+28(a7),d5       ;d5 = ymax

 move.l 40+0(a7),d0        ;* lower right point
 move.l 40+4(a7),d1
 add.l d6,d0
 add.l d7,d1
 bsr .lims                 ;check limits
 tst.l 40+.ind1(a7)
 bpl.s .slx1a              ;go if window
 move.l 40+32(a7),a1
 tst.l 40+.ind0(a7)
 bpl.s .slx1b              ;  rastport: go if outline
 bra.s .slx1c              ;  rastport: go if solid
.slx1a:
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 add.w xxp_LeftEdge(a5),d0 ;  window: add top,left offsets
 add.w xxp_TopEdge(a5),d1
 tst.l 40+.ind0(a7)        ;  window: go if solid
 bmi.s .slx1c
 bsr TLWCheck              ;  window: bad if resized
 bne .bad
.slx1b:
 jsr _LVOWritePixel(a6)    ;write lh pixel (outline)
 bra.s .slx1d
.slx1c:
 jsr _LVOMove(a6)          ;move to left (solid)
.slx1d:

 move.l 40+0(a7),d0        ;* lower right pixel / row
 move.l 40+4(a7),d1
 sub.l d6,d0
 bcc.s .scy2
 moveq #0,d0
.scy2:
 add.l d7,d1
 bsr .lims
 tst.l 40+.ind1(a7)
 bpl.s .slx3a
 move.l 40+32(a7),a1
 tst.l 40+.ind0(a7)
 bpl.s .slx3b
 bra.s .slx3c
.slx3a:
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 add.w xxp_LeftEdge(a5),d0
 add.w xxp_TopEdge(a5),d1
 tst.l 40+.ind0(a7)
 bmi.s .slx3c
 bsr TLWCheck
 bne .bad
.slx3b:
 jsr _LVOWritePixel(a6)
 bra.s .slx3d
.slx3c:
 jsr _LVODraw(a6)
.slx3d:

 move.l 40+0(a7),d0        ;* upper right pixel/row
 move.l 40+4(a7),d1
 sub.l d6,d0
 bcc.s .scy3
 moveq #0,d0
.scy3:
 sub.l d7,d1
 bcc.s .scy4
 moveq #0,d1
.scy4:
 bsr .lims
 tst.l 40+.ind1(a7)
 bpl.s .slx4a
 move.l 40+32(a7),a1
 tst.l 40+.ind0(a7)
 bpl.s .slx4b
 bra.s .slx4d
.slx4a:
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 add.w xxp_LeftEdge(a5),d0
 add.w xxp_TopEdge(a5),d1
 tst.l 40+.ind0(a7)
 bmi.s .slx4b
 bsr TLWCheck
 bne .bad
 jsr _LVOWritePixel(a6)
 bra.s .slx4e
.slx4b:
 bsr TLWCheck
 bne.s .bad
.slx4d:
 jsr _LVOMove(a6)
.slx4e:

 move.l 40+0(a7),d0        ;* upper right pixel
 move.l 40+4(a7),d1
 add.l d6,d0
 sub.l d7,d1
 bcc.s .scy1
 moveq #0,d1
.scy1:
 bsr .lims
 tst.l 40+.ind1(a7)
 bpl.s .slx2a
 move.l 40+32(a7),a1
 tst.l 40+.ind0(a7)
 bpl.s .slx2b
 bra.s .slx2d
.slx2a:
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 add.w xxp_LeftEdge(a5),d0
 add.w xxp_TopEdge(a5),d1
 tst.l 40+.ind0(a7)
 bmi.s .slx2c
 bsr TLWCheck
 bne.s .bad
.slx2b:
 jsr _LVOWritePixel(a6)
 bra.s .slx2e
.slx2c:
 bsr TLWCheck
 bne.s .bad
.slx2d:
 jsr _LVODraw(a6)
.slx2e:

.skip:                     ;to next dot
 move.l .xval+40(a7),d0
 cmp.l .aint+40(a7),d0     ;all dots done? (x up to a)
 movem.l (a7)+,d0-d7/a0-a1
 bcc.s .skpc
 tst.l .yval(a7)           ;all dots done? (y down to 0)
 bgt .dotx                 ;no, find next coordinate pair

.skpc:
 subq.l #1,a3              ;dec a3
 cmpa.w #0,a3
 beq .redi                 ;continue if 2nd of 2 times thru
 bra.s .done               ;else done ok

.bad:                      ;bad if window resized
 movem.l (a7)+,d0-d7/a0-a1
 move.w #35,xxp_errn+2(a4)

.done:
 movem.l (a7)+,d0-d7/a0-a6
 add.w #20,a7
 movem.l (a7)+,d0-d1
 tst.l xxp_errn(a4)
 eori.w #-1,CCR            ;EQ, xxp_errn<> if bad
 rts

.lims:                     ;** check d0,d1 within limits
 cmp.l d2,d0
 bcc.s .lim0
 move.l d2,d0
.lim0:
 cmp.l d0,d4
 bcc.s .lim1
 move.l d4,d0
.lim1:
 cmp.l d3,d1
 bcc.s .lim2
 move.l d3,d1
.lim2:
 cmp.l d1,d5
 bcc.s .lim3
 move.l d5,d1
.lim3:
 rts


*>>>> select a region within xxp_AcWind

; D0 = minimum xpos
; D1 = minimum ypos
; D2 = maximum xpos
; D3 = maximum ypos
; A0 = 16 byte area for region (can be in xxp_buff)

; Result in  D0 and (a0):
;   D0: 0=cancelled   -1=ok
;   If ok:
;      4(a0) = top left xpos
;      8(a0) = top left ypos
;     12(a0) = bot right xpos
;     16(a0) = bot right ypos

TLGetarea:
 sub.w #20,a7              ;box data at 60(a7)
 movem.l d0-d7/a0-a6,-(a7) ;save all except result in d0  (60 stack levels)
 move.l xxp_gfxb(a4),a6    ;a6 = gfx base
 move.l xxp_AcWind(a4),a5  ;a5 = active window
 moveq #0,d0
 move.b rp_DrawMode(a0),d0
 move.l d0,76(a7)          ;save initial draw mode
 moveq #RP_JAM2!RP_COMPLEMENT,d0 ;set draw mode to complement
 move.l xxp_WPort(a5),a1
 jsr _LVOSetDrMd(a6)
.wait:                     ;* wait for mousedown/Esc
 jsr _LVOWaitTOF(a6)       ;avoid busy wait
 move.l xxp_Window(a5),a1
 jsr TLMmess               ;get message
 beq .wait                 ;go if none
 move.l d4,d5
 and.l #IDCMP_NEWSIZE,d5
 bne .canc                 ;treat as cancel if newsize
 move.l d4,d5
 and.l #IDCMP_CLOSEWINDOW,d5
 bne .canc                 ;treat as cancel if close window
 move.l d4,d5
 and.l #IDCMP_VANILLAKEY,d5
 beq.s .wtcu               ;go if not vanilla key
 cmp.b #$1B,d0
 bne .wait                 ;ignore vanilla key unless Esc
 bra .canc                 ;treat Esc as cancel
.wtcu:
 move.l d4,d5
 and.l #IDCMP_MOUSEBUTTONS,d5
 beq .wait                 ;ignore if not mousebuttons
 cmp.w #SELECTDOWN,d0
 bne .wait                 ;ignore mousebuttons other than lmb down
 cmp.w 0+2(a7),d1
 bcs .wait                 ;ignore if pointer out of allowable area
 cmp.w 8+2(a7),d1
 bhi .wait
 cmp.w 4+2(a7),d2
 bcs .wait
 cmp.w 12+2(a7),d2
 bhi .wait
 clr.l 60(a7)              ;put data in box area, & init box
 move.w d1,62(a7)
 clr.l 64(a7)
 move.w d2,66(a7)
 clr.l 68(a7)
 move.w d1,70(a7)
 clr.l 72(a7)
 move.w d2,74(a7)
 bsr .draw
.cont:                     ;* wait for mouse up/Esc
 jsr _LVOWaitTOF(a6)       ;avoid busy wait
 move.l xxp_Window(a5),a1
 bsr TLMmess               ;any idcmp?
 bne.s .some               ;yes, go
 move.l xxp_Window(a5),a1  ;get pointer posn
 move.w wd_MouseX(a1),d0
 move.w wd_MouseY(a1),d1
 cmp.w 70(a7),d0           ;redo box if pointer has moved
 bne.s .move
 cmp.w 74(a7),d1
 beq .cont
.move:                     ;* pointer has moved
 cmp.w 62(a7),d0
 bcs .cont                 ;kill box & redo if pointer left or above box
 cmp.w 66(a7),d1
 bcs .cont
 cmp.w 8+2(a7),d0          ;ignore pointer if right or below box
 bhi .cont
 cmp.w 12+2(a7),d1
 bhi .cont
 bsr .draw                 ;undraw rectangle
 move.w d0,70(a7)
 move.w d1,74(a7)
 bsr .draw                 ;draw at new posn
 bra .cont                 ;& keep waiting
.some:
 move.l d4,d5
 and.l #IDCMP_NEWSIZE,d5
 bne .drcc                 ;treat newsize as cancel
 move.l d4,d5
 and.l #IDCMP_CLOSEWINDOW,d5
 bne .drcc                 ;treat closewindow as cancel
 move.l d4,d5
 and.l #IDCMP_VANILLAKEY,d5
 beq.s .smcu               ;go if not vanilla key
 cmp.b #$1B,d0
 bne .cont                 ;ignore if not Esc
 bra .drcc                 ;treat Esc as cancel
.smcu:
 move.l d4,d5
 and.l #IDCMP_MOUSEBUTTONS,d5
 beq .cont                 ;ignore if not mousebuttons
 cmp.w #SELECTUP,d0        ;ignore if not lmb up
 bne .cont
 bsr .draw                 ;erase the box
 cmp.w 62(a7),d1
 bcs .wait                 ;reject & retry if pointer above/left of topleft
 cmp.w 66(a7),d2
 bcs .wait
 move.l 32(a7),a0          ;get where to put result
 move.l 60(a7),(a0)        ;fill in result
 move.l 64(a7),4(a0)
 move.l 68(a7),8(a0)
 move.l 72(a7),12(a0)
 move.l #-1,(a7)           ;* good - signal d0=-1 in stack
 bra.s .done
.drcc:                     ;* undraw then cancel
 bsr .draw
.canc:                     ;* cancelled - signal d0=0 in stack
 clr.l (a7)
.done:
 move.l xxp_WPort(a5),a1   ;restore initial drawmode
 move.l 76(a7),d0
 jsr _LVOSetDrMd(a6)
 movem.l (a7)+,d0-d7/a0-a6
 add.w #20,a7
 rts
.draw:                     ;** complement box
 movem.l d0-d7/a0-a2,-(a7) ;save all (44 stack bytes)
 move.l xxp_WPort(a5),a2   ;a2 = rastport
 move.l 60+4+44+0(a7),d4   ;box from (d4,d5)-(d6,d7)
 move.l 60+4+44+4(a7),d5
 move.l 60+4+44+8(a7),d6
 move.l 60+4+44+12(a7),d7
 move.l a2,a1              ;top left
 move.l d4,d0
 move.l d5,d1
 jsr _LVOMove(a6)
 move.l a2,a1              ;top left to top right
 move.l d6,d0
 move.l d5,d1
 jsr _LVODraw(a6)
 cmp.l d5,d7               ;quit if height = 1
 beq.s .drqt
 move.l a2,a1              ;bot left
 move.l d4,d0
 move.l d7,d1
 jsr _LVOMove(a6)
 move.l a2,a1              ;bot left to bot right
 move.l d6,d0
 move.l d7,d1
 jsr _LVODraw(a6)
 addq.l #1,d5              ;down a line for side tops
 cmp.l d5,d7
 beq.s .drqt               ;quit if height = 2
 subq.l #1,d7              ;up a line for side bots
 move.l a2,a1              ;top left
 move.l d4,d0
 move.l d5,d1
 jsr _LVOMove(a6)
 move.l a2,a1              ;top left to bot left
 move.l d4,d0
 move.l d7,d1
 jsr _LVODraw(a6)
 cmp.l d4,d6               ;quit if width = 1
 beq.s .drqt
 move.l a2,a1              ;top right
 move.l d6,d0
 move.l d5,d1
 jsr _LVOMove(a6)
 move.l a2,a1              ;top right to bot right
 move.l d6,d0
 move.l d7,d1
 jsr _LVODraw(a6)
 addq.l #1,d4              ;right a line for left side 2nd pixel
 cmp.l d4,d6               ;quit if width = 2
 beq.s .drqt
 move.l a2,a1              ;top left
 move.l d4,d0
 move.l d5,d1
 jsr _LVOMove(a6)
 move.l a2,a1              ;top left to bot right
 move.l d4,d0
 move.l d7,d1
 jsr _LVODraw(a6)
 subq.l #1,d6              ;left a line for right side 2nd pixel
 cmp.l d4,d6               ;quit if width = 3
 beq.s .drqt
 move.l a2,a1              ;top right
 move.l d6,d0
 move.l d5,d1
 jsr _LVOMove(a6)
 move.l a2,a1              ;top right to bot right
 move.l d6,d0
 move.l d7,d1
 jsr _LVODraw(a6)
.drqt:
 movem.l (a7)+,d0-d7/a0-a2
 rts


*>>>> Put up a progress thermometer

; On call:  D0 = progress
;           D1 = total                    (must be <>0)
;           D2 = 0:no text -1:text +1:%   (font,sty,tspc must be set)

TLProgress:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l d0,d7              ;d7 = progress
 move.l d1,d6              ;d6 = total

 move.l xxp_pref(a4),a1    ;prefs colours: yprg/yprg+2/yprg+3=back/frnt/Hg

 move.l xxp_prgd(a4),d0    ;draw thermometer bev
 move.l xxp_prgd+4(a4),d1
 move.l xxp_prgd+8(a4),d2
 move.l xxp_prgd+12(a4),d3
 bset #31,d0               ;(recessed)
 bsr TLReqbev

 bclr #31,d0               ;set d0-d3 to dims of inside area
 bset #29,d0
 addq.w #2,d0
 addq.w #1,d1
 subq.w #2,d3
 subq.w #4,d2

 move.l d7,d5              ;d4 = totl, d5 = prog
 move.l d6,d4              ;scale d4,d5 to word length if required
.scal:
 swap d4
 tst.w d4
 beq.s .scld
 swap d4
 lsr.l #1,d4
 lsr.l #1,d5
 bra .scal
.scld:
 swap d4

 mulu d5,d2                ;calculate Hg length in pixels
 divu d4,d2
 moveq #0,d4
 and.l #$0000FFFF,d2
 beq.s .bkgr

 move.b xxp_yprg+3(a1),d4  ;draw Hg
 bsr TLReqarea

.bkgr:                     ;draw background
 add.w d2,d0
 neg.w d2
 add.w xxp_prgd+8+2(a4),d2
 subq.w #4,d2
 ble.s .text
 move.b xxp_yprg(a1),d4
 bsr TLReqarea

.text:                     ;draw text
 tst.l 8(a7)               ;test input d2  (MI if text)
 beq .done                 ;go if none
 bpl.s .pcnt               ;go if %

 move.l d7,d0              ;put ascii of prog/totl in buff
 move.l a4,a0
 bsr TLHexasc
 move.b #'/',(a0)+
 move.l d6,d0
 bsr TLHexasc
 clr.b (a0)
 bra.s .prnt

.pcnt:                     ;put ascii of % in buff
 moveq #100,d0
 cmp.l d6,d7
 beq.s .pcnr               ;go if 100%

.pcns:
 swap d6                   ;scale to word size
 tst.w d6
 beq.s .pctr
 swap d6
 lsr.l #1,d6
 lsr.l #1,d7
 bra .pcns
.pctr:
 swap d6

 mulu d7,d0                ;calculate %
 divu d6,d0

.pcnr:
 move.l a4,a0              ;put ascii  in buff
 bsr TLHexasc
 move.b #'%',(a0)+
 clr.b (a0)

.prnt:
 move.l xxp_AcWind(a4),a5  ;set pen, jam1
 move.l xxp_IText(a5),-(a7)
 move.l xxp_FrontPen(a5),-(a7)
 move.l a4,xxp_IText(a5)
 move.b xxp_yprg+2(a1),xxp_FrontPen(a5)
 move.b #RP_JAM1,xxp_DrawMode(a5)

 bsr TLTszdo               ;get d4=width d6=height
 move.l xxp_prgd+12(a4),d1 ;centre vertically
 sub.w d6,d1
 bcs.s .txbd               ;go if won't fit
 addq.l #1,d1
 lsr.l #1,d1
 add.l xxp_prgd+4(a4),d1
 move.l xxp_prgd+8(a4),d0  ;centre horizontally
 sub.w d4,d0
 bcs.s .txbd               ;go if won't fit
 addq.l #1,d0
 lsr.l #1,d0
 add.l xxp_prgd(a4),d0
 bsr TLTrim                ;print text

.txbd:
 move.l (a7)+,xxp_FrontPen(a5)
 move.l (a7)+,xxp_IText(a5)

.done:
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> set/get the scroller(s) of the active window (D0=0 set, D0=-1 get)
;       d1=-1vert 0both +1horz
TLWscroll:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 move.l d1,d7              ;d7 = vert/both/horz
 move.l xxp_AcWind(a4),a5  ;a5 = active window's wsuw
 move.l xxp_scrl(a5),a3    ;a3 = xxp_scro structure
 move.l xxp_intb(a4),a6

 tst.l d0                  ;go if d0=-1 -> get
 bmi .get

 sub.w #28,a7              ;tags to set horizontal attributes
 tst.l d7
 bmi.s .sver               ;go if vert only

 move.l a7,a0
 move.l #PGA_Top,(a0)+     ;tag 1: PGA_Top     = GA_Top
 move.l xxp_hztp(a3),(a0)+
 move.l #PGA_Total,(a0)+   ;tag 2: PGA_Total   = GA_Total
 move.l xxp_hztt(a3),(a0)+
 move.l #PGA_Visible,(a0)+ ;tag 3: PGA_Visible = GA_Visible
 move.l xxp_hzvs(a3),(a0)+
 clr.l (a0)

 move.l xxp_scoh(a3),a0    ;set horizontal attribs
 move.l a7,a1
 jsr _LVOSetAttrsA(a6)

 move.l xxp_scoh(a3),a0    ;refresh horizontal slider
 move.l xxp_Window(a5),a1
 sub.l a2,a2
 moveq #1,d0
 jsr _LVORefreshGList(a6)
 tst.l d7                  ;go if vertical only
 bgt.s .sdon

.sver:
 move.l a7,a0              ;tags to set vertical attributes
 move.l #PGA_Top,(a0)+     ;tag 1: PGA_Top     = GA_Top
 move.l xxp_vttp(a3),(a0)+
 move.l #PGA_Total,(a0)+   ;tag 2: PGA_Total   = GA_Total
 move.l xxp_vttt(a3),(a0)+
 move.l #PGA_Visible,(a0)+ ;tag 3: PGA_Visible = GA_Visible
 move.l xxp_vtvs(a3),(a0)+
 clr.l (a0)

 move.l xxp_scov(a3),a0    ;set vertical attribs
 move.l a7,a1
 jsr _LVOSetAttrsA(a6)

 move.l xxp_scov(a3),a0    ;refresh vertical slider
 move.l xxp_Window(a5),a1
 sub.l a2,a2
 moveq #1,d0
 jsr _LVORefreshGList(a6)

.sdon:                     ;finished setting
 add.w #28,a7
 movem.l (a7)+,d0-d7/a0-a6
 rts

.get:                      ;* here if get
 move.l (a4),-(a7)
 tst.l d7
 bmi.s .gver               ;go if vert only
 move.l xxp_scoh(a3),a0
 move.l a4,a1
 move.l #PGA_Top,d0
 jsr _LVOGetAttr(a6)
 move.l (a4),xxp_hztp(a3)  ;get hztp
 tst.l d7
 bgt.s .gdon               ;go if horz only

.gver:
 move.l xxp_scov(a3),a0
 move.l a4,a1
 move.l #PGA_Top,d0
 jsr _LVOGetAttr(a6)
 move.l (a4),xxp_vttp(a3)  ;get vttp
 move.l (a7)+,(a4)

.gdon:
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> setup/draw/kill a tabs area
; Setup:  D0 = strnum  D1 = min body width  D2 = body height
; Draw:   D0 = 0    D1 = which to show (1+)   D2 = xpos  D3 = ypos
; Kill:   D0 = 0    D1 = 0                    D2 = xpos  D3 = ypos
TLTabs:
 movem.l d0-d7/a0-a6,-(a7)
 move.l xxp_AcWind(a4),a5
 move.l xxp_IText(a5),-(a7)
 move.l xxp_FrontPen(a5),-(a7)
 move.w #$0103,xxp_FrontPen(a5)
 move.l a4,xxp_IText(a5)
 clr.l xxp_errn(a4)

 tst.l d0                  ;go if draw/kill
 beq .draw

 bsr TLStra0               ;* setup
 move.l a0,xxp_tbss(a4)    ;set string address
 moveq #0,d0               ;d0 counts strings
 moveq #0,d3               ;d3 finds max string len
.next:
 move.l a4,a1              ;put next string in buff
 addq.w #1,d0              ;bump string count
.tfr:
 move.b (a0)+,(a1)+        ;tfr to buff for getting len
 beq.s .tfrd
 cmp.b #'\',-1(a1)         ;\ or 0 delimits
 bne .tfr
.tfrd:
 clr.b -1(a1)              ;null delimit in buff
 bsr TLTsize
 cmp.w d3,d4               ;this len > max len so far?
 bcs.s .max
 move.w d4,d3              ;yes, put max so far in d3
.max
 tst.b -1(a0)              ;do next unless end of string reached
 bne .next
 addq.w #8,d3              ;minimum thumbtab width = max string width + 8
 addq.w #4,d6
 move.l d6,xxp_tblh(a4)    ;thumbtab height = font height + 4
.cry:                      ;get min tab wdth allowed by min body wdth
 move.l d1,d4              ; = ((bod wdth+8)-8)/numtabs rounded up
 add.l d0,d4
 subq.l #1,d4
 divu d0,d4
 and.l #$0000FFFF,d4       ;d4 = min tab width allowed by min body wdth
 cmp.w d4,d3
 bcc.s .maxw
 move.l d4,d3              ;take whichever is bigger
.maxw:
 move.l d3,xxp_tblw(a4)    ;set tab width
 mulu d0,d3
 addq.w #8,d3              ;total width = tabnum * tabwidth + 8
 move.l d3,xxp_tbbw(a4)    ;set total width
 add.l d6,d2
 addq.w #3,d2              ;total height = body ht + tab ht + 3
 move.l d2,xxp_tbbh(a4)    ;set total height
 bra .done                 ;all set up ok

.draw:                     ;go if kill

 move.l d1,d7              ;d7 = front tab num + 1
 beq .kill

 move.l d2,d0              ;* draw
 move.l d3,d1
 move.l xxp_tbbw(a4),d2
 move.l xxp_tbbh(a4),d3
 bsr TLReqarea             ;draw background, outline
 bsr TLReqbev

 move.l d1,d2              ;d1,d2 = top left
 move.l d0,d1
 moveq #0,d0
 bsr TLPict                ;draw top left corner

 move.l xxp_tbss(a4),a0    ;a0 scans thumbtab labels
.nexx:                     ;* complete next thumbtag...
 move.l a4,a1
.ntfr:
 move.b (a0)+,(a1)+        ;tfr label to buff
 beq.s .ntfd
 cmp.b #'\',-1(a1)
 bne .ntfr
.ntfd:
 clr.b -1(a1)              ;null delimit label
 move.l d1,d4              ;(save d1)
 move.l d1,d0
 move.l d2,d1
 addq.l #8,d0
 addq.l #2,d1
 bsr TLTrim                ;draw text at d1+8,d2+2
 move.l d4,d1              ;(restore d1)
 add.l xxp_tblw(a4),d1     ;bump to next tab lhs

 subq.w #1,d7
 bgt.s .tabp               ;go draw desc & horz to right of front tab
 bmi.s .tabm               ;go draw desc & horz to left of front tab
.tabe:
 moveq #1,d0
.tabd:
 tst.b -1(a0)              ;go if we are the rhs of the last tab
 beq .wrap
 bsr TLPict                ;else, draw under/over or over/under
 bra .nexx                 ;to next thumb tag

.tabp:                     ;here if left of front tab
 movem.l d1-d2,-(a7)       ;draw its descender
 move.l d1,d0
 move.l d2,d1
 addq.l #8,d1
 moveq #2,d2
 move.l xxp_tblh(a4),d3
 subq.l #8,d3
 moveq #2,d4
 bset #29,d0
 bsr TLReqarea
 movem.l (a7)+,d1-d2

 movem.l d1-d2,-(a7)       ;draw horizontal
 move.l d1,d0
 move.l d2,d1
 move.l xxp_tblw(a4),d2
 sub.l d2,d0
 add.l xxp_tblh(a4),d1
 subq.w #1,d1
 moveq #1,d3
 moveq #2,d4
 bset #29,d0
 bsr TLReqarea
 movem.l (a7)+,d1-d2

 moveq #2,d0               ;go draw under/over
 bra .tabd

.tabm:                     ;here if right of front tab
 movem.l d1-d2,-(a7)       ;draw its descender
 move.l d1,d0
 move.l d2,d1
 sub.l xxp_tblw(a4),d0
 addq.l #6,d0
 addq.l #8,d1
 moveq #2,d2
 move.l xxp_tblh(a4),d3
 subq.l #8,d3
 moveq #1,d4
 bset #29,d0
 addq.w #1,d7
 beq.s .tbmd
 subq.w #1,d3
.tbmd:
 subq.w #1,d7
 bsr TLReqarea
 movem.l (a7)+,d1-d2

 movem.l d1-d2,-(a7)       ;draw horizontal
 move.l d1,d0
 move.l d2,d1
 move.l xxp_tblw(a4),d2
 sub.l d2,d0
 addq.l #7,d0
 add.l xxp_tblh(a4),d1
 subq.l #1,d1
 moveq #1,d3
 moveq #2,d4
 bset #29,d0
 bsr TLReqarea
 movem.l (a7)+,d1-d2

 bra .tabe                 ;go draw over/under

.wrap:                     ;here if last tab
 moveq #3,d0               ;draw rhs of last tab
 bsr TLPict
 bra .done

.kill:                    ;* kill
 move.l d2,d0
 move.l d3,d1
 move.l xxp_tbbw(a4),d2
 move.l xxp_tbbh(a4),d3
 move.l (a7)+,xxp_FrontPen(a5)
 move.l xxp_FrontPen(a5),-(a7)
 bsr TLReqarea

.done:
 move.l (a7)+,xxp_FrontPen(a5)
 move.l (a7)+,xxp_IText(a5)
 movem.l (a7)+,d0-d7/a0-a6
 rts

*>>>> monitor the tabs. call w. D0-D1 as per TLkeyboard) D2=xpos, D3=ypos
; call with   D0,D1 = TLkeyboard D1,D2
;             D2,D3 = xpos,ypos of tabs (tabs must already be set up)
; returns with D0=1+ for thumbtab clicked, else D0=0
TLTabmon:
 movem.l d0-d1/a5,-(a7)    ;save all exc result in d0
 clr.l (a7)                ;stack d0 = 0 pro-tem

 move.l xxp_AcWind(a4),a5  ;a5 = AcWind

 sub.w xxp_LeftEdge(a5),d0 ;make d0,d1 rel to window printable part
 bcs.s .done
 sub.w xxp_TopEdge(a5),d1
 bcs.s .done

 sub.w d2,d0               ;make d0,d1 rel to tabs area
 bcs.s .done
 sub.w d3,d1
 bcs.s .done

 cmp.w xxp_tblh+2(a4),d1   ;go if d1 not within thumbtabs
 bgt.s .done
 cmp.w xxp_tbbw+2(a4),d0   ;go if d0 not within thumbtabs
 bcc.s .done

 divu xxp_tblw+2(a4),d0    ;get whichever to d0 in stack
 and.l #$0000FFFF,d0
 addq.l #1,d0              ;make 1+
 move.l d0,(a7)

 move.l d0,d1              ;re-draw with clicked thumbtab in front
 moveq #0,d0
 bsr TLTabs

.done:
 movem.l (a7)+,d0-d1/a5
 rts

*>>>> draw 1 of the .pix pictures
; D0 = num (0-11)
; D1 = xpos
; D2 = ypos
TLPict:
 movem.l d0-d7/a0-a6,-(a7) ;save all

 move.l xxp_gfxb(a4),a6    ;a6 = gfxb
 move.l xxp_AcWind(a4),a5  ;a5 = AcWind

 moveq #8,d4               ;picture size = 8X8
 moveq #8,d5

 move.w xxp_PWidth(a5),d3  ;check horz fit (quit without error if won't fit)
 sub.w d1,d3               ;d3 = max width that currently fits
 ble.s .done               ;quit if d3 <= 0
 cmp.w d4,d3               ;ok if d3 >= d4
 bcc.s .vert
 move.w d3,d4              ;else d3 to d4

.vert:
 move.w xxp_PHeight(a5),d3 ;check vert fit (quit without error if won't fit)
 sub.w d2,d3               ;d3 = max height that currently fits
 ble.s .done               ;quit if d3 <= 0
 cmp.w d5,d3               ;ok if d3 >= d5
 bcc.s .redi
 move.w d3,d5              ;else d3, to d5

.redi:
 move.l xxp_pixx(a4),a0    ;a0 = rport from
 move.l xxp_WPort(a5),a1   ;a1 = rport to
 move.l d2,d3
 move.l d1,d2              ;d2,d3 = to coords
 add.w xxp_LeftEdge(a5),d2
 add.w xxp_TopEdge(a5),d3  ;make d2,d3 rel to window edge
 mulu #8,d0                ;from xpos = 8*num
 moveq #0,d1               ;from ypos = 0
 move.w #$00C0,d6          ;JAM2
 bsr TLWCheck
 bne.s .bad                ;don't blit if window resized
 jsr _LVOClipBlit(a6)      ;do the blit
 clr.l xxp_errn(a4)        ;error = 0 if blitted
 bra.s .done

.bad:
 move.w #35,xxp_errn+2(a4) ;bad if window resized (error 35)

.done:
 movem.l (a7)+,d0-d7/a0-a6
 rts


*>>>> dropdown menu
TLDropdown:

;pointers to the 64 byte workspace + pushed regs
.strs: equ 0               ;.L address of strings
.chrs: equ 4               ;.L max string len
.xpos: equ 8               ;.L menu xpos
.ypos: equ 12              ;.L menu ypos
.wdth: equ 16              ;.L menu width
.hght: equ 20              ;.L menu height (if dropped)
.what: equ 24              ;.L operative choice (1+)
.back: equ 28              ;.L output choice (0, or 1+ if user actvted menu)
.fsty: equ 32              ;.L calling window fsty,tspc cache
.fnum: equ 36              ;.W calling window fnum cahce
.slid: equ 38              ;
.pens: equ 40              ;.L calling window pens cache
.itxt: equ 44              ;.L calling window IText
.drop: equ 48              ;.L lines in drop
.slix: equ 52              ;.L }
.sliy: equ 56              ;.L } cache slider data
.sliw: equ 60              ;.L }
.slih: equ 64              ;.L }
.tops: equ 68              ;.L }
.totl: equ 72              ;.L }
.visi: equ 76              ;.L }
.hook: equ 80              ;.L }
.prev: equ 84              ;.L previous xxp_tops for .body

.d0: equ 84                ;input d0-d7
.d1: equ .d0+4
.d2: equ .d0+8
.d3: equ .d0+12
.d4: equ .d0+16
.d5: equ .d0+20
.d6: equ .d0+24
.d7: equ .d0+28

 movem.l d0-d7/a0-a6,-(a7) ;save all except result in D0 (level 64+)
 clr.l xxp_errn(a4)
 sub.w #.d0,a7             ;create a workspace

 move.l .d1(a7),d0         ;point .strs to 1st string
 bsr TLStra0
 move.l a0,.strs(a7)

 move.l xxp_AcWind(a4),a5  ;cache calling window data
 move.l xxp_Fsty(a5),.fsty(a7)
 move.w xxp_Fnum(a5),.fnum(a7)
 move.l xxp_FrontPen(a5),.pens(a7)
 move.l xxp_IText(a5),.itxt(a7)

 clr.w xxp_Tspc(a5)        ;set properties of window
 move.l a4,xxp_IText(a4)
 move.w #$0100,xxp_FrontPen(a5)
 move.b #RP_JAM1,xxp_DrawMode(a5)
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont

 move.l .d4(a7),.xpos(a7)  ;set .xpos,.ypos,.what
 move.l .d5(a7),.ypos(a7)
 move.l .d3(a7),.what(a7)
 clr.l .back(a7)           ;so far, no response from user

 move.l .d6(a7),d0         ;set .chrs...
 bne.s .f6ok               ;go if input d6<>0
 moveq #0,d0               ;else, find max string length
 move.l .d2(a7),d1
 subq.w #1,d1              ;d0 holds max, d1 counts strings
 move.l .strs(a7),a0       ;a0 scans strings
.fxd6:
 moveq #-1,d2              ;d2 counts chrs in string
.f6sc:
 addq.l #1,d2              ;set d2 to len of this string
 tst.b (a0)+
 bne .f6sc
 cmp.w d2,d0
 bcc.s .f6cy
 move.w d2,d0              ;put in d0 if d2>d0
.f6cy:
 dbra d1,.fxd6
.f6ok:
 move.l d0,.chrs(a7)       ;set .chrs with len of longest string / input d6

 lsl.w #3,d0               ;set .wdth
 add.w #16,d0
 move.l d0,.wdth(a7)

 tst.l .d0(a7)             ;go if only drawing
 beq .draw

 move.l xxp_kybd+4(a4),d1  ;d1,d2 = lmb xpos,ypos rel to window topleft
 move.l xxp_kybd+8(a4),d2
 sub.w xxp_LeftEdge(a5),d1
 sub.w .xpos+2(a7),d1
 sub.w .wdth+2(a7),d1
 add.w #12,d1
 bmi .no                   ;go if click was not within the V box
 cmp.w #12,d1
 bcc .no
 sub.w xxp_TopEdge(a5),d2
 sub.w .ypos+2(a7),d2
 bmi .no
 cmp.w #10,d2
 bcc .no

.yes:                      ;here if V box clicked
 tst.l .d7(a7)
 bpl.s .ydrp               ;go unless cycle only

 move.l .d3(a7),d0         ;cycle only: get input
 cmp.l .d2(a7),d0          ;was it = no of strings?
 bcs.s .only               ;no, ok
 moveq #0,d0               ;yes, back to 0
.only:
 addq.l #1,d0              ;bump it
 move.l d0,.back(a7)       ;put in back, what
 move.l d0,.what(a7)
 bra .draw                 ;& go draw

.ydrp:
 move.l .d2(a7),d3
 cmp.l .d7(a7),d3          ;set drop to least of input d2,d7
 ble.s .maxd
 move.l .d7(a7),d3
.maxd:
 move.l d3,.drop(a7)

 moveq #0,d0               ;move xpos,ypos if won't fit
 move.w xxp_PWidth(a5),d0
 sub.l .wdth(a7),d0        ;d0 = max posn for xpos that will fit
 bcc.s .xpcu
 moveq #0,d0
.xpcu:
 cmp.l .xpos(a7),d0
 bge.s .xpok
 move.l d0,.xpos(a7)       ;put xpos at d0 if xpos > d0
.xpok:
 move.w xxp_PHeight(a5),d0
 move.l .drop(a7),d1
 lsl.w #3,d1
 add.w #12,d1
 sub.l d1,d0               ;d0 = max posn for ypos that will fit
 bcc.s .ypcu
 moveq #0,d0
.ypcu:
 cmp.l .ypos(a7),d0
 bge.s .ypok
 move.l d0,.ypos(a7)       ;put ypos at d0 if ypos > d0
.ypok:

 move.l .xpos(a7),d0       ;backup area under drop to ERport
 move.l .ypos(a7),d1
 add.w #10,d1
 moveq #0,d2
 moveq #0,d3
 move.l .wdth(a7),d4       ;d4 = width
 moveq #0,d7
 move.w xxp_PWidth(a5),d7
 sub.w d0,d7               ;d7 = amt of window right of lhs
 ble.s .drdp               ;don't backup if none
 cmp.w d4,d7
 bcc.s .bku0
 move.w d7,d4              ;if that is < width, make that the width
.bku0:
 move.l .drop(a7),d5       ;d5 = height
 lsl.w #3,d5
 addq.w #2,d5
 move.w xxp_PHeight(a5),d7 ;d7 = amt of window bwlow top
 sub.w d1,d7
 ble.s .drdp               ;don't backup if none
 cmp.w d5,d7
 bcc.s .bku1
 move.w d7,d5              ;if that < height, make that the height
.bku1:
 add.w xxp_LeftEdge(a5),d0 ;make xpos,ypos rel to window edges
 add.w xxp_TopEdge(a5),d1
 move.w #$C0,d6            ;vanilla copy
 move.l xxp_gfxb(a4),a6
 move.l xxp_WPort(a5),a0   ;from window rastport
 move.l xxp_ERport(a4),a1  ;to ERport
 bsr TLWCheck
 bne .no                   ;quit if window resized
 jsr _LVOClipBlit(a6)      ;do the backup

.drdp:
 move.l .xpos(a7),d0       ;draw drop outline
 move.l .ypos(a7),d1
 add.w #10,d1
 move.l .wdth(a7),d2
 move.l .drop(a7),d3
 lsl.w #3,d3
 addq.w #2,d3
 moveq #3,d4
 bsr TLReqbev

 move.l xxp_slix(a4),.slix(a7) ;cache input slider data
 move.l xxp_sliy(a4),.sliy(a7)
 move.l xxp_sliw(a4),.sliw(a7)
 move.l xxp_slih(a4),.slih(a7)
 move.l xxp_tops(a4),.tops(a7)
 move.l xxp_totl(a4),.totl(a7)
 move.l xxp_strs(a4),.visi(a7)
 move.l xxp_hook(a4),.hook(a7)

 move.l .xpos(a7),d0       ;draw slider
 add.l .wdth(a7),d0
 sub.w #12,d0
 move.l d0,xxp_slix(a4)
 move.l .ypos(a7),d0
 add.w #10,d0
 move.l d0,xxp_sliy(a4)
 move.l #12,xxp_sliw(a4)
 move.l .drop(a7),d3
 lsl.w #3,d3
 addq.w #2,d3
 move.l d3,xxp_slih(a4)
 clr.l xxp_tops(a4)
 move.l .d2(a7),xxp_totl(a4)
 move.l .drop(a7),xxp_strs(a4)
 move.l #.body,xxp_hook(a4)
 move.l #-1,.prev(a7)
 move.l a7,a0              ;a0 = a7 data for .hook
 bsr TLSlider

.wait:                     ;menu dropped: wait for user response
 bsr TLWCheck
 bne .off                  ;quit if window resized
 bsr TLKeyboard
 cmp.b #$1B,d0             ;quit if Esc
 beq.s .off
 cmp.b #$93,d0             ;quit if window close
 beq.s .off
 cmp.b #$80,d0             ;else reject unless click
 bne .wait

 move.l d1,d4              ;see if within body width / V width
 sub.w xxp_LeftEdge(a5),d4
 sub.w .xpos+2(a7),d4
 subq.w #2,d4
 bmi.s .moni
 move.l .chrs(a7),d5
 lsl.w #3,d5
 addq.w #2,d5
 sub.w d5,d4
 bcs.s .trbd               ;go if within body width

 cmp.w #12,d4              ;within width of V button?
 bcc.s .moni               ;no, go
 moveq #0,d4
 move.w d2,d4
 sub.w xxp_TopEdge(a5),d4
 sub.w .ypos+2(a7),d4
 bmi.s .moni               ;go if above height of V button
 cmp.w #10,d4
 bcs.s .off                ;quit if within V button
 bcc.s .moni               ;else, try if in slider

.trbd:                     ;with body horz - see if vert
 moveq #0,d4
 move.w d2,d4
 sub.w xxp_TopEdge(a5),d4
 sub.w .ypos+2(a7),d4
 sub.w #11,d4
 bmi.s .moni               ;no, go
 lsr.w #3,d4               ;d4 = linum rel to body
 add.l xxp_tops(a4),d4     ;d4 = linum rel to input d2
 cmp.l .d2(a7),d4          ;go if off bottom of body
 bcc.s .moni

 addq.l #1,d4             ;item chosen - put in .back,.what
 move.l d4,.what(a7)
 move.l d4,.back(a7)
 bra.s .off               ;& switch off

.moni:                    ;monitor slider
 move.l a7,a0
 bsr TLSlimon
 bra .wait

.off:                      ;turn drop menu off
 move.l .xpos(a7),d2       ;restore area under drop from ERport
 move.l .ypos(a7),d3
 add.w #10,d3
 moveq #0,d0
 moveq #0,d1
 move.l .wdth(a7),d4       ;d4 = width
 moveq #0,d7
 move.w xxp_PWidth(a5),d7
 sub.w d2,d7               ;d7 = amt of window right of lhs
 ble.s .no                 ;don't restore if none
 cmp.w d4,d7
 bcc.s .rst0
 move.w d7,d4              ;if that is < width, make that the width
.rst0:
 move.l .drop(a7),d5       ;d5 = height
 lsl.w #3,d5
 addq.w #2,d5
 move.w xxp_PHeight(a5),d7 ;d7 = amt of window below top
 sub.w d3,d7
 ble.s .no                 ;don't restore if none
 cmp.w d5,d7
 bcc.s .rst1
 move.w d7,d5              ;if that < height, make that the height
.rst1:
 add.w xxp_LeftEdge(a5),d2 ;make xpos,ypos rel to window edges
 add.w xxp_TopEdge(a5),d3
 move.w #$C0,d6            ;vanilla copy
 move.l xxp_gfxb(a4),a6
 move.l xxp_WPort(a5),a1   ;to window rastport
 move.l xxp_ERport(a4),a0  ;from ERport
 bsr TLWCheck              ;don't blit if resized
 bne.s .no
 jsr _LVOClipBlit(a6)      ;do the restore

.no:
 move.l .d4(a7),.xpos(a7)  ;revert to input xpos,ypos to draw
 move.l .d5(a7),.ypos(a7)

.draw:                     ;draw the undropped menu
 move.l .xpos(a7),d0       ;text background
 move.l .ypos(a7),d1
 move.l .wdth(a7),d2
 move.l #10,d3
 sub.l #12,d2
 moveq #0,d4
 bset #29,d0
 bsr TLReqarea

 bclr #29,d0               ;text bev
 bsr TLReqbev

 addq.w #2,d0              ;text of .what
 addq.w #1,d1
 move.l .strs(a7),a0       ;find text
 move.l .what(a7),d4
 subq.w #1,d4
 bra.s .dwfw
.dwnx:
 tst.b (a0)+
 bne .dwnx
.dwfw:
 dbra d4,.dwnx
 move.l a4,a1
.dwtf:
 move.b (a0)+,(a1)+        ;tfr text to buff
 bne .dwtf
 move.l .chrs(a7),d4       ;len <= .chrs
 clr.b 0(a4,d4.w)
 bsr TLTrim                ;print it
 subq.w #2,d0
 subq.w #1,d1

 add.l d2,d0               ;bev around V
 moveq #12,d2
 bsr TLReqbev

 move.l d1,d2              ;draw V
 move.l d0,d1
 addq.w #2,d1
 addq.w #1,d2
 moveq #9,d0
 tst.l .d7(a7)
 bpl.s .pict
 moveq #12,d0              ;(if cycle, draw pict 12)
.pict:
 bsr TLPict

.done:
 tst.w .slid(a7)           ;restore slider data if cached
 beq.s .nsld
 move.l .slix(a7),xxp_slix(a4)
 move.l .sliy(a7),xxp_sliy(a4)
 move.l .sliw(a7),xxp_sliw(a4)
 move.l .slih(a7),xxp_slih(a4)
 move.l .tops(a7),xxp_tops(a4)
 move.l .totl(a7),xxp_totl(a4)
 move.l .visi(a7),xxp_strs(a4)
 move.l .hook(a7),xxp_hook(a4)
.nsld:

 move.l xxp_AcWind(a4),a5  ;restore calling window properties
 move.w .fsty+2(a7),xxp_Tspc(a5)
 move.l .pens(a7),xxp_FrontPen(a5)
 move.l .itxt(a7),xxp_IText(a5)
 moveq #0,d0
 move.w .fnum(a7),d0
 moveq #0,d1
 move.w .fsty(a7),d1
 moveq #0,d2
 bsr TLNewfont

 move.l .back(a7),.d0(a7)  ;put result in stack D0 (0 unless selection made)

 add.w #.d0,a7             ;discard workspace & return
 movem.l (a7)+,d0-d7/a0-a6
 rts

; TLDropmenu subroutine

.body:                     ;** draw body of drop
 move.l xxp_Stak(a4),a0
 move.l 32(a0),a6          ;retrieve caller A0 = pointer to A7 data

 move.l xxp_tops(a4),d0    ;quit if tops = prev
 cmp.l .prev(a6),d0
 beq .bqut
 move.l d0,.prev(a6)       ;else, set prev to new tops

 move.l .xpos(a6),d0       ;draw drop background
 addq.w #2,d0
 move.l .ypos(a6),d1
 add.w #11,d1
 move.l .wdth(a6),d2
 sub.w #14,d2
 move.l .drop(a6),d3
 lsl.w #3,d3
 moveq #3,d4
 bset #29,d0
 bsr TLReqarea

 move.l .what(a6),d3      ;highlight background of .what
 subq.l #1,d3
 sub.l xxp_tops(a4),d3
 bmi.s .nbck              ;go if .what not visible right now (above top)
 cmp.l .drop(a6),d3
 bcc.s .nbck              ;go if .what not visible right now (below bot)
 lsl.w #3,d3
 add.l d3,d1
 moveq #8,d3
 moveq #0,d4
 bsr TLReqarea
.nbck:
 bclr #29,d0

 move.l .strs(a6),a0      ;a0 = address of 1st string
 move.l xxp_tops(a4),d2   ;d2 = 1st visible
 bra.s .hkfw
.hknx:
 tst.b (a0)+              ;bypass all before 1st visible
 bne .hknx
.hkfw:
 dbra d2,.hknx

 move.l .drop(a6),d2      ;d2 counts strings printed
 subq.w #1,d2
 move.l .xpos(a6),d0      ;d0 = xpos
 addq.w #2,d0
 move.l .ypos(a6),d1      ;d1 = ypos
 add.w #11,d1

.prnt:                    ;print next string
 move.l a4,a1
.prtf:
 move.b (a0)+,(a1)+       ;tfr to buff
 bne .prtf
 move.l .chrs(a6),d3      ;truncate if required
 clr.b 0(a4,d3.w)
 bsr TLTrim               ;print it
 addq.w #8,d1             ;bump ypos
 dbra d2,.prnt            ;until all printed

.bqut:
 rts


*>>>> maintain a set of ASCII lines
TLMultiline:

; Call:    D0 has bit 1 set if mem unsaved; bit 31 set if view only
;                                               and TLMultiline forbids
;          D1 has TLReqedit forbids

; Retn:    xxp_errn = 0 if ok (possible errors 1,2,30,31,32,34)
;          xxp_Mmem,Mtop,Mcrr,Mmxc,Mtpl set
;          xxp_chnd  bit0=1 if changed,  bit1=1 if unsaved
;          xxp_lins  set
;          xxp_kybd  set  $1B=Esc  $93=Close  $97=Inactive

; save regs &c

 movem.l d0-d7/a0-a6,-(a7) ;save all except result in d0

 move.l d0,d6              ;remember input d0,d1
 move.l d1,d5

 move.l xxp_AcWind(a4),a5  ;* A5 = active window throughout TLMultiline

 move.l xxp_strg(a4),-(a7) ;save global strings
 move.l (a7),d7
 move.l xxp_Help(a4),-(a7) ;save global help
 move.l xxp_FrontPen(a5),-(a7) ;save pens, DrMode, IText
 move.l xxp_IText(a5),-(a7)
 move.l #.str,xxp_strg(a4) ;attach local strings
 clr.l xxp_errn(a4)        ;errn=0 pro-tem
 move.l xxp_Menu(a5),-(a7) ;save window's existing menu (if any)
 move.l xxp_Menu+2(a5),-(a7) ;save window's menuon (in lsw)
 bsr TLReqmuclr            ;and switch it off (if exists,on)
 clr.l xxp_Menu(a5)        ;so far, no TLMultiline menu
 move.l xxp_Fnum(a5),-(a7) ;save Fnum (in lsw)
 move.l xxp_Fsty(a5),-(a7) ;save Fsty,Tspc
 move.l xxp_RFont(a5),-(a7) ;save RFont,HFont
 move.l xxp_RTspc(a5),-(a7) ;save RTspc,HTspc
 move.l xxp_RFsty(a5),-(a7) ;save RFsty,HFsty

 moveq #0,d0
 move.w xxp_Fnum(a5),d0
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont             ;window font =  input font plain

 move.l xxp_pref(a4),a0
 moveq #10,d0
 moveq #0,d1
 move.b xxp_ysty(a0),d1
 moveq #1,d2
 bsr TLNewfont             ;requester font = as per prefs

 moveq #0,d0
 moveq #0,d1
 moveq #2,d2
 bsr TLNewfont             ;help font = 0 plain

 clr.w xxp_Tspc(a5)        ;Tspc=0
 clr.l xxp_RTspc(a5)       ;RTspc,HTspc = as per prefs
 move.b xxp_yspc(a0),xxp_RTspc+1(a5)

 move.w #$0100,xxp_FrontPen(a5)   ;pens = 1,0
 move.b #RP_JAM2,xxp_DrawMode(a5) ;drawmode = jam2

 sub.w #128,a7             ;* create a workspace
 move.l a7,a6              ;* a6 = workspace pointer throughout Multiline

; Multiline - temporary variables, offset from (A6) in stack

.mmem: equ 0               ;.L memory base
.mtop: equ 4               ;.L current memory top
.fdir: equ 8               ;.L limit of memory, also 130 bytes for dir
.ffil: equ 12              ;.L limit of .fdir, also 34 bytes for fil
.lins: equ 16              ;.L current number of lines
.curr: equ 20              ;.L current line
.crsr: equ 24              ;.W cursor tab
.mmxc: equ 26              ;.W max chrs per line
.topl: equ 28              ;.L topline on display
.fonh: equ 32              ;.W font height
.tpla: equ 34              ;.L topline address
.crra: equ 38              ;.L current line address
.slns: equ 42              ;.W lines that currently fit on window
.offs: equ 44              ;.W operative offset
.d2d5: equ 46              ;.L*4 current d2-d5 for ScrollRaster of window
.rngs: equ 62              ;.L starting line of range
.rnge: equ 66              ;.L ending line of range
.kybd: equ 70              ;.W <> if crsr posn in pixels
.glob: equ 72              ;.L global string address
.work: equ 76              ;.L used by .rwrp to hold old .lins value
.chnd: equ 80              ;.L return bits (see below)
.forb: equ 84              ;.L TLReqedit forbids
.lock: equ 88              ;.W 0=unlock, -1=lock
.rlok: equ 90              ;.W 0 = can lock/unlock  -1 = cannot unlock
.slir: equ 92              ;.W -1 = scrollers present
.valc: equ 94              ;.W -1 = don't request width in .vald unless must
.ypos: equ 98              ;.W ypos used by .draw
.pqal: equ 100             ;.L frst line to be printed
.pqzl: equ 104             ;.L last line of page to be printed
.pqzz: equ 108             ;.L last line to be printed
.pqla: equ 112             ;.L address of first line to be printed
.pqpg: equ 116             ;.B lines per page
.pqcl: equ 117             ;.B chrs per line
.pqmg: equ 118             ;.B chrs in margin
.pqts: equ 119             ;.B 0/1/2/3 = none/print/skip/abandon print
.pqkk: equ 120             ;.L line num clicked in .pqdo/.hook subroutine

; .chnd bits  0: 1 if mem changed since call
;             1: 1 if mem changed since save
;
; The initial state of .chnd is set by D0 on call

; Multiline - check memory exists, else create, other setting up

 clr.w .slir(a6)           ;set .slir if scrollers
 tst.l xxp_scrl(a5)
 beq.s .nsld
 subq.w #1,.slir(a6)
 move.l xxp_scrl(a5),a0    ;init horz scroller
 move.l #2048,xxp_hztt(a0)
 clr.l xxp_hztp(a0)
 move.l #2048,xxp_hzvs(a0)
 moveq #0,d0
 moveq #1,d1
 bsr TLWscroll

.nsld:

 clr.w .lock(a6)           ;set .lock = -1 if bit 31 of d6 (=input d0) set
 clr.w .rlok(a6)           ;by default, unlocked, can lock / unlock
 tst.l d6
 bpl.s .nlok               ;if D0 bit 31 set on call:
 subq.w #1,.lock(a6)       ;  lock text
 subq.w #1,.rlok(a6)       ;  forbid unlocking
 clr.w .offs(a6)           ;  offs = 0
 bclr #31,d6
.nlok:

 bclr #0,d6                ;mem not yet changed since call
 and.l #$0FFF,d5           ;forb bits - only bits 0-11 applicable
 btst #2,d6
 beq.s .nfpg               ;go unless paging forbidden
 bset #4,d6                ;forbid blocking
 bset #5,d6                ;forbid page/block shape
.nfpg:
 move.l d5,.forb(a6)
 move.l d6,.chnd(a6)       ;bits set by caller (0=changed, 1=unsaved)

 clr.w .kybd(a6)           ;annul .kybd
 move.l xxp_FSuite(a4),a0
 move.w xxp_Fnum(a5),d0
 mulu #xxp_fsiz,d0
 move.w ta_YSize(a0,d0.w),.fonh(a6) ;set font height
 move.l d7,.glob(a6)       ;save global string address
 clr.w .crsr(a6)           ;init .crsr

 move.l xxp_Mmem(a5),d0    ;memory already created?
 bne.s .memc               ;yes, go
 move.l xxp_sysb(a4),a6
 move.l xxp_Mmsz(a5),d0
 moveq #MEMF_FAST,d1
 jsr _LVOAllocVec(a6)      ;* create memory
 move.l a7,a6              ;re-point a6 to internal variables
 beq .bad1                 ;bad if out of memory
 move.l d0,a0
 add.l xxp_Mmsz(a5),a0
 clr.b -34(a0)             ;init .ffil (filename for saving)
 clr.b -164(a0)            ;init .fdir (dirname for saving)

 move.l d0,a0
 move.l a0,xxp_Mmem(a5)    ;initialise wsuw data
 clr.b (a0)+
 move.l a0,xxp_Mtop(a5)
 clr.l xxp_Mcrr(a5)
 move.w #76,xxp_Mmxc(a5)
 clr.l xxp_Mtpl(a5)
.memc:

 move.l xxp_Mmem(a5),.mmem(a6) ;init .mmem
 move.l xxp_Mcrr(a5),.curr(a6) ;init .curr
 move.w xxp_Mmxc(a5),.mmxc(a6) ;init .mmxc
 move.l xxp_Mtop(a5),.mtop(a6) ;init .mtop
 move.l xxp_Mtpl(a5),.topl(a6) ;init .topl

 add.l xxp_Mmsz(a5),d0     ;* initialise other pointers, validate memory
 sub.l #34,d0
 move.l d0,.ffil(a6)       ;init .ffil
 sub.l #130,d0
 move.l d0,.fdir(a6)       ;init .fdir
 move.w #-1,.valc(a6)
 bsr .vald                 ;initialise lins, mtop, validate text
 move.b xxp_lppg(a4),.pqpg(a6) ;get intuition printer prefs
 move.b xxp_cpln(a4),.pqcl(a6)
 move.b xxp_marg(a4),.pqmg(a6)

 lea .ment,a0              ;* initialise menu
 bsr TLReqmenu
 tst.l d0                  ;bad if can't
 beq .bad2
 bsr TLReqmuset
 bsr .able                 ;switch menu items on/off

; Multiline - recycle here if window to be redrawn with new .curr

.kapt:
 move.l .mmem(a6),a0       ;seek .curr - a0 scans .mmem
 move.l .curr(a6),d0       ;d0 counts lines
 bra.s .nxcr
.crfw:
 tst.b (a0)+               ;to next line
 bne .crfw
.nxcr:
 subq.l #1,d0              ;until .curr reached
 bpl .crfw
 move.l a0,.crra(a6)       ;set .crra

; Multiline - recycle here if window to be redrawn with same .curr

.nsls:
 bsr .slsr                 ;check .topl, get .tpla, clear window, &c
 beq .bad3                 ;bad if window height > font height
 bsr .chek                 ;preview curr, set .offs
 beq .done                 ;go if bad (when errn already set)
 bsr .draw                 ;draw all lines on window
 beq .done                 ;go if bad (when errn already set)
 bpl .nsls                 ;go try again if window resized

; Multiline - recycle here to wait for keyboard input

.wait:
 bsr TLWCheck              ;redraw window if resized
 bne .nsls
 bsr .vert                 ;fix scrollers
 tst.w .lock(a6)
 bne .lokt                 ;go if locked
 bsr .edit                 ;edit .curr
 cmp.w #10,d0              ;redo if bad fixed offset
 beq .nsls
 bsr .conu                 ;process contin (if any)
 tst.l xxp_errn(a4)
 bne .done                 ;quit if .edit gave bad return

 move.b xxp_kybd+15(a4),d3 ;d3 = shift of last keyboard entry to TLReqedit
 move.b xxp_kybd+3(a4),d0  ;d0 = last keyboard entry to TLReqedit
 beq .wait
 cmp.b #$8E,d0             ;up arrow
 beq.s .upar
 cmp.b #$8F,d0             ;down arrow
 beq .dnar
 cmp.b #$80,d0             ;click
 beq .clik
 cmp.b #$95,d0             ;menu
 beq .mens
 cmp.b #$98,d0             ;scroller
 beq .scol
 btst #3,d3                ;Ctrl
 bne .ctrl
 bra .othr                 ;other inputs

; Multiline - up arrow

.upar:
 btst #0,d3                ;if shift, up a window full
 bne .upwd

.up1:
 move.l .curr(a6),d0       ;don't scroll if curr already = 0
 beq .wait
 cmp.l .topl(a6),d0        ;go if topl < curr
 bne .upcn
 moveq #0,d1               ;d1 = amt to scroll
 move.w .fonh(a6),d1

 moveq #0,d0               ;do the scroll
 neg.l d1
 move.l .d2d5(a6),d2
 move.l .d2d5+4(a6),d3
 move.l .d2d5+8(a6),d4
 move.l .d2d5+12(a6),d5
 move.l xxp_WPort(a5),a1
 move.l a6,a2
 bsr TLWCheck
 bne.s .updc
 move.l xxp_gfxb(a4),a6
 jsr _LVOScrollRaster(a6)  ;(don't scroll if window resized)
 move.l a2,a6
.updc:

 subq.l #1,.curr(a6)       ;dec curr, topline
 subq.l #1,.topl(a6)
 beq.s .upb0               ;(go if topline became zero)
 move.l .tpla(a6),a0       ;find line before topline
 subq.l #1,a0
.upbk:
 tst.b -(a0)
 bne .upbk
 addq.l #1,a0
 move.l a0,.tpla(a6)       ;put line before topline in tpla,crra
 move.l a0,.crra(a6)
 bra.s .upbc

.upb0:
 move.l .mmem(a6),.tpla(a6) ;if topline became zero, put mmem in tpla
 move.l .mmem(a6),.crra(a6) ;if curr became zero, put mmem in tpla

.upbc:                     ;go edit if unlocked (.edit will print curr)
 tst.w .lock(a6)
 beq .wait

 sub.w #28,a7              ;echo topline if locked
 move.l a7,a0
 move.l #xxp_xoffs,(a0)+   ;tag 1: fixed offset
 clr.w (a0)+
 move.w .offs(a6),(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 2: point to text
 move.l .crra(a6),(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: no cursor
 move.l #-1,(a0)+
 clr.l (a0)                ;delimit tags
 moveq #0,d0               ;xpos = 0
 moveq #0,d1               ;ypos = 0
 move.l a7,a0
 bsr TLWCheck              ;don't echo if window resized
 bne.s .spbq
 jsr TLReqedit             ;echo topline
.spbq:
 add.w #28,a7
 bra .wait

.upcn:                     ;here if curr was below topline
 subq.l #1,.curr(a6)       ;dec curr
 bne.s .upnz               ;go unless became zero
 move.l .mmem(a6),.crra(a6)
 bra .wait

.upnz:                     ;find line before curr, put in crra
 move.l .crra(a6),a0
 subq.l #1,a0
.upck:
 tst.b -(a0)
 bne .upck
 addq.l #1,a0
 move.l a0,.crra(a6)
 bra .wait                 ;& to edit

.upwd:                     ;* up a window-full
 moveq #0,d0               ;set topl, curr
 move.w .slns(a6),d0
 subq.w #1,d0              ;d0 =  1 less than lines in window
 beq .up1                  ;(go if only 1 line on window)
 move.l .topl(a6),d1
 sub.l d0,d1               ;get new topl
 bcc.s .upw1               ;go if to line 0
 moveq #0,d1
.upw1:
 move.l d1,.topl(a6)       ;fix topl (slsr will fix tpla)
.upw2:
 move.l .curr(a6),d1       ;fix curr
 sub.l d0,d1
 bhi.s .upw3               ;go if curr becomes > 0

 clr.l .curr(a6)
 move.l .mmem(a6),.crra(a6) ;if new curr = 0, fix crra & go
 bra .nsls

.upw3:
 move.l d1,.curr(a6)
 move.l .crra(a6),a0
 subq.l #1,a0
 subq.l #1,d0
.upw4:
 tst.b -(a0)               ;find new crra
 bne .upw4
 dbra d0,.upw4
 addq.l #1,a0
 move.l a0,.crra(a6)
 bra .nsls

; Multiline - down arrow

.dnar:                     ;* down arrow
 btst #0,d3                ;shift?
 bne .dwwd                 ;yes, down a window full

.dw1:
 move.l .curr(a6),d0
 addq.l #1,d0
 cmp.l .lins(a6),d0        ;go if curr already at last line
 beq .wait

 move.l d0,.curr(a6)       ;bump curr
 move.l .crra(a6),a0
.dwca:
 tst.b (a0)+               ;curra to next line
 bne .dwca
 move.l a0,.crra(a6)

 tst.w .lock(a6)           ;go if text locked (always scroll up)
 bne.s .dwlk

 sub.l .topl(a6),d0        ;curr still on window?
 cmp.w .slns(a6),d0
 bcs .wait                 ;yes, done

 bsr .cotr                 ;else scroll up & continue
 bra .wait

.dwlk:                     ;* window is locked - scroll up 1
 move.l d0,.topl(a6)       ;topl at curr
 move.l a0,.tpla(a6)

 move.l .d2d5(a6),d2       ;scroll up past old topl
 move.l .d2d5+4(a6),d3
 move.l .d2d5+8(a6),d4
 move.l .d2d5+12(a6),d5
 moveq #0,d0
 moveq #0,d1
 move.w .fonh(a6),d1
 move.l xxp_WPort(a5),a1
 move.l a6,a2
 move.l xxp_gfxb(a4),a6
 jsr TLWCheck              ;don't scroll if window resized
 bne.s .dwlr
 jsr _LVOScrollRaster(a6)
.dwlr:
 move.l a2,a6

 move.l .curr(a6),d0       ;go if botline past eof
 moveq #0,d1
 move.w .slns(a6),d1
 add.l d1,d0
 cmp.l .lins(a6),d0
 bhi .wait

 move.l .crra(a6),a1       ;point a1 to last line
 subq.w #1,d1
 move.w d1,d2
 mulu .fonh(a6),d1         ;d1 = ypos of botline
 bra.s .dwln
.dwlf:
 tst.b (a1)+
 bne .dwlf
.dwln:
 dbra d2,.dwlf

 sub.w #28,a7              ;print last line
 move.l a7,a0
 move.l #xxp_xoffs,(a0)+   ;tag 1: fixed offset
 clr.w (a0)+
 move.w .offs(a6),(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 2: point to text
 move.l a1,(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: no cursor
 move.l #-1,(a0)+
 clr.l (a0)                ;delimit tags
 moveq #0,d0               ;xpos = 0
 move.l a7,a0
 jsr TLReqedit
 add.w #28,a7
 bra .wait

.dwwd:                     ;* down a window full
 moveq #0,d0
 move.w .slns(a6),d0       ;down lines on window - 1
 subq.w #2,d0              ;d0 counts lines
 bmi .dw1                  ;go if only 1 line in window

 move.l .curr(a6),d1       ;d1 bumps curr
 move.l .crra(a6),a0       ;a0 bumps crra
.dww1:
 addq.l #1,d1              ;bump curr
 cmp.l .lins(a6),d1
 bcc .nsls                 ;go if end reached
 addq.l #1,.topl(a6)       ;bump topl
 addq.l #1,.curr(a6)       ;bump curr
.dww2:
 tst.b (a0)+               ;bump crra
 bne .dww2
 move.l a0,.crra(a6)
 dbra d0,.dww1             ;until window-full bypassed
 bra .nsls

; Multiline - Ctrl keys

.ctrl:                     ;* Ctrl pressed
 btst #0,d3
 bne .shct                 ;go if shift
 cmp.b #1,d0
 beq .frst                 ;Ctrl a  -> first line
 cmp.b #4,d0
 beq .dlin                 ;Ctrl d  -> delete line
 cmp.b #26,d0
 beq .last                 ;Ctrl z  -> last line
.shct:
 cmp.b #1,d0
 beq .srng                 ;Shift/Ctrl/A  -> mark start of range
 cmp.b #4,d0
 beq .drng                 ;Shift/Ctrl/D  -> delete range
 cmp.b #9,d0
 beq .irng                 ;Shift/Ctrl/I  -> insert range
 cmp.b #26,d0
 beq .erng                 ;Shift/Ctrl/Z  -> mark end of range

.frst:                     ;* Ctrl a  -> first line
 clr.l .curr(a6)
 clr.l .topl(a6)           ;.curr, .topl = 0
 bra .kapt

.last:                     ;* Ctrl z  -> last line
 move.l .lins(a6),d0
 subq.l #1,d0
 move.l d0,.curr(a6)       ;curr = last line
 moveq #0,d1
 move.w .slns(a6),d1
 subq.l #1,d1
 beq .kapt                 ;(go if only 1 line in window - will fix topl)
 sub.l d1,d0
 move.l d0,.topl(a6)       ;topl = window-full above curr
 bpl .kapt
 clr.l .topl(a6)           ;or 0 if can't
 bra .kapt

.dlin:                     ;* Ctrl d  -> delete line
 ori.b #3,.chnd+3(a6)
 move.l .lins(a6),d0
 subq.l #1,d0
 beq .dlls                 ;-> new if only 1 line remains

 move.l #-1,.rngs(a6)
 move.l #-1,.rnge(a6)      ;annul range

 cmp.l .curr(a6),d0
 bne .dlok                 ;go unless curr is last line
 move.l d0,.lins(a6)       ;curr = last line: dec lins
 move.l .crra(a6),.mtop(a6) ;note new mtop
 subq.l #1,.curr(a6)       ;dec curr
 clr.w .crsr(a6)           ;clear crsr
 bra .kapt                 ;& redraw window
.dlok:

 move.l .curr(a6),d6
 sub.l .topl(a6),d6        ;d6 = curr's linum rel to topl
 move.l .d2d5(a6),d2       ;up scroll lines from curr
 move.l .d2d5+8(a6),d4     ;d2,d4,d5 as per scroll all
 move.l .d2d5+12(a6),d5
 move.l d6,d3
 mulu .fonh(a6),d3         ;d3 = border top + dist to curr
 add.l .d2d5+4(a6),d3
 moveq #0,d0               ;d0 = 0
 moveq #0,d1
 move.w .fonh(a6),d1       ;d1 = font height
 move.l xxp_WPort(a5),a1
 move.l a6,a2
 move.l xxp_gfxb(a4),a6
 bsr TLWCheck
 bne.s .dlic               ;go if window resized
 jsr _LVOScrollRaster(a6)  ;do the scroll
.dlic:
 move.l a2,a6
 move.l .mtop(a6),a2       ;a2 = old memtop
 move.l .crra(a6),a0       ;a0 puts
 move.l a0,a1              ;a1 gets
.dl1f:
 tst.b (a1)+               ;point a1 to line after crra
 bne .dl1f
 bra.s .dlfw               ;to next get
.dlnx:
 move.b (a1)+,(a0)+        ;tfr a line down
 bne .dlnx
.dlfw:
 cmp.l a2,a1               ;have we reached old mtop?
 bcs .dlnx                 ;no, tfr next line
 move.l a0,.mtop(a6)       ;yes, note new memtop
 subq.l #1,.lins(a6)       ;dec lins
 clr.w .crsr(a6)           ;clr crsr
 move.l .crra(a6),a1       ;a1 finds bottom line of window
 move.w .slns(a6),d5
 sub.w d6,d5               ;d5-1 = bottom line rel to curr
 subq.w #1,d5
 beq .wait                 ;go if curr on bottom line
.dlbn:
 tst.b (a1)+               ;to next line
 bne .dlbn
 cmp.l a0,a1               ;go if past last line
 bcc .wait
 subq.w #1,d5              ;until bottom line reached
 bne .dlbn

 sub.w #28,a7              ;room for tags
 move.l a7,a0
 move.l #xxp_xoffs,(a0)+   ;tag 1: fixed offset
 clr.w (a0)+
 move.w .offs(a6),(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 2: text address
 move.l a1,(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: crsr = -1 (i.e. none)
 move.l #-1,(a0)+
 clr.l (a0)
 moveq #0,d0               ;d0 = xpos
 move.w .slns(a6),d1
 subq.w #1,d1
 mulu .fonh(a6),d1         ;d1 = ypos
 move.l a7,a0              ;a0 = tags
 jsr TLReqedit             ;show line
 add.w #28,a7
 bra .wait

.dlls:                     ;if only line, clear it rather than delete
 move.l .crra(a6),a0
 clr.b (a0)
 clr.w .crsr(a6)
 bra .wait

.srng:                     ;* Shift/Ctrl/A  -> mark start of range
 move.l .curr(a6),.rngs(a6)
 bra .wait

.erng:                     ;* Shift/Ctrl/Z  -> mark end of range
 move.l .curr(a6),.rnge(a6)
 bra .wait

.newg:                     ;* new the memory
 move #43,d0
 moveq #2,d1
 move.l xxp_Help(a4),-(a7)
 move.w #220,xxp_Help(a4)
 move.w #6,xxp_Help+2(a4)
 bsr TLReqchoose           ;caution user
 move.l (a7)+,xxp_Help(a4)
 cmp.w #1,d0
 bne .wait
.newc:
 bsr .new
 bra .kapt

.drng:                     ;* Shift/Ctrl/D  -> delete range
 moveq #40,d0
 moveq #2,d1
 move.l xxp_Help(a4),-(a7)
 move.w #226,xxp_Help(a4)
 move.w #5,xxp_Help+2(a4)
 bsr TLReqchoose           ;caution user
 move.l (a7)+,xxp_Help(a4)
 cmp.w #1,d0
 bne .wait

 bsr .vrng
 beq .wait                 ;go if bad range

 ori.b #3,.chnd+3(a6)
 move.l d1,d2              ;d2 = no. of lines deleted
 sub.l d0,d2
 addq.l #1,d2
 sub.l d2,.lins(a6)        ;deduct from lins
 beq .newc                 ;if all lines deleted, to new

 cmp.l .curr(a6),d1
 bcc.s .drls               ;go if curr <= last line
 sub.l d2,.curr(a6)        ;else, reduce curr by no. of lines deleted
 clr.w .crsr(a6)
 bra.s .drrd
.drls:
 cmp.l .curr(a6),d0        ;go if curr < 1st line
 bhi.s .drrd
 move.l d0,.curr(a6)       ;curr is in range - make curr = start of range
 clr.w .crsr(a6)
 cmp.l .lins(a6),d0
 bne.s .drrd
 subq.l #1,.curr(a6)       ;range extends to last line, curr befor range
.drrd:
 move.l .mmem(a6),a0       ;a0 finds start of range
 bra.s .drsn
.drsf:
 tst.b (a0)+
 bne .drsf
.drsn:
 subq.l #1,d0
 bpl .drsf
 move.l a0,a1              ;a1 finds end of range
.dref:
 tst.b (a1)+
 bne .dref
 subq.l #1,d2
 bne .dref
 move.l .mtop(a6),a2       ;a2 = old memtop
 bra.s .drtn
.drtf:
 move.b (a1)+,(a0)+        ;tfr next byte down
.drtn:
 cmp.l a2,a1               ;until old memtop reached
 bcs .drtf
 move.l a0,.mtop(a6)       ;note new memtop
 move.l #-1,.rngs(a6)
 move.l #-1,.rnge(a6)
 bra .kapt

.irng:                     ;* Shift/Ctrl/I  -> insert range
 bsr .vrng
 beq .wait                 ;go if range invalid
 move.l .curr(a6),d2       ;d0 = start; d1 = end; d2 = curr
 cmp.l d0,d2
 bcs.s .irgd               ;ok if curr < start
 cmp.l d2,d1
 bcc .irbd                 ;bad if  start <= curr <= end
.irgd:
 move.l .mmem(a6),a0       ;point a0 to start of range (a0 = what to insert)
 move.l d0,d2
 bra.s .irgn
.irgs:
 tst.b (a0)+
 bne .irgs
.irgn:
 subq.l #1,d2
 bpl .irgs
 move.l a0,a1              ;point a1 past end of range
 move.l d1,d2
 sub.l d0,d2
.irge:
 tst.b (a1)+
 bne .irge
 subq.l #1,d2
 bpl .irge
 move.l .mtop(a6),a2       ;a2 = old memtop
 move.l a1,d3
 sub.l a0,d3               ;d3 = bytes in range
 move.l a2,a3              ;a3 = proposed new memtop
 add.l d3,a3
 cmp.l .fdir(a6),a3
 bhi.s .irom               ;go if text out of mem

 ori.b #3,.chnd+3(a6)
 move.l a3,.mtop(a6)       ;fix memtop
 move.l d1,d2
 sub.l d0,d2
 addq.l #1,d2              ;d2 = lines in range
 move.l .crra(a6),a1       ;create a hole at crra (a1 = insertion point)
.irtf:
 move.b -(a2),-(a3)        ;tfr a byte forward
 cmp.l a1,a2               ;until insertion point reached
 bhi .irtf
 add.l d2,.lins(a6)        ;fix number of lines
 cmp.l a0,a1               ;compare insertion point - old range start
 bcc.s .iris               ;go if inserting forward
 add.l d3,a0               ;inserting backward - bump range start
 add.l d2,.rngs(a6)        ;                     bump range linums
 add.l d2,.rnge(a6)
.iris:
 move.b (a0)+,(a1)+        ;transfer range to insertion point
 subq.l #1,d3
 bne .iris
 bra .kapt
.irom:                     ;report error - out of memory
 moveq #46,d0
 bra.s .irrp
.irbd:                     ;report error - can't insert within own compass
 moveq #39,d0
.irrp:
 moveq #1,d1
 moveq #0,d2
 move.l xxp_Help(a4),-(a7)
 move.w #231,xxp_Help(a4)
 move.w #15,xxp_Help+2(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 bra .wait

; Multiline - miscellaneous keys pressed

.othr:                     ;* misc keyboard presses
 cmp.b #$0D,d0
 beq .wait                 ;recycle if return (the usual)
 cmp.b #$1B,d0
 beq .done                 ;quit if Esc
 cmp.b #$93,d0
 beq .done                 ;quit if close window
 cmp.b #$97,d0
 beq .done                 ;quit if inactive window
 bra .wait                 ;ignore others

.scoz:                     ;* scroller message - locked
 move.l xxp_scrl(a5),d0
 beq .wait                 ;ignore if no scroller (can't get here?)

 move.l d0,a0
 sub.w .offs(a6),d1        ;d1 = change to offs
 beq.s .scol               ;try vert if no horz change
 bmi.s .scou
 cmp.w #8,d1               ;increase: if < 8, make 8
 bcc.s .scop
 moveq #8,d1
 bra.s .scop
.scou:
 neg.w d1                  ;decrease: if < 8, make 8
 cmp.w #8,d1
 bcc.s .scon
 moveq #8,d1
.scon:
 neg.w d1
.scop:
 add.w d1,.offs(a6)        ;update offs
 bpl.s .scp0
 clr.w .offs(a6)           ;offs = 0 if < 0
.scp0:
 move.l xxp_hztt(a0),d0    ;d0 = max allowable offs
 sub.l xxp_hzvs(a0),d0
 cmp.w .offs(a6),d0
 bcc.s .scp2
 move.w d0,.offs(a6)       ;offs = max allowable if > max
.scp2:
 move.w .offs(a6),xxp_hztp+2(a0)
 bsr TLWslof               ;ignore futher messages
 bra .nsls                 ;& update display

.scol:                     ;* scroller message
 move.l xxp_scrl(a5),d0
 beq .wait                 ;ignore if no scroller (can't get here?)

 move.l d0,a0              ;a0 = slider gadget data
 move.l .topl(a6),d2       ;d2 = old topl
 moveq #0,d7
 move.w .slns(a6),d7       ;d7 = slns
 move.l xxp_vttp(a0),d0    ;d0 = new topl
 move.l d2,xxp_vttp(a0)    ;(keep old in case only crra moves)
 cmp.w #3,d3
 beq .up1                  ;go if up a step
 cmp.w #4,d3
 beq .dw1                  ;go if down a step
 move.l d0,d4

 sub.l d2,d4               ;d4 = new - old
 beq .wait                 ;ignore if new = old

 bsr TLWslof               ;clear other messages since slow
 move.l d0,.topl(a6)       ;note new topl
 tst.w .lock(a6)
 beq.s .scnl               ;go if unlocked
 move.l d0,.curr(a6)       ;else, put curr at topl
 bra .kapt

.scnl:
 move.l .curr(a6),d1
 sub.l d0,d1               ;d1 = curr - new topl
 bmi.s .sclf               ;new curr if d1<0
 cmp.l d7,d1
 bcs .nsls                 ;ok if d1 < slns
.sclf:
 move.l d0,.curr(a6)       ;new curr (= topl)
 cmp.l d2,d0
 bcs .kapt                 ;ok if new topl < old topl
 add.l d7,d0
 subq.l #1,d0              ;else, put curr at bot of window
 cmp.l .lins(a6),d0
 bcs .kapt
 move.l d0,.curr(a6)
 bra .kapt

.clik:                     ;* window clicked
 move.l xxp_kybd+4(a4),d0
 move.l xxp_kybd+8(a4),d1  ;d0,d1 = mouse xpos, ypos
 sub.w xxp_LeftEdge(a5),d0
 bcs .wait
 sub.w xxp_TopEdge(a5),d1  ;ignore if off printable area
 bcs .wait
 cmp.w xxp_PWidth(a5),d0
 bcc .wait
 cmp.w xxp_PHeight(a5),d1
 bcc .wait
 divu .fonh(a6),d1         ;d1 = line clicked rel to topline
 and.l #$FFFF,d1
 add.l .topl(a6),d1        ;d1 = line num clicked
 cmp.l .lins(a6),d1
 bcc .wait                 ;go if no such line
 move.l d1,.curr(a6)       ;d1 = curr
 move.w d0,.kybd(a6)       ;d0 = crsr xpos in pixels
 move.l .tpla(a6),a0
 sub.l .topl(a6),d1
 bra.s .clkf
.clkn:
 tst.b (a0)+               ;find new .crra
 bne .clkn
.clkf:
 dbra d1,.clkn
 move.l a0,.crra(a6)       ;set .crra
 bra .wait

; Multiline - respond to menu selections

.mens:                     ;* menu select
 move.l xxp_kybd+4(a4),d0  ;d0 = menu
 bmi .wait
 move.l xxp_kybd+8(a4),d1  ;d1 = menu item
 cmp.w #1,d0
 bcs.s .men0
 beq.s .men1
 cmp.w #3,d0
 bcs .men2
 beq .men3
 bra .wait                 ;(can't be menu 4 - menu 4 coopted by Reqedit)

.men0:                     ;menu 0...
 cmp.w #1,d1
 bcs .load                 ;#0 load
 beq .save                 ;#1 save
 cmp.w #3,d1
 beq .svas                 ;#3 save as
 cmp.w #5,d1
 beq .mprt                 ;#5 print
 cmp.w #7,d1
 beq .abut                 ;#7 about
 cmp.w #9,d1
 bcs .gprf                 ;#8 gui prefs
 beq .guig                 ;#9 guide
 cmp.w #11,d1
 bcs .lkul                 ;#10 lock/unlock
 cmp.w #12,d1
 beq .done                 ;#12 stop
 bra .wait

.men1:                     ;menu 1...
 cmp.w #1,d1
 bcs .frst                 ;#0 1st line
 beq .last                 ;#1 last line
 cmp.w #3,d1
 bcs .skfw                 ;#2 seek forward
 beq .skbk                 ;#3 seek back
 cmp.w #5,d1
 bcs .sklf                 ;#4 seek left
 beq .dwwd                 ;#5 down a window-full
 cmp.w #7,d1
 bcs .upwd                 ;#6 up a window-full
 beq .lnum                 ;#7 line number
 cmp.w #9,d1
 bcs .info                 ;#8 info
 bra .wait

.men2:                     ;menu 2...
 cmp.w #1,d1
 bcs .ilin                 ;#0 insert line
 beq .dlin                 ;#1 delete line
 cmp.w #3,d1
 beq .srng                 ;#3 range start
 cmp.w #5,d1
 bcs .erng                 ;#4 range end
 beq .irng                 ;#5 insert range
 cmp.w #7,d1
 bcs .drng                 ;#6 delete range
 cmp.w #9,d1
 bcs .svrg                 ;#8 save range
 beq .ifil                 ;#9 insert file
 cmp.w #11,d1
 beq .rwrp                 ;#11 rewrap range
 cmp.w #13,d1
 bcs .gmax                 ;#12 change max line len
 beq .spel                 ;#13 spell check range
 cmp.w #16,d1
 beq .newg                 ;#16 new
 bra .wait

.men3:                     ;menu 3...
 tst.w d1
 beq .font                 ;#0 font
 bra .wait                 ;else ignore

.load:                     ;* load
 bsr .ldfl                 ;open file
 beq .wait                 ;bad if can't
 bsr TLBusy
 bset #0,.chnd+3(a6)       ;mark as changed
 bclr #1,.chnd+3(a6)       ;mark as saved
 move.l .mmem(a6),d2
 move.l .fdir(a6),d3
 sub.l d2,d3
 jsr TLReadfile            ;read file
 beq.s .ldbd               ;go if bad read (leave old contents intact??)
 jsr TLClosefile
 tst.l d0
 ble.s .ldnl               ;go if null read (leave old contents intact)

 move.l d0,a0
 add.l .mmem(a6),a0
 move.l a0,.mtop(a6)       ;note new mtop
 clr.b -1(a0)              ;make sure last line has eol
 cmp.l d3,d0
 bcc.s .ldtr               ;go if file too big (truncate)
 bra.s .ldgd
.ldbd:                     ;report can't read
 moveq #84,d0
 bra.s .ldrp
.ldtr:                     ;report truncated
 moveq #85,d0
 bra.s .ldrp
.ldnl:                     ;report null read
 moveq #87,d0
.ldrp:
 moveq #1,d1
 moveq #0,d2
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
.ldgd:                     ;wrap up the load
 clr.l .topl(a6)
 clr.l .curr(a6)
 clr.w .crsr(a6)
 clr.w .valc(a6)
 bsr .vald                 ;validate after bad/trunc/null
 bsr TLUnbusy
 bra .kapt

.save:                     ;* save
 bsr .any
 beq .sgb1                 ;quit if mmem empty
 bsr .svfl
 beq .svas                 ;if can't open -> save as
 bra .sapk                 ;else, pick up svas where file open

.svas:                     ;* save as
 bsr .any
 beq .sgb1                 ;quit if mmem empty
 bsr .safl
 beq .wait                 ;quit if can't open

.sapk:
 bsr TLBusy
 bsr .exit                 ;replace $00's by $0A's
 move.l .mmem(a6),d2
 move.l .mtop(a6),d3
 sub.l d2,d3
 jsr TLWritefile           ;write file
 beq.s .sabd
 bclr #1,.chnd+3(a6)       ;signal saved
 bra.s .saok
.sabd:
 moveq #83,d0
 moveq #1,d1
 moveq #0,d2
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo             ;report if bad write
 move.l (a7)+,xxp_Help(a4)
.saok:
 bsr .ntry                 ;replace $0A's by $00's
 jsr TLClosefile           ;close file
 bsr TLUnbusy
 bra .wait

.mprt:                     ;* print &&&&
 move.w #290,xxp_Help(a4)
 move.w #10,xxp_Help+2(a4)
 move.l #272,d0
 moveq #5,d1
 bsr TLReqchoose           ;choose task
 cmp.w #1,d0
 bcs .wait
 beq.s .pqrg
 cmp.w #3,d0
 bcs.s .pqcr
 beq.s .pqaa
 cmp.w #5,d0
 bcc .wait

 bsr .pprf                 ;set printer prefs
 bra .mprt

.pqrg:                     ;print range
 bsr .vrng                 ;set d0,d1 = start,end of range
 beq .wait                 ;go if range invalid
 bra.s .pqpk
.pqcr:                     ;print all from current
 move.l .curr(a6),d0
 bra.s .pqac
.pqaa:                     ;print all
 moveq #0,d0
.pqac:
 move.l .lins(a6),d1
 subq.l #1,d1
.pqpk:                     ;* print lines d0-d1
 move.l d0,.pqal(a6)
 move.l d1,.pqzz(a6)
 bsr .pqdo                 ;do the print job
 bra .kapt

.abut:                     ;* about
 bsr .abot
 bra .wait

.guig:                     ;* view AmigaGuide
 bsr .guid
 bsr TLWslof
 bra .wait

.gprf:                     ;* GUI prefs
 moveq #-1,d0
 jsr TLPrefs
 bra .wait

.lkul:                     ;* lock / unlock
 clr.w .offs(a6)
 move.w .lock(a6),d0
 eori.w #-1,d0
 move.w d0,.lock(a6)       ;switch .lock
 beq.s .lkok
 move.w #173,d0            ;report now locked
 move.w #171,xxp_Help(a4)
 move.w #1,xxp_Help+2(a4)
.lkrp:
 moveq #1,d1
 moveq #1,d2
 bsr TLReqinfo
 bsr .able                 ;update menu on/offs
 bra .nsls
.lkok:
 move.l xxp_scrl(a5),a0
 clr.l xxp_hztp(a0)        ;annul horz scroller if now unlocked
 move.l #2048,xxp_hzvs(a0)
 moveq #0,d0
 moveq #1,d1
 bsr TLWscroll
 move.w #174,d0            ;report now unlocked
 bra .lkrp

.skfw:                     ;* seek forward
 bsr .sfwd
 bra .nsls

.skbk:                     ;* seek back
 bsr .sbak
 bra .nsls

.sklf:                     ;* seek left
 bsr .slef
 bra .nsls

.lnum                      ;* go to line number
 move.w #131,d0
 jsr TLStra0               ;point d0 to local string 131
 sub.w #64,a7              ;set up strings in a7 (so can change)
 move.l a7,a1
 move.l a1,xxp_strg(a4)
 clr.b (a1)+
.lnst:
 move.b (a0)+,(a1)+
 bne .lnst
 move.l a1,a0              ;put num of last string in limit
 move.b #' ',-1(a0)
 move.l .lins(a6),d0
 jsr TLHexasc
 clr.b (a0)
 clr.b (a4)
 moveq #1,d0               ;get lnum required
 moveq #-1,d1
 moveq #8,d2
 moveq #0,d3
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinput
 move.l (a7)+,xxp_Help(a4)
 add.w #64,a7
 move.l #.str,xxp_strg(a4)
 tst.l d0
 beq .wait                 ;retry if cancel
 move.l xxp_valu(a4),d0
 subq.l #1,d0              ;make result rel to 0
 bmi .lnum
 cmp.l .lins(a6),d0
 bcc .lnum                 ;go if bad lnum
 move.l d0,.curr(a6)
 clr.w .crsr(a6)
 bra .kapt                 ;go there

.info:                     ;* info re text
 bsr .data
 bra .wait

.ilin:                     ;* insert line
 move.l .crra(a6),a2       ;a2 = crra
 move.l .mtop(a6),a0
 cmp.l .fdir(a6),a0        ;ignore if out of mem
 bcc .wait
 ori.b #3,.chnd+3(a6)
 addq.l #1,.mtop(a6)       ;fix mtop
 move.l a0,a1
 addq.l #1,a1              ;tfr up a byte down to crra
.ilcu:
 move.b -(a0),-(a1)
 cmp.l a2,a0
 bhi .ilcu
 clr.b (a0)                ;blank line at crra
 clr.w .crsr(a6)           ;fix crsr
 addq.l #1,.lins(a6)       ;fix lins
 bra .nsls

.svrg:                     ;* save range
 bsr .vrng
 beq .wait                 ;quit if none
 bsr .any
 beq .sgb1                 ;quit if mmem empty

 move.l .fdir(a6),a0       ;(cache old fil,dir)
 sub.w #164,a7
 move.l a7,a1
 moveq #40,d0
.svrs:
 move.l (a0)+,(a1)+
 dbra d0,.svrs

 bsr .safl                 ;open file

 move.l a7,a0              ;(restore old fil,dir)
 move.l .fdir(a6),a1
 move.l d0,-(a7)
 moveq #40,d0
.svrr:
 move.l (a0)+,(a1)+
 dbra d0,.svrr
 move.l (a7)+,d0
 add.w #164,a7

 beq .wait                 ;quit if can't open
 move.l .mmem(a6),a0
 move.l .rngs(a6),d0
 beq.s .svr1
.svr0:
 tst.b (a0)+               ;find start of range
 bne .svr0
 subq.l #1,d0
 bne .svr0
.svr1:
 move.l a0,d2              ;d2 = start of range
 move.l .rnge(a6),d0
 sub.l .rngs(a6),d0
.svr2:
 tst.b (a0)+               ;find end of range
 bne .svr2
 subq.l #1,d0
 bpl .svr2
 move.l a0,d3              ;d3 = end of rng - start of rng = bytes in range
 sub.l d2,d3
 bsr .exit                 ;(change $0's to $A's)
 jsr TLWritefile
 beq.s .sgb2
 jsr TLClosefile           ;close file
 bsr .ntry                 ;(change $A's to $0's)
 bra .wait

.sgb1:                     ;bad 1: file empty
 moveq #86,d0
 bra.s .sgbd

.sgb2:                     ;bad 2: can't write
 bsr .ntry                 ;       (change $A's to $0's)
 moveq #83,d0

.sgbd:
 moveq #1,d1
 moveq #0,d2
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 bra .wait

.ifil:                     ;* insert file
 bsr .any
 beq .load                 ;-> load if mmem empty

 move.l .fdir(a6),a0       ;(cache old fil,dir)
 sub.w #164,a7
 move.l a7,a1
 moveq #40,d0
.ifis:
 move.l (a0)+,(a1)+
 dbra d0,.ifis

 bsr .ldfl                 ;open file

 move.l a7,a0              ;(restore old fil,dir)
 move.l .fdir(a6),a1
 move.l d0,-(a7)
 moveq #40,d0
.ifir:
 move.l (a0)+,(a1)+
 dbra d0,.ifir
 move.l (a7)+,d0
 add.w #164,a7

 beq .wait                 ;quit if can't open file
 bsr TLBusy
 ori.b #3,.chnd+3(a6)
 move.l .crra(a6),a2
 move.l .mtop(a6),a0       ;move mem from crra to top of memory
 move.l .fdir(a6),a1
.ifup:
 move.b -(a0),-(a1)
 cmp.l a2,a0
 bhi .ifup
 move.l a2,d2              ;read file into hole thus created
 move.l a1,d3
 sub.l d2,d3
 jsr TLReadfile
 beq.s .ifbr               ;go if bad read
 tst.l d0
 bne.s .ifgt               ;go if >0 bytes read ok
 move.w #134,d0
 bra.s .ifrp               ;report 0 bytes read
.ifbr:
 move.w #133,d0            ;report bad read
.ifrp:
 moveq #1,d1
 moveq #0,d2
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 moveq #0,d0               ;d0 = 0 if bad read / no bytes read
.ifgt:
 jsr TLClosefile           ;close file
 add.l d0,a2               ;point a2 to crra + bytes read
 move.l .fdir(a6),a0
.iftf:
 move.b (a1)+,(a2)+        ;move rest of file down to fill the gap
 cmp.l a0,a1
 bcs .iftf
 move.l a2,.mtop(a6)       ;note new mtop
 bsr TLUnbusy
 tst.l d0
 beq .nsls                 ;go if nothing read
 clr.w .valc(a6)
 bsr .vald                 ;else validate, re-check everything
 bra .kapt

; Multline - rewrap

.rwrp:                     ;* rewrap range
 move.w #263,xxp_Help(a4)
 move.w #9,xxp_Help+2(a4)
 move.w #258,d0
 moveq #4,d1
 bsr TLReqchoose           ;choose para/all/range/canc
 cmp.w #1,d0
 bcs .wait
 beq.s .rwpc
 cmp.w #3,d0
 beq.s .rwpr
 bcc .wait

 clr.l .rngs(a6)           ;rewrap all
 move.l .lins(a6),d0
 bra.s .rwpe

.rwpc:                     ;rewrap current line to next blank line
 move.l .curr(a6),d0
 move.l d0,.rngs(a6)
 move.l .crra(a6),a0
.rwpf:
 tst.b (a0)+
 bne .rwpf
 addq.l #1,d0
 cmp.l .lins(a6),d0
 beq.s .rwpe
 tst.b (a0)
 bne .rwpf
.rwpe:
 subq.l #1,d0
 move.l d0,.rnge(a6)

.rwpr:                     ;rewrap range
 bsr .vrng
 beq .wait                 ;go if range invalid
 move.l .lins(a6),.work(a6)  ;remember old .lins value
 bsr TLBusy                ;busy pointer

;set up registers
 move.l d0,.curr(a6)       ;leave curr,topl at start of range
 move.l d0,.topl(a6)
 move.l d1,d7              ;d7 counts input lines
 sub.l d0,d7
 addq.l #1,d7
 move.w .mmxc(a6),d6       ;d6 = mmxc
 moveq #0,d5               ;d5 counts chrs so far in output lines
 move.l d0,d4              ;d4 counts output linum
 move.l d0,d3              ;d3 counts input linum
 moveq #0,d2               ;d2 = ltyp of op line

;move input lines to top of mem
 move.l .mmem(a6),a2
 bra.s .rw0n
.rw0f:                     ;point a2 to 1st line of range
 tst.b (a2)+
 bne .rw0f
.rw0n:
 subq.l #1,d0
 bpl .rw0f
 move.l a2,.crra(a6)       ;set crra to start of range
 move.l .mtop(a6),a1       ;move all from range start to top of mem
 move.l .fdir(a6),a0
.rwhl:
 move.b -(a1),-(a0)
 cmp.l a2,a1               ;a0 gets input, a1 gets output
 bhi .rwhl

; process next input line...
.rwip:                     ;* get next input line
 move.l a0,d0
 sub.l a1,d0               ;d0 = gap between input & output
 cmp.l #20,d0              ;out of mem of < 20
 bcs .rwom
 tst.b (a0)                ;go if input line null
 beq .rwe0
 cmp.b #32,(a0)            ;go if input line starts with space
 beq .rwe1

; preview next word of input line
.rwnw:
 move.l a0,d1              ;d1 remembers starting a0
 cmp.b #32,(a0)
 beq .rw2s                 ;go if "word" start with space
.rwwl:
 tst.b (a0)+               ;look at next byte
 beq.s .rwwe               ;go if eol
 cmp.b #32,-1(a0)          ;until eol/space found
 bne .rwwl
.rwwe:
 subq.l #1,a0              ;point a0 back to eol/space
 move.l a0,d0
 sub.l d1,d0               ;d0 = bytes in word        } if spc at start, a
 move.l d1,a0              ;a0 back to start of word  } 1 byte "word"
 moveq #0,d1
 tst.l d5
 beq.s .rwwc               ;don't prepend space if: - new output line
 cmp.b #32,-1(a1)          ;                        - last output chr is spc
 beq.s .rwwc
 moveq #1,d1               ;d1=1 if output line will prepend space
 addq.w #1,d5
.rwwc:

;will the word fit?
 add.w d0,d5               ;d5 = len of output line, if word (& space) added
 cmp.w d6,d5               ;will it fit?
 bgt.s .rwnn               ;go if not
 cmp.w d0,d5
 beq.s .rwno               ;go if we are starting a new output line
 tst.w d1
 beq.s .rwtr               ;go unless we prepend a space
 move.b #32,(a1)+          ;prepend a space
 bra.s .rwtr               ;& go transfer the word
.rwno:
 move.l a1,a3              ;starting an output line: a3 = its address

; transfer the word to the output line
.rwtr:
.rwtf:
 move.b (a0)+,(a1)+        ;transfer the word to the output line
 subq.w #1,d0
 bne .rwtf
 tst.b (a0)+               ;input line ended?
 beq.s .rwei               ;yes, go
 bra .rwnw                 ;no, try to append next word

; word would not fit in output line
.rwnn:
 sub.w d0,d5               ;d5 is at it was before attempting to  add word
 sub.w d1,d5
 bne .rweo                 ;go if d5 was not empty
 move.w d6,d0              ;new line was empty: so word will never fit
.rwch:
 move.b (a0)+,(a1)+
 subq.w #1,d0              ;so, add as much of the word as will fit, &
 bne .rwch                 ;                      start new output line
.rweo:
 bsr .rwtl                 ;remove trailing spaces
 clr.b (a1)+               ;end the output line
 moveq #0,d5               ;show none in progress
 addq.l #1,.lins(a6)       ;bump the line count
 addq.l #1,d4              ;bump the output line number
 bra .rwnw                 ;& go to next word of input line

; input line ended
.rwei:
 subq.l #1,.lins(a6)       ;dec lines count
 addq.l #1,d3              ;bump input line number
 subq.l #1,d7              ;dec lines in range count
 bne .rwip                 ;go to next line if morw

; no more input lines
 tst.l d5                  ;no more inputs - is an output line partly done?
 beq .rwwp                 ;no, go wrap up
 bsr .rwtl                 ;remove trailing spaces
 clr.b (a1)+               ;yes, put an eol for it (don't care about d4,d5)
 addq.l #1,.lins(a6)       ;bump lins
 bra .rwwp                 ;go wrap up

; null input line found
.rwe0:
 tst.w d5                  ;go if no output line in progress
 beq.s .rwe2
 bsr .rwtl                 ;remove trailing spaces
 clr.b (a1)+               ;else, finish output line
 moveq #0,d5               ;show no output line in progress
 addq.l #1,d4              ;bump output line number
 addq.l #1,.lins(a6)       ;bump lins
.rwe2:
 addq.l #1,a0              ;bump past input eol
 clr.b (a1)+               ;send blank output line
 addq.l #1,d4              ;bump output line number
 addq.l #1,.lins(a6)       ;bump lins
 moveq #0,d2               ;force ltyp mismatch next input line
 bra .rwei                 ;go input line ended

;input line starts with space
.rwe1:
 moveq #0,d2               ;force ltyp mismatch next line
 tst.w d5                  ;go if no output line in progress
 beq.s .rwe3
.rwp1:
 bsr .rwtl                 ;remove trailing spaces
 clr.b (a1)+               ;else, finish output line
 addq.l #1,d4              ;bump output line number
 addq.l #1,.lins(a6)       ;bump lins
.rwe3:
 move.l a1,a3              ;record start of output line
 moveq #1,d5               ;note 1 chr in it
.rwp2:
 moveq #1,d0
 move.b (a0)+,(a1)+        ;put the space in the output line
 bra .rwnw                 ;& to next input word

; here if word starts with space
.rw2s:
 tst.w d5                  ;go if op line unstarted
 beq .rwe3
 addq.w #1,d5              ;bump chr count
 cmp.w d6,d5
 bcs .rwp2                 ;go if room for space
 bra .rwp1                 ;else, start another line with the space

; here if new input line has ltyp mismatch
.rwep:
 move.l d0,d2              ;note new ltyp
 tst.l d5
 beq .rwnw                 ;go to next word if no output line in progress
 bsr .rwtl                 ;remove trailing spaces
 clr.b (a1)+               ;else, finish out line
 moveq #0,d5               ;note no new output line in progress
 addq.l #1,d4              ;bump out line number
 addq.l #1,.lins(a6)       ;bump lins
 bra .rwnw                 ;& to next word of input line

; rewrap has run out of memory
.rwom:
 move.w #129,d0            ;report out of memory
 moveq #1,d1
 moveq #0,d2
 move.w #246,xxp_Help(a4)
 move.w #5,xxp_Help+2(a4)
 bsr TLReqinfo
 tst.w d5                  ;go if no output line in progress
 beq.s .rwwp
 bsr .rwtl                 ;remove trailing spaces
 clr.b (a1)+               ;else, finish output line
 addq.l #1,.lins(a6)       ;bump lins
 move.l d4,.curr(a6)       ;put output line num reached in curr
 move.l a3,.crra(a6)       ;put its start address in crra

; rewrap done - transfer rest of lines
.rwwp:
 move.l .fdir(a6),a2       ;a2 = limit of input
 bra.s .rwwf
.rwwn:
 move.b (a0)+,(a1)+       ;tfr a byte down
.rwwf:
 cmp.l a2,a0
 bcs .rwwn                ;until input reached limit
 move.l a1,.mtop(a6)      ;record new mtop
 move.l .rnge(a6),d0
 add.l .lins(a6),d0
 sub.l .work(a6),d0
 move.l d0,.rnge(a6)       ;fix range end (changes by change in lins)
 bsr TLUnbusy
 bra .nsls                 ;* the rewrap is finished

; Multiline - get maximum line length

.gmax:
 move.w #142,d0            ;put lines 142, 143+ in xxp_gide
 jsr TLStra0

 move.l xxp_gide(a4),a1
 move.l a1,xxp_strg(a4)
 clr.b (a1)+
.gms1:
 move.b (a0)+,(a1)+
 bne .gms1
 exg a0,a1
 move.b #' ',-1(a0)
 moveq #0,d0
 move.w .mmxc(a6),d0       ;append existing mmxc to lines 142 (= line now)
 jsr TLHexasc
 move.b #')',(a0)+
 clr.b (a0)+
 exg a0,a1
 moveq #12,d0              ;now tfr help lines
.gmtf:
 move.b (a0)+,(a1)+
 bne .gmtf
 dbra d0,.gmtf
 move.w #2,xxp_Help(a4)    ;set up help
 move.w #13,xxp_Help+2(a4)
 moveq #1,d0               ;get new mmxc
 moveq #-1,d1
 moveq #3,d2
 moveq #0,d3
 clr.b (a4)
 bsr TLReqinput

 move.l #.str,xxp_strg(a4)
 move.w #143,xxp_Help(a4)
 tst.l d0                  ;go if canc
 beq .wait
 move.l xxp_valu(a4),d3    ;reject if <10, >254
 cmp.w #10,d3
 bcs .gmax
 cmp.w #255,d3
 bcc .gmax
 cmp.w .mmxc(a6),d3        ;compare new - old
 beq .wait                 ;go if same
 bcc.s .gmgt               ;accept if new > old
 move.w #156,d0
 moveq #2,d1
 bsr TLReqchoose           ;new < old: warn
 cmp.w #1,d0
 bne .wait                 ;go if cancel
 move.w d3,.mmxc(a6)       ;set new mmxc
 clr.l .rngs(a6)           ;put all lines in range
 move.l .lins(a6),d0
 subq.l #1,d0
 move.l d0,.rnge(a6)
 ori.b #3,.chnd+3(a6)      ;note altered
 bra .rwrp                 ;& go rewrap
.gmgt:
 ori.b #3,.chnd+3(a6)      ;new > old: set new mmxc
 move.w d3,.mmxc(a6)
 bra .kapt

; Multline - spell check range

.spel:                     ;* spell check range  ######
 bsr .vrng
 beq .wait

 bra .kapt

; Multline - exit bad

.bad1:                     ;* bad 1 - can't create Mmem
 addq.l #1,xxp_errn(a4)
 bra.s .donp
.bad2:                     ;* bad 2 - can't allocate menu (out of chip ram?)
 moveq #2,d0
 bra.s .bad
.bad3:                     ;* bad 3 - window height < font height
 moveq #32,d0
.bad:
 move.l d0,xxp_errn(a4)

; Multiline - exit good

.done:                     ;* bra here to return good (or bad if errn set)
 move.l .curr(a6),xxp_Mcrr(a5) ;put final data to window data
 move.l .topl(a6),xxp_Mtpl(a5)
 move.w .mmxc(a6),xxp_Mmxc(a5)
 move.l .mtop(a6),xxp_Mtop(a5)
 bsr .exit                 ;fill text w. $0A's
.donp:
 move.l .chnd(a6),xxp_chnd(a4) ;saved/changed in xxp_chnd
 move.l .lins(a6),xxp_lins(a4) ;number of lines in xxp_lins
 add.w #128,a7             ;remove temporary buffer
 moveq #0,d0               ;* restore window fonts ,&c
 moveq #0,d1
 moveq #0,d2
 move.w 16(a7),d0          ;d0 = orig Fnum
 move.w 12(a7),d1          ;d1 = orig Fsty
 bsr TLNewfont             ;set original font, style
 move.w 14(a7),xxp_Tspc(a5) ;set original Tspc
 moveq #0,d0
 move.w 8(a7),d0           ;d0 = orig RFont
 move.w 0(a7),d1           ;d1 = orig RFsty
 moveq #1,d2
 bsr TLNewfont             ;set original font, style
 moveq #0,d0
 move.w 10(a7),d0          ;d0 = orig HFont
 move.w 2(a7),d1           ;d1 = orig HFsty
 moveq #2,d2
 bsr TLNewfont             ;set original font, style
 move.l 4(a7),xxp_RTspc(a5) ;set original RTspc, HTspc
 add.w #20,a7              ;pop 5 stack items - remove original font data
 bsr TLReqmuclr            ;Multiline's menu (if any) off
 move.l xxp_Menu(a5),d0
 beq.s .muff
 move.l d0,a0              ;close TLMulitline's menu (if any)
 move.l xxp_gadb(a4),a6
 jsr _LVOFreeMenus(a6)
.muff:
 move.l (a7)+,d0           ;* restore original menu data
 move.l (a7)+,xxp_Menu(a5)
 beq.s .muof               ;go if window had no menu
 tst.w d0
 beq.s .muof               ;go if it was off
 bsr TLReqmuset            ;turn window's menu back on
.muof:
 move.l (a7)+,xxp_IText(a5)
 move.l (a7)+,xxp_FrontPen(a5)
 move.l (a7)+,xxp_Help(a4) ;restore global help
 move.l (a7)+,xxp_strg(a4) ;re-attach global strings
 movem.l (a7)+,d0-d7/a0-a6 ;bad if xxp_errn(a4)<>0
 rts

; Multiline - here in lieu of .edit if text is locked

.lokt:
 move.w #159,xxp_Help(a4)  ;set help
 move.w #12,xxp_Help+2(a4)
 tst.w .rlok(a6)
 bne.s .lokc
 addq.w #1,xxp_Help+2(a4)  ;one more line if unlockable
.lokc:
 bsr TLWCheck              ;go if resized
 bne .nsls
 jsr TLKeyboard            ;get user response
 cmp.b #$8E,d0             ;up arrow
 beq .upar
 cmp.b #$8F,d0             ;down arrow
 beq .dnar
 cmp.b #$95,d0             ;menu
 beq .mens
 btst #3,d3                ;Ctrl
 bne.s .lkct
 cmp.b #$1B,d0             ;quit if Esc
 beq .done
 cmp.b #$93,d0             ;quit if close window
 beq .done
 cmp.b #$97,d0             ;quit if inactive window
 beq .done
 cmp.b #$98,d0             ;go if slider
 beq .scoz
 bra .lokc                 ;reject other inputs

; Multiline - ctrl key clicked when locked

.lkct:                     ;ctrl if clicked
 cmp.b #1,d0
 beq .frst                 ;ctrl a - first line
 cmp.b #26,d0
 beq .last                 ;ctrl z - last line
 bra .lokt                 ;reject other inputs

; Multline - select font

.font:
 moveq #0,d0               ;select a font
 bsr TLReqfont
 subq.w #1,d0
 bmi.s .foqt               ;go if none selected
 moveq #0,d1
 moveq #0,d2
 bsr TLNewfont             ;attach selected font
 beq.s .foqt               ;go if can't
 move.l xxp_FSuite(a4),a0
 move.w xxp_Fnum(a5),d0
 mulu #xxp_fsiz,d0
 move.w ta_YSize(a0,d0.w),.fonh(a6) ;set font height
.foqt:
 jsr TLError               ;if error, report to output stream
 bra .kapt

************** Multiline Soubroutines *************

; Multiline Subroutine - validate memory contents

.vald:                     ;* validates all from .mmem to .mtop
 move.l #-1,.rngs(a6)      ;annul range
 move.l #-1,.rnge(a6)
 moveq #0,d7               ;d7 = count of bad chrs removed
 moveq #0,d6               ;d6 = longest line encountered
 moveq #0,d5               ;d5 = number of lines encountered
 moveq #0,d3               ;d3 = number of lines truncated
 move.l .mtop(a6),a3       ;a3 = memtop
 move.l .mmem(a6),a0       ;a0 gets
 move.l a0,a1              ;a1 puts
.line:                     ;* validate next line
 move.l a1,a2              ;remember address of line start
.char:                     ;* validate next chr
 move.b (a0)+,d0
 cmp.b #9,d0
 bne.s .chrc               ;go if not tab chr
 move.b #32,(a1)+          ;put spaces
 bra .char
.chrc:
 move.b d0,(a1)+           ;tfr chr
 beq.s .eol                ;eol if $00
 cmp.b #$0A,d0
 beq.s .eol                ;eol if $0A
 cmp.b #32,d0
 bcs.s .badc               ;bad if <32
 cmp.b #127,d0
 bcs .char                 ;ok if 32 - 126
 cmp.b #160,d0
 bcc .char                 ;ok if 160 - 255
.badc:                     ;* bad chr found
 addq.l #1,d7              ;bump bad chr count
 subq.l #1,a1              ;remove bad chr
 bra .char
.eol:                      ;* eol found
 subq.l #1,a1
 tst.l d5
 beq.s .eol2               ;go if 1st line
.eol1:
 cmp.b #32,-(a1)           ;remove trailing spaces
 beq .eol1
 bra.s .llen               ;a1 points to last non-space, or end of prev line
.eol2:
 cmp.b #32,-(a1)
 bne.s .llen               ;remove trailing spaces from 1st line
 cmp.l a2,a1
 bcc .eol2
.llen:
 addq.l #1,a1              ;point to end of line
 move.l a1,d4
 sub.l a2,d4               ;d4 = line len
 cmp.l #255,d4
 bcs.s .shrt               ;go if line <255 chrs
 move.l a2,a1              ;point a1 back to start of line
 move.l #254,d4            ;d4 = line len, as truncated
 add.l d4,a1               ;add back 254, to make it 254 chrs
 addq.l #1,d3              ;bump truncation counter
.shrt:
 clr.b (a1)+               ;null delimit line
 cmp.l d4,d6
 bcc.s .max                ;put line len in d6 if d4 > existing d6
 move.l d4,d6
.max:
 addq.l #1,d5              ;bump line count
 cmp.l .mtop(a6),a0        ;have we reached the end of lines?
 bcs .line                 ;no, to next line
 move.l d5,.lins(a6)       ;set .lins = number of lines
 move.l a1,.mtop(a6)       ;set .mtop = where output reached
 cmp.l .curr(a6),d5
 bhi.s .max1
 move.l d5,.curr(a6)       ;make sure .curr < number of lines
 subq.l #1,.curr(a6)
.max1:
 moveq #31,d0
 move.l d7,d1

 beq.s .rep1               ;go if no bad chrs found
 ori.b #3,.chnd+3(a6)
 bsr .rp10                 ;else, report no. of bad chrs found
.rep1:

 moveq #32,d0              ;go if no lines truncated
 move.l d3,d1
 beq.s .rep2
 ori.b #3,.chnd+3(a6)
 bsr .rp10                 ;else, report no. of lines truncated as >254 chrs
.rep2:

 cmp.w .mmxc(a6),d6        ;go if longest line > .mmxc
 bhi .tool
 beq .toos                 ;go if d6 = mmxc
 tst.w .valc(a6)           ;go if not calling line length unless must
 bmi .toos
 cmp.w #5,d6               ;go if longest line < 5
 bcs .toos
 cmp.w #76,.mmxc(a6)       ;always accept if longest allowed = 76
 beq .toos

 sub.w #200,a7             ;report ok - get longest allowed if required
 lea .s216,a0
 move.l a7,a1
 clr.b (a1)+
 move.w #190,d0            ;tfr strings 216-9 to stack
.tos0:
 move.b (a0)+,(a1)+
 dbra d0,.tos0
 move.l a7,a0              ;put d6 = longest loaded
 add.w #33,a0
 move.b #' ',1(a0)
 move.b #' ',2(a0)
 moveq #0,d0
 move.w d6,d0
 jsr TLHexasc
 move.l a7,a0              ;put current longest allowed
 add.w #54,a0
 move.b #' ',1(a0)
 move.b #' ',2(a0)
 moveq #0,d0
 move.w .mmxc(a6),d0
 jsr TLHexasc
 moveq #1,d0               ;get ready to call Reqchoose
 moveq #2,d1
 cmp.w #76,d6
 bcc.s .tos1
 moveq #3,d1               ;if longest < 76, add string 219
.tos1:
 move.l xxp_strg(a4),196(a7)
 move.l a7,xxp_strg(a4)    ;point strg to stack
 bsr TLReqchoose           ;choose longest allowed option
 move.l 196(a7),xxp_strg(a4)
 add.w #200,a7
 cmp.w #2,d0
 bcs.s .toos               ;go if as is chosen
 bne.s .to76               ;go if 76 chosen
.tolo:
 cmp.w #20,d6              ;longest (=76) chosen
 bcc.s .to20
 moveq #20,d6              ;make sure at least 20
.to20:
 move.w d6,.mmxc(a6)       ;put longest loaded -> longest allowed
 bra .toos
.to76:
 move.w #76,.mmxc(a6)      ;put 76 -> longest allowed
.toos:
 rts                       ;else, return ok

.rp10:                     ;** report str D0, w. value in D1 at tab 10
 jsr TLStrbuf
 move.l d1,d0
 move.l a4,a0
 add.w #10,a0
 jsr TLHexasc
 moveq #0,d1
 bsr TLReqchoose
 rts

.tool:                     ;here if loo-long lines found
 sub.w #200,a7             ;put strings 88-90 in stack
 lea .st88,a0
 move.l a7,a1
 move.l a1,xxp_strg(a4)    ;point xxp_strg there
 clr.b (a1)+
 moveq #2,d0
.totf:
 move.b (a0)+,(a1)+
 bne .totf
 dbra d0,.totf
 move.l d6,d0              ;insert max string length
 move.l a7,a0
 add.w #14,a0
 jsr TLHexasc
 moveq #1,d0               ;choose new max / divide too-long lines
 moveq #2,d1
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqchoose
 move.l (a7)+,xxp_Help(a4)
 add.w #200,a7
 move.l #.str,xxp_strg(a4)
 cmp.w #1,d0
 bgt.s .towr               ;go if divide too-long lines
 move.w d6,.mmxc(a6)       ;else, set new .mmxc
 rts
.towr:                     ;* divide any too-long lines
 ori.b #3,.chnd+3(a6)
 moveq #0,d7               ;d7 counts chopped lines
 moveq #0,d1
 move.w .mmxc(a6),d1       ;d1 = required mmxc
 move.l .mmem(a6),a0       ;a0 scans
 move.l .mtop(a6),a2       ;a2 = mtop
.toln:                     ;next line...
 move.l a0,a1              ;a1 = start of line
.toch:
 tst.b (a0)+               ;find eol
 bne .toch
 move.l a0,d0              ;check its len
 sub.l a1,d0
 cmp.w d1,d0
 ble .took                 ;go if len ok
 move.l a1,a0              ;start too-long line again
 moveq #0,d2               ;d0 holds last space before too long
 add.l d1,a1               ;a1 = allowable limit of line
.tofw:
 cmp.b #32,(a0)+           ;find any spaces
 bne.s .tons
 move.l a0,d0              ;which put in d0 (d0 points to chr after spc)
.tons:
 cmp.l a1,a0               ;keep looking until allowable limit found
 bcs .tofw
 tst.l d0                  ;go if a space was found
 bne.s .togt
 move.l a0,d0              ;else overlay last chr
.togt:
 move.l d0,a0              ;restart after chop point
 clr.b -1(a0)              ;put eol before
 addq.l #1,.lins(a6)       ;bump no. of lines
 addq.l #1,d7              ;bump count of chopped lines
.took:
 cmp.l a2,a0               ;until last line reached
 bcs .toln
 moveq #33,d0              ;report no. of lines split
 move.l d7,d1
 bsr .rp10
 rts

; Multiline subroutine - check topl, set slns
;  1. if topl incompatible with curr, chooses a topl
;  2. sets slns
;  3. sets d2d5 to d2-d5 values for ScrollRaster

.tpck:
 movem.l d0-d7/a0-a3,-(a7) ;save all

 move.l xxp_Window(a5),a0  ;set .d2d5+0,4,8
 moveq #0,d0
 moveq #0,d1
 move.b wd_BorderRight(a0),d0
 sub.w d0,d1
 move.b wd_BorderLeft(a0),d0
 add.w wd_Width(a0),d1
 move.l d0,.d2d5(a6)       ;set .d2d5+0 = window lhs = border left
 subq.l #1,d1
 move.l d1,.d2d5+8(a6)     ;set .d2d5+8 = window rhs = wdth - rght - 1
 move.b wd_BorderTop(a0),d0
 move.l d0,.d2d5+4(a6)     ;set .d2d5+4 = window top = border top

 move.l .curr(a6),d0       ;do sanity check on topl
 tst.w .lock(a6)
 bne.s .tppt               ;if locked, topl always = curr

 sub.l .topl(a6),d0        ;go if curr > topl (as it should be)
 bcc.s .tprc

 move.l .curr(a6),d0       ;else if curr < 31, make provisional topl 0
 sub.l #30,d0
 bcs.s .tpp0
 add.l #25,d0              ;else, make topl = curr - 5
 bra.s .tppt
.tpp0:
 moveq #0,d0

.tppt:                     ;set topl with provisional value
 move.l d0,.topl(a6)

.tprc:
 moveq #0,d2
 move.w xxp_PHeight(a5),d2 ;set slns,d2d5+12
 divu .fonh(a6),d2
 and.l #$FFFF,d2           ;d2 = int(printable height / font height)
 move.l d2,d1
 move.w d2,.slns(a6)       ;set .slns = lines that will fit
 beq.s .tpbd               ;bad if no lines will fit

 mulu .fonh(a6),d2
 add.l .d2d5+4(a6),d2
 subq.l #1,d2
 move.l d2,.d2d5+12(a6)

 move.l .curr(a6),d0       ;topl - topl s/be < slns
 sub.l .topl(a6),d0
 cmp.l d1,d0
 bcs.s .tpgd               ;yes, go
 move.l .curr(a6),d0
 sub.l d1,d0               ;else, set topl to curr - slns + 1
 addq.l #1,d0
 bpl.s .tprb
 moveq #0,d0
.tprb:
 move.l d0,.topl(a6)

.tpgd:
 moveq #-1,d0              ;go quit good
 bra.s .tpqt

.tpbd:                     ;here if bad - no lines will fit
 moveq #0,d0

.tpqt:
 movem.l (a7)+,d0-d7/a0-a3 ;EQ if bad
 rts

; Multiline subroutine - check range is valid, report if not

.vrng:
 move.l .rngs(a6),d0
 bmi.s .vrb1
 move.l .rnge(a6),d1
 bmi.s .vrb2
 cmp.l d0,d1
 bcs.s .vrb3
 moveq #-1,d2              ;MI if good
 rts
.vrb1:
 moveq #36,d0
 bra.s .vrbc
.vrb2:
 moveq #37,d0
 bra.s .vrbc
.vrb3:
 moveq #38,d0
.vrbc:
 moveq #1,d1               ;report error
 moveq #0,d2
 move.l xxp_Help(a4),-(a7)
 move.w #231,xxp_Help(a4)
 move.w #15,xxp_Help+2(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 moveq #0,d0               ;EQ if bad
 rts

; Multiline subroutine - ready text for exit

.exit:
 move.l .mmem(a6),a0      ;a0 scans
 move.l .mtop(a6),a1      ;a1 is top of mem
.extc:
 tst.b (a0)+              ;find each eol
 bne .extc
 move.b #$0A,-1(a0)       ;which replace by $0A
 cmp.l a1,a0
 bcs .extc
 rts

; Multiline subroutine - fix text after saving (reverse effect of .exit)

.ntry:
 move.l .mmem(a6),a0      ;a0 scans
 move.l .mtop(a6),a1      ;a1 is top of mem
 moveq #$0A,d0
.entc:
 cmp.b (a0)+,d0           ;find each eof
 bne .entc
 clr.b -1(a0)             ;replace it by $00
 cmp.l a1,a0              ;until eof found
 bcs .entc
 rts

; Multiline subroutine - open file for save as

.safl:
 move.l .ffil(a6),a0       ;call TLAslfile
 move.l .fdir(a6),a1
 moveq #34,d0
 moveq #-1,d1
 jsr TLAslfile
 beq.s .sfqt               ;go if cancel / out of chip ram

 jsr TLOpenwrite           ;call TLOpenwrite
 bne.s .sfgd
 jsr TLError
 moveq #82,d0
 bra.s .sfrp

.sfgd:                     ;MI, D0=-1 if good
 moveq #-1,d0
 rts

.sfqt:
 moveq #80,d0
 tst.l xxp_errn(a4)
 beq.s .sfrp
 moveq #81,d0

.sfrp:
 move #1,d1
 moveq #0,d2
 move.l d0,d3
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 move.l d3,d0
 jsr TLStrbuf
 jsr TLOutput

 moveq #0,d0
 rts                       ;EQ, D0=0 if bad

; Multiline subroutine - open file for save

.svfl:
 move.l .fdir(a6),a0       ;tfr dir to buff
 move.l a4,a1
.sltf:
 move.b (a0)+,(a1)+
 bne .sltf
 move.l a4,d1              ;add fil to dir in buff
 move.l .ffil(a6),d2
 move.l a6,a2
 move.l xxp_dosb(a4),a6
 jsr _LVOAddPart(a6)
 move.l a2,a6
 tst.l d0                  ;go if AddPart fails
 beq.s .slqt
 jsr TLOpenwrite           ;EQ if bad
 bne.s .slqt
 jsr TLError
 moveq #-1,d0
.slqt:                     ;MI if ok
 rts

; Multiline subroutine - open file for load

.ldfl:
 move.l .ffil(a6),a0       ;call TLAslfile
 move.l .fdir(a6),a1
 moveq #34,d0
 moveq #1,d1
 jsr TLAslfile
 beq.s .lfqt               ;go if cancel / out of chipram

 jsr TLOpenread            ;call TLOpenread
 bne.s .lfgd
 jsr TLError
 moveq #82,d0
 bra.s .lfrp

.lfgd:
 moveq #-1,d0              ;MI, D0=-1 if good
 rts

.lfqt:
 moveq #80,d0
 tst.l xxp_errn(a4)
 beq.s .lfrp
 moveq #81,d0

.lfrp:
 moveq #1,d1
 moveq #0,d2
 move.l d0,d3
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 move.l d3,d0
 jsr TLStrbuf
 jsr TLOutput

 moveq #0,d0
 rts                       ;EQ, D0=0 if bad

; TLMultiline subroutine -
;   updates window if resized
;   validates topl
;   sets d2d5,slns,tpla
; returns bad if window too small for 1 line to fit

.slsr:
 bsr TLReqcls              ;clear window          EQ not resized
 bsr TLWupdate             ;update window         MI resized ok
                           ;                      GT bad: window < font ht

 bsr .tpck                 ;check topl, set d2d5,slns

 tst.l .topl(a6)           ;set tpla
 bne.s .slsc
 move.l .mmem(a6),a0       ;if topl = 0, tpla = mmem
 bra.s .slsw
.slsc:
 move.l .crra(a6),a0       ;seek tpla
 move.l .curr(a6),d1
 sub.l .topl(a6),d1        ;d1 = curr - topl
.slsf:
 tst.b -(a0)               ;find end of previous line
 bne .slsf
 dbra d1,.slsf             ;until at eol before topl
 addq.l #1,a0              ; to topl
.slsw:
 move.l a0,.tpla(a6)       ;set tpla

.slsq:
 moveq #-1,d0              ;MI if window resized
 rts

.slsb:
 moveq #0,d0               ;EQ if window height < font height
 rts

; TLMultiline subroutine -
;   check size, postioning  of .curr -> set .offs, set horz scroller info

.chek:
 tst.w .slir(a6)           ;go if no scrollers
 beq.s .chku

 tst.w .lock(a6)           ;if locked, update horz scroller data
 beq.s .chku
 move.l xxp_scrl(a5),a0
 move.w .offs(a6),xxp_hztp+2(a0)      ;if locked, tt = 2048, vs = PWidth
 move.w xxp_PWidth(a5),xxp_hzvs+2(a0) ;           tp = offset

.chku:
 tst.w .lock(a6)           ;leave .offs alone if locked
 bne.s .chgd
 clr.l xxp_errn(a4)

 sub.w #28,a7              ;* get line width & crsr posn
 move.l a7,a0
 move.l #xxp_xcrsr,(a0)+   ;tag 1: cursor
 clr.w (a0)+
 move.w .crsr(a6),(a0)+
 move.l #xxp_xnprt,(a0)+   ;tag 2: don't print
 move.l #-1,(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 3: point to text
 move.l .crra(a6),(a0)+
 clr.l (a0)                ;delimit tags
 move.l a7,a0
 moveq #0,d0
 moveq #0,d1
 jsr TLReqedit             ;get string length & crsr posn
 add.w #28,a7
 beq.s .chbd               ;go if bad (unlikely)

 moveq #-80,d0
.chtr:
 add.l #80,d0              ;try every 80 for offset
 cmp.w xxp_chnd(a4),d0
 bgt.s .chna               ;if offs > lhs of crsr, put offset at lhs of crsr
 move.w d0,.offs(a6)
 add.w xxp_PWidth(a5),d0
 cmp.w xxp_chnd+2(a4),d0   ;if crsr fits, use that
 bcc.s .chgd
 sub.w xxp_PWidth(a5),d0   ;else, to next
 bra .chtr
.chna:                     ;here is crsr too near rhs of 80 bit segment
 move.w xxp_chnd(a4),.offs(a6)

.chgd:
 moveq #-1,d0              ;MI if good
 rts

.chbd:                     ;* set errn if TLReqedit returns bad
 add.w #24,d0
 move.w d0,xxp_errn+2(a4)
 moveq #0,d0               ;EQ if bad (xxp_errn already set)
 rts

; Multiline subroutine - draw all lines on window

.draw:
 clr.l xxp_errn(a4)
 moveq #0,d7               ;d7 = relative linum
 move.l .topl(a6),d6       ;d6 = absolute linum

 clr.w .ypos(a6)

 move.l .tpla(a6),a3       ;a3 = line address

.dwnx:
 tst.w .lock(a6)
 bne.s .dwdo               ;if unlocked...
 cmp.l .crra(a6),a3        ;...skip if line with cursor
 beq.s .dwfw
.dwdo:

 sub.w #28,a7              ;room for tags
 move.l a7,a0
 move.l #xxp_xoffs,(a0)+   ;tag 1: fixed offset
 clr.w (a0)+
 move.w .offs(a6),(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 2: text address
 move.l a3,(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: crsr = -1 (i.e. none)
 move.l #-1,(a0)+
 clr.l (a0)
 moveq #0,d0               ;d0 = xpos
 moveq #0,d1               ;d1 = ypos
 move.w .ypos(a6),d1
 move.l a7,a0              ;a0 = tags
 jsr TLReqedit             ;show line
 add.w #28,a7
 beq.s .dwbd               ;go if bad (unlikely)

 cmp.w #12,d0              ;go if window resized
 beq.s .dwrs

.dwfw:
 tst.b (a3)+               ;bypass line delimiter
 bne .dwfw

 move.w .fonh(a6),d0       ;bump .ypos
 add.w d0,.ypos(a6)

 addq.l #1,d6              ;bump abs linum
 cmp.l .lins(a6),d6
 bcc.s .dwgd               ;go if no more lines
 addq.w #1,d7              ;bump rel linum
 cmp.w .slns(a6),d7
 bcs .dwnx                 ;until all lines in window done

.dwgd:
 moveq #-1,d0              ;MI = good
 rts

.dwrs:
 moveq #1,d0               ;GT = window resized
 rts

.dwbd:
 add.w #24,d0
 move.w d0,xxp_errn+2(a4)
 moveq #0,d0               ;EQ = bad   (unlikely)(errn already set)
 rts

; Multiline subroutine - edit current line

.edit:
 move.w #47,xxp_Help(a4)   ;set help
 move.w #20,xxp_Help+2(a4)

 move.l .crra(a6),a0       ;* put current line in FWork
 move.l xxp_FWork(a4),a1
.edtf:
 move.b (a0)+,(a1)+
 bne .edtf

 sub.w #92,a7              ;* room for 11 tags for TLReqedit
 move.l a7,a0
 move.l #xxp_xmaxc,(a0)+   ;tag 1: max chrs
 clr.w (a0)+
 move.w .mmxc(a6),(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 2: text address
 move.l xxp_FWork(a4),(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: cursor
 clr.w (a0)+
 move.w .crsr(a6),(a0)+
 move.l #xxp_xoffs,(a0)+   ;tag 4: forced offset
 clr.w (a0)+
 move.w .offs(a6),(a0)+
 move.l #xxp_xforb,(a0)+   ;tag 5: forbids  (force plaintext)
 move.l .forb(a6),(a0)+
 move.l #xxp_xtask,(a0)+   ;tag 6: task  (text w. contin line)
 move.l #xxp_xtcon,(a0)+
 move.l #xxp_xiclr,(a0)+   ;tag 8: clear tablet first
 move.l #-1,(a0)+
 move.l #xxp_xtral,(a0)+   ;tag 9: clear trailing spaces before return
 move.l #-1,(a0)+
 move.l #xxp_xkybd,(a0)+   ;tag 10: crsr pixel xpos in line clicked
 clr.w (a0)+
 move.w .kybd(a6),(a0)+    ;(annul .kybd after used)
 clr.w .kybd(a6)
 move.l #xxp_xmenu,(a0)+   ;tag 11: send Line Format menu strip
 move.l #4,(a0)+
 clr.l (a0)                ;delimit tags

 moveq #0,d0               ;d0 = xpos
 move.l .curr(a6),d1       ;d1 = ypos
 sub.l .topl(a6),d1
 mulu .fonh(a6),d1
 move.l a7,a0              ;a0 = tags

 jsr TLReqedit             ;* edit the line (.edit keeps return code)
 tst.w xxp_Help(a4)
 bpl.s .fhlp               ;go if help uncalled
 bclr #7,xxp_Help+2(a4)    ;mark help as uncalled
.fhlp:
 add.w #92,a7              ;discard tags

 movem.l d0/a6,-(a7)       ;restore background pen for scrolls
 move.l xxp_gfxb(a4),a6
 move.l xxp_WPort(a5),a1
 moveq #0,d0
 jsr _LVOSetBPen(a6)
 movem.l (a7)+,d0/a6

 move.w xxp_crsr+2(a4),.crsr(a6) ;update cursor
 tst.b xxp_chnd(a4)
 bpl .edgd                 ;go if text unchanged
 ori.b #3,.chnd+3(a6)      ;else, note text changed

 move.l xxp_FWork(a4),a0   ;* tfr newline to oldline (as far as will fit)
 move.l .crra(a6),a1       ;a0 gets, a1 puts
 moveq #0,d7               ;d7=0 if tfr'ing newline, -1 if tfr'ing contin
.edp0:
 tst.b (a1)                ;go if oldline finished
 beq.s .edp4
 tst.b (a0)                ;go if newline/contin finished
 beq.s .edp1
 move.b (a0)+,(a1)+        ;tfr next chr
 bra .edp0

.edp1:                     ;* newline/contin finished
 move.l a1,a0              ;(a1 to a0 ready for .edp2 in case we go there)
 tst.w d7
 bmi.s .edp2               ;go to .edp2 if we have just trf'ed contin line
 tst.b xxp_chnd+2(a4)
 bpl.s .edp2               ;go if .edp2 if no contin line
 clr.b (a1)+               ;send delimiter of newline
 moveq #-1,d7              ;flag we are getting contin line
 addq.l #1,.lins(a6)       ;bump no. of lines
 move.l xxp_FWork(a4),a0   ;point to contin line
 add.w #512,a0
 bra .edp0                 ;& resume trf'ing

.edp2:                     ;* newline/contin all tfr'ed, oldline eol not yet
 tst.b (a0)+               ;find end of oldline in a0
 bne .edp2
 subq.l #1,a0              ;a1,a0 point to delimiter of newline,oldline
 move.l .mtop(a6),a2       ;point a2 to old memtop
.edp3:
 move.b (a0)+,(a1)+        ;remove the gap between newline, oldline
 cmp.l a2,a0               ;until old memtop reached
 bcs .edp3
 move.l a1,.mtop(a6)       ;note new memtop
 bra.s .edgd               ;go - (newline/contin < oldline) now saved

.edp4:                     ;* eol of oldline reached
 move.l a4,a2              ;(a4 to a2 in case we go to .edp5)
 tst.b (a0)
 bne.s .edp5               ;to .edp5 if newline/contin eof not reached too
 tst.w d7                  ;if we just finished contin...
 bmi.s .edgd               ;go - (newline/contin = oldline) now saved
 tst.b xxp_chnd+2(a4)      ;if there is no contin...
 bpl.s .edgd               ;go - (newline/contin = oldline) now saved

.edp5:                     ;* here if newline/contin > oldline ....
 move.b (a0)+,(a2)+        ;put rest of newline/contin in buff
 bne .edp5
 tst.w d7                  ;go if we just tfr'ed contin
 bmi.s .edp7
 tst.b xxp_chnd+2(a4)      ;go if there is no contin
 bpl.s .edp7
.edp6:
 moveq #-1,d7              ;note we are tfr'ing contin
 addq.l #1,.lins(a6)       ;bump no. of lines
 move.l xxp_FWork(a4),a0
 add.w #512,a0             ;point a0 to contin line
 bra .edp5                 ;& resume tfr'ing to buff

.edp7:                     ;* a1 = delim of oldline
 subq.l #1,a2              ;* a2 = delim of newline/contin segment in buff
 move.l a2,d1              ;remember a2
 move.l .mtop(a6),a2       ;a2 = old memtop
 move.l a2,a3              ;a3 = new memtop = a2 + (d1 - a4)
 add.l d1,a3
 sub.l a4,a3
 cmp.l .fdir(a6),a3        ;is there enough memory?
 bhi .edom                 ;no, go -> out of memory
 move.l a3,.mtop(a6)       ;note new memtop
.edp8:
 move.b -(a2),-(a3)        ;create a hole down to a1 (incl delim of oldline)
 cmp.l a1,a2
 bhi .edp8
 move.l a4,a0              ;put from a4 (=buff)
.edp9:
 move.b (a0)+,(a1)+        ;tfr next byte
 cmp.l a3,a1               ;until new posn of oldline delim
 bcs .edp9

.edgd:
 moveq #-1,d1              ;* MI = good (return code still in D0)
 rts

.edom:                     ;* out of memory
 moveq #35,d0
 moveq #1,d1               ;report out of mem
 moveq #1,d2
 move.w #251,xxp_Help(a4)
 move.w #5,xxp_Help+2(a4)
 bsr TLReqinfo
 moveq #10,d0              ;& send return code as if bad fixed offset
 rts

; Multiline subroutine - process contin line returned by .edit

.conu:
 move.l d0,d7              ;* save .edit's return code in d7
 tst.b xxp_chnd+2(a4)
 bpl .codq                 ;* go if no contin

 move.l .rngs(a6),d0       ;* adjust range if required
 bmi.s .cor1
 cmp.l .curr(a6),d0
 bls.s .cor1
 addq.l #1,.rngs(a6)       ;bump start if > old curr
.cor1:
 move.l .rnge(a6),d0
 bmi.s .cor2
 cmp.l .curr(a6),d0
 blt.s .cor2
 addq.l #1,.rnge(a6)       ;bump end if >= old curr
.cor2:

 btst #6,xxp_chnd+2(a4)    ;* bump curr,crra
 beq.s .cosm               ;go if crsr on oldline
 addq.l #1,.curr(a6)
 move.l .crra(a6),a0       ;else, bump curr & crra
.cor3:
 tst.b (a0)+
 bne .cor3
 move.l a0,.crra(a6)

.cosm:                     ;* scroll down conu -> botline (if any)
 moveq #0,d5               ;d5 = line height
 move.w .fonh(a6),d5
 move.l .curr(a6),d3       ;d3 = conu line rel to topl
 sub.l .topl(a6),d3        ;( = curr - topl)
 btst #6,xxp_chnd+2(a4)
 bne.s .cosw
 addq.l #1,d3              ;(or, curr+1 - topl if crsr not on conu)
.cosw:
 cmp.w .slns(a6),d3        ;go if nothing to be scrolled down
 bcc .cocu

 mulu d5,d3                ;d3 = ypos of conu, rel to topl
 move.l d5,d1
 neg.l d1                  ;d1 = amt to scroll
 add.l .d2d5+4(a6),d3      ;d3 = ypos of conu on window = ytop
 move.l .d2d5+12(a6),d5    ;d5 = ybot
 move.l .d2d5(a6),d2       ;d2 = xleft
 move.l .d2d5+8(a6),d4     ;d4 = xright

 moveq #0,d0
 move.l xxp_WPort(a5),a1
 jsr TLWCheck
 bne.s .codq               ;(don't scroll if window resized)
 move.l a6,a2
 move.l xxp_gfxb(a4),a6
 jsr _LVOScrollRaster(a6)
 move.l a2,a6

 btst #6,xxp_chnd+2(a4)    ;done ok if crsr on conu
 bne.s .codq               ;(no need to echo conu, .edit will echo it)

 move.l .crra(a6),a1       ;* echo conu, if crsr on conu-1...
.cor9:
 tst.b (a1)+               ;find its text address
 bne .cor9

 sub.w #28,a7
 move.l a7,a0
 move.l #xxp_xoffs,(a0)+   ;tag 1: fixed offset
 clr.w (a0)+
 move.w .offs(a6),(a0)+
 move.l #xxp_xtext,(a0)+   ;tag 2: point to text
 move.l a1,(a0)+
 move.l #xxp_xcrsr,(a0)+   ;tag 3: no cursor
 move.l #-1,(a0)+
 clr.l (a0)                ;delimit tags
 moveq #0,d0               ;xpos = 0
 move.l d3,d1
 sub.l .d2d5+4(a6),d1      ;d1 = ypos of conu
 move.l a7,a0
 jsr TLReqedit             ;echo contin
 add.w #28,a7
 bra.s .codq               ;done ok

.cocu:                     ;* conu is off bot of window
 btst #6,xxp_chnd+2(a4)
 beq.s .codq               ;quit if crsr not on conu

 bsr.s .cotr               ;scroll up until curr on window

.codq:                     ;* restore d0 = return code from edit
 move.l d7,d0
 rts

; Multiline subroutine - scroll window up until curr is on window

.cotr:                     ;* bump topl & scroll up until conu fits
 addq.l #1,.topl(a6)
 move.l .tpla(a6),a0
.conx:
 tst.b (a0)+
 bne .conx
 move.l a0,.tpla(a6)

 moveq #0,d1               ;set d1 = lspace
 move.w .fonh(a6),d1

 move.l .d2d5(a6),d2       ;scroll up past old topl
 move.l .d2d5+4(a6),d3
 move.l .d2d5+8(a6),d4
 move.l .d2d5+12(a6),d5
 moveq #0,d0
 move.l xxp_WPort(a5),a1
 move.l a6,a2
 move.l xxp_gfxb(a4),a6
 move.l d1,d6
 jsr TLWCheck
 bne.s .corz
 jsr _LVOScrollRaster(a6)  ;don't scroll if window resized
.corz:
 move.l a2,a6
 rts

; Multiline subroutine - show "about" info

.abot:
 tst.l xxp_about(a4)      ;go if caller has set about info
 bne.s .abus
 moveq #67,d0             ;attach default about info
 moveq #13,d1
 bra.s .abdo
.abus:
 move.l .glob(a6),xxp_strg(a4) ;temporarily attach global strings
 clr.l xxp_Help(a4)
 move.w xxp_about(a4),d0  ;attach user about info
 move.w xxp_about+2(a4),d1
.abdo:
 moveq #0,d2              ;display about
 move.l xxp_Help(a4),-(a7)
 clr.l xxp_Help(a4)
 bsr TLReqinfo
 move.l (a7)+,xxp_Help(a4)
 move.l #.str,xxp_strg(a4)
 rts

; Multiline subroutine - see if memory buffer empty

.any:
 cmp.l #1,.lins(a6)
 bne.s .anyq
 move.l .mmem(a6),a0
 tst.b (a0)
.anyq:                    ;NE if anything
 rts                      ;EQ if nothing

; Multiline subroutine - new the mmem

.new:
 movem.l d0/a0,-(a7)
 bclr #1,.chnd+3(a6)       ;mark as "saved"
 bset #0,.chnd+3(a6)       ;mark as changed
 move.l #-1,.rngs(a6)      ;zap everything
 move.l #-1,.rnge(a6)
 move.l #1,.lins(a6)
 clr.l .curr(a6)
 clr.l .topl(a0)
 move.l .mmem(a6),a0
 clr.b (a0)+
 move.l a0,.mtop(a6)
 clr.w .crsr(a6)
 movem.l (a7)+,d0/a0
 rts

; Multiline subroutine - get a seek string

.sstr:
 move.w #92,xxp_Help(a4)  ;attach help
 move.w #15,xxp_Help+2(a4)
 clr.b (a4)
 move.w #135,d0
 moveq #0,d1
 moveq #30,d2
 moveq #0,d3
 bsr TLReqinput           ;get input
 beq .ssbd                ;go if cancel
 move.l a4,a0
 move.l a4,a1
 add.w #xxp_patt,a1       ;a0 gets, a1 puts
 tst.b (a0)
 beq.s .ssgd              ;keep xxp_patt if null input
 clr.b 31(a1)
 cmp.b #'|',(a0)
 bne.s .sscs
 move.b #$DF,31(a1)       ;xxp_patt+31 = 0 if sig, -1 if blind
 addq.l #1,a0
.sscs:
 move.b (a0)+,(a1)+       ;tfr input to xxp_patt
 bne .sscs
.ssgd:
 move.b xxp_patt(a4),d6   ;d6 = 1st chr, reject if null
 beq .sstr
 move.b xxp_patt+31(a4),d7 ;d7: EQ=significant, MI=blind
 moveq #-1,d0             ;MI = good
 rts
.ssbd:
 moveq #0,d0              ;EQ = bad (cancel)
 rts

; Multline subroutine - signal seek unfound

.skbd:
 move.l a6,a2
 move.l xxp_intb(a4),a6
 move.l xxp_Screen(a4),a0
 jsr _LVODisplayBeep(a6)
 move.l a2,a6
 rts

; Multliline subroutine - seek forward

.sfwd
 bsr .sstr                ;get string; d6 = 1st chr, d7 = $DF if caseblind
 beq.s .sfdn              ;go if cancel
 move.l a4,a3
 add.w #xxp_patt+1,a3     ;a3 points to 2nd chr, 1st chr in d6
 move.l .curr(a6),d4      ;d4 holds propoed curr
 move.l .lins(a6),d5      ;d5 = lins
 move.l .crra(a6),a2      ;a2 holds proposed crra
 bra.s .sfnx              ;try next line
.sffw:
 tst.b (a2)+              ;forward a line
 bne .sffw
 bsr.s .stst              ;seek string in it
 bne.s .sfnx              ;go if unfound
 move.l d4,.curr(a6)      ;found: set curr
 move.l a2,.crra(a6)      ;       set crra
 bra.s .sfdn
.sfnx:
 addq.l #1,d4             ;bump proposed curr
 cmp.l d5,d4
 bcs .sffw                ;continue until eof
 bsr .skbd                ;report string unfound
.sfdn:
 rts

; Multiline subroutine -
;   see if sought at (a3) in line (a2), case in d7 (EQ = sig), 1st chr in d6

.stst:
 move.l a2,d3              ;save a2 in d3
 tst.b d7
 bne.s .stz2               ;go if case blind
.stz0:
 tst.b (a2)
 beq.s .stzn               ;unfound if eol
 cmp.b (a2)+,d6            ;next chr of line matches 1st chr?
 bne .stz0                 ;no, keep looking
 move.l a2,a0              ;(a0) = chr after matched chr
 move.l a3,a1              ;(a1) = 2nd chr of sought
.stz1:
 tst.b (a1)                ;sought finished?
 beq.s .stzy               ;yes, string found
 cmpm.b (a0)+,(a1)+        ;no, match next chr
 beq .stz1                 ;continue if matched
 bra .stz0                 ;else, try next chr in line
.stz2:                     ;* here if case blind
 tst.b (a2)
 beq.s .stzn               ;unfound if eol
 move.b d6,d0
 move.b (a2)+,d1
 eor.b d1,d0               ;(all mismatched bits = 1)
 and.b d7,d0               ;(remove bit 5)
 tst.b d0                  ;all except bit 5 matched?
 bne .stz2                 ;no, keep looking
 move.l a2,a0              ;(a0) = chr after matched chr
 move.l a3,a1              ;(a1) = 2nd chr of sought
.stz3:
 tst.b (a1)                ;sought finished?
 beq.s .stzy               ;yes, string found
 move.b (a0)+,d0           ;else, match next chr
 move.b (a1)+,d1
 eor.b d1,d0
 and.b d7,d0
 beq .stz3                 ;continue if matched
 bra .stz2                 ;else, try next chr in line
.stzn:                     ;NE if string unfound
 move.l d3,a2
 moveq #-1,d0
 rts
.stzy:                     ;EQ if string found
 move.l a2,d0
 sub.l d3,d0
 subq.w #1,d0
 move.w d0,.crsr(a6)       ;set cursor
 move.l d3,a2              ;restore a2 = crra
 moveq #0,d0
 rts

; Multiline subroutine - seek back

.sbak
 bsr .sstr                ;get sought; d6 = 1st chr, d7 = $DF if case blind
 beq.s .sbdn              ;go if cancel
 move.l a4,a3
 add.w #xxp_patt+1,a3     ;a3 points to 2nd chr, 1st chr in d6
 move.l .curr(a6),d4      ;d4 holds proposed curr
 beq .sbbd                ;go if at 1st line already
 move.l .crra(a6),a2      ;a2 holds proposed crra
 bra.s .sbnx              ;try next line
.sbbk:
 tst.b -(a2)              ;back a line
 bne .sbbk
 addq.l #1,a2
 bsr.s .stst              ;seek string in it
 bne.s .sbnx              ;go if unfound
.sbys:
 move.l d4,.curr(a6)      ;found: set curr
 move.l a2,.crra(a6)      ;       set crra
 bra.s .sbdn
.sbnx:
 subq.l #1,a2             ;ready to go back a line
 subq.l #1,d4             ;dec proposed curr
 bne .sbbk
 move.l .mmem(a6),a2      ;to mmem if at 1st line
 bsr .stst                ;seek string in it
 beq .sbys                ;go if found
.sbbd:
 bsr .skbd                ;report string unfound
.sbdn:
 rts

; Multiline subroutine - seek left

.slef
 bsr .sstr                 ;get sought  d6 = 1st chr, d7 = $DF if case blind
 beq.s .sldn               ;go if cancel
 move.l a4,a3
 add.w #xxp_patt+1,a3      ;a3 points to 2nd chr of sought
 move.l .lins(a6),d5       ;d5 = lins
 moveq #0,d4               ;d4 holds proposed curr
 move.l .mmem(a6),a2       ;a2 holds proposed crra
 bra.s .sltr               ;go try 1st line
.slnx:
 tst.b (a2)+               ;to next line
 bne .slnx
.sltr:
 tst.b d7                  ;go if case blind
 bne.s .slbl
 cmp.b (a2),d6             ;first chr matched?
 bne.s .slfw               ;no, go
 move.l a3,a0              ;(a0) = 2nd chr sought
 move.l a2,a1              ;(a1) = 2nd chr of line
 addq.l #1,a1
.slcs:
 tst.b (a0)                ;end of sought reached?
 beq.s .slys               ;yes, string found
 cmpm.b (a0)+,(a1)+        ;else, match next chr
 beq .slcs
 bra.s .slfw               ;to next line if mismatch
.slbl:                     ;* here for case blind
 move.b (a2),d0            ;first chr matched?
 eor.b d6,d0
 and.b d7,d0
 tst.b d0
 bne.s .slfw
 move.l a3,a0              ;(a0) = 2nd chr sought
 move.l a2,a1              ;(a1) = 2nd chr of line
 addq.l #1,a1
.slbc:
 tst.b (a0)                ;end of sought reached?
 beq.s .slys               ;yes, string found
 move.b (a0)+,d0
 move.b (a1)+,d1           ;else, match next chr
 eor.b d1,d0
 and.b d7,d0
 tst.b d0
 beq .slbc                 ;to next chr unless mismatch
.slfw:                     ;* to next line
 addq.l #1,d4              ;bump proposed curr
 cmp.l d5,d4
 bcs .slnx                 ;until all lines looked at
 bsr .skbd                 ;report can't find string
 bra.s .sldn
.slys:                     ;string found...
 clr.w .crsr(a6)           ;set crsr
 move.l d4,.curr(a6)       ;set curr
 move.l a2,.crra(a6)       ;set crra
.sldn:
 rts

; Multiline subroutine - show data about memory contents

.data:
 move.l xxp_Help(a4),-(a7)
 moveq #107,d0             ;put strings 107+ in xxp_gide point xxp_strg ther
 jsr TLStra0               ;(so that we can modify them and be re-entrant)
 move.w #9,xxp_Help(a4)
 move.w #14,xxp_Help+2(a4)

 move.l xxp_gide(a4),a1
 move.l a1,xxp_strg(a4)
 clr.b (a1)+
 moveq #21,d0
.dttf:
 move.b (a0)+,(a1)+
 bne .dttf
 dbra d0,.dttf
 move.l xxp_gide(a4),a0    ;poke number of lines
 add.w #50,a0
 move.l .lins(a6),d0
 jsr TLHexasc
 move.l .mmem(a6),a0
 moveq #0,d7               ;d7 counts line number
 moveq #0,d6               ;d6 holds max line length
 moveq #0,d5               ;d5 counts paragraphs
 moveq #0,d4               ;d4 <> if paragraph has begun (msw=font,lsw=just)
 moveq #0,d3               ;d3 counts words
.dtln:                     ;scan next line
 tst.b (a0)
 beq.s .dtep               ;can't be in para if null
.dtsm:
 cmp.b #32,(a0)            ;can't be in para if starts with space
 bne.s .dtlt
.dtep:
 moveq #0,d4               ;note not in para
 bra.s .dtwd
.dtlt:
 move.l d7,d0              ;get line font, just
 swap d0                   ;put data in d0 halves, negate
 move.w d1,d0
 bset #31,d0
 cmp.l d0,d4               ;para continues?
 beq.s .dtwd               ;yes, go
 addq.l #1,d5              ;no, start a para
 move.l d0,d4              ;& note its type code
.dtwd:                     ;* count words in line
 move.l a0,a1              ;a1 = line start
.dtfs:                     ;seek for a possible word...
 move.b (a0)+,d0
 beq.s .dtel               ;go if eol reached
 cmp.b #'A',d0
 bcs .dtfs                 ;must start with A-Z or a-z
 cmp.b #'Z'+1,d0
 bcs.s .dtmb
 cmp.b #'a',d0
 bcs .dtfs
 cmp.b #'z'+1,d0
 bcc .dtfs
.dtmb:                     ;A-Z of a-z found - see if a-z follows
 move.b (a0)+,d0
 beq.s .dtel               ;go if eol
 cmp.b #'a',d0
 bcs .dtfs                 ;else seek a possible word start
 cmp.b #'z'+1,d0
 bcc .dtfs
.dtbd:                     ;bypass rest of word
 move.b (a0)+,d0
 beq.s .dtwe               ;word & line ends if eol
 cmp.b #'''',d0
 beq .dtbd                 ;word continues if ' or a-z
 cmp.b #'a',d0
 bcs.s .dtwg
 cmp.b #'z'+1,d0
 bcs .dtbd
.dtwg:
 addq.l #1,d3              ;word ends: bump word count
 bra .dtfs                 ;& seek another
.dtwe:
 addq.l #1,d3              ;word ends & eol found: bump word count
.dtel:
 move.l a0,d0              ;eol reached: get line len to d0
 sub.l a1,d0
 subq.l #1,d0
 cmp.l d0,d6
 bcc.s .dtnl
 move.l d0,d6              ;put in d6 if > existing maxlen
.dtnl:
 addq.l #1,d7              ;bump line num
 cmp.l .lins(a6),d7        ;until all lines done
 bcs .dtln
 move.l xxp_gide(a4),a0    ;insert max line len
 add.w #85,a0
 move.l d6,d0
 jsr TLHexasc
 move.l xxp_gide(a4),a0    ;insert total words
 add.w #120,a0
 move.l d3,d0
 jsr TLHexasc
 move.l xxp_gide(a4),a0    ;insert total paras
 add.w #155,a0
 move.l d5,d0
 jsr TLHexasc
 move.l xxp_gide(a4),a0    ;insert line number
 add.w #190,a0
 move.l .curr(a6),d0
 addq.l #1,d0
 jsr TLHexasc
 move.l xxp_gide(a4),a0    ;insert memory used
 add.w #225,a0
 move.l .mtop(a6),d1
 sub.l .mmem(a6),d1
 add.l #164,d1
 move.l d1,d0
 jsr TLHexasc
 move.l xxp_gide(a4),a0    ;insert memory unused
 add.w #260,a0
 move.l xxp_Mmsz(a5),d0
 sub.l d1,d0
 jsr TLHexasc
 moveq #1,d0               ;report stats
 moveq #8,d1
 moveq #0,d2
 bsr TLReqinfo
 move.l #.str,xxp_strg(a4)

 move.l (a7)+,xxp_Help(a4)
 rts

; Multiline subroutine - View Multiline.guide

.guid:
 move.l xxp_guid(a4),-(a7)
 move.l xxp_node(a4),-(a7)
 move.l #.s137,xxp_guid(a4)
 clr.l xxp_node(a4)
 bsr TLGuide
 move.l (a7)+,xxp_node(a4)
 move.l (a7)+,xxp_guid(a4)
 rts

; Multiline subroutine - enable / disable menu items

.able:
 move.l .forb(a6),d7       ;TLReqedit forbids
 move.l .chnd(a6),d6       ;TLMultiline forbids
 move.w .lock(a6),d5
 moveq #0,d0               ;* menu 0
 moveq #-1,d2
 moveq #0,d1               ;load
 bsr .ab31
 moveq #1,d1               ;save
 btst #2,d6
 bsr .aboo
 moveq #3,d1               ;save as
 btst #2,d6
 bsr .aboo
 moveq #10,d1              ;lock/unlock
 tst.w .rlok(a6)
 bsr .aboo
 moveq #2,d0               ;* menu 2
 moveq #0,d1               ;iline
 bsr .ab31
 moveq #1,d1               ;dline
 bsr .ab31
 moveq #5,d1               ;irng
 bsr .ab31
 moveq #6,d1               ;drng
 bsr .ab31
 moveq #8,d1               ;srng
 btst #2,d6
 bsr .aboo
 moveq #9,d1               ;ifil
 bsr .ab31
 moveq #11,d1              ;rewrap
 bsr .ab31
 moveq #12,d1              ;llen
 bsr .ab31
 moveq #13,d1              ;spel
 bsr .ab31
 moveq #16,d1              ;new
 bsr .ab31
 moveq #3,d0               ;* menu 3
 moveq #0,d1               ;font
 btst #12,d6
 bsr .aboo
 moveq #1,d1               ;pturn
 btst #4,d6
 bsr .aboo
 moveq #2,d1               ;bturn
 btst #5,d6
 bsr .aboo
 moveq #3,d1               ;pg/bl shape
 btst #4,d6
 bsr .aboo
 moveq #4,d1               ;lspc
 btst #6,d6
 bsr .aboo
 moveq #5,d1               ;cspc
 btst #7,d6
 bsr .aboo
 moveq #6,d1               ;fjst limit
 btst #8,d6
 bsr .aboo
 moveq #7,d1               ;pens
 btst #9,d6
 bsr .aboo
 moveq #8,d1               ;graphics
 btst #11,d6
 bsr .aboo
 moveq #4,d0               ;* menu 4
 moveq #0,d1
 moveq #0,d2               ;bold
 btst #0,d7
 bsr .abor
 moveq #1,d2               ;ital
 btst #1,d7
 bsr .abor
 moveq #2,d2               ;wide
 btst #3,d7
 bsr .abor
 moveq #3,d2               ;shad
 btst #5,d7
 bsr .abor
 moveq #4,d2               ;super
 btst #11,d7
 bsr .abor
 moveq #5,d2               ;sub
 btst #11,d7
 bsr .abor
 moveq #1,d1
 moveq #0,d2               ;und0
 btst #2,d7
 bsr .abor
 moveq #1,d2               ;und1
 btst #2,d7
 bsr .abor
 moveq #2,d2               ;und2
 btst #2,d7
 bsr .abor
 moveq #3,d2               ;und3
 btst #2,d7
 bsr .abor
 moveq #4,d2               ;und4
 btst #2,d7
 bsr .abor
 moveq #5,d2               ;dot und
 btst #4,d7
 bsr .abor
 moveq #6,d2               ;strike thru
 btst #2,d7
 bsr .abor
 moveq #2,d1
 moveq #0,d2               ;rjst
 btst #6,d7
 bsr .abor
 moveq #1,d2               ;fjst
 btst #7,d7
 bsr .abor
 moveq #2,d2               ;cent
 btst #8,d7
 bsr .abor
 moveq #3,d2               ;ljst
 btst #9,d7
 bsr .abor
 moveq #3,d1               ;comp
 moveq #-1,d2
 btst #10,d7
 bsr .abor
 moveq #4,d1               ;erase
 bsr .ab31
 moveq #5,d1               ;undo
 bsr .ab31
 moveq #6,d1               ;restore
 bsr .ab31
 moveq #7,d1               ;spc fill
 bsr .ab31
 rts
.abor:                     ;** off if NE, else call .ab31
 bne.s .abof
.ab31:                     ;** off if locked else call .aboo
 tst.w d5
 bne.s .abof
.aboo:                     ;** item d0,d1,d2 on if EQ, off if NE
 bne.s .abof
 bsr TLOnmenu
 rts
.abof:
 bsr TLOffmenu
 rts

; Multiline subroutine - update window's vertical slider

.vert:
 tst.w .slir(a6)          ;go if no scrollers
 beq.s .vrtq
 movem.l a0/d0-d1,-(a7)   ;saves all
 move.l xxp_scrl(a5),a0
 move.l .topl(a6),xxp_vttp(a0)   ;top = topline
 move.l .lins(a6),xxp_vttt(a0)   ;total = lines in mem
 moveq #0,d0
 move.w .slns(a6),d0      ;visible = least of slns,totl
 cmp.l .lins(a6),d0
 bcs.s .vrtc
 move.l .lins(a6),d0
.vrtc:
 move.l d0,xxp_vtvs(a0)
 moveq #0,d0
 moveq #-1,d1              ;update vert scroll
 tst.w .lock(a6)
 beq.s .vrtu
 moveq #0,d1               ;also update horz if locked
.vrtu:
 bsr TLWscroll
 movem.l (a7)+,a0/d0-d1
.vrtq:
 rts

; Multiline subroutine - called from re-wrap
;   remove trailing spaces from output lines before appending eol

.rwtl:
 cmp.l a3,a1               ;go if at start of line
 beq.s .rwtq
 cmp.b #32,-(a1)           ;last chr = spc?
 beq .rwtl                 ;yes, remove it
 addq.l #1,a1              ;no, keep it
.rwtq:
 rts

; Multiline subroutine - interact ready to print a page  (lines d4-d5)
;   on call, .pqal,.pqzz,.pqpg,.pqcl,.pqmg already set

.pqdo:
 move.l .mmem(a6),a0       ;initialise .pqla
 move.l .pqal(a6),d0
 bra.s .pqzf
.pqzp:
 tst.b (a0)+
 bne .pqzp
.pqzf:
 subq.l #1,d0
 bpl .pqzp
 move.l a0,.pqla(a6)

.pqnx:                     ;* do next page
 move.l .pqla(a6),a0
 move.l .pqal(a6),d0

.pqlm:
 cmp.l .pqzz(a6),d0        ;go if all lines printed
 bcc .pqqt

.pqbl:                     ;skip blank lines at start of page
 addq.l #1,d0
 tst.b (a0)+
 beq .pqlm
 subq.l #1,d0
 subq.l #1,a0
 move.l d0,.pqal(a6)
 move.l a0,.pqla(a6)

 moveq #0,d0               ;set .pqzl
 move.b .pqpg(a6),d0
 add.l .pqal(a6),d0
 subq.l #1,d0
 cmp.l .pqzz(a6),d0
 ble.s .pqep
 move.l .pqzz(a6),d0
.pqep:
 move.l d0,.pqzl(a6)

 move.l xxp_Height(a4),d2  ;select largest possible d2 to fit TLReqshow
 lsr.w #3,d2
.pqrf:
 lea .hook,a0
 move.l #279,d0
 move.l .pqzl(a6),d1
 sub.l .pqal(a6),d1
 add.w #12+1,d1
 cmp.w d2,d1
 bcc.s .pqcy
 move.w d2,d1
.pqcy:
 moveq #0,d3
 clr.w xxp_ReqNull(a4)
 bsr TLReqshow
 bne.s .pqry
 subq.w #1,d2              ;if d2=19 doesn't fit, dec d2 until it does
 bra .pqrf
.pqry:

 move.w #300,xxp_Help(a4)
 move.w #11,xxp_Help+2(a4)
 clr.l .pqkk(a6)           ;nothing clicked yet
 clr.b .pqts(a6)           ;print/skip/abandon not clicked
 move.l #279,d0            ;call TLReqshow
 bsr TLReqshow
 bne.s .pqpt               ;go print if Quit button
 tst.l xxp_errn(a4)
 bne .pqbd                 ;go if error

.pqpt:                     ;here if print/quit
 move.l .pqkk(a6),d0
 beq.s .pqbr               ;go if no line highlighted
 subq.w #1,d0
 add.l .pqal(a6),d0        ;else set pqzl to line before it
 move.l d0,.pqzl(a6)

.pqbr:
 cmpi.b #2,.pqts(a6)       ;print/skip/abandon clicked?
 beq .pqsk                 ;go if skip
 bpl .pqcc                 ;go if abandon

 move.l #'PRT:',(a4)       ;open PRT:
 clr.b 4(a4)
 jsr TLOpenwrite
 bne.s .pqpo
 move.w #40,xxp_errn+2(a4) ;go if bad (error 40)
 bra .pqbd

.pqpo:
 move.l .pqla(a6),a3       ;* print lines pqal to pqzl
 move.l .pqzl(a6),d7       ;a3 = address reached
 sub.l .pqal(a6),d7        ;d7 counts lines

.pqln:                     ;print next line
 move.l a4,a0
 move.b .pqmg(a6),d0
 bra.s .pqmm
.pqnm:
 move.b #$20,(a0)+         ;send spaces for margin
.pqmm:
 subq.b #1,d0
 bpl .pqnm
.pqtf:
 move.b (a3)+,(a0)+        ;send chrs in line
 bne .pqtf
 subq.l #1,a0
 moveq #0,d0               ;point a1 to max line len
 move.b .pqcl(a6),d0
 move.l a4,a1
 add.l d0,a1
 cmp.l a0,a1               ;make sure not past a1
 bcc.s .pqsn
 move.l a1,a0
.pqsn:
 move.b #$0A,(a0)+         ;append LF
 move.l a4,d2
 move.l a0,d3
 sub.l d2,d3
 jsr TLWritefile           ;send to PRT:
 beq.s .pqcf               ;go if can't
 dbra d7,.pqln             ;until all lines done

 move.b #$0C,(a4)          ;send form feed at end of page
 move.l a4,d2
 moveq #1,d3
 jsr TLWritefile
 beq.s .pqcf

 jsr TLClosefile           ;close PRT:
 bra.s .pqsk               ;go to next page

.pqcf:                     ;here if can't send to PRT: (error 41)
 move.w #41,xxp_errn+2(a4)
 bra.s .pqbd

.pqsk:                     ;* skip to line after end of page
 move.l .pqal(a6),d0
 move.l .pqla(a6),a0
.pqss:
 tst.b (a0)+
 bne .pqss
 addq.l #1,d0
.pqsf:
 cmp.l .pqzl(a6),d0
 ble .pqss
 move.l d0,.pqal(a6)       ;update pqal,pqla
 move.l a0,.pqla(a6)
 bra .pqnx                 ;& to next page

.pqbd:                     ;exit - error (TLReqshow failed)
 jsr TLError               ;report error to monitor
 move.l #287,d0
 bra.s .pqrp

.pqcc:                     ;exit - abandon
 move.l #288,d0
 bra.s .pqrp

.pqqt:                     ;exit - all done
 move.l #289,d0

.pqrp:                     ;report & quit
 clr.l xxp_Help(a4)
 moveq #1,d1
 moveq #0,d2
 bsr TLReqinfo             ;report
 jsr TLError               ;(report to monitor if TLReqinfo failed)
 rts

; TLMultiline "subroutine" - hook for .pqdo (printing) TLReqshow

.hook:
 move.l xxp_Stak(a4),a0    ;retrieve A6 when TLReqshow called from xxp_Stak
 move.l 56(a0),a6

 move.l d0,d1              ;go if click
 bmi .hkck

 cmp.w #12,d1              ;go if line 12+ (i.e. printable lines 0+)
 bcc.s .hkln

 move.l #286,d0            ;show line 0-11 (headers)
 sub.w #2,d1
 bmi.s .hkhd               ;(lines 0-1 blank)
 cmp.w #3,d1
 bmi.s .hkh0               ;(lines 2-4 = print/skip/abandon = str 279=81)
 sub.w #5,d1
 bmi.s .hkhd               ;(lines 5-6 blank)
 cmp.w #3,d1
 bcc.s .hkhd               ;(lines 10-11 blank)
 addq.w #3,d1              ;(lines 7-9 instructions = str 282-4)
.hkh0:
 add.w #280,d1
 move.w d1,d0
.hkhd:
 jsr TLStra0               ;point to string to be shown
 rts

.hkln:                     ;here if printable line clicked
 move.l .pqla(a6),a0
 sub.w #12,d1              ;d1 = linum rel to first line
 move.l .pqzl(a6),d0
 sub.l .pqal(a6),d0
 cmp.w d1,d0
 bcs.s .hkzz
 bra.s .hklq
.hklf:
 tst.b (a0)+               ;point a0 to line to be shown
 bne .hklf
.hklq:
 dbra d1,.hklf
 rts

.hkzz:                     ;here if past pqzl
 move.l a4,a0
 clr.b (a0)
 rts

.hkck:                     ;here if a line clicked
 bclr #31,d0               ;get linum
 cmp.w #12,d0
 bcc.s .hkkl               ;go if 12+ ( = prinatble line 0+)
 subq.w #1,d0
 ble.s .hkkz
 cmp.w #4,d0               ;do nothing if 0-1 or 5-11
 bcc.s .hkkz
 move.b d0,.pqts(a6)       ;set .pqts = 1-3 & force quit if 2-4
 moveq #0,d0
 rts

.hkkl:                     ;d0 = linum clicked (rel to .pqal)
 sub.w #12,d0
 cmp.l .pqkk(a6),d0
 bne.s .hkky               ;go if different
 clr.l .pqkk(a6)
 moveq #1,d0               ;if already highlighted, turn off
 rts

.hkky:
 move.l .pqzl(a6),d1
 sub.l .pqal(a6),d1
 cmp.l d0,d1
 bcs.s .hkkz
 move.l d0,.pqkk(a6)       ;note highlighted line
 moveq #2,d0
 rts

.hkkz:                     ;do nothing
 moveq #-1,d0
 rts

; TLMultiline subroutine - over-ride printer prefs

.pprf:
 move.l #311,d0            ;select prefs item
 moveq #5,d1
 bsr TLReqchoose
 cmp.w #1,d0
 bcs .ppqt
 beq .pppg
 cmp.w #3,d0
 bcs .pppl
 beq .pppm
 cmp.w #5,d0
 bcs .pppf
 bra .ppqt

.pppg:                     ;lines/page
 moveq #0,d0
 move.b .pqpg(a6),d0
 move.l a4,a0
 jsr TLHexasc
 clr.b (a0)
 move.l #318,d0
 moveq #-1,d1
 moveq #3,d2
 moveq #0,d3
 bsr TLReqinput
 beq .pprf
 move.l xxp_valu(a4),d0
 tst.b d0
 beq .pppg
 move.b d0,.pqpg(a6)
 bra .pprf

.pppl:                     ;chrs/line
 moveq #0,d0
 move.b .pqcl(a6),d0
 move.l a4,a0
 jsr TLHexasc
 clr.b (a0)
 move.l #319,d0
 moveq #-1,d1
 moveq #3,d2
 moveq #0,d3
 bsr TLReqinput
 beq .pprf
 move.l xxp_valu(a4),d0
 cmp.w #25,d0
 bcs .pppl
 cmp.w #161,d0
 bcc .pppl
 move.b d0,.pqcl(a6)
 bra .pprf

.pppm:                     ;margins
 moveq #0,d0
 move.b .pqmg(a6),d0
 move.l a4,a0
 jsr TLHexasc
 clr.b (a0)
 move.l #320,d0
 moveq #-1,d1
 moveq #1,d2
 moveq #0,d3
 bsr TLReqinput
 beq .pprf
 move.l xxp_valu(a4),d0
 move.b d0,.pqmg(a6)
 bra .pprf

.pppf:                     ;Workbench prefs
 move.b xxp_lppg(a4),.pqpg(a6) ;get intuition printer prefs
 move.b xxp_cpln(a4),.pqcl(a6)
 move.b xxp_marg(a4),.pqmg(a6)
 bra .pprf

.ppqt:
 rts

******************* TLMultiline Data ****************

.str: dc.b 0
 dc.b 'Project',0 ;1
 dc.b 'Load',0 ;2
 dc.b 'Save',0 ;3
 dc.b 'Save as',0 ;4
 dc.b 'Print',0 ;5
 dc.b 'About',0 ;6
 dc.b 'Stop Editing',0 ;7
 dc.b 'Go to',0 ;8
 dc.b 'First line',0 ;9
 dc.b 'Last line',0 ;10
 dc.b 'Seek forward',0 ;11
 dc.b 'Seek back',0 ;12
 dc.b 'Seek at line start',0 ;13
 dc.b 'Fwd a window-full',0 ;14
 dc.b 'Back a window-full',0 ;15
 dc.b 'Info about text',0 ;16
 dc.b 'Cut & Paste',0 ;17
 dc.b 'Insert line',0 ;18
 dc.b 'Delete line',0 ;19
 dc.b 'Mark start of Range',0 ;20
 dc.b 'Mark end of Range',0 ;21
 dc.b 'Insert Range',0 ;22
 dc.b 'Delete Range',0 ;23
 dc.b 'Save Range',0 ;24
 dc.b 'Insert file',0 ;25
 dc.b 'Rewrap',0 ;26
 dc.b 'Spell check Range',0 ;27
 dc.b 'Erase all (careful!)',0 ;28
 dc.b 0 ;29
 dc.b 'LSC!?QAZFBGWVIDMNRP',0 ;30
 dc.b 'Caution:          bad characters have been removed.',0 ;31
 dc.b 'Caution:          lines truncated, as >254 chrs (<Help> for info).',0
 dc.b 'Done OK:          lines split',0 ;33
 dc.b 'Specify filename...',0 ;34
 dc.b 'Error: out of memory - can''t keep changes to the line you edited',0
 dc.b 'Error: start of range is not marked',0 ;36
 dc.b 'Error: end of range is not marked',0 ;37
 dc.b 'Error: start of range must be before end of range',0 ;38
 dc.b 'Error: cannot insert range within its own compass',0 ;39
 dc.b 'Delete range?',0 ;40
 dc.b 'Yes (Careful!)',0 ;41
 dc.b 'No',0 ;42
 dc.b 'Erase ALL lines?',0 ;43
 dc.b 'Yes (Careful)',0 ;44
 dc.b 'No',0 ;45
 dc.b 'Error: cannot insert range - out of memory',0 ;46
 dc.b 'Instructions for using this text editor...',0 ;47
 dc.b '** n.b. some of the options below may be currently disabled **',0
 dc.b 'Menu: The "Project" menu should be self explanatory.',0
 dc.b 'The "Go To" menu allows you to navigate thru the text. Most menu',0
 dc.b 'items cause a requester to appear, when you can press the <Help>',0
 dc.b 'button for further particulars. Note also menu keyboard bypasses',0
 dc.b ' ',0 ;53
 dc.b '          Ctrl                   Shift/Ctrl        Marking a Range',0
 dc.b ' ',0 ;55
 dc.b 'a To 1st line   o "Outline"      A Start range     You must mark a',0
 dc.b 'b Bold          r Right justfy   C Comp (pg turn)  range by',0
 dc.b 'c Centre        s Shadow         D Delete range    Shift/Ctrl/A +',0
 dc.b 'd Delete line   u Underline      I Insert range    Shift/Ctrl/Z',0
 dc.b 'f Full justify  w Wide text      R Restore         before you',0 ;60
 dc.b 'i Italic        x X-out          S Space fill      Insert, Delete',0
 dc.b 'l Left justify  z To last line   U Undo            Save Range.',0
 dc.b '                                 Z End range',0 ;63
 dc.b 'Ctrl/Up arrow  Superscript',0 ;64
 dc.b 'Ctrl/Dn arrow  Subscript',0 ;65
 dc.b ' ',0 ;66
 dc.b 'The "Multiline" Text Editor you are using....',0 ;67
 dc.b ' ',0 ;68
 dc.b 'Is part of the user interface in tandem.library, written by:',0 ;69
 dc.b ' ',0 ;70
 dc.b 'Ken Shillito   Email       shillito@tpg.com.au',0 ;71
 dc.b '               Home Page   http://fast.to/shillito',0 ;72
 dc.b ' ',0 ;73
 dc.b 'The Tandem package consists of:',0 ;74
 dc.b '1. An integrated editor-assembler-debugger called "Tandem"',0 ;75
 dc.b '2. A progressive hands-on tutor with Tandem to learn assembler',0 ;76
 dc.b '3. tandem.library  which contains the user interface.',0 ;77
 dc.b ' ',0 ;78
 dc.b 'This is version 2.62 of tandem.library, released March 24th 200.',0
 dc.b 'No load/save took place: Cancel selected',0 ;80
 dc.b 'Error: can''t put up ASL requester - out of chip mem',0 ;81
 dc.b 'Error: can''t open file',0 ;82
 dc.b 'Error: can''t write to file',0 ;83
 dc.b 'Error: can''t read file',0 ;84
 dc.b 'Caution: file truncated due to lack of memory in edit buffer',0 ;85
 dc.b 'Nothing to save: memory buffer is empty',0 ;86
 dc.b 'Error: file read was empty',0 ;87
.st88: dc.b 'Longest line     characters - more than currently allowed',0
 dc.b 'Change longest allowed to above value',0 ;89
 dc.b 'Divide all too-long lines',0 ;90
 dc.b 0 ;91
 dc.b 'Seeking for a string...',0 ;92
 dc.b 'This text editor does 3 types of string search:',0 ;93
 dc.b ' ',0 ;94
 dc.b '1. Seek forward - seeks the first occurence in all lines after the',0
 dc.b '   current line.',0 ;96
 dc.b '2. Seek back - seeks the first occurence in all lines before the',0
 dc.b '   current line.',0 ;98
 dc.b '3. Seek left - start from the first line, seeks the first',0 ;99
 dc.b '   occurence of the string, at the beginning of each line.',0 ;100
 dc.b ' ',0 ;101
 dc.b 'If you input a null string your most recent non-null input will',0
 dc.b 'be sought.',0 ;103
 dc.b ' ',0 ;104
 dc.b 'By default, the search is case significant. But if you prepend a',0
 dc.b '| character to your input, the search will be case blind (slower).',0
 dc.b 'Information about lines in memory               ',0 ;107
 dc.b '           = Lines in memory      ',0 ;108
 dc.b '           = Max chrs in a line   ',0 ;109
 dc.b '           = Words in memory      ',0 ;110
 dc.b '           = Paras (see <help>)   ',0 ;111
 dc.b '           = Current line num     ',0 ;112
 dc.b '           = Memory total used    ',0 ;113
 dc.b '           = Memory bytes unused  ',0 ;114
 dc.b 'Paragraphs....',0 ;115
 dc.b ' ',0 ;116
 dc.b 'This text editor assumes a paragraph starts with any printable',0
 dc.b 'non-blank line that does not start with a space. The paragraph',0
 dc.b 'continues until a line is found that:',0 ;119
 dc.b ' ',0 ;120
 dc.b '  - is blank.',0 ;121
 dc.b '  - has a different justification from the one before.',0 ;122
 dc.b '  - has a different font / font size from the one before.',0 ;123
 dc.b '  - changes between fixed / proportional from the one before.',0 ;124
 dc.b '  - starts with a space.',0 ;125
 dc.b '  - is non-printable.',0 ;126
 dc.b ' ',0 ;127
 dc.b 'Rewrapping, when requested, is done a paragraph at a time.',0 ;128
 dc.b 'Rewrap incomplete: out of memory',0 ;129
 dc.b 'Go to line number',0 ;130
 dc.b 'Line number to go to 1 to',0 ;131
 dc.b 'Change max line length',0 ;132
 dc.b 'Error: bad read - memory (probably) left as it was before.',0 ;133
 dc.b 'Caution: file was empty - memory left as it was before.',0 ;134
 dc.b 'Input a string for seeking (press <Help> for details)',0 ;135
.s136: dc.b 'amigaguide.library',0 ;136
.s137: dc.b 'Multiline.guide',0 ;137
 dc.b 'Error: can''t open Multiline.guide',0 ;138
 dc.b 'Error: can''t open amigaguide.library',0 ;139
 dc.b 'Error: can''t lock CD to open Mutliline.guide',0 ;140
 dc.b 'View AmigaGuide',0 ;141
 dc.b 'Maximum line length (10 to 254) (see <Help> for info!!) (currently',0
 dc.b 'Changing the maximum line length...',0 ;143
 dc.b 'If you INcrease the maximum line length, all text lines will',0 ;144
 dc.b 'be unchanged. You will often then choose to do a re-wrap to',0 ;145
 dc.b 'spread existing lines across the broader range.',0 ;146
 dc.b ' ',0 ;147
 dc.b 'If you DEcrease the maximum line length, all the text lines',0 ;148
 dc.b 'will be re-wrapped. This can cause problems with tables, &c',0 ;149
 dc.b 'whose lines are too long to fit in the new line length. The',0 ;150
 dc.b 're-wrapper is fairly intelligent at guessing which lines are',0 ;151
 dc.b 'formatted, and leaving them alone if possible.',0 ;152
 dc.b ' ',0 ;153
 dc.b 'It''s not a bad idea to save the text before you decrease the',0 ;154
 dc.b 'maximum line length, in case you don''t like the result.',0 ;155
 dc.b 'You are decreasing the maximum line length (<Help> for info).',0 ;156
 dc.b 'OK - continue',0 ;157
 dc.b 'Cancel',0 ;158
 dc.b 'Instructions for using this text editor...',0 ;159
 dc.b '(It is currently a viewer only - you can look at, but not edit,',0
 dc.b 'the text).',0 ;161
 dc.b 'Menu: The "Project" menu should be self explanatory.',0 ;162
 dc.b 'The "Go To" menu allows you to navigate thru the text. Most menu',0
 dc.b 'items cause a requester to appear, when you can press the <Help>',0
 dc.b 'button for further particulars. Note also menu keyboard bypasses',0
 dc.b ' ',0 ;166
 dc.b 'Ctrl a  To first line',0 ;167
 dc.b 'Ctrl z  To last line',0 ;168
 dc.b 'Up arrow, down arrow to scroll',0 ;169
 dc.b 'Shift up arrow, Shift down arrow to go up/down a window-full.',0 ;170
 dc.b 'Select Unlock in the Project Menu to re-allow you to edit text.',0
 dc.b 'Lock/Unlock Text',0 ;172
 dc.b 'Text is now locked (see <Help> for info).',0 ;173
 dc.b 'Text is now unlocked.',0 ;174
 dc.b 'Page Formatting',0 ;175
 dc.b 'Font Select',0 ;176
 dc.b 'Page Turn',0 ;177
 dc.b 'Block Turn',0 ;178
 dc.b 'Page/Block Shape',0 ;179
 dc.b 'Line Spacing',0 ;180
 dc.b 'Character spacing',0 ;181
 dc.b 'Full justify limit',0 ;182
 dc.b 'Text Pens',0 ;183
 dc.b 0 ;184
 dc.b 'Graphics',0 ;185
 dc.b 0 ;186
 dc.b 0 ;187
 dc.b 0 ;188
 dc.b 0 ;189
 dc.b 'Line formatting, editing',0 ;190
 dc.b 'Font Style',0 ;191
 dc.b 'Bold        Ctrl/b',0 ;192
 dc.b 'Italic      Ctrl/i',0 ;193
 dc.b 'Wide        Ctrl/w',0 ;194
 dc.b 'Shadow      Ctrl/s',0 ;195
 dc.b 'Superscript Ctrl/up',0 ;196
 dc.b 'Subscript   Ctrl/down',0 ;197
 dc.b 'Under/Overlining',0 ;198
 dc.b 'Single Under   Ctrl/u',0 ;199
 dc.b 'Over           Ctrl/e',0 ;200
 dc.b 'Under+Over     Ctrl/f',0 ;201
 dc.b 'Double Under   Ctrl/g',0 ;202
 dc.b 'Dbl Under+Over Ctrl/h',0 ;203
 dc.b 'Dotted Under   Ctrl/o',0 ;204
 dc.b 'Justification',0 ;205
 dc.b 'Right Justify Ctrl/r',0 ;206
 dc.b 'Full Justify  Ctrl/j',0 ;207
 dc.b 'Center        Ctrl/c',0 ;208
 dc.b 'Left Justify  Ctrl/l',0 ;209
 dc.b 'Complement',0 ;210
 dc.b 'Erase (x-out)  Ctrl/x',0 ;211
 dc.b 'Undo           Shift/Ctrl/u',0 ;212
 dc.b 'Restore        Shift/Ctrl/r',0 ;213
 dc.b 'Space fill     Shift/Ctrl/s',0 ;214
 dc.b 'GUI Preferences',0 ;215
.s216: dc.b 'Loaded ok - longest line loaded ..., longest allowed ...',0
 dc.b 'Leave longest allowed as is',0 ;217
 dc.b 'Change longest allowed to longest loaded (minimum 20)',0 ;218
 dc.b 'Change longest allowed to 76',0 ;219
 dc.b 'You have selected "Erase all"...',0 ;220
 dc.b 'If Erase all takes place, everything in memory will be lost.',0 ;221
 dc.b 'If you have saved it to disk, that''s ok. Or, if your are',0 ;222
 dc.b 'sure you don''t want it, that''s also ok. But otherwise, then',0 ;223
 dc.b 'after you press OK for this Help requester, select "No" to',0 ;224
 dc.b 'keep all your lines in memory.',0 ;225
 dc.b 'You have chosen "Delete Range"...',0 ;226
 dc.b 'If you now choose "Yes", you will lose irretrievably all the lines',0
 dc.b 'within the range. If you have already copied them to somewhere',0
 dc.b 'else, or you''re sure you don''t want them, that''s ok. But if',0
 dc.b 'you''re unsure, choose "No" to keep them.',0 ;230
 dc.b 'An error has arisen with respect to operating on a "Range"...',0 ;231
 dc.b '1. Before you can operate on a Range, you must select the start',0
 dc.b '   of the range. To do so, place the cursor on a line, and select',0
 dc.b '   the menu item "Mark start of range".',0 ;234
 dc.b '2. Then, you must mark the end of the range. Place the cursor on',0
 dc.b '   any line, from the line you marked as the start onwards, and',0
 dc.b '   select "Mark end of range".',0 ;237
 dc.b ' ',0 ;238
 dc.b 'Your range is then marked. It will remain so, unless you do',0 ;239
 dc.b 'something (other than "Insert Range") to change the number of',0 ;240
 dc.b 'lines in memory.',0 ;241
 dc.b ' ',0 ;242
 dc.b 'Note that if you choose "Insert range", the cursor cannot be on',0
 dc.b 'any line within the marked range. Also, if you choose "Insert',0 ;244
 dc.b 'range", there may not be enough memory to do the insertion.',0 ;245
 dc.b 'The rewrap could not be completed - out of memory...',0 ;246
 dc.b 'When rewrapping takes place, there is a very slight chance that',0
 dc.b 'Multiline will run out of memory. Memory must have been almost',0
 dc.b 'full when you began the rewrap. So you will find that some lines',0
 dc.b 'have been rewrapped, and the later ones not. Sorry about that.',0
 dc.b 'Multiline has run out of memory....',0 ;251
 dc.b 'You should save your text before you do anything else. You may',0
 dc.b 'need to divide it up into segments, or otherwise shorten it, as',0
 dc.b 'won''t fit into the amount of memory that Multiline is using in',0
 dc.b 'the present application.',0 ;255
 dc.b 'Strike through',0 ;256
 dc.b 'Force Fixed',0 ;257
 dc.b 'Rewrap...',0 ;258
 dc.b 'From current line to next blank line',0 ;259
 dc.b 'Everything in memory (careful!)',0 ;260
 dc.b 'The marked range (if any)',0 ;261
 dc.b 'Cancel',0 ;262
 dc.b 'You have selected "Rewrap"....',0 ;263
 dc.b 'Multiline will scan through the range of lines you select, and if',0
 dc.b 'any line can have words from the next line tacked onto it, they',0
 dc.b 'will be so tacked on. That way, paragraphs will be tidied up.',0 ;266
 dc.b ' ',0 ;267
 dc.b 'Lines only get rewrapped within their own paragraphs. Paragraphs',0
 dc.b 'end when a blank line, or a line that starts with a space, occurs.',0
 dc.b 'If the font/text style &c of successive lines differs, re-wrapping',0
 dc.b 'never takes place across them.',0 ;271
 dc.b 'Print...',0 ;272
 dc.b 'The currently marked range',0 ;273
 dc.b 'Everything in memory from current line to end',0 ;274
 dc.b 'Everything in memory from start to end',0 ;275
 dc.b 'Adjust printer prefs',0 ;276
 dc.b 'Cancel',0 ;277
 dc.b 'Printing done - no more lines to print',0 ;278
 dc.b 'The next page is ready to print...  (press <Help> for info)',0 ;279
 dc.b '***  Click THIS line (or the Quit button) to PRINT the page    ***',0
 dc.b '***  Click THIS line to SKIP the page                          ***',0
 dc.b '***  Click THIS line to ABANDON printing                       ***',0
 dc.b '*** The lines below are to be printed. Click any of them except **',0
 dc.b '*** the first, to force that line & lines after it onto the    ***',0
 dc.b '*** page after next. (If you change your mind, click it again) ***',0
 dc.b 0 ;286 (must be null)
 dc.b 'Can''t print - out of mem',0 ;287
 dc.b 'Printing abandoned',0 ;288
 dc.b 'Printing finished - no more pages to print',0 ;289
 dc.b 'You have chosen to print some or all of the lines in memory.',0 ;290
 dc.b 'When Multiline starts up, it has the printer preferences you',0 ;291
 dc.b 'have installed in the Amiga Workbench Printer prefs, for the',0 ;292
 dc.b 'lines per page, left margin width, and characters printed.',0 ;293
 dc.b ' ',0 ;294
 dc.b 'If your preferences characters per line is 80, and margins are 5,',0
 dc.b 'then if you have set Multiline to 76 characters per line, lines',0
 dc.b 'will get chopped off, since 80 chrs per line minus 5 for the',0 ;297
 dc.b 'margin equals only 75. So in that case set 0 to 4 for margin.',0
 dc.b 'The values you set do not change your workbench prefs permanently.',0
 dc.b 'Multiline is ready to print a page...',0 ;300
 dc.b 'The requester currently showing lists all the lines which will be',0
 dc.b 'printed as this page. If you want to cut the page short (e.g. to',0
 dc.b 'put a page turn at a main heading) then click the line where the',0
 dc.b 'page turn is to be (of course, not the first line). If you change',0
 dc.b 'your mind, you can re-click that line to cancel, or click another',0
 dc.b 'line.',0 ;306
 dc.b ' ',0 ;307
 dc.b 'By clicking the lines near the top of the page, you can also chose',0
 dc.b 'from: print the page, skip the page, or abandon printing. If you',0
 dc.b 'click the "Quit" button, you will thereby choose print the page.',0
 dc.b 'Printer prefs...',0 ;311
 dc.b 'Lines per page',0 ;312
 dc.b 'Chrs per line',0 ;313
 dc.b 'Left margin',0 ;314
 dc.b 'Re-install Workbench printer preferences',0 ;315
 dc.b 'All now OK',0 ;316
 dc.b 0 ;317
 dc.b 'Lines per page (usually 62)',0 ;318
 dc.b 'Characters per line  25-160  (usually 80)',0 ;319
 dc.b 'Margin width  0-9  (usually 0)',0 ;320

 ds.w 0

.ment:
 TLnm 1,1      ;Project                    * n.b. This is still re-entrant
 TLnm 2,2,30   ;  Load                L    * because although TLReqmenu
 TLnm 2,3,30   ;  Save                S    * changes it, when TLReqmenu
 TLnm 2,-1     ;                           * re-runs through it, it leaves
 TLnm 2,4,30   ;  Save as             C    * it alone in its altered form.
 TLnm 2,-1
 TLnm 2,5      ;  Print
 TLnm 2,-1
 TLnm 2,6,30   ;  About               !
 TLnm 2,215    ;  GUI Prefernces
 TLnm 2,141,30 ;  AmigaGuide          ?
 TLnm 2,172    ;  Lock/Unlock text
 TLnm 2,-1
 TLnm 2,7,30   ;  Stop editing        Q
 TLnm 1,8      ;Go To
 TLnm 2,9,30   ;  First line          A
 TLnm 2,10,30  ;  Last line           Z
 TLnm 2,11,30  ;  Seek forward        F
 TLnm 2,12,30  ;  Seek back           B
 TLnm 2,13,30  ;  Seek at line start  G
 TLnm 2,14,30  ;  Fwd a window-full   W
 TLnm 2,15,30  ;  Back a window-full  V
 TLnm 2,130    ;  Go to line number
 TLnm 2,16     ;  Info about text
 TLnm 1,17     ;Cut & Paste
 TLnm 2,18,30  ;  Insert line         I
 TLnm 2,19,30  ;  Delete line         D
 TLnm 2,-1
 TLnm 2,20,30  ;  Mark start          M
 TLnm 2,21,30  ;  Mark end            N
 TLnm 2,22     ;  Insert rng
 TLnm 2,23     ;  Delete rng
 TLnm 2,-1
 TLnm 2,24     ;  Save range
 TLnm 2,25     ;  Insert file
 TLnm 2,-1
 TLnm 2,26,30  ;  Rewrap              R
 TLnm 2,132    ;  Change line length
 TLnm 2,27     ;  Spell check range   S
 TLnm 2,-1
 TLnm 2,-1
 TLnm 2,28     ;  Erase all (careful!)
 TLnm 1,175    ;Page Formatting
 TLnm 2,176    ;  Font Select
 TLnm 2,177,30 ;  Page Turn           P
 TLnm 2,178    ;  Block Turn
 TLnm 2,179    ;  Page/Block Shape
 TLnm 2,180    ;  Line Spacing
 TLnm 2,181    ;  Character spacing
 TLnm 2,182    ;  Full justify limit
 TLnm 2,183    ;  Text Pens
 TLnm 2,185    ;  Graphics
 TLnm 1,190    ;Line formatting, editing
 TLnm 2,191    ;  Font Style
 TLnm 3,192    ;    Bold        Ctrl/b
 TLnm 3,193    ;    Italic      Ctrl/i
 TLnm 3,194    ;    Wide        Ctrl/w
 TLnm 3,195    ;    Shadow      Ctrl/s
 TLnm 3,196    ;    Superscript Ctrl/up
 TLnm 3,197    ;    Subscript   Ctrl/down
 TLnm 2,198    ;  Under/Overlining
 TLnm 3,199    ;    Single Under   Ctrl/u
 TLnm 3,200    ;    Over           Ctrl/e
 TLnm 3,201    ;    Under+Over     Ctrl/f
 TLnm 3,202    ;    Double Under   Ctrl/g
 TLnm 3,203    ;    Dbl Under+Over Ctrl/h
 TLnm 3,204    ;    Dotted Under   Ctrl/o
 TLnm 3,256    ;    Strike Through
 TLnm 2,205    ;  Justification
 TLnm 3,206    ;    Right Justify Ctrl/r
 TLnm 3,207    ;    Full Justify  Ctrl/j
 TLnm 3,208    ;    Center        Ctrl/c
 TLnm 3,209    ;    Left Justify  Ctrl/l
 TLnm 3,257    ;    Force Fixed   Ctrl/p
 TLnm 2,210    ;  Complement
 TLnm 2,211    ;  Erase (x-out)  Ctrl/x
 TLnm 2,212    ;  Undo           Shift/Ctrl/u
 TLnm 2,213    ;  Restore        Shift/Ctrl/r
 TLnm 2,214    ;  Space fill     Shift/Ctrl/s
 TLnm 4,0      ;(End)


* this table is used by tandem.i to simulate tandem.library's jump table
* (when Tandem.i sets a pseudo tanbase at TLEndcode+24)

 IFEQ xxp_what-2           ;#^6  only assemble this table if in tandem.i

 jmp TLPict
 jmp TLTabmon
 jmp TLTabs
 jmp TLMget
 jmp TLPrefs
 jmp TLWscroll
 jmp TLReqfont
 jmp TLDropdown
 jmp TLHexasc16
 jmp TLGetarea
 jmp TLEllipse
 jmp TLData
 jmp TLProgress
 jmp TLResize
 jmp TLPutilbm
 jmp TLGetilbm
 jmp TLReqoff
 jmp TLReqon
 jmp TLReqchek
 jmp TLReqredi
 jmp TLSlimon
 jmp TLPassword
 jmp TLSlider
 jmp TLButtxt
 jmp TLButprt
 jmp TLButstr
 jmp TLPreffil
 jmp TLPrefdir
 jmp TLOffmenu
 jmp TLOnmenu
 jmp TLReqcolor
 jmp TLUnbusy
 jmp TLBusy
 jmp TLFloat
 jmp TLWcheck
 jmp TLWupdate
 jmp TLMultiline
 jmp TLWpop
 jmp TLWsub
 jmp TLTrim
 jmp TLWpoll
 jmp TLReqinfo
 jmp TLReqmuclr
 jmp TLReqmuset
 jmp TLReqmenu
 jmp TLAssdev
 jmp TLReqshow
 jmp TLReqedit
 jmp TLReqinput
 jmp TLReqchoose
 jmp TLReqfull
 jmp TLReqcls
 jmp TLReqarea
 jmp TLReqbev
 jmp TLWslof
 jmp TLAslfile
 jmp TLAslfont
 jmp TLButmon
 jmp TLNewfont
 jmp TLGetfont
 jmp TLWfront
 jmp TLTsize
 jmp TLText
 jmp TLWclose
 jmp TLWindow
 jmp TLKeyboard
 jmp TLProgdir
 jmp TLChip
 jmp TLPublic
 jmp TLInput
 jmp TLOutput
 jmp TLHexasc
 jmp TLAschex
 jmp TLClosefile
 jmp TLReadfile
 jmp TLWritefile
 jmp TLOpenwrite
 jmp TLOpenread
 jmp TLError
 jmp TLStra0
 jmp TLStrbuf
 jmp TLFsub

 ENDC              ;#^6

TLEndcode: ;mark end of program
