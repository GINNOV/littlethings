
/*
 * Portable Object Compiler (c) 1998 by Stes & Lerman.  All Rights Reserved.
 */

#ifndef __OBJGRAPH_H__
#define __OBJGRAPH_H__

#include "objc.h"

@interface ObjGraph : Object
{
}

+ over:anId;
- over:anId unique:(BOOL)flag;
+ over:anId unique:(BOOL)flag;
- (unsigned) size;
- error:(STR)fmt,...;
- add:anObject;
@end

#endif /* __OBJGRAPH_H__ */


