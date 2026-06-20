* relative addresses (set 1st sundry pref to "no" before compiling)
* do NOT run - for testing assembly only

 mc68881
 mc68020

bill:
 fbeq.w  fred    ;F2810022
 fbeq.l  fred    ;F2C10000001E
 fbne    fred    ;F28E0018
 fbeq    bill    ;F281FFF0
 fdbeq   d0,fred ;F2480001000E
 fdbne   d0,fred ;F248000E0008
 fdbeq   d0,bill ;F2480001FFDE
fred:
 beq.b  jack     ;672E
 beq.w  jack     ;6700002C
 beq.l  jack     ;67FF00000028
 bne    jack     ;66000022
 beq    fred     ;67EE
 bsr.b  jack     ;611C
 bsr.w  jack     ;6100001A
 bsr.l  jack     ;61FF00000016
 bsr    jack     ;61000010
 bsr    fred     ;61DC
 dbeq   d0,jack  ;57C8000A
 dbne   d0,jack  ;56C80006
 dbeq   d0,fred  ;57C8FFD2
jack:

 end
