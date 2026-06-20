/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADosList wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DosPacket_H
#define ASAP_DosPacket_H

extern "C"
{
 #include <Proto/DOS.H>
}

class ADosPacket : public DosPacket
{
 public:
 inline void AbortPkt(MsgPort *port);
 inline void ReplyPkt(long res1, long res2);
 inline void SendPkt(MsgPort *port, MsgPort *replyport);
 inline static ADosPacket * WaitPkt();
};

//-----------------------------------------------------------------------------
void ADosPacket::AbortPkt (MsgPort *port)
{
 ::AbortPkt(port, this);
}
//-----------------------------------------------------------------------------
void ADosPacket::ReplyPkt (long res1, long res2)
{
 ::ReplyPkt(this, res1, res2);
}
//-----------------------------------------------------------------------------
void ADosPacket::SendPkt (MsgPort *port, MsgPort *replyport)
{
 ::SendPkt(this, port, replyport);
}
//-----------------------------------------------------------------------------
ADosPacket *ADosPacket::WaitPkt ()
{
 return (ADosPacket *) ::WaitPkt();
}

#endif
