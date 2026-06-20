
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta, Sean O' Neil
    tksuoran@cc.helsinki.fi, soneil@home.com

		Adapted from

		The Universe Development Kit
		Copyright (C) 2000  Sean O'Neil
		soneil@home.com

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\class   MemoryBlock
	\ingroup g_sys_support
	\author  Sean O'Neil
	\brief   Memory Management class
	\date    2000, 2001
*/


#ifndef TEDDY_SYS_SUPPORT_MEMORY_BLOCK_H
#define TEDDY_SYS_SUPPORT_MEMORY_BLOCK_H


#include <cstring>


namespace SysSupport {


//#define RELEASE(a){ if(a) { a->Release(); a = NULL; } }


class MemoryBlock {
public:
	MemoryBlock(){
		elements      = 0;
		element_size  = 0;
		pool          = NULL;
		free_stack    = NULL;
		free_position = 0;
	}

	MemoryBlock( int elements, int element_size ){
		pool       = NULL;
		free_stack = NULL;
		init( elements, element_size );
	}

	~MemoryBlock(){
		cleanup();
	}

	void cleanup(){
		if( free_stack != NULL ){
			delete (char*)(free_stack);
			free_stack = NULL;
		}

		if( pool != NULL ){
			delete (char*)(pool);
			pool = NULL;
		}
	}

	void init( int elements, int element_size ){
		cleanup();
		elements     = elements;
		element_size = element_size;
		pool         = new char[elements * element_size];
		//		TRACE("CMemoryBlock::Init() allocating %d bytes.\n", nElements * nElementSize);
		free_stack   = new void *[elements];
		for( free_position = 0; free_position < elements; free_position++ ){
			free_stack[free_position] = (void *)( (int)pool + free_position * element_size );
		}
	}

	int getElementSize     (){ return element_size;  }
	int getFreeElementCount(){ return free_position; }

	void *getElement(){
		void *block = NULL;
		if( free_position ){
			block = free_stack[--free_position];
		}
		return block;
	}

	void releaseElement( void *block ){
		free_stack[free_position++] = block;
	}

protected:
	int    elements;
	int    element_size;
	void  *pool;
	void **free_stack;
	int    free_position;
};


};  //  namespace SysSupport


#endif  //  TEDDY_SYS_SUPPORT_MEMORY_BLOCK_H

