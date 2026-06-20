; ****** Mathematics Sine and Cosine macro definitions ******

; Metacomco Macro Assembler
; Version 1.0 Date: 15-06-88 (Created)

sine		macro
		and.w	#255,\1
		lea	_SinValues(pc),a0
		add.w	\1,\1
		move.w	0(a0,\1.w),\3
		muls	\2,\3
		lsr.l	#8,\3
		ifnd	_SinValues
		bra	_ov_SinValues

_SinValues	dc.w	0,6,13,19,25,31,38,44
		dc.w	50,56,62,68,74,80,86,92
		dc.w	98,104,109,115,121,126,132,137
		dc.w	142,147,152,157,162,167,172,177
		dc.w	181,185,190,194,198,202,206,209
		dc.w	213,216,220,223,226,229,231,234
		dc.w	237,239,241,243,245,247,248,250
		dc.w	251,252,253,254,255,255,256,256
		dc.w	256,256,256,255,255,254,253,252
		dc.w	251,250,248,247,245,243,241,239
		dc.w	237,234,231,229,226,223,220,216
		dc.w	213,209,206,202,198,194,190,185
		dc.w	181,177,172,167,162,157,152,147
		dc.w	142,137,132,126,121,115,109,104
		dc.w	98,92,86,80,74,68,62,56
		dc.w	50,44,38,31,25,19,13,6
		dc.w	0,-6,-13,-19,-25,-31,-38,-44
		dc.w	-50,-56,-62,-68,-74,-80,-86,-92
		dc.w	-98,-104,-109,-115,-121,-126,-132,-137
		dc.w	-142,-147,-152,-157,-162,-167,-172,-177
		dc.w	-181,-185,-190,-194,-198,-202,-206,-209
		dc.w	-213,-216,-220,-223,-226,-229,-231,-234
		dc.w	-237,-239,-241,-243,-245,-247,-248,-250
		dc.w	-251,-252,-253,-254,-255,-255,-256,-256
		dc.w	-256,-256,-256,-255,-255,-254,-253,-252
		dc.w	-251,-250,-248,-247,-245,-243,-241,-239
		dc.w	-237,-234,-231,-229,-226,-223,-220,-216
		dc.w	-213,-209,-206,-202,-198,-194,-190,-185
		dc.w	-181,-177,-172,-167,-162,-157,-152,-147
		dc.w	-142,-137,-132,-126,-121,-115,-109,-104
		dc.w	-98,-92,-86,-80,-74,-68,-62,-56
		dc.w	-50,-44,-38,-31,-25,-19,-13,-6
_ov_SinValues	;
		endc
		endm

;Usage:	sine	<Dx>,<Dy>,<Dz>
;Computes the sine of parameter Dx, multiplies it by Dy
;and returns the result in Dz.
;Notes:	All the parameters but not Dy must be DATA registers.
;	The contents of the registers A0 and Dx will be lost.
;	The parameter Dx is given in the scale 0-255 re-
;	presenting the degree values 0-359, thus +1 in Dx
;	means +360/256 in degrees.


cosine		macro
		add.b	#64,\1
		sine	\1,\2,\3
		endm

;Usage:	cosine	<Dx>,<Dy>,<Dz>
;Computes the cosine of parameter Dx, multiplies it by Dy
;and returns the result in Dz.
;Notes:	All the parameters but not Dy must be DATA registers.
;	The contents of the registers A0 and Dx will be lost.
;	The parameter Dx is given in the scale 0-255 re-
;	presenting the degree values 0-359, thus +1 in Dx
;	means +360/256 in degrees.

