/****************************************************************/
/* unistr.c                                                     */
/****************************************************************/
/* 2008, Gilles PELLETIER, some code to work with 3.1 and lower */
/****************************************************************/
/* 01-Mar-2008 Set some ANAIIS code to display usb strings      */
/****************************************************************/


#include <stdio.h>

#include <exec/exec.h>
#include <usb/usb.h>

#include "unistr.h"

void strc(struct USBBusDscHead *strdsc, char *str)
{
  if ((strdsc != NULL) && (str != NULL))
  {
    if ((strdsc->dh_Length > 0) && (strdsc->dh_Type == USBDESC_STRING))
    {
      int len, i ;
      UBYTE *cTmp = (UBYTE *)strdsc ;
      len = (strdsc->dh_Length - 2) / 2 ;
      if (len >= 0)
      {
        for (i=0; i<len; i++)
        {
          str[i] = cTmp[2 + i*2] ;
        }
        str[len] = 0 ;
      }
    }
  }
}

