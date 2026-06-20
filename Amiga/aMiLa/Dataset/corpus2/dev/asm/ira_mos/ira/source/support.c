#include <exec/rawfmt.h>
#include <proto/exec.h>

TEXT mnebuf[32];
TEXT dtabuf[96];
TEXT adrbuf[64];

STRPTR itoa(ULONG integer)
{
	STATIC TEXT buf[16];
	ULONG d = integer;

	RawDoFmt("%ld", &d, (APTR)RAWFMTFUNC_STRING, buf);
	return buf;
}

STRPTR itohex(ULONG integer, ULONG len)
{
	STATIC TEXT buf[16];
	STATIC TEXT fmtbuf[] = "%04.4lx";
	ULONG d = integer;

	fmtbuf[2] = len + '0';
	fmtbuf[4] = len + '0';

	RawDoFmt(fmtbuf, &d, (APTR)RAWFMTFUNC_STRING, buf);
	return buf;
}

VOID mnecat(STRPTR buf)
{
	STATIC ULONG cnt;
	STRPTR dst;
	UBYTE c;

	dst = &mnebuf[ mnebuf[0] ? cnt : 0 ];

	do
	{
		c = *buf++;
		*dst++ = c;
	}
	while (c);

	cnt = dst - &mnebuf[0] - 1;
}

VOID dtacat(STRPTR buf)
{
	STATIC ULONG cnt;
	STRPTR dst;
	UBYTE c;

	dst = &dtabuf[ dtabuf[0] ? cnt : 0 ];

	do
	{
		c = *buf++;
		*dst++ = c;
	}
	while (c);

	cnt = dst - &dtabuf[0] - 1;
}

VOID adrcat(STRPTR buf)
{
	STATIC ULONG cnt;
	STRPTR dst;
	UBYTE c;

	dst = &adrbuf[ adrbuf[0] ? cnt : 0 ];

	do
	{
		c = *buf++;
		*dst++ = c;
	}
	while (c);

	cnt = dst - &adrbuf[0] - 1;
}

STRPTR argopt(int argc, char **argv, const char *foo, int *nextarg, char *option)
{
	STRPTR odata;

	odata = NULL;

	if (argc > *nextarg)
	{
		STRPTR p;

		p = argv[*nextarg];

		if (*p == '-')
		{
			*nextarg += 1;
			p++;

			*option = *p;
			odata = p + 1;
		}
	}

	return odata;
}
