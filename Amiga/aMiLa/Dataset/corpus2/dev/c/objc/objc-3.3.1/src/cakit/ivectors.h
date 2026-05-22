#ifndef __bigintobjvec_sequence_header__
#define __bigintobjvec_sequence_header__

@interface bigintobjvec_sequence : sequencec
{
  id content;
  id currentMember;
  struct bigintobjvec_ix ix;
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

#endif /* __bigintobjvec_sequence_header__ */
 
