/* 
 *
 * Albero binario ordinato
 *
 * Binary Tree
 *
 */

#include <bintree.h>



void TreeCreate (TTREE*t){
   t->n_elem=0;
   t->tree=NULL;
   }

static TTREEELEM *Create(TTREEITEM i){
   TTREEELEM *p;
   MALLOC (p,TTREEELEM *,sizeof(TTREEELEM));
   p->info=i;
   p->right=p->left=NULL;
   return p;
   }

static TTREEELEM * Locate(TTREE*t,TTREEITEM i){
    TTREEELEM *p,*q;
    p=q=t->tree;
    while (q!=NULL&&i!=p->info)  {
          p=q;
          if (i<p->info) q=p->left;
                else
                         q=p->right;
          }
    return p;
    }

int TreePut(TTREE*t,TTREEITEM i){
    TTREEELEM *p,*z;
    p=Locate (t,i);
      if(t->n_elem==0)
          {  z=Create (i);
             t->n_elem++;
             t->tree=z;}
      else
         if (p->info==i) return(1);
            else
            { z=Create (i);
              t->n_elem++;
               if (p->info>i) p->left=z;
                 else         p->right=z;
            }
    return (0);
    }

static void InOrder(TTREEELEM *p){
    if (p==NULL) return;
    InOrder(p->left);
    printf("\n%d",p->info);
    InOrder(p->right);
  }

void TreeInOrder(TTREE *p){
  InOrder(p->tree);
  }

static void PreOrder(TTREEELEM *p){
    if (p==NULL) return;
    printf("\n%d",p->info);
    PreOrder(p->left);
    PreOrder(p->right);
    }

void TreePreOrder(TTREE *p){
  PreOrder(p->tree);
  }

static void PostOrder(TTREEELEM *p){
    if (p==NULL) return;
    PostOrder(p->left);
    PostOrder(p->right);
    printf("\n%d",p->info);
    }
void TreePostOrder(TTREE *p){
    PostOrder(p->tree);
    }

static TTREEELEM * Locate2(TTREE*t,TTREEITEM i,TTREEELEM **pf){
    TTREEELEM *p,*q;
    p=*pf=q=t->tree;
    while (q!=NULL&&i!=p->info)  {
          *pf=p;
          p=q;
          if (i<p->info) q=p->left;
                else
                         q=p->right;
          }
    if (p->info==i)  return p;
       else
       return NULL;
    }

static int IsLeaf(TTREEELEM* p){
    return(p->right==NULL&&p->left==NULL);}

static int HasOneSubtree(TTREEELEM *p){
    return(p->left==NULL||p->right==NULL);}

static TTREEELEM *LocateInOrderSucc(TTREEELEM *p,TTREEELEM**pfather){
    TTREEELEM *father,*succ;
    father=p;
    succ=p->right;
    while (succ->left!=NULL)
       {
       father=succ;
       succ=succ->left;
       }
    *pfather=father;
    return (succ);
    }

int TreeGetNode (TTREE *t,TTREEITEM i){
    TTREEELEM *p,*pfather,*rp,*rpfather;
    TTREEITEM ii;
    p=Locate2(t,i,&pfather);
    if (p==NULL) return 0;
    if (IsLeaf(p)) rp=NULL;
       else
         if (HasOneSubtree(p))
           {
           rp=((p->left!=NULL)? p->left:p->right);
           }
            else
              {
              rp=LocateInOrderSucc(p,&rpfather);
              if (rpfather!=p){
                 rpfather->left=rp->right;
                 rp->right=p->right;
                 }
              rp->left=p->left;
              }
    if (p==t->tree) t->tree=rp;
      else
        if (p==pfather->left)  pfather->left=rp;
          else                 pfather->right=rp;
    t->n_elem--;
    /*ii=p->info;*/
    FREE(p);
    return (1);
    }
