/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 ***************************************************************************
 *
 * Full_Narrator.c
 *
 * This example program sends a string of phonetic text to the narrator
 * device and, while it is speaking, highlights, word-by-word, a
 * corresponding English string.  In addition, mouth movements are drawn
 * in a separate window.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Requires Kickstart V37 or greater.
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <ctype.h>
#include <exec/exec.h>
#include <fcntl.h>
#include <devices/narrator.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/dos_protos.h>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


/*
 *  Due to an omission, the sync field defines were not included in older
 *  versions of the narrator device include files.  So, if they haven't
 *  already been defined, do so now.
 */

#ifndef NDF_READMOUTH                        /* Already defined ? */
#define NDF_READMOUTH   0x01                 /* No, define here   */
#define NDF_READWORD    0x02
#define NDF_READSYL     0x04
#endif

#define PEN3    3                            /* Drawing pens */
#define PEN2    2
#define PEN1    1
#define PEN0    0


BOOL FromCLI = TRUE;
BYTE chans[4] = {3, 5, 10, 12};


LONG EyesLeft;                               /* Left edge of left eye     */
LONG EyesTop;                                /* Top of eyes box           */
LONG EyesBottom;                             /* Bottom of eyes box        */
LONG YMouthCenter;                           /* Pixels from top edge      */
LONG XMouthCenter;                           /* Pixels from left edge     */
LONG LipWidth, LipHeight;                    /* Width and height of mouth */


struct TextAttr MyFont = {"topaz.font", TOPAZ_SIXTY, FS_NORMAL, FPF_ROMFONT,};

extern struct Library   *SysBase;   /* Used to check the OS version number */

struct  IntuitionBase   *IntuitionBase = NULL;
struct  GfxBase         *GfxBase = NULL;

struct  MsgPort         *VoicePort = NULL;
struct  MsgPort         *MouthPort = NULL;

struct  narrator_rb     *VoiceIO = NULL;
struct  mouth_rb        *MouthIO = NULL;

struct  IntuiText  HighLight;
struct  NewWindow  NewWindow;
struct  Window    *TextWindow;
struct  Window    *FaceWindow;
struct  RastPort  *FaceRast;


void main(int argc, char **argv)
{
LONG     i;
LONG     sentence;
LONG     Offset;
LONG     CharsLeft;
LONG     ScreenPos;
LONG     WordLength;
LONG     LineNum;
UBYTE    *Tempptr;
UBYTE    *English;
UBYTE    *OldEnglish;
UBYTE     c;

UBYTE    *PhonPtr;              /* Pointer to phonetic text     */
LONG     PhonSize;              /* Size of phonetic text        */
UBYTE    *PhonStart[100];       /* Start of phonetic sentences  */
LONG     NumPhonStarts;         /* Number of phonetic sentences */

UBYTE    *EngPtr;               /* Pointer to English text      */
LONG     EngSize;               /* Size of English text         */
UBYTE    *EngStart[100];        /* Start of English sentences   */
LONG     NumEngStarts;          /* Number of English sentences  */

UBYTE    *EngLine[24];          /* Start of line on screen      */
LONG     EngBytes[24];          /* Bytes per line on screen     */
LONG     NumEngLines;           /* Number of lines on screen    */


extern  void  Cleanup(UBYTE *errmsg);
extern  void  ClearWindow(struct Window *TextWindow);
extern  void  DrawFace(void);
extern  void  UpdateFace(void);


/*
 *  (0)   Note whether the program was started from the CLI or from
 *        Workbench.
 */

if (argc == 0)
    FromCLI = FALSE;

/*
 *  (1)   Setup the phonetic text to be spoken.  If there are any non-
 *        alphabetic characters in the text (such as NEWLINES or TABS)
 *        replace them with spaces.  Then break up the text into sentences,
 *        storing the start of each sentence in PhonStart array elements.
 */

PhonPtr = "KAA1RDIYOWMAYAA5PAXTHIY.  AY /HAED NEH1VER /HER4D AXV IHT "
          "BIXFOH5R, BAHT DHEH5R IHT WAHZ - LIH4STIXD AEZ (DHAX FOH5RM "
          "AXV /HAA5RT DIHZIY5Z) DHAET FEH4LD (NAAT WAH5N OHR TUW5) - "
          "BAHT (AO7L THRIY5 AXV DHAX AA5RTAXFIHSHUL /HAA5RTQ "
          "RIXSIH5PIYINTS).  (AH LIH5TUL RIXSER5CH) PROHDUW5ST (SAHM "
          "IH5NTRIHSTIHNX RIXZAH5LTS). AHKOH5RDIHNX TUW (AEN AA5RTIHKUL "
          "IHN DHAX NOWVEH5MBER EY2THQX NAY5NTIYNEYTIYFOH1R NUW IY5NXGLIND "
          "JER5NUL AXV MEH5DIXSIN), (SIH5GEREHT SMOW5KIHNX) KAO4ZIHZ "
          "(DHIHS LIY5THUL DIHZIY5Z) DHAET WIY4KINZ (DHAX /HAA5RTS "
          "PAH4MPIHNX PAW2ER).  WAYL (DHIY IHGZAE5KT MEH5KINIXZUM) IHZ "
          "NAAT KLIY5R, DAA5KTER AA5RTHER JEY2 /HAARTS SPEH5KYULEYTIHD "
          "DHAET NIH4KAXTIY2N- OHR KAA5RBIN MUNAA5KSAYD IHN DHAX SMOW5K- "
          "SAH5M/HAW1 POY4ZINZ DHAX /HAA5RT, AEND LIY4DZ TUW (/HAA5RT "
          "FEY5LYER).";

PhonSize = strlen(PhonPtr);
NumPhonStarts = 0;
PhonStart[NumPhonStarts++] = PhonPtr;
for (i = 0;  i < PhonSize;  ++i)
     {
     if (isspace((int)(c = *PhonPtr++)))
         *(PhonPtr-1) = ' ';
     if ((c == '.') || (c == '?'))
         {
         *PhonPtr = '\0';
         PhonStart[NumPhonStarts++] = ++PhonPtr;
         }
     }

/*
 *  (2)  Create the English text corresponding to the phonetic text above.
 *       As before, insure that there are no TABS or NEWLINES in the text.
 *       Break the text up into sentences and store the start of each
 *       sentence in EngStart array elements.
 */

EngPtr = "Cardiomyopathy. I had never heard of it before, but there it was "
         "listed as the form of heart disease that felled not one or two but "
         "all three of the artificial heart recipients. A little research "
         "produced some interesting results. According to an article in the "
         "November 8, 1984, New England Journal of Medicine, cigarette smoking "
         "causes this lethal disease that weakens the heart's pumping power.   "
         "While the exact mechanism is not clear, Doctor Arthur J Hartz "
         "speculated that nicotine or carbon monoxide in the smoke somehow "
         "poisons the heart and leads to heart failure.";

EngSize = strlen(EngPtr);
NumEngStarts = 0;
EngStart[NumEngStarts++] = EngPtr;
for (i = 0;  i < EngSize;  ++i)
     {
     if (isspace((int)(c = *EngPtr++)))
         *(EngPtr-1) = ' ';
     if ((c == '.') || (c == '?'))
         {
         *EngPtr = '\0';
         EngStart[NumEngStarts++] = ++EngPtr;
         }
     }

/*
 *  (3)   Open Intuition and Graphics libraries.
 */

if (!(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0)))
    Cleanup("can't open intuition");


if ((GfxBase=(struct GfxBase *)OpenLibrary("graphics.library", 0)) == NULL)
    Cleanup("can't open graphics");

/*
 *  (4)   Setup the NewWindow structure for the text display and
 *        open the text window.
 */

NewWindow.LeftEdge    = 20;
NewWindow.TopEdge     = 100;
NewWindow.Width       = 600;
NewWindow.Height      = 80;
NewWindow.DetailPen   = 0;
NewWindow.BlockPen    = 1;
NewWindow.Title       = " Narrator Demo ";
NewWindow.Flags       = SMART_REFRESH | ACTIVATE | WINDOWDEPTH | WINDOWDRAG;
NewWindow.IDCMPFlags  = NULL;
NewWindow.Type        = WBENCHSCREEN;
NewWindow.FirstGadget = NULL;
NewWindow.CheckMark   = NULL;
NewWindow.Screen      = NULL;
NewWindow.BitMap      = NULL;
NewWindow.MinWidth    = 600;
NewWindow.MinHeight   = 80;
NewWindow.MaxWidth    = 600;
NewWindow.MaxHeight   = 80;

if ((TextWindow = (struct Window *)OpenWindow(&NewWindow)) == NULL)
    Cleanup("Text window could not be opened");

/*
 *  (4)   Setup the NewWindow structure for the face display, open the 
 *        window, cache the RastPort pointer, and draw the initial face.
 *        If this is 1.3 or an earlier version of the OS (i.e., before V36) 
 *        then don't do the face since it uses new features of Release 2
 */
if ( SysBase->lib_Version >= 36 )
    {
    NewWindow.LeftEdge    = 20;
    NewWindow.TopEdge     = 12;
    NewWindow.Width       = 120;
    NewWindow.Height      = 80;
    NewWindow.DetailPen   = 0;
    NewWindow.BlockPen    = 1;
    NewWindow.Title       = " Face ";
    NewWindow.Flags       = SMART_REFRESH | WINDOWDEPTH | WINDOWDRAG;
    NewWindow.IDCMPFlags  = NULL;
    NewWindow.Type        = WBENCHSCREEN;
    NewWindow.FirstGadget = NULL;
    NewWindow.CheckMark   = NULL;
    NewWindow.Screen      = NULL;
    NewWindow.BitMap      = NULL;
    NewWindow.MinWidth    = 120;
    NewWindow.MinHeight   = 80;
    NewWindow.MaxWidth    = 120;
    NewWindow.MaxHeight   = 80;

    if ((FaceWindow = (struct Window *)OpenWindow(&NewWindow)) == NULL)
        Cleanup("Face window could not be opened");

    FaceRast = FaceWindow->RPort;

    DrawFace();
    }

/*
 *  (5)   Create read and write msg ports.
 */

if ((MouthPort = CreatePort(NULL,0)) == NULL)
    Cleanup("Can't get read port");
if ((VoicePort = CreatePort(NULL,0)) == NULL)
    Cleanup("Can't get write port");

/*
 *  (6)   Create read and write I/O request blocks.
 */

if (!(MouthIO = (struct mouth_rb *)
                  CreateExtIO(MouthPort,sizeof(struct mouth_rb))))
    Cleanup("Can't get read IORB");

if (!(VoiceIO = (struct narrator_rb *)
                   CreateExtIO(VoicePort,sizeof(struct narrator_rb))))
    Cleanup("Can't get write IORB");

/*
 *  (7)   Set up the write I/O request block and open the device.
 */

VoiceIO->ch_masks            = &chans[0];
VoiceIO->nm_masks            = sizeof(chans);
VoiceIO->message.io_Command = CMD_WRITE;
VoiceIO->flags               = NDF_NEWIORB;

if (OpenDevice("narrator.device", 0, VoiceIO, 0) != NULL)
    Cleanup("OpenDevice failed");

/*
 *  (8)   Set up the read I/O request block.
 */

MouthIO->voice.message.io_Device = VoiceIO->message.io_Device;
MouthIO->voice.message.io_Unit   = VoiceIO->message.io_Unit;
MouthIO->voice.message.io_Message.mn_ReplyPort = MouthPort;
MouthIO->voice.message.io_Command = CMD_READ;

/*
 *  (9)   Initialize highlighting IntuiText structure.
 */

HighLight.FrontPen  = 1;
HighLight.BackPen   = 0;
HighLight.DrawMode  = JAM1;
HighLight.ITextFont = &MyFont;
HighLight.NextText  = NULL;

/*
 *  (10)   For each sentence, put up the English text in BLACK.  As
 *         Narrator says each word, highlight that word in BLUE.  Also
 *         continuously draw mouth shapes as Narrator speaks.
 */

for (sentence = 0; sentence < NumPhonStarts; ++sentence)
     {

     /*
      *  (11)  Begin by breaking the English sentence up into lines of
      *        text in the window.  EngLine is an array containing a
      *        pointer to the start of each English text line.
      */

     English = EngStart[sentence] + strspn((UBYTE *)EngStart[sentence], " ");
     NumEngLines = 0;
     EngLine[NumEngLines++] = English;
     CharsLeft = strlen(English);
     while (CharsLeft > 51)
           {
           for (Offset = 51; *(English+Offset) != ' '; --Offset) ;
           EngBytes[NumEngLines-1] = Offset;
           English                += Offset + 1;
           *(English-1)            = '\0';
           EngLine[NumEngLines++]  = English;
           CharsLeft              -= Offset + 1;
           }
     EngBytes[NumEngLines-1] = CharsLeft;

     /*
      *  (12)   Clear the window and draw in the unhighlighted English text.
      */

     ClearWindow(TextWindow);

     HighLight.FrontPen = 1;
     HighLight.LeftEdge = 10;
     HighLight.TopEdge  = 20;

     for (i = 0; i < NumEngLines; ++i)
          {
          HighLight.IText = EngLine[i];
          PrintIText(TextWindow->RPort, &HighLight, 0, 0);
          HighLight.TopEdge += 10;
          }

     HighLight.TopEdge  = 20;
     HighLight.FrontPen = 3;
     HighLight.IText    = EngLine[0];

     /*
      *  (13)   Set up the write request with the address and length of
      *         the phonetic text to be spoken.  Also tell device to
      *         generate mouth shape changes and word sync events.
      */

     VoiceIO->message.io_Data   = PhonStart[sentence];
     VoiceIO->message.io_Length = strlen(VoiceIO->message.io_Data);
     VoiceIO->flags             = NDF_NEWIORB | NDF_WORDSYNC;
     VoiceIO->mouths            = 1;

    /*
     *  (14)   Send the write request to the device.  This is an
     *         asynchronous write, the device will return immediately.
     */

     SendIO(VoiceIO);

    /*
     *  (15)   Initialize some variables.
     */

     ScreenPos  = 0;
     LineNum    = 0;
     English    = EngLine[LineNum];
     OldEnglish = English;
     MouthIO->voice.message.io_Error = 0;

    /*
     *  (16)   Issue synchronous read requests.  For each request we
     *         check the sync field to see if the read returned a mouth
     *         shape change, a start of word sync event, or both.  We
     *         continue issuing read requests until we get a return code
     *         of ND_NoWrite, which indicates that the write has finished.
     *         Since this section of code relies on new features of 
     *         Release 2, first check to make sure we have the right OS.
     */

     if ( SysBase->lib_Version >= 36 )
         {
         for ( DoIO(MouthIO);
               MouthIO->voice.message.io_Error != ND_NoWrite;
               DoIO(MouthIO) )

              {
    
              /*
               *  (17)   If bit 1 of the sync field is on, this is a start
               *         of word sync event.  In that case we highlight the
               *         next word.
               */
  
              if ( MouthIO->sync & NDF_READWORD )
                  {
                  if ((Tempptr = strchr(English, ' ')) != NULL)
                      {
                      English = Tempptr + 1;
                      *(English-1) = '\0';
                      }

                  PrintIText(TextWindow->RPort, &HighLight, 0, 0);
                  WordLength      = strlen(OldEnglish) + 1;
                  HighLight.IText = English;
                  OldEnglish      = English;
                  ScreenPos      += WordLength;

                  if (ScreenPos >= EngBytes[LineNum])
                      {
                      HighLight.LeftEdge   = 10;
                      HighLight.TopEdge   += 10;
                      ScreenPos            = 0;
                      English = OldEnglish = EngLine[++LineNum];
                      HighLight.IText      = English;
                      }
                  else
                      HighLight.LeftEdge += 10*WordLength;
                  }
 
              /*
               *  (18)   If bit 0 of the sync field is on, this is a mouth
               *         shape change event.  In that case we update the face.
               *         If this is 1.3 or an earlier version of the OS (i.e., 
               *         before V36) then don't do the face since it uses new 
               *         features of Release 2.
               */

              if (MouthIO->sync & NDF_READMOUTH) 
                  UpdateFace();

              }
          }

     /*   
      *  (19)   The write has finished (return code from last read equals
      *         ND_NoWrite).  We must wait on the write I/O request to
      *         remove it from the message port.
      */

     WaitIO(VoiceIO);

     }


/*
 *  (20)   Program completed, cleanup and return.
 */

Cleanup("Normal completion");

}


void Cleanup(UBYTE *errmsg)
{


/*
 *  (1)   Cleanup and go away.  This routine does not return but EXITs.
 *        Everything it does is pretty self explanatory.
 */

if (FromCLI)
    printf("%s\n\r", errmsg);
if (TextWindow)
    CloseWindow(TextWindow);
if (FaceWindow)
    CloseWindow(FaceWindow);
if (VoiceIO && VoiceIO->message.io_Device)
    CloseDevice(VoiceIO);
if (VoiceIO)
    DeleteExtIO(VoiceIO);
if (VoicePort)
    DeletePort(VoicePort);
if (MouthIO)
    DeleteExtIO(MouthIO);
if (MouthPort)
    DeletePort(MouthPort);
if (GfxBase)
    CloseLibrary(GfxBase);
if (IntuitionBase)
    CloseLibrary(IntuitionBase);

exit(RETURN_OK);
}


void ClearWindow(struct Window *TextWindow)
{
LONG    OldPen;

/*
 *  (1)   Clears a window.
 */

OldPen = (LONG)TextWindow->RPort->FgPen;
SetAPen(TextWindow->RPort, 0);
SetDrMd(TextWindow->RPort, JAM1);
RectFill(TextWindow->RPort, 3, 12, TextWindow->Width-3, TextWindow->Height-2);
SetAPen(TextWindow->RPort, OldPen);
}


void DrawFace()
{

/*
 *  (1)   Draws the initial face.  The variables defined here are used in
 *        UpdateFace() to redraw the mouth shape.
 */

EyesLeft = 15;
EyesTop = 20;
EyesBottom = 35;

XMouthCenter = FaceWindow->Width >> 1;
YMouthCenter = FaceWindow->Height - 25;

SetAPen(FaceWindow->RPort, PEN1);
RectFill(FaceWindow->RPort, 3, 10, FaceWindow->Width-3, FaceWindow->Height-2);

SetAPen(FaceWindow->RPort, PEN0);
RectFill(FaceWindow->RPort, EyesLeft, EyesTop, EyesLeft+25, EyesTop+15);
RectFill(FaceWindow->RPort, EyesLeft+65, EyesTop, EyesLeft+90, EyesTop+15);

SetAPen(FaceWindow->RPort, PEN3);
Move(FaceWindow->RPort, XMouthCenter-(FaceWindow->Width >> 3), YMouthCenter);
Draw(FaceWindow->RPort, XMouthCenter+(FaceWindow->Width >> 3), YMouthCenter);
}


void UpdateFace()
{

/*
 *  (1)   Redraws mouth shape in response to a mouth shape change message
 *        from the device.  Its all pretty self explanatory.
 */

WaitBOVP(&FaceWindow->WScreen->ViewPort);
SetAPen(FaceRast, PEN1);
RectFill(FaceRast, 3, EyesBottom, FaceWindow->Width-3, FaceWindow->Height-2);

LipWidth  = MouthIO->width*3;
LipHeight = MouthIO->height*2/3;

SetAPen(FaceRast, PEN3);
Move(FaceRast, XMouthCenter - LipWidth, YMouthCenter);
Draw(FaceRast, XMouthCenter           , YMouthCenter - LipHeight);
Draw(FaceRast, XMouthCenter + LipWidth, YMouthCenter);
Draw(FaceRast, XMouthCenter,            YMouthCenter + LipHeight);
Draw(FaceRast, XMouthCenter - LipWidth, YMouthCenter);
}
