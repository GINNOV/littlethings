
/* This proto file was generated on Monday 14-Feb-00 20:58:46 */

#ifndef GPROTO
#define GPROTO
#endif /* GPROTO */

#ifndef LPROTO
#define LPROTO
#endif /* LPROTO */


/*
 * Global prototypes for module st_main.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

void DEBUG( void );
void M_PrgError( UBYTE *ErrStr, APTR ErrFmt );

/*
 * Local prototypes for module st_main.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

LONG wbmain( void );
int main( void );
BOOL M_InitPrg( void );
void M_EndPrg( void );
void M_DoPrg( void );

/*
 * Global prototypes for module st_strings.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

UBYTE *STR_Get( ULONG SID );

/*
 * Global prototypes for module st_gui.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

BOOL GUI_InitMUI( void );
void GUI_EndMUI( void );
BOOL GUI_Construct( void );
void GUI_Destruct( void );
void GUI_EventHandler( void );
ULONG GUI_Popup( UBYTE *Title, UBYTE *Body, void *BodyFmt, UBYTE *Gads );
ULONG GUI_Get_Cycle_Active( ULONG CycleID );
APTR GUI_Get_List_Entry( ULONG ListID, ULONG Index );
APTR GUI_Get_List_Active( ULONG ListID );
void GUI_Act_List_Clear( ULONG ListID );
struct Screen *GUI_Get_ScreenPtr( void );
void GUI_Set_List_Active( ULONG ListID, ULONG Index );
void GUI_Set_Text_Contents( ULONG TextID, UBYTE *Str );
void GUI_Set_List_Quiet( ULONG ListID, BOOL State );
void GUI_Act_Window_Open( ULONG WndID, BOOL State );
void GUI_Act_AboutGUISystem( void );
void GUI_Act_ConfigureGUISystem( void );
void GUI_Set_App_Iconified( BOOL State );
BOOL GUI_OpenSaveReq( UBYTE *PathBuf, ULONG PathBufLen );
void GUI_Act_List_InsertABC( ULONG ListID, APTR ListEntry );
void GUI_Set_Menuitem_Enabled( ULONG WinID, ULONG MenuItemID, BOOL NewState );

/*
 * Global prototypes for module st_memory.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

BOOL MEM_Init( void );
void MEM_Free( void );
APTR MEM_AllocVec( ULONG Size );
void MEM_FreeVec( APTR Vec );
UBYTE *MEM_StrToVec( UBYTE *Str );

/*
 * Global prototypes for module st_misc.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

ULONG R_GetTasksStackSize( void );
BOOL R_DateStampToStr( struct DateStamp *DS, UBYTE *Buf );
BOOL R_IsTaskPtrValid( struct Task *TaskPtr );

/*
 * Global prototypes for module st_artl.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

BOOL ARTL_Init( void );
BOOL ARTL_Free( void );
BOOL ARTL_SendSimpleAPMCmd( LONG CmdID );
BOOL ARTL_SendAPM( struct ARTLProcessMsg *APM );
struct AppList *ARTL_GetAppList( void );
void ARTL_Set_TrackMode( ULONG NewTrackMode );
ULONG ARTL_Get_TrackMode( void );
BOOL ARTL_CheckProcSignals( ULONG SigsGot );
ULONG ARTL_GetPMsgCnt( void );
LONG ARTL_ClearDeadANs( struct AppList *AL );
ULONG ARTL_ClearUnusedANs( struct AppList *AL );
ULONG ARTL_ClearUnusedTNs( struct List *TL );
void ARTL_AppListKillFunc( register __a2 APTR Pool,
  register __a1 struct AppNode *AN );
struct AppNode *ARTL_AppListMakeFunc( register __a2 APTR Pool,
  register __a1 struct AppNode *AN );
LONG ARTL_AppListShowFunc( register __a2 UBYTE **ColumnArray,
  register __a1 struct AppNode *AN );
LONG ARTL_AppListSortFunc( register __a1 struct AppNode *AN1,
  register __a2 struct AppNode *AN2 );
void ARTL_TrackerListKillFunc( register __a2 APTR Pool,
  register __a1 struct TrackerNode *TN );
struct TrackerNode *ARTL_TrackerListMakeFunc(
  register __a2 APTR Pool,
  register __a1 struct TrackerNode *TN );
LONG ARTL_TrackerListShowFunc( register __a2 UBYTE **ColumnArray,
  register __a1 struct TrackerNode *TN );
LONG ARTL_TrackerListSortFunc(
  register __a1 struct TrackerNode *TN1,
  register __a2 struct TrackerNode *TN2 );

/*
 * Local prototypes for module st_artl.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

LONG ARTL_HandlerProcess( void );
BOOL ATRL_InitHandlerDebug( void );
void ATRL_EndHandlerDebug( void );
void ARTL_PMsgDebug( struct PatchMsg *PMsg );
struct AppNode *ARTL_PushLibAN( struct AppList *AL,
  struct PatchMsg *PMsg );
void ARTL_PullLibAN( struct AppList *AL, struct PatchMsg *PMsg );
struct AppNode *ARTL_PushDevAN( struct AppList *AL,
  struct PatchMsg *PMsg );
void ARTL_PullDevAN( struct AppList *AL, struct PatchMsg *PMsg );
struct AppNode *ARTL_PushFontAN( struct AppList *AL,
  struct PatchMsg *PMsg );
void ARTL_PullFontAN( struct AppList *AL, struct PatchMsg *PMsg );
struct AppNode *ARTL_PushLockAN( struct AppList *AL,
  struct PatchMsg *PMsg );
void ARTL_PullLockAN( struct AppList *AL, struct PatchMsg *PMsg );
struct AppNode *ARTL_PushFileHandleAN( struct AppList *AL,
 struct PatchMsg *PMsg );
void ARTL_PullFileHandleAN( struct AppList *AL,
  struct PatchMsg *PMsg );
struct AppList *ARTL_AllocAL( void );
void ARTL_FreeAL( struct AppList *AL );
void ARTL_LockAL( struct AppList *AL );
void ARTL_UnlockAL( struct AppList *AL );
void ARTL_FlushAL( struct AppList *AL );
struct AppNode *ARTL_CreateAN_ViaPMsg( struct PatchMsg *PMsg );
BOOL ARTL_AddANToAL( struct AppNode *InsAN, struct AppList *AL );
struct AppNode *ARTL_AllocAN( void );
void ARTL_FreeAN( struct AppNode *AN );
struct AppNode *ARTL_CloneAN( struct AppNode *AN );
struct AppNode *ARTL_FindAN_ViaTaskPtr( struct AppList *AL,
  struct Task *TaskPtrToFnd );
void ARTL_UnlinkAN( struct AppNode *AN );
UWORD ARTL_UpdateANStatus( struct AppNode *AN );
UBYTE *ARTL_SetANTaskName( struct AppNode *AN, UBYTE *TaskName );
UBYTE *ARTL_SetANCmdName( struct AppNode *AN, UBYTE *CmdName );
void ARTL_UpdateAL( struct AppList *AL );
BOOL ARTL_SaveALAsASCII( struct AppList *AL, UBYTE *DestFile,
  BOOL SaveAll );
BOOL ARTL_SaveAL_Libs( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll );
BOOL ARTL_SaveAL_Devs( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll );
BOOL ARTL_SaveAL_Fonts( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll );
BOOL ARTL_SaveAL_Locks( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll );
BOOL ARTL_SaveAL_FHs( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll );
LONG ARTL_GetANListIndex_ViaTaskPtr( struct Task *TaskPtr );
struct TrackerNode *ARTL_CreateTN_ViaPMsg( struct PatchMsg *PMsg );
BOOL ARTL_AddTNToTL(
  struct TrackerNode *InsTN, struct List *TL, ULONG AddMode );
struct TrackerNode *ARTL_AllocTN( void );
void ARTL_FreeTN( struct TrackerNode *TN );
struct TrackerNode *ARTL_CloneTN( struct TrackerNode *TN );
BOOL ATRL_BuildTNPath( struct TrackerNode *TN );
struct TrackerNode *ARTL_FindLibTN_ViaLibName( struct List *TL,
  UBYTE *LibName );
struct TrackerNode *ARTL_FindLibTN_ViaLibBase( struct List *TL,
  struct Library *LibBase );
struct TrackerNode *ARTL_FindDevTN_ViaIOReq(  struct List *TL,
  struct IORequest *IOReq );
struct TrackerNode *ARTL_FindDevTN_ViaDevName( struct List *TL,
  UBYTE *DevName );
struct TrackerNode *ARTL_FindFontTN_ViaTextFont( struct List *TL,
  struct TextFont *TF );
struct TrackerNode *ARTL_FindLockTN_ViaLock( struct List *TL,
  BPTR Lk );
struct TrackerNode *ARTL_FindFileHandleTN_ViaFH( struct List *TL,
  BPTR FH );
void ARTL_UnlinkTN( struct TrackerNode *TN );
void ARTL_FreeTL( struct List *TL );
void ARTL_UpdateTL( struct List *TL );
ULONG ARTL_CountTL( struct List *TL, LONG ID );
ULONG ARTL_CountTNsInUse( struct List *TL );
void ARTL_FindAppsUsingRes( struct TrackerNode *TNToFnd,
  struct AppList *AL );
ULONG ARTL_CountList( struct List *L );

/*
 * Global prototypes for module st_libs.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

BOOL LIBS_Init( void );
void LIBS_Free( void );

/*
 * Global prototypes for module st_actions.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

BOOL ACT_SigEvent( ULONG SigEvent );
void ACT_Main_TrackMode( void );
void ACT_Main_Save( void );
void ACT_Main_Update( void );
void ACT_Main_TrackerListview_DoubleClick( void );
void ACT_Main_TrackerListview_SingleClick( void );
void ACT_Main_AppListview_SingleClick( void );
void ACT_Main_Menu_Project_About( void );
void ACT_Main_Menu_Project_About_MUI( void );
void ACT_Main_Menu_Project_Settings_MUI( void );
void ACT_Main_Menu_Project_Hide( void );
void ACT_Main_Menu_Control_Reset( void );
void ACT_Main_Menu_Control_ClearDeadApps( void );
void ACT_Main_Menu_Control_TrackUnusedResources( BOOL Checked );
void ACT_Main_Menu_Control_ShowUnusedResources( BOOL Checked );
void ACT_Main_Menu_Control_ClearUnusedRes( void );

/*
 * Global prototypes for module st_patches.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

BOOL PATCH_Init( void );
BOOL PATCH_Free( void );
BOOL PATCH_CheckUnpatch( void );

/*
 * Local prototypes for module st_patches.c
 *
 * Auto-generated with XProto 1.1 by Andrew Bell
 *
 */

APTR PATCH_CheckLVO( struct Library *LibBase, LONG LVO,
  APTR OrigFunc, APTR ShouldBeFunc );

