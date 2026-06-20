/*
 * OS4 68k STUBS file automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


#ifndef		TEST_STUBS68K_H
#define		TEST_STUBS68K_H

/*
**
**    Copyright (C) 2008/2009 Weaver Developers.
**
**    All rights reserved.
**
*/


#ifdef		__USE_INLINE__
#undef		__USE_INLINE__
#endif

#ifndef		__NOGLOBALIFACE__
#define		__NOGLOBALIFACE__
#endif

#include	<exec/interfaces.h>
#include	<exec/libraries.h>
#include	<exec/emulation.h>
#include	<interfaces/exec.h>
/* Create the interface file by using Weaver with keyword IFACE */
#include	<interfaces/test.h>		/* You may create and store it locally; here it's there where it belongs */


/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


/* FIXME - am I really necessary? */
static inline int8  convert_int8 (uint32 x) { return x; }
static inline int16 convert_int16(uint32 x) { return x; }


STATIC struct Library * stub_OpenPPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct LibraryManagerInterface *Self = (struct LibraryManagerInterface *) ExtLib->ILibrary;

	return (Self->Open)( 0);
}
STATIC CONST struct EmuTrap stub_Open = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_OpenPPC };


STATIC APTR stub_ClosePPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct LibraryManagerInterface *Self = (struct LibraryManagerInterface *) ExtLib->ILibrary;

	return (Self->Close)();
}
STATIC CONST struct EmuTrap stub_Close = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_ClosePPC };


STATIC APTR stub_ExpungePPC(uint32 *regarray UNUSED)
{
	return NULL;
}
STATIC CONST struct EmuTrap stub_Expunge = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_ExpungePPC };


STATIC uint32 stub_ReservedPPC(uint32 *regarray UNUSED)
{
	return 0;
}
STATIC CONST struct EmuTrap stub_Reserved = { TRAPINST, TRAPTYPE, stub_ReservedPPC };


STATIC uint32 stub_Reserved1PPC(uint32 *regarray UNUSED)
{
	return 0;
}
STATIC CONST struct EmuTrap stub_Reserved1 = { TRAPINST, TRAPTYPE, stub_Reserved1PPC };


STATIC LONG stub_AddPPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct TestIFace *Self = (struct TestIFace *) ExtLib->MainIFace;

	return (Self->Add)(
		(LONG) regarray[0],
		(LONG) regarray[1]);
}
STATIC CONST struct EmuTrap stub_Add = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_AddPPC };


STATIC LONG stub_SubPPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct TestIFace *Self = (struct TestIFace *) ExtLib->MainIFace;

	return (Self->Sub)(
		(LONG) regarray[0],
		(LONG) regarray[1]);
}
STATIC CONST struct EmuTrap stub_Sub = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_SubPPC };


STATIC uint32 stub_Reserved2PPC(uint32 *regarray UNUSED)
{
	return 0;
}
STATIC CONST struct EmuTrap stub_Reserved2 = { TRAPINST, TRAPTYPE, stub_Reserved2PPC };


STATIC struct Screen * stub_CloneWBScrPPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct TestIFace *Self = (struct TestIFace *) ExtLib->MainIFace;

	return (Self->CloneWBScr)();
}
STATIC CONST struct EmuTrap stub_CloneWBScr = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_CloneWBScrPPC };


STATIC void stub_CloseClonedWBScrPPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct TestIFace *Self = (struct TestIFace *) ExtLib->MainIFace;

	(Self->CloseClonedWBScr)(
		(struct Screen *) regarray[8]);
}
STATIC CONST struct EmuTrap stub_CloseClonedWBScr = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_CloseClonedWBScrPPC };


STATIC void stub_GetClonedWBScrAttrAPPC(uint32 *regarray)
{
	struct Library *Base = (struct Library *) regarray[REG68K_A6/4];
	struct ExtendedLibrary *ExtLib = (struct ExtendedLibrary *) ((uint32) Base + Base->lib_PosSize);
	struct TestIFace *Self = (struct TestIFace *) ExtLib->MainIFace;

	(Self->GetClonedWBScrAttrA)(
		(struct Screen *) regarray[8],
		(struct TagItem *) regarray[9]);
}
STATIC CONST struct EmuTrap stub_GetClonedWBScrAttrA = { TRAPINST, TRAPTYPE, (uint32 (*)(uint32 *)) stub_GetClonedWBScrAttrAPPC };


CONST CONST_APTR VecTable68K[] =
{
	&stub_Open,
	&stub_Close,
	&stub_Expunge,
	&stub_Reserved,
	&stub_Reserved1,
	&stub_Add,
	&stub_Sub,
	&stub_Reserved2,
	&stub_CloneWBScr,
	&stub_CloseClonedWBScr,
	&stub_GetClonedWBScrAttrA,
	(CONST_APTR) -1
};


#endif	/* TEST_STUBS68K_H */
