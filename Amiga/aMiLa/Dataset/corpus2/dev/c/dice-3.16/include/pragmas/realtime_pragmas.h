/* $VER: dinclude:pragmas/realtime_pragmas.h 1.0 (15.8.98) */
#ifndef RealTimeBase_PRAGMA_H
#define RealTimeBase_PRAGMA_H

#pragma libcall RealTimeBase LockRealTime 1e 001
#pragma libcall RealTimeBase UnlockRealTime 24 801
#pragma libcall RealTimeBase CreatePlayerA 2a 801
#pragma libcall RealTimeBase DeletePlayer 30 801
#pragma libcall RealTimeBase SetPlayerAttrsA 36 9802
#pragma libcall RealTimeBase SetConductorState 3c 10803
#pragma libcall RealTimeBase ExternalSync 42 10803
#pragma libcall RealTimeBase NextConductor 48 801
#pragma libcall RealTimeBase FindConductor 4e 801
#pragma libcall RealTimeBase GetPlayerAttrsA 54 9802

#endif
