//////////////////////////////////////////////////////////////////////////////
// iterator.cpp
//
// Jeffry A Worth
// January 28, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES

#include "aframe:include/iterator.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFPtrDlistIterator::AFPtrDlistIterator(AFPtrDlist& list)
	:m_list(&list),
	m_key(NULL),
	m_index(0)
{
}

void
AFPtrDlistIterator::reset()
{
	m_index=0;
	m_key=NULL;
}

BOOL
AFPtrDlistIterator::operator++()
{
	if(m_key)
		return((m_key=(*m_list)[++m_index])!=NULL);
	return((m_key=(*m_list)[m_index=0])!=NULL);
}

BOOL
AFPtrDlistIterator::operator--()
{
	if(m_key)
		return((m_key=(*m_list)[--m_index])!=NULL);
	return((m_key=(*m_list)[m_index=m_list->entries()-1])!=NULL);
}

BOOL
AFPtrDlistIterator::removeKey()
{
	if(m_key) {
		m_list->remove(m_index,TRUE);
		if(m_index>0)
			m_index--;
		return((m_key=(*m_list)[m_index])!=NULL);
	}
	return FALSE;
}


AFObject*
AFPtrDlistIterator::key()
{
	return m_key;
}
