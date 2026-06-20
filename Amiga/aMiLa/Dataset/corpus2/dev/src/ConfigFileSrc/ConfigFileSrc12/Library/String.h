/*
**		$PROJECT: ConfigFile.library
**		$FILE: String.h
**		$DESCRIPTION: Header file of prototypes.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef STRING_H
#define STRING_H 1

extern ULONG   __builtin_strlen(STRPTR);
extern ULONG   __builtin_strcmp(STRPTR, STRPTR);
extern STRPTR  __builtin_strcpy(STRPTR, STRPTR);
extern VOID    __builtin_memcpy(APTR,APTR,ULONG);

#define StrLen(a)   __builtin_strlen(a)
#define StrCmp(a,b) __builtin_strcmp(a,b)
#define StrCpy(a,b) __builtin_strcpy(a,b)
#define MemCpy(a,b,c) __builtin_memcpy(a,b,c)

#endif /* STRING_H */
