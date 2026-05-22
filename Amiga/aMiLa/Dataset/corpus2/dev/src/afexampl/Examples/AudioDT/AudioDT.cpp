//////////////////////////////////////////////////////////////////////////////
// AudioDT.cpp
//
// Deryk Robosson
// March 16, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/AudioDT.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFAudioDT::AFAudioDT()
{
    m_dtAudio.volume=64;
    m_dtAudio.cycles=1;
    m_dtAudio.period=330;   // Defaults
}

AFAudioDT::~AFAudioDT()
{
}

// Create new object from file
BOOL AFAudioDT::LoadSample(char *file_name)
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

    if(!(m_dtGlobal.o=NewDTObject(file_name,DTA_SourceType,DTST_FILE,
                                  DTA_GroupID,GID_SOUND,
                                  GA_Immediate, TRUE,
                                  GA_RelVerify, TRUE,
                                  SDTA_Continuous, TRUE,
                                  SDTA_Volume,m_dtAudio.volume,
                                  SDTA_Cycles,m_dtAudio.cycles,
                                  ICA_TARGET, ICTARGET_IDCMP,
                                  TAG_DONE)))
            return FALSE;
    else return TRUE;
}

// Play the existing object
BOOL AFAudioDT::PlaySample()
{
    if(m_dtGlobal.o != NULL) {
        m_dtAudio.dtt.MethodID = DTM_TRIGGER;
        m_dtAudio.dtt.dtt_Function = STM_PLAY;
        DoMethodA(m_dtGlobal.o,(Msg)&m_dtAudio.dtt);
        return TRUE;
    } else return FALSE;
}

// Play from a file
BOOL AFAudioDT::PlayFile(char *file_name)
{
    Object *tempo;
    AUDIODT save;

    save=m_dtAudio;

    if(!(IsDataType(file_name)))
        return FALSE;

    if(tempo=NewDTObject(file_name,DTA_SourceType,DTST_FILE,
                         DTA_GroupID,GID_SOUND,
                         SDTA_Volume,m_dtAudio.volume,
                         SDTA_Cycles,m_dtAudio.cycles,
                         ICA_TARGET, ICTARGET_IDCMP,
                         TAG_DONE)) {

            m_dtAudio.dtt.MethodID = DTM_TRIGGER;
            m_dtAudio.dtt.dtt_Function = STM_PLAY;
            if(!(DoMethodA(tempo,(Msg)&m_dtAudio.dtt))) {
                DisposeObject(tempo);
                tempo = NULL;
                return FALSE;
            }
    } else return FALSE;
    DisposeDTObject(tempo);
    tempo=NULL;
    m_dtAudio=save;
    return TRUE;
}

// Set volume of current object
BOOL AFAudioDT::SetVolume(int volume)
{
    return SetVolume((ULONG)volume);
}

// Set volume of current object
BOOL AFAudioDT::SetVolume(ULONG volume)
{
    if(m_dtGlobal.o != NULL) {
        if(SetDTAttrs(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,SDTA_Volume,
                        volume,TAG_DONE)) {
            m_dtAudio.volume = volume;
            m_dtAudio.vhdr->vh_Volume=volume;
            return TRUE;
        } else return FALSE;
    } else return FALSE;
}

// Set buffer of current object
BOOL AFAudioDT::SetBuffer(UBYTE* buffer, ULONG size)
{
    if(m_dtGlobal.o != NULL) {
        if(SetDTAttrs(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,
                    SDTA_Sample,&buffer,SDTA_SampleLength,size,TAG_DONE)) {
            m_dtAudio.buffer = (char*)buffer;
            m_dtAudio.samplelength = size;
            return TRUE;
        } else return FALSE;
    } else return FALSE;
}

// Set task to signal when another
// buffer is needed or play is done
BOOL AFAudioDT::SignalTask(struct Task *task)
{
    if(m_dtGlobal.o != NULL) {
        if(SetDTAttrs(m_dtGlobal.o,m_dtGlobal.dtWindow->m_pWindow,(struct Requester*)NULL,SDTA_SignalTask,
                        task,TAG_DONE))
            return TRUE;
        else return FALSE;
    } else return FALSE;
}

// Get buffer and return to user
UBYTE* AFAudioDT::GetBuffer(UBYTE* buffer)
{
    if(m_dtGlobal.o != NULL) {
        if(!(GetDTAttrs(m_dtGlobal.o,SDTA_Sample,&buffer,TAG_DONE))) {
            buffer = NULL;
            return buffer;
        }
        else return buffer;
    } else {
        buffer = NULL;
        return buffer;
      }
}

// Get buffersize and return to user
ULONG AFAudioDT::GetBufferSize()
{
    return m_dtAudio.samplelength;
}
