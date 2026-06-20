/*
 *  sysdeps.h - System dependent definitions for MorphOS
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef SYSDEPS_H
#define SYSDEPS_H

#include <exec/types.h>
#include <devices/timer.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#undef AMIGA

#include "user_strings_morphos.h"

#ifndef REAL_ADDRESSING
#define REAL_ADDRESSING 0
#endif
#define DIRECT_ADDRESSING 1

/* Using 68k emulator */
#define EMULATED_68K 1

/* The m68k emulator uses a prefetch buffer ? */
#define USE_PREFETCH_BUFFER 0

/* Mac ROM is write protected when banked memory is used */
#if REAL_ADDRESSING || DIRECT_ADDRESSING
# define ROM_IS_WRITE_PROTECTED 0
# define USE_SCRATCHMEM_SUBTERFUGE 1
#else
# define ROM_IS_WRITE_PROTECTED 1
#endif

/* Direct Addressing requires Video on SEGV signals */
#if DIRECT_ADDRESSING && !ENABLE_VOSF
# undef  ENABLE_VOSF
# define ENABLE_VOSF 1
#endif

/* ExtFS is supported */
#define SUPPORTS_EXTFS 1

/* Data types */
typedef unsigned char uint8;
typedef signed char int8;
typedef UWORD uint16;
typedef WORD int16;
typedef ULONG uint32;
typedef LONG int32;
typedef UQUAD uint64;
typedef QUAD int64;
//#define VAL64(a) (a ## l)
//#define UVAL64(a) (a ## ul)
#define VAL64(a) (a ## ll)
#define UVAL64(a) (a ## ull)

typedef uint32 uintptr;
typedef int32 intptr;

typedef UQUAD loff_t;

// Time data type for Time Manager emulation
typedef struct timeval tm_time_t;

// Offset Mac->MorphOS time in seconds
#define TIME_OFFSET 0x8b31ef80

/* UAE CPU data types */
#define uae_s8 int8
#define uae_u8 uint8
#define uae_s16 int16
#define uae_u16 uint16
#define uae_s32 int32
#define uae_u32 uint32
#define uae_s64 int64
#define uae_u64 uint64
typedef uae_u32 uaecptr;

/* Alignment restrictions */
#define CPU_CAN_ACCESS_UNALIGNED

/* Big-endian CPUs which can do unaligned accesses */
static inline uae_u32 do_get_mem_long(uae_u32 *a) {return *a;}
static inline uae_u32 do_get_mem_word(uae_u16 *a) {return *a;}
static inline void do_put_mem_long(uae_u32 *a, uae_u32 v) {*a = v;}
static inline void do_put_mem_word(uae_u16 *a, uae_u32 v) {*a = v;}

#define do_get_mem_byte(a) ((uae_u32)*((uae_u8 *)(a)))
#define do_put_mem_byte(a, v) (*(uae_u8 *)(a) = (v))

#define call_mem_get_func(func, addr) ((*func)(addr))
#define call_mem_put_func(func, addr, v) ((*func)(addr, v))
#define __inline__ inline
#define CPU_EMU_SIZE 0
#undef NO_INLINE_MEMORY_ACCESS
#undef MD_HAVE_MEM_1_FUNCS
#define ENUMDECL typedef enum
#define ENUMNAME(name) name
#define write_log printf
#undef USE_MAPPED_MEMORY
#undef CAN_MAP_MEMORY

#define FPU_UAE
#define SIZEOF_SHORT			2
#define SIZEOF_INT			4
#define SIZEOF_LONG			4
#define SIZEOF_LONG_LONG	8
#define SIZEOF_VOID_P		4
#define SIZEOF_FLOAT			4
#define SIZEOF_DOUBLE		8

#define ASM_SYM_FOR_FUNC(a)

#ifndef REGPARAM
# define REGPARAM
#endif
#define REGPARAM2

#if defined(__powerpc__) || defined(__ppc__)
#define HAVE_TEST_AND_SET 1
static inline int testandset(volatile int *p)
{
	int ret;
	__asm__ __volatile__("0:    lwarx	%0,0,%1\n"
						 "      xor.	%0,%3,%0\n"
						 "      bne		1f\n"
						 "      stwcx.	%2,0,%1\n"
						 "      bne-	0b\n"
						 "1:    "
						 : "=&r" (ret)
						 : "r" (p), "r" (1), "r" (0)
						 : "cr0", "memory");
	return ret;
}
#endif

#endif
