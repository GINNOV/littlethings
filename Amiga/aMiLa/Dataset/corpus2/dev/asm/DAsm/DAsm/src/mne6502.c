
/*
 *  MNE6502.C
 *
 *  (c)Copyright 1988, Matthew Dillon, All Rights Reserved.
 *
 */

#include "asm.h"

#define ASTD	AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX|\
		AF_WORDADRY|AF_INDBYTEX|AF_INDBYTEY

MNE Mne6502[] = {
    NULL, v_mnemonic, "adc", 0, AF_IMM8|ASTD,
    { 0x69, 0x65, 0x75, 0x6D, 0x7D, 0x79, 0x61, 0x71 },
    NULL, v_mnemonic, "and", 0, AF_IMM8|ASTD,
    { 0x29, 0x25, 0x35, 0x2D, 0x3D, 0x39, 0x21, 0x31 },
    NULL, v_mnemonic, "asl", 0, AF_IMP|AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0x0A, 0x06, 0x16, 0x0E, 0x1E },
    NULL, v_mnemonic, "bcc", 0, AF_REL, { 0x90 },
    NULL, v_mnemonic, "bcs", 0, AF_REL, { 0xB0 },
    NULL, v_mnemonic, "beq", 0, AF_REL, { 0xF0 },
    NULL, v_mnemonic, "bit", 0, AF_BYTEADR|AF_WORDADR,
    { 0x24, 0x2C },
    NULL, v_mnemonic, "bmi", 0, AF_REL, { 0x30 },
    NULL, v_mnemonic, "bne", 0, AF_REL, { 0xD0 },
    NULL, v_mnemonic, "bpl", 0, AF_REL, { 0x10 },
    NULL, v_mnemonic, "brk", 0, AF_IMP, { 0x00 },
    NULL, v_mnemonic, "bvc", 0, AF_REL, { 0x50 },
    NULL, v_mnemonic, "bvs", 0, AF_REL, { 0x70 },
    NULL, v_mnemonic, "clc", 0, AF_IMP, { 0x18 },
    NULL, v_mnemonic, "cld", 0, AF_IMP, { 0xD8 },
    NULL, v_mnemonic, "cli", 0, AF_IMP, { 0x58 },
    NULL, v_mnemonic, "clv", 0, AF_IMP, { 0xB8 },
    NULL, v_mnemonic, "cmp", 0, AF_IMM8|ASTD,
    { 0xC9, 0xC5, 0xD5, 0xCD, 0xDD, 0xD9, 0xC1, 0xD1 },
    NULL, v_mnemonic, "cpx", 0, AF_IMM8|AF_BYTEADR|AF_WORDADR,
    { 0xE0, 0xE4, 0xEC },
    NULL, v_mnemonic, "cpy", 0, AF_IMM8|AF_BYTEADR|AF_WORDADR,
    { 0xC0, 0xC4, 0xCC },
    NULL, v_mnemonic, "dec", 0, AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0xC6, 0xD6, 0xCE, 0xDE },
    NULL, v_mnemonic, "dex", 0, AF_IMP, { 0xCA },
    NULL, v_mnemonic, "dey", 0, AF_IMP, { 0x88 },
    NULL, v_mnemonic, "eor", 0, AF_IMM8|ASTD,
    { 0x49, 0x45, 0x55, 0x4D, 0x5D, 0x59, 0x41,0x51 },
    NULL, v_mnemonic, "inc", 0, AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0xE6, 0xF6, 0xEE, 0xFE },
    NULL, v_mnemonic, "inx", 0, AF_IMP, { 0xE8 },
    NULL, v_mnemonic, "iny", 0, AF_IMP, { 0xC8 },
    NULL, v_mnemonic, "jmp", 0, AF_WORDADR|AF_INDWORD,
    { 0x4C, 0x6C },
    NULL, v_mnemonic, "jsr", 0, AF_WORDADR, { 0x20 },
    NULL, v_mnemonic, "lda", 0, AF_IMM8|ASTD,
    { 0xA9, 0xA5, 0xB5, 0xAD, 0xBD, 0xB9, 0xA1, 0xB1 },
    NULL, v_mnemonic, "ldx", 0, AF_IMM8|AF_BYTEADR|AF_BYTEADRY|AF_WORDADR|AF_WORDADRY,
    { 0xA2, 0xA6, 0xB6, 0xAE, 0xBE },
    NULL, v_mnemonic, "ldy", 0, AF_IMM8|AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0xA0, 0xA4, 0xB4, 0xAC, 0xBC },
    NULL, v_mnemonic, "lsr", 0, AF_IMP|AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0x4A, 0x46, 0x56, 0x4E, 0x5E },
    NULL, v_mnemonic, "nop", 0, AF_IMP, { 0xEA },
    NULL, v_mnemonic, "ora", 0, AF_IMM8|ASTD,
    { 0x09, 0x05, 0x15, 0x0D, 0x1D, 0x19, 0x01, 0x11 },
    NULL, v_mnemonic, "pha", 0, AF_IMP, { 0x48 },
    NULL, v_mnemonic, "php", 0, AF_IMP, { 0x08 },
    NULL, v_mnemonic, "pla", 0, AF_IMP, { 0x68 },
    NULL, v_mnemonic, "plp", 0, AF_IMP, { 0x28 },
    NULL, v_mnemonic, "rol", 0, AF_IMP|AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0x2A, 0x26, 0x36, 0x2E, 0x3E },
    NULL, v_mnemonic, "ror", 0, AF_IMP|AF_BYTEADR|AF_BYTEADRX|AF_WORDADR|AF_WORDADRX,
    { 0x6A, 0x66, 0x76, 0x6E, 0x7E },
    NULL, v_mnemonic, "rti", 0, AF_IMP, { 0x40 },
    NULL, v_mnemonic, "rts", 0, AF_IMP, { 0x60 },
    NULL, v_mnemonic, "sbc", 0, AF_IMM8|ASTD,
    { 0xE9, 0xE5, 0xF5, 0xED, 0xFD, 0xF9, 0xE1, 0xF1 },
    NULL, v_mnemonic, "sec", 0, AF_IMP, { 0x38 },
    NULL, v_mnemonic, "sed", 0, AF_IMP, { 0xF8 },
    NULL, v_mnemonic, "sei", 0, AF_IMP, { 0x78 },
    NULL, v_mnemonic, "sta", 0, ASTD,
    { 0x85, 0x95, 0x8D, 0x9D, 0x99, 0x81, 0x91 },
    NULL, v_mnemonic, "stx", 0, AF_BYTEADR|AF_BYTEADRY|AF_WORDADR,
    { 0x86, 0x96, 0x8E },
    NULL, v_mnemonic, "sty", 0, AF_BYTEADR|AF_BYTEADRX|AF_WORDADR,
    { 0x84, 0x94, 0x8C },
    NULL, v_mnemonic, "tax", 0, AF_IMP, { 0xAA },
    NULL, v_mnemonic, "tay", 0, AF_IMP, { 0xA8 },
    NULL, v_mnemonic, "tsx", 0, AF_IMP, { 0xBA },
    NULL, v_mnemonic, "txa", 0, AF_IMP, { 0x8A },
    NULL, v_mnemonic, "txs", 0, AF_IMP, { 0x9A },
    NULL, v_mnemonic, "tya", 0, AF_IMP, { 0x98 },
    NULL
};



