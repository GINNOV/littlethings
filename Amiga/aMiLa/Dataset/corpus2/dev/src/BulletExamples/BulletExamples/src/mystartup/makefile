CFLAGS = nostackcheck

OBJS = mystartup.o
INCLUDES = mystartup.h

.c.o:
    sc $(CFLAGS) $*

all: $(OBJS)

install: $(OBJS)
    copy $(OBJS) lib:
    copy $(INCLUDES) include:

clean:
    delete >NIL: $(OBJS)
