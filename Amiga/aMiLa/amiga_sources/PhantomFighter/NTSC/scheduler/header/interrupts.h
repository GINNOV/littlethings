#include <hardware/custom.h>

#define InterruptsOff custom.intena=0x07c0
#define InterruptsOn  custom.intena=0x8000
