#ifndef PHONEUDP_H
#define PHONEUDP_H

/* Phoneudp.h */

#define IDCMP_READY 0x01
#define READ_READY  0x02
#define WRITE_READY 0x04

#ifndef AMIPHONEPACKET_H
#include "AmiPhonePacket.h"
#endif

int ConnectPhoneSocket(BOOL BShowRequester, char * szPeerName);
int ClosePhoneSocket(void);
int Receive(char *sBuffer, LONG lLen);

void GetPhonePeerName(char *sBuffer, int nBufLen);
void ChangeConnectPort(int nPortNum);
void SetTCPSendBuf(ULONG ulBufSize);

BOOL SendCommandPacket(UBYTE ubCommand, UBYTE ubType, ULONG ulData);
BOOL SendPacket(struct AmiPhoneSendBuffer * pPack, BOOL BUseTCP);

ULONG PhoneWait(ULONG Mask);
BOOL SetAsyncMode(BOOL BAsynch, LONG sSocket);

#endif
