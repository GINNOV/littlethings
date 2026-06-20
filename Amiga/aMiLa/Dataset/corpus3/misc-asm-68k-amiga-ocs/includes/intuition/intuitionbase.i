	IFND	INTUITION_INTUITIONBASE_I
INTUITION_INTUITIONBASE_I	SET	1
	IFND	EXEC_TYPES_I
	INCLUDE	"exec/types.i"
	ENDC
	IFND	EXEC_LIBRARIES_I
	INCLUDE	"exec/libraries.i"
	ENDC
	IFND	GRAPHICS_VIEW_I
	INCLUDE	"graphics/view.i"
	ENDC
	rsreset
IntuitionBase	rs.b	0
ib_LibNode	rs.b	LIB_SIZE
ib_ViewLord	rs.b	v_SIZEOF
ib_ActiveWindow	rs.l	1
ib_ActiveScreen	rs.l	1
ib_FirstScreen	rs.l	1
	ENDC

