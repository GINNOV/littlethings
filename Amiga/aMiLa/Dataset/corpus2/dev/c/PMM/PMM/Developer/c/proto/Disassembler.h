#ifndef _PROTO_DISASSEMBLER_H
#define _PROTO_DISASSEMBLER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_DISASSEMBLER_PROTOS_H
#include <clib/Disassembler_protos.h>
#endif

#ifdef __GNUC__
#include <inline/Disassembler.h>
#else
#include <pragma/Disassembler_lib.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *DisassemblerBase;
#endif

#endif	/*  _PROTO_DISASSEMBLER_H  */
