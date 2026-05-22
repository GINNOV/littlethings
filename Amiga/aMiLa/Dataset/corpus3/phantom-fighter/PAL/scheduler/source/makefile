#################################################################
#								#
#		Make File for Phantom Fighter			#
#		   Written by Billy Newport			#
#								#
#		   (c) Emerald Software Ltd.			#
#								#
#################################################################

LNFLAGS=   +Q +SS +Cdb
LNLIBS=    -llib:cl32 -llib:ml32
#LNLIBS=    -llib:ml32
#CFLAGS=    +C +D +L +Iram:c/phantom.pre -DNOCOMEBACK
#CFLAGS=     +C +D +L -DNOCOMEBACK
CFLAGS=    +Iram:c/phantom.pre +C +D +L -Iheader: -DNOCOMEBACK -DMDEBUG
OBJS1=     main.o schedule.o queue.o DispList.o bullets.o game.o alert.o
OBJS2=     memory.o view.o loader.o ic.o wave.o joystick.o
OBJS3=     specials.o Debug.o patterns.o copper.o sound.o
OBJS4=     rnd.o loading.o scores.o sprites.o ReadKeys.o Collchk.o
OBJS5=     Animate.o isrs.o bugs.o eyes.o Blitter.o BigGuy.o
OBJS6=     BullData.o copperlist.o ADOS.o

GUY = header:bigguys.h
BDTA = header:BulletData.h
EYE = header:eyes.h
BUG = header:bugs.h
ANM = header:animation.h
COP = header:copperfunc.h
INT = header:interrupts.h
JOY = header:joystick.h
WVE = header:wave.h header:wave.i
DSP = header:displist.h header:displist.i header:collision.i header:collision.h
GME = header:game.h
BUL = header:bullets.h
TOK = header:token.h
SCH = header:scheduler.h header:scheduler.i
VIEW = header:view.h
IFF = header:iff.h header:iff.i
BLT = HEADER:BLITS.H
SND = header:sound.h
SPR = header:sprites.h

prog:	$(OBJS1) $(OBJS2) $(OBJS3) $(OBJS4) $(OBJS5) $(OBJS6)
	ln $(LNFLAGS) -O PROG $(OBJS1) $(OBJS2) $(OBJS5) $(OBJS6) $(OBJS3) $(OBJS4) $(LNLIBS)
         
        unhunk prog prog.obj
        kos z
        copy prog.obj ram:
        kos c ram:prog.obj test1.obj
        delete ram:prog.obj


phantom.pre: include.h
        cc +C  +D -s +L -Iheader: -A +Hphantom.pre include.h
        delete include.asm
        copy phantom.pre ram:c/

ReadKeys.o : ReadKeys.asm
        as -V -D readkeys.asm
        
Blitter.o : Blitter.asm
        as -V -C -D Blitter.asm
        
ISRs.o : ISRs.asm
        as -V -C -D ISRs.asm
        
COLLCHK.o : COLLCHK.asm
        as -V -C -D COLLCHK.asm
        
wave.o: wave.c $(WVE) $(DSP) $(SCH) $(GME) $(IFF)
        cc $(CFLAGS) wave.c

clare1.o: clare1.c
        cc $(CFLAGS) clare1.c

clare2.o: clare2.c
        cc $(CFLAGS) clare2.c

copperlist.o: copperlist.c
        cc $(CFLAGS) copperlist.c

ADOS.o: ADOS.c
        cc $(CFLAGS) ADOS.c

blits.o: blits.c $(BLT) $(IFF)
        cc $(CFLAGS) blits.c

BigGuy.o: BigGuy.c $(SCH) $(IFF) $(DSP) $(GUY) $(WVE) $(ANM) $(EYE)
        cc $(CFLAGS) BigGuy.c

eyes.o: eyes.c $(DSP) $(SCH) $(GME) $(IFF) $(EYE)
        cc $(CFLAGS) eyes.c

bugs.o: bugs.c $(DSP) $(SCH) $(BUG)
        cc $(CFLAGS) bugs.c

Animate.o: Animate.c $(DSP) $(SCH) $(EYE)
        cc $(CFLAGS) Animate.c

sprites.o: sprites.c $(SCH) $(SPR)
        cc $(CFLAGS) sprites.c

gii: gii.c
        cc +C +D +L gii.c
        ln $(LNFLAGS) -O c:gii gii.o alert.o memory.o loader.o -llib:cl32 -llib:ml32

AmigaPath: AmigaPath.c
        cc +C +D +L AmigaPath.c
        ln $(LNFLAGS) -O c:AmigaPath AmigaPath.o -llib:cl32 -llib:ml32

Test: Test.c
        cc -Iheader: +C +D +L Test.c
        ln $(LNFLAGS) -O Test test.o memory.o loader.o alert.o -llib:cl32 -llib:ml32
        unhunk test test.obj
#        kos z
#        copy test.obj ram:
#        kos c ram:test.obj test.obj
#        delete ram:test.obj


#safememory.o: safememory.c
#        cc $(CFLAGS) safememory.c

rnd.o: rnd.c
        cc $(CFLAGS) rnd.c

Scores.o: Scores.c $(JOY) $(VIEW) $(GME)
        cc $(CFLAGS) Scores.c

sound.o: sound.c $(SCH) $(SND) $(IFF)
        cc $(CFLAGS) sound.c

turretmap.o: turretmap.c $(GME)
        cc $(CFLAGS) turretmap.c

patterns.o: patterns.c $(WVE)
        cc $(CFLAGS) patterns.c

specials.o: specials.c $(TOK) $(GME) $(DSP) $(SCH) $(WVE) $(COP)
        cc $(CFLAGS) specials.c

Debug.o: Debug.c
        cc $(CFLAGS) Debug.c

alert.o: alert.c
        cc $(CFLAGS) alert.c

game.o: game.c $(GME)
        cc $(CFLAGS) game.c

joystick.o: joystick.c $(JOY) $(VIEW) $(GME) $(DSP) $(SCH) $(COP) $(WVE)
        cc $(CFLAGS) joystick.c

blits.o: blits.c $(VIEW) $(IFF) $(BLT)
        cc $(CFLAGS) blits.c

LOADER.o: LOADER.c $(IFF)
        cc $(CFLAGS) LOADER.c

BULLDATA.o: BULLDATA.c $(BDTA)
        cc $(CFLAGS) BULLDATA.c

LOADING.o: LOADING.c $(IFF) $(WVE)
        cc $(CFLAGS) LOADING.c

BULLETS.o: BULLETS.c $(BDTA) MyMissile.c $(EYE) $(GUY) $(BUL) $(VIEW) $(GME) $(SCH) $(DSP) $(IFF) $(SPR)
        cc $(CFLAGS) BULLETS.c

DispList.o: DispList.c $(SCH) $(DSP) $(WVE)
        cc $(CFLAGS) DispList.c

schedule.o: schedule.c $(SCH)
	cc $(CFLAGS) schedule.c

QUEUE.o : QUEUE.asm $(SCH)
        as -V -C -D QUEUE.asm
        
memory.o: memory.c $(IFF)
	cc $(CFLAGS) memory.c

view.o: view.c $(TOK) $(VIEW) $(SCH) $(GME) $(COP) $(IFF)
	cc $(CFLAGS) view.c

main.o: main.c $(SCH) $(DSP) $(WVE)
	cc $(CFLAGS) main.c

ic.o: ic.c $(INT) $(BLT) $(VIEW) $(SCH) $(GME)
	cc $(CFLAGS) ic.c

copper.o: copper.c
	cc $(CFLAGS) copper.c

