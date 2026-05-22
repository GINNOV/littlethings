; Image data for AppIcon.S
;
; © Copyright 1993 Paul Firth
;

APP_IMAGE1	dc.w		0,0				;left egde, top edge
		dc.w		49,20				;width,hight
		dc.w		2				;depth
		dc.l		APPICON1_DATA			;image data
		dc.b		3,0				;planepick, planeonoff
		dc.l		NULL				;next image
		
APP_IMAGE2	dc.w		0,0
		dc.w		49,20
		dc.w		2
		dc.l		APPICON2_DATA
		dc.b		3,0
		dc.l		NULL
;----------------------------------------------------------------------------
APP_DISKOBJ	dc.w		NULL				;magic
		dc.w		NULL				;version

;embeded gad struct :

		dc.l		NULL				;next gad
		dc.w		0,0				;left, top
		dc.w		49,21				;width,hight
		dc.w		GADGHIMAGE			;flags
		dc.w		NULL				;activation
		dc.w		NULL				;gad type
		dc.l		APP_IMAGE1			;render image
		dc.l		APP_IMAGE2			;select image
		dc.l		NULL				;gadget text
		dc.l		NULL				;mutual exclude
		dc.l		NULL				;special info
		dc.w		0				;gadget id
		dc.l		NULL				;user data

; end of embedded.

		dc.w		NULL				;icon type
		dc.w		NULL				;pad
		dc.l		NULL				;default tool
		dc.l		NULL				;tool type array
		dc.l		NULL				;current x
		dc.l		NULL				;current y
		dc.l		NULL				;drawer struct
		dc.l		NULL				;tool window - only applies to tools
		dc.l		NULL				;stacksize - only applies to tools
;----------------------------------------------------------------------------
		section		appimages,data_c

APPICON1_DATA	dc.w		$0000,$0000,$0000,$8000,$0000,$0000,$0001,$8000
		dc.w		$0000,$0000,$0011,$8000,$0000,$0000,$0031,$8000
		dc.w		$0000,$0000,$0231,$8000,$0000,$0000,$0631,$8000
		dc.w		$0000,$0000,$4631,$8000,$0000,$0000,$C631,$8000
		dc.w		$0000,$0000,$C631,$8000,$0000,$0000,$C631,$8000
		dc.w		$0000,$0000,$C631,$8000,$0000,$0000,$C631,$8000
		dc.w		$0000,$0000,$C631,$8000,$0000,$FFFF,$C631,$8000
		dc.w		$0000,$0000,$0631,$8000,$001F,$FFFF,$FE31,$8000
		dc.w		$0000,$0000,$0031,$8000,$03FF,$FFFF,$FFF1,$8000
		dc.w		$0000,$0000,$0001,$8000,$7FFF,$FFFF,$FFFF,$8000
; Plane 1:
		dc.w		$FFFF,$FFFF,$FFFF,$0000,$C000,$0000,$0000,$0000
		dc.w		$C7FF,$FFFF,$FFE0,$0000,$C600,$0000,$0000,$0000
		dc.w		$C63F,$FFFF,$FC00,$0000,$C630,$0000,$0000,$0000
		dc.w		$C631,$FFFF,$8000,$0000,$C631,$8000,$0000,$0000
		dc.w		$C631,$8000,$0000,$0000,$C631,$8000,$0000,$0000
		dc.w		$C631,$8000,$0000,$0000,$C631,$8000,$0000,$0000
		dc.w		$C631,$8000,$0000,$0000,$C631,$0000,$0000,$0000
		dc.w		$C630,$0000,$0000,$0000,$C620,$0000,$0000,$0000
		dc.w		$C600,$0000,$0000,$0000,$C400,$0000,$0000,$0000
		dc.w		$C000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
		
APPICON2_DATA	dc.w		$FFFF,$FFFF,$FFFF,$0000,$C000,$0000,$0000,$0000
		dc.w		$C7FF,$FFFF,$FFE0,$0000,$C600,$0000,$0000,$0000
		dc.w		$C63F,$FFFF,$FC00,$0000,$C630,$0000,$0000,$0000
		dc.w		$C631,$FFFF,$8000,$0000,$C631,$8000,$0000,$0000
		dc.w		$C631,$8000,$0000,$0000,$C631,$8000,$0000,$0000
		dc.w		$C631,$8000,$0000,$0000,$C631,$8000,$0000,$0000
		dc.w		$C631,$8000,$0000,$0000,$C631,$0000,$0000,$0000
		dc.w		$C630,$0000,$0000,$0000,$C620,$0000,$0000,$0000
		dc.w		$C600,$0000,$0000,$0000,$C400,$0000,$0000,$0000
		dc.w		$C000,$0000,$0000,$0000,$8000,$0000,$0000,$0000
; Plane 2:
		dc.w		$0000,$0000,$0000,$8000,$0000,$0000,$0001,$8000
		dc.w		$0000,$0000,$0011,$8000,$0000,$0000,$0031,$8000
		dc.w		$0000,$0000,$0231,$8000,$0000,$0000,$0631,$8000
		dc.w		$0000,$0000,$4631,$8000,$0000,$0000,$C631,$8000
		dc.w		$0000,$0000,$C631,$8000,$0000,$0000,$C631,$8000
		dc.w		$0000,$0000,$C631,$8000,$0000,$0000,$C631,$8000
		dc.w		$0000,$0000,$C631,$8000,$0000,$FFFF,$C631,$8000
		dc.w		$0000,$0000,$0631,$8000,$001F,$FFFF,$FE31,$8000
		dc.w		$0000,$0000,$0031,$8000,$03FF,$FFFF,$FFF1,$8000
		dc.w		$0000,$0000,$0001,$8000,$7FFF,$FFFF,$FFFF,$8000	