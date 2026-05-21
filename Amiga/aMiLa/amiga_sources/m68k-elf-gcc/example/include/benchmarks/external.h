/*
 * external.h
 *
 *  Created on: 06.07.2019
 *      Author: andre
 */

#ifndef INCLUDE_BENCHMARKS_EXTERNAL_H_
#define INCLUDE_BENCHMARKS_EXTERNAL_H_

class incrementer
{
  public:
	void increment();
};

void c_increment();
void c_increment_cppFootprint(void* this_);

#endif /* INCLUDE_BENCHMARKS_EXTERNAL_H_ */
