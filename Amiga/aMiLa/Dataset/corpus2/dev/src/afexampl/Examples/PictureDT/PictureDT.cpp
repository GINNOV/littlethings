//////////////////////////////////////////////////////////////////////////////
// PictureDT.cpp
//
// Deryk Robosson
// March 16, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/PictureDT.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFPictureDT::AFPictureDT()
{
}

AFPictureDT::~AFPictureDT()
{
}

// Create new object from file or clipboard
BOOL AFPictureDT::LoadPicture(char *file_name)
{
    if(m_dtGlobal.o != NULL) {
        if(m_dtGlobal.dtAdded)
            RemoveObject();
        DisposeDTObject(m_dtGlobal.o);
        delete m_dtGlobal.o;
        m_dtGlobal.o=NULL;
    }

    if(!(IsDataType(file_name)))
        return FALSE;

    if(m_dtGlobal.o=NewDTObject(file_name, DTA_SourceType, DTST_FILE,
                                DTA_GroupID, GID_PICTURE,
                                GA_Immediate, TRUE,
                                GA_RelVerify, TRUE,
                                PDTA_Remap, TRUE,
                                ICA_TARGET, ICTARGET_IDCMP,
                                TAG_DONE)) {

        m_dtGlobal.gpl.MethodID = DTM_PROCLAYOUT;
        m_dtGlobal.gpl.gpl_GInfo = NULL;
        m_dtGlobal.gpl.gpl_Initial = 1;

        if(!DoMethodA(m_dtGlobal.o,(Msg)&m_dtGlobal.gpl))
            return FALSE;

        if(!(GetDTAttrs(m_dtGlobal.o,PDTA_BitMapHeader,&m_dtPicture.bmhd,
                          PDTA_BitMap, &m_dtPicture.bmap,
                          PDTA_ModeID, &m_dtPicture.display_ID,
                          PDTA_NumColors, &m_dtPicture.numcolors,
                          PDTA_CRegs, &m_dtPicture.cregs, TAG_DONE)))
                            return FALSE;
    } else return FALSE;
    return TRUE;
}

// Fill screen color map
BOOL AFPictureDT::LoadCMap(struct Screen *screen)
{
    ULONG i, r, g, b;

    if(!screen)
        return FALSE;
    else {
        if(m_dtPicture.cregs) {
            m_dtPicture.numcolors = 2 << (screen->RastPort.BitMap->Depth - 1);
            for(i=0;i<m_dtPicture.numcolors;i++) {
                r=m_dtPicture.cregs[i * 3 + 0];
                g=m_dtPicture.cregs[i * 3 + 1];
                b=m_dtPicture.cregs[i * 3 + 2];
                SetRGB32(&screen->ViewPort,i,r,g,b);
            }
        } else return FALSE;
    }
    return TRUE;
}
