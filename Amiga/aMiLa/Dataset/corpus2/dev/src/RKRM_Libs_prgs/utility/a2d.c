;/* a2d.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfis -j73 a2d.c
Blink FROM LIB:c.o,a2d.o TO a2d LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/

/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/
    #include <exec/types.h>
    #include <exec/memory.h>
    #include <dos/datetime.h>
    #include <devices/timer.h>

    #include <clib/exec_protos.h>
    #include <clib/timer_protos.h>
    #include <clib/utility_protos.h>

    #include <stdio.h>

    LONG main(void);

    struct Library *TimerBase;
    struct Library *UtilityBase;

    LONG main(void)
    {
      struct ClockData *clockdata;
      struct timerequest *tr;
      struct timeval *tv;
      LONG seconds;

      if (UtilityBase = OpenLibrary("utility.library", 37))
      {
        if (tr = AllocMem(sizeof(struct timerequest), MEMF_CLEAR))
        {
          if (tv = AllocMem(sizeof(struct timeval), MEMF_CLEAR))
          {
            if (clockdata = AllocMem(sizeof(struct ClockData), MEMF_CLEAR))
            {
              if (!(OpenDevice("timer.device", UNIT_VBLANK, (struct IORequest *)tr, 0) ))
              {
                TimerBase = tr->tr_node.io_Device;

                GetSysTime(tv);

                printf("GetSysTime():\t%d %d\n", tv->tv_secs, tv->tv_micro);

                Amiga2Date(tv->tv_secs, clockdata);

                printf("Amiga2Date():  sec %d min %d hour %d\n", clockdata->sec,
                        clockdata->min, clockdata->hour);

                printf("               mday %d month %d year %d wday %d\n", clockdata->mday,
                       clockdata->month, clockdata->year, clockdata->wday);

                seconds = CheckDate(clockdata);

                printf("CheckDate():\t%ld\n", seconds);

                seconds = Date2Amiga(clockdata);

                printf("Date2Amiga():\t%ld\n", seconds);

                CloseDevice((struct IORequest *)tr);
              }
              FreeMem(clockdata, sizeof(struct ClockData));
            }
            FreeMem(tv, sizeof(struct timeval));
          }
          FreeMem(tr, sizeof(struct timerequest));
        }
        CloseLibrary(UtilityBase);
      }
    }
