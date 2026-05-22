/*
 * benchmark.h
 *
 *  Created on: 22.06.2019
 *      Author: andre
 */

#ifndef INCLUDE_BENCHMARKS_BENCHMARK_H_
#define INCLUDE_BENCHMARKS_BENCHMARK_H_

#include <stdio.h>

class benchmark
{
  public:
	virtual void execute(FILE* f){};
	benchmark()
	{
	}

	virtual ~benchmark()
	{
	}
};

#endif /* INCLUDE_BENCHMARKS_BENCHMARK_H_ */
