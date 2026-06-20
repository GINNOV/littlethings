/*
 * constants.c
 *
 *  Created on: 1 may 2015
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : constants.c
 *      Purpose  : Contains data for IRA
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2024 Frank Wille, (C)2014-2018 Nicolas Bastien
 */

#include <stdio.h>
#include <stdint.h>

#include "ira.h"

/* Indices of cpuname array are directly linked to CPU defines */
const char cpuname[][8] = {"MC68000", "MC68010", "MC68020", "MC68030", "MC68040", "MC68060", "MC68851", "MC68881", "MC68882"};

/* Number of elements in the cpuname array above */
const size_t cpuname_number = sizeof(cpuname) / 8;

/* All data are now gathered into an unique array */
/* note: family field is used to execute specific piece of code (i.e checking extension word with LPSTOP) */
Opcode_t instructions[] = {
/* family                   opcode[8]  result  mask    srcadr                                                                                      destadr                                                                 flags                               cputype */
{OPC_BITFIELD,              "BF",      0xe8c0, 0xf8c0, MODE_SPECIFIC,                                                                              MODE_SPECIFIC,                                                          OPF_ONE_MORE_WORD,                  M020UP},
{OPC_ROTATE_SHIFT_MEMORY,   "ASL",     0xe1c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "ASR",     0xe0c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "LSL",     0xe3c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "LSR",     0xe2c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "ROXL",    0xe5c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "ROXR",    0xe4c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "ROL",     0xe7c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_MEMORY,   "ROR",     0xe6c0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_OPERAND_WORD,                   M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "ASL",     0xe100, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "ASR",     0xe000, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "LSL",     0xe108, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "LSR",     0xe008, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "ROXL",    0xe110, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "ROXR",    0xe010, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "ROL",     0xe118, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_ROTATE_SHIFT_REGISTER, "ROR",     0xe018, 0xf118, MODE_IN_LOWER_BYTE|MODE_ROTATE_SHIFT,                                                       MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ILLEGAL", 0x4afc, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "NOP",     0x4e71, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "RESET",   0x4e70, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_RTE,                   "RTE",     0x4e73, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_RTR,                   "RTR",     0x4e77, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_RTS,                   "RTS",     0x4e75, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_RTD,                   "RTD",     0x4e74, 0xffff, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_SP_DISPLACE_W,                                  OPF_OPERAND_BYTE,                   M010UP},
{OPC_NONE,                  "STOP",    0x4e72, 0xffff, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          MODE_NONE,                                                              OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "TRAPV",   0x4e76, 0xffff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "MOVEC",   0x4e7a, 0xfffe, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_MOVEC,                                          OPF_OPERAND_LONG,                   M010UP},
{OPC_NONE,                  "BKPT",    0x4848, 0xfff8, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_BKPT,                                           OPF_OPERAND_BYTE,                   M010UP},
{OPC_NONE,                  "SWAP",    0x4840, 0xfff8, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "LINK.W",  0x4e50, 0xfff8, MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_SP_DISPLACE_W,                                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "LINK.L",  0x4808, 0xfff8, MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_SP_DISPLACE_L,                                  OPF_OPERAND_WORD,                   M020UP},
{OPC_NONE,                  "UNLK",    0x4e58, 0xfff8, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                    OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "EXT.W",   0x4880, 0xfff8, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "EXT.L",   0x48c0, 0xfff8, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "EXTB.L",  0x49c0, 0xfff8, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_OPERAND_LONG,                   M020UP},
{OPC_NONE,                  "MOVE.L",  0x4e68, 0xfff8, MODE_IN_LOWER_BYTE|MODE_USP,                                                                MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                    OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "MOVE.L",  0x4e60, 0xfff8, MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_USP,                                            OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "TRAP",    0x4e40, 0xfff0, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_TRAP,                                           OPF_OPERAND_BYTE,                   M680x0},
{OPC_DIVL,                  "DIV",     0x4c40, 0xffc0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_MUL_DIV_LONG,                                   OPF_OPERAND_LONG|OPF_ONE_MORE_WORD, M020UP},
{OPC_MULL,                  "MUL",     0x4c00, 0xffc0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_MUL_DIV_LONG,                                   OPF_OPERAND_LONG|OPF_ONE_MORE_WORD, M020UP},
{OPC_NONE,                  "TAS",     0x4ac0, 0xffc0, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_BYTE,                   M680x0},
{OPC_JMP,                   "JMP",     0x4ec0, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                    OPF_OPERAND_WORD,                   M680x0},
{OPC_JSR,                   "JSR",     0x4e80, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                    OPF_OPERAND_WORD,                   M680x0},
{OPC_PEA,                   "PEA",     0x4840, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                    OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "NBCD",    0x4800, 0xffc0, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "MOVE",    0x44c0, 0xffc0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_CCR,                                            OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "MOVE",    0x46c0, 0xffc0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_SR,                                             OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "MOVE",    0x40c0, 0xffc0, MODE_IN_LOWER_BYTE|MODE_SR,                                                                 D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "MOVE",    0x42c0, 0xffc0, MODE_IN_LOWER_BYTE|MODE_CCR,                                                                D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_WORD,                   M010UP},
{OPC_MOVEM,                 "MOVEM.W", 0x4880, 0xffc0, MODE_IN_LOWER_BYTE|MODE_MOVEM,                                                              A_IND|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,                        OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M680x0},
{OPC_NONE,                  "MOVEM.W", 0x4c80, 0xffc0, A_IND|A_IND_POST|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                             MODE_IN_LOWER_BYTE|MODE_MOVEM,                                          OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M680x0},
{OPC_MOVEM,                 "MOVEM.L", 0x48c0, 0xffc0, MODE_IN_LOWER_BYTE|MODE_MOVEM,                                                              A_IND|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,                        OPF_OPERAND_LONG|OPF_ONE_MORE_WORD, M680x0},
{OPC_NONE,                  "MOVEM.L", 0x4cc0, 0xffc0, A_IND|A_IND_POST|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                             MODE_IN_LOWER_BYTE|MODE_MOVEM,                                          OPF_OPERAND_LONG|OPF_ONE_MORE_WORD, M680x0},
{OPC_LEA,                   "LEA",     0x41c0, 0xf1c0, A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "CHK.W",   0x4180, 0xf1c0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "CHK.L",   0x4100, 0xf1c0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_LONG,                   M020UP},
{OPC_NONE,                  "CLR",     0x4200, 0xff00, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_TST,                   "TST",     0x4a00, 0xff00, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,                           MODE_NONE,                                                              OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "NOT",     0x4600, 0xff00, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "NEG",     0x4400, 0xff00, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "NEGX",    0x4000, 0xff00, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ADDA.W",  0xd0c0, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "ADDA.L",  0xd1c0, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "ADDX",    0xd100, 0xf138, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ADDX",    0xd108, 0xf138, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_PRE,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_PRE,            OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ADD",     0xd100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ADD",     0xd000, 0xf100, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "EXG",     0xc140, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                    OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "EXG",     0xc148, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                                      MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                    OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "EXG",     0xc188, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      MODE_IN_LOWER_BYTE|MODE_AREG_DIRECT,                                    OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "ABCD",    0xc100, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "ABCD",    0xc108, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_PRE,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_PRE,            OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "MULS",    0xc1c0, 0xf1c0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "MULU",    0xc0c0, 0xf1c0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "AND",     0xc100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "AND",     0xc000, 0xf100, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "CMPA.W",  0xb0c0, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "CMPA.L",  0xb1c0, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "CMPM",    0xb108, 0xf138, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_POST,                                                 MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_POST,           OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "CMP",     0xb000, 0xf100, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "EOR",     0xb100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_PACK_UNPACK,           "PACK",    0x8148, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_PRE,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_PRE,            OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M020UP},
{OPC_PACK_UNPACK,           "PACK",    0x8140, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M020UP},
{OPC_PACK_UNPACK,           "UNPK",    0x8188, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_PRE,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_PRE,            OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M020UP},
{OPC_PACK_UNPACK,           "UNPK",    0x8180, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M020UP},
{OPC_NONE,                  "SBCD",    0x8100, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "SBCD",    0x8108, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_PRE,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_PRE,            OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "DIVS",    0x81c0, 0xf1c0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "DIVU",    0x80c0, 0xf1c0, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "OR",      0x8100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "OR",      0x8000, 0xf100, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED,       MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_MOVE,                  "MOVE.B",  0x1000, 0xf000, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "MOVEA.W", 0x3040, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_MOVE,                  "MOVE.W",  0x3000, 0xf000, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_WORD,                   M680x0},
{OPC_MOVEAL,                "MOVEA.L", 0x2040, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_LONG,                   M680x0},
{OPC_MOVE,                  "MOVE.L",  0x2000, 0xf000, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "MOVEQ",   0x7000, 0xf100, MODE_IN_LOWER_BYTE|MODE_MOVEQ,                                                              MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_BYTE,                   M680x0},
{OPC_NONE,                  "SUBA.W",  0x90c0, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0},
{OPC_NONE,                  "SUBA.L",  0x91c0, 0xf1c0, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_DIRECT,                  OPF_OPERAND_LONG,                   M680x0},
{OPC_NONE,                  "SUBX",    0x9100, 0xf138, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "SUBX",    0x9108, 0xf138, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_PRE,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_AREG_INDIRECT_PRE,            OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "SUB",     0x9100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "SUB",     0x9000, 0xf100, D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "MOVEP",   0x0188, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_D16,                              OPF_OPERAND_WORD,                   M680x0 ^ M68060},
{OPC_NONE,                  "MOVEP.W", 0x0108, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_D16,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_WORD,                   M680x0 ^ M68060},
{OPC_NONE,                  "MOVEP.L", 0x01c8, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                                      MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_D16,                              OPF_OPERAND_LONG,                   M680x0 ^ M68060},
{OPC_NONE,                  "MOVEP.L", 0x0148, 0xf1f8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_D16,                                                  MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_DREG_DIRECT,                  OPF_OPERAND_LONG,                   M680x0 ^ M68060},
{OPC_NONE,                  "B",       0x0800, 0xff00, MODE_IN_LOWER_BYTE|MODE_BIT_MANIPULATION,                                                   MODE_NONE,                                                              OPF_NO_FLAG,                        M680x0},
{OPC_NONE,                  "CAS2",    0x08fc, 0xf9ff, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_CAS2,                                           OPF_ONE_MORE_WORD,                  M020UP},
{OPC_NONE,                  "CAS",     0x08c0, 0xf9c0, MODE_IN_LOWER_BYTE|MODE_CAS,                                                                A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,             OPF_ONE_MORE_WORD,                  M020UP},
{OPC_RTM,                   "RTM",     0x06c0, 0xfff0, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_RTM,                                            OPF_NO_FLAG,                        M68020},
{OPC_CALLM,                 "CALLM",   0x06c0, 0xffc0, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                    OPF_OPERAND_WORD,                   M68020},
{OPC_C2,                    "C",       0x00c0, 0xf9c0, A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                                        MODE_NONE,                                                              OPF_APPEND_SIZE|OPF_ONE_MORE_WORD,  M020UP},
{OPC_CMPI,                  "CMPI",    0x0c00, 0xff00, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "EORI",    0x0a00, 0xff00, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED, OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ANDI",    0x0200, 0xff00, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED, OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ADDI",    0x0600, 0xff00, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "SUBI",    0x0400, 0xff00, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "ORI",     0x0000, 0xff00, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED, OPF_APPEND_SIZE,                    M680x0},
{OPC_BITOP,                 "B",       0x0100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_BIT_MANIPULATION,                                 MODE_NONE,                                                              OPF_NO_FLAG,                        M680x0},
{OPC_MOVES,                 "MOVES",   0x0e00, 0xff00, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_APPEND_SIZE|OPF_ONE_MORE_WORD,  M010UP},
{OPC_DBcc,                  "DB",      0x50c8, 0xf0f8, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_DBcc,                                           OPF_OPERAND_BYTE|OPF_APPEND_CC,     M680x0},
{OPC_NONE,                  "TRAP",    0x50fc, 0xf0ff, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_OPERAND_BYTE|OPF_APPEND_CC,     M020UP},
{OPC_NONE,                  "TRAP",    0x50fa, 0xf0ff, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          MODE_NONE,                                                              OPF_OPERAND_WORD|OPF_APPEND_CC,     M020UP},
{OPC_NONE,                  "TRAP",    0x50fb, 0xf0ff, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          MODE_NONE,                                                              OPF_OPERAND_LONG|OPF_APPEND_CC,     M020UP},
{OPC_NONE,                  "S",       0x50c0, 0xf0c0, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_OPERAND_BYTE|OPF_APPEND_CC,     M680x0},
{OPC_NONE,                  "ADDQ",    0x5000, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_ADDQ_SUBQ,                                        D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32, OPF_APPEND_SIZE,                    M680x0},
{OPC_NONE,                  "SUBQ",    0x5100, 0xf100, MODE_IN_LOWER_BYTE|MODE_ALT_REGISTER|MODE_ADDQ_SUBQ,                                        D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32, OPF_APPEND_SIZE,                    M680x0},
{OPC_Bcc,                   "B",       0x6000, 0xf000, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_Bcc,                                            OPF_OPERAND_BYTE|OPF_APPEND_CC,     M680x0},
{OPC_PMMU,                  "P",       0xf000, 0xffc0, MODE_NONE,                                                                                  MODE_NONE,                                                              OPF_ONE_MORE_WORD,                  M68030|M68851},
{OPC_PFLUSH040,             "PFLUSH",  0xf500, 0xffe0, MODE_NONE,                                                                                  MODE_SPECIFIC,                                                          OPF_NO_FLAG,                        M040UP},
{OPC_PTEST040,              "PTEST",   0xf548, 0xffd8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT,                                                      MODE_NONE,                                                              OPF_NO_FLAG,                        M68040},
{OPC_PBcc,                  "PB",      0xf080, 0xffb0, MODE_NONE,                                                                                  MODE_IN_LOWER_BYTE|MODE_PBcc,                                           OPF_APPEND_SIZE|OPF_APPEND_PCC,     M68851},
{OPC_PDBcc,                 "PDB",     0xf048, 0xfff8, MODE_IN_LOWER_BYTE|MODE_DREG_DIRECT,                                                        MODE_IN_LOWER_BYTE|MODE_PDBcc,                                          OPF_ONE_MORE_WORD|OPF_APPEND_PCC,   M68851},
{OPC_NONE,                  "PSAVE",   0xf100, 0xffc0, MODE_NONE,                                                                                  A_IND|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,                        OPF_NO_FLAG,                        M68851},
{OPC_NONE,                  "PRESTORE",0xf140, 0xffc0, A_IND|A_IND_POST|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND,                             MODE_NONE,                                                              OPF_NO_FLAG,                        M68851},
{OPC_PTRAPcc,               "PTRAP",   0xf078, 0xfff8, MODE_SPECIFIC,                                                                              MODE_NONE,                                                              OPF_ONE_MORE_WORD|OPF_APPEND_PCC,   M68851},
{OPC_PScc,                  "PS",      0xf040, 0xffc0, MODE_NONE,                                                                                  D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32,       OPF_ONE_MORE_WORD|OPF_APPEND_PCC,   M68851},
{OPC_NONE,                  "CINVA",   0xf418, 0xff3f, MODE_IN_LOWER_BYTE|MODE_CACHE_REG,                                                          MODE_NONE,                                                              OPF_NO_FLAG,                        M040UP},
{OPC_CACHE_SCOPE,           "CINV",    0xf400, 0xff20, MODE_IN_LOWER_BYTE|MODE_CACHE_REG,                                                          MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT,                                  OPF_NO_FLAG,                        M040UP},
{OPC_NONE,                  "CPUSHA",  0xf438, 0xff3f, MODE_IN_LOWER_BYTE|MODE_CACHE_REG,                                                          MODE_NONE,                                                              OPF_NO_FLAG,                        M040UP},
{OPC_CACHE_SCOPE,           "CPUSH",   0xf420, 0xff20, MODE_IN_LOWER_BYTE|MODE_CACHE_REG,                                                          MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT,                                  OPF_NO_FLAG,                        M040UP},
{OPC_PLPA,                  "PLPA",    0xf588, 0xffb8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT,                                                      MODE_NONE,                                                              OPF_NO_FLAG,                        M68060},
{OPC_MOVE16,                "MOVE16",  0xf620, 0xfff8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_POST,                                                 MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_POST|MODE_EXT_REGISTER,           OPF_ONE_MORE_WORD,                  M040UP},
{OPC_NONE,                  "MOVE16",  0xf600, 0xfff8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_POST,                                                 MODE_IN_LOWER_BYTE|MODE_ABSOLUTE_32,                                    OPF_NO_FLAG,                        M040UP},
{OPC_NONE,                  "MOVE16",  0xf608, 0xfff8, MODE_IN_LOWER_BYTE|MODE_ABSOLUTE_32,                                                        MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT_POST,                             OPF_NO_FLAG,                        M040UP},
{OPC_NONE,                  "MOVE16",  0xf610, 0xfff8, MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT,                                                      MODE_IN_LOWER_BYTE|MODE_ABSOLUTE_32,                                    OPF_NO_FLAG,                        M040UP},
{OPC_NONE,                  "MOVE16",  0xf618, 0xfff8, MODE_IN_LOWER_BYTE|MODE_ABSOLUTE_32,                                                        MODE_IN_LOWER_BYTE|MODE_AREG_INDIRECT,                                  OPF_NO_FLAG,                        M040UP},
{OPC_LPSTOP,                "LPSTOP",  0xf800, 0xffff, MODE_IN_LOWER_BYTE|MODE_IMMEDIATE,                                                          MODE_NONE,                                                              OPF_OPERAND_WORD|OPF_ONE_MORE_WORD, M68060},
/* note: that special opcode description, which stands for "unknown opcode", HAS to be the last element of instructions[] array ! */
{OPC_NONE,                  "",        0x0000, 0x0000, MODE_IN_LOWER_BYTE|MODE_INVALID,                                                            MODE_NONE,                                                              OPF_OPERAND_BYTE,                   M680x0}};

/* instruction (up to 68060) summary */
/*
x  ABCD
x  ADD
x  ADDA
x  ADDI
x  ADDQ
x  ADDX
x  AND
x  ANDI
x  ANDI to CCR
x  ANDI to SR
x  ASL
x  ASR
x  Bcc
x  BCHG
x  BCLR
x  BFCHG
x  BFCLR
x  BFEXTS
x  BFEXTU
x  BFFFO
x  BFINS
x  BFSET
x  BFTST
x  BKPT
x  BRA
x  BSET
x  BSR
x  BTST
x  CALLM
x  CAS
x  CAS2
x  CHK
x  CHK2
x  CINV
x  CLR
x  CMP
x  CMPA
x  CMPI
x  CMPM
x  CMP2
x  CPUSH
x  DBcc
x  DIVS
x  DIVSL
x  DIVU
x  DIVUL
x  EOR
x  EORI
x  EORI to CCR
x  EORI to SR
x  EXG
x  EXT
x  EXTB
   FABS           040 060 88x
   FSABS          040 060
   FDABS          040 060
   FACOS          040 060 88x
   FADD           040 060 88x
   FSADD          040 060
   FDADD          040 060
   FASIN          040 060 88x
   FATAN          040 060 88x
   FATANH         040 060 88x
   FBcc           040 060 88x
   FCMP           040 060 88x
   FCOS           040 060 88x
   FCOSH          040 060 88x
   FDBcc          040 060 88x
   FDIV           040 060 88x
   FSDIV          040 060
   FDDIV          040 060
   FETOX          040 060 88x
   FETOXM1        040 060 88x
   FGETEXP        040 060 88x
   FGETMAN        040 060 88x
   FINT           040 060 88x
   FINTRZ         040 060 88x
   FLOG10         040 060 88x
   FLOG2          040 060 88x
   FLOGN          040 060 88x
   FLOGNP1        040 060
   FMOD           040 060 88x
   FMOVE          040 060 88x
   FSMOVE         040 060
   FDMOVE         040 060
   FMOVECR        040 060 88x
   FMOVEM         040 060 88x
   FMUL           040 060 88x
   FSMUL          040 060
   FDMUL          040 060
   FNEG           040 060 88x
   FSNEG          040 060
   FDNEG          040 060
   FNOP           040 060 88x
   FREM           040 060 88x
   FRESTORE       040 060 88x
   FSAVE          040 060 88x
   FSCALE         040 060 88x
   FScc           040 060 88x
   FSGLDIV        040 060 88x
   FSGLMUL        040 060 88x
   FSIN           040 060 88x
   FSINCOS        040 060 88x
   FSINH          040 060 88x
   FSQRT          040 060 88x
   FSSQRT         040 060
   FDSQRT         040 060
   FSUB           040 060 88x
   FSSUB          040 060
   FDSUB          040 060
   FTAN           040 060 88x
   FTANH          040 060 88x
   FTENTOX        040 060 88x
   FTRAPcc        040 060 88x
   FTST           040 060 88x
   FTWOTOX        040 060 88x
x  ILLEGAL
x  JMP
x  JSR
x  LEA
x  LINK
x  LPSTOP
x  LSL
x  LSR
x  MOVE
x  MOVEA
x  MOVE from CCR
x  MOVE to CCR
x  MOVE from SR
x  MOVE to SR
x  MOVE USP
x  MOVE16
x  MOVEC
x  MOVEM
x  MOVEP
x  MOVEQ
x  MOVES
x  MULS
x  MULU
x  NBCD
x  NEG
x  NEGX
x  NOP
x  NOT
x  OR
x  ORI
x  ORI to CCR
x  ORI to SR
x  PACK
x  PBcc           851
x  PDBcc          851
x  PEA
x  PFLUSH         030 040 060 851
x  PLPA           060
x  PLOAD          030 851
x  PMOVE          030 851
x  PRESTORE       851
x  PSAVE          851
x  PScc           851
x  PTEST          030 040 851
x  PTRAPcc        851
x  PVALID         851
x  RESET
x  ROL
x  ROR
x  ROXL
x  ROXR
x  RTD
x  RTE
x  RTM
x  RTR
x  RTS
x  SBCD
x  Scc
x  STOP
x  SUB
x  SUBA
x  SUBI
x  SUBQ
x  SUBX
x  SWAP
x  TAS
x  TRAP
x  TRAPcc
x  TRAPV
x  TST
x  UNLK
x  UNPK
*/
/* Number of elements in the instructions array above */
const size_t OpCode_number = sizeof(instructions) / sizeof(Opcode_t);

const char cpu_cc[][3] = {"T", "F", "HI", "LS", "CC", "CS", "NE", "EQ", "VC", "VS", "PL", "MI", "GE", "LT", "GT", "LE", "RA", "SR"};
const char mmu_cc[][3] = {"BS", "BC", "LS", "LC", "SS", "SC", "AS", "AC", "WS", "WC", "IS", "IC", "GS", "GC", "CS", "CC"};
const char fpu_cc[][5] = {"F", "EQ", "OGT", "OGE", "OLT", "OLE", "OGL", "OR", "UN", "UEQ", "UGT", "UGE", "ULT", "ULE", "NE", "T", "SF", "SEQ", "GT", "GE", "LT", "LE", "GL", "GLE", "NGLE", "NGL", "NLE", "NLT", "NGE", "NGT", "SNE", "ST"};
const char extensions[][3] = {".B", ".W", ".L"};
const char caches[][3] = {"NC", "DC", "IC", "BC"};
const char bitop[][4] = {"TST", "CHG", "CLR", "SET"};
const char memtypename[][9] = {"PUBLIC", "CHIP", "FAST", "EXTENDED"};
const char modname[][5] = {"CODE", "DATA", "BSS"};
const char bitfield[][5] = {"TST", "EXTU", "CHG", "EXTS", "CLR", "FFO", "SET", "INS"};
const ControlRegister_t ControlRegisters[18] = {
   {"SFC",   M010UP},               {"DFC",  M010UP},               {"CACR",  M020UP}, {"TC",   M040UP},
   {"ITT0",  M040UP},               {"ITT1", M040UP},               {"DTT0",  M040UP}, {"DTT1", M040UP},
   {"BUSCR", M68060},               {"USP",  M010UP},               {"VBR",   M010UP}, {"CAAR", M68020|M68030},
   {"MSP",   M68020|M68030|M68040}, {"ISP",  M68020|M68030|M68040}, {"MMUSR", M68040}, {"URP",  M040UP},
   {"SRP",   M040UP},               {"PCR",  M68060}};
const char pmmu_reg1[][4] = {"TC", "DRP", "SRP", "CRP", "CAL", "VAL", "SCC", "AC"};
const char pmmu_reg2[][5] = {"PSR", "PCSR", "", "", "BAD", "BAC"};

const x_adr_t x_adrs[] = {
{"ABSEXECBASE", 0x0004,SOURCE_FAMILY_AMIGA},
{"BUS_ERROR",   0x0008,0},
{"ADR_ERROR",   0x000C,0},
{"ILLEG_OPC",   0x0010,0},
{"DIVISION0",   0x0014,0},
{"CHK",         0x0018,0},
{"TRAPV",       0x001C,0},
{"PRIVILEG",    0x0020,0},
{"TRACE",       0x0024,0},
{"LINEA_EMU",   0x0028,0},
{"LINEF_EMU",   0x002C,0},
{"INT_NOINI",   0x003C,0},
{"INT_WRONG",   0x0060,0},
{"AUTO_INT1",   0x0064,0},
{"AUTO_INT2",   0x0068,0},
{"AUTO_INT3",   0x006C,0},
{"AUTO_INT4",   0x0070,0},
{"AUTO_INT5",   0x0074,0},
{"AUTO_INT6",   0x0078,0},
{"NMI",         0x007C,0},
{"TRAP_00",     0x0080,0},
{"TRAP_01",     0x0084,0},
{"TRAP_02",     0x0088,0},
{"TRAP_03",     0x008C,0},
{"TRAP_04",     0x0090,0},
{"TRAP_05",     0x0094,0},
{"TRAP_06",     0x0098,0},
{"TRAP_07",     0x009C,0},
{"TRAP_08",     0x00A0,0},
{"TRAP_09",     0x00A4,0},
{"TRAP_10",     0x00A8,0},
{"TRAP_11",     0x00AC,0},
{"TRAP_12",     0x00B0,0},
{"TRAP_13",     0x00B4,0},
{"TRAP_14",     0x00B8,0},
{"TRAP_15",     0x00BC,0},
{"CIAB_PRA",    0xBFD000,SOURCE_FAMILY_AMIGA},
{"CIAB_PRB",    0xBFD100,SOURCE_FAMILY_AMIGA},
{"CIAB_DDRA",   0xBFD200,SOURCE_FAMILY_AMIGA},
{"CIAB_DDRB",   0xBFD300,SOURCE_FAMILY_AMIGA},
{"CIAB_TALO",   0xBFD400,SOURCE_FAMILY_AMIGA},
{"CIAB_TAHI",   0xBFD500,SOURCE_FAMILY_AMIGA},
{"CIAB_TBLO",   0xBFD600,SOURCE_FAMILY_AMIGA},
{"CIAB_TBHI",   0xBFD700,SOURCE_FAMILY_AMIGA},
{"CIAB_TDLO",   0xBFD800,SOURCE_FAMILY_AMIGA},
{"CIAB_TDMD",   0xBFD900,SOURCE_FAMILY_AMIGA},
{"CIAB_TDHI",   0xBFDA00,SOURCE_FAMILY_AMIGA},
{"CIAB_SDR",    0xBFDC00,SOURCE_FAMILY_AMIGA},
{"CIAB_ICR",    0xBFDD00,SOURCE_FAMILY_AMIGA},
{"CIAB_CRA",    0xBFDE00,SOURCE_FAMILY_AMIGA},
{"CIAB_CRB",    0xBFDF00,SOURCE_FAMILY_AMIGA},
{"CIAA_PRA",    0xBFE001,SOURCE_FAMILY_AMIGA},
{"CIAA_PRB",    0xBFE101,SOURCE_FAMILY_AMIGA},
{"CIAA_DDRA",   0xBFE201,SOURCE_FAMILY_AMIGA},
{"CIAA_DDRB",   0xBFE301,SOURCE_FAMILY_AMIGA},
{"CIAA_TALO",   0xBFE401,SOURCE_FAMILY_AMIGA},
{"CIAA_TAHI",   0xBFE501,SOURCE_FAMILY_AMIGA},
{"CIAA_TBLO",   0xBFE601,SOURCE_FAMILY_AMIGA},
{"CIAA_TBHI",   0xBFE701,SOURCE_FAMILY_AMIGA},
{"CIAA_TDLO",   0xBFE801,SOURCE_FAMILY_AMIGA},
{"CIAA_TDMD",   0xBFE901,SOURCE_FAMILY_AMIGA},
{"CIAA_TDHI",   0xBFEA01,SOURCE_FAMILY_AMIGA},
{"CIAA_SDR",    0xBFEC01,SOURCE_FAMILY_AMIGA},
{"CIAA_ICR",    0xBFED01,SOURCE_FAMILY_AMIGA},
{"CIAA_CRA",    0xBFEE01,SOURCE_FAMILY_AMIGA},
{"CIAA_CRB",    0xBFEF01,SOURCE_FAMILY_AMIGA},
{"CLK_S1",      0xDC0000,SOURCE_FAMILY_AMIGA},
{"CLK_S10",     0xDC0004,SOURCE_FAMILY_AMIGA},
{"CLK_MI1",     0xDC0008,SOURCE_FAMILY_AMIGA},
{"CLK_MI10",    0xDC000C,SOURCE_FAMILY_AMIGA},
{"CLK_H1",      0xDC0010,SOURCE_FAMILY_AMIGA},
{"CLK_H10",     0xDC0014,SOURCE_FAMILY_AMIGA},
{"CLK_D1",      0xDC0018,SOURCE_FAMILY_AMIGA},
{"CLK_D10",     0xDC001C,SOURCE_FAMILY_AMIGA},
{"CLK_MO1",     0xDC0020,SOURCE_FAMILY_AMIGA},
{"CLK_MO10",    0xDC0024,SOURCE_FAMILY_AMIGA},
{"CLK_Y1",      0xDC0028,SOURCE_FAMILY_AMIGA},
{"CLK_Y10",     0xDC002E,SOURCE_FAMILY_AMIGA},
{"CLK_WEEK",    0xDC0030,SOURCE_FAMILY_AMIGA},
{"CLK_CD",      0xDC0034,SOURCE_FAMILY_AMIGA},
{"CLK_CE",      0xDC0038,SOURCE_FAMILY_AMIGA},
{"CLK_CF",      0xDC003C,SOURCE_FAMILY_AMIGA},
{"HARDBASE",    0xDFF000,SOURCE_FAMILY_AMIGA},
{"DMACONR",     0xDFF002,SOURCE_FAMILY_AMIGA},
{"VPOSR",       0xDFF004,SOURCE_FAMILY_AMIGA},
{"VHPOSR",      0xDFF006,SOURCE_FAMILY_AMIGA},
{"DSKDATR",     0xDFF008,SOURCE_FAMILY_AMIGA},
{"JOY0DAT",     0xDFF00A,SOURCE_FAMILY_AMIGA},
{"JOY1DAT",     0xDFF00C,SOURCE_FAMILY_AMIGA},
{"CLXDAT",      0xDFF00E,SOURCE_FAMILY_AMIGA},
{"ADKCONR",     0xDFF010,SOURCE_FAMILY_AMIGA},
{"POT0DAT",     0xDFF012,SOURCE_FAMILY_AMIGA},
{"POT1DAT",     0xDFF014,SOURCE_FAMILY_AMIGA},
{"POTGOR",      0xDFF016,SOURCE_FAMILY_AMIGA},
{"SERDATR",     0xDFF018,SOURCE_FAMILY_AMIGA},
{"DSKBYTR",     0xDFF01A,SOURCE_FAMILY_AMIGA},
{"INTENAR",     0xDFF01C,SOURCE_FAMILY_AMIGA},
{"INTREQR",     0xDFF01E,SOURCE_FAMILY_AMIGA},
{"DSKPTH",      0xDFF020,SOURCE_FAMILY_AMIGA},
{"DSKPTL",      0xDFF022,SOURCE_FAMILY_AMIGA},
{"DSKLEN",      0xDFF024,SOURCE_FAMILY_AMIGA},
{"DSKDAT",      0xDFF026,SOURCE_FAMILY_AMIGA},
{"REFPTR",      0xDFF028,SOURCE_FAMILY_AMIGA},
{"VPOSW",       0xDFF02A,SOURCE_FAMILY_AMIGA},
{"VHPOSW",      0xDFF02C,SOURCE_FAMILY_AMIGA},
{"COPCON",      0xDFF02E,SOURCE_FAMILY_AMIGA},
{"SERDAT",      0xDFF030,SOURCE_FAMILY_AMIGA},
{"SERPER",      0xDFF032,SOURCE_FAMILY_AMIGA},
{"POTGO",       0xDFF034,SOURCE_FAMILY_AMIGA},
{"JOYTEST",     0xDFF036,SOURCE_FAMILY_AMIGA},
{"STREQU",      0xDFF038,SOURCE_FAMILY_AMIGA},
{"STRVBL",      0xDFF03A,SOURCE_FAMILY_AMIGA},
{"STRHOR",      0xDFF03C,SOURCE_FAMILY_AMIGA},
{"STRLONG",     0xDFF03E,SOURCE_FAMILY_AMIGA},
{"BLTCON0",     0xDFF040,SOURCE_FAMILY_AMIGA},
{"BLTCON1",     0xDFF042,SOURCE_FAMILY_AMIGA},
{"BLTAFWM",     0xDFF044,SOURCE_FAMILY_AMIGA},
{"BLTALWM",     0xDFF046,SOURCE_FAMILY_AMIGA},
{"BLTCPTH",     0xDFF048,SOURCE_FAMILY_AMIGA},
{"BLTCPTL",     0xDFF04A,SOURCE_FAMILY_AMIGA},
{"BLTBPTH",     0xDFF04C,SOURCE_FAMILY_AMIGA},
{"BLTBPTL",     0xDFF04E,SOURCE_FAMILY_AMIGA},
{"BLTAPTH",     0xDFF050,SOURCE_FAMILY_AMIGA},
{"BLTAPTL",     0xDFF052,SOURCE_FAMILY_AMIGA},
{"BLTDPTH",     0xDFF054,SOURCE_FAMILY_AMIGA},
{"BLTDPTL",     0xDFF056,SOURCE_FAMILY_AMIGA},
{"BLTSIZE",     0xDFF058,SOURCE_FAMILY_AMIGA},
{"BLTCON01",    0xDFF05A,SOURCE_FAMILY_AMIGA}, /* ECS */
{"BLTSIZV",     0xDFF05C,SOURCE_FAMILY_AMIGA}, /* ECS */
{"BLTSIZH",     0xDFF05E,SOURCE_FAMILY_AMIGA}, /* ECS */
{"BLTCMOD",     0xDFF060,SOURCE_FAMILY_AMIGA},
{"BLTBMOD",     0xDFF062,SOURCE_FAMILY_AMIGA},
{"BLTAMOD",     0xDFF064,SOURCE_FAMILY_AMIGA},
{"BLTDMOD",     0xDFF066,SOURCE_FAMILY_AMIGA}, /* 50 */
{"BLTCDAT",     0xDFF070,SOURCE_FAMILY_AMIGA},
{"BLTBDAT",     0xDFF072,SOURCE_FAMILY_AMIGA},
{"BLTADAT",     0xDFF074,SOURCE_FAMILY_AMIGA},
{"BLTDDAT",     0xDFF076,SOURCE_FAMILY_AMIGA},
{"SPRHDAT",     0xDFF078,SOURCE_FAMILY_AMIGA}, /* ECS */
{"DENISEID",    0xDFF07C,SOURCE_FAMILY_AMIGA}, /* ECS */
{"DSKSYNC",     0xDFF07E,SOURCE_FAMILY_AMIGA},
{"COP1LCH",     0xDFF080,SOURCE_FAMILY_AMIGA},
{"COP1LCL",     0xDFF082,SOURCE_FAMILY_AMIGA},
{"COP2LCH",     0xDFF084,SOURCE_FAMILY_AMIGA},
{"COP2LCL",     0xDFF086,SOURCE_FAMILY_AMIGA},
{"COPJMP1",     0xDFF088,SOURCE_FAMILY_AMIGA},
{"COPJMP2",     0xDFF08A,SOURCE_FAMILY_AMIGA},
{"COPINS",      0xDFF08C,SOURCE_FAMILY_AMIGA},
{"DIWSTRT",     0xDFF08E,SOURCE_FAMILY_AMIGA},
{"DIWSTOP",     0xDFF090,SOURCE_FAMILY_AMIGA},
{"DDFSTRT",     0xDFF092,SOURCE_FAMILY_AMIGA},
{"DFFSTOP",     0xDFF094,SOURCE_FAMILY_AMIGA},
{"DMACON",      0xDFF096,SOURCE_FAMILY_AMIGA},
{"CLXCON",      0xDFF098,SOURCE_FAMILY_AMIGA},
{"INTENA",      0xDFF09A,SOURCE_FAMILY_AMIGA},
{"INTREQ",      0xDFF09C,SOURCE_FAMILY_AMIGA},
{"ADKCON",      0xDFF09E,SOURCE_FAMILY_AMIGA},
{"AUD0LCH",     0xDFF0A0,SOURCE_FAMILY_AMIGA},
{"AUD0LCL",     0xDFF0A2,SOURCE_FAMILY_AMIGA},
{"AUD0LEN",     0xDFF0A4,SOURCE_FAMILY_AMIGA},
{"AUD0PER",     0xDFF0A6,SOURCE_FAMILY_AMIGA},
{"AUD0VOL",     0xDFF0A8,SOURCE_FAMILY_AMIGA},
{"AUD0DAT",     0xDFF0AA,SOURCE_FAMILY_AMIGA},
{"AUD1LCH",     0xDFF0B0,SOURCE_FAMILY_AMIGA},
{"AUD1LCL",     0xDFF0B2,SOURCE_FAMILY_AMIGA},
{"AUD1LEN",     0xDFF0B4,SOURCE_FAMILY_AMIGA},
{"AUD1PER",     0xDFF0B6,SOURCE_FAMILY_AMIGA},
{"AUD1VOL",     0xDFF0B8,SOURCE_FAMILY_AMIGA},
{"AUD1DAT",     0xDFF0BA,SOURCE_FAMILY_AMIGA},
{"AUD2LCH",     0xDFF0C0,SOURCE_FAMILY_AMIGA},
{"AUD2LCL",     0xDFF0C2,SOURCE_FAMILY_AMIGA},
{"AUD2LEN",     0xDFF0C4,SOURCE_FAMILY_AMIGA},
{"AUD2PER",     0xDFF0C6,SOURCE_FAMILY_AMIGA},
{"AUD2VOL",     0xDFF0C8,SOURCE_FAMILY_AMIGA},
{"AUD2DAT",     0xDFF0CA,SOURCE_FAMILY_AMIGA},
{"AUD3LCH",     0xDFF0D0,SOURCE_FAMILY_AMIGA},
{"AUD3LCL",     0xDFF0D2,SOURCE_FAMILY_AMIGA},
{"AUD3LEN",     0xDFF0D4,SOURCE_FAMILY_AMIGA},
{"AUD3PER",     0xDFF0D6,SOURCE_FAMILY_AMIGA},
{"AUD3VOL",     0xDFF0D8,SOURCE_FAMILY_AMIGA},
{"AUD3DAT",     0xDFF0DA,SOURCE_FAMILY_AMIGA},
{"BPL1PTH",     0xDFF0E0,SOURCE_FAMILY_AMIGA},
{"BPL1PTL",     0xDFF0E2,SOURCE_FAMILY_AMIGA},
{"BPL2PTH",     0xDFF0E4,SOURCE_FAMILY_AMIGA},
{"BPL2PTL",     0xDFF0E6,SOURCE_FAMILY_AMIGA},
{"BPL3PTH",     0xDFF0E8,SOURCE_FAMILY_AMIGA},
{"BPL3PTL",     0xDFF0EA,SOURCE_FAMILY_AMIGA},
{"BPL4PTH",     0xDFF0EC,SOURCE_FAMILY_AMIGA},
{"BPL4PTL",     0xDFF0EE,SOURCE_FAMILY_AMIGA},
{"BPL5PTH",     0xDFF0F0,SOURCE_FAMILY_AMIGA},
{"BPL5PTL",     0xDFF0F2,SOURCE_FAMILY_AMIGA},
{"BPL6PTH",     0xDFF0F4,SOURCE_FAMILY_AMIGA},
{"BPL6PTL",     0xDFF0F6,SOURCE_FAMILY_AMIGA},
{"BPLCON0",     0xDFF100,SOURCE_FAMILY_AMIGA},
{"BPLCON1",     0xDFF102,SOURCE_FAMILY_AMIGA},
{"BPLCON2",     0xDFF104,SOURCE_FAMILY_AMIGA},
{"BPLCON3",     0xDFF106,SOURCE_FAMILY_AMIGA}, /* ECS */
{"BPL1MOD",     0xDFF108,SOURCE_FAMILY_AMIGA},
{"BPL2MOD",     0xDFF10A,SOURCE_FAMILY_AMIGA},
{"BPL1DAT",     0xDFF110,SOURCE_FAMILY_AMIGA},
{"BPL2DAT",     0xDFF112,SOURCE_FAMILY_AMIGA},
{"BPL3DAT",     0xDFF114,SOURCE_FAMILY_AMIGA},
{"BPL4DAT",     0xDFF116,SOURCE_FAMILY_AMIGA},
{"BPL5DAT",     0xDFF118,SOURCE_FAMILY_AMIGA},
{"BPL6DAT",     0xDFF11A,SOURCE_FAMILY_AMIGA},
{"SPR0PTH",     0xDFF120,SOURCE_FAMILY_AMIGA},
{"SPR0PTL",     0xDFF122,SOURCE_FAMILY_AMIGA},
{"SPR1PTH",     0xDFF124,SOURCE_FAMILY_AMIGA},
{"SPR1PTL",     0xDFF126,SOURCE_FAMILY_AMIGA},
{"SPR2PTH",     0xDFF128,SOURCE_FAMILY_AMIGA},
{"SPR2PTL",     0xDFF12A,SOURCE_FAMILY_AMIGA},
{"SPR3PTH",     0xDFF12C,SOURCE_FAMILY_AMIGA},
{"SPR3PTL",     0xDFF12E,SOURCE_FAMILY_AMIGA},
{"SPR4PTH",     0xDFF130,SOURCE_FAMILY_AMIGA},
{"SPR4PTL",     0xDFF132,SOURCE_FAMILY_AMIGA},
{"SPR5PTH",     0xDFF134,SOURCE_FAMILY_AMIGA},
{"SPR5PTL",     0xDFF136,SOURCE_FAMILY_AMIGA},
{"SPR6PTH",     0xDFF138,SOURCE_FAMILY_AMIGA},
{"SPR6PTL",     0xDFF13A,SOURCE_FAMILY_AMIGA},
{"SPR7PTH",     0xDFF13C,SOURCE_FAMILY_AMIGA},
{"SPR7PTL",     0xDFF13E,SOURCE_FAMILY_AMIGA},
{"SPR0POS",     0xDFF140,SOURCE_FAMILY_AMIGA},
{"SPR0CTL",     0xDFF142,SOURCE_FAMILY_AMIGA},
{"SPR0DATA",    0xDFF144,SOURCE_FAMILY_AMIGA},
{"SPR0DATB",    0xDFF146,SOURCE_FAMILY_AMIGA},
{"SPR1POS",     0xDFF148,SOURCE_FAMILY_AMIGA},
{"SPR1CTL",     0xDFF14A,SOURCE_FAMILY_AMIGA},
{"SPR1DATA",    0xDFF14C,SOURCE_FAMILY_AMIGA},
{"SPR1DATB",    0xDFF14E,SOURCE_FAMILY_AMIGA},
{"SPR2POS",     0xDFF150,SOURCE_FAMILY_AMIGA},
{"SPR2CTL",     0xDFF152,SOURCE_FAMILY_AMIGA},
{"SPR2DATA",    0xDFF154,SOURCE_FAMILY_AMIGA},
{"SPR2DATB",    0xDFF156,SOURCE_FAMILY_AMIGA},
{"SPR3POS",     0xDFF158,SOURCE_FAMILY_AMIGA},
{"SPR3CTL",     0xDFF15A,SOURCE_FAMILY_AMIGA},
{"SPR3DATA",    0xDFF15C,SOURCE_FAMILY_AMIGA},
{"SPR3DATB",    0xDFF15E,SOURCE_FAMILY_AMIGA},
{"SPR4POS",     0xDFF160,SOURCE_FAMILY_AMIGA},
{"SPR4CTL",     0xDFF162,SOURCE_FAMILY_AMIGA},
{"SPR4DATA",    0xDFF164,SOURCE_FAMILY_AMIGA},
{"SPR4DATB",    0xDFF166,SOURCE_FAMILY_AMIGA},
{"SPR5POS",     0xDFF168,SOURCE_FAMILY_AMIGA},
{"SPR5CTL",     0xDFF16A,SOURCE_FAMILY_AMIGA},
{"SPR5DATA",    0xDFF16C,SOURCE_FAMILY_AMIGA},
{"SPR5DATB",    0xDFF16E,SOURCE_FAMILY_AMIGA},
{"SPR6POS",     0xDFF170,SOURCE_FAMILY_AMIGA},
{"SPR6CTL",     0xDFF172,SOURCE_FAMILY_AMIGA},
{"SPR6DATA",    0xDFF174,SOURCE_FAMILY_AMIGA},
{"SPR6DATB",    0xDFF176,SOURCE_FAMILY_AMIGA},
{"SPR7POS",     0xDFF178,SOURCE_FAMILY_AMIGA},
{"SPR7CTL",     0xDFF17A,SOURCE_FAMILY_AMIGA},
{"SPR7DATA",    0xDFF17C,SOURCE_FAMILY_AMIGA},
{"SPR7DATB",    0xDFF17E,SOURCE_FAMILY_AMIGA},
{"COLOR00",     0xDFF180,SOURCE_FAMILY_AMIGA},
{"COLOR01",     0xDFF182,SOURCE_FAMILY_AMIGA},
{"COLOR02",     0xDFF184,SOURCE_FAMILY_AMIGA},
{"COLOR03",     0xDFF186,SOURCE_FAMILY_AMIGA},
{"COLOR04",     0xDFF188,SOURCE_FAMILY_AMIGA},
{"COLOR05",     0xDFF18A,SOURCE_FAMILY_AMIGA},
{"COLOR06",     0xDFF18C,SOURCE_FAMILY_AMIGA},
{"COLOR07",     0xDFF18E,SOURCE_FAMILY_AMIGA},
{"COLOR08",     0xDFF190,SOURCE_FAMILY_AMIGA},
{"COLOR09",     0xDFF192,SOURCE_FAMILY_AMIGA},
{"COLOR10",     0xDFF194,SOURCE_FAMILY_AMIGA},
{"COLOR11",     0xDFF196,SOURCE_FAMILY_AMIGA},
{"COLOR12",     0xDFF198,SOURCE_FAMILY_AMIGA},
{"COLOR13",     0xDFF19A,SOURCE_FAMILY_AMIGA},
{"COLOR14",     0xDFF19C,SOURCE_FAMILY_AMIGA},
{"COLOR15",     0xDFF19E,SOURCE_FAMILY_AMIGA},
{"COLOR16",     0xDFF1A0,SOURCE_FAMILY_AMIGA},
{"COLOR17",     0xDFF1A2,SOURCE_FAMILY_AMIGA},
{"COLOR18",     0xDFF1A4,SOURCE_FAMILY_AMIGA},
{"COLOR19",     0xDFF1A6,SOURCE_FAMILY_AMIGA},
{"COLOR20",     0xDFF1A8,SOURCE_FAMILY_AMIGA},
{"COLOR21",     0xDFF1AA,SOURCE_FAMILY_AMIGA},
{"COLOR22",     0xDFF1AC,SOURCE_FAMILY_AMIGA},
{"COLOR23",     0xDFF1AE,SOURCE_FAMILY_AMIGA},
{"COLOR24",     0xDFF1B0,SOURCE_FAMILY_AMIGA},
{"COLOR25",     0xDFF1B2,SOURCE_FAMILY_AMIGA},
{"COLOR26",     0xDFF1B4,SOURCE_FAMILY_AMIGA},
{"COLOR27",     0xDFF1B6,SOURCE_FAMILY_AMIGA},
{"COLOR28",     0xDFF1B8,SOURCE_FAMILY_AMIGA},
{"COLOR29",     0xDFF1BA,SOURCE_FAMILY_AMIGA},
{"COLOR30",     0xDFF1BC,SOURCE_FAMILY_AMIGA},
{"COLOR31",     0xDFF1BE,SOURCE_FAMILY_AMIGA},
{"HTOTAL",      0xDFF1C0,SOURCE_FAMILY_AMIGA}, /* Starting here, only ECS-Register */
{"HSSTOP",      0xDFF1C2,SOURCE_FAMILY_AMIGA},
{"HBSTRT",      0xDFF1C4,SOURCE_FAMILY_AMIGA},
{"HBSTOP",      0xDFF1C6,SOURCE_FAMILY_AMIGA},
{"VTOTAL",      0xDFF1C8,SOURCE_FAMILY_AMIGA},
{"VSSTOP",      0xDFF1CA,SOURCE_FAMILY_AMIGA},
{"VBSTRT",      0xDFF1CC,SOURCE_FAMILY_AMIGA},
{"VBSTOP",      0xDFF1CE,SOURCE_FAMILY_AMIGA},
{"SPRHSTRT",    0xDFF1D0,SOURCE_FAMILY_AMIGA},
{"SPRHSTOP",    0xDFF1D2,SOURCE_FAMILY_AMIGA},
{"BPLHSTRT",    0xDFF1D4,SOURCE_FAMILY_AMIGA},
{"BPLHSTOP",    0xDFF1D6,SOURCE_FAMILY_AMIGA},
{"HHPOSW",      0xDFF1D8,SOURCE_FAMILY_AMIGA},
{"HHPOSR",      0xDFF1DA,SOURCE_FAMILY_AMIGA},
{"BEAMCON0",    0xDFF1DC,SOURCE_FAMILY_AMIGA},
{"HSSTRT",      0xDFF1DE,SOURCE_FAMILY_AMIGA},
{"VSSTRT",      0xDFF1E0,SOURCE_FAMILY_AMIGA},
{"HCENTER",     0xDFF1E2,SOURCE_FAMILY_AMIGA},
{"DIWHIGH",     0xDFF1E4,SOURCE_FAMILY_AMIGA},
{"BPLHMOD",     0xDFF1E6,SOURCE_FAMILY_AMIGA},
{"SPRHPTH",     0xDFF1E8,SOURCE_FAMILY_AMIGA},
{"SPRHPTL",     0xDFF1EA,SOURCE_FAMILY_AMIGA},
{"BPLHPTH",     0xDFF1EC,SOURCE_FAMILY_AMIGA},
{"BPLHPTL",     0xDFF1EE,SOURCE_FAMILY_AMIGA},
{"FMODE",       0xDFF1FE,SOURCE_FAMILY_AMIGA}
};

/* Number of elements in the x_adrs array above */
const size_t x_adr_number = sizeof(x_adrs) / sizeof(x_adr_t);
