#ifndef WARPUP_MACROS_H
#define WARPUP_MACROS_H

#define PPCLP0(base,offs,rt)					\
({								\
	register rt returnreg __asm("3");			\
	register unsigned long basearg __asm("3") = (unsigned long)base;	\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%1;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:"=r" (returnreg)							\
	:"r" (dummy),"r" (basearg),"r" (templr)			\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
	returnreg;\
})

#define PPCLP0NR(base,offs)					\
({								\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%0;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:							\
	:"r" (dummy),"r" (basearg)						\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
})

#define PPCLP1(base,offs,rt,t1,r1,v1)				\
({								\
	register rt returnreg __asm("3");			\
	register t1 param1 __asm(#r1)=(v1);			\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%1;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:"=r" (returnreg)							\
	:"r" (dummy),"r" (basearg),"r" (param1)			\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
	returnreg;\
})

#define PPCLP1NR(base,offs,t1,r1,v1)				\
({								\
	register t1 param1 __asm(#r1)=(v1);			\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%0;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:							\
	:"r" (dummy),"r" (basearg),"r" (param1)			\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
})

#define PPCLP2(base,offs,rt,t1,r1,v1,t2,r2,v2)			\
({								\
	register rt returnreg __asm("3");			\
	register t1 param1 __asm(#r1)=(v1);			\
	register t2 param2 __asm(#r2)=(v2);			\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%1;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:"=r" (returnreg)							\
	:"r" (dummy),"r" (basearg),"r" (param1),"r" (param2)	\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
	returnreg;\
})

#define PPCLP2NR(base,offs,t1,r1,v1,t2,r2,v2)			\
({								\
	register t1 param1 __asm(#r1)=(v1);			\
	register t2 param2 __asm(#r2)=(v2);			\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%0;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:							\
	:"r" (dummy),"r" (basearg),"r" (param1),"r" (param2)	\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
})

#define PPCLP3(base,offs,rt,t1,r1,v1,t2,r2,v2,t3,r3,v3)		\
({								\
	register rt returnreg __asm("3");			\
	register t1 param1 __asm(#r1)=(v1);			\
	register t2 param2 __asm(#r2)=(v2);			\
	register t3 param3 __asm(#r3)=(v3);			\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%1;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:"=r" (returnreg)							\
	:"r" (dummy),"r" (basearg),"r" (param1),"r" (param2),"r" (param3)	\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
	returnreg;\
})

#define PPCLP3NR(base,offs,t1,r1,v1,t2,r2,v2,t3,r3,v3)		\
({								\
	register t1 param1 __asm(#r1)=(v1);			\
	register t2 param2 __asm(#r2)=(v2);			\
	register t3 param3 __asm(#r3)=(v3);			\
	register unsigned long basearg __asm("3") = (unsigned long)base;			\
	register unsigned long dummy __asm("0") = *(unsigned long *)((char *)base+2+offs); \
	__asm volatile("					\
	subi	1,1,32;						\
	mflr	12;						\
	stw	12,28(1);					\
	mfcr	12;						\
	stw	12,24(1);					\
	mtlr	%0;						\
	blrl;							\
	lwz	12,24(1);					\
	mtcr	12;						\
	lwz	12,28(1);					\
	mtlr	12;						\
	addi	1,1,32;						\
	"							\
	:							\
	:"r" (dummy),"r" (basearg),"r" (param1),"r" (param2),"r" (param3)	\
	:"0","3","4","5","6","7","8","9","10","11","12","32","33","34","35","36","37","38","39","40","41","42","43","44","45","ctr","memory");\
})

#endif
