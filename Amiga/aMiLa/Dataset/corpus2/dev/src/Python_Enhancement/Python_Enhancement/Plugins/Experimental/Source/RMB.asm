				;
				;Checking the register $DFF016 for the right
				;mouse button, to be used as a program hold.
				;Part of the Python_Enhancement suite.
				;
				;Assembled with a68k.
				;
				;Linked with blink.
				;
rmb:				;
	btst	#2,$dff016	;Check to see if the right mouse button is
				;pressed.
	bne	rmb		;IF NOT then wait until it is.
				;
	clr.l	d0		;Ensure return code is 0.
				;
	rts			;Return to calling routine.
				;
	END			;
