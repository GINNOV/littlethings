
; -------------------------------------------------------------------
; ChannelInfo structure
; -------------------------------------------------------------------
			RSRESET
ci_sample_start		RS.L	1 ;sample start address
ci_rightch_offs		RS.L	1 ;right ch start address
ci_mixregs		RS.L	0 ;MIX REGISTERS START HERE
; DON'T CHANGE THE ORDER OF THE FOLLOWING FIVE OFFSETS
ci_offset		RS.L	1 ;current sample offset
ci_fraction		RS.L	1 ;1/65536th of ci_offset (W)
ci_advance		RS.L	1 ;offset change per mixed sample
ci_advfract		RS.L	1 ;1/65536th of ci_advance (W)
ci_mixroutine		RS.L	1 ;mix routine address
ci_endoffset		RS.L	1 ;sample end offset
ci_restartoffset	RS.L	1 ;loop restart change
ci_newstart_addr	RS.L	1 ;new sample start addr (synth)
ci_newendoffset		RS.L	1 ;new sample end offset (synth)
ci_voltable_l		RS.L	1 ;pointer to current vol table (L)
ci_voltable_r		RS.L	1 ;pointer to current vol table (R)
ci_volshift_l		RS.W	1 ;16-bit sample volume shift (L)
ci_volshift_r		RS.W	1 ;16-bit sample volume shift (R)
ci_flags		RS.B	1 ;flags
ci_pad			RS.B	3 ;longword align
ci_prevsample		RS.W	1 ;for smoothing routine
ci_currsample		RS.W	1 ;for smoothing routine
ci_nextsample		RS.W	1 ;for smoothing routine
ci_prevsample_r		RS.W	1 ;for smoothing routine
ci_currsample_r		RS.W	1 ;for smoothing routine
ci_nextsample_r		RS.W	1 ;for smoothing routine
ci_altmixroutine	RS.L	1 ;mix routine for other direction
ci_sizeof		RS.L	0

;ci_flags bit numbers
CHFLAGB_MUTED		EQU	7
CHFLAGB_LOOP		EQU	6
CHFLAGB_STARTSYN	EQU	5
CHFLAGB_16BIT		EQU	4
CHFLAGB_BACKW		EQU	3
CHFLAGB_STEREO		EQU	2
CHFLAGB_MIXING_RIGHT	EQU	1 ;a flag bit for smoothing routine
CHFLAGB_PINGPONG	EQU	0
