/************************************************/
/*                                              */
/*              Small-C compiler                */
/*                                              */
/*                by Ron Cain                   */
/*          modified by Willi Kusche            */
/*                                              */
/************************************************/

#define BANNER  "* * *  Small-C  V2.0  * * *"

/*      Define system dependent parameters      */


/*      Stand-alone definitions                 */


#define NULL 0
#define targeol 10

/*      UNIX definitions (if not stand-alone)   */


/* #include <stdio.h>   */
/* #define eol 13     */


/*      Define the symbol table parameters      */


#define symsiz  14
#define symtbsz 5040
#define numglbs 300
#define startglb symtab
#define endglb  startglb+numglbs*symsiz
#define startloc endglb+symsiz
#define endloc  symtab+symtbsz-symsiz


/*      Define symbol table entry format        */


#define name    0
#define ident   9
#define type    10
#define storage 11
#define offset  12


/*      System wide name size (for symbols)     */


#define namesize 9
#define namemax  8


/*      Define data for external symbols        */

#define extblsz 2000
#define startextrn exttab
#define endextrn exttab+extblsz-namesize-1

/* Possible types of exttab entries */
/* Stored in the byte following zero terminating the name */

#define rtsfunc 1
#define userfunc 2
#define statref 3


/*      Define possible entries for "ident"     */


#define variable 1
#define array   2
#define pointer 3
#define function 4
#define argument        5


/*      Define possible entries for "type"      */


#define cchar   1
#define cint    2
#define cchararg        3

/*      Define possible entries for "storage"   */


#define statik  1
#define stkloc  2


/*      Define the "while" statement queue      */


#define wqtabsz 100
#define wqsiz   4
#define wqmax   wq+wqtabsz-wqsiz


/*      Define entry offsets in while queue     */


#define wqsym   0
#define wqsp    1
#define wqloop  2
#define wqlab   3


/*      Define the literal pool                 */


#define litabsz 3000
#define litmax  litabsz-1


/*      Define the input line                   */


#define linesize 80
#define linemax linesize-1
#define mpmax   linemax


/*      Define the macro (define) pool          */


#define macqsize 1000
#define macmax  macqsize-1


/*      Define statement types (tokens)         */


#define stif    1
#define stwhile 2
#define streturn 3
#define stbreak 4
#define stcont  5
#define stasm   6
#define stexp   7


/* Define how to carve up a name too long for the assembler */


#define asmpref 7
#define asmsuff 7
