

EditorWindow	dc.w		0,0
		dc.w		640,35
		dc.b		0,1
		dc.l		MENUPICK+CLOSEWINDOW+ACTIVEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		EditorName
		dc.l		0
		dc.l		0
		dc.w		250,55
		dc.w		640,256
		dc.w		WBENCHSCREEN

EditorName	dc.b		'Window Maker © Dec 1991, M.Meany.',0
		even

ProjectMenu	dc.l		0
		dc.w		10,0
		dc.w		80,10
		dc.w		MENUENABLED
		dc.l		ProjectName
		dc.l		NewItem
		dc.w		0,0,0,0

ProjectName	dc.b		'Project',0
		even

NewItem		dc.l		EditItem
		dc.w		0,0
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'N'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

		dc.l		New		; subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'New',0
		even

EditItem	dc.l		LoadItem
		dc.w		0,10
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'E'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

		dc.l		Edit		; Subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'Edit',0
		even

LoadItem	dc.l		SaveFItem
		dc.w		0,22
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'L'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL
		dc.l		Load		;subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'Load File',0
		even

SaveFItem	dc.l		SaveSItem
		dc.w		0,32
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'F'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL
		dc.l		SaveF		;subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'Save File',0
		even

SaveSItem	dc.l		AboutItem
		dc.w		0,42
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'S'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL
		dc.l		SaveS		;subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'Save Source',0
		even

AboutItem	dc.l		QuitItem
		dc.w		0,54
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'A'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL
		dc.l		About		;subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'About',0
		even

QuitItem	dc.l		0
		dc.w		0,66
		dc.w		160,8
		dc.w		ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		'Q'
		dc.b		0
		dc.l		0
		dc.w		MENUNULL
		dc.l		Quit		;subroutine label

.IText		dc.b		0,0,RP_JAM1,0
		dc.w		8,0
		dc.l		0
		dc.l		.ITextText
		dc.l		0

.ITextText	dc.b		'Quit',0
		even



StatusLine	dc.b		2,0,RP_JAM2,0
		dc.w		8,15
		dc.l		0
		dc.l		.StatusText
		dc.l		.StatusLine1

.StatusText	dc.b		'STATUS : ',0
		even

.StatusLine1	dc.b		1,0,RP_JAM2,0
		dc.w		80,15
		dc.l		0
ErrMsgPtr	dc.l		NoError
		dc.l		0

