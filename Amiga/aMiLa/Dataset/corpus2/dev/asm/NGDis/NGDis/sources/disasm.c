/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  This module contains all commands that the interactive disassembler
//  understands. Also the command line parsing and command function
//  discovery in this module.
//
// Version:
//  v0.1 - 0.3       JiK - Initial versions..
//  v0.4 22-Nov-2001 JiK - Fixed layout..
//
// Supported Commands:
//  d      - disassemble a block of code
//  m      - hexdump a block of code
//  h      - help page
//  help   - help page
//  rom    - display rom information if the rom is a NGP rom
//  :      - poke bytes/shorts/longs into memory
//  w      - save a block of code to the disk
//  x      - exit
//  D      - re-disassemble previous disassembly
//  <CRLF> - repeat previous command like 'd' and 'm'
//
/////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <assert.h>

#include "tlcs900d.h"
#include "disasm.h"

//
//
//

static char cmd[MAX_CMD];
static uint32_t prev_pos = 0;
static int (*prev_cmd)( struct tlcs900d *, char * ) = NULL;

/////////////////////////////////////////////////////////////////////////////
//
// A list of implemented commands. Commands MUST be is alphabetical order
// by the command name. In case of mixing strings, chars and special
// marks check the ASCII table for corrent alphabetical ordering.
//
// About commands:
//
// All commands have the same function prototype. The first passed parameters
// is always a ptr to struct tlcs900d. The second passed parameter is always
// a ptr to char string that contains the 'typed' command line without
// the first parameter (i.e. the command like 'd') or NULL. Note that the
// passed string is already parsed with strtok() so the function
// can continue parsing with strtok(NULL, "....");
//
/////////////////////////////////////////////////////////////////////////////

struct _command {
  char *name;                               // name of the command
  int (*cmd)( struct tlcs900d *, char * );  // function ptr to command
  char *help;                               // description of the command
} commands[] = {
  // MUST be in alphabetical order!
  {"",    NULL,      "<CRLF>              -> repeat some previous "
   "commands without parameters"},
  {":",   poke,      ": address bytes ..  -> poke bytes into memory"},
  {"D",   disassemD, "D                   -> disasseble starting from "
   "previous address"},
  {"d",   disassem,  "d [address]         -> disasseble starting from "
   "address"},
  {"h",   help,      "h                   -> print short command manual"},
  {"help",help,      "help                -> print short command manual"},
  {"m",   memdump,   "m [address]         -> dump memory starting from "
   "address"},
  {"rom", rominfo, "rom                 -> print NGP rom info"},
  {"w",   save,      "w name start end    -> save rom between start and "
   "end"},
  {"x",   dexit,     "x                   -> exit"}
};

#define NUM_COMMANDS (sizeof(commands) / sizeof(struct _command))

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  This function parses the 'typed' command line. The parsing is done with
//  strtok(). The list of all commands is searched with binary search (which
//  requires that the list of commands is in alphabetical order). When the
//  desired command is found then corresponding function gets called..
//
// Parameters:
//  cmd - a ptr to char string containing the 'typed' command line.
//  dd  - a ptr to tjcs900d structure.
//
// Returns:
//  DPARSE_OK if ok,
//  DPARSE_UNKNOWN_ERR if the command was not found,
//  DPARSE_SYNTAX_ERR if the command line was not valid,
//  DPARSE_BOUNDS_ERR if there was invalid numbers or number ranges,
//  DPARSE_EXIT if the disassembler should exit.
//
/////////////////////////////////////////////////////////////////////////////

int parse_command( char *cmd, struct tlcs900d *dd ) {
  struct _command *cc;
  char *p;

  if (p = strtok(cmd," \t\r\n")) {
    if (cc = (struct _command *)bsearch(p,commands,NUM_COMMANDS,
                                        sizeof(struct _command),compare) ) {
      prev_cmd = NULL;
      return cc->cmd(dd,strtok(NULL," \t\r\n"));
    } else {
      return DPARSE_UNKNOWN_ERR;
    }
  } else if (prev_cmd) {
      return prev_cmd(dd,NULL);
  }

  return DPARSE_OK;
}

static int compare( const void *a, const void *b ) {
  return strcmp((const char *)a,((struct _command *)b)->name);
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Dump rom as hex and ascii.
//
// Parameters:
//  dd - a ptr to tlcs900d struct.
//  b  - a ptr to remaining command line.
//
// Returns:
//  DPARSE_OK in any case.
//
// Note:
//  
//
/////////////////////////////////////////////////////////////////////////////

#define CH(p) ( isprint(*(p)) ? *(p) : '.' )

static int memdump( struct tlcs900d *dd, char *b ) {
  uint32_t i;
  int n, m;
  uint8_t *p;

  if (b == NULL) {
    i = dd->pos;
  } else {
    i = getptr(b) - dd->base;

    if (i >= dd->len) {
      printf("End of ROM reached.\n");
      return DPARSE_OK;
    }

    dd->pos = i;
  }

  for (n = 0; n < dd->lines && dd->pos < dd->len; n++) {
    p = dd->buffer+dd->pos;
    printf("%08X: ",dd->base + dd->pos);
    printf("%02X%02X%02X%02X %02X%02X%02X%02X "
           "%02X%02X%02X%02X %02X%02X%02X%02X  ",
            *(p+0),*(p+1),*(p+2),*(p+3),*(p+4),*(p+5),*(p+6),*(p+7),
            *(p+8),*(p+9),*(p+10),*(p+11),*(p+12),*(p+13),*(p+14),*(p+15));

    p = dd->buffer+dd->pos;
    printf("'%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c'\n",
            CH(p+0),CH(p+1),CH(p+2),CH(p+3),CH(p+4),CH(p+5),CH(p+6),CH(p+7),
            CH(p+8),CH(p+9),CH(p+10),CH(p+11),
            CH(p+12),CH(p+13),CH(p+14),CH(p+15));
    dd->pos += 16;
  }

  // remember this for prev_cmd..

  prev_cmd = memdump;

  //

  return DPARSE_OK;
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Disassemble the previous page again.
//
// Parameters:
//
// Returns:
//
/////////////////////////////////////////////////////////////////////////////

static int disassemD( struct tlcs900d *dd, char *b ) {
  char ptr[10];
  sprintf(ptr,"%x",prev_pos);
  return disassem(dd,ptr);
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Disassemble n lines of code and output it to stdout.
//
// Parameters:
//
// Returns:
//
/////////////////////////////////////////////////////////////////////////////

static int disassem( struct tlcs900d *dd, char *b ) {
  uint32_t i;
  uint8_t *m;
  int n, l, j, s;

  static char empty[] = "            ";

  if (b == NULL) {
    i = dd->pos;
  } else {
    i = getptr(b) - dd->base;

    if (i >= dd->len) {
      printf("End of ROM reached.\n");
      return DPARSE_OK;
    }

    dd->pos = i;
  }

  // record previous position

  prev_pos = dd->pos + dd->base;

  //

  for (n = 0; n < dd->lines && dd->pos < dd->len; n++) {
    l = decode( dd );

    printf("%08X: ",dd->base + dd->pos);

    if (l == 0) {
      printf("%02X                ?????\n",dd->buffer[dd->pos++]);
    } else {
      m = dd->buffer + dd->pos;

      switch (dd->opt) {
      case OPT_1_0_0:
        printf("%02X                ",*m);
        break;
      case OPT_1_1_0:
        printf("%02X %02X             ",*m, *(m+1));
        break;
      case OPT_1_1_1:
        printf("%02X %02X %02X          ",*m,*(m+1),*(m+2));
        break;
      case OPT_1_1_2:
        printf("%02X %02X %02X%02X        ",*m,*(m+1),*(m+2),*(m+3));
        break;
      case OPT_1_2_0:
        printf("%02X %02X%02X           ",*m,*(m+1),*(m+2));
        break;
      case OPT_1_3_0:
        printf("%02X %02X%02X%02X         ",*m,*(m+1),*(m+2),*(m+3));
        break;
      case OPT_2_1_2:
        printf("%02X%02X %02X %02X%02X      ",*m,*(m+1),*(m+2),*(m+3),*(m+4));
        break;
      case OPT_1_4_0:
        printf("%02X %02X%02X%02X%02X       ",*m,*(m+1),*(m+2),*(m+3),*(m+4));
        break;
      case OPT_1_1_1_1_1_1:
        printf("%02X %02X %02X %02X %02X %02X ",*m,*(m+1),*(m+2),
               *(m+3),*(m+4),*(m+5));
        break;
      case OPT_1_n_1:
        printf("%02X ",*m++);
        for (s = 0, j = 2; j < l; j++, s += 2) { printf("%02X",*m++); }
        if (s) { printf(" "); s++; }
        s = 18 - 5 - s;
        printf("%02X%*.*s",*m++,s,s,empty);
        break;
      case OPT_1_n_1_1:
        printf("%02X ",*m++);
        for (s = 0, j = 3; j < l; j++, s += 2) { printf("%02X",*m++); }
        if (s) { printf(" "); s++; }
        s = 18 - 8 - s;
        printf("%02X %02X%*.*s",*(m),*(m+1),s,s,empty);
        break;
      case OPT_1_n_1_2:
        printf("%02X ",*m++);
        for (s = 0, j = 4; j < l; j++, s += 2) { printf("%02X",*m++); }
        if (s) { printf(" "); s++; }
        s = 18 - 10 - s;
        printf("%02X %02X%02X%*.*s",*(m),*(m+1),*(m+2),s,s,empty);
        break;
      case OPT_1_n_2:
        printf("%02X ",*m++);
        for (s = 0, j = 3; j < l; j++, s += 2) { printf("%02X",*m++); }
        if (s) { printf(" "); s++; }
        s = 18 - 7 - s;
        printf("%02X%02X%*.*s",*(m),*(m+1),s,s,empty);
        break;
      case OPT_1_n_1_4:
        printf("%02X ",*m++);
        for (s = 0, j = 6; j < l; j++, s += 2) { printf("%02X",*m++); }
        if (s) { printf(" "); s++; }
        s = 18 - 14 - s;
        printf("%02X %02X%02X%02X%02X%*.*s",
              *(m),*(m+1),*(m+2),*(m+3),*(m+4),s,s,empty);
        break;
      default:
        assert(0);
      }

      printf("%-5s %s\n",dd->opf,dd->ops);
      dd->pos += l;
    }
  }

  // remember this for prev_cmd..

  prev_cmd = disassem;

  //

  return DPARSE_OK;
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Exit the disassembler
//
// Parameters:
//
// Returns:
//  DPARSE_EXIT which causes the disassembler to exit.
//
/////////////////////////////////////////////////////////////////////////////

static int dexit( struct tlcs900d *dd, char *b ) {
  return DPARSE_EXIT;
}


/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Check and print information about NGP's rom header chunk. It is expected
//  that the header chunk is at the beginning of the loaded rom file.
//
// Parameters:
//
// Returns:
//  DPARSE_OK in any case.
//
/////////////////////////////////////////////////////////////////////////////

static int rominfo( struct tlcs900d *dd, char *b ) {
  checkrom(dd,1);
  return DPARSE_OK;
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Print a short disassembler command description to stdout.
//
// Parameters:
//
// Returns:
//  DPARSE_OK in any case.
//
/////////////////////////////////////////////////////////////////////////////

static int help( struct tlcs900d *dd, char *b ) {
  int n;

  printf("\n Quick Command Reference\n\n");

  for (n = 0; n < NUM_COMMANDS; n++) {
    printf("%s\n",commands[n].help);
  }
  return DPARSE_OK;
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Poke a number of bytes/shorts/longs into rom file. The poked data size
//  is automatically selected e.g. numbers greater than 0xff are stored as
//  shorts etc. Numbers and address default to hexadecimals but is the number
//  begins with underscore then it will be handled as a decimal i.e. _20
//  means 20 not 14H.
//
// Parameters:
//
// Returns:
//  DPARSE_OK if ok,
//  DPARSE_SYNTAX_ERROR if address is missing.
//
/////////////////////////////////////////////////////////////////////////////

static int poke( struct tlcs900d *dd, char *b ) {
  uint32_t i;
  uint32_t x;

  if (b == NULL) {
    return DPARSE_SYNTAX_ERR;
  } else {
    i = getptr(b) - dd->base;

    if (i >= dd->len) {
      printf("End of ROM reached.\n");
      return DPARSE_OK;
    }
  }

  while ((b = strtok(NULL," \t\r\n")) && i < dd->len) {
    x = getptr(b);

    if (x < 0x100) {
      dd->buffer[i++] = x;
    } else if (x < 0x10000) {
      dd->buffer[i++] = x >> 8;
      dd->buffer[i++] = x;
    } else if (x < 0x1000000) {
      dd->buffer[i++] = x >> 16;
      dd->buffer[i++] = x >> 8;
      dd->buffer[i++] = x;
    } else {
      dd->buffer[i++] = x >> 24;
      dd->buffer[i++] = x >> 16;
      dd->buffer[i++] = x >> 8;
      dd->buffer[i++] = x;
    }
  }

  return DPARSE_OK;
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Save a selected range of rom to a file.
//
// Parameters:
//
// Returns:
//  DPARSE_OK if ok,
//  DPARSE_SYNTAX_ERR if not enough parameters are passed,
//  DPARSE_BOUNDS_ERR if save endaddress <= startaddress.
//  In case of disk io error DPARSE_OK is returned but an error message
//  gets printed to stdout.
//
/////////////////////////////////////////////////////////////////////////////

static int save( struct tlcs900d *dd, char *b ) {
  FILE *fh;
  char *name;
  uint32_t s;
  uint32_t e;

  if (b == NULL) {
    return DPARSE_SYNTAX_ERR;
  } else {
    name = b;
  }
  if (b = strtok(NULL, " \t\r\n")) {
    s = getptr(b);

    if (b = strtok(NULL, " \t\r\n")) {
      e = getptr(b);

      if (s >= e) { return DPARSE_BOUNDS_ERR; }

      e -= dd->base;
      s -= dd->base;

      if (fh = fopen(name,"w+b")) {
        if (fwrite(dd->buffer+s,1,e-s,fh) != (e-s)) {
          printf("Writing file '%s' failed\n",name);
        }

        fclose(fh);
      } else {
        printf("Failed to open file '%s' for writing\n",name);
      }

      return DPARSE_OK;
    }
  }

  return DPARSE_SYNTAX_ERR;
}

/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Search for a string or bytes.
//
// Parameters:
//
// Returns:
//  DPARSE_OK if ok,
//  DPARSE_SYNTAX_ERR if not enough parameters are passed,
//  DPARSE_BOUNDS_ERR if save endaddress <= startaddress.
//  In case of disk io error DPARSE_OK is returned but an error message
//  gets printed to stdout.
//
/////////////////////////////////////////////////////////////////////////////

static int search( struct tlcs900d *dd, uint8_t *s ) {

  while (s && *s != '\0') {
    




  if (*s == '\'') {
    // handle as a string..
  } else {
    // handle as bytes..

  }

  }
  return DPARSE_OK;
}




/////////////////////////////////////////////////////////////////////////////
//
// Description:
//  Convert an ascii string to integer. If the string begins witn an
//  underscore, the number will be handled as a decimal. Normally conversion
//  handles numbers as hexadecimals.
//
// Parameters:
//  s - a ptr to char string containing one or more whitespace separated
//      ascii string representing decimal or hexadecimal numbers.
//
// Returns:
//  0 in case of error (also prints an error message to stdout), otherwise
//  the converted number.
//
/////////////////////////////////////////////////////////////////////////////

static uint32_t getptr( const char *s ) {
  int radix = 16;
  uint32_t r;
  char *b;

  if (*s == '_') {
    radix = 10;
    s++;
  }

  r = strtoul(s,&b,radix);

  if ((r == 0 || r == LONG_MAX)  && errno == ERANGE) {
    printf("Error: %s is not a valid number\n",s);
    r = 0;
  } 

  return r;
}
