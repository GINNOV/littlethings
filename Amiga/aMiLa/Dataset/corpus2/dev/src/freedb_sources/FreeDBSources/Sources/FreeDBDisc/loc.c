
#include "class.h"

/***********************************************************************/

static LONG ids1[] =
{
    MSG_Get,
    MSG_Get_Help,
    MSG_Save,
    MSG_Save_Help,
    MSG_Stop,
    MSG_Stop_Help,
    MSG_Disc,
    MSG_Disc_Help,
    MSG_Matches,
    MSG_Matches_Help,
    MSG_Edit,
    MSG_Edit_Help,

    MSG_TextDiscID,
    MSG_TextDiscIDHelp,
    MSG_TextCateg,
    MSG_TextCategHelp,
    MSG_TextTitle,
    MSG_TextTitleHelp,
    MSG_TextArtist,
    MSG_TextArtistHelp,
    MSG_TextTracks,
    MSG_TextTracksHelp,
    MSG_TextYear,
    MSG_TextYearHelp,
    MSG_TextGenre,
    MSG_TextGenreHelp,
    MSG_TextExtended,
    MSG_TextExtendedHelp,
    MSG_TextHelp,

    MSG_TitleAudio,
    MSG_TitleData,
    MSG_TitleTrack,
    MSG_TitleContents,
    MSG_TitleDiscID,
    MSG_TitleCateg,
    MSG_TitleTitle,
    MSG_TitleArtist,
    MSG_TitleTime,
    MSG_TitleYear,
    MSG_TitleGenre,
    MSG_TitleExtended,
    MSG_TitleHelp,

    MSG_MatchesDiscID,
    MSG_MatchesCateg,
    MSG_MatchesTitle,
    MSG_MatchesArtist,
    MSG_MatchesHelp,

    MSG_EditDiscID,
    MSG_EditCateg,
    MSG_EditTitle,
    MSG_EditArtist,
    MSG_EditTracks,
    MSG_EditYear,
    MSG_EditGenre,
    MSG_EditExtended,
    MSG_EditTTitle,
    MSG_EditTTitleHelp,
    MSG_EditUse,
    MSG_EditUseHelp,
    MSG_EditRestore,
    MSG_EditRestoreHelp,
    MSG_EditSubmit,
    MSG_EditSubmitHelp,
    MSG_EditHelp,

    MSG_Bar,
    MSG_ViewMode_TextGfx,
    MSG_ViewMode_Gfx,
    MSG_ViewMode_Text,
    MSG_ViewMode,
    MSG_ViewMode_Help,
    MSG_BorderLess,
    MSG_BorderLess_Help,
    MSG_Sunny,
    MSG_Sunny_Help,
    MSG_Raised,
    MSG_Raised_Help,
    MSG_Small,
    MSG_Small_Help,
    MSG_Copyright,
    MSG_BarForced,

    MSG_Welcome,
    MSG_ReadingTOC,
    MSG_LocalFound,
    MSG_LocalMulti,
    MSG_RemoteFound,
    MSG_RemoteMulti,
    MSG_SaveCancel,
    MSG_SaveFile,
    MSG_Saved,
    MSG_NothingToPlay,
    MSG_CantPlay,
    MSG_Playing,

    -1
};

static STRPTR staticStrings[] =
{
    "Get",
    "Look up a disc.",
    "Save",
    "Save disc to the local cache.",
    "Stop",
    "Interrupt remote connections.",
    "Disc",
    "Switch to disc info page.",
    "Matches",
    "Switch to multi matches page.",
    "Edit",
    "Switch to edit page.",

    "DiscID:",
    "The freedb ID of the disc.",
    "Categ:",
    "The category the disc belongs to.",
    "Title:",
    "The title of the disc.",
    "Artist:",
    "The author of the disc.",
    "Tracks:",
    "The number of the\ntracks on the disc.",
    "Year:",
    "The year the disc was created.",
    "Genre:",
    "The musical genre of the disc.",
    "Extented:",
    "Extented Information.",
    "Disc informations.",

    "Audio",
    "Data",
    "\33bTrack",
    "\33bType",
    "\33bDiscID",
    "\33bCateg",
    "\33bTitle",
    "\33bArtist",
    "\33bTime",
    "\33bYear",
    "\33bGenre",
    "\33bExtented",
    "Tracks informations.",

    "\33bDiscID",
    "\33bCateg",
    "\33bTitle",
    "\33bArtist",
    "Multi matches discs list.",

    "_DiscID",
    "_Categ",
    "_Title",
    "_Artist",
    "Trac_ks",
    "_Year",
    "_Genre",
    "_Extented",
    "Title %ld",
    "Title of the n-th track.",
    "_Use",
    "Set disc information.",
    "_Restore",
    "Restore disc information.",
    "_Submit",
    "Set disc information and\nsend them to the server.",
    "Edit disc information.",

    "Bar",
    "Icons and text",
    "Icons only",
    "Text only",
    "_Appears as",
    "Adjust the view of the bar.",
    "_Borderless",
    "No border buttons.",
    "Sunn_y",
    "Mouse-over colored buttons.",
    "_Raised",
    "Mouse-over bordered buttons.",
    "_Small",
    "Small buttons.",
    "Copyright 2001 Alfonso Ranieri <alforan@tin.it>",
    "\33c\33iThe bar is forced to text only!",

    "Welcome to FreeDB!",
    "Reading TOC...",
    "Disc found in local cache.",
    "Multi matches in local cache.",
    "Disc found on server.",
    "Multi matches on server.",
    "*_Save|_Cancel",
    "Disco: %08lx  Categ: %s\nalready exists. Replace it?",
    "Disc saved.",
    "Nothing to play.",
    "Can't play track %ld.",
    "Playing from track %ld..."
};

static STRPTR translatedStrings[sizeof(ids1)/sizeof(LONG)-1];
STRPTR *strings;

/***********************************************************************/

static LONG ids2[] =
{
    MSG_ViewMode_TextGfx,
    MSG_ViewMode_Gfx,
    MSG_ViewMode_Text,
    -1,
};

STRPTR cyclerStrings[sizeof(ids2)/sizeof(LONG)];

/***********************************************************************/

void ASM
initStrings(REG(a0) struct libBase *base)
{
    register STRPTR *s, *ss;
    register LONG   *id;

    if ((base->localeBase = OpenLibrary("locale.library",37)) && (base->cat = OpenCatalogA(NULL,CATNAME,NULL)))
    {
        strings = translatedStrings;

        for (id = ids1, s = strings, ss = staticStrings; *id!=-1; id++, s++, ss++)
            *s = GetCatalogStr(libBase->cat,*id,*ss);

    }
    else strings = staticStrings;

    for (s = cyclerStrings, id = ids2; *id!=-1; s++, id++)
        *s = strings[*id];
    *s = NULL;
}

/***********************************************************************/
