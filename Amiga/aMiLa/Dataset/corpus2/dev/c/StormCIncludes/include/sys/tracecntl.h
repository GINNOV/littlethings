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

#ifndef _SYS_TRACECNTL_H
#define _SYS_TRACECNTL_H

#include <sys/types.h>
#include <sys/syscall.h>
#include <exec/ports.h>

struct trace_packet {
  struct Message tp_message;
  struct MsgPort *tp_tracer_port;	/* set this up before INSTALL !! */
  int		 tp_flags;		/* currently ignored, *must* be 0 !! */
  pid_t		 tp_pid;		/* pid, or 0 to trace all but self */
  enum _syscall_ tp_syscall;		/* sc, or 0 to trace all */
  /* these are the arguments filled in on a trace message */
  int		 tp_is_entry;		/* true when entry, false when exit */
  int		 *tp_argv;		/* arguments of the function.
  					   argv[0] is always the syscall,
  					   argv[1] is the result if !tp_is_entry,
  					   now follows the return address in
  					   the program that did this call, then
					   the following elements are the
					   arguments to the function */
  int		 *tp_errno;		/* the address of the process errno */
  /* here you can specify actions to be performed when you reply to this msg */
  int		 tp_action;		/* available values see below */
};

#define TRACE_ACTION_JSR	1	/* jsr into the syscall, and trace
					   result (with tp_is_entry == 0) */
#define TRACE_ACTION_JMP	0	/* jmp into the syscall, no result trace */
#define TRACE_ACTION_RTS	-1	/* causes the syscall to return with
					   the value in argv[0] without actually
					   performing the call */
#define TRACE_ACTION_ABORT	2	/* causes the process to call abort() */


/* these are the commands available in tracecntl (): */
enum trace_cmd {
	/* install a trace handling packet. for INSTALL_TRACE_HANDLER you
	   have to initialize :
	     tp_tracer_port	here's where the packet is sent
	     tp_pid		get notice for this pid (0 for all)
	     tp_syscall		get notice for this syscall (0 for all)
	 */
  TRACE_INSTALL_HANDLER,

	/* remove the installed packet. Don't (!) do this if the handler
	   is expecting a reply from you. */
  TRACE_REMOVE_HANDLER,

	/* to be extended ;-)) */
};

/* results:
   0:  handler installed
   -1: handler not installed, library configured without tracecntl support */
int tracecntl (enum trace_cmd, struct trace_packet *);

#endif /* _SYS_TRACECNTL */
