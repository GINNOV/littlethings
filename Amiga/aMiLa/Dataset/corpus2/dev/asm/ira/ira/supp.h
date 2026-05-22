/*
 * supp.h
 *
 *  Created on: 8 may 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : supp.h
 *      Purpose  : Headers for extended functions
 *      Copyright: (C)2015-2016 Nicolas Bastien
 */

#ifndef SUPP_H_
#define SUPP_H_

void adrcat(const char *);
char * argopt(int, char **, int *, char *);
uint16_t be16(void *);
uint32_t be32(void *);
void delfile(const char *);
void dtacat(const char *);
char * itoasc(int32_t);
char * itohex(uint32_t, uint32_t);
void mnecat(const char *);
void * myalloc(size_t);
void * mycalloc(size_t);
void * myrealloc(void *, size_t);
char * mystrdup(char *);
uint32_t readbe32(FILE *);
int stccpy(char *, const char *, size_t);
int32_t stcd_base(const char *, int);
int32_t stcd_l(const char *);
int32_t stch_l(const char *);
int32_t parseAddress(const char *);
int stricmp(const char *, const char *);
int strnicmp(const char *, const char *, size_t);
char * strupr(char *);
void wbe32(void *, uint32_t);

#endif /* SUPP_H_ */
