; startup 4 LITTEL v0.16b 
; v0.17b : adding _exception, _exceptioninfo 
; _LITTEL, _G1, _G2, _G3, _G4 : f”rdefinierade general purpose variabler. 
; removed _ExecBase, it seems it didnt have the same address as _SysBase.. 
; version is now v18
 
   incdir "ainc:" 
 
   include "lib/exec.i" 
   include "lib/dos.i" 
 
   xref _DATA_BAS_ 
 
   xref programstart_ 
   
 
   MACHINE 68020 
 
   near A4,-1 
 
   code 
 
startup: 
   * save regs       *
   movem.l d2-d7/a2-a6, -(a7) 

   *   save arg        * 
   move.l a0, _arg(A4)

   * init smalldata    * 
   lea _DATA_BAS_, a1 
   lea 32766(a1), a4 

   * save a4 in code-segment * 
   move.l a4, littel_a4 
  
 
   * sysbase -> a6    * 
   move.l 4, a6
   * save it           * 
   move.l a6, _SysBase(A4) 

   * open dos          * 
   lea dosname(pc), a1 
   move.l #37, d0 
   jsr OpenLibrary(a6) 
   move.l D0, _DOSBase(A4) 
   beq cleanup                ;error ? 

   * open gfx          * 
   lea gfxname(pc), a1 
   move.l #37, d0           ;gfx ver 37 
   jsr OpenLibrary(A6)      ;open gfx 
   move.l d0, _GfxBase(A4)  ; save in _graphicsBase 
   beq cleanup                     ;error? 

   * open intuition    * 
   lea intuitionname(pc), A1 
   move.l #37, D0           ;intuition v 37 
   jsr OpenLibrary(a6)      ; open intuition 
   move.l d0, _IntuitionBase(A4) ; save in _inuitionBase 
   beq cleanup 

   * open utility     * 
   lea utilityname(pc), A1 
   move.l #37, d0 
   jsr OpenLibrary(a6) 
   move.l d0, _UtilityBase(A4) 
   beq cleanup 

   * get input and output * 
   movea.l _DOSBase(a4),a6 
   jsr     Output(a6)                ; Output() 
   move.l  d0,_stdout(A4) 
   jsr     Input(a6)                ; Input() 
   move.l  d0,_stdin(A4) 

   move.l #0, d7                  ; clear the exception-carrier..
   move.l #$C7974747, _LITTEL(A4) ; tell we  are LITTEL 
 
   bsr programstart_ 
 
cleanup: 
   move.l d0, d5            ; save returnvalue 
   move.l _SysBase(A4), a6 
   move.l _IntuitionBase(A4), a1 
   jsr CloseLibrary(a6) 
   move.l _DOSBase(A4), a1 
   jsr CloseLibrary(a6) 
   move.l _GfxBase(A4), a1 
   jsr CloseLibrary(a6) 
   move.l _UtilityBase(A4), a1 
   jsr CloseLibrary(a6) 
   move.l d5, d0            ; return returnvalue
   * restore regs *
   movem.l (a7)+, d2-d7/a2-a6  
   rts 


   xdef littel_a4 
 
littel_a4: 
   ds.l 1 
 
   ;data 
 
   even 
dosname: 
   dc.b "dos.library",0 
   even 
gfxname: 
   dc.b "graphics.library",0 
   even 
intuitionname: 
   dc.b "intuition.library",0 
   even 
utilityname: 
   dc.b "utility.library",0 
 
  xdef _SysBase, _DOSBase, _IntuitionBase, _GfxBase, _UtilityBase 
  xdef _arg, _stdin, _stdout, _exception, _exceptioninfo 
  xdef _LITTEL, _G1, _G2, _G3, _G4 
 
  BSS 
 
_SysBase: 
   ds.l 1 
_DOSBase: 
   ds.l 1 
_IntuitionBase: 
   ds.l 1 
_GfxBase: 
   ds.l 1 
_UtilityBase: 
   ds.l 1 
_arg: 
   ds.l 1 
_stdin: 
   ds.l 1 
_stdout: 
   ds.l 1 
_exception: 
   ds.l 1 
_exceptioninfo: 
   ds.l 1 
_LITTEL: 
   ds.l 1 
_reserved1: 
   ds.l 1 
_reserved2: 
   ds.l 1 
_G1: 
   ds.l 1 
_G2: 
   ds.l 1 
_G3: 
   ds.l 1 
_G4: 
   ds.l 1 
 
  
   END 
 
 
