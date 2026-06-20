//////////////////////////////////////////////////////////////////////////////
// TextDT.cpp
//
// Deryk Robosson
// March 17, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/TextDT.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFTextDT::AFTextDT()
{
    m_dtText.buffer=NULL;
    m_dtText.bufferlen=0;
    m_dtText.linelist=NULL;
    m_dtText.tf=NULL;
}

AFTextDT::~AFTextDT()
{
}

// Create new object
BOOL AFTextDT::LoadText(char *file_name, struct Screen *screen)
{
    struct Screen   *scr;

    if(m_dtGlobal.o != NULL) {
        if(m_dtGlobal.dtAdded)
            RemoveObject();
        DisposeDTObject(m_dtGlobal.o);
        delete m_dtGlobal.o;
        m_dtGlobal.o=NULL;
    }

    if(!(IsDataType(file_name)))
        return FALSE;

    // Get font info from the screen we are on or are passed
    if(!screen) {
        if(scr=LockPubScreen(NULL)) {
            AskFont(&scr->RastPort,&m_dtText.ta);
            UnlockPubScreen(NULL,scr);
        }
    } else AskFont(&screen->RastPort,&m_dtText.ta);

    // Set our new DataType Object
    if(!(m_dtGlobal.o=NewDTObject(file_name,DTA_SourceType,DTST_FILE,
                                  GA_Immediate, TRUE,
                                  GA_RelVerify, TRUE,
                                  DTA_GroupID,GID_TEXT,
                                  DTA_TextAttr, &m_dtText.ta,
                                  TDTA_WordWrap, TRUE,
                                  ICA_TARGET, ICTARGET_IDCMP,
                                  TAG_DONE)))
        return FALSE;

    // Get Attributes for our newly defined object
    if(!(GetDTAttrs(m_dtGlobal.o,TDTA_LineList,&m_dtText.linelist,TAG_DONE)))
        return FALSE;
    else {
        // Layout our new object
        m_dtGlobal.gpl.MethodID=DTM_PROCLAYOUT;
        m_dtGlobal.gpl.gpl_GInfo=NULL;
        m_dtGlobal.gpl.gpl_Initial=1;

        if(!(DoMethodA(m_dtGlobal.o,(Msg)&m_dtGlobal.gpl)))
            return FALSE;
        else return TRUE;
    }
}

// Get buffer and return to user
UBYTE* AFTextDT::GetBuffer(UBYTE* buffer)
{
    if(m_dtGlobal.o != NULL) {
        if(!(GetDTAttrs(m_dtGlobal.o,TDTA_Buffer,&buffer,TAG_DONE))) {
            buffer=NULL;
            return buffer;
        }
        else return buffer;
    } else {
        buffer=NULL;
        return buffer;
      }
}

// Return buffer size to user
ULONG AFTextDT::GetBufferSize()
{
    return m_dtText.bufferlen;
}

// Set new buffer for object
BOOL AFTextDT::SetBuffer(UBYTE* buffer, ULONG size)
{
    if(m_dtGlobal.o != NULL) {
        if(!(SetDTAttrs(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,
                    TDTA_Buffer,&buffer,TDTA_BufferLen,size,TAG_DONE)))
            return FALSE;
        else {
            m_dtText.buffer=(char*)buffer;
            m_dtText.bufferlen=size;
            return TRUE;
        }
    } else return FALSE;
}

// Set the font for the object
BOOL AFTextDT::SetDTFont(struct TextFont *tf)
{
    if(m_dtGlobal.o != NULL) {
        if(!(SetDTAttrs(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,
                        DTA_TextFont,tf,TAG_DONE)))
            return FALSE;
        else {
            m_dtText.tf=tf;
            return TRUE;
        }
    } else return FALSE;
}

// set font attributes for object
BOOL AFTextDT::SetDTFontAttr(TEXTATTR ta)
{
    if(m_dtGlobal.o != NULL) {
        if(!(SetDTAttrs(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,
                        DTA_TextAttr,&ta,TAG_DONE)))
            return FALSE;
        else {
            m_dtText.ta=ta;
            return TRUE;
        }
    } else return FALSE;
}
