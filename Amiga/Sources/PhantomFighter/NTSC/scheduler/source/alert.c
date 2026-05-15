/*************************************************
 * Routine for Displaying a Lert
 *
 */
#include <exec/types.h>

void DoAlert(text)
char *text;
{
  dprintf("Alert: %s\n",text);
  while(1);
}

void DoAnAlert(text)
char *text;
{
  dprintf("Alert: %s\n",text);
  while(1);
}

  
