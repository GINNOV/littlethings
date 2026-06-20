/**************************************************************************

Name       : Engine.cpp
Programmer : Jesse Chan
Version    : 0.01
Date Begun : 03-24-1999
Date Last  : 04-12-1999
Description:

Completed  : 
To do list : 

Development: Compiler: SAS/C++ v7.01
             System  : A1200 w/ internal 810 MB Hard Drive
                       Microbotics M1230XA MMU 68030 CPU 50-Mhz FPU 50-Mhz
                       02 MB ChipRAM
                       16 MB FastRAM 60ns
                       Pioneer external 10x CD-ROM
                       Surf Squirrel PCMCIA SCSI-2 Interface w/ serial port
                       28.8-Kbps Supra FAX/MODEM

**************************************************************************/

// INCLUDES ///////////////////////////////////////////////////////////////

#include <proto/dos.h>  // TICKS_PER_SECOND

#include "Keys.h"
#include "Display.h"

// DEFINITIONS ////////////////////////////////////////////////////////////

#define SECONDS TICKS_PER_SECOND

// MAIN ///////////////////////////////////////////////////////////////////

int main(int argc, char *argv[])
{
   Display D1;

   D1.Compile_Title("Chan Engine", __DATE__, __TIME__);

   while(D1.keypressed != KEY_ESC)
   {
     D1.Worms();
     D1.KeyUpdate();
   }

} // End main

///////////////////////////////////////////////////////////////////////////

