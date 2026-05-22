//////////////////////////////////////////////////////////////////////////////
// ptrdlist.cpp
//
// Jeffry A Worth
// January 26, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/ptrdlist.hpp"

//////////////////////////////////////////////////////////////////////////////
// AFPtrDlist Class
AFPtrDlist::AFPtrDlist()
	:m_head(NULL),
	m_tail(NULL),
	m_entries(0)
{
}

AFPtrDlist::~AFPtrDlist()
{
	cleanAndDestroy();
}

BOOL
AFPtrDlist::append(AFObject* ptr)
{
	AFNode *node, *temp;

	if(node = new AFNode(ptr)) {
		node->prev(temp=m_tail);
		m_tail=node;
		if(temp)
			temp->next(node);
		if(!m_head)
			m_head=m_tail;
		m_entries++;
		ptr->m_node = node;
		return TRUE;
	}
	return FALSE;
}

BOOL
AFPtrDlist::prepend(AFObject* ptr)
{
	AFNode *node, *temp;

	if(node = new AFNode(ptr)) {
		node->next(temp=m_head);
		m_head=node;
		if(temp)
			temp->prev(node);
		if(!m_tail)
			m_tail=m_head;
		m_entries++;
		ptr->m_node=node;
		return TRUE;
	}
	return FALSE;
}

BOOL
AFPtrDlist::isEmpty()
{
	return(m_entries==0);
}

AFNode*
AFPtrDlist::nodeAt(ULONG index)
{
	AFNode* node;
	long i;

	if(index >= 0 && index < entries()) {
		if(index<=entries()/2) {
			node=m_head;
			for(i=0;i<index;i++)
				node=node->next();
			return node;
		} else {
			node=m_tail;
			for(i=0;i<entries()-index-1;i++)
				node=node->prev();
			return node;
		}
	}
	return NULL;
}


AFObject*
AFPtrDlist::operator[](ULONG index)
{
	AFNode* node;

	if(node=nodeAt(index))
		return node->object();
	return NULL;
}

ULONG
AFPtrDlist::entries()
{
	return m_entries;
}

void
AFPtrDlist::remove(ULONG index, BOOL deleteobject)
{
	removeNode(nodeAt(index),deleteobject);
}

void
AFPtrDlist::removeNode(AFNode* node, BOOL deleteobject)
{
	AFNode *nPrev,*nNext;

	if(node) {
		nPrev=node->prev();
		nNext=node->next();

		if(nNext) {
			nNext->prev(nPrev);
		}		
		if(nPrev) {
			nPrev->next(nNext);
		}
		if(m_head==node)
			m_head=nNext;
		if(m_tail==node)
			m_tail=nPrev;

		m_entries--;

		if(deleteobject) {
			node->object()->DestroyObject();
			delete node->object();
		} else
			node->object()->m_node=NULL;

		delete node;
	}
	
}

void
AFPtrDlist::cleanAndDestroy()
{
	while(!isEmpty())
		remove(0,TRUE);
}
