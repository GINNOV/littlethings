//////////////////////////////////////////////////////////////////////////////
//
// Description:
//  This module contains the main entrypoint for the disassembler and 
//  the initializing of structures etc.
//
// Version:
//  v0.31 22-Nov-2001 JiK 
//  v0.34 29-Dec-2001 JiK
//  v0.35 30-Mar-2002 JiK
//  v0.36 30-Apr-2002 JiK
//
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <limits.h>
#include "tlcs900d.h"
#include "disasm.h"

//
// Static data for dump mode..
//

static uint32_t dumpstart = 0;
static uint32_t dumpend = 0;

//////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Usage..
//
// Parameters:
// Returns:
//
//////////////////////////////////////////////////////////////////////////////

static void usage( char **argv ) {
  fprintf(stderr,"Usage: %s [-<options>] rom-file\n",argv[0]);
  fprintf(stderr,"Options:\n");
  fprintf(stderr,"  -l n        List n lines\n");
  fprintf(stderr,"  -b address  ROM base address in hex\n");
  fprintf(stderr,"  -s n        Add n bytes of empty space\n");
  fprintf(stderr,"  -S address  Start address for dump disassembly\n");
  fprintf(stderr,"  -E address  End address for dump disassembly\n");
  exit(1);
}

//////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Initializes disassembler structures sets system defaults for the
//  disassembler.
//
// Parameters:
//  dd - A ptr to tlcs900d structure.
//
// Returns:
//  None.
//
//////////////////////////////////////////////////////////////////////////////

static void setdefaults( struct tlcs900d *dd ) {
  memset(dd,0,sizeof(struct tlcs900d));
  dd->lines = 20;
  dd->space = 0;
  dd->base = 0x000000;
}

//////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Parse command line options and override some system defaults
//  based on options.
//
// Parameters:
//  dd - A ptr to tlcs900d structure, which contains system defaults
//       for the disassembler.
//  argc - Number of arguments.
//  argv - A list of command line arguments.
//
// Returns:
//  0 if ok. 1 if error.
//
//////////////////////////////////////////////////////////////////////////////

static int checkoptions( struct tlcs900d *dd, int argc, char **argv ) {
  char *e;
  int n;

  for (n = 1; n < argc - 1; n += 2) {
    if (!strcmp("-l",argv[n])) {        // display lines
      dd->lines = atoi(argv[n+1]);
      if (dd->lines < 1) { dd->lines = 1; }
    } else if (!strcmp("-b",argv[n])) { // base address
      dd->base = strtoul(argv[n+1],&e,16);
    } else if (!strcmp("-s",argv[n])) { // extra space
      dd->space = atoi(argv[n+1]);
      if (dd->space < 0) { dd->space = 0; }
    } else if (!strcmp("-S",argv[n])) { // extra space
      dumpstart = strtoul(argv[n+1],&e,16);
    } else if (!strcmp("-E",argv[n])) { // extra space
      dumpend = strtoul(argv[n+1],&e,16);
    } else {
      fprintf(stderr,"Unknown option: %s\n",argv[n]);
      return 1;
    }
  }

  if (dumpend && dumpstart > dumpend) {
    fprintf(stderr,"Dump start can not be lower than dump end.\n");
    return 1;
  }

  return 0;
}

//////////////////////////////////////////////////////////////////////////////
//
// Description:
//  main()
//
// Parameters:
//  argc - 
//  argv - 
//
// Returns:
//  0 if ok, > 0 if something went wrong.
//
//////////////////////////////////////////////////////////////////////////////

int main( int argc, char** argv ) {
  char new_cmd[MAX_CMD];
  struct tlcs900d dd;
  int n;

  // Check command line and options..

  if (argc < 2 || argc & 1) {
    usage(argv);
    return 0;
  }

  setdefaults(&dd);

  if (checkoptions(&dd,argc,argv)) {
    usage(argv);
    return 0;
  }

  // Greetings.. :)

  printf( "\n"
          "NEOGEO Pocket aware TLCS900H Disassembler v%s\n"
          "   (c) 2001-2 Jouni 'Mr.Spiv' Korhonen\n"
          "\n",NGD_VERSION); 

  // Load rom and init structures.. also check if the rom is
  // a NGP compliant rom..

  if (loadrom_and_init(argv[argc-1],&dd)) {
    printf("Exiting..\n");
    return 0;
  }

  //
  // There are two modes available: dump mode and interactive.
  // The dump mode just disassembles a predefined range of
  // rom to stdout. The dump mode is entered if the user
  // defines either -S or -E option..
  //
  // The interactive mode is.. hmm.. interactive :)
  //

  if (dumpstart != 0 || dumpend != 0) {
    // fix dump mode.. if dump end address is not defined then
    // dump from dump start to the end of rom.

    if (dumpend > dd.base) { dd.len = dumpend - dd.base; }
    if (dumpstart == 0) { dumpstart = dd.base; }

    // tweak the disassembly function not to care about
    // maximum number of outputted lines..

    dd.lines = INT_MAX;
    sprintf(new_cmd,"d %x",dumpstart);
    parse_command(new_cmd,&dd);

  } else {
    do {
      printf("-> ");

      if (fgets(new_cmd,80,stdin)) {
        n = parse_command(new_cmd,&dd);

        switch (n) {
        case DPARSE_SYNTAX_ERR:
          printf("Syntax Error..\n");
          break;
        case DPARSE_UNKNOWN_ERR:
          printf("Unknown Command Error..\n");
          break;
        case DPARSE_BOUNDS_ERR:
          printf("Invalid numbers or range error..\n");
          break;
        default:
          break;
        }
      } else {
        puts("Error..");
        continue;
      }
    } while (n != DPARSE_EXIT);
  }

  // Exit stuff..

  if (dd.buffer) { free(dd.buffer); }
  if (dd.fh) { fclose(dd.fh); }
  return 0;
}
