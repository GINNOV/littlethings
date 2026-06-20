/*
  pitch_shift.c - Peter Capasso

  RELEASED IN TO THE PUBLIC DOMAIN BY PETER C CAPASSO 15-JAN-2000

  uses doppler overlap add algorithm: cosine windowing with 50% overlap.
  uses floating point only for pre-rendering of window.
  Works good (but lacks anti-aliasing, which you should only notice
  when shifting down more than an octave)!

  Note: this version reads unsigned mono 16-bit raw files.  To use
  regular raw files, remove the calls to "flipper()".  To adapt to
  other file formats, replace the first flipper call with a call to
  a routine to convert from the file format to signed 16bit words, and
  replace the second call to flipper with a routine to convert back
  to your file format.

  Window size seriously effects sound quality
*/

/*
  with a window size of 8000 ...
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   up four half steps    10079
   up three half steps    9514
   up a whole note        8979
   up a half step         8476
   down a half step       7551
   down a whole note      7127
   down three half steps  6727
   down four half steps   6350

  twelfth root of two is roughly 1.059463094
*/

static char amiga_version[] = "$VER: Version 3.0\n";

#include<exec/types.h>
#include<ctype.h>
#include<stdio.h>
#include<stdlib.h>
#include<stddef.h>
#ifndef memmove
  #include "string.h"
#endif
#include "math.h"


/* defines */
#define mod %
#define neq !=
#define eq ==
#define OKDOKEY 0
#define DOOPS 20
#ifndef MAX_STR
#define MAX_STR 1024
#endif


/* global vars */
int shift_size;  /* set by user */
int window_size;  /* set by user */
WORD *read_buffer;   /* always shift_size in length */
WORD *write_buffer;  /* always window_size in length */
WORD *window_buffer; /*  "      "      "    "  "     */


/* forward references */
void flipper(WORD *, int);
void word_zero_fill(WORD *, int);
void pitch(WORD *);
void usage();
void usage_exit();
void render_sine();


/* start of actual code */
void flipper(b, len)
WORD *b;
int len;
{
  WORD *temp;

  for (temp = b; len--; temp++)
    *temp ^= (WORD) 0x8000;
  temp = (WORD *) NULL;
}


void word_zero_fill(b, len)
WORD *b;
int len;
{
  WORD *temp;

  for (temp = b; len--; temp++)
    *temp = 0;
  temp = (WORD *) NULL;
}


void pitch(rb)
WORD *rb;  /* pointer to somewhere in the read_buffer */
{
  long x, accumulator;

  for (x = 0; x neq window_size; x++) {
    /* get the sample */
    accumulator = rb[((x * shift_size) / window_size)];
    /* window it */
    accumulator *= window_buffer[x];   /* apply cosine window */
    /* scale back down to word range */
    accumulator /= 32768;  /* shift with sign fill instead? */
    /* add it to the output buffer */
    write_buffer[x] += accumulator;
  }
}


void usage()
{
  fprintf(stderr, "pitch_shift <infile> <outfile> <window_size> \
<pitch_ratio>\nWhere window_size is in samples and pitch_ratio is \
the pitch ratio relative to the window_size\n\
Remember: a ratio > window_size is a shift up in pitch.\n");
}


void usage_exit()
{
  usage();
  exit(DOOPS);
}


void render_sine()
{
  float temp;
  int x;

  for (x = 0; x neq window_size; x++) {
    temp = cos((x * PI * 2) / window_size);  /*  1   0   -1   0    1   */
    temp *= -0.5;                            /* -0.5 0    0.5 0   -0.5 */
    temp += 0.5;                             /*  0   0.5  1   0.5  0   */
    temp *= 32767.0;
    window_buffer[x] = (int) temp;
  }
}


main(argc, argv)
int argc;
char *argv[];
{
  FILE *f1, *f2;
  int wcount, status, exit_ready, half_window;

  if (argc eq 0)
    exit(DOOPS);
  if (argc neq 5) {
    usage_exit();
  }

  window_size = atoi(argv[3]);
  if ((window_size < 512) || (window_size > 8192)) {
    fprintf(stderr, "window size must be 512-8192\n");
    exit(DOOPS);
  }
  half_window = window_size / 2;

  shift_size = atoi(argv[4]);
  if (shift_size & 1)
    shift_size--;      /* force it to be even */
  if (
      (shift_size < 8) ||
      (shift_size > (window_size * 2))
     ) {
    fprintf(stderr, "shift_size must not be less than 8\n\
and it must not be more than 2x the window size.\n");
    exit(DOOPS);
  }
  printf("shift size: %d \twindow_size: %d\n", shift_size, window_size);

  if ((window_buffer = calloc(window_size, sizeof(WORD))) eq NULL) {
    fprintf(stderr, "error allocating window buffer\n");
    exit(DOOPS);
  }
  if ((read_buffer = calloc(window_size * 2, sizeof(WORD))) eq NULL) {
    free(window_buffer);
    fprintf(stderr, "error allocating read buffer\n");
    exit(DOOPS);
  }
  if ((write_buffer = calloc(window_size, sizeof(WORD))) eq NULL) {
    free(read_buffer);
    free(window_buffer);
    fprintf(stderr, "error allocating write buffer\n");
    exit(DOOPS);
  }
  render_sine();
  word_zero_fill(write_buffer, window_size);
  word_zero_fill(read_buffer, window_size * 2);
  if ((f1 = fopen(argv[1], "rb")) eq NULL) {
    fprintf(stderr, "error opening input file \"%s\"\n", argv[1]);
    exit(DOOPS);
  }
  setvbuf(f1, NULL, _IOFBF, 16384);
  if ((f2 = fopen(argv[2], "wb")) eq NULL) {
    fprintf(stderr, "error creating output file \"%s\"\n", argv[2]);
    exit(DOOPS);
  }
  setvbuf(f2, NULL, _IOFBF, 16384);

  /* now start to work: main loop */
  for (exit_ready = 1; exit_ready;) {
    /* shift 3/4 of memory down by 1/4 */
    memmove(
       read_buffer,                 /* dest */
       &read_buffer[half_window],   /* source */
       ((window_size + half_window) * sizeof(WORD))
    );
    wcount = fread(
       &read_buffer[window_size + half_window],
       sizeof(WORD),
       half_window,
       f1
    );
    flipper(&read_buffer[window_size + half_window], half_window);
    if (wcount < half_window) {  /* was only a partial block read (EOF)? */
      /* fill rest of read buffer with zeros */
      word_zero_fill(
        &read_buffer[window_size + half_window + wcount],
        half_window - wcount
      );
      exit_ready = 0;
    }
    /* shift, window, and mix into output */
    pitch(&read_buffer[(window_size * 2) - shift_size]);
    /* now write first half of buffer.  Then move the second half
       down to the first half, then zero out the second half */
    flipper(write_buffer, half_window);
    status = fwrite(write_buffer, sizeof(WORD), half_window, f2);
    if (status neq half_window) {
      fprintf(stderr, "file write error.  tried %d, did %d\n",
          half_window, status);
      exit(DOOPS);
    }
    memmove(
         write_buffer,
         &write_buffer[half_window],
         half_window * sizeof(WORD)
    );
    word_zero_fill(&write_buffer[half_window], half_window); 
  }
  fclose(f2);
  fclose(f1);
  free(window_buffer);
  free(read_buffer);
  free(write_buffer);
  fprintf(stderr, "\033[7m Done \033[m\n");
  exit(OKDOKEY);
}


/* actual end of this file */
