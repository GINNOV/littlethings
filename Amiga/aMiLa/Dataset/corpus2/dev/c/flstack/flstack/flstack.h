#ifndef FLSTACK_H
#define FLSTACK_H

/******************************************\
*                                          *
*  Stack ADT (using a fixed length array)  *
*                                          *
*  Written by Giles Burdett                *
*  http://www.the-giant-sofa.demon.co.uk   *
*                                          *
\******************************************/


/* --== The Structure ==-- */

/* The stack pointer points at the currently occupied top item */
/* It does NOT point to the next available space!!! */


struct FLstack {
    int TOS;                 /* Top of stack */
    int MAXSTACK;            /* Maximum size of stack */
    int stack_array[1024];   /* The actual stack (of 4K in this case) */
};


/* Boolean defs */

typedef short BOOL;
#ifndef TRUE
    #define TRUE  1
#endif
#ifndef FALSE
    #define FALSE 0
#endif

/* --== The Functions ==-- */

/* All require a POINTER to a stack */


void FLstk_Make_Empty    (struct FLstack *S);                                                                                    /* Destroy all stack contents and reset stack pointer */

BOOL FLstk_Push          (struct FLstack *S, int value);                                                                               /* Push an item onto the top of the stack */

int  FLstk_Pop           (struct FLstack *S);                                                                                           /* Pop an item off the top of the stack ie. delete the top stack item */

int  FLstk_Top           (struct FLstack *S);                                                                                            /* Examine the top item on the stack WITHOUT destroying it */

BOOL FLstk_Is_Empty      (struct FLstack *S);                                                                                      /* Test the stack to see if it is empty */

BOOL FLstk_Is_Full       (struct FLstack *S);                                                                                       /* Test the stack to see if it is full */

int  FLstk_Height        (struct FLstack *S);                                                                                   /* Returns the height of the stack */

#endif

