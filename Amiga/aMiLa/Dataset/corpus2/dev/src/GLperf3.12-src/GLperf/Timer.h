/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#ifndef _Timer_h
#define _Timer_h

#if defined(WIN32)

#include <windows.h>
#include <time.h>
typedef struct _Timer {
    long buf;
    DWORD start, stop;
    float elapsed;
} Timer, *TimerPtr;

#elif defined(__OS2__)

#define INCL_DOSMISC
#include <os2.h>
#include <time.h>
typedef struct _Timer {
    long buf;
    ULONG start, stop;
    float elapsed;
} Timer, *TimerPtr;

#else

#include <time.h>      /* for CLK_TCK */
#include <sys/times.h>
typedef struct _Timer {
    struct tms buf;
    time_t start, stop;
    float elapsed;
} Timer, *TimerPtr;

#endif

TimerPtr new_Timer();
void delete_Timer(TimerPtr);
void Timer__Start(TimerPtr);
void Timer__Stop(TimerPtr);
float Timer__Read(TimerPtr);

#endif
