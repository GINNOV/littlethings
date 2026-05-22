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
 * PRC/PDB File Access.
 *
 * @author Richard "Shred" Körber
 */

#include <string.h>
#include <utility/date.h>
#include "pdalink_glob.h"


#define TIME_DIFF (2335305600)    /* Seconds between 1.Jan.1978 and 1.Jan.1904 */

#define MKTAG(a,b,c,d)  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))

__saveds __asm int PL_FileClose(register __a0 APTR fh);


/*------------------------------------------------------**
** Name:        fileLen                          private
**
** Funktion:    Ermittelt die Länge einer Datei
**
** Parameter:   fh        Dateihandle
** Ergebnis:    len       Dateilänge oder -1: Fehler
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:45:19
*/
static LONG fileLen(BPTR fh)
{
  struct FileInfoBlock *fib;
  LONG size;

  if(fib = AllocVec(sizeof(struct FileInfoBlock),MEMF_PUBLIC))
  {
    if(ExamineFH(fh,fib))
    {
      size = fib->fib_Size;
      FreeVec(fib);
      return(size);
    }
    FreeVec(fib);
  }
  return(-1);
}
//<
/*------------------------------------------------------**
** Name:        unpackTime                       private
**
** Funktion:    Datei -> Palm-Zeit
**
** Parameter:   time      Sekunden seit 1.1.1904
**              tstr      auszufüllende DLP_SysTime
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:44:30
*/
static void unpackTime(ULONG time, struct DLP_SysTime *tstr)
{
  if(time==0 || time==TIME_DIFF)      // TIME_DIFF is a workaround to catch buggy
  {                                   // files made by palmlink below V1
    tstr->year   = 0;
    tstr->month  = 0;
    tstr->day    = 0;
    tstr->hour   = 0;
    tstr->minute = 0;
    tstr->second = 0;
    tstr->pad    = 0;
  }
  else
  {
    struct ClockData cld;
    Amiga2Date((time-TIME_DIFF),&cld);
    tstr->year   = cld.year;
    tstr->month  = cld.month;
    tstr->day    = cld.mday;
    tstr->hour   = cld.hour;
    tstr->minute = cld.min;
    tstr->second = cld.sec;
  }
}
//<
/*------------------------------------------------------**
** Name:        packTime                         private
**
** Funktion:    Datei <- Palm-Zeit
**
** Parameter:   tstr      DLP_SysTime
**              time      auszufüllende Sekunden seit 1.1.1904
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:44:30
*/
static void packTime(struct DLP_SysTime *tstr, ULONG *time)
{
  if(tstr->year==0)
  {
    *time = 0;
  }
  else
  {
    struct ClockData cld;
    cld.year  = tstr->year;
    cld.month = tstr->month;
    cld.mday  = tstr->day;
    cld.hour  = tstr->hour;
    cld.min   = tstr->minute;
    cld.sec   = tstr->second;
    *time = Date2Amiga(&cld) + TIME_DIFF;
  }
}
//<
/*------------------------------------------------------**
** Name:        createNewEntry                   private
**
** Funktion:    Erzeugt ein neues Entry und hängt an
**
** Parameter:   plfh      FileHandle
** Ergebnis:    entry     Neuer Entry
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 20:29:37
*/
static struct PL_Entry *createNewEntry(struct PL_File *plfh)
{
  struct PL_Entry *newentry = AllocVec(sizeof(struct PL_Entry),MEMF_PUBLIC|MEMF_CLEAR);
  if(!newentry) return(NULL);

  AddTail((struct List *)&plfh->entries, (struct Node *)newentry);
  plfh->cntEntries++;
  return(newentry);
}
//<
/*------------------------------------------------------**
** Name:        getEntry                         private
**
** Funktion:    Holt den Eintrag nach Index
**
** Parameter:   plfh      Filehandle
**              ix        Index
** Ergebnis:    entry     Eintrag oder NULL
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 20:43:43
*/
static struct PL_Entry *getEntry(struct PL_File *plfh, UWORD ix)
{
  struct PL_Entry *currEntry, *nextEntry;

  for
  (
    currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
    nextEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
    currEntry=nextEntry
  )
  {
    if(!(ix--)) return(currEntry);
  }
  return(NULL);
}
//<



/*------------------------------------------------------**
** Name:        PL_FileOpen                       public
**
** Funktion:    Öffnet eine Palm-Datei
**
** Parameter:   name      Dateiname
**              dbinfo    DBInfo (NULL: read, sonst write)
** Ergebnis:    fh        Filehandle
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 22:59:05
*/
__saveds __asm APTR PL_FileOpen
(
  register __a0 STRPTR name,
  register __a1 struct DLP_DBInfo *ndbinfo
)
{
  struct PL_File *plfh;

  if(!(plfh = AllocVec(sizeof(struct PL_File),MEMF_PUBLIC|MEMF_CLEAR))) return(NULL);   // NoMem
  NewList((struct List *)&plfh->entries);

  if(!ndbinfo)
  {
    /*---- OPEN FILE FOR READING -------------------------------------*/
    struct PL_FileHeader hdr;
    struct DLP_DBInfo *dbi = &plfh->dbinfo;
    struct PL_ResEntryHeader reseh;
    struct PL_RecEntryHeader receh;
    struct PL_Entry *currEntry, *predEntry;
    ULONG oldoffset;
    UWORD i;

    /* Open file */
    if(!(plfh->fh = Open(name,MODE_OLDFILE))) goto error;
    plfh->size = fileLen(plfh->fh);
    /* parse header */
    if(FRead(plfh->fh,&hdr,sizeof(struct PL_FileHeader),1) != 1) goto error;
    CopyMem(hdr.name,dbi->name,32);
    dbi->name[32] = '\0';
    dbi->flags              = hdr.flags;
    dbi->version            = hdr.version;
    unpackTime(hdr.creationTime,&dbi->createDate);
    unpackTime(hdr.modificationTime,&dbi->modifyDate);
    unpackTime(hdr.backupTime,&dbi->backupDate);
    dbi->modnum             = hdr.modificationNr;
    dbi->type               = hdr.type;
    dbi->creator            = hdr.creator;
    plfh->uniqueID          = hdr.uniqueID;
    plfh->nextRecordListID  = hdr.nextRecordListID;
    plfh->numRecords        = hdr.numRecords;
    if(plfh->nextRecordListID) goto error;       // Extended Format is not supported

#ifdef FILEDEBUG
  Printf("Entries: %ld\n",plfh->numRecords);
#endif

    if(dbi->flags & DLPDBIF_RESOURCE)
    {
      plfh->resourceFlag  = TRUE;
      plfh->entHeaderSize = sizeof(struct PL_ResEntryHeader);
    }
    else
    {
      plfh->resourceFlag  = FALSE;
      plfh->entHeaderSize = sizeof(struct PL_RecEntryHeader);
    }

    if(plfh->numRecords)                    // Entries are present?
    {
      for(i=0; i<plfh->numRecords; i++)
      {
        currEntry = createNewEntry(plfh);
        if(!currEntry) goto error;
        if(plfh->resourceFlag)
        {
          if(FRead(plfh->fh,&reseh,sizeof(struct PL_ResEntryHeader),1) != 1) goto error;
          currEntry->type    = reseh.type;
          currEntry->id      = reseh.id;
          currEntry->offset  = reseh.offset;
        }
        else
        {
          if(FRead(plfh->fh,&receh,sizeof(struct PL_RecEntryHeader),1) != 1) goto error;
          currEntry->offset  = receh.offset;
          currEntry->attrs   = receh.attrs;
          currEntry->uid     = (((ULONG)(receh.uid[0]))<<16) + (((ULONG)(receh.uid[1]))<<8) + ((ULONG)(receh.uid[2]));
        }
      }

      /* Get lengths */
      oldoffset = plfh->size;
      for
      (
        currEntry=(struct PL_Entry *)plfh->entries.mlh_TailPred;
        predEntry=(struct PL_Entry *)currEntry->node.mln_Pred;
        currEntry=predEntry
      )
      {
        currEntry->size = oldoffset - currEntry->offset;
        oldoffset = currEntry->offset;
      }

      if(hdr.sortInfoOffset)
      {
        plfh->sortInfoSize = oldoffset - hdr.sortInfoOffset;
        oldoffset = hdr.sortInfoOffset;
      }

      if(hdr.appInfoOffset)
      {
        plfh->appInfoSize = oldoffset - hdr.appInfoOffset;
        oldoffset = hdr.appInfoOffset;
      }

      /* Read AppInfo */
      if(plfh->appInfoSize)
      {
#ifdef FILEDEBUG
  Printf("AppInfo @0x%08lx (Size %ld)\n",hdr.appInfoOffset,plfh->appInfoSize);
#endif
        if(!(plfh->appInfo = AllocVec(plfh->appInfoSize,MEMF_PUBLIC))) goto error;
        Seek(plfh->fh,hdr.appInfoOffset,OFFSET_BEGINNING);  /** ERROR ? **/
        Flush(plfh->fh);
        if(FRead(plfh->fh,plfh->appInfo,plfh->appInfoSize,1) != 1) goto error;
      }
      else
      {
        plfh->appInfo = NULL;
      }

      /* Read SortInfo */
      if(plfh->sortInfoSize)
      {
#ifdef FILEDEBUG
  Printf("SortInfo @0x%08lx (Size %ld)\n",hdr.sortInfoOffset,plfh->sortInfoSize);
#endif
        if(!(plfh->sortInfo = AllocVec(plfh->sortInfoSize,MEMF_PUBLIC))) goto error;
        Seek(plfh->fh,hdr.sortInfoOffset,OFFSET_BEGINNING);  /** ERROR ? **/
        Flush(plfh->fh);
        if(FRead(plfh->fh,plfh->sortInfo,plfh->sortInfoSize,1) != 1) goto error;
      }
      else
      {
        plfh->sortInfo = NULL;
      }

      /* Read each entry */
      for
      (
        currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
        predEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
        currEntry=predEntry
      )
      {
#ifdef FILEDEBUG
  Printf("Entry @0x%08lx (Size %ld)\n",currEntry->offset,currEntry->size);
#endif
        if(!(currEntry->entryData = AllocVec(currEntry->size,MEMF_PUBLIC))) goto error;
        Seek(plfh->fh,currEntry->offset,OFFSET_BEGINNING);
        Flush(plfh->fh);
        if(FRead(plfh->fh,currEntry->entryData,currEntry->size,1) != 1) goto error;
#ifdef FILEDEBUG
  Printf("  Data %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",((ULONG*)currEntry->entryData)[0],((ULONG*)currEntry->entryData)[1],((ULONG*)currEntry->entryData)[2],((ULONG*)currEntry->entryData)[3],((ULONG*)currEntry->entryData)[4],((ULONG*)currEntry->entryData)[5],((ULONG*)currEntry->entryData)[6],((ULONG*)currEntry->entryData)[7]);
#endif
      }
    }

    return(plfh);
  }
  else
  {
    /*---- OPEN FILE FOR WRITING -------------------------------------*/
    if(!(plfh->filename = AllocVec(strlen(name)+1, MEMF_PUBLIC))) goto error;
    CopyMem(name,plfh->filename,strlen(name)+1);

    plfh->forWriteFlag = TRUE;
    CopyMem(ndbinfo,&plfh->dbinfo,sizeof(struct DLP_DBInfo));
    if(plfh->dbinfo.flags & DLPDBIF_RESOURCE)
    {
      plfh->resourceFlag  = TRUE;
      plfh->entHeaderSize = sizeof(struct PL_ResEntryHeader);
    }
    else
    {
      plfh->resourceFlag  = FALSE;
      plfh->entHeaderSize = sizeof(struct PL_RecEntryHeader);
    }

    return(plfh);
  }
error:

  plfh->forWriteFlag = FALSE;
  PL_FileClose(plfh);
  return(NULL);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileClose                      public
**
** Funktion:    Schließt eine Palm-Datei
**
** Parameter:   fh        Filehandle
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:46:17
*/
__saveds __asm int PL_FileClose
(
  register __a0 APTR fh
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *currEntry, *nextEntry;
  int res = TRUE;

  /* In write mode, write file */
  if(plfh->forWriteFlag)
  {
    struct PL_FileHeader fhdr = {0};
    struct DLP_DBInfo *dbi = &plfh->dbinfo;
    struct PL_RecEntryHeader receh;
    struct PL_ResEntryHeader reseh;
    ULONG offset;

    /* Open File */
    plfh->fh = Open(plfh->filename,MODE_NEWFILE);
    if(!plfh->fh) { res=FALSE; goto error; }

    offset = sizeof(struct PL_FileHeader) + plfh->cntEntries*plfh->entHeaderSize + 2;

    /* Fill header */
    strncpy(fhdr.name,dbi->name,32);
    fhdr.flags            = dbi->flags;
    fhdr.version          = dbi->version;
    packTime(&dbi->createDate,&fhdr.creationTime);
    packTime(&dbi->modifyDate,&fhdr.modificationTime);
    packTime(&dbi->backupDate,&fhdr.backupTime);
    fhdr.modificationNr   = dbi->modnum;
    fhdr.type             = dbi->type;
    fhdr.creator          = dbi->creator;
    fhdr.uniqueID         = plfh->uniqueID;
    fhdr.nextRecordListID = plfh->nextRecordListID;
    fhdr.numRecords       = plfh->cntEntries;

    if(plfh->appInfo)
    {
      fhdr.appInfoOffset  = offset;
      offset += plfh->appInfoSize;
    }
    if(plfh->sortInfo)
    {
      fhdr.sortInfoOffset = offset;
      offset += plfh->sortInfoSize;
    }

    if(FWrite(plfh->fh,&fhdr,sizeof(struct PL_FileHeader),1) != 1) {res=FALSE; goto error;}

    for
    (
      currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
      nextEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
      currEntry=nextEntry
    )
    {
      currEntry->offset = offset;
      if(plfh->resourceFlag)
      {
        reseh.type   = currEntry->type;
        reseh.id     = currEntry->id;
        reseh.offset = currEntry->offset;
        if(FWrite(plfh->fh,&reseh,sizeof(struct PL_ResEntryHeader),1) != 1) {res=FALSE; goto error;}
      }
      else
      {
        receh.offset = currEntry->offset;
        receh.attrs  = currEntry->attrs;
        receh.uid[0] = (currEntry->uid>>16) & 0xFF;
        receh.uid[1] = (currEntry->uid>>8) & 0xFF;
        receh.uid[2] = currEntry->uid & 0xFF;
        if(FWrite(plfh->fh,&receh,sizeof(struct PL_RecEntryHeader),1) != 1) {res=FALSE; goto error;}
      }
      offset += currEntry->size;
    }
    if(FWrite(plfh->fh,"\0\0",2,1) != 1) {res=FALSE; goto error;}

    if(plfh->appInfo)
      if(FWrite(plfh->fh,plfh->appInfo,plfh->appInfoSize,1) != 1) {res=FALSE; goto error;}

    if(plfh->sortInfo)
      if(FWrite(plfh->fh,plfh->sortInfo,plfh->sortInfoSize,1) != 1) {res=FALSE; goto error;}

    for
    (
      currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
      nextEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
      currEntry=nextEntry
    )
    {
      if(FWrite(plfh->fh,currEntry->entryData,currEntry->size,1) != 1) {res=FALSE; goto error;}
    }
  }

error:
  if(plfh->fh) Close(plfh->fh);                   // Close file

  /* Free all entries */
  for
  (
    currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
    nextEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
    currEntry=nextEntry
  )
  {
    if(currEntry->entryData) FreeVec(currEntry->entryData);
    Remove((struct Node *)currEntry);
    FreeVec(currEntry);
  }

  /* Free memory */
  if(plfh->appInfo)  FreeVec(plfh->appInfo);      // Free AppInfo
  if(plfh->sortInfo) FreeVec(plfh->sortInfo);     // Free SortInfo
  if(plfh->filename) FreeVec(plfh->filename);     // Copy file name

  FreeVec(plfh);                                  // Release handle itself
  return(res);                                    // Done!
}
//<

/*------------------------------------------------------**
** Name:        PL_FileGetDBInfo
**
** Funktion:    Holt sich die DBInfo
**
** Parameter:   fh        Filehandle
** Ergebnis:    dbinfo
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:57:20
*/
__saveds __asm struct DLP_DBInfo *PL_FileGetDBInfo
(
  register __a0 APTR fh
)
{
  return(&((struct PL_File *)fh)->dbinfo);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileSetDBInfo
**
** Funktion:    Setzt die DBInfo
**
** Parameter:   fh        Filehandle
**              dbinfo    Zu setzende DBInfo
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 19:30:39
*/
__saveds __asm int PL_FileSetDBInfo
(
  register __a0 APTR fh,
  register __a1 struct DLP_DBInfo *dbinfo
)
{
  struct PL_File *plfh = (struct PL_File *)fh;

  if(!plfh->forWriteFlag) return(FALSE);
  if((dbinfo->flags&DLPDBIF_RESOURCE) != (plfh->dbinfo.flags&DLPDBIF_RESOURCE)) return(FALSE);
  CopyMem(dbinfo,&plfh->dbinfo,sizeof(struct DLP_DBInfo));
  return(TRUE);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileGetAppInfo
**
** Funktion:    Holt sich Infos über die Application
**
** Parameter:   fh        Filehandle
**              size      Platz für die Größe
** Ergebnis:    appinfo
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:57:20
*/
__saveds __asm APTR PL_FileGetAppInfo
(
  register __a0 APTR fh,
  register __a1 ULONG *size
)
{
  struct PL_File *plfh = (struct PL_File *)fh;

  *size = plfh->appInfoSize;
  return(plfh->appInfo);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileSetAppInfo
**
** Funktion:    Setzt Infos über die Application
**
** Parameter:   fh        Filehandle
**              appinfo   Appinfo
**              size      Größe
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:57:20
*/
__saveds __asm int PL_FileSetAppInfo
(
  register __a0 APTR fh,
  register __a1 APTR appinfo,
  register __d0 ULONG size
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  APTR newappinfo;

  if(plfh->appInfo)
  {
    FreeVec(plfh->appInfo);
    plfh->appInfo = NULL;
    plfh->appInfoSize = 0;
  }

  if(!appinfo) return(TRUE);

  if(newappinfo = AllocVec(size,MEMF_PUBLIC))
  {
    plfh->appInfo = newappinfo;
    plfh->appInfoSize = size;
    CopyMem(appinfo,newappinfo,size);
    return(TRUE);
  }
  return(FALSE);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileGetSortInfo
**
** Funktion:    Holt sich Infos über das Sorting
**
** Parameter:   fh        Filehandle
**              size      Platz für die Größe
** Ergebnis:    sortinfo
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 19:00:39
*/
__saveds __asm APTR PL_FileGetSortInfo
(
  register __a0 APTR fh,
  register __a1 ULONG *size
)
{
  struct PL_File *plfh = (struct PL_File *)fh;

  *size = plfh->sortInfoSize;
  return(plfh->sortInfo);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileSetSortInfo
**
** Funktion:    Setzt Infos über Sorting
**
** Parameter:   fh        Filehandle
**              sortinfo  Sortinfo
**              size      Größe
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 18:57:20
*/
__saveds __asm int PL_FileSetSortInfo
(
  register __a0 APTR fh,
  register __a1 APTR sortinfo,
  register __d0 ULONG size
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  APTR newsortinfo;

  if(plfh->sortInfo)
  {
    FreeVec(plfh->sortInfo);
    plfh->sortInfo = NULL;
    plfh->sortInfoSize = 0;
  }

  if(!sortinfo) return(TRUE);

  if(newsortinfo = AllocVec(size,MEMF_PUBLIC))
  {
    plfh->sortInfo = newsortinfo;
    plfh->sortInfoSize = size;
    CopyMem(sortinfo,newsortinfo,size);
    return(TRUE);
  }
  return(FALSE);
}
//<

/*------------------------------------------------------**
** Name:        PL_FileReadResource
**
** Funktion:    Liest eine Resource
**
** Parameter:   fh        Filehandle
**              ix        Index
**              size      Platz für Größe
**              type      Platz für Typ
**              id        Platz für ID
** Ergebnis:    resource  Gewünschte Resource, NULL: Error
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 20:43:43
*/
__saveds __asm APTR PL_FileReadResource
(
  register __a0 APTR fh,
  register __d0 UWORD ix,
  register __a1 ULONG *size,
  register __a2 ULONG *type,
  register __a3 UWORD *id
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *ent;

  if(plfh->forWriteFlag || !plfh->resourceFlag) return(NULL);
  ent = getEntry(plfh,ix);
  if(!ent) return(NULL);

  if(size) *size = ent->size;
  if(type) *type = ent->type;
  if(id)   *id   = ent->id;
  return(ent->entryData);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileAddResource
**
** Funktion:    Fügt eine Resource hinzu
**
** Parameter:   fh        Filehandle
**              buffer    Daten für die Resource
**              size      Größe
**              type      Typ
**              id        ID
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 21:14:48
*/
__saveds __asm int PL_FileAddResource
(
  register __a0 APTR fh,
  register __a1 APTR buffer,
  register __d0 ULONG size,
  register __d1 ULONG type,
  register __d2 UWORD id
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *ent;
  APTR newbuf;

  if(!plfh->forWriteFlag || !plfh->resourceFlag) return(FALSE);
  if(newbuf = AllocVec(size,MEMF_PUBLIC))
  {
    if(ent = createNewEntry(plfh))
    {
      CopyMem(buffer,newbuf,size);
      ent->entryData = newbuf;
      ent->size      = size;
      ent->type      = type;
      ent->id        = id;
      return(TRUE);
    }
    FreeVec(newbuf);
  }
  return(FALSE);
}
//<

/*------------------------------------------------------**
** Name:        PL_FileReadRecord
**
** Funktion:    Liest einen Record
**
** Parameter:   fh        Filehandle
**              ix        Index
**              size      Platz für Größe
**              attr      Platz für Attribute
**              uid       Platz für UID
** Ergebnis:    resource  Gewünschte Resource, NULL: Error
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 20:43:43
*/
__saveds __asm APTR PL_FileReadRecord
(
  register __a0 APTR fh,
  register __d0 UWORD ix,
  register __a1 ULONG *size,
  register __a2 UBYTE *attr,
  register __a3 ULONG *uid
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *ent;

  if(plfh->forWriteFlag || plfh->resourceFlag) return(NULL);
  ent = getEntry(plfh,ix);
  if(!ent) return(NULL);

  if(size) *size = ent->size;
  if(attr) *attr = ent->attrs;
  if(uid)  *uid  = ent->uid;
  return(ent->entryData);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileReadRecordID
**
** Funktion:    Liest einen Record
**
** Parameter:   fh        Filehandle
**              uid       UID
**              size      Platz für Größe
**              attr      Platz für Attribute
**              ix        Platz für Index
** Ergebnis:    resource  Gewünschte Resource, NULL: Error
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 20:43:43
*/
__saveds __asm APTR PL_FileReadRecordID
(
  register __a0 APTR fh,
  register __d0 ULONG uid,
  register __a1 ULONG *size,
  register __a2 UBYTE *attr,
  register __a3 UWORD *ix
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *currEntry, *nextEntry;
  UWORD cix=0;

  for
  (
    currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
    nextEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
    currEntry=nextEntry
  )
  {
    if(currEntry->uid == uid)
    {
      if(ix) *ix = cix;
      return(PL_FileReadRecord(fh,cix,size,attr,NULL));
    }
    cix++;
  }
  return(NULL);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileAddRecord
**
** Funktion:    Fügt einen Record hinzu
**
** Parameter:   fh        Filehandle
**              buffer    Daten für die Resource
**              size      Größe
**              attr      Attribute
**              uid       Unique ID
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 21:14:48
*/
__saveds __asm int PL_FileAddRecord
(
  register __a0 APTR fh,
  register __a1 APTR buffer,
  register __d0 ULONG size,
  register __d1 UBYTE attr,
  register __d2 ULONG uid
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *ent;
  APTR newbuf;

  if(!plfh->forWriteFlag || plfh->resourceFlag) return(FALSE);
  if(newbuf = AllocVec(size,MEMF_PUBLIC))
  {
    if(ent = createNewEntry(plfh))
    {
      CopyMem(buffer,newbuf,size);
      ent->entryData = newbuf;
      ent->size      = size;
      ent->attrs     = attr;
      ent->uid       = uid;
      return(TRUE);
    }
    FreeVec(newbuf);
  }
  return(FALSE);
}
//<

/*------------------------------------------------------**
** Name:        PL_FileUsedID
**
** Funktion:    Testet, ob UID benutzt wird
**
** Parameter:   fh        Filehandle
**              uid       UID
** Ergebnis:    result    TRUE: wird benutzt
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 20:43:43
*/
__saveds __asm int PL_FileUsedID
(
  register __a0 APTR fh,
  register __d0 ULONG uid
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Entry *currEntry, *nextEntry;

  for
  (
    currEntry=(struct PL_Entry *)plfh->entries.mlh_Head;
    nextEntry=(struct PL_Entry *)currEntry->node.mln_Succ;
    currEntry=nextEntry
  )
  {
    if(currEntry->uid == uid) return(TRUE);
  }
  return(FALSE);
}
//<


/*------------------------------------------------------**
** Name:        PL_FileRetrieve
**
** Funktion:    Empfängt eine Datei vom Palm
**
** Parameter:   fh        Filehandle
**              socket    Socket
**              cardno    Karten-Nr
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 23:05:50
*/
__saveds __asm int PL_FileRetrieve
(
  register __a0 APTR fh,
  register __a1 APTR socket,
  register __d0 UBYTE cardno
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  APTR buffer;
  LONG dbh, length, entries;
  WORD i;
  ULONG type,uid;
  UWORD id,size;
  UBYTE attr,category;
  int res=FALSE;

  buffer = AllocVec(0x10000,MEMF_PUBLIC);
  if(buffer)
  {
    dbh = DLP_OpenDB(socket, cardno, DLPDBOF_READ|DLPDBOF_SECRET, plfh->dbinfo.name);
    if(dbh>=0)
    {
      length = DLP_ReadAppBlock(socket,dbh,0,buffer,0xFFFF);
      if(length>0)
      {
        PL_FileSetAppInfo(fh,buffer,length);
      }

      entries = DLP_CountDBEntries(socket,dbh);
      if(entries>=0)
      {
        if(plfh->resourceFlag)
        {
          /*--- Resource ---*/
          for(i=0; i<entries; i++)
          {
            if(DLP_ReadResourceByIndex(socket,dbh,i,buffer,&type,&id,&size) >= 0)
            {
              if(!PL_FileAddResource(fh,buffer,size,type,id)) goto error;
            }
          }
          res = TRUE;
        }
        else
        {
          /*--- Record ---*/
          for(i=0; i<entries; i++)
          {
            if(DLP_ReadRecordByIndex(socket,dbh,i,buffer,&uid,&size,&attr,&category) >= 0)
            {
              if(attr & (DLPDBAT_DELETED|DLPDBAT_ARCHIVE)) continue;  // Cannot be restored
              if(!PL_FileAddRecord(fh,buffer,size,((attr&0xF0) | (category&0x0F)),uid)) goto error;
            }
          }
          res = TRUE;
        }
      }
error:
      DLP_CloseDB(socket,dbh);
    }
    FreeVec(buffer);
  }
  return(res);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileInstall
**
** Funktion:    Sendet eine Datei zum Palm
**
** Parameter:   fh        Filehandle
**              socket    Socket
**              cardno    Karten-Nr
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 23:05:50
*/
__saveds __asm int PL_FileInstall
(
  register __a0 APTR fh,
  register __a1 APTR socket,
  register __d0 UBYTE cardno
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  int  res = FALSE;
  BOOL reset = FALSE;
  LONG dbh;
  UWORD tmpflags, id;
  APTR appinfo, appinfo2=NULL, buffer;
  ULONG size,type,uid;
  UBYTE attr;
  WORD i;

  /* Remove old entry */
#ifdef FILEDEBUG
  Printf("DeleteDB %ld\n",plfh->dbinfo.name);
#endif
  DLP_DeleteDB(socket,cardno,plfh->dbinfo.name);

	 /* Judd - 25Nov99 - Graffiti hack We want to make sure that these 2
	    flags get set for this one */

  if(plfh->dbinfo.creator == MKTAG('g', 'r', 'a', 'f'))
  {
    tmpflags |= DLPDBIF_NEWER|DLPDBIF_RESET;
  }

  /* Calculate the flags */
  tmpflags = plfh->dbinfo.flags;
  if(strcmp(plfh->dbinfo.name,"Graffiti ShortCuts")==0)
  {
    tmpflags |= DLPDBIF_OPEN;   // A file that is already opened, will be changed
    reset = TRUE;               // Just to make sure...
  }

#ifdef FILEDEBUG
  Printf("CreateDB %ld\n",plfh->dbinfo.name);
#endif
  dbh = DLP_CreateDB(socket,cardno,plfh->dbinfo.creator,plfh->dbinfo.type,tmpflags,plfh->dbinfo.version,plfh->dbinfo.name);
  if(dbh>=0)
  {
    appinfo = PL_FileGetAppInfo(fh,&size);
#ifdef FILEDEBUG
  Printf("GetAppInfo 0x%08lx\n",appinfo);
#endif
    /* Workaround for a bug in PalmOS 2.0 */
    if((sock->version>0x0100) && (strcmp(plfh->dbinfo.name,"MemoDB")==0) && (size>0) && (size<282))
    {
      if(appinfo2 = AllocVec(282,MEMF_PUBLIC))
      {
        CopyMem(appinfo,appinfo2,size);
        appinfo = appinfo2;
        size = 282;
      }
    }

    if(plfh->dbinfo.creator == MKTAG('p','t','c','h')) reset = TRUE;
    if(plfh->dbinfo.flags & DLPDBIF_RESET) reset = TRUE;

#ifdef FILEDEBUG
  Printf("WriteAppBlock 0x%08lx\n",appinfo);
#endif
    if(size>0) DLP_WriteAppBlock(socket,dbh,appinfo,size);

    if(plfh->dbinfo.flags & DLPDBIF_RESOURCE)
    {
      /*--- INSTALL RESOURCE ---*/
      for(i=0; i<plfh->cntEntries; i++)
      {
        buffer = PL_FileReadResource(fh,i,&size,&type,&id);
#ifdef FILEDEBUG
  Printf("ReadResource 0x%08lx\n",buffer);
#endif
        if(!buffer || size>65535) goto error;                               // ERROR: No Resource, or >64K
#ifdef FILEDEBUG
  Printf("WriteResource 0x%08lx\n",buffer);
#endif
        if(!DLP_WriteResource(socket,dbh,type,id,buffer,size)) goto error;  // Failure
        if(type == MKTAG('b','o','o','t')) reset = TRUE;
      }
      res = TRUE;
    }
    else
    {
      /*--- INSTALL RECORD ---*/
      for(i=0; i<plfh->cntEntries; i++)
      {
        buffer = PL_FileReadRecord(fh,i,&size,&attr,&uid);
#ifdef FILEDEBUG
  Printf("ReadRecord 0x%08lx\n",buffer);
#endif
        if(!buffer || size>65535) goto error;                               // ERROR: No Record, or >64K
        if((attr&DLPDBAT_DELETED) && (sock->version<0x0101)) continue;      // PalmOS1 cannot install deleted entries
#ifdef FILEDEBUG
  Printf("WriteRecord 0x%08lx\n",buffer);
#endif
        if(!DLP_WriteRecord(socket,dbh,attr&0xF0,uid,attr&0x0F,buffer,size,NULL)) goto error;  // Failure
      }
      res = TRUE;
    }

error:
    if(reset) DLP_ResetSystem(socket);
#ifdef FILEDEBUG
  Printf("CloseDB\n",buffer);
#endif
    DLP_CloseDB(socket,dbh);
    if(!res) DLP_DeleteDB(socket,cardno,plfh->dbinfo.name);   // Remove faulty entry
  }

  if(appinfo2) FreeVec(appinfo2);
  return(res);
}
//<
/*------------------------------------------------------**
** Name:        PL_FileMerge
**
** Funktion:    Verbindet eine Datei mit einer Palm-Datenbank
**
** Parameter:   fh        Filehandle
**              socket    Socket
**              cardno    Karten-Nr
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    14. Juni 1998, 23:05:50
*/
__saveds __asm int PL_FileMerge
(
  register __a0 APTR fh,
  register __a1 APTR socket,
  register __d0 UBYTE cardno
)
{
  struct PL_File *plfh = (struct PL_File *)fh;
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  int  res = FALSE;
  BOOL reset = FALSE;
  LONG dbh;
  UWORD id;
  APTR  buffer;
  ULONG size,type,uid;
  UBYTE attr;
  WORD  i;

  dbh = DLP_OpenDB(socket,cardno, DLPDBOF_READWRITE|DLPDBOF_SECRET, plfh->dbinfo.name);
  if(dbh<0) return(PL_FileInstall(fh,socket,cardno));   // Just install

  if(plfh->dbinfo.creator == MKTAG('p','t','c','h')) reset=TRUE;
  if(plfh->dbinfo.flags & DLPDBIF_RESET) reset = TRUE;

  if(plfh->dbinfo.flags & DLPDBIF_RESOURCE)
  {
    /*--- INSTALL RESOURCE ---*/
    for(i=0; i<plfh->cntEntries; i++)
    {
      buffer = PL_FileReadResource(fh,i,&size,&type,&id);
      if(!buffer || size>65535) goto error;                               // ERROR: No Resource, or >64K
      if(!DLP_WriteResource(socket,dbh,type,id,buffer,size)) goto error;  // Failure
      if(type == MKTAG('b','o','o','t')) reset = TRUE;
    }
    res = TRUE;
  }
  else
  {
    /*--- INSTALL RECORD ---*/
    for(i=0; i<plfh->cntEntries; i++)
    {
      buffer = PL_FileReadRecord(fh,i,&size,&attr,&uid);
      if(!buffer || size>65535) goto error;                               // ERROR: No Record, or >64K
      if((attr&DLPDBAT_DELETED) && (sock->version<0x0101)) continue;      // PalmOS1 cannot install deleted entries
      if(!DLP_WriteRecord(socket,dbh,attr&0xF0,uid,attr&0x0F,buffer,size,NULL)) goto error;  // Failure
    }
    res = TRUE;
  }

error:
  if(reset) DLP_ResetSystem(socket);
  DLP_CloseDB(socket,dbh);
  return(res);
}
//<



/********************************************************************/
