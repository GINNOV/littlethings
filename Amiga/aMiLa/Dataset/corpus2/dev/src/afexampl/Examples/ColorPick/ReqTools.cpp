//////////////////////////////////////////////////////////////////////////////
// ReqTools.cpp - AFrame v1.0 © 1996 Synthetic Input
//
// ReqTools C++ Object utilizing reqtools.library version 38.1296
// by Nico François.  ReqTools is © Nico François
// 
//
// Deryk B Robosson
// Jeffry A Worth
// January 20, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "AFRAME:include/reqtools.hpp"

extern struct ExecBase *SysBase;
extern struct ReqToolsBase *ReqToolsBase;

#ifndef __AFREQTOOLS_DEFTAGS__
#define __AFREQTOOLS_DEFTAGS__

ULONG def_screentags[] = { RTSC_Flags,SCREQF_DEPTHGAD|SCREQF_SIZEGADS|SCREQF_AUTOSCROLLGAD|SCREQF_OVERSCANGAD,TAG_END } ;
ULONG def_filetags[] = { RTFI_FilterFunc,TAG_END };
ULONG def_multifiletags[] = { RTFI_FilterFunc,RTFI_Flags,FREQF_MULTISELECT,TAG_END };
ULONG def_dirtags[] = { RTFI_Flags,FREQF_NOFILES,TAG_END };
ULONG def_volumetags[] = { RTFI_FilterFunc,RTFI_VolumeRequest,0,TAG_END };
ULONG def_fonttags[] = { RTFO_FilterFunc,TAG_END };
ULONG def_palettetags[] = { TAG_END };
ULONG def_getlong[] = { RTGL_ShowDefault,FALSE,RTGL_Min,0,RTGL_Max,999999,TAG_END };
ULONG def_getstring[] = { RTGS_GadFmt,(ULONG)"_Ok|_Cancel",RTGS_BackFill,FALSE,RTGS_Flags,GSREQF_CENTERTEXT|GSREQF_HIGHLIGHTTEXT,TAG_MORE,RT_Underscore,'_',TAG_END };

#endif //__AFREQTOOLS_DEFTAGS__

//////////////////////////////////////////////////////////////////////////////
//

AFReqTools::AFReqTools()
    :color(0),
//    filename[0](NULL),
    m_filelist(NULL),
    m_screenmoderequester(NULL),
    m_filerequester(NULL),
    m_fontrequester(NULL)
{
    filename[0]=NULL;

    if(!ReqToolsBase)
        if(!(ReqToolsBase=(struct ReqToolsBase *)OpenLibrary((UBYTE*)REQTOOLSNAME,(ULONG)REQTOOLSVERSION)))
            printf("Unable to open reqtools.library version %ld\n",REQTOOLSVERSION);
}

AFReqTools::~AFReqTools()
{
    if(ReqToolsBase) CloseLibrary((struct Library*)ReqToolsBase),ReqToolsBase=NULL;

    DestroyObject();
}

void AFReqTools::DestroyObject()
{
    if(m_filelist)  rtFreeFileList(m_filelist);
    if(m_screenmoderequester) rtFreeRequest(m_screenmoderequester);
    if(m_filerequester) rtFreeRequest(m_filerequester);
    if(m_fontrequester) rtFreeRequest(m_fontrequester);

    delete m_filelist;
    delete m_screenmoderequester;
    delete m_filerequester;
    delete m_fontrequester;

    color=0;
    filename[0]=NULL;
    m_filelist=NULL;
    m_screenmoderequester=NULL;
    m_filerequester=NULL;
    m_fontrequester=NULL;
}

void AFReqTools::Create()
{
}

BOOL AFReqTools::EZRequest(char *text, char *gadfmt)
{
    return ::rtEZRequest(text,gadfmt,NULL,NULL);
}

BOOL AFReqTools::EZRequestA(char *text, char *gadfmt, struct rtReqInfo *reqinfo, ULONG taglist[])
{
    return ::rtEZRequest(text,gadfmt,reqinfo,(struct TagItem *)taglist);
}

BOOL AFReqTools::ScreenMode()
{
    if(SysBase->LibNode.lib_Version<37) {
        rtEZRequestTags("ScreenMode requesters require\n Kickstart 2.0 or higher.\n","_Ok",NULL,NULL,RT_Underscore,'_',TAG_END);
        return FALSE;
    } else {
        if(m_screenmoderequester=(struct rtScreenModeRequester*)rtAllocRequestA(RT_SCREENMODEREQ,NULL)) {
            if(!rtScreenModeRequest(m_screenmoderequester,(char *)"Select a Screen Mode",(ULONG)RTSC_Flags,
                                    (ULONG)(SCREQF_DEPTHGAD|SCREQF_SIZEGADS|SCREQF_AUTOSCROLLGAD|SCREQF_OVERSCANGAD),(ULONG)TAG_END))
                return FALSE;
            else return TRUE;
        } else { 
            rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
            return FALSE;
          }
    }
}

BOOL AFReqTools::ScreenModeA(ULONG taglist[])
{
    if(SysBase->LibNode.lib_Version<37) {
        rtEZRequestTags("ScreenMode requesters require\n Kickstart 2.0 or higher.\n","_Ok",NULL,NULL,RT_Underscore,'_',TAG_END);
        return FALSE;
    } else {
        if(m_screenmoderequester=(struct rtScreenModeRequester*)rtAllocRequestA(RT_SCREENMODEREQ,NULL)) {
            if(!rtScreenModeRequestA(m_screenmoderequester,(char *)"Select a Screen Mode",(struct TagItem *)taglist))
                return FALSE;
            else return TRUE;

        } else { 
            rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
            return FALSE;
          }
    }
}

BOOL AFReqTools::FileRequest()
{
    if(m_filerequester=(struct rtFileRequester*)rtAllocRequestA(RT_FILEREQ,NULL)) {
        m_filterhook.h_Entry=(ULONG(*)())file_filterfunc;
        if(!rtFileRequest(m_filerequester,filename,"Select a File",RTFI_FilterFunc,&m_filterhook,TAG_END))
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::FileRequestA(ULONG taglist[])
{
    if(m_filerequester=(struct rtFileRequester*)rtAllocRequestA(RT_FILEREQ,NULL)) {
        m_filterhook.h_Entry=(ULONG(*)())file_filterfunc;
        if(!rtFileRequestA(m_filerequester,filename,"Select a File",(struct TagItem *)taglist))
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::FilesRequest()
{
    if(m_filerequester=(struct rtFileRequester*)rtAllocRequestA(RT_FILEREQ,NULL)) {
        m_filterhook.h_Entry=(ULONG(*)())file_filterfunc;
        m_filelist=(struct rtFileList*)rtFileRequest(m_filerequester,filename,"Select Files",RTFI_FilterFunc,&m_filterhook,RTFI_Flags,FREQF_MULTISELECT,TAG_END);
        if(!m_filelist)
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::FilesRequestA(ULONG taglist[])
{
    if(m_filerequester=(struct rtFileRequester*)rtAllocRequestA(RT_FILEREQ,NULL)) {
        m_filterhook.h_Entry=(ULONG(*)())file_filterfunc;
        m_filelist=(struct rtFileList*)rtFileRequestA(m_filerequester,filename,"Select Files",(struct TagItem *)taglist);
        if(!m_filelist)
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::DirRequest()
{
    if(m_filerequester=(struct rtFileRequester*)rtAllocRequestA(RT_FILEREQ,NULL)) {
        if(!rtFileRequest(m_filerequester,filename,"Select a Directory",RTFI_Flags,FREQF_NOFILES,TAG_END))
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::VolumeRequest()
{
    if(m_filerequester=(struct rtFileRequester*)rtAllocRequestA(RT_FILEREQ,NULL)) {
        m_volume_filterhook.h_Entry=(ULONG (*)())vol_filterfunc;
        if(!rtFileRequest(m_filerequester,filename,"Select a Volume",RTFI_FilterFunc,&m_volume_filterhook,RTFI_VolumeRequest,0,TAG_END))
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::FontRequest()
{
    if(m_fontrequester=(struct rtFontRequester*)rtAllocRequestA(RT_FONTREQ,NULL)) {
        m_fontrequester->Flags=FREQF_STYLE|FREQF_COLORFONTS;
        m_font_filterhook.h_Entry=(ULONG (*)())font_filterfunc;
        if(!rtFontRequest(m_fontrequester,"Select a Font",RTFO_FilterFunc,&m_font_filterhook,TAG_END))
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::FontRequestA(ULONG taglist[])
{
    if(m_fontrequester=(struct rtFontRequester*)rtAllocRequestA(RT_FONTREQ,NULL)) {
        m_fontrequester->Flags=FREQF_STYLE|FREQF_COLORFONTS;
        m_font_filterhook.h_Entry=(ULONG (*)())font_filterfunc;
        if(!rtFontRequestA(m_fontrequester,"Select a Font",(struct TagItem *)taglist))
            return FALSE;
        else return TRUE;
    } else {
        rtEZRequest((char *)"Out of memory!",(char *)"Ok!",NULL,NULL);
        return FALSE;
      }
}

BOOL AFReqTools::PaletteRequest()
{
    color=rtPaletteRequest("Change Palette",NULL,TAG_END);

    if(color==-1)
        return FALSE;
    else return TRUE;
}

BOOL AFReqTools::PaletteRequestA(ULONG taglist[])
{
    color=rtPaletteRequestA("Change Palette",m_reqinfo,(struct TagItem *)taglist);

    if(color==-1)
        return FALSE;
    else return TRUE;
}

void AFReqTools::ScreenToFront(struct Screen *screen)
{
    rtScreenToFrontSafely(screen);
}

void AFReqTools::SetWaitPointer(struct Window *win)
{
    rtSetWaitPointer(win);
}

BOOL AFReqTools::LockWindow(struct Window *win)
{
    m_windowlock=(APTR)rtLockWindow(win);
    return TRUE;
}

void AFReqTools::UnlockWindow(struct Window *win, APTR winlock)
{
    rtUnlockWindow(win,winlock);
}

ULONG AFReqTools::GetLong(char *title, struct rtReqInfo *reqinfo)
{
    ULONG ret;
    if(!(ret=rtGetLong((ULONG *)&longvar,title,reqinfo,RTGL_ShowDefault,FALSE,RTGL_Min,0,RTGL_Max,999999,TAG_END)))
        return FALSE;
    else return ret;
}

ULONG AFReqTools::GetLongA(char *title, struct rtReqInfo *reqinfo, ULONG taglist[])
{
    ULONG ret;
    if(!(ret=rtGetLongA((ULONG *)&longvar,title,reqinfo,(struct TagItem *)taglist)))
        return FALSE;
    else return ret;
}

ULONG AFReqTools::GetString(UBYTE *buffer, ULONG maxchars, char *title, struct rtReqInfo *reqinfo)
{
    ULONG ret;

    if(!(ret=rtGetString(buffer, maxchars, title, reqinfo, RTGS_GadFmt, "_Ok|_Cancel",RTGS_BackFill,FALSE,RTGS_Flags,GSREQF_CENTERTEXT|GSREQF_HIGHLIGHTTEXT,TAG_MORE,RT_Underscore,'_',TAG_END)))
        return FALSE;
    else return ret;
}

ULONG AFReqTools::GetStringA(UBYTE *buffer, ULONG maxchars, char *title, struct rtReqInfo *reqinfo, ULONG taglist[])
{
    ULONG ret;

    if(!(ret=rtGetStringA(buffer, maxchars, title, reqinfo, (struct TagItem *)taglist)))
        return FALSE;
    else return ret;
}

ULONG AFReqTools::GetVScreenSize(struct Screen *screen, ULONG *widthptr, ULONG *heightptr)
{
    ULONG spacing;

    if(!(spacing=rtGetVScreenSize(screen,widthptr,heightptr)))
        return FALSE;
    else return spacing;
}


BOOL __asm __saveds file_filterfunc (register __a0 struct Hook *filterhook,
       register __a2 struct rtFileRequester *req,
       register __a1 struct FileInfoBlock *fib)
{
    // examine fib to decide if you want this file in the requester
    return TRUE;
}

BOOL __asm __saveds vol_filterfunc (
    REG __a0 struct Hook *hook,
    REG __a2 struct rtFileRequester *filereq,
    REG __a1 struct rtVolumeEntry *volentry
    )
{
    // examine volentry to decide which volumes you want in this requester
    return TRUE;
}

BOOL __asm __saveds font_filterfunc (
    REG __a0 struct Hook *hook,
    REG __a2 struct rtFontRequester *fontreq,
    REG __a1 struct TextAttr *textattr
    )
{
    // examine textattr to decide which fonts you want in this requester
    return TRUE;
}

AFString* AFReqTools::GetFileName()
{
    AFString temp;

    if(m_filerequester->Dir) {
        temp=m_filerequester->Dir;
        if(temp[temp.length()-1] != ':') {
            temp += "/";
            temp += filename;
            return (AFString*)temp;
        } else {
            temp += filename;
            return (AFString*)temp;
          }
    } else {
        temp = filename;
        return (AFString*)temp;
      }
}
