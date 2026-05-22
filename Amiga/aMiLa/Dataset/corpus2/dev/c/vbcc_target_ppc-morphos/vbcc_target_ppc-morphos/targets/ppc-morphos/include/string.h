/* string.h - vbcc PowerPC */

#ifndef __STRING_H
#define __STRING_H 1

#ifndef __SIZE_T
#define __SIZE_T 1
typedef unsigned long size_t;
#endif

#undef NULL
#define NULL ((void *)0)

void *memcpy(void *,const void *,size_t);
void *memmove(void *,const void *,size_t);
char *strcpy(char *,const char *);
char *strncpy(char *,const char *,size_t);
char *strcat(char *,const char *);
char *strncat(char *,const char *,size_t);
int memcmp(const void *,const void *,size_t);
int strcmp(const char *,const char *);
int strncmp(const char *,const char *,size_t);
void *memchr(const void *,int,size_t);
char *strchr(const char *,int);
size_t strcspn(const char *,const char *);
char *strpbrk(const char *,const char *);
char *strrchr(const char *,int);
size_t strspn(const char *,const char *);
char *strstr(const char *,const char *);
void *memset(void *,int,size_t);
size_t strlen(const char *);
char *strtok(char *,const char *);
char *strerror(int);
int strcoll(const char *,const char *);
size_t strxfrm(char *,const char *,size_t);

#ifndef __NOINLINE__
/* PowerPC inline functions */
size_t __asm_strlen(__reg("r3") const char *) =
                "\tsubi\t4,3,1\n"
                "#barrier\n"
                "\tlbzu\t0,1(4)\n"
                "\tcmpwi\t0,0\n"
                "\tbne\t$-8\n"
                "\tsub\t3,4,3";
char *__asm_strcpy(__reg("r3") char *, __reg("r4") const char *) =
                "\tsubi\t5,3,1\n"
                "\tsubi\t4,4,1\n"
                "#barrier\n"
                "\tlbzu\t0,1(4)\n"
                "\tstbu\t0,1(5)\n"
                "\tcmpwi\t0,0\n"
                "\tbne\t$-12";
char *__asm_strncpy(__reg("r3") char *, __reg("r4") const char *,
                    __reg("r5") size_t) =
                "\tcmpwi\t5,0\n"
                "\tbeq\t$+36\n"
                "\tmtctr\t5\n"
                "\tsubi\t5,3,1\n"
                "#barrier\n"
                "\tlbz\t0,0(4)\n"
                "\tstbu\t0,1(5)\n"
                "\tcmpwi\t0,0\n"
                "\tbeq\t$+8\n"
                "\taddi\t4,4,1\n"
                "\tbdnz\t$-20";
int __asm_strcmp(__reg("r3") const char *, __reg("r4") const char *) =
                "\tsubi\t5,3,1\n"
                "\tsubi\t4,4,1\n"
                "#barrier\n"
                "\tlbzu\t3,1(5)\n"
                "\tlbzu\t6,1(4)\n"
                "\tsub.\t3,3,6\n"
                "\tbne\t$+12\n"
                "\tcmpwi\t6,0\n"
                "\tbne\t$-20";
int __asm_strncmp(__reg("r3") const char *, __reg("r4") const char *,
                  __reg("r5") size_t) =
                "\tsubi\t6,3,1\n"
                "\tli\t3,0\n"
                "\tcmpwi\t5,0\n"
                "\tbeq\t$+36\n"
                "\tsubi\t4,4,1\n"
                "\tmtctr\t5\n"
                "#barrier\n"
                "\tlbzu\t3,1(6)\n"
                "\tlbzu\t5,1(4)\n"
                "\tsub.\t3,3,5\n"
                "\tbne\t$+12\n"
                "\tcmpwi\t5,0\n"
                "\tbdnzf\t2,$-20";
int __asm_memcmp(__reg("r3") const void *, __reg("r4") const void *,
                 __reg("r5") size_t) =
                "\tmtctr\t5\n"
                "\tsubi\t6,3,1\n"
                "\tsubi\t4,4,1\n"
                "\tmr.\t3,5\n"
                "\tbeq\t$+20\n"
                "#barrier\n"
                "\tlbzu\t3,1(6)\n"
                "\tlbzu\t5,1(4)\n"
                "\tsubf.\t3,5,3\n"
                "\tbdnzt\t2,$-12";

#define strlen(p) __asm_strlen(p)
#define strcpy(d,s) __asm_strcpy(d,s)
#define strncpy(d,s,n) __asm_strncpy(d,s,n)
#define strcmp(s1,s2) __asm_strcmp(s1,s2)
#define strncmp(s1,s2,n) __asm_strncmp(s1,s2,n)
#define memcmp(s1,s2,n) __asm_memcmp(s1,s2,n)
#endif /* __NOINLINE__ */

#endif
