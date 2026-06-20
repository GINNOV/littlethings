/*
 * Article 1436 of net.micro.amiga:
 * Relay-Version: version B 2.10.3 4.3bsd-beta 6/6/85; site well.UUCP
 * Posting-Version: version B 2.10.2 9/5/84; site yale.ARPA
 * Path: well!ptsfa!qantel!lll-crg!ucdavis!ucbvax!decvax!yale!umetcalf
 * From: umetcalf@yale.ARPA (Chris Metcalf)
 * Newsgroups: net.micro.amiga
 * Subject: stripc.c -- strip your include files down to size!
 * Message-ID: <186@yale.ARPA>
 * Date: 4 Jan 86 20:19:26 GMT
 * Date-Received: 5 Jan 86 12:53:49 GMT
 * Reply-To: umetcalf@yale-cheops.UUCP (Chris Metcalf)
 * Distribution: net
 * Organization: Yale University CS Dept., New Haven CT
 * Lines: 165
 */

/*
 * This program should be run on all the files in your /include directory.
 * It simple-mindedly strips out comments and much of the extra whitespace.
 * It may fragment the disk a bit, however (by creating and renaming temp 
 * files), so you may want to do a loogical copy of the disk when you're done.
 * The program can be used either with an argument (stripc stdio.h),
 * or as a filter (stripc < stdio.h > test.h).
 * 
 * Enjoy!
 * 				Chris 
 * 
 */

/*
 * stripc.c
 * 
 * 	This program removes all comments from the selected file (either
 * a command-line argument or standard input).  It also removes much of
 * the excess whitespace while attempting to preserve the basic 
 * arrangement of the program text.
 *
 * Chris Metcalf
 * Jan 2, 1986
 */

#include <stdio.h>
#include <ctype.h>

#define bool char
#define TRUE 1
#define FALSE 0

char nextchar();		/* returns next non-comment character */
void strip_blanks();
#define WS 0x80			/* ORed into whitespace characters */

main (argc, argv)
char **argv;
{
  char tmpfile[32];	/* temp name of stripped file */
  char *name;		/* name of this program (stripc) */
  FILE *in, *out;	/* file descriptors for parameter files */

  /* read filename arguments -- syntax: stripc [filename filename ...] */

  name = argv[0];
  if (argc == 1) strip_blanks(stdin, stdout);
  else while (*++argv) {
    if ((in = fopen(*argv, "r")) == NULL) {
      fprintf(stderr, "%s: couldn't open file %s\n", name, *argv);
      exit(1);
    }
    if ((out = fopen(strcat(strcpy(tmpfile, *argv), ".t"), "w")) == NULL) {
      fprintf(stderr, "%s: couldn't open temp file %s\n", name, tmpfile);
      exit(1);
    }
    strip_blanks(in, out);
    fclose(in);
    fclose(out);
    if (unlink(*argv)) {
      fprintf(stderr, "%s: couldn't remove %s\n", name, *argv);
      exit(1);
    }
    if (rename(tmpfile, *argv)) {
      fprintf(stderr, "%s: couldn't rename %s as %s\n",name,*argv,tmpfile);
      exit(1);
    }
  }
}

/*
 * read characters through nextchar(), eliminating white space
 */

void strip_blanks(in, out)
FILE *in, *out;
{
  char c;		/* current character */
  char lastws = 0;	/* the white space character being buffered */
  bool ws;		/* set if current character if white space */

  while ((c = nextchar(in)) != EOF) {
    ws = c & WS;
    c &= ~WS;
    if (lastws) {
      if (!ws) {
	putc(lastws, out);
	putc(c, out);
	lastws = 0;
      }
      else if (c == '\n' || c == '\r' || c == '\f') lastws = '\n';
      else if (c == '\t' && lastws != '\n') lastws = '\t';
      else if (c == ' ' && lastws != '\n' && lastws != '\t') lastws = ' ';
    }
    else if (ws) lastws = (c=='\r'||c=='\f')?'\n':c;
    else putc(c, out);
  }
  if (lastws) putc(lastws, out);
}

char nextchar (in)
FILE *in;
{
  char c;  			/* current character being read */
  bool modes;	  		/* a temp variable for testing all modes */
  static char next;  		/* the character waiting to be read */
  static bool init = TRUE,  	/* is the first time through the loop */
    comments = FALSE,  		/* whether we're in a block of comments */
    oldcomments = FALSE,  	/* whether we WERE in a block of comments */
    quotes = FALSE, 		/* whether we're in double quotes */
    single = FALSE, 		/* in single quotes */
    preproc = FALSE, 		/* in a # line (preprocessor command) */
    demagic = FALSE, 		/* was the previous character a backslash */
    newline = TRUE; 		/* was the previous character a newline */

  /* establish lookahead the first time the routine is called */

  if (init) {
    next = getc(in);
    init = FALSE;
  }

  /*
   * The main do statement loops until a "real" character is found,
   * or the end of file is encountered.  The initial state of preproc,
   * quotes, single, and comments are saved so that transitions from
   * state to state during the "switch" can be eliminated in the output.
   *
   * The switch statement handles the work and the strange cases.
   * If a # is found and the previous character was a newline, and
   * we're not in comments mode, preprocessor mode is set TRUE.  
   * Preprocessor mode is ended by a newline (unless it's escaped).
   * Comments mode is set if a / is followed by a *, and none of
   * the other modes (preproc, quotes, single) are set.  Comments mode
   * is ended by * followed by / unless it's in a preprocessor line.
   * Single quotes mode is toggled on and off by ', unless we're in
   * double quotes or a comment mode, or the ' is escaped.  Double
   * quotes function similarly.  Note that single and double quotes
   * mode can be erroneously set during preprocessor lines, but this
   * is unimportant, since the code for newline already turns off quotes
   * mode at the end of a line (to guard against mismatched quotes).
   */

  do {
    if ( (c = next) == EOF) {
      init = TRUE;
      return (EOF);
    }
    next = getc(in);
    modes = preproc || quotes || single;
    oldcomments = comments;
    switch (c) {
      case '#': if (newline && !comments) preproc = TRUE; break;
      case '\n': if (!demagic) preproc = single = quotes = FALSE; break;
      case '/': if (!quotes && !single && next == '*') comments = TRUE; break;
      case '*': if (comments && next == '/') comments = FALSE; break;
      case '\'': if (!comments && !demagic && !quotes) single = !single; break;
      case '"': if (!comments && !demagic && !single) quotes = !quotes; break;
    }
    demagic = ( !demagic && (c == '\\') );
    newline = ( !demagic && (c == '\n') );
    if ( comments != oldcomments )
      next = getc(in);  /* we don't want to have to read it again */
  } while (comments || oldcomments);
  if ((!isprint(c) || c == ' ') && !quotes && !single) c |= WS;
  return c;
}


