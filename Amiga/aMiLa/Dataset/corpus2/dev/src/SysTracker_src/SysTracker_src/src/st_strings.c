/***************************************************************************/
/* st_string.c - Strings.                                                  */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/

UBYTE *Strings[] = /* Eventually all strings will end up here */
{
  /* SID_EMPTY                      */ "",
  /* SID_OK                         */ "OK",
  /* SID_ERROR                      */ "Error",
  /* SID_UNKNOWN_BRACKET            */ "(unknown)",
  /* SID_LVO_POINTS_TO              */ "- [LVO points to 0x%08lx, should be 0x%08lx],\n",
  /* SID_LVO_OK                     */ "- [OK],\n",

  /* SID_CANT_REMOVE_PATCHES        */ "SysTracker cannot remove it's patches from the following\n"
                                       "library vectors because another program has also patched\n"
                                       "them:\n\n",

  /* SID_PLEASE_REMOVE_HACKS        */ "\n\n"
                                       "Please quit any patches, hacks, snooping utilities, virus checkers,\n"
                                       "or similar programs that were started after SysTracker, before\n"
                                       "attempting to quit.",

  /* SID_ERROR_REMOVING_PATCHES     */ "Error removing patches",
  /* SID_OK_I_WILL                  */ "OK, I will",
  /* SID_APPS_USING_THIS_RES        */ "Applications also using this resource",
  /* SID_EXIT                       */ "Exit",
  /* SID_SAVE                       */ "Save",
  /* SID_UPDATE                     */ "Update",
  /* SID_QUIT                       */ "Quit",
  /* SID_TRACK_MODE                 */ "Track mode",
  /* SID_NO_APP_OBJECT              */ "Failed to create application object!",
  /* SID_ACCESSED_FMT_TIMES         */ "Accessed %lu time(s)",
  /* SID_SYSTEM_RESOURCE_TRACKER    */ "System resource tracker",
  /* SID_SAVE_AS_ASCII              */ "Save as ASCII text...",
  /* SID_SHORTHELP_APPLIST          */ "This is the list of applications being tracked by SysTracker",
  /* SID_SHORTHELP_SAVE             */ "Save list as ASCII text for later reference",
  /* SID_SHORTHELP_UPDATE           */ "Go load some programs, then come back and press this",
  /* SID_SHORTHELP_QUIT             */ "Quit SysTracker.",
  /* SID_SHORTHELP_RESNAME          */ "Name of the resource",
  /* SID_SHORTHELP_LIST             */ "Applications that are also using this resource",
  /* SID_SHORTHELP_TRACKERLIST      */ "This lister shows the resources currently allocated by the selected application.",
  /* SID_SHORTHELP_TRACKEROPENCNT   */ "This shows you the amount of times the selected\nitem has been accessed by the application.",
  /* SID_SHORTHELP_TRACK_MODE       */ "Use this to select the track mode",
  /* SID_SHORTHELP_EXIT             */ "Close this window",
  /* SID_I_NEED_LIB                 */ "I need %s version %ld!",
  /* SID_TASK                       */ "Task",
  /* SID_PROCESS                    */ "Process",
  /* SID_UNKNOWN                    */ "Unknown",
  /* SID_ALIVE                      */ "Alive",
  /* SID_DEAD                       */ "Dead",
  /* SID_NA                         */ "N/A",
  /* SID_CLI                        */ "CLI",
  /* SID_WB                         */ "WB",
  /* SID_APPNAME                    */ "\33bApplication name",
  /* SID_TYPE                       */ "\33bType",
  /* SID_STATUS                     */ "\33bStatus",
  /* SID_ORIGIN                     */ "\33bOrigin",
  /* SID_CANT_GET_STACK_MEM         */ "Cannot get stack memory!",
  /* SID_CANT_GET_MEMORY_RESOURCES  */ "Failed to allocate primary memory resources",
  /* SID_OLD_CPU                    */ "Sorry, I need at least an MC68020 CPU. :-(",
  /* SID_OLD_OS                     */ "Sorry, I need OS 3.0 or better. :-(",
  /* SID_CANT_INVOKE_HANDLER        */ "Failed to invoke ARTL handler process!",
  /* SID_CANNOT_OPEN_FOLLOWING_LIBS */ "SysTracker cannot open the following libraries!\n\n",
  /* SID_LIB_VERSION_FMT            */ "%-30s version %ld\n",
  /* SID_UNNAMED_BRACKET            */ "(unnamed)",
  /* SID_EMPTY_NAME_BRACKET         */ "(empty name)",
  /* SID_GENERATED_WITH             */ "\n*** Generated with %s on %s ***\n\n",
  /* SID_IS_USING                   */ "%s is using:\n",
  /* SID_LISTTITLE_LIBRARIES        */ "\33bLibraries",
  /* SID_LISTTITLE_DEVICES          */ "\33bDevices",
  /* SID_LISTTITLE_FONTS            */ "\33bFonts",
  /* SID_LISTTITLE_OPENCOUNT        */ "\33bAccessCnt",
};

GPROTO UBYTE *STR_Get( ULONG SID )
{
  if (SID > SID_AMOUNT) return "";
  else return Strings[SID];
}


