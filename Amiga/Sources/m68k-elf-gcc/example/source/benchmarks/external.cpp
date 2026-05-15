/*
 * external.cpp
 *
 *  Created on: 06.07.2019
 *      Author: andre
 */

#include "external.h"

volatile int a = 0;

void incrementer::increment()
{
	a++;
}

void c_increment()
{
	a++;
}

void c_increment_cppFootprint(void* this_)
{
	a++;
}
