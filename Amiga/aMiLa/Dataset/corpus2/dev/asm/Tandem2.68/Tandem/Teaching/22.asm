* 22.asm     make program runnable from workbench      version 0.00  1.9.97

 include 'IncAll.i'    ;pre-assembles all Amiga OS3.1 includes, and _LVO's

 move.l _AbsExecBase,a6 ;find task structure for this program
 sub.l a1,a1           ;a1=0 means "find my own task structure"
 jsr _LVOFindTask(a6)  ;puts task address in d0
 move.l d0,a2          ;put in a2 so we can look at elements of task struct
 clr.w workbench       ;will be <>0 if started from workbench
 tst.l pr_CLI(a2)      ;<>0 if from CLI, else from workbench
 bne.s Cli             ;go if CLI
 subq.w #1,workbench   ;remember from workbench
 lea pr_MsgPort(a2),a0 ;wait for workbench startup message at pr_MsgPort
 jsr _LVOWaitPort(a6)  ;does not return until a message is there
 lea pr_MsgPort(a2),a0 ;now, get the workbench startup message at pr_MsgPort
 jsr _LVOGetMsg(a6)    ;puts message in d0 (= the addr of a message struct)
 move.l d0,message     ;remember the message, for replying
Cli:
 lea intname,a1        ;open intuition.library
 moveq #37,d0          ;version 37+ (i.e. release 2.04+)
 jsr _LVOOpenLibrary(a6) ;puts the library address in d0
 move.l d0,intbase     ;remember where the intuition library base is
 beq.s Abort           ;quit if can't open (unlikely!)
 move.l d0,a6          ;a6 = intuition library base
 sub.l a0,a0           ;a0=0 to make DisplyBeep beep all screens
 jsr _LVODisplayBeep(a6) ;beep all screens
 move.l _AbsExecBase,a6  ;a6 = exec library base
 tst.w workbench       ;go if CLI
 beq.s Cliback
 jsr _LVOForbid(a6)    ;stop multi-tasking until RTS  * This is the ONLY
 move.l message,a1     ;retrieve the startup message  * context you should
 jsr _LVOReplyMsg(a6)  ;reply to it                   * use _LVOForbid!!
Cliback:
 move.l intbase,a1     ;close intuition.library
 jsr _LVOCloseLibrary(a6)
 clr.l d0              ;return ok
 rts                   ;(exit from program cancels effect of _LVOForbid)
Abort:
 moveq #-1,d0          ;return bad if couldn't open library
 rts

workbench: ds.w 1 ;<>0 if from workbench, else from CLI
message: ds.l 1   ;workbench startup message (meaningless if from CLI)
intname: dc.b 'intuition.library',0  ;use to open the intuition library
intbase: ds.l 1                      ;the base of the intuition library
