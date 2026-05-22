/* edlib  version 1.0 of 04/08/88 */
/*
    strrpos searches the null-terminated string string for the last
    occurance of the character "key". It returns either the position
    or -1 if it is not found.
*/

int strrpos(string,key)
char *string;
char key;
{
    char *temp;

    if ( !key )
        return(strlen(string));

    for (temp = string + strlen(string) - 1; temp >= string ; temp-- )
        if ( *temp == key)
            return(temp - string);

    return(-1);
}
