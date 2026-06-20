/* Copyright (c) 1986, Greg McGary */
/* @(#)radix.h	1.1 86/10/09 */

#define	RADIX_DEC	(1 << (10 - 1))
#define	RADIX_OCT	(1 << (010 - 1))
#define	RADIX_HEX	(1 << (0x10 - 1))
#define	RADIX_ALL	(RADIX_DEC|RADIX_OCT|RADIX_HEX)
