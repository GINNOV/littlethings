CPPFLAGS=-O3 -I/usr/X11R6/include
# Comment out the following line if you use egcs :
CXXFLAGS=-fno-rtti -fno-exceptions
XLIB = -L/usr/X11R6/lib -lX11 -lXext

SWFOBJS=\
	flash.o \
	character.o \
	shape.o \
	button.o \
	program.o \
	bitmap.o \
	displaylist.o \
	font.o \
	graphic.o \
	text.o \
	matrix.o \
	script.o \
	sound.o \
	sprite.o \
	cxform.o \
	adpcm.o

#	bitstream.o
#	dump.o

all: libflash.o

libflash.o: $(SWFOBJS) Jpeg/libjpeg.a Zlib/libz.a
	ld -r -o $@ $(SWFOBJS) Jpeg/libjpeg.a Zlib/libz.a

Jpeg/libjpeg.a:
	cd Jpeg; $(MAKE)

Zlib/libz.a:
	cd Zlib; $(MAKE)

clean:
	-rm $(SWFOBJS) libflash.o
	cd Jpeg; $(MAKE) clean
	cd Zlib; $(MAKE) clean

.PHONY: plugin jpeg all
# DO NOT DELETE

adpcm.o: adpcm.h
bitmap.o: bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h Jpeg/jmorecfg.h Zlib/zlib.h
bitmap.o: Zlib/zconf.h swf.h matrix.h cxform.h rect.h character.h
bitmap.o: displaylist.h graphic.h
bitstream.o: bitstream.h
button.o: swf.h matrix.h cxform.h rect.h button.h character.h displaylist.h
button.o: graphic.h shape.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h
button.o: Jpeg/jmorecfg.h Zlib/zlib.h Zlib/zconf.h sound.h
character.o: swf.h matrix.h cxform.h rect.h character.h displaylist.h
character.o: graphic.h
cxform.o: cxform.h
displaylist.o: displaylist.h graphic.h swf.h matrix.h cxform.h rect.h
displaylist.o: character.h
dump.o: script.h swf.h matrix.h cxform.h rect.h shape.h character.h
dump.o: displaylist.h graphic.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h
dump.o: Jpeg/jmorecfg.h Zlib/zlib.h Zlib/zconf.h button.h sound.h font.h
dump.o: text.h adpcm.h program.h flash.h sprite.h
flash.o: script.h swf.h matrix.h cxform.h rect.h shape.h character.h
flash.o: displaylist.h graphic.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h
flash.o: Jpeg/jmorecfg.h Zlib/zlib.h Zlib/zconf.h button.h sound.h font.h
flash.o: text.h adpcm.h program.h flash.h sprite.h
font.o: font.h swf.h matrix.h cxform.h rect.h character.h displaylist.h
font.o: graphic.h shape.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h
font.o: Jpeg/jmorecfg.h Zlib/zlib.h Zlib/zconf.h
graphic.o: character.h swf.h matrix.h cxform.h rect.h displaylist.h graphic.h
graphic.o: sqrt.h
matrix.o: matrix.h
program.o: program.h swf.h matrix.h cxform.h rect.h character.h displaylist.h
program.o: graphic.h sound.h flash.h
script.o: script.h swf.h matrix.h cxform.h rect.h shape.h character.h
script.o: displaylist.h graphic.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h
script.o: Jpeg/jmorecfg.h Zlib/zlib.h Zlib/zconf.h button.h sound.h font.h
script.o: text.h adpcm.h program.h flash.h sprite.h
shape.o: swf.h matrix.h cxform.h rect.h shape.h character.h displaylist.h
shape.o: graphic.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h Jpeg/jmorecfg.h
shape.o: Zlib/zlib.h Zlib/zconf.h
sound.o: sound.h character.h swf.h matrix.h cxform.h rect.h displaylist.h
sound.o: graphic.h
sprite.o: sprite.h character.h swf.h matrix.h cxform.h rect.h displaylist.h
sprite.o: graphic.h program.h sound.h flash.h
text.o: graphic.h swf.h matrix.h cxform.h rect.h text.h font.h character.h
text.o: displaylist.h shape.h bitmap.h Jpeg/jpeglib.h Jpeg/jconfig.h
text.o: Jpeg/jmorecfg.h Zlib/zlib.h Zlib/zconf.h
