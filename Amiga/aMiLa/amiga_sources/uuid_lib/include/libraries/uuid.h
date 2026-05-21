/* uuid.h */
/* This file is part of uuid.library by Chris Young
 * <chris@unsatisfactorysoftware.co.uk
 */

#ifndef _LIBRARIES_UUID_H_
#define _LIBRARIES_UUID_H_ 1

#define UUID_Version	TAG_USER+1
#define UUID_Namespace	TAG_USER+2
#define UUID_Name	TAG_USER+3
#define UUID_Preset	TAG_USER+4 /* See below */
#define UUID_String	TAG_USER+5

/* Pre-defined UUIDs */
#define UUID_NULL	1
#define UUID_NS_DNS	2
#define UUID_NS_URL	3
#define UUID_NS_OID	4
#define UUID_NS_X500	5

#endif
