#include <proto/exec.h>
#include <stdarg.h>

/* by courtesy of Doug Walker of SAS Institute */

void Sprintf(char *, const char *, ...);                                              
void Sprintf(char *buffer, const char *ctl, ...)
{
   va_list args;                                                                
   va_start(args, ctl);                                                         
   /*********************************************************/
   /* NOTE: The string below is actually CODE that copies a */
   /*       value from d0 to A3 and increments A3:          */
   /*                                                       */
   /*          move.b d0,(a3)+                              */
   /*          rts                                          */
   /*                                                       */
   /*********************************************************/

   RawDoFmt((char *)ctl, args, (void (*))"\x16\xc0\x4e\x75", buffer);

   va_end(args);
}
