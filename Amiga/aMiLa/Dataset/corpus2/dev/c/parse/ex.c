/*** exemple d'utilisation (début seulement) %%% use sample (beginning) ***/

#include <stdio.h>
#include "parse.h"

#define OPTIONS "f;h i "

#ifndef ENGLISH
#  define UNSET   "pas mise"
#else
#  define UNSET   "unset"
#endif

void main (int narg, char * parg [])
{
   struct rapport rapport;
   char nopt;

   if ((nopt = parse(OPTIONS, narg, parg, &rapport)) < 0) {
      if (rapport.erreur != OPT_LACK_OF_MEMORY) {
         fprintf(stderr, ParseErrMess, rapport.lettre);
         if (rapport.erreur == OPT_UNKNOWN_OPTION)
            fprintf(stderr, "\nUSAGE : parse [-f <file>] [-h] [-i] <arg>");
      } else
         fprintf(stderr, ParseErrMess);
      fputc('\n', stderr);
      exit(10);
   }
   /* maintanant il nous faut utiliser les argv et arc donnes dans rapport
      now we have to use the argv and argc provided in rapport             */
   if (rapport.narg  != 1) {
      fprintf(stderr, "USAGE : parse [-f <fichier>] [-h] [-i] <argument>\n");
#        ifndef ENGLISH
      if (narg)
         fprintf(stderr, "Il y a %d arguments au lieu d'un seul !\n",  rapport.narg);
      else
         fprintf(stderr, "Il faut un argument !\n");
#        else  /* ENGLISH  */
      if (narg)
         fprintf(stderr, "There are %d arguments instead of a single one!\n",  rapport.narg);
      else
         fprintf(stderr, "There must be an argument!\n");
#        endif /* ENGLISH  */
         /* faire le ménage avant de partir.  ## let's clean and quit.  */
         parse_cleanup();
         exit(10);
   }
   /* pas d'erreur de syntaxe détectée
      no syntax error was encountered  */
   printf("%d options\noption f %s%s\noption h %s\noption i %s\nargument = %s\n",
          nopt,
          (rapport.options[0]) ? "set to " : UNSET,
          (rapport.options[0]) ? rapport.arguments[0] : "",
          (rapport.options[1]) ? "set" : UNSET,
          (rapport.options[2]) ? "set" : UNSET,
          rapport.parg[0]
          );
   /* faire le ménage avant de partir.  ## let's clean and quit.  */
   parse_cleanup();
   exit(0);
}

