#include "amiga.h"
#include "dir_data.h"

iDIR *last_info;
struct idirect *last_entry;

BPTR _get_cd(void)
{
    BPTR dir = CurrentDir(0);

    CurrentDir(dir);

    return dir;
}
