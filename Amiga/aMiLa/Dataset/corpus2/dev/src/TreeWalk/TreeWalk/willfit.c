/*
 * willfit - Decide if one or more directories will fit on the given
 * device.
 *
 * Copyright (c) 1990, Mike Meyer
 *
 * Usage: willfit device [directories]
 *
 * Decides whether or not there's enough room on device for the given
 * directories (and all files contained inside them). Willfit starts by
 * getting the number of free blocks on the device, and then keeps a
 * running total of free blocks left on the device as it scans each tree.
 * If there are enough free blocks, it prints 'yes' followed by the name
 * of the directory as the user typed it. If there aren't enough blocks,
 * it prints the shortfall for that directory. After the first shortfall,
 * it prints how large each directory (and etc.) is.
 *
 * Device may be any file that's on the device of interest. As a special
 * case, if the device is "-" then willfit uses the current device, and
 * acts as if it already ran out of space, so you get a list of how many
 * disk blocks each argument directory consumes. There is no RETURN_WARN
 * in this case.
 *
 * The return value is RETURN_OK if all arguments fit, RETURN_WARN if
 * some arguments wouldn't fit, and RETURN_ERROR if some arguments didn't
 * exist. RETURN_FAIL indicates out of memory, or unable to get data for
 * device.
 *
 * Note that the output of "willfit -" may not agree with the output of
 * list. Willfit always reports the number of blocks taken up for the
 * file, including all file system data blocks. List reports the block
 * count from the file information block, which just includes the data
 * blocks for the old file system, and includes all file system blocks
 * except maybe the header block for the fast file system. This means
 * that willfit may report one block higher than list, and possibly more.
 * That willfit reports the header block sometimes means there is one extra
 * block on the device, if you ask it about a directory which already exists
 * on the destination device. For example, if "willfit df0: tree" reports
 * a shortfall of one block, but the directory tree already exists on df0:,
 * then "copy tree df0:tree all" should work.
 */

#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <dos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "treewalk.h"

	
/* Globals, because the nature of the beast requires them */
static char			*my_name ;	/* Name I was invoked by */
static long			running_total ;	/* Tree size so far */
static long			blocks_free ;	/* Blocks free on device */
static struct FileInfoBlock	*fib ;		/* Scratch fib me to play in */
static int			blocksize = 0 ;	/* data bytes in a block */

/*
 * getdevdata - gets the device data we need to keep around.
 */
static int
getdevdata(char *dev) {
	BPTR			lock ;
	struct InfoData		*fid ;

	/* Get a lock */
	if ((lock = Lock(dev, ACCESS_READ)) == NULL) {
		fprintf(stderr, "%s: Can't lock device %s\n", my_name, dev) ;
		return FALSE ;
		}

	/* Get space for an InfoData structure */
	if ((fid = (struct InfoData *)
		AllocMem(sizeof(struct InfoData), 0)) == NULL) {
			fprintf(stderr, "%s: out of memory\n", my_name) ;
			return FALSE ;
			}

	/* Get the info we need */
	if (!Info(lock, fid)) {
		FreeMem(fid, sizeof(struct InfoData)) ;
		fprintf(stderr, "%s: Can't get info on %s\n", my_name, dev) ;
		return FALSE ;
		}

	/* set the globals needed from this device */
	blocksize = fid->id_BytesPerBlock ;
	blocks_free = fid->id_NumBlocks - fid->id_NumBlocksUsed ;

	/* Clean up and exit */
	FreeMem(fid, sizeof(struct InfoData)) ;
	return TRUE ;
	}

/*
 * This is a kludge, correct for 512 byte block file systems. There are
 * no other kinds as yet, and I expect this to appear somewhere where it
 * can be found should new block sizes appear.
 */
#define	EXTENTS_PER_BLOCK	72

/*
 * sumup - tracks the running sum of how big things are.
 */
#define NUMBER_USED(m, n) ((n / m) + (n % m ? 1 : 0))
static int
sumup(BPTR lock, struct FileInfoBlock *fib) {
	long	blocks ;

	/* Do we gotta stop now? */
	if (SetSignal(0, 0) & SIGBREAKF_CTRL_C) return TREE_STOP ;

	/* Ignore directory headers */
	if (fib == NULL) return TREE_CONT ;

	/* If we got a real fib, add in data blocks plus file system blocks */
	blocks = NUMBER_USED(blocksize, fib->fib_Size) ;
	running_total += blocks + NUMBER_USED(EXTENTS_PER_BLOCK, blocks) ;

	/* zero-length files use a header that doesn't show above */
	if (fib->fib_Size == 0) running_total += 1 ;

	/* And continue the walk */
	return TREE_CONT ;
	}

/*
 * du - arrange to let treewalk do the actual work, with the sumup routine
 * to keep a running total for this tree.
 */
static int
du(char *dir) {
	BPTR	lock ;
	int	stat ;

	/* Make sure we've got something we can really work on */
	if ((lock = Lock(dir, ACCESS_READ)) == NULL) {
		fprintf(stderr, "%s: Can't lock directory %s\n", my_name, dir) ;
		return TRUE ;
		}

	if (!Examine(lock, fib)) {
		fprintf(stderr, "%s: Can't examine %s\n", my_name, dir) ;
		return TRUE ;
		}

	/* Count the block in the top node */
	running_total = 0 ;
	sumup(lock, fib) ;

	/* Walk the tree and count all the blocks in it */
	stat = treewalk(lock, sumup, TREE_PRE) ;

	/* Tell the user, and clean up */
	UnLock(lock) ;
	if (blocks_free <= 0)
		printf("%ld\t%s\n", running_total, *dir ? dir : "\"\"") ;
	else if ((blocks_free -= running_total) >= 0) printf("yes\t%s\n", dir) ;
	else printf("%ld\t%s\n", -blocks_free, *dir ? dir : "") ;

	return !stat ;
	}

/*
 * main - just call du on each argument.
 */
void
main(int argc, char **argv) {
	int	error = FALSE ;

	my_name = argv[0] ;

	/* get the device data, if possible */
	if (strcmp(*++argv, "-")) {
		if (!getdevdata(*argv)) exit(RETURN_FAIL) ;
		}
	else  {
		if (!getdevdata(":")) exit(RETURN_FAIL) ;
		blocks_free = 0 ;
		}

	/* Get a scratch fib for du to use */
	if ((fib = (struct FileInfoBlock *)
		AllocMem(sizeof(struct FileInfoBlock), 0)) == NULL) {
			fprintf(stderr, "%s: out of memory\n", my_name) ;
			exit(RETURN_FAIL) ;
			}

	if (!*++argv) error = du("") ;
	else
		do error |= du(*argv) ;
		while (*++argv) ;

	FreeMem(fib, sizeof(struct FileInfoBlock)) ;
	exit(error ? RETURN_ERROR : (blocks_free < 0 ? RETURN_WARN : RETURN_OK)) ;
	}
