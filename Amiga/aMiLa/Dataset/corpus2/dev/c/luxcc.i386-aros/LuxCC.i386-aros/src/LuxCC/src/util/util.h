#ifndef UTIL_H_
#define UTIL_H_

#define TRUE  1
#define FALSE 0

#if DEBUG
#define DEBUG_PRINTF(...) fprintf(stderr, __VA_ARGS__)
#else
#define DEBUG_PRINTF(...)
#endif

#define TERMINATE(...) fprintf(stderr, __VA_ARGS__), fprintf(stderr, "\n"), exit(EXIT_FAILURE)

#define equal(s, t)     (strcmp((s), (t)) == 0)
#define not_equal(s, t) (strcmp((s), (t)) != 0)

#define NELEMS(a) (sizeof(a)/sizeof(a[0]))
#define is_po2(x) (x!=0 && (x & (x-1))==0)
#define MAX(a, b) ((a) > (b) ? (a) : (b))

unsigned long hash2(unsigned long k);
unsigned hash(char *s);
int round_up(int num, int mul);
int ilog2(unsigned val);
int file_exists(char *file_path);
char *replace_extension(char *fname, char *newext);
int be_atoi(char *s);
char *read_file(char *path);

#endif
