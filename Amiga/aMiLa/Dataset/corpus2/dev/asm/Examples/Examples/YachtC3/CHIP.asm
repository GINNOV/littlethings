  ;If you're using Manx, you're going to have to modify open_libs to copy
  ;this data into CHIP mem. Amoung other deficiencies, Manx asm will not
  ;honor the next SECTION directive with CHIP specifier. Hey, you bought it.

                  SECTION  YachtChip,DATA,CHIP

;===================== IMAGE DATA FOR 6 FACES OF A DIE ===================
; Image data for dice spots.  All 48 bits are used for the image. This data
; must be in Amiga CHIP memory (lower 512K) hence the SECTION directive.

   XDEF    OneSpot,TwoSpot,ThreeSpot,FourSpot,FiveSpot,SixSpot
OneSpot:
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$7E0,0
   dc.w   0,$1FF8,0,0,$1FF8,0,0,$1FF8,0,0,$7E0,0,0,0,0,0,0,0,0,0,0
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0

TwoSpot:
   dc.w   $1F80,0,0,$7FE0,0,0,$7FE0,0,0,$7FE0,0,0,$1F80,0,0,0,0,0,0,0,0
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1f8,0,0,$7FE
   dc.w   0,0,$7FE,0,0,$7FE,0,0,$1F8

ThreeSpot:
   dc.w   $1F80,0,0,$7FE0,0,0,$7FE0,0,0,$7FE0,0,0,$1F80,0,0,0,0,0,0,0,0
   dc.w   0,$7E0,0,0,$1FF8,0,0,$1FF8,0,0,$1FF8,0,0,$7E0,0,0,0,0,0,0,0
   dc.w   0,0,$1F8,0,0,$7FE,0,0,$7FE,0,0,$7FE,0,0,$1F8

FourSpot:
   dc.w   $1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE,$7FE0,0,$7FE,$1F80,0,$1F8
   dc.w   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   dc.w   $1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE,$7FE0,0,$7FE,$1F80,0,$1F8

FiveSpot:
   dc.w   $1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE,$7FE0,0,$7FE,$1F80,0,$1F8
   dc.w   0,0,0,0,0,0,0,$7E0,0,0,$1FF8,0,0,$1FF8,0,0,$1FF8,0,0,$7E0,0
   dc.w   0,0,0,0,0,0,$1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE,$7FE0,0,$7FE
   dc.w   $1F80,0,$1F8

SixSpot:
   dc.w   $1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE,$7FE0,0,$7FE,$1F80,0,$1F8
   dc.w   0,0,0,0,0,0,$1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE,$7FE0,0,$7FE
   dc.w   $1F80,0,$1F8,0,0,0,0,0,0,$1F80,0,$1F8,$7FE0,0,$7FE,$7FE0,0,$7FE
   dc.w   $7FE0,0,$7FE,$1F80,0,$1F8

