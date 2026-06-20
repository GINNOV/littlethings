/*
 *  This file is part of ixemul.library for the Amiga.
 *  Copyright (C) 1991, 1992  Markus M. Wild
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _USER_H
#define _USER_H

#include <sys/time.h>
#include <sys/resource.h>
#include <sys/syslog.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <setjmp.h>
#include <machine/reg.h>
#include <stdio.h>
#include <netdb.h>
#include <pwd.h>
#include <grp.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <arpa/nameser.h>
#include <resolv.h>
#include <ix.h>

struct ixnode {
  struct ixnode *next, *prev;
};

struct ixlist {
  struct ixnode *head, *tail;
};

struct utimenode {
  struct ixnode node;
  unsigned time;
};

/* internal structure used by malloc(), kmalloc() and friends */
struct malloc_data {
  struct ixlist	        md_list;
  unsigned int		md_malloc_sbrk_used;
};

/* internal structure used by the stackextend code */
struct stackframe
{
  struct stackframe *next;	/* NULL if there is no next one */
  void *savesp;			/* stored sp for next underlying stackframe */
  void *upper;			/* end of this stackframe+1 */
};


/*
 * One structure allocated per session.
 */
struct	session {
	int	s_count;		/* ref cnt; pgrps in session */
/*	struct	proc *s_leader;		*//* session leader */
	int	pgrp;			/* controlling process group */
/*	struct	vnode *s_ttyvp;		*//* vnode of controlling terminal */
/*	struct	tty *s_ttyp;		*//* controlling terminal */
/*	char	s_login[MAXLOGNAME];	*//* setlogin() name */
};

/*
 * One structure allocated per process group.
 */
struct	pgrp {
	struct	pgrp *pg_hforw;		/* forward link in hash bucket */
	struct	proc *pg_mem;		/* pointer to pgrp members */
	struct	session *pg_session;	/* pointer to session */
	pid_t	pg_id;			/* pgrp id */
	int	pg_jobc;		/* # procs qualifying pgrp for job control */
};

/* internal structure used by mmap() and friends */
struct mmap_mem {
	struct mmap_mem	*next;
	void		*addr;
	size_t		length;
	int		fd;
	int		offset;
	int		prot;
	int		flags;
};

/* having it in a struct makes parameter passing easier */

struct reg_parms {
  jmp_buf jb;
};

struct vfork_msg {
  struct Message 	vm_msg;
  struct Process	*vm_self;	/* for validation purposes */
  struct Process 	*vm_pptr;
  struct reg_parms 	*vm_regs;	/* parents context to restore */
  int			vm_own_malloc;
  int		 	vm_rc;		/* 0 if the child started normally, else errno */
  int                   vm_plower;      /* lower bound of parents stack */
  int                   vm_pupper;      /* upper bound of parents stack */
  int                   vm_clower;      /* lower bound of childs stack */
  int                   vm_cupper;      /* upper bound of childs stack */
  int                   vm_omask;       /* parent's omask (nowhere else to store this */
};

/*
 * Per process structure
 */

/* default size */
#define A4_POINTERS 100

/* NB: a list of pointers for shared libraries is allocated *before*
   the start of this struct! So the struct is actually larger, but
   the advantage of this is that the number of free library slots is
   easy to enlarge through a setting, without scrambling the offsets
   within the 'regular' user struct. */

/* Starting with ixemul-47.0 this whole structure is PRIVATE and may
   change without notice!
   Use the new functions ix_get_long/ix_set_long to access certain fields
   in this structure. */

struct user {
	/* both a magic cookie and a way to get at the library base thru u */
	struct ixemul_base	*u_ixbase;
	void			*u_user;	/* freely usable user field */

	long		u_a4_pointers_size;	/* number of a4 pointers */

/* 1.3 - signal management */
	sig_t		u_signal[NSIG];		/* disposition of signals */
	int		u_sigmask[NSIG];	/* signals to be blocked */
	sigset_t	u_sigonstack;		/* signals to take on sigstack */
	sigset_t	u_sigintr;		/* signals that interrupt syscalls */
	sigset_t	u_oldmask;		/* saved mask from before sigpause */
	struct	sigstack u_sigstack;	/* sp & on stack state variable */
#define	u_onstack	u_sigstack.ss_onstack
#define	u_sigsp		u_sigstack.ss_sp
	int		u_sig;			/* for core dump/debugger XXX */
	int		u_code;			/* for core dump/debugger XXX */
	
	int			p_flag;		/* process flags, as necessary.. */
	char			p_stat;
	int			p_xstat;	/* exit status */
	char			p_cursig;
	sigset_t		p_sig;		/* signals pending to this process */
	sigset_t		p_sigmask;	/* current signal mask */
	sigset_t		p_sigignore;	/* signals being ignored */
	sigset_t		p_sigcatch;	/* signals being caught by user */

	caddr_t 		p_wchan;	/* event process is awaiting */


/* 1.4 - descriptor management (for shared library version) */
	struct file 		*u_ofile[NOFILE];	/* file structures for open files */
	char			u_pofile[NOFILE];	/* per-process flags of open files */
	int			u_lastfile;	/* high-water mark of u_ofile */
#define	UF_EXCLOSE 	0x1			/* auto-close on exec */
	short			u_cmask;	/* mask for file creation */

/* 1.5 - timing and statistics */
	struct rusage 		u_ru;		/* stats for this proc */
	struct rusage 		u_cru;		/* sum of stats for reaped children */
	struct itimerval 	u_timer[3];
	struct timeval 	        u_start;
	struct utimenode        u_time;
	short			u_acflag;

	struct uprof {			/* profile arguments */
		short	*pr_base;	/* buffer base */
		unsigned pr_size;	/* buffer size */
		unsigned pr_off;	/* pc offset */
		unsigned pr_scale;	/* pc scaling */
	} u_prof;
	unsigned		u_prof_last_pc;	/* last function that called mcount() */

/* 1.6 - resource controls */
	struct	rlimit u_rlimit[RLIM_NLIMITS];

/* amiga specific stuff */
	struct malloc_data	u_md;
	
	struct ixnode	        u_user_node;
	struct Task             *u_task;
	struct MsgPort		*u_sync_mp;	/* PA_SIGNAL message port */
	struct timerequest 	*u_time_req;
	int			*u_errno;
	BPTR			u_startup_cd;
	
	int			u_ringring;	/* used in sleep.c and usleep.c */

	char			***u_environ;

	/* used to handle AmigaOS signals. see SIGMSG  */
        u_int			u_lastrcvsig;
        char			u_sleep_sig;
        char			u_pipe_sig;
        
        /* c-startup stuff */
        jmp_buf			u_jmp_buf;
        char 			*u_argline;
        u_int			u_arglinelen;
        int			u_expand_cmd_line;

	struct atexit		*u_atexit;
	
	char			u_getenv_buf[255];
	
	UBYTE			u_otask_flags;
	void			(*u_olaunch)();
	APTR			u_otrap_code;
	APTR			u_otrap_data;
#ifdef __pos__
        void                    *IRQBase;       /* IRQ.resource base */
	struct pOS_Interrupt	u_itimerint;	/* 1 interrupt / task */
#else
	struct Interrupt	u_itimerint;	/* 1 interrupt / task */
#endif

	int			p_pgrp;		/* process group */
	struct session		*u_session;	/* session pointer */

	char			*u_strtok_last;	/* moved with 37.8 */
	
	/* vfork() support */
	struct ixlist		p_zombies;	/* list of death messages */
	int			p_zombie_sig;	/* signal to set when a child died */
	struct Process		*p_pptr;	/* parent */
	struct Process		*p_opptr;	/* old parent (used in ptrace) */
	struct Process		*p_cptr;	/* last recently created child */
	struct Process		*p_osptr;	/* older sybling */
	struct Process		*p_ysptr;	/* younger sybling */
	struct vfork_msg	*p_vfork_msg;

	struct my_seg		*u_segs;	/* execve stores the SegList here */
	u_long			u_start_pc;     /* start and end addresses */
        u_long                  u_end_pc;       /* of the code hunk */
	void			(*u_oswitch)();
	
	/* stdio support comes here */
	char			u_tmpnam_buf[MAXPATHLEN]; /* quite large.. */
	u_long			u_tmpcount;
#include <glue.h>
	struct glue		u_sglue;
	/* the 3 `standard' FILE pointers (!) are here */
	void			*u_sF[3];

	/* vfork() support #2 */
	void			*u_save_sp;	/* when vfork'd, this is the `real' sp */
	jmp_buf			u_vfork_frame;	/* for the parent in vfork () */
	u_int			u_mini_stack[1000]; /* 4K stack while in vfork () */

	/* stack watcher. When usp < u_red_zone && ix.ix_watch_stack -> SIGSEGV */
	void			*u_red_zone;

	/* base relative support. This even works for pure programs ! */
	u_int			u_a4;
	
	/* currently there's just 1, meaning don't trace me */
	u_int			u_trace_flags;
	
	/* this is for getmntinfo() */
	struct statfs		*u_mntbuf;
	int			u_mntsize;
	long			u_bufsize;
	
	/* this is for SIGWINCH support. */
	struct IOStdReq		*u_idev_req;
	struct Window		*u_window;	/* the watched window */
#ifdef __pos__
	struct pOS_Interrupt	u_idev_int;
#else
	struct Interrupt	u_idev_int;
#endif

	/* for `ps' (or dump as it's called for now.. ) */
	char			*p_wmesg;
	
	/* new support for `real' process groups, control ttys etc.. */
	struct user		*p_pgrpnxt;
	struct pgrp		*p_pgrpptr;
	struct Process		*p_exec_proc;	/* to get back to struct Process */
	
	/* to be able to switch memory lists on the fly, as required when vfork'd
	   processes are supposed to allocate memory from their parents pool until
	   they detach. */
	struct malloc_data	*u_mdp;
	
	/* data needed for network support */
	struct Library		*u_ixnetbase;
	void			*u_ixnet;
	int                     *u_h_errno;

	/* ptrace() and kern_sig.c:stopped_process_handler() interface.  */
	struct reg              *u_regs;
	struct fpreg            *u_fpregs;
	int			u_mask_state;

	/* strftime() globals */
	size_t			u_gsize;
	char			*u_pt;
	
	/* putenv() global */
	int			u_env_alloced;
	
	/* rand() global */
	u_long			u_rand_next;
	
	/* stuff for stackextend */
	void			*u_tc_splower;	/* original entries of task structure */
	void			*u_tc_spupper;	/* to restore them at exit */
	void			*u_org_lower;	/* original stackborders */
	void			*u_org_upper;
	void			**u_stk_limit;	/* pointer to limit variable */
	unsigned long		u_stk_argbt;	/* Maximum size of arguments */
	struct stackframe	*u_stk_used;	/* used stackframes */
	struct stackframe	*u_stk_spare;	/* spare stackframes */
	unsigned long		u_stk_current;	/* current stack size */
	unsigned long		u_stk_max;	/* maximum stack size so far */

	char u_root_directory[MAXPATHLEN];	/* for chroot() */
	short			u_is_root;	/* current directory is root */

	/* stuff for muFS support */
	struct muUserInfo       *u_UserInfo;    /* private muUserInfo to use */
	struct muGroupInfo      *u_GroupInfo;   /* private muGroupInfo to use */
	struct muUserInfo       *u_fileUserInfo;    /* private muUserInfo for database ops */
	struct muGroupInfo      *u_fileGroupInfo;   /* private muGroupInfo for database ops */
	BOOL                    u_groupfileopen;    /* dummy for emulation */
	BOOL                    u_passwdfileopen;   /* dummy for emulation */
	struct passwd           u_passwd;       /* static buffer to hold the data */
	struct group            u_group;        /* ditto */

	FILE			*u_grp_fp;	/* File pointer to the groups file */
	int			u_grp_stayopen;	/* TRUE if group file should stay open */
	char			**u_members;	/* array of group members */
	char			*u_grp_line;	/* buffer for reading a line from the group file */

	/* Support for ixnet functions */
	FILE			*u_serv_fp;	/* File pointer to services file */
	char			*u_serv_line;	/* buffer for reading a line from the services file */
	struct servent		u_serv;
	char			**u_serv_aliases;
	int			u_serv_stayopen;
	
	FILE			*u_proto_fp;	/* File pointer to protocol file */
	char			*u_proto_line;
	struct protoent		u_proto;
	char			**u_proto_aliases;
	int			u_proto_stayopen;
	
	int                     u_logname_valid;
	char                    u_logname[MAXLOGNAME + 1];
	char                    u_logname_buf[MAXLOGNAME + 1];
	
	char			u_ntoa_buf[18];	/* used by inet_ntoa */
	
	/* resolv state structure */
	struct __res_state	*u_res;
	int			*u_res_socket;
	
	/* logfile handling */
	int			u_LogFile;	/* fd for log */
	int			u_LogStat;	/* status bits, set by openlog() */
	char			*u_LogTag;	/* string to tag the entry with */
	int			u_LogFacility;	/* default facility code */
	int			u_LogMask;	/* mask of priorities to be logged */
	
	int			u_setuid;	/* used for setuid() - have to remember
						 * to log out */
	/* mmap handling */
	struct mmap_mem		*u_mmap;

	struct MsgPort		*u_select_mp;	/* PA_SIGNAL message port */

        /* strtod support */
        void                    *u_freelist[16];
        void                    *u_p5s;
        void                    *u_result;
        int                     u_result_k;
        
        /* popen support */
        pid_t                   *u_popen_pids;

        /* uid / gid support */

	FILE			*u_pwd_fp;	/* File pointer to the passwd file */
	int			u_pwd_stayopen;	/* TRUE if passwd file should stay open */
	char			*u_pwd_line;	/* buffer for reading a line from the passwd file */

	char                    u_crypt_buf[21];

	uid_t                   u_nextuid;
        uid_t                   u_nextgid;

	uid_t                   u_ruid;
        uid_t                   u_euid;
        gid_t                   u_rgid;
        gid_t                   u_egid;
        int                     u_ngroups;
	int                     u_grouplist[NGROUPS_MAX]; /* for init/get/setgroups() */
	
	/* shm support */
	int			u_shmsize;
	int			u_shmused;
	void			**u_shmarray;
	
	/* ix_segment support */
	ix_segment              u_segment_info;
#ifdef __pos__
        struct pOS_Segment      *u_segment_ptr;
        struct pOS_SegmentLst   *u_segment_list;
#else
        short                   u_segment_no;   /* segment number (0-2) */
        long                    u_segment_ptr;
#endif
};

/* flag codes */
#define	SLOAD	0x0000001	/* in core */
#define	SSYS	0x0000002	/* swapper or pager process */
#define	SLOCK	0x0000004	/* process being swapped out */
#define	SSWAP	0x0000008	/* save area flag */
#define	STRC	0x0000010	/* process is being traced */
#define	SWTED	0x0000020	/* parent has been told that this process stopped */
#define	SULOCK	0x0000040	/* user settable lock in core */
#define	SNOCLDSTOP	0x0000080	/* tc_Launch has to take a signal next time */
#define	SFREEA4	0x0000100	/* we allocated memory for a4, free it */
#define	SOMASK	0x0000200	/* restore old mask after taking signal */
#define	SWEXIT	0x0000400	/* working on exiting */
#define	SPHYSIO	0x0000800	/* doing physical i/o (bio.c) */
#define	SVFORK	0x0001000	/* process resulted from vfork() */
#define	SVFDONE	0x0002000	/* another vfork flag */
#define	SNOVM	0x0004000	/* no vm, parent in a vfork() */
#define	SPAGI	0x0008000	/* init data space on demand, from inode */
#define	SSEQL	0x0010000	/* user warned of sequential vm behavior */
#define	SUANOM	0x0020000	/* user warned of random vm behavior */
#define	STIMO	0x0040000	/* timing out during sleep */
#define	SORPHAN	0x0080000	/* process is orphaned (can't be ^Z'ed) */
#define	STRACNG	0x0100000	/* process is tracing another process */
#define	SOWEUPC	0x0200000	/* owe process an addupc() call at next ast */
#define	SSEL	0x0400000	/* selecting; wakeup/waiting danger */
#define	SLOGIN	0x0800000	/* a login process (legit child of init) */
#define SUSAGE  0x1000000	/* we already reported the stack usage */

/* stat codes */
#define	SSLEEP	1		/* awaiting an event */
#define	SWAIT	2		/* (abandoned state) */
#define	SRUN	3		/* running */
#define	SIDL	4		/* intermediate state in process creation */
#define	SZOMB	5		/* has exited, waiting for parent to pick up status */
#define	SSTOP	6		/* stopped */

#endif /* _USER_H */
