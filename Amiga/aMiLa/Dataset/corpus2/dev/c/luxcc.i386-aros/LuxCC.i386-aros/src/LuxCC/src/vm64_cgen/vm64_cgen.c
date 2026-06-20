#include "vm64_cgen.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include "../luxvm/vm.h"
#include "../util/util.h"
#include "../decl.h"
#include "../expr.h"
#include "../imp_lim.h"
#include "../loc.h"
#include "../util/str.h"
#include "../error.h"
#include "../luxcc.h"

#define MAX_STRLIT  1024

static FILE *output_file;
static char *curr_func_name;
static unsigned temp_struct_size;
static char *string_literal_pool[MAX_STRLIT];
static unsigned str_lit_count;
static Declaration int_ty;
static Declaration long_ty;

/* The amount of space to allocate for the current function's local variables. */
static int size_of_local_area = 0;
/* Used to compute the addresses of local variables. */
static int local_offset = VM64_LOCAL_START;
/* Return type of the current function being processed. */
static Declaration ret_ty;

static String *output_buffer;
#define emit(...)   (string_printf(output_buffer, __VA_ARGS__))
#define emitln(...) (string_printf(output_buffer, __VA_ARGS__), string_printf(output_buffer, "\n"))

static unsigned new_string_literal(char *s)
{
    /* TOIMPROVE: search into the pool before add a new string */

    string_literal_pool[str_lit_count] = s;

    return str_lit_count++;
}

static void emit_string_literals(void)
{
    unsigned n;
    unsigned char *c;

    if (str_lit_count == 0)
        return;

    emitln(".data");
    for (n = 0; n < str_lit_count; n++) {
        emitln("@S%u:", n);
        c = (unsigned char *)string_literal_pool[n];
        do
            emitln(".byte %u", *c);
        while (*c++ != '\0');
    }
    string_write(output_buffer, output_file);
    string_clear(output_buffer);
}

static void compound_statement(ExecNode *s, int push_scope);
static void if_statement(ExecNode *s);
static void switch_statement(ExecNode *s);
static void while_statement(ExecNode *s);
static void do_statement(ExecNode *s);
static void for_statement(ExecNode *s);
static void goto_statement(ExecNode *s);
static void continue_statement(void);
static void break_statement(void);
static void return_statement(ExecNode *s);
static void case_statement(ExecNode *s);
static void default_statement(ExecNode *s);
static void expression_statement(ExecNode *s);
static void label_statement(ExecNode *s);
static void asm_statement(ExecNode *s);
static void statement(ExecNode *s);
static void expression(ExecNode *e, int is_addr);
static void expr_convert(ExecNode *e, Declaration *dest);
static unsigned function_argument(ExecNode *arg, DeclList *param);
static void load(ExecNode *e);
static void load_addr(ExecNode *e);
static void store(Declaration *dest_ty);
static void static_object_definition(TypeExp *decl_specs, TypeExp *declarator, int mangle_name);
static int is_64val(Token cat);

/*            */
/* Statements */
/*            */

static unsigned btarget_stack[128], ctarget_stack[128];
static int bt_stack_top = -1, ct_stack_top = -1;

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

int is_64val(Token cat)
{
    switch (cat) {
    case TOK_LONG: case TOK_UNSIGNED_LONG:
    case TOK_LONG_LONG: case TOK_UNSIGNED_LONG_LONG:
    case TOK_STAR: case TOK_SUBSCRIPT: case TOK_FUNCTION:
    case TOK_STRUCT: case TOK_UNION: /* struct/union's address */
        return TRUE;
    default:
        return FALSE;
    }
}

void statement(ExecNode *s)
{
    switch (s->kind.stmt) {
    case CmpndStmt:
        compound_statement(s, TRUE);
        break;
    case IfStmt:
        if_statement(s);
        break;
    case SwitchStmt:
        switch_statement(s);
        break;
    case WhileStmt:
        while_statement(s);
        break;
    case DoStmt:
        do_statement(s);
        break;
    case ForStmt:
        for_statement(s);
        break;
    case GotoStmt:
        goto_statement(s);
        break;
    case ContinueStmt:
        continue_statement();
        break;
    case BreakStmt:
        break_statement();
        break;
    case ReturnStmt:
        return_statement(s);
        break;
    case CaseStmt:
        case_statement(s);
        break;
    case DefaultStmt:
        default_statement(s);
        break;
    case ExpStmt:
        expression_statement(s);
        break;
    case LabelStmt:
        label_statement(s);
        break;
    case AsmStmt:
        asm_statement(s);
        break;
    }
}

void asm_statement(ExecNode *s)
{
    emit("%s", s->attr.str);
}

static void do_auto_init(TypeExp *ds, TypeExp *dct, ExecNode *e, int offset)
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
            /*
             * Character array initialized by string literal.
             */
            unsigned n;

            emitln("ldbp %d;", offset);
            expression(e, FALSE);
            n = strlen(e->attr.str)+1;
            if (nelem == n) {
                /* fits nicely */
                emitln("memcpy %d;", n);
            } else if (nelem < n) {
                /* no enough room; just copy the first nelem chars of the string */
                emitln("memcpy %d;", nelem);
            } else {
                /* copy all the string and zero the trailing elements */
                emitln("memcpy %d;", n);
                emitln("ldiqw %d;", n);
                emitln("addqw;");
                emitln("ldidw 0;");
                emitln("fill %d;", nelem-n);
            }
            emitln("pop;");
            emitln("pop;");
        } else {
            unsigned elem_size;
            Declaration elem_ty;

            /*
             * Get element size.
             */
            elem_ty.decl_specs = ds;
            elem_ty.idl = dct->child;
            elem_size = get_sizeof(&elem_ty);

            /*
             * Handle elements with explicit initializer.
             */
            e = e->child[0];
            for (; e!=NULL && nelem!=0; e=e->sibling, --nelem) {
                do_auto_init(ds, dct->child, e, offset);
                offset += elem_size;
            }

            /*
             * Handle elements without explicit initializer.
             */
            if (nelem != 0) {
                /* there are nelem elements to zero */
                emitln("ldbp %d;", offset);
                emitln("ldidw 0;");
                emitln("fill %d;", nelem*elem_size);
                emitln("pop;");
                emitln("pop;");
            }
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

        /*
         * Handle members with explicit initializer.
         */
        d = ts->attr.dl;
        full_init = FALSE;
        for (; d != NULL; d = d->next) {
            dct = d->decl->idl;
            for (; e!=NULL && dct!=NULL; e=e->sibling, dct=dct->sibling) {
                unsigned mem_offs;

                mem_offs = get_member_descriptor(ts, dct->str)->offset;
                do_auto_init(d->decl->decl_specs, dct->child, e, offset+mem_offs);
            }

            if (e == NULL) {
                if (dct==NULL && d->next==NULL)
                    full_init = TRUE;
                break;
            }
        }

        /*
         * Handle members without explicit initializer.
         */
        if (!full_init) {
            if (dct == NULL) {
                d = d->next;
                dct = d->decl->idl;
            }
            while (TRUE) {
                while (dct != NULL) {
                    StructMember *md;

                    md = get_member_descriptor(ts, dct->str);
                    emitln("ldbp %d;", offset+md->offset);
                    emitln("ldidw 0;");
                    emitln("fill %d;", md->size);
                    emitln("pop;");
                    emitln("pop;");
                    dct = dct->sibling;
                }
                d = d->next;
                if (d != NULL)
                    dct = d->decl->idl;
                else
                    break;
            }
        }
    } else if (ts->op == TOK_UNION) {
        /*
         * Union.
         */

        if (e->attr.op != TOK_INIT_LIST)
            goto scalar;
        e = e->child[0];

        /* initialize the first named member */
        do_auto_init(ts->attr.dl->decl->decl_specs, ts->attr.dl->decl->idl->child, e, offset);
    } else {
        /*
         * Scalar.
         */
        Declaration dest_ty;
scalar:
        if (e->kind.exp==OpExp && e->attr.op==TOK_INIT_LIST)
            e = e->child[0];
        dest_ty.decl_specs = ds;
        dest_ty.idl = dct;
        expr_convert(e, &dest_ty);
        emitln("ldbp %d;", offset);
        store(&dest_ty);
        emitln("pop;");
        if (is_64val(get_type_category(&dest_ty)))
            emitln("pop;");
    }
}

void compound_statement(ExecNode *s, int push_scope)
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
                    for (dct = dl->decl->idl; dct != NULL; dct = dct->sibling)
                        static_object_definition(dl->decl->decl_specs, dct, TRUE);
                    emitln(".text");
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
                location_new(dct->str, local_offset);
                emitln("# var: %s, offset: %d", dct->str, local_offset);
                if (dct->attr.e != NULL)
                    do_auto_init(lty.decl_specs, lty.idl, dct->attr.e, local_offset);
                local_offset += get_sizeof(&lty);
            }
        }
    }
    for (sl = s->child[0]; sl != NULL; sl = sl->sibling)
        statement(sl);

    if (local_offset > size_of_local_area)
        size_of_local_area = local_offset;

    if (push_scope && s->locals!=NULL) {
        local_offset = old_local_offset;
        location_pop_scope();
    }
}

#define emit_lab(n)         (emitln("@L%u:", n))
#define emit_jmp(target)    (emitln("jmp @L%u;", target))
#define emit_jmpf(target)   (emitln("jmpf @L%u;", target))
#define emit_jmpt(target)   (emitln("jmpt @L%u;", target))

static unsigned new_label(void)
{
    static unsigned label_count = 1;
    return label_count++;
}

static void controlling_expression(ExecNode *e)
{
    expression(e, FALSE);
    if (is_64val(get_type_category(&e->type)))
        emitln("ordw;");
}

void if_statement(ExecNode *s)
{
    /*
     * if (e)
     *      stmt1
     * else
     *      stmt2
     */

    unsigned L1, L2;

    /* e */
    controlling_expression(s->child[0]);
    L1 = L2 = new_label();
    emit_jmpf(L1);
    /* stmt1 */
    statement(s->child[1]);
    if (s->child[2] != NULL) {
        /* stmt2 */
        L2 = new_label();
        emit_jmp(L2);
        emit_lab(L1);
        statement(s->child[2]);
    }
    emit_lab(L2); /* L1==L2 if no ELSE-part */
}

void while_statement(ExecNode *s)
{
    /*
     * while (e)
     *      stmt
     */

    unsigned L1, L2;

    L1 = new_label();
    L2 = new_label();
    /* e */
    emit_lab(L1);
    controlling_expression(s->child[0]);
    emit_jmpf(L2);
    /* stmt */
    push_break_target(L2), push_continue_target(L1);
    statement(s->child[1]);
    pop_break_target(), pop_continue_target();
    emit_jmp(L1);
    emit_lab(L2);
}

void do_statement(ExecNode *s)
{
    /*
     * do
     *      stmt
     * while (e);
     */

    unsigned L1, L2, L3;

    L1 = new_label();
    L2 = new_label();
    L3 = new_label();
    /* stmt */
    emit_lab(L1);
    push_break_target(L3), push_continue_target(L2);
    statement(s->child[1]);
    pop_break_target(), pop_continue_target();
    /* e */
    emit_lab(L2);
    controlling_expression(s->child[0]);
    emit_jmpf(L3);
    emit_jmp(L1);
    emit_lab(L3);
}

void for_statement(ExecNode *s)
{
    /*
     * for (e1; e2; e3)
     *      stmt;
     */

    unsigned L1, L2, L3;

    /* e1 */
    if (s->child[1] != NULL) {
        expression(s->child[1], FALSE);
        emitln("pop;");
        if (is_64val(get_type_category(&s->child[1]->type)))
            emitln("pop;");
    }

    L1 = new_label();
    if (s->child[2] != NULL)
        L2 = new_label();
    L3 = new_label();

    /* e2 */
    emit_lab(L1);
    if (s->child[0] != NULL) {
        controlling_expression(s->child[0]);
        emit_jmpf(L3);
    }
    /* stmt */
    push_break_target(L3), push_continue_target((s->child[2]!=NULL)?L2:L1);
    statement(s->child[3]);
    pop_break_target(), pop_continue_target();
    /* e3 */
    if (s->child[2] != NULL) {
        emit_lab(L2);
        expression(s->child[2], FALSE);
        emitln("pop;");
        if (is_64val(get_type_category(&s->child[2]->type)))
            emitln("pop;");
    }
    emit_jmp(L1);
    emit_lab(L3);
}

void goto_statement(ExecNode *s)
{
    emitln("jmp @@%s_%s;", curr_func_name, s->attr.str);
}

void label_statement(ExecNode *s)
{
    /* mangled label name = "@@" + current function name + '_' + label name */
    emitln("@@%s_%s:", curr_func_name, s->attr.str);
    statement(s->child[0]);
}

void continue_statement(void)
{
    emit_jmp(ctarget_stack[ct_stack_top]);
}

void break_statement(void)
{
    emit_jmp(btarget_stack[bt_stack_top]);
}

void return_statement(ExecNode *s)
{
    if (s->child[0] != NULL) {
        Token cat;

        cat = get_type_category(&ret_ty);

        /*
         * The return value is always a qword.
         * If the result is smaller (e.g. int),
         * the caller must explicitly discard
         * the H.O. dword.
         */
        if (is_integer(cat) && get_rank(cat)<=INT_RANK)
            expr_convert(s->child[0], &long_ty);
        else
            expr_convert(s->child[0], &ret_ty);

        if (cat==TOK_STRUCT || cat==TOK_UNION) {
            unsigned size;

            size = get_sizeof(&ret_ty);
            if (size > temp_struct_size)
                temp_struct_size = size;
            emitln("ldiqw __temp_struct;");
            emitln("swap2;");
            emitln("memcpy %d;", size);
        }
    } else {
        emitln("ldiqw 0;");
    }
    emitln("ret;");
}

void expression_statement(ExecNode *s)
{
    if (s->child[0] == NULL)
        return;

    expression(s->child[0], FALSE);
    emitln("pop;");
    if (is_64val(get_type_category(&s->child[0]->type)))
        emitln("pop;");
}

/*
 * Switch statement.
 * TOIMPROVE:
 *  - avoid the HASH_SIZE iterations when building the search table.
 */
#define HASH_SIZE       1009
#define HASH_VAL(s)     (hash(s)%HASH_SIZE)
#define HASH_VAL2(x)    (hash2(x)%HASH_SIZE)

typedef struct SwitchLabel SwitchLabel;
static struct SwitchLabel {
    unsigned lab;
    long long val;
    int is_default;
    SwitchLabel *next;
} *switch_labels[MAX_SWITCH_NEST][HASH_SIZE];
static int switch_nesting_level = -1;

static int cmp_switch_label(const void *p1, const void *p2)
{
    SwitchLabel *x1 = *(SwitchLabel **)p1;
    SwitchLabel *x2 = *(SwitchLabel **)p2;

    /* the default label is always at the beginning */
    if (x1->is_default)
        return -1;
    if (x2->is_default)
        return 1;

    if (x1->val < x2->val)
        return -1;
    else if (x1->val == x2->val)
        return 0;
    else
        return 1;
}

static void install_switch_label(long long val, int is_default, unsigned lab)
{
    unsigned h;
    SwitchLabel *np;

    np = malloc(sizeof(SwitchLabel));
    np->lab = lab;
    np->val = val;
    np->is_default = is_default;
    h = is_default?0:HASH_VAL2((unsigned long)val);
    np->next = switch_labels[switch_nesting_level][h];
    switch_labels[switch_nesting_level][h] = np;
}

void switch_statement(ExecNode *s)
{
    unsigned ST, EXIT;
    int i, st_size, ce64;
    SwitchLabel *search_table[MAX_CASE_LABELS], *np;

    /*
     * Controlling expression.
     */
    ce64 = (get_rank(get_type_category(&s->child[0]->type)) >= LONG_RANK);
    ST = new_label();
    expression(s->child[0], FALSE);
    emitln("ldiqw @T%d;", ST);
    emitln("%s;", ce64 ? "switch2" : "switch");

    /*
     * Body.
     */
    ++switch_nesting_level;
    EXIT = new_label();
    push_break_target(EXIT);
    statement(s->child[1]);
    pop_break_target();
    emit_lab(EXIT);

    /*
     * Build search table.
     */
    st_size = 0;
    for (i = 0; i < HASH_SIZE; i++) {
        if (switch_labels[switch_nesting_level][i] != NULL) {
            for (np = switch_labels[switch_nesting_level][i]; np != NULL; np = np->next)
                search_table[st_size++] = np;
            switch_labels[switch_nesting_level][i] = NULL;
        }
    }
    --switch_nesting_level;
    if (st_size != 0)
        qsort(search_table, st_size, sizeof(search_table[0]), cmp_switch_label);
    /*
     * Emit search table.
     */
    emitln(".data");
    emitln(".align 8");
    emitln("@T%d:", ST);
    if (st_size == 0) {
        /* if there are no labels at all, the body of the switch is skipped */
        emitln(".dword 1");
        if (ce64)
            emitln(".dword 0");
        emitln(".qword @L%d", EXIT);
        emitln(".text");
        return;
    }

    /* emit case values */
    /* the first value corresponds to the default case and is the size of the search table */
    if (!search_table[0]->is_default) {
        /* there is no default label */
        emitln(".dword %d", st_size+1);
        i = 0;
    } else {
        emitln(".dword %d", st_size);
        i = 1;
    }
    if (ce64)
        emitln(".dword 0");
    while (i < st_size) {
        emitln(".dword %d", ((int *)&search_table[i]->val)[0]);
        if (ce64)
            emitln(".dword %d", ((int *)&search_table[i]->val)[1]);
        ++i;
    }

    /* emit labels */
    /* the first label correspond to the default case; if there is none the exit label acts as default */
    if (!search_table[0]->is_default)
        emitln(".qword @L%d", EXIT);
    for (i = 0; i < st_size; i++) {
        emitln(".qword @L%d", search_table[i]->lab);
        free(search_table[i]);
    }
    emitln(".text");
}

void case_statement(ExecNode *s)
{
    unsigned L;

    L = new_label();
    install_switch_label(s->child[0]->attr.val, FALSE, L);
    emit_lab(L);
    statement(s->child[1]);
}

void default_statement(ExecNode *s)
{
    unsigned L;

    L = new_label();
    install_switch_label(0, TRUE, L);
    emit_lab(L);
    statement(s->child[0]);
}

/*             */
/* Expressions */
/*             */

/*
 * Generate code for expression `e'.
 * Cast the result (dword or qword on top of the stack) to type `dest'.
 */
void expr_convert(ExecNode *e, Declaration *dest)
{
    Token cat_dest, cat_src;

    expression(e, FALSE);

    cat_src  = get_type_category(&e->type);
    cat_dest = get_type_category(dest);

    switch (cat_dest) {
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
        if (is_64val(cat_src)) {
            emitln("pop;");
            emitln("dw2b;");
        } else if (cat_src!=TOK_CHAR && cat_src!=TOK_SIGNED_CHAR) {
            emitln("dw2b;");
        }
        break;
    case TOK_UNSIGNED_CHAR:
        if (is_64val(cat_src)) {
            emitln("pop;");
            emitln("dw2ub;");
        } else if (cat_src != TOK_UNSIGNED_CHAR) {
            emitln("dw2ub;");
        }
        break;
    case TOK_SHORT:
        if (is_64val(cat_src)) {
            emitln("pop;");
            emitln("dw2w;");
        } else {
            switch (cat_src) {
            case TOK_CHAR: case TOK_SIGNED_CHAR:
            case TOK_UNSIGNED_CHAR:
            case TOK_SHORT:
                break;
            default:
                emitln("dw2w;");
                break;
            }
        }
        break;
    case TOK_UNSIGNED_SHORT:
        if (is_64val(cat_src)) {
            emitln("pop;");
            emitln("dw2uw;");
        } else if (cat_src!=TOK_UNSIGNED_CHAR && cat_src!=TOK_UNSIGNED_SHORT) {
            emitln("dw2uw;");
        }
        break;
    case TOK_INT:
    case TOK_ENUM:
    case TOK_UNSIGNED:
        if (is_64val(cat_src))
            emitln("pop;");
        break;
    case TOK_STAR:
    case TOK_SUBSCRIPT:
    case TOK_FUNCTION:
    case TOK_LONG:
    case TOK_UNSIGNED_LONG:
    case TOK_LONG_LONG:
    case TOK_UNSIGNED_LONG_LONG:
        if (is_integer(cat_src) && get_rank(cat_src)<=INT_RANK) {
            if (is_unsigned_int(cat_src))
                emitln("udw2qw;");
            else
                emitln("dw2qw;");
        }
        break;
    default: /* no conversion required */
        break;
    }
}

/*
 * Push arguments from right to left recursively.
 * Maintain the stack aligned.
 */
unsigned function_argument(ExecNode *arg, DeclList *param)
{
    Token ty_cat;
    Declaration ty;
    unsigned arg_area_size, real_arg_size, aligned_arg_size;

    if (arg == NULL)
        return 0;

    if (param->decl->idl==NULL || param->decl->idl->op!=TOK_ELLIPSIS) {
        /*
         * This argument matches a declared (non-optional) parameter.
         */
        arg_area_size = function_argument(arg->sibling, param->next);
        ty.decl_specs = param->decl->decl_specs;
        /* just get the type part of the declarator, skip any identifier */
        if (param->decl->idl!=NULL && param->decl->idl->op==TOK_ID)
            ty.idl = param->decl->idl->child;
        else
            ty.idl = param->decl->idl;
        expr_convert(arg, &ty);
        real_arg_size = get_sizeof(&ty);
    } else {
        /*
         * This and the arguments that follow match the `...'.
         */
        arg_area_size = function_argument(arg->sibling, param);
        expression(arg, FALSE);
        ty = arg->type;
        if (ty.idl!=NULL && (ty.idl->op==TOK_SUBSCRIPT || ty.idl->op==TOK_FUNCTION))
            real_arg_size = 4;
        else
            real_arg_size = get_sizeof(&arg->type);
    }
    aligned_arg_size = round_up(real_arg_size, VM64_STACK_ALIGN);
    arg_area_size += aligned_arg_size;

    /*
     * Copy struct/unions by value.
     */
    if ((ty_cat=get_type_category(&ty))==TOK_STRUCT || ty_cat==TOK_UNION)
        emitln("ldn %d;", real_arg_size);

    return arg_area_size;
}

void expression(ExecNode *e, int is_addr)
{
    Token cat;

    switch (e->kind.exp) {
    case OpExp:
        switch (e->attr.op) {
        case TOK_COMMA:
            expression(e->child[0], FALSE);
            emitln("pop;");
            if (is_64val(get_type_category(&e->child[0]->type)))
                emitln("pop;");
            expression(e->child[1], FALSE);
            break;
        case TOK_ASSIGN:
            expr_convert(e->child[1], &e->type);
            expression(e->child[0], TRUE);
            store(&e->type);
            break;
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
            ExecNode new_e;

            new_e = *e;
            switch (e->attr.op) {
                case TOK_MUL_ASSIGN:    new_e.attr.op = TOK_MUL;     break;
                case TOK_DIV_ASSIGN:    new_e.attr.op = TOK_DIV;     break;
                case TOK_REM_ASSIGN:    new_e.attr.op = TOK_REM;     break;
                case TOK_PLUS_ASSIGN:   new_e.attr.op = TOK_PLUS;    break;
                case TOK_MINUS_ASSIGN:  new_e.attr.op = TOK_MINUS;   break;
                case TOK_LSHIFT_ASSIGN: new_e.attr.op = TOK_LSHIFT;  break;
                case TOK_RSHIFT_ASSIGN: new_e.attr.op = TOK_RSHIFT;  break;
                case TOK_BW_AND_ASSIGN: new_e.attr.op = TOK_BW_AND;  break;
                case TOK_BW_XOR_ASSIGN: new_e.attr.op = TOK_BW_XOR;  break;
                case TOK_BW_OR_ASSIGN:  new_e.attr.op = TOK_BW_OR;   break;
            }
            new_e.type.decl_specs = (TypeExp *)e->child[2];
            new_e.type.idl = (TypeExp *)e->child[3];
            expr_convert(&new_e, &e->type);
            expression(e->child[0], TRUE);
            store(&e->type);
            break;
        }

        case TOK_CONDITIONAL: {
            /*
             * e1 ? e2 : e3
             */

            unsigned L1, L2;

            L1 = new_label();
            L2 = new_label();
            /* e1 */
            controlling_expression(e->child[0]);
            emit_jmpf(L1);
            /* e2 */
            expr_convert(e->child[1], &e->type);
            emit_jmp(L2);
            /* e3 */
            emit_lab(L1);
            expr_convert(e->child[2], &e->type);
            emit_lab(L2);
            break;
        }

        case TOK_OR: {
            unsigned L1, L2;

            L1 = new_label();
            L2 = new_label();

            controlling_expression(e->child[0]);
            emit_jmpt(L1);
            controlling_expression(e->child[1]);
            emit_jmpt(L1);
            emitln("ldidw 0;");
            emit_jmp(L2);
            emit_lab(L1);
            emitln("ldidw 1;");
            emit_lab(L2);
            break;
        }
        case TOK_AND: {
            unsigned L1, L2;

            L1 = new_label();
            L2 = new_label();

            controlling_expression(e->child[0]);
            emit_jmpf(L1);
            controlling_expression(e->child[1]);
            emit_jmpf(L1);
            emitln("ldidw 1;");
            emit_jmp(L2);
            emit_lab(L1);
            emitln("ldidw 0;");
            emit_lab(L2);
            break;
        }

#define BIN_OPS()   expression(e->child[0], FALSE), expression(e->child[1], FALSE)
#define BIN_OPS2()  expr_convert(e->child[0], &e->type), expr_convert(e->child[1], &e->type)
        case TOK_BW_OR:
            if (get_rank(get_type_category(&e->type)) >= LONG_RANK) {
                BIN_OPS2();
                emitln("orqw;");
            } else {
                BIN_OPS();
                emitln("ordw;");
            }
            break;
        case TOK_BW_XOR:
            if (get_rank(get_type_category(&e->type)) >= LONG_RANK) {
                BIN_OPS2();
                emitln("xorqw;");
            } else {
                BIN_OPS();
                emitln("xordw;");
            }
            break;
        case TOK_BW_AND:
            if (get_rank(get_type_category(&e->type)) >= LONG_RANK) {
                BIN_OPS2();
                emitln("andqw;");
            } else {
                BIN_OPS();
                emitln("anddw;");
            }
            break;

        case TOK_EQ:
        case TOK_NEQ: {
            char *op;

            op = (e->attr.op == TOK_EQ) ? "eq" : "neq";
            if (is_64val(get_type_category(&e->child[0]->type))) {
                expression(e->child[0], FALSE);
                expr_convert(e->child[1], &e->child[0]->type);
                emitln("%sqw;", op);
            } else if (is_64val(get_type_category(&e->child[1]->type))) {
                expr_convert(e->child[0], &e->child[1]->type);
                expression(e->child[1], FALSE);
                emitln("%sqw;", op);
            } else {
                BIN_OPS();
                emitln("%sdw;", op);
                break;
            }
        }
            break;

        case TOK_LT:
        case TOK_GT:
        case TOK_LET:
        case TOK_GET: {
            char *sign, *size;
            Token cat1, cat2;

            cat1 = get_type_category(&e->child[0]->type);
            cat2 = get_type_category(&e->child[1]->type);

            if (is_64val(cat1)) {
                expression(e->child[0], FALSE);
                expr_convert(e->child[1], &e->child[0]->type);
                size = "qw";
            } else if (is_64val(cat2)) {
                expr_convert(e->child[0], &e->child[1]->type);
                expression(e->child[1], FALSE);
                size = "qw";
            } else {
                BIN_OPS();
                size = "dw";
            }
            if (is_integer(cat1) && is_integer(cat2)) {
                if (is_unsigned_int(get_promoted_type(cat1)) || is_unsigned_int(get_promoted_type(cat2)))
                    sign = "u";
                else
                    sign = "s";
            } else { /* at least one of the operands has pointer type */
                sign = "u";
            }
            switch (e->attr.op) {
            case TOK_LT:
                emitln("%slt%s;", sign, size);
                break;
            case TOK_GT:
                emitln("%sgt%s;", sign, size);
                break;
            case TOK_LET:
                emitln("%slet%s;", sign, size);
                break;
            case TOK_GET:
                emitln("%sget%s;", sign, size);
                break;
            }
        }
            break;

        case TOK_LSHIFT:
            expression(e->child[0], FALSE);
            expr_convert(e->child[1], &int_ty);
            if (get_rank(get_type_category(&e->type)) >= LONG_RANK)
                emitln("sllqw;");
            else
                emitln("slldw;");
            break;
        case TOK_RSHIFT: {
            char *skind;

            cat = get_type_category(&e->type);
            skind = is_unsigned_int(cat) ? "l" : "a";

            expression(e->child[0], FALSE);
            expr_convert(e->child[1], &int_ty);
            if (get_rank(cat) >= LONG_RANK)
                emitln("sr%sqw;", skind);
            else
                emitln("sr%sdw;", skind);
        }
            break;

        case TOK_PLUS:
            if (is_integer(cat=get_type_category(&e->type))) {
                if (get_rank(cat) >= LONG_RANK) {
                    BIN_OPS2();
                    emitln("addqw;");
                } else {
                    BIN_OPS();
                    emitln("adddw;");
                }
            } else {
                int i, j;
                unsigned size;
                Declaration ty;

                if (is_integer(get_type_category(&e->child[0]->type)))
                    i = 0, j = 1;
                else
                    i = 1, j = 0;
                ty.decl_specs = e->child[j]->type.decl_specs;
                ty.idl = e->child[j]->type.idl->child;

                expression(e->child[j], FALSE);
                /*
                 * XXX: What does the standard says about the integer operand?.
                 *      It is promoted, converted (to what?), ...
                 */
                expr_convert(e->child[i], &e->type);
                if ((size=get_sizeof(&ty)) > 1) {
                    emitln("ldiqw %d;", size);
                    emitln("mulqw;");
                }
                emitln("addqw;");
            }
            break;
        case TOK_MINUS:
            if (is_integer(cat=get_type_category(&e->child[0]->type))) {
                if (get_rank(cat) >= LONG_RANK) {
                    BIN_OPS2();
                    emitln("subqw;");
                } else {
                    BIN_OPS();
                    emitln("subdw;");
                }
            } else {
                unsigned size;
                Declaration ty;

                ty.decl_specs = e->child[0]->type.decl_specs;
                ty.idl = e->child[0]->type.idl->child;
                size = get_sizeof(&ty);
                expression(e->child[0], FALSE);
                expr_convert(e->child[1], &e->child[0]->type);
                if (is_integer(get_type_category(&e->child[1]->type))) { /* pointer - integer */
                    if (size > 1) {
                        emitln("ldiqw %d;", size);
                        emitln("mulqw;");
                    }
                    emitln("subqw;");
                } else { /* pointer - pointer */
                    emitln("subqw;");
                    if (size > 1) {
                        emitln("ldiqw %d;", size);
                        emitln("sdivqw;");
                    }
                }
            }
            break;

        case TOK_MUL:
            if (get_rank(get_type_category(&e->type)) >= LONG_RANK) {
                BIN_OPS2();
                emitln("mulqw;");
            } else {
                BIN_OPS();
                emitln("muldw;");
            }
            break;
        case TOK_DIV:
        case TOK_REM: {
            char *sign, *op;

            cat = get_type_category(&e->type);
            sign = is_unsigned_int(cat) ? "u" : "s";
            op = (e->attr.op == TOK_DIV) ? "div" : "mod";
            if (get_rank(cat) >= LONG_RANK) {
                BIN_OPS2();
                emitln("%s%sqw;", sign, op);
            } else {
                BIN_OPS();
                emitln("%s%sdw;", sign, op);
            }
        }
            break;

        case TOK_CAST:
            expr_convert(e->child[0], (Declaration *)e->child[1]);
            break;

        case TOK_PRE_INC:
        case TOK_PRE_DEC: {
            int is64;

            expression(e->child[0], TRUE);
            emitln("dup2;");
            emitln("dup2;");
            load(e);
            if (is_integer(cat=get_type_category(&e->type))) {
                if (get_rank(cat) <= INT_RANK) {
                    emitln("ldidw 1;");
                    is64 = FALSE;
                } else {
                    emitln("ldiqw 1;");
                    is64 = TRUE;
                }
            } else { /* pointer */
                Declaration pointed_to_ty;

                pointed_to_ty.decl_specs = e->type.decl_specs;
                pointed_to_ty.idl = e->type.idl->child;
                emitln("ldiqw %d;", get_sizeof(&pointed_to_ty));
                is64 = TRUE;
            }
            if (is64) {
                (e->attr.op == TOK_PRE_INC) ? emitln("addqw;") : emitln("subqw;");
                emitln("swap2;");
                store(&e->type);
            } else {
                (e->attr.op == TOK_PRE_INC) ? emitln("adddw;") : emitln("subdw;");
                emitln("dup;");
                emitln("swap2;");
                store(&e->type);
            }
            emitln("pop;");
            emitln("pop;");
            /* reload incremented/decremented value */
            load(e);
        }
            break;
        case TOK_POS_INC:
        case TOK_POS_DEC: {
            int is64;

            cat = get_type_category(&e->type);
            is64 = is_64val(cat);

            expression(e->child[0], TRUE);
            emitln("dup2;");
            load(e);
            if (!is64)
                emitln("dw2qw;");
            emitln("swap2;");
            emitln("dup2;");
            load(e);
            if (!is64)
                emitln("%s2qw;", is_unsigned_int(cat) ? "dw" : "udw");
            if (is_integer(cat)) {
                emitln("ldiqw 1;");
            } else { /* pointer */
                Declaration pointed_to_ty;

                pointed_to_ty.decl_specs = e->type.decl_specs;
                pointed_to_ty.idl = e->type.idl->child;
                emitln("ldiqw %d;", get_sizeof(&pointed_to_ty));
            }
            (e->attr.op == TOK_POS_INC) ? emitln("addqw;") : emitln("subqw;");
            if (!is64) {
                emitln("pop;");
                emitln("dup;");
            }
            emitln("swap2;");
            store(&e->type);
            emitln("pop;");
            emitln("pop;");
            if (!is64)
                emitln("pop;");
        }
            break;

        case TOK_ADDRESS_OF:
            expression(e->child[0], TRUE);
            break;
        case TOK_INDIRECTION:
            expression(e->child[0], FALSE);
            if (!is_addr)
                load(e);
            break;

        case TOK_UNARY_PLUS:
        case TOK_UNARY_MINUS:
        case TOK_COMPLEMENT: {
            char *size;

            expression(e->child[0], FALSE);
            if (get_rank(get_type_category(&e->type)) >= LONG_RANK)
                size = "qw";
            else
                size = "dw";
            switch (e->attr.op) {
            case TOK_UNARY_PLUS:
                break;
            case TOK_UNARY_MINUS:
                emitln("neg%s;", size);
                break;
            case TOK_COMPLEMENT:
                emitln("cmpl%s;", size);
                break;
            }
        }
            break;
        case TOK_NEGATION:
            expression(e->child[0], FALSE);
            if (is_64val(get_type_category(&e->child[0]->type)))
                emitln("notqw;");
            else
                emitln("notdw;");
            break;

        case TOK_SUBSCRIPT: {
            unsigned size;

            if (is_pointer(get_type_category(&e->child[0]->type))) { /* a[i] */
                expression(e->child[0], FALSE);
                expr_convert(e->child[1], &e->child[0]->type);
            } else { /* i[a] */
                expression(e->child[1], FALSE);
                expr_convert(e->child[0], &e->child[1]->type);
            }
            if ((size=get_sizeof(&e->type)) > 1) {
                emitln("ldiqw %d;", size);
                emitln("mulqw;");
            }
            emitln("addqw;");
            if (!is_addr)
                load(e);
        }
            break;
        case TOK_FUNCTION: {
            unsigned arg_siz;

            arg_siz = function_argument(e->child[1], e->locals);
            expression(e->child[0], FALSE);
            emitln("call %d;", arg_siz);
            if ((cat=get_type_category(&e->type))==TOK_VOID || is_integer(cat) && get_rank(cat)<=INT_RANK)
                emitln("pop;");
            break;
        }
        case TOK_DOT:
        case TOK_ARROW: {
            int is_union;

            if (e->attr.op == TOK_DOT)
                is_union = get_type_category(&e->child[0]->type) == TOK_UNION;
            else
                is_union = get_type_spec(e->child[0]->type.decl_specs)->op == TOK_UNION;

            expression(e->child[0], FALSE);
            if (!is_union) {
                StructMember *m;

                m = get_member_descriptor(get_type_spec(e->child[0]->type.decl_specs), e->child[1]->attr.str);
                emitln("ldiqw %d;", m->offset);
                emitln("addqw;");
            }
            if (!is_addr)
                load(e);
        }
            break;
        } /* switch (e->attr.op) */
        break;
    case IConstExp:
        if (get_rank(get_type_category(&e->type)) >= LONG_RANK)
            emitln("ldiqw %lld;", e->attr.val);
        else
            emitln("ldidw %d;", (int)e->attr.val);
        break;
    case StrLitExp:
        emitln("ldiqw @S%d;", new_string_literal(e->attr.str));
        break;
    case IdExp:
        load_addr(e);
        if (!is_addr)
            load(e);
        break;
    } /* switch (e->kind.exp) */
}

void store(Declaration *dest_ty)
{
    switch (get_type_category(dest_ty)) {
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
    case TOK_UNSIGNED_CHAR:
        emitln("stb;");
        break;
    case TOK_SHORT:
    case TOK_UNSIGNED_SHORT:
        emitln("stw;");
        break;
    case TOK_INT:
    case TOK_ENUM:
    case TOK_UNSIGNED:
        emitln("stdw;");
        break;
    case TOK_STAR:
    case TOK_SUBSCRIPT:
    case TOK_FUNCTION:
    case TOK_LONG:
    case TOK_UNSIGNED_LONG:
    case TOK_LONG_LONG:
    case TOK_UNSIGNED_LONG_LONG:
        emitln("stqw;");
        break;
    case TOK_STRUCT:
    case TOK_UNION:
        emitln("swap2;");
        emitln("memcpy %d;", get_sizeof(dest_ty));
        break;
    }
}

void load(ExecNode *e)
{
    Token cat;

    cat = get_type_category(&e->type);
    switch (cat) {
    case TOK_STRUCT:
    case TOK_UNION:
        break;
    case TOK_FUNCTION:
    case TOK_SUBSCRIPT:
        /* load the start address (already done) */
        break;
    case TOK_STAR:
    case TOK_LONG:
    case TOK_UNSIGNED_LONG:
    case TOK_LONG_LONG:
    case TOK_UNSIGNED_LONG_LONG:
        emitln("ldqw;");
        break;
    case TOK_INT:
    case TOK_UNSIGNED:
    case TOK_ENUM:
        emitln("lddw;");
        break;
    case TOK_SHORT:
        emitln("ldw;");
        break;
    case TOK_UNSIGNED_SHORT:
        emitln("lduw;");
        break;
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
        emitln("ldb;");
        break;
    case TOK_UNSIGNED_CHAR:
        emitln("ldub;");
        break;
    }
}

void load_addr(ExecNode *e)
{
    if (e->attr.var.duration == DURATION_STATIC) {
        if (e->attr.var.linkage == LINKAGE_NONE) /* static local */
            emitln("ldiqw @%s_%s;", curr_func_name, e->attr.str); /* use the mangled name */
        else /* external */
            emitln("ldiqw %s;", e->attr.str);
    } else { /* parameter or local */
        int offset;

        offset = location_get_offset(e->attr.str);
        emitln("ldbp %d;", offset);
    }
}

static long long do_static_expr(ExecNode *e)
{
    switch (e->kind.exp) {
    case OpExp:
        switch (e->attr.op) {
        case TOK_SUBSCRIPT: {
            int pi, ii;
            Declaration ty;

            if (is_integer(get_type_category(&e->child[0]->type)))
                pi = 1, ii = 0;
            else
                pi = 0, ii = 1;
            ty = e->child[pi]->type;
            ty.idl = ty.idl->child;
            return do_static_expr(e->child[pi])+get_sizeof(&ty)*do_static_expr(e->child[ii]);
        }
        case TOK_DOT:
        case TOK_ARROW:
            if (get_type_category(&e->child[0]->type) != TOK_UNION) {
                StructMember *m;

                m = get_member_descriptor(get_type_spec(e->child[0]->type.decl_specs), e->child[1]->attr.str);
                return do_static_expr(e->child[0])+m->offset;
            } else {
                return do_static_expr(e->child[0]);
            }
        case TOK_ADDRESS_OF:
        case TOK_INDIRECTION:
        case TOK_CAST:
            return do_static_expr(e->child[0]);

        case TOK_PLUS:
            if (is_integer(get_type_category(&e->type))) {
                return do_static_expr(e->child[0])+do_static_expr(e->child[1]);
            } else {
                int pi, ii;
                Declaration ty;

                if (is_integer(get_type_category(&e->child[0]->type)))
                    pi = 1, ii = 0;
                else
                    pi = 0, ii = 1;
                ty = e->child[pi]->type;
                ty.idl = ty.idl->child;
                return do_static_expr(e->child[pi])+get_sizeof(&ty)*do_static_expr(e->child[ii]);
            }
        case TOK_MINUS:
            if (is_integer(get_type_category(&e->child[0]->type))) { /* int-int */
                return do_static_expr(e->child[0])-do_static_expr(e->child[1]);
            } else { /* ptr-int */
                Declaration ty;

                ty = e->child[0]->type;
                ty.idl = ty.idl->child;
                return do_static_expr(e->child[0])-get_sizeof(&ty)*do_static_expr(e->child[1]);
            }
        case TOK_CONDITIONAL:
            if (e->child[0]->attr.val)
                return do_static_expr(e->child[1]);
            else
                return do_static_expr(e->child[2]);
        default:
            assert(0);
        }
    case IConstExp:
        return e->attr.val;
    case StrLitExp:
        emit("@S%d+", new_string_literal(e->attr.str));
        return 0;
    case IdExp:
        if (e->attr.var.linkage == LINKAGE_NONE)
            emit("@%s_%s+", curr_func_name, e->attr.str);
        else
            emit("%s+", e->attr.str);
        return 0;
    }
}

static void do_static_init(TypeExp *ds, TypeExp *dct, ExecNode *e)
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
            /*
             * Character array initialized by string literal.
             */
            unsigned n;
            unsigned char *c;

            n = 0;
            c = (unsigned char *)e->attr.str;
            do
                emitln(".byte %u", *c), ++n;
            while (n<nelem && *c++!='\0');

            /* zero any trailing elements */
            if (n < nelem)
                emitln(".zero %d", nelem-n);
        } else {
            /*
             * Handle elements with explicit initializer.
             */
            e = e->child[0];
            for (; e!=NULL && nelem!=0; e=e->sibling, --nelem)
                do_static_init(ds, dct->child, e);

            /*
             * Handle elements without explicit initializer.
             */
            if (nelem != 0) {
                Declaration elem_ty;

                elem_ty.decl_specs = ds;
                elem_ty.idl = dct->child;
                emitln(".align %d", get_alignment(&elem_ty));
                emitln(".zero %d", nelem*get_sizeof(&elem_ty));
            }
        }
    } else if ((ts=get_type_spec(ds))->op == TOK_STRUCT) {
        /*
         * Struct.
         */
        DeclList *d;
        int full_init;
        Declaration ty;
        unsigned align;

        e = e->child[0];

        /* align struct beginning */
        ty.decl_specs = ts;
        ty.idl = NULL;
        if ((align=get_alignment(&ty)) > 1)
            emitln(".align %u", align);

        /*
         * Handle members with explicit initializer.
         */
        d = ts->attr.dl;
        full_init = FALSE;
        for (; d != NULL; d = d->next) {
            dct = d->decl->idl;
            for (; e!=NULL && dct!=NULL; e=e->sibling, dct=dct->sibling)
                do_static_init(d->decl->decl_specs, dct->child, e);

            if (e == NULL) {
                if (dct==NULL && d->next==NULL)
                    full_init = TRUE;
                break;
            }
        }

        /*
         * Handle members without explicit initializer.
         */
        if (!full_init) {
            if (dct == NULL) {
                d = d->next;
                dct = d->decl->idl;
            }
            while (TRUE) {
                while (dct != NULL) {
                    Declaration ty;

                    ty.decl_specs = d->decl->decl_specs;
                    ty.idl = dct->child;
                    emitln(".align %d", get_alignment(&ty));
                    emitln(".zero %d", get_sizeof(&ty));

                    dct = dct->sibling;
                }
                d = d->next;
                if (d != NULL)
                    dct = d->decl->idl;
                else
                    break;
            }
        }
    } else if (ts->op == TOK_UNION) {
        /*
         * Union.
         */
        Declaration ty;
        unsigned align;

        e = e->child[0];

        /* align union beginning */
        ty.decl_specs = ts;
        ty.idl = NULL;
        if ((align=get_alignment(&ty)) > 1)
            emitln(".align %u", align);

        /* initialize the first named member */
        do_static_init(ts->attr.dl->decl->decl_specs, ts->attr.dl->decl->idl->child, e);
    } else {
        /*
         * Scalar.
         */
        Declaration dest_ty;
scalar:
        if (e->kind.exp==OpExp && e->attr.op==TOK_INIT_LIST)
            e = e->child[0];
        dest_ty.decl_specs = ds;
        dest_ty.idl = dct;
        switch (get_type_category(&dest_ty)) {
        case TOK_CHAR:
        case TOK_SIGNED_CHAR:
        case TOK_UNSIGNED_CHAR:
            emit(".byte ");
            break;
        case TOK_SHORT:
        case TOK_UNSIGNED_SHORT:
            emitln(".align 2");
            emit(".word ");
            break;
        case TOK_INT:
        case TOK_UNSIGNED:
        case TOK_ENUM:
            emitln(".align 4");
            emit(".dword ");
            break;
        case TOK_STAR:
        case TOK_LONG:
        case TOK_UNSIGNED_LONG:
        case TOK_LONG_LONG:
        case TOK_UNSIGNED_LONG_LONG:
            emitln(".align 8");
            emit(".qword ");
            emitln("%lld", do_static_expr(e));
            return;
        }
        emitln("%d", (int)do_static_expr(e));
    }
}

void static_object_definition(TypeExp *decl_specs, TypeExp *declarator, int mangle_name)
{
    TypeExp *scs;
    Declaration ty;
    ExecNode *initializer;
    unsigned alignment;

    ty.decl_specs = decl_specs;
    ty.idl = declarator->child;
    initializer = declarator->attr.e;

    /* segment */
    if (initializer != NULL)
        emitln(".data");
    else
        emitln(".bss");

    /* alignment */
    if ((alignment=get_alignment(&ty)) > 1)
        emitln(".align %d", alignment);

    /* label */
    if (mangle_name)
        /* mangled name = '@' + current function name + '_' + static local object name */
        emitln("@%s_%s:", curr_func_name, declarator->str);
    else
        emitln("%s:", declarator->str);

    /* allocation/initialization */
    if (initializer != NULL)
        do_static_init(ty.decl_specs, ty.idl, initializer);
    else
        emitln(".res %d", get_sizeof(&ty));

    if ((scs=get_sto_class_spec(decl_specs))==NULL || scs->op!=TOK_STATIC)
        emitln(".global %s", declarator->str);
}

static void function_definition(TypeExp *decl_specs, TypeExp *header)
{
    DeclList *p;
    TypeExp *scs;
    int param_offs;
    char num[11], *cp;
    unsigned addsp_param, pos_tmp;

    curr_func_name = header->str;
    emitln("# ==== start of definition of function `%s' ====", curr_func_name);
    emitln(".text");
    emitln("%s:", curr_func_name);
    if ((scs=get_sto_class_spec(decl_specs))==NULL || scs->op!=TOK_STATIC)
        emitln(".global %s", curr_func_name);
    emit("addsp ");
    addsp_param = string_get_pos(output_buffer);
    emitln("XXXXXXXXXXX");

    location_push_scope();

    p = header->child->attr.dl;
    if (get_type_spec(p->decl->decl_specs)->op==TOK_VOID && p->decl->idl==NULL)
        p = NULL; /* function with no parameters */

    param_offs = VM64_LOCAL_PARAM_END;
    while (p != NULL) {
        Declaration pty;

        if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
            break; /* start of optional parameters (`...') */

        pty.decl_specs = p->decl->decl_specs;
        pty.idl = p->decl->idl->child;
        param_offs -= round_up(get_sizeof(&pty), VM64_STACK_ALIGN);
        location_new(p->decl->idl->str, param_offs);
        emitln("# param:`%s', offset:%d", p->decl->idl->str, param_offs);

        p = p->next;
    }

    /* set return type before encounter any return statement */
    ret_ty.decl_specs = decl_specs;
    ret_ty.idl = header->child->child;

    compound_statement(header->attr.e, FALSE);
    location_pop_scope();

    /* fix up the amount of storage to allocate for locals */
    pos_tmp = string_get_pos(output_buffer);
    string_set_pos(output_buffer, addsp_param);
    sprintf(num, "%d", round_up(size_of_local_area-VM64_LOCAL_START, VM64_STACK_ALIGN));
    cp = string_curr(output_buffer);
    strncpy(cp, num, 10);
    cp += strlen(num);
    *cp++ = ';';
    while (*cp != '\n')
        *cp++ = ' ';
    string_set_pos(output_buffer, pos_tmp);

    size_of_local_area = 0;
    local_offset = VM64_LOCAL_START;

    emitln("ldidw 0;");
    emitln("ret;");
}

void vm64_cgen(FILE *outf)
{
    ExternId *ed;

    location_init();
    output_file = outf;
    output_buffer = string_new(4096);
    int_ty.decl_specs = get_type_node(TOK_INT);
    int_ty.idl = NULL;
    long_ty.decl_specs = get_type_node(TOK_LONG);
    long_ty.idl = NULL;

    for (ed = get_external_declarations(); ed != NULL; ed = ed->next) {
        if (ed->status == REFERENCED) {
            TypeExp *scs;

            if ((scs=get_sto_class_spec(ed->decl_specs))==NULL || scs->op!=TOK_STATIC)
                emitln(".extern %s", ed->declarator->str);
        } else {
            if (ed->declarator->child!=NULL && ed->declarator->child->op==TOK_FUNCTION)
                function_definition(ed->decl_specs, ed->declarator);
            else
                static_object_definition(ed->decl_specs, ed->declarator, FALSE);
        }

        string_write(output_buffer, output_file);
        string_clear(output_buffer);
    }
    if (temp_struct_size > 0) {
        emitln(".bss");
        emitln(".align 8");
        emitln("__temp_struct:");
        emitln(".res %d", temp_struct_size);
        string_write(output_buffer, output_file);
        string_clear(output_buffer);
    }
    emit_string_literals();
}
