
#ifndef HANDLETOKEN_H
#define HANDLETOKEN_H

#include <indent.h>

extern void handle_the_token(
    const codes_ty   type_code,
    BOOLEAN        * scase,
    BOOLEAN        * force_nl,
    BOOLEAN        * sp_sw,
    BOOLEAN        * flushed_nl,
    codes_ty       * hd_type,
    int            * dec_ind,
    BOOLEAN        * last_token_ends_sp,
    exit_values_ty * file_exit_value,
    const bb_code_ty can_break,
    BOOLEAN        * last_else,
    BOOLEAN          is_procname_definition,
    BOOLEAN        * pbreak_line);

extern void check_code_size(void);
extern void need_chars(buf_ty * bp, size_t needed);
#endif
