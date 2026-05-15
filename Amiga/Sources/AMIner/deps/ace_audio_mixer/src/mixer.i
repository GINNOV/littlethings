; $VER: mixer.i 3.1 (17.03.23)
;
; mixer.i
; Include file for mixer.asm
;
; Note: all mixer configuration is done via mixer_config.i, please do not edit
;       the constants in this file.
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
;          the PAL or NTSC buffer size in length (depending on the video
;          system passed to MixerSetup())
;       *) if MIXER_SIZEX32 and MIXER_SIZEXBUF are set to one, the samples
;          need to be a multiple of the PAL/NTSC buffer size and a multiple of
;          32 bytes in length (depending on the video system passed to
;          MixerSetup())
;
;       The file mixer.i contains the equates mixer_PAL_multiple and 
;       mixer_NTSC_multiple which give the exaxt multiple requirements for
;       samples. Note that in most cases these two will be the same value,
;       only if MIXER_SIZEXBUF is set to 1 the number will be different 
;       between these two.
; 
; Mixer API (see mixer documentation for more information)
; -------------------------------------------------------------
;
; MixerSetup(A0=buffer,D0=video_system.w)
;	Prepares the mixer structure for use by the mixing routines and sets mixer
;   playback volume to the maximum hardware volume of 64. Must be called prior
;   to any other mixing routines. A0 must point to a block of memory in Chip 
;   RAM at least mixer_buffer_size bytes in size. D0 must contain either 
;   MIX_PAL if running on a PAL system, or MIX_NTSC when running on a NTSC 
;   system.
;
;   If the video system is unknown, set D0 to MIX_PAL.
;
;   Note: on 68020+ systems, it is advisable to align the Chip RAM buffer to a
;         4 byte boundary for optimal performance.
; 
; MixerInstallHandler(A0=VBR,D0=save_vector.w)
;	Sets up the mixer interrupt handler. MixerSetup must be called prior to
;	calling this routine. Pass the VBR or zero in A0. D0 controls whether or 
;   not the old interrupt vector will be saved. Set it to 0 to save the vector
;   for future restoring and to 1 to skip saving the vector.
;
; MixerRemoveHandler()
;   Removes the mixer interrupt handler. MixerStop should be called prior to
;	calling this routine to make sure audio DMA is stopped.
;
; MixerStart()
;	Starts mixer playback (initially playing back silence). MixerSetup and 
;	MixerInstallHandler must have been called prior to calling this routine.
;
;   Note: if MIXER_CIA_TIMER is set to 1, this routine also starts the CIA 
;         timer to measure performance metrics.
;
; MixerStop()
;	Stops mixer playback. MixerSetup and MixerInstallHandler must have been 
;   called prior to calling this routine.
;
;   Note: if MIXER_CIA_TIMER is set to 1, this routine also stops the CIA
;         timer used to measure performance metrics. The results are found in
;         mixer_ticks_last, mixer_ticks_best and mixer_ticks_worst (these 
;         variables are not available if MIXER_CIA_TIMER is set to 0).
;
; MixerVolume(D0=volume.w)
;   Set the desired hardware output volume used by the mixer (valid values are
;   0 to 64).
;
; D0=MixerPlayFX(A0=effect_structure,D0=hardware_channel)
;   Adds the sample defined in the MXEffect structure pointed to by A0 on the 
;   the hardware channel given in D0. If MIXER_SINGLE is set to 1, the 
;   hardware channel does not need to be given in D0. Determines the best
;   mixer channel to play back on based on priority and age. If no applicable
;   channel is free (for instance due to higher priority samples playing), the
;   routine will not play the sample.
;
;   D0 returns the hardware & mixer channel the sample will play on, or -1 if
;   no free channel could be found.
;
;   Note: the MXEffect structure definition can be found at the bottom of 
;         mixer.i, values are as described at the MixerPlaySample routine.
;
; D0=MixerPlayChannelFX(A0=effect_structure,D0=mixer_channel)
;   Adds the sample defined in the MXEffect structure pointed to by A0 on the 
;   the hardware and mixer channel given in D0. If MIXER_SINGLE is set to 1, 
;   the hardware channel does not need to be given in D0, but the mixer 
;   channel must still be set. Determines whether to play back the sample 
;   based on priority and age. If the channel isn't free (for instance due to
;   a higher priority sample playing), the routine will not play the sample.
;
;   D0 returns the hardware & mixer channel the sample will play on, or -1 if
;   no free channel could be found.
;
;   Note: the MXEffect structure definition can be found at the bottom of 
;         mixer.i, values are as described at the MixerPlaySample routine.
;   Note: a mixer channel refers to the internal virtual channels the mixer 
;         uses to mix samples together. By exposing these virtual channels, 
;         more fine grained control over playback becomes possible.
;
;         Mixer channels range from MIX_CH0 to MIX_CH3, depending on the 
;         maximum number of software channels available as defined in 
;         mixer_config.i.
;
; MixerStopFX(D0=mixer_channel_mask)
;   Stops playback on the given hardware/mixer channel combination in D0. If
;   MIXER_SINGLE is set to 1, the hardware channel does not need to be given
;   in D0, but the mixer channel must still be set. If MIXER_MULTI or 
;   MIXER_MULTI_PAIRED are set to 1, multiple hardware channels can be 
;   selected at the same time. In this case the playback is stopped on the 
;   given mixer channels across all selected hardware channels.
;
;   Note: see MixerPlayChannelFX for an explanation of mixer channels.
;
; D0=MixerPlaySample(A0=sample,D0=hardware_channel,D1=length,
;                    D2=signed_priority.w,D3=loop_indicator.w)
;   Adds the sample pointed to by A0 on the hardware channel given in D0. If 
;   MIXER_SINGLE is set to 1, the hardware channel does not need to be given 
;   in D0. Determines the best mixer channel to play back on based on priority
;   and age. If no applicable channel is free (for instance due to higher 
;   priority samples playing), the routine will not play the sample.
;
;   Other values that need to be set are D1, which sets the length of the 
;   sample (signed long, unless MIXER_WORDSIZED is set to 1, in which case the
;   length is an unsigned word). D2 gives the desired priority of the sample.
;   Samples of higher priority can overwrite already playing samples of lower
;   priority if no free mixer channel can be found. D3 has to contain either 
;   MIX_FX_ONCE for samples that need to play once, or MIX_FX_LOOP for samples
;   that should loop forever. Looping samples can only be stopped by either 
;   calling MixerStop or MixerStopFX.
;
;   D0 returns the hardware & mixer channel the sample will play on, or -1 if
;   no free channel could be found.
;
; D0=MixerPlayChannelSample(A0=sample,D0=mixer_channel,D1=length,
;                           D2=signed_priority.w,D3=loop_indicator.w)
;   Adds the sample pointed to by A0 on the hardware/mixer channel given in 
;   D0. If MIXER_SINGLE is set to 1, the hardware channel does not need to be 
;   given in D0. Determines whether to play back the sample based on priority
;   and age. If the channel isn't free (for instance due to a higher priority
;   sample playing), the routine will not play the sample.
;
;   Other values that need to be set are D1, which sets the length of the 
;   sample (signed long, unless MIXER_WORDSIZED is set to 1, in which case the
;   length is an unsigned word). D2 gives the desired priority of the sample.
;   Samples of higher priority can overwrite already playing samples of lower
;   priority if no free mixer channel can be found. D3 has to contain either 
;   MIX_FX_ONCE for samples that need to play once, or MIX_FX_LOOP for samples
;   that should loop forever. Looping samples can only be stopped by either 
;   calling MixerStop or MixerStopFX.
;
;   D0 returns the hardware & mixer channel the sample will play on, or -1 if
;   no free channel could be found.
;
;   Note: see MixerPlayChannelFX for an explanation of mixer channels.
;
; D0=MixerGetBufferSize()
;	Returns the size of the Chip RAM buffer size that needs to be allocated
;	and passed to MixerSetup(). Note that this routine merely returns the
;	value of mixer_buffer_size, which is defined in mixer.i. The function of
;	this routine is to offer a method for C programs to gain access to this
;	value without needing access to mixer.i.
;
; D0=MixerGetSampleMinSize()
;	Returns the minimum sample size. This is the minimum sample size the mixer
;   can play back correctly. Samples must always be a multiple of this value 
;   in length.
;
;	Normally this value is 4, but optimisation options in mixer_config.i can
;	can increase this.
;
;	Note: this routine is usually not needed as the minimum sample size is 
;	      implied by the mixer_config.i setup. Its primary function is to give
;	      the correct value in case MIXER_SIZEXBUF has been set to 1 in 
;	      mixer_config.i, in which case the minimum sample size will depend on
;	      the video system selected when calling MixerSetup (PAL or NTSC).
; 	Note: MixerSetup() must have been called prior to calling this routine.
;
; If MIXER_CIA_TIMER is set to 1, an additional routine is available:
; MixerCalcTicks()
;   Calculates the average number of CIA ticks that passed during the last 128
;   calls of the mixer interrupt handler. Results are found in 
;   mixer_ticks_average.
;
;
; Author: Jeroen Knoester
; Version: 3.1
; Revision: 20230317
;
; Assembled using VASM in Amiga-link mode.
; TAB size = 4 spaces

; Includes (OS includes assume at least NDK 1.3) 
	include	exec/types.i
	include hardware/dmabits.i
	
	include mixer_config.i
	
	IFND	MIXER_I
MIXER_I	SET	1

; References
	XREF	MixerSetup
	XREF	MixerInstallHandler
	XREF	MixerRemoveHandler
	XREF	MixerStart
	XREF	MixerStop
	XREF	MixerVolume

	XREF	MixerPlayFX
	XREF	MixerPlayChannelFX
	XREF	MixerStopFX
	
	XREF	MixerPlaySample
	XREF	MixerPlayChannelSample
	
	XREF	MixerGetBufferSize
	XREF	MixerGetSampleMinSize

	IF MIXER_CIA_TIMER=1
		XREF	MixerCalcTicks

		XREF	mixer_ticks_last
		XREF	mixer_ticks_best
		XREF	mixer_ticks_worst
		XREF	mixer_ticks_average
	ENDIF
	
	XREF	mixer

; Constants
MIX_PAL					EQU	0				; Amiga system type
MIX_NTSC				EQU	1				
	
MIX_FX_ONCE				EQU	1				; Play back FX once
MIX_FX_LOOP				EQU	-1				; Play back FX as continous loop
	
MIX_CH0					EQU	16				; Mixer software channel 0
MIX_CH1					EQU	32				; ..
MIX_CH2					EQU	64				; ..
MIX_CH3					EQU	128				; Mixer software channel 3

mixer_output_aud0	EQU	mixer_output_channels&1
mixer_output_aud1	EQU	(mixer_output_channels>>1)&1
mixer_output_aud2	EQU	(mixer_output_channels>>2)&1
mixer_output_aud3	EQU	(mixer_output_channels>>3)&1
mixer_output_count	EQU	mixer_output_aud0+mixer_output_aud1+mixer_output_aud2+mixer_output_aud3

mixer_PAL_cycles 		EQU	3546895
mixer_NTSC_cycles		EQU	3579545

	IF MIXER_PER_IS_NTSC=0
mixer_PAL_period		EQU	mixer_period
mixer_NTSC_period		EQU (mixer_period*mixer_NTSC_cycles)/mixer_PAL_cycles
	ELSE
mixer_NTSC_period		EQU	mixer_period
mixer_PAL_period		EQU (mixer_period*mixer_PAL_cycles)/mixer_NTSC_cycles
	ENDIF

; Note: do not use mixer_PAL_buffer_size or mixer_NTSC_buffer_size below to
;       get the buffer size, always refer to mixer_buffer_size instead as the
;       mixer internally requires multiple buffers to work correctly and
;       mixer_buffer_size takes this into account.
	IF MIXER_68020=0
		IF MIXER_SIZEX32=1
mixer_PAL_buffer_size	EQU	((mixer_PAL_cycles/mixer_PAL_period/50)&65504)+32
mixer_NTSC_buffer_size	EQU	((mixer_NTSC_cycles/mixer_NTSC_period/60)&65504)+32
		ELSE
mixer_PAL_buffer_size	EQU	((mixer_PAL_cycles/mixer_PAL_period/50)&65532)+4
mixer_NTSC_buffer_size	EQU	((mixer_NTSC_cycles/mixer_NTSC_period/60)&65532)+4
		ENDIF
	ELSE
mixer_PAL_buffer_size	EQU	((mixer_PAL_cycles/mixer_PAL_period/50)&65532)+4
mixer_NTSC_buffer_size	EQU	((mixer_NTSC_cycles/mixer_NTSC_period/60)&65532)+4
	ENDIF

; Note: use mixer_buffer_size to get the correct size for the mixer Chip RAM
;       block to allocate.
mixer_buffer_size		EQU	mixer_PAL_buffer_size*(1+(mixer_output_count*2))
mixer_32b_cnt			EQU mixer_PAL_buffer_size/32

.mixer_sam_mult			SET 4
.mixer_sam_mult_ntsc	SET 4
	IF MIXER_SIZEX32=1
.mixer_sam_mult			SET 32
.mixer_sam_mult_ntsc	SET 32
	ENDIF
	IF MIXER_SIZEXBUF=1
.mixer_sam_mult			SET mixer_PAL_buffer_size
.mixer_sam_mult_ntsc	SET mixer_NTSC_buffer_size
	ENDIF
mixer_PAL_multiple		EQU .mixer_sam_mult
mixer_NTSC_multiple		EQU .mixer_sam_mult_ntsc
	
; Structures
 STRUCTURE MXChannel,0
	IF MIXER_68020=0
		  IF MIXER_WORDSIZED=1
			UWORD	mch_remaining_length
			UWORD	mch_length
		ELSE
			LONG	mch_remaining_length
			LONG	mch_length
		ENDIF
	ELSE
		LONG	mch_remaining_length
		LONG	mch_length
	ENDIF
	APTR	mch_sample_ptr
	APTR	mch_loop_ptr
	UWORD	mch_status
	UWORD	mch_priority
	UWORD	mch_age
	IF MIXER_68020=1
		UWORD	mch_align
	ENDIF
	LABEL	mch_SIZEOF
	
 STRUCTURE MXMixerEntry,0
	STRUCT	mxe_channels,mch_SIZEOF*4
	STRUCT	mxe_active_channels,4*4
	STRUCT	mxe_pointers,4*4
	STRUCT	mxe_buffers,4*2
	IF MIXER_MULTI_PAIRED=1
		UWORD	mxe_active
		IF MIXER_68020=1
			UWORD	mxe_align
		ENDIF
	ENDIF
	LABEL	mxe_SIZEOF

 STRUCTURE MXMixer,0
	IF MIXER_SINGLE=1
		STRUCT	mx_mixer_entries,mxe_SIZEOF
	ELSE
		STRUCT	mx_mixer_entries,mxe_SIZEOF*4
	ENDIF
	APTR	mx_empty_buffer
	UWORD	mx_buffer_size
	UWORD	mx_buffer_size_w
	UWORD	mx_irq_bits
	UWORD	mx_hw_channels
	UWORD	mx_hw_period
	UWORD	mx_volume
	UWORD	mx_status
	UWORD	mx_vidsys
	LABEL	mx_SIZEOF

 STRUCTURE MXEffect,0	
	LONG	mfx_length						; Note: the sample length can be
											; both long or unsiged word 
											; depending on the setting of
											; MIXER_WORDSIZED.
	APTR	mfx_sample_ptr
	UWORD	mfx_loop
	UWORD	mfx_priority
	LABEL	mfx_SIZEOF
	
	ENDC	; MIXER_I
; End of File