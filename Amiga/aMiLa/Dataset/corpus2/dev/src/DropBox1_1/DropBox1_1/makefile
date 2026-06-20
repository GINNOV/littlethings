#DropBox Makefile
# Steve Anichini

NOSYM = -cci -E -isrc
SYM = -Hsrc/all.sym $(NOSYM)
FLAGS = $(SYM) -d4 
OBJSYM = obj+sym/
OBJ = obj/

DropBox.debug: DropBox.lnk $(OBJ)DropStrings.o $(OBJ)Version.o \
$(OBJSYM)DropEdit.o $(OBJ)logo.o $(OBJSYM)fileio.o $(OBJSYM)DropBox.o \
$(OBJSYM)window.o $(OBJSYM)database.o
	blink TO "DropBox.debug" with DropBox.lnk

DropBox: DropBox.lnk $(OBJ)DropStrings.o $(OBJ)Version.o \
$(OBJSYM)DropEdit.o $(OBJ)logo.o $(OBJSYM)fileio.o $(OBJSYM)DropBox.o \
$(OBJSYM)window.o $(OBJSYM)database.o
	blink NODEBUG TO "DropBox" with DropBox.lnk

DropBox.final: DropBox.lnk $(OBJ)DropStrings.o $(OBJ)Version.o \
$(OBJ)DropEdit.o $(OBJ)logo.o $(OBJ)fileio.o $(OBJ)DropBox.o \
$(OBJ)window.o $(OBJ)database.o
	blink NODEBUG TO "DropBox.final" with DropBox_Opt.lnk
	
$(OBJ)DropStrings.o: src/DropStrings.c src/DropBox.h src/all.sym
	lc $(SYM) -o$(OBJ)DropStrings.o src/DropStrings.c
	
$(OBJ)logo.o: src/logo.c
	lc $(NOSYM) -o$(OBJ)logo.o src/logo.c
	
$(OBJSYM)database.o: src/database.c src/DropBox.h src/all.sym
	lc $(FLAGS) -o$(OBJSYM)database.o src/database.c
	
$(OBJ)database.o: src/database.c src/DropBox.h src/all.sym
	lc $(SYM) -O -o$(OBJ)database.o src/database.c
		
$(OBJSYM)DropBox.o: src/DropBox.c src/DropBox.h src/all.sym src/window.h
	lc $(FLAGS) -o$(OBJSYM)DropBox.o src/DropBox.c

$(OBJ)DropBox.o: src/DropBox.c src/DropBox.h src/all.sym src/window.h
	lc $(FLAGS) -O -o$(OBJ)DropBox.o src/DropBox.c

$(OBJSYM)DropEdit.o: src/DropEdit.c src/DropBox.h src/all.sym src/window.h
	lc $(FLAGS)	-o$(OBJSYM)DropEdit.o src/DropEdit.c

$(OBJ)DropEdit.o: src/DropEdit.c src/DropBox.h src/all.sym src/window.h
	lc $(FLAGS)	-O -o$(OBJ)DropEdit.o src/DropEdit.c
	
$(OBJSYM)window.o: src/window.c src/window.h src/all.sym
	lc $(FLAGS) -o$(OBJSYM)window.o src/window.c

$(OBJ)window.o: src/window.c src/window.h src/all.sym
	lc $(FLAGS) -O -o$(OBJ)window.o src/window.c

$(OBJSYM)fileio.o: src/fileio.c src/fileio.h src/DropBox.h src/all.sym
	lc $(FLAGS) -o$(OBJSYM)fileio.o src/fileio.c

$(OBJ)fileio.o: src/fileio.c src/fileio.h src/DropBox.h src/all.sym
	lc $(FLAGS) -O -o$(OBJ)fileio.o src/fileio.c
		
$(OBJ)Version.o: src/version.c
	lc -o$(OBJ)Version.o src/version.c
	
src/all.sym: src/precomp.c
	lc $(NOSYM) -ph -osrc/all.sym src/precomp.c
	
