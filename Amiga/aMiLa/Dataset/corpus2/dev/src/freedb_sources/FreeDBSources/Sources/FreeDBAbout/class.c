
#include <proto/graphics.h>
#include "class.h"
#define USE_FREEDB_BODY
#define USE_FREEDB_COLORS
#include "freedb.iff.h"

/***********************************************************************/

struct data
{
    Object *mui;
};

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register Object *g, *im, *url, *mui;
    register char   buf[64], *c;

    stccpy(buf,libBase->freeDBBase->lib_IdString,sizeof(buf));
    for (c = buf; *c!='\r'; c++);
    *c = 0;

    if (obj = (Object *)DoSuperNew(cl,obj,
                MUIA_Window_Title, strings[MSG_Title],
                MUIA_Window_LeftEdge, MUIV_Window_LeftEdge_Centered,
                MUIA_Window_TopEdge, MUIV_Window_TopEdge_Centered,
                MUIA_Window_UseRightBorderScroller, TRUE,
                MUIA_Window_UseBottomBorderScroller, TRUE,
                WindowContents, ScrollgroupObject,
                    MUIA_Background, MUII_RequesterBack,
                    MUIA_Scrollgroup_UseWinBorder, TRUE,
                    MUIA_Scrollgroup_Contents, VirtgroupObject,
                        MUIA_Frame, MUIV_Frame_Virtual,
                        MUIA_Background, MUII_GroupBack,
                        Child, HGroup,
                            Child, HSpace(0),
                            Child, im = BodychunkObject,
                                    MUIA_Frame,                 MUIV_Frame_Button,
                                    MUIA_InputMode,             MUIV_InputMode_RelVerify,
                                    MUIA_FixWidth,              FREEDB_WIDTH,
                                    MUIA_FixHeight,             FREEDB_HEIGHT,
                                    MUIA_Bitmap_Width,          FREEDB_WIDTH,
                                    MUIA_Bitmap_Height,         FREEDB_HEIGHT,
                                    MUIA_Bodychunk_Depth,       FREEDB_DEPTH,
                                    MUIA_Bodychunk_Body,        FreeDB_body,
                                    MUIA_Bodychunk_Compression, FREEDB_COMPRESSION,
                                    MUIA_Bodychunk_Masking,     FREEDB_MASKING,
                                    MUIA_Bitmap_SourceColors,   FreeDB_colors,
                                    MUIA_Bitmap_Transparent,    0,
                                    MUIA_CycleChain,            TRUE,
                                End,
                            Child, HSpace(0),
                        End,
                        Child, textObject(strings[MSG_By],PPCENTERBOLD,100,MUIV_Font_Inherit),
                        Child, vFixSpace,
                        Child, MUI_MakeObject(MUIO_BarTitle,strings[MSG_Infos]),
                        Child, HGroup,
                            Child, HSpace(0),
                            Child, ColGroup(2),
                                Child, textObject(strings[MSG_LibVersion],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, textObject(buf,NULL,0,MUIV_Font_Inherit),
                                Child, textObject(strings[MSG_Author],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, urlTextObject("mailto:alforan@tin.it","Alfonso Ranieri"),
                                Child, textObject(strings[MSG_Support],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, url = urlTextObject("http://web.tiscalinet.it/amiga/freedb/",NULL),
                                Child, textObject(strings[MSG_Freedb],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, urlTextObject("http://www.freedb.org",NULL),
                            End,
                            Child, HSpace(0),
                        End,
                        Child, vFixSpace,
                        Child, MUI_MakeObject(MUIO_BarTitle,strings[MSG_ThirdParts]),
                        Child, g = VGroup,
                            Child, HGroup,
                                MUIA_Group_HorizSpacing,0,
                                Child, hFixSpace,
                                Child, textObject("-",PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, textObject(strings[MSG_NList],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, urlTextObject("mailto:masson@iutsoph.unice.fr","Gilles Masson"),
                                Child, HSpace(0),
                            End,
                            Child, HGroup,
                                MUIA_Group_HorizSpacing,0,
                                Child, hFixSpace,
                                Child, textObject("-",PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, textObject(strings[MSG_Speedbar],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, urlTextObject("mailto:wiz@vapor.com","Simone Tellini"),
                                Child, HSpace(0),
                            End,
                            Child, HGroup,
                                MUIA_Group_HorizSpacing,0,
                                Child, hFixSpace,
                                Child, textObject("-",PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, textObject(strings[MSG_Textinput],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, urlTextObject("mailto:owagner@vapor.com","Oliver Wagner"),
                                Child, HSpace(0),
                            End,
                            Child, HGroup,
                                MUIA_Group_HorizSpacing,0,
                                Child, hFixSpace,
                                Child, textObject("-",PPRIGHT,0,MUIV_Font_Inherit),
                                Child, hFixSpace,
                                Child, mui = TextObject,
                                    ButtonFrame,
                                    MUIA_Background,        MUII_ButtonBack,
                                    MUIA_InputMode,         MUIV_InputMode_RelVerify,
                                    MUIA_Font,              MUIV_Font_Button,
                                    MUIA_CycleChain,        TRUE,
                                    MUIA_Text_Contents,     "_MUI",
                                    MUIA_Text_PreParse,     (ULONG)"\33c",
                                    MUIA_Text_HiCharIdx,    '_',
                                    MUIA_Text_SetMax,       TRUE,
                                End,
                                Child, textObject(strings[MSG_OfCourse],PPRIGHT,0,MUIV_Font_Inherit),
                                Child, HSpace(0),
                            End,
                        End,
                    End,
                End,
                TAG_MORE,msg->ops_AttrList))
    {
        register struct data    *data = INST_DATA(cl,obj);
        register Object         *space;
        register STRPTR         tn;

        if ((tn = strings[MSG_Translation]))
        {
            register Object *translation;

            if (!(translation = HGroup,
                MUIA_Group_HorizSpacing,0,
                Child, hFixSpace,
                Child, textObject("-",PPRIGHT,0,MUIV_Font_Inherit),
                Child, hFixSpace,
                Child, textObject(tn,PPRIGHT,0,MUIV_Font_Inherit),
                Child, HSpace(0),
            End))
            {
                CoerceMethod(cl,obj,OM_DISPOSE);
                return 0;
            }
            DoMethod(g,OM_ADDMEMBER,translation);
        }

        if (!(space = vFixSpace))
        {
            CoerceMethod(cl,obj,OM_DISPOSE);
            return 0;
        }
        DoMethod(g,OM_ADDMEMBER,space);

        data->mui = mui;

        DoMethod(obj,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,MUIV_Notify_Self,3,MUIM_Set,MUIA_Window_Open,0);
        DoMethod(im,MUIM_Notify,MUIA_Pressed,0,url,1,MUIM_Urltext_OpenURL);
    }

    return (ULONG)obj;
}

/***********************************************************************/

static ASM ULONG
mGet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    switch (msg->opg_AttrID)
    {
        case MUIA_Version:
            *msg->opg_Storage = VERSION;
            return 1;

        case MUIA_Revision:
            *msg->opg_Storage = REVISION;
            return 1;

        default:
            return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

static ASM ULONG
mWindowSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (!DoSuperMethodA(cl,obj,msg)) return FALSE;

    DoMethod(data->mui,MUIM_Notify,MUIA_Pressed,FALSE,_app(obj),2,MUIM_Application_AboutMUI,obj);

    return TRUE;
}

/***********************************************************************/

static ASM ULONG
mWindowCleanup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    DoMethod(data->mui,MUIM_KillNotify,MUIA_Pressed);

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static SAVEDS ASM ULONG
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:                return mNew(cl,obj,(APTR)msg);
        case OM_GET:                return mGet(cl,obj,(APTR)msg);
        case MUIM_Window_Setup:     return mWindowSetup(cl,obj,(APTR)msg);
        case MUIM_Window_Cleanup:   return mWindowCleanup(cl,obj,(APTR)msg);
        default:                    return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->class = MUI_CreateCustomClass((struct Library *)base,MUIC_Window,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
