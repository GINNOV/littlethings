ASL_TB=TAG_USER+$80000

; Types of requesters known to ASL, used as arguments to AllocAslRequest()
ASL_FileRequest	      =0
ASL_FontRequest	      =1
ASL_ScreenModeRequest =2

; File requester tag values, used by AllocAslRequest() and AslRequest()

; Window control
ASLFR_Window	      =ASL_TB+2   ; Parent window
ASLFR_Screen	      =ASL_TB+40  ; Screen to open on if no window
ASLFR_PubScreenName   =ASL_TB+41  ; Name of public screen
ASLFR_PrivateIDCMP    =ASL_TB+42  ; Allocate private IDCMP?
ASLFR_IntuiMsgFunc    =ASL_TB+70  ; Function to handle IntuiMessages
ASLFR_SleepWindow     =ASL_TB+43  ; Block input in ASLFR_Window?
ASLFR_UserData	      =ASL_TB+52  ; What to put in fr_UserData

; Text display
ASLFR_TextAttr	      =ASL_TB+51  ; Text font to use for gadget text
ASLFR_Locale	      =ASL_TB+50  ; Locale ASL should use for text
ASLFR_TitleText       =ASL_TB+1   ; Title of requester
ASLFR_PositiveText    =ASL_TB+18  ; Positive gadget text
ASLFR_NegativeText    =ASL_TB+19  ; Negative gadget text

; Initial settings
ASLFR_InitialLeftEdge =ASL_TB+3   ; Initial requester coordinates
ASLFR_InitialTopEdge  =ASL_TB+4
ASLFR_InitialWidth    =ASL_TB+5   ; Initial requester dimensions
ASLFR_InitialHeight   =ASL_TB+6
ASLFR_InitialFile     =ASL_TB+8   ; Initial contents of File gadget
ASLFR_InitialDrawer   =ASL_TB+9   ; Initial contents of Drawer gadget
ASLFR_InitialPattern  =ASL_TB+10  ; Initial contents of Pattern gadget

; Options
ASLFR_Flags1	      =ASL_TB+20  ; Option flags
ASLFR_Flags2	      =ASL_TB+22  ; Additional option flags
ASLFR_DoSaveMode      =ASL_TB+44  ; Being used for saving?
ASLFR_DoMultiSelect   =ASL_TB+45  ; Do multi-select?
ASLFR_DoPatterns      =ASL_TB+46  ; Display a Pattern gadget?

; Filtering
ASLFR_DrawersOnly     =ASL_TB+47  ; Don't display files?
ASLFR_FilterFunc      =ASL_TB+49  ; Function to filter files
ASLFR_RejectIcons     =ASL_TB+60  ; Display .info files?
ASLFR_RejectPattern   =ASL_TB+61  ; Don't display files matching pattern
ASLFR_AcceptPattern   =ASL_TB+62  ; Accept only files matching pattern
ASLFR_FilterDrawers   =ASL_TB+63  ; Also filter drawers with patterns
ASLFR_HookFunc	      =ASL_TB+7   ; Combined callback function

;*
;* ASL ScreenMode Requester data structures and constants
;*
;* This structure must only be allocated by asl.library and is READ-ONLY!
;* Control of the various fields is provided via tags when the requester
;* is created with AllocAslRequest() and when it is displayed via
;* AslRequest()
;*

; Window control
ASLSM_Window          =ASL_TB+2   ; Parent window
ASLSM_Screen          =ASL_TB+40  ; Screen to open on if no window
ASLSM_PubScreenName   =ASL_TB+41  ; Name of public screen
ASLSM_PrivateIDCMP    =ASL_TB+42  ; Allocate private IDCMP?
ASLSM_IntuiMsgFunc    =ASL_TB+70  ; Function to handle IntuiMessages
ASLSM_SleepWindow     =ASL_TB+43  ; Block input in ASLSM_Window?
ASLSM_UserData        =ASL_TB+52  ; What to put in sm_UserData

; Text display
ASLSM_TextAttr        =ASL_TB+51  ; Text font to use for gadget text
ASLSM_Locale          =ASL_TB+50  ; Locale ASL should use for text
ASLSM_TitleText       =ASL_TB+1   ; Title of requester
ASLSM_PositiveText    =ASL_TB+18  ; Positive gadget text
ASLSM_NegativeText    =ASL_TB+19  ; Negative gadget text

; Initial settings
ASLSM_InitialLeftEdge =ASL_TB+3   ; Initial requester coordinates
ASLSM_InitialTopEdge  =ASL_TB+4
ASLSM_InitialWidth    =ASL_TB+5   ; Initial requester dimensions
ASLSM_InitialHeight   =ASL_TB+6
ASLSM_InitialDisplayID     =ASL_TB+100 ; Initial display mode id
ASLSM_InitialDisplayWidth  =ASL_TB+101 ; Initial display width
ASLSM_InitialDisplayHeight =ASL_TB+102 ; Initial display height
ASLSM_InitialDisplayDepth  =ASL_TB+103 ; Initial display depth
ASLSM_InitialOverscanType  =ASL_TB+104 ; Initial type of overscan
ASLSM_InitialAutoScroll    =ASL_TB+105 ; Initial autoscroll setting
ASLSM_InitialInfoOpened    =ASL_TB+106 ; Info wndw initially opened?
ASLSM_InitialInfoLeftEdge  =ASL_TB+107 ; Initial Info window coords.
ASLSM_InitialInfoTopEdge   =ASL_TB+108

; Options
ASLSM_DoWidth         =ASL_TB+109  ; Display Width gadget?
ASLSM_DoHeight        =ASL_TB+110  ; Display Height gadget?
ASLSM_DoDepth         =ASL_TB+111  ; Display Depth gadget?
ASLSM_DoOverscanType  =ASL_TB+112  ; Display Overscan Type gadget?
ASLSM_DoAutoScroll    =ASL_TB+113  ; Display AutoScroll gadget?

; Filtering
ASLSM_PropertyFlags   =ASL_TB+114  ; Must have these Property flags
ASLSM_PropertyMask    =ASL_TB+115  ; Only these should be looked at
ASLSM_MinWidth        =ASL_TB+116  ; Minimum display width to allow
ASLSM_MaxWidth        =ASL_TB+117  ; Maximum display width to allow
ASLSM_MinHeight       =ASL_TB+118  ; Minimum display height to allow
ASLSM_MaxHeight       =ASL_TB+119  ; Maximum display height to allow
ASLSM_MinDepth        =ASL_TB+120  ; Minimum display depth
ASLSM_MaxDepth        =ASL_TB+121  ; Maximum display depth
ASLSM_FilterFunc      =ASL_TB+122  ; Function to filter mode id's

; Custom additions
ASLSM_CustomSMList    =ASL_TB+123  ; Exec list of struct DisplayMode

; Window control
ASLFO_Window	      =ASL_TB+2   ; Parent window
ASLFO_Screen	      =ASL_TB+40  ; Screen to open on if no window
ASLFO_PubScreenName   =ASL_TB+41  ; Name of public screen
ASLFO_PrivateIDCMP    =ASL_TB+42  ; Allocate private IDCMP?
ASLFO_IntuiMsgFunc    =ASL_TB+70  ; Function to handle IntuiMessages
ASLFO_SleepWindow     =ASL_TB+43  ; Block input in ASLFO_Window?
ASLFO_UserData	      =ASL_TB+52  ; What to put in fo_UserData

; Text display
ASLFO_TextAttr	      =ASL_TB+51  ; Text font to use for gadget text
ASLFO_Locale	      =ASL_TB+50  ; Locale ASL should use for text
ASLFO_TitleText       =ASL_TB+1   ; Title of requester
ASLFO_PositiveText    =ASL_TB+18  ; Positive gadget text
ASLFO_NegativeText    =ASL_TB+19  ; Negative gadget text

; Initial settings
ASLFO_InitialLeftEdge =ASL_TB+3   ; Initial requester coordinates
ASLFO_InitialTopEdge  =ASL_TB+4
ASLFO_InitialWidth    =ASL_TB+5   ; Initial requester dimensions
ASLFO_InitialHeight   =ASL_TB+6
ASLFO_InitialName     =ASL_TB+10  ; Initial contents of Name gadget
ASLFO_InitialSize     =ASL_TB+11  ; Initial contents of Size gadget
ASLFO_InitialStyle    =ASL_TB+12  ; Initial font style
ASLFO_InitialFlags    =ASL_TB+13  ; Initial font flags for TextAttr
ASLFO_InitialFrontPen =ASL_TB+14  ; Initial front pen
ASLFO_InitialBackPen  =ASL_TB+15  ; Initial back pen
ASLFO_InitialDrawMode =ASL_TB+59  ; Initial draw mode

; Options
ASLFO_Flags	          =ASL_TB+20  ; Option flags
ASLFO_DoFrontPen      =ASL_TB+44  ; Display Front color selector?
ASLFO_DoBackPen       =ASL_TB+45  ; Display Back color selector?
ASLFO_DoStyle	      =ASL_TB+46  ; Display Style checkboxes?
ASLFO_DoDrawMode      =ASL_TB+47  ; Display DrawMode cycle gadget?

; Filtering
ASLFO_FixedWidthOnly  =ASL_TB+48  ; Only allow fixed-width fonts?
ASLFO_MinHeight       =ASL_TB+16  ; Minimum font height to display
ASLFO_MaxHeight       =ASL_TB+17  ; Maximum font height to display
ASLFO_FilterFunc      =ASL_TB+49  ; Function to filter fonts
ASLFO_HookFunc	      =ASL_TB+7   ; Combined callback function
ASLFO_MaxFrontPen     =ASL_TB+66  ; Max # of colors in front palette
ASLFO_MaxBackPen      =ASL_TB+67  ; Max # of colors in back palette

; Custom additions
ASLFO_ModeList	      =ASL_TB+21  ; Substitute list for drawmodes
ASLFO_FrontColors     =ASL_TB+64  ; Color table for front pen palette
ASLFO_BackColors      =ASL_TB+65  ; Color table for back pen palette
