* test XDEF/XREF, & save .o    v.0.0
 
 xref jim,bill,harry
 
 nop
 move.l fred,d0
 move.l jim,d1
 move.w #jack,d2
 move.w bill,d3
 move.b jim,harry
 move.w jim(a4),d3
 move.b bill(a2,d3),d1
 rts

joe:
fred: dc.l $12345678
jack: equ $4321
 
 xdef fred,joe,jack

 END

;as assembled by A68k:

;0000: 000003E7 00000000 000003E8 00000001    ...ç.......è....     
;0010: 20000000 000003E9 0000000C 4E712039     ......é....Nq 9     
;0020: 0000002C 22390000 0000343C 43213639    ...,"9....4<C!69     
;0030: 00000000 13F90000 00000000 0000362C    .....ù........6,     
;0040: 00001232 30004E75 12345678 000003EC    ...20.Nu.4Vx...ì     
;0050: 00000001 00000000 00000004 00000000    ................     
;0060: 000003EF 01000001 6A6F6500 0000002C    ...ï....joe....,     
;0070: 01000001 66726564 0000002C 02000001    ....fred...,....     
;0080: 6A61636B 00004321 81000001 6A696D00    jack..C!....jim.     
;0090: 00000002 0000000A 0000001A 81000001    ................     
;00A0: 62696C6C 00000001 00000014 81000002    bill............     
;00B0: 68617272 79000000 00000001 0000001E    harry...........     
;00C0: 83000001 6A696D00 00000001 00000024    ....jim........$     
;00D0: 84000001 62696C6C 00000001 00000029    ....bill.......)     
;00E0: 00000000 000003F2                      .......ò             

;3E7 0          hunk_unit
;3E8 1 20000000 optional hunk_name
;3E9 C ........ hunk_code
;3EC 1 0 4, 0   hunk_reloc32 (fred only)
;3EF hunk_ext
;    1,1   joe   2C        XDEF rel
;    1,1   fred  2C        XDEF rel
;    2,1   jack  4321      XDEF abs
;    129,1 jim    2  A 1A  XREF 2 entries  .L
;    129,1 bill   1 14     XREF 1 entry    .L
;    129,2 harry  1 1E     XREF 1 entry    .L
;    131,1 jim    1 24     XREF 1 entry    .W
;    132,1 bill   1 29     XREF 1 entry    .B
;    0
;3F2 hunk_end
