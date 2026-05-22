/**********************************************************************
 *
 *       fichier: fils.c       Terminal sur une fenetre Amiga.
 *                          le code est reentrant pour permettre le
 *                          lancement de plusieurs process dessus.
 *                             Pour cela, il doit etre linke avec
 *                          'startproc.obj' qui est reentrant aussi
 *                          et remplace 'astartup.obj'.
 *                             StartProc.obj permet seulement d'avoir
 *                          une fonction "exit()" et SysBase.
 *
 *       par Jean-Michel FORGEAS
 *
 *       creation: 09-Jun-87
 *       revision: 18-Jun-87
 *
 **********************************************************************/


/******* Included Files ***********************************************/

#include "proc.h"


/******* Imported *****************************************************/

extern ULONG  SysBase;                 /* = AbsExecBase seule adresse
                                            absolue dans Exec         */
extern struct Pack       *GetMsg();
extern struct FileHandle *Open();


/******* Exported ******************************************************/

VOID main();


/******* Program ******************************************************/

static VOID Quitte();

            /* ATTENTION!!! DOSBase est GLOBAL au 
               programme, si un process ecris alors
               qu'un autre lis, ca fait desordre !!!
            */
struct DosLibrary *DOSBase=0;


            /* chaque fils a besoin de ses variables globales, mais
               elles doivent leur etre propre. Donc chaque fils va
               allouer de la memoire a l'image de cette structure
               et va ranger ses variables dedans.
            */
struct Global {
        int    id;              /* numero du process */
        struct MsgPort *port;   /* port original du process */
        struct Pack    *pack;   /* message recu du pere */
        struct FileHandle *stdin, *stdout, *stderr; /* fichier d'e/s */
        int  initialSP;         /* pointeur initial sur la pile du process */
};                              /* il est passe par startproc.obj et doit  */
                                /* lui etre retourne avec exit(initialSP); */


/**********************************************************************
 *
 *      Point d'entree
 *
 **********************************************************************/


/*-------------------------------------------------------------
 *      lancement de chaque fils
 */

VOID main(initialSP)  /* chaque process a un pointeur sur sa pile. Ici il */
int initialSP;        /* est passe au process par 'startproc.obj' pour le */
                      /* memoriser et le rendre avec exit(initialSP) */
{
   struct Global  *G=0;  /* pointeur sur la zone des variables du process */
   struct Process *proc; /* process de chaque fils pour trouver le port */
   struct MsgPort *port; /* adresse du port original du process */
   struct Pack    *pack; /* adresse du message venant du pere */
   int rc;

   if (!DOSBase) {
        Forbid(); /* bloque les autre process pendant que celui-ci ecrit */
        DOSBase = (struct DosLibrary *) OpenLibrary( DOSNAME, 0 );
        if (!DOSBase) exit(0);
        Permit(); /* les autres peuvent maintenant lire */
   }

   proc = (struct Process *) FindTask(0);  /* adresse de son descripteur...*/
   port = &proc->pr_MsgPort;               /* ...pour adresse de son port */

   WaitPort( port );       /* attend le message du pere avec infos */
   pack = GetMsg( port );  /* sur fichier a ouvrir */


          /*--- allocation de memoire pour les variables globales ---*/
   if (!(G = (struct Global *) AllocMem( sizeof(struct Global), MEMF_CLEAR )))
    {
      Quitte( G, NO_MEMORY );
    }
          /*--- initialisation des variables globales ---*/
   if ((rc = InitGlobal( G, initialSP, pack )) != NO_ERROR)
    {
      Quitte( G, rc );
    }

   pack->result = NO_ERROR;    /* le pere veut savoir si tout est OK */
   pack->FilsPort = G->port;   /* le pere sait de qui vient le reply */
   ReplyMsg( pack );
                 /* Appel fonction principale */
   rc = ProcessCode( G );

   Quitte( G, rc );
}


/*-------------------------------------------------------------
 *      Initialisation de l'environement de chaque fils
 */

static int InitGlobal( G, initialSP, pack )
struct Global  *G;
int    initialSP;
struct Pack *pack;
{
 struct MsgPort *port;

   G->id   = pack->id;  /* numero */
   G->initialSP = initialSP; /* pointeur de pile passe par startproc.obj */

                /* chacun ouvre son fichier (console) */

   if (!(port = (struct MsgPort *) CreatePort( "fils", 0 ))) return( NO_MEMORY );
   G->port = port;

   if (!(G->stdin = Open( pack->bufread, MODE_OLDFILE ))) return( NO_FILE );
   G->stdout = G->stderr = G->stdin;

   Write( G->stdout, "stdout ok\n", 10 );

   return( NO_ERROR );
}


/*-------------------------------------------------------------
 *      Nettoie et fin
 */

static VOID Quitte( G, rc )
struct Global *G;
int rc;
{
   int  initialSP;
   struct Pack *pack;

   initialSP = G->initialSP; /* rememoriser initialSP avant FreeMem() */
   pack = G->pack;           /* l'adresse du message aussi */

   Write( G->stdout, "Quitte() ok\n", 12 );
   if (G->stdin)  Close( G->stdin );
   if (G->port)   DeletePort( G->port );
   if (G)         FreeMem( G, sizeof(struct Global) );
   if (DOSBase)   CloseLibrary( DOSBase );

   Forbid();          /* bloque le pere: il faut que le process se */
                      /* termine avant que le pere fasse UnLoad du code */
   pack->result = rc;
   ReplyMsg( pack );  /* pour que le pere sache qu'il peut faire UnLoad */
                      /* si c'est le dernier fils */
   exit(initialSP);   /* retour a startproc.obj qui va remettre son */
                      /* pointeur de pile a cette valeur avant RTS */
}



/*-------------------------------------------------------------
 *      code de fonctionnement de chaque process fils
 */

static int ProcessCode(G)
struct Global *G;
{
   Write( G->stdout, "Process Fils prêt\n", 18 ); /*accueil */

   while (TRUE)
   {
     WaitPort( G->port );          /* attend une requete du pere */
     G->pack = GetMsg( G->port );

     if (G->pack->lenwrite)
      {
        Write( G->stdout, G->pack->bufwrite, G->pack->lenwrite );
        G->pack->lenwrite = 0;
      }

     if (G->pack->cmd == CMD_STOP) break;

     G->pack->lenread = Read( G->stdin, G->pack->bufread, G->pack->lenread );

        /* renvoit les caracteres lu au pere. Si c'est 'logoff', le */
        /* pere renverra un CMD_STOP */
     ReplyMsg( G->pack );
   }
   return( NO_ERROR );
}
