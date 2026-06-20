 ifnd DEVICES_TRACKDISK_I
DEVICES_TRACKDISK_I set 1
*
*  devices/trackdisk.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_IO_I
 include "exec/io.i"
 endc
 ifnd EXEC_DEVICES_I
 include "exec/devices.i"
 endc

NUMSECS 	= 11
NUMUNITS	= 4

TD_SECTOR	= 512
TD_SECSHIFT	= 9

TD_NAME macro
 dc.b "trackdisk.device",0
 even
 endm

 BITDEF TD,EXTCOM,15
 DEVINIT
 DEVCMD TD_MOTOR
 DEVCMD TD_SEEK
 DEVCMD TD_FORMAT
 DEVCMD TD_REMOVE
 DEVCMD TD_CHANGENUM
 DEVCMD TD_CHANGESTATE
 DEVCMD TD_PROTSTATUS
 DEVCMD TD_RAWREAD
 DEVCMD TD_RAWWRITE
 DEVCMD TD_GETDRIVETYPE
 DEVCMD TD_GETNUMTRACKS
 DEVCMD TD_ADDCHANGEINT
 DEVCMD TD_REMCHANGEINT
 DEVCMD TD_GETGEOMETRY
 DEVCMD TD_EJECT
 DEVCMD TD_LASTCOMM

ETD_WRITE      = CMD_WRITE|TDF_EXTCOM
ETD_READ       = CMD_READ|TDF_EXTCOM
ETD_MOTOR      = TD_MOTOR|TDF_EXTCOM
ETD_SEEK       = TD_SEEK|TDF_EXTCOM
ETD_FORMAT     = TD_FORMAT|TDF_EXTCOM
ETD_UPDATE     = CMD_UPDATE|TDF_EXTCOM
ETD_CLEAR      = CMD_CLEAR|TDF_EXTCOM
ETD_RAWREAD    = TD_RAWREAD|TDF_EXTCOM
ETD_RAWWRITE   = TD_RAWWRITE|TDF_EXTCOM

* struct IOExtTD
 rsset iostd_SIZE
iotd_Count	rs.l 1
iotd_SecLabel	rs.l 1
iotd_SIZE	rs

* struct DriveGeometry
 rsreset
dg_SectorSize	rs.l 1
dg_TotalSectors rs.l 1
dg_Cylinders	rs.l 1
dg_CylSectors	rs.l 1
dg_Heads	rs.l 1
dg_TrackSectors rs.l 1
dg_BufMemType	rs.l 1
dg_DeviceType	rs.b 1
dg_Flags	rs.b 1
dg_Reserved	rs.w 1
dg_SIZEOF	rs

DG_DIRECT_ACCESS	= 0
DG_SEQUENTIELL_ACCESS	= 1
DG_PRINTER		= 2
DG_PROCESSOR		= 3
DG_WORM 		= 4
DG_CDROM		= 5
DG_SCANNER		= 6
DG_OPTICAL_DISK 	= 7
DG_MEDIUM_CHANGER	= 8
DG_COMMUNICATION	= 9
DG_UNKNOWN		= 31
 BITDEF DG,REMOVABLE,0

 BITDEF IOTD,INDEXSYNC,4
 BITDEF IOTD,WORDSYNC,5
TD_LABELSIZE	= 16
 BITDEF TD,ALLOW_NON_3_5,0
DRIVE3_5	= 1
DRIVE5_25	= 2

TDERR_NotSpecified equ 20
TDERR_NoSecHdr equ 21
TDERR_BadSecPreamble equ 22
TDERR_BadSecID equ 23
TDERR_BadHdrSum equ 24
TDERR_BadSecSum equ 25
TDERR_TooFewSecs equ 26
TDERR_BadSecHdr equ 27
TDERR_WriteProt equ 28
TDERR_DiskChanged equ 29
TDERR_SeekError equ 30
TDERR_NoMem equ 31
TDERR_BadUnitNum equ 32
TDERR_BadDriveType equ 33
TDERR_DriveInUse equ 34
TDERR_PostReset equ 35

* struct TDU_PublicUnit
 rsset unit_SIZE
tdu_Comp01Track rs.w 1
tdu_Comp10Track rs.w 1
tdu_Comp11Track rs.w 1
tdu_StepDelay	rs.l 1
tdu_SettleDelay rs.l 1
tdu_RetryCnt	rs.b 1
tdu_PubFlags	rs.b 1
tdu_CurrTrk	rs.w 1
tdu_CalibrateDelay rs.l 1
tdu_Counter	rs.l 1
tdu_PublicUnitSIZE rs
 BITDEF TDP,NOCLICK,0

 endc
