#include <exec/types.h>
#include "mixer.h"

typedef enum MixerState {
	MIXER_STOPPED = 0,
	MIXER_RUNNING = 1,
} MixerState;

typedef struct MXChannel {
#if !defined(MIXER_68020) && defined(MIXER_WORDSIZED)
	UWORD	mch_remaining_length;
	UWORD	mch_length;
#else
	LONG	mch_remaining_length;
	LONG	mch_length;
#endif
	APTR	mch_sample_ptr;
	APTR	mch_loop_ptr;
	UWORD	mch_status;
	UWORD	mch_priority;
	UWORD	mch_age;
#if defined(MIXER_68020)
		UWORD	mch_align
#endif
} MXChannel;

 typedef struct MXMixerEntry {
	MXChannel	mxe_channels[4];
	ULONG	mxe_active_channels[4];
	void*	mxe_pointers[4];
	void*	mxe_buffers[2];
#if defined(MIXER_MULTI_PAIRED)
	UWORD	mxe_active;
#if defined(MIXER_68020)
	UWORD	mxe_align;
#endif
#endif
} MXMixerEntry;

typedef struct MXMixer {
#if defined(MIXER_SINGLE)
		MXMixerEntry mx_mixer_entries[1];
#else
		MXMixerEntry mx_mixer_entries[4];
#endif
	APTR	mx_empty_buffer;
	UWORD	mx_buffer_size;
	UWORD	mx_buffer_size_w;
	UWORD	mx_irq_bits;
	UWORD	mx_hw_channels;
	UWORD	mx_hw_period;
	UWORD	mx_volume;
	UWORD	mx_status;
	UWORD	mx_vidsys;
} MXMixer;
