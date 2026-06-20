/* Amiga C++ List Nodes
** Copyright (C) 1986, by MTS Associates, Jacksonville FL
** All rights reserved.  Duplication of this data by other than
** licensed users is a violation of copyright law.
**
** Function prototypes for the exec.library of Amiga EXEC
**
** Updated: 11/17/86, TFH
** Constructeur de noeud modifié: Vendredi 14-Août-92 par Gilles Dridi
*/

#ifndef EXEC_NODES_H
#define  EXEC_NODES_H

enum Node_Type {
 NT_UNKNOWN =  0, 
 NT_TASK =  1, 
 NT_INTERRUPT =   2, 
 NT_DEVICE =   3, 
 NT_MSGPORT =  4, 
 NT_MESSAGE =  5, 
 NT_FREEMSG =  6, 
 NT_REPLYMSG = 7, 
 NT_RESOURCE = 8,
 NT_LIBRARY =  9,
 NT_MEMORY =   10,
 NT_SOFTINT =  11,
 NT_FONT =  12,
 NT_PROCESS =  13,
 NT_SEMAPHORE = 14,
 NT_SIGNALSEM = 15
};

struct Node;
void Remove( Node* n);

struct MinNode {
   MinNode *mln_Succ;
   MinNode *mln_Pred;

   MinNode *next() { return mln_Succ; }
   MinNode *prev() { return mln_Pred; }
   void remove() {Remove( (Node *) this); }
   BOOL is_first() { return mln_Pred->mln_Pred == NULL; }
   BOOL is_last() { return mln_Succ->mln_Succ == NULL; }
   BOOL at_end() { return mln_Succ == NULL; }
};

struct Node : public MinNode {

#define ln_Succ mln_Succ
#define ln_Pred mln_Pred

    UBYTE   ln_Type;
    BYTE    ln_Pri; 
    char    *ln_Name; 

   friend Node *FindName(Node *nd, const TEXT *n);

   Node(Node_Type node_type, TEXT *name= NULL,
       int priority= 0) {
      ln_Succ = ln_Pred = 0;
      ln_Type = node_type;
      ln_Pri  = priority;
      ln_Name = name;
   }
   Node() {}   // null constructor

      Node *next() { return (Node *) ln_Succ; }
      Node *prev() { return (Node *) ln_Pred; }

   char *name() { return ln_Name; }
   void remove() {Remove(this); }
   Node *find(const TEXT *n) { return FindName(this, n); }
};

#endif
