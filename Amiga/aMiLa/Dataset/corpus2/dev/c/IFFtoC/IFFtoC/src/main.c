/*
*   Iff2C - Converts an Iff ILBM file to C source
*   ---------------------------------------------
*   v0.40, by Gauthier Groult & Jm Forgeas & Alfred Faust(MOS-porting)
*
*   Last updates:
*     v0.41  15-Mar-2004 Left/TopEdge to 0 added, bug outfilepath removed
*     v0.40  26-Feb-2004 complete reworked and enhanced for MorphOS
*                        by Alfred Faust <alfred.j.faust@gmx.de>
*     v0.30, 12-May-89,  fixed minor output bug, -ghg-
*     v0.29, 01-May-89,  plane pick option now works, -ghg-
*     v0.28, 30-Apr-89,  -lsdh options added, jm Forgeas
*     v0.27, 13-Nov-88,  original coding by Gauthier Groult
*
*/


#include <exec/memory.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/asl.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <intuition/intuition.h>
#include <utility/tagitem.h>
#include <graphics/gfx.h>
#include <stdio.h>
#include <string.h>

#include "iff/ilbm.h"
#include "iff/readpict.h"
#include "iff/remalloc.h"
#include "iff2c.h"


ULONG __abox__ = 1;
STRPTR version = "$VER: Iff2C v0.41, by Gauthier Groult & Jm Forgeas, for MorphOS rewritten by Alfred Faust 25-Feb-04";

#define SOURCETITLE "Choose Source-File(s) please:"
#define DESTTITLE   "Choose Destination-Dir please:"
#define RAMOUT      "RAM:"

struct FileRequester *filereq = NULL;
struct GfxBase  *GfxBase = NULL;
struct Library *AslBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct Library *GadToolsBase = NULL;
struct EasyStruct message;

struct EasyStruct message ={
    20,
    0,
    NULL,
    "Do you want to convert more pics ?",
    "Yes|No"
};

struct EasyStruct aslout ={
    20,
    0,
    NULL,
    "Couldn't open the asl.library",
    "Oh,no!"
};

struct EasyStruct gfxout ={
    20,
    0,
    NULL,
    "Couldn't open the graphics.library",
    "Oh,no!"
};

struct EasyStruct intuiout ={
    20,
    0,
    NULL,
    "Couldn't open the intuition.library",
    "Oh,no!"
};

struct EasyStruct gadtoolsout ={
    20,
    0,
    NULL,
    "Couldn't open the gadtools.library",
    "Oh,no!"
};

struct EasyStruct fileexists ={
    20,
    0,
    "Warning !",
    "",
    "No|Yes"
};



UBYTE ipath[256];
UBYTE opath[256];
UBYTE ifile[128];
UBYTE ofile[128];
UBYTE infilename[256];  //the resulting path:infile
UBYTE outfilename[256]; //the resulting path:outfile


ULONG getflags(struct Screen *screen)
{
    ULONG flags = (PRINT_COMMENTS | PRINT_IMAGE | COMPUTE_ONOFF | XYNULL);
    struct IntuiMessage *message;
    LONG class, code;
    struct Gadget *gadget = NULL,
                  *gad = NULL,
                  *spritegad = NULL,
                  *imagegad = NULL,
                  *commentsgad = NULL,
                  *xynullgad = NULL,
                  *glist=NULL;
    struct NewGadget ng;
    struct Window *window;
    struct TextAttr textattr;
    APTR visualinfo = NULL;
    UBYTE okkey = 79,
          spritekey = 83,
          imagekey = 73,
          commentskey = 67,
          xynullkey = 76;
    UBYTE *oktext = "_OK",
          *spritetext = "_Sprite Header",
          *imagetext = "_Image Structures",
          *commentstext = "_Comments",
          *xynulltext = "_Left/TopEdge = 0",
          *windowtext = " Choose IFF2C-Options please";

    BOOL close_me = FALSE;

    if(!(screen)) return(0L);

    AskFont(screen->RastPort, &textattr);

    gad = (struct Gadget *)CreateContext((struct Gadget **)&glist);
    if (visualinfo==NULL)
    {
        visualinfo = (APTR)GetVisualInfo(screen,TAG_DONE);
    }

    ng.ng_LeftEdge = 135;
    ng.ng_TopEdge = 93;
    ng.ng_Width = 60;
    ng.ng_Height = 16;
    ng.ng_GadgetText = oktext;
    ng.ng_GadgetID = 1;
    ng.ng_TextAttr = &textattr;
    ng.ng_VisualInfo = visualinfo;
    ng.ng_Flags = PLACETEXT_IN;
    gad = (struct Gadget *)CreateGadget(BUTTON_KIND, gad, &ng,
            GT_Underscore ,'_',
            TAG_DONE);

    ng.ng_TopEdge = 22;
    ng.ng_LeftEdge = 17;
    ng.ng_GadgetText = spritetext;
    ng.ng_Flags = PLACETEXT_RIGHT;
    ng.ng_GadgetID = 2;
    spritegad = gad = (struct Gadget *)CreateGadget(CHECKBOX_KIND, gad, &ng,
            GT_Underscore ,'_',
            TAG_DONE);

    ng.ng_TopEdge = 38;
    ng.ng_GadgetText = imagetext;
    ng.ng_Flags = PLACETEXT_RIGHT;
    ng.ng_GadgetID = 3;
    imagegad = gad = (struct Gadget *)CreateGadget(CHECKBOX_KIND, gad, &ng,
            GTCB_Checked, TRUE,
            GT_Underscore ,'_',
            TAG_DONE);

    ng.ng_TopEdge = 54;
    ng.ng_GadgetText = commentstext;
    ng.ng_Flags = PLACETEXT_RIGHT;
    ng.ng_GadgetID = 4;
    commentsgad = gad = (struct Gadget *)CreateGadget(CHECKBOX_KIND, gad, &ng,
            GTCB_Checked, TRUE,
            GT_Underscore ,'_',
            TAG_DONE);

    ng.ng_TopEdge = 70;
    ng.ng_GadgetText = xynulltext;
    ng.ng_Flags = PLACETEXT_RIGHT;
    ng.ng_GadgetID = 5;
    commentsgad = gad = (struct Gadget *)CreateGadget(CHECKBOX_KIND, gad, &ng,
            GTCB_Checked, TRUE,
            GT_Underscore ,'_',
            TAG_DONE);



    window = (struct Window *) OpenWindowTags(NULL,
                                        WA_Activate,        TRUE,
                                        WA_Borderless,      FALSE,
                                        WA_CustomScreen,    screen,
                                        WA_DragBar,         TRUE,
                                        WA_Title,           windowtext,
                                        WA_Height,          116,
                                        WA_Width,           208,
                                        WA_Gadgets,         glist,
                                        WA_Left,            131,
                                        WA_Top,             127,
                                        WA_IDCMP,           IDCMP_GADGETUP |
                                                            IDCMP_GADGETDOWN |
                                                            IDCMP_VANILLAKEY,
                                        WA_Flags,           WFLG_SIMPLE_REFRESH |
                                                            WFLG_NOCAREREFRESH,
                                        TAG_DONE);

    if (window) {
        WindowToFront(window);
        while (close_me == FALSE) {
            Wait (1 << window->UserPort->mp_SigBit);
            while ((close_me == FALSE) && (message = (struct IntuiMessage *)GT_GetIMsg(window->UserPort)))
            {
                class = message->Class;
                code = (UWORD)message->Code;
                GT_ReplyIMsg(message);
                if (class == IDCMP_GADGETUP) {
                gadget = (struct Gadget *)message->IAddress;
                    switch(gadget->GadgetID) {
                        case 1 : //OK
                            close_me = TRUE;
                            break;
                        case 2 : //sprite
                            if(gadget->Flags & SELECTED)
                            {
                                flags |= SPRITE_HEADER;
                            }
                            else
                            {
                                flags &= ~(SPRITE_HEADER);
                            }
                            break;
                        case 3 : //image
                            if(gadget->Flags & SELECTED)
                            {
                                flags |= PRINT_IMAGE;
                            }
                            else
                            {
                                flags &= ~(PRINT_IMAGE);
                            }
                            break;
                        case 4 : //comments
                            if(gadget->Flags & SELECTED)
                            {
                                flags |= PRINT_COMMENTS;
                            }
                            else
                            {
                                flags &= ~(PRINT_COMMENTS);
                            }
                            break;
                        case 5 : //Left/TopEdge = 0
                            if(gadget->Flags & SELECTED)
                            {
                                flags |= XYNULL;
                            }
                            else
                            {
                                flags &= ~(XYNULL);
                            }
                            break;
                    }
                }
                else if (class == IDCMP_VANILLAKEY)
                {
                    if ((code == okkey) || (code == (okkey + 32)))
                    {
                        close_me = TRUE;
                    }
                    if ((code == spritekey) || (code == (spritekey + 32)))
                    {
                        if(flags & SPRITE_HEADER)
                        {
                            flags &= ~(SPRITE_HEADER);
                        }
                        else
                        {
                            flags |= SPRITE_HEADER;
                        }
                        GT_SetGadgetAttrs(spritegad, window, NULL,
                                          GTCB_Checked, (flags & SPRITE_HEADER),
                                          TAG_DONE);

                    }
                    if ((code == imagekey) || (code == (imagekey + 32)))
                    {
                        if(flags & PRINT_IMAGE)
                        {
                            flags &= ~(PRINT_IMAGE);
                        }
                        else
                        {
                            flags |= PRINT_IMAGE;
                        }
                        GT_SetGadgetAttrs(imagegad, window, NULL,
                                          GTCB_Checked, (flags & PRINT_IMAGE),
                                          TAG_DONE);
                    }
                    if ((code == commentskey) || (code == (commentskey + 32)))
                    {
                        if(flags & PRINT_COMMENTS)
                        {
                            flags &= ~(PRINT_COMMENTS);
                        }
                        else
                        {
                            flags |= PRINT_COMMENTS;
                        }
                        GT_SetGadgetAttrs(commentsgad, window, NULL,
                                          GTCB_Checked, (flags & PRINT_COMMENTS),
                                          TAG_DONE);
                    }
                    if ((code == xynullkey) || (code == (xynullkey + 32)))
                    {
                        if(flags & XYNULL)
                        {
                            flags &= ~(XYNULL);
                        }
                        else
                        {
                            flags |= XYNULL;
                        }
                        GT_SetGadgetAttrs(xynullgad, window, NULL,
                                          GTCB_Checked, (flags & XYNULL),
                                          TAG_DONE);
                    }
                }
            }
            if (close_me == TRUE) break;
        }
        CloseWindow(window);
        if (glist) FreeGadgets((struct Gadget *)glist);
        return(flags);
    }
    else {
        if (glist) FreeGadgets((struct Gadget *)glist);
        return(0L);
    }
}

VOID getname(UBYTE *reqentry, ULONG sw){
//sw: 0 = inpath, 1 = outpath, 2= infilename,
//    3 = outfilename we make the appendix = .c

    LONG len = strlen((BYTE *)reqentry) + 2;
    UBYTE * store = NULL;

    if (reqentry){
        switch(sw)
        {
            case 0:
                sprintf(infilename, "%s", reqentry);
                sprintf(ipath, "%s", reqentry);
                break;
            case 1:
                sprintf(outfilename, "%s", reqentry);
                sprintf(opath, "%s", reqentry);
                break;
            case 2:
                sprintf(ifile, "%s", reqentry);
                break;
            case 3:
                store = (STRPTR)FilePart((STRPTR)reqentry); //get the filename
                store = (STRPTR)strtok(store, ".");         //cut the extension
                sprintf(ofile,"%s.c",store);                //new extension
                break;
        }
    }
    else return;
}

int main(UBYTE argc, UBYTE **argv)
{
    ULONG     arg=1,
              flags = 0;//(PRINT_COMMENTS | PRINT_IMAGE | COMPUTE_ONOFF | PRINT_DATA) ;
    LONG      file;
    FILE      *outfile;
    IFFP      iffp = NO_FILE;
    ILBMFrame iFrame;
    struct    BitMap bitmap;
    UBYTE     filexists[200] ;
    STRPTR    name, pathdelimiter, path;
    struct TagItem filereqtags[9];
    struct Screen *screen = NULL;

    LONG readbyte = 0,
         result,
         argselected = 0;
    int i = 0;

    struct WBArg *wbarg = NULL;

    /* we open the neccessary libraries */

    if(!(AslBase = (struct Library *)OpenLibrary("asl.library",0L)))
    {
        EasyRequest(NULL, &aslout, NULL);
        goto cleanup;
    }

    if (!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0)))
    {
        EasyRequest(NULL, &gfxout, NULL);
        goto cleanup;
    }

    if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 0)))
    {
        EasyRequest(NULL, &intuiout, NULL);
        goto cleanup;
    }

    if (!(GadToolsBase = (struct Library *)OpenLibrary("gadtools.library", 0)))
    {
        EasyRequest(NULL, &gadtoolsout, NULL);
        goto cleanup;
    }

    screen = LockPubScreen(NULL);
    UnlockPubScreen(NULL, screen);

    if(!(flags = getflags(screen)))
    {
        goto cleanup;
    }

    /* we fill the filerequester tags with neccessary datas */

    filereqtags[0].ti_Tag  = ASLFR_TitleText;
    filereqtags[0].ti_Data = (ULONG)DESTTITLE;

    filereqtags[1].ti_Tag  = ASLFR_InitialDrawer;
    filereqtags[1].ti_Data = (ULONG)"RAM:";

    filereqtags[2].ti_Tag  = ASLFR_DoMultiSelect;
    filereqtags[2].ti_Data = FALSE;

    filereqtags[3].ti_Tag  = ASLFR_DoPatterns;
    filereqtags[3].ti_Data = FALSE;

    filereqtags[4].ti_Tag  = ASLFR_InitialFile;
    filereqtags[4].ti_Data = (ULONG)"";

    filereqtags[5].ti_Tag  = ASLFR_InitialPattern;
    filereqtags[5].ti_Data = (ULONG)"";

    filereqtags[6].ti_Tag  = ASLFR_InitialHeight;
    filereqtags[6].ti_Data = 150;

    filereqtags[7].ti_Tag  = ASLFR_DrawersOnly;
    filereqtags[7].ti_Data = TRUE;

    filereqtags[8].ti_Tag  = TAG_DONE;

newstart: /* startpoint, if we won't leave the program to work away*/

    /* we allocate a asl request as a FileRequester */
    filereq = (struct FileRequester *)AllocAslRequest(ASL_FileRequest, 0L);


    /* making the AslRequester for the outpath appearing -
    if we leave the  requester with a selection ... */

    if(AslRequest(filereq, filereqtags)){

        getname(filereq->fr_Drawer,1);  //1 = outpath

    }
    else {
        /* leaved the requester with "Cancel" */
        goto exitit;
    }

    /* alter the tags for use as source requester */

    filereqtags[0].ti_Data = (ULONG)SOURCETITLE;  //new title
    filereqtags[2].ti_Data = TRUE;                //multiselect
    filereqtags[3].ti_Data = TRUE;                //pattern
    filereqtags[5].ti_Data = (ULONG)"#?.iff";     //init pattern
    filereqtags[6].ti_Data = 400;                 //initial height
    filereqtags[7].ti_Data = FALSE;               //drawersonly


    /* making the AslRequester appearing -
    if we leave the  requester with a selection ... */

    if(AslRequest(filereq, filereqtags)){

        /* multiple selection ? */

        if (filereq->fr_NumArgs){
            argselected = filereq->fr_NumArgs ;
            wbarg = filereq->fr_ArgList;
            filereq->fr_File = wbarg->wa_Name;
        }
        /* we create the string with complete path of the infile */

        getname(filereq->fr_Drawer,0); //0 = inpath
        getname(filereq->fr_File,2);   //2 = infile
        AddPart(infilename, ifile, 256);

        /* same for the outpath */

        getname(filereq->fr_File,3);
        AddPart(outfilename, ofile, 200);

    }
    else {
        /* leaved the requester with "Cancel" */
        goto exitit;
    }

    /* mainloop */

    for(i = 1;;i++)
    {
        printf("Working on file: %s\n", (UBYTE *)infilename);

        /* the core of the program */

        if (file = Open(infilename, MODE_OLDFILE))
        {
            iffp = ReadPicture(file, &bitmap, &iFrame, ChipAlloc);
            Close(file);
        }
        else
        {
            fprintf(stderr, "Iff2c: wrong file name %s\n", infilename);
            goto cleanup;
        }
        if (iffp != IFF_DONE)
        {
            fprintf(stderr, "Iff2c: wrong file format %s\n", infilename);
            goto cleanup;
        }
        if(outfile = fopen(outfilename, "r"))
        {
            fclose(outfile);
            sprintf(filexists,"%s\nexists already! Overwrite?",outfilename);
            fileexists.es_TextFormat = filexists;

            if((result = EasyRequest(NULL, &fileexists, NULL)))
            {
                goto skip;
            }
        }

        if(outfile = fopen(outfilename, "w"))
        {
            name = (STRPTR)strtok(ifile, ".");

            BMap2C((FILE *)outfile, name, bitmap.Planes[0],
                    iFrame.bmHdr.x, iFrame.bmHdr.y,
                    iFrame.bmHdr.w, iFrame.bmHdr.h,
                    bitmap.Depth, flags );
            fclose(outfile);
        }
skip:
        if (bitmap.Planes[0]) RemFree(bitmap.Planes[0]);

        /* go to the next entry in the filelist */

        argselected -- ;

        if(argselected)
        {
            wbarg++;
        }
        else
        {
            break;
        }

        /* more than one file selected */

        if (wbarg)
        {
            /* new infilename from the List -> ifile*/
            memset((APTR)ifile, 0, 100);
            getname(wbarg->wa_Name,2);
            /* "reset" infilename to the inpath */
            memset((APTR)infilename, 0, 200);
            strcpy(infilename, ipath);

            if ((infilename[0]) && (ifile[0])){

                /* new complete infilename  */
                AddPart(infilename, ifile, 200);

                /* create new outfilename -> ofile*/
                memset((APTR)ofile, 0, 100);
                getname(wbarg->wa_Name,3);

                /* "reset" outfilename to the outpath */
                memset((APTR)outfilename, 0, 200);
                strcpy(outfilename, opath);

                /* new complete outfilename  */
                AddPart(outfilename, ofile, 200);

            }
            /* if no infile or inpath */

            else
            {
                break;
            }

        }
        else
        {
            break;
        }
    }

exitit:

    if (result = EasyRequest(NULL, &message, NULL)){

        /* alter the tags for use as destination path requester */

        filereqtags[0].ti_Data = (ULONG)DESTTITLE;     //new title
        filereqtags[1].ti_Data = (ULONG)"RAM:";        //init drawer
        filereqtags[2].ti_Data = FALSE;                //multiselect
        filereqtags[3].ti_Data = FALSE;                //pattern
        filereqtags[4].ti_Data = (ULONG)"";            //init file
        filereqtags[6].ti_Data = 150;                  //init height
        filereqtags[7].ti_Data = TRUE;                 //only drawers
        if(filereq) FreeAslRequest((APTR)filereq);

        Delay(20);
        goto newstart;
    }

cleanup:

    /* freeing recources*/
    if(filereq) FreeAslRequest((APTR)filereq);

    /* close the opened libraries */

    if (AslBase) CloseLibrary((struct Library *)AslBase);
    if (GfxBase)CloseLibrary((struct Library *)GfxBase);
    if (IntuitionBase)CloseLibrary((struct Library *)IntuitionBase);


    return(0);
}


