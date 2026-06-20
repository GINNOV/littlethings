/* ports.h - exec library function prototypes */

/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/
#ifndef	EXEC_PORTS_H
#define	EXEC_PORTS_H

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

class Task;

/****** Signal bits *****************************************************/

class SignalNum {
 short signalnum;

public:
// operator LONG() { return signalnum; }
 friend int AllocSignal(const int n = -1);
 friend void FreeSignal(const SignalNum n);
 SignalNum(const int s) { signalnum = s; }
 SignalNum() { signalnum = -1; }
 void operator=(const int n) { signalnum = n; }
 WORD number() { return signalnum; }
 int error() { return signalnum < 0; }
 LONGBITS bits() { return (1 << signalnum); }
};

class SigBits;
class MsgPort;
LONGBITS Wait(LONGBITS);

class SigBits {
	LONGBITS signals;
public:
	SigBits(LONGBITS i) { signals = i; }
	SigBits(SignalNum n) { signals = n.bits(); }
	SigBits(MsgPort *mp);
	SigBits() { signals = 0; }
        LONGBITS bits() { return signals; }

	friend SigBits operator| (SigBits sig1, SigBits sig2)
		{ return (sig1.signals | sig2.signals); }

	friend SigBits operator| (SigBits sig1, LONGBITS sig2)
		{ return (sig1.signals | SigBits(sig2).signals); }

	friend SigBits operator| (LONGBITS sig1, SigBits sig2)
		{ return (SigBits(sig1).signals | sig2.signals); }

	friend SigBits SetSignal(const SigBits s, const SigBits s);
	friend void Signal(const Task *t, const SigBits s);

	void set(SigBits s) { signals |= s.signals; }
	void clear(SigBits s) { signals &= ~s.signals; }

	int was(SigBits s) { return signals & s.signals; }
	int was(SignalNum s) { return signals & s.bits(); }
	SigBits wait() { return SigBits(Wait(signals)); }
};

/****** Message *****************************************************/

class Message;

void ReplyMsg(Message * m);
void PutMsg(const MsgPort *mp, Message *m);

struct Message : Node {
    class   MsgPort *mn_ReplyPort;  /* message reply port */
    UWORD   mn_Length;		    /* message len in bytes */

    Message(MsgPort *port = NULL, int l = 0) : (NT_MESSAGE)
    { mn_ReplyPort = port; mn_Length = l; } 

    void reply() { ReplyMsg(this); }
    void send(MsgPort *p) { PutMsg(p, this); }
    void send(MsgPort *p, MsgPort *r) { mn_ReplyPort = r; PutMsg(p, this); }
};

/****** MsgPort *****************************************************/
//
//  Contains private data areas - do not attempt to define statically
//
class MsgPort : public Node {
public:
    UBYTE   mp_Flags; 
    UBYTE   mp_SigBit;		    /* signal bit number    */
    Task    *mp_SigTask;	    /* task to be signalled */
    uList    mp_MsgList;	    /* message linked list  */


public:
	friend MsgPort *CreatePort(char *portname = NULL, int priority = 0);
	friend void DeletePort(MsgPort *mp);
	friend void AddPort(const MsgPort *mp);
	friend MsgPort *FindPort(const TEXT *name);
	friend void RemPort(const MsgPort *mp);
	friend Message * WaitPort(const MsgPort *mp);
	friend Message * GetMsg(const MsgPort *mp);
	Message *wait() { return WaitPort(this); }
	Message *get() { return GetMsg(this); }
	Message *first() { return (Message *)mp_MsgList.first(); }
};

// The following CANNOT be statically declared.  Use new/delete ONLY!

class StdPort : public MsgPort {
public :
	StdPort(char *portname = NULL, int priority=0)
	{ this = (StdPort *)CreatePort(portname, priority); }
	~StdPort() { DeletePort((MsgPort *)this); this = NULL; }
};

#define mp_SoftInt mp_SigTask

#define PF_ACTION	3

inline SigBits::SigBits(MsgPort *mp)
	 { signals = 1L << mp->mp_SigBit; }

enum PF_Action {
	PA_SIGNAL = 0,
	PA_SOFTINT = 1,
	PA_IGNORE = 2
};

#endif
