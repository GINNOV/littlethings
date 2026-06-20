#ifndef XADMASTER_XADXPK_C
#define XADMASTER_XADXPK_C

/* Programmheader

	Name:		xadXPK.c
	Main:		xadmaster
	Versionstring:	$VER: xadXPK.c 1.4 (03.12.2000)
	Author:		SDI, Kyzer
	Distribution:	Freeware
	Description:	xpk decrunch handling

 1.0   14.06.98 : first version
 1.1   10.08.98 : completed xpkDecrunch
 1.2   20.06.99 : removed AllocMem calls
 1.3   16.03.00 : renamed from xpkstuff.c
 1.4   03.12.00 : changed tag calls to normal calls
*/

#include <proto/xpkmaster.h>
#include <proto/xadmaster.h>
#include <proto/exec.h>
#include <exec/memory.h>

static LONG GetXpkError(LONG err)
{
  LONG ret;

  switch(err)
  {
    case XPKERR_OK:		ret = XADERR_OK; break;
    case XPKERR_IOERRIN:	ret = XADERR_INPUT; break;
    case XPKERR_IOERROUT:	ret = XADERR_OUTPUT; break;
    case XPKERR_CORRUPTPKD:
    case XPKERR_TRUNCATED:	ret = XADERR_ILLEGALDATA; break;
    case XPKERR_NOMEM:		ret = XADERR_NOMEMORY; break;
    case XPKERR_WRONGCPU:
    case XPKERR_MISSINGLIB:
    case XPKERR_VERSION:
    case XPKERR_OLDMASTLIB:
    case XPKERR_OLDSUBLIB:
    case XPKERR_NOHARDWARE:
    case XPKERR_BADHARDWARE:	ret = XADERR_RESOURCE; break;
    case XPKERR_NEEDPASSWD:
    case XPKERR_WRONGPW:	ret = XADERR_PASSWORD; break;
    default:			ret = XADERR_DECRUNCH; break;
  };
  return ret;
}

/* reads XPKF file from current input stream and stores a pointer to
decrunched file in *str and the size in *size */
static LONG xpkDecrunch(STRPTR *str, ULONG *size, struct xadArchiveInfo *ai,
struct xadMasterBase *xadMasterBase)
{
  struct Library *XpkBase;
  struct ExecBase * SysBase = xadMasterBase->xmb_SysBase;
  ULONG buf[2];
  LONG err;
  ULONG *mem;
  struct TagItem tags[8];
  
  if((XpkBase = OpenLibrary("xpkmaster.library", 4)))
  {
    if(!(err = xadHookAccess(XADAC_READ, 8, buf, ai)))
    {
      if((mem = xadAllocVec(buf[1]+8, MEMF_PUBLIC)))
      {
        if(!(err = xadHookAccess(XADAC_READ, buf[1], mem+2, ai)))
        {
          struct XpkFib xfib;

          mem[0] = buf[0];
          mem[1] = buf[1];

          tags[0].ti_Tag  = XPK_InBuf;
          tags[0].ti_Data = (ULONG) mem;
          tags[1].ti_Tag  = XPK_InLen;
          tags[1].ti_Data = (ULONG) buf[1]+8;
          tags[2].ti_Tag  = TAG_DONE;
          if(!XpkExamine(&xfib, tags))
          {
            STRPTR mem2;

	    if((mem2 = (STRPTR) xadAllocVec(xfib.xf_ULen+XPK_MARGIN,
	    MEMF_PUBLIC|MEMF_CLEAR)))
	    {
	      *str = mem2;
	      *size = xfib.xf_ULen;

              tags[2].ti_Tag  = XPK_OutBuf;
              tags[2].ti_Data = (ULONG) mem2;
              tags[3].ti_Tag  = XPK_OutBufLen;
              tags[3].ti_Data = (ULONG) *size + XPK_MARGIN;
              tags[4].ti_Tag  = ai->xai_Password ? XPK_Password : TAG_IGNORE;
              tags[4].ti_Data = (ULONG) ai->xai_Password;
              tags[5].ti_Tag  = XPK_UseXfdMaster;
              tags[5].ti_Data = 0;
              tags[6].ti_Tag  = XPK_PassRequest;
              tags[6].ti_Data = FALSE;
              tags[7].ti_Tag  = TAG_DONE;
              if((err = GetXpkError(XpkUnpack(tags))))
              {
                xadFreeObjectA(mem2, 0); *str = 0; *size = 0;
              }
            }
          }
          else
            err = XADERR_ILLEGALDATA;
        }  
        xadFreeObjectA(mem, 0);
      } /* xadAllocVec */
      else
        err = XADERR_NOMEMORY;
    } /* Hook Read */
    CloseLibrary(XpkBase);
  } /* OpenLibrary */
  else
    err = XADERR_RESOURCE;

  return err;
}

#endif /* XADMASTER_XADXPK_C */
