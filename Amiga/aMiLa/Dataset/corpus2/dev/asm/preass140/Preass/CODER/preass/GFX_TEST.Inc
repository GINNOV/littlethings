; Tags are a general mechanism of extensible data arrays for parameter
; specification and property inquiry. In practice, tags are used in arrays,
; or chain of arrays.

;   STRUCTURE TagItem,0
;	ULONG	ti_Tag		; identifies the type of the data
;	ULONG	ti_Data		; type-specific data
;   LABEL ti_SIZEOF

; constants for Tag.ti_Tag, control tag values
TAG_DONE   = 0  ; terminates array of TagItems. ti_Data unused
TAG_END	   = 0  ; synonym for TAG_DONE
TAG_IGNORE = 1  ; ignore this item, not end of array
TAG_MORE   = 2  ; ti_Data is pointer to another array of TagItems
		  ; note that this tag terminates the current array
TAG_SKIP   = 3  ; skip this and the next ti_Data items

; Tag filter logic specifiers for use with FilterTagItems()

TAGFILTER_AND = 0	; exclude everything but filter hits
TAGFILTER_NOT = 1	; exclude only filter hits

TAG_USER   = $80000000

; --- FLAGS SET BY INTUITION -------------------------------------------------

; The SCREENTYPE bits are reserved for describing various Screen types
; available under Intuition.  

SCREENTYPE	=	$000F	; all the screens types available 

; --- the definitions for the Screen Type ------------------------------------

WBENCHSCREEN	=	$0001	; identifies the Workbench screen
PUBLICSCREEN	=	$0002	; public shared (custom) screen
CUSTOMSCREEN	=	$000F	; for that special look

SHOWTITLEBAR	=	$0010	; this gets set by a call to ShowTitle() 

BEEPING    	=	$0020	; set when Screen is beeping 

CUSTOMBITMAP	=	$0040	; if you are supplying your own BitMap

SCREENBEHIND	=	$0080	; if you want your screen to open behind
				; already open screens

SCREENQUIET	=	$0100	; if you do not want Intuition to render
				; into your screen (gadgets, title)

SCREENHIRES	=	$0200	; do not use lowres gadgets (set by intuition)

STDSCREENHEIGHT	=	-1	; supply in NewScreen.Height
STDSCREENWIDTH	=	-1	; supply in NewScreen.Width

NS_EXTENDED	=	$1000	; means ns_Extenion is valid
AUTOSCROLL	=	$4000	; automatic scrolling of large raster

* New for V39:
PENSHARED	=	$0400	; Screen opener set {SA_SharePens,TRUE}

* Screen attribute tag ID's.  These are used in the ti_Tag field of
* TagItem arrays passed to OpenScreenTagList() (or in the
* ExtNewScreen.Extension field).

* Screen attribute tags.  Please use these versions, not those in
* iobsolete.h.

 TAGPointer=TAG_USER+33
*
*   these items specify items equivalent to fields in NewScreen
    SA_Left=	TAGPointer  ; traditional screen positions and dimensions
    SA_Top=	TagPointer+1
    SA_Width=	TAGPointer+2
    SA_Height=	TAGPointer+3
    SA_Depth=	TAGPointer+4; screen bitmap depth
    SA_DetailPen=TAGPointer+5; serves as default for windows, too
    SA_BlockPen=TAGPointer+6
    SA_Title=	TAGPointer+7    ; default screen title

    SA_Colors=	TAGPointer+8	; ti_Data is an array of struct ColorSpec,
              			; terminated by ColorIndex = -1.  Specifies
				; initial screen palette colors.
				; Also see SA_Colors32 for use under V39.

    SA_ErrorCode=TAGPointer+9	; ti_Data points to LONG error code (values
    				; below)
    SA_Font=	TAGPointer+10 	; equiv. to NewScreen.Font
    SA_SysFont=	TAGPointer+11	; Selects one of the preferences system fonts:
				;	0 - old DefaultFont, fixed-width
				;	1 - WB Screen preferred font


    SA_Type=	TAGPointer+12	; ti_Data is PUBLICSCREEN or CUSTOMSCREEN.
    				; For other fields of NewScreen.Type, see
    				; individual tags,eg. SA_Behind, SA_Quiet.

    SA_BitMap=	TAGPointer+13	; ti_Data is pointer to custom BitMap.	This
				; implies type of CUSTOMBITMAP

    SA_PubName=	TAGPointer+14	; presence of this tag means that the screen
				; is to be a public screen.  Please specify
				; BEFORE the two tags below

    SA_PubSig=	TAGPointer+15
    SA_PubTask=	TAGPointer+16	; Task ID and signal for being notified that
				; the last window has closed on a public screen


    SA_DisplayID=TAGPointer+17	; ti_Data is new extended display ID from
				; <graphics/displayinfo.i> (V37) or from
				; <graphics/modeid.i> (V39 and up)

    SA_DClip=	TAGPointer+18	; ti_Data points to a rectangle which defines
				; screen display clip region

    SA_Overscan=TAGPointer+19	; Set to one of the OSCAN_
				; specifiers below to get a system standard
				; overscan region for your display clip,
				; screen dimensions |unless otherwise specified
				; and automatically centered position (partial
				; support only so far).

    SA_Obsolete1=TAGPointer+20  ; obsolete S_MONITORNAME

*   booleans *

    SA_ShowTitle=TAGPointer+21	; boolean equivalent to flag SHOWTITLE
    SA_Behind=	TAGPointer+22	; boolean equivalent to flag SCREENBEHIND
    SA_Quiet=	TAGPointer+23	; boolean equivalent to flag SCREENQUIET
    SA_AutoScroll=TAGPointer+24	; boolean equivalent to flag AUTOSCROLL
    SA_Pens=	TAGPointer+25  ; array as in DrawInfo, terminated by -1
    SA_FullPalette=TAGPointer+26; boolean: initialize color table to entire
				;  preferences palette (32 for V36), rather
				; than compatible pens 0-3, 17-19, with
				; remaining palette as returned by 
				; GetColorMap()


    SA_ColorMapEntries=TAGPointer+27 ; New for V39:
			             ; Allows you to override the number of 
			             ; entries in the ColorMap for your screen.
			             ; Intuition normally allocates (1<<depth) 
			             ; or 32, whichever is more, but you may 
			             ; require even more if you use certain 
			             ; V39 graphics.library features (eg. 
			             ; palette-banking).

    SA_Parent=	TAGPointer+28	; New for V39:
				; ti_Data is a pointer to a "parent" screen to
				; attach this one to.  Attached screens slide
				; and depth-arrange together.

    SA_Draggable=TAGPointer+29	; New for V39:
				; Boolean tag allowing non-draggable screens.
				; Do not use without good reason!
				; (Defaults to TRUE).

    SA_Exclusive=TAGPointer+30  ; New for V39:
				; Boolean tag allowing screens that won't share
				; the display.  Use sparingly!  Starting with
				; 3.01,attached screens may be SA_Exclusive. 
				; Setting SA_Exclusive for each screen will 
				; produce an exclusive family.   
				; (Defaults to FALSE).

     SA_SharePens=TAGPointer+31	; New for V39:
				; For those pens in the screen's 
				; DrawInfo->dri_Pens,Intuition obtains them 
				; in shared mode (see graphics.library/
				; ObtainPen()).  For compatibility, Intuition
				; obtains the other pens of a public screen as
				; PEN_EXCLUSIVE.  Screens that wish to manage
				; the pens themselves should generally set
				; this tag to TRUE.  This instructs Intuition
				; to leave the other pens unallocated.

    SA_BackFill=TAGPointer+32 	; New for V39:
				; provides a "backfill hook" for your screen's
				; Layer_Info.
				; See layers.library/InstallLayerInfoHook()

    SA_Interleaved=TAGPointer+33; New for V39:
				; Boolean tag requesting that the bitmap
				; allocated for you be interleaved.
				; (Defaults to FALSE).

    SA_Colors32=TAGPointer+34	; New for V39:
				; Tag to set the screen's initial palette 
				; colors at 32 bits-per-gun.ti_Data is a 
				; pointer to a table to be passed to the
				; graphics.library/LoadRGB32() function.
				; This format supports both runs of color
				; registers and sparse registers.  See the
				; autodoc for that function for full details.
				; Any color set here has precedence over
				; the same register set by SA_Colors.

    SA_VideoControl=TAGPointer+35; New for V39:
				; ti_Data is a pointer to a taglist that 
				; Intuition will pass to graphics.library/
				; VideoControl(), upon opening the screen.

    SA_FrontChild=TAGPointer+36	; New for V39:
				; ti_Data is a pointer to an already open 
				; screen that is to be the child of the 
				; screen being opened.The child screen will
				; be moved to the front of its family.

    SA_BackChild=TAGPointer+37	; New for V39:
				; ti_Data is a pointer to an already open 
				; screen that is to be the child of the 
				; screen being opened.  The child screen will 
				; be moved to the back of its family.

    SA_LikeWorkbench=TAGPointer+38; New for V39:
				; Set ti_Data to 1 to request a screen which
				; is just like the Workbench.  This gives
				; you the same screen mode, depth, size,
				; colors, etc., as the Workbench screen.

    SA_Reserved=TAGPointer+39 	; Reserved for private Intuition use

    SA_MinimizeISG=TAGPointer+40; New for V40:
				; For compatibility, Intuition always ensures
				; that the inter-screen gap is at least three
				; non-interlaced lines.  If your application
				; would look best with the smallest possible
				; inter-screen gap, set ti_Data to TRUE.
				; If you use the new graphics VideoControl()
				; VC_NoColorPaletteLoad tag for your screen's
				; ViewPort, you should also set this tag.



* OpenScreen error codes, which are returned in the (optional) LONG
* pointed to by ti_Data for the SA_ErrorCode tag item

OSERR_NOMONITOR		= (1)	; named monitor spec not available
OSERR_NOCHIPS		= (2)	; you need newer custom chips	
OSERR_NOMEM		= (3)	; couldn't get normal memory
OSERR_NOCHIPMEM		= (4)	; couldn't get chipmem
OSERR_PUBNOTUNIQUE	= (5)	; public screen name already used
OSERR_UNKNOWNMODE	= (6)	; don't recognize mode asked for
OSERR_TOODEEP		= (7)	; Screen deeper than HW supports
OSERR_ATTACHFAIL	= (8)	; Failed to attach screens
OSERR_NOTAVAILABLE	= (9) ; Mode not available for other reason


INVALID_ID			=	~0
MONITOR_ID_MASK			=	$FFFF1000

DEFAULT_MONITOR_ID		=	$00000000
NTSC_MONITOR_ID			=	$00011000
PAL_MONITOR_ID			=	$00021000

** the following 22 composite keys are for Modes on the default Monitor.
** NTSC & PAL "flavors" of these particular keys may be made by or'ing
** the NTSC or PAL MONITOR_ID with the desired MODE_KEY...
**
** For example, to specifically open a PAL HAM interlaced ViewPort
** (or intuition screen), you would use the modeid of
** (PAL_MONITOR_ID | HAMLACE_KEY)
**

LORES_KEY			=	$00000000 
HIRES_KEY			=	$00008000 
SUPER_KEY			=	$00008020 
HAM_KEY				=	$00000800 
LORESLACE_KEY			=	$00000004 
HIRESLACE_KEY			=	$00008004 
SUPERLACE_KEY			=	$00008024 
HAMLACE_KEY			=	$00000804 
LORESDPF_KEY			=	$00000400 
HIRESDPF_KEY			=	$00008400 
SUPERDPF_KEY			=	$00008420 
LORESLACEDPF_KEY		=	$00000404 
HIRESLACEDPF_KEY		=	$00008404 
SUPERLACEDPF_KEY		=	$00008424 
LORESDPF2_KEY			=	$00000440 
HIRESDPF2_KEY			=	$00008440 
SUPERDPF2_KEY			=	$00008460 
LORESLACEDPF2_KEY		=	$00000444 
HIRESLACEDPF2_KEY		=	$00008444 
SUPERLACEDPF2_KEY		=	$00008464 
EXTRAHALFBRITE_KEY		=	$00000080 
EXTRAHALFBRITELACE_KEY		=	$00000084 
* New for AA ChipSet (V39)
HIRESHAM_KEY			=	$00008800
SUPERHAM_KEY			=	$00008820
HIRESEHB_KEY			=	$00008080
SUPEREHB_KEY			=	$000080a0
HIRESHAMLACE_KEY		=	$00008804
SUPERHAMLACE_KEY		=	$00008824
HIRESEHBLACE_KEY		=	$00008084
SUPEREHBLACE_KEY		=	$000080a4
* New for V40
LORESSDBL_KEY			=	$00000008
LORESHAMSDBL_KEY		=	$00000808
LORESEHBSDBL_KEY		=	$00000088
HIRESHAMSDBL_KEY		=	$00008808

