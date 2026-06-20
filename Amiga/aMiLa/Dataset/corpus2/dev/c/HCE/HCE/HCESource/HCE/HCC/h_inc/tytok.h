/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	tytok.h
 *
 *	keyword token values
 *
 * Modified by Detlef Wuerkner for AMIGA
 * Changes marked with TETISOFT
 */

/* CHANGED BY TETISOFT to get the same Result if ENUMS defined or not */

#ifndef ENUMS
#define K_EXTERN	'A'
#define K_AUTO		'B'
#define K_REGISTER	'C'
#define K_TYPEDEF	'D'
#define K_STATIC	'E'

#define ENUM_SC		'F'	/* storage class for enum item */
#define HERE_SC		'G'	/* storage class for glb def */
#define T_UCHAR		'H'

/* ADDED BY TETISOFT */
#define T_USHORT	'I'

#define T_ULONG		'J'

#define K_LONG		'K'
#define K_SHORT		'L'
#define K_UNSIGNED	'M'

#define K_INT		'N'
#define K_CHAR		'O'
#define K_FLOAT		'P'
#define K_DOUBLE	'Q'
#define K_VOID		'R'

#define K_UNION		'S'
#define K_ENUM		'T'
#define K_STRUCT	'U'

#else
enum {
	K_EXTERN = 'A', K_AUTO, K_REGISTER, K_TYPEDEF, K_STATIC,
	ENUM_SC, HERE_SC,
	T_UCHAR,

/* ADDED BY TETISOFT */
	T_USHORT,

	T_ULONG,
	K_LONG, K_SHORT, K_UNSIGNED,
	K_INT, K_CHAR, K_FLOAT, K_DOUBLE, K_VOID,
	K_UNION, K_ENUM, K_STRUCT
};
#endif

#define FIRST_SC	K_EXTERN
#define LAST_SC		K_STATIC

#define FIRST_BAS	T_UCHAR
#define LAST_BAS	K_VOID
