* try this

Fred MACRO
 moveq \1,d0
 moveq \2,d1
 moveq \3,d2
 moveq \4,d3
 moveq \5,d4
 moveq \6,d5
 moveq \7,d6
 moveq \8,d7
 move.w \9,a0
 move.w \10,a1
 IFGE NARG-11
 IFNC '\11','#11'
 move.w \11,a2
 ENDC
 ENDC
 ENDM

 Fred #1,#2,#3,#4,#5,#6,#7,#8,#9,#10,#11
 rts
