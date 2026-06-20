/*
 * GOO
 * Q Software's GOOey system
 * Header file by oondy
 */
 
#ifndef GOO_HEADER
#define GOO_HEADER

#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>

// The GOOObject structure, returned when a GOO object is created
struct GOOObject
{
  struct GOOObject *NextObject;  // Linked-list of objects
  struct Window *Window;  // The window this gadget belongs to
  struct BitMap *BitMap;  // The graphic for this gadget
  struct BitMap *AltBitMap;
  struct Gadget *Gadget;  // An intuition gadget that belongs to this object
  struct StringInfo SInfo;// The stringinfo structure used for string gadgets (not ptr)
  struct IntuiText IText; // Text for an object (not pointer!)
  ULONG Type;             // Type of object
  UWORD ID;               // ID number for this object
  WORD LeftEdge;          // Relative coords for the gadget in relation to the window
  WORD TopEdge;
  UWORD Width;
  UWORD Height;
  STRPTR TipText;         // Text that appears to describe the object or NULL
  ULONG IntuiCounter;     // Counter that gets ++ when mouse is over object
  BOOL ReadOnly;          // Allow appliprog to receieve events for this object
  STRPTR ButtonText;      // Text that is shown if no bitmap (for testing only)
  BOOL HasBorder;
  UWORD BorderGapX, BorderGapY;
  BOOL RedrawMeThenTosser;
  BOOL ClickedOnButton;   // If TRUE, redraw this button as clicked (private)
};

// The GOOWindow structure, returned when a GOO window is opened
struct GOOWindow
{
  struct Window *Window;  // The intuition window used
  struct Screen *Screen;  // Which screen this window appears on
  struct GOOObject *FirstObject; // The first object on this window
  WORD Count; // Number of objects - do not touch!
};

// The GOOIMsg structure - an extension of the IntuiMessage struct
// This structure is READ-ONLY!
struct GOOIMsg
{
  ULONG Class;                // A GOO class or NULL if GOO doesn't understand 
  ULONG Code;                 // A code relevant to specific objects
  ULONG ID;                   // The ID of the selected object
  ULONG Seconds;              // Seconds variable copied from IMsg for double-clicks
  ULONG Micros;               // As Seconds but the Microsecond variable
};

//------------------------------------------------------- Goo bits
#define GOOTIP_DELAYAPPEAR 10   // Time in intuiticks to show tiptext
#define GOOTIP_DELAYREMOVE 100  // Time in intuiticks to remove tiptext

//------------------------------------------------------- Tags

// Synomons
#define GOOTAG_X        GOOTAG_LeftEdge
#define GOOTAG_Y        GOOTAG_TopEdge

#define GOOTAG_Dummy     (0xF000)
#define GOOTAG_LeftEdge  (GOOTAG_Dummy + 1) // Leftedge of object on window
#define GOOTAG_TopEdge   (GOOTAG_Dummy + 2) // Topedge of object on window
#define GOOTAG_Width     (GOOTAG_Dummy + 3) // Width of object on window
#define GOOTAG_Height    (GOOTAG_Dummy + 4) // Height of object on window
#define GOOTAG_ID        (GOOTAG_Dummy + 5) // ID of object to reference with
#define GOOTAG_BitMap    (GOOTAG_Dummy + 6) // This object uses a bitmap
#define GOOTAG_Type      (GOOTAG_Dummy + 7) // Sets what type of object this is
#define GOOTAG_TipText   (GOOTAG_Dummy + 8) // Sets the objects tip text
#define GOOTAG_ReadOnly  (GOOTAG_Dummy + 9) // Object can't be clicked on
#define GOOTAG_Text      (GOOTAG_Dummy + 10)// Text to display instead of bitmap
#define GOOTAG_MaxChars  (GOOTAG_Dummy + 11)// Max length of text for string object
#define GOOTAG_FrontPen  (GOOTAG_Dummy + 12)// Forecolour for text objects
#define GOOTAG_BackPen   (GOOTAG_Dummy + 13)// Backcolour for text objects
#define GOOTAG_Border    (GOOTAG_Dummy + 14)// Place border around object
#define GOOTAG_BGapX     (GOOTAG_Dummy + 15)// Extra gap for the border on an object
#define GOOTAG_BGapY     (GOOTAG_Dummy + 16)
#define GOOTAG_AltBitMap (GOOTAG_Dummy + 17)// Alternative image for buttons

//------------------------------------------------------- Object Types
#define GOOTYPE_DUMMY   (GOOTAG_Dummy + 0x4000)
#define GOOTYPE_BUTTON  (GOOTYPE_DUMMY + 1)  // Object you can click on
#define GOOTYPE_STRING  (GOOTYPE_DUMMY + 2)  // Object you can type into
#define GOOTYPE_LABEL   (GOOTYPE_DUMMY + 3)  // Object that says something
#define GOOTYPE_TEXT    GOOTYPE_LABEL        // Synonim for label objects

//------------------------------------------------------- Flags for tags
#define GOOOBJ_DUMMY    (GOOTAG_Dummy + 0x5000)
#define GOOOBJ_USEBITMAPWIDTH  (GOOOBJ_DUMMY + 1) // Width = BitMap->Width
#define GOOOBJ_USEBITMAPHEIGHT (GOOOBJ_DUMMY + 2) // Height = BitMap->Height

//------------------------------------------------------- Miscellanous flags
#define GOOWFG_DUMMY    (GOOTAG_Dummy + 0x6000)

//------------------------------------------------------- Object classes
#define GOOCL_DUMMY         (GOOTAG_Dummy + 0x7000)
#define GOOCL_BUTTONSELECT  (GOOCL_DUMMY + 1)
#define GOOCL_MOUSECLICK    (GOOCL_DUMMY + 2)
#define GOOCL_STRINGCHANGE  (GOOCL_DUMMY + 3)
#define GOOCL_UNKNOWNGADGET (GOOCL_DUMMY + 4)
#define GOOCL_RAWKEYPRESS   (GOOCL_DUMMY + 5)

//- Varibles that you can query for GOO_GetInternal or set using GOO_SetInternal
#define GOOINT_DUMMY      (GOOTAG_Dummy + 0x8000) // Private
#define GOOINT_SHINEPEN   (GOOINT_DUMMY + 1)  // Bright pen for drawing string gadgets
#define GOOINT_SHADOWPEN  (GOOINT_DUMMY + 2)  // Shadow pen for drawing string gadgets
#define GOOINT_TIPBACKPEN (GOOINT_DUMMY + 3)  // Background pen for tip text
#define GOOINT_TIPTEXTPEN (GOOINT_DUMMY + 4)  // Text pen for tip text

//------------------------------------------------------- Prototypes
BOOL GOO_NewObject(struct GOOWindow *GOOWindow, struct TagItem *TagList);
BOOL GOO_NewObjectTags(struct GOOWindow *GOOWindow, ...);
void GOO_FreeObject(struct GOOWindow *GOOWindow, ULONG ID);
void GOO_FreeObjects(struct GOOWindow *GOOWindow);
struct GOOWindow *GOO_OpenWindow(struct Screen *Screen, struct TagItem *TagList);
struct GOOWindow *GOO_OpenWindowTags(struct Screen *Screen, ...);
void GOO_CloseWindow(struct GOOWindow *GOOWindow, BOOL FreeObjects);
void GOO_RefreshObjects(struct GOOWindow *GOOWindow, BOOL AllowClear);
void GOO_RefreshObject(struct GOOWindow *GOOWindow, ULONG ID);
struct GOOIMsg *GOO_GetIMsg(struct GOOWindow *GOOWindow);
void GOO_ReplyIMsg(struct GOOIMsg *Msg);
struct GOOIMsg *GOO_WaitIMsg(struct GOOWindow *GOOWindow);
BOOL GOO_SetObjectAttr(struct GOOWindow *GOOWindow, ULONG ID, struct TagItem *TagList);
BOOL GOO_SetObjectAttrTags(struct GOOWindow *GOOWindow, ULONG ID, ...);
LONG GOO_GetObjectAttr(struct GOOWindow *GOOWindow, ULONG ID, ULONG Tag);
LONG GOO_SetInternal(ULONG Varible, LONG Value);
LONG GOO_GetInternal(ULONG Varible);

#endif

