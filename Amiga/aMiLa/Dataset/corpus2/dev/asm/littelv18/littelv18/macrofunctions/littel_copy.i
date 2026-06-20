; internal LITTEL 68k v19 macros © Leif Salomonsson 2000

; not used yet

; *** COPY macros **************

; if it werent for the complexity of
; the 68k instructions, this would be much easier!
; well.. if speed wasnt important it could be simpler.

; theese macros support 9 different sources/destinations :
; Rx
; AxPtrL
; AxPtrW
; AxPtrB
; GV
; LV
; PA
; ST (2ST=dest, ST2=source)
; DV (only as source)


; combinations not directly supported :
; AxPtrW2AxPtrL
; AxPtrW2GV
; AxPtrW2LV
; AxPtrW2PA
; AxPtrW2ST
; AxPtrB2AxPtrL
; AxPtrB2AxPtrW
; AxPtrB2GV
; AxPtrB2LV
; AxPtrB2PA
; AxPtrB2ST
; combine macros and use temporary regs
; for those combinations.

; SOURCE : Rx

Rx2Rx macro ; reg, reg
   code
   move.l \1, \2
   endm

Rx2GV macro ; reg, gvar
   code
   move.l \1, \2(a4)
   endm

Rx2LV macro ; reg, lvar, procname
   code
   move.l \1, -PROC_\3_var_\2(A5)
   endm

Rx2PA macro ; reg, par, procname
   code
   move.l \1, PROC_\3_par_\2(A5)
   endm

Rx2AxPtr macro ; .size, reg, ax, ptroffset
   code
   move.\0 \1, \3(\2)
   endm

Rx2ST macro ; reg
   code
   move.l \1, -(a7)
   endm

; SOURCE AxPtrL

AxPtrL2Rx macro ; ax, ptroffset, reg
   code
   move.l \2(\1), \3
   endm

AxPtrL2GV macro ; ax, ptroffset, gvar
   code
   move.l \2(\1), \3(a4)
   endm

AxPtrL2LV macro ; ax, ptroffset, lvar, procname
   code
   move.l \2(\1), -PROC_\4_var_\3(A5)
   endm

AxPtrL2PA macro ; ax, ptroffset, par, procname
   code
   move.l \2(\1), PROC_\4_par_\3(A5)
   endm

AxPtrL2AxPtrL macro ; ax1, ptroffset1, ax2, ptroffset2
   code
   move.l \2(\1), \4(\3)
   endm

AxPtrL2AxPtrW macro ; ax1, ptroffset1, ax2, ptroffset2
   code
   move.w \2(\1), \4(\3)
   endm

AxPtrL2AxPtrB macro ; ax1, ptroffset1, ax2, ptroffset2
   code
   move.b \2(\1), \4(\3)
   endm

AxPtrL2ST macro ; ax, ptroffset
   code
   move.l \2(\1), -(a7)
   endm

; SOURCE : AxPtrW

AxPtrW2Rx macro ; ax, ptroffset, reg
   code
   move.l #0, \3
   move.w \2(\1), \3
   endm

AxPtrW2AxPtrW macro ; ax1, ptroffset1, ax2, ptroffset2
   move.w \2(\1), \4(\3)
   endm

AxPtrW2AxPtrB macro ; ax1, ptroffset1, ax2, ptroffset2
   code
   move.b \2(\1), \4(\3)
   endm

; SOURCE AxPtrB

AxPtrB2Reg macro ; ax, ptroffset, reg
   code
   move.l #0, \3
   move.b \2(\1), \3
   endm

AxPtrB2AxPtrB macro ; ax1, ptroffset1, ax2, ptroffset2
   code
   move.b \2(\1), \4(\3)
   endm

;SOURCE GV

GV2Rx macro ; gvar, reg
   code
   move.l \1(a4), \2
   endm

GV2GV macro ; gvar, gvar
   code
   move.l \1(a4), \2(a4)
   endm

GV2LV macro ; gvar, lvar, procname
   code
   move.l \1(a4), -PROC_\3_var_\2(A5)
   endm

GV2PA macro ; gvar, par, procname
   code
   move.l \1(a4), PROC_\3_par_\2(A5)
   endm

GV2AxPtr macro ; .size, gvar, ax, ptroffset
   code
   move.\0 \1(a4), \3(\2)
   endm

GV2ST macro ; gvar
   code
   move.l \1(a4), -(a7)
   endm

; SOURCE : LV

LV2Rx macro ; lvar, reg, procname
   code
   move.l -PROC_\3_var_\1(A5), \2
   endm

LV2GV macro ; lvar, gvar, procname
   code
   move.l -PROC_\3_var_\1(A5), \2(a4)
   endm

LV2LV macro ; lval, lvar, procname
   code
   move.l -PROC_\3_var_\1(A5), -PROC_\3_var_\2(A5)
   endm

LV2PA macro ; lvar, par, procname
   code
   move.l -PROC_\3_var_\1(A5), PROC_\3_par_\2(A5)
   endm

LV2AxPtr macro ; .size, lvar, ax, ptroffset, procname
   code
   move.\0 -PROC_\4_var_\1(A5), \3(\2)
   endm

LV2ST macro ; lvar, procname
   code
   move.l -PROC_\2_var_\1(A5), -(a7)
   endm

PA2Rx macro ; par, reg, procname
   code
   move.l PROC_\3_par_\1(A5), \2
   endm

PA2GV macro ; par, gvar, procname
   code
   move.l PROC_\3_par_\1(A5), \2(a4)
   endm

PA2LV macro ; pal, lvar, procname
   code
   move.l PROC_\3_par_\1(A5), -PROC_\3_var_\2(A5)
   endm

PA2PA macro ; par, par, procname
   code
   move.l PROC_\3_par_\1(A5), PROC_\3_par_\2(A5)
   endm

PA2AxPtr macro ; .size, par, ax, ptroffset, procname
   code
   move.\0 PROC_\4_par_\1(A5), \3(\2)
   endm

PA2ST macro ; par, procname
   code
   move.l PROC_\2_par_\1(A5), -(a7)
   endm

; SOURCE : (a7)+

ST2Rx macro ; reg
   code
   move.l (a7)+, \1
   endm

ST2AxPtrL macro ; ax, ptroffset
   code
   move.l (a7)+, \2(\1)
   endm

ST2GV macro ; gvar
   code
   move.l (a7)+, \1(a4)
   endm

ST2LV macro ; lvar, procname
   code
   move.l (a7)+, -PROC_\2_var_\1(A5)
   endm

ST2PA macro ; par, procname
   code
   move.l (a7)+, PROC_\2_par_\1(A5)
   endm

; SOURCE : DV

DV2Rx macro ; dv, reg
   code
   move.l #\1, \2
   endm

DV2AxPtr macro ; .size, dv, ax, ptroffset
   code
   move.\0 #\1, \2(\1)
   endm

DV2GV macro ; dv, gv
   code
   move.l #\1, \2(a4)
   endm

DV2LV macro ; dv, lv, procname
   code
   move.l #\1, -PROC_\3_var_\2(A5)
   endm

DV2PA macro ; dv, par, procname
   code
   move.l #\1, PROC_\3_par_\2(A5)
   endm

DV2ST macro ; dv
   code
   move.l #\1, -(a7)
   endm














