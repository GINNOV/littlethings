/* stdlib.h - vbcc PowerPC V.4-ABI */

#ifndef __CTYPE_H
#define __CTYPE_H 1

extern const unsigned char __ctype[];

int isalnum(int);
int isalpha(int);
int isblank(int);
int iscntrl(int);
int isdigit(int);
int isgraph(int);
int islower(int);
int isprint(int);
int ispunct(int);
int isspace(int);
int isupper(int);
int isxdigit(int);

#define isalpha(x)  (__ctype[(x)+1] & 3)
#define isblank(x)  ((x)==9 || (x)==32)
#define isupper(x)  (__ctype[(x)+1] & 1)
#define islower(x)  (__ctype[(x)+1] & 2)
#define isdigit(x)  (__ctype[(x)+1] & 4)
#define isxdigit(x) (__ctype[(x)+1] & 68)
#define isalnum(x)  (__ctype[(x)+1] & 7)
#define isspace(x)  (__ctype[(x)+1] & 8)
#define ispunct(x)  (__ctype[(x)+1] & 16)
#define iscntrl(x)  (__ctype[(x)+1] & 32)
#define isprint(x)  (__ctype[(x)+1] & 151)
#define isgraph(x)  (__ctype[(x)+1] & 23)

int toupper(int);
int tolower(int);

#ifndef __NOINLINE__
int toupper(__reg("r3") int) =
        "\t.extern\t__ctype\n"
        "\tlis\t11,(__ctype+1)@ha\n"
        "\taddi\t11,11,(__ctype+1)@l\n"
        "\tlbzx\t12,11,3\n"
        "\tandi.\t12,12,2\n"
        "\tbeq\t$+8\n"
        "\tsubi\t3,3,0x20\n"
        "#barrier";

int tolower(__reg("r3") int) =
        "\t.extern\t__ctype\n"
        "\tlis\t11,(__ctype+1)@ha\n"
        "\taddi\t11,11,(__ctype+1)@l\n"
        "\tlbzx\t12,11,3\n"
        "\tandi.\t12,12,1\n"
        "\tbeq\t$+8\n"
        "\taddi\t3,3,0x20\n"
        "#barrier";
#endif /* __NOINLINE__ */

#endif
