/*
 * Intermediate code generator
 *  AST ==> IC
 */
#define DEBUG 0
#include "ic.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "util/util.h"
#include "decl.h"
#include "expr.h"
#include "util/arena.h"
#include "imp_lim.h"
#include "loc.h"
#include "dflow.h"
#include "util/bset.h"
#include "ast2c.h"
#include "luxcc.h"

#define ID_TABLE_SIZE 1009
typedef struct IDNode IDNode;
typedef struct SwitchLabel SwitchLabel;
typedef struct Label Label;

#define IINIT   1024
#define IGROW   2
unsigned ic_instructions_max;
unsigned ic_instructions_counter;
Quad *ic_instructions;

char **C_source;

#define AINIT   IINIT*3
#define AGROW   2
unsigned ic_addresses_max;
unsigned ic_addresses_counter;
Address *ic_addresses;

#define NINIT   128
#define NGROW   2
unsigned cfg_nodes_max;
unsigned cfg_nodes_counter;
CFGNode *cfg_nodes;

#define CINIT   32
#define CGROW   2
unsigned cg_nodes_max;
unsigned cg_nodes_counter;
CGNode *cg_nodes;

static int label_counter, label_max;
static unsigned *lab2instr;
static unsigned true_addr, false_addr;
static unsigned memset_addr, memcpy_addr;
static ExecNode memset_node, memcpy_node;
static TypeExp int_expr = { TOK_INT };
static Declaration int_ty = { &int_expr };
static TypeExp unsigned_expr = { TOK_UNSIGNED };
static Declaration unsigned_ty = { &unsigned_expr };
static TypeExp long_expr = { TOK_LONG };
static Declaration long_ty = { &long_expr };
ExternId *static_objects_list;
static unsigned curr_cg_node;
static unsigned ic_func_first_instr;
static unsigned exit_label;
static Arena *temp_names_arena;

static FILE *cg_dotfile;
static FILE *cfg_dotfile;
static FILE *ic_file;

/*
 * x86 stuff.
 */
#define X86_PARAM_END 8 /* ebp+8 */
/* ---- */

/*
 * x64 stuff.
 */
#define X64_PARAM_END 16 /* rbp+16 */
static ExecNode *base_node;
static struct {
    unsigned gp_offset;         /* offset from reg_save_area */
    unsigned reg_save_area;     /* offset from rbp */
    unsigned overflow_arg_area; /* offset from rbp */
} va_arg_data;
/* ---- */

/*
 * x86/x64 stuff.
 */
/* the amount of space to allocate for the current function's local variables */
int size_of_local_area = 0;
/* used to compute the addresses of local variables */
static int local_offset;
/* ---- */

/*
 * MIPS stuff
 */
#define MIPS_ARM_PARAM_END 8 /* 8($fp) */
/* --- */

static Arena *id_table_arena;
static struct IDNode {
    char *sid;
    int nid;
    int scope;
    IDNode *next;
} *id_table[ID_TABLE_SIZE];

int nid_counter;
static int nid_max;
char **nid2sid_tab;

static int *atv_table;
static int atv_counter, atv_max;
BSet *address_taken_variables;

static void ic_out_of_memory(char *func)
{
    TERMINATE("error: %s(): out of memory", func);
}

static void new_nid(char *sid)
{
    if (nid_counter >= nid_max) {
        char **p;

        nid_max *= 2;
        if ((p=realloc(nid2sid_tab, nid_max*sizeof(char *))) == NULL)
            ic_out_of_memory("new_nid");
        nid2sid_tab = p;
    }
    nid2sid_tab[nid_counter++] = sid;
}

int get_var_nid(char *sid, int scope)
{
    IDNode *np;
    unsigned h;

    h = hash(sid)%ID_TABLE_SIZE;
    for (np = id_table[h]; np != NULL; np = np->next)
        if (equal(np->sid, sid) && np->scope==scope)
            return np->nid;
    np = arena_alloc(id_table_arena, sizeof(IDNode));
    np->sid = sid;
    np->scope = scope;
    np->nid = nid_counter;
    np->next = id_table[h];
    id_table[h] = np;
    new_nid(sid);
    return np->nid;
}

static void edge_init(GraphEdge *p, unsigned max)
{
    p->edges = calloc(max, sizeof(unsigned));
    p->max = max;
    p->n = 0;
}

static void edge_free(GraphEdge *p)
{
    free(p->edges);
}

void edge_add(GraphEdge *p, unsigned e)
{
    unsigned i;

    for (i = 0; i < p->n; i++)
        if (p->edges[i] == e)
            return;

    if (p->n >= p->max) {
        unsigned *new_edges;

        p->max *= 2;
        if ((new_edges=realloc(p->edges, p->max*sizeof(unsigned))) == NULL)
            ic_out_of_memory("edge_add");
        p->edges = new_edges;
    }
    p->edges[p->n++] = e;
}

unsigned edge_iterate(GraphEdge *p)
{
    static unsigned n, *curr;

    if (p != NULL) {
        n = p->n;
        curr = p->edges;
    }
    if (n) {
        --n;
        return *curr++;
    }
    return (unsigned)-1;
}

unsigned new_cg_node(char *func_id)
{
    unsigned i;

    for (i = 0; i < cg_nodes_counter; i++)
        if (equal(cg_nodes[i].func_id, func_id))
            return i;
    if (cg_nodes_counter >= cg_nodes_max) {
        CGNode *p;

        /* grow */
        cg_nodes_max *= CGROW;
        if ((p=realloc(cg_nodes, cg_nodes_max*sizeof(CGNode))) == NULL)
            ic_out_of_memory("new_cg_node");
        cg_nodes = p;
    }
    memset(&cg_nodes[cg_nodes_counter], 0, sizeof(CGNode));
    cg_nodes[cg_nodes_counter].func_id = func_id;
    edge_init(&cg_nodes[cg_nodes_counter].out, 1);
    return cg_nodes_counter++;
}

static void new_cfg_node(unsigned leader)
{
    if (cfg_nodes_counter >= cfg_nodes_max) {
        CFGNode *p;

        /* grow */
        cfg_nodes_max *= NGROW;
        if ((p=realloc(cfg_nodes, cfg_nodes_max*sizeof(CFGNode))) == NULL)
            ic_out_of_memory("new_cfg_node");
        cfg_nodes = p;
    }
    cfg_nodes[cfg_nodes_counter].leader = leader;
    edge_init(&cfg_nodes[cfg_nodes_counter].out, 2);
    edge_init(&cfg_nodes[cfg_nodes_counter].in, 5);
    ++cfg_nodes_counter;
}

static void emit_i(OpKind op, Declaration *type, unsigned tar, unsigned arg1, unsigned arg2)
{
    if (ic_instructions_counter >= ic_instructions_max) {
        void *p;
        unsigned old_max;

        /* grow */
        old_max = ic_instructions_max;
        ic_instructions_max *= IGROW;
        if ((p=realloc(ic_instructions, ic_instructions_max*sizeof(Quad))) == NULL)
            ic_out_of_memory("emit_i");
        ic_instructions = p;

        if (verbose_asm) {
            if ((p=realloc(C_source, ic_instructions_max*sizeof(char *))) == NULL)
                ic_out_of_memory("emit_i");
            C_source = p;
            memset(C_source+old_max, 0, sizeof(char *)*(ic_instructions_max-old_max));
        }
    }
    ic_instructions[ic_instructions_counter].op = op;
    ic_instructions[ic_instructions_counter].type = type;
    ic_instructions[ic_instructions_counter].tar = tar;
    ic_instructions[ic_instructions_counter].arg1 = arg1;
    ic_instructions[ic_instructions_counter].arg2 = arg2;
    ++ic_instructions_counter;
}

static void emit_src(char *s)
{
    C_source[ic_instructions_counter] = s;
}

static unsigned new_address(AddrKind kind)
{
    if (ic_addresses_counter >= ic_addresses_max) {
        Address *p;

        /* grow */
        ic_addresses_max *= AGROW;
        if ((p=realloc(ic_addresses, ic_addresses_max*sizeof(Address))) == NULL)
            ic_out_of_memory("new_address");
        ic_addresses = p;
    }
    memset(&ic_addresses[ic_addresses_counter], 0, sizeof(Address));
    ic_addresses[ic_addresses_counter].kind = kind;

    return ic_addresses_counter++;
}

static unsigned new_temp_addr(void)
{
    unsigned n;
    char s[10], *p;
    static unsigned t_counter = 1;

    n = new_address(TempKind);
    p = arena_alloc(temp_names_arena, sprintf(s, "t%u", t_counter++)+1);
    address(n).cont.nid = nid_counter;
    new_nid(strcpy(p, s));

    return n;
}

static unsigned new_label(void)
{
    unsigned L;

    if (label_counter >= label_max) {
        unsigned *p;

        label_max *= 2;
        if ((p=realloc(lab2instr, label_max*sizeof(unsigned))) == NULL)
            ic_out_of_memory("new_label");
        lab2instr = p;
    }
    L = new_address(IConstKind);
    address(L).cont.val = label_counter++;

    return L;
}

static void emit_label(unsigned L)
{
    lab2instr[address(L).cont.val] = ic_instructions_counter;
    emit_i(OpLab, NULL, L, 0, 0);
}

static void new_atv(int vnid)
{
    if (atv_counter >= atv_max) {
        int *p;

        atv_max *= 2;
        if ((p=realloc(atv_table, atv_max*sizeof(int))) == NULL)
            ic_out_of_memory("new_atv");
        atv_table = p;
    }
    atv_table[atv_counter++] = vnid;
}

static void ic_init(void)
{
    location_init();

    /* init instruction buffer */
    if ((ic_instructions=malloc(IINIT*sizeof(Quad))) == NULL)
        goto out_mem;
    ic_instructions_max = IINIT;
    ic_instructions_counter = 0;

    if (verbose_asm && (C_source=calloc(1, ic_instructions_max*sizeof(char *)))==NULL)
        goto out_mem;

    /* init address buffer */
    if ((ic_addresses=malloc(AINIT*sizeof(Address))) == NULL)
        goto out_mem;
    ic_addresses_max = AINIT;
    ic_addresses_counter = 1; /* address 0 is reserved for 'empty' */

    /* init CFG buffer */
    if ((cfg_nodes=malloc(NINIT*sizeof(CFGNode))) == NULL)
        goto out_mem;
    cfg_nodes_max = NINIT;
    cfg_nodes_counter = 1; /* 0 reserved for null node */

    /* init CG buffer */
    if ((cg_nodes=malloc(CINIT*sizeof(CGNode))) == NULL)
        goto out_mem;
    cg_nodes_max = CINIT;
    cg_nodes_counter = 0;

    /* init nid -> sid table */
    if ((nid2sid_tab=malloc(128*sizeof(char *))) == NULL)
        goto out_mem;
    nid_max = 128;
    nid_counter = 0;

    id_table_arena = arena_new(256, FALSE);
    temp_names_arena = arena_new(256, FALSE);

    true_addr = new_address(IConstKind);
    address(true_addr).cont.uval = 1;
    false_addr = new_address(IConstKind);
    address(false_addr).cont.uval = 0;

    memset_node.attr.str = "memset";
    memset_addr = new_address(IdKind);
    address(memset_addr).cont.nid = get_var_nid("memset", 0);
    address(memset_addr).cont.var.e = &memset_node;

    memcpy_node.attr.str = "memcpy";
    memcpy_addr = new_address(IdKind);
    address(memcpy_addr).cont.nid = get_var_nid("memcpy", 0);
    address(memcpy_addr).cont.var.e = &memcpy_node;

    label_max = 64;
    if ((lab2instr=malloc(label_max*sizeof(unsigned))) == NULL)
        goto out_mem;

    atv_max = 32;
    if ((atv_table=malloc(atv_max*sizeof(int))) == NULL)
        goto out_mem;
    atv_counter = 0;

    return;
out_mem:
    ic_out_of_memory("ic_init");
}

static void ic_reset(void)
{
    label_counter = 0;
    /* x86/x64 stuff */
    size_of_local_area = 0;
    local_offset = 0;
    base_node = NULL;
}

#if 0
static void ic_free_all(void)
{
    unsigned i;

    free(ic_instructions);
    free(ic_addresses);
    for (i = 1; i < cfg_nodes_counter; i++) {
        edge_free(&cfg_node(i).out);
        edge_free(&cfg_node(i).in);
        bset_free(cfg_node(i).UEVar);
        bset_free(cfg_node(i).VarKill);
        bset_free(cfg_node(i).LiveOut);
        bset_free(cfg_node(i).Dom);
    }
    free(cfg_nodes);
    for (i = 0; i < cg_nodes_counter; i++) {
        edge_free(&cg_node(i).out);
        if (!cg_node_is_empty(i))
            bset_free(cg_node(i).modified_static_objects);
    }
    free(cg_nodes);
    arena_destroy(id_table_arena);
    arena_destroy(temp_names_arena);
    free(lab2instr);
    free(nid2sid_tab);
}
#endif

/* find address-taken variables in a single static initializer expression */
static void ic_find_atv_in_expr(ExecNode *e)
{
    if (e->kind.exp == OpExp) {
        switch (e->attr.op) {
        case TOK_DOT:
        case TOK_ARROW:
        case TOK_ADDRESS_OF:
        case TOK_INDIRECTION:
        case TOK_CAST:
            ic_find_atv_in_expr(e->child[0]);
            break;
        case TOK_SUBSCRIPT:
        case TOK_PLUS:
        case TOK_MINUS:
            ic_find_atv_in_expr(e->child[0]);
            ic_find_atv_in_expr(e->child[1]);
            break;
        case TOK_CONDITIONAL:
            if (e->child[0]->attr.val)
                ic_find_atv_in_expr(e->child[1]);
            else
                ic_find_atv_in_expr(e->child[2]);
            break;
        default:
            assert(0);
        }
    } else if (e->kind.exp == IdExp) {
        new_atv(get_var_nid(e->attr.str, e->attr.var.scope));
    }
}

/* find address-taken variables in static initializer (scalar or bracketed) */
static void ic_find_atv_in_init(TypeExp *ds, TypeExp *dct, ExecNode *e)
{
    TypeExp *ts;

    if (dct != NULL) {
        if (dct->op != TOK_SUBSCRIPT)
            goto scalar;
        if (e->kind.exp == StrLitExp)
            return;
        for (e = e->child[0]; e != NULL; e = e->sibling)
            ic_find_atv_in_init(ds, dct->child, e);
    } else if ((ts=get_type_spec(ds))->op == TOK_STRUCT) {
        DeclList *d;

        e = e->child[0];
        d = ts->attr.dl;
        for (; d != NULL; d = d->next) {
            dct = d->decl->idl;
            for (; e!=NULL && dct!=NULL; e=e->sibling, dct=dct->sibling)
                ic_find_atv_in_init(d->decl->decl_specs, dct->child, e);
            if (e == NULL)
                break;
        }
    } else if (ts->op == TOK_UNION) {
        e = e->child[0];
        ic_find_atv_in_init(ts->attr.dl->decl->decl_specs, ts->attr.dl->decl->idl->child, e);
    } else {
scalar:
        if (e->kind.exp==OpExp && e->attr.op==TOK_INIT_LIST)
            e = e->child[0];
        ic_find_atv_in_expr(e);
    }
}

/* find address-taken variables in static initializers */
static void ic_find_atv(void)
{
    ExternId *np;

    for (np = static_objects_list; np != NULL; np = np->next)
        if (np->declarator->attr.e != NULL)
            ic_find_atv_in_init(np->decl_specs, np->declarator->child, np->declarator->attr.e);
}

static void ic_simplify(void)
{
    unsigned i;

    for (i = ic_func_first_instr; i < ic_instructions_counter; i++) {
        unsigned /*tar,*/ arg1, arg2;

        /*tar = instruction(i).tar;*/
        arg1 = instruction(i).arg1;
        arg2 = instruction(i).arg2;

        switch (instruction(i).op) {
#define is_iconst(a) (address(a).kind == IConstKind)
#define fold(_i_, _op_) (\
    instruction(_i_).op = OpAsn,\
    address(arg1).kind = IConstKind,\
    address(arg1).cont.val = address(arg1).cont.val _op_ address(arg2).cont.val)
#define fold2(_i_, _op_)\
    do {\
        instruction(_i_).op = OpAsn;\
        address(arg1).kind = IConstKind;\
        if (is_unsigned_int(get_type_category(instruction(i).type)))\
            address(arg1).cont.uval = address(arg1).cont.uval _op_ address(arg2).cont.uval;\
        else\
            address(arg1).cont.val = address(arg1).cont.val _op_ address(arg2).cont.val;\
    } while (0)

        /*
         * x = 0+y => x = y
         * x = y+0 => x = y
         */
        case OpAdd:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2)) {
                    fold(i, +);
                } else if (address(arg1).cont.val == 0) {
                    instruction(i).op = OpAsn;
                    instruction(i).arg1 = arg2;
                }
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
            }
            break;
        /*
         * x = 0-y => x = -y
         * x = y-0 => x = y
         */
        case OpSub:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2)) {
                    fold(i, -);
                } else if (address(arg1).cont.val == 0) {
                    instruction(i).op = OpNeg;
                    instruction(i).arg1 = arg2;
                }
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
            }
            break;
        /*
         * x = 0*y  => x = 0
         * x = 1*y  => x = y
         * x = -1*y => x = -y
         * x = p*y  => x = y<<n (with p == 2^n)
         * x = y*0  => x = 0
         * x = y*1  => x = y
         * x = y*-1 => x = -y
         * x = y*p  => x = y<<n
         */
        case OpMul:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2)) {
                    fold(i, *);
                } else if (address(arg1).cont.val == 0) {
                    instruction(i).op = OpAsn;
                } else if (address(arg1).cont.val == 1) {
                    instruction(i).op = OpAsn;
                    instruction(i).arg1 = arg2;
                } else if (address(arg1).cont.val == -1) {
                    instruction(i).op = OpNeg;
                    instruction(i).arg1 = arg2;
                } else if (is_po2(address(arg1).cont.uval)) {
                    instruction(i).op = OpSHL;
                    address(arg1).cont.uval = ilog2(address(arg1).cont.uval);
                    instruction(i).arg1 = arg2;
                    instruction(i).arg2 = arg1;
                }
            } else if (is_iconst(arg2)) {
                if (address(arg2).cont.val == 0) {
                    instruction(i).op = OpAsn;
                    address(arg1).kind = IConstKind;
                    address(arg1).cont.val = 0;
                } else if (address(arg2).cont.val == 1) {
                    instruction(i).op = OpAsn;
                } else if (address(arg2).cont.val == -1) {
                    instruction(i).op = OpNeg;
                } else if (is_po2(address(arg2).cont.uval)) {
                    instruction(i).op = OpSHL;
                    address(arg2).cont.uval = ilog2(address(arg2).cont.uval);
                }
            }
            break;
        /*
         * x = 0/y => x = 0
         * x = y/1 => x = y
         *
         * The following will only work with unsigned numbers (or when
         * y has a positive value, but of course we may not know that).
         * x = y/p => x = y>>n (with p == 2^n)
         */
        case OpDiv:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2))
                    fold2(i, /);
                else if (address(arg1).cont.val == 0)
                    instruction(i).op = OpAsn;
            } else if (is_iconst(arg2)) {
                if (address(arg2).cont.val==1) {
                    instruction(i).op = OpAsn;
                } else if (is_po2(address(arg2).cont.uval)
                && is_unsigned_int(get_type_category(instruction(i).type))) {
                    instruction(i).op = OpSHR;
                    address(arg2).cont.uval = ilog2(address(arg2).cont.uval);
                }
            }
            break;
        /*
         * x = 0%y => x = 0
         * x = y%1 => x = 0
         *
         * The following will only work under the same constraints as
         * for the division case.
         * x = y%p => x = y & (p-1) (with p being a power of two)
         */
        case OpRem:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2))
                    fold2(i, %);
                else if (address(arg1).cont.val == 0)
                    instruction(i). op = OpAsn;
            } else if (is_iconst(arg2)) {
                if (address(arg2).cont.val==1) {
                    instruction(i).op = OpAsn;
                    address(arg1).kind = IConstKind;
                    address(arg1).cont.val = 0;
                } else if (is_po2(address(arg2).cont.uval)
                && is_unsigned_int(get_type_category(instruction(i).type))) {
                    instruction(i).op = OpAnd;
                    address(arg2).cont.uval = address(arg2).cont.uval-1;
                }
            }
            break;
        /*
         * x = 0<<y => x = 0
         * x = y<<0 => x = y
         */
        case OpSHL:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2))
                    fold(i, <<);
                else if (address(arg1).cont.val == 0)
                    instruction(i).op = OpAsn;
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
            }
            break;
        /*
         * x = 0>>y => x = 0
         * x = y>>0 => x = y
         */
        case OpSHR:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2))
                    fold2(i, >>);
                else if (address(arg1).cont.val == 0)
                    instruction(i).op = OpAsn;
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
            }
            break;
        /*
         * x = 0&y => x = 0
         * x = y&0 => x = 0
         */
        case OpAnd:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2))
                    fold(i, &);
                else if (address(arg1).cont.val == 0)
                    instruction(i).op = OpAsn;
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
                instruction(i).arg1 = arg2;
            }
            break;
        /*
         * x = 0|y => x = y
         * x = y|0 => x = y
         */
        case OpOr:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2)) {
                    fold(i, |);
                } else if (address(arg1).cont.val == 0) {
                    instruction(i).op = OpAsn;
                    instruction(i).arg1 = arg2;
                }
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
            }
            break;
        /*
         * x = 0^y => x = y
         * x = y^0 => x = y
         */
        case OpXor:
            if (is_iconst(arg1)) {
                if (is_iconst(arg2)) {
                    fold(i, ^);
                } else if (address(arg1).cont.val == 0) {
                    instruction(i).op = OpAsn;
                    instruction(i).arg1 = arg2;
                }
            } else if (is_iconst(arg2) && address(arg2).cont.val==0) {
                instruction(i).op = OpAsn;
            }
            break;
        case OpEQ:
            if (is_iconst(arg1) && is_iconst(arg2)) {
                fold(i, ==);
                instruction(i).type = &int_ty;
            }
            break;
        case OpNEQ:
            if (is_iconst(arg1) && is_iconst(arg2)) {
                fold(i, !=);
                instruction(i).type = &int_ty;
            }
            break;
        case OpLT:
            if (is_iconst(arg1) && is_iconst(arg2)) {
                instruction(i).op = OpAsn;
                address(arg1).kind = IConstKind;
                if ((long)instruction(i).type & IC_SIGNED)
                    address(arg1).cont.val = address(arg1).cont.val<address(arg2).cont.val;
                else
                    address(arg1).cont.val = address(arg1).cont.uval<address(arg2).cont.uval;
                instruction(i).type = &int_ty;
            }
            break;
        case OpLET:
            if (is_iconst(arg1) && is_iconst(arg2)) {
                instruction(i).op = OpAsn;
                address(arg1).kind = IConstKind;
                if ((long)instruction(i).type & IC_SIGNED)
                    address(arg1).cont.val = address(arg1).cont.val<=address(arg2).cont.val;
                else
                    address(arg1).cont.val = address(arg1).cont.uval<=address(arg2).cont.uval;
                instruction(i).type = &int_ty;
            }
            break;
        case OpGT:
            if (is_iconst(arg1) && is_iconst(arg2)) {
                instruction(i).op = OpAsn;
                address(arg1).kind = IConstKind;
                if ((long)instruction(i).op & IC_SIGNED)
                    address(arg1).cont.val = address(arg1).cont.val>address(arg2).cont.val;
                else
                    address(arg1).cont.val = address(arg1).cont.uval>address(arg2).cont.uval;
                instruction(i).type = &int_ty;
            }
            break;
        case OpGET:
            if (is_iconst(arg1) && is_iconst(arg2)) {
                instruction(i).op = OpAsn;
                address(arg1).kind = IConstKind;
                if ((long)instruction(i).op & IC_SIGNED)
                    address(arg1).cont.val = address(arg1).cont.val>=address(arg2).cont.val;
                else
                    address(arg1).cont.val = address(arg1).cont.uval>=address(arg2).cont.uval;
                instruction(i).type = &int_ty;
            }
            break;

#undef fold
#undef fold2
#define fold(_i_, _op_)\
instruction(i).op = OpAsn,\
address(arg1).kind = IConstKind,\
address(arg1).cont.val = _op_ address(arg1).cont.val

        case OpNeg:
            if (is_iconst(arg1))
                fold(i, -);
            break;
        case OpCmpl:
            if (is_iconst(arg1))
                fold(i, ~);
            break;
        case OpNot:
            if (is_iconst(arg1))
                fold(i, !);
            break;
        case OpCh:
            if (is_iconst(arg1))
                fold(i, (char));
            break;
        case OpUCh:
            if (is_iconst(arg1))
                fold(i, (unsigned char));
            break;
        case OpSh:
            if (is_iconst(arg1))
                fold(i, (short));
            break;
        case OpUSh:
            if (is_iconst(arg1))
                fold(i, (unsigned short));
            break;
        case OpLLSX:
            if (is_iconst(arg1))
                fold(i, (int));
            break;
        case OpLLZX:
            if (is_iconst(arg1))
                fold(i, (unsigned));
            break;
        // case OpAddrOf:
        // case OpInd:
        // case OpAsn:
        // case OpCall:
        // case OpIndCall:

        // case OpIndAsn:

        // case OpLab:
        // case OpJmp:

        // case OpArg:
        // case OpRet:

        // case OpSwitch:
        // case OpCase:

        case OpCBr:
            if (is_iconst(arg1)) {
                instruction(i).op = OpJmp;
                if (!address(arg1).cont.val)
                    instruction(i).tar = arg2;
            }
            break;
        // case OpNOp:
        } /* switch (instruction(i).op) */
#undef is_iconst
#undef fold
#undef fold2
    }
}

static void ic_function_definition(TypeExp *decl_specs, TypeExp *header);
static void ic_compound_statement(ExecNode *s, int push_scope);
static void ic_if_statement(ExecNode *s);
static void ic_switch_statement(ExecNode *s);
static void ic_while_statement(ExecNode *s);
static void ic_do_statement(ExecNode *s);
static void ic_for_statement(ExecNode *s);
static void ic_goto_statement(ExecNode *s);
static void ic_continue_statement(void);
static void ic_break_statement(void);
static void ic_return_statement(ExecNode *s);
static void ic_case_statement(ExecNode *s);
static void ic_default_statement(ExecNode *s);
static void ic_expression_statement(ExecNode *s);
static void ic_label_statement(ExecNode *s);
static void ic_statement(ExecNode *s);
static void fix_gotos(void);
static void ic_builtin_va_start_statement(ExecNode *s);

void ic_function_definition(TypeExp *decl_specs, TypeExp *header)
{
    Token cat;
    DeclList *p;
    Declaration ty;
    int param_offs, reg_param_offs;
    int nfree_reg;
    unsigned entry_label;

    nfree_reg = 6;
    param_offs = 0;

    ty.decl_specs = decl_specs;
    ty.idl = header->child->child;
    if ((cat=get_type_category(&ty))==TOK_STRUCT || cat==TOK_UNION) {
        /* allocate space for the 'return value address' */
        if (target_arch == ARCH_X64) {
            if (get_sizeof(&ty) > 16) {
                local_offset -= 8;
                --nfree_reg; /* rdi becomes unavailable */
            }
        } else if (target_arch == ARCH_X86) {
            local_offset -= 4;
        } else if (target_arch==ARCH_MIPS || (target_arch==ARCH_ARM && get_sizeof(&ty)>4)) {
            param_offs += 4;
        }
    }

    location_push_scope();
    p = header->child->attr.dl;
    if (get_type_spec(p->decl->decl_specs)->op==TOK_VOID && p->decl->idl==NULL)
        p = NULL; /* function with no parameters */

    if (target_arch == ARCH_X64) {
        DeclList *tmp;
        int is_vararg;

        is_vararg = FALSE;
        for (tmp = p; tmp != NULL; tmp = tmp->next) {
            if (tmp->decl->idl!=NULL && tmp->decl->idl->op==TOK_ELLIPSIS)
                is_vararg = TRUE;
        }

        param_offs += X64_PARAM_END;
        reg_param_offs = is_vararg ? -48 : local_offset-8;
        while (p != NULL) {
            unsigned siz;

            if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
                break; /* start of optional parameters (`...') */

            ty.decl_specs = p->decl->decl_specs;
            ty.idl = p->decl->idl->child;
            if ((siz=get_sizeof(&ty))>16 || siz>nfree_reg*8) { /* passed on the stack */
                location_new(p->decl->idl->str, param_offs);
                DEBUG_PRINTF("==> param:`%s', offset:%d\n", p->decl->idl->str, param_offs);
                param_offs += round_up(siz, 8);
            } else { /* passed on registers (and spilled upon entry) */
                if (is_vararg) {
                    location_new(p->decl->idl->str, reg_param_offs);
                    DEBUG_PRINTF("==> param:`%s', offset:%d\n", p->decl->idl->str, reg_param_offs);
                    reg_param_offs += 8;
                    --nfree_reg;
                    if (siz > 8) {
                        reg_param_offs += 8;
                        --nfree_reg;
                    }
                } else {
                    if (siz > 8) {
                        reg_param_offs -= 8;
                        --nfree_reg;
                    }
                    location_new(p->decl->idl->str, reg_param_offs);
                    DEBUG_PRINTF("==> param:`%s', offset:%d\n", p->decl->idl->str, reg_param_offs);
                    reg_param_offs -= 8;
                    --nfree_reg;
                }
            }

            p = p->next;
        }
        if (is_vararg) {
            va_arg_data.reg_save_area = local_offset-48;
            va_arg_data.gp_offset = 48-nfree_reg*8;
            va_arg_data.overflow_arg_area = param_offs;
            DEBUG_PRINTF("reg_save_area=%d\n", va_arg_data.reg_save_area);
            DEBUG_PRINTF("gp_offset=%d\n", va_arg_data.gp_offset);
            DEBUG_PRINTF("overflow_arg_area=%d\n", va_arg_data.overflow_arg_area);
            local_offset -= 48;
        } else {
            local_offset = reg_param_offs+8;
        }
    } else if (target_arch == ARCH_X86) {
        param_offs += X86_PARAM_END;
        while (p != NULL) {
            if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
                break; /* start of optional parameters (`...') */

            location_new(p->decl->idl->str, param_offs);
            DEBUG_PRINTF("==> param:`%s', offset:%d\n", p->decl->idl->str, param_offs);
            ty.decl_specs = p->decl->decl_specs;
            ty.idl = p->decl->idl->child;
            param_offs += round_up(get_sizeof(&ty), 4);

            p = p->next;
        }
    } else if (target_arch==ARCH_MIPS || target_arch==ARCH_ARM) {
        param_offs += MIPS_ARM_PARAM_END;
        while (p != NULL) {
            if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
                break; /* start of optional parameters (`...') */

            ty.decl_specs = p->decl->decl_specs;
            ty.idl = p->decl->idl->child;

            param_offs = round_up(param_offs, get_alignment(&ty));
            location_new(p->decl->idl->str, param_offs);
            DEBUG_PRINTF("==> param:`%s', offset:%d\n", p->decl->idl->str, param_offs);
            param_offs += round_up(get_sizeof(&ty), 4);

            p = p->next;
        }
    }

    entry_label = new_label();
    exit_label = new_label();

    /* build ENTRY node */
    emit_i(OpJmp, NULL, entry_label, 0, 0);
    emit_label(entry_label);

    cg_node(curr_cg_node).is_leaf = TRUE;
    ic_compound_statement(header->attr.e, FALSE);
    emit_label(exit_label); /* return's target */

    /* build EXIT node */
    exit_label = new_label();
    emit_i(OpJmp, NULL, exit_label, 0, 0);
    emit_label(exit_label);

    location_pop_scope();
    fix_gotos();
    cg_node(curr_cg_node).size_of_local_area = size_of_local_area;
}

static int pocount;
static int *visited, nunvisited;

/*                 */
/* Call-Graph (CG) */
/*                 */

#if DEBUG
static void print_CG_ordering(void)
{
    unsigned i;

    printf("CG PO = [ ");
    for (i = 0; i < cg_nodes_counter; i++)
        printf("%u%s", cg_node(i).PO, (i!=cg_nodes_counter-1)?", ":" ");
    printf("]\n");
    printf("CG RPO = [ ");
    for (i = 0; i < cg_nodes_counter; i++)
        printf("%u%s", cg_node(i).RPO, (i!=cg_nodes_counter-1)?", ":" ");
    printf("]\n");
}
#endif

static void print_CG(void)
{
    unsigned i;

#if DEBUG
    print_CG_ordering();
#endif
    fprintf(cg_dotfile, "digraph {\n");
    for (i = 0; i < cg_nodes_counter; i++) {
        unsigned j;

        fprintf(cg_dotfile, "V%u[label=\"F%u %s\\n", i, i, cg_node(i).func_id);
        fprintf(cg_dotfile, "[%u, %u]\"];\n", cg_node(i).bb_i, cg_node(i).bb_f);
        for (j = edge_iterate(&cg_node(i).out); j != -1; j = edge_iterate(NULL))
            fprintf(cg_dotfile, "V%u -> V%u;\n", i, j);
    }
    fprintf(cg_dotfile, "}\n");
}

static void number_subCG(unsigned n)
{
    int i;

    visited[n] = TRUE;
    --nunvisited;
    if (!cg_node_is_empty(n)) {
        for (i = 0; i < cg_node(n).out.n; i++) {
            unsigned succ;

            succ = cg_node(n).out.edges[i];
            if (!visited[succ])
                number_subCG(succ);
        }
    }
    cg_node(pocount).PO = n;
    ++pocount;
}

static void number_CG(void)
{
    unsigned n, n2;

    visited = calloc(cg_nodes_counter, sizeof(int));
    nunvisited = cg_nodes_counter;
    pocount = 0;

    while (nunvisited != 0) {
        for (n = 0; n < cg_nodes_counter; n++)
            if (!visited[n])
                break;
        number_subCG(n);
    }
    for (n2=cg_nodes_counter-1, n=0; n < cg_nodes_counter; n2--, n++)
        cg_node(n).RPO = cg_node(n2).PO;

    free(visited);
}

/*                          */
/* Control Flow Graph (CFG) */
/*                          */

#if DEBUG
static void print_CFG_ordering(unsigned fn)
{
    unsigned i;
    unsigned entry_bb, last_bb;

    entry_bb = cg_node(fn).bb_i;
    last_bb = cg_node(fn).bb_f;

    printf("CFG PO = [ ");
    for (i = entry_bb; i <= last_bb; i++)
        printf("%u%s", cfg_node(i).PO, (i!=last_bb)?", ":" ");
    printf("]\n");

    printf("CFG RPO = [ ");
    for (i = entry_bb; i <= last_bb; i++)
        printf("%u%s", cfg_node(i).RPO, (i!=last_bb)?", ":" ");
    printf("]\n");
}
#endif

/* emit a DOT definition of the CFG */
static void print_CFG(unsigned fn)
{
    unsigned i;

    if (cg_node_is_empty(fn))
        return;
#if DEBUG
    print_CFG_ordering(fn);
#endif
    fprintf(cfg_dotfile, "digraph {\n");
    for (i = cg_node(fn).bb_i; i <= cg_node(fn).bb_f; i++) {
        unsigned j;

        fprintf(cfg_dotfile, "V%u[label=\"B%u ", i, i);
        for (j = cfg_node(i).leader; j <= cfg_node(i).last; j++)
            fprintf(cfg_dotfile, "(%u)%s", j, (j!=cfg_node(i).last)?", ":"");
        fprintf(cfg_dotfile, "\"];\n");

        for (j = 0; j < cfg_node(i).out.n; j++)
            fprintf(cfg_dotfile, "V%u -> V%u;\n", i, cfg_node(i).out.edges[j]);
    }
    fprintf(cfg_dotfile, "}\n");
}

static void number_subCFG(unsigned n)
{
    int i;

    visited[n-cg_node(curr_cg_node).bb_i] = TRUE;
    --nunvisited;
    for (i = 0; i < cfg_node(n).out.n; i++) {
        unsigned succ;

        succ = cfg_node(n).out.edges[i];
        if (!visited[succ-cg_node(curr_cg_node).bb_i])
            number_subCFG(succ);
    }
    cfg_node(pocount).PO = n;
    ++pocount;
}

static void number_CFG(void)
{
    unsigned n, n2;

    visited = calloc(cg_node_nbb(curr_cg_node), sizeof(int));
    pocount = cg_node(curr_cg_node).bb_i;

    nunvisited = cg_node_nbb(curr_cg_node);
    while (nunvisited != 0) {
        for (n = cg_node(curr_cg_node).bb_i; n <= cg_node(curr_cg_node).bb_f; n++)
            if (!visited[n-cg_node(curr_cg_node).bb_i])
                break;
        number_subCFG(n);
    }
    n = cg_node(curr_cg_node).bb_i;
    n2 = cg_node(curr_cg_node).bb_f;
    while (n <= cg_node(curr_cg_node).bb_f) {
        cfg_node(n).RPO = cfg_node(n2).PO;
        --n2, ++n;
    }

    free(visited);
}

static void build_CFG(void)
{
    int i;
    unsigned leader, func_ninstr, *leader2node;

    func_ninstr = ic_instructions_counter-ic_func_first_instr;
    leader2node = calloc(func_ninstr, sizeof(unsigned));

    cg_node(curr_cg_node).bb_i = cfg_nodes_counter;
    leader2node[0] = cfg_nodes_counter;
    new_cfg_node(ic_func_first_instr);
    leader2node[1] = cfg_nodes_counter;
    new_cfg_node(ic_func_first_instr+1);
    for (i = ic_func_first_instr+2; i < ic_instructions_counter; i++) {
        unsigned *p;

        switch (instruction(i).op) {
        case OpJmp:
            leader = lab2instr[address(instruction(i).tar).cont.val];
            if (!*(p=&leader2node[leader-ic_func_first_instr])) {
                *p = cfg_nodes_counter;
                new_cfg_node(leader);
            }
            leader = i+1;
            if (!*(p=&leader2node[leader-ic_func_first_instr])) {
                *p = cfg_nodes_counter;
                new_cfg_node(leader);
            }
            break;
        case OpCBr:
            leader = lab2instr[address(instruction(i).tar).cont.val];
            if (!*(p=&leader2node[leader-ic_func_first_instr])) {
                *p = cfg_nodes_counter;
                new_cfg_node(leader);
            }
            leader = lab2instr[address(instruction(i).arg2).cont.val];
            if (!*(p=&leader2node[leader-ic_func_first_instr])) {
                *p = cfg_nodes_counter;
                new_cfg_node(leader);
            }
            break;
        case OpSwitch: {
            int j;

            for (j = i+1; instruction(j).op == OpCase; j++) {
                leader = lab2instr[address(instruction(j).arg1).cont.val];
                if (!*(p=&leader2node[leader-ic_func_first_instr])) {
                    *p = cfg_nodes_counter;
                    new_cfg_node(leader);
                }
            }
        }
            break;
        }
    }
    cg_node(curr_cg_node).bb_f = cfg_nodes_counter-1;

    for (i = cg_node(curr_cg_node).bb_i; i < cfg_nodes_counter; i++) {
        unsigned last;

        last = cfg_node(i).leader+1;
        while (last<ic_instructions_counter && !leader2node[last-ic_func_first_instr])
             ++last;
        cfg_node(i).last = --last;

        /* add edges */
        switch (instruction(last).op) {
        case OpCBr: {
            unsigned succ1, succ2;

            leader = lab2instr[address(instruction(last).tar).cont.val];
            succ1 = leader2node[leader-ic_func_first_instr];
            leader = lab2instr[address(instruction(last).arg2).cont.val];
            succ2 = leader2node[leader-ic_func_first_instr];

            /* set out edges of current node */
            edge_add(&cfg_node(i).out, succ1);
            edge_add(&cfg_node(i).out, succ2);

            /* set in edges of successors */
            edge_add(&cfg_node(succ1).in, i);
            edge_add(&cfg_node(succ2).in, i);
        }
            break;

        case OpJmp: {
            unsigned succ;

            leader = lab2instr[address(instruction(last).tar).cont.val];
            succ = leader2node[leader-ic_func_first_instr];
            assert(succ != 0);

            edge_add(&cfg_node(i).out, succ);
            edge_add(&cfg_node(succ).in, i);
        }
            break;

        case OpCase: {
            unsigned succ;

            do {
                leader = lab2instr[address(instruction(last).arg1).cont.val];
                succ = leader2node[leader-ic_func_first_instr];
                assert(succ != 0);

                edge_add(&cfg_node(i).out, succ);
                edge_add(&cfg_node(succ).in, i);
                --last;
            } while (instruction(last).op == OpCase);
        }
            break;

        default: /* fall-through */
            if (last != ic_instructions_counter-1) {
                unsigned succ;

                assert(instruction(last+1).op == OpLab);

                leader = lab2instr[address(instruction(last+1).tar).cont.val];
                succ = leader2node[leader-ic_func_first_instr];
                assert(succ != 0);

                edge_add(&cfg_node(i).out, succ);
                edge_add(&cfg_node(succ).in, i);
            }
            break;
        }
    }
    free(leader2node);
    number_CFG();
}

/*            */
/* Statements */
/*            */

struct SwitchLabel {
    unsigned lab;
    long long val;
    SwitchLabel *next;
} *ic_case_labels[MAX_SWITCH_NEST], *ic_default_labels[MAX_SWITCH_NEST];
static int ic_switch_nesting_level = -1;

static struct Label {
    char *str;
    unsigned addr;
    Label *next;
} *ic_labels;
static void register_label(char *str, unsigned addr);
static unsigned get_label_address(char *str);
static int gotos_to_fix[MAX_GOTOS_PER_FUNC], gotos_to_fix_counter;

static unsigned btarget_stack[128], ctarget_stack[128];
static int bt_stack_top = -1, ct_stack_top = -1;

static unsigned ic_expression(ExecNode *e, int is_addr, unsigned true_lab, unsigned false_lab);
static int number_expression_tree(ExecNode *e);
static unsigned ic_expr_convert(ExecNode *e, Declaration *dest);
static void ic_auto_init(TypeExp *ds, TypeExp *dct, ExecNode *e, unsigned id, unsigned offset);
static void ic_zero(unsigned id, unsigned offset, unsigned nb);

#define NOLAB ((unsigned)-1)

static unsigned ic_expression2(ExecNode *e, unsigned true_lab, unsigned false_lab)
{
    number_expression_tree(e);
    return ic_expression(e, FALSE, true_lab, false_lab);
}

static void ic_controlling_expression(ExecNode *e, unsigned true_lab, unsigned false_lab)
{
    if (e->kind.exp==OpExp && (e->attr.op==TOK_OR || e->attr.op==TOK_AND))
        ic_expression2(e, true_lab, false_lab);
    else
        emit_i(OpCBr, &e->type, true_lab, ic_expression2(e, true_lab, false_lab), false_lab);
}

static void push_break_target(unsigned lab)
{
    btarget_stack[++bt_stack_top] = lab;
}

static void pop_break_target(void)
{
    --bt_stack_top;
}

static void push_continue_target(unsigned lab)
{
    ctarget_stack[++ct_stack_top] = lab;
}

static void pop_continue_target(void)
{
    --ct_stack_top;
}

void ic_statement(ExecNode *s)
{
    switch (s->kind.stmt) {
    case BuiltinVaStartStmt:
        ic_builtin_va_start_statement(s);
        break;
    case CmpndStmt:
        ic_compound_statement(s, TRUE);
        break;
    case IfStmt:
        ic_if_statement(s);
        break;
    case SwitchStmt:
        ic_switch_statement(s);
        break;
    case WhileStmt:
        ic_while_statement(s);
        break;
    case DoStmt:
        ic_do_statement(s);
        break;
    case ForStmt:
        ic_for_statement(s);
        break;
    case GotoStmt:
        ic_goto_statement(s);
        break;
    case ContinueStmt:
        ic_continue_statement();
        break;
    case BreakStmt:
        ic_break_statement();
        break;
    case ReturnStmt:
        ic_return_statement(s);
        break;
    case CaseStmt:
        ic_case_statement(s);
        break;
    case DefaultStmt:
        ic_default_statement(s);
        break;
    case ExpStmt:
        ic_expression_statement(s);
        break;
    case LabelStmt:
        ic_label_statement(s);
        break;
    }
}

/*
 * Model in IC the assembly code required
 * to implement va_start() in x64.
 */
void ic_builtin_va_start_statement(ExecNode *s)
{
    /*
     va_start(ap, l):

        t1 = &base

        t2 = &ap
        *t2 = gp_offset

        t3 = t2+8
        t4 = t1-overflow_arg_area
        *t3 = t4

        t5 = t2+16
        t6 = t1-reg_save_area
        *t5 = t6
    */
    unsigned t1, t2, t3, t4, t5, t6;
    unsigned gp_offset_addr, overflow_arg_area_addr, reg_save_area_addr;
    static unsigned mem_offs1 = 0, mem_offs2 = 0;
    static int base_counter;
    static unsigned base_addr;

    t1 = new_temp_addr();
    t2 = new_temp_addr();
    t3 = new_temp_addr();
    t4 = new_temp_addr();
    t5 = new_temp_addr();
    t6 = new_temp_addr();

    gp_offset_addr = new_address(IConstKind);
    address(gp_offset_addr).cont.uval = va_arg_data.gp_offset;
    overflow_arg_area_addr = new_address(IConstKind);
    address(overflow_arg_area_addr).cont.uval = va_arg_data.overflow_arg_area;
    reg_save_area_addr = new_address(IConstKind);
    address(reg_save_area_addr).cont.uval = -va_arg_data.reg_save_area;

    if (mem_offs1 == 0) {
        mem_offs1 = new_address(IConstKind);
        address(mem_offs1).cont.uval = 8;

        mem_offs2 = new_address(IConstKind);
        address(mem_offs2).cont.uval = 16;
    }

    if (base_node == NULL) {
        char *base_name;

        base_name = malloc(16);
        sprintf(base_name, "base@%d", base_counter++);

        base_node = new_exec_node();
        base_node->node_kind = ExpNode;
        base_node->kind.exp = IdExp;
        base_node->attr.var.id = base_name;
        base_node->attr.var.scope = 0;
        base_node->attr.var.linkage = LINKAGE_NONE;
        base_node->attr.var.duration = DURATION_AUTO;

        base_addr = new_address(IdKind);
        address(base_addr).cont.var.e = base_node;
        address(base_addr).cont.nid = get_var_nid(base_name, 0);
        address(base_addr).cont.var.offset = 0; /* &base == rbp */
    }
    emit_i(OpAddrOf, NULL, t1, base_addr, 0);

    t2 = ic_expression(s->child[0], FALSE, NOLAB, NOLAB); /* [!] assume va_list is defined as an array */
    emit_i(OpIndAsn, &int_ty, 0, t2, gp_offset_addr);

    emit_i(OpAdd, &long_ty, t3, t2, mem_offs1);
    emit_i(OpAdd, &long_ty, t4, t1, overflow_arg_area_addr);
    emit_i(OpIndAsn, &long_ty, 0, t3, t4);

    emit_i(OpAdd, &long_ty, t5, t2, mem_offs2);
    emit_i(OpSub, &long_ty, t6, t1, reg_save_area_addr);
    emit_i(OpIndAsn, &long_ty, 0, t5, t6);
}

void ic_if_statement(ExecNode *s)
{
    /*
    ==> if (<e>) <stmt1> else <stmt2>
    CBr L1, <e>, L2
    L1:
    <stmt1>
    Jmp L3
    L2:
    <stmt2>
    L3:
    ...
     */
    int else_part;
    unsigned L1, L2, L3;

    /* does the else part is present? */
    else_part = s->child[2]!=NULL;

    L1 = new_label();
    L2 = new_label();
    if (else_part)
        L3 = new_label();

    if (verbose_asm)
        emit_src(ast2c(s));
    ic_controlling_expression(s->child[0], L1, L2);
    emit_label(L1);
    ic_statement(s->child[1]);
    if (else_part) {
        emit_i(OpJmp, NULL, L3, 0, 0);
        if (verbose_asm)
            emit_src("else");
    }
    emit_label(L2);
    if (else_part) {
        ic_statement(s->child[2]);
        emit_label(L3);
    }
}

void ic_while_statement(ExecNode *s)
{
    /*
    ==> while (<e>) <stmt>
    CBr L1, <e>, L3
    L1:
    <stmt>
    L2:
    CBr L1, <e>, L3
    L3:
    ...
     */
    char *ce;
    unsigned L1, L2, L3;

    L1 = new_label();
    L2 = new_label();
    L3 = new_label();

    if (verbose_asm)
        emit_src(ce = ast2c(s));
    ic_controlling_expression(s->child[0], L1, L3);
    emit_label(L1);
    push_break_target(L3), push_continue_target(L2);
    ic_statement(s->child[1]);
    pop_break_target(), pop_continue_target();
    if (verbose_asm)
        emit_src(ce);
    emit_label(L2);
    ic_controlling_expression(s->child[0], L1, L3);
    emit_label(L3);
}

void ic_do_statement(ExecNode *s)
{
    /*
    ==> do <stmt> while (<e>)
    L1:
    <stmt>
    L2:
    CBr L1, <e>, L3
    L3:
    ...
     */
    int iprev;
    unsigned L1, L2, L3;

    L2 = new_label();
    L3 = new_label();

    iprev = ic_instructions_counter-1;
    if (instruction(iprev).op != OpLab) {
        L1 = new_label();
        emit_label(L1);
    } else {
        L1 = instruction(iprev).tar;
    }
    push_break_target(L3), push_continue_target(L2);
    ic_statement(s->child[1]);
    pop_break_target(), pop_continue_target();
    if (verbose_asm)
        emit_src(ast2c(s));
    emit_label(L2);
    ic_controlling_expression(s->child[0], L1, L3);
    emit_label(L3);
}

void ic_for_statement(ExecNode *s)
{
    /*
    ==> for (<e1>; <e2>; <e3>) <stmt>
    <e1>
    CBr L1, <e2>, L3
    L1:
    <stmt>
    L2:
    <e3>
    CBr L1, <e2>, L3
    L3:
    ...
     */
    char *ce;
    unsigned L1, L2, L3;

    L1 = new_label();
    L2 = new_label();
    L3 = new_label();

    if (s->child[1] != NULL) {
        if (verbose_asm)
            emit_src(ast2c(s->child[1]));
        ic_expression2(s->child[1], NOLAB, NOLAB);
    }
    if (s->child[0] != NULL) {
        if (verbose_asm)
            emit_src(ce = ast2c(s->child[0]));
        ic_controlling_expression(s->child[0], L1, L3);
    }
    emit_label(L1);
    push_break_target(L3), push_continue_target(L2);
    ic_statement(s->child[3]);
    pop_break_target(), pop_continue_target();
    emit_label(L2);
    if (s->child[2] != NULL) {
        if (verbose_asm)
            emit_src(ast2c(s->child[2]));
        ic_expression2(s->child[2], NOLAB, NOLAB);
    }
    if (s->child[0] != NULL) {
        if (verbose_asm)
            emit_src(ce);
        ic_controlling_expression(s->child[0], L1, L3);
    } else {
        emit_i(OpJmp, NULL, L1, 0, 0);
    }
    emit_label(L3);
}

void ic_label_statement(ExecNode *s)
{
    int iprev;

    if (verbose_asm)
        emit_src(ast2c(s));
    iprev = ic_instructions_counter-1;
    if (instruction(iprev).op != OpLab) {
        unsigned L;

        L = new_label();
        emit_label(L);
        register_label(s->attr.str, L);
    } else {
        register_label(s->attr.str, instruction(iprev).tar);
    }
    ic_statement(s->child[0]);
}

void ic_goto_statement(ExecNode *s)
{
    if (verbose_asm)
        emit_src(ast2c(s));
    gotos_to_fix[gotos_to_fix_counter++] = ic_instructions_counter;
    emit_i(OpJmp, (Declaration *)s->attr.str, 0, 0, 0);
}

void ic_continue_statement(void)
{
    if (verbose_asm)
        emit_src("continue;");
    emit_i(OpJmp, NULL, ctarget_stack[ct_stack_top], 0, 0);
}

void ic_break_statement(void)
{
    if (verbose_asm)
        emit_src("break;");
    emit_i(OpJmp, NULL, btarget_stack[bt_stack_top], 0, 0);
}

void ic_return_statement(ExecNode *s)
{
    if (verbose_asm)
        emit_src(ast2c(s));
    if (s->child[0] != NULL) {
        Declaration *ty;

        ty = new_declaration_node();
        ty->decl_specs = (TypeExp *)s->child[1];
        ty->idl = (TypeExp *)s->child[2];
        emit_i(OpRet, ty, 0, ic_expr_convert(s->child[0], ty), 0);
    }
    emit_i(OpJmp, NULL, exit_label, 0, 0);
}

void ic_switch_statement(ExecNode *s)
{
    /*
    ==> switch (<e>) <stmt>
    switch <e>
    ...
    EXIT:
     */
    unsigned EXIT, i, a, n;
    SwitchLabel *np, *temp;

    ++ic_switch_nesting_level;

    if (verbose_asm)
        emit_src(ast2c(s));
    EXIT = new_label();
    push_break_target(EXIT);
    a = new_address(IConstKind);
    address(a).cont.val = s->attr.val;
    emit_i(OpSwitch, &s->child[0]->type, 0, ic_expression2(s->child[0], NOLAB, NOLAB), a);
    i = ic_instructions_counter;
    n = ic_instructions_counter+s->attr.val;
    while (ic_instructions_counter < n)
        emit_i(OpCase, NULL, 0, 0, 0);
    ic_statement(s->child[1]);
    pop_break_target();
    emit_label(EXIT);

    for (np = ic_case_labels[ic_switch_nesting_level]; np != NULL; ) {
        a = new_address(IConstKind);
        address(a).cont.val = np->val;

        /*ic_instructions[i].op = OpCase;*/
        ic_instructions[i].tar = a;
        ic_instructions[i].arg1 = np->lab;
        ic_instructions[i].arg2 = false_addr;
        ++i;

        temp = np;
        np = np->next;
        free(temp);
    }
    ic_case_labels[ic_switch_nesting_level] = NULL;

    np = ic_default_labels[ic_switch_nesting_level];
    ic_default_labels[ic_switch_nesting_level] = NULL;
    /*ic_instructions[i].op = OpCase;*/
    ic_instructions[i].tar = false_addr;
    if (np != NULL) {
        ic_instructions[i].arg1 = np->lab;
        free(np);
    } else {
        ic_instructions[i].arg1 = EXIT;
    }
    ic_instructions[i].arg2 = true_addr;

    --ic_switch_nesting_level;
}

void ic_case_statement(ExecNode *s)
{
    unsigned iprev;
    OpKind prev_op;
    SwitchLabel *np;

    if (verbose_asm)
        emit_src(ast2c(s));

    iprev = ic_instructions_counter-1;
    prev_op = instruction(iprev).op;

    np = malloc(sizeof(SwitchLabel));
    np->val = s->child[0]->attr.val;
    if (prev_op == OpLab) {
        np->lab = instruction(iprev).tar;
    } else {
        np->lab = new_label();
        emit_label(np->lab);
    }
    ic_statement(s->child[1]);
    np->next = ic_case_labels[ic_switch_nesting_level];
    ic_case_labels[ic_switch_nesting_level] = np;
}

void ic_default_statement(ExecNode *s)
{
    unsigned iprev;
    OpKind prev_op;
    SwitchLabel *np;

    if (verbose_asm)
        emit_src("default:");

    iprev = ic_instructions_counter-1;
    prev_op = instruction(iprev).op;

    np = malloc(sizeof(SwitchLabel));
    if (prev_op == OpLab) {
        np->lab = instruction(iprev).tar;
    } else {
        np->lab = new_label();
        emit_label(np->lab);
    }
    ic_statement(s->child[0]);
    np->next = ic_default_labels[ic_switch_nesting_level];
    ic_default_labels[ic_switch_nesting_level] = np;
}

void ic_compound_statement(ExecNode *s, int push_scope)
{
    ExecNode *sl;
    int old_local_offset;

    if (s->locals != NULL) {
        DeclList *dl;

        old_local_offset = local_offset;
        if (push_scope)
            location_push_scope();

        /* traverse declaration list */
        for (dl = s->locals; dl != NULL; dl = dl->next) {
            TypeExp *dct, *scs;

            /* check for extern/static local variables */
            if ((scs=get_sto_class_spec(dl->decl->decl_specs)) != NULL) {
                if (scs->op == TOK_STATIC) {
                    for (dct = dl->decl->idl; dct != NULL; dct = dct->sibling) {
                        ExternId *np;

                        np = new_extern_id_node();
                        np->decl_specs = dl->decl->decl_specs;
                        np->declarator = dct;
                        np->enclosing_function = cg_node(curr_cg_node).func_id;
                        np->next = static_objects_list;
                        static_objects_list = np;
                    }
                    continue;
                } else if (scs->op==TOK_EXTERN || scs->op==TOK_TYPEDEF) {
                    continue;
                }
            }

            /* traverse init declarator list */
            for (dct = dl->decl->idl; dct != NULL; dct = dct->sibling) {
                Declaration lty;

                lty.decl_specs = dl->decl->decl_specs;
                lty.idl = dct->child;
                if (get_type_category(&lty) == TOK_FUNCTION)
                    continue;
                local_offset = round_up(local_offset, get_alignment(&lty));
                local_offset -= get_sizeof(&lty);
                location_new(dct->str, local_offset);
                DEBUG_PRINTF("==> var: %s, offset: %d\n", dct->str, local_offset);
                if (dct->attr.e != NULL) {
                    unsigned a;
                    ExecNode *id_node;

                    /* make up an identifier node so this can be treated as a normal assignment */
                    id_node = new_exec_node();
                    id_node->node_kind = ExpNode;
                    id_node->kind.exp = IdExp;
                    id_node->attr.var.id = dct->str;
                    id_node->attr.var.scope = s->attr.var.scope;
                    id_node->attr.var.linkage = LINKAGE_NONE;
                    id_node->attr.var.duration = DURATION_AUTO;
                    id_node->attr.var.is_param = FALSE;
                    id_node->type = lty;

                    a = new_address(IdKind);
                    address(a).cont.var.e = id_node;
                    address(a).cont.nid = get_var_nid(dct->str, s->attr.var.scope);
                    address(a).cont.var.offset = local_offset;

                    ic_auto_init(lty.decl_specs, lty.idl, dct->attr.e, a, 0);
                }
            }
        }
    }

    /*if (verbose_asm)
        emit_src("{");*/
    for (sl = s->child[0]; sl != NULL; sl = sl->sibling)
        ic_statement(sl);
    /*if (verbose_asm)
        emit_src("}");*/

    if (local_offset < size_of_local_area)
        size_of_local_area = local_offset;

    if (push_scope && s->locals!=NULL) {
        local_offset = old_local_offset;
        location_pop_scope();
    }
}

void ic_expression_statement(ExecNode *s)
{
    if (s->child[0] != NULL) {
        if (verbose_asm)
            emit_src(ast2c(s));
        ic_expression2(s->child[0], NOLAB, NOLAB);
    }
}

void register_label(char *str, unsigned addr)
{
    Label *np;

    np = malloc(sizeof(Label));
    np->str = str;
    np->addr = addr;
    np->next = ic_labels;
    ic_labels = np;
}

unsigned get_label_address(char *str)
{
    Label *np;

    for (np = ic_labels; np != NULL; np = np->next)
        if (equal(np->str, str))
            return np->addr;
    assert(0);
}

void fix_gotos(void)
{
    Label *np, *temp;

    while (--gotos_to_fix_counter >= 0) {
        int i;

        i = gotos_to_fix[gotos_to_fix_counter];
        instruction(i).tar = get_label_address((char *)instruction(i).type);
    }
    gotos_to_fix_counter = 0;

    for (np = ic_labels; np != NULL; ) {
        temp = np;
        np = np->next;
        free(temp);
    }
    ic_labels = NULL;
}

void ic_zero(unsigned id, unsigned offset, unsigned nb)
{
    /*
     * Do memset(arg #1, arg #2, arg #3);
     * where:
     *  - arg #1: &id+offset
     *  - arg #2: 0
     *  - arg #3: nb
     * Also assume sizeof(int) == sizeof(void *)
     */
    unsigned a1;

    if (target_arch==ARCH_MIPS || target_arch==ARCH_ARM) {
        /* arg #1 */
        a1 = new_temp_addr();
        emit_i(OpAddrOf, NULL, a1, id, 0);
        if (offset > 0) {
            unsigned a2, a3;

            a2 = new_address(IConstKind);
            address(a2).cont.uval = offset;
            a3 = new_temp_addr();
            emit_i(OpAdd, &long_ty, a3, a1, a2);
            a1 = a3;
        }
        emit_i(OpArg, &int_ty, 0, a1, 0);
        /* arg #2 */
        a1 = new_address(IConstKind);
        address(a1).cont.uval = 0;
        emit_i(OpArg, &int_ty, 0, a1, 0);
        /* arg #3 */
        a1 = new_address(IConstKind);
        address(a1).cont.uval = nb;
        emit_i(OpArg, &unsigned_ty, 0, a1, 0);
    } else {
        /* arg #3 */
        a1 = new_address(IConstKind);
        address(a1).cont.uval = nb;
        emit_i(OpArg, &unsigned_ty, 0, a1, 0);
        /* arg #2 */
        a1 = new_address(IConstKind);
        address(a1).cont.uval = 0;
        emit_i(OpArg, &int_ty, 0, a1, 0);
        /* arg #1 */
        a1 = new_temp_addr();
        emit_i(OpAddrOf, NULL, a1, id, 0);
        if (offset > 0) {
            unsigned a2, a3;

            a2 = new_address(IConstKind);
            address(a2).cont.uval = offset;
            a3 = new_temp_addr();
            emit_i(OpAdd, &long_ty, a3, a1, a2);
            a1 = a3;
        }
        emit_i(OpArg, &int_ty, 0, a1, 0);
    }
    /* do the call */
    a1 = new_address(IConstKind);
    address(a1).cont.val = 3;
    emit_i(OpCall, &int_ty, new_temp_addr(), memset_addr, a1);
    cg_node(curr_cg_node).is_leaf = FALSE;
}

void ic_auto_init(TypeExp *ds, TypeExp *dct, ExecNode *e, unsigned id, unsigned offset)
{
    TypeExp *ts;

    if (dct != NULL) {
        unsigned nelem;

        if (dct->op != TOK_SUBSCRIPT)
            goto scalar; /* pointer */

        /*
         * Array.
         */
        nelem = dct->attr.e->attr.uval;
        if (e->kind.exp == StrLitExp) {
            /* char array initialized by string literal */
            unsigned a1, n, nfill;

            a1 = new_address(IConstKind);
            n = strlen(e->attr.str)+1;
            nfill = 0;
            if (nelem == n) { /* fits nicely */
                address(a1).cont.uval = n;
            } else if (nelem < n) { /* no enough room; just copy the first nelem chars of the string */
                address(a1).cont.uval = nelem;
            } else { /* copy all the string and zero the trailing elements */
                address(a1).cont.uval = n;
                nfill = nelem-n;
            }
            if (target_arch==ARCH_MIPS || target_arch==ARCH_ARM) {
                unsigned a2;

                a2 = new_temp_addr();
                emit_i(OpAddrOf, NULL, a2, id, 0);
                if (offset > 0) {
                    unsigned a3, a4;

                    a3 = new_address(IConstKind);
                    address(a3).cont.uval = offset;
                    a4 = new_temp_addr();
                    emit_i(OpAdd, &long_ty, a4, a2, a3);
                    a2 = a4;
                }
                emit_i(OpArg, &int_ty, 0, a2, 0);
                a2 = new_address(StrLitKind);
                address(a2).cont.str = e->attr.str;
                emit_i(OpArg, &int_ty, 0, a2, 0);
                emit_i(OpArg, &int_ty, 0, a1, 0);
            } else {
                emit_i(OpArg, &int_ty, 0, a1, 0);
                a1 = new_address(StrLitKind);
                address(a1).cont.str = e->attr.str;
                emit_i(OpArg, &int_ty, 0, a1, 0);
                a1 = new_temp_addr();
                emit_i(OpAddrOf, NULL, a1, id, 0);
                if (offset > 0) {
                    unsigned a2, a3;

                    a2 = new_address(IConstKind);
                    address(a2).cont.uval = offset;
                    a3 = new_temp_addr();
                    emit_i(OpAdd, &long_ty, a3, a1, a2);
                    a1 = a3;
                }
                emit_i(OpArg, &int_ty, 0, a1, 0);
            }
            a1 = new_address(IConstKind);
            address(a1).cont.val = 3;
            emit_i(OpCall, &int_ty, new_temp_addr(), memcpy_addr, a1);
            if (nfill > 0)
                ic_zero(id, offset+n, nfill);
            cg_node(curr_cg_node).is_leaf = FALSE;
        } else {
            unsigned elem_size;
            Declaration ty;

            /* get element size */
            ty.decl_specs = ds;
            ty.idl = dct->child;
            elem_size = get_sizeof(&ty);

            /* handle elements with explicit initializer */
            for (e = e->child[0]; e!=NULL && nelem!=0; e=e->sibling, --nelem) {
                ic_auto_init(ds, dct->child, e, id, offset);
                offset += elem_size;
            }

            /* handle elements without explicit initializer */
            if (nelem != 0)
                ic_zero(id, offset, nelem*elem_size);
        }
    } else if ((ts=get_type_spec(ds))->op == TOK_STRUCT) {
        /*
         * Struct.
         */
        DeclList *d;
        int full_init;


        if (e->attr.op != TOK_INIT_LIST)
            goto scalar;
        e = e->child[0];

        /* handle members with explicit initializer */
        d = ts->attr.dl;
        full_init = FALSE;
        for (; d != NULL; d = d->next) {
            dct = d->decl->idl;
            for (; e!=NULL && dct!=NULL; e=e->sibling, dct=dct->sibling) {
                unsigned mem_offs;

                mem_offs = get_member_descriptor(ts, dct->str)->offset;
                ic_auto_init(d->decl->decl_specs, dct->child, e, id, offset+mem_offs);
            }

            if (e == NULL) {
                if (dct==NULL && d->next==NULL)
                    full_init = TRUE;
                break;
            }
        }

        /* handle members without explicit initializer */
        if (!full_init) {
            unsigned p1, p2;

            if (dct == NULL) {
                d = d->next;
                dct = d->decl->idl;
            }
            p1 = -1;
            while (TRUE) {
                while (dct != NULL) {
                    StructMember *md;

                    md = get_member_descriptor(ts, dct->str);
                    if (p1 == -1) {
                        p1 = offset+md->offset;
                        p2 = p1+md->size;
                    } else {
                        p2 = offset+md->offset+md->size;
                    }
                    dct = dct->sibling;
                }
                d = d->next;
                if (d != NULL)
                    dct = d->decl->idl;
                else
                    break;
            }
            ic_zero(id, p1, p2-p1);
        }
    } else if (ts->op == TOK_UNION) {
        /*
         * Union.
         */

        if (e->attr.op != TOK_INIT_LIST)
            goto scalar;
        e = e->child[0];

        /* initialize the first named member */
        ic_auto_init(ts->attr.dl->decl->decl_specs, ts->attr.dl->decl->idl->child, e, id, offset);
    } else {
        /*
         * Scalar.
         */
        unsigned a1;
        Declaration *ty;
scalar:
        if (e->kind.exp==OpExp && e->attr.op==TOK_INIT_LIST)
            e = e->child[0];
        a1 = new_temp_addr();
        emit_i(OpAddrOf, NULL, a1, id, 0);
        if (offset > 0) {
            unsigned a2, a3;

            a2 = new_address(IConstKind);
            address(a2).cont.uval = offset;
            a3 = new_temp_addr();
            emit_i(OpAdd, &long_ty, a3, a1, a2);
            a1 = a3;
        }
        ty = new_declaration_node();
        ty->decl_specs = ds;
        ty->idl = dct;
        emit_i(OpIndAsn, ty, 0, a1, ic_expr_convert(e, ty));
    }
}

/*             */
/* Expressions */
/*             */

#define NREG(x) ((x)->nreg)

/*
 * Annotate an expression syntax tree with the number
 * of registers needed to evaluate the expression it
 * represents.
 */
int number_expression_tree(ExecNode *e)
{
    assert(e != NULL);

    switch (e->kind.exp) {
    case OpExp:
        switch (e->attr.op) {
        case TOK_OR:
        case TOK_AND:
        case TOK_BW_OR:
        case TOK_BW_XOR:
        case TOK_BW_AND:
        case TOK_EQ:
        case TOK_NEQ:
        case TOK_LT:
        case TOK_GT:
        case TOK_LET:
        case TOK_GET:
        case TOK_LSHIFT:
        case TOK_RSHIFT:
        case TOK_PLUS:
        case TOK_MINUS:
        case TOK_MUL:
        case TOK_DIV:
        case TOK_REM:
        case TOK_SUBSCRIPT: {
            int nl, nr;

            nl = number_expression_tree(e->child[0]);
            nr = number_expression_tree(e->child[1]);
            if (nl == nr)
                e->nreg = nl+1;
            else
                e->nreg = nl>nr?nl:nr;
        }
            break;
        default:
            /*
             * TODO: Assign a value according to the specific operator.
             * For now just approx. a value.
             */
            e->nreg = number_expression_tree(e->child[0])+1;
            break;
        }
        break;
    case IConstExp:
    case StrLitExp:
    case IdExp:
        e->nreg = 1;
        break;
    }
    return e->nreg;
}

static unsigned ic_dereference(unsigned ptr, Declaration *ty)
{
    unsigned dst;

    switch (get_type_category(ty)) {
    case TOK_SUBSCRIPT:
    case TOK_FUNCTION:
        return ptr;
    }
    if (const_addr(ptr)) {
        unsigned tmp;

        /* to avoid a lot of annoying "is this a constant?" checks later */
        tmp = new_temp_addr();
        emit_i(OpAsn, &long_ty, tmp, ptr, 0);
        ptr = tmp;
    }
    /* dst = *(ty *)ptr */
    dst = new_temp_addr();
    emit_i(OpInd, ty, dst, ptr, 0);
    return dst;
}

static void ic_indirect_assignment(unsigned ptr, unsigned expr, Declaration *ty)
{
    if (const_addr(ptr)) {
        unsigned tmp;

        /* to avoid future checks (analogous to ic_dereference()) */
        tmp = new_temp_addr();
        emit_i(OpAsn, &long_ty, tmp, ptr, 0);
        ptr = tmp;
    }
    /* *(ty *)ptr = expr */
    emit_i(OpIndAsn, ty, 0, ptr, expr);
}

static unsigned get_step_size(ExecNode *e)
{
    unsigned a;

    a = new_address(IConstKind);
    if (is_integer(get_type_category(&e->type))) {
        address(a).cont.uval = 1;
    } else {
        Declaration ty;

        ty = e->type;
        ty.idl = ty.idl->child;
        address(a).cont.uval = get_sizeof(&ty);
    }
    return a;
}

typedef struct {
    unsigned addr;
    Declaration *ty;
    TokenNode *old_info;
} ComputedArg;

static int function_argument2(ExecNode *arg, DeclList *param)
{
    int n;

    if (arg == NULL)
        return 0;

    n = 1;
    if (param->decl->idl==NULL || param->decl->idl->op!=TOK_ELLIPSIS) {
        /* this argument matches a declared (non-optional) parameter */

        Declaration *ty;

        if (arg->kind.exp == -1) {
            ty = ((ComputedArg *)arg->info)->ty;
        } else {
            ty = param->decl;
            if (ty->idl!=NULL && ty->idl->op==TOK_ID) { /* skip identifier */
                ty = new_declaration_node();
                ty->decl_specs = param->decl->decl_specs;
                ty->idl = param->decl->idl->child;
            }
        }

        if (arg->kind.exp == -1) {
            TokenNode *old_info;

            emit_i(OpArg, ty, 0, ((ComputedArg *)arg->info)->addr, 0);
            arg->kind.exp = OpExp;
            old_info = ((ComputedArg *)arg->info)->old_info;
            free(arg->info);
            arg->info = old_info;
        } else {
            emit_i(OpArg, ty, 0, ic_expr_convert(arg, ty), 0);
        }

        n += function_argument2(arg->sibling, param->next);
    } else {
        /* this and the arguments that follow match the `...' */

        if (arg->kind.exp == -1) {
            TokenNode *old_info;

            emit_i(OpArg, &arg->type, 0, ((ComputedArg *)arg->info)->addr, 0);
            arg->kind.exp = OpExp;
            old_info = ((ComputedArg *)arg->info)->old_info;
            free(arg->info);
            arg->info = old_info;
        } else {
            emit_i(OpArg, &arg->type, 0, ic_expression(arg, FALSE, NOLAB, NOLAB), 0);
        }

        n += function_argument2(arg->sibling, param);
    }
    return n;
}

static int contains_function_call(ExecNode *e)
{
    switch (e->kind.exp) {
    case OpExp:
        switch (e->attr.op) {
        case TOK_CONDITIONAL:
            return contains_function_call(e->child[0])
            || contains_function_call(e->child[1])
            || contains_function_call(e->child[2]);

        case TOK_CAST: case TOK_PRE_INC:
        case TOK_PRE_DEC: case TOK_POS_INC:
        case TOK_POS_DEC: case TOK_ADDRESS_OF:
        case TOK_INDIRECTION: case TOK_NEGATION:
        case TOK_COMPLEMENT: case TOK_UNARY_MINUS:
        case TOK_UNARY_PLUS: case TOK_SUBSCRIPT:
        case TOK_DOT: case TOK_ARROW:
            return contains_function_call(e->child[0]);

        case TOK_FUNCTION:
            return TRUE;

        default:
            return contains_function_call(e->child[0]) || contains_function_call(e->child[1]);
        } /* switch (e->attr.op) */
        break;
    case IConstExp:
    case StrLitExp:
    case IdExp:
        return FALSE;
    } /* switch (e->kind.exp) */
    assert(0);
}

/*
 * Along with function_argument2(), emit arguments for architectures
 * that align long long to 8 bytes. The arguments are computed from
 * left to right.
 */
static int aligned_function_argument(ExecNode *arg, DeclList *param)
{
    DeclList *tp;
    ExecNode *ta;
    Declaration *ty;
    unsigned arg_addr;
    ComputedArg *ca;

    /*
     * Emit function call expressions first. This is done so the
     * stack can always be considered aligned at the start of
     * arguments computation. Otherwise things would get messy
     * with nested function calls.
     */
    ta = arg;
    tp = param;
    while (ta != NULL) {
        if (tp->decl->idl==NULL || tp->decl->idl->op!=TOK_ELLIPSIS) {
            /* this argument matches a declared (non-optional) parameter */

            if (!contains_function_call(ta)) {
                tp = tp->next;
                goto next;
            }

            ty = tp->decl;
            if (ty->idl!=NULL && ty->idl->op==TOK_ID) { /* skip identifier */
                ty = new_declaration_node();
                ty->decl_specs = tp->decl->decl_specs;
                ty->idl = tp->decl->idl->child;
            }

            arg_addr = ic_expr_convert(ta, ty);
            tp = tp->next;
        } else {
            /* this and the arguments that follow match the `...' */

            if (!contains_function_call(ta))
                goto next;

            arg_addr = ic_expression(ta, FALSE, NOLAB, NOLAB);
            ty = NULL; /* not used */
        }
        ca = malloc(sizeof(ComputedArg));
        ca->ty = ty;
        ca->addr = arg_addr;
        ca->old_info = ta->info;
        ta->info = (TokenNode *)ca;
        ta->kind.exp = -1; /* mark it as already computed */
next:   ta = ta->sibling;
    }

    return function_argument2(arg, param);
}

/*
 * Push arguments from right to left recursively.
 * Return the number of arguments pushed.
 */
static int function_argument(ExecNode *arg, DeclList *param)
{
    int n;

    if (arg == NULL)
        return 0;

    n = 1;
    if (param->decl->idl==NULL || param->decl->idl->op!=TOK_ELLIPSIS) {
        /* this argument matches a declared (non-optional) parameter */

        Declaration *ty;

        n += function_argument(arg->sibling, param->next);
        ty = param->decl;
        if (ty->idl!=NULL && ty->idl->op==TOK_ID) { /* skip identifier */
            ty = new_declaration_node();
            ty->decl_specs = param->decl->decl_specs;
            ty->idl = param->decl->idl->child;
        }
        emit_i(OpArg, ty, 0, ic_expr_convert(arg, ty), 0);
    } else {
        /* this and the arguments that follow match the `...' */

        n += function_argument(arg->sibling, param);
        emit_i(OpArg, &arg->type, 0, ic_expression(arg, FALSE, NOLAB, NOLAB), 0);
    }
    return n;
}

static int is_wideval(Token cat)
{
    if (targeting_arch64) {
        switch (cat) {
        case TOK_STAR: case TOK_SUBSCRIPT: case TOK_FUNCTION:
        case TOK_LONG: case TOK_UNSIGNED_LONG:
        case TOK_LONG_LONG: case TOK_UNSIGNED_LONG_LONG:
        /*case TOK_STRUCT: case TOK_UNION:*/
            return TRUE;
        default:
            return FALSE;
        }
    } else {
        return (cat==TOK_LONG_LONG || cat==TOK_UNSIGNED_LONG_LONG);
    }
}

/* do ic_expr_convert() according to an ILP32 data model */
static unsigned do_expr_convert32(ExecNode *e, Declaration *dest)
{
    OpKind op;
    unsigned a1, a2;
    Token cat_dest, cat_src;

    a1 = ic_expression(e, FALSE, NOLAB, NOLAB);

    cat_src  = get_type_category(&e->type);
    cat_dest = get_type_category(dest);

    switch (cat_dest) {
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
        if (cat_src!=TOK_CHAR && cat_src!=TOK_SIGNED_CHAR) {
            op = OpCh;
            break;
        }
        return a1; /* no conversion */
    case TOK_UNSIGNED_CHAR:
        if (cat_src != TOK_UNSIGNED_CHAR) {
            op = OpUCh;
            break;
        }
        return a1; /* no conversion */
    case TOK_SHORT:
        switch (cat_src) {
        case TOK_CHAR: case TOK_SIGNED_CHAR:
        case TOK_UNSIGNED_CHAR:
        case TOK_SHORT:
            return a1; /* no conversion */
        default:
            op = OpSh;
            break;
        }
        break;
    case TOK_UNSIGNED_SHORT:
        if (cat_src!=TOK_UNSIGNED_CHAR && cat_src!=TOK_UNSIGNED_SHORT) {
            op = OpUSh;
            break;
        }
        return a1; /* no conversion */
    case TOK_LONG_LONG:
    case TOK_UNSIGNED_LONG_LONG:
        if (cat_src!=TOK_LONG_LONG && cat_src!=TOK_UNSIGNED_LONG_LONG) {
            if (is_unsigned_int(cat_src))
                op = OpLLZX;
            else
                op = OpLLSX;
            break;
        }
        return a1; /* no conversion */
    default:
        return a1; /* no conversion */
    }
    /* fall through */
    /* convert */
    a2 = new_temp_addr();
    emit_i(op, dest, a2, a1, 0);
    return a2;
}

/* do ic_expr_convert() according to a LP64 data model */
static unsigned do_expr_convert64(ExecNode *e, Declaration *dest)
{
    OpKind op;
    unsigned a1, a2;
    Token cat_dest, cat_src;

    a1 = ic_expression(e, FALSE, NOLAB, NOLAB);

    cat_src  = get_type_category(&e->type);
    cat_dest = get_type_category(dest);

    switch (cat_dest) {
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
        if (cat_src!=TOK_CHAR && cat_src!=TOK_SIGNED_CHAR) {
            op = OpCh;
            break;
        }
        return a1; /* no conversion */
    case TOK_UNSIGNED_CHAR:
        if (cat_src != TOK_UNSIGNED_CHAR) {
            op = OpUCh;
            break;
        }
        return a1; /* no conversion */
    case TOK_SHORT:
        switch (cat_src) {
        case TOK_CHAR: case TOK_SIGNED_CHAR:
        case TOK_UNSIGNED_CHAR:
        case TOK_SHORT:
            return a1; /* no conversion */
        default:
            op = OpSh;
            break;
        }
        break;
    case TOK_UNSIGNED_SHORT:
        if (cat_src!=TOK_UNSIGNED_CHAR && cat_src!=TOK_UNSIGNED_SHORT) {
            op = OpUSh;
            break;
        }
        return a1; /* no conversion */
    case TOK_INT:
    case TOK_ENUM:
    case TOK_UNSIGNED:
        return a1; /* no conversion */
    default:
        if (is_integer(cat_src) && get_rank(cat_src)==INT_RANK) {
            if (is_unsigned_int(cat_src))
                op = OpLLZX;
            else
                op = OpLLSX;
            break;
        }
        return a1; /* no conversion */
    }
    /* fall through */
    /* convert */
    a2 = new_temp_addr();
    emit_i(op, dest, a2, a1, 0);
    return a2;
}

/*
 * Evaluate expression `e' and convert the result to type `dest'.
 */
static unsigned ic_expr_convert(ExecNode *e, Declaration *dest)
{
    if (targeting_arch64)
        return do_expr_convert64(e, dest);
    else
        return do_expr_convert32(e, dest);
}

unsigned ic_expression(ExecNode *e, int is_addr, unsigned true_lab, unsigned false_lab)
{
    switch (e->kind.exp) {
    case OpExp:
        switch (e->attr.op) {
        case TOK_COMMA:
            ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
            return ic_expression(e->child[1], FALSE, NOLAB, NOLAB);

        case TOK_ASSIGN: {
            unsigned a1, a2;

            a2 = ic_expr_convert(e->child[1], &e->type);
            if (e->child[0]->kind.exp == IdExp) {
                a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                emit_i(OpAsn, &e->type, a1, a2, 0);
                return a1;
            } else {
                a1 = ic_expression(e->child[0], TRUE, NOLAB, NOLAB);
                ic_indirect_assignment(a1, a2, &e->type);
                return a2;
            }
        }

        case TOK_MUL_ASSIGN:
        case TOK_DIV_ASSIGN:
        case TOK_REM_ASSIGN:
        case TOK_PLUS_ASSIGN:
        case TOK_MINUS_ASSIGN:
        case TOK_LSHIFT_ASSIGN:
        case TOK_RSHIFT_ASSIGN:
        case TOK_BW_AND_ASSIGN:
        case TOK_BW_XOR_ASSIGN:
        case TOK_BW_OR_ASSIGN: {
            ExecNode *new_e;
            unsigned a1, a2;

            /*
             * TOFIX:
             * - This generates code that evaluates the left operand twice.
             *  e.g.
             *      *f() += 123; ==> *f() = *f()+123;
             *  Instead, it should be something like
             *      tmp = f();
             *      *tmp = *tmp+123
             */

            new_e = new_exec_node();
            *new_e = *e;
            switch (e->attr.op) {
                case TOK_MUL_ASSIGN:    new_e->attr.op = TOK_MUL;     break;
                case TOK_DIV_ASSIGN:    new_e->attr.op = TOK_DIV;     break;
                case TOK_REM_ASSIGN:    new_e->attr.op = TOK_REM;     break;
                case TOK_PLUS_ASSIGN:   new_e->attr.op = TOK_PLUS;    break;
                case TOK_MINUS_ASSIGN:  new_e->attr.op = TOK_MINUS;   break;
                case TOK_LSHIFT_ASSIGN: new_e->attr.op = TOK_LSHIFT;  break;
                case TOK_RSHIFT_ASSIGN: new_e->attr.op = TOK_RSHIFT;  break;
                case TOK_BW_AND_ASSIGN: new_e->attr.op = TOK_BW_AND;  break;
                case TOK_BW_XOR_ASSIGN: new_e->attr.op = TOK_BW_XOR;  break;
                case TOK_BW_OR_ASSIGN:  new_e->attr.op = TOK_BW_OR;   break;
            }
            new_e->type.decl_specs = (TypeExp *)e->child[2];
            new_e->type.idl = (TypeExp *)e->child[3];
            a2 = ic_expr_convert(new_e, &e->type);
            if (e->child[0]->kind.exp == IdExp) {
                a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                emit_i(OpAsn, &e->type, a1, a2, 0);
                return a1;
            } else {
                a1 = ic_expression(e->child[0], TRUE, NOLAB, NOLAB);
                ic_indirect_assignment(a1, a2, &e->type);
                return a2;
            }
        }

        case TOK_CONDITIONAL: {
            unsigned L1, L2, L3;

            L1 = new_label();
            L2 = new_label();
            L3 = new_label();

            ic_controlling_expression(e->child[0], L1, L2);
            emit_label(L1);
            if (get_type_category(&e->type) != TOK_VOID) {
                unsigned a;

                a = new_temp_addr();
                emit_i(OpAsn, &e->type, a, ic_expr_convert(e->child[1], &e->type), 0);
                emit_i(OpJmp, NULL, L3, 0, 0);
                emit_label(L2);
                emit_i(OpAsn, &e->type, a, ic_expr_convert(e->child[2], &e->type), 0);
                emit_label(L3);
                return a;
            } else {
                ic_expression(e->child[1], FALSE, NOLAB, NOLAB);
                emit_i(OpJmp, NULL, L3, 0, 0);
                emit_label(L2);
                ic_expression(e->child[2], FALSE, NOLAB, NOLAB);
                emit_label(L3);
                return 0;
            }
        }

        case TOK_OR: {
            unsigned a;
            unsigned L1, L2, L3, L4;

            if (true_lab != NOLAB) {
                assert(false_lab != NOLAB);
                L1 = new_label();

                ic_controlling_expression(e->child[0], true_lab, L1);
                emit_label(L1);
                ic_controlling_expression(e->child[1], true_lab, false_lab);
                return 0;
            } else {
                L1 = new_label();
                L2 = new_label();
                L3 = new_label();
                L4 = new_label();

                a = new_temp_addr();
                ic_controlling_expression(e->child[0], L1, L2);
                emit_label(L2);
                ic_controlling_expression(e->child[1], L1, L3);
                emit_label(L1);
                emit_i(OpAsn, &e->type, a, true_addr, 0);
                emit_i(OpJmp, NULL, L4, 0, 0);
                emit_label(L3);
                emit_i(OpAsn, &e->type, a, false_addr, 0);
                emit_label(L4);
                return a;
            }
        }

        case TOK_AND: {
            unsigned a;
            unsigned L1, L2, L3, L4;

            if (true_lab != NOLAB) {
                assert(false_lab != NOLAB);
                L1 = new_label();

                ic_controlling_expression(e->child[0], L1, false_lab);
                emit_label(L1);
                ic_controlling_expression(e->child[1], true_lab, false_lab);
                return 0;
            } else {
                L1 = new_label();
                L2 = new_label();
                L3 = new_label();
                L4 = new_label();

                a = new_temp_addr();
                ic_controlling_expression(e->child[0], L1, L3);
                emit_label(L1);
                ic_controlling_expression(e->child[1], L2, L3);
                emit_label(L2);
                emit_i(OpAsn, &e->type, a, true_addr, 0);
                emit_i(OpJmp, NULL, L4, 0, 0);
                emit_label(L3);
                emit_i(OpAsn, &e->type, a, false_addr, 0);
                emit_label(L4);
                return a;
            }
        }

        case TOK_EQ:
        case TOK_NEQ:
        case TOK_LT:
        case TOK_GT:
        case TOK_LET:
        case TOK_GET: {
            OpKind op;
            long flags;
            Declaration *ty;
            Token cat1, cat2;
            unsigned a1, a2, a3;

            flags = 0;
            cat1 = get_type_category(&e->child[0]->type);
            cat2 = get_type_category(&e->child[1]->type);
            if (is_wideval(cat1)) {
                ty = &e->child[0]->type;
                flags |= IC_WIDE;
            } else if (is_wideval(cat2)) {
                ty = &e->child[1]->type;
                flags |= IC_WIDE;
            } else {
                ty = &int_ty;
            }

            if (NREG(e->child[0]) >= NREG(e->child[1])) {
                a1 = ic_expr_convert(e->child[0], ty);
                a2 = ic_expr_convert(e->child[1], ty);
            } else {
                a2 = ic_expr_convert(e->child[1], ty);
                a1 = ic_expr_convert(e->child[0], ty);
            }

            if (is_integer(cat1) && is_integer(cat2)
            && is_signed_int(get_promoted_type(cat1)) && is_signed_int(get_promoted_type(cat2)))
                flags |= IC_SIGNED;

            switch (e->attr.op) {
            case TOK_EQ:  op = OpEQ;  break;
            case TOK_NEQ: op = OpNEQ; break;
            case TOK_LT:  op = OpLT;  break;
            case TOK_GT:  op = OpGT;  break;
            case TOK_LET: op = OpLET; break;
            case TOK_GET: op = OpGET; break;
            }
            a3 = new_temp_addr();
            if (false_lab == NOLAB)
                flags |= IC_STORE;
            emit_i(op, (Declaration *)flags, a3, a1, a2);
            return a3;
        }

        case TOK_PLUS: {
            unsigned a1, a2, a3;

            if (is_integer(get_type_category(&e->type))) {
                if (NREG(e->child[0]) >= NREG(e->child[1])) {
                    a1 = ic_expr_convert(e->child[0], &e->type);
                    a2 = ic_expr_convert(e->child[1], &e->type);
                } else {
                    a2 = ic_expr_convert(e->child[1], &e->type);
                    a1 = ic_expr_convert(e->child[0], &e->type);
                }
                a3 = new_temp_addr();
                emit_i(OpAdd, &e->type, a3, a1, a2);
                return a3;
            } else {
                int ii, pi;
                Declaration ty;
                unsigned a4, a5;

                if (is_integer(get_type_category(&e->child[0]->type)))
                    ii = 0, pi = 1;
                else
                    ii = 1, pi = 0;
                if (NREG(e->child[ii]) >= NREG(e->child[pi])) {
                    a1 = ic_expr_convert(e->child[ii], &e->type);
                    a2 = ic_expression(e->child[pi], FALSE, NOLAB, NOLAB);
                } else {
                    a2 = ic_expression(e->child[pi], FALSE, NOLAB, NOLAB);
                    a1 = ic_expr_convert(e->child[ii], &e->type);
                }
                ty = e->child[pi]->type;
                ty.idl = ty.idl->child;
                a3 = new_address(IConstKind);
                address(a3).cont.uval = get_sizeof(&ty);
                a4 = new_temp_addr();
                emit_i(OpMul, &long_ty, a4, a1, a3);
                a5 = new_temp_addr();
                emit_i(OpAdd, &e->type, a5, a2, a4);
                return a5;
            }
        }

        case TOK_MINUS: {
            unsigned a1, a2, a3;

            if (is_integer(get_type_category(&e->child[0]->type))) { /* int-int */
                if (NREG(e->child[0]) >= NREG(e->child[1])) {
                    a1 = ic_expr_convert(e->child[0], &e->type);
                    a2 = ic_expr_convert(e->child[1], &e->type);
                } else {
                    a2 = ic_expr_convert(e->child[1], &e->type);
                    a1 = ic_expr_convert(e->child[0], &e->type);
                }
                a3 = new_temp_addr();
                emit_i(OpSub, &e->type, a3, a1, a2);
                return a3;
            } else {
                Declaration ty;
                unsigned a4, a5;

                if (NREG(e->child[0]) >= NREG(e->child[1])) {
                    a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                    a2 = ic_expr_convert(e->child[1], &e->child[0]->type);
                } else {
                    a2 = ic_expr_convert(e->child[1], &e->child[0]->type);
                    a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                }
                ty = e->child[0]->type;
                ty.idl = ty.idl->child;
                a3 = new_address(IConstKind);
                address(a3).cont.uval = get_sizeof(&ty);
                if (is_integer(get_type_category(&e->child[1]->type))) { /* ptr-int */
                    a4 = new_temp_addr();
                    emit_i(OpMul, &long_ty, a4, a2, a3);
                    a5 = new_temp_addr();
                    emit_i(OpSub, &e->type, a5, a1, a4);
                } else { /* ptr-ptr */
                    a4 = new_temp_addr();
                    emit_i(OpSub, &e->type, a4, a1, a2);
                    a5 = new_temp_addr();
                    emit_i(OpDiv, &long_ty, a5, a4, a3);
                }
                return a5;
            }
        }

        case TOK_LSHIFT:
        case TOK_RSHIFT: {
            unsigned a1, a2, a3;

            if (NREG(e->child[0]) >= NREG(e->child[1])) {
                a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                a2 = ic_expression(e->child[1], FALSE, NOLAB, NOLAB);
            } else {
                a2 = ic_expression(e->child[1], FALSE, NOLAB, NOLAB);
                a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
            }
            a3 = new_temp_addr();
            emit_i((e->attr.op==TOK_LSHIFT)?OpSHL:OpSHR, &e->type, a3, a1, a2);
            return a3;
        }

        case TOK_BW_OR:
        case TOK_BW_XOR:
        case TOK_BW_AND:
        case TOK_MUL:
        case TOK_DIV:
        case TOK_REM: {
            OpKind op;
            unsigned a1, a2, a3;

            if (NREG(e->child[0]) >= NREG(e->child[1])) {
                a1 = ic_expr_convert(e->child[0], &e->type);
                a2 = ic_expr_convert(e->child[1], &e->type);
            } else {
                a2 = ic_expr_convert(e->child[1], &e->type);
                a1 = ic_expr_convert(e->child[0], &e->type);
            }
            a3 = new_temp_addr();
            switch (e->attr.op) {
            case TOK_BW_OR:  op = OpOr;  break;
            case TOK_BW_XOR: op = OpXor; break;
            case TOK_BW_AND: op = OpAnd; break;
            case TOK_MUL:    op = OpMul; break;
            case TOK_DIV:    op = OpDiv; break;
            case TOK_REM:    op = OpRem; break;
            }
            emit_i(op, &e->type, a3, a1, a2);
            return a3;
        }

        case TOK_CAST:
            return ic_expr_convert(e->child[0], (Declaration *)e->child[1]);

        case TOK_PRE_INC:
        case TOK_PRE_DEC: {
            Token cat;
            unsigned a1, a2, a3, a4, a5;

#define CAST()\
    if ((cat=get_type_category(&e->type))==TOK_CHAR || cat==TOK_UNSIGNED_CHAR) {\
        a4 = new_temp_addr();\
        emit_i((cat==TOK_CHAR)?OpCh:OpUCh, NULL, a4, a3, 0);\
    } else if (cat==TOK_SHORT || cat==TOK_UNSIGNED_SHORT) {\
        a4 = new_temp_addr();\
        emit_i((cat==TOK_SHORT)?OpSh:OpUSh, NULL, a4, a3, 0);\
    } else {\
        a4 = a3;\
    }
            a1 = get_step_size(e);
            if (e->child[0]->kind.exp == IdExp) {
                a2 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                a3 = new_temp_addr();
                emit_i((e->attr.op==TOK_PRE_INC)?OpAdd:OpSub, &e->type, a3, a2, a1);
                CAST();
                emit_i(OpAsn, &e->type, a2, a4, 0);
                return a2;
            } else {
                a2 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                a3 = new_temp_addr();
                emit_i((e->attr.op==TOK_PRE_INC)?OpAdd:OpSub, &e->type, a3, a2, a1);
                CAST();
                a5 = ic_expression(e->child[0], TRUE, NOLAB, NOLAB);
                ic_indirect_assignment(a5, a4, &e->type);
                return a4;
            }
        }
#undef CAST

        case TOK_POS_INC:
        case TOK_POS_DEC: {
            unsigned a1, a2, a3, a4;

            a1 = get_step_size(e);
            if (e->child[0]->kind.exp == IdExp) {
                a2 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                a3 = new_temp_addr();
                emit_i(OpAsn, &e->type, a3, a2, 0);
                a4 = new_temp_addr();
                emit_i((e->attr.op==TOK_POS_INC)?OpAdd:OpSub, &e->type, a4, a3, a1);
                emit_i(OpAsn, &e->type, a2, a4, 0);
                return a3;
            } else {
                a2 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                a3 = new_temp_addr();
                emit_i((e->attr.op==TOK_POS_INC)?OpAdd:OpSub, &e->type, a3, a2, a1);
                a4 = ic_expression(e->child[0], TRUE, NOLAB, NOLAB);
                ic_indirect_assignment(a4, a3, &e->type);
                return a2;
            }
        }

        case TOK_ADDRESS_OF:
            return ic_expression(e->child[0], TRUE, NOLAB, NOLAB);
        case TOK_INDIRECTION:
            if (is_addr)
                return ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
            else
                return ic_dereference(ic_expression(e->child[0], FALSE, NOLAB, NOLAB), &e->type);

        case TOK_NEGATION: {
            unsigned a1, a2;

            a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
            a2 = new_temp_addr();
            emit_i(OpNot, &e->child[0]->type, a2, a1, 0);
            return a2;
        }
        case TOK_COMPLEMENT:
        case TOK_UNARY_MINUS: {
            unsigned a1, a2;

            a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
            a2 = new_temp_addr();
            emit_i((e->attr.op==TOK_COMPLEMENT)?OpCmpl:OpNeg, &e->type, a2, a1, 0);
            return a2;
        }
        case TOK_UNARY_PLUS:
            return ic_expression(e->child[0], FALSE, NOLAB, NOLAB);

        case TOK_SUBSCRIPT: {
            int ii, pi;
            Declaration ty;
            unsigned a1, a2, a3, a4, a5;

            if (is_integer(get_type_category(&e->child[0]->type)))
                ii = 0, pi = 1;
            else
                ii = 1, pi = 0;
            if (NREG(e->child[ii]) >= NREG(e->child[pi])) {
                a1 = ic_expr_convert(e->child[ii], &e->child[pi]->type);
                a2 = ic_expression(e->child[pi], FALSE, NOLAB, NOLAB);
            } else {
                a2 = ic_expression(e->child[pi], FALSE, NOLAB, NOLAB);
                a1 = ic_expr_convert(e->child[ii], &e->child[pi]->type);
            }
            ty = e->child[pi]->type;
            ty.idl = ty.idl->child;
            a3 = new_address(IConstKind);
            address(a3).cont.uval = get_sizeof(&ty);
            a4 = new_temp_addr();
            emit_i(OpMul, &long_ty, a4, a1, a3);
            a5 = new_temp_addr();
            emit_i(OpAdd, &long_ty, a5, a2, a4);
            if (is_addr)
                return a5;
            else
                return ic_dereference(a5, &e->type);
        }

        case TOK_FUNCTION: {
            int na;
            OpKind op;
            ExecNode *tmp;
            unsigned a1, a2;
            DeclList *p;

            cg_node(curr_cg_node).is_leaf = FALSE;
            emit_i(OpBegArg, NULL, 0, 0, 0);

            a2 = new_address(IConstKind);
            if (target_arch==ARCH_MIPS || target_arch==ARCH_ARM) {
                Token cat;

                na = 0;
                if ((cat=get_type_category(&e->type))==TOK_STRUCT || cat==TOK_UNION) {
                    if (target_arch==ARCH_MIPS || get_sizeof(&e->type)>4) {
                        /* this is to accommodate the 'return value address' (note arg2!=0) */
                        emit_i(OpArg, &e->type, 0, false_addr, 1);
                        ++na;
                    }
                }
                na += aligned_function_argument(e->child[1], e->locals);
            } else {
                na = function_argument(e->child[1], e->locals);
            }
            address(a2).cont.val = na;

            if (target_arch == ARCH_X64) {
                /*
                 * An OpNOp right before an OpCall/OpIndCall indicates that the
                 * function being called has a variable number of arguments. The
                 * x64 code generator uses this to know if it must set rax to zero
                 * or not.
                 */
                for (p = e->locals; p != NULL; p = p->next) {
                    if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS) {
                        emit_i(OpNOp, NULL, 0, 0, 0);
                        break;
                    }
                }
            }

            tmp = e->child[0];
            while (tmp->kind.exp==OpExp /*&& tmp->attr.op==TOK_STAR*/)
                 tmp = tmp->child[0];
            if (tmp->kind.exp==IdExp && get_type_category(&tmp->type)==TOK_FUNCTION) {
                unsigned tar_fn;

                op = OpCall;
                a1 = new_address(IdKind);
                address(a1).cont.var.e = tmp;
                address(a1).cont.nid = get_var_nid(tmp->attr.str, tmp->attr.var.scope);
                /* add call-graph edge */
                tar_fn = new_cg_node(tmp->attr.str);
                edge_add(&cg_node(curr_cg_node).out, tar_fn);
            } else {
                op = OpIndCall;
                a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
            }
            if (get_type_category(&e->type) != TOK_VOID) {
                unsigned a3;

                a3 = new_temp_addr();
                emit_i(op, &e->type, a3, a1, a2);
                return a3;
            } else {
                emit_i(op, &e->type, 0, a1, a2);
                return 0;
            }
        }

        case TOK_DOT:
        case TOK_ARROW: {
            int is_union;
            unsigned a1;

            if (e->attr.op == TOK_DOT) {
                a1 = ic_expression(e->child[0], TRUE, NOLAB, NOLAB);
                is_union = get_type_category(&e->child[0]->type) == TOK_UNION;
            } else {
                a1 = ic_expression(e->child[0], FALSE, NOLAB, NOLAB);
                is_union = get_type_spec(e->child[0]->type.decl_specs)->op == TOK_UNION;
            }
            if (!is_union) {
                StructMember *m;
                unsigned a2, a3;

                m = get_member_descriptor(get_type_spec(e->child[0]->type.decl_specs), e->child[1]->attr.str);
                a2 = new_address(IConstKind);
                address(a2).cont.uval = m->offset;
                a3 = new_temp_addr();
                emit_i(OpAdd, &long_ty, a3, a1, a2);
                a1 = a3;
            }
            if (is_addr)
                return a1;
            else
                return ic_dereference(a1, &e->type);
        }
        } /* switch (e->attr.op) */
        break;
    case IConstExp: {
        unsigned a;

        a = new_address(IConstKind);
        address(a).cont.uval = e->attr.uval;
        return a;
    }
    case StrLitExp: {
        unsigned a;

        a = new_address(StrLitKind);
        address(a).cont.str = e->attr.str;
        return a;
    }
    case IdExp: {
        Token cat;
        unsigned a1;

        a1 = new_address(IdKind);
        address(a1).cont.var.e = e;
        address(a1).cont.nid = get_var_nid(e->attr.str, e->attr.var.scope);
        if (e->attr.var.duration == DURATION_AUTO)
            address(a1).cont.var.offset = location_get_offset(e->attr.str);

        if (is_addr || (cat=get_type_category(&e->type))==TOK_SUBSCRIPT || cat==TOK_FUNCTION) {
            unsigned a2;

            a2 = new_temp_addr();
            emit_i(OpAddrOf, NULL, a2, a1, 0);
            new_atv(address(a1).cont.nid);
            return a2;
        } else {
            return a1;
        }
    }
    } /* switch (e->kind.exp) */

    assert(0);
}

static void print_addr(unsigned addr)
{
    if (addr == 0)
        return;

    switch (address(addr).kind) {
    case IConstKind:
        fprintf(ic_file, "%lld", address(addr).cont.val);
        break;
    case TempKind:
    case IdKind:
        fprintf(ic_file, "%s", address_sid(addr));
        break;
    case StrLitKind:
        fprintf(ic_file, "\"%s\"", address(addr).cont.str);
        break;
    }
}

static void print_binop(Quad *i, char *op)
{
    print_addr(i->tar);
    fprintf(ic_file, " = ");
    print_addr(i->arg1);
    fprintf(ic_file, " %s ", op);
    print_addr(i->arg2);
}

static void print_unaop(Quad *i, char *op)
{
    print_addr(i->tar);
    fprintf(ic_file, " = %s", op);
    print_addr(i->arg1);
}

static void dump_ic(unsigned fn)
{
    unsigned i;
    unsigned first, last;

    if (cg_node_is_empty(fn))
        return;

    first = cfg_node(cg_node(fn).bb_i).leader;
    last  = cfg_node(cg_node(fn).bb_f).last;
    for (i = first; i <= last; i++) {
        Quad *p;

        p = &ic_instructions[i];
        fprintf(ic_file, "(%d) ", i);
        switch (p->op) {
        case OpAdd: print_binop(p, "+");  break;
        case OpSub: print_binop(p, "-");  break;
        case OpMul: print_binop(p, "*");  break;
        case OpDiv: print_binop(p, "/");  break;
        case OpRem: print_binop(p, "%");  break;
        case OpSHL: print_binop(p, "<<"); break;
        case OpSHR: print_binop(p, ">>"); break;
        case OpAnd: print_binop(p, "&");  break;
        case OpOr:  print_binop(p, "|");  break;
        case OpXor: print_binop(p, "^");  break;
        case OpEQ:  print_binop(p, "=="); break;
        case OpNEQ: print_binop(p, "!="); break;
        case OpLT:  print_binop(p, "<");  break;
        case OpLET: print_binop(p, "<="); break;
        case OpGT:  print_binop(p, ">");  break;
        case OpGET: print_binop(p, ">="); break;

        case OpNeg:  print_unaop(p, "-"); break;
        case OpCmpl: print_unaop(p, "~"); break;
        case OpNot:  print_unaop(p, "!"); break;
        case OpCh:   print_unaop(p, "(char)");           break;
        case OpUCh:  print_unaop(p, "(unsigned char)");  break;
        case OpSh:   print_unaop(p, "(short)");          break;
        case OpUSh:  print_unaop(p, "(unsigned short)"); break;
        /*case OpInt:  print_unaop(p, "(int)"); break;*/
        /*case OpUInt: print_unaop(p, "(unsigned)"); break;*/
        case OpLLSX: print_unaop(p, "(sign-extend to LL)"); break;
        case OpLLZX: print_unaop(p, "(zero-extend to LL)"); break;
        case OpIndAsn:
            fprintf(ic_file, "*");
            print_addr(p->arg1);
            fprintf(ic_file, " = ");
            print_addr(p->arg2);
            break;
        case OpAsn:    print_unaop(p, "");  break;
        case OpAddrOf: print_unaop(p, "&"); break;
        case OpInd:    print_unaop(p, "*"); break;

        case OpLab:
            fprintf(ic_file, "L%lld:", address(p->tar).cont.val);
            break;
        case OpJmp:
            fprintf(ic_file, "jmp L%lld", address(p->tar).cont.val);
            break;
        case OpSwitch:
            fprintf(ic_file, "switch ");
            print_addr(p->arg1);
            fprintf(ic_file, " [");
            print_addr(p->arg2);
            fprintf(ic_file, " labels]");
            break;
        case OpCase:
            fprintf(ic_file, "case ");
            print_addr(p->tar);
            fprintf(ic_file, ", L%lld, %lld", address(p->arg1).cont.val, address(p->arg2).cont.val);
            break;
        case OpCBr:
            fprintf(ic_file, "cbr L%lld, ", address(p->tar).cont.val);
            print_addr(p->arg1);
            fprintf(ic_file, ", L%lld", address(p->arg2).cont.val);
            break;
        case OpBegArg:
            fprintf(ic_file, "begarg");
            break;

        case OpArg:
            fprintf(ic_file, "arg ");
            print_addr(p->arg1);
            break;
        case OpCall:
        case OpIndCall:
            if (p->tar) {
                print_addr(p->tar);
                fprintf(ic_file, " = ");
            }
            if (p->op == OpCall)
                print_addr(p->arg1);
            else
                fprintf(ic_file, "(*"), print_addr(p->arg1), fprintf(ic_file, ")");
            fprintf(ic_file, "() ["); print_addr(p->arg2); fprintf(ic_file, " arg]");
            break;
        case OpRet:
            fprintf(ic_file, "ret ");
            print_addr(p->arg1);
            break;
        }
        fprintf(ic_file, "\n");
    }
}

void ic_main(ExternId ***func_def_list, ExternId ***ext_sym_list)
{
    ExternId *ed;
    unsigned i, j;

    *func_def_list = calloc(1, sizeof(ExternId *)*512);
    *ext_sym_list  = calloc(1, sizeof(ExternId *)*512);

    for (ed=get_external_declarations(), i=j=0; ed != NULL; ed = ed->next) {
        TypeExp *scs;

        if (ed->status == REFERENCED) {
            if ((scs=get_sto_class_spec(ed->decl_specs))==NULL || scs->op!=TOK_STATIC)
                (*ext_sym_list)[j++] = ed;
        } else {
            if (ed->declarator->child!=NULL && ed->declarator->child->op==TOK_FUNCTION) {
                (*func_def_list)[i++] = ed;
            } else {
                ExternId *np;

                np = malloc(sizeof(ExternId));
                np->decl_specs = ed->decl_specs;
                np->declarator = ed->declarator;
                np->enclosing_function = NULL;
                np->next = static_objects_list;
                static_objects_list = np;
            }
        }
    }

    ic_init();
    for (i = 0, ed = (*func_def_list)[i]; ed != NULL; ++i, ed = (*func_def_list)[i]) {
        ic_func_first_instr = ic_instructions_counter;
        curr_cg_node = new_cg_node(ed->declarator->str);
        ic_function_definition(ed->decl_specs, ed->declarator);
        ic_simplify();
        build_CFG();
        ic_reset();
    }
    if (i == 0)
        return;

    ic_find_atv();
    address_taken_variables = bset_new(nid_counter);
    for (i = 0; i < atv_counter; i++)
        bset_insert(address_taken_variables, atv_table[i]);
    free(atv_table);

    /*
     * [!] Important: from now on the nid counter
     * must stand still for the analyses to work
     * correctly.
     */
    number_CG();
    // opt_main();
    for (i = 0; i < cg_nodes_counter; i++) {
        if (ic_outpath!=NULL && equal(cg_node(i).func_id, ic_function_to_print)) {
            ic_file = fopen(ic_outpath, "wb");
            dump_ic(i);
            fclose(ic_file);
        }
        if (cfg_outpath!=NULL && equal(cg_node(i).func_id, cfg_function_to_print)) {
            cfg_dotfile = fopen(cfg_outpath, "wb");
            print_CFG(i);
            fclose(cfg_dotfile);
        }
        /*dflow_Dom(i);*/
        dflow_LiveOut(i);
        // dflow_ReachIn(i, i == cg_nodes_counter-1);
    }
    if (cg_outpath != NULL) {
        cg_dotfile = fopen(cg_outpath, "wb");
        print_CG();
        fclose(cg_dotfile);
    }
}
