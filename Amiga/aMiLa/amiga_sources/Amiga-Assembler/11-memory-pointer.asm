START:
	; load address of MYMEMORY into address register 0
	lea	MYMEMORY,a0
	nop
	
MYMEMORY:
	dc.b "Hello World from Amiga Memory",0
	even