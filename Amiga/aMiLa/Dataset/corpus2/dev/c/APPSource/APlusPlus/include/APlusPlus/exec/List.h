#ifndef APP_List_H
#define APP_List_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/exec/List.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


extern "C" {
#ifdef __GNUG__
#include <inline/exec.h>
#include <clib/alib_protos.h>
#endif

#ifdef __SASC
#include <proto/exec.h>
#endif

#include <exec/lists.h>
}


class MinListC;

class MinNodeC : private MinNode
{
   friend class MinListC;
   public:
      MinNodeC();
      virtual ~MinNodeC();

      MinNodeC* succ() const
         { return (MinNodeC*)(mln_Succ->mln_Succ==NULL?NULL:mln_Succ); }
      MinNodeC* pred() const
         { return (MinNodeC*)(mln_Pred->mln_Pred==NULL?NULL:mln_Pred); }
      void remove();    // can be called at any time and results in a lonely node
      BOOL isLonelyNode() const
         { return (succ()==this); }

      virtual BOOL applyMinNodeC(void* any);    // your subclass should overwrite this
      MinListC* findList(void) const;     // get the MinListC object that this is linked to.

   private:
      /* set a node to a state when its repeated remove cannot cause pointer trash.
       * (succ and pred point to the node itself, so Remove() cannot afflict other memory)
       */
      void neutralize()
         { mln_Succ = mln_Pred = this; }

};


void MinListC__Destruct(MinListC* list);
BOOL MinListC__Member(const MinListC* list,const MinNodeC* find);
MinNodeC* MinListC__RemoveSafely(MinListC* list,MinNodeC* node);


class MinListC : private MinList
{
   public:
      MinListC();
      virtual ~MinListC();

      BOOL empty() const
         { return (mlh_Head->mln_Succ==0); }
      BOOL isEmpty() const
         { return empty(); }
      MinNodeC* head() const
         { return (MinNodeC*)( empty() ? NULL : mlh_Head ); }
      MinNodeC* tail() const
         { return (MinNodeC*)( empty() ? NULL : mlh_TailPred ); }

      void addHead(MinNodeC* node)
         { AddHead((List*)(MinList*)this,(Node*)(MinNode*)node); }
      void addTail(MinNodeC* node)
         { AddTail((List*)(MinList*)this,(Node*)(MinNode*)node); }

      MinNodeC* remHead();
      MinNodeC* remTail();

      BOOL member(MinNodeC* node) const
         { return MinListC__Member(this,node); }
      MinNodeC* remove(MinNodeC* node)
         { return MinListC__RemoveSafely(this,node); }
      void insert(MinNodeC* node,MinNodeC* pred);  // insert new node before pred

      BOOL apply(void* any);
      // run the applyMinNodeC on all list nodes with <any> as parameter.
      // Stops if applyNodeC returned FALSE, and returns FALSE!!! else returns TRUE.
};

class ListC;

class NodeC : private Node
{
   public:
      NodeC(BYTE pri = 0, UBYTE type = NT_USER);
      NodeC(BYTE pri, const UBYTE* name = 0, UBYTE type = NT_USER);
      NodeC(const UBYTE* name, UBYTE type = NT_USER);
      virtual ~NodeC();         // removes node from any list

      NodeC* succ() const
         { return (NodeC*)(ln_Succ->ln_Succ==NULL?NULL:ln_Succ); }
      NodeC* pred() const
         { return (NodeC*)(ln_Pred->ln_Pred==NULL?NULL:ln_Pred); }
      void remove()
         { Remove((Node*)this); neutralize(); }
      BOOL isLonelyNode() const
         { return (ln_Succ==this); }

      virtual BOOL applyNodeC(void* any);       // your subclass should overwrite this

      BYTE priority() const
         { return ln_Pri; }              // read priority
      void setPriority(BYTE pri)
         { ln_Pri = pri; }    // write priority

      const UBYTE* name() const
         { return (UBYTE*)ln_Name; }      // read name
      void setName(const UBYTE* set_name)
         { ln_Name = (char*)set_name; }   // write name

      UBYTE type() const
         { return ln_Type; }    // read type
      void setType(UBYTE type)
         { ln_Type = type; }    // write type

      UBYTE& type_ref()
         { return ln_Type; }

      ListC* findList() const
         { return (ListC*) ((MinNodeC*)(List*)this)->findList(); }

      //operator MinNodeC* () { return (MinNodeC*)(MinNode*)(Node*)this; }

   protected:
      UBYTE*& name_ref() { return (UBYTE*&)ln_Name; }

   private:
      void neutralize() { ln_Succ = ln_Pred = this; }
      void init(BYTE pri, const UBYTE* name, UBYTE type);
};


/**********************************************************************************************
         » ListC class «
   encapsulates the EXEC list.
 **********************************************************************************************/
class ListC : private List
{
   public:
      ListC(UBYTE type = 0);
      virtual ~ListC();

      BOOL empty() const
         { return (lh_Head->ln_Succ==0); }
      BOOL isEmpty() const
         { return empty(); }     // synonym for empty()
      NodeC* head() const
         { return (NodeC*)( empty() ? NULL : lh_Head ); }
      NodeC* tail() const
         { return (NodeC*)( empty() ? NULL : lh_TailPred ); }

      ListC& addHead(NodeC* node)
         { AddHead((List*)this,(Node*)node); return *this; }
      ListC& addTail(NodeC* node)
         { AddTail((List*)this,(Node*)node); return *this; }
      ListC& enqueue(NodeC* node)
         { Enqueue((List*)this,(Node*)node); return *this; }
      void insert(NodeC* node,NodeC* pred);  // insert new node before pred
      NodeC* remHead()
         { return (NodeC*) ((MinListC*)this)->remHead(); }
      NodeC* remTail()
         { return (NodeC*) ((MinListC*)this)->remTail(); }
      NodeC* remove(NodeC* node)
         { return (NodeC*)MinListC__RemoveSafely((MinListC*)this,(MinNodeC*)node); }

      BOOL member(NodeC* node) const
         { return MinListC__Member((MinListC*)this,(MinNodeC*)node); }
      NodeC* findName(const UBYTE* name) const
         { return (NodeC*)FindName((List*)this,(UBYTE*)name); }

      BOOL apply(void* any);
};


inline void MinListC::insert(MinNodeC* node,MinNodeC* pred)
{
   if (!member(node) && member(pred))  // must not insert already inserted node or behind non-member!
      Insert((List*)this,(Node*)node,(Node*)pred);
}

inline void ListC::insert(NodeC* node,NodeC* pred)
{
   if (!member(node) && member(pred))  // must not insert already inserted node or behind non-member!
      Insert((List*)this,(Node*)node,(Node*)pred);
}

/** Give your node type and a pointer to your list and you will get a pointer "node" to
 ** your node type in the subsequent loop body. Of course your node type must be derived
 ** from MinNode or Node class as must your list be derived from MinList or List class.
 ** This loop does NOT allow to delete the node object within the loop, since the successor
 ** could not be read from an invalid node! Also FOREACHOF() within another FOREACHOF loop
 ** shadows the first node. Instead use the macro with explicit variable name.
 ** This hides the type conflict with the return type of the list classes in the absence of
 ** parameterized classes (templates). As soon as templates are available all list classes
 ** will be doubled with template classes.
 **/
#define FOREACHOF(type,list) for(type* node=(type*)((list)->head());node;node=(type*)node->succ())
#define FOREACHOFNAME(type,list,node) for(type* node=(type*)((list)->head());node;node=(type*)node->succ())


/** This loop allows deleting the object addressed in 'node'.
 ** Add NEXTSAFE behind your loop body (behind the closing brace if there is one)
 **/
#define FOREACHSAFE(type,list) for(type* node=(type*)((list)->head()),*next=NULL; \
                                 node;node=next) \
                               { next=(type*)node->succ();

#define NEXTSAFE }

#endif   /* APP_List_H */
