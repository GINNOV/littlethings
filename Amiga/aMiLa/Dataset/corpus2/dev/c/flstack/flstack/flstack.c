/******************************************\
*                                          *
*  Stack ADT (using a fixed length array)  *
*                                          *
*  Written by Giles Burdett                *
*  http://www.the-giant-sofa.demon.co.uk   *
*                                          *
\******************************************/


#include "flstack.h"

void FLstk_Make_Empty (struct FLstack *S)      /* Destroy all stack contents and reset stack pointer */
{
    S->TOS=-1;
    S->MAXSTACK=1024;
}



BOOL FLstk_Push (struct FLstack *S, int value) /* Push an item onto the top of the stack */
{
    if (FLstk_Is_Full(S)==TRUE)
        return FALSE;

    S->TOS++;
    S->stack_array[S->TOS]=value;
    return TRUE;
}



int FLstk_Top (struct FLstack *S)              /* Examine the top item on the stack WITHOUT destroying it */
{
    return S->stack_array[S->TOS];
}



int FLstk_Pop (struct FLstack *S)              /* Retrieve top stack item and then delete it */
{
    int result;

    result=S->stack_array[S->TOS];
    S->TOS--;
    return result;
}



BOOL FLstk_Is_Empty (struct FLstack *S)        /* Test the stack to see if it is empty */
{
    if (S->TOS==-1)
        return TRUE;
    else
        return FALSE;
}



BOOL FLstk_Is_Full (struct FLstack *S)         /* Test the stack to see if it is full */
{
    if (S->TOS==S->MAXSTACK-1)
        return TRUE;
    else
        return FALSE;
}


int FLstk_Height (struct FLstack *S)           /* Return the height of the stack */
{
    return S->TOS+1;
}
