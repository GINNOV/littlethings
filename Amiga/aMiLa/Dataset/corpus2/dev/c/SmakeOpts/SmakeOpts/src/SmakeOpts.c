/*
**  SmakeOpts - (C) 1996 by Reinhard Katzmann. All rights reservec
**
**  This program creates a BGUI Window with prefs settings for Smake.
**  After all settings were made they will be saved to a file 'smopts'
**  This file can be called bia:
**  > smake `type smopts`
**  It also reads old settings from this file.
*/

#ifndef LIBRARIES_BGUI_H
#include <libraries/bgui.h>
#endif

#ifndef LIBRARIES_BGUI_MACROS_H
#include <libraries/bgui_macros.h>
#endif

#ifndef BGUI_PROTO_H
#include <proto/bgui.h>
#endif

#include <bgclass/stringpatch.h> /* removes Intui string gadget Bug */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libraries/asl.h>
#include <exec/memory.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>
#include <dos/var.h>
#include <dos/dos.h>
#include <proto/intuition.h>
#include <clib/alib_protos.h>
#include <proto/wb.h>
#include <proto/icon.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include "SmakeOpts_rev.h"

UBYTE versiontag[] = VERSTAG;
UBYTE Copyright[] = VERS ". Copyright (C) 1996 Reinhard Katzmann. All rights reserved";

#define TEMPLATE "P=PUBSCREEN/K"
#define OPT_PUBLIC  0
#define OPT_COUNT   1

#define QUOTE       '"'
#define ESCAPE '*'
#define ESC '\x1b'
#define NL '\n'
#define ODATALENGTH 80

/* Datatype for Options: Option and arguments (if any) */
/* Change ODATALENGTH if you need longer argument strings */
typedef struct optstr
{
  char  o_Option[3];
  char  o_Data[ODATALENGTH];
} OPTSTR;

enum
{
    GO_MASTER, GO_DEBUGCHECK, GO_SMDBGCHECK, GO_ALLCHECK,
    GO_SILENTCHECK, GO_ERASECHECK, GO_SMFILESTRING, GO_SMAKEFILE,
    GO_MODNAMESTRING, GO_DEFFILESTRING, GO_DEFAULTFILE, GO_SAVEBUTTON,
    GO_CANCELBUTTON,

    GO_NUMGADS
};

Object *SmakeOptsWinObjs[GO_NUMGADS];
Object *win;
Object *filereq; /* for keeping directory when called twice */
struct Screen *pscreen=NULL;
struct WBStartup *startup=NULL;
struct RDArgs *myrda=NULL;
char **cArgs;
ULONG pbscreen;

void CloseAll(int ec)
{
    if (win) DisposeObject( win );
    if (filereq) DisposeObject( filereq );
    if (cArgs) FreeVec(cArgs);
    if (pscreen) UnlockPubScreen((char *)pbscreen,pscreen);
    if (myrda) FreeArgs(myrda);
    exit(ec);
}

Object *InitSmakeOptsWin( void )
/* Create Window Object with all its gadget objects */
{
    Object *win;
    Object **ar = SmakeOptsWinObjs;
    ULONG tmp=0;

    win = WindowObject,
        WINDOW_Title, "Change Smake Options",
        WINDOW_ScreenTitle, VSTR,
        WINDOW_SmartRefresh, TRUE,
        WINDOW_AutoAspect, TRUE,
        WINDOW_CloseOnEsc, TRUE,
        WINDOW_ShowTitle, TRUE,
        WINDOW_PubScreen, pscreen,
        WINDOW_MasterGroup, ar[GO_MASTER] = VGroupObject,
            Spacing (4),
            HOffset (4),
            VOffset (4),
            VarSpace (50),

            StartMember, HGroupObject,
                Spacing (4),
                VarSpace (50),

                StartMember, ar[GO_DEBUGCHECK] = CheckBoxObject,
                    ButtonFrame,
                    LAB_Label, "_Debug",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    GA_ID, GO_DEBUGCHECK,
                EndObject, Weight (1), FixMinWidth, FixMinHeight, EndMember,
                VarSpace (20),

                StartMember, ar[GO_SMDBGCHECK] = CheckBoxObject,
                    ButtonFrame,
                    LAB_Label, "Smake-Debug",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    GA_ID, GO_SMDBGCHECK,
                EndObject, Weight (1), FixMinWidth, FixMinHeight, EndMember,
                VarSpace (20),

                StartMember, ar[GO_ALLCHECK] = CheckBoxObject,
                    ButtonFrame,
                    LAB_Label, "_All",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    GA_ID, GO_ALLCHECK,
                EndObject, Weight (1), FixMinWidth, FixMinHeight, EndMember,
                VarSpace (20),

                StartMember, ar[GO_SILENTCHECK] = CheckBoxObject,
                    ButtonFrame,
                    LAB_Label, "S_ilent",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    GA_ID, GO_SILENTCHECK,
                EndObject, Weight (1), FixMinWidth, FixMinHeight, EndMember,
                VarSpace (20),

                StartMember, ar[GO_ERASECHECK] = CheckBoxObject,
                    ButtonFrame,
                    LAB_Label, "_Erase",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    GA_ID, GO_ERASECHECK,
                EndObject, EndMember,
                VarSpace (50),
            EndObject, NoAlign, EndMember,
            VarSpace (50),

            StartMember, HGroupObject,
                Spacing (4),

                StartMember, ar[GO_SMFILESTRING] = StringObject,
                    RidgeFrame,
                    LAB_Label, "_Smake file",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    STRINGA_TextVal, "Smakefile",
                    STRINGA_MaxChars, 65,
                    STRINGA_EditHook, &StringPatchHook,
                    STRINGA_MinCharsVisible, 0,
                    GA_ID, GO_SMFILESTRING,
                EndObject, FixMinHeight, EndMember,

                StartMember, ar[GO_SMAKEFILE] = ButtonObject,
                    ButtonFrame,
                    VIT_BuiltIn, BUILTIN_GETFILE,
                    GA_ID, GO_SMAKEFILE,
                EndObject, FixMinWidth, FixMinHeight, EndMember,
            EndObject, EndMember,
            VarSpace (50),

            StartMember, HGroupObject,
                Spacing (4),

                StartMember, ar[GO_MODNAMESTRING] = StringObject,
                    RidgeFrame,
                    LAB_Label, "_Target Name",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    STRINGA_MaxChars, 65,
                    STRINGA_EditHook, &StringPatchHook,
                    STRINGA_MinCharsVisible, 0,
                    GA_ID, GO_MODNAMESTRING,
                EndObject, FixMinHeight, EndMember,

                StartMember, ButtonObject,
                EndObject, FixWidth (20), FixHeight (20), EndMember,
            EndObject, EndMember,
            VarSpace (50),

            StartMember, HGroupObject,
                Spacing (4),

                StartMember, ar[GO_DEFFILESTRING] = StringObject,
                    RidgeFrame,
                    LAB_Label, "Default _file",
                    LAB_Place, PLACE_LEFT,
                    LAB_Underscore, '_',
                    STRINGA_TextVal, "Smake.def",
                    STRINGA_MaxChars, 65,
                    STRINGA_EditHook, &StringPatchHook,
                    STRINGA_MinCharsVisible, 0,
                    GA_ID, GO_DEFFILESTRING,
                EndObject, FixMinHeight, EndMember,

                StartMember, ar[GO_DEFAULTFILE] = ButtonObject,
                    ButtonFrame,
                    VIT_BuiltIn, BUILTIN_GETFILE,
                    GA_ID, GO_DEFAULTFILE,
                EndObject, FixMinWidth, FixMinHeight, EndMember,
            EndObject, EndMember,
            VarSpace (50),

            StartMember, HGroupObject,
                Spacing (4),

                StartMember, ar[GO_SAVEBUTTON] = ButtonObject,
                    ButtonFrame,
                    LAB_Label, "Save",
                    LAB_Underscore, '_',
                    GA_ID, GO_SAVEBUTTON,
                EndObject, FixMinHeight, EndMember,
                VarSpace (100),

                StartMember, ar[GO_CANCELBUTTON] = ButtonObject,
                    ButtonFrame,
                    LAB_Label, "Cancel",
                    LAB_Underscore, '_',
                    GA_ID, GO_CANCELBUTTON,
                EndObject, FixMinHeight, EndMember,
            EndObject, EndMember,
        EndObject,
    EndObject;

    tmp += GadgetKey( win, ar[GO_DEBUGCHECK], "d");
    tmp += GadgetKey( win, ar[GO_ALLCHECK], "a");
    tmp += GadgetKey( win, ar[GO_SILENTCHECK], "i");
    tmp += GadgetKey( win, ar[GO_SMFILESTRING], "s");
    tmp += GadgetKey( win, ar[GO_MODNAMESTRING], "t");
    tmp += GadgetKey( win, ar[GO_DEFFILESTRING], "f");
    if (tmp < 6) {
        if (!startup) puts("Could not assign Gadget keys.");
        return 0;
    }

    return( win );
}

int CountArgs(char *line)
/* Count args from input line (from SAS Source: _main.c) */
{
    char *argbuf;
    int argc;

   argbuf = line;
   for (argc = 0; ; argc++)
   {
        while (isspace(*line))  line++;
        if (*line == '\0')      break;
        if (*line == QUOTE)
        {
            line++;
            while (*line != QUOTE && *line != 0)
            {
               if (*line == ESCAPE)
               {
                  line++;
                  if (*line == 0) break;
               }
               line++;
            }
            if (*line) line++;
        }
        else            /* non-quoted arg */
        {
            while ((*line != '\0') && (!isspace(*line))) line++;
            if (*line == '\0')  break;
        }
   }
   return argc;
}

char **CreateArgArray(char *line,int argc)
/*
** Build argument pointer array from input line and argument numnergs argc
** (from SAS Source: _main.c)
*/
{
    char *argbuf,**argv;
    int i;

   argv = AllocVec((argc+1) * sizeof(char *), MEMF_CLEAR);
   if (argv == NULL)
   CloseAll(20);

   i = 0;
   argbuf=line;

   while (1)
   {
       while (isspace(*line))  line++;
       if (*line == '\0')      break;
       if (*line == QUOTE)
       {
           argbuf = argv[i++] = ++line;  /* ptr inside quoted string */
           while (*line != QUOTE && *line != 0)
           {
              if (*line == ESCAPE)
              {
                 line++;
                 switch (*line)
                 {
                    case '\0':
                       *argbuf = 0;
                       goto linedone;
                    case 'E':
                       *argbuf++ = ESC;
                       break;
                    case 'N':
                       *argbuf++ = NL;
                       break;
                    default:
                       *argbuf++ = *line;
                 }
                 line++;
              }
              else
              {
                *argbuf++ = *line++;
              }
           }
           if (*line) line++;
           *argbuf++ = '\0'; /* terminate arg */
       }
       else            /* non-quoted arg */
       {
           argv[i++] = line;
           while ((*line != '\0') && (!isspace(*line))) line++;
           if (*line == '\0')  break;
           else                *line++ = '\0';  /* terminate arg */
       }
   }
linedone:
   return argv;
}

void main(int argc, char **argv)
{
    struct Window *window;
    struct WBArg *wbarg;
    struct DiskObject *dobj;
    FILE *smfile;
    int iNum,iNext=0;
    ULONG signal,rc,tmp,fname;
    LONG olddir=-1;
    LONG result[OPT_COUNT];
    BOOL running=TRUE,debug=FALSE,smdbg=FALSE,all=FALSE,silent=FALSE,erase=FALSE;
    char line[256],*cdata,opts[]="bf",cOption;
    struct optstr newopts[8];

    for (iNum=0; iNum<8; iNum++)
    {
       newopts[iNum].o_Option[0]=0;
       newopts[iNum].o_Data[0]=0;
       if (iNum<OPT_COUNT) result[iNum]=NULL;
    }

    /* Argument parsing: Currently only PubScreen Name */

    if (argc==0)  /* From WB */
    {
        startup = (struct WBStartup *)argv;
        for (iNum=0, wbarg=startup->sm_ArgList; iNum < startup->sm_NumArgs; iNum++, wbarg++)
        {
            /* If there's a directory lock for this wbarg, CD there */
            olddir = -1;
            if ( (wbarg->wa_Lock) && (*wbarg->wa_Name))
                olddir = CurrentDir(wbarg->wa_Lock);
            if ((*wbarg->wa_Name) && (dobj=GetDiskObject(wbarg->wa_Name))) /* Parse ToolTypes */
            {
                cArgs= (char **)dobj->do_ToolTypes;
                if (cdata=(char *)FindToolType(cArgs,"PUBSCREEN"))
                {
                    pbscreen=(ULONG)cdata;
                    if (!(pscreen=LockPubScreen((char *)pbscreen)))
                        CloseAll(5); /* AmigaDOS: Warn */
                }
                FreeDiskObject(dobj);
            }
            if (olddir !=-1) CurrentDir(olddir);
        }
    }
    else /* From CLI */
    {
        printf("%s\n",Copyright);
        if (argc==2 && !strcmp(argv[1],"?")) {
            printf("\nUSAGE: %s %s\n\n",argv[0],TEMPLATE);
            exit(0);
        }

        if (!(myrda=ReadArgs(TEMPLATE, result, NULL))) {
            if (!startup) puts("Could not parse arguments.");
            CloseAll(5); /* AmigaDOS: Warn */
        }

        if (result[OPT_PUBLIC]) {
            pbscreen=result[OPT_PUBLIC];
            if (!(pscreen=LockPubScreen((char *)pbscreen)))
            {
                if (!startup) puts("Could not lock Public Screen.");
                CloseAll(5); /* AmigaDOS: Warn */
            }
        }
    }

    /* Read the old smopts if existant */
    if (smfile=fopen("smopts","r"))
    {
        if (fgets(line,255,smfile))
        {
            cdata=line;
            iNum=CountArgs(cdata); /* Count arguments */
            cArgs=CreateArgArray(cdata,iNum); /* Build argument pointer array */
            while(cdata=argopt(iNum,cArgs,opts,&iNext,&cOption))
            {
                switch(cOption)
                /*
                ** newopts[]: 0 := switch 'a'
                **            1 := switch 'b' + filename
                **            2 := switch 'd'
                **            3 := switch 'e'
                **            4 := switch 'f' + filename
                **            5 := switch 's'
                **            6 := DEBUG="DEBUG=full" (per default)
                **            7 := <modfilename>
                */
                {
                    case 'a': strcpy(newopts[0].o_Option,"-a");
                              all=TRUE;
                              break;
                    case 'b': strcpy(newopts[1].o_Option,"-b");
                              strcpy(newopts[1].o_Data,cdata);
                              break;
                    case 'd': strcpy(newopts[2].o_Option,"-d");
                              smdbg=TRUE;
                              break;
                    case 'e': strcpy(newopts[3].o_Option,"-e");
                              erase=TRUE;
                              break;
                    case 'f': strcpy(newopts[4].o_Option,"-f");
                              strcpy(newopts[4].o_Data,cdata);
                              break;
                    case 's': strcpy(newopts[5].o_Option,"-s");
                              silent=TRUE;
                              break;
                }
            }
            newopts[7].o_Option[0]=0;
            for (; iNext < iNum; iNext++)
            {
                char tmp[ODATALENGTH];
                char hp[ODATALENGTH];

                strcpy(tmp,cArgs[iNext]); /* cArgs[] may not be changed using strtok() (tmp will do instead) */
                cdata=strtok(tmp,"\""); /* Search for a Quote in the argument */
                strcpy(hp,cdata); /* hp: Will contain full argument until next Quote (if any) */
                if (stricmp(cArgs[iNext],cdata)) /* We have found a Quote (Variable Definition with Quote) */
                {
                    while(1)
                    {
                       iNext++; /* Get next "argument" inside \" ... \" */
                       strcpy(tmp,cArgs[iNext]); /* cArgs[] may not be changed using strtok() (tmp will do instead) */
                       cdata=strtok(tmp,"\""); /* Try to find ending Quote */
                       strcat(hp,cdata); /* Add the current "argument" to the final full argument */
                       if ( (iNext>=iNum) || (stricmp(cArgs[iNext],cdata)) ) break; /* We have found the ending Quote */
                    }
                }
                cdata=strtok(hp,"=");
                if (!(stricmp(cdata,"DEBUG"))) /* DEBUG option found (DEBUG="DEBUG FULL" usually) */
                {
                    strcpy(newopts[6].o_Data,"DEBUG=\"DEBUG=full\"");
                    debug=TRUE;
                }
                else /* Other variable definition or target */
                    if ( (strlen(hp) + strlen(newopts[7].o_Data)) < ODATALENGTH ) {
                        strcat(newopts[7].o_Data,hp); /* hp contains the full argument, remeber ? */
                        strcat(newopts[7].o_Data," ");
                     }
                strcpy(tmp,cArgs[iNext]);
            }
        }
        fclose(smfile);
    }

    /* Create Window Object */
    if (!(win=InitSmakeOptsWin()))
    {
        printf("Could not create Window Object\n");
        CloseAll(5);   /* AmigaDOS: Warn */
    }

    if (debug) SetAttrs(SmakeOptsWinObjs[GO_DEBUGCHECK],GA_Selected,TRUE,TAG_DONE);
    if (smdbg) SetAttrs(SmakeOptsWinObjs[GO_SMDBGCHECK],GA_Selected,TRUE,TAG_DONE);
    if (all) SetAttrs(SmakeOptsWinObjs[GO_ALLCHECK],GA_Selected,TRUE,TAG_DONE);
    if (silent) SetAttrs(SmakeOptsWinObjs[GO_SILENTCHECK],GA_Selected,TRUE,TAG_DONE);
    if (erase) SetAttrs(SmakeOptsWinObjs[GO_ERASECHECK],GA_Selected,TRUE,TAG_DONE);
    if (newopts[4].o_Option[0]) SetAttrs(SmakeOptsWinObjs[GO_SMFILESTRING],STRINGA_TextVal,(ULONG)newopts[4].o_Data,TAG_DONE);
    if (newopts[1].o_Option[0]) SetAttrs(SmakeOptsWinObjs[GO_DEFFILESTRING],STRINGA_TextVal,(ULONG)newopts[1].o_Data,TAG_DONE);
    if (newopts[7].o_Data[0]) SetAttrs(SmakeOptsWinObjs[GO_MODNAMESTRING],STRINGA_TextVal,(ULONG)newopts[7].o_Data,TAG_DONE);

    /* Open Window (on PubScreen) */
    if (!(window=WindowOpen(win)))
    {
        puts("Could not open window.\n");
        CloseAll(5);
    }

   /* Main Loop */

   GetAttr(WINDOW_SigMask, win, &signal);
   do
   {
        Wait(signal);
        while ((rc=HandleEvent(win)) != WMHI_NOMORE) {
            switch(rc) {
                case GO_SAVEBUTTON:
                    line[0]=0;
                    /* Build smake command line */
                    if (!(smfile=fopen("smopts","w"))) {
                        if (!startup) printf("Could not open smopts file.\n");
                        CloseAll(20);
                    }
                    for(iNum=0; iNum<8; iNum++)
                    {
                        if (newopts[iNum].o_Option[0]) {
                            strcat(line,newopts[iNum].o_Option);
                            strcat(line," ");
                        }
                        if (newopts[iNum].o_Data[0]) {
                            strcat(line,newopts[iNum].o_Data);
                            strcat(line," ");
                        }
                    }
                    fputs(line,smfile);
                    fclose(smfile);
                case WMHI_CLOSEWINDOW:
                case GO_CANCELBUTTON:
                    running=FALSE;
                    break;
                case GO_DEBUGCHECK:
                    GetAttr(GA_Selected,SmakeOptsWinObjs[GO_DEBUGCHECK],&tmp);
                    debug=(BOOL)tmp;
                    if (debug) strcpy(newopts[6].o_Data,"DEBUG=\"DEBUG=full\"");
                    else newopts[6].o_Data[0]=0;
                    break;
                case GO_SMDBGCHECK:
                    GetAttr(GA_Selected,SmakeOptsWinObjs[GO_SMDBGCHECK],&tmp);
                    smdbg=(BOOL)tmp;
                    if (smdbg) strcpy(newopts[2].o_Option,"-d");
                    else newopts[2].o_Option[0]=0;
                    break;
                case GO_ALLCHECK:
                    GetAttr(GA_Selected,SmakeOptsWinObjs[GO_ALLCHECK],&tmp);
                    all=(BOOL)tmp;
                    if (all) strcpy(newopts[0].o_Option,"-a");
                    else newopts[0].o_Option[0]=0;
                    break;
                case GO_SILENTCHECK:
                    GetAttr(GA_Selected,SmakeOptsWinObjs[GO_SILENTCHECK],&tmp);
                    silent=(BOOL)tmp;
                    if (silent) strcpy(newopts[5].o_Option,"-s");
                    else newopts[5].o_Option[0]=0;
                    break;
                case GO_ERASECHECK:
                    GetAttr(GA_Selected,SmakeOptsWinObjs[GO_ERASECHECK],&tmp);
                    erase=(BOOL)tmp;
                    if (erase) strcpy(newopts[3].o_Option,"-e");
                    else newopts[3].o_Option[0]=0;
                    break;
                case GO_SMAKEFILE:
                    if (!filereq)
                        if (! (filereq = FileReqObject, ASLFR_DoPatterns, TRUE, EndObject)) {
                            if (!startup) printf("Could not open File Requester\n");
                            break;
                        }
                    SetAttrs(filereq, ASLFR_InitialHeight, pscreen->Height-20,TAG_DONE);
                    if ((DoRequest( filereq ))) break; /* break if Cancel is pressed */
                    GetAttr(FRQ_Path, filereq, &fname);
                    SetGadgetAttrs((struct Gadget *)SmakeOptsWinObjs[GO_SMFILESTRING],window,NULL,STRINGA_TextVal,fname,TAG_DONE);
                case GO_SMFILESTRING:
                    GetAttr(STRINGA_TextVal,SmakeOptsWinObjs[GO_SMFILESTRING],&tmp);
                    strcpy(newopts[4].o_Data,(char *)tmp);
                    if (newopts[4].o_Data[0] && stricmp(newopts[4].o_Data,"smakefile")) strcpy(newopts[4].o_Option,"-f");
                    else newopts[4].o_Option[0]=0;
                    break;
                case GO_MODNAMESTRING:
                    GetAttr(STRINGA_TextVal,SmakeOptsWinObjs[GO_MODNAMESTRING],&tmp);
                    strcpy(newopts[7].o_Data,(char *)tmp);
                    break;
                case GO_DEFAULTFILE:
                    if (!filereq)
                        if (! (filereq = FileReqObject, ASLFR_DoPatterns, TRUE, EndObject)) {
                            if (!startup) printf("Could not open File Requester\n");
                            break;
                        }
                    SetAttrs(filereq, ASLFR_InitialHeight, pscreen->Height-20,TAG_DONE);
                    if ((DoRequest( filereq ))) break; /* break if Cancel is pressed */
                    GetAttr(FRQ_Path, filereq, &fname);
                    SetGadgetAttrs((struct Gadget *)SmakeOptsWinObjs[GO_DEFFILESTRING],window,NULL,STRINGA_TextVal,fname,TAG_DONE);
                case GO_DEFFILESTRING:
                    GetAttr(STRINGA_TextVal,SmakeOptsWinObjs[GO_DEFFILESTRING],&tmp);
                    strcpy(newopts[1].o_Data,(char *)tmp);
                    if (newopts[1].o_Data[0] && stricmp(newopts[1].o_Data,"smake.def")) strcpy(newopts[1].o_Option,"-b");
                    else newopts[1].o_Option[0]=0;
                    break;
            }
        }
    } while(running);

    /* Write output file */

    CloseAll(0);
}

#ifdef _DCC
int wbmain( struct WBStartup *wbs )
{
    return( main( 0, wbs ));
}
#endif
