
;Display last key pressed
;Written by John Grinham,
;           266 Tor st
;           Toowoomba, Queensland
;           Australia
;
;Version 1.1, 29-11-91 (a beginners experiment)
;Compiled with Public Domain Assembler, A68K
;                            Linker   , Blink
;                            Editor   , AZ
;
;       exec.library equates
;
execbase        =       4       ;address of exec.library
openlib         =       -408    ;address of open library function
closelib        =       -414    ;address of close library function
;
;       dos.library equates
;
write           =       -48     ;address of dos.library function write
mode_old        =       1005    ;mode for window
open            =       -30     ;addr of dos.library open a file function
close           =       -36     ;addr of dos.library close a file function
;
;       hardware equates
;
lastkey         =       $bfec01 ;hardware register address

init:
        move.l  execbase,a6     ;get address of exec.library in a6
        lea     doslib(pc),a1   ;pointer to name 'dos.library'
        moveq   #0,d0           ;version
        jsr     openlib(a6)     ;load dos.library
        move.l  d0,dosbase      ;store address of dos.library
        beq     quit           ;go here if something wrong
        lea     consul(pc),a1   ;addr of definition of window
        move.l  #mode_old,d0    ;mode for write function
        jsr     openfile        ;open a window
        beq     quit           ;any quits ?
        move.l  d0,conhandle    ;no ! then save addr of window handle
next:
        jsr     readreg         ;read hardware register
        cmp.b   #$75,d0         ;has ESC been pressed
        beq     quit
        jsr     convert         ;convert to ASCII
        jsr     printstring     ;print string to screen
        bra     next            ;loop to hardware register read
quit:
        move.l  conhandle,d1    ;close this one
        move.l  dosbase,a6
        jsr     close(a6)

        move.l  execbase,a6     ;addr of exec.library
        move.l  dosbase,a1      ;which library will we shut?
        jsr     closelib(a6)    ;close it!
        rts
openfile:
        move.l  a1,d1           ;copy a1 to d1
        move.l  d0,d2           ;copy d0 to d2
        move.l  dosbase,a6      ;addr of dos.library in a6
        jsr     open(a6)        ;open
        tst.l   d0
        rts
readreg:
        move.b  lastkey,d0      ;get key
        move.b  d0,d1           ;copy to d1
        rts                     ;finished here
convert:
        jsr     lowfour         ;convert lower four bits to ASCII
        move.b  d1,d0           ;back to origional
        jsr     highfour        ;convert higher four bits to ASCII
        rts                     ;finished here too!
lowfour:
        and.b   #15,d0          ;drop high four bits
        jsr     alpha           ;go for conversion
        move.b  d0,parttwo      ;store 2nd part
        rts                     ;it's over
highfour:
        ror.b   #4,d0           ;rotate till 1 becomes 16
        and.b   #15,d0          ;drop high four again
        jsr     alpha
        move.b  d0,partone      ;store first four bits
        rts                     ;no more
alpha:
        cmp.b   #9,d0           ;compare to nine
        bls     numeric         ;jump if nine or less
        add.b   #55,d0
        rts                     ;home sweet home
numeric:
        add.b   #48,d0          ;make ASCII char
        rts                     ;go home

printstring:
        move.l  #string,d0      ;watch string variable
        movem.l d0-d7/a0-a6,-(sp)       ;save all registers
        move.l  d0,a0           ;copy to a0
        move.l  a0,d2           ;copy to d2
        clr.l   d3              ;set to zero
ploop:
        tst.b   (a0)+
        beq     pmsg2
        addq.l  #1,d3           ;get count of characters
        bra     ploop
pmsg2:
        move.l  conhandle,d1
        move.l  dosbase,a6
        jsr     write(a6)
        movem.l (sp)+,d0-d7/a0-a6
        rts

string:
        dc.b    '  Press ESC to exit  ->'
partone:
        dc.b    0
parttwo:
        dc.b    0
        dc.b    '<-     '
        dc.b    13,0            ;CR after to maintain same line
        even                    ;word or long reads must be at
                                ;an EVEN address
dosbase:
        dc.l    0
doslib:
        dc.b    "dos.library",0
        even
conhandle:
        dc.l    0
consul:
        dc.b    'CON:0/100/400/50/* DISPLAY HEX *',0
        even

        end
