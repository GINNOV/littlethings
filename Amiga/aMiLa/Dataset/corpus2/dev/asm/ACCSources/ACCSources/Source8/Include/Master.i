
; Master includer.

; This file is for lazy people who would rather include just one file at
;the start of their program. This file will cause all my other include files,
;which hold library offsets, to load in. 

; Note if you want any of the structure include files to load in then you 
;will have to include these seperately.

	include	diskfont_lib.i		spelling ?
	include	dos_lib.i
	include	exec_lib.i
	include	graphics_lib.i
	include	intuition_lib.i
	include	layers_lib.i
	
