/* Avoid problems with conflicting declarations for mkdir and wait */
#define mkdir __fake_mkdir
#define wait __fake_wait
#include "include:dos.h"
#undef mkdir
#undef wait
