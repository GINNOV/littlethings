/* $VER: include/pragmas/ressourcetracking_pragmas.h 1.0 (3.7.98) */
#ifndef RessourceTrackingBase_PRAGMA_H
#define RessourceTrackingBase_PRAGMA_H

#pragma libcall RessourceTrackingBase rt_AddManager 1e 101
#pragma libcall RessourceTrackingBase rt_RemManager 24 00
#pragma libcall RessourceTrackingBase rt_FindNumUsed 2a 00
#pragma libcall RessourceTrackingBase rt_UnsetMarker 30 00
#pragma libcall RessourceTrackingBase rt_AllocMem 36 2102
#pragma libcall RessourceTrackingBase rt_SetCustomF0 3c 101
#pragma libcall RessourceTrackingBase rt_SetCustomF1 42 2102
#pragma libcall RessourceTrackingBase rt_SetCustomF2 48 32103
#pragma libcall RessourceTrackingBase rt_SetMarker 4e 00
#pragma libcall RessourceTrackingBase rt_AllocSignal 54 101
#pragma libcall RessourceTrackingBase rt_OpenLibrary 5a 2102
#pragma libcall RessourceTrackingBase rt_AddSemaphore 60 101
#pragma libcall RessourceTrackingBase rt_Forbid 66 00
#pragma libcall RessourceTrackingBase rt_AllocTrap 6c 101
#pragma libcall RessourceTrackingBase rt_CreateMsgPort 72 00
#pragma libcall RessourceTrackingBase rt_AddPort 78 101

#endif
