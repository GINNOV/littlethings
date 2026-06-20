#ifndef __obj_vardnsrecdegspspol_sequence_header__
#define __obj_vardnsrecdegspspol_sequence_header__

@interface obj_vardnsrecdegspspol_sequence : sequencec
{
  id content;
  id currentMember;
  struct obj_vardnsrecdegspspol_ix ix;
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

#endif /* __obj_vardnsrecdegspspol_sequence_header__ */
 
