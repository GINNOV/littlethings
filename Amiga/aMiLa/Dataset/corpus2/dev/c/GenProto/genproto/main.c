/************************************************************************/
/* genproto			by Nicolas Pomarède			*/
/*				pomarede@isty-info.uvsq.fr		*/
/*									*/
/* 13-15/12/1995	v1.0	Première version.			*/
/*									*/
/* 06/01/1996			Changement message d'aide.		*/
/*									*/
/* 07/01/1996		v1.1	Option -d (debug ON)			*/
/*				Ignore ligne si CurrentPos atteint	*/
/*				MAX_TOKEN_PER_PROTOTYPE.		*/
/*				RESET si token PARAMS non suivi d'un	*/
/*				token BLOC juste après.			*/
/*				Fonction MyAlloc avec sortie si erreur.	*/
/* 11/11/1996		v1.2	option -b (banner OFF)			*/
/*				Vérification ParamBufLen < PARAMLEN.	*/
/*				option -f gère code \x et FORMATLEN.	*/
/*				Réécriture fichier README.		*/
/*									*/
/* Détermine les lignes correspondant à une définition de fonction.	*/
/* Les fonctions repérées sont ensuite affichées grâce à un printf	*/ 
/* personnalisable (incluant n° de ligne et nom du fichier).		*/
/* On peut ainsi générer un index de toutes les fonctions contenues	*/
/* dans un ensemble de fichiers C ou C++.				*/
/* Le programme repère les définitions de fonctions et non pas les	*/
/* déclarations (= prototypes).						*/
/* ex:									*/
/* void		main ( void );	<= déclaration ignorée			*/
/* void		main ( void )	<= définition détectée			*/
/* { ... }								*/
/* Les fonctions obtenues peuvent être ensuite triées.			*/
/*									*/
/* Utilisation : voir fonction Usage()					*/
/*									*/
/* This file is part of genproto v1.2					*/
/* Copyright November 1996 by Nicolas Pomarede.				*/
/************************************************************************/



#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

#include "proto.h"

/****************************************/
/*   Structures et Variables globales	*/
/****************************************/

#define TRUE		1
#define FALSE		0


#define MAX_TOKEN_PER_PROTOTYPE		50	/* sûrement jamais atteint */
#define	FORMATLEN	1000			/* taille FormatString */


struct function {
  struct function	*next;			/* liste chaînée */

  char			*ReturnParam;
  char			*ClassName;
  char			*FunctionName;
  char			*Param;
  int			Line;
  char			*File;
};


struct function		*pFirstF;		/* pour la liste chaînée */
struct function		*pLastF;

struct function		**TableFunctions;	/* tableaux de pointeurs */
int			NbFunctions;

int			LinePrototype;		/* n° de la ligne en cours */
char			*CurrentFileName;

FILE			*OutputFile;

int			DebugMode = FALSE;	/* pas de debug par défaut */
int			DisplayBanner = TRUE;	/* affiche BannerText */


/* Chaîne d'affichage par défaut */
char			FormatString[ FORMATLEN ] = "%R\t%C %S %N\t%P\tline %L, file %F\n";

/* Ordre de tri par défaut : classe, nom, fichier, ligne */
char			SortString[ 10 ] = "CNFL";

/* Chaîne vide, utilisée pour les fonctions sans ClassName */
char			EmptyString[] = "\0";

/* Message d'en-tête */
char	BannerText[] = "GenProto v1.2 (11/11/96) by Nicolas Pomarède\n\n";


/****************************************/
/*		Prototypes		*/
/****************************************/

void		Usage		( char *name );

char		*CharCopy	( char *buf , int len );
char		*AddTokens	( char **TokenList , int FirstToken , int LastToken );
void		AddPrototype	( char **TokenList , int ClassNamePos , int FunctionNamePos , int ParamPos );
void		ScanOneFile	( void );

void		SortPrototypes	( struct function **T , int Gauche , int Droite );
void		Swap		( struct function **T , int i , int j );
int		CompareFunctions( struct function *pF1 , struct function *pF2 );

void		CopyListToTable	( void );

void		PrintOnePrototype ( struct function *pF );
void		PrintPrototypes ( void );

void		DeletePrototypes( void );

void		*MyAlloc	( size_t size );
void		MyExit		( void );

void		main		( int argc , char **argv );





/************************************************************************/
/* Affiche un texte d'aide sur l'utilisation du programme "name".	*/
/************************************************************************/
void		Usage ( char *name )
{
  fprintf ( stderr , "genproto v1.2 (11/11/1996) © Nicolas Pomarède\n" );
  fprintf ( stderr , "Usage: %s [-h] [-d ] [-b] [-f<Format String>] [-s[CNFL]] [-o<Output File>] <Source Files>\n" , name );
  fprintf ( stderr ,
		"Each function is printed with Format String (similar to printf()).\n"
		"You can include the following %%-command:\n"
		"\t%%R : prints the return parameters of the function\n"
		"\t%%C : prints the ClassName of the function (if it exists)\n"
		"\t%%S : prints :: if the ClassName exists\n"
		"\t%%N : prints the name of the function\n"
		"\t%%P : prints the input parameters of the function\n"
		"\t%%L : prints the line number of the function\n"
		"\t%%F : prints the file where the function is declared\n"
		"Any other %%-command will cause the program to stop\n"
		"All the \\x escape sequences are recognized (\\n,\\t,...)\n"
		"except the octal and hexadecimal conversion (\\ooo and \\xhh)\n"
		"(These sequences must be preprocessed by your shell).\n"
		"The default is \"%%R\\t%%C %%S %%N\\t%%P\\tline %%L, file %%F\\n\"\n"
		"\n"
		"Functions might be sorted using the Sort String.\n"
		"The criterias allowed are C,N,F and L (same as in Format String)\n"
		"You can specify any number of criterias (up to 4).\n"
		"The default is CNFL.\n"
		"\n"
		"Results might be printed to Output File ; the default is stdout.\n"
		"\n"
		"-h prints this little help\n"
		"-d turns debug mode ON and prints all tokens\n"
		"-b turns banner off (the little copyright text)\n"
		"All others parameters are interpreted as files to be scanned.\n"
		"\n" );
}




/************************************************************************/
/* Alloue len+1 octets et copie la chaîne buf dedans.			*/
/* Retourne un pointeur sur la mémoire allouée.				*/
/************************************************************************/
char		*CharCopy ( char *buf , int len )
{
  char		*dest = (char *) MyAlloc ( len + 1 );

  strcpy ( dest , buf );
  return dest;
}



/************************************************************************/
/* Crée une chaîne correspondant à la concaténation des tokens		*/
/* FirstToken à LastToken et retourne un pointeur sur la chaîne créée.	*/
/* Les tokens sont séparés par un caractère ' ', sauf les '*' qui ne	*/
/* sont pas suivis de ' ' (pour que "**" ne donne pas "* *").		*/
/* Il n'y a pas de ' ' à la fin de la chaîne résultat.			*/
/************************************************************************/
char		*AddTokens ( char **TokenList , int FirstToken , int LastToken )
{
  int		i;
  int		Len = 0;
  char		*res , *s , *d;


  for ( i = FirstToken ; i <= LastToken ; i++ )
    Len += strlen ( TokenList[ i ] ) + 1;	/* ajoute un ' ' après chaque token */

  res = (char *) MyAlloc ( Len + 1 );		/* pour le '\0' */

  *res = '\0';					/* chaîne vide */
  d = res;

  /* Concatène tous les tokens dans res en les séparant par un ' ' */
  for ( i = FirstToken ; i <= LastToken ; i++ )
    {
      s = TokenList[ i ];
      while ( *d++ = *s++ )			/* copie TokenList[ i ], '\0' inclu */
	;

      d--;					/* revient sur le '\0' */
      if ( *(d-1) != '*' )			/* rajoute un ' ' après le token */
	*d++ = ' ';				/* s'il ne s'agit pas d'un '*' */
    }

  if ( *(d-1) == ' ' )				/* enlève le ' ' final */
    *(d-1) = '\0';
  else
    *d = '\0';

  return res;
}



/************************************************************************/
/* Ajoute un prototype à la liste déjà existante.			*/
/* Un prototype est caractérisé par une liste de tokens, la position	*/
/* du nom de la classe, la position du nom de la fonction et la position*/
/* de la liste de paramètres.						*/
/* Les tokens 0 à ClassNamePos/FunctionNamePos constituent les types	*/
/* de retour.								*/
/************************************************************************/
void		AddPrototype ( char **TokenList , int ClassNamePos , int FunctionNamePos , int ParamPos )
{
  struct function	*pNewF = MyAlloc ( sizeof ( struct function ) );


  /* Recrée les paramètres de retour */
  if ( ClassNamePos >= 0 )
    pNewF->ReturnParam = AddTokens ( TokenList , 0 , ClassNamePos-1 );
  else
    pNewF->ReturnParam = AddTokens ( TokenList , 0 , FunctionNamePos-1 );

  if ( !pNewF->ReturnParam )			/* erreur AddToken ? */
    exit ( 1 );


  /* Recopie le token ClassName s'il existe */
  if ( ClassNamePos >= 0 )
    {
      pNewF->ClassName = MyAlloc ( strlen ( TokenList[ ClassNamePos ] ) + 1 );
      pNewF->ClassName = strcpy ( pNewF->ClassName , TokenList[ ClassNamePos ] );
    }
  else pNewF->ClassName = EmptyString;


  /* Recopie le token FunctionName */
  pNewF->FunctionName = MyAlloc ( strlen ( TokenList[ FunctionNamePos ] ) + 1 );
  pNewF->FunctionName = strcpy ( pNewF->FunctionName , TokenList[ FunctionNamePos ] );


  /* Recopie le token Param */
  pNewF->Param = MyAlloc ( strlen ( TokenList[ ParamPos ] ) + 1 );
  pNewF->Param = strcpy ( pNewF->Param , TokenList[ ParamPos ] );

  pNewF->next = NULL;
  pNewF->Line = LinePrototype;
  pNewF->File = CharCopy ( CurrentFileName , strlen ( CurrentFileName ) );


  if ( pLastF )
    {
      pLastF->next = pNewF;		/* ajoute à la liste chaînée */
      pLastF = pNewF;
    }
  else
    pFirstF = pLastF = pNewF;		/* crée la liste chaînée */


  if ( DebugMode )
    {
      fprintf ( stderr , "\nAdding declaration: file %s line %d\n" , CurrentFileName , LinePrototype );
      fprintf ( stderr , "\treturn <%s>\n" , pNewF->ReturnParam );
      fprintf ( stderr , "\tclass  <%s>\n" , pNewF->ClassName );
      fprintf ( stderr , "\tname   <%s>\n" , pNewF->FunctionName );
      fprintf ( stderr , "\tparam  <%s>\n\n" , pNewF->Param );
    }
}



/************************************************************************/
/* Récupère les tokens renvoyés par yylex() dans une pile.		*/
/* Lorsqu'on arrive au token BLOC, on crée un nouveau prototype ; sinon	*/
/* la pile est vidée à chaque token non satisfaisant.			*/
/************************************************************************/
void		ScanOneFile ( void )
{
  char		*TokenList[ MAX_TOKEN_PER_PROTOTYPE ];
  int		ClassNamePos , FunctionNamePos , ParamPos;
  int		CurrentPos;
  int		Val;
  int		i;


  CurrentPos = 0;			/* pointe début de la pile */
  ClassNamePos = -1234;
  FunctionNamePos = -1;
  ParamPos = -1;


  while ( ( Val = yylex() ) != 0 )	/* while !feof() */
    {
      if ( DebugMode )
	{
	  fprintf ( stderr , "tokenid %d, val <%s>, len %d\n" , Val , yytext , yyleng );
	  fprintf ( stderr , " CurrentPos %d ClassNamePos %d" , CurrentPos , ClassNamePos );
	  fprintf ( stderr , " FunctionNamePos %d ParamPos %d\n" , FunctionNamePos , ParamPos );
	}

      /* Empêche dépassement de la pile des tokens lus */
      if ( CurrentPos == MAX_TOKEN_PER_PROTOTYPE )
	{
	  fprintf ( stderr , "Too many tokens in file %s line %d !!\n" ,
			CurrentFileName , LinePrototype );
	  Val = RESET;			/* force un abandon du prototype en cours */
	}


      if ( ParamPos != -1 )		/* liste des paramètres trouvée */
					/* gère cas du C++ */
	if ( Val == ':' )		/* constructeur de classe de base */
	  while ( Val != BLOC )
	    {
	      Val = yylex();
	      if ( Val == 0 )		/* BLOC non trouvé */
		{ fprintf ( stderr , "base constructor not found in file %s line %d !!\n" ,
				CurrentFileName , LinePrototype );
		  goto End;
		}
	    }
	else if ( Val != BLOC )
	  Val = RESET;			/* RESET si PARAMS non suivi par BLOC */


      switch ( Val ) {
	case KEYWORD:
	case ID:
			LinePrototype = lineno;
			TokenList[ CurrentPos++ ] = CharCopy ( yytext , yyleng );
			break;
	case DEUX_POINTS:
			ClassNamePos = CurrentPos-1;
			break;

	case PARAMS:	if ( ClassNamePos == -1 )	/* impossible */
			  break;
			if ( CurrentPos == 0 )		/* impossible */
			  break;

			FunctionNamePos = CurrentPos-1;
			ParamPos = CurrentPos;
			TokenList[ CurrentPos++ ] = CharCopy ( ParamBuf ,ParamBufLen );
			break;

	case BLOC:	if ( ParamPos != -1 )
			  AddPrototype ( TokenList , ClassNamePos , FunctionNamePos , ParamPos );
			/* effectue un RESET après */

	default:	/* RESET */

	case RESET:	if ( CurrentPos )
			  for ( i=0 ; i < CurrentPos ; i++ )
			    free ( TokenList[ i ] );

			CurrentPos = 0;
			ClassNamePos = -1234;		/* valeur < -1 */
			FunctionNamePos = -1;
			ParamPos = -1;
			break;
	}
    }


End:

  if ( CurrentPos )			/* libère contenu de la pile */
    for ( i=0 ; i < CurrentPos ; i++ )
      free ( TokenList[ i ] );
}




/************************************************************************/
/* Tri le tableau T entre Gauche et Droite inclus avec un quicksort.	*/
/* Le tableau T contient des pointeurs sur toutes les fonctions trouvées*/
/* Le tri est effectué dans l'ordre croissant.				*/
/************************************************************************/
void		SortPrototypes ( struct function **T , int Gauche , int Droite )
{
  int		i , Last;

  if ( Gauche >= Droite )
    return;				/* moins de 2 éléments */

  Swap ( T , Gauche , ( Gauche + Droite ) / 2 );
  Last = Gauche;

  for ( i = Gauche+1 ; i<= Droite ; i++ )
    if ( CompareFunctions ( T[ i ], T[ Gauche ] ) < 0 )
      Swap ( T , ++Last , i );

  Swap ( T , Gauche , Last );
  SortPrototypes ( T , Gauche , Last-1 );
  SortPrototypes ( T , Last+1 , Droite );
}



/************************************************************************/
/* Echange T[ i ] et T[ j ]						*/
/************************************************************************/
void		Swap ( struct function **T , int i , int j )
{
  struct function *pF;

  pF = T[ i ];
  T[ i ] = T[ j ];
  T[ j ] = pF;
}



/************************************************************************/
/* Compare les 2 fonctions pF1 et pF2 suivant les critères de SortString*/
/* pF1 et pF2 peuvent être comparées suivant 4 critères : C, N, F et L	*/
/* Dès que l'un des critères permet de différencier pF1 et pF2, on	*/
/* retourne un nombre >0 ou <0. Sinon, si les champs comparés étaient	*/
/* égaux, on lit un nouvel élément de SortString et on recompare pF1 et	*/
/* pF2 en fonction de cet élément.					*/
/* Par défaut, on compare ClassName, puis FunctionName, puis File et	*/
/* enfin Line.								*/
/*									*/
/* Retourne	<0	si pF1 < pF2					*/
/*		>0	si pF1 > pF2					*/
/*		0	si pF1 = pF2					*/
/************************************************************************/
int		CompareFunctions ( struct function *pF1 , struct function *pF2 )
{
  char		*p = SortString;
  char		c;
  int		res;

  while ( c=*p++ )
    switch ( c ) {
	case 'C':
		res = strcmp ( pF1->ClassName , pF2->ClassName );
		if ( res )
		  return res;
		break;
	case 'N':
		res = strcmp ( pF1->FunctionName , pF2->FunctionName );
		if ( res )
		  return res;
		break;
	case 'F':
		res = strcmp ( pF1->File , pF2->File );
		if ( res )
		  return res;
		break;
	case 'L':
		res = pF1->Line - pF2->Line;
		if ( res )
		  return res;
		break;
	default:
		fprintf ( stderr , "Unknown sort parameter '%c'\n" , c );
		exit ( 1 );
      }

  return res;
}




/************************************************************************/
/* Recopie les adresses de toutes les fonctions trouvées dans un tableau*/
/* de pointeurs.							*/
/* En sortie, on met à jour NbFunctions et TableFunctions.		*/
/************************************************************************/
void		CopyListToTable	( void )
{
  struct function	*pF;
  int			i;

  NbFunctions = 0;

  pF = pFirstF;
  if ( !pF )
    return;

  while ( pF )
    {
      NbFunctions++;
      pF = pF->next;
    }

  /* alloue un tableau de NbFunctions pointeurs */
  TableFunctions = (struct function **) MyAlloc ( NbFunctions * sizeof ( struct function *) );

  if ( !TableFunctions )
    exit ( 1 );

  pF = pFirstF;
  for ( i = 0 ; i < NbFunctions ; i++ )
    {
      TableFunctions[ i ] = pF;		/* remplit le tableau de pointeurs */
      pF = pF->next;
    }
}




/************************************************************************/
/* Affiche un prototype en fonction de la chaîne de formatage.		*/
/* Les caractères autorisés sont les suivants:				*/
/*	%R : paramètre de retour					*/
/*	%C : nom de la classe (s'il existe)				*/
/*	%S : affiche séparateur "::" s'il y a un nom de classe		*/
/*	%N : nom de la fonction						*/
/*	%P : paramètres de la fonction					*/
/*	%L : ligne de début de la déclaration				*/
/*	%F : fichier							*/
/* On balaie FormatString jusqu'à trouver un '%'; à ce moment,on affiche*/
/* tous les caractères précédents (depuis StartPtr) avec un printf et on*/
/* affiche un texte en fonction du caractère suivant '%'.		*/
/* On continue jusqu'à la fin de FormatString.				*/
/************************************************************************/
void		PrintOnePrototype ( struct function *pF )
{
  char		*StartPtr , *Ptr;
  char		c;

  StartPtr = Ptr = FormatString;

  while ( c = *Ptr )
    if ( c == '%' )			/* caractère d'affichage d'un champ */
      {
	*Ptr = '\0';			/* remplace '%' par '\0' */
	printf ( StartPtr );		/* affiche jusqu'à '%' */
	*Ptr++ = '%';			/* restaure '%' pour les prochains appels */
	switch ( *Ptr ) {
		case 'R':	printf ( "%s" , pF->ReturnParam );
				break;
		case 'C':	if ( pF->ClassName[ 0 ] )	/* chaîne non vide */
				  printf (  "%s" , pF->ClassName );
				break;
		case 'S':	if ( pF->ClassName[ 0 ] )	/* chaîne non vide */
				  printf ( "::" );
				break;
		case 'N':	printf ( "%s" , pF->FunctionName );
				break;
		case 'P':	printf ( "%s" , pF->Param );
				break;
		case 'L':	printf ( "%d" , pF->Line );
				break;
		case 'F':	printf ( "%s" , pF->File );
				break;
		default:	fprintf ( stderr , "Unknown format %%%c, aborting\n" , *Ptr );
				exit ( 1 );
	  }
	Ptr++;				/* saute le caractère d'affichage */
        StartPtr = Ptr;
      }

    else				/* caractère != '%' */
      Ptr++;

  printf ( StartPtr );			/* affiche la fin de Format String */
}



/************************************************************************/
/* Affiche tous les prototypes créés.					*/
/************************************************************************/
void		PrintPrototypes ( void )
{
  int			i;


  if ( DisplayBanner )
    printf ( "%s" , BannerText );	/* texte d'info sur genproto */

  if ( NbFunctions == 0 )
    return;

  for ( i = 0 ; i < NbFunctions ; i++ )
    PrintOnePrototype ( TableFunctions[ i ] );
}




/************************************************************************/
/* Efface tous les prototypes déjà créés.				*/
/************************************************************************/
void		DeletePrototypes ( void )
{
  struct function	*pF;
  struct function	*pFnext;

  pF = pFirstF;
  while ( pF )
    {
      free ( pF->ReturnParam );
      if ( pF->ClassName != EmptyString );
        free ( pF->ClassName );
      free ( pF->FunctionName );
      free ( pF->Param );
      free ( pF->File );

      pFnext = pF->next;
      free ( pF );
      pF = pFnext;
    }

  pFirstF = pLastF = NULL;


  if ( TableFunctions )
    free ( TableFunctions );
  TableFunctions = NULL;
}




/************************************************************************/
/* Fonction appelée en cas d'appel à exit() (suite à une erreur).	*/
/* Libère la mémoire allouée avant de sortir.				*/
/************************************************************************/
void		MyExit ( void )
{
  if ( pFirstF )
    DeletePrototypes ();
}




/************************************************************************/
/* Fonction d'allocation mémoire avec récupération des erreurs.		*/
/* On appelle malloc(), et en cas d'erreurs, on sort par exit( 1 ).	*/
/* Cette fonction retourne toujours un résultat != NULL.		*/
/************************************************************************/
void		*MyAlloc ( size_t size )
{
  void		*res;

  res = malloc ( size );

  if ( res )
    return res;

  fprintf ( stderr , "Malloc Error for %u bytes\n" , size );
  exit ( 1 );
}





/************************************************************************/
/* Fonction principale ; les options possibles sont -h, -o, -s et -f.	*/
/* On reparcourt ensuite tous les argv[] et on scanne tous les fichiers	*/
/* dont le nom ne commence pas par '-'.					*/
/* La liste chaînée ainsi créée est recopiée dans un tableau afin d'être*/
/* éventuellemnt triée, puis affichée et détruite.			*/
/************************************************************************/
void		main ( int argc , char **argv )
{
  char		*s;
  char		*d;
  char		c;
  int		Use_Error = FALSE;
  int		i , len;
  FILE		*CurrentFile;
  int		SortFlag = FALSE;

  atexit ( MyExit );			/* intercepte exit() */
  OutputFile = stdout;			/* affichage par défaut sur stdout */


  /* Analyse des options de la ligne de commande */

  i = 1;
  while ( i < argc )
    {
      if ( argv[ i ][ 0 ] == '-' )
	switch ( argv[ i ][ 1 ] ) {
	  case 's':
		s = argv[ i ] + 2;	/* pointe après "-s" */
		d = SortString;

		SortFlag = TRUE;
		if ( !*s )			/* s'il n'y a rien après "-s" */
		  break;
		while ( *d++ = *s++ )		/* recopie la suite de "-s" */
		  ;				/* dans SortString */
		break;

	  case 'f':
		s = argv[ i ] + 2;	/* pointe après "-f" */
		d = FormatString;

		if ( !*s )			/* s'il n'y a rien après "-f" */
		  break;
		len = 1;
		while ( c = *s++ )		/* traite la suite de "-f" */
		  {
		    if ( c == '\\' )
		      switch ( c = *s++ ) {
			case 'n':	*d++ = '\n';	break;
			case 't':	*d++ = '\t';	break;
			case 'v':	*d++ = '\v';	break;
			case 'b':	*d++ = '\b';	break;
			case 'r':	*d++ = '\r';	break;
			case 'f':	*d++ = '\f';	break;
			case 'a':	*d++ = '\a';	break;
			default :	*d++ = c;	break;	/* \c devient c */
			}

		    else
		      *d++ = c;

		    len++;
		    if ( len == FORMATLEN-1 )
		      {
		        fprintf ( stderr , "Format String too long\n" );
		        exit ( 1 );
		      }
		  }

		*d = '\0';			/* fin de FormatString */
		break;

	  case 'o':				/* redirige stdout */
		s = argv[ i ] + 2;		/* pointe le nom après "-o" */
		if ( !freopen ( s , "w" , stdout ) )
		  {
		    fprintf ( stderr , "Can't open %s for output\n" , s );
		    exit ( 1 );
		  }
		break;

	  case 'h':
		Use_Error = TRUE;		/* affiche syntaxe de genproto */
		break;

	  case 'd':
		DebugMode = TRUE;		/* affiche info de debugging */
		break;

	  case 'b':
		DisplayBanner = FALSE;		/* n'affiche plus BannerText */
		break;

	  default:
		fprintf ( stderr, "Unknown option %s\n" , argv[ i ] );
		Use_Error = TRUE;
		break;
	  }
      i++;				/* argv suivant */
    }

  if ( Use_Error )
    {
      Usage ( argv[ 0 ] );
      exit ( 1 );
    }


  /* Tous les argv[ i ] ne commençant pas par '-' sont interprétés comme */
  /* des noms de fichiers à scanner. */

  i = 1;
  while ( i < argc )
    {
      if ( argv[ i ][ 0 ] != '-' )
	{
	  CurrentFileName = argv[ i ];
	  CurrentFile = fopen ( CurrentFileName , "r" );

	  if ( CurrentFile )
	    {
	      yyrestart ( CurrentFile );	/* initialise yylex() */
	      lineno = 1;
	      ScanOneFile ();
	      fclose ( CurrentFile );
	    }
	  else
	    fprintf ( stderr , "Error opening %s\n" , argv[ i ] );
	}
      i++;					/* argv suivant */
    }


  CopyListToTable ();				/* recopie la liste chaînée */

  if ( SortFlag )
    SortPrototypes ( TableFunctions , 0 , NbFunctions-1 );

  PrintPrototypes ();
  DeletePrototypes ();
}


/************************************************************************/
/*				END main.c				*/
/************************************************************************/
