/*
 * PdaLink -- Connect Palm with Amiga
 *
 * Copyright (C) 1998-2010 Richard "Shred" Körber
 *   http://pdalink.shredzone.org
 *
 * This library is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Header for debug functions.
 *
 * @author Harry "Piru" Sintonen
 */

#ifndef __DEBUG_H__
#define __DEBUG_H__

#define DB_LEVEL 1
//#define DEBUG

#ifdef DEBUG
   #define BreakPoint __emit(0x4afc)
   void dprintf(const char *, ...);
#  ifdef __GNUC__
#    define KPRINTF(l, x) do { if ((l) >= DB_LEVEL) \
     { dprintf("%s:%s/%lu: ", __FILE__, __FUNCTION__, __LINE__); dprintf x;} } while (0)
#  else
#    define KPRINTF(l, x) do { if ((l) >= DB_LEVEL) \
     { dprintf("%s/%lu: ", __FILE__, __LINE__); dprintf x;} } while (0)
#  endif /* __GNUC__ */
#  define DB(x) x
   void dumpmem(void *mem, unsigned long int len);
#else /* !DEBUG */

#define KPRINTF(l, x) ((void) 0)
#define DB(x)
#define BreakPoint

#endif /* DEBUG */

#endif /* __DEBUG_H__ */
