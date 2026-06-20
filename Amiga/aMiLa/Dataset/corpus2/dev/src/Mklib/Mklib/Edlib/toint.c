/* edlib  version 1.0 of 04/08/88 */
/*
    toint is also not included in Manx. converts an ascii character
    into its corresponding hexadecimal value. Can be used for
    binary and decimal digits since these are subsets of the
    hexadecimal character set.
*/
int toint(c)
char c;
{
    if ( c >= '0' && c <= '9') {
        return( c - '0' );
    } else if ( c >= 'a' && c <= 'f' ) {
        return( c - 'a' +10 );
    } else if ( c >= 'A' && c <= 'F' ) {
        return( c - 'A' +10 );
    } else
        return(-1);
}
