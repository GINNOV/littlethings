
#include "freedb.h"

/****************************************************************************/

static UWORD sprintfStuff[] = {0x16c0, 0x4e75};

void __stdargs
sprintf(char *to,char *fmt,...)
{
    RawDoFmt(fmt,&fmt+1,(APTR)sprintfStuff,to);
}

/****************************************************************************/

struct stream
{
    char    *buf;
    int     size;
    int     counter;
    int     stop;
};

/****************************************************************************/

static void ASM
snprintfStuff(REG(d0) char c,REG(a3) struct stream *s)
{
    if (!s->stop)
    {
        if (++s->counter>=s->size)
        {
            *(s->buf) = 0;
            s->stop   = 1;
        }
        else *(s->buf++) = c;
    }
}

int __stdargs
snprintf(char *buf,int size,char *fmt,...)
{
    struct stream s;

    s.buf     = buf;
    s.size    = size;
    s.counter = 0;
    s.stop    = 0;

    RawDoFmt(fmt,&fmt+1,(APTR)snprintfStuff,&s);

    return s.counter-1;
}

/****************************************************************************/
