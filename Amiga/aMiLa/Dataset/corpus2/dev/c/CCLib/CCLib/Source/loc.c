/*-------------------------------------------------------------------------+
 |									   |
 | Name:    loc 							   |
 | Purpose: counts lines of actual code and comments and prints stats	   |
 |									   |
 | Author:  Robert W. Albrecht			   Date: 9/89		   |
 +-------------------------------------------------------------------------*/

#define ANSIC 1
#include "stdio.h"
#include "ccfunc.h"

long whitechars, codechars, commentchars, codelines;
long whitechars_total, codechars_total, commentchars_total, codelines_total;
long blanklines, blanklines_total, filecount;
short quiet;
short _math = 0; /* <= don't load MathIeeeDoubBas.library */

void do_totals(void) /* add up total stats */
{
whitechars_total += whitechars;
codechars_total += codechars;
commentchars_total += commentchars;
codelines_total += codelines;
blanklines_total += blanklines;
blanklines = whitechars = codechars = commentchars = codelines = 0L;
}

void printtotals(void) /* print total stats */
{
long avglines;
void printstats(void);

avglines = codelines_total/filecount;

printf("\nTotal statistics for %ld files...\n",filecount);
whitechars = whitechars_total;
codechars = codechars_total;
commentchars = commentchars_total;
codelines = codelines_total;
blanklines = blanklines_total;
printstats();
printf("The average number of code lines per file is %ld.\n\n",avglines);
}

void printstats(void) /* print stats */
{
long avgline;
long code_p;
long code_pn;

if( codelines )
   avgline = codechars/codelines;
else
   avgline = 0;
code_pn = code_p = codechars*100;
if( commentchars + whitechars + codechars )
   code_p /= (commentchars+whitechars+codechars);
else
   code_p = 0;
if( whitechars + codechars )
   code_pn /= (whitechars+codechars);
else
   code_pn = 0;

printf("%ld lines of code, ",codelines);
printf("%ld blank lines, ",blanklines);
printf("%ld bytes of code,\n",codechars);
printf("%ld bytes of whitespace, ",whitechars);
printf("and %ld bytes of comments.\n",commentchars);
printf("The average code line has %ld bytes.\n",avgline);
printf("The code content is %ld%%, %ld%% without comments.\n",
   code_p, code_pn);
}

#define COMMENT 1
#define BLANK 1
#define CODE 0

void loc(char *fname)  /* counts lines of actual code */
{
register FILE *f;
register short c, oldc;
register short mode, hascode;

if( f = fopen(fname,"r") )
   {
   c = oldc = -1;
   mode = CODE;
   hascode = BLANK;

   while( (c = getc(f)) != EOF )
      {
      switch( mode )
	 {
	 case CODE:
	    {
	    if( c == '*' && oldc == '/' )
	       {
	       mode = COMMENT;
	       codechars--;
	       }
	    else switch(c)
	       {
	       case '\n':
		  if( hascode == CODE )
		     {
		     codelines++;
		     hascode = BLANK;
		     }
		  else
		     blanklines++;
	       case '\t': case '\v': case '\b':
	       case '\r': case '\f': case '\a':
	       case ' ':
		  whitechars++;
	       break;

	       default:
		  hascode = CODE;
		  codechars++;
	       break;
	       }
	    }
	 break;

	 case COMMENT:
	    if( c == '/' && oldc == '*' )
	       mode = CODE;
	    else
	       commentchars++;
	 break;
	 }
      oldc = c;
      }
   if( !quiet )
      {
      printf("\nThe file %s contains...\n",fname);
      printstats();
      }
   do_totals();
   filecount++;
   fclose(f);
   }
else
   printf("Can't open input file %s\n",fname);
}



void main(long argc,char *argv[]) /* main routine */
{
short i;
char *ptr, *scdir();

if( argc > 1 )
   {
   printf("Lines Of C (LOC) by Robert W. Albrecht\n\n");

   for( i = 1; i < argc; i++)
      {
      if( argv[i][0] == '-' )
	 {
	 if( argv[i][1] == 'Q' || argv[i][1] == 'q' )
	    quiet = 1;
	 }
      else
	 {
	 while( ptr = scdir(argv[i]) )
	    {
	    loc(ptr);
	    }
	 }
      }
   if( filecount > 1 || quiet )
      printtotals();
   }
else if( argc == 1 )
   {
   printf("Lines Of C (LOC) by Robert W. Albrecht\n\n");
   printf("SYNTAX: loc [-Q] file1 file2 ...\n");
   printf("Wild-Card characters accepted.\n");
   }
}
