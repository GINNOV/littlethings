/*
 *
 *  Grafo Matrice di adiacenza
 *
 *  Graph (adjacency matrix)
 *
 */

#include <graph.h>
#include <arraydyn.h>

void GraphCreate(TGRAPH *g,int isize){
int i,j;
g->size=isize;
CALLOC(g->adj,int**,isize,sizeof(int*))
for (i=0;i<isize;i++){
 CALLOC (g->adj[i],int*,isize,sizeof(int));
 }
for (i=0;i<isize;i++)
  for(j=0;j<isize;j++)
     g->adj[i][j]=0;
g->allocato=1;
}


void GraphFree(TGRAPH *g){
int i,j;
for (i=0;i<g->size;i++){
 FREE(g->adj[i]);
 }
FREE(g->adj);
g->allocato=0;
g->size=0;
}

void GraphPutArc(TGRAPH *g,int n1,int n2,int weight){
g->adj[n1][n2]=weight;
}

void GraphRemoveArc(TGRAPH *g,int n1,int n2){
g->adj[n1][n2]=0;
}



void GraphCopy (TGRAPH *gdest,TGRAPH *gsource){
int i,j;
if (!gsource->allocato||!gdest->allocato) FATAL (O SBOB BOB U);
for (i=0;i<gsource->size;i++)
   for (j=0;j<gsource->size;j++)
      gdest->adj[i][j]=gsource->adj[i][j];
}

extern void GraphPutNode(TGRAPH *g1,TGRAPH *g2){
   GraphCreate(g2,g1->size+1);
   GraphCopy(g2,g1);
   }

extern void GraphRemoveNode(TGRAPH *g1,TGRAPH *g2,int nodo){
   int i,j,r,c;
   nodo--;
   if (nodo>g1->size||nodo<0) FATAL (Errore nodo inesistente);
         GraphCreate(g2,g1->size-1);
         r=0;
         c=0;
         for (i=0;i<g1->size;i++){
                c=0;
                for (j=0;j<g1->size;j++){
                  if(i!=nodo&&j!=nodo) g2->adj[r][c]=g1->adj[i][j];
                        if (j!=nodo) c++;
                }
         if (i!=nodo) r++;
         }
 }

static void prod(TGRAPH *a,TGRAPH *b,TGRAPH *c){
  int i,j,k,val;
  for (i=0;i<a->size;i++)
     for (j=0;j<a->size;j++){
       val=0;
       for (k=0;k<a->size;k++)
          val=val||(a->adj[i][k]&&b->adj[k][j]);
          c->adj[i][j]=val;
          }
     }
static void GrafAdd (TGRAPH *a,TGRAPH *b){
  int i,j;
  for (i=0;i<a->size;i++)
     for (j=0;j<a->size;j++)
                a->adj[i][j]=a->adj[i][j]||b->adj[i][j];
 }

void GraphTransitiveClosure(TGRAPH *g,TGRAPH *tc){
  int i;
  TGRAPH temp1,temp2;
  GraphCreate(&temp1,g->size);
  GraphCreate(&temp2,g->size);
  GraphCopy(&temp1,g);
  GraphCopy(tc,g);
  for(i=0;i<g->size;i++){
    prod(&temp1,g,&temp2);
    GrafAdd(tc,&temp2);
    GraphCopy(&temp1,&temp2);
  }
}

int GraphShortTestPath(TGRAPH *g,int s,int t,int *path){
  TARRAY distance,definitivo;
  int smalldist=INTMAX;
  int newdist;
  int current,i,k,ln;
  ArrayCreate(&distance,g->size);
  ArrayCreate(&definitivo,g->size);
    for (i=0;i<g->size;i++){
           ArrayPut(&distance,i,INTMAX);
       ArrayPut(&definitivo,i,NO);
       }
  ArrayPut(&distance,s,0);
  ArrayPut(&definitivo,s,SI);
  current=s;
  path[0]=s;
  while (current!=t){
        smalldist=INTMAX;
    ln=ArrayRead(&distance,current);    /* Distanza Attuale da s */
    for (i=0;i<g->size;i++){
      if (ArrayRead(&definitivo,i)==NO){
         newdist=ln+g->adj[current][i];
         if (newdist<ArrayRead(&distance,i)){
              ArrayPut(&distance,i,newdist);
              path[i]=current;    /* Segnamo i nodi del cammino */
              }
         if (ArrayRead(&distance,i)<smalldist){
              smalldist=ArrayRead(&distance,i);
              k=i;
              }
      }
    }
    current=k;
    ArrayPut(&definitivo,k,SI);
  }
  i=ArrayRead(&distance,t);
  ArrayFree(&distance);
  ArrayFree(&definitivo);
  return (i);
}


int GraphIsConnected(TGRAPH *g){
 int i,j,k;
 int connesso=1;
 TARRAY toccata;
 ArrayCreate(&toccata,g->size);
 for (i=0;i<g->size;i++)
  ArrayPut(&toccata,i,NO);
  ArrayPut(&toccata,0,SI);
   for (k=0;k<g->size;k++)
     for(j=0;j<g->size;j++){
       if ((ArrayRead(&toccata,k)==SI)&&g->adj[k][j])
          ArrayPut(&toccata,j,SI);}
   for (i=0;i<g->size;i++)
     if (ArrayRead(&toccata,i)==NO) connesso=0;
   ArrayFree(&toccata);
   return connesso;
  }

void GraphTraverseArcs(TGRAPH *g,void (*f)(int,int)){
 int i,j;
  for (i=0;i<g->size;i++){
    for (j=0;j<g->size;j++)
     if (g->adj[i][j]==1)
                         (*f)(i,j);
        }
}

void TrasformaMatrx (TGRAPH *g){
        int i,j;
        for (i=0; i<g->size; i++)
                for (j=0; j<g->size; j++){
                if (i!=j && g->adj[i][j]==0)
                        g->adj[i][j]=INTMAX;
                }
}
