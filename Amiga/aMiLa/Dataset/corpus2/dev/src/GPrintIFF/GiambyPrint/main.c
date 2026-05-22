/**** Dichiarazione dei file di supporto ***********************************/
#include <stdio.h>
#include <string.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/asl_protos.h>

#include <iffp/iff.h>
#include "ilbm.h"

/*** Variabili Globali *****************************************************/
const   UBYTE   vers[]  = "\0$VER: GPrintIFF V1.0 (20/10/1996)\0";
BOOL	done	= FALSE;

 /**** Dichiaro le strutture necessarie per aprire le librerie ****/
extern struct Library           *SysBase;
extern struct Library           *GfxBase;
extern struct DOSBase           *DOSBase;
extern struct IntuitionBase     *IntuitionBase;

struct  Library *GadToolsBase   = NULL,
                *AslBase        = NULL,
                *IFFParseBase   = NULL;

 /**** Dichiarazione della Tag per il Menu ****/
 struct NewMenu GadMenu[] = {
 { NM_TITLE, "Progetto",                	 0 , 0, 0, 0},
 {  NM_ITEM, "Carica...",              		"C", 0, 0, 0},

 {  NM_ITEM, NM_BARLABEL,               	 0 , 0, 0, 0},

 {  NM_ITEM, "Stampa",                 		"P", 0, 0, 0},
 {  NM_ITEM, "Informazioni...",         	 0,  0, 0, 0},
 {   NM_SUB, "       GPrintIFF V1.0       ",	 0, 0, 0, 0},
 {   NM_SUB, "©1996 by Giambattista Bloisi",	 0, 0, 0, 0},

 {  NM_ITEM, NM_BARLABEL,              		 0 , 0, 0, 0},

 {  NM_ITEM, "Fine",                   		"F", 0, 0, 0},

 {  NM_END,  NULL,                     		 0 , 0, 0, 0},
};
struct Menu     *MyMenu = NULL;
struct MenuItem *MItem;

/**** Prototypes per le procedure interne **********************************/
#define Prototype extern
Prototype int   wbmain          (struct WBStartup *);
Prototype void  main            (int, char **);
Prototype void  CleanUp         (char *);
Prototype void  LoadPrint       (STRPTR);

/**** struttura per i requester con l'utente *****/
 struct EasyStruct mes = {
        sizeof(struct EasyStruct),
        0,
        "GPrintIFF Message",
        "\n%s\n",
        "OK"
        };

int wbmain(struct WBStartup *wbstartup)
{
 main(1, NULL);
}

void main(int argc, char **argv)
{
	/* Apro le librerie necessarie */
   IntuitionBase  = (struct IntuitionBase *) OpenLibrary("intuition.library", 36);
    if(!IntuitionBase)
        CleanUp("Non posso aprire la intuition.library V36");

    GadToolsBase  = OpenLibrary("gadtools.library", 36);
    if(!GadToolsBase)
        CleanUp("Non posso aprire la gadtools.library V36");

    AslBase       = OpenLibrary("asl.library", 0);
    if(!AslBase)
        CleanUp("Non posso aprire la asl.library V36");

    IFFParseBase = OpenLibrary("iffparse.library", 0);
    if(!IFFParseBase)
        CleanUp("Non posso aprire la iffparse.library");

	/* Alloco le strutture necessarie per la gestione IFF */
    if(!(ilbm = (struct ILBMInfo *) AllocMem(sizeof(struct ILBMInfo), MEMF_PUBLIC|MEMF_CLEAR)))
        CleanUp("Non c'è abbastanza memoria");

    ilbm->ParseInfo.propchks    = ilbmprops;
    ilbm->ParseInfo.collectchks = ilbmcollects;
    ilbm->ParseInfo.stopchks    = ilbmstops;
    ilbm->windef = &mynw;

    if(!(ilbm->ParseInfo.iff = AllocIFF()))
        CleanUp("Non posso allocare la struttura IFF");


	/* Controllo il numero degli argomenti */
    if (argc==2)
    {
     LoadPrint((STRPTR)argv[1]);
     argc=1;
    }

    if (argc==1)
    {
     struct  FileRequester   *filreq=NULL;

     if(filreq=AllocAslRequest(ASL_FileRequest, NULL))
       {
        while(!done)
         {
          if(AslRequestTags(filreq,
                        ASLFR_Screen,           NULL,
                        ASLFR_TitleText,        "Selezione una immagine...",
                        ASLFR_PositiveText,     "Leggi",
                        ASLFR_NegativeText,     "Fine",
                        ASLFR_RejectIcons,      TRUE,
                        TAG_END))
           {
            strcpy(ilbmname, filreq->fr_Drawer);
            AddPart(ilbmname, filreq->fr_File, 256);
            LoadPrint((STRPTR)ilbmname);
           }
           else done=TRUE;

         } //end while

       }
        else CleanUp("Non posso aprire l'ASL Requester");

    }
    else
    {
    printf("GPrintIFF V1.0 - ©1996 by Giambattista Bloisi\n\n"
           "Uso:\n"
           "GPrint <nome_del_file_immagine>\n\n"
           "N.B. Se non viene specificato nessun nome, verrà automaticamente\n"
           "aperto l'ASL requester\n");
    }

 CleanUp(NULL);
}

void LoadPrint(imagefile)
STRPTR imagefile;
{
  struct Screen        *scr;
  struct Window        *win;
  struct IntuiMessage  *msg;

  APTR *VInfo  = NULL;
  LONG error   = 0L;
  BOOL done2   = FALSE;
  ULONG menu, item, sub;
  ULONG imsgClass;
  UWORD imsgCode;

  if(!(error = showilbm(ilbm, (UBYTE *)imagefile)))
    {
     scr = ilbm->scr;
     win = ilbm->win;

     if(VInfo=GetVisualInfo(scr, TAG_DONE))
       {
        if(MyMenu=CreateMenus(GadMenu,
                              GTMN_FrontPen,	0,
                              TAG_DONE))
          {
           if(LayoutMenus(MyMenu, VInfo,
                          GTMN_NewLookMenus,	TRUE,
                          TAG_DONE))
             {

	      GT_RefreshWindow(win, NULL);

              if(SetMenuStrip(win, MyMenu))
                {

		 while(!done2)
    		   {
     		    Wait(1 << win->UserPort->mp_SigBit);

        	    while((!done2) && (msg = GT_GetIMsg(win->UserPort)))
        	      {
            		imsgClass = msg->Class;
            		imsgCode = msg->Code;
            		GT_ReplyIMsg(msg);

            		if(imsgClass==IDCMP_MENUPICK) /* Uso dei menu? */
            		  {
                	   while(imsgCode!=MENUNULL) /* Lettura di tutti gli eventi menu */
                	     {
                              MItem=ItemAddress(MyMenu, imsgCode);

                    	      /* Selezione dei dati della scelta menu */
                    	      menu=MENUNUM(imsgCode);
                    	      item=ITEMNUM(imsgCode);
                    	      sub=SUBNUM(imsgCode);

                    	      if(menu==0)
                     		{
                        	 if(item==0) done2=TRUE;
				 else if(item==2)
                           	         screendump(scr, 0, 0, scr->Width,
                           	                    scr->Height, 0, 0);
				 else if(item==5)
                               		{
                               		 done =TRUE;
                               		 done2=TRUE;
                               		}
                    		}
                    	      imsgCode = MItem->NextSelect;
                	     }
            		  }
        	      }
    		   }

         	 }
          	FreeMenus(MyMenu);
             }
          }
         ClearMenuStrip(win);
       }
      FreeVisualInfo(VInfo);
      unshowilbm(ilbm);
    }

  if(error)   EasyRequest(NULL, &mes, NULL, IFFerr(error));

}

void CleanUp(errmsg)
char *errmsg;
{
    /* Stampa il messaggio di chiusura */
        if(errmsg)      EasyRequest(NULL, &mes, NULL, errmsg);

    /* Chiusura e deallocazione delle risorse utilizzate */

    if(ilbm->ParseInfo.iff) FreeIFF(ilbm->ParseInfo.iff);
    if(ilbm)            FreeMem(ilbm, sizeof(struct ILBMInfo));

    if(IFFParseBase)    CloseLibrary(IFFParseBase);
    if(GadToolsBase)    CloseLibrary(GadToolsBase);
    if(AslBase)         CloseLibrary(AslBase);
    if(IntuitionBase)   CloseLibrary((struct Library *)IntuitionBase);

}