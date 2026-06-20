/******************************************************************************

    MODUL
	unix.h

    DESCRIPTION
	Include-File fuer unix.c

	Es werden folgende externe Symbole benutzt:

	    ANSI_C
	    USE_VOIDPTR 	"void *" kann benutzt werden (wird nicht
				beachtet, wenn ANSI_C gesetzt ist).
	    XMD_H		Wenn X11/Xmd.h geladen wurde werden
				BYTE und BOOL nicht mehr definiert.

******************************************************************************/

#ifndef UNIX_H
#define UNIX_H

/***************************************
	       Includes
***************************************/
#ifndef EXEC_NODES_H
#   include <exec/nodes.h>
#endif


/***************************************
     Globale bzw. externe Variable
***************************************/


/***************************************
	 Defines und Strukturen
***************************************/
#ifndef EXEC_TYPES_H
#   define GLOBAL      extern
#   define IMPORT      extern
#   define STATIC      static
#   define REGISTER    register

#   ifndef VOID
#	define VOID void
#   endif /* VOID */

#   if defined(ANSI_C) || defined(USE_VOIDPTR)
	typedef void * APTR;		    /* 32-bit untyped pointer */
#   else
	typedef char * APTR;
#   endif


    typedef long	    LONG;	/* signed 32bit quantity */
    typedef unsigned long   ULONG;	/* dito, unsigned */
    typedef unsigned long   LONGBITS;	/* 32 bits manipulated individually */
    typedef short	    WORD;	/* dito, 16bit */
    typedef unsigned short  UWORD;
    typedef unsigned short  WORDBITS;
#   ifndef XMD_H
#	ifdef __STDC__
	    typedef signed char     BYTE;	/* signed 8bit quantity */
#	else /* !__STDC__ */
	    typedef char	    BYTE;
#	endif /* !__STDC__ */
#   endif /* !XMD_H */
    typedef unsigned char   UBYTE;
    typedef unsigned char   BYTEBITS;
    typedef short	    RPTR;	/* Signed 16bit relative pointer */
    typedef unsigned char * STRPTR;	/* String-pointer (NULL-terminated) */

    typedef float	    FLOAT;
    typedef double	    DOUBLE;
#   ifndef XMD_H
	typedef char		BOOL;
#   endif /* !XMD_H */
    typedef unsigned char   TEXT;

#   ifndef TRUE
#	define TRUE	1
#   endif
#   ifndef FALSE
#	define FALSE	0
#   endif
#   ifndef NULL
#	define NULL	0L
#   endif

#   define BYTEMASK    0xFF
#endif /* EXEC_TYPES_H */


/*
    Um Strukturen, die auf dem Stack aufgebaut werden einlesen zu koennen,
    muessen Sie umgewandelt werden, weil verschiedene Rechner Parameter anders
    auf dem Stack ablegen. In diesem Enum stehen die verschiedenen Typen, die
    zur Verfuegung stehen:
*/

typedef enum
{
    __DT_BYTE,	    /* 1 Byte (8 Bit): char, UBYTE, ... */
    __DT_WORD,	    /* 1 Word (16 Bit): short, WORD, ... */
    __DT_LONG,	    /* 1 Langwort (32 Bit): long, LONG, ... */
    __DT_INT,	    /* 1 Int (16 oder 32 Bit): int */
    __DT_PTR,	    /* Zeiger (32/64 Bit): char *, APTR, ... */
    __DT_FLOAT,     /* Float (32 Bit IEEE): float, FLOAT, ... */
    __DT_DOUBLE     /* Double (64 Bit IEEE): double, DOUBLE, ... */
} DataType;


/*
    Die folgende Struktur definiert den Aufbau einer Struktur, d.h. welches
    Feld wo steht und welchen Typ es hat:
*/

struct StructEntryTypeDef
{
    ULONG    setd_Offset;	/* Offset in der Struktur in Bytes */
    DataType setd_Type; 	/* Typ des Eintrags */
};


/*
    Alles was jetzt noch fehlt ist eine ID und Zusatzinformationen:
*/

struct StructDescription
{
    struct MinNode sd_Node;	/* Fuer Verkettung */
    ULONG	   sd_ID;	/* ID fuer die Struktur */
    ULONG	   sd_Size;	/* Groesse der Struktur in Bytes */
    ULONG	   sd_NumSETD;	/* Anzahl der Eintraege in der
				   StructEntryTypeDef-Struktur */
    struct StructEntryTypeDef * sd_SETD;
				/* Beschreibung der Eintraege */
};

#define movmem(src,dst,sz)      memmove ((char *)dst, (char *)src, (int)sz)


/***************************************
	       Prototypes
***************************************/
#ifndef HAS_MEMMOVE
    extern APTR memmove P((APTR, APTR, ULONG));
#endif


#endif /* UNIX_H */

/******************************************************************************
*****  ENDE unix.h
******************************************************************************/
