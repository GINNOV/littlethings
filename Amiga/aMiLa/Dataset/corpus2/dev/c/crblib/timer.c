
#include <stdlib.h>
#include <time.h>
#include <limits.h>

#include <crbinc/inc.h>
#include <crbinc/timer.h>

ulong ClockSeconds(clock_t Clock)
{
return( Clock / CLOCKS_PER_SEC );
}

ulong ClockMilliSeconds(clock_t Clock)
{
ulong Multiplier,Divisor;

Multiplier = 1000;
Divisor = CLOCKS_PER_SEC;

while( Clock >= (ULONG_MAX/Multiplier) )
  {
  Multiplier >>= 1;
  Divisor >>= 1;
  if ( Multiplier == 0 ) return(0xFFFFFFFF);
  }
if ( Divisor == 0 ) return(0xFFFFFFFF);

return( (Clock*Multiplier/Divisor) - (ClockSeconds(Clock)*1000) );
}

ulong NumPerSec(ulong Num,clock_t DiffClock)
{
ulong Multiplier;

Multiplier = CLOCKS_PER_SEC;

while( Num >= (ULONG_MAX/Multiplier) )
  {
  Multiplier >>= 1;
  DiffClock >>= 1;
  if ( Multiplier == 0 ) return(0xFFFFFFFF);
  }

if ( DiffClock == 0 ) return(0xFFFFFFFF);

return( Num*Multiplier/DiffClock );
}
