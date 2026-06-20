/*
**	Sampler.c, Copyright © 1995 by Olaf `Olsen' Barthel
**		Placed in the Public Domain
**
**	:ts=4
*/

#include <hardware/dmabits.h>
#include <hardware/intbits.h>
#include <hardware/custom.h>
#include <hardware/cia.h>

#include <devices/audio.h>

#include <resources/misc.h>

#include <dos/dosextens.h>

#include <exec/execbase.h>
#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/misc_protos.h>
#include <clib/dos_protos.h>
#include <clib/alib_protos.h>

#ifdef WE_EVEN_HAD_THESE_JAF
#include <pragmas/exec_pragmas.h>
#include <pragmas/misc_pragmas.h>
#endif

	// We'll replace #defines with references to globals. This is
	// to avoid certain compiler optimizations that may have
	// side-effects

#ifdef custom
#undef custom
#endif	// custom

#ifdef ciaa
#undef ciaa
#endif	// ciaa

#ifdef ciab
#undef ciab
#endif	// ciab

extern __far volatile struct Custom	custom;
extern __far volatile struct CIA	ciaa;
extern __far volatile struct CIA	ciab;

	// Audio channel bits

#define LEFT0F  1
#define RIGHT0F  2
#define RIGHT1F  4
#define LEFT1F  8

	// Handy shortcuts for the two bits that enable sampler  input
	// from the left and the right channel

#define LEFT_CHANNEL	CIAF_PRTRPOUT
#define RIGHT_CHANNEL	CIAF_PRTRSEL

	// Here is where you define the sample rate. The Amiga audio hardware
	// currently won't go beyond 28000 samples per second, so 22050 samples
	// per second are a nice round number. Please note that since this program
	// does stereo sampling the effective sampling rate is halved, effectively
	// yielding 11025 samples per second.

#define SAMPLING_RATE	22050

LONG __saveds
Main(VOID)
{
	STATIC UBYTE ChannelData[] = { LEFT0F | RIGHT0F, LEFT0F | RIGHT1F, LEFT1F | RIGHT0F, LEFT1F | RIGHT1F };

	struct ExecBase		*SysBase;
	struct DosLibrary	*DOSBase;
	struct Library		*MiscBase;

	struct MsgPort		*AudioPort;
	struct IOAudio		*AudioRequest;
	WORD				 LeftChannel;
	WORD				 RightChannel;
	UWORD				 AudioInt;
	UWORD				 AudioDMA;

	UWORD				 Sample,Value;
	BOOL				 IntLeftWasEnabled,
						 DMALeftWasEnabled,
						 IntRightWasEnabled,
						 DMARightWasEnabled;
	BOOL				 IsLeft;

		// Set up the libraries

	SysBase = *(struct ExecBase **)4;

	if(DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",37))
	{
			// Open the audio.device driver

		if(AudioPort = CreateMsgPort())
		{
			if(AudioRequest = (struct IOAudio *)CreateIORequest(AudioPort,sizeof(struct IOAudio)))
			{
				AudioRequest -> ioa_Request . io_Message . mn_Node . ln_Pri	= 127;
				AudioRequest -> ioa_Data									= ChannelData;
				AudioRequest -> ioa_Length									= sizeof(ChannelData);

				if(!OpenDevice(AUDIONAME,NULL,(struct IORequest *)AudioRequest,NULL))
				{
						// misc.resource controls the parallel port bits

					if(MiscBase = (struct Library *)OpenResource(MISCNAME))
					{
						STRPTR User;

						if(!(User = AllocMiscResource(MR_PARALLELPORT,__FILE__)))
						{
							if(!(User = AllocMiscResource(MR_PARALLELBITS,__FILE__)))
							{
									// Now check which audio channels we could allocate

								if((ULONG)AudioRequest -> ioa_Request . io_Unit & LEFT0F)
									LeftChannel = 0;
								else
									LeftChannel = 3;

								if((ULONG)AudioRequest -> ioa_Request . io_Unit & RIGHT0F)
									RightChannel = 1;
								else
									RightChannel = 2;

									// Build the interrupt and dma masks

								AudioInt = (1L << (INTB_AUD0 + LeftChannel)) | (1L << (INTB_AUD0 + RightChannel));
								AudioDMA = (1L << (DMAB_AUD0 + LeftChannel)) | (1L << (DMAB_AUD0 + RightChannel));

									// Save interrupt/dma enabled bits for later

								IntLeftWasEnabled = (custom . intenar & (1L << (INTB_AUD0 + LeftChannel))) ? TRUE : FALSE;
								DMALeftWasEnabled = (custom . dmaconr & (1L << (DMAB_AUD0 + LeftChannel))) ? TRUE : FALSE;

								IntRightWasEnabled = (custom . intenar & (1L << (INTB_AUD0 + RightChannel))) ? TRUE : FALSE;
								DMARightWasEnabled = (custom . dmaconr & (1L << (DMAB_AUD0 + RightChannel))) ? TRUE : FALSE;

									// Switch the data direction of the parallel port we will
									// be reading the samples from to input.

								ciaa . ciaddrb = 0;

									// Switch the data direction of the port we will use to
									// select the channel to read to output

								ciab . ciaddra |= LEFT_CHANNEL | RIGHT_CHANNEL;	// Enable output to sampler

									// We start reading from the left channel

								ciab . ciapra = (ciab . ciapra & ~RIGHT_CHANNEL) | LEFT_CHANNEL;

								IsLeft = TRUE;

									// Set up the two audio channels for output. The trick we
									// will use will give us both accurate sample timing and
									// audio output of the data we are sampling. It goes like
									// this: we disable audio DMA and write the sample data
									// `manually' into the DAC registers. As soon as the audio
									// state machine is finished playing this single sample
									// an interrupt will be triggered. Since interrupts are
									// disabled we will have to poll the interrupt request
									// register until the interrupt is set. The rate at which
									// the audio hardware generates the interrupts is exactly
									// our sampling rate (obviously) and provides the accurate
									// monotonous timing we need to record the sampler ouput.

								custom . aud[LeftChannel] . ac_ptr = NULL;
								custom . aud[LeftChannel] . ac_len = 1;		// One word at a time
								custom . aud[LeftChannel] . ac_per = (SysBase -> ex_EClockFrequency * 5) / SAMPLING_RATE;
								custom . aud[LeftChannel] . ac_vol = 64;	// Maximum volume

								custom . aud[RightChannel] . ac_ptr = NULL;
								custom . aud[RightChannel] . ac_len = 1;		// One word at a time
								custom . aud[RightChannel] . ac_per = (SysBase -> ex_EClockFrequency * 5) / SAMPLING_RATE;
								custom . aud[RightChannel] . ac_vol = 64;	// Maximum volume

									// Turn audio DMA channels off

								custom . dmacon = AudioDMA;

									// Disable audio interrupts

								custom . intena = AudioInt;

									// Clear pending requests

								custom . intreq = AudioInt;

								custom . aud[LeftChannel] . ac_dat = 0;		// Trigger interrupt

									// The Disable() could be replaced with a Forbid() if one
									// doesn't need high sampling accuracy. As it is, interrupts
									// may temporarily steal the CPU and cause `pops' in the
									// recorded input.

								Disable();

								do
								{
										// Wait for audio interrupt

									while(!(custom . intreqr & AudioInt));

										// Clear request

									custom . intreq = AudioInt;

										// Grab the sampler value; it will be in the range 0..255,
										// but the audio hardware expects signed sample values in
										// the range -128..127 so we'll use old trick to turn the
										// sample into a signed two's complement value.

									Value = ciaa . ciaprb ^ 0x80;

										// The audio hardware operates on words, not on bytes,
										// so we'll have to fake a word by composing it of the
										// byte we read.

									Sample = (Value << 8) | Value;

										// Write the sample value and set up for next
										// interrupt

									if(IsLeft)
										custom . aud[LeftChannel] . ac_dat = Sample;
									else
										custom . aud[RightChannel] . ac_dat = Sample;

										// Toggle the channel.

									IsLeft			^= TRUE;
									ciab . ciapra	^= LEFT_CHANNEL | RIGHT_CHANNEL;
								}
								while(ciaa . ciapra & CIAF_GAMEPORT0);	// Wait for mouse to be pressed

									// Wait for audio interrupt

								while(!(custom . intreqr & AudioInt));

									// Clear request

								custom . intreq = AudioInt;

								Enable();

									// Restore interrupt and dma bits

								if(IntLeftWasEnabled)
									custom . intena = INTF_SETCLR | (1L << (INTB_AUD0 + LeftChannel));

								if(IntRightWasEnabled)
									custom . intena = INTF_SETCLR | (1L << (INTB_AUD0 + RightChannel));

								if(DMALeftWasEnabled)
									custom . dmacon = DMAF_SETCLR | (1L << (DMAB_AUD0 + LeftChannel));

								if(DMARightWasEnabled)
									custom . dmacon = DMAF_SETCLR | (1L << (DMAB_AUD0 + RightChannel));

								FreeMiscResource(MR_PARALLELBITS);
							}
							else
								Printf("Parallel bits are in use by %s\n",User);

							FreeMiscResource(MR_PARALLELPORT);
						}
						else
							Printf("Parallel port is in use by %s\n",User);
					}
					else
						Printf("Couldn't open misc.resource\n");

					CloseDevice((struct IORequest *)AudioRequest);
				}
				else
					Printf("Cannot open audio.device\n");

				DeleteIORequest(AudioRequest);
			}

			DeleteMsgPort(AudioPort);
		}

		CloseLibrary(DOSBase);
	}

	return(0);
}
