;"amendlib.s"   JY 1989
;Try and work this one out.
;It's only a short piece of code.
;I wrote this over a year ago, so don't ask me any questions about it.
;I found it looking through one of my old souce disks.
;
;It amends the OldOpenLibrary call using the SetFunction call in Exec.
;Find a use for it. It may have potential for virus detecting?!


	move.l	4,a6
	move.l	#end-start,d0
	move.l	#0,d1
	jsr	-198(a6)	;Allocate memory for program
	move.l	d0,memory
	beq	nomem
	lea	-408(a6),a1	;OldOpenLibrary
	move	(a1)+,jumpcom	;copy old jump address
	move.l	(a1),jumpcom+2	;into new program
	move.l	memory,a0
	lea	start,a1
	move	#end-start-1,d1	;length-1
translp	move.b	(a1)+,(a0)+	;transfer program to memory
	dbra	d1,translp
	move.l	4,a1		;library
	move.l	#-408,a0	;offset
	move.l	memory,d0	;jump
	jsr	-420(a6)	;SetFunction
	jsr	-414(a6)	;CloseLibrary
	move	#$aaa,d0
	move	#-1,d1
delay1	move	d0,$dff180
	dbra	d1,delay1
nomem	rts

memory	dc.l	0

	opt p+
start	move	#0,d0
	move	#-1,d1
delay2	move	d0,$dff180
	dbra	d1,delay2
jumpcom	ds.b	6
end

