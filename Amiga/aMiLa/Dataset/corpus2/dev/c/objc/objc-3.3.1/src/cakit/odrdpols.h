#ifndef __obj_vardnsrecdegdnspol_sequence_header__
#define __obj_vardnsrecdegdnspol_sequence_header__

@interface obj_vardnsrecdegdnspol_sequence : sequencec
{
  id content;
  id currentMember;
  struct obj_vardnsrecdegdnspol_ix ix;
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

#endif /* __obj_vardnsrecdegdnspol_sequence_header__ */
 
