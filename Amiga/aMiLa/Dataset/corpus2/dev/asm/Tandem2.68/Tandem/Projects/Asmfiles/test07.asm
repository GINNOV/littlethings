* test addr tfr

* lines without ; or ; too soon
* (but will assemble ok, for Amiga .i's)

 moveq #20,d0    ignores lack of ;
 moveq #20,d0;   ignores ; without spc

* check ' and " assembly

 move.l #20,d0         ;$00000014
 move.l #'abcd',d0     ;abcd
 move.l #'a"cd',d0     ;a"cd
 move.l #'a''cd',d0    ;a'cd
 move.l #'a cd',d0     ;a cd
 move.l #'''''''''',d0 ;''''
 move.l #"abcd",d0     ;abcd
 move.l #"a'cd",d0     ;a'cd
 move.l #"a""cd",d0    ;a"cd
 move.l #"a cd",d0     ;a cd
 move.l #"""""""""",d0 ;""""

* check <...> rules

fred: macro
 move.l #\1cd',d0      ;abcd
 move.l #\2ef",d0      ; 'ef
 move.l #\3,d0         ;'bc'
 endm

 fred <'ab>,<" '>,'''bc'''

* check ranges accepted as .B
 dc.b $00000080 ;$000000 can have any
 dc.b $0000007F
 dc.b $FFFFFF80 ;$FFFFFF can have 80-FF

* check ranges accepted as .W
 dc.w $00008000 ;$0000 can have any
 dc.w $00007FFF
 dc.w $FFFF8000 ;$FFFF can have 8000-FFFF

* check that label of DS.W/DC.W is word-aligned
 dc.b $11
ev1: dc.w $2222 ;ev1 s/be rel addr after fill byte
 dc.b $33
ev2: ds.w 1     ;ev2 s/be rel addr after fill byte

ev3: equ ev1    ;value must be even 0064
ev4: equ ev2    ;value must be even 0068
