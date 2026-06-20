# ifndef yyPhoneLogScanner
# define yyPhoneLogScanner

/* $Id: Scanner.h,v 2.6 1992/08/07 15:29:41 grosch rel $ */

/* line 4 "PhoneLogScanner.rex" */
/* EXPORT */
         #include "StringMem.h"   /* For 'PutString' */
         #include "Idents.h"      /* For 'MakeIdent' */
         #include "Positions.h"
         #include "System.h"

         typedef struct {
                         tPosition  Position;
                         tStringRef lexstring;
                         int        number;
                        } PhoneLogScanner_tScanAttribute;

         extern void PhoneLogScanner_ErrorAttribute(int Token, PhoneLogScanner_tScanAttribute *Attribute);
         /* EXPORT */

# define PhoneLogScanner_EofToken	0

# ifdef lex_interface
#    define PhoneLogScanner_GetToken	yylex
#    define PhoneLogScanner_TokenLength	yyleng
# endif

extern	char *		PhoneLogScanner_TokenPtr	;
extern	short		PhoneLogScanner_TokenLength	;
extern	PhoneLogScanner_tScanAttribute	PhoneLogScanner_Attribute	;
extern	void		(* PhoneLogScanner_Exit) ()	;

extern	void		PhoneLogScanner_BeginScanner	(void);
extern	void		PhoneLogScanner_BeginFile	(char * yyFileName);
extern	int		PhoneLogScanner_GetToken	(void);
extern	int		PhoneLogScanner_GetWord	(char * yyWord);
extern	int		PhoneLogScanner_GetLower	(char * yyWord);
extern	int		PhoneLogScanner_GetUpper	(char * yyWord);
extern	void		PhoneLogScanner_CloseFile	(void);
extern	void		PhoneLogScanner_CloseScanner	(void);

# endif
