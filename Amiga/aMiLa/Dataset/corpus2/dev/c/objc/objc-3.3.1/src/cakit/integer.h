
/*
 * Computer Algebra Kit (c) 1992,00 by Comp.Alg.Objects.  All Rights Reserved.
 * $Id: integer.h,v 1.7 2000/10/12 14:40:25 stes Exp $
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

typedef unsigned short bigintwrd_t;

typedef bigintwrd_t *bigintdig_t;

typedef struct bigint
  {
    int sign;
    int count;
    int capacity;
    bigintdig_t digits;
  }
 *bigint_t;
#if (0)				/* public and private structure must match exactly */
typedef struct bigint
  {
    int sign;
    int count;
    int capacity;
    void *digits;
  }
 *bigint_t;
#endif /* 0 */

typedef unsigned short int DIGIT;

/* the following type is declared here only to be included once
 * there is *no* special treatment of small integers in CAInteger
 */
typedef struct bigintobj
  {
    short int hit;
    short int val;
    id obj;
  }
 *bigintobj_t;

typedef struct bigintobj *bigintobjseq_t;
typedef struct bigintobj bigintobj_c;
typedef struct
  {
    id proto;
  }
bigintobj_args;

#define bigintobj_isvalue	0
#define bigintobj_pervalue	0

@interface BigInt : CAObject
{
  struct bigint value;
}
- check;

- _setUpInteger;
+ new;
+ str:(STR)aString;
+ int:(int)intValue;
- factorial:(int)n;
+ factorial:(int)n;
+ fibonacci:(int)n;
- copy;
- deepCopy;
- release;
- doempty;
- empty;
- (bigint_t) bigint_value;
- dobigint_value:(bigint_t)aValue;
- bigint_value:(bigint_t)aValue;
- (bigint_t) bigint_reference;
- dobigint_reference:(bigint_t)aReference;
- bigint_reference:(bigint_t)aReference;
- class_vector;
- class_vardnsrecdegsps_polynomial;
- class_vardnsrecdegdns_polynomial;
- class_vardnsexpdegsps_polynomial;

- (unsigned) hash;
- (BOOL) isEqual:b;
- (BOOL) notEqual:b;
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
- (BOOL) notZero;
- (BOOL) isOpposite:b;
- (BOOL) notOpposite:b;
- negate;
- _double:(int)v;
- double;
- _add:(int)v:b:(int)w;
- add:b;
- subtract:b;
- addDigit:(DIGIT)d;
- subtractDigit:(DIGIT)d;

- one;
- minusOne;
- _add:(int)v:B multiply:b:(int)w;
- _multiply:a:(int)v add:B:(int)w;
- _multiply:a:(int)v add:B multiply:b:(int)w;
- (BOOL) isOne;
- (BOOL) notOne;
- (BOOL) isMinusOne;
- (BOOL) notMinusOne;
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

- fileOutOn:aFiler;
- fileInFrom:aFiler;
@end

#endif /* __CAINTEGER_HEADER__ */
 
