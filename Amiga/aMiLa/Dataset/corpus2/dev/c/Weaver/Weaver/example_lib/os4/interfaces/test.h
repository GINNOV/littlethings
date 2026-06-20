/*
 * INTERFACE file automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


#ifndef		TEST_INTERFACE_DEF_H
#define		TEST_INTERFACE_DEF_H

/*
**
**    Copyright (C) 2008/2009 Weaver Developers.
**
**    All rights reserved.
**
*/


#include	<exec/types.h>
#include	<exec/exec.h>
#include	<exec/interfaces.h>

/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


struct TestIFace
{
	struct InterfaceData Data;

	uint32	APICALL (*Obtain)(struct TestIFace *Self);
	uint32	APICALL (*Release)(struct TestIFace *Self);
	void	APICALL (*Expunge)(struct TestIFace *Self);
	struct Interface * APICALL (*Clone)(struct TestIFace *Self);

	void	APICALL (*Reserved1)(struct TestIFace *Self);
	LONG	APICALL (*Add)(struct TestIFace *Self, LONG a, LONG b);
	LONG	APICALL (*Sub)(struct TestIFace *Self, LONG a, LONG b);
	void	APICALL (*Reserved2)(struct TestIFace *Self);
	struct Screen *	APICALL (*CloneWBScr)(struct TestIFace *Self);
	void	APICALL (*CloseClonedWBScr)(struct TestIFace *Self, struct Screen *scr);
	void	APICALL (*GetClonedWBScrAttrA)(struct TestIFace *Self, struct Screen *scr, struct TagItem *tags);
	void	APICALL (*GetClonedWBScrAttr)(struct TestIFace *Self, struct Screen *scr, ...);
};

#endif	/* TEST_INTERFACE_DEF_H */
