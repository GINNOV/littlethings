;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»
;»»»»»  $Header: Big:Programming/Assembler/RCS/R250LVOs.i,v 1.3 1996/06/27 16:53:07 AGMS Exp $
;»»»»»
;»»»»»  Library vector offsets used by Random250 program.  Extracted from
;»»»»»  the full list for assembly speed reasons.
;»»»»»
;»»»»»  $Log: R250LVOs.i,v $
;»»»»»  Revision 1.3  1996/06/27  16:53:07  AGMS
;»»»»»  Semaphore stuff added.
;»»»»»
;»»»»»  Revision 1.2  1996/06/22  13:53:08  AGMS
;»»»»»  *** empty log message ***
;»»»»»
;»»»»»  Revision 1.1  1996/06/20  18:59:53  AGMS
;»»»»»  Initial revision
;»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»

                                IFND    R250_LVO_I
R250_LVO_I                      SET     1

; For exec.library:
_LVOFreeMem                     EQU     -210
_LVORemove                      EQU     -252
_LVOCloseLibrary                EQU     -414
_LVOOpenLibrary                 EQU     -552
_LVOInitSemaphore               EQU     -558
_LVOObtainSemaphore             EQU     -564
_LVOReleaseSemaphore            EQU     -570

; For intuition.library:
_LVOCurrentTime                 EQU     -84
_LVOAutoRequest                 EQU     -348

                                ENDC
