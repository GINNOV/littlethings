#ifndef __modp_vardnsexpdegspspol_sequence_header__
#define __modp_vardnsexpdegspspol_sequence_header__

@interface modp_vardnsexpdegspspol_sequence : sequencec
{
  id content;
  id currentMember;
  struct modp_vardnsexpdegspspol_ix ix;
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

#endif /* __modp_vardnsexpdegspspol_sequence_header__ */
 
