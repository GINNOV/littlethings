/* 
 *
 *  Albero binario ordinato
 *
 *  Binary Tree
 *
 */

#ifndef BINTRE
#define BINTRE
#include <stdlib.h>
#include <stdio.h>
#include "myerror.h"

typedef int TTREEITEM;
typedef struct s1 TTREEELEM;
typedef struct s1 {TTREEITEM info;
                   TTREEELEM *right;
                   TTREEELEM *left;
                   }TTREEELEM2;
typedef struct s2 { int n_elem;
                    TTREEELEM *tree;
                    }TTREE;

extern void TreeCreate(TTREE *t);
extern int TreePut (TTREE *,TTREEITEM );
          /* ritorna vero se gia' presente, altrimenti falso */
extern void TreeInOrder (TTREE *);
extern void TreePreOrder (TTREE *);
extern void TreePostOrder (TTREE *);
extern int TreeGetNode(TTREE*,TTREEITEM);
          /* Ritorna vero se eliminato falso se non presente */
#endif

