/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 9/25/2003
 *---------------------------------------------------------------------
 * Copyright (c) 2003 BITbyBIT Software Group, All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * BITbyBIT Software Group (Confidential Information).  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with BITbyBIT Software Group.
 *
 * BITbyBIT SOFTWARE GROUP MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
 * SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * BITbyBIT Software Group LLC SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
 * LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
 * SOFTWARE OR ITS DERIVATIVES.
 *---------------------------------------------------------------------
 *
 * Project: All
 *
 * Description: This file defines a common set datatypes and defines,
 *              to increase portability
 *
 * $VER: avd_types.h 1.0
 * 
 */

#ifndef __AVD_TYPES_H__
#define __AVD_TYPES_H__

#include <os_types.h>

/* Make sure we have the new style int8/16/32/64 types */
#include <sys/types.h>

#ifndef HAVE_UINT_TYPES
typedef char int8;
typedef unsigned char uint8;
typedef short int int16;
typedef unsigned short int uint16;
typedef long int32;
typedef unsigned long uint32;
#endif

#define AVD_NULL     0
#define AVD_TRUE     1
#define AVD_FALSE    0
#define AVD_OK       1
#define AVD_YES      1
#define AVD_NO       0
#define AVD_ERROR    -1
#define AVD_NO_ERROR 0

/* These Typedefs can be overridden in the <os_types.h> file */
#ifndef AVD_BOOL
#define AVD_BOOL     BOOL
#endif
#ifndef AVD_BYTE
#define AVD_BYTE     char
#endif
#ifndef AVD_UBYTE
#define AVD_UBYTE    unsigned char
#endif
#ifndef AVD_WORD
#define AVD_WORD     short int
#endif
#ifndef AVD_UWORD
#define AVD_UWORD    unsigned short int
#endif
#ifndef AVD_LONG
#define AVD_LONG     long
#endif
#ifndef AVD_ULONG
#define AVD_ULONG    unsigned long
#endif
#ifndef AVD_FLOAT
#define AVD_FLOAT    float
#endif

/* Define USE_PROTOTYPES */
#ifndef NO_PROTOTYPES
#ifndef USE_PROTOTYPES
#define USE_PROTOTYPES
#endif
#endif

#endif /* __AVD_TYPES_H__ */
