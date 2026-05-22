/*
    Mklib 1.0 - a source file generator for Amiga shared libraries
    Compiled with Manx v3.6a small code model/16 bit int. (see makefile)

    copyright 1988 Edwin Hoogerbeets

    This software and the files it produces are freely redistributable
    as long there is no charge beyond reasonable copy fees and as long
    as this notice stays intact.

    Thanks to Jimm Mackraz for Elib on Fish 87, from which much of this
    program is lifted. Also thanks to Neil Katin for his mylib.asm upon
    which elib is based.
*/
#define MAXFUNC 50
#define MAXLEN  64

/* definitions of token types */
#define NOTHING 0       /* end of input     */
#define IDENT   1       /* identifier       */
#define OBRACE  2       /* open brace {     */
#define CBRACE  3       /* close brace }    */
#define LONGT   4       /* 'LONG' keyword   */
#define OBRACK  5       /* open bracket (   */
#define CBRACK  6       /* close bracket )  */
#define COMMA   7       /* comma ,          */
#define EXT     8       /* 'extern' keyword */
#define SEMI    9       /* semicolon ;      */
#define CHAR    10      /* 'char' keyword   */
#define MYNAME  11      /* 'myname' token   */
#define STAR    12      /* * is born yuk yuk*/
#define QUOTE   13      /* quote "          */
#define MYID    14      /* 'myid' keyword   */
#define OTHER   20      /* everything else  */

char myname[MAXLEN];    /* storage for final name of library */
int mynamedef = 0;      /* is myname defined? */
char myid[MAXLEN];      /* storage for final id of library */
int myiddef = 0;        /* is myid defined ? */

typedef struct {        /* structure to hold function names */
    char name[MAXLEN];
    int numofargs;
} ftable;

ftable functable[MAXFUNC];
int ftcounter = 0;

char tempfunc[MAXLEN];
int tempc = 0;

FILE *startup, *interface, *link, *romtag, *makefile, *lib, *inc, *linkh;

void shutdown();

extern char *asmheader[], *cheader[], *makeheader[], *startupcode[];
extern char *rtag[], *mandatory[], *incbody[], *faceheader[], *linkhead[];
extern char *link2[], *face2[], *makefooter[], *facemid[];

#define NUMOFREGS 14

char *regs[] = {
    "d0", "d1", "a0", "a1", "d2", "d3", "d4", "d5",
    "d6", "d7", "a2", "a3", "a4", "a5", NULL
};

