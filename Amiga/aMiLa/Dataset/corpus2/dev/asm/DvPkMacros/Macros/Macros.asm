
;*************************************************
;** Macros                                      **
;** © 1990,93,96 THOR-Software inc.             **
;** Version 1.17 23th July 1996                 **
;**---------------------------------------------**
;** This is a package of useful macros for the  **
;** DevPac assembler                            **
;** feel free to strip the comments             **
;** but leave every comments marked with an     **
;** asterisk (*) because they are printed       **
;** as error messages if something's getting    **
;** wrong                                       **
;*************************************************


;*************************************************
;** Global arguments                            **
;**---------------------------------------------**
;** If you define a label named                 **
;** SHORTSTACK                                  **
;** the stack gets only word aligned instead of **
;** long aligned.                               **
;** This takes less stack space, but slows the  **
;** code for the MC'20 and higher processors    **
;** somewhat down.                              **
;*************************************************


;*************************************************
;** Some useful macros for modifying the        **
;** condition codes in 6502 style               **
;*************************************************

sec     Macro           ;set carry
        ori #$01,ccr
        Endm
        
clc     Macro           ;clear carry
        andi #$fe,ccr
        Endm
        
sez     Macro           ;set zero
        ori #$04,ccr
        Endm
        
clz     Macro           ;clear zero
        andi #$fb,ccr
        Endm
        
sen     Macro           ;set negative
        ori #$08,ccr
        Endm
        
cln     Macro           ;clear negative
        andi #$f7,ccr
        Endm

noz     Macro           ;invert zero
        eor #$04,ccr
        EndM

sev     Macro           ;set overflow
        ori #$02,ccr
        Endm
        
clv     Macro           ;clear overflow
        andi #$fd,ccr
        Endm
        
clx     Macro           ;clear X
        andi #$ef,ccr
        Endm

sex     Macro           ;set X
        ori #$10,ccr
        EndM

;*************************************************
;** the next lines clear internal counters      **
;** do not touch them                           **
;*************************************************
        
_sc     set 0           ;the stack counter
_rc     set 0           ;counter for registers
_re     set 0           ;level counter for registers
_fc     set 0           ;counter for loops
_fe     set 0           ;level counter for loops
_pc     set 0           ;parameter counter for C style functions
_pe     set 0           ;level counter for C style functions
_pm     set 0           ;counts removed parameters
_bs     set 0           ;space taken by global static variables

;*************************************************
;** some macros for stack management            **
;** mainly internal use                         **
;** but also register framing                   **
;*************************************************

        ifd __G2        ;this works only for DevPac 2 and better

reserve Macro           ;reserve room on the stack
        iflt \1
                fail    ;(*) argument must be greater than zero
                mexit
        endc
        
        ifd SHORTSTACK
_si\<_sc> set (\1+((\1)&1))
        elseif
_si\<_sc> set ((\1+3)&-4)
        endc
        
        ifne \1
                ifle _si\<_sc>-8
                        subq.l #_si\<_sc>,a7
                elseif
                        lea -_si\<_sc>(a7),a7
                endc
        endc
_sc     set _sc+1
        Endm

;Example:
;       reserve 100
;       Reserve 100 bytes of stack space, relative to a7.
;       address it with dist(a7), dist is positive
;
        
restore Macro           ;restore stack space
        ifle _sc
                fail    ;(*) illegal nesting
                mexit   
        endc
_sc     set _sc-1
        ifne _si\<_sc>
                ifle _si\<_sc>-8
                         addq.l #_si\<_sc>,a7
                elseif
                        lea _si\<_sc>(a7),a7
                endc
        endc
        EndM

;Example:
;       reserve 100             reserve stack space
;        ....
;       restore                 restore stack
;
;       reserve and restore nest, btw
        

extend Macro            ;Extend the memory allocated with "reserve" by n bytes
        ifle _sc
                fail
                mexit   ;(*) nest failure: "reserve" missing
        endc
        
        ifd SHORTSTACK
_si\<_sc> set (\1+((\1)&1))
        elseif
_si\<_sc> set ((\1+3)&-4)
        endc
        
        ifle _si\<_sc>-8
                subq.l #_si\<_sc>,a7
        elseif
                lea -_si\<_sc>(a7),a7
        endc
_sh     set _sc-1
_si\<_sh> set _si\<_sh>+_si\<_sc>
        EndM

;Example:
;               reserve 100     allocate 100 bytes
;               extend  50      allocate another 50 bytes in the same stack frame, so get 150
;               restore         give 100+50 bytes back
        

shrink Macro            ;shrink the stack space by n bytes, opposide to extend
        ifle _sc
                fail    ;(*) nest failure: reserve missing
                mexit
        endc
        
        ifd SHORTSTACK
_si\<_sc> set (\1+((\1)&1))
        elseif
_si\<_sc> set ((\1+3)&-4)
        endc
        
        ifle _si\<_sc>-8
                addq.l #_si\<_sc>,a7
        elseif
                lea _si\<_sc>(a7),a7
        endc
_sh     set _sc-1
_si\<_sh> set _si\<_sh>-_si\<_sc>
        iflt _si\<_sh>
                fail    ;(*) shrink out of range
                mexit
        endc
        EndM
;Example:
;               reserve 100     reserve 100 bytes
;               extend 50       get another 50 bytes in the same frame
;               shrink 75       give 75 bytes back
;               restore         give the remaining 75 bytes back

        
_lastget Macro                  ;internal macro for stack relative addressing
        ifne _sh-_sc
_sj     set _sj+_si\<_sh>
_sh     set _sh+1
        _lastget
        endc
        EndM
        
loadbase Macro                  ;get base address of a previously loaded stack frame
        iflt \1
                fail    ;(*) out of range
                mexit
        endc
_sh     set _sc-\1
        iflt _sh
                fail    ;(*) nest failure: reserve missing
                mexit
        endc
_sj     set 0
        _lastget
        lea _sj(a7),\2
        EndM

;Example:
;               reserve 100
;                reserve 50
;                loadbase 1,a6  load base address of the first stack frame into a6
;                               a6 is now relative to the 100 bytes,
;                               a7 to the 50 bytes
;                restore
;               restore         give everything back

        
saveregs Macro                  ;save registers to the stack
_rc     set _rc+1               ;unique id
_re     set _re+1               ;counts levels
_rn\<_re> set _rc               ;level->number
_ri\<_rc> reg \1
        movem.l \1,-(sp)
        EndM

;Example:
;               saveregs d2-d3/a2-a3/a6
;
;               Unlike the usual macros, this call DOES nest!
;
;
        
loadregs Macro                  ;load macros from the stack
        ifle _re
                fail            ;(*) nest failure: saveregs missing
                mexit
        endc
_rt     set _rn\<_re>
        movem.l (sp)+,_ri\<_rt>
_re     set _re-1
        EndM

;Example:
;               saveregs d2-d3/a2-a3/a6
;                ...
;                saveregs d2-d4         yes, this NESTS!
;                ...
;                loadregs               reload the first set
;                ...
;               loadregs                reload the second set


;*************************************************
;** Automatic loop support                      **
;** do/while loops & for/next loops             **
;*************************************************

for     Macro           ;a popular for next loop, counts downwards in words
_fc     set _fc+1       ;unique id
_fe     set _fe+1       ;level counter
_fn\<_fe> set _fc       ;level to number
        ifc '','\1'                     ;without parameters
                bra.\0 ._fi\<_fc>_loop
        elseif
                move.\0 \1-1,\2         ;(*) only immediate adressing
        endc
._fi\<_fc>_do:
        EndM

;Examples
;       for             start of the loop, counter already loaded
;                       zero is a legal counter value, the body isn't
;                       executed then
;       for.s           start of the loop, short loop, counter already loaded
;
;       for.l #9,d0     start loop, load counter (9 loops here)
;                       this one gets optimized (one branch less)
;                       but allows only immediate addressing to
;                       load the counter register (d0 here)
;
        
next    Macro           ;end of the loop
        ifle _fe
                fail    ;(*) nest failure: for missing
                mexit
        endc
_ft     set _fn\<_fe>
._fi\<_ft>_loop:
        ifc '','\1'
                fail    ;(*) counter register missing
                mexit
        endc
        ifc '','\2'
._fi\<_ft>_cont:
                dbra \1,._fi\<_ft>_do
        elseif          ;(*) cont invalid with condition
                db\1 \2,._fi\<_ft>_do
        endc
._fi\<_ft>_exit:
_fe     set _fe-1
        EndM
        
;Examples
;       next d0         end of a for loop with counter register d0
;       next eq,d0      end of a loop, terminate the loop if eq OR
;                       counted down to zero
;
;Full example:
;       for.l #12,d0
;        clr.l (a0)+
;       next d0         clears 12 adjacent long words
;                       all labels are generated by the macro set
;
;       remember, all this looping stuff NESTS!

break   Macro           ;terminates a for or do loop immediately, jumps behind the final comand
        ifle _fe        
                fail    ;(*) break not in a loop body
                mexit
        endc
_ft     set _fn\<_fe>
        ifc '','\1'     ;without condition
                bra.\0 ._fi\<_ft>_exit
        elseif
                b\1.\0 ._fi\<_ft>_exit
        endc
        EndM

;Examples
;       for.l #9,d0
;        ...
;        break          terminate loop now
;
;       next d0
;
;       break.s         break, short distances
;       break.s eq      break if the eq flag is set
;

cont    Macro           ;continue with the next iteration
        ifle _fe        
                fail    ;(*) cont not in a loop body
                mexit
        endc
_ft     set _fn\<_fe>
        ifc '','\1'     ;without condition
                bra.\0 ._fi\<_ft>_cont          ;(*) cont impossible with next & condition
        elseif
                b\1.\0 ._fi\<_ft>_cont          ;(*) cont impossible with next & condition
        endc
        EndM

;Examples
;
;       for.l #8,d0
;        ...
;        cont.s eq              next iteration if Z flag is set
;        ...
;       next d0                 end of loop
;

reloop  Macro                   ;redo looping
        ifle _fe        
                fail            ;(*) reloop not in a loop body
                mexit
        endc
_ft     set _fn\<_fe>
        ifc '','\1'     ;without condition
                bra.\0 ._fi\<_ft>_do
        elseif
                b\1.\0 ._fi\<_ft>_do
        endc
        EndM

;Examples
;
;       reloop          rerun this iteration
;       reloop.s        rerun, short jump
;       reloop.s cc     rerun if the carry flag is cleared
;
;       The difference between reloop and cont is that cont starts
;       the next iteration of a loop (so, the counter is decremented)
;       while reloops reruns the loop again with the old counter
;       there is NO difference between reloop and cont for do/while
;       style loops


do      Macro           ;start of a loop, execute it at least once
_fc     set _fc+1       ;increment id
_fe     set _fe+1       ;level counter
_fn\<_fe> set _fc       ;level->number
._fi\<_fc>_do:
._fi\<_fc>_cont:
        EndM


repeat  Macro           ;start a loop, possibly no execution at all
_fc     set _fc+1       ;increment id
_fe     set _fe+1       ;level counter
_fn\<_fe> set _fc       ;level->number
        bra.\0 ._fi\<_fc>_loop  ;jump to the end of the loop
._fi\<_fc>_do:
._fi\<_fc>_cont:
        EndM
        
while   Macro           ;end of a loop
        ifle _fe
                fail    ;(*) nest failure: No loop started
                mexit
        endc
_ft     set _fn\<_fe>
._fi\<_ft>_loop:
        b\1.\0 ._fi\<_ft>_do
._fi\<_ft>_exit:
_fe     set _fe-1       
        EndM

loop    Macro
        while.\0 ra
        EndM

;Examples:
;       do              start a loop....
;        ...
;       while.s eq      as long as the Z flag is set, short loop
;
;Full example: Travese an exec style list
;
;       lea lh_Head(a2),a0      ;get head node
;       do
;        move.l (a0),a0         ;get first node
;        tst.l (a0)             ;test if this is a real node or the end
;        break.s eq             ;abort if end of list reached
;
;        ...                    ;do something with the node
;       loop.s                  ;continue operation
;
;
;       repeat.s                ;short jump
;       ...
;       while.s eq              ;quite the same as the first example
;                               ;but checks the condition first before
;                               ;the loop is entered. A set Z flag
;                               ;will never enter the loop


;*************************************************
;** String macros                               **
;** implementations of some standard C functions**
;*************************************************

smove   Macro                   ;copy one string to another, like strcpy
        ifne NARG-2
                fail            ;(*) only two arguments
        endc
        
._sm\@: move.b (\1)+,(\2)+
        bne.s ._sm\@
        EndM    

;Examples
;       smove a0,a1             ;copy string *a0 to string *a1
;


strlen  Macro                   ;get the length of a string, excluding the NUL
        ifne NARG-2
                fail            ;(*) only two arguments
                mexit
        endc
        move.l \1,\2
._sl\@:
        tst.b (\1)+
        bne.s ._sl\@
        sub.l \1,\2
        not.l \2
        Endm

;Examples
;       strlen a0,d0            ;get the length of the string *a0 is
;                               ;pointing to and store it in d0
;                               ;*a0 points afterwards behind the NUL
;                               ;byte


;*************************************************
;** Calling C style functions with              **
;** arguments on the stack                      **
;*************************************************

_putarg Macro                   ;internal use macro, writes one argument
        ifgt \1
_pm             set 1           ;get one parameter

                ifnc '','\2'
                                                ;hier: parameter present
                        ifc '.l','\2'
_pm                             set 2           ;explicit size: longword
_pc                             set _pc+4
                        endc
                        ifc '.w','\2'
_pm                             set 2           ;explicit size: word
_pc                             set _pc+2
                        endc
                        ifc '.b','\2'
_pm                             set 2           ;explicit size: byte
_pc                             set _pc+2       ;a byte takes REALLY two bytes of stack!
                        endc
                        
                        ifeq _pm-2
                                ifc '\3',''
                                        fail    ;parameter missing
                                        mexit
                                endc
                                move\2 \3,-(sp) ;write it to the stack
                        elseif  
                                ifne _fl
                                        move.l \2,-(sp) ;default long
_pc                                     set _pc+4
                                elseif
                                        move.w \2,-(sp) ;default word
_pc                                     set _pc+2
                                endc
                        endc
        
                endc
        
_pe             set \1-_pm              ;now call this stuff recursively
                ifeq _pm-2
                        _putarg \<_pe>,\4,\5,\6,\7,\8,\9,\A,\B,\C,\D,\E,\F,\G,\H,\I,\J
                elseif
                        _putarg \<_pe>,\3,\4,\5,\6,\7,\8,\9,\A,\B,\C,\D,\E,\F,\G,\H,\I,\J
                endc
        
        endc
        endm
        
        
bcr     Macro                   ;call a C style function, use BSR
_pc     set 0
_fl     set 0
        _putarg 18,\J,\I,\H,\G,\F,\E,\D,\C,\B,\A,\9,\8,\7,\6,\5,\4,\3,\2
        bsr.\0 \1
        ifne _pc
        lea _pc(a7),a7
        endc
        EndM

jcr     Macro                   ;call a C style function, use JSR
_pc     set 0
_fl     set 0
        _putarg 18,\J,\I,\H,\G,\F,\E,\D,\C,\B,\A,\9,\8,\7,\6,\5,\4,\3,\2
        jsr \1
        ifne _pc
        lea _pc(a7),a7
        endc
        EndM

jtags   Macro                   ;a tag based library call with the tags as arguments
_pc     set 4
_fl     set 1
        clr.l -(a7)             ;TAG_END
        _putarg 17,\J,\I,\H,\G,\F,\E,\D,\C,\B,\A,\9,\8,\7,\6,\5,\4,\3
        move.l a7,\2
        jsr \1
        lea _pc(a7),a7
        EndM

;Examples:
;       jcr Handler,.l,#0,IO(a1)
;       call the handler functions with long arguments,
;       zero and the contents of IO(a1)
;       put these arguments on the stack and free the stack
;       afterwards
;
;       bcr.s TempFree,.l,a1,a5,.b,#0,.l,ExecBase
;       call the TempFree function with long arguments a1,a5
;       one byte argument #0 and a long argument ExecBase
;
;       all sizes default to word except for the tag based calls,
;       where the size defaults to long.
;       types must be given PRIOR to the arguments


;*************************************************
;** More tag call support                       **
;** (different style)                           **
;*************************************************

deftag  Macro                   ;start of a tag call
_pc     set 4
        clr.l -(a7)             ;TAG_END
        EndM
        
tag     Macro                   ;place a tag on the stack
        move.l \2,-(sp)         ;(*) illegal tag data
        move.l #\1,-(sp)        ;(*) illegal tag
_pc     set _pc+8
        EndM

itag    Macro                   ;place an indirect tag on the stack
        move.l \2,-(sp)         ;(*) illegal tag data
        move.l \1,-(sp)         ;(*) illegal tag
_pc     set _pc+8
        EndM
        
endtag  Macro                   ;end of a tag call and the call itself
        move.l a7,\2
        jsr \1
        lea _pc(a7),a7
        endM

;Examples:
;       deftag
;        tag TAG_Width,#320
;        tag TAG_Height,#200
;       endtag OpenWindwoTagList(a6),a0
;
;       the first paratemter to the tag macro is the type of the
;       tag, the second its value.
;       The endtag macro takes two arguments as well, the
;       tag function and the parameter where the tag list has to
;       be provided
;
;       The tag call expects an immediate number as its first parameter
;       whereas the itag call accepts any legal data, so registers are
;       valid here, too.


;*************************************************
;** More macros for C-style functions           **
;** this time the function header itself        **
;*************************************************

defarg  Macro           ;start of the argument description
        rsreset
_sh     set 0
_sj     set 0
        _lastget
        rs.l 1          ;reserve one long for the PC
        ifnc '','\1'
        rs.l \1         ;supply number of saved registers here
        endc    
        rs.b _sj        ;room reserved for auto variables
        EndM
        
arg     Macro           ;get the name of one argument
        ifc '','\0'
\1              rs.w 1
        elseif
\1              rs.\0 1
                ifc 'b','\0'
                        rs.b 1
                endc
        endc
        EndM
        
endarg  Macro           ;end of the argument list
        EndM    

;Examples for argument descriptions
;       saveregs d2-d3/a2
;       defarg 3        start of the arguments, three registers saved
;        arg buffer     one word, gets the name buffer
;        arg.l code     one longword
;        arg.w len      one word
;        arg.b char     one byte
;       endarg
;
;       move.l code(a7),d0      get the argument
;

;*************************************************
;** The next one is pretty handy:               **
;** variable definions for assembly language    **
;** in case you run out of registers            **
;** the variables are taken from the stack      **
;** and require the stack macros from above     **
;*************************************************

defvar  Macro           ;start of the variable list
        rsreset
        EndM

auto    Macro           ;define one auto (stack) variable, take it from the stack
        ifc     '','\2'
\1              rs.\0   1
        elseif
\1              rs.\0   \2
        endc
        EndM
        
static  Macro           ;define a static (BSS) variable
        ifc     '','\2'
_bc             set 1
        elseif
_bc             set \2
        endc
_bz     set 0
        ifc     'l','\0'
_bs     set (_bs+1)&$fffffffe
_bz             set 4
        endc
        ifc     'w','\0'
_bs     set (_bs+1)&$fffffffe
_bz             set 2
        endc
        ifc     'b','\0'
_bz             set 1
        endc
        ifeq    _bz
                fail    ;(*) illegal data size
                mexit
        endc
\1      =_bs
_bs     set     _bs+(_bc*_bz)
        EndM
        
extern  Macro           ;define an external variable
        xref    \1
        EndM

register Macro          ;define a register variable
\1      equr    \2
        EndM

endvar  Macro           ;end of the variable list
._vl\@  rs.b 0
        reserve ._vl\@
        EndM
        
freevar Macro           ;free stack space allocated by variables
        restore
        EndM

staticspace Macro
        ds.b _bs        ;reserve space for static variables
        EndM            ;should be called only once in the program
                        ;or you're wasting space

;One example definition of a function that uses auto variables
;Foo:
;       saveregs d2-d3/a2       save local registers
;       defvar                  start of variable definitions
;        auto.w count           ;a counter
;        auto.l help,4          ;four longs
;        auto.b char            ;one character
;        auto.l inc             ;one long
;        static.l save          ;one static variable
;        register.w cinc,d0     ;a register variable
;       endvar                  ;that's it!
;
;       move.l d0,inc(a7)       ;set the inc-variable
;       move.w d1,count(a7)     ;set count
;       do
;        ...
;        add.l inc(a7),d2       ;increment d2
;       while.s cc              ;as long as no overflow
;       ...
;       freevar                 ;free variables
;       loadregs                ;get registers
;       rts
;
; One note: Variable names are (sorry to say that, but such is life)
; GLOBAL to the module. You've to invent some unique names for
; them. A popular choice is to use a shortcut of the procedure name
; and an underscore, like "foo_inc" instead of "inc"

        endc            ;the remaining stuff is valid for all assemblers

;*************************************************
;** longword bit field addressing               **
;** for adress-register indirect                **
;** maybe very special, but I need them         **
;*************************************************
btstm   Macro                   ;test one bit in a longword
        btst #(\1)&$7,(3^((\1)>>3))+\2
        Endm
        
bclrm   Macro                   ;clear one bit in a longword
        bclr #(\1)&$7,(3^((\1)>>3))+\2
        Endm    
        
bsetm   Macro                   ;set one bit in a longword
        bset #(\1)&$7,(3^((\1)>>3))+\2
        Endm    
        
bchgm   Macro                   ;change one bit in a longword
        bchg #(\1)&$7,(3^((\1)>>3))+\2
        Endm

bnegm   Macro                   ;like btstm, but returns the inverted result
        btst #(\1)&$7,(3^((\1)>>3))+\2
        noz
        Endm    

;Examples:
;               btstm cn_Test,cn_Flags(a5)
;               test the bit named "cn_Test" in the long word bit field
;               cn_Flags(a5)
;               The MSB of byte 0 is bit 31, the LSB of byte 3 is bit 0
;

;*************************************************
;** List support macros                         **
;** partially stolen from exec/nodes.i          **
;*************************************************

NewList         Macro   ;Initialize a list. Much shorter than a function call
        move.l \1,8(\1)
        addq.l #4,\1
        clr.l (\1)
        move.l \1,-(\1)
        endm
;provide an address register as argument that points to the list structure

;The next macros take the same arguments as the exec functions of the
;same names, so mostly *a1 for the node pointer and *a0 for the
;list pointer. There's currently no way of using other registers
;even though the modification would be trivial

AddHead         Macro           ;add node *a1 to the top of list *a0
        MOVE.L  (A0),D0
        MOVE.L  A1,(A0)
        MOVEM.L D0/A0,(A1)
        MOVE.L  D0,A0
        MOVE.L  A1,4(A0)
        ENDM

AddTail         Macro           ;add node *a1 at the end of list *a0
        ADDQ.L  #4,A0
        MOVE.L  4(A0),D0
        MOVE.L  A1,4(A0)
        EXG     D0,A0
        MOVEM.L D0/A0,(A1)
        MOVE.L  A1,(A0)
        ENDM

Remove          Macro           ;remove node *a1 from a list
        MOVE.L  (A1)+,A0
        MOVE.L  (A1),A1
        MOVE.L  A0,(A1)
        MOVE.L  A1,4(A0)
        ENDM

RemHead         Macro           ;remove the head of a list, return ptr in d0
        MOVE.L  (A0),A1
        MOVE.L  (A1),D0
        BEQ.S   .__remhead\@
        MOVE.L  D0,(A0)
        EXG.L   D0,A1
        MOVE.L  A0,4(A1)
.__remhead\@:
        ENDM


RemTail         Macro           ;remove the tail of a list, return ptr in d0
        MOVE.L  8(A0),A1
        MOVE.L  4(A1),D0
        BEQ.S   .__remtail\@
        MOVE.L  D0,8(A0)
        EXG.L   D0,A1
        MOVE.L  A0,(A1)
        ADDQ.L  #4,(A1)
.__remtail\@:
        ENDM


InsertAfter     Macro           ;insert node *a1 behind node *a0, no special cases, *a0 must be a valid node
        move.l (a0),d0
        movem.l d0/a0,(a1)
        move.l a1,(a0)
        move.l d0,a0
        move.l a1,4(a0)
        EndM

InsertBefore    Macro           ;insert node *a1 in front of *a0, no special cases, *a0 must be a valid node
        move.l 4(a0),d0
        move.l a1,4(a0)
        exg.l a0,d0
        movem.l d0/a0,(a1)
        move.l a1,(a0)
        EndM

;That's all folks!

