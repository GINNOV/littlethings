#ifndef IMP_LIM_H_
#define IMP_LIM_H_

/*
 * Some implementation limits (not necessarily standard-compliant).
 */

#define MAX_NEST            16   /* maximum block nesting level (blocks without locals don't count) */
#define MAX_SWITCH_NEST     16
#define MAX_LOG_LINE_LEN    4095
#define MAX_CASE_LABELS     1024 /* for a single switch statement */
#define MAX_GOTOS_PER_FUNC  64

#endif
