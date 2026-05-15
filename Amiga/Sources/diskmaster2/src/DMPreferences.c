/* DiskMaster2 preferences module
**
** 2.6
**
** 05-08-23 jjt - First post! :-)
**
** 05-08-24 jjt - Works!  First internal release.
**              - Supports "TitleFormat", "SetFormat", "SetX TIMEPLUS", and "SetX SIZES".
**
** 05-08-25 jjt - Added "SetX SEPARATOR".
**              - Gadgets no longer spread vertically when window is enlarged.
**
** 05-08-26 jjt - Rearranged gadget IDs so the "modified" and "PrefGadgets" arrays no longer
**                waste 3 LONGs.
**              - Req. now blocks input (Busy()).  @#&%!  ...And unblocks when finished.
**              - Added "SetX NOTIFY".
**              - Bugfix:  DMPrefReq() - <page> was accidentally reused as the page group
**                pointer.
**              - Added a status bar:  Displays DM command name, & modified status.
**              - Rearragned gadget IDs (again) for simplicity with status reporting.
**
** 05-08-27 jjt - Gadget IDs are now enumerations.
**              - Replaced all "GA_TextAttr" tags with one "WINDOW_TextAttr" tag.
**              - Added "NewScreen" and "HostScreen" with a toggle.
**              - Added buildHostScreenGad() and buildNewScreenGad() support functions.
**
** 05-08-28 jjt - Made DMP_HostScreen and DMP_Screen_<x> global vars.  Can be used by SaveConfig().
**              - Added initHelpStrings().
**              - DMPrefReq() Removed "Reaction exists" test.
**              - Added "BarFormat" and "SetX DefX and DefY".
**
** 05-08-29 jjt - Added "SetX DIGITS", "SetX APPICON", "SetX IconX and IconY".
**              - Bugfix:  DMPrefReq() - "case WMHI_GADGETUP:" was missing a "break".
**              - Replaced all "read a string gadget's buffer" code with calls to
**                GetAttr(STRINGA_TextVal, ...).
**              - Bugfix:  DMPrefReq() - ActionArgs[1] wasn't set to NULL begore calling
**                SaveConfig().
**              - Bugfix: DMPrefReq() - WMHI_GADGETHELP tests that "gid" is in bounds.
**                (Moving off-window occasionally had odd results).
**
** 05-08-30 jjt - DMPrefReq() - Added code to translate "-1" to/from NO_ICON_POSITION for
**                IconX and IconY (SetX).
**              - Bugfix: DMPrefReq() - GID_USESCREENTYPE was broken.  "page_main_g1" was
**                assigned multiple times (from cutting & pasting).
**              - DMPrefReq() - SetX DefX & DefY will be set depending on the state of
**                GID_SETX_WINSCALE.
**              - DMPrefReq() - Added a test to compare SETX_APPICON's string gadget to current
**                AppIconPath.  GetFile.gadget is silent when its string gadget is changed.
**
** 05-08-31 jjt - Removed temporoary DM.c code.
**              - DMPrefReq() - Removed a useless ">= 0" comparison between unsigneds in
**                WMHI_GADGETHELP.
**              - Removed "SetX NOTIFY".
**              - DMPrefReq() - Req. won't close if "Save" fails.
**              - DMPrefReq() - Changed "SetX DIGITS" to a chooser gadget.
**              - DMPrefReq() - WMHI_GADGETUP - using a switch() instead of if()s.
**              - DMPrefReq() - GID_SETX_WINSCALE will also toggle the disabled state of
**                              GID_SETX_DEFX and GID_SETX_DEFY.
**              - DMPrefReq() - Added "WA_Width" tag to set window to half the screen's width.
**              - DMPrefReq(), buildHostScreenGad() - Set STRINGA_Justification (Left)
**                for all string gadgets.
**
** 05-09-01 jjt - Added "Sort".
**              - DMPrefReq() - Removed "bdyta"; it was never used.
**              - DMPrefReq() - Created "Fonts" page.
**
** 05-09-02 jjt - "Fonts" gadgets work.
**
** 05-09-03 jjt - Removed 3 gcc warnings.
**              - DMPrefReq() - Removed "STRINGA_Justification" tags.
**              - DMPrefReq() - Added tab-cycling to gadgets that support it.
**              - DMPrefReq() - Added keyboard shortcuts to the clicktab and some gadgets.
**              - DMPrefReq() - Changed "WINDOW_Layout" tag to "WINDOW_ParentGroup".
**              - DMPrefReq() - Pressing "Tab", when nothing is active, will activate the first
**                gadget on the current page.
**
** 05-09-06 jjt - DMPrefReq() - Set window font to DMFONTS_REQTXT, and "Save", "Use", and
**                "Cancel" buttons to DMFONTS_REQBTN.
**              - Removed commented-out appicon-display code.
**              - DMPrefReq() - Renamed the gadget lables for "SetX DIGITS", "Font DIRWIN",
**                and "Font DirGad".
**              - Moved init of DMP_Screen_<x> vars to InitScreenDefaults() in DMScreen.c.
**              - Removed DMP_ValidDMPScreenVals var.  They're always valid now.
**              - Bugfix: DMPrefReq() - Added a test to keep DMP_Screen_Depth <= 8.
**              - Bugfix: DMPrefReq() - "scrnta"'s Style & Flags weren't initialized.
**              - DMPrefReq() - Resets DM if screen mode/type is changed.
**
** 05-09-07 jjt - Bugfix:  Canceling the DMPrefs req. after changing the screen mode would
**                still reset DM to that mode.
**              - Bugfix:  After changing the screen mode, but canceling the DMPrefs req.,
**                the changed values would still be used in SaveConfig().
**              - Changing the screen font will triger a DM reset.
**
** 05-09-12 jjt - Added "SetX DRAGDELAY" and "SetX WHEELMULT".
**
** 05-09-13 jjt - DMPrefReq() - Moved "Button" string gad higher on the "Windows" page.
**              - DMPrefReq() - Renamed 2-line "Thousands separator" label to "1000 separator".
**              - Changed command options in DMP_Help array from uppercase to mixed-case.
**
** 05-09-16 jjt - DMPrefReq() - Beginning the "Colors" page.  Palette.
**
** 05-09-17 jjt - Bugfix:  DMPrefReq() - GID_FONT_DIRWIN and GID_FONT_DIRGAD labels
**                were swapped (I thought I fixed this before?!).
**              - DMPrefReq() - "Colors" page:  Sliders.
**              - Split DMPrefReq() into three functions:  DMPrefReq(), DMPHandleInput(),
**                and DMPSetPreferences().
**                So now there are three too-large functions instead of one really-
**                freakin'-too-huge function. ...And it all still seems to work. :-)
**
** 05-09-18 jjt - Gadget interconnection actually works(!).
**                Connected GID_PALETTE, GID_COLORBOX, and GID_COLORBOXIDX.
**              - Connedted GID_<???>SLIDER to GID_<???>INTVAL.
**              - Added "SetX UserColors".
**
** 05-09-19 jjt - Added setEditColor().  Sets GID_<???>SLIDER and GID_<???>INTVAL to the
**                current palette color.
**              - Added putEditColor().  Puts the slider values into the current palette
**                color.
**
** 05-09-20 jjt - DMPrefReq() - Current palette is backed up, & reset on a Cancel.
**              - Added ResetColor() - Resets one or all palette color(s).
**
** 05-09-26 jjt - Bugfix: DMPrefReq() - Moved the GetRGB32() call that backs up the ColorMap
**                to after the window is opened.  This fixes the backed-up colors not matching
**                the palette gadget's colors.
**
** 05-09-27 jjt - Bugfix: DMPrefReq() - Some SetGadgetAttrs() were called before <win> was
**                valid.  <win> will now always be NULL (safe) or valid.
**
** 05-10-01 jjt - DMPrefReq() - Implemented color Copy and Swap.
**
** 05-10-02 rri - Forced the string-gadgets to appear left-adjusted by manually
**                setting their position to "0" after the windows has been opened.
**              - Removing two warnings about dead assignments SAS-C complained about.
**              - Fixed a warning with GCC and the separator-char.
**
** 05-10-02 jjt - Under Os 3.x, only string-gadgets on the current page get refreshed
**                after BufferPos is set to "0".  Otherwise a rendering glitch occurs.
**              - DMPrefReq() - Removed the "*.info" pattern from the AppIcon file req.
**
** 05-10-03 rri - Fixed the separator-char warning fix...
**
** 05-10-03 jjt - DMPrefReq() - Removed the test to keep DMP_Screen_Depth <= 8.
**              - Added DMPHandleIDCMP(), an IDCMP hook.  Step one for real-time slider updates.
**
** 05-10-04 jjt - Added a "(void *)" after the "(ULONG *)" cast in GetAttr() calls to
**                quiet a GCC warning.
**              - Added makeRgbSliderInterconnect().  Real-time slider updates step two.
**              - Reduced the number of global variables.
**              - DMPrefReq() - Most palette controls are disabled when DM is using a public screen.
**
** 05-10-05 jjt - DMPrefReq() - When DM uses a public screen, the RGB integer gadgets are.
**                read-only instead of disabled (so the values are readable), and the
**                arrows disappear.
**              - Bugfix: DMPHandleIDCMP() - Input from the RGB integer gadgets is recognized.
**              - DMPSetPreferences() - Added "SetX UserColors".
**              - Bugfix: DMPHandleInput() - GID_COLORBOXIDX didn't update the RGB sliders.
**              - Replaced DMP_ColorTable32[] with ColMap[], from DMPalette.c
**
** 05-10-08 jjt - Bugfix: DMPrefReq() - Removed _BackFill and LAYOUT_FILLPATTERN tags.
**                These interfere with _BackgroundPen, especially in OS4.
**              - Removed the VLayout group containing the ClickTab.  It's only needed when
**                using a FillPattern or BackFill.
**              - Added a test so that gadget refreshes necessary on 16/24-bit screens won't
**                occur on 8-bit screens.
**              - DMPSetPreferences() - A changed palette will trigger a DM reset on 16/24-bit
**                screens.
**              - DMP_Screen_Depth is set from GetBitMapAttr() instead of copying Screen_Depth.
**              - Replaced some "ULONG"s and "WORD"s with "uint32" and "int16".
**
** 05-10-09 jjt - Bugfix: DMPSetPreferences() - "case GID_SCREEN:" was missing a "break".
**
** 05-10-10 jjt - DMP_ColorTable32 is back.
**
** 05-10-16 jjt - Fixed gcc warnings.
**              - Bugfix: makepaletteInterconnect() - The "if (model...)" had a semicolon.
**              - Bugfix: makeRgbSliderInterconnect() - The "if (model...)" had a semicolon.
**              - Removed the "Experimental" label in the comments section, and merged the
**                comments.
**              - DMPrefReq() - Added tests to compare the current contents of string and
**                integer gadgets against their initial contents, and set DMP_Modified
**                accordingly.
**
** 05-10-17 jjt - DMPrefReq() - "SetX Separator" now uses a chooser gadget.
**              - DMPrefReq() - Moved "SetX Separator" gadget beside "SetX Sizes".
**              - Bugfix: DMPrefReq() - Used the wrong var to index strtest_init[] and
**                inttest_init[] arrays.
**
** 05-10-30 rri - Removed a few warnings with GCC4
**              - Added a line for 'Sizes' that somehow was missing...
**
** 05-11-02 jjt - Bugfix: The state of GID_SETX_WINSCALE is preserved.
**                Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**              - Removed SetX DefX & DefY integer gadgets.  GID_SETX_WINSCALE controls
**                whether defx & defy are set to the current screen width & height.
**
** 05-11-02 jjt - Simplified GID_SETX_WINSCALE a little more.
**              - DMPrefReq() - Removed scrnta; the DMTextAttrs array has this info.
**
** 05-11-05 jjt - DMPrefReq() - Changed GID_SETFORMAT's label to "Display format:".
**              - Bugfix: DMPSetPreferences() - case GID_SCREEN's "break" was inside an
**                "if" block.
**              - Bugfix: DMP_UseHostScreen is initialized to FALSE.
**              - DMPrefReq() - Changed PrefGadgets[GID_SCREEN] init.
**              - Bugfix: DMPSetPreferences() - case GID_SCREEN's "resetDM" should also
**                be outside the "if" block.
**
** 05-11-07 jjt - Changed DMP_Help from an array of strings to an array of helpdata structs.
**              - DMPHandleInput() - "Help" key triggers context sensitive help.
**
** 05-11-08 jjt - Added "SetX Guide".
**
** 05-11-12 jjt - DMP_UseHostScreen's initial value is TRUE.
**
** 05-11-13 jjt - DMPrefReq() - Changed GID_SETX_WINSCALE's text.
**                Suggested by Gerd Frank <mainactor@gmx.net>.
**
** 05-11-15 jjt - DMPHandleInput() - Commented-out the Esc = Quit lines.
**              - DMPrefReq() - The status bar is now a read-only button.
**
** 05-11-16 jjt - DMP_HandleInput() - Added "- Press HELP for details" to the status
**                bar message.
**              - Removed "lines" field of struct helpdata.
**
** 05-11-22 jjt - build...ScreenGad() sets the help node of GID_USESCREENTYPE.
**
** 05-11-23 jjt - Added "SetX REQHIDEHELP".
**
** 05-11-26 jjt - DMPrefReq() - Added a v45+ test.
**
** 05-11-27 jjt - DMP_UseWinScale's default is FALSE.
**
** 05-11-29 jjt - DMPrefReq() - Added a border around the remaining gadgets on the Main page.
**                Suggested by Gerd Frank <mainactor@gmx.net>.
**              - DMPrefReq() - The HELP key works within string gadgets.
**
** 05-11-30 jjt - ClassAct compatible.
**                Removed 05-11-26's v45+ test.
**                Added makeCALabels() and freeCALabels().
**                make...Interconnect() - Replaced SetGadgetAttrs() calls with SetAttrs().
**
** 05-12-01 jjt - makeCALabels() - Removed 2 useless ClickTab tags (Enabled and Spacing).
**
** 05-12-04 rri - Modifying the ActivateLayoutGadget() line somehow does cure a system-freeze
**                occuring on OS4 when using TAB-cycling.
**              - Removed one warning with GCC4.
**
** 05-12-07 jjt - DMPrefReq() - Screen font gadget is disabled when the screen type gadget is
**                set to use a public screen.
**                Suggested by David Rey <tactica@gmx.net>.
**              - Bugfix: DMPSetPreferences() - The screen font won't be set when a public
**                screen is in use/selected.
**              - DMPrefReq() - Added the character names to SetX Separator gadget's choices.
**                Suggested by David Rey <tactica@gmx.net>.
**
** 05-12-10 rri - Following David Rey's first impression changed the names for the
**                separators again.
**
** 2.7 ??
**
** 05-12-15 jjt - Added "Keys" page.
**              - Added makeKeyCmdsList() - Support function to build a ListBrowser list of
**                the key commands.
**              - DMP_HandleInput() - GID_KEY_ADD and GID_KEY_REM buttons work.
**
** 05-12-16 jjt - Added DMPSetPrefs_KeyCmds() - Applies the new key cmds.
**              - Added dmpAddNewNode() and dmpRemoveNode() support functions.
**              - Added dmpMoveNode(), and "Move" buttons to the listview.
**              - Bugfix: Just clicking in the listview would set its modified flag.
**              - Added makeListView() - Creates a listview and support buttons.
**              - DMPrefReq() - Key command listview is created by makeListView().
**
** 05-12-17 jjt - DMPSetPrefs_KeyCmds() - Added a test for empty key strings.
**              - Added "AutoCmds" page.
**              - Added makeAutoCmdsList().
**              - Added DMPSetPrefs_AutoCmds() - Applies new AutoCmds.
**
** 05-12-18 jjt - Bugfix: The AutoCmds list wasn't freed.
**              - Added makeMenusList().
**              - Added "Menus" page.
**              - dmpAddNewNode(), dmpRemoveNode() - Simplified.
**              - Added DMPSetPrefs_Menus() - Applies new Menus.
**              - DMPrefReq(), makeListView() - Trying a new layout for the command pages;
**                no title and fewer layout groups.
**              - DMPrefReq() - Rearranged command pages to Menu, AutoCmds, KeyCmds (SaveConfig order).
**              - Removed some commented-out code.
**
** 05-12-19 jjt - Bugfix: FirstGad[] wasn't rearranged along with the tab order.
**
** 05-12-20 jjt - dmpAddNewNode() - New nodes are inserted after the current node, if there
**                is one.
**              - Added dmpDisableLVButtons().  "Remove" and the "Move" buttons are disabled
**                when no node is selected.
**              - DMPrefReq() - Layout experiment:  "Menus", "AutoCmds" and "Keys" are
**                pages within a "Commands" page.
**              - DMPrefReq() - Changed AutoCmd column names to "File Data" and "Filename Pattern".
**              - Removed some commented-out code.
**              - dmpAddNewNode(), dmpMoveNode() - The node becomes/remains visible.
**
** 05-12-21 jjt - Removed FirstGads[] and most of the TAB code.  Activating the "Save" gadget
**                seems to have the exact same effect (??!).
**              - Added "Commands" page to the "Commands" page.  Not yet functioning.
**              - Added makeCmdsList().  It doesn't really, but will in the future.
**              - The "Commands" page gadgets are in place.
**              - Removed "layout_main" and "page_main_g1" global vars.  These are now in the
**                PrefGadgets[] array as GID_LAYOUT_MAIN and GID_LAYOUT_SCRN1.
**
** 05-12-22 jjt - dmpDisableLVButtons() - Uses a loop instead of individual SetGadgetAttrs() calls.
**              - dmpDisableLVButtons() - Added Command page gadgets GID_CMD_STATE, GID_CMDFGPAL,
**                 and GID_CMD_BGPAL.
**              - Added Pal2BtnFG map, and connected the Command page palettes to the sample text.
**              - Added dmpCmdLV2Pal() and dmpCmdPal2LV() - Support functions for the
**                "Commands" page Cmd Color gadgets.
**              - Bugfix: Accidentally reassigned the "clicktab" var to the Commands page tabs.
**
** 05-12-23 jjt - Bugfix: makeMenusList() - BARLABEL items weren't created.
**              - Bugfix: makeMenusList() - Changed "key" to a UBYTE arrray.
**              - Bugfix: dmpAddNewNode() - Had a semicolon at the end of an if().
**              - Removed some GCC warnings.
**              - dmpAddNewNode() - The newly added node is put in Edit mode.
**              - Added makeKludgeNode() - Creates and adds a hidden node to a list.
**              - make...List() - Calls makeKludgeNode().
**              - dmpMoveNode() - Will not move the selected node above the hidden kludge node.
**              - Bugfix: Corrected a pointer to 0 in DMPSetPrefs_Menus().
**              - dmpAddNewNode() - The Command column is initialized as "<?>".
**              - Added dmpLVEditNext() - Activates the next column in edit-mode.
**                Commented-out; not working as it should.
**
** 05-12-29 jjt - Bugfix: makeListView() - Using "gid+<x>" instead of "gid++".
**
** 06-01-01 jjt - makeCmdsList() - Works; no longer just a place holder.
**              - Command window cycle gadget (GID_CMD_WINS) works.
**              - initHelpStrings() - Added entries for the Command window gadgets.
**
** 06-01-02 jjt - makeCmdsList() - Tweaked GID_CMD_WINS's text.
**
** 06-01-03 jjt - makeCmdsList() - Tweaked GID_CMD_WINS's text some more.
**              - Added DMPSetPrefs_Cmds() - Applies new AddCmds.
**              - Removed some commented-out code.
**
** 06-01-04 jjt - Bugfix: dmpAddNewNode() - Had an actual gadget ID instead of <gid> when getting
**                the listview's list.
**              - Bugfix: DMPSetPrefs_Cmds() - "#" entries were used/saved with color info.
**              - DMPSetPrefs_Cmds() - Fixed some GCC warnings.
**              - Bugfix: makeCmdsList() - Won't crash when there are no command windows.
**
** 06-01-19 jjt - Added HideDev.
**              - Added makeHideDevList(), DMPSetPrefs_HdieDev().
**              - dmp...Node() - Added support for the HideDev list.
**              - Uncommented dmpLVEditNext().
**
** 06-01-20 jjt - Bugfix: DMPHandleInput() - GID_..._LIST - Adjusting a column
**                separator would enable the Remove and Move buttons.
**
** 06-01-21 jjt - Added Pens section to the Colors page.
**              - initHelpStrings() - Also inits the Pen names array.
**              - Added makePensList(), dmpSetPenColor(), dmpPenNode2Pal(), and
**                DMPSetPrefs_Pens().
**              - Bugfix: Changing the RGB sliders (SetEditColor()) triggered the
**                IDCMP hook, which then set ChangedPalette to true.  Added a kludge to
**                stop it.
**
** 06-01-22 jjt - makePensList() - Pens pens aren't listed if DM is using a public screen.
**              - DMPSetPreferences() - Changed pens cause windows to be refreshed.
**
** 06-12-05 rri - Removed the GETFONT_FixedWidthOnly, TRUE, from the font options.
**
** b2
**
** 06-12-10 rri - Conditionally removed the drag_delay option from the OS4 build
**                as it is obsolete with the Reaction-GUI.
**
** b3
**
** 06-12-14 rri - Added getfont-entry for DMFONTS_CMDWIN.
**
** b7
**
** 06-12-26 rri - Added getfont-entry for DMFONTS_READER.
**
** 06-12-28 rri - Removed loop to fill DMTextAttrs[], DMOpenFont() updates it now.
**
** b8
**
** 07-01-04 rri - Localisation, did not comment-tag everything so all these "msgPrefs*"
**                entities are added in 2.7b8 unless otherwise tagged...
**              - Conditionally removed the second color option for the cmd-window commands
**                from the OS4 build.
**              - Made the window a bit higher overall by adding "LISTBROWSER_MinVisible, 4,"
**              - Fix: Selecting an entry from the list of pens resulted in garbage
**                     beeing displayed in the statusbar.
** b9
**
** 07-01-10 rri - Fix: Instead of "Commands" a title of the auto-commands liser was
**                     labeled "Title". Thanks for Javier de las Rivas for the report!
**
** 07-01-20 rri - Fix: The palette-gadget for the background-color was falsely indicating
**                     the same entry as the palette-gadget for the foreground-color.
**              - Added simple mouse-wheel support.
**
** b10
**
** 07-01-28 rri - Code-fix for 68k in DMPHandleIDCMP() - SAS-C does not know "UNUSED".
**
*/


#include "DM.h"


/* --- Constants --- */
enum  /* Prefs Req. Gadget IDs */
{
  GID_UNDEFINED=0,      /* These do not affect the "changed" status */
  GID_CANCEL,
  GID_USE,
  GID_SAVE,
  GID_HELP,

  GID_LAYOUT_MAIN,
  GID_LAYOUT_SCRN1,

  GID_CLICKTAB_MAIN, /* 2.7b9 rri */
  GID_CLICKTAB_COMMANDS, /* 2.7b9 rri */

  GID_PALETTE,
  GID_COLORBOX,
  GID_COLORBOXIDX,
/*   GID_PENS_PICK, */

  GID_CMD_WINS,
#ifndef __amigaos4__
  GID_CMD_STATE,
  GID_CMD_SAMPLE,
#endif

  GID_USESCREENTYPE,    /* These affect the "Changed" status */
  GID_SCREEN,
  GID_BARFORMAT,
  GID_SETX_WINSCALE,
  GID_SETX_APPICON,
  GID_SETX_ICONX,
  GID_SETX_ICONY,
  GID_SETX_DIGITS,
  GID_SETX_GUIDE,
  GID_SETX_REQHIDEHELP,

  GID_TITLEFORMAT,
  GID_SETFORMAT,
  GID_SETX_TIMEPLUS,
  GID_SETX_SIZES,
  GID_SETX_SEPARATOR,
  GID_SORT_BY,
  GID_SORT_REV,
  GID_SORT_GLOBAL,
  GID_BUTTON,
  GID_SETX_DRAGDELAY,
  GID_SETX_WHEELMULT,
  GID_HDEV_LIST,
  GID_HDEV_ADD,
  GID_HDEV_REM,
  GID_HDEV_UP,
  GID_HDEV_DOWN,

  /* this has to be the same order as in DM.h! */
  GID_FONT_DIRWIN,
  GID_FONT_DIRGAD,
  GID_FONT_REQTXT,
  GID_FONT_REQBTN,
  GID_FONT_MENU,
  GID_FONT_CMDWIN, /* 2.7 rri */
  GID_FONT_READER, /* 2.7 rri */
  GID_FONT_SCREEN,

  GID_SETX_UCLRSLD,
  GID_SETX_UCLRINT,
  GID_PALETTE_COPY,
  GID_PALETTE_SWAP,
  GID_PALETTE_RESET,
  GID_PALETTE_RESETALL,
  GID_REDSLIDER,
  GID_GRNSLIDER,
  GID_BLUSLIDER,
  GID_REDINTVAL,
  GID_GRNINTVAL,
  GID_BLUINTVAL,
  GID_PENS_LIST,

  GID_KEY_LIST,
  GID_KEY_ADD,
  GID_KEY_REM,
  GID_KEY_UP,
  GID_KEY_DOWN,
  GID_AUTO_LIST,
  GID_AUTO_ADD,
  GID_AUTO_REM,
  GID_AUTO_UP,
  GID_AUTO_DOWN,
  GID_MENU_LIST,
  GID_MENU_ADD,
  GID_MENU_REM,
  GID_MENU_UP,
  GID_MENU_DOWN,
  GID_CMD_LIST,
  GID_CMD_ADD,
  GID_CMD_REM,
  GID_CMD_UP,
  GID_CMD_DOWN,
  GID_CMD_FGPAL,
  GID_CMD_BGPAL,

/*
  GID_,
*/

  GAD_TOTAL
};
#define PREFGAD_START  GID_USESCREENTYPE  /* Gadgets that map to DM options */
#define DMP_MAXCMDWINS  25


/* --- Structure Definitions --- */
struct helpdata
{
  STRPTR text;
  STRPTR node;
};


/* --- Function Prototypes --- */
uint32 DMPHandleInput(Object *winobj);
BOOL   DMPSetPreferences(uint32 exitopt, BOOL *resetdm);
void   DMPSetPrefs_KeyCmds(void);  /* 2.7 jjt */
void   DMPSetPrefs_AutoCmds(void); /* 2.7 jjt */
void   DMPSetPrefs_Menus(void);    /* 2.7 jjt */
void   DMPSetPrefs_Cmds(void);     /* 2.7 jjt */
void   DMPSetPrefs_HideDev(void);  /* 2.7 jjt */
BOOL   DMPSetPrefs_Pens(void);     /* 2.7 jjt */
void   initHelpStrings(void);
struct Gadget * buildHostScreenGad(void);
struct Gadget * buildNewScreenGad(void);
void   makePaletteInterconnect(Object *model);
void   makeRgbSliderInterconnect(Object *modelarray[]);
void   setEditColor(struct Window *win);
void   putEditColor(struct Window *win);
void   CopySwapColor(struct Window *win, uint32 c1, uint32 c2, BOOL swap);
void   ResetColor(struct Window *win, BOOL resetall);
void SAVEDS ASM DMPHandleIDCMP(REG(a0, struct Hook *hk), REG(a2, Object *winobj), REG(a1, struct IntuiMessage *imsg));
void   makeKludgeNode(struct List *list, uint32 cols);  /* 2.7 jjt */
void   makeKeyCmdsList(struct List *list);  /* 2.7 jjt */
void   makeAutoCmdsList(struct List *list); /* 2.7 jjt */
void   makeMenusList(struct List *list);    /* 2.7 jjt */
void   makeCmdsList(void);                  /* 2.7 jjt */
void   makeHideDevList(struct List *list);  /* 2.7 jjt */
void   makePensList(struct List *list);     /* 2.7 jjt */
Object * makeListView(uint32 gid);  /* 2.7 jjt */
void   dmpDisableLVButtons(struct Window *win, uint32 lvgid, BOOL disable); /* 2.7 jjt */
void   dmpLVEditNext(struct Window *win, uint32 gid); /* 2.7 jjt */
void   dmpAddNewNode(uint32 gid, struct Window *win); /* 2.7 jjt */
void   dmpRemoveNode(uint32 gid, struct Window *win); /* 2.7 jjt */
void   dmpMoveNode(uint32 btnid, struct Window *win); /* 2.7 jjt */
void   dmpCmdLV2Pal(struct Window *win);  /* 2.7 jjt */
void   dmpCmdPal2LV(struct Window *win);  /* 2.7 jjt */
void   dmpSetPenColor(struct Window *win, uint32 pen);  /* 2.7 jjt */
void   dmpPenNode2Pal(struct Window *win);  /* 2.7 jjt */


/* --- Global Variables --- */
extern BOOL              Req_ShowHelpBtn;
extern UBYTE             *ActionArgs[], TitleFormat[], DispFormat[], BarFormat[],
                         *AppIconPath, FontKeywords[][15], PGadStr[],
                         *KeyCmdStr[], *AutoCmdStr[], /* 2.7 jjt */
                         *DevHide_List[]; /* 2.7 jjt */
extern UWORD             Screen_Depth, Pens20[];
extern LONG              sizes, separator, digits, IconX, IconY,
                         BackPen, DirPen, FilePen, SelectPen;
extern ULONG             FLAGS, Screen_ID, Screen_Width, Screen_Height,
                         UserColors, DevHide_Count;
extern STRPTR            DiskMaster2Guide;
extern APTR              StringPool;
extern uint32            wheel_multiply, drag_delay;
extern struct DirWindow  *DirWin[], *CDWin;
extern struct Screen     *Screen, *MyScreen;
extern struct TextFont   *DMFonts[];
extern struct TagItem    reqtags_Ok[];
extern struct Menu       *DMMenu; /* 2.7 jjt */
extern struct DirWindow  *DirWin[];

BOOL             DMP_UseHostScreen=TRUE, helpinit=FALSE, Refresh24, ChangedPalette,
                 DMP_Modified[GAD_TOTAL]={FALSE}, DMP_UseWinScale=FALSE,
                 DMP_PensModified=FALSE;
UBYTE            DMP_HostScreen[40]="", tmparg[1024], tmparg2[20];
uint16           DMP_CmdWinIDs[DMP_MAXCMDWINS+1];
uint32           DMP_Screen_ID, DMP_Screen_Width, DMP_Screen_Height, DMP_Screen_Depth,
                 DMP_Screen_FontSz,
                 /* FirstGad[]={GID_USESCREENTYPE, GID_TITLEFORMAT, 0, 0, GID_MENU_LIST, GID_AUTO_LIST, GID_KEY_LIST}, */
                 ColorMax, ColorIdx,
                 DMP_ColorTable32[770], *DMP_RGBTable32,
                 DMP_CmdWinIndex=0, DMP_SetColorKludge=3;

STRPTR           DMP_Screen_Font=NULL,
                 SetXSep[]={".", ",", " ", 0},
                 DMP_CmdWinTitles[DMP_MAXCMDWINS+1],
                 SetXPenNames[]={"BPen", "DPen", "FPen", "SPen", 0},
                 PenNames[50];

struct TextAttr  DMTextAttrs[DMFONTS_SCREEN+1];

struct Gadget    *PrefGadgets[GAD_TOTAL], *clicktab, *statusbar;

struct helpdata  DMP_Help[GAD_TOTAL]; /* 2.6 jjt */

struct List      KeyCmds_l, AutoCmds_l, Menus_l, Cmds_l[DMP_MAXCMDWINS], CmdWins_l,
                 HideDev_l, Pens_l;  /* 2.7 jjt */

/* Attr Mapping  Lists */
                 /* Palette to Integer */
struct TagItem   Pal2IntMap[]={{PALETTE_Colour, INTEGER_Number},
                               {TAG_END, 0}}, /* 2.6 rri - 0 != NULL as NULL is a pointer now */
                 /* Integer to Palette */
                 Int2PalMap[]={{INTEGER_Number, PALETTE_Colour},
                               {TAG_END, 0}},
                 /* Palette to Button BG */
                 Pal2BtnMap[]={{PALETTE_Colour, BUTTON_BackgroundPen},
                               {TAG_END, 0}},
                 /* Integer to Button */
                 Int2BtnMap[]={{INTEGER_Number, BUTTON_BackgroundPen},
                               {TAG_END, 0}},
                 /* Slider to Integer */
                 Sld2IntMap[]={{SLIDER_Level, INTEGER_Number},
                               {TAG_END, 0}},
                 /* Integer to Slider */
                 Int2SldMap[]={{INTEGER_Number, SLIDER_Level},
                               {TAG_END, 0}},
                 /* Palette to Button FG */ /* 2.7 jjt */
                 Pal2BtnFGMap[]={{PALETTE_Colour, BUTTON_TextPen},
                                 {TAG_END, 0}};

/* ListView Column Info */ /* 2.7 jjt */
struct ColumnInfo Keys_ci[]={{10, 0, CIF_DRAGGABLE},
                             {90, 0, CIF_DRAGGABLE},
                             {-1, (STRPTR)~0, -1}},
                  Auto_ci[]={{20, 0, CIF_DRAGGABLE},
                             {20, 0, CIF_DRAGGABLE},
                             {60, 0, CIF_DRAGGABLE},
                             {-1, (STRPTR)~0, -1}},
                  Menu_ci[]={{20, 0, CIF_DRAGGABLE},
                             {20, 0, CIF_DRAGGABLE},
                             { 5, 0, CIF_DRAGGABLE},
                             {55, 0, CIF_DRAGGABLE},
                             {-1, (STRPTR)~0, -1}},
                  Cmds_ci[]={{30, 0, CIF_DRAGGABLE},
                             {70, 0, CIF_DRAGGABLE},
                             {-1, (STRPTR)~0, -1}},
                  HDev_ci[]={{100, 0, CIF_DRAGGABLE},
                             {-1, (STRPTR)~0, -1}},
                  Pens_ci[]={{10, 0, 0},
                             {80, 0, 0},
                             {10, 0, 0},
                             {-1, (STRPTR)~0, -1}};


void DMPrefReq(LONG page)
{
  BOOL                 resetdm=FALSE, nopalette;
  uint32               i, done=FALSE, exitopt, sorttype=0, sortrev=0, gid, v,
                       strtest_gids[]={GID_BARFORMAT, GID_TITLEFORMAT, GID_SETFORMAT,
                                       GID_BUTTON, 0},
                       inttest_gids[]={GID_SETX_ICONX, GID_SETX_ICONY, 0},
                       inttest_init[2];
  STRPTR               tabs[6], timestampfmt[3], sizefmt[4], scrntype[3], setxsep[4],
                       setxdigits[]={"4", "5", "6", "7", "8", "9", 0},
                       setxdrgdly[]={"3", "4", "5", "6", "7", "8", "9", 0},
                       setxwhlmlt[]={"1", "2", "3", "4", "5", 0},
                       sortby[7],
#ifndef __amigaos4__
                       cmdstate[3],
#endif
                       strtest_init[4], sptr,
                       cmdtabs[5];
  struct Window        *win;
  struct Hook          idcmphook;
  struct List          tabsl, timestampfmtl, sizefmtl, scrntypel, setxdigitsl, setxdrgdlyl,
                       setxwhlmltl, sortbyl, setxsepl,
                       cmdtabsl;
#ifndef __amigaos4
  struct List          cmdstatel;
#endif
  Object               *window, *PaletteICM=NULL, *RgbICM[3]={NULL, NULL, NULL};

  Busy(1);

  #ifdef __amigaos4__
    idcmphook.h_Entry = (HOOKFUNC) DMPHandleIDCMP; /* 2.6 rri */
  #else
    idcmphook.h_Entry = (ULONG (* )())DMPHandleIDCMP;
  #endif
  idcmphook.h_SubEntry = NULL;

  /* Fill in TextAttrs for the DMFonts up to and including DMFONTS_SCREEN */
/* 2.7 rri moved update of DMTextAttrs[] over to DMOpenFont()
  for (i=0; i < (DMFONTS_SCREEN+1); i++)
  {
    FontToAttr(DMFonts[i], &(DMTextAttrs[i]));
  }
*/
  initHelpStrings();

  /* Init modified aray */
  for (i=0; i < GAD_TOTAL; i++)
  {
    DMP_Modified[i] = FALSE;
  }

  /* Tab gadget names */
  tabs[0] = (STRPTR) msgPrefsTabMain; //"_Main";
  tabs[1] = (STRPTR) msgPrefsTabWindows; // "_Windows";
  tabs[2] = (STRPTR) msgPrefsTabFonts; // "_Fonts";
  tabs[3] = (STRPTR) msgPrefsTabColors; // "C_olors";
  tabs[4] = (STRPTR) msgPrefsTabCommands; // "Comman_ds";  /* Locale Note:  Share this string with cmdtabs[] */
  tabs[5] = 0;

  /* UseScreenType gadget & defaults */
  scrntype[0] = (STRPTR) msgPrefsMainPublicScreen; // "Public screen";
  scrntype[1] = (STRPTR) msgPrefsMainCustomScreen; // "Custom screen";
  scrntype[2] = 0;

  DMP_Screen_ID = Screen_ID;
  DMP_Screen_Width = Screen_Width;
  DMP_Screen_Height = Screen_Height;
  DMP_Screen_Depth = GetBitMapAttr(Screen->RastPort.BitMap, BMA_DEPTH);
  Refresh24 = DMP_Screen_Depth > 8;

  PrefGadgets[GID_SCREEN] = DMP_UseHostScreen ? buildHostScreenGad() : buildNewScreenGad(); /* 2.6 jjt */

  /* Timestamp format gadget choices */
  timestampfmt[0] = (STRPTR) msgPrefsWindowsTimeA; // "hh:mm";
  timestampfmt[1] = (STRPTR) msgPrefsWindowsTimeB; // "hh:mm:ss:tt";
  timestampfmt[2] = 0;

  /* Size format gadget choices */
  sizefmt[0] = (STRPTR) msgPrefsWindowsSizeA; // "1234567";
  sizefmt[1] = (STRPTR) msgPrefsWindowsSizeB; // "1205 K";
  sizefmt[2] = (STRPTR) msgPrefsWindowsSizeC; // "1,234,567";
  sizefmt[3] = 0;

  /* Sort gadget choices & defaults */
  sortby[0] = (STRPTR) msgPrefsWindowsSortA; // "Name";
  sortby[1] = (STRPTR) msgPrefsWindowsSortB; // "Size";
  sortby[2] = (STRPTR) msgPrefsWindowsSortC; // "Date";
  sortby[3] = (STRPTR) msgPrefsWindowsSortD; // "Comment";
  sortby[4] = (STRPTR) msgPrefsWindowsSortE; // "Extension";
  sortby[5] = (STRPTR) msgPrefsWindowsSortF; // "Name length";
  sortby[6] = 0;

  if (CDWin)
  {
    i = CDWin->Sorting;
    sortrev = i & 1;

    i &= ~1;
    if (i < 11)
    {
      sorttype = i / 2;
    }
  }

  /* Separator gadget choices */
  setxsep[0] = (STRPTR) msgPrefsWindowsSeparatorA; // "dot"; /* 2.6 rri */
  setxsep[1] = (STRPTR) msgPrefsWindowsSeparatorB; // "comma"; /* 2.6 rri */
  setxsep[2] = (STRPTR) msgPrefsWindowsSeparatorC; // "space"; /* 2.6 rri */
  setxsep[3] = 0;

  /* HideDev list init */ /* 2.7 jjt */
  makeHideDevList(&HideDev_l);
  HDev_ci[0].ci_Title = (STRPTR) msgPrefsWindowsHideVol; // "Volume";

  /* Set up color backup */
  ChangedPalette = FALSE;
  ColorMax = 1 << (min(DMP_Screen_Depth, 8));
  /* DMP_ColorTable32[0] - LoadRGB32() info:  total colors (upper 16-bits) | first color index (0).
     DMP_ColorTable32[1 - 3] - Color #0 Red, Green, & Blue (32-bits each).
     DMP_ColorTable32[4 - 6] - Color #1 Red, Green, & Blue (32-bits each).
     ...
     DMP_ColorTable32[766 - 768] - Color #256 Red, Green, & Blue (32-bits each).
     DMP_ColorTable32[769] - 0.

     DMP_RGBTable32 - Points to ColorTable32[1]
  */
  DMP_RGBTable32 = &(DMP_ColorTable32[1]);
  /*  Moved this to after the window is opened.  Otherwise some colors don't match what
      the palette gadget displays.
  GetRGB32(Screen->ViewPort.ColorMap, 0, ColorMax, DMP_RGBTable32);
  */
  DMP_ColorTable32[0] = ColorMax << 16;
  DMP_ColorTable32[ColorMax * 3 + 1] = 0;
  ColorIdx = 0;
  nopalette = (MyScreen == NULL);

  makePensList(&Pens_l);
  /*
  Pens_ci[0].ci_Title = "Pen";
  Pens_ci[1].ci_Title = "Name";
  Pens_ci[2].ci_Title = "Color";
  */

  /* Command Tab gadget names */
  cmdtabs[0] = (STRPTR) msgPrefsTabCommands; // "Comman_ds";  /* Locale Note:  Share this string with tabs[] */
  cmdtabs[1] = (STRPTR) msgPrefsTabMenus; // "Men_us";
  cmdtabs[2] = (STRPTR) msgPrefsTabAutoCnds; // "_AutoCmds";
  cmdtabs[3] = (STRPTR) msgPrefsTabKeys; // "_Keys";
  cmdtabs[4] = 0;

  /* Commands list init */ /* 2.7 jjt */
  makeCmdsList();
  Cmds_ci[0].ci_Title = (STRPTR) msgPrefsCommandsColLabelTitle; // "Title";
  Cmds_ci[1].ci_Title = (STRPTR) msgPrefsCommandsColLabelCommand; // "Command";

  /* obsolete! rri */
#ifndef __amigaos4__
  cmdstate[0] = "Normal";
  cmdstate[1] = "Selected";
  cmdstate[2] = 0;
#endif

  /* Menus list init */ /* 2.7 jjt */
  makeMenusList(&Menus_l);
  Menu_ci[0].ci_Title = (STRPTR) msgPrefsCommandsColLabelMenu; // "Menu Name";
  Menu_ci[1].ci_Title = (STRPTR) msgPrefsCommandsColLabelTitle; // "Title";
  Menu_ci[2].ci_Title = (STRPTR) msgPrefsCommandsColLabelKey; // "Key";
  Menu_ci[3].ci_Title = (STRPTR) msgPrefsCommandsColLabelCommand; // "Command";

  /* AutoCmds list init */ /* 2.7 jjt */
  makeAutoCmdsList(&AutoCmds_l);
  Auto_ci[0].ci_Title = (STRPTR) msgPrefsCommandsColLabelFData; // "File Data";
  Auto_ci[1].ci_Title = (STRPTR) msgPrefsCommandsColLabelFName; // "Filename Pattern";
  Auto_ci[2].ci_Title = (STRPTR) msgPrefsCommandsColLabelCommand; /* 2.7b9 rri */ // "Command";

  /* KeyCmds list init */ /* 2.7 jjt */
  makeKeyCmdsList(&KeyCmds_l);
  Keys_ci[0].ci_Title = (STRPTR) msgPrefsCommandsColLabelKey; // "Key";

  /* ClickTab and Chooser label init */
  makeCALabels(&tabsl, tabs, TRUE);
  makeCALabels(&scrntypel, scrntype, FALSE);
  makeCALabels(&timestampfmtl, timestampfmt, FALSE);
  makeCALabels(&sizefmtl, sizefmt, FALSE);
  makeCALabels(&sortbyl, sortby, FALSE);
  makeCALabels(&setxdigitsl, setxdigits, FALSE);
  makeCALabels(&setxdrgdlyl, setxdrgdly, FALSE);
  makeCALabels(&setxwhlmltl, setxwhlmlt, FALSE);
  makeCALabels(&setxsepl, setxsep, FALSE);
  makeCALabels(&cmdtabsl, cmdtabs, TRUE);
#ifndef __amigaos4__
  makeCALabels(&cmdstatel, cmdstate, FALSE);
#endif

  /* StringTest values - Initial values that string contents will be comparred to */
  strtest_init[0] = BarFormat;
  strtest_init[1] = TitleFormat;
  strtest_init[2] = DispFormat;
  strtest_init[3] = PGadStr;

  /* IntegerTest values - Initial values that integer contents will be comparred to */
  inttest_init[0] = IconX;
  inttest_init[1] = IconY;
  Keys_ci[1].ci_Title = (STRPTR) msgPrefsCommandsColLabelCommand; // "Command";

  /* --- Create DMPrefs window --- */
  window = WindowObject,
    WINDOW_Position, WPOS_CENTERSCREEN,
    WINDOW_GadgetUserData, WGUD_IGNORE,
    WA_Activate, TRUE,
    WA_Title, msgPrefsTitle, // "DMPrefs",
    WA_DragBar, TRUE,
    WA_DepthGadget, TRUE,
    WA_SizeGadget, TRUE,
    WA_SizeBBottom, TRUE,
    WA_PubScreen,  Screen,
    WA_Width, Screen->Width / 2,
    WA_IDCMP, IDCMP_RAWKEY | IDCMP_VANILLAKEY |
              #ifdef __amigaos4__ /* 2.7b9 rri */
              IDCMP_EXTENDEDMOUSE |
              #endif
              IDCMP_IDCMPUPDATE,
    WINDOW_IDCMPHook, &idcmphook,
    WINDOW_IDCMPHookBits,
              #ifdef __amigaos4__ /* 2.7b9 rri */
              IDCMP_EXTENDEDMOUSE |
              #endif
              IDCMP_IDCMPUPDATE,
    WINDOW_GadgetHelp, TRUE,
    WINDOW_TextAttr, &DMTextAttrs[DMFONTS_REQTXT],
    WINDOW_ParentGroup, PrefGadgets[GID_LAYOUT_MAIN] = VLayoutObject,
      LAYOUT_DeferLayout, TRUE,
      LAYOUT_SpaceInner, TRUE,
      LAYOUT_SpaceOuter, TRUE,

      /* --- Tabbed Pages --- */
      LAYOUT_AddChild, /*clicktab =*/ PrefGadgets[GID_CLICKTAB_MAIN] = ClickTabObject, /* 2.7b9 rri */
        GA_ID, GID_CLICKTAB_MAIN, /* 2.7b9 rri */
        /* GA_Text, tabs, */
        CLICKTAB_Labels, &tabsl,
        CLICKTAB_PageGroup, PageObject,
          LAYOUT_DeferLayout, TRUE,

          /* --- Main Options Page --- */
          PAGE_Add, VLayoutObject,
            LAYOUT_SpaceOuter, TRUE,

            LAYOUT_AddChild, VLayoutObject,
              LAYOUT_BevelStyle, BVS_GROUP,
              LAYOUT_LabelPlace, BVJ_TOP_LEFT,
              LAYOUT_Label, msgPrefsMainLabelScreen, // "Screen",
              LAYOUT_SpaceOuter, TRUE,

              LAYOUT_AddChild, PrefGadgets[GID_LAYOUT_SCRN1] = HLayoutObject,
                LAYOUT_BottomSpacing, 2,

                LAYOUT_AddChild, PrefGadgets[GID_USESCREENTYPE] = ChooserObject,  /* Toggle HostScreen/NewScreen */
                  GA_ID, GID_USESCREENTYPE,
                  GA_RelVerify, TRUE,
                  /* CHOOSER_LabelArray, scrntype, */
                  CHOOSER_Labels, &scrntypel,
                  CHOOSER_Selected, DMP_UseHostScreen ? 0 : 1,
                  GA_TabCycle, TRUE,
                ChooserEnd,
                CHILD_WeightedWidth, 0,

              LAYOUT_AddChild, PrefGadgets[GID_SCREEN],  /* HostScreen or NewScreen */
              LayoutEnd,

              LAYOUT_AddChild, PrefGadgets[GID_BARFORMAT] = StringObject,  /* BarFormat */
                GA_ID, GID_BARFORMAT,
                GA_RelVerify, TRUE,
                STRINGA_TextVal, BarFormat,
                STRINGA_MaxChars, 192,
                GA_TabCycle, TRUE,
              StringEnd,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsMainLabelTitle, // "Title format:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_WINSCALE] = CheckBoxObject,  /* Use SetX DEFX & DEFY */
                GA_ID, GID_SETX_WINSCALE,
                GA_RelVerify, TRUE,
                GA_Text, msgPrefsMainLabelScale, // "Scale windows to fit screen?", /* 2.6 jjt */
                GA_Selected, DMP_UseWinScale,
                GA_TabCycle, TRUE,
              CheckBoxEnd,

            LayoutEnd, /* VLayout - Screen */
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild, VLayoutObject,
              LAYOUT_BevelStyle, BVS_GROUP,
              LAYOUT_LabelPlace, BVJ_TOP_LEFT,
              LAYOUT_Label, msgPrefsMainLabelAppIcon, // "AppIcon",
              LAYOUT_SpaceOuter, TRUE,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_APPICON] = GetFileObject,  /* SetX APPICON */
                GA_ID, GID_SETX_APPICON,
                GA_RelVerify, TRUE,
                GETFILE_ReadOnly, FALSE,
                GETFILE_FullFileExpand, TRUE,
                GETFILE_DoPatterns, TRUE,
                GETFILE_RejectIcons, FALSE,
                GETFILE_File, AppIconPath,
                GA_TabCycle, TRUE,
              End,

              LAYOUT_AddChild, HLayoutObject,
                LAYOUT_AddChild, PrefGadgets[GID_SETX_ICONX] = IntegerObject,  /* SetX IconX */
                  GA_ID, GID_SETX_ICONX,
                  GA_RelVerify, TRUE,
                  INTEGER_MaxChars, 6,
                  INTEGER_Minimum, -1,
                  INTEGER_Maximum, 65535,
                  INTEGER_Number, (ULONG) IconX == NO_ICON_POSITION ? -1 : IconX,
                  INTEGER_Arrows, FALSE,
                  GA_TabCycle, TRUE,
                IntegerEnd,
                CHILD_WeightedWidth, 0,
                CHILD_Label, LabelObject,
                  LABEL_Text, "x:",
                LabelEnd,

                LAYOUT_AddChild, PrefGadgets[GID_SETX_ICONY] = IntegerObject,  /* SetX IconY */
                  GA_ID, GID_SETX_ICONY,
                  GA_RelVerify, TRUE,
                  INTEGER_MaxChars, 6,
                  INTEGER_Minimum, -1,
                  INTEGER_Maximum, 65535,
                  INTEGER_Number, (ULONG) IconY == NO_ICON_POSITION ? -1 : IconY,
                  INTEGER_Arrows, FALSE,
                  GA_TabCycle, TRUE,
                IntegerEnd,
                CHILD_WeightedWidth, 0,
                CHILD_Label, LabelObject,
                  LABEL_Text, "y:",
                LabelEnd,

              LayoutEnd,  /* AppIcon X & Y H-group */
              CHILD_WeightedWidth, 0,

            LayoutEnd,  /* AppIcon V-Group */
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild, VLayoutObject,  /* other opts V-Group */
              LAYOUT_BevelStyle, BVS_GROUP,
              LAYOUT_SpaceOuter, TRUE,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_DIGITS] = ChooserObject,  /* SetX DIGITS */
                GA_ID, GID_SETX_DIGITS,
                GA_RelVerify, TRUE,
                /* CHOOSER_LabelArray, setxdigits, */
                CHOOSER_Labels, &setxdigitsl,
                CHOOSER_Selected, digits - 4,
                GA_TabCycle, TRUE,
              ChooserEnd,
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsMainLabelDigits, // "Digits:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_GUIDE] = GetFileObject,  /* SetX GUIDE */
                GA_ID, GID_SETX_GUIDE,
                GA_RelVerify, TRUE,
                GETFILE_ReadOnly, FALSE,
                GETFILE_FullFileExpand, TRUE,
                GETFILE_DoPatterns, TRUE,
                GETFILE_File, DiskMaster2Guide,
                GA_TabCycle, TRUE,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsMainLabelGuide, // "Guide:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_REQHIDEHELP] = CheckBoxObject,  /* SetX REQHIDEHELP */
                GA_ID, GID_SETX_REQHIDEHELP,
                GA_RelVerify, TRUE,
                GA_Text, msgPrefsMainLabelHelp, // "Help button in requesters?",
                GA_Selected, Req_ShowHelpBtn,
                GA_TabCycle, TRUE,
              CheckBoxEnd,

            LayoutEnd,  /* other V-Group */
            CHILD_WeightedHeight, 0,

          LayoutEnd, /* Main Page */

          /* --- Window Options Page --- */
          PAGE_Add, VLayoutObject,
            LAYOUT_AddChild, VLayoutObject,
              LAYOUT_SpaceOuter, TRUE,

              LAYOUT_AddChild, PrefGadgets[GID_TITLEFORMAT] = StringObject,  /* TitleFormat */
                GA_ID, GID_TITLEFORMAT,
                GA_RelVerify, TRUE,
                STRINGA_TextVal, TitleFormat,
/*                STRINGA_TextVal, "One very long string, indeed.  Too long, perhaps, but we shall soon see, in a mere matter of minutes.", */
                STRINGA_MaxChars, 50,
                GA_TabCycle, TRUE,
              StringEnd,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsMainLabelTitle, // "Title format:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_SETFORMAT] = StringObject,  /* SetFormat */
                GA_ID, GID_SETFORMAT,
                GA_RelVerify, TRUE,
                STRINGA_TextVal, DispFormat,
                STRINGA_MaxChars, 20,
                GA_TabCycle, TRUE,
              StringEnd,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelDisplay, // "Display format:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_BUTTON] = StringObject,  /* Button */
                GA_ID, GID_BUTTON,
                GA_RelVerify, TRUE,
                STRINGA_TextVal, PGadStr,
                STRINGA_MaxChars, 250,
                GA_TabCycle, TRUE,
              StringEnd,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelButton, // "Button:",
              LabelEnd,

              LAYOUT_AddChild, HLayoutObject,
                LAYOUT_VertAlignment, LALIGN_CENTER,
                LAYOUT_AddChild, PrefGadgets[GID_SORT_BY] = ChooserObject,  /* Sort */
                  GA_ID, GID_SORT_BY,
                  GA_RelVerify, TRUE,
                  /* CHOOSER_LabelArray, sortby, */
                  CHOOSER_Labels, &sortbyl,
                  CHOOSER_Selected, sorttype,
                  GA_TabCycle, TRUE,
                ChooserEnd,

                LAYOUT_AddChild, PrefGadgets[GID_SORT_REV] = CheckBoxObject,  /* Sort reverse */
                  GA_ID, GID_SORT_REV,
                  GA_RelVerify, TRUE,
                  GA_Text, msgPrefsWindowsLabelReverse, // "Reverse",
                  GA_Selected, sortrev,
                  GA_TabCycle, TRUE,
                CheckBoxEnd,

                LAYOUT_AddChild, PrefGadgets[GID_SORT_GLOBAL] = CheckBoxObject,  /* Sort global */
                  GA_ID, GID_SORT_GLOBAL,
                  GA_RelVerify, TRUE,
                  GA_Text, msgPrefsWindowsLabelGlobal, // "Global",
                  GA_Selected, TRUE,
                  GA_TabCycle, TRUE,
                CheckBoxEnd,

              LayoutEnd,  /* Sort - HGroup */
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelSort, // "Sort by:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_TIMEPLUS] = ChooserObject,  /* SetX TimePlus */
                GA_ID, GID_SETX_TIMEPLUS,
                GA_RelVerify, TRUE,
                /* CHOOSER_LabelArray, timestampfmt, */
                CHOOSER_Labels, &timestampfmtl,
                CHOOSER_Selected, FLAGS & DMFLAG_TIMEPLUS ? 1 : 0,
                GA_TabCycle, TRUE,
              ChooserEnd,
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelTimestamp, // "Timestamp:",
              LabelEnd,

              LAYOUT_AddChild, HLayoutObject,
                LAYOUT_AddChild, PrefGadgets[GID_SETX_SIZES] = ChooserObject,  /* SetX Sizes */
                  GA_ID, GID_SETX_SIZES,
                  GA_RelVerify, TRUE,
                  /* CHOOSER_LabelArray, sizefmt, */
                  CHOOSER_Labels, &sizefmtl,
                  CHOOSER_Selected, sizes-1,
                  GA_TabCycle, TRUE,
                ChooserEnd,
                CHILD_WeightedWidth, 0,

                LAYOUT_AddChild, PrefGadgets[GID_SETX_SEPARATOR] = ChooserObject,  /* SetX Separator */
                  GA_ID, GID_SETX_SEPARATOR,
                  GA_RelVerify, TRUE,
                  /* CHOOSER_LabelArray, SetXSep, */
                  CHOOSER_Labels, &setxsepl,
                  CHOOSER_Selected, separator == ',' ? 1 : separator == ' ' ? 2 : 0,
                  GA_TabCycle, TRUE,
                ChooserEnd,
                CHILD_Label, LabelObject,
                  LABEL_Text, msgPrefsWindowsLabelSeparator, // "Separator:",
                LabelEnd,
                CHILD_WeightedWidth, 0,

              LayoutEnd,  /* Sizes - HGroup */
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelSizes, // "Size style:",
              LabelEnd,

#ifndef __amigaos4__
              LAYOUT_AddChild, PrefGadgets[GID_SETX_DRAGDELAY] = ChooserObject,  /* SetX DRAGDELAY */
                GA_ID, GID_SETX_DRAGDELAY,
                GA_RelVerify, TRUE,
                /* CHOOSER_LabelArray, setxdrgdly, */
                CHOOSER_Labels, &setxdrgdlyl,
                CHOOSER_Selected, (drag_delay / 1000) - 3,
                GA_TabCycle, TRUE,
              ChooserEnd,
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, "Drag delay:", /* not localised, still unclear if needed again... */
              LabelEnd,
#endif
              LAYOUT_AddChild, PrefGadgets[GID_SETX_WHEELMULT] = ChooserObject,  /* SetX WHEELMULT */
                GA_ID, GID_SETX_WHEELMULT,
                GA_RelVerify, TRUE,
                /* CHOOSER_LabelArray, setxwhlmlt, */
                CHOOSER_Labels, &setxwhlmltl,
                CHOOSER_Selected, wheel_multiply - 1,
                GA_TabCycle, TRUE,
              ChooserEnd,
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelMultiplier, // "Wheel multiplier:",
              LabelEnd,

              LAYOUT_AddChild, makeListView(GID_HDEV_LIST), /* HideDev */ /* 2.7 jjt */
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsWindowsLabelHide, // "HideDev:",
              LabelEnd,

            LayoutEnd,  /* VLayout page */
          LayoutEnd,  /* Window Page */

          /* --- Font Options Page --- */
          PAGE_Add, VLayoutObject,
            LAYOUT_AddChild, VLayoutObject,
              LAYOUT_SpaceOuter, TRUE,

              LAYOUT_AddChild, PrefGadgets[GID_FONT_SCREEN] = GetFontObject,  /* NewScreen F(ont) */
                GA_ID, GID_FONT_SCREEN,
                GA_RelVerify, TRUE,
                GA_Disabled, DMP_UseHostScreen,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_SCREEN]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelScreen, // "_Screen:", /* 2.7 rri */
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_FONT_DIRWIN] = GetFontObject,  /* Font DIRWIN */
                GA_ID, GID_FONT_DIRWIN,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_MAIN]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelDirEntries, // "Directory _entries:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_FONT_DIRGAD] = GetFontObject,  /* Font DIRGAD */
                GA_ID, GID_FONT_DIRGAD,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_DIRGAD]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelPaths, // "Directory _paths:",
              LabelEnd,

              /* 2.7 rri */
              LAYOUT_AddChild, PrefGadgets[GID_FONT_CMDWIN] = GetFontObject,  /* Font CMDWIN */
                GA_ID, GID_FONT_CMDWIN,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_CMDWIN]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelCommands, // "_CMD-window entries:",
              LabelEnd,

              /* 2.7 rri */
              LAYOUT_AddChild, PrefGadgets[GID_FONT_READER] = GetFontObject,  /* Font READER */
                GA_ID, GID_FONT_READER,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_READER]),
                GETFONT_MaxHeight, 100,
                GETFONT_FixedWidthOnly, TRUE,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelReader, // "_Reader:",
              LabelEnd,


              LAYOUT_AddChild, PrefGadgets[GID_FONT_MENU] = GetFontObject,  /* Font MENU */
                GA_ID, GID_FONT_MENU,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_MENU]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelMenu, // "_Menus:", /* 2.7 rri */
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_FONT_REQTXT] = GetFontObject,  /* Font REQTEXT */
                GA_ID, GID_FONT_REQTXT,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_REQTXT]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelReqText, // "Requester _text:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_FONT_REQBTN] = GetFontObject,  /* Font REQBUTTONS */
                GA_ID, GID_FONT_REQBTN,
                GA_RelVerify, TRUE,
                GETFONT_TextAttr, &(DMTextAttrs[DMFONTS_REQBTN]),
                GETFONT_MaxHeight, 100,
              End,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsFontsLabelReqButtons, // "Requester _buttons:",
              LabelEnd,

            LayoutEnd,  /* VLayout page */
            CHILD_WeightedHeight, 0,
          LayoutEnd,  /* Fonts Page */

          /* --- Color Options Page --- */
          PAGE_Add, VLayoutObject,
            LAYOUT_SpaceOuter, TRUE,

            LAYOUT_AddChild, HLayoutObject,  /* Palette H-group */
              LAYOUT_BevelStyle, BVS_SBAR_VERT,
              LAYOUT_LabelPlace, BVJ_TOP_LEFT,
              LAYOUT_Label, msgPrefsColorsLabelTitle, // "Colors",
              LAYOUT_BottomSpacing, 8,

              LAYOUT_AddChild, PrefGadgets[GID_PALETTE] = PaletteObject,  /* Palette box */
                GA_ID,  GID_PALETTE,
                GA_RelVerify, TRUE,
                PALETTE_NumColours, ColorMax,
              PaletteEnd,

              LAYOUT_AddChild, VLayoutObject,  /* Palette button V-group */

                LAYOUT_AddChild, PrefGadgets[GID_PALETTE_COPY] = ButtonObject,
                  GA_ID, GID_PALETTE_COPY,
                  GA_RelVerify, TRUE,
                  GA_Disabled, nopalette,
                  GA_Text, msgPrefsColorsLabelCopy, // "Copy",
                  BUTTON_PushButton, TRUE,
                ButtonEnd,

                LAYOUT_AddChild,PrefGadgets[GID_PALETTE_SWAP] =  ButtonObject,
                  GA_ID, GID_PALETTE_SWAP,
                  GA_RelVerify, TRUE,
                  GA_Disabled, nopalette,
                  GA_Text, msgPrefsColorsLabelSwap, // "Swap",
                  BUTTON_PushButton, TRUE,
                ButtonEnd,

                LAYOUT_AddChild, ButtonObject,
                  GA_ID, GID_PALETTE_RESET,
                  GA_RelVerify, TRUE,
                  GA_Disabled, nopalette,
                  GA_Text, msgPrefsColorsLabelReset, // "Reset",
                ButtonEnd,

                LAYOUT_AddChild, ButtonObject,
                  GA_ID, GID_PALETTE_RESETALL,
                  GA_RelVerify, TRUE,
                  GA_Disabled, nopalette,
                  GA_Text, msgPrefsColorsLabelResetAll, // "Reset All",
                ButtonEnd,

              LayoutEnd,  /* Palette button V-Group */
              CHILD_WeightedWidth, 0,

            LayoutEnd,  /* Palette H-group */
            CHILD_WeightedHeight, 0,  /* 2.7 jjt */

            LAYOUT_AddChild, HLayoutObject,  /* Color controls H-group */
              LAYOUT_BottomSpacing, 8,

              LAYOUT_AddChild, VLayoutObject,  /* Color-box V-group */
                LAYOUT_SpaceInner, FALSE,

                LAYOUT_AddChild, PrefGadgets[GID_COLORBOX] = ButtonObject,
                  GA_ReadOnly, TRUE,
                ButtonEnd,

                LAYOUT_AddChild, PrefGadgets[GID_COLORBOXIDX] = IntegerObject,
                  GA_ID, GID_COLORBOXIDX,
                  GA_RelVerify, TRUE,
                  INTEGER_Number, 0,
                  INTEGER_MaxChars, 4,
                  INTEGER_Minimum, 0,
                  INTEGER_Maximum, ColorMax - 1,
                IntegerEnd,

              LayoutEnd,  /* Color-box V-group */
              CHILD_WeightedWidth, 0,

              LAYOUT_AddChild, VLayoutObject,  /* Color sliders V-group */
                LAYOUT_LeftSpacing, 2,
                GA_Disabled, nopalette,

                LAYOUT_AddChild, HLayoutObject,  /* Red slider H-group */

                  LAYOUT_SpaceInner, FALSE,
                  LAYOUT_VertAlignment, LALIGN_CENTER,

                  LAYOUT_AddChild, PrefGadgets[GID_REDSLIDER] = SliderObject,
                    GA_ID, GID_REDSLIDER,
                    GA_RelVerify, TRUE,
                    GA_Disabled, nopalette,
                    SLIDER_Min, 0,
                    SLIDER_Max, 255,
                    SLIDER_ShortTicks, TRUE,
                    SLIDER_Ticks, 16,
                    SLIDER_Orientation, SORIENT_HORIZ,
                  SliderEnd,

                  LAYOUT_AddChild, PrefGadgets[GID_REDINTVAL] = IntegerObject,
                    GA_ID, GID_REDINTVAL,
                    GA_RelVerify, TRUE,
                    GA_ReadOnly, nopalette,
                    INTEGER_Arrows, !nopalette,
                    INTEGER_MaxChars, 4,
                    INTEGER_Minimum, 0,
                    INTEGER_Maximum, 255,
                  IntegerEnd,
                  CHILD_WeightedWidth, 0,
                LayoutEnd,  /* Red slider H-group */
                CHILD_Label, LabelObject,
                  LABEL_Text, "R:",
                LabelEnd,

                LAYOUT_AddChild, HLayoutObject,  /* Green slider H-group */
                  LAYOUT_SpaceInner, FALSE,
                  LAYOUT_VertAlignment, LALIGN_CENTER,

                  LAYOUT_AddChild, PrefGadgets[GID_GRNSLIDER] = SliderObject,
                    GA_ID, GID_GRNSLIDER,
                    GA_RelVerify, TRUE,
                    GA_Disabled, nopalette,
                    SLIDER_Min, 0,
                    SLIDER_Max, 255,
                    SLIDER_Ticks, 16,
                    SLIDER_Orientation, SORIENT_HORIZ,
                  SliderEnd,

                  LAYOUT_AddChild, PrefGadgets[GID_GRNINTVAL] = IntegerObject,
                    GA_ID, GID_GRNINTVAL,
                    GA_RelVerify, TRUE,
                    GA_ReadOnly, nopalette,
                    INTEGER_Arrows, !nopalette,
                    INTEGER_MaxChars, 4,
                    INTEGER_Minimum, 0,
                    INTEGER_Maximum, 255,
                  IntegerEnd,
                  CHILD_WeightedWidth, 0,
                LayoutEnd,  /* Green slider H-group */
                CHILD_Label, LabelObject,
                  LABEL_Text, "G:",
                LabelEnd,

                LAYOUT_AddChild, HLayoutObject,  /* Blue slider H-group */
                  LAYOUT_SpaceInner, FALSE,
                  LAYOUT_VertAlignment, LALIGN_CENTER,

                  LAYOUT_AddChild, PrefGadgets[GID_BLUSLIDER] = SliderObject,
                    GA_ID, GID_BLUSLIDER,
                    GA_RelVerify, TRUE,
                    GA_Disabled, nopalette,
                    SLIDER_Min, 0,
                    SLIDER_Max, 255,
                    SLIDER_Ticks, 16,
                    SLIDER_Orientation, SORIENT_HORIZ,
                  SliderEnd,

                  LAYOUT_AddChild, PrefGadgets[GID_BLUINTVAL] = IntegerObject,
                    GA_ID, GID_REDINTVAL,
                    GA_RelVerify, TRUE,
                    GA_ReadOnly, nopalette,
                    INTEGER_Arrows, !nopalette,
                    INTEGER_MaxChars, 4,
                    INTEGER_Minimum, 0,
                    INTEGER_Maximum, 255,
                  IntegerEnd,
                  CHILD_WeightedWidth, 0,
                LayoutEnd,  /* Blue slider H-group */
                CHILD_Label, LabelObject,
                  LABEL_Text, "B:",
                LabelEnd,

              LayoutEnd,  /* Color sliders V-group */

            LayoutEnd,  /* Color controls H-group */
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild, HLayoutObject,  /* SetX UserColors slider H-group */
              LAYOUT_SpaceInner, FALSE,
              LAYOUT_VertAlignment, LALIGN_CENTER,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_UCLRSLD] = SliderObject,
                GA_ID, GID_SETX_UCLRSLD,
                GA_RelVerify, TRUE,
                SLIDER_Min, 4,
                SLIDER_Max, ColorMax,
                SLIDER_Level, UserColors,
                SLIDER_ShortTicks, TRUE,
                SLIDER_Ticks, 16,
                SLIDER_Orientation, SORIENT_HORIZ,
              SliderEnd,
              CHILD_Label, LabelObject,
                LABEL_Text, msgPrefsColorsLabelUserCol, // "User colors:",
              LabelEnd,

              LAYOUT_AddChild, PrefGadgets[GID_SETX_UCLRINT] = IntegerObject,
                GA_ID, GID_SETX_UCLRINT,
                GA_RelVerify, TRUE,
                INTEGER_MaxChars, 4,
                INTEGER_Minimum, 4,
                INTEGER_Maximum, ColorMax,
                INTEGER_Number, UserColors,
                ICA_TARGET, PrefGadgets[GID_SETX_UCLRSLD],
                ICA_MAP, Int2SldMap,
              IntegerEnd,
              CHILD_WeightedWidth, 0,
            LayoutEnd,  /* SetX UserColors slider H-group */
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild, VLayoutObject,  /* Pens V-group */
              LAYOUT_BevelStyle, BVS_SBAR_VERT,
              LAYOUT_LabelPlace, BVJ_TOP_LEFT,
              LAYOUT_Label, msgPrefsColorsLabelPens, // "Pens",

              LAYOUT_AddChild, PrefGadgets[GID_PENS_LIST] = ListBrowserObject,
                GA_ID, GID_PENS_LIST,
                GA_RelVerify, TRUE,
                LISTBROWSER_ShowSelected, TRUE,
                /* LISTBROWSER_AutoFit, TRUE, */
                LISTBROWSER_Labels, (ULONG) &Pens_l,
                LISTBROWSER_ColumnInfo, (ULONG) &Pens_ci[0],
                /* LISTBROWSER_ColumnTitles, TRUE, */
                LISTBROWSER_VertSeparators, FALSE,
                LISTBROWSER_HorizSeparators, TRUE,
                LISTBROWSER_MinVisible, 4, /* 2.7b8 rri */
                GA_TabCycle, TRUE,
              End,
/*
              LAYOUT_AddChild, PrefGadgets[GID_PENS_PICK] = ButtonObject,
                GA_ID, GID_PENS_PICK,
                GA_RelVerify, TRUE,
                GA_Disabled, TRUE,
                GA_Text, "Choose color",
                BUTTON_PushButton, TRUE,
                GA_TabCycle, TRUE,
              ButtonEnd,
              CHILD_WeightedHeight, 0,
*/
            LayoutEnd,  /* Pens V-group */

          LayoutEnd,  /* Colors Page */

          /* --- Commands Page --- */ /* 2.7 jjt*/
          PAGE_Add, VLayoutObject,
            LAYOUT_SpaceOuter, TRUE,

            LAYOUT_AddChild, PrefGadgets[GID_CLICKTAB_COMMANDS] = ClickTabObject, /* 2.7b9 rri */
              GA_ID, GID_CLICKTAB_COMMANDS, /* 2.7b9 rri */
              CLICKTAB_Labels, &cmdtabsl,
              CLICKTAB_PageGroup, PageObject,
                LAYOUT_DeferLayout, TRUE,
                PAGE_Add, VLayoutObject, /* Commands page */ /* 2.7 jjt */
                  LAYOUT_SpaceOuter, TRUE,

                  LAYOUT_AddChild, PrefGadgets[GID_CMD_WINS] = ChooserObject,
                    GA_ID, GID_CMD_WINS,
                    GA_RelVerify, TRUE,
                    CHOOSER_Labels, &CmdWins_l,
                    CHOOSER_MaxLabels, DMP_MAXCMDWINS,
                    GA_TabCycle, TRUE,
                  ChooserEnd,
                  CHILD_WeightedHeight, 0,

                  LAYOUT_AddChild, makeListView(GID_CMD_LIST),

                  LAYOUT_AddChild, HLayoutObject,  /* Cmd Colors H-Group */

#ifndef __amigaos4__ /* 2.7b8 rri - Reaction windows only have one set of colors */
                    LAYOUT_AddChild, VLayoutObject,
                      LAYOUT_AddImage, LabelObject,
                        LABEL_Text, "Title Colors:",
                      LabelEnd,

                      LAYOUT_AddChild, PrefGadgets[GID_CMD_STATE] = ChooserObject,  /* Normal or selected Chooser */
                        GA_ID, GID_CMD_STATE,
                        GA_RelVerify, TRUE,
                        GA_Disabled, TRUE,
                        CHOOSER_Labels, &cmdstatel,
                        GA_TabCycle, TRUE,
                      ChooserEnd,

                      LAYOUT_AddChild, PrefGadgets[GID_CMD_SAMPLE] = ButtonObject,  /* Sample text */
                        GA_ID, GID_CMD_SAMPLE,
                        GA_ReadOnly, TRUE,
                        GA_TextAttr, &(DMTextAttrs[DMFONTS_MAIN]),
                        BUTTON_BevelStyle, BVS_NONE,
                        GA_Text, "Sample Text",
                      ButtonEnd,

                    LayoutEnd, /* V-Group */
                    CHILD_WeightedWidth, 0,
#endif
                    LAYOUT_AddChild, VLayoutObject,
                      LAYOUT_AddImage, LabelObject,
                        LABEL_Text, msgPrefsCommandsLabelForeground, // "Foreground",
                      LabelEnd,

                      LAYOUT_HorizAlignment, LALIGN_CENTER,
                      LAYOUT_AddChild, PrefGadgets[GID_CMD_FGPAL] = PaletteObject,  /* Foreground Palette box */
                        GA_ID,  GID_CMD_FGPAL,
                        GA_RelVerify, TRUE,
                        GA_Disabled, TRUE,
                        PALETTE_NumColours, min(ColorMax, 16),
#ifndef __amigaos4__
                        ICA_TARGET, PrefGadgets[GID_CMD_SAMPLE],
                        ICA_MAP, Pal2BtnFGMap,
#endif
                      PaletteEnd,
                    LayoutEnd, /* V-Group */

                    LAYOUT_AddChild, VLayoutObject,
                      LAYOUT_AddImage, LabelObject,
                        LABEL_Text, msgPrefsCommandsLabelBackground, // "Background",
                      LabelEnd,

                      LAYOUT_HorizAlignment, LALIGN_CENTER,
                      LAYOUT_AddChild, PrefGadgets[GID_CMD_BGPAL] = PaletteObject,  /* Background Palette box */
                        GA_ID,  GID_CMD_BGPAL,
                        GA_RelVerify, TRUE,
                        GA_Disabled, TRUE,
                        PALETTE_NumColours, min(ColorMax, 16),
#ifndef __amigaos4__
                        ICA_TARGET, PrefGadgets[GID_CMD_SAMPLE],
                        ICA_MAP, Pal2BtnMap,
#endif
                      PaletteEnd,
                    LayoutEnd, /* V-Group */

                  LayoutEnd, /* Cmd Color H-Group */
                  /* CHILD_WeightedWidth, 0, */
                  CHILD_WeightedHeight, 0,

                LayoutEnd,  /* Commands page */

                PAGE_Add, makeListView(GID_MENU_LIST), /* Menu page         */ /* 2.7 jjt */
                PAGE_Add, makeListView(GID_AUTO_LIST), /* AutoCommands page */ /* 2.7 jjt */
                PAGE_Add, makeListView(GID_KEY_LIST),  /* Key Commands page */ /* 2.7 jjt */
              PageEnd,
            LayoutEnd,  /* Cmds ClickTab */
          LayoutEnd, /* Cmd V-Group */

        PageEnd,
        CLICKTAB_Current, page,
      LayoutEnd, /* Clicktab end */

      /* --- Status bar --- */
      LAYOUT_AddChild, statusbar = ButtonObject,
        GA_ReadOnly, TRUE,
        BUTTON_Justification, BCJ_LEFT,
      ButtonEnd,
      CHILD_WeightedHeight, 0,

      /* --- Save, Use, & Cancel Buttons --- */
      LAYOUT_AddChild, HLayoutObject,
        LAYOUT_EvenSize, TRUE,
          LAYOUT_AddChild, ButtonObject,
            GA_ID, GID_SAVE,
            GA_RelVerify, TRUE,
            GA_TextAttr, &DMTextAttrs[DMFONTS_REQBTN],
            GA_Text, msgPrefsButtonsSave, // "_Save...",
            GA_TabCycle, TRUE,
          ButtonEnd,
          CHILD_WeightedWidth, 0,

          LAYOUT_AddChild, ButtonObject,
            GA_ID, GID_USE,
            GA_RelVerify, TRUE,
            GA_TextAttr, &DMTextAttrs[DMFONTS_REQBTN],
            GA_Text, msgPrefsButtonsUse, // "_Use",
            GA_TabCycle, TRUE,
          ButtonEnd,
          CHILD_WeightedWidth, 0,

          LAYOUT_AddChild, ButtonObject,
            GA_ID, GID_CANCEL,
            GA_RelVerify, TRUE,
            GA_TextAttr, &DMTextAttrs[DMFONTS_REQBTN],
            GA_Text, msgPrefsButtonsCancel, // "_Cancel",
            GA_TabCycle, TRUE,
          ButtonEnd,
          CHILD_WeightedWidth, 0,
      LayoutEnd,
      CHILD_WeightedHeight, 0,

    LayoutEnd,
  WindowEnd;


  /* --- Handle messages, set preferences --- */
  if (window)
  {
    SetAttrs(PrefGadgets[GID_SETX_UCLRSLD], ICA_TARGET, PrefGadgets[GID_SETX_UCLRINT],
                                            ICA_MAP, Sld2IntMap,
                                            TAG_END);

    if ((win = (struct Window *) RA_OpenWindow(window)))
    {
      /* Backup the palette.
         Doing this before the window is opened results in alternate values for some indexes.
      */
      GetRGB32(Screen->ViewPort.ColorMap, 0, ColorMax, DMP_RGBTable32);

      makePaletteInterconnect(PaletteICM);
      makeRgbSliderInterconnect(RgbICM);
      setEditColor(NULL);  /* Rendering glitch if called when <win> is open but not on the Colors page */

      #ifdef __amigaos4__ /* 2.6 rri */
      RefreshSetGadgetAttrs(PrefGadgets[GID_BARFORMAT], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      RefreshSetGadgetAttrs(PrefGadgets[GID_TITLEFORMAT], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      RefreshSetGadgetAttrs(PrefGadgets[GID_SETFORMAT], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      RefreshSetGadgetAttrs(PrefGadgets[GID_BUTTON], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      #else
      SetGadgetAttrs(PrefGadgets[GID_BARFORMAT], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      SetGadgetAttrs(PrefGadgets[GID_TITLEFORMAT], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      SetGadgetAttrs(PrefGadgets[GID_SETFORMAT], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      SetGadgetAttrs(PrefGadgets[GID_BUTTON], win, NULL, STRINGA_BufferPos, 0, TAG_DONE);
      /* Refreshing gadgets not on the current page causes artifacts in OS 3.x */ /* 2.6 jjt */
      if (page == 0)
      {
        RefreshGList(PrefGadgets[GID_BARFORMAT], win, NULL, 1);
      }
      else if (page == 1)
      {
        RefreshGList(PrefGadgets[GID_TITLEFORMAT], win, NULL, 1);
        RefreshGList(PrefGadgets[GID_SETFORMAT], win, NULL, 1);
        RefreshGList(PrefGadgets[GID_BUTTON], win, NULL, 1);
      }
      #endif

      /* Input Event loop... */
      while (!done)
      {
        exitopt = DMPHandleInput(window);

        /* Test string gadget contents against initial values... */
        i = 0;
        while ((gid = strtest_gids[i])) /* 2.6 rri */
        {
          GetAttr(STRINGA_TextVal, PrefGadgets[gid], (ULONG *)(void *) &sptr);
          DMP_Modified[gid] = (Stricmp(strtest_init[i++], sptr) != 0);
        }

        /* Test integer gadget contents against initial values... */
        i = 0;
        while ((gid = inttest_gids[i])) /* 2.6 rri */
        {
          GetAttr(INTEGER_Number, PrefGadgets[gid], &v);
          DMP_Modified[gid] = v != inttest_init[i++];
        }

        done = DMPSetPreferences(exitopt, &resetdm);
      }
    } /* if OpenWindow() */

    DisposeObject(PaletteICM);
    for (i=0; i<3; i++)
    {
      DisposeObject(RgbICM[i]);
    }
    DisposeObject(window);
  }  /* if (window) */

  /* Free the ClickTab and Chooser labels */
  freeCALabels(&tabsl, TRUE);
  freeCALabels(&scrntypel, FALSE);
  freeCALabels(&timestampfmtl, FALSE);
  freeCALabels(&sizefmtl, FALSE);
  freeCALabels(&sortbyl, FALSE);
  freeCALabels(&setxdigitsl, FALSE);
  freeCALabels(&setxdrgdlyl, FALSE);
  freeCALabels(&setxwhlmltl, FALSE);
  freeCALabels(&setxsepl, FALSE);
  freeCALabels(&cmdtabsl, TRUE);
#ifndef __amigaos4__
  freeCALabels(&cmdstatel, FALSE);
#endif
  freeCALabels(&CmdWins_l, FALSE);  /* 2.7 jjt */

  /* Free the ListBrowser lists */ /* 2.7 jjt */
  FreeListBrowserList(&HideDev_l);
  FreeListBrowserList(&KeyCmds_l);
  FreeListBrowserList(&AutoCmds_l);
  FreeListBrowserList(&Menus_l);

  for(i=0; DMP_CmdWinTitles[i]; i++)
  {
    PoolFreeVec(DMP_CmdWinTitles[i]);
    FreeListBrowserList(&(Cmds_l[i]));
  }

  Busy(0);

  if (resetdm)
  {
    if (RememberDMClose())
    {
      RememberDMOpen();
    }
  }
}


#ifdef __amigaos4__ /* 2.7b10 rri */
void SAVEDS ASM DMPHandleIDCMP(REG(a0, struct Hook *hk UNUSED),
                               REG(a2, Object *winobj),
                               REG(a1, struct IntuiMessage *imsg))
#else
void SAVEDS ASM DMPHandleIDCMP(REG(a0, struct Hook *hk ),
                               REG(a2, Object *winobj),
                               REG(a1, struct IntuiMessage *imsg))
#endif
{
  uint32 gid;
  struct Window *win;
  struct TagItem *taglist; /* , *tag; */

  /* --- IDCMP hook to handle IDCMP_IDCMPUPDATE messages ---
     Update colors in real time based on the RGB sliders.
  */

  #ifndef __amigaos4__ /* 2.7b10 rri */
  if (hk) {}  /* so gcc won't complain <hk> isn't used. */
  #endif

  GetAttr(WINDOW_Window, winobj, (ULONG *)(void*) &win);
  gid = GetTagData(GA_ID, 42, imsg->IAddress);

/* 2.7b9 rri */
#ifdef __amigaos4__
  if ( (imsg->Class == IDCMP_EXTENDEDMOUSE) && (imsg->Code  == IMSGCODE_INTUIWHEELDATA) )
  {
   int32 position = 0;
   uint32 page;
   struct IntuiWheelData *iwd = NULL;

   iwd = (struct IntuiWheelData *)imsg->IAddress;

   GetAttr(CLICKTAB_Current, PrefGadgets[GID_CLICKTAB_MAIN], &page);

   if (page == 1) // windows-page
   {
    gid = GID_HDEV_LIST;
   }
   else if (page == 3) // colors-page
   {
    gid = GID_PENS_LIST;
   }
   else if (page == 4) // commands-page
   {
    GetAttr(CLICKTAB_Current, PrefGadgets[GID_CLICKTAB_COMMANDS], &page);

    switch (page)
    {
     case 0:
            gid = GID_CMD_LIST;
            break;
     case 1:
            gid = GID_MENU_LIST;
            break;
     case 2:
            gid = GID_AUTO_LIST;
            break;
     case 3:
            gid = GID_KEY_LIST;
            break;
    };
   }

   if (iwd)
   {
    if (iwd->WheelY != 0 )
    {
     GetAttr(LISTBROWSER_Top,PrefGadgets[gid], &position);
     if (position < 1)
     {
      position++;
     }
     position += iwd->WheelY * wheel_multiply;
     if (position < 1)
     {
      position = 1;
     }
     SetGadgetAttrs(PrefGadgets[gid], win, NULL,LISTBROWSER_Top,position, TAG_END,0);
    }
   }
  }
#endif

  if (imsg->Class == IDCMP_IDCMPUPDATE)
  {
    taglist = imsg->IAddress;
/*
    // DEBUG - What's in the taglist?
    while((tag = NextTagItem(&taglist)))
    {
      sprintf(tmparg, "%lx - %lx\n%lx, %lx, %lx", tag->ti_Tag, tag->ti_Data, GA_ID, GID_REDSLIDER, SLIDER_Level);
      DMReqTagList(tmparg, 0, 0, 0);
    }
*/

    if (!(FindTagItem(LAYOUT_HelpGadget, taglist)))  /* Ignore Help msgs */
    {
//      GetAttr(WINDOW_Window, winobj, (ULONG *)(void*) &win);

//      gid = GetTagData(GA_ID, 0, taglist);
      switch (gid)
      {
        case GID_REDSLIDER:
        case GID_GRNSLIDER:
        case GID_BLUSLIDER:
          putEditColor(win);
          if (DMP_SetColorKludge)
          {
            DMP_SetColorKludge--;
          }
          else
          {
            ChangedPalette = TRUE;
          }
          break;
      } /* end switch */
    } /* endif - !GadgetHelp */
  } /* endif - IDCMPUPDATE*/
}


uint32 DMPHandleInput(Object *window)
{
  BOOL          done=FALSE, ignoremod=FALSE;
  int16         code;
  uint32        signal, exitopt=0, result, i, gid, chooseropt, palaction=0, helpgid=0;
  STRPTR        sptr;
  struct Window *win;
  struct Gadget *gadptr;


  GetAttr(WINDOW_Window, window, (ULONG *)(void *) &win);
  GetAttr(WINDOW_SigMask, window, &signal); /* Obtain the window wait signal mask */

  while (!done)
  {
    Wait(signal);
    while ((result = RA_HandleInput(window, &code)) != WMHI_LASTMSG)
    {
      switch (result & WMHI_CLASSMASK)
      {
        case WMHI_RAWKEY:
          if ((result & WMHI_KEYMASK) == 0x5F)  /* Help */
          {
            ViewAsync(DiskMaster2Guide, DMP_Help[helpgid].node);
          }
          break;

        case WMHI_VANILLAKEY:
          gid = result & WMHI_KEYMASK;
/*
          if (gid == 27)  // Esc pressed
          {
            done = TRUE;
            exitopt = 0;
          }
          else
*/
          if (gid == 9)  /* Tab pressed */
          {
            ActivateLayoutGadget(PrefGadgets[GID_LAYOUT_MAIN], win, NULL, (Object) &PrefGadgets[GID_SAVE]); /* 2.7 jjt */
/*
            GetAttr(CLICKTAB_Current, clicktab, &chooseropt);
            i = FirstGad[chooseropt];

            if (i)
            {
             ActivateLayoutGadget(layout_main, win, NULL, (Object) &PrefGadgets[i]); // 2.6 rri
            }
*/
          }
          break;

        case WMHI_GADGETUP:
          gid = result & WMHI_GADGETMASK;

          if (code == 0x5F)  /* HELP pressed in a string gadget */
          {
            ViewAsync(DiskMaster2Guide, DMP_Help[gid].node);
          }
          else  /* Normal GadgetUp */
          {
          switch (gid)
            {
/*
sprintf(tmparg, "%ld", gid);
DMReqTagList(tmparg, 0, 0, 0);
*/
              case GID_USESCREENTYPE:  /* Toggle between HostScreen & NewScreen */
                GetAttr(CHOOSER_Selected, PrefGadgets[GID_USESCREENTYPE], &chooseropt);
                gadptr = chooseropt ? buildNewScreenGad() : buildHostScreenGad();

/*                SetGadgetAttrs(page_main_g1, win, NULL, LAYOUT_ModifyChild, PrefGadgets[GID_SCREEN],*/
                SetGadgetAttrs(PrefGadgets[GID_LAYOUT_SCRN1], win, NULL, LAYOUT_ModifyChild, PrefGadgets[GID_SCREEN],
                                                        CHILD_ReplaceObject, gadptr,
                                                        TAG_DONE);
                PrefGadgets[GID_SCREEN] = gadptr;

                if (DoMethod(window, WM_RETHINK) == 0)
                {
                  DoMethod(window, WM_NEWPREFS);
                }

                SetGadgetAttrs(PrefGadgets[GID_FONT_SCREEN], win, NULL, GA_Disabled, (chooseropt == 0), TAG_DONE);
                break;

              case GID_SCREEN:
                gadptr = PrefGadgets[GID_SCREEN];
                GetAttr(CHOOSER_Selected, PrefGadgets[GID_USESCREENTYPE], &chooseropt);

                if (chooseropt)
                {
                  /* NewScreen - Open req. & cache values */
                  RequestScreenMode((Object *) gadptr, win);
                  GetAttr(GETSCREENMODE_DisplayID, gadptr, &DMP_Screen_ID);
                  GetAttr(GETSCREENMODE_DisplayWidth, gadptr, &DMP_Screen_Width);
                  GetAttr(GETSCREENMODE_DisplayHeight, gadptr, &DMP_Screen_Height);
                  GetAttr(GETSCREENMODE_DisplayDepth, gadptr, &DMP_Screen_Depth);
                }
                else
                {
                  /* HostScreen - Cache screen name */
                  GetAttr(STRINGA_TextVal, gadptr, (ULONG *)(void *) &sptr);
                  DMstrncpy(DMP_HostScreen, sptr, 39);
                }
                break;

              case GID_SETX_APPICON:
              case GID_SETX_GUIDE:
                /* SetX APPICON or GUIDE - Open req. */
                DoMethod((Object *) PrefGadgets[gid], GFILE_REQUEST , win);
                break;

              case GID_FONT_SCREEN:
              case GID_FONT_DIRWIN:
              case GID_FONT_DIRGAD:
              case GID_FONT_CMDWIN: /* 2.7 rri */
              case GID_FONT_READER: /* 2.7 rri */
              case GID_FONT_MENU:
              case GID_FONT_REQTXT:
              case GID_FONT_REQBTN:
                DoMethod((Object *) PrefGadgets[gid], GFONT_REQUEST, win);
                break;

              case GID_PALETTE:
              case GID_COLORBOXIDX:
                i = ColorIdx;
                GetAttr(PALETTE_Colour, PrefGadgets[GID_PALETTE], &ColorIdx);
                if (palaction)
                {
/*                  if (palaction == GID_PENS_PICK) */ /* 2.7 jjt */
                  if (palaction == GID_PENS_LIST)  /* 2.7 jjt */
                  {
                    dmpSetPenColor(win, ColorIdx);
                  }
                  else
                  {
                    CopySwapColor(win, i, ColorIdx, palaction == GID_PALETTE_SWAP);
                  }
                }
                setEditColor(win);
/*
              sprintf(tmparg, "%ld", ColorIdx);
              DMReqTagList(tmparg, 0, 0, 0);
*/
                break;

              case GID_PALETTE_COPY:
              case GID_PALETTE_SWAP:
              /*case GID_PENS_PICK:*/    /* 2.7 jjt */

                i = (gid == GID_PALETTE_COPY) ? GID_PALETTE_SWAP : GID_PALETTE_COPY;
                SetGadgetAttrs(PrefGadgets[i], win, NULL, GA_Selected, FALSE, TAG_DONE);
                SetGadgetAttrs(PrefGadgets[GID_PENS_LIST], win, NULL, LISTBROWSER_Selected, -1, TAG_DONE);

/*
                if (gid != GID_PALETTE_COPY)
                {
                  SetGadgetAttrs(PrefGadgets[GID_PALETTE_COPY], win, NULL, GA_Selected, FALSE, TAG_DONE);
                }
                if (gid != GID_PALETTE_SWAP)
                {
                  SetGadgetAttrs(PrefGadgets[GID_PALETTE_SWAP], win, NULL, GA_Selected, FALSE, TAG_DONE);
                }
                if (gid != GID_PENS_PICK)
                {
                  SetGadgetAttrs(PrefGadgets[GID_PENS_PICK], win, NULL, GA_Selected, FALSE, TAG_DONE);
                }
*/
                palaction = 0x80000000 | gid;
                break;

              case GID_PALETTE_RESET:
                ResetColor(win, FALSE);
                break;

              case GID_PALETTE_RESETALL:
                ResetColor(win, TRUE);
                ChangedPalette = FALSE;
                break;

              case GID_PENS_LIST:
/*                 SetGadgetAttrs(PrefGadgets[GID_PENS_PICK], win, NULL, GA_Disabled, FALSE, TAG_DONE); */
                dmpPenNode2Pal(win);
                palaction = 0x80000000 | gid;
                ignoremod = TRUE;
                break;

              case GID_CMD_WINS:  /* 2.7 jjt */
                GetAttr(CHOOSER_Selected, PrefGadgets[gid], &DMP_CmdWinIndex);
                SetGadgetAttrs(PrefGadgets[GID_CMD_LIST], win, NULL, LISTBROWSER_Selected, -1,
                                                                     LISTBROWSER_Labels, (ULONG) &Cmds_l[DMP_CmdWinIndex],
                                                                     TAG_DONE);
                dmpDisableLVButtons(win, GID_CMD_LIST, TRUE);
                break;

              case GID_KEY_LIST:  /* 2.7 jjt */
              case GID_AUTO_LIST:
              case GID_MENU_LIST:
              case GID_CMD_LIST:
              case GID_HDEV_LIST:
                GetAttr(LISTBROWSER_RelEvent, PrefGadgets[gid], &chooseropt);
                if (chooseropt == LBRE_NORMAL)  /* 2.7 jjt */
                {
                  dmpDisableLVButtons(win, gid, FALSE); /* 2.7 jjt */

                  if (gid == GID_CMD_LIST)
                  {
                    dmpCmdLV2Pal(win);
                  }
                }

                if (chooseropt == LBRE_EDIT)
                {
                  dmpLVEditNext(win, gid);
                }
                else
                {
                  ignoremod = TRUE;
                }

                break;

              case GID_KEY_ADD:  /* 2.7 jjt */
              case GID_AUTO_ADD:
              case GID_MENU_ADD:
              case GID_CMD_ADD:
              case GID_HDEV_ADD:
                dmpAddNewNode(gid, win);

                dmpDisableLVButtons(win, gid-1, FALSE);  /* 2.7 jjt */

                if (gid == GID_CMD_ADD)
                {
                  dmpCmdLV2Pal(win);
                }

                break;

              case GID_KEY_REM:  /* 2.7 jjt */
              case GID_AUTO_REM:
              case GID_MENU_REM:
              case GID_CMD_REM:
              case GID_HDEV_REM:
                dmpRemoveNode(gid, win);
                dmpDisableLVButtons(win, gid-2, TRUE);  /* 2.7 jjt */
                break;

              case GID_KEY_UP:    /* 2.7 jjt */
              case GID_KEY_DOWN:
              case GID_AUTO_UP:
              case GID_AUTO_DOWN:
              case GID_MENU_UP:
              case GID_MENU_DOWN:
              case GID_CMD_UP:
              case GID_CMD_DOWN:
              case GID_HDEV_UP:
              case GID_HDEV_DOWN:
                dmpMoveNode(gid, win);
                break;

#ifndef __amigaos4__
              case GID_CMD_STATE:  /* 2.7 jjt */
                dmpCmdLV2Pal(win);
                break;
#endif

              case GID_CMD_FGPAL:  /* 2.7 jjt*/
              case GID_CMD_BGPAL:
                dmpCmdPal2LV(win);
                DMP_Modified[GID_CMD_LIST] = TRUE;
                break;

            }  /* end switch (gid) */

            /* --- Set modified --- */
            if (gid) {
              if (gid >= PREFGAD_START)
              {
                if (ignoremod)  /* 2.7 jjt */
                {
                  ignoremod = FALSE;
                }
                else
                {
                  /* User changed a prefs gadget */
                  DMP_Modified[gid] = TRUE;

                  /* Undefined, and Save, Use, & Cancel buttons (global mod. flag(s)) */
                  for (i=0; i < PREFGAD_START; i++)
                  {
                    DMP_Modified[i] = TRUE;
                  }

                  /* If GID_CMD_LIST was modified, mark which list was modified. */
                  if (DMP_Modified[GID_CMD_LIST])
                  {
                    DMP_CmdWinIDs[DMP_CmdWinIndex] |= 0x8000;
                  }
                }
              }
              else if (gid <= GID_SAVE)
              {
                /* Save, Use, or Cancel button pressed */
                done = TRUE;
                exitopt = gid;
              }

              /* --- Reset(?) Palette color Copy or Swap --- */
              if (palaction)
              {
                if (palaction & 0x80000000)
                {
                  /* Palette Action was just set; leave it (mostly) alone */
                  palaction &= 0x7fffffff;
                }
                else
                {
                  /* Clear the Palette Action */
                  if (palaction == GID_PENS_LIST)
                  {
                    SetGadgetAttrs(PrefGadgets[palaction], win, NULL, LISTBROWSER_Selected, -1, TAG_DONE);
                    DMP_Help[GID_PENS_LIST].text = (STRPTR) msgPrefsColorsHelpSelectPen; // "Select the Pen to change";
                  }
                  else
                  {
                    SetGadgetAttrs(PrefGadgets[palaction], win, NULL, GA_Selected, FALSE, TAG_DONE);
                  }
                  palaction = 0;
                }
              }

            } /* end normal GadgetUp*/
          }
          break;  /* end case WMHI_GADGETUP */

        case WMHI_GADGETHELP:
          gid = result & WMHI_GADGETMASK;

          if (gid < GAD_TOTAL)
          {
            helpgid = gid;
/*
            sprintf(tmparg, "%s (%s) - Press HELP for details", DMP_Help[gid].text,
                                                                DMP_Modified[gid] ? "Changed" : "Unchanged");
*/
            sprintf(tmparg, "%s (%s) - %s", DMP_Help[gid].text,
                                            DMP_Modified[gid] ? msgPrefsHelpChanged : msgPrefsHelpUnchanged,
                                            msgPrefsHelpDetails);
/*             sprintf(tmparg, "%ld", gid); */

            SetAttrs(statusbar, GA_Text, tmparg, TAG_DONE);
            RefreshGList(statusbar, win, NULL, 1);
          }
          break;

      } /* end switch WMHI_CLASSMASK*/
    } /* end while window msg */
  }  /* end while !done */

  return exitopt;
}


BOOL DMPSetPreferences(uint32 exitopt, BOOL *resetdm)
{
  BOOL            done=TRUE, boolval;
  UBYTE           sortbychars[]="NSDCEL";
  uint32          i, gid, chooseropt, gadopt, gadopt2;
  STRPTR          sptr;
  struct TextAttr *txtattr;
  struct Gadget   *gadptr;

  if (exitopt > GID_CANCEL)
  {
    /* --- Set preferences --- */

    /* Appicon string gadget was changed? (It doesn't send msgs (despite what the docs say)) */
    if (DMP_Modified[GID_SETX_APPICON] == FALSE)  /* If it's modified then skip next test */
    {
      GetAttr(GETFILE_FullFile, PrefGadgets[GID_SETX_APPICON], (ULONG *)(void *) &sptr);
      DMP_Modified[GID_SETX_APPICON] = (Stricmp(AppIconPath, sptr) != 0);
    }
    /* Guide string gadget was changed? */
    if (DMP_Modified[GID_SETX_GUIDE] == FALSE)  /* If it's modified then skip next test */
    {
      GetAttr(GETFILE_FullFile, PrefGadgets[GID_SETX_GUIDE], (ULONG *)(void *) &sptr);
      DMP_Modified[GID_SETX_GUIDE] = (Stricmp(DiskMaster2Guide, sptr) != 0);
    }


    /* Set preferences for modified items... */
    for (gid=PREFGAD_START; gid < GAD_TOTAL; gid++)
    {
      if (DMP_Modified[gid])
      {
        gadptr = PrefGadgets[gid];
        ActionArgs[1] = 0;
        ActionArgs[2] = 0;
        switch(gid)
        {
          case GID_USESCREENTYPE:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt);
            DMP_UseHostScreen = (chooseropt == 0);
            *resetdm = TRUE;
            break;
          case GID_SCREEN:
            if (DMP_UseHostScreen == FALSE)
            {
              Screen_ID = DMP_Screen_ID;
              Screen_Width = DMP_Screen_Width;
              Screen_Height = DMP_Screen_Height;
              Screen_Depth = DMP_Screen_Depth;
            }
            *resetdm = TRUE;
            break;
          case GID_SETX_WINSCALE:
            GetAttr(GA_Selected, gadptr, &chooseropt);
            DMP_UseWinScale = (chooseropt != 0);
            break;
          case GID_BARFORMAT:
            GetAttr(STRINGA_TextVal, gadptr, (ULONG *)(void *) &sptr);
            DMSetFormat(sptr, BarFormat, 192);
            break;
          case GID_SETX_APPICON:
            GetAttr(GETFILE_FullFile, gadptr, (ULONG *)(void *) &sptr);
            sprintf(tmparg, "APPICON=%s", sptr);
            ActionArgs[1] = tmparg;
            DMSet();
            break;
          case GID_SETX_ICONX:
            GetAttr(INTEGER_Number, gadptr, (ULONG *)(void *) &IconX);
            if (IconX == -1)
            {
              IconX = NO_ICON_POSITION;
            }
            break;
          case GID_SETX_ICONY:
            GetAttr(INTEGER_Number, gadptr, (ULONG *)(void *) &IconY);
            if (IconY == -1)
            {
              IconY = NO_ICON_POSITION;
            }
            break;
          case GID_SETX_DIGITS:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt);
            sprintf(tmparg, "DIGITS=%ld", chooseropt + 4);
            ActionArgs[1] = tmparg;
            DMSet();
            break;
          case GID_SETX_GUIDE:
            GetAttr(GETFILE_FullFile, gadptr, (ULONG *)(void *) &sptr);
            sprintf(tmparg, "GUIDE=%s", sptr);
            ActionArgs[1] = tmparg;
            DMSet();
            break;
          case GID_SETX_REQHIDEHELP:
            GetAttr(GA_Selected, gadptr, &chooseropt);
            Req_ShowHelpBtn = (chooseropt != 0);
            break;

          case GID_TITLEFORMAT:
            GetAttr(STRINGA_TextVal, gadptr, (ULONG *)(void *) &sptr);
            DMSetFormat(sptr, TitleFormat, 50);
            break;
          case GID_SETFORMAT:
            GetAttr(STRINGA_TextVal, gadptr, (ULONG *)(void *) &sptr);
            DMSetFormat(sptr, DispFormat, 20);
            break;
          case GID_SETX_TIMEPLUS:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt);
            boolval = (chooseropt == 1);
            if (((FLAGS & DMFLAG_TIMEPLUS) != 0) != boolval) /* User choice different than current setting? */
            {
              ActionArgs[1] = "TIMEPLUS";
              DMSet();
            }
            break;
          case GID_SETX_SIZES:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt); /* 2.6 rri */
            sprintf(tmparg, "SIZES=%ld", chooseropt+1);
            ActionArgs[1] = tmparg;
            DMSet();
            break;
          case GID_SETX_SEPARATOR:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt);
            sprintf(tmparg, "SEPARATOR=%ld", (LONG) *(SetXSep[chooseropt]));
            ActionArgs[1] = tmparg;
            DMSet();
            break;
          case GID_SORT_BY:
          case GID_SORT_REV:
          case GID_SORT_GLOBAL:
            GetAttr(CHOOSER_Selected, PrefGadgets[GID_SORT_BY], &chooseropt);
            GetAttr(GA_Selected, PrefGadgets[GID_SORT_REV], &gadopt);
            GetAttr(GA_Selected, PrefGadgets[GID_SORT_GLOBAL], &gadopt2);
            sprintf(tmparg, "%lc%lc", sortbychars[chooseropt],
                                    gadopt ? '-' : '\0');
            ActionArgs[1] = tmparg;
            if (gadopt2)
            {
              ActionArgs[2] = "G";
              ActionArgs[3] = 0;
            }
            Sort();
            DMP_Modified[GID_SORT_REV] = FALSE;
            DMP_Modified[GID_SORT_GLOBAL] = FALSE;
            break;
          case GID_BUTTON:
            GetAttr(STRINGA_TextVal, gadptr, (ULONG *)(void *) &sptr);
            DMstrncpy(PGadStr, sptr, 250);
            break;
#ifndef __amigaos4__
          case GID_SETX_DRAGDELAY:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt);
            drag_delay = (chooseropt + 3) * 1000;
            break;
#endif
          case GID_SETX_WHEELMULT:
            GetAttr(CHOOSER_Selected, gadptr, &chooseropt);
            wheel_multiply = chooseropt + 1;
            break;
          case GID_FONT_SCREEN:
            if (!DMP_UseHostScreen)
            {
              GetAttr(GETFONT_TextAttr, gadptr, (ULONG *)(void *) &txtattr);
              if (DMP_Screen_Font)
              {
                PoolFreeVec(DMP_Screen_Font);
              }
              DMP_Screen_Font = CloneStr(txtattr->ta_Name, StringPool);
              DMP_Screen_FontSz = txtattr->ta_YSize;
              *resetdm = TRUE;
            }
            break;
          case GID_FONT_DIRWIN:
          case GID_FONT_DIRGAD:
          case GID_FONT_MENU:
          case GID_FONT_CMDWIN: /* 2.7 rri */
          case GID_FONT_READER: /* 2.7 rri */
          case GID_FONT_REQTXT:
          case GID_FONT_REQBTN:
            i = gid - GID_FONT_DIRWIN;
            GetAttr(GETFONT_TextAttr, gadptr, (ULONG *)(void *) &txtattr);
            sprintf(tmparg, "%s=%s", FontKeywords[i], txtattr->ta_Name);
            sprintf(tmparg2, "%ld", (LONG) txtattr->ta_YSize);
            ActionArgs[1] = tmparg;
            ActionArgs[2] = tmparg2;
            ActionArgs[3] = 0;
            CMD_Font();
            break;

          case GID_SETX_UCLRSLD:
          case GID_SETX_UCLRINT:
            GetAttr(INTEGER_Number, PrefGadgets[GID_SETX_UCLRINT], &chooseropt);
            sprintf(tmparg, "USERCOLORS=%ld", chooseropt);
            ActionArgs[1] = tmparg;
            DMSet();
            break;

          /* 2.7 jjt */
          case GID_KEY_LIST:
            DMPSetPrefs_KeyCmds();
            break;
          case GID_AUTO_LIST:
            DMPSetPrefs_AutoCmds();
            break;
          case GID_MENU_LIST:
            DMPSetPrefs_Menus();
            break;
          case GID_CMD_LIST:
            DMPSetPrefs_Cmds();
            break;
          case GID_HDEV_LIST:
            DMPSetPrefs_HideDev();
            break;
          case GID_PENS_LIST:
            *resetdm = DMPSetPrefs_Pens();
            RefreshWindows();
            break;

/*
          case GID_:
            break;

DMReqTagList(tmparg, 0, 0, 0);
*/
        }  /* end switch (gid) */

        if (ChangedPalette && Refresh24)
        {
          /* "Encourage" 16/24-bit screens to use the new palette */
          *resetdm = TRUE;
        }

      }  /* end if modified */
    }  /* end for (DMP_Modified[]...) */

    if (exitopt == GID_SAVE)
    {
      ActionArgs[1] = 0;
      done = SaveConfig();
    }
  } /* end if Save or Use */
  else
  {
    /* Requester was cancelled... */
    if (ChangedPalette)
    {
      ResetColor(NULL, TRUE);
    }
  }

  return done;
}


void DMPSetPrefs_KeyCmds(void)  /* 2.7 jjt */
{
  STRPTR key, cmd;
  struct Node *node, *nextnode;

  /* --- Replace current key commands with Folgers crystals --- */

  /* Out with the old... */
  FreeStringArray(KeyCmdStr, 100);

  /* In with the new...  */
  node = KeyCmds_l.lh_Head->ln_Succ;  /* Skip the kludge node at the list's head */
  while((nextnode = node->ln_Succ))
  {
    GetListBrowserNodeAttrs(node, LBNA_Column, 0,
                                  LBNCA_Text, (ULONG *)(void *) &key,
                                  LBNA_Column, 1,
                                  LBNCA_Text, (ULONG *)(void *) &cmd,
                                  TAG_DONE);
    if (*key)
    {
      sprintf(tmparg, "%s, %s", key, cmd);
      /* DMReqTagList(tmparg, 0, 0, 0); */
      AddKeyCmd(tmparg);
    }
    node = nextnode;
  }
}


void DMPSetPrefs_AutoCmds(void)  /* 2.7 jjt */
{
  STRPTR data, pattern, cmd, comma, sptr;
  struct Node *node, *nextnode;

  /* --- Replace current AutoCmds with the new AutoCmd_l values --- */

  FreeStringArray(AutoCmdStr, 255);

  node = AutoCmds_l.lh_Head->ln_Succ;  /* Skip the kludge node at the list's head */
  while((nextnode = node->ln_Succ))
  {
    GetListBrowserNodeAttrs(node, LBNA_Column, 0,
                                  LBNCA_Text, (ULONG *)(void *) &data,
                                  LBNA_Column, 1,
                                  LBNCA_Text, (ULONG *)(void *) &pattern,
                                  LBNA_Column, 2,
                                  LBNCA_Text, (ULONG *)(void *) &cmd,
                                  TAG_DONE);
    if ((*data || *pattern))
    {
      if (*pattern)
      {
        comma = ",";
        sptr = pattern;
      }
      else
      {
        comma = "";
        sptr = data;
      }
      sprintf(tmparg, "%s%s, %s", comma, sptr, cmd);
      /* DMReqTagList(tmparg, 0, 0, 0); */
      AddAutoCmd(tmparg);
    }
    node = nextnode;
  }
}


void DMPSetPrefs_Menus(void)  /* 2.7 jjt */
{
  UBYTE       key[]={" , "};
  STRPTR      menu, title, k, cmd;
  struct Node *node, *nextnode;

  /* --- Replace current Menus with the new Menus_l values --- */

  MyFreeMenus();

  node = Menus_l.lh_Head->ln_Succ;  /* Skip the kludge node at the list's head */
  while((nextnode = node->ln_Succ))
  {
    GetListBrowserNodeAttrs(node, LBNA_Column, 0,
                                  LBNCA_Text, (ULONG *)(void *) &menu,
                                  LBNA_Column, 1,
                                  LBNCA_Text, (ULONG *)(void *) &title,
                                  LBNA_Column, 2,
                                  LBNCA_Text, (ULONG *)(void *) &k,
                                  LBNA_Column, 3,
                                  LBNCA_Text, (ULONG *)(void *) &cmd,
                                  TAG_DONE);
    if ((*menu && *title))
    {

      if (Stricmp(title, "BARLABEL") == 0)
      {
        key[0] = 0;
        cmd = ""; /* 2.7 jjt */
      }
      else
      {
        key[0] = *k;
      }
      sprintf(tmparg, "%s, %s, %s%s", menu, title, key, cmd);
      /* DMReqTagList(tmparg, 0, 0, 0); */
      AddMenuCmd(tmparg);
    }
    node = nextnode;
  }

  DMLayoutMenus();
}


void DMPSetPrefs_Cmds(void)  /* 2.7 jjt */
{
  UBYTE            *colorptr;
  uint32           i, winidx, colors;
  STRPTR           nameptr, cmdptr;
  struct List      *list;
  struct Node      *node, *nextnode;
  struct DirWindow *dw;

  /* ---- Replace Cmd Window contents with new data --- */
  colorptr = (UBYTE *) &colors;

  for(i=0; DMP_CmdWinIDs[i] != 0xFFFF; i++)
  {
    if ((DMP_CmdWinIDs[i] & 0x8000))
    {
      winidx = DMP_CmdWinIDs[i] & 0xFF;
      dw = DirWin[winidx];
      list = &(Cmds_l[i]);

      FreeDirTable(dw);
      dw->Flags |= DWFLAG_ADD;

      node = list->lh_Head->ln_Succ;  /* Skip the kludge node at the list's head */
      while((nextnode = node->ln_Succ))
      {
        GetListBrowserNodeAttrs(node, LBNA_UserData, &colors,
                                      LBNA_Column, 0,
                                      LBNCA_Text, (ULONG *)(void *) &nameptr,
                                      LBNA_Column, 1,
                                      LBNCA_Text, (ULONG *)(void *) &cmdptr,
                                      TAG_DONE);
        if (*nameptr)
        {
          if ((*nameptr == '#')) /* 2.7 jjt */
          {
            sprintf(tmparg, "#");
          }
          else
          {
            sprintf(tmparg, "%s, %lx%lx, %lx%lx, %s", nameptr,
                                                      (LONG) colorptr[0], (LONG) colorptr[1],
                                                      (LONG) colorptr[2], (LONG) colorptr[3],
                                                      cmdptr);
/*             DMReqTagList(tmparg, 0, 0, 0); */
          }
          AddCmd(dw, tmparg);
        }
        node = nextnode;
      } /* while (node) */
      RefreshCmdWin(dw);
    } /* if (modified) */
  } /* for (CmdWinIDs) */
}


void DMPSetPrefs_HideDev(void)  /* 2.7 jjt */
{
  struct Node *node, *nextnode;

  /* --- Replace current HideDev volumes with new data --- */

  /* Clear... */
  ActionArgs[1] = 0;
  CMD_HideDev();

  /* Replace...  */
  ActionArgs[2] = "ADD";
  ActionArgs[3] = 0;

  node = HideDev_l.lh_Head->ln_Succ;  /* Skip the kludge node at the list's head */
  while((nextnode = node->ln_Succ))
  {
    GetListBrowserNodeAttrs(node, LBNA_Column, 0,
                                  LBNCA_Text, (ULONG *)(void *) &(ActionArgs[1]),
                                  TAG_DONE);
    CMD_HideDev();
    node = nextnode;
  }
}


BOOL DMPSetPrefs_Pens(void)  /* 2.7 jjt */
{
  BOOL        reset=FALSE;
  uint32      i, pen, *setxpens[4];
  struct Node *node;


  /* Set SetX pens... */
  setxpens[0] = &BackPen;
  setxpens[1] = &DirPen;
  setxpens[2] = &FilePen;
  setxpens[3] = &SelectPen;

  node = Pens_l.lh_Head;  /* No kludge node here */
  for(i=0; i < 4; i++)
  {
    GetListBrowserNodeAttrs(node, LBNA_Column, 2, LBNCA_BGPen, &pen, TAG_DONE);
    *setxpens[i] = pen;
    node = node->ln_Succ;
  }

  /* Set Pens pens... */
  if (DMP_PensModified)
  {
    i = 0;
    while((node->ln_Succ))
    {
      GetListBrowserNodeAttrs(node, LBNA_Column, 2, LBNCA_BGPen, &pen, TAG_DONE);
      Pens20[i++] = pen;
      node = node->ln_Succ;
    }
    reset = TRUE;
  }

  return reset;
}


void initHelpStrings()
{
  uint32 i;
  STRPTR genericAddNode, genericRemNode, genericUpNode, genericDownNode;

  genericAddNode = (STRPTR) msgPrefsHelpAddNode; // "Add a new entry";
  genericRemNode = (STRPTR) msgPrefsHelpRemNode; // "Remove the selected entry";
  genericUpNode  = (STRPTR) msgPrefsHelpMoveUp; // "Move selected item down";
  genericDownNode= (STRPTR) msgPrefsHelpMoveDown; // "Move selected item down";

  /* Initialize DMP_Help array */

  if (helpinit)
  {
    /* Strings are already initialized; exit */
    return;
  }

  for (i=0; i < GAD_TOTAL; i++)
  {
    DMP_Help[i].text = (STRPTR) msgPrefsTitle; //"DMPrefs";
    DMP_Help[i].node = "DMPrefs";
  }

  /* Gadget help strings */
  DMP_Help[GID_CANCEL].text = (STRPTR) msgPrefsHelpDiscard; // "Discard changes";
  DMP_Help[GID_USE].text = (STRPTR) msgPrefsHelpUse; // "Use these settings";
  DMP_Help[GID_SAVE].text = (STRPTR) msgPrefsHelpSave; // "Save settings";

  DMP_Help[GID_USESCREENTYPE].text = (STRPTR) msgPrefsHelpScreenType; // "Use HostScreen or NewScreen";
  DMP_Help[GID_BARFORMAT].text = "BarFormat";
  DMP_Help[GID_BARFORMAT].node = "BarFormat";
  DMP_Help[GID_SETX_WINSCALE].text = (STRPTR) msgPrefsHelpWinScale; // "Use SetX DefX & DefY";
  DMP_Help[GID_SETX_WINSCALE].node = "SetX";
  DMP_Help[GID_SETX_APPICON].text = "SetX AppIcon";
  DMP_Help[GID_SETX_APPICON].node = "SetX";
  DMP_Help[GID_SETX_ICONX].text = "SetX IconX";
  DMP_Help[GID_SETX_ICONX].node = "SetX";
  DMP_Help[GID_SETX_ICONY].text = "SetX IconY";
  DMP_Help[GID_SETX_ICONY].node = "SetX";
  DMP_Help[GID_SETX_DIGITS].text = "SetX Digits";
  DMP_Help[GID_SETX_DIGITS].node = "SetX";
  DMP_Help[GID_SETX_GUIDE].text = "SetX Guide";
  DMP_Help[GID_SETX_GUIDE].node = "SetX";
  DMP_Help[GID_SETX_REQHIDEHELP].text = "SetX ReqHideHelp";
  DMP_Help[GID_SETX_REQHIDEHELP].node = "SetX";

  DMP_Help[GID_TITLEFORMAT].text = "TitleFormat";
  DMP_Help[GID_TITLEFORMAT].node = "TitleFormat";
  DMP_Help[GID_SETFORMAT].text = "SetFormat";
  DMP_Help[GID_SETFORMAT].node = "SetFormat";
  DMP_Help[GID_SETX_TIMEPLUS].text = "SetX TimePlus";
  DMP_Help[GID_SETX_TIMEPLUS].node = "SetX";
  DMP_Help[GID_SETX_SIZES].text = "SetX Sizes";
  DMP_Help[GID_SETX_SIZES].node = "SetX";
  DMP_Help[GID_SETX_SEPARATOR].text = "SetX Separator";
  DMP_Help[GID_SETX_SEPARATOR].node = "SetX";
  DMP_Help[GID_SORT_BY].text = "Sort";
  DMP_Help[GID_SORT_BY].node = "Sort";
  DMP_Help[GID_SORT_REV].text = (STRPTR) msgPrefsHelpSortReverse; // "Reverse sort order";
  DMP_Help[GID_SORT_REV].node = "Sort";
  DMP_Help[GID_SORT_GLOBAL].text = (STRPTR) msgPrefsHelpSortGlobal; // "All windows, or Source only?";
  DMP_Help[GID_SORT_GLOBAL].node = "Sort";
  DMP_Help[GID_BUTTON].text = "Button";
  DMP_Help[GID_BUTTON].node = "Button";
  DMP_Help[GID_SETX_DRAGDELAY].text = "SetX DragDelay";
  DMP_Help[GID_SETX_DRAGDELAY].node = "SetX";
  DMP_Help[GID_SETX_WHEELMULT].text = "SetX WheelMult";
  DMP_Help[GID_SETX_WHEELMULT].node = "SetX";
  DMP_Help[GID_HDEV_LIST].text = "HideDev";
  DMP_Help[GID_HDEV_LIST].node = "HideDev";
  DMP_Help[GID_HDEV_ADD].text = genericAddNode;
  DMP_Help[GID_HDEV_ADD].node = "HideDev";
  DMP_Help[GID_HDEV_REM].text = genericRemNode;
  DMP_Help[GID_HDEV_REM].node = "HideDev";
  DMP_Help[GID_HDEV_UP].text = genericUpNode;
  DMP_Help[GID_HDEV_UP].node = "HideDev";
  DMP_Help[GID_HDEV_DOWN].text = genericDownNode;
  DMP_Help[GID_HDEV_DOWN].node = "HideDev";

  DMP_Help[GID_FONT_SCREEN].text = "NewScreen F, FS";
  DMP_Help[GID_FONT_SCREEN].node = "NewScreen";
  DMP_Help[GID_FONT_DIRWIN].text = "Font DirWin";
  DMP_Help[GID_FONT_DIRWIN].node = "Font";
  DMP_Help[GID_FONT_DIRGAD].text = "Font DirGad";
  DMP_Help[GID_FONT_DIRGAD].node = "Font";
  DMP_Help[GID_FONT_MENU].text = "Font Menu";
  DMP_Help[GID_FONT_MENU].node = "Font";

  /* 2.7 rri */
  DMP_Help[GID_FONT_CMDWIN].text = "Font CMDWin";
  DMP_Help[GID_FONT_CMDWIN].node = "Font";
  DMP_Help[GID_FONT_READER].text = "Font Reader";
  DMP_Help[GID_FONT_READER].node = "Font";

  DMP_Help[GID_FONT_REQTXT].text = "Font ReqText";
  DMP_Help[GID_FONT_REQTXT].node = "Font";
  DMP_Help[GID_FONT_REQBTN].text = "Font ReqButtons";
  DMP_Help[GID_FONT_REQBTN].node = "Font";

  DMP_Help[GID_PALETTE_COPY].text = (STRPTR) msgPrefsHelpPaletteCopy; // "Copy current color to another cell";
  DMP_Help[GID_PALETTE_SWAP].text = (STRPTR) msgPrefsHelpPaletteSwap; // "Swap current color with another cell";
  DMP_Help[GID_PALETTE_RESET].text = (STRPTR) msgPrefsHelpPaletteReset; // "Reset the current color";
  DMP_Help[GID_PALETTE_RESETALL].text = (STRPTR) msgPrefsHelpPaletteResetAll; // "Reset the palette";
  DMP_Help[GID_SETX_UCLRSLD].text = "SetX UserColors";
  DMP_Help[GID_SETX_UCLRSLD].node = "SetX";
  DMP_Help[GID_SETX_UCLRINT].text = "SetX UserColors";
  DMP_Help[GID_SETX_UCLRINT].node = "SetX";
  DMP_Help[GID_PENS_LIST].text = (STRPTR) msgPrefsHelpPenSelect; // "Select the Pen to change";
  DMP_Help[GID_PENS_LIST].node = "Pens";

  DMP_Help[GID_KEY_LIST].text = "AddKeyCommand";
  DMP_Help[GID_KEY_LIST].node = "AddKeyCmd";
  DMP_Help[GID_KEY_ADD].text = genericAddNode;
  DMP_Help[GID_KEY_ADD].node = "AddKeyCmd";
  DMP_Help[GID_KEY_REM].text = genericRemNode;
  DMP_Help[GID_KEY_REM].node = "AddKeyCmd";
  DMP_Help[GID_KEY_UP].text = genericUpNode;
  DMP_Help[GID_KEY_UP].node = "AddKeyCmd";
  DMP_Help[GID_KEY_DOWN].text = genericDownNode;
  DMP_Help[GID_KEY_DOWN].node = "AddKeyCmd";
  DMP_Help[GID_AUTO_LIST].text = "AddAutoCommand";
  DMP_Help[GID_AUTO_LIST].node = "AddAutoCmd";
  DMP_Help[GID_AUTO_ADD].text = genericAddNode;
  DMP_Help[GID_AUTO_ADD].node = "AddAutoCmd";
  DMP_Help[GID_AUTO_REM].text = genericRemNode;
  DMP_Help[GID_AUTO_REM].node = "AddAutoCmd";
  DMP_Help[GID_AUTO_UP].text = genericUpNode;
  DMP_Help[GID_AUTO_UP].node = "AddAutoCmd";
  DMP_Help[GID_AUTO_DOWN].text = genericDownNode;
  DMP_Help[GID_AUTO_DOWN].node = "AddAutoCmd";
  DMP_Help[GID_MENU_LIST].text = "AddMenuCommand";
  DMP_Help[GID_MENU_LIST].node = "AddMenuCmd";
  DMP_Help[GID_MENU_ADD].text = genericAddNode;
  DMP_Help[GID_MENU_ADD].node = "AddMenuCmd";
  DMP_Help[GID_MENU_REM].text = genericRemNode;
  DMP_Help[GID_MENU_REM].node = "AddMenuCmd";
  DMP_Help[GID_MENU_UP].text = genericUpNode;
  DMP_Help[GID_MENU_UP].node = "AddMenuCmd";
  DMP_Help[GID_MENU_DOWN].text = genericDownNode;
  DMP_Help[GID_MENU_DOWN].node = "AddMenuCmd";
  DMP_Help[GID_CMD_WINS].text = (STRPTR) msgPrefsHelpCmdWin; // "Command window to edit";
  DMP_Help[GID_CMD_WINS].node = "AddCmd";
  DMP_Help[GID_CMD_LIST].text = "AddCommand";
  DMP_Help[GID_CMD_LIST].node = "AddCmd";
  DMP_Help[GID_CMD_ADD].text = genericAddNode;
  DMP_Help[GID_CMD_ADD].node = "AddCmd";
  DMP_Help[GID_CMD_REM].text = genericRemNode;
  DMP_Help[GID_CMD_REM].node = "AddCmd";
  DMP_Help[GID_CMD_UP].text = genericUpNode;
  DMP_Help[GID_CMD_UP].node = "AddCmd";
  DMP_Help[GID_CMD_DOWN].text = genericDownNode;
  DMP_Help[GID_CMD_DOWN].node = "AddCmd";
#ifndef __amigaos4__
  DMP_Help[GID_CMD_STATE].text = "Edit normal or selected colors";
  DMP_Help[GID_CMD_STATE].node = "AddCmd";
#endif
  DMP_Help[GID_CMD_FGPAL].text = (STRPTR) msgPrefsHelpForeground; // "Foreground color";
  DMP_Help[GID_CMD_FGPAL].node = "AddCmd";
  DMP_Help[GID_CMD_BGPAL].text = (STRPTR) msgPrefsHelpBackground; // "Background color";
  DMP_Help[GID_CMD_BGPAL].node = "AddCmd";
#ifndef __amigaos4__
  DMP_Help[GID_CMD_SAMPLE].text = "Color example";
  DMP_Help[GID_CMD_SAMPLE].node = "AddCmd";
#endif
/*
  DMP_Help[GID_].text = "";
  DMP_Help[GID_].node = "";
*/

  /* Also init PenNames[] and NULL-terminate... */  /* 2.7 jjt */
  i = 0;
  PenNames[i++] = "Detail";
  PenNames[i++] = "Block";
  PenNames[i++] = "Text";
  PenNames[i++] = "Shine";
  PenNames[i++] = "Shadow";
  PenNames[i++] = "HighFill";
  PenNames[i++] = "HighFill Text";
  PenNames[i++] = "Background";
  PenNames[i++] = "Highlight Text";
  PenNames[i++] = "Bar Detail";
  PenNames[i++] = "Bar Block";
  PenNames[i++] = "Bar Trim";
  /*   PenNames[i++] = ""; */
  PenNames[i] = 0;

  helpinit = TRUE;
}


struct Gadget * buildHostScreenGad()
{
  struct Gadget *hostgad;

  /* Build a HostScreen (string) gadget */

  hostgad = StringObject,
    GA_ID, GID_SCREEN,
    GA_RelVerify, TRUE,
    STRINGA_TextVal, DMP_HostScreen,
    STRINGA_MaxChars, 38,
    STRINGA_Justification, GACT_STRINGLEFT,
    GA_TabCycle, TRUE,
  StringEnd;

  DMP_Help[GID_USESCREENTYPE].node = "HostScreen";
  DMP_Help[GID_SCREEN].text = "HostScreen";
  DMP_Help[GID_SCREEN].node = "HostScreen";

  return hostgad;
}


struct Gadget * buildNewScreenGad()
{
  struct Gadget *newscrgad;

  /* Build a GetScreenMode gadget */

  newscrgad = GetScreenModeObject,
    GA_ID, GID_SCREEN,
    GA_RelVerify, TRUE,
    GETSCREENMODE_DisplayID, DMP_Screen_ID,
    GETSCREENMODE_DisplayWidth, DMP_Screen_Width,
    GETSCREENMODE_DisplayHeight, DMP_Screen_Height,
    GETSCREENMODE_DisplayDepth, DMP_Screen_Depth,
    GETSCREENMODE_DoWidth, TRUE,
    GETSCREENMODE_DoHeight, TRUE,
    GETSCREENMODE_DoDepth, TRUE,
    GETSCREENMODE_MinWidth, 320,
    GETSCREENMODE_MinHeight, 200,
  End;

  DMP_Help[GID_USESCREENTYPE].node = "NewScreen";
  DMP_Help[GID_SCREEN].text = "NewScreen";
  DMP_Help[GID_SCREEN].node = "NewScreen";

  return newscrgad;
}


void makePaletteInterconnect(Object *model)
{
  Object *icptr;

  /* Create a BOOPSI ModelClass interconnection object to connect GID_PALETTE,
     GID_COLORBOX, and GID_COLORBOXIDX.
     ...As if such a thing was possible.
  */

  if ((model = NewObject(NULL, "modelclass", TAG_END)))
  {
    SetAttrs(PrefGadgets[GID_PALETTE], ICA_TARGET, model, TAG_END);
    SetAttrs(PrefGadgets[GID_COLORBOXIDX], ICA_TARGET, model, TAG_END);

    /* Palette to Integer */
    if ((icptr = NewObject(NULL, "icclass", ICA_TARGET, PrefGadgets[GID_COLORBOXIDX],
                                            ICA_MAP, Pal2IntMap,
                                            TAG_END)))
    {
      DoMethod(model, OM_ADDMEMBER, icptr);
    }

    /* Integer to Palette */
    if ((icptr = NewObject(NULL, "icclass", ICA_TARGET, PrefGadgets[GID_PALETTE],
                                            ICA_MAP, Int2PalMap,
                                            TAG_END)))
    {
      DoMethod(model, OM_ADDMEMBER, icptr);
    }

    /* Palette to Button BG */
    if ((icptr = NewObject(NULL, "icclass", ICA_TARGET, PrefGadgets[GID_COLORBOX],
                                            ICA_MAP, Pal2BtnMap,
                                            TAG_END)))
    {
      DoMethod(model, OM_ADDMEMBER, icptr);
    }

    /* Integer to Button BG */
    if ((icptr = NewObject(NULL, "icclass", ICA_TARGET, PrefGadgets[GID_COLORBOX],
                                            ICA_MAP, Int2BtnMap,
                                            TAG_END)))
    {
      DoMethod(model, OM_ADDMEMBER, icptr);
    }
  }
}


void makeRgbSliderInterconnect(Object *modelarray[])
{
  uint32 i;
  Object *icptr;

  /* Create 3 BOOPSI ModelClass interconnection objects to connect GID_<x>SLIDERs,
     GID_<x>INTVALs, and broadcast the changes to the req's IDCMP port.
     ...Pure science fiction.
  */

  for (i=0; i < 3; i++)
  {
    if ((modelarray[i] = NewObject(NULL, "modelclass", ICA_TARGET, ICTARGET_IDCMP, TAG_END)))
    {
      /* Tell the gadgets to talk to the model... */
      SetAttrs(PrefGadgets[GID_REDSLIDER + i], ICA_TARGET, modelarray[i], TAG_END);
      SetAttrs(PrefGadgets[GID_REDINTVAL + i], ICA_TARGET, modelarray[i], TAG_END);

      /* Translate INTEGER_Number to SLIDER_Level... */
      if ((icptr = NewObject(NULL, "icclass", ICA_TARGET, PrefGadgets[GID_REDSLIDER + i],
                                              ICA_MAP, Int2SldMap,
                                              TAG_END)))
      {
        DoMethod(modelarray[i], OM_ADDMEMBER, icptr);
      }

      /* Translate SLIDER_Level to INTEGER_Number... */
      if ((icptr = NewObject(NULL, "icclass", ICA_TARGET, PrefGadgets[GID_REDINTVAL + i],
                                              ICA_MAP, Sld2IntMap,
                                              TAG_END)))
      {
        DoMethod(modelarray[i], OM_ADDMEMBER, icptr);
      }
    } /* model created */
  } /* end for */
}


void setEditColor(struct Window *win)
{
  uint32 i, color8, rgb[3];

  /* --- Set the RGB slider/integer values to the current color --- */

  GetRGB32(Screen->ViewPort.ColorMap, ColorIdx, 1, rgb);

  for(i=0; i < 3; i++)
  {
    color8 = rgb[i] >> 24; /* GetRGB32 returns 32 bits; we only want 8 */

    SetGadgetAttrs(PrefGadgets[GID_REDSLIDER + i], win, NULL, SLIDER_Level, color8, TAG_END);
  }

  /* The above SetGadgetAttrs() calls triggers the IDCMP hook */
  DMP_SetColorKludge = 3; /* 2.7 jjt */
}


void putEditColor(struct Window *win)
{
  uint32 i, rgb, color32table[5];

  /* --- Copy RGB slider values to the current color --- */

  color32table[0] = 0x00010000 | ColorIdx; /* No. of colors + starting index */
  for(i=0; i < 3; i++)
  {
    GetAttr(SLIDER_Level, PrefGadgets[GID_REDSLIDER + i], &rgb);
    color32table[i + 1] = (rgb << 24) | 0x00FFFFFF;  /* 8-bit color to 32 */
  }
  color32table[4] = 0;

  LoadRGB32(&(Screen->ViewPort), color32table);

  if (Refresh24)
  {
    /* 16/24-bit screens won't automatically reflect changes */
    SetGadgetAttrs(PrefGadgets[GID_PALETTE], win, NULL, PALETTE_Colour, ColorIdx, TAG_END);
    RefreshGList(PrefGadgets[GID_COLORBOX], win, NULL, 1);
  }
}


void CopySwapColor(struct Window *win, uint32 c1, uint32 c2, BOOL swap)
{
  uint32 color1[5], color2[5];

  /* --- Copy color at index <c1> to <c2>, and possibly <c2> to <c1> --- */

  GetRGB32(Screen->ViewPort.ColorMap, c1, 1, &(color1[1]));
  GetRGB32(Screen->ViewPort.ColorMap, c2, 1, &(color2[1]));
  color1[0] = 0x10000 | c2;
  color1[4] = 0;
  color2[0] = 0x10000 | c1;
  color2[4] = 0;

  LoadRGB32(&(Screen->ViewPort), color1);
  if (swap)
  {
    LoadRGB32(&(Screen->ViewPort), color2);
  }
  SetGadgetAttrs(PrefGadgets[GID_COLORBOX], win, NULL, BUTTON_BackgroundPen, ColorIdx, TAG_END);

  if (Refresh24)
  {
    /* 16/24-bit screens won't automatically reflect changes */
    RefreshGList(PrefGadgets[GID_PALETTE], win, NULL, 1);
  }
}


void ResetColor(struct Window *win, BOOL resetall)
{
  uint32 *tableptr, onecolor[5], idx, i;

  /* --- Reset the current color, or the entire palette --- */

  if (resetall)
  {
    /* Reset all */
    tableptr = DMP_ColorTable32;
  }
  else
  {
    /* Reset current color */
    onecolor[0] = 0x00010000 | ColorIdx;
    onecolor[4] = 0;
    idx = ColorIdx * 3;
    for(i=1; i < 4; i++)
    {
      onecolor[i] = DMP_RGBTable32[idx++];
    }
    tableptr = onecolor;
/*
    sprintf(tmparg, "%lu\n%lx %lx %lx", ColorIdx,
    onecolor[1], onecolor[2], onecolor[3]);
    DMReqTagList(tmparg, 0, 0, 0);
*/
  }
  LoadRGB32(&(Screen->ViewPort), tableptr);

  if (win)
  {
    setEditColor(win);

    if (Refresh24)
    {
      /* 16/24-bit screens won't automatically reflect changes */
      RefreshGList(PrefGadgets[GID_PALETTE], win, NULL, 1);
      RefreshGList(PrefGadgets[GID_COLORBOX], win, NULL, 1);
    }
  }
}


void makeCALabels(struct List *list, STRPTR *labels, BOOL isclicktab)
{
  uint32 i=0;
  struct Node *node;

  NewList(list);

  while(*labels)
  {
    if (isclicktab)  /* Make a ClickTab tab label... */
    {
      node = (struct Node *) AllocClickTabNode(TNA_Text, *labels,
                                               TNA_Number, i,
                                               TAG_DONE);
    }
    else  /* Make a Chooser choice... */
    {
      node = AllocChooserNode(CNA_Text, *labels, TAG_DONE);
    }

    if(node)
    {
      AddTail(list, node);
    }

    i++;
    labels++;
  }
}


void freeCALabels(struct List *list, BOOL isclicktab)
{
  struct Node *node, *nextnode;

  node = list->lh_Head;
  while((nextnode = node->ln_Succ)) /* 2.6 rri - GCC4 */
  {
    if (isclicktab)
    {
      FreeClickTabNode(node);
    }
    else
    {
      FreeChooserNode(node);
    }
    node = nextnode;
  }
}


void makeKludgeNode(struct List *list, uint32 cols)  /* 2.7 jjt */
{
  struct Node *node;

  /* --- ListBrowsers are unhappy when their lists are empty, so... --- */

  if ((node = AllocListBrowserNode(cols, LBNA_MemPool, StringPool,
                                         LBNA_Flags, LBFLG_HIDDEN,
                                         TAG_DONE)))
  {
    AddHead(list, node); /* Up here only Move needs to be aware of it */
  }
}


void makeKeyCmdsList(struct List *list)  /* 2.7 jjt */
{
  UBYTE       key[10];
  uint32      i, ki;
  STRPTR      kptr, cmdptr;
  struct Node *node;

  /* --- Build a ListBrowser list of key commands --- */

  NewList(list);

  for(i=0; i < 100; i++)
  {
    if((kptr = KeyCmdStr[i])) /* Find a key command... */
    {
      ki = 0;
      while (*kptr && (*kptr != ',') && (ki < 8)) /* Copy the keypress portion to <key>... */
      {
        key[ki++] = *kptr++;
      }
      key[ki] = 0;  /* Null-terminate <key> */
      while ((*kptr == ',') || (*kptr == ' ')) /* Skip the "," and any spaces */
      {
        kptr++;
      }
      cmdptr = kptr; /* Command portion of KeyCmdStr (probably). */

      if ((node = AllocListBrowserNode(2, LBNA_MemPool, StringPool,
                                          LBNA_Column, 0,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) key,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 8,
                                          LBNA_Column, 1,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) cmdptr,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 512,
                                          TAG_DONE)))
      {
        AddTail(list, node);
      }
    }
  }

  makeKludgeNode(list, 2);
}


void makeAutoCmdsList(struct List *list)  /* 2.7 jjt */
{
  uint32      i;
  STRPTR      datptr, patptr, cmdptr="", sptr, commaptr=0;
  struct Node *node;

  /* --- Build a ListBrowser list of auto commands --- */

  NewList(list);

  for(i=0; i < 255; i++)
  {
    if((sptr = AutoCmdStr[i])) /* Find an auto  command... */
    {
      if (*sptr == ',') /* Use a pattern */
      {
        sptr++;
        patptr = sptr;
        datptr = "";
      }
      else  /* Use data */
      {
        datptr = sptr;
        patptr = "";
      }

      while (*sptr && (*sptr != ',')) /* Find the comma or end of string... */
      {
        sptr++;
      }
      if (*sptr)  /* comma */
      {
        commaptr = sptr;  /* Remember this location */
        *sptr++ = 0;
        while (*sptr == ' ')  /* Skip spaces */
        {
          sptr++;
        }
        cmdptr = sptr;
      }

      if ((node = AllocListBrowserNode(3, LBNA_MemPool, StringPool,
                                          LBNA_Column, 0,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) datptr,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 254,
                                          LBNA_Column, 1,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) patptr,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 252,
                                          LBNA_Column, 2,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) cmdptr,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 512,
                                          TAG_DONE)))
      {
        AddTail(list, node);
      }

      if (commaptr)  /* Restore the comma, if changed. */
      {
        *commaptr = ',';
        commaptr = 0;
      }
    }
  }

  makeKludgeNode(list, 3);
}


void makeMenusList(struct List *list)  /* 2.7 jjt */
{
  UBYTE            key[]={" "};
  STRPTR           menuname, itemname, cmd;
  struct Node      *node;
  struct Menu      *menu;
  struct MenuItem  *item;

  /* --- Build a ListBrowser list of menus --- */

  NewList(list);

  menu = DMMenu;
  while(menu)
  {
    item = menu->FirstItem;
    menuname = menu->MenuName;
    while(item)
    {
      cmd = GTMENUITEM_USERDATA(item);
      if (cmd == NM_BARLABEL)
      {
        itemname = "BARLABEL";
        key[0] = 0;
        cmd = "";
      }
      else
      {
        itemname = ((struct IntuiText *) item->ItemFill)->IText;
        key[0] = item->Command;  /* Shortcut key or 0 */
      }

      if ((node = AllocListBrowserNode(4, LBNA_MemPool, StringPool,
                                          LBNA_Column, 0,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) menuname,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 100,
                                          LBNA_Column, 1,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) itemname,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 400,
                                          LBNA_Column, 2,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) key,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 2,
                                          LBNA_Column, 3,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) cmd,
                                            LBNCA_Editable, TRUE,
                                            LBNCA_MaxChars, 512,
                                          TAG_DONE)))
      {
        AddTail(list, node);
      }

      item = item->NextItem;
    }
    menu = menu->NextMenu;
  }

  makeKludgeNode(list, 4);
}


void makeCmdsList(void)  /* 2.7 jjt */
{
  UBYTE            winlabel[256], *colorptr;
  LONG             cidx;
  uint32           i, lidx=0, j, dmclrs, colors;
  STRPTR           nameptr, cmdptr;
  struct List      *list;
  struct Node      *node;
  struct DirWindow *dw;
  struct DirList   **dl, *dlp;

  /* --- Build a ListBrowser list of command window commands --- */

  colorptr = (UBYTE *) &colors;

  NewList(&CmdWins_l);

  /* Loop through the windows... */
  for(i=0; i < DMMAXWINDOWS; i++)
  {
    if (lidx >= DMP_MAXCMDWINS)
    {
      break;
    }

    if ((dw = DirWin[i]))
    {
      if (dw->Flags & DW_CMD)
      {
        /* Found a CMD window */

        /* Make GID_CMD_WINS entry */
        sprintf(winlabel, "%s %lu (ID: %lu  %ld,%ld %ldx%ld)", msgPrefsCommandsLabelCmdWin, lidx+1, i,
                                                               (LONG) dw->norm[0], (LONG) dw->norm[1],
                                                               (LONG) dw->norm[2], (LONG) dw->norm[3]);
        DMP_CmdWinTitles[lidx] = CloneStr(winlabel, StringPool);
        /* DMReqTagList(winlabel, 0, 0, 0); */
        DMP_CmdWinIDs[lidx] = i;

        if ((node = AllocChooserNode(CNA_Text, DMP_CmdWinTitles[lidx], TAG_DONE)))
        {
          AddTail(&CmdWins_l, node);

          /* Make cmds list */
          list = &(Cmds_l[lidx]);
          NewList(list);

          dl = dw->DirList;
          for(cidx=0; cidx < dw->FileCount; cidx++)
          {
            dlp = dl[cidx];
            if (dlp->name)
            {
              nameptr = dlp->name;
              cmdptr = dlp->cmt;
              dmclrs = dlp->attr;
              for(j=0; j < 4; j++)
              {
                colorptr[j] = dmclrs & 0x0F;
                dmclrs >>= 4;
              }
            }
            else
            {
              nameptr = "#";
              cmdptr = "";
              colors = 0x10000001;
            }
            /* DMReqTagList(nameptr, 0, 0, 0); */

            if ((node = AllocListBrowserNode(2, LBNA_MemPool, StringPool,
                                                LBNA_UserData, colors,
                                                LBNA_Flags, LBFLG_CUSTOMPENS,
                                                LBNA_Column, 0,
                                                  LBNCA_CopyText, TRUE,
                                                  LBNCA_FGPen, colorptr[0],
                                                  LBNCA_BGPen, colorptr[1],
                                                  LBNCA_Text, (ULONG) nameptr,
                                                  LBNCA_Editable, TRUE,
                                                  LBNCA_MaxChars, 120,
                                                LBNA_Column, 1,
                                                  LBNCA_CopyText, TRUE,
                                                  LBNCA_Text, (ULONG) cmdptr,
                                                  LBNCA_Editable, TRUE,
                                                  LBNCA_MaxChars, 900,
                                                TAG_DONE)))
            {
              AddTail(list, node);
            }
          } /* for (cmd total) */

          makeKludgeNode(list, 2);
          lidx++;

        } /* if (chooser node) */
      } /* if (CmdWin)*/
    } /* if (Win) */
  } /* for(DMMAXWINDOWS) */

  DMP_CmdWinTitles[lidx] = 0;
  DMP_CmdWinIDs[lidx] = 0xFFFF;

  /* Dummy values for when no command windows exist */
  if (DMP_CmdWinIDs[0] == 0xFFFF)
  {
    DMP_CmdWinTitles[0] = CloneStr(msgPrefsCommandsLabelNoCmdWin, StringPool);
    DMP_CmdWinTitles[1] = 0;
    if ((node = AllocChooserNode(CNA_Text, DMP_CmdWinTitles[0], TAG_DONE)))
    {
      AddTail(&CmdWins_l, node);
    }
    NewList(&Cmds_l[0]);
    makeKludgeNode(&Cmds_l[0], 2);
  }
}


void makeHideDevList(struct List *list)  /* 2.7 jjt */
{
  uint32      i;
  struct Node *node;

  /* --- Build a ListBrowser list of HideDev strings --- */

  NewList(list);

  for (i=0; i < DevHide_Count; i++)
  {
    sprintf(tmparg, "%s:", DevHide_List[i]);
    if ((node = AllocListBrowserNode(1, LBNA_MemPool, StringPool,
                                        LBNA_Column, 0,
                                          LBNCA_CopyText, TRUE,
                                          LBNCA_Text, (ULONG) tmparg,
                                          LBNCA_Editable, TRUE,
                                          LBNCA_MaxChars, 256,
                                        TAG_DONE)))
    {
      AddTail(list, node);
    }

  }

  makeKludgeNode(list, 2);
}


void makePensList(struct List *list) /* 2.7 jjt */
{
  LONG        setxpens[4];
  uint32      i;
  STRPTR      sptr;
  struct Node *node;

  setxpens[0] = BackPen;
  setxpens[1] = DirPen;
  setxpens[2] = FilePen;
  setxpens[3] = SelectPen;

  NewList(list);

  /* Create SetX entries... */
  i = 0;
  while ((sptr = SetXPenNames[i]))
  {
    if ((node = AllocListBrowserNode(3, LBNA_MemPool, StringPool,
                                        LBNA_Flags, LBFLG_CUSTOMPENS,
                                        LBNA_Column, 0,
                                          LBNCA_CopyText, TRUE,
                                          LBNCA_Justification, LCJ_CENTRE,
                                          LBNCA_Text, (ULONG) "SetX",
                                        LBNA_Column, 1,
                                          LBNCA_Text, (ULONG) sptr,
                                        LBNA_Column, 2,
                                          LBNCA_CopyText, TRUE,
                                          LBNCA_Text, (ULONG) "",
                                          LBNCA_BGPen, setxpens[i],
                                        TAG_DONE)))
    {
      AddTail(list, node);
    }
    i++;
  }

  /* Create Pens entries (if not on a PubScreen)... */
  if (!DMP_UseHostScreen)
  {
    i = 0;
    while ((sptr = PenNames[i]))
    {
      sprintf(tmparg, "%ld", i);
      if ((node = AllocListBrowserNode(3, LBNA_MemPool, StringPool,
                                          LBNA_Flags, LBFLG_CUSTOMPENS,
                                          LBNA_Column, 0,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Justification, LCJ_CENTRE,
                                            LBNCA_Text, (ULONG) tmparg,
                                          LBNA_Column, 1,
                                            LBNCA_Text, (ULONG) sptr,
                                          LBNA_Column, 2,
                                            LBNCA_CopyText, TRUE,
                                            LBNCA_Text, (ULONG) "",
                                            LBNCA_BGPen, Pens20[i],
                                          TAG_DONE)))
      {
        AddTail(list, node);
      }
      i++;
    }
  }

}


Object * makeListView(uint32 gid)  /* 2.7 jjt */
{
  struct List       *list=0;
  Object            *lvgroup;
  struct ColumnInfo *ci=0;

  switch (gid)
  {
    case GID_KEY_LIST:
      list = &KeyCmds_l;
      ci = Keys_ci;
      break;

    case GID_AUTO_LIST:
      list = &AutoCmds_l;
      ci = Auto_ci;
      break;

    case GID_MENU_LIST:
      list = &Menus_l;
      ci = Menu_ci;
      break;

    case GID_CMD_LIST:
      list = &Cmds_l[0];
      ci = Cmds_ci;
      break;

    case GID_HDEV_LIST:
      list = &HideDev_l;
      ci = HDev_ci;
      break;
  }

  lvgroup = VLayoutObject,
              LAYOUT_SpaceOuter, gid != GID_CMD_LIST,
              LAYOUT_AddChild, PrefGadgets[gid] = ListBrowserObject,
                /* GA_ID, gid++, */
                GA_ID, gid,
                GA_RelVerify, TRUE,
                LISTBROWSER_AutoFit, TRUE,
                LISTBROWSER_ShowSelected, TRUE,
                LISTBROWSER_HorizontalProp, TRUE,
                LISTBROWSER_Editable, TRUE,
                LISTBROWSER_Labels, (ULONG) list,
                LISTBROWSER_ColumnInfo, (ULONG) ci,
                LISTBROWSER_ColumnTitles, TRUE,
                GA_TabCycle, TRUE,
              End,

              LAYOUT_AddChild, HLayoutObject,  /* Buttons H-Group */
                LAYOUT_EvenSize, TRUE,

                  LAYOUT_AddChild, ButtonObject,  /* Add */
                    /* GA_ID, gid++, */
                    GA_ID, gid+1,
                    GA_RelVerify, TRUE,
                     GA_Text, msgPrefsButtonsAdd, // "Add",
                    GA_TabCycle, TRUE,
                  ButtonEnd,

                  LAYOUT_AddChild, PrefGadgets[gid+2] = ButtonObject,  /* Remove */
                    GA_ID, gid+2,
                    GA_RelVerify, TRUE,
                    GA_Text, msgPrefsButtonsRemove, // "Remove",
                    GA_Disabled, TRUE,
                    GA_TabCycle, TRUE,
                  ButtonEnd,

                  LAYOUT_AddChild, PrefGadgets[gid+3] = ButtonObject,  /* Move up */
                    GA_ID, gid+3,
                    GA_RelVerify, TRUE,
                    GA_Text, msgPrefsButtonsMoveUp, // "Move Up",
                    GA_Disabled, TRUE,
                    GA_TabCycle, TRUE,
                  ButtonEnd,

                  LAYOUT_AddChild, PrefGadgets[gid+4] = ButtonObject,  /* Move Down */
                    GA_ID, gid+4,
                    GA_RelVerify, TRUE,
                    GA_Text, msgPrefsButtonsMoveDown, // "Move Down",
                    GA_Disabled, TRUE,
                    GA_TabCycle, TRUE,
                  ButtonEnd,

              LayoutEnd,
              CHILD_WeightedWidth, 0,
              CHILD_WeightedHeight, 0,  /* End Buttons H-Group */

            LayoutEnd;
  return lvgroup;
}


void dmpDisableLVButtons(struct Window *win, uint32 lvgid, BOOL disable)  /* 2.7 jjt */
{
  uint32 i, e;

  /* (Dis|En)able "Remove", "Move Up", and "Move Down" gadgets,
     and also the forground and background palettes if this is the "Commands" page.
  */
  e = lvgid == GID_CMD_LIST ? 7 : 5;
  for (i = 2; i < e; i++)
  {
    SetGadgetAttrs(PrefGadgets[lvgid+i], win, NULL, GA_Disabled, disable, TAG_DONE);
  }

#ifndef __amigaos4__
  if (lvgid == GID_CMD_LIST)
  {
    SetGadgetAttrs(PrefGadgets[GID_CMD_STATE], win, NULL, GA_Disabled, disable, TAG_DONE);
  }
#endif
}


void dmpLVEditNext(struct Window *win, uint32 gid) /* 2.7 jjt */
{
  uint32 col, pos, total;

  /* --- Activate Edit mode for the next column of the current node --- */
  GetAttr(LISTBROWSER_RelColumn, PrefGadgets[gid], &col);
  GetAttr(LISTBROWSER_Selected, PrefGadgets[gid], &pos);

  if ((gid == GID_CMD_LIST) || (gid == GID_KEY_LIST))
  {
    total = 2;
  }
  else if (gid == GID_AUTO_LIST)
  {
    total = 3;
  }
  else
  {
    total = 4;
  }

  if (++col < total)
  {
    SetGadgetAttrs(PrefGadgets[gid], win, NULL, LISTBROWSER_EditColumn, col,
                                                LISTBROWSER_EditNode, pos,
                                                TAG_DONE);
    ActivateGadget(PrefGadgets[gid], win, 0);
  }
}


void dmpAddNewNode(uint32 gid, struct Window *win) /* 2.7 jjt */
{
  uint32         pos;
  struct List    *list=0;
  struct Node    *node, *dest;
  struct TagItem *tags=0,
                 keynodetags[]={{LBNA_MemPool, 0},
                                {LBNA_Column, 0},
                                  {LBNCA_CopyText, TRUE},
                                  {LBNCA_Text, (ULONG) ""},
                                  {LBNCA_Editable, TRUE},
                                  {LBNCA_MaxChars, 8},
                                {LBNA_Column, 1},
                                  {LBNCA_CopyText, TRUE},
                                  {LBNCA_Text, (ULONG) "<?>"},
                                  {LBNCA_Editable, TRUE},
                                  {LBNCA_MaxChars, 512},
                                {TAG_DONE, 0}},
                autonodetags[]={{LBNA_MemPool, 0},
                                {LBNA_Column, 0},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) ""},
                                 {LBNCA_Editable, TRUE},
                                 {LBNCA_MaxChars, 254},
                                {LBNA_Column, 1},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) ""},
                                 {LBNCA_Editable, TRUE},
                                 {LBNCA_MaxChars, 252},
                                {LBNA_Column, 2},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) "<?>"},
                                 {LBNCA_Editable, TRUE},
                                 {LBNCA_MaxChars, 512},
                                {TAG_DONE, 0}},
                menunodetags[]={{LBNA_MemPool, 0},
                                {LBNA_Column, 0},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) ""},
                                 {LBNCA_Editable, TRUE},
                                 {LBNCA_MaxChars, 100},
                                {LBNA_Column, 1},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) ""},
                                 {LBNCA_Editable, TRUE},
                                 {LBNCA_MaxChars, 400},
                                {LBNA_Column, 2},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) ""},
                                 {LBNCA_Editable, TRUE},
                                 {LBNCA_MaxChars, 2},
                                {LBNA_Column, 3},
                                 {LBNCA_CopyText, TRUE},
                                 {LBNCA_Text, (ULONG) "<?>"},
                                 {LBNCA_Editable, TRUE},
                                {LBNCA_MaxChars, 512},
                                {TAG_DONE, 0}},
                 cmdnodetags[]={{LBNA_MemPool, 0},
                                {LBNA_UserData, 0x01000001}, /* FG, BG, Selected FG, BG */
                                {LBNA_Flags, LBFLG_CUSTOMPENS},
                                {LBNA_Column, 0},
                                  {LBNCA_CopyText, TRUE},
                                  {LBNCA_Text, (ULONG) ""},
                                  {LBNCA_Editable, TRUE},
                                  {LBNCA_MaxChars, 120},
                                {LBNA_Column, 1},
                                 {LBNCA_CopyText, TRUE},
                                  {LBNCA_Text, (ULONG) "<?>"},
                                  {LBNCA_Editable, TRUE},
                                  {LBNCA_MaxChars, 900},
                                {TAG_DONE, 0}},
                hdevnodetags[]={{LBNA_MemPool, 0},
                                {LBNA_Column, 0},
                                  {LBNCA_CopyText, TRUE},
                                  {LBNCA_Text, (ULONG) ":"},
                                  {LBNCA_Editable, TRUE},
                                  {LBNCA_MaxChars, 256},
                                {TAG_DONE, 0}};


  switch (gid)
  {
    case GID_KEY_ADD:
      tags = keynodetags;
      break;

    case GID_AUTO_ADD:
      tags = autonodetags;
      break;

    case GID_MENU_ADD:
      tags = menunodetags;
      break;

    case GID_CMD_ADD:
      tags = cmdnodetags;
      break;

    case GID_HDEV_ADD:
      tags = hdevnodetags;
      break;
  }

  gid--;
  GetAttr(LISTBROWSER_Labels, PrefGadgets[gid], (ULONG *)(void *) &list);

  tags->ti_Data = (ULONG) StringPool; /* Set the memory pool for whichever taglist we're using. */

  GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[gid], (ULONG *)(void *) &dest);  /* 2.7 jjt */
  if (dest)
  {
    GetAttr(LISTBROWSER_Selected, PrefGadgets[gid], &pos);
    pos++;
  }
  else
  {
    dest = list->lh_TailPred;
    GetAttr(LISTBROWSER_TotalNodes, PrefGadgets[gid], &pos);
  }

  if ((node = (struct Node *) DoGadgetMethod(PrefGadgets[gid], win, NULL, LBM_ADDNODE, PrefGadgets[gid], dest, tags)))
  {
    SetGadgetAttrs(PrefGadgets[gid], win, NULL, LISTBROWSER_MakeVisible, pos,
                                                LISTBROWSER_EditColumn, 0,
                                                LISTBROWSER_EditNode, pos,
                                                TAG_DONE);
    ActivateGadget(PrefGadgets[gid], win, 0);
    DMP_Modified[gid] = TRUE;
  }
}


void dmpRemoveNode(uint32 gid, struct Window *win) /* 2.7 jjt */
{
  struct Node *node;

  gid -= 2;

  GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[gid], (ULONG *)(void *) &node);
  if (node)
  {
    DoGadgetMethod(PrefGadgets[gid], win, NULL, LBM_REMNODE, PrefGadgets[gid], node);
    DMP_Modified[gid] = TRUE;
  }

}


void dmpMoveNode(uint32 btnid, struct Window *win) /* 2.7 jjt */
{
  int32       pos, total;
  uint32      gid=0, dir=0;
  struct List *list=0;
  struct Node *srcnode, *dstnode=0;

  /* --- Move the selected node up or down the list --- */
  /* ...But not above the hidden kludge node.           */

  switch (btnid)
  {
    case GID_KEY_DOWN:
      dir = 1;
    case GID_KEY_UP:
      gid = GID_KEY_LIST;
      break;

    case GID_AUTO_DOWN:
      dir = 1;
    case GID_AUTO_UP:
      gid = GID_AUTO_LIST;
      break;

    case GID_MENU_DOWN:
      dir = 1;
    case GID_MENU_UP:
      gid = GID_MENU_LIST;
      break;

    case GID_CMD_DOWN:
      dir = 1;
    case GID_CMD_UP:
      gid = GID_CMD_LIST;
      break;

    case GID_HDEV_DOWN:
      dir = 1;
    case GID_HDEV_UP:
      gid = GID_HDEV_LIST;
      break;
  }

  GetAttr(LISTBROWSER_Labels, PrefGadgets[gid], (ULONG *)(void *) &list);
  GetAttr(LISTBROWSER_Selected, PrefGadgets[gid], (ULONG *) &pos);
  GetAttr(LISTBROWSER_TotalNodes, PrefGadgets[gid], (ULONG *) &total);

  if ((pos != -1) && (total > 2))  /* Something selected, and list isn't empty */
  {
    GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[gid], (ULONG *)(void *) &srcnode);
    if (dir) /* Moving down */
    {
      if (++pos != total)  /* If we aren't the last node */
      {
        dstnode = srcnode->ln_Succ;
      }
    }
    else  /* Moving up */
    {
      if (--pos != 0) /* If we aren't the first node (not counting the kludge node) */
      {
        dstnode = srcnode->ln_Pred;
        dstnode = dstnode->ln_Pred;
      }
    }

    if (dstnode)
    {
      SetGadgetAttrs(PrefGadgets[gid], win, NULL, LISTBROWSER_Labels, ~0, TAG_DONE);

      Remove(srcnode);
      Insert(list, srcnode, dstnode);

      SetGadgetAttrs(PrefGadgets[gid], win, NULL, LISTBROWSER_Labels, (ULONG) list,
                                                  LISTBROWSER_SelectedNode, (ULONG) srcnode,
                                                  LISTBROWSER_MakeVisible, pos,
                                                  TAG_DONE);
      DMP_Modified[gid] = TRUE;
    }
  }
}


void dmpCmdLV2Pal(struct Window *win)  /* 2.7 jjt */
{
  UBYTE       *cptr;
  uint32      colors, state, cidx;
  struct Node *node;

  /* --- Transfer color information from a listview node to the Cmd color gadgets --- */

  /* Get state, current node, and the node's UserData (color info) */
#ifdef __amigaos4__
 state = 0;
#else
  GetAttr(CHOOSER_Selected, PrefGadgets[GID_CMD_STATE], &state);
#endif
  GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[GID_CMD_LIST], (ULONG *)(void *) &node);
  GetListBrowserNodeAttrs(node, LBNA_UserData, &colors, TAG_DONE);

  /* Store color in the palettes */
  cptr = (UBYTE *) &colors;
  cidx = state * 2;

/*
  sprintf(tmparg, "%lx %lx\n%lx %lx\n%lx", cptr[0], cptr[1], cptr[2], cptr[3], cidx);
  DMReqTagList(tmparg, 0, 0, 0);
*/

  SetGadgetAttrs(PrefGadgets[GID_CMD_FGPAL], win, NULL, PALETTE_Colour, cptr[cidx++], TAG_DONE); /* 2.7b9 rri */
  SetGadgetAttrs(PrefGadgets[GID_CMD_BGPAL], win, NULL, PALETTE_Colour, cptr[cidx], TAG_DONE);

#ifndef __amigaos4__
  SetGadgetAttrs(PrefGadgets[GID_CMD_SAMPLE], win, NULL, BUTTON_TextPen, cptr[cidx++], TAG_DONE);
  SetGadgetAttrs(PrefGadgets[GID_CMD_SAMPLE], win, NULL, BUTTON_BackgroundPen, cptr[cidx], TAG_DONE);
#endif
}


void dmpCmdPal2LV(struct Window *win)  /* 2.7 jjt */
{
  UBYTE       *cptr;
  uint32      colors, state, cidx, fg, bg;
  struct List *list;
  struct Node *node;


  /* --- Transfer color info. from Cmd color gadgets to the current listview node --- */

  /* Get state, current node, and the node's UserData (color info) */
#ifdef __amigaos4__
 state = 0;
#else
  GetAttr(CHOOSER_Selected, PrefGadgets[GID_CMD_STATE], &state);
#endif
  GetAttr(PALETTE_Colour, PrefGadgets[GID_CMD_FGPAL], &fg);
  GetAttr(PALETTE_Colour, PrefGadgets[GID_CMD_BGPAL], &bg);
  GetAttr(LISTBROWSER_Labels, PrefGadgets[GID_CMD_LIST], (ULONG *)(void *) &list);
  GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[GID_CMD_LIST], (ULONG *)(void *) &node);
  GetListBrowserNodeAttrs(node, LBNA_UserData, &colors, TAG_DONE);

  /* Update the colors with the current palette values */
  cptr = (UBYTE *) &colors;
  cidx = state * 2;

  cptr[cidx++] = fg;
  cptr[cidx] = bg;

  /* Store the colors in the listview node */
  SetGadgetAttrs(PrefGadgets[GID_CMD_LIST], win, NULL, LISTBROWSER_Labels, ~0, TAG_DONE);

  SetListBrowserNodeAttrs(node, LBNA_UserData, colors,
                                /* LBNA_Flags, LBFLG_CUSTOMPENS, */
                                LBNA_Column, 0,
                                  LBNCA_FGPen, cptr[0],
                                  LBNCA_BGPen, cptr[1],
                                TAG_DONE);

  SetGadgetAttrs(PrefGadgets[GID_CMD_LIST], win, NULL, LISTBROWSER_Labels, (ULONG) list, TAG_DONE);
}


void dmpSetPenColor(struct Window *win, uint32 pen)  /* 2.7 jjt */
{
  uint32 pos;
  struct Node *node;

  /* --- Set the current Pen List node's color to <pen> --- */
  if (pen < 29)
  {
    GetAttr(LISTBROWSER_Selected, PrefGadgets[GID_PENS_LIST], &pos);
    GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[GID_PENS_LIST], (ULONG *)(void *) &node);
    if (node)
    {
      SetGadgetAttrs(PrefGadgets[GID_PENS_LIST], win, NULL, LISTBROWSER_Labels, ~0, TAG_DONE);

      SetListBrowserNodeAttrs(node, LBNA_Column, 2, LBNCA_BGPen, pen, TAG_DONE);

      SetGadgetAttrs(PrefGadgets[GID_PENS_LIST], win, NULL, LISTBROWSER_Labels, (ULONG) &Pens_l, TAG_DONE);

      DMP_Modified[GID_PENS_LIST] = TRUE;
      if (pos > 3)
      {
        DMP_PensModified = TRUE;
      }
    }
  }
}


void dmpPenNode2Pal(struct Window *win)
{
  struct Node *node;

  /* --- Set palette index to the selected node's pen --- */

  GetAttr(LISTBROWSER_SelectedNode, PrefGadgets[GID_PENS_LIST], (ULONG *)(void *) &node);
  if (node)
  {
    GetListBrowserNodeAttrs(node, LBNA_Column, 2, LBNCA_BGPen, &ColorIdx, TAG_DONE);
    SetGadgetAttrs(PrefGadgets[GID_PALETTE], win, NULL, PALETTE_Colour, ColorIdx, TAG_DONE);
    SetGadgetAttrs(PrefGadgets[GID_COLORBOX], win, NULL, BUTTON_BackgroundPen, ColorIdx, TAG_END);
    SetGadgetAttrs(PrefGadgets[GID_COLORBOXIDX], win, NULL, INTEGER_Number, ColorIdx, TAG_END);
    setEditColor(win);

//    DMP_Help[GID_PENS_LIST].text = "Choose pen color (0-28) from palette";
    SetAttrs(statusbar, GA_Text, msgPrefsHelpChoosePen, TAG_DONE); /* 2.7b8 rri */
    RefreshGList(statusbar, win, NULL, 1);
  }
}

