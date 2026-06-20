
/*
 * Copyright (c) 1998 David Stes.
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published 
 * by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * $Id: util.h,v 1.1.1.1 2000/06/07 21:09:24 stes Exp $
 */

#define YYSTYPE id
extern FILE *yyin;		/* lex.lm global */
extern int yyparse();

FILE *openfile(STR name, STR modfs);
FILE *reopenfile(STR name, STR modfs, FILE * of);

extern int okblock;

id mkcppdirect(char *s);
id mkexprstmt(id expr);
id mklabeledstmt(id label, id stmt);
id mkcasestmt(id keyw, id expr, id stmt);
id mkdefaultstmt(id keyw, id stmt);
id mkifstmt(id keyw, id expr, id stmt);
id mkifelsestmt(id keyw, id expr, id stmt, id ekeyw, id estmt);
id mkswitchstmt(id keyw, id expr, id stmt);
id mkwhilestmt(id keyw, id expr, id stmt);
id mkdostmt(id keyw, id stmt, id wkeyw, id expr);
id mkforstmt(id keyw, id a, id b, id c, id stmt);
id mkgotostmt(id keyw, id label);
id mkcontinuestmt(id keyw);
id mkbreakstmt(id keyw);
id mkreturnstmt(id keyw, id expr);
id mkcastexpr(id a, id b);
id mkcondexpr(id a, id b, id c);
id mkunaryexpr(STR op, id a);
id mksizeof(id a);
id mktypeof(id kw,id a);
id mkaddressof(id a);
id mkdereference(id a);
id mkbinexpr(id a, STR op, id b);
id mkcommaexpr(id a, id b);
id mkrelexpr(id a, STR op, id b);
id mkassignexpr(id a, STR op, id b);
id mkfuncall(id funname, id args);
id mkbuiltincall(id funname, id args);
id mkfunbody(id datadefs, id compound);
void declarefun(id specs, id decl);
void declaremeth(BOOL factory, id decl);
id mkfundef(id specs, id decl, id body);
id mkmethdef(BOOL factory, id decl, id body);
id mkmesgexpr(id receiver, id args);
id mkdecl(id ident);
id mkprecdecl(id tquals, id decl);
id mkarraydecl(id lhs, id ix);
id mkfundecl(id lhs, id args);
id mkprefixdecl(id lhs, id rhs);
id mkpostfixdecl(id lhs, id rhs);
id mkpointer(id specs, id pointer);
id mkbitfielddecl(id decl, id expr);
id mkstardecl(id pointer, id decl);
id mkasmop(id string, id expr);
id mkasmstmt(id keyw, id tqual, id expr, id asmop1, id asmop2, id clobbers);
id mkcompstmt(id lb, id datadefs, id stmtlist, id rb);
id mklist(id c, id s);
id mklist2(id c, id s,id t);
id atdefsaddall(id c, id n);
id mkblockexpr(id lb, id parms, id datadefs, id stmts, id expr, id rb);
id mkclassdef(id keyw, id name, id sname, id ivars, id cvars);
id mkdatadef(id datadef, id specs, id decl, id initializer);
id mkencodeexpr(id name);
id mkenumspec(id keyw, id name, id lb, id list, id rb);
id mkenumerator(id name, id value);
id mkgnuattrib(id anyword, id exprlist);
id mkgnuattribdecl(id keyw, id list);
id mklistexpr(id lb, id x, id rb);
id mktypename(id specs, id decl);
id mkcomponentdef(id cdef, id specs, id decl);
id mkstructspec(id keyw, id name, id lb, id defs, id rb);
id mkkeywarg(id sel, id arg);
id mkkeywdecl(id sel, id cast, id arg);
id mkmethproto(id cast, id usel, id ksel, BOOL varargs);
id mkidentexpr(id name);
id mkconstexpr(id name, id schain);
id mkprecexpr(id expr);
id mkbracedgroup(id expr);
id mkarrowexpr(id array, id ix);
id mkdotexpr(id array, id ix);
id mkindexexpr(id array, id ix);
id mkpostfixexpr(id expr, id pf);
id mkparmdef(id parmdef, id specs, id decl);
id mkparmdeflist(id idents, id parmdefs, BOOL varargs);
id mkselarg(id selarg, id usel, int ncols);
id mkselectorexpr(id expr);

void procextdef(id def);
void finclassdef(void);
void datadefokblock(id datadef, id specs, id decl);

id mkfileinmeth(id classdef, id ivarnames, id ivartypes);
id mkfileoutmeth(id classdef, id ivarnames, id ivartypes);

id mkincrefsmeth(id classdef, id ivarnames, id ivartypes);
id mkdecrefsmeth(id classdef, id ivarnames, id ivartypes);
 
