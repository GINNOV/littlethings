/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2026 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

#include "SDL_internal.h"

#if defined(SDL_TIMER_AMIGAOS4) || defined(SDL_TIMERS_DISABLED)

#include <proto/exec.h>
#include <proto/timer.h>
#include <exec/execbase.h>
#include <devices/timer.h>
#include <libraries/dos.h>

#include "SDL_os4timer_c.h"

#include "../../thread/amigaos4/SDL_systhread_c.h"

#include "../../main/amigaos4/SDL_os4debug.h"

static struct TimeVal OS4_StartTime;

static struct TimerIFace* SDL3_ITimer;

static ULONG OS4_TimerFrequency;

typedef struct OS4_ClockVal {
    union {
        struct EClockVal cv;
        Uint64 ticks;
    } u;
} OS4_ClockVal;

// Initialized with the thread sub system
void OS4_InitTimerSubSystem(void)
{
    dprintf("Called\n");

    struct ExecBase* sysbase = (struct ExecBase *)IExec->Data.LibBase;
    struct Library* timerBase = (struct Library *)IExec->FindName(&sysbase->DeviceList, "timer.device");

    SDL3_ITimer = (struct TimerIFace *)IExec->GetInterface(timerBase, "main", 1, NULL);

    dprintf("ITimer %p\n", SDL3_ITimer);

    if (!SDL3_ITimer) {
        dprintf("Failed to get ITimer\n");
        return;
    }

    SDL3_ITimer->GetSysTime(&OS4_StartTime);

    struct EClockVal cv;
    OS4_TimerFrequency = SDL3_ITimer->ReadEClock(&cv);

    dprintf("Timer frequency %lu Hz\n", OS4_TimerFrequency);
}

void OS4_QuitTimerSubSystem(void)
{
    dprintf("Called\n");

    IExec->DropInterface((struct Interface *)SDL3_ITimer);
    SDL3_ITimer = NULL;
}

static void
OS4_TimerCleanup(OS4_TimerInstance * timer)
{
    if (timer) {
        if (timer->request) {
            dprintf("Freeing timer request %p\n", timer->request);
            IExec->FreeSysObject(ASOT_IOREQUEST, timer->request);
            timer->request = NULL;
        }

        if (timer->port) {
            dprintf("Freeing timer port %p\n", timer->port);
            IExec->FreeSysObject(ASOT_PORT, timer->port);
            timer->port = NULL;
        }
    }
}

bool
OS4_TimerCreate(OS4_TimerInstance * timer)
{
    bool success = false;

    dprintf("Creating timer %p for task %p\n", timer, IExec->FindTask(NULL));

    if (!timer) {
        return false;
    }

    timer->port = IExec->AllocSysObject(ASOT_PORT, NULL);

    if (timer->port) {
        timer->request = IExec->AllocSysObjectTags(ASOT_IOREQUEST,
                                                   ASOIOR_ReplyPort, timer->port,
                                                   ASOIOR_Size, sizeof(struct TimeRequest),
                                                   TAG_DONE);

        if (timer->request) {
            if (!(IExec->OpenDevice("timer.device", UNIT_WAITUNTIL, (struct IORequest *)timer->request, 0))) {
                success = true;
            } else {
                dprintf("Failed to open timer.device\n");
            }
        } else {
            dprintf("Failed to allocate timer request\n");
        }
    } else {
        dprintf("Failed to allocate timer port\n");
    }

    timer->requestSent = false;

    if (!success) {
        OS4_TimerCleanup(timer);
    }

    return success;
}

void
OS4_TimerDestroy(OS4_TimerInstance * timer)
{
    dprintf("Destroying timer %p for task %p\n", timer, IExec->FindTask(NULL));

    if (timer && timer->request && timer->requestSent) {
        if (!IExec->CheckIO((struct IORequest *)timer->request)) {
            IExec->AbortIO((struct IORequest *)timer->request);
            IExec->WaitIO((struct IORequest *)timer->request);
        }
    }

    OS4_TimerCleanup(timer);
}

ULONG
OS4_TimerSetAlarmMicro(OS4_TimerInstance * timer, Uint64 alarmTicks)
{
    const ULONG seconds = alarmTicks / 1000000;
    struct TimeVal now;

    if (!SDL3_ITimer) {
        dprintf("Timer subsystem not initialized\n");
        return 0;
    }

    //dprintf("timer %p, request %p, port %p, ticks %u\n", timer, timer->request, timer->port, alarmTicks);

    if (timer && timer->request && timer->port) {
        timer->request->Request.io_Command = TR_ADDREQUEST;
        timer->request->Time.Seconds = seconds;
        timer->request->Time.Microseconds  = alarmTicks - (seconds * 1000000);

        SDL3_ITimer->GetSysTime(&now);
        SDL3_ITimer->AddTime(&timer->request->Time, &now);

        IExec->SetSignal(0, 1L << timer->port->mp_SigBit);
        IExec->SendIO((struct IORequest *)timer->request);
        timer->requestSent = true;

        // Return the alarm signal for Wait() use
        return 1L << timer->port->mp_SigBit;
    }

    return 0;
}

void
OS4_TimerClearAlarm(OS4_TimerInstance * timer)
{
    //dprintf("timer %p, request %p, request sent %d\n", timer, timer->request, timer->requestSent);

    if (timer && timer->request && timer->requestSent) {
        if (!IExec->CheckIO((struct IORequest *)timer->request)) {
            IExec->AbortIO((struct IORequest *)timer->request);
        }

        IExec->WaitIO((struct IORequest *)timer->request);
    }
}

bool
OS4_TimerDelayMicro(Uint64 ticks)
{
	OS4_TimerInstance* timer = OS4_ThreadGetTimer();

    if (timer) {
        const ULONG alarmSig = OS4_TimerSetAlarmMicro(timer, ticks);
        if (alarmSig) {
            const ULONG sigsReceived = IExec->Wait(alarmSig | SIGBREAKF_CTRL_C);

            OS4_TimerClearAlarm(timer);

        	return (sigsReceived & alarmSig) == alarmSig;
        }
    }

    return false;
}

void
OS4_TimerGetTime(struct TimeVal * timeval)
{
    if (!timeval) {
        dprintf("timeval NULL\n");
        return;
    }

    if (!SDL3_ITimer) {
        dprintf("Timer subsystem not initialized\n");
        timeval->Seconds = 0;
        timeval->Microseconds = 0;
        return;
    }

    SDL3_ITimer->GetSysTime(timeval);
    SDL3_ITimer->SubTime(timeval, &OS4_StartTime);
}

Uint64
OS4_TimerGetCounter(void)
{
    OS4_ClockVal value;

    if (!SDL3_ITimer) {
        dprintf("Timer subsystem not initialized\n");
        return 0;
    }

    SDL3_ITimer->ReadEClock(&value.u.cv);

    return value.u.ticks;
}

Uint64
OS4_TimerGetFrequency(void)
{
    return OS4_TimerFrequency;
}

#endif /* (SDL_TIMER_AMIGAOS4) || defined(SDL_TIMERS_DISABLED) */
