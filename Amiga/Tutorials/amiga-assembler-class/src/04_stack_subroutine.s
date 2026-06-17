        SECTION code,CODE

        ; Lesson 04: call a helper that doubles d0.
        moveq   #21,d0
        bsr.s   double_d0
        rts

double_d0:
        add.l   d0,d0
        rts

