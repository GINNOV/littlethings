#ifndef _SCSI2_H
#define _SCSI2_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEC_TYPES_H */

/***********************************************************************/

typedef UBYTE FREEDB_Command6[6];
typedef UBYTE FREEDB_Command10[10];
typedef UBYTE FREEDB_Command12[12];

/***********************************************************************/

/* Note
** FREEDBC_XXX SCSI2 command
** FREEDBS_XXX structure
** FREEDBV_XXX value
** FREEDBM_XXX macro
*/

/***********************************************************************/

#define FREEDBV_TOCSIZE     804
#define FREEDBV_MAXTRACKS   100

/***********************************************************************/

#define FREEDBM_SETLONG(cmd,i,value)    ((cmd)[(i)]   = ((value) & 0xFF000000)>>24, \
                                         (cmd)[(i)+1] = ((value) & 0x00FF0000)>>16, \
                                         (cmd)[(i)+2] = ((value) & 0x0000FF00)>>8, \
                                         (cmd)[(i)+3] = ((value) & 0x000000FF))

#define FREEDBM_SETWORD(cmd,i,value)    ((cmd)[(i)]   = ((value) & 0xFF00)>>8, \
                                         (cmd)[(i)+1] = ((value) & 0x00FF))

#define FREEDBM_SETLUN(cmd,lun)         ((cmd)[1] = (lun)<<5)

#define FREEDBM_GETLONG(buf,i)          (((buf)[(i)]<<24)|((buf)[(i)+1]<<16)|((buf)[(i)+2]<<8)|((buf)[(i)+3]))

/***********************************************************************/

/*
** COMMANDS
**/

enum
{
    FREEDBC_CHANGEDEFINITION           = (int)0x40,
    FREEDBC_COMPARE                    = (int)0x39,
    FREEDBC_COPY                       = (int)0x18,
    FREEDBC_COPYANDVERIFY              = (int)0x3A,
    FREEDBC_INQUIRY                    = (int)0x12,
    FREEDBC_LOCKUNLOCKCACHE            = (int)0x36,
    FREEDBC_LOGSELECT                  = (int)0x4C,
    FREEDBC_LOGSENSE                   = (int)0x4D,
    FREEDBC_MODESELECT6                = (int)0x15,
    FREEDBC_MODESELECT10               = (int)0x55,
    FREEDBC_MODESENSE6                 = (int)0x1A,
    FREEDBC_MODESENSE10                = (int)0x5A,
    FREEDBC_PAUSERESUME                = (int)0x4B,
    FREEDBC_PLAYAUDIO10                = (int)0x45,
    FREEDBC_PLAYAUDIO12                = (int)0xA5,
    FREEDBC_PLAYAUDIOMSF               = (int)0x47,
    FREEDBC_PLAYAUDIOTRACKINDEX        = (int)0x48,
    FREEDBC_PLAYTRACKRELATIVE10        = (int)0x49,
    FREEDBC_PLAYTRACKRELATIVE12        = (int)0xA9,
    FREEDBC_PREFETCH                   = (int)0x34,
    FREEDBC_PREVENTALLOWMEDIUMREMOVAL  = (int)0x1E,
    FREEDBC_READ6                      = (int)0x08,
    FREEDBC_READ10                     = (int)0x28,
    FREEDBC_READ12                     = (int)0xA8,
    FREEDBC_READBUFFER                 = (int)0x3C,
    FREEDBC_READCDROMCAPACITY          = (int)0x25,
    FREEDBC_READHEADER                 = (int)0x44,
    FREEDBC_READLONG                   = (int)0x3E,
    FREEDBC_READSUBCHANNEL             = (int)0x42,
    FREEDBC_READTOC                    = (int)0x43,
    FREEDBC_RECEIVEDIAGNOSTICRESULTS   = (int)0x1C,
    FREEDBC_RELEASE                    = (int)0x17,
    FREEDBC_REQUESTSENSE               = (int)0x03,
    FREEDBC_RESERVE                    = (int)0x16,
    FREEDBC_REZEROUNIT                 = (int)0x01,
    FREEDBC_SEARCHDATAEQUAL10          = (int)0x31,
    FREEDBC_SEARCHDATAEQUAL12          = (int)0xB1,
    FREEDBC_SEARCHDATAHIGH10           = (int)0x30,
    FREEDBC_SEARCHDATAHIGH12           = (int)0xB0,
    FREEDBC_SEARCHDATALOW10            = (int)0x32,
    FREEDBC_SEARCHDATALOW12            = (int)0xB2,
    FREEDBC_SEEK6                      = (int)0x0B,
    FREEDBC_SEEK10                     = (int)0x2B,
    FREEDBC_SENDDIAGNOSTIC             = (int)0x1D,
    FREEDBC_SETLIMITS10                = (int)0x33,
    FREEDBC_SETLIMITS12                = (int)0xB3,
    FREEDBC_STARTSTOPUNIT              = (int)0x1B,
    FREEDBC_SYNCHRONIZECACHE           = (int)0x35,
    FREEDBC_TESTUNITREADY              = (int)0x00,
    FREEDBC_VERIFY10                   = (int)0x2F,
    FREEDBC_VERIFY12                   = (int)0xAf,
    FREEDBC_WRITEBUFFER               = (int)0x3B,
};

/***********************************************************************/

/*
** Sense
**/

#define FREEDBM_Sense_Valid(s)              ((s)[0]>>7)
#define FREEDBM_Sense_ErrorCode(s)          ((s)[0]&0x7f)
#define FREEDBM_Sense_SegmentNumber(s)      ((s)[1])
#define FREEDBM_Sense_FileMark(s)           ((s)[2]>>7)
#define FREEDBM_Sense_EOM(s)                (((s)[2] & 0x40)>>6)
#define FREEDBM_Sense_ILI(s)                (((s)[2] & 0x20)>>5)
#define FREEDBM_Sense_SenseKey(s)           ((s)[2] & 0xf)
#define FREEDBM_Sense_Information(s)        FREEDBM_GETLONG(s,3)
#define FREEDBM_Sense_ASL(s)                ((s)[7])
#define FREEDBM_Sense_CSI(s)                FREEDBM_GETLONG(s,8)
#define FREEDBM_Sense_ASC(s)                ((s)[12])
#define FREEDBM_Sense_ASCQ(s)               ((s)[13])
#define FREEDBM_Sense_FRUC(s)               ((s)[14])
#define FREEDBM_Sense_SKSV(s)               (((s)[15] & 0x80)>>7)
#define FREEDBM_Sense_SKS(s)                ((((s)[15] & 0x7f)<<16)|((s)[16]<<8)|((s)[17]))

/***********************************************************************/

/*
** Info
**/

#define FREEDBM_INQUIRY_PeripheralQualifier(s)      ((s)[0]>>5)
#define FREEDBM_INQUIRY_PeripheralType(s)           ((s)[0] & 0xf)
#define FREEDBM_INQUIRY_RMB(s)                      ((s)[1]>>7)
#define FREEDBM_INQUIRY_Modifier(s)                 ((s)[1] & 0x7f)
#define FREEDBM_INQUIRY_ISO(s)                      ((s)[2]>>6)
#define FREEDBM_INQUIRY_ECMA(s)                     (((s)[2] & 0x38)>>3)
#define FREEDBM_INQUIRY_ANSI(s)                     ((s)[2] & 0x7)
#define FREEDBM_INQUIRY_AENC(s)                     ((s)[3]>>7)
#define FREEDBM_INQUIRY_TrmIOP(s)                   (((s)[3] & 0x40)>>6)
#define FREEDBM_INQUIRY_RDF(s)                      ((s)[3] & 0x7)
#define FREEDBM_INQUIRY_ALength(s)                  ((s)[4])
#define FREEDBM_INQUIRY_RelAdr(s)                   ((s)[7]>>7)
#define FREEDBM_INQUIRY_WBus32(s)                   (((s)[7] & 0x40)>>6)
#define FREEDBM_INQUIRY_WBus16(s)                   (((s)[7] & 0x20)>>5)
#define FREEDBM_INQUIRY_Sync(s)                     (((s)[7] & 0x10)>>4)
#define FREEDBM_INQUIRY_Linked(s)                   (((s)[7] & 0x8)>>3)
#define FREEDBM_INQUIRY_CmdQue(s)                   (((s)[7] & 0x2)>>1)
#define FREEDBM_INQUIRY_SftRe(s)                    ((s)[7] & 0x1)
#define FREEDBM_INQUIRY_Vendor(s)                   ((s)+8)
#define FREEDBM_INQUIRY_Product(s)                  ((s)+16)
#define FREEDBM_INQUIRY_Revision(s)                 ((s)+32)


/***********************************************************************/

/*
** Status
**/

#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_AudioStatus(s)  ((s)[1])
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Play(s)         (FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_AudioStatus(s)==0x11)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Pause(s)        (FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_AudioStatus(s)==0x12)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Complete(s)     (FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_AudioStatus(s)==0x13)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_DataLength(s)   (((s)[2]<<8)|((s)[3]))
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_ADR(s)          ((s)[5]>>7)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Control(s)      ((s)[5] & 0x7f)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_PreEmp(s)       (FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Control(s) & 0x1)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_CopyPerm(s)     (FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Control(s) & 0x2)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_AudioTrack(s)   (!(FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Control(s) & 0x4))
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_4Channels(s)    (FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Control(s) & 0x8)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Track(s)        ((s)[6])
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_Index(s)        ((s)[7])
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_AbsAddr(s)      FREEDBM_GETLONG(s,8)
#define FREEDBM_READSUBCHANNEL_CDRomCurrentPosition_RelAddr(s)      FREEDBM_GETLONG(s,12)

#define FREEDBV_READSUBCHANNEL_SubQ         (1<<6)
#define FREEDBV_READSUBCHANNEL_SubData      (0x00)
#define FREEDBV_READSUBCHANNEL_SubPosition  (0x01)
#define FREEDBV_READSUBCHANNEL_SubMCN       (0x02)
#define FREEDBV_READSUBCHANNEL_SubISRC      (0x03)
#define FREEDBV_READSUBCHANNEL_TCVal_Valid  (1<<7)
#define FREEDBV_READSUBCHANNEL_MCVal_Valid  (1<<7)

/***********************************************************************/

/*
** StartStop
**/

enum
{
    FREEDBV_STARTSTOP_Stop  = 0,
    FREEDBV_STARTSTOP_Ready = 1,
    FREEDBV_STARTSTOP_Eject = 2,
    FREEDBV_STARTSTOP_Load  = 3,
};

/***********************************************************************/

/*
** PauseResume
**/

#define FREEDBV_PAUSERESUME_Resume  0
#define FREEDBV_PAUSERESUME_Pause   1

/***********************************************************************/

/*
** ModeSense
**/

#define FREEDBV_ModeSense_PF_SCSI2              0x10

#define FREEDBV_ModeSense_PC_CurrentValues      0x0
#define FREEDBV_ModeSense_PC_ChangeableValues   0x1
#define FREEDBV_ModeSense_PC_DefaultValue       0x2
#define FREEDBV_ModeSense_PC_SavedValues        0x3

#define FREEDBV_ModeSense_PageCode_Caching      0x08
#define FREEDBV_ModeSense_PageCode_Audio        0x0e
#define FREEDBV_ModeSense_PageCode_Page         0x0d
#define FREEDBV_ModeSense_PageCode_Mode         0x0a
#define FREEDBV_ModeSense_PageCode_Disconnect   0x02
#define FREEDBV_ModeSense_PageCode_Supported    0x0b
#define FREEDBV_ModeSense_PageCode_Device       0x09
#define FREEDBV_ModeSense_PageCode_ReadError    0x01

#define FREEDBM_ModeSense_DataLength(s)         ((s)[0])
#define FREEDBM_ModeSense_MediumType(s)         ((s)[1])
#define FREEDBM_ModeSense_Empty(s)              (FREEDBM_ModeSense_MediumType(s)==0x70)
#define FREEDBM_ModeSense_Opened(s)             (FREEDBM_ModeSense_MediumType(s)==0x71)
#define FREEDBM_ModeSense_Specific(s)           ((s)[2])
#define FREEDBM_ModeSense_BDLength(s)           ((s)[3])

#define FREEDBM_ModeSense_Audio_PS(s)           ((s)[4]>>7)
#define FREEDBM_ModeSense_Audio_Immed(s)        (((s)[6] & 0x4)>>2)
#define FREEDBM_ModeSense_Audio_SOTC(s)         ((s)[6] & 0x2)
#define FREEDBM_ModeSense_Audio_APRVal(s)       ((s)[9]>>7)
#define FREEDBM_ModeSense_Audio_LBA(s)          ((s)[9] & 0xf)
#define FREEDBM_ModeSense_Audio_PBS(s)          (((s)[10]<<8)|((s)[11]))
#define FREEDBM_ModeSense_Audio_Out0(s)         ((s)[12] & 0xf)
#define FREEDBM_ModeSense_Audio_Vol0(s)         ((s)[13])
#define FREEDBM_ModeSense_Audio_Out1(s)         ((s)[14] & 0xf)
#define FREEDBM_ModeSense_Audio_Vol1(s)         ((s)[15])
#define FREEDBM_ModeSense_Audio_Out2(s)         ((s)[16] & 0xf)
#define FREEDBM_ModeSense_Audio_Vol2(s)         ((s)[17])
#define FREEDBM_ModeSense_Audio_Out3(s)         ((s)[18] & 0xf)
#define FREEDBM_ModeSense_Audio_Vol3(s)         ((s)[19])

/***********************************************************************/

/*
** TOC
**/

#define FREEDBM_TOCHeader_Length(s)     (((s)[0]<<8)|(s)[1])
#define FREEDBM_TOCHeader_FirstTrack(s) ((s)[2])
#define FREEDBM_TOCHeader_LastTrack(s)  ((s)[3])

#define FREEDBM_TOCData_ADR(s)          ((s)[1]>>7)
#define FREEDBM_TOCData_Control(s)      ((s)[1] & 0x7f)
#define FREEDBM_TOCData_PreEmp(s)       (FREEDBM_TOCData_Control(s) & 0x1)
#define FREEDBM_TOCData_CopyPerm(s)     (FREEDBM_TOCData_Control(s) & 0x2)
#define FREEDBM_TOCData_AudioTrack(s)   (!(FREEDBM_TOCData_Control(s) & 0x4))
#define FREEDBM_TOCData_4Channels(s)    (FREEDBM_TOCData_Control(s) & 0x8)
#define FREEDBM_TOCData_TrackNumber(s)  ((s)[2])
#define FREEDBM_TOCData_AbsAddr(s)      FREEDBM_GETLONG(s,4)

#define FREEDBM_TOCBlock_TOCHeader(s)   (s)
#define FREEDBM_TOCBlock_TOCData(s)     (s+4)

#define FREEDBV_TOCBlock_TOCDataSize    8

struct FREEDBS_Track
{
    ULONG   track;
    ULONG   startAddr;
    ULONG   endAddr;
    ULONG   frames;
    ULONG   startMin;
    ULONG   startSec;
    ULONG   startFrame;
    ULONG   endMin;
    ULONG   endSec;
    ULONG   endFrame;
    ULONG   min;
    ULONG   sec;
    ULONG   frame;
    BOOL    ADR;
    BOOL    audio;
    BOOL    copyPerm;
    BOOL    preEmp;
    BOOL    fourChannels;
};

struct FREEDBS_TOC
{
    ULONG                   firstTrack;
    ULONG                   lastTrack;
    ULONG                   startAddress;
    ULONG                   endAddress;
    ULONG                   frames;
    ULONG                   min;
    ULONG                   sec;
    ULONG                   frame;
    ULONG                   discID;
    ULONG                   numTracks;
    struct FREEDBS_Track    tracks[FREEDBV_MAXTRACKS];
};

/***********************************************************************/

#endif /* _SCSI2_H */
