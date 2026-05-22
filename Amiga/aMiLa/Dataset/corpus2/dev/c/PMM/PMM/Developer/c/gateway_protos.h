/*
**      prototypes for gateway.library
**
**      (C) Copyright 1998-2000 Michaela Prüß
**      All Rights Reserved.
*/

#ifndef CLIB_GATEWAY_PROTOS_H
#define CLIB_GATEWAY_PROTOS_H

#ifndef GATEWAY_GATEWAY_H
#include "gateway.h"
#endif /* GATEWAY_GATEWAY_H */

#include <exec/types.h>

/* -- start functions -- */

ULONG GateRequest(UBYTE *title_d1,UBYTE *body,UBYTE *gadgets);
void trim(UBYTE *trptr);
void rtrim(UBYTE *trptr);
void trim_include(UBYTE *trptr);
void mail_trim(UBYTE *trptr,long fkt);
void set(UBYTE *lbuff,long slen);
void lset(UBYTE *lbuff,long slen);
void lsetmin(UBYTE *lbuff,long slen);
long instr(UBYTE *sa,UBYTE *sb);
void midstr(UBYTE *mstr,long pos,long laenge);
void newstr(UBYTE *istr,UBYTE *nstr,long pos,long len);
long wordwrp(UBYTE *line,UBYTE *rest,long len);
void kill_ansi(UBYTE *buffer);
char *fn_splitt(char *src,char *drive,char *path,char *file,char *ext);
char *fn_build(char *dst,char *drive,char *path,char *file,char *ext);
ULONG time_to_zahl(UBYTE *ti);
ULONG date_to_zahl(UBYTE *da);
ULONG date_to_day(ULONG date);
void addval(UBYTE *str,ULONG n);
char *ltofa(char *tx_d1,ULONG l);
void string(UBYTE *spstr,long num,long ch);
BOOL newer(UBYTE *d1,UBYTE *t1,UBYTE *d2,UBYTE *t2);
void upstr(UBYTE *trptr);
void lowstr(UBYTE *trptr);
long StrCaseCmp(char *s1,char *s2);
char *strdup(const char *s);
void swapmem(char *src,char *dst,long n);
long memncmp(char *a,char *b,long length);
char *index(char *dst,long c);
void trim_cr(UBYTE *trptr);
long instr_pat(UBYTE *sa,UBYTE *sb);

/* -- end functions -- */
