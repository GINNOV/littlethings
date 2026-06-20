#include "operations.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "../util/util.h"
#include "vm.h"

static Operation operations[] = {
    /* operations with no operand */
    { "halt",       OpHalt,     0 },
    { "ldb",        OpLdB,      0 },
    { "ldub",       OpLdUB,     0 },
    { "ldw",        OpLdW,      0 },
    { "lduw",       OpLdUW,     0 },
    { "lddw",       OpLdDW,     0 },
    { "ldqw",       OpLdQW,     0 },
    { "stb",        OpStB,      0 },
    { "stw",        OpStW,      0 },
    { "stdw",       OpStDW,     0 },
    { "stqw",       OpStQW,     0 },
    { "adddw",      OpAddDW,    0 },
    { "subdw",      OpSubDW,    0 },
    { "muldw",      OpMulDW,    0 },
    { "sdivdw",     OpSDivDW,   0 },
    { "udivdw",     OpUDivDW,   0 },
    { "smoddw",     OpSModDW,   0 },
    { "umoddw",     OpUModDW,   0 },
    { "addqw",      OpAddQW,    0 },
    { "subqw",      OpSubQW,    0 },
    { "mulqw",      OpMulQW,    0 },
    { "sdivqw",     OpSDivQW,   0 },
    { "udivqw",     OpUDivQW,   0 },
    { "smodqw",     OpSModQW,   0 },
    { "umodqw",     OpUModQW,   0 },
    { "negdw",      OpNegDW,    0 },
    { "cmpldw",     OpCmplDW,   0 },
    { "notdw",      OpNotDW,    0 },
    { "negqw",      OpNegQW,    0 },
    { "cmplqw",     OpCmplQW,   0 },
    { "notqw",      OpNotQW,    0 },
    { "sltdw",      OpSLTDW,    0 },
    { "ultdw",      OpULTDW,    0 },
    { "sletdw",     OpSLETDW,   0 },
    { "uletdw",     OpULETDW,   0 },
    { "sgtdw",      OpSGTDW,    0 },
    { "ugtdw",      OpUGTDW,    0 },
    { "sgetdw",     OpSGETDW,   0 },
    { "ugetdw",     OpUGETDW,   0 },
    { "eqdw",       OpEQDW,     0 },
    { "neqdw",      OpNEQDW,    0 },
    { "sltqw",      OpSLTQW,    0 },
    { "ultqw",      OpULTQW,    0 },
    { "sletqw",     OpSLETQW,   0 },
    { "uletqw",     OpULETQW,   0 },
    { "sgtqw",      OpSGTQW,    0 },
    { "ugtqw",      OpUGTQW,    0 },
    { "sgetqw",     OpSGETQW,   0 },
    { "ugetqw",     OpUGETQW,   0 },
    { "eqqw",       OpEQQW,     0 },
    { "neqqw",      OpNEQQW,    0 },
    { "anddw",      OpAndDW,    0 },
    { "ordw",       OpOrDW,     0 },
    { "xordw",      OpXorDW,    0 },
    { "slldw",      OpSLLDW,    0 },
    { "srldw",      OpSRLDW,    0 },
    { "sradw",      OpSRADW,    0 },
    { "andqw",      OpAndQW,    0 },
    { "orqw",       OpOrQW,     0 },
    { "xorqw",      OpXorQW,    0 },
    { "sllqw",      OpSLLQW,    0 },
    { "srlqw",      OpSRLQW,    0 },
    { "sraqw",      OpSRAQW,    0 },
    { "dw2b",       OpDW2B,     0 },
    { "dw2ub",      OpDW2UB,    0 },
    { "dw2w",       OpDW2W,     0 },
    { "dw2uw",      OpDW2UW,    0 },
    { "dw2qw",      OpDW2QW,    0 },
    { "udw2qw",     OpUDW2QW,   0 },
    { "ret",        OpRet,      0 },
    { "dup",        OpDup,      0 },
    { "dup2",       OpDup2,     0 },
    { "pop",        OpPop,      0 },
    { "nop",        OpNop,      0 },
    { "swap",       OpSwap,     0 },
    { "swap2",      OpSwap2,    0 },
    { "switch",     OpSwitch,   0 },
    { "switch2",    OpSwitch2,  0 },
    { "pushsp",     OpPushSP,   0 },
    /* operations with operand */
    { "ldn",        OpLdN,      1 },
    { "memcpy",     OpMemCpy,   1 },
    { "stn",        OpStN,      1 },
    { "ldidw",      OpLdIDW,    1 },
    { "ldiqw",      OpLdIQW,    1 },
    { "ldbp",       OpLdBP,     1 },
    { "jmpf",       OpJmpF,     1 },
    { "jmpt",       OpJmpT,     1 },
    { "jmp",        OpJmp,      1 },
    { "call",       OpCall,     1 },
    { "addsp",      OpAddSP,    1 },
    { "fill",       OpFill,     1 },
    { "libcall",    OpLibCall,  1 },
};

static int cmp_op(const void *p1, const void *p2)
{
    Operation *x1 = (Operation *)p1;
    Operation *x2 = (Operation *)p2;

    return strcmp(x1->str, x2->str);
}

Operation *lookup_operation(char *op_str)
{
    Operation key, *res;
    static int sorted = FALSE;

    if (!sorted) {
        qsort(operations, NELEMS(operations), sizeof(operations[0]), cmp_op);
        sorted = TRUE;
    }

    key.str = op_str;
    res = bsearch(&key, operations, NELEMS(operations), sizeof(operations[0]), cmp_op);

    return res;
}
