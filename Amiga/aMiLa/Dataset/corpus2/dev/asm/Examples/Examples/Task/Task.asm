  XREF    _SysBase,_DOSBase,_stdout  ;from startup code

  XREF     _LVOWait                  ;from amiga.lib
  XREF     _LVOWaitTOF
  XREF     _LVOCloseLibrary,_LVOOpenLibrary
  XREF     _LVODelay,_LVOWrite
  XREF     _CreateTask,_DeleteTask

  XREF     sprintf   ;from functions.o

; Task.asm - a cheap sub-task example in by C Scheppner. Asm by JG.
; Cheap because there is shared data for communication (ie Counter) rather
; than using MsgPorts. This runs the risk of the subTask modifying Counter
; while the main task is printing out its value. We could use Forbid() and
; Permit() in main() to disable the subTask while we print Count, but then
; subTask could not be incrementing Count "during" main.
; Link with StartUp.o instead of SmallStart.o because we need _stdout.

LIB_VERSION equ 33

    SECTION  TaskCode,CODE

   XDEF   _main
_main:
    movea.l  _SysBase,a6
;----Open the graphics library
    moveq    #LIB_VERSION,d0
    lea      GfxName,a1
    jsr      _LVOOpenLibrary(a6)
    move.l   d0,_GfxBase
    bne.s    .5            ;branch if successful open
    lea      CantOpenGfx,a0
    bra.s    _cleanexit
;----create a subTask by calling CreateTask--------
;---CreateTask(subTaskName,0,subTaskRtn,2000)-----
.5  pea      2000          ;stack size, 2K is just enough for a minor task
    pea      subTaskCode   ;the code where execution starts
    clr.l    -(sp)         ;no special termination code, main will delete it
    pea      _subTaskName  ;name of the task
    jsr      _CreateTask   ;standard C function in amiga.lib (or Manx c lib)
    lea      16(sp),sp
    move.l   d0,_subTaskPtr
    bne.s    .6            ;branch if successfully created
    lea      CantCreateTask,a0
    bra.s    _cleanexit
;---for 0 to 9 (ie loop 10 times)---------
.6  moveq    #10-1,d6      ;subtract 1 for the Dbra instruction
    movea.l  _DOSBase,a6   ;wait while the subTask increments
   ;----Delay(50) (main is a process and can call Delay. subTask can't.)
.9  moveq    #50,d1
    jsr      _LVODelay(a6) ;the Counter every 1/60th of a second.
  ;---Print out the current value (whatever it is) of the Counter to the CLI
    move.l   _Counter,-(sp)
    lea      _buffer,a0   ;where to store the formatted ascii string
    move.l   #CounterFormat,d0
    jsr      sprintf
    addq.w   #4,sp
    move.l   d0,d3         ;length of string
    move.l   #_buffer,d2
    move.l   _stdout,d1
    beq.s    skip          ;no _stdout? Must have run from WorkBench
    jsr      _LVOWrite(a6)
skip:
    Dbra     d6,.9
;---Close everything after 10 loops
    bra.s    .14

   XDEF   _cleanexit
_cleanexit:
;---Print the passed string message (in a0) to the CLI
    move.l   _stdout,d1
    beq.s    .14           ;no _stdout? Must have run from WorkBench
    move.l   a0,d2
len move.b   (a0)+,d0
    bne.s    len
    move.l   a0,d3
    sub.l    d2,d3         ;length of string
    movea.l  _DOSBase,a6
    jsr      _LVOWrite(a6)
.14 movea.l  _SysBase,a6
;---If subTask exists, then set PrepareToDie to tell it "Get ready to be
;   deleted, you heathen pig!"
    move.l   _subTaskPtr,d0
    beq.s    .19
    lea      _PrepareToDie,a0
    Bset.b   #0,(a0)
;---(Busy) Wait for subTask to recognize PrepareToDie, then delete subTask.
;   (subTask will clear PrepareToDie before it goes to sleep)
.20 Btst.b   #0,(a0)
    bne.s    .20     ;"Finish incrementing Counter and recognize us, scum!"
;----Delete the subTask
    move.l   d0,-(sp)    ;address of SubTask
    jsr      _DeleteTask ;standard C Function
    addq.w   #4,sp
;---If graphics library is open, close it
.19 move.l   _GfxBase,d0
    beq.s    .22
    movea.l  d0,a1
    jsr      _LVOCloseLibrary(a6)
;--- exit the program (i.e. return to the startup code)-----
.22 rts

;subTaskCode increments the Counter every 1/60 second until main tells it to
;"prepare to be deleted" by setting bit #0 of PrepareToDie. subTask then
;clears PrepareToDie, telling main() that it is now waiting to be deleted.
;It calls the Wait function with a mask of 0. This task will never wake up
;in a million years when you pass a 0 to Wait, but it doesn't matter because
;main is going to delete it.

   XDEF   subTaskCode
subTaskCode:
    movea.l  _GfxBase,a6
;---increment the counter until _main() says "PrepareToDie" (sets bit #0)
.26 jsr      _LVOWaitTOF(a6)  ;slight delay (of 1/60 sec) inbetween each inc
    addq.l   #1,_Counter
    Bclr.b   #0,_PrepareToDie ;Should I Wait?
    beq.s    .26
; At this point, subTask has just cleared PrepareToDie, telling _main
; "I'm ready to be deleted". Now, Wait forever (or until _main deletes me)
    moveq    #0,d0        ;0 = wait forever, never returns from Wait
    movea.l  _SysBase,a6
    jmp      _LVOWait(a6)

   SECTION  TaskData,DATA

   XDEF    _subTaskPtr,_subTaskName
_subTaskPtr    dc.l 0

; Data shared by main and subTaskRtn
   XDEF   _GfxBase,_Counter,_PrepareToDie
_GfxBase       dc.l 0
_Counter       dc.l 0 ;the hex Counter value
_PrepareToDie  dc.b 0

; Strings
_subTaskName   dc.b 'Example SubTask',0
GfxName        dc.b 'graphics.library',0
CantOpenGfx    dc.b 'Cannot open graphics.library',0
CantCreateTask dc.b 'Cannot create the subTask',0
CounterFormat  dc.b 'Counter = %ld',10,0

_buffer  ds.b 40 ;we store our ascii "numeral" Counter here

   END
