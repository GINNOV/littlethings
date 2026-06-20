* test expression evaluation

 nop
fred:
 nop
 move.l jill,d0   ;203900000002
 rts

* hex conts 2/4 chrs s/be sign ext
jack: equ $8      ;00000008
mary: equ $80     ;FFFFFF80
bill: equ $080    ;00000080
june: equ $8000   ;FFFF8000
dave: equ $08000  ;00008000

* a relative EQU
jill: equ fred    ;00000002 rel
