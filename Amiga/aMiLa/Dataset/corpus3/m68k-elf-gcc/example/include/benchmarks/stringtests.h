/*
 * strings.h
 *
 *  Created on: 13.06.2019
 *      Author: andre
 */

#ifndef STRINGTESTSS_H_
#define STRINGTESTSS_H_

#include "benchmark.h"

#ifndef DISABLE_STREAMCLASS
#include <iostream>
#include <sstream>
#include <string>
#endif

class benchmark_strings : public benchmark
{
  private:
#ifndef DISABLE_STREAMCLASS
	std::stringstream cppstrstr;
	void stringstream_build();
#endif

	static int nums[4];

	char strAr[100];
	void carr_build();

  public:
	void execute(FILE* f);
};

#endif /* STRINGTESTSS_H_ */
