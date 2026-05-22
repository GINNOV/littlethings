* 68020+ addressing modes without []

 rts                     ;4E75
fred:
 nop                     ;4E71

 tst.l fred(pc)          ;4ABAFFFC
 tst.l (fred.b,pc)       ;4ABAFFF8
 tst.l (fred.w,pc)       ;4ABAFFF4
 tst.l (fred.l,pc)       ;4ABB0170FFFFFFF0
 tst.l (fred,zpc)        ;4ABB01E0FFE8
 tst.l (fred.w,zpc)      ;4ABB01E0FFE2
 tst.l (fred.l,zpc)      ;4ABB01F000000002
 tst.l (fred.b,pc,d1)    ;4ABB10D4
 tst.l (fred.w,pc,d1)    ;4ABB1120FFD0
 tst.l (fred.l,pc,d1)    ;4ABB1130FFFFFFCA
 tst.l (fred,zpc,d1)     ;4ABB11A0FFC2
 tst.l (fred.b,zpc,d1)   ;4ABB10BC
 tst.l (fred.w,zpc,d1)   ;4ABB11A0FFB8
 tst.l (fred.l,zpc,d1)   ;4ABB11B000000002
 tst.l joan(pc)          ;4ABA0050
 tst.l (joan.b,pc)       ;4ABA004C
 tst.l (joan.w,pc)       ;4ABA0048
 tst.l (joan.l,pc)       ;4ABB017000000044
 tst.l (joan,zpc)        ;4ABB01E00003C
 tst.l (joan.w,zpc)      ;4ABB01E000036
 tst.l (joan.l,zpc)      ;4ABB01F0000000A8
 tst.l (joan.b,pc,d1)    ;4ABB1028
 tst.l (joan.w,pc,d1)    ;4ABB11200024
 tst.l (joan.l,pc,d1)    ;4ABB11300000001E
 tst.l (joan,zpc,d1)     ;4ABB11A00016
 tst.l (joan.b,zpc,d1)   ;4ABB1010
 tst.l (joan.w,zpc,d1)   ;4ABB11A0000C
 tst.l (joan.l,zpc,d1)   ;4ABB11B0000000A8
joan:
 tst.l (pc,d1)           ;4ABB1110
 tst.l (zpc,d1)          ;4ABB1190
 tst.l (pc)              ;4ABAFFFE
 tst.l (zpc)             ;4ABB01D0

jack:
 nop                            ;4E71
 lea (jack,a1,d3),a5            ;4BF13130000000B8
 lea (jill.l,a3,d1),a5          ;4BF311300000012C
 lea ($1234,a1,d3.l),a5         ;4BF139201234
 lea ($1234.w,a1,d3*1),a5       ;4BF131201234
 lea ($1234.l,a1,d3*2),a5       ;4BF1333000001234
 lea ($12345678,a1,d3.l*4),a5   ;4BF13D3012345678
 lea ($12345678.l,a1,d3.l*8),a5 ;4BF13F3012345678
 lea (jack,a1.l),a5             ;4BF099B0000000B8
 lea (jill.l,a1.w),a5           ;4BF091B00000012C
 lea ($1234,d1),a5              ;4BF011A01234
 lea ($12345678,a1*2),a5        ;4BF093B012345678
 lea (jack,a1),a5               ;4BF10170000000B8
 lea (jill.l,a1),a5             ;4BF101700000012C
 lea ($1234,a1),a5              ;4BE91234
 lea ($12345678.l,a1),a5        ;4BF1017012345678
 lea (a1,d3),a5                 ;4BF13000
jill:
