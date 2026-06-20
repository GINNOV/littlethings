EXTERN_LIB MACRO
 XREF _LVO\1
 ENDM
STRUCTURE MACRO
\1 EQU 0
SOFFSET SET \2
 ENDM
FPTR MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+4
 ENDM
BOOL MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+2
 ENDM
BYTE MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+1
 ENDM
UBYTE MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+1
 ENDM
WORD MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+2
 ENDM
UWORD MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+2
 ENDM
SHORT MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+2
 ENDM
USHORT MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+2
 ENDM
LONG MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+4
 ENDM
ULONG MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+4
 ENDM
FLOAT MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+4
 ENDM
DOUBLE MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+8
 ENDM
APTR MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+4
 ENDM
CPTR MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+4
 ENDM
RPTR MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+2
 ENDM
LABEL MACRO
\1 EQU SOFFSET
 ENDM
STRUCT MACRO
\1 EQU SOFFSET
SOFFSET SET SOFFSET+\2
 ENDM
ALIGNWORD MACRO
SOFFSET SET (SOFFSET+1)&$fffffffe
 ENDM
ALIGNLONG MACRO
SOFFSET SET (SOFFSET+3)&$fffffffc
 ENDM
ENUM MACRO
 IFC '\1',''
EOFFSET SET 0
 ENDC
 IFNC '\1',''
EOFFSET SET \1
 ENDC
 ENDM
EITEM MACRO
\1 EQU EOFFSET
EOFFSET SET EOFFSET+1
 ENDM
BITDEF MACRO
 BITDEF0 \1,\2,B_,\3
\@BITDEF SET 1<<\3
 BITDEF0 \1,\2,F_,\@BITDEF
 ENDM
BITDEF0 MACRO
\1\3\2 EQU \4
 ENDM
JSRLIB MACRO
 XREF _LVO\1
 jsr _LVO\1(a6)
 ENDM
JMPLIB MACRO
 XREF _LVO\1
 jmp _LVO\1(a6)
 ENDM
BSRSELF MACRO
 XREF \1
 bsr \1
 ENDM
BRASELF MACRO
 XREF \1
 bra \1
 ENDM
BLINK MACRO
 IFNE DEBUG_DETAIL
 bchg.b #1,$bfe001
 ENDC
 ENDM
TRIGGER MACRO
 IFGE DEBUG_DETAIL-\1
 move.w #$5555,$2fe
 ENDC
 ENDM
CLEAR MACRO
 moveq.l #0,\1
 ENDM
CLEARA MACRO
 suba.l \1,\1
 ENDM
PRINTF MACRO
 IFGE DEBUG_DETAIL-\1
 XREF kprint_macro
PUSHCOUNT SET 0
 IFNC '\9',''
 move.l \9,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 IFNC '\8',''
 move.l \8,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 IFNC '\7',''
 move.l \7,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 IFNC '\6',''
 move.l \6,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 IFNC '\5',''
 move.l \5,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 IFNC '\4',''
 move.l \4,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 IFNC '\3',''
 move.l \3,-(sp)
PUSHCOUNT SET PUSHCOUNT+4
 ENDC
 movem.l a0/a1,-(sp)
 lea.l PSS\@(pc),A0
 lea.l 4*2(SP),A1
 BSR kprint_macro
 movem.l (sp)+,a0/a1
 bra.s PSE\@
PSS\@ dc.b \2
 IFEQ (\1&1)
 dc.b 13,10
 ENDC
 dc.b 0
 ds.w 0
PSE\@
 lea.l PUSHCOUNT(sp),sp
 ENDC
 ENDM
PUSHM MACRO
 IFGT NARG-1
 FAIL
 ENDC
PUSHM_COUNT SET PUSHM_COUNT+1
PUSHM_\*VALOF(PUSHM_COUNT) REG \1
 movem.l PUSHM_\*VALOF(PUSHM_COUNT),-(sp)
 ENDM
POPM MACRO
 movem.l (sp)+,PUSHM_\*VALOF(PUSHM_COUNT)
 IFNC '\1','NOBUMP'
PUSHM_COUNT SET PUSHM_COUNT+1
 ENDC
 ENDM
NEWLIST MACRO
 MOVE.L \1,LH_TAILPRED(\1)
 ADDQ.L #4,\1
 CLR.L (\1)
 MOVE.L \1,-(\1)
 ENDM
TSTLIST MACRO
 IFGT NARG-1
 FAIL
 ENDC
 IFC '\1',''
 CMP.L LH_TAIL+LN_PRED(A0),A0
 ENDC
 IFNC '\1',''
 CMP.L LH_TAIL+LN_PRED(\1),\1
 ENDC
 ENDM
TSTLST2 MACRO
 MOVE.L \1,\2
 TST.L (\2)
 ENDM
SUCC MACRO
 MOVE.L (\1),\2
 ENDM
PRED MACRO
 MOVE.L LN_PRED(\1),\2
 ENDM
IFEMPTY MACRO
 CMP.L LH_TAIL+LN_PRED(\1),\1
 BEQ \2
 ENDM
IFNOTEMPTY  MACRO
 CMP.L LH_TAIL+LN_PRED(\1),\1
 BNE \2
 ENDM
TSTNODE MACRO
 MOVE.L (\1),\2
 TST.L (\2)
 ENDM
NEXTNODE MACRO
 MOVE.L \1,\2
 MOVE.L (\2),\1
 IFC '\0',''
 BEQ \3
 ENDC
 IFNC '\0',''
 BEQ.S \3
 ENDC
 ENDM
ADDHEAD MACRO
 MOVE.L (A0),D0
 MOVE.L A1,(A0)
 MOVEM.L D0/A0,(A1)
 MOVE.L D0,A0
 MOVE.L A1,LN_PRED(A0)
 ENDM
ADDTAIL MACRO
 ADDQ.L #LH_TAIL,A0
 MOVE.L LN_PRED(A0),D0
 MOVE.L A1,LN_PRED(A0)
 EXG D0,A0
 MOVEM.L D0/A0,(A1)
 MOVE.L A1,(A0)
 ENDM
REMOVE MACRO
 MOVE.L (A1)+,A0
 MOVE.L (A1),A1
 MOVE.L A0,(A1)
 MOVE.L A1,LN_PRED(A0)
 ENDM
REMHEAD MACRO
 MOVE.L (A0),A1
 MOVE.L (A1),D0
 BEQ.S REMHEAD\@
 MOVE.L D0,(A0)
 EXG.L D0,A1
 MOVE.L A0,LN_PRED(A1)
REMHEAD\@
 ENDM
REMHEADQ MACRO
 MOVE.L (\1),\2
 MOVE.L (\2),\3
 MOVE.L \3,(\1)
 MOVE.L \1,LN_PRED(\3)
 ENDM
REMTAIL MACRO
 MOVE.L LH_TAIL+LN_PRED(A0),A1
 MOVE.L LN_PRED(A1),D0
 BEQ.S REMTAIL\@
 MOVE.L D0,LH_TAIL+LN_PRED(A0)
 EXG.L D0,A1
 MOVE.L A0,(A1)
 ADDQ.L #4,(A1)
REMTAIL\@
 ENDM
ALERT MACRO
 movem.l d7/a5/a6,-(sp)
 move.l #\1,d7
 IFNC '\2',''
 lea.l \2,a5
 ENDC
 move.l 4,a6
 jsr _LVOAlert(a6)
 movem.l (sp)+,d7/a5/a6
 ENDM
DEADALERT MACRO
 move.l #\1,d7
 IFNC '\2',''
 lea.l \2,a5
 ENDC
 move.l 4,a6
 jsr _LVOAlert(a6)
 ENDM
INITBYTE MACRO
 IFLE (\1)-255
 DC.B $a0,\1
 DC.B  \2,0
 MEXIT
 ENDC
 DC.B $e0,0
 DC.W \1
 DC.B \2,0
 ENDM
INITWORD MACRO
 IFLE (\1)-255
 DC.B $90,\1
 DC.W \2
 MEXIT
 ENDC
 DC.B $d0,0
 DC.W \1
 DC.W \2
 ENDM
INITLONG MACRO
 IFLE (\1)-255
 DC.B $80,\1
 DC.L \2
 MEXIT
 ENDC
 DC.B $c0,0
 DC.W \1
 DC.L \2
 ENDM
INITSTRUCT MACRO
 DS.W 0
 IFC '\4',''
COUNT\@ SET 0
 ENDC
 IFNC '\4',''
COUNT\@ SET \4
 ENDC
CMD\@ SET (((\1)<<4)!COUNT\@)
 IFLE (\2)-255
 DC.B (CMD\@)!$80
 DC.B \2
 MEXIT
 ENDC
 DC.B CMD\@!$0C0
 DC.B (((\2)>>16)&$0FF)
 DC.W ((\2)&$0FFFF)
 ENDM
STRING MACRO
 dc.b \1
 dc.b 0
 CNOP 0,2
 ENDM
STRINGL MACRO
 dc.b 13,10
 dc.b \1
 dc.b 0
 CNOP 0,2
 ENDM
STRINGR MACRO
 dc.b \1
 dc.b 13,10,0
 CNOP 0,2
 ENDM
STRINGLR MACRO
 dc.b 13,10
 dc.b \1
 dc.b 13,10,0
 CNOP 0,2
 ENDM
LIBINIT MACRO
 IFC '\1',''
COUNT_LIB SET LIB_USERDEF
 ENDC
 IFNC '\1',''
COUNT_LIB SET \1
 ENDC
 ENDM
LIBDEF MACRO
\1 EQU COUNT_LIB
COUNT_LIB SET COUNT_LIB-LIB_VECTSIZE
 ENDM
CALLLIB MACRO
 IFGT NARG-1
 FAIL
 ENDC
 JSR \1(A6)
 ENDM
LINKLIB MACRO
 IFGT NARG-2
 FAIL
 ENDC
 MOVE.L A6,-(SP)
 MOVE.L \2,A6
 JSR \1(A6)
 MOVE.L (SP)+,A6
 ENDM
BEGINIO MACRO
 LINKLIB DEV_BEGINIO,IO_DEVICE(A1)
 ENDM
ABORTIO MACRO
 LINKLIB DEV_ABORTIO,IO_DEVICE(A1)
 ENDM
DEVINIT MACRO
 IFC '\1',''
CMD_COUNT SET CMD_NONSTD
 ENDC
 IFNC '\1',''
CMD_COUNT SET \1
 ENDC
 ENDM
DEVCMD MACRO
\1 EQU CMD_COUNT
CMD_COUNT SET CMD_COUNT+1
 ENDM
INT_ABLES MACRO
 XREF _intena
 ENDM
DISABLE MACRO
 IFC '\1',''
 MOVE.W #$04000,_intena
 ADDQ.B #1,IDNestCnt(A6)
 MEXIT
 ENDC
 IFC '\2','NOFETCH'
 MOVE.W #$04000,_intena
 ADDQ.B #1,IDNestCnt(\1)
 MEXIT
 ENDC
 IFNC '\1',''
 MOVE.L 4,\1
 MOVE.W #$04000,_intena
 ADDQ.B #1,IDNestCnt(\1)
 MEXIT
 ENDC
 ENDM
ENABLE MACRO
 IFC '\1',''
 SUBQ.B #1,IDNestCnt(A6)
 BGE.S ENABLE\@
 MOVE.W #$0C000,_intena
ENABLE\@
 MEXIT
 ENDC
 IFC '\2','NOFETCH'
 SUBQ.B #1,IDNestCnt(\1)
 BGE.S ENABLE\@
 MOVE.W #$0C000,_intena
ENABLE\@
 MEXIT
 ENDC
 IFNC '\1',''
 MOVE.L 4,\1
 SUBQ.B #1,IDNestCnt(\1)
 BGE.S ENABLE\@
 MOVE.W #$0C000,_intena
ENABLE\@
 MEXIT
 ENDC
 ENDM
TASK_ABLES MACRO
 XREF _LVOPermit
 ENDM
FORBID MACRO
 IFC '\1',''
 ADDQ.B #1,TDNestCnt(A6)
 MEXIT
 ENDC
 IFC '\2','NOFETCH'
 ADDQ.B #1,TDNestCnt(\1)
 MEXIT
 ENDC
 IFNC '\1',''
 MOVE.L 4,\1
 ADDQ.B #1,TDNestCnt(\1)
 MEXIT
 ENDC
 ENDM
PERMIT MACRO
 IFC '\1',''
 JSR _LVOPermit(A6)
 MEXIT
 ENDC
 IFC '\2','NOFETCH'
 EXG.L A6,\1
 JSR _LVOPermit(A6)
 EXG.L A6,\1
 MEXIT
 ENDC
 IFNC '\1',''
 MOVE.L A6,-(SP)
 MOVE.L 4,A6
 JSR _LVOPermit(A6)
 MOVE.L (SP)+,A6
 MEXIT
 ENDC
 ENDM
UTILITYNAME MACRO
 DC.B 'utility.library',0
 ENDM
AUDIONAME MACRO
 DC.B 'audio.device',0
 ENDM
BBID_DOS MACRO
 dc.b 'DOS',0
 ENDM
BBID_KICK MACRO
 dc.b 'KICK'
 ENDM
M_ASM MACRO
 DC.B '>1'
 ENDM
M_AWM MACRO
 DC.B '?7'
 ENDM
PARALLELNAME MACRO
 dc.b 'parallel.device',0
 ds.w 0
 ENDM
SERIALNAME MACRO
 dc.b 'serial.device',0
 dc.w 0
 ENDM
TIMERNAME MACRO
 DC.B 'timer.device',0
 DS.W 0
 ENDM
TD_NAME MACRO
 DC.B 'trackdisk.device',0
 DS.W 0
 ENDM
DOSNAME MACRO
 DC.B 'dos.library',0
 ENDM
BPTR MACRO
 LONG \1
 ENDM
BSTR MACRO
 LONG \1
 ENDM
LIBENT MACRO
_LVO\1 EQU count
count SET count-vsize
 ENDM
InitAnimate MACRO
 CLR.L \1
 ENDM
RemBob MACRO
 OR.W #BF_BOBSAWAY,b_BobFlags+\1
 ENDM
GRAPHICSNAME MACRO
 DC.B 'graphics.library',0
 ENDM
OTSUFFIX MACRO
 dc.b '.otag',0
 ds.w 0
 ENDM
OTE_Bullet MACRO
 dc.b 'bullet',0
 ds.w 0
 ENDM
AslName MACRO
 DC.B 'asl.library',0
 ENDM
EXPANSIONNAME MACRO
 dc.b 'expansion.library',0
 ENDM
GTMENU_USERDATA MACRO
 move.l mu_SIZEOF(\1),\2
 ENDM
GTMENUITEM_USERDATA MACRO
 move.l mi_SIZEOF(\1),\2
 ENDM
MENU_USERDATA MACRO
 move.l mi_SIZEOF(\1),\2
 ENDM
SizeNVData MACRO
 move.l -4(/1),/2
 subq.l #4,/2
 ENDM
DATATYPESCLASS MACRO
 DC.B 'datatypesclass',0
 ENDM
PICTUREDTCLASS MACRO
 dc.b 'picture.datatype',0
 ENDM
SOUNDDTCLASS MACRO
 DC.B 'sound.datatype',0
 ENDM
ANIMATIONDTCLASS MACRO
 DC.B 'animation.datatype',0
 ENDM
BATTCLOCKNAME MACRO
 dc.b 'battclock.resource',0
 ds.w 0
 ENDM
BATTMEMNAME MACRO
 dc.b 'battmem.resource',0
 ds.w 0
 ENDM
CARDRESNAME MACRO
 dc.b 'card.resource',0
 ds.w 0
 ENDM
RESINIT MACRO
 IFC '\1',''
COUNT_RES SET RES_USERDEF
 ENDC
 IFNC '\1',''
COUNT_RES SET \1
 ENDC
 ENDM
RESDEF MACRO
\1 EQU COUNT_RES
COUNT_RES SET COUNT_RES-LIB_VECTSIZE
 ENDM
CIAANAME MACRO
 DC.B 'ciaa.resource',0
 ENDM
CIABNAME MACRO
 DC.B 'ciab.resource',0
 ENDM
DISKNAME MACRO
 DC.B 'disk.resource',0
 DS.W 0
 ENDM
FSRNAME MACRO
 dc.b 'FileSystem.resource',0
 ENDM
MISCNAME MACRO
 DC.B 'misc.resource',0
 CNOP 0,2
 ENDM
POTGONAME MACRO
 dc.b 'potgo.resource',0
 ds.w 0
 ENDM
RXSLIBNAME MACRO
 dc.b 'rexxsyslib.library',0
 ENDM
RXSDIR MACRO
 dc.b 'REXX',0
 ENDM
RXSTNAME MACRO
 dc.b 'ARexx',0
 ENDM
ICONNAME MACRO
 DC.B 'icon.library',0
 ENDM
WORKBENCH_NAME MACRO
 dc.b 'workbench.library',0
 ds.w 0
 ENDM
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
 dc.l \3
 ENDC
 IFLT NARG-3
 dc.l 0
 ENDC
 IFGE NARG-4
 dc.w \4
 ENDC
 IFLT NARG-4
 dc.w 0
 ENDC
 IFGE NARG-5
 dc.l \5,0
 ENDC
 IFLT NARG-5
 dc.l 0,0
 ENDC
 ENDM
TLDo: MACRO
 move.l a6,-(a7)
 move.l xxp_tanb(a4),a6
 jsr _LVOTL\1(a6)
 move.l (a7)+,a6
 ENDM
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
 IFEQ NARG-7
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
 IFNC '\3','0'
 IFNC '\3','1'
 move.l \3,a0
 TLDo Reqedit
 movem.l (a7)+,d1/a0
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 MEXIT
 ENDC
 ENDC
 movem.l a1/a5,-(a7)
 sub.w #100,a7
 move.l a7,a1
 move.l #xxp_xtext,(a1)+
 move.l a4,(a1)+
 IFC '\3','1'
 move.l #xxp_xstyl,(a1)+
 move.l xxp_FWork(a4),(a1)
 add.l #256,(a1)+
 move.l #xxp_xfont,(a1)+
 move.l xxp_AcWind(a4),a5
 clr.w (a1)+
 move.w xxp_Fnum(a5),(a1)+
 move.l #xxp_xcspc,(a1)+
 clr.w (a1)+
 move.w xxp_Tspc(a5),(a1)+
 ENDC
 move.l #xxp_xmaxc,(a1)+
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
 IFGE NARG-5
 IFNC '\5',''
 move.l #xxp_xmaxt,(a1)+
 move.l \5,(a1)+
 ENDC
 ENDC
 IFGE NARG-6
 IFNC '\6',''
 move.l #xxp_xmaxw,(a1)+
 move.l \6,(a1)+
 ENDC
 ENDC
 IFGE NARG-7
 IFNC '\7',''
 move.l #xxp_xmenu,(a1)+
 move.l \7,(a1)+
 ENDC
 ENDC
 IFGE NARG-8
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
 move.l #xxp_xiclr,(a1)+
 move.l #-1,(a1)+
 move.l #xxp_xtral,(a1)+
 move.l #-1,(a1)+
 move.l #xxp_xforb,(a1)+
 IFC '\3','0'
 move.l #xxp_xesty,(a1)+
 ENDC
 IFC '\3','1'
 clr.l (a1)+
 ENDC
 clr.l (a1)
 move.l a7,a0
 TLDo Reqedit
 add.w #100,a7
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
TLwindow0: MACRO
 TLwindow #-1
 TLwindow #0,#0,#0,#640,#100,xxp_Width(a4),xxp_Height(a4),#0,#st_1
 ENDM
TLscreen: MACRO
 movem.l d0-d1/a0-a1/a6,-(a7)
 sub.l #52,a7
 move.l a7,a0
 move.l #SA_Width,(a0)+
 move.l #STDSCREENWIDTH,(a0)+
 move.l #SA_Height,(a0)+
 move.l #STDSCREENHEIGHT,(a0)+
 move.l #SA_Depth,(a0)+
 move.l \1,(a0)+
 move.l #SA_Title,(a0)+
 move.l \2,(a0)+
 move.l #SA_Pens,(a0)+
 move.l \3,(a0)+
 move.l #SA_DisplayID,(a0)+
 IFEQ NARG-3
 move.l #HIRES_KEY,(a0)+
 ENDC
 IFEQ NARG-4
 move.l \4,(a0)+
 ENDC
 move.l #TAG_END,(a0)+
 move.l xxp_intb(a4),a6
 sub.l a0,a0
 move.l a7,a1
 jsr _LVOOpenScreenTagList(a6)
 clr.w xxp_Public(a4)
 add.l #52,a7
 move.l d0,xxp_Screen(a4)
 movem.l (a7)+,d0-d1/a0-a1/a6
 ENDM
TLattach: MACRO
 movem.l d0-d1/a0,-(a7)
 move.l \1,a0
 move.l a0,xxp_Mmem(a5)
 clr.b (a0)+
 move.l a0,xxp_Mtop(a5)
 subq.l #1,a0
 move.l \2,d0
 move.l d0,xxp_Mmsz(a5)
 add.l d0,a0
 clr.b -34(a0)
 clr.b -164(a0)
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
 eori.w #-1,CCR
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
