#include <exec/execbase.h>
#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <pragmas/exec_sysbase_pragmas.h>

#include "libraries/PicassoIVresource.h"

LONG __saveds
main(VOID)
{
	struct ExecBase *SysBase;
	struct P4Resource *p4r;

	SysBase = *(struct ExecBase **)4;

	if(p4r = (struct P4Resource *)OpenResource(PICASSOIVRESNAME))
	{
		static UWORD pal[] = { (109<<8)|(26<<1),760,776,880,920,603,604,606,625 };
		static UWORD ntsc[] = { (89<<8)|(27<<1),760,776,880,920,489,496,500,525 };

		struct P4Timing *timing;

		if(timing = (struct P4Timing *)AllocMem(sizeof(*timing),MEMF_ANY))
		{
			CopyMem(p4r->p4res_PALTiming,timing,sizeof(*timing));
			CopyMem(pal,timing,sizeof(pal));

			p4r->p4res_PALTiming = timing;
		}

		if(timing = (struct P4Timing *)AllocMem(sizeof(*timing),MEMF_ANY))
		{
			CopyMem(p4r->p4res_NTSCTiming,timing,sizeof(*timing));
			CopyMem(ntsc,timing,sizeof(ntsc));

			p4r->p4res_NTSCTiming = timing;
		}
	}

	return(0);
}
