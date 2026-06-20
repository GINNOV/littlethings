/* parameter names have underscores
 * the underscores get removed in the documentation
 */
void underscore(
    /* an int */
    int __x,

    /* a pointer to an int */
    int *__y,

    /* another pointer to an int, funnily enough */
    int _z[],

    /* a char, with a strange bit legal name */
    char _,

    /* an anonymous double */
    double,

    /* pointer to a function */
    float (*__funcptr)(int *__a1, char __a2[]));
