;/* showprefs.c - Execute me to compile me with SAS C 5.10
LC -b0 -d0 -cfis -v -j73 showprefs.c
Blink FROM showprefs.o TO showprefs LIBRARY LIB:Amiga.lib
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

/*
** showprefs.c - parse and show some info from an IFF Preferences file
** NOTE: This example requires upcoming 2.1 prefs/ include files.
**
** IMPORTANT!! This example is not linked with startup code (eg. c.o).
** It uses strictly direct AmigaDOS stdio, and also demonstrates
** direct ReadArgs argument parsing.  Therefore it is a CLI-only
** example.  If launched from Workbench, packet errors would occur
** since the WbStartup message is still sitting in the process's
** pr_MsgPort, and the code would never be unloaded from memory.
*/

#include <exec/types.h>
#include <dos/dos.h>
#include <libraries/dos.h>
#include <libraries/iffparse.h>
#include <prefs/prefhdr.h>
#include <prefs/font.h>
#include <prefs/icontrol.h>
#include <prefs/input.h>
#include <prefs/overscan.h>
#include <prefs/printergfx.h>
#include <prefs/printertxt.h>
#include <prefs/screenmode.h>
#include <prefs/serial.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>

struct ExecBase *SysBase;
struct Library *DOSBase;
struct Library *IFFParseBase;

static UBYTE *IFFErrTxt[] = {
  "EOF",    /* (end of file, not an error) */
  "EOC",     /* (end of context, not an error) */
  "no lexical scope",
  "insufficient memory",
  "stream read error",
  "stream write error",
  "stream seek error",
  "file corrupt",
  "IFF syntax error",
  "not an IFF file",
  "required call-back hook missing",
  NULL,     /* (return to client, never shown) */
};

LONG main(void)
{
  struct RDArgs *readargs = NULL;
  LONG rargs[2];
  struct IFFHandle *iffhandle;
  struct ContextNode *cnode;
  struct StoredProperty *hdrsp;
  struct StoredProperty *sp;
  UBYTE *filename = NULL;
  LONG ifferror, error = 0, rc = RETURN_OK;

  /* We must set up SysBase (we are not linked with startup code) */
  SysBase = (*((struct Library **) 4));

  /* This no-startup-code example may not be used from Workbench */
  if ((((struct Process *)FindTask(NULL))->pr_CLI)==NULL)
        return(RETURN_FAIL);

  if (DOSBase = OpenLibrary("dos.library", 37)) {
    if (IFFParseBase = OpenLibrary ("iffparse.library", 37)) {

      readargs = ReadArgs("FILE/A", rargs, NULL);
      if( (readargs) && (rargs[0]) ) {

        filename = (UBYTE *)rargs[0];

        /* allocate an IFF handle */
        if (iffhandle = AllocIFF()) {
          /* Open the file for reading */
          if (iffhandle->iff_Stream = (LONG)Open(filename, MODE_OLDFILE)) {
            /* initialize the iff handle */
            InitIFFasDOS (iffhandle);
            if ((ifferror = OpenIFF (iffhandle, IFFF_READ)) == 0) {
              PropChunk(iffhandle, ID_PREF, ID_PRHD);

              PropChunk(iffhandle, ID_PREF, ID_FONT);
              PropChunk(iffhandle, ID_PREF, ID_ICTL);
              PropChunk(iffhandle, ID_PREF, ID_INPT);
              PropChunk(iffhandle, ID_PREF, ID_OSCN);
              PropChunk(iffhandle, ID_PREF, ID_PGFX);
              PropChunk(iffhandle, ID_PREF, ID_PTXT);
              PropChunk(iffhandle, ID_PREF, ID_SCRM);
              PropChunk(iffhandle, ID_PREF, ID_SERL);

              for (;;) {
                ifferror = ParseIFF(iffhandle, IFFPARSE_STEP);

                 if (ifferror == IFFERR_EOC)
                   continue;
                else if (ifferror)
                  break;

                /* Do nothing is this is a PrefHeader chunk,
                 * we'll pop it later when there is a pref
                 * chunk.
                 */
                if (cnode = CurrentChunk(iffhandle))
                  if (cnode->cn_ID == ID_PRHD || cnode->cn_ID == ID_FORM)
                    continue;

                /* Get the preferences header, stored previously */
                hdrsp = FindProp(iffhandle, ID_PREF, ID_PRHD);

                if (sp = FindProp(iffhandle, ID_PREF, ID_FONT)) {
                  Printf("FrontPen:  %ld\n",
                        ((struct FontPrefs *)sp->sp_Data)->fp_FrontPen);
                  Printf("BackPen:   %ld\n",
                        ((struct FontPrefs *)sp->sp_Data)->fp_BackPen);
                  Printf("DrawMode:  %ld\n",
                        ((struct FontPrefs *)sp->sp_Data)->fp_DrawMode);
                  Printf("Font:      %s\n",
                        (LONG)((struct FontPrefs *)sp->sp_Data)->fp_Name);
                  Printf("ta_YSize:  %ld\n",
                        ((struct FontPrefs *)sp->sp_Data)->fp_TextAttr.ta_YSize);
                  Printf("ta_Style:  %ld\n",
                        ((struct FontPrefs *)sp->sp_Data)->fp_TextAttr.ta_Style);
                  Printf("ta_Flags:  %ld\n",
                        ((struct FontPrefs *)sp->sp_Data)->fp_TextAttr.ta_Flags);
                } else   if (sp = FindProp(iffhandle, ID_PREF, ID_ICTL)) {
                  Printf("TimeOut:   %ld\n",
                        ((struct IControlPrefs *)sp->sp_Data)->ic_TimeOut);
                  Printf("MetaDrag:  %ld\n",
                        ((struct IControlPrefs *)sp->sp_Data)->ic_MetaDrag);
                  Printf("WBtoFront: %ld\n",
                        ((struct IControlPrefs *)sp->sp_Data)->ic_WBtoFront);
                  Printf("FrontToBack: %ld\n",
                        ((struct IControlPrefs *)sp->sp_Data)->ic_FrontToBack);
                  Printf("ReqTrue:    %ld\n",
                        ((struct IControlPrefs *)sp->sp_Data)->ic_ReqTrue);
                  Printf("ReqFalse:    %ld\n",
                        ((struct IControlPrefs *)sp->sp_Data)->ic_ReqFalse);
                  /* etc */
                } else if (sp = FindProp(iffhandle, ID_PREF, ID_INPT)) {
                  Printf("PointerTicks:      %ld\n",
                        ((struct InputPrefs *)sp->sp_Data)->ip_PointerTicks);
                  Printf("DoubleClick/Secs:  %ld\n",
                        ((struct InputPrefs *)sp->sp_Data)->ip_DoubleClick.tv_secs);
                  Printf("DoubleClick/Micro: %ld\n",
                        ((struct InputPrefs *)sp->sp_Data)->ip_DoubleClick.tv_micro);
                  /* etc */
                } else if (sp = FindProp(iffhandle, ID_PREF, ID_OSCN)) {
                  Printf("DisplayID:  0x%lx\n",
                        ((struct OverscanPrefs *)sp->sp_Data)->os_DisplayID);
                  /* etc */
                } else if (sp = FindProp(iffhandle, ID_PREF, ID_PGFX)) {
                  Printf("Aspect:     %ld\n",
                        ((struct PrinterGfxPrefs *)sp->sp_Data)->pg_Aspect);
                  /* etc */
                } else if (sp = FindProp(iffhandle, ID_PREF, ID_PTXT)) {
                  Printf("Driver:     %s\n",
                        (LONG)((struct PrinterTxtPrefs *)sp->sp_Data)->pt_Driver);
                  /* etc */
                } else if (sp = FindProp(iffhandle, ID_PREF, ID_SCRM)) {
                  Printf("DisplayID:  0x%lx\n",
                        ((struct ScreenModePrefs *)sp->sp_Data)->sm_DisplayID);
                  /* etc */
                } else if (sp = FindProp(iffhandle, ID_PREF, ID_SERL)) {
                  Printf("BaudRate:   %ld\n",
                        ((struct SerialPrefs *)sp->sp_Data)->sp_BaudRate);
                  /* etc */
                }
              }

              CloseIFF(iffhandle);
            }

            if (ifferror != IFFERR_EOF) {
              rargs[1] = (LONG)IFFErrTxt[-ifferror - 1];
              VFPrintf(Output(), "%s: %s\n", rargs);
              rc = RETURN_FAIL;
            }

            Close(iffhandle->iff_Stream);
          } else
            error = IoErr();

          FreeIFF(iffhandle);
        } else {
          VFPrintf(Output(), "Can't allocate IFF handle\n", NULL);
          rc = RETURN_FAIL;
        }
      } else
        error = IoErr();
      CloseLibrary(IFFParseBase);


      SetIoErr(error);
      if (error) {
        rc = RETURN_FAIL;
        PrintFault(error, filename ? filename : "");
      }
    }

    if(readargs) FreeArgs(readargs);
    CloseLibrary(DOSBase);

  } else {
      rc = RETURN_FAIL;
    }

  return(rc);
}
