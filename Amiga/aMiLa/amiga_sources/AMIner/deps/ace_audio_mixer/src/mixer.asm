; $VER: mixer.asm 3.1 (17.03.23)
;
; mixer.asm
; Audio mixing routines
;
; For mixer API, see mixer.i and the rest of the mixer documentation.
;
; Note: all mixer configuration is done via mixer_config.i, please do not edit
;       the constants in this file.
;
; Note: code output by this file depends on settings in mixer_config.i
;
; Note: the audio mixer expects samples to be pre-processed such that adding
;       sample values together for all mixer channels can never exceed 8 bit
;       signed limits or overflow from positive to negative (or vice versa).
;
; Note: the audio mixer requires samples to be a multiple of a certain number
;       of bytes for correct playback. The exact number of bytes depends on
;       the configuration in mixer_config.i.
;
;       The number of bytes is as follows:
;       *) if none of the options below apply, the samples need to be a
;          multiple of 4 bytes in length
;       *) if MIXER_SIZEX32 is set to 1, the samples need to be a multiple of
;          32 bytes in length
;       *) if MIXER_SIZEXBUF is set to 1, the samples need to be a multiple of
;          the PAL or NTSC buffer size in length (depending on whether ot not
;          MIXER_SIZEXBUF_NTSC is 0 or 1)
;       *) if MIXER_SIZEX32 and MIXER_SIZEXBUF are set to one, the samples
;          need to be a multiple of the PAL/NTSC buffer size and a multiple of
;          32 bytes in length (depending on whether ot not MIXER_SIZEXBUF_NTSC
;          is 0 or 1)
;
;       The file mixer.i contains the equates mixer_PAL_multiple and
;       mixer_NTSC_multiple which give the exaxt multiple requirements for
;       samples. Note that in most cases these two will be the same value,
;       only if MIXER_SIZEXBUF is set to 1 the number will be different
;       between these two.
;
; Author: Jeroen Knoester
; Version: 3.1
; Revision: 20230317
;
; Assembled using VASM in Amiga-link mode.
; TAB size = 4 spaces

; Includes (OS includes assume at least NDK 1.3)
	include hardware/custom.i
	include hardware/dmabits.i
	include mixer.i
	IF MIXER_CIA_TIMER=1
		include hardware/cia.i
	ENDIF

; Constants
mxcustombase		EQU	$dff000				; mx prefix to keep one namespace
	IF MIXER_CIA_TIMER=1
mxciabase			EQU	$bfe000				; mx prefix to keep one namespace
	ENDIF

MIXER_CHAN_INACTIVE	EQU	0
MIXER_CHAN_ACTIVE	EQU	1
MIXER_CHAN_LOOP		EQU	-1

MIXER_STOPPED		EQU 0
MIXER_RUNNING		EQU 1

MIXER_AUD_COLOUR	EQU	$707
MIXER_IH_COLOUR		EQU	$b0b
MIXER_CHUPD_COLOUR	EQU	$909
MIXER_OTHER_COLOUR	EQU	$099

; Audio channel for use when MIXER_SINGLE is set
	IF MIXER_SINGLE=1
		IF mixer_output_aud0=1
mxsinglechan		SET	aud0
mxsingledma			SET DMAF_AUD0
		ENDIF
		IF mixer_output_aud1=1
mxsinglechan		SET	aud1
mxsingledma			SET DMAF_AUD1
		ENDIF
		IF mixer_output_aud2=1
mxsinglechan		SET	aud2
mxsingledma			SET DMAF_AUD2
		ENDIF
		IF mixer_output_aud3=1
mxsinglechan		SET	aud3
mxsingledma			SET DMAF_AUD3
		ENDIF
	ENDIF

; Sample/buffer constants
mxslength_word		SET	0
	IF MIXER_68020=0
		IF MIXER_WORDSIZED=1
mxslength_word		SET	1
		ENDIF
	ENDIF

mxsize_x32			SET 0
	IF MIXER_68020=0
		IF MIXER_SIZEX32=1
mxsize_x32			SET 1
		ENDIF
	ENDIF

; Start of code
	IF MIXER_SECTION=1
			section code,code
	ENDIF

;-----------------------------------------------------------------------------
; Check various mixer_config.i settings
;-----------------------------------------------------------------------------
mixer_error	SET	0

; Check if mixer count>=1
	IF mixer_output_count=0
mixer_error SET 1
		IF MIXER_NO_ECHO=0
			echo
			echo "Error: no mixer output channel has been selected"
		ENDIF
	ENDIF

; Check if software channels between 1 and 4
	IF mixer_sw_channels<1
mixer_error SET 1
		IF MIXER_NO_ECHO=0
			echo
			echo "Error: number of mixed channels out of range (1-4)"
		ENDIF
	ENDIF

	IF mixer_sw_channels>4
mixer_error SET 1
		IF MIXER_NO_ECHO=0
			echo
			echo "Error: number of mixed channels out of range (1-4)"
		ENDIF
	ENDIF

; Check if mixer_config.i only has one mixer type selected
.mxtype_check	EQU	MIXER_SINGLE+MIXER_MULTI+MIXER_MULTI_PAIRED
	IF .mxtype_check=0
mixer_error SET 1
		IF MIXER_NO_ECHO=0
			echo
			echo "Error: no mixer type selected in mixer_config.i"
		ENDIF
	ENDIF
	IF .mxtype_check>1
mixer_error SET 1
		IF MIXER_NO_ECHO=0
			echo
			echo "Error: more than one mixer type selected in mixer_config.i"
		ENDIF
	ENDIF

; Check if the single mixer only has one enabled channel
	IF mixer_output_count>1
		IF MIXER_SINGLE=1
mixer_error SET 1
			IF MIXER_NO_ECHO=0
			echo
			echo "Error: MIXER_SINGLE only supports one output channel"
			ENDIF
		ENDIF
	ENDIF

; Check if the paired mode has both AUD2 and AUD3 selected
.mxchancheck EQU mixer_output_aud2+mixer_output_aud3
	IF .mxchancheck<2
		IF MIXER_MULTI_PAIRED=1
mixer_error SET 1
			IF MIXER_NO_ECHO=0
			echo
			echo "Error: MIXER_MULTI_PAIRED requires DMAF_AUD2&3 selected"
			ENDIF
		ENDIF
	ENDIF

	IF mixer_error=0
;-----------------------------------------------------------------------------
; CIA timer start & CIA timer stop macros (available if MIXER_CIA_TIMER=1)
;-----------------------------------------------------------------------------
		IF MIXER_CIA_TIMER=1
		; Macro: CIAStart
		; This macro starts the CIA timer to measure mixer performance.
		;
		; Note: MixerInstallHandler should have been called prior to using
		;       this macro.
CIAStart	MACRO
		movem.l	d0/a6,-(sp)					; Stack

		; Set up CIA timer A for one shot mode
		lea.l	mxciabase+1,a6
		move.b	ciacra(a6),d0
		and.b	#%11000000,d0				; Keep bits 6&7 as is
		or.b    #%00001000,d0				; Set for one-shot mode
		move.b	d0,ciacra(a6)
        move.b	#%01111111,ciaicr(a6)		; Clear all CIA interrupts

		; Set up timer value (low byte first)
		move.b	#$ff,ciatalo(a6)
		move.b	#$ff,ciatahi(a6)

		movem.l	(sp)+,d0/a6					; Stack
			ENDM

		; Macro: CIAStop
		; This macro ends the CIA timer and store the measured results.
		;
		; Note: MixerInstallHandler should have been called prior to using
		;       this macro.
CIAStop		MACRO
		movem.l	d0/d1/a6,-(sp)				; Stack

		; Stop timer & fetch result
		lea.l	mxciabase+1,a6
		bclr	#0,ciacra(a6)
		moveq	#0,d0
		moveq	#0,d1
		move.b	ciatalo(a6),d0
		move.b	ciatahi(a6),d1
		asl.w	#8,d1
		or.w	d1,d0

		; Store result
		lea.l	mixer_ticks_last(pc),a6
		move.w	d0,(a6)						; Store last result

		; Compare result with best stored result
		cmp.w	2(a6),d0
		bls.s	.\@_not_best

		move.w	d0,2(a6)					; Store best result

.\@_not_best
		; Compare result with worst stored result
		cmp.w	4(a6),d0
		bcc.s	.\@_not_worst

		move.w	d0,4(a6)					; Store worst result

.\@_not_worst

		; Update average list
		lea.l	mixer_ticks_storage_off(pc),a6
		move.w	(a6),d1
		move.w	d0,2(a6,d1.w)				; Store in buffer
		addq.w	#2,d1

		cmp.w	#256,d1
		ble.s	.\@_no_avg_reset

		; Reset average counter
		moveq	#0,d1

.\@_no_avg_reset
		; Write to average buffer
		move.w	d1,(a6)

		movem.l	(sp)+,d0/d1/a6				; Stack
			ENDM
		ENDIF

;-----------------------------------------------------------------------------
; Setup routines
;-----------------------------------------------------------------------------

		; Routine: MixerSetup
		; This routine sets up the data structures and buffers used by the
		; mixer.
		;
		; Note: no error checking is done, if the values in mixer_config.i are
		;       invalid or the values passed in D0 & A0 are incorrect, the
		;       outcome of this routine is undefined.
		;
		; Note: the mixer defaults to the maximum hardware volume of 64, in
		;       part to compensate for the lower maximum volume mixed samples
		;       have (due to the lower maximum amplitude value of the
		;       individual samples).
		;
		; D0 - Set to MIX_PAL when running on a PAL system,
		;      set MIX_NTSC when running on a NTSC system
		; A0 - Pointer to a block of Chip Memory to use for mixer buffers.
		;      This block needs to be mixer_buffer_size bytes in size.
		;
		;      Note: on 68020+, the block should be longword aligned for
		;            optimal performance. On 68000, the block must be at
		;            least aligned on a word boundary.
MixerSetup
		movem.l	d0/d3-d7/a0-a2,-(sp)		; Stack

		; Fetch mixer structure
		lea.l	mixer(pc),a1

		; Store PAL/NTSC flag
		move.w	d0,mx_vidsys(a1)

		; Set buffer offset value based on PAL/NTSC flag
		cmp.w	#MIX_NTSC,d0
		beq.s	.mixer_ntsc

.mixer_pal
		move.l	#mixer_PAL_buffer_size,d0
		move.w	#mixer_PAL_period,d3
		bra.s	.fill_mixer_struct

.mixer_ntsc
		move.l	#mixer_NTSC_buffer_size,d0
		move.w	#mixer_NTSC_period,d3

		; Fill mixer structure
.fill_mixer_struct
		move.w	#MIXER_STOPPED,mx_status(a1)
		move.w	#64,mx_volume(a1)
		move.w	d3,mx_hw_period(a1)
		move.w	#mixer_output_channels,d6
		move.w	d6,mx_hw_channels(a1)
		move.w	d0,mx_buffer_size(a1)
		move.w	d0,d7
		asr.w	#1,d7
		move.w	d7,mx_buffer_size_w(a1)
		move.l	a0,mx_empty_buffer(a1)
		bsr		MixerClearBuffer		; Clear the empty buffer
		IF MIXER_MULTI_PAIRED=1
			and.w	#$7,d6
		ENDIF
		asl.w	#7,d6
		move.w	d6,mx_irq_bits(a1)

		; Fill mixer entry structure(s)
		IF MIXER_SINGLE=1
			moveq	#1-1,d7
			moveq	#1,d6
		ELSE
			moveq	#4-1,d7
			moveq	#mixer_output_channels,d6
		ENDIF
		IF MIXER_MULTI_PAIRED=1
			and.w	#$7,d6
		ENDIF
		moveq	#0,d4
		lea.l	mx_mixer_entries(a1),a1

		; Loop over entries
.mixer_entry_lp
		; Check if current HW channel is active
		btst	#0,d6
		beq		.mixer_entry_lp_end

		IF MIXER_MULTI_PAIRED=1
			; Clear active bit
			move.w	#0,mxe_active(a1)
		ENDIF

		; Set up for channel loop
		moveq	#4-1,d5
		lea.l	mxe_channels(a1),a2

		; Loop over mixer entry channels
.mixer_channel_lp
		IF mxslength_word=1
			move.w	d4,mch_remaining_length
			move.w	d4,mch_length(a2)
		ELSE
			move.l	d4,mch_remaining_length(a2)
			move.l	d4,mch_length(a2)
		ENDIF
		move.l	d4,mch_sample_ptr(a2)
		move.l	d4,mch_loop_ptr(a2)
		move.w	d4,mch_status(a2)
		move.w	d4,mch_priority(a2)
		move.w	d4,mch_age(a2)
		lea.l	mch_SIZEOF(a2),a2
		dbra	d5,.mixer_channel_lp

		; Fill mixer entry current channel & sample pointers
		moveq	#4-1,d5
		lea.l	mxe_active_channels(a1),a2

.mixer_pointers_lp
		move.l	d4,16(a2)
		move.l	d4,(a2)+
		dbra	d5,.mixer_pointers_lp

		; Fill mixer entry buffer pointers & clear buffers
		lea.l	mxe_buffers(a1),a2
		lea.l	0(a0,d0.w),a0
		move.l	a0,(a2)+
		bsr		MixerClearBuffer
		lea.l	0(a0,d0.w),a0
		move.l	a0,(a2)+
		bsr		MixerClearBuffer

.mixer_entry_lp_end
		asr.w	#1,d6
		lea.l	mxe_SIZEOF(a1),a1
		dbra	d7,.mixer_entry_lp

		movem.l	(sp)+,d0/d3-d7/a0-a2		; Stack
		rts

		; Routine: MixerInstallHandler
		; This routine sets up the required audio interrupt for the mixer.
		;
		; Note: MixerSetup must have been called prior to calling this
		;       routine.
		; Note: if MIXER_CIA_TIMER is set to 1, this routine also saves the
		;       CIA state to be able to restore it later.
		;
		; D0 - 0: save old interrupt vector
		;      1: do not save old interrupt vector
		; A0 - Pointer to VBR
		;
		;      Note: on systems without VBR (i.e. 68000 based systems), A0 has
		;      to be set to 0.
MixerInstallHandler
		movem.l	d1/a1/a6,-(sp)				; Stack

		IF MIXER_CIA_TIMER=1
			move.w	d0,-(sp)				; Stack

			; Save CIA values
			lea.l	mxciabase+1,a6			; CIA A
			lea.l	mixer_stored_cia(pc),a1

			move.b	ciacra(a6),d0
			move.b	ciaicr(a6),d1
			move.b	d0,(a1)					; Store CIA control value
			move.b	d1,1(a1)				; Store CIA IC value

			move.w	(sp)+,d0				; Stack
		ENDIF

		; Fetch custombase
		lea.l	mxcustombase,a6

		; Store the VBR value
		lea.l	mixer_stored_vbr(pc),a1
		move.l	a0,(a1)+

		; Save interrupt vector if needed
		tst.w	d0
		bne		.no_save
		move.l	$70(a0),(a1)+

		; Save any audio interrupt bits set
		move.w	intenar(a6),d1
		and.w	#%11110000000,d1			; Audio = bits 7-10
		or.w	#$8000,d1
		move.w	d1,(a1)+

.no_save
		; Disable all audio interrupts
		move.w	#%11110000000,d1			; Audio = bits 7-10
		move.w	d1,intena(a6)				; Disable audio interrupts
		move.w	d1,intreq(a6)				; Clear any pending interrupts
		move.w	d1,intreq(a6)				; Twice for A4000

		; Set audio interrupt handler
		lea.l	MixerIRQHandler(pc),a1		; Interrupt handler
		move.l	a1,$70(a0)					; $70 is vector 4 / audio

		; Calculate audio interrupt bit for correct channel and store result
		lea.l	mixer(pc),a1				; Fetch mixer structure
		move.w	#mixer_output_channels,d1	; Load audio channel bit(s)
		asl.w	#7,d1						; Shift by 7 to get interrupt bit
		move.w	d1,mx_irq_bits(a1)			; Store result

		; Set up audio interrupt
		or.w	#$c000,d1					; Prep INTENA setup
		move.w	d1,intena(a6)				; Set INTENA value
		tst.w	dmaconr(a6)					; Delay for A4000

		; Update mixer status
		move.w	#MIXER_RUNNING,mx_status(a1)

		movem.l	(sp)+,d1/a1/a6				; Stack
		rts

		; Routine: MixerRemoveHandler
		; This routine disables & removes the audio interrupt.
		; It also restores the old handler if previously stored.
		;
		; Note: MixerSetup & MixerInstallHandler must have been called prior to calling
		;       this routine.
		; Note: if MIXER_CIA_TIMER is set to 1, this routine also restores the
		;       saved CIA state.
		; Note: if MIXER_CIA_TIMER & MIXER_CIA_KBOARD_RES are set to 1, this
		;       routine also restores the keyboard for AmigaOS use. Note that
		;       in this case, the MixerRemoveHandler routine should be called
		;       shortly before returning to the OS to prevent CIA timer
		;       underflows.
MixerRemoveHandler
		movem.l	d0/a0/a1/a6,-(sp)			; Stack

		; Fetch custom base
		lea.l	mxcustombase,a6

		; Disable all audio interrupts
		move.w	#%11110000000,d0			; Audio = bits 7-10
		move.w	d0,intena(a6)				; Disable audio interrupts
		move.w	d0,intreq(a6)				; Clear any pending interrupts
		move.w	d0,intreq(a6)				; Twice for A4000

		; Restore interrupt vector (if set)
		lea.l	mixer_stored_vbr(pc),a1
		move.l	(a1)+,a0					; Get VBR
		move.l	(a1)+,d0					; Get handler
		beq		.no_restore

		; Restore interrupt vector
		move.l	d0,$70(a0)					; Vector 4

		; Restore INTENA value
		move.w	(a1)+,intena(a6)			; Set old intena values
		tst.w	dmaconr(a6)					; Delay for A4000

.no_restore
		; Update mixer status
		lea.l	mixer(pc),a1
		move.w	#MIXER_STOPPED,mx_status(a1)

		IF MIXER_CIA_TIMER=1
			; Restore CIA values
			lea.l	mxciabase+1,a6			; CIA A
			lea.l	mixer_stored_cia(pc),a1
			move.b	(a1),ciacra(a6)			; Restore CIA A control value
			move.b	1(a1),ciaicr(a6)		; Restore CIA A IC value

			IF MIXER_CIA_KBOARD_RES=1
				; Remaining code to restore keyboard
				move.b	#$ff,ciatblo(a6)	; TB=$ffff
				move.b	#$ff,ciatbhi(a6)
				; Re-enable CIA-A interrupts for AmigaOS
				move.b	#$8f,ciaicr(a6)
			ENDIF
		ENDIF
		movem.l	(sp)+,d0/a0/a1/a6			; Stack
		rts

		; Routine: MixerStart
		; This routine enables playback of mixed samples. Initial playback is
		; silence.
		;
		; Note: MixerSetup & MixerInstallHandler must have been called prior
		;       to calling this routine.
		; Note: if MIXER_CIA_TIMER is set to 1, this routine also clears the
		;       stored CIA timer results.
MixerStart
		movem.l	d0/d1/d7/a0/a6,-(sp)		; Stack

		IF MIXER_CIA_TIMER=1
			; Clear stored CIA timing results
			lea.l	mixer_ticks_last(pc),a6
			clr.w	(a6)+
			clr.w	(a6)+
			move.w	#$ffff,(a6)
		ENDIF

		; Fetch custombase
		lea.l	mxcustombase,a6

		; Enable audio interrupts for all valid channels
		; lea.l	mixer(pc),a0
		; move.w	mx_irq_bits(a0),d0			; Fetch IRQ bits
		; or.w	#$c000,d0					; Prep INTENA setup
		; move.w	d0,intena(a6)				; Set INTENA value
		; tst.w	dmaconr(a6)					; Delay for A4000

		IF MIXER_SINGLE=1
			move.w	#mxsinglechan,d1
		ELSE
			; Play silence on all selected channels
			move.w	#mixer_output_channels,d0
			move.w	#aud,d1
			moveq	#4-1,d7

			; Loop over all channels
.lp			btst	#0,d0
			beq		.next_channel
		ENDIF

		; Play silence
		bsr		MixerPlaySilence

		IF MIXER_SINGLE=0
		; Go to next channel
.next_channel
			asr.w	#1,d0
			add.w	#ac_SIZEOF,d1
			dbra	d7,.lp
		ENDIF

		movem.l	(sp)+,d0/d1/d7/a0/a6		; Stack
		rts

		; Routine: MixerStop
		; This routine disables playback of mixed samples.
		;
		; Note: MixerSetup, MixerInstallHandler & MixerStart must have been called
		;       before calling this routine.
MixerStop
		movem.l	d6/d7/a0/a6,-(sp)				; Stack

		; Fetch custombase
		lea.l	mxcustombase,a6

		; Fetch mixer, irq bits & HW channels
		lea.l	mixer(pc),a0
		move.w	mx_irq_bits(a0),d7
		move.w	mx_hw_channels(a0),d6

		; Disable audio interrupt(s)
		; move.w	d7,intena(a6)					; Disable audio interrupts
		; move.w	d7,intreq(a6)					; Clear any pending interrupts
		; move.w	d7,intreq(a6)					; Twice for A4000


		IF MIXER_SINGLE=1
			move.w	#mxsinglechan,d1
		ELSE
			; Play silence on all selected channels
			move.w	#mixer_output_channels,d0
			move.w	#aud,d1
			moveq	#4-1,d7

			; Loop over all channels
.lp			btst	#0,d0
			beq		.next_channel
		ENDIF

		; Play silence & set volume to zero.
		bsr		MixerPlaySilence
		move.w	#0,ac_vol(a6,d1.w)

		IF MIXER_SINGLE=0
		; Go to next channel
.next_channel
			asr.w	#1,d0
			add.w	#ac_SIZEOF,d1
			dbra	d7,.lp
		ENDIF

		; Disable audio DMA for the mixing channel(s)
		; move.w	d6,dmacon(a6)
		movem.l	d0/d1/a0/a1,-(sp)			; Stack
		jsr mixerDisableAudioDma
		movem.l	(sp)+,d0/d1/a0/a1			; Stack

		; Fetch mixer entries
		lea.l	mx_mixer_entries(a0),a0

		; Loop over all mixer entries
		IF MIXER_SINGLE=1
			moveq	#1-1,d7
		ELSE
			moveq	#4-1,d7
		ENDIF
.enlp	lea.l	mxe_channels(a0),a6

		; Deactivate all mixer channels per entry
		moveq	#4-1,d6
.chlp	move.w	#MIXER_CHAN_INACTIVE,mch_status(a6)
		lea.l	mch_SIZEOF(a6),a6
		dbra	d6,.chlp

		; Loop back
		lea.l	mxe_SIZEOF(a0),a0
		dbra	d7,.enlp

		movem.l	(sp)+,d6/d7/a0/a6				; Stack
		rts

		; Routine: MixerVolume
		; This routine sets the hardware volume used by the mixer hardware
		; channels during playback.
		;
		; Note: when running MixerSetup, volume is set to the hardware maximum
		;       of 64 by default.
		;
		; D0 - desired volume (0-64)
MixerVolume
		move.l	a0,-(sp)					; Stack

		; Fetch mixer & set volume
		lea.l	mixer(pc),a0
		move.w	d0,mx_volume(a0)

		move.l	(sp)+,a0					; Stack
		rts

;-----------------------------------------------------------------------------
; SFX playback macros
;-----------------------------------------------------------------------------

		; Macro: MixFetchEntry
		; This macro forms the common code for fetching the correct mixer
		; entry. Used in MixPlaySam/MixPlaySamCh. Implemented as a macro for
		; reasons of performance and prevention of writing double code.
MixFetchEntry	MACRO
		; Fetch mixer & first entry
		lea.l	mixer+mx_mixer_entries(pc),a1

		; Multi mixer path
		IF MIXER_SINGLE=0
			; Jump to selected entry
			move.w	d0,d4
			and.w	#$f,d4
			add.w	d4,d4
			add.w	d4,d4
			jmp		.enjmp_table(pc,d4.w)

			; Jump table
			; The empty space included in the table is required for the
			; conversion between entry bit and entry number.
.enjmp_table
			nop
			nop
			jmp	.en0(pc)
			jmp	.en1(pc)
			dc.l	0
			jmp	.en2(pc)
			dc.l	0,0,0

.en3		lea.l	mxe_SIZEOF(a1),a1
.en2		lea.l	mxe_SIZEOF(a1),a1
.en1		lea.l	mxe_SIZEOF(a1),a1
.en0
		ENDIF

		; Select first channel
		lea.l	mxe_channels(a1),a1
				ENDM

		; Macro: MixChkChan
		; This macro forms the an unrolled loop entry for checking if a mixer
		; channel is free for use by the requested sample, taking into account
		; priority and age.
		;
		; \1 channel number (or 0 in case of MIXER_68020)
MixChkChan	MACRO
		; Check if the channel can be used
		IF MIXER_68020=1
			swap	d3
			move.w	mch_status(a1),d0
			smi		d3
			or.b	d3,d0
			swap	d3
			addq.w	#1,d0
			add.w	d0,d0
			add.w	d0,d0
			jmp		.stjmp_table\1(pc,d0.w)
		ELSE
			swap	d0
			move.w	mch_status(a1),d7
			smi		d0
			or.b	d0,d7
			swap	d0
			addq.w	#1,d7
			add.w	d7,d7
			add.w	d7,d7
			jmp		.stjmp_table\1(pc,d7.w)
		ENDIF

.stjmp_table\1
		; Jump table for the different statusses (free, in use, looping)
		jmp		.not_free\1(pc)
		jmp		.play_fx\1(pc)
		jmp		.check_priority\1(pc)

.play_fx\1
		; This channel is free, play the sample here
		IF MIXER_68020=1
			moveq	#0,d6
			bset	d7,d6					; Best channel found
		ELSE
			move.w	#MIX_CH\1,d6			; Best channel found
		ENDIF
		bra		.found

.check_priority\1
		; Check based on priority
		; Check if the priority of the new sample is equal or higher than the
		; current channel.
		cmp.w	mch_priority(a1),d2
		blt.s	.not_free\1

		; Check if the priority of the current channel is lower than the best
		; found priority so far.
		cmp.w	mch_priority(a1),d4
		bgt.s	.new_best_chan\1

		; Check if the age of the current channel is higher than the best age
		; found so far.
		cmp.w	mch_age(a1),d5
		bhi.s	.not_free\1

.new_best_chan\1
		; Set current channel as best found so far
		move.w	mch_priority(a1),d4			; Best priority found
		move.w	mch_age(a1),d5				; Reset best age found
		IF \1=1
			moveq	#0,d6
			bset	d7,d6					; Best channel found
		ELSE
			move.w	#MIX_CH\1,d6			; Best channel found
		ENDIF
		move.l	a1,a2						; Best channel found pointer

.not_free\1
		; This channel is not free, continue with the next channel.
		lea.l	mch_SIZEOF(a1),a1
				ENDM

		; Macro: MixPlaySam
		; This macro forms the common code for MixerPlayFX & MixerPlaySample.
		; Implemented as a macro for reasons of performance and prevention of
		; writing double code.
		;
		; \1 - Set to 0 for register based and 1 for MXEffect based played
MixPlaySam		MACRO
		; Fetch the correct mixer entry
		MixFetchEntry

		IF MIXER_SINGLE=1
			; Set HW channel to correct channel for single mixing
			move.w	#mxsingledma,d0
		ENDIF

		IF \1=1
			; Pre-fetch elements from structure as needed
			move.w	mfx_priority(a0),d2
			move.l	mfx_length(a0),d1
		ENDIF

		; Set up to search for best channel
		move.w	#-32768,d4					; Best priority found
		moveq	#0,d5						; Reset best age found
		moveq	#0,d6						; Best channel found
		move.l	d6,a2						; Reset best channel pointer

		; For each mixer channel, check availability
		IF MIXER_68020=1
			; Set up for loop
			swap	d0						; Swap HW channel

			move.w	#4,d7					; Channel bit
			swap	d7
			move.w	#4-1,d7					; Loop counter

.chlp		swap	d7						; Channel bit
			MixChkChan 0
			addq.w	#1,d7					; Next channel
			swap	d7						; Loop counter
			dbra	d7,.chlp

			swap	d0						; Swap back HW channel
		ELSE
			MixChkChan 0					; Check MIX_CH0
			IF mixer_sw_channels>=2
				MixChkChan 1				; Check MIX_CH1
			ENDIF
			IF mixer_sw_channels>=3
				MixChkChan 2				; Check MIX_CH2
			ENDIF
			IF mixer_sw_channels=4
				MixChkChan 3				; Check MIX_CH3
			ENDIF
		ENDIF

		; Check if any channel was found based on priority
		tst.w	d6
		bne.s	.prio_found

		; No channels are free
		moveq	#-1,d0
		bra		.done

.prio_found
		; Found a lower priority/older channel
		move.l	a2,a1

.found
		; Found a free channel, add the sample
		IF mxsize_x32=1
			and.w	#$ffe0,d1					; Limit to multiple of 32 bytes
		ELSE
			and.w	#$fffc,d1					; Limit to multiple of  4 bytes
		ENDIF

		; Writes to the channel must be atomic (i.e. can't be interrupted by
		; the audio mixer to prevent failures in playback)

		; Test if the mixer interrupts are running
		move.w	mixer+mx_status(pc),d7
		beq.s	.irq_disabled

		; Disable audio interrupts
		; lea.l	mxcustombase,a6
		; move.w	mixer+mx_irq_bits(pc),d7		; Fetch audio bits
		; and.w	#$7fff,d7						; Mask out SET/CLR bit
		; move.w	d7,intena(a6)					; Disable audio interrupts
		; tst.w	dmaconr(a6)						; Wait for A4000
		movem.l	d0/d1/a0/a1,-(sp)			; Stack
		jsr mixerEnableAudioDma
		movem.l	(sp)+,d0/d1/a0/a1			; Stack
.irq_disabled

		; Start of atomic part
		IF mxslength_word=1
			move.w	d1,mch_length(a1)			; Set length
			move.w	d1,mch_remaining_length(a1)	; Set remaining length
		ELSE
			move.l	d1,mch_length(a1)			; Set length
			move.l	d1,mch_remaining_length(a1)	; Set remaining length
		ENDIF
		move.w	d2,mch_priority(a1)			; Set priority
		move.w	#0,mch_age(a1)				; Set age
		IF \1=1
			move.l	mfx_sample_ptr(a0),mch_sample_ptr(a1); Set sample pointer
		ELSE
			move.l	a0,mch_sample_ptr(a1)	; Set sample pointer
		ENDIF

		IF \1=1
			tst.w	mfx_loop(a0)
		ELSE
			tst.w	d3
		ENDIF
		bmi.s	.write_loop_ptr				; Check for looping sample

		; Not a loop, use empty buffer
		move.l	mixer+mx_empty_buffer(pc),mch_loop_ptr(a1)
		bra.s	.write_status

.write_loop_ptr
		IF \1=1
			move.l	mfx_sample_ptr(a0),mch_loop_ptr(a1); Set sample pointer
		ELSE
			move.l	a0,mch_loop_ptr(a1)	; Set sample pointer
		ENDIF
.write_status
		IF \1=1
			move.w	mfx_loop(a0),mch_status(a1)	; Set status
		ELSE
			move.w	d3,mch_status(a1)			; Set status
		ENDIF

		; Test if the mixer interrupts are running
		move.w	mixer+mx_status(pc),d7
		beq.s	.irq_enabled

		; Re-enable audio interrupts
		; move.w	mixer+mx_irq_bits(pc),d7
		; or.w	#$8000,d7					; Set the SET/CLR bit
		; move.w	d7,intena(a6)				; Enable audio interrupts
		movem.l	d0/d1/a0/a1,-(sp)			; Stack
		jsr mixerEnableAudioInterrupts
		movem.l	(sp)+,d0/d1/a0/a1			; Stack
.irq_enabled

		; End of atomic part
		or.w	d6,d0						; Set return value

.done
				ENDM

		; Macro: MixPlayChSam
		; This macro forms the common code for MixerPlayChannelFX &
		; MixerPlayChannelSample. Implemented as a macro for reasons of
		; performance and prevention of writing double code.
		;
		; \1 - Set to 0 for register based and 1 for MXEffect based played
MixPlayChSam	MACRO
		; Fetch the correct mixer entry
		MixFetchEntry

		IF MIXER_SINGLE=1
			; Set HW channel to correct channel for single mixing
			moveq	#mxsingledma,d2
			and.w	#$f0,d0
			or.w	d2,d0
		ENDIF

		IF \1=1
			; Pre-fetch elements from structure as needed
			move.w	mfx_priority(a0),d2
			move.l	mfx_length(a0),d1
		ENDIF

		; Jump to selected channel
		move.w	d0,d4
		asr.w	#4,d4
		add.w	d4,d4
		add.w	d4,d4
		jmp		.chjmp_table(pc,d4.w)

		; Jump table
		; The empty space included in the table is required for the
		; conversion between channel bit and channel number.
.chjmp_table
		nop
		nop
		jmp	.ch0(pc)
		jmp	.ch1(pc)
		dc.l	0
		jmp	.ch2(pc)
		dc.l	0,0,0

.ch3	lea.l	mch_SIZEOF(a1),a1
.ch2	lea.l	mch_SIZEOF(a1),a1
.ch1	lea.l	mch_SIZEOF(a1),a1
.ch0
		; Check if the channel can be used
		swap	d0
		move.w	mch_status(a1),d4
		smi		d0
		or.b	d0,d4
		swap	d0
		addq.w	#1,d4
		add.w	d4,d4
		add.w	d4,d4
		jmp		.stjmp_table(pc,d4.w)

		; Jump table for the different statusses (free, in use, looping)
.stjmp_table
		jmp		.not_free(pc)
		jmp		.play_fx(pc)
		jmp		.check_priority(pc)

.check_priority
		; Check if the priority of the new FX is equal or higher than the
		; currently playing FX.
		cmp.w	mch_priority(a1),d2
		bge.s	.play_fx

		; Channel is not free
.not_free
		moveq	#-1,d0
		bra.s	.done

.play_fx
		; Add sample to selected channel here
		IF mxsize_x32=1
			and.w	#$ffe0,d1					; Limit to multiple of 32 bytes
		ELSE
			and.w	#$fffc,d1					; Limit to multiple of  4 bytes
		ENDIF

		; Writes to the channel must be atomic (i.e. can't be interrupted by
		; the audio mixer to prevent failures in playback)

		; Test if the mixer interrupts are running
		move.w	mixer+mx_status(pc),d4
		beq.s	.irq_disabled

		; Disable audio interrupts
		; lea.l	mxcustombase,a6
		; move.w	mixer+mx_irq_bits(pc),d4		; Fetch audio bits
		; and.w	#$7fff,d4						; Mask out SET/CLR bit
		; move.w	d4,intena(a6)					; Disable audio interrupts
		; tst.w	dmaconr(a6)						; Wait for A4000
		movem.l	d0/d1/a0/a1,-(sp)			; Stack
		jsr mixerDisableAudioInterrupts
		movem.l	(sp)+,d0/d1/a0/a1			; Stack

.irq_disabled

		; Start of atomic part
		IF mxslength_word=1
			move.w	d1,mch_length(a1)			; Set length
			move.w	d1,mch_remaining_length(a1)	; Set remaining length
		ELSE
			move.l	d1,mch_length(a1)			; Set length
			move.l	d1,mch_remaining_length(a1)	; Set remaining length
		ENDIF
		move.w	d2,mch_priority(a1)			; Set priority
		move.w	#0,mch_age(a1)				; Set age
		IF \1=1
			move.l	mfx_sample_ptr(a0),mch_sample_ptr(a1); Set sample pointer
		ELSE
			move.l	a0,mch_sample_ptr(a1)	; Set sample pointer
		ENDIF

		IF \1=1
			tst.w	mfx_loop(a0)
		ELSE
			tst.w	d3
		ENDIF
		bmi.s	.write_loop_ptr				; Check for looping sample

		; Not a loop, use empty buffer
		move.l	mixer+mx_empty_buffer(pc),mch_loop_ptr(a1)
		bra.s	.write_status

.write_loop_ptr
		IF \1=1
			move.l	mfx_sample_ptr(a0),mch_loop_ptr(a1); Set sample pointer
		ELSE
			move.l	a0,mch_loop_ptr(a1)	; Set sample pointer
		ENDIF
.write_status
		IF \1=1
			move.w	mfx_loop(a0),mch_status(a1)	; Set status
		ELSE
			move.w	d3,mch_status(a1)			; Set status
		ENDIF

		; Test if the mixer interrupts are running
		move.w	mixer+mx_status(pc),d4
		beq.s	.irq_enabled

		; Re-enable audio interrupts
		; move.w	mixer+mx_irq_bits(pc),d4
		; or.w	#$8000,d4					; Set the SET/CLR bit
		; move.w	d4,intena(a6)				; Enable audio interrupts
		movem.l	d0/d1/a0/a1,-(sp)			; Stack
		jsr mixerEnableAudioInterrupts
		movem.l	(sp)+,d0/d1/a0/a1			; Stack

.irq_enabled

		; End of atomic part
		tst.w	d0							; Set return value

.done
				ENDM

;-----------------------------------------------------------------------------
; SFX playback routines
;-----------------------------------------------------------------------------

		; Routine: MixerPlaySample
		; This routine plays the given sample on the given hardware channel,
		; selecting the best possible fitting mixer channel available.
		; Priority is taken into account.
		;
		; Fails if no applicable mixer channel is free.
		;
		; Note: this routine does not check if the HW channel selected is
		;       available to the mixer, if an unused HW channel is
		;       selected, no sample will be played back. This only applies if
		;       MIXER_MULTI=1 or  MIXER_MULTI_PAIRED=1.
		; Note: once playing, looping samples can only be ended by calling
		;       MixerStopFX. Until this happens, a looping sample will occupy
		;       a mixer channel forever, regardless of the priority of any
		;       incoming sample playback requests.
		;
		;       Keep in mind that the initial playback request for a looping
		;       sample will follow priorities as normal to determine if it can
		;       start playing.
		;
		; A0 - Pointer to sample data
		; D0 - Hardware channel (f.ex. DMAF_AUD0)
		;      Note: if MIXER_SINGLE=1, hardware channel selection is ignored.
		;      Note: if MIXER_MULTI_PAIRED=1, DMAF_AUD3 is not a valid
		;            channel.
		;      Note: Only one HW channel can be selected at a time.
		; D1 - Length of sample in bytes
		; D2 - Priority (signed, higher number=higher priority)
		; D3 - Loop indicator (MIX_FX_ONCE or MIX_FX_LOOP)
		;
		; Returns
		; D1 - Either:
		;      *) -1, if the sample can't be played (f.ex. due to priority)
		;      *) Hardware/mixer channel combination the sample will be played
		;         on. (f.ex. DMAF_AUD0|MIX_CH2)
MixerPlaySample
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_OTHER_COLOUR,$dff180
		ENDIF
		movem.l	d2-d7/a1/a2/a6,-(sp)		; Stack

		; Play the sample
		MixPlaySam 0

		movem.l	(sp)+,d2-d7/a1/a2/a6		; Stack
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
			tst.w	d1						; Restore condition code
		ENDIF
		rts

		; Routine: MixerPlayChannelSample
		; This routine plays the given sample on the given hardware/mixer
		; channel combination. Priority and channel availability are taken
		; into account.
		;
		; Fails if the selected hardware/mixer channel combination is not
		; free.
		;
		; Note: this routine does not check if the HW channel selected is
		;       available to the mixer, if an unused HW channel is
		;       selected, no sample will be played back. This only applies if
		;       MIXER_MULTI=1 or  MIXER_MULTI_PAIRED=1.
		; Note: this routine does not check if the mixer is running with
		;       enough mixed channels for the required mixer channel to be
		;       in use. If the mixer channel is not in use, no sample will be
		;       played back.
		; Note: once playing, looping samples can only be ended by calling
		;       MixerStopFX. Until this happens, a looping sample will occupy
		;       a mixer channel forever, regardless of the priority of any
		;       incoming sample playback requests.
		;
		;       Keep in mind that the initial playback request for a looping
		;       sample will follow priorities as normal to determine if it can
		;       start playing.
		;
		; A0 - Pointer to sample data
		; D0 - Hardware channel/mixer channel (f.ex. DMAF_AUD0|MIX_CH1)
		;      Supports setting exactly one mixer software channel.
		;
		;      Note: if MIXER_SINGLE=1, hardware channel selection is ignored.
		;      Note: if MIXER_MULTI_PAIRED=1, DMAF_AUD3 is not a valid
		;            channel.
		;      Note: Only one HW channel can be selected at a time.
		; D1 - Length of sample in bytes
		; D2 - Priority (signed, higher number=higher priority)
		; D3 - Loop indicator (MIX_FX_ONCE or MIX_FX_LOOP)
		;
		; Returns
		; D1 - Either:
		;      *) -1, if the sample can't be played (f.ex. due to priority)
		;      *) Hardware/mixer channel combination the sample will be played
		;         on. (f.ex. DMAF_AUD0|MIX_CH1)
MixerPlayChannelSample
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_OTHER_COLOUR,$dff180
		ENDIF
		movem.l	d2-d4/a1/a6,-(sp)			; Stack

		; Play the sample
		MixPlayChSam 0

		movem.l	(sp)+,d2-d4/a1/a6			; Stack
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
			tst.w	d1						; Restore condition code
		ENDIF
		rts

		; Routine: MixerPlayFX
		; This routine plays the given sample on the given hardware
		; channel, selecting the best possible fitting mixer channel
		; available. Priority is taken into account.
		;
		; Fails quietly if no applicable mixer channel is free.
		;
		; Note: this routine does not check if the HW channel selected is
		;       available to the mixer, if an unused HW channel is
		;       selected, no sample will be played back. This only applies if
		;       MIXER_MULTI=1 or  MIXER_MULTI_PAIRED=1.
		; Note: once playing, looping FX can only be ended by calling
		;       MixerStopFX. Until this happens, a looping FX will occupy a
		;       mixer channel forever, regardless of the priority of any
		;       incoming FX playback requests.
		;
		;       Keep in mind that the initial playback request for a looping
		;       FX will follow priorities as normal to determine if it can
		;       start playing.
		;
		; A0 - Pointer to MXEffect structure for the effect to play
		; D0 - Hardware channel (f.ex. DMAF_AUD0)
		;      Note: if MIXER_SINGLE=1, hardware channel selection is ignored.
		;      Note: if MIXER_MULTI_PAIRED=1, DMAF_AUD3 is not a valid
		;            channel.
		;      Note: Only one HW channel can be selected at a time.
		;
		; Returns
		; D1 - Either:
		;      *) -1, if the FX can't be played (f.ex. due to priority)
		;      *) Hardware/software channel combination the FX will be played
		;         on. (f.ex. DMAF_AUD0|MIX_CH2)
MixerPlayFX
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_OTHER_COLOUR,$dff180
		ENDIF
		move.w	d2,-(sp)
		movem.l	d4-d7/a1/a2/a6,-(sp)		; Stack

		; Play the effect
		MixPlaySam 1

		movem.l	(sp)+,d4-d7/a1/a2/a6		; Stack
		move.w	(sp)+,d2
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
			tst.w	d1						; Restore condition code
		ENDIF
		rts

		; Routine: MixerPlayChannelFX
		; This routine plays the given FX on the given hardware/mixer channel
		; combination. Priority and channel availability are taken into
		; account.
		;
		; Fails quietly if the selected hardware/mixer channel combination is not free.
		;
		; Note: this routine does not check if the HW channel selected is
		;       available to the mixer, if an unused HW channel is
		;       selected, no sample will be played back. This only applies if
		;       MIXER_MULTI=1 or  MIXER_MULTI_PAIRED=1.
		; Note: this routine does not check if the mixer is running with
		;       enough mixed channels for the required mixer channel to be
		;       in use. If the mixer channel is not in use, no FX will be
		;       played back.
		; Note: once playing, looping FX can only be ended by calling
		;       MixerStopFX. Until this happens, a looping FX will occupy a
		;       mixer channel forever, regardless of the priority of any
		;       incoming FX playback requests.
		;
		;       Keep in mind that the initial playback request for a looping
		;       FX will follow priorities as normal to determine if it can
		;       start playing.
		;
		; A0 - Pointer to MXEffect structure for the FX to play
		; D0 - Hardware channel/mixer channel (f.ex. DMAF_AUD0|MIX_CH1)
		;      Supports setting exactly one mixer channel.
		;
		;      Note: if MIXER_SINGLE=1, hardware channel selection is ignored.
		;      Note: if MIXER_MULTI_PAIRED=1, DMAF_AUD3 is not a valid
		;            channel.
		;      Note: Only one HW channel can be selected at a time.
		;
		; Returns
		; D1 - Either:
		;      *) -1, if the FX can't be played (f.ex. due to priority)
		;      *) Hardware/software channel combination the FX will be played
		;         on. (f.ex. DMAF_AUD0|MIX_CH1)
MixerPlayChannelFX
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_OTHER_COLOUR,$dff180
		ENDIF
		move.w	d2,-(sp)
		movem.l	d4/a1/a6,-(sp)				; Stack

		; Play the effect
		MixPlayChSam 1

		movem.l	(sp)+,d4/a1/a6				; Stack
		move.w	(sp)+,d2
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
			tst.w	d1						; Restore condition code
		ENDIF
		rts

		; Routine: MixerStopFX
		; This routine stops playback on the given hardware/mixer channel(s).
		;
		; Note: this routine supports selecting multiple hardware and mixer
		;       channels in a single call. In this case, the relevant mixer
		;       channels stop playback on all selected hardware channels.
		;
		; D0 - Hardware channel/mixer channel mask (f.ex. DMAF_AUD0|MIX_CH1)
		;      Note: if MIXER_SINGLE=1, hardware channel selection is ignored.
MixerStopFX
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_OTHER_COLOUR,$dff180
		ENDIF
		IF MIXER_SINGLE=1
			IF MIXER_68020=1
				movem.l	d0-d2/d7/a0,-(sp)	; Stack
			ELSE
				movem.l	d0/d1/a0,-(sp)		; Stack
			ENDIF
			and.w	#$fff0,d0
			or.w	#mxsingledma,d0			; Set correct hardware channel
		ELSE
			IF MIXER_68020=1
				movem.l	d0-d3/d6/d7/a0/a1,-(sp)	; Stack
			ELSE
				movem.l	d0-d2/d7/a0/a1,-(sp)	; Stack
			ENDIF
		ENDIF

		; Fetch mixer & setup for stopping FX
		lea.l	mixer(pc),a0
		moveq	#MIXER_CHAN_INACTIVE,d1

		; Single mixer path
		IF MIXER_SINGLE=1
			; Fetch the first mixer entry/channel
			lea.l	mx_mixer_entries+mxe_channels(a0),a0

			; Check each channel
			IF MIXER_68020=1
				; Set up for loop
				moveq	#4,d2
				moveq	#4-1,d7

.chlp			btst	d2,d0
				beq.s	.nxt_ch

				move.w	d1,mch_status(a0)

.nxt_ch			lea.l	mch_SIZEOF(a0),a0
				addq.w	#1,d2
				dbra	d7,.chlp
			ELSE
				btst	#4,d0				; Check channel 0
				beq.s	.ch1

				move.w	d1,mch_status(a0)

.ch1			btst	#5,d0				; Check channel 1
				beq.s	.ch2

				move.w	d1,mch_status+mch_SIZEOF(a0)

.ch2			btst	#6,d0				; Check channel 2
				beq.s	.ch3

				move.w	d1,mch_status+(mch_SIZEOF*2)(a0)

.ch3			btst	#7,d0				; Check channel 3
				beq.s	.stopfx_done

				move.w	d1,mch_status+(mch_SIZEOF*3)(a0)
.stopfx_done
			ENDIF
		ENDIF

		; Multi mixer path
		IF MIXER_SINGLE=0
			; Fetch first mixer entry
			lea.l	mx_mixer_entries(a0),a0

			; Set up for loop
			moveq	#4-1,d7
			moveq	#0,d2

			; Loop over mixer entries
.lp			lea.l	mxe_channels(a0),a1
			btst	d2,d0
			beq.s	.next_entry

			; Check each channel for current entry
			IF MIXER_68020=1
				; Set up for loop
				moveq	#4,d3
				moveq	#4-1,d6

.chlp			btst	d3,d0
				beq.s	.nxt_ch

				move.w	d1,mch_status(a1)

.nxt_ch			lea.l	mch_SIZEOF(a1),a1
				addq.w	#1,d3
				dbra	d6,.chlp
			ELSE
				btst	#4,d0				; Check channel 0
				beq.s	.ch1

				move.w	d1,mch_status(a1)

.ch1			btst	#5,d0				; Check channel 1
				beq.s	.ch2

				move.w	d1,mch_status+mch_SIZEOF(a1)

.ch2			btst	#6,d0				; Check channel 2
				beq.s	.ch3

				move.w	d1,mch_status+(mch_SIZEOF*2)(a1)

.ch3			btst	#7,d0				; Check channel 3
				beq.s	.next_entry

				move.w	d1,mch_status+(mch_SIZEOF*3)(a1)
			ENDIF

			; Loop back
.next_entry	lea.l	mxe_SIZEOF(a0),a0
			addq.w	#1,d2
			dbra	d7,.lp
		ENDIF

		IF MIXER_SINGLE=1
			IF MIXER_68020=1
				movem.l	(sp)+,d0-d2/d7/a0	; Stack
			ELSE
				movem.l	(sp)+,d0/d1/a0		; Stack
			ENDIF
		ELSE
			IF MIXER_68020=1
				movem.l	(sp)+,d0-d3/d6/d7/a0/a1	; Stack
			ELSE
				movem.l	(sp)+,d0-d2/d7/a0/a1	; Stack
			ENDIF
		ENDIF
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
		ENDIF
		rts

;-----------------------------------------------------------------------------
; Interrupt handler macros
;-----------------------------------------------------------------------------
		; Macro: MixSingIHstart
		; This macro forms the start of the mixer audio interrupt handler in
		; case MIXER_SINGLE=1. Implemented as a macro for performance reasons
		; and to prevent double code.
MixSingIHstart	MACRO
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_IH_COLOUR,$dff180
		ENDIF
		IF MIXER_CIA_TIMER=1
			CIAStart
		ENDIF
		IF MIXER_68020=0
			movem.l	d0-d7/a0-a6,-(sp)				; Stack
		ELSE
			movem.l	d0-d3/d7/a0-a6,-(sp)			; Stack
		ENDIF

		; Fetch custombase & mixer / mixer entry
		lea.l	mxcustombase,a6
		lea.l	mixer+mx_mixer_entries(pc),a1

		; Acknowledge interrupt
		move.w	mixer+mx_irq_bits(pc),intreq(a6)

		; Fetch and swap buffers
		lea.l	mxe_buffers(a1),a2
		move.l	(a2)+,d0							; Fetch
		move.l	(a2)+,a0
		move.l	d0,-(a2)							; Swap
		move.l	a0,-(a2)							; Use current buffer

		; Get audio channel
		lea.l	mxsinglechan(a6),a6

		; Play current buffer
		move.l	a0,ac_ptr(a6)
		move.l	mixer+mx_hw_period(pc),ac_per(a6)	; Period & volume

		; Run mixer
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_CHUPD_COLOUR,$dff180
		ENDIF
				ENDM

		; Macro: MixSingIHend
		; This macro forms the end of the mixer audio interrupt handler in
		; case MIXER_SINGLE=1. Implemented as a macro for performance reasons
		; and to prevent double code.
MixSingIHend	MACRO
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_IH_COLOUR,$dff180
		ENDIF
		IF MIXER_68020=0
			movem.l	(sp)+,d0-d7/a0-a6		; Stack
		ELSE
			movem.l	(sp)+,d0-d3/d7/a0-a6	; Stack
		ENDIF
		IF MIXER_CIA_TIMER=1
			CIAStop
		ENDIF
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
		ENDIF
		rts
				ENDM

		; Macro: MixMultIHstart
		; This macro forms the start of the mixer audio interrupt handler in
		; case MIXER_MULTI=1 or MIXER_MULTI_PAIRED=1. Implemented as a macro
		; for performance reasons and to prevent double code.
MixMultIHstart	MACRO
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_IH_COLOUR,$dff180
		ENDIF
		IF MIXER_CIA_TIMER=1
			CIAStart
		ENDIF
		movem.l	d0-d7/a0-a6,-(sp)			; Stack

		; Fetch custombase & mixer / mixer entry / IRQ bits
		lea.l	mxcustombase,a6
		lea.l	mixer+mx_mixer_entries(pc),a1

		; Fetch current interrupts and mask out irrelevant ones
		move.w	intreqr(a6),d4
		and.w	mixer+mx_irq_bits(pc),d4

		; Set up for looping over each mixer entry
		moveq	#4-1,d7					; Check all channels
		move.w	#aud,d6
		moveq	#7,d5					; First audio interrupt bit

		; Loop over each mixer entry
.entry_lp
		IF MIXER_MULTI_PAIRED=1
			cmp.w	#10,d5
			bne.s	.test_channel_bit

			; Paired channel: get last buffer
			lea.l	mxe_buffers(a1),a2
			move.l	(a2),a0					; Get current buffer
			tst.w	mxe_active(a1)
			bne.s	.acknowledge_irq

			move.l	mixer+mx_empty_buffer(pc),a0
			bra.s	.acknowledge_irq
		ENDIF
.test_channel_bit
		btst	d5,d4						; Test if channel is active
		beq		.next_entry

		; Fetch and swap buffers
		lea.l	mxe_buffers(a1),a2
		move.l	(a2)+,d0					; Fetch
		move.l	(a2)+,a0
		move.l	d0,-(a2)					; Swap
		move.l	a0,-(a2)					; Use current buffer

.acknowledge_irq
		; Acknowledge interrupts
		moveq	#0,d4
		bset	d5,d4					; D4 = correct IRQ bit
		move.w	d4,intreq(a6)			; Acknowledge IRQ

		; Play current buffer
		move.l	a0,ac_ptr(a6,d6.w)
		move.l	mixer+mx_hw_period(pc),ac_per(a6,d6.w)	; Period & volume

		IF MIXER_MULTI_PAIRED=1
			; Skip mixing for the paired channel
			cmp.w	#10,d5
			beq		.end_handler
		ENDIF

		IF MIXER_68020=0
			movem.l	d4-d7,-(sp)				; Stack
		ELSE
			move.l	d7,-(sp)				; Stack
		ENDIF

		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_CHUPD_COLOUR,$dff180
		ENDIF
		; Run the mixer
				ENDM

		; Macro: MixMultIHend
		; This macro forms the end of the mixer audio interrupt handler in
		; case MIXER_MULTI=1 or MIXER_MULTI_PAIRED=1. Implemented as a macro
		; for performance reasons and to prevent double code.
MixMultIHend	MACRO
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_IH_COLOUR,$dff180
		ENDIF
		IF MIXER_68020=0
			movem.l	(sp)+,d4-d7				; Stack
		ELSE
			move.l	(sp)+,d7				; Stack
		ENDIF
		bra.s	.end_handler

.next_entry
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_IH_COLOUR,$dff180
		ENDIF

		; Fetch next entry & set up next audio channel
		IF MIXER_MULTI_PAIRED=1
			cmp.w	#9,d5
			beq.s	.paired_skip
		ENDIF
		lea.l	mxe_SIZEOF(a1),a1

.paired_skip
		addq.w	#1,d5						; Next channel bit to test
		add.w	#ac_SIZEOF,d6				; Next audio channel
		dbra	d7,.entry_lp

		; End of handler
.end_handler
		movem.l	(sp)+,d0-d7/a0-a6			; Stack
		IF MIXER_CIA_TIMER=1
			CIAStop
		ENDIF
		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_DEFAULT_COLOUR,$dff180
		ENDIF
		rts
				ENDM

;-----------------------------------------------------------------------------
; Mixer macros
;-----------------------------------------------------------------------------
		; Macro: MixSingleLongWord
		; This macro mixed a single longword to the given data register,
		; across the given number of channels.
		;
		; \1 - destination register number
		; \2 - number of channels to mix
MixSingleLongWord	MACRO
		add.l	(a3)+,\1
		IF \2>2
			add.l	(a4)+,\1
		ENDIF
		IF \2>3
			add.l	(a5)+,\1
		ENDIF
					ENDM

		; Macro: MixLongWords
		; This macro mixes 8 longwords (32 bytes) to all 8 data registers,
		; across the given number of channels.
		;
		; \1 number of channels to mix
MixLongWords		MACRO
		MixSingleLongWord d0,\1
		MixSingleLongWord d1,\1
		MixSingleLongWord d2,\1
		MixSingleLongWord d3,\1
		MixSingleLongWord d4,\1
		MixSingleLongWord d5,\1
		MixSingleLongWord d6,\1
		MixSingleLongWord d7,\1
					ENDM

		; Macro: MixCheckChannel
		; This macro checks the given channel and resets it if needed based
		; on remaining size.
		;
		; \1 - pointer to use
MixCheckChannel	MACRO
		; Update sample remaining length and check for underflows
		move.l	mxe_active_channels(a1,d0.w),a6
		IF mxslength_word=1
			move.w	mch_remaining_length(a6),d3	; D3 = remaining length
			sub.w	d2,d3						; Update remaining length
			bhi.s	.\@_write_remaining
		ELSE
			move.l	mch_remaining_length(a6),d3	; D3 = remaining length
			sub.l	d2,d3						; Update remaining length
			bgt.s	.\@_write_remaining
		ENDIF

		; Zero bytes remain
		clr.b	mch_status+1(a6)			; Clear active status for
											; non-looping samples
		IF mxslength_word=1
			move.w	mch_length(a6),d3		; Fetch total length
		ELSE
			move.l	mch_length(a6),d3		; Fetch total length
		ENDIF
		move.l	mch_loop_ptr(a6),\1			; Update pointer

.\@_write_remaining
		IF mxslength_word=1
			move.w	d3,mch_remaining_length(a6)	; Write remaining length
		ELSE
			move.l	d3,mch_remaining_length(a6)	; Write remaining length
		ENDIF
		move.l	\1,mch_sample_ptr(a6)		; Write sample pointer

		; Check if remaining length <= smallest remaining length
		IF mxslength_word=1
			cmp.w	d3,d1
			bls.s	.\@_next_channel

			move.w	d3,d1
		ELSE
			cmp.l	d3,d1
			ble.s	.\@_next_channel

			move.l	d3,d1
		ENDIF

.\@_next_channel
		addq.w	#4,d0
				ENDM

		; Macro: MixJump32
		; This macro determines how many blocks of 32 bytes need to be mixed
		; (up to mx_buffer_size)
		;
		; \1 - number of channels
MixJump32	MACRO
		; Push remaining length/bytes to process on stack
		move.w	d1,-(sp)
		move.w	d7,-(sp)
		move.w	d1,d6
		IF mxsize_x32=0
			and.w	#$ffe0,d6				; D6 = bytes to process
		ENDIF
		move.w	d6,a6						; Store bytes processed in A6

		; Calculate position in the jumptable
		asr.w	#3,d6
		jmp		.mix_\1ch_jmp_table32(pc,d6.w)
			ENDM

		; Macro: MixBlock32
		; This macro mixes in blocks of 32 bytes (up to mx_buffer_size)
		;
		; \1 - number of channels
MixBlock32	MACRO
		; The jump table below is dynamically generated based on the sample
		; buffer size & the size of a 32 byte mixing block.
.mix_\1ch_jmp_table32
		; Calculate maximum offset
.mix_\1ch_jmpoff32	EQU .mix_\1ch_32b+((mixer_32b_cnt-1)*.mix_\1ch_32b_sz)
		; Generate jump table
		IF mxsize_x32=1
			jmp	.mix_\1ch_calcrem4_st(pc)
		ELSE
			jmp	.mix_\1ch_4b_setup_st(pc)
		ENDIF
		REPT mixer_32b_cnt-1
		jmp	.mix_\1ch_jmpoff32-(REPTN*.mix_\1ch_32b_sz)(pc)
		ENDR

		; 1st block: 32 byte increments
.mix_\1ch_32b
		movem.l	(a2)+,d0-d7
		IF \1>1
			MixLongWords \1
		ENDIF
		movem.l	d0-d7,(a0)
		lea.l	32(a0),a0
.mix_\1ch_32b_single
.mix_\1ch_32b_sz	SET .mix_\1ch_32b_single-.mix_\1ch_32b

		REPT mixer_32b_cnt-1
		movem.l	(a2)+,d0-d7
		IF \1>1
			MixLongWords \1
		ENDIF
		movem.l	d0-d7,(a0)
		lea.l	32(a0),a0
		ENDR
			ENDM

		; Macro: MixChkRem32
		; This macro checks if any work still needs to be done after mixing in
		; blocks of 32 bytes.
		;
		; \1 - number of channels
MixChkRem32	MACRO
.mix_\1ch_chkrem32
		; Pull remaining length/remaining bytes to mix of the stack
		move.w	(sp)+,d7
		move.w	(sp)+,d1

		; Check processed byte count vs smallest remaining byte count
		cmp.w	a6,d1
		bne.s	.mix_\1ch_4b_setup
		bra		.mix_\1ch_calcrem4
				ENDM

		; Macro: MixJump4
		; This macro decides how many blocks of 4 bytes need to be mixed (up
		; to 32 bytes)
		;
		; \1 - number of channels
MixJump4	MACRO
.mix_\1ch_4b_setup_st
		; Update stack position
		lea.l	4(sp),sp

.mix_\1ch_4b_setup
		; Set up for the 4 byte blocks
		move.w	d1,d6
		sub.w	a6,d6						; Determine remaining amount of
											; bytes to proces.

		; Jump to the correct position in the jumptable
		jmp		.mix_\1ch_jmp_table4(pc,d6.w)
			ENDM

		; Macro: MixBlock4
		; This macro mixes up to 32 bytes of sample data.
		;
		; \1 - number of channels
MixBlock4	MACRO
.mix_\1ch_jmp_table4
		; Calculate maximum offset
.mix_\1ch_jmpoff4	EQU .mix_\1ch_4b+(6*.mix_\1ch_4b_sz)
		; Generate jump table
		jmp	.mix_\1ch_calcrem4(pc)
		REPT 6
		jmp	.mix_\1ch_jmpoff4-(REPTN*.mix_\1ch_4b_sz)(pc)
		ENDR

		; 2nd block: 4 byte increments
.mix_\1ch_4b
		IF \1=1
			move.l	(a2)+,(a0)+
		ENDIF
		IF \1>1
			move.l	(a2)+,d0
			MixSingleLongWord d0,\1
			move.l	d0,(a0)+
		ENDIF
.mix_\1ch_4b_single
.mix_\1ch_4b_sz	SET .mix_\1ch_4b_single-.mix_\1ch_4b

		REPT 6
		IF \1=1
			move.l	(a2)+,(a0)+
		ENDIF
		IF \1>1
			move.l	(a2)+,d0
			MixSingleLongWord d0,\1
			move.l	d0,(a0)+
		ENDIF
		ENDR
			ENDM

		; Macro: MixCalcRem4
		; This macro calculates how many longwords still need to be mixed and
		; checks & updates channels if needed.
		;
		; \1 - number of channels
MixCalcRem4	MACRO
.mix_\1ch_calcrem4_st
		IF mxsize_x32=1
			move.w	(sp)+,d7
			move.w	(sp)+,d1
		ENDIF
.mix_\1ch_calcrem4
		; Update remaining bytes & smallest remaining length
		IF mxslength_word=1
			move.w	d1,d2
			sub.w	d1,d7
			move.w	d7,d1
		ELSE
			ext.l	d1
			move.l	d1,d2
			sub.w	d1,d7
			move.w	d7,d1
		ENDIF

		; Reset channel counter
		moveq	#0,d0

		; Check all active channels
		MixCheckChannel a2
		IF \1>1
			MixCheckChannel a3
		ENDIF
		IF \1>2
			MixCheckChannel a4
		ENDIF
		IF \1>3
			MixCheckChannel a5
		ENDIF

		; Check if any bytes still need to be mixed
		tst.w	d1
		bne		.mix_\1ch_start
		bra		.mix_done
			ENDM

		; Macro: MixLoop020
		; This macro mixes the given number of channels together in a simple
		; loop. This is faster on 68020+ by making use of the instruction
		; cache.
		;
		; \1 - number of channels
MixLoop020	MACRO
		; Set up for loop
		move.w	d1,d3
		asr.w	#2,d3						; Convert to number of longwords
		subq.w	#1,d3

.mix_\1ch_lp
		IF \1=1
			move.l	(a2)+,(a0)+
		ENDIF
		IF \1>1
			move.l	(a2)+,d0
			MixSingleLongWord d0,\1
			move.l	d0,(a0)+
		ENDIF
		dbra	d3,.mix_\1ch_lp
			ENDM

		; Macro: MixBlockBufSize
		; This macro mixes the given number of channels together in a
		; single unrolled block that always mixes the full sample buffer
		; size in one go.
		;
		; \1 - number of channels
MixBlockBufSize	MACRO
		; Calculate block repetition counts
.mix_\1ch_pal_size_32		SET mixer_PAL_buffer_size&$ffe0
.mix_\1ch_ntsc_size_32		SET mixer_NTSC_buffer_size&$ffe0
.mix_\1ch_pal_diff_4		SET mixer_PAL_buffer_size-.mix_\1ch_pal_size_32
.mix_\1ch_ntsc_diff_4		SET mixer_NTSC_buffer_size-.mix_\1ch_ntsc_size_32

		; Check PAL/NTSC flag
		move.w	mixer+mx_vidsys(pc),d0
		bne		.mix_\1ch_blk_ntsc

		; PAL block (32 bytes)
		REPT (.mix_\1ch_pal_size_32)/32
			movem.l	(a2)+,d0-d7
			IF \1>1
				MixLongWords \1
			ENDIF
			movem.l	d0-d7,(a0)
			lea.l	32(a0),a0
		ENDR
		IF mxsize_x32=0
			; PAL block (4 bytes)
			REPT (.mix_\1ch_pal_diff_4)/4
				IF \1=1
					move.l	(a2)+,(a0)+
				ENDIF
				IF \1>1
					move.l	(a2)+,d0
					MixSingleLongWord d0,\1
					move.l	d0,(a0)+
				ENDIF
			ENDR
		ENDIF
		bra		.mix_done

.mix_\1ch_blk_ntsc
		; NTSC block
		REPT (.mix_\1ch_ntsc_size_32)/32
			movem.l	(a2)+,d0-d7
			IF \1>1
				MixLongWords \1
			ENDIF
			movem.l	d0-d7,(a0)
			lea.l	32(a0),a0
		ENDR
		IF mxsize_x32=0
			REPT (.mix_\1ch_ntsc_diff_4)/4
				IF \1=1
					move.l	(a2)+,(a0)+
				ENDIF
				IF \1>1
					move.l	(a2)+,d0
					MixSingleLongWord d0,\1
					move.l	d0,(a0)+
				ENDIF
			ENDR
		ENDIF
		bra		.mix_done
				ENDM

		; Macro: MixUpdateChannel
		; This macro checks if a channel is active and adds it to the channels
		; to be mixed if so. Active channels age value is updated.
MixUpdateChannel	MACRO
		tst.w	mch_status(a2)
		beq.s	.\@_done

		; Sample is active (one-shot or looping)
		IF mxslength_word=1
			move.w	mch_remaining_length(a2),d2	; Fetch remaining length
		ELSE
			move.l	mch_remaining_length(a2),d2	; Fetch remaining length
		ENDIF
		addq.w	#1,mch_age(a2)				; Update age
		move.l	a2,(a3)+					; Write channel & sample pointers
		move.l	mch_sample_ptr(a2),(a4)+

		; Update smallest remaining size if needed
		IF mxslength_word=1
			cmp.w	d2,d1
			bls.s	.\@_update_channel

			move.w	d2,d1
		ELSE
			cmp.l	d2,d1
			ble.s	.\@_update_channel

			move.l	d2,d1
		ENDIF

.\@_update_channel
		; Increase channel count
		addq.w	#4,d0

.\@_done
		; Fetch next channel
		lea.l	mch_SIZEOF(a2),a2
					ENDM

		; Macro: MixUpdateChannelBufSize
		; This macro checks if a channel is active and adds it to the channels
		; to be mixed if so. Active channels age value is updated.
		; This version is for mixing in blocks of the buffer size.
MixUpdateChannelBufSize	MACRO
		tst.w	mch_status(a2)
		beq.s	.\@_done

		; Sample is active (one-shot or looping)
		IF mxslength_word=1
			sub.w	d7,mch_remaining_length(a2)	; Update remaining length
			bcc.s	.\@_active_channel

			; Reset remaining length & active status
			clr.b	mch_status+1(a2)
			move.w	mch_length(a2),mch_remaining_length(a2)
			move.l	mch_loop_ptr(a2),mch_sample_ptr(a2)
		ELSE
			sub.l	d7,mch_remaining_length(a2)	; Update remaining length
			bge.s	.\@_active_channel

			; Reset remaining length & active status
			clr.b	mch_status+1(a2)
			move.l	mch_length(a2),mch_remaining_length(a2)
			move.l	mch_loop_ptr(a2),mch_sample_ptr(a2)
		ENDIF

.\@_active_channel
		move.l	mch_sample_ptr(a2),a6
		IF mxslength_word=1
			add.w	d7,a6
		ELSE
			add.l	d7,a6
		ENDIF
		move.l	a6,mch_sample_ptr(a2)
		addq.w	#1,mch_age(a2)				; Update age
		move.l	a6,(a4)+

.\@_update_channel
		; Increase channel count
		addq.w	#4,d0

.\@_done
		; Fetch next channel
		lea.l	mch_SIZEOF(a2),a2
						ENDM

		; Macro: MixUpdateChannels
		; This macro checks if all channels are active and adds them to the
		; channels to be mixed if so. Active channels age value is updated.
MixUpdateChannels	MACRO
		; Fetch pointers & buffer size
		lea.l	mxe_channels(a1),a2
		IF MIXER_68020=0
			IF MIXER_SIZEXBUF=0
				lea.l	mxe_active_channels(a1),a3
			ENDIF
		ELSE
			lea.l	mxe_active_channels(a1),a3
		ENDIF
		lea.l	mxe_pointers(a1),a4

		; Clear channel counter & set minimum length/buffer size
		moveq	#0,d0
		move.w	mixer+mx_buffer_size(pc),d1

		; Set maximum length
		IF mxslength_word=1
			move.w	d1,d7
		ELSE
			ext.l	d1
			move.l	d1,d7
		ENDIF

		; Update each channel
		IF MIXER_68020=1
			moveq	#mixer_sw_channels-1,d3

.mix_upd_ch_lp
			MixUpdateChannel
			dbra	d3,.mix_upd_ch_lp
		ELSE
			REPT mixer_sw_channels
				IF MIXER_SIZEXBUF=1
					MixUpdateChannelBufSize
				ELSE
					MixUpdateChannel
				ENDIF
			ENDR
		ENDIF
					ENDM

		; Macro: MixChannels
		; This macro mixes all active channels
MixChannels		MACRO
		; Select number of channels to mix
		jmp		.jmp_table(pc,d0.w)
.jmp_table
		jmp		.mix_silence(pc)			; 0
		jmp		.mix_copy_only(pc)			; 1
		IF mixer_sw_channels>1
			jmp		.mix_2_channels(pc)		; etc
		ENDIF
		IF mixer_sw_channels>2
			jmp		.mix_3_channels(pc)
		ENDIF
		IF mixer_sw_channels>3
			jmp		.mix_4_channels(pc)
		ENDIF

.mix_silence
		IF MIXER_SINGLE=1
			lea.l	mxcustombase,a6
			lea.l	mxsinglechan(a6),a6
			move.l	mixer+mx_empty_buffer(pc),ac_ptr(a6)
			move.w	mixer+mx_hw_period(pc),ac_per(a6)
		ELSE
			lea.l	mxcustombase,a6
			move.l	mixer+mx_empty_buffer(pc),ac_ptr(a6,d6.w)
			move.w	mixer+mx_hw_period(pc),ac_per(a6,d6.w)
			IF MIXER_MULTI_PAIRED=1
				move.w	#0,mxe_active(a1)
			ENDIF
		ENDIF
		bra		.mix_done

.mix_copy_only
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Fetch source pointers
		move.l	mxe_pointers(a1),a2

.mix_1ch_start
		; Mix the channels
		IF MIXER_SIZEXBUF=1
			MixBlockBufSize 1
		ELSE
			MixJump32 1
			MixBlock32 1
			MixChkRem32 1
			MixJump4 1
			MixBlock4 1
			MixCalcRem4 1
		ENDIF

	IF mixer_sw_channels>1
.mix_2_channels
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Fetch source pointers
		movem.l	mxe_pointers(a1),a2/a3

.mix_2ch_start
		; Mix the channels
		IF MIXER_SIZEXBUF=1
			MixBlockBufSize 2
		ELSE
			MixJump32 2
			MixBlock32 2
			MixChkRem32 2
			MixJump4 2
			MixBlock4 2
			MixCalcRem4 2
		ENDIF
	ENDIF

	IF mixer_sw_channels>2
.mix_3_channels
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Fetch source pointers
		movem.l	mxe_pointers(a1),a2/a3/a4

.mix_3ch_start
		; Mix the channels
		IF MIXER_SIZEXBUF=1
			MixBlockBufSize 3
		ELSE
			MixJump32 3
			MixBlock32 3
			MixChkRem32 3
			MixJump4 3
			MixBlock4 3
			MixCalcRem4 3
		ENDIF
	ENDIF

	IF mixer_sw_channels>3
.mix_4_channels
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Fetch source pointers
		movem.l	mxe_pointers(a1),a2/a3/a4/a5

.mix_4ch_start
		; Mix the channels
		IF MIXER_SIZEXBUF=1
			MixBlockBufSize 4
		ELSE
			MixJump32 4
			MixBlock32 4
			MixChkRem32 4
			MixJump4 4
			MixBlock4 4
			MixCalcRem4 4
		ENDIF
	ENDIF

.mix_done
		; End of mixing
				ENDM

		; Macro: MixChannels020
		; This macro mixes all channels (68020+ optimised version)
MixChannels020	MACRO
		; Select number of channels to mix
		jmp		.jmp_table(pc,d0.w)

.jmp_table
		jmp		.mix_silence(pc)			; 0
		jmp		.mix_copy_only(pc)			; 1
		IF mixer_sw_channels>1
			jmp		.mix_2_channels(pc)		; etc
		ENDIF
		IF mixer_sw_channels>2
			jmp		.mix_3_channels(pc)
		ENDIF
		IF mixer_sw_channels>3
			jmp		.mix_4_channels(pc)
		ENDIF

.mix_silence
		IF MIXER_SINGLE=1
			lea.l	mxcustombase,a6
			lea.l	mxsinglechan(a6),a6
			move.l	mixer+mx_empty_buffer(pc),ac_ptr(a6)
			move.w	mixer+mx_hw_period(pc),ac_per(a6)
		ELSE
			lea.l	mxcustombase,a6
			move.l	mixer+mx_empty_buffer(pc),ac_ptr(a6,d6.w)
			move.w	mixer+mx_hw_period(pc),ac_per(a6,d6.w)
			IF MIXER_MULTI_PAIRED=1
				move.w	#0,mxe_active(a1)
			ENDIF
		ENDIF
		bra		.mix_done

.mix_copy_only
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Setup
		move.l	mxe_pointers(a1),a2			; Fetch pointer

.mix_1ch_start
		; Mix channels
		MixLoop020 1
		MixCalcRem4 1

	IF mixer_sw_channels>1
.mix_2_channels
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Setup
		movem.l	mxe_pointers(a1),a2/a3		; Fetch pointers

.mix_2ch_start
		; Mix channels
		MixLoop020 2
		MixCalcRem4 2
	ENDIF

	IF mixer_sw_channels>2
.mix_3_channels
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Setup
		movem.l	mxe_pointers(a1),a2/a3/a4	; Fetch pointers

.mix_3ch_start
		; Mix channels
		MixLoop020 3
		MixCalcRem4 3
	ENDIF

	IF mixer_sw_channels>3
.mix_4_channels
		IF MIXER_MULTI_PAIRED=1
			move.w	#1,mxe_active(a1)
		ENDIF

		; Setup
		movem.l	mxe_pointers(a1),a2/a3/a4/a5; Fetch pointers

.mix_4ch_start
		; Mix channels
		MixLoop020 4
		MixCalcRem4 4

.mix_4ch_done
	ENDIF

.mix_done
		; End of mixing
				ENDM

;-----------------------------------------------------------------------------
; Interrupt handler / mixing routines
;-----------------------------------------------------------------------------
		; Routine: MixerIRQHandler
		; This routine is the interrupt handler for the mixer. It reacts to
		; audio interrupts, mixes the mixer channels and plays back the audio.
		;
		; The mixing routines use double buffering, where one buffer is played
		; back while the next buffer is being mixed.
		;
		; Note: for performance reasons, the code to handle various mixer types
		;       has been implemented as macros. The handler merely combines
		;       these into the correct variant as set up in mixer_config.i.
MixerIRQHandler
		; Interrupt handler start
		IF MIXER_SINGLE=1
			MixSingIHstart
		ELSE
			MixMultIHstart
		ENDIF

		; Update & mix channels
		MixUpdateChannels

		IF MIXER_TIMING_BARS=1
			move.w	#MIXER_AUD_COLOUR,$dff180
		ENDIF

		IF MIXER_68020=1
			MixChannels020
		ELSE
			MixChannels
		ENDIF

		; Interrupt handler end
		IF MIXER_SINGLE=1
			MixSingIHend
		ELSE
			MixMultIHend
		ENDIF

;-----------------------------------------------------------------------------
; Support routines
;-----------------------------------------------------------------------------

		; Routine: MixerGetBufferSize
		; This routine returns the value of mixer_buffer_size, the required
		; size of the Chip RAM buffer that needs to be allocated and passed to
		; MixerSetup().
		;
		; It's primary purpose is to give C programs a way to get this value
		; without needing access to mixer.i
		;
		; Returns
		; D0 - value of mixer_buffer_size
MixerGetBufferSize
		move.l	#mixer_buffer_size,d0
		rts

		; Routine: MixerGetSampleMinSize
		; This routine returns the miminum sample size. This is the minimum
		; sample size the mixer can play back correctly. Samples must always
		; be a multiple of this value in length.
		;
		; Normally this value is 4, but optimisation options in mixer_config.i
		; can increase this.
		;
		; Note: MixerSetup() must have been called prior to calling this
		;       routine.
		;
		; Returns
		; D0 - minimum sample size
MixerGetSampleMinSize
		move.l	a0,-(sp)					; Stack
		lea.l	mixer(pc),a0

		; Preload PAL value
		moveq	#0,d0
		move.w	#mixer_PAL_multiple,d0
		tst.w	mx_vidsys(a0)
		beq.s	.done

		; NTSC value
		move.w	#mixer_NTSC_multiple,d0

.done	move.l	(sp)+,a0					; Stack
		rts

		; Routine: MixerPlaySilence
		; This routine plays the silent (empty) buffer via Paula.
		;
		; D1 - Hardware channel to play silence on
MixerPlaySilence
		movem.l	d0/d1/a0/a6,-(sp)			; Stack

		; Fetch audio channel
		lea.l	mxcustombase,a6

		; Get empty buffer & buffer size in words
		lea.l	mixer(pc),a0

		; Set audio register values
		move.l	mx_empty_buffer(a0),ac_ptr(a6,d1.w)
		move.w	mx_buffer_size_w(a0),ac_len(a6,d1.w)
		move.w	mx_hw_period(a0),ac_per(a6,d1.w)
		move.w	mx_volume(a0),ac_vol(a6,d1.w)

		; Calculate audio bit to set
		; sub.w	#aud,d1
		; asr.w	#4,d1
		; move.w	#DMAF_SETCLR,d0
		; bset	d1,d0

		; Activate audio DMA
		; move.w	d0,dmacon(a6)
		movem.l	d0/d1/a0/a1,-(sp)			; Stack
		jsr mixerEnableAudioDma
		movem.l	(sp)+,d0/d1/a0/a1			; Stack

		movem.l	(sp)+,d0/d1/a0/a6			; Stack
		rts

		; Routine: MixerClearBuffer
		; This routine clears the given buffer to zero.
		; Note: this routine is not speed optimized.
		;
		; A0 - Pointer to buffer to clear
MixerClearBuffer
		movem.l	d0/d7/a0/a1,-(sp)			; Stack

		; Fetch buffer size in longwords
		lea.l	mixer(pc),a1
		move.w	mx_buffer_size(a1),d7

		; Prepare for loop
		moveq	#0,d0
		asr.w	#2,d7
		subq.w	#1,d7

		; Loop over longwords in the buffer
.lp		move.l	d0,(a0)+
		dbra	d7,.lp

		movem.l	(sp)+,d0/d7/a0/a1			; Stack
		rts

		; Routine: MixerCalcTicks
		; This routine calculates the average tick time over the rolling
		; 128 entry buffer. It also converts the recorded CIA timer values to
		; to CIA ticks ($ffff-CIA timer value = CIA ticks).
		;
		; Note: only functions if MIXER_CIA_TIMER is set to 1
		; Note: values only accurate if mixer has been running and playing
		;       back sample data at least 128 frames.
MixerCalcTicks
		IF MIXER_CIA_TIMER=1
			movem.l	d0/d1/d7/a0,-(sp)		; Stack

			; Fetch the buffer
			lea.l	mixer_ticks_storage(pc),a0

			; Set up for loop
			moveq	#0,d0
			moveq	#128-1,d7

			; Loop over all entries
.lp			moveq	#0,d1
			move.w	(a0)+,d1
			add.l	d1,d0
			dbra	d7,.lp

			; Calculate average
			divu.w	#128,d0
			lea.l	mixer_ticks_average(pc),a0
			move.w	d0,(a0)

			; Calculate CIA ticks from CIA timer values recorded
			; This is needed because the CIA timer values run from $ffff to 0,
			; so the values recorded are inverted from the actual number of
			; ticks that have elapsed.
			lea.l	mixer_ticks_last(pc),a0
			moveq	#4-1,d7

			; Loop over the results
.lp2		moveq	#-1,d1
			move.w	(a0),d0
			sub.w	d0,d1
			move.w	d1,(a0)+
			dbra	d7,.lp2

			movem.l	(sp)+,d0/d1/d7/a0		; Stack
		ENDIF
		rts

; Mixer data
		cnop	0,4
mixer					blk.b	mx_SIZEOF
		IF MIXER_68020=1
			cnop	0,4
		ENDIF
mixer_stored_vbr		dc.l	0
mixer_stored_handler	dc.l	0
mixer_stored_intena		dc.w	0
		IF MIXER_CIA_TIMER=1
mixer_stored_cia		dc.w	0
mixer_ticks_last		dc.w	0
mixer_ticks_best		dc.w	0
mixer_ticks_worst		dc.w	$ffff
mixer_ticks_average		dc.w	0
mixer_ticks_storage_off	dc.w	0
mixer_ticks_storage		blk.w	128
		ENDIF

		IF MIXER_C_DEFS=1
; C style routine aliases
_MixerGetBufferSize		EQU	MixerGetBufferSize
_MixerSetup				EQU MixerSetup
_MixerInstallHandler	EQU MixerInstallHandler
_MixerRemoveHandler		EQU MixerRemoveHandler
_MixerStart				EQU MixerStart
_MixerStop				EQU MixerStop
_MixerVolume			EQU MixerVolume
_MixerPlayFX			EQU MixerPlayFX
_MixerPlayChannelFX		EQU MixerPlayChannelFX
_MixerStopFX			EQU MixerStopFX
_MixerPlaySample		EQU MixerPlaySample
_MixerPlayChannelSample	EQU MixerPlayChannelSample
_MixerGetSampleMinSize	EQU MixerGetSampleMinSize
_MixerIRQHandler		EQU MixerIRQHandler
_mixer				EQU mixer

	XDEF	_MixerGetBufferSize
	XDEF	_MixerSetup
	XDEF	_MixerInstallHandler
	XDEF	_MixerRemoveHandler
	XDEF	_MixerStart
	XDEF	_MixerStop
	XDEF	_MixerVolume
	XDEF	_MixerPlayFX
	XDEF	_MixerPlayChannelFX
	XDEF	_MixerStopFX
	XDEF	_MixerPlaySample
	XDEF	_MixerPlayChannelSample
	XDEF	_MixerGetSampleMinSize
	XDEF	_MixerIRQHandler
	XDEF	_mixer
		ENDIF

	ENDIF
; End of File
