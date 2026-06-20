
#include "FreeDB.h"

/***********************************************************************/

#define ARG_DEVICENAME      "DEVICENAME"
#define ARG_DEVICE          "DEVICE"
#define ARG_UNIT            "UNIT"
#define ARG_LUN             "LUN"
#define ARG_NTUSESPACE      "NTUSESPACE"

#define TEMPLATE            ARG_DEVICENAME","ARG_DEVICE"/K,"ARG_UNIT"/K/N,"ARG_LUN"/K/N,"ARG_NTUSESPACE"/S"

#define GETNUM(a)           (*((LONG *)a))

/***********************************************************************/

LONG ASM
parseArg(REG(a0) struct global *g)
{
    register LONG res;

    if (g->wbs)
    {
        register struct Library *IconBase;

        if (IconBase = OpenLibrary("icon.library",37))
        {
            register struct DiskObject  *icon;
            register struct WBArg       *args;
            register BPTR               oldDir;

            args = g->wbs->sm_ArgList;
            oldDir = CurrentDir(args[0].wa_Lock);

            if (icon = GetDiskObject(args[0].wa_Name))
            {
                register STRPTR value;

                if (value = FindToolType(icon->do_ToolTypes,ARG_DEVICE))
                {
                    stccpy(g->device,value,sizeof(g->device));
                    g->dtag = FREEDBA_Device;
                }
                else
                {
                    if (!(value = FindToolType(icon->do_ToolTypes,ARG_DEVICENAME)))
                        value = DEF_DEVICENAME;
                    stccpy(g->device,value,sizeof(g->device));
                    g->dtag = FREEDBA_DeviceName;
                }

                if (value = FindToolType(icon->do_ToolTypes,ARG_UNIT))
                    g->unit = (UWORD)atoi(value);
                else g->unit = DEF_UNIT;

                if (value = FindToolType(icon->do_ToolTypes,ARG_LUN))
                    g->lun = (UBYTE)atoi(value);
                else g->lun = DEF_LUN;

                if (FindToolType(icon->do_ToolTypes,ARG_NTUSESPACE))
                    g->flags |= GFLG_NTUSESPACE;

                FreeDiskObject(icon);
            }

            CurrentDir(oldDir);
            CloseLibrary(IconBase);
            res = 1;
        }
        else res = 0;
    }
    else
    {
        register struct RDArgs  *ra;
        APTR                    arg[5] = {0};

        if (ra = ReadArgs(TEMPLATE,(LONG *)arg,NULL))
        {
            if (arg[0]) stccpy(g->device,arg[0],sizeof(g->device));
            else
            {
                if (arg[1])
                {
                    stccpy(g->device,arg[1],sizeof(g->device));
                    g->dtag = FREEDBA_Device;
                }
                else
                {
                    stccpy(g->device,DEF_DEVICENAME,sizeof(g->device));
                    g->dtag = FREEDBA_DeviceName;
                }
            }

            if (arg[2]) g->unit = (UWORD)GETNUM(arg[2]);
            else g->unit = DEF_UNIT;

            if (arg[3]) g->lun = (UBYTE)GETNUM(arg[3]);
            else g->lun = DEF_LUN;

            if (arg[4]) g->flags |= GFLG_NTUSESPACE;

            FreeArgs(ra);
            res = 1;
        }
        else
        {
            PrintFault(IoErr(),PRG);
            res = 0;
        }
    }

    return res;
}

/****************************************************************************/
