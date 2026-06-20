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

unsigned char *level_mark;
/* Tree level information. level_mark[i] contains 1 if there are more
 * leafs on the level `i', otherwise it contains 0
 */
int level_mark_size = 0;   /* Actual size of level_mark */
int level_mark_incr = 128; /* level_mark is expanded by this number of bytes */

int out_line = 1; /* Current output line number */
FILE *outfile;    /* Output file */

static void
set_level_mark(int lev, int mark)
{
     if (lev >= level_mark_size) {
	  level_mark_size += level_mark_incr;
	  level_mark = xrealloc(level_mark, level_mark_size);
     }
     level_mark[lev] = mark;
}

/* Print current tree level
 */
void
print_level(int lev, int last)
{
     int i;

     if (print_line_numbers) 
	  fprintf(outfile, "%5d ", out_line);
     if (print_levels)
	  fprintf(outfile, "{%4d} ", lev);
     fprintf(outfile, "%s", level_begin);
     for (i = 0; i < lev; i++) 
	  fprintf(outfile, "%s", level_indent[ level_mark[i] ]);
     fprintf(outfile, "%s", level_end[last]);
}


/* Low level output functions */

struct output_driver {
     char *name;
     int (*handler) (cflow_output_command cmd,
		     FILE *outfile, int line,
		     void *data, void *handler_data);
     void *handler_data;
};

static int driver_index;
static int driver_max=0;
struct output_driver output_driver[MAX_OUTPUT_DRIVERS];

int
register_output(const char *name,
		int (*handler) (cflow_output_command cmd,
				FILE *outfile, int line,
				void *data, void *handler_data),
		void *handler_data)
{
     if (driver_max == MAX_OUTPUT_DRIVERS-1)
	  abort ();
     output_driver[driver_max].name = strdup(name);
     output_driver[driver_max].handler = handler;
     output_driver[driver_max].handler_data = handler_data;
     return driver_max++;
}

int
select_output_driver(const char *name)
{
     int i;
     for (i = 0; i < driver_max; i++)
	  if (strcmp(output_driver[i].name, name) == 0) {
	       driver_index = i;
	       return 0;
	  }
     return -1;
}

void
output_init()
{
     output_driver[driver_index].handler(cflow_output_init,
					 NULL, 0,
					 NULL,
				         output_driver[driver_index].handler_data);
}

void
newline()
{
     output_driver[driver_index].handler(cflow_output_newline,
					 outfile, out_line,
					 NULL,
				         output_driver[driver_index].handler_data);
     out_line++;
}

static void
begin()
{
     output_driver[driver_index].handler(cflow_output_begin,
					 outfile, out_line,
					 NULL,
					 output_driver[driver_index].handler_data);
}

static void
end()
{
     output_driver[driver_index].handler(cflow_output_end,
					 outfile, out_line,
					 NULL,
					 output_driver[driver_index].handler_data);
}

static void
separator()
{
     output_driver[driver_index].handler(cflow_output_separator,
					 outfile, out_line,
					 NULL,
					 output_driver[driver_index].handler_data);
}

#if 0
static void
print_text(char *buf)
{
     output_driver[driver_index].handler(cflow_output_text,
					 outfile, out_line,
					 buf,
					 output_driver[driver_index].handler_data);
}
#endif

static int
print_symbol (int direct, int level, int last, Symbol *sym)
{
     struct output_symbol output_symbol;

     output_symbol.direct = direct;
     output_symbol.level = level;
     output_symbol.last = last;
     output_symbol.sym = sym;

     return output_driver[driver_index].handler(cflow_output_symbol,
						outfile, out_line,
						&output_symbol,
						output_driver[driver_index].handler_data);
}


static int
compare(const void *ap, const void *bp)
{
     Symbol * const *a = ap;
     Symbol * const *b = bp;
     return strcmp((*a)->name, (*b)->name);
}

static int
is_var(Symbol *symp)
{
     if (include_symbol(symp)) {
	  if (symp->type == SymIdentifier) 
	       return symp->storage == ExternStorage ||
	 	      symp->storage == StaticStorage;
	  else
	       return 1;
     }
     return 0;
}

int
symbol_is_function(Symbol *symp)
{
     return symp->type == SymIdentifier && symp->arity >= 0;
}

static void
clear_active(Symbol *sym)
{
     sym->active = 0;
}


/* Cross-reference output */
void
print_refs(char *name, struct linked_list *reflist)
{
     Ref *refptr;
     struct linked_list_entry *p;

     for (p = linked_list_head(reflist); p; p = p->next) {
	  refptr = (Ref*)p->data;
	  fprintf(outfile, "%s   %s:%d\n",
		  name,
		  refptr->source,
		  refptr->line);
     }
}

static void
print_function(Symbol *symp)
{
     if (symp->source) {
	  fprintf(outfile, "%s * %s:%d %s\n",
		  symp->name,
		  symp->source,
		  symp->def_line,
		  symp->decl);
     }
     print_refs(symp->name, symp->ref_line);
}

static void
print_type(Symbol *symp)
{
     if (symp->source)
	  fprintf(outfile, "%s t %s:%d\n",
		  symp->name,
		  symp->source,
		  symp->def_line);
}
   
void
xref_output()
{
     Symbol **symbols, *symp;
     size_t i, num;
     
     num = collect_symbols(&symbols, is_var, 0);
     qsort(symbols, num, sizeof(*symbols), compare);
     
     /* produce xref output */
     for (i = 0; i < num; i++) {
	  symp = symbols[i];
	  switch (symp->type) {
	  case SymIdentifier:
	       print_function(symp);
	       break;
	  case SymToken:
	       print_type(symp);
	       break;
	  case SymUndefined:
	       break;
	  }
     }
     free(symbols);
}



/* Tree output */

static void
set_active(Symbol *sym)
{
     sym->active = out_line;
}

static int
is_printable(struct linked_list_entry *p)
{
     return p != NULL && include_symbol((Symbol*)p->data);
}

static int
is_last(struct linked_list_entry *p)
{
     while ((p = p->next))
	  if (is_printable(p))
	       return 0;
     return 1;
}

/* Produce direct call tree output
 */
static void
direct_tree(int lev, int last, Symbol *sym)
{
     struct linked_list_entry *p;
     int rc;
     
     if (sym->type == SymUndefined
	 || (max_depth && lev >= max_depth)
	 || !include_symbol(sym))
	  return;

     rc = print_symbol(1, lev, last, sym);
     newline();
     if (rc || sym->active)
	  return;
     set_active(sym);
     for (p = linked_list_head(sym->callee); p; p = p->next) {
	  set_level_mark(lev+1, !is_last(p));
	  direct_tree(lev+1, is_last(p), (Symbol*)p->data);
     }
     clear_active(sym);
}

/* Produce reverse call tree output
 */
static void
inverted_tree(int lev, int last, Symbol *sym)
{
     struct linked_list_entry *p;
     int rc;
     
     if (sym->type == SymUndefined
	 || (max_depth && lev >= max_depth)
	 || !include_symbol(sym))
	  return;
     rc = print_symbol(0, lev, last, sym);
     newline();
     if (rc || sym->active)
	  return;
     set_active(sym);
     for (p = linked_list_head(sym->caller); p; p = p->next) {
	  set_level_mark(lev+1, !is_last(p));
	  inverted_tree(lev+1, is_last(p), (Symbol*)p->data);
     }
     clear_active(sym);
}

static void
tree_output()
{
     Symbol **symbols, *main_sym;
     size_t i, num;
     cflow_depmap_t depmap;
     
     /* Collect functions and assign them ordinal numbers */
     num = collect_functions(&symbols);
     for (i = 0; i < num; i++)
	  symbols[i]->ord = i;
     
     /* Create a dependency matrix */
     depmap = depmap_alloc(num);
     for (i = 0; i < num; i++) {
	  if (symbols[i]->callee) {
	       struct linked_list_entry *p;
	       
	       for (p = linked_list_head(symbols[i]->callee); p;
		    p = p->next) {
		    Symbol *s = (Symbol*) p->data;
		    if (symbol_is_function(s))
			 depmap_set(depmap, i, ((Symbol*)p->data)->ord);
	       }		    
	  }
     }
     
     depmap_tc(depmap);

     /* Mark recursive calls */
     for (i = 0; i < num; i++)
	  if (depmap_isset(depmap, i, i))
	       symbols[i]->recursive = 1;
     free(depmap);
     free(symbols);
     
     /* Collect and sort all symbols */
     num = collect_symbols(&symbols, is_var, 0);
     qsort(symbols, num, sizeof(*symbols), compare);
	       
     /* Produce output */
     begin();
    
     if (reverse_tree) {
	  for (i = 0; i < num; i++) {
	       inverted_tree(0, 0, symbols[i]);
	       separator();
	  }
     } else {
	  if ((main_sym = start_name ? lookup(start_name) : NULL) != NULL) {
	       direct_tree(0, 0, main_sym);
	       separator();
	  } else if (!all_functions) {
	       all_functions = 1;
	  }

	  if (all_functions) {
	       for (i = 0; i < num; i++) {
		    if (main_sym != symbols[i]
			&& symbols[i]->source
			&& (all_functions > 1 || symbols[i]->caller == NULL)) {
			 direct_tree(0, 0, symbols[i]);
			 separator();
		    }
	       }
	  }
     }
     
     end();
     
     free(symbols);
}

void
output()
{
     if (strcmp(outname, "-") == 0) {
	  outfile = stdout;
     } else {
	  outfile = fopen(outname, "w");
	  if (!outfile)
	       error(EX_FATAL, errno, _("cannot open file `%s'"), outname);
     } 
     
     set_level_mark(0, 0);
     if (print_option & PRINT_XREF) {
	  xref_output();
     }
     if (print_option & PRINT_TREE) {
	  tree_output();
     }
     fclose(outfile);
}






