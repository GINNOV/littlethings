

extern ULONG vbrd0(void);
extern ULONG a7d0(void);
extern void  rte(APTR bot_stack);


struct StackFrameBusError030 {
    /* by me: ULONG a0/a1/d0/d1 */
    UWORD _x;	     /* ==0 */
    ULONG rte;
    UWORD _y[5];     /* B008 0EE80749 4CDF7FFE */
    ULONG hit[2];    /* 2x das gleiche! */
    ULONG _z[2];     /* 01F65065 20102010 */
    ULONG after_rte; /* rte+6 rte+4 rte+2 */
    ULONG _hit;      /* once again */
    // ...
}; /* struct  */
