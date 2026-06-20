#include "SerialClass.h"
 
//	Paul Cimino 1995
//	Example program using the SerialClass
//	Opens a serialport using parameters given,
// 	sends a character out to a terminal, then waits
//	for a character
//

int
main(void)
{
        // create a SerialClass called "myPort", use 1200, 8N1, let everything
        // else default
        SerialClass	myPort(SERIALNAME, "SerialTest", 0, 1200, 8, 1, NONE);

        // overloaded the stream operators
        myPort << 'k';
        char    tempCh;
        myPort >> tempCh;
        cout << tempCh << endl;
        
        // send a charcater out of the port
        myPort.writeByte((UBYTE)'j');
        myPort.writeByte((UBYTE)'\n');


	// get a character back
	cout << " Asking port for a character : " << flush;
	cout << "Received : " << (char)myPort.readByte() << endl;

	// send a string
        char *dum = "Howdy !\n";
        myPort.writeData((UBYTE *) dum, strlen(dum));
        myPort.write(dum);
        
	// get three bytes back
	cout << "Getting three chars back : " << flush;
	cout << myPort.read(3) << endl;

	// get bytes until newline
	cout << "Getting a line : " << flush;
	cout << (char *)myPort.read() << endl;
        
        // Also overloaded the >> operator to handle character IO
        char ch1, ch2;
        myPort >> ch1 >> ch2;// can be used recusively !
        cout << "Using >> operator to get two characters : " << flush;
        cout << ch1 << " and " << ch2 << endl;
        
        cout << "Using << to send the two characters back in reverse order " << endl;
        // similarly the << operator can put characters into the stream
        myPort << ch2 << ch1;// can't use flush or endl, remeber this isn't
                             // the same as cout, this could be soled if
                             // the serial port could be openned 
                             // as a file stream, THEN I WOULDN'T HAVE TO
                             // DO ALL THIS MESS !
                             
// Wanted to be able to use << and >> with strings, but needs some work
/*        // similarly, we can use << and >> for strings, let's try it !
        cout << "Sending a string using <<" << endl;
        myPort << "\nThis is a test \n\n\r";
        cout << "Waiting for a line of text" << endl;
        char *mystring = new char [1024];
        // WARNING ! you must allocate enough memory for this to work
        // any memory allocated inside the function will go away
        myPort >> mystring;
        cout << "Received the string : " << mystring << endl;
        
        // finally, should be able to mix these
        cout << "Waiting for a another line . . . " << endl;
        myPort >> ch1 >> mystring;
        cout << "The first character was " << ch1 ;
        cout << " The rest of the line was " << mystring < endl;
        
                             
        delete [] mystring;
*/

	return 1;
}
