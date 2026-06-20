/* edlib  version 1.0 of 04/08/88 */
/* Return the number of characters from "charset" that are at the BEGINNING
 * of string "str".
*/

int strspn(str, charset)
char *str, *charset;
{
        char *temp = str;

        while ( index(charset, *temp) )
                ++temp;

        return(temp - str);
}
