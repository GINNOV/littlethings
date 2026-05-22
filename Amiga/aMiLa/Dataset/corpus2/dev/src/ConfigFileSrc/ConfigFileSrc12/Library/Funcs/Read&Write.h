/*
**		$PROJECT: ConfigFile.library
**		$FILE: Read&Write.h
**		$DESCRIPTION: Read.c and Write.c header file
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
**
*/

#ifndef READ_WRITE_H
#define READ_WRITE_H

#define CTRLB_END	0x00
#define CTRLB_SUB	0xFF

#define NUM_MASK		0xC0
#define NUM_WORD		0x80
#define NUM_BYTE		0x40

#define BOOL_TRUE		0x80

#define STYP_MASK		0x38

#define TYP_MASK		0x07
#define TYP_STRING	0x07
#define TYP_NUMBER	0x06
#define TYP_BOOL		0x05
#define TYP_EXT_1		0x04
#define TYP_EXT_2		0x03
#define TYP_EXT_3		0x02
#define TYP_EXT_4		0x01

#endif /* READ_WRITE_H */
