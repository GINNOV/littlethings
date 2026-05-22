/* $Id: enum.h,v 2.0 1993/04/05 02:38:20 greyham Exp $ */
#include "config.h"

extern SymbolTable *enum_table;	/* enum symbol table */

/* Initialize a list of enumerators.*/
EnumeratorList *
new_enumerator_list _((Enumerator *enumerator));

/* Add the enumerator to the list. */
void
add_enumerator_list _((EnumeratorList *list,   Enumerator *enumerator));

/* Free storage used by the elements in the enumerator list. */
void
free_enumerator_list _((EnumeratorList *enumerator_list));

void
new_enumerator _((Enumerator *e, char *name,
		char *comment_before, char *comment_after));

/* Free the storage used by the enumerator.*/
void
free_enumerator _((Enumerator *param));

/* add a comment to the last enumeralor in the list */
int
comment_last_enumerator _((EnumeratorList *enum_list, char *comment));

/* enum namespace management */
void add_enum_symbol _((char *name, EnumeratorList *first_enum));

/* look for the first enumerator associated with the symbol */
EnumeratorList *find_enum_symbol _((char *name));

void destroy_enum_lists();

/* create new typedef symbols */
void new_typedef_symbols _((DeclSpec *decl_spec, DeclaratorList *decl_list));

void enumerator_error _((char *name));
