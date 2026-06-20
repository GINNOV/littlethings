/*
 * DisKo3.c (08/06/04)
 *
 */

#include <stdio.h>
#include <libraries/mui.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>
#include <proto/exec.h>
#include <clib/alib_protos.h>

#include <mui/Busy_mcc.h>

#define MAKE_ID(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

struct Library *MUIMasterBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;

#ifdef __amigaos4__
struct IntuitionIFace *IIntuition;
struct MUIMasterIFace *IMUIMaster;
#endif

#define	MUIA_Application_UsedClasses	0x8042e9a7	/* V20 STRPTR *	i..	*/

static STRPTR ClassList[]	=
{
	"Busy.mcc",
	NULL
};

void CreateGui(void)
{
	Object *app = NULL;
	Object *window = NULL;
	Object *bt_play, *bt_stop, *bt_previous, *bt_next, *bt_pause, *bt_eject;
	Object *busy;
	Object *sl_volume;
	Object *lv_pistes;
	Object *list;

	/* Description de l'interface et de ses propriétés */	

	app = (Object *)ApplicationObject,
		MUIA_Application_Author, "corto@guru-meditation.net",
		MUIA_Application_Base, "DISKO",
		MUIA_Application_Title, "DisKo - Exemple 3",
		MUIA_Application_Version, "$VER: DisKo 1.03 (08/06/04)",
		MUIA_Application_Copyright, "Mathias PARNAUDEAU",
		MUIA_Application_Description, "Player de CD audio minimaliste",
		MUIA_Application_HelpFile, NULL,
		MUIA_Application_UsedClasses, ClassList,

        SubWindow, window = WindowObject,
				MUIA_Window_Title, "DisKo - release 3",
            MUIA_Window_ID, MAKE_ID('W', 'I', 'N', '1'),
            WindowContents, VGroup,

					Child, HGroup,
						Child, lv_pistes = ListviewObject,
							MUIA_Listview_Input, FALSE,
							MUIA_Listview_List, list = ListObject,
								ReadListFrame,
								MUIA_List_Format, "P=\33r",
							End,
						End,

						Child, VGroup,
							Child, Label("Volume"),
							Child, sl_volume = SliderObject,
								MUIA_Group_Horiz, FALSE,
								MUIA_Numeric_Min, 0,
								MUIA_Numeric_Max, 100,
								MUIA_Numeric_Value, 38,
								MUIA_Numeric_Reverse, TRUE,
							End,
						End,
					End,

					/* Utilisation d'un groupe horizontal pourvu de boutons */
					Child, HGroup,
						Child, bt_previous = KeyButton("Précédent", 'p'),
						Child, bt_next = KeyButton("Suivant", 'v'),
						Child, bt_play = KeyButton("Jouer", 'j'),
						Child, bt_pause = KeyButton("Pause", 'a'),
						Child, bt_stop = KeyButton("Stopper", 's'),
						Child, bt_eject = KeyButton("Ejecter", 'e'),
					End,

					Child, busy = BusyObject,
						MUIA_Busy_Speed, MUIV_Busy_Speed_Off,
					End,
				End,
        End,
    End;

	/* On fixe quelques valeurs et notifications */
	
	DoMethod(window,
		MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
		app, 2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);

	set(bt_stop, MUIA_Disabled, TRUE);

	DoMethod(busy, MUIM_Busy_Move, FALSE);

	DoMethod(bt_play, MUIM_Notify, MUIA_Pressed, FALSE,
	   bt_stop, 3, MUIM_Set, MUIA_Disabled, FALSE);
	DoMethod(bt_play, MUIM_Notify, MUIA_Pressed, FALSE,
	   bt_play, 3, MUIM_Set, MUIA_Disabled, TRUE);

	DoMethod(bt_stop, MUIM_Notify, MUIA_Pressed, FALSE,
	   bt_play, 3, MUIM_Set, MUIA_Disabled, FALSE);
	DoMethod(bt_stop, MUIM_Notify, MUIA_Pressed, FALSE,
	   bt_stop, 3, MUIM_Set, MUIA_Disabled, TRUE);

	DoMethod(bt_play, MUIM_Notify, MUIA_Pressed, FALSE,
					busy, 3, MUIM_Set, MUIA_Busy_Speed, 20);
	DoMethod(bt_stop, MUIM_Notify, MUIA_Pressed, FALSE,
					busy, 3, MUIM_Set, MUIA_Busy_Speed, MUIV_Busy_Speed_Off);

	DoMethod(list, MUIM_List_InsertSingle, "1 - Première piste", MUIV_List_Insert_Bottom);
	DoMethod(list, MUIM_List_InsertSingle, "2 - Deuxième piste", MUIV_List_Insert_Bottom);

	SetAttrs(window, MUIA_Window_Open, TRUE, TAG_END);

	/* Boucle de gestion des évènements, toujours la même */
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

	set(window, MUIA_Window_Open, FALSE);

	/* Libération des ressources et fermeture */
	MUI_DisposeObject(app);
}


/*
 * Initialisation et vérification de tout ce qui est nécessaire à la bonne exécution
 * de l'application : ouverture des bibliothèques, test de présence des classes MCC, ...
 */
int Initialize(void)
{
	int res = 1;
	Object *busy = NULL;

	IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39L);
	MUIMasterBase = OpenLibrary(MUIMASTER_NAME, MUIMASTER_VMIN);

	if (IntuitionBase == NULL){
		printf("Impossible d'ouvrir 'intuition.library' V39\n");
		res = 0;
	}
	if (MUIMasterBase == NULL){
		printf("Impossible d'ouvrir '%s' V%d\n", MUIMASTER_NAME, MUIMASTER_VMIN);
		res = 0;
	}

#ifdef __amigaos4__
	IIntuition = (struct IntuitionIFace *)GetInterface((struct Library *)IntuitionBase, "main", 1, NULL);
	if (!IIntuition){
		printf("Impossible d'obtenir l'interface IIntuition\n");
		res = 0;
	}

	IMUIMaster = (struct MUIMasterIFace *)GetInterface(MUIMasterBase, "main", 1, NULL);
	if (!IMUIMaster){
		printf("Impossible d'obtenir l'interface IMUIMaster\n");
		res = 0;
	}
#endif

	busy = BusyObject, End;
	if (busy == NULL){
		printf("Classe Busy manquante\n");
		res = 0;
	}
	MUI_DisposeObject(busy);

	return res;
}


/*
 * Fermeture et libération de tout ce qui a été initialisé au démarrage.
 */
void DeInitialize(void)
{
#ifdef __amigaos4__
	if (IMUIMaster) {
		DropInterface((struct Interface *)IMUIMaster);
	}
	if (IIntuition) {
		DropInterface((struct Interface *)IIntuition);
	}
#endif
	CloseLibrary(MUIMasterBase);
	CloseLibrary((struct Library *)IntuitionBase);
}


int main(int argc, char **argv)
{

	if(Initialize()){
		CreateGui();
	}
	DeInitialize();

	return 0;
}
