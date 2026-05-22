#ifndef XADMASTER_CPIO_C
#define XADMASTER_CPIO_C

/* Programmheader

	Name:		Cpio.c
	Main:		xadmaster
	Versionstring:	$VER: Cpio.c 1.3 (20.04.2001)
	Author:		SDI, Stefan Haubenthal
	Distribution:	Freeware
	Description:	Cpio file archiver client

 1.3   20.04.01 : dummy CRC added
 1.2   22.08.00 : optimised
 1.1   11.08.00 : bug fixes
 1.0   28.07.00 : first version
*/

#include <proto/xadmaster.h>
#include <dos/dos.h>
#include <exec/memory.h>
#include "SDI_compiler.h"
#define SDI_TO_ANSI
#include "SDI_ASM_STD_protos.h"

#ifndef XADMASTERFILE
#define Cpio_Client		FirstClient
#define NEXTCLIENT		0
UBYTE version[] = "$VER: Cpio 1.3 (20.04.2001) \251 Stefan Haubenthal";
#endif
#define CPIO_VERSION		1
#define CPIO_REVISION		3

struct CpioHeader
{				/* byte offset */
  UBYTE ch_Magic[6];		/*   0 */
  UBYTE ch_INode[8];		/*   6 */
  UBYTE ch_Mode[8];		/*  14 */
  UBYTE ch_UserID[8];		/*  22 */
  UBYTE ch_GroupID[8];		/*  30 */
  UBYTE ch_LinkName[8];		/*  38 */
  UBYTE ch_MTime[8];		/*  46 */
  UBYTE ch_Size[8];		/*  54 */
  UBYTE ch_DevMajor[8]; 	/*  62 */
  UBYTE ch_DevMinor[8]; 	/*  70 */
  UBYTE ch_RDevMajor[8]; 	/*  78 */
  UBYTE ch_RDevMinor[8]; 	/*  86 */
  UBYTE ch_NameSize[8];		/*  94 */
  UBYTE ch_Checksum[8]; 	/* 102 */
};

/* Values used in Mode field.  */
#define	S_ISDIR(m)	((m & 0170000) == 0040000)	/* directory */
#define	S_ISCHR(m)	((m & 0170000) == 0020000)	/* char special */
#define	S_ISBLK(m)	((m & 0170000) == 0060000)	/* block special */
#define	S_ISREG(m)	((m & 0170000) == 0100000)	/* regular file */
#define	S_ISLNK(m)	((m & 0170000) == 0120000)	/* symbolic link */
#define	S_ISFIFO(m)	((m & 0170000) == 0010000)	/* fifo */
#define	S_ISSOCK(m)	((m & 0170000) == 0140000)	/* socket */

static ULONG hextonum(STRPTR hex, LONG *ok)
{
  ULONG i = 0;
  LONG width=8;

  while(width-- && *hex == ' ')
    ++hex;

  if(!*hex)
    *ok = 0;
  else
  {
    while(1+width-- && isxdigit(*hex))
     i = isdigit(*hex) ? (i*16)+*(hex++)-'0' : (i*16)+*(hex++)-'a'+10;

    if(width > 0 && *hex)	/* an error, set error flag */
      *ok = 0;
  }

  return i;
}

ASM(BOOL) Cpio_RecogData(REG(d0, ULONG size), REG(a0, STRPTR data),
REG(a6, struct xadMasterBase *xadMasterBase))
{
  if(!strncmp(data, "070701", 6)  /* ASCII cpio archive (SVR4 with no CRC) */
  || !strncmp(data, "070702", 6)) /* ASCII cpio archive (SVR4 with CRC) */
    return 1;
  else
    return 0;
}

ASM(LONG) Cpio_GetInfo(REG(a0, struct xadArchiveInfo *ai),
REG(a6, struct xadMasterBase *xadMasterBase))
{
  struct CpioHeader ch;
  struct xadFileInfo *fi = 0, *fi2;
  LONG err = 0, size, ok, a, b, type, pos, num = 1;
  STRPTR ch_Name;		/* 110 */

  while(!err && ai->xai_InPos+sizeof(struct CpioHeader) < ai->xai_InSize &&
  !(err = xadHookAccess(XADAC_READ, sizeof(struct CpioHeader), &ch, ai)))
  {
    a = hextonum(ch.ch_NameSize, &ok);

    if(!(ch_Name = (STRPTR) xadAllocVec(a+3, MEMF_ANY|MEMF_CLEAR)))
      err = XADERR_NOMEMORY;
    else
      err = xadHookAccess(XADAC_READ, ((2+a+3)&(~3))-2, ch_Name, ai);
    if(ch_Name && strcmp(ch_Name, "TRAILER!!!"))
    {
      size = hextonum(ch.ch_Size, &ok);
      pos = ai->xai_InPos;
      type = hextonum(ch.ch_Mode, &ok);
      if(ok && S_ISREG(type) && (err = xadHookAccess(XADAC_INPUTSEEK, (size+3)&(~3), 0, ai)))
        ;
      else if(ok && (S_ISREG(type) || S_ISDIR(type) || S_ISLNK(type)))
      {
        b = S_ISLNK(type) ? size+4 : 0; /* +4 == 1 ZERO-Byte + max 3 pad bytes */
      
        if(!(fi2 = (struct xadFileInfo *) xadAllocObject(XADOBJ_FILEINFO,
        XAD_OBJNAMESIZE, a+b, TAG_DONE)))
          err = XADERR_NOMEMORY;
        else
        {
          fi2->xfi_DataPos = pos;
          fi2->xfi_Flags = XADFIF_SEEKDATAPOS;
	  if(S_ISLNK(type))
	  {
	    fi2->xfi_Flags |= XADFIF_LINK;
            fi2->xfi_LinkName = fi2->xfi_FileName + a;
            err = xadHookAccess(XADAC_READ, (size+3)&(~3), fi2->xfi_LinkName, ai);
	  }
	  else if(S_ISDIR(type))
	    fi2->xfi_Flags |= XADFIF_DIRECTORY;
	  else
            fi2->xfi_CrunchSize = fi2->xfi_Size = size;

          xadCopyMem(ch_Name, fi2->xfi_FileName, a);
          fi2->xfi_OwnerUID = hextonum(ch.ch_UserID, &ok);
          fi2->xfi_OwnerGID = hextonum(ch.ch_GroupID, &ok);

          xadConvertProtection(XAD_PROTUNIX, hextonum(ch.ch_Mode, &ok), XAD_GETPROTAMIGA,
          &fi2->xfi_Protection, TAG_DONE);

          xadConvertDates(XAD_DATEUNIX, hextonum(ch.ch_MTime, &ok),
          XAD_MAKELOCALDATE, 1, XAD_GETDATEXADDATE, &fi2->xfi_Date, TAG_DONE);

	  fi2->xfi_EntryNumber = num++;
          if(fi)
            fi->xfi_Next = fi2;
          else
            ai->xai_FileInfo = fi2;
          fi = fi2;
        }
      }
    }
    if(ch_Name)
      xadFreeObjectA(ch_Name, 0);
  }

  if(err)
  {
    ai->xai_Flags |= XADAIF_FILECORRUPT;
    ai->xai_LastError = err;
  }

  return (ai->xai_FileInfo ? 0 : err);
}

ASM(LONG) Cpio_UnArchive(REG(a0, struct xadArchiveInfo *ai),
REG(a6, struct xadMasterBase *xadMasterBase))
{
  return xadHookAccess(XADAC_COPY, ai->xai_CurFile->xfi_Size, 0, ai);
}

const struct xadClient Cpio_Client = {
NEXTCLIENT, XADCLIENT_VERSION, 4, CPIO_VERSION, CPIO_REVISION,
6, XADCF_FILEARCHIVER|XADCF_FREEFILEINFO, 0, "Cpio",
(BOOL (*)()) Cpio_RecogData, (LONG (*)()) Cpio_GetInfo,
(LONG (*)()) Cpio_UnArchive, 0};

#endif /* XADASTER_CPIO_C */
