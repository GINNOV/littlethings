#ifndef XADMASTER_CONVERTE_C
#define XADMASTER_CONVERTE_C

/* Programmheader

	Name:		ConvertE.c
	Main:		xadmaster
	Versionstring:	$VER: ConvertE.c 1.2 (04.07.2000)
	Author:		SDI, Kyzer
	Distribution:	Public Domain
	Description:	endian conversion macros

 1.0   22.08.1999 : first version
 1.1   22.06.2000 : improved version by Kyzer, removed EndSet funcs
 1.2   04.07.2000 : more compiler checks, portability fixes
*/

/* macros to use:
 * EndGetXXX(a)  - reads value of endianness XXX from memory.
 *                 'a' should be of type 'char *' or 'unsigned char *'
 * EndConvXXX(a) - converts expression/value/var of endianness XXX to
 *                 the correct endianness for this architecture.
 *
 * XXX can be:
 * M32 - big-endian Motorola format, 32 bit value
 * M16 - big-endian Motorola format, 16 bit value
 * I32 - little-endian Intel format, 32 bit value
 * I16 - little-endian Intel format, 16 bit value
 *
 * Note that the EndConvXXX macros only work for architectures that are
 * themselves little- or big-endian, and only work if the defines tested
 * below reveal the correct endianness of the architecture being compiled for.
 * Define either XAD_BIGENDIAN or XAD_LITTLEENDIAN.
 *
 * It is recommended that you only use the EndGetXXX() macros, as these are
 * endian-neutral, and even work on middle-endian machines like PDPs or
 * switchable-endian machines like PPCs.
 *
 * Keep in mind, that the macros require calculation time, so avoid to use
 * them double time. Call them once and reuse results.
 */

#define EndGetM32(a)  ((((a)[0])<<24)|(((a)[1])<<16)|(((a)[2])<<8)|((a)[3]))
#define EndGetM16(a)  ((((a)[0])<<8)|((a)[1]))
#define EndGetI32(a)  ((((a)[3])<<24)|(((a)[2])<<16)|(((a)[1])<<8)|((a)[0]))
#define EndGetI16(a)  ((((a)[1])<<8)|((a)[0]))

/* private */
#define _xecswap16(a) ((((a) & 0x00FF) <<  8) | (((a) >>  8) & 0x00FF))
#define _xecswap32(a) ((((a) & 0x00FF) << 24) | (((a) & 0xFF00) <<  8) |  \
                       (((a) >>  8) & 0xFF00) | (((a) >> 24) & 0x00FF))
/* some future music */
#define _xecswap64(a) (_xecswap32((a) >> 32) | (_xecswap32(a) << 32))


/* if XAD_BIGENDIAN or XAD_LITTLEENDIAN is defined, use that instead of
 * making compiler tests. Otherwise, all Unix systems endianness can be
 * tested with the autoconf AC_C_BIGENDIAN test (defines WORDS_BIGENDIAN),
 * otherwise it's generally safe to assume little-endianness due to the
 * extreme number of Intel PCs and compilers out there. Big-endian non-unix
 * exceptions would be Amiga or 68k Apple Macintosh (MPW compiler or
 * CodeWarrior)
 */
#if !defined(XAD_BIGENDIAN) && !defined(XAD_LITTLEENDIAN)
# if defined(WORDS_BIGENDIAN) || defined(AMIGA) || defined(__SC__) || defined(__MWERKS__)
#  define XAD_BIGENDIAN
# else
#  define XAD_LITTLEENDIAN
# endif
#endif

#if defined(XAD_BIGENDIAN)
# define EndConvM32(a)	(a)
# define EndConvM16(a)	(a)
# define EndConvI32(a)	_xecswap32(a)
# define EndConvI16(a)	_xecswap16(a)
#elif defined(XAD_LITTLEENDIAN)
# define EndConvM32(a)	_xecswap32(a)
# define EndConvM16(a)	_xecswap16(a)
# define EndConvI32(a)	(a)
# define EndConvI16(a)	(a)
#else
# error Either XAD_BIGENDIAN or XAD_LITTLEENDIAN must be defined!
#endif

#endif /* XADMASTER_CONVERTE_C */
