#ifndef STMT_H_
#define STMT_H_

#include "parser.h"

void stmt_init(void);
void stmt_done(void);
void analyze_labeled_statement(ExecNode *s, int in_switch);
void analyze_selection_statement(ExecNode *s);
void analyze_iteration_statement(ExecNode *s);
void analyze_jump_statement(ExecNode *s, int in_loop, int in_switch);
void set_return_type(TypeExp *ds, TypeExp *dct);
void empty_label_table(void);
void resolve_gotos(void);
void increase_switch_nesting_level(ExecNode *e);
int decrease_switch_nesting_level(void);

#endif
