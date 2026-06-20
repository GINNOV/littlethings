#ifndef yySets
#define yySets

/* $Id: Sets.h,v 1.7 1992/08/07 14:36:33 grosch rel $ */

/* $Log: Sets.h,v $
 * Revision 1.7  1992/08/07  14:36:33  grosch
 * layout changes
 *
 * Revision 1.6  1992/02/06  09:29:54  grosch
 * fixed bug: stdio and ANSI C
 *
 * Revision 1.5  1991/11/21  14:25:34  grosch
 * new version of RCS on SPARC
 *
 * Revision 1.4  91/07/17  17:23:38  grosch
 * introduced ARGS trick for ANSI compatibility
 *
 * Revision 1.3  90/07/04  14:34:05  grosch
 * introduced conditional include
 *
 * Revision 1.2  89/12/08  17:25:03  grosch
 * complete redesign in order to increase efficiency
 *
 * Revision 1.1  89/01/09  17:29:42  grosch
 * added functions Size, Minimum, and Maximum
 *
 * Revision 1.0  88/10/04  11:44:45  grosch
 * Initial revision
 *
 */

/* Ich, Doktor Josef Grosch, Informatiker, Sept. 1987 */


#include "ratc.h"
#include <stdio.h>


#define BitsPerBitset     32
#define LdBitsPerBitset   5
#define MaskBitsPerBitset 0x0000001f

#define IsElement(Elmt,Set)       ((int)((Set)->BitsetPtr[(Elmt) >> LdBitsPerBitset] << ((Elmt) & MaskBitsPerBitset)) < 0)
#define Size(Set)                 ((Set)->MaxElmt)
#define Select(Set)               Minimum(Set)
#define IsNotEqual(Set1,Set2)     (!IsEqual(Set1,Set2))
#define IsStrictSubset(Set1,Set2) (IsSubset(Set1,Set2) && IsNotEqual(Set1,Set2))


typedef long BITSET;

typedef struct {
                cardinal  MaxElmt;
                cardinal  LastBitset;
                BITSET   *BitsetPtr;
                short     Card;
                cardinal  FirstElmt;
                cardinal  LastElmt;
               } tSet;


void MakeSet(tSet *Set, cardinal MaxSize);
void ReleaseSet(tSet *Set);
void Union(tSet *Set1, tSet *Set2);
void Difference(tSet *Set1, tSet *Set2);
void Intersection(tSet *Set1, tSet *Set2);
void SymDiff(tSet *Set1, tSet *Set2);
void Complement(tSet *Set);
void Include(tSet *Set, cardinal Elmt);
void Exclude(tSet *Set, cardinal Elmt);
cardinal Card(tSet *Set);
/* cardinal Size(tSet *Set); */
cardinal Minimum(tSet *Set);
cardinal Maximum(tSet *Set);
/* cardinal Select(tSet *Set); */
cardinal Extract(tSet *Set);
bool IsSubset(tSet *Set1, tSet *Set2);
/* bool IsStrictSubset(tSet *Set1, tSet *Set2); */
bool IsEqual(tSet *Set1, tSet *Set2);
/* bool IsNotEqual(tSet *Set1, tSet *Set2); */
/* bool IsElement(cardinal Elmt, tSet *Set); */
bool IsEmpty(tSet *Set);
bool Forall(tSet *Set, bool (* Proc)());
bool Exists(tSet *Set, bool (* Proc)());
bool Exists1(tSet *Set, bool (* Proc)());
void Assign(tSet *Set1, tSet *Set2);
void AssignElmt(tSet *Set, cardinal Elmt);
void AssignEmpty(tSet *Set);
void ForallDo(tSet *Set, void (* Proc)());
void ReadSet(FILE *File, tSet *Set);
void WriteSet(FILE *File, tSet *Set);
void InitSets(void);

#endif
