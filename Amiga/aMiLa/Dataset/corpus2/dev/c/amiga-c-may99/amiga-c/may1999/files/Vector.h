#ifndef VECTOR_H
#define VECTOR_H
/*
 * Vector.h -- Vector class template header file
 *
 * The Vector class template is used to replace a standard array.  It will
 * grow automatically to accomodate its members.  Random access to members
 * of a Vector is efficient.  Inserting and removing members of a Vector is
 * expensive.
 */

#include <exec/memory.h>
#include <proto/exec.h>


const ULONG INIT_VECTOR_CAPACITY		= 16;	// initial capacity
const ULONG VECTOR_CAPACITY_INCREMENT	= 16;	// capacity increment


template<class T> class Vector {
public:
	Vector(ULONG init_capacity = INIT_VECTOR_CAPACITY) throw (bad_alloc);
	~Vector();
	ULONG GetSize() const;
	void AddItem(T* data) throw (bad_alloc);
	void RemoveItem(T* data);
	void RemoveItem(ULONG i);
	T* operator [](ULONG i);
	void ClearVector();
private:
	T** vector;
	ULONG capacity;
	ULONG size;
};


/*
 * Vector -- Constructor
 *
 * Initializes the object to its default state.  The initial capacity
 * of the vector can be specified if it can be anticipated.
 */
template<class T> Vector<T>::Vector(ULONG init_capacity)
{
	vector = (T**)AllocMem(init_capacity * sizeof(T*), MEMF_ANY);
	if ( vector == NULL )
		throw bad_alloc();

	size = 0;
	capacity = init_capacity;
}


/*
 * ~Vector -- Destructor
 *
 * Frees any object allocated resources.
 */
template<class T> Vector<T>::~Vector()
{
	FreeMem((APTR)vector, capacity * sizeof(T*));
}


/*
 * GetSize -- Get size
 *
 * Returns the size or number of elements in the vector.
 */
template<class T> ULONG Vector<T>::GetSize()
{
	return size;
}


/*
 * AddItem -- Add item
 *
 * Adds an item to the vector.  The vector size will be increased as
 * required.
 */
template<class T> void Vector<T>::AddItem(T* data)
{
	if ( size == capacity )  {
		const ULONG new_capacity = capacity + VECTOR_CAPACITY_INCREMENT;
		T** new_vector = (T**)AllocMem(new_capacity * sizeof(T*), MEMF_ANY);
		if ( new_vector == NULL )
			throw bad_alloc();

		CopyMemQuick((APTR)vector, (APTR)new_vector, capacity * sizeof(T*));
		FreeMem((APTR)vector, capacity * sizeof(T*));
		vector = new_vector;
		capacity = new_capacity;
	}

	vector[size] = data;
	size++;
}


/*
 * RemoveItem -- Remove item
 *
 * Removes an item from the vector.
 */
template<class T> void Vector<T>::RemoveItem(T* data)
{
	for ( ULONG i = 0; i < size; ++i )  {
		if ( vector[i] == data )
			break;
	}

	RemoveItem(i);
}

template<class T> void Vector<T>::RemoveItem(ULONG i)
{
	if ( i >= size )
		return;

	while ( i < size - 1 )  {
		vector[i] = vector[i + 1];
		++i;
	}

	--size;
}


/*
 * operator [] -- Subscript item
 *
 * Returns an object pointer to the subscripted item.
 */
template<class T> T* Vector<T>::operator [](ULONG i)
{
	return vector[i];
}


/*
 * Clear -- Clear vector
 *
 * Clears the vector of its all items.
 */
template<class T> void Vector<T>::ClearVector()
{
	size = 0;
}


#endif
