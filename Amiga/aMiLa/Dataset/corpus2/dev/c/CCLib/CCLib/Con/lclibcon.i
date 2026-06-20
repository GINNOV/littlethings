; -------- Macro for Lattice Assembler -----
CCLIBREF macro
   xref _CCLibBase
   section text,code
   xdef  _\1
_\1:
   move.l   _CCLibBase,a6
   jmp	    \2(a6)
   end
   endm


