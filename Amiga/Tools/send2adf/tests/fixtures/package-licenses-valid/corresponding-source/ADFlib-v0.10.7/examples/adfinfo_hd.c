/*
 *  adfinfo_hd - hard disk metadata code
 *
 *  Copyright (C) 2023-2026 Tomasz Wolak
 *
 *  This file is part of adfinfo, an utility program showing low-level
 *  filesystem metadata of Amiga Disk Files (ADFs).
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

#include "adfinfo_hd.h"

#include "adfinfo_common.h"

#include "adf_blk_hd.h"
#include "adf_byteorder.h"
#include "adf_dev_hd.h"
#include "adf_env.h"
#include "adf_raw.h"
#include "adf_util.h"
#include "adf_vol.h"

#include <stdlib.h>
#include <string.h>


static void show_rdsk( const struct AdfRDSKblock * const  rdsk );

static void show_part( const struct AdfPARTblock * const  part,
                       const int32_t                      block );

static void show_fshd( const struct AdfFSHDblock * const  fshd,
                       const int32_t                      block )
{
    (void) fshd, (void) block;
}

static void show_lseg( const struct AdfLSEGblock * const  lseg,
                       const int32_t                      block )
{
    (void) lseg, (void) block;
}

static void show_badb( const struct AdfBADBblock * const  badb,
                       const int32_t                      block )
{
    (void) badb, (void) block;
}



void show_hd_info( const struct AdfDevice * const  dev )
{
    struct AdfRDSKblock  rdsk;

    // show Rigid Disk Block
    ADF_RETCODE rc = adfReadRDSKblock( dev, &rdsk );
    if ( rc != ADF_RC_OK )
        return;

    // show RDSK block
    show_rdsk( &rdsk );

    // show PART blocks
    struct AdfPARTblock  part;
    for ( int32_t next = rdsk.partitionList;  next != -1;  next = part.next ) {
        if ( adfReadPARTblock( dev, next, &part ) != ADF_RC_OK ) {
            fprintf( stderr, "Error reading PART block at %d, device '%s'",
                     next, dev->name );
            break;
        }
        show_part( &part, next );
    }

    // show bad blocks
    struct AdfFSHDblock fshd;
    for ( int32_t next = rdsk.fileSysHdrList;  next != -1;  next = fshd.next ) {
        if ( adfReadFSHDblock( dev, next, &fshd ) != ADF_RC_OK ) {
            fprintf( stderr, "Error reading FSHD block at %d, device '%s'",
                     next, dev->name );
            break;
        }
        printf( "FSHD block at %d\n", next );
        show_fshd( &fshd, next );

        // show LSEG blocks
        struct AdfLSEGblock lseg;
        for ( int32_t next = fshd.segListBlock;  next != -1;  next = lseg.next ) {
            if ( adfReadLSEGblock( dev, next, &lseg ) != ADF_RC_OK ) {
                fprintf( stderr, "Error reading LSEG block at %d, device '%s'",
                         next, dev->name );
                break;
            }
            printf( "LSEG block at %d\n", next );
            show_lseg( &lseg, next );
        }
    }


    // show BADB blocks
    struct AdfBADBblock badb;
    for ( int32_t next = rdsk.badBlockList;  next != -1;  next = badb.next ) {
        if ( adfReadBADBblock( dev, next, &badb ) != ADF_RC_OK ) {
            fprintf( stderr, "Error reading LSEG block at %d, device '%s'",
                     next, dev->name );
            break;
        }
        printf( "BADB block at %d\n", next );
        show_badb( &badb, next );
    }
}


static void show_rdsk( const struct AdfRDSKblock * const rdsk )
{
    uint8_t block_orig_endian[ sizeof(struct AdfRDSKblock) ];
    memcpy( block_orig_endian, rdsk, sizeof(struct AdfRDSKblock) );
    adfSwapEndian( block_orig_endian, ADF_SWBL_RDSK );
    uint32_t checksum_calculated = adfNormalSum( block_orig_endian, 8,
                                                 sizeof(struct AdfRDSKblock) );
    char diskVendor[ 8 + 1 ],
         diskProduct[ 16 + 1 ],
         diskRevision[ 4 + 1 ],
	 controllerVendor[ 8 + 1 ],
         controllerProduct[ 16 + 1 ],
         controllerRevision[ 4 + 1 ];
    char * endptr = stpncpy( diskVendor,  rdsk->diskVendor, 8 );          *endptr = '\0';
    endptr = stpncpy( diskProduct,        rdsk->diskProduct, 16 );        *endptr = '\0';
    endptr = stpncpy( diskRevision,       rdsk->diskRevision, 4 );        *endptr = '\0';
    endptr = stpncpy( controllerVendor,   rdsk->controllerVendor, 8 );    *endptr = '\0';
    endptr = stpncpy( controllerProduct,  rdsk->controllerProduct, 16 );  *endptr = '\0';
    endptr = stpncpy( controllerRevision, rdsk->controllerRevision, 4 );  *endptr = '\0';

    printf( "\nRigid Disk Block (RDSK / RDB):\n"
            //"  offset field                value\n"
            "  0x000  type:                0x%-16x\t'%c%c%c%c'\n"
            "  0x004  size:                0x%-16x\t%u\n"
            "  0x008  checkSum:            0x%x\n"
            "     ->  calculated:          0x%x%s\n"
            "  0x00c  hostID:              0x%-16x\t%d\n"
            "  0x010  blockSize:           0x%-16x\t%u\n"
            "  0x014  flags:               0x%x\n"
            "  0x018  badBlockList:        0x%-16x\t%d\n"
            "  0x01c  partitionList:       0x%-16x\t%d\n"
            "  0x020  fileSysHdrList:      0x%-16x\t%d\n"
            "  0x024  driveInit:           0x%-16x\t%d\n"
            "  0x028  r1[ 6 ]:             reserved (int32_t)\n"
            "  0x040  cylinders:           0x%-16x\t%u\n"
            "  0x044  sectors:             0x%-16x\t%u\n"
            "  0x048  heads:               0x%-16x\t%u\n"
            "  0x04c  interleave:          0x%-16x\t%d\n"
            "  0x050  parkingZone:         0x%-16x\t%d\n"
            "  0x054  r2[ 3 ]:             reserved (int32_t)\n"
            "  0x060  writePreComp:        0x%-16x\t%d\n"
            "  0x064  reducedWrite:        0x%-16x\t%d\n"
            "  0x068  stepRate:            0x%-16x\t%d\n"
            "  0x06c  r3[ 5 ]:             reserved (int32_t)\n"
            "  0x080  rdbBlockLo:          0x%-16x\t%d\n"
            "  0x084  rdbBlockHi:          0x%-16x\t%u\n"
            "  0x088  loCylinder:          0x%-16x\t%u\n"
            "  0x08c  hiCylinder:          0x%-16x\t%u\n"
            "  0x090  cylBlocks:           0x%-16x\t%u\n"
            "  0x094  autoParkSeconds:     0x%-16x\t%d\n"
            "  0x098  highRDSKBlock:       0x%-16x\t%d\n"
            "  0x09c  r4:                  0x%-16x\t%u\n"
            "  0x0a0  diskVendor:          %s\n"
            "  0x0a8  diskProduct:         %s\n"
            "  0x0b8  diskRevision:        %s\n"
            "  0x0bc  controllerVendor:    %s\n"
            "  0x0c4  controllerProduct:   %s\n"
            "  0x0d4  controllerRevision:  %s\n"
            "  0x0d8  r5[ 10 ]:            reserved (int32_t)\n",
//"  100*/

//          char      id[ 4 ];                "RDSK" 
            swapUint32IfLittleEndianHost( *( (const uint32_t *) &rdsk->id[0] ) ),
            printable( rdsk->id[0] ),
            printable( rdsk->id[1] ),
            printable( rdsk->id[2] ),
            printable( rdsk->id[3] ),
            rdsk->size, rdsk->size,
            rdsk->checksum,
            checksum_calculated,
            rdsk->checksum == checksum_calculated ? " -> OK" : " -> different(!)",
            rdsk->hostID,         rdsk->hostID,               /* 7 */
            rdsk->blockSize,      rdsk->blockSize,             /* 512 bytes */
            rdsk->flags,                 /* 0x17 */
            rdsk->badBlockList,   rdsk->badBlockList,
            rdsk->partitionList,  rdsk->partitionList,
            rdsk->fileSysHdrList, rdsk->fileSysHdrList,
            rdsk->driveInit,      rdsk->driveInit,
            //r1[ 6 ];               /* -1 */
            rdsk->cylinders,   rdsk->cylinders,  
            rdsk->sectors,     rdsk->sectors,    
            rdsk->heads,       rdsk->heads,      
            rdsk->interleave,  rdsk->interleave, 
            rdsk->parkingZone, rdsk->parkingZone,
            //r2[ 3 ];               /* 0 */
            rdsk->writePreComp, rdsk->writePreComp,
            rdsk->reducedWrite, rdsk->reducedWrite,
            rdsk->stepRate,     rdsk->stepRate,
            //r3[ 5 ];               /* 0 */
            rdsk->rdbBlockLo,      rdsk->rdbBlockLo,
            rdsk->rdbBlockHi,      rdsk->rdbBlockHi,
            rdsk->loCylinder,      rdsk->loCylinder,
            rdsk->hiCylinder,      rdsk->hiCylinder,
            rdsk->cylBlocks,       rdsk->cylBlocks, 
            rdsk->autoParkSeconds, rdsk->autoParkSeconds,
            rdsk->highRDSKBlock,   rdsk->highRDSKBlock,
            rdsk->r4,              rdsk->r4,
            diskVendor,
            diskProduct,
            diskRevision,
            controllerVendor,
            controllerProduct,
            controllerRevision
            //r5[ 10 ];              /* 0 */
        );
}

static void show_part( const struct AdfPARTblock * const  part,
                       const int32_t                      block )
{        
    uint8_t block_orig_endian[ sizeof(struct AdfPARTblock) ];
    memcpy( block_orig_endian, part, sizeof(struct AdfPARTblock) );
    adfSwapEndian( block_orig_endian, ADF_SWBL_PART );
    uint32_t checksum_calculated = adfNormalSum( block_orig_endian, 8,
                                                 sizeof(struct AdfPARTblock) );

    char * const name = strndup( part->name, (size_t) part->nameLen );
    printf( "\n\nPART block at %d:\n"
            "  0x000  type:                0x%-16x\t'%c%c%c%c'\n"
            "  0x004  size:                0x%-16x\t%u\n"
            "  0x008  checkSum:            0x%x\n"
            "     ->  calculated:          0x%x%s\n"
            "  0x00c  hostID:              0x%-16x\t%d\n"
            "  0x010  next:                0x%-16x\t%u\n"
            "  0x014  flags:               0x%x\n"
            "  0x018  r1[ 2 ](reserved):   0x%-16x\n"
            "                              0x%-16x\n"
            "  0x020  devFlags:            0x%-16x\t%d\n"
            "  0x024  nameLen:             0x%-16x\t%d\n"
            "  0x025  name:                '%s'\n"
            "  0x044  r2[ 15 ]:            reserved (int32_t)\n"
            "  0x080  vectorSize:          0x%-16x\t%d\n"
            "  0x084  blockSize:           0x%-16x\t%d\n"
            "  0x088  secOrg:              0x%-16x\t%d\n"
            "  0x08c  surfaces:            0x%-16x\t%d\n"
            "  0x090  sectorsPerBlock:     0x%-16x\t%d\n"
            "  0x094  blocksPerTrack:      0x%-16x\t%d\n"
            "  0x098  dosReserved:         0x%-16x\t%d\n"
            "  0x09c  dosPreAlloc:         0x%-16x\t%d\n"
            "  0x0a0  interleave:          0x%-16x\t%d\n"
            "  0x0a4  lowCyl:              0x%-16x\t%d\n"
            "  0x0a8  highCyl:             0x%-16x\t%d\n"
            "  0x0ac  numBuffer:           0x%-16x\t%d\n"
            "  0x0b0  bufMemType:          0x%-16x\t%d\n"
            "  0x0b4  maxTransfer:         0x%-16x\t%d\n"
            "  0x0b8  mask:                0x%-16x\t%d\n"
            "  0x0bc  bootPri:             0x%-16x\t%d\n"
            "  0x0c0  dosType[ 4 ]:        0x%08x\t\t'%c%c%c%c'\n"
            "  0x0c4  r3[ 15 ]:            reserved (int32_t)\n",
            block,
            swapUint32IfLittleEndianHost( *( (const uint32_t *) &part->id[0] ) ),
            printable( part->id[0] ),           // id[ 4 ];  "PART"
            printable( part->id[1] ),
            printable( part->id[2] ),
            printable( part->id[3] ),
            part->size,        part->size,      // 64 int32_ts
            part->checksum,
            checksum_calculated,
            part->checksum == checksum_calculated ? " -> OK" : " -> different(!)",
            part->hostID,      part->hostID,    // 7
            part->next,        part->next,
            part->flags,
            part->r1[ 0 ],     part->r1[ 1 ],
            part->devFlags,   part->devFlags,
            part->nameLen,    part->nameLen,
            name,                    //part->name
            //r2[ 15 ]
            
            part->vectorSize,      part->vectorSize,
            part->blockSize,       part->blockSize,
            part->secOrg,          part->secOrg,
            part->surfaces,        part->surfaces,
            part->sectorsPerBlock, part->sectorsPerBlock,
            part->blocksPerTrack,  part->blocksPerTrack,
            part->dosReserved,     part->dosReserved,
            part->dosPreAlloc,     part->dosPreAlloc,
            part->interleave,      part->interleave,
            part->lowCyl,          part->lowCyl,
            part->highCyl,         part->highCyl,
            part->numBuffer,       part->numBuffer,
            part->bufMemType,      part->bufMemType,
            part->maxTransfer,     part->maxTransfer,
            part->mask,            part->mask,
            part->bootPri,         part->bootPri,
            swapUint32IfLittleEndianHost( *( (uint32_t *) &part->dosType[ 0 ] ) ),
            printable( part->dosType[ 0 ] ),
            printable( part->dosType[ 1 ] ),
            printable( part->dosType[ 2 ] ),
            printable( part->dosType[ 3 ] )
            //r3[ 15 ];
        );

    free( name );
}
