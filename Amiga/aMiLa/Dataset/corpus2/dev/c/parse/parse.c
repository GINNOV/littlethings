/*----------------------------------------*\
>  parse.c : (c) 1992 Jean-Pierre RIVIERE  <
\*----------------------------------------*/

#include <stdlib.h>
#ifdef AMIGA
#  include <exec/types.h>
#  include <exec/memory.h>
#else
#  define  FreeMem(ptr,size)       free(ptr)
#  define  AllocMem(size,type)     malloc(size)
#  ifndef NULL
#     define NULL 0L
#  endif
#endif

#include "parse.h"

#ifdef NO_PARSE_ERR_MESS
#  define report_error(erreur)
#else /* NO_PARSE_ERR_MESS */
   char * ParseErrMess;
#  define report_error(erreur)  ParseErrMess = ParseErrorMessage[(erreur) - 1]
#define         ERR_MESS_WITH_LETTER
#  ifndef ERR_MESS_WITHOUT_LETTER
#     define ERR_LETTER " %c"
#  else /* ERR_MESS_WITHOUT_LETTER */
#     define ERR_LETTER
#  endif /* ERR_MESS_WITHOUT_LETTER */
#  ifndef ENGLISH
   static const char * ParseErrorMessage [] = {
      "Manque de mémoire",
      "Appel de fonction erroné",
      "option" ERR_LETTER " inconnue",
      "option oubliée après le tiret",
      "option" ERR_LETTER " répétée",
      "argument de l'option" ERR_LETTER " absent",
      "argument collé à l'option" ERR_LETTER,
      "option" ERR_LETTER " à argument devant être isolée"
   };
#  else /* ENGLISH  */
   static char * ParseErrorMessage [] = {
      "lack of memory",
      "wrong function call",
      "unknown option" ERR_LETTER,
      "forgotten option after the dash",
      "repeated option" ERR_LETTER,
      "lacking an argument after option" ERR_LETTER,
      "argument stuck to option" ERR_LETTER,
      "option" ERR_LETTER " with argument is not lonesome"
   };
#  endif   /* ENGLISH  */
#  undef ERR_LETTER
#endif   /* NO_PARSE_ERR_MESS */

/* données statiques pour la gestion des appels
   statistical data for managing the calls      */
static char * Options;     /* ensemble des options    ## set of options       */
static char ** Arguments;  /* ensemble des arguments  ## set of arguments     */
static short Taille;       /* taille du descriptif    ## size of description  */

static char parse_option (char *, struct rapport *, short *);

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

static char * strseek (char * s, char r)
  /** entrée                              *** input
      s  : chaîne à parcourir              : string to parse
      r  : caractère à trouver             : character to look for
  *** valeur                              *** value
      pointeur sur le premier caractère r    pointer on the first r character
      de la chaîne ou sur sa fin             or on the end of the string
  **/

/*** recherche un caractère dans une chaîne décrivant les options
     looks for a character in an options-describing string        ***/

{
   while (*s != r && *s)
      s += 2;  /* le format de la chaîne impose cet incrément de deux
                  the string format needs that increment of two         */
   return s;
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

char parse_cleanup (void)
   /** sortie                             *** output
      1 ssi quelque chose a été nettoyé      1 if something was cleansed
      0 sinon (appel en faute)               0 else (wrong call)
   **/
{
   if (!Taille)
      return 0;
   if (Arguments)
      FreeMem(Arguments, (--Taille) << 1);
   if (Options)
      FreeMem(Options, Taille >> 1);
   /* un deuxieme appel a parse_cleanup doit etre tolérable
      a second call to parse_cleanup has to be tolerated    */
   Taille = 0;
   return 1;
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

/* macro pour alléger la suite du programme
   macro to light up the program             */
#define probleme(rap,opt,val,err)  { \
        (rap)->erreur = (val); report_error((rap)->erreur);  \
        (rap)->lettre = (opt); parse_cleanup(); return (err); }

char parse (char * descrip, int argc, char ** argv,
      struct rapport * rapport)
   /** entrée                             *** input
      descrip  : descripteur des options   : description of the options
      argc     : nombre de paramètres      : number of parameters
      argv     : vecteurs des paramètres   : parameters vector
   *** sortie                             *** output
      rapport  : indicateur d'activité     : indicates what's happened
   *** valeur                             *** value
      nul ssi il y a eu erreur             : zero only in case of error
   **/

/*** parcours la ligne à la recherche des options selon le format indiqué
     parse the command line for options according to the indicated format ***/

{
   char *   opt;     /* chaîne des options      ## options string       */
   short    nopt;    /* nombre d'options        ## number of options    */

   /* vérification de l'appel
      check the call          */
   if (Taille) {
      rapport->erreur = OPT_WRONG_CALL;
      rapport->lettre = '\0';
      return 0;
   }
   /* préparation du parcours
      parsing preparation     */
   rapport->parg = argv + 1;
   rapport->narg =  argc - 1;
   opt = descrip;
   Taille = 1 + (nopt = strlen(opt) >> 1);
#  ifdef AMIGA
   if (!(Options = rapport->options =
               (char *) AllocMem(nopt, MEMF_PUBLIC | MEMF_CLEAR))
         || !(Arguments = rapport->arguments =
               (char **) AllocMem(nopt << 2, MEMF_PUBLIC | MEMF_CLEAR)))
#  else  /* AMIGA */
   if (!(Options = rapport->options = (char *) calloc(nopt, 1))
         || !(Arguments = rapport->arguments = (char **) calloc(nopt << 2, 1)))
#  endif /* AMIGA */
   {
      /* liberer la memoire et annuler Taille
         free the memory and zero Taille      */
      parse_cleanup();
      probleme(rapport, 0, OPT_LACK_OF_MEMORY, -1);
   }
   nopt = 0;
   rapport->erreur = 0;
   /* vérification qu'il y a des options ou des arguments
      check that there are options or arguments             */
   if (rapport->narg == 0)
      return nopt;
   /* parcours
      parsing */
   do {
      if (**rapport->parg == '-') { /* option décelée ## option detected  */
         char res;
         res = parse_option(descrip, rapport, &nopt);
         switch (res) {
         default :
            continue;
         case 1 :
            break;
         case 2 :
            nopt = -1;
            break;
         }
         break;
      } else
         /* fin des options détectée
            end of options detected   */
         break;
   }while (rapport->narg);
   return nopt;
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

static char parse_option (char * descrip, struct rapport * rapport, short * nopt)
   /** entrée                                *** input
      descrip  : descripteur des options      : description of the options
   *** sortie                                *** output
      rapport  : indicateur d'activité        : indicates what's happened
      nopt     : nombre d'options validées    : number of validated options
   *** valeur                                *** value
      0 : pas de problème rencontré           : no problem encountered
      1 : pas de problème et traitement fini  : no problem but parse is over
      2 : il y a eu un problème               : there was a problem
   **/
{
   int      narg;    /* nombre de paramètres    ## number of parameters */

   char *   ana;  /* analyse           ## analyse           */
   char *   grop; /* groupe d'options  ## group of options  */
   char num;   /* numéro   ## number   */
   char op;    /* option *** option    */

   grop = (*(rapport->parg)++) + 1;
   switch (op = *grop++) {
   case '\0' : /* - : entrée standard, premier argument  */
      if (rapport->narg && **rapport->parg == '-')
         probleme(rapport, op, OPT_MISSING_OPTION, 2);
      /* c'était bien le cas et c'est la fin des options
         that was the case and that's the end of options */
      --rapport->parg;
      return 1;
   case '-' :  /* -- : fin des options ## end of options */
      if (*grop)
         probleme(rapport, op, OPT_UNKNOWN_OPTION, 2);  /* --?   */
      --rapport->narg;
      return 1;
   default :   /* -? : une option   */
      /* on a une option, existe-elle pour autant ?
         we have an option but does it exist ?        */
      if (*(ana = strseek(descrip, op)) == '\0')
         probleme(rapport, op, OPT_UNKNOWN_OPTION, 2);
      num = (ana - descrip) >> 1;
      if (rapport->options[num])
         probleme(rapport, op, OPT_REPETITION, 2);
      rapport->options[num] = 1;
      if (ana[1] == ';') {
         /* option à argument
            option needing an argument */
         if (*grop)
            probleme(rapport, op, OPT_STUCK_ARGUMENT, 2);
         if ((rapport->narg -= 2) < 0)
            probleme(rapport, op, OPT_ABSENT_ARGUMENT, 2);
         rapport->arguments[num] = *(rapport->parg)++;
         ++*nopt;
      } else {
         /* recherche d'autres options sans arguments
            looking for other options without arguments */
         while (*grop)
            if (*(ana = strseek(descrip, op = *grop++))) {
               if (ana[1] == ';')
                  probleme(rapport, op, OPT_STUCK_OPTION, 2);
               num = (ana - descrip) >> 1;
               if (rapport->options[num])
                  probleme(rapport, op, OPT_REPETITION, 2);
               rapport->options[num] = 1;
               ++*nopt;
            } else
               probleme(rapport, op, OPT_UNKNOWN_OPTION, 2);
         --rapport->narg;
      }
      return 0;
   }
}
