 ifnd RESOURCES_DISK_I
RESOURCES_DISK_I set 1
*
*  resources/disk.i
*  Release 3.1
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

 ifnd EXEC_TYPES_I
 include "exec/types.i"
 endc
 ifnd EXEC_LISTS_I
 include "exec/lists.i"
 endc
 ifnd EXEC_PORTS_I
 include "exec/ports.i"
 endc
 ifnd EXEC_INTERRUPTS_I
 include "exec/interrupts.i"
 endc
 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc

* struct DiscResourceUnit
 rsset mn_SIZE
dru_DiscBlock	rs.b is_SIZE
dru_DiscSync	rs.b is_SIZE
dru_Index	rs.b is_SIZE
dru_SIZE	rs

* struct DiscResource
 rsset lib_SIZE
dr_Current	rs.l 1
dr_Flags	rs.b 1
dr_pad		rs.b 1
dr_SysLib	rs.l 1
dr_CiaResource	rs.l 1
dr_UnitID	rs.l 4
dr_Waiting	rs.b lh_SIZE
dr_DiscBlock	rs.b is_SIZE
dr_DiscSync	rs.b is_SIZE
dr_Index	rs.b is_SIZE
dr_CurrTask	rs.l 1
dr_SIZE 	rs

	BITDEF	DR_ALLOC0,0
	BITDEF	DR_ALLOC1,1
	BITDEF	DR_ALLOC2,2
	BITDEF	DR_ALLOC3,3
	BITDEF	DR_ACTIVE,7

DSKDMAOFF	= $4000

DISKNAME macro
	dc.b "disk.resource",0
	even
	endm

	LIBINIT LIB_BASE
	LIBDEF	DR_ALLOCUNIT
	LIBDEF	DR_FREEUNIT
	LIBDEF	DR_GETUNIT
	LIBDEF	DR_GIVEUNIT
	LIBDEF	DR_GETUNITID
	LIBDEF	DR_READUNITID
DR_LASTCOMM	= DR_READUNITID

DRT_AMIGA	= $00000000
DRT_37422D2S	= $55555555
DRT_EMPTY	= $ffffffff
DRT_150RPM	= $aaaaaaaa

 endc
