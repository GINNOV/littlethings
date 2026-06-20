/*
 * stringtests.cpp
 *
 *  Created on: 13.06.2019
 *      Author: andre
 */

#include "multiplatform.h"

#include <array>
#include <list>
#include <vector>

#include <functional>
#include <iomanip>
#include <numeric>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <algorithm> //algorithm must be included latest for bebbo toolchain

#include "iterating.h"
#include "measure.h"
#include "stringtests.h"

int benchmark_strings::nums[4];

void benchmark_strings::carr_build()
{
	sprintf(strAr, "%d %d %d %d", nums[0], nums[1], nums[2], nums[3]);
}

#ifndef DISABLE_STREAMCLASS
std::stringstream cppstrstr;

void benchmark_strings::stringstream_build()
{
	cppstrstr << nums[0] << " " << nums[1] << " " << nums[2] << " " << nums[3];
}

#endif

void benchmark_strings::execute(FILE* out)
{
	const struct
	{
		std::function<void(benchmark_strings&)> func;
		const char* name;
	} stringtests[] = {
		{&benchmark_strings::carr_build, "sprintf"},
#ifndef DISABLE_STREAMCLASS
		{&benchmark_strings::stringstream_build, "c++ stringstream build"},
#endif
	};

	// prepare the tests

	size_t i;
	for (i = 0; i < 4; i++)
	{
		nums[i] = rand();
	}

	fprintf(out, "Construct strings from 4 integers\n");

	for (auto i : stringtests)
	{
		measure_start();
		i.func(*this);
		measure_end();
		fprintf(out, "%30s %6d us\n", i.name, (int)elapsedTime);
	}

#ifndef DISABLE_STREAMCLASS
	if (strcmp(cppstrstr.str().c_str(), strAr))
	{
		fprintf(out, "String failure!\n");
	}
	else
	{
		fprintf(out, "Strings ok\n");
	}
#endif

	fprintf(out, "\n");
}
