#ifndef _INLINE_FUELGAUGE_H
#define _INLINE_FUELGAUGE_H

#ifndef FUELGAUGE_BASE_NAME
#define FUELGAUGE_BASE_NAME FuelGaugeBase
#endif

#define FUELGAUGE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) FUELGAUGE_BASE_NAME) - 30))((struct Library *) FUELGAUGE_BASE_NAME)

#endif /*  _INLINE_FUELGAUGE_H  */
