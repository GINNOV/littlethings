#include <check.h>
#include <stdlib.h>


#include "adflib.h"
#include "adf_util.h"
#include "test_util.h"


START_TEST( test_check_framework ) {
    ck_assert ( 1 );
}
END_TEST


START_TEST( test_swap_boot )
{
#define BUFSIZE 1024
    uint8_t * const boot = malloc( BUFSIZE );
    pattern_random( boot, BUFSIZE );

    uint8_t * const bootBak = malloc( BUFSIZE );
    memcpy( bootBak, boot, BUFSIZE );

    const uint32_t
        long1 = *(uint32_t *)( boot + 4 ),
        long2 = *(uint32_t *)( boot + 8 );

    adfSwapEndian( boot, ADF_SWBL_BOOT );

    // check swapped things are correct
    ck_assert_uint_eq( long1, swapUint32( *(uint32_t *)( boot + 4 ) ) );
    ck_assert_uint_eq( long2, swapUint32( *(uint32_t *)( boot + 8 ) ) );
    
    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( boot, bootBak, 4 ) );
    ck_assert_int_eq( 0, memcmp( boot + 12,
                                 bootBak + 12,
                                 BUFSIZE - 12 ) );

    // swap back
    adfSwapEndian( boot, ADF_SWBL_BOOT );

    // check all the same
    ck_assert_int_eq( 0, memcmp( boot, bootBak, BUFSIZE ) );
#undef BUFSIZE
    free( bootBak );
    free( boot );
}
END_TEST

START_TEST( test_swap_root )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1      = 108;
    const size_t     nlongs1_size = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1       = malloc( nlongs1_size );
    memcpy( longs1, block, nlongs1_size );

    const unsigned   nlongs2       = 10;
    const size_t     nlongs2_size  = nlongs2 * sizeof( uint32_t );
    uint32_t * const longs2        = malloc( nlongs2_size );
    const size_t     longs2_offset = nlongs1_size + 40;
    memcpy( longs2, block + longs2_offset, nlongs2_size );

    adfSwapEndian( block, ADF_SWBL_ROOT );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *) block )[ i ] ) );

    for ( unsigned i = 0; i < nlongs2; i++ )
        ck_assert_uint_eq( longs2[ i ],
                           swapUint32( ( (uint32_t *)( block + longs2_offset ) )[ i ] ) );
    
    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block + nlongs1_size,
                                 blockBak + nlongs1_size, 40 ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_ROOT );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs2 );
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


START_TEST( test_swap_data )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1      = 6;
    const size_t     nlongs1_size = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1       = malloc( nlongs1_size );
    memcpy( longs1, block, nlongs1_size );

    adfSwapEndian( block, ADF_SWBL_DATA );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *) block )[ i ] ) );    

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block + nlongs1_size,
                                 blockBak + nlongs1_size, 488 ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_DATA );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST

START_TEST( test_swap_entry )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1      = 82;
    const size_t     nlongs1_size = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1       = malloc( nlongs1_size );
    memcpy( longs1, block, nlongs1_size );

    const unsigned   nlongs2       = 3;
    const size_t     nlongs2_size  = nlongs2 * sizeof( uint32_t );
    uint32_t * const longs2        = malloc( nlongs2_size );
    const size_t     longs2_offset = nlongs1_size + 92;
    memcpy( longs2, block + longs2_offset, nlongs2_size );

    const unsigned   nlongs3       = 11;
    const size_t     nlongs3_size  = nlongs3 * sizeof( uint32_t );
    uint32_t * const longs3        = malloc( nlongs3_size );
    const size_t     longs3_offset = longs2_offset + nlongs2_size + 36;
    memcpy( longs3, block + longs3_offset, nlongs3_size );

    adfSwapEndian( block, ADF_SWBL_ENTRY );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *) block )[ i ] ) );

    for ( unsigned i = 0; i < nlongs2; i++ )
        ck_assert_uint_eq( longs2[ i ],
                           swapUint32( ( (uint32_t *)( block + longs2_offset ) )[ i ] ) );

    for ( unsigned i = 0; i < nlongs3; i++ )
        ck_assert_uint_eq( longs3[ i ],
                           swapUint32( ( (uint32_t *)( block + longs3_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block    + nlongs1_size,
                                 blockBak + nlongs1_size,
                                 92 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs2_offset + nlongs2_size,
                                 blockBak + longs2_offset + nlongs2_size,
                                 36 ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_ENTRY );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs3 );
    free( longs2 );
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST

START_TEST( test_swap_cache )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned nlongs1 = 6;
    const size_t nlongs1_size = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1 = malloc( nlongs1_size );
    memcpy( longs1, block, nlongs1_size );

    adfSwapEndian( block, ADF_SWBL_CACHE );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *) block )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block + nlongs1_size,
                                 blockBak + nlongs1_size, BUFSIZE - nlongs1_size ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_CACHE );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST

START_TEST( test_swap_bitmap_fext )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1      = 128;
    const size_t     nlongs1_size = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1       = malloc( nlongs1_size );
    memcpy( longs1, block, nlongs1_size );

    adfSwapEndian( block, ADF_SWBL_BITMAP );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *) block )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block + nlongs1_size,
                                 blockBak + nlongs1_size, BUFSIZE - nlongs1_size ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_FEXT );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


START_TEST( test_swap_link )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1      = 6;
    const size_t     nlongs1_size = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1       = malloc( nlongs1_size );
    memcpy( longs1, block, nlongs1_size );

    const unsigned   nlongs2       = 86;
    const size_t     nlongs2_size  = nlongs2 * sizeof( uint32_t );
    uint32_t * const longs2        = malloc( nlongs2_size );
    const size_t     longs2_offset = nlongs1_size + 64;
    memcpy( longs2, block + longs2_offset, nlongs2_size );

    const unsigned   nlongs3       = 12;
    const size_t     nlongs3_size  = nlongs3 * sizeof( uint32_t );
    uint32_t * const longs3        = malloc( nlongs3_size );
    const size_t     longs3_offset = longs2_offset + nlongs2_size + 32;
    memcpy( longs3, block + longs3_offset, nlongs3_size );

    adfSwapEndian( block, ADF_SWBL_LINK );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *) block )[ i ] ) );

    for ( unsigned i = 0; i < nlongs2; i++ )
        ck_assert_uint_eq( longs2[ i ],
                           swapUint32( ( (uint32_t *)( block + longs2_offset ) )[ i ] ) );

    for ( unsigned i = 0; i < nlongs3; i++ )
        ck_assert_uint_eq( longs3[ i ],
                           swapUint32( ( (uint32_t *)( block + longs3_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block    + nlongs1_size,
                                 blockBak + nlongs1_size,
                                 64 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs2_offset + nlongs2_size,
                                 blockBak + longs2_offset + nlongs2_size,
                                 32 ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_LINK );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs3 );
    free( longs2 );
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


START_TEST( test_swap_rdsk )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1       = 39;
    const size_t     nlongs1_size  = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1        = malloc( nlongs1_size );
    const size_t     longs1_offset = 4;
    memcpy( longs1, block + longs1_offset, nlongs1_size );

    const unsigned   nlongs2       = 10;
    const size_t     nlongs2_size  = nlongs2 * sizeof( uint32_t );
    uint32_t * const longs2        = malloc( nlongs2_size );
    const size_t     longs2_offset = longs1_offset + nlongs1_size + 56;
    memcpy( longs2, block + longs2_offset, nlongs2_size );

    adfSwapEndian( block, ADF_SWBL_RDSK );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *)( block + longs1_offset ) )[ i ] ) );

    for ( unsigned i = 0; i < nlongs2; i++ )
        ck_assert_uint_eq( longs2[ i ],
                           swapUint32( ( (uint32_t *)( block + longs2_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block, blockBak, 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs1_offset + nlongs1_size,
                                 blockBak + longs1_offset + nlongs1_size,
                                 56 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs2_offset + nlongs2_size,
                                 blockBak + longs2_offset + nlongs2_size,
                                 BUFSIZE - ( longs2_offset + nlongs2_size ) ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_RDSK );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs2 );
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


START_TEST( test_swap_badb )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1       = 127;
    const size_t     nlongs1_size  = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1        = malloc( nlongs1_size );
    const size_t     longs1_offset = 4;
    memcpy( longs1, block + longs1_offset, nlongs1_size );

    adfSwapEndian( block, ADF_SWBL_BADB );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *)( block + longs1_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block, blockBak, 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs1_offset + nlongs1_size,
                                 blockBak + longs1_offset + nlongs1_size,
                                 BUFSIZE - ( longs1_offset + nlongs1_size ) ) );
    // swap back
    adfSwapEndian( block, ADF_SWBL_BADB );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


START_TEST( test_swap_part )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1       = 8;
    const size_t     nlongs1_size  = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1        = malloc( nlongs1_size );
    const size_t     longs1_offset = 4;
    memcpy( longs1, block + longs1_offset, nlongs1_size );

    const unsigned   nlongs2       = 31;
    const size_t     nlongs2_size  = nlongs2 * sizeof( uint32_t );
    uint32_t * const longs2        = malloc( nlongs2_size );
    const size_t     longs2_offset = longs1_offset + nlongs1_size + 32;
    memcpy( longs2, block + longs2_offset, nlongs2_size );

    const unsigned   nlongs3       = 15;
    const size_t     nlongs3_size  = nlongs3 * sizeof( uint32_t );
    uint32_t * const longs3        = malloc( nlongs3_size );
    const size_t     longs3_offset = longs2_offset + nlongs2_size + 4;
    memcpy( longs3, block + longs3_offset, nlongs3_size );

    adfSwapEndian( block, ADF_SWBL_PART );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *)( block + longs1_offset ) )[ i ] ) );

    for ( unsigned i = 0; i < nlongs2; i++ )
        ck_assert_uint_eq( longs2[ i ],
                           swapUint32( ( (uint32_t *)( block + longs2_offset ) )[ i ] ) );

    for ( unsigned i = 0; i < nlongs3; i++ )
        ck_assert_uint_eq( longs3[ i ],
                           swapUint32( ( (uint32_t *)( block + longs3_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block, blockBak, 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs1_offset + nlongs1_size,
                                 blockBak + longs1_offset + nlongs1_size,
                                 32 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs2_offset + nlongs2_size,
                                 blockBak + longs2_offset + nlongs2_size,
                                 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs3_offset + nlongs3_size,
                                 blockBak + longs3_offset + nlongs3_size,
                                 BUFSIZE - ( longs3_offset + nlongs3_size ) ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_PART );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs3 );
    free( longs2 );
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST

START_TEST( test_swap_fshd )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1       = 7;
    const size_t     nlongs1_size  = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1        = malloc( nlongs1_size );
    const size_t     longs1_offset = 4;
    memcpy( longs1, block + longs1_offset, nlongs1_size );

    const unsigned   nlongs2       = 55;
    const size_t     nlongs2_size  = nlongs2 * sizeof( uint32_t );
    uint32_t * const longs2        = malloc( nlongs2_size );
    const size_t     longs2_offset = longs1_offset + nlongs1_size + 4;
    memcpy( longs2, block + longs2_offset, nlongs2_size );

    adfSwapEndian( block, ADF_SWBL_FSHD );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *)( block + longs1_offset ) )[ i ] ) );

    for ( unsigned i = 0; i < nlongs2; i++ )
        ck_assert_uint_eq( longs2[ i ],
                           swapUint32( ( (uint32_t *)( block + longs2_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block, blockBak, 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs1_offset + nlongs1_size,
                                 blockBak + longs1_offset + nlongs1_size,
                                 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs2_offset + nlongs2_size,
                                 blockBak + longs2_offset + nlongs2_size,
                                 BUFSIZE - ( longs2_offset + nlongs2_size ) ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_FSHD );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs2 );
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


START_TEST( test_swap_lseg )
{
#define BUFSIZE 512
    uint8_t * const block = malloc( BUFSIZE );
    pattern_random( block, BUFSIZE );

    uint8_t * const blockBak = malloc( BUFSIZE );
    memcpy( blockBak, block, BUFSIZE );

    const unsigned   nlongs1       = 4;
    const size_t     nlongs1_size  = nlongs1 * sizeof( uint32_t );
    uint32_t * const longs1        = malloc( nlongs1_size );
    const size_t     longs1_offset = 4;
    memcpy( longs1, block + longs1_offset, nlongs1_size );

    adfSwapEndian( block, ADF_SWBL_LSEG );

    // check swapped things are correct
    for ( unsigned i = 0; i < nlongs1; i++ )
        ck_assert_uint_eq( longs1[ i ],
                           swapUint32( ( (uint32_t *)( block + longs1_offset ) )[ i ] ) );

    // check nothing else was changed
    ck_assert_int_eq( 0, memcmp( block, blockBak, 4 ) );

    ck_assert_int_eq( 0, memcmp( block    + longs1_offset + nlongs1_size,
                                 blockBak + longs1_offset + nlongs1_size,
                                 BUFSIZE - ( longs1_offset + nlongs1_size ) ) );

    // swap back
    adfSwapEndian( block, ADF_SWBL_LSEG );

    // check all the same
    ck_assert_int_eq( 0, memcmp( block, blockBak, BUFSIZE ) );

#undef BUFSIZE
    free( longs1 );
    free( blockBak );
    free( block );
}
END_TEST


Suite * adflib_suite( void )
{
    Suite * const suite = suite_create( "adfSwapEndian" );
    
    TCase * tcase = tcase_create( "check framework" );
    tcase_add_test( tcase, test_check_framework );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_boot" );
    tcase_add_test( tcase, test_swap_boot );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_root" );
    tcase_add_test( tcase, test_swap_root );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_data" );
    tcase_add_test( tcase, test_swap_data );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_entry" );
    tcase_add_test( tcase, test_swap_entry );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_cache" );
    tcase_add_test( tcase, test_swap_cache );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_bitmap_fext" );
    tcase_add_test( tcase, test_swap_bitmap_fext );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_link" );
    tcase_add_test( tcase, test_swap_link );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_rdsk" );
    tcase_add_test( tcase, test_swap_rdsk );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_badb" );
    tcase_add_test( tcase, test_swap_badb );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_part" );
    tcase_add_test( tcase, test_swap_part );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_fshd" );
    tcase_add_test( tcase, test_swap_fshd );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test_swap_lseg" );
    tcase_add_test( tcase, test_swap_lseg );
    suite_add_tcase( suite, tcase );

    return suite;
}


int main( void )
{
    Suite * const   suite   = adflib_suite();
    SRunner * const srunner = srunner_create( suite );

    adfLibInit();
    srunner_run_all( srunner, CK_VERBOSE ); //CK_NORMAL );
    adfLibCleanUp();

    const int number_failed = srunner_ntests_failed( srunner );
    srunner_free( srunner );

    return ( number_failed == 0 ) ? EXIT_SUCCESS : EXIT_FAILURE;
}
