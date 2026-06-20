/* Copyright (c) 1986, Greg McGary */
/* @(#)bool.h	1.1 86/10/09 */

#ifndef _BOOL_H
#define _BOOL_H 1

typedef	int	bool;

#ifndef TRUE
#define	TRUE	(0==0)
#endif	/* TRUE */

#ifndef FALSE
#define	FALSE	(0!=0)
#endif	/* FALSE */

#endif	/* _BOOL_H */
