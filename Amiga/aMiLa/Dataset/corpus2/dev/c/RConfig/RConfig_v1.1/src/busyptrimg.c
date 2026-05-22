/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1991, 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: busyptrimg.c
 * Description: Busy (wait) pointer image
 * Comments: Locate the object file's data into chip mem; use fixhunk21;
 *   Data "lifted" from RKM: Libraries 3rd edition
 */

#include <exec/types.h>

UWORD WaitPointerImage[] = {
    0x0000, 0x0000,
    0x0400, 0x07C0,
    0x0000, 0x07C0,
    0x0100, 0x0380,
    0x0000, 0x07E0,
    0x07C0, 0x1FF8,
    0x1FF0, 0x3FEC,
    0x3FF8, 0x7FDE,
    0x3FF8, 0x7FBE,
    0x7FFC, 0xFF7F,
    0x7EFC, 0xFFFF,
    0x7FFC, 0xFFFF,
    0x3FF8, 0x7FFE,
    0x3FF8, 0x7FFE,
    0x1FF0, 0x3FFC,
    0x07C0, 0x1FF8,
    0x0000, 0x07E0,
    0x0000, 0x0000
};
