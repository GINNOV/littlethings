
CC          = vc

stdCFLAGS   = -O3 -k -sc -DVBCC -c -notmpfile -IInclude/ -no-trigraphs \
              -maxoptpasses=100 -maxerrors=4 -cpu=68030 -inline-size=20
stdLDFLAGS  = -lamiga

TstCFLAGS   = $(stdCFLAGS) -sd
TstLDFLAGS  = $(stdLDFLAGS) -lressourcetracking

LibCFLAGS   = $(stdCFLAGS)
LibLDFLAGS  = $(stdLDFLAGS) -nostdlib
LibOBJS     = StartUp.o LibInit.o SampleFuncs.o
LibINCS     = include/ressourcetracking/ressourcetracking.h\
              include/ressourcetracking/ressourcetrackingbase.h\
              include/pragmas/ressourcetracking_pragmas.h\
              include/pragma/ressourcetracking_lib.h\
              include/clib/ressourcetracking_protos.h

TrashCmd    = C:Move
TrashPat    = (asm|i|s)
TrashDir    = div/
RM          = c:Delete


ressourcetracking.library: $(LibOBJS) $(LibINCS)
	$(CC) $(LibLDFLAGS) -o ressourcetracking.library $(LibOBJS)
	Copy ressourcetracking.library LIBS:ressourcetracking.library
	MProtect LIBS:ressourcetracking.library RWED GROUP RE OTHER RE

StartUp.o: StartUp.c $(LibINCS)
	$(CC) $(LibCFLAGS) StartUp.c
	$(TrashCmd) StartUp.$(TrashPat) $(TrashDir)

LibInit.o: LibInit.c $(LibINCS)
	$(CC) $(LibCFLAGS) LibInit.c
	$(TrashCmd) LibInit.$(TrashPat) $(TrashDir)

SampleFuncs.o: SampleFuncs.c $(LibINCS)
	$(CC) $(LibCFLAGS) SampleFuncs.c
	$(TrashCmd) SampleFuncs.$(TrashPat) $(TrashDir)



Tst = Test
$(Tst)_r:
	$(Tst)

$(Tst): $(Tst).o
	$(CC) $(TstLDFLAGS) -o $(Tst) $(Tst).o

$(Tst).o: $(Tst).c
	$(CC) $(TstCFLAGS) -o $(Tst).o $(Tst).c
	$(TrashCmd) $(Tst).$(TrashPat) $(TrashDir)



CreateLib:
	c:Execute CreateLib.b



Clean:
	$(RM) $(TrashDir)#?.(a(|sm)|i|lnk) #?.(o|s) ressourcetracking.library

