/*
 * allocate.h
 *
 *  Created on: 13.06.2019
 *      Author: andre
 */

#ifndef ALLOCATE_H_
#define ALLOCATE_H_

#include "benchmark.h"

class benchmark_allocate : public benchmark
{
  private:
	void c_pointer();
	void cpp_pointer();
	void cpp_unique();
	void cpp_shared();
	void cpp_vectorUnique();
	void cpp_vectorUnique_reserved();
	void cpp_vectorUnique_presized();
	void cpp_listUnique();
	void cpp_arrayUnique();

	int numberOfAllocations;
	int sizeOfBlock;

  public:
	void execute(FILE* f);

	benchmark_allocate()
	{
		numberOfAllocations = 100;
		sizeOfBlock			= 4;
	}

	benchmark_allocate(int allocs, int elemsize)
	{
		numberOfAllocations = allocs;
		sizeOfBlock			= elemsize;
	}
};

#endif /* ALLOCATE_H_ */
