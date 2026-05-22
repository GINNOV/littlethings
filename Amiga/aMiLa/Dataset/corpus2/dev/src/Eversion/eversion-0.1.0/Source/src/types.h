#ifndef EVERSION__TYPES_H
 #define EVERSION__TYPES_H

typedef unsigned char		u8;
typedef unsigned short		u16;
typedef unsigned long		u32;

typedef signed char			s8;
typedef signed short		s16;
typedef signed long			s32;

 #ifndef NULL
 # ifdef __cplusplus
 #  define NULL 0	// __cplusplus-only definition
 # else
 #  define NULL ((void*)0)
 # endif
 #endif


#endif //EVERSION__TYPES_H
