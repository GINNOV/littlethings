 ifnd DEVICES_PARALLEL_I
DEVICES_PARALLEL_I set 1
*
*  devices/parallel.i
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
 DEVCMD PDCMD_QUERY
 DEVCMD PDCMD_SETPARAMS
PAR_DEVFINISH	= PDCMD_SETPARAMS

PARALLELNAME macro
 dc.b "parallel.device",0
 even
 endm

ParErr_DevBusy	= 1
ParErr_BufTooBig = 2
ParErr_InvParam = 3
ParErr_LineErr	= 4
ParErr_NotOpen	= 5
ParErr_PortReset = 6
ParErr_InitErr	 = 7

 BITDEF PAR,SHARED,5
 BITDEF PAR,SLOWMODE,4
 BITDEF PAR,FASTMODE,3
 BITDEF PAR,RAD_BOOGIE,3
 BITDEF PAR,ACKMODE,2
 BITDEF PAR,EOFMODE,1
 BITDEF IOPAR,QUEUED,6
 BITDEF IOPAR,ABORT,5
 BITDEF IOPAR,ACTIVE,4
 BITDEF IOPT,RWDIR,3
 BITDEF IOPT,PARSEL,2
 BITDEF IOPT,PAPEROUT,1
 BITDEF IOPT,PARBUSY,0

 rsreset
PTERMARRAY_0	rs.l 1
PTERMARRAY_1	rs.l 1
PTERMARRAY_SIZE rs

* struct IOExtPar
 rsset iostd_SIZE
io_PExtFlags	rs.l 1
io_ParStatus	rs.b 1
io_ParFlags	rs.b 1
io_PTermArray	rs.b PTERMARRAY_SIZE
IOExtPar_SIZE	rs

 endc
