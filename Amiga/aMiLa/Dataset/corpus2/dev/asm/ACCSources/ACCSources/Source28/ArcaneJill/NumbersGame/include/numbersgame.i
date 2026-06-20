	IFND	NUMBERSGAME_I
NUMBERSGAME_I	set	1

	include	earth/earthbase.i

;============================
;	struct Method
;============================

		rsreset
mth_LevelNode	rs.b	MLN_SIZE	Link to lev_MethodList
mth_ValueNode	rs.b	MLN_SIZE	Link to res_MethodList
mth_Atoms	rs.b	1		Which seeds were used
mth_Type	rs.b	1		Type of this method
mth_Value	rs.w	1		Value produced by this method
mth_Parent1	rs.l	1		Left parent
mth_Parent2	rs.l	1		Right parent
mth_SIZE	rs.w	1

; Legitimate values for mth_Type are:

METHOD_SEED		equ	0
METHOD_SUM		equ	'+'
METHOD_DIFFERENCE	equ	'-'
METHOD_PRODUCT		equ	'*'
METHOD_QUOTIENT		equ	'/'

; Legal values for mth_Value are between 1 and:

MAX_LEGAL_VALUE		equ	$3FFF

;============================
;	struct Result
;============================

		rsreset
res_TreeNode	rs.b	tn_SIZE		Node for binary tree
res_MethodList	rs.b	MLH_SIZE	List of all methods of this value
res_SIZE	rs.w	0

;============================
;	struct Level
;============================

		rsreset
lev_MethodList	rs.b	MLH_SIZE	List of all methods of this level
lev_SIZE	rs.w	0

;============================
;	struct Scheme
;============================

		rsreset
sch_TreeHeader	rs.b	th_SIZE		Tree of Results
sch_Hook	rs.b	h_SIZEOF	Hook structure for tree
sch_Levels	rs.b	8*lev_SIZE	Array of Levels
sch_Self	rs.l	1		Pointer back to TreeHeader
sch_MatchWord	rs.l	1		Magic number
sch_SIZE	rs.w	0

; sch_MatchWord must contain the following constant...

SCH_MAGIC	equ	$C0D1F1ED

	CODE

	SETDATA	a5

	ENDC