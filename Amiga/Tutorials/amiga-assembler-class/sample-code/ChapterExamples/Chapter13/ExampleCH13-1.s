* --------------------------------------------------------------------

; Example CH13-1.s

; Function name:     WaitForExitMessage()


; Purpose:           Wait until user hits window's close gadget


; Input Parameters:  Address of IDCMP user-port should be in a2. 


; Output parameters: None


; Register Usage:    a0: Used by WaitPort() and GetMsg()  
                     
;                    a1: Used by ReplyMsg()
                     
;                    a2: Holds user-port address

;                    d0: Used by WaitPort() and GetMsg()
                     
;                    d1: Unused but possibly altered by system functions

;                    d2: Used as an exit flag (quit when non-zero)


; Other Notes:       All registers are preserved

* --------------------------------------------------------------------

; subroutine specific EQUates...

TRUE                 EQU      1

* --------------------------------------------------------------------

WaitForExitMessage   movem.l  d0-d2/a0-a2,-(sp)    preserve registers

                     clr.l    d2                   clear exit flag

WaitForExitMessage2  move.l   a2,a0                port address
  
                     CALLSYS  WaitPort,_SysBase  

                     jsr      GetMessage           

                     cmpi.l   #TRUE,d2             exit flag set?

                     bne      WaitForExitMessage2

                     movem.l   (sp)+,d0-d2/a0-a2   restore registers

                     rts                           logical end of routine

* --------------------------------------------------------------------
                     
GetMessage           move.l   a2,a0                get port address in a0

                     CALLSYS  GetMsg,_SysBase      get the message

                     tst.l    d0

                     beq      GetMessageExit       did it exist?

                     move.l   d0,a1                copy pointer to a1

                     cmpi.l   #IDCMP_CLOSEWINDOW,im_Class(a1) 

                     bne      GetMessage1          

                     moveq    #TRUE,d2             user hit close gadget 

                     
GetMessage1          CALLSYS  ReplyMsg,_SysBase

                     bra      GetMessage           check for more messages

GetMessageExit       rts                           d2 holds exit flag
                     
* --------------------------------------------------------------------



