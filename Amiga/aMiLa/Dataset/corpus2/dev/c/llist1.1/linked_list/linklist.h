
/*=========================================================
  == PROGRAM NAME : linklist.h                           ==
  == --------------------------------------------------- ==
  == DESCRIPTION : header file for all the functions in  ==
  ==      the linked list library version 1.1            ==
  =========================================================
*/

#include <exec/memory.h>
#include <proto/exec.h>
#include <stdlib.h>

/*
 * here are some structures that can be used
 * the void * is for the user to define and 
 * control.  remember that if it is used a 
 * typedef will probably have to be used.
 * Also typedefing of user defined link structures
 * may be required to use some of these functions
 * without the compiler crying.
 *
 * NOTE : these structures don't have to be used but
 * the pointers to the links have to be included in any
 * user defined struct or none of these functions will work.
 */

typedef struct _single {
  struct _single  *next;
  void             *data;
} Single;

typedef struct _double {
  struct _double  *next;
  struct _double  *prev;
  void            *data;
} Double;

typedef struct _circle {
  struct _circle  *next;
  void              *data;
} Circle;

/*
 * standard functions for all the linked lists
 */
void *stdGetNewLink (int  /* size of the link */);  

/*
 * functions for single linked lists
 */
Single *singleGetNewLink (void);
Single *singleAttachBegin (Single *, Single *);
Single *singleAttachEnd (Single *, Single *);
Single *singleInsertLink (Single *, Single *);
Single *singleDeleteLink (Single *, Single *);
Single *singleSearch (void *, Single *);
Single *singleFindEnd (Single *);
void    singleDestroyList (Single *);

/*
 * functions for double linked lists
 */
Double *doubleGetNewLink (void);
Double *doubleAttachBegin (Double *, Double *);
Double *doubleAttachEnd (Double *, Double *);
Double *doubleInsertLink (Double *, Double *);
Double *doubleDeleteLink (Double *, Double *);
Double *doubleFindBegin (Double *);
Double *doubleFindEnd (Double *);
Double *doubleSearch (void *, Double *);
void    doubleDestroyList (Double *);

/*
 * functions for circular linked lists
 */
Circle *circleGetNewLink (void);
Circle *circleStartList (Circle *);
Circle *circleAttachEnd (Circle *, Circle *);
Circle *circleInsertLink (Circle *, Circle *);
Circle *circleDeleteLink (Circle *, Circle *);
Circle *circleSearch (void *, Circle *);
void    circleDestroyList (Circle *);
