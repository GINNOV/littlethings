	IFND	IFF_ILBM_I
IFF_ILBM_I	SET	1

	STRUCTURE	BitmapHeader,0
		UWORD	bmhd_w
		UWORD	bmhd_h
		WORD	bmhd_x
		WORD	bmhd_y
		UBYTE	bmhd_nPlanes
		UBYTE	bmhd_Masking
		UBYTE	bmhd_Compression
		UBYTE	bmhd_pad1
		UWORD	bmhd_TransparentColor
		UBYTE	bmhd_xAspect
		UBYTE	bmhd_yAspect
		WORD	bmhd_PageWidth
		WORD	bmhd_PageHeight
		LABEL	bmhd_SIZEOF

	STRUCTURE	DestMerge,0
		UBYTE	dm_depth
		UBYTE	dm_pad1
		UWORD	dm_PlanePick
		UWORD	dm_PlaneOnOff
		UWORD	dm_PlaneMask
		LABEL	dm_SIZEOF

	STRUCTURE	CamgChunk,0
		ULONG	cc_ViewModes
		LABEL	cc_SIZEOF

	ENDC ; IFF_ILBM_I
