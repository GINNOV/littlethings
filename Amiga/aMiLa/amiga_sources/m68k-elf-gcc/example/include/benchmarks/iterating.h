/*
 * iterating.h
 *
 *  Created on: 13.06.2019
 *      Author: andre
 */

#ifndef ITERATING_H_
#define ITERATING_H_

#include "benchmark.h"
#include <array>
#include <list>
#include <vector>

constexpr int numberOfElements = 1000;

class benchmark_iterating : public benchmark
{
  private:
	int arraySum_ppi();
	int arraySum_ipp();
	int arraySum_rangeloop();
	int vectorSum_rangeloop();
	int vectorSum_foreach();
	int vectorSum_iterator();
	int vectorSum_accumulate();
	int listSum_rangeloop();
	int listSum_iterator();
	int callCFunc();
	int callCppFunc();
	int callCFuncCppFootprint();

	int nums[numberOfElements];
	std::array<int, numberOfElements> cpparraynums;
	std::vector<int> vecnums;
	std::list<int> listnums;

  public:
	void execute(FILE* f);
};

#endif /* ITERATING_H_ */
