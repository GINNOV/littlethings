#ifndef LIBRARIES_WIZARD_H
#define LIBRARIES_WIZARD_H

/*
**  $VER: wizard.h 40.0 (24.03.98)
**
**  © 1996-1998 HAAGE & PARTNER,  All Rights Reserved
**
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef LIBRARIES_GADTOOLS_H
#include <libraries/gadtools.h>
#endif

#define WIZARDNAME "wizard.library"

/*
** WizardInfo
**
** every wizard gadget gets a WizardInfo structure in its SpecialInfo
** pointer. This structure is read-only!
*/

struct WizardInfo
{
    ULONG Flags;
    APTR LayoutInfo;
};

#define WZF_Active               0x0001 /* unset: gadget is hidden */
#define WZF_Intermediate         0x0002 /* set: gadget knows intermediate mode */
#define WZF_IsIntermediate       0x0004 /* set: gadget is in intermediate state */
#define WZF_MinWidthValid        0x0008 /* set: MinWidth value is valid */
#define WZF_MinHeightValid       0x0010 /* set: MinHeight value is valid */
#define WZF_DisplaySelected      0x0020 /* set: current display state is SELECTED */
#define WZF_DisplayIndeterminate 0x0040 /* set: current display state is INDETERMINATE */
#define WZF_DisplayDisabled      0x0080 /* set: current display state is DISABLED */
#define WZF_NewDisableLook       0x0100 /* set: new disable look */

/*
** Pens
**
**
*/
#define WZRD_TEXTPEN          0x8002
#define WZRD_SHINEPEN         0x8003
#define WZRD_SHADOWPEN        0x8004
#define WZRD_FILLPEN          0x8005
#define WZRD_FILLTEXTPEN      0x8006
#define WZRD_BACKGROUNDPEN    0x8007
#define WZRD_HIGHLIGHTTEXTPEN 0x8008
#define WZRD_BARDETAILPEN     0x8009
#define WZRD_BARBLOCKPEN      0x800A
#define WZRD_BARTRIMPEN       0x800B

#define WZRD_HALFSHINEPEN     0x8100
#define WZRD_HALFSHADOWPEN    0x8101
#define WZRD_BLACKPEN         0x8102
#define WZRD_DARKGRAYPEN      0x8103
#define WZRD_MIDGRAYPEN       0x8104
#define WZRD_LIGHTGRAYPEN     0x8105
#define WZRD_WHITEPEN         0x8106

/*
** Frames
**
**
*/
#define WZRDFRAME_NONE        0
#define WZRDFRAME_ICON        1
#define WZRDFRAME_BUTTON      2
#define WZRDFRAME_STRING      3
#define WZRDFRAME_DOUBLEICON  4
#define WZRDFRAME_SICON       5
#define WZRDFRAME_SBUTTON     6
#define WZRDFRAME_SSTRING     7
#define WZRDFRAME_SDOUBLEICON 8

/*
** Label Adjustment and Placement
*/

#define WZRDPLACE_LEFT        0x01
#define WZRDPLACE_RIGHT       0x02
#define WZRDPLACE_CENTER      0x10

#define WZRDLABEL_INNER       0
#define WZRDLABEL_TOP         1
#define WZRDLABEL_BOTTOM      2
#define WZRDLABEL_LEFT        3
#define WZRDLABEL_RIGHT       4

#define WARROW_LEFT           0
#define WARROW_RIGHT          1
#define WARROW_UP             2
#define WARROW_DOWN           3

#define WGLYPH_NONE          -1
#define WGLYPH_FILE           0
#define WGLYPH_DRAWER         1
#define WGLYPH_POPUP          2
#define WGLYPH_LINE           3
#define WGLYPH_CYCLE          4
#define WGLYPH_RADIO          5
#define WGLYPH_CHECKBOX       6
#define WGLYPH_LEFTAMIGA      7
#define WGLYPH_RIGHTAMIGA     8
#define WGLYPH_ENTER          9
#define WGLYPH_SHIFT         10
#define WGLYPH_ARROWLEFT     11
#define WGLYPH_ARROWRIGHT    12
#define WGLYPH_ARROWUP       13
#define WGLYPH_ARROWDOWN     14

#define WGHF_IgnoreOS         1
#define WGHF_FullControl      2

struct WizardDrawInfo
{
    struct DrawInfo *wdi_DrawInfo;
    UWORD wdi_NumPens;
    UWORD *wdi_Pens;
    struct TextFont *wdi_Font;       // screen default font
    struct TextFont *wdi_SmallFont;  // a small font
    struct TextFont *wdi_LargeFont;  // a large font
    struct TextFont *wdi_FixFont;    // a non-proportional font
    UWORD wdi_NumFrames;
    struct Image *wdi_Frames;
    UWORD wdi_NumGlyphs;
    struct Image *wdi_Glyphs;
};

/*
**
** WizardNode
**
**
*/
struct WizardNode
{
    struct MinNode Node;

    UBYTE Entrys;
    UBYTE Flags;
    UWORD Width;
    UWORD Height;
    UWORD MinHeight;
    UWORD SBGPen;
    UBYTE Baseline;
    UBYTE TreeEntry;

    struct MinList    *Childs;
    struct WizardNode *ParentNode;

    UBYTE Privat[16];
    ULONG UserData;
};

/*
** WizardNodeEntry
**
**
**
*/
struct WizardNodeEntry
{
    UBYTE Private[24];
};

/*
**
** WizardDefaultNode
**
*/

struct WizardDefaultNode
{
    struct WizardNode WizardNode;
    struct WizardNodeEntry Entry;
};

/*******************************************************************/

struct WizardWindowHandle
{
    struct MinNode   Node;
    struct Window   *Window;
    struct Menu     *MenuStrip;
    struct DrawInfo *DrawInfo;
    APTR             VisualInfo;
    STRPTR           ScreenTitle;
    WORD             SizeImageWidth;
    WORD             SizeImageHeight;
    struct MinList   Objects;
    struct Gadget   *RootGadget;
    struct Gadget   *RootTopGadget;
    struct Gadget   *RootLeftGadget;
    struct Gadget   *RootBottomGadget;
    struct Gadget   *RootRightGadget;
    void            *UserStruct;
};

struct WizardNewImage
{
    UWORD Flags;
    UWORD Name;
    UWORD Width;
    UWORD Height;
    UWORD Depth;
    UWORD Compression;
    ULONG Reserved;
    ULONG ColorLength;
    ULONG ImageLength;
};

#define WIF_Interleaved 4
#define WIF_Standard    8

/*
**
** WizardVImage
**
*/
struct WizardVImage
{
    UWORD   Flags;
    UWORD   Counter;
    UWORD   MinWidth;
    UWORD   MinHeight;
    UWORD  *RelCoords;
};

#define WVIF_MinWidth         1
#define WVIF_MinHeight        2
#define WVIF_AreaInit         4
#define WVIF_Recursion        8

#define WVIB_MinWidth         0
#define WVIB_MinHeight        1
#define WVIB_AreaInit         2
#define WVIB_Recursion        3

#define WVICMD_END            0
#define WVICMD_COLOR          1
#define WVICMD_COLOR2         2
#define WVICMD_MOVE           3
#define WVICMD_DRAW           4
#define WVICMD_RECTFILL       5
#define WVICMD_WRITEPIXEL     6
#define WVICMD_IMAGE          7
#define WVICMD_TEXT           8
#define WVICMD_SETDRMD        9
#define WVICMD_TEXTIMAGE      10
#define WVICMD_TEXTMOVE       11
#define WVICMD_TAGCOLOR       12
#define WVICMD_TEXTPLACE      13
#define WVICMD_SETAFPT        14
#define WVICMD_SNAPCURSOR     15
#define WVICMD_SNAPX          16
#define WVICMD_SNAPY          17
#define WVICMD_TAGMOVE        18
#define WVICMD_TAGIMAGE       19
#define WVICMD_BITMAP_TO_RP   20
#define WVICMD_FILLBORDER     21
#define WVICMD_BEEP           22
#define WVICMD_AREAINIT       23
#define WVICMD_AREAMOVE       24
#define WVICMD_AREADRAW       25
#define WVICMD_AREAEND        26
#define WVICMD_TAGAREAPTRN    27            /* V38 */
#define WVICMD_SNAPXY         28            /* V38 */
#define WVICMD_BITMAP         29            /* V38 */
#define WVICMD_SYSFRAME       30            /* V39 */
#define WVICMD_TAGBORDER      31            /* V39 */
#define WVICMD_CLIPTEXT       32            /* V39 */

/* Tags */

#define WZRD_TagDummy           0x80000000+0x180000

#define WVIA_TagDummy           (WZRD_TagDummy+100)

#define WVIA_Text               (WVIA_TagDummy+0)
#define WVIA_TextFont           (WVIA_TagDummy+1)
#define WVIA_TextPlace          (WVIA_TagDummy+2)
#define WVIA_TextPen            (WVIA_TagDummy+3)
#define WVIA_TextStyles         (WVIA_TagDummy+4)
#define WVIA_TextHighLights     (WVIA_TagDummy+5)
#define WVIA_TextImages         (WVIA_TagDummy+6)

#define WVIA_TagImage           (WVIA_TagDummy+7)
#define WVIA_TagImageCode       (WVIA_TagDummy+8)

#define WVIA_ImageCode          (WVIA_TagDummy+9)

#define WVIA_Color0             (WVIA_TagDummy+10)
#define WVIA_Color1             (WVIA_TagDummy+11)
#define WVIA_Color2             (WVIA_TagDummy+12)
#define WVIA_Color3             (WVIA_TagDummy+13)
#define WVIA_Color4             (WVIA_TagDummy+14)
#define WVIA_Color5             (WVIA_TagDummy+15)
#define WVIA_Color6             (WVIA_TagDummy+16)
#define WVIA_Color7             (WVIA_TagDummy+17)

#define WVIA_TPoint0            (WVIA_TagDummy+18)
#define WVIA_TPoint1            (WVIA_TagDummy+19)
#define WVIA_TPoint2            (WVIA_TagDummy+20)
#define WVIA_TPoint3            (WVIA_TagDummy+21)
#define WVIA_TPoint4            (WVIA_TagDummy+22)
#define WVIA_TPoint5            (WVIA_TagDummy+23)
#define WVIA_TPoint6            (WVIA_TagDummy+24)
#define WVIA_TPoint7            (WVIA_TagDummy+25)

#define WVIA_AreaPtrn           (WVIA_TagDummy+26)
#define WVIA_TmpRas             (WVIA_TagDummy+27)

#define WVIA_BitMapWidth        (WVIA_TagDummy+28)
#define WVIA_BitMapHeight       (WVIA_TagDummy+29)
#define WVIA_BitMap0            (WVIA_TagDummy+30)
#define WVIA_BitMap1            (WVIA_TagDummy+31)
#define WVIA_BitMap2            (WVIA_TagDummy+32)
#define WVIA_BitMap3            (WVIA_TagDummy+33)
#define WVIA_BitMap4            (WVIA_TagDummy+34)
#define WVIA_BitMap5            (WVIA_TagDummy+35)
#define WVIA_BitMap6            (WVIA_TagDummy+36)
#define WVIA_BitMap7            (WVIA_TagDummy+37)

#define WVIA_PureText           (WVIA_TagDummy+38)

#define WVIA_TagAreaPtSz        (WVIA_TagDummy+39)
#define WVIA_TagAreaPtrn0       (WVIA_TagDummy+40)
#define WVIA_TagAreaPtrn1       (WVIA_TagDummy+41)
#define WVIA_TagAreaPtrn2       (WVIA_TagDummy+42)
#define WVIA_TagAreaPtrn3       (WVIA_TagDummy+43)

#define WVIA_FrameObject        (WVIA_TagDummy+44)
#define WVIA_SysIObject         (WVIA_TagDummy+45)

/* Tags für den Aufruf von WZ_OpenSurface() */

#define SFH_Locale              (WZRD_TagDummy+200)
#define SFH_Catalog             (WZRD_TagDummy+201)
#define SFH_AutoInit            (WZRD_TagDummy+202)

/* Tags für den Aufruf von WZ_CreateWindowObj() */
#define WWH_GadgetArray         (WZRD_TagDummy+300)
#define WWH_GadgetArraySize     (WZRD_TagDummy+301)
#define WWH_PreviousGadget      (WZRD_TagDummy+302)
#define WWH_StringHook          (WZRD_TagDummy+303) /* Do not use under V37 !!! */
#define WWH_StackSize           (WZRD_TagDummy+304) /* für WZ_AllocWindowHandle */
#define WWH_BubbleHelp          (WZRD_TagDummy+305) /* V 40 */

/* Tags für den Aufruf von WZ_ControlBubbleHelp() */
#define CBH_BubbleHelp          (WZRD_TagDummy+320) /* V 40 */

/* Classes in V1.0 */

#define WCLASS_GROUPEND         0

#define WCLASS_LAYOUT           0
#define WCLASS_HGROUP           1
#define WCLASS_VGROUP           2
#define WCLASS_BUTTON           3
#define WCLASS_STRING           4
#define WCLASS_LABEL            5
#define WCLASS_CHECKBOX         6
#define WCLASS_MX               7
#define WCLASS_INTEGER          8
#define WCLASS_HSCROLLER        9
#define WCLASS_VSCROLLER        10
#define WCLASS_ARROW            11
#define WCLASS_LISTVIEW         12
#define WCLASS_MULTILISTVIEW    13
#define WCLASS_TOGGLE           14
#define WCLASS_LINE             15
#define WCLASS_COLORFIELD       16
#define WCLASS_ARGS             17
#define WCLASS_GAUGE            18
#define WCLASS_CYCLE            19
#define WCLASS_VECTORBUTTON     20
#define WCLASS_DATE             21
#define WCLASS_SPACE            22
#define WCLASS_IMAGE            23
#define WCLASS_IMAGEBUTTON      24
#define WCLASS_IMAGETOGGLE      25
#define WCLASS_IMAGEPOPUP       26
#define WCLASS_TEXTPOPUP        27
#define WCLASS_PALETTE          28
#define WCLASS_VECTORPOPUP      29
#define WCLASS_HIERARCHY        30
#define WCLASS_HSLIDER          31
#define WCLASS_VSLIDER          32
#define WCLASS_STRINGFIELD      33          /* V 38 */
#define WCLASS_EXTERN           34          /* V 38 */
#define WCLASS_LAST             35

/* Flags, die Sie in dem Tag WGA_Flags angeben können */

#define WGF_GadgetHelp      (1<<1)
#define WGF_Disabled        (1<<8)
#define WGF_Immediate       (1<<2)
#define WGF_KeyControl      (1<<9)
#define WGRPF_EqualSize     (1<<15)
#define WGRPF_DockMode      (1<<14)
#define WGRPF_TabMode       (1<<13)
#define WSPCF_Transparent   (1<<15)
#define WSTFF_ReadOnly      (1<<15)
#define WTGF_SimpleMode     (1<<15)
#define WLVF_ReadOnly       (1<<15)
#define WLVF_DoubleClicks   (1<<14)
#define WLVF_NewLook        (1<<13)     /* V 38*/
#define WLVF_Borderless     (1<<12)     /* V 38 */
#define WSCF_NewLook        (1<<15)
#define WITF_SimpleMode     (1<<15)
#define WIPF_NewLook        (1<<15)
#define WTPF_NewLook        (1<<15)
#define WVPF_NewLook        (1<<15)
#define WSLF_NewLook        (1<<15)
#define WCYF_NewLook        (1<<15)     /* V 38 */

/* alle folgenden Tags sind Universal-Tags für alle Wizardgadgets */

#define WGA_Label                           (WZRD_TagDummy+400)
#define WGA_Label2                          (WZRD_TagDummy+401)
#define WGA_TextFont                        (WZRD_TagDummy+402)
#define WGA_Flags                           (WZRD_TagDummy+403)
#define WGA_Priority                        (WZRD_TagDummy+404)
#define WGA_RelHeight                       (WZRD_TagDummy+405)
#define WGA_MinWidth                        (WZRD_TagDummy+406)
#define WGA_MinHeight                       (WZRD_TagDummy+407)
#define WGA_Link                            (WZRD_TagDummy+408)
#define WGA_LinkData                        (WZRD_TagDummy+409)
#define WGA_HelpText                        (WZRD_TagDummy+410)
#define WGA_Config                          (WZRD_TagDummy+411)
#define WGA_NewImage                        (WZRD_TagDummy+412)
#define WGA_SelNewImage                     (WZRD_TagDummy+413)
#define WGA_Group                           (WZRD_TagDummy+414)
#define WGA_GroupPage                       (WZRD_TagDummy+415)
#define WGA_Locale                          (WZRD_TagDummy+416)
#define WGA_Screen                          (WZRD_TagDummy+417)
#define WGA_Bounds                          (WZRD_TagDummy+418)
#define WGA_Private                         (WZRD_TagDummy+420)     /* V 38 */
#define WGA_TabMinWidth                     (WZRD_TagDummy+421)     /* V 38 */
#define WGA_TabMinHeight                    (WZRD_TagDummy+422)     /* V 38 */
#define WGA_ObjectName                      (WZRD_TagDummy+423)     /* V 38, Userdata->ObjectName or NULL */
#define WGA_ClassID                         (WZRD_TagDummy+424)     /* V 39 */

/* Notify - Tags */
#define WNOTIFYA_Type                       (WZRD_TagDummy+450)

/* Class-Tags */

#define WGROUPA_ActivePage                  (WZRD_TagDummy+500)
#define WGROUPA_MaxPage                     (WZRD_TagDummy+501)
#define WGROUPA_HBorder                     (WZRD_TagDummy+502)
#define WGROUPA_VBorder                     (WZRD_TagDummy+503)
#define WGROUPA_BHOffset                    (WZRD_TagDummy+504)
#define WGROUPA_BVOffset                    (WZRD_TagDummy+505)
#define WGROUPA_Space                       (WZRD_TagDummy+506)
#define WGROUPA_VarSpace                    (WZRD_TagDummy+507)
#define WGROUPA_FrameType                   (WZRD_TagDummy+508)

#define WSTRINGA_MaxChars                   (WZRD_TagDummy+509)
#define WSTRINGA_String                     (WZRD_TagDummy+510)

#define WCHECKBOXA_Checked                  (WZRD_TagDummy+511)

#define WMXA_Active                         (WZRD_TagDummy+512)

#define WGROUPA_HighLights                  (WZRD_TagDummy+513)
#define WGROUPA_HighlightPen                (WZRD_TagDummy+514)

#define WLABELA_FrameType                   (WZRD_TagDummy+515)
#define WLABELA_Space                       (WZRD_TagDummy+516)
#define WLABELA_BGPen                       (WZRD_TagDummy+517)
#define WLABELA_TextPlace                   (WZRD_TagDummy+518)
#define WLABELA_Lines                       (WZRD_TagDummy+519)

#define WINTEGERA_Long                      (WZRD_TagDummy+520)
#define WINTEGERA_MinLong                   (WZRD_TagDummy+521)
#define WINTEGERA_MaxLong                   (WZRD_TagDummy+522)

#define WSCROLLERA_Top                      (WZRD_TagDummy+523)
#define WSCROLLERA_Visible                  (WZRD_TagDummy+524)
#define WSCROLLERA_Total                    (WZRD_TagDummy+525)

#define WSTRINGA_Justification              (WZRD_TagDummy+526)
#define WINTEGERA_Justification             (WZRD_TagDummy+527)

#define WARROWA_Type                        (WZRD_TagDummy+528)

#define WLISTVIEWA_HeaderNode               (WZRD_TagDummy+533)     /* V 38 */
#define WLISTVIEWA_Top                      (WZRD_TagDummy+534)
#define WLISTVIEWA_Selected                 (WZRD_TagDummy+535)
#define WLISTVIEWA_List                     (WZRD_TagDummy+536)
#define WLISTVIEWA_Columns                  (WZRD_TagDummy+537) /*  V 38  */
#define WLISTVIEWA_Visible                  (WZRD_TagDummy+538)
#define WLISTVIEWA_DoubleClick              (WZRD_TagDummy+539)

#define WTOGGLEA_Checked                    (WZRD_TagDummy+540)

#define WLINEA_Type                         (WZRD_TagDummy+541)
#define WLINEA_Label                        (WZRD_TagDummy+542)

#define WCOLORFIELDA_Pen                    (WZRD_TagDummy+543)

#define WARGSA_TextPlace                    (WZRD_TagDummy+544)
#define WARGSA_FrameType                    (WZRD_TagDummy+545)
#define WARGSA_Arg0                         (WZRD_TagDummy+546)
#define WARGSA_Arg1                         (WZRD_TagDummy+547)
#define WARGSA_Arg2                         (WZRD_TagDummy+548)
#define WARGSA_Arg3                         (WZRD_TagDummy+549)
#define WARGSA_Arg4                         (WZRD_TagDummy+550)
#define WARGSA_Arg5                         (WZRD_TagDummy+551)
#define WARGSA_Arg6                         (WZRD_TagDummy+552)
#define WARGSA_Arg7                         (WZRD_TagDummy+553)
#define WARGSA_Arg8                         (WZRD_TagDummy+554)
#define WARGSA_Arg9                         (WZRD_TagDummy+555)

#define WGAUGEA_Total                       (WZRD_TagDummy+556)
#define WGAUGEA_Current                     (WZRD_TagDummy+557)
#define WGAUGEA_Format                      (WZRD_TagDummy+558)

#define WCYCLEA_Active                      (WZRD_TagDummy+559)
#define WCYCLEA_Labels                      (WZRD_TagDummy+560)

#define WARROWA_Step                        (WZRD_TagDummy+561)

#define WVECTORBUTTONA_Type                 (WZRD_TagDummy+562)

#define WDATEA_Day                          (WZRD_TagDummy+563)
#define WDATEA_Month                        (WZRD_TagDummy+564)
#define WDATEA_Year                         (WZRD_TagDummy+565)

#define WARGSA_Format                       (WZRD_TagDummy+566)

#define WLABELA_HighlightPen                (WZRD_TagDummy+567)

#define WBUTTONA_Label                      (WZRD_TagDummy+568)

#define WLABELA_HighLights                  (WZRD_TagDummy+569)
#define WLABELA_Label                       (WZRD_TagDummy+570)

#define WIMAGEA_BGPen                       (WZRD_TagDummy+571)
#define WIMAGEA_FrameType                   (WZRD_TagDummy+572)
#define WIMAGEA_HBorder                     (WZRD_TagDummy+573)
#define WIMAGEA_VBorder                     (WZRD_TagDummy+574)
#define WIMAGEA_NewImage                    (WZRD_TagDummy+575)

#define WIMAGEBUTTONA_BGPen                 (WZRD_TagDummy+576)
#define WIMAGEBUTTONA_SelBGPen              (WZRD_TagDummy+577)
#define WIMAGEBUTTONA_FrameType             (WZRD_TagDummy+578)
#define WIMAGEBUTTONA_HBorder               (WZRD_TagDummy+579)
#define WIMAGEBUTTONA_VBorder               (WZRD_TagDummy+580)
#define WIMAGEBUTTONA_NewImage              (WZRD_TagDummy+581)
#define WIMAGEBUTTONA_SelNewImage           (WZRD_TagDummy+582)

#define WIMAGETOGGLEA_BGPen                 (WZRD_TagDummy+583)
#define WIMAGETOGGLEA_SelBGPen              (WZRD_TagDummy+584)
#define WIMAGETOGGLEA_FrameType             (WZRD_TagDummy+585)
#define WIMAGETOGGLEA_HBorder               (WZRD_TagDummy+586)
#define WIMAGETOGGLEA_VBorder               (WZRD_TagDummy+587)
#define WIMAGETOGGLEA_NewImage              (WZRD_TagDummy+588)
#define WIMAGETOGGLEA_SelNewImage           (WZRD_TagDummy+589)
#define WIMAGETOGGLEA_Checked               (WZRD_TagDummy+590)

#define WSTRINGA_Hook                       (WZRD_TagDummy+591) /* V 38 */
#define WINTEGERA_Hook                      (WZRD_TagDummy+592) /* V 38 */

#define WIMAGEPOPUPA_BGPen                  (WZRD_TagDummy+593)
#define WIMAGEPOPUPA_FrameType              (WZRD_TagDummy+594)
#define WIMAGEPOPUPA_HBorder                (WZRD_TagDummy+595)
#define WIMAGEPOPUPA_VBorder                (WZRD_TagDummy+596)
#define WIMAGEPOPUPA_TextPlace              (WZRD_TagDummy+597)
#define WIMAGEPOPUPA_NewImage               (WZRD_TagDummy+598)
#define WIMAGEPOPUPA_Labels                 (WZRD_TagDummy+599)
#define WIMAGEPOPUPA_Selected               (WZRD_TagDummy+600)

#define WTEXTPOPUPA_TextPlace               (WZRD_TagDummy+601)
#define WTEXTPOPUPA_Labels                  (WZRD_TagDummy+602)
#define WTEXTPOPUPA_Selected                (WZRD_TagDummy+603)
#define WTEXTPOPUPA_Name                    (WZRD_TagDummy+604)

#define WPALETTEA_Colors                    (WZRD_TagDummy+605)
#define WPALETTEA_Selected                  (WZRD_TagDummy+606)
#define WPALETTEA_Offset                    (WZRD_TagDummy+607)

#define WGROUPA_BGPen                       (WZRD_TagDummy+608)
#define WGROUPA_DockMinVisible              (WZRD_TagDummy+609)
#define WGROUPA_Styles                      (WZRD_TagDummy+610)

#define WLABELA_Styles                      (WZRD_TagDummy+611)

#define WVECTORPOPUPA_Type                  (WZRD_TagDummy+612)
#define WVECTORPOPUPA_Labels                (WZRD_TagDummy+613)
#define WVECTORPOPUPA_TextPlace             (WZRD_TagDummy+614)
#define WVECTORPOPUPA_Selected              (WZRD_TagDummy+615)

#define WHIERARCHYA_HeaderNode              (WZRD_TagDummy+616) /* V 38 */
#define WHIERARCHYA_ImageType               (WZRD_TagDummy+617)
#define WHIERARCHYA_ImageWidth              (WZRD_TagDummy+618)
#define WHIERARCHYA_Top                     (WZRD_TagDummy+619)
#define WHIERARCHYA_List                    (WZRD_TagDummy+620)
#define WHIERARCHYA_Selected                (WZRD_TagDummy+621)
#define WHIERARCHYA_Visible                 (WZRD_TagDummy+622)
#define WHIERARCHYA_DoubleClick             (WZRD_TagDummy+623)
#define WHIERARCHYA_Columns                 (WZRD_TagDummy+624) /* V 38 */
#define WHIERARCHYA_TreeClick               (WZRD_TagDummy+625) /* V 38, BOOL */

#define WSLIDERA_Hook                       (WZRD_TagDummy+626) /* V 38 */

#define WSLIDERA_Min                        (WZRD_TagDummy+627)
#define WSLIDERA_Max                        (WZRD_TagDummy+628)
#define WSLIDERA_Level                      (WZRD_TagDummy+629)

#define WTOGGLEA_Label                      (WZRD_TagDummy+630)

#define WLAYOUTA_RootGadget                 (WZRD_TagDummy+631)
#define WLAYOUTA_Type                       (WZRD_TagDummy+632)
#define WLAYOUTA_BorderLeft                 (WZRD_TagDummy+633)
#define WLAYOUTA_BorderRight                (WZRD_TagDummy+634)
#define WLAYOUTA_BorderTop                  (WZRD_TagDummy+635)
#define WLAYOUTA_BorderBottom               (WZRD_TagDummy+636)
#define WLAYOUTA_StackSwap                  (WZRD_TagDummy+637)

#define WARGSA_TextPen                      (WZRD_TagDummy+638)
#define WARGSA_BackgroundPen                (WZRD_TagDummy+639)

#define WSTRINGFIELDA_Text                  (WZRD_TagDummy+640) /* V38 */
#define WSTRINGFIELDA_MaxChars              (WZRD_TagDummy+641) /* V38 */
#define WSTRINGFIELDA_MaxLines              (WZRD_TagDummy+642) /* V38 */
#define WSTRINGFIELDA_TextPen               (WZRD_TagDummy+643) /* V38 */
#define WSTRINGFIELDA_STextPen              (WZRD_TagDummy+644) /* V38 */
#define WSTRINGFIELDA_CTextPen              (WZRD_TagDummy+645) /* V38 */
#define WSTRINGFIELDA_BGPen                 (WZRD_TagDummy+646) /* V38 */
#define WSTRINGFIELDA_SBGPen                (WZRD_TagDummy+647) /* V38 */
#define WSTRINGFIELDA_CBGPen                (WZRD_TagDummy+648) /* V38 */
#define WSTRINGFIELDA_Hook                  (WZRD_TagDummy+649) /* V38 */

#define WBUTTONA_Hook                       (WZRD_TagDummy+650) /* V38 */

#define WEXTERNA_Data0                      (WZRD_TagDummy+651) /* V38 */
#define WEXTERNA_Data1                      (WZRD_TagDummy+652) /* V38 */
#define WEXTERNA_Data2                      (WZRD_TagDummy+653) /* V38 */
#define WEXTERNA_Data3                      (WZRD_TagDummy+654) /* V38 */
#define WEXTERNA_Data4                      (WZRD_TagDummy+655) /* V38 */
#define WEXTERNA_Data5                      (WZRD_TagDummy+656) /* V38 */
#define WEXTERNA_Data6                      (WZRD_TagDummy+657) /* V38 */
#define WEXTERNA_Data7                      (WZRD_TagDummy+658) /* V38 */

#define WPALETTEA_PenTable                  (WZRD_TagDummy+659) /* V38 */

#define WSLIDERA_MODE                       (WZRD_TagDummy+660)
#define WSCROLLERA_MODE                     WSLIDER_MODE

/* V 41 */
#define WPOPUPA_Tag                         (WZRD_TagDummy+661)
#define WPOPUPA_Selected                    (WZRD_TagDummy+662)
#define WPOPUPA_Labels                      (WZRD_TagDummy+663)
#define WPOPUPA_Delay                       (WZRD_TagDummy+664)
#define WPOPUPA_SelectButton                (WZRD_TagDummy+665)
#define WPOPUPA_MenuButton                  (WZRD_TagDummy+666)
#define WGA_HBorder                         (WZRD_TagDummy+667)
#define WGA_VBorder                         (WZRD_TagDummy+668)

#define WPROPA_Mode                         WSLIDERA_MODE

/* Tags für WZ_InitNode() */

#define WNODEA_Flags                        (WZRD_TagDummy+1000)
#define WNODEA_UserData                     (WZRD_TagDummy+1001) /*  V 38  */

#define WNF_SELECTED        (1<<0)  /* Node ist selektiert, MultiListView */
#define WNF_TREE            (1<<5)  /* Das ist eine Node eines Baumes */
#define WNF_AUTOMATIC       (1<<6)  /* Baumkontrolle geht an BOOPSI-Object  */
#define WNF_VISIBLE         (1<<7)  /* Baum dieser Node wird dargestellt    */

/* Tags für WZ_InitNodeEntry() */


#define WENTRYA_Type                        (WZRD_TagDummy+1100)

#define WNE_SPACE       0       /*  V 38  */
#define WNE_TEXT        1
#define WNE_FORMAT      2       /*  V 38  */
#define WNE_TREE        3
#define WNE_IMAGE       4       /*  V 38  */
#define WNE_VIMAGE      5       /*  V 38  */
#define WNE_HOOK        6       /*  V 38  */


#define WENTRYA_TextPen                     (WZRD_TagDummy+1101)
#define WENTRYA_TextSPen                    (WZRD_TagDummy+1102)
#define WENTRYA_TextStyle                   (WZRD_TagDummy+1103)
#define WENTRYA_TextSStyle                  (WZRD_TagDummy+1104)
#define WENTRYA_TextString                  (WZRD_TagDummy+1105)
#define WENTRYA_TreeParentNode              (WZRD_TagDummy+1106)
#define WENTRYA_TreeChilds                  (WZRD_TagDummy+1107)
#define WENTRYA_TreeString                  (WZRD_TagDummy+1108)
#define WENTRYA_TreePen                     (WZRD_TagDummy+1109) /*  V 38  */
#define WENTRYA_TreeSPen                    (WZRD_TagDummy+1110) /*  V 38  */
#define WENTRYA_TreeStyle                   (WZRD_TagDummy+1111) /*  V 38  */
#define WENTRYA_TreeSStyle                  (WZRD_TagDummy+1112) /*  V 38  */
#define WENTRYA_TextFont                    (WZRD_TagDummy+1113) /*  V 38  */
#define WENTRYA_TextJustification           (WZRD_TagDummy+1114) /*  V 38  */
#define WENTRYA_TreeFont                    (WZRD_TagDummy+1115) /*  V 38  */

#define WENTRYA_ImageWidth                  (WZRD_TagDummy+1116) /*  V 38  */
#define WENTRYA_ImageHeight                 (WZRD_TagDummy+1117) /*  V 38  */
#define WENTRYA_ImageBitmap                 (WZRD_TagDummy+1118) /*  V 38  */
#define WENTRYA_ImageSBitmap                (WZRD_TagDummy+1119) /*  V 38  */
#define WENTRYA_ImageJustification          (WZRD_TagDummy+1120) /*  V 38  */

#define WENTRYA_VImageWidth                 (WZRD_TagDummy+1121) /*  V 38  */
#define WENTRYA_VImageStruct                (WZRD_TagDummy+1122) /*  V 38  */
#define WENTRYA_VImageTags                  (WZRD_TagDummy+1123) /*  V 38  */
#define WENTRYA_VImageSTags                 (WZRD_TagDummy+1124) /*  V 38  */
#define WENTRYA_VImageType                  (WZRD_TagDummy+1136) /*  V 39  */

#define WENTRYA_SpaceWidth                  (WZRD_TagDummy+1125) /*  V 38  */

#define WENTRYA_FormatPen                   (WZRD_TagDummy+1126) /*  V 38  */
#define WENTRYA_FormatSPen                  (WZRD_TagDummy+1127) /*  V 38  */
#define WENTRYA_FormatStyle                 (WZRD_TagDummy+1128) /*  V 38  */
#define WENTRYA_FormatSStyle                (WZRD_TagDummy+1129) /*  V 38  */
#define WENTRYA_FormatStruct                (WZRD_TagDummy+1130) /*  V 38  */
#define WENTRYA_FormatFont                  (WZRD_TagDummy+1131) /*  V 38  */
#define WENTRYA_FormatJustification         (WZRD_TagDummy+1132) /*  V 38  */

#define WENTRYA_HookStruct                  (WZRD_TagDummy+1133) /*  V 38  */
#define WENTRYA_HookWidth                   (WZRD_TagDummy+1134) /*  V 38  */
#define WENTRYA_HookUserData                (WZRD_TagDummy+1135) /*  V 38  */


/* Types für WZ_GetDataAddress() */

#define WDATA_CHUNK         0           /* V 38 */
#define WDATA_IMAGE         'IMGS'      /* V 38 */
#define WDATA_WINDOW        'WINS'
#define WDATA_REQUEST       'REQS'
#define WDATA_FONT          'FNTS'
#define WDATA_LIBRARY       'LIBS'

#endif /* LIBRARIES_WIZARD_H */

