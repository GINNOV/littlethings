/*
 * Source generated with ARexxBox 1.12 (May 18 1993)
 * which is Copyright (c) 1992,1993 Michael Balzer
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <rexx/storage.h>
#include <rexx/rxslib.h>

#ifdef __GNUC__
/* GCC needs all struct defs */
#include <dos/exall.h>
#include <graphics/graphint.h>
#include <intuition/classes.h>
#include <devices/keymap.h>
#include <exec/semaphores.h>
#endif

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/rexxsyslib_protos.h>

#ifndef __NO_PRAGMAS

#ifdef AZTEC_C
#include <pragmas/exec_lib.h>
#include <pragmas/dos_lib.h>
#include <pragmas/rexxsyslib_lib.h>
#endif

#ifdef LATTICE
#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/rexxsyslib_pragmas.h>
#endif

#endif /* __NO_PRAGMAS */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifdef LATTICE
#undef toupper
#define inline __inline
#endif

#ifdef __GNUC__
#undef toupper
static inline char toupper( char c )
{
	return( islower(c) ? c - 'a' + 'A' : c );
}
#endif

#ifdef AZTEC_C
#define inline
#endif

#include "phonerexx.h"
#include "phonerexx_aux.h"

extern struct ExecBase *SysBase;
extern struct DosLibrary *DOSBase;
extern struct RxsLib *RexxSysBase;


/* $ARB: I 831931909 */


/* $ARB: B 1 QUIT */
void rx_quit( struct RexxHost *host, struct rxd_quit **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_quit *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			FakeIDCMPMessage(IDCMP_MENUPICK, P_QUIT, 0);
			rd->rc = 1;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 1 QUIT */

/* $ARB: B 2 CONNECT */
void rx_connect( struct RexxHost *host, struct rxd_connect **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_connect *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if ((rd->arg.force)&&(BNetConnect)) ClosePhoneSocket();
			rd->rc = ConnectPhoneSocket((rd->arg.prompt!=0),rd->arg.hostname ? rd->arg.hostname : "");
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 2 CONNECT */

/* $ARB: B 3 DISCONNECT */
void rx_disconnect( struct RexxHost *host, struct rxd_disconnect **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_disconnect *rd = *rxd;
	
	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			rd->rc = 0;
			if (BNetConnect)
			{
				ClosePhoneSocket();
				rd->rc = 1;
			}
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 3 DISCONNECT */

/* $ARB: B 4 CONNECTTO */
void rx_connectto( struct RexxHost *host, struct rxd_connectto **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_connectto *rd = *rxd;
	char szPierName[MAXPEERNAMELENGTH];

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			rd->rc = 0;
			
			/* adjust menu order to array order */
			if (rd->arg.entry)
			{
				(*rd->arg.entry)--; if (*rd->arg.entry < 0) *rd->arg.entry = 9;			
				if ((*rd->arg.entry >= 0)&&(*rd->arg.entry <= 9)&&(pszCallIPs[*rd->arg.entry]))
				{
					if ((rd->arg.force)&&(BNetConnect)) ClosePhoneSocket();
					Strncpy(szPierName,pszCallIPs[*rd->arg.entry],MAXPEERNAMELENGTH);
					rd->rc = ConnectPhoneSocket((rd->arg.prompt!=0),szPierName);
				}
			}
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 4 CONNECTTO */

/* $ARB: B 5 PLAYFILE */
void rx_playfile( struct RexxHost *host, struct rxd_playfile **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_playfile *rd = *rxd;
	FILE * fpTest;
	
	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			rd->rc = 0;
			if ((rd->arg.filename)&&(fpTest = fopen(rd->arg.filename, "rb")))
			{
				fclose(fpTest);
				StartSoundPlayer(rd->arg.filename);
				rd->rc = 1;
			}
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 5 PLAYFILE */

/* $ARB: B 6 MEMO */
void rx_memo( struct RexxHost *host, struct rxd_memo **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_memo *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if ((rd->arg.start)||(rd->arg.stop))
			     rd->rc = StartRecording((rd->arg.start != 0), rd->arg.filename);
			else rd->rc = StartRecording((fpMemo == NULL), rd->arg.filename);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 6 MEMO */

/* $ARB: B 7 SETSAMPLER */
void rx_setsampler( struct RexxHost *host, struct rxd_setsampler **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setsampler *rd = *rxd;
	int nWanted = SAMPLER_MAX;
	
	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
               		if (rd->arg.dss8) 	  nWanted = SAMPLER_GVPDSS8;
               		if (rd->arg.perfectsound) nWanted = SAMPLER_PERFECT;
               		if (rd->arg.amas) 	  nWanted = SAMPLER_AMAS;
               		if (rd->arg.soundmagic)   nWanted = SAMPLER_SOMAGIC;
               		if (rd->arg.toccata)      nWanted = SAMPLER_TOCCATA;
               		if (rd->arg.aura) 	  nWanted = SAMPLER_AURA;
               		if (rd->arg.ahi) 	  nWanted = SAMPLER_AHI;
               		if (rd->arg.custom) 	  nWanted = SAMPLER_CUSTOM;
               		if (rd->arg.generic) 	  nWanted = SAMPLER_GENERIC;
               		ChangeSamplerType(nWanted);
               		rd->rc = (nWanted == ubSamplerType);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 7 SETSAMPLER */

/* $ARB: B 8 SETCOMPRESSION */
void rx_setcompression( struct RexxHost *host, struct rxd_setcompression **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setcompression *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.adpcm2) ChangeCompressMode(COMPRESS_ADPCM2);
			if (rd->arg.adpcm3) ChangeCompressMode(COMPRESS_ADPCM3);
			if (rd->arg.none)   ChangeCompressMode(COMPRESS_NONE);
			rd->rc = rd->arg.adpcm2 || rd->arg.adpcm3 || rd->arg.none;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 8 SETCOMPRESSION */

/* $ARB: B 9 SETXMITENABLE */
void rx_setxmitenable( struct RexxHost *host, struct rxd_setxmitenable **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setxmitenable *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.toggle) nToggleMode = TOGGLE_TOGGLE;
			if (rd->arg.hold)   nToggleMode = TOGGLE_HOLD;
			rd->rc = (rd->arg.toggle || rd->arg.hold);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 9 SETXMITENABLE */

/* $ARB: B 10 SETINPUTGAIN */
void rx_setinputgain( struct RexxHost *host, struct rxd_setinputgain **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setinputgain *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			rd->rc = 0;
			if (rd->arg.gain)
			{
				UNLESS(rd->arg.relative) nLineGainValue = 0;
				RaiseLineGain(*rd->arg.gain);
				rd->rc = 1;
			}
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 10 SETINPUTGAIN */

/* $ARB: B 11 SETINPUTAMPLIFY */
void rx_setinputamplify( struct RexxHost *host, struct rxd_setinputamplify **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setinputamplify *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			rd->rc = 1;
			if (rd->arg.multiplier) 
			{
				switch(*rd->arg.multiplier)
				{
					case 1: nAmpShift = IntData.ulShiftLeft = 0; break;
					case 2: nAmpShift = IntData.ulShiftLeft = 1; break;
					case 4: nAmpShift = IntData.ulShiftLeft = 2; break;
					default: rd->rc = 0;
				}
			} else rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 11 SETINPUTAMPLIFY */

/* $ARB: B 12 SETINPUTCHANNEL */
void rx_setinputchannel( struct RexxHost *host, struct rxd_setinputchannel **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setinputchannel *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.left)  ChangeInputChannel(INPUT_JACK_LEFT);
			if (rd->arg.right) ChangeInputChannel(INPUT_JACK_RIGHT);
			rd->rc = (rd->arg.left || rd->arg.right);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 12 SETINPUTCHANNEL */

/* $ARB: B 14 SETENABLEONCONNECT */
void rx_setenableonconnect( struct RexxHost *host, struct rxd_setenableonconnect **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setenableonconnect *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.on)  BEnableOnConnect = TRUE; 
			if (rd->arg.off) BEnableOnConnect = FALSE;
			rd->rc = (rd->arg.on || rd->arg.off);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 14 SETENABLEONCONNECT */

/* $ARB: B 15 SETINPUTSOURCE */
void rx_setinputsource( struct RexxHost *host, struct rxd_setinputsource **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setinputsource *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.mic)  ChangeInputSource(INPUT_SOURCE_MIC, TRUE);
			if (rd->arg.line) ChangeInputSource(INPUT_SOURCE_EXT, TRUE);
			rd->rc = (rd->arg.mic || rd->arg.line);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 15 SETINPUTSOURCE */

/* $ARB: B 16 SETXMITONPLAY */
void rx_setxmitonplay( struct RexxHost *host, struct rxd_setxmitonplay **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setxmitonplay *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.on)  BXmitOnPlay = TRUE; 
			if (rd->arg.off) BXmitOnPlay = FALSE;
			rd->rc = (rd->arg.on || rd->arg.off);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 16 SETXMITONPLAY */

/* $ARB: B 17 SETTCPBATCHXMIT */
void rx_settcpbatchxmit( struct RexxHost *host, struct rxd_settcpbatchxmit **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_settcpbatchxmit *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */			
			if (rd->arg.on)  BTCPBatchXmit = TRUE; 
			if (rd->arg.off) BTCPBatchXmit = FALSE;
			rd->rc = (rd->arg.on || rd->arg.off);

			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 17 SETTCPBATCHXMIT */

/* $ARB: B 18 SETSAMPLERATE */
void rx_setsamplerate( struct RexxHost *host, struct rxd_setsamplerate **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setsamplerate *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.rate)
			{
				FakeIDCMPMessage(IDCMP_GADGETUP, *rd->arg.rate, FREQ_SLIDER);
				rd->rc = 1;
			} else rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 18 SETSAMPLERATE */

/* $ARB: B 19 SETXMITDELAY */
void rx_setxmitdelay( struct RexxHost *host, struct rxd_setxmitdelay **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setxmitdelay *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.milliseconds)
			{
				FakeIDCMPMessage(IDCMP_GADGETUP, *rd->arg.milliseconds, DELAY_SLIDER);
				rd->rc = 1;
			} else rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 19 SETXMITDELAY */

/* $ARB: B 20 SETTHRESHVOL */
void rx_setthreshvol( struct RexxHost *host, struct rxd_setthreshvol **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_setthreshvol *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (rd->arg.threshold)
			{
				ChangeVolumeThreshold(*rd->arg.threshold);
				rd->rc = 1;
			} else rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 20 SETTHRESHVOL */

/* $ARB: B 21 ENABLE */
void rx_enable( struct RexxHost *host, struct rxd_enable **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_enable *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			ToggleMicButton(CODE_ON);
			rd->rc = BTransmitting;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 21 ENABLE */

/* $ARB: B 22 DISABLE */
void rx_disable( struct RexxHost *host, struct rxd_disable **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_disable *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			ToggleMicButton(CODE_OFF);
			rd->rc = (BTransmitting == FALSE);
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 22 DISABLE */

/* $ARB: B 23 GETSTATE */
void rx_getstate( struct RexxHost *host, struct rxd_getstate **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_getstate *rd = *rxd;
	static char szResRemoteName[MAXPEERNAMELENGTH];
	static char szResSamplerState[15];
	static char szResChannel[6];
	static char szResSampler[20];
	static char szResCompression[15];
	static char szResSource[6];
	static char szResXmitenable[7];
	static LONG ulResversion, ulResmemo, ulResxmitenable, ulResinputgain, 
		    ulResamplify, ulResenableonconnect, ulResxmitonplay,
        	    ulRestcpbatchxmit, ulRessamplerate, ulResxmitdelay,
		    ulResthreshvol, ulResbrowseropen, ulResfilereqopen,
		    ulReszoomed;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (BNetConnect) Strncpy(szResRemoteName, szPeerName, sizeof(szResRemoteName));
				    else strcpy(szResRemoteName, "(Not connected)");
	                rd->res.remotename = szResRemoteName;
	  
	  		/* Just use the regular string */              
	                rd->res.voicemaildir = szVoiceMailDir;
	                
	                GetSamplerState(szResSamplerState);
	                rd->res.samplerstate = szResSamplerState;

	                rd->res.lastmemofile = szLastMemoFile;

			     if (ubInputChannel == INPUT_JACK_LEFT)  strcpy(szResChannel,"LEFT");
			else if (ubInputChannel == INPUT_JACK_RIGHT) strcpy(szResChannel,"RIGHT");
			else strcpy(szResChannel, "????");
	                rd->res.inputchannel = szResChannel;

			     if (ubInputSource == INPUT_SOURCE_MIC) strcpy(szResSource,"MIC");
			else if (ubInputSource == INPUT_SOURCE_EXT) strcpy(szResSource,"LINE");
			else strcpy(szResSource, "????");
	                rd->res.inputsource = szResSource;

			GetSamplerType(szResSampler, ubSamplerType);
	                rd->res.sampler = szResSampler;
	                
	                     if (ubCurrComp == COMPRESS_ADPCM2) strcpy(szResCompression,"ADPCM2");
	                else if (ubCurrComp == COMPRESS_ADPCM3) strcpy(szResCompression,"ADPCM3");
	                else if (ubCurrComp == COMPRESS_NONE)   strcpy(szResCompression,"NONE");
	                rd->res.compression = szResCompression;

			     if (nToggleMode == TOGGLE_TOGGLE) strcpy(szResXmitenable, "TOGGLE");
			else if (nToggleMode == TOGGLE_HOLD)   strcpy(szResXmitenable, "HOLD");
			else strcpy(szResXmitenable, "????");
			rd->res.xmitenable = szResXmitenable;
			
			/* A little hackery here--otherwise memos make AmiPhone look like it's sending */
			UNLESS(BNetConnect) {ulRexxSendAve = ulRexxReceiveAve = 0L;}
			
			ulResversion 		= VERSION_NUMBER;	rd->res.version		= &ulResversion;
	                ulResmemo		= (fpMemo != NULL);	rd->res.memo		= &ulResmemo;
	                ulResinputgain		= nLineGainValue;	rd->res.inputgain	= &ulResinputgain;
	                ulResamplify		= 1<<nAmpShift;		rd->res.amplify		= &ulResamplify;
	                ulResenableonconnect 	= BEnableOnConnect;	rd->res.enableonconnect	= &ulResenableonconnect;
	                ulResxmitonplay		= BXmitOnPlay;		rd->res.xmitonplay	= &ulResxmitonplay;
	                ulRestcpbatchxmit	= BTCPBatchXmit;	rd->res.tcpbatchxmit	= &ulRestcpbatchxmit;
	                ulRessamplerate		= ulBytesPerSecond;	rd->res.samplerate	= &ulRessamplerate;
	                ulResxmitdelay		= (fPacketDelay * 1000);rd->res.xmitdelay	= &ulResxmitdelay;
	                ulResthreshvol		= nMinSampleVol;	rd->res.threshvol	= &ulResthreshvol;
	                ulResbrowseropen	= BBrowserIsRunning;	rd->res.browseropen	= &ulResbrowseropen;
	                ulResfilereqopen	= (FileReqTask != NULL);rd->res.filereqopen	= &ulResfilereqopen;
	                ulReszoomed		= BZoomed;		rd->res.zoomed		= &ulReszoomed;
							                rd->res.receiverate 	= &ulRexxReceiveAve;
							                rd->res.sendrate  	= &ulRexxSendAve;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 23 GETSTATE */

/* $ARB: B 24 BROWSER */
void rx_browser( struct RexxHost *host, struct rxd_browser **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_browser *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if ((rd->arg.show)&&(BBrowserIsRunning == FALSE)&&(*szVoiceMailDir != '\0'))
			{
				StartBrowser(szVoiceMailDir);
				rd->rc = 1;
			}
			else if ((rd->arg.hide)&&(BBrowserIsRunning == TRUE))
			{
				StopBrowser();
				rd->rc = 1;
			} else rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 24 BROWSER */

/* $ARB: B 25 DAEMON */
void rx_daemon( struct RexxHost *host, struct rxd_daemon **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_daemon *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (((rd->arg.show)&&(daemonInfo->BWindowIsOpen == FALSE)) ||
		 	    ((rd->arg.hide)&&(daemonInfo->BWindowIsOpen == TRUE)))
		 	{
		 		FakeIDCMPMessage(IDCMP_MENUPICK, T_SHOWDAEMON, 0);
		 		rd->rc = 1;
			} rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 25 DAEMON */

/* $ARB: B 26 ZOOM */
void rx_zoom( struct RexxHost *host, struct rxd_zoom **rxd, long action, struct RexxMsg *rexxmsg )
{
	struct rxd_zoom *rd = *rxd;

	switch( action )
	{
		case RXIF_INIT:
			*rxd = AllocVec( sizeof *rd, MEMF_CLEAR );
			if( rd = *rxd )
			{
				/* set your DEFAULTS here */
			}
			break;
			
		case RXIF_ACTION:
			/* Insert your CODE here */
			if (((rd->arg.big)&&(BZoomed == TRUE)) ||
			    ((rd->arg.small)&&(BZoomed == FALSE)))
			{
				ZipWindow(PhoneWindow);
				rd->rc = 1;
			}
			else rd->rc = 0;
			break;
		
		case RXIF_FREE:
			/* FREE your local data here */
			FreeVec( rd );
			break;
	}
	return;
}
/* $ARB: E 26 ZOOM */


#ifndef RX_ALIAS_C
char *ExpandRXCommand( struct RexxHost *host, char *command )
{
	/* Insert your ALIAS-HANDLER here */
	return( NULL );
}
#endif

