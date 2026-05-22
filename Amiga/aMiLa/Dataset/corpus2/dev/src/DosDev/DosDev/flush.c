
/*
 *  Allocate memory until we can't ... force the system to flush all
 *  non-active DOS devices, libraries, fonts, etc....
 */

extern void *AllocMem();

main()
{
    char *ptr;
    long bytes = 1 << 9;

    while (ptr = AllocMem(bytes, MEMF_PUBLIC)) {
	FreeMem(ptr, bytes);
	bytes <<= 1;
    }
}

