 ifnd DEVICES_SERIAL_I
DEVICES_SERIAL_I set 1
*
*  devices/serial.i
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
 DEVCMD SDCMD_QUERY
 DEVCMD SDCMD_BREAK
 DEVCMD SDCMD_SETPARAMS
SER_DEVFINISH	= SDCMD_SETPARAMS

SERIALNAME macro
 dc.b "serial.device",0
 even
 endm

 BITDEF SER,XDISABLED,7
 BITDEF SER,EOFMODE,6
 BITDEF SER,SHARED,5
 BITDEF SER,RAD_BOOGIE,4
 BITDEF SER,QUEUEDBRK,3
 BITDEF SER,7WIRE,2
 BITDEF SER,PARTY_ODD,1
 BITDEF SER,PARTY_ON,0

 BITDEF IOST,XOFFREAD,4
 BITDEF IOST,XOFFWRITE,3
 BITDEF IOST,READBREAK,2
 BITDEF IOST,WROTEBREAK,1
 BITDEF IOST,OVERRUN,0

 BITDEF SEXT,MSPON,1
 BITDEF SEXT,MARK,0

* struct TERMARRAY
 rsreset
TERMARRAY_0	rs.l 1
TERMARRAY_1	rs.l 1
TERMARRAY_SIZE	rs

* struct IOExtSer
 rsset iostd_SIZE
io_CtlChar	rs.l 1
io_RbufLen	rs.l 1
io_ExtFlags	rs.l 1
io_Baud 	rs.l 1
io_BrkTime	rs.l 1
io_TermArray	rs.b TERMARRAY_SIZE
io_ReadLen	rs.b 1
io_WriteLen	rs.b 1
io_StopBits	rs.b 1
io_SerFlags	rs.b 1
io_Status	rs.w 1
IOExtSer_SIZE	rs

SerErr_DevBusy equ 1
SerErr_BaudMismatch equ 2
SerErr_InvBaud equ 3
SerErr_BufErr equ 4
SerErr_InvParam equ 5
SerErr_LineErr equ 6
SerErr_NotOpen equ 7
SerErr_PortReset equ 8
SerErr_ParityErr equ 9
SerErr_InitErr equ 10
SerErr_TimerErr equ 11
SerErr_BufOverflow equ 12
SerErr_NoDSR equ 13
SerErr_NoCTS equ 14
SerErr_DetectedBreak equ 15

 ifd DEVICES_SERIAL_I_OBSOLETE
SER_DBAUD	= 9600
 BITDEF IOSER,QUEUED,6
 BITDEF IOSER,ABORT,5
 BITDEF IOSER,ACTIVE,4
 endc

 endc
