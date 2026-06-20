
#include "amiga.h"
#include "signals.h"
#include "fifofd.h"
#include "timers.h"
#include "amigados.h"
#include <exec/execbase.h>
#include <dos/var.h>
#include <workbench/startup.h>
#include <proto/timer.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/time.h>
#include <pwd.h>
#include <ios1.h>

struct Process *_us;
struct timeinfo *_odd_timer;
ULONG _odd_sig;
long _startup_time;
long _stack_size;
struct Library *TimerBase;

static char *empty_env = 0;     /* A default empty environment */
char **environ;                 /* Unix style environment variable list */
char *_system_name;

extern struct ExecBase *SysBase;
extern struct passwd _amiga_user;
extern struct UFB *__ufbs;
int main(int argc, char **argv, char **envp);
extern void _fail(char *format,...);

static void nomem(void)
{
    _fail("No memory");
}

static void *_xmalloc(unsigned n)
{
    void *p = malloc(n);

    if (!p)
	nomem();

    return p;
}

static void *_xrealloc(void *p, unsigned n)
{
    void *p2 = realloc(p, n);

    if (!p2)
	nomem();

    return p2;
}

static char *safe_copystr(char *str)
{
    char *new;

    if (!str)
	str = "";
    new = malloc(strlen(str) + 1);
    if (!new)
	return 0;
    return strcpy(new, str);
}

void make_environ(void)
/* Effect: Builds a UNIX style environ variable from the AmigaDOS environment.
 */
{
    int env_count = 0;
    long env_len = 0;
    struct LocalVar *scan_env;
    char **new_environ, *env_text;

    for (scan_env = (struct LocalVar *) _us->pr_LocalVars.mlh_Head;
	 scan_env->lv_Node.ln_Succ;
	 scan_env = (struct LocalVar *) scan_env->lv_Node.ln_Succ) {

	if (scan_env->lv_Node.ln_Type == LV_VAR &&
	    !(scan_env->lv_Flags & (GVF_GLOBAL_ONLY | GVF_BINARY_VAR))) {
	    /* We only handle local text variables */
	    env_count++;
	    env_len += 2 + strlen(scan_env->lv_Node.ln_Name) + scan_env->lv_Len;
	}
    }
    new_environ = environ = (char **)_xmalloc(sizeof(char *) * (1 + env_count) +
					       env_len);
    env_text = (char *) (environ + (1 + env_count));
    if (!environ)
	environ = &empty_env;
    else {
	for (scan_env = (struct LocalVar *) _us->pr_LocalVars.mlh_Head;
	     scan_env->lv_Node.ln_Succ;
	     scan_env = (struct LocalVar *) scan_env->lv_Node.ln_Succ) {

	    if (scan_env->lv_Node.ln_Type == LV_VAR &&
	    !(scan_env->lv_Flags & (GVF_GLOBAL_ONLY | GVF_BINARY_VAR))) {
		/* We only handle local text variables */
		char *env_name = scan_env->lv_Node.ln_Name;
		int env_len = scan_env->lv_Len;

		*new_environ++ = env_text;
		while (*env_name)
		    *env_text++ = *env_name++;
		*env_text++ = '=';
		env_name = scan_env->lv_Value;
		while (env_len--)
		    *env_text++ = *env_name++;
		*env_text++ = '\0';
	    }
	}
	*new_environ = 0;
    }
}

/*  _main routine.
 *  Hides the differences between wb & cli.
 *  Provides a unix-like environment (including coomand-line parsing &
 *  wildcard expansion)
 */

#define DEFPATLEN 256
#define NAMELEN 1024

struct args {
    int size;
    int argc;
    char **argv;
};

static void make_argv(struct args *args, int argc)
{
    args->size = argc;
    args->argc = 0;
    args->argv = _xmalloc(sizeof(char *) * argc);
}

static int safe_add_arg(struct args *args, char *argument, int copy)
{
    char *arg_copy;

    if (copy)
	arg_copy = safe_copystr(argument);
    else
	arg_copy = argument;

    if (!arg_copy)
	return 0;

    if (args->argc >= args->size) {
	/* Make argv bigger */
	if (args->size * 2 < args->size + 16)
	    args->size += 16;
	else
	    args->size *= 2;

	args->argv = realloc(args->argv, sizeof(char *) * args->size);

	if (!args->argv)
	    return 0;
    }
    args->argv[args->argc++] = arg_copy;
    return 1;
}

static void add_arg(struct args *args, char *argument, int copy)
{
    if (!safe_add_arg(args, argument, copy))
	nomem();
}

static void concat_args(struct args *args, struct args *add)
{
    if (args->argc + add->argc > args->size) {
	args->size = (args->argc + add->argc) * 2;
	args->argv = _xrealloc(args->argv, sizeof(char *) * args->size);
    }
    memcpy(args->argv + args->argc, add->argv, add->argc * sizeof(char *));
    args->argc += add->argc;
    free(add->argv);
}

typedef enum {
    quote_none, quote_single, quote_double
} quote_type;

typedef enum {
    extract_normal, extract_test, extract_pattern
} extract_type;

static void extract(char *buf, char *start, char *end,
		    quote_type type, extract_type extract)
{
    char *res = buf;

    switch (type) {
	case quote_single:
	    if (extract != extract_test) {
		buf[end - start] = '\0';
		memcpy(buf, start, end - start);
	    } else
		strcpy(buf, "a");      /* Things in quotes are never patterns */
	    break;

	case quote_none:
	    while (start < end) {
		if (start[0] == '\\' && start[1]) {
		    start += 2;
		    /* Wildcard are escaped */
		    if (extract == extract_test) {
			*res++ = 'a';
		    } else if (extract == extract_pattern) {
			switch (start[-1]) {
			    case '?':
			    case '#':
			    case '(':
			    case ')':
			    case '|':
			    case '[':
			    case ']':
			    case '~':
			    case '%':
			    case '*':
			    case '\'':
				*res++ = '\'';
			    default:
				*res++ = start[-1];
				break;
			}
		    } else {
			*res++ = start[-1];
		    }
		} else {
		    *res++ = *start++;
		}
	    }
	    *res = '\0';
	    break;

	case quote_double:
	    while (start < end) {
		if (start[0] == '*' && start[1]) {
		    start += 2;
		    switch (start[-1]) {
			case 'n':
			    *res++ = '\n';
			    break;
			case 'e':
			    *res++ = '\x1b';
			    break;
			default:
			    *res++ = start[-1];
			    break;
		    }
		} else
		    *res++ = *start++;
	    }
	    *res = '\0';
	    break;
    }
}

void __stdargs __main(char *line)
/*  Effect: Call unix_main with wildcards in argc & argv expanded (like unix).
 *  Also, do some early amiga initialisation for emacs.
 */
{
    int ret;
    struct args args, wildargs;
    char *pattern, *arg_start, *arg_end, *arg;
    quote_type arg_quoted;
    long patlen = DEFPATLEN;
    struct AnchorPath *anchor;
    struct timeval now;

    if (SysBase->LibNode.lib_Version < 37)
	_XCEXIT(20);

    stdin->_file = 0;
    stdin->_flag = _IOREAD;
    stdout->_file = 1;
    stdout->_flag = _IOWRT | _IOLBF;
    stderr->_file = 2;
    stderr->_flag = _IOWRT | _IONBF;

    _us = (struct Process *) FindTask(0);
    _odd_timer = _alloc_timer();
    if (!_odd_timer)
	_fail("Failed to create timer");
    _odd_sig = _timer_sig(_odd_timer);
    TimerBase = (struct Library *) _odd_timer->io->tr_node.io_Device;
    GetSysTime(&now);
    _startup_time = now.tv_secs;

    /* These use _startup_time, so must be here */
    _init_fifo();
    _init_signals();

    if (_us->pr_CLI)
	_stack_size = ((struct CommandLineInterface *) BADDR(_us->pr_CLI))->cli_DefaultStack << 2;
    else
	_stack_size = _us->pr_StackSize;

    /* Make unix-like argc, argv (expand wildcards) */
    if (!line[0]) {
	/* Workbench, create argc & argv from files passed */
	extern struct WBStartup *WBenchMsg;
	int i;

	/* Initialise I/O. SAS C runtime provide us an input/output window */
	BPTR winin = __ufbs->ufbfh;
	BPTR winout = __ufbs->ufbnxt->ufbfh;
	BPTR winerr = __ufbs->ufbnxt->ufbnxt->ufbfh;

	/* Give up if nothing is available */
	if (!winin || !winout || !winerr)
	    _fail("No standard I/O");

	_init_unixio(winin, FALSE, winout, FALSE, winerr, FALSE);

	/* Make argc, argv from Workbench parameters */
	make_argv(&args, WBenchMsg->sm_NumArgs);

	for (i = 0; i < WBenchMsg->sm_NumArgs; i++) {
	    char filename[256];

	    if (NameFromLock(WBenchMsg->sm_ArgList[i].wa_Lock, filename, 256)) {
		AddPart(filename, WBenchMsg->sm_ArgList[i].wa_Name, 256);
		add_arg(&args, filename, TRUE);
	    }
	    /* else A parameter was lost, cry, cry, cry */
	}
    } else {
	/* From CLI expand wildcards (with unix-like command line parsing) */
	BPTR in, out, err;

	/* Initialise I/O. Copy CLI info provided by SAS/C runtime */
	in = __ufbs->ufbfh;
	out = __ufbs->ufbnxt->ufbfh;
	if ((err = _us->pr_CES) == 0)
	    err = __ufbs->ufbnxt->ufbnxt->ufbfh;

	/* Give up if nothing is available */
	if (!in || !out || !err)
	    _fail("No standard I/O");

	_init_unixio(in, FALSE, out, FALSE, err, FALSE);

	make_argv(&args, 1);

	anchor = _xmalloc(sizeof(struct AnchorPath) + NAMELEN);
	anchor->ap_Strlen = NAMELEN;
	pattern = _xmalloc(DEFPATLEN);
	while (1) {
	    long new_patlen;
	    int wild;

	    /* Skip white space */
	    while (isspace(*line))
		line++;
	    if (!*line)
		break;          /* End of command line */

	    /* Extract next word */
	    /* Words in double quotes are handled AmigaDOS style
	     * (+ filename expansion) */
	    if (*line == '"') {
		line++;
		arg_start = line;
		/* Find end of word */
		while (*line && *line != '"') {
		    /* '*' is an escape character inside double quotes
		     * (AmigaDOS compatibility) */
		    if ((*line == '*') && line[1])
			line++;
		    line++;
		}
		arg_end = line;
		if (*line == '"')
		    line++;
		arg_quoted = quote_double;
	    }
	    /* Words in single quotes are handled unix style */
	    else if (*line == '\'') {
		line++;
		arg_start = line;
		/* Find end of word */
		while (*line && *line != '\'')
		    line++;
		arg_end = line;
		if (*line == '\'')
		    line++;
		arg_quoted = quote_single;
	    }
	    /* Unquoted words are handled unix style */
	    else {              /* Plain word */
		arg_start = line;
		/* Find end of word */
		while (*line && !isspace(*line)) {
		    if (*line == '\\' && line[1])
			line++;
		    line++;
		}
		arg_end = line;
		arg_quoted = quote_none;
	    }
	    arg = _xmalloc(arg_end - arg_start + 1);
	    if (args.argc == 0) {       /* Command name is left untouched */
		strncpy(arg, arg_start, arg_end - arg_start);
		arg[arg_end - arg_start] = 0;
		add_arg(&args, arg, FALSE);
	    } else {
		new_patlen = (arg_end - arg_start) * 2 + 16;
		if (new_patlen > patlen) {
		    free(pattern);
		    pattern = _xmalloc(new_patlen);
		    patlen = new_patlen;
		}
		extract(arg, arg_start, arg_end, arg_quoted, extract_test);
		wild = ParsePattern(arg, pattern, patlen);
		if (wild < 0) {
		    *arg_end = 0;
		    _fail("Invalid wildcard %s", arg_start);
		}
		if (!wild) {
		    extract(arg, arg_start, arg_end, arg_quoted, extract_normal);
		    add_arg(&args, arg, FALSE);
		} else {
		    int none = TRUE;
		    long error;

		    anchor->ap_Flags = anchor->ap_Reserved = anchor->ap_BreakBits = 0;
		    extract(arg, arg_start, arg_end, arg_quoted, extract_pattern);
		    make_argv(&wildargs, 16);
		    error = MatchFirst(arg, anchor);
		    while (!error) {
			none = FALSE;
			if (!safe_add_arg(&wildargs, anchor->ap_Buf, TRUE)) {
			    error = ERROR_NO_FREE_STORE;
			    break;
			}
			error = MatchNext(anchor);
		    }
		    MatchEnd(anchor);
		    if (error != ERROR_NO_MORE_ENTRIES)
			_fail("Error expanding arguments");
		    if (none) {
			extract(arg, arg_start, arg_end, arg_quoted, extract_normal);
			add_arg(&args, arg, FALSE);
		    } else {
			tqsort(wildargs.argv, wildargs.argc);
			concat_args(&args, &wildargs);
			free(arg);
		    }
		}
	    }
	}
	free(pattern);
	free(anchor);
    }

    make_environ();

    if (!(_amiga_user.pw_name = __getenv("USER")))
	_amiga_user.pw_name = "user";
    if (!(_amiga_user.pw_gecos = __getenv("USERNAME")))
	_amiga_user.pw_gecos = _amiga_user.pw_name;
    if (!(_amiga_user.pw_dir = __getenv("HOME")))
	_amiga_user.pw_dir = "s:";
    if (!(_amiga_user.pw_shell = __getenv("SHELL")))
	_amiga_user.pw_shell = "bin:sh";
    if (!(_system_name = __getenv("HOSTNAME")))
	_system_name = "amiga";

    ret = main(args.argc, args.argv, environ);
    exit(ret);
}
