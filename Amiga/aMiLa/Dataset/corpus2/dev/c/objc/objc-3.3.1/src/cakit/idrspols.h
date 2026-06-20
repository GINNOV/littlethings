#ifndef __bigintobj_vardnsrecdegspspol_sequence_header__
#define __bigintobj_vardnsrecdegspspol_sequence_header__

@interface bigintobj_vardnsrecdegspspol_sequence : sequencec
{
  id content;
  id currentMember;
  struct bigintobj_vardnsrecdegspspol_ix ix;
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

#endif /* __bigintobj_vardnsrecdegspspol_sequence_header__ */
 
