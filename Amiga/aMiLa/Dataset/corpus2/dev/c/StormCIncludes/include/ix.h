#ifndef __IX_H
#define __IX_H

/* This header provides prototypes for ixemul specific functions and
 * variables available in ixemul.library or libc.a.
 *
 * Each function is also documented in this header (or will be). Sometimes
 * an ixemul extension is described here, but for ease of use the original
 * prototype or macro is defined elsewhere.
 */

/* Some forward declarations...
 */
struct Library;
struct __res_state;
struct timeval;
struct Process;
struct WBStartup;


/* This tells you which OS you are running on.
 */
extern int ix_os;

#define OS_IS_AMIGAOS   0
#define OS_IS_POS       0x704F5300      /* 'pOS\0' */


/* This is the name of the program without the path. E.g., if argv[0] is
 * "/gg/bin/cat", then __progname is "cat".
 */
extern char *__progname;


/* This macro can be ORed with the other flags you pass to open(). It will
 * make the open() function case sensitive. This macro is defined in
 * sys/fcntl.h.
 *
 * #define     O_CASE          0x1000
 */


/* Like vfork(), but the memory that the child allocates will be owned by
 * the child. vfork() uses the parent's memory list, but since ix_vfork() is
 * used as a fork() emulation, this would be undesirable, not in the least
 * because that memory wouldn't be released until the parent exits. Causing
 * a huge memory leak.
 */
int ix_vfork(void);


/* This function is used to obtain and set variables from ixemul.library.
 * In general, this is not a function you should call yourself.
 * Only the startup code should use this. If you need to call this
 * function for some reason, I recommend that the ix_get_variables()
 * function from crt0.c is used instead (see below).
 */
void ix_get_vars(int argc, char **ctype, int *_sys_nerr, 
 	         struct Library **sysbase, struct Library **dosbase,
 	         FILE ***fpp, char ***environ_out, char ***environ_in,
 	         int *real_errno, int *real_h_errno, struct __res_state *_res,
 	         int *_res_socket, int *ExecLib);


/* A wrapper function for ix_get_vars(). This is not an ixemul function,
 * but it is part of crt0.c. The single argument should be set to 0.
 */
void ix_get_variables(int from_vfork_setup_child);


/* This is a wrapper intended to make life just a little bit easier for those
 * who need to use the ix_vfork()/ix_vfork_resume() trick.  It replaces the old
 * 'ix_resident()/ix_get_vars()' pair.
 */
void ix_vfork_setup_child(void);


/* This is an implementation extension to the `real' ix_vfork(). Normally you
 * can only cause the parent to resume by calling _exit() or execve() from
 * the child. Since there is no real fork() in ixemul, this function
 * is a third possibility to make the parent resume. You have then two
 * concurrent processes sharing the same frame and global data. Please be
 * EXTREMELY careful what you may do and what not. ix_vfork() itself is a hack,
 * this is an even greater one...
 *
 * DO NOT use this function in combination with vfork(), or you'll get a big
 * memory leak. Only use it with ix_vfork().
 */
void ix_vfork_resume(void);


/* This function will show a requester with the given formatted string as
 * the body text and with one or two buttons. If button1 is NULL, then an
 * Abort button is shown. If button1 is not NULL, but button2 is, then only
 * a single button is shown. The title of the requester is passed in the
 * first argument. If that argument is NULL, then ixemul will use the program
 * name instead. Use this function to show a message in an OS independent
 * fashion.
 *
 * The function returns 0 is button1 is pressed and 1 otherwise.
 *
 * Example: ix_req(NULL, "Abort", NULL, "%s only supports AmigaOS!", __progname);
 * choice = ix_req(NULL, "Abort", "Continue", "Cannot find file %s", filename);
 */
int ix_req(char *title, char *button1, char *button2, char *fmt, ...);


/* Similar to chmod(), but obtains the original OS protection bits.
 * No translation to Unix protection bits has taken place.
 */
int ix_chmod(char *name, int mode);


/* Like select() but you can pass a pointer to an extra bitmask as the last
 * argument. In that case select() will also wait on these signal bits and
 * return if one of these signals came in. The contents of mask will be set
 * to the signals that arrived.
 */
int ix_select(int nfd, fd_set *ifd, fd_set *ofd, fd_set *efd,
              struct timeval *timeout, long *mask);

/* Use ix_wait instead of Wait(): this way ixemul will handle Ctrl-C correctly
 * for you and will also take care of ASYNC file streams, sending a SIGIO
 * signal if something arrives.
 */
#define ix_wait(pmask) ix_select(0, NULL, NULL, NULL, NULL, pmask)

/* This function returns the internal OS filehandle for a given ixemul file
 * descriptor. Note that this function can return 0 as not every descriptor
 * is actually a file. Use this function very restrictively: it lets you
 * use OS functions on ixemul descriptors and mixing these two can be a
 * tricky thing.
 */
long ix_filehandle(int fd);


/* These two functions can be used to walk through all the segments in a
 * segmentlist. These functions are used by gdb using segment list pointers
 * obtained through the ptrace() call. They are generally used like this:
 *
 *      ix_segment *seg;
 *
 *	for (seg = ix_get_first_segment(seglist);
 *           seg;
 *           seg = ix_get_next_segment())
 *      {
 *        .....
 *      }
 */

/* These are the possible segment type values
 */
#define IX_SEG_TYPE_UNKNOWN 0
#define IX_SEG_TYPE_TEXT    1
#define IX_SEG_TYPE_DATA    2
#define IX_SEG_TYPE_BSS     3
#define IX_SEG_TYPE_MAX     3

/* The segment info is stored in this static (!) structure.
 * So you cannot walk through two segment lists at the same time
 * in the same program.
 */
typedef struct
{
  void *start;
  unsigned long size;
  int type;
} ix_segment;


/* The function prototypes
 */
ix_segment *ix_get_first_segment(long seglist);
ix_segment *ix_get_next_segment(void);


/* Flush the instruction cache from the given address with the given
 * length.
 */
void ix_flush_insn_cache(void *addr, int length);


/* Flush the data cache from the given address with the given
 * length.
 */
void ix_flush_data_cache(void *addr, int length);


/* Flush all caches completely
 */
void ix_flush_caches(void);


/* These two function query and set certain properties of ixemul.library.
 * Given a certain ID, ix_get_long will return the corresponding value or
 * -1 if not found. Some IDs may require extra information passed in the 
 * 'extra' argument. Set to 0 unless stated otherwise in the ID
 * description.
 *
 * ix_set_long will set the value of the given ID. It returns -1 if it
 * couldn't set the value and it returns the old value otherwise.
 */
long ix_get_long(unsigned long id, unsigned long extra);
long ix_set_long(unsigned long id, long value);

/* Valid IDs: */

/* The version number of the library, output only
 */
#define IXID_VERSION      	0

/* The revision number of the library, output only
 */
#define IXID_REVISION     	1

/* Get/set the per-task freely usable user field, input/output
 */
#define IXID_USERDATA     	2

/* Get the pointer to the user struct, output only
 */
#define IXID_USER     		3

/* Get the number of reserved a4 pointers (for the shared ixlibraries),
 * output only.
 */
#define IXID_A4_PTRS   		4

/* Return TRUE if an FPU is present
 */
#define IXID_HAVE_FPU           5

/* Return CPU identification (see below)
 */
#define IXID_CPU                6

/* Return OS identification (see description of ix_os above)
 */
#define IXID_OS                 7

/* Return u_ofile[] from the user struct
 */
#define IXID_OFILE              8

/* Return u_environ from the user struct
 */
#define IXID_ENVIRON            9

/* Return u_expand_cmd_line from the user struct
 */
#define IXID_EXPAND_CMD_LINE    10


/* CPU identifications: */
#define IX_CPU_68000		0
#define IX_CPU_68010		1
#define IX_CPU_68020		2
#define IX_CPU_68030		3
#define IX_CPU_68040		4
#define IX_CPU_68060		6


/* Duplicates and releases the socket "fd" to the TCP/IP stack so
 * other processes can use it. The return value should be used with
 * obtainsocket(). NOTE: The original socket is still valid!
 */
int ix_release_socket(int fdes);

/* Gains access to the socket with id "id". id was the return value of
 * releasesocket() and the domain, type, protocol should match the arguments
 * of the socket() call.
 */
int ix_obtain_socket(long id, int inet, int stream, int protocol);

/* Structure for OS independent semaphores. The 124 bytes buffer is
 * big enough to store an AmigaOS or a p.OS semaphore and leaves enough
 * room for future expansion.
 *
 * Before using this structure you must ensure that ix_mutex_initialized
 * is 0!
 */
struct ix_mutex
{
  int  ix_mutex_initialized;
  char ix_mutex_buf[124];
};


/* Lock this mutex. Locks may be nested!
 * Returns 0 if succeeds, -1 if it fails. In case of failure, errno will
 * contain the cause. Currently it never fails, but in the future it may
 * fail and set errno to EINTR.
 */
int ix_mutex_lock(struct ix_mutex *mutex);

/* Try to lock this mutex. Locks may be nested!
 * Returns 0 if succeeds, -1 if it fails. In case of failure, errno will
 * contain the cause. If it couldn't lock the mutex, errno will be set to
 * EAGAIN.
 */
int ix_mutex_attempt_lock(struct ix_mutex *mutex);

/* Unlock the mutex.
 */
void ix_mutex_unlock(struct ix_mutex *mutex);

/* Do not use: low level functions. Required for ppc support.
 */
char **__ix_get_environ(void);
void __ix_init_ids(void);
void __ix_cli_parse(struct Process *this_proc, long alen, char *_aptr, int *argc, char ***argv);
int  __ix_wb_parse(struct Process *ThisProcess, struct WBStartup *WBenchMsg, char *default_wb_window);
void __ix_install_sigwinch (void);
void __ix_remove_sigwinch (void);

#if 0
ix_resident
// use ix_geta4 in callbacks installed using funopen() when -resident
ix_geta4
ix_check_cpu
ix_tracecntl
ix_default_wb_window
ix_get_gmt_offset
ix_set_gmt_offset
ix_get_default_settings
ix_get_settings
ix_set_settings
__init_stk_limit
__stkovf
__stkext
__stkext_f
__stkrst
#endif

#endif
