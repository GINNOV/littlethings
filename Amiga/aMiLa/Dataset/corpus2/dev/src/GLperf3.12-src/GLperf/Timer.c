/*
//   (C) COPYRIGHT International Business Machines Corp. 1993
//   All Rights Reserved
//   Licensed Materials - Property of IBM
//   US Government Users Restricted Rights - Use, duplication or
//   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//

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

#include "Timer.h"
#include "Global.h"
#include <stdlib.h>
#include <malloc.h>

TimerPtr new_Timer()
{
    TimerPtr this = (TimerPtr)malloc(sizeof(Timer));
    CheckMalloc(this);
    this->elapsed = 0.0;
    return this;
}

void delete_Timer(TimerPtr this)
{
    free(this);
}

void Timer__Start(TimerPtr this)
{
#if defined( WIN32)
    this->start = GetTickCount();
#elif defined( __OS2__)
    DosQuerySysInfo( QSV_MS_COUNT, QSV_MS_COUNT, &this->start, sizeof( this->start));
#else
    this->start = times(&this->buf);
#endif
}

void Timer__Stop(TimerPtr this)
{
#if defined( WIN32)
    this->stop = GetTickCount();
    this->elapsed = ((float)(this->stop) - (float)(this->start)) / 1000.0F;
#elif defined( __OS2__)
    DosQuerySysInfo( QSV_MS_COUNT, QSV_MS_COUNT, &this->stop, sizeof( this->stop));
    this->elapsed = (( float)( this->stop - this->start)) / 1000.0F;
#else
    this->stop = times(&this->buf);
    this->elapsed = (float)(this->stop - this->start)/(float)CLK_TCK;
#endif
}

float Timer__Read(TimerPtr this)
{
    return this->elapsed;
}
