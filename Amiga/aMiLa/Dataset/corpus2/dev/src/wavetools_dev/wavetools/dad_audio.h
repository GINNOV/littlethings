#ifndef DAD_AUDIO_H
#define DAD_AUDIO_H
/************************************************************************
** $VER: 0.19_BETA dad_audio.h (95.11.15)                              **
** dad_audio.device include file BETA by Johan Nyblom                  **
** email: nyblom@mother.ludd.luth.se                                   **
** All this knowledge has been found by reverse engineering,           **
** guessing and the use of devmon. It has NOTHING to do with           **
** Digital Audio Design, the makers of wavetools hardware              **
** and software.                                                       **
** I am not responsible for any damage anyone does with this stuff :)  **
** just so that you know, this is EXTREMELY shaky knowledge.           **
** Ye have been forewarned!                                            **
************************************************************************/

#include <exec/io.h>	/*std DEVICE commands and structures*/

/* Standard device commands, listed for easy access.
CMD_INVALID	0 Invalid Command
CMD_RESET	1 Reset device to orig.state
CMD_READ	2 Read from device
CMD_WRITE	3 Write to device
CMD_UPDATE	4 Process buffer
CMD_CLEAR	5 Clear all buffers
CMD_STOP	6 Insert pause
CMD_START	7 Continue after pause
CMD_FLUSH	8 Stop current task
*/

/************************************************************************
**                                                                     **
** dad_audio.device	   					       **
**                                                                     **
************************************************************************/

/* CMD_READ	standard device command
**		io_Data = Longword Aligned.
**			data is read into the address in io_Data.
**		io_Offset = -1, it worls with Offset=0 but dad_audio.device
**			returns offset=-1 so why not use it from the start,
**			besides WaveTools(software) uses Offset -1 so...
**
**		Result: buffer is read to address,
**			io_Actual = bytes read
**
**
** DataFormat is LONG( WORD(left) , WORD(right))
**
*/



/*
** dad_audio.device commandon
*/

#define	DADCMD_BUFFER		(CMD_NONSTD+0)
#define	DAD_BUFFER_SETUP	0L
#define	DAD_BUFFER_SWITCH	-1L
	/* Call with Offset to determine usage,
	** Offset = 	DAD_ BUFFER_SWITCH
	**		Result: io_Actual = number of bytes in presampled buffer.
	**
	** Offset = 	DAD_BUFFER_SETUP
	** 		Result:	io_Actual is set to first sampling length (ie max internal buffer size)
	**		usually 8084 but it could differ with another hardware setup.
	**
	**Model:
	**	Suppose the card has 2 onboard buffes, these buffers are 8084 bytes each.
	** 1.	Setup onboard buffers, returning maximum size in bytes. (8084)
	** 2.	Next read from the card to a buffer MEMF_24BITDMA or
	**		MEMF_CHIP if you are gonna dump it do disk,
	**		the card starts sampling into buffer1 and let me read it when it is full,
	**		while the card continues to sample into buffer2.
	** 3.	I am done reading and now switches buffers with the buffer command,
	**		buffer2 is frozen. and sampling to buffer 1 starts,
	**		io_Actual is the length the card managed to sample into buffer2.
	**		io_Error = -128 if overflow(or some error) happened.
	** 4.	I read from card, getting my data from buffer2 this time.
	**	Then it starts over at 3.
        */



#define	DADCMD_OUTPUTDAMP	(CMD_NONSTD+2)
#define	DADCONST_MAXDAMP	31L		/* value from dad_audio.device */
	/*
	** Set damping on output, io_Data = Damping
	** The maximum is 31 which gives no sound out and minimum is 0, integer steps.
	** all other except flags and command should be zero
        */


#define	DADCMD_INPUTGAIN	(CMD_NONSTD+3)
#define	DADCONST_MAXGAIN	15L
	/*
	** Set gain on input, io_Data = gain
	** Maximum = 15, minimum = 0 integer steps
	*/


#define	DADCMD_REPLAYFREQ	(CMD_NONSTD+4)
	/*
	** set playback frequency io_Data = Frequency.
	** You can only use a couple of frequencies
	** see below DADFREQ_*
	*/


#define	DADCMD_INIT1		(CMD_NONSTD+5)
	/*
	** This is called by WaveTools (sampling software)
	** with all values = 0 except command,
	** upon return io_Data = an address which is later used
	** in the set buffer command. I dont know what this is about
	** maybe it is auto buffer allocation. Maybe it is base address of the
	** hardware dma zone or something. But since you can set your own bufferspace,
	** it doesnt matter.
	*/


#define	DADCMD_MUTE		(CMD_NONSTD+6)
	/*
	** Mute Internal channels output
	** io_Data = 0 turns sound off
	** io_Data = 1 turns them on
	*/


#define	DADCMD_SAMPLEFREQ	(CMD_NONSTD+7)
	/*
	** set sampling frequency io_Data = frequency
	** I checked dad_audio.device and it did no real checking of the
	** frequency, maybe it is linked to replay frequency.
	*/


#define	DADCMD_SMPTE		(CMD_NONSTD+15)
	/*
	** SMPTE port init, E=-1 if hardware is not there.
	** I cant check anything more because I havent got the hardware :(
	*/


#define	DADCMD_INIT2		(CMD_NONSTD+17)
	/*
	** This is an interresting command, it is called with
	** io_Data = (DADF_SET | DADF_INIT) (ie. $80000001) by wavetools
	** prior to setting frequency,damping and such.
	** I dont know what it is, could be internal status bits or something.
	*/


#define	DAD_DEVICENAME "dad_audio.device"

/*
** Flags
*/
#define	DADB_INIT	0L
#define DADB_SETFLAG	31L

#define	DADF_INIT	(1L << 0)	/* $00000001 */
#define DADF_SETFLAG	(1L << 31)	/* $80000000 */


/*
** Frequencies
*/
#define DADFREQ_48000	48000;	/* These values are checked for in dad_audio.device 	*/
#define DADFREQ_44100	44100;	/* I guess they are the only frequencys alowed		*/
#define DADFREQ_32000	32000;	/* they are valid for both sampling and playback	*/
#define DADFREQ_29400	29400;
#define DADFREQ_24000	24000;
#define DADFREQ_22050	22050;
#define DADFREQ_19200	19200;
#define DADFREQ_17640	17640;


#endif	/* DAD_AUDIO_H  */
