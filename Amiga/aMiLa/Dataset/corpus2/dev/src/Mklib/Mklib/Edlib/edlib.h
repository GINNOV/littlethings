/*
    edlib.h Copyright 1988 Edwin Hoogerbeets

    This code may be freely redistributed as long as no cost is levied
    for it and that this copyright notice remains intact.

    edlib contains a bunch of routines that are listed in H&S that are
    not in the Manx libraries. Also contains other public domain as well
    as freely redistributable routines.

    The library was compiled with Manx 3.6a.
*/
#include <exec/types.h>

/* character processing functions */
extern int   isbdigit();  /* is the character a `1' or a `0'? */
extern int   iscsym();    /* character part of a valid C symbol? */
extern int   iscsymf();   /* character valid a first char in a C symbol? */
extern int   toint();     /* converts a character 0..f to its hexadecimal value */
extern int   isodigit();  /* is this an octal digit? */

/* string processing functions */
extern int  bintoint();   /* these three take character strings and return the */
extern int  dectoint();   /* int value of the number in the string */
extern int  hextoint();
extern char *stoupper();  /* converts a string to entirely upper case chars */
extern char *stolower();  /* converts a string to entirely lower case chars */
extern int  strpos();     /* gives position of first occurance of char in string */
extern int  strrpos();    /* gives position of last occurance of char in string */
extern char *strrpbrk();
extern int  stricmp();    /* case insensitive string compare */
extern int  strnicmp();   /* " with a certain length */
extern int  strcspn();
extern char *strpbrk();   /* these four courtesy Daniel J. Barrett */
extern char *strtok();
extern int  strspn();

/* definitions to use getopt() */
extern int getopt();
extern char *optarg;
extern int optind;




