/* Bovs - Support header for SAS/C - Copyright 1992 Bryan Ford */
#ifndef BRY_BOVS_H
#define BRY_BOVS_H

void BExit(void);
void __regargs BRExit(int retcode,int retcode2);
void __regargs LockOverlay(long overlayhandle);
void __regargs UnlockOverlay(long overlayhandle);
long __asm ResCall(register __a2 void *routine,
        register __a0 void *arg1,register __a1 void *arg2);

#endif
