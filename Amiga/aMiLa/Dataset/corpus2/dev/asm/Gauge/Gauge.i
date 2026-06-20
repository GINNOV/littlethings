

	;$VER: Gauge.i by Andry of PEGAS 0.1 (24.9.97)
	;Include file for Gauge.asm


    IFND EXEC_TYPES_I
    INCLUDE "exec/types.i"
    ENDC ; EXEC_TYPES_I




GA_STOP	=	-1


;The flags to be passed to d0 when calling ga_OpenGauge()
;--------------------------------------------------------
;If this flag is set, you have to specify a value which represents 100% .
;The value you pass as an UWORD in d1. (The default for this value is 100)
;See also the BUGS section in Gauge.asm
	BITDEF	GA,100VALUE,0

;If set, you have to define a time period in seconds.  The progress window
;will be first opened after this time period. If not set, it will
;be opened immediatly. The delay is expected in d2 (LONG).
;Don't bother the user with short appearing gauges (if you design your program
;for a 020/14MHz don't forget there exist several 060's and it will come new...).
;NOTE: ga_OpenGauge() will not open the window immediatly, therefore it may
; success and the failure comes first with some ga_RedrawGauge() call, which may
; try to open it. That means you never know if the window was really opened.
; For normal use it should suffice, but if you'd like to check it you have to
; change the main code (which is permitted).
	BITDEF	GA,SLEEPTIME,1

;If set, a pointer to a screen is expected in a0.
;The gauge-window will appear on that screen.
	BITDEF	GA,SCREEN,2


;If set, the system-default font will be used otherwise screen font will be used.
	BITDEF	GA,SYSTEMFONT,3


;If set, a stop button will be enabled. If the user presses the stop-button,
;you receive GA_STOP from ga_RedrawGauge(). That means, if you set this flag,
;you have to check for the result of ga_RedrawGauge() else you don't have to.
; Note that the gauge-window will not close until you call ga_CloseGauge().
	BITDEF	GA,ENABLESTOP,4

;The nominal size of a progress-bar is 128 pixels.
;If you set this flag, you must set width of the progress bar (in pixels).
;The width is expected in d3 (WORD)
;See also the BUGS section in Gauge.asm
	BITDEF	GA,WIDTH,5


;This overrides the GAF_SCREEN flag. If set a pointer to a window is expected
;in a0. The gauge window will appear on the same screen as the window.
	BITDEF	GA,WINDOW,6


;The gauge window will not be centered. Left and top values will be used.
;Those are expected in d4. Left offset represent bits 31-16 (MSW)
;and top offset represent bits 15-0 (LSW). Those offsets are relative
;to left-top corner of a screen resp. window.
;If this flag is zero (default), the gauge window will be centered either
;on a defined screen (GAF_SCREEN) or within bounds of a defined window (GAF_WINDOW).
	BITDEF	GA,NOCENTER,7


;If set, a pointer to a new gauge-window title is expected in a2,
;else default title will be used.
	BITDEF	GA,WTITLE,8


;This flag allows you to use structure GaugeParams as a parameter instead
;of setting all the registers. The structure is expected in a0.
;Each item of this structure will be first used when the corresponding flag
;is set. If not set, the corresponding item is ignored.
;All other registers are ignored.
	BITDEF	GA,STRUCTURE,9



	STRUCTURE GaugeParams,0
	APTR	gapa_ScrWinAdr	;as register a0
	APTR	gapa_StopText	;as a1 (text for STOP button)
	APTR	gapa_Title	;as a2 (gauge-window title)
	LONG	gapa_Delay	;as d2 (initial delay in seconds)
	LONG	gapa_WinPos	;as d4 (two WORDs in a LONG which represent
				;the left and top offsets of the gauge-window)
	UWORD	gapa_100Value	;as d1 (a value which is 100%)
	UWORD	gapa_BarWidth	;as d3 (width of the progress bar)
	LABEL	gapa_SIZEOF
