/* rot13.c   Bei EBCDIC klappt das natuerlich nicht! */

#include <ctype.h>
#include <stdio.h>

int main()
{
    int c;

    while ((c=getc(stdin))!=EOF)
        putc(islower(c)? 'a'+(c-'a'+13)%26 :
             isupper(c)? 'A'+(c-'A'+13)%26 : c, stdout);
    return 0;
}
