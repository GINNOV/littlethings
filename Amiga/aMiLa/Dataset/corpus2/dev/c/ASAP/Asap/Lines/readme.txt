For SAS/C users, remember to specify cxxsrc at the command line:

sc cxxsrc lines.c link

To compile in GCC use:

gcc -noixemul -o Lines LINES.C

or

gcc -O2 -m68030 -noixemul -msmall-code -o Lines LINES.C