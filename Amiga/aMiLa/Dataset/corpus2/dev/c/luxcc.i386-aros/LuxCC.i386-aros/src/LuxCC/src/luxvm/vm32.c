/*
 * LuxVM 32-bit version.
 *
 * This is intended to be run on 32-bit host systems, where pointers are 32-bit long.
 *
 * If your system arch is x86_64, you can still run this by compiling with gcc's `-m32'
 * switch (or luxdvr's `-mx86' switch).
 */
#include "vm.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>
#include <assert.h>
#include <errno.h>
#include "as.h"
#include "operations.h"
#include "../util/util.h"

#define DEFAULT_STACK_SIZE  32768

char *prog_name;
int32_t *stack, *data, *bss;
uint8_t *text;
int text_size, data_size, bss_size;

int vm_argc;
char **vm_argv;

/* search function used with `switch' */
int cmp_int(const void *p1, const void *p2)
{
    int32_t v1 = *(int32_t *)p1;
    int32_t v2 = *(int32_t *)p2;

    if (v1 < v2)
        return -1;
    else if (v1 == v2)
        return 0;
    else
        return 1;
}

/* search function used with `switch2' */
int cmp_int2(const void *p1, const void *p2)
{
    int64_t v1 = *(int64_t *)p1;
    int64_t v2 = *(int64_t *)p2;

    if (v1 < v2)
        return -1;
    else if (v1 == v2)
        return 0;
    else
        return 1;
}

void do_libcall(int32_t *sp, int32_t *bp, int32_t c)
{
    int32_t a;
    int32_t *p;

    switch (c) {
    case 0: /* getvars */
        p = (void *)bp[-3];
        p[0] = (int32_t)stdin;
        p[1] = (int32_t)stdout;
        p[2] = (int32_t)stderr;
        p[3] = vm_argc;
        p[4] = (int32_t)vm_argv;
        p[5] = (int32_t)&errno;
        sp[0] = 0;
        break;
    case 1: /* malloc */
        sp[0] = (int32_t)malloc(bp[-3]);
        break;
    case 2: /* free */
        free((void *)bp[-3]);
        sp[0] = 0;
        break;
    case 3: /* exit */
        exit(bp[-3]);
        break;
    case 4: /* realloc */
        p = (void *)bp[-3];
        a = bp[-4];
        sp[0] = (int32_t)realloc(p, a);
        break;
    case 5: /* fputc */
        sp[0] = fputc(bp[-3], (FILE *)bp[-4]);
        break;
    case 6: /* fgetc */
        sp[0] = fgetc((FILE *)bp[-3]);
        break;
    case 7: /* fread */
        sp[0] = fread((void *)bp[-3], bp[-4], bp[-5], (FILE *)bp[-6]);
        break;
    case 8: /* fwrite */
        sp[0] = fwrite((void *)bp[-3], bp[-4], bp[-5], (FILE *)bp[-6]);
        break;
    case 9: /* ferror */
        sp[0] = ferror((FILE *)bp[-3]);
        break;
    case 10: /* fopen */
        sp[0] = (int32_t)fopen((char *)bp[-3], (char *)bp[-4]);
        break;
    case 11: /* fclose */
        sp[0] = fclose((FILE *)bp[-3]);
        break;
    case 12: /* fseek */
        sp[0] = fseek((FILE *)bp[-3], bp[-4], bp[-5]);
        break;
    case 13: /* ftell */
        sp[0] = (int32_t)ftell((FILE *)bp[-3]);
        break;
    case 14: /* rewind */
        rewind((FILE *)bp[-3]);
        sp[0] = 0;
        break;
    case 15: /* fgets */
        sp[0] = (int32_t)fgets((char *)bp[-3], bp[-4], (FILE *)bp[-5]);
        break;
    case 16:
        sp[0] = stat((char *)bp[-3], (struct stat *)bp[-4]);
        break;
    case 17:
        sp[0] = fileno((FILE *)bp[-3]);
        break;
    case 18:
        sp[0] = isatty(bp[-3]);
        break;
    case 19:
        sp[0] = (int32_t)strtol((char *)bp[-3], (char **)bp[-4], bp[-5]);
        break;
    case 20:
        sp[0] = (int32_t)strtoul((char *)bp[-3], (char **)bp[-4], bp[-5]);
        break;
    case 21:
        ((int64_t *)sp)[0] = (int64_t)strtoll((char *)bp[-3], (char **)bp[-4], bp[-5]);
        break;
    case 22:
        ((int64_t *)sp)[0] = (int64_t)strtoull((char *)bp[-3], (char **)bp[-4], bp[-5]);
        break;
    case 23:
        sp[0] = (int32_t)system((char *)bp[-3]);
        break;
    case 24:
        sp[0] = (int32_t)remove((char *)bp[-3]);
        break;
    case 25:
        sp[0] = (int32_t)rename((char *)bp[-3], (char *)bp[-4]);
        break;
    case 26:
        sp[0] = (int32_t)fflush((FILE *)bp[-3]);
        break;
    default:
        fprintf(stderr, "libcall %d not implemented\n", c);
        break;
    }
}

int32_t *exec(void)
{
    uint8_t *ip, *ip1;
    int32_t *sp, *bp;
    int32_t a, b;
    int opcode;

    ip = text;
    sp = stack;
    bp = stack;

    while (1) {
        opcode = *ip++;
        switch (opcode) {
                /* memory read */
            case OpLdB:
                sp[0] = *(int8_t *)sp[0];
                break;
            case OpLdUB:
                sp[0] = *(uint8_t *)sp[0];
                break;
            case OpLdW:
                sp[0] = *(int16_t *)sp[0];
                break;
            case OpLdUW:
                sp[0] = *(uint16_t *)sp[0];
                break;
            case OpLdDW:
                sp[0] = *(int32_t *)sp[0];
                break;
            case OpLdQW:
                *(int64_t *)sp = *(int64_t *)sp[0];
                ++sp;
                break;
            case OpLdN: {
                int32_t n;
                uint8_t *src, *dest;

                n = *(int32_t *)ip;
                ip += sizeof(int32_t);
                src = (uint8_t *)sp[0];
                dest = (uint8_t *)sp;
                sp = (int32_t *)((int32_t)sp+round_up(n, 4)-4);
                while (n-- > 0)
                    *dest++ = *src++;
                break;
            }

                /* memory write */
            case OpStB:
                *(int8_t *)sp[0] = (int8_t)sp[-1];
                --sp;
                break;
            case OpStW:
                *(int16_t *)sp[0] = (int16_t)sp[-1];
                --sp;
                break;
            case OpStDW:
                *(int32_t *)sp[0] = sp[-1];
                --sp;
                break;
            case OpStQW:
                *(int64_t *)sp[0] = *(int64_t *)&sp[-2];
                --sp;
                break;
            case OpMemCpy:
                memmove((void *)sp[-1], (const void *)sp[0], *(uint32_t *)ip);
                ip += sizeof(uint32_t);
                --sp;
                break;

            case OpFill:
                memset((void *)sp[-1], sp[0], *(uint32_t *)ip);
                ip += sizeof(uint32_t);
                --sp;
                break;

                /* load immediate pointers */
            case OpLdBP:
                ++sp;
                sp[0] = (int32_t)bp + *(int32_t *)ip;
                ip += sizeof(int32_t);
                break;

                /* load immediate data */
            case OpLdIDW:
                ++sp;
                sp[0] = *(int32_t *)ip;
                ip += sizeof(int32_t);
                break;
            case OpLdIQW:
                ++sp;
                ((int64_t *)sp)[0] = *(int64_t *)ip;
                ++sp;
                ip += sizeof(int64_t);
                break;

                /* arithmetic */
            case OpAddDW:
                sp[-1] += sp[0];
                --sp;
                break;
            case OpAddQW:
                --sp;
                ((int64_t *)sp)[-1] += ((int64_t *)sp)[0];
                --sp;
                break;
            case OpSubDW:
                sp[-1] -= sp[0];
                --sp;
                break;
            case OpSubQW:
                --sp;
                ((int64_t *)sp)[-1] -= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpMulDW:
                sp[-1] *= sp[0];
                --sp;
                break;
            case OpMulQW:
                --sp;
                ((int64_t *)sp)[-1] *= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpSDivDW:
                sp[-1] /= sp[0];
                --sp;
                break;
            case OpSDivQW:
                --sp;
                ((int64_t *)sp)[-1] /= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpUDivDW:
                sp[-1] = (uint32_t)sp[-1]/(uint32_t)sp[0];
                --sp;
                break;
            case OpUDivQW:
                --sp;
                ((uint64_t *)sp)[-1] = ((uint64_t *)sp)[-1]/((uint64_t *)sp)[0];
                --sp;
                break;
            case OpSModDW:
                sp[-1] %= sp[0];
                --sp;
                break;
            case OpSModQW:
                --sp;
                ((int64_t *)sp)[-1] %= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpUModDW:
                sp[-1] = (uint32_t)sp[-1]%(uint32_t)sp[0];
                --sp;
                break;
            case OpUModQW:
                --sp;
                ((uint64_t *)sp)[-1] = ((uint64_t *)sp)[-1]%((uint64_t *)sp)[0];
                --sp;
                break;
            case OpNegDW:
                sp[0] = -sp[0];
                break;
            case OpNegQW:
                ((int64_t *)&sp[-1])[0] = -((int64_t *)&sp[-1])[0];
                break;
            case OpNotDW:
                sp[0] = !sp[0];
                break;
            case OpNotQW:
                --sp;
                sp[0] = !((int64_t *)sp)[0];
                break;

                /* comparisons */
            case OpSLTDW:
                sp[-1] = sp[-1]<sp[0];
                --sp;
                break;
            case OpSLTQW:
                sp -= 3;
                sp[0] = ((int64_t *)sp)[0]<((int64_t *)sp)[1];
                break;
            case OpULTDW:
                sp[-1] = (uint32_t)sp[-1]<(uint32_t)sp[0];
                --sp;
                break;
            case OpULTQW:
                sp -= 3;
                sp[0] = ((uint64_t *)sp)[0]<((uint64_t *)sp)[1];
                break;
            case OpSLETDW:
                sp[-1] = sp[-1]<=sp[0];
                --sp;
                break;
            case OpSLETQW:
                sp -= 3;
                sp[0] = ((int64_t *)sp)[0]<=((int64_t *)sp)[1];
                break;
            case OpULETDW:
                sp[-1] = (uint32_t)sp[-1]<=(uint32_t)sp[0];
                --sp;
                break;
            case OpULETQW:
                sp -= 3;
                sp[0] = ((uint64_t *)sp)[0]<=((uint64_t *)sp)[1];
                break;
            case OpSGTDW:
                sp[-1] = sp[-1]>sp[0];
                --sp;
                break;
            case OpSGTQW:
                sp -= 3;
                sp[0] = ((int64_t *)sp)[0]>((int64_t *)sp)[1];
                break;
            case OpUGTDW:
                sp[-1] = (uint32_t)sp[-1]>(uint32_t)sp[0];
                --sp;
                break;
            case OpUGTQW:
                sp -= 3;
                sp[0] = ((uint64_t *)sp)[0]>((uint64_t *)sp)[1];
                break;
            case OpSGETDW:
                sp[-1] = sp[-1]>=sp[0];
                --sp;
                break;
            case OpSGETQW:
                sp -= 3;
                sp[0] = ((int64_t *)sp)[0]>=((int64_t *)sp)[1];
                break;
            case OpUGETDW:
                sp[-1] = (uint32_t)sp[-1]>=(uint32_t)sp[0];
                --sp;
                break;
            case OpUGETQW:
                sp -= 3;
                sp[0] = ((uint64_t *)sp)[0]>=((uint64_t *)sp)[1];
                break;
            case OpEQDW:
                sp[-1] = sp[-1]==sp[0];
                --sp;
                break;
            case OpEQQW:
                sp -= 3;
                sp[0] = ((int64_t *)sp)[0]==((int64_t *)sp)[1];
                break;
            case OpNEQDW:
                sp[-1] = sp[-1]!=sp[0];
                --sp;
                break;
            case OpNEQQW:
                sp -= 3;
                sp[0] = ((int64_t *)sp)[0]!=((int64_t *)sp)[1];
                break;

                /* bitwise */
            case OpAndDW:
                sp[-1] &= sp[0];
                --sp;
                break;
            case OpAndQW:
                --sp;
                ((int64_t *)sp)[-1] &= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpOrDW:
                sp[-1] |= sp[0];
                --sp;
                break;
            case OpOrQW:
                --sp;
                ((int64_t *)sp)[-1] |= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpXorDW:
                sp[-1] ^= sp[0];
                --sp;
                break;
            case OpXorQW:
                --sp;
                ((int64_t *)sp)[-1] ^= ((int64_t *)sp)[0];
                --sp;
                break;
            case OpCmplDW:
                sp[0] = ~sp[0];
                break;
            case OpCmplQW:
                ((int64_t *)&sp[-1])[0] = ~((int64_t *)&sp[-1])[0];
                break;
            case OpSLLDW:
                sp[-1] <<= sp[0];
                --sp;
                break;
            case OpSLLQW:
                ((int64_t *)sp)[-1] <<= sp[0];
                --sp;
                break;
            case OpSRLDW:
                sp[-1] = (uint32_t)sp[-1] >> sp[0];
                --sp;
                break;
            case OpSRLQW:
                ((uint64_t *)sp)[-1] >>= sp[0];
                --sp;
                break;
            case OpSRADW:
                sp[-1] >>= sp[0];
                --sp;
                break;
            case OpSRAQW:
                ((int64_t *)sp)[-1] >>= sp[0];
                --sp;
                break;

                /* conversions */
            case OpDW2B:
                sp[0] = (int8_t)sp[0];
                break;
            case OpDW2UB:
                sp[0] = (uint8_t)sp[0];
                break;
            case OpDW2W:
                sp[0] = (int16_t)sp[0];
                break;
            case OpDW2UW:
                sp[0] = (uint16_t)sp[0];
                break;
            case OpDW2QW:
                ((int64_t *)sp)[0] = sp[0];
                ++sp;
                break;
            case OpUDW2QW:
                ((int64_t *)sp)[0] = (uint32_t)sp[0];
                ++sp;
                break;

                /* subroutines */
            case OpCall:
                a = *(int32_t *)ip; /* size of param area */
                ip += sizeof(int32_t);
                ip1 = (uint8_t *)sp[0];
                sp[0] = (int32_t)ip;
                sp[1] = (int32_t)bp;
                sp[2] = a;
                sp += 2;
                ip = ip1;
                bp = sp;
                break;
            case OpRet:
                a = sp[0]; /* return value */
                sp = bp;
                ip = (uint8_t *)sp[-2];
                bp = (int32_t *)sp[-1];
                b = sp[0]; /* size of param area */
                sp = (int32_t *)((int32_t)sp-sizeof(int32_t)*2-b); /* sizeof(int32_t)*2: old bp + ret addr */
                sp[0] = a;
                break;

                /* jumps */
            case OpJmp:
                ip1 = (uint8_t *)*(int32_t *)ip;
                ip = ip1;
                break;
            case OpJmpF:
                ip1 = (uint8_t *)*(int32_t *)ip;
                ip += sizeof(int32_t);
                if (!sp[0])
                    ip = ip1;
                --sp;
                break;
            case OpJmpT:
                ip1 = (uint8_t *)*(int32_t *)ip;
                ip += sizeof(int32_t);
                if (sp[0])
                    ip = ip1;
                --sp;
                break;

            case OpSwitch: {
                int32_t val, count;
                int32_t *tab, *p, *p_end, *res;

                val = sp[-1];
                tab = (int32_t *)sp[0];
                sp -= 2;

                p = tab;
                count = *p++;
                p_end = tab+count;

                if ((res=bsearch(&val, p, count-1, sizeof(*p), cmp_int)) == NULL)
                    ip = (uint8_t *)*p_end; /* default */
                else
                    ip = (uint8_t *)*(p_end+(res-tab));
                break;
            }
            case OpSwitch2: {
                int64_t val, count;
                int64_t *tab, *p, *res;
                int32_t *p_end;

                val = *(int64_t *)&sp[-2];
                tab = (int64_t *)sp[0];
                sp -= 3;

                p = tab;
                count = *p++;
                p_end = (int32_t *)(tab+count);

                if ((res=bsearch(&val, p, count-1, sizeof(*p), cmp_int2)) == NULL)
                    ip = (uint8_t *)*p_end;
                else
                    ip = (uint8_t *)*(p_end+(res-tab));
            }
                break;

                /* system library calls */
            case OpLibCall:
                a = *(int32_t *)ip;
                ip += sizeof(int32_t);
                ++sp;
                do_libcall(sp, bp, a);
                break;

                /* stack management */
            case OpAddSP:
                a = *(int32_t *)ip;
                ip += sizeof(int32_t);
                sp = (int32_t *)((int32_t)sp+a);
                break;
            case OpDup:
                ++sp;
                sp[0] = sp[-1];
                break;
            case OpPop:
                --sp;
                break;
            case OpSwap:
                sp[0]  ^= sp[-1];
                sp[-1] ^= sp[0];
                sp[0]  ^= sp[-1];
                break;
            case OpPushSP:
                ++sp;
                sp[0] = (int32_t)(sp-1);
                break;

            /* misc */
            case OpNop:
                break;
            case OpHalt:    /* OK */
            default:        /* error, unknown opcode */
                return sp;
        } /* switch (opcode) */
    } /* while (1) */
}

void load_code(char *file_path)
{
    int i;
    FILE *fp;
    int ndreloc, ntreloc;

    if ((fp=fopen(file_path, "rb")) == NULL)
        TERMINATE("%s: error reading file `%s'", prog_name, file_path);

    /* header */
    fread(&bss_size, sizeof(int32_t), 1, fp);
    bss = calloc(1, bss_size);
    fread(&data_size, sizeof(int32_t), 1, fp);
    fread(&text_size, sizeof(int32_t), 1, fp);
    fread(&ndreloc, sizeof(int32_t), 1, fp);
    fread(&ntreloc, sizeof(int32_t), 1, fp);

    /* data&text */
    data = malloc(data_size);
    fread(data, data_size, 1, fp);
    text = malloc(text_size);
    fread(text, text_size, 1, fp);

    /* data relocation table */
    for (i = 0; i < ndreloc; i++) {
        int32_t base;
        int32_t segment, offset;

        fread(&segment, sizeof(int32_t), 1, fp);
        fread(&offset, sizeof(int32_t), 1, fp);
        base = (segment==TEXT_SEG)?(int32_t)text:(segment==DATA_SEG)?(int32_t)data:(int32_t)bss;
        *(int32_t *)((char *)data+offset) += base;
    }

    /* text relocation table */
    for (i = 0; i < ntreloc; i++) {
        int32_t base;
        int32_t segment, offset;

        fread(&segment, sizeof(int32_t), 1, fp);
        fread(&offset, sizeof(int32_t), 1, fp);
        base = (segment==TEXT_SEG)?(int32_t)text:(segment==DATA_SEG)?(int32_t)data:(int32_t)bss;
        *(int32_t *)&text[offset] += base;
    }

    fclose(fp);
}

void disassemble_text(uint8_t *text, int text_size)
{
    uint8_t *p, *lim;

    for (p = text, lim = text+text_size; p < lim;) {
        printf("(%p) ", p);
        switch (*p++) {
        case OpHalt:    printf("halt\n");   break;
        case OpLdB:     printf("ldb\n");    break;
        case OpLdUB:    printf("ldub\n");   break;
        case OpLdW:     printf("ldw\n");    break;
        case OpLdUW:    printf("lduw\n");   break;
        case OpLdDW:    printf("lddw\n");   break;
        case OpLdQW:    printf("ldqw\n");   break;
        case OpStB:     printf("stb\n");    break;
        case OpStW:     printf("stw\n");    break;
        case OpStDW:    printf("stdw\n");   break;
        case OpStQW:    printf("stqw\n");   break;
        case OpAddDW:   printf("adddw\n");  break;
        case OpAddQW:   printf("addqw\n");  break;
        case OpSubDW:   printf("subdw\n");  break;
        case OpSubQW:   printf("subqw\n");  break;
        case OpMulDW:   printf("muldw\n");  break;
        case OpMulQW:   printf("mulqw\n");  break;
        case OpSDivDW:  printf("sdivdw\n"); break;
        case OpSDivQW:  printf("sdivqw\n"); break;
        case OpUDivDW:  printf("udivdw\n"); break;
        case OpUDivQW:  printf("udivqw\n"); break;
        case OpSModDW:  printf("smoddw\n"); break;
        case OpSModQW:  printf("smodqw\n"); break;
        case OpUModDW:  printf("umoddw\n"); break;
        case OpUModQW:  printf("umodqw\n"); break;
        case OpNegDW:   printf("negdw\n");  break;
        case OpNegQW:   printf("negqw\n");  break;
        case OpCmplDW:  printf("cmpldw\n"); break;
        case OpCmplQW:  printf("cmplqw\n"); break;
        case OpNotDW:   printf("notdw\n");  break;
        case OpNotQW:   printf("notqw\n");  break;
        case OpSLTDW:   printf("sltdw\n");  break;
        case OpSLTQW:   printf("sltqw\n");  break;
        case OpULTDW:   printf("ultdw\n");  break;
        case OpULTQW:   printf("ultqw\n");  break;
        case OpSLETDW:  printf("sletdw\n"); break;
        case OpSLETQW:  printf("sletqw\n"); break;
        case OpULETDW:  printf("uletdw\n"); break;
        case OpULETQW:  printf("uletqw\n"); break;
        case OpSGTDW:   printf("sgtdw\n");  break;
        case OpSGTQW:   printf("sgtqw\n");  break;
        case OpUGTDW:   printf("ugtdw\n");  break;
        case OpUGTQW:   printf("ugtqw\n");  break;
        case OpSGETDW:  printf("sgetdw\n"); break;
        case OpSGETQW:  printf("sgetqw\n"); break;
        case OpUGETDW:  printf("ugetdw\n"); break;
        case OpUGETQW:  printf("ugetqw\n"); break;
        case OpEQDW:    printf("eqdw\n");   break;
        case OpEQQW:    printf("eqqw\n");   break;
        case OpNEQDW:   printf("neqdw\n");  break;
        case OpNEQQW:   printf("neqqw\n");  break;
        case OpAndDW:   printf("anddw\n");  break;
        case OpAndQW:   printf("andqw\n");  break;
        case OpOrDW:    printf("ordw\n");   break;
        case OpOrQW:    printf("orqw\n");   break;
        case OpXorDW:   printf("xordw\n");  break;
        case OpXorQW:   printf("xorqw\n");  break;
        case OpSLLDW:   printf("slldw\n");  break;
        case OpSLLQW:   printf("sllqw\n");  break;
        case OpSRLDW:   printf("srldw\n");  break;
        case OpSRLQW:   printf("srlqw\n");  break;
        case OpSRADW:   printf("sradw\n");  break;
        case OpSRAQW:   printf("sraqw\n");  break;
        case OpRet:     printf("ret\n");    break;
        case OpDup:     printf("dup\n");    break;
        case OpPop:     printf("pop\n");    break;
        case OpNop:     printf("nop\n");    break;
        case OpSwap:    printf("swap\n");   break;
        case OpSwitch:  printf("switch\n"); break;
        case OpPushSP:  printf("pushsp\n"); break;
        case OpSwitch2: printf("switch2\n");break;
        case OpDW2B:    printf("dw2b\n");   break;
        case OpDW2UB:   printf("dw2ub\n");  break;
        case OpDW2W:    printf("dw2w\n");   break;
        case OpDW2UW:   printf("dw2uw\n");  break;
        case OpDW2QW:   printf("dw2qw\n");  break;
        case OpUDW2QW:  printf("udw2qw\n"); break;
        case OpLdIDW:   printf("ldidw ");   printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpLdIQW:   printf("ldiqw ");   printf("%llx\n", *(int64_t *)p);p+=sizeof(int64_t); break;
        case OpLdBP:    printf("ldbp ");    printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpJmpF:    printf("jmpf ");    printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpJmpT:    printf("jmpt ");    printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpJmp:     printf("jmp ");     printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpCall:    printf("call ");    printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpFill:    printf("fill ");    printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpLdN:     printf("ldn ");     printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpStN:     printf("stn ");     printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpMemCpy:  printf("memcpy ");  printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpAddSP:   printf("addsp ");   printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        case OpLibCall: printf("libcall "); printf("%x\n", *(int32_t *)p);  p+=sizeof(int32_t); break;
        default: assert(0);
        }
    }
}

void disassemble_data(int32_t *data, int32_t data_size)
{
    uint8_t *p, *lim;

    for (p = (uint8_t *)data, lim = (uint8_t *)data+data_size; p < lim;) {
        printf("(%p) ", p);
        printf("%x\n", *(int32_t *)p);
        p += sizeof(int32_t);
    }
}

void vm_usage(void)
{
    printf("usage: %s [vm-options] <program> [program-arguments]\n", prog_name);
    exit(0);
}

int main(int argc,char *argv[])
{
    /*
                [ Program image ]

    +-------------------------------------------------+ <-text
    | Text                                            |
    +-------------------------------------------------+

    +-------------------------------------------------+ <-bss
    | Bss                                             |
    +-------------------------------------------------+

    +-------------------------------------------------+ <-data
    | Data                                            |
    +-------------------------------------------------+

    +-------------------------------------------------+ <-stack
    | Stack                                           |
    +-------------------------------------------------+
    */
    int i;
    int disas;
    char *infile;
    int32_t *sp;
    int stack_size;

    prog_name = argv[0];
    if (argc == 1)
        vm_usage();
    infile = NULL;
    disas = FALSE;
    stack_size = DEFAULT_STACK_SIZE;
    for (i = 1; i < argc; i++) {
        if (argv[i][0] != '-') {
            infile = argv[i];
            break;
        }
        switch (argv[i][1]) {
        case 's':
            if (argv[i][2] != '\0') {
                stack_size = atol(argv[i]+2);
            } else if (argv[i+1] == NULL) {
                fprintf(stderr, "%s: option `s' requires an argument\n", prog_name);
                exit(1);
            } else {
                stack_size = atol(argv[++i]);
            }
            break;
        case 'd':
            disas = TRUE;
            break;
        case 'h':
            printf("usage: %s [vm-options] <program> [program-arguments]\n"
                   "  The available options are:\n"
                   "    -s<size>    specify stack size\n"
                   "    -d          disassemble code and data after loading\n"
                   "    -h          print this help\n", prog_name);
            exit(0);
            break;
        case '\0':
            break;
        default:
            fprintf(stderr, "%s: unknown option `%s'\n", prog_name, argv[i]);
            exit(1);
        }
    }
    if (infile == NULL)
        vm_usage();

    load_code(infile);
    if (disas) {
        printf("Bss:  (%d zero bytes)\n", bss_size);
        printf("Data: (%d bytes)\n", data_size);
        if (data_size)
            disassemble_data(data, data_size);
        printf("Code: (%d bytes)\n", text_size);
        disassemble_text(text, text_size);
    }
    stack = malloc(stack_size*sizeof(long));
    vm_argc = argc-i;
    vm_argv = argv+i;
    sp = exec();

    return *sp;
}
