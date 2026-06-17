        SECTION code,CODE

        ; Lesson 01: registers as explicit variables.
        ; Trace d0 after every instruction.
        moveq   #10,d0
        addq.l  #7,d0
        subq.l  #2,d0
        rts

