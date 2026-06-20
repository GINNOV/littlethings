 IFND GRAPHICS_COPPER_I
GRAPHICS_COPPER_I SET 1
*
*  graphics/copper.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

COPPER_MOVE	= 0
COPPER_WAIT	= 1
CPRNXTBUF	= 2
CPR_NT_LOF	= $8000
CPR_NT_SHT	= $4000

* struct CopIns
 rsreset
ci_OpCode	rs.w 1
ci_nxtlist	rs.w 0
ci_VWaitPos	rs.w 0
ci_DestAddr	rs.w 1
ci_HWaitPos	rs.w 0
ci_DestData	rs.w 1
ci_SIZEOF	rs.w 0

* struct cprlist
 rsreset
crl_Next	rs.l 1
crl_start	rs.l 1
crl_MaxCount	rs.w 1
crl_SIZEOF	rs.w 0

* struct CopList
 rsreset
cl_Next 	rs.l 1
cl__CopList	rs.l 1
cl__ViewPort	rs.l 1
cl_CopIns	rs.l 1
cl_CopPtr	rs.l 1
cl_CopLStart	rs.l 1
cl_CopSStart	rs.l 1
cl_Count	rs.w 1
cl_MaxCount	rs.w 1
cl_DyOffset	rs.w 1
cl_SIZEOF	rs.w 0

* struct UCopList
 rsreset
ucl_Next	rs.l 1
ucl_FirstCopList rs.l 1
ucl_CopList	rs.l 1
ucl_SIZEOF	rs.w 0

* struct copinit
 rsreset
copinit_vsync_hblank	rs.w 2
copinit_diwstart	rs.w 4
copinit_diagstrt	rs.w 4
copinit_sprstrtup	rs.w 2*8*2
copinit_wait14		rs.w 4
copinit_genloc		rs.w 4+4+2
copinit_sprstop 	rs.w 4
copinit_SIZEOF		rs.w 0

 endc
