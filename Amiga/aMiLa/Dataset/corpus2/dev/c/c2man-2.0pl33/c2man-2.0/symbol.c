/* $Id: symbol.c,v 2.0.1.2 1993/08/31 05:05:20 greyham Exp $
 *
 * Symbol table maintenance. Implements an abstract data type called
 * the symbol table.
 */
#include "c2man.h"
#include "symbol.h"

/* Create a symbol table.
 * Return a pointer to the symbol table or NULL if an error occurs.
 */
SymbolTable *
create_symbol_table ()
{
    SymbolTable *symtab;
    int i;

    symtab = (SymbolTable *)safe_malloc(sizeof(SymbolTable));

    for (i = 0; i < SYM_MAX_HASH; ++i)
	symtab->bucket[i] = NULL;

    return symtab;
}


/* Free the memory allocated to the symbol table.
 */
void
destroy_symbol_table (symtab)
SymbolTable *symtab;
{
    int i;
    Symbol *sym, *next;

    for (i = 0; i < SYM_MAX_HASH; ++i) {
	sym = symtab->bucket[i];
	while (sym != NULL) {
	    next = sym->next;
	    free(sym->name);
	    free(sym);
	    sym = next;
	}
    }
    free(symtab);
}


/* This is a simple hash function mapping a symbol name to a hash bucket. */

static unsigned int
hash (name)
char *name;
{
    char *s;
    unsigned int h;

    h = 0;
    s = name;
    while (*s != '\0')
	h = (h << 1) ^ *s++;
    return h % SYM_MAX_HASH;
}


/* Search the list of symbols <list> for the symbol <name>.
 * Return a pointer to the symbol or NULL if not found.
 */
static Symbol *
search_symbol_list (list, name)
Symbol *list;
char *name;
{
    Symbol *sym;

    for (sym = list; sym != NULL; sym = sym->next) {
	if (strcmp(sym->name, name) == 0)
	    return sym;
    }
    return NULL;
}


/* Look for symbol <name> in symbol table <symtab>.
 * Return a pointer to the symbol or NULL if not found.
 */
Symbol *
find_symbol (symtab, name)
SymbolTable *symtab;
char *name;
{
    return search_symbol_list(symtab->bucket[hash(name)], name);
}


/* If the symbol <name> does not already exist in symbol table <symtab>,
 * then add the symbol to the symbol table.
 * Return a pointer to the symbol or NULL on an error.
 */
Symbol *
new_symbol (symtab, name, flags)
SymbolTable *symtab;	/* symbol table */
char *name;		/* symbol name */
int flags;		/* symbol attributes */
{
    Symbol *sym;
    int i;

    if ((sym = find_symbol(symtab, name)) == NULL) {
	sym = (Symbol *)safe_malloc(sizeof(Symbol));
	sym->name = strduplicate(name);
	sym->flags = flags;
	sym->valtype = SYMVAL_NONE;
	i = hash(name);
	sym->next = symtab->bucket[i];
	symtab->bucket[i] = sym;
    }
    return sym;
}
