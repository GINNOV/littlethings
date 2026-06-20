BLINDOS	EQU	0	;0->distri
EABLINDOS	EQU	0	;0->distri
ATARI	EQU	0
AMIGA	EQU	1
_68000	equ	0	;0->version 68020 only
_68010	equ	1
_68020	equ	1
_68030	equ	1
_68040	equ	1
_CPU32	equ	1
VERSION	equ	$0100	;01.00
	IFEQ	_68000
	LIST
	opt	p=68020
	NOLIST
	ENDC
;	opt	o+,ow-;,o1-,w-
;  #[ Macros:
;
	IFNE	ATARI
ASCINL	MACRO
	dc.b	\1,13,10
	ENDM
ASCINLZ	MACRO
	dc.b	\1,13,10,0
	ENDM
	ENDC	;ATARI

	IFNE	AMIGA
ASCINL	MACRO
	dc.b	\1,10
	ENDM
ASCINLZ	MACRO
	dc.b	\1,10,0
	ENDM
	ENDC	;AMIGA
	

STRUCTINIT	MACRO
X		SET	0
		ENDM

SIZEOF		MACRO
\1		EQU	X
		ENDM

WORD_EVEN	MACRO
		IFNE	X-((X/2)*2)
X		SET	X+1
		ENDC
		ENDM

LONG_EVEN	MACRO
		WORD_EVEN
		IFNE	X-((X/4)*4)
X		SET	X+2
		ENDC
		ENDM

BYTE		MACRO
		IFNC	'\1',''
\1		EQU	X
		ENDC
		IFC	'\2',''
X		SET	X+1
		ELSEIF
X		SET	X+(\2)
		ENDC
		ENDM

WORD		MACRO
		IFNC	'\1',''
\1		EQU	X
		ENDC
		IFC	'\2',''
X		SET	X+2
		ELSEIF
X		SET	X+(2*(\2))
		ENDC
		ENDM

LONG		MACRO
		IFNC	'\1',''
\1		EQU	X
		ENDC
		IFC	'\2',''
X		SET	X+4
		ELSEIF
X		SET	X+(4*(\2))
		ENDC
		ENDM

PTR		MACRO
		IFNC	'\1',''
\1		EQU	X
		ENDC
		IFC	'\2',''
X		SET	X+4
		ELSEIF
X		SET	X+(4*(\2))
		ENDC
		ENDM

_Debugger	MACRO
	trap	#0
	ENDM

CALL	MACRO
	jsr	_\1(a6)
	ENDM

_EXTB	MACRO
	IFNE	_68000
	ext.w	\1
	ext.l	\1
	ELSEIF
	extb	\1
	ENDC
	ENDM

_TAS	MACRO
	IFNE	ATARI
	tas	\1
	ENDC
	IFNE	AMIGA
	bset	#7,\1
	ENDC
	ENDM
;
;  #] Macros:
;	 #[ Equates divers:
	IFNE	AMIGA
DIRSEP	equ	'/'
PATHSZ	equ	256
	ENDC	;AMIGA
	IFNE	ATARI
DIRSEP	equ	'\'
PATHSZ	equ	256
	ENDC	;ATARI
;	 #] Equates divers:
;	 #[ Section equs:
SEC_off	EQU	-1
SEC_text	EQU	0
SEC_data	EQU	4
SEC_bss	EQU	8
SEC_org	EQU	12
;	 #] Section equs:
;	 #[ Numbers/Sizes:
BIN_block_size	EQU	16*1024	;=16384
EXP_BLOCK_NB	EQU	1000	;=30000
GLOBALS_PER_BLOCK	EQU	100	;= 7000
LOCALS_PER_BLOCK	EQU	50	;=  700
LOCPTR_PER_BLOCK	EQU	1000	;= 4000
DOUBLY_PER_BLOCK	EQU	10	;=   40
EQUS_PER_BLOCK	EQU	100	;= 1600
XREFS_PER_BLOCK	EQU	50	;=  700
MAX_MAC_ARGS	EQU	36	;=
;	 #] Numbers/Sizes:
;	 #[ Patch equs:
;si changement d'ordre, changer patch+flush
P_W911	equ 0	;ASL,ASR,LSL,LSR,ROXL,ROXR,ADDQ,SUBQ	warn if !(1<=x<=7)
P_EA1	equ 1*2	;ASL,ASR,LSL,LSR ea (#1,ea)	err if !(x==1)
P_BIT8	equ 2*2	;Bitopi ea
P_BIT32	equ 3*2	;Bitopi Dn
P_W07	equ 4*2	;MOVEQ	warn if !(-127<=x<=128)
P_W05	equ 5*2	;BF width	warn if !(1<=x<=32)
P_W610	equ 6*2	;BF offset	warn if !(0<=x<=31)
P_W02	equ 7*2	;BKPT #0~7	err if !(0<=x<=7)
P_L02	equ 8*2	;PTESTWR(fc),PFLUSH(fc)	err if !(0<=x<=7)
P_L1012	equ 9*2	;PTESTWR(level)	warn if !(0<=x<=7)
P_W03	equ 10*2	;TRAP #0~15	err if !(0<=x<=15)
P_L06	equ 11*2	;FMOVECR(romoffset)	warn if !(known)
P_K06	equ 12*2	;FMOVE(k-factor):	err if !(-64<=k<=63)
P_L57	equ 13*2	;PFLUSH
P_FTRAPW	equ 14*2	;FTRAPcc.w	warn if long (UNUSED)
P_FTRAPL	equ 15*2	;FTRAPcc.l	(UNUSED)
P_D8	equ 16*2	;d8(An,Xn),CALLM	err if !(-127<=x<=128)
P_D16	equ 17*2	;d16(An)
P_ABSB	equ 18*2	;MOVEccr
P_ABSW	equ 19*2	;abs.w,Bd.w,Od.w,TRAPccW
P_ABSL	equ 20*2	;abs.l,Bd.l,Od.l,TRAPccL
P_DCB	equ 21*2	;DC.B
P_DCW	equ 22*2	;DC.W,#i.b,#i.w,LINKW,STOP,MOVEsr,BCLR,BCHG,BSET
P_DCL	equ 23*2	;DC.L,#i.l,LINKL
P_D8PC	equ 24*2	;d8(PC,Xn)	err if !(-127<=x<=128)
P_D16PC	equ 25*2	;d16(PC)
P_DBCC	equ 26*2	;DBcc,FBCCW,PBCCW,FDBCC,PDBCC
P_BCCB	equ 27*2	;Bcc.B	err if (x==NULL)
P_BCCW	equ 28*2	;Bcc.W	(Opti->BCCB)
P_BCCL	equ 29*2	;Bcc.L	(Opti->BCCW,BCCB)
P_BDPCW	equ 30*2	;(bd.w,pc)+([bd.w,pc])
P_BDPCL	equ 31*2	;(bd.l,pc)+([bd.l,pc])
P_MAX	equ P_BDPCL

;(+MOVE16?)
;	 #] Patch equs:
;	 #[ Si equs:
BYTE_SIZE	equ	0
WORD_SIZE	equ	1
LONG_SIZE	equ	2
SINGLE_SIZE	equ	3
DOUBLE_SIZE	equ	4
EXTEND_SIZE	equ	5
PACKED_SIZE	equ	6
;	 #] Si equs:
;	 #[ Token equs:
TOKEND0	equ	0
TOKEND1	equ	1
TOKEND2	equ	2
TOKEND3	equ	3
TOKEND4	equ	4
TOKEND5	equ	5
TOKEND6	equ	6
TOKEND7	equ	7
TOKENA0	equ	8
TOKENA1	equ	9
TOKENA2	equ	10
TOKENA3	equ	11
TOKENA4	equ	12
TOKENA5	equ	13
TOKENA6	equ	14
TOKENA7	equ	15
TOKENB	equ	16
TOKENW	equ	17
TOKENL	equ	18
TOKENSC1	equ	19
TOKENSC2	equ	20
TOKENSC4	equ	21
TOKENSC8	equ	22
TOKENSR	equ	23
TOKENCCR	equ	24
TOKENUSP	equ	25

TOKENQUOTE	equ	26

TOKENPC	equ	29
TOKENZAN	equ	30
TOKENZPC	equ	31

LASTTOKEN	EQU	TOKENZPC

TOKENEOL	equ	$ff
;	 #] Token equs:
;	 #[ MA equs:
;EA_mode
	;modes simples (i.e. sans sous-modes)
;DNMODE		equ	0
AN_MODE		equ	1
ANINDIR_MODE	equ	2
ANPOST_MODE	equ	3
ANPRE_MODE	equ	4
D16AN_MODE	equ	5

	;mode 6 (4 sous-modes)
MEM_MODE 	equ	6
D8ANXN_MODE	equ	6
BDANXN_MODE	equ	6
BDAN_XNOD_MODE	equ	6
BDANXN_OD_MODE	equ	6

	;mode 7 (8 sous-modes)
PC_MODE		equ	7
D16PC_MODE	equ	7
D8PCXN_MODE	equ	7
BDPCXN_MODE	equ	7
BDPC_XNOD_MODE	equ	7
BDPCXN_OD_MODE	equ	7
ABS_MODE	equ	7
IMMEDIATE_MODE	equ	7
	;d'ou sous-types en registre (EA_an):
ABS_WORD_REG	equ	%000
ABS_LONG_REG	equ	%001
D16PC_REG	equ	%010
PCMEM_REG	equ	%011
D8PCXN_REG	equ	%011
BDPCXN_REG	equ	%011
BDPC_XNOD_REG	equ	%011
BDPCXN_OD_REG	equ	%011
IMMEDIATE_REG	equ	%100

	;d'ou sous-registres si mode6 ou si mode7 et an==%011
;EA_mode2
_BDZPCXN_MODE	equ	$ff	;ZPC (full mode)
_D8ANXN_MODE	equ	0	;An brief mode
_D8PCXN_MODE	equ	0	;PC brief mode
_BDANXN_MODE	equ	1	;An full mode
_BDPCXN_MODE	equ	1	;PC full mode

	;bdsize
BD0_SZ		equ	%01
BDW_SZ		equ	%10
BDL_SZ		equ	%11

	;odsize
ODNOMEM_SZ	equ	%00
OD0_SZ		equ	%01
ODW_SZ		equ	%10
ODL_SZ		equ	%11
ODPOST0_SZ	equ	%101
ODPOSTW_SZ	equ	%110
ODPOSTL_SZ	equ	%111

XNW_SZ		equ	0
XNL_SZ		equ	1

DN_EA	equ	0
AN_EA	equ	1
ANIND_EA	equ	2
ANPST_EA	equ	3
ANPRE_EA	equ	4
AND16_EA	equ	5
ANMEM_EA	equ	6
PCD8_EA	equ	7
PCD16_EA	equ	8
PCMEM_EA	equ	9
ABS_EA	equ	10
IMM_EA	equ	11
;	 #] MA equs:
;	 #[ Eval equs:
EVAL_OPTI		equ	5
EVAL_RELOC	equ	4
EVAL_LOCGLO	equ	3
EVAL_LOC		equ	2
EVAL_GLO		equ	1
EVAL_NOERR	equ	0
EVAL_EQUR		equ	-1
EVAL_SYNTAX	equ	-2
EVAL_DIV0		equ	-3
EVAL_LSTR		equ	-4
EVAL_LNUM		equ	-5
EVAL_NOREL	equ	-6
EVAL_NFVAR	equ	-7
EVAL_OPERR	equ	-8
EVAL_MEM		equ	-9
EVAL_BOPEXP	equ	-10
EVAL_BOPUNEXP	equ	-11
EVAL_EOE		equ	-12
EVAL_MATCH	equ	-13
EVAL_PARUNEXP	equ	-14
EVAL_MUSTEVAL	equ	-15
EVAL_FW_SET	equ	-16
EVAL_OVERFLOW	equ	-17
EVAL_NEGSFT	equ	-18
EVAL_COMPEQUR	equ	-19
EVAL_ILLRADIX	equ	-20
EVAL_TYPE		equ	-21
EVAL_ILLOP	equ	-22
EVAL_ILLCR	equ	-23
EVAL_NFFUNC	equ	-24
EVAL_NBARGS	equ	-25
;	 #] Eval equs:
;	 #[ Debug equs:
DBG_NONE	equ	0	;=d-/x-
DBG_DRI	equ	1	;=d+
DBG_EXT	equ	2	;=x+
;	 #] Debug equs:
;	 #[ Src equs:
SRC_NONE	equ	0	;=y-
SRC_REL	equ	1	;=y0
SRC_ABS	equ	2	;=y1
;	 #] Src equs:
;	 #[ Link equs:
PRG_OBJ	equ	0	;=l0
PURE_OBJ	equ	1	;=l1
DRI_OBJ	equ	2	;=l2
BSD_OBJ	equ	3	;=l3
;	 #] Link equs:
;	 #[ Error equs:
error_error_errno		equ	0

illchar_lt32_errno		equ	-1	;Syntax analyser
illchar_gt127_errno		equ	-2
illchar_opcode_errno	equ	-3
illchar_label_errno		equ	-4
unbal_quote_errno 		equ	-5
unbal_parent_errno		equ	-6
unbal_bracket_errno		equ	-7
unexp_eosrc_errno		equ	-8
;-9

opnf_errno		equ	-10	;Instruction finder
opsz_forb_errno		equ	-11

oper_exp_errno		equ	-15	;Operandes matching
oper_2many_errno		equ	-16
startq_exp_errno		equ	-17
endq_exp_errno		equ	-18

sz_exp_errno		equ	-20	;Ea builder
sc_exp_errno		equ	-21
sz_sc_exp_errno		equ	-22
cant_input_errno		equ	-23
an_exp_errno 		equ	-24
dn_forb_errno		equ	-25
b_forb_errno		equ	-26
opar_exp_errno		equ	-27
comma_2many_errno		equ	-28
xn_exp_errno 		equ	-29

sz_ge_b_errno		equ	-30
sz_ge_w_errno		equ	-31
d16_ge_errno		equ	-32
d8_ge_errno		equ	-33
sc_forb_errno		equ	-34
xn_2many_errno		equ	-35
dn_or_pre_exp_errno		equ	-36
dn_exp_errno		equ	-37
eoo_exp_errno		equ	-38
min_exp_errno		equ	-39

sz_forb_errno		equ	-40
an_forb_errno		equ	-41
anindir_forb_errno		equ	-42
anpost_forb_errno		equ	-43
anpre_forb_errno		equ	-44
d16An_forb_errno		equ	-45
d8An_forb_errno		equ	-46
full_forb_errno		equ	-47
d16pc_forb_errno		equ	-48
d8pc_forb_errno		equ	-49

absw_forb_errno		equ	-50
absl_forb_errno		equ	-51
imm_forb_errno		equ	-52
ea_forb_errno		equ	-53
i_exp_errno		equ	-54
q_exp_errno		equ	-55
shift_ge_8_errno		equ	-56
w_exp_errno		equ	-57
bitge64_errno		equ	-58
bkptge8_errno		equ	-59

semi_exp_errno		equ	-60
brace_exp_errno		equ	-61
offset_ge_32_errno		equ	-62
width_ge_32_errno		equ	-63
plus_exp_errno		equ	-64
trap_gt_15_errno		equ	-65
cr_exp_errno		equ	-66
reglist_exp_errno		equ	-67
d16_exp_errno		equ	-68
x_exp_errno		equ	-69
fp_exp_errno		equ	-70
reg_twice_errno		equ	-71
dn_or_sep_exp_errno		equ	-72
bad_reglist_errno		equ	-73
fpu_dn_sz_forb_errno	equ	-74
fpcr_exp_errno		equ	-75
fpu_fp_sz_forb_errno	equ	-76
kfactor_ge_errno		equ	-77
pfc_exp_errno		equ	-78
pfc_ge_7_errno		equ	-79
mmusr_forb_errno		equ	-80
cline_exp_errno		equ	-81
shift_ea_1_errno		equ	-82
comma_exp_errno		equ	-83
cpar_exp_errno		equ	-84
pn_exp_errno 		equ	-85
quote_exp_errno		equ	-86

pcb_not_reached_errno	equ	-87	;PC-relatives EA
pcw_not_reached_errno	equ	-88
zbccb_forb_errno		equ	-89

bad_mpu_errno		equ	-90	;messages internes
not_imp_errno		equ	-91
;				-92
eval_d16_errno		equ	-93
eval_d8_errno		equ	-94
eval_abs_errno		equ	-95
eval_immed_errno		equ	-96
eval_pc_errno		equ	-97
eval_bd_errno		equ	-98
eval_od_errno		equ	-99

eval_errno		equ	-100	;evaluator
;eval_equr_errno		equ	-100
;eval_syntax_errno		equ	-101
;eval_div0_errno		equ	-102
;eval_lstr_errno		equ	-103
;eval_lnb_errno		equ	-104
;eval_estr_errno		equ	-105
rel_forb_errno		equ	-106	;erreur d'eval et generale
;eval_forb_errno		equ	-107
;eval_rel_errno		equ	-108
;eval_mem_errno		equ	-109

mac_endm_exp_errno		equ	-130	;macros
mac_endm_unexp_errno	equ	-131
mac_exitm_unexp_errno	equ	-132
mac_shiftm_unexp_errno	equ	-133
mac_2many_decl_errno	equ	-134
mac_2many_calls_errno	equ	-135
mac_inv_par_errno		equ	-136
mac_enclos_errno		equ	-137
mac_sup_unbal_errno		equ	-138
mac_eqnf_errno		equ	-139
mac_opcode_errno		equ	-140

rept_endr_exp_errno		equ	-141	;repeat
rept_endr_unexp_errno	equ	-142
rept_neg_errno		equ	-143
force_even_errno		equ	-144
ifcc_endif_exp_errno	equ	-145	;ifcc
ifcc_else_unexp_errno	equ	-146
ifcc_endif_unexp_errno	equ	-147
ifcc_garbage_errno		equ	-148
strc_end_unexp_errno	equ	-149

min_forb_errno		equ	-150	;miscellaneous
local_forb_errno		equ	-151
label_exp_errno		equ	-152
equr_reg_errno		equ	-153
fpiar_exp_errno		equ	-154
fpu_req_errno		equ	-155
p_exp_errno		equ	-156
foff_2big_errno		equ	-157

file_exp_errno		equ	-160	;include
load_include_errno		equ	-161
fail_errno		equ	-162
var_2many_errno		equ	-163
super_forb_errno		equ	-164
rel_oos_sec_errno		equ	-165	;AMIGA
org_forb_errno		equ	-166
link_misp_errno		equ	-167
link_rest_errno		equ	-168
data_in_bss_errno		equ	-169	;dc/ds

mc10_forb_errno		equ	-170	;MPUs
mc20_forb_errno		equ	-171
mc30_forb_errno		equ	-172
mc40_forb_errno		equ	-173
mc60_forb_errno		equ	-174
mc32_forb_errno		equ	-175
mmu_forb_errno		equ	-176
fpu_forb_errno		equ	-177
ea20_forb_errno		equ	-178
mccr_forb_errno		equ	-179

mdefany_errno		equ	-180	;MDEFs
mdefequ_errno		equ	-181
mdefset_errno		equ	-182
mdefmac_errno		equ	-183
xdef_undef_errno		equ	-184

sec_name_errno		equ	-185	;SECs
sec_start_errno		equ	-186
sec_2many_errno		equ	-187
sec_difftypes_errno		equ	-188
;			equ	-189

create_errno		equ	-190	;disk
open_errno		equ	-191
read_errno		equ	-192
write_errno		equ	-193
seek_errno		equ	-194
close_errno		equ	-195
setpath_errno		equ	-196
setdrive_errno		equ	-197
getpath_errno		equ	-198
getdrive_errno		equ	-199

varram_errno		equ	-200	;ram
fileram_errno		equ	-201
expram_errno		equ	-202
macram_errno		equ	-203
ifccram_errno		equ	-204
reptram_errno		equ	-205
memram_errno		equ	-206
modram_errno		equ	-207
dbgram_errno		equ	-208
binram_errno		equ	-209

FAT_ERRNO			equ	190
MAX_ERRNO			equ	209

;	 #] Error equs:
;	 #[ Warning equs:
zd162indir_warnno		equ	-1
labs2w_warnno		equ	-2
bd2d8_warnno		equ	-3
bd2w_warnno		equ	-4
bd2z_warnno		equ	-5
od2w_warnno		equ	-6
od2z_warnno		equ	-7
ld162lbd_warnno		equ	-8

zbccb2nop_warnno		equ	-10
bwbcc2b_warnno		equ	-11
bwbcc2l_warnno		equ	-12
fwbcc2b_warnno		equ	-13
fwbcc2w_warnno		equ	-14
move2q_warnno		equ	-15
move2clr_warnno		equ	-16
moveal2w_warnno		equ	-17
movea2sub_warnno		equ	-18
ari2q_warnno		equ	-19
ari2lea_warnno		equ	-20
lea2q_warnno		equ	-21
cmp2tst_warnno		equ	-22
lsl2add_warnno		equ	-23
roxl2addx_warnno		equ	-24

comment_spur_warnno		equ	-30
empty_reglist_warnno	equ	-31
oddsp_warnno		equ	-32
bitmod8_warnno		equ	-33
bitmod32_warnno		equ	-34
mq_ext_warnno		equ	-35
fpu_soft_warnno		equ	-36
fpusz_soft_warnno		equ	-37
ec_forb_warnno		equ	-38
xref_spur_warnno		equ	-39
xdef_spur_warnno		equ	-40
xref_unused_warnno		equ	-41
oddbranch_warnno		equ	-42
oddaddr_warnno		equ	-43
mpu_decl_warnno		equ	-44
mmu_decl_warnno		equ	-45
fpu_decl_warnno		equ	-46

MAX_WARNNO		equ	44
OPTI_NB			equ	17

;	 #] Warning equs:
;	 #[ Optable equs:
FUNC_PREPR	equ	0
FUNC_68000	equ	1
FUNC_68010	equ	2
FUNC_68020	equ	4
FUNC_68030	equ	8
FUNC_68040	equ	$10
FUNC_68881	equ	$20
FUNC_68851	equ	$40
FUNC_CPU32	equ	$80
FUNC_68EC0	equ	0
_FUNC_68000	equ	0
_FUNC_68010	equ	1
_FUNC_68020	equ	2
_FUNC_68030	equ	3
_FUNC_68040	equ	4
_FUNC_68881	equ	5
_FUNC_68851	equ	6
_FUNC_CPU32	equ	7

FUNC_NOFLAGS	equ	0
FUNC_VAR		equ	1
FUNC_NOOPER	equ	2
FUNC_SUPER	equ	4
_FUNC_VAR		equ	0
_FUNC_NOOPER	equ	1
_FUNC_SUPER	equ	2
;	 #] Optable equs:
;	 #[ MCU equs:

MPU_00	equ	0
MPU_10	equ	1
MPU_32	equ	2
MPU_20	equ	3
MPU_30	equ	4
MPU_40	equ	5
MPU_60	equ	6

MMU_NO	equ	0
MMU_51	equ	1
MMU_30	equ	2
MMU_40	equ	3
MMU_EC	equ	4
MMU_60	equ	5

FPU_NO	equ	0
FPU_81	equ	1
FPU_40	equ	2
FPU_LC	equ	3
FPU_60	equ	4

;	 #] MCU equs:
;	 #[ Ref struct: in tablexxs
	STRUCTINIT
	LONG	REF_opcode	;L intruction opcode
	LONG	REF_left		;L left ea
	LONG	REF_right		;L right ea
	WORD	REF_rout		;W offset routine
	BYTE	REF_flags		;B super
	BYTE	REF_procs		;B allowed procs
	SIZEOF	REF_SIZEOF	;16
;	 #] Ref struct:
;	 #[ Bin struct: binary buffer
	STRUCTINIT		;block binaire avant/arriere
	PTR	BIN_start		;@ debut du block binaire/NULL if INCBIN
	PTR	BIN_size,0	;L size for INCBIN (if size->W) \
	PTR	BIN_cur		;@ courante		  /
	PTR	BIN_name,0	;@ fname for INCBIN		  \
	PTR	BIN_end		;@ fin			  /
	LONG	BIN_off		;L cursection cursize
	WORD	BIN_sec		;W binary section (text/data)
	PTR	BIN_next		;@ next
	PTR	BIN_prev		;@ prev (utilise pr incbin)
	SIZEOF	BIN_SIZEOF	;12
;	 #] Bin struct:
;	 #[ EA struct: effective address
	STRUCTINIT		;EA
	LONG	EA_f,0		;id ci-dessous en long
	BYTE	EA_an		;B Pn or Dn reg
	BYTE	EA_xn		;B Xn reg
	BYTE	EA_mode		;B major mode (0-7)
	BYTE	EA_mode2		;B minor mode
	BYTE	EA_xnsz		;B Xn size
	BYTE	EA_xnsc		;B Xn scale
	BYTE	EA_bdsz		;B Bd size
	BYTE	EA_odsz		;B Od size
	LONG	EA_value		;L Imm/D8/D16/Bd value
	LONG	EA_vtype		;L value type (EXP)
	LONG	EA_odsrc,0	;@ start od (token)
	LONG	EA_odvalue	;L Od value
	LONG	EA_odvtype	;L value type (EXP)
	SIZEOF	EA_SIZEOF		;24
;	 #] EA struct:
;	 #[ Mod struct: module
	STRUCTINIT		;MOD	;module avant/arriere
	PTR	MOD_addr		;@ buffer
	PTR	MOD_orgnam	;@ original name
	PTR	MOD_expnam	;@ expanded name
	PTR	MOD_prev		;@ prev
	PTR	MOD_next		;@ next
	PTR	MOD_cursrc	;@ current src
	LONG	MOD_curlnb	;L current line #
	LONG	MOD_incnum	;L current incnum
	PTR	MOD_father	;@ loader module (pour include)
	LONG	MOD_num		;L module #
	LONG	MOD_curoffs	;L mode slow
	LONG	MOD_size		;L taille totale du fichier
	PTR	MOD_headed
	PTR	MOD_cured
	PTR	MOD_nextram
	SIZEOF	MOD_SIZEOF	;36+8
;	 #] Mod struct:
;	 #[ PMod struct:
	STRUCTINIT		;MOD	;module avant/arriere
	LONG	PMOD_time		;L timestamp
	LONG	PMOD_name		;L nameoffset
	SIZEOF	PMOD_SIZEOF	;8
;	 #] PMod struct:
;	 #[ Linr struct: line record
	STRUCTINIT		;LINR line record avant
	LONG	LINR_mod		;L mod # / mod offset
	LONG	LINR_addr		;L code offset
	LONG	LINR_size		;L code size
	LONG	LINR_base		;L start line #
	LONG	LINR_count	;L lines # in record
	PTR	LINR_first	;@ first linn struct
	LONG	LINR_curaddr	;L current code offset
	LONG	LINR_curbase	;L current base offset
	PTR	LINR_var		;@ var
	WORD	LINR_sec		;W section #
	PTR	LINR_next		;@ next
	SIZEOF	LINR_SIZEOF	;36
;	 #] Linr struct:
;	 #[ Line number struct:
	STRUCTINIT		;LINN line number avant
	BYTE	LINN_inc		;B src line increment
	BYTE	LINN_off		;B code offset
	PTR	LINN_next		;@ next
	SIZEOF	LINN_SIZEOF	;6
;	 #] Line number struct:
;	 #[ Var struct:
VAR_GLOB	equ	4	;0
VAR_XREF	equ	5	;1
VAR_XDEF	equ	6	;2
VAR_LOC	equ	7	;3

EQU_EQU	equ	0		;laisser 0
EQU_SET	equ	1
EQU_EQUR	equ	2
EQU_REG	equ	3

EQU_GLOB	equ	4		;=EQU_GLOB+VAR_GLOB
EQU_XREF	equ	5		;=EQU_GLOB+VAR_XREF
EQU_XDEF	equ	6		;=EQU_GLOB+VAR_XDEF
EQU_LOC	equ	7		;=EQU_GLOB+VAR_LOC

EQU_FEQU	equ	8
EQU_FSET	equ	9
EQU_FEQUR	equ	10
EQU_FREG	equ	11

EQU_MACRO	equ	12

VAR_DEFED	equ	6		;bit 6 of TYPE is DEFINED
VAR_MINUS	equ	7		;bit 7 of TYPE is MINUS

	STRUCTINIT		;equate list avant
	PTR	EQUL_next		;@ next
	WORD	EQUL_nb		;W nb d'equs ds ce bloc
	PTR	EQUL_block	;@ du bloc
	SIZEOF	EQUL_SIZEOF	;10

	STRUCTINIT		;var list avant
	PTR	VARL_next		;@ next
	WORD	VARL_nb		;W nb de vars ds ce bloc
	PTR	VARL_block	;@ du bloc
	SIZEOF	VARL_SIZEOF	;10

	STRUCTINIT		;variable, stockage en tableau ds globals_ptr
	LONG	VAR_start		;@ addresse de la variable en memoire
	WORD	VAR_len		;W longueur de la var
	LONG	VAR_ptrmac,0	;@ struct macro
	LONG	VAR_value		;L valeur de la var
	BYTE	VAR_type		;B type de var
	BYTE	VAR_sec		;B # section de la var
	WORD	VAR_mod		;W # module contenant la var (0:internal)
	LONG	VAR_nb,0		;L # de la var
	LONG	VAR_lnb		;L # ligne ds le module
	SIZEOF	VAR_SIZEOF	;18

;	 #] Var struct:
;	 #[ Prep structs:
	STRUCTINIT		;Rept/Endr arriere
	PTR	REPT_backptr	;@ struct precedente
	LONG	REPT_count	;L compteur
	LONG	REPT_value	;L compteur initial
	PTR	REPT_srcaddr	;@ src derriere REPT
	PTR	REPT_macsrc	;@ src derriere macro REPTant sans ENDR
	PTR	REPT_mod		;@ module debut REPT
	LONG	REPT_incnum	;L incrementation ligne debut REPT
	LONG	REPT_lnb		;L Ligne # debut REPT
	PTR	REPT_decladdr	;@ src sur la ligne de REPT
	PTR	REPT_edblock	;@ struct editeur
	SIZEOF	REPT_SIZEOF	;36

;Ifcc/Elseif/Endc
;Ifcc Types
IFNE_TYPE		EQU	0
IFEQ_TYPE		EQU	1
IFC_TYPE		EQU	2
IFNC_TYPE		EQU	3
IFND_TYPE		EQU	4
IFD_TYPE		EQU	5
IFGT_TYPE		EQU	6
IFGE_TYPE		EQU	7
IFLE_TYPE		EQU	8
IFLT_TYPE		EQU	9
	STRUCTINIT
	PTR	IFCC_backptr	;@ prev
	PTR	IFCC_srcaddr	;@ src
	PTR	IFCC_mod		;@ mod
	LONG	IFCC_lnb		;L line #
	BYTE	IFCC_type		;B IFcc type
	BYTE	IFCC_result	;B boolean result
	WORD	IFCC_canteval	;W not taken flag
	SIZEOF	IFCC_SIZEOF	;20
	
	STRUCTINIT		;pareil que MACBUF
	PTR	IFCCBUF_next
	PTR	IFCCBUF_prev
	WORD	IFCCBUF_nb
	PTR	IFCCBUF_cur
	SIZEOF	IFCCBUF_SIZEOF
	
;	 #] Prep structs:
;	 #[ Macro structs:
	STRUCTINIT
	PTR	MAC_srcstart	;@ debut texte macro
	PTR	MAC_modstart	;@ module de depart macro
	LONG	MAC_linestart	;L nb de lignes de la macro
	PTR	MAC_curline	;@ decl macro
	LONG	MAC_incline	;L incrementation entre declaration et code
	PTR	MAC_edblock	;@ struct editeur
	SIZEOF	MAC_SIZEOF	;24

	STRUCTINIT		;arriere
	PTR	MACCTXT_cur
	PTR	MACCTXT_curexp
	WORD	MACCTXT_nbargs
	WORD	MACCTXT_argshift
	LONG	MACCTXT_lnb	;L num de ligne derriere l'appel macro
	LONG	MACCTXT_incnum	;L incrementation de ligne derriere l'appel macro
	PTR	MACCTXT_lptr	;@ src de la ligne d'appel
	PTR	MACCTXT_backsrc	;@ src derriere l'appel macro
	PTR	MACCTXT_curbuf	;@ buffer courant d'expansion
	PTR	MACCTXT_mod	;@ module derriere l'appel macro
	WORD	MACCTXT_rept	;W ReptNestCnt a l'appel
	WORD	MACCTXT_ifcc	;W IfccNestCnt a l'appel
	PTR	MACCTXT_edblock	;@ struct editeur
	WORD	MACCTXT_aroused	;W boolean \@ used
	LONG	MACCTXT_arocnt	;L compteur \@ local
	PTR	MACCTXT_prev	;@ contexte precedent
	SIZEOF	MACCTXT_SIZEOF	;36

	STRUCTINIT
	PTR	MACBUF_next
	PTR	MACBUF_prev
	WORD	MACBUF_nb
	PTR	MACBUF_cur
	SIZEOF	MACBUF_SIZEOF

	STRUCTINIT
	WORD	MacNestCnt
	LONG	GloMacAroCnt
	LONG	LocMacAroCnt
	PTR	MacNARGptr
	WORD	MacCallSize
	PTR	MacBufCur
	PTR	MacMemCur
	PTR	MacMemHead
	PTR	CurMacSrcList	;relie les bouts de mac src en SlowMode
	PTR	HeadMacSrcList
	WORD	MacIfccCnt
	WORD	MacLineSize
	WORD	MacNbArgs
	WORD	MacShift		;valeur courante de MSHIFT
	PTR	MacCurPtr		;@ struct EQU-MAC en cours d'expansion
	PTR	MacCurExpPtr	;@ ligne src en cours d'expansion
	PTR	MacCurBufPtr
	PTR	MacStackPtr
	BYTE	MacAroUsedFlg
	BYTE	InMacFlg
	PTR	MacCurDecl	;@ macro en cours de declaration
	PTR	MacMemCtxtCur	;surcouche mem
	SIZEOF	MAC_STUFF_SIZEOF
;	 #] Macro structs:
;	 #[ Line struct:
	STRUCTINIT		;tokenized line
	BYTE	LINE_field,256	;field
	PTR	LINE_btokend	;@ bracket end (token)
	PTR	LINE_tokend	;@ line end (token)
	PTR	LINE_srcstart	;@ line start (source)
	PTR	LINE_srccomma	;@ od start (source) used twice
	WORD	LINE_par0nb	;W level 0 parent #
	WORD	LINE_parnb	;W parent comma #
	WORD	LINE_branb	;W bracket comma #
	WORD	LINE_eval		;W !=0 => operateur arithmetique present
	SIZEOF	LINE_SIZEOF	;256+24

LINEBUF_SIZE	EQU	LINE_SIZEOF*127
;doit etre mult de long, au moins 256, aligne
FLSHBUF_SIZE	EQU	LINEBUF_SIZE
;	 #] Line struct:
;	 #[ Eval structs:
	STRUCTINIT
	BYTE	FS_len
	BYTE	FS_nargs
	WORD	FS_name
	PTR	FS_fonc
	PTR	FS_ev_fonc
	SIZEOF	FS_SIZEOF
;	 #] Eval structs:
;	 #[ Field equs:
SETEOL	MACRO
	st	\1			;;TOKENEOL
	ENDM

REFPTR	EQUR	a2

INCREF	MACRO
	lea	REF_SIZEOF(REFPTR),REFPTR
	ENDM
INC2REF	MACRO
	lea	REF_SIZEOF*2(REFPTR),REFPTR
	ENDM
INC3REF	MACRO
	lea	REF_SIZEOF*3(REFPTR),REFPTR
	ENDM

FIELDPTR	EQUR	a3

FIELDNEXT	EQU	LINE_SIZEOF
FIELDPREV	EQU	-LINE_SIZEOF

INCFIELD	MACRO
	lea	FIELDNEXT(FIELDPTR),FIELDPTR
	ENDM
DECFIELD	MACRO
	lea	FIELDPREV(FIELDPTR),FIELDPTR
	ENDM
INC2FIELD	MACRO
	lea	FIELDNEXT*2(FIELDPTR),FIELDPTR
	ENDM
DEC2FIELD	MACRO
	lea	FIELDPREV*2(FIELDPTR),FIELDPTR
	ENDM

EAPTR	EQUR	a4

EANEXT	EQU	EA_SIZEOF
EAPREV	EQU	-EA_SIZEOF

INCEA	MACRO
	lea	EANEXT(EAPTR),EAPTR
	ENDM
DECEA	MACRO
	lea	EAPREV(EAPTR),EAPTR
	ENDM

NEVAL	MACRO
	move.w	LINE_eval(FIELDPTR),d0
	bsr	Evaluate
	ENDM	;;NEVAL

JNEVAL	MACRO
	move.w	LINE_eval(FIELDPTR),d0
	jsr	Evaluate
	ENDM	;;NEVAL

FEVAL	MACRO
	move.w	LINE_eval(FIELDPTR),d0
	bsr	ForEval
	ENDM	;;FEVAL

JFEVAL	MACRO
	move.w	LINE_eval(FIELDPTR),d0
	jsr	ForEval
	ENDM	;;FEVAL

OEVAL	MACRO
	move.w	LINE_eval(FIELDPTR),d0
	bsr	OptEval
	ENDM	;;OEVAL

JOEVAL	MACRO
	move.w	LINE_eval(FIELDPTR),d0
	jsr	OptEval
	ENDM	;;OEVAL

EAEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_value(EAPTR)	;;MA_vtype
	ENDM	;;EAEVAL

JEAEVAL	MACRO
	JNEVAL
	movem.l	d0-d1,EA_value(EAPTR)	;;MA_vtype
	ENDM	;;EAEVAL

EABEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_value(EAPTR)	;;MA_vtype
	ENDM	;;EAEVAL

EAWEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_value(EAPTR)	;;MA_vtype
	ENDM	;;EAEVAL

EALEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_value(EAPTR)	;;MA_vtype
	ENDM	;;EAEVAL

EAODEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_odvalue(EAPTR)	;;MA_odtype
	ENDM	;;EAODEVAL

EAODWEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_odvalue(EAPTR)	;;MA_odtype
	ENDM	;;EAODEVAL

EAODLEVAL	MACRO
	NEVAL
	movem.l	d0-d1,EA_odvalue(EAPTR)	;;MA_odtype
	ENDM	;;EAODEVAL

;	 #] Field equs:
;	 #[ Exp struct:
	STRUCTINIT		;Stockage des expr non resolues
	LONG	EXP_start		;L offset expression (source)
	WORD	EXP_mod		;W MOD#
	BYTE	EXP_sec		;B section referencee par l'exp
	BYTE	EXP_len		;B expression length
	WORD	EXP_patch		;W backpatching type
	WORD	EXP_bin		;W BIN#
	WORD	EXP_poke		;W binary offset
	PTR	EXP_backval	;@ local & set values
	BYTE	EXP_eval,0	;B expression is complex
	LONG	EXP_varnb,0	;L inside var # for xref and reloc
	LONG	EXP_lnb		;L line #
	LONG	EXP_PC		;L cursection cursize
	WORD	EXP_secnum	;W section ou l'exp est declaree
	SIZEOF	EXP_SIZEOF	;30
	PTR	EXP_dupliq	;@ global ghost
	SIZEOF	EXP_LOC_SIZEOF	;34
;	 #] Exp struct:
;	 #[ Head Exp struct:
	STRUCTINIT		;Headers des expr non resolues avant/arriere
	PTR	HEAD_prev		;@ prev
	PTR	HEAD_next		;@ next
	PTR	HEAD_start	;@ debut des donnees du bloc associe
	PTR	HEAD_current	;@ courante des donnees du bloc associe
	PTR	HEAD_end		;@ de fin des donnees du bloc associe
	WORD	HEAD_nb		;W EXP # in HEAD
	SIZEOF	HEAD_SIZEOF	;24
;	 #] Head Exp struct:
;	 #[ Mem Block struct:
	STRUCTINIT
	PTR	MEMBLOCK_cur
	PTR	MEMBLOCK_end
	PTR	MEMBLOCK_next
	PTR	MEMBLOCK_prev
	WORD	MEMBLOCK_nb
	SIZEOF	MEMBLOCK_SIZEOF	;18
;	 #] Mem Block struct:
;	 #[ Text struct:
	STRUCTINIT
	PTR	TXT_text
	PTR	TXT_next
	PTR	TXT_prev
	LONG	TXT_lnb
	LONG	TXT_size
	LONG	TXT_asz
	SIZEOF	TXT_SIZEOF
;	 #] Text struct:
;	 #[ IEnv struct:
	STRUCTINIT
	PTR	IENV_print	;print string
	PTR	IENV_outmsg	;out message
	PTR	IENV_idle		;idle
	PTR	IENV_alloc	;malloc
	PTR	IENV_mod		;first module
	SIZEOF	IENV_SIZEOF
;	 #] IEnv struct:
;	 #[ Msg struct:
MSG_WARN	equ	1
MSG_OPTI	equ	2
MSG_EVAL	equ	4
MSG_CORR	equ	8
MSG_FATL	equ	16

	STRUCTINIT
	WORD	MSG_flags		;flags
	WORD	MSG_no		;errno
	WORD	MSG_ev		;eval errno
	BYTE	MSG_len		;chars len
	BYTE	MSG_off		;char offset
	LONG	MSG_lnb		;line nb
	PTR	MSG_mod		;module (MOD *)
	PTR	MSG_txt		;txt in module (TXT *)
	PTR	MSG_msg1		;msg text (char *)
	PTR	MSG_msg2		;msg text (char *)
	PTR	MSG_ln		;line in txt (char *)
	SIZEOF	MSG_SIZEOF
;	 #] Msg struct:
;	 #[ Pref struct:
	STRUCTINIT
	WORD	PREF_dbg0
	WORD	PREF_dbg1
	WORD	PREF_dbg2
	WORD	PREF_dbg3
	WORD	PREF_case
	WORD	PREF_ldot
	WORD	PREF_warn
	WORD	PREF_wopt
	WORD	PREF_verb
	WORD	PREF_chck
	WORD	PREF_slow
	WORD	PREF_smem
	WORD	PREF_equf
	WORD	PREF_lsym
	WORD	PREF_lmac
	WORD	PREF_corr
	WORD	PREF_supr
	WORD	PREF_inde
	WORD	PREF_mpu
	WORD	PREF_mmu
	WORD	PREF_fpu
	BYTE	PREF_fpuid
	BYTE	PREF_fpucr
	WORD	PREF_fpuk
	WORD	PREF_aro
	WORD	PREF_lnk
	WORD	PREF_lcnt
	WORD	PREF_ltab
	WORD	PREF_llen
	WORD	PREF_plen
	BYTE	PREF_mttl,256
	BYTE	PREF_sttl,256
	BYTE	PREF_outp,PATHSZ
	BYTE	PREF_incd,PATHSZ
	BYTE	PREF_def,256
	SIZEOF	PREF_SIZEOF
;	 #] Pref struct:
;	 #[ Opti struct:
	STRUCTINIT
	WORD	OPTI_bbcc
	WORD	OPTI_zd16
	WORD	OPTI_labs2w
	WORD	OPTI_move2q
	WORD	OPTI_ari2q
	WORD	OPTI_fbcc
	WORD	OPTI_nop
	WORD	OPTI_bd
	WORD	OPTI_od
	WORD	OPTI_adda2lea
	WORD	OPTI_lea2q
	WORD	OPTI_moveal2w
	WORD	OPTI_movea2sub
	WORD	OPTI_ld162lbd
	SIZEOF	OPTI_SIZEOF
;	 #] Opti struct:
;	 #[ IAsm struct:
	STRUCTINIT
	PTR	IASM_pref		;preferences
	PTR	IASM_msg		;messages table
	SIZEOF	IASM_SIZEOF
;	 #] IAsm struct:
;	 #[ Path struct:
	STRUCTINIT
	PTR	PATH_next
	BYTE	PATH_str,0
	SIZEOF	PATH_SIZEOF
;	 #] Path struct:
;	 #[ Macros diverses:
TSTEOL	MACRO
	tst.l	\1
	bpl\0	\2
	ENDM

STRCPY	MACRO
.\@:	move.b	(a0)+,(a1)+
	bne.s	.\@
	ENDM

STRCCPY	MACRO
	moveq	#0,d0
.\@:	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.\@
	ENDM

STRNCPY	MACRO
	subq.w	#1,d0
	bmi.s	.\@end
.\@:	move.b	(a0)+,(a1)+
	dbeq	d0,.\@
.\@end:
	ENDM

STRLEN	MACRO
	moveq	#-1,d0	;;TSTEOL
.\@:	tst.b	(a0)+
	dbeq	d0,.\@
	not.l	d0
	ENDM

MSTRLEN	MACRO
	moveq	#-1,d0
	move.b	d0,d1
.\@:	tst.b	(a0)+
	dbmi	d0,.\@
	cmp.b	-1(a0),d1
	bne.s	.\@
	not.l	d0
	ENDM

PSTRCPY	MACRO
	movem.l	a0-a1,-(sp)
.\@:	move.b	(a0)+,(a1)+
	bne.s	.\@
	movem.l	(sp)+,a0-a1
	ENDM

PSTRCCPY	MACRO
	movem.l	a0-a1,-(sp)
	moveq	#0,d0
.\@:	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.\@
	movem.l	(sp)+,a0-a1
	ENDM

PSTRNCPY	MACRO
	movem.l	a0-a1,-(sp)
	subq.w	#1,d0
	bmi.s	.\@end
.\@:	move.b	(a0)+,(a1)+
	dbeq	d0,.\@
.\@end:	movem.l	(sp)+,a0-a1
	ENDM

PSTRLEN	MACRO
	move.l	a0,-(sp)
	moveq	#-1,d0	;;TSTEOL
.\@:	tst.b	(a0)+
	dbeq	d0,.\@
	not.l	d0
	move.l	(sp)+,a0
	ENDM

PMSTRLEN	MACRO
	movem.l	d1/a0,-(sp)
	moveq	#-1,d0
	move.b	d0,d1
.\@:	tst.b	(a0)+
	dbmi	d0,.\@
	cmp.b	-1(a0),d1
	bne.s	.\@
	not.l	d0
	movem.l	(sp)+,d1/a0
	ENDM

CASETAB	MACRO
.t:	dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
	dc.b	$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
	dc.b	$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,'.',$2f
	dc.b	'0','1','2','3','4','5','6','7','8','9',$3a,$3b,$3c,$3d,$3e,'?'
	dc.b	'@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
	dc.b	'P','Q','R','S','T','U','V','W','X','Y','Z',$5b,$5c,$5d,$5e,'_'
	dc.b	'`','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
	dc.b	'P','Q','R','S','T','U','V','W','X','Y','Z','{',$7c,'}',$7e,$7f
	even
	ENDM

;	 #] Macros diverses:

