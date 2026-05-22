BLOCK_SIZE equ 100	; Constant value

START:
	move.l #BLOCK_SIZE-1,d7
	lea SOURCE,a0
	lea DESTINATION,a1
	
	; do while loop
.copy:
	move.b (a0)+,(a1)+
	beq.s .exit
	dbf d7,.copy
	
.exit
	move.l $0,d7
	rts
	
SOURCE:
	dc.b "Block of some code to copy in RAM of Amiga 1200."
	even
	
DESTINATION:
	ds.b BLOCK_SIZE
	even