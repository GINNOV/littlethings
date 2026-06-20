#include "expr.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>
#include <assert.h>
#include "util/util.h"
#include "decl.h"
#include "error.h"
#include "luxcc.h"

/*
 * Print error and set to 'error' the type of
 * the node 'tok' (generally an operator node).
 */
#define ERROR(tok, ...)\
    do {\
        emit_error(FALSE, (tok)->info->src_file, (tok)->info->src_line, (tok)->info->src_column, __VA_ARGS__);\
        (tok)->type.decl_specs = get_type_node(TOK_ERROR);\
    } while (0)

#define ERROR_R(tok, ...)\
    do {\
        ERROR(tok, __VA_ARGS__);\
        return;\
    } while (0)

#define WARNING(tok, ...) emit_warning((tok)->info->src_file, (tok)->info->src_line, (tok)->info->src_column, __VA_ARGS__)
#define FATAL_ERROR(tok, ...) emit_error(TRUE, (tok)->info->src_file, (tok)->info->src_line, (tok)->info->src_column, __VA_ARGS__)

/*
 * Macro used by functions that analyze binary operators. If any of the operands has
 * type 'error', set the result type as 'error' too and return. This is helpful to
 * avoid error cascades.
 *  E.g. the expression `&0 + 1', with syntax tree
 *          +
 *         / \
 *        &   1
 *        |
 *        0
 * When + examines the operands and encounters that the left is invalid (has type 'error'
 * derived from the invalid application of & to an integer constant) it just sets 'error'
 * as its own type and returns (instead of printing a message like 'invalid operands to
 * binary +'). Only the code that analyzes & will print a diagnostic.
 */
#define IS_ERROR_BINARY(e, ty_l, ty_r)\
    if (ty_l==TOK_ERROR || ty_r==TOK_ERROR) {\
        e->type.decl_specs = get_type_node(TOK_ERROR);\
        return;\
    }
/*
 * Similar to above but for unary operators.
 */
#define IS_ERROR_UNARY(e, ty)\
    if (ty == TOK_ERROR) {\
        e->type.decl_specs = get_type_node(TOK_ERROR);\
        return;\
    }

Token get_type_category(Declaration *d)
{
    if (/*d->decl_specs!=NULL && */d->decl_specs->op==TOK_ERROR)
        return TOK_ERROR;

    if (d->idl != NULL)
        return d->idl->op;
    else
        return get_type_spec(d->decl_specs)->op;
}

int is_integer(Token ty)
{
    switch (ty) {
    case TOK_LONG_LONG: case TOK_UNSIGNED_LONG_LONG:
    case TOK_LONG: case TOK_UNSIGNED_LONG:
    case TOK_INT: case TOK_UNSIGNED:
    case TOK_SHORT: case TOK_UNSIGNED_SHORT:
    case TOK_CHAR: case TOK_SIGNED_CHAR: case TOK_UNSIGNED_CHAR:
    case TOK_ENUM:
        return TRUE;
    default:
        return FALSE;
    }
}

int is_pointer(Token op)
{
    /*
     * Note: function designators are checked for explicitly by the code.
     */
    return (op==TOK_STAR || op==TOK_SUBSCRIPT);
}

static int is_scalar(Token op)
{
    /*
     * Note: function designators and arrays are checked for explicitly.
     */
    return (is_integer(op) || op==TOK_STAR);
}

/*
 *    The C expressions that can be lvalues are:
 * Expression             Additional requirements
 *  name                   name must be a variable
 *  e[k]                   none
 *  (e)                    e must be an lvalue
 *  e.name                 e must be an lvalue
 *  e->name                none
 *  *e                     none
 *  string-constant        none
 */
static int is_lvalue(ExecNode *e)
{
    if (e->kind.exp == IdExp) {
        if (e->type.idl!=NULL && e->type.idl->op==TOK_FUNCTION)
            return FALSE;
        return TRUE;
    } else if (e->kind.exp == OpExp) {
        switch (e->attr.op) {
        case TOK_SUBSCRIPT:
        case TOK_ARROW:
        case TOK_INDIRECTION:
            return TRUE;
        case TOK_DOT:
            return is_lvalue(e->child[0]);
        default:
            return FALSE;
        }
    } else if (e->kind.exp == StrLitExp) {
        return TRUE;
    } else if (e->kind.exp == IConstExp) {
        return FALSE;
    }

    assert(0);
}

static int is_modif_struct_union(TypeExp *type)
{
    DeclList *d;
    TypeExp *dct;

    for (d = type->attr.dl; d != NULL; d = d->next) {
        TypeExp *ts, *tq;

        tq = get_type_qual(d->decl->decl_specs);
        ts = get_type_spec(d->decl->decl_specs);

        for (dct = d->decl->idl; dct != NULL; dct = dct->sibling) {
            TypeExp *p;

            p = dct->child;
            if (p!=NULL && p->op==TOK_SUBSCRIPT)
                /* search the element type */
                for (; p!=NULL && p->op==TOK_SUBSCRIPT; p = p->child);

            if (p == NULL) {
                /* the member type is not a derived declarator type */
                if (tq!=NULL && (tq->op==TOK_CONST||tq->op==TOK_CONST_VOLATILE)) {
                    return FALSE;
                } else if (ts->op==TOK_STRUCT || ts->op==TOK_UNION) {
                    /* see if one of the members is non-modifiable */
                    if (ts->attr.dl == NULL)
                        ts = lookup_tag(ts->str, TRUE)->type;
                    if (!is_modif_struct_union(ts))
                        return FALSE;
                }
            } else if (p->op == TOK_STAR) {
                if (p->attr.el!=NULL
                && (p->attr.el->op==TOK_CONST||p->attr.el->op==TOK_CONST_VOLATILE))
                    return FALSE;
            }
        }
    }

    return TRUE;
}

int is_modif_lvalue(ExecNode *e)
{
    /*
     * 6.3.2.1#1
     * A modifiable lvalue is an lvalue that does not have array type, does not have an
     * incomplete type, does not have a const-qualified type, and if it is a structure
     * or union, does not have any member (including, recursively, any member or element
     * of all contained aggregates or unions) with a const-qualified type.
     */
    Token ty;

    if (!is_lvalue(e))
        return FALSE;

    ty = get_type_category(&e->type);
    if (ty == TOK_SUBSCRIPT) {
        return FALSE;
    } else if (ty == TOK_STAR) {
        if (e->type.idl->attr.el!=NULL
        && (e->type.idl->attr.el->op==TOK_CONST||e->type.idl->attr.el->op==TOK_CONST_VOLATILE))
            return FALSE;
    } else if (ty == TOK_VOID) {
        return FALSE;
    } else {
        TypeExp *tq;

        if ((tq=get_type_qual(e->type.decl_specs))!=NULL && (tq->op==TOK_CONST||tq->op==TOK_CONST_VOLATILE))
            return FALSE;

        if (ty==TOK_STRUCT||ty==TOK_UNION||ty==TOK_ENUM) {
            TypeExp *ts;

            ts = get_type_spec(e->type.decl_specs);
            if (!is_complete(ts->str))
                return FALSE;
            if (ty!=TOK_ENUM && !is_modif_struct_union(ts))
                return FALSE;
        }
    }

    return TRUE;
}

Token get_promoted_type(Token int_ty)
{
    switch (int_ty) {
    case TOK_CHAR: case TOK_UNSIGNED_CHAR: case TOK_SIGNED_CHAR:
    case TOK_SHORT: case TOK_UNSIGNED_SHORT:
        return TOK_INT;
    default:
        return int_ty; /* promotion is not required */
    }
}

/*
 * Every integer type has an integer conversion rank.
 * Integer conversion ranks from highest to lowest
 * 1) long long int, unsigned long long int
 * 2) long int, unsigned long int
 * 3) int, unsigned int
 * 4) short int, unsigned short int
 * 5) char, signed char, unsigned char
 * 6) _Bool *
 * (*) not supported
 */
int get_rank(Token ty)
{
    switch (ty) {
    case TOK_LONG_LONG:
    case TOK_UNSIGNED_LONG_LONG:
        return LLONG_RANK;
    case TOK_LONG:
    case TOK_UNSIGNED_LONG:
        return LONG_RANK;
    case TOK_INT:
    case TOK_UNSIGNED:
    case TOK_ENUM: /* the standard does not require this (see 6.7.2.2#4) */
        return INT_RANK;
    case TOK_SHORT:
    case TOK_UNSIGNED_SHORT:
        return SHORT_RANK;
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
    case TOK_UNSIGNED_CHAR:
        return CHAR_RANK;
    }

    assert(0);
}

int is_signed_int(Token ty)
{
    switch (ty) {
    case TOK_CHAR:
    case TOK_SIGNED_CHAR:
    case TOK_SHORT:
    case TOK_INT:
    case TOK_LONG:
    case TOK_LONG_LONG:
    case TOK_ENUM:
        return TRUE;
    default:
        return FALSE;
    }
}

int is_unsigned_int(Token ty)
{
    switch (ty) {
    case TOK_UNSIGNED_CHAR:
    case TOK_UNSIGNED_SHORT:
    case TOK_UNSIGNED:
    case TOK_UNSIGNED_LONG:
    case TOK_UNSIGNED_LONG_LONG:
        return TRUE;
    default:
        return FALSE;
    }
}

/*
 * ty1, ty2: promoted operands.
 */
Token get_result_type(Token ty1, Token ty2)
{
    /*
     * 6.3.1.8 Usual arithmetic conversions.
     * [...]
     * If both operands have the same type, then no further conversion is needed.
     */

    /*
     * Otherwise, the integer promotions are performed on both operands. Then the
     * following rules are applied to the promoted operands:
     */
    int rank1, rank2;
    int sign1, sign2;

    /*
     * If both operands have the same type, then no further conversion is needed.
     */
    if (ty1 == ty2)
        return ty1;

    /* fetch rank and sign */
    rank1 = get_rank(ty1);
    rank2 = get_rank(ty2);
    sign1 = is_signed_int(ty1);
    sign2 = is_signed_int(ty2);

    /*
     * Otherwise, if both operands have signed integer types or both have unsigned
     * integer types, the operand with the type of lesser integer conversion rank is
     * converted to the type of the operand with greater rank.
     */
    if (sign1 == sign2)
        return (rank1>rank2)?ty1:ty2;

    /*
     * Otherwise, if the operand that has unsigned integer type has rank greater or
     * equal to the rank of the type of the other operand, then the operand with
     * signed integer type is converted to the type of the operand with unsigned
     * integer type.
     */
    if (!sign1 && rank1>=rank2)
        return ty1;
    if (!sign2 && rank2>=rank1)
        return ty2;

    /*
     * Otherwise, if the type of the operand with signed integer type can represent
     * all of the values of the type of the operand with unsigned integer type, then
     * the operand with unsigned integer type is converted to the type of the
     * operand with signed integer type.
     */
    if (targeting_arch64) { /* assume LP64 data model */
        if (sign1) {
            if (ty2 != TOK_UNSIGNED_LONG)
                return ty1;
        } else {
            if (ty1 != TOK_UNSIGNED_LONG)
                return ty2;
        }
    } else {
        if (sign1) {
            if (ty1 == TOK_LONG_LONG)
                return ty1;
        } else {
            if (ty2 == TOK_LONG_LONG)
                return ty2;
        }
    }

    /*
     * Otherwise, both operands are converted to the unsigned integer type
     * corresponding to the type of the operand with signed integer type.
     */
    if (sign1)
        return (ty1 == TOK_LONG) ? TOK_UNSIGNED_LONG : TOK_UNSIGNED_LONG_LONG;
    else
        return (ty2 == TOK_LONG) ? TOK_UNSIGNED_LONG : TOK_UNSIGNED_LONG_LONG;
}

/* [!] do not modify the returned nodes */
TypeExp *get_type_node(Token ty)
{
    static TypeExp ty_char                  = { TOK_CHAR };
    static TypeExp ty_int                   = { TOK_INT };
    static TypeExp ty_unsigned              = { TOK_UNSIGNED };
    static TypeExp ty_long                  = { TOK_LONG };
    static TypeExp ty_unsigned_long         = { TOK_UNSIGNED_LONG };
    static TypeExp ty_long_long             = { TOK_LONG_LONG };
    static TypeExp ty_unsigned_long_long    = { TOK_UNSIGNED_LONG_LONG };
    static TypeExp ty_error                 = { TOK_ERROR };
    static TypeExp ty_void                  = { TOK_VOID };

    switch (ty) {
    case TOK_CHAR:                  return &ty_char;
    case TOK_INT: case TOK_ENUM:    return &ty_int;
    case TOK_UNSIGNED:              return &ty_unsigned;
    case TOK_LONG:                  return &ty_long;
    case TOK_UNSIGNED_LONG:         return &ty_unsigned_long;
    case TOK_LONG_LONG:             return &ty_long_long;
    case TOK_UNSIGNED_LONG_LONG:    return &ty_unsigned_long_long;
    case TOK_ERROR:                 return &ty_error;
    case TOK_VOID:                  return &ty_void;
    }
    assert(0);
}

/*
 * Shorthand function used by the most of binary operators.
 */
void binary_op_error(ExecNode *op)
{
    char *ty1, *ty2;

    ty1 = stringify_type_exp(&op->child[0]->type, TRUE);
    ty2 = stringify_type_exp(&op->child[1]->type, TRUE);
    ERROR(op, "invalid operands to binary %s (`%s' and `%s')", tok2lex(op->attr.op), ty1, ty2);
    free(ty1), free(ty2);
}

int is_ptr2obj(Declaration *p)
{
    if (p->idl->child != NULL) {
        if (p->idl->child->op == TOK_FUNCTION)
            return FALSE; /* pointer to function */
        if (p->idl->child->op==TOK_SUBSCRIPT && p->idl->child->attr.e==NULL)
            return FALSE; /* pointer to incomplete type */
    } else {
        TypeExp *ts;

        ts = get_type_spec(p->decl_specs);
        if (is_struct_union_enum(ts->op)&&!is_complete(ts->str) || ts->op==TOK_VOID)
            return FALSE; /* pointer to incomplete type */
    }

    return TRUE;
}

#define is_void_ptr(c, t) ((c)!=TOK_FUNCTION && (t).idl->child==NULL && get_type_spec((t).decl_specs)->op==TOK_VOID)
#define is_func_ptr(c, t) ((c)==TOK_FUNCTION || (t).idl->child!=NULL && (t).idl->child->op==TOK_FUNCTION)

/*
 * See if the expression `e' can be stored in a variable of type `dest_ty'.
 */
int can_assign_to(Declaration *dest_ty, ExecNode *e)
{
    /*
     * 6.5.16.1 Simple assignment
     * Constraints
     * 1# One of the following shall hold:
     * - the left operand has qualified or unqualified arithmetic type and the right has
     * arithmetic type;
     * - the left operand has a qualified or unqualified version of a structure or union type
     * compatible with the type of the right;
     * - both operands are pointers to qualified or unqualified versions of compatible types,
     * and the type pointed to by the left has all the qualifiers of the type pointed to by the
     * right;
     * - one operand is a pointer to an object or incomplete type and the other is a pointer to a
     * qualified or unqualified version of void, and the type pointed to by the left has all
     * the qualifiers of the type pointed to by the right;
     * - the left operand is a pointer and the right is a null pointer constant;
     */
    Token cat_d, cat_s;
    Declaration *src_ty;

    src_ty = &e->type;

    cat_d = get_type_category(dest_ty);
    cat_s = get_type_category(src_ty);

    if (is_integer(cat_d)) {
        if (is_integer(cat_s)) {
            int rank_d, rank_s;

            /*
             * If the src expression is an integer constant, try to verify that
             * the constant fits into the dest type. Emit a warning if it doesn't.
             */
            if (e->kind.exp == IConstExp) {
                long long val, final_val;

                val = e->attr.val;
                switch (cat_d) {
                case TOK_UNSIGNED_LONG_LONG:
                case TOK_LONG_LONG:
                    return TRUE;
                case TOK_UNSIGNED_LONG:
                    if (targeting_arch64)
                        return TRUE;
                    /* fall-through */
                case TOK_UNSIGNED:
                    if (val<0 || val>UINT_MAX) {
                        final_val = (unsigned)e->attr.uval;
                        break;
                    }
                    return TRUE;
                case TOK_LONG:
                    if (targeting_arch64)
                        return TRUE;
                    /* fall-through */
                case TOK_INT:
                case TOK_ENUM:
                    if (val<INT_MIN || val>INT_MAX) {
                        final_val = (int)e->attr.uval;
                        break;
                    }
                    return TRUE;
                case TOK_SHORT:
                    if (val<SHRT_MIN || val>SHRT_MAX) {
                        final_val = (short)e->attr.uval;
                        break;
                    }
                    return TRUE;
                case TOK_UNSIGNED_SHORT:
                    if (val<0 || val>USHRT_MAX) {
                        final_val = (unsigned short)e->attr.uval;
                        break;
                    }
                    return TRUE;
                case TOK_CHAR:
                case TOK_SIGNED_CHAR:
                    if (val<CHAR_MIN || val>CHAR_MAX) {
                        final_val = (signed char)e->attr.uval;
                        break;
                    }
                    return TRUE;
                case TOK_UNSIGNED_CHAR:
                    if (val<0 || val>UCHAR_MAX) {
                        final_val = (unsigned char)e->attr.uval;
                        break;
                    }
                    return TRUE;
                default:
                    assert(0);
                }
                if (is_signed_int(cat_s))
                    WARNING(e, "implicit conversion changes value from %lld to %lld", val, final_val);
                else
                    WARNING(e, "implicit conversion changes value from %llu to %lld", val, final_val);
                return TRUE;
            }

            rank_d = get_rank(cat_d);
            rank_s = get_rank(cat_s);
            if (targeting_arch64) {
                /* consider long and long long as having the same rank */
                rank_d = (rank_d==LLONG_RANK)?LONG_RANK:rank_d;
                rank_s = (rank_s==LLONG_RANK)?LONG_RANK:rank_s;
            } else {
                /* consider int and long as having the same rank */
                rank_d = (rank_d==LONG_RANK)?INT_RANK:rank_d;
                rank_s = (rank_s==LONG_RANK)?INT_RANK:rank_s;
            }

            /*
             * Emit a warning if the destination type is narrower than the source type.
             */
            if (rank_s > rank_d)
                WARNING(e, "implicit conversion loses integer precision: `%s' to `%s'",
                tok2lex(cat_s), tok2lex(cat_d));
            /*
             * Otherwise, emit a warning if the source and destination
             * types do not have the same signedness.
             */
            else if (rank_d==rank_s && is_signed_int(cat_d)!=is_signed_int(cat_s))
                WARNING(e, "implicit conversion changes signedness: `%s' to `%s'",
                tok2lex(cat_s), tok2lex(cat_d));
        } else if (is_pointer(cat_s) || cat_s==TOK_FUNCTION) {
            WARNING(e, "pointer to integer conversion without a cast");
        } else {
            return FALSE;
        }
    } else if (cat_d==TOK_STRUCT || cat_d==TOK_UNION) {
        TypeExp *ts_d, *ts_s;

        if (cat_d != cat_s)
            return FALSE;

        ts_d = get_type_spec(dest_ty->decl_specs);
        ts_s = get_type_spec(src_ty->decl_specs);
        if (ts_d->str != ts_s->str)
            return FALSE;
    } else if (cat_d == TOK_STAR) {
        if (is_pointer(cat_s) || cat_s==TOK_FUNCTION) {
            TypeExp *ts_d, *ts_s;

            /*
             * Check if the pointers are assignment compatible (without having into
             * account type qualifiers). Emit a warning an return if they are not.
             */
            if (!are_compatible(dest_ty->decl_specs, (cat_d!=TOK_FUNCTION)?dest_ty->idl->child:dest_ty->idl,
            src_ty->decl_specs, (cat_s!=TOK_FUNCTION)?src_ty->idl->child:src_ty->idl, FALSE, FALSE)) {
                /*
                 * They do not point to the same type, see if one of them is `void *'
                 * and the other is a pointer to an object or incomplete type
                 */
                if (is_void_ptr(cat_d, *dest_ty)) {
                    /* the destination operand is `void *' */
                    if (is_func_ptr(cat_s, *src_ty)) {
                        /* the source operand is a function pointer */
                        WARNING(e, "function pointer implicitly converted to void pointer");
                        return TRUE;
                    }
                } else if (is_void_ptr(cat_s, *src_ty)) {
                    /* the source operand is `void *' */
                    if (is_func_ptr(cat_d, *dest_ty)) {
                        /* the destination operand is a function pointer */
                        /*
                         * Check for the special case of NULL:
                         *      func_ptr = (void *)0;
                         */
                        if (e->kind.exp==OpExp
                        && e->attr.op==TOK_CAST
                        && e->child[0]->kind.exp==IConstExp
                        && e->child[0]->attr.val==0)
                            return TRUE;
                        WARNING(e, "void pointer implicitly converted to function pointer");
                        return TRUE;
                    }
                } else {
                    /* everything failed, just emit a warning and return */
                    WARNING(e, "assignment from incompatible pointer type");
                    return TRUE;
                }
            }
            /* fall through */

            /*
             * Verify that the type pointed to by the left operand has
             * all the qualifiers of the type pointed to by the right,
             * and emit a warning if this requirement is not met.
             */
            ts_d = ts_s = NULL;

            /* fetch qualifiers of left pointed to type */
            if (dest_ty->idl->child == NULL)
                ts_d = get_type_qual(dest_ty->decl_specs);
            else if (dest_ty->idl->child->op == TOK_STAR)
                ts_d = dest_ty->idl->child->attr.el;
            /* fetch qualifiers of right pointed to type */
            if (src_ty->idl->child == NULL)
                ts_s = get_type_qual(src_ty->decl_specs);
            else if (src_ty->idl->child->op == TOK_STAR)
                ts_s = src_ty->idl->child->attr.el;

            if (ts_s != NULL) {
                char *discarded;

                discarded = NULL;
                if (ts_s->op == TOK_CONST_VOLATILE) {
                    if (ts_d == NULL)
                        discarded = "const volatile";
                    else if (ts_d->op == TOK_CONST)
                        discarded = "volatile";
                    else if (ts_d->op == TOK_VOLATILE)
                        discarded = "const";
                } else if (ts_s->op == TOK_CONST) {
                    if (ts_d==NULL || ts_d->op==TOK_VOLATILE)
                        discarded = "const";
                } else if (ts_s->op == TOK_VOLATILE) {
                    if (ts_d==NULL || ts_d->op==TOK_CONST)
                        discarded = "volatile";
                }
                if (discarded != NULL)
                    WARNING(e, "assignment discards `%s' qualifier from pointer target type", discarded);
            }
        } else if (is_integer(cat_s)) {
            if (e->kind.exp!=IConstExp || e->attr.val!=0)
                WARNING(e, "integer to pointer conversion without a cast");
        } else {
            return FALSE;
        }
    }

    return TRUE;
}

void analyze_expression(ExecNode *e)
{
    IS_ERROR_BINARY(e, get_type_category(&e->child[0]->type), get_type_category(&e->child[1]->type));
    /*
     * 6.5.17
     * #2 The left operand of a comma operator is evaluated as a void expression; there is a
     * sequence point after its evaluation. Then the right operand is evaluated; the result has its
     * type and value.97) If an attempt is made to modify the result of a comma operator or to
     * access it after the next sequence point, the behavior is undefined.
     */
    e->type = e->child[1]->type;
}

void analyze_assignment_expression(ExecNode *e)
{
    IS_ERROR_BINARY(e, get_type_category(&e->child[0]->type), get_type_category(&e->child[1]->type));
    /*
     * 6.5.16
     * #2 An assignment operator shall have a modifiable lvalue as its left operand.
     */
    if (!is_modif_lvalue(e->child[0]))
        ERROR_R(e, "expression is not assignable");

    /*
     * #3 An assignment operator stores a value in the object designated by the left operand. An
     * assignment expression has the value of the left operand after the assignment, but is not an
     * lvalue. The type of an assignment expression is the type of the left operand unless the
     * left operand has qualified type, in which case it is the unqualified version of the type of
     * the left operand. The side effect of updating the stored value of the left operand shall
     * occur between the previous and the next sequence point.
     */
    if (e->attr.op == TOK_ASSIGN) {
        if (!can_assign_to(&e->child[0]->type, e->child[1])) {
            char *ty1, *ty2;

            ty1 = stringify_type_exp(&e->child[0]->type, FALSE);
            ty2 = stringify_type_exp(&e->child[1]->type, TRUE);
            ERROR(e, "incompatible types when assigning to type `%s' from type `%s'", ty1, ty2);
            free(ty1), free(ty2);

            return;
        }
    } else {
        /* E1 op= E2 ==> E1 = E1 op (E2) ; with E1 evaluated only once */
        ExecNode temp;

        temp = *e;
        switch (e->attr.op) {
        case TOK_MUL_ASSIGN:
            temp.attr.op = TOK_MUL;
            analyze_multiplicative_expression(&temp);
            break;
        case TOK_DIV_ASSIGN:
            temp.attr.op = TOK_DIV;
            analyze_multiplicative_expression(&temp);
            break;
        case TOK_REM_ASSIGN:
            temp.attr.op = TOK_REM;
            analyze_multiplicative_expression(&temp);
            break;
        case TOK_PLUS_ASSIGN:
            temp.attr.op = TOK_PLUS;
            analyze_additive_expression(&temp);
            break;
        case TOK_MINUS_ASSIGN:
            temp.attr.op = TOK_MINUS;
            analyze_additive_expression(&temp);
            break;
        case TOK_LSHIFT_ASSIGN:
            temp.attr.op = TOK_LSHIFT;
            analyze_bitwise_operator(&temp);
            break;
        case TOK_RSHIFT_ASSIGN:
            temp.attr.op = TOK_RSHIFT;
            analyze_bitwise_operator(&temp);
            break;
        case TOK_BW_AND_ASSIGN:
            temp.attr.op = TOK_BW_AND;
            analyze_bitwise_operator(&temp);
            break;
        case TOK_BW_XOR_ASSIGN:
            temp.attr.op = TOK_BW_XOR;
            analyze_bitwise_operator(&temp);
            break;
        case TOK_BW_OR_ASSIGN:
            temp.attr.op = TOK_BW_OR;
            analyze_bitwise_operator(&temp);
            break;
        }
        if (!can_assign_to(&e->child[0]->type, &temp)) {
            char *ty1, *ty2;

            ty1 = stringify_type_exp(&e->child[0]->type, FALSE);
            ty2 = stringify_type_exp(&temp.type, TRUE);
            ERROR(e, "incompatible types when assigning to type `%s' from type `%s'", ty1, ty2);
            free(ty1), free(ty2);

            return;
        }
        /*
         * Save inferred result type for later use.
         * child 2 and 3 are unused by this operator,
         * so the result can be stored there.
         */
        e->child[2] = (ExecNode *)temp.type.decl_specs;
        e->child[3] = (ExecNode *)temp.type.idl;
    }

    e->type = e->child[0]->type;
}

void analyze_conditional_expression(ExecNode *e)
{
    /*
     * 6.5.15
     *
     * #2 The first operand shall have scalar type.
     * #3 One of the following shall hold for the second and third operands:
     * - both operands have arithmetic type;
     * - both operands have the same structure or union type;
     * - both operands have void type;
     * - both operands are pointers to qualified or unqualified versions of compatible types;
     * - one operand is a pointer and the other is a null pointer constant; or
     * - one operand is a pointer to an object or incomplete type and the other is a pointer to
     * a qualified or unqualified version of void.
     */
    Token ty1, ty2, ty3;

    /*
     * Check that the first operand has scalar type.
     */
    ty1 = get_type_category(&e->child[0]->type);
    IS_ERROR_UNARY(e, ty1);

    if (!is_scalar(ty1) && ty1!=TOK_SUBSCRIPT && ty1!=TOK_FUNCTION)
        ERROR_R(e, "invalid first operand for conditional operator");

    /*
     * Check that the second and third operands can
     * be brought to a common type for the result.
     */
    ty2 = get_type_category(&e->child[1]->type);
    ty3 = get_type_category(&e->child[2]->type);
    IS_ERROR_BINARY(e, ty2, ty3);

    if (is_integer(ty2)) {
        if (is_integer(ty3)) {
            e->type.decl_specs = get_type_node(get_result_type(get_promoted_type(ty2), get_promoted_type(ty3)));
        } else if (is_pointer(ty3) || ty3==TOK_FUNCTION) {
            /*
             * Set the type of the pointer operand as the type of the result.
             */
            e->type = e->child[2]->type;
            /*
             * Emit a warning if the integer operand is not the null pointer constant
             */
            if (e->child[1]->kind.exp!=IConstExp || e->child[1]->attr.val!=0)
                WARNING(e, "pointer/integer type mismatch in conditional expression");
        } else {
            goto type_mismatch;
        }
    } else if (ty2==TOK_STRUCT || ty2==TOK_UNION) {
        TypeExp *ts2, *ts3;

        if (ty3 != ty2)
            goto type_mismatch;

        ts2 = get_type_spec(e->child[1]->type.decl_specs);
        ts3 = get_type_spec(e->child[2]->type.decl_specs);
        if (ts2->str != ts3->str)
            goto type_mismatch;
        e->type = e->child[1]->type;
    } else if (is_pointer(ty2) || ty2==TOK_FUNCTION) {
        if (is_integer(ty3)) {
            e->type = e->child[1]->type;
            if (e->child[2]->kind.exp!=IConstExp || e->child[2]->attr.val!=0)
                WARNING(e, "pointer/integer type mismatch in conditional expression");
        } else if (is_pointer(ty3) || ty3==TOK_FUNCTION) {
            /*
             * 6.5.15#6
             * If both the second and third operands are pointers or one is a null pointer constant and the
             * other is a pointer, the result type is a pointer to a type qualified with all the type qualifiers
             * of the types pointed-to by both operands. Furthermore, if both operands are pointers to
             * compatible types or to differently qualified versions of compatible types, the result type is
             * a pointer to an appropriately qualified version of the composite type; if one operand is a
             * null pointer constant, the result has the type of the other operand; otherwise, one operand
             * is a pointer to void or a qualified version of void, in which case the result type is a
             * pointer to an appropriately qualified version of void.
             */
            if (!are_compatible(e->child[1]->type.decl_specs, e->child[1]->type.idl->child,
            e->child[2]->type.decl_specs, e->child[2]->type.idl->child, FALSE, FALSE)) {
                /*
                 * The pointers do not point to compatible types.
                 */
                int iv, inv;
                TypeExp *tq1, *tq2;

                /*
                 * See if one of the operands is a pointer to void (the other
                 * operand cannot be a function pointer).
                 */
                if (is_void_ptr(ty2, e->child[1]->type)) {
                    /* the second operand is `void *' */
                    if (is_func_ptr(ty3, e->child[2]->type)) {
                        /* the third operand is a function pointer */
                        WARNING(e, "conditional expression between `void *' and function pointer");
                        /* set `void *' as the result type */
                        e->type = e->child[1]->type;
                        goto done;
                    } else {
                        iv = 1;  /* index of the void pointer operand */
                        inv = 2; /* index of the non-void pointer operand */
                    }
                } else if (is_void_ptr(ty3, e->child[2]->type)) {
                    /* the third operand is `void *' */
                    if (is_func_ptr(ty2, e->child[1]->type)) {
                        /* the second operand is a function pointer */
                        WARNING(e, "conditional expression between function pointer and `void *'");
                        e->type = e->child[2]->type;
                        goto done;
                    } else {
                        iv = 2;
                        inv = 1;
                    }
                } else {
                    WARNING(e, "pointer type mismatch in conditional expression");
                    /* set the type of the 2nd operand as the type of the result */
                    e->type = e->child[1]->type;
                    goto done;
                }
                /* fall through */

                /*
                 * One operand is a pointer to void or a qualified version of void and
                 * the other is a pointer to an object or incomplete type.
                 */
                if (e->child[inv]->type.idl->child == NULL
                || e->child[inv]->type.idl->child->op == TOK_STAR) {
                    /* the non-void pointer operand is a pointer to a non-derived-declarator-type
                       or a pointer to pointer */
                    tq1 = get_type_qual(e->child[iv]->type.decl_specs);
                    if (e->child[inv]->type.idl->child == NULL)
                        tq2 = get_type_qual(e->child[inv]->type.decl_specs);
                    else
                        tq2 = e->child[inv]->type.idl->child->attr.el;
                    if (tq1 == NULL) {
                        if (tq2 == NULL) {
                            e->type = e->child[iv]->type;
                        } else {
                            e->type.decl_specs = new_type_exp_node();
                            e->type.decl_specs->op = tq2->op;
                            e->type.decl_specs->child = e->child[iv]->type.decl_specs;
                            e->type.idl = e->child[iv]->type.idl;
                        }
                    } else if (tq2 == NULL) {
                        e->type = e->child[iv]->type;
                    } else {
                        if (tq1->op==tq2->op || tq1->op==TOK_CONST_VOLATILE) {
                            e->type = e->child[iv]->type;
                        } else {
                            e->type.decl_specs = dup_decl_specs(e->child[iv]->type.decl_specs);
                            get_type_qual(e->type.decl_specs)->op = TOK_CONST_VOLATILE;
                            e->type.idl = e->child[iv]->type.idl;
                        }
                    }
                } else /* if (e->child[2]->type.idl->child->op == TOK_SUBSCRIPT) */ {
                    /* the non-void pointer operand is a pointer to array */
                    e->type = e->child[iv]->type;
                }
            } else {
                /*
                 * Both operands are pointers to compatible types or to
                 * differently qualified versions of compatible types.
                 */
                TypeExp *tq1, *tq2;

                if (e->child[1]->type.idl->child == NULL) {
                    /* pointers to non-derived-declarator-types */
                    tq1 = get_type_qual(e->child[1]->type.decl_specs);
                    tq2 = get_type_qual(e->child[2]->type.decl_specs);
                    if (tq1 == NULL) {
                        e->type = e->child[2]->type;
                    } else if (tq2 == NULL) {
                        e->type = e->child[1]->type;
                    } else {
                        if (tq1->op==tq2->op || tq1->op==TOK_CONST_VOLATILE) {
                            e->type = e->child[1]->type;
                        } else if (tq2->op == TOK_CONST_VOLATILE) {
                            e->type = e->child[2]->type;
                        } else {
                            e->type.decl_specs = dup_decl_specs(e->child[1]->type.decl_specs);
                            get_type_qual(e->type.decl_specs)->op = TOK_CONST_VOLATILE;
                            e->type.idl = e->child[1]->type.idl;
                        }
                    }
                } else if (e->child[1]->type.idl->child->op == TOK_STAR) {
                    /* pointers to pointer */
                    tq1 = e->child[1]->type.idl->child->attr.el;
                    tq2 = e->child[2]->type.idl->child->attr.el;
                    if (tq1 == NULL) {
                        e->type = e->child[2]->type;
                    } else if (tq2 == NULL) {
                        e->type = e->child[1]->type;
                    } else {
                        if (tq1->op==tq2->op || tq1->op==TOK_CONST_VOLATILE) {
                            e->type = e->child[1]->type;
                        } else if (tq2->op == TOK_CONST_VOLATILE) {
                            e->type = e->child[2]->type;
                        } else {
                            e->type.idl = dup_declarator(e->child[1]->type.idl);
                            e->type.idl->child->attr.el = new_type_exp_node();
                            e->type.idl->child->attr.el->op = TOK_CONST_VOLATILE;
                            e->type.decl_specs = e->child[1]->type.decl_specs;
                        }
                    }
                } else {
                    /* pointers to arrays or functions */
                    e->type = e->child[1]->type;
                }
            }
        } else {
            goto type_mismatch;
        }
    } else if (ty2 == TOK_VOID) {
        if (ty3 != TOK_VOID)
            goto type_mismatch;
        e->type = e->child[1]->type;
    }

done:
    return;
type_mismatch: {
    char *ty1, *ty2;

    ty1 = stringify_type_exp(&e->child[1]->type, TRUE);
    ty2 = stringify_type_exp(&e->child[2]->type, TRUE);
    ERROR(e, "type mismatch in conditional expression (`%s' and `%s')", ty1, ty2);
    free(ty1), free(ty2);
    }
}

void analyze_logical_operator(ExecNode *e)
{
    Token ty1, ty2;

    /*
     * 6.5.13/14
     * #2 Each of the operands shall have scalar type.
     */
    ty1 = get_type_category(&e->child[0]->type);
    ty2 = get_type_category(&e->child[1]->type);
    IS_ERROR_BINARY(e, ty1, ty2);

    if (!is_scalar(ty1) && ty1!=TOK_SUBSCRIPT && ty1!=TOK_FUNCTION
    || !is_scalar(ty2) && ty2!=TOK_SUBSCRIPT && ty2!=TOK_FUNCTION) {
        binary_op_error(e);
        return;
    }

    /* the result has type int */
    e->type.decl_specs = get_type_node(TOK_INT);
}

void analyze_relational_equality_expression(ExecNode *e)
{
#define is_eq_op(op) ((op)==TOK_EQ||(op)==TOK_NEQ)
    /*
     * 6.5.8 Relational operators
     * #2 One of the following shall hold:
     * - both operands have real type;
     * - both operands are pointers to qualified or unqualified versions of compatible
     * object types; or
     * - both operands are pointers to qualified or unqualified versions of compatible
     * incomplete types.
     */

     /*
      * 6.5.9 Equality operators
      * One of the following shall hold:
      * - both operands have arithmetic type;
      * - both operands are pointers to qualified or unqualified versions of compatible types;
      * - one operand is a pointer to an object or incomplete type and the other is a pointer
      * to a qualified or unqualified version of void; or
      * - one operand is a pointer and the other is a null pointer constant.
      */
    Token ty1, ty2;

    ty1 = get_type_category(&e->child[0]->type);
    ty2 = get_type_category(&e->child[1]->type);
    IS_ERROR_BINARY(e, ty1, ty2);

    if (is_integer(ty1)) {
        if (is_integer(ty2)) {
            ; /* OK */
        } else if (is_pointer(ty2) || ty2==TOK_FUNCTION) {
            if (!is_eq_op(e->attr.op) || e->child[0]->kind.exp!=IConstExp || e->child[0]->attr.val!=0)
                WARNING(e, "comparison between pointer and integer");
        } else {
            binary_op_error(e);
            return;
        }
    } else if (is_pointer(ty1) || ty1==TOK_FUNCTION) {
        if (is_integer(ty2)) {
            if (!is_eq_op(e->attr.op) || e->child[1]->kind.exp!=IConstExp || e->child[1]->attr.val!=0)
                WARNING(e, "comparison between pointer and integer");
        } else if (is_pointer(ty2) || ty2==TOK_FUNCTION) {
            TypeExp *p1, *p2;

            /*
             * Check for the case where one of the operands
             * (or both) is `void *' (only for ==/!=)
             */
            if (is_eq_op(e->attr.op)) {
                if (ty1!=TOK_FUNCTION && e->child[0]->type.idl->child==NULL
                && get_type_spec(e->child[0]->type.decl_specs)->op==TOK_VOID) {
                    /* the left operand is a void pointer */

                    /* check for the special case of (void *)0 as left operand */
                    if (e->child[0]->kind.exp==OpExp
                    && e->child[0]->attr.op==TOK_CAST
                    && e->child[0]->child[0]->kind.exp==IConstExp
                    && e->child[0]->child[0]->attr.val==0)
                        goto done;

                    if (ty2==TOK_FUNCTION
                    || e->child[1]->type.idl->child!=NULL&&e->child[1]->type.idl->child->op==TOK_FUNCTION)
                        WARNING(e, "comparison of `void *' with function pointer");

                    goto done;
                } else if (ty2!=TOK_FUNCTION && e->child[1]->type.idl->child==NULL
                && get_type_spec(e->child[1]->type.decl_specs)->op==TOK_VOID) {
                    /* the right operand is a void pointer */

                    /* check for the special case of (void *)0 as right operand */
                    if (e->child[1]->kind.exp==OpExp
                    && e->child[1]->attr.op==TOK_CAST
                    && e->child[1]->child[0]->kind.exp==IConstExp
                    && e->child[1]->child[0]->attr.val==0)
                        goto done;

                    if (ty1==TOK_FUNCTION
                    || e->child[0]->type.idl->child!=NULL&&e->child[0]->type.idl->child->op==TOK_FUNCTION)
                        WARNING(e, "comparison of `void *' with function pointer");

                    goto done;
                }
            }

            p1 = (ty1!=TOK_FUNCTION)?e->child[0]->type.idl->child:e->child[0]->type.idl;
            p2 = (ty2!=TOK_FUNCTION)?e->child[1]->type.idl->child:e->child[1]->type.idl;

            if (!are_compatible(e->child[0]->type.decl_specs, p1, e->child[1]->type.decl_specs, p2, FALSE, FALSE))
                WARNING(e, "comparison of distinct pointer types");
            else if (!is_eq_op(e->attr.op) && p1!=NULL && p1->op==TOK_FUNCTION)
                WARNING(e, "comparison of function pointers");
        } else {
            binary_op_error(e);
            return;
        }
    } else {
        binary_op_error(e);
        return;
    }

done:
    /* the result has type int */
    e->type.decl_specs = get_type_node(TOK_INT);
}

void analyze_bitwise_operator(ExecNode *e)
{
    /*
     * These operators are required to have operands that have integer type.
     * The integer promotions are performed on each of the operands.
     */
    Token ty1, ty2;

    ty1 = get_type_category(&e->child[0]->type);
    ty2 = get_type_category(&e->child[1]->type);
    IS_ERROR_BINARY(e, ty1, ty2);

    if (!is_integer(ty1) || !is_integer(ty2)) {
        binary_op_error(e);
        return;
    }

    if (e->attr.op==TOK_LSHIFT || e->attr.op==TOK_RSHIFT)
        /*
         * The usual arithmetic conversions do not apply to <</>>.
         * The type of the result is that of the promoted left operand.
         */
        e->type.decl_specs = get_type_node(get_promoted_type(ty1));
    else
        e->type.decl_specs = get_type_node(get_result_type(get_promoted_type(ty1), get_promoted_type(ty2)));
}

void analyze_additive_expression(ExecNode *e)
{
    Token ty_l, ty_r;

    ty_l = get_type_category(&e->child[0]->type);
    ty_r = get_type_category(&e->child[1]->type);
    IS_ERROR_BINARY(e, ty_l, ty_r);

    /*
     * 6.5.6
     * #8 When an expression that has integer type is added to or subtracted from a pointer,
     * the result has the type of the pointer operand.
     */

    if (e->attr.op == TOK_PLUS) {
        /*
         * 6.5.6
         * #2 For addition, either both operands shall have arithmetic type, or one operand shall
         * be a pointer to an object type and the other shall have integer type. (Incrementing is
         * equivalent to adding 1.)
         */
        if (is_integer(ty_l)) {
            if (is_integer(ty_r)) {
                /* integer + integer */
                e->type.decl_specs = get_type_node(get_result_type(get_promoted_type(ty_l), get_promoted_type(ty_r)));
            } else if (is_pointer(ty_r)) {
                /* integer + pointer */
                if (!is_ptr2obj(&e->child[1]->type)) {
                    binary_op_error(e);
                    return;
                }
                e->type = e->child[1]->type;
            } else {
                binary_op_error(e);
                return;
            }
        } else if (is_pointer(ty_l)) {
            if (!is_integer(ty_r) || !is_ptr2obj(&e->child[0]->type)) {
                binary_op_error(e);
                return;
            }
            /* pointer + integer */
            e->type = e->child[0]->type;
        } else {
            binary_op_error(e);
            return;
        }
    } else {
        /*
         * 6.5.6
         * #3 For subtraction, one of the following shall hold:
         * - both operands have arithmetic type;
         * - both operands are pointers to qualified or unqualified versions of compatible object
         * types; or
         * - the left operand is a pointer to an object type and the right operand has integer type.
         * (Decrementing is equivalent to subtracting 1.)
         */
        if (is_integer(ty_l)) {
            if (is_integer(ty_r)) {
                /* integer - integer */
                e->type.decl_specs = get_type_node(get_result_type(get_promoted_type(ty_l), get_promoted_type(ty_r)));
            } else {
                binary_op_error(e);
                return;
            }
        } else if (is_pointer(ty_l)) {
            if (is_integer(ty_r)) {
                /* pointer - integer */
                if (!is_ptr2obj(&e->child[0]->type)) {
                    binary_op_error(e);
                    return;
                }
                e->type = e->child[0]->type;
            } else if (is_pointer(ty_r)) {
                /* pointer - pointer */
                if (!is_ptr2obj(&e->child[0]->type) || !is_ptr2obj(&e->child[1]->type)
                || !are_compatible(e->child[0]->type.decl_specs, e->child[0]->type.idl->child,
                e->child[1]->type.decl_specs, e->child[1]->type.idl->child, FALSE, FALSE)) {
                    binary_op_error(e);
                    return;
                }
                e->type.decl_specs = get_type_node(TOK_LONG); /* ptrdiff_t */
            } else {
                binary_op_error(e);
                return;
            }
        } else {
            binary_op_error(e);
            return;
        }
    }
}

void analyze_multiplicative_expression(ExecNode *e)
{
    Token ty1, ty2;

    /*
     * 6.5.5
     * #2 Each of the operands shall have arithmetic type. The operands of the % operator
     * shall have integer type.
     */
    ty1 = get_type_category(&e->child[0]->type);
    ty2 = get_type_category(&e->child[1]->type);
    IS_ERROR_BINARY(e, ty1, ty2);

    if (!is_integer(ty1) || !is_integer(ty2)) {
        binary_op_error(e);
        return;
    }

    e->type.decl_specs = get_type_node(get_result_type(get_promoted_type(ty1), get_promoted_type(ty2)));
}

void analyze_cast_expression(ExecNode *e)
{
    Token ty_src, ty_tgt;

    /*
     * 6.5.4
     * #2 Unless the type name specifies a void type, the type name shall specify
     * qualified or unqualified scalar type and the operand shall have scalar type.
     */
    /* source type */
    ty_src = get_type_category(&e->child[0]->type);
    IS_ERROR_UNARY(e, ty_src);

    if (!is_scalar(ty_src) && ty_src!=TOK_SUBSCRIPT
    && ty_src!=TOK_FUNCTION && ty_src!=TOK_VOID)
        ERROR_R(e, "cast operand does not have scalar type");

    /* target type */
    ty_tgt = get_type_category((Declaration *)e->child[1]);
    IS_ERROR_UNARY(e, ty_tgt);

    if (!is_scalar(ty_tgt) && ty_tgt!=TOK_VOID)
        ERROR_R(e, "cast specifies conversion to non-scalar type");

    /* check for void ==> non-void */
    if (ty_src==TOK_VOID && ty_tgt!=TOK_VOID)
        ERROR_R(e, "invalid cast of void expression to non-void type");

    e->type = *(Declaration *)e->child[1];
}

static void analyze_inc_dec_operator(ExecNode *e)
{
    /*
     * 6.5.2.4#1/6.5.3.1#1
     * The operand of the postfix/prefix increment or decrement operator shall have
     * qualified or unqualified real or pointer type and shall be a modifiable lvalue.
     */
    Token ty;

    ty = get_type_category(&e->child[0]->type);
    IS_ERROR_UNARY(e, ty);

    if (!is_integer(ty) && !is_pointer(ty))
        ERROR_R(e, "wrong type argument to %s",
        (e->attr.op==TOK_POS_INC||e->attr.op==TOK_PRE_INC)?"increment":"decrement");
    if (!is_modif_lvalue(e->child[0]))
        ERROR_R(e, "expression is not modifiable");

    e->type = e->child[0]->type;
}

void analyze_unary_expression(ExecNode *e)
{
    switch (e->attr.op) {
    case TOK_PRE_INC:
    case TOK_PRE_DEC:
        analyze_inc_dec_operator(e);
        break;
    case TOK_ALIGNOF:
    case TOK_SIZEOF: {
        char *op;
        Token cat;
        Declaration ty;

        /*
         * 6.5.3.4
         * #1 The sizeof operator shall not be applied to an expression that has function type
         * or an incomplete type, to the parenthesized name of such a type, or to an expression
         * that designates a bit-field member.
         */
        if (e->child[1] != NULL) {
            /* "sizeof" "(" type_name ")" */
            ty.decl_specs = ((Declaration *)e->child[1])->decl_specs;
            ty.idl = ((Declaration *)e->child[1])->idl;
        } else {
            /* "sizeof" unary_expression */
            ty.decl_specs = e->child[0]->type.decl_specs;
            ty.idl = e->child[0]->type.idl;
        }
        cat = get_type_category(&ty);
        IS_ERROR_UNARY(e, cat);

        op = (e->attr.op == TOK_SIZEOF)?"sizeof":"__alignof__";
        if (cat == TOK_FUNCTION)
            ERROR_R(e, "invalid application of `%s' to a function type", op);
        else if (cat==TOK_SUBSCRIPT && ty.idl->attr.e==NULL
        || is_struct_union_enum(cat) && !is_complete(get_type_spec(ty.decl_specs)->str))
            ERROR_R(e, "invalid application of `%s' to incomplete type", op);

        /*
         * #2 The sizeof operator yields the size (in bytes) of its operand, which may be an
         * expression or the parenthesized name of a type. The size is determined from the type of
         * the operand. The result is an integer. If the type of the operand is a variable length array
         * type, the operand is evaluated; otherwise, the operand is not evaluated and the result is an
         * integer constant.
         * #3 When applied to an operand that has type char, unsigned char, or signed char,
         * (or a qualified version thereof) the result is 1. When applied to an operand that has array
         * type, the result is the total number of bytes in the array. When applied to an operand
         * that has structure or union type, the result is the total number of bytes in such an object,
         * including internal and trailing padding.
         */
        /* convert node to integer constant */
        e->kind.exp = IConstExp;
        e->type.decl_specs = get_type_node(TOK_UNSIGNED_LONG);
        e->attr.uval = (e->attr.op == TOK_SIZEOF)?get_sizeof(&ty):get_alignment(&ty);
        break;
    }
    case TOK_ADDRESS_OF: {
        Token ty;
        TypeExp *temp;

        /*
         * 6.5.3.2
         * 1# The operand of the unary & operator shall be either a function designator, the result of a
         * [] or unary * operator, or an lvalue that designates an object that is not a bit-field and is
         * not declared with the register storage-class specifier.
         */
        ty = get_type_category(&e->child[0]->type);
        IS_ERROR_UNARY(e, ty);

        if (!is_lvalue(e->child[0]) && ty!=TOK_FUNCTION)
            ERROR_R(e, "invalid operand to &");
        if ((temp=get_sto_class_spec(e->child[0]->type.decl_specs))!=NULL && temp->op==TOK_REGISTER)
            ERROR_R(e, "address of register variable requested");

        /*
         * 6.5.3.2
         * #3 The unary & operator yields the address of its operand. If the operand has type ‘‘type’’,
         * the result has type ‘‘pointer to type’’.
         */
        temp = new_type_exp_node();
        temp->op = TOK_STAR;
        temp->child = e->child[0]->type.idl;

        /* set the type of the & node */
        e->type.decl_specs = e->child[0]->type.decl_specs;
        e->type.idl = temp;
        break;
    }
    case TOK_INDIRECTION: {
        Token ty;

        /*
         * 6.5.3.2
         * #2 The operand of the unary * operator shall have pointer type.
         */
        ty = get_type_category(&e->child[0]->type);
        IS_ERROR_UNARY(e, ty);

        if (!is_pointer(ty) && ty!=TOK_FUNCTION)
            ERROR_R(e, "invalid operand to *");

        /* make sure that the pointer does not point to an incomplete struct/union/enum */
        if (ty != TOK_FUNCTION) {
            TypeExp *ts;

            ts = get_type_spec(e->child[0]->type.decl_specs);
            if (is_struct_union_enum(ts->op) && !is_complete(ts->str))
                ERROR_R(e, "dereferencing pointer to incomplete type");
        }

        /*
         * 6.5.3.2
         * #4 The unary * operator denotes indirection. If the operand points to a function, the result
         * is a function designator; if it points to an object, the result is an lvalue designating the
         * object. If the operand has type ‘‘pointer to type’’, the result has type ‘‘type’’. If an
         * invalid value has been assigned to the pointer, the behavior of the unary * operator is
         * undefined.
         */
        e->type.decl_specs = e->child[0]->type.decl_specs;
        e->type.idl = (ty!=TOK_FUNCTION)?e->child[0]->type.idl->child:e->child[0]->type.idl;
        break;
    }
    case TOK_UNARY_PLUS:
    case TOK_UNARY_MINUS:
    case TOK_COMPLEMENT: {
        Token ty;

        /*
         * 6.5.3.3
         * #1 The operand of the unary + or - operator shall have arithmetic type;
         * of the ~ operator, integer type.
         */
        ty = get_type_category(&e->child[0]->type);
        IS_ERROR_UNARY(e, ty);

        if (!is_integer(ty))
            ERROR_R(e, "invalid operand to %s", tok2lex(e->attr.op));

        e->type.decl_specs = get_type_node(get_promoted_type(ty));
        break;
    }
    case TOK_NEGATION: {
        Token ty;

        /*
         * 6.5.3.3
         * #1 The operand of the unary ! operator shall have scalar type.
         */
        ty = get_type_category(&e->child[0]->type);
        IS_ERROR_UNARY(e, ty);

        if (!is_scalar(ty) && ty!=TOK_FUNCTION && ty!=TOK_SUBSCRIPT)
            ERROR_R(e, "invalid operand to !");

        /* the result has type int */
        e->type.decl_specs = get_type_node(TOK_INT);
        break;
    }
    }
}

void analyze_postfix_expression(ExecNode *e)
{
    switch (e->attr.op) {
    case TOK_SUBSCRIPT: {
        /*
         * 6.5.2.1#1
         * One of the expressions shall have type ‘‘pointer to object type’’, the other
         * expression shall have integer type, and the result has type ‘‘type’’.
         */
        int ch_idx; /* index of the pointer child */
        Token ty1, ty2;
        TypeExp *ptr_operand;

        ty1 = get_type_category(&e->child[0]->type);
        IS_ERROR_UNARY(e, ty1);
        ty2 = get_type_category(&e->child[1]->type);
        IS_ERROR_UNARY(e, ty2);

        if (is_pointer(ty1)) {
            if (!is_integer(ty2))
                goto non_int_sub;
            ptr_operand = e->child[0]->type.idl;
            ch_idx = 0;
        } else if (is_pointer(ty2)) {
            if (!is_integer(ty1))
                goto non_int_sub;
            ptr_operand = e->child[1]->type.idl;
            ch_idx = 1;
        } else {
            ERROR_R(e, "subscripted value is neither array nor pointer");
        }

        /*
         * Check that the pointer points to an object
         * type (and not to a function or incomplete type).
         */
        if (ptr_operand->child == NULL) {
            /* the pointed to type is not a derived declarator type */
            TypeExp *ts;

            ts = get_type_spec(e->child[ch_idx]->type.decl_specs);
            if (is_struct_union_enum(ts->op) && !is_complete(ts->str))
                goto subs_incomp;
        } else if (ptr_operand->child->op==TOK_SUBSCRIPT && ptr_operand->child->attr.e==NULL) {
            goto subs_incomp;
        } else if (ptr_operand->child->op == TOK_FUNCTION) {
            ERROR_R(e, "subscripting pointer to function");
        }

        /* set the element type as the type of the [] node */
        e->type.decl_specs = e->child[ch_idx]->type.decl_specs;
        e->type.idl = e->child[ch_idx]->type.idl->child;
        break;
non_int_sub:
        ERROR_R(e, "array subscript is not an integer");
subs_incomp:
        ERROR_R(e, "subscripting pointer to incomplete type");
    }
    case TOK_FUNCTION: {
        /*
         * 6.5.2.2
         * #1 The expression that denotes the called function shall have type pointer to function
         * returning void or returning an object type other than an array type.
         */
        /*
         * 6.5.2.2
         * #5 If the expression that denotes the called function has type pointer to function returning an
         * object type, the function call expression has the same type as that object type, and has the
         * value determined as specified in 6.8.6.4. Otherwise, the function call has type void. [...]
         * 6.7.2.3#footnote (about incomplete types)
         * [...] The specification has to be complete before such a function is called or defined.
         */
        int n;
        DeclList *p;
        ExecNode *a;
        TypeExp *ty;

        IS_ERROR_UNARY(e, get_type_category(&e->child[0]->type));

        ty = e->child[0]->type.idl;

        if (ty == NULL)
            goto non_callable;
        else if (ty->op == TOK_FUNCTION)
            ;
        else if (ty->op==TOK_STAR && ty->child!=NULL && ty->child->op==TOK_FUNCTION)
            ty = ty->child;
        else
            goto non_callable;
        /*
         * Functions cannot be declared as returning an array or function, so what remains
         * to check is that the return type is not an incomplete enum/struct/union type.
         */
        if (ty->child == NULL) {
            /* the return type is not a derived declarator type */
            TypeExp *ts;

            ts = get_type_spec(e->child[0]->type.decl_specs);
            if (is_struct_union_enum(ts->op) && !is_complete(ts->str))
                ERROR_R(e, "calling function with incomplete return type `%s %s'", tok2lex(ts->op), ts->str);
        }

        /*
         * 6.5.2.2
         * #2 If the expression that denotes the called function has a type that includes a prototype, the
         * number of arguments shall agree with the number of parameters. Each argument shall
         * have a type such that its value may be assigned to an object with the unqualified version
         * of the type of its corresponding parameter.
         *
         * #7 If the expression that denotes the called function has a type that does include a prototype,
         * the arguments are implicitly converted, as if by assignment, to the types of the
         * corresponding parameters, taking the type of each parameter to be the unqualified version
         * of its declared type. The ellipsis notation in a function prototype declarator causes
         * argument type conversion to stop after the last declared parameter. The default argument
         * promotions are performed on trailing arguments.
         */
        n = 1;
        p = ty->attr.dl;
        if (get_type_spec(p->decl->decl_specs)->op==TOK_VOID && p->decl->idl==NULL)
            p = NULL;
        e->locals = p; /* for later ease of access to the formal parameters */
        a = e->child[1];
        while (p!=NULL && a!=NULL) {
            Declaration p_ty;

            IS_ERROR_UNARY(e, get_type_category(&a->type));

            if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
                break;
            p_ty.decl_specs = p->decl->decl_specs;
            /* handle parameters with and without an identifier */
            p_ty.idl = (p->decl->idl!=NULL&&p->decl->idl->op==TOK_ID)?p->decl->idl->child:p->decl->idl;
            if (!can_assign_to(&p_ty, a)) {
                char *ty1, *ty2;

                ty1 = stringify_type_exp(&p_ty, TRUE);
                ty2 = stringify_type_exp(&a->type, TRUE);
                // ERROR(e, "parameter/argument type mismatch (parameter #%d; expected `%s', given `%s')", n, ty1, ty2);
                emit_error(FALSE, a->info->src_file, a->info->src_line, a->info->src_column,
                "parameter/argument type mismatch (parameter #%d; expected `%s', given `%s')",
                n, ty1, ty2);
                free(ty1), free(ty2);
                // return;
            }

            ++n;
            p = p->next;
            a = a->sibling;
        }
        if (a!=NULL || p!=NULL) {
            if (p!=NULL && p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
                ; /* OK */
            else
                ERROR_R(e, "parameter/argument number mismatch");
        }

        /* set the return type of the function as the type of the () node */
        e->type.decl_specs = e->child[0]->type.decl_specs;
        e->type.idl = ty->child;
        break;
non_callable:
        ERROR_R(e, "called object is not a function");
    }
    case TOK_DOT:
    case TOK_ARROW: {
        char *id;
        DeclList *d;
        TypeExp *ts, *tq_l, *tq_r, *dct;

        IS_ERROR_UNARY(e, get_type_category(&e->child[0]->type));

        /*
         * 6.5.2.3
         * #1 The first operand of the . operator shall have a qualified or unqualified structure
         * or union type, and the second operand shall name a member of that type.
         *
         * #2 The first operand of the -> operator shall have type ‘‘pointer to qualified or unqualified
         * structure’’ or ‘‘pointer to qualified or unqualified union’’, and the second operand shall
         * name a member of the type pointed to.
         */
        ts = get_type_spec(e->child[0]->type.decl_specs);

        if (ts->op!=TOK_STRUCT && ts->op!=TOK_UNION)
            ERROR_R(e, "left operand of %s has neither structure nor union type", tok2lex(e->attr.op));
        if (e->attr.op == TOK_DOT) {
            if (e->child[0]->type.idl != NULL)
                ERROR_R(e, "invalid operand to .");
        } else {
            if (e->child[0]->type.idl==NULL || !is_pointer(e->child[0]->type.idl->op))
                ERROR_R(e, "invalid operand to ->");
        }

        /* fetch the name of the requested member */
        id = e->child[1]->attr.str;

        if (ts->attr.dl == NULL) {
            TypeTag *np;

            if ((np=lookup_tag(ts->str, TRUE))->type->attr.dl == NULL)
                ERROR_R(e, "left operand of %s has incomplete type", tok2lex(e->attr.op));
            // ts = np->type;
            ts->attr.dl = np->type->attr.dl;
        }

        /* search for the member */
        for (d = ts->attr.dl; d != NULL; d = d->next) {
            for (dct = d->decl->idl; dct != NULL; dct = dct->sibling) {
                if (equal(id, dct->str))
                    goto mem_found;
            }
        }
        ERROR_R(e, "`%s %s' has no member named `%s'", tok2lex(ts->op), ts->str, id);
mem_found:
        /*
         * 6.5.2.3
         * #3 A postfix expression followed by the . operator and an identifier designates a member of
         * a structure or union object. The value is that of the named member, and is an lvalue if
         * the first expression is an lvalue. If the first expression has qualified type, the result has
         * the so-qualified version of the type of the designated member.
         *
         * #4 A postfix expression followed by the -> operator and an identifier designates a member
         * of a structure or union object. The value is that of the named member of the object to
         * which the first expression points, and is an lvalue. If the first expression is a pointer to
         * a qualified type, the result has the so-qualified version of the type of the designated
         * member.
         */
        if ((tq_l=get_type_qual(e->child[0]->type.decl_specs)) != NULL) {
            /*
             * The first expression has qualified type.
             */
            if (dct->child != NULL) {
                /* derived declarator type (struct members cannot
                   have function type, so ignore that case) */
                if (dct->child->op == TOK_STAR) {
                    TypeExp *new_ptr_node;

                    // new_ptr_node = calloc(1, sizeof(TypeExp));
                    new_ptr_node = new_type_exp_node();
                    *new_ptr_node = *dct->child;

                    if (dct->child->attr.el == NULL) {
                        /* non-qualified pointer */
                        new_ptr_node->attr.el = tq_l;
                    } else if (dct->child->attr.el->op!=tq_l->op
                    && dct->child->attr.el->op!=TOK_CONST_VOLATILE) {
                        /* qualified pointer (by const or volatile, but not both) */
                        new_ptr_node->attr.el = new_type_exp_node();
                        new_ptr_node->attr.el->op = TOK_CONST_VOLATILE;
                    } /*else {
                        free(new_ptr_node);
                        new_ptr_node = dct->child;
                    }*/
                    e->type.idl = new_ptr_node;
                } else if (dct->child->op == TOK_SUBSCRIPT) {
                    int n;
                    TypeExp *p;

                    /* search the element type */
                    for (p=dct->child, n=0; p!=NULL && p->op==TOK_SUBSCRIPT; p=p->child, n++);
                    if (p != NULL) {
                        /* array of pointers, qualify the pointer element type */
                        TypeExp *new_dct_list;

                        new_dct_list = dup_declarator(dct->child);

                        if (p->attr.el == NULL) {
                            /* non-qualified pointer */
                            for (p = new_dct_list; n != 0; p=p->child, --n);
                            p->attr.el = tq_l;
                        } else if (p->attr.el->op!=tq_l->op && p->attr.el->op!=TOK_CONST_VOLATILE) {
                            /* qualified pointer (by const or volatile, but not both) */
                            for (p = new_dct_list; n != 0; p=p->child, --n);
                            p->attr.el = new_type_exp_node();
                            p->attr.el->op = TOK_CONST_VOLATILE;
                        } /*else {
                        }*/
                        e->type.idl = new_dct_list;
                    } else {
                        /* array of non-derived declarator types, just add a new
                           qualifier (if required) to the declaration specifiers list */
                        goto decl_specs_qualif;
                    }
                }
                e->type.decl_specs = d->decl->decl_specs;
            } else {
decl_specs_qualif:
                if ((tq_r=get_type_qual(d->decl->decl_specs)) != NULL) {
                    /* the member is already qualified */
                    if (tq_r->op!=tq_l->op && tq_r->op!=TOK_CONST_VOLATILE) {
                        tq_r = new_type_exp_node();
                        tq_r->op = TOK_CONST_VOLATILE;
                        tq_r->child = new_type_exp_node();
                        *tq_r->child = *get_type_spec(d->decl->decl_specs);
                        tq_r->child->child = NULL;
                    }
                } else {
                    /* there is not type qualifier between
                       the member's declaration specifiers */
                    tq_r = new_type_exp_node();
                    tq_r->op = tq_l->op;
                    tq_r->child = d->decl->decl_specs;
                }
                e->type.decl_specs = tq_r;
                e->type.idl = dct->child;
            }
        } else {
            /*
             * The first expression has unqualified type.
             */
            e->type.decl_specs = d->decl->decl_specs;
            e->type.idl = dct->child;
        }
        break;
    }
    case TOK_POS_INC:
    case TOK_POS_DEC:
        analyze_inc_dec_operator(e);
        break;
    }
}

static void analyze_iconst(ExecNode *e)
{
    Token ty, kind;
    char *ep, *ic;
    long long val;

    kind = (Token)e->child[0];
    ic = e->attr.str;
    switch (kind) {
    case TOK_ICONST_D:
    case TOK_ICONST_DL:
    case TOK_ICONST_DLL:
        errno = 0;
        val = strtoll(ic, &ep, 10);
        if (errno == ERANGE) {
            ty = TOK_LONG_LONG;
            break;
        }
        if (val <= INT_MAX)
            ty = (kind == TOK_ICONST_D)  ? TOK_INT
               : (kind == TOK_ICONST_DL) ? TOK_LONG : TOK_LONG_LONG;
        else if (targeting_arch64)
            ty = TOK_LONG;
        else
            ty = TOK_LONG_LONG;
        break;

    case TOK_ICONST_DU:
    case TOK_ICONST_DUL:
    case TOK_ICONST_DULL:
        errno = 0;
        val = (long long)strtoull(ic, &ep, 10);
        if (errno == ERANGE) {
            ty = TOK_UNSIGNED_LONG_LONG;
            break;
        }
        if ((unsigned long long)val <= UINT_MAX)
            ty = (kind == TOK_ICONST_DU)  ? TOK_UNSIGNED
               : (kind == TOK_ICONST_DUL) ? TOK_UNSIGNED_LONG : TOK_UNSIGNED_LONG_LONG;
        else if (targeting_arch64)
            ty = TOK_UNSIGNED_LONG;
        else
            ty = TOK_UNSIGNED_LONG_LONG;
        break;

    case TOK_ICONST_OH:
    case TOK_ICONST_OHL:
    case TOK_ICONST_OHLL:
        errno = 0;
        val = strtoll(ic, &ep, 0);
        if (errno == ERANGE) {
            ; /* fall-through */
        } else {
            if (val <= INT_MAX)
                ty = (kind == TOK_ICONST_OH)  ? TOK_INT
                   : (kind == TOK_ICONST_OHL) ? TOK_LONG : TOK_LONG_LONG;
            else if ((unsigned long long)val <= UINT_MAX)
                ty = (kind == TOK_ICONST_OH)  ? TOK_UNSIGNED
                   : (kind == TOK_ICONST_OHL) ? TOK_UNSIGNED_LONG : TOK_UNSIGNED_LONG_LONG;
            else if (targeting_arch64)
                ty = TOK_LONG;
            else
                ty = TOK_LONG_LONG;
            break;
        }

    case TOK_ICONST_OHU:
    case TOK_ICONST_OHUL:
    case TOK_ICONST_OHULL:
        errno = 0;
        val = (long long)strtoull(ic, &ep, 0);
        if (errno == ERANGE) {
            ty = TOK_UNSIGNED_LONG_LONG;
            break;
        } else {
            if ((unsigned long long)val <= UINT_MAX)
                ty = (kind == TOK_ICONST_OHU)  ? TOK_UNSIGNED
                   : (kind == TOK_ICONST_OHUL) ? TOK_UNSIGNED_LONG : TOK_UNSIGNED_LONG_LONG;
            else if (targeting_arch64)
                ty = TOK_UNSIGNED_LONG;
            else
                ty = TOK_UNSIGNED_LONG_LONG;
        }
        break;
    }
    if (errno == ERANGE)
        WARNING(e, "integer constant is too large for its type");
    e->attr.val = val;
    e->type.decl_specs = get_type_node(ty);
}

void analyze_primary_expression(ExecNode *e)
{
    switch (e->kind.exp) {
    case IdExp:
        /* convert the enumeration constant into a simple integer constant */
        if (e->type.idl!=NULL && e->type.idl->op==TOK_ENUM_CONST) {
            e->kind.exp = IConstExp;
            e->attr.val = e->type.idl->attr.e->attr.val;
            e->type.idl = NULL;
        }
        break;
    case IConstExp:
        analyze_iconst(e);
        break;
    case StrLitExp:
        e->type.decl_specs = get_type_node(TOK_CHAR);
        e->type.idl = new_type_exp_node();
        e->type.idl->op = TOK_SUBSCRIPT;
        e->type.idl->attr.e = new_exec_node();
        e->type.idl->attr.e->attr.val = strlen(e->attr.str)+1;
        break;
    }
}

unsigned get_alignment(Declaration *ty)
{
    Token cat;
    unsigned alignment;
    Declaration new_ty;

    cat = get_type_category(ty);
    switch (cat) {
    case TOK_STRUCT:
    case TOK_UNION:
        alignment = lookup_struct_descriptor(get_type_spec(ty->decl_specs)->str)->alignment;
        break;
    case TOK_SUBSCRIPT:
        new_ty.decl_specs = ty->decl_specs;
        new_ty.idl = ty->idl->child;
        alignment = get_alignment(&new_ty);
        break;
    case TOK_LONG_LONG: case TOK_UNSIGNED_LONG_LONG:
        switch (target_arch) {
        case ARCH_X64:
        case ARCH_VM64:
        case ARCH_MIPS:
        case ARCH_ARM:
            alignment = 8;
            break;
        default:
            alignment = 4;
            break;
        }
        break;
    case TOK_STAR:
    case TOK_LONG: case TOK_UNSIGNED_LONG:
        alignment = targeting_arch64 ? 8 : 4;
        break;
    case TOK_ENUM:
    case TOK_INT: case TOK_UNSIGNED:
        alignment = 4;
        break;
    case TOK_SHORT: case TOK_UNSIGNED_SHORT:
        alignment = 2;
        break;
    case TOK_CHAR: case TOK_SIGNED_CHAR: case TOK_UNSIGNED_CHAR:
        alignment = 1;
        break;
    default:
        assert(0);
    }

    return alignment;
}

unsigned get_sizeof(Declaration *ty)
{
    Token cat;
    unsigned size;
    Declaration new_ty;

    size = 0;

    cat = get_type_category(ty);
    switch (cat) {
    case TOK_UNION: {
        StructMember *sm;
        StructDescriptor *sd;

        sd = lookup_struct_descriptor(get_type_spec(ty->decl_specs)->str);
        for (sm = sd->members; sm != NULL; sm = sm->next)
            if (sm->size > size)
                size = sm->size;
        size = round_up(size, sd->alignment);
        break;
    }
    case TOK_STRUCT:
        size = lookup_struct_descriptor(get_type_spec(ty->decl_specs)->str)->size;
        break;
    case TOK_SUBSCRIPT:
        new_ty.decl_specs = ty->decl_specs;
        new_ty.idl = ty->idl->child;
        size = ty->idl->attr.e->attr.val*get_sizeof(&new_ty);
        break;
    case TOK_LONG_LONG: case TOK_UNSIGNED_LONG_LONG:
        size = 8;
        break;
    case TOK_STAR:
    case TOK_LONG: case TOK_UNSIGNED_LONG:
        size = targeting_arch64 ? 8 : 4;
        break;
    case TOK_ENUM:
    case TOK_INT: case TOK_UNSIGNED:
        size = 4;
        break;
    case TOK_SHORT: case TOK_UNSIGNED_SHORT:
        size = 2;
        break;
    case TOK_CHAR: case TOK_SIGNED_CHAR: case TOK_UNSIGNED_CHAR:
        size = 1;
        break;
    case TOK_VOID:
    case TOK_ERROR:
        size = 0;
        break;
    }

    return size;
}

/*
 * Try to evaluate e as a constant expression.
 * is_addr indicates if e is &'s operand.
 * is_iconst indicates if e must be an integer constant expression.
 *
 * A few notes:
 *  - Addresses always evaluate to true.
 *  - Addresses plus/minus an integer constant have unknown value.
 *  - Any attempt to use an unknown value is an error.
 *    e.g.   int a[5];
 *           int b = a+1 && 1; // error! assign 1 or 0?
 *    on the other hand, the following is OK
 *           int b = a+1 && 0; // always 0
 */
long long eval_const_expr(ExecNode *e, int is_addr, int is_iconst)
{
    long long resL, resR;

    switch (e->kind.exp) {
    case OpExp:
#define KIND(n)  (n->kind.exp)
#define VALUE(n) (n->attr.val)
        switch (e->attr.op) {
        case TOK_SUBSCRIPT: {
            int pi, ii;
            long long indx, ptr;

            if (is_iconst)
                break;
            if (is_integer(get_type_category(&e->child[0]->type)))
                pi = 1, ii = 0;
            else
                pi = 0, ii = 1;
            indx = eval_const_expr(e->child[ii], FALSE, is_iconst);
            if (KIND(e->child[ii]) != IConstExp)
                break;
            ptr  = eval_const_expr(e->child[pi], is_addr, is_iconst);
            if (KIND(e->child[pi]) == IConstExp) {
                Declaration ty;

                KIND(e) = IConstExp;
                ty = e->child[pi]->type;
                ty.idl = ty.idl->child;
                return (VALUE(e) = ptr+indx*get_sizeof(&ty));
            } else {
                return ptr;
            }
        }
        case TOK_DOT:
        case TOK_ARROW:
            if (is_iconst)
                break;
            resL = eval_const_expr(e->child[0], is_addr, is_iconst);
            if (KIND(e->child[0]) == IConstExp) {
                KIND(e) = IConstExp;
                if (get_type_category(&e->child[0]->type) != TOK_UNION) {
                    StructMember *m;

                    m = get_member_descriptor(get_type_spec(e->child[0]->type.decl_specs), e->child[1]->attr.str);
                    return (VALUE(e) = resL+m->offset);
                } else {
                    return (VALUE(e) = resL);
                }
            } else {
                return resL;
            }
        case TOK_SIZEOF:
            if (e->child[1] != NULL)
                resL = (long)get_sizeof((Declaration *)e->child[1]);
            else
                resL = (long)get_sizeof(&e->child[0]->type);
            KIND(e) = IConstExp;
            return (VALUE(e) = resL);
        case TOK_ADDRESS_OF:
            if (is_iconst)
                break;
            resL = eval_const_expr(e->child[0], TRUE, is_iconst);
            if (KIND(e->child[0]) == IConstExp) {
                KIND(e) = IConstExp;
                return (VALUE(e) = resL);
            } else {
                return resL;
            }
        case TOK_INDIRECTION:
            if (is_iconst)
                break;
            resL = eval_const_expr(e->child[0], is_addr, is_iconst);
            if (KIND(e->child[0]) == IConstExp) {
                KIND(e) = IConstExp;
                return (VALUE(e) = resL);
            } else {
                return resL;
            }

#define evalL() eval_const_expr(e->child[0], FALSE, is_iconst)
#define evalR() eval_const_expr(e->child[1], FALSE, is_iconst)
        case TOK_UNARY_PLUS:
            resL = evalL();
            if (KIND(e->child[0]) != IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = +resL);
        case TOK_UNARY_MINUS:
            resL = evalL();
            if (KIND(e->child[0]) != IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = -resL);
        case TOK_COMPLEMENT:
            resL = evalL();
            if (KIND(e->child[0]) != IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = ~resL);
        case TOK_NEGATION:
            resL = evalL();
            if (KIND(e->child[0]) != IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = !resL);
        case TOK_CAST: {
            Token dest_ty;

            dest_ty = get_type_category((Declaration *)e->child[1]);
            if (is_iconst && !is_integer(dest_ty))
                break;
            resL = evalL();
            if (KIND(e->child[0]) == IConstExp) {
                KIND(e) = IConstExp;
                switch (dest_ty) {
                case TOK_SHORT:
                    return (VALUE(e) = (short)resL);
                case TOK_UNSIGNED_SHORT:
                    return (VALUE(e) = (unsigned short)resL);
                case TOK_CHAR:
                case TOK_SIGNED_CHAR:
                    return (VALUE(e) = (char)resL);
                case TOK_UNSIGNED_CHAR:
                    return (VALUE(e) = (unsigned char)resL);
                case TOK_INT: case TOK_ENUM:
                    return (VALUE(e) = (int)resL);
                case TOK_UNSIGNED: case TOK_STAR:
                    return (VALUE(e) = (unsigned)resL);
                default: /* no conversion */
                    return (VALUE(e) = resL);
                }
            } else {
                /* make sure no address is truncated */
                switch (dest_ty) {
                case TOK_SHORT: case TOK_UNSIGNED_SHORT:
                case TOK_CHAR: case TOK_SIGNED_CHAR: case TOK_UNSIGNED_CHAR:
                    goto err;
                case TOK_INT: case TOK_UNSIGNED:
                    if (targeting_arch64)
                        goto err;
                    break;
                }
                return resL;
            err:
                break;
            }
        }

        case TOK_MUL:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL*resR);
        case TOK_DIV:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL/(unsigned long)resR);
            else
                return (VALUE(e) = resL/resR);
        case TOK_REM:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL%(unsigned long)resR);
            else
                return (VALUE(e) = resL%resR);
        case TOK_PLUS:
            if (is_integer(get_type_category(&e->type))) {
                resL = evalL(), resR = evalR();
                if (KIND(e->child[0])==IConstExp && KIND(e->child[1])==IConstExp) {
                    KIND(e) = IConstExp;
                    return (VALUE(e) = resL+resR);
                } else {
                    return 0xABCD; /* doesn't matter */
                }
            } else {
                int pi, ii;

                if (is_iconst)
                    break;
                if (is_integer(get_type_category(&e->child[0]->type)))
                    pi = 1, ii = 0;
                else
                    pi = 0, ii = 1;
                resL = evalL(), resR = evalR();
                if (KIND(e->child[ii]) != IConstExp)
                    break;
                if (KIND(e->child[pi])==IConstExp && KIND(e->child[ii])==IConstExp) {
                    Declaration ty;

                    KIND(e) = IConstExp;
                    ty = e->child[pi]->type;
                    ty.idl = ty.idl->child;
                    if (pi == 0)
                        return (VALUE(e) = resL + resR*get_sizeof(&ty));
                    else
                        return (VALUE(e) = resL*get_sizeof(&ty) + resR);
                } else {
                    return 0xABCD; /* doesn't matter */
                }
            }
        case TOK_MINUS:
            if (is_integer(get_type_category(&e->child[0]->type))) { /* int-int */
                resL = evalL(), resR = evalR();
                if (KIND(e->child[1]) != IConstExp)
                    break;
                if (KIND(e->child[0]) == IConstExp) {
                    KIND(e) = IConstExp;
                    return (VALUE(e) = resL-resR);
                } else {
                    return 0xABCD; /* doesn't matter */
                }
            } else {
                if (is_iconst)
                    break;
                resL = evalL(), resR = evalR();
                if (KIND(e->child[1]) != IConstExp)
                    break;
                if (KIND(e->child[0]) == IConstExp) {
                    Declaration ty;

                    KIND(e) = IConstExp;
                    ty = e->child[0]->type;
                    ty.idl = ty.idl->child;
                    if (is_integer(get_type_category(&e->child[1]->type))) /* ptr-int */
                        return (VALUE(e) = resL - resR*get_sizeof(&ty));
                    else /* ptr-ptr */
                        return (VALUE(e) = (resL-resR)/get_sizeof(&ty));
                } else {
                    return 0xABCD; /* doesn't matter */
                }
            }
        case TOK_LSHIFT:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL<<resR);
        case TOK_RSHIFT:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL>>resR);
            else
                return (VALUE(e) = resL>>resR);
        case TOK_LT:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL<(unsigned long)resR);
            else
                return (VALUE(e) = resL<resR);
        case TOK_GT:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL>(unsigned long)resR);
            else
                return (VALUE(e) = resL>resR);
        case TOK_LET:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL<=(unsigned long)resR);
            else
                return (VALUE(e) = resL<=resR);
        case TOK_GET:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            if (is_unsigned_int(get_type_category(&e->type)))
                return (VALUE(e) = (unsigned long)resL>=(unsigned long)resR);
            else
                return (VALUE(e) = resL>=resR);
        case TOK_EQ:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL==resR);
        case TOK_NEQ:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL!=resR);
        case TOK_BW_AND:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL&resR);
        case TOK_BW_XOR:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL^resR);
        case TOK_BW_OR:
            resL = evalL(), resR = evalR();
            if (KIND(e->child[0])!=IConstExp || KIND(e->child[1])!=IConstExp)
                break;
            KIND(e) = IConstExp;
            return (VALUE(e) = resL|resR);
        case TOK_AND:
            /*
             * x && y: OK.
             * ? && x: x must be an integer constant equal to 0.
             * x && ?: x must be an integer constant equal to 0.
             * ? && ?: invalid.
             */
            resL = evalL();
            if (KIND(e->child[0])!=IConstExp && KIND(e->child[0])==OpExp) {
                resR = evalR();
                if ((KIND(e->child[1])!=IConstExp && KIND(e->child[1])==OpExp) || resR)
                    break;
                KIND(e) = IConstExp;
                return (VALUE(e) = FALSE);
            } else {
                if (!resL) {
                    KIND(e) = IConstExp;
                    return (VALUE(e) = FALSE);
                }
                resR = evalR();
                if (KIND(e->child[0])!=IConstExp && KIND(e->child[0])==OpExp)
                    break;
                KIND(e) = IConstExp;
                return (VALUE(e) = !!resR);
            }
        case TOK_OR:
            /*
             * x || y: OK
             * ? || x: x must be an integer constant distinct to 0.
             * x || ?: x must be an integer constant distinct to 0.
             * ? || ?: invalid.
             */
            resL = evalL();
            if (KIND(e->child[0])!=IConstExp && KIND(e->child[0])==OpExp) {
                resR = evalR();
                if ((KIND(e->child[1])!=IConstExp && KIND(e->child[1])==OpExp) || !resR)
                    break;
                KIND(e) = IConstExp;
                return (VALUE(e) = TRUE);
            } else {
                if (resL) {
                    KIND(e) = IConstExp;
                    return (VALUE(e) = TRUE);
                }
                resR = evalR();
                if (KIND(e->child[0])!=IConstExp && KIND(e->child[0])==OpExp)
                    break;
                KIND(e) = IConstExp;
                return (VALUE(e) = !!resR);
            }
        case TOK_CONDITIONAL: {
            long long cond;

            cond = eval_const_expr(e->child[0], FALSE, is_iconst);
            if (KIND(e->child[0]) == IConstExp)
                ;
            else if (KIND(e->child[0]) == OpExp)
                break;
            else
                VALUE(e) = cond;
            if (cond) {
                resL = eval_const_expr(e->child[1], FALSE, is_iconst);
                if (KIND(e->child[1]) == IConstExp) {
                    KIND(e) = IConstExp;
                    return (VALUE(e) = resL);
                } else {
                    return resL;
                }
            } else {
                resR = eval_const_expr(e->child[2], FALSE, is_iconst);
                if (KIND(e->child[2]) == IConstExp) {
                    KIND(e) = IConstExp;
                    return (VALUE(e) = resR);
                } else {
                    return resR;
                }
            }
        }
#undef evalL
#undef evalR
#undef VALUE
#undef KIND
        }
        break;

    case IConstExp:
        return e->attr.val;

    case StrLitExp:
        if (is_iconst)
            break;
        return TRUE;

    case IdExp:
        if (is_iconst)
            break;

        /*
         * An identifier can only appears in a constant expression
         * if its address is being computed or the address of one
         * of its elements (arrays) or members (unions/structs) is
         * being computed. The address can be computed implicitly
         * if the identifier denotes an array or function designator.
         */
        if (!is_addr
        && (e->type.idl==NULL || e->type.idl->op!=TOK_FUNCTION&&e->type.idl->op!=TOK_SUBSCRIPT))
            break;
        /*
         * Moreover, the identifier must have static storage
         * duration (it was declared at file scope or has one
         * of the storage class specifiers extern or static).
         */
        if (!is_external_id(e->attr.str)) {
            TypeExp *scs;

            scs = get_sto_class_spec(e->type.decl_specs);
            if (scs==NULL || scs->op!=TOK_STATIC&&scs->op!=TOK_EXTERN)
                break;
        }
        return TRUE;
    }
    emit_error(TRUE, e->info->src_file, e->info->src_line, e->info->src_column,
    "invalid constant expression");
    // longjmp(env, 1);
}
