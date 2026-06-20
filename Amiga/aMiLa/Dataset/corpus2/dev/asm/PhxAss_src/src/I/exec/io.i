 ifnd EXEC_IO_I
EXEC_IO_I set 1
*
*  exec/io.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc

 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc


** IO Request Structures
 rsset	mn_SIZE
io_Device	rs.l 1
io_Unit 	rs.l 1
io_Command	rs.w 1
io_Flags	rs.b 1
io_Error	rs.b 1
io_SIZE 	rs 0
io_Actual	rs.l 1
io_Length	rs.l 1
io_Data 	rs.l 1
io_Offset	rs.l 1
iostd_SIZE	rs 0

 BITDEF  IO,QUICK,0

** Standard Device Library Functions
 LIBINIT
 LIBDEF  DEV_BEGINIO
 LIBDEF  DEV_ABORTIO

** IO Function Macros
 macro	 BEGINIO
 LINKLIB DEV_BEGINIO,io_Device(a1)
 endm

 macro	 ABORTIO
 LINKLIB DEV_ABORTIO,io_Device(a1)
 endm

** Standard Device Command Definitions
 macro	 DEVINIT
 ifc	 "\1",""
CMD_COUNT set CMD_NONSTD
 else
CMD_COUNT set \1
 endc
 endm

 macro	 DEVCMD
\1 equ	 CMD_COUNT
CMD_COUNT set CMD_COUNT+1
 endm

 DEVINIT 0
 DEVCMD  CMD_INVALID
 DEVCMD  CMD_RESET
 DEVCMD  CMD_READ
 DEVCMD  CMD_WRITE
 DEVCMD  CMD_UPDATE
 DEVCMD  CMD_CLEAR
 DEVCMD  CMD_STOP
 DEVCMD  CMD_START
 DEVCMD  CMD_FLUSH
 DEVCMD  CMD_NONSTD

 endc	    ; EXEC_IO_I
