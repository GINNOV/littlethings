#ifndef __EMPTY_H__
#define __EMPTY_H__

/* Protos der Routinen aus misc.c */

extern void returnpacket(struct ExecBase *SysBase, struct DosPacket*,struct Process*,long,long);
extern struct DosPacket *getpacket(struct ExecBase *SysBase, struct Process*);

#if defined(__MORPHOS__)
#define __TEXTSEGMENT__ __attribute__((section(".text")))
#define SAVEDS
#else
#define __TEXTSEGMENT__
#define SAVEDS __saveds
#endif

extern const char __TEXTSEGMENT__ dosname[];

#endif /* __EMPTY_H__ */