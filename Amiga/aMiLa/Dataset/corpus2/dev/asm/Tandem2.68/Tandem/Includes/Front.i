* Front.i             revision 2.62 3.24.00    *  (extract from Tandem.i)

 include 'IncAll.i'        ;get AmigaOS includes & FDs

************************* set what assembled ***************************

xxp_what: EQU  1  ;set:  0=tandem.library  1=front.i  2=tandem.i

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
