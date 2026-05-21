/*
 * PdaLink -- Connect Palm with Amiga
 *
 * Copyright (C) 1998-2010 Richard "Shred" Körber
 *   http://pdalink.shredzone.org
 *
 * This library is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * ARexx interface.
 *
 * @author Richard "Shred" Körber
 */
 
#include <stdio.h>
#include <string.h>
#include "pdalink_glob.h"

#define ARG3(rmp) (rmp->rm_Args[3])    /* Extension to rexx/storage.h */


static struct TrackArgs
{
  struct RDArgs *rdargs;
  unsigned char param[0];
};

/*----------------------------------------------------------------
** parseArgs    Parse Parameter String                 LOCAL
//>
*/
struct TrackArgs *parseArgs(STRPTR param, STRPTR template, LONG *array)
{
  struct TrackArgs *targ;

  if(targ = AllocVec(sizeof(struct TrackArgs) + strlen(param) + 5, MEMF_PUBLIC|MEMF_CLEAR))
  {
    if(targ->rdargs = AllocDosObject(DOS_RDARGS,NULL))
    {
      strcpy(targ->param, (param ? param : (STRPTR) "") );
      strcat(targ->param, "\n");
      targ->rdargs->RDA_Flags |= RDAF_NOPROMPT;
      targ->rdargs->RDA_Source.CS_Buffer = targ->param;
      targ->rdargs->RDA_Source.CS_Length = strlen(targ->param);
      if(ReadArgs(template,array,targ->rdargs))
      {
        return(targ);
      }
      FreeDosObject(DOS_RDARGS,targ->rdargs);
    }
    FreeVec(targ);
  }
  return(NULL);
}
//<
/*----------------------------------------------------------------
** freeArgs     Free a parameter list                       LOCAL
//>
*/
void freeArgs(struct TrackArgs *targ)
{
  if(targ)
  {
    FreeArgs(targ->rdargs);
    FreeDosObject(DOS_RDARGS,targ->rdargs);
    FreeVec(targ);
  }
}
//<
/*----------------------------------------------------------------
** returnString  Return a String as result                  LOCAL
//>
*/
void returnString(struct RexxArg **rxarg, STRPTR string)
{
  *rxarg = (struct RexxArg *)CreateArgstring(string,strlen(string));
}
//<
/*----------------------------------------------------------------
** returnNum    Return an Integer as result                 LOCAL
//>
*/
void returnNum(struct RexxArg **rxarg, LONG num)
{
  unsigned char strbuf[30];
  sprintf(strbuf,"%lu",num);
  returnString(rxarg,strbuf);
}
//<
/*----------------------------------------------------------------
** setStringVar Set an ARexx variable to a String           LOCAL
//>
*/
int setStringVar(struct RexxMsg *msg, STRPTR base, STRPTR var, STRPTR cont)
{
  char *buffer = AllocVec(strlen(base)+strlen(var)+2,MEMF_PUBLIC);    // Get a buffer
  int rc = FALSE;
  if(buffer)
  {
    strcpy(buffer,base);
    strcat(buffer,".");
    strcat(buffer,var);
    rc = !SetRexxVar((struct Message *)msg,buffer,cont,strlen(cont));
    FreeVec(buffer);
  }
  return rc;
}
//<
/*----------------------------------------------------------------
** setNumVar    Set an ARexx variable to an integer         LOCAL
//>
*/
int setNumVar(struct RexxMsg *msg, STRPTR base, STRPTR var, LONG cont)
{
  char numbuffer[20];
  char *buffer = AllocVec(strlen(base)+strlen(var)+2,MEMF_PUBLIC);    // Get a buffer
  int rc = FALSE;

  if(buffer)
  {
    strcpy(buffer,base);
    strcat(buffer,".");
    strcat(buffer,var);
    sprintf(numbuffer,"%ld",cont);
    rc = !SetRexxVar((struct Message *)msg,buffer,numbuffer,strlen(numbuffer));
    FreeVec(buffer);
  }
  return rc;
}
//<
/*----------------------------------------------------------------
** setSysTimeVar  Set ARexx variable to DLP_SysTime         LOCAL
//>
*/
int setSysTimeVar(struct RexxMsg *msg, STRPTR base, STRPTR var, struct DLP_SysTime *time)
{
  char timebuf[50];

  if(time->year==0)
    strcpy(timebuf,"---");
  else
    sprintf(timebuf,"%04ld-%02ld-%02ld %02ld:%02ld:%02ld",time->year,time->month,time->day,time->hour,time->minute,time->second);
  return setStringVar(msg,base,var,timebuf);
}
//<
/*----------------------------------------------------------------
** setIDVar     Set ARexx variable to an ID                 LOCAL
//>
*/
int setIDVar(struct RexxMsg *msg, STRPTR base, STRPTR var, ULONG id)
{
  char idbuf[5];

  idbuf[0] = (id>>24)&0xFF;
  idbuf[1] = (id>>16)&0xFF;
  idbuf[2] = (id>>8)&0xFF;
  idbuf[3] = id&0xFF;
  idbuf[4] = 0x00;
  return setStringVar(msg,base,var,idbuf);
}
//<


/*------------------------------------------------------**
** Name:        PL_AddRexxHandle                  PUBLIC
**
** Funktion:    Fügt einen RexxHandle in die Liste ein
**
** Parameter:   name      Name des Handles (case Sensitive)
**              handle    Handle
** Ergebnis:
//>
** Bemerkungen:
**
** Revision:    29. Oktober 1998, 23:05:17
*/
__saveds __asm void PL_AddRexxHandle
(
  register __a0 APTR handle,
  register __a1 STRPTR name
)
{
  struct RexxHandle *newHandle;

  ObtainSemaphore(&global.rexxHandleSemaphore);         // obtain a semaphore
  newHandle = AllocVec(sizeof(struct RexxHandle) + strlen(name) + 1 , MEMF_PUBLIC|MEMF_CLEAR);
  if(newHandle)                                         // create structure
  {
    newHandle->rh_node.ln_Name = newHandle->rh_name;    // set ln_Name
    strcpy(newHandle->rh_name,name);                    // copy the name
    newHandle->rh_handle = handle;                      // and the handle
    AddTail(&global.rexxHandles,(struct Node *)newHandle);
  }
  ReleaseSemaphore(&global.rexxHandleSemaphore);
}
//<
/*------------------------------------------------------**
** Name:        PL_FindRexxHandle                 PUBLIC
**
** Funktion:    Sucht einen RexxHandle aus der Liste
**
** Parameter:   name      Name des Handles (case Sensitive)
** Ergebnis:    handle    Handle
//>
** Bemerkungen:
**
** Revision:    29. Oktober 1998, 23:10:06
*/
__saveds __asm APTR PL_FindRexxHandle
(
  register __a0 STRPTR name
)
{
  struct RexxHandle *handle;
  APTR plh = NULL;

  ObtainSemaphore(&global.rexxHandleSemaphore);         // obtain semaphore
  handle = (struct RexxHandle *)FindName(&global.rexxHandles,name);
  if(handle)
    plh = handle->rh_handle;
  ReleaseSemaphore(&global.rexxHandleSemaphore);
  return(plh);
}
//<
/*------------------------------------------------------**
** Name:        PL_DeleteRexxHandle               PUBLIC
**
** Funktion:    Entfernt einen RexxHandle aus der Liste
**
** Parameter:   name      Name des Handles (case Sensitive)
** Ergebnis:
//>
** Bemerkungen:
**
** Revision:    29. Oktober 1998, 23:11:31
*/
__saveds __asm void PL_DeleteRexxHandle
(
  register __a0 STRPTR name
)
{
  struct RexxHandle *handle;

  ObtainSemaphore(&global.rexxHandleSemaphore);         // obtain semaphore
  handle = (struct RexxHandle *)FindName(&global.rexxHandles,name);
  if(handle)
  {
    Remove((struct Node *)handle);
    FreeVec(handle);
  }
  ReleaseSemaphore(&global.rexxHandleSemaphore);
}
//<

/**
 * Open a socket
 */
static LONG rx_openSocket(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "SD=DEVICE/K,SU=UNIT/K/N,SB=MAXBAUD/K/N";
  struct Parameter
  {
    STRPTR device;
    LONG   *unit;
    LONG   *baud;
  } param = {0};
  struct TrackArgs *targ;
  APTR handle;
  LONG error;
  ULONG tags[20];
  int i = 0;

  if(!ARG1(rxmsg)) return(ERR10_017);           /*  wrong number of arguments   */

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    tags[i++] = PLTAG_ErrorPtr;
    tags[i++] = (ULONG) &error;
    if(param.device)
    {
      tags[i++] = PLTAG_SerialDevice;
      tags[i++] = (ULONG) param.device;
    }
    if(param.unit)
    {
      tags[i++] = PLTAG_SerialUnit;
      tags[i++] = (ULONG) *param.unit;
    }
    if(param.baud)
    {
      tags[i++] = PLTAG_SerialMaxRate;
      tags[i++] = (ULONG) *param.baud;
    }
    tags[i] = TAG_DONE;

    handle = PL_OpenSocket((struct TagItem *)tags);

    rxmsg->rm_Result1 = error;

    PL_AddRexxHandle(handle,ARG1(rxmsg));

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Close a socket
 */
static LONG rx_closeSocket(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  PL_DeleteRexxHandle(ARG1(rxmsg));
  PL_CloseSocket(socket);
  return(0);
}
//<

/**
 * Accept a connection
 */
static LONG rx_accept(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "TIMEOUT/K/N";
  struct Parameter
  {
    LONG   *timeout;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;
  LONG to = 30;             // default to 30 Seconds Timeout

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    if(param.timeout) to = *param.timeout;
    if(!PL_Accept(socket,to))
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Open Conduit
 */
static LONG rx_openConduit(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(!DLP_OpenConduit(socket))
    rxmsg->rm_Result1 = PL_LastError(socket);

  return(0);
}
//<

/**
 * Close Conduit
 */
static LONG rx_endOfSync(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "STATUS/N";
  struct Parameter
  {
    LONG  *status;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    LONG status = 0;
    if(param.status) status = *param.status;

    if(!DLP_EndOfSync(socket,status))
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Add entry to HotSync Log
 */
static LONG rx_addSyncLogEntry(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  LONG rc=0;
  static STRPTR template = "ENTRY/A,NOLF/S";
  struct Parameter
  {
    STRPTR  entry;
    LONG    nolf;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    char *buf = AllocVec(strlen(param.entry)+2,MEMF_PUBLIC);
    if(buf)
    {
      strcpy(buf,param.entry);
      if(!param.nolf) strcat(buf,"\n");
      if(!DLP_AddSyncLogEntry(socket,buf))
        rxmsg->rm_Result1 = PL_LastError(socket);
      FreeVec(buf);
    }
    else
      rc = ERR10_003;                         /* no memory available */

    freeArgs(targ);
    return(rc);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Read information about database
 */
static LONG rx_getDBInfo(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "INDEX/N/A,ROM/S,CARD/K/N";
  struct Parameter
  {
    LONG   *index;
    LONG   rom;
    LONG   *card;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;

  if(!ARG3(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    struct DLP_DBInfo info;
    UBYTE cardno = 0;
    UBYTE flags  = DLPGDBF_RAM;
    char name[36];

    if(param.card) cardno = *param.card;
    if(param.rom)  flags  = DLPGDBF_ROM;

    if(DLP_GetDBInfo(socket,cardno,flags,*param.index,&info))
    {
      stccpy       (name,info.name,34);
      setStringVar (rxmsg,ARG3(rxmsg),"NAME"      ,name);
      setNumVar    (rxmsg,ARG3(rxmsg),"INDEX"     ,info.index);
      setSysTimeVar(rxmsg,ARG3(rxmsg),"CREATED"   ,&info.createDate);
      setSysTimeVar(rxmsg,ARG3(rxmsg),"MODIFIED"  ,&info.modifyDate);
      setSysTimeVar(rxmsg,ARG3(rxmsg),"BACKUPPED" ,&info.backupDate);
      setNumVar    (rxmsg,ARG3(rxmsg),"VERSION"   ,info.version);
      setIDVar     (rxmsg,ARG3(rxmsg),"CREATOR"   ,info.creator);
      setIDVar     (rxmsg,ARG3(rxmsg),"TYPE"      ,info.type);
      setNumVar    (rxmsg,ARG3(rxmsg),"FLAGS"     ,info.flags);
      setNumVar    (rxmsg,ARG3(rxmsg),"EXCLUDE"   ,info.excludes);

      returnNum(rxarg,info.more);
    }
    else
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Read the current baud rate
 */
static LONG rx_getBaudRate(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;
  ULONG rate;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  rate = PL_GetBaudRate(socket);
  returnNum(rxarg,rate);
  return(0);
}
//<

/**
 * Read the last error code
 */
static LONG rx_lastError(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;
  LONG ec;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  ec = PL_LastError(socket);
  returnNum(rxarg,ec);
  return(0);
}
//<

/**
 * Explains an error code
 */
static LONG rx_explain(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "CODE/N/A";
  struct Parameter
  {
    LONG   *code;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;
  char buffer[100];

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    PL_Explain(*param.code,buffer,100);
    returnString(rxarg,buffer);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Reset system
 */
static LONG rx_resetSystem(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(!DLP_ResetSystem(socket))
    rxmsg->rm_Result1 = PL_LastError(socket);

  return(0);
}
//<

/**
 * Reset LastSyncPC
 */
static LONG rx_resetLastSyncPC(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;

  if(!ARG1(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(!DLP_ResetLastSyncPC(socket))
    rxmsg->rm_Result1 = PL_LastError(socket);

  return(0);
}
//<

/**
 * Changes information about NetSyncInfo
 */
static LONG rx_netSyncInfo(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "LANSYNC/K/N,HOSTNAME/K,HOSTADDRESS/K,HOSTSUBNETMASK/K";
  struct Parameter
  {
    LONG   *lansync;
    STRPTR hostname;
    STRPTR hostaddress;
    STRPTR hostsubnetmask;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;
  int changed = FALSE;

  if(!ARG3(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    struct DLP_NetSyncInfo nsi;
    char buffer[260];

    if(DLP_GetNetSyncInfo(socket,&nsi))
    {
      if(param.lansync)
      {
        nsi.lanSync = *param.lansync;
        changed = TRUE;
      }
      if(param.hostname)
      {
        strncpy(nsi.hostName,param.hostname,256);
        changed = TRUE;
      }
      if(param.hostaddress)
      {
        strncpy(nsi.hostAddress,param.hostaddress,40);
        changed = TRUE;
      }
      if(param.hostsubnetmask)
      {
        strncpy(nsi.hostSubnetMask,param.hostsubnetmask,40);
        changed = TRUE;
      }

      setNumVar    (rxmsg,ARG3(rxmsg),"LANSYNC"       ,nsi.lanSync);
      stccpy(buffer,nsi.hostName,256);
      setStringVar (rxmsg,ARG3(rxmsg),"HOSTNAME"      ,buffer);
      stccpy(buffer,nsi.hostAddress,40);
      setStringVar (rxmsg,ARG3(rxmsg),"HOSTADDRESS"   ,buffer);
      stccpy(buffer,nsi.hostSubnetMask,40);
      setStringVar (rxmsg,ARG3(rxmsg),"HOSTSUBNETMASK",buffer);

      if(changed)
      {
        if(!DLP_SetNetSyncInfo(socket,&nsi))
          rxmsg->rm_Result1 = PL_LastError(socket);
      }
    }
    else
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Change information about UserInfo
 */
static LONG rx_userInfo(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "USERNAME/K,PASSWORD/K";
  struct Parameter
  {
    STRPTR username;
    STRPTR password;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;
  int changed = FALSE;

  if(!ARG3(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    struct DLP_UserInfo ui;
    char buffer[130];

    if(DLP_GetUserInfo(socket,&ui))
    {
      if(param.username)
      {
        strncpy(ui.userName,param.username,128);
        changed = TRUE;
      }

      if(param.password)
      {
        strncpy(ui.password,param.password,128);
        changed = TRUE;
      }

      setIDVar     (rxmsg,ARG3(rxmsg),"USERID"        ,ui.userID);
      setIDVar     (rxmsg,ARG3(rxmsg),"VIEWERID"      ,ui.viewerID);
      setNumVar    (rxmsg,ARG3(rxmsg),"LASTSYNCPC"    ,ui.lastSyncPC);
      setSysTimeVar(rxmsg,ARG3(rxmsg),"LASTSYNC"      ,&ui.lastSync);
      setSysTimeVar(rxmsg,ARG3(rxmsg),"SUCCESSFULSYNC",&ui.successfulSync);
      stccpy(buffer,ui.userName,128);
      setStringVar (rxmsg,ARG3(rxmsg),"USERNAME"      ,buffer);
      stccpy(buffer,ui.password,128);
      setStringVar (rxmsg,ARG3(rxmsg),"PASSWORD"      ,buffer);

      if(changed)
      {
        if(!DLP_SetUserInfo(socket,&ui))
          rxmsg->rm_Result1 = PL_LastError(socket);
      }
    }
    else
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Change system time
 */
static LONG rx_sysTime(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "D=DAY/K/N,MO=MONTH/K/N,Y=YEAR/K/N,H=HOUR/K/N,MI=MINUTE/K/N,S=SECOND/K/N";
  struct Parameter
  {
    LONG  *day;
    LONG  *month;
    LONG  *year;
    LONG  *hour;
    LONG  *minute;
    LONG  *second;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;
  int changed = FALSE;

  if(!ARG3(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    struct DLP_SysTime st;

    if(DLP_GetSysTime(socket,&st))
    {
      if(param.day)
      {
        LONG day = *param.day;
        if(day>=1 && day<=31)
        {
          st.day = day;
          changed = TRUE;
        }
      }
      if(param.month)
      {
        LONG month = *param.month;
        if(month>=1 && month<=12)
        {
          st.month = month;
          changed = TRUE;
        }
      }
      if(param.year)
      {
        LONG year = *param.year;
        if(year<200) year+=1900;
        st.year = year;
        changed = TRUE;
      }
      if(param.hour)
      {
        LONG hour = *param.hour;
        if(hour>=0 && hour<=23)
        {
          st.hour = hour;
          changed = TRUE;
        }
      }
      if(param.minute)
      {
        LONG minute = *param.minute;
        if(minute>=0 && minute<=59)
        {
          st.minute = minute;
          changed = TRUE;
        }
      }
      if(param.second)
      {
        LONG second = *param.second;
        if(second>=0 && second<=60)        // UTC may have 61 seconds per minute!
        {
          st.second = second;
          changed = TRUE;
        }
      }

      setSysTimeVar(rxmsg,ARG3(rxmsg),"TIME"      ,&st);
      setNumVar    (rxmsg,ARG3(rxmsg),"SECOND"    ,st.second);
      setNumVar    (rxmsg,ARG3(rxmsg),"MINUTE"    ,st.minute);
      setNumVar    (rxmsg,ARG3(rxmsg),"HOUR"      ,st.hour);
      setNumVar    (rxmsg,ARG3(rxmsg),"DAY"       ,st.day);
      setNumVar    (rxmsg,ARG3(rxmsg),"MONTH"     ,st.month);
      setNumVar    (rxmsg,ARG3(rxmsg),"YEAR"      ,st.year);

      if(changed)
      {
        if(!DLP_SetSysTime(socket,&st))
          rxmsg->rm_Result1 = PL_LastError(socket);
      }
    }
    else
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Read StorageInfo
 */
static LONG rx_getStorageInfo(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  static STRPTR template = "CARD/N";
  struct Parameter
  {
    LONG   *card;
  } param = {0};
  struct TrackArgs *targ;
  APTR socket;

  if(!ARG3(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(targ = parseArgs(ARG2(rxmsg),template,(LONG *)&param))
  {
    struct DLP_StorageInfo info;
    UBYTE cardno = 0;
    char name[130];

    if(param.card) cardno = *param.card;

    if(DLP_GetStorageInfo(socket,cardno,&info))
    {
      stccpy       (name,info.name,128);
      setStringVar (rxmsg,ARG3(rxmsg),"NAME"        ,name);
      stccpy       (name,info.manuf,128);
      setStringVar (rxmsg,ARG3(rxmsg),"MANUFACTURER",name);
      setNumVar    (rxmsg,ARG3(rxmsg),"CARDNO"      ,info.cardNo);
      setNumVar    (rxmsg,ARG3(rxmsg),"VERSION"     ,info.cardVersion);
      setSysTimeVar(rxmsg,ARG3(rxmsg),"CREATED"     ,&info.date);
      setNumVar    (rxmsg,ARG3(rxmsg),"ROMSIZE"     ,info.ROMSize);
      setNumVar    (rxmsg,ARG3(rxmsg),"RAMSIZE"     ,info.RAMSize);
      setNumVar    (rxmsg,ARG3(rxmsg),"RAMFREE"     ,info.RAMFree);

      returnNum(rxarg,info.more);
    }
    else
      rxmsg->rm_Result1 = PL_LastError(socket);

    freeArgs(targ);
    return(0);
  }
  return(ERR10_018);                          /*  invalid argument to function*/
}
//<

/**
 * Read SysInfo
 */
static LONG rx_getSysInfo(struct RexxMsg *rxmsg, struct RexxArg **rxarg)
//>
{
  APTR socket;
  struct DLP_SysInfo info;

  if(!ARG2(rxmsg)) return(ERR10_017);         /*  wrong number of arguments   */
  socket = PL_FindRexxHandle(ARG1(rxmsg));
  if(!socket) return(ERR10_018);              /*  invalid argument to function*/

  if(DLP_GetSysInfo(socket,&info))
  {
    char name[130];
    stccpy       (name,info.name,128);
    setStringVar (rxmsg,ARG2(rxmsg),"SYSNAME"   ,name);
    setNumVar    (rxmsg,ARG2(rxmsg),"ROMVERSION",info.romVer);
    setNumVar    (rxmsg,ARG2(rxmsg),"LOCALIZION",info.locale);
  }
  else
    rxmsg->rm_Result1 = PL_LastError(socket);

  return(0);
}
//<


/*----------------------------------------------------------------
** RexxCmd      Rexx command call
//>
*/
__saveds __asm LONG RexxCmd
(
  register __a0 struct RexxMsg *rxmsg,
  register __a1 struct RexxArg **rxarg
)
{
  STRPTR cmdstr = ARG0(rxmsg);

  // Quick and dirty test
  if(strnicmp(cmdstr,"PDA_",5))
    return(1);

  // It is most probably one of our commands, so perform
  // a detailed test.
  /*TODO: speed this up a litte bit, preferably with a nice hash table*/
  if(!stricmp(cmdstr,"PDA_OPENSOCKET"))
    return rx_openSocket(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_CLOSESOCKET"))
    return rx_closeSocket(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_ACCEPT"))
    return rx_accept(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_OPENCONDUIT"))
    return rx_openConduit(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_ENDOFSYNC"))
    return rx_endOfSync(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_ADDSYNCLOGENTRY"))
    return rx_addSyncLogEntry(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_GETDBINFO"))
    return rx_getDBInfo(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_LASTERROR"))
    return rx_lastError(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_EXPLAIN"))
    return rx_explain(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_RESETSYSTEM"))
    return rx_resetSystem(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_RESETLASTSYNCPC"))
    return rx_resetLastSyncPC(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_USERINFO"))
    return rx_userInfo(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_SYSTIME"))
    return rx_sysTime(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_NETSYNCINFO"))
    return rx_netSyncInfo(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_GETSTORAGEINFO"))
    return rx_getStorageInfo(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_GETSYSINFO"))
    return rx_getSysInfo(rxmsg,rxarg);

  if(!stricmp(cmdstr,"PDA_GETBAUDRATE"))
    return rx_getBaudRate(rxmsg,rxarg);

  return(1);                                      // Command not known
}
//<

/****************************************************************/

