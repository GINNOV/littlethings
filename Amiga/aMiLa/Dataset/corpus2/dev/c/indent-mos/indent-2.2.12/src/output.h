/** \file
 *
 */

#ifndef OUTPUT_H
#define OUTPUT_H

#include "sys.h" /* for RCSTAG_H */
RCSTAG_H (output, "$Id$");

#include <sys/stat.h>
#include "indent.h"

typedef struct buf_break_st
{
   struct buf_break_st *next;    /*!< The first possible break point to the right, if any. */
   struct buf_break_st *prev;    /*!< The first possible break point to the left, if any. */
   int                  offset;  /*!< The break point: the first character in the buffer that will
                                  * not be put on this line any more. */
   char *corresponds_to;         /*!< If ptr equals s_code and this equals s_code_corresponds_to,
                                  * then parser_state_toc->procname is valid. */
   int target_col;               /*!< Indentation column if we would break the line here. */
   int first_level;
   int level;                    /*!< Number of open '(' and '['. */
   int col;                      /*!< The number of columns left of the break point, before the break. */
   int priority_code_length;     /*!< Used to calculate the priority of this break point: */
   bb_code_ty priority_code;
   int priority_newline;         /*!< Set when in the input file there was a newline at this place. */
   int priority;
} buf_break_st_ty;

extern buf_break_st_ty * buf_break;

extern int           buf_break_used;
extern int           prev_target_col_break;

extern void clear_buf_break_list (
    BOOLEAN * pbreak_line);

extern int compute_code_target (
   int paren_targ);

extern int compute_label_target (void);

extern int count_columns (
   int column, 
   char *bp, 
   int stop_char);

extern void set_buf_break (
    bb_code_ty    code,
    int           paren_targ);

extern void dump_line (
    int       force_nl,
    int     * paren_targ,
    BOOLEAN * break_line);

extern void flush_output(void);

extern void open_output(
    const char * filename,
    const char * mode);
     
extern void reopen_output_trunc(
    const char * filename);

extern void close_output(
    struct stat * file_stats,
     const char  * filename);

extern void inhibit_indenting(
    BOOLEAN flag);

extern int output_line_length (void);

#endif
