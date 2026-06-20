BIN=usr:bin
FILE=prototype

manx:
	make -f /generic_make/manx.makefile BIN=$(BIN) FILE=$(FILE)
	copy #?.c usr:src/cbackup
lattice:
	make -f /generic_make/lattice.makefile BIN=$(BIN) FILE=$(FILE)
	copy #?.c usr:src/cbackup
clean:
	delete $(BIN)/$(FILE)
	delete #?.dbg #?.info #?.map #?.bak #?.lnk #?.o
