#include "stdio.h"
#include "stdlib.h"
#include "string.h"
int main(int argc, char *argv[])
{
	long int peekaddress;
	unsigned char mybyte;
	peekaddress = 0;
	mybyte = 0;
	if (strlen(argv[1]) <= 0) (argv[1]) = "0";
	if (strlen(argv[1]) >= 9) (argv[1]) = "16777215";
	peekaddress = atol(argv[1]);
	if (argc <= 1) peekaddress = 0;
	if (argc >= 3) peekaddress = 0;
	if (peekaddress <= 0) peekaddress = 0;
	if (peekaddress >= 16777215) peekaddress = 16777215;
	mybyte = *(unsigned char *)peekaddress;
	return(mybyte);
}
