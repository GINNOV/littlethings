
/*
   Regr. test of updating dataSize in headers of OFS datablocks
   (additionally, testing consistency of the checksums)

   See also commit: c0fa47992320bf4a12c729ab9aac9b2489c7e78b
*/

#include "adflib.h"

#include <stdio.h>
#include <stdlib.h>

#define TEST_VERBOSITY 1

typedef struct test_data_s {
    char * const          adfname;
    char * const          filename;
    unsigned char * const buffer;
    const unsigned        bufsize;
    unsigned              blocksize;
    const unsigned char   fstype;
    const int             max_errors;
} test_data_t;


int test_floppy_datasize_ofs ( test_data_t * const tdata );

int verify_file_data ( struct AdfVolume * const vol,
                       char * const             filename,
                       unsigned char * const    buffer,
                       const unsigned           bytes_written,
                       const int                max_errors );

int verify_file_metadata_ofs ( struct AdfVolume * const vol,
                               char * const             filename,
                               const unsigned           bytes_written,
                               const int                max_errors );

//void pattern_AMIGAMIG ( unsigned char * buf,
//                        const unsigned  BUFSIZE );

void pattern_random ( unsigned char * buf,
                      const unsigned  BUFSIZE );


int main (void)
{
    adfLibInit();

#ifdef _MSC_VER   // visual studio do not understand that const is const...
#define BUF_SIZE 1024 * 1024
#else
    const unsigned BUF_SIZE = 1024 * 1024;
#endif
    unsigned char * const buf = malloc ( BUF_SIZE );
    if ( buf == NULL )
        return 1;

    //pattern_AMIGAMIG ( buf, BUFSIZE );
    pattern_random ( buf, BUF_SIZE );

    const unsigned test_blocksize[] = { 4096, 4095, 2049, 2048, 1025, 1024, 1023,
        513, 512, 511, 257, 256, 128/*, 32, 16, 8, 4, 2, 1  */ };
    const unsigned nblocksizes = sizeof ( test_blocksize ) / sizeof ( unsigned );

    test_data_t tdata_ofs = {
        .adfname    = "test_floppy_overfilling_ofs.adf",
        .filename   = "testfile1.dat",
        .buffer     = buf,
        .bufsize    = BUF_SIZE,
        //.blocksize = ,
        .fstype     =  0,     // OFS
        .max_errors = 10
    };

    int status = 0;
    for ( unsigned i = 0 ; i < nblocksizes ; ++i ) {
        tdata_ofs.blocksize = test_blocksize[i];
        status += test_floppy_datasize_ofs( &tdata_ofs );
    }

    free ( buf );
    adfLibCleanUp();
    return status;
}


int test_floppy_datasize_ofs ( test_data_t * const tdata )
{
    const char * const fstype_info[] = { "OFS", "FFS" };
#if TEST_VERBOSITY > 0
    printf ("Test floppy OFS datasize update, filesystem: %s, blocksize: %d",
            fstype_info [ tdata->fstype ], tdata->blocksize );
#endif

    //struct AdfDevice * device = adfDevCreate ( "dump", tdata->adfname, 80, 2, 11 );
    struct AdfDevice * device = adfDevCreate ( "ramdisk", tdata->adfname, 80, 2, 11 );
    if ( ! device )
        return 1;
    adfCreateFlop ( device, "OFS_dataSize_Update_Test", tdata->fstype );

    struct AdfVolume * vol = adfVolMount ( device, 0, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol )
        return 1;

#if TEST_VERBOSITY > 1
    printf ( "\nFree blocks: %d\n", adfCountFreeBlocks ( vol ) );
#endif

    struct AdfFile * output = adfFileOpen ( vol, tdata->filename, ADF_FILE_MODE_WRITE );
    if ( ! output )
        return 1;

    int status = 1;
    unsigned char * bufferp = tdata->buffer;
    unsigned bytes_written = 0;
    while ( bytes_written + tdata->blocksize < tdata->bufsize ) {  /* <- assumption:
                                                                      bufsize must be larger than
                                                                      floppy size + blocksize */
        unsigned block_bytes_written = adfFileWrite ( output, tdata->blocksize, bufferp );
        bytes_written += block_bytes_written;
        if ( block_bytes_written != tdata->blocksize ) {
            // OK, end of the disk space hit and not all bytes written
            status = 0;   
            break;
        }
        bufferp += block_bytes_written; //tdata->blocksize;
        //printf ( "\nFree blocks: %d\n", adfCountFreeBlocks ( vol ) );

        // The bug with not updated dataSize was appearing only when appending,
        // (it is _not_ appearing if writing the file continuously, without closing!).
        // To reproduce the bug must close, reopen and seek to EOF.
        adfFileClose( output );
        output = adfFileOpen( vol, tdata->filename, ADF_FILE_MODE_WRITE );
        adfFileSeek( output, bytes_written );
    }

    if ( output->pos != bytes_written ) {
        fprintf ( stderr, "written_file->pos (%u) != bytes_written (%u) - ERROR!\n",
                  output->pos, bytes_written );
        status++;
    }

    //adfFlushFile ( output );
    adfFileClose ( output );

#if TEST_VERBOSITY > 1
    printf ( "\nFree blocks: %d\n", adfCountFreeBlocks ( vol ) );
#endif
    unsigned free_blocks = adfCountFreeBlocks ( vol );
    if ( free_blocks != 0 ) {
        fprintf ( stderr, "\n%d blocks still free after 'overfilling'!\n",
                  free_blocks );
        status++;
    }

    status += verify_file_data ( vol, tdata->filename, tdata->buffer,
                                 bytes_written, tdata->max_errors );

    //if ( adfVolIsOFS( vol ) ) {
    status += verify_file_metadata_ofs( vol, tdata->filename,
                                        bytes_written, tdata->max_errors );
        //}

    adfVolUnMount ( vol );
    adfDevUnMount ( device );
    adfDevClose ( device );

#if TEST_VERBOSITY > 0
    printf (" -> %s\n", status ? "ERROR" : "OK" );
#endif

    return status;
}


int verify_file_data ( struct AdfVolume * const vol,
                       char * const             filename,
                       unsigned char * const    buffer,
                       const unsigned           bytes_written,
                       const int                max_errors )
{
    struct AdfFile * output = adfFileOpen ( vol, filename, ADF_FILE_MODE_READ );
    if ( ! output )
        return 1;

#ifdef _MSC_VER   // visual studio do not understand that const is const...
#define READ_BUFSIZE 1024
#else
    const unsigned READ_BUFSIZE = 1024;
#endif
    unsigned char readbuf [ READ_BUFSIZE ];

    unsigned bytes_read = 0,
             block_bytes_read,
             offset = 0;
    int nerrors = 0;
    do {
        block_bytes_read = adfFileRead ( output, READ_BUFSIZE, readbuf );
        bytes_read += block_bytes_read;
        for ( unsigned i = 0 ; i < block_bytes_read ; ++i ) {
            if ( readbuf [ offset % READ_BUFSIZE ] != buffer [ offset ] ) {
                fprintf ( stderr, "Data differ at %u ( 0x%x ): orig. 0x%x, read 0x%x\n",
                          offset, offset,
                          buffer [ offset ],
                          readbuf [ offset % READ_BUFSIZE ] );
                nerrors++;
                if ( nerrors > max_errors )
                    break;
            }
            offset++;
        }
    } while ( block_bytes_read == READ_BUFSIZE  && nerrors <= max_errors );

    adfFileClose ( output );

    if ( bytes_read != bytes_written ) {
        fprintf ( stderr, "bytes read (%u) != bytes written (%u) -> ERROR!!!\n",
                  bytes_read, bytes_written );
        nerrors++;
    }

    return nerrors;
}


int verify_file_metadata_ofs ( struct AdfVolume * const vol,
                               char * const             filename,
                               const unsigned           bytes_written,
                               const int                max_errors )
{
    struct AdfFile * output = adfFileOpen ( vol, filename, ADF_FILE_MODE_READ );
    if ( output == NULL )
        return 1;

#ifdef _MSC_VER   // visual studio do not understand that const is const...
#define READ_BUFSIZE 488   // OFS block size (to read data block-by-block)
#else
    const unsigned READ_BUFSIZE = 488;
#endif
    unsigned char readbuf [ READ_BUFSIZE ];

    unsigned bytes_read = 0,
             block_bytes_read;
    int nerrors = 0;

    const struct AdfOFSDataBlock * const ofsblock = output->currentData;
    struct AdfOFSDataBlock ofsblock_orig_endian;

    do {
        block_bytes_read = adfFileRead ( output, READ_BUFSIZE, readbuf );
        bytes_read += block_bytes_read;

        // verify datasize in OFS header
        if ( bytes_read < output->fileHdr->byteSize ) {
            // middle of the file - blocks fully filled with data
            if ( ofsblock->dataSize != 488 ) {
                fprintf ( stderr, "Not the last block but data size in OFS header "
                          "is %u (0x%x), so it is < 488, block %u (0x%x).\n",
                          ofsblock->dataSize, ofsblock->dataSize,
                          output->nDataBlock, output->nDataBlock );
                nerrors++;
                if ( nerrors > max_errors )
                    break;
            }
        } else if ( bytes_read == output->fileHdr->byteSize ) {
            // verify data size in the last data block
            if ( bytes_written % 488 == 0 ) {
                if ( ofsblock->dataSize != 488 ) {
                    fprintf ( stderr, "Invalid data size in the last OFS block %u (0x%x), "
                              " expected 488 (0x%x), block %u (0x%x).\n",
                              ofsblock->dataSize, ofsblock->dataSize,
                              488u, output->nDataBlock, output->nDataBlock );
                    nerrors++;
                }
            } else if ( bytes_written % 488 != ofsblock->dataSize ) {
                fprintf ( stderr, "Invalid data size in the last OFS block %u (0x%x) "
                          "- different than calculated from file size: "
                          "%u mod 488 = %u (0x%x), block %u (0x%x).\n",
                          ofsblock->dataSize, ofsblock->dataSize,
                          bytes_written, bytes_read, bytes_read % 488,
                          output->nDataBlock, output->nDataBlock );
                nerrors++;
            }
        } else {
            fprintf( stderr, "%s: this should never happen (bug in the test).\n", __func__ );
            nerrors++;
        }

        // verify checksum in OFS header
        memcpy( &ofsblock_orig_endian, output->currentData, 512 );
        adfSwapEndian( (uint8_t * const) &ofsblock_orig_endian, ADF_SWBL_DATA );
        uint32_t checksum_calculated = adfNormalSum(
            (const uint8_t * const ) &ofsblock_orig_endian, 0x14,
            sizeof(struct AdfOFSDataBlock) );
        
        if ( ofsblock->checkSum != checksum_calculated ) {
            fprintf ( stderr, "Checksum in OFS header 0x%08x is different than "
                      "calculated 0x%08x, block %u (0x%x).\n",
                      ofsblock->checkSum, checksum_calculated,
                      output->nDataBlock, output->nDataBlock );
                nerrors++;
                if ( nerrors > max_errors )
                    break;            
        }
    } while ( //block_bytes_read == READ_BUFSIZE &&
        ( ! adfFileAtEOF( output ) ) &&
        nerrors <= max_errors );
    
    adfFileClose ( output );

    return nerrors;
}

/*
void pattern_AMIGAMIG ( unsigned char * buf,
                        const unsigned  BUFSIZE )
{
    for ( unsigned i = 0 ; i < BUFSIZE ; i += 4 ) {
        buf[i]   = 'A';
        buf[i+1] = 'M';
        buf[i+2] = 'I';
        buf[i+3] = 'G';
     }
}
*/

void pattern_random ( unsigned char * buf,
                      const unsigned  BUFSIZE )
{
    for ( unsigned i = 0 ; i < BUFSIZE ; ++i ) {
        buf[i]   = (unsigned char) ( rand() & 0xff );
    }
}
