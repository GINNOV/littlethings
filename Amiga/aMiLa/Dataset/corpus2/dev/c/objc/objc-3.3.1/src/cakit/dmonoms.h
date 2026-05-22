#ifndef __vardns_sequence_header__
#define __vardns_sequence_header__

@interface vardns_sequence : sequencec
{
  id content;
  id currentMember;
  struct vardns_ix ix;
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

#endif /* __vardns_sequence_header__ */
 
