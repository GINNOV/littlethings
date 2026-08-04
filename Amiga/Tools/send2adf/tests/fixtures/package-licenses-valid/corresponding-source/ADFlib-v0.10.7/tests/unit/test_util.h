
#ifndef TEST_UTIL_H
#define TEST_UTIL_H

#include "adflib.h"


unsigned verify_file_data( struct AdfVolume * const    vol,
                           const char * const          filename,
                           const unsigned char * const buffer,
                           const unsigned              bytes_written,
                           const unsigned              errors_max );

unsigned validate_file_metadata( struct AdfVolume * const vol,
                                 const char * const       filename,
                                 const unsigned           errors_max );

void pattern_AMIGAMIG( unsigned char * const buf,
                       const unsigned        bufsize );

void pattern_random( unsigned char * const buf,
                     const unsigned        bufsize );


unsigned pos2datablockIndex( const unsigned pos,
                             const unsigned blocksize );

unsigned filesize2datablocks( const unsigned fsize,
                              const unsigned blocksize );

unsigned datablocks2extblocks( const unsigned data_blocks );

unsigned filesize2blocks( const unsigned fsize,
                          const unsigned blocksize );

unsigned datablock2posInExtBlk( const unsigned datablock_idx );

#endif
