        SECTION code,CODE

player_lives equ 0
player_level equ 1
player_score equ 2
player_size  equ 4

        ; Lesson 07: a record is memory plus offsets.
        lea     player(pc),a0
        move.w  player_score(a0),d0
        add.w   #300,d0
        move.w  d0,player_score(a0)
        rts

player:
        dc.b    3          ; lives
        dc.b    1          ; level
        dc.w    1200       ; score

