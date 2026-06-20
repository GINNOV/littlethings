/*  This file is part of GNU cflow
 *  Copyright (C) 1997-2019 Sergey Poznyakoff
 *  
 *  GNU cflow is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  GNU cflow is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/* tokens */
enum {
     LBRACE = '{',
     RBRACE = '}',
     WORD = 257,
     LBRACE0,
     RBRACE0,
     IDENTIFIER,
     EXTERN,
     STATIC,
     TYPEDEF,
     STRUCT,
     MODIFIER,
     OP,
     UNION,
     ENUM,
     MEMBER_OF,
     TYPE,
     STRING,
     PARM_WRAPPER,
     QUALIFIER
};

typedef struct {
    char *str;
} YYSTYPE;

extern YYSTYPE yylval;
extern char *filename;
extern char *canonical_filename;
extern int line_num;

extern int yylex(void);

