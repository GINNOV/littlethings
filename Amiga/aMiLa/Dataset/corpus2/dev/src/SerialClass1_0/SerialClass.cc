#include "SerialClass.h"
#ifndef DEBUG
#define DEBUG
#endif

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
// 	It would be great if someone familiar with Asynchronous
//	Transfer Mode (ATM) and other useful protocals could
// 	expand this into a truly useful Class
//
//	Thanks go to J. Edward Hanway for his OptMouse ver 1.2 code
//
//
//
SerialClass::SerialClass(char *device, char *portN, int unit, int Baud, int Bits,
	int Stop, Parity Par, HandShake Hand, int HighSpeed, int Share)
{
        // set OPEN status
        isOpen = 0;
        
	// assign the device name
	deviceName = new char [strlen(device)+1];
	strcpy(deviceName, device);

	// Default Unit number
	unitNum = unit;

	// assign the port name
	if (portN == 0) {
		portName = new char [strlen(deviceName)+5];// just in case the unit 
			// number is ridiculously huge
		sprintf(portName, "%s%d\0", deviceName, unitNum);
	} else {
		portName = new char [strlen(portN)+1];
		strcpy(portName, portN);
	}

	// Open the port
	if (!open()) 
	{
		cerr << "Sorry, problem openning the port" << endl;
		cerr << "Port in use ? " << endl;
		cerr << "Here's a good place in the code to add throws\n";
		cerr << "and catches for exception handling !" << endl;
		exit(0);
	} else {
#ifdef DEBUG
		cout << "Default port successfully opened as : ";
		cout << deviceName << " Unit : " << unitNum << endl;
#endif
	}
        
	// set the parameters after openning the port
	setBaud(Baud);
	setBits(Bits);
	setStop(Stop);
	setParity(Par);
	setHand(Hand);
	setHighSpeed(HighSpeed);
	setShare(Share);


}

SerialClass::~SerialClass()
{
	// close the device
	if (isOpen) close();

	// Reclaim the device name memory
	if (deviceName) delete [] deviceName;
        
        if (portName) delete [] portName;
	if (deviceName) delete [] deviceName;
	if (port) delete port;
	if (iob) delete iob;
        
}


int
SerialClass::open(void)
{ 
    port = CreatePort(portName, 0);
    if (port) {
        iob = CreateExtIO(port, sizeof(struct IOExtSer));
        if (iob) {
            isOpen = !OpenDevice((unsigned char *)deviceName, 
                                (unsigned long)unitNum, 
                                iob, 
                                (unsigned long)0L);
        }
        
    }
        
    iob_ser = (struct IOExtSer *)iob;

    return isOpen;
}
    
void
SerialClass::close(void)
{
    	if(isOpen == TRUE) {
		AbortIO(iob);
		CloseDevice(iob);
		isOpen = FALSE;
	}
	if(iob) {
		DeleteExtIO(iob);
		iob = NULL;
	}
	if(port) {
		DeletePort(port);
		port = NULL;
	}   
}

void
SerialClass::mDoIO(struct IORequest *iob) 
{
// took this function from "OptMouse", because I don't 
// yet understand IO stuff or pragma calls

    register LONGBITS signals, sigbit;
    
#pragma libcalliob->io_Device BeginIO 1e 901
    
    if (isOpen) {
      iob->io_Flags |= IOF_QUICK;
      BeginIO(iob);
      if(!(iob->io_Flags & IOF_QUICK)) {
          sigbit = 1L << iob->io_Message.mn_ReplyPort->mp_SigBit;
          signals = Wait(sigbit | SIGBREAKF_CTRL_C);
        
          if(signals & sigbit) {
                  GetMsg(iob->io_Message.mn_ReplyPort);
          }
        
          if (signals & SIGBREAKF_CTRL_C) {
              close();
              cerr << "Problem in mDoIO, SIGBREAKF_CTRL_C encountered";
              cerr << "\nClosing port" << endl;
          }
      }
   }  
}
    

int
SerialClass::setBaud(int BAUD) 
{
	IOB_SER->io_Baud = BAUD;
        setParams();
        
	return BAUD;
}

int
SerialClass::setBits(int BITS) 
{
	IOB_SER->io_ReadLen = (unsigned char)BITS;
        IOB_SER->io_WriteLen = (unsigned char)BITS;
        setParams();
        
	return BITS;
}

int
SerialClass::setStop(int BITS) 
{
	IOB_SER->io_StopBits = (unsigned char)BITS;
        setParams();
        
	return BITS;
}

Parity
SerialClass::setParity(Parity par) 
{

	// first, clear the affected bits
	IOB_SER->io_SerFlags &= ~(SERF_PARTY_ON|SERF_PARTY_ODD);
	IOB_SER->io_ExtFlags &= ~(SEXTF_MSPON|SEXTF_MARK);

	switch (par) {
                case NONE : // do nothing;
                        break;
		case EVEN : IOB_SER->io_SerFlags |= SERF_PARTY_ON;
			break;
		case ODD : IOB_SER->io_SerFlags |= SERF_PARTY_ON|SERF_PARTY_ODD;
			break;
		case MARK : IOB_SER->io_SerFlags |= SERF_PARTY_ON;
                        IOB_SER->io_ExtFlags |= SEXTF_MSPON|SEXTF_MARK;
			break;
                case SPACE : IOB_SER->io_SerFlags |= SERF_PARTY_ON;
                        IOB_SER->io_ExtFlags |= SEXTF_MSPON;
                        break;
		default :
			cerr << "Invalid Parity, should be 0, 1, 2, 3, 4" << endl;
			cerr << "For NONE, EVEN, ODD, MARK, SPACE" << endl;
                        cerr << " YOU used : " << (int) par << endl;
	}

        setParams();
        
	return par;
}

HandShake
SerialClass::setHand(HandShake hand) 
{

	// first, clear the affected bits
	IOB_SER->io_SerFlags &= ~(SERF_7WIRE);

	switch (hand) {
                case NONE : // do nothing;
                        break;
		case RTSCTS : IOB_SER->io_SerFlags |= SERF_7WIRE;
			break;
		default :
			cerr << "Invalid Handshaking, should be 0, 1" << endl;
			cerr << "For NONE, RTSCTS" << endl;
                        cerr << " YOU used : " << (int) hand << endl;
	}

        setParams();
        
	return hand;
}

int
SerialClass::setHighSpeed(int FLAG) 
{

	// first, clear the affected bits
	IOB_SER->io_SerFlags &= ~(SERF_RAD_BOOGIE);

	switch (FLAG) {
                case FALSE : // do nothing;
                        break;
		case TRUE : IOB_SER->io_SerFlags |= SERF_RAD_BOOGIE;
			break;
		default :
			cerr << "Invalid High Speed Flag, should be 0, 1" << endl;
			cerr << "For FALSE, TRUE" << endl;
                        cerr << " YOU used : " << FLAG << endl;
	}

        setParams();
	return FLAG;
}

int
SerialClass::setShare(int FLAG) 
{

	// first, clear the affected bits
	IOB_SER->io_SerFlags &= ~(SERF_SHARED);

	switch (FLAG) {
                case FALSE : // do nothing;
                        break;
		case TRUE : IOB_SER->io_SerFlags |= SERF_SHARED;
			break;
		default :
			cerr << "Invalid Share Flag, should be 0, 1" << endl;
			cerr << "For FALSE, TRUE" << endl;
                        cerr << " YOU used : " << FLAG << endl;
	}

        setParams();
      	return FLAG;
}

void 
SerialClass::setParams(void)
{
        // set the serial port parameters
        IOB_SER->IOSer.io_Command = SDCMD_SETPARAMS;
        mDoIO(iob);
}

UBYTE
SerialClass::readByte(void)
{
	UBYTE	ch = 0;

	IOB_SER->IOSer.io_Command = CMD_READ;
	IOB_SER->IOSer.io_Length = 1;
	IOB_SER->IOSer.io_Data = (APTR) &ch;

	// (Maybe use BeginIO ?)
        // BeginIO(iob);
	mDoIO(iob);
		
	return ch;
}

UBYTE *
SerialClass::read(int numBytes)
{
	UBYTE	*chPtr = new UBYTE[numBytes];

	IOB_SER->IOSer.io_Command = CMD_READ;
	IOB_SER->IOSer.io_Length = numBytes;
	IOB_SER->IOSer.io_Data = (APTR) chPtr;

	// (Maybe use BeginIO ?)
	mDoIO(iob);
		
	return chPtr;
}

// Reads text from the serial port until NULL or the termination character
// is received
UBYTE *
SerialClass::read(char termination)
{
	UBYTE	ch, *newPtr, *tmpPtr;
	int	i, size = 1;

	newPtr = new UBYTE [size];

	IOB_SER->IOSer.io_Command = CMD_READ;
	IOB_SER->IOSer.io_Length = 1;
	IOB_SER->IOSer.io_Data = (APTR) &ch;

	do {
		// (Maybe use BeginIO ?)
		mDoIO(iob);

		newPtr[size - 1] = ch; // save the character to the end of a string
		tmpPtr = new UBYTE [size]; // allocate room to save the string
		tmpPtr = newPtr;
		newPtr = 0; // remove the new string
		newPtr = new UBYTE [size+1]; // reallocate string with more room
		for (i = 0; i < size; i++) newPtr[i] = tmpPtr[i]; // move string back
		delete [] tmpPtr; // reclaim memory
		size++; // increment size
cout << ch << "Size is " << size << endl;	
	} while (ch != termination);
		
	// terminate the string
	newPtr[size - 1] = 0;

	return newPtr;
}


UBYTE
SerialClass::writeByte(UBYTE ch)
{
	IOB_SER->IOSer.io_Command = CMD_WRITE;
	IOB_SER->IOSer.io_Length = 1;
	IOB_SER->IOSer.io_Data = (APTR) &ch;
       
#ifdef DEBUG
        cout << "Ready to send a character" << endl;
#endif
	// (Maybe use BeginIO ?)
	mDoIO(iob);
//        cout << "Trying SendIO first " << endl;
//        SendIO(iob);
//        cout << "Now trying DoIO" << endl;
//        DoIO(iob);
		
#ifdef DEBUG
        cout << "Character sent" << endl;
#endif
	return ch;
}

UBYTE *
SerialClass::writeData(UBYTE *data, int size)
{
	int i;
        
#ifdef DEBUG
        cout << "Data is " << (char *)data << " size is " << size << endl;
#endif	
        for (i = 0; i < size; i++) writeByte(data[i]);

	return data;
}

char *
SerialClass::write(char *data, char terminationChar)
{
	int i = 0;
        
        while (data[i] != terminationChar) writeByte(data[i++]);

	return data;
}

void 
SerialClass::setParameters(void) { 
        IOB_SER->IOSer.io_Command = SDCMD_SETPARAMS; // get ready to set serial port parameters
	mDoIO(iob); // DO IT !
}
