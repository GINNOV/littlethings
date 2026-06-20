/*
 * DisKo1.c (05/06/04)
 *
 */

#include <stdio.h>
#include <libraries/mui.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/muimaster.h>
#include <clib/alib_protos.h>

struct IntuitionBase *IntuitionBase;
struct Library  *MUIMasterBase;

#ifdef __amigaos4__
struct IntuitionIFace *IIntuition;
struct MUIMasterIFace *IMUIMaster;
#endif

#define MAKE_ID(a,b,c,d) ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

int Initialize(void)
{
	int res = 1;

	IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39L);
	MUIMasterBase = OpenLibrary(MUIMASTER_NAME, 19);

#ifdef __amigaos4__
	IMUIMaster = (struct MUIMasterIFace *)GetInterface(MUIMasterBase, "main", 1, NULL);
	IIntuition = (struct IntuitionIFace *)GetInterface((struct Library *)IntuitionBase, "main", 1, NULL);

	res = IMUIMaster && IIntuition;
#endif

	return (IntuitionBase && MUIMasterBase && res);
}

void DeInitialize(void)
{

#ifdef __amigaos4__
	if (IMUIMaster) DropInterface((struct Interface *)IMUIMaster);
	if (IIntuition) DropInterface((struct Interface *)IIntuition);
#endif

	if (IntuitionBase)
		CloseLibrary((struct Library *)IntuitionBase);

	if (MUIMasterBase)
		CloseLibrary(MUIMasterBase);

}

int CreateGui(void)
{
	Object *app, *window;

	/* Description de l'interface graphique */

	app = ApplicationObject,
		MUIA_Application_Title  , "Titre",
		MUIA_Application_Version , "$VER: 0.0.1 (05/06/04)",
		MUIA_Application_Copyright , "©2004, copyright et célébrité",
		MUIA_Application_Author  , "L'auteur, c'est vous !",
		MUIA_Application_Description, "Description libre",
		MUIA_Application_Base  , "DISKO",

		SubWindow, window = WindowObject,
			MUIA_Window_Title, "Projet DisKo : Premier programme MUI",
			MUIA_Window_ID , MAKE_ID('W','I','N','1'),
			WindowContents, VGroup,

				Child, TextObject, TextFrame,
					MUIA_Background, MUII_TextBack,
					MUIA_Text_Contents, "\33c Il affiche ici du texte multiligne dans un TextObject\navec une frame \33bTextFrame\33n",
				End,

				Child, TextObject, ButtonFrame,
					MUIA_Background, MUII_TextBack,
					MUIA_Text_Contents, "\33c Et ici un TextObject avec une frame d'aspect \33iButtonFrame\33n\nce qui lui donne son aspect de bouton",
				End,

				Child, TextObject, StringFrame,
					MUIA_Background, MUII_TextBack,
					MUIA_Text_Contents, "\33c Et un dernier avec \33uStringFrame\33n\n(Escape pour quitter l'application)",
				End,

				Child, SimpleButton("Bouton sans action"),

			End,
		End,
	End;

	if (!app){
		printf("Impossible de créer l'application.\n");
		return 0;
	}

	DoMethod(window,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,
		app,2,MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit);

	/* Commande l'ouverture, donc l'affichage, de la fenêtre */

	set(window,MUIA_Window_Open,TRUE);

	/* Boucle de gestion des événements qui permet de savoir quand la fermeture
	 * a été demandée
	 */
	{
		ULONG sigs = 0;

		while (DoMethod(app,MUIM_Application_NewInput,&sigs) != MUIV_Application_ReturnID_Quit)
		{
			if (sigs)
			{
				sigs = Wait(sigs | SIGBREAKF_CTRL_C);
				if (sigs & SIGBREAKF_CTRL_C) break;
			}
		}
	}

	set(window,MUIA_Window_Open,FALSE);

	// Fermeture de la fenêtre, désallocation des ressources
	MUI_DisposeObject(app);

	return 1;
}


int main(int argc,char *argv[])
{

	if ( Initialize() ){
		CreateGui();
	}else{
		printf("Impossible d'ouvrir toutes les bibliothèques\n");
	}

	DeInitialize();

	return 0;
}
