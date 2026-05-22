#ifndef BSET_H_
#define BSET_H_

typedef struct BSet BSet;

BSet *bset_new(int nmemb);
void bset_free(BSet *s);
void bset_cpy(BSet *s1, BSet *s2); /* s1 = s2 */
void bset_clear(BSet *s);
int bset_eq(BSet *s1, BSet *s2);
void bset_union(BSet *s1, BSet *s2); /* s1 = s1 U s2 */
void bset_inters(BSet *s1, BSet *s2); /* s1 = s1 ∩ s2 */
void bset_diff(BSet *s1, BSet *s2); /* s1 = s1 \ s2 */
int bset_member(BSet *s, int e);
void bset_insert(BSet *s, int e);
void bset_delete(BSet *s, int e);
int bset_card(BSet *s); /* |s| */
/*
 * Return the position of the next rightmost '1', or -1 if there is none.
 * Note the least-significant bit is at position zero.
 */
int bset_iterate(BSet *s);
void bset_fill(BSet *s, int n); /* give membership to everything up to (and excluding) n */

#endif
