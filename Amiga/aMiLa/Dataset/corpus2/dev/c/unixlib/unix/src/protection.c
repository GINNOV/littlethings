
#include "amiga.h"
#include <sys/stat.h>

int use_amiga_flags;

int _make_protection(int mode)
{
    int amode;

    if (use_amiga_flags)
	return mode;

    /* We always turn archive off */
    amode = 0;

    /* Read: if any unix read */
    if (mode & (S_IRUSR | S_IRGRP | S_IROTH))
	amode |= FIBF_READ;

    /* Write: if user write or group write
       Delete: if user write or world write */
    if (mode & S_IWUSR)
	amode |= FIBF_WRITE | FIBF_DELETE;
    if (mode & S_IWGRP)
	amode |= FIBF_WRITE;
    if (mode & S_IWOTH)
	amode |= FIBF_DELETE;

    /* Execute: if group execute or user execute and not world execute
       Script: if world execute or user execute ant not group execute */
    if (mode & S_IXGRP)
	amode |= FIBF_EXECUTE;
    if (mode & S_IXOTH)
	amode |= FIBF_SCRIPT;
    if ((mode & (S_IXUSR | S_IXGRP | S_IXOTH)) == S_IXUSR)
	amode |= FIBF_EXECUTE | FIBF_SCRIPT;

    /* Pure: if sticky */
    if (mode & S_ISVTX)
	amode |= FIBF_PURE;

    /* Make correct bits active 0 */
    amode ^= FIBF_READ | FIBF_WRITE | FIBF_EXECUTE | FIBF_DELETE;
    return amode;
}

int _make_mode(int protection)
{
    int mode;

    if (use_amiga_flags)
	return protection & ~S_IFMT;

    mode = 0;
    /* make all bits active 1 */
    protection ^= FIBF_READ | FIBF_WRITE | FIBF_EXECUTE | FIBF_DELETE;

    /* Read user, group, world if amiga read */
    if (protection & FIBF_READ)
	mode |= S_IRUSR | S_IRGRP | S_IROTH;

    /* Write:
       user if amiga write & delete
       group if amiga write
       other if amiga delete */
    if ((protection & (FIBF_WRITE | FIBF_DELETE)) == (FIBF_WRITE | FIBF_DELETE))
	mode |= S_IWUSR;
    if (protection & FIBF_WRITE)
	mode |= S_IWGRP;
    if (protection & FIBF_DELETE)
	mode |= S_IWOTH;

    /* Execute:
       user if amiga execute or script
       group if amiga execute
       world if amiga script */
    if (protection & (FIBF_EXECUTE | FIBF_SCRIPT))
	mode |= S_IXUSR;
    if (protection & FIBF_EXECUTE)
	mode |= S_IXGRP;
    if (protection & FIBF_SCRIPT)
	mode |= S_IXOTH;

    /* Sticky: if pure */
    if (protection & FIBF_PURE)
	mode |= S_ISVTX;

    return mode;
}
