#ifndef EVERSION__MACROS_H
#define EVERSION__MACROS_H

#define RELEASE_ARRAY( x ) if(x) { delete [] x; x = NULL; }
#define RELEASE_OBJ( x ) if(x) { delete x; x = NULL; }
#define RELEASE( x ) if(x) delete (x);

#ifdef MIN
#undef MIN
#endif //MIN
template<typename T> inline T MIN(T x, T y) { return x>y ? y : x; }

#ifdef MAX
#undef MAX
#endif //MAX
template<typename T> inline T MAX(T x, T y) { return x>y ? x : y; }

template<typename T> inline T UNSIGN(T x) { return x>=0?x:0; }

#endif //EVERSION__MACROS_H
