/** \file
 * Copyright (c) 1999 Carlo Wood.  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef INDENT_LEXI_H
#define INDENT_LEXI_H

#include "sys.h" /* for RCSTAG_H */

RCSTAG_H (lexi, "$Id$");

typedef enum rwcodes
{
  rw_none,
  rw_operator,			/*!< For C++ operator overloading. */
  rw_break,
  rw_switch,
  rw_case,
  rw_struct_like,		/*!< struct, union */
  rw_enum,
  rw_decl,
  rw_sp_paren,			/*!< if, while, for */
  rw_sp_nparen,			/*!< do */
  rw_sp_else,			/*!< else */
  rw_sizeof,
  rw_return
} rwcodes_ty;

typedef enum codes
{
  code_eof = 0,			/*!< end of file */
  newline,
  lparen,			/*!< '(' or '['.  Also '{' in an
				   initialization.  */
  rparen,			/*!< ')' or ']'.  Also '}' in an
				   initialization.  */
  start_token,
  unary_op,
  binary_op,
  postop,

  question,
  casestmt,
  colon,
  doublecolon,			/*!< For C++ class methods. */
  semicolon,
  lbrace,
  rbrace,

  ident,			/*!< string or char literal,
				   identifier, number */

  overloaded,			/*!< For C++ overloaded operators (like +) */
  cpp_operator,

  comma,
  comment,			/*!< A "slash-star" comment */
  cplus_comment,		/*!< A C++ "slash-slash" */
  swstmt,
  preesc,			/*!< '#'.  */

  form_feed,
  decl,

  sp_paren,			/*!< if, for, or while token */
  sp_nparen,			/*!< do */
  sp_else,			/*!< else */
  ifstmt,
  elseifstmt,
  whilestmt,

  forstmt,
  stmt,
  stmtl,
  elselit,
  dolit,
  dohead,
  dostmt,
  ifhead,

  elsehead,
  struct_delim,			/*!< '.' or "->" */

  attribute,			/*!< The '__attribute__' qualifier */
  number_of_codes
} codes_ty;

extern void addkey(
   char *key, 
   rwcodes_ty val);

extern codes_ty lexi(void);
extern void cleanup_user_specials(void);

#endif /* INDENT_LEXI_H */
