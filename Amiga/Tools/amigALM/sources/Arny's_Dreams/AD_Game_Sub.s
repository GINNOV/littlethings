
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      A R N Y ' S   D R E A M S	            *
*                      ===========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                            GAME SUB MODULE                              *
*                            ---------------                              *
*                                                                         *
*                                                                         *
***************************************************************************






***************************************************************************

Update_Camera

* Synopsis:
* These sub move the camera ( 320x224 views in the 512x512 Game Bitmap)

* In:
* Camera_x & Camera_y are the top left edge of the 320x224 views (screen)

***************************************************************************



	H_UPDATE_CAMERA

	rts






***************************************************************************

Get_V_Mask_Info

* Synopsis:
* Test 4 pixels in 512x512x1 Game_Base_Mask at position x,y
* and return their value.
*
*
*    Space        0          pixel 0 are at x,y
*          _______1________  pixel 1 are at x,y+1
*    Ground / / / 2  /  /    pixel 2 are at x,y+2
*          / / /  3 /  /     pixel 3 are at x,y+3

* In:
* d0, d1 are x and y coordinates.

* Out:
* d0, d1, d2, d3 are the value of the pixel 0,1,2 and 3.
* Return value are 0 for pixel off and 1 for pixel on.

***************************************************************************



                  lea	Game_Base_Mask,a0
	move	d0,d4
                  lsr	#3,d0
                  bclr	#0,d0
	add	d0,a0
	lsl	#6,d1
	add	d1,a0
	move	(a0),d0
	move	64(a0),d1
	move	128(a0),d2
	move	192(a0),d3
	and	#$f,d4
	sub	#$f,d4
	neg	d4
	lsr	d4,d0
	lsr	d4,d1
	lsr	d4,d2
	lsr	d4,d3
	moveq	#1,d4
	and	d4,d0
	and	d4,d1
	and	d4,d2
	and	d4,d3

	rts






***************************************************************************

Get_H_Mask_Info

* Synopsis:
* Test 2 pixels in 512x512x1 Game_Base_Mask at position x,y
* and return their value.
*
*                        |
* pixel 0 are at x,y    0|1        pixel 1 are at x+1,y
*                        |

* In:
* d0, d1 are x and y coordinates.

* Out:
* d0, d1 are the value of the pixel 0 and 1
* Return value are 0 for pixel off and 1 for pixel on.

***************************************************************************



                  lea	Game_Base_Mask,a0
	move	d0,d2
	move	d0,d3
	addq	#1,d3

	lsl	#6,d1
	add	d1,a0

                  lsr	#3,d0
                  bclr	#0,d0
	move	(a0,d0.w),d0

                  lsr	#3,d3
                  bclr	#0,d3
	move	(a0,d3.w),d1

	and	#$f,d2
	sub	#$f,d2
	neg	d2
	lsr	d2,d0
	lsr	d2,d1
	moveq	#1,d2
	and	d2,d0
	and	d2,d1

	rts




