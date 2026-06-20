/* edlib  version 1.0 of 04/08/88 */
#define NULL    0L

char *strrpbrk(str, charset)
char *str, *charset;
{
        char *temp;
        extern char *index();

        temp = str + strlen(str) - 1;

        while ( temp != (str - 1)  && !index(charset, *temp) )
                --temp;

        return( (temp != (str - 1)) ? temp : NULL);
}
