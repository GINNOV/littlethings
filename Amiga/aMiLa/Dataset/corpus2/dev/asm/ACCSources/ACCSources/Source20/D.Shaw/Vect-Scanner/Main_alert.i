; Undocumented bug in DisplayAlert. All Texts must be an even number of bytes
;long, including the terminating 0. Failure to follow this will crash the
;system and will corrupt the display of your alert.
;			 	 01010101010101010101010101010101010101010101010101010101010101010101010101010101     
alert_text	dc.w		180
		dc.b		15
		dc.b		'>>>>>>> VECTOR SCANNER ALERT <<<<<<< ',0
		dc.b		$ff

		dc.w		10
		dc.b		25
		dc.b		'An execbase reset vector has been changed.Please check for',0
		dc.b		$ff
	
		dc.w		10
		dc.b		35
		dc.b		'hello',0
		dc.b		$00
		even
