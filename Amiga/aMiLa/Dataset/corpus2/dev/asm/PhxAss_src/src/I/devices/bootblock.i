 ifnd DEVICES_BOOTBLOCK_I
DEVICES_BOOTBLOCK_I set 1
*
*  devices/bootblock.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1994
*

* struct BB
 rsreset
bb_id		rs.l 1
bb_chksum	rs.l 1
bb_dosblock	rs.l 1
bb_entry	rs
bb_SIZE 	rs

BOOTSECTS	= 2
BBID_DOS macro
 dc.b "DOS",0
 endm
BBID_KICK macro
 dc.b "KICK",0
 endm
BBNAME_DOS	= $444f5300
BBNAME_KICK	= $4b49434b

 endc
