
execbase     = 4

IFND Konstanten_Flag
   Konstanten_Flag=1
INCLUDE Preass/Konstanten_old.inc
EndIF

HIRES      = $8000
JAM1       = 0
JAM2       = 1
COMPLEMENT = 2
INVERSVID  = 4


TAG_DONE   = 0  ; terminates array of TagItems. ti_Data unused
TAG_END	   = 0  ; synonym for TAG_DONE
TAG_IGNORE = 1  ; ignore this item, not end of array
TAG_MORE   = 2  ; ti_Data is pointer to another array of TagItems

TAG_SKIP   = 3  ; skip this and the next ti_Data items

TAGFILTER_AND = 0	; exclude everything but filter hits
TAGFILTER_NOT = 1	; exclude only filter hits

TAG_USER   = $80000000

SCREENTYPE	=	$000F	; all the screens types available 

WBENCHSCREEN	=	$0001	; identifies the Workbench screen
PUBLICSCREEN	=	$0002	; public shared (custom) screen
CUSTOMSCREEN	=	$000F	; for that special look

_SHOWTITLE	=	$0010	; this gets set by a call to ShowTitle() 

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

PENSHARED	=	$0400	; Screen opener set {SA_SharePens,TRUE}


 TAGPointer=TAG_USER+33

    SA_Left=	TAGPointer  ; traditional screen positions and dimensions
    SA_Top=	TagPointer+1
    SA_Width=	TAGPointer+2
    SA_Height=	TAGPointer+3
    SA_Depth=	TAGPointer+4; screen bitmap depth
    SA_DetailPen=TAGPointer+5; serves as default for windows, too
    SA_BlockPen=TAGPointer+6
    SA_Title=	TAGPointer+7    ; default screen title
    SA_Colors=	TAGPointer+8	; ti_Data is an array of struct ColorSpec,
    SA_ErrorCode=TAGPointer+9	; ti_Data points to LONG error code (values
    SA_Font=	TAGPointer+10 	; equiv. to NewScreen.Font
    SA_SysFont=	TAGPointer+11	; Selects one of the preferences system fonts:
    SA_Type=	TAGPointer+12	; ti_Data is PUBLICSCREEN or CUSTOMSCREEN.
    SA_BitMap=	TAGPointer+13	; ti_Data is pointer to custom BitMap.	This
    SA_PubName=	TAGPointer+14	; presence of this tag means that the screen
    SA_PubSig=	TAGPointer+15
    SA_PubTask=	TAGPointer+16	; Task ID and signal for being notified that
    SA_DisplayID=TAGPointer+17	; ti_Data is new extended display ID from
    SA_DClip=	TAGPointer+18	; ti_Data points to a rectangle which defines
    SA_Overscan=TAGPointer+19	; Set to one of the OSCAN_
    SA_Obsolete1=TAGPointer+20  ; obsolete S_MONITORNAME
    SA_ShowTitle=TAGPointer+21	; boolean equivalent to flag SHOWTITLE
    SA_Behind=	TAGPointer+22	; boolean equivalent to flag SCREENBEHIND
    SA_Quiet=	TAGPointer+23	; boolean equivalent to flag SCREENQUIET
    SA_AutoScroll=TAGPointer+24	; boolean equivalent to flag AUTOSCROLL
    SA_Pens=	TAGPointer+25  ; array as in DrawInfo, terminated by -1
    SA_FullPalette=TAGPointer+26; boolean: initialize color table to entire
    SA_ColorMapEntries=TAGPointer+27 ; New for V39:
    SA_Parent=	TAGPointer+28	; New for V39:
    SA_Draggable=TAGPointer+29	; New for V39:
    SA_Exclusive=TAGPointer+30  ; New for V39:
    SA_SharePens=TAGPointer+31	; New for V39:
    SA_BackFill=TAGPointer+32 	; New for V39:
    SA_Interleaved=TAGPointer+33; New for V39:
    SA_Colors32=TAGPointer+34	; New for V39:
    SA_VideoControl=TAGPointer+35; New for V39:
    SA_FrontChild=TAGPointer+36	; New for V39:
    SA_BackChild=TAGPointer+37	; New for V39:
    SA_LikeWorkbench=TAGPointer+38; New for V39:
    SA_Reserved=TAGPointer+39 	; Reserved for private Intuition use
    SA_MinimizeISG=TAGPointer+40; New for V40:

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
EURO36_Monitor_ID               =       $00071000
EURO72_MONITOR_ID 		=	$00061000
SUPER72_MONITOR_ID		=	$00081000


LORES_KEY			        =	$00000000 
HIRES_KEY		    	        =	$00008000 
SUPER_KEY			        =	$00008020 
HAM_KEY			    	        =	$00000800 
LORESLACE_KEY			=	$00000004 
HIRESLACE_KEY			=	$00008004 
SUPERLACE_KEY			=	$00008024 
HAMLACE_KEY			        =	$00000804 
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
EXTRAHALFBRITELACE_KEY	        =	$00000084 
HIRESHAM_KEY			=	$00008800
SUPERHAM_KEY			=	$00008820
HIRESEHB_KEY			=	$00008080
SUPEREHB_KEY			=	$000080a0
HIRESHAMLACE_KEY		=	$00008804
SUPERHAMLACE_KEY		=	$00008824
HIRESEHBLACE_KEY		=	$00008084
SUPEREHBLACE_KEY		=	$000080a4
LORESSDBL_KEY			=	$00000008
LORESHAMSDBL_KEY		=	$00000808
LORESEHBSDBL_KEY		=	$00000088
HIRESHAMSDBL_KEY		=	$00008808

MEMF_ANY	= 0		;Any type of memory will do
MEMF_PUBLIC     = $00000001
MEMF_CHIP       = $00000002
MEMF_FAST       = $00000004
MEMF_LOCAL      = %100000000
MEMF_24BITDMA	= %1000000000
MEMF_KICK       = %10000000000
MEMF_CLEAR	    = %10000000000000000
MEMF_LARGEST    = %100000000000000000	
MEMF_REVERSE    = %1000000000000000000
MEMF_TOTAL      = %10000000000000000000
MEMF_NO_EXPUNGE = %01000000000000000000000000000000

MEM_BLOCKSIZE	= 8
MEM_BLOCKMASK	= (MEM_BLOCKSIZE-1)

MEM_DID_NOTHING	=	0	; Nothing we could do...
MEM_ALL_DONE	=	-1	; We did all we could do
MEM_TRY_AGAIN	=	1	; We did some, try the allocation again

NB_VERSION= 5
CBD_NAMELEN= 24
CBD_TITLELEN= 40
CBD_DESCRLEN= 40
NBU_DUPLICATE= 0
NBU_UNIQUE= 1
NBU_NOTIFY= 2
COF_SHOW_HIDE= 4
CX_INVALID= 0	
CX_FILTER= 1	
CX_TYPEFILTER= 2
CX_SEND= 3	
CX_SIGNAL= 4	
CX_TRANSLATE= 5	
CX_BROKER= 6	
CX_DEBUG= 7	
CX_CUSTOM= 8	
CX_ZERO= 9	
CXM_IEVENT= $20
CXM_COMMAND= $40
CXCMD_DISABLE= 15	
CXCMD_ENABLE= 17	
CXCMD_APPEAR= 19	
CXCMD_DISAPPEAR= 21
CXCMD_KILL= 23	  
CXCMD_LIST_CHG= 27
CXCMD_UNIQUE= 25
IX_VERSION= 2
IXSYM_SHIFT= 1	     
IXSYM_CAPS= 2	     
IXSYM_ALT= 4	     
IX_NORMALQUALS= $7FFF
CBERR_OK= 0        
CBERR_SYSERR= 1    
CBERR_DUP= 2       
CBERR_VERSION= 3   
COERR_ISNULL= 1    
COERR_NULLATTACH= 2
COERR_BADFILTER= 4 
COERR_BADTYPE= 8   

SYS_Dummy=	    TAG_USER+32
SYS_Input=	    SYS_Dummy+1	
SYS_Output=	    SYS_Dummy+2	
SYS_Asynch=	    SYS_Dummy+3	
SYS_UserShell=	SYS_Dummy+4   
SYS_CustomShell=SYS_Dummy+5   
NP_Dummy=       TAG_USER+1000
NP_Seglist=     NP_Dummy+1	 
NP_FreeSeglist= NP_Dummy+2	 
NP_Entry=       NP_Dummy+3	 
NP_Input=       NP_Dummy+4	 
NP_Output=      NP_Dummy+5	 
NP_CloseInput=  NP_Dummy+6	 
NP_CloseOutput= NP_Dummy+7	 
NP_Error=       NP_Dummy+8	 
NP_CloseError=  NP_Dummy+9	 
NP_CurrentDir=  NP_Dummy+10	 
NP_StackSize=   NP_Dummy+11	 
NP_Name=        NP_Dummy+12	 
NP_Priority=    NP_Dummy+13	 
NP_ConsoleTask= NP_Dummy+14	 
NP_WindowPtr=   NP_Dummy+15	 
NP_HomeDir=     NP_Dummy+16	 
NP_CopyVars=    NP_Dummy+17	 
NP_Cli=         NP_Dummy+18	 
NP_Path=        NP_Dummy+19	 
NP_CommandName= NP_Dummy+20  
NP_Arguments=   NP_Dummy+21
NP_NotifyOnDeath= NP_Dummy+22 
NP_Synchronous= NP_Dummy+23	 
NP_ExitCode=    NP_Dummy+24	 
NP_ExitData=    NP_Dummy+25	 
ADO_Dummy=	    TAG_USER+2000
ADO_FH_Mode=	ADO_Dummy+1	
ADO_DirLen=	    ADO_Dummy+2	
ADO_CommNameLen=ADO_Dummy+3	
ADO_CommFileLen=ADO_Dummy+4	
ADO_PromptLen=	ADO_Dummy+5	

; LowLevel SysControl:

SCON_Dummy= TAG_USER+$00C00000
SCON_TakeOverSys= SCON_Dummy+0
SCON_KillReq= SCON_Dummy+1
SCON_CDReboot= SCON_Dummy+2
SCON_StopInput= SCON_Dummy+3
SCON_AddCreateKeys= SCON_Dummy+4
SCON_RemCreateKeys= SCON_Dummy+5
