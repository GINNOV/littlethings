/* $Id: enum.c,v 2.0.1.1 1993/08/31 05:07:21 greyham Exp $
 * enumerator operations
 */
#include "c2man.h"
#include "strconcat.h"
#include "enum.h"
#include "manpage.h"

SymbolTable *enum_table;	/* enum symbol table */

/* we have to keep a list of EnumeratorLists because:
 * - unnamed EnumeratorLists can't go in the symbol table.
 * - a single EnumeratorList can be typedef'ed or enum'ed to more than one
 *   symbol, in which case it is referenced from the typedef_table or
 *   enum_table repectively more than once.
 */
EnumeratorList *first_list = NULL, **last_next_list = &first_list;

/* Initialize a list of enumerators.*/
EnumeratorList *
new_enumerator_list (enumerator)
     Enumerator *enumerator;
{
    Enumerator *p;
    EnumeratorList *list;
    
    list = (EnumeratorList *)safe_malloc(sizeof *list);
    *last_next_list = list;
    last_next_list = &list->next;
    list->next = NULL;
    
    p = (Enumerator *)safe_malloc(sizeof(Enumerator));
    *p = *enumerator;
    
    list->first = list->last = p;
    p->next = NULL;
    return list;
}

/* Add the enumerator to the list. */
void
add_enumerator_list (list, enumerator)
     EnumeratorList *list;
     Enumerator *enumerator;
{
    Enumerator *p;

    p = (Enumerator *)safe_malloc((unsigned)sizeof(Enumerator));
    *p = *enumerator;

    list->last->next = p;
    list->last = p;
    p->next = NULL;
}

/* Free storage used by the elements in the enumerator list. */
void
free_enumerator_list (enumerator_list)
     EnumeratorList *enumerator_list;
{
    Enumerator *p, *next;

    p = enumerator_list->first;
    while (p != NULL) {
	next = p->next;
	free_enumerator(p);
	free(p);
	p = next;
    }
}


void
new_enumerator(e, name, comment_before, comment_after)
     Enumerator *e;
     char *name;
     char *comment_before;
     char *comment_after;
{
    e-> name = name;
    e-> comment = comment_after ? comment_after : comment_before;
    e-> group_comment = comment_before && comment_after ? comment_before : NULL;
}

/* Free the storage used by the enumerator.*/
void
free_enumerator (param)
     Enumerator *param;
{
    free(param->name);
    safe_free(param->comment);
    safe_free(param->group_comment);
}

/* add a comment to the last enumerator in the list */
int
comment_last_enumerator(list, comment)
     EnumeratorList *list;
     char *comment;
{
    if (list->last->comment)
    {
	if (list->last->group_comment)
	{
	    enumerator_error(list->last->name);
	    free(comment);
	    return 0;
	}

	list->last->group_comment = list->last->comment;
    }

    list->last->comment = comment;
    return 1;
}

/* enum namespace management */
void add_enum_symbol(name, enum_list)
     char *name;
     EnumeratorList *enum_list;
{
    Symbol *entry = new_symbol(enum_table, name, DS_NONE);
    
    if (entry)
    {
	entry->value.enum_list = enum_list;
	entry->valtype = SYMVAL_ENUM;
    }
}

/* look for the Enumerator list associated with the symbol */
EnumeratorList *find_enum_symbol(name)
     char *name;
{
    Symbol *entry = find_symbol(enum_table, name);
    
    if (entry)
    	return entry->value.enum_list;
    else
    	return NULL;
}

void destroy_enum_lists()
{
    EnumeratorList *list, *next;
    
    /* free all the enumerator lists */
    for (list = first_list; list; list = next)
    {
	next = list->next;
	free_enumerator_list(list);
	free(list);
    }
}

/* create new typedef symbols */
void new_typedef_symbols(decl_spec, decl_list)
     DeclSpec *decl_spec;
     DeclaratorList *decl_list;
{
    Declarator *d;
    
    for (d = decl_list->first; d; d = d-> next)
    {
	Symbol *s = new_symbol(typedef_names, d->name, DS_NONE);
	
	if (s && decl_spec->enum_list)
	{
	    s->value.enum_list = decl_spec->enum_list;
	    s->valtype = SYMVAL_ENUM;
	}
    }
}

void enumerator_error(name)
     char *name;
{
    yyerror("enumerator '%s' has multiple comments", name);
}
