/*
 * Source generated with ARexxBox 1.12 (May 18 1993)
 * which is Copyright (c) 1992,1993 Michael Balzer
 */

#ifndef _phonerexx_H
#define _phonerexx_H

#define RXIF_INIT   1
#define RXIF_ACTION 2
#define RXIF_FREE   3

#define ARB_CF_ENABLED     (1L << 0)

#define ARB_HF_CMDSHELL    (1L << 0)
#define ARB_HF_USRMSGPORT  (1L << 1)

struct RexxHost
{
	struct MsgPort *port;
	char portname[ 80 ];
	long replies;
	struct RDArgs *rdargs;
	long flags;
	APTR userdata;
};

struct rxs_command
{
	char *command, *args, *results;
	long resindex;
	void (*function)( struct RexxHost *, void **, long, struct RexxMsg * );
	long flags;
};

struct arb_p_link
{
	char	*str;
	int		dst;
};

struct arb_p_state
{
	int		cmd;
	struct arb_p_link *pa;
};

#ifndef NO_GLOBALS
extern char RexxPortBaseName[80];
extern struct rxs_command rxs_commandlist[];
extern struct arb_p_state arb_p_state[];
extern int command_cnt;
extern char *rexx_extension;
#endif

void ReplyRexxCommand( struct RexxMsg *rxmsg, long prim, long sec, char *res );
void FreeRexxCommand( struct RexxMsg *rxmsg );
struct RexxMsg *CreateRexxCommand( struct RexxHost *host, char *buff, BPTR fh );
struct RexxMsg *CommandToRexx( struct RexxHost *host, struct RexxMsg *rexx_command_message );
struct RexxMsg *SendRexxCommand( struct RexxHost *host, char *buff, BPTR fh );

void CloseDownARexxHost( struct RexxHost *host );
struct RexxHost *SetupARexxHost( char *basename, struct MsgPort *usrport );
struct rxs_command *FindRXCommand( char *com );
char *ExpandRXCommand( struct RexxHost *host, char *command );
char *StrDup( char *s );
void ARexxDispatch( struct RexxHost *host );

/* rxd-Strukturen dürfen nur AM ENDE um lokale Variablen erweitert werden! */

struct rxd_browser
{
	long rc, rc2;
	struct {
		long show;
		long hide;
	} arg;
};

void rx_browser( struct RexxHost *, struct rxd_browser **, long, struct RexxMsg * );

struct rxd_connect
{
	long rc, rc2;
	struct {
		char *hostname;
		long prompt;
		long force;
	} arg;
};

void rx_connect( struct RexxHost *, struct rxd_connect **, long, struct RexxMsg * );

struct rxd_connectto
{
	long rc, rc2;
	struct {
		long *entry;
		long prompt;
		long force;
	} arg;
};

void rx_connectto( struct RexxHost *, struct rxd_connectto **, long, struct RexxMsg * );

struct rxd_daemon
{
	long rc, rc2;
	struct {
		long show;
		long hide;
	} arg;
};

void rx_daemon( struct RexxHost *, struct rxd_daemon **, long, struct RexxMsg * );

struct rxd_disable
{
	long rc, rc2;
};

void rx_disable( struct RexxHost *, struct rxd_disable **, long, struct RexxMsg * );

struct rxd_disconnect
{
	long rc, rc2;
};

void rx_disconnect( struct RexxHost *, struct rxd_disconnect **, long, struct RexxMsg * );

struct rxd_enable
{
	long rc, rc2;
};

void rx_enable( struct RexxHost *, struct rxd_enable **, long, struct RexxMsg * );

struct rxd_getstate
{
	long rc, rc2;
	struct {
		char *var, *stem;
	} arg;
	struct {
		long *version;
		char *remotename;
		char *voicemaildir;
		char *samplerstate;
		char *lastmemofile;
		long *memo;
		char *sampler;
		char *compression;
		char *xmitenable;
		long *inputgain;
		long *amplify;
		char *inputchannel;
		char *inputsource;
		long *enableonconnect;
		long *xmitonplay;
		long *tcpbatchxmit;
		long *samplerate;
		long *xmitdelay;
		long *threshvol;
		long *browseropen;
		long *filereqopen;
		long *zoomed;
		long *receiverate;
		long *sendrate;
	} res;
};

void rx_getstate( struct RexxHost *, struct rxd_getstate **, long, struct RexxMsg * );

struct rxd_memo
{
	long rc, rc2;
	struct {
		long start;
		long stop;
		char *filename;
	} arg;
};

void rx_memo( struct RexxHost *, struct rxd_memo **, long, struct RexxMsg * );

struct rxd_playfile
{
	long rc, rc2;
	struct {
		char *filename;
		long *rate;
		long prompt;
	} arg;
};

void rx_playfile( struct RexxHost *, struct rxd_playfile **, long, struct RexxMsg * );

struct rxd_quit
{
	long rc, rc2;
};

void rx_quit( struct RexxHost *, struct rxd_quit **, long, struct RexxMsg * );

struct rxd_setcompression
{
	long rc, rc2;
	struct {
		long adpcm2;
		long adpcm3;
		long none;
	} arg;
};

void rx_setcompression( struct RexxHost *, struct rxd_setcompression **, long, struct RexxMsg * );

struct rxd_setenableonconnect
{
	long rc, rc2;
	struct {
		long on;
		long off;
	} arg;
};

void rx_setenableonconnect( struct RexxHost *, struct rxd_setenableonconnect **, long, struct RexxMsg * );

struct rxd_setinputamplify
{
	long rc, rc2;
	struct {
		long *multiplier;
	} arg;
};

void rx_setinputamplify( struct RexxHost *, struct rxd_setinputamplify **, long, struct RexxMsg * );

struct rxd_setinputchannel
{
	long rc, rc2;
	struct {
		long left;
		long right;
	} arg;
};

void rx_setinputchannel( struct RexxHost *, struct rxd_setinputchannel **, long, struct RexxMsg * );

struct rxd_setinputgain
{
	long rc, rc2;
	struct {
		long *gain;
		long relative;
	} arg;
};

void rx_setinputgain( struct RexxHost *, struct rxd_setinputgain **, long, struct RexxMsg * );

struct rxd_setinputsource
{
	long rc, rc2;
	struct {
		long mic;
		long line;
	} arg;
};

void rx_setinputsource( struct RexxHost *, struct rxd_setinputsource **, long, struct RexxMsg * );

struct rxd_setsampler
{
	long rc, rc2;
	struct {
		long dss8;
		long perfectsound;
		long amas;
		long soundmagic;
		long toccata;
		long aura;
		long ahi;
		long custom;
		long generic;
	} arg;
};

void rx_setsampler( struct RexxHost *, struct rxd_setsampler **, long, struct RexxMsg * );

struct rxd_setsamplerate
{
	long rc, rc2;
	struct {
		long *rate;
	} arg;
};

void rx_setsamplerate( struct RexxHost *, struct rxd_setsamplerate **, long, struct RexxMsg * );

struct rxd_settcpbatchxmit
{
	long rc, rc2;
	struct {
		long on;
		long off;
	} arg;
};

void rx_settcpbatchxmit( struct RexxHost *, struct rxd_settcpbatchxmit **, long, struct RexxMsg * );

struct rxd_setthreshvol
{
	long rc, rc2;
	struct {
		long *threshold;
	} arg;
};

void rx_setthreshvol( struct RexxHost *, struct rxd_setthreshvol **, long, struct RexxMsg * );

struct rxd_setxmitdelay
{
	long rc, rc2;
	struct {
		long *milliseconds;
	} arg;
};

void rx_setxmitdelay( struct RexxHost *, struct rxd_setxmitdelay **, long, struct RexxMsg * );

struct rxd_setxmitenable
{
	long rc, rc2;
	struct {
		long hold;
		long toggle;
	} arg;
};

void rx_setxmitenable( struct RexxHost *, struct rxd_setxmitenable **, long, struct RexxMsg * );

struct rxd_setxmitonplay
{
	long rc, rc2;
	struct {
		long on;
		long off;
	} arg;
};

void rx_setxmitonplay( struct RexxHost *, struct rxd_setxmitonplay **, long, struct RexxMsg * );

struct rxd_zoom
{
	long rc, rc2;
	struct {
		long big;
		long small;
	} arg;
};

void rx_zoom( struct RexxHost *, struct rxd_zoom **, long, struct RexxMsg * );

#endif
