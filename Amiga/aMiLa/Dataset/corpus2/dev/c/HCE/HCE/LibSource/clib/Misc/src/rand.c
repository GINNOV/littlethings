/*
 *	In environments where the operating system doesn't provide
 *	a random number generator, the following code may be useful.
 */

static unsigned long _seed = 1;

int rand()
{
	_seed = (_seed * 1103515245) + 12345;
	return((unsigned int) ((_seed / 65536) % 32768));
}

void srand(seed)
unsigned int seed;
{
	_seed = seed;
}
