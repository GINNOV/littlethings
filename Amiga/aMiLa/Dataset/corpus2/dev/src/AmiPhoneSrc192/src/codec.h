#ifndef CODEC_H
#define CODEC_H

BOOL AllocAudio(BOOL BAlloc);
BOOL GetMessageFileName(time_t tTime, char * szMessageDir, char *szBuf, int nBufLength);
BOOL ResetByteCounter(void);
ULONG DecompressData(UBYTE * ubIn, UBYTE * ubOut, UBYTE ubCompMode, ULONG ulLen, ULONG ulJoinCode);
void PrintPacketHeader(FILE * fpOut, struct AmiPhonePacketHeader * header);
void SavePacket(struct AmiPhonePacketHeader *, FILE * fpOutFile);
void SetMessageNote(time_t tStartTime, char * szFrom, char * szMessageDir, ULONG ulSecondsTaken);

char * TimeStamp(time_t *);
char * Strncpy(char * s1, char * s2, int n); 

FILE * OpenMessageFile(time_t time_stamp, char * szMessageDir);
void RemoveMessageFile(time_t time_stamp, char * szMessageDir);
struct AmiPhoneSendBuffer * GetTCPPacket(LONG sSocket);

ULONG MilliSecondDuration(struct AmiPhonePacketHeader * packet);

/* Returns TRUE if a VWARN packet should be sent, FALSE if not. */
BOOL CheckVersions(char * szRemoteSoftwareName, ULONG ulRemoteVersionNumber, BOOL BOkToShowReq);

#ifdef AMIPHONE_H
ULONG CompressData(UBYTE * ubIn, UBYTE * ubOut, UBYTE bCompType, ULONG ulBytes, ULONG * pulUpdateJoinCode);
#endif

/* Helpful macros for the ubiquitous SetMenuValues() function */
#define NEXTMENU    currentMenu=currentMenu->NextMenu
#define FIRSTITEM   currentItem=currentMenu->FirstItem
#define NEXTITEM    currentItem=currentItem->NextItem
#define CHECKITEM   currentItem->Flags|=(CHECKED)
#define UNCHECKITEM currentItem->Flags&=~(CHECKED)
#define ENABLEITEM  currentItem->Flags|=(ITEMENABLED)
#define DISABLEITEM currentItem->Flags&=~(ITEMENABLED)
#define FIRSTSUB    currentSub=currentItem->SubItem
#define NEXTSUB     currentSub=currentSub->NextItem
#define CHECKSUB    currentSub->Flags|=(CHECKED)
#define UNCHECKSUB  currentSub->Flags&=~(CHECKED)
#define ENABLESUB   currentSub->Flags|=(ITEMENABLED)
#define DISABLESUB  currentSub->Flags&=~(ITEMENABLED)
#define ENABLEMENU  currentMenu->Flags|=(MENUENABLED)
#define DISABLEMENU currentMenu->Flags&=~(MENUENABLED)


#endif
