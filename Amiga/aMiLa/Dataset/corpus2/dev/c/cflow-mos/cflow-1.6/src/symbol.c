/* This file is part of GNU cflow
   Copyright (C) 1997-2019 Sergey Poznyakoff

   GNU cflow is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   GNU cflow is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>. */

#include <cflow.h>
#include <parser.h>
#include <hash.h>

static Hash_table *symbol_table;

static struct linked_list *static_symbol_list;
static struct linked_list *auto_symbol_list;
static struct linked_list *static_func_list;
static struct linked_list *unit_local_list;

static void
append_symbol(struct linked_list **plist, Symbol *sp)
{
     if (sp->entry) {
	  linked_list_unlink(sp->entry->list, sp->entry);
	  sp->entry = NULL;
     }
     if (!data_in_list(sp, *plist)) {
	  linked_list_append(plist, sp);
	  sp->entry = (*plist)->tail;
     }
}

struct table_entry {
     Symbol *sym;
};

/* Calculate the hash of a string.  */
static size_t
hash_symbol_hasher(void const *data, size_t n_buckets)
{
     struct table_entry const *t = data;
     if (!t->sym)
	  return ((size_t) data) % n_buckets;
     return hash_string(t->sym->name, n_buckets);
}

/* Compare two strings for equality.  */
static bool
hash_symbol_compare(void const *data1, void const *data2)
{
     struct table_entry const *t1 = data1;
     struct table_entry const *t2 = data2;
     return t1->sym && t2->sym && strcmp(t1->sym->name, t2->sym->name) == 0;
}

Symbol *
lookup(const char *name)
{
     Symbol s, *sym;
     struct table_entry t, *tp;
     
     if (!symbol_table)
	  return NULL;
     s.name = (char*) name;
     t.sym = &s;
     tp = hash_lookup(symbol_table, &t);
     if (tp) {
	  sym = tp->sym;
	  while (sym->type == SymToken && sym->flag == symbol_alias)
	       sym = sym->alias;
     } else
	  sym = NULL;
     return sym;
}

/* Install a new symbol `NAME'.  If UNIT_LOCAL is set, this symbol can
   be local to the current compilation unit. */
Symbol *
install(char *name, int flags)
{
     Symbol *sym;
     struct table_entry *tp, *ret;
     
     sym = xmalloc(sizeof(*sym));
     memset(sym, 0, sizeof(*sym));
     sym->type = SymUndefined;
     sym->name = name;

     tp = xmalloc(sizeof(*tp));
     tp->sym = sym;
     
     if (((flags & INSTALL_CHECK_LOCAL) &&
	  canonical_filename && strcmp(filename, canonical_filename)) ||
	 (flags & INSTALL_UNIT_LOCAL)) {
	  sym->flag = symbol_local;
	  append_symbol(&static_symbol_list, sym);
     } else
	  sym->flag = symbol_none;
     
     if (! ((symbol_table
	     || (symbol_table = hash_initialize (0, 0, 
						 hash_symbol_hasher,
						 hash_symbol_compare, 0)))
	    && (ret = hash_insert (symbol_table, tp))))
	  xalloc_die ();

     if (ret != tp) {
	  if (flags & INSTALL_OVERWRITE) {
	       free(sym);
	       free(tp);
	       return ret->sym;
	  }
	  if (ret->sym->type != SymUndefined) 
	       sym->next = ret->sym;
	  ret->sym = sym;
	  free(tp);
     }
     sym->owner = ret;
     return sym;
}

void
ident_change_storage(Symbol *sp, enum storage storage)
{
     if (sp->storage == storage)
	  return;
     if (sp->storage == StaticStorage)
	  /* FIXME */;

     switch (storage) {
     case StaticStorage:
	  append_symbol(&static_symbol_list, sp);
	  break;
     case AutoStorage:
	  append_symbol(&auto_symbol_list, sp);
	  break;
     default:
	  break;
     }
     sp->storage = storage;
}

Symbol *
install_ident(char *name, enum storage storage)
{
     Symbol *sp;

     sp = install(name, 
                  storage != AutoStorage ? 
                     INSTALL_CHECK_LOCAL : INSTALL_DEFAULT);
     sp->type = SymIdentifier;
     sp->arity = -1;
     sp->storage = ExternStorage;
     sp->decl = NULL;
     sp->source = NULL;
     sp->def_line = -1;
     sp->ref_line = NULL;
     sp->caller = sp->callee = NULL;
     sp->level = -1;
     ident_change_storage(sp, storage);
     return sp;
}

/* Unlink the symbol from the table entry */
static void
unlink_symbol(Symbol *sym)
{
     Symbol *s, *prev = NULL;
     struct table_entry *tp = sym->owner;
     for (s = tp->sym; s; ) {
	  Symbol *next = s->next;
	  if (s == sym) {
	       if (prev)
		    prev->next = next;
	       else
		    tp->sym = next;
	       break;
	  } else
	       prev = s;
	  s = next;
     }
	       
     sym->owner = NULL;
}     

/* Unlink and free the first symbol from the table entry */
static void
delete_symbol(Symbol *sym)
{
     unlink_symbol(sym);
     /* The symbol could have been referenced even if it is static
	in -i^s mode. See tests/static.at for details. */
     if (sym->ref_line == NULL && !(reverse_tree && sym->callee)) {
	  linked_list_destroy(&sym->ref_line);
	  linked_list_destroy(&sym->caller);
	  linked_list_destroy(&sym->callee);
	  free(sym);
     }
}     

/* Delete from the symbol table all static symbols defined in the current
   source.
   If the user requested static symbols in the listing, the symbol is
   not deleted, as it may have been referenced by other symbols. Instead,
   it is unlinked from its table entry.
   NOTE: This takes advantage of the fact that install() uses LIFO strategy,
   so we don't have to check the name of the source where the symbol was
   defined. */

static void
static_free(void *data)
{
     Symbol *sym = data;
     struct table_entry *t = sym->owner;

     if (!t)
	  return;
     if (sym->flag == symbol_local) {
	  /* In xref mode, eligible unit-local symbols are retained in
	     unit_local_list for further processing.
	     Otherwise, they are deleted. */
	  if (print_option == PRINT_XREF && include_symbol(sym)) {
	       unlink_symbol(sym);
	       linked_list_append(&unit_local_list, sym);
	  } else {
	       delete_symbol(sym);
	  }
     } else {
	  unlink_symbol(sym);
	  if (symbol_is_function(sym))
	       linked_list_append(&static_func_list, sym);
     }
}

void
delete_statics()
{
     if (static_symbol_list) {
	  static_symbol_list->free_data = static_free;
	  linked_list_destroy(&static_symbol_list);
     }
}

/* See NOTE above */

/* Delete from the symbol table all auto variables with given nesting
   level. */
int
delete_level_autos(void *data, void *call_data)
{
     int level = *(int*)call_data;
     Symbol *s = data;
     if (s->level == level) {
	  delete_symbol(s);
	  return 1;
     }
     return 0;
}

int
delete_level_statics(void *data, void *call_data)
{
     int level = *(int*)call_data;
     Symbol *s = data;
     if (s->level == level) {
	  unlink_symbol(s);
	  return 1;
     }
     return 0;
}

void
delete_autos(int level)
{
     linked_list_iterate(&auto_symbol_list, delete_level_autos, &level);
     linked_list_iterate(&static_symbol_list, delete_level_statics, &level);
}

struct collect_data {
     Symbol **sym;
     int (*sel)(Symbol *p);
     size_t index;
};

static bool
collect_processor(void *data, void *proc_data)
{
     struct table_entry *t = data;
     struct collect_data *cd = proc_data;
     Symbol *s;
     for (s = t->sym; s; s = s->next) {
	  if (cd->sel(s)) {
	       if (cd->sym)
		    cd->sym[cd->index] = s;
	       cd->index++;
	  }
     }
     return true;
}

static int
collect_list_entry(void *item, void *proc_data)
{
     Symbol *s = item;
     struct collect_data *cd = proc_data;
     if (cd->sel(s)) {
	  cd->sym[cd->index] = s;
	  cd->index++;
     }
     return 0;
}
 
size_t
collect_symbols(Symbol ***return_sym, int (*sel)(Symbol *p),
		size_t reserved_slots)
{
     struct collect_data cdata;
     size_t size;
     
     size = hash_get_n_entries(symbol_table)
	     + linked_list_size(static_func_list)
	     + linked_list_size(unit_local_list);
     cdata.sym = xcalloc(size + reserved_slots, sizeof(*cdata.sym));
     cdata.index = 0;
     cdata.sel = sel;
     hash_do_for_each(symbol_table, collect_processor, &cdata);
     linked_list_iterate(&static_func_list, collect_list_entry, &cdata);
     linked_list_iterate(&unit_local_list, collect_list_entry, &cdata);

     cdata.sym = xrealloc(cdata.sym,
			  (cdata.index + reserved_slots) * sizeof(*cdata.sym));
     *return_sym = cdata.sym;
     return cdata.index;
}

size_t
collect_functions(Symbol ***return_sym)
{
     Symbol **symbols;
     size_t num, snum;
     struct linked_list_entry *p;

     /* Count static functions */
     snum = linked_list_size(static_func_list);
     
     /* Collect global functions */
     num = collect_symbols(&symbols, symbol_is_function, snum);

     /* Collect static functions */
     if (snum) 
	  for (p = linked_list_head(static_func_list); p; p = p->next)
	       symbols[num++] = p->data;
     *return_sym = symbols;
     return num;
}



/* Special handling for function parameters */

int
delete_parms_itr(void *data, void *call_data)
{
     int level = *(int*)call_data;
     Symbol *s = data;
     struct table_entry *t = s->owner;
	  
     if (!t)
	  return 1;
     if (s->type == SymIdentifier && s->storage == AutoStorage
	 && s->flag == symbol_parm && s->level > level) {
	  delete_symbol(s);
	  return 1;
     }
     return 0;
}

/* Delete all parameters with parameter nesting level greater than LEVEL */
void
delete_parms(int level)
{
     linked_list_iterate(&auto_symbol_list, delete_parms_itr, &level);
}

/* Redeclare all saved parameters as automatic variables with the
   given nesting level */
void
move_parms(int level)
{
     struct linked_list_entry *p;

     for (p = linked_list_head(auto_symbol_list); p; p = p->next) {
	  Symbol *s = p->data;

	  if (s->type == SymIdentifier && s->storage == AutoStorage
	      && s->flag == symbol_parm) {
	       s->level = level;
	       s->flag = symbol_none;
	  }
     }
}

