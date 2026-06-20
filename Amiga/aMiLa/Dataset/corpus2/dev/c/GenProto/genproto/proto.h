/************************************************/
/* Prototypes and constants for proto.l / main.c*/
/*						*/
/* This file is part of genproto v1.2		*/
/* Copyright November 1996 by Nicolas Pomarede.	*/
/************************************************/


/********************************/
/*	Variables de proto.l	*/
/********************************/


#ifndef PROTO_H
#define PROTO_H


/* Les tokens renvoyés par yylex() */
/* yylex() renvoie 0 si EOF */

#define RESET		256
#define KEYWORD		257
#define ID		258
#define PARAMS		259
#define BLOC		260
#define DEUX_POINTS	261


#define	PARAMLEN	2000

extern int	lineno;
extern char	ParamBuf[ PARAMLEN ];
extern int	ParamBufLen;


int		yylex		( void );
void		yyrestart	( FILE *new_file );
extern char	*yytext;
extern int	yyleng;


#endif	/* PROTO_H */


/************************************************/
/*		FIN DE proto.h			*/
/************************************************/
