
/*
 * Portable Object Compiler (c) 1996 by Stes & Lerman.  All Rights Reserved.
 */

#ifndef __OBJASSOC_H__
#define __OBJASSOC_H__

#include "objc.h"

#define Association Assoc

@interface Assoc: Object
{
    id	key;
    id	value;
}

- setUpKey:aKey value:aValue;
+ key:aKey;
+ key:aKey value:aValue;

- key;
- (STR) str;
- value;

- (unsigned) hash;
- (BOOL) isEqual:anAssoc;
- (int) compare:anAssoc;

- value:aValue;

- printToFile:(FILE *)aFile;

#ifdef __PORTABLE_OBJC_NEXT__
- write:(NXTypedStream *)stream;
- read:(NXTypedStream *)stream;
#endif /* __PORTABLE_OBJC_NEXT__ */

@end

#endif /* __OBJASSOC_H__ */


