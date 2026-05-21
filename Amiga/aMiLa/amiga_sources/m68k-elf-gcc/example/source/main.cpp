/*
 * main.cpp
 *
 *  Created on: 22.06.2019
 *      Author: andre
 */

#include "config.h"

#ifndef DISABLE_STREAMCLASS
#include <iostream>
#endif

#include "measure.h"
#include <gsl/span>
#include <iomanip>
#include <list>
#include <malloc.h>
#include <numeric>
#include <stdio.h>
#include <stdlib.h>
#include <vector>

#include <algorithm> //algorithm must be included latest for bebbo toolchain

#include "allocate.h"
#include "iterating.h"
#include "stringtests.h"

extern "C"
{
#include "gdb-m68k-stub.h"
#include "uart.h"
}

#if defined(AMIGACROSS) && !defined(BUILD_FOR_AMIGADOS)
/*
 * FIXME I'm quite confused why this is needed. As it seems this is normally done
 * by libgcc and crtbegin.o inside of that lib. But I have the feeling that libgloss
 * which also provides crt0.o is not compatible with crtbegin.o.
 * While the .ctors segment seems to be correct the .init segment is not and the system will crash.
 * I'm not sure why this happens. So until then global C++ constructors must be called by manually
 * processing .ctors after main is called.
 * Usually this would happen before main is called.
 */
void staticConstructors()
{
	extern uint32_t __CTOR_LIST__;

	uint32_t* ptr = &__CTOR_LIST__;
	ptr++; // skip number of pointers

	while (*ptr)
	{
		void (*func)() = (void (*)()) * ptr;
		// printf("Execute static constructor %lx\n", *ptr);
		func();

		ptr++;
	}
}

// FIXME Why is this needed?
void* __dso_handle;

#endif

template <size_t SIZE> void printArray(std::array<int, SIZE>& arr)
{
	for (auto i : arr)
	{
		printf("%d ", i);
	}
	printf("\n");
}

void printArray2(gsl::span<int> arr)
{
	for (auto i : arr)
	{
		printf("%d ", i);
	}
	printf("\n");
}

int main(int argc, char** argv)
{
	// set_debug_traps();
#if defined(AMIGACROSS) && !defined(BUILD_FOR_AMIGADOS)
	staticConstructors();
#endif

	printf("Slamy's Litte C vs C++ Benchmark\n");

	std::array<int, 10> a{{1, 2, 3, 4}};
	std::array<int, 5> b{{1, 2, 3, 4}};
	std::array<int, 6> c{{1, 2, 3, 4}};
	std::array<int, 100> d{{1, 2, 3, 4}};
	printArray(a);
	printArray(b);
	printArray(c);
	printArray(d);
	printArray2(a);
	printArray2(b);
	printArray2(c);
	printArray2(d);
	return 0;
#ifdef BUILD_FOR_AMIGADOS
	FILE* out = fopen("results.txt", "w");
	printf("Please find the results in results.txt\n");
#else
	FILE* out = stdout;
#endif

	std::vector<std::unique_ptr<benchmark>> bmarks;

	bmarks.push_back(std::make_unique<benchmark_allocate>(50, 4));
	bmarks.push_back(std::make_unique<benchmark_allocate>(50, 64));
	bmarks.push_back(std::make_unique<benchmark_strings>());
	bmarks.push_back(std::make_unique<benchmark_iterating>());

	std::for_each(bmarks.begin(), bmarks.end(), [out](auto& i) { i->execute(out); });

	printMemoryUsage();

	return 0;
}

// FIXME can this be removed?
// Sorgt dafür, dass exception demangling nicht eingelinkt wird!
// https://developer.mbed.org/forum/platform-32-ST-Nucleo-L152RE-community/topic/4802/?page=2#comment-25593
namespace __gnu_cxx
{
void __verbose_terminate_handler()
{
	for (;;)
		;
}
} // namespace __gnu_cxx
extern "C" void __cxa_pure_virtual(void);
extern "C" void __cxa_pure_virtual(void)
{
	for (;;)
		;
}
