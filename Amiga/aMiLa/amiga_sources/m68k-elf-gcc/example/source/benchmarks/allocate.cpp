/*
 * allocate.cpp
 *
 *  Created on: 13.06.2019
 *      Author: andre
 */

#include "multiplatform.h"

#include "math.h"
#include <array>
#include <functional>
#include <iomanip>
#include <list>
#include <memory>
#include <numeric>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

#include <algorithm> //algorithm must be included latest for bebbo toolchain

#include "measure.h"
#include <allocate.h>

void benchmark_allocate::c_pointer()
{
	int i;
	int* pointers[numberOfAllocations];

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers[i] = (int*)malloc(sizeof(int) * sizeOfBlock);
		if (pointers[i] == NULL)
		{
			printf("Failed to allocate memory\n");
			exit(1);
		}
	}

	for (i = 0; i < numberOfAllocations; i++)
		free(pointers[i]);
}

void benchmark_allocate::cpp_pointer()
{
	int i;
	int* pointers[numberOfAllocations];

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers[i] = new int[sizeOfBlock];
		if (pointers[i] == NULL)
		{
			printf("Failed to allocate memory\n");
			exit(1);
		}
	}

	for (i = 0; i < numberOfAllocations; i++)
		delete[] pointers[i];
}

void benchmark_allocate::cpp_unique()
{
	int i;
	std::unique_ptr<int[]> pointers[numberOfAllocations];

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers[i] = std::make_unique<int[]>(sizeOfBlock);
	}
}

// std::make_shared<int[]> doesn't seems to be yet implemented in the GCC version of bebbo toolchain
#ifndef BUILD_FOR_AMIGADOS
void benchmark_allocate::cpp_shared()
{
	int i;
	std::shared_ptr<int[]> pointers[numberOfAllocations];

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers[i] = std::make_shared<int[]>(sizeOfBlock);
	}
}
#endif

void benchmark_allocate::cpp_vectorUnique()
{
	int i;
	std::vector<std::unique_ptr<int[]>> pointers;

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers.push_back(std::make_unique<int[]>(sizeOfBlock));
	}
}

void benchmark_allocate::cpp_vectorUnique_reserved()
{
	int i;
	std::vector<std::unique_ptr<int[]>> pointers;
	pointers.reserve(numberOfAllocations);

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers.push_back(std::make_unique<int[]>(sizeOfBlock));
	}
}

void benchmark_allocate::cpp_vectorUnique_presized()
{
	int i;
	std::vector<std::unique_ptr<int[]>> pointers(numberOfAllocations);

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers.at(i) = std::make_unique<int[]>(sizeOfBlock);
	}
}

void benchmark_allocate::cpp_listUnique()
{
	int i;
	std::list<std::unique_ptr<int[]>> pointers;

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers.push_back(std::make_unique<int[]>(sizeOfBlock));
	}
}

// FIXME size of std::array cannot be defined with a dynamic size like the normal C array can do?
void benchmark_allocate::cpp_arrayUnique()
{
	int i;
	std::array<std::unique_ptr<int[]>, 50> pointers;

	for (i = 0; i < numberOfAllocations; i++)
	{
		pointers[i] = std::make_unique<int[]>(sizeOfBlock);
	}
}

struct testEntry
{
	std::function<void(benchmark_allocate&)> func;
	const char* name;
	float result;
};

void benchmark_allocate::execute(FILE* out)
{
	std::vector<struct testEntry> tests{{
		{&benchmark_allocate::c_pointer, "c array of malloc'd pointers"},
		{&benchmark_allocate::cpp_pointer, "c array of new'd pointers"},
		{&benchmark_allocate::cpp_unique, "c array of unique pointers"},
		{&benchmark_allocate::cpp_vectorUnique_reserved, "reserve c++ vector of unique pointers"},
		{&benchmark_allocate::cpp_vectorUnique_presized, "presized c++ vector of unique pointers"},
#ifndef BUILD_FOR_AMIGADOS
		{&benchmark_allocate::cpp_shared, "c array of shared pointers"},
#endif
		{&benchmark_allocate::cpp_vectorUnique, "empty c++ vector of unique pointers"},
		{&benchmark_allocate::cpp_listUnique, "c++ list of unique pointers"},
		{&benchmark_allocate::cpp_arrayUnique, "c++ array of unique pointers"},

	}};

	fprintf(out, "Allocate %d int arrays of size %d and manage them\n", numberOfAllocations, sizeOfBlock);

	bool first = true;
	float firstElapsedTime;

	for (auto& i : tests)
	{
		measure_start();
		i.func(*this);
		measure_end();
		i.result = elapsedTime;
	}

	std::sort(tests.begin(), tests.end(), [](auto& a, auto& b) { return a.result < b.result; });

	for (auto& i : tests)
	{
		if (first)
		{
			first			 = false;
			firstElapsedTime = i.result;
		}

		float scaling = roundf((i.result / firstElapsedTime) * 100.0f);
		fprintf(out, "%40s %6d us %6d%%\n", i.name, (int)i.result, (int)scaling);
	}

	fprintf(out, "\n");
}
