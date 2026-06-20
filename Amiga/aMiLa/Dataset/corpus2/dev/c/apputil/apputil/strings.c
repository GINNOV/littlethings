/*
 * string.c
 * ========
 * String utility functions.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include "apputil.h"


LONG strlen(STRPTR s) {
  STRPTR p = s;

  while (*p++ != '\0') {
  }

  return p - s;
}


VOID strcpy(STRPTR dest, STRPTR src) {
  while ((*dest++ = *src++) != '\0'){
  }
}
