/****** --background-- *****************************************************
 * NAME
 *   device_info -- Get information about a mounted DOS device.
 * DESCRIPTION
 *   This is a simple set of functions to obtain information about a
 *   mounted DOS device *by drive name*, not by device name and unit number.
 *
 *   The main motivation has been that many programs expect the user to
 *   specify device and unit instead of simply the drive name. For example,
 *   instead of "cd0:" it has to be "scsi.device", unit 6.
 *
 *   This is extremely tedious in most cases because nobody wants to keep
 *   SCSI-ID's in mind - not to mention that they might change.
 *
 *   And why should one have to fiddle with several setups once a new serial
 *   card is installed and replace the string "serial.device" by
 *   "new-serial.device" in loads of settings windows? Let the user specify
 *   "SER:" and as time comes map "SER:" to a better device without the need
 *   to tell this every program.
 *
 *   The only problem about that is that it is a bit annoying for
 *   programmers to collect this information together "manually". You have
 *   to lock the DosList, dig around in obscure data structures and fiddle
 *   with BCPL strings.
 *
 *   These functions free you from this work. The device_info_t structure
 *   uses C strings and does not require any locking as everything is
 *   copied "by value" into the structure. No pointer references are used,
 *   so you can access the data even if the drive was ejected, unmounted
 *   or replaced. Of course this does not spare you a decent error handling,
 *   but you can be sure not to access any already released memory.
 *
 *   For compiling this material, use the included makefile and possible
 *   additional files:
 *
 *   smakefile, SCOPTIONS  - For SAS/c 6.57
 *   Makefile              - For gcc 2.7.2
 *
 *   The code should also work with Dice C.
 * AUTHOR
 *   Thomas Aglassinger <agi@sbox.tu-graz.ac.at>
 * COPYRIGHT
 *   This code is placed in the public domain. That means, you can use at as
 *   you like, even in commercial software. You even don't have to give me
 *   any credits.
 *
 *   You use this material at your own risk. I'm not responsible for any
 *   damage resulting from it.
 *
 *   If you find any bugs or make any improvements, please let me know so
 *   this source can be updated.
 * HISTORY
 *   v1.0, 12-Aug-1998
 *   - initial release
 * EXAMPLE
 *   For an example usage, take a look at the included "test_device_info.c".
 * SEE ALSO
 *   device_info_t, free_device_info(), get_device_info()
 **************************************************************************/

#include "device_info.h"

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/filehandler.h>

/* Without the includes below, GCC starts to whine... */
#include <exec/devices.h>
#include <exec/io.h>
#include <exec/semaphores.h>
#include <utility/tagitem.h>
#include <dos/exall.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <string.h>


/* Set DEBUG 1 for inline debugging output to stdout */
#define DEBUG 0

#if DEBUG
#include <stdio.h>
#define D(x) x
#else
#define D(x)                    /* do nothing */
#endif


/****i* dupBSTR ************************************************************
 * NAME
 *   dupBSTR -- Duplicate BCPL string to C string.
 * SYNOPSIS
 *   result = dupBSTR( c_target, bcpl_source )
 *
 *   static BOOL dupBSTR( STRPTR *, BSTR );
 * FUNCTION
 *   Convert a BCPL string to a C string and allocate an own memory area for
 *   the result.
 *
 *   You are responsible to call FreeVec() yourself once the result is not
 *   needed anymore.
 * INPUTS
 *   c_target    - Variable to hold the converted string
 *   bcpl_source - BCPL string to duplicate.
 * RESULT
 *   TRUE if the memory could be allocated.
 *
 *   In case of error, FALSE is returned and IoErr() is set to
 *   ERROR_NO_FREE_STORE.
 *
 *   If source is NULL, c_target also is set to NULL, but still success
 *   is TRUE.
 * SEE ALSO
 *   SetIoErr()
 **************************************************************************/
static BOOL dupBSTR(STRPTR * c_target, BSTR bcpl_source)
{
    BOOL success = TRUE;
    STRPTR source = (STRPTR) BADDR(bcpl_source);

    if (source != NULL)
    {
        size_t source_length = source[0];
        STRPTR target = AllocVec(source_length + 1, MEMF_ANY);

        if (target != NULL)
        {
            strncpy(target, source + 1, source_length);
            target[source_length] = '\0';
            *c_target = target;
        }
        else
        {
            SetIoErr(ERROR_NO_FREE_STORE);
            success = FALSE;
        }
    }
    else
    {
        *c_target = NULL;
    }

    return success;
}

/****** free_device_info ***************************************************
 * NAME
 *   free_device_info -- .
 * SYNOPSIS
 *   free_device_info( device_info )
 *
 *   VOID free_device_info( device_info_t * );
 * FUNCTION
 *   Free resources allocated by get_device_info().
 * INPUTS
 *   device_info - Device information to free. This is the return value of
 *       get_device_info(). If this is NULL, the function will do nothing.
 * SEE ALSO
 *   get_device_info()
 **************************************************************************/
VOID free_device_info(device_info_t * device_info)
{
#define lazyFreeVec(x) if (x!=NULL) FreeVec(x)

    if (device_info)
    {
        lazyFreeVec(device_info->name);
        lazyFreeVec(device_info->handler);
        lazyFreeVec(device_info->device);
        FreeVec(device_info);
    }
}

/****** get_device_info ****************************************************
 * NAME
 *   get_device_info -- Get information about the given device..
 * SYNOPSIS
 *   device_info = get_device_info( name )
 *
 *   device_info_t *get_device_info( STRPTR );
 * FUNCTION
 *   Get information about the given device.
 *
 *   This is achieved by scanning the locking the DosList using
 *   LockDosList() and search for the device using FindDosEntry(). The
 *   resulting data are copied into own memory areas (by value) and no
 *   references to the original are kept. The DosList is then unlocked
 *   again.
 *
 *   Some convenient translations are performed, e.g. BCPL strings are
 *   converted to zero terminated C strings and the block size is stored
 *   in bytes instead of longs.
 *
 *   To give back these resources once they are not needed any more, you
 *   have to call free_device_info().
 * INPUTS
 *   name - Zero terminated device name, including trailing colon (:), for
 *          example "df0:".
 * RESULT
 *   If the information could be obtained, the full a full device_info_t
 *   is returned.
 *
 *   In case of error, NULL is returned and IoErr() contains more
 *   information. Possible values are:
 *   
 *   ERROR_NO_FREE_STORE          - Not enough memory
 *   ERROR_INVALID_COMPONENT_NAME - 'name' did not end in ":"
 *   ERROR_DEVICE_NOT_MOUNTED     - Could not find any information about
 *                                  the requested device
 * NOTES
 *   Not all string fields of device_info-T have to contain values. For
 *   example, "df0:" does not have a handler but only a device, so
 *   device_info->handler is NULL.
 *
 *   If device_info->device is NULL, most numeric fields are so. In such
 *   a case, device_info->unit is -1. This can happen for example with
 *   "Ram:".
 * SEE ALSO
 *   free_device_info(), dos.library/IoErr() dos.library/LockDosList()
 **************************************************************************/
device_info_t *get_device_info(STRPTR name)
{
    BOOL success = FALSE;
    device_info_t *device_info = AllocVec(sizeof(struct device_info_s), MEMF_CLEAR);

    if (device_info != NULL)
    {
        size_t name_length = strlen(name);
        device_info->name = AllocVec(name_length, MEMF_ANY);
        device_info->unit = -1;

        if (device_info->name != NULL)
        {
            /* Copy all but one character of the name. This should strip
             * the ":" */
            strncpy(device_info->name, name, name_length - 1);
            device_info->name[name_length - 1] = '\0';

            D(printf("name=\"%s\"\n", device_info->name));

            if (strchr(device_info->name, ':') == NULL)
            {
                /* Flags for LockDosList() to read all devices */
                ULONG ldl_flags = LDF_DEVICES | LDF_READ;

                /* Lock doslist */
                struct DosList *dos_list = LockDosList(ldl_flags);
                struct FileSysStartupMsg *dst = NULL;
                struct DosEnvec *env = NULL;
                BSTR handler = NULL;

                dos_list = FindDosEntry(dos_list, device_info->name, ldl_flags);

                if (dos_list)
                {
                    dst = (struct FileSysStartupMsg *) BADDR(dos_list->dol_misc.dol_handler.dol_Startup);
                    handler = dos_list->dol_misc.dol_handler.dol_Handler;

                    D(printf("startup=%p\n", dst));
                    D(printf("handler=%p\n", handler));

                    success = TRUE;

                    if (dst)
                    {
                        /* Get device unit and name */
                        device_info->unit = dst->fssm_Unit;
                        success = dupBSTR(&(device_info->device), dst->fssm_Device);

                        /* Get values from environment, like low/high cylinder */
                        env = (struct DosEnvec *) BADDR(dst->fssm_Environ);
                        if (env)
                        {
                            D(printf("environ=%p\n", env));
                            device_info->dos_type = env->de_DosType;
                            device_info->blocks_per_track = env->de_BlocksPerTrack;
                            device_info->heads = env->de_Surfaces;
                            device_info->low_cylinder = env->de_LowCyl;
                            device_info->high_cylinder = env->de_HighCyl;

                            /* The block size has to be multipled with 4 to get a
                             * value in bytes */
                            device_info->block_size = env->de_SizeBlock * 4L;
                        }
                    }

                    if (handler)
                    {
                        /* Get name of handler */
                        success = dupBSTR(&(device_info->handler), handler);
                    }
                }
                else
                {
                    SetIoErr(ERROR_DEVICE_NOT_MOUNTED);
                }

                UnLockDosList(ldl_flags);
            }
            else
            {
                /* There still was a ":" in the name */
                SetIoErr(ERROR_INVALID_COMPONENT_NAME);
            }
        }
        else
        {
            SetIoErr(ERROR_NO_FREE_STORE);
        }
    }
    else
    {
        SetIoErr(ERROR_NO_FREE_STORE);
    }

    /* If something went wrong, cleanup and set device_info to NULL */
    if (!success)
    {
        free_device_info(device_info);
        device_info = NULL;
    }

    return device_info;
}

