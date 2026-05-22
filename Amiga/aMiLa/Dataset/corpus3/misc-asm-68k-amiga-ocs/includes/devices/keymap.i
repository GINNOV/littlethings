	IFND	DEVICES_KEYMAP_I
DEVICES_KEYMAP_I	SET	1
	IFND	EXEC_NODES_I
	INCLUDE	"exec/nodes.i"
	ENDC
	IFND	EXEC_LISTS_I
	INCLUDE	"exec/lists.i"
	ENDC
	rsreset
KeyMap	rs.b	0
km_LoKeyMapTypes	rs.l	1
km_LoKeyMap	rs.l	1
km_LoCapsable	rs.l	1
km_LoRepeatable	rs.l	1
km_HiKeyMapTypes	rs.l	1
km_HiKeyMap	rs.l	1
km_HiCapsable	rs.l	1
km_HiRepeatable	rs.l	1
km_SIZEOF	rs.w	0
	rsreset
KeyMapNode	rs.b	0
kn_Node	rs.b	LN_SIZE
kn_KeyMap	rs.b	km_SIZEOF
kn_SIZEOF	rs.w	0
	rsreset
KeyMapResource	rs.b	0
kr_Node	rs.b	LN_SIZE
kr_List	rs.b	LH_SIZE
kr_SIZEOF	rs.w	0
KCB_NOP	EQU	7
KCF_NOP	EQU	$80
KC_NOQUAL	EQU	0
KC_VANILLA	EQU	7
KCB_SHIFT	EQU	0
KCF_SHIFT	EQU	$01
KCB_ALT	EQU	1
KCF_ALT	EQU	$02
KCB_CONTROL	EQU	2
KCF_CONTROL	EQU	$04
KCB_DOWNUP	EQU	3
KCF_DOWNUP	EQU	$08
KCB_DEAD	EQU	5
KCF_DEAD	EQU	$20
KCB_STRING	EQU	6
KCF_STRING	EQU	$40
DPB_MOD	EQU	0
DPF_MOD	EQU	$01
DPB_DEAD	EQU	3
DPF_DEAD	EQU	$08
DP_2DINDEXMASK	EQU	$0F
DP_2DFACSHIFT	EQU	4
	ENDC

