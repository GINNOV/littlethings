/*
 * sqlitequery.c
 * Main program of this graphical tool that displays results of queries in a listview.
 * It is intended to keep it simple as a example of how to program with libsqlite3.
 *
 * Requirements (Aminet is your friend) :
 * - libsqlite3 : http://aminet.net/package/biz/dbase/sqlite-3.5.4-amiga
 * - SDI_headers : http://aminet.net/package/dev/c/sdi_headers-1.6
 * - NList and NListview MUI classes : http://aminet.net/search?query=mcc_nlist
 *
 * How to compile :
 * - GCC MorphOS
 * gcc -Wall -noixemul -o sqlitequery sqlitequery.c -lsqlite3
 * - GCC AmigaOS4
 * gcc -Wall -g -ggdb -D__USE_BASETYPE__ -D__USE_INLINE__ -o sqlitequery sqlitequery.c -lsqlite3 -lm
 *
 * To do :
 * - add a list of previously run requests
 * - check existence of NList class at initialization
 * - add a list of tables with their structures and other database information
 * - compile it with vbcc (at the moment, fail when linking with undefined math symbols)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libraries/mui.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>
#include <clib/alib_protos.h>

#include <mui/TextEditor_mcc.h>
#include <mui/NListview_mcc.h>

#include <SDI_hook.h>

#include <sqlite3.h>

#define MAKE_ID(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

struct Library *MUIMasterBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;

#ifdef __amigaos4__
struct MUIMasterIFace *IMUIMaster;
struct IntuitionIFace *IIntuition;
#endif

#define	MUIA_Application_UsedClasses	0x8042e9a7	/* V20 STRPTR *	i..	*/

static char *ClassList[] =
{
	"TextEditor.mcc",
	"NList.mcc",
	"NListview.mcc",
	NULL
};

static char window_title[148];

static Object *app = NULL;
static Object *window = NULL;
static Object *txt_result = NULL;
static Object *lv_result, *lst_result;

static sqlite3 *db = NULL;
static int print_col_names = 1;

// Structure that describes each resulting row from a query
struct ReqData {
	int nb;
	char **columns;
};


#define APPAUTHOR		"Corto"
#define APPBASE			"BASE"
#define APPTITLE			"sqlitequery"
#define APPVERSION		"$VER title 0.10 (10/08/2008)"
#define APPCOPYRIGHT		"Copyright"
#define APPDESCRIPTION	"Graphical tool to display results of SQLite queries"
#define WINTITLE			"sqlitequery"


/****************** Part that contains hooks to manage the result list *******************/

HOOKPROTONH(ResultList_Construct, ULONG, APTR pool, struct ReqData *reqdata)
{
	struct ReqData *newreqdata;
	int n;

	newreqdata = AllocPooled(pool, sizeof(struct ReqData));
	if (newreqdata){
		newreqdata->nb = reqdata->nb;
		newreqdata->columns = AllocPooled(pool, reqdata->nb * sizeof(char *));
		for (n=0 ; n<reqdata->nb ; n++){
			if (reqdata->columns[n]){
				newreqdata->columns[n] = AllocPooled(pool, strlen(reqdata->columns[n]) + 1);
				strcpy(newreqdata->columns[n], reqdata->columns[n]);
			}else{
				newreqdata->columns[n] = AllocPooled(pool, 5);
				strcpy(newreqdata->columns[n], "NULL");
			}
		}
	}

	return (ULONG)newreqdata;
}

MakeStaticHook(hook_ResultList_Construct, ResultList_Construct);


HOOKPROTONH(ResultList_Destruct, ULONG, APTR pool, struct ReqData *reqdata)
{
	int n;

	for (n=0 ; n<reqdata->nb ; n++){
		FreePooled(pool, reqdata->columns[n], strlen(reqdata->columns[n]) + 1);
	}

	FreePooled(pool, reqdata->columns, reqdata->nb * sizeof(char *));

	FreePooled(pool, reqdata, sizeof(struct ReqData));

	return 0;
}

MakeStaticHook(hook_ResultList_Destruct, ResultList_Destruct);


/*
 * Whenever MUI feels that the list title has to be drawn, it will
 * call your display hook with a NULL entry pointer. Your
 * hook has to check for this NULL entry and fill the
 * given string array with your column titles.
 */
HOOKPROTO(ResultList_Display, ULONG, char **array, struct ReqData *reqdata)
{
	struct ReqData *dispreq;
	int n;

	if (reqdata){
		dispreq = reqdata;
	}else{
		dispreq = (struct ReqData *)hook->h_Data;
	}

	if (dispreq){
		for (n=0; n<dispreq->nb ; n++){
			*array++ = dispreq->columns[n];
		}
	}

	return 0;
}

MakeStaticHook(hook_ResultList_Display, ResultList_Display);


/****************** Part that makes database access *******************************/


/*
 * This function is called for each row got from a query.
 * Each time a query is validated, the global variable print_col_names is set to 1
 * to indicate that the function is called for the first time and must give the column titles.
 * I decided to put the titles in the field h_Data of the display structure.
 */
static int DisplayResults(void *NotUsed, int argc, char **argv, char **azColName){
	int i;
	struct ReqData reqdata;
	struct ReqData *titledata;
	char str_format[64];

	// Dynamic build of the string that describes the number and format of the columns
	for (i=0 ; i<argc-1 ; i++){
		str_format[i] = ',';
	}
	str_format[i] = 0;
	set(lst_result, MUIA_NList_Format, str_format);

	// At the first call of this function, we prepare the display of the column names in the title bar
	if (print_col_names == 1){
		titledata = AllocVec(sizeof(struct ReqData), MEMF_ANY);
		titledata->nb = argc;
		titledata->columns = AllocVec(argc * sizeof(char *), MEMF_ANY); //azColName;
		for (i=0 ; i<argc ; i++){
			titledata->columns[i] = AllocVec(strlen(azColName[i]) + 1, MEMF_ANY);
			strcpy(titledata->columns[i], azColName[i]);
		}

		hook_ResultList_Display.h_Data = (APTR)titledata;
		set(lst_result, MUIA_NList_Title, TRUE);

		print_col_names = 0;
	}

	reqdata.nb = argc;
	reqdata.columns = argv;
	DoMethod(lst_result, MUIM_NList_InsertSingle, &reqdata, MUIV_NList_Insert_Bottom);

	return 0;
 }


/*
 * Function associated to the hook called when the button "Execute requete" is pressed.
 * The query is executed by sqlite3_exec() that calls the function DisplayResults through its hook for each row.
 */
HOOKPROTONH(ExecuteRequestFunc, ULONG, APTR obj, struct TagItem *tag_list)
{
	char *request;
	int rc;
	char *zErrMsg = 0;

	// Get the content of the query in the TextEditor object and send it to sqlite3_exec
	// Display the error messages in the read-only text area at the bottom

	request = (char *)DoMethod(obj, MUIM_TextEditor_ExportText);
	if (request){

		DoMethod(txt_result, MUIM_TextEditor_ClearText);
		DoMethod(lst_result, MUIM_NList_Clear);

		// Send and execute the SQL query
		print_col_names = 1;
		rc =  sqlite3_exec (db, request, DisplayResults, lst_result, &zErrMsg);

		if( rc!=SQLITE_OK ){
			DoMethod(txt_result, MUIM_TextEditor_InsertText, zErrMsg);
		}

		FreeVec(request);
	}

	return TRUE;
}

MakeStaticHook(hook_ExecuteRequest, ExecuteRequestFunc);


/*
 * Almost the same function than the previous one that execute requests. This one does not
 * read a request written by hand but run the one that read the admin table that contains
 * the database structure (and names of existing tables in our case).
 */
HOOKPROTONH(ListTablesFunc, ULONG, APTR obj, struct TagItem *tag_list)
{
	char *request = "select name from sqlite_master where type = 'table'";
	int rc;
	char *zErrMsg = 0;

	DoMethod(lst_result, MUIM_NList_Clear);

	// Send and execute the SQL query
	print_col_names = 1;
	rc =  sqlite3_exec (db, request, DisplayResults, lst_result, &zErrMsg);

	// Display an error message if it fails
	if( rc!=SQLITE_OK ){
		DoMethod(txt_result, MUIM_TextEditor_InsertText, zErrMsg);
	}

	return TRUE;
}

MakeStaticHook(hook_ListTables, ListTablesFunc);

Object * OpenMainWindow(char *database_name)
{
	Object *txt_request, *bt_execute, *bt_list_tables;
	Object *app2;

	/* Interface description here */

	app2 = (Object *)ApplicationObject,
		MUIA_Application_Author, APPAUTHOR,
		MUIA_Application_Base, APPBASE,
		MUIA_Application_Title, APPTITLE,
		MUIA_Application_Version, APPVERSION,
		MUIA_Application_Copyright, APPCOPYRIGHT,
		MUIA_Application_Description, APPDESCRIPTION,
		MUIA_Application_HelpFile, NULL,
		MUIA_Application_UsedClasses, ClassList,

		SubWindow, window = WindowObject,
			MUIA_Window_Title, WINTITLE,
			MUIA_Window_ID, MAKE_ID('W', 'I', 'N', '1'),
			WindowContents, VGroup,

				Child, txt_request = TextEditorObject,
				End,

				Child, HGroup,
					Child, bt_execute = KeyButton("Execute request", 'e'),
					Child, bt_list_tables = KeyButton("List tables", 't'),
				End,

				Child, lv_result = NListviewObject,
					MUIA_NListview_NList, lst_result = NListObject,
						MUIA_Frame, MUIV_Frame_InputList,
						MUIA_NList_ConstructHook, &hook_ResultList_Construct,
						MUIA_NList_DestructHook, &hook_ResultList_Destruct,
						MUIA_NList_DisplayHook, &hook_ResultList_Display,
					End,
				End,

				Child, VGroup, GroupFrameT("Error message"),
					Child, txt_result = TextEditorObject,
						MUIA_TextEditor_ReadOnly, TRUE,
						MUIA_Weight, 40,
					End,
				End,

			End,
		End,
	End;

	if (app2){
		/* Initialization of some values and notifications */
	
		DoMethod(window,
			MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
			app2, 2,
			MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);

		DoMethod(bt_execute, MUIM_Notify, MUIA_Pressed, FALSE,
					txt_request, 2, MUIM_CallHook, &hook_ExecuteRequest);

		DoMethod(bt_list_tables, MUIM_Notify, MUIA_Pressed, FALSE,
					txt_request, 2, MUIM_CallHook, &hook_ListTables);

		set(window, MUIA_Window_Open, TRUE);
		set(window, MUIA_Window_ActiveObject, txt_request);
		sprintf(window_title, "%s : %s", WINTITLE, database_name);
		set(window, MUIA_Window_Title, window_title);

		// Initial query for example
		set(txt_request, MUIA_TextEditor_Contents, "select * from projects");
	}

	return app2;
}


/*
 * Initialize and check all the needed stuff for a right execution of the program :
 * open libraries, check MCC classes
 */
int Initialize(void)
{
	int res = 1;
	Object *texted;

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
	IMUIMaster = (struct MUIMasterIFace *)GetInterface(MUIMasterBase, "main", 1, NULL);
#endif

	texted = TextEditorObject, End;
	if (texted == NULL){
		printf("Classe TextEditor manquante\n");
		res = 0;
	}
	MUI_DisposeObject(texted);

	return res;
}


/*
 * Close and free all previously initialized resources
 */
void DeInitialize(void)
{

#ifdef __amigaos4__
	if (IIntuition) {
		DropInterface((struct Interface *)IIntuition);
	}
	if (IMUIMaster) {
		DropInterface((struct Interface *)IMUIMaster);
	}
#endif

	CloseLibrary(MUIMasterBase);
	CloseLibrary((struct Library *)IntuitionBase);
}


int main(int argc, char **argv)
{
	int res = 0;
	int rc;

	if (argc != 2){
		fprintf(stderr, "Usage : %s DATABASE\n", argv[0]);
		exit(1);
	}

	rc =  sqlite3_open (argv[1], &db);
	if( rc ){
		fprintf(stderr, "Impossible to open the database file : %s\n", sqlite3_errmsg(db));
		exit(1);
	}

	if (Initialize()){
		app = OpenMainWindow(argv[1]);
		if (app){
			/* Main event loop */

			ULONG sigs = 0;

			while (DoMethod(app,MUIM_Application_NewInput,&sigs) != MUIV_Application_ReturnID_Quit)
			{
				if (sigs)
				{
					sigs = Wait(sigs | SIGBREAKF_CTRL_C);
					if (sigs & SIGBREAKF_CTRL_C) break;
				}
			}

			/* Free resources and close */

			FreeVec((struct ReqData *)hook_ResultList_Display.h_Data);
			set(window, MUIA_Window_Open, FALSE);
			MUI_DisposeObject(app);
		}else{
			res = 2;
		}
	}else{
		res = 1;
	}

	/* Close libraries and database */

	DeInitialize();
	sqlite3_close (db);

	return res;
}
