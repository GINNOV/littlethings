#ifdef AMIGA
char v[] = "\0$VER: 1.0A (04-Aug-2002) by J.T. Steichen\0";
#endif
#define NUMBER 257
#define HEXSTRING 258
#define EXIT 259
#define OR 260
#define AND 261
#define EOL 262
#define PLUS 263
#define MINUS 264
#define STAR 265
#define SLASH 266
#define PERCENT 267
#define LPAREN 268
#define RPAREN 269
#define XOR 270
#define EQUAL 271
#define YYEOF 272
#define BITINVERT 273
#define LSHIFT 274
#define RSHIFT 275
#define DOLLAR 276
#define YYERRCODE 256

#include <ctype.h>
#include <stdio.h>

#include <exec/types.h>
#include <AmigaDOSErrs.h>

#define   CATCOMP_ARRAY 1
#include "MyCalcLocale.h"

#include <StringFunctions.h>

#include "CPGM:GlobalObjects/CommonFuncs.h"

IMPORT struct Catalog *catalog;

/*  Perhaps someone else can add floating point support!

float  regs[26] = { 0.0 };     // calculator has 26 memories!
float  val      = 0.0;
*/

int    printflag, exitflag, val = 0;

#ifdef PARSE_DEBUG
# define PDBG( f, v )     fprintf( stderr, f, v )
#else
# define PDBG( f, v )
#endif

extern STRPTR CMsg( int strIndex, STRPTR defaultString );

/*
float ConvToFloat( int arg )
{
   float dummy = arg;
   
   return( dummy );
}

int ConvToInt( float arg )
{
   int dummy = (int) arg;
   
   return( dummy );
}
*/

int BreakPoint( void )
{
   return( 0 );
}

typedef union   {

   char  *y_str;   /* ID     */
   int    y_num;   /* Number */
   float  y_float; /* Float  */

   } YYSTYPE;

// YYSTYPE;

#ifndef  YYCONST
# define YYCONST /* const */
#endif

YYCONST short yylhs[] = {                                -1,
    0,    0,    0,    4,    3,    3,    3,    3,    3,    3,
    3,    3,    3,    3,    3,    3,    5,    5,    2,    1,
    1,    1,    1,    1,    1,    6,    7,
};

YYCONST short yylen[] = {                                 2,
    1,    2,    3,    2,    1,    3,    3,    3,    3,    3,
    3,    3,    3,    3,    3,    3,    0,    1,    1,    1,
    1,    2,    2,    2,    2,    1,    1,
};

YYCONST short yydefred[] = {                              0,
   20,   21,    0,    0,   26,    0,    0,   19,    5,    0,
    1,    0,    4,   24,   25,   22,   23,    0,    0,   18,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    9,   10,   11,    0,    0,    0,
    3,   27,    6,
};

YYCONST short yydgoto[] = {                               7,
    8,    9,   10,   11,   29,   12,   43,
};

YYCONST short yysindex[] = {                           -230,
    0,    0, -254, -246,    0, -225,    0,    0,    0, -207,
    0, -227,    0,    0,    0,    0,    0, -227, -227,    0,
 -227, -227, -227, -227, -227, -227, -227, -227, -244, -189,
 -261, -169, -201, -201,    0,    0,    0, -174, -216, -216,
    0,    0,    0,
};

YYCONST short yyrindex[] = {                              0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    7,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   36,    0,
   39,   69,    1,   18,    0,    0,    0,   73,   35,   52,
    0,    0,    0,
};

YYCONST short yygindex[] = {                              0,
    0,    0,   -2,   11,    0,    0,    0,
};

#define	YYTABLESIZE		343

YYCONST short yytable[] = {                              19,
    7,   21,   22,   23,   24,   25,   17,   13,   26,   30,
   14,   15,   27,   28,    3,   31,   32,    8,   33,   34,
   35,   36,   37,   38,   39,   40,    1,    2,    3,    1,
    2,   16,   17,    4,   15,    2,    4,    5,   12,   41,
    5,    0,    6,    0,    0,    6,   21,   22,   23,   24,
   25,   16,   18,   19,   20,   21,   22,   23,   24,   25,
    0,    0,   26,   23,   24,   25,   27,   28,   13,    0,
   18,   19,   14,   21,   22,   23,   24,   25,    0,   42,
   26,    0,    0,    0,   27,   28,   19,    0,   21,   22,
   23,   24,   25,   21,   22,   23,   24,   25,    0,   27,
   28,    0,    0,    0,   27,   28,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    7,
    7,    7,    7,    7,    7,   17,    0,    0,    0,    7,
    7,    0,    0,    0,    7,    7,    8,    8,    8,    8,
    8,    8,    0,    0,    0,    0,    8,    8,    0,    0,
    0,    8,    8,   15,   15,   15,   15,   12,   12,    0,
   12,    0,    0,   15,   15,    0,    0,   12,   15,   15,
   16,   16,   16,   16,    0,    0,    0,    0,    0,    0,
   16,   16,    0,    0,    0,   16,   16,   13,   13,   13,
   13,   14,   14,    0,   14,    0,    0,   13,   13,    0,
    0,   14,   14,
};

YYCONST short yycheck[] = {                             261,
    0,  263,  264,  265,  266,  267,    0,  262,  270,   12,
  257,  258,  274,  275,  259,   18,   19,    0,   21,   22,
   23,   24,   25,   26,   27,   28,  257,  258,  259,  257,
  258,  257,  258,  264,    0,    0,  264,  268,    0,   29,
  268,   -1,  273,   -1,   -1,  273,  263,  264,  265,  266,
  267,    0,  260,  261,  262,  263,  264,  265,  266,  267,
   -1,   -1,  270,  265,  266,  267,  274,  275,    0,   -1,
  260,  261,    0,  263,  264,  265,  266,  267,   -1,  269,
  270,   -1,   -1,   -1,  274,  275,  261,   -1,  263,  264,
  265,  266,  267,  263,  264,  265,  266,  267,   -1,  274,
  275,   -1,   -1,   -1,  274,  275,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  259,
  260,  261,  262,  263,  264,  259,   -1,   -1,   -1,  269,
  270,   -1,   -1,   -1,  274,  275,  259,  260,  261,  262,
  263,  264,   -1,   -1,   -1,   -1,  269,  270,   -1,   -1,
   -1,  274,  275,  259,  260,  261,  262,  259,  260,   -1,
  262,   -1,   -1,  269,  270,   -1,   -1,  269,  274,  275,
  259,  260,  261,  262,   -1,   -1,   -1,   -1,   -1,   -1,
  269,  270,   -1,   -1,   -1,  274,  275,  259,  260,  261,
  262,  259,  260,   -1,  262,   -1,   -1,  269,  270,   -1,
   -1,  269,  270,
};

#define YYFINAL 7

#ifndef YYDEBUG
#define YYDEBUG 1
#endif

#define YYMAXTOKEN 276
#if YYDEBUG

YYCONST char *yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"NUMBER","HEXSTRING","EXIT","OR",
"AND","EOL","PLUS","MINUS","STAR","SLASH","PERCENT","LPAREN","RPAREN","XOR",
"EQUAL","YYEOF","BITINVERT","LSHIFT","RSHIFT","DOLLAR",
};

YYCONST char *yyrule[] = {
"$accept : statement",
"statement : exitstmt",
"statement : binary eol",
"statement : binary eol exitstmt",
"exitstmt : EXIT EOL",
"binary : number",
"binary : lp binary rp",
"binary : binary PLUS binary",
"binary : binary MINUS binary",
"binary : binary STAR binary",
"binary : binary SLASH binary",
"binary : binary PERCENT binary",
"binary : binary OR binary",
"binary : binary AND binary",
"binary : binary XOR binary",
"binary : binary LSHIFT binary",
"binary : binary RSHIFT binary",
"eol :",
"eol : EOL",
"number : integer",
"integer : NUMBER",
"integer : HEXSTRING",
"integer : BITINVERT NUMBER",
"integer : BITINVERT HEXSTRING",
"integer : MINUS NUMBER",
"integer : MINUS HEXSTRING",
"lp : LPAREN",
"rp : RPAREN",
};
#endif

#define yyclearin (yychar = (-1))
#define yyerrok   (yyerrflag = 0)

#ifndef YYSTACKSIZE
# ifdef YYMAXDEPTH
#  define YYSTACKSIZE YYMAXDEPTH
# else
#  define YYSTACKSIZE 300
# endif
#endif

int      yydebug;
int      yynerrs;
int      yyerrflag;
int      yychar;
short   *yyssp;
YYSTYPE *yyvsp;

YYSTYPE yyval;
YYSTYPE yylval;
#define yystacksize YYSTACKSIZE

short   yyss[ YYSTACKSIZE ];
YYSTYPE yyvs[ YYSTACKSIZE ];

#ifdef PARSE_DEBUG

void yyerror( char *s )  {  printf( CMsg( MSG_FMT_PARSE_ERROR, MSG_FMT_PARSE_ERROR_STR ), s );  }

void main( int argc, char **argv )
{
   exitflag = 0;

   if (argc == 2)
      yydebug = 1;
     
   for ( ; ; )
      {
      printflag = 1;

      if (yyparse() == 0 && printflag != 0)
         {
         printf( CMsg( MSG_FMT_PARSE_RESULT, MSG_FMT_PARSE_RESULT_STR ), val );

         printflag = 0;
         }

      if (exitflag == 1)
         return;
      }

   return;
}

#else

#include "CPGM:GlobalObjects/CommonFuncs.h"

void yyerror( char *s )
{
   UserInfo( s, CMsg( MSG_CHECK_EXPRESSION_RQTITLE, MSG_CHECK_EXPRESSION_RQTITLE_STR ) );
   
   return;
}

IMPORT char *TTTempFile;

IMPORT int yyin;

PUBLIC int Calculate( char *expr )
{
   char  ErrMsg[512] = { 0, };
   
   int   rval  = 0;
   FILE *tfile = OpenFile( TTTempFile, "w" );
   
   if (!tfile) // == NULL)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_NO_FILE_WRITE, MSG_FMT_NO_FILE_WRITE_STR ), TTTempFile );
      
      UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM_RQTITLE, MSG_SYSTEM_PROBLEM_RQTITLE_STR ) );
      
      return( -1 );
      }
   else
      {
      StringCopy( ErrMsg, expr );

      StringCat( ErrMsg, "\nQ\n" );
      
      fputs( ErrMsg, tfile );

      fclose( tfile );
      
      if (!(tfile = OpenFile( TTTempFile, "r" ))) // == NULL)
         {
         sprintf( ErrMsg, CMsg( MSG_FMT_NO_FILE_READ, MSG_FMT_NO_FILE_READ_STR ), TTTempFile );
      
         UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM_RQTITLE, MSG_SYSTEM_PROBLEM_RQTITLE_STR ) );
      
         return( -1 );
         }

      yyin = (int) tfile;
      
      yyparse();
      
      fclose( tfile );
      
      yyin = (int) stdin; /* Just in case */
      
      rval = val;
      }

   return( rval );      
}

#endif

/* ------------ END of Calc.y file! ----------------- */
#define YYACCEPT goto yyaccept
#define YYERROR goto yyerrlab

int yyparse( void )
{
    register int yym, yyn, yystate;

#   if YYDEBUG
    register char *yys;
    extern char *getenv();

    if (yys = getenv("YYDEBUG"))
       {
       yyn = *yys;

       if (yyn == '0')
          yydebug = 0;
       else if (yyn >= '1' && yyn <= '9')
          yydebug = yyn - '0';
       }
#   endif

    yynerrs   = 0;
    yyerrflag = 0;
    yychar    = (-1);
    yyssp     = yyss;
    yyvsp     = yyvs;

    *yyssp    = yystate = 0;

yyloop:

    if (yyn = yydefred[ yystate ])
       goto yyreduce;

    if (yychar < 0) // Need more tokens??
       {
       if ((yychar = yylex()) < 0)
          yychar = 0;

#      if YYDEBUG
       if (yydebug)
          {
          yys = 0;

          if (yychar <= YYMAXTOKEN)
             yys = yyname[ yychar ];

          if (yys == 0)
             yys = "illegal-symbol";

          printf( "yydebug: state %d, reading %d (%s)\n", yystate,
                    yychar, yys );
          }
#      endif
       }

    if ((yyn = yysindex[ yystate ]) 
       && (yyn += yychar) >= 0
       && yyn <= YYTABLESIZE 
       && yycheck[ yyn ] == yychar)
       {
#      if YYDEBUG
       if (yydebug)
          printf( "yydebug: state %d, shifting to state %d\n",
                    yystate, yytable[yyn] );
#      endif

       if (yyssp >= yyss + yystacksize - 1)
          {
          goto yyoverflow;
          }

       *++yyssp = yystate = yytable[ yyn ];
       *++yyvsp = yylval;
       yychar   = (-1); // Set Flag for more tokens.

       if (yyerrflag > 0)
          --yyerrflag;

       goto yyloop;
       }

    if ((yyn = yyrindex[ yystate ])
       && (yyn += yychar) >= 0
       && yyn <= YYTABLESIZE
       && yycheck[ yyn ] == yychar)
       {
       yyn = yytable[ yyn ];

       goto yyreduce;
       }

    if (yyerrflag) 
       goto yyinrecovery;

yynewerror:
    yyerror( "syntax error" );

yyerrlab:
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
       {
       yyerrflag = 3;

       for ( ; ; )
          {
          if ((yyn = yysindex[ *yyssp ])
             && (yyn += YYERRCODE) >= 0
             && yyn <= YYTABLESIZE
             && yycheck[ yyn ] == YYERRCODE)
             {
#            if YYDEBUG
             if (yydebug)
                printf( "yydebug: state %d, error recovery shifting\
 to state %d\n", *yyssp, yytable[yyn] );
#            endif

             if (yyssp >= yyss + yystacksize - 1)
                {
                goto yyoverflow;
                }

             *++yyssp = yystate = yytable[yyn];
             *++yyvsp = yylval;

             goto yyloop;
             }
          else
             {
#            if YYDEBUG
             if (yydebug)
                printf( "yydebug: error recovery discarding state %d\n",
                         *yyssp );
#            endif

             if (yyssp <= yyss)
                goto yyabort;

             --yyssp;
             --yyvsp;
             }
          }
       }
    else
       {
       if (yychar == 0)
          goto yyabort;

#      if YYDEBUG
       if (yydebug)
          {
          yys = 0;
          if (yychar <= YYMAXTOKEN)
             yys = yyname[ yychar ];

          if (yys == 0)
             yys = "illegal-symbol";

          printf( "yydebug: state %d, error recovery discards token %d (%s)\n",
                    yystate, yychar, yys);
          }
#      endif

       yychar = (-1); // Set flag for more tokens.

       goto yyloop;
       }

yyreduce:

#   if YYDEBUG
    if (yydebug)
       printf( "yydebug: state %d, reducing by rule %d (%s)\n",
                yystate, yyn, yyrule[yyn] );
#   endif

    yym   = yylen[ yyn ];
    yyval = yyvsp[ 1 - yym ];
    switch (yyn)
       {
case 2:
{ PDBG( "Expr RESULT: %d\n", val ); }
break;
case 3:
{ PDBG( "Expr RESULT: %d\n", val ); }
break;
case 4:
{ exitflag = 1; 
               YYACCEPT; 
             }
break;
case 5:
{ val = yyval.y_num ; yyerrok; }
break;
case 6:
{ val = yyval.y_num  = yyvsp[-1].y_num ; yyerrok; }
break;
case 7:
{ val = yyval.y_num  = yyvsp[-2].y_num  + yyvsp[0].y_num ; 
               yyerrok; 
             }
break;
case 8:
{ val = yyval.y_num  = yyvsp[-2].y_num  - yyvsp[0].y_num ; yyerrok; }
break;
case 9:
{ val = yyval.y_num  = yyvsp[-2].y_num  * yyvsp[0].y_num ; 
               yyerrok; 
             }
break;
case 10:
{ if (yyvsp[0].y_num  != 0)
                  { 
                  val = yyval.y_num  = yyvsp[-2].y_num  / yyvsp[0].y_num ;
                  } 
               else
                  {
                  fprintf( stderr, CMsg( MSG_DIVIDE_ZERO_ERROR, MSG_DIVIDE_ZERO_ERROR_STR ) );
                  val = yyval.y_num  = 0;
                  }

               yyerrok; 
             }
break;
case 11:
{ if (yyvsp[0].y_num  != 0)
                  val = yyval.y_num  = yyvsp[-2].y_num  % yyvsp[0].y_num ; 
               else
                  {
                  fprintf( stderr, CMsg( MSG_DIVIDE_ZERO_ERROR, MSG_DIVIDE_ZERO_ERROR_STR ) );
                  val = yyval.y_num  = 0;
                  }

               yyerrok; 
             }
break;
case 12:
{ val = yyval.y_num  = yyvsp[-2].y_num  | yyvsp[0].y_num ; yyerrok; }
break;
case 13:
{ val = yyval.y_num  = yyvsp[-2].y_num  & yyvsp[0].y_num ; 
               yyerrok; 
             }
break;
case 14:
{ val = yyval.y_num  = yyvsp[-2].y_num  ^ yyvsp[0].y_num ; yyerrok; }
break;
case 15:
{ val = yyval.y_num  = yyvsp[-2].y_num  << yyvsp[0].y_num ; yyerrok; }
break;
case 16:
{ val = yyval.y_num  = yyvsp[-2].y_num  >> yyvsp[0].y_num ; yyerrok; }
break;
case 20:
{ yyerrok; }
break;
case 21:
{
               val = yyval.y_num ; /* (void) stch_i( $$, &val ); */
             
               yyerrok; 
             }
break;
case 22:
{ yyval.y_num  = ~yyvsp[0].y_num ; val = yyval.y_num ; }
break;
case 23:
{
               yyval.y_num  = ~yyvsp[0].y_num ; val = yyval.y_num ; /* (void) stch_i( $2, &val ); val = ~val; */

               yyerrok;
             }
break;
case 24:
{ yyval.y_num  = -yyvsp[0].y_num ; val = yyval.y_num ; yyerrok; }
break;
case 25:
{
               yyval.y_num  = -yyvsp[0].y_num ; val = yyval.y_num ; /* (void) stch_i( $2, &val ); val = -val; */
               
               yyerrok; 
             }
break;
case 26:
{ yyerrok; }
break;
case 27:
{ yyerrok; }
break;
       }

    yyssp  -= yym;
    yystate = *yyssp;
    yyvsp  -= yym;
    yym     = yylhs[yyn];

    if (yystate == 0 && yym == 0)
       {
#      ifdef YYDEBUG
       if (yydebug)
          printf( "yydebug: after reduction, shifting from state 0 to\
 state %d\n", YYFINAL );
#      endif

       yystate  = YYFINAL;
       *++yyssp = YYFINAL;
       *++yyvsp = yyval;
       if (yychar < 0) // Need more tokens??
          {
          if ((yychar = yylex()) < 0)
             yychar = 0;

#         if YYDEBUG
          if (yydebug)
             {
             yys = 0;
             if (yychar <= YYMAXTOKEN)
                yys = yyname[ yychar ];

             if (yys == 0)
                yys = "illegal-symbol";

             printf( "yydebug: state %d, reading %d (%s)\n",
                        YYFINAL, yychar, yys );
             }
#         endif
          }

       if (yychar == 0) 
          goto yyaccept;
       goto yyloop;
       }

    if ((yyn = yygindex[ yym ])
       && (yyn += yystate) >= 0
       && yyn <= YYTABLESIZE
       && yycheck[ yyn ] == yystate)
       {
       yystate = yytable[yyn];
       }
    else
       yystate = yydgoto[yym];

#   ifdef YYDEBUG
    if (yydebug)
       printf("yydebug: after reduction, shifting from state %d \
to state %d\n", *yyssp, yystate);
#   endif

    if (yyssp >= yyss + yystacksize - 1)
       {
       goto yyoverflow;
       }

    *++yyssp = yystate;
    *++yyvsp = yyval;
    goto yyloop;

yyoverflow:
    yyerror( "YACC stack overflow" );

yyabort:
    return( 1 );

yyaccept:
    return( 0 );
}
