/*
 * Chk_Abort.c: This is really a Manxism.
 * 15May89 - Created by Jeff Lydiatt.
 */
#define GETSTATUS 0L
#define ABORTSTATE 0x1000L
  long
Chk_Abort()
{
	long status;
	extern long SetSignal();
	extern int Enable_Abort;
	extern void _abort();

	if ((status = SetSignal(GETSTATUS, ABORTSTATE)) &ABORTSTATE) {
		if ( !Enable_Abort )
			return( status );
		abort();
	}
	return 0;
}
