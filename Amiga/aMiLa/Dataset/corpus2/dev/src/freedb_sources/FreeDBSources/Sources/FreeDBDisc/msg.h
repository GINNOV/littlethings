#ifndef _MSG_H
#define _MSG_H

/***********************************************************************/

enum
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
    MSG_Playing
};

/***********************************************************************/

#define CATNAME "FreeDBDisc.catalog"

/***********************************************************************/

#endif /* _MSG_H */
