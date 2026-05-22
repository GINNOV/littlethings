/* Avoid problems with conflicting declarations for mkdir */
#define mkdir __fake_mkdir
#include "include:stdlib.h"
#undef mkdir
