#pragma printLine #include <assert.h>
#pragma OCbuiltInFctn assert

#ifdef NDEBUG
#define assert(x) (void)0
#endif

