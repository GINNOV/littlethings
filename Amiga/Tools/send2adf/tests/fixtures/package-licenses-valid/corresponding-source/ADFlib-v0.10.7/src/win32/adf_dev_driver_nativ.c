/*
 *  Win32/adf_dev_driver_nativ.c - Win32 specific drive-access routines for ADFLib
 *
 *  Copyright (C) 1999      Dan Sutherland <dan@chromerhino.demon.co.uk>
 *                2023-2026 Tomasz Wolak
 *
 *  This file is part of ADFLib.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, see <https://www.gnu.org/licenses/>.
 *
 */

#include <windows.h>
#include <stdlib.h>
#include <string.h>

#include "adf_limits.h"
#include "adf_str.h"
#include "adf_err.h"
#include "adf_dev_driver_nativ.h"
#include "adf_dev_type.h"
#include "adf_env.h"
#include "nt4_dev.h"


struct AdfNativeDevice {
       void *hDrv;
};

static bool Win32IsDevice( const char * const  devName );
static ADF_RETCODE Win32ReleaseDevice( struct AdfDevice * const  dev );


/*
 * Open a physical disk device on Windows - (adflib device API)
 *
 * lpstrName:  a 3-character identification of the disk device:
 *    [0] - if '|' it means that it is a physical device (on Windows)
 *    [1] - if 'H' it means a disk drive
 *    [2] - a numeric id of the disk drive (as, for instance, listed in
 *          "Disk Management")
 */
static struct AdfDevice * Win32InitDevice( const char * const   lpstrName,
                                           const AdfAccessMode  mode )
{
    if ( ! Win32IsDevice( lpstrName ) ) {
        return NULL;
    }

    struct AdfDevice * dev = malloc( sizeof(struct AdfDevice) );
    if ( dev == NULL ) {
        adfEnv.eFct( "%s: malloc error", __func__ );
        return NULL;
    }

    dev->readOnly = ( mode != ADF_ACCESS_MODE_READWRITE );

    dev->drvData = malloc( sizeof(struct AdfNativeDevice) );
    if ( dev->drvData == NULL ) {
        adfEnv.eFct( "%s: malloc data error", __func__ );
        free( dev );
        return NULL;
    }

    /* convert device name to something usable by Win32 functions */
    if ( strlen( lpstrName ) != 3 ) {
        adfEnv.eFct( "%s: invalid drive specifier", __func__ );
        free( dev->drvData );
        free( dev );
        return NULL;
    }

    char strTempName[ 3 ];
    strTempName[ 0 ] = lpstrName[ 1 ];
    strTempName[ 1 ] = lpstrName[ 2 ];
    strTempName[ 2 ] = '\0';

    void ** const hDrv = &( ( (struct AdfNativeDevice *) dev->drvData )->hDrv );
    *hDrv = NT4OpenDrive( strTempName );
    if ( *hDrv == NULL ) {
        adfEnv.eFct( "%s: NT4OpenDrive", __func__ );
        free( dev->drvData );
        free( dev );
        return NULL;
    }

    NT4DriveGeometry_t geometry;
    if ( ! NT4GetDriveGeometry( *hDrv, &geometry ) ) {
        adfEnv.eFct( "%s: error getting drive geometry", __func__ );
        Win32ReleaseDevice( dev );
        return NULL;
    }

    // no support for disks with non 512-byte sectors (-> to improve?)
    if ( geometry.bytesPerSector != ADF_DEV_BLOCK_SIZE ) {
        adfEnv.eFct( "%s: non %u-byte sector size", __func__, ADF_DEV_BLOCK_SIZE );
        Win32ReleaseDevice( dev );
        return NULL;
    }

    dev->geometry.cylinders = geometry.cylinders;
    dev->geometry.heads     = geometry.tracksPerCylinder;
    dev->geometry.sectors   = geometry.sectorsPerTrack;
    dev->geometry.blockSize = geometry.bytesPerSector;

    //dev->size = NT4GetDriveSize(nDev->hDrv);
    dev->sizeBlocks = geometry.cylinders *
                      geometry.tracksPerCylinder *
                      geometry.sectorsPerTrack;

    dev->type  = adfDevGetTypeByGeometry( &dev->geometry );
    dev->class = ( dev->type != ADF_DEVTYPE_UNKNOWN ) ?
        adfDevTypeGetClass( dev->type ) :
        adfDevGetClassBySizeBlocks( dev->sizeBlocks );

    dev->nVol    = 0;
    dev->volList = NULL;
    dev->mounted = false;
    dev->name    = strdup( lpstrName );
    dev->drv     = &adfDeviceDriverNative;

    return dev;
}


static ADF_RETCODE Win32ReleaseDevice( struct AdfDevice * const  dev )
{
    void ** const hDrv = &( ( (struct AdfNativeDevice *) dev->drvData )->hDrv );

    if ( ! NT4CloseDrive( *hDrv ) )
        return ADF_RC_ERROR;				/* BV */
    free( dev->name );
    free( dev->drvData );
    free( dev );

    return ADF_RC_OK;
}


static ADF_RETCODE Win32ReadSectors( const struct AdfDevice * const  dev,
                                     const uint32_t                  block,
                                     const uint32_t                  lenBlocks,
                                     uint8_t * const                 buf )
{
    if ( block + lenBlocks > dev->sizeBlocks )
        return ADF_RC_ERROR;

    void ** const hDrv = &( ( (struct AdfNativeDevice *) dev->drvData )->hDrv );

    if ( ! NT4ReadSector( *hDrv, (long) block, dev->geometry.blockSize * lenBlocks, buf ) ) {
        adfEnv.eFct( "%s: NT4ReadSector", __func__ );
        return ADF_RC_ERROR;				/* BV */
    }

    return ADF_RC_OK;
}


static ADF_RETCODE Win32WriteSectors( const struct AdfDevice * const  dev,
                                      const uint32_t                  block,
                                      const uint32_t                  lenBlocks,
                                      const uint8_t * const           buf )
{
    if ( block + lenBlocks > dev->sizeBlocks )
        return ADF_RC_ERROR;

    void ** const hDrv = &( ( (struct AdfNativeDevice *) dev->drvData )->hDrv );

    if ( ! NT4WriteSector( *hDrv, (long) block, dev->geometry.blockSize * lenBlocks, buf ) ) {
        adfEnv.eFct( "%s: NT4WriteSector", __func__ );
        return ADF_RC_ERROR;				/* BV */
    }

    return ADF_RC_OK;
}


static bool Win32IsDevNative(void)
{
    return true;
}


static bool Win32IsDevice( const char * const  devName )
{
    return devName[ 0 ] == '|';
}


const struct AdfDeviceDriver adfDeviceDriverNative = {
    .name         = "native win32",
    .data         = NULL,
    .createDev    = NULL,
    .openDev      = Win32InitDevice,
    .closeDev     = Win32ReleaseDevice,
    .readSectors  = Win32ReadSectors,
    .writeSectors = Win32WriteSectors,
    .isNative     = Win32IsDevNative,
    .isDevice     = Win32IsDevice
};
