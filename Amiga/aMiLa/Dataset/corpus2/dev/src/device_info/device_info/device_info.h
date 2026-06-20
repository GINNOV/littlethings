#ifndef DEVICE_INFO_H
#define DEVICE_INFO_H

#include <exec/types.h>

/****** device_info_t ******************************************************
 * NAME
 *   device_info_t -- Device information data type.
 * FUNCTION
 *   The device_info_t stores information about a device.
 * SEE ALSO
 *   get_device_info()
 * SOURCE
 */
struct device_info_s
{
    STRPTR name;                /* Name, e.g. "PC0" (no colon!) */
    STRPTR handler;             /* Handler, e.g. "l:CrossDOSFileSystem" */
    STRPTR device;              /* Device, e.g. "mfm.device" */
    LONG unit;                  /* Unit number, e.g. 0 */
    ULONG dos_type;
    ULONG low_cylinder;
    ULONG high_cylinder;
    ULONG block_size;           /* Block size in bytes */
    ULONG blocks_per_track;
    ULONG heads;
};

typedef struct device_info_s device_info_t;
/******/

device_info_t *get_device_info(STRPTR name);
VOID free_device_info(device_info_t * device_info);

#endif /* DEVICE_INFO_H */
