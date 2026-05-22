/*
 * CCHECK.C -- Amiga Lattice C version 4/8/86
 *
 *
 * Copyright: The Regents of the University of California
 *   [Note - since Steve Draper distributed cchk.c over
 *    Usenet, I assume it's effectively in the public
 *    domain. JCM
 *
 * Title:  ccheck
 *
 * Purpose: To find and report all badly matched openers and
 *   closers plus assignment/equality confusions
 *   in a c source file.
 *
 *
 * Author:  Steve Draper, expanding cnest by Tom Anderson
 *
 * Usage:  ccheck [-q] [-v] <filename1> <filename2> ...
 *
 * History (in reverse order to minimize reading time for updates):
 *
 *   June 13, 1994 Jason Petty
 *   - Must get valid file name else exits with usage.
 *     Changes marked VANSOFT.
 *
 *
 *   April 8, 1986  Converted to Amiga Lattice C from from butchered text
 *                  file.  If any one can supply me with the original source
 *                  I would appreciate it.  IF-ELSE check seems flaky.
 *  
 *                           Thom Althoff (BIX althoff)
 *                       c/o American Broadcasting Companies
 *                           30 W. 67th St Video Tape Tech Support 
 *                           Floor B1
 *                           New York City, N.Y. 10023
 *
 *
 *   June 18, 1985  Converted to Aztec C - removed BDS C code  -  Rick Moore
 *
 *   January 9, 1983  Single BDS/UNIX source created
 *      as CCHECK.C  -- Jeff Martin
 *
 *   December 29, 1982 Adapted for BDS C --
 *       Jeff Martin at home.
 *
 *   December 20, 1982 Converted to cchk --
 *       Steve Draper at UCSD
 *
 *   December 9, 1982 Jeffrey Mogul at Stanford
 *    - checks for unclosed comment at end of file.
 *
 *   December 3, 1982 creation date --
 *      Tom Anderson at microsof!fluke
 *
 */

#include <stdio.h>
#include <ctype.h>

#define TRUE 1
#define FALSE 0
#define SPACE 32

#define BRACE 1
#define SQBRAK  2
#define PAREN 3
#define IF 4
#define IFCOND 5
#define WHLCOND 6
#define THEN 7
#define ELSE 8

#define STACKSIZ 64

struct brak
{
    int type, b_indent, b_ln;
} stack[STACKSIZ];

#define rmbrak(N) (top -= N, stackc -= N)
#define myungetc(C)  ungetc(((C) == '\n' ? SPACE : (C)), infile)

#define VFLAG "-v"
#define QFLAG "-q"
#define SFLAG "-s"

int firsttime; /* This was a static in mygetchar() */

int mygetchar(), pr();
void checkelse(), newbrak(), checkcloser(), prtype();
void usage();

FILE *infile;
int ln, indent, commindent, stackc, commln;
int singlequoterr, oddsinglequote, bracecnt, parencnt, sqbrakcnt;
int errstatus, wstatus;
int errnmb, wnmb;
int verbose;
char *filename;
struct brak *top;

void usage(op) /* Added, VANSOFT. */
int op;
{
  printf(
  "\n\n\nCCHECK: Copyright - The Regents of the University of California.\n");
  printf("Author: Steve Draper.\n\n");
  printf("Purpose: To find and report all badly matched openers and\n");
  printf(
  "closers plus assignment/equality confusions in a c source file.\n\n");

  printf("USAGE:  CCHECK [-q] [-v] <filename1> <filename2> ...\n\n");
  printf("Flags:\n");
  printf("\t-q   -  Suppress warning messages.\n");
  printf("\t-v   -  Verbose.\n\n\n");

 if(!op)
  exit(10); /* Exit error. */
}

main(argc, argv)
unsigned argc ;
char *argv[] ;
{
    register int c;
    int i;
    int doubleqflag;
    unsigned file_index;

    wnmb = 0;
    verbose = 0;
    file_index = 1;

    while (argc > 1  &&  argv[file_index][0] == '-')
       {
        if (strcmp(argv[file_index], VFLAG) == 0)
            verbose++;
        if (strcmp(argv[file_index], QFLAG) == 0)
            wnmb = -2;
        if (strcmp(argv[file_index], SFLAG) == 0)
            wnmb = -2;
        file_index++;
        argc--;
       }

    do
     {
        /* INIT for each file */
        firsttime = 1;
        doubleqflag = 0;
        errstatus = wstatus = 0;
        ln = 1;
        indent = 0;
        commindent = 0;
        singlequoterr = oddsinglequote = parencnt = sqbrakcnt = bracecnt = 0;
        errnmb = 0;
        if (wnmb > -2)
            wnmb = 0;
        newbrak(0);

        if (argc == 1 || argc == 0)
          {
            usage(NULL); /* usage. Added, VANSOFT. */
           }
        else
         {
          if ((infile = fopen(argv[file_index], "r")) == (FILE * ) NULL)
           {
            usage(1); /* 1 = don't 'exit()' yet. (usage. Added,VANSOFT) */
     fprintf(stdout, "%s: Can't access %s!\n\n",argv[0],argv[file_index]);
            exit(10); /* exit error. */ 
            }
           filename = argv[file_index]; 
          }
 
        while ( ( c = mygetchar()) !=  EOF )
           {
            if (verbose == 2)
               {
                for (i = stackc; i > 0; i--)
                  {
            printf("%c %d: type ", c, i);
            prtype(stack[i].type);
            printf(", indent %d, line %d.\n",stack[i].b_indent,stack[i].b_ln);
                  }
               }

            switch (c)
            {
            case ';':
                ungetc(SPACE, infile);
                while (top->type == ELSE)
                    rmbrak(1);
                if (top->type == THEN)
                {
                    rmbrak(1);
                    checkelse();
                }
                break;

            case '!':
            case '>':
            case '<':
                /* swallow legit. '=' chars */
                c = mygetchar();
                if (c != '=')
                    myungetc(c);
                break;

            case '=':
                if ((top - 1)->type == IFCOND  ||  (top - 1)->type == WHLCOND)
                   {
                    c = mygetchar();
                    if (c != '=')
                      {
                        myungetc(c);
              if(pr(1))
               printf("Assignment instead of equals in conditional,%d\n", ln);
                    }
                }
                break;

            case '\n':
            case SPACE:
                c = mygetchar();
                switch (c) {
                case 'i':
                    /* if */
                    c = mygetchar();
                  if (c == 'f' && !isalpha(c = fgetc(infile)) && !isdigit(c))
                      {
                        ungetc(c, infile);
                        newbrak(IF);
                        while ((c = mygetchar()) == SPACE ||  c == '\n');
                        if (c != '(')
                        {
                            if (pr(1))
                                printf("Bad if (no condition) line %d.\n",ln);
                            rmbrak(1);
                        }
                        else
                            newbrak(IFCOND);
                            myungetc(c);
                    }
                        else
                        myungetc(c);
                    break;
                case 'w':
                    /* while */
                    if ((c = mygetchar()) == 'h'
                      &&  (c = mygetchar()) == 'i'
                      &&  (c = mygetchar()) == 'l'
                      &&  (c = mygetchar()) == 'e'
                      &&  !isalpha(c = fgetc(infile))  &&  !isdigit(c))
                      {
                        ungetc(c, infile);
                        while ((c = mygetchar()) == SPACE ||  c == '\n');
                        if (c != '(')
                         {
                        if(pr(1))
                           printf("Bad while (no condition) line %d.\n",ln);
                        }
                        else
                            newbrak(WHLCOND);
                            myungetc(c);
                    }
                    else
                        myungetc(c);
                    break;
                case 'e':
                    /* else */
                    myungetc(c);
                    checkelse();
                    break;

                default:
                    myungetc(c);
                    break;
                }
                break;

            case '*':
                /* close comment ? */
                c = mygetchar();
                if (c != '/')
                {
                    myungetc(c);
                    break;
                }

   if(pr(1))
      printf("Line %d: Comment close without open, indent %d\n",ln, indent);

                break;

            case '\'':
             if((c = fgetc(infile)) != '\\')
                {
                    if (c == '\''  ||  (c = fgetc(infile)) != '\'')
                    {
                        if (pr(1))
                            printf("Bad character constant line %d\n", ln);
                        singlequoterr = 1;
                     }
                }
               else 
                {
                   if(!isdigit(c = fgetc(infile)))
                    {
                     if((c = fgetc(infile)) != '\'')
                        {
                     if(pr(1))
                        printf("Bad character constant with \\ line %d\n",ln);
                        }
                     } 
                   else
                     {
                    if(isdigit(c = fgetc(infile)))
                        if(isdigit(c = fgetc(infile)))
                           c = fgetc(infile);
                    if(c != '\'')
                        if(pr(1))
                       printf("Bad character constant with \\0 line %d\n",ln);
                      }
                 }
                if(c != '\'')
                  {
                    ungetc(c, infile);
                    oddsinglequote = !oddsinglequote;
                    singlequoterr = 1;
                   }
                break;

            case '"':
                do
                {
                    c = fgetc(infile);
                    if (c == EOF)
                    {
              if(pr(2))
                printf("Error: '\"' quoted string not ended on line %d\n",ln);
                            break;
                    }
                    else
             if (c == '\n')
                {
              if(doubleqflag == 0)
                if(pr(0))
                printf("Warning: '\"' quoted string not ended on line %d",ln);
                        doubleqflag = 1;
                        ln++;
                }
               else
                    if (c == '\\')
                      {
                        c = SPACE;
                        fgetc(infile);
                      }
                }
                while (c != '"');
                doubleqflag = 0;
                break;

            case '{':
                if (stackc  &&  indent < top->b_indent)
                    if (pr(0))
                        printf("Indent jumps backwards line %d.\n", ln);
                newbrak(BRACE);
                break;

            case '}':
                checkcloser(BRACE);
                while (top->type == ELSE)
                    rmbrak(1);
                if (top->type == THEN)
                {
                    rmbrak(1);
                    checkelse();
                }
                break;

            case '(':
                if (stackc  &&  indent < top->b_indent)
                    if (pr(0))
                        printf("Indent jumps backwards line %d.\n", ln);
                newbrak(PAREN);
                break;

            case ')':
                checkcloser(PAREN);
                if (top->type == IFCOND)
                {
                    rmbrak(1);
                    newbrak(THEN);
                }
                else
                if (top->type == WHLCOND)
                    rmbrak(1);
                break;

            case '[':
                if (stackc  &&   indent < top->b_indent)
                    if (pr(0))
                        printf("Indent jumps backwards line %d.\n", ln);
                newbrak(SQBRAK);
                break;

            case ']':
                checkcloser(SQBRAK);
                break;

            default:
                break;

            }
        }

        fclose(infile);

        while (stackc > 0)
        {
            pr(2);
            fputs("Unclosed brak at EOF: ", stdout);
            prtype(top->type);
            printf(" opened on line %d.\n", top->b_ln);
            switch (top->type)
            {
            case BRACE:
                bracecnt++;
                break;
            case SQBRAK:
                sqbrakcnt++;
                break;
            case PAREN:
                parencnt++;
                break;
            default:
                break;
            }
            rmbrak(1);
        }

 if((i = (oddsinglequote || bracecnt || sqbrakcnt || parencnt)) || errstatus)
        {
            pr(2);
            printf("Summary:\n");
        }
        else
        {
            if (filename != NULL)
            {
                fputs(filename, stdout);
                fputs(": ", stdout);
            }
            printf(" OK\n");
        }
        if (oddsinglequote)
            printf("\tOdd number of single quotes.\n");
        if (bracecnt)
            printf("\t%d too few %s braces.\n", abs(bracecnt), 
                    (bracecnt > 0 ? "closing" : "opening"));
        if (sqbrakcnt)
            printf("\t%d too few %s square brackets.\n", abs(sqbrakcnt),
                   (sqbrakcnt > 0 ? "closing" : "opening"));
        if (parencnt)
            printf("\t%d too few %s parentheses.\n", abs(parencnt), 
                   (parencnt > 0 ? "closing" : "opening"));
        if (errstatus && !i)
            printf("\tPossible error(s), but no net delimiter imbalance.\n");
        putchar('\n');
    }
    while (++file_index < argc);

    exit(errstatus ? 2 : wstatus);
}

int mygetchar()
{
    register int c;

    c = fgetc(infile);

    /*
    if (c == ';') {
        ungetc(SPACE, infile);
        return(';');
    }
    */
    if (c == '/') {    /* open comment ? */
        c = fgetc(infile);
        if (c != '*')
        {
            ungetc(c, infile);
            return('/');
        }
        commln = ln;
        commindent = indent;

        while (1)
        {
            c = fgetc(infile);

            if (c == EOF)
            {   /* last comment never ended */
                if(pr(2))
                   printf("Comment opened line %d unclosed by end of file.\n",
                            commln);
                break; /* Get out of this loop! */
            }
            else
            if (c == '/') {  /* nested comment ? */
                if ((c = fgetc(infile)) == '*')
                {
              if (pr(0))
                  fprintf(stdout,
      "Nested comment: line %d, indent %d.  First open: line %d indent %d\n", 
                       ln, indent, commln, commindent);
                }
                else
                    ungetc(c, infile);
            } else if (c == '*') {  /* end comment ? */
                if ((c = fgetc(infile)) == '/')
                {
                    if (indent != commindent  &&  indent - 1 != commindent)
                        if (pr(0))
                            printf(
 "Indent of comment close doesn't match open: lines %d, %d indents %d, %d\n", 
                                   commln, ln, commindent, indent);

                    break;    /* only exit from loop, except EOF */
                }
                else
                    ungetc(c, infile);
            }
            else
            if (c == '\n')
            {
                do
                {                  
                  if (c == SPACE)
                        indent++;
                    else
                    if (c == '\t')                    
                        indent = ((indent + 8) / 8) * 8;
                    else if (c == '\n')
                    {
                        ln++;
                        indent = 0;
                    }
                }
                while (isspace(c = fgetc(infile)));
                ungetc(c, infile);
            }
        }
        return(SPACE);

    }

    if (c == '\n'  ||  firsttime == 1)
    {
        firsttime = 0;
lf:
        while (1)
        {
            if (c == SPACE)
                indent++;
            else if (c == '\t')
                indent = ((indent + 8) / 8) * 8;
            else if (c == '\n')
            {
                ln++;
                indent = 0;
                singlequoterr = 0;
            } else
            {
                ungetc(c, infile);
                return('\n');
                /*NOTREACHED*/
                break;
            }
            c = fgetc(infile);
        }
    }

    if (c == SPACE  ||  c == '\t')
    {
        do
        
            c = fgetc(infile);
        while (c == SPACE  ||  c == '\t');
        if (c != '\n')
        {
            ungetc(c, infile);
            return(SPACE);
        }
        else
            goto lf;
    }
    return(c);
}

/*
 * administer count of error msgs. and suppress if too many
 * administer the status var.s
 * prepend file name to msg.
 * flag error msg.s (not warnings) with '*'
 */
int pr(error)
int error;
{
    int i;

    if (singlequoterr)
        return(0);

    if (verbose)
      {
        for (i = stackc; i > 0; i--)
        {
         printf("%d: type ", i);
         prtype(stack[i].type);
         printf(", indent %d, line %d.\n", stack[i].b_indent, stack[i].b_ln);
         }
      }

    if (error == 2)
      {
        errnmb = 0;
        errstatus = 1;
      }
    else
    
    if (error)
       {
        errstatus = 1;
        if (errnmb < 0)
            return(0);
            
        else
        if (errnmb >= 9)
          {
            errnmb = -1;
            printf("Other error messages being suppressed.\n");
            return(0);
          }
        }
    else
    {
        wstatus = 1;
        if (wnmb < 0)
            return(0);
        else if (errnmb + wnmb >= 9)
          {
            wnmb = -1;
            puts("Further warning messages being suppressed.\n");
            return(0);
          }
     }

    if (filename != NULL)
      {
        fputs(filename, stdout);
        fputs(": ", stdout);
      }
    if (error)
        putchar('*');
    if (error)
        errnmb++;
    else
        wnmb++;
    return(1);
}

void newbrak(newtype)
int newtype;
{
    if (newtype == 0)
      {
        top = stack;
        stackc = 0;
      }
    else
      {
        top++;
        stackc++;
      }
      
    if (stackc >= STACKSIZ)
       {
        if (pr(2))
         {
           printf("***stack overflow, line %d.\n", ln);
         }  
        exit(3);
       }

    top->type = newtype;
    top->b_indent = indent;
    top->b_ln = ln;

}

void prtype(typ)
int typ;
{
    switch (typ)
    {
    case BRACE:
        putchar('}');
        break;
    case PAREN:
        putchar(')');
        break;
    case SQBRAK:
        putchar(']');
        break;
    case IF:
        fputs("if", stdout);
        break;
    case IFCOND:
        fputs("if-condition", stdout);
        break;
    case THEN:
        fputs("then", stdout);
        break;
    case ELSE:
        fputs("else", stdout);
        break;
    case WHLCOND:
        fputs("while-condition", stdout);
        break;
    default:
        fputs("'NULL'", stdout);
        break;
    }
}

void checkcloser(typ)
int typ;
{
    int i, found;

    i = found = 0;
    if (typ == top->type  &&  top->b_indent == indent)
    {
        rmbrak(1);
        return;
    }
    
    while (!found  &&  ++i < stackc  &&  indent <= (top - i)->b_indent)
        if (typ == (top - i)->type  &&  (top - i)->b_indent == indent)
            found = 1;

    if (found)
    {
     if(pr(1))
        printf("Missing closer%s detected line %d:\n", (i > 1 ? "s" :""), ln);
        while (i--)
        {
            if (pr(1))
            {
                fputs("\tMissing closing ", stdout);
                prtype(top->type);
                printf(" opened line %d.\n", top->b_ln);
            }
            switch (top->type)
            {
            case BRACE:
                bracecnt++;
                break;
            case SQBRAK:
                sqbrakcnt++;
                break;
            case PAREN:
                parencnt++;
                break;
            default:
                break;
            }
            rmbrak(1);
        }
        rmbrak(1); /* the matching brak */
    }
    else
    if (typ == top->type)
    {
        if (indent != top->b_indent)
        {
            if (pr(0)) {
                fputs("Mismatched indent on closing ", stdout);
                prtype(typ);
                printf(" lines %d, %d; indents %d, %d.\n",
                  top->b_ln, ln, top->b_indent, indent);
            }
        }
        rmbrak(1);
    }
      else
      {
        switch (typ)
        {
        case BRACE:
            bracecnt--;
            break;
            case SQBRAK:
            sqbrakcnt--;
            break;
        case PAREN:
            parencnt--;
            break;
        default:
            break;
        }

        if (pr(1))
        {
            fputs("Muddle detected at unmatched closing ", stdout);
            prtype(typ);
            printf(" line %d.\n", ln);
        }
    }
}

/*
 * removes IF from stack
 * checks else's indent
 */
void checkelse()
{
    int c;

    while ((c = mygetchar()) == SPACE  || c == '\n');
    if (c == 'e' &&  (c = mygetchar()) == 'l' &&  (c = mygetchar()) == 's' &&
       (c = mygetchar()) == 'e' &&  !isalpha(c = fgetc(infile)) &&
       !isdigit(c))
      {
        ungetc(c, infile);
        if (top->type == THEN)
            rmbrak(1);
        if (top->type != IF)
        {
            if (pr(1))
                printf("Else with no if line %d.\n", ln);
        }
          else
          if (indent + 2 < top->b_indent)
          {
            if (pr(1))
                printf(
    "Dangling else -- bound to wrong if?  \"if\" line %d, \"else\" line %d\n",
                       top->b_ln, ln);
          }
          else
          if (indent != top->b_indent)
          {
            if (pr(0))
            {
                fputs("Wrong indent for else", stdout);
                if (indent - 2 >  top->b_indent)
                    fputs(" missing if?", stdout);
            printf(".  \"if\" line %d, \"else\" line %d.\n", top->b_ln,ln);
            }
        }

        if (top->type == IF)
            rmbrak(1);
        newbrak(ELSE);
    }
    else
    {
        myungetc(c);
        ungetc(SPACE, infile);  /* BUG?? */
        /* no else so terminate the IF */
        if (top->type == IF)
        {
            rmbrak(1);
            while (top->type == ELSE)
                rmbrak(1);
            if (top->type == THEN)
            {
                rmbrak(1);
                checkelse();
            }
        }
    }
}

/*  This function is included because Aztec C does not include an "abs"
    function.  If your library contains this function, this code can be    
    deleted.
*/
int abs(i)
{
    int c;

    return((i < 0) ? -i : i);
}

                              