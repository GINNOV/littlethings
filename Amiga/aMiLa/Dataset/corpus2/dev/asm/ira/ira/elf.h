/*
 * elf.h
 *
 *  Created on: 2 may 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : elf.h
 *      Purpose  : ELF executable file definitions (note : only defines elf32 because 680x0 is only 32 bits wide)
 *      Copyright: (C)2015-2016 Nicolas Bastien
 */

#ifndef ELF_H_
#define ELF_H_

/* ELF's magic */
#define ELF_MAGIC    0x7F454C46  /* note: 0x454C46 in ascii is "ELF" */

#define EI_NIDENT    16

typedef struct
{
   unsigned char e_ident[EI_NIDENT];
   uint16_t      e_type;
   uint16_t      e_machine;
   uint32_t      e_version;
   uint32_t      e_entry;
   uint32_t      e_phoff;
   uint32_t      e_shoff;
   uint32_t      e_flags;
   uint16_t      e_ehsize;
   uint16_t      e_phentsize;
   uint16_t      e_phnum;
   uint16_t      e_shentsize;
   uint16_t      e_shnum;
   uint16_t      e_shtrndx;
} elf32_header_t;

/* e_ident[] indexes */
#define EI_MAG0    0
#define EI_MAG1    1
#define EI_MAG2    2
#define EI_MAG3    3
#define EI_CLASS   4
#define EI_DATA    5
#define EI_VERSION 6
#define EI_OSABI   7
#define EI_PAD     8

/* e_type values */
#define ET_NONE   0
#define ET_REL    1
#define ET_EXEC   2
#define ET_DYN    3
#define ET_CORE   4
#define ET_LOPROC 0xff00
#define ET_HIPROC 0xffff

/* e_machine values (note : only M68K cares in IRA) */
#define EM_68K     4

void ReadElfExecutable(ira_t *);

#endif /* ELF_H_ */
