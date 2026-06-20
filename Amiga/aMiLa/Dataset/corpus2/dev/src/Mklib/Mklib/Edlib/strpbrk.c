/* edlib  version 1.0 of 04/08/88 */
#define NULL    0L

char *strpbrk(str, charset)
char *str, *charset;
{
        char *temp;
        extern char *index();

        temp = str;

        while ( *temp && !index(charset, *temp) )
                temp++;

        return( *temp ? temp : NULL);
}
