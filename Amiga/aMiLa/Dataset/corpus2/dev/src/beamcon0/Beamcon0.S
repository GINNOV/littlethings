; © 1995 by Fabrizio Farenga
;
; f.farenga@agora.stm.it
; http://www.agora.stm.it/htbin/wwx?fi^F.Farenga
;
; ##############################################################
;
; Read the O.S. copy of BeamCon0 register.
;
; ##############################################################
;
; These examples are provided "as-is" and are subject to change;
; no warranties are made.  All use is at your own risk.
; No liability or responsibility is assumed.
;
;
;
; ** USE THE O.S. LUKE! **
;


_LVOOpenLibrary=-552
_LVOCloseLibrary=-414
_LVOGfxLookUp=-702
gb_actiview=34
ve_Monitor=28
ms_beamcon0=40

BEAMCON0 EQU $DFF1DC

ResetBeamCon0

  lea     _GfxName,A1  ;Open graphics.library
  move.l  #36,D0       ;V36 or higher.
  move.l  4,A6
  jsr   _LVOOpenLibrary(A6) 
  move.l  D0,_GfxBase  ;If graphics.library is older
  beq     NoViewExtra  ;than v36, the O.S. can't manage
                       ;BEAMCON0

  move.l  _GfxBase,A6
  move.l  gb_ActiView(A6),A0 ;Check for ViewExtra
  move.l  _GfxBase,A6        ;structure
  jsr     _LVOGfxLookUp(A6)
  tst.l   D0
  beq     NoViewExtra

  move.l  D0,A0               ;Get the Monitor
  move.l  ve_Monitor(A0),A0   ;structure from ViewExtra

  move.w  ms_beamcon0(A0),D0  ;Read the sync of the
                              ;active monitor.

  move.w  D0,BEAMCON0         ;Write the sync into the
                              ;BEAMCON0 register

NoViewExtra:

Exit:
  move.l  _GfxBase,A1         ;Close graphics.library
  move.l  4,A6
  jsr     _LVOCloseLibrary(A6)

  moveq   #0,D0

  rts

_GfxBase:  dc.l 0
_GfxName:  dc.b "graphics.library",0
