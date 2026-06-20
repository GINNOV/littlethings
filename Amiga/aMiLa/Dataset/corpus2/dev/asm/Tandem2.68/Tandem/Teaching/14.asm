* 14.asm     Addressing modes     version 0.00    1.9.97

 lea fred,a0      ;ready A0 for use in addressing modes
 move.l a0,d0     ;A0=address register immediate - contents of A0
 move.l (a0),d1   ;(A0)=address register indirect - contents of addess
                  ;  pointed to by A0  (='Hell')
 move.b 1(a0),d2  ;1(A0)=address register indirect with displacement
                  ;  contents of address A0+1 (='e')
 moveq #2,d3      ;#2=immediate data   value 2 built into mc
                  ;use MOVEQ instead of MOVE.L for  -128<=values<=+127
 move.b 1(a0,d3.w),d4 ;address register indirect with index
                      ;contents of address A0+D3.W+1  (=A0+3='l')
 move.w fred,d5   ;fred=memory direct   contents of address fred (='He'
 rts

fred: dc.b 'Hello!',0
 ds.w 0
