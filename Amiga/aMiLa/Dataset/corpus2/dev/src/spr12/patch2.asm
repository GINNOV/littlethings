         SECTION  text,CODE
         ;
         ;        Benefits:
         ;        1)  Unlike patch1.asm, this method can call other routines
         ;            at will.  Unfortunately, it use slightly more CPU for
         ;            removal management.
         ;
         ;        Restrictions:
         ;        1)  None (that I can think of B-))
         ;
         ;
         ;        Export symbols
         ;
         XDEF     _patchStart
         XDEF     _patchEnd
         XDEF     _codeStart
         XDEF     _codeEnd
         XDEF     _UCount_Offset
         XDEF     _SigBit_Offset
         XDEF     _Task_Offset
         XDEF     _RtsNop_Offset
         ;
         ;        Import symbols
         ;
         XREF     _AbsExecBase
         XREF     _LVODisable
         XREF     _LVOEnable
         XREF     _LVOSignal
         ;
         ;        Here begins the patch.
         ;
_patchStart:
         ;
         ;        Here begins the patch code.
         ;
_codeStart:
         ;
         ;        Increment the nesting count.
         ;
         move.l   a0,-(sp)
         lea.l    NCOUNT(pc),a0
         addq.l   #1,(a0)
         move.l   (sp)+,a0
         ;
         ;        Do whatever the patch needs to do...
         ;
         move.l   #10,d0
         ;
         ;        Decrement the nesting count.
         ;
         move.l   a0,-(sp)
         lea.l    NCOUNT(pc),a0
         subq.l   #1,(a0)
         move.l   (sp)+,a0
         ;
         ;        When the patch is to be removed, we change the following
         ;        RTS to a NOP instruction.  This way we don't have any
         ;        overhead in the patch.
         ;
RTSNOP   rts
         ;        Here ends the patch code.
         ;
         ;        Here begins the removal code.
         ;
         ;        Preserve registers.
         ;
         movem.l  d0-d1/a0-a1,-(sp)
         ;
         ;        We decrement the UCOUNT field until it reaches zero.
         ;
         lea.l    UCOUNT(pc),a0
         subq.l   #1,(a0)
         bne.b    10$
         ;
         ;        The UCOUNT field has reached zero so notify remover that it's
         ;        okay to free storage.  Remember that we are still Disabled()
         ;        so the remover can't free our storage yet.
         ;
         move.l   SIGNAL(pc),d0
         move.l   TASK(pc),a1
         move.l   a6,-(sp)
         move.l   _AbsExecBase.W,a6
         jsr      _LVOSignal(a6)
         move.l   (sp)+,a6
         ;
         ;        Restore registers
         ;
10$      movem.l  (sp)+,d0-d1/a0-a1
         ;
         ;        Return to caller
         ;
         rts
_codeEnd:
         ;
         ;        Here ends the removal code.
         ;
         ;
         ;        Here begins the removal variables.
         ;
NCOUNT   dc.l     0
UCOUNT   dc.l     0
SIGNAL   dc.l     0
TASK     dc.l     0
         ;
         ;        Here ends the patch.
         ;
_patchEnd:
         ;
         ;        Here begins some convenience fields.  There are not part of
         ;        the patch.
         ;
_UCount_Offset:
         DC.L     UCOUNT-_patchStart
_SigBit_Offset:
         DC.L     SIGNAL-_patchStart
_Task_Offset:
         DC.L     TASK-_patchStart
_RtsNop_Offset:
         DC.L     RTSNOP-_patchStart
         ;
         ;        The End
         ;
         END
