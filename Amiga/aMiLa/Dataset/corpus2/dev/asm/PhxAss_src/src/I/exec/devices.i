 ifnd EXEC_DEVICES_I
EXEC_DEVICES_I set 1
*
*  exec/devices.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc
 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc


dd_SIZE = lib_SIZE

 rsset	mp_SIZE
unit_flags	rs.b 1
unit_pad	rs.b 1
unit_OpenCnt	rs.w 1
unit_SIZE	rs 0

 BITDEF  UNIT,ACTIVE,0
 BITDEF  UNIT,INTASK,1

 endc
