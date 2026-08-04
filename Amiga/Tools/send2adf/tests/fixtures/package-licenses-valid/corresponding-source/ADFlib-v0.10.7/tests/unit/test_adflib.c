#include <check.h>
#include <stdio.h>
#include <stdlib.h>

#include "adflib.h"

START_TEST( test_check_framework ) {
    ck_assert( 1 );
}
END_TEST


START_TEST( test_adflib_init )
{
    ADF_RETCODE rc = adfLibInit();
    ck_assert( rc == ADF_RC_OK );

    adfLibCleanUp();
}
END_TEST

START_TEST( test_adflib_cleanup )
{
    ck_assert( adfLibInit() == ADF_RC_OK );

    adfLibCleanUp();
    // so far, nothing to check here
}
END_TEST


Suite * adflib_suite(void)
{
    Suite * const suite = suite_create( "adflib init" );
    
    TCase * tcase = tcase_create ( "check framework" );
    tcase_add_test( tcase, test_check_framework );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "adflib init" );
    tcase_add_test( tcase, test_adflib_init  );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "adflib cleanup" );
    tcase_add_test( tcase, test_adflib_cleanup );
    suite_add_tcase( suite, tcase );

    return suite;
}


int main(void)
{
    Suite * const    suite   = adflib_suite();
    SRunner * const  srunner = srunner_create( suite );

    srunner_run_all( srunner, CK_VERBOSE ); //CK_NORMAL );

    int number_failed = srunner_ntests_failed ( srunner );
    srunner_free( srunner );

    return ( number_failed == 0 ) ? EXIT_SUCCESS : EXIT_FAILURE;
}
