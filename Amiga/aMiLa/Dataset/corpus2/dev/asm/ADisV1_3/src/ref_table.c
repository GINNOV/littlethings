/*
 * Change history
 * $Log:	ref_table.c,v $
 * Revision 3.0  93/09/24  17:54:26  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:56:51  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:54:50  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.18  93/07/01  11:44:25  Martin_Apel
 * 
 * Revision 1.17  93/06/16  20:29:30  Martin_Apel
 * Bug fix: Removed strlen calls in enter_ref, when it was uncertain that
 *          its parameter was NULL. ENFORCER Hits killed.
 * 
 * Revision 1.16  93/06/03  18:36:59  Martin_Apel
 * Minor mod.: Table size for symbol table is now derived from the size of
 *             the load file instead of from the sum of the hunk sizes
 * 
 */

#include <exec/types.h>
#include <string.h>
#include "defs.h"
#include "refs.h"

static char rcsid [] = "$Id: ref_table.c,v 3.0 93/09/24 17:54:26 Martin_Apel Exp $";

/**********************************************************************/
/* I'm using a combination of a doubly linked list and a hash table   */
/*        for maintaining a data base of referenced addresses.        */
/**********************************************************************/

#define HASH_FUNC(x) ((x)>>4)
#define SENTINEL     0xffffffff

PRIVATE struct mem_pool *current_pool,
                        *first_pool = NULL;

PRIVATE struct ref_entry **ref_table = NULL;
PRIVATE struct ref_entry **active_table = NULL;
PRIVATE long table_size;

/**************************************************************************/

BOOL init_ref_table (ULONG size)

{
/* A marker with address 0xffffffff is placed as the very last entry
   in the reference table. This speeds up all comparisons considerably.
*/
int i;
struct ref_entry *marker;

table_size = size / 16 + 2;

ref_table = get_mem (table_size * sizeof (struct ref_entry*));
active_table = get_mem (table_size * sizeof (struct ref_entry*));
first_pool = get_mem (sizeof (struct mem_pool) + POOLSIZE);

current_pool = first_pool;
first_pool->next = NULL;
first_pool->free = (POOLSIZE - sizeof (struct ref_entry)) / 2;   /* in words */
first_pool->next_free = (UWORD*)(first_pool + 1);   /* ptr behind mempool */
marker = (struct ref_entry*)first_pool->next_free;
first_pool->next_free += sizeof (struct ref_entry) / 2;

/* Enter marker (space already reserved) */

marker->next = NULL;
marker->prev = marker;
marker->next_active = NULL;
marker->prev_active = marker;
marker->offset = SENTINEL;
marker->name = NULL;
marker->access = ACC_UNKNOWN;

for (i = table_size - 1; i >= 0; i--)
  {
  *(ref_table + i) = marker;
  *(active_table + i) = marker;
  }

return (TRUE);
}

/**************************************************************************/

void kill_ref_table ()

{
struct mem_pool *tmp, *next;

for (tmp = first_pool; tmp != NULL; tmp = next)
  {
  next = tmp->next;
  release_mem (tmp);
  }

if (ref_table)
  release_mem (ref_table);
if (active_table)
  release_mem (active_table);
  
}

/**************************************************************************/

PRIVATE struct ref_entry *find_ref (ULONG offset, BOOL *found)

/* Returns a pointer to the desired ref_entry, if possible;
   otherwise returns pointer to the next entry in the table
*/
{
int entry;
register struct ref_entry *tmp;

entry = HASH_FUNC (offset);
/* For those labels which lie outside the segment (typically from geta4 ()) */
if (entry >= table_size)
  entry = table_size - 1;

for (tmp = *(ref_table + entry); tmp->offset < offset; tmp = tmp->next);

if (tmp->offset == offset)
  {
  *found = TRUE;       /* found it */
  return (tmp);
  }

*found = FALSE;
return (tmp);
}

/**************************************************************************/

PRIVATE struct ref_entry *find_active_ref (ULONG offset, BOOL *found)

/* Returns a pointer to the desired ref_entry, if possible;
   otherwise returns pointer to the next entry in the table
*/
{
int entry;
register struct ref_entry *tmp;

entry = HASH_FUNC (offset);
/* For those labels which lie outside the segment (typically from geta4 ()) */
if (entry >= table_size)
  entry = table_size - 1;

for (tmp = *(active_table + entry); tmp->offset < offset; tmp = tmp->next_active);

if (tmp->offset == offset)
  {
  *found = TRUE;       /* found it */
  return (tmp);
  }

*found = FALSE;
return (tmp);
}

/**************************************************************************/

BOOL find_reference (ULONG offset, char **name, UWORD *access_type)

{
BOOL found;
struct ref_entry *ref_entry;

ref_entry = find_ref (offset, &found);
if (found)
  {
  *name = ref_entry->name;
  *access_type = ref_entry->access;
  return (TRUE);
  }
else
  return (FALSE);
}

/**************************************************************************/

BOOL find_active_reference (ULONG offset, char **name, UWORD *access_type)

{
BOOL found;
struct ref_entry *ref_entry;

ref_entry = find_active_ref (offset, &found);
if (found)
  {
  *name = ref_entry->name;
  *access_type = ref_entry->access;
  return (TRUE);
  }
else
  return (FALSE);
}

/**************************************************************************/

void enter_ref (ULONG offset, char *name, UWORD access_type)

{
/* Upon calling "enter_ref" a label is always activated */

BOOL found;
struct ref_entry *tmp,
                 *tmp_active,
                 *new;
char *string;
register int index;
BOOL activate = FALSE;
int name_len;

tmp = find_ref (offset, &found);
if (name == NULL)
  name_len = 0;
else
  name_len = strlen (name);

if (found)
  {
  if ((tmp->name == NULL) && (name != NULL))
    {
    if (current_pool->free < (name_len + 2) / 2)
      {
      current_pool->next = get_mem (sizeof (struct mem_pool) + POOLSIZE);
      current_pool = current_pool->next;
      current_pool->free = POOLSIZE / 2;
      current_pool->next_free = (UWORD*)(current_pool + 1);
      current_pool->next = NULL;
      }
    string = (char*) current_pool->next_free;
    current_pool->next_free += (name_len + 2) / 2;
    current_pool->free -= (name_len + 2) / 2;
    strcpy (string, name);
    tmp->name = string;
    }

  activate = access_type & (~tmp->access);   /* activate this label,
                                                if there's new information */
  tmp->access |= access_type;
  }
else
  {
  if (current_pool->free < (sizeof (struct ref_entry) + name_len + 2) / 2)
    {
    current_pool->next = get_mem (sizeof (struct mem_pool) + POOLSIZE);
    current_pool = current_pool->next;
    current_pool->free = POOLSIZE / 2;
    current_pool->next_free = (UWORD*)(current_pool + 1);
    current_pool->next = NULL;
    }
  new = (struct ref_entry*) current_pool->next_free;
  current_pool->free -= (sizeof (struct ref_entry) + name_len + 2) / 2;
  current_pool->next_free += (sizeof (struct ref_entry) + name_len + 2) / 2;
  
  new->prev = tmp->prev;
  new->next = tmp;
  tmp->prev->next = new;
  tmp->prev = new;

  index = HASH_FUNC (offset);
  if (index >= table_size)
    index = table_size - 1;
  while (index >= 0 && (*(ref_table + index))->offset > offset)
    *(ref_table + index--) = new;
  tmp = new;

  new->offset = offset;
  string = (char*)(new + 1);
  new->access = access_type | ACC_NEW;
  if (name != NULL)
    {
    strcpy (string, name);
    new->name = string;
    }
  else
    new->name = NULL;
  activate = TRUE;
  }

if (activate)
  {
  /* Enter it into the active table */
  tmp_active = find_active_ref (offset, &found);
  if (found)
    return;        /* label is already in active list */

  tmp->access &= ~TMP_INACTIVE;
  tmp->prev_active = tmp_active->prev_active;         
  tmp->next_active = tmp_active;
  tmp_active->prev_active->next_active = tmp;
  tmp_active->prev_active = tmp;

  index = HASH_FUNC (offset);
  if (index >= table_size)
    index = table_size - 1;
  while (index >= 0 && (*(active_table + index))->offset > offset)
    *(active_table + index--) = tmp;
  }

return;
}

/**************************************************************************/

ULONG ext_enter_ref (ULONG offset, ULONG hunk, char *name, UWORD access_type)

{
/* enter_ref for addresses which lie outside their hunk.
   ext_enter_ref returns a special ID under which this label
   can be found again */
ULONG reference;

if (hunk > 253)
  {
  fprintf (stderr, "Sorry, can't handle files with more than 253 hunks\n");
  ExitADis ();
  }

reference = (offset & 0x00ffffff) | ((hunk + 1) << 24);
enter_ref (reference, name, access_type);
return (reference);
}

/**************************************************************************/

ULONG next_reference (ULONG from, ULONG to, UWORD *access)

{
register struct ref_entry *tmp;
register int index;

/* default case, only occurs for the end of a hunk */
#ifdef DEBUG
if (from >= to)
  {
  fprintf (stderr, "next_reference: from > to\n");
  return (to);
  }
#endif

index = HASH_FUNC (from);
if (index >= table_size)
  index = table_size - 1;

for (tmp = *(ref_table + index); tmp->offset <= from; tmp = tmp->next);

if (tmp->offset >= to)
  {
  *access = ACC_UNKNOWN;
  return (to);
  }
*access = tmp->access;
return (tmp->offset);
}

/**************************************************************************/

ULONG next_active_reference (ULONG from, ULONG to, UWORD *access)

{
register struct ref_entry *tmp;
register int index;

/* default case, only occurs for the end of a hunk */
#ifdef DEBUG
if (from >= to)
  {
  fprintf (stderr, "next_active_reference: from > to\n");
  return (to);
  }
#endif

index = HASH_FUNC (from);
if (index >= table_size)
  index = table_size - 1;

for (tmp = *(active_table + index); tmp->offset <= from; tmp = tmp->next_active);

if (tmp->offset > to)
  return (to);
*access = tmp->access;
return (tmp->offset);
}

/**************************************************************************/

#ifdef DEBUG

void check_active_table ()

{
struct ref_entry *tmp;
static int call_count = 0;

call_count++;
for (tmp = *active_table; tmp->offset != SENTINEL; tmp = tmp->next_active)
  {
  if (tmp->access & TMP_INACTIVE)
    {
    printf ("Found inactive label in active table\n");
    printf ("Called %d times\n", call_count);
    }
  }
}

#endif

/**************************************************************************/

void deactivate_labels (ULONG from, ULONG to)

{
/* Removes all labels in the range "from" to "to" from the active list.
   (excluding "to" itself) */
BOOL found;
struct ref_entry *tmp,
                 *next;
int index;

tmp = find_active_ref (from, &found);
while (tmp->offset < to)
  {
  next = tmp->next_active;
  next->prev_active = tmp->prev_active;
  tmp->prev_active->next_active = next;
  tmp->prev_active = tmp->next_active = NULL;
  tmp->access |= TMP_INACTIVE;
  tmp = next;
  }

index = HASH_FUNC (to);
if (index >= table_size)
  index = table_size - 1;
while (index >= 0 && (*(active_table + index))->offset >= from)
  *(active_table + index--) = tmp;
}

/**************************************************************************/

void make_labels_permanent ()

{
struct ref_entry *current_entry;

for (current_entry = *ref_table; current_entry->offset != SENTINEL; 
     current_entry = current_entry->next)
  current_entry->access &= ~(ACC_NEW | TMP_INACTIVE);
}

/**************************************************************************/

void delete_tmp_labels ()

{
struct ref_entry *current_entry;

/* It's not possible to free the memory of deleted labels now,
   it's automatically freed by kill_ref_table () at the end
   of the program */

for (current_entry = *ref_table; current_entry->offset != SENTINEL; 
     current_entry = current_entry->next)
  {
  if (current_entry->access & ACC_NEW)
    {
    ULONG offset;
    int index;

    current_entry->prev->next = current_entry->next;
    current_entry->next->prev = current_entry->prev;
    offset = current_entry->offset;
    index = HASH_FUNC (offset);
    if (index >= table_size)
      index = table_size - 1;
    while (index >= 0 && (*(ref_table + index))->offset == offset)
      *(ref_table + index--) = current_entry->next;

    /* Remove it from the active table as well */
    if (current_entry->next_active != NULL)
      {
      current_entry->prev_active->next_active = current_entry->next_active;
      current_entry->next_active->prev_active = current_entry->prev_active;
      offset = current_entry->offset;
      index = HASH_FUNC (offset);
      if (index >= table_size)
        index = table_size - 1;
      while (index >= 0 && (*(active_table + index))->offset == offset)
        *(active_table + index--) = current_entry->next_active;
      }
    }
  else if (current_entry->access & TMP_INACTIVE)
    {
    struct ref_entry *tmp_active;
    int index;
    BOOL found;
    ULONG offset;

    current_entry->access &= ~TMP_INACTIVE;
    offset = current_entry->offset;
    tmp_active = find_active_ref (offset, &found);
    if (found)
      fprintf (stderr, "INTERNAL ERROR: delete_tmp_labels: TMP_INACTIVE label in active list at address %lx\n", offset);
    current_entry->prev_active = tmp_active->prev_active;         
    current_entry->next_active = tmp_active;
    tmp_active->prev_active->next_active = current_entry;
    tmp_active->prev_active = current_entry;

    index = HASH_FUNC (offset);
    if (index >= table_size)
      index = table_size - 1;
    while (index >= 0 && (*(active_table + index))->offset > offset)
      *(active_table + index--) = current_entry;
    }
  }
}

/**************************************************************************/

#ifdef DEBUG
void print_ref_table (ULONG from, ULONG to)

{
register struct ref_entry *tmp;
int i;

printf ("References by chain\n");
i = HASH_FUNC (from);
for (tmp = *(ref_table + i); tmp->offset < to; tmp = tmp->next)
  {
  printf ("%06lx: Access: %04lx, %s\n", tmp->offset, tmp->access,
          tmp->name);
  }
/*
printf ("References by index:\n");
for (i = HASH_FUNC (from); i < HASH_FUNC (to); i++)
  printf ("First entry in chain %x: %lx\n", i, (*(ref_table + i))->offset);
*/
}

void print_active_table (ULONG from, ULONG to)

{
register struct ref_entry *tmp;
int i;

printf ("References by chain\n");
i = HASH_FUNC (from);
for (tmp = *(active_table + i); tmp->offset < to; tmp = tmp->next_active)
  {
  printf ("%06lx: Access: %04lx, %s\n", tmp->offset, tmp->access,
          tmp->name);
  }
/* 
printf ("References by index:\n");
for (i = HASH_FUNC (from); i < HASH_FUNC (to); i++)
  printf ("First entry in chain %x: %lx\n", i, (*(active_table + i))->offset);
*/
}


BOOL ref_exists (ULONG offset)

{
char *dummy;
UWORD access;

return (find_reference (offset, &dummy, &access));
}

#endif
