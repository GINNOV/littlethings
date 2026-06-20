//////////////////////////////////////////////////////////////////////////////
// ptrdlist.hpp
//
// Jeffry A Worth
// January 26, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __PTRDLIST_HPP__
  #define __PTRDLIST_HPP__

  #include <exec/types.h>
  #include "aframe:include/node.hpp"
  #include "aframe:include/object.hpp"


  //////////////////////////////////////////////////////////////////////////////
  // PtrDlist Class

  class AFPtrDlist : public AFObject
  {
	public:
		AFPtrDlist();
		~AFPtrDlist();

		BOOL append(AFObject* ptr);
		BOOL prepend(AFObject* ptr);
		BOOL isEmpty();
		AFNode* nodeAt(ULONG index);
		AFObject* operator[](ULONG index);
		ULONG entries();
		void remove(ULONG index, BOOL deleteobject);
		void removeNode(AFNode* node, BOOL deleteobject);
		void cleanAndDestroy();
  
	private:
		AFNode* m_head;
		AFNode* m_tail;
		ULONG m_entries;
  };

//////////////////////////////////////////////////////////////////////////////
#endif // __PTRDLIST_HPP__
