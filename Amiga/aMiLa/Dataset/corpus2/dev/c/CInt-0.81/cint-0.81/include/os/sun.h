/******************************************************************************

    MODUL
	os/sun.h

    DESCRIPTION
	Sun-Specific things. This file is read AFTER in_stddef.h.

******************************************************************************/

#ifndef OS_SUN_H
#define OS_SUN_H

/***************************************
	       Includes
***************************************/


/***************************************
     Globale bzw. externe Variable
***************************************/


/***************************************
	 Defines und Strukturen
***************************************/
#ifdef ANSI_C
#   define VOIDPTR	void *
#else
#   define VOIDPTR	char *
#endif


/***************************************
	       Prototypes
***************************************/
/* ---------- stdio ---------- */
extern int    printf   P((const char *, ...));
extern int    fprintf  P((FILE *, const char *, ...));
/* extern char * sprintf  P((char *, const char *, ...)); */
extern int    vprintf  P((const char *, va_list));
extern int    vfprintf P((FILE *, const char *, va_list));
extern char * vsprintf P((char *, const char *, va_list));
extern int    puts     P((const char *));
extern int    fputs    P((const char *, FILE *));
extern FILE * fopen    P((const char *, const char *));
extern FILE * freopen  P((const char *, const char *, FILE *));
extern FILE * fdopen   P((int, const char *));
extern int    fclose   P((FILE *));
extern int    fflush   P((FILE *));
extern char * gets     P((char *));
extern char * fgets    P((char *, FILE *));
extern int    fgetc    P((FILE *));
extern int    getw     P((FILE *));
extern int    fputc    P((FILE *));
extern int    putw     P((FILE *));
extern FILE * popen    P((char *, char *));
extern int    pclose   P((FILE *));
extern FILE * tmpfile  P((void));
extern char * ctermid  P((char *));
extern char * cuserid  P((char *));
extern char * tmpnam   P((char *));
extern char * tempnam  P((char *, char *));
extern int    fread    P((char *, int, int, FILE *));
extern int    fwrite   P((char *, int, int, FILE *));
extern int    system   P((char *));

/* This is here only for keeping GCC silent */
extern unsigned char _flsbuf P((unsigned char, FILE *));


#ifndef SYSV
/* ---------- memory.h ---------- */
extern VOIDPTR memccpy P((VOIDPTR, const VOIDPTR, int, int));
extern VOIDPTR memchr  P((const VOIDPTR, int, int));
#ifndef __GNUC__
extern int     memcmp  P((const VOIDPTR, const VOIDPTR, int));
extern VOIDPTR memcpy  P((VOIDPTR, const VOIDPTR, int));
#endif
extern VOIDPTR memset  P((VOIDPTR, int, int));
#endif


/* ---------- ctype.h ---------- */
extern int    toupper  P((int));
extern int    tolower  P((int));


/* ---------- string.h --------- */
extern char * strcat	  P((char *, char *));
extern char * strncat	  P((char *, char *, int));
extern char * strdup	  P((char *));
#ifndef __GNUC__
extern char * strcpy	  P((char *, char *));
extern int    strcmp	  P((char *, char *));
#endif
extern int    strncmp	  P((char *, char *, int));
extern int    strcasecmp  P((char *, char *));
extern int    strncasecmp P((char *, char *, int));
extern char * strncpy	  P((char *, char *, int));

/* ----------- math.h ---------- */
extern double strtod	  P((const char *, char **));
extern double atof	  P((const char *));


#endif /* OS_SUN_H */

/******************************************************************************
*****  ENDE os/sun.h
******************************************************************************/
