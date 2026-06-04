        SECTION code,CODE

        ; Lesson 02: labels name addresses.
        move.w  score(pc),d0     ; d0 = 1200
        moveq   #0,d1            ; clear all of d1 before loading one byte
        move.b  lives(pc),d1     ; d1 = 3
        add.w   d1,d0            ; d0 = score + lives
        rts

score:  dc.w    1200
lives:  dc.b    3
        even

