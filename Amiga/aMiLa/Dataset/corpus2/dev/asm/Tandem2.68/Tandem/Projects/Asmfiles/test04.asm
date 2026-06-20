* 68020+ addressing modes with ([])

stt:
sue: equ $1111
jan: equ $11112222

 rts                       ;4E75

fred:
 nop                       ;4E71
bill:
 nop                       ;4E71

 tst.l ([sue,a4],d1,jan.l)             ;4AB41127111111112222
 tst.l ([jan.l,a4],d1,sue)             ;4AB41136111122221111
 tst.l ([fred.l,a4],d1,bill.l)         ;4AB41137000000020000
 tst.l ([jill.l,a4],d1,june.l)         ;4AB411370000080200000804
 tst.l ([$1234,a4],d1*2,$87654321.l)   ;4AB41327123487654321
 tst.l ([$1234.w,a4],d1*2,$87654321.l) ;4AB41327123487654321
 tst.l ([$1234.l,a4],d1*2,$4321)       ;4AB41336000012344321
 tst.l ([$12345678.l,a4],a1,$4321.w)   ;4AB49136123456784321
 tst.l ([$12345678.l,a4],a1,$4321.l)   ;4AB491371234567800004321

 tst.l ([sue,a4,d1],jan.l)             ;4AB41123111111112222
 tst.l ([jan.l,a4,d1],sue)             ;4AB41132111122221111
 tst.l ([fred.l,a4,d1],bill.l)         ;4AB411330000000200000004
 tst.l ([jill.l,a4,d1],june.l)         ;4AB411330000080200000804
 tst.l ([$1234,a4,d1*2],$87654321.l)   ;4AB41323123487654321
 tst.l ([$1234.w,a4,d1*2],$87654321.l) ;4AB41323123487654321
 tst.l ([$1234.l,a4,d1*2],$4321)       ;4AB41332000012344321
 tst.l ([$12345678.l,a4,a1.w],$4321.w) ;4AB49132123456784321
 tst.l ([$12345678.l,a4,a1.w],$4321.l) ;4AB491331234567800004321

 tst.l ([fred,pc],d1,jan.l)            ;4ABB1127FF3A11112222
 tst.l ([fred,pc],d1,sue)              ;4ABB1126FF301111
 tst.l ([fred.l,pc],d1,bill.l)         ;4ABB1137FFFFFF2800000004
 tst.l ([jill.l,pc],d1,june.l)         ;4ABB11370000071C00000804
 tst.l ([fred,pc],d1*2,$87654321.l)    ;4ABB1327FF1087654321
 tst.l ([fred,pc],d1*2,$4321)          ;4ABB1326FF064321
 tst.l ([fred,pc],a1,$4321.w)          ;4ABB9126FEFE4321
 tst.l ([fred,pc],a1,$4321.l)          ;4ABB9127FEF600004321

 tst.l ([fred,pc,d1],jan.l)            ;4ABB1123FEEC11112222
 tst.l ([fred,pc,d1],sue)              ;4ABB1122FEE21111
 tst.l ([fred.l,pc,d1],bill.l)         ;4ABB1133FFFFFEDA00000004
 tst.l ([jill.l,pc,d1],june.l)         ;4ABB1133000006CE00000804
 tst.l ([fred,pc,d1*2],$87654321.l)    ;4ABB1323FEC287654321
 tst.l ([fred,pc,d1*2],$87654321.l)    ;4ABB1323FEB887654321
 tst.l ([fred,pc,d1*2],$4321)          ;4ABB1322FEAE4321
 tst.l ([fred,pc,a1.w],$4321.w)        ;4ABB9122FEA64321
 tst.l ([fred,pc,a1.w],$4321.l)        ;4ABB9123FE9E00004321

 tst.l ([fred,zpc],d1,jan.l)            ;4ABB11A7FE9411112222
 tst.l ([jan.l,zpc],d1,sue)             ;4ABB11B6111122221111
 tst.l ([fred.l,zpc],d1,bill.l)         ;4ABB11B70000000200000004
 tst.l ([jill.l,zpc],d1,june.l)         ;4ABB11B70000080200000804
 tst.l ([fred,zpc],d1*2,$87654321.l)    ;4ABB13A7FE6887654321
 tst.l ([fred,zpc],d1*2,$4321)          ;4ABB13A6FE5E4321
 tst.l ([$1234.l,zpc],d1*2,$4321)       ;4ABB13B6000012344321
 tst.l ([$12345678.l,zpc],a1,$4321.w)   ;4ABB91B6123456784321
 tst.l ([$12345678.l,zpc],a1,$4321.l)   ;4ABB91B71234567800004321

 tst.l ([fred,zpc,d1],jan.l)            ;4ABB11A3FE3611112222
 tst.l ([jan.l,zpc,d1],sue)             ;4ABB11B2111122221111
 tst.l ([fred.l,zpc,d1],bill.l)         ;4ABB11B30000000200000004
 tst.l ([jill.l,zpc,d1],june.l)         ;4ABB11B30000080200000804
 tst.l ([fred,zpc,d1*2],$87654321.l)    ;4ABB13A3FE0A87654321
 tst.l ([$1234.l,zpc,d1*2],$4321)       ;4ABB13B2000012344321
 tst.l ([$12345678.l,zpc,a1.w],$4321.w) ;4ABB91B2123456784321
 tst.l ([$12345678.l,zpc,a1.w],$4321.l) ;4ABB91B31234567800004321

 tst.l ([sue],d1,jan.l)                ;4AB011A7111111112222
 tst.l ([jan.l],d1,sue)                ;4AB011B6111122221111
 tst.l ([fred.l],d1,bill.l)            ;4AB011B70000000200000004
 tst.l ([jill.l],d1,june.l)            ;4AB011B70000080200000804
 tst.l ([$1234],d1*2,$87654321.l)      ;4AB013A7123487654321
 tst.l ([$1234.w],d1*2,$87654321.l)    ;4AB013A7123487654321
 tst.l ([$1234.l],d1*2,$4321)          ;4AB013B6000012344321
 tst.l ([$12345678.l],a1,$4321.w)      ;4AB091B6123456784321
 tst.l ([$12345678.l],a1,$4321.l)      ;4AB091B71234567800004321

 tst.l ([sue,d1],jan.l)                ;4AB011A3111111112222
 tst.l ([jan.l,d1],sue)                ;4AB011B2111122221111
 tst.l ([fred.l,d1],bill.l)            ;4AB011B30000000200000004
 tst.l ([jill.l,d1],june.l)            ;4AB011B30000080200000804
 tst.l ([$1234,d1*2],$87654321.l)      ;4AB013A3123487654321
 tst.l ([$1234.w,d1*2],$87654321.l)    ;4AB013A3123487654321
 tst.l ([$1234.l,d1*2],$4321)          ;4AB013B2000012344321
 tst.l ([$12345678.l,a1.w],$4321.w)    ;4AB091B2123456784321
 tst.l ([$12345678.l,a1.w],$4321.l)    ;4AB091B31234567800004321

 tst.l ([],d1,jan.l)                   ;4AB0119311112222 } Barfly 1197
 tst.l ([],d1,sue)                     ;4AB011921111     } Barfly 1196
 tst.l ([],d1,bill.l)                  ;4AB0119300000004 }
 tst.l ([],d1,june.l)                  ;4AB0119300000804 } Devpac wrong -
 tst.l ([],d1*2,$87654321.l)           ;4AB0139387654321 } treats as
 tst.l ([],d1*2,$4321)                 ;4AB013924321     } preindexed
 tst.l ([],a1,$4321.w)                 ;4AB091924321     }
 tst.l ([],a1,$4321.l)                 ;4AB0919300004321 }

 tst.l ([d1],jan.l)                    ;4AB0119311112222
 tst.l ([d1],sue)                      ;4AB011921111
 tst.l ([d1],bill.l)                   ;4AB0119300000004
 tst.l ([d1],june.l)                   ;4AB0119300000804
 tst.l ([d1*2],$87654321.l)            ;4AB0139387654321
 tst.l ([d1*2],$4321)                  ;4AB013924321
 tst.l ([a1.w],$4321.w)                ;4AB091924321
 tst.l ([a1.w],$4321.l)                ;4AB0919300004321

 tst.l ([],jan.l)                      ;4AB001D311112222
 tst.l ([],sue)                        ;4AB001D21111
 tst.l ([],bill.l)                     ;4AB001D300000004
 tst.l ([],june.l)                     ;4AB001D300000804
 tst.l ([],$87654321.l)                ;4AB001D387654321
 tst.l ([],$4321)                      ;4AB001D24321
 tst.l ([],$4321.w)                    ;4AB001D24321
 tst.l ([],$4321.l)                    ;4AB001D300004321

 tst.l ([])                            ;4AB001D1

 tst.l ([sue],jan.l)                   ;4AB001E3111111112222
 tst.l ([jan.l],sue)                   ;4AB001F2111122221111
 tst.l ([fred.l],bill.l)               ;4AB001F30000000200000004
 tst.l ([jill.l],june.l)               ;4AB001F30000080200000804
 tst.l ([$1234],$87654321.l)           ;4AB001E3123487654321
 tst.l ([$1234.w],$87654321.l)         ;4AB001E3123487654321
 tst.l ([$1234.l],$4321)               ;4AB001F2000012344321
 tst.l ([$12345678.l],$4321.w)         ;4AB001F2123456784321
 tst.l ([$12345678.l],$4321.l)         ;4AB001F31234567800004321

 tst.l ([sue])                         ;4AB001E11111
 tst.l ([jan.l])                       ;4AB001F111112222
 tst.l ([fred.l])                      ;4AB001F1000000002
 tst.l ([jill.l])                      ;4AB001F1000000802
 tst.l ([$1234])                       ;4AB001E11234
 tst.l ([$1234.w])                     ;4AB001E11234
 tst.l ([$1234.l])                     ;4AB001F100001234
 tst.l ([$12345678.l])                 ;4AB001F112345678
 tst.l ([$12345678.l])                 ;4AB001F112345678

 tst.l ([],d1)                         ;4AB01191 }Barfly 1995 (1195/1995 ok)
 tst.l ([],d1*2)                       ;4AB01391 }Devpac wrong - treats
 tst.l ([],a1)                         ;4AB09191 }as preindexed

 tst.l ([a4],d1,jan.l)                 ;4AB4111711112222
 tst.l ([a4],d1,sue)                   ;4AB411161111

 tst.l ([a4,d1],jan.l)                 ;4AB4111311112222
 tst.l ([a4,d1],sue)                   ;4AB411121111

 tst.l ([pc],d1,jan.l)                 ;4ABB111711112222
 tst.l ([pc],d1,sue)                   ;4ABB11161111

 tst.l ([pc,d1],jan.l)                 ;4ABB111311112222
 tst.l ([pc,d1],sue)                   ;4ABB11121111

 tst.l ([zpc],d1,jan.l)                ;4ABB119711112222
 tst.l ([zpc],d1,sue)                  ;4ABB11961111

 tst.l ([zpc,d1],jan.l)                ;4ABB119311112222
 tst.l ([zpc,d1],sue)                  ;4ABB11921111

 tst.l ([a4],jan.l)                    ;4AB4015311112222
 tst.l ([a4],sue)                      ;4AB401521111

 tst.l ([pc],jan.l)                    ;4ABB015311112222
 tst.l ([pc],sue)                      ;4ABB01521111

 tst.l ([zpc],jan.l)                   ;4ABB01D311112222
 tst.l ([zpc],sue)                     ;4ABB01D21111

jack:
skp: equ jack-stt

 ds.b $0800-skp

 nop                                   ;4E71
jill:
 nop                                   ;4E71
june:
