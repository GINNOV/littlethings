
***********************************************
* This little program speeds up               *
* the motors of floppys df0: - df3:           *
* This has two effects:                       *
* 1. the floppy is speeded                    *
* 2. the scratching sound the floppy          *
*    usually makes becomes a whining sound    *
*                                             *
* I know of no negative effects               *
*                                             *
*   E. Lenz                                   *
*   Johann-Fichte-Strasse 11                  *
*   8 Munich 40                               *
*   Germany                                   *
***********************************************

; EXEC.library routines

_AbsExecBase       equ 4
_LVOForbid         equ -$84
_LVOPermit         equ -$8a
_LVOFindName       equ -$114
_LVOGetMsg         equ -$174
_LVOReplyMsg       equ -$17a
_LVOWaitPort       equ -$180

PortStatus   equ 34
TrackPort    equ 36
SPReg        equ 54
IDNestCnt    equ 294
TrackTask    equ 302
DeviceList   equ 350

pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114

        moveq   #0,d7
        movea.l _AbsExecBase,a6
        movea.l ThisTask(a6),a0

; Start from Workbench ?

        tst.l   pr_CLI(a0)
        bne.s   noWB          Not from WB

; Get WB Message

        lea     pr_MsgPort(a0),a0
        jsr     _LVOWaitPort(a6)
        jsr     _LVOGetMsg(a6)
        move.l  d0,d7           Pointer to WB message


noWB    bsr.s   Disable

        lea     TrackName(pc),a1
        lea     DeviceList(a6),a0
        jsr     _LVOFindName(a6)
        movea.l d0,a5              a5 = trackdisk save
        beq.s   Err

; speed up df0: to df3:

        moveq   #12,d3
l3      move.l  TrackPort(a5,d3.w),d0   is drive implemented?
        beq.s   l5
        movea.l d0,a3

l1      btst    #0,PortStatus(a3)     wait until drive ready
        bne.s   l1
        move.l  #1800,$2c(a3)         speed up step motor
        move.l  #1,$30(a3)            no wait after positioning
        lea     TrackTask+SPReg(a3),a2
        movea.l (a2),a1

l5      subq.l  #4,d3
        bpl.s   l3

Err     bsr.s   Enable
        tst.l   d7
        beq.s   Nbench

        jsr     _LVOForbid(a6)
        movea.l d7,a1
        jsr     _LVOReplyMsg(a6)  Reply to WB
        jsr     _LVOPermit(a6)

Nbench  moveq   #0,d0    No errors
        rts


Disable move.w  #$4000,$dff09a     disable copper interrupts
        move.l  a6,-(a7)
        movea.l _AbsExecBase,a6
        addq.b  #1,IDNestCnt(a6)
        bra.s   Ll1

Enable  move.l  a6,-(a7)           enable copper interrupts
        movea.l _AbsExecBase,a6
        subq.b  #1,IDNestCnt(a6)
        bge.s   Ll1
        move.w  #$c000,$dff09a
Ll1     movea.l (a7)+,a6
        rts

TrackName  dc.b 'trackdisk.device',0
           even
           end
