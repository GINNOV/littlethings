#ifndef TIMECONVERT_H
#define TIMECONVERT_H

#include <time.h>

int _gettime(struct timeval *tp);
/* Effect: Store GMT time into tp.
     If USE_LOCAL is defined, assume system stores local time,
     otherwise it stores GMT.
*/

void _gmt2amiga(time_t time, struct DateStamp *date);
/* Effect: Converts a time expressed in seconds since
     the 1 January 1970 0:00:00 GMT, to an Amiga time.
     If USE_LOCAL is defined, Amiga time is assumed to
     be stored as local time, otherwise as GMT.
   Modifies: date, to contain the time in Amiga format
*/

time_t _amiga2gmt(struct DateStamp *date);
/* Effect: Convert a date expressed in Amiga format (as a 
     local time if USE_LOCAL is defined, as GMT otherwise)
     to a number of seconds since 1 January 1970 0:00:00 GMT.
   Returns: this latter time
*/

#endif
