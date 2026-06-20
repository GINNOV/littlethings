#ifndef __bigintobj_vardnsrecdegdnspol_sequence_header__
#define __bigintobj_vardnsrecdegdnspol_sequence_header__

@interface bigintobj_vardnsrecdegdnspol_sequence : sequencec
{
  id content;
  id currentMember;
  struct bigintobj_vardnsrecdegdnspol_ix ix;
}
- _setUpContent:anObject;
+ content:anObject;
- release;
- (unsigned) size;
- (BOOL) isEmpty;
- toFirst;
- toLast;
- toElementAt:(int)i;
- currentMember;
- next;
- previous;
@end

#endif /* __bigintobj_vardnsrecdegdnspol_sequence_header__ */
 
