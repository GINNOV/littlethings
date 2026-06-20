# /************************************************************
#
#     TML's C Language Card Image Package  v1.1
#     January, 1993
#     Todd M. Lewis             (919) 776-7386
#     2601 Piedmont Drive
#     Sanford, NC  27330-9437
#     USA
# ************************************************************/

OPT = -qv -wc -hi includes
CC  = cc

# The options listed above mean the following things to
# the Manx Aztec C compiler (cc):
#   -qv       Be verbose about what file is being read.
#   -wc       Turn off warning about signed vs. unsigned character pointers.
#   -bs       Produce debugging information.
#   -hi includes Read the pre-compiled header file "includes"
#   -ho includes Dump the symbol table to the file "includes"
#
# The linker (ln) options are:
#   -g        Produce a debugging file.
#   +cd       Put initialized data into CHIP RAM.
#   -lc       link with the library "c.lib"

all: trimline Hello_V Hello_H Hello_VBig
vertical:   Hello_V
horizontal: Hello_H
big:        Hello_VBig

trimline: trimline.c
   cc trimline.c
   ln trimline.o -lc

CardHBrush.c: CardHBrush trimline
    ILBMtoC   CardHBrush
    trimline <CardHBrush.c >t:x
    copy t:x  CardHBrush.c
    delete t:x

CardVBrush.c: CardVBrush trimline
    ILBMtoC CardVBrush
    trimline <CardVBrush.c >t:x
    copy t:x CardVBrush.c
    delete t:x

CardVBigBrush.c: CardVBigBrush trimline
    ILBMtoC   CardVBigBrush
    trimline <CardVBigBrush.c >t:x
    copy t:x  CardVBigBrush.c
    delete t:x

CardHImages.o: CardHImages.c CardHImages.h Cards.h CardHBrush.c includes
        $(CC) $(OPT) CardHImages.c

Cards.o      : Cards.c Cards.h includes
        $(CC) $(OPT) Cards.c

CardVImages.o: CardVImages.c CardVImages.h Cards.h CardVBrush.c includes
        $(CC) $(OPT) CardVImages.c

CardVBigImages.o: CardVBigImages.c CardVBigImages.h Cards.h CardVBigBrush.c includes
        $(CC) $(OPT) CardVBigImages.c

Hello_H.o: Hello_H.c CardHImages.h Cards.h includes
    $(CC) $(OPT) Hello_H.c

Hello_H:   Hello_H.o CardHImages.o Cards.o
    ln +cd Hello_H.o CardHImages.o Cards.o -lc

Hello_V.o: Hello_V.c CardVImages.h Cards.h includes
    $(CC) $(OPT) Hello_V.c

Hello_V:   Hello_V.o CardVImages.o Cards.o
    ln +cd Hello_V.o CardVImages.o Cards.o -lc

Hello_VBig.o: Hello_VBig.c CardVBigImages.h Cards.h includes
    $(CC) $(OPT) Hello_VBig.c

Hello_VBig: Hello_VBig.o CardVBigImages.o Cards.o
    ln +cd  Hello_VBig.o CardVBigImages.o Cards.o -lc

includes: includes.c
    $(CC) -qv -wc -ho includes includes.c

clean:
    Delete Hello_H.dbg    CardHImages.o    Hello_H.o \
           Hello_V.dbg    CardVImages.o    Hello_V.o \
           Hello_VBig.dbg CardVBigImages.o Hello_VBig.o \
           Cards.o trimline.o includes

