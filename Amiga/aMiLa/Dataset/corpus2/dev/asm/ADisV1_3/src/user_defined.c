/*
 * Change history
 * $Log:	user_defined.c,v $
 * Revision 3.0  93/09/24  17:54:28  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:56:55  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:54:54  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.5  93/07/01  11:44:35  Martin_Apel
 * 
 * Revision 1.4  93/06/03  20:30:10  Martin_Apel
 * 
 * 
 */

#include <stdio.h>
#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: user_defined.c,v 3.0 93/09/24 17:54:28 Martin_Apel Exp $";

struct predef_label
  {
  struct predef_label *next;
  ULONG address;
  UWORD access;
  };

PRIVATE struct predef_label *predefined_labels = 0;

void predefine_label (ULONG address, UWORD access)

{
struct predef_label *new;

new = get_mem (sizeof (struct predef_label));
new->address = address;
new->access = access;
new->next = predefined_labels;
predefined_labels = new;
}

/***********************************************************************/

void add_predefined_labels ()

{
struct predef_label *tmp,
                    *to_be_deleted;

for (tmp = predefined_labels; tmp != 0;)
  {
  enter_ref (tmp->address, NULL, tmp->access);
  to_be_deleted = tmp;
  tmp = tmp->next;
  release_mem (to_be_deleted);
  }
}
