#include "amiga.h"
#include "timers.h"
#include "signals.h"
#include "processes.h"

void __stdargs _CXFERR(int);

/* When one of these occur, call handle_signals */
static ULONG signalsigs;

void (*_sig_handlers[NSIG]) (int);

long _sig_mask, _sig_pending;

/* These can be generated only by bsdsocket.library */
long _sigio_sig = -1, _sigurg_sig = -1;

extern void _fail(char *format,...);
extern void _message(char *format,...);
extern int (*_break_func)(void);


/* Alarm signal */
/* ------------ */

static struct timeinfo *alarm_timer;

static int check_alarm(void)
{
    return alarm_timer && _timer_expired(alarm_timer);
}

/*
 *  Schedule a SIGALRM after secs seconds
 */
void alarm(int secs)
{
    _timer_start(alarm_timer, secs, 0);
}

static void init_alarm(void)
{
    if (!(alarm_timer = _alloc_timer()))
	_fail("Failed to create timer");
    signalsigs |= _timer_sig(alarm_timer);
}

static void cleanup_alarm(void)
{
    _free_timer(alarm_timer);
}

/* SIGINT definition */
/* ----------------- */

static void init_sigint(void)
{
    signalsigs |= SIGBREAKF_CTRL_C;
}

/* static void cleanup_sigint(void) { } */

static int check_sigint(ULONG sigs)
{
    return (sigs & SIGBREAKF_CTRL_C) != 0;
}

/* SIGQUIT definition */
/* ------------------ */

static void init_sigquit(void)
{
    signalsigs |= SIGBREAKF_CTRL_D;
}

/* static void cleanup_sigquit(void) { } */

static int check_sigquit(ULONG sigs)
{
    return (sigs & SIGBREAKF_CTRL_D) != 0;
}

/* SIGCHLD definition */
/* ------------------ */

static void init_children(void)
{
    _init_processes();
    signalsigs |= 1L << _children_exit->mp_SigBit;
}

static void cleanup_children(void)
{
    _cleanup_processes();
}

static int check_children(void)
{
    struct exit_message *msg;
    int change = FALSE;

    while (msg = (struct exit_message *) GetMsg(_children_exit)) {
	struct process *p;

	if ((p = _find_pid(msg->pid)) && p->status == alive) {
	    change = TRUE;
	    p->status = exited;
	    p->rc = msg->rc;
	}
	FreeMem(msg, sizeof(struct exit_message));
    }
    return change;
}

/* SIGIO definition */
/* ---------------- */

static void init_sigio(void)
{
    if (_sigio_sig >= 0)
	signalsigs |= sigmask(_sigio_sig);
}

/* static void cleanup_sigio(void) { } */

static int check_sigio(ULONG sigs)
{
    return _sigio_sig < 0 ? 0 : (sigs & sigmask(_sigio_sig)) != 0;
}

/* SIGURG definition */
/* ----------------- */

static void init_sigurg(void)
{
    if (_sigurg_sig >= 0)
	signalsigs |= sigmask(_sigurg_sig);
}

/* static void cleanup_sigurg(void) { } */

static int check_sigurg(ULONG sigs)
{
    return _sigurg_sig < 0 ? 0 : (sigs & sigmask(_sigurg_sig)) != 0;
}

/* Signal dispatching */
/* ------------------ */

/*
 *  Do the action associated with signal sig if it isn't masked
 *  Mask it for the duration of the signal exec
 */
void _sig_dispatch(int sig)
{
    void (*fn) (int);
    int smask = sigmask(sig);

    if (sig == SIGKILL)
	__exit(0);

    if (_sig_mask & smask) {
	_sig_pending |= smask;
    } else {
	do {
	    _sig_pending &= ~smask;
	    if (sig >= 0 && sig < NSIG) {
		fn = _sig_handlers[sig];
		/*
		 * Note: SIGINT is special because onbreak() may
		 * override the SIG_DFL and SIG_IGN settings.
		 */
		if (sig == SIGINT) {
		    _sig_mask |= smask;
		    if (_break_func()) { 
			_message("user interrupt");
			__exit(0);
		    }
		    _sig_mask &= ~smask;
		} else if (fn == SIG_DFL) {
		    switch (sig) {
			case SIGURG:
			case SIGCHLD:
			case SIGIO:
			case SIGWINCH:
			    break;
			case SIGQUIT:
			    _message("user interrupt");
			default:
			    __exit(0);
		    }
		} else if (fn != SIG_IGN) {
		    _sig_mask |= smask;
		    _sig_handlers[sig] (sig);
		    _sig_mask &= ~smask;
		}
	    }
	}
	while (_sig_pending & smask);	/* Signal may have been generated during
					   the signal handling function. */
    }
}

ULONG _check_signals(ULONG extra_sigs)
{
    return SetSignal(0, signalsigs | extra_sigs);
}

ULONG _wait_signals(ULONG extra_sigs)
{
    return Wait(signalsigs | extra_sigs);
}

int _handle_signals(ULONG sigs)
{
    int signaled = 0;

    if (check_alarm()) {
	signaled = 1;
	_sig_dispatch(SIGALRM);
    }
    if (check_sigint(sigs)) {
	signaled = 1;
	_sig_dispatch(SIGINT);
    }
    if (check_sigquit(sigs)) {
	signaled = 1;
	_sig_dispatch(SIGQUIT);
    }
    if (check_sigio(sigs)) {
	signaled = 1;
	_sig_dispatch(SIGIO);
    }
    if (check_sigurg(sigs)) {
	signaled = 1;
	_sig_dispatch(SIGURG);
    }
    if (check_children()) {
	signaled = 1;
	_sig_dispatch(SIGCHLD);
    }
    return signaled;
}

/*
 *  Patch into SAS signal stuff so as to replace it
 */
void __stdargs _CXFERR(int code)
{
    extern int _FPERR;

    _FPERR = code;
    _sig_dispatch(SIGFPE);
}

/*
 *  Checks all signals
 */
void __regargs __chkabort(void)
{
    _handle_signals(_check_signals(0));
}

void __stdargs Chk_Abort(void)
{
    __chkabort();
}

/* Initialisation */
/* -------------- */

void _init_signals(void)
{
    int i;

    for (i = 0; i < NSIG; i++)
	_sig_handlers[i] = SIG_DFL;
    _sig_mask = _sig_pending = 0;
    signalsigs = 0;

    init_sigint();
    init_sigquit();
    init_sigio();
    init_sigurg();
    init_alarm();
    init_children();
}

void _cleanup_signals(void)
{
    cleanup_alarm();
    /* cleanup_sigquit(); */
    /* cleanup_sigint(); */
    /* cleanup_sigio(); */
    /* cleanup_sigurg(); */
    cleanup_children();
}
