*
* Sine Table of the form {16384*sin(x/512*2PI):x=0,1,...,511} Tablesize=1K
* Note-Angles are in 512ths of 2PI Radians!
* ( ^ Only Sailors use degrees.... )
* So 90Deg is at Word 128 , 180Deg is at Word 256 etc...
*
sinetab:
 dc.w $0,$C9,$192,$25B,$324,$3ED,$4B5,$57E,$646,$70E,$7D6,$89D,$964,$A2B,$AF1,$BB7,$C7C,$D41,$E06,$ECA,$F8D,$1050,$1112,$11D3,$1294,$1354,$1413,$14D2,$1590,$164C,$1709,$17C4
 dc.w $187E,$1937,$19EF,$1AA7,$1B5D,$1C12,$1CC6,$1D79,$1E2B,$1EDC,$1F8C,$203A,$20E7,$2193,$223D,$22E7,$238E,$2435,$24DA,$257E,$2620,$26C1,$2760,$27FE,$289A,$2935,$29CE,$2A65,$2AFB,$2B8F,$2C21,$2CB2
 dc.w $2D41,$2DCF,$2E5A,$2EE4,$2F6C,$2FF2,$3076,$30F9,$3179,$31F8,$3274,$32EF,$3368,$33DF,$3453,$34C6,$3537,$35A5,$3612,$367D,$36E5,$374B,$37B0,$3812,$3871,$38CF,$392B,$3984,$39DB,$3A30,$3A82,$3AD3
 dc.w $3B21,$3B6D,$3BB6,$3BFD,$3C42,$3C85,$3CC5,$3D03,$3D3F,$3D78,$3DAF,$3DE3,$3E15,$3E45,$3E72,$3E9D,$3EC5,$3EEB,$3F0F,$3F30,$3F4F,$3F6B,$3F85,$3F9C,$3FB1,$3FC4,$3FD4,$3FE1,$3FEC,$3FF5,$3FFB,$3FFF
 dc.w $4000,$3FFF,$3FFB,$3FF5,$3FEC,$3FE1,$3FD4,$3FC4,$3FB1,$3F9C,$3F85,$3F6B,$3F4F,$3F30,$3F0F,$3EEB,$3EC5,$3E9D,$3E72,$3E45,$3E15,$3DE3,$3DAF,$3D78,$3D3F,$3D03,$3CC5,$3C85,$3C42,$3BFD,$3BB6,$3B6D
 dc.w $3B21,$3AD3,$3A82,$3A30,$39DB,$3984,$392B,$38CF,$3871,$3812,$37B0,$374B,$36E5,$367D,$3612,$35A5,$3537,$34C6,$3453,$33DF,$3368,$32EF,$3274,$31F8,$3179,$30F8,$3076,$2FF2,$2F6C,$2EE4,$2E5A,$2DCF
 dc.w $2D41,$2CB2,$2C21,$2B8F,$2AFB,$2A65,$29CE,$2935,$289A,$27FE,$2760,$26C1,$2620,$257E,$24DA,$2435,$238E,$22E7,$223D,$2193,$20E7,$203A,$1F8C,$1EDC,$1E2B,$1D79,$1CC6,$1C12,$1B5D,$1AA7,$19EF,$1937
 dc.w $187E,$17C4,$1709,$164C,$1590,$14D2,$1413,$1354,$1294,$11D3,$1112,$1050,$F8D,$ECA,$E06,$D41,$C7C,$BB7,$AF1,$A2B,$964,$89D,$7D6,$70E,$646,$57E,$4B5,$3ED,$324,$25B,$192,$C9
 dc.w $0,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4B,$FA82,$F9BA,$F8F2,$F82A,$F763,$F69C,$F5D5,$F50F,$F449,$F384,$F2BF,$F1FA,$F136,$F073,$EFB0,$EEEE,$EE2D,$ED6C,$ECAC,$EBED,$EB2E,$EA70,$E9B4,$E8F7,$E83C
 dc.w $E782,$E6C9,$E611,$E559,$E4A3,$E3EE,$E33A,$E287,$E1D5,$E124,$E074,$DFC6,$DF19,$DE6D,$DDC3,$DD19,$DC72,$DBCB,$DB26,$DA82,$D9E0,$D93F,$D8A0,$D802,$D766,$D6CB,$D632,$D59B,$D505,$D471,$D3DF,$D34E
 dc.w $D2BF,$D231,$D1A6,$D11C,$D094,$D00E,$CF8A,$CF07,$CE87,$CE08,$CD8C,$CD11,$CC98,$CC21,$CBAD,$CB3A,$CAC9,$CA5B,$C9EE,$C983,$C91B,$C8B5,$C850,$C7EE,$C78F,$C731,$C6D5,$C67C,$C625,$C5D0,$C57E,$C52D
 dc.w $C4DF,$C493,$C44A,$C403,$C3BE,$C37B,$C33B,$C2FD,$C2C1,$C288,$C251,$C21D,$C1EB,$C1BB,$C18E,$C163,$C13B,$C115,$C0F1,$C0D0,$C0B1,$C095,$C07B,$C064,$C04F,$C03C,$C02C,$C01F,$C014,$C00B,$C005,$C001
 dc.w $C000,$C001,$C005,$C00B,$C014,$C01F,$C02C,$C03C,$C04F,$C064,$C07B,$C095,$C0B1,$C0D0,$C0F1,$C115,$C13B,$C163,$C18E,$C1BB,$C1EB,$C21D,$C251,$C288,$C2C1,$C2FD,$C33B,$C37B,$C3BE,$C403,$C44A,$C493
 dc.w $C4DF,$C52D,$C57E,$C5D0,$C625,$C67C,$C6D5,$C731,$C78F,$C7EE,$C850,$C8B5,$C91B,$C983,$C9EE,$CA5B,$CAC9,$CB3A,$CBAD,$CC21,$CC98,$CD11,$CD8C,$CE08,$CE87,$CF08,$CF8A,$D00E,$D094,$D11C,$D1A6,$D231
 dc.w $D2BF,$D34E,$D3DF,$D471,$D505,$D59B,$D632,$D6CB,$D766,$D802,$D8A0,$D93F,$D9E0,$DA82,$DB26,$DBCB,$DC72,$DD19,$DDC3,$DE6D,$DF19,$DFC6,$E074,$E124,$E1D5,$E287,$E33A,$E3EE,$E4A3,$E559,$E611,$E6C9
 dc.w $E782,$E83C,$E8F7,$E9B4,$EA70,$EB2E,$EBED,$ECAC,$ED6C,$EE2D,$EEEE,$EFB0,$F073,$F136,$F1FA,$F2BF,$F384,$F449,$F50F,$F5D5,$F69C,$F763,$F82A,$F8F2,$F9BA,$FA82,$FB4B,$FC13,$FCDC,$FDA5,$FE6E,$FF37

*Trig Macros and routines...
*All these assume A4 points at Sinetab!!!
*
*Sin Dx	 Takes "angle" in Dx returns 2^14*sin("angle") in Dx

Sin	MACRO
	and.w #$1ff,\1
	lsl.w #1,\1
	move.w (a4,\1.w),\1
	ENDM

* Cos Dx 

Cos	MACRO
	add.w #$80,\1
	sin \1
	ENDM

* Tan Dx

Tan	MACRO
	move \1,-(sp)			;stack \1
	cos \1
	move \1,-(sp)			;stack cos \1
	bne.s notzero_\@	

;division by zero....	
	lea 4(sp),sp			;restore stack
	move #$7fff,\1			;As close to signed infinity as poss!
	bra.s leavez_\@	
	
notzero_\@:

	move 2(sp),\1			;get \1	
	sin \1
	ext.l \1			;extended to a long word
	lsl.l #8,\1
	lsl.l #6,\1			;*16384

	divs (sp),\1			;do the divide
	lea 4(sp),sp			;reset the stack	
		
leavez_\@:
	ENDM
	
;
;trigdiv d? -- divides out the 16384 from the data reg d?
;

trigdiv	MACRO
	lsr.l #8,\1
	lsr.l #6,\1
	ENDM

* Ok thats that , the above are macros ... may need to use these
* in subroutines if mem is tight....
* Tan is a mess ....!! Create a Tantable if not good enough
	
