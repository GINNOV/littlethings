/*------------------------------------------------------------------
 * ctok : C language tokenizer
 *------------------------------------------------------------------
 * 10-01-91 originally by Patrick J. Mueller
 *------------------------------------------------------------------*/

/*------------------------------------------------------------------
 * define
 *------------------------------------------------------------------*/
#define MAX_IDENT_LEN  255
#define MAX_OPER_LEN     3

/*------------------------------------------------------------------
 * typedefs
 *------------------------------------------------------------------*/
#define TOKEN_EOF            0           /* end of file             */
#define TOKEN_IDENT          1           /* identifier              */
#define TOKEN_NUMBER         2           /* number                  */
#define TOKEN_STRING         3           /* char or string constant */
#define TOKEN_PREPROC        4           /* preprocessor            */
#define TOKEN_COMMENT        5           /* comment                 */
#define TOKEN_OPER           6           /* operator                */

typedef struct
   {
   int            type;
   unsigned long  offs;
   unsigned long  len;
   unsigned long  line;
   char          *ident;
   } Token;

typedef unsigned long (*CTokRead)(
   void  *readInfo,
   char **buffer
   );

/*------------------------------------------------------------------
 * prototypes
 *------------------------------------------------------------------*/
void *CTokInit(
   CTokRead  readFunc,
   void     *readInfo
   );

void CTokTerm(
   void *handle
   );

void CTokGet(
   void     *handle,
   Token    *token
   );
