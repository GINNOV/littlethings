 ifnd DEVICES_GAMEPORT_I
DEVICES_GAMEPORT_I set 1
*
*  devices/gameport.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_IO_I
 include "exec/io.i"
 endc

 DEVINIT
 DEVCMD GPD_READEVENT
 DEVCMD GPD_ASKCTYPE
 DEVCMD GPD_SETCTYPE
 DEVCMD GPD_ASKTRIGGER
 DEVCMD GPD_SETTRIGGER

 BITDEF GPT,DOWNKEYS,0
 BITDEF GPT,UPKEYS,1

* sturct GamePortTrigger
 rsreset
gpt_Keys	rs.w 1
gpt_Timeout	rs.w 1
gpt_XDelta	rs.w 1
gpt_YDelta	rs.w 1
gpt_SIZEOF	rs

GPCT_ALLOCATED	= -1
GPCT_NOCONTROLLER = 0
GPCT_MOUSE	= 1
GPCT_RELJOYSTICK = 2
GPCT_ABSJOYSTICK = 3

GPDERR_SETCTYPE = 1

 endc
