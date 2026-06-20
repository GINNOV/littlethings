; In_Go Reassembler RCTDemo: 09.06.2000 19:56:33
_SysBase EQU $4
MaxIntSgnd EQU $7FFFFFFF
Optimize68020 EQU 0
 SECTION "Segment0",CODE
 cnop 0,4
SegmentBeginn0:
  movem.l D0/A0,-(A7)
  suba.l A1,A1
  movea.l $4.W,A6
FindTask SET -$126
   jsr FindTask(A6)
  suba.l A1,A1
  movea.l D0,A2
pr_CLI SET $AC
  tst.l pr_CLI(A2)
   bne.b JL_0_38
pr_MsgPort SET $5C
  lea pr_MsgPort(A2),A0
WaitPort SET -$180
   jsr WaitPort(A6)
pr_MsgPort SET $5C
  lea pr_MsgPort(A2),A0
GetMsg SET -$174
   jsr GetMsg(A6)
  movea.l D0,A1
sm_NumArgs SET $1C
  move.l sm_NumArgs(A1),D0
sm_ArgList SET $24
  movea.l sm_ArgList(A1),A0
  moveq.l #-$01,D1
  addq.w #8,A7
 bra.b JL_0_3E
 
JL_0_38:
  movem.l (A7)+,D0/A0
  moveq.l #$00,D1
JL_0_3E:
  movem.l A1/A6,-(A7)
   jsr SegmentBeginn1
  movem.l (A7)+,A1/A6
  move.l A1,D1
   beq.b JL_0_58
  move.l D0,D2
ReplyMsg SET -$17A
   jsr ReplyMsg(A6)
  move.l D2,D0
JL_0_58:
 rtS 
 
  ds.w 1
 SECTION "Segment1",CODE
 cnop 0,4
SegmentBeginn1:
 bra.w JL_1_35A
 
JL_1_4:
  movea.l _SysBase,A6
  lea AL_1_3A,A1
  moveq.l #$00,D0
OpenLibrary SET -$228
   jsr OpenLibrary(A6)
  move.l D0,AL_1_46
 rtS 
 
JL_1_1E:
  movea.l _SysBase,A6
  movea.l AL_1_46,A1
  cmpa.l #$0,A1
   beq.w JL_1_38
CloseLibrary SET -$19E
   jsr CloseLibrary(A6)
JL_1_38:
 rtS 
 
AL_1_3A:
  dc.b "rct.library",0
AL_1_46:
  ds.l 1
JL_1_4A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$1E(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_5A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$24(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_6A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$2A(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_7A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$30(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_8A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$36(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_9A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$3C(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_AA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$42(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_BA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$48(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_CA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$4E(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_DA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$54(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_EA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$5A(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_FA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$60(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_10A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$66(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_11A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$6C(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_12A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$72(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_13A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$78(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_14A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$7E(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_15A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$84(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_16A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$8A(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_17A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$90(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_18A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$96(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_19A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$9C(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_1AA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$A2(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_1BA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$A8(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_1CA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$AE(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_1DA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$B4(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_1EA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$BA(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_1FA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$C0(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_20A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$C6(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_21A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$CC(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_22A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$D2(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_23A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$D8(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_24A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$DE(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_25A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$E4(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_26A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$EA(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_27A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$F0(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_28A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$F6(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_29A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$FC(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_2AA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$102(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_2BA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$108(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_2CA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$10E(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_2DA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$114(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_2EA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$11A(A6)
  movea.l (A7)+,A6
 rtS 
 
AJL_1_2FA:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$120(A6)
  movea.l (A7)+,A6
 rtS 
 
AJL_1_30A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$126(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_31A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$12C(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_32A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$132(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_33A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$138(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_34A:
  move.l A6,-(A7)
  movea.l AL_1_46,A6
   jsr -$13E(A6)
  movea.l (A7)+,A6
 rtS 
 
JL_1_35A:
   bsr.w JL_1_4
  tst.l D0
   beq.w JL_1_3C2
  movem.l D1-D7/A0-A6,-(A7)
  lea AL_1_382,A0
  move.l #$1,D0
   jsr AJL_1_2FA
  movem.l (A7)+,D1-D7/A0-A6
 bra.w JL_1_3B2
 
AL_1_382:
   dc.b "[1][RCT-Form Alert|mit Bild!][Is ja toll|Weiter]"
JL_1_3B2:
  lea AL_1_3C4,A0
   jsr AJL_1_30A
   bsr.w JL_1_1E
JL_1_3C2:
 rtS 
 
AL_1_3C4:
  ds.w 1
AL_1_3C6:
 dc.l AL_1_4A8
AL_1_3CA:
 dc.l AL_1_4C0
AL_1_3CE:
 dc.l AL_1_542
AL_1_3D2:
 dc.l AL_1_560
  ds.w 7
  dc.b $10,$00,$00,$00 ;....
  ds.l 18
  dc.b $00,$64,$00,$00 ;.d..
  ds.l 2
  dc.b ".info",0,0
  ds.b 25
  dc.b "#?",0,0
  ds.l 18
AL_1_4A8:
  dc.b "RCT-Dateiauswahlfenster",0
AL_1_4C0:
  dc.b "SYS:",0,0
  ds.l 31
AL_1_542:
  ds.w 15
AL_1_560:
  ds.l 40
 End
