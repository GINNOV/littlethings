#ifndef __modpvec_sequence_header__
#define __modpvec_sequence_header__

@interface modpvec_sequence : sequencec
{
  id content;
  id currentMember;
  struct modpvec_ix ix;
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

#endif /* __modpvec_sequence_header__ */
 
