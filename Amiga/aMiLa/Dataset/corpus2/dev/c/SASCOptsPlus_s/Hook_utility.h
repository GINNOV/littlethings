/*  Prototypes for Hook_Utility */

#include <utility/hooks.h>

/* prototype for C_Function

	a0 points to a struct hook.
	See MUI AutoDocs in order to know what registers (a2,a1) point.

*/
typedef APTR (*proto_c_function)(struct Hook *a0,APTR a2,APTR a1);

/*
	Don't forget to allocate the struct Hook.
	Data is the h_Data field of the struct Hook.
*/
void InstallHook(struct Hook *hook, proto_c_function c_function, APTR Data);
