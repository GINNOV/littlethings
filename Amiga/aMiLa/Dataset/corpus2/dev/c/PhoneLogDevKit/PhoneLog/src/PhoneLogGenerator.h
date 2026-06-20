 /* Copyright © 1996 Kai Hofmann. All rights reserved. */

 #include <stdio.h>
 #include "PhoneLog.h"


 FILE *OpenPhoneLog(const char *const name);
 void ClosePhoneLog(FILE *const file);
 void WritePhoneLogStartEntry(FILE *const file, const struct PhoneLogEntry *const item);
 void WritePhoneLogEndEntry(FILE *const file, const struct PhoneLogEntry *const item);
 void WritePhoneLogEntry(FILE *const file, const struct PhoneLogEntry *const item);
 void WritePhoneLogMark(FILE *const file);
