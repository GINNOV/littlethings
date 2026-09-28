        section code,code

start:
        moveq   #0,d0          ; expected result: 5
        moveq   #5,d1          ; deliberate bug: DBRA runs six times

count_loop:
        addq.l  #1,d0
        dbra    d1,count_loop

        rts
