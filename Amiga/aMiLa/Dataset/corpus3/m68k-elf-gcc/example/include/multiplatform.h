/*
 * multiplatform.h
 *
 *  Created on: 02.12.2018
 *      Author: andre
 */

#ifndef INCLUDE_MULTIPLATFORM_H_
#define INCLUDE_MULTIPLATFORM_H_

#include "config.h"

#ifdef BUILD_FOR_AMIGADOS
#define PRINTF uart_printf
#define ASSERT uart_assert
void waitForVBlank();

extern volatile struct Custom* mycustom;
extern volatile struct CIA* myciaa;

#define custom mycustom
#define ciaa myciaa

#else
#define PRINTF uart_printf
#define ASSERT uart_assert

extern volatile struct Custom* const custom;
extern volatile struct CIA* const ciaa;

#endif

#endif /* INCLUDE_MULTIPLATFORM_H_ */
