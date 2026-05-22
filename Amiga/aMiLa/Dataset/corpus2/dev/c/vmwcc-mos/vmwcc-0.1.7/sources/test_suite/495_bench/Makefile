VMWCC = ../../vmwcc
GCC = gcc
GCC_CFLAGS = -O2 -Wall
VMWCC_CFLAGS = -O0 -Wall


to_test := bm1 bm2 bm3 bm4 bm5 bm6 bm7 bm8


all:	$(to_test)

bm0:	bm0.c
	$(VMWCC) $(VMWCC_CFLAGS) bm0.c
	$(GCC) $(GCC_CFLAGS) -o bm0.gcc bm0.c

bm1:	bm1.c
	$(VMWCC) $(VMWCC_CFLAGS) bm1.c
	$(GCC) $(GCC_CFLAGS) -o bm1.gcc bm1.c

bm2:	bm2.c
	$(VMWCC) $(VMWCC_CFLAGS) bm2.c
	$(GCC) $(GCC_CFLAGS) -o bm2.gcc bm2.c

bm3:	bm3.c
	$(VMWCC) $(VMWCC_CFLAGS) bm3.c
	$(GCC) $(GCC_CFLAGS) -o bm3.gcc bm3.c
	
bm4:	bm4.c
	$(VMWCC) $(VMWCC_CFLAGS) bm4.c
	$(GCC) $(GCC_CFLAGS) -o bm4.gcc bm4.c
	
bm5:	bm5.c
	$(VMWCC) $(VMWCC_CFLAGS) bm5.c
	$(GCC) $(GCC_CFLAGS) -o bm5.gcc bm5.c
	
bm6:	bm6.c
	$(VMWCC) $(VMWCC_CFLAGS) bm6.c
	$(GCC) $(GCC_CFLAGS) -o bm6.gcc bm6.c
	
bm7:	bm7.c
	$(VMWCC) $(VMWCC_CFLAGS) bm7.c
	$(GCC) $(GCC_CFLAGS) -o bm7.gcc bm7.c	
	
bm8:	bm8.c
	$(VMWCC) $(VMWCC_CFLAGS) bm8.c
	$(GCC) $(GCC_CFLAGS) -o bm8.gcc bm8.c	
	
bm9:	bm9.c
	$(VMWCC) $(VMWCC_CFLAGS) bm9.c
	$(GCC) $(GCC_CFLAGS) -o bm9.gcc bm9.c		


clean:			 
			 rm -f *~ *.o *.s *.out1 *.out2 *.gcc $(to_test)
