#ifndef APP_PriorityList_H
#define APP_PriorityList_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/exec/PriorityList.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/exec/List.h>


/******************************************************************************
   
      » PriorityNode class «

   is derived from NodeC but hides direct priority setting to prevent from 
   messing up the order of the PriorityList.
   
 ******************************************************************************/
class PriorityList;

class PriorityNode : private NodeC
{
   friend class PriorityList;
   public:
      // all constructor parameter combinations are possible
      PriorityNode(const UBYTE* name = 0,UBYTE type = NT_USER);
      PriorityNode(UBYTE type);

      PriorityNode *succ() const
         { return (PriorityNode*)NodeC::succ(); }
      PriorityNode *pred() const
         { return (PriorityNode*)NodeC::pred(); }

      // make selected private NodeC::functions public again
      NodeC::name;
      NodeC::setName;
      NodeC::type;
      NodeC::setType;
      NodeC::type_ref;
      NodeC::priority;
      NodeC::applyNodeC;
      NodeC::remove;
      NodeC::isLonelyNode;

   protected:
      NodeC::name_ref;
};

/**********************************************************************************************
      » PriorityList class «
   hides the ListC methods which could mess up the sorting
 **********************************************************************************************/
class PriorityList : private ListC
{
   friend class PriorityNode;
   public:
      PriorityList(UBYTE type = 0);

      PriorityNode *head() const
         { return (PriorityNode*)ListC::head(); }
      PriorityNode *tail() const
         { return (PriorityNode*)ListC::tail(); }

      PriorityNode *remHead()
         { return (PriorityNode*)ListC::remHead(); }
      PriorityNode *remTail()
         { return (PriorityNode*)ListC::remTail(); }
      PriorityNode *remove(PriorityNode *node)
         { return (PriorityNode*)ListC::remove(node); }

      ListC::apply;
      ListC::empty;
      ListC::isEmpty;

      BOOL member(PriorityNode *node) const
         { return ListC::member((NodeC*)node); }

      void enqueue(PriorityNode *node,BYTE pri);

      PriorityNode *findName(const UBYTE* name) const
         { return (PriorityNode*)ListC::findName(name); }

      // change node priority and thereby place
      BYTE changePri(PriorityNode *node,BYTE pri)
         { if (member(node)) return internalChangePri(node,pri); else return 0; }

   private:
      BYTE internalEnqueue(PriorityNode *node,BYTE pri);
      BYTE internalChangePri(PriorityNode *node,BYTE pri);
};


inline void PriorityList::enqueue(PriorityNode *node,BYTE pri)
{
   if (member(node))   // must not enqueue already enqueued node
      internalChangePri(node,pri);  // dequeue member, then enqueue again
   else
      internalEnqueue(node,pri);
}

#endif   /* APP_PriorityList_H */
