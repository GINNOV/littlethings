#include <exec/types.h>
#include <proto/locale.h>
#include <proto/exec.h>

#include "phonemes.h"

PRIVATE UBYTE __far *message[] = {

#define _TEXT_ONLY
#define MSG(name, text) text,
#include "messages.h"

};

#define NUMSTR (sizeof message/sizeof message[0])


void main(void)
{
    int n;
    
    for (n = 0; n<NUMSTR; n++)
    {
        char *p;
        
        printf("%d \"", n);
        
        p = message[n];
        
        while (*p)
        {
            char ch = *p++;
            
            switch (ch)
            {
                case '\n': printf("\\n");  break;
                case '\"': printf("\\\""); break;
                case '\'': printf("\\\'"); break;
                case '\t': printf("\\t");  break;
                default:
                putchar(ch);
                break;
            }
        }
    }
}



