#ifndef COMMANDLIST_LOCALE_H
#define COMMANDLIST_LOCALE_H


/****************************************************************************/


/* This file was created automatically by CatComp.
 * Do NOT edit by hand!
 */


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifdef CATCOMP_ARRAY
#undef CATCOMP_NUMBERS
#undef CATCOMP_STRINGS
#define CATCOMP_NUMBERS
#define CATCOMP_STRINGS
#endif

#ifdef CATCOMP_BLOCK
#undef CATCOMP_STRINGS
#define CATCOMP_STRINGS
#endif


/****************************************************************************/


#ifdef CATCOMP_NUMBERS

#define EXCHANGE_DESCR_STR 0
#define REQ_QUIT_STR 1
#define REQ_PROCEED_STR 2
#define REQ_CANCEL_STR 3
#define REQ_DELETE_STR 4
#define REQ_ERRTITLE_STR 5
#define REQ_REQUEST_STR 6
#define REQ_ABOUTTITLE_STR 7
#define REQ_ABOUTTEXT_STR 8
#define REQ_OK_STR 9
#define REQ_DELETETEXT_STR 10
#define CON_TITLE_STR 11
#define MAIN_MENU_PROJECT_STR 12
#define MAIN_MENU_SETTINGS_STR 13
#define MAIN_MENU_EDITCOMMANDS_STR 14
#define MAIN_MENU_EDITCOMMANDS_KEY 15
#define MAIN_MENU_LOADSETTINGS_STR 16
#define MAIN_MENU_LOADSETTINGS_KEY 17
#define MAIN_MENU_SAVESETTINGS_STR 18
#define MAIN_MENU_SAVESETTINGS_KEY 19
#define MAIN_MENU_SAVESETTINGSAS_STR 20
#define MAIN_MENU_SAVESETTINGSAS_KEY 21
#define MAIN_MENU_ABOUT_STR 22
#define MAIN_MENU_ABOUT_KEY 23
#define MAIN_MENU_HIDE_STR 24
#define MAIN_MENU_HIDE_KEY 25
#define MAIN_MENU_QUIT_STR 26
#define MAIN_MENU_QUIT_KEY 27
#define CFG_GAD_HOTKEY_STR 28
#define CFG_GAD_HOTKEY_KEY 29
#define CFG_GAD_COMMAND_STR 30
#define CFG_GAD_COMMAND_KEY 31
#define CFG_GAD_WB_STR 32
#define CFG_GAD_CLI_STR 33
#define CFG_GAD_ADD_STR 34
#define CFG_GAD_ADD_KEY 35
#define CFG_GAD_DELETE_STR 36
#define CFG_GAD_DELETE_KEY 37
#define CFG_GAD_UP_STR 38
#define CFG_GAD_UP_KEY 39
#define CFG_GAD_DOWN_STR 40
#define CFG_GAD_DOWN_KEY 41
#define CFG_GAD_TYPE_STR 42
#define CFG_GAD_TYPE_KEY 43
#define CFG_GAD_STACK_STR 44
#define CFG_GAD_STACK_KEY 45
#define CFG_NEW_ITEM_STR 46
#define CFG_REQ_TITLE_STR 47
#define ERR_INVALID_HOTKEY_STR 48
#define ERR_INVALID_ITEM_HOTKEY_STR 49
#define ERR_LAUNCH_NODIR_STR 50
#define ERR_LAUNCH_NOTFOUND_STR 51
#define ERR_LAUNCH_CREATEPROC_STR 52
#define ERR_LAUNCH_NOICON_STR 53
#define ERR_LAUNCH_STILLWORKBENCH_STR 54
#define ERR_READ_SETTINGS_STR 55
#define ERR_SAVE_SETTINGS_STR 56

#endif /* CATCOMP_NUMBERS */


/****************************************************************************/


#ifdef CATCOMP_STRINGS

#define EXCHANGE_DESCR_STR_STR "Launch commands from a list"
#define REQ_QUIT_STR_STR "Quit"
#define REQ_PROCEED_STR_STR "Proceed"
#define REQ_CANCEL_STR_STR "Cancel"
#define REQ_DELETE_STR_STR "Delete"
#define REQ_ERRTITLE_STR_STR "CommandList Error"
#define REQ_REQUEST_STR_STR "Request"
#define REQ_ABOUTTITLE_STR_STR "About"
#define REQ_ABOUTTEXT_STR_STR "CommandList %s\nCompilation date: (%s)\n\n© 1994 Johan Billing\n\nFidoNet: 2:200/207.6\nE-mail: johan.billing@kcc.ct.se\n\nHotkey: %s\n\nLaunched Workbench programs: %lu\n\nThis program is FreeWare."
#define REQ_OK_STR_STR "Ok"
#define REQ_DELETETEXT_STR_STR "Do you really want to remove the command\n\"%s\" from the list?"
#define CON_TITLE_STR_STR "CommandList Output"
#define MAIN_MENU_PROJECT_STR_STR "Project"
#define MAIN_MENU_SETTINGS_STR_STR "Settings"
#define MAIN_MENU_EDITCOMMANDS_STR_STR "Edit commands"
#define MAIN_MENU_EDITCOMMANDS_KEY_STR "E"
#define MAIN_MENU_LOADSETTINGS_STR_STR "Load Settings..."
#define MAIN_MENU_LOADSETTINGS_KEY_STR "L"
#define MAIN_MENU_SAVESETTINGS_STR_STR "Save Settings"
#define MAIN_MENU_SAVESETTINGS_KEY_STR "S"
#define MAIN_MENU_SAVESETTINGSAS_STR_STR "Save Settings As..."
#define MAIN_MENU_SAVESETTINGSAS_KEY_STR "A"
#define MAIN_MENU_ABOUT_STR_STR "About..."
#define MAIN_MENU_ABOUT_KEY_STR "?"
#define MAIN_MENU_HIDE_STR_STR "Hide"
#define MAIN_MENU_HIDE_KEY_STR "H"
#define MAIN_MENU_QUIT_STR_STR "Quit"
#define MAIN_MENU_QUIT_KEY_STR "Q"
#define CFG_GAD_HOTKEY_STR_STR "_Hotkey"
#define CFG_GAD_HOTKEY_KEY_STR "H"
#define CFG_GAD_COMMAND_STR_STR "_Command"
#define CFG_GAD_COMMAND_KEY_STR "C"
#define CFG_GAD_WB_STR_STR "WB"
#define CFG_GAD_CLI_STR_STR "CLI"
#define CFG_GAD_ADD_STR_STR "_Add"
#define CFG_GAD_ADD_KEY_STR "A"
#define CFG_GAD_DELETE_STR_STR "De_lete..."
#define CFG_GAD_DELETE_KEY_STR "L"
#define CFG_GAD_UP_STR_STR "_Up"
#define CFG_GAD_UP_KEY_STR "U"
#define CFG_GAD_DOWN_STR_STR "_Down"
#define CFG_GAD_DOWN_KEY_STR "D"
#define CFG_GAD_TYPE_STR_STR "_Type"
#define CFG_GAD_TYPE_KEY_STR "T"
#define CFG_GAD_STACK_STR_STR "_Stack"
#define CFG_GAD_STACK_KEY_STR "S"
#define CFG_NEW_ITEM_STR_STR "(new)"
#define CFG_REQ_TITLE_STR_STR "Please select command"
#define ERR_INVALID_HOTKEY_STR_STR "Invalid hotkey \"%s\""
#define ERR_INVALID_ITEM_HOTKEY_STR_STR "Invalid hotkey \"%s\" for \"%s\""
#define ERR_LAUNCH_NODIR_STR_STR "Directory \"%s\" not found"
#define ERR_LAUNCH_NOTFOUND_STR_STR "Unable to launch Worbench program \"%s\"\nNot enough memory or file not found."
#define ERR_LAUNCH_CREATEPROC_STR_STR "Unable to create process for Workbench command"
#define ERR_LAUNCH_NOICON_STR_STR "Unable to open icon for \"%s\""
#define ERR_LAUNCH_STILLWORKBENCH_STR_STR "Unable to quit, %lu Workbench programs are still running.\nPlease exit them and try again."
#define ERR_READ_SETTINGS_STR_STR "Unable to read settings file \"%s\""
#define ERR_SAVE_SETTINGS_STR_STR "Unable to save settings file \"%s\""

#endif /* CATCOMP_STRINGS */


/****************************************************************************/


#ifdef CATCOMP_ARRAY

struct CatCompArrayType
{
    LONG   cca_ID;
    STRPTR cca_Str;
};

static const struct CatCompArrayType CatCompArray[] =
{
    {EXCHANGE_DESCR_STR,(STRPTR)EXCHANGE_DESCR_STR_STR},
    {REQ_QUIT_STR,(STRPTR)REQ_QUIT_STR_STR},
    {REQ_PROCEED_STR,(STRPTR)REQ_PROCEED_STR_STR},
    {REQ_CANCEL_STR,(STRPTR)REQ_CANCEL_STR_STR},
    {REQ_DELETE_STR,(STRPTR)REQ_DELETE_STR_STR},
    {REQ_ERRTITLE_STR,(STRPTR)REQ_ERRTITLE_STR_STR},
    {REQ_REQUEST_STR,(STRPTR)REQ_REQUEST_STR_STR},
    {REQ_ABOUTTITLE_STR,(STRPTR)REQ_ABOUTTITLE_STR_STR},
    {REQ_ABOUTTEXT_STR,(STRPTR)REQ_ABOUTTEXT_STR_STR},
    {REQ_OK_STR,(STRPTR)REQ_OK_STR_STR},
    {REQ_DELETETEXT_STR,(STRPTR)REQ_DELETETEXT_STR_STR},
    {CON_TITLE_STR,(STRPTR)CON_TITLE_STR_STR},
    {MAIN_MENU_PROJECT_STR,(STRPTR)MAIN_MENU_PROJECT_STR_STR},
    {MAIN_MENU_SETTINGS_STR,(STRPTR)MAIN_MENU_SETTINGS_STR_STR},
    {MAIN_MENU_EDITCOMMANDS_STR,(STRPTR)MAIN_MENU_EDITCOMMANDS_STR_STR},
    {MAIN_MENU_EDITCOMMANDS_KEY,(STRPTR)MAIN_MENU_EDITCOMMANDS_KEY_STR},
    {MAIN_MENU_LOADSETTINGS_STR,(STRPTR)MAIN_MENU_LOADSETTINGS_STR_STR},
    {MAIN_MENU_LOADSETTINGS_KEY,(STRPTR)MAIN_MENU_LOADSETTINGS_KEY_STR},
    {MAIN_MENU_SAVESETTINGS_STR,(STRPTR)MAIN_MENU_SAVESETTINGS_STR_STR},
    {MAIN_MENU_SAVESETTINGS_KEY,(STRPTR)MAIN_MENU_SAVESETTINGS_KEY_STR},
    {MAIN_MENU_SAVESETTINGSAS_STR,(STRPTR)MAIN_MENU_SAVESETTINGSAS_STR_STR},
    {MAIN_MENU_SAVESETTINGSAS_KEY,(STRPTR)MAIN_MENU_SAVESETTINGSAS_KEY_STR},
    {MAIN_MENU_ABOUT_STR,(STRPTR)MAIN_MENU_ABOUT_STR_STR},
    {MAIN_MENU_ABOUT_KEY,(STRPTR)MAIN_MENU_ABOUT_KEY_STR},
    {MAIN_MENU_HIDE_STR,(STRPTR)MAIN_MENU_HIDE_STR_STR},
    {MAIN_MENU_HIDE_KEY,(STRPTR)MAIN_MENU_HIDE_KEY_STR},
    {MAIN_MENU_QUIT_STR,(STRPTR)MAIN_MENU_QUIT_STR_STR},
    {MAIN_MENU_QUIT_KEY,(STRPTR)MAIN_MENU_QUIT_KEY_STR},
    {CFG_GAD_HOTKEY_STR,(STRPTR)CFG_GAD_HOTKEY_STR_STR},
    {CFG_GAD_HOTKEY_KEY,(STRPTR)CFG_GAD_HOTKEY_KEY_STR},
    {CFG_GAD_COMMAND_STR,(STRPTR)CFG_GAD_COMMAND_STR_STR},
    {CFG_GAD_COMMAND_KEY,(STRPTR)CFG_GAD_COMMAND_KEY_STR},
    {CFG_GAD_WB_STR,(STRPTR)CFG_GAD_WB_STR_STR},
    {CFG_GAD_CLI_STR,(STRPTR)CFG_GAD_CLI_STR_STR},
    {CFG_GAD_ADD_STR,(STRPTR)CFG_GAD_ADD_STR_STR},
    {CFG_GAD_ADD_KEY,(STRPTR)CFG_GAD_ADD_KEY_STR},
    {CFG_GAD_DELETE_STR,(STRPTR)CFG_GAD_DELETE_STR_STR},
    {CFG_GAD_DELETE_KEY,(STRPTR)CFG_GAD_DELETE_KEY_STR},
    {CFG_GAD_UP_STR,(STRPTR)CFG_GAD_UP_STR_STR},
    {CFG_GAD_UP_KEY,(STRPTR)CFG_GAD_UP_KEY_STR},
    {CFG_GAD_DOWN_STR,(STRPTR)CFG_GAD_DOWN_STR_STR},
    {CFG_GAD_DOWN_KEY,(STRPTR)CFG_GAD_DOWN_KEY_STR},
    {CFG_GAD_TYPE_STR,(STRPTR)CFG_GAD_TYPE_STR_STR},
    {CFG_GAD_TYPE_KEY,(STRPTR)CFG_GAD_TYPE_KEY_STR},
    {CFG_GAD_STACK_STR,(STRPTR)CFG_GAD_STACK_STR_STR},
    {CFG_GAD_STACK_KEY,(STRPTR)CFG_GAD_STACK_KEY_STR},
    {CFG_NEW_ITEM_STR,(STRPTR)CFG_NEW_ITEM_STR_STR},
    {CFG_REQ_TITLE_STR,(STRPTR)CFG_REQ_TITLE_STR_STR},
    {ERR_INVALID_HOTKEY_STR,(STRPTR)ERR_INVALID_HOTKEY_STR_STR},
    {ERR_INVALID_ITEM_HOTKEY_STR,(STRPTR)ERR_INVALID_ITEM_HOTKEY_STR_STR},
    {ERR_LAUNCH_NODIR_STR,(STRPTR)ERR_LAUNCH_NODIR_STR_STR},
    {ERR_LAUNCH_NOTFOUND_STR,(STRPTR)ERR_LAUNCH_NOTFOUND_STR_STR},
    {ERR_LAUNCH_CREATEPROC_STR,(STRPTR)ERR_LAUNCH_CREATEPROC_STR_STR},
    {ERR_LAUNCH_NOICON_STR,(STRPTR)ERR_LAUNCH_NOICON_STR_STR},
    {ERR_LAUNCH_STILLWORKBENCH_STR,(STRPTR)ERR_LAUNCH_STILLWORKBENCH_STR_STR},
    {ERR_READ_SETTINGS_STR,(STRPTR)ERR_READ_SETTINGS_STR_STR},
    {ERR_SAVE_SETTINGS_STR,(STRPTR)ERR_SAVE_SETTINGS_STR_STR},
};

#endif /* CATCOMP_ARRAY */


/****************************************************************************/


#ifdef CATCOMP_BLOCK

static const char CatCompBlock[] =
{
    "\x00\x00\x00\x00\x00\x1C"
    EXCHANGE_DESCR_STR_STR "\x00"
    "\x00\x00\x00\x01\x00\x06"
    REQ_QUIT_STR_STR "\x00\x00"
    "\x00\x00\x00\x02\x00\x08"
    REQ_PROCEED_STR_STR "\x00"
    "\x00\x00\x00\x03\x00\x08"
    REQ_CANCEL_STR_STR "\x00\x00"
    "\x00\x00\x00\x04\x00\x08"
    REQ_DELETE_STR_STR "\x00\x00"
    "\x00\x00\x00\x05\x00\x12"
    REQ_ERRTITLE_STR_STR "\x00"
    "\x00\x00\x00\x06\x00\x08"
    REQ_REQUEST_STR_STR "\x00"
    "\x00\x00\x00\x07\x00\x06"
    REQ_ABOUTTITLE_STR_STR "\x00"
    "\x00\x00\x00\x08\x00\xBC"
    REQ_ABOUTTEXT_STR_STR "\x00\x00"
    "\x00\x00\x00\x09\x00\x04"
    REQ_OK_STR_STR "\x00\x00"
    "\x00\x00\x00\x0A\x00\x3E"
    REQ_DELETETEXT_STR_STR "\x00\x00"
    "\x00\x00\x00\x0B\x00\x14"
    CON_TITLE_STR_STR "\x00\x00"
    "\x00\x00\x00\x0C\x00\x08"
    MAIN_MENU_PROJECT_STR_STR "\x00"
    "\x00\x00\x00\x0D\x00\x0A"
    MAIN_MENU_SETTINGS_STR_STR "\x00\x00"
    "\x00\x00\x00\x0E\x00\x0E"
    MAIN_MENU_EDITCOMMANDS_STR_STR "\x00"
    "\x00\x00\x00\x0F\x00\x02"
    MAIN_MENU_EDITCOMMANDS_KEY_STR "\x00"
    "\x00\x00\x00\x10\x00\x12"
    MAIN_MENU_LOADSETTINGS_STR_STR "\x00\x00"
    "\x00\x00\x00\x11\x00\x02"
    MAIN_MENU_LOADSETTINGS_KEY_STR "\x00"
    "\x00\x00\x00\x12\x00\x0E"
    MAIN_MENU_SAVESETTINGS_STR_STR "\x00"
    "\x00\x00\x00\x13\x00\x02"
    MAIN_MENU_SAVESETTINGS_KEY_STR "\x00"
    "\x00\x00\x00\x14\x00\x14"
    MAIN_MENU_SAVESETTINGSAS_STR_STR "\x00"
    "\x00\x00\x00\x15\x00\x02"
    MAIN_MENU_SAVESETTINGSAS_KEY_STR "\x00"
    "\x00\x00\x00\x16\x00\x0A"
    MAIN_MENU_ABOUT_STR_STR "\x00\x00"
    "\x00\x00\x00\x17\x00\x02"
    MAIN_MENU_ABOUT_KEY_STR "\x00"
    "\x00\x00\x00\x18\x00\x06"
    MAIN_MENU_HIDE_STR_STR "\x00\x00"
    "\x00\x00\x00\x19\x00\x02"
    MAIN_MENU_HIDE_KEY_STR "\x00"
    "\x00\x00\x00\x1A\x00\x06"
    MAIN_MENU_QUIT_STR_STR "\x00\x00"
    "\x00\x00\x00\x1B\x00\x02"
    MAIN_MENU_QUIT_KEY_STR "\x00"
    "\x00\x00\x00\x1C\x00\x08"
    CFG_GAD_HOTKEY_STR_STR "\x00"
    "\x00\x00\x00\x1D\x00\x02"
    CFG_GAD_HOTKEY_KEY_STR "\x00"
    "\x00\x00\x00\x1E\x00\x0A"
    CFG_GAD_COMMAND_STR_STR "\x00\x00"
    "\x00\x00\x00\x1F\x00\x02"
    CFG_GAD_COMMAND_KEY_STR "\x00"
    "\x00\x00\x00\x20\x00\x04"
    CFG_GAD_WB_STR_STR "\x00\x00"
    "\x00\x00\x00\x21\x00\x04"
    CFG_GAD_CLI_STR_STR "\x00"
    "\x00\x00\x00\x22\x00\x06"
    CFG_GAD_ADD_STR_STR "\x00\x00"
    "\x00\x00\x00\x23\x00\x02"
    CFG_GAD_ADD_KEY_STR "\x00"
    "\x00\x00\x00\x24\x00\x0C"
    CFG_GAD_DELETE_STR_STR "\x00\x00"
    "\x00\x00\x00\x25\x00\x02"
    CFG_GAD_DELETE_KEY_STR "\x00"
    "\x00\x00\x00\x26\x00\x04"
    CFG_GAD_UP_STR_STR "\x00"
    "\x00\x00\x00\x27\x00\x02"
    CFG_GAD_UP_KEY_STR "\x00"
    "\x00\x00\x00\x28\x00\x06"
    CFG_GAD_DOWN_STR_STR "\x00"
    "\x00\x00\x00\x29\x00\x02"
    CFG_GAD_DOWN_KEY_STR "\x00"
    "\x00\x00\x00\x2A\x00\x06"
    CFG_GAD_TYPE_STR_STR "\x00"
    "\x00\x00\x00\x2B\x00\x02"
    CFG_GAD_TYPE_KEY_STR "\x00"
    "\x00\x00\x00\x2C\x00\x08"
    CFG_GAD_STACK_STR_STR "\x00\x00"
    "\x00\x00\x00\x2D\x00\x02"
    CFG_GAD_STACK_KEY_STR "\x00"
    "\x00\x00\x00\x2E\x00\x06"
    CFG_NEW_ITEM_STR_STR "\x00"
    "\x00\x00\x00\x2F\x00\x16"
    CFG_REQ_TITLE_STR_STR "\x00"
    "\x00\x00\x00\x30\x00\x14"
    ERR_INVALID_HOTKEY_STR_STR "\x00"
    "\x00\x00\x00\x31\x00\x1E"
    ERR_INVALID_ITEM_HOTKEY_STR_STR "\x00\x00"
    "\x00\x00\x00\x32\x00\x1A"
    ERR_LAUNCH_NODIR_STR_STR "\x00\x00"
    "\x00\x00\x00\x33\x00\x4C"
    ERR_LAUNCH_NOTFOUND_STR_STR "\x00"
    "\x00\x00\x00\x34\x00\x30"
    ERR_LAUNCH_CREATEPROC_STR_STR "\x00\x00"
    "\x00\x00\x00\x35\x00\x1E"
    ERR_LAUNCH_NOICON_STR_STR "\x00\x00"
    "\x00\x00\x00\x36\x00\x5A"
    ERR_LAUNCH_STILLWORKBENCH_STR_STR "\x00"
    "\x00\x00\x00\x37\x00\x22"
    ERR_READ_SETTINGS_STR_STR "\x00"
    "\x00\x00\x00\x38\x00\x22"
    ERR_SAVE_SETTINGS_STR_STR "\x00"
};

#endif /* CATCOMP_BLOCK */


/****************************************************************************/


struct LocaleInfo
{
    APTR li_LocaleBase;
    APTR li_Catalog;
};


#ifdef CATCOMP_CODE

STRPTR GetString(struct LocaleInfo *li, LONG stringNum)
{
LONG   *l;
UWORD  *w;
STRPTR  builtIn;

    l = (LONG *)CatCompBlock;

    while (*l != stringNum)
    {
        w = (UWORD *)((ULONG)l + 4);
        l = (LONG *)((ULONG)l + (ULONG)*w + 6);
    }
    builtIn = (STRPTR)((ULONG)l + 6);

#define XLocaleBase LocaleBase
#define LocaleBase li->li_LocaleBase
    
    if (LocaleBase)
        return(GetCatalogStr(li->li_Catalog,stringNum,builtIn));
#define LocaleBase XLocaleBase
#undef XLocaleBase

    return(builtIn);
}


#endif /* CATCOMP_CODE */


/****************************************************************************/


#endif /* COMMANDLIST_LOCALE_H */
