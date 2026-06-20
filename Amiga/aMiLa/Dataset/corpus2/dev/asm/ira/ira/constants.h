/*
 * constants.h
 *
 *  Created on: 1 may 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : constants.h
 *      Purpose  : Header for constants
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2015 Frank Wille, (C)2014-2017 Nicolas Bastien
 */

#ifndef CONSTANTS_H_
#define CONSTANTS_H_

extern const size_t cpuname_number;

extern const char cpu_cc[][3],
                  mmu_cc[][3],
                  extensions[][3],
                  caches[][3],
                  bitop[][4],
                  memtypename[][9],
                  modname[][5],
                  bitfield[][5],
                  cpuname[][8],
                  pmmu_reg1[][4],
                  pmmu_reg2[][5];

extern const size_t OpCode_number;
extern Opcode_t instructions[];
extern const ControlRegister_t ControlRegisters[18];

extern const size_t x_adr_number;
extern const x_adr_t x_adrs[];

#endif /* CONSTANTS_H_ */
