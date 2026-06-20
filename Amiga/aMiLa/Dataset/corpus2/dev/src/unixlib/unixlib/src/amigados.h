#ifndef AMIGADOS_H
#define AMIGADOS_H

int _alloc_amigafd(BPTR fh, long protection, long flags);

void _init_unixio(BPTR in, int close_in, BPTR out, int close_out,
		  BPTR error, int close_error);
int _do_truncate(BPTR fh, off_t length);

#endif
