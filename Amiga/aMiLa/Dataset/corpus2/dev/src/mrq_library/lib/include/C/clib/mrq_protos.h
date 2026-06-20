#ifndef CLIB_MISTERQ_H
#define CLIB_MISTERQ_H 1

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

void ClearR(void);
struct MisterQBase *MisterQInit(void);
int MisterQCleanUp(struct MisterQBase *);
void MRequest(STRPTR,struct MisterQBase *);
APTR MLoadFile(STRPTR,struct MisterQBase *,ULONG);
int MFreeFile(APTR,struct MisterQBase *);
int MSaveFile(STRPTR,struct MisterQBase *,APTR,ULONG);
void CopyBytes(APTR,APTR,ULONG);
UBYTE MCloseScreen(struct MisterQBase *,struct MScreen *);
struct MScreen *MOpenScreen(struct MisterQBase *,ULONG,ULONG,ULONG,APTR);
int C2P(struct MisterQBase *,APTR,int,int,int,int);
STRPTR AslFILERequest(STRPTR,struct MisterQBase *);
void AslFreeFILERequest(STRPTR);
void DecConvert(LONG,struct MisterQBase *);
void HexConvert(LONG,struct MisterQBase *);
void RomanConvert(LONG,struct MisterQBase *);
LONG Rnd(LONG,struct MisterQBase *);
void WyswTXT(int,int,STRPTR,struct MisterQBase *);
struct IntuiMessage *GetMessage(struct MsgPort *,struct MisterQBase *);

int P2C(APTR, APTR, int, int, struct MisterQBase *);
STRPTR SearchW(STRPTR, int, STRPTR, int);
struct IntuiMessage *GetDynamicMessage(struct MsgPort *,struct MisterQBase *);
void DoubleBuffer(struct MScreen *, int,int,int,int, struct MisterQBase *);
int GetFPS(void);

#endif /* !CLIB_MISTERQ_H */
