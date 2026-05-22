//////////////////////////////////////////////////////////////////////////////
// ReqTools.hpp - AFrame v1.0 © 1996 Synthetic Input
//
// ReqTools C++ Object utilizing reqtools.library version 38.1296
// by Nico François.  ReqTools is © Nico François
// 
//
// Deryk B Robosson
// Jeffry A Worth
// January 20, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFREQTOOLS_HPP__
#define __AFREQTOOLS_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "AFrame:include/AFrame.hpp"
#include "AFrame:include/Object.hpp"
#include "AFrame:include/string.hpp"
#include <exec/memory.h>
#include <exec/execbase.h>
#include <utility/tagitem.h>
#include <stdlib.h>
#include <string.h>

#include <libraries/reqtools.h>
#include <proto/reqtools.h>

#define REG register

BOOL __asm __saveds file_filterfunc (
        REG __a0 struct Hook *, REG __a2 struct rtFileRequester *,
        REG __a1 struct FileInfoBlock *
    );

BOOL __asm __saveds font_filterfunc (
        REG __a0 struct Hook *, REG __a2 struct rtFontRequester *,
        REG __a1 struct TextAttr *
    );

BOOL __asm __saveds vol_filterfunc (
        REG __a0 struct Hook *, REG __a2 struct rtFileRequester *,
        REG __a1 struct rtVolumeEntry *
    );

//////////////////////////////////////////////////////////////////////////////
// Req_Tools Class
class AFReqTools : public AFObject
{
public:

    AFReqTools();
    ~AFReqTools();

    virtual void DestroyObject();
    virtual char *ObjectType() { return "ReqTools"; };

// Methods

    virtual void Create();
    virtual BOOL EZRequest(char *bodytext, char *gadtext);
    virtual BOOL EZRequestA(char *bodytext, char *gadtext, struct rtReqInfo *reqinfo, ULONG *taglist);
    virtual BOOL ScreenMode();
    virtual BOOL ScreenModeA(ULONG *taglist);
    virtual BOOL FileRequest();
    virtual BOOL FileRequestA(ULONG *taglist);
    virtual BOOL FilesRequest();
    virtual BOOL FilesRequestA(ULONG *taglist);
    virtual BOOL DirRequest();
    virtual BOOL VolumeRequest();
    virtual BOOL FontRequest();
    virtual BOOL FontRequestA(ULONG *taglist);
    virtual BOOL PaletteRequest();
    virtual BOOL PaletteRequestA(ULONG *taglist);
    virtual void ScreenToFront(struct Screen *screen);
    virtual void SetWaitPointer(struct Window *window);
    virtual BOOL LockWindow(struct Window *window);
    virtual void UnlockWindow(struct Window *window, APTR winlock);
    virtual ULONG GetLong(char *title, struct rtReqInfo *reqinfo);
    virtual ULONG GetLongA(char *title, struct rtReqInfo *reqinfo, ULONG *taglist);
    virtual ULONG GetString(UBYTE *buffer, ULONG maxchars, char *title, struct rtReqInfo *reqinfo);
    virtual ULONG GetStringA(UBYTE *buffer, ULONG maxchars, char *title, struct rtReqInfo *reqinfo, ULONG *taglist);
    virtual ULONG GetVScreenSize(struct Screen *screen, ULONG *widthptr, ULONG *heightptr);
    AFString* GetFileName();    // returns full path and filename

    struct rtReqInfo *m_reqinfo;
    struct rtFileRequester *m_filerequester;
    struct rtFontRequester *m_fontrequester;
    struct rtScreenModeRequester *m_screenmoderequester;
    struct rtFileList *m_filelist, *m_tempfilelist;
    struct Hook m_filterhook, m_font_filterhook, m_volume_filterhook;
    APTR m_windowlock;
    ULONG color, longvar;
    char buffer[256], filename[256];
};

//////////////////////////////////////////////////////////////////////////////
#endif // __AFREQTOOLS_HPP__
