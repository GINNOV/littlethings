/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: keymap.h,v 1.2.1.3 1994/12/09 05:27:24 jason Exp $

$Log: keymap.h,v $
 * Revision 1.2.1.3  1994/12/09  05:27:24  jason
 * added copyright
 *
 * Revision 1.2.1.2  1994/11/16  06:20:37  jason
 * comments
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:04:12  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:00:51  jason
 * RCS/agl.h,v
 *

******************************************************************************/


/*
 *  Key remapping for Amiga GL
 */

#define KEYMAPLENGTH	128

static short KeyRemap[KEYMAPLENGTH]=
	{
	ACCENTGRAVEKEY,	/* 0x00	? */
	ONEKEY,			/* 0x01	*/
	TWOKEY,			/* 0x02	*/
	THREEKEY,		/* 0x03	*/
	FOURKEY,		/* 0x04	*/
	FIVEKEY,		/* 0x05	*/
	SIXKEY,			/* 0x06	*/
	SEVENKEY,		/* 0x07	*/
	EIGHTKEY,		/* 0x08	*/
	NINEKEY,		/* 0x09	*/
	ZEROKEY,		/* 0x0A	*/
	MINUSKEY,		/* 0x0B	*/
	EQUALKEY,		/* 0x0C	*/
	BACKSLASHKEY,	/* 0x0D	*/
	0,				/* 0x0E	*/
	PAD0,			/* 0x0F	*/
	QKEY,			/* 0x10	*/
	WKEY,			/* 0x11	*/
	EKEY,			/* 0x12	*/
	RKEY,			/* 0x13	*/
	TKEY,			/* 0x14	*/
	YKEY,			/* 0x15	*/
	UKEY,			/* 0x16	*/
	IKEY,			/* 0x17	*/
	OKEY,			/* 0x18	*/
	PKEY,			/* 0x19	*/
	LEFTBRACKETKEY,	/* 0x1A	*/
	RIGHTBRACKETKEY,/* 0x1B	*/
	0,				/* 0x1C	*/
	PAD1,			/* 0x1D	*/
	PAD2,			/* 0x1E	*/
	PAD3,			/* 0x1F	*/
	AKEY,			/* 0x20	*/
	SKEY,			/* 0x21	*/
	DKEY,			/* 0x22	*/
	FKEY,			/* 0x23	*/
	GKEY,			/* 0x24	*/
	HKEY,			/* 0x25	*/
	JKEY,			/* 0x26	*/
	KKEY,			/* 0x27	*/
	LKEY,			/* 0x28	*/
	SEMICOLONKEY,	/* 0x29	*/
	QUOTEKEY,		/* 0x2A	*/
	0,				/* 0x2B	*/
	0,				/* 0x2C	*/
	PAD4,			/* 0x2D	*/
	PAD5,			/* 0x2E	*/
	PAD6,			/* 0x2F	*/
	0,				/* 0x30	*/
	ZKEY,			/* 0x31	*/
	XKEY,			/* 0x32	*/
	CKEY,			/* 0x33	*/
	VKEY,			/* 0x34	*/
	BKEY,			/* 0x35	*/
	NKEY,			/* 0x36	*/
	MKEY,			/* 0x37	*/
	COMMAKEY,		/* 0x38	*/
	PERIODKEY,		/* 0x39	*/
	VIRGULEKEY,		/* 0x3A	*/
	0,				/* 0x3B	*/
	PADPERIOD,		/* 0x3C	*/
	PAD7,			/* 0x3D	*/
	PAD8,			/* 0x3E	*/
	PAD9,			/* 0x3F	*/
	SPACEKEY,		/* 0x40	*/
	BACKSPACEKEY,	/* 0x41	*/
	TABKEY,			/* 0x42	*/
	PADENTER,		/* 0x43	*/
	RETKEY,			/* 0x44	*/
	ESCKEY,			/* 0x45	*/
	DELKEY,			/* 0x46	*/
	0,				/* 0x47	*/
	0,				/* 0x48	*/
	0,				/* 0x49	*/
	PADMINUS,		/* 0x4A	*/
	0,				/* 0x4B	*/
	UPARROWKEY,		/* 0x4C	*/
	DOWNARROWKEY,	/* 0x4D	*/
	RIGHTARROWKEY,	/* 0x4E	*/
	LEFTARROWKEY,	/* 0x4F	*/
	F1KEY,			/* 0x50	*/
	F2KEY,			/* 0x51	*/
	F3KEY,			/* 0x52	*/
	F4KEY,			/* 0x53	*/
	F5KEY,			/* 0x54	*/
	F6KEY,			/* 0x55	*/
	F7KEY,			/* 0x56	*/
	F8KEY,			/* 0x57	*/
	F9KEY,			/* 0x58	*/
	F10KEY,			/* 0x59	*/
	PADPF1,			/* 0x5A	*/
	PADPF2,			/* 0x5B	*/
	PADVIRGULEKEY,	/* 0x5C	*/
	PADASTERKEY,	/* 0x5D	*/
	PADPLUSKEY,		/* 0x5E	*/
	INSERTKEY,		/* 0x5F	*/
	LEFTSHIFTKEY,	/* 0x60	*/
	RIGHTSHIFTKEY,	/* 0x61	*/
	CAPSLOCKKEY,	/* 0x62	*/
	CTRLKEY,		/* 0x63	*/
	LEFTALTKEY,		/* 0x64	*/
	RIGHTALTKEY,	/* 0x65	*/
	LEFTCTRLKEY,	/* 0x66	*/
	RIGHTCTRLKEY,	/* 0x67	*/
	0,				/* 0x68	*/
	0,				/* 0x69	*/
	0,				/* 0x6A	*/
	0,				/* 0x6B	*/
	0,				/* 0x6C	*/
	0,				/* 0x6D	*/
	0,				/* 0x6E	*/
	0,				/* 0x6F	*/
	};
