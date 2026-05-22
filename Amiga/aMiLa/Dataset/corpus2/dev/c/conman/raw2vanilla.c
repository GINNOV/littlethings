#include <simple/gen.h>

__regargs ubyte Raw2Vanilla (uword RawKey,uword Shift)
{
if ( Shift )
	{
	switch(RawKey)
		{
		case 0x00:	return('~');
		case 0x01:	return('!');
		case 0x02:	return('@');
		case 0x03:	return('#');
		case 0x04:	return('$');
		case 0x05:	return('%');
		case 0x06:	return('^');
		case 0x07:	return('&');
		case 0x08:	return('*');
		case 0x09:	return('(');
		case 0x0A:	return(')');
		case 0x0B:	return('_');
		case 0x0C:	return('+');
		case 0x0D:	return('|');
		case 0x10:	return('Q');
		case 0x11:	return('W');
		case 0x12:	return('E');
		case 0x13:	return('R');
		case 0x14:	return('T');
		case 0x15:	return('Y');
		case 0x16:	return('U');
		case 0x17:	return('I');
		case 0x18:	return('O');
		case 0x19:	return('P');
		case 0x1A:	return('{');
		case 0x1B:	return('}');
		case 0x20:	return('A');
		case 0x21:	return('S');
		case 0x22:	return('D');
		case 0x23:	return('F');
		case 0x24:	return('G');
		case 0x25:	return('H');
		case 0x26:	return('J');
		case 0x27:	return('K');
		case 0x28:	return('L');
		case 0x29:	return(':');
		case 0x2A:	return('"');

		case 0x31:	return('Z');
		case 0x32:	return('X');
		case 0x33:	return('C');
		case 0x34:	return('V');
		case 0x35:	return('B');
		case 0x36:	return('N');
		case 0x37:	return('M');
		case 0x38:	return('<');
		case 0x39:	return('>');
		case 0x3A:	return('?');

		case 0x40: return(' ');
		case 0x44: return('\n');
	
		default:  return(0);
		}
	}
else
	{
	switch(RawKey)
		{
		case 0x00:	return('`');
		case 0x01:	return('1');
		case 0x02:	return('2');
		case 0x03:	return('3');
		case 0x04:	return('4');
		case 0x05:	return('5');
		case 0x06:	return('6');
		case 0x07:	return('7');
		case 0x08:	return('8');
		case 0x09:	return('9');
		case 0x0A:	return('0');
		case 0x0B:	return('-');
		case 0x0C:	return('=');
		case 0x0D:	return(92); // '\'
		case 0x10:	return('q');
		case 0x11:	return('w');
		case 0x12:	return('e');
		case 0x13:	return('r');
		case 0x14:	return('t');
		case 0x15:	return('y');
		case 0x16:	return('u');
		case 0x17:	return('i');
		case 0x18:	return('o');
		case 0x19:	return('p');
		case 0x1A:	return('[');
		case 0x1B:	return(']');
		case 0x20:	return('a');
		case 0x21:	return('s');
		case 0x22:	return('d');
		case 0x23:	return('f');
		case 0x24:	return('g');
		case 0x25:	return('h');
		case 0x26:	return('j');
		case 0x27:	return('k');
		case 0x28:	return('l');
		case 0x29:	return(';');
		case 0x2A:	return(39 ); // '''

		case 0x31:	return('z');
		case 0x32:	return('x');
		case 0x33:	return('c');
		case 0x34:	return('v');
		case 0x35:	return('b');
		case 0x36:	return('n');
		case 0x37:	return('m');
		case 0x38:	return(',');
		case 0x39:	return('.');
		case 0x3A:	return('/');

		case 0x40: return(' ');
		case 0x44: return('\n');
	
		default:  return(0);
		}
	}
}
