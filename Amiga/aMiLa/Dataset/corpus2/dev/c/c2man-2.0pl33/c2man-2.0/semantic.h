/* $Id: semantic.h,v 2.0.1.5 1994/01/07 07:04:40 greyham Exp $
 *
 * Declarations for semantic action routines
 */
#include "config.h"

extern boolean is_typedef_name _((
	char *name
	));
void
new_decl_spec _((
DeclSpec *decl_spec,
char *text,
int flags));

extern void join_decl_specs _((
	DeclSpec *result,
	DeclSpec *a,
	DeclSpec *b
	));
extern void free_decl_spec _((
	DeclSpec *decl_spec
	));
void
new_parameter _((
Parameter *param,		/* pointer to structure to be initialized */
DeclSpec *decl_spec,		/* declaration specifier structure */
Declarator *declarator,		/* declarator structure */
char *comment_before,		/* comment before the param */
char *comment_after));		/* comment after the param */

extern void free_parameter _((
	Parameter *param
	));

/* add a comment to the last parameter in the list */
int
comment_last_parameter _((ParameterList *list, char *comment));

extern void new_param_list _((
	ParameterList *param_list,
	Parameter *param
	));

extern void add_param_list _((
	ParameterList *to,
	ParameterList *from,
	Parameter *param
	));
extern void free_param_list _((
	ParameterList *param_list
	));
extern void new_ident_list _((
	ParameterList *param_list
	));
extern void add_ident_list _((
	ParameterList *to,
	ParameterList *from,
	Identifier *ident
	));
extern Declarator * new_declarator _((
	char *text,
	char *name
	));
extern void free_declarator _((
	Declarator *d
	));
extern void new_decl_list _((
	DeclaratorList *decl_list,
	Declarator *declarator
	));
extern void add_decl_list _((
	DeclaratorList *to,
	DeclaratorList *from,
	Declarator *declarator
	));
extern void free_decl_list _((
	DeclaratorList *decl_list
	));
extern void set_param_types _((
	ParameterList *params,
	DeclSpec *decl_spec,
	DeclaratorList *declarators,
	char *comment,
	char *eolcomment
	));

/* Output a function parameter.*/
void output_parameter _((Parameter *p));

int
remember_declarations _((
char *comment,			/* comment associated */
DeclSpec *decl_spec,		/* declaration specifier */
DeclaratorList *decl_list,	/* list of declared variables */
char *eolcomment));		/* eol comment after */

void
dyn_decl_spec _((
DeclSpec *decl_spec,
char *text,
unsigned int flags));

void
new_enum_decl_spec _((
DeclSpec *decl_spec,
char *text,
int flags,
EnumeratorList *enum_list));

void
output_decl_spec _((DeclSpec *decl_spec));

void
output_declarator _((Declarator *d, boolean format));

void parameter_error _((Parameter *param));
void declarator_error _((Declarator *decl));

boolean has_parameters _((const Declarator *d));
boolean is_function_declarator _((const Declarator *d));
