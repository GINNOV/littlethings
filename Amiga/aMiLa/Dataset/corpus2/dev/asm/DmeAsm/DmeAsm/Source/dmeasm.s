*************************************************************************
*  DmeAsm V1.1,  April 1990,  Written by Nic Wilson                     *
*  Based on an original program by Warren Weber                         *
*************************************************************************

                INCDIR  dh0:devpac/include/
                INCLUDE exec/exec_lib.i
                INCLUDE intuition/intuitionbase.i
                INCLUDE intuition/intuition_lib.i
                INCLUDE libraries/dos_lib.i

                        SECTION ,CODE
                INCLUDE common/macros.i

                        SECTION program,DATA
                INCLUDE dmeasm.data

                        SECTION ,CODE

                StartCode
main            bsr     copynames
		moveq   #0,d7
                lea     patchwindow,a0
                CALLINT  OpenWindow
                move.l  d0,ourwindow
                beq     exit
                move.l  d0,a0
                move.l  wd_RPort(a0),rport
                move.l  wd_UserPort(a0),mport

                move.l  rport,a0
                lea     IText1,a1
                moveq   #0,d0
                moveq   #0,d1
                CALLINT PrintIText              ;print all our text

                move.l  rport,a0
                lea     sourceimage,a1          ;source image
                moveq   #0,d0                   ;leftedge
                moveq   #0,d1                   ;topedge
                CALLINT DrawImage

                move.l  _wbmsg,d0               ;are we from WB
                bne     wbdme                   ;no

        ;make 1 of the string gadgets active

                cmpi.l  #0,dmescreen            ;does dmescreen exist
                bne.s   dmefound                ;yes so make dest gad active
                lea     sourcestring,a0
                bsr     activate                ;else, make source gad active
                bra     checkmsg
dmefound        lea     deststring,a0
                bsr     activate                ;make destination gadget active

;----------------------------------------------------------
;       Main Loop, get any messages, check gadgets
;----------------------------------------------------------

checkmsg        move.l  mport,a0
                CALLEXEC WaitPort
                move.l  mport,a0
                CALLEXEC GetMsg
                move.l  d0,msgpointer           ;save ptr to message struct
                move.l  d0,a0
                move.l  im_Class(a0),a1
                cmpa.l  #GADGETUP,a1
                beq     checkgadgets
                move.l  msgpointer,a1
                bsr     repmessage
                bra.s   checkmsg

;---------------------------------------------------
;       Find what gadget was selected
;---------------------------------------------------

checkgadgets    move.l  msgpointer,a1
                move.l  im_IAddress(a1),a0      ;get address of gadget struct
                bsr     repmessage
                move.w  gg_GadgetID(a0),d0
                cmpi.b  #6,d0                   ;just past toggle select gadgets
                blt     checkmsg                ;if so skip it
                cmpi.b  #6,d0                   ;is it cancel
                beq     cancelhit
                cmpi.b  #7,d0                   ;is it assemble
                beq     assemblehit
                cmpi.b  #8,d0                   ;is it metascope
                beq     metahit
                cmpi.b  #9,d0                   ;is it asm/debug
                beq     asmdebughit
                cmpi.b  #10,d0                  ;asm/run
                beq     asmrunhit
                cmpi.b  #13,d0                  ;run
                beq     runhit
                cmpi.b  #11,d0                  ;source
                beq     sourcehit
                cmpi.b  #14,d0
                beq     outhit
                cmpi.b  #12,d0                  ;destination
                bne     checkmsg                ;no, loop

;----------------------------------------------------------------------------
;       Handle the Destination string gadget being edited, assemble being hit
;----------------------------------------------------------------------------

desthit         lea     deststring,a0
                bsr     stillact
                lea     outstring,a0
                bsr     activate
                bra     checkmsg

outhit          lea     outstring,a0
                bsr     stillact
                bra     assemblehit

stillact        cmpi.w  #SELECTED,gg_Flags(a0)
                beq     stillact
                rts

assemblehit     bsr     buildcommand            ;build the command line
                bsr     shutwind                ;close wind
                move.l  #prog,d1                ;string to loadseg
                bsr     loadnrun                ;assemble it
                bra     exit                    ;quit

;---------------------------------
;       Source gadget routine
;---------------------------------
        ;copy source to destination string gadget
sourcehit       lea     sourcebuff,a1
                lea     destbuff,a0
                bsr     copydest
                bsr     refreshstrings          ;refresh the string gads
                lea     deststring,a0
                bsr     activate                ;activate dest string gad
                bra     checkmsg

;---------------------------------
;       Cancel gadget routine
;---------------------------------

cancelhit       bra     closewind               ;exit

;---------------------------------
;       metascope gadget routine
;---------------------------------

metahit         bsr     shutwind
meta2           lea     destbuff,a1             ;actuall file to metascope
                lea     metastring,a0           ;execute string
                adda.l  #11,a0                  ;point to 1st char
                bsr     copytillnull            ;copy source buff to text string
                move.l  #metastring,d1          ;metascope text
                bsr     runit                   ;metascope it
                bra     exit

;---------------------------------
;       Run gadget routine
;---------------------------------

runhit          bsr     shutwind
                lea     runprog,a0              ;destination
                lea     destbuff,a1             ;source
                bsr     copytillnull            ;copy to command string
                move.l  #runprog,d1
                bsr     runit                   ;run the program
                bra     exit

;---------------------------------
;       Asm/Run gadget routine
;---------------------------------

asmrunhit       bsr     buildcommand            ;build the command line
                bsr     shutwind
                move.l  #prog,d1                ;string to loadseg
                bsr     loadnrun                ;assemble it
                cmpi.l  #4,d0                   ;check return code
                bge     exit                    ;if 1 or more quit
                WaitFor 150                     ;allow disk access to stop

                lea     destbuff,a1             ;filename is here
                lea     runprog,a0              ;program string to run
                bsr     copytillnull            ;move it in
                move.l  #runprog,d1             ;run the program
                bsr     runit
                bra     exit                    ;quit

;---------------------------------
;       Asm/Debug gadget routine
;---------------------------------

asmdebughit     bsr     buildcommand
                bsr     shutwind
                move.l  #prog,d1                ;string to loadseg
                bsr     loadnrun                ;assemble it
                cmpi.l  #4,d0                   ;check return code
                bge     exit                    ;if 1 or more quit
                bra     meta2                   ;else metascope it and exit

*******************************************************************************
*                               SUBROUTINES
;-------------------------------------------------------------------
;       Execute the command string and wait for the task to end.
;-------------------------------------------------------------------
        ;d1 has string to load

loadnrun        move.l   #args,d1
                moveq    #0,d2
                moveq    #0,d3
                CALLDOS  Execute
waittask        move.l   #taskname,a1
                CALLEXEC FindTask
                tst.l    d0
                bne      waittask
                move.l   d7,d1
                beq      nowind
                CALLDOS  Close
nowind          rts

;---------------------------------------------------------------
;       Find which gadgets are selected, build the command line
;---------------------------------------------------------------

buildcommand    lea     outbuff,a0
                cmpi.b  #0,(a0)
                beq     opencon
                move.l  #smallwind,d1
                move.l  #MODE_NEWFILE,d2
                CALLDOS Open
                move.l  d0,d7
                lea     prog1,a0
                lea     outbuff,a1
                bsr     copytillnull
                subq.l  #1,a0
                move.b  #$20,(a0)+
                move.b  #0,(a0)
opencon         lea     prog,a1
                lea     args,a0                 ;command to loadseg
                bsr     copytillnull
                subq.l  #1,a0
fillrest        lea     sourcebuff,a1           ;source
                bsr     copytillnull            ;copy source name to command line
                move.b  #' ',-1(a0)             ;insert a space
                move.b  #'-',(a0)+
                lea     gadgetlist,a2
                move.w  gg_Flags(a2),d0         ;debug gadget
                btst.l  #7,d0                   ;is it selected
                bne     .link                   ;yes(no debug wanted)
                move.b  #'d',(a0)+              ;d for debug

.link           lea     linkgad,a2
                move.w  gg_Flags(a2),d0         ;link gadget
                btst.l  #7,d0                   ;is it selected
                beq     .slowmem                ;no
                move.b  #'l',(a0)+              ;l for link

.slowmem        lea     memgad,a2
                move.w  gg_Flags(a2),d0         ;slow assemble memory
                btst.l  #7,d0                   ;is it selected
                beq     .insertdest             ;no
                move.b  #'m',(a0)+              ;m slow assemble

.insertdest     move.b  #'o',(a0)+              ;insert the needed o
                lea     destbuff,a1             ;source for copy a0 has dest
                bsr     copytillnull            ;insert it

.list           lea     listgad,a2              ;listing gadget
                move.w  gg_Flags(a2),d0
                btst.l  #7,d0                   ;is it selected
                beq     .nolist                 ;finished
                move.b  #' ',-1(a0)             ;insert a space
                move.b  #'-',(a0)+              ;insert the -
                move.b  #'p',(a0)+              ;p for listing file
                lea     destbuff,a1             ;list file name
                bsr     copytillnull
                move.b  #'.',-1(a0)             ;build .lst extension
                move.b  #'l',(a0)+
                move.b  #'s',(a0)+
                move.b  #'t',(a0)+
                move.b  #0,(a0)                 ;null command line
.nolist         rts

;------------------------------------------------------------------
;       copy filename from CLI paramter to string buffer
;------------------------------------------------------------------

copynames	move.l   _argv,a1		;get param array
		move.l   (a1),a1		;get first param
	        lea     sourcebuff,a0           ;source string gadget
.move           move.b  (a1)+,(a0)+             
                cmpi.b  #$0,(a1)
                bne     .move
.done           move.b  #0,(a0)

        ;copy from source string buffer to destination string buffer
        
copydest        lea     sourcebuff,a1           ;source buffer
                lea     destbuff,a0             ;destination buffer
                moveq   #1,d0                   ;set for one char
.copy           addq.b  #1,d0                   ;increment character count
                move.b  (a1)+,(a0)+             ;move source to dest
                bne     .copy                   ;stop on zero
                subq.b  #2,d0                   ;correct for dbf
.dot            cmpi.b  #'.',-(a0)              ;find dot
                beq     .null                   ;found dot
                dbf     d0,.dot
                bra     .done
.null           move.b  #0,(a0)+                ;clear dot
.done           lea     destbuff,a0
                CountString
                lea     deststringSInfo,a0      ;string info struct
                move.w  d0,si_BufferPos(a0)     ;cursor pos in string gadget
                rts

;----------------------
;reply to all mesages
;----------------------

repmessage      pushscr
                move.l  a1,d0
                beq     .nomsg
                CALLEXEC ReplyMsg
.nomsg          popscr
                rts

;-----------------------------------
;       Execute their command line
;-----------------------------------

        ;command to execute must be in d1
runit           move.l  d1,a0                   ;string to execute
                tst.b   (a0)                    ;is there anything to execute
                beq     no                     ;no
                moveq   #0,d2                   ;input
                move.l  _stdout,d3
                CALLDOS Execute
                ActWindow               ;activate cli window
no             rts

;----------------------------------
;       Copy Memory Routine
;----------------------------------
        ;copy memory untill a null is found, a1 source a0 dest
copytillnull    move.b  (a1)+,(a0)+
                bne     copytillnull            ;continue till null found
                move.b  #0,(a0)                 ;null it
                rts

;------------------------------
;       Refresh string gadgets
;------------------------------

refreshstrings  lea     sourcestring,a0         ;start at source string gad
                move.l  ourwindow,a1
                move.l  #0,a2                   ;no requestors
                CALLINT RefreshGadgets
                rts

;------------------------------------------------------
;       activate a string gadget, gadget must be in a0
;------------------------------------------------------

activate        move.l  ourwindow,a1
                suba.l  a2,a2                   ;no requestors
                CALLINT ActivateGadget
                rts

;--------------------------
;       Close our window
;--------------------------

shutwind        move.l  ourwindow,a0
                CALLINT CloseWindow
                rts

*****************************************************************************
*                       ERROR ROUTINES

        ;-----------------------------------------------
        ;       Warn if we cant do a loadseg on Genim2
        ;-----------------------------------------------
errloadseg      lea     loadsegmsg,a0           ;print error msg
                move.l  _stdout,d1
                DosPrint
                addq.l  #4,a7                   ;replace the rts and exit
                bra     exit

        ;-------------------------------------------------
        ;       Warn that this program runs from cli only
        ;-------------------------------------------------
wbdme           move.l  rport,a0
                lea     statusstruct,a1
                move.l  #wbdmemsg,it_IText(a1)  ;print an error msg
                moveq   #0,d0                   ;x
                moveq   #0,d1                   ;y
                CALLINT PrintIText
                WaitFor 350

*****************************************************************************
*                               EXIT

closewind       bsr     shutwind
exit            ActWindow
                rts

*****************************************************************************
*                               DATA

                        SECTION program,DATA
smallwind       dc.b    'con:0/0/200/10/Assembling... ',0
prog            dc.b    'sys:c/GenIm2 >'
prog1           dc.b    'con:0/0/640/255/Assembling... ',0
args            dc.b    '                                                                                         ',0
metastring      dc.b    'MetaScope                                         ',0
wbdmemsg        dc.b    'DmeAsm runs from Cli only',0
runprog         dc.b    '                                      ',0
loadsegmsg      dc.b    114,$0a,' Cant run Genim2, check that its in the C or current directory',$0a
                dc.b    '       and that there is enough memory to run it.',$0a,0
taskname        dc.b    'GenIm2',0
*****************************************************************************

                        SECTION variables,BSS
        cnop 0,4
rport           ds.l    1
mport           ds.l    1
dmescreen       ds.l    1
ourwindow       ds.l    1
msgpointer      ds.l    1
segment         ds.l    1
flag            ds.b    1
sourcebuff      ds.b    40
destbuff        ds.b    40
outbuff         ds.b    40

        END
