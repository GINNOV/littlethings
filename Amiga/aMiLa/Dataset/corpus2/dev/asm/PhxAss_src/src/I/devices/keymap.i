 ifnd DEVICES_KEYMAP_I
DEVICES_KEYMAP_I set 1
*
*  devices/keymap.i
*  Release 2.0
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

* struct KeyMap
 rsreset
km_LoKeyMapTypes	rs.l 1
km_LoKeyMap		rs.l 1
km_LoCapsable		rs.l 1
km_LoRepeatable 	rs.l 1
km_HiKeyMapTypes	rs.l 1
km_HiKeyMap		rs.l 1
km_HiCapsable		rs.l 1
km_HiRepeatable 	rs.l 1
km_SIZEOF		rs

* struct KeyMapNode
 rsreset
kn_Node 	rs.b ln_SIZE
kn_KeyMap	rs.b km_SIZEOF
kn_SIZEOF	rs

* struct KeyMapResource
kr_Node 	rs.b ln_SIZE
kr_List 	rs.b lh_SIZE
kr_SIZEOF	rs

 BITDEF KC,NOP,7
 BITDEF KC,SHIFT,0
 BITDEF KC,ALT,1
 BITDEF KC,CONTROL,2
 BITDEF KC,DOWNUP,3
 BITDEF KC,DEAD,5
 BITDEF KC,STRING,6
KC_NOQUAL	= 0
KC_VANILLA	= 7

 BITDEF DP,MOD,0
 BITDEF DP,DEAD,3

DP_2DINDEXMASK	= $0F
DP_2DFACSHIFT	= 4

 endc
