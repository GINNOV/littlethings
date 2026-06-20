#ifndef _INCLUDE_WBSTARTUP_H
#define _INCLUDE_WBSTARTUP_H

/*
**  $VER: wbstartup.h 1.01 (7.2.97)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif

void wbmain(struct WBStartup *);

#ifdef __cplusplus
}
#endif

#ifdef WBSTART_LIKE_SAS

/*

For all those how really like that dangerous kind of starting programs
from workbench.

*/

#ifdef __cplusplus
extern "C"
#endif
void main(int, char *[]);

#ifdef __cplusplus
extern "C"
#endif
void wbmain(struct WBStartup *wb)
{
	main(0,(char **) wb);
}

#endif // WBSTART_LIKE_SAS

#endif
