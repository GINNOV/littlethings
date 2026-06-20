/* edlib  version 1.0 of 04/08/88 */
/*
    strpos searches the null-terminated string string for the first
    occurance of the character "key". It returns either the position
    or EOF if it is not found.
*/

int strpos(string,key)
char *string;
char key;
{
    int counter = 0;

    if ( !key )
        return(strlen(string));

    while (string[counter]) {
        if (string[counter] == key)
            return(counter);
        counter++;
    }
    return(-1);
}
