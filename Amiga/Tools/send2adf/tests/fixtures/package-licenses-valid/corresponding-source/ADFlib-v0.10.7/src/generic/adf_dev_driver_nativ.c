/*
 * generic/adf_dev_driver_nativ.c - native device driver template
 *                                  (a "dummy" device)
 *
 *  Copyright (C) 1997-2022 Laurent Clevy
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

#include <stdlib.h>
#include <string.h>
#include "adf_dev_driver_nativ.h"
#include "adf_err.h"
#include "adf_env.h"


/*
 * myInitDevice
 *
 * must fill 'dev->size'
 */
static struct AdfDevice * myInitDevice( const char * const   name,
                                        const AdfAccessMode  mode )
{
    (void) name, (void) mode;
    adfEnv.eFct( "%s: not implemented", __func__ );
    return NULL;
}


/*
 * myReadSectors
 *
 */
ADF_RETCODE myReadSectors( const struct AdfDevice * const  dev,
                           const uint32_t                  block,
                           const uint32_t                  lenBlocks,
                           uint8_t * const                 buf )
{
    (void) dev, (void) block, (void) lenBlocks, (void) buf;
    adfEnv.eFct( "%s: not implemented", __func__ );
    return ADF_RC_ERROR;
}


/*
 * myWriteSectors
 *
 */
ADF_RETCODE myWriteSectors( const struct AdfDevice * const  dev,
                            const uint32_t                  block,
                            const uint32_t                  lenBlocks,
                            const uint8_t * const           buf )
{
    (void) dev, (void) block, (void) lenBlocks, (void) buf;
    adfEnv.eFct( "%s: not implemented", __func__ );
    return ADF_RC_ERROR;
}


/*
 * myReleaseDevice
 *
 * free native device
 */
ADF_RETCODE myReleaseDevice( struct AdfDevice * const  dev )
{
    (void) dev;
    adfEnv.eFct( "%s: not implemented", __func__ );
    return ADF_RC_ERROR;
}


/*
 * myIsDevNative
 *
 */
static bool myIsDevNative(void)
{
    return false;
}


static bool myIsDevice( const char * const  devName )
{
    (void) devName;
    return false;
}


const struct AdfDeviceDriver  adfDeviceDriverNative = {
    .name         = "native generic",
    .data         = NULL,
    .createDev    = NULL,
    .openDev      = myInitDevice,
    .closeDev     = myReleaseDevice,
    .readSectors  = myReadSectors,
    .writeSectors = myWriteSectors,
    .isNative     = myIsDevNative,
    .isDevice     = myIsDevice
};


/*##########################################################################*/
