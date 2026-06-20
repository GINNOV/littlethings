VMWCC = ../vmwcc
GCC = gcc
GCC_CFLAGS = -O2 -Wall
VMWCC_CFLAGS = -O0 -Wall


to_test := times_table if_then while_nest if_nested write expr input reg \
           ifwhile array prime mod global_var if min_max mmm proc squares \
	   hello_world arr_str letter exam globals gcd complex collatz \
	   nested qsort complex_array heapsort fancy_read param big_global \
	   class_sample struct scope mem crazy_fp spill while dumb_math \
	   for unary shift char_array string

all:	$(to_test)

times_table:	times_table.c
		$(VMWCC) $(VMWCC_CFLAGS) times_table.c
		$(GCC) $(GCC_CFLAGS) -o times_table.gcc times_table.c
		
if_then:	if_then.c
		$(VMWCC) $(VMWCC_CFLAGS) if_then.c
		$(GCC) $(GCC_CFLAGS) -o if_then.gcc if_then.c		
		
while_nest:	while_nest.c
		$(VMWCC) $(VMWCC_CFLAGS) while_nest.c
		$(GCC) $(GCC_CFLAGS) -o while_nest.gcc while_nest.c				
		
if_nested:	if_nested.c
		$(VMWCC) $(VMWCC_CFLAGS) if_nested.c
		$(GCC) $(GCC_CFLAGS) -o if_nested.gcc if_nested.c						
		

write:	write.c
		$(VMWCC) $(VMWCC_CFLAGS) write.c
		$(GCC) $(GCC_CFLAGS) -o write.gcc write.c						
		
expr:	expr.c
		$(VMWCC) $(VMWCC_CFLAGS) expr.c
		$(GCC) $(GCC_CFLAGS) -o expr.gcc expr.c								
		
input:	input.c
		$(VMWCC) $(VMWCC_CFLAGS) input.c
		$(GCC) $(GCC_CFLAGS) -o input.gcc input.c		

ifwhile:	ifwhile.c
		$(VMWCC) $(VMWCC_CFLAGS) ifwhile.c
		$(GCC) $(GCC_CFLAGS) -o ifwhile.gcc ifwhile.c		
		

reg:	reg.c
		$(VMWCC) $(VMWCC_CFLAGS) reg.c
		$(GCC) $(GCC_CFLAGS) -o reg.gcc reg.c								
		
array:	array.c
		$(VMWCC) $(VMWCC_CFLAGS) array.c
		$(GCC) $(GCC_CFLAGS) -o array.gcc array.c								

prime:	prime.c
		$(VMWCC) $(VMWCC_CFLAGS) prime.c
		$(GCC) $(GCC_CFLAGS) -o prime.gcc prime.c								

mod:	mod.c
		$(VMWCC) $(VMWCC_CFLAGS) mod.c
		$(GCC) $(GCC_CFLAGS) -o mod.gcc mod.c								

global_var:	global_var.c
		$(VMWCC) $(VMWCC_CFLAGS) global_var.c
		$(GCC) $(GCC_CFLAGS) -o global_var.gcc global_var.c
		
		
if:	if.c
		$(VMWCC) $(VMWCC_CFLAGS) if.c
		$(GCC) $(GCC_CFLAGS) -o if.gcc if.c
		
min_max:	min_max.c
		$(VMWCC) $(VMWCC_CFLAGS) min_max.c
		$(GCC) $(GCC_CFLAGS) -o min_max.gcc min_max.c		

mmm:	mmm.c
		$(VMWCC) $(VMWCC_CFLAGS) mmm.c
		$(GCC) $(GCC_CFLAGS) -o mmm.gcc mmm.c		

proc:	proc.c
		$(VMWCC) $(VMWCC_CFLAGS) proc.c
		$(GCC) $(GCC_CFLAGS) -o proc.gcc proc.c		

squares:	squares.c
		$(VMWCC) $(VMWCC_CFLAGS) squares.c
		$(GCC) $(GCC_CFLAGS) -o squares.gcc squares.c		
		
hello_world:	hello_world.c
		$(VMWCC) $(VMWCC_CFLAGS) hello_world.c
		$(GCC) $(GCC_CFLAGS) -o hello_world.gcc hello_world.c				
	
arr_str:	arr_str.c
		$(VMWCC) $(VMWCC_CFLAGS) arr_str.c
		$(GCC) $(GCC_CFLAGS) -o arr_str.gcc arr_str.c						
		
letter:		letter.c
		$(VMWCC) $(VMWCC_CFLAGS) letter.c
		$(GCC) $(GCC_CFLAGS) -o letter.gcc letter.c						
		
exam:		exam.c
		$(VMWCC) $(VMWCC_CFLAGS) exam.c
		$(GCC) $(GCC_CFLAGS) -o exam.gcc exam.c								
		
globals:	globals.c
		$(VMWCC) $(VMWCC_CFLAGS) globals.c
		$(GCC) $(GCC_CFLAGS) -o globals.gcc globals.c										
		
gcd:		gcd.c
		$(VMWCC) $(VMWCC_CFLAGS) gcd.c
		$(GCC) $(GCC_CFLAGS) -o gcd.gcc gcd.c												
		
complex:	complex.c
		$(VMWCC) $(VMWCC_CFLAGS) complex.c
		$(GCC) $(GCC_CFLAGS) -o complex.gcc complex.c														
		
collatz:	collatz.c
		$(VMWCC) $(VMWCC_CFLAGS) collatz.c
		$(GCC) $(GCC_CFLAGS) -o collatz.gcc collatz.c																
		
nested:		nested.c
		$(VMWCC) $(VMWCC_CFLAGS) nested.c
		$(GCC) $(GCC_CFLAGS) -o nested.gcc nested.c																		
		
qsort:		qsort.c
		$(VMWCC) $(VMWCC_CFLAGS) qsort.c
		$(GCC) $(GCC_CFLAGS) -o qsort.gcc qsort.c																				
		
complex_array:		complex_array.c
		$(VMWCC) $(VMWCC_CFLAGS) complex_array.c
		$(GCC) $(GCC_CFLAGS) -o complex_array.gcc complex_array.c																						
		
heapsort:		heapsort.c
		$(VMWCC) $(VMWCC_CFLAGS) heapsort.c
		$(GCC) $(GCC_CFLAGS) -o heapsort.gcc heapsort.c																								
			
fancy_read:		fancy_read.c
		$(VMWCC) $(VMWCC_CFLAGS) fancy_read.c
		$(GCC) $(GCC_CFLAGS) -o fancy_read.gcc fancy_read.c																										
		
param:		param.c
		$(VMWCC) $(VMWCC_CFLAGS) param.c
		$(GCC) $(GCC_CFLAGS) -o param.gcc param.c																										
		

big_global:		big_global.c
		$(VMWCC) $(VMWCC_CFLAGS) big_global.c
		$(GCC) $(GCC_CFLAGS) -o big_global.gcc big_global.c																										

class_sample:	class_sample.c
		$(VMWCC) $(VMWCC_CFLAGS) class_sample.c
		$(GCC) $(GCC_CFLAGS) -o class_sample.gcc class_sample.c																										
		
struct:	struct.c
		$(VMWCC) $(VMWCC_CFLAGS) struct.c
		$(GCC) $(GCC_CFLAGS) -o struct.gcc struct.c																												
		
scope:	scope.c
		$(VMWCC) $(VMWCC_CFLAGS) scope.c
		$(GCC) $(GCC_CFLAGS) -o scope.gcc scope.c																														
		

mem:	mem.c
		$(VMWCC) $(VMWCC_CFLAGS) mem.c
		$(GCC) $(GCC_CFLAGS) -o mem.gcc mem.c																														
		
crazy_fp:	crazy_fp.c
		$(VMWCC) $(VMWCC_CFLAGS) crazy_fp.c
		$(GCC) $(GCC_CFLAGS) -o crazy_fp.gcc crazy_fp.c																																
		
		
spill:	spill.c
		$(VMWCC) $(VMWCC_CFLAGS) spill.c
		$(GCC) $(GCC_CFLAGS) -o spill.gcc spill.c																																
		
while:	while.c
		$(VMWCC) $(VMWCC_CFLAGS) while.c
		$(GCC) $(GCC_CFLAGS) -o while.gcc while.c																																		


dumb_math:	dumb_math.c
		$(VMWCC) $(VMWCC_CFLAGS) dumb_math.c
		$(GCC) $(GCC_CFLAGS) -o dumb_math.gcc dumb_math.c																																		
		
for:	for.c
		$(VMWCC) $(VMWCC_CFLAGS) for.c
		$(GCC) $(GCC_CFLAGS) -o for.gcc for.c																																				
		
unary:	unary.c
		$(VMWCC) $(VMWCC_CFLAGS) unary.c
		$(GCC) $(GCC_CFLAGS) -o unary.gcc unary.c																																				
		
shift:	shift.c
		$(VMWCC) $(VMWCC_CFLAGS) shift.c
		$(GCC) $(GCC_CFLAGS) -o shift.gcc shift.c																																						
		
char_array:	char_array.c
		$(VMWCC) $(VMWCC_CFLAGS) char_array.c
		$(GCC) $(GCC_CFLAGS) -o char_array.gcc char_array.c																																								
		
string:	string.c
		$(VMWCC) $(VMWCC_CFLAGS) string.c -lc
		$(GCC) $(GCC_CFLAGS) -o string.gcc string.c 		

clean:			 
			 rm -f *~ *.o *.s *.out1 *.out2 *.gcc *.ssa *.ssa2 $(to_test)
