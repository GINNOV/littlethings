/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_POWERSDL_NET_H
#define _VBCCINLINE_POWERSDL_NET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

void  __SDLNet_FreeSocketSet(SDLNet_SocketSet ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_FreeSocketSet(__p0) __SDLNet_FreeSocketSet((__p0))

TCPsocket  __SDLNet_TCP_Open(IPaddress *) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_TCP_Open(__p0) __SDLNet_TCP_Open((__p0))

IPaddress * __SDLNet_TCP_GetPeerAddress(TCPsocket ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_TCP_GetPeerAddress(__p0) __SDLNet_TCP_GetPeerAddress((__p0))

int  __SDLNet_UDP_Recv(UDPsocket , UDPpacket *) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_Recv(__p0, __p1) __SDLNet_UDP_Recv((__p0), (__p1))

const char * __SDLNet_ResolveIP(IPaddress *) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_ResolveIP(__p0) __SDLNet_ResolveIP((__p0))

UDPpacket ** __SDLNet_AllocPacketV(int , int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_AllocPacketV(__p0, __p1) __SDLNet_AllocPacketV((__p0), (__p1))

void  __SDLNet_FreePacket(UDPpacket *) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_FreePacket(__p0) __SDLNet_FreePacket((__p0))

UDPsocket  __SDLNet_UDP_Open(Uint16 ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_Open(__p0) __SDLNet_UDP_Open((__p0))

IPaddress * __SDLNet_UDP_GetPeerAddress(UDPsocket , int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_GetPeerAddress(__p0, __p1) __SDLNet_UDP_GetPeerAddress((__p0), (__p1))

int  __SDLNet_CheckSockets(SDLNet_SocketSet , Uint32 ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_CheckSockets(__p0, __p1) __SDLNet_CheckSockets((__p0), (__p1))

void  __SDLNet_TCP_Close(TCPsocket ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_TCP_Close(__p0) __SDLNet_TCP_Close((__p0))

int  __SDLNet_ResolveHost(IPaddress *, const char *, Uint16 ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_ResolveHost(__p0, __p1, __p2) __SDLNet_ResolveHost((__p0), (__p1), (__p2))

void  __SDLNet_UDP_Close(UDPsocket ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_Close(__p0) __SDLNet_UDP_Close((__p0))

int  __SDLNet_DelSocket(SDLNet_SocketSet , SDLNet_GenericSocket ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_DelSocket(__p0, __p1) __SDLNet_DelSocket((__p0), (__p1))

SDLNet_SocketSet  __SDLNet_AllocSocketSet(int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_AllocSocketSet(__p0) __SDLNet_AllocSocketSet((__p0))

UDPpacket * __SDLNet_AllocPacket(int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_AllocPacket(__p0) __SDLNet_AllocPacket((__p0))

void  __SDLNet_Quit() =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_Quit() __SDLNet_Quit()

int  __SDLNet_UDP_Bind(UDPsocket , int , IPaddress *) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_Bind(__p0, __p1, __p2) __SDLNet_UDP_Bind((__p0), (__p1), (__p2))

void  __SDLNet_UDP_Unbind(UDPsocket , int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_Unbind(__p0, __p1) __SDLNet_UDP_Unbind((__p0), (__p1))

int  __SDLNet_UDP_SendV(UDPsocket , UDPpacket **, int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_SendV(__p0, __p1, __p2) __SDLNet_UDP_SendV((__p0), (__p1), (__p2))

int  __SDLNet_ResizePacket(UDPpacket *, int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_ResizePacket(__p0, __p1) __SDLNet_ResizePacket((__p0), (__p1))

int  __SDLNet_UDP_RecvV(UDPsocket , UDPpacket **) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_RecvV(__p0, __p1) __SDLNet_UDP_RecvV((__p0), (__p1))

void  __SDLNet_FreePacketV(UDPpacket **) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_FreePacketV(__p0) __SDLNet_FreePacketV((__p0))

int  __SDLNet_TCP_Send(TCPsocket , void *, int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_TCP_Send(__p0, __p1, __p2) __SDLNet_TCP_Send((__p0), (__p1), (__p2))

int  __SDLNet_UDP_Send(UDPsocket , int , UDPpacket *) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_UDP_Send(__p0, __p1, __p2) __SDLNet_UDP_Send((__p0), (__p1), (__p2))

int  __SDLNet_AddSocket(SDLNet_SocketSet , SDLNet_GenericSocket ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_AddSocket(__p0, __p1) __SDLNet_AddSocket((__p0), (__p1))

int  __SDLNet_Init() =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_Init() __SDLNet_Init()

TCPsocket  __SDLNet_TCP_Accept(TCPsocket ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_TCP_Accept(__p0) __SDLNet_TCP_Accept((__p0))

int  __SDLNet_TCP_Recv(TCPsocket , void *, int ) =
	"\tlis\t11,PowerSDLNetBase@ha\n"
	"\tlwz\t12,PowerSDLNetBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDLNet_TCP_Recv(__p0, __p1, __p2) __SDLNet_TCP_Recv((__p0), (__p1), (__p2))

#endif /* !_VBCCINLINE_POWERSDL_NET_H */
