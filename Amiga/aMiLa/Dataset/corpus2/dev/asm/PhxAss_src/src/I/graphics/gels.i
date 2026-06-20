 IFND GRAPHICS_GELS_I
GRAPHICS_GELS_I SET 1
*
*  graphics/gels.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc

SUSERFLAGS	= $00ff
 BITDEF VS,VSPRITE,0
 BITDEF VS,SAVEBACK,1
 BITDEF VS,OVERLAY,2
 BITDEF VS,MUSTDRAW,3
 BITDEF VS,BACKSAVED,8
 BITDEF VS,BOBUPDATE,9
 BITDEF VS,GELGONE,10
 BITDEF VS,VSOVERFLOW,11

BUSERFLAGS	= $00ff
 BITDEF B,SAVEBOB,0
 BITDEF B,BOBISCOMP,1
 BITDEF B,BWAITING,8
 BITDEF B,BDRAWN,9
 BITDEF B,BOBSAWAY,10
 BITDEF B,BOBNIX,11
 BITDEF B,SAVEPRESERVE,12
 BITDEF B,OUTSTEP,13

ANFRACSIZE equ 6
ANIMHALF equ $20
RINGTRIGGER equ 1

INITANIMATE macro
 clr.l	 \1
 endm

REMBOB macro
 or.w	 #BF_BOBSAWAY,b_BobFlags+\1
 endm

* struct VSprite
 rsreset
vs_NextVSprite	rs.l 1
vs_PrevVSprite	rs.l 1
vs_DrawPath	rs.l 1
vs_ClearPath	rs.l 1
vs_OldY 	rs.l 1
vs_OldX 	rs.w 1
vs_Flags	rs.w 1
vs_Y		rs.w 1
vs_X		rs.w 1
vs_Height	rs.w 1
vs_Width	rs.w 1
vs_Depth	rs.w 1
vs_MeMask	rs.w 1
vs_HitMask	rs.w 1
vs_ImageData	rs.l 1
vs_BorderLine	rs.l 1
vs_CollMask	rs.l 1
vs_SprColors	rs.l 1
vs_VSBob	rs.l 1
vs_PlanePick	rs.b 1
vs_PlaneOnOff	rs.b 1
vs_SUserExt	rs
vs_SIZEOF	rs

* struct Bob
 rsreset
bob_BobFlags	rs.w 1
bob_SaveBuffer	rs.l 1
bob_ImageShadow rs.l 1
bob_Before	rs.l 1
bob_After	rs.l 1
bob_BobVSprite	rs.l 1
bob_BobComp	rs.l 1
bob_DBuffer	rs.l 1
bob_BUserExt	rs
bob_SIZEOF	rs

* struct AnimComp
 rsreset
ac_CompFlags	rs.w 1
ac_Timer	rs.w 1
ac_TimeSet	rs.w 1
ac_NextComp	rs.l 1
ac_PrevComp	rs.l 1
ac_NextSeq	rs.l 1
ac_PrevSeq	rs.l 1
ac_AnimCRoutine rs.l 1
ac_XTrans	rs.w 1
ac_YTrans	rs.w 1
ac_HeadOb	rs.l 1
ac_AnimBob	rs.l 1
ac_SIZE 	rs

* struct AnimOb
 rsreset
ao_NextOb	rs.l 1
ao_PrevOb	rs.l 1
ao_Clock	rs.l 1
ao_AnOldY	rs.w 1
ao_AnOldX	rs.w 1
ao_AnY		rs.w 1
ao_AnX		rs.w 1
ao_YVel 	rs.w 1
ao_XVel 	rs.w 1
ao_YAccel	rs.w 1
ao_XAccel	rs.w 1
ao_RingYTrans	rs.w 1
ao_RingXTrans	rs.w 1
ao_AnimORoutine rs.l 1
ao_HeadComp	rs.l 1
ao_AUserExt	rs
ao_SIZEOF	rs

* struct DBufPacket
 rsreset
dbp_BufY	rs.w 1
dbp_BufX	rs.w 1
dbp_BufPath	rs.l 1
dbp_BufBuffer	rs.l 1
dbp_SIZEOF	rs

 endc
