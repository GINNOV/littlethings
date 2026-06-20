
/*
 * Computer Algebra Kit (c) 1992,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: integer.h,v 1.5 2000/10/05 14:59:15 stes Exp $
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

#ifndef __CAINTEGER_HEADER__
#define __CAINTEGER_HEADER__

#include "cobject.h"

#define Integer BigInt

typedef struct bigint
  {
    int sign;
    int count;
    int capacity;
    void *digits;
  }
 *bigint_t;

typedef unsigned short int DIGIT;

@interface BigInt : CAObject
{
  struct bigint value;
}

+ new;
+ str:(STR)aString;
+ int:(int)intValue;
+ factorial:(int)n;
+ fibonacci:(int)n;
- copy;
- deepCopy;
- release;

- (unsigned) hash;
- (BOOL) isEqual:b;
- (int) numDigits;
- (BOOL) isDigit;

- insertDigit:(DIGIT)d;
- (DIGIT) removeDigit;

- (DIGIT) digitAt:(int)i;
- (DIGIT) lastDigit;
- (DIGIT) leadingDigit;

- (STR) str;
- str:(STR)aString;

- asNumerical;
- asModp:(unsigned short)p;
- (DIGIT) digitValue;
- digitValue:(DIGIT)aValue;
- (unsigned long) ulongValue;
- ulongValue:(unsigned long)aValue;
- (int) intValue;
- intValue:(int)aValue;
- (double) doubleValue;
- (float) floatValue;

- (int) sign;
- (int) compare:b;

- zero;
- (BOOL) isZero;
- (BOOL) isOpposite:b;
- negate;
- double;
- add:b;
- subtract:b;
- addDigit:(DIGIT)d;
- subtractDigit:(DIGIT)d;

- one;
- minusOne;
- (BOOL) isOne;
- (BOOL) isMinusOne;
- square;
- multiply:b;
- multiplyDigit:(DIGIT)d;
- inverse;

- divide:b;
- divideDigit:(DIGIT)b;
- quotientDigit:(DIGIT)b;
- remainder:b quotient:(id *)q;
- quotientDigit:(DIGIT)d remainder:(DIGIT *)r;
- (DIGIT) remainderDigit:(DIGIT)d;

- (BOOL) isEven;
- (BOOL) isOdd;

- gcd:b;

- (BOOL) printsLeadingSign;
- printOn:(IOD)aFile;
@end

#endif /* __CAINTEGER_HEADER__ */
 
