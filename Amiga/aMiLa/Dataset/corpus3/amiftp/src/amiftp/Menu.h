
struct CallBackHook menuhooks[]={
    {Reconnect,AG_MENURECONNECT},
    {AddToSitelist,AG_MENUADDTOSITELIST},
    {menu_ResetADT,AG_MENURESETADT},
    {menu_Iconify,AG_MENUICONIFY},
    {About,AG_MENUABOUT},
    {menu_Quit,AG_MENUQUIT},
    {menu_SelectAll,AG_MENUTAGALL},
    {menu_UnselectAll,AG_MENUUNTAGALL},
    {menu_BinaryTransferMode,AG_MENUTRANSFERMODE},
    {menu_AsciiTransferMode,AG_MENUTRANSFERMODE},
    {menu_ClearCache,AG_MENUCLEARCACHE},
    {menu_Delete,AG_MENUDELETE},
    {menu_SortByName,AG_MENUSORT},
    {menu_SortByDate,AG_MENUSORT},
    {OpenPrefsWindow,AG_MENUGLOBAL},
    {menu_HostlistPrefs,AG_MENUSITELIST},
    {menu_LogWindow,AG_MENULOGWINDOW},
    {ToggleDotFiles,AG_MENUTOGGLEDOT},
    {menu_ToggleADT,AG_MENUTOGGLEADT},
    {LoadPrefs,AG_MENULOADSETTINGS},
    {SavePrefs,AG_MENUSAVESETTINGS},
    {SavePrefsAs,AG_MENUSAVESETTINGS}
};

struct NewMenu mainmenus[] = 
{
    {NM_TITLE, NULL, NULL,0,~0,NULL},                    /* Project */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[0]},/*Reconnect},         * Reconnect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[1]}, /* Add to sitelist */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[2]},
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[3]},      /* Iconify */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[4]},            /* About */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[5]},        /* Quit */
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* Files */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[6]},   /* Tag all */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[7]}, /* Untag all */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,NULL},                    /* Transfer mode */
    {NM_SUB,     NULL,NULL,CHECKIT,~1,&menuhooks[8]}, /* Binary */
    {NM_SUB,     NULL,NULL,0,~2,&menuhooks[9]},  /* ASCII */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[10]},         /* Clear cache */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[11]},      /* Delete */
/*    {NM_ITEM,    "Move","M",0,~0,(APTR) &menuhooks[9]},*/
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* Sort */
    {NM_ITEM,    NULL,NULL,CHECKIT,~1,(APTR)&menuhooks[12]},
    {NM_ITEM,    NULL,NULL,CHECKIT,~2,(APTR)&menuhooks[13]},
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* Settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[14]},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[15]},
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[16]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[17]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[18]}, /* Log window */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[19]},                   /* Load settings... */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[20]},                   /* Save settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[21]},                   /* Save settings as...*/
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* HotList */
    {NM_END}
};

LONG MenuLabels[] =
{
    (LONG)MENU_Project,
    (LONG)MENU_Reconnect,
    (LONG)MENU_AddToSiteList,
    (LONG)MENU_ResetADT,
    (LONG)MENU_Iconify,
    (LONG)MENU_About,
    (LONG)MENU_Quit,

    (LONG)MENU_Files,
    (LONG)MENU_TagAll,
    (LONG)MENU_UntagAll,
    (LONG)MENU_TransferMode,
    (LONG)MENU_Binary,
    (LONG)MENU_ASCII,
    (LONG)MENU_ClearCache,
    (LONG)MENU_Delete,
    /*MENU_Move,*/

    (LONG)MENU_Sort,
    (LONG)MENU_SortbyName,
    (LONG)MENU_SortbyDate,

    (LONG)MENU_Settings,
    (LONG)MENU_Global,
    (LONG)MENU_Hostlist,
    (LONG)MENU_LogWindow,
    (LONG)MENU_ToggleDotFiles,
    (LONG)MENU_ToggleADTFiles,
    (LONG)MENU_LoadSettings,
    (LONG)MENU_SaveSettings,
    (LONG)MENU_SaveSettingsAs,

    (LONG)MENU_HotList
  };
