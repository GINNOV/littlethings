* test bit instructions

 bchg d3,d2            ;0742
 bchg d3,(a3)          ;0753
 bchg d5,(a5)+         ;0B5D
 bchg d1,-(a2)         ;0362
 bchg d0,3(a2)         ;016A0003
 bchg d7,$12(a5,d3.w)  ;0F753012
 bchg d1,$1234.w       ;03781234
 bchg d2,$12345678     ;057912345678

 bchg #1,d7            ;08470001
 bchg #3,(a5)          ;08550003
 bchg #7,(a1)+         ;08590007
 bchg #2,-(a5)         ;08650002
 bchg #1,$1234(a6)     ;086E00011234
 bchg #0,-23(a2,d1.l)  ;0872000018E9
 bchg #5,$12.w         ;087800050012
 bchg #7,$23456abc     ;0879000723456ABC

 bclr d3,d2            ;0782
 bclr d3,(a3)          ;0793
 bclr d5,(a5)+         ;0B9D
 bclr d1,-(a2)         ;03A2
 bclr d0,3(a2)         ;01AA0003
 bclr d7,$12(a5,d3.w)  ;0FB53012
 bclr d1,$1234.w       ;03B81234
 bclr d2,$12345678     ;05B912345678

 bclr #1,d7            ;08870001
 bclr #3,(a5)          ;08950003
 bclr #7,(a1)+         ;08990007
 bclr #2,-(a5)         ;08A50002
 bclr #1,$1234(a6)     ;08AE00011234
 bclr #0,-23(a2,d1.l)  ;08B2000018E9
 bclr #5,$12.w         ;08B800050012
 bclr #7,$23456abc     ;08B9000723456ABC

 bset d3,d2            ;07C2
 bset d3,(a3)          ;07D3
 bset d5,(a5)+         ;0BDD
 bset d1,-(a2)         ;03E2
 bset d0,3(a2)         ;01EA0003
 bset d7,$12(a5,d3.w)  ;0FF53012
 bset d1,$1234.w       ;03F81234
 bset d2,$12345678     ;05F912345678

 bset #1,d7            ;08C70001
 bset #3,(a5)          ;08D50003
 bset #7,(a1)+         ;08D90007
 bset #2,-(a5)         ;08E50002
 bset #1,$1234(a6)     ;08EE00011234
 bset #0,-23(a2,d1.l)  ;08F2000018E9
 bset #5,$12.w         ;08F800050012
 bset #7,$23456abc     ;08F9000723456ABC

 btst d3,d2            ;0702
 btst d3,(a3)          ;0713
 btst d5,(a5)+         ;0B1D
 btst d1,-(a2)         ;0322
 btst d0,3(a2)         ;012A0003
 btst d7,$12(a5,d3.w)  ;0F353012
 btst d1,$1234.w       ;03381234
 btst d2,$12345678     ;053912345678

 btst #1,d7            ;08070001
 btst #3,(a5)          ;08150003
 btst #7,(a1)+         ;08190007
 btst #2,-(a5)         ;08250002
 btst #1,$1234(a6)     ;082E00011234
 btst #0,-23(a2,d1.l)  ;0832000018E9
 btst #5,$12.w         ;083800050012
 btst #7,$23456abc     ;0839000723456ABC
