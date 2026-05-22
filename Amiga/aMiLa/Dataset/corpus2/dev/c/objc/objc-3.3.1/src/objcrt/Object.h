
/*
 * Portable Object Compiler (c) 1997,98,99,2000,03,14.  All Rights Reserved.
 * $Id: Object.h,v 1.6 2014/03/04 09:02:08 stes Exp $
 */

/*
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published 
 * by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef __PORTABLE_OBJC__
/* if this file is included by a different compiler, it's by mistake */
#error Portable Object Compiler Object.h must not be in include path.
#else

#ifndef __OBJECT_H__
#define __OBJECT_H__

#include "objcrt.h"
#include <string.h>

#define __objcrt_revision__ "3.2.1"

#ifdef _XtIntrinsic_h
#define Object OCObject		/* remap Object class - cant use Xt Object */
#endif

@interface Object
{
  id isa;
#ifdef OBJC_REFCNT
  unsigned int _refcnt;
#else
  unsigned short attr;		/* compatibility Stepstone */
  unsigned short objID;		/* compatibility Stepstone */
#endif
}

+ initialize;
- initialize;

- str:(STR)s;
+ new;
- new;
- increfs;
- copy;
- deepCopy;
- free;
- decrefs;
- release;
+ free;
+ release;

- self;
- yourself;
- class;
- superclass;
- superClass;
+ class;
+ superclass;
+ superClass;
- add:anObject;
- (STR) name;
+ (STR) name;
- findClass:(STR)name;
- (SEL) findSel:(STR)name;
- (SEL) selOfSTR:(STR)name;
- idOfSTR:(STR)aClassName;

- (unsigned) hash;
- (BOOL) isEqual:anObject;
- (STR) str;
- (unsigned) size;
+ (BOOL) isEqual:anObject;
- (BOOL) isSame:anObject;
- (BOOL) notEqual:anObject;
- (BOOL) notSame:anObject;
- (int) compare:anObject;
- (int) invertCompare:anObject;

- (BOOL) respondsTo:(SEL)aSelector;
- (BOOL) isMemberOf:aClass;
- (BOOL) isKindOf:aClass;

+ someInstance;
- nextInstance;
- become:other;
+ become:other;

+ subclasses;
+ poseAs:superClass;
+ addMethodsTo:superClass;
+ subclass:(STR)name;
+ subclass:(STR)name:(int)ivars:(int)cvars;
+ load;
+ unload;
+ (BOOL) inheritsFrom:aClass;
+ (BOOL) isSubclassOf:aClass;

- subclassResponsibility;
- subclassResponsibility:(SEL)aSelector;
- notImplemented;
- notImplemented:(SEL)aSelector;
- shouldNotImplement;
- shouldNotImplement:(SEL)aSelector;
- shouldNotImplement:(SEL)aSelector from:superClass;
- vsprintf:(STR)format:(OC_VA_LIST *)ap;
- error:(STR)format,...;
- halt:message;

- doesNotRecognize:(SEL)aSelector;
- doesNotUnderstand:aMessage;

- (IMP) methodFor:(SEL)aSelector;
+ (IMP) instanceMethodFor:(SEL)aSelector;

- perform:(SEL)aSelector;
- perform:(SEL)aSelector with:anObject;
- perform:(SEL)aSelector with:anObject with:otherObject;
- perform:(SEL)aSelector with:anObject with:otherObject with:thirdObj;

- print;
+ print;
- printLine;
- show;
- printToFile:(FILE *)aFile;
- printOn:(IOD)anIOD;

+ (STR) objcrtRevision;

+ readFrom:(STR)aFileName;
- (BOOL) storeOn:(STR)aFileName;

- fileOutIdsFor:aFiler;
- fileInIdsFrom:aFiler;
- fileOutIdsFor;
- fileInIdsFrom;
- fileOutOn:aFiler;
+ fileInFrom:aFiler;
- fileInFrom:aFiler;
- fileOut:(void *)value type:(char)typeDesc;
- fileIn:(void *)value type:(char)typeDesc;
- awake;
- awakeFrom:aFiler;

@end

#endif /* __OBJECT_H__ */

#endif /* __PORTABLE_OBJC__ */
 
