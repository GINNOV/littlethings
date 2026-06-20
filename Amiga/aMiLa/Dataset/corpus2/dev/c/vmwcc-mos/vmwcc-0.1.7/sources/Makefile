CC=gcc
CFLAGS = -O3 -Wall -g

#CC=cc
#CFLAGS = -O3 -Wall -arch host


vmwcc:	vmwcc.o ir_generator.o block.o copy_propogate.o cse.o debug.o node.o parser.o phi_functions.o register_allocate.o scanner.o ppc_backend.o
	$(CC) $(LFLAGS) -o vmwcc vmwcc.o block.o copy_propogate.o cse.o debug.o ir_generator.o node.o parser.o phi_functions.o register_allocate.o scanner.o ppc_backend.o

vmwcc.o:  vmwcc.c scanner.h
	  $(CC) $(CFLAGS) -c vmwcc.c

#csp:	csp.o alpha_backend.o csg.o css.o
#	$(CC) -o csp csp.o alpha_backend.o csg.o css.o


#alpha_backend.o:	alpha_backend.c
#	$(CC) $(CFLAGS) -c alpha_backend.c

block.o:      block.c
	      $(CC) $(CFLAGS) -c block.c

copy_propogate.o:   copy_propogate.c
		    $(CC) $(CFLAGS) -c copy_propogate.c

cse.o:	      cse.c
	      $(CC) $(CFLAGS) -c cse.c
	      

debug.o:      debug.c
	      $(CC) $(CFLAGS) -c debug.c

ir_generator.o:	    ir_generator.c
		    $(CC) $(CFLAGS) -c ir_generator.c

#parser.o:	parser.c
#	$(CC) $(CFLAGS) -c parser.c

#csg.o:	csg.c csg.h
#	$(CC) $(CFLAGS) -c csg.c

node.o:	node.c node.h type.h block.h
	$(CC) $(CFLAGS) -c node.c

parser.o:     parser.c
	      $(CC) $(CFLAGS) -c parser.c

phi_functions.o:	phi_functions.c
			$(CC) $(CFLAGS) -c phi_functions.c

register_allocate.o:	register_allocate.c
			$(CC) $(CFLAGS) -c register_allocate.c

scanner.o:	scanner.c scanner.h
	$(CC) $(CFLAGS) -c scanner.c
	
	
ppc_backend.o:		ppc_backend.c
			$(CC) $(CFLAGS) -c ppc_backend.c
	

clean:	
	rm -f *.o *~ vmwcc core *.dot *.ps core.* *.s
