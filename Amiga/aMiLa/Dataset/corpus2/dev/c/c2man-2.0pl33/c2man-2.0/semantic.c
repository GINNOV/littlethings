/* $Id: semantic.c,v 2.0.1.12 1994/01/07 07:05:05 greyham Exp $
 *
 * C manual page generator
 * These routines implement the semantic actions executed by the yacc parser.
 */
#include "c2man.h"

#include <ctype.h>
#include "semantic.h"
#include "enum.h"
#include "manpage.h"
#include "strconcat.h"
#include "output.h"

/* Return TRUE if the given identifier is really a typedef name.
 * Search the symbol table for the identifier.
 */
boolean
is_typedef_name (name)
char *name;
{
    return (boolean)(find_symbol(typedef_names, name) != NULL);
}

/* Initialize a new declaration specifier part.
 */
void
new_decl_spec (decl_spec, text, flags)
DeclSpec *decl_spec;
char *text;
int flags;
{
    decl_spec->text = text ? strduplicate(text) : NULL;
    decl_spec->flags = flags;
    decl_spec->enum_list = NULL;
}

/* Free storage used by a declaration specifier part.
 */
void
free_decl_spec (decl_spec)
DeclSpec *decl_spec;
{
    safe_free(decl_spec->text);	/* could be an ellipsis you know */
}

/* Initialize a new declaration specifier part, including an enum part.
 */
void
new_enum_decl_spec (decl_spec, text, flags, enum_list)
DeclSpec *decl_spec;
char *text;
int flags;
EnumeratorList *enum_list;
{
    decl_spec->text = text;
    decl_spec->flags = flags;
    decl_spec->enum_list = enum_list;
}

/* Initialize a new declaration specifier part, but don't strdup the text. */
void
dyn_decl_spec (decl_spec, text, flags)
DeclSpec *decl_spec;
char *text;
unsigned int flags;
{
    decl_spec->text = text;
    decl_spec->flags = flags;
    decl_spec->enum_list = NULL;
}

/* Append two declaration specifier parts together.
 */
void
join_decl_specs (result, a, b)
DeclSpec *result, *a, *b;
{
    if (a->text)
    {
	if (b->text)
	{
	    result->text = strconcat(a->text, " ", b->text, NULLCP);
	    free(a->text);
	    free(b->text);
	}
	else
	    result->text = a->text;
    }
    else
	result->text = b->text;
    
    result->flags = a->flags | b->flags;
    
    /* only one of the decl specs should have an enum list! */
    result->enum_list = a->enum_list ? a->enum_list : b->enum_list;
}

/* Allocate and initialize a declarator. */
Declarator *
new_declarator (text, name)
char *name, *text;
{
    Declarator *d;

    d = (Declarator *)safe_malloc(sizeof(Declarator));
    d->text = text;
    d->name = name;
    d->type = DECL_SIMPLE;
    d->comment = NULL;
    new_ident_list(&d->params);
    d->head = d;
    d->func_stack = NULL;
    return d;
}

/* Free storage used by a declarator.
 */
void
free_declarator (d)
Declarator *d;
{
#ifdef DEBUG
    fprintf(stderr,"free_declarator: decl = %lx, name = %s, text = %s\n",
	(long)d, d->name?d->name:"NULL", d->text?d->text:"NULL");
#endif
    safe_free(d->name);	/* could be an ellipsis (ie: no name) */
    safe_free(d->text);	/* ellipsis is marked by no text too */
    safe_free(d->comment);
    free_param_list(&(d->params));
    if (d->func_stack != NULL)
	free_declarator(d->func_stack);
    free(d);
}

/* add a comment to the last declarator in the list */
int
comment_last_decl(list, comment)
DeclaratorList *list;
char *comment;
{
    if (list->last->comment)
    {
	declarator_error(list->last);
	free(comment);
	return 0;
    }
    else
	list->last->comment = comment;
    return 1;
}

/* Initialize a declarator list and add the given declarator to it.
 */
void
new_decl_list (decl_list, declarator)
DeclaratorList *decl_list;
Declarator *declarator;
{
    decl_list->first = decl_list->last = declarator;
    declarator->next = NULL;
}

/* Free storage used by the declarators in the declarator list.
 */
void
free_decl_list (decl_list)
DeclaratorList *decl_list;
{
    Declarator *d, *next;
#ifdef DEBUG
    fprintf(stderr,"free_decl_list: decl_list = %lx, first = %lx\n",
    	(long)decl_list, (long)decl_list->first);
#endif
    d = decl_list->first;
    while (d != NULL) {
	next = d->next;
	free_declarator(d);
	d = next;
    }
}

/* Add the declarator to the declarator list.
 */
void
add_decl_list (to, from, declarator)
DeclaratorList *to, *from;
Declarator *declarator;
{
    to->first = from->first;
    from->last->next = declarator;
    to->last = declarator;
    to->last->next = NULL;
}

/* Initialize the parameter structure.
 */
void
new_parameter (param, decl_spec, declarator, comment_before, comment_after)
Parameter *param;		/* pointer to structure to be initialized */
DeclSpec *decl_spec;		/* declaration specifier structure */
Declarator *declarator;		/* declarator structure */
char *comment_before;		/* comment before the param */
char *comment_after;		/* comment after the param */
{

    if (decl_spec == NULL) {
	new_decl_spec(&(param->decl_spec), NULLCP, DS_JUNK);
    } else {
	param->decl_spec = *decl_spec;
    }

    if (declarator == NULL) {
	declarator = new_declarator(NULLCP, NULLCP);
    }
    param->declarator = declarator;

    if (comment_before && comment_after)
    {
	parameter_error(param);
	free(comment_after);	/* comment_before will go in Parameter */
    }

    param->declarator->comment =
			comment_before ? comment_before : comment_after;
    param->suppress = FALSE;
    param->duplicate = FALSE;
}

/* Free the storage used by the parameter.
 */
void
free_parameter (param)
Parameter *param;
{
    free_decl_spec(&(param->decl_spec));
    free_declarator(param->declarator);
}

/* add a comment to the last parameter in the list */
int
comment_last_parameter(list, comment)
ParameterList *list;
char *comment;
{
    if (list->last == NULL)
    {
	yyerror("comment '%s' applies to non-existent parameter", comment);
	free(comment);
	return 0;
    }

    if (list->last->declarator->comment)
    {
	parameter_error(list->last);
	free(comment);
	return 0;
    }
    else
	list->last->declarator->comment = comment;
    return 1;
}

/* Initialize a list of function parameters.
 */
void
new_param_list (param_list, param)
ParameterList *param_list;
Parameter *param;
{
    Parameter *p;

    p = (Parameter *)safe_malloc((unsigned)sizeof(Parameter));
    *p = *param;
    
    param_list->first = param_list->last = p;
    p->next = NULL;
}

/* Free storage used by the elements in the function parameter list.
 */
void
free_param_list (param_list)
ParameterList *param_list;
{
    Parameter *p, *next;

    p = param_list->first;
    while (p != NULL) {
	next = p->next;
	free_parameter(p);
	free(p);
	p = next;
    }
}

/* Add the function parameter declaration to the list.
 */
void
add_param_list (to, from, param)
ParameterList *to, *from;
Parameter *param;
{
    Parameter *p;

    p = (Parameter *)safe_malloc((unsigned)sizeof(Parameter));
    *p = *param;

    to->first = from->first;
    from->last->next = p;
    to->last = p;
    p->next = NULL;
}

/* Initialize an empty list of function parameter names.
 */
void
new_ident_list (param_list)
ParameterList *param_list;
{
    param_list->first = param_list->last = NULL;
}

/* Add an item to the list of function parameter declarations but set only
 * the parameter name field and the comments.
 */
void
add_ident_list (to, from, ident)
ParameterList *to, *from;
Identifier *ident;
{
    Parameter *p;
    Declarator *declarator;

    p = (Parameter *)safe_malloc(sizeof(Parameter));
    declarator = new_declarator(ident->name, strduplicate(ident->name));
    new_parameter(p, (DeclSpec *)NULL, declarator, ident->comment_before,
						    ident->comment_after);

    to->first = from->first;
    if (to->first == NULL) {
	to->first = p;
    } else {
	from->last->next = p;
    }
    to->last = p;
    p->next = NULL;
}

/* Search the list of parameters for a matching parameter name.
 * Return a pointer to the matching parameter or NULL if not found.
 */
static Parameter *
search_parameter_list (params, name)
ParameterList *params;
char *name;
{
    Parameter *p;

    for (p = params->first; p != NULL; p = p->next) {
	if (p->declarator->name && strcmp(p->declarator->name, name) == 0)
	    return p;
    }
    return (Parameter *)NULL;
}

/* This routine is called to generate function prototypes from traditional
 * style function definitions.  For each parameter name in the declarator
 * list, find the matching parameter name in the parameter list and set
 * that parameter's declaration specifier.
 * This is also where we promote formal parameters.  Parameters of type
 * "char", "unsigned char", "short", or "unsigned short" get promoted to
 * "int".  Parameters of type "float" are promoted to "double".
 */
void
set_param_types (params, decl_spec, declarators, comment, eolcomment)
ParameterList *params;
DeclSpec *decl_spec;
DeclaratorList *declarators;
char *comment;
char *eolcomment;
{
    Declarator *d;
    Parameter *p;

    if (comment && eolcomment)
    {
	yyerror("parameter declaration has multiple comments");
	return;
    }

    if (!comment)	comment = eolcomment;
    
    for (d = declarators->first; d != NULL; d = d->next) {
	/* Search the parameter list for a matching name. */
	if ((p = search_parameter_list(params, d->name)) == NULL) {
	    output_error();
	    fprintf(stderr, "declared argument \"%s\" is missing\n", d->name);
	} else {
	    char *decl_spec_text = decl_spec->text;
	    if (promote_param && strcmp(d->text, d->name) == 0) {
		if (decl_spec->flags & (DS_CHAR | DS_SHORT))
		    decl_spec_text = "int";
		else if (decl_spec->flags & DS_FLOAT)
		    decl_spec_text = "double";
	    }
	    safe_free(p->decl_spec.text);   /* there shouldn't be one, but...*/
	    p->decl_spec.text = strduplicate(decl_spec_text);
	    if (p->decl_spec.flags != decl_spec->flags)
	    {
		if (p->decl_spec.flags & DS_JUNK)
		    p->decl_spec.flags = decl_spec->flags;
		else
		    parameter_error(p);
	    }
	    if (p->decl_spec.enum_list != decl_spec->enum_list)
	    {
		if (p->decl_spec.enum_list == NULL)
		    p->decl_spec.enum_list = decl_spec->enum_list;
		else
		    parameter_error(p);
	    }

	    free_declarator(p->declarator);
	    p->declarator = d;

	    if (comment)
	    {
		if (p->declarator->comment)
		    parameter_error(p);
		else
		    p->declarator->comment = strduplicate(comment);
	    }
	}
    }

    free_decl_spec(decl_spec);
    safe_free(comment);
}

/* Output a declaration specifier for an external declaration.
 */
void
output_decl_spec (decl_spec)
DeclSpec *decl_spec;
{
    output->text(decl_spec->text);
}

static void
output_parameters _((Declarator *d, boolean format));

/* does a function have any parameters?
 * This accounts for both fn() and fn(void)
 */
boolean has_parameters(d)
const Declarator *d;
{
    Parameter *first = d->head->params.first;

    return (first != NULL &&
	   (first->declarator->text != NULL ||
	    strcmp(first->decl_spec.text, "void")));
}

/* output a declarator name, stripping leading underscores if necessary */
void output_decl_text(text, keep_underscores)
char *text;
boolean keep_underscores;
{
    if (!keep_underscores)
    {
	/* skip leading stuff before the actual name */
	while (*text && *text != '_' && !isalnum(*text))
	    output->character(*text++);
	while (text[0] == '_' && text[1])	text++;
    }
    output->text(text);
}

/* Output a function declarator.
 */
static void
output_func_declarator (declarator, format)
Declarator *declarator;
boolean format;
{
    char *s, *t, *decl_text;

    /* Output declarator text before function declarator place holder. */
    if ((s = strstr(declarator->text, "%s")) == NULL)
	return;
    *s = '\0';
    output->text(declarator->text);

    /* Substitute place holder with function declarator. */
    if (!is_function_declarator(declarator->func_stack)) {

	decl_text = declarator->func_stack->text;
	if (declarator->name == NULL || declarator->name[0] == '\0') {
	    output->text(decl_text);
	} else {

	    /* Output the declarator text before the declarator name. */
	    if ((t = strstr(decl_text, declarator->name)) == NULL)
		return;
	    *t = '\0';
	    output->text(decl_text);
	    *t = declarator->name[0];

	    if (format && strcmp(declarator_prefix, " ") != 0)
		output_format_string(declarator_prefix);

	    /* Output the declarator name. */
	    output_decl_text(declarator->name, format);

	    /* Output the remaining declarator text. */
	    output->text(t + strlen(declarator->name));

	    /* Output the declarator suffix. */
	    if (format) output_format_string(declarator_suffix);
	}
    } else {
	output_func_declarator(declarator->func_stack,format);
    }
    *s = '%';
    s += 2;

    /* Output declarator text up to but before parameters place holder. */
    if ((t = strstr(s, "()")) == NULL)
	return;
    *t = '\0';
    output->text(s);

    /* Substitute place holder with function parameters. */
    output->character(*t++ = '(');
    output_parameters(declarator, format);
    output->text(t);
}

/* Output a declarator.
 */
void
output_declarator (d, format)
Declarator *d;
boolean format;
{
    if (d->func_stack) {
	output_func_declarator(d, format);
    } else {
	output_decl_text(d->text, format);
    }
}

/* Output a function parameter.
 */
void
output_parameter (p)
Parameter *p;
{
    if (p->decl_spec.text)
	output->text(p->decl_spec.text);
    else
    /* Check for parameter names with no declaration specifiers.  This
     * happens when a parameter name appears in the identifier list of a
     * function definition but does not appear in the parameter declaration
     * part.  The default type in this cause is "int".
     */
    if (p->declarator->text && strcmp(p->declarator->text, "...") != 0)
	output->text("int ");

    /* not all parameters must have declarators: might be a prototype */
    if (p->declarator->text) {
	if (p->decl_spec.text)
	    output->character(' ');
	/* don't format parameters; keep it all on one line */
	output_declarator(p->declarator, FALSE);
    }
}

/* Output the list of function parameters.
 */
static void
output_parameters (d, format)
Declarator *d;
boolean format;
{
    if (has_parameters(d)) {
        Parameter *p = d->params.first;
	if (format) output_format_string(first_param_prefix);
	output_parameter(p);
	p = p->next;
	while (p != NULL) {
	    output->character(',');
	    if (format) output_format_string(middle_param_prefix);
	    output_parameter(p);
	    p = p->next;
	}
	if (format) output_format_string(last_param_suffix);
    }
    else
	output->text("void");
}

/* remember variable and function declarations. */
int
remember_declarations (comment, decl_spec, decl_list, eolcomment)
char *comment;			/* comment before */
DeclSpec *decl_spec;		/* declaration specifier */
DeclaratorList *decl_list;	/* list of declared variables */
char *eolcomment;		/* eol comment after */
{
    Declarator *d, *next;
    int ret = 1;
    
    /* attach EOL comment to last one in list */
    if (eolcomment)
    {
	Declarator *attach;

	/* if it's a function, attach it to the last parameter */
	if (is_function_declarator(decl_list->last) &&
	    decl_list->last->head->params.last)
	    attach = decl_list->last->head->params.last->declarator;
	else
	    attach = decl_list->last;
	    
	if (attach->comment)
	{
	    declarator_error(attach);
	    free(eolcomment);
	    ret = 0;
	}
	else
	    attach->comment = eolcomment;
    }
    
    /* special case of a single declarator handled efficiently */
    if (decl_list->first && decl_list->first->next == NULL)
    {
	d = decl_list->first;
	/* free the declarator comment if it isn't going to get used */
	if (comment)
	    safe_free(d->comment);
	else
	    comment = d->comment;

	/* and nuke it from the declarator so free_declarator won't free it
	 * (since safe_free will do that) if new_manual_page decides to throw
	 * it away.
	 */
	d->comment = NULL;

	new_manual_page(comment, decl_spec, d);
    }
    else
    {
	for (d = decl_list->first; d != NULL; d = next)
	{
	    DeclSpec spec_copy;
	    char *comment_copy;

	    next = d->next;
#ifdef DEBUG
	    fprintf(stderr,
		"remember_declarations: text=%s name=%s\ncomment: %s\n",
	    	d->text,d->name, comment ? comment : "NULL");
#endif
	    spec_copy = *decl_spec;
	    spec_copy.text = strduplicate(decl_spec->text);
	    comment_copy = d->comment ? d->comment :
				    (comment ? strduplicate(comment) : NULL);
	    d->comment = NULL;
	    new_manual_page(comment_copy, &spec_copy,d);
	}

	/* free 'em up */
	free_decl_spec(decl_spec);
	safe_free(comment);
    }

    return ret;
}

void parameter_error(param)
Parameter *param;
{
    yyerror("parameter '%s' has multiple comments", param->declarator->name);
}

void declarator_error(decl)
Declarator *decl;
{
    yyerror("declarator '%s' has multiple comments", decl->name);
}

/* is a declarator for a function? (as opposed to a variable) */
boolean is_function_declarator(decl)
const Declarator *decl;
{
    return decl->type == DECL_FUNCTION || decl->type == DECL_FUNCDEF;
}
