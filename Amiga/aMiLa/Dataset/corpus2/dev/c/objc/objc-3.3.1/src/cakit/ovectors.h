#ifndef __objvec_sequence_header__
#define __objvec_sequence_header__

@interface objvec_sequence : sequencec
{
  id content;
  id currentMember;
  struct objvec_ix ix;
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

#endif /* __objvec_sequence_header__ */
 
