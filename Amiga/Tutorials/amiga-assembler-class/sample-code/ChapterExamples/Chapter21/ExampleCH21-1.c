/* ----------------------------------------------------------------------- */

/* Example 21-1.c  - uses Exclusive ORing patch via GLOBAL variables */

#include <exec/types.h>

#include <stdio.h>

#define MESSAGE1 "Please enter a string\n"

#define MESSAGE2 "Converted string is..........." 

#define MESSAGE3 "String after 2nd conversion..."

#define LINEFEED  10

#define MAX_CHARS 80

#define EOR_MASK  0x1F

TEXT g_input_string[MAX_CHARS+1];    /* space for the user's string */

UBYTE g_EOR_mask=EOR_MASK;  /* Exclusive-ORing conversion mask */


main()

{

WORD  keyboard_character; UBYTE count=0;

printf(MESSAGE1);

while ((keyboard_character=getchar())!=LINEFEED)
    
    {
    
    if (count<=MAX_CHARS) g_input_string[count++]=keyboard_character;
  
    };

g_input_string[count]=NULL;                  /* add terminal NULL */

Convert();                                   /* EOR the string */

printf("%s %s \n",MESSAGE2,g_input_string);  /* show user converted string */

Convert();                                   /* 2nd EOR operation */

printf("%s %s \n",MESSAGE3, g_input_string); /* show string again */

}

/* ----------------------------------------------------------------------- */

