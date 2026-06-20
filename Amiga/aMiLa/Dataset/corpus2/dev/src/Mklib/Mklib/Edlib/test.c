/* edlib  version 1.0 of 04/08/88 */
#include <stdio.h>
#include "edlib.h"
#include <ctype.h>
#include <exec/types.h>

char b[] = "10101";
char d[] = "12345";
char h[] = "2a";

char s1[] = "hey man this was in lower case.";
char s2[] = "THIS WAS ENTIRELY UPPER CASE IN THE FASHION OF IBM.";

char s3[] = "hey man this was in lower case.";
char s4[] = "THIS WAS ENTIRELY UPPER CASE IN THE FASHION OF IBM.";

main()
{
    printf("Bin: %d\n",bintoint(b));
    printf("Dec: %d\n",dectoint(d));
    printf("Hex: %d\n",hextoint(h));

    printf("Is 1 a bdigit? %d Is 'a'? %d\n",isbdigit('1'),isbdigit('a'));

    printf("iscsym: 'a' %d '_' %d '4' %d '!' %d '/' %d\n",iscsym('a'),
            iscsym('_'), iscsym('4'), iscsym('!'), iscsym('/'));

    printf("iscsymf: 'a' %d '_' %d '4' %d '!' %d '/' %d\n",iscsymf('a'),
            iscsymf('_'), iscsymf('4'), iscsymf('!'), iscsymf('/'));

    printf("isodigit: '2' %d '8' %d 'a' %d\n", isodigit('2'), isodigit('8'),
            isodigit('a'));

    printf("stoupper: %s\n",stoupper(s1));
    printf("stolower: %s\n",stolower(s2));

    printf("strcspn: '%s' '%s' gives %d\n",s3,"an",strcspn(s3,"an"));

    printf("stricmp: '%s' '%s' gives %d\n",s1,s3,stricmp(s1,s3));
    printf("strnicmp: '%s' '%s' 10 gives %d\n",s1,s3,strnicmp(s1,s3,10));

    printf("strpbrk: '%s' '%s' gives '%s'\n",s3,"a",strpbrk(s3,"a"));

    printf("strpos: '%s' '%c' gives %d\n",s3,'a',strpos(s3,'a'));

    printf("strrpbrk: '%s' '%s' gives '%s'\n",s3,"a",strrpbrk(s3,"a"));

    printf("strrpos: '%s' '%c' gives %d\n",s3,'a',strrpos(s3,'a'));

    printf("strspn: '%s' '%s' gives %d\n",s3,"ma yeh",strspn(s3,"ma yeh"));

    printf("strtok: '%s'\n",s3);
    printf("  tok1: '%s'\n",strtok(s3," "));
    printf("  tok2: '%s'\n",strtok(NULL," "));
    printf("  tok3: '%s'\n",strtok(NULL," "));

    printf("toint: '1' %d 'b' %d 'k' %d\n",toint('1'),toint('b'),toint('k'));

    exit(0);
}

/* Testing the following functions:

 bintoint.c                rwed     317    1  01-Aug-88 21:17:27
 dectoint.c                rwed     334    1  01-Aug-88 21:19:17
 hextoint.c                rwed     337    1  01-Aug-88 21:21:57
 isbdigit.c                rwed     236    1  23-Jun-88 22:18:41
 iscsym.c                  rwed     262    1  31-Jul-88 10:16:17
 iscsymf.c                 rwed     273    1  07-Jul-88 23:17:39
 isodigit.c                rwed     270    1  01-Aug-88 21:46:43
 stolower.c                rwed     213    1  02-Aug-88 23:08:39
 stoupper.c                rwed     213    1  01-Aug-88 21:50:24
 strcspn.c                 rwed     279    1  02-Aug-88 23:10:52
 stricmp.c                 rwed     321    1  02-Aug-88 23:30:25
 strnicmp.c                rwed     350    1  02-Aug-88 23:32:01
 strpbrk.c                 rwed     258    1  02-Aug-88 23:12:28
 strpos.c                  rwed     433    1  03-Aug-88 00:04:26
 strrpbrk.c                rwed     304    1  02-Aug-88 23:19:03
 strrpos.c                 rwed     442    1  03-Aug-88 00:09:53
 strspn.c                  rwed     270    1  02-Aug-88 23:14:16
 strtok.c                  rwed     515    2  23-Jun-88 20:38:17
 toint.c                   rwed     488    1  01-Aug-88 21:21:45

*/

