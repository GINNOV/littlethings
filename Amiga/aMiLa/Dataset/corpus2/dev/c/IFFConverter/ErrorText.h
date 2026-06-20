/*
**     $VER: ErrorText.h 0.01 (17-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 17-02-95  Version 0.01
**
**  ErrorText.h contains strings of texts. These string are meant for
**  use with the function 'DisplayError'.
**
*/

char ESW_Title[]   = "What am I supposed to do";
char ESW_PicInfo[] = "Picture Info";


char EST_LockErr[]          = "I couldn't get a lock on\n%s";
char EST_OpenLibErr[]       = "Sorry, I need %s.library V%ld+";
char EST_OpenErr[]          = "I could not open %s";
char EST_AllocErr[]         = "I could not allcoate\n%s for you";
char EST_AllocMemErr[]      = "I could not allocate %ld bytes\nof memory for you";
char EST_NoVisIErr[]        = "I could not get VisualInfo";
char EST_NoIFFErr[]         = "File is not an IFF File";
char EST_NoIFFILBMErr[]     = "%s\nis an IFF, but not IFF ILBM";
char EST_Fail[]             = "%s failed";
char EST_NotFound[]         = "%s not found";
char EST_GadCreate[]        = "I could not create Gadget #%ld";
char EST_AslNoFreeStore[]   = "Asl was unable to allocate enough memory";
char EST_AslNoMoreEntries[] = "AslRequester could not be opened,\ndue to unavailable screenmode";
char EST_NotImplemented[]   = "Function '%s'\nis not implemented.";
char EST_FileExistsAsk[]    = "File %s\nalready exists.";

char ESG_RetryOverwriteCancel[] = "Retry|Overwrite|Cancel";
char ESG_RetryCancel[]          = "Retry|Cancel";
char ESG_Okay[]                 = "Okay";


enum ErrorExitType {
   Lib_Exit,
   Clean_Exit,
   No_Exit
};


APTR IFFerror__NULL_Title_Okay[] = {
   NULL,
   &ESW_Title,
   &ESG_Okay
};

APTR IFFerror__PanelWindow_Title_Okay[] = {
   &PanelWindow,
   &ESW_Title,
   &ESG_Okay
};

APTR IFFerror__PanelWindow_Title_RetryCancel[] = {
   &PanelWindow,
   &ESW_Title,
   &ESG_RetryCancel
};

APTR IFFerror__PanelWindow_Title_ROverwC[] = {
   &PanelWindow,
   &ESW_Title,
   &ESG_RetryOverwriteCancel
};
