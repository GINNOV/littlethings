#ifndef _SERIALCLASS
#define _SERIALCLASS
 
//
//	Paul Cimino 1995
//	C++ Class to make basic Amiga serial port access a little easier
//	This code is being released into the public domain
//	feel free to improve upon it, however I ask that you :
//		1) Redistribute the improved code
//		2) Fully document changes to the code :
//			A) Why the changes were made
//			B) Document where your code is added
//			C) Don't remove my code, rather comment it out
//		3) Send me a copy (cimino@mdso.vf.ge.com or if that
//			mail id goes away, 73677,1761@compuserve.com )
//
//      Maybe someone could add WaitForChar() so the code doesn't
//      lock up if it never gets a character ?
//
// 	It would be great if someone familiar with Asynchronous
//	Transfer Mode (ATM) and other useful protocals could
// 	expand this into a truly useful Class
//
//	Thanks go to J. Edward Hanway for his OptMouse ver 1.2 code
//
// Version
#define VERSION "1.0 Paul Cimino, 1995"
// Version history :
// V 0.1 	Basic class structure
// V 0.5	First "usable" class
// V 1.0        Class which handles data in/out, strings in/out
// overloaded operators << and >>
//
// Definitions and macros
#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif
// don't need this for Amiga, types.h takes care of it
//#ifndef UBYTE
//	typedef char UBYTE;
//#endif

// Includes
#include <exec/types.h>
#include <devices/serial.h>
#include <devices/input.h>
#include <devices/inputevent.h>
#include <devices/keyboard.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>

extern "C" {
#include <stdlib.h>
}
#include <iostream.h>
// 


// Definitions and macros
typedef enum {NONE = 0, EVEN, ODD, MARK, SPACE} Parity;
typedef enum {OFF = 0, RTSCTS} HandShake;

#ifndef SERIALNAME
#define SERIALNAME "serial.device"
#endif

// cast iob as an IOExtSer
#define IOB_SER ((struct IOExtSer *)(iob))

// Class definition
class SerialClass {
public :
	// constructors and destructor
        SerialClass(char *device = SERIALNAME, // Name of the serial device 
		char *portNm = 0, // name of the port, defaults to <devicename><unit>
		int unit = 0, // Unit number of device
 		int baud = 19200, // Baud rate
 		int bits = 8, // Number of bits
		int stop = 1, // number of stop bits
		Parity = NONE, // type of parity being used
		HandShake = OFF, // type of handshaking used
		int HighSpeed = FALSE, // high speed mode
		int Share = FALSE);// whether or not the device is shared 

       
	~SerialClass(void);

        // management functions
        void    close();
        int     open();
        
	
	// Public access functions
        struct MsgPort *        getPort();
        struct IORequest *      getIO();
        int                     status() { return isOpen; }
            
        void mDoIO(struct IORequest *iob_ptr); // from Serial Mouse program
	int	setBaud(int baudRate);	// Set the baud rate
	int	setBits(int numBits);	// set the number of data bits read and written
	int	setStop(int stopBits);	// set the number of stop bits
	Parity	setParity(Parity parity); // set the parity
	HandShake	setHand(HandShake shake); // set handshaking OFF or RTSCTS
	int	setHighSpeed(int TRUE_or_FALSE); // Set high Speed mode TRUE or FALSE
	int	setShare(int TRUE_or_FALSE); // set shared port status TRUE or FALSE
        void    setParams(void);// Tell the serial port to change setup

	// Utility functions
	UBYTE	readByte(); // gets a byte from the port
	UBYTE	writeByte(UBYTE); // writes a byte to the port
	UBYTE	*read(int numBytes); // returns a number of bytes from the port
	UBYTE	*read(char terminationChar = '\r'); // reads until the 
                        // defined termination character 
			// is read, default is "RETURN"
	UBYTE	*writeData(UBYTE *, int numByte); // writes numBytes of data 
        // 
     	char	*write(char *, char terminationChar = '\0'); // writes 
                      // data to the port until a termination char
                      // is met, termination character is NOT sent
                      // to the port
                      
        // overload the extraction >> operator and the << insertion
        // operator.  Life would be much easier if someone
        // figure out how to simply make a Serial Class which
        // acts like a file stream
        // Anyone wanna give it a shot ?
        //
        // Here, we can send/receive single characters to/from the port
        // i.e. given a SerialClass instance myport
        // I can use the command :
        // myport << 'm' << 'y';
        // or given a char ch :
        // myport >> ch;
        // Can't use flush or endl, sorry
        class SerialClass &operator<< (char a) { writeByte((UBYTE)a);
                                                return *this; }
        class SerialClass &operator>> (char &a) { a = (char)readByte();
                                                return *this; }
/* Haven't gotten the bugs out of this yet
       class SerialClass &operator<< (unsigned char *a) { write(a);
                                                return *this; }
        // WARNING ! This assumes that "a" has enough memory allocated !                                        
        class SerialClass &operator>> (unsigned char *a) { strcpy(a, read());
                                                return *this; }
*/                                                   


protected :
	void setParameters(void);            
	struct MsgPort		*port;
	struct IORequest 	*iob;
        struct IOExtSer         *iob_ser;
	int     		isOpen;
	char			*deviceName;
	char			*portName;
	int			unitNum;
};


#endif


// what is : SERF_XDISABLED ??

