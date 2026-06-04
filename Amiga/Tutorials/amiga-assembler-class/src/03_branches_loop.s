        SECTION code,CODE

        ; Lesson 03: add 5 + 4 + 3 + 2 + 1.
        moveq   #0,d0            ; total
        moveq   #5,d1            ; counter

.loop:
        add.w   d1,d0
        subq.w  #1,d1
        bne.s   .loop

        rts

