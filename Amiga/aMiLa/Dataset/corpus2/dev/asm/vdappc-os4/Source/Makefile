CC	= gcc -mcrt=newlib
COPTS	= -DBIGENDIAN
CLIBS	=

vdappc: vdappc.c ppc_disasm.c ppc_disasm.h
	$(CC) $(COPTS) -o vdappc vdappc.c ppc_disasm.c $(CLIBS)
