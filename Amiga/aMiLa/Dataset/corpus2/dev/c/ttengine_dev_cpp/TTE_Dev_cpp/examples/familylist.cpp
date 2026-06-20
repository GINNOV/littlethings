/*
	This file is copyright by Grzegorz Krashewski, changed by Tomasz
    Kaczanowski. You can use it for free, but you must add info about
    using this code and info about author. Remember also, that if you
    want to have new versions of this code and other codes for
    AmigaOS-like systems you should motivate author of this code. You
    can send him a small gift or mail or bug report.

    contact:
       kaczus (at) poczta (_) onet (_) pl
       or
       kaczus (at) wp (_) pl
    (_) replaced dot.
    Don't forget also about Krashan!!! - author of ttengine!
*/


/* Example of using TT_ObtainFamilyList() */


#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/ttengine.hpp>

TTEngine *TTEngine::Base=NULL;// Declaration of global library Base
int main()
{
	TTEngine::Base=new TTEngine; // Open library for global functions
	{
		STRPTR *family_list;

		PutStr("Listing all available font families:\n-------------------------------------\n");

		if (family_list = TT_ObtainFamilyListA(NULL))
		{
			STRPTR *p = family_list;

			while (*p)
			{
				Printf("%s\n", (ULONG)*p++);
			}
			TT_FreeFamilyList(family_list);
		}

		PutStr("\nListing monospaced font families:\n-------------------------------------\n");

		if (family_list = TTEngine::Base->TT_ObtainFamilyList(TTRQ_FixedWidthOnly, TRUE, TAG_END))
		{
			STRPTR *p = family_list;

			while (*p)
			{
				Printf("%s\n", (ULONG)*p++);
			}
			TT_FreeFamilyList(family_list);
		}
	}
    delete TTEngine::Base; // close library for global use
    return 0;
}
