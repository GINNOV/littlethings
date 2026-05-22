#ifndef AS_H_
#define AS_H_

enum { /* Symbol.kind */
    LOCAL_SYM,
    GLOBAL_SYM,
    EXTERN_SYM
};

enum {
    DATA_SEG,
    TEXT_SEG,
    BSS_SEG
};

#define MAX_SYM_LEN 64 /* symbol name max length */

#endif
