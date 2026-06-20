#ifndef HCE_INOUT_H
#define HCE_INOUT_H

#ifndef WORKBENCH_STARTUP_H
#include <workbench/startup.h>
#endif

/* Copyright (c) 1994, by Jason Petty.
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *
 *    Defines and Prototypes used by Hce_InOut.c
 */

#define T_INLEN       1024   /* Max Chars read at any one time. */

#define IO_LOAD     0        /* Modes used by Get_IO_NAME() */
#define IO_SAVE     1
#define IO_DELETE   2
#define IO_RUN      3
#define IO_LOCK     4
#define IO_LCONFIG  5
#define IO_SCONFIG  6
#define IO_SOURCE   7
#define IO_DEST     8
#define IO_MAKEDIR  9
#define IO_ASSIGN   10
#define IO_PATH     11
#define IO_RENAME1  13
#define IO_RENAME2  14

extern char IO_FileName[T_MAXSTR];
extern char In_buffer[T_INLEN];
extern struct WBArg *io_arglist;

/***************** PROTOTYPES *****************/
char *StripFN();
WORD lock_HceConfig();
int file_exists(), Get_IO_NAME(), IO_readfile(), DirToCurrent();
int IO_Save_AS(), IO_writefile(), write_CONFIG(), read_CONFIG();
int AppendFile(), copy_FILE();
void DiskToList(),Clear_FRDir(),Clear_FRFile(),save_ALIST(),load_ALIST();
void Print_IO_ERR(), StripPATH(), dump_Cstuff(), dump_Ostuff();
void dump_Astuff(), dump_Lstuff(), dump_Other();
int read_Cstuff(), read_Ostuff(), read_Astuff(), read_Lstuff();

#endif
