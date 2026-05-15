START:
	; copy memory from SOURCE to DESTINATION
	lea	SOURCE,a0
	lea DESTINATION,a1
	
	move.b (a0)+,(a1)+
	nop
	
SOURCE:
	dc.b "Hello World from Amiga Memory",0
	even
	
DESTINATION:
	ds.b 50