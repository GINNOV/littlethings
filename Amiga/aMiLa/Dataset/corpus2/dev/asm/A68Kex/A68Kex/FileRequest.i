_AbsExecBase equ 4

**** exec ****

_LVOAllocMem       equ -$c6
_LVOFreeMem        equ -$d2
_LVOGetMsg         equ -$174
_LVOReplyMsg       equ -$17a
_LVOOldOpenLibrary equ -$198
_LVOCloseLibrary   equ -$19e
_LVOOpenDevice     equ -$1bc
_LVOCloseDevice    equ -$1c2
_LVODoIO           equ -$1c8

*** intuition ***

_LVOCloseWindow    equ -$48
_LVOModifyProp     equ -$9c
_LVOOffGadget      equ -$ae
_LVOOpenWindow     equ -$cc
_LVOPrintIText     equ -$d8
_LVORefreshGadgets equ -$de
_LVOScreenToFront  equ -$fc

*** dos ****

_LVOWrite          equ -$30
_LVOOutput         equ -$3c
_LVOLock           equ -$54
_LVOUnLock         equ -$5a
_LVOExamine        equ -$66
_LVOExNext         equ -$6c

**** graphics ****

_LVORectFill       equ -$132
_LVOSetAPen        equ -$156
_LVOScrollRaster   equ -$18c

im_Class         equ $14
im_Code          equ $18
im_IAddress      equ $1c
gg_GadgetID      equ $26
wd_RPort         equ $32
wd_UserPort      equ $56

aa6  set 0
exec equ 1
int  equ 2
dos  equ 3
graf equ 4

CALLEXEC macro
         ifne    (aa6-exec)
         movea.l _AbsExecBase,a6
aa6      set exec
         endif
         jsr     _LVO\1(a6)
         endm

CALLINT  macro
         movea.l _IntuitionBase(pc),a6
aa6      set int
         jsr     _LVO\1(a6)
         endm

INTNAME  macro
         dc.b 'intuition.library',0
         endm

CALLDOS  macro
         ifne    (aa6-dos)
         movea.l _DOSBase(pc),a6
aa6      set dos
         endif
         jsr     _LVO\1(a6)
         endm

DOSNAME  macro
         dc.b 'dos.library',0
         endm

CALLGRAF macro
         ifne    (aa6-graf)
         movea.l _GfxBase(pc),a6
aa6      set graf
         endif
         jsr     _LVO\1(a6)
         endm

GRAFNAME macro
         dc.b 'graphics.library',0
         endm


DLT_DEVICE   equ 0
RP_JAM1      equ 0
RP_JAM2      equ 1
RELVERIFY    equ 1
BOOLGADGET   equ 1
GADGHBOX     equ 1
WBENCHSCREEN equ 1
AUTOKNOB     equ 1
GADGHIMAGE   equ 2
WINDOWDRAG   equ 2
PROPGADGET   equ 3
STRGADGET    equ 4
FREEVERT     equ 4
GADGETDOWN   equ $20
GADGETUP     equ $40
ACTIVATE     equ $1000
DISKINSERTED equ $8000
DISKREMOVED  equ $10000
RMBTRAP      equ $10000

dn_Next    equ 0
dn_Type    equ 4
di_DevInfo equ 4
rn_Info    equ $18
dl_Root    equ $22
dn_Name    equ $28


