/*-
 * Copyright (c) 1984 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)ptrace.h	7.4 (Berkeley) 2/22/91
 */

#ifndef	_PTRACE_H_
#define	_PTRACE_H_

#define	PT_TRACE_ME	0	/* child declares it's being traced */
#define	PT_READ_I	1	/* read word in child's I space */
#define	PT_READ_D	2	/* read word in child's D space */
#define	PT_READ_U	3	/* read word in child's user structure */
#define	PT_WRITE_I	4	/* write word in child's I space */
#define	PT_WRITE_D	5	/* write word in child's D space */
#define	PT_WRITE_U	6	/* write word in child's user structure */
#define	PT_CONTINUE	7	/* continue the child */
#define	PT_KILL		8	/* kill the child process */
#define	PT_STEP		9	/* single step the child */
#define PT_ATTACH       10      /* attach to running process */
#define PT_DETACH       11      /* detach from running process */
#define PT_GETREGS      12      /* read process register */
#define PT_SETREGS      13      /* set process register */
#define PT_GETFPREGS    14      /* read process floating point registers */
#define PT_SETFPREGS    15      /* set process floating point registers */
#define PT_GETSEGS      16      /* get segment list of execve-d program */
#define PT_GETIXINFO    17      /* get ixinfo-structure of ixemul.library */
#define PT_GETEXENAME   18      /* get name of execve-d program */
#define PT_GETA4        19      /* get the a4 register value (for base-relative programs */

/* Do NOT use this structure unless you know what you are doing.
   This structure is used to pass certain ixemul addresses to GDB to
   aid debugging. The structure may change without notice. */

struct ixinfo
{
  short version;
  long ixemul_seglist;
  long sigtramp_start;
  long sigtramp_end;
  long ixnet_seglist;
  void (*install_vector)(void);
  void (*restore_vector)(void);
};

#ifdef _KERNEL

struct reg;
struct fpreg;
int process_read_regs __P((struct user *p, struct reg *regs));
int process_write_regs __P((struct user *p, struct reg *regs));
int process_read_fpregs __P((struct user *p, struct fpreg *regs));
int process_write_fpregs __P((struct user *p, struct fpreg *regs));
int process_set_pc __P((struct user *p, caddr_t addr));
int process_sstep __P((struct user *p, int sstep));

#else

#include <sys/cdefs.h>

__BEGIN_DECLS
int	ptrace __P((int _request, pid_t _pid, caddr_t _addr, int _data));
__END_DECLS

#endif

#endif	/* !_PTRACE_H_ */
