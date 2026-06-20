#define NUMBER 257
#define HEXSTRING 258
#define EXIT 259
#define OR 260
#define AND 261
#define EOL 262
#define PLUS 263
#define MINUS 264
#define STAR 265
#define SLASH 266
#define PERCENT 267
#define LPAREN 268
#define RPAREN 269
#define XOR 270
#define EQUAL 271
#define YYEOF 272
#define BITINVERT 273
#define LSHIFT 274
#define RSHIFT 275
#define DOLLAR 276
typedef union   {

   char  *y_str;   /* ID     */
   int    y_num;   /* Number */
   float  y_float; /* Float  */

   } YYSTYPE;
extern YYSTYPE yylval;
