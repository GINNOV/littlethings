        section code,code

start:
        moveq   #7,d0
        move.w  d0,$100       ; throwaway watchpoint target
        rts
