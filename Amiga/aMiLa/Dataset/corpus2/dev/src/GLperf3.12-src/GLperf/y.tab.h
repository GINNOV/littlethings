typedef union {
  AttributePtr attr;
  AttributeListPtr attrList;
  PropertyPtr prop;
  PropertyListPtr propList;
  PropNameListPtr propNameList;
  TestPtr test;
  TestListPtr testList;
  SuitePtr suite;
  int ival;
  float fval;
  double dval;
  short sval;
  unsigned uval;
} YYSTYPE;
#define	testName	258
#define	attrName	259
#define	wildcard	260
#define	PropName	261
#define	errorName	262
#define	openCurly	263
#define	closeCurly	264
#define	openBracket	265
#define	closeBracket	266
#define	openParen	267
#define	closeParen	268
#define	From	269
#define	To	270
#define	step	271
#define	Percent	272
#define	Printf	273
#define	comma	274


extern YYSTYPE yylval;
