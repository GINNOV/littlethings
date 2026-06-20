// Modifié le Vendredi 14-Août-92 par Gilles Dridi
// Attention: les commandes préprocesseurs (#...) ne sont pas francisables.

#ifndef  EXEC_TYPESF_H
#define  EXEC_TYPESF_H

#ifndef MAIN
#define GLOBAL extern      /* déclaration externe par GLOBAL */
#else
#define GLOBAL
#define GLOBALE   GLOBAL
#endif

#define NEANT     void     /* le type néant ! */
#define statique  static   /* varaible locale statique */
#define registre  register /* variable registre */
#define amie      friend   /* pour déclarer une fonction amie */
#define operateur	operator	/* pour surcharger un opérateur sur classe */
#define virtuelle virtual  /* pour déclarer une fonction virtuelle */
#define classe    class    /* pour déclarer une classe */
#define protegee  protected /* pour une partie protégée d'une classe */
#define privee    private  /* pour une partie privee d'une classe */
#define construis new      /* construction dynamique d'une instance de classe */
#define detruis   delete   /* destruction dynamique d'une instance */
#define moiMeme   this     /* pointeur sur soi-même */
#define tailleDe  sizeof   /* occupation mémoire en octets d'une classe */
#define enLigne	inline	/* inclure le corps de la fonction en ligne */

#define si        if
#define sinon     else
#define tantQue   while
#define stoppe    break
#define fais      do
#define pour      for
#define aiguille  switch
#define cas       case
#define defaut		default
#define renvoie   return

typedef long      LONG;        /* quantité 32-bit signée */
typedef unsigned long   LONGN; /* quantité 32-bit non-signée */
typedef LONGN     LONGBITS;    /* quantité 32 bit manipulable bit à bit */
typedef short     MOT;         /* quantité 16-bit signée */
typedef unsigned short  MOTN;  /* quantité 16-bit non-signée */
typedef MOTN      MOTBITS;     /* quantité 16-bit manipulable bit à bit */
typedef char      OCTET;       /* quantité  8-bit signée */
typedef unsigned char  OCTETN; /* quantité  8-bit non-signée */
typedef OCTETN    BYTEBITS;    /* quantité  8-bit manipulable bit à bit */
typedef OCTETN    *PTRCHN;     /* pointeur sur chaîne */
typedef NEANT     *PTRNEANT;   /* pointeur sur néant */
typedef NEANT     *PTRBCPL;    /* pointeur sur néant multiplié par 4 */
typedef void (*Procedure)();   /* pointeur sur une procédure sans param. */

/* Types with specific semantics */
typedef float  FLOTTANT;
typedef float  REEL;
typedef int    ENTIER;
typedef double DOUBLE;
typedef MOT    BOOLEEN;
typedef OCTETN TEXTE;

const int VRAI= 1;
const int FAUX= 0;
#ifndef NULL
#define NULL 0
#endif
#define NUL    NULL
#define NULLE  NULL
#define MASQUEOCTET 0xFF

#ifndef  ENTMAX
#define  ENTMAX   2147483647
#endif

void exit(int);
/* GURU void Gripe(const char *msg, const char *m1 = NULL, const char *m2=NULL);
*/

inline estAmigaAff(TEXTE c) {
   return ((c >= 0x20) && (c <= 0x7E)) || ((c >= 0xA0) && (c <= 0xFF));
}

#endif
