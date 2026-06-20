#include "decl.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "util/util.h"
#include "expr.h"
#include "stmt.h"
#include "util/arena.h"
#include "imp_lim.h"
#include "error.h"
#include "luxcc.h"

#define ERROR(tok, ...) emit_error(TRUE, (tok)->info->src_file, (tok)->info->src_line, (tok)->info->src_column, __VA_ARGS__)
#define WARNING(tok, ...) emit_warning((tok)->info->src_file, (tok)->info->src_line, (tok)->info->src_column, __VA_ARGS__)

#define HASH_SIZE       4093
#define OUTERMOST_LEVEL 0
#define FILE_SCOPE      0
#define HASH_VAL(s)     (hash(s)%HASH_SIZE)
#define HASH_VAL2(x)    (hash2(x)%HASH_SIZE)

char *current_function_name; /* used to implement __func__ */

static ExternId *external_declarations[HASH_SIZE];
static ExternId *external_declarations_list; /* linearized symtab */

ExternId *get_external_declarations(void)
{
    return external_declarations_list;
}

/*
 * Lexically scoped symbol tables that implement ordinary
 * identifiers and tags name spaces.
 * The symbol table that implements label names is in stmt.c.
 * Structure and union members are handled in a special way.
 */
static Symbol *ordinary_identifiers[MAX_NEST][HASH_SIZE];
static TypeTag *tags[MAX_NEST][HASH_SIZE];

static int nesting_level = OUTERMOST_LEVEL;
static int delayed_delete;
static int scope_id;
static TokenNode *typedef_name_info;

static Arena *oids_arena[MAX_NEST];
static Arena *tags_arena[MAX_NEST];
static Arena *decl_node_arena;

static DeclList *new_param_decl(TypeExp *decl_specs, TypeExp *declarator)
{
    DeclList *n;

    n = new_decl_list_node();
    n->decl = new_declaration_node();
    n->decl->decl_specs = decl_specs;
    n->decl->idl = declarator;
    n->next = NULL;
    return n;
}

TypeExp *dup_declarator(TypeExp *d)
{
    TypeExp *n;

    if (d == NULL)
        return d;

    n = new_type_exp_node();
    *n = *d;
    n->info = typedef_name_info;
    if (d->op == TOK_FUNCTION) {
        DeclList *p, *temp;

        p = d->attr.dl;
        n->attr.dl = temp = new_param_decl(p->decl->decl_specs, dup_declarator(p->decl->idl));
        p = p->next;
        while (p != NULL) {
            temp->next = new_param_decl(p->decl->decl_specs, dup_declarator(p->decl->idl));
            temp=temp->next, p=p->next;
        }
    }
    n->child = dup_declarator(d->child);
    return n;
}

TypeExp *dup_decl_specs(TypeExp *ds)
{
    TypeExp *n;

    if (ds == NULL)
        return NULL;
    n = new_type_exp_node();
    *n = *ds;
    n->child = dup_decl_specs(ds->child);
    return n;
}

void decl_init(void)
{
    int i;

    for (i = 0; i < MAX_NEST; i++) {
        oids_arena[i] = arena_new(sizeof(Symbol)*64, FALSE);
        tags_arena[i] = arena_new(sizeof(TypeTag)*32, FALSE);
    }
    decl_node_arena = arena_new(2048, FALSE);
}

ExternId *new_extern_id_node(void)
{
    return arena_alloc(decl_node_arena, sizeof(ExternId));
}

static int is_sto_class_spec(Token t)
{
    switch (t) {
    case TOK_TYPEDEF:
    case TOK_EXTERN:
    case TOK_STATIC:
    case TOK_AUTO:
    case TOK_REGISTER:
        return TRUE;
    default:
        return FALSE;
    }
}

static int is_type_spec(Token t)
{
    switch (t) {
    case TOK_VOID: case TOK_CHAR: case TOK_SIGNED_CHAR: case TOK_UNSIGNED_CHAR:
    case TOK_SHORT: case TOK_UNSIGNED_SHORT: case TOK_INT: case TOK_UNSIGNED:
    case TOK_LONG: case TOK_UNSIGNED_LONG: case TOK_STRUCT: case TOK_UNION:
    case TOK_ENUM: case TOK_TYPEDEFNAME: case TOK_ERROR:
    case TOK_LONG_LONG: case TOK_UNSIGNED_LONG_LONG:
        return TRUE;
    default:
        return FALSE;
    }
}

static int is_type_qualifier(Token t)
{
    return (t==TOK_CONST || t==TOK_VOLATILE);
}

int is_struct_union_enum(Token t)
{
    return (t==TOK_STRUCT || t==TOK_UNION || t==TOK_ENUM);
}

TypeExp *get_sto_class_spec(TypeExp *d)
{
    while (d != NULL) {
        if (is_sto_class_spec(d->op))
            break;
        d = d->child;
    }
    return d;
}

TypeExp *get_type_spec(TypeExp *d)
{
    while (d != NULL) {
        if (is_type_spec(d->op))
            break;
        d = d->child;
    }
    assert(d != NULL); /* a type specifier is required */
    return d;
}

TypeExp *get_type_qual(TypeExp *d)
{
    while (d != NULL) {
        if (is_type_qualifier(d->op) || d->op==TOK_CONST_VOLATILE)
            break;
        d = d->child;
    }
    return d;
}

/* pop_scope() just set a flag. This function performs the actual delete. */
static void delete_scope(void)
{
    assert(nesting_level >= 0);

    memset(&ordinary_identifiers[nesting_level][0], 0, sizeof(Symbol *)*HASH_SIZE);
    arena_reset(oids_arena[nesting_level]);

    memset(&tags[nesting_level][0], 0, sizeof(TypeTag *)*HASH_SIZE);
    arena_reset(tags_arena[nesting_level]);

    --nesting_level;
    delayed_delete = FALSE;
}

void restore_scope(void)
{
    delayed_delete = FALSE;
}

void push_scope(void)
{
    if (delayed_delete)
        delete_scope();

    if (++nesting_level >= MAX_NEST) /* overflow */
        TERMINATE("error: too many nested scopes (>= %d)", MAX_NEST);

    ++scope_id; /* create a new ID for this scope */
}

void pop_scope(void)
{
    if (delayed_delete)
        delete_scope();

    delayed_delete = TRUE;
}

int get_curr_scope_id(void)
{
    return scope_id;
}

TypeTag *lookup_tag(char *id, int all)
{
    int n;
    unsigned h;
    TypeTag *np;

    if (delayed_delete)
        delete_scope();

    n = nesting_level;
    h = HASH_VAL(id);
    if (all == TRUE) {
        for (; n >= 0; n--)
            for (np = tags[n][h]; np != NULL; np = np->next)
                if (equal(id, np->type->str))
                    return np;
        return NULL; /* not found */
    } else {
        for (np = tags[n][h]; np != NULL; np = np->next)
            if (equal(id, np->type->str))
                return np;
        return NULL; /* not found */
    }
}

void install_tag(TypeExp *ty)
{
    unsigned h;
    TypeTag *np;

    DEBUG_PRINTF("new tag `%s', nesting level: %d\n", ty->str, nesting_level);

    if (delayed_delete)
        delete_scope();

    np = arena_alloc(tags_arena[nesting_level], sizeof(TypeTag));
    np->type = ty;
    h = HASH_VAL(ty->str);
    np->next = tags[nesting_level][h];
    tags[nesting_level][h] = np;
}

Symbol *lookup_ordinary_id(char *id, int all)
{
    int n;
    Symbol *np;
    unsigned h;

    if (delayed_delete)
        delete_scope();

    n = nesting_level;
    h = HASH_VAL(id);
    if (all == TRUE) {
        for (; n >= 0; n--)
            for (np = ordinary_identifiers[n][h]; np != NULL; np = np->next)
                if (equal(id, np->declarator->str))
                    return np;
        return NULL; /* not found */
    } else {
        for (np = ordinary_identifiers[n][h]; np != NULL; np = np->next)
            if (equal(id, np->declarator->str))
                return np;
        return NULL; /* not found */
    }
}

static void install_ordinary_id(TypeExp *decl_specs, TypeExp *declarator, int is_param)
{
    Symbol *np;
    unsigned h;
    TypeExp *scs;
    Token curr_scs, prev_scs;

    if (delayed_delete)
        delete_scope();

    h = HASH_VAL(declarator->str);
    for (np = ordinary_identifiers[nesting_level][h]; np != NULL; np = np->next)
        if (equal(declarator->str, np->declarator->str))
            break;

    if (np == NULL) { /* not found in this scope */
        np = arena_alloc(oids_arena[nesting_level], sizeof(Symbol));
        np->decl_specs = decl_specs;
        np->declarator = declarator;
        np->is_param = (short)is_param;
        np->nesting_level = (short)nesting_level;
        np->scope = scope_id;
        np->next = ordinary_identifiers[nesting_level][h];
        ordinary_identifiers[nesting_level][h] = np;
        return;
    }

    /*
     * Already in this scope.
     * Just check for errors.
     * Do not replace the previous declaration.
     */
    curr_scs = (scs=get_sto_class_spec(decl_specs))!=NULL ? scs->op:0;
    prev_scs = (scs=get_sto_class_spec(np->decl_specs))!=NULL ? scs->op:0;

    if (declarator->op==TOK_ENUM_CONST || curr_scs==TOK_TYPEDEF) {
        /*
         * Clash while trying to install an enumeration constant or typedef name.
         */
        if (declarator->op==TOK_ENUM_CONST && np->declarator->op==TOK_ENUM_CONST)
            ERROR(declarator, "redeclaration of enumerator `%s'", declarator->str);
        else if (curr_scs==TOK_TYPEDEF && prev_scs==TOK_TYPEDEF)
            ERROR(declarator, "redefinition of typedef `%s'", declarator->str);
        else
            goto redecl_as_diff_kind;
    } else if (np->declarator->op==TOK_ENUM_CONST || prev_scs==TOK_TYPEDEF) {
        /*
         * Clash with previously declared enumeration constant or typedef name.
         */
        goto redecl_as_diff_kind;
    } else if (nesting_level != OUTERMOST_LEVEL) {
        int curr_is_func, prev_is_func;

        /*
         * If one of the declarations declares a function, just make sure the
         * other one declares a function too and return. analyze_init_declarator()
         * will check for linkage and type agreement.
         */
        curr_is_func = declarator->child!=NULL && declarator->child->op==TOK_FUNCTION;
        prev_is_func = np->declarator->child!=NULL && np->declarator->child->op==TOK_FUNCTION;
        if (curr_is_func || prev_is_func) {
            if (curr_is_func != prev_is_func)
                goto redecl_as_diff_kind;
            else
                return; /* OK by now */
        }

        /*
         * Check linkage of objects.
         */
        if (!curr_scs || curr_scs!=TOK_EXTERN) {
            if (!prev_scs || prev_scs!=TOK_EXTERN)
                /* e.g. int x; ==> int x; */
                ERROR(declarator, "redeclaration of `%s' with no linkage", declarator->str);
            else /* if (prev_scs == TOK_EXTERN) */
                /* e.g. extern int x; ==> int x; */
                ERROR(declarator, "declaration of `%s' with no linkage follows extern declaration", declarator->str);
        } else if (!prev_scs || prev_scs!=TOK_EXTERN) {
            /* e.g. int x; ==> extern int x; */
            ERROR(declarator, "extern declaration of `%s' follows declaration with no linkage", declarator->str);
        }
    }
    return;
redecl_as_diff_kind:
    /*
     * This is the diagnostic given by gcc and clang
     * when an ordinary identifier that denotes
     * - A function,
     * - An enumeration constant,
     * - A typedef name, or
     * - An object/variable
     * is redeclared as denoting a different kind.
     */
    ERROR(declarator, "`%s' redeclared as different kind of symbol", declarator->str);
}

ExternId *lookup_external_id(char *id)
{
    ExternId *np;

    for (np = external_declarations[HASH_VAL(id)]; np != NULL; np = np->next)
        if (equal(id, np->declarator->str))
            return np;
    return NULL; /* not found */
}

static void install_external_id(TypeExp *decl_specs, TypeExp *declarator, ExtIdStatus status)
{
    ExternId *np;
    unsigned h;

    np = new_extern_id_node();
    np->decl_specs = decl_specs;
    np->declarator = declarator;
    np->status = status;
    h = HASH_VAL(declarator->str);
    np->next = external_declarations[h];
    external_declarations[h] = np;
}

int is_external_id(char *id)
{
    return lookup_external_id(id)!=NULL;
}

/* set attributes to identifier node */
void set_attributes(ExecNode *e, Symbol *sym)
{
    Token cat;
    TypeExp *scs;

    /* set type */
    e->type.decl_specs = sym->decl_specs;
    e->type.idl = (sym->declarator->op!=TOK_ENUM_CONST)?sym->declarator->child:sym->declarator;
    cat = get_type_category(&e->type);

    /* set scope (the identifier/scope pair is used to unambiguously identify the object) */
    if (sym->nesting_level != OUTERMOST_LEVEL)
        e->attr.var.scope = sym->scope;
    else
        e->attr.var.scope = FILE_SCOPE;

    scs = get_sto_class_spec(e->type.decl_specs);

    /* set storage duration */
    if (sym->nesting_level == OUTERMOST_LEVEL
    || scs!=NULL && (scs->op==TOK_EXTERN || scs->op==TOK_STATIC)
    || cat == TOK_FUNCTION)
        e->attr.var.duration = DURATION_STATIC;
    else
        e->attr.var.duration = DURATION_AUTO;

    /* set linkage */
    if (scs == NULL) {
        if (sym->nesting_level==OUTERMOST_LEVEL || cat==TOK_FUNCTION)
            e->attr.var.linkage = LINKAGE_EXTERNAL;
        else
            e->attr.var.linkage = LINKAGE_NONE;
    } else if (scs->op == TOK_EXTERN) {
        e->attr.var.linkage = LINKAGE_EXTERNAL;
    } else if (scs->op==TOK_STATIC && sym->nesting_level==OUTERMOST_LEVEL) {
        e->attr.var.linkage = LINKAGE_INTERNAL;
    } else {
        e->attr.var.linkage = LINKAGE_NONE;
    }

    if (e->attr.var.linkage == LINKAGE_EXTERNAL)
        e->attr.var.scope = FILE_SCOPE;

    e->attr.var.is_param = (char)sym->is_param;
}

void analyze_decl_specs(TypeExp *d)
{
    enum {
        CHAR        = 0x00001,
        INT         = 0x00002,
        VOID        = 0x00004,
        STRUCT      = 0x00008,
        UNION       = 0x00010,
        ENUM        = 0x00020,
        TYPEDEFNAME = 0x00040,
        SHORT       = 0x00080,
        LONG        = 0x00100,
        LONG_LONG   = 0x00200,
        UNSIGNED    = 0x00400,
        SIGNED      = 0x00800,
        VOLATILE    = 0x01000,
        CONST       = 0x02000,
        TYPEDEF     = 0x04000,
        EXTERN      = 0x08000,
        STATIC      = 0x10000,
        AUTO        = 0x20000,
        REGISTER    = 0x40000,
    };
#define SIGN_MASK (UNSIGNED+SIGNED)
#define SIZE_MASK (SHORT+LONG+LONG_LONG)
#define TYPE_MASK (VOID+STRUCT+UNION+ENUM+TYPEDEFNAME)
#define QUAL_MASK (VOLATILE+CONST)
#define STOC_MASK (TYPEDEF+EXTERN+STATIC+AUTO+REGISTER)

    TypeExp *p;
    unsigned tymsk = 0;
    TypeExp *tyspe_node;

    assert(d != NULL);
    tyspe_node = NULL;
    for (p = d; p != NULL; p = p->child) {
        switch (p->op) {
        case TOK_CHAR:
        case TOK_INT:
            if ((tymsk & INT+CHAR+TYPE_MASK) != 0)
                goto too_many_tyspe;
            tymsk |= (p->op == TOK_CHAR) ? CHAR : INT;
            break;

        case TOK_VOID:
        case TOK_STRUCT:
        case TOK_UNION:
        case TOK_ENUM:
        case TOK_TYPEDEFNAME:
            if ((tymsk & TYPE_MASK+SIGN_MASK+SIZE_MASK+INT+CHAR) != 0)
                goto too_many_tyspe;
            switch (p->op) {
            case TOK_VOID:          tymsk |= VOID;          break;
            case TOK_STRUCT:        tymsk |= STRUCT;        break;
            case TOK_UNION:         tymsk |= UNION;         break;
            case TOK_ENUM:          tymsk |= ENUM;          break;
            case TOK_TYPEDEFNAME:   tymsk |= TYPEDEFNAME;   break;
            }
            tyspe_node = p;
            break;

        case TOK_SHORT:
            if ((tymsk & SIZE_MASK+TYPE_MASK+CHAR) != 0)
                goto too_many_tyspe;
            tymsk |= SHORT;
            break;
        case TOK_LONG:
            if ((tymsk & LONG_LONG+TYPE_MASK+CHAR) != 0) {
                goto too_many_tyspe;
            } else if ((tymsk&LONG) != 0) {
                tymsk &= ~LONG;
                tymsk |= LONG_LONG;
            } else {
                tymsk |= LONG;
            }
            break;

        case TOK_UNSIGNED:
        case TOK_SIGNED:
            if ((tymsk & SIGN_MASK+TYPE_MASK) != 0)
                goto too_many_tyspe;
            tymsk |= (p->op == TOK_UNSIGNED) ? UNSIGNED : SIGNED;
            break;

        case TOK_VOLATILE:
            tymsk |= VOLATILE;
            break;
        case TOK_CONST:
            tymsk |= CONST;
            break;

        case TOK_TYPEDEF:
        case TOK_EXTERN:
        case TOK_STATIC:
        case TOK_AUTO:
        case TOK_REGISTER:
            if ((tymsk&STOC_MASK) != 0)
                ERROR(p, "more than one storage class specifier");
            switch (p->op) {
            case TOK_TYPEDEF:   tymsk |= TYPEDEF;   break;
            case TOK_EXTERN:    tymsk |= EXTERN;    break;
            case TOK_STATIC:    tymsk |= STATIC;    break;
            case TOK_AUTO:      tymsk |= AUTO;      break;
            case TOK_REGISTER:  tymsk |= REGISTER;  break;
            }
            break;
        }
    }

    p = d;
    if ((tymsk&STOC_MASK) != 0) {
        if (p == tyspe_node)
            p = p->child;
        p->op = get_sto_class_spec(d)->op;
        if (p->child != NULL)
            p = p->child;
    }
    switch (tymsk & QUAL_MASK) {
    case VOLATILE:
        if (p == tyspe_node) {
            p = p->child;
            p->op = TOK_VOLATILE;
        } else {
            p->op = TOK_VOLATILE;
            if (p->child != NULL)
                p = p->child;
        }
        break;
    case CONST:
        if (p == tyspe_node) {
            p = p->child;
            p->op = TOK_CONST;
        } else {
            p->op = TOK_CONST;
            if (p->child != NULL)
                p = p->child;
        }
        break;
    case CONST+VOLATILE:
        if (p == tyspe_node) {
            p = p->child;
            p->op = TOK_CONST_VOLATILE;
        } else {
            p->op = TOK_CONST_VOLATILE;
            if (p->child != NULL)
                p = p->child;
        }
        break;
    default:
        break;
    }
    assert(p != NULL);
    switch (tymsk & TYPE_MASK+SIGN_MASK+SIZE_MASK+INT+CHAR) {
    case CHAR:
    case CHAR+SIGNED:
        p->op = TOK_CHAR;
        break;
    case CHAR+UNSIGNED:
        p->op = TOK_UNSIGNED_CHAR;
        break;
    case SHORT:
    case SHORT+INT:
    case SHORT+SIGNED:
    case SHORT+SIGNED+INT:
        p->op = TOK_SHORT;
        break;
    case SHORT+UNSIGNED:
    case SHORT+UNSIGNED+INT:
        p->op = TOK_UNSIGNED_SHORT;
        break;
    case INT:
    case SIGNED+INT:
        p->op = TOK_INT;
        break;
    case UNSIGNED:
    case UNSIGNED+INT:
        p->op = TOK_UNSIGNED;
        break;
    case LONG:
    case LONG+INT:
    case LONG+SIGNED:
    case LONG+SIGNED+INT:
        p->op = TOK_LONG;
        break;
    case LONG+UNSIGNED:
    case LONG+UNSIGNED+INT:
        p->op = TOK_UNSIGNED_LONG;
        break;
    case LONG_LONG:
    case LONG_LONG+INT:
    case LONG_LONG+SIGNED:
    case LONG_LONG+SIGNED+INT:
        p->op = TOK_LONG_LONG;
        break;
    case LONG_LONG+UNSIGNED:
    case LONG_LONG+UNSIGNED+INT:
        p->op = TOK_UNSIGNED_LONG_LONG;
        break;
    case VOID:
        p->op = TOK_VOID;
        break;
    case STRUCT:
    case UNION:
    case ENUM:
    case TYPEDEFNAME:
        break;
    case 0:
        ERROR(d, "missing type specifier");
    default:
        assert(0);
    }
    p->child = NULL;
    return;

too_many_tyspe:
    ERROR(p, "more than one type specifier");
}

int is_typedef_name(char *id)
{
    Symbol *np;

    if ((np=lookup_ordinary_id(id, TRUE)) != NULL) {
        TypeExp *scs;

        if ((scs=get_sto_class_spec(np->decl_specs))!=NULL && scs->op==TOK_TYPEDEF)
            return TRUE;
    }
    return FALSE;
}

static int en_val = -1;

void reset_enum_val(void)
{
    en_val = -1;
}

void analyze_enumerator(TypeExp *e)
{
    static TypeExp enum_ds = { TOK_INT };

    /*
     * 6.7.2.2#2
     * The expression that defines the value of an enumeration constant shall be an integer
     * constant expression that has a value representable as an int.
     */
    if (e->attr.e != NULL) {
        Token ty;

        ty = get_type_category(&e->attr.e->type);
        if (!is_integer(ty))
            ERROR(e, "enumerator value is not an integer constant");
        en_val = eval_const_expr(e->attr.e, FALSE, TRUE);
    } else {
        e->attr.e = new_exec_node();
        if (en_val+1 < en_val)
            WARNING(e, "overflow in enumeration value");
        ++en_val;
    }
    e->attr.e->attr.val = en_val;
    install_ordinary_id(&enum_ds, e, FALSE);
}

int compare_decl_specs(TypeExp *ds1, TypeExp *ds2, int qualified)
{
    TypeExp *temp1, *temp2;

    /* type specifiers */
    temp1 = get_type_spec(ds1);
    temp2 = get_type_spec(ds2);
    if (temp1->op!=temp2->op || is_struct_union_enum(temp1->op)&&temp1->str!=temp2->str)
        return FALSE;

    /* type qualifiers */
    if (qualified) {
        temp1 = get_type_qual(ds1);
        temp2 = get_type_qual(ds2);
        if (temp1==NULL && temp2!=NULL
        || temp2==NULL && temp1!=NULL
        || temp1!=NULL && temp1->op!=temp2->op) {
            DEBUG_PRINTF("type qualifiers conflict\n");
            return FALSE;
        }
    }

    return TRUE;
}

/*
 * Return TRUE if the two types are compatible.
 * If 'qualified' is TRUE, type qualifiers are taken into account.
 * If 'compose' is TRUE, array types are composed.
 */
int are_compatible(TypeExp *ds1, TypeExp *dct1,
                   TypeExp *ds2, TypeExp *dct2,
                   int qualified, int compose)
{
    /* identifiers are non-significant */
    if (dct1!=NULL && dct1->op==TOK_ID)
        dct1 = dct1->child;
    if (dct2!=NULL && dct2->op==TOK_ID)
        dct2 = dct2->child;

    if (dct1==NULL || dct2==NULL) {
        if (dct1 != dct2)
            return FALSE;
        return compare_decl_specs(ds1, ds2, qualified);
    }

    if (dct1->op != dct2->op)
        return FALSE;

    switch (dct1->op) {
    case TOK_ELLIPSIS:
        return TRUE;
    case TOK_STAR:
        if (qualified
        && (dct1->attr.el==NULL && dct2->attr.el!=NULL
        || dct1->attr.el!=NULL && dct2->attr.el==NULL
        || dct1->attr.el!=NULL && dct1->attr.el->op!=dct2->attr.el->op))
            return FALSE;
        break;
    case TOK_SUBSCRIPT:
        if (dct1->attr.e!=NULL && dct2->attr.e!=NULL) {
            if (dct1->attr.e->attr.val != dct2->attr.e->attr.val)
                return FALSE;
        } else if (compose) {
            if (dct1->attr.e==NULL && dct2->attr.e!=NULL)
                dct1->attr.e = dct2->attr.e;
            else if (dct2->attr.e==NULL && dct1->attr.e!=NULL)
                dct2->attr.e = dct1->attr.e;
        }
        break;
    case TOK_FUNCTION: {
        DeclList *p1, *p2;

        p1 = dct1->attr.dl;
        p2 = dct2->attr.dl;
        while (p1!=NULL && p2!=NULL) {
            /*
             * 6.7.5.3#15
             * [...]In the determination of type compatibility and of a composite type, each
             * parameter declared [...] with qualified type is taken as having the unqualified
             * version of its declared type.
             */
            if (!are_compatible(p1->decl->decl_specs, p1->decl->idl,
            p2->decl->decl_specs, p2->decl->idl, FALSE, compose))
                return FALSE;
            p1 = p1->next;
            p2 = p2->next;
        }
        if (p1 != p2)
            return FALSE;
    }
        break;
    }

    return are_compatible(ds1, dct1->child, ds2, dct2->child, TRUE, compose);
}

int is_complete(char *tag)
{
    TypeTag *tp;

    if (tag[0] == '<') /* <anonymous> struct/union/enum */
        return TRUE;
    tp = lookup_tag(tag, TRUE);
    assert(tp != NULL);
    return (tp->type->op == TOK_ENUM) ? tp->type->attr.el!=NULL : tp->type->attr.dl!=NULL;
}

#if 0
int is_incomplete(TypeExp *decl_specs, TypeExp *declarator)
{
    if (declarator->child == NULL) {
        TypeExp *ts;

        ts = get_type_spec(decl_specs);
        if (ts->op==TOK_VOID || is_struct_union_enum(ts->op)&&!is_complete(ts->str))
            return TRUE;
    } else if (declarator->child->op==TOK_SUBSCRIPT && declarator->child->attr.e==NULL) {
        return TRUE;
    }
}
#endif

/*
 * Use this function instead of analyze_declarator() when the declarator
 * to be analyzed already went through any typedef-name replacement, and
 * no identifier needs to be installed into the symbol table.
 */
static void analyze_declarator2(TypeExp *decl_specs, TypeExp *declarator)
{
    if (declarator == NULL)
        return;

    switch (declarator->op) {
    case TOK_ID:
    case TOK_STAR:
        break;
    case TOK_SUBSCRIPT:
        /*
         * 6.7.5.2#1
         * The element type shall not be an incomplete or function type.
         */
        if (declarator->child != NULL) {
            if (declarator->child->op == TOK_FUNCTION)
                ERROR(declarator, "array of functions");
            else if (declarator->child->op==TOK_SUBSCRIPT && declarator->child->attr.e==NULL)
                ERROR(declarator, "array has incomplete element type");
        } else {
            TypeExp *ts;

            ts = get_type_spec(decl_specs);
            if (ts->op==TOK_VOID || is_struct_union_enum(ts->op)&&!is_complete(ts->str))
                ERROR(declarator, "array has incomplete element type");
        }
        if (declarator->attr.e != NULL) {
            long size;

            /*
             * 6.7.5.2#1
             * [...] If they delimit an expression (which specifies the size of an array), the
             * expression shall have an integer type. If the expression is a constant expression,
             * it shall have a value greater than zero. [...] Note: VLAs are not supported, so the
             * expression must always be constant.
             */
            if (!is_integer(get_type_category(&declarator->attr.e->type)))
                ERROR(declarator, "size of array has non-integer type");

            size = eval_const_expr(declarator->attr.e, FALSE, TRUE);
            if (size <= 0)
                ERROR(declarator, "size of array not greater than zero");

            /* store the computed size in the root of the expression tree */
            declarator->attr.e->attr.val = size; /* maybe overwrites some operator */
        }
        break;
    case TOK_FUNCTION: {
        DeclList *p;

        /*
         * 6.5.7.3#1
         * A function declarator shall not specify a return type that is a function type
         * or an array type.
         */
        if (declarator->child != NULL) {
            if (declarator->child->op == TOK_FUNCTION)
                ERROR(declarator, "function returning a function");
            else if (declarator->child->op == TOK_SUBSCRIPT)
                ERROR(declarator, "function returning an array");
        }

        /*
         * Make sure that, if there is a void parameter,
         * it is the first and only one.
         */
        p = declarator->attr.dl;
        while (p != NULL) {
            if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ELLIPSIS)
                break;

            if (get_type_spec(p->decl->decl_specs)->op == TOK_VOID) {
                TypeExp *temp;

                if (p->decl->idl!=NULL && p->decl->idl->op==TOK_ID)
                    temp = p->decl->idl->child;
                else
                    temp = p->decl->idl;

                if (temp==NULL && (p!=declarator->attr.dl || p->next!=NULL))
                    ERROR(declarator, "`void' must be the first and only parameter");
            }
            p = p->next;
        }
    }
        break;
    }
    analyze_declarator2(decl_specs, declarator->child);
}

static void replace_typedef_name(Declaration *decl)
{
    Symbol *s;
    TypeExp *temp, *tq, *ts, *decl_specs, *declarator;

    decl_specs = decl->decl_specs;
    declarator = decl->idl;

    if ((ts=get_type_spec(decl_specs))->op != TOK_TYPEDEFNAME)
        return;

    /*
     * Type specifiers
     */
    s = lookup_ordinary_id(ts->str, TRUE);
    /* new created nodes will have the same file/line/column information as the typedef name node */
    typedef_name_info = ts->info;
    /* replace the typedef name node for the type specifier node of the typedef name */
    temp = ts->child;
    *ts = *get_type_spec(s->decl_specs);
    ts->child = temp;
    ts->info = typedef_name_info;

    /*
     * Append the declarator part (if present) of the typedef name.
     * A copy of the typedef name's declarator is used to make the replacement
     * because of the risk of modifying the typedef definition during type composition.
     * Suppose the declarations
     *  typedef int a[];
     *  extern a x;
     *  extern int x[10]; // (1), completes x
     * if later the typedef name is used again, as in
     *  a x2;
     * x2 will have type int[10] instead of int[] because (1) completed directly the
     * typedef definition.
     */
    if (s->declarator->child != NULL) {
        if (declarator != NULL) {
            while (declarator->child != NULL)
                declarator = declarator->child;
            declarator->child = dup_declarator(s->declarator->child);
            declarator = declarator->child;
        } else {
            /* empty abstract declarator */
            decl->idl = declarator = dup_declarator(s->declarator->child);
        }
    } else if (declarator) {
        declarator = NULL; /* to trigger the 'goto nothing' that follows */
    }

    /*
     * Type qualifiers (if any)
     * Situations:
     * (1)
     *  typedef int *t;
     *  const t x;
     * after replacement
     *  int *const x; // const removed, new node for pointer's const
     * (2)
     *  typedef const int t;
     *  t x;
     * after replacement
     *  const int x; // new const node
     */

    /* check for (1) */
    temp = get_type_qual(decl_specs);
    if (temp==NULL || declarator==NULL)
        goto nothing;
    if (declarator->op==TOK_STAR || declarator->op==TOK_FUNCTION) {
        goto common;
    } else if (declarator->op == TOK_SUBSCRIPT) {
        /*
         *  6.7.3#8
         * If the specification of an array type includes any type qualifiers,
         * the element type is so-qualified, not the array type.
         */
        do
            declarator = declarator->child;
        while (declarator!=NULL && declarator->op==TOK_SUBSCRIPT); /* search the element type */
        if (declarator != NULL)
            /* the element type of the array is a derived type (pointer or function) */
            goto common;
    }
    goto nothing;
common:
    if (declarator->op == TOK_FUNCTION) {
        WARNING(declarator, "qualifier on function type `%s' has undefined behavior", s->declarator->str);
        temp->op = 0; /* just ignore the qualifier */
        goto nothing;
    }
    /* qualify the pointer */
    if (declarator->attr.el == NULL) {
        declarator->attr.el = new_type_exp_node();
        declarator->attr.el->op = temp->op;
    } else if (declarator->attr.el->op != temp->op) {
        declarator->attr.el->op = TOK_CONST_VOLATILE;
    }
    temp->op = 0; /* no declaration specifier has value zero */
nothing:
    /* check for (2) */
    tq = get_type_qual(s->decl_specs);
    if (tq != NULL) {
        if (temp != NULL) {
            if (!temp->op)
                temp->op = tq->op; /* utilize node removed in (1) */
            else if (temp->op != tq->op)
                temp->op = TOK_CONST_VOLATILE;
        } else {
            /* no type qualifier between the declaration specifiers of
               the original declaration, append a new node at the end */
            temp = decl_specs;
            while (temp->child != NULL)
                temp = temp->child;
            temp->child = new_type_exp_node();
            temp->child->op = tq->op;
        }
    }
}

void analyze_declarator(TypeExp *decl_specs, TypeExp *declarator, int inst_sym)
{
    Declaration d;

    d.decl_specs = decl_specs;
    d.idl = declarator;
    replace_typedef_name(&d);

    analyze_declarator2(decl_specs, declarator);
    if (inst_sym)
        install_ordinary_id(decl_specs, declarator, FALSE);
}

void analyze_type_name(Declaration *tn)
{
    analyze_decl_specs(tn->decl_specs);
    replace_typedef_name(tn);
    analyze_declarator2(tn->decl_specs, tn->idl);
}

void analyze_parameter_declaration(Declaration *d)
{
    TypeExp *scs;

    analyze_decl_specs(d->decl_specs);

    /* 6.7.5.3#2 */
    if ((scs=get_sto_class_spec(d->decl_specs))!=NULL && scs->op!=TOK_REGISTER)
        ERROR(scs, "invalid storage class specifier in parameter declaration");

    replace_typedef_name(d);
    if (d->idl != NULL) {
        TypeExp *p;

        analyze_declarator2(d->decl_specs, d->idl);

        /*
         * Perform adjustment on array and function parameters.
         */
        if (d->idl->op == TOK_ID) {
            p = d->idl->child;
            if (p==NULL && get_type_spec(d->decl_specs)->op==TOK_VOID)
                ERROR(d->idl, "parameter has void type");
            install_ordinary_id(d->decl_specs, d->idl, TRUE);
        } else {
            p = d->idl;
        }
        if (p != NULL) {
            if (p->op == TOK_SUBSCRIPT) {
                /* 6.7.5.3#7 */
                p->op = TOK_STAR;
                if (p->attr.e != NULL) {
                    p->attr.e = NULL;
                }
            } else if (p->op == TOK_FUNCTION) {
                /* 6.7.5.3#8 */
                TypeExp *temp;

                temp = new_type_exp_node();
                *temp = *p;
                p->child = temp;
                p->op = TOK_STAR;
                p->attr.el = NULL;
            }
        }
    }
}

void analyze_function_definition(Declaration *f)
{
    DeclList *p;
    TypeExp *spec;

    /*
     * 6.9.1#2
     * The identifier declared in a function definition (which is the name of the function) shall
     * have a function type, as specified by the declarator portion of the function definition.
     *
     * Note: check this before replace typedef names because it is not allowed for the identifier
     * of a function definition to inherit its 'functionness' from a typedef name.
     */
    if (f->idl->child==NULL || f->idl->child->op!=TOK_FUNCTION)
        ERROR(f->idl, "declarator of function definition does not specify a function type");
    current_function_name = f->idl->str;

    /*
     * We currently are in parameters's scope.
     * Temporarily switch to file scope in order
     * to analyze the function.
     */
    assert(nesting_level == OUTERMOST_LEVEL+1);
    nesting_level = OUTERMOST_LEVEL;
    analyze_declarator(f->decl_specs, f->idl, TRUE);
    analyze_init_declarator(f->decl_specs, f->idl, TRUE);
    nesting_level = OUTERMOST_LEVEL+1;

    /*
     * 6.9.1#4
     * The storage-class specifier, if any, in the declaration specifiers shall be either
     * extern or static.
     */
    if ((spec=get_sto_class_spec(f->decl_specs))!=NULL && spec->op!=TOK_EXTERN && spec->op!=TOK_STATIC)
        ERROR(spec, "invalid storage class `%s' in function definition", tok2lex(spec->op));

    /* check that the function doesn't return an incomplete type */
    if (f->idl->child->child == NULL) {
        /* the return type is not a derived declarator type */
        spec = get_type_spec(f->decl_specs);
        if (is_struct_union_enum(spec->op) && !is_complete(spec->str))
            ERROR(spec, "return type is an incomplete type");
    }

    /*
     *  6.9.1#5
     * If the declarator includes a parameter type list, the declaration of each parameter shall
     * include an identifier, except for the special case of a parameter list consisting of a single
     * parameter of type void, in which case there shall not be an identifier.
     *
     *  6.7.5.3#4
     * After adjustment, the parameters in a parameter type list in a function declarator that is
     * part of a definition of that function shall not have incomplete type.
     */
    p = f->idl->child->attr.dl;
    if (get_type_spec(p->decl->decl_specs)->op!=TOK_VOID || p->decl->idl!=NULL) {
        /* the function has parameters, enforce the above constraints */
        do {
            if (p->decl->idl==NULL || p->decl->idl->op!=TOK_ID) {
                ERROR(p->decl->decl_specs, "missing parameter name in function definition");
            } else if (p->decl->idl->child == NULL) { /* not a derived declarator type */
                TypeExp *ts;

                ts = get_type_spec(p->decl->decl_specs);
                if (is_struct_union_enum(ts->op) && !is_complete(ts->str))
                    ERROR(p->decl->idl, "parameter `%s' has incomplete type", p->decl->idl->str);
            }
            p = p->next;
        } while (p!=NULL && p->decl->idl->op!=TOK_ELLIPSIS);
    }
    set_return_type(f->decl_specs, f->idl->child->child);
}

static void enforce_type_compatibility(TypeExp *prev_ds, TypeExp *prev_dct, TypeExp *ds, TypeExp *dct)
{
    if (!are_compatible(prev_ds, prev_dct, ds, dct, TRUE, TRUE)) {
        Declaration d1, d2;

        d1.decl_specs = prev_ds;
        d1.idl = prev_dct;
        d2.decl_specs = ds;
        d2.idl = dct;
        ERROR(dct, "conflicting types for `%s': before `%s', now `%s'", dct->str,
        stringify_type_exp(&d1, FALSE), stringify_type_exp(&d2, FALSE));
    }
}

/*
 * Check to see if an object with type ds/dct can be initialized
 * by an expression e (if is_const_expr, e must be computable at
 * compile-time).
 * Note: Currently only fully bracketed initialization is handled.
 */
static void analyze_initializer(TypeExp *ds, TypeExp *dct, ExecNode *e, int is_const_expr)
{
    TypeExp *ts;

    if (dct != NULL) {
        Token ty_spec;
        int i, is_init_list;

        if (dct->op != TOK_SUBSCRIPT)
            goto scalar; /* must be a pointer, functions cannot have initializer */

        /*
         * Array.
         */
        is_init_list = e->kind.exp==OpExp && e->attr.op==TOK_INIT_LIST;
        if ((e->kind.exp==StrLitExp || is_init_list && e->child[0]->kind.exp==StrLitExp)
        && dct->child==NULL && is_integer(ty_spec=get_type_spec(ds)->op) && get_rank(ty_spec)==1) {
            /* character array initialized by string literal (or a string literal enclosed in braces) */
            int size;

            if (is_init_list) {
                /* replace the {} by for the string */
                e->kind.exp = StrLitExp;
                e->attr.str = e->child[0]->attr.str;
                e->child[0] = NULL;
            }

            size = strlen(e->attr.str);
            if (dct->attr.e != NULL) {
                /* array with specified bounds */
                if (dct->attr.e->attr.val < size) /* '\0' is only stored when there is room */
                    WARNING(e, "initializer-string for char array is too long");
            } else {
                /* array with unspecified bounds */

                /* complete the array type */
                dct->attr.e = new_exec_node();
                dct->attr.e->attr.val = size+1; /* make room for '\0' */
            }
        } else {
            if (!is_init_list)
                ERROR(e, "invalid array initializer");
            e = e->child[0];

            if (dct->attr.e != NULL) {
                /* array with specified bounds */
                i = dct->attr.e->attr.val;
                for (; e!=NULL && i!=0; e=e->sibling, --i)
                    analyze_initializer(ds, dct->child, e, is_const_expr);

                if (e != NULL)
                    ERROR(e, "excess elements in array initializer");
            } else {
                /* array with unspecified bounds */
                i = 0;
                for (; e != NULL; e = e->sibling, ++i)
                    analyze_initializer(ds, dct->child, e, is_const_expr);

                /* complete the array type */
                dct->attr.e = new_exec_node();
                dct->attr.e->attr.val = i;
            }
        }
    } else if ((ts=get_type_spec(ds))->op == TOK_STRUCT) {
        /*
         * Struct.
         */
        DeclList *d;


        /*
         * See if the struct is being initialized by a single
         * expression of compatible type, like
         *  struct A x = y; // valid if y has struct A type
         * or an initializer list
         *  struct A x = { 1, 2 };
         */
        if (e->kind.exp!=OpExp || e->attr.op!=TOK_INIT_LIST)
            goto scalar;

        /* initialized by initializer list */
        e = e->child[0];

        if (ts->attr.dl == NULL) {
            TypeTag *p;

            p = lookup_tag(ts->str, TRUE);
            assert(p != NULL);
            ts->attr.dl = p->type->attr.dl;
        }
        d = ts->attr.dl;
        for (; d != NULL; d = d->next) {
            dct = d->decl->idl;
            for (; e!=NULL && dct!=NULL; e=e->sibling, dct=dct->sibling)
                analyze_initializer(d->decl->decl_specs, dct->child, e, is_const_expr);

            if (e == NULL)
                break;
        }

        if (e != NULL)
            ERROR(e, "excess elements in struct initializer");
    } else if (ts->op == TOK_UNION) {
        /*
         * Union.
         */

        /* the same as for structs */
        if (e->kind.exp!=OpExp || e->attr.op!=TOK_INIT_LIST)
            goto scalar;

        e = e->child[0];

        if (ts->attr.dl == NULL) {
            TypeTag *p;

            p = lookup_tag(ts->str, TRUE);
            assert(p != NULL);
            ts->attr.dl = p->type->attr.dl;
        }
        /* only the first member of the union can be initialized */
        analyze_initializer(ts->attr.dl->decl->decl_specs, ts->attr.dl->decl->idl->child, e, is_const_expr);

        if (e->sibling != NULL)
            ERROR(e->sibling, "excess elements in union initializer");
    } else {
        /*
         * Scalar.
         */
        Declaration dest_ty;
scalar:
        if (e->kind.exp==OpExp && e->attr.op==TOK_INIT_LIST) {
            /*
             * 6.7.8#11 The initializer for a scalar shall be a single expression,
             * optionally enclosed in braces. [...]
             */
            if (e->child[0]->sibling != NULL)
                ERROR(e, "excess elements in scalar initializer");
            e = e->child[0];
        }
        if (get_type_category(&e->type) == TOK_ERROR)
            return;
        dest_ty.decl_specs = ds;
        dest_ty.idl = dct;
        if (is_const_expr) {
            Token cat;

            /*
             * We want to disallow pointers values to initialize
             * long long variables on 32-bit platforms.
             */
            if (!targeting_arch64
            && ((cat=get_type_category(&dest_ty))==TOK_LONG_LONG || cat==TOK_UNSIGNED_LONG_LONG))
                (void)eval_const_expr(e, FALSE, TRUE);
            else
                (void)eval_const_expr(e, FALSE, FALSE);
        }

        /* the same rules as for simple assignment apply */
        if (!can_assign_to(&dest_ty, e))
            ERROR(e, "initializing `%s' with an expression of incompatible type `%s'",
            stringify_type_exp(&dest_ty, FALSE), stringify_type_exp(&e->type, FALSE));
    }
}

void analyze_init_declarator(TypeExp *decl_specs, TypeExp *declarator, int is_func_def)
{
    TypeExp *scs;
    ExternId *prev;
    int has_func_typecat, is_initialized;

    has_func_typecat = declarator->child!=NULL && declarator->child->op==TOK_FUNCTION;
    is_initialized = declarator->attr.e!=NULL && !is_func_def;
    scs = get_sto_class_spec(decl_specs);

    /*
     * 6.7.8
     * #3 The type of the entity to be initialized shall be an array of unknown size ("[]")
     * or an object type that is not a variable length array type.
     */
    if (is_initialized) {
        if (scs!=NULL &&  scs->op==TOK_TYPEDEF) {
            ERROR(declarator, "trying to initialize typedef");
        } else if (has_func_typecat) {
            ERROR(declarator->child, "trying to initialize function type");
        } else if (declarator->child == NULL) {
            TypeExp *ts;

            ts = get_type_spec(decl_specs);
            if (ts->op==TOK_VOID || is_struct_union_enum(ts->op)&&!is_complete(ts->str))
                ERROR(declarator, "trying to initialize variable with incomplete non-array type");
        }
    }

    /* typedef definition? */
    if (scs!=NULL && scs->op==TOK_TYPEDEF)
        return; /* OK */

    if (nesting_level == OUTERMOST_LEVEL) {
        /*
         * File scope.
         */

        /*
         * 6.9
         * #2 The storage-class specifiers auto and register shall not appear in the declaration
         * specifiers in an external declaration.
         */
        if (scs!=NULL && (scs->op==TOK_AUTO||scs->op==TOK_REGISTER))
            ERROR(scs, "file-scope declaration of `%s' specifies `%s'", declarator->str, tok2lex(scs->op));

        /*
         * 6.7
         * #4 All the expressions in an initializer for an object that has static storage
         * duration shall be constant expressions or string literals.
         */
        if (is_initialized)
            analyze_initializer(decl_specs, declarator->child, declarator->attr.e, TRUE);

        /*
         * Check for redefinition, linkage, and type compatibility.
         */
        if ((prev=lookup_external_id(declarator->str)) == NULL) {
            /* first time seeing this identifier */
            if (is_initialized || is_func_def)
                install_external_id(decl_specs, declarator, DEFINED);
            else if (has_func_typecat || scs!=NULL&&scs->op==TOK_EXTERN)
                install_external_id(decl_specs, declarator, REFERENCED);
            else
                install_external_id(decl_specs, declarator, TENTATIVELY_DEFINED);
        } else {
            int link_err = 0;
            TypeExp *prev_scs;

            /* check for redefinition */
            if (is_initialized || is_func_def) {
                if (prev->status == DEFINED)
                    ERROR(declarator, "redefinition of `%s'", declarator->str);
                prev->status = DEFINED;
            }

            /* check linkage */
            prev_scs = get_sto_class_spec(prev->decl_specs);
            if (prev_scs == NULL) {
                if (scs!=NULL && scs->op==TOK_STATIC)
                    /* e.g. int x; ==> static int x; */
                    link_err = 1;
            } else if (prev_scs->op == TOK_EXTERN) {
                if (scs != NULL) {
                    if (scs->op == TOK_STATIC)
                        /* e.g. extern int x; ==> static int x; */
                        link_err = 1;
                } else if (!has_func_typecat && prev->status!=DEFINED) {
                    /* e.g. extern int x; ==> int x; */
                    prev->status = TENTATIVELY_DEFINED;
                }
            } else if (prev_scs->op == TOK_STATIC) {
                if (scs==NULL && !has_func_typecat)
                    /* e.g. static int x; ==> int x; */
                    link_err = 2;
            }
            if (!link_err)
                ;
            else if (link_err == 1)
                ERROR(declarator, "static declaration of `%s' follows non-static declaration", declarator->str);
            else if (link_err == 2)
                ERROR(declarator, "non-static declaration of `%s' follows static declaration", declarator->str);

            /* check type compatibility */
            enforce_type_compatibility(prev->decl_specs, prev->declarator, decl_specs, declarator);

            /* update previous declaration */
            if (is_initialized || is_func_def)
                prev->declarator = declarator;
            if (is_initialized) {
                TypeExp *pts;

                /* analyze_initializer() sets attr.dl (the declaration list) for struct and unions */
                if (declarator->child == NULL
                && ((pts=get_type_spec(prev->decl_specs))->op==TOK_STRUCT || pts->op==TOK_UNION)
                && pts->attr.dl == NULL)
                    pts->attr.dl = get_type_spec(decl_specs)->attr.dl;
            }
        }
    } else {
        /*
         * Block scope.
         */

        /*
         * 6.7.1
         * #5 The declaration of an identifier for a function that has block scope shall
         * have no explicit storage-class specifier other than extern.
         */
        if (has_func_typecat && scs!=NULL && scs->op!=TOK_TYPEDEF && scs->op!=TOK_EXTERN)
            ERROR(declarator->child, "function `%s' declared in block scope cannot have `%s' storage class",
            declarator->str, tok2lex(scs->op));

        if (is_initialized) {
            /*
             * 6.7.8
             * #5 If the declaration of an identifier has block scope, and the identifier has
             * external or internal linkage, the declaration shall have no initializer for the
             * identifier.
             */
            if (scs!=NULL && scs->op==TOK_EXTERN)
                ERROR(declarator, "`extern' variable cannot have an initializer");

            analyze_initializer(decl_specs, declarator->child, declarator->attr.e,
            (scs!=NULL&&scs->op==TOK_STATIC)?TRUE:FALSE);
        }

        if (scs!=NULL && scs->op==TOK_EXTERN || has_func_typecat) {
            if ((prev=lookup_external_id(declarator->str)) == NULL)
                /* first time seeing this identifier */
                install_external_id(decl_specs, declarator, REFERENCED);
            else
                enforce_type_compatibility(prev->decl_specs, prev->declarator, decl_specs, declarator);
        } else {
            int link_ty_err = 0;

            /*
             * 6.7
             * #7 If an identifier for an object is declared with no linkage, the type for
             * the object shall be complete by the end of its declarator, or by the end of
             * its init-declarator if it has an initializer;
             */
            if (declarator->child == NULL) {
                TypeExp *ts;

                ts = get_type_spec(decl_specs);
                if (ts->op==TOK_VOID || is_struct_union_enum(ts->op)&&!is_complete(ts->str))
                    link_ty_err = 1;
            } else if (declarator->child->op==TOK_SUBSCRIPT && declarator->child->attr.e==NULL) {
                link_ty_err = 1;
            }
            if (link_ty_err)
                ERROR(declarator, "`%s' has no linkage and incomplete type", declarator->str);
        }
    }
}

#define MAX_DESCR_STACK 64

static StructDescriptor *struct_descriptor_table[HASH_SIZE];
static StructDescriptor *descriptor_stack[MAX_DESCR_STACK];
static int descr_stack_top = -1;

/*
 * Add a new member to the top descriptor.
 */
void new_struct_member(TypeExp *decl_specs, TypeExp *declarator)
{
    unsigned alignment;
    StructMember *n, *p;

    /* before add, check for duplicate */
    for (p = descriptor_stack[descr_stack_top]->members; p != NULL; p = p->next)
        if (equal(declarator->str, p->id))
            ERROR(declarator, "duplicate member `%s'", declarator->str);

    n = arena_alloc(decl_node_arena, sizeof(StructMember));
    /* set tag and type */
    n->id = declarator->str;
    n->type.decl_specs = decl_specs;
    n->type.idl = declarator->child;
    /* set size */
    n->size = get_sizeof(&n->type);
    /* set an offset that met with the alignment requirements of the member's type */
    alignment = get_alignment(&n->type);
    n->offset = round_up(descriptor_stack[descr_stack_top]->size, alignment);
    /* update struct's overall size */
    descriptor_stack[descr_stack_top]->size = n->offset+n->size;
    /* update struct's alignment */
    if (alignment > descriptor_stack[descr_stack_top]->alignment)
        descriptor_stack[descr_stack_top]->alignment = alignment;
    /* append member */
    n->next = descriptor_stack[descr_stack_top]->members;
    descriptor_stack[descr_stack_top]->members = n;
}

void push_struct_descriptor(TypeExp *ty)
{
    int i;
    char *tag;
    StructDescriptor *n;

    tag = ty->str;

    /*
     * Check for the tricky case where the struct is redefined inside itself.
     * For example
     *      struct A {
     *          struct A {
     *              int x;
     *          } m;
     *      };
     */
    for (i = descr_stack_top; i >= 0; i--)
        if (*tag!='<' && equal(tag, descriptor_stack[i]->tag))
            ERROR(ty, "nested redefinition of `%s %s'", tok2lex(ty->op), tag);

    /* push new descriptor */
    n = arena_alloc(decl_node_arena, sizeof(StructDescriptor));
    n->tag = tag;
    n->size = n->alignment = 0;
    n->members = NULL;
    descriptor_stack[++descr_stack_top] = n;
}

void pop_struct_descriptor(void)
{
    char *tag;
    unsigned h;
    StructDescriptor *n;

    /*
     * Before pop, fetch the descriptor to add it to the struct descriptor table.
     */
    n = descriptor_stack[descr_stack_top];
    --descr_stack_top;
    tag = n->tag;

    /* adjust the overall size to met with alignment requirements */
    n->size = round_up(n->size, n->alignment);

    /*
     * Note that the address itself is hashed and not the string it points to.
     * Because of scope rules the tag does not uniquely identify the struct type.
     */
    h = HASH_VAL2((unsigned long)tag);
    n->next = struct_descriptor_table[h];
    struct_descriptor_table[h] = n;
}

StructDescriptor *lookup_struct_descriptor(char *tag)
{
    StructDescriptor *np;

    for (np = struct_descriptor_table[HASH_VAL2((unsigned long)tag)]; np != NULL; np = np->next)
        if (tag == np->tag)
            break;

    assert(np != NULL);
    return np;
}

StructMember *get_member_descriptor(TypeExp *ty, char *id)
{
    StructMember *m;

    m = lookup_struct_descriptor(ty->str)->members;
    while (m != NULL) {
        if (equal(id, m->id))
            return m;
        m = m->next;
    }
    assert(0);
}

void analyze_struct_declarator(TypeExp *sql, TypeExp *declarator)
{
    int inc_ty_err = 0;

    /* 6.7.2.1
     * #2 A structure or union shall not contain a member with incomplete or function type (hence,
     * a structure shall not contain an instance of itself, but may contain a pointer to an instance
     * of itself) [we don't support flexible array members, so what follows is not important to us]
     */
    analyze_declarator(sql, declarator, FALSE);
    if (declarator->child == NULL) {
        /* not a derived declarator type */
        TypeExp *ts;

        ts = get_type_spec(sql);
        if (is_struct_union_enum(ts->op) && !is_complete(ts->str))
            inc_ty_err = 1;
    } else if (declarator->child->op == TOK_SUBSCRIPT) {
        /* the type category is array, the size expression cannot be missing */
        if (declarator->child->attr.e == NULL)
            inc_ty_err = 1;
    } else if (declarator->child->op == TOK_FUNCTION) {
        ERROR(declarator, "member `%s' declared as a function", declarator->str);
    }
    if (inc_ty_err)
        ERROR(declarator, "member `%s' has incomplete type", declarator->str);
    new_struct_member(sql, declarator);
}

/*
 * If show_decayed is TRUE, arrays are shown as pointers to the element
 * type and function designators are shown as pointers to the function
 * they designate.
 */
char *stringify_type_exp(Declaration *d, int show_decayed)
{
    TypeExp *e;
    char out[256], temp[256], ds[128], *s;

    out[0]='\0', temp[0]='\0', ds[0]='\0';

    e = d->decl_specs;
    while (e != NULL) {
        if (e->op) {
            strcat(ds, tok2lex(e->op));
            if (is_struct_union_enum(e->op)) {
                strcat(ds, " ");
                strcat(ds, e->str);
            }
            if (e->child != NULL) {
                strcat(ds, " ");
            } else if (d->idl != NULL) {
                if (d->idl->op == TOK_ID) {
                    if (d->idl->child != NULL)
                        strcat(ds, " ");
                } else {
                    strcat(ds, " ");
                }
            }
        }
        e = e->child;
    }

    e = d->idl;
    while (e != NULL) {
        if (e->op == TOK_FUNCTION) {
            DeclList *p;

            if (show_decayed)
                strcat(out, "(*)(");
            else
                strcat(out, "(");
            p = e->attr.dl;
            while (p != NULL) {
                char *param;

                param = stringify_type_exp(p->decl, FALSE);
                strcat(out, param);
                free(param);

                p = p->next;
                if (p != NULL)
                    strcat(out, ", ");
            }
            strcat(out, ")");
        } else if (e->op == TOK_SUBSCRIPT) {
            /*if (e->attr.e != NULL)
                sprintf(temp, "%s[%ld]", out, e->attr.e->attr.val);
            else
                sprintf(temp, "%s[]", out);
            strcpy(out, temp);*/
            if (show_decayed) {
                if (e->child!=NULL && (e->child->op==TOK_SUBSCRIPT || e->child->op==TOK_FUNCTION))
                    strcpy(temp, "(*)");
                else
                    strcpy(temp, "*");
            } else {
                if (e->attr.e != NULL)
                    sprintf(temp, "[%lld]", e->attr.e->attr.val);
                else
                    strcpy(temp, "[]");
            }
            strcat(out, temp);
        } else if (e->op == TOK_STAR) {
            if (e->child!=NULL && (e->child->op==TOK_SUBSCRIPT || e->child->op==TOK_FUNCTION)) {
                if (e->attr.el != NULL)
                    sprintf(temp, "(*%s%s)", tok2lex(e->attr.el->op), out);
                else
                    sprintf(temp, "(*%s)", out);
            } else {
                if (e->attr.el != NULL)
                    sprintf(temp, "*%s%s", tok2lex(e->attr.el->op), out);
                else
                    sprintf(temp, "*%s", out);
            }
            strcpy(out, temp);
        } else if (e->op == TOK_ID) {
            /* ... */
        } else if (e->op == TOK_ELLIPSIS) {
            strcpy(out, "...");
        }
        e = e->child;
        show_decayed = FALSE;
    }
    s = malloc(strlen(ds)+strlen(out)+1);
    strcpy(s, ds);
    strcat(s, out);

    return s;
}

static void complete_tentative_definition(TypeExp *decl_specs, TypeExp *declarator)
{
    if (declarator->child == NULL) {
        TypeExp *ts;

        ts = get_type_spec(decl_specs);
        if (ts->op == TOK_VOID)
            ERROR(declarator, "variable has incomplete type `void'");
        else if (is_struct_union_enum(ts->op) && !is_complete(ts->str))
            ERROR(declarator, "tentative definition has type `%s %s' that is never completed",
            tok2lex(ts->op), ts->str);
    } else if (declarator->child->op==TOK_SUBSCRIPT && declarator->child->attr.e==NULL) {
        /*
         * 6.9.2#2
         * [...] If a translation unit contains one or more tentative definitions for an
         * identifier, and the translation unit contains no external definition for that
         * identifier, then the behavior is exactly as if the translation unit contains a
         * file scope declaration of that identifier, with the composite type as of the end
         * of the translation unit, with an initializer equal to 0.
         *
         * 6.9.2#5
         * EXAMPLE 2
         * If at the end of the translation unit containing
         *      int i[];
         * the array i still has incomplete type, the implicit initializer causes it to have
         * one element, which is set to zero on program startup.
         */
        declarator->child->attr.e = new_exec_node();
        declarator->child->attr.e->attr.val = 1;
    }
}

/*
 * Make the list of external declarations that will be used by the code generator.
 * On the way, check for tentatively defined objects making sure to not left any
 * with incomplete type.
 */
void analyze_translation_unit(void)
{
    int i;
    ExternId *first, *last;

    first = last = NULL;
    for (i = 0; i < HASH_SIZE; i++) {
        if (external_declarations[i] != NULL) {
            first = last = external_declarations[i];
            for (; last->next != NULL; last = last->next)
                if (last->status == TENTATIVELY_DEFINED)
                    complete_tentative_definition(last->decl_specs, last->declarator);
            break;
        }
    }
    for (i = i+1; i < HASH_SIZE; i++)
        if ((last->next=external_declarations[i]) != NULL)
            for (; last->next != NULL; last = last->next)
                if (last->status == TENTATIVELY_DEFINED)
                    complete_tentative_definition(last->decl_specs, last->declarator);
    if (last!=NULL && last!=first && last->status==TENTATIVELY_DEFINED)
        complete_tentative_definition(last->decl_specs, last->declarator);
    external_declarations_list = first;
}
