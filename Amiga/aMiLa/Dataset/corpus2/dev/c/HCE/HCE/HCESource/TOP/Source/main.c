/* Copyright (c) 1988,1989,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 * Modified by Detlef Wuerkner for AMIGA
 * Changes marked with TETISOFT
 *
 * 1994
 * Modified by Jason Petty to work with HCE.
 * Changes marked with VANSOFT.
 */

#include "top.h"

FILE *ifp, *ofp;  /* input/output file pointers */

/* ADDED BY TETISOFT */
FILE *rfp, *cfp, *dfp, *bfp; /* refs-code-data-bss-dest file pointers */
FILE *destfp;   /* desired destination file pointer */

#ifndef MINIX
long _STKSIZ = 32768L; /* need mucho stack for recursion */
#endif

/*
 * Options 
 */
bool debug   = FALSE;
bool do_brev = TRUE;  /* branch reversals enabled */
bool do_peep = TRUE;  /* peephole optimizations enabled */
bool do_regs = TRUE;  /* do "registerizing" */
bool do_lrot = TRUE;  /* do loop rotations */
bool gflag = FALSE;  /* don't do stuff that confuses the debugger */
bool verbose = FALSE;

/* ADDED BY TETISOFT */
int dest_hunk = PUBLICMEM;

/*
 * Optimization statistics (use -v to print)
 */
int s_bdel = 0;  /* branches deleted */
int s_badd = 0;  /* branches added */
int s_brev = 0;  /* branch reversals */
int s_lrot = 0;  /* loop rotations */
int s_peep1 = 0;  /* 1 instruction peephole changes */
int s_peep2 = 0;  /* 2 instruction peephole changes */
int s_peep3 = 0;  /* 3 instruction peephole changes */
int s_idel = 0;  /* instructions deleted */
int s_reg = 0;  /* variables "registerized" */

/* CHANGED BY TETISOFT */
/* #define TMPFILE "top_tmp.$$$" */ /* temporary file name */
/*int use_temp = FALSE; */ /* using temporary file */
char *rfile = "T:TOP.refs";
char *cfile = "T:TOP.code";
char *dfile = "T:TOP.data";
char *bfile = "T:TOP.bss";

char *Version =
"top Version 2.00  Copyright (c) 1988-1991 by Sozobon, Limited.";

/* ADDED BY TETISOFT */
char *Version2 =
"    Amiga Version 1.1 by Detlef W\374rkner.";

usage()
{

/* CHANGED BY TETISOFT */
 /* fprintf(stderr, "usage: top [-gdvblpr] infile [outfile]\n"); */
 fprintf(stderr, "\nUsage: top [flags] infile [outfile]\n");
 fprintf(stderr, "Valid optimizer flags are:\n");
 fprintf(stderr, "   -d: Debug\n");
 fprintf(stderr, "   -v: Verbose\n");
 fprintf(stderr, "   -b: Branch reversal OFF\n");
 fprintf(stderr, "   -l: Loop rotation OFF\n");
 fprintf(stderr, "   -p: Peephole optimization OFF\n");
 fprintf(stderr, "   -r: Variable registerizing OFF\n");
 fprintf(stderr, "   -g: No change of stack fix-ups (for debugging)\n");
 fprintf(stderr, "   -c: Force DATA and BSS hunks to Chip Memory\n");

/* CHANGED BY TETISOFT */
/* exit(1); */
 exit(EXIT_FAILURE);

}

/* ADDED BY TETISOFT */
FILE *saveopen(file, mode)
char *file, *mode;
{
 FILE *fp;
 void *buf;

 if ((fp = fopen(file, mode)) == NULL) {
    fprintf(stderr, "TOP: Can't open file %s\n", file);
    exit(EXIT_FAILURE);
 }
 buf = (void *)alloc(BUFSIZ);
 setbuf (fp, buf);
 return(fp);
}

/* ADDED BY TETISOFT */
void savecopy(fp, name)
FILE *fp;
char *name;
{
 short c;

 fclose(fp);   /* fflush/rewind doesn't work! */
 fp = saveopen(name, "r");
 while ((c = fgetc(fp)) != EOF) {
     if (fputc(c, destfp) == EOF) {
     fprintf(stderr, "TOP: Can't write to output file\n");
  exit(EXIT_FAILURE);
     }
 }
 fclose(fp);
 remove(name);
}

main(argc, argv)
int argc;
char *argv[];
{
 FILE *fopen();
 register char *s;

/* ADDED BY TETISOFT */
 if (argc == 0) {  /* We run from WorkBench */
  exit(EXIT_FAILURE);
 }

 while (argc > 1 && argv[1][0] == '-') {
  for (s = &argv[1][1]; *s ;s++) {
   switch (*s) {
   case 'd': case 'D':
    debug = TRUE;
    break;
   case 'b': case 'B':
    do_brev = FALSE;
    break;
   case 'p': case 'P':
    do_peep = FALSE;
    break;
   case 'r': case 'R':
    do_regs = FALSE;
    break;
   case 'l': case 'L':
    do_lrot = FALSE;
    break;
   case 'v': case 'V':

/* CHANGED BY TETISOFT */
/* CHANGED AGIAN, VANSOFT */
                         fprintf(stderr,"%s\n%s\n",Version,Version2);
    verbose = TRUE;
    break;
   case 'g': case 'G':
    gflag = TRUE;
    break;
   case 'O': case 'z': case 'Z':
    /*
     * When options are received from 'cc' they
     * look like "-Oxxx", so just ignore the 'O'.
     */
    break;

/* ADDED BY TETISOFT */
   case 'c': case 'C':
    dest_hunk = CHIPMEM;
    break;

   default:
    usage();
    break;
   }
  }
  argv++;
  argc--;
 }

/* CHANGED BY TETISOFT */
 if ((argc > 3) || (argc < 2))
  usage();

/* COMMENTED OUT, VANSOFT.
 fprintf(stderr, "%s:\n", argv[1]);
*/

 ifp = saveopen(argv[1], "r");
 if (argc > 2)
  destfp = saveopen(argv[2], "w");
 rfp = saveopen(rfile, "w");
 ofp = rfp;
 cfp = saveopen(cfile, "w");
 dfp = saveopen(dfile, "w");
 bfp = saveopen(bfile, "w");

 dofile();

 if (verbose) {
  if (do_peep) {
   fprintf(stderr, "Peephole changes (1): %4d\n", s_peep1);
   fprintf(stderr, "Peephole changes (2): %4d\n", s_peep2);
   fprintf(stderr, "Peephole changes (3): %4d\n", s_peep3);
   fprintf(stderr, "Instructions deleted: %4d\n", s_idel);
  }
  if (do_regs)
   fprintf(stderr, "Variables registered: %4d\n", s_reg);
  if (do_lrot)
   fprintf(stderr, "Loop rotations      : %4d\n", s_lrot);
  if (do_brev)
   fprintf(stderr, "Branch reversals    : %4d\n", s_brev);
  fprintf(stderr, "Branches removed    : %4d\n", s_bdel - s_badd);
 }

/* ADDED BY TETISOFT */
 if (ifp != stdin)
  fclose(ifp);
 if (!destfp)
    destfp = saveopen(argv[1], "w");
 savecopy(rfp, rfile);
 savecopy(cfp, cfile);
 savecopy(dfp, dfile);
 savecopy(bfp, bfile);
 fprintf(destfp, "\n\tEND\n");
 if (destfp != stdout)
  fclose(destfp);
 exit(EXIT_SUCCESS);
}


dofile()
{
 if (!readline())
  return;

 while (dofunc())
  ;
}
