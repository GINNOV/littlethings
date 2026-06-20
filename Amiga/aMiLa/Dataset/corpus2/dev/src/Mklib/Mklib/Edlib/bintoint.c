/* edlib  version 1.0 of 04/08/88 */
/* this function takes a string of binary digits and returns its value */
int bintoint(number)
char *number;
{
    int value = 0;

    while ( *number )
        if ( isbdigit(*number) ) {
            value = (value << 1) + toint(*number++);
        } else {
            return(value);
        }

    return(value);
}
