# Generated automatically from Makefile.in by configure.
# Makefile for libiconv/src

#### Start of system configuration section. ####

# Directories used by "make":
srcdir = .

# Directories used by "make install":
prefix = /usr/local
local_prefix = /usr/local
exec_prefix = $(prefix)
libdir = $(exec_prefix)/lib

# Programs used by "make":
CC = gcc -O
CFLAGS = -noixemul 
CPP = gcc -O -E -w
INCLUDES = -I. -I$(srcdir) -I../include -I$(srcdir)/../include
LIBTOOL = $(SHELL) $(top_builddir)/libtool
LIBTOOL_COMPILE = $(LIBTOOL) --mode=compile
LIBTOOL_LINK = $(LIBTOOL) --mode=link
LIBTOOL_INSTALL = $(LIBTOOL) --mode=install
LIBTOOL_UNINSTALL = $(LIBTOOL) --mode=uninstall
CP = cp
MV = mv
LN = ln
LN_S = ln -s
RM = rm -f

# Programs used by "make install":
INSTALL = /bin/install -c
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

#### End of system configuration section. ####

SHELL = /bin/sh

# Before making a release, change this according to the libtool documentation,
# section "Library interface versions".
LIBICONV_VERSION_INFO = 2:1:0

# Needed by $(LIBTOOL).
top_builddir = ..

SOURCES = $(srcdir)/iconv.c

OBJECTS = iconv.lo

PLUG_SOURCES =

all : libiconv.la 

libiconv.la : $(OBJECTS)
	$(LIBTOOL_LINK) $(CC) -o libiconv.la -rpath $(libdir) -version-info $(LIBICONV_VERSION_INFO) $(OBJECTS)

libiconv_plug.so : libiconv_plug_.so
	$(RM) libiconv_plug.so
	$(LN_S) libiconv_plug_.so libiconv_plug.so

libiconv_plug_linux.so : $(SOURCES)
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -DPIC -DLIBICONV_PLUG $(SOURCES) $(PLUG_SOURCES) -shared -o libiconv_plug_linux.so

libiconv_plug_solaris.so : $(SOURCES)
	$(CC) $(CFLAGS) $(INCLUDES) -fPIC -DPIC -DLIBICONV_PLUG $(SOURCES) $(PLUG_SOURCES) -G -o libiconv_plug_solaris.so

libiconv_plug_osf.so : $(SOURCES)
	if test -n "yes"; then \
	  $(CC) $(CFLAGS) $(INCLUDES) -fPIC -DPIC -DLIBICONV_PLUG $(SOURCES) $(PLUG_SOURCES) -shared -o libiconv_plug_osf.so; \
	else \
	  $(CC) $(CFLAGS) $(INCLUDES) -DPIC -DLIBICONV_PLUG $(SOURCES) $(PLUG_SOURCES) -c -o iconv_plug.o; \
	  /bin/ld -shared -expect_unresolved \* -o libiconv_plug_osf.so iconv_plug.o; \
	fi

iconv.lo : $(srcdir)/iconv.c $(srcdir)/converters.h $(srcdir)/encodings.def $(srcdir)/encodings_aix.def $(srcdir)/aliases.h $(srcdir)/aliases_aix.h $(srcdir)/flags.h
	$(LIBTOOL_COMPILE) $(CC) $(CFLAGS) $(INCLUDES) -c $(srcdir)/iconv.c

# Installs the library and include files only. Typically called with only
# $(libdir) and $(includedir) - don't use $(prefix) and $(exec_prefix) here.
install-lib : all force
	if [ ! -d $(libdir) ] ; then mkdir $(libdir) ; fi
	$(LIBTOOL_INSTALL) $(INSTALL_DATA) libiconv.la $(libdir)/libiconv.la

install : all force
	if [ ! -d $(DESTDIR)$(prefix) ] ; then mkdir $(DESTDIR)$(prefix) ; fi
	if [ ! -d $(DESTDIR)$(exec_prefix) ] ; then mkdir $(DESTDIR)$(exec_prefix) ; fi
	if [ ! -d $(DESTDIR)$(libdir) ] ; then mkdir $(DESTDIR)$(libdir) ; fi
	$(LIBTOOL_INSTALL) $(INSTALL_DATA) libiconv.la $(DESTDIR)$(libdir)/libiconv.la
	if test -n ""; then $(INSTALL_DATA)  $(DESTDIR)$(libdir)/.new && mv $(DESTDIR)$(libdir)/.new $(DESTDIR)$(libdir)/ ; fi

installdirs : force
	if [ ! -d $(DESTDIR)$(prefix) ] ; then mkdir $(DESTDIR)$(prefix) ; fi
	if [ ! -d $(DESTDIR)$(exec_prefix) ] ; then mkdir $(DESTDIR)$(exec_prefix) ; fi
	if [ ! -d $(DESTDIR)$(libdir) ] ; then mkdir $(DESTDIR)$(libdir) ; fi

uninstall : force
	$(LIBTOOL_UNINSTALL) $(RM) $(DESTDIR)$(libdir)/libiconv.la
	if test -n ""; then $(RM) $(DESTDIR)$(libdir)/ ; fi

check : all

mostlyclean : clean

clean : force
	$(RM) *.o *.lo *.a *.la libiconv_plug* core
	$(RM) -r .libs _libs

distclean : clean
	$(RM) config.status config.log config.cache Makefile config.h libtool

maintainer-clean : distclean

force :

