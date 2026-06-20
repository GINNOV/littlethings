
/**
 **  ReAction Demonstration.
 **
 **  This is a port of the ClassActDemo to ReAction
 **
 **  original copyright message from the ClassActDemo:
 **  Copyright © 1995-1997 by Timothy Aston and Christopher Aldi
 **  All rights reserved.
 **
 **  This is a fairly comprehensive demo intended to show-off ReActions's
 **  capability, and also demonstrate to you, the programmer, how to use
 **  ReAction.
 **
 **  The demo takes place completely in a single window, made up of several
 **  pages. The entire GUI layout is done completely in a single Layout
 **  class gadget, that is made up of layout groups containing images and
 **  gadgets and other layout groups.  We create this layout first, then we
 **  create a window object and attach the layout to that.
 **
 **  A good idea would be to go through each of the gadgets created in this
 **  programme, load up its autodoc, and see how we've used the various
 **  features here in this demo.  Then feel free to change some things
 **  around and see what else you can do with ReAction, because this demo by
 **  no means shows off all that ReAction can do.
 **
 **/

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS

#include <reaction/reaction.h>
#include <clib/alib_protos.h>
#include <clib/reaction_lib_protos.h>

#include <intuition/icclass.h>
#include <libraries/gadtools.h>
#include <proto/diskfont.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/icon.h>
#include <proto/intuition.h>
#include <proto/utility.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Gadget IDs
 */
#define GAD_BACK 1
#define GAD_FORWARD 2
#define GAD_QUIT 3
#define GAD_GETFILE 4
#define GAD_GETFONT 5
#define GAD_GETSCREEN 6

#define NUM_PAGES 7

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *WindowBase;
struct Library *LayoutBase;
struct Library *BitMapBase;
struct Library *ButtonBase;
struct Library *CheckBoxBase;
struct Library *ChooserBase;
struct Library *ClickTabBase;
struct Library *FuelGaugeBase;
struct Library *GetFileBase;
struct Library *GetFontBase;
struct Library *GetScreenModeBase;
struct Library *IntegerBase;
struct Library *ListBrowserBase;
struct Library *PaletteBase;
struct Library *RadioButtonBase;
struct Library *ScrollerBase;
struct Library *SpaceBase;
struct Library *SpeedBarBase;
struct Library *StringBase;
struct Library *GlyphBase;
struct Library *LabelBase;
struct Library *IconBase;
struct UtilityBase *UtilityBase;

/* External variables, from Images.c
 */
extern struct Image picture_image, reaction_image;
extern struct Image sb_images[];
extern struct Image hide_image, show_image, leaf_image;

/* Global variables.
 */
struct Screen *screen = NULL;
struct Gadget *layout, *layout1, *page, *layout2;
struct Gadget *fuelgauge_gad, *integer_gad, *scroller_gad, *palette_gad, *lb_gad;
struct Gadget *getfile_gad, *getfont_gad, *getscreen_gad, *fontpreview_gad;
struct Gadget *back_gad, *forward_gad;
struct Image *limage;
struct List *radio_list, *chooser_list1, *chooser_list2, *chooser_list3, *tab_list;
struct List speedbar_list, lb_list1, lb_list2;

/* Some static string data used to initialize some gadgets.
 */

/* Integer to FuelGauge mapping.
 */
struct TagItem integer_map[] =
{
        { INTEGER_Number, FUELGAUGE_Level },
        { TAG_END }
};

/* GetFont to Button mapping.
 */
struct TagItem getfont_map[] =
{
        { GETFONT_TextAttr, GA_TextAttr },
        { GETFONT_FrontPen, BUTTON_TextPen },
        { GETFONT_BackPen, BUTTON_BackgroundPen },
        { GETFONT_SoftStyle, BUTTON_SoftStyle },
        { TAG_END }
};

/* SpeedBar help strings.  Also used in a ListBrowser.
 */
UBYTE *sbhelp_strs[] =
{
    "Erase block and copy it to the clipboard",
    "Copy block to the clipboard",
    "Paste from clipboard to your project",
    "Erase block",
    "Mail someone",
    "Insert current time",
    "Insert current date",
    "Disk",
    "Spray Paint",
    "Print project",
    NULL
};

/* ListBrowser column info.
 */
struct ColumnInfo ci1[] =
{
    { 20, NULL, 0 },
    { 80, NULL, 0 },
    { -1, (STRPTR)~0, -1 }
};

struct ColumnInfo ci2[] =
{
    { 100, "Column Header", 0 },
    { -1, (STRPTR)~0, -1 }
};

/* Some fonts that we'll be using.
 */
struct TextAttr helvetica15bu = { (STRPTR)"helvetica.font", 15, FSF_UNDERLINED | FSF_BOLD, FPF_DISKFONT };
struct TextAttr garnet16 = { (STRPTR)"garnet.font", 16, 0, FPF_DISKFONT };

/* Function prototypes.
 */
VOID set_mapping(struct Screen *, struct DrawInfo *, UWORD []);
LONG easy_req(struct Window *, char *, char *, char *, ...);
BOOL make_lb_list(struct List *, struct Image *, UBYTE **);
VOID make_fancy_list(struct Gadget *);
ULONG __saveds lb_hook(__reg("a0") struct Hook *hook, __reg("a2") struct Node *node,
                                                         __reg("a1") struct LBDrawMsg *msg);
BOOL make_speedbar_list(struct List *, struct Image *, UBYTE **);
VOID free_speedbar_list(struct List *);

void cleanexit(char *str);

/* This is the start of our program.
 */
int main(void)
{

    if ( ! (IntuitionBase = (struct IntuitionBase*)OpenLibrary("intuition.library",33)))
        cleanexit("Can't open intuition.library");

    if ( ! (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",39)))
        cleanexit("Can't open graphics.library");

    if ( ! (WindowBase = OpenLibrary("window.class",44)))
        cleanexit("Can't open window.class");

    if ( ! (LayoutBase = OpenLibrary("gadgets/layout.gadget",44)))
        cleanexit("Can't open layout.gadget");

    if ( ! (BitMapBase = OpenLibrary("images/bitmap.image",44)))
        cleanexit("Can't open bitmap.image");

    if ( ! (ButtonBase = OpenLibrary("gadgets/button.gadget",44)))
        cleanexit("Can't open button.gadget");

    if ( ! (CheckBoxBase = OpenLibrary("gadget/checkbox.gadget",44)))
        cleanexit("Can't open checkbox.gadget");

    if ( ! (ChooserBase = OpenLibrary("gadgets/chooser.gadget",44)))
        cleanexit("Can't open chooser.gadget");

    if ( ! (ClickTabBase = OpenLibrary("gadgets/clicktab.gadget",44)))
        cleanexit("Can't open clicktab.gadget");

    if ( ! (FuelGaugeBase = OpenLibrary("gadgets/fuelgauge.gadget",44)))
        cleanexit("Can't open fuelgauge.gadget");

    if ( ! (GetFileBase = OpenLibrary("gadgets/getfile.gadget",44)))
        cleanexit("Can't open getfile.gadget");

    if ( ! (GetFontBase = OpenLibrary("gadgets/getfont.gadget",44)))
        cleanexit("Can't open getfont.gadget");

    if ( ! (GetScreenModeBase = OpenLibrary("gadgets/getscreenmode.gadget",44)))
        cleanexit("Can't open getscreenmode.gadget");

    if ( ! (IntegerBase = OpenLibrary("gadgets/integer.gadget",44)))
        cleanexit("Can't open integer.gadget");

    if ( ! (ListBrowserBase = OpenLibrary("gadgets/listbrowser.gadget",44)))
        cleanexit("Can't open listbrowser.gadget");

    if ( ! (PaletteBase = OpenLibrary("gadgets/palette.gadget",44)))
        cleanexit("Can't open palette.gadget");

    if ( ! (RadioButtonBase = OpenLibrary("gadgets/radiobutton.gadget",44)))
        cleanexit("Can't open radiobutton.image");

    if ( ! (ScrollerBase = OpenLibrary("gadgets/scroller.gadget",44)))
        cleanexit("Can't open scroller.gadget");

    if ( ! (SpaceBase = OpenLibrary("gadgets/space.gadget",44)))
        cleanexit("Can't open space.gadget");

    if ( ! (SpeedBarBase = OpenLibrary("gadgets/speedbar.gadget",44)))
        cleanexit("Can't open speedbar.gadget");

    if ( ! (StringBase = OpenLibrary("gadgets/string.gadget",44)))
        cleanexit("Can't open string.gadget");

    if ( ! (GlyphBase = OpenLibrary("images/glyph.image",44)))
        cleanexit("Can't open glyph.image");

    if ( ! (LabelBase = OpenLibrary("images/label.image",44)))
        cleanexit("Can't open label.image");

    if ( ! (IconBase = OpenLibrary("icon.library",44)))
        cleanexit("Can't open icon.library");

    if ( ! (UtilityBase = (struct UtilityBase *) OpenLibrary("utility.library",33)))
        cleanexit("Can't open utility.library");

    /* We'll just open up on the default public screen, so we need to get
     * a lock on it.
     */
    if (screen = LockPubScreen(NULL))
    {
        struct DrawInfo *drinfo = GetScreenDrawInfo(screen);
        struct Image *l;
        UWORD mapping[8];

        /* Setup the pen mappings to use for our images.
         */
        set_mapping(screen, drinfo, mapping);

        /* Create a bunch of label lists that our various gadgets will
         * use.
         */
        make_speedbar_list(&speedbar_list, sb_images, sbhelp_strs);
        make_lb_list(&lb_list1, sb_images, sbhelp_strs);
        NewList(&lb_list2);

        if (layout = LayoutObject,
            GA_DrawInfo, drinfo,
            LAYOUT_DeferLayout, TRUE,       /* Layout refreshes done on
                                             * task's context (by the
                                             * window class) */
            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_BottomSpacing, 4,
            LAYOUT_HorizAlignment, LALIGN_RIGHT,
            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,

            LAYOUT_AddChild, LayoutObject,
                LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
                LAYOUT_AddChild, LayoutObject,
                    LAYOUT_BevelStyle, BVS_BUTTON,
                    LAYOUT_BevelState, IDS_SELECTED,
                    LAYOUT_VertAlignment, LALIGN_CENTRE,
                    LAYOUT_HorizAlignment, LALIGN_CENTRE,
                    LAYOUT_SpaceOuter, TRUE,

                    /* This is a simple Label class image with a mapping.
                     */
                    LAYOUT_AddImage, l = LabelObject,
                        LABEL_Justification, LABEL_CENTRE,
                        LABEL_Mapping, mapping,
                        LABEL_Image, &picture_image,
                    LabelEnd,
                    CHILD_WeightedWidth, 0,
                    CHILD_WeightedHeight, 0,

                LayoutEnd,
                CHILD_WeightedWidth, 0,

                LAYOUT_AddChild, layout1 = LayoutObject,
                    LAYOUT_LeftSpacing, 4,
                    LAYOUT_RightSpacing, 4,
                    LAYOUT_TopSpacing, 2,
                    LAYOUT_BottomSpacing, 2,
                    LAYOUT_BevelStyle, BVS_GROUP,

                    /* All the cool stuff in this demo appears
                     * on different pages that we can flip
                     * through via some buttons at the bottom
                     * of the window.
                     */
                    LAYOUT_AddChild, page = PageObject,
                        /* The first page, showing our nifty
                         * logo.  This is a single label image,
                         * notice how you can seemlessly mix
                         * text and images, and also do pen
                         * re-mapping.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,

                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "Welcome to the ReAction Demo\n",
                                LABEL_Mapping, mapping,
                                LABEL_Image, &reaction_image,
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,
                        LayoutEnd,

                        /* A credits page, made up of a single
                         * label image.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,

                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "Welcome to the ReAction Demo\n",
                                IA_Font, screen->Font,
                                LABEL_Text, "\nClassactDemo written by Timothy Aston\n",
                                LABEL_Text, "ReAction port by Matthias Rustler",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,
                        LayoutEnd,

                        /* The Button gadget class is so
                         * versatile, might as well dedicate
                         * an entire page to it.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,

                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "ReAction has buttons!",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,

                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_AddChild, ButtonObject,
                                    GA_Text, "_Simple",
                                    GA_RelVerify, TRUE,
                                ButtonEnd,

                                LAYOUT_AddChild, ButtonObject,
                                    GA_Text, "Push Button",
                                    GA_RelVerify, TRUE,
                                    BUTTON_PushButton, TRUE,
                                ButtonEnd,

                                LAYOUT_AddChild, ButtonObject,
                                    GA_Text, "Colour",
                                    GA_RelVerify, TRUE,
                                    BUTTON_BackgroundPen, 7,
                                    BUTTON_TextPen, 2,
                                ButtonEnd,
                            LayoutEnd,

                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_AddChild, ButtonObject,
                                    GA_Text, "B_old",
                                    GA_RelVerify, TRUE,
                                    BUTTON_SoftStyle, FSF_BOLD,
                                ButtonEnd,

                                LAYOUT_AddChild, ButtonObject,
                                    GA_Text, "Read-Only",
                                    GA_RelVerify, TRUE,
                                    GA_ReadOnly, TRUE,
                                ButtonEnd,

                                LAYOUT_AddChild, ButtonObject,
                                    GA_Text, "_Right aligned",
                                    GA_RelVerify, TRUE,
                                    BUTTON_Justification, BCJ_RIGHT,
                                ButtonEnd,

                            LayoutEnd,

                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_AddChild, ButtonObject,
                                    GA_TextAttr, &garnet16,
                                    GA_Text, "B_ig Button, different font",
                                    GA_RelVerify, TRUE,
                                ButtonEnd,
                            LayoutEnd,

                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_VertAlignment, LALIGN_CENTRE,

                                LAYOUT_AddChild, ButtonObject,
                                    BUTTON_AutoButton, BAG_POPFILE,
                                    GA_RelVerify, TRUE,
                                ButtonEnd,
                                CHILD_WeightedWidth, 0,
                                CHILD_WeightedHeight, 0,
                                CHILD_Label, LabelObject,
                                    LABEL_Text, "Get Fi_le",
                                LabelEnd,
                                LAYOUT_AddChild, ButtonObject,
                                    BUTTON_AutoButton, BAG_POPDRAWER,
                                    GA_RelVerify, TRUE,
                                ButtonEnd,
                                CHILD_WeightedWidth, 0,
                                CHILD_WeightedHeight, 0,
                                CHILD_Label, LabelObject,
                                    LABEL_Text, "Get _Drawer",
                                LabelEnd,
                                LAYOUT_AddChild, ButtonObject,
                                    BUTTON_AutoButton, BAG_POPFONT,
                                    GA_RelVerify, TRUE,
                                ButtonEnd,
                                CHILD_WeightedWidth, 0,
                                CHILD_WeightedHeight, 0,
                                CHILD_Label, LabelObject,
                                    LABEL_Text, "Fo_nt",
                                LabelEnd,

                                LAYOUT_AddChild, ButtonObject,
                                    BUTTON_AutoButton, BAG_POPTIME,
                                    GA_RelVerify, TRUE,
                                ButtonEnd,
                                CHILD_WeightedWidth, 0,
                                CHILD_WeightedHeight, 0,
                                CHILD_Label, LabelObject,
                                    LABEL_Text, "_Time",
                                LabelEnd,
                            LayoutEnd,
                        LayoutEnd,

                        /* Our next page shows some gadgets
                         * that are basically just direct
                         * replacements for GadTools gadget
                         * kinds.  Don't be fooled though, even
                         * though they may look similar, we've
                         * made several useful enhancements.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,

                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "GadTools Replacements",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,

                            LAYOUT_AddChild, PaletteObject,
                                GA_RelVerify, TRUE,
                                PALETTE_NumColours, 1 << screen->RastPort.BitMap->Depth,
                            PaletteEnd,
                            CHILD_MinWidth, 40,
                            CHILD_MinHeight, 20,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "_Palette",
                            LabelEnd,

                            LAYOUT_AddChild, scroller_gad = ScrollerObject,
                                GA_RelVerify, TRUE,
                                SCROLLER_Top, 0,
                                SCROLLER_Total, 90,
                                SCROLLER_Visible, 10,
                                SCROLLER_Orientation, FREEHORIZ,
                            ScrollerEnd,
                            CHILD_MinHeight, 14,
                            CHILD_WeightedHeight, 0,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "_Scroller",
                            LabelEnd,

                            LAYOUT_AddChild, StringObject,
                                GA_RelVerify, TRUE,
                                STRINGA_MaxChars, 40,
                                STRINGA_TextVal, "ReAction is just soooooo cool",
                            StringEnd,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "S_tring",
                            LabelEnd,

                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_AddChild, RadioButtonObject,
                                    GA_RelVerify, TRUE,
                                    GA_DrawInfo, drinfo,
                                    RADIOBUTTON_Labels, radio_list = RadioButtons("ReAction radio buttons",
                                            "support strumming.",
                                            "Click & Drag over buttons!",
                                            NULL),
                                    RADIOBUTTON_Spacing, 2,
                                RadioButtonEnd,
                                LAYOUT_AddChild, CheckBoxObject,
                                    GA_RelVerify, TRUE,
                                    GA_Text, "_Click the label",
                                    CHECKBOX_TextPlace, PLACETEXT_RIGHT,
                                CheckBoxEnd,
                            LayoutEnd,
                            CHILD_WeightedHeight, 0,
                        LayoutEnd,

                        /* This page is a little more
                         * interesting, it contains some of the
                         * cooler classes like the fuelgauge,
                         * chooser and speedbar.  We also have
                         * an Integer class gadget, showing off
                         * our innovative arrow buttons.  This
                         * gadget is connected to the fuelgauge
                         * via a simple mapping.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,
                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "New and Improved!\n",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,
                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_SpaceOuter, FALSE,
                                LAYOUT_AddChild, fuelgauge_gad = FuelGaugeObject,
                                    FUELGAUGE_Orientation, FGORIENT_HORIZ,
                                    FUELGAUGE_Percent, TRUE,
                                    FUELGAUGE_Min, 0,
                                    FUELGAUGE_Max, 100,
                                    FUELGAUGE_Level, 20,
                                    FUELGAUGE_Ticks, 10,
                                    FUELGAUGE_TickSize, 4,
                                    FUELGAUGE_ShortTicks, TRUE,
                                FuelGaugeEnd,
                                CHILD_WeightedHeight, 0,
                                CHILD_Label, LabelObject,
                                    LABEL_DrawInfo, drinfo,
                                    LABEL_Text, "Interconnected:",
                                LabelEnd,
                            LayoutEnd,
                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_SpaceOuter, FALSE,
                                LAYOUT_AddChild, integer_gad =IntegerObject,
                                    GA_RelVerify, TRUE,
                                    INTEGER_MaxChars, 3,
                                    INTEGER_Minimum, 0,
                                    INTEGER_Maximum, 100,
                                    INTEGER_Number, 20,
                                    INTEGER_MinVisible, 5,
/*
   Surprise, surprise. After I moved ICA_TAGET outside the gadget creation ,
   the interconnection works again
*/
                                    ICA_MAP, integer_map,
                                IntegerEnd,
                                CHILD_WeightedHeight, 0,
                                CHILD_WeightedWidth, 0,
                                CHILD_Label, LabelObject,
                                    LABEL_DrawInfo, drinfo,
                                    LABEL_Text, "_Look, arrows! (Range: 0...100):",
                                LabelEnd,
                            LayoutEnd,
                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_AddChild, ChooserObject,
                                    GA_RelVerify, TRUE,
                                    CHOOSER_Labels, chooser_list1 = ChooserLabels(  "A PopUp gadget",
                                        "from the Chooser",
                                        "gadget class.",
                                        "Good for allowing",
                                        "the user to",
                                        "select a state",
                                        "or mode.",
                                        NULL),
                                    CHOOSER_PopUp, TRUE,
                                    CHOOSER_AutoFit, TRUE,
                                ChooserEnd,
                                LAYOUT_AddChild, ChooserObject,
                                    GA_RelVerify, TRUE,
                                    CHOOSER_Labels, chooser_list2 = ChooserLabels("A DropDown",
                                        "gadget from",
                                        "the Chooser",
                                        "gadget class.",
                                        "Good for",
                                        "allowing the",
                                        "user to",
                                        "select actions",
                                        NULL),
                                    CHOOSER_DropDown, TRUE,
                                    CHOOSER_Title, "Drop-Down",
                                    CHOOSER_AutoFit, FALSE,
                                ChooserEnd,
                                LAYOUT_AddChild, ChooserObject,
                                    GA_RelVerify, TRUE,
                                    CHOOSER_Labels, chooser_list3 = ChooserLabels("A thin Chooser.",
                                        "Use this in",
                                        "conjunction with",
                                        "a string gadget.",
                                        NULL),
                                    CHOOSER_DropDown, TRUE,
                                    CHOOSER_AutoFit, TRUE,
                                ChooserEnd,
                                CHILD_MinWidth, 20,
                                CHILD_WeightedWidth, 0,
                            LayoutEnd,
                            CHILD_WeightedWidth, 0,
                            LAYOUT_AddChild, SpeedBarObject,
                                GA_RelVerify, TRUE,
                                SPEEDBAR_Orientation, SBORIENT_HORIZ,
                                SPEEDBAR_Buttons, &speedbar_list,
                                SPEEDBAR_Background, mapping[4],
                                SPEEDBAR_StrumBar, FALSE,
                            SpeedBarEnd,
                            CHILD_WeightedHeight, 0,
                            LAYOUT_AddChild, ClickTabObject,
                                GA_RelVerify, TRUE,
                                CLICKTAB_Labels, tab_list = ClickTabs("Tabs", "For",
                                "Pages", "Etc.", NULL),
                                CLICKTAB_Current, 0L,
                            ClickTabEnd,
                            CHILD_WeightedHeight, 0,
                        LayoutEnd,
                        CHILD_WeightedWidth, 0,

                        /* One of the most powerful classes
                         * we've done is the ListBrowser.  The
                         * first object is a simple multi-
                         * column list showing images and text,
                         * as well as editable nodes.  The 2nd
                         * object is intended to demonstrate
                         * some of the numerous node attributes.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,
                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "Look what ListBrowser can do!\n",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,
                            LAYOUT_AddChild, LayoutObject,
                                LAYOUT_AddChild, ListBrowserObject,
                                    GA_RelVerify, TRUE,
                                    LISTBROWSER_Labels, (ULONG)&lb_list1,
                                    LISTBROWSER_ColumnInfo, &ci1,
                                    LISTBROWSER_AutoFit, TRUE,
                                    LISTBROWSER_MultiSelect, TRUE,
                                    LISTBROWSER_ShowSelected, TRUE,
                                    LISTBROWSER_Separators, TRUE,
                                    LISTBROWSER_Editable, TRUE,
                                    LISTBROWSER_Spacing, 1,
                                ListBrowserEnd,
                                LAYOUT_AddChild, lb_gad = ListBrowserObject,
                                    GA_RelVerify, TRUE,
                                    LISTBROWSER_Labels, &lb_list2,
                                    LISTBROWSER_ColumnInfo, &ci2,
                                    LISTBROWSER_ColumnTitles, TRUE,
                                    LISTBROWSER_Separators, TRUE,
                                    LISTBROWSER_Hierarchical, TRUE,
                                    LISTBROWSER_Editable, TRUE,
                                    LISTBROWSER_MultiSelect, TRUE,
                                    LISTBROWSER_ShowSelected, TRUE,
                                ListBrowserEnd,
                            LayoutEnd,
                        LayoutEnd,

                        /* Our second ListBrowser page shows
                         * the powerful hierarchical mode of
                         * ListBrowser.  The two gadgets
                         * contain identical lists, but the
                         * left-hand gadget shows the default
                         * hide/show images while the right-
                         * hand ones shows some custom images.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,
                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "Get File/Font/Screen Mode\n",
                                IA_Font, screen->Font,
                                LABEL_Text, "ASL has never been this easy",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,
                            LAYOUT_AddChild, getfile_gad = GetFileObject,
                                GA_ID, GAD_GETFILE,
                                GA_RelVerify, TRUE,
                                GETFILE_TitleText, "Select a File",
                                GETFILE_ReadOnly, FALSE,
                            End,
                            CHILD_WeightedHeight, 0,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "File:",
                            LabelEnd,
                            LAYOUT_AddChild, getfont_gad = GetFontObject,
                                GA_ID, GAD_GETFONT,
                                GA_RelVerify, TRUE,
                                GETFONT_TitleText, "Select a Font",
                                GETFONT_DoStyle, TRUE,
                                GETFONT_DoFrontPen, TRUE,
                                GETFONT_DoBackPen, TRUE,
                                ICA_MAP, getfont_map,
                            End,
                            CHILD_WeightedHeight, 0,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "Font:",
                            LabelEnd,
                            LAYOUT_AddChild, fontpreview_gad = ButtonObject,
                                GA_ReadOnly, TRUE,
                                GA_Text, "123 AcBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz!@#$%^&*()",
                                BUTTON_DomainString, "Text",
                            ButtonEnd,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "Preview:",
                            LabelEnd,
                            LAYOUT_AddChild, getscreen_gad = GetScreenModeObject,
                                GA_ID, GAD_GETSCREEN,
                                GA_RelVerify, TRUE,
                                GETSCREENMODE_TitleText, "Select a Screen Mode",
                                GETSCREENMODE_DoWidth, TRUE,
                                GETSCREENMODE_DoHeight, TRUE,
                                GETSCREENMODE_DoDepth, TRUE,
                                GETSCREENMODE_MinWidth, 500,
                                GETSCREENMODE_MinHeight, 180,
                            End,
                            CHILD_WeightedHeight, 0,
                            CHILD_Label, LabelObject,
                                LABEL_Text, "Screen Mode:",
                            LabelEnd,
                        LayoutEnd,

                        /* This is the last page, just the
                         * credits, again as a single label
                         * gadget.
                         */
                        PAGE_Add, LayoutObject,
                            LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                            LAYOUT_VertAlignment, LALIGN_CENTRE,
                            LAYOUT_HorizAlignment, LALIGN_CENTRE,
                            LAYOUT_AddImage, l = LabelObject,
                                LABEL_DrawInfo, drinfo,
                                IA_Font, &helvetica15bu,
                                LABEL_Justification, LABEL_CENTRE,
                                LABEL_Text, "Use ReAction Now!\n",
                                IA_Font, screen->Font,
                                LABEL_Text, "\nA standardized font sensitive\n",
                                LABEL_Text, "GUI system is a good thing",
                            LabelEnd,
                            CHILD_WeightedWidth, 0,
                            CHILD_WeightedHeight, 0,
                        LayoutEnd,
                    LayoutEnd,
                PageEnd,
            LayoutEnd,

            /* These are the gadgets that appear at the
            * bottom of the window for changing pages.
            */
            LAYOUT_AddChild, layout2 = LayoutObject,
                LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
                LAYOUT_EvenSize, TRUE,
                LAYOUT_HorizAlignment, LALIGN_RIGHT,
                LAYOUT_SpaceInner, FALSE,
                LAYOUT_AddChild, SpaceObject,
                SpaceEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,
                LAYOUT_AddChild, SpaceObject,
                SpaceEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,
                LAYOUT_AddChild, back_gad = ButtonObject,
                    GA_ID, GAD_BACK,
                    GA_Text, "< _Back",
                    GA_RelVerify, TRUE,
                    GA_Disabled, TRUE,
                ButtonEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,
                LAYOUT_AddChild, forward_gad = ButtonObject,
                    GA_ID, GAD_FORWARD,
                    GA_Text, "_Forward >",
                    GA_RelVerify, TRUE,
                ButtonEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,
                LAYOUT_AddChild, SpaceObject,
                SpaceEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,
                LAYOUT_AddChild, ButtonObject,
                    GA_ID, GAD_QUIT,
                    GA_Text, "Quit",
                    GA_RelVerify, TRUE,
                ButtonEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,
            LayoutEnd,
            CHILD_WeightedWidth, 0,
            CHILD_WeightedHeight, 0,
        LayoutEnd)
        {
            struct MsgPort *app_port;
            Object *window_obj;

            /* Connect the GetFont gadget to the font preview button.
             */
            SetAttrs(getfont_gad,
                ICA_TARGET, fontpreview_gad,
                TAG_DONE);

            SetAttrs(integer_gad,
                ICA_TARGET, fuelgauge_gad,
                TAG_DONE);

            /* Make the fancy ListBrowserList.
             */
            make_fancy_list(lb_gad);

            /* Create a message port for App* messages.  This is needed for
             * iconification.  We're being a touch naughty by not checking
             * the return code, but that just means that iconification won't
             * work, nothing really bad will happen.
             */
            app_port = CreateMsgPort();

            /* Create the window object.
             */
            if (window_obj = WindowObject,
                WA_Left, 0,
                WA_Top, screen->Font->ta_YSize + 3,
                WA_CustomScreen, screen,
                WA_IDCMP, IDCMP_CLOSEWINDOW,
                WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH,
                WA_Title, "ReAction Demonstration",
                WINDOW_ParentGroup, layout,
                WINDOW_IconifyGadget, TRUE,
                WINDOW_Icon, GetDiskObject("PROGDIR:ReAction"),
                WINDOW_IconTitle, "ReAction Demo",
                WINDOW_AppPort, app_port,
            EndWindow)
            {
                struct Window *win;

                /*  Open the window.
                 */
                if (win = (struct Window *)RA_OpenWindow(window_obj))
                {
                    ULONG signal;
                    BOOL ok = TRUE;

                    /* Obtain the window wait signal mask.
                     */
                    GetAttr(WINDOW_SigMask, window_obj, &signal);

                    /* Input Event Loop
                     */
                    while (ok)
                    {
                        ULONG result;

                        Wait(signal | (1L << app_port->mp_SigBit));

                        /* CA_HandleInput() returns the gadget ID of a clicked
                         * gadget, or one of several pre-defined values.  For
                         * this demo, we're only actually interested in a
                         * close window and a couple of gadget clicks.
                         */
                        while ((result = RA_HandleInput(window_obj, NULL)) != WMHI_LASTMSG)
                        {
                            ULONG current_page;

                            switch(result & WMHI_CLASSMASK)
                            {
                                case WMHI_CLOSEWINDOW:
                                    ok = FALSE;
                                    break;

                                case WMHI_GADGETUP:
                                    switch (result & WMHI_GADGETMASK)
                                    {
                                        case GAD_FORWARD:
                                            GetAttr(PAGE_Current, page, &current_page);
                                            if (current_page < NUM_PAGES)
                                            {
                                                if (current_page == 0)
                                                    if (SetGadgetAttrs(back_gad, win, NULL, GA_Disabled, FALSE, TAG_DONE))
                                                        RefreshGList(layout2, win, NULL, 1);
        
                                                current_page++;
        
                                                if (current_page == NUM_PAGES)
                                                    if (SetGadgetAttrs(forward_gad, win, NULL, GA_Disabled, TRUE, TAG_DONE))
                                                        RefreshGList(layout2, win, NULL, 1);
        
                                                SetGadgetAttrs(page, win, NULL, PAGE_Current, current_page, TAG_DONE);
                                                RethinkLayout(layout1, win, NULL, TRUE);
                                            }
                                            break;

                                        case GAD_GETFILE:
                                            DoMethod((Object *)getfile_gad , GFILE_REQUEST , win);
                                            break;

                                        case GAD_GETFONT:
                                            DoMethod((Object *)getfont_gad , GFONT_REQUEST , win);
                                            break;

                                        case GAD_GETSCREEN:
                                            RequestScreenMode((Object *)getscreen_gad, win);
                                            break;

                                        case GAD_BACK:
                                            GetAttr(PAGE_Current, page, &current_page);
                                            if (current_page > 0)
                                            {
                                                if (current_page == NUM_PAGES)
                                                    if (SetGadgetAttrs(forward_gad, win, NULL, GA_Disabled, FALSE, TAG_DONE))
                                                        RefreshGList(layout2, win, NULL, 1);
        
                                                current_page--;
        
                                                if (current_page == 0)
                                                    if (SetGadgetAttrs(back_gad, win, NULL, GA_Disabled, TRUE, TAG_DONE))
                                                        RefreshGList(layout2, win, NULL, 1);
        
                                                SetGadgetAttrs(page, win, NULL, PAGE_Current, current_page, TAG_DONE);
                                                RethinkLayout(layout1, win, NULL, TRUE);
                                            }
                                            break;

                                        case GAD_QUIT:
                                            ok = FALSE;
                                            break;

                                        default:
                                            break;
                                    }
                                    break;
                                                        
                                case WMHI_ICONIFY:
                                    if (RA_Iconify(window_obj)) win = NULL;
                                    break;
                                                         
                                case WMHI_UNICONIFY:
                                    win = RA_OpenWindow(window_obj);
                                    break;

                                default:
                                    break;
                            }
                        }
                    }

                    /* Disposing of the window object will also close the
                     * window if it is already opened and it will dispose of
                     * all objects attached to it.
                     */
                    DisposeObject(window_obj);
                }
                else
                    easy_req(NULL, "Demo failed to start\nCouldn't open window", "Quit", "");

                        /* Lose the App* message port.
                         */
                if (app_port) DeleteMsgPort(app_port);
            }
            else
            {
                easy_req(NULL, "Demo failed to start\nCouldn't create window object", "Quit", "");
                DisposeObject(layout);
            }
        }
        else
            easy_req(NULL, "Demo failed to start\nCouldn't create layout", "Quit", "");

        /* Free the lists.
         */
        if (radio_list)
                FreeRadioButtons(radio_list);
        if (chooser_list1)
                FreeChooserLabels(chooser_list1);
        if (chooser_list2)
                FreeChooserLabels(chooser_list2);
        if (chooser_list3)
                FreeChooserLabels(chooser_list3);
        if (tab_list)
                FreeClickTabs(tab_list);

        free_speedbar_list(&speedbar_list);

        FreeListBrowserList(&lb_list1);
        FreeListBrowserList(&lb_list2);
        DisposeObject(limage);

        if (screen->RastPort.BitMap->Depth > 2)
        {
            ReleasePen(screen->ViewPort.ColorMap, mapping[4]);
            ReleasePen(screen->ViewPort.ColorMap, mapping[5]);
            ReleasePen(screen->ViewPort.ColorMap, mapping[7]);
        }

        UnlockPubScreen(0, screen);
    }
    else
            easy_req(NULL, "Demo failed to start\nCouldn't lock destination screen", "Quit", "");

    cleanexit(NULL);
}


/* Set the mapping array for a screen.  This creates an 8 colour mapping
 * that should closely match the style of 8-colour palette that has become
 * more or less conventional:
 *     pen 0 - medium grayish tone
 *     pen 1 - black
 *     pen 2 - white
 *     pen 3 - an arbitrary colour
 *     pen 4 - darker tone of pen 0
 *     pen 5 - lighter tone of pen 0
 *     pen 6,7 - some nice colours.
 * You can be reasonably sure that this routine will setup a mapping that
 * will make images designed for this style of palette look OK.
 *
 * This should probably lock the pen it eventually chooses, and maybe try to
 * allocate a pen if it can't find anything close enough.
 */
VOID set_mapping(struct Screen *screen, struct DrawInfo *drinfo, UWORD image_mapping[])
{
    /* Setup the image remapping.
     */
    image_mapping[0] = drinfo->dri_Pens[BACKGROUNDPEN];
    image_mapping[1] = drinfo->dri_Pens[SHADOWPEN];
    image_mapping[2] = drinfo->dri_Pens[SHINEPEN];
    image_mapping[3] = drinfo->dri_Pens[FILLPEN];

    if (screen->RastPort.BitMap->Depth > 2)
    {
        struct ColorMap *colourmap = screen->ViewPort.ColorMap;
        ULONG bg[3];

        GetRGB32(colourmap, drinfo->dri_Pens[BACKGROUNDPEN], 1, bg);
        image_mapping[4] = ObtainBestPen(colourmap, bg[0] - 0x22222222, bg[1] - 0x22222222, bg[2] - 0x22222222,
            OBP_Precision, PRECISION_GUI);
        image_mapping[5] = ObtainBestPen(colourmap, bg[0] + 0x22222222, bg[1] + 0x22222222, bg[2] + 0x22222222,
            OBP_Precision, PRECISION_GUI);
        image_mapping[7] = ObtainBestPen(colourmap, 0xeeeeeeee, 0x22222222, 0x22222222,
            OBP_Precision, PRECISION_GUI);
    }
    else
    {
        image_mapping[4] = image_mapping[5] = drinfo->dri_Pens[BACKGROUNDPEN];
        image_mapping[6] = image_mapping[7] = drinfo->dri_Pens[FILLPEN];
    }
}

/* Do an easy requester.
 */
LONG easy_req(struct Window *win, char *reqtext, char *reqgads, char *reqargs, ...)
{
    struct EasyStruct general_es =
    {
        sizeof(struct EasyStruct),
        0,
        "Demo",
        NULL,
        NULL
    };

    general_es.es_TextFormat = reqtext;
    general_es.es_GadgetFormat = reqgads;

    return(EasyRequestArgs(win, &general_es, NULL, &reqargs));
}


/* Function to make an Exec List of ListBrowserNodes from an array of images
 * and an array of strings.
 */
BOOL make_lb_list(struct List *list, struct Image *images, UBYTE **strs)
{
    struct Node *node;
    WORD i = 0;

    NewList(list);

    while (i < 10)
    {
        if (node = AllocListBrowserNode(2,
            LBNA_Column, 0,
                LBNCA_Image, images,
                LBNCA_Justification, LCJ_CENTRE,
            LBNA_Column, 1,
                LBNCA_CopyText, TRUE,
                LBNCA_Text, *strs,
                LBNCA_Editable, TRUE,
                LBNCA_MaxChars, 60,
            TAG_DONE))
        {
            AddTail(list, node);
        }
        else
            break;

        images++;
        strs++;
        i++;
    }
    return(TRUE);
}


/* Make a fairly fancy list.  We've taken a different approach here, this
 * time using ListBrowser methods to create the list items AFTER the object
 * has been created.
 */
VOID make_fancy_list(struct Gadget *lb_gad)
{
    struct Image *gimage;
    static struct Hook lbhook;

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Demo of ListBrowserNode features",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Editable node",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Click twice to edit",
            LBNCA_Editable, TRUE,
            LBNCA_MaxChars, 60,
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Change colours",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Flags, LBFLG_CUSTOMPENS,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Colourful!",
            LBNCA_FGPen, 19,
            LBNCA_BGPen, 18,
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Checkbox item",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_CheckBox, TRUE,
        LBNA_Checked, TRUE,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Checked by default",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_CheckBox, TRUE,
        LBNA_Checked, FALSE,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Unchecked by default",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Justifications",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Left",
            LBNCA_Justification, LCJ_LEFT,
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Centre",
            LBNCA_Justification, LCJ_CENTRE,
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Right",
            LBNCA_Justification, LCJ_RIGHT,
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Read-Only node",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Flags, LBFLG_READONLY,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Can't select me!",
        TAG_DONE);

    gimage = GlyphObject,
        IA_Width, 20,
        IA_Height, 20,
        GLYPH_Glyph, GLYPH_POPTIME,
        GlyphEnd;

    limage = LabelObject,
        IA_Font, &garnet16,
        LABEL_Text, "Created using\n_label.image\n",
        IA_Font, screen->Font,
        LABEL_SoftStyle, FSF_BOLD | FSF_ITALIC,
        LABEL_DisposeImage, TRUE,
        LABEL_Image, gimage,
        IA_FGPen, 35,
        LABEL_Text, " Cool eh?",
        LabelEnd;

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Some images",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Column, 0,
            LBNCA_Image, limage,
        TAG_DONE);

    lbhook.h_Entry = (ULONG (*)())lb_hook;
    lbhook.h_SubEntry = NULL;
    lbhook.h_Data = NULL;

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 1,
        LBNA_Flags, LBFLG_HASCHILDREN | LBFLG_SHOWCHILDREN,
        LBNA_Column, 0,
            LBNCA_CopyText, TRUE,
            LBNCA_Text, "Rendering hook",
        TAG_DONE);

    LBAddNode(lb_gad, NULL, NULL, (struct Node *)~0,
        LBNA_Generation, 2,
        LBNA_Column, 0,
            LBNCA_RenderHook, &lbhook,
            LBNCA_HookHeight, 20,
        TAG_DONE);
}

/* Hook for our fancy list.  This just renders an ellipse.
 */
ULONG __saveds lb_hook(__reg("a0") struct Hook *hook, __reg("a2") struct Node *node,
                                                         __reg("a1") struct LBDrawMsg *msg)
{
    WORD width = msg->lbdm_Bounds.MaxX - msg->lbdm_Bounds.MinX;
    WORD height = msg->lbdm_Bounds.MaxY - msg->lbdm_Bounds.MinY;

    if(msg->lbdm_MethodID != LV_DRAW)
        return(LBCB_UNKNOWN);

        SetAPen(msg->lbdm_RastPort, 69);
        DrawEllipse(msg->lbdm_RastPort,
                msg->lbdm_Bounds.MinX + (width / 2), msg->lbdm_Bounds.MinY + (height / 2),
                width / 2, height / 2);
                
    return(LVCB_OK);
}

/* Create the SpeedBar list from an array of images, creating help texts
 * for each button from a string array.
 */
BOOL make_speedbar_list(struct List *list, struct Image *images, UBYTE **help)
{
    struct Node *node;
    WORD i = 0;

    NewList(list);

    while (i < 10)
    {
        if (node = AllocSpeedButtonNode(i,
            SBNA_Image, images,
            SBNA_Top, 2,
            SBNA_Left, 0,
            SBNA_Help, *help,
            SBNA_Enabled, TRUE,
            SBNA_Spacing, 2,
            SBNA_Highlight, SBH_RECESS,
            TAG_DONE))
            {
                AddTail(list, node);
            }
            else
                puts("Allocation failed\n");

        images++;
        help++;
        i++;
    }
    return(TRUE);
}

/* Function to free a SpeedBar Exec List.
 */
VOID free_speedbar_list(struct List *list)
{
    struct Node *node, *nextnode;

    node = list->lh_Head;
    while (nextnode = node->ln_Succ)
    {
        FreeSpeedButtonNode(node);
        node = nextnode;
    }
    NewList(list);
}

void cleanexit(char *str)
{
    if (str) printf("Error: %s\n",str);

    CloseLibrary( (struct Library *) IntuitionBase);
    CloseLibrary( (struct Library *) GfxBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(BitMapBase);
    CloseLibrary(ButtonBase);
    CloseLibrary(CheckBoxBase);
    CloseLibrary(ChooserBase);
    CloseLibrary(ClickTabBase);
    CloseLibrary(FuelGaugeBase);
    CloseLibrary(GetFileBase);
    CloseLibrary(GetFontBase);
    CloseLibrary(GetScreenModeBase);
    CloseLibrary(IntegerBase);
    CloseLibrary(ListBrowserBase);
    CloseLibrary(PaletteBase);
    CloseLibrary(RadioButtonBase);
    CloseLibrary(ScrollerBase);
    CloseLibrary(SpaceBase);
    CloseLibrary(SpeedBarBase);
    CloseLibrary(StringBase);
    CloseLibrary(GlyphBase);
    CloseLibrary(LabelBase);
    CloseLibrary(IconBase);
    CloseLibrary( (struct Library *) UtilityBase);

    exit(0);
}

