#ifndef yyPhoneLogParser
  #define yyPhoneLogParser

/* $Id: Parser.h,v 2.1 1992/08/07 15:28:42 grosch rel $ */



  #ifdef yacc_interface
    #define PhoneLogParser yyparse
    #define yyInitStackSize YYMAXDEPTH
  #endif

extern char *PhoneLogParser_TokenName[];

int PhoneLogParser(void);
void ClosePhoneLogParser(void);

#endif
