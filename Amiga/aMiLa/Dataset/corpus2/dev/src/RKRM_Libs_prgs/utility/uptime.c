;/* uptime.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfis -j73 uptime.c
Blink FROM LIB:c.o,uptime.o TO uptime LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
    /* Uses SAS C getreg() */

    #include <exec/types.h>
    #include <exec/memory.h>
    #include <dos/dos.h>
    #include <dos/dosextens.h>
    #include <dos/datetime.h>
    #include <utility/date.h>
    #include <dos.h>

    #include <clib/exec_protos.h>
    #include <clib/dos_protos.h>
    #include <clib/utility_protos.h>

    #include <stdlib.h>

    struct Library *UtilityBase;

    LONG main(void);

    LONG main(void)
    {
      struct InfoData *infodata;
      struct DeviceList *ramdevice;
      struct DateStamp *now;
      LONG currenttime, boottime;
      BPTR lock;
      LONG vargs[3];
      LONG rc = RETURN_FAIL;

      /* Fails silently if < 37 */
      if (UtilityBase = OpenLibrary("utility.library", 37))
      {
        if (infodata = AllocMem(sizeof(struct InfoData), MEMF_CLEAR))
        {
          if (now = AllocMem(sizeof(struct DateStamp), MEMF_CLEAR))
          {
            if (lock = Lock("RAM:", SHARED_LOCK))
            {
              if ((Info(lock, infodata)) == DOSTRUE)
              {
                /* Make C pointer */

                ramdevice = BADDR(infodata->id_VolumeNode);

                boottime = SMult32(ramdevice->dl_VolumeDate.ds_Days, 86400) +
                           SMult32(ramdevice->dl_VolumeDate.ds_Minute, 60) +
                           SDivMod32(ramdevice->dl_VolumeDate.ds_Tick,
                                     TICKS_PER_SECOND );

                DateStamp(now);

                currenttime = SMult32(now->ds_Days, 86400) +
                              SMult32(now->ds_Minute, 60) +
                              SDivMod32(now->ds_Tick, TICKS_PER_SECOND);

                currenttime -= boottime;

                if (currenttime > 0)
                {
                  vargs[0] = UDivMod32(currenttime, 86400);

                  vargs[1] = getreg(1);
                  vargs[1] = UDivMod32(vargs[1], 3600);

                  vargs[2] =getreg(1);
                  vargs[2] = UDivMod32(vargs[2], 60);

                  /*
                   * Passing the address of the array allows the VPrintf()
                   * function to access the array contents.  Keep in mind
                   * that VPrintf() does _NOT_ know how many elements are
                   * really valid in the final parameter, and will gleefully
                   * run past the valid arguments.
                   */
                  VFPrintf(Output(),
                           "up for %ld days, %ld hours, %ld minutes\n",
                           vargs );

                  rc = RETURN_OK;
                }
              }
              UnLock(lock);
            }
            FreeMem(now, sizeof(struct DateStamp));
          }
          FreeMem(infodata, sizeof(struct InfoData));
        }
        CloseLibrary(UtilityBase);
      }
      exit(rc);
    }
