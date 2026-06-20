****************************************************************************
**                                         Append to Amiga3.1.asm
**  tanlib.i     revision 1.85  28. 4.99   sc         B0000  labs ptrs 20000
**                                         asm lines 100000  labs asci 40000
****************************************************************************

xxp_lver: SET 37           ;min version for Amiga libs     (=release  2.04)
xxp_tver: SET 37           ;min version for tandem.library (=release  1)

; Data used by Front.i and tandem.library
;    Front.i creates an instance of this structure in a 1024 byte stack
;    frame, and calls Program with A4 pointing to it.

 STRUCTURE xxp_tndm,0

;system information

 STRUCT xxp_buff,512       ;general purpose scratchpad
 WORD xxp_tand             ;<> if running under Tandem (i.e. debugging)
 WORD xxp_user             ;for applications (Tandem.i leaves alone)
 APTR xxp_bnch             ;startup msg if under workbench, 0 if under CLI
 STRUCT xxp_A0D0,8         ;A0,D0 on startup (CLI params if xxp_bnch=0)
 APTR xxp_sysb             ;base of system.library (cache of _AbsExecBase)
 APTR xxp_dosb             ;base of dos.library
 APTR xxp_intb             ;base of intuition.library
 APTR xxp_gfxb             ;base of graphics.library
 APTR xxp_aslb             ;base of asl.library
 APTR xxp_gadb             ;base of gadtools.library
 APTR xxp_tanb             ;base of tandem.library
 APTR xxp_oput             ;CLI output stream/Workbench monitor
 APTR xxp_iput             ;CLI  input stream/Workbench monitor
 LONG xxp_memk             ;memkey for AllocRemember
 LONG xxp_cdir             ;<> if user has changed the CD (init CD here)
 LONG xxp_hndl             ;handle from TLOpenread/write
 APTR xxp_strg             ;pointer to strings table in user program
 WORD xxp_ackn             ;Program sets to string num of closedown msg

; Data initialised at first call to TLWindow (or via TLReq....)
;    Front0.i sets xxp_Screen to null to show all inoperative
;    If user wants other than workbench screen, poke it to xxp_Screen, and:
;      xxp_Public=0  when Front0.i will close xxp_Screen after Program rts's
;      xxp_Public=-1 when Front0.i will leave xxp_Screen alone

 APTR xxp_Screen     ;the screen used for TL calls
 APTR xxp_vi         ;  GadTools vi for xxp_Screen
 LONG xxp_Width      ;  screen width
 LONG xxp_Height     ;  screen height
 LONG xxp_Depth      ;  screen depth
 APTR xxp_EBmap      ;Double buffering area used by TLReqedit bitmap
 APTR xxp_ERport     ;  rastport
 LONG xxp_ehgt       ;  height
 LONG xxp_ewid       ;  width
 APTR xxp_FSuite     ;Instance of an xxp_fsui structure (see below)
 LONG xxp_Stak       ;Caller d0-d7/a0-a6 set by requesters for hooks
 APTR xxp_FWork      ;Used by TLReqedit, &c (see below)
 APTR xxp_WSuite     ;Instance of an xxp_wsui structure (see below)
 APTR xxp_AcWind     ;  Address of currently active window in xxp_WSuite
 WORD xxp_Active     ;  its window num; -1 if none active
 WORD xxp_Public     ;for TLWclose: 2=close xxp_Screen; 1=leave alone
 WORD xxp_Pop        ;window num to pop for requesters
 LONG xxp_Help       ;first line, number of lines, of help
 WORD xxp_ReqNull    ;set <>0 to enable requesters, 0 to disable

;sundry data for internal use by TL routines

 LONG xxp_tbbw            ;tabs total width
 LONG xxp_tbbh            ;     total height
 LONG xxp_tblw            ;     individual width
 LONG xxp_tblh            ;     individual height
 STRUCT xxp_kybd,16       ;D0-D3 returned by TLKeyboard
 LONG xxp_crsr            ;cursor tab (0+)
 LONG xxp_tbss            ;tabs string num with thumbtag labels
 LONG xxp_valu            ;  value of number input
 LONG xxp_chnd            ;  <> if input string changed
 LONG xxp_lins            ;TLMultiline no. of lines in xxp_Mmem
 LONG xxp_guid            ;path of AmigaGuide invoked by TLHelp
 LONG xxp_node            ;node of AmigaGuide invoked by TLHelp
 LONG xxp_gide            ;workspace to TLGide
 LONG xxp_mmtp            ;unused
 STRUCT xxp_rnge,8        ;unused
 LONG xxp_glob            ;unused
 STRUCT xxp_patt,32       ;TLMultiline,TLReqshow string sought
 LONG xxp_errn            ;Error number
 LONG xxp_rinf            ;TLReqshow data extent pointer
 LONG xxp_Hook            ;TLReqshow callback hook

; data for requester buttons

 LONG xxp_reqx            ;Requester  xpos      *** Caution: do not
 LONG xxp_reqy            ;  ypos               *** interpose noew items
 LONG xxp_reqw            ;  width              *** between reqx and butl
 LONG xxp_reqh            ;  height
 LONG xxp_butx            ;Button set  xpos
 LONG xxp_buty            ;  ypos
 LONG xxp_butw            ;  width
 LONG xxp_buth            ;  height
 LONG xxp_btdx            ;  dx
 LONG xxp_btdy            ;  dy
 LONG xxp_butk            ;  buttons in row
 LONG xxp_butl            ;  no. of rows

; printer data

 WORD xxp_styl            ;unused
 BYTE xxp_lppg            ;printer lines/page
 BYTE xxp_marg            ;printer margins
 BYTE xxp_cpln            ;printer chrs/line
 BYTE xxp_pica            ;print -1=pica 0=elite

; output of xxp_TSize

 LONG xxp_wdth            ;output of xxp_TSize  D4 = width
 LONG xxp_chrs            ;  D5 = chrs
 LONG xxp_ysiz            ;  D6 = ysiz
 LONG xxp_basl            ;  D7 = baseline

 STRUCT xxp_fil1,2        ;(unused)

;data for requester sliders

 LONG xxp_slix            ;Slider  xpos
 LONG xxp_sliy            ;        ypos
 LONG xxp_sliw            ;        width
 LONG xxp_slih            ;        height               TLReqshow
 LONG xxp_otop            ;(unused)
 LONG xxp_tops            ; Value  slide top        {num of top string shown
 LONG xxp_totl            ;        total            {total strings
 LONG xxp_strs            ;        slide            {strings on screen
 LONG xxp_lcom            ;                         {line to be complemented
 LONG xxp_hook            ; hook to call when slider moves

;sundry data

 APTR xxp_busy            ;TLBusy chip memory
 APTR xxp_hook0           ;called by TLReqchek if set
 APTR xxp_hook1           ;called by TLReqon if set
 APTR xxp_hook2           ;called by TLHook2 if set

;data for opening printer.device

 APTR xxp_requ            ;printer request
 LONG xxp_sigb            ;signal bit
 WORD xxp_devo            ;<> if printer open
 STRUCT xxp_rept,MP_SIZE  ;message port(=34)

;misc data
 APTR xxp_splc            ;data for spell.library
 LONG xxp_about           ;about line, numlines for TLMultiline

;data for TLProgress
 STRUCT xxp_prgd,16       ;xpos,ypos,wdth,hght of thermometer
 STRUCT xxp_prgi,4        ;(unused)

;misc data
 LONG xxp_gadg            ;if <>, gadgets for TLWindow
 APTR xxp_slid            ;instance of an xxp_slis structure, or 0
 APTR xxp_mesg            ;most recent IntuiMessage from TLMmess
 APTR xxp_pref            ;GUI prefs (an xxp_yprf structure)
 STRUCT xxp_prfp,8        ;used by TLReqon, &c (operative xxp_prefs data)
 APTR xxp_pixx            ;chip mem for .pix in TLWindow

 STRUCT xxp_fil0,22       ;(unused)

 LABEL xxp_size           ;must not exceed 1024

* Structure of memory pointed to by xxp_WSuite

; sub-structures pointed to by xxp_wsui - data for each window

 STRUCTURE xxp_wsuw,0

;data for TLReqedit,TLText,&c (TLReqedit,TLText,&c also use xxp_Wport)
 BYTE xxp_FrontPen   ; } pens & drawmode
 BYTE xxp_BackPen    ; }
 BYTE xxp_DrawMode   ; }
 BYTE xxp_Kludge     ; }
 WORD xxp_LeftEdge   ; } These are set to top left of printable area
 WORD xxp_TopEdge    ; }
 WORD xxp_xmin       ; } xmin underlap found in last TLTsize (+ve)
 WORD xxp_xmax       ; } xmax overlap found in lst TLTsize (+ve)
 APTR xxp_IText      ; } null delimited ASCII to be printed
 WORD xxp_Fnum       ; } font number for window
 WORD xxp_Attc       ; } -1 if new Fnum, else operative Fsty
 WORD xxp_Fsty       ; } font style (0-3 for xxp_plain &c)  } supplementary
 WORD xxp_Tspc       ; } text spacing                       } to above

;other data for the window
 LONG xxp_Window     ;the window's own address (0 if unopened)
 LONG xxp_Menu       ;menu created by TLReqmenu (must not be shared)
 WORD xxp_Menuon     ;<> if xxp_Menu attached
 WORD xxp_PWidth     ; } current window print width (width-borders)
 WORD xxp_PHeight    ; } current window print height (height-borders)
 APTR xxp_WPort      ;window rastport
 LONG xxp_Wcheck     ;window dims used by TLWcheck
 WORD xxp_ReqLeft    ;requester lhs
 WORD xxp_ReqTop     ;requester top

;data used by TLMultiline
 APTR xxp_Mmem       ;<>0 if mem addr for TLMultiline    } applicable if
 LONG xxp_Mmsz       ;memsize (if xxp_Mmem<>0)           } TLMultiline
 LONG xxp_Mtop       ;addr top of lines (if mmp_Mmem<>0) } called for this
 LONG xxp_Mcrr       ;line num w. cursor                 } window, else
 WORD xxp_Mmxc       ;max characters in line             } xxp_Mmem=0
 LONG xxp_Mtpl       ;topline shown on window            }

;Window refresh
 APTR xxp_Refr       ;TLKeyboard window refresh (not usually used)
 APTR xxp_scrl       ;an xxp_scro structure (null if no scroll bars)

 LONG xxp_shad       ;shadow font: 0unused 1pen 2dy 1dx
 LONG xxp_Styl       ;(unused)

;data passed from windows 0-9 to windows 10,11 (i.e. requesters,help)
 WORD xxp_RFont      ;requesters fontnum         } When a requester or
 WORD xxp_HFont      ;      help fontnum         } TLHelp is invoked, this
 WORD xxp_RTspc      ;requesters xxp_Tspc        } data from xxp_AcWind (if
 WORD xxp_HTspc      ;      help xxp_Tspc        } any window is active) is
 WORD xxp_RFsty      ;requesters xxp_Fsty        } passed to window 10
 WORD xxp_HFsty      ;      help xxp_Fsty        } or 11.

 LABEL xxp_siz2

; the structure pointed to by xxp_WSuite

 STRUCTURE xxp_wsui,0      ;(consists of 12 xxp_wsuw structures)
 STRUCT xxp_ws00,xxp_siz2  ;windows 0-9
 STRUCT xxp_ws01,xxp_siz2
 STRUCT xxp_ws02,xxp_siz2
 STRUCT xxp_ws03,xxp_siz2
 STRUCT xxp_ws04,xxp_siz2
 STRUCT xxp_ws05,xxp_siz2
 STRUCT xxp_ws06,xxp_siz2
 STRUCT xxp_ws07,xxp_siz2
 STRUCT xxp_ws08,xxp_siz2
 STRUCT xxp_ws09,xxp_siz2
 STRUCT xxp_ws10,xxp_siz2  ;used for requesters
 STRUCT xxp_ws11,xxp_siz2  ;use for help
 LABEL xxp_siz3

* Structure of font suite & .styl data (pointed to by xxp_FSuite,xxp_FWork)

; sub-structure of xxp_fsui for each font

 STRUCTURE xxp_fsuf,0      ;structure of xxp_FSuite entries
 STRUCT xxp_attr,8         ;TextAttr for the font
 STRUCT xxp_fnam,32        ;the fontname
 APTR xxp_plain            ;addr of normal size       (0 if unopened)
 APTR xxp_bold             ;addr of double width      (0 if unopened)
 APTR xxp_ital             ;addr of half height       (0 if unopened)
 APTR xxp_boit             ;addr of dbl wdth + hlf ht (0 if unopened)
 LABEL xxp_fsiz            ;=56

; the structure pointed to by xxp_FSuite

 STRUCTURE xxp_fsui,0      ;(consists of 10 xxp_fsuf structures)
 STRUCT xxp_fs00,xxp_fsiz  ;font 0 - always Topaz/8
 STRUCT xxp_fs01,xxp_fsiz
 STRUCT xxp_fs02,xxp_fsiz
 STRUCT xxp_fs03,xxp_fsiz
 STRUCT xxp_fs04,xxp_fsiz
 STRUCT xxp_fs05,xxp_fsiz
 STRUCT xxp_fs06,xxp_fsiz
 STRUCT xxp_fs07,xxp_fsiz
 STRUCT xxp_fs08,xxp_fsiz
 STRUCT xxp_fs09,xxp_fsiz
 STRUCT xxp_fs10,xxp_fsiz  ;font 10 - default requesters
 STRUCT xxp_fs11,xxp_fsiz  ;font 11 - default Reqshow
 LABEL xxp_siz4            ;=672

; the structure pointed by xxp_FWork

; bytes 0-1799     used by TLReqedit
; bytes 1800-2399  used by TLMultiline

xxp_siz5 equ 2400

* default values
xxp_ewiv: SET 1280         ;default xxp_ewid (160*8) } 20480 bytes/plane
xxp_ehgv: SET 128          ;default xxp_ehgt         }
xxp_col1: SET $01000200    ;default xxp_colr   (1,0 2,0)
xxp_col2: SET $03000103    ;default xxp_colr+4 (3,0 1,3)

* the data pointed to by xxp_splc (used by spell.library)
 STRUCTURE xxp_Spel,0
 APTR xxp_dict           ;address of spelling diectionary
 LONG xxp_dics           ;size of sp_dict
 APTR xxp_priv           ;address of private list (0 if none)
 APTR xxp_prit           ;top  of sp_priv
 LONG xxp_pris           ;size of sp_priv memory
 APTR xxp_temp           ;address of temporary list
 APTR xxp_temt           ;top  of sp_temp
 LONG xxp_tems           ;size of sp_temp
 APTR xxp_clog           ;address of corrections log
 APTR xxp_clot           ;top  of sp_clot
 LONG xxp_clos           ;size of sp_clot
 APTR xxp_comm           ;address of common errors
 APTR xxp_comt           ;top  of sp_comm
 LONG xxp_coms           ;size of sp_comm
 APTR xxp_spel           ;address of line(s) to spell check } used only
 APTR xxp_splt           ;top  of sp_spel                   }   by
 LONG xxp_spls           ;size of sp_spel                   } TLSpelchek
 BYTE xxp_case           ;case checking:    -1,0,1=ignore/correct/query
 BYTE xxp_ctxt           ;context display   -1,0,1=none/errors/all
 BYTE xxp_pryn           ;private list      -1,1=yes/no
 BYTE xxp_tpyn           ;temporary list    -1,1=yes/no
 BYTE xxp_cmyn           ;common errors     -1,1=yes/no
 BYTE xxp_lgyn           ;log or changes    -1,1=yes/no
 BYTE xxp_klu0           ;(unused)
 BYTE xxp_klu1           ;(unused)
 STRUCT xxp_word,30      ;word to be checked
 STRUCT xxp_sugg,70      ;suggestions for xxp_word
 STRUCT xxp_swrk,8       ;internal use
 APTR xxp_dptr           ;dict pointers  } These can be removed by AllocVec,
 APTR xxp_pptr           ;priv pointers  } when 0 must be poked to here.
 STRUCT xxp_pdir,130     ;xxp_priv directory
 STRUCT xxp_pfil,34      ;xxp_priv file
 STRUCT xxp_ddir,130     ;xxp_dict directory
 STRUCT xxp_dfil,34      ;xxp_dict file
 LABEL xxp_spsz          ; = 520 to end of xxp_dfil

* tags for TLreqedit
xxp_xtext: equ 1            ;Address of text, e.g. xxp_FWork  dflt buff
xxp_xstyl: equ 2            ;Address of styl, e.g. xxp_FWork+256  dflt all 0
xxp_xmaxt: equ 3            ;Maximum width of tablet  dflt max possible
xxp_xmaxc: equ 4            ;Maximum characters  dflt 255
xxp_xmaxw: equ 5            ;Max text width  (no dflt - use xxp_xmaxc)
xxp_xcrsr: equ 6            ;initial cursor posn  -1 for none  dflt 0
xxp_xoffs: equ 7            ;fixed offset  -1 for none  dflt -1
xxp_xforb: equ 8            ;forbids (see below)  dflt all
xxp_xtask: equ 9            ;task 0-3 (see below)  dflt 0
xxp_xcomp: equ 10           ;-1=complement  0=don't complement  dflt 0
xxp_xnprt: equ 11           ;-1=don't print  0=print  dflt 0
xxp_xfont: equ 12           ;fontnum  dflt 0
xxp_xcspc: equ 13           ;cspace  dflt 0
xxp_xmaxj: equ 14           ;max fjust spacing  0=force  dflt 5
xxp_xltyp: equ 15           ;initial ltype (see below)  dflt 0
xxp_xkybd: equ 16           ;crsr xpos in pixels, dlft use xxp_xcrsr
                            ;(17 unused)
xxp_xiclr: equ 18           ;-1=clear tablet before starting  dflt 0
xxp_xtral: equ 19           ;-1=remove trailing spaces before RTS  dflt=0
xxp_xshdv: equ 20           ;shadow: 0,pen,dy,dx   dflt xxp_shad -> 00020102
xxp_xresz: equ 21           ;0=resize forbid, -1=resize cont, dflt 0
xxp_xmenu: equ 22           ;menu num (if any) of "Text Format" menu
xxp_xfgbg: equ 23           ;0,0,foreground pen,background pen (dflt wsuw)
xxp_xffix: equ 24           ;-1=force fixed width  dflt 0
xxp_xjam1: equ 25           ;-1=jam1  0=jam2  dflt 0
xxp_xcase: equ 26           ;0=normal  1=ucase  2=lcase  3=small cap  dflt 0
xxp_xstyb: equ 27           ;lsb of argument = styl of all bytes dflt 0
xxp_xrevs: equ 28           ;-1=reverse (right to left) printing

* TLReqedit xxp_xforb forbid bits (OR them together)
xxp_xesty: equ $0FFF        ;disable all changes to styl

xxp_xbold: equ $0001        ;disable  Ctrl B bold
xxp_xital: equ $0002        ;disable  Ctrl I italic
xxp_xundl: equ $0004        ;disable  Ctrl U underline, strike thru
xxp_xdubl: equ $0008        ;disable  Ctrl W wide
xxp_xfixt: equ $0010        ;disable  Ctrl P force fixed
xxp_xshad: equ $0020        ;disable  Ctrl S shadow
xxp_xrjst: equ $0040        ;disable  Ctrl R right just
xxp_xfjst: equ $0080        ;disable  Ctrl J full just
xxp_xcent: equ $0100        ;disable  Ctrl C centre
xxp_xljst: equ $0200        ;disable  Ctrl L left just
xxp_xcmpj: equ $0400        ;disable  Shift Ctrl C complement
xxp_xsusb: equ $0800        ;disable  Ctrl up/down arrow   super/sub script
xxp_xunrm: equ $1000        ;disable return if menu select
xxp_xunre: equ $2000        ;disable return if unknown Ctrl key
xxp_xunrc: equ $4000        ;disable return if unknown other than Ctrl

* TLMultiline forbid &c bits
xxp_xmsty: equ $FFF0        ;disable all changes to styl

xxp_xchnd: equ $0001        ;<> = text changed (on return)(ignored on call)
xxp_xunsv: equ $0002        ;<> = text unsaved (on call & return)

xxp_xpage: equ $0010        ;disable paging
xxp_xblok: equ $0020        ;disable blocking
xxp_xspce: equ $0040        ;disable lspace
xxp_xspac: equ $0080        ;disable cspace
xxp_xjust: equ $0100        ;disable fjst change
xxp_xpens: equ $0200        ;disable pens
xxp_xcols: equ $0400        ;(unused)
xxp_xpict: equ $0800        ;disable graphics
xxp_xfnts: equ $1000        ;disable font select
xxp_xrend: equ $2000        ;(unused)

xxp_xchng: equ $80000000    ;disable all alterations to text

* TLReqedit xxp_xtask task values
xxp_xtstr: equ 0            ;string - no continuation line
xxp_xtcon: equ 1            ;string - continuation line
xxp_xtdec: equ 2            ;number - decimal number    } return value in
xxp_xthex: equ 3            ;number - hex number        } xxp_valu

* TLReqedit xxp_xltyp initial justification values
xxp_xleft: equ 0            ;left justification  } Final value in
xxp_xcntr: equ 1            ;centre              } bits 8-9 of
xxp_xrght: equ 2            ;right justification } xxp_chnd
xxp_xfull: equ 3            ;full justification  }

* TLReqedit xxp_xstyl bits
xxp_xbit0: equ 0            ;bold
xxp_xbit1: equ 1            ;italic
xxp_xbit2: equ 2            ;underline   } 0001 und  0011 ovr   0101 und+ovr
xxp_xbit3: equ 3            ;superscript } 0010 sup  0111 dbl und + ovr
xxp_xbit4: equ 4            ;subscript   } 0100 sub  0110 dbl und
xxp_xbit5: equ 5            ;dot underlin} 1000 dot  1001 thru
xxp_xbit6: equ 6            ;shadow font
xxp_xbit7: equ 7            ;double width

* TLreqedit return codes
xxp_xrtn: equ 0             ;return / accept
xxp_xesc: equ 1             ;Esc    / cancel
xxp_xnpr: equ 2             ;tagged no print
xxp_xncr: equ 3             ;tagged no cursor
xxp_xcnt: equ 4             ;contin line formed (without pressing return)
xxp_xclk: equ 5             ;left mouse button while pointer off tablet
xxp_xmnu: equ 6             ;user made menu selection
xxp_xunk: equ 7             ;unknown keyboard input (e.g. left/right Amiga)
xxp_xnrr: equ 8             ;window became too narrow
xxp_xshl: equ 9             ;window became too shallow
xxp_xoff: equ 10            ;can't obey fixed offset
xxp_xfnt: equ 11            ;can't attach font (out of memory)

* data pointed to by xxp_slid
 STRUCTURE xxp_slis,0
 LONG xxp_draw             ;screen DrawInfo
 APTR xxp_szob             ;Size Object
 APTR xxp_lfob             ;Left Object
 APTR xxp_rtob             ;Right Object
 APTR xxp_upob             ;Up Object
 APTR xxp_dnob             ;Down Object
 APTR xxp_ckob             ;Check Object
 LONG xxp_psec             ;prefs keyboard repeat secs
 LONG xxp_pmic             ;                      micros
 LONG xxp_asec             ;last boopsi message   secs
 LONG xxp_amic             ;                      micros
 LABEL xxp_slsz            ;Size of xxp_slis

* data pointed to by xxp_scrl
 STRUCTURE xxp_scro,0
 APTR xxp_scoh             ;horizontal scroller object
 APTR xxp_slfo             ;  left object
 APTR xxp_srto             ;  right object
 APTR xxp_scov             ;vertical scroller object
 APTR xxp_supo             ;  up object
 APTR xxp_sdno             ;  down object
 APTR xxp_gcnt             ;gadtools context
 LONG xxp_hztp             ;horizontal top
 LONG xxp_hzvs             ;           visible
 LONG xxp_hztt             ;           total
 LONG xxp_vttp             ;vertical   top
 LONG xxp_vtvs             ;           visible
 LONG xxp_vttt             ;           total
 LABEL xxp_scrs            ;size of xxp_scro

* structure to hold GUI prefs (in xxp_pref)
 STRUCTURE xxp_yprf,0      ;GUI prefs
 STRUCT xxp_yfon,32        ;requester fontname
 WORD xxp_yhgt             ;          fontheight
 BYTE xxp_ysty             ;          fontstyle
 BYTE xxp_yspc             ;          fontspacing
 STRUCT xxp_yfsh,32        ;show data fontname (height 8)
 STRUCT xxp_ychs,8         ;choose  bkgrnd,titl,txt pens; horz,vrt gaps; 000
 STRUCT xxp_yinp,8         ;input   ditto
 STRUCT xxp_yinf,8         ;info    ditto
 STRUCT xxp_yprg,8         ;prog    ditto  (no title, horz=prgress, no vert)
 STRUCT xxp_ydat,8         ;data    ditto  (no vert)
 STRUCT xxp_yshw,8         ;show    ditto  (no horz, no vert)
 LABEL xxp_ypsz

******************* MACRO's for tandem.library ************************

* macro for NewMenu structure
TLnm: MACRO
 IFEQ \1-1
 dc.b NM_TITLE,0
 ENDC
 IFEQ \1-2
 dc.b NM_ITEM,0
 ENDC
 IFEQ \1-3
 dc.b NM_SUB,0
 ENDC
 IFGE \1-4
 dc.b NM_END,0
 ENDC
 IFEQ \2+1
 dc.l NM_BARLABEL
 ENDC
 IFNE \2+1
 dc.l \2
 ENDC
 IFGE NARG-3
 dc.l \3          ;\3=0, CommKey ptr, or 0<strnum<1024, next chr of strnum.
 ENDC             ;      Thus for example all commkeys may be in string 27,
 IFLT NARG-3      ;      when ea. param 3 is 27 & chrs get picked off 1 by 1
 dc.l 0           ;(if no \3, assume 0)
 ENDC
 IFGE NARG-4
 dc.w \4          ;\4=flags (usually omitted)
 ENDC
 IFLT NARG-4
 dc.w 0           ;(if no \4, assume 0)
 ENDC
 IFGE NARG-5
 dc.l \5,0        ;\5=mutual exclude (usually omitted)
 ENDC
 IFLT NARG-5
 dc.l 0,0         ;(if no \5, assume 0)
 ENDC
 ENDM

;  **** All MACRO's *must* be called with A4 pointing to xxp_buff ****

* MACRO used by MACRO's below
TLDo: MACRO                ;\1=function name w/out TL, e.g. Height
 move.l a6,-(a7)           ;save all except whatever tandem.library changes
 move.l xxp_tanb(a4),a6    ;a6=tanbase     * Use TLDo direct after loading
 jsr _LVOTL\1(a6)          ;do the call    * the registers "by hand"; else
 move.l (a7)+,a6           ;restore a6     * use the MACRO's below. Assume
 ENDM                      ;               * CCR is undefined after TLDo.

* MACRO's for calling tandem.library
TLfsub: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 TLDo Fsub
 move.l (a7)+,d0
 ENDM

TLstrbuf: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 TLDo Strbuf
 move.l (a7)+,d0
 ENDM

TLstra0: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 TLDo Stra0
 move.l (a7)+,d0
 ENDM

TLerror: MACRO
 TLDo Error
 tst.l d0
 eori #-1,CCR
 ENDM

TLopenread: MACRO
 TLDo Openread
 tst.l D0
 ENDM

TLopenwrite: MACRO
 TLDo Openwrite
 tst.l D0
 ENDM

TLwritefile: MACRO
 movem.l d2-d3,-(a7)
 move.l \1,d2
 move.l \2,d3
 TLDo Writefile
 movem.l (a7)+,d2-d3
 tst.l xxp_errn(a4)
 eori #-1,CCR
 ENDM

TLreadfile: MACRO
 movem.l d2-d3,-(a7)
 move.l \1,d2
 move.l \2,d3
 TLDo Readfile
 movem.l (a7)+,d2-d3
 tst.l xxp_errn(a4)
 eori #-1,CCR
 ENDM

TLclosefile: MACRO
 TLDo Closefile
 ENDM

TLaschex: MACRO
 move.l \1,a0
 TLDo Aschex
 tst.l d0
 ENDM

TLhexasc: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 move.l \2,a0
 TLDo Hexasc
 move.l (a7)+,d0
 ENDM

TLoutput: MACRO
 move.l d0,-(a7)
 TLDo Output
 move.l (a7)+,d0
 ENDM

TLinput: MACRO
 move.l d0,-(a7)
 TLDo Input
 move.l (a7)+,d0
 ENDM

TLpublic: MACRO
 move.l \1,d0
 TLDo Public
 tst.l d0
 ENDM

TLchip: MACRO
 move.l \1,d0
 TLDo Chip
 tst.l d0
 ENDM

TLprogdir: MACRO
 TLDo Progdir
 ENDM

TLkeyboard: MACRO
 TLDo Keyboard
 ENDM

TLwindow: MACRO
 movem.l d1-d7/a0,-(a7)
 move.l \1,d0
 IFGT NARG-1
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 move.l \5,d4
 move.l \6,d5
 move.l \7,d6
 move.l \8,d7
 IFGE NARG-9
 move.l \9,a0
 ENDC
 ENDC
 TLDo Window
 movem.l (a7)+,d1-d7/a0
 tst.l d0
 ENDM

TLwclose: MACRO
 TLDo Wclose
 ENDM

TLtext: MACRO
 movem.l d0-d1,-(a7)
 move.l \1,d0
 move.l \2,d1
 TLDo Text
 movem.l (a7)+,d0-d1
 ENDM

TLtsize: MACRO
 TLDo Tsize
 ENDM

TLwfront: MACRO
 TLDo Wfront
 ENDM

TLgetfont: MACRO
 movem.l d0-d1/a0,-(a7)
 move.l \1,a0
 move.l \2,d0
 move.l \3,d1
 TLDo Getfont
 movem.l (a7)+,d0-d1/a0
 ENDM

TLnewfont: MACRO
 movem.l d0-d2,-(a7)
 move.l \1,d0
 move.l \2,d1
 moveq #0,d2
 IFGE NARG-3
 move.l \3,d2
 ENDC
 TLDo Newfont
 tst.l D0
 movem.l (a7)+,d0-d2
 ENDM

TLaslfont: MACRO
 movem.l d0-d1,-(a7)
 move.l \1,d0
 TLDo Aslfont
 tst.l d0
 movem.l (a7)+,d0-d1
 ENDM

TLaslfile: MACRO
 movem.l d1/a0-a1,-(a7)
 move.l \1,a0
 move.l \2,a1
 move.l \3,d0
 moveq #1,d1
 IFC '\4','sv'
 moveq #-1,d1
 ENDC
 TLDo Aslfile
 movem.l (a7)+,d1/a0-a1
 tst.l d0
 ENDM

TLwslof: MACRO
 TLDo Wslof
 ENDM

TLreqbev: MACRO
 movem.l d0-d5/a0,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 and.l #$FFFF,d0
 IFGE NARG-5
 IFC '\5','rec'
 bset #31,d0
 ENDC
 IFC '\5','box'
 bset #30,d0
 ENDC
 ENDC
 IFGE NARG-6
 IFNC '\6',''
 move.l \6,a0
 bset #31,d1
 ENDC
 ENDC
 IFGE NARG-7
 bset #29,d0
 move.l \7,d4
 ENDC
 IFEQ NARG-8
 moveq #2,d5
 ENDC
 IFGE NARG-8
 move.l \8,d5
 ENDC
 TLDo Reqbev
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 movem.l (a7)+,d0-d5/a0
 ENDM

TLreqarea: MACRO
 movem.l d0-d4/a0,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 IFGE NARG-5
 IFNC '\5',''
 bset #29,d0
 move.l \5,d4
 ENDC
 ENDC
 IFGE NARG-6
 bset #31,d1
 move.l \6,a0
 ENDC
 TLDo Reqarea
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 movem.l (a7)+,d0-d4/a0
 ENDM

TLreqcls: MACRO
 TLDo Reqcls
 ENDM

TLreqfull: MACRO
 TLDo Reqfull
 ENDM

TLreqchoose: MACRO
 move.l d1,-(a7)
 moveq #0,d1
 IFEQ NARG-2
 move.l \1,d0
 move.l \2,d1
 ENDC
 TLDo Reqchoose
 move.l (a7)+,d1
 tst.l d0
 ENDM

TLreqinput: MACRO
 movem.l d1-d3,-(a7)
 move.l \1,d0
 moveq #0,d1
 moveq #20,d2
 IFGE NARG-2
 IFC '\2','num'
 moveq #-1,d1
 moveq #4,d2
 ENDC
 ENDC
 IFGE NARG-2
 IFC '\2','hex'
 moveq #1,d1
 moveq #8,d2
 ENDC
 ENDC
 IFGE NARG-3
 move.l \3,d2
 ENDC
 moveq #0,d3
 IFGE NARG-4
 move.l \4,d3
 ENDC
 TLDo Reqinput
 move.l d0,d1
 move.l xxp_valu(a4),d0
 tst.l d1
 movem.l (a7)+,d1-d3
 ENDM

TLreqedit: MACRO
 movem.l d1/a0,-(a7)
 move.l \1,d0
 move.l \2,d1

 IFNC '\3','0'           ;do if \3 = custom tags
 IFNC '\3','1'
 move.l \3,a0
 TLDo Reqedit
 movem.l (a7)+,d1/a0
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 MEXIT
 ENDC
 ENDC

 movem.l a1/a5,-(a7)      ;do if \3 = 0 or 1 (default tags for plain, styl)
 sub.w #100,a7
 move.l a7,a1
 move.l #xxp_xtext,(a1)+  ;tag 1: text = a4
 move.l a4,(a1)+
 IFC '\3','1'
 move.l #xxp_xstyl,(a1)+  ;tag 2: styl = FWork+256    (tag 2-4 styl only)
 move.l xxp_FWork(a4),(a1)
 add.l #256,(a1)+
 move.l #xxp_xfont,(a1)+  ;tag 3: font = as per AcWind
 move.l xxp_AcWind(a4),a5
 clr.w (a1)+
 move.w xxp_Fnum(a5),(a1)+
 move.l #xxp_xcspc,(a1)+  ;tag 4: cspc = as per AcWind
 clr.w (a1)+
 move.w xxp_Tspc(a5),(a1)+
 ENDC
 move.l #xxp_xmaxc,(a1)+  ;tag 5: maxc = \4, deflt 20, or 4 if num, 8 if hex
 move.l #20,(a1)+
 IFGE NARG-8
 IFC '\8','num'
 move.l #4,-4(a1)
 ENDC
 IFC '\8','hex'
 move.l #8,-4(a1)
 ENDC
 ENDC
 IFGE NARG-4
 IFNC '\4',''
 move.l \4,-4(a1)
 ENDC
 ENDC
 IFGE NARG-5              ;tag 6: maxt = \5, dflt none
 IFNC '\5',''
 move.l #xxp_xmaxt,(a1)+
 move.l \5,(a1)+
 ENDC
 ENDC
 IFGE NARG-6              ;tag 7: maxw = \6, dflt none
 IFNC '\6',''
 move.l #xxp_xmaxw,(a1)+
 move.l \6,(a1)+
 ENDC
 ENDC
 IFGE NARG-7              ;tag 8: menu = \7, dflt none
 IFNC '\7',''
 move.l #xxp_xmenu,(a1)+
 move.l \7,(a1)+
 ENDC
 ENDC
 IFGE NARG-8              ;tag 9: task = str/num/hex, default str
 IFNC '\8',''
 move.l xxp_xtask,(a1)+
 clr.l (a1)+
 IFC '\8','num'
 move.l #xxp_xtdec,-4(a1)
 ENDC
 IFC \'8','hex'
 move.l #xxp_xthex,-4(a1)
 ENDC
 ENDC
 ENDC
 move.l #xxp_xiclr,(a1)+  ;tag 10: iclr = -1
 move.l #-1,(a1)+
 move.l #xxp_xtral,(a1)+  ;tag 11: tral = -1
 move.l #-1,(a1)+
 move.l #xxp_xforb,(a1)+
 IFC '\3','0'             ;tag 12: forb = 0/xxp_xesty
 move.l #xxp_xesty,(a1)+
 ENDC
 IFC '\3','1'
 clr.l (a1)+
 ENDC
 clr.l (a1)               ;delimit tags
 move.l a7,a0
 TLDo Reqedit             ;do the edit
 add.w #100,a7            ;discard tags
 movem.l (a7)+,a1/a5
 movem.l (a7)+,d1/a0
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLreqshow: MACRO
 movem.l d1-d2/a5,-(a7)
 move.l \1,a0
 move.l \2,d0
 move.l \3,d1
 move.l \4,d2
 moveq #0,d3
 IFGE NARG-5
 move.l \5,d3
 ENDC
 IFGE NARG-6
 IFC 'seek','\6'
 bset #31,d2
 ENDC
 IFC 'smart','\6'
 bset #31,d2
 bset #30,d2
 ENDC
 ENDC
 move.l #-1,xxp_lcom(a4)
 IFGE NARG-7
 move.l \7,xxp_lcom(a4)
 ENDC
 TLDo Reqshow
 movem.l (a7)+,d1-d2/a5
 tst.l d0
 ENDM

TLassdev: MACRO
 TLDo Assdev
 tst.l d0
 ENDM

TLreqmenu: MACRO
 movem.l d0/a0,-(a7)
 move.l \1,a0
 TLDo Reqmenu
 tst.l d0
 movem.l (a7)+,d0/a0
 ENDM

TLreqmuset: MACRO
 TLDo Reqmuset
 ENDM

TLreqmuclr: MACRO
 TLDo Reqmuclr
 ENDM

TLreqinfo: MACRO
 movem.l d1-d2,-(a7)
 move.l \1,d0
 moveq #1,d1
 moveq #1,d2
 IFNE NARG-1
 move.l \2,d1
 IFNE NARG-2
 move.l \3,d2
 ENDC
 ENDC
 TLDo Reqinfo
 movem.l (a7)+,d1-d2
 tst.l d0
 ENDM

TLwpoll: MACRO
 TLDo Wpoll
 tst.l d0
 ENDM

TLtrim: MACRO
 movem.l d0-d1,-(a7)
 move.l \1,d0
 move.l \2,d1
 TLDo Trim
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 movem.l (a7)+,d0-d1
 ENDM

TLwsub: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 TLDo Wsub
 move.l (a7)+,d0
 ENDM

TLwpop: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 TLDo Wpop
 move.l (a7)+,d0
 ENDM

TLmultiline: MACRO
 movem.l d0-d1,-(a7)
 move.l \1,d0
 move.l \2,d1
 TLDo Multiline
 movem.l (a7)+,d0-d1
 tst.l xxp_errn(a4)
 eori.w #-1,ccr
 ENDM

TLwupdate: MACRO
 TLDo Wupdate
 ENDM

TLwcheck: MACRO
 movem.l d0-d1,-(a7)
 TLDo Wcheck
 tst.l d0
 movem.l (a7)+,d0-d1
 ENDM

TLfloat: MACRO
 move.l \1,a0
 move.l \2,a1
 TLDo Float
 tst.w d0
 eori.w #-1,ccr
 ENDM

TLbusy: MACRO
 TLDo Busy
 ENDM

TLunbusy: MACRO
 TLDo Unbusy
 ENDM

TLreqcolor: MACRO
 move.l \1,d0
 TLDo Reqcolor
 tst.l d0
 ENDM

TLonmenu: MACRO
 movem.l d0-d2,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 TLDo Onmenu
 movem.l (a7)+,d0-d2
 ENDM

TLoffmenu: MACRO
 movem.l d0-d2,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 TLDo Offmenu
 movem.l (a7)+,d0-d2
 ENDM

TLprefdir: MACRO
 movem.l d0/a0,-(a7)
 move.l \1,a0
 moveq #0,d0
 IFC '\2','save'
 moveq #-1,d0
 ENDC
 TLDo Prefdir
 movem.l (a7)+,d0/a0
 ENDM

TLpreffil: MACRO
 movem.l d0-d3/a0,-(a7)
 move.l \1,a0
 moveq #0,d0
 IFC '\2','save'
 moveq #-1,d0
 ENDC
 move.l \3,d2
 move.l \4,d3
 TLDo Preffil
 movem.l (a7)+,d0-d3/a0
 ENDM

TLbad: MACRO
 move.l d0,-(a7)
 move.l \1,d0
 TLDo Strbuf
 TLDo Output
 move.l (a7)+,d0
 subq.w #1,xxp_ackn(a4)
 ENDM

TLstring: MACRO
 TLstrbuf \1
 TLtrim \2,\3
 ENDM

TLoutstr: MACRO
 TLstrbuf \1
 TLoutput
 ENDM

* easy call to TLWindow  (opens window 0, title must be in st_1)
TLwindow0: MACRO
 TLwindow #-1
 TLwindow #0,#0,#0,#640,#100,xxp_Width(a4),xxp_Height(a4),#0,#st_1
 ENDM

* open a private screen for WSuite \1=depth, \2=title, \3=pens [\4 display]
TLscreen: MACRO
 movem.l d0-d1/a0-a1/a6,-(a7)
 sub.l #52,a7                 ;room for 6 tags
 move.l a7,a0
 move.l #SA_Width,(a0)+       ;tag 1
 move.l #STDSCREENWIDTH,(a0)+
 move.l #SA_Height,(a0)+      ;tag 2
 move.l #STDSCREENHEIGHT,(a0)+
 move.l #SA_Depth,(a0)+       ;tag 3
 move.l \1,(a0)+
 move.l #SA_Title,(a0)+       ;tag 4
 move.l \2,(a0)+
 move.l #SA_Pens,(a0)+        ;tag 5
 move.l \3,(a0)+
 move.l #SA_DisplayID,(a0)+   ;tag 6
 IFEQ NARG-3
 move.l #HIRES_KEY,(a0)+      ;no \4, hires
 ENDC
 IFEQ NARG-4
 move.l \4,(a0)+              ;if \4 -> display id
 ENDC
 move.l #TAG_END,(a0)+        ;delimit
 move.l xxp_intb(a4),a6
 sub.l a0,a0
 move.l a7,a1
 jsr _LVOOpenScreenTagList(a6)
 clr.w xxp_Public(a4)         ;tell Front.i to close screen on closedown
 add.l #52,a7
 move.l d0,xxp_Screen(a4)
 movem.l (a7)+,d0-d1/a0-a1/a6 ;EQ if bad
 ENDM

* attach mem to a windows Mmem   a5=window's wsuw  \1=addr  \2=size
* The mem *must* created by AllocVec (*not* e.g. TLpublic)
TLattach: MACRO
 movem.l d0-d1/a0,-(a7)    ;save all
 move.l \1,a0
 move.l a0,xxp_Mmem(a5)    ;put in mem pointer
 clr.b (a0)+               ;initialise text memory
 move.l a0,xxp_Mtop(a5)
 subq.l #1,a0
 move.l \2,d0              ;d0 = Mmsz
 move.l d0,xxp_Mmsz(a5)
 add.l d0,a0
 clr.b -34(a0)             ;init ffil } file, dir used in TLMultiline
 clr.b -164(a0)            ;init fdir } TLAslfile calls
 clr.l xxp_Mcrr(a5)
 clr.l xxp_Mtpl(a5)
 move.w #76,xxp_Mmxc(a5)
 movem.l (a7)+,d0-d1/a0
 ENDM

TLgetilbm: MACRO
 movem.l d0-d1/a1,-(a7)
 moveq #-1,d0
 move.l \1,d1
 move.l \2,a1
 IFGE NARG-3
 IFNC '\3',''
 moveq #0,d0
 ENDC
 ENDC
 IFGE NARG-4
 bset #31,d1
 ENDC
 TLDo Getilbm
 movem.l (a7)+,d0-d1/a1
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLputilbm: MACRO
 movem.l d0-d3/a0,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 move.l \5,a0
 TLDo Putilbm
 movem.l (a7)+,d0-d3/a0
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLresize: MACRO
 movem.l d0-d5/a0,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 move.l \5,d4
 move.l \6,d5
 moveq #0,d6
 IFGE NARG-7
 IFNC '\7',''
 move.l \7,d6
 ENDC
 ENDC
 IFGE NARG-8
 move.l \8,a0
 bset #31,d1
 ENDC
 TLDo Resize
 movem.l (a7)+,d0-d5/a0
 ENDM

TLellipse: MACRO
 movem.l d0-d7/a0,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 move.l \5,d4
 move.l \6,d5
 move.l \7,d6
 move.l \8,d7
 IFGE NARG-9
 IFNC '\9',''
 move.l \9,a0
 bset #31,d1
 ENDC
 IFGE NARG-10
 bset #31,d0
 ENDC
 ENDC
 TLDo Ellipse
 movem.l (a7)+,d0-d7/a0
 tst.l xxp_errn(a4)
 eori.w #-1CCR
 ENDM

TLgetarea: MACRO
 movem.l d0-d3/a0,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 move.l \5,a0
 TLDo Getarea
 tst.l d0
 movem.l (a7)+,d0-d3/a0
 ENDM

TLprogress: MACRO
 movem.l d0-d2,-(a7)
 move.l \1,d0
 move.l \2,d1
 moveq #0,d2
 IFGE NARG-3
 moveq #-1,d2
 IFC '\3','%'
 moveq #1,d2
 ENDC
 ENDC
 TLDo Progress
 movem.l (a7)+,d0-d2
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLreqoff: MACRO
 TLDo Reqoff
 ENDM

TLhexasc16: MACRO
 movem.l d0-d1,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,a0
 TLDo Hexasc16
 movem.l (a7)+,d0-d1
 ENDM

TLreqfont: MACRO
 move.l \1,d0
 TLDo Reqfont
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLdata: MACRO
 movem.l d0-d1,-(a7)
 move.l \1,d0
 move.l \2,d1
 TLDo Data
 tst.l d0
 movem.l (a7)+,d0-d1
 ENDM

TLwscroll: MACRO
 movem.l d0-d1,-(a7)
 moveq #-1,d0
 IFC '\1','set'
 moveq #0,d0
 ENDC
 moveq #0,d1
 IFGE NARG-2
 IFC '\2','vert'
 moveq #-1,d1
 ENDC
 IFC '\2','horz'
 moveq #1,d1
 ENDC
 ENDC
 TLDo Wscroll
 movem.l (a7)+,d0-d1
 ENDM

TLbutmon: MACRO
 movem.l d1-d2,-(a7)
 move.l \1,d1
 move.l \2,d2
 TLDo Butmon
 tst.l d0
 movem.l (a7)+,d1-d2
 ENDM

TLbutstr: MACRO
 move.l a0,-(a7)
 move.l \1,a0
 TLDo Butstr
 move.l (a7)+,a0
 ENDM

TLbutprt: MACRO
 TLDo Butprt
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLbuttxt: MACRO
 move.l a0,-(a7)
 move.l \1,a0
 TLDo Buttxt
 move.l (a7)+,a0
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLslider: MACRO
 move.l a5,-(a7)
 move.l \1,a5
 TLDo Slider
 move.l (a7)+,a5
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLpassword: MACRO
 move.l \1,d0
 TLDo Password
 tst.l d0
 ENDM

TLslimon: MACRO
 movem.l d0-d3,-(a7)
 move.l \1,d1
 move.l \2,d2
 move.l \3,d3
 TLDo Slimon
 tst.l d0
 movem.l (a7)+,d0-d3
 ENDM

TLreqredi: MACRO
 move.l a5,-(a7)
 move.l \1,a5
 TLDo Reqredi
 move.l (a7)+,a5
 ENDM

TLreqchek: MACRO
 movem.l d2-d3,-(a7)
 move.l \1,d2
 move.l \2,d3
 TLDo Reqchek
 movem.l (a7)+,d2-d3
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLreqon: MACRO
 move.l \1,a5
 TLDo Reqon
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLprefs: MACRO
 move.l d0,-(a7)
 moveq #1,d0
 IFGE NARG-1
 moveq #-1,d0
 ENDC
 TLDo Prefs
 move.l (a7)+,d0
 ENDM

TLmget: MACRO
 TLDo Mget
 tst.l d0
 ENDM

TLfreebmap: MACRO
 movem.l d0-d2/a0-a3/a6,-(a7)
 move.l xxp_sysb(a4),a6
 move.l \1,a3
 move.l a3,a2
 addq.l #bm_Planes,a2
 moveq #0,d2
 move.b bm_Depth(a3),d2
 subq.w #1,d2
.fbmp:
 move.l (a2)+,a1
 jsr _LVOFreeVec(a6)
 dbra d2,.fbmp
 move.l a3,a1
 jsr _LVOFreeVec(a6)
 movem.l (a7)+,d0-d2/a0-a3/a6
 ENDM

TLembed: MACRO
 ENDM

TLtabmon: MACRO
 movem.l d1-d3,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 move.l \4,d3
 TLDo Tabmon
 movem.l (a7)+,d1-d3
 tst.l d0
 ENDM

TLpict:MACRO
 movem.l d0-d2,-(a7)
 move.l \1,d0
 move.l \2,d1
 move.l \3,d2
 TLDo Pict
 movem.l (a7)+,d0-d2
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLtabs: MACRO
 movem.l d0-d3,-(a7)
 move.l \1,d0
 IFGE NARG-2
 move.l \2,d1
 IFGE NARG-3
 move.l \3,d2
 IFGE NARG-4
 move.l \4,d3
 ENDC
 ENDC
 ENDC
 TLDo Tabs
 movem.l (a7)+,d0-d3
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDM

TLdropdown: MACRO
 movem.l d0-d7,-(a7)
 moveq #-1,d0
 IFC 'draw','\1'
 moveq #0,d0
 ENDC
 move.l \2,d1
 move.l \3,d2
 moveq #1,d3
 IFNC '','\4'
 move.l \4,d3
 ENDC
 move.l \5,d4
 move.l \6,d5
 moveq #0,d6
 IFGE NARG-7
 IFNC '','\7'
 move.l \7,d6
 ENDC
 ENDC
 moveq #7,d7
 IFGE NARG-8
 IFNC 'cycle','\8'
 move.l \8,d7
 ENDC
 IFC 'cycle','\8'
 moveq #-1,d7
 ENDC
 ENDC
 TLDo Dropdown
 IFNC 'draw','\1'
 move.l d0,(a7)
 ENDC
 movem.l (a7)+,d0-d7
 IFC 'draw','\1'
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 ENDC
 ENDM
