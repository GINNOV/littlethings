 ifnd DEVICES_AUDIO_I
DEVICES_AUDIO_I set 1
*
*  devices/audio.i
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

AUDIONAME macro
 dc.b "audio.device",0
 endm

ADHARD_CHANNELS equ 4
ADALLOC_MINPREC equ -128
ADALLOC_MAXPREC equ 127

 rsset CMD_NONSTD
ADCMD_FREE	rs.b 1
ADCMD_SETPREC	rs.b 1
ADCMD_FINISH	rs.b 1
ADCMD_PERVOL	rs.b 1
ADCMD_LOCK	rs.b 1
ADCMD_WAITCYCLE rs.b 1
ADCMD_ALLOCATE	= 32

 BITDEF ADCMD,NOUNIT,5
 BITDEF ADIO,PERVOL,4
 BITDEF ADIO,SYNCCYCLE,5
 BITDEF ADIO,NOWAIT,6
 BITDEF ADIO,WRITEMESSAGE,7

ADIOERR_NOALLOCATION equ -10
ADIOERR_ALLOCFAILED equ -11
ADIOERR_CHANNELSTOLEN equ -12

* struct IOAudio
 rsset io_SIZE
ioa_AllocKey	rs.w 1
ioa_Data	rs.l 1
ioa_Length	rs.l 1
ioa_Period	rs.w 1
ioa_Volume	rs.w 1
ioa_Cycles	rs.w 1
ioa_WriteMsg	rs.b mn_SIZE
ioa_SIZEOF	rs

 endc
