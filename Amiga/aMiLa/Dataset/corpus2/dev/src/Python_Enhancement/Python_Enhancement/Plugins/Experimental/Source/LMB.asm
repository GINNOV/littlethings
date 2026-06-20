				;
				;The standard left mouse button hold
				;routine used by almost everyone... :)
				;Part of the Python_Enhancement suite.
				;
				;Assembled with a68k.
				;
				;Linked with blink.
				;
lmb:				;
	btst	#6,$bfe001	;Check to see if the left mouse button is
				;pressed.
	bne	lmb		;IF NOT then wait until it is.
				;
	clr.l	d0		;Ensure return code is 0.
				;
	rts			;Return to calling routine.
				;
	END			;
