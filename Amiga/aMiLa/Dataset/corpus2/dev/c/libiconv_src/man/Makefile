# Generated automatically from Makefile.in by configure.
# Makefile for libiconv/man

#### Start of system configuration section. ####

# Directories used by "make":
srcdir = .

# Directories used by "make install":
prefix = /usr/local
local_prefix = /usr/local
exec_prefix = $(prefix)
mandir = $(prefix)/man

# Programs used by "make":
RM = rm -f


# Programs used by "make install":
INSTALL = /bin/install -c
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

#### End of system configuration section. ####

SHELL = /bin/sh

all :

install : force
	if [ ! -d $(DESTDIR)$(prefix) ] ; then mkdir $(DESTDIR)$(prefix) ; fi
	if [ ! -d $(DESTDIR)$(mandir) ] ; then mkdir $(DESTDIR)$(mandir) ; fi
	if [ ! -d $(DESTDIR)$(mandir)/man3 ] ; then mkdir $(DESTDIR)$(mandir)/man3 ; fi
	cd $(srcdir) && for f in *.3 ; do echo $(INSTALL_DATA) $$f $(DESTDIR)$(mandir)/man3/$$f ; $(INSTALL_DATA) $$f $(DESTDIR)$(mandir)/man3/$$f ; done

installdirs : force
	if [ ! -d $(DESTDIR)$(prefix) ] ; then mkdir $(DESTDIR)$(prefix) ; fi
	if [ ! -d $(DESTDIR)$(mandir) ] ; then mkdir $(DESTDIR)$(mandir) ; fi
	if [ ! -d $(DESTDIR)$(mandir)/man3 ] ; then mkdir $(DESTDIR)$(mandir)/man3 ; fi

uninstall : force
	cd $(srcdir) && for f in *.3 ; do echo $(RM) $(DESTDIR)$(mandir)/man3/$$f ; $(RM) $(DESTDIR)$(mandir)/man3/$$f ; done

check :

mostlyclean :

clean :

distclean : force
	$(RM) Makefile

maintainer-clean : distclean

force :

