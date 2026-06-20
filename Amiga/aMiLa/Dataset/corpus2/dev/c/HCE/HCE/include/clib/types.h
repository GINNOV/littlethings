/*
 *	TYPES.H
 */

#ifndef	TYPES_H
#define	TYPES_H

#ifndef VOID
#define	VOID	void
#endif

/*
 * typedef	unsigned char	BYTE;
 * typedef	unsigned int	WORD;
 * typedef	unsigned long	LONG;
 */

typedef	unsigned char	uchar;		/* 8-bit unsigned     */
typedef	unsigned short	ushort;		/* 16-bit unsigned    */
typedef	unsigned int	uint;		/* 16/32-bit unsigned */
typedef	unsigned long	ulong;		/* 32-bit unsigned    */

typedef	unsigned char	u_char;		/* 8-bit unsigned     */
typedef	unsigned short	u_short;	/* 16-bit unsigned    */
typedef	unsigned int	u_int;		/* 16/32-bit unsigned */
typedef	unsigned long	u_long;		/* 32-bit unsigned    */

typedef	unsigned char	dev_t;		/* device (drive) id    */
typedef	unsigned long	fpos_t;		/* file position offset */
typedef	unsigned long	time_t;		/* raw date/time        */
typedef	long		clock_t;	/* 200Hz clock ticks    */

#endif TYPES_H
