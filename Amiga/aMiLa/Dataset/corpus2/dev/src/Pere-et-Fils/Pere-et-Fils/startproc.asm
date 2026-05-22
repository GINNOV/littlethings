
************************************************************************
*
*       C reentrant process Startup/Exit           (JM Forgeas 13-06-87)
*       compile (under Lattice) multiple process on once loaded code 
*
************************************************************************


******* Included Files *************************************************

        INCLUDE "exec/types.i"
        INCLUDE "exec/libraries.i"
        INCLUDE "exec/tasks.i"


******* Imported *******************************************************

xlib    macro
        xref    _LVO\1
        endm

        xref    _AbsExecBase        ; the only one absolute system adress
        xref    _main               ; C code entry point

        xlib    Forbid
        xlib    Permit


******* Exported *******************************************************

        xdef   _SysBase            ; Lattice seems to need it
        xdef   _exit               ; standard C exit function

callsys MACRO
        CALLLIB _LVO\1
        ENDM


************************************************************************
*
*       Standard Program Entry Point
*
************************************************************************

startup:
               move.l _AbsExecBase,a6    ; get Exec's library base ptr
               callsys  Forbid           ; writing together...
               move.l a6,_SysBase        ; save it in _SysBase
               callsys  Permit           ; other process can read it

               move.l SP,d0              ; send initial task stack ptr
               move.l d0,-(SP)           ;      to:  main(initialSP)

               jsr    _main              ; main() opens doslib itself


        ;------ return or exit from code:
_exit:
               move.l         4(SP),d0   ; restore stack ptr stored and
               move.l         d0,SP      ;      returned by _main
               moveq.l        #0,d0
               rts


************************************************************************

        DATA

************************************************************************

_SysBase       dc.l   0


        END
