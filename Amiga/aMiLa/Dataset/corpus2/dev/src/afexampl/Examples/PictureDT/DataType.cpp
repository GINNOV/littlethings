//////////////////////////////////////////////////////////////////////////////
// DataType.cpp
//
// Deryk Robosson
// March 9, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/DataType.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFDataType::AFDataType()
{
    m_dtGlobal.dtAdded=FALSE;
    m_dtGlobal.dtWindow=NULL;
    m_dtGlobal.o=NULL;
    m_dtGlobal.dtt.MethodID=DTM_TRIGGER;

    if(!DataTypesBase)
        if(!(DataTypesBase=(struct Library*)OpenLibrary((UBYTE*)"datatypes.library",(ULONG)39)))
            printf("Failed to open datatypes.library v39 or greater\n");
}

// Remove object from window if it has been added
// and dispose of it
AFDataType::~AFDataType()
{
    if(m_dtGlobal.o != NULL) {
        if(m_dtGlobal.dtAdded) {
            RemoveObject();
            m_dtGlobal.dtAdded=FALSE;
        }

        DisposeDTObject(m_dtGlobal.o);
        delete m_dtGlobal.o;
        m_dtGlobal.o=NULL;
    }
    if(DataTypesBase) CloseLibrary((struct Library*)DataTypesBase),DataTypesBase=NULL;
}

void AFDataType::DestroyObject()
{
}

// Check to see if we have a DT to support
// the file requested
BOOL AFDataType::IsDataType(char *file_name)
{
    BPTR lock;
    BOOL it_is;

    it_is = FALSE;
    if (lock = Lock((STRPTR)file_name, ACCESS_READ)) {
        if (m_dtGlobal.dtn = ObtainDataTypeA(DTST_FILE, (APTR)lock, NULL)) {
            switch(m_dtGlobal.dtn->dtn_Header->dth_GroupID) {
            case GID_PICTURE:
            case GID_SYSTEM:
            case GID_TEXT:
            case GID_DOCUMENT:
            case GID_SOUND:
            case GID_INSTRUMENT:
            case GID_MUSIC:
            case GID_ANIMATION:
            case GID_MOVIE:
                it_is=TRUE;
                break;
            default:
                it_is=FALSE;
                break;
            }
            ReleaseDataType(m_dtGlobal.dtn);
        }
        UnLock(lock);
   }
   return(it_is);
}

// Fill m_dtGlobal.dtInfo struct if a DT is
// found to support file type
BOOL AFDataType::DTInfo(char *file_name)
{
    struct DataTypeHeader *dth;
    BPTR lock;
    char *buffer;

    if (lock = Lock((STRPTR)file_name, ACCESS_READ)) {
        if (m_dtGlobal.dtn = ObtainDataTypeA(DTST_FILE, (APTR)lock, NULL)) {
            dth=m_dtGlobal.dtn->dtn_Header;

            m_dtGlobal.dtInfo.description=dth->dth_Name;
            m_dtGlobal.dtInfo.name=dth->dth_BaseName;
            m_dtGlobal.dtInfo.type=GetDTString((dth->dth_Flags & DTF_TYPE_MASK)+DTMSG_TYPE_OFFSET);
            m_dtGlobal.dtInfo.group=GetDTString(dth->dth_GroupID);
            m_dtGlobal.dtInfo.id=IDtoStr((LONG)dth->dth_ID,buffer);

            ReleaseDataType(m_dtGlobal.dtn);
        } else {
            UnLock(lock);
            return FALSE;
          }
    } else return FALSE;
    return TRUE;
}

// Fill m_dtGlobal.dtInfo struct if a DT is
// found to support object type
BOOL AFDataType::DTInfo()
{
    struct DataTypeHeader *dth;
    char *buffer;

    if(m_dtGlobal.o != NULL) {
        if(!(GetDTAttrs(m_dtGlobal.o,DTA_DataType,(ULONG)&m_dtGlobal.dtn,TAG_DONE)))
            return FALSE;
        else {
            dth=m_dtGlobal.dtn->dtn_Header;
            m_dtGlobal.dtInfo.description=dth->dth_Name;
            m_dtGlobal.dtInfo.name=dth->dth_BaseName;
            m_dtGlobal.dtInfo.type=GetDTString((dth->dth_Flags & DTF_TYPE_MASK)+DTMSG_TYPE_OFFSET);
            m_dtGlobal.dtInfo.group=GetDTString(dth->dth_GroupID);
            m_dtGlobal.dtInfo.id=IDtoStr((LONG)dth->dth_ID,buffer);
            return TRUE;
        }
    } else return FALSE;
}

// Save object to clipboard or to a file
BOOL AFDataType::SaveObject(ULONG stype, char *file_name, ULONG mode)
{
    struct DiskObject   *dob;
    struct VoiceHeader  *vhdr;
    BPTR                fh;
    AFString            buffer;

    if(m_dtGlobal.o != NULL) {
        if(stype==DTST_CLIPBOARD) {
            m_dtGlobal.dtg.MethodID=DTM_COPY;
            m_dtGlobal.dtg.dtg_GInfo=NULL;
            if(!(DoDTMethodA(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,(Msg)&m_dtGlobal.dtg)))
                return FALSE;
            else return TRUE;
        }
        if(stype==DTST_FILE) {
            if(!(GetDTAttrs(m_dtGlobal.o,DTA_DataType,(ULONG)&m_dtGlobal.dtn,TAG_DONE)))
                return FALSE;
            else {
                if(m_dtGlobal.dtn->dtn_Header->dth_GroupID==GID_SOUND) {
                    GetDTAttrs (m_dtGlobal.o, SDTA_VoiceHeader, &vhdr, TAG_DONE);
                    vhdr->vh_SamplesPerSec=(715909 * 5) / (UWORD)330;
                    vhdr->vh_Compression=CMP_NONE;
                    vhdr->vh_Volume=64;
                }
            }

            if(!(fh=Open(file_name,MODE_NEWFILE)))
                return FALSE;

            m_dtGlobal.dtw.MethodID=DTM_WRITE;
            m_dtGlobal.dtw.dtw_GInfo=NULL;
            m_dtGlobal.dtw.dtw_FileHandle=fh;
            m_dtGlobal.dtw.dtw_Mode=mode;
            m_dtGlobal.dtw.dtw_AttrList=NULL;

            if(!(DoDTMethodA(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,(Msg)&m_dtGlobal.dtw))) {
                Close(fh);
                return FALSE;
            } else {
                buffer="ENV:Sys/def_";
                buffer+=m_dtGlobal.dtn->dtn_Header->dth_BaseName;

                if((dob=GetDiskObject(buffer))==NULL)
                    dob=GetDefDiskObject(WBPROJECT);
                if(dob) {
                    PutDiskObject((UBYTE*)file_name,dob);
                    FreeDiskObject(dob);
                }
                Close(fh);
                return TRUE;
              }
        } else return FALSE;
    } else return FALSE;
}

// Print DataType Object
BOOL AFDataType::PrintObject(AFWindow *window)
{
    if(m_dtGlobal.o != NULL) {
        if(m_dtGlobal.dtPrint.mp=CreateMsgPort()) {
            if(!(m_dtGlobal.dtPrint.pio=(union printerIO*)CreateIORequest(m_dtGlobal.dtPrint.mp,sizeof(union printerIO)))) {
                DeleteMsgPort(m_dtGlobal.dtPrint.mp);
                return FALSE;
            }
            if(OpenDevice((UBYTE*)"printer.device",(ULONG)0,(struct IORequest*)m_dtGlobal.dtPrint.pio,(ULONG)0)) {
                PrintComplete();
                return FALSE;
            } else {
                m_dtGlobal.dtPrint.dtp.MethodID=DTM_PRINT;
                m_dtGlobal.dtPrint.dtp.dtp_GInfo=NULL;
                m_dtGlobal.dtPrint.dtp.dtp_PIO=m_dtGlobal.dtPrint.pio;
                m_dtGlobal.dtPrint.dtp.dtp_AttrList=NULL;

                if(!(PrintDTObjectA(m_dtGlobal.o,window->m_pWindow,(struct Requester*)NULL,&m_dtGlobal.dtPrint.dtp))) {
                    PrintComplete();
                    return FALSE;
                } else return TRUE;
              }
        } else return FALSE;
    } else return FALSE;
}

// Abort PrintObject Job
BOOL AFDataType::AbortPrint()
{
    if(m_dtGlobal.o != NULL) {
        if(!(DoMethod(m_dtGlobal.o,DTM_ABORTPRINT,NULL)))
            return FALSE;
        else {
            PrintComplete();
            return TRUE;
        }
    } else return FALSE;
}

// PrintObject failure/success cleanup
BOOL AFDataType::PrintComplete()
{
    if(m_dtGlobal.dtPrint.pio) {
        CloseDevice((struct IORequest*)m_dtGlobal.dtPrint.pio);
        m_dtGlobal.dtPrint.mp=m_dtGlobal.dtPrint.pio->ios.io_Message.mn_ReplyPort;
        DeleteIORequest((struct IORequest*)m_dtGlobal.dtPrint.pio);
        DeleteMsgPort(m_dtGlobal.dtPrint.mp);
        m_dtGlobal.dtPrint.pio=NULL;
        return TRUE;
    } else return FALSE;
}

// Doesn't yet work :(
BOOL AFDataType::LoadClipBoard(LONG unit)
{
    Object *newo;
    ULONG type;
    struct IFFHandle *iff=NULL;

    if(!(type=InterrogateClipBoard(unit)))
        return FALSE;

    if(!(IFFParseBase=(struct Library*)OpenLibrary((UBYTE*)"iffparse.library",(ULONG)0L)))
        return FALSE;
    if(!(iff=AllocIFF()))
        return FALSE;
    
    if(!(iff->iff_Stream = (ULONG)OpenClipboard(unit)))
        return FALSE;
    else InitIFFasClip(iff);

    if(!(newo=NewDTObject((APTR)unit,DTA_SourceType,DTST_CLIPBOARD,
                          DTA_Handle, iff, DTA_GroupID, type, TAG_DONE)))
        return FALSE;
    else {
        if(iff->iff_Stream)
            CloseClipboard((struct ClipboardHandle*)iff->iff_Stream);

        if(iff) {
            FreeIFF(iff);
            iff=NULL;
        }

        if(IFFParseBase) {
            CloseLibrary((struct Library*)IFFParseBase);
            IFFParseBase=NULL;
        }
        m_dtGlobal.o=newo;
        if(newo)
            DisposeDTObject(newo);
        return TRUE;
    }

}

// Find out what's on the clipboard and if we've got a DT to support
// it, if so return the type found.
ULONG AFDataType::InterrogateClipBoard(LONG unit)
{
    struct IFFHandle *iff = NULL;
    ULONG type;

    if(!(IFFParseBase=(struct Library*)OpenLibrary((UBYTE*)"iffparse.library",(ULONG)0L)))
        return FALSE;

    if(!(iff=AllocIFF()))
        return FALSE;

    if(!(iff->iff_Stream = (ULONG)OpenClipboard(unit)))
        return FALSE;
    else InitIFFasClip(iff);

    if (m_dtGlobal.dtn = ObtainDataTypeA(DTST_CLIPBOARD, iff, NULL)) {
        switch(m_dtGlobal.dtn->dtn_Header->dth_GroupID) {
        case GID_PICTURE:
            type=GID_PICTURE;
        case GID_SYSTEM:
            type=GID_SYSTEM;
            break;
        case GID_TEXT:
            type=GID_TEXT;
            break;
        case GID_DOCUMENT:
            type=GID_DOCUMENT;
            break;
        case GID_SOUND:
            type=GID_SOUND;
            break;
        case GID_INSTRUMENT:
            type=GID_INSTRUMENT;
            break;
        case GID_MUSIC:
            type=GID_MUSIC;
            break;
        case GID_ANIMATION:
            type=GID_ANIMATION;
            break;
        case GID_MOVIE:
            type=GID_MOVIE;
            break;
        default:
            type=0; // if we reach here, either the clipboard has no data or
            break;  // the system has no datatype to support it
        }
        if(m_dtGlobal.dtn)
            ReleaseDataType(m_dtGlobal.dtn);
    }

    if(iff->iff_Stream)
        CloseClipboard((struct ClipboardHandle*)iff->iff_Stream);

    if(iff) {
        FreeIFF(iff);
        iff=NULL;
    }

    if(IFFParseBase) {
        CloseLibrary((struct Library*)IFFParseBase);
        IFFParseBase=NULL;
    }

    return type;    
}

//  Add a datatype object to a window
ULONG AFDataType::AddObject(AFWindow *window, AFRect *rect, UWORD id)
{
    ULONG result;
    AFRect newrect;
    LONG x, y;

    if(m_dtGlobal.o != NULL) {
        result=AddDTObject(window->m_pWindow,(struct Requester *)NULL, m_dtGlobal.o, -1);

        if(rect->Width() > window->m_pWindow->Width)
            x=window->m_pWindow->Width;
        else x=rect->Width();

        if(rect->Height() > window->m_pWindow->Height)
            y=window->m_pWindow->Height;
        else y=rect->Height();

        newrect.SetRect(rect->TopLeft()->m_x, rect->TopLeft()->m_y, x, y);

        SetDTAttrs(m_dtGlobal.o,window->m_pWindow, (struct Requester*)NULL,
                        GA_Left, (LONG)newrect.TopLeft()->m_x,
                        GA_Top, (LONG)newrect.TopLeft()->m_y,
                        GA_Width, (LONG)newrect.Width(),
                        GA_Height, (LONG)newrect.Height(),
                        GA_ID, id,
                        TAG_DONE);
        m_dtGlobal.dtAdded=TRUE;
        m_dtGlobal.dtWindow=window;

        m_dtGlobal.gpl.MethodID=DTM_PROCLAYOUT;
        m_dtGlobal.gpl.gpl_GInfo=NULL;
        m_dtGlobal.gpl.gpl_Initial=1;

        if(!(DoMethodA(m_dtGlobal.o,(Msg)&m_dtGlobal.gpl)))
            return FALSE;

        ::RefreshGadgets(window->m_pWindow->FirstGadget,window->m_pWindow,(struct Requester*)NULL);
        return result;
    } else return FALSE;
}

// Remove a datatype object from a window
LONG AFDataType::RemoveObject()
{
    LONG result;

    if(m_dtGlobal.o != NULL ) {
        m_dtGlobal.dtAdded=FALSE;
        result=RemoveDTObject(m_dtGlobal.dtWindow->m_pWindow, m_dtGlobal.o);
        m_dtGlobal.dtWindow=NULL;
        return result;
    } else return FALSE;
}

// Frame an object to a window if object is larger than window
// else return size of object
AFRect AFDataType::FrameObject(AFWindow *window)
{
    AFRect rect1, rect2;

    m_dtGlobal.dtf.MethodID=DTM_FRAMEBOX;
    m_dtGlobal.dtf.dtf_FrameInfo=&m_dtGlobal.fri;
    m_dtGlobal.dtf.dtf_ContentsInfo=&m_dtGlobal.fri;
    m_dtGlobal.dtf.dtf_SizeFrameInfo=sizeof(struct FrameInfo);

    DoDTMethodA(m_dtGlobal.o, window->m_pWindow, (struct Requester*)NULL, (Msg)&m_dtGlobal.dtf);

    window->GetDisplayRect(&rect1);

    if(m_dtGlobal.fri.fri_Dimensions.Width > rect1.Width())
        m_dtGlobal.fri.fri_Dimensions.Width = rect1.Width();
    if(m_dtGlobal.fri.fri_Dimensions.Height > rect1.Height())
        m_dtGlobal.fri.fri_Dimensions.Height = rect1.Height();

    rect2.SetRect(0,0,m_dtGlobal.fri.fri_Dimensions.Width,m_dtGlobal.fri.fri_Dimensions.Height);
    return rect2;
}

// Frame an object to a screen if object is larger than screen
// else return size of object
AFRect AFDataType::FrameObject(AFScreen *screen)
{
    AFRect rect;

    m_dtGlobal.dtf.MethodID=DTM_FRAMEBOX;
    m_dtGlobal.dtf.dtf_FrameInfo=&m_dtGlobal.fri;
    m_dtGlobal.dtf.dtf_ContentsInfo=&m_dtGlobal.fri;
    m_dtGlobal.dtf.dtf_SizeFrameInfo=sizeof(struct FrameInfo);

    DoDTMethodA(m_dtGlobal.o, (struct Window*)NULL, (struct Requester*)NULL, (Msg)&m_dtGlobal.dtf);

    if(m_dtGlobal.fri.fri_Dimensions.Width > screen->m_pScreen->Width)
        m_dtGlobal.fri.fri_Dimensions.Width = screen->m_pScreen->Width;
    if(m_dtGlobal.fri.fri_Dimensions.Height > screen->m_pScreen->Height)
        m_dtGlobal.fri.fri_Dimensions.Height = screen->m_pScreen->Height;

    rect.SetRect(0,0,m_dtGlobal.fri.fri_Dimensions.Width,m_dtGlobal.fri.fri_Dimensions.Height);
    return rect;
}

// Get true object size
AFRect AFDataType::FrameObject()
{
    AFRect rect;

    m_dtGlobal.dtf.MethodID=DTM_FRAMEBOX;
    m_dtGlobal.dtf.dtf_FrameInfo=&m_dtGlobal.fri;
    m_dtGlobal.dtf.dtf_ContentsInfo=&m_dtGlobal.fri;
    m_dtGlobal.dtf.dtf_SizeFrameInfo=sizeof(struct FrameInfo);

    DoDTMethodA(m_dtGlobal.o, (struct Window*)NULL,(struct Requester*)NULL,(Msg)&m_dtGlobal.dtf);

    rect.SetRect(0,0,m_dtGlobal.fri.fri_Dimensions.Width,m_dtGlobal.fri.fri_Dimensions.Height);
    return rect;
}

// No real purpose as of yet ;)
AFDataType AFDataType::operator=(AFDataType dt)
{
    return dt;
}
