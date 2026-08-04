#include <check.h>
#include <stdio.h>
#include <stdlib.h>

//#include "adflib.h"
#include "adf_vector.h"

START_TEST( test_check_framework ) {
    ck_assert( 1 );
}
END_TEST


START_TEST( test_adf_vector )
{
    struct AdfVector vector;

    // empty
    vector = adfVectorCreate( 0, sizeof(char *) );
    ck_assert_ptr_null( vector.items );
    ck_assert_ptr_nonnull( vector.destroy );

    vector.destroy( &vector );
    ck_assert_ptr_null( vector.items );
    ck_assert_ptr_null( vector.destroy );

    // non-empty
    vector = adfVectorCreate( 256, sizeof(char *) );
    ck_assert_ptr_nonnull( vector.items );
    ck_assert_ptr_nonnull( vector.destroy );

    vector.destroy( &vector );
    ck_assert_ptr_null( vector.items );
    ck_assert_ptr_null( vector.destroy );

}
END_TEST


Suite * adflib_suite(void)
{
    Suite * const suite = suite_create( "adf vector" );
    
    TCase * tcase = tcase_create( "check framework" );
    tcase_add_test( tcase, test_check_framework );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "test adf_vector" );
    tcase_add_test( tcase, test_adf_vector );
    suite_add_tcase( suite, tcase );

    return suite;
}


int main(void)
{
    Suite * const suite     = adflib_suite();
    SRunner * const srunner = srunner_create( suite );

    srunner_run_all( srunner, CK_VERBOSE ); //CK_NORMAL );

    const int nfailed = srunner_ntests_failed( srunner );
    srunner_free( srunner );

    return ( nfailed == 0 ) ? EXIT_SUCCESS : EXIT_FAILURE;
}
