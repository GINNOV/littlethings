;TOSPJPKPJPKAAAAGHGGAAAFPNJDAAAACHHPAAAGABPFAAAANGCGAAAFFLAFAAAFKIPHAAAANGCHAFOLMHFA
;---------------T-------T---------------T------------------------------------T

	IFND	GRStructures_I

GRStructures_I	set	1

;;----------------------------------------------------------------------------;
;---- Structure definitions --------------------------------------------------;
;-----------------------------------------------------------------------------;
	rsreset		;define structure used by disasseditor
de_lines	rs.w	1	;lines used by this command (inc break)
de_flags	rs.w	1	;flags (defined below)
de_address	rs.l	1	;address of command
de_source	rs.l	1	;source address \ Check flags for
de_dest	rs.l	1	;dest address   / valid entries
de_SizeOf	rs.b	0

de_SValid=	0		;flag if s/d is valid
de_DValid=	1
de_Break=	2		;if cmd have breakline
de_Double=	3		;if cmd takes up two lines

	rsreset		;define mnemonic structure
mn_Type	rs.w	1
mn_Name	rs.b	10
mn_Bits	rs.w	1
mn_Mask	rs.w	1
mn_SizeOf	rs.b	0

mn_FPUID=	mn_SizeOf	;additional data for FPU cmds
mn_FPUMask=	mn_FPUID+2
mnf_SizeOf=	mn_FPUMask+2

	rsreset		;EAData structure
EAD_cmd	rs.w	1	;bits for cmd-word
EAD_ext	rs.w	1	;extension word
EAD_bd	rs.l	1	;bd / address / #data
EAD_od	rs.l	1	;od
EAD_extra	rs.l	1	;extra long for .x/.p data
EAD_bds	rs.b	1	;bd size (0/1/2 = b/w/l)
EAD_ods	rs.b	1
EAD_type	rs.w	1	;type

EAD_ea	rs.l	1	;effective address (for jumps etc)
EAD_eavalid	rs.b	1	;flag valid ea.
	rs.b	1	;dummy_fill

EAD_SizeOf	rs.b	0


	ENDC
