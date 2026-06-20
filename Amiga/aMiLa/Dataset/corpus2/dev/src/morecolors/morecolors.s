
I found this in alt.sys.amiga.demos... the text was all over the place
so I had to edit it a bit - I also added the corresponding register
names from the AGA Hardware Reference Manual - the stuff in the brackets.

#####

From: skull@freenet.hut.fi (Juha Lainema)
Subject: Copper Chunky Enchanced
Date: 2 Apr 1994 13:15:24 GMT


Ok, everyone. I promised to send a routine,
that allows you to change more than 100 colours
per line with the copper only, and here it is:			

	dc.w	$01c0,$00ed	;XStop				(HTOTAL)
				;this is what you want to alter:
				;it has to be odd, and the bigger
				;it is, the more you can fit on one
				;line with copper. $ef works on
				;quite all monitors, if they
				;are not too overheated.	

	dc.w	$01c2,$000f	;XStart				(HSSTOP)
	dc.w	$01c4,$0001	;HStart		;dis		(HBSTRT)
	dc.w	$01c6,$0080	;HStop		;dis		(HBSTOP)

	dc.w	$01c8,$0137	;refresh rate (50*312.5/xxx hz)	(VTOTAL)
				;This is the number of raster-
				;lines you have. Want more
				;raster time? Just make this
				;number bigger. Wont work
				;on all monitors. Mine can take
				;up to $13b, friends can take
				;up to $150...

	dc.w	$01ca,$002b	;????		;dis?		(VSSTOP)
	dc.w	$01cc,$010a	;Show End			(VBSTRT)
	dc.w	$01ce,$002e	;ShowStart			(VBSTOP)
	dc.w	$01dc,$53c0	;beam÷con			(BEAMCON0)
	dc.w	$01de,$0000	;????		;dis?		(HSSTRT)
		
Hope you guys can get something out of it....
If you use it, please thank me somewhere, would you?
No real need, but would be fun though.
_

-- 
Skull--- </irtual ÷>reams -- O -&---------- Failright ----(÷/)-+
ˆ skull@freenet.hut.fi      -+- ˆ Exess Is Way To Wisdom  /  ÷ ˆ
ˆ Wanna Buy Sources? Mail!   l  ˆ Gaining Only Hangover.  "÷/" ˆ
+--> Demonstration </Internal Extinction÷> noitartsnomeD <-Amiga

#####
