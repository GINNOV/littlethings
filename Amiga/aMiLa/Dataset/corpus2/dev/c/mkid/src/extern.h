/* Copyright (c) 1986, Greg McGary */
/* @(#)extern.h	1.1 86/10/09 */

#include "bool.h"

/* miscellaneous external declarations */

        /* basename.c */

char *basename(char *path);
char *dirname(char *path);

        /* bitcount.c */

int bitCount(register unsigned mask);

        /* bitops.c */

char *bitsset(register char *s1, register char *s2, register int n);
char *bitsclr(register char *s1, register char *s2, register int n);
char *bitsand(register char *s1, register char *s2, register int n);
char *bitsxor(register char *s1, register char *s2, register int n);
int bitstst(register char *s1, register char *s2, register int n);
int bitsany(register char *s, register int n);

        /* bitsvec.c */

int vecToBits(register char *bitArray, register char *vec, int size);
int bitsToVec(register char *vec, char *bitArray, int bitCount, int size);
char *intToStr(register int i, int size);
int strToInt(register char *bufp, int size);

        /* document.c */

void document(char **doc);

        /* gets0.c */

int fgets0(char *buf0, int size, register FILE *inFILE);

        /* getsFF.c */

int getsFF(char *buf0, register FILE *inFILE);
void skipFF(register FILE *inFILE);

        /* getscan.c */

void setAdaArgs(char *lang, int op, char *arg);
char *getAdaId(FILE *inFILE, int *flagP);
void setPascalArgs(char *lang, int op, char *arg);
char *getPascalId(FILE *inFILE, int *flagP);
void setTextArgs(char *lang, int op, char *arg);
char *getTextId(FILE *inFILE, int *flagP);
void setRoffArgs(char *lang, int op, char *arg);
char *getRoffId(FILE *inFILE, int *flagP);
void setTeXArgs(char *lang, int op, char *arg);
char *getTeXId(FILE *inFILE, int *flagP);
void setLispArgs(char *lang, int op, char *arg);
char *getLispId(FILE *inFILE, int *flagP);
char *getLanguage(char *suffix);
char *(*getScanner(char *lang))(FILE *inFILE, int *flagP);
void setScanArgs(int op, char *arg);

        /* hash.c */

char *hashSearch(char *key, char *base, int nel, int width, int (*h1 )(char *), int (*h2 )(char *), int (*compar )(char *, char *), long *probes);
int h1str(register char *key);
int h2str(register char *key);

        /* init.c */

FILE *initID(char *idFile, struct idhead *idhp, struct idarg **idArgs);

        /* opensrc.c */

FILE *openSrcFILE(char *path, char *sccsDir, char *rcsDir);
char *getSCCS(char *dir, char *base, char *sccsDir);
char *coRCS(char *dir, char *base, char *rcsDir);

        /* paths.c */

char *spanPath(char *dir, char *arg);
char *skipJunk(char *path);
char *rootName(char *path);
char *suffName(char *path);
bool canCrunch(char *path1, char *path2);
char *getDirToName(char *topName);

        /* scan-asm.c */

char *getAsmId(FILE *inFILE, int *flagP);
void setAsmArgs(char *lang, int op, char *arg);

        /* scan-c.c */

char *getCId(FILE *inFILE, int *flagP);
void setCArgs(char *lang, int op, char *arg);

        /* stoi.c */

int radix(register char *name);
int stoi(char *name);
int otoi(char *name);
int dtoi(char *name);
int xtoi(char *name);

        /* strsav.c */

char *strsav(const char *s);
char *strnsav(const char *s, int n);

        /* tty.c */

void restoretty(void);
void savetty(void);
void chartty(void);
void linetty(void);

        /* uerror.c */

char *uerror(void);
void filerr(char *syscall, char *fileName);

        /* wmatch.c */

bool wordMatch(char *name0, register char *line);

        /* memory.c */

void *xmalloc(size_t);
void *xcalloc(size_t,size_t);

extern char *MyName;
