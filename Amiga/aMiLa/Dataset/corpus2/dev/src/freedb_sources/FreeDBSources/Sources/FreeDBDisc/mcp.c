
#include "class.h"

/***********************************************************************/

struct data
{
    Object  *sb;
    Object  *viewMode;
    Object  *sunny;
    Object  *borderLess;
    Object  *raising;
    Object  *small;
    Object  *info;
};

/***********************************************************************/

extern struct SBButton sbuttons[];

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register struct data    *data;
    register Object         *prefs;
    register char           copyright[256];
    ULONG                   noBrushes;

    if (!(obj = (Object *)DoSuperMethodA(cl, obj, msg)))
        return 0;

    snprintf(copyright,sizeof(copyright),"\33c\33b%s\33n %s (%s)\n%s",PRG,VRSTRING,DATE,strings[MSG_Copyright]);

    data = INST_DATA(cl,obj);

    if (!(prefs = VGroup,
        Child, VGroup,
            GroupFrameT(strings[MSG_Bar]),
            Child, VSpace(0),
            Child, HGroup,
                Child, HSpace(0),
                Child, VGroup,
                    Child, HGroup,
                        GroupSpacing(0),
                        Child, data->sb = barObject,
                            MUIA_FreeDB_Bar_ImagesDrawer, FREEDBV_ImagesDir,
                            MUIA_FreeDB_Bar_Buttons, sbuttons,
                            MUIA_FreeDB_Bar_Spacer, "Space",
                            MUIA_FreeDB_Bar_AllUnabled, TRUE,
                        End,
                        Child, HSpace(0),
                    End,
                    Child, hbar(),
                    Child, VGroup,
                        Child, ColGroup(5),
                            Child, Label1(strings[MSG_BorderLess]),
                            Child, data->borderLess = checkmarkObject(MSG_BorderLess,MSG_BorderLess_Help),
                            Child, HSpace(0),
                            Child, Label1(strings[MSG_Sunny]),
                            Child, data->sunny = checkmarkObject(MSG_Sunny,MSG_Sunny_Help),
                            Child, Label1(strings[MSG_Raised]),
                            Child, data->raising = checkmarkObject(MSG_Raised,MSG_Raised_Help),
                            Child, HSpace(0),
                            Child, Label1(strings[MSG_Small]),
                            Child, data->small = checkmarkObject(MSG_Small,MSG_Small_Help),
                        End,
                        Child, HGroup,
                            Child, Label2(strings[MSG_ViewMode]),
                            Child, data->viewMode = cycleObject(MSG_ViewMode,MSG_ViewMode_Help,cyclerStrings),
                        End,
                    End,
                End,
                Child, HSpace(0),
            End,
            Child, VSpace(0),
            Child, data->info = textObject(NULL,NULL,TRUE),
        End,
        Child, TextObject,
            TextFrame,
            MUIA_Background, MUII_TextBack,
            MUIA_FixHeightTxt, "\n",
            MUIA_Text_Contents, copyright,
        End,
    End))
    {
        CoerceMethod(cl,obj,OM_DISPOSE);
        return 0;
    }

    DoMethod(data->viewMode,MUIM_Notify,MUIA_Cycle_Active,MUIV_EveryTime,
        data->sb,3,MUIM_Set,MUIA_SpeedBar_ViewMode,MUIV_TriggerValue);

    DoMethod(data->sunny,MUIM_Notify,MUIA_Selected,MUIV_EveryTime,
        data->sb,3,MUIM_Set,MUIA_SpeedBar_Sunny,MUIV_TriggerValue);

    DoMethod(data->borderLess,MUIM_Notify,MUIA_Selected,MUIV_EveryTime,
        data->sb,3,MUIM_Set,MUIA_SpeedBar_Borderless,MUIV_TriggerValue);

    DoMethod(data->raising,MUIM_Notify,MUIA_Selected,MUIV_EveryTime,
        data->sb,3,MUIM_Set,MUIA_SpeedBar_RaisingFrame,MUIV_TriggerValue);

    DoMethod(data->small,MUIM_Notify,MUIA_Selected,MUIV_EveryTime,
        data->sb,3,MUIM_Set,MUIA_SpeedBar_SmallImages,MUIV_TriggerValue);

    DoMethod(obj,OM_ADDMEMBER,prefs);

    get(data->sb,MUIA_FreeDB_Bar_NoBrushes,&noBrushes);
    if (noBrushes) set(data->info,MUIA_Text_Contents,strings[MSG_BarForced]);

    return (ULONG)obj;
}

/***********************************************************************/

static ULONG ASM
mConfigToGadgets(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_Settingsgroup_ConfigToGadgets *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    ULONG                   *p, val;

    if (p = (ULONG *)DoMethod(msg->configdata,MUIM_Dataspace_Find,MUIA_FreeDB_Bar_ViewMode))
        val = *p;
    else val = MUIV_SpeedBar_ViewMode_Gfx;
    set(data->viewMode,MUIA_Cycle_Active,val);

    if (p = (ULONG *)DoMethod(msg->configdata,MUIM_Dataspace_Find,MUIA_FreeDB_Bar_Sunny))
        val = *p;
    else val = 0;
    set(data->sunny,MUIA_Selected,val);

    if (p = (ULONG *)DoMethod(msg->configdata,MUIM_Dataspace_Find,MUIA_FreeDB_Bar_Borderless))
        val = *p;
    else val = 0;
    set(data->borderLess,MUIA_Selected,val);

    if (p = (ULONG *)DoMethod(msg->configdata,MUIM_Dataspace_Find,MUIA_FreeDB_Bar_Raising))
        val = *p;
    else val = 0;
    set(data->raising,MUIA_Selected,val);

    if (p = (ULONG *)DoMethod(msg->configdata,MUIM_Dataspace_Find,MUIA_FreeDB_Bar_Small))
        val = *p;
    else val = 0;
    set(data->small,MUIA_Selected,val);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mGadgetsToConfig(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_Settingsgroup_GadgetsToConfig *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    ULONG                   p;

    get(data->viewMode,MUIA_Cycle_Active,&p);
    DoMethod(msg->configdata,MUIM_Dataspace_Add,&p,sizeof(ULONG),MUIA_FreeDB_Bar_ViewMode);

    get(data->sunny,MUIA_Selected,&p);
    DoMethod(msg->configdata,MUIM_Dataspace_Add,&p,sizeof(ULONG),MUIA_FreeDB_Bar_Sunny);

    get(data->borderLess,MUIA_Selected,&p);
    DoMethod(msg->configdata,MUIM_Dataspace_Add,&p,sizeof(ULONG),MUIA_FreeDB_Bar_Borderless);

    get(data->raising,MUIA_Selected,&p);
    DoMethod(msg->configdata,MUIM_Dataspace_Add,&p,sizeof(ULONG),MUIA_FreeDB_Bar_Raising);

    get(data->small,MUIA_Selected,&p);
    DoMethod(msg->configdata,MUIM_Dataspace_Add,&p,sizeof(ULONG),MUIA_FreeDB_Bar_Small);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_Setup *msg)
{
    if (!DoSuperMethodA(cl,obj,msg)) return FALSE;
    return TRUE;
}

/***********************************************************************/

static ULONG ASM
mCleanup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_Setup *msg)
{
    if (!DoSuperMethodA(cl,obj,msg)) return FALSE;

    return TRUE;
}

/***********************************************************************/

static ULONG SAVEDS ASM
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch (msg->MethodID)
    {
        case OM_NEW:                                return mNew(cl,obj,(APTR)msg);
        case MUIM_Setup:                            return mSetup(cl,obj,(APTR)msg);
        case MUIM_Cleanup:                          return mCleanup(cl,obj,(APTR)msg);
        case MUIM_Settingsgroup_ConfigToGadgets:    return mConfigToGadgets(cl,obj,(APTR)msg);
        case MUIM_Settingsgroup_GadgetsToConfig:    return mGadgetsToConfig(cl,obj,(APTR)msg);
        default:                                    return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

void ASM
initMCPClass(void)
{
    libBase->mcp = MUI_CreateCustomClass((struct Library *)libBase,MUIC_Mccprefs,NULL,sizeof(struct data),dispatcher);
}

/***********************************************************************/
