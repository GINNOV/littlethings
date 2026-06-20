
#
# Note: when compiling slider.o, the compiler sometimes
# crashes with a bus-error.
# If that happens, compiling it manually from the command line
# might help
#

.c.o:
	mmcc.ttp $*.c
	mmimp.ttp $*.o

OBJS1 = active.o animdata.o animmenu.o bigrepla.o bringin.o centerpo.o
OBJS2 = changedi.o code.o colormen.o confirm.o control.o cseq.o cursorda.o
OBJS3 = digitgau.o displays.o findcolo.o hlstorgb.o io.o mainmenu.o morphdat.o
OBJS4 = morphmen.o reindex.o rotate.o rotateme.o scalescr.o scroller.o slider.o
OBJS5 = spikemen.o splitscr.o splittwe.o storagem.o story.o text.o timemenu.o
OBJS6 = undo.o upstream.o vbop.o vclone.o vgeneric.o vhook.o vloop.o vkill.o
OBJS7 = vmove.o vsample.o vspike.o vsupport.o workpoly.o wsubs.o zmenu.o

OBJS = $(OBJS1) $(OBJS2) $(OBJS3) $(OBJS4) $(OBJS5) $(OBJS6) $(OBJS7)

all ALL: libcomm.a

libcomm.a: $(OBJS)
	$(RM) $@
	mmlib.ttp rv $@ $(OBJS1)
	mmlib.ttp rv $@ $(OBJS2)
	mmlib.ttp rv $@ $(OBJS3)
	mmlib.ttp rv $@ $(OBJS4)
	mmlib.ttp rv $@ $(OBJS5)
	mmlib.ttp rv $@ $(OBJS6)
	mmlib.ttp rv $@ $(OBJS7)

clean CLEAN::
	$(RM) *.o *.a
