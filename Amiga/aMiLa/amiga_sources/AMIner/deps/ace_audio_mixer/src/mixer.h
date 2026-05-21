/*
 * mixer.h
 *
 * This is the C header file for the Audio Mixer. The Audio Mixer is written
 * in assembly, this header file offers an interface to the assembly routines.
 * As supplied, the header file should work for VBCC and Bebbo's GCC compiler.
 *
 * To use the Audio Mixer in C programs, the mixer.asm file still must be
 * assembled into an object file, with mixer_config.i set up correctly for the
 * desired use.
 *
 * Note: in mixer_config.i, the value MIXER_C_DEFS must be set to 1 for this
 *       header file to work.
 *
 * Author: Jeroen Knoester
 * Version: 3.1
 * Revision: 20230319
 *
 * TAB size = 4 spaces
 */
#ifndef MIXER_H
#define MIXER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* Constants */
#define MIX_PAL  0			/* Amiga system type */
#define MIX_NTSC 1

#define MIX_FX_ONCE  1		/* Play back FX once */
#define MIX_FX_LOOP -1		/* Play back FX as continous loop */

#define MIX_CH0  16			/* Mixer software channel 0 */
#define MIX_CH1	 32			/* .. */
#define MIX_CH2	 64			/* .. */
#define MIX_CH3	128			/* Mixer software channel 3 */

/* Types */

typedef struct MXEffectStructure
{
	LONG mfx_length;		/* Length of sample */
	void *mfx_sample_ptr;	/* pointer to sample in any RAM (even address) */
	UWORD mfx_loop;			/* Loop indicator (MIX_FX_ONCE or MIX_FX_LOOP) */
	UWORD mfx_priority;		/* Priority indicator (higher is better) */
} MXEffectStructure;


/* REGARG define to call assembly routines */
#if defined(BARTMAN_GCC) || defined(__INTELLISENSE__)
// Exploit the fact that Bartman's compiler doesn't add underscore to its C symbols and use them to call underscored mixer function from asm side
#define MIX_API __attribute__((always_inline)) static inline
#define MIX_REGARG(arg, reg) arg
#elif defined(__VBCC__)
#define MIX_API
#define MIX_REGARG(arg, reg) __reg(reg) arg
#elif defined(__GNUC__) // Bebbo
#define MIX_API
#define MIX_REGARG(arg, reg) arg asm(reg)
#endif

/* Prototypes */

MIX_API void MixerIRQHandler();

/*
ULONG MixerGetBufferSize()
	Returns the size of the Chip RAM buffer size that needs to be allocated
	and passed to MixerSetup(). Note that this routine merely returns the
	value of mixer_buffer_size, which is defined in mixer.i. The function of
	this routine is to offer a method for C programs to gain access to this
	value without needing access to mixer.i.
*/
MIX_API ULONG MixerGetBufferSize();

/*
ULONG MixerGetSampleMultiplier()
	Returns the minimum size the miminum sample size. This is the minimum
	sample size the mixer can play back correctly. Samples must always be a
	multiple of this value in length.

	Normally this value is 4, but optimisation options in mixer_config.i can
	can increase this.

	Note: this routine is usually not needed as the minimum sample size is
	      implied by the mixer_config.i setup. Its primary function is to give
	      the correct value in case MIXER_SIZEXBUF has been set to 1 in
	      mixer_config.i, in which case the minimum sample size will depend on
	      the video system selected when calling MixerSetup (PAL or NTSC).
	Note: MixerSetup() must have been called prior to calling this function.
*/
MIX_API ULONG MixerGetSampleMinSize();

/*
void MixerSetup(void *buffer,UWORD video_system)
	Prepares the mixer structure for use by the mixing routines and sets mixer
	playback volume to the maximum hardware volume of 64. Must be called prior
	to any other mixing routines.

	- buffer must point to a block of memory in Chip RAM at least
	  mixer_buffer_size bytes in size.
	- video_system must contain either MIX_PAL if running on a PAL system, or
	  MIX_NTSC when running on a NTSC system.

	If the video system is unknown, set video_system to MIX_PAL.

	Note: on 68020+ systems, it is advisable to align the Chip RAM buffer to a
	      4 byte boundary for optimal performance.
*/
MIX_API void MixerSetup (MIX_REGARG(void *buffer, "a0"),
                 MIX_REGARG(UWORD vidsys,"d0"));

/*
void MixerInstallHandler(void *VBR,UWORD save_vector)
	Sets up the mixer interrupt handler. MixerSetup() must be called prior to
	calling this routine.
	- Pass the VBR value or zero in VBR.
	- save_vector controls whether or not the old interrupt vector will be
	  saved. Set it to 0 to save the vector for future restoring and to 1 to skip
	  saving the vector.
   */
MIX_API void MixerInstallHandler(MIX_REGARG(void *VBR,"a0"),
                         MIX_REGARG(UWORD save_vector,"d0"));

/*
void MixerRemoveHandler()
	Removes the mixer interrupt handler. MixerStop() should be called prior to
	calling this routine to make sure audio DMA is stopped.
*/
MIX_API void MixerRemoveHandler();

/*
void MixerStart()
	Starts mixer playback (initially playing back silence). MixerSetup() and
	MixerInstallHandler() must have been called prior to calling this
	function.
*/
MIX_API void MixerStart();

/*
void MixerStop()
	Stops mixer playback. MixerSetup() and MixerInstallHandler() must have
	been called prior to calling this function.
*/
MIX_API void MixerStop();

/*
void MixerVolume(UWORD volume)
	Set the desired hardware output volume used by the mixer (valid values are
	0 to 64).
*/
MIX_API void MixerVolume(MIX_REGARG(UWORD volume,"d0"));

/*
ULONG MixerPlayFX(MXEffectStructure *effect_structure,
                  ULONG hardware_channel)
	Adds the sample defined in the MXEffectStructure pointed to by
	effect_structure on the the hardware channel given in hardware_channel. If
	MIXER_SINGLE is set to 1 in mixer_config.i, the hardware channel can be
	left a 0. Determines the best mixer channel to play back on based on
	priority and age. If no applicable channel is free (for instance due to
	higher priority samples playing), the routine will not play the sample.

	Returns the hardware & mixer channel the sample will play on, or -1 if no
	free channel could be found.

	Note: the MXEffectStructure definition can be found at the top of this
		  file.
*/
MIX_API ULONG MixerPlayFX(MIX_REGARG(MXEffectStructure *effect_structure,"a0"),
                  MIX_REGARG(ULONG hardware_channel,"d0"));

/*
ULONG MixerPlayChannelFX(MXEffectStructure *effect_structure,
                         ULONG mixer_channel)
	Adds the sample defined in the MXEffectStructure pointed to by
	effect_structure on the the hardware and mixer channel given in
	mixer_channel. If MIXER_SINGLE is set to 1 in mixer_config.i, the hardware
	channel bits can be left zero, but the mixer channel bit must still be
	set. Determines whether to play back the sample based on priority and age.
	If the channel isn't free (for instance due to a higher priority sample
	playing), the routine will not play the sample.

	Returns the hardware & mixer channel the sample will play on,	or -1 if
	no free channel could be found.

	Note: the MXEffectStructure definition can be found at the top of
	      of this file, values are as described at the MixerPlaySample()
		  routine.
	Note: a mixer channel refers to the internal virtual channels the mixer
	      uses to mix samples together. By exposing these virtual channels,
	      more fine grained control over playback becomes possible.

	      Mixer channels range from MIX_CH0 to MIX_CH3, depending on the
	      maximum number of software channels available as defined in
	      mixer_config.i.
*/
MIX_API ULONG MixerChannelPlayFX(MIX_REGARG(MXEffectStructure *effect_structure,"a0"),
                         MIX_REGARG(ULONG mixer_channel,"d0"));

/*
void MixerStopFX(ULONG mixer_channel_mask)
	Stops playback on the given hardware/mixer channel combination in
	channel_mask. If MIXER_SINGLE is set to 1 in mixer_config.i, the hardware
	channel bits can be left zero, but the mixer channel bits must still be
	set. If MIXER_MULTI or MIXER_MULTI_PAIRED are set to 1 in mixer_config.i,
	multiple hardware channels can be selected at the same time. In this case
	the playback is stopped on the given mixer channels across all selected
	hardware channels.

	Note: see MixerPlayChannelFX() for an explanation of mixer channels.
*/
MIX_API void MixerStopFX(MIX_REGARG(UWORD mixer_channel_mask,"d0"));

/*
ULONG MixerPlaySample(void *sample,ULONG hardware_channel,LONG length,
                      WORD signed_priority,UWORD loop_indicator)
	Adds the sample pointed to by sample on the hardware channel given in
	hardware_channel. If MIXER_SINGLE is set to 1 in mixer_config.i, the
	hardware channel can be left 0. Determines the best mixer channel to play
	back on based on priority and age. If no applicable channel is free (for
	instance due to higher priority samples playing), the routine will not
	play the sample.

	Other values that need to be set are length, which sets the length of the
	sample (signed long, unless MIXER_WORDSIZED is set to 1 in mixer_config.i,
	in which case the length is an unsigned word). The desired priority of the
	sample is set in signed_priority. Samples of higher priority can overwrite
	already playing samples of lower priority if no free mixer channel can be
	found. The loop_indicator has to contain either MIX_FX_ONCE for samples
	that need to play once, or MIX_FX_LOOP for samples that should loop
	forever. Looping samples can only be stopped by either calling MixerStop()
	or MixerStopFX().

	Returns the hardware & mixer channel the sample will play on, or -1 if no
	free channel could be found.
*/
MIX_API ULONG MixerPlaySample(MIX_REGARG(void *sample,"a0"),
                      MIX_REGARG(ULONG hardware_channel,"d0"),
					  MIX_REGARG(LONG length,"d1"),
					  MIX_REGARG(WORD signed_priority,"d2"),
					  MIX_REGARG(UWORD loop_indicator,"d3"));

/*
ULONG MixerPlayChannelSample(void *sample,ULONG mixer_channel,LONG length,
                             WORD signed_priority,UWORD loop_indicator)
	Adds the sample pointed to by sample on the hardware/mixer channel given
	in mixer_channel. If MIXER_SINGLE is set to 1 in mixer_config.i, the
	hardware channel bits do not need to be set, but the mixer channel bit
	must still be given. Determines whether to play back the sample based on
	priority and age. If the channel isn't free (for instance due to a higher
	priority sample playing), the routine will not play the sample.

	Other values that need to be set are length, which sets the length of the
	sample (signed long, unless MIXER_WORDSIZED is set to 1 in mixer_config.i,
	in which case the length is an unsigned word). Set the desired priority of
	the sample in signed_priority. Samples of higher priority can overwrite
	already playing samples of lower priority if no free mixer channel can be
	found. The loop_indicator has to contain either MIX_FX_ONCE for samples
	that need to play once, or MIX_FX_LOOP for samples that should loop
	forever. Looping samples can only be stopped by either calling MixerStop()
	or MixerStopFX().

	Returns the hardware & mixer channel the sample will play on, or -1 if no
	free channel could be found.

	Note: see MixerPlayChannelFX() for an explanation of mixer channels.
*/
MIX_API ULONG MixerPlayChannelSample(MIX_REGARG(void *sample,"a0"),
                             MIX_REGARG(ULONG mixer_channel,"d0"),
					         MIX_REGARG(LONG length,"d1"),
					         MIX_REGARG(WORD signed_priority,"d2"),
					         MIX_REGARG(UWORD loop_indicator,"d3"));

#undef MIX_REGARG

#if defined(BARTMAN_GCC)

MIX_API ULONG MixerGetBufferSize(void) {
	register volatile ULONG reg_result __asm("d0");
	__asm__ volatile (
		"jsr _MixerGetBufferSize"
		// OutputOperands
		: "=r" (reg_result)
		// InputOperands
		:
		// Clobbers
		: "cc"
	);

	return reg_result;
}

MIX_API ULONG MixerGetSampleMinSize(void) {
	register volatile ULONG reg_result __asm("d0");

	__asm__ volatile (
		"jsr _MixerGetSampleMinSize"
		// OutputOperands
		: "=r" (reg_result)
		// InputOperands
		:
		// Clobbers
		: "cc"
	);

	return reg_result;
}

MIX_API void MixerSetup(void *buffer, UWORD vidsys) {
	register volatile void *reg_buffer __asm("a0") = buffer;
	register volatile UWORD reg_vidsys __asm("d0") = vidsys;

	__asm__ volatile (
		"jsr _MixerSetup\n"
		// OutputOperands
		:
		// InputOperands
		: "r" (reg_buffer), "r" (reg_vidsys)
		// Clobbers
		: "cc"
	);
}

MIX_API void MixerInstallHandler(void *VBR, UWORD save_vector) {
	register volatile void *reg_VBR __asm("a0") = VBR;
	register volatile UWORD reg_save_vector __asm("d0") = save_vector;

	__asm__ volatile (
		"jsr _MixerInstallHandler\n"
		// OutputOperands
		:
		// InputOperands
		: "r" (reg_VBR), "r" (reg_save_vector)
		// Clobbers
		: "cc"
	);
}

MIX_API void MixerIRQHandler(void) {
	__asm__ volatile (
		"jsr _MixerIRQHandler"
		// OutputOperands
		:
		// InputOperands
		:
		// Clobbers
		: "cc"
	);
}

MIX_API void MixerRemoveHandler(void) {
	__asm__ volatile (
		"jsr _MixerRemoveHandler"
		// OutputOperands
		:
		// InputOperands
		:
		// Clobbers
		: "cc"
	);
}

MIX_API void MixerStart(void) {
	__asm__ volatile (
		"jsr _MixerStart"
		// OutputOperands
		:
		// InputOperands
		:
		// Clobbers
		: "cc"
	);
}

MIX_API void MixerStop(void) {
	__asm__ volatile (
		"jsr _MixerStop"
		// OutputOperands
		:
		// InputOperands
		:
		// Clobbers
		: "cc"
	);
}

MIX_API void MixerVolume(UWORD volume) {
	register volatile UWORD reg_volume __asm("d0") = volume;

	__asm__ volatile (
		"jsr _MixerVolume\n"
		// OutputOperands
		:
		// InputOperands
		: "r" (reg_volume)
		// Clobbers
		: "cc"
	);
}

MIX_API ULONG MixerPlayFX(
	MXEffectStructure *effect_structure, ULONG hardware_channel
) {
	register volatile MXEffectStructure *reg_effect_structure __asm("a0") = effect_structure;
	register volatile ULONG reg_hardware_channel __asm("d0") = hardware_channel;
	register volatile ULONG reg_result __asm("d0");

	__asm__ volatile (
		"jsr _MixerPlayFX\n"
		// OutputOperands
		: "=r" (reg_result)
		// InputOperands
		: "r" (reg_effect_structure), "r" (reg_hardware_channel)
		// Clobbers
		: "cc"
	);

	return reg_result;
}

MIX_API ULONG MixerChannelPlayFX(
	MXEffectStructure *effect_structure, ULONG mixer_channel
) {
	register volatile MXEffectStructure *reg_effect_structure __asm("a0") = effect_structure;
	register volatile ULONG reg_mixer_channel __asm("d0") = mixer_channel;
	register volatile ULONG reg_result __asm("d0");

	__asm__ volatile (
		"jsr _MixerChannelPlayFX\n"
		// OutputOperands
		: "=r" (reg_result)
		// InputOperands
		: "r" (reg_effect_structure), "r" (reg_mixer_channel)
		// Clobbers
		: "cc"
	);

	return reg_result;
}

MIX_API void MixerStopFX(UWORD mixer_channel_mask) {
	register volatile UWORD reg_mixer_channel_mask __asm("d0") = mixer_channel_mask;

	__asm__ volatile (
		"jsr _MixerStopFX\n"
		// OutputOperands
		:
		// InputOperands
		: "r" (reg_mixer_channel_mask)
		// Clobbers
		: "cc"
	);
}

MIX_API ULONG MixerPlaySample(
	void *sample, ULONG hardware_channel, LONG length, WORD signed_priority,
	UWORD loop_indicator
) {
	register volatile void *reg_sample __asm("a0") = sample;
	register volatile ULONG reg_hardware_channel __asm("d0") = hardware_channel;
	register volatile LONG reg_length __asm("d1") = length;
	register volatile WORD reg_signed_priority __asm("d2") = signed_priority;
	register volatile UWORD reg_loop_indicator __asm("d3") = loop_indicator;
	register volatile ULONG reg_result __asm("d0");

	__asm__ volatile (
		"jsr _MixerPlaySample\n"
		// OutputOperands
		: "=r" (reg_result)
		// InputOperands
		: "r" (reg_sample), "r" (reg_hardware_channel), "r" (reg_length),
			"r" (reg_signed_priority), "r" (reg_loop_indicator)
		// Clobbers
		: "cc"
	);

	return reg_result;
}

MIX_API ULONG MixerPlayChannelSample(
	void *sample, ULONG mixer_channel, LONG length, WORD signed_priority,
	UWORD loop_indicator
) {
	register volatile void *reg_sample __asm("a0") = sample;
	register volatile ULONG reg_mixer_channel __asm("d0") = mixer_channel;
	register volatile LONG reg_length __asm("d1") = length;
	register volatile WORD reg_signed_priority __asm("d2") = signed_priority;
	register volatile UWORD reg_loop_indicator __asm("d3") = loop_indicator;
	register volatile ULONG reg_result __asm("d0");

	__asm__ volatile (
		"jsr _MixerPlayChannelSample\n"
		// OutputOperands
		: "=r" (reg_result)
		// InputOperands
		: "r" (reg_sample), "r" (reg_mixer_channel), "r" (reg_length),
			"r" (reg_signed_priority), "r" (reg_loop_indicator)
		// Clobbers
		: "cc"
	);

	return reg_result;
}

#endif // BARTMAN_GCC

#endif // MIXER_H
