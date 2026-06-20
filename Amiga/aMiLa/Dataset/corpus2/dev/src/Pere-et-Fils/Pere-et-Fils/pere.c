/**********************************************************************
 *
 *       fichier: pere.c    lanceur de process(s) et programme maitre
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

extern struct MsgPort *CreateProc();
extern struct Pack    *GetMsg();
extern int LoadSeg();
extern int stdin;


/******* Exported *****************************************************/

VOID main();


/******* Program ******************************************************/

static VOID Manage();
static VOID Quitte();
static VOID DeleteUser();
static struct Pack *CreatePack();
static VOID DeletePack();

#define PRIORITY       0
#define STACKSIZE   4000

struct MsgPort *InitPort, *MyPort=0;
int    segment=0;
int    ProcNum=0;


/**********************************************************************
 *
 *      Point d'entree
 *
 **********************************************************************/


/*-------------------------------------------------------------
 *      chargement du code reentrant (pour cet exemple: fils.c)
 */

VOID main(argc,argv)
int  argc;
char *argv[];      /* argv[1]=fichierdufils  argv[2]=nombredefilsalancer */
{
  int i=0, n=0;

    if (argc != 3) Quitte(1);
    stcd_i( argv[2], &n );
    if (n<=0) Quitte(0);
                            /* premier port pour initialiser les fils */
    if (!(InitPort = (struct MsgPort *) CreatePort( "Init", 0 ))) Quitte(5);
                            /* second port pour causer avec les fils */
    if (!(MyPort = (struct MsgPort *) CreatePort( "Pere", 0 ))) Quitte(5);

                            /* chargement du code qui supportera les fils */
    if (!(segment = LoadSeg( argv[1] ))) Quitte(3);
                            /* lancement de plusieurs process sur le code */
    for (i=0; i<n; i++) if (CreateUser() != NO_ERROR) break;

    printf("--- %ld de partis sur %ls demandes\n",ProcNum,argv[2]);
    if (ProcNum) Manage();
              /* on quitte seulement si tous les fils sont termines */
    Quitte(0);
}


/*------------------------------------------------------
 *      usine a gaz de creation de process fils
 */

static int CreateUser()
{
  struct MsgPort *FilsPort;
  struct Pack *MyPack;
  int i, rc;

    i = ProcNum+1;            /* nombre de fils + 1) */
                              /* on alloue un message pour chaque fils */
    if (!(MyPack = CreatePack( InitPort ))) return(NO_MEMORY);

    FilsPort = CreateProc( "fils", PRIORITY, segment, STACKSIZE );
    if (!FilsPort)
     {
       printf("***Erreur CreateProc %ld: manque de memoire\n",i );
       DeletePack( MyPack );
       return( NO_MEMORY );
     }
                   /* on passe au fils son numero et son fichier a ouvrir */
    MyPack->id   = i;
    sprintf( MyPack->bufread, "CON:%ld/%ld/200/70/User %ld", 100+10*i, 50+9*i, i );

    PutMsg( FilsPort, MyPack );
    WaitPort( InitPort );           /* le fils signale s'il est ok ou non */
    MyPack = GetMsg( InitPort );
    if ((rc = MyPack->result) != NO_ERROR)
     {
       printf("***Erreur fils %ld: %ld\n", i, rc );
       DeletePack( MyPack );
       return( rc );
     }
                                /* on passe le fils sur l'autre port */
    MyPack->msg.mn_ReplyPort = MyPort;
                                /* on lui demande de prompter et lire */
    MyPack->cmd      = CMD_READ;
    MyPack->lenread  = 256;
    MyPack->bufwrite = "\n]";
    MyPack->lenwrite = 2;
                                /* c'est parti: les caracteres lus seront */
    PutMsg( MyPack->FilsPort, MyPack );  /* le fils a mis son port dans: */
    ProcNum = i;                         /* MyPack->FilsPort... */
    printf("fils numero %ld parti !\n", i);
    return( NO_ERROR );
}


/*------------------------------------------------------
 *      fume pas, bois pas, mais flingue
 */

static VOID DeleteUser( pack )
struct Pack *pack;
{
        /* l'utilisateur a passe par le fils une demande de "logoff" (fin) */
    pack->cmd = CMD_STOP;          /* on arrete donc le fils */
    PutMsg( pack->FilsPort, pack );
                /* le fils fait Forbid(), repond, puis se termine */
    WaitPort( MyPort );
    GetMsg( MyPort );     /* le fils est termine quand on prend le message */
    DeletePack( pack );   /* effacement du message associe au fils */
    ProcNum--;            /* nombre de fils actifs - 1 */
    printf("un de moins, ");
    if (ProcNum) printf("plus que %ld...\n",ProcNum);
    else printf("c'etait le dernier !\n");
}


/*------------------------------------------------------
 *      on attend une reponse d'un fils, et on renvoie
 */

static VOID Manage()
{
 struct Pack *MyPack;

   while (TRUE)
   {
      WaitPort( MyPort );
      MyPack = GetMsg( MyPort );

      if (MyPack->lenread==0)
       {
          MyPack->cmd = CMD_READ;
       }
      else
       {
          MyPack->bufread[ MyPack->lenread-1 ] = 0;
          if (strcmp( MyPack->bufread, "logoff" ) == 0)
           {
              DeleteUser( MyPack );
              if (!ProcNum) return;
              continue;
           }
          else
           {
              MyPack->cmd      = CMD_READ;
              MyPack->lenread  = 256;
              MyPack->bufwrite = "d'accord mon pote\n]";
              MyPack->lenwrite = 19;
           }
       }
      PutMsg( MyPack->FilsPort, MyPack );
   }
}


/*------------------------------------------------------
 *      nettoyage et fin
 */

static VOID Quitte(n)
int n;
{
   switch (n)
    {
      case 0: printf("---Fin du père ok\n");         break;
      case 1: printf("***Process fichier nbfils\n"); break;
      case 2: printf("***Cannot Allocate memory\n"); break;
      case 3: printf("***Cannot LoadSeg\n");         break;
      case 4: printf("***Cannot CreateProc\n");      break;
      case 5: printf("***Cannot CreatePort\n");      break;
    }

   if (segment)  UnLoadSeg( segment );
   if (MyPort)   DeletePort( MyPort );
   if (InitPort) DeletePort( InitPort );

   exit(n);
}


/*-----------------------------------------------------
 *      creation/effacement des structures de message
 */

static struct Pack *CreatePack( ReplyPort )
struct MsgPort  *ReplyPort;
{
 struct Pack *pack;

   pack = (struct Pack *) AllocMem( sizeof(struct Pack), MEMF_CLEAR | MEMF_PUBLIC );
   if ( !pack) return ( (struct Pack *) 0);

   pack->msg.mn_Node.ln_Type = NT_MESSAGE;
   pack->msg.mn_Length       = sizeof(struct Pack)-sizeof(struct Message);
   pack->msg.mn_ReplyPort    = ReplyPort;

   return( pack );
}

static VOID DeletePack( pack )
struct Pack *pack;
{
   pack->msg.mn_Node.ln_Type = 0xFF;
   FreeMem ( pack, sizeof(*pack) );
}
