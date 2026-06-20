/*
**    GetModeInfo
**
**        © 1996 by Timo C. Nentwig
**        All Rights Reserved !
**
**        Tcn@oxygen.in-berlin.de
**
*/

/// #include

#include "gm_GST.h"

///
/// proto

static BOOL    OpenLibs        (VOID);
static VOID    CloseLibs       (VOID);
static VOID    EvalArgs        (VOID);
static VOID    InitSettings    (VOID);

///

struct    Library               *AslBase;
struct    GfxBase               *GfxBase;
struct    ScreenModeRequester   *ModeRequest;

    // C:Version

static const STRPTR    __ver = "\0$VER: " PRG_TITLE " " PRG_VERSION " " __AMIGADATE__;

    // Libraries

static const struct { STRPTR Name; ULONG Version; APTR *Library; } Table [] =
{

    "dos.library",      LIBRARY_MINIMUM, (APTR *) &DOSBase,
    "asl.library",      LIBRARY_MINIMUM, (APTR *) &AslBase,
    "graphics.library", LIBRARY_MINIMUM, (APTR *) &GfxBase,

    NULL

};

/// main ()

ULONG
main (VOID)
{

    ULONG   Result = RETURN_FAIL;

    if (OpenLibs())
    {

        InitSettings();

        EvalArgs();

        if (ModeRequest = AllocAslRequest (ASL_ScreenModeRequest, NULL))
        {

            if (AslRequestTags (ModeRequest, TAG_DONE))
            {

                struct
                {

                    struct    DisplayInfo      Display;
                    struct    MonitorInfo      Monitor;
                    struct    DimensionInfo    Dimension;
                    struct    NameInfo         Name;

                } Info;

                Result = RETURN_OK;

                GetDisplayInfoData (NULL, (STRPTR) &Info . Name,  sizeof (struct NameInfo), DTAG_NAME, ModeRequest -> sm_DisplayID);

                FPrintf (Output(), "[2m[1m%s[0m\n", Info . Name . Name);
                FPrintf (Output(), "\tModeID (dec)    : %ld\n",     ModeRequest -> sm_DisplayID);
                FPrintf (Output(), "\tModeID (hex)    : 0x%08lx\n", ModeRequest -> sm_DisplayID);

                if (Set . Info . Monitor)
                {

                    if (GetDisplayInfoData (NULL, (STRPTR) &Info . Monitor, sizeof (struct MonitorInfo), DTAG_MNTR, ModeRequest -> sm_DisplayID))
                    {

                        FPrintf (Output(), "\n[1mMonitor Info:[0m\n\n");
                        FPrintf (Output(), "\tTotalRows       : %ld\n", Info . Monitor . TotalRows);
                        FPrintf (Output(), "\tTotalColorClocks: %ld\n", Info . Monitor . TotalColorClocks);
                        FPrintf (Output(), "\tMinRow          : %ld\n", Info . Monitor . MinRow);
                        FPrintf (Output(), "\tCompatibility   : %ld\n", Info . Monitor . Compatibility);

                    }

                }

                if (Set . Info . Display)
                {

                    if (GetDisplayInfoData (NULL, (STRPTR) &Info . Display, sizeof (struct DisplayInfo), DTAG_DISP, ModeRequest -> sm_DisplayID))
                    {

                        FPrintf (Output(), "\n[1mDisplayInfo Info:[0m\n\n");
                        FPrintf (Output(), "\tNotAvailable    : %ld\n", Info . Display . NotAvailable);
                        FPrintf (Output(), "\tPixelSpeed      : %ld\n", Info . Display . PixelSpeed);
                        FPrintf (Output(), "\tNumStdSprites   : %ld\n", Info . Display . NumStdSprites);
                        FPrintf (Output(), "\tRedBits         : %ld\n", Info . Display . RedBits);
                        FPrintf (Output(), "\tGreenBits       : %ld\n", Info . Display . GreenBits);
                        FPrintf (Output(), "\tBlueBits        : %ld\n", Info . Display . BlueBits);

                    }

                }

                if (Set . Info . Dimension)
                {

                    if (GetDisplayInfoData (NULL, (STRPTR) &Info . Dimension, sizeof (struct DimensionInfo), DTAG_DIMS, ModeRequest -> sm_DisplayID))
                    {

                        FPrintf (Output(), "\n[1mDimension Info:[0m\n\n");
                        FPrintf (Output(), "\tMaxDepth        : %ld\n", Info . Dimension . MaxDepth);
                        FPrintf (Output(), "\tMinRasterWidth  : %ld\n", Info . Dimension . MinRasterWidth);
                        FPrintf (Output(), "\tMinRasterHeight : %ld\n", Info . Dimension . MinRasterHeight);
                        FPrintf (Output(), "\tMaxRasterWidth  : %ld\n", Info . Dimension . MaxRasterWidth);
                        FPrintf (Output(), "\tMaxRasterHeight : %ld\n", Info . Dimension . MaxRasterHeight);

                    }

                }

            }
            else
            {

                FreeAslRequest (ModeRequest);

            }

        }

        CloseLibs();

    }

    return (Result);

}

///

/// InitSetting ()

    /*
     *    FUNCTION    Initialize settings structure.
     *
     *    NOTE
     *
     *    EXAMPLE     InitSettings ();
     *
     */


static VOID
InitSettings (VOID)
{

    Set . Info . Dimension = FALSE;
    Set . Info . Monitor   = FALSE;
    Set . Info . Display   = FALSE;

}

///
/// EvalArgs ()

    /*
     *    FUNCTION    Evaluate given shell arguments
     *
     *    NOTE
     *
     *    EXAMPLE     EvalArgs ();
     *
     */


static VOID
EvalArgs (VOID)
{

    #define    ARG_TEMPLATE    "DI=DIMENSIONINFO/S,MI=MONITORINFO/S,DII=DISPLAYINFO/S"

    enum    {

                DIMENSIONINFO,
                MONITORINFO,
                DISPLAYINFO,

                ARG_COUNT

            };

    STRPTR   *ArgArray;

    if (ArgArray = (STRPTR *) AllocVec (sizeof (STRPTR) * (ARG_COUNT), MEMF_ANY | MEMF_CLEAR))
    {

        struct    RDArgs   *ArgsPtr;

        if (ArgsPtr = (struct RDArgs *) AllocDosObject (DOS_RDARGS, TAG_END))
        {

            ArgsPtr -> RDA_ExtHelp  =  "[2m" PRG_TITLE " " PRG_VERSION "\n"
                                       "Copyright © " PRG_YEAR " by " PRG_AUTHOR "[0m\n"
                                       "All Rights Reserved !\n\n"
                                        PRG_EMAIL "\n";

            if (ReadArgs (ARG_TEMPLATE, (LONG *) ArgArray, ArgsPtr))
            {

                if (ArgArray [DIMENSIONINFO])    Set . Info . Dimension = TRUE;
                if (ArgArray [MONITORINFO]  )    Set . Info . Monitor   = TRUE;
                if (ArgArray [DISPLAYINFO]  )    Set . Info . Display   = TRUE;

                FreeArgs (ArgsPtr);

            }

            FreeDosObject (DOS_RDARGS, ArgsPtr);

        }

        FreeVec (ArgArray);

    }

}

///

/// OpenLibs ()

    /*
     *    FUNCTION    Open a required libraries.
     *
     *    NOTE        <Table> is defined above.
     *
     *    EXAMPLE     OpenLibs ();
     *
     */


static BOOL
OpenLibs (VOID)
{

    LONG    i;

        // Open libraries

    for (i = 0; Table [i] . Name != NULL; i++)
    {

            // Failed to open a library

        if ( ! (*Table [i] . Library = OpenLibrary (Table [i] . Name, Table [i] . Version)))
        {

            FPrintf (Output(), PRG_TITLE ": Failed to open \"%s\" V%ld+ !\n", Table [i] . Name, Table [i] . Version);
            return (FALSE);

        }

    }

    return (TRUE);

}

///
/// CloseLibs ()

    /*
     *    FUNCTION    Close all opened libraries.
     *
     *    NOTE        <Table> is defined above.
     *
     *    EXAMPLE     CloseLibs ();
     *
     */


static VOID
CloseLibs (VOID)
{

    LONG    i;

        // Close libraries

    for (i = 0; Table [i] . Name != NULL; i++)
    {

        CloseLib (*Table [i] . Library);

    }

}

///

