#ifndef EXPR_H_
#define EXPR_H_

#include "parser.h"

#define LLONG_RANK  5
#define LONG_RANK   4
#define INT_RANK    3
#define SHORT_RANK  2
#define CHAR_RANK   1

void analyze_primary_expression(ExecNode *e);
void analyze_postfix_expression(ExecNode *e);
void analyze_unary_expression(ExecNode *e);
void analyze_cast_expression(ExecNode *e);
void analyze_multiplicative_expression(ExecNode *e);
void analyze_additive_expression(ExecNode *e);
void analyze_assignment_expression(ExecNode *e);
void analyze_bitwise_operator(ExecNode *e);
void analyze_relational_equality_expression(ExecNode *e);
void analyze_logical_operator(ExecNode *e);
void analyze_conditional_expression(ExecNode *e);
void analyze_expression(ExecNode *e);

int can_assign_to(Declaration *dest_ty, ExecNode *e);
long long eval_const_expr(ExecNode *e, int is_addr, int is_iconst);
int is_signed_int(Token ty);
int is_unsigned_int(Token ty);
int is_integer(Token ty);
int is_pointer(Token op);
int get_rank(Token ty);
TypeExp *get_type_node(Token ty);
Token get_type_category(Declaration *d);
Token get_promoted_type(Token int_ty);
unsigned get_alignment(Declaration *ty);
unsigned get_sizeof(Declaration *ty);

#endif
