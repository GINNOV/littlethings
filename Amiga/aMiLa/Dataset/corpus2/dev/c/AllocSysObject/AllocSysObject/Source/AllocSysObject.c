/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <proto/exec.h>
#include <proto/utility.h>

#include "include/exec/exectags.h"

#define MEMF_MASK	(MEMF_CLEAR|MEMF_LARGEST|MEMF_REVERSE|MEMF_TOTAL|MEMF_NO_EXPUNGE)

#define PROTO(x)        OS4_ ## x
#define EMUCALL(x,y)    static x y
#define EMUCALL68K(x,y) EMUCALL(x,y) __attribute__((varargs68k)); EMUCALL(x, y)
#define RC_START(x)     x rc;
#define RC_END          return rc;
#define NR_START
#define NR_END

#if DEBUG_EXEC
# define kprintf(fmt, tags...)	({ULONG _tags[] = { 0 , ## tags }; RawDoFmt(fmt, (APTR)&_tags[1], (void (*)(void))1, NULL);})
# define  bug	kprintf
# define	D(x)	x
#else
# define  bug
# define	D(x)
#endif

/**********************************************************************
	Alloc/FreeSysObject
**********************************************************************/

STATIC APTR AllocObj(struct ExecIFace *Self, ULONG size, ULONG no_tracking)
{
	ULONG *obj;

	size += 4;

	if (no_tracking)
	{
		obj = AllocVec(size, MEMF_ANY|MEMF_CLEAR);
	}
	else
	{
		obj = AllocVecTaskPooled(size);

		if (obj)
		{
			memset(obj, 0, size);
		}
	}

	if (obj)
	{
		*obj++ = no_tracking;
	}

	return obj;
}

STATIC VOID FreeObj(struct ExecIFace *Self, APTR obj)
{
	ULONG *p = obj;

	if (obj)
	{
		p--;

		if (*p)
		{
			FreeVec(p);
		}
		else
		{
			FreeVecTaskPooled(p);
		}
	}
}

EMUCALL(APTR, PROTO(AllocSysObject(struct ExecIFace *Self, ULONG type, struct TagItem *tags)))
{
	RC_START(APTR)
	struct TagItem	*tstate, *tag;
	LONG notrack;

	notrack = 0;	// Should default to TRUE
	rc = NULL;

	#if DEBUG_EXEC
	{
		CONST_STRPTR typename;

		switch (type)
		{
			case ASOT_IOREQUEST	: typename	= "ASOT_IOREQUEST"; break;
			case ASOT_HOOK			: typename	= "ASOT_HOOK"; break;
			case ASOT_INTERRUPT	: typename	= "ASOT_INTERRUPT"; break;
			case ASOT_LIST			: typename	= "ASOT_LIST"; break;
			case ASOT_DMAENTRY	: typename	= "ASOT_DMAENTRY"; break;
			case ASOT_NODE			: typename	= "ASOT_NODE"; break;
			case ASOT_PORT			: typename	= "ASOT_PORT"; break;
			case ASOT_MESSAGE		: typename	= "ASOT_MESSAGE"; break;
			case ASOT_SEMAPHORE	: typename	= "ASOT_SEMAPHORE"; break;
			case ASOT_TAGLIST		: typename	= "ASOT_TAGLIST"; break;
			case ASOT_MEMPOOL		: typename	= "ASOT_MEMPOOL"; break;
			case ASOT_ITEMPOOL	: typename	= "ASOT_ITEMPOOL"; break;
			default					: typename	= "ASOT_???"; break;
		}

		D(bug("ExecIFace: AllocSysObject(%s) (%ld)\n", (IPTR)typename, type));
	}
	#endif

	tstate	= tags;

	tag = FindTagItem(ASO_NoTrack, tags);

	if (tag && tag->ti_Data)
	{
		D(bug("ASO_NoTrack set!\n"));
		notrack = 1;
	}

	switch (type)
	{
		case ASOT_IOREQUEST	:
		{
			ULONG size = sizeof(struct IORequest);
			APTR port = NULL;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOIOR_Size			: size = tag->ti_Data; break;
						case ASOIOR_ReplyPort	: port = (APTR)tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, size, notrack);

			if (rc)
			{
				((struct IORequest *)rc)->io_Message.mn_ReplyPort	= port;
				((struct IORequest *)rc)->io_Message.mn_Length		= size;
			}

			break;
		}

		case ASOT_INTERRUPT	:
		{
			ULONG	size	= sizeof(struct Interrupt);
			APTR code = NULL, data = NULL;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOINTR_Size	: size = tag->ti_Data; break;
						case ASOINTR_Code	: code = (APTR)tag->ti_Data; break;
						case ASOINTR_Data	: data = (APTR)tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, size, notrack);

			if (rc)
			{
				((struct Interrupt *)rc)->is_Data = data;
				((struct Interrupt *)rc)->is_Code = code;
			}

			break;
		}

		case ASOT_HOOK			:
		{
			APTR entry = NULL, subentry = NULL, data = NULL;
			ULONG size = sizeof(struct Hook);

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOHOOK_Size			: size = tag->ti_Data; break;
						case ASOHOOK_Entry		: entry = (APTR)tag->ti_Data; break;
						case ASOHOOK_Subentry	: subentry = (APTR)tag->ti_Data; break;
						case ASOHOOK_Data			: data = (APTR)tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, size, notrack);

			if (rc)
			{
				((struct Hook *)rc)->h_Entry		= entry;
				((struct Hook *)rc)->h_SubEntry	= subentry;
				((struct Hook *)rc)->h_Data		= data;
			}

			break;
		}

		case ASOT_LIST			:
		{
			ULONG size = sizeof(struct List), min = 0, type = 0;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOLIST_Size		: size = tag->ti_Data; break;
						case ASOLIST_Type		: type = tag->ti_Data; break;
						case ASOLIST_Min		: min = tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, size, notrack);

			if (rc)
			{
				NEWLIST(rc);

				if (!min)
					((struct List *)rc)->lh_Type	= type;
			}

			break;
		}

		case ASOT_DMAENTRY	:
			break;

		case ASOT_NODE			:
		{
			STRPTR name = NULL;
			ULONG size  = sizeof(struct Node), min = 0, type = 0, pri = 0;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASONODE_Size		: size = tag->ti_Data; break;
						case ASONODE_Min		: min = tag->ti_Data; break;
						case ASONODE_Type		: type = tag->ti_Data; break;
						case ASONODE_Pri		: pri = tag->ti_Data; break;
						case ASONODE_Name		: name = (STRPTR)tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, size, notrack);

			if (rc && !min)
			{
				((struct Node *)rc)->ln_Type	= type;
				((struct Node *)rc)->ln_Pri	= pri;
				((struct Node *)rc)->ln_Name	= name;
			}

			break;
		}

		case ASOT_PORT			:
		{
			STRPTR name = NULL;
			ULONG size  = sizeof(struct MsgPort), action = 0, pri = 0, allocsig = 1;
			LONG signum = -1, target = 0, public = 0, copy = 0, namelen = 0;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOPORT_Size			: size = tag->ti_Data; break;
						case ASOPORT_AllocSig	: allocsig = tag->ti_Data; break;
						case ASOPORT_Action		: action = tag->ti_Data; break;
						case ASOPORT_Pri			: pri = tag->ti_Data; break;
						case ASOPORT_Name			: name = (STRPTR)tag->ti_Data; break;
						case ASOPORT_Signal		: signum = tag->ti_Data; break;
						case ASOPORT_Target		: target = tag->ti_Data; break;
						case ASOPORT_Public		: public = tag->ti_Data; break;
						case ASOPORT_CopyName	: copy = tag->ti_Data; break;
					}
				}
			}

			if (copy && name)
			{
				namelen = strlen(name) + 1;
			}

			size += 4;

			rc	= AllocObj(Self, size + namelen, notrack);

			if (rc)
			{
				struct MsgPort *port;

				*(LONG *)rc = -1;

				if (signum == -1 || allocsig)
				{
					signum = AllocSignal(signum);

					if (signum < 0)
					{
						FreeObj(Self, rc);
						rc	= NULL;
						goto done;
					}	

					*(LONG *)rc = signum;
				}

				port = (APTR)((ULONG)rc + 4);

				port->mp_SigTask	= target ? (struct Task *)target : FindTask(NULL);

				NEWLIST(&port->mp_MsgList);

				if (namelen)
				{
					UBYTE *tmp = rc;

					strcpy(&tmp[size], name);
					name = &tmp[size];
				}

				port->mp_Node.ln_Name = name;
				port->mp_Node.ln_Pri  = pri;
				port->mp_Node.ln_Type = NT_MSGPORT;
				port->mp_Flags        = action;
				port->mp_SigBit       = signum;

				if (public)
					AddPort(port);
			}

			break;
		}

		case ASOT_MESSAGE		:
		{
			STRPTR name = NULL;
			ULONG size = sizeof(struct Message);
			APTR port = NULL;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOMSG_Size			: size = tag->ti_Data; break;
						case ASOMSG_ReplyPort	: port = (APTR)tag->ti_Data; break;
						case ASOMSG_Length		: size = tag->ti_Data; break;
						case ASOMSG_Name			: name = (STRPTR)tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, size, notrack);

			if (rc)
			{
				((struct Message *)rc)->mn_Node.ln_Type	= NT_MESSAGE;
				((struct Message *)rc)->mn_ReplyPort		= port;
				((struct Message *)rc)->mn_Length			= size;
			}

			break;
		}

		case ASOT_SEMAPHORE	:
		{
			ULONG pri = 0, public = 0, size = sizeof(struct SignalSemaphore);
			ULONG copy = 0, namelen = 0;
			STRPTR name	= NULL;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOSEM_Size		: size = tag->ti_Data; break;
						case ASOSEM_Name		: name = (STRPTR)tag->ti_Data; break;
						case ASOSEM_Pri		: pri = tag->ti_Data; break;
						case ASOSEM_Public	: public = tag->ti_Data; break;
						case ASOSEM_CopyName	: copy = tag->ti_Data; break;
					}
				}
			}

			if (copy && name)
			{
				namelen = strlen(name) + 1;
			}

			rc	= AllocObj(Self, size + namelen, notrack);

			if (rc)
			{
				InitSemaphore(rc);

				if (namelen)
				{
					UBYTE *tmp = rc;

					strcpy(&tmp[size], name);
					name = &tmp[size];
				}

				((struct SignalSemaphore *)rc)->ss_Link.ln_Pri  = pri;
				((struct SignalSemaphore *)rc)->ss_Link.ln_Name = name;

				if (public && name)
					AddSemaphore(rc);
			}

			break;
		}

		case ASOT_TAGLIST		:
		{
			ULONG entries = 0;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOTAGS_NumEntries		: entries = tag->ti_Data; break;
					}
				}
			}

			rc	= AllocObj(Self, entries * sizeof(struct TagItem), notrack);
			break;
		}

		case ASOT_MEMPOOL		:
		{
			ULONG flags = MEMF_ANY, puddle = 8192, tresh = 8000;

			if (tags)
			{
				while ((tag = NextTagItem(&tstate)))
				{
					switch (tag->ti_Tag)
					{
						case ASOPOOL_MFlags		: flags = tag->ti_Data & MEMF_MASK; break;
						case ASOPOOL_Puddle		: puddle = tag->ti_Data; break;
						case ASOPOOL_Threshold	: tresh = tag->ti_Data; break;
					}
				}

				if (tresh > puddle)
					puddle = tresh;
			}

			rc	= CreatePool(flags, puddle, tresh);
			break;
		}

		case ASOT_ITEMPOOL	:
			break;
	}

done:
	RC_END
}

EMUCALL68K(APTR, PROTO(AllocSysObjectTags(struct ExecIFace *Self, ULONG type, ...)))
{
	va_list	va;
	va_start	(va, type);
	return OS4_AllocSysObject(Self, type, (struct TagItem *)va->overflow_arg_area);
}

EMUCALL(VOID, PROTO(FreeSysObject(struct ExecIFace *Self, ULONG type, APTR object)))
{
	NR_START
	D(bug("ExecIFace: FreeSysObject(%ld)\n", type));

	if (object)
	{
		switch (type)
		{
			case ASOT_PORT			:
				{
					LONG *p = (LONG *)object;

					p--;

					FreeSignal(*p);

					object = (APTR)p;
				}

			case ASOT_IOREQUEST	:
			case ASOT_HOOK			:
			case ASOT_INTERRUPT	:
			case ASOT_LIST			:
			case ASOT_NODE			:
			case ASOT_MESSAGE		:
			case ASOT_SEMAPHORE	:
			case ASOT_TAGLIST		: FreeObj(Self, object); break;
			case ASOT_MEMPOOL		: DeletePool(object); break;
			case ASOT_ITEMPOOL	: break;
			case ASOT_DMAENTRY	: break;
		}
	}
	NR_END
}
