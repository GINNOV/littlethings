/*

   AsyncIFF.c - This piece of code is Copyright 1997 by Alessandro Zummo,
                and can be freely used as long as you send me an email.


   Instructions:

   You should #define a macro for ASM, SAVEDS and REG(x) and include this 
   piece of code in your source and then:

    1) AllocIFF()
	2) OpenAsync()
	3) InitIFF(IFFHandle, IFFF_FSEEK|IFFF_RSEEK, &IFFHook); instead of InitIFFasDOS
    4) OpenIFF(IFFHandle,IFFREAD) or OpenIFF(IFFHandle,IFFWRITE)
	5) Do your stuff
	6) CloseIFF()
	7) CloseAsync()
	8) FreeIFF()

    Don't forget to open the asyncio.library v38.0

	Comments to azummo@ita.flashnet.it
*/

SAVEDS ULONG ASM IFFLowLevelFunc(REG(a0) struct Hook *streamHook, REG(a2) struct IFFHandle *iffh, REG(a1) struct IFFStreamCmd *iffcmd);


static const struct Hook	 IFFHook = { { NULL,NULL},(void *)IFFLowLevelFunc,NULL,NULL };

/* -----> 

		IFFHook.h_Entry 	= (void *)IFFLowLevelFunc;
	    IFFHook.h_SubEntry	= NULL;
	    IFFHook.h_Data		= NULL;

*/


SAVEDS ULONG ASM IFFLowLevelFunc(REG(a0) struct Hook *streamHook, REG(a2) struct IFFHandle *iffh, REG(a1) struct IFFStreamCmd *iffcmd)
{
	#define buf iffcmd->sc_Buf
	#define len iffcmd->sc_NBytes

	#define fileh (AsyncFile *)iffh->iff_Stream

	switch(iffcmd->sc_Command)
	{
		case IFFCMD_READ:

			if(ReadAsync(fileh,buf,len) == -1)
				return(IFFERR_READ);
			return(0);
			break;

		case IFFCMD_WRITE:

			if(WriteAsync(fileh,buf,len) == -1)
				return(IFFERR_WRITE);
			return(0);
			break;

		case IFFCMD_SEEK:

			if(SeekAsync(fileh,len,MODE_CURRENT) == -1)
				return(IFFERR_SEEK);
			return(0);
			break;
	
		default:
			return(0);
			break;
	}
}	
