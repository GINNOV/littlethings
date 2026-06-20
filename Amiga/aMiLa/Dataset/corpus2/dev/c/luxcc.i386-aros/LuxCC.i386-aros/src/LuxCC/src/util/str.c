#include "str.h"
#include <stdlib.h>
#include <stdarg.h>

struct String {
    char *buf;
    unsigned buf_max, buf_next;
};

String *string_new(unsigned siz)
{
    String *s;

    s = malloc(sizeof(String));
    s->buf = malloc(siz);
    s->buf_max = siz;
    s->buf_next = 0;
    return s;
}

void string_free(String *s)
{
    free(s->buf);
    free(s);
}

void string_clear(String *s)
{
    s->buf_next = 0;
}

int string_printf(String *s, char *fmt, ...)
{
	va_list args;
    unsigned avail, n;

	va_start(args, fmt);
    avail = s->buf_max-s->buf_next;
    if ((n=vsnprintf(s->buf+s->buf_next, avail, fmt, args)) >= avail) {
        char *p;

        if ((p=realloc(s->buf, s->buf_max*2+n)) == NULL)
            return -1;
        s->buf_max = s->buf_max*2+n;
        s->buf = p;

        va_end(args);
        va_start(args, fmt);
        vsprintf(s->buf+s->buf_next, fmt, args);
    }
    s->buf_next += n;
	va_end(args);
    return n;
}

int string_vprintf(String *s, char *fmt, va_list ap)
{
	va_list ap2;
    unsigned avail, n;

    va_copy(ap2, ap);
    avail = s->buf_max-s->buf_next;
    if ((n=vsnprintf(s->buf+s->buf_next, avail, fmt, ap)) >= avail) {
        char *p;

        if ((p=realloc(s->buf, s->buf_max*2+n)) == NULL)
            return -1;
        s->buf_max = s->buf_max*2+n;
        s->buf = p;

        vsprintf(s->buf+s->buf_next, fmt, ap2);
    }
    s->buf_next += n;
    return n;
}

void string_write(String *s, FILE *fp)
{
    fwrite(s->buf, 1, s->buf_next, fp);
}

char *string_curr(String *s)
{
    return s->buf+s->buf_next;
}

unsigned string_get_pos(String *s)
{
    return s->buf_next;
}

void string_set_pos(String *s, unsigned n)
{
    s->buf_next = n;
}
