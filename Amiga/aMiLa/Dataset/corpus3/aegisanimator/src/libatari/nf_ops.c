#include <setjmp.h>
#include <stddef.h>
#include <nf_ops.h>
#include <osbind.h>
#include <errno.h>
#include <varargs.h>

#ifndef void
#  define void int
#endif

#define NATFEAT_ID   0x7300
#define NATFEAT_CALL 0x7301

#define __MINT_SIGILL		4L		/* illegal instruction */
#define __MINT_SIGSYS		12L		/* bad system call */

#define Psignal(a, b) gemdos(274, a, b)
#define Psigreturn() gemdos(282)

/*** ---------------------------------------------------------------------- ***/

long _nf_get_id P((const char *feature_name));

asm {
_nf_get_id:
	dc.w NATFEAT_ID
	rts
}


long _nf_call P((long id, ...));

asm {
_nf_call:
	dc.w NATFEAT_CALL
	rts
}

static char const nf_vers_str[] = NF_ID_VERSION;

static long _nf_tos P((void));

asm {
_nf_tos:
	pea		nf_vers_str(A4)
	moveq	#0,D0			/* assume no NatFeats available */
	move.l	D0,-(A7)
	lea		_nf_illegal(PC),A1
	move.l	0x0010,A0		/* illegal instruction vector */
	move.l	A1,0x0010
	move.l	A7,A1			/* save the ssp */

	nop						/* flush pipelines (for 68040+) */

	dc.w	NATFEAT_ID		/* Jump to NATFEAT_ID */
	tst.l	D0
	beq.s	_nf_illegal
	moveq	#1,D0			/* NatFeats detected */
	move.l	D0,(A7)

_nf_illegal:
	move.l	A1,A7
	move.l	A0,0x0010
	nop						/* flush pipelines (for 68040+) */
	move.l	(A7)+,D0
	addq.l	#4,A7			/* pop nf_version argument */
	rts
}

static void _nf_mint P((void));

asm {
_nf_mint:
	pea		nf_vers_str(A4)
	moveq	#0,D0			/* assume no NatFeats available */
	move.l	D0,-(A7)
	dc.w	NATFEAT_ID		/* Jump to NATFEAT_ID */
	addq.l	#8,A7			/* pop nf_version argument */
	rts
}

/*** ---------------------------------------------------------------------- ***/

static int sigsys;

static void sigsys_handler P((long sig))
{
	sigsys = 1;
}

void nf_catch_sigsys P((void))
{
	sigsys = 0;
	Psignal(__MINT_SIGSYS, sigsys_handler);
}

static jmp_buf ill_jmp;
static void catch_ill P((long sig))
{
	Psigreturn();
	longjmp(ill_jmp, 1);
}


static struct nf_ops _nf_ops = { _nf_get_id, _nf_call, { 0, 0, 0 } };
static struct nf_ops *nf_ops;

struct nf_ops *nf_init P((void))
{
	long ret;
	int got_ill;
	
	/*
	 * The __NF cookie is deprecated, but there is currently
	 * no standard defined what to do e.g. on ColdFire, where the
	 * NF opcodes are not illegal, and the detection would fail.
	 * So there is currently no choice but to check for the cookie,
	 * until we find a better solution.
	 */
	if (nf_ops == NULL)
	{
		nf_catch_sigsys();
		ret = Supexec(_nf_tos);
		if (ret == 1)
		{
			nf_ops = &_nf_ops;
		} else if (ret == -38) /* EPERM */
		{
			if ((ret = (long)Psignal(__MINT_SIGILL, catch_ill)) != -32L)
			{
				if ((got_ill = setjmp(ill_jmp)) == 0)
					_nf_mint();
				Psignal(__MINT_SIGILL, ret);
				if (got_ill == 0)
					nf_ops = &_nf_ops;
			}
		}
	}
	return nf_ops;
}

/*** ---------------------------------------------------------------------- ***/

const char *nf_get_name(buf, bufsize)
char *buf;
size_t bufsize;
{
	const char *ret = NULL;
	struct nf_ops *nf_ops;
	
	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_name = NF_GET_ID(nf_ops, NF_ID_NAME);
			
		if (nfid_name)
			if ((*nf_ops->call)(nfid_name | 0, buf, (unsigned long)bufsize) != 0)
			{
				ret = buf;
			}
	}
        
	return ret;
}

/*** ---------------------------------------------------------------------- ***/

const char *nf_get_fullname(buf, bufsize)
char *buf;
size_t bufsize;
{
	const char *ret = NULL;
	struct nf_ops *nf_ops;
	
	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_name = NF_GET_ID(nf_ops, NF_ID_NAME);
			
		if (nfid_name)
			if ((*nf_ops->call)(nfid_name | 1, buf, (unsigned long)bufsize) != 0)
			{
				ret = buf;
			}
	}
        
	return ret;
}

/*** ---------------------------------------------------------------------- ***/

long nf_version P((void))
{
	struct nf_ops *nf_ops;
	long version = 0;
	
	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_version = NF_GET_ID(nf_ops, NF_ID_VERSION);
		
		if (nfid_version)
		{
			version = (*nf_ops->call)(nfid_version | 0);
		}
	}
	return version;
}

/*** ---------------------------------------------------------------------- ***/

int nf_debug(msg)
const char *msg;
{
	struct nf_ops *nf_ops;

	if ((nf_ops = nf_init()) != NULL)
	{
		long nfid_stderr = NF_GET_ID(nf_ops, NF_ID_STDERR);
		
		if (nfid_stderr)
		{
			(*nf_ops->call)(nfid_stderr | 0, msg);
			return 1;
		}
	}
	
	return 0;
}

/*** ---------------------------------------------------------------------- ***/

long nf_shutdown(mode)
int mode;
{
	struct nf_ops *ops;
	long res = 0;

	if ((ops = nf_init()) != NULL)
	{
		long shutdown_id = NF_GET_ID(ops, NF_ID_SHUTDOWN);
		
		if (shutdown_id)
        	res = (*ops->call)(shutdown_id | mode);
	}
	return res;
}

/*** ---------------------------------------------------------------------- ***/

int nf_debugvprintf(format, args)
const char *format;
va_list args;
{
	struct nf_ops *ops;
	long nfid_stderr;
	int ret;
	
	if ((ops = nf_init()) == NULL ||
		(nfid_stderr = NF_GET_ID(ops, NF_ID_STDERR)) == 0)
	{
		errno = -32;
		return -1;
	}	
	{
		static char buf[2048];
		extern char *_sprintf();
		
		_sprintf(buf, args);
		ret = (*ops->call)(nfid_stderr | 0, buf);
	}

	return ret;
}

/*** ---------------------------------------------------------------------- ***/

int nf_debugprintf(format, va_alist)
const char *format;
va_dcl;
{
	int ret;
	va_list args;
	
	args = &format; /* kludge; _sprintf() expects this */
	ret = nf_debugvprintf(format, args);
	va_end(args);
	return ret;
}
