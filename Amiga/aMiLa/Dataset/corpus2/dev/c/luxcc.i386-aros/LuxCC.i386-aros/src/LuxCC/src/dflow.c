/*
 * Iterative data-flow analyses.
 */
#define DEBUG 0
#include "dflow.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "util/util.h"
#include "ic.h"
#include "expr.h"
#include "util/bset.h"
#include "util/arena.h"

static
void print_id_set(BSet *s)
{
    int i, c;

    c = bset_card(s);
    for (i = bset_iterate(s); i != -1; i = bset_iterate(NULL))
        printf("%s%s", nid2sid_tab[i], (c--!=1)?", ":"");
}

// =======================================================================================
// Reaching definitions
// =======================================================================================
#if 0
typedef struct VarDefPoint VarDefPoint;
static struct VarDefPoint {
    unsigned dp;
    VarDefPoint *next;
} **variable_definition_points;
static Arena *vdp_arena;

static void reach_print_set(BSet *s, unsigned first);
static void reach_init_block(unsigned b, unsigned ninstr, unsigned first);

void reach_print_set(BSet *s, unsigned first)
{
    unsigned i, c;

    c = bset_card(s);
    for (i = bset_iterate(s); i != -1; i = bset_iterate(NULL))
        printf("%d%s", i+first, (c--!=1)?", ":"");
}

void reach_init_block(unsigned b, unsigned ninstr, unsigned first)
{
    int i;
    BSet *defined_names;
    BSet *DEDef, *DefKill;

    defined_names = bset_new(nid_counter);
    DEDef = bset_new(ninstr);
    DefKill = bset_new(ninstr);

    for (i = cfg_node(b).last; i >= (int)cfg_node(b).leader; i--) {
        int tar_nid;
        unsigned tar/*, arg1, arg2*/;

        tar = instruction(i).tar;
        /*arg1 = instruction(i).arg1;
        arg2 = instruction(i).arg2;*/

        switch (instruction(i).op) {
        case OpCall:
        case OpIndCall:
            if (!tar)
                continue;
        case OpAdd: case OpSub: case OpMul: case OpDiv:
        case OpRem: case OpSHL: case OpSHR: case OpAnd:
        case OpOr: case OpXor: case OpEQ: case OpNEQ:
        case OpLT: case OpLET: case OpGT: case OpGET:
        case OpNeg: case OpCmpl: case OpNot: case OpCh:
        case OpUCh: case OpSh: case OpUSh: case OpAsn:
        case OpAddrOf: case OpInd:
            tar_nid = address_nid(tar);
            if (!bset_member(defined_names, tar_nid)) {
                VarDefPoint *p;

                bset_insert(DEDef, i-first);
                for (p = variable_definition_points[tar_nid]; p != NULL; p = p->next)
                    bset_insert(DefKill, p->dp-first);
                bset_delete(DefKill, i-first);
                bset_insert(defined_names, tar_nid);
            }
            continue;

        default:
            continue;
        }
    }
    cfg_node(b).DEDef = DEDef;
    cfg_node(b).DefKill = DefKill;
    bset_free(defined_names);
}

void dflow_ReachIn(unsigned fn, int is_last)
{
    BSet *temp, *new_in;
    unsigned entry_bb, exit_bb;
    unsigned i, changed, ninstr;

    if (cg_node_is_empty(fn))
        return;

    entry_bb = cg_node(fn).bb_i;
    exit_bb = cg_node(fn).bb_f;
    ninstr = cfg_node(exit_bb).last-cfg_node(entry_bb).leader+1;

    for (i = entry_bb; i <= exit_bb; i++) {
        reach_init_block(i, ninstr, cfg_node(entry_bb).leader);

#if DEBUG
        printf("DEDef[B%d]=", i);
        reach_print_set(cfg_node(i).DEDef, cfg_node(entry_bb).leader);
        printf("\n\n");

        printf("DefKill[B%d]=", i);
        reach_print_set(cfg_node(i).DefKill, cfg_node(entry_bb).leader);
        printf("\n\n");
#endif

        /* all ReachIn sets are initially empty */
        cfg_node(i).ReachIn = bset_new(ninstr);
    }

    temp = bset_new(ninstr);
    new_in = bset_new(ninstr);

    changed = TRUE;
    while (changed) {
        DEBUG_PRINTF("==> ReachIn solver iteration\n");
        changed = FALSE;
        for (i = entry_bb; i <= exit_bb; i++) {
            unsigned pred, b;

            b = CFG_RPO[i];
            for (pred = edge_iterate(&cfg_node(b).in); pred != -1; pred = edge_iterate(NULL)) {
                bset_cpy(temp, cfg_node(pred).ReachIn);
                bset_diff(temp, cfg_node(pred).DefKill);
                bset_union(temp, cfg_node(pred).DEDef);
                bset_union(new_in, temp);
            }
            if (!bset_eq(cfg_node(b).ReachIn, new_in)) {
                bset_cpy(cfg_node(b).ReachIn, new_in);
                changed = TRUE;
            }
            bset_clear(new_in);
        }
    }
    bset_free(temp), bset_free(new_in);
    if (is_last) {
        free(variable_definition_points);
        arena_destroy(vdp_arena);
    } else {
        memset(variable_definition_points, 0, nid_counter*sizeof(VarDefPoint *));
        arena_reset(vdp_arena);
    }

#if DEBUG
    for (i = entry_bb; i <= exit_bb; i++) {
        printf("ReachIn[%u]=", i);
        reach_print_set(cfg_node(i).ReachIn, cfg_node(entry_bb).leader);
        printf("\n\n");
    }
#endif
}
#endif
// =======================================================================================
// Dominance
// =======================================================================================
static void dom_print_set(BSet *s);

void dom_print_set(BSet *s)
{
    int i, c;

    c = bset_card(s);
    for (i = bset_iterate(s); i != -1; i = bset_iterate(NULL))
        printf("%d%s", i, (c--!=1)?", ":"");
}

void dflow_Dom(unsigned fn)
{
    /*
     * TBD:
     * Unreachable code (e.g. the one caused by 'return' statements)
     * makes the exit node be dominated by itself only.
     */

    int i, changed;
    BSet *N, *temp;
    unsigned entry_bb, exit_bb;

    if (cg_node_is_empty(fn))
        return;

    entry_bb = cg_node(fn).bb_i;
    exit_bb = cg_node(fn).bb_f;

    /* Dom(n0) = { n0 } */
    cfg_node(entry_bb).Dom = bset_new(cfg_nodes_counter);
    bset_insert(cfg_node(entry_bb).Dom, entry_bb);

    /* N = all nodes of the CFG */
    N = bset_new(cfg_nodes_counter);
    for (i = entry_bb; i <= exit_bb; i++)
        bset_insert(N, i);

    /* for every n != n0, Dom(n) = N */
    for (i = entry_bb+1; i <= exit_bb; i++) {
        cfg_node(i).Dom = bset_new(cfg_nodes_counter);
        bset_cpy(cfg_node(i).Dom, N);
    }

    /* working set */
    temp = bset_new(cfg_nodes_counter);

    /* solve equations */
    changed = TRUE;
    while (changed) {
        DEBUG_PRINTF("==> Dom solver iteration\n");
        changed = FALSE;
        for (i = entry_bb+1; i <= exit_bb; i++) {
            int j, i2;
            unsigned pred;

            i2 = cfg_node(i).RPO;
            assert(i2 >= entry_bb);
            assert(i2 <= exit_bb);
            if ((pred = cfg_node(i2).in.edges[0])) {
                bset_cpy(temp, cfg_node(pred).Dom);
                for (j = 1; j<cfg_node(i2).in.n && (pred=cfg_node(i2).in.edges[j]); j++)
                    bset_inters(temp, cfg_node(pred).Dom);
            }
            bset_insert(temp, i2);

            if (!bset_eq(temp, cfg_node(i2).Dom)) {
                bset_cpy(cfg_node(i2).Dom, temp);
                changed = TRUE;
            }
            bset_clear(temp);
        }
    }
    bset_free(N), bset_free(temp);

#if DEBUG
        printf("Dominance, function: `%s'\n", cg_node(fn).func_id);
        for (i = cg_node(fn).bb_i; i <= cg_node(fn).bb_f; i++) {
            printf("Dom(n%d) = { ", i);
            dom_print_set(cfg_node(i).Dom);
            printf(" }\n");
        }
#endif
}

// =======================================================================================
// Live analysis.
// =======================================================================================
static void live_init_block(unsigned b, int exit_bb);
static BSet *live_tmp;
static BSet *modified_static_objects;

/*
 * Compute UEVar(b) and VarKill(b).
 * Also keep track of variables' definition points for later use in Reaching Definitions.
 */
void live_init_block(unsigned b, int exit_bb)
{
    unsigned i;
    BSet *UEVar, *VarKill;

    /* sets initially empty */
    UEVar = bset_new(nid_counter);
    VarKill = bset_new(nid_counter);

    if (exit_bb)
        bset_cpy(UEVar, modified_static_objects);

    for (i = cfg_node(b).leader; i <= cfg_node(b).last; i++) {
        unsigned tar, arg1, arg2;

        tar = instruction(i).tar;
        arg1 = instruction(i).arg1;
        arg2 = instruction(i).arg2;

        switch (instruction(i).op) {
#define add_UEVar(e)\
    if (!bset_member(VarKill, address_nid(e)))\
        bset_insert(UEVar, address_nid(e))
#define add_VarKill(e)\
    bset_insert(VarKill, address_nid(e))
/*#define add_VarDefPoint(e)\
    do {\
        VarDefPoint **p;\
\
        p = &variable_definition_points[address_nid(e)];\
        if (*p == NULL) {\
            *p = arena_alloc(vdp_arena, sizeof(VarDefPoint));\
            (*p)->dp = i;\
            (*p)->next = NULL;\
        } else {\
            VarDefPoint *q;\
\
            q = arena_alloc(vdp_arena, sizeof(VarDefPoint));\
            q->dp = i;\
            q->next = *p;\
            *p = q;\
        }\
    } while (0)*/

        case OpAdd: case OpSub: case OpMul: case OpDiv:
        case OpRem: case OpSHL: case OpSHR: case OpAnd:
        case OpOr: case OpXor: case OpEQ: case OpNEQ:
        case OpLT: case OpLET: case OpGT: case OpGET:
            if (!const_addr(arg1))
                add_UEVar(arg1);
            if (!const_addr(arg2))
                add_UEVar(arg2);
            add_VarKill(tar);
            // add_VarDefPoint(tar);
            continue;

        case OpAsn: /* keep track of static objects modified by this function */
            if ((address(tar).kind == IdKind)
            && (address(tar).cont.var.e->attr.var.duration == DURATION_STATIC))
                bset_insert(modified_static_objects, address_nid(tar));
        case OpNeg: case OpCmpl: case OpNot: case OpCh:
        case OpUCh: case OpSh: case OpUSh:  case OpLLSX:
        case OpLLZX:
            if (!const_addr(arg1))
                add_UEVar(arg1);
            add_VarKill(tar);
            // add_VarDefPoint(tar);
            continue;

        case OpArg:
        case OpRet:
        case OpSwitch:
        case OpCBr:
            if (!const_addr(arg1))
                add_UEVar(arg1);
            continue;

        case OpAddrOf:
            add_VarKill(tar);
            // add_VarDefPoint(tar);
            continue;

        case OpInd:
            /*
             * For safety, overestimate ambiguous indirect
             * references (assume all address-taken variables
             * are referenced).
             */
            bset_cpy(live_tmp, address_taken_variables);
            bset_diff(live_tmp, VarKill);
            bset_union(UEVar, live_tmp);

            add_UEVar(arg1);
            add_VarKill(tar);
            // add_VarDefPoint(tar);
            continue;

        case OpIndAsn:
            /*
             * Must-point-to information is required in order
             * to include pointer targets in the VarKill set.
             * For safety, underestimate ambiguous indirect
             * assignments (assume no variables are modified).
             */
            if (!const_addr(arg2))
                add_UEVar(arg2);
            add_UEVar(arg1);
            continue;

        case OpCall:
        case OpIndCall:
            bset_cpy(live_tmp, address_taken_variables);
            bset_union(live_tmp, modified_static_objects);
            bset_diff(live_tmp, VarKill);
            bset_union(UEVar, live_tmp);

            if (instruction(i).op==OpIndCall && !const_addr(arg1))
                add_UEVar(arg1);
            if (tar) {
                add_VarKill(tar);
                // add_VarDefPoint(tar);
            }
            continue;

        default:
            continue;
        }
    }
    cfg_node(b).UEVar = UEVar;
    cfg_node(b).VarKill = VarKill;
}

/* compute LiveOut for all the blocks of the CFG */
void dflow_LiveOut(unsigned fn)
{
    BSet *new_out;
    unsigned i, changed;
    unsigned entry_bb, exit_bb;

    if (cg_node_is_empty(fn))
        return;

    entry_bb = cg_node(fn).bb_i;
    exit_bb = cg_node(fn).bb_f;
    // variable_definition_points = calloc(nid_counter, sizeof(VarDefPoint *));
    // vdp_arena = arena_new(sizeof(VarDefPoint)*32);
    live_tmp = bset_new(nid_counter);
    modified_static_objects = bset_new(nid_counter);

    /* gather initial information */
    for (i = entry_bb; i <= exit_bb; i++) {
        live_init_block(i, i == exit_bb);

#if DEBUG
        printf("UEVar[%d]=", i);
        print_id_set(cfg_node(i).UEVar);
        printf("\n\n");

        printf("VarKill[%d]=", i);
        print_id_set(cfg_node(i).VarKill);
        printf("\n\n");
#endif

        /* all LiveOut sets are initially empty */
        cfg_node(i).LiveOut = bset_new(nid_counter);
    }
    cg_node(fn).modified_static_objects = modified_static_objects;

    new_out = bset_new(nid_counter);

    /* solve equations */
    changed = TRUE;
    while (changed) {
        DEBUG_PRINTF("==> LiveOut solver iteration\n");
        changed = FALSE;
        for (i = entry_bb; i <= exit_bb; i++) {
            unsigned succ, b;

            b = cfg_node(i).PO;
            assert(b >= entry_bb);
            assert(b <= exit_bb);
            /*
             * LiveOut(b) = the union of all successors of b, where the contribution
             *              of each successor m is       __________
             *                  UEVar(m) U (LiveOut(m) ∩ VarKill(m))
             */
            for (succ = edge_iterate(&cfg_node(b).out); succ != -1; succ = edge_iterate(NULL)) {
                bset_cpy(live_tmp, cfg_node(succ).LiveOut);
                bset_diff(live_tmp, cfg_node(succ).VarKill);
                bset_union(live_tmp, cfg_node(succ).UEVar);
                bset_union(new_out, live_tmp);
            }
            if (!bset_eq(cfg_node(b).LiveOut, new_out)) {
                bset_cpy(cfg_node(b).LiveOut, new_out);
                changed = TRUE;
            }
            bset_clear(new_out);
        }
    }
    bset_free(live_tmp), bset_free(new_out);

#if DEBUG
    for (i = entry_bb; i <= exit_bb; i++) {
        printf("LiveOut[%d]=", i);
        print_id_set(cfg_node(i).LiveOut);
        printf("\n\n");
    }
#endif
}

/*
 * Liveness and next-use.
 */

unsigned char *liveness_and_next_use;
static BSet *operand_liveness;
static BSet *operand_next_use;

#if DEBUG
static void print_liveness_and_next_use(unsigned fn);
#endif

/*
 * Initialize the operand table with the liveness
 * and next use as of the end of the block.
 * Liveness is determined using the LiveOut set.
 */
static void init_operand_table(BSet *block_LiveOut)
{
    bset_clear(operand_next_use);
    bset_cpy(operand_liveness, block_LiveOut);
}

static void compute_function_liveness_and_next_use(unsigned fn)
{
    int b;
    unsigned entry_bb, last_bb;

    if (cg_node_is_empty(fn))
        return;

    entry_bb = cg_node(fn).bb_i;
    last_bb = cg_node(fn).bb_f;

    /* annotate the quads of every block with liveness and next-use information */
    for (b = entry_bb; b <= last_bb; b++) {
        int i;

        init_operand_table(cfg_node(b).LiveOut);

        /* scan backward through the block */
        for (i = cfg_node(b).last; i >= (int)cfg_node(b).leader; i--) {
            unsigned tar, arg1, arg2;

            tar = instruction(i).tar;
            arg1 = instruction(i).arg1;
            arg2 = instruction(i).arg2;
            switch (instruction(i).op) {
#define update_tar()\
        do {\
            int tar_nid;\
\
            tar_nid = address_nid(tar);\
            if (bset_member(operand_liveness, tar_nid)) {\
                liveness_and_next_use[i] |= TAR_LIVE_MASK;\
                bset_delete(operand_liveness, tar_nid);\
            } else {\
                /*liveness_and_next_use[i] &= ~TAR_LIVE_MASK;*/\
            }\
            if (bset_member(operand_next_use, tar_nid)) {\
                liveness_and_next_use[i] |= TAR_NEXT_MASK;\
                bset_delete(operand_next_use, tar_nid);\
            } else {\
                /*liveness_and_next_use[i] &= ~TAR_NEXT_MASK;*/\
            }\
        } while (0)
#define update_arg1()\
        do {\
            int arg1_nid;\
\
            arg1_nid = address_nid(arg1);\
            if (bset_member(operand_liveness, arg1_nid)) {\
                liveness_and_next_use[i] |= AR1_LIVE_MASK;\
            } else {\
                /*liveness_and_next_use[i] &= ~AR1_LIVE_MASK;*/\
                bset_insert(operand_liveness, arg1_nid);\
            }\
            if (bset_member(operand_next_use, arg1_nid)) {\
                liveness_and_next_use[i] |= AR1_NEXT_MASK;\
            } else {\
                /*liveness_and_next_use[i] &= ~AR1_NEXT_MASK;*/\
                bset_insert(operand_next_use, arg1_nid);\
            }\
        } while (0)
#define update_arg2()\
        do {\
            int arg2_nid;\
\
            arg2_nid = address_nid(arg2);\
            if (bset_member(operand_liveness, arg2_nid)) {\
                liveness_and_next_use[i] |= AR2_LIVE_MASK;\
            } else {\
                /*liveness_and_next_use[i] &= ~AR2_LIVE_MASK;*/\
                bset_insert(operand_liveness, arg2_nid);\
            }\
            if (bset_member(operand_next_use, arg2_nid)) {\
                liveness_and_next_use[i] |= AR2_NEXT_MASK;\
            } else {\
                /*liveness_and_next_use[i] &= ~AR2_NEXT_MASK;*/\
                bset_insert(operand_next_use, arg2_nid);\
            }\
        } while (0)

            case OpAdd: case OpSub: case OpMul: case OpDiv:
            case OpRem: case OpSHL: case OpSHR: case OpAnd:
            case OpOr: case OpXor: case OpEQ: case OpNEQ:
            case OpLT: case OpLET: case OpGT: case OpGET:
                update_tar();
                if (!const_addr(arg1))
                    update_arg1();
                if (!const_addr(arg2))
                    update_arg2();
                continue;

            case OpNeg: case OpCmpl: case OpNot: case OpCh:
            case OpAsn: case OpUCh: case OpSh: case OpUSh:
            case OpLLSX: case OpLLZX:
                update_tar();
                if (!const_addr(arg1))
                    update_arg1();
                continue;

            case OpArg:
            case OpRet:
            case OpSwitch:
            case OpCBr:
                if (!const_addr(arg1))
                    update_arg1();
                continue;

            case OpAddrOf:
                update_tar();
                continue;

            case OpInd:
                update_tar();
                update_arg1();
                bset_union(operand_liveness, address_taken_variables);
                continue;

            case OpIndAsn:
                update_arg1();
                if (!const_addr(arg2))
                    update_arg2();
                continue;

            case OpCall:
            case OpIndCall:
                if (tar)
                    update_tar();
                if (instruction(i).op==OpIndCall && !const_addr(arg1))
                    update_arg1();
                bset_union(operand_liveness, cg_node(fn).modified_static_objects);
                bset_union(operand_liveness, address_taken_variables);
                continue;

            default: /* other */
                continue;
            } /* switch (instruction(i).op) */
        } /* instructions */
    } /* basic blocks */

#if DEBUG
    print_liveness_and_next_use(fn);
#endif
}

#if DEBUG
void print_liveness_and_next_use(unsigned fn)
{
    int b;
    unsigned entry_bb, last_bb;

    entry_bb = cg_node(fn).bb_i;
    last_bb = cg_node(fn).bb_f;

    for (b = entry_bb; b <= last_bb; b++) {
        int i;

        printf("Block %d\n", b);

        for (i = cfg_node(b).leader; i <= cfg_node(b).last; i++) {
            unsigned tar, arg1, arg2;

            tar = instruction(i).tar;
            arg1 = instruction(i).arg1;
            arg2 = instruction(i).arg2;
            switch (instruction(i).op) {
#define print_tar()\
        printf("name=%s, ", address_sid(tar)),\
        printf("status=%s, ", tar_liveness(i)?"LIVE":"DEAD"),\
        printf("next use=%d", !!tar_next_use(i))
#define print_arg1()\
        printf("name=%s, ", address_sid(arg1)),\
        printf("status=%s, ", arg1_liveness(i)?"LIVE":"DEAD"),\
        printf("next use=%d", !!arg1_next_use(i))
#define print_arg2()\
        printf("name=%s, ", address_sid(arg2)),\
        printf("status=%s, ", arg2_liveness(i)?"LIVE":"DEAD"),\
        printf("next use=%d", !!arg2_next_use(i))

            case OpAdd: case OpSub: case OpMul: case OpDiv:
            case OpRem: case OpSHL: case OpSHR: case OpAnd:
            case OpOr: case OpXor: case OpEQ: case OpNEQ:
            case OpLT: case OpLET: case OpGT: case OpGET:
                print_tar();
                if (!const_addr(arg1)) {
                    printf(" | ");
                    print_arg1();
                }
                if (!const_addr(arg2)) {
                    printf(" | ");
                    print_arg2();
                }
                break;

            case OpNeg: case OpCmpl: case OpNot: case OpCh:
            case OpUCh: case OpSh: case OpUSh: case OpAsn:
            case OpSXLL: case OpZXLL:
                print_tar();
                if (!const_addr(arg1)) {
                    printf(" | ");
                    print_arg1();
                }
                break;

            case OpArg:
            case OpRet:
            case OpSwitch:
            case OpCBr:
                if (!const_addr(arg1)) {
                    print_arg1();
                }
                break;

            case OpAddrOf:
                print_tar();
                break;

            case OpInd:
                print_tar();
                printf(" | ");
                print_arg1();
                break;

            case OpIndAsn:
                print_arg1();
                if (!const_addr(arg2)) {
                    printf(" | ");
                    print_arg2();
                }
                break;

            case OpCall:
            case OpIndCall:
                if (tar)
                    print_tar();
                if (!const_addr(arg1)) {
                    printf(" | ");
                    print_arg1();
                }
                break;

            default:
                continue;
            } /* instructions */
            printf("\n--------------\n");
        } /* basic blocks */
        printf("\n\n");
    }
}
#endif

void compute_liveness_and_next_use(void)
{
    int i;

    liveness_and_next_use = calloc(ic_instructions_counter, sizeof(unsigned char));
    operand_liveness = bset_new(nid_counter);
    operand_next_use = bset_new(nid_counter);
    for (i = 0; i < cg_nodes_counter; i++)
        compute_function_liveness_and_next_use(i);
    bset_free(operand_liveness);
    bset_free(operand_next_use);
}
