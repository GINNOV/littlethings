/* The FlashSort1 Algorithm                *
 *                                         *
 * as described by Karl-Dietrich Neubert   *
 * in Dr. Dobb's Journal, February 1998    *
 *                                         *
 * adapted to ANSI C for research purposes *
 * by Andreas R. Kleinert in 1998          *
 *                                         */

typedef int sort_type;

extern void flashsort(sort_type *array, int num, int *ind, int numind);
