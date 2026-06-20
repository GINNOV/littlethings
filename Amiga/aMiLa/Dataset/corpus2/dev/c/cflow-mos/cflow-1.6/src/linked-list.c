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

static struct linked_list *
deref_linked_list(struct linked_list **plist)
{
     if (!*plist) {
	  struct linked_list *list = xmalloc(sizeof(*list));
	  list->free_data = NULL;
	  list->head = list->tail = NULL;
	  *plist = list;
     }
     return *plist;
}


struct linked_list *
linked_list_create(linked_list_free_data_fp fun)
{
     struct linked_list *list = xmalloc(sizeof(*list));
     list->free_data = fun;
     list->head = list->tail = NULL;
     return list;
}

void
linked_list_append(struct linked_list **plist, void *data)
{
     struct linked_list *list = deref_linked_list (plist);
     struct linked_list_entry *entry = xmalloc(sizeof(*entry));

     entry->list = list;
     entry->data = data;
     entry->next = NULL;
     entry->prev = list->tail;
     if (list->tail)
	  list->tail->next = entry;
     else
	  list->head = entry;
     list->tail = entry;
}

#if 0
void
linked_list_prepend(struct linked_list **plist, void *data)
{
     struct linked_list *list = deref_linked_list (plist);
     struct linked_list_entry *entry = xmalloc(sizeof(*entry));
     
     entry->list = list;
     entry->data = data;
     if (list->head)
	  list->head->prev = entry;
     entry->next = list->head;
     entry->prev = NULL;
     list->head = entry;
     if (!list->tail)
	  list->tail = entry;
}
#endif

void
linked_list_destroy(struct linked_list **plist)
{
     if (plist && *plist) {
	  struct linked_list *list = *plist;
	  struct linked_list_entry *p;

	  for (p = list->head; p; ) {
	       struct linked_list_entry *next = p->next;
	       if (list->free_data)
		    list->free_data(p->data);
	       free(p);
	       p = next;
	  }
	  free(list);
	  *plist = NULL;
     }
}

void
linked_list_unlink(struct linked_list *list, struct linked_list_entry *ent)
{
     struct linked_list_entry *p;

     if ((p = ent->prev))
	  p->next = ent->next;
     else
	  list->head = ent->next;

     if ((p = ent->next))
	  p->prev = ent->prev;
     else
	  list->tail = ent->prev;
     if (list->free_data)
	  list->free_data(ent->data);
     free(ent);
}

void
linked_list_iterate(struct linked_list **plist, 
		    int (*itr) (void *, void *), void *data)
{
     struct linked_list *list;
     struct linked_list_entry *p;

     if (!*plist)
	  return;
     list = *plist;
     for (p = linked_list_head(list); p; ) {
	  struct linked_list_entry *next = p->next;

	  if (itr(p->data, data))
	       linked_list_unlink(list, p);
	  p = next;
     }
     if (!list->head)
	  linked_list_destroy(&list);
     *plist = list;
}

int
data_in_list(void *data, struct linked_list *list)
{
     struct linked_list_entry *p;
     
     for (p = linked_list_head(list); p; p = p->next)
	  if (p->data == data)
	       return 1;
     return 0;
}

size_t
linked_list_size(struct linked_list *list)
{
     size_t size = 0;
     if (list) {
	  struct linked_list_entry *p;
	  for (p = linked_list_head(list); p; p = p->next)
	       size++;
     }
     return size;
}

