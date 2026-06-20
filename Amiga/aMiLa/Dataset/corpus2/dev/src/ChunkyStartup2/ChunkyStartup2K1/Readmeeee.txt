Short:    Chunkystartup.asm CGX/AGA/PICASSO useful for OSlike demos.(asm/C)
Uploader: krabob@online.fr
Author:   krabob@online.fr
Type:     dev/src

-----------------------------------------------------------
 krabob/mankind present a continuation of some merko work:

 Chunkystartup.o

 So here are nice functions to open 8bits chunky screen, and
it works the same on aga , cgx and picasso.
 very useful piece of code for demo nowadays.
 aga-only user can code CGX compatible and vice versa !!!
 resolution-free !!! OS-friendly !!! no RTG libs needed !!!

 usable in C or asm !!!

all code and linkable .o provided !!! test.c provided !
 even some executable provided ? what else !!!

Better Read ChunkyStartup.h for an explanation of functions.

 you have a function to open a screen, another
 to refresh it with a chunky screen, another to close it,
 et ceterae... all sources provided.

test! launch a screen asl requester,then a little zoomsprite effect.
test320! launch always a 320x240 screen, on cgx (if found) or AGA.


 report buggs (if there are ) at:

 krabob@online.fr

 and visit now and often: www.m4nkind.com for
 demo productions !!! more MODERN sources soon.

 if you want discuss demo and asm, take an irc client
 and visit #amycoders !!!

 What are the files ?


c2p1x1_8_c5_bm.s                 M.Kalms c2p optimised 020/030
c2p1x1_8_c5_bm_040.s             M.Kalms c2p optimised 040/060

                        (choose one of this 2 files included in
                        ChunkyStartup.asm  )

ChunkyStartup.asm                the functions sources
Test!                           executable with asl requester
ChunkyStartup.h                 primitives for vbcc
ChunkyStartup.o
test.c
Texture.Chunky                  data for test
Texture.LoadRGB32               data for test
cybergraphics.doc               some cybergraphics include
cybergraphics.i
cybergraphics_lib.i
hamfont                         some data for ChunkyDebug
ChunkyDebug.asm
ChunkyDebug.h
ChunkyDebug.o
KZoomSprite.h                   some drawing function to test
KZoomSprite.i
KZoomSprite.o
Readmeeee.txt


