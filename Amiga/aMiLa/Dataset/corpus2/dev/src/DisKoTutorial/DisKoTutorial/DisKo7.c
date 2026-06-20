
/*
 * DisKo7.c (11/10/04) - Dérivation de classe
 * 
 * VBCC OS4 :
 * vc -ISDK:Local/common/include/ -ICoding:MUI/DisKoTutorial/cdmanager/ -D__USE_INLINE__ -D__USE_BASETYPE__ -DDoSuperMethodA=IDoSuperMethodA -c DisKo7.c 
 *
 * On voit avec le type de UtilityBase la complexité qui apparait, due à des variantes entre les différents SDK.
 */

#include <stdio.h>
#include <string.h>

#include <clib/alib_protos.h>
#include <libraries/mui.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>
#include <proto/exec.h>
#include <proto/utility.h>

#include <mui/Busy_mcc.h>

#include <SDI_hook.h>
#include <SDI_stdarg.h>

#include "cdmanager.h"

#define MAKE_ID(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

#if defined(__VBCC__)
#define UTILITYBASE_TYPE 	struct UtilityBase
#elif defined(__MORPHOS__) || defined(__SASC)
#define UTILITYBASE_TYPE	struct Library
#else
#define UTILITYBASE_TYPE 	struct UtilityBase
#endif

struct IntuitionBase	*IntuitionBase	= NULL;
struct Library			*MUIMasterBase	= NULL;
UTILITYBASE_TYPE		*UtilityBase = NULL;

#ifdef __amigaos4__
struct IntuitionIFace *IIntuition;
struct MUIMasterIFace *IMUIMaster;
struct UtilityIFace *IUtility;
#endif

#define	MUIA_Application_UsedClasses	0x8042e9a7	/* V20 STRPTR *	i..	*/

static char *ClassList[] =
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

static char titles[24][64];

struct MUI_CustomClass *cl_disko;

/*
 * Attention, cas spécial. DoSuperNew n'est défini que sous MorphOS
 * Il existe deux moyens : celui utilisant les SDI_headers ne fonctionnant pas avec VBCC 68k,
 * on laisse les deux pour exemple.
 */

#ifndef __MORPHOS__
#ifdef __amigaos4__
Object * STDARGS VARARGS68K DoSuperNew(struct IClass *cl, APTR obj, ...)
{
	Object *rc;
	VA_LIST args;

	VA_START(args, obj);
	rc = (Object *)DoSuperMethod(cl, obj, OM_NEW, VA_ARG(args, ULONG), NULL);
	VA_END(args);

	return rc;
}
#else
APTR __stdargs DoSuperNew(struct IClass *cl, APTR obj, ULONG tag1, ...)
{
	return ((APTR)DoSuperMethod(cl, obj, OM_NEW, &tag1, NULL));
}
#endif
#endif


/*************************************************************************************/

struct DisKoData {
	Object *lv_titles;
	Object *lst_titles;
	Object *busy;
	Object *txt_info;

	char device[64];
	int unit;

	int track;
};

#define DISKOTAGBASE			(TAG_USER + 0x61843716)

#define MUIA_DisKo_Device				(DISKOTAGBASE + 0)
#define MUIA_DisKo_Unit					(DISKOTAGBASE + 1)
#define MUIA_DisKo_Track				(DISKOTAGBASE + 2)

#define MUIM_DisKo_Play					(DISKOTAGBASE + 20)
#define MUIM_DisKo_Stop					(DISKOTAGBASE + 21)
#define MUIM_DisKo_Previous			(DISKOTAGBASE + 22)
#define MUIM_DisKo_Next					(DISKOTAGBASE + 23)


static ULONG DisKoNew(struct IClass *cl, Object *obj, struct opSet *msg)
{
	Object *lv_titles, *lst_titles, *busy, *txt_info;
	int i, tracks;

	obj = DoSuperNew(cl, obj,
					MUIA_Frame, MUIV_Frame_Group,
					Child, lv_titles = ListviewObject,
						MUIA_Listview_List, lst_titles = ListObject,
							MUIA_Frame, MUIV_Frame_InputList,
						End,
					End,
					Child, HGroup,
						Child, txt_info = TextObject,
							MUIA_Frame, MUIV_Frame_Text,
							MUIA_Text_Contents, "Information piste",
						End,
						Child, busy = BusyObject,
							MUIA_Busy_Speed, MUIV_Busy_Speed_Off,
						End,
					End,
					TAG_MORE, msg->ops_AttrList);

	/* Si l'objet a bien été créé, on poursuit son initialisation */

	if (obj){
		struct DisKoData *data = (struct DisKoData *)INST_DATA(cl, obj);
		struct TagItem *tags,*tag;

		/* On sauvegarde dans la structure les références sur les objets du groupe,
         sinon elles seront perdues à la fermeture de la fonction constructeur */

		data->lv_titles = lv_titles;
		data->lst_titles = lst_titles;
		data->busy = busy;
		data->txt_info = txt_info;

		strcpy(data->device, "ide.device");
		data->unit = 2;

		data->track = 1;

		/* parse initial taglist */

		for (tags=((struct opSet *)msg)->ops_AttrList;tag=NextTagItem(&tags);){
			switch (tag->ti_Tag){
				case MUIA_DisKo_Unit:
					set(obj, MUIA_DisKo_Unit, tag->ti_Data);
					break;
				case MUIA_DisKo_Device:
					set(obj, MUIA_DisKo_Device, tag->ti_Data);
					break;
			}
		}

		tracks = CDM_GetNumTracks();
		for (i=1 ; i<=tracks ; i++){
			sprintf(titles[i], "Piste %d", i);
			DoMethod(data->lst_titles, MUIM_List_InsertSingle, titles[i], MUIV_List_Insert_Bottom);
		}


		set(data->lst_titles, MUIA_List_Active, MUIV_List_Active_Top);

		DoMethod(data->lst_titles, MUIM_Notify, MUIA_List_Active, MUIV_EveryTime,
			obj, 1, MUIM_DisKo_Play);
	}

	return (ULONG)obj;
}


/*
 * Cette méthode "dispose" n'a aucun intérêt ici, à part montrer sa construction.
 * Vu qu'on n'a aucune donnée allouée dynamiquement dans notre structure, l'appel à la méthode dispose
 * de la classe mère dans le dispatcher aurait suffi
 */
static ULONG DisKoDispose(struct IClass *cl, Object *obj, struct opSet *msg)
{
	struct DisKoData *data;

	data = (struct DisKoData *)INST_DATA(cl, obj);

	/* Ici, code de libération des ressources dynamiques des données internes */



	return (DoSuperMethodA(cl, obj, msg));
}


static ULONG DisKoSet(struct IClass *cl, Object *obj, struct opSet *msg)
{
	struct DisKoData *data;
	struct TagItem *tags, *tag;

	data = (struct DisKoData *)INST_DATA(cl, obj);

	for (tags=((struct opSet *)msg)->ops_AttrList;tag=NextTagItem(&tags);){
		switch (tag->ti_Tag){

			case MUIA_DisKo_Unit:
				data->unit = tag->ti_Data;
				break;
			case MUIA_DisKo_Device:
				if (tag->ti_Data){
					strcpy(data->device, (char *)tag->ti_Data);
				}
				break;
		}
	}

	return (DoSuperMethodA(cl, obj, msg));
}

static ULONG DisKoPlay(struct DisKoData *data)
{
	int val;

	get(data->lst_titles, MUIA_List_Active, &val);
	val++;

	CDM_PlayTrack(val);

	set(data->busy, MUIA_Busy_Speed, 20);

	return TRUE;
}

static ULONG DisKoStop(struct DisKoData *data)
{
	CDM_StopTrack();

	set(data->busy, MUIA_Busy_Speed, MUIV_Busy_Speed_Off);

	return TRUE;
}

static ULONG DisKoPrevious(struct DisKoData *data)
{
	set(data->lst_titles, MUIA_List_Active, MUIV_List_Active_Up);

	return TRUE;
}

static ULONG DisKoNext(struct DisKoData *data)
{
	set(data->lst_titles, MUIA_List_Active, MUIV_List_Active_Down);

	return TRUE;
}


DISPATCHERPROTO(DisKoDispatcher)
{
	struct DisKoData *data = (struct DisKoData *)INST_DATA(cl, obj);

	/* Un appel de méthode a été fait sur l'objet DisKo, on identifie laquelle c'est */

	switch(msg->MethodID){
		case OM_NEW :						return DisKoNew(cl, obj, (APTR)msg); break;
		case OM_DISPOSE :					return DisKoDispose(cl, obj, (APTR)msg); break;
		case OM_SET:						return DisKoSet(cl, obj, (APTR)msg); break;

		case MUIM_DisKo_Play :			return DisKoPlay(data); break;
		case MUIM_DisKo_Stop :			return DisKoStop(data); break;
		case MUIM_DisKo_Previous :		return DisKoPrevious(data); break;
		case MUIM_DisKo_Next :			return DisKoNext(data); break;

	}

	/* Si la méthode n'appartient à aucune que l'on a défini, on remonte l'appel à l'objet père */
	return DoSuperMethodA(cl, obj, msg);
}



/*************************************************************************************/

/* On conserve le hook sur le volume pour montrer comment ça fonctionne */


HOOKPROTONH(ChangeVolume, ULONG, APTR obj, struct TagItem *tag_list)
{
	int val;

	get(obj, MUIA_Numeric_Value, &val);
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
	Object *sl_volume;

	Object *sl_unit;
	Object *str_device;

	Object *obj_disko;

	/* Description de l'interface et de ses propriétés */	

	app = (Object *)ApplicationObject,
		MUIA_Application_Author, "corto@guru-meditation.net",
		MUIA_Application_Base, "DISKO",
		MUIA_Application_Title, "DisKo - Exemple 7",
		MUIA_Application_Version, "$VER: DisKo 1.07 (14/10/04)",
		MUIA_Application_Copyright, "Mathias PARNAUDEAU",
		MUIA_Application_Description, "Player de CD audio minimaliste",
		MUIA_Application_HelpFile, NULL,
		MUIA_Application_UsedClasses, ClassList,

		SubWindow, window = WindowObject,
			MUIA_Window_Title, "DisKo - release 7",
			MUIA_Window_ID, MAKE_ID('W', 'I', 'N', '1'),
			WindowContents, VGroup,

				Child, RegisterGroup(Pages),
					MUIA_Register_Frame, TRUE,

					// Onglet utilisation
					Child, VGroup,
						Child, HGroup,
							Child, obj_disko = NewObject(cl_disko->mcc_Class, NULL, MUIA_DisKo_Unit, config.unit, MUIA_DisKo_Device, config.device, TAG_DONE),

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

		DoMethod(sl_volume, MUIM_Notify, MUIA_Numeric_Value, MUIV_EveryTime,
					sl_volume, 2, MUIM_CallHook, &hook_ChangeVolume);
/*
		DoMethod(sl_volume, MUIM_Notify, MUIA_Pressed, FALSE,
					sl_volume, 2, MUIM_CallHook, &hook_ChangeVolume);
*/
		DoMethod(bt_play, MUIM_Notify, MUIA_Pressed, FALSE,
					obj_disko, 1, MUIM_DisKo_Play);

		DoMethod(bt_stop, MUIM_Notify, MUIA_Pressed, FALSE,
					obj_disko, 1, MUIM_DisKo_Stop);

		DoMethod(bt_previous, MUIM_Notify, MUIA_Pressed, FALSE,
					obj_disko, 1, MUIM_DisKo_Previous);

		DoMethod(bt_next, MUIM_Notify, MUIA_Pressed, FALSE,
					obj_disko, 2, MUIM_DisKo_Next);

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
	config.unit = 2;
	strcpy(config.device, "ide.device");
#endif

	IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39L);
	MUIMasterBase = OpenLibrary(MUIMASTER_NAME, MUIMASTER_VMIN);
	UtilityBase = (UTILITYBASE_TYPE *)OpenLibrary("utility.library", 39);
	cdm = CDM_Initialize(config.device, config.unit);

	if (IntuitionBase == NULL){
		printf("Impossible d'ouvrir 'intuition.library' V39\n");
		res = 0;
	}
	if (MUIMasterBase == NULL){
		printf("Impossible d'ouvrir '%s' V%d\n", MUIMASTER_NAME, MUIMASTER_VMIN);
		res = 0;
	}
	if (UtilityBase == NULL){
		printf("Impossible d'ouvrir 'utility.library' V39\n");
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
	IUtility = (struct UtilityIFace *)GetInterface(UtilityBase, "main", 1, NULL);
	if (!IUtility){
		printf("Impossible d'obtenir l'interface IUtility\n");
		res = 0;
	}
#endif

	if (cdm){
		printf("Impossible d'initialiser le module CDDA, erreur %d\n", cdm);
		printf("Veuillez modifier le device et l'unité dans la fonction Initialize() de DisKo7.c\n");
		printf("Et vérifiez qu'un CD audio est bien présent dans le lecteur ! ;-)\n");
		res = 0;
	}

	busy = BusyObject, End;
	if (busy == NULL){
		printf("Classe Busy manquante\n");
		res = 0;
	}
	MUI_DisposeObject(busy);

	cl_disko = MUI_CreateCustomClass(NULL, MUIC_Group, NULL, sizeof(struct DisKoData),  ENTRY(DisKoDispatcher));
	if (cl_disko == NULL){
		printf("Impossible de créer la classe interne DisKo\n");
		res = 0;
	}

	return res;
}


/*
 * Fermeture et libération de tout ce qui a été initialisé au démarrage.
 */
void DeInitialize(void)
{
	if (cl_disko){
		MUI_DeleteCustomClass(cl_disko);
	}
	CloseLibrary((struct Library *)UtilityBase);
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
	if (IUtility) {
		DropInterface((struct Interface *)IUtility);
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
