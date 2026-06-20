/*
 * Grafo
 *
 * Graph
 *
 */

#ifndef GRAP
#define GRAP
#include <stdio.h>
#include <stdlib.h>
#include "myerror.h"


#define NO 0
#define SI 1
#define INTMAX 20000
typedef struct s0{ int size;
                   int **adj;
                   int allocato;
                   }TGRAPH;
extern void GraphCreate(TGRAPH *g,int isize);
extern void GraphFree(TGRAPH *g);
extern void GraphPutArc(TGRAPH *g,int n1,int n2,int weight);
extern void GraphRemoveArc(TGRAPH *g,int n1,int n2);
extern void GraphCopy (TGRAPH *gdest,TGRAPH *gsource);
extern void GraphPutNode(TGRAPH *,TGRAPH*);
extern void GraphRemoveNode(TGRAPH*,TGRAPH*,int);
extern void GraphTransitiveClosure(TGRAPH *g,TGRAPH *tc);
extern int GraphShortTestPath(TGRAPH *g,int s,int t,int*);
extern int GraphIsConnected(TGRAPH *g);
extern void GraphTraverseArcs(TGRAPH *g,void (*f)());
#endif
