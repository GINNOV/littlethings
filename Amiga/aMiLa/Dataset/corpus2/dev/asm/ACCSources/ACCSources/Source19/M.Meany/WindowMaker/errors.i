
; Error messages for status line
;				 0123456789012345678901234567890123456789
NoError		dc.b		'Ok.                                              ',0
		even
ErrOpenUser	dc.b		'Could not open a new window for editing.         ',0
		even
ErrNoPathName	dc.b		'Could not form a correct pathname from selection!',0
		even
ErrCancelSel	dc.b		"Operation aborted, CANCEL selected!              ",0
		even
ErrOpenEdit	dc.b		'Could not open Edit window.                      ',0
		even
ErrNoOutFile	dc.b		'Could not open file for writing.                 ',0
		even
ErrNoInFile	dc.b		'Could not open file for reading.                 ',0
		even
ErrNoSrcFile	dc.b		'Could not open source file for writing.          ',0
		even
ErrWrongHeader	dc.b		'Load aborted, not a WindowMaker data file!       ',0
		even
ErrSaveOk	dc.b		'Data file saved Ok.                              ',0
		even
ErrSaveSrcOk	dc.b		'Source file saved Ok.                            ',0
		even
ErrOpenOk	dc.b		'Opened new window for editing.                   ',0
		even
ErrActivate	dc.b		'Window editor now activated!                     ',0
		even
ErrSleep	dc.b		'Window editor now sleeping!                      ',0
		even

; Dummy errors for testing.

EditErr		dc.b		'Edit Selected.                          ',0
		even
LoadErr		dc.b		'Load Selected.                          ',0
		even
SaveFErr	dc.b		'Save File Selected.                     ',0
		even
SaveSErr	dc.b		'Save Source Selected.                   ',0
		even
AboutErr	dc.b		'Programmed by Mark Meany, © December 91.',0
		even




