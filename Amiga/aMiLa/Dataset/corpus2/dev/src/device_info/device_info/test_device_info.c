/*
 * test_device_info.c
 *
 * Littel test program where you can specify device to show information about
 */
#include <stdio.h>
#include <string.h>

/* Without the includes below, GCC starts to whine... */
#include <exec/devices.h>
#include <exec/io.h>
#include <exec/semaphores.h>
#include <utility/tagitem.h>
#include <dos/exall.h>
#include <clib/dos_protos.h>

#include "device_info.h"

int main(int argc, char *argv[])
{
    if ((argc == 2) && (strcmp(argv[1], "?")))
    {
        device_info_t *device_info = get_device_info(argv[1]);

        if (device_info != NULL)
        {
            /* ULONG capacity = device_info->block_size * device_info->heads * device_info->blocks_per_track * (device_info->high_cylinder - device_info->low_cylinder); */
            printf("Information about \"%s:\"\n", device_info->name);
            if (device_info->handler != NULL)
            {
                printf("  handler=\"%s\"\n", device_info->handler);
            }
            else
            {
                printf("  handler=<no handler>\n");
            }

            if (device_info->device != NULL)
            {
                printf("  device =\"%s\"\n", device_info->device);
                printf("  unit   =%ld\n", device_info->unit);
                /* printf("capacity=%ld\n", capacity); */
                printf("  lowcyl =%ld\n", device_info->low_cylinder);
                printf("  highcyl=%ld\n", device_info->high_cylinder);
                printf("  heads  =%ld\n", device_info->heads);
                printf("  blksize=%ld\n", device_info->block_size);
                printf("  blkptrk=%ld\n", device_info->blocks_per_track);
            }
            else
            {
                printf("  device =<no device>\n");
            }

            free_device_info(device_info);
        }
        else
        {
            PrintFault(IoErr(), "Error obtaining device information");
        }
    }
    else
    {
        fprintf(stderr, "Usage  : test_device_info <device_name>\n");
        fprintf(stderr, "Example: test_device_info df0:\n");
    }
    return 0;
}

