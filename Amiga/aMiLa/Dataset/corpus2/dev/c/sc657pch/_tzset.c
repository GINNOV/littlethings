/***
*
*          Copyright © 1996  SAS Institute, Inc.
*
* name             __tzset -- set time zone parameters
*
* synopsis         __tzset();
*
* description      This function sets the time zone variables __daylight,
*                  __timezone, and __tzname from the information in the
*                  TZ environment variable.
*
***/

#include <time.h>
#include <stdlib.h>
#include <string.h>



void __tzset()
{
    char   *p;
    int    x;


#ifdef LESS_GETENV

    p = _TZ;
    if (p == NULL)
    {
       p = __getenv("TZ");
       if (p == NULL) 
          p = "CST6";
       _TZ = p;
    }
    else return;

#else

    char *q;
    q = p = __getenv("TZ");

    if (p == NULL)
        p = _TZ;

#endif

    if (p == NULL)
        p = "CST6";

    __tzstn[0] = p[0];
    __tzstn[1] = p[1]; 
    __tzstn[2] = p[2];
    __tzstn[3] = '\0';

    __tzname[0] = __tzstn;

    p += __stcd_i(&p[3], &x) + 3;
    __timezone = x * 3600;

    if (*p != '\0') {
        __tzdtn[0] = p[0];
        __tzdtn[1] = p[1];
        __tzdtn[2] = p[2];
        __tzdtn[3] = '\0';
        __daylight = 1;
    } else {
        __tzdtn[0] = '\0';
        __daylight = 0;
    }

    __tzname[1] = __tzdtn;
    
#ifndef LESS_GETENV
    if (q) free(q);
#endif
}
