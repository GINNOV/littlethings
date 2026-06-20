/*
 * DisKo5.c (21/08/04)
 * txt_info a été mis en global
 */

#include <stdio.h>
#include <libraries/mui.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>
#include <proto/exec.h>
#include <clib/alib_protos.h>
#include <string.h>

#include <mui/Busy_mcc.h>

#include <SDI_hook.h>

#define MAKE_ID(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

struct Library *MUIMasterBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;

#ifdef __amigaos4__
struct IntuitionIFace *IIntuition;
struct MUIMasterIFace *IMUIMaster;
#endif

#define	MUIA_Application_UsedClasses	0x8042e9a7	/* V20 STRPTR *	i..	*/

static char * ClassList[] =
{
	"Busy.mcc",
	NULL
};

static Object *app = NULL;
static Object *window = NULL;

static char *Pages[] = { "Utilisation", "Configuration", NULL };

struct Config {
	ULONG unit;
	char device[32];
} config;

#if defined(__SASC)
extern ULONG HookEntry( struct Hook *hookPtr, Object *obj, APTR message );
#endif

Object *txt_info;


/*
 * Hook lié à l'action 'changement de volume' via le slider
 */
#if 0
// Ancien hook : probleme d'affichage du texte sur sortie standard sur certaines configurations (amifred)
static ULONG hook_ChangeVolumeFunc(struct Hook *hook, APTR obj, struct TagItem *tag_list)
{
	int val;

	get(obj, MUIA_Numeric_Value, &val);

	printf("Nouvelle valeur : %d\n", val);

	return TRUE;
}
#endif
#if 0
static ULONG hook_ChangeVolumeFunc(struct Hook *hook, APTR obj, struct TagItem *tag_list)
{
	int val;
	char text[5];

	get(obj, MUIA_Numeric_Value, &val);

	sprintf(text, "%d", val);
	set(txt_info, MUIA_Text_Contents, text);

	printf("Nouvelle valeur : %d\n", val);

	return TRUE;
}

struct Hook hook_ChangeVolume = 
{
	{NULL, NULL}, (HOOKFUNC) HookEntry, (HOOKFUNC) hook_ChangeVolumeFunc, NULL
};
#endif

HOOKPROTONH(ChangeVolume, ULONG, APTR obj, struct TagItem *tag_list)
{
	int val;
	char text[5];

	get(obj, MUIA_Numeric_Value, &val);

	sprintf(text, "%d", val);
	set(txt_info, MUIA_Text_Contents, text);

	printf("Nouvelle valeur : %d\n", val);

	return TRUE;
}

MakeStaticHook(hook_ChangeVolume, ChangeVolume);

/*
 * Construction et ouverture de la fenêtre principale.
 * Cette fonction est appelée quand on sait que tout a bien été initialisé.
 */
Object * OpenMainWindow(void)
{
	Object *bt_play, *bt_stop, *bt_previous, *bt_next, *bt_pause, *bt_eject;
	Object *busy;
	Object *lv_pistes;
	Object *sl_volume;
	Object *list;

	Object *sl_unit;
	Object *str_device;


	/* Description de l'interface et de ses propriétés */	

	app = (Object *)ApplicationObject,
		MUIA_Application_Author, "corto@guru-meditation.net",
		MUIA_Application_Base, "DISKO",
		MUIA_Application_Title, "DisKo - Exemple 5",
		MUIA_Application_Version, "$VER: DisKo 1.05 (04/08/04)",
		MUIA_Application_Copyright, "Mathias PARNAUDEAU",
		MUIA_Application_Description, "Player de CD audio minimaliste",
		MUIA_Application_HelpFile, NULL,
		MUIA_Application_UsedClasses, ClassList,

		SubWindow, window = WindowObject,
			MUIA_Window_Title, "DisKo - release 5",
			MUIA_Window_ID, MAKE_ID('W', 'I', 'N', '1'),
			WindowContents, VGroup,

				Child, RegisterGroup(Pages),
					MUIA_Register_Frame, TRUE,

					// Onglet utilisation

					Child, VGroup,
						Child, HGroup,
							Child, lv_pistes = ListviewObject,
								MUIA_Listview_List, list = ListObject,
									MUIA_Frame, MUIV_Frame_InputList,
									MUIA_List_Format, "P=\33r",
									MUIA_List_Active, MUIV_List_Active_Top,
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

						Child, VSpace(2),

						Child, HGroup,
							Child, txt_info = TextObject,
								MUIA_Frame, MUIV_Frame_Text,
								MUIA_Background, MUII_TextBack,
								MUIA_Text_Contents, "Information piste",
							End,
							Child, busy = BusyObject,
								MUIA_Busy_Speed, MUIV_Busy_Speed_Off,
							End,
						End,
						Child, HGroup,
							Child, bt_previous = KeyButton("Précédent", 'p'),
							Child, bt_next = KeyButton("Suivant", 'v'),
							Child, bt_play = KeyButton("Jouer", 'j'),
							Child, bt_pause = KeyButton("Pause", 'a'),
							Child, bt_stop = KeyButton("Stopper", 's'),
							Child, bt_eject = KeyButton("Ejecter", 'e'),
						End,

					End,

					// Onglet configuration

					Child, VGroup, GroupFrameT("Lecteur CD"),
						Child, ColGroup(2),
							Child, Label2("Device"),
							Child, str_device = String(config.device, 32),
							Child, Label1("Unit" ),
							Child, sl_unit = SliderObject,
								MUIA_Group_Horiz, TRUE,
								MUIA_Numeric_Min, 0,
								MUIA_Numeric_Max, 7,
								MUIA_Numeric_Value, config.unit,
							End,
						End,
						Child, KeyButton("Valider", 'd'),
					End,
				End,
			End,
		End,
	End;

	if (app){
	
		DoMethod(window,
			MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
			app, 2,
			MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);

		DoMethod(busy, MUIM_Busy_Move, FALSE);

		DoMethod(bt_play, MUIM_Notify, MUIA_Pressed, FALSE,
					busy, 3, MUIM_Set, MUIA_Busy_Speed, 20);
		DoMethod(bt_stop, MUIM_Notify, MUIA_Pressed, FALSE,
					busy, 3, MUIM_Set, MUIA_Busy_Speed, MUIV_Busy_Speed_Off);

		DoMethod(list, MUIM_List_InsertSingle, "1 - Première piste", MUIV_List_Insert_Bottom);
		DoMethod(list, MUIM_List_InsertSingle, "2 - Deuxième piste", MUIV_List_Insert_Bottom);

		DoMethod(sl_volume, MUIM_Notify, MUIA_Numeric_Value, MUIV_EveryTime,
					sl_volume, 2, MUIM_CallHook, &hook_ChangeVolume);

		set(list, MUIA_List_Active, MUIV_List_Active_Top);

		SetAttrs(window, MUIA_Window_Open, TRUE, TAG_END);
	}

	return app;
}


/*
 * Initialisation et vérification de tout ce qui est nécessaire à la bonne exécution
 * de l'application : ouverture des bibliothèques, test de présence des classes MCC, ...
 */
int Initialize(void)
{
	int res = 1;
	Object *busy = NULL;

	// Initialisation de la configuration (chargement éventuel à partir d'un fichier)
	config.unit = 2;
	strcpy(config.device, "ide.device");

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


/*
 * Programme principal : il appelle les initialisations, ouvre la fenêtre puis gère
 * les événements jusqu'à ce qu'on ferme l'application, condition de libération
 * des ressources
 */
int main(int argc, char **argv)
{
	int res = 0;

	if (Initialize()){
		app = OpenMainWindow();
		if (app){
			/* Boucle de gestion des évènements, toujours la même */
			ULONG sigs = 0;

			while (DoMethod(app,MUIM_Application_NewInput,&sigs) != MUIV_Application_ReturnID_Quit)
			{
				if (sigs)
				{
					sigs = Wait(sigs | SIGBREAKF_CTRL_C);
					if (sigs & SIGBREAKF_CTRL_C) break;
				}
			}

			/* Libération des ressources et fermeture */
			set(window, MUIA_Window_Open, FALSE);
			MUI_DisposeObject(app);
		}else{
			res = 2;
		}
	}else{
		res = 1;
	}

	DeInitialize();

	return res;
}
