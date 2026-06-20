#if defined __PPC__ && defined __GNUC__

__inline static unsigned long SWAP32(unsigned long a )
{
   unsigned long b;

   __asm__ ("lwbrx %0,0,%1"
           :"=r"(b)
           :"r"(&a), "m"(a));

   return b;

}

__inline static unsigned short SWAP16(unsigned short a )
{
   unsigned short b;
   __asm__ ("lhbrx %0,0,%1"
           :"=r"(b)
           :"r"(&a), "m"(a));

   return(b);
}

#endif

#if defined mc68000 && defined __GNUC__
__inline static unsigned long SWAP32(unsigned long a)
{

   __asm__ ("rol.w #8,%0;swap %0;rol.w #8,%0"
            :"=d"(a):"0"(a));

   return(a);
}


__inline static unsigned short SWAP16(unsigned short a)
{
   __asm__ ("rol.w #8,%0"
            :"=d"(a):"0"(a));

   return(a);
}
#endif