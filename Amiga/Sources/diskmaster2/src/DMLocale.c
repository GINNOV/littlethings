/* DiskMaster II  Locale Module
**
** This file was created automatically by `FlexCat 2.4'
** from "DiskMaster2.cd".
**
** Do NOT edit by hand!
**
*/

#include "DM.h"

#include <libraries/locale.h>
#include <proto/locale.h>

struct FC_String DiskMaster2_Strings[168] = {
    { (STRPTR) "Close all visitor windows!", 0 },
    { (STRPTR) "Out of memory!", 1 },
    { (STRPTR) "File move error!", 2 },
    { (STRPTR) "Font is proportional!", 3 },
    { (STRPTR) "Total: %s - Not enough room!", 4 },
    { (STRPTR) "Delete Failed", 5 },
    { (STRPTR) "Can`t Quit! %ld Arexx-Script(s) still running!", 6 },
    { (STRPTR) "Unable to compress %s !", 7 },
    { (STRPTR) "Unable to decompress %s !", 8 },
    { (STRPTR) "Unable to open: %s !", 9 },
    { (STRPTR) "Error initializing reader!", 10 },
    { (STRPTR) "Error viewing file: %s !", 11 },
    { (STRPTR) "Close all Info, View and Help windows!", 12 },
    { (STRPTR) "Enter new name for %s:", 1000 },
    { (STRPTR) "Enter new filename:", 1001 },
    { (STRPTR) "Enter comment for %s:", 1002 },
    { (STRPTR) "Enter protection mask for:\n%s", 1003 },
    { (STRPTR) "Enter new directory name:", 1004 },
    { (STRPTR) "Enter command string:", 1005 },
    { (STRPTR) "Enter ARexx string:", 1006 },
    { (STRPTR) "Enter new archive name:", 1007 },
    { (STRPTR) "Enter select-pattern:", 1008 },
    { (STRPTR) "Directories selected. Specify pattern:", 1009 },
    { (STRPTR) "Enter new display-format:", 1010 },
    { (STRPTR) "Auto Command: data,pattern,<command string>", 1011 },
    { (STRPTR) "Command template: Title,##,##,<command string>", 1012 },
    { (STRPTR) "Enter filename to save:", 1013 },
    { (STRPTR) "Key Command: C,<command string>", 1014 },
    { (STRPTR) "Command template: Menu,Title,A,<command string>", 1015 },
    { (STRPTR) "Enter destination path:", 1016 },
    { (STRPTR) "Found: %s\nOpen New Window?", 1017 },
    { (STRPTR) "Enter new button command string:", 1018 },
    { (STRPTR) "%s exists:\n"\
	"  Source: %ld bytes - %s %s\n"\
	"  Dest:   %ld bytes - %s %s\n"\
	"Okay to overwrite?", 1019 },
    { (STRPTR) "Go to line:", 1020 },
    { (STRPTR) "Enter search pattern:", 1021 },
    { (STRPTR) "Built-in english catalog in use.", 1022 },
    { (STRPTR) "Enter DiskMaster2 command:", 1023 },
    { (STRPTR) "_Okay", 2000 },
    { (STRPTR) "_Cancel", 2001 },
    { (STRPTR) "_Skip", 2002 },
    { (STRPTR) "_Icon", 2003 },
    { (STRPTR) "_Yes|_All|_Rename...|N_one|_No|_Cancel", 2004 },
    { (STRPTR) "_Okay|_Skip|_Cancel", 2005 },
    { (STRPTR) "_Okay|A_ll|S_kip|_Cancel", 2006 },
    { (STRPTR) "Moving %s", 3000 },
    { (STRPTR) "Copying %s", 3001 },
    { (STRPTR) "Total: %s - Leaving %s free.", 3002 },
    { (STRPTR) "Listing of %s\n\n", 3003 },
    { (STRPTR) "Deleted %s", 3004 },
    { (STRPTR) "Select Command to Edit", 3005 },
    { (STRPTR) "Press RETURN to continue...\n", 3006 },
    { (STRPTR) "Operation canceled", 3007 },
    { (STRPTR) "compressed", 3008 },
    { (STRPTR) "decompressed", 3009 },
    { (STRPTR) "Pattern Not Found", 3010 },
    { (STRPTR) "No Search Pattern", 3011 },
    { (STRPTR) "Searching %s...", 3012 },
    { (STRPTR) "B", 4000 },
    { (STRPTR) "K", 4001 },
    { (STRPTR) "M", 4002 },
    { (STRPTR) "G", 4003 },
    { (STRPTR) "T", 4004 },
    { (STRPTR) "Broken Link!", 4005 },
    { (STRPTR) "Name", 4006 },
    { (STRPTR) "Size", 4007 },
    { (STRPTR) "Date", 4008 },
    { (STRPTR) "Comment", 4009 },
    { (STRPTR) "Time", 4010 },
    { (STRPTR) "Flags", 4011 },
    { (STRPTR) "DiskMaster2 Preferences", 5000 },
    { (STRPTR) "Press HELP for details", 5001 },
    { (STRPTR) "Changed", 5002 },
    { (STRPTR) "Unchanged", 5003 },
    { (STRPTR) "Add a new entry", 5004 },
    { (STRPTR) "Remove the selected entry", 5005 },
    { (STRPTR) "Move selected item up", 5006 },
    { (STRPTR) "Move selected item down", 5007 },
    { (STRPTR) "Discard changes", 5008 },
    { (STRPTR) "Use these settings", 5009 },
    { (STRPTR) "Save settings", 5010 },
    { (STRPTR) "Use HostScreen or NewScreen", 5011 },
    { (STRPTR) "Use SetX DefX & DefY", 5012 },
    { (STRPTR) "Reverse sort order", 5013 },
    { (STRPTR) "All windows, or Source only?", 5014 },
    { (STRPTR) "Copy current color to another cell", 5015 },
    { (STRPTR) "Swap current color with another cell", 5016 },
    { (STRPTR) "Reset the current", 5017 },
    { (STRPTR) "Reset the palette", 5018 },
    { (STRPTR) "Select the Pen to change", 5019 },
    { (STRPTR) "Command window to edit", 5020 },
    { (STRPTR) "Foreground color", 5021 },
    { (STRPTR) "Background color", 5022 },
    { (STRPTR) "Choose pen color (0-28) from palette", 5023 },
    { (STRPTR) "_Main", 5100 },
    { (STRPTR) "_Windows", 5101 },
    { (STRPTR) "_Fonts", 5102 },
    { (STRPTR) "C_olors", 5103 },
    { (STRPTR) "Comman_ds", 5104 },
    { (STRPTR) "M_enus", 5105 },
    { (STRPTR) "_Auto-Commands", 5106 },
    { (STRPTR) "_Keyboard-Commands", 5107 },
    { (STRPTR) "Public screen", 5200 },
    { (STRPTR) "Custom screen", 5201 },
    { (STRPTR) "Screen", 5202 },
    { (STRPTR) "Title format:", 5203 },
    { (STRPTR) "Scale windows to fit screen?", 5204 },
    { (STRPTR) "AppIcon", 5205 },
    { (STRPTR) "Digits:", 5206 },
    { (STRPTR) "Guide:", 5207 },
    { (STRPTR) "Help button in requesters?", 5208 },
    { (STRPTR) "hh:mm", 5300 },
    { (STRPTR) "hh:mm:ss:tt", 5301 },
    { (STRPTR) "1234567", 5302 },
    { (STRPTR) "1205 K", 5303 },
    { (STRPTR) "1,234,567", 5304 },
    { (STRPTR) "Name", 5305 },
    { (STRPTR) "Size", 5306 },
    { (STRPTR) "Date", 5307 },
    { (STRPTR) "Comment", 5308 },
    { (STRPTR) "Extension", 5309 },
    { (STRPTR) "Name length", 5310 },
    { (STRPTR) "dot", 5311 },
    { (STRPTR) "comma", 5312 },
    { (STRPTR) "space", 5313 },
    { (STRPTR) "Volume", 5314 },
    { (STRPTR) "Display format:", 5315 },
    { (STRPTR) "Button:", 5316 },
    { (STRPTR) "Reverse", 5317 },
    { (STRPTR) "Global", 5318 },
    { (STRPTR) "Sort by:", 5319 },
    { (STRPTR) "Timestamp:", 5320 },
    { (STRPTR) "Separator:", 5321 },
    { (STRPTR) "Size style:", 5322 },
    { (STRPTR) "Wheel multiplier:", 5323 },
    { (STRPTR) "Hide Dev:", 5324 },
    { (STRPTR) "Sc_reen:", 5400 },
    { (STRPTR) "Directory _entries:", 5401 },
    { (STRPTR) "Directory _paths:", 5402 },
    { (STRPTR) "C_MD-window entries:", 5403 },
    { (STRPTR) "_Reader:", 5404 },
    { (STRPTR) "_Menus:", 5405 },
    { (STRPTR) "Requester _text:", 5406 },
    { (STRPTR) "Requester _buttons:", 5407 },
    { (STRPTR) "Colors", 5500 },
    { (STRPTR) "Copy", 5501 },
    { (STRPTR) "Swap", 5502 },
    { (STRPTR) "Reset", 5503 },
    { (STRPTR) "Reset All", 5504 },
    { (STRPTR) "User colors:", 5505 },
    { (STRPTR) "Pens", 5506 },
    { (STRPTR) "Select the Pen to change", 5507 },
    { (STRPTR) "Title", 5600 },
    { (STRPTR) "Command", 5601 },
    { (STRPTR) "Menu Name", 5602 },
    { (STRPTR) "Key", 5603 },
    { (STRPTR) "File Data", 5604 },
    { (STRPTR) "Filename Pattern", 5605 },
    { (STRPTR) "Foreground", 5606 },
    { (STRPTR) "Background", 5607 },
    { (STRPTR) "Command Window", 5608 },
    { (STRPTR) "No Command Windows", 5609 },
    { (STRPTR) "_Save...", 5700 },
    { (STRPTR) "_Use", 5701 },
    { (STRPTR) "_Cancel", 5702 },
    { (STRPTR) "Add", 5703 },
    { (STRPTR) "Remove", 5704 },
    { (STRPTR) "Move Up", 5705 },
    { (STRPTR) "Move Down", 5706 }
};

STATIC struct Catalog *DiskMaster2Catalog = NULL;


VOID CloseDiskMaster2Catalog(VOID)
{
if (DiskMaster2Catalog)
 {
  CloseCatalog(DiskMaster2Catalog);
 }
}

VOID OpenDiskMaster2Catalog(VOID)
{
if (LocaleBase)
 {
  if ((DiskMaster2Catalog = OpenCatalog(NULL, (STRPTR) "DiskMaster2.catalog",
                               OC_BuiltInLanguage, "english",
                               OC_Version, 2,
                               TAG_DONE)))
   {
    struct FC_String *fc;
    int i;

    for (i = 0, fc = DiskMaster2_Strings;  i < 168;  i++, fc++)
     {
      fc->msg = GetCatalogStr(DiskMaster2Catalog, fc->id, (STRPTR) fc->msg);
     }
   }
 }
}
