/*
	$VER: Bin2C 0.5

	Bin2C by LeMUr/ Fire
	             /& blabla

	Public Domain.

		Program zapisuje plii binarne w formie liczb hexadecymalnych (np. dla
	úródîówki w C).
		Kickstart 2.0+ (lub 1.3 po zmianie "Printf" na "printf", co wydîuûy
	kod wynikowy)
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <proto/dos.h>
#include <proto/exec.h>

#include <exec/memory.h>

// wersja programu
const static char Version[]="\0$VER: Bin2C 0.5 (" __DATE__ ") by LeMUr/Fire & blabla\0";

// pamiëê i jej rozmiar
UBYTE *Bufor=NULL;
ULONG Size=NULL;


void out(int kod)
// Procedura zwalnia co byîo zajëte i wychodzi z podanym kodem bîëdu
{
	if(Bufor && Size)
		FreeMem(Bufor, Size);

	exit(kod);
} /* out() */


int main(int argc, char *argv[])
{
	UBYTE znak[10];
	ULONG i=0;

	BPTR file, lock;
	struct FileInfoBlock __aligned fib;

	/* najpierw sprawdúmy agrumenty... */
	if(argc!=3)
	{
		Printf("I need two file-names as argument!\n");
		out(5);
	}

	/* jebanie z plikiem */
	if(!(lock=Lock(argv[1], ACCESS_READ)))
	{
		Printf("Unable to lock \"%s\"\n", argv[1]);
		out(25);
	}

	if(!Examine(lock, &fib))
	{
		Printf("Unable to examine \"%s\"\n", argv[1]);
		UnLock(lock);
		out(30);
	}

	if(!(Size=fib.fib_Size))
	{
		Printf("File couldn't be 0 bytes long!\n");
		UnLock(lock);
		out(32);
	}

	if(!(Bufor=AllocMem(Size, MEMF_CHIP)))
	{
		Printf("Unable to allocate memory!\n");
		UnLock(lock);
		out(35);
	}

	if(!(file=Open(argv[1], MODE_OLDFILE)))
	{
		Printf("Unable to open file \"%s\"\n", argv[1]);
		UnLock(lock);
		out(40);
	}

	Read(file, Bufor, Size);
	Close(file);
	UnLock(lock);

	/* jebanie zdrugim plikiem */
	if(!(file=Open(argv[2], MODE_NEWFILE)))
	{
		Printf("Unable to open file \"%s\"\n", argv[2]);
		UnLock(lock);
		out(40);
	}

	Write(file, "UBYTE Data[]=\n{\n", 16);
	/* "konwersja" */
	for(i=0; i<Size; i++)
	{
		sprintf(znak, "0x%X,\n", Bufor[i]);
		if(strlen(znak)==5)
			sprintf(znak, "0x0%X,\n", Bufor[i]);
		Write(file, znak, strlen(znak));
	}

	Write(file, "\n};\n", 4);
	Close(file);

	out(0);
} /* main() */
