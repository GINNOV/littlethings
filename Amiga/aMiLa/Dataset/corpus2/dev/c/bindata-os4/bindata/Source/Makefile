.PHONY:clean
.PHONY:tests
tests:bindata bsicon-32x32.png
	./bindata bsicon-32x32.png > bsicon-32x32.c
bindata: bindata.o
	gcc bindata.o -o bindata
bindata.o: bindata.c
	gcc -c bindata.c
clean:
	@ rm -f bindata bsicon-32x32.c bindata.o
