//////////////////////////////////////////////////////////////////////////////
// AudioDT.hpp
//
// Deryk Robosson
// March 16, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __AUDIODT_HPP__
#define __AUDIODT_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/datatype.hpp"

//////////////////////////////////////////////////////////////////////////////
// Definitions

typedef struct {
    struct VoiceHeader  *vhdr;          // voice header pointer
    struct dtTrigger    dtt;            // datatype trigger struct
    ULONG               samplelength;   // sample length
    ULONG               cycles;         // sample cycles
    ULONG               period;         // sample period
    ULONG               volume;         // sample volume
    ULONG               clock;          // sample clock rate
    BYTE                *buffer;        // sample buffer
} AUDIODT;

//////////////////////////////////////////////////////////////////////////////
// AudioDT Class

class AFAudioDT : public AFDataType
{
public:

    AFAudioDT();
    ~AFAudioDT();

    virtual char *ObjectType() { return "AudioDT"; };

    BOOL PlaySample();
    BOOL PlayFile(char* file_name);
    BOOL LoadSample(char* file_name);
    BOOL SetVolume(int volume);
    BOOL SetVolume(ULONG volume);
    BOOL SetBuffer(UBYTE *buffer, ULONG size);
    BOOL SignalTask(struct Task *task);
    UBYTE* GetBuffer(UBYTE* buffer);
    ULONG GetBufferSize();

    AUDIODT m_dtAudio;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __AUDIODT_HPP__
