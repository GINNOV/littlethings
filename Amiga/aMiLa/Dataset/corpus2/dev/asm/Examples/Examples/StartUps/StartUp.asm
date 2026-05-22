;=============================Startup.asm==============================
;For Workbench programs, or CLI programs with or without command line para-
;meters. (Allows arguments in quotes on the CLI). Also can be modified to
;exclude argument parsing, standard IO, and C exit capability. Assembled
;with Inovatronics CAPE assembler.
;Modified from Astartup.asm by Bryce Nesbitt. Additional Mods by Jeff Glatt.

  SMALLOBJ  ;CAPE directive for PC-relative addressing replaces absolute

;************** Included Files *******************

   INCLUDE "allsyms.i"  ;CAPE include file of all Amiga system variables

;****************** Imported *************************

   XREF   _main           ; C/asm code entry point

;**********************************************************
;
;   Standard Program Entry Point (if MAXARGS is not 0)
;
;   main (argc, argv)
;      int   argc;    ;Passed as 32 bits. 0=from Workbench
;      char *argv[];  ;Passed as 32 bits. If from workbench,
;                     ;then this is the WB message pointer.
;

; The next 3 equates determine what code gets included during assembly.

MAXARGS equ 31   ;max # of CLI arguments parsed (If 0, then doesn't create
                ;the argv and argc arrays, or pass parameters to _main. It
                ;will delete the parsing code during assembly.)

Cexit   equ 1   ;If 0, then only exit point for assembly via an rts in main
                ;or a jsr exit with the return code in d0. No C exit point
                ;is supported.

standard equ 1  ;If 0, doesn't set up stdin, stdout, stderr, and errno.

    SECTION StartUpCode,CODE

    XDEF    _startup,_BUFFER,exit

_BUFFER:
_startup:
     move.l   d0,d6       ;dosCmdLen
     move.l   a0,a2       ;dosCmdBuf
     lea      initialSP,a3

   ;---Get stack address
     move.l   sp,(a3)+    ; initialSP

   ;---Get Exec library base
     movea.l  $00000004,a6
     move.l   a6,(a3)+    ;_SysBase

   ;------ Open the DOS library:
     lea      DOSName,a1
     jsr      _LVOOpenLibrary(a6) ; Look ma, no error check!
     move.l   d0,(a3)+            ; _DOSBase
     movea.l  d0,a5

   ;------ get the address of our task
     movea.l  ThisTask(a6),a4
     move.l   a4,(a3)+            ;_ThisTask 

   ;------ are we running as a son of Workbench?
     move.l   pr_CLI(a4),d0
     beq      fromWorkbench
     clr.l    (a3)+      ; returnMsg

;=======================================================================
;====== CLI Startup Code ===============================================
;=======================================================================

  IFNE MAXARGS

   ;------ find command name:
fromCLI:
    movea.l  pr_CLI(a4),a0
    adda.l   a0,a0      ; bcpl pointer conversion
    adda.l   a0,a0
    movea.l  cli_CommandName(a0),a0
    adda.l   a0,a0      ; bcpl pointer conversion
    adda.l   a0,a0

   ;------ create buffer and array:
    lea     _argvBuffer,a4
    lea     _argvArray,a1
    moveq   #1,d2                   ; param counter

   ;------ fetch command name:
    moveq   #0,d0
    move.b  (a0)+,d0   ; size of command name
    move.l  a4,(a1)+   ; ptr to command name
    bra.s   DoC
CMD move.b  (a0)+,(a4)+
DoC Dbra    d0,CMD
    clr.b   (a4)+

;------ collect parameters:
   ;------ skip control characters and leading spaces:
    moveq   #MAXARGS-1,d3
    moveq   #' ',d0
    moveq   #'"',d4
parmloopa:
    move.b  (a2)+,d1
    subq.l  #1,d6
    ble.s   parmExit   ;last char to process
    cmp.b   d0,d1
    ble.s   parmloopa  ;if not $21 to $7F
    movea.l a4,a0      ;save beginning of arg
  ;---check for quoted string
    cmp.b   d4,d1
    bne.s   PR
   ;---process quoted string (copy chars up to control or " char, or no
   ;   more chars in the command line
QU  move.b  (a2)+,d1
    cmp.b   d0,d1
    blt.s   nxP        ;if control char
    cmp.b   d4,d1
    beq.s   nxP        ;if end quote
    move.b  d1,(a4)+
    subq.l  #1,d6
    bge.s   QU
    bra.s   nxP
   ;------ copy parameter up to a space or control char
PR  move.b  d1,(a4)+
    move.b  (a2)+,d1
    subq.l  #1,d6
    cmp.b   d0,d1
    bgt.s   PR
nxP clr.b   (a4)+      ;Null terminate
    addq.w  #1,d2
    move.l  a0,(a1)+
    Dbra    d3,parmloopa
   ;------ Clear out ends (All Done)
parmExit:
    clr.b   (a4)
    clr.l   (a1)
  ;---push passed values to _main
    pea      _argvArray  ; Arg array pointer
    move.l   d2,-(sp)    ; Arg count

 ENDC

 IFNE standard

   ;------ get standard input handle:
    movea.l  a5,a6      ; Get _DOSBase
    jsr      _LVOInput(a6)
    move.l   d0,(a3)+   ; _stdin

   ;------ get standard output handle:
    jsr      _LVOOutput(a6)
    move.l   d0,(a3)+   ; _stdout
    move.l   d0,(a3)+   ; _stderr

 ENDC

   ;------ call C main entry point
    bra.s    domain

;=======================================================================
;====== Workbench Startup Code =========================================
;=======================================================================

   ;------ we are now set up.  wait for a message from our starter
fromWorkbench:
    ;[a4=ThisTask]
    ;[a5=_DOSBase]
    lea     pr_MsgPort(a4),a0   ; our process base
    jsr     _LVOWaitPort(a6)
    lea     pr_MsgPort(a4),a0   ; our process base
    jsr     _LVOGetMsg(a6)

   ;------ save the message so we can return it later
    move.l   d0,(a3)+ ; set returnMsg. NOTE: no ReplyMsg yet!

 IFNE MAXARGS

   ;------ push argc and argv.  if argc = 0 program came from
   ;------ Workbench, and argv will have the WB message address.
    move.l   d0,-(SP)   ; set argv to the WB message
    clr.l   -(SP)       ; set argc to 0

 ENDC

   ;------ get the first argument
    ;[d0=WBMessage]
    movea.l  a5,a6      ;Get _DOSBase
    movea.l  d0,a2
    move.l   sm_ArgList(a2),d0
    beq.s    docons

   ;------ and set the current directory to the same directory
    movea.l  d0,a0
    move.l   wa_Lock(a0),d1
    jsr      _LVOCurrentDir(a6)

docons: ;------ ignore the toolwindow argument
domain:
    jsr     _main
    moveq   #0,d0      ; Successful return code

 IFNE Cexit

 XDEF _exit

    bra.s   exit

;************************************************************************
;   C Program exit(returncode) Function

_exit: move.l   4(sp),d0      ; extract return code

 ENDC

exit: move.l   d0,d2         ; save return code
      lea      initialSP,a3  ; set "frame pointer"
      move.l   (a3)+,sp      ; restore stack pointer

   ;------ close DOS library:
      movea.l  (a3)+,a6
      movea.l  (a3),a1
      jsr      _LVOCloseLibrary(a6)

   ;------ if we ran from CLI, skip workbench cleanup:
      addq.l   #8,a3         ;skip ThisTask
      move.l   (a3),d0
      beq.s    exitToDOS

   ;------ return the startup message to our parent
   ;------ we forbid so workbench can't UnLoadSeg() us
   ;------ before we are done:
      addq.b   #1,TDNestCnt(a6)
      ;[d0=returnMsg]
      movea.l  d0,a1
      jsr      _LVOReplyMsg(a6)
   ;------ this rts sends us back to DOS:
exitToDOS:
      move.l   d2,d0
      rts

 ;******************* DATA ***********************
      XDEF  _SysBase,_DOSBase,_returnMsg,_ThisTask

initialSP   dc.l 0   ; initial stack pointer
_SysBase    dc.l 0   ; exec library base pointer
_DOSBase    dc.l 0   ; dos library base pointer
_ThisTask   dc.l 0   ; address of this task
_returnMsg  dc.l 0   ; Workbench message, or zero for CLI startup

  IFNE standard

      XDEF  _errno,_stdin,_stdout,_stderr
_stdin      dc.l 0   ; in handle
_stdout     dc.l 0   ; out handle
_stderr     dc.l 0   ; error handle
_errno      dc.l 0   ; error number from OS routines

  ENDC

  IFNE MAXARGS

  XDEF _argvArray,_argvBuffer

_argvArray   ds.l MAXARGS+1 ;maximum args (parameters) on CLI line
_argvBuffer  ds.b 256       ;256 characters maximum on a CLI line

  ENDC

DOSName:    dc.b 'dos.library',0

  END
