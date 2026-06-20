#
#        Makefile for BumpRev (AztecC v5.2a)
#
# Macros
#
PRECOMP=ram:bumprev.pre
DEFINES=
MYCFLAGS=-ms -pacs0t -so -wdelopqw

CFLAGS=$(MYCFLAGS) $(DEFINES) -hi $(PRECOMP)
LFLAGS=-m +q

OBJECTS=bumprev.o

LIBRARIES=-la16 -lc16

#
# Dependancy entries
#
all: $(PRECOMP) bumprev
#
$(PRECOMP): bumprev.pre
   copy bumprev.pre $(PRECOMP) clone
#
bumprev.pre: includes.h
   cc -o nil: -ho $(PRECOMP) -a $(MYCFLAGS) includes.h
   copy $(PRECOMP) $@ clone
#
bumprev: $(OBJECTS)
   ln $(LFLAGS) -o $@ $(OBJECTS) $(LIBRARIES)
#
