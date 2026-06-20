#ifndef _INCLUDE_PRAGMA_SOCKET_LIB_H
#define _INCLUDE_PRAGMA_SOCKET_LIB_H

#ifndef CLIB_SOCKET_PROTOS_H
#include <clib/socket_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/socket.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(SocketBase,0x01E,socket(d0,d1,d2))
#pragma amicall(SocketBase,0x024,bind(d0,a0,d1))
#pragma amicall(SocketBase,0x02A,listen(d0,d1))
#pragma amicall(SocketBase,0x030,accept(d0,a0,a1))
#pragma amicall(SocketBase,0x036,connect(d0,a0,d1))
#pragma amicall(SocketBase,0x03C,sendto(d0,a0,d1,d2,a1,d3))
#pragma amicall(SocketBase,0x042,send(d0,a0,d1,d2))
#pragma amicall(SocketBase,0x048,recvfrom(d0,a0,d1,d2,a1,a2))
#pragma amicall(SocketBase,0x04E,recv(d0,a0,d1,d2))
#pragma amicall(SocketBase,0x054,shutdown(d0,d1))
#pragma amicall(SocketBase,0x05A,setsockopt(d0,d1,d2,a0,d3))
#pragma amicall(SocketBase,0x060,getsockopt(d0,d1,d2,a0,a1))
#pragma amicall(SocketBase,0x066,getsockname(d0,a0,a1))
#pragma amicall(SocketBase,0x06C,getpeername(d0,a0,a1))
#pragma amicall(SocketBase,0x072,IoctlSocket(d0,d1,a0))
#pragma amicall(SocketBase,0x078,CloseSocket(d0))
#pragma amicall(SocketBase,0x07E,WaitSelect(d0,a0,a1,a2,a3,d1))
#pragma amicall(SocketBase,0x084,SetSocketSignals(d0,d1,d2))
#pragma amicall(SocketBase,0x08A,getdtablesize())
#pragma amicall(SocketBase,0x090,ObtainSocket(d0,d1,d2,d3))
#pragma amicall(SocketBase,0x096,ReleaseSocket(d0,d1))
#pragma amicall(SocketBase,0x09C,ReleaseCopyOfSocket(d0,d1))
#pragma amicall(SocketBase,0x0A2,Errno())
#pragma amicall(SocketBase,0x0A8,SetErrnoPtr(a0,d0))
#pragma amicall(SocketBase,0x0AE,Inet_NtoA(d0))
#pragma amicall(SocketBase,0x0B4,inet_addr(a0))
#pragma amicall(SocketBase,0x0BA,Inet_LnaOf(d0))
#pragma amicall(SocketBase,0x0C0,Inet_NetOf(d0))
#pragma amicall(SocketBase,0x0C6,Inet_MakeAddr(d0,d1))
#pragma amicall(SocketBase,0x0CC,inet_network(a0))
#pragma amicall(SocketBase,0x0D2,gethostbyname(a0))
#pragma amicall(SocketBase,0x0D8,gethostbyaddr(a0,d0,d1))
#pragma amicall(SocketBase,0x0DE,getnetbyname(a0))
#pragma amicall(SocketBase,0x0E4,getnetbyaddr(d0,d1))
#pragma amicall(SocketBase,0x0EA,getservbyname(a0,a1))
#pragma amicall(SocketBase,0x0F0,getservbyport(d0,a0))
#pragma amicall(SocketBase,0x0F6,getprotobyname(a0))
#pragma amicall(SocketBase,0x0FC,getprotobynumber(d0))
#pragma amicall(SocketBase,0x102,vsyslog(d0,a0,a1))
#pragma amicall(SocketBase,0x108,Dup2Socket(d0,d1))
#pragma amicall(SocketBase,0x10E,sendmsg(d0,a0,d1))
#pragma amicall(SocketBase,0x114,recvmsg(d0,a0,d1))
#pragma amicall(SocketBase,0x11A,gethostname(a0,d0))
#pragma amicall(SocketBase,0x120,gethostid())
#pragma amicall(SocketBase,0x126,SocketBaseTagList(a0))
#pragma amicall(SocketBase,0x12C,GetSocketEvents(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall SocketBase socket               01E 21003
#pragma  libcall SocketBase bind                 024 18003
#pragma  libcall SocketBase listen               02A 1002
#pragma  libcall SocketBase accept               030 98003
#pragma  libcall SocketBase connect              036 18003
#pragma  libcall SocketBase sendto               03C 39218006
#pragma  libcall SocketBase send                 042 218004
#pragma  libcall SocketBase recvfrom             048 A9218006
#pragma  libcall SocketBase recv                 04E 218004
#pragma  libcall SocketBase shutdown             054 1002
#pragma  libcall SocketBase setsockopt           05A 3821005
#pragma  libcall SocketBase getsockopt           060 9821005
#pragma  libcall SocketBase getsockname          066 98003
#pragma  libcall SocketBase getpeername          06C 98003
#pragma  libcall SocketBase IoctlSocket          072 81003
#pragma  libcall SocketBase CloseSocket          078 001
#pragma  libcall SocketBase WaitSelect           07E 1BA98006
#pragma  libcall SocketBase SetSocketSignals     084 21003
#pragma  libcall SocketBase getdtablesize        08A 00
#pragma  libcall SocketBase ObtainSocket         090 321004
#pragma  libcall SocketBase ReleaseSocket        096 1002
#pragma  libcall SocketBase ReleaseCopyOfSocket  09C 1002
#pragma  libcall SocketBase Errno                0A2 00
#pragma  libcall SocketBase SetErrnoPtr          0A8 0802
#pragma  libcall SocketBase Inet_NtoA            0AE 001
#pragma  libcall SocketBase inet_addr            0B4 801
#pragma  libcall SocketBase Inet_LnaOf           0BA 001
#pragma  libcall SocketBase Inet_NetOf           0C0 001
#pragma  libcall SocketBase Inet_MakeAddr        0C6 1002
#pragma  libcall SocketBase inet_network         0CC 801
#pragma  libcall SocketBase gethostbyname        0D2 801
#pragma  libcall SocketBase gethostbyaddr        0D8 10803
#pragma  libcall SocketBase getnetbyname         0DE 801
#pragma  libcall SocketBase getnetbyaddr         0E4 1002
#pragma  libcall SocketBase getservbyname        0EA 9802
#pragma  libcall SocketBase getservbyport        0F0 8002
#pragma  libcall SocketBase getprotobyname       0F6 801
#pragma  libcall SocketBase getprotobynumber     0FC 001
#pragma  libcall SocketBase vsyslog              102 98003
#pragma  libcall SocketBase Dup2Socket           108 1002
#pragma  libcall SocketBase sendmsg              10E 18003
#pragma  libcall SocketBase recvmsg              114 18003
#pragma  libcall SocketBase gethostname          11A 0802
#pragma  libcall SocketBase gethostid            120 00
#pragma  libcall SocketBase SocketBaseTagList    126 801
#pragma  libcall SocketBase GetSocketEvents      12C 801
#endif
#ifdef __STORM__
#pragma tagcall(SocketBase,0x102,syslog(d0,a0,a1))
#pragma tagcall(SocketBase,0x126,SocketBaseTags(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall SocketBase syslog               102 98003
#pragma  tagcall SocketBase SocketBaseTags       126 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_SOCKET_LIB_H  */
