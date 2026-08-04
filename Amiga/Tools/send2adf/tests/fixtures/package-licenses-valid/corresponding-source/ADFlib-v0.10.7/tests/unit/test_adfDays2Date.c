#include <check.h>
#include <stdio.h>
#include <stdlib.h>

//#include "adflib.h"
#include "adf_util.h"


START_TEST( test_check_framework ) {
    ck_assert( 1 );
}
END_TEST


START_TEST( test_adfDays2Date  )
{
    typedef struct test_data_s {
      // input
        int32_t days;

      //output
        int     yy,
                mm,
                dd;
    } test_data_t;

    test_data_t test_data[] = {
        // doesn't work for negative days
        // -> cannot represent dates before 1/1/1978 (!)
        //{ -1,   1977, 12, 31 },

        { 0,     1978,  1,  1 },
        { 6988,  1997,  2, 18 },
        { 16412, 2022, 12,  8 }
    };

    const int NTESTS = sizeof( test_data ) / sizeof( test_data_t );

    int yy, mm, dd;
    for ( int i = 0; i < NTESTS ; ++i ) {
        adfDays2Date( test_data[ i ].days,  // input
                      &yy, &mm, &dd );      // output

        printf( "days 0x%x ( %d )\n", test_data[ i ].days,
                                      test_data[ i ].days );

        ck_assert_int_eq( test_data[i].yy, yy );
        ck_assert_int_eq( test_data[i].mm, mm );
        ck_assert_int_eq( test_data[i].dd, dd );
    }

}
END_TEST

Suite * adflib_suite( void )
{
    Suite * const suite = suite_create( "adflib" );
    
    TCase * tcase = tcase_create( "check framework" );
    tcase_add_test( tcase, test_check_framework );
    suite_add_tcase( suite, tcase );

    tcase = tcase_create( "adflib adfDays2Date" );
    tcase_add_test( tcase, test_adfDays2Date  );
    suite_add_tcase( suite, tcase );

    return suite;
}


int main( void )
{
    Suite * const   suite   = adflib_suite();
    SRunner * const srunner = srunner_create( suite );

    srunner_run_all( srunner, CK_VERBOSE ); //CK_NORMAL );

    const int number_failed = srunner_ntests_failed( srunner );
    srunner_free( srunner );

    return ( number_failed == 0 ) ? EXIT_SUCCESS : EXIT_FAILURE;
}
