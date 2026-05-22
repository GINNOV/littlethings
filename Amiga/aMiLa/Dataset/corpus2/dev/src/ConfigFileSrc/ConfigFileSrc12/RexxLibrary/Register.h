/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Register.h
**		$DESCRIPTION: Header file for easy use of register args.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef REGISTER_H
#define REGISTER_H

#define LibCall		__asm __saveds
#define SLibCall		__asm
#define RegCall		__asm
#define SaveDS			__saveds

#define REGA0			register __a0
#define REGA1			register __a1
#define REGA2			register __a2
#define REGA3			register __a3
#define REGA4			register __a4
#define REGA5			register __a5
#define REGA6			register __a6
#define REGA7			register __a7

#define REGD0			register __d0
#define REGD1			register __d1
#define REGD2			register __d2
#define REGD3			register __d3
#define REGD4			register __d4
#define REGD5			register __d5
#define REGD6			register __d6
#define REGD7			register __d7

#endif /* REGISTER_H */
