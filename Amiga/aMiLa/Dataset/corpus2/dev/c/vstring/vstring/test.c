/*
 * vstring: https://github.com/dhobsd/vstring
 *
 * Copyright 2014 Devon H. O'Dell <devon.odell@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#include "vstring.h"

static uint32_t allocs, reallocs, frees;

void *
tmalloc(size_t s)
{

	void *m = malloc(s);
	allocs++;
	memset(m, 0xA, s);
	return m;
}

void *
trealloc(void *p, size_t s)
{

	reallocs++;
	return realloc(p, s);
}

void
tfree(void *p)
{

	frees++;
	free(p);
}

int
main(void)
{
	char sbuf[16];
	vstring_malloc vm;
	vstring *vs;

	vs = NULL;
	vs = vs_init(vs, NULL, VS_TYPE_STATIC, sbuf, 16);
	assert(vs_pushstr(vs, "1234567890123456", 16));
	assert(vs_finalize(vs) == false);
	vs_deinit(vs);

	vs = NULL;
	vs = vs_init(vs, NULL, VS_TYPE_GROWABLE, sbuf, 16);
	assert(vs_pushstr(vs, "1234567890123456", 16));
	assert(vs_finalize(vs));
	assert(vs->size == 32);
	assert(!memcmp(vs_contents(vs), "1234567890123456\0", 17));
	vs_deinit(vs);

	vs = NULL;
	vs = vs_init(vs, NULL, VS_TYPE_STATIC | VS_TYPE_GROWABLE, sbuf, 16);
	assert(vs_pushstr(vs, "1234567890123456", 16));
	assert(vs_finalize(vs));
	assert(vs->size == 32);
	assert(!memcmp(vs_contents(vs), "1234567890123456\0", 17));
	vs_deinit(vs);

	vs = NULL;
	vs = vs_init(vs, NULL, VS_TYPE_DYNAMIC, NULL, 0);
	assert(vs_push(vs, 'a'));
	assert(vs_pushstr(vs, "bc", 2));
	assert(vs_pushuint(vs, 10));
	assert(vs_pushint(vs, -11));
	assert(vs_padint(vs, 1, 2));
	assert(vs_pushdouble(vs, 0.12345));
	assert(vs_pushdouble(vs, NAN));
	assert(vs_pushdouble(vs, INFINITY));
	assert(vs_pushdouble(vs, -INFINITY));
	assert(vs_pushdouble(vs, 0.0));
	assert(vs_pushdouble(vs, -0.0));
	assert(vs_finalize(vs));
	//assert(!memcmp(vs_contents(vs), "abc10-11010.123450000NaNinf-inf0.000000000-0.000000000\0", vs_len(vs)));

	//printf("%s\n", vs_contents(vs));
	assert(!memcmp(vs_contents(vs), "abc10-11010.123450000NaNinf-inf0.0000000000.000000000\0", vs_len(vs)));

	vs_deinit(vs);

	vs = NULL;
	vm.vs_malloc = tmalloc;
	vm.vs_realloc = trealloc;
	vm.vs_free = tfree;
	vs = vs_init(vs, &vm, VS_TYPE_DYNAMIC, NULL, 0);
	assert(vs->type == 1);
	assert(vs->flags == VS_NEEDSFREE);
	assert(vs_len(vs) == 0);
	assert(vs_contents(vs) == NULL);
	assert(vs->size == 0);
	assert(vs_push(vs, 'a'));
	assert(vs_push(vs, 'b'));
	for (int i = vs_len(vs); i < 257; i++) {
		vs_push(vs, 'a');
	}
	vs_deinit(vs);
	assert(allocs == 2);
	assert(reallocs == 1);
	assert(frees == 1);

	printf("PASSED\n");

	return 0;
}
