/* AmiPhoned.h */

#define READ_READY  0x01
#define MSG_READY   0x02

int MakeReq(char *sTitle, char *sText, char *sGadgets);
int SpaceUsedInDir(char * szDirectory);
int SpaceFreeForMessage(char * szDirectory, int nMaxSize);
int FreeSpaceOnDisk(char * szDirectory);
int ConnectRelay(char * szIPName, int nWhich);
int PacketTime(struct AmiPhonePacketHeader * ubPacket);


void SetExitMessage(char * message, int nExitVal);
void CleanExit(void);
void GetPhonePeerName(char *sBuffer, int nBufLen);
void debug(int i);
void PhonedWait(ULONG ulMask);
void QueueData(struct AmiPhonePacketHeader * pHead, UBYTE * ubData);
void LaunchXMitter(char * szPeerName);
void SetUpLocalAmiPhoneInfo(struct AmiPhoneInfo * inf);
void SetTimer(ULONG ulBytes);
void FreePacket(struct AmiPhonePacketHeader * cph);
void PrintPacketList(void);
void OpenTitleBar(ULONG * pulMask);
void CloseTitleBar(ULONG * pulMask);
void ParseArgs(void);
void UpperCase(char *sOldString);
void ReplaceChars(char * szString, char cFrom, char cTo);
void DisplayAbout(void);
void AddRelay(char * szOptIPName, int nWhich);
void RemoveRelay(int nWhich, BOOL BSendDisconnect);
void LowerCase(char *sOldString);
void CheckDaemonInfo(void);
void HandleRelayResponse(int nWhich);
void FinalizeRelay(int nWhich, int nPortNum, UBYTE ubReplyType, ULONG ulDataLen);
void ReplaceMenuString(int nWhich);
void PrintSocketState(struct sockaddr_in * psaSock);
void SetWindowTitle(char * szOptTitle);
void FinalizeOutFile(void);
void SetMenuValues(void);
void IncrementBuildup(int nDelta);


BOOL SendMessageToClient(UBYTE ubMessage);
BOOL ClosePhonedConnection(BOOL BSendDisconnect);
BOOL AcceptTCPSocket(struct DaemonMessage *dm);
BOOL TransferToDataSocket(UBYTE ubReplyType);
BOOL SafePutToPort(struct Message * message, char * portname);
BOOL SetAsyncMode(BOOL BAsync, int sCurrSocket);
BOOL SendCommandPacket(UBYTE ubCommand, UBYTE ubType, ULONG ulData);
BOOL ReceiveTCPPacket(void);
BOOL ReceiveUDPPacket(struct AmiPhoneSendBuffer * pPack);
BOOL AllocPacketList(BOOL BAlloc);
BOOL PlayNextPacket(void);
BOOL AddPacket(struct AmiPhoneSendBuffer * ubPacket);
BOOL GetToolTypeArg(struct DiskObject * AmiPhoneDiskObject, char *szArg, int *nParam, char **szParam);
BOOL UserHere(void);
BOOL CanStoreMessage(void);
BOOL PlayAudio(struct AmiPhoneSendBuffer * packet);
BOOL SendRelayCommandPacket(UBYTE ubCommand, UBYTE ubType, ULONG ulData, int nWhich);
BOOL SendRelayPacket(struct AmiPhoneSendBuffer * pPack, ULONG sSocket);

struct MenuItem * GetRelayItem(int nWhich);

int DMakeReq(char *sTitle, char *sText, char *sGadgets);

char * OpenLibraries(BOOL BOpen);
char * OpenLibraries(BOOL BOpen);
char * AmiPhonePortName(void);

BOOL CopyLocalHostAddress(char * pcCopyHere);

LONG CreateUDPSocket(void);

/* status defines for the two audio buffers */
#define STATUS_INVALID  0	/* Is not set up with valid data */
#define STATUS_PLAYING  1	/* Is currently playing a chunk */
