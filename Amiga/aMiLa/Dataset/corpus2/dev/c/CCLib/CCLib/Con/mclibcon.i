;------------ Macro for Metacomco assembler --------------
   XREF _CCLibBase

CCLIBREF  MACRO
   XDEF  _\1
_\1:
   move.l   _CCLibBase,a6
   jmp	    \2(a6)
   end
   ENDM


