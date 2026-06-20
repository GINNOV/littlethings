/*
 * Source generated with ARexxBox 1.12 (May 18 1993)
 * which is Copyright (c) 1992,1993 Michael Balzer
 */

#include <exec/types.h>
#include <dos/dos.h>
#include <rexx/storage.h>

#define NO_GLOBALS
#include "phonerexx.h"

#define RESINDEX(stype) (((long) &((struct stype *)0)->res) / sizeof(long))

char	RexxPortBaseName[80] = "AmiPhone";
char	*rexx_extension = "AmiPhone";

struct rxs_command rxs_commandlist[] =
{
	{ "BROWSER", "SHOW/S,HIDE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_browser, 1 },
	{ "CONNECT", "HOSTNAME,PROMPT/S,FORCE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_connect, 1 },
	{ "CONNECTTO", "ENTRY/N,PROMPT/S,FORCE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_connectto, 1 },
	{ "DAEMON", "SHOW/S,HIDE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_daemon, 1 },
	{ "DISABLE", NULL, NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_disable, 1 },
	{ "DISCONNECT", NULL, NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_disconnect, 1 },
	{ "ENABLE", NULL, NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_enable, 1 },
	{ "GETSTATE", NULL, "VERSION/N,REMOTENAME,VOICEMAILDIR,SAMPLERSTATE,LASTMEMOFILE,MEMO/N,SAMPLER,COMPRESSION,XMITENABLE,INPUTGAIN/N,AMPLIFY/N,INPUTCHANNEL,INPUTSOURCE,ENABLEONCONNECT/N,XMITONPLAY/N,TCPBATCHXMIT/N,SAMPLERATE/N,XMITDELAY/N,THRESHVOL/N,BROWSEROPEN/N,FILEREQOPEN/N,ZOOMED/N,RECEIVERATE/N,SENDRATE/N", RESINDEX(rxd_getstate), (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_getstate, 1 },
	{ "MEMO", "START/S,STOP/S,FILENAME", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_memo, 1 },
	{ "PLAYFILE", "FILENAME,RATE/N,PROMPT/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_playfile, 1 },
	{ "QUIT", NULL, NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_quit, 1 },
	{ "SETCOMPRESSION", "ADPCM2/S,ADPCM3/S,NONE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setcompression, 1 },
	{ "SETENABLEONCONNECT", "ON/S,OFF/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setenableonconnect, 1 },
	{ "SETINPUTAMPLIFY", "MULTIPLIER/N", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setinputamplify, 1 },
	{ "SETINPUTCHANNEL", "LEFT/S,RIGHT/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setinputchannel, 1 },
	{ "SETINPUTGAIN", "GAIN/N,RELATIVE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setinputgain, 1 },
	{ "SETINPUTSOURCE", "MIC/S,LINE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setinputsource, 1 },
	{ "SETSAMPLER", "DSS8/S,PERFECTSOUND/S,AMAS/S,SOUNDMAGIC/S,TOCCATA/S,AURA/S,AHI/S,CUSTOM/S,GENERIC/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setsampler, 1 },
	{ "SETSAMPLERATE", "RATE/N", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setsamplerate, 1 },
	{ "SETTCPBATCHXMIT", "ON/S,OFF/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_settcpbatchxmit, 1 },
	{ "SETTHRESHVOL", "THRESHOLD/N", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setthreshvol, 1 },
	{ "SETXMITDELAY", "MILLISECONDS/N", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setxmitdelay, 1 },
	{ "SETXMITENABLE", "HOLD/S,TOGGLE/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setxmitenable, 1 },
	{ "SETXMITONPLAY", "ON/S,OFF/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_setxmitonplay, 1 },
	{ "ZOOM", "BIG/S,SMALL/S", NULL, 0, (void (*)(struct RexxHost *,void **,long,struct RexxMsg *)) rx_zoom, 1 },
	{ NULL, NULL, NULL, NULL, NULL }
};

int		command_cnt = 25;

static struct arb_p_link link0[] = {
	{"ZOOM", 1}, {"SET", 2}, {"QUIT", 19}, {"PLAYFILE", 20}, {"MEMO", 21}, {"GETSTATE", 22},
	{"ENABLE", 23}, {"D", 24}, {"CONNECT", 29}, {"BROWSER", 31}, {NULL, 0} };

static struct arb_p_link link2[] = {
	{"XMIT", 3}, {"T", 7}, {"SAMPLER", 10}, {"INPUT", 12}, {"ENABLEONCONNECT", 17}, {"COMPRESSION", 18},
	{NULL, 0} };

static struct arb_p_link link3[] = {
	{"ONPLAY", 4}, {"ENABLE", 5}, {"DELAY", 6}, {NULL, 0} };

static struct arb_p_link link7[] = {
	{"HRESHVOL", 8}, {"CPBATCHXMIT", 9}, {NULL, 0} };

static struct arb_p_link link10[] = {
	{"ATE", 11}, {NULL, 0} };

static struct arb_p_link link12[] = {
	{"SOURCE", 13}, {"GAIN", 14}, {"CHANNEL", 15}, {"AMPLIFY", 16}, {NULL, 0} };

static struct arb_p_link link24[] = {
	{"IS", 25}, {"AEMON", 28}, {NULL, 0} };

static struct arb_p_link link25[] = {
	{"CONNECT", 26}, {"ABLE", 27}, {NULL, 0} };

static struct arb_p_link link29[] = {
	{"TO", 30}, {NULL, 0} };

struct arb_p_state arb_p_state[] = {
	{-1, link0}, {24, NULL}, {11, link2}, {21, link3}, {23, NULL},
	{22, NULL}, {21, NULL}, {19, link7}, {20, NULL}, {19, NULL},
	{17, link10}, {18, NULL}, {13, link12}, {16, NULL}, {15, NULL},
	{14, NULL}, {13, NULL}, {12, NULL}, {11, NULL}, {10, NULL},
	{9, NULL}, {8, NULL}, {7, NULL}, {6, NULL}, {3, link24},
	{4, link25}, {5, NULL}, {4, NULL}, {3, NULL}, {1, link29},
	{2, NULL}, {0, NULL}  };

