/*
 * vc +aospcc -O1 -I example_lib/os4/ -o RAM:Demo example_lib/os4/Demo.c
 * i686-aros-strip -R.comment --strip-unneeded -o RAM:Demo RAM:Demo-db
 *
 * vc +aosppc -I -D__USE_INLINE__ -O1 Demo.c -o RAM:Demo
 */

#include <intuition/screens.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/test.h>

#include <intuition/screens.h>

#include <string.h>
#include <stdio.h>

#include "misc_lib.c"

struct Library *TestBase = NULL;

#if defined(__amigaos4__)
struct TestIFace *ITest;
#endif

int main( int argc, char **argv)
{
	struct Screen *scr;
	ULONG i, w, h, d;

	if ( (OPEN_LIB( "test.library", 2, &TestBase, NULL, 1, &ITest, NULL)) )
	{
		Write( Output(), "Opened \"Test-Lib\"!\n", 19);
		if ( (scr = CloneWBScr()) )
		{
			for (i = 0; i < 100; i ++)
			{
				Write( Output(), ".", 1);
				Delay( 2);
			}
			Write( Output(), "\n", 1);

			/* Let's test if the by Weaver generated VARARG function works */
			GetClonedWBScrAttr( scr, SA_Width, &w, SA_Height, &h, SA_Depth, &d, TAG_DONE);
			printf( "Used a screen of %lux%lu pixels and a depth of %lu\n", w, h, d);

			CloseClonedWBScr( scr);
		}
		else
		{
			Write( Output(), "Can't clone WB!\n", 16);
		}

		CLOSE_LIB( &TestBase, &ITest);
	}
	else
	{
		Write( Output(), "Can't open \"Test-Lib\"!\n", 23);
	}

	return 0;	
}
