# choose where hershey fonts are to reside
FONTDIR="VoglGrfx:"

# choose name of vogl library
VOGLLIB=VoglGrfx:vogl

all : vogldriver voglsrc voglhershey clean

vogldriver :
	cc -DAMIGA drivers/amiga.c

voglsrc :
	cc -Isrc -DAMIGA src/arcs.c
	cc -Isrc -DAMIGA src/attr.c
	cc -Isrc -DAMIGA src/buffer.c
	cc -Isrc -DAMIGA src/clip.c
	cc -Isrc -DAMIGA src/curves.c
	cc -Isrc -DAMIGA src/draw.c
	cc -Isrc -DAMIGA src/drivers.c
	cc -Isrc -DAMIGA src/getgp.c
	cc -Isrc -DAMIGA src/mapping.c
	cc -Isrc -DAMIGA src/matrix.c
	cc -Isrc -DAMIGA src/move.c
	cc -Isrc -DAMIGA src/newtoken.c
	cc -Isrc -DAMIGA src/newtokens.c
	cc -Isrc -DAMIGA src/objects.c
	cc -Isrc -DAMIGA src/patches.c
	cc -Isrc -DAMIGA src/points.c
	cc -Isrc -DAMIGA src/polygons.c
	cc -Isrc -DAMIGA src/pref.c
	cc -Isrc -DAMIGA src/queue.c
	cc -Isrc -DAMIGA src/rect.c
	cc -Isrc -DAMIGA src/scale.c
	cc -Isrc -DAMIGA src/tensor.c
	cc -Isrc -DAMIGA src/text.c
	cc -Isrc -DAMIGA src/trans.c
	cc -Isrc -DAMIGA src/valloc.c
	cc -Isrc -DAMIGA src/vcalls.c
	cc -Isrc -DAMIGA src/viewing.c
	cc -Isrc -DAMIGA src/viewp.c
	cc -Isrc -DAMIGA src/yobbarays.c

voglhershey :
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/h2v.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/check.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/fdisp.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/fhtext.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/getchar.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/halloc.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/hdisp.c
	cc -Isrc -Ihershey/src -DFONTLIB=$(FONTDIR) -DAMIGA hershey/src/htext.c
	ord -v liblist.manx ram:tmp
	lb $(VOGLLIB) -f ram:tmp
	c:delete ram:tmp
	ln hershey/src/h2v.o   hershey/src/getchar.o -l$(VOGLLIB) -lm8 -lc
	ln hershey/src/hdisp.o hershey/src/getchar.o -l$(VOGLLIB) -lm8 -lc
	ln hershey/src/fdisp.o -l$(VOGLLIB) -lm8 -lc
	hershey/src/h2v hershey/data/hersh.oc
	hershey/src/h2v hershey/data/hersh.or hershey/fonts/japan.hmp japanese
	c:copy   astrology   cursive    cyrillic    $(FONTDIR)
	c:delete astrology   cursive    cyrillic
	c:copy   futura.l    futura.m   gothic.eng  $(FONTDIR)
	c:delete futura.l    futura.m   gothic.eng
	c:copy   gothic.ger  gothic.ita greek       $(FONTDIR)
	c:delete gothic.ger  gothic.ita greek
	c:copy   markers     math.low   math.upp    $(FONTDIR)
	c:delete markers     math.low   math.upp
	c:copy   meteorology music      script      $(FONTDIR)
	c:delete meteorology music      script
	c:copy   symbolic    times.g    times.i     $(FONTDIR)
	c:delete symbolic    times.g    times.i
	c:copy   times.ib    times.r    times.rb    $(FONTDIR)
	c:delete times.ib    times.r    times.rb
	c:copy   japanese                           $(FONTDIR)
	c:delete japanese

clean :
	copy c:delete ram:
	ram:delete drivers/amiga.o
	ram:delete src/arcs.o
	ram:delete src/attr.o
	ram:delete src/buffer.o
	ram:delete src/clip.o
	ram:delete src/curves.o
	ram:delete src/draw.o
	ram:delete src/drivers.o
	ram:delete src/getgp.o
	ram:delete src/mapping.o
	ram:delete src/matrix.o
	ram:delete src/move.o
	ram:delete src/newtoken.o
	ram:delete src/newtokens.o
	ram:delete src/objects.o
	ram:delete src/patches.o
	ram:delete src/points.o
	ram:delete src/polygons.o
	ram:delete src/pref.o
	ram:delete src/queue.o
	ram:delete src/rect.o
	ram:delete src/scale.o
	ram:delete src/tensor.o
	ram:delete src/text.o
	ram:delete src/trans.o
	ram:delete src/valloc.o
	ram:delete src/vcalls.o
	ram:delete src/viewing.o
	ram:delete src/viewp.o
	ram:delete src/yobbarays.o
	ram:delete hershey/src/h2v.o
	ram:delete hershey/src/check.o
	ram:delete hershey/src/fdisp.o
	ram:delete hershey/src/fhtext.o
	ram:delete hershey/src/getchar.o
	ram:delete hershey/src/halloc.o
	ram:delete hershey/src/hdisp.o
	ram:delete hershey/src/htext.o
	ram:delete hershey/src/h2v
	ram:delete hershey/src/hdisp
	ram:delete hershey/src/fdisp
	c:delete ram:delete
