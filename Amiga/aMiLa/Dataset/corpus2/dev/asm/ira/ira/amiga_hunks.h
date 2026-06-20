/*
 * amiga_hunks.h
 *
 *  Created on: 26 april 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : amiga_hunks.h
 *      Purpose  : Amiga executable file's Hunk and AllocMem flags definitions
 *      Copyright: (C) 1989-1999 Amiga, Inc.
 */

#ifndef AMIGA_HUNKS_H
#define AMIGA_HUNKS_H

/* hunk types */
#define HUNK_UNIT           0x03E7
#define HUNK_NAME           0x03E8
#define HUNK_CODE           0x03E9
#define HUNK_DATA           0x03EA
#define HUNK_BSS            0x03EB
#define HUNK_RELOC32        0x03EC
#define HUNK_ABSRELOC32     HUNK_RELOC32
#define HUNK_RELOC16        0x03ED
#define HUNK_RELRELOC16     HUNK_RELOC16
#define HUNK_RELOC8         0x03EE
#define HUNK_RELRELOC8      HUNK_RELOC8
#define HUNK_EXT            0x03EF
#define HUNK_SYMBOL         0x03F0
#define HUNK_DEBUG          0x03F1
#define HUNK_END            0x03F2
#define HUNK_HEADER         0x03F3

#define HUNK_OVERLAY        0x03F5
#define HUNK_BREAK          0x03F6

#define HUNK_DREL32         0x03F7
#define HUNK_DREL16         0x03F8
#define HUNK_DREL8          0x03F9

#define HUNK_LIB            0x03FA
#define HUNK_INDEX          0x03FB

/* Extended hunk types */
#define HUNK_PPC_CODE       0x04E9
#define HUNK_RELRELOC26     0x04EC

/*
 * Note: V37 LoadSeg uses 0x03F7 (HUNK_DREL32) by mistake.  This will continue
 * to be supported in future versions, since HUNK_DREL32 is illegal in load files
 * anyways.  Future versions will support both 0x03F7 and 0x03FC, though anything
 * that should be usable under V37 should use 0x03F7.
 */
#define HUNK_RELOC32SHORT   0x03FC

/* see ext_xxx below.  New for V39 (note that LoadSeg only handles RELRELOC32).*/
#define HUNK_RELRELOC32     0x03FD
#define HUNK_ABSRELOC16     0x03FE

/*
 * Any hunks that have the HUNKB_ADVISORY bit set will be ignored if they
 * aren't understood.  When ignored, they're treated like HUNK_DEBUG hunks.
 * NOTE: this handling of HUNKB_ADVISORY started as of V39 dos.library!  If
 * loading such executables is attempted under <V39 dos, it will fail with a
 * bad hunk type.
 */
#define HUNKB_ADVISORY     29
#define HUNKB_CHIP         30
#define HUNKB_FAST         31
#define HUNKF_ADVISORY     (1L<<29)
#define HUNKF_CHIP         (1L<<30)
#define HUNKF_FAST         (1L<<31)

/* hunk_ext sub-types */
#define EXT_SYMB          0         /* symbol table */
#define EXT_DEF           1         /* relocatable definition */
#define EXT_ABS           2         /* Absolute definition */
#define EXT_RES           3         /* no longer supported */
#define EXT_REF32       129         /* 32 bit absolute reference to symbol */
#define EXT_ABSREF32    EXT_REF32
#define EXT_COMMON      130         /* 32 bit absolute reference to COMMON block */
#define EXT_ABSCOMMON   EXT_COMMON
#define EXT_REF16       131         /* 16 bit PC-relative reference to symbol */
#define EXT_RELREF16    EXT_REF16
#define EXT_REF8        132         /*  8 bit PC-relative reference to symbol */
#define EXT_RELREF8     EXT_REF8
#define EXT_DEXT32      133         /* 32 bit data relative reference */
#define EXT_DEXT16      134         /* 16 bit data relative reference */
#define EXT_DEXT8       135         /*  8 bit data relative reference */

/* These are to support some of the '020 and up modes that are rarely used */
#define EXT_RELREF32    136         /* 32 bit PC-relative reference to symbol */
#define EXT_RELCOMMON   137         /* 32 bit PC-relative reference to COMMON block */

/* for completeness... All 680x0's support this */
#define EXT_ABSREF16    138         /* 16 bit absolute reference to symbol */

/* this only exists on '020's and above, in the (d8,An,Xn) address mode */
#define EXT_ABSREF8     139         /* 8 bit absolute reference to symbol */

/* Extended hunk_ext sub-types */
#define EXT_RELREF26    229         /* For PPC code */

/*----- Memory Requirement Types ---------------------------*/
/*----- See the AllocMem() documentation for details--------*/

#define MEMF_ANY        (0L)     /* Any type of memory will do */
#define MEMF_PUBLIC     (1L<<0)
#define MEMF_CHIP       (1L<<1)
#define MEMF_FAST       (1L<<2)
#define MEMF_LOCAL      (1L<<8)  /* Memory that does not go away at RESET */
#define MEMF_24BITDMA   (1L<<9)  /* DMAable memory within 24 bits of address */
#define MEMF_KICK       (1L<<10) /* Memory that can be used for KickTags */

#define MEMF_CLEAR      (1L<<16) /* AllocMem: NULL out area before return */
#define MEMF_LARGEST    (1L<<17) /* AvailMem: return the largest chunk size */
#define MEMF_REVERSE    (1L<<18) /* AllocMem: allocate from the top down */
#define MEMF_TOTAL      (1L<<19) /* AvailMem: return total size of memory */

#define MEMF_NO_EXPUNGE (1L<<31) /*AllocMem: Do not cause expunge on failure */

void ExamineHunks(ira_t *, int);
void ReadAmigaHunkObject(ira_t *);
void ReadAmigaHunkExecutable(ira_t *);
uint32_t ReadSymbol(FILE *, uint32_t *, uint8_t *, uint8_t *);

#endif /* AMIGA_HUNKS_H */
