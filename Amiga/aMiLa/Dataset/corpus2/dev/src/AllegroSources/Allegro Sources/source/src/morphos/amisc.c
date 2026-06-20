/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Miscellanous Amiga code.
 *
 *      See readme.txt for copyright information.
 */

#include <math.h>
#include <sys/types.h>

double fmod( double x, double y )
{
	union{ double d; u_int64_t u;}ux = {x};
	union{ double d; u_int64_t u;}uy = {y};
	
	u_int64_t absx = ux.u & ~0x8000000000000000ULL;
	u_int64_t absy = uy.u & ~0x8000000000000000ULL;

	if( absx-1ULL >= 0x7fefffffffffffffULL || absy-1ULL >= 0x7fefffffffffffffULL )
	{
		double fabsx = __builtin_fabs(x);
		double fabsy = __builtin_fabs(y);
		
		// deal with NaN
		if( x != x || y != y )
			return x + y;

		//x = Inf or y = 0, return Invalid per IEEE-754
		if( fabsx == __builtin_inf() || 0.0 == y )
		{
			return __builtin_nan("");
		}

		//handle trivial case
		if( fabsy == __builtin_inf() || 0.0 == x )
		{
			return x;
		}
	}
 
	if( absy >= absx )
	{
		if( absy == absx )
		{
			ux.u ^= absx;
			return ux.d;
		}
		
		return x;
	}
 
	int32_t expx = absx >> 52;
	int32_t expy = absy >> 52;
	int64_t sx = absx & 0x000fffffffffffffLL;
	int64_t sy = absy & 0x000fffffffffffffLL;

	if( 0 == expx )
	{
		u_int32_t shift = __builtin_clzll( absx ) - (64-53);
		sx <<= shift;
		expx = 1 - shift;
	}

	if( 0 == expy )
	{
		u_int32_t shift = __builtin_clzll( absy ) - (64-53);
		sy <<= shift;
		expy = 1 - shift;
	}
	sx |= 0x0010000000000000ULL;
	sy |= 0x0010000000000000ULL;


	int32_t idiff = expx - expy;
	int32_t shift = 0;
	int64_t mask;
	
	do
	{
		sx <<= shift;
		idiff += ~shift;
		sx -= sy;
		mask = sx >> 63;
		sx += sx;
		sx += sy & mask;
		shift = __builtin_clzll( sx ) - (64-53);
	}
	while( idiff >= shift && sx != 0LL );

	if( idiff < 0 )
	{
		sx += sy & mask;
		sx >>= 1;
		idiff = 0;
	}
	
	sx <<= idiff;
	
	if( 0 == sx )
	{
		ux.u &= 0x8000000000000000ULL;
		return ux.d;
	}
	
	shift = __builtin_clzll( sx ) - (64-53);
	sx <<= shift;
	expy -= shift;
	sx &= 0x000fffffffffffffULL;
	sx |= ux.u & 0x8000000000000000ULL;
	if( expy > 0 )
	{
		ux.u = sx | ((int64_t) expy << 52);
		return ux.d;
	}
	
	expy += 1022;
	ux.u = sx | ((int64_t) expy << 52);
	return ux.d * 0x1.0p-1022;
}

typedef union {
       struct {
		u_int32_t hi;
		u_int32_t lo;
	} i;
       double            d;
} hexdouble;

#define HEXDOUBLE(hi, lo) { { hi, lo } }
#define likely(x) (x)
#define unlikely(x) (x)
#define      __FABS(x)	__builtin_fabs(x)
enum {
  _FE_INEXACT                    = 0x02000000,
  _FE_DIVBYZERO                  = 0x04000000,
  _FE_UNDERFLOW                  = 0x08000000,
  _FE_OVERFLOW                   = 0x10000000,
  _FE_INVALID                    = 0x20000000,
  _FE_ALL_EXCEPT                 = 0x3E000000 /* FE_INEXACT | FE_DIVBYZERO | FE_UNDERFLOW | FE_OVERFLOW | FE_INVALID*/
};

#define FE_INEXACT      _FE_INEXACT
#define FE_DIVBYZERO    _FE_DIVBYZERO
#define FE_UNDERFLOW    _FE_UNDERFLOW
#define FE_OVERFLOW     _FE_OVERFLOW
#define FE_INVALID      _FE_INVALID
#define FE_ALL_EXCEPT   _FE_ALL_EXCEPT

/*  Macros to get or set environment flags doubleword  */
#define      FEGETENVD(x) ({ __label__ L1, L2; L1: (void)&&L1; \
					asm volatile ("mffs %0" : "=f" (x)); \
                    L2: (void)&&L2; })
					
#define		 FESETENVD(x) ({ __label__ L1, L2; L1: (void)&&L1; \
                    asm volatile("mtfsf 255,%0" : : "f" (x)); \
                    L2: (void)&&L2; })

/*  Macros to get or set environment flags doubleword in their own dispatch group  */
#define      FEGETENVD_GRP(x)     ({ __label__ L1, L2; L1: (void)&&L1; \
									asm volatile ("mffs %0" : "=f" (x)); \
									L2: (void)&&L2; __NOOP; __NOOP; __NOOP; })
									
#define      FESETENVD_GRP(x)     ({ __label__ L1, L2; __NOOP; __NOOP; __NOOP; L1: (void)&&L1; \
									asm volatile ("mtfsf 255,%0" : : "f" (x)); \
									L2: (void)&&L2;})

double hypot ( double x, double y )
{
	static const hexdouble Huge = HEXDOUBLE(0x7FF00000, 0x00000000);
	static const hexdouble NegHuge = HEXDOUBLE(0xFFF00000, 0x00000000);

        register double temp;
	hexdouble OldEnvironment, CurrentEnvironment;
        
        register double FPR_env, FPR_z, FPR_one, FPR_inf, FPR_Minf, 
                        FPR_absx, FPR_absy, FPR_big, FPR_small;
        
        FPR_z = 0.0;					FPR_one = 1.0;
        FPR_inf = Huge.d;				FPR_Minf = NegHuge.d;
        FPR_absx = __FABS( x );				FPR_absy = __FABS( y );
      
/*******************************************************************************
*     If argument is SNaN then a QNaN has to be returned and the invalid       *
*     flag signaled.                                                           * 
*******************************************************************************/
	
	if (unlikely( ( x == FPR_inf ) || ( y == FPR_inf ) || ( x == FPR_Minf ) || ( y == FPR_Minf ) ))
            return FPR_inf;
                
        if (unlikely( ( x != x ) || ( y != y ) ))
        {
            x = __FABS ( x + y );
            return x;
        }
            
        if ( FPR_absx > FPR_absy )
        {
            FPR_big = FPR_absx;
            FPR_small = FPR_absy;
        }
        else
        {
            FPR_big = FPR_absy;
            FPR_small = FPR_absx;
        }
        
        // Now +0.0 <= FPR_small <= FPR_big < INFINITY
        
        if (unlikely( FPR_small == FPR_z ))
            return FPR_big;
            
        FEGETENVD( FPR_env );				// save environment, set default
        FESETENVD( FPR_z );

        temp = FPR_small / FPR_big;			
	OldEnvironment.d = FPR_env;
	
	temp = FPR_one + temp * temp;	   
	    temp = sqrt ( temp );	   
        
#if 0
        FEGETENVD_GRP( CurrentEnvironment.d );
        CurrentEnvironment.i.lo &= ~FE_UNDERFLOW;	// Clear any inconsequential underflow
        FESETENVD_GRP( CurrentEnvironment.d );
#endif
   
        temp = FPR_big * temp;				// Might raise UNDERFLOW or OVERFLOW

#if 0            
        FEGETENVD_GRP( CurrentEnvironment.d );
        OldEnvironment.i.lo |= CurrentEnvironment.i.lo; // Pick up any UF or OF
        FESETENVD_GRP( OldEnvironment.d );        		// restore caller's environment
#endif

        return temp;
}
