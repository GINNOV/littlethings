CFLAGS = nostackcheck gst=include:all.gst

PROGS = /View /ViewChars /Rotate /ViewDiskfont
ICONS = /View.info /ViewChars.info /Rotate.info /ViewDiskfont.info
VIEW_OBJS = BulletMainFile.o window.o engine.o View.o input.o
VIEWCHARS_OBJS = BulletMainChars.o window.o engine.o ViewChars.o input.o
ROTATE_OBJS = BulletMain.o window.o engine.o Rotate.o
VIEWDISKFONT_OBJS = ViewDiskfont.o window.o

.c.o:
    sc $(CFLAGS) $*

all: $(PROGS)

/View: $(VIEW_OBJS)
    slink FROM LIB:mystartup.o $(VIEW_OBJS) TO /View LIBRARY LIB:sc.lib

/ViewChars: $(VIEWCHARS_OBJS)
    slink FROM LIB:mystartup.o $(VIEWCHARS_OBJS) TO /ViewChars LIBRARY LIB:sc.lib

/Rotate: $(ROTATE_OBJS)
    slink FROM LIB:mystartup.o $(ROTATE_OBJS) TO /Rotate LIBRARY LIB:sc.lib LIB:amiga.lib

/ViewDiskfont: $(VIEWDISKFONT_OBJS)
    slink FROM LIB:mystartup.o $(VIEWDISKFONT_OBJS) TO /ViewDiskfont LIBRARY LIB:sc.lib

clean:
    -@delete >NIL: $(VIEW_OBJS) $(VIEWCHARS_OBJS) $(ROTATE_OBJS) $(VIEWDISKFONT_OBJS)

realclean:
    -@smake clean
    -@delete >NIL: $(PROGS) $(ICONS)
