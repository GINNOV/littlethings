BIN=usr:bin

sas:
	csh -c prototype -o prototypes.h *.c
	smake -f sas.makefile BIN=$(BIN) all
	copy #?.h #?.c usr:src/cbackup
manx:
	csh -c prototype -o prototypes.h *.c
	mset "CCEDIT=vim -e"
	make -f usr:src/agl/makefile BIN=$(BIN) manx
	make -f manx.makefile BIN=$(BIN) all
	copy #?.h #?.c usr:src/cbackup
lattice:
	make -f lattice.makefile BIN=$(BIN)
	copy #?.h #?.c usr:src/cbackup
clean:
	delete #?.Err #?.dbg #?.info #?.map #?.bak #?.lnk #?.o
