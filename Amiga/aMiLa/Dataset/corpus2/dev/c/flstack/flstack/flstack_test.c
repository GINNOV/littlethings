/******************************************\
*                                          *
*  FLstack ADT test program                *
*                                          *
*  Written by Giles Burdett                *
*  http://www.the-giant-sofa.demon.co.uk   *
*                                          *
\******************************************/


#include "flstack.h"
#include <stdio.h>


void display_stack (struct FLstack *S);

int main()
{
    struct FLstack my_stack;

    FLstk_Make_Empty(&my_stack);  /* Initialise stack structure */
    display_stack(&my_stack);     /* stack contents = Empty */
    FLstk_Push(&my_stack, 1);
    display_stack(&my_stack);     /* stack contents = 1 */
    FLstk_Push(&my_stack, 2);
    display_stack(&my_stack);     /* stack contents = 1, 2 */
    printf("Top item is %d\n", FLstk_Top(&my_stack)); /* output = 2 */
    display_stack(&my_stack);     /* stack contents = 1, 2 */

    printf("Top item was %d\n", FLstk_Pop(&my_stack)); /* output = 2 */

    display_stack(&my_stack);     /* stack contents = 1 */
    FLstk_Pop(&my_stack);
    display_stack(&my_stack);     /* stack contents = Empty */
    
    return 0;
}


void display_stack (struct FLstack *S)
{
    int count;

    if (FLstk_Is_Empty(S)==TRUE)
        puts("It's empty!");

    for (count=0; count<=S->TOS; count++)
        printf ("%d, ",S->stack_array[count]);
    puts("");
}
