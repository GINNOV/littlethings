/* A Bison parser, made by GNU Bison 2.6.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     identifier = 258,
     constant = 259,
     stringcomp = 260,
     builtinfun = 261,
     typeword = 262,
     storageclass = 263,
     typedefkeyw = 264,
     typequal = 265,
     externlang = 266,
     cppdirect = 267,
     enumkeyw = 268,
     structkeyw = 269,
     ifkeyw = 270,
     elsekeyw = 271,
     whilekeyw = 272,
     dokeyw = 273,
     forkeyw = 274,
     switchkeyw = 275,
     casekeyw = 276,
     defaultkeyw = 277,
     breakkeyw = 278,
     continuekeyw = 279,
     returnkeyw = 280,
     gotokeyw = 281,
     asmkeyw = 282,
     sizeofop = 283,
     typeofop = 284,
     ellipsis = 285,
     dosasmstmt = 286,
     assignop = 287,
     equalop = 288,
     relop = 289,
     shift = 290,
     plusplus = 291,
     logand = 292,
     logor = 293,
     arrow = 294,
     atdefs = 295,
     atselector = 296,
     atinterface = 297,
     atend = 298,
     atencode = 299,
     atrequires = 300,
     blockbegin = 301,
     gnuextension = 302,
     attributekeyw = 303,
     unary = 304,
     hyperunary = 305
   };
#endif
/* Tokens.  */
#define identifier 258
#define constant 259
#define stringcomp 260
#define builtinfun 261
#define typeword 262
#define storageclass 263
#define typedefkeyw 264
#define typequal 265
#define externlang 266
#define cppdirect 267
#define enumkeyw 268
#define structkeyw 269
#define ifkeyw 270
#define elsekeyw 271
#define whilekeyw 272
#define dokeyw 273
#define forkeyw 274
#define switchkeyw 275
#define casekeyw 276
#define defaultkeyw 277
#define breakkeyw 278
#define continuekeyw 279
#define returnkeyw 280
#define gotokeyw 281
#define asmkeyw 282
#define sizeofop 283
#define typeofop 284
#define ellipsis 285
#define dosasmstmt 286
#define assignop 287
#define equalop 288
#define relop 289
#define shift 290
#define plusplus 291
#define logand 292
#define logor 293
#define arrow 294
#define atdefs 295
#define atselector 296
#define atinterface 297
#define atend 298
#define atencode 299
#define atrequires 300
#define blockbegin 301
#define gnuextension 302
#define attributekeyw 303
#define unary 304
#define hyperunary 305



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
