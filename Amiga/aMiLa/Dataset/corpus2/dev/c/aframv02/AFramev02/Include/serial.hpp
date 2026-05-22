//////////////////////////////////////////////////////////////////////////////
// Serial.hpp
//
// Deryk B Robosson
// Jeffry A Worth
// December 16, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFSERIAL_HPP__
#define __AFSERIAL_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "AFrame:include/aframe.hpp"
#include <exec/types.h>
#include <devices/serial.h>
#include <stdlib.h>
#include <string.h>

#define NONE  0
#define EVEN  1
#define ODD   2
#define MARK  3
#define SPACE 4
#define OFF   0
#define RTSCTS 1
#define IOB_SER ((struct IOExtSer *)(iob))

//////////////////////////////////////////////////////////////////////////////
// Serial Class

class AFSerial : public AFObject
{
public:
  AFSerial();
  ~AFSerial();

  virtual void DestroyObject();
  virtual char *ObjectType() { return "AFSerial"; };

// Methods
    virtual void Create(char *,int,ULONG,int,int,int,int,int,int);
    virtual void Close();
    virtual void SetParameters();
    int Status();

//  virtual void DoIO(struct IORequest *iob_ptr);
//  virtual void SetBaud(int baudrate);
//  virtual void SetBits(int databits);
//  virtual void SetStop(int stopbits);
//  virtual void SetParity(int parity);
//  virtual void SetHand(int shake);
//  virtual void SetHighSpeed(int true_or_false);
//  virtual void SetShare(int true_or_false);
//  virtual void SetParams(void);
//  virtual void WriteData(UBYTE *, int numbytes);
//  virtual void Write(UBYTE *, char termchar='\0');
//  virtual void WriteByte(UBYTE);

//  UBYTE ReadByte();
//  UBYTE *Read(int numbytes);
//  UBYTE *Read(char termchar='\r');

private:

    LPMsgPort m_SerialMP;       // used for reads/writes normal and reads highspeed
    LPMsgPort m_SerialHSMP;     // message port used for writes with highspeed set
    LPIORequest m_SerIO;
    LPIORequest m_SerHSIO;
    LPIOExtSer m_SerialIO;      // ExtendedIORequest reads/writes
    LPIOExtSer m_SerialHSIO;    // used with highspeed set

    int isopen;         // keeps track of open/close of device

    char *m_devicename; // serial device name
    int m_unit;         // device unit number
    ULONG m_baud;       // range 1 to 4,294,967,295 =)
    int m_bits;         // Read/Write length typically 7 or 8
    int m_stopbit;      // typically 1 or 2
    int m_parity;       // parity for device
    int m_handshake;    // software (xon/xoff) or hardware(RTS/CTS)
    int m_highspeed;    // sets highspeed mode (read & write) TRUE/FALSE
    int m_share;        // opens device in shared mode TRUE/FALSE
};

//////////////////////////////////////////////////////////////////////////////
#endif // __AFSERIAL_HPP__
