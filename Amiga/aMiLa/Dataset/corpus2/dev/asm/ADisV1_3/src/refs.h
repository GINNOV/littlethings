/*
 * Change history
 * $Log:	refs.h,v $
 * Revision 3.0  93/09/24  17:54:39  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:57:10  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:55:09  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.8  93/06/03  20:31:19  Martin_Apel
 * 
 * 
 */

/* $Id: refs.h,v 3.0 93/09/24 17:54:39 Martin_Apel Exp $ */

#define POOLSIZE 20000

/* must be even multiple of 2 bytes long */
struct ref_entry
  {
  struct ref_entry *next,
                   *prev,
                   *next_active,
                   *prev_active;
  ULONG offset;
  char *name;
  UWORD access;
  };
  
struct mem_pool
  {
  struct mem_pool *next;
  ULONG free;
  UWORD *next_free;
  };

/* These bits must not be used by the disassembler for data storage */
#define ACC_NEW 0x8000
#define TMP_INACTIVE 0x4000        /* This label is temporarily deactivated */
