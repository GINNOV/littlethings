//////////////////////////////////////////////////////////////////////////////
// CDRom.hpp
//
// Deryk B Robosson
// Jeffry A Worth
// December 16, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFCDROM_HPP__
#define __AFCDROM_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "AFrame:include/AFrame.hpp"
#include "AFrame:include/Object.hpp"
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <exec/devices.h>
#include <exec/io.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <devices/cd.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/disk.h>
#include <clib/cdplayer_protos.h>
#include <libraries/cdplayer.h>
#include <pragmas/cdplayer_pragmas.h>
#include <stdio.h>

#include <devices/scsidisk.h>
#include <devices/trackdisk.h>

/////////////////////////////////////////////////////////////////////////////
// Structures and Global Vars

// Macros for converting addresses to Minutes and Seconds

#define BASE2MIN(val)   ((val)/75/60)   // Macro to convert blocks to minutes
#define BASE2SEC(val)   (((val)/75)%60) // Macro to convert blocks to seconds

#define BLOCKSPERSECOND 75              // CD blocks per second of audio
#define MAX_TOC     100                 // maximum number of tracks
#define SENSE_LEN   18                  // SCSI command reply data buffers
#define DATA_LEN    252                 // SCSI command reply data buffers
#define TOC_LEN     (MAX_TOC * 8 + 4)   // max TOC size = 100 TOC track descriptors

#define CDP_EMPTY   0 // No CD in
#define CDP_PLAYING 1 // Playing
#define CDP_PAUSED  2 // Paused 
#define CDP_STOPPED 3 // CD in, not Playing
#define CDP_SEEKING 4 // Seeking to a Track
#define CDP_EJECTED 5 // Tray Out

#define SCSI_CMD_TUR    0x00 // Test Unit Ready
#define SCSI_CMD_RZU    0x01 // Rewind / Rezero Unit
#define SCSI_CMD_RQS    0x03 // Request Sense
#define SCSI_CMD_FMU    0x04 // Format / Format Unit
#define SCSI_CMD_RAB    0x07 // Initialize Element Status / Reassign Blocks
#define SCSI_CMD_RD     0x08 // Get Message / Receive(06)
#define SCSI_CMD_WR     0x0A // Print / Send Message / Send / Write (06)
#define SCSI_CMD_SK     0x0B // Slew and Print(06)
#define SCSI_CMD_INQ    0x12 // Inquire
#define SCSI_CMD_MSL    0x15 // Mode Select(06)
#define SCSI_CMD_RU     0x16 // Reserve / Reserve Unit
#define SCSI_CMD_RLU    0x17 // Release / Release Unit
#define SCSI_CMD_MSE    0x1A // Mode Sense(06)
#define SCSI_CMD_SSU    0x1B // Load Unload / Scan / Stop Print / Start Stop Unit
#define SCSI_CMD_RDI    0x1C // Receive Diagnostic Results
#define SCSI_CMD_SDI    0x1D // Send Diagnostic Results
#define SCSI_CMD_PAMR   0x1E // Prevent Allow Medium Removal
#define SCSI_CMD_RCP    0x25 // Read CD-ROM Capacity
#define SCSI_CMD_RXT    0x28 // Get Message / Read(10)
#define SCSI_CMD_WXT    0x2A // Send Message / Write(10)
#define SCSI_CMD_SKX    0x2B // Locate / Seek(10)
#define SCSI_CMD_WVF    0x2E // Write And Verify(10)
#define SCSI_CMD_VF     0x2F // Verify(10)
#define SCSI_CMD_RDD    0x37 // Read Defect Data
#define SCSI_CMD_WDB    0x3B // Meduim Scan
#define SCSI_CMD_RDB    0x3C // Read Buffer

#define SCSI_CMD_COPY                   0x18 // Copy 
#define SCSI_CMD_COMPARE                0x39 // Compare
#define SCSI_CMD_COPYANDVERIFY          0x3A // Copy and Compare
#define SCSI_CMD_CHGEDEF                0x40 // Change Definition
#define SCSI_CMD_READSUBCHANNEL         0x42 // Read Sub-Channel
#define SCSI_CMD_READTOC                0x43 // Read TOC
#define SCSI_CMD_READHEADER             0x44 // Read Header
#define SCSI_CMD_PLAYAUDIO12            0xA5 // Play Audio(12)
#define SCSI_CMD_PLAYAUDIO10            0x45 // Play Audio(10)
#define SCSI_CMD_PLAYAUDIOTRACKINDEX    0x48 // Play Audio Track Index
#define SCSI_CMD_PAUSERESUME            0x4B // Pause / Resume

#define SCSI_SENSE_NOINFO       0x00 // No additional sense information
#define SCSI_SENSE_IOTERM       0x06 // I/O process terminated
#define SCSI_SENSE_PLAYING      0x11 // Audio play operation in progress
#define SCSI_SENSE_PAUSED       0x12 // Audio play operation paused
#define SCSI_SENSE_SUCCESS      0x13 // Audio play operation successfully completed
#define SCSI_SENSE_STOPERROR    0x14 // Audio play stopped due to error
#define SCSI_SENSE_NOSTATUS     0x15 // No current audio status to return

typedef struct
{
    UBYTE opcode;
    UBYTE b1;
    UBYTE b2;
    UBYTE b3;
    UBYTE b4;
    UBYTE control;
} SCSICMD6;

typedef struct
{
    UBYTE opcode;
    UBYTE b1;
    UBYTE b2;
    UBYTE b3;
    UBYTE b4;
    UBYTE b5;
    UBYTE b6;
    UBYTE b7;
    UBYTE b8;
    UBYTE control;
} SCSICMD10;

typedef struct
{
    UBYTE opcode;
    UBYTE b1;
    UBYTE b2;
    UBYTE b3;
    UBYTE b4;
    UBYTE b5;
    UBYTE b6;
    UBYTE b7;
    UBYTE b8;
    UBYTE b9;
    UBYTE b10;
    UBYTE control;
} SCSICMD12;


typedef struct {
	BYTE  cdi_DeviceType;       // byte 0 bits 0-4 of DataBuf
	BOOL  cdi_RemovableMedium;  // byte 1 bit 7
	BYTE  cdi_ANSIVersion;      // byte 2
	UBYTE *cdi_VendorID;        // bytes 8-15
	UBYTE *cdi_ProductID;       // bytes 16-32
	UBYTE *cdi_ProductRev;      // bytes 32-35
	UBYTE *cdi_VendorSpec;      // bytes 36-55
} DEVINFO;

//////////////////////////////////////////////////////////////////////////////
// CD_Rom Class

class AFCD_Rom : public AFObject
{
public:

    UBYTE *DataBuf;
    UBYTE *TOCBuf;
    UBYTE *SenseData;

    union CDTOC TOC[100];
    ULONG TOC_Length[MAX_TOC];  // track lenghts in blocks
    ULONG TOC_Time[MAX_TOC];    // track lenghts in seconds
    UBYTE TOC_Flags[MAX_TOC];   // audio/data
    STRPTR TOCS[MAX_TOC];       // titles
    ULONG TOCP[MAX_TOC];        // program
    ULONG Tracks;               // Total tracks on disk (easier to get to vs
                                // digging in the structs)

    ULONG TrackMin;     // Set by SCSI_CDCurrentTitle()
    ULONG TrackSec;     // Set by SCSI_CDCurrentTitle()
    ULONG Track;        // Updated by SCSI_CDStatus()
//    ULONG EndAddress;
    ULONG cd_status;    // Updated by SCSI_CDStatus()
    BOOL cd_paused;     // Updated by SCSI_CDPause() / CDPause()
    BOOL cd_active;     // Updated by CDActive()
    BOOL cd_ejected;    // Updated by SCSI_CDEject() / CDEject()
    BOOL lib;           // Used to determine whether to use xxxxx.device
                        // (ex: scsi.device) or cdplayer.library

    struct CD_TOC cd_toc;
    struct CD_Time cd_time;
    struct CD_Volume cd_vol;
    struct CD_Info cd_info;
    DEVINFO dev_info;


    AFCD_Rom();
    ~AFCD_Rom();

    virtual void DestroyObject();
    virtual char *ObjectType() { return "CDRom"; };

// Methods
    virtual void CDCreate(UBYTE *, ULONG);

    virtual void SCSI_CDClose();
    virtual void SCSI_CDOpen();
    virtual void SCSI_CDEject();
    virtual void SCSI_CDPlay(ULONG, ULONG);
    virtual void SCSI_CDPause();
    virtual void SCSI_CDStop();
    virtual void SCSI_CDJump(LONG);
    virtual void SCSI_CDStatus();
    virtual int SCSI_CDCurrentTitle();
    virtual void SCSI_CDTitleTime();
    virtual void SCSI_CDGetVolume();
    virtual void SCSI_CDSetVolume(int, int, int, int);
    virtual void SCSI_ReadTOC();
    virtual void SCSI_CDInfo();
    BOOL SCSI_IsCD();
    virtual void DoSCSI(UBYTE *, int, UBYTE *, int, UBYTE);

    virtual void CDClose();
    virtual void CDOpen();
    virtual void CDEject();
    virtual void CDPlay(UBYTE, UBYTE);
    virtual void CDPause();
    virtual void CDStop();
    virtual void CDJump(LONG);
    virtual void CDActive(); // similar to SCSI_CDStatus
    virtual void CDCurrentTitle();
    virtual void CDTitleTime();
    virtual void CDGetVolume();
    virtual void CDSetVolume();
    virtual void CDReadTOC();
    virtual void CDInfo();

private:
    LPMsgPort m_scsi_port;
    LPIOStdReq m_scsi_io;
    STRPTR m_scsi_device;
    ULONG m_scsi_unit;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __AFCDROM_HPP__
