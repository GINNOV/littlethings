/* ----------------------------------------------------------------------- */

/* Example 21-2.c  - with parameter driven Exclusive ORing patch */

#include <exec/types.h>

#include <stdio.h>

#define MESSAGE1 "Please enter a string\n"

#define MESSAGE2 "Converted string is..........." 

#define MESSAGE3 "String after 2nd conversion..."

#define LINEFEED  10

#define MAX_CHARS 80

#define EOR_MASK  0x1F


main()

{

TEXT input_string[MAX_CHARS+1];    /* space for the user's string */

UBYTE EOR_mask=EOR_MASK;  /* Exclusive-ORing conversion mask */

WORD  keyboard_character; UBYTE count=0;

printf(MESSAGE1);

while ((keyboard_character=getchar())!=LINEFEED)
    
    {
    
    if (count<=MAX_CHARS) input_string[count++]=keyboard_character;
  
    };

input_string[count]=NULL;                  /* add terminal NULL */

Convert(input_string, EOR_mask);             /* EOR the string */

printf("%s %s \n",MESSAGE2,input_string);  /* show user converted string */

Convert(input_string, EOR_mask);             /* 2nd EOR operation */

printf("%s %s \n",MESSAGE3, input_string); /* show string again */

}

/* ----------------------------------------------------------------------- */
