        SECTION code,CODE

        ; Lesson 06: choose a state from lives.
        ; Result: d1 = 0 means dead, d1 = 1 means alive.
        moveq   #0,d0
        move.b  player_lives(pc),d0

        cmpi.w  #0,d0
        beq.s   .dead

        moveq   #1,d1
        bra.s   .done

.dead:
        moveq   #0,d1

.done:
        move.l  d1,d0
        rts

player_lives:
        dc.b    2
        even

