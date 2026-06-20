/* hexify.h
 * Copyright (C) 2015 Jason Pepas.
 * See https://github.com/pepaslabs/hexify.c
 * Released under the terms of the MIT license.
 * See https://opensource.org/licenses/MIT
 */

#ifndef HEXIFY_H
#define HEXIFY_H

#include <stddef.h> // size_t, etc.


// translate the binary data from 'in' as a hexidecimal string into 'out'.
// 'out_size' is the size of 'out' (including room for the trailing '\0').
// returns the number of hexidecimal bytes written (not including the trailing '\0').
int hexify(unsigned char *in, size_t in_size, char *out, size_t out_size);


#endif // HEXIFY_H
