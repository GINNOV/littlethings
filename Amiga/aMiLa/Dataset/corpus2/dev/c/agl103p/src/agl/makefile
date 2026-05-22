
sas:
	csh -c source ./Compile
manx:
	csh -c prototype -o prototypes.h *.c
	mset "CCEDIT=vim -e"
	make -f manx.makefile all
	copy #?.h #?.c usr:src/cbackup
lattice:
	make -f lattice.makefile
	copy #?.h #?.c usr:src/cbackup
clean:
	delete #?.Err #?.dbg #?.info #?.map #?.bak #?.lnk #?.o
