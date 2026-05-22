#ifndef _M68K_REG_H_
#define _M68K_REG_H_

/* Interface between ptrace.c:ptrace() and kern_sig.c:stopped_process_handler().
   Register set accessible via ptrace(). */
struct reg
  {
    /* Registers, d0-d7/a0-a7.  D0 is r_regs[0], a0 is r_regs[8].  */
    int r_regs[16];
    caddr_t r_pc;          		/* program counter */
    unsigned short r_sr;              	/* status register */
  };

struct fpreg
  {
    int r_fpregs[8 * 3];	/* Registers fp0-fp7 */
    int r_fpcontrol[3];		/* fpcr/fpsr/fpiar */
  };

#endif /* !_M68K_REG_H_ */
