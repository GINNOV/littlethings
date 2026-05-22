#ifndef APP_ObjectList_H
#define APP_ObjectList_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: ObjectList.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include "APlusPlus/exec/PriorityList.h"


/******************************************************************************

         » ReferenceNode class «

   uses the NodeC class as storage for a pointer to any type of object. 
   The object address will be stored in the name field of NodeC and a type 
   can be given for identifying later.
   
 ******************************************************************************/
class ReferenceNode : public PriorityNode
{
   public:
      ReferenceNode(APTR object, UBYTE type = NT_USER);

      ReferenceNode *succ()
         { return (ReferenceNode*)PriorityNode::succ(); }
      ReferenceNode *pred()
         { return (ReferenceNode*)PriorityNode::pred(); }

      APTR& object()
         { return (APTR&)name_ref(); }    // returns the object address as reference!
      BYTEBITS& flags()
         { return (BYTEBITS)PriorityNode::type_ref(); }
};

class ReferenceList : public PriorityList
{
   public:
      ReferenceList(UBYTE type = 0);

      ReferenceNode *head()
         { return (ReferenceNode*)PriorityList::head(); }
      ReferenceNode *tail()
         { return (ReferenceNode*)PriorityList::tail(); }

      ReferenceNode *remHead()
         { return (ReferenceNode*)PriorityList::remHead(); }
      ReferenceNode *remTail()
         { return (ReferenceNode*)PriorityList::remTail(); }
      ReferenceNode *remove(ReferenceNode *node)
         { return (ReferenceNode*)PriorityList::remove(node); }

      ReferenceNode *findObject(APTR objectptr,UBYTE type = 0);
      // find the Node with the given address stored in from the given type.
      // At least one argument must be specified, the other can be null and
      // is not used for the match.
};

/**********************************************************************************************
         » TObjNode class & TObjList class «

   uses the Reference classes and have basically the same useability. But the nodes are
   traced from the List and will be deleted when the TObjList is to be deleted.
   Therefore TObjNodes MUST NOT BE CREATED ON STACK but dynamically with the new operator!!
   That makes the virtual TObjNode destructor really important. Own classes can be derived
   with own destructors and the programmer needs not to care about their correct deletion.
   As it is for all Node/MinNode-derived classes a node can be deleted safely with its own
   remove() method, even if it is not linked into a list!
 **********************************************************************************************/

class TObjNode : public ReferenceNode
{
   public:
      TObjNode(APTR object, UBYTE type = NT_USER);
};

class TObjList : public ReferenceList  // Traced objects list
{
   public:
      TObjList(UBYTE type = 0);
      ~TObjList();   // DELETE all nodes (so nodes MUST be dynamically allocated via new()

      TObjNode *findObject(APTR object,UBYTE type = 0)
         { return (TObjNode*)ReferenceList::findObject(object,type); }

      void deleteTObj(APTR obj);  // search for a reference to obj and delete the node
};

#endif   /* APP_ObjectList_H */
