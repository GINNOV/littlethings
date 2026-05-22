      IFND      DPRINTF_I

DPRINTF_I       SET         1
DPFC            SET         0

; -----------------------------
DPFHELP MACRO
          IFNC         '','\1'
            move.w     \1,-(sp)
            move.l     \1,-(sp)                 ; Parameter auf Stack
DPFC        SET        DPFC+1
          ENDC
        ENDM
; -----------------------------
DPF     MACRO
          IFD               DPRINTF
            IFNE            DPRINTF
              movem.l       d0/a6,-(sp)
              movea.l       4.w,a6              ; ^ExecBase
              jsr           -528(a6)            ;_LVOGetCC
              move.w        d0,-(sp)
              movem.l       2(sp),d0/a6

DPFC          SET           0

; Das Makro kann hier erweitert werden (DPFHELP \e usw.)!

              DPFHELP       \d
              DPFHELP       \c
              DPFHELP       \b
              DPFHELP       \a
              DPFHELP       \9
              DPFHELP       \8
              DPFHELP       \7
              DPFHELP       \6
              DPFHELP       \5
              DPFHELP       \4
              DPFHELP       \3
              DPFHELP       \2

              movea.l       4.w,a6              ; ^ExecBase
              jsr           -120(a6)            ; _LVODisable

              pea           DPFC
              pea           .DPrintfForm\@(pc)

              movea.l       -112(a6),a6         ; _LVODebug+2

              cmpi.l        #'DPF0',8(a6)       ; Test ob DPrintf
              bne.s         .NoPrintf\@         ; vorhanden?
              movem.l       a5,-(sp)            ; a5 retten
              movea.l       16(a6),a5           ; ^DPrintf Datenstruktur
              movea.l       12(a6),a6           ; ^DPrintf Code
              jsr           (a6)                ; Daten übertragen
                                                ; d0 und a6 werden verändert!
              movem.l       (sp)+,a5
.NoPrintf\@:
              IFEQ          DPFC
                addq.l      #8,sp               ; Optimierung
              ELSEIF
                lea         (6*DPFC)+8(sp),sp
              ENDC
              movea.l       4.w,a6              ; ^ExecBase
              jsr           -126(a6)            ; _LVOEnable

              move.w        (sp)+,d0            ; Statusregister
              move.b        d0,ccr              ; Restaurieren
              movem.l       (sp)+,d0/a6
              bra           .DPrintfEnde\@
.DPrintfForm\@:
              dc.b          "\1"
              IFC           'L','\0'
                dc.b        10
              ENDC
              dc.b          0
              even
.DPrintfEnde\@:
            ENDC
          ENDC
        ENDM
      ENDC                  ; DPRINTF_I
