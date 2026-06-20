#ifndef VM_H_
#define VM_H_

/*
        Possible Extensions

    Note: X = B, UB, W, UW, DW.

    LdAX = LdI addr;
           LdX;

    StAX = LdI addr;
           StX;
*/

/*
 * Highly inspired in Fabrice Bellard's VM for the fbcc compiler.
 */

#define VM32_STACK_ALIGN      4
#define VM32_LOCAL_START      4
#define VM32_LOCAL_PARAM_END -8

#define VM64_STACK_ALIGN      4
#define VM64_LOCAL_START      4
#define VM64_LOCAL_PARAM_END -16

/*
 *      Base types
 *
 *   b   = signed 8 bits
 *   ub  = unsigned 8 bits
 *   w   = signed 16 bits
 *   uw  = unsigned 16 bits
 *   dw  = signed 32 bits
 *   udw = unsigned 32 bits
 *   qw  = 64 bits value
 */
enum {
    OpHalt,
    OpLdB,
    OpLdUB,
    OpLdW,
    OpLdUW,
    OpLdDW,
    OpLdQW,
    OpLdN,
    OpStB,
    OpStW,
    OpStDW,
    OpStQW,
    OpStN,
    OpMemCpy,
    OpAddDW,
    OpAddQW,
    OpSubDW,
    OpSubQW,
    OpMulDW,
    OpMulQW,
    OpSDivDW,
    OpSDivQW,
    OpUDivDW,
    OpUDivQW,
    OpSModDW,
    OpSModQW,
    OpUModDW,
    OpUModQW,
    OpNegDW,
    OpNegQW,
    OpCmplDW,
    OpCmplQW,
    OpNotDW,
    OpNotQW,
    OpSLTDW,
    OpSLTQW,
    OpULTDW,
    OpULTQW,
    OpSLETDW,
    OpSLETQW,
    OpULETDW,
    OpULETQW,
    OpSGTDW,
    OpSGTQW,
    OpUGTDW,
    OpUGTQW,
    OpSGETDW,
    OpSGETQW,
    OpUGETDW,
    OpUGETQW,
    OpEQDW,
    OpEQQW,
    OpNEQDW,
    OpNEQQW,
    OpAndDW,
    OpAndQW,
    OpOrDW,
    OpOrQW,
    OpXorDW,
    OpXorQW,
    OpSLLDW,
    OpSLLQW,
    OpSRLDW,
    OpSRLQW,
    OpSRADW,
    OpSRAQW,
    OpDW2B,
    OpDW2UB,
    OpDW2W,
    OpDW2UW,
    OpDW2QW,
    OpUDW2QW,
    OpLdIDW,
    OpLdIQW,
    OpLdBP,
    OpJmpF,
    OpJmpT,
    OpJmp,
    OpSwitch,
    OpSwitch2,
    OpCall,
    OpRet,
    OpDup,
    OpDup2,
    OpPop,
    OpAddSP,
    OpSwap,
    OpSwap2,
    OpPushSP,
    OpLibCall,
    OpFill,
    OpNop,
};

#endif
