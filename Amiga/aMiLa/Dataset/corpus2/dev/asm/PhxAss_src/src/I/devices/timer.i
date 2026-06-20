 ifnd DEVICES_TIMER_I
DEVICES_TIMER_I set 1
*
*  devices/timer.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_IO_I
 include "exec/io.i"
 endc

UNIT_MICROHZ   = 0
UNIT_VBLANK    = 1
UNIT_ECLOCK    = 2
UNIT_WAITUNTIL = 3
UNIT_WAITECLOCK = 4

TIMERNAME macro
 dc.b "timer.device",0
 even
 endm

* struct timeval
 rsreset
tv_secs 	rs.l 1
tv_micro	rs.l 1
tv_SIZE 	rs.w 0

* struct EClockVal
 rsreset
ev_hi		rs.l 1
ev_lo		rs.l 1
ev_SIZE 	rs.w 0

* struct timerequest
 rsset io_SIZE
iotv_time	rs.b tv_SIZE
iotv_SIZE	rs.w 0

 DEVINIT
 DEVCMD  TR_ADDREQUEST
 DEVCMD  TR_GETSYSTIME
 DEVCMD  TR_SETSYSTIME

 endc
