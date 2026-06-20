/*
 * DisKo6.c (04/08/04)
 *
 */

#include <stdio.h>
#include <string.h>
#include <libraries/mui.h>
#include <proto/muimaster.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <clib/alib_protos.h>

#include <mui/Busy_mcc.h>

#include <SDI_hook.h>

#include "cdmanager.h"

#define MAKE_ID(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

struct Library *MUIMasterBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;

#ifdef __amigaos4__
struct IntuitionIFace *IIntuition;
struct MUIMasterIFace *IMUIMaster;
#endif

#define	MUIA_Application_UsedClasses	0x8042e9a7	/* V20 STRPTR *	i..	*/

static char *ClassList[] =
{
	"Busy.mcc",
	NULL
};

static Object *app = NULL;
static Object *window = NULL;
static Object *list;
static Object *busy;

static char *Pages[] = { "Utilisation", "Configuration", NULL };

struct Config {
	int unit;
	char device[32];
} config;

static char titles[24][64];


/*
 * Hooks nécessaires en attendant mieux ... ;-)
 */

HOOKPROTONH(ChangeVolume, ULONG, APTR obj, struct TagItem *tag_list)
{
	int val;

	get(obj, MUIA_Numeric_Value, &val);

	printf("Nouvelle valeur : %d\n", val);

	return TRUE;
}
MakeStaticHook(hook_ChangeVolume, ChangeVolume);

HOOKPROTONH(hook_PlayTrackFunc, ULONG, APTR obj, struct TagItem *tag_list)
{
	int val;

	get(obj, MUIA_List_Active, &val);
	val++;

	CDM_PlayTrack(val);

	set(busy, MUIA_Busy_Speed, 20);

	return TRUE;
}

MakeStaticHook(hook_PlayTrack, hook_PlayTrackFunc);

HOOKPROTONH(hook_StopTrackFunc, ULONG, APTR obj, struct TagItem *tag_list)
{
	CDM_StopTrack();

	set(busy, MUIA_Busy_Speed, MUIV_Busy_Speed_Off);

	return TRUE;
}

MakeStaticHook(hook_StopTrack, hook_StopTrackFunc);

/*
 * Construction et ouverture de la fenêtre principale.
 * Cette fonction est appelée quand on sait que tout a bien été initialisé.
 */
Object * OpenMainWindow(void)
{
	Object *bt_play, *bt_stop, *bt_previous, *bt_next, *bt_pause, *bt_eject;
	Object *lv_pistes;
	Object *sl_volume;

	Object *sl_unit;
	Object *str_device;
	Object *txt_info;

	int i, tracks;

	/* Description de l'interface et de ses propriétés */	

	app = (Object *)ApplicationObject,
		MUIA_Application_Author, "corto@guru-meditation.net",
		MUIA_Application_Base, "DISKO",
		MUIA_Application_Title, "DisKo - Exemple 6",
		MUIA_Application_Version, "$VER: DisKo 1.06 (27/07/04)",
		MUIA_Application_Copyright, "Mathias PARNAUDEAU",
		MUIA_Application_Description, "Player de CD audio minimaliste",
		MUIA_Application_HelpFile, NULL,
		MUIA_Application_UsedClasses, ClassList,

		SubWindow, window = WindowObject,
			MUIA_Window_Title, "DisKo - release 6",
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
									//MUIA_List_Format, "P=\33r",
									MUIA_List_Active, MUIV_List_Active_Top,
									MUIA_List_AutoVisible, TRUE,
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
		/* On fixe quelques valeurs et notifications */
	
		DoMethod(window,
			MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
			app, 2,
			MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);

		DoMethod(busy, MUIM_Busy_Move, FALSE);

		tracks = CDM_GetNumTracks();
		for (i=1 ; i<=tracks ; i++){
			sprintf(titles[i], "Piste %d", i);
			DoMethod(list, MUIM_List_InsertSingle, titles[i], MUIV_List_Insert_Bottom);
		}

		DoMethod(sl_volume, MUIM_Notify, MUIA_Numeric_Value, MUIV_EveryTime,
					sl_volume, 2, MUIM_CallHook, &hook_ChangeVolume);
/*
		DoMethod(sl_volume, MUIM_Notify, MUIA_Pressed, FALSE,
					sl_volume, 2, MUIM_CallHook, &hook_ChangeVolume);
*/
		DoMethod(bt_play, MUIM_Notify, MUIA_Pressed, FALSE,
					list, 2, MUIM_CallHook, &hook_PlayTrack); //MUIM_List_Jump, MUIV_List_Jump_Active);

		DoMethod(bt_stop, MUIM_Notify, MUIA_Pressed, FALSE,
					bt_stop, 2, MUIM_CallHook, &hook_StopTrack);

		set(list, MUIA_List_Active, MUIV_List_Active_Top);

		DoMethod(list, MUIM_Notify, MUIA_List_Active, MUIV_EveryTime,
			list, 2, MUIM_CallHook, &hook_PlayTrack);

		DoMethod(bt_previous, MUIM_Notify, MUIA_Pressed, FALSE,
					list, 3, MUIM_Set, MUIA_List_Active, MUIV_List_Active_Up);

		DoMethod(bt_next, MUIM_Notify, MUIA_Pressed, FALSE,
					list, 3, MUIM_Set, MUIA_List_Active, MUIV_List_Active_Down);

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
	int cdm;

	// Initialisation de la configuration (chargement éventuel à partir d'un fichier)
#if defined(__amigaos4__)
	config.unit = 1;
	strcpy(config.device, "a1ide.device");
#elif defined(__MORPHOS__)
	config.unit = 2;
	strcpy(config.device, "ide.device");
#else
	// Pour UAE, ça fonctionne pour moi avec : uaescsi.device, unit 0
	config.unit = 1;
	strcpy(config.device, "scsi.device");
#endif

	IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39L);
	MUIMasterBase = OpenLibrary(MUIMASTER_NAME, MUIMASTER_VMIN);
	cdm = CDM_Initialize(config.device, config.unit);

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

	if (cdm){
		printf("Impossible d'initialiser le module CDDA avec %s, unité %d\n", config.device, config.unit);
		printf("Veuillez modifier le device et l'unité dans la fonction Initialize() de DisKo6.c\n");
		printf("Et vérifiez qu'un CD audio est bien présent dans le lecteur ! ;-)\n");
		res = 0;
	}

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

	CloseLibrary(MUIMasterBase);
	CloseLibrary((struct Library *)IntuitionBase);
	CDM_DeInitialize();

#ifdef __amigaos4__
	if (IMUIMaster) {
		DropInterface((struct Interface *)IMUIMaster);
	}
	if (IIntuition) {
		DropInterface((struct Interface *)IIntuition);
	}
#endif
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
