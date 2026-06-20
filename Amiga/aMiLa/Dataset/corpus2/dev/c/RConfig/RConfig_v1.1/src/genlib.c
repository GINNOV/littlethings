/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: genlib.c
 * Description: Library generator
 * Comments: Calls external 'cc' to compile source with appropriate flags;
 *   calls external 'lb' to create library module
 */

#include <exec/types.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/exec_protos.h>
#include <stdio.h>
#include <time.h>
#include "rc2.h"

extern UWORD WaitPointerImage[];

extern void ClearMsgPort(struct MsgPort *mport);

extern int alloca_mode;
extern int setjmp_mode;
extern int main_mode;
extern int stkchk_mode;

extern int integer_mode;    /* 32 bits vs 16 bits */
extern int data_mode;       /* small model vs large model */

extern ULONG ccopts[10];    /* ccopts values */
extern int uservars;        /* precedence for user specified register vars */

extern struct FileRequester *fr;

#define THRESHHOLD  2768    /* min. threshhold */
#define STACKSIZE   8192    /* must be greater than threshhold */
#define CONTEXTSIZE 128     /* arbitrary minimum */

char cmdbuffer[2048];
char optbuffer[2048];
char num[36];

char currentdir[2048] ="\0"; /* defaults to current directory */

/* not configurable yet */
#define CRT0SRC     "crt0.a68"
#define CRT0OBJ     "crt0.o"
#define MAINSRC     "_main.c"
#define MAINOBJ     "_main.o"
#define EXITSRC     "_exit.c"
#define EXITOBJ     "_exit.o"
#define RLIBSRC     "rlib.c"
#define RLIBOBJ     "rlib.o"
#define OUTPUTNAME  "rlib.lib"
#define RLIBH       "rlib.h"

#define RESETVALUE(g,v) GT_SetGadgetAttrs(RConfigGadgets[g], \
      RConfigWnd, NULL, GTIN_Number, v, TAG_END)

#define WRITE_SOPT(g,o) \
    if (ccopts[g]) \
        strcat(optbuffer, "-s" o " "); /* enable */    \
    else                                        \
        strcat(optbuffer, "-s0" o " ") /* disable */

#define WRITE_ROPT(g,o) \
    if (ccopts[g]) \
        strcat(optbuffer, "-r" o " "); /* enable */    \
    else                                        \
        strcat(optbuffer, "-r0" o " ") /* disable */

#define WRITEDEF(d) \
    fprintf(rh, "#ifndef %s\n" \
          "#define %s\n" \
          "#endif\n\n", d, d)
 
struct EasyStruct myES = {
    sizeof(struct EasyStruct),
    0,
    (UBYTE *)"RConfig System Error",
    (UBYTE *)"%s",
    (UBYTE *)"Continue"
};

static char *paths[2] = {
   "RLIB:",
   "AZTEC:RLIB/"
};

void GenLib() {
    long int minstk, stksize, context;
    long ok;
    struct Process *pp;
    APTR savedwindowptr;
    struct Requester waitRequest;
    int directory = -1; /* -1 == none, 0 == "RLIB:", 1 == "AZTEC:RLIB" */
    FILE *rh = NULL;
    time_t currenttime;
    extern int pathlength;

    InitRequester(&waitRequest); /* block input to this window */
    if (Request(&waitRequest, RConfigWnd))
        SetPointer(RConfigWnd, WaitPointerImage, 16, 16, -6, 0);
    else {
        EasyRequest(NULL, &myES, NULL, "Unable to initialize requester.");
        return;
    }

    SetWindowTitles(RConfigWnd, (UBYTE*)"Generating library...", (UBYTE*)-1);

    /* verify currentdir */
    if (pathlength) {
        sprintf(currentdir, "%s", fr->rf_Dir);
        if (currentdir[pathlength-1] != ':' &&
              currentdir[pathlength-1] != '/')
            strcat(currentdir, "/");
        if (access(currentdir, 0)) {
            EasyRequest(NULL, &myES, NULL, "Output directory not found.");
            goto GenLibFail;
        }
    } else
        currentdir[0] = '\0';
    
    sprintf(cmdbuffer, "%s" RLIBH, currentdir);
    rh = fopen(cmdbuffer, "w");
    if (!rh) {
        EasyRequest(NULL, &myES, NULL, "Unable to create \"rlib.h\".");
        goto GenLibFail;
    } else {
        currenttime = time(NULL); /* or time(&currenttime); */
        fprintf(rh,
              "/*\n" \
              " *  lib.h\n" \
              " *\n" \
              " *  Header file for rlib.lib created %s",
              ctime(&currenttime)
        );
    }

    if (getenv("manx/include")==NULL) {
        EasyRequest(NULL, &myES, NULL, "Manx INCLUDE environment variable not set.");
        goto GenLibFail;
    }

    if (stkchk_mode & 2) {
        minstk = ((struct StringInfo *)RConfigGadgets[GD_STKCHK_MINSTK]->SpecialInfo)->LongInt;
        stksize = ((struct StringInfo *)RConfigGadgets[GD_STKCHK_STKSIZE]->SpecialInfo)->LongInt;
        context = ((struct StringInfo *)RConfigGadgets[GD_STKCHK_CONTEXT]->SpecialInfo)->LongInt;

        if (minstk < THRESHHOLD) {
            RESETVALUE(GD_STKCHK_MINSTK, THRESHHOLD);
            EasyRequest(NULL, &myES, NULL, "Threshhold < minimum (2768).");
            goto GenLibFail;
        }

        if (stksize < STACKSIZE) {
            RESETVALUE(GD_STKCHK_STKSIZE, STACKSIZE);
            EasyRequest(NULL, &myES, NULL, "Stack size < minimum (8192).");
            goto GenLibFail;
        } else if (stksize < minstk) {
            RESETVALUE(GD_STKCHK_STKSIZE, minstk);
            EasyRequest(NULL, &myES, NULL, "Stack size < Threshhold.");
            goto GenLibFail;
        }    
    
        if (context < CONTEXTSIZE) {
            RESETVALUE(GD_STKCHK_CONTEXT, CONTEXTSIZE);
            EasyRequest(NULL, &myES, NULL, "Context size < minimum (128).");
            goto GenLibFail;
        } else if (context > stksize) {
            RESETVALUE(GD_STKCHK_CONTEXT, CONTEXTSIZE);
            EasyRequest(NULL, &myES, NULL, "Context size > Stack size.");
            goto GenLibFail;
        }
    }

    if (main_mode & 2) {
        if (main_mode & 1) {
            if (data_mode) {
                EasyRequest(NULL, &myES, NULL, "Resident main/exit not permitted in large data model.");
                goto GenLibFail;
            }
            fprintf(rh, " *   - %s main/exit\n", "resident");
        } else {
            fprintf(rh, " *   - %s main/exit\n", "detach");
        }
    }

    pp = (struct Process *)FindTask(0L);
    savedwindowptr = pp->pr_WindowPtr;
    pp->pr_WindowPtr = (APTR)-1; /* suppress system requesters */

    if (access(paths[0], 0)==0) /* RLIB: exists */
        directory = 0;
    else if (access(paths[1], 0)==0) /* AZTEC:RLIB exists */
        directory = 1;
    else {
        pp->pr_WindowPtr = savedwindowptr; /* restore original value */
        EasyRequest(NULL, &myES, NULL, "RConfig Library Source Not Found.");
        goto GenLibFail;
    }

    if (access(OUTPUTNAME, 0)==0) /* rlib.lib already exists */
        remove(OUTPUTNAME);

    pp->pr_WindowPtr = savedwindowptr; /* restore original value */

    optbuffer[0] = '\0';

    if (alloca_mode & 2) {
        sprintf(optbuffer, "%s", "-d__ALLOCA_REPLACE ");
        if (alloca_mode & 1) {
            fprintf(rh, " *   - %s alloca\n", "risky");
            strcat(optbuffer, "-d__RISKY_ALLOCA ");
        } else {
            fprintf(rh, " *   - %s alloca\n", "safe");
            strcat(optbuffer, "-d__SAFE_ALLOCA ");
        }
    }

    if (stkchk_mode & 2) {
        strcat(optbuffer, "-d__STKCHK_REPLACE ");
        sprintf(num, "-dSTKCHK_MIN_STACK=%d ", minstk);
        strcat(optbuffer, num);
        if (stkchk_mode & 1) {
            fprintf(rh, " *   - dynastack stkchk, threshhold=%ld, new stack=%ld, context=%ld\n", minstk, stksize, context);
            strcat(optbuffer, "-d__DYNASTACK_STKCHK ");
            sprintf(num, "-dSTKCHK_STACK_SIZE=%d ", stksize);
            strcat(optbuffer, num);
            sprintf(num, "-dSTKCHK_CONTEXT_SIZE=%d ", context);
            strcat(optbuffer, num);
        } else {
            fprintf(rh, " *   - better stkchk, threshhold=%ld\n", minstk);
            strcat(optbuffer, "-d__BETTER_STKCHK ");
        }
    }

    if (setjmp_mode) {
        fputs(" *   - setjmp/longjmp\n", rh);
        strcat(optbuffer, "-d__SETJMP_REPLACE ");
    }

    fputs(" */\n\n", rh);

    if (stkchk_mode & 2 && setjmp_mode)
        WRITEDEF("__DYNASTACK_STKCHK");

    if (alloca_mode & 2 && !(alloca_mode & 1))
        WRITEDEF("__SAFE_ALLOCA");

    if (alloca_mode & 2) {
        if (setjmp_mode) {
            WRITEDEF("__ALLOCA_REPLACE");
        }
        fputs("#include <alloca.h>\n", rh);
    }

    if (setjmp_mode)
        fputs("#include <rsetjmp.h>\n", rh);

    if (data_mode)
        strcat(optbuffer, "-md ");  /* large data memory model */
    else
        strcat(optbuffer, "-m0d "); /* small data memory model */

    if (integer_mode)
        strcat(optbuffer, "-ps "); /* 16 bit ints */
    else            
        strcat(optbuffer, "-pl "); /* 32 bit ints */

    /* optimization flags here override CCOPTS env. var. setting */
    WRITE_SOPT(GD_sa, "a");
    WRITE_SOPT(GD_sb, "b");
    WRITE_SOPT(GD_sf, "f");
    WRITE_SOPT(GD_sm, "m");
    WRITE_SOPT(GD_ss, "s");
    WRITE_SOPT(GD_sp, "p");
    WRITE_SOPT(GD_sn, "n");
    WRITE_ROPT(GD_r4, "4");
    WRITE_ROPT(GD_r6, "6");

    if (ccopts[GD_srsu]) {
        if (uservars)
            strcat(optbuffer, "-su");
        else
            strcat(optbuffer, "-sr");
    } else
        strcat(optbuffer, "-s0r -s0u"); /* disable */

    sprintf(cmdbuffer, "cc %s%s -i%s -oT:%s ",
          paths[directory], RLIBSRC, paths[directory], RLIBOBJ);

    strcat(cmdbuffer, optbuffer);
    putchar('\n'); puts(cmdbuffer);
    ok = SystemTags(cmdbuffer, TAG_END);        

    if (main_mode & 2) {
        if (main_mode & 1) {
            sprintf(cmdbuffer, "as %s%s -o T:%s -e__RESSTART_MAIN",
                  paths[directory], CRT0SRC, CRT0OBJ);
            putchar('\n'); puts(cmdbuffer);
            ok = SystemTags(cmdbuffer, TAG_END);        
            sprintf(cmdbuffer, "cc %s%s -oT:%s -d__RESSTART_MAIN ",
                  paths[directory], EXITSRC, EXITOBJ);
            strcat(cmdbuffer, optbuffer);
            putchar('\n'); puts(cmdbuffer);
            ok = SystemTags(cmdbuffer, TAG_END);
            sprintf(cmdbuffer, "lb %s%s T:%s T:%s T:%s",
                  currentdir, OUTPUTNAME, CRT0OBJ, EXITOBJ, RLIBOBJ);
            putchar('\n'); puts(cmdbuffer);
            ok = SystemTags(cmdbuffer, TAG_END);
            remove("T:_exit.o"); remove("T:crt0.o");
        } else {
            sprintf(cmdbuffer, "as %s%s -o T:%s",
                  paths[directory], CRT0SRC, CRT0OBJ);
            putchar('\n'); puts(cmdbuffer);
            ok = SystemTags(cmdbuffer, TAG_END);        
            /* detach code */
            sprintf(cmdbuffer, "cc %s%s -oT:%s -d__DETACH_MAIN -m0b ",
                  paths[directory], MAINSRC, MAINOBJ);
            strcat(cmdbuffer, optbuffer);
            putchar('\n'); puts(cmdbuffer);
            ok = SystemTags(cmdbuffer, TAG_END);
            sprintf(cmdbuffer, "lb %s%s T:%s T:%s T:%s",
                  currentdir, OUTPUTNAME, CRT0OBJ, MAINOBJ, RLIBOBJ);
            putchar('\n'); puts(cmdbuffer);
            ok = SystemTags(cmdbuffer, TAG_END);
            remove("T:_main.o"); remove("T:crt0.o");
        }
    } else {
        sprintf(cmdbuffer, "lb %s%s T:%s",
              currentdir, OUTPUTNAME, RLIBOBJ);
        putchar('\n'); puts(cmdbuffer);
        ok = SystemTags(cmdbuffer, TAG_END);
    }
    remove("T:rlib.o");

    goto GenLibQuit;

GenLibFail:
    /* just falls through */

GenLibQuit:
    if (rh)
        fclose(rh);

    SetWindowTitles(RConfigWnd, (UBYTE*)"Replacement Library Configuration", (UBYTE*)-1);

    DisplayBeep(NULL); /* all screens...may want to change
                          this to just the Workbench screen */

    ClearMsgPort(RConfigWnd->UserPort);

    ClearPointer(RConfigWnd);
    EndRequest(&waitRequest, RConfigWnd);
}
