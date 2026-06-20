#ifndef _INCLUDE_PRAGMA_GATEWAY_LIB_H
#define _INCLUDE_PRAGMA_GATEWAY_LIB_H

#ifndef CLIB_GATEWAY_PROTOS_H
#include <clib/Gateway_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(GatewayBase,0x01E,GateRequest(d1,d2,d3))
#pragma amicall(GatewayBase,0x024,trim(d1))
#pragma amicall(GatewayBase,0x02A,rtrim(d1))
#pragma amicall(GatewayBase,0x030,trim_include(d1))
#pragma amicall(GatewayBase,0x036,mail_trim(d1,d2))
#pragma amicall(GatewayBase,0x03C,set(d1,d2))
#pragma amicall(GatewayBase,0x042,lset(d1,d2))
#pragma amicall(GatewayBase,0x048,lsetmin(d1,d2))
#pragma amicall(GatewayBase,0x04E,instr(d1,d2))
#pragma amicall(GatewayBase,0x054,midstr(d1,d2,d3))
#pragma amicall(GatewayBase,0x05A,newstr(d1,d2,d3,d4))
#pragma amicall(GatewayBase,0x060,wordwrp(d1,d2,d3))
#pragma amicall(GatewayBase,0x066,kill_ansi(d1))
#pragma amicall(GatewayBase,0x06C,fn_splitt(d1,d2,d3,d4,d5))
#pragma amicall(GatewayBase,0x072,fn_build(d1,d2,d3,d4,d5))
#pragma amicall(GatewayBase,0x078,time_to_zahl(d1))
#pragma amicall(GatewayBase,0x07E,date_to_zahl(d1))
#pragma amicall(GatewayBase,0x084,date_to_day(d1))
#pragma amicall(GatewayBase,0x08A,addval(d1,d2))
#pragma amicall(GatewayBase,0x090,ltofa(d1,d2))
#pragma amicall(GatewayBase,0x096,string(d1,d2,d3))
#pragma amicall(GatewayBase,0x09C,newer(d1,d2,d3,d4))
#pragma amicall(GatewayBase,0x0A2,upstr(d1))
#pragma amicall(GatewayBase,0x0A8,lowstr(d1))
#pragma amicall(GatewayBase,0x0AE,StrCaseCmp(d1,d2))
#pragma amicall(GatewayBase,0x0B4,strdup(d1))
#pragma amicall(GatewayBase,0x0BA,swapmem(d1,d2,d3))
#pragma amicall(GatewayBase,0x0C0,memncmp(d1,d2,d3))
#pragma amicall(GatewayBase,0x0C6,index(d1,d2))
#pragma amicall(GatewayBase,0x0CC,trim_cr(d1))
#pragma amicall(GatewayBase,0x0D2,instr_pat(d1,d2))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall GatewayBase GateRequest          01E 32103
#pragma  libcall GatewayBase trim                 024 101
#pragma  libcall GatewayBase rtrim                02A 101
#pragma  libcall GatewayBase trim_include         030 101
#pragma  libcall GatewayBase mail_trim            036 2102
#pragma  libcall GatewayBase set                  03C 2102
#pragma  libcall GatewayBase lset                 042 2102
#pragma  libcall GatewayBase lsetmin              048 2102
#pragma  libcall GatewayBase instr                04E 2102
#pragma  libcall GatewayBase midstr               054 32103
#pragma  libcall GatewayBase newstr               05A 432104
#pragma  libcall GatewayBase wordwrp              060 32103
#pragma  libcall GatewayBase kill_ansi            066 101
#pragma  libcall GatewayBase fn_splitt            06C 5432105
#pragma  libcall GatewayBase fn_build             072 5432105
#pragma  libcall GatewayBase time_to_zahl         078 101
#pragma  libcall GatewayBase date_to_zahl         07E 101
#pragma  libcall GatewayBase date_to_day          084 101
#pragma  libcall GatewayBase addval               08A 2102
#pragma  libcall GatewayBase ltofa                090 2102
#pragma  libcall GatewayBase string               096 32103
#pragma  libcall GatewayBase newer                09C 432104
#pragma  libcall GatewayBase upstr                0A2 101
#pragma  libcall GatewayBase lowstr               0A8 101
#pragma  libcall GatewayBase StrCaseCmp           0AE 2102
#pragma  libcall GatewayBase strdup               0B4 101
#pragma  libcall GatewayBase swapmem              0BA 32103
#pragma  libcall GatewayBase memncmp              0C0 32103
#pragma  libcall GatewayBase index                0C6 2102
#pragma  libcall GatewayBase trim_cr              0CC 101
#pragma  libcall GatewayBase instr_pat            0D2 2102
#endif

#endif	/*  _INCLUDE_PRAGMA_GATEWAY_LIB_H  */
