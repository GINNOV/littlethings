CFLAGS = -so -waru

rconfig: rconfig.o genlib.o rc2.o rccopts.o gtbsup.o busyptrimg.o
    ln +s rconfig.o genlib.o rc2.o rccopts.o gtbsup.o busyptrimg.o -lc
    fixhunk21 rconfig

rccopts.o: rccopts.c rc2.h
rconfig.o: rconfig.c rc2.h
genlib.o: genlib.c rc2.h

stkchker: stkchker.c
    cc -so stkchker.c
    ln stkchker.o -lc
