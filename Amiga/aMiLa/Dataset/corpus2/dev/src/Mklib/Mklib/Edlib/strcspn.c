/* edlib  version 1.0 of 04/08/88 */
/* Return the number of characters NOT from "charset" that are at the
 * BEGINNING of string "string".
*/

int strcspn(str, charset)
char *str, *charset;
{
        char *temp = str;

        while (!strchr(charset, *temp))
                ++temp;

        return(temp - str);
}

