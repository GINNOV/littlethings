/*--------------------------------------------------------------------------

 HDTemp - example usage of the HD_SMARTCMD

 Copyright (C) 2013 Rupert Hausberger <naTmeg@gmx.net>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

--------------------------------------------------------------------------*/

#include <devices/smart.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <exec/errors.h>

#include <proto/dos.h>
#include <proto/exec.h>

/*------------------------------------------------------------------------*/

#if defined(__GNUC__)
#ifdef __MORPHOS__
ULONG __abox__ 		= 1; /* mos 1.x binary 			*/
ULONG __amigappc__	= 1; /* mos 0.x compatibility */
int __initlibraries	= 0; /* no auto-libinit 		*/
#endif
int __nocommandline	= 1; /* no argc, argv 			*/
#endif

/*------------------------------------------------------------------------*/

#define NAME		"HDTemp"
#define VERSION	"1"
#define REVISION	"0"

static const char verstag[] = "$VER: "NAME" "VERSION"."REVISION" ("__AMIGADATE__") ©"__YEAR__" Rupert Hausberger <naTmeg@gmx.net>";

/*------------------------------------------------------------------------*/

#define ARG_TEMPLATE "DEVICE/A,UNIT/A/N,K=KELVIN/S"

enum {
	ARG_DEVICE,
	ARG_UNIT,
	ARG_KELVIN,
	ARG_END
};

struct ExecBase *SysBase = NULL;
struct DosLibrary *DOSBase = NULL;

static LONG main2(ULONG *args);

/*------------------------------------------------------------------------*/

int main(void)
{
	int rc = RETURN_FAIL;

	SysBase = *((struct ExecBase **)4l);
	if ((DOSBase = (struct DosLibrary *)OpenLibrary(DOSNAME, 37))) {
		struct RDArgs *rda;
		LONG err;

		if ((rda = AllocDosObject(DOS_RDARGS, NULL))) {
			struct RDArgs *rd;
			ULONG args[ARG_END] = { 0,0,0 };

			if ((rd = ReadArgs(ARG_TEMPLATE, args, rda))) {
				err = main2(args);
				FreeArgs(rd);
			} else
				err = IoErr();

			FreeDosObject(DOS_RDARGS, rda);
		} else
			err = ERROR_NO_FREE_STORE;

		if (err == 0)
			rc = RETURN_OK;
		else {
			PrintFault(err, NAME);
			SetIoErr(err);
		}
		CloseLibrary((struct Library *)DOSBase);
	}
	return rc;
}

/*------------------------------------------------------------------------*/
/* HD_SMARTCMD does use a IOStdReq */

static struct IOStdReq *io = NULL;
static struct MsgPort *mp = NULL;

static BOOL Open_Device(STRPTR device, ULONG unit)
{
	if ((mp = CreateMsgPort())) {
		if ((io = (struct IOStdReq *)CreateIORequest(mp, sizeof(struct IOStdReq)))) {
			if (OpenDevice(device, unit, (struct IORequest *)io, 0ul) == 0)
				return TRUE;

			DeleteIORequest(io);
		}
		DeleteMsgPort(mp);
	}
	return FALSE;
}

static void Close_Device(void)
{
	CloseDevice((struct IORequest *)io);
	DeleteIORequest(io);
	DeleteMsgPort(mp);
}

static BYTE Do_Device(UWORD command, APTR data, ULONG length, ULONG offset)
{
	io->io_Command = command;
	io->io_Flags = 0;
	io->io_Error = 0;
	io->io_Actual = 0;
	io->io_Length = length;
	io->io_Data = data;
	io->io_Offset = offset;

	return DoIO((struct IORequest *)io);
}

/*------------------------------------------------------------------------*/

static BOOL SMART_TestAvail(void)
{
	ULONG magic_id;

	if (Do_Device(HD_SMARTCMD, &magic_id, sizeof(ULONG), SMARTC_TEST_AVAIL) == 0) {
		if (magic_id == SMART_MAGIC_ID)
			return TRUE;
	}
	return FALSE;
}

static BYTE SMART_ReadAttributes(struct SMARTAttributes *sa)
{
	return Do_Device(HD_SMARTCMD, sa, SMART_DATA_LENGTH, SMARTC_READ_VALUES);
}

/*------------------------------------------------------------------------*/

UBYTE ExtractTemperature(struct SMARTAttributes *sa)
{
	UBYTE i;

	for (i = 0; i < SMART_MAX_ATTRIBUTES; i++) {
		struct SMARTAttributeEntry *sae = &sa->sa_Attribute[i];

		if (sae->sae_ID == SMARTA_HDA_TEMPERATURE)
			return sae->sae_Value;
	}
	return 0xff;
}

static LONG main2(ULONG *args)
{
	UBYTE *device = (UBYTE *)args[ARG_DEVICE];
	ULONG unit = *((ULONG *)args[ARG_UNIT]);
	BOOL kelvin = args[ARG_KELVIN] ? TRUE : FALSE;
	LONG rc = RETURN_FAIL;

	if (Open_Device(device, unit))
	{
		if (SMART_TestAvail())
		{
			struct SMARTAttributes sa;
			BYTE err;

			if ((err = SMART_ReadAttributes(&sa)) == 0)
			{
				UBYTE temp = ExtractTemperature(&sa);

				if (temp != 0xff) {
					Printf("%ld\n", kelvin ? (LONG)((FLOAT)temp + 273.15) : (LONG)temp);
					rc	= RETURN_OK;
				} else
					Printf("%s:%lu does not support the S.M.A.R.T. temperature attribute 0xC2\n", device, unit);
			} else {
				/* If S.M.A.R.T. is disabled, the device shall return IOERR_ABORTED, until SMARTC_ENABLE is issued. */
				if (err == IOERR_ABORTED)
					Printf("S.M.A.R.T. is disabled at %s:%lu\n", device, unit);
				else
					Printf("Error issuing command at %s:%lu (ioerr %ld)\n", device, unit, (LONG)err);
			}
		} else
			Printf("%s:%lu does not support the HD_SMARTCMD\n", device, unit);

		Close_Device();
	} else
		Printf("Can't open %s:%lu\n", device, unit);

	return rc;
}

/*------------------------------------------------------------------------*/

