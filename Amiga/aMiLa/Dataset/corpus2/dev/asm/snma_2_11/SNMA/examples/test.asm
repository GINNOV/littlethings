* This little example is used to demonstrate global tables of snma.
* If you have addgb'd gbtest.i succesfully, this file should assemble
* just fine with the following command:
* ->rx ShellAsm a.asm
*
* See documents for full explanation.

	move.l	#NUMBER,d0
	HOO	d0,d1
	rts

