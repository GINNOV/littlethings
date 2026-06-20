/*
 * atari.h
 *
 *  Created on: 2 may 2015
 *      Author   : Nicolas Bastien, Frank Wille
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : atari.h
 *      Purpose  : Atari's executable file definitions
 *      Copyright: (C)2015-2016,2024 Nicolas Bastien, Frank Wille
 */

#ifndef ATARI_H_
#define ATARI_H_

/* Atari's magic */
#define ATARI_MAGIC  0x601A

typedef struct
{
   uint8_t ph_branch[2];     /* Branch to start of the program  */
                             /* (must be 0x601a!)               */

   uint8_t ph_tlen[4];       /* Length of the TEXT segment      */
   uint8_t ph_dlen[4];       /* Length of the DATA segment      */
   uint8_t ph_blen[4];       /* Length of the BSS segment       */
   uint8_t ph_slen[4];       /* Length of the symbol table      */
   uint8_t ph_res1[4];       /* Reserved, should be 0;          */
                             /* Required by PureC               */
   uint8_t ph_prgflags[4];   /* Program flags                   */
   uint8_t ph_absflag[2];    /* 0 = Relocation info present     */
} atari_header_t;

#define DRI_NAMELEN 8
#define XVALUE 0x87654321       /* SozobonX symbol value for extended name */
typedef struct
{
   char name[DRI_NAMELEN];
   uint8_t type[2];
   uint8_t value[4];
} dri_symbol_t;

/* symbol types */
#define STYP_UNDEF 0
#define STYP_BSS 0x0100
#define STYP_TEXT 0x0200
#define STYP_DATA 0x0400
#define STYP_EXTERNAL 0x0800
#define STYP_REGISTER 0x1000
#define STYP_GLOBAL 0x2000
#define STYP_EQUATED 0x4000
#define STYP_DEFINED 0x8000
#define STYP_LONGNAME 0x0048
#define STYP_TFILE 0x0280
#define STYP_TFARC 0x02c0
#define STYP_XFLAGS 0x4200


void ReadAtariExecutable(ira_t *);

#endif /* ATARI_H_ */
