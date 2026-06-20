 ifnd EXEC_RESIDENT_I
EXEC_RESIDENT_I set 1
*
*  exec/resident.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 rsreset
rt_MatchWord	rs.w 1
rt_MatchTag	rs.l 1
rt_EndSkip	rs.l 1
rt_Flags	rs.b 1
rt_Version	rs.b 1
rt_Type 	rs.b 1
rt_Pri		rs.b 1
rt_Name 	rs.l 1
rt_IdString	rs.l 1
rt_Init 	rs.l 1
rt_SIZE 	rs 0

RTC_MATCHWORD equ $4afc

 BITDEF RT,COLDSTART,0
 BITDEF RT,SINGLETASK,1
 BITDEF RT,AFTERDOS,2
 BITDEF RT,AUTOINIT,7

;RTM_WHEN equ 1
RTW_NEVER equ 0
RTW_COLDSTART equ 1

 endc
