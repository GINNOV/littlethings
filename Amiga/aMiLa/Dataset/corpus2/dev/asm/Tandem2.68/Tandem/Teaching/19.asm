* 19.asm    NARG, conditional assembly     version 0.00   1.9.97

* sum of 0 to 4 things to register \1
sum: macro
 moveq #0,\1
 IFGE NARG-2
 add.l #\2,\1
 IFGE NARG-3
 add.l #\3,\1
 IFGE NARG-4
 add.l #\4,\1
 IFGE NARG-5
 add.l #\5,\1
 ENDC
 ENDC
 ENDC
 ENDC
 ENDM

* do some sums
 sum d0,4,5
 sum d1
 sum d2,5,6,7
 sum d3,-1,2,0
 sum d4,1,2,3,4
 rts
