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
 * Example application for transporting data to and from the Palm.
 *
 * @author Richard "Shred" Körber
 */
 
/*
**  Compiles with SAS/C, e.g.
**      sc PdaTransfer.c NOSTACKCHECK DATA=NEAR STRMER CPU=68060 OPT
*/

#include <stdio.h>
#include <string.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>
#include <clib/pdalink_protos.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/pdalink_pragmas.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosasl.h>
#include <libraries/pdalink.h>


#define  VERSIONSTR   "1.1"
#define  DATESTR      "7.1.2000"
#define  COPYRIGHTSTR "2000"
#define  EMAILSTR     "rkoerber@gmx.de"
#define  URLSTR       "http://pdalink.shredzone.org"

#define  NORMAL       "\2330m"
#define  BOLD         "\2331m"
#define  ITALIC       "\2333m"
#define  UNDERLINE    "\2334m"

#define  MKTAG(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

static char ver[] = "$VER: PdaTransfer " VERSIONSTR " (" DATESTR ") " EMAILSTR;
static char titletxt[] = \
  BOLD "PdaTransfer " VERSIONSTR " (C) " COPYRIGHTSTR " Richard Körber" NORMAL "\n\n";
static char helptxt[] = \
  "  " ITALIC "E-Mail: " NORMAL EMAILSTR "\n"
  "  " ITALIC "URL:    " NORMAL URLSTR "\n\n"
  ITALIC "Usage:" NORMAL "\n"
  "  BACKUP/S       Backup the database (DIR)\n"
  "  RESTORE/S      Restore a backup (DIR)\n"
  "  INSTALL/S      Install a file (FILE)\n"
  "  MERGE/S        Merge a file (FILE)\n"
  "  FETCH/S        Fetch a database (NAME)\n"
  "  DELETE/S       Delete a database (NAME)\n"
  "  LIST/S         List all databases\n"
  "  PURGE/S        Purge deleted records\n"
  "  DIR/K          Backup directory (if required)\n"
  "  FILE/K         Filename (if required)\n"
  "  NAME/K         Database name (if required)\n"
  "  DEVICE/K       Serial device (\"serial.device\")\n"
  "  UNIT/K/N       Serial unit (0)\n"
  "  MAXBAUD/K/N    Maximum baud (57600)\n"
  "\n";

struct Parameter
{
  LONG   backup;
  LONG   restore;
  LONG   install;
  LONG   merge;
  LONG   fetch;
  LONG   delete;
  LONG   list;
  LONG   purge;
  STRPTR dir;
  STRPTR file;
  STRPTR name;
  STRPTR device;
  LONG   *unit;
  LONG   *maxbaud;
}
param;

static char template[] = "BACKUP/S,RESTORE/S,INSTALL/S,MERGE/S,FETCH/S,DELETE/S,LIST/S,PURGE/S,D=DIR/K,F=FILE/K,N=NAME/K,SD=DEVICE/K,SU=UNIT/K/N,SB=MAXBAUD/K/N";

struct FileNode
{
  struct Node Node;         // Backup/Restore
  struct DateStamp Date;    // Backup only
  struct DLP_DBInfo dbinfo; // Restore only
  char FileName[108];       // Backup/Restore
};

extern struct DOSBase *DOSBase;
struct Library *PdalinkBase;
struct Library *UtilityBase;
APTR socket = NULL;
BOOL ignoreError = FALSE;



/*
** get last error code as string
*/
STRPTR getError(APTR socket)
{
  static unsigned char errortext[256];
  PL_Explain(PL_LastError(socket),errortext,255);
  return(errortext);
}

/*
** Open a connection to the Pilot
*/
int Connect(void)
{
  LONG error;

  if(socket) return(TRUE);

  socket = PL_OpenSocketTags
    (
    PLTAG_ErrorPtr      , &error,
    (param.device  ? PLTAG_SerialDevice  : TAG_IGNORE) , param.device,
    (param.unit    ? PLTAG_SerialUnit    : TAG_IGNORE) , *param.unit ,
    (param.maxbaud ? PLTAG_SerialMaxRate : TAG_IGNORE) , *param.maxbaud,
    PLTAG_AbortMask     , SIGBREAKF_CTRL_C,
    TAG_DONE
    );

  if(socket)
  {
    Printf("Please press the HotSync button " ITALIC "now" NORMAL "\n");
    if(PL_Accept(socket,10L)) {
      Printf("Connection established, %ld bps\n",PL_GetBaudRate(socket));
      return(TRUE);
    }
  }
  else
  {
    unsigned char errortext[256];
    PL_Explain(error,errortext,255);
    Printf("** Socket error: %s\n",errortext);
  }
  return(FALSE);
}

/*
** Close all databases and disconnect
*/
void Disconnect(void)
{
  if(!socket) return;
  DLP_AddSyncLogEntry(socket,"Synchronized with PdaLink\n-- AMIGA made it possible --\n");
  DLP_EndOfSync(socket,0);
  PL_CloseSocket(socket);
}

/*
** Generate a AmigaDOS conformous file name from the
** DataBase name.
*/
void genFileName(STRPTR name, struct DLP_DBInfo *dbinfo)
{
  UWORD i;

  strcpy(name,dbinfo->name);
  for(i=0; i<strlen(name); i++)
    if(name[i]<' ' || name[i]=='/' || name[i]==':') name[i]='_';  // Protect DOS characters
  if(dbinfo->flags & DLPDBIF_RESOURCE)
    strcat(name,".prc");
  else
    strcat(name,".pdb");
}


/*
** Convert a DLP_SysTime to a DOS DateStamp
*/
void Date2Stamp(struct DLP_SysTime *time, struct DateStamp *ds)
{
  struct ClockData cld;
  ULONG sec;

  cld.year  = time->year;
  cld.month = time->month;
  cld.mday  = time->day;
  cld.hour  = time->hour;
  cld.min   = time->minute;
  cld.sec   = time->second;
  sec = Date2Amiga(&cld);

  ds->ds_Tick   = (sec%60) * TICKS_PER_SECOND;
  sec /= 60;
  ds->ds_Minute = sec%(24*60);
  sec /= 24*60;
  ds->ds_Days   = sec;
}

/*
** Convert a DOS DateStamp to DLP_SysTime
*/
void Stamp2Date(struct DateStamp *ds, struct DLP_SysTime *time)
{
  struct ClockData cld;

  Amiga2Date(((ds->ds_Days*24*60)+ds->ds_Minute)*60+(ds->ds_Tick/TICKS_PER_SECOND),&cld);
  time->year   = cld.year;
  time->month  = cld.month;
  time->day    = cld.mday;
  time->hour   = cld.hour;
  time->minute = cld.min;
  time->second = cld.sec;
}

/*
** Set a DLP_SysTime to the current date and time
*/
void setToday(struct DLP_SysTime *time)
{
  struct DateStamp ds;
  DateStamp(&ds);
  Stamp2Date(&ds,time);
}


/*
** Set the Pilot into a synchronized state
*/
void VoidSyncFlags(void)
{
  struct DLP_UserInfo user;
  if(Connect())
  {
    if(DLP_GetUserInfo(socket,&user))
    {
      user.lastSyncPC = 0x00000000;     // Hopefully unique...
      setToday(&user.successfulSync);
      setToday(&user.lastSync);
      DLP_SetUserInfo(socket,&user);
    }
  }
}


/*
** Backup a database
*/
void cmd_backup(STRPTR dir)
{
  APTR fh;
  BPTR lock;
  BPTR olddir;
  struct FileInfoBlock *fib;
  struct List files;
  struct FileNode *newnode;
  struct FileNode *currEntry, *nextEntry;
  struct DLP_DBInfo dbinfo;
  struct DLP_SysTime time;
  struct DateStamp stamp;

  UWORD i;
  char filename[100];

  NewList(&files);

  if(!dir)
  {
    PutStr("** DIR required\n");
    return;
  }

  /* Check if existing, and if it is really a directory */
  if(!(fib = AllocVec(sizeof(struct FileInfoBlock),MEMF_PUBLIC))) return;
  lock = Lock(dir,ACCESS_READ);
  if(!lock)                             // Does not exist, so create it
  {
    lock = CreateDir(dir);
    if(!lock)                           // Couldn't create either
    {
      Printf("** Couldn't create directory %s\n",dir);
      FreeVec(fib);
      return;
    }
  }

  if(!Examine(lock,fib))
  {
    Printf("** Couldn't examine directory %s\n",dir);
    goto error;
  }
  if(fib->fib_DirEntryType < 0)
  {
    Printf("** %s is not a directory\n",dir);
    goto error;
  }

  olddir = CurrentDir(lock);

  /* Read all file names into the files list */
  while(ExNext(lock,fib))
  {
    if(fib->fib_DirEntryType > 0) continue;   // Skip subdirectories

    newnode = AllocVec(sizeof(struct FileNode),MEMF_ANY);
    if(!newnode) goto error;

    CopyMem(fib->fib_FileName,newnode->FileName,108);
    CopyMem(&fib->fib_Date,&newnode->Date,sizeof(struct DateStamp));
    newnode->Node.ln_Name = newnode->FileName;
    AddTail(&files,(struct Node *)newnode);
  }

  /* Open conduit */
  if(!Connect()) goto error;

  /* Backup all database entries */
  for(i=0;;)
  {
    if(!DLP_OpenConduit(socket)) goto error;
    if(!DLP_GetDBInfo(socket,0,DLPGDBF_RAM,i,&dbinfo))    // get the next entry
    {
      if(PL_LastError(socket)==PLERR_NOTFOUND) break;     // last one
      goto error;
    }
    i = dbinfo.index+1;
    genFileName(filename,&dbinfo);
    newnode = (struct FileNode *)FindName(&files,filename);   // search for the file
    if(newnode)                                           // File does already exist
    {
      Stamp2Date(&newnode->Date,&time);                   // Check if the file has
      if(  (time.year   == dbinfo.modifyDate.year)        // not been modified since
         &&(time.month  == dbinfo.modifyDate.month)       // last backup
         &&(time.day    == dbinfo.modifyDate.day)
         &&(time.hour   == dbinfo.modifyDate.hour)
         &&(time.minute == dbinfo.modifyDate.minute)
         &&(time.second == dbinfo.modifyDate.second))
      {
        Printf("  Skipped: %s (not changed)\n",newnode->FileName);
        Remove((struct Node *)newnode);                   // yes: skip it
        FreeVec(newnode);
        continue;
      }
    }

    /* Retrieve the file */
    dbinfo.flags &= ~DLPDBIF_OPEN;                        // Saved database is not open

    fh = PL_FileOpen(filename,&dbinfo);
    if(!fh)
    {
      Printf("** Unable to open file %s for writing\n",filename);
      goto error;
    }
    Printf("  Store:   %s (from %s)... ",filename,dbinfo.name);
    Flush(Output());
    if(PL_FileRetrieve(fh,socket,0))                      // Get the file
      PutStr("OK\n");
    else
      Printf("Failed (%s)\n",getError(socket));
    PL_FileClose(fh);

    Date2Stamp(&dbinfo.modifyDate,&stamp);                // Set file date to the
    SetFileDate(filename,&stamp);                         // last modification date

    if(newnode)
    {
      Remove((struct Node *)newnode);                     // Remove from list
      FreeVec(newnode);
    }
  }

  /* Delete all remaining files */
  for
  (
    currEntry=(struct FileNode *)files.lh_Head;
    nextEntry=(struct FileNode *)currEntry->Node.ln_Succ;
    currEntry=nextEntry
  )
  {
    Printf("  Delete:  %s...\n",currEntry->FileName);     // Is deleted on the Pilot too
    Flush(Output());
    if(DeleteFile(currEntry->FileName))
      PutStr("OK\n");
    else
      Printf("Failed (%s)\n",getError(socket));
    Remove((struct Node *)currEntry);
    FreeVec(currEntry);
  }

  VoidSyncFlags();                                        // Sync done

  PutStr("Backup completed successfully\n");

error:
  if(PL_LastError(socket)==PLERR_NOTFOUND) ignoreError = TRUE;
  CurrentDir(olddir);
  for                                                     // Clean up all memory
  (
    currEntry=(struct FileNode *)files.lh_Head;
    nextEntry=(struct FileNode *)currEntry->Node.ln_Succ;
    currEntry=nextEntry
  )
  {
    Remove((struct Node *)currEntry),
    FreeVec(currEntry);
  }
  FreeVec(fib);                         // Release FIB
  UnLock(lock);                         // Free directory lock
  return;
}

/*
** Restore a database
*/
void cmd_restore(STRPTR dir)
{
  APTR fh;
  BPTR lock;
  BPTR olddir;
  struct FileInfoBlock *fib;
  struct List files;
  struct FileNode *newnode;
  struct FileNode *currEntry, *nextEntry;

  NewList(&files);

  if(!dir)
  {
    PutStr("** DIR required\n");
    return;
  }

  /* Check if existing, and if it is really a directory */
  if(!(fib = AllocVec(sizeof(struct FileInfoBlock),MEMF_PUBLIC))) return;
  lock = Lock(dir,ACCESS_READ);
  if(!lock)                             // Does not exist
  {
    Printf("** Couldn't find directory %s\n",dir);
    FreeVec(fib);
    return;
  }

  if(!Examine(lock,fib))
  {
    Printf("** Couldn't examine directory %s\n",dir);
    goto error;
  }
  if(fib->fib_DirEntryType < 0)
  {
    Printf("** %s is not a directory\n",dir);
    goto error;
  }

  olddir = CurrentDir(lock);            // Set as current dir

  /* Read all file names into the files list */
  while(ExNext(lock,fib))
  {
    if(fib->fib_DirEntryType > 0) continue;   // Skip subdirectories

    newnode = AllocVec(sizeof(struct FileNode),MEMF_ANY);
    if(!newnode) goto error;

    CopyMem(fib->fib_FileName,newnode->FileName,108);
    newnode->Node.ln_Name = newnode->FileName;
    CopyMem(&fib->fib_Date,&newnode->Date,sizeof(struct DateStamp));

    fh = PL_FileOpen(newnode->FileName,NULL);
    if(!fh)
    {
      Printf("** Unable to open file %s for reading\n",newnode->FileName);
      goto error;
    }
    CopyMem(PL_FileGetDBInfo(fh),&newnode->dbinfo,sizeof(struct DLP_DBInfo));
    PL_FileClose(fh);

    if(newnode->dbinfo.type == MKTAG('a','p','p','l'))
      AddTail(&files,(struct Node *)newnode);         // send 'appl' as last
    else
      AddHead(&files,(struct Node *)newnode);
  }

  /* Open connection */
  if(!Connect()) goto error;

  /* Restore all database files */
  for
  (
    currEntry=(struct FileNode *)files.lh_Head;
    nextEntry=(struct FileNode *)currEntry->Node.ln_Succ;
    currEntry=nextEntry
  )
  {
    if(!DLP_OpenConduit(socket)) goto error;
    fh = PL_FileOpen(currEntry->FileName,NULL);
    if(!fh)
    {
      Printf("** Unable to open file %s\n",currEntry->FileName);
      goto error;
    }
    Printf("  Restore: %s as %s...",currEntry->FileName,currEntry->dbinfo.name);
    Flush(Output());
    if(PL_FileInstall(fh,socket,0))
      PutStr("OK\n");
    else
      Printf("Failed (%s)\n",getError(socket));
    PL_FileClose(fh);
    Remove((struct Node *)currEntry);
    FreeVec(currEntry);
  }

  PutStr("Restore completed successfully\n");
  VoidSyncFlags();                                        // Sync done

error:
  if(PL_LastError(socket)==PLERR_NOTFOUND) ignoreError = TRUE;
  CurrentDir(olddir);
  for                                                     // Clean up all memory
  (
    currEntry=(struct FileNode *)files.lh_Head;
    nextEntry=(struct FileNode *)currEntry->Node.ln_Succ;
    currEntry=nextEntry
  )
  {
    Remove((struct Node *)currEntry),
    FreeVec(currEntry);
  }
  FreeVec(fib);                         // Release FIB
  UnLock(lock);                         // Free directory lock
  return;
}


/*
** Install a software
*/
void cmd_install(STRPTR file)
{
  APTR fh;

  if(!file)
  {
    PutStr("** FILE required\n");
    return;
  }

  if(!Connect()) return;
  if(!DLP_OpenConduit(socket)) return;

  fh = PL_FileOpen(file,NULL);
  if(!fh)
  {
    Printf("** Unable to open file %s\n",file);
    return;
  }
  Printf("Installing %s...",file);
  Flush(Output());
  if(PL_FileInstall(fh,socket,0))
    PutStr("OK\n");
  else
    Printf("Failed (%s)\n",getError(socket));

  PL_FileClose(fh);
  VoidSyncFlags();
}

/*
** Merge a software
*/
void cmd_merge(STRPTR file)
{
  APTR fh;

  if(!file)
  {
    PutStr("** FILE required\n");
    return;
  }

  if(!Connect()) return;
  if(!DLP_OpenConduit(socket)) return;

  fh = PL_FileOpen(file,NULL);
  if(!fh)
  {
    Printf("** Unable to open file %s\n",file);
    return;
  }
  Printf("Merging %s...",file);
  Flush(Output());
  if(PL_FileMerge(fh,socket,0))
    PutStr("OK\n");
  else
    Printf("Failed (%s)\n",getError(socket));

  PL_FileClose(fh);
  VoidSyncFlags();
}

/*
** Fetch a database
*/
void cmd_fetch(STRPTR name)
{
  struct DLP_DBInfo dbinfo;
  UWORD index;
  BOOL found;
  char filename[50];
  APTR fh;

  if(!name)
  {
    PutStr("** NAME required\n");
    return;
  }

  if(!Connect()) return;
  if(!DLP_OpenConduit(socket)) return;

  for(found=TRUE, index=0;;)
  {
    if(DLP_GetDBInfo(socket,0,DLPGDBF_RAM,index,&dbinfo))
    {
      if(!strcmp(name,dbinfo.name)) break;
      index = dbinfo.index+1;
    }
    else
    {
      found=FALSE;
      break;
    }
  }

  if(!found)
    for(found=TRUE, index=0;;)
    {
      if(DLP_GetDBInfo(socket,0,DLPGDBF_ROM,index,&dbinfo))
      {
        if(!strcmp(name,dbinfo.name)) break;
        index = dbinfo.index+1;
      }
      else
      {
        found=FALSE;
        break;
      }
    }

  if(!found)
  {
    Printf("** Database %s not found\n",name);
    return;
  }

  genFileName(filename,&dbinfo);

  dbinfo.flags &= ~DLPDBIF_OPEN;      // Saved database is not open

  fh = PL_FileOpen(filename,&dbinfo);
  if(!fh)
  {
    Printf("** Unable to open file %s\n",filename);
    return;
  }

  Printf("Fetching %s to file %s... ",name,filename);
  Flush(Output());
  if(PL_FileRetrieve(fh,socket,0))
    PutStr("OK\n");
  else
    Printf("Failed (%s)\n",getError(socket));

  PL_FileClose(fh);
}

/*
** Delete a database
*/
void cmd_delete(STRPTR name)
{
  struct DLP_DBInfo dbinfo = {0};
  UWORD index;
  BOOL found;

  if(!name)
  {
    PutStr("** NAME required\n");
    return;
  }

  if(!Connect()) return;
  if(!DLP_OpenConduit(socket)) return;

  for(found=TRUE, index=0;;)
  {
    if(DLP_GetDBInfo(socket,0,DLPGDBF_RAM,index,&dbinfo))
    {
      if(!strcmp(name,dbinfo.name)) break;
      index = dbinfo.index+1;
    }
    else
    {
      found=FALSE;
      break;
    }
  }

  if(!found)
  {
    Printf("** Database %s not found\n",name);
    return;
  }

  Printf("Deleting %s... ",name);
  Flush(Output());

  if(!DLP_DeleteDB(socket,0,name))
  {
    Printf("Failed (%s)\n",getError(socket));
    return;
  }

  PutStr("OK\n");

  if(dbinfo.type==MKTAG('b','o','o','t')) PutStr("Rebooting after HotSync.\n");
}

/*
** List all databases
*/
void cmd_list(void)
{
  struct DLP_DBInfo info;
  UWORD i;
  ULONG nr;

  if(!Connect()) return;
  if(!DLP_OpenConduit(socket)) return;

  PutStr(BOLD "-- LIST OF ALL RAM DATABASES --" NORMAL "\n");

  for(nr=1,i=0 ; ; nr++)
  {
    if(!DLP_GetDBInfo(socket,0,DLPGDBF_RAM,i,&info)) break;
    Printf("%3ld: '%s'\n",nr,info.name);
    i = info.index+1;
  }

  PutStr(BOLD "-- LIST OF ALL ROM DATABASES --" NORMAL "\n");

  for(nr=1,i=0 ; ; nr++)
  {
    if(!DLP_GetDBInfo(socket,0,DLPGDBF_ROM,i,&info)) break;
    Printf("%3ld: '%s'\n",nr,info.name);
    i = info.index+1;
  }

  PutStr(BOLD "---------------------------" NORMAL "\n");
  if(PL_LastError(socket)==PLERR_NOTFOUND) ignoreError = TRUE;
}

/*
** Purge all deleted records
*/
void cmd_purge(void)
{
  struct DLP_DBInfo info;
  UWORD i;
  LONG dbh;

  if(!Connect()) return;
  if(!DLP_OpenConduit(socket)) return;

  PutStr(BOLD "Purging deleted records from..." NORMAL "\n");

  for(i=0;;)
  {
    if(!DLP_GetDBInfo(socket,0,DLPGDBF_RAM,i,&info)) break;
    i = info.index+1;
    if(info.flags & DLPDBIF_RESOURCE) continue;       // don't purge resources
    Printf("  %s: ",info.name);
    Flush(Output());
    dbh = DLP_OpenDB(socket,0,DLPDBOF_READWRITE,info.name);
    if(   dbh>=0
       && DLP_CleanUpDatabase(socket,dbh)
       && DLP_ResetSyncFlags(socket,dbh))
    {
      PutStr("OK\n");
      DLP_CloseDB(socket,dbh);
    }
    else
    {
      Printf("Failed (%s)\n",getError(socket));
    }
  }
  if(PL_LastError(socket)==PLERR_NOTFOUND) ignoreError = TRUE;
  VoidSyncFlags();
}

/*
** MAIN PART
*/
int main(void)
{
  struct RDArgs *args;

  PutStr(titletxt);

  if(args = (struct RDArgs *)ReadArgs(template,(LONG *)&param,NULL))
  {
    if(UtilityBase = OpenLibrary("utility.library",36L))
    {
      if(PdalinkBase = OpenLibrary("pdalink.library",2L))
      {
        if(param.backup)                  // BACKUP
          cmd_backup(param.dir);
        else if(param.restore)            // RESTORE
          cmd_restore(param.dir);
        else if(param.install)            // INSTALL
          cmd_install(param.file);
        else if(param.merge)              // MERGE
          cmd_merge(param.file);
        else if(param.fetch)              // FETCH
          cmd_fetch(param.name);
        else if(param.delete)             // DELETE
          cmd_delete(param.name);
        else if(param.list)               // LIST
          cmd_list();
        else if(param.purge)              // PURGE
          cmd_purge();
        else
          PutStr(helptxt);                // No command was given

        if(socket)
        {
          if(!ignoreError && (PL_LastError(socket)!=0))
            Printf("** Socket error: %s\n",getError(socket));
          Disconnect();
        }
        CloseLibrary(PdalinkBase);
      }
      else PutStr("** Couldn't open pdalink.library V2+\n");
      CloseLibrary(UtilityBase);
    }
    else PutStr("** Couldn't open utility.library V36+\n");

    FreeArgs(args);
  }
  else PutStr(helptxt);

  return(0);
}

/********************************************************************/
