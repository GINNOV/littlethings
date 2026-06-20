#include "parser.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "util/util.h"
#include "decl.h"
#include "expr.h"
#include "stmt.h"
#include "error.h"
#include "util/arena.h"
#include "sassert.h"
#include "luxcc.h"

extern char *current_function_name;
static TokenNode *curr_tok;
static Arena *parser_str_arena;
/*static */Arena *parser_node_arena;

/* objects used to convert "()" into "(void)" */
static Declaration void_ty;
static DeclList void_param;

#define ERROR(...) emit_error(TRUE, curr_tok->src_file, curr_tok->src_line, curr_tok->src_column, __VA_ARGS__)

TypeExp *new_type_exp_node(void)
{
    TypeExp *n;

    n = arena_alloc(parser_node_arena, sizeof(TypeExp));
    n->info = curr_tok;
    ++stat_number_of_ast_nodes;
    return n;
}

Declaration *new_declaration_node(void)
{
    Declaration *n;

    n = arena_alloc(parser_node_arena, sizeof(Declaration));
    ++stat_number_of_ast_nodes;
    return n;
}

DeclList *new_decl_list_node(void)
{
    DeclList *n;

    n = arena_alloc(parser_node_arena, sizeof(DeclList));
    ++stat_number_of_ast_nodes;
    return n;
}

ExecNode *new_exec_node(void)
{
    ExecNode *n;

    n = arena_alloc(parser_node_arena, sizeof(ExecNode));
    n->info = curr_tok;
    ++stat_number_of_ast_nodes;
    return n;
}

static ExternDecl *new_extern_decl_node(void)
{
    ExternDecl *n;

    n = arena_alloc(parser_node_arena, sizeof(ExternDecl));
    ++stat_number_of_ast_nodes;
    return n;
}

static ExecNode *new_stmt_node(StmtKind kind)
{
    ExecNode *n;

    n = new_exec_node();
    n->node_kind = StmtNode;
    n->kind.exp = kind;
    return n;
}

static ExecNode *new_op_node(Token op)
{
    ExecNode *n;

    n = new_exec_node();
    n->node_kind = ExpNode;
    n->kind.exp = OpExp;
    n->attr.op = op;
    return n;
}

static ExecNode *new_pri_exp_node(ExpKind kind)
{
    ExecNode *n;

    n = new_exec_node();
    n->node_kind = ExpNode;
    n->kind.exp = kind;
    return n;
}

static Token lookahead(int i)
{
    TokenNode *p;

    p = curr_tok;
    while (--i /*&& p->token!=TOK_EOF*/)
        p = p->next;
    return p->token;
}

static char *get_lexeme(int i)
{
    TokenNode *p;

    p = curr_tok;
    while (--i /*&& p->token!=TOK_EOF*/)
        p = p->next;
    return p->lexeme;
}

static void match(Token token)
{
    if (curr_tok->token == token)
        curr_tok = curr_tok->next;
    else
        ERROR("expecting `%s'; found `%s'", tok2lex(token), curr_tok->lexeme);
}

/*                                  */
/* Functions that test lookahead(1) */
/*                                  */

static int in_first_storage_class_specifier(void)
{
    switch (lookahead(1)) {
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

static int in_first_type_specifier(void)
{
    switch (lookahead(1)) {
    case TOK_VOID:
    case TOK_CHAR:
    case TOK_SHORT:
    case TOK_INT:
    case TOK_LONG:
    case TOK_SIGNED:
    case TOK_UNSIGNED:
    case TOK_STRUCT:
    case TOK_UNION:
    case TOK_ENUM:
        return TRUE;
    case TOK_ID:
        if (lookahead(2) == TOK_COLON)
            return FALSE; /* label definition */
        return is_typedef_name(get_lexeme(1));
    default:
        return FALSE;
    }
}

static int in_first_type_qualifier(void)
{
    return (lookahead(1)==TOK_CONST || lookahead(1)==TOK_VOLATILE);
}

static int in_first_specifier_qualifier_list(void)
{
    return (in_first_type_specifier() || in_first_type_qualifier());
}

static int in_first_declaration_specifiers(void)
{
    return (in_first_storage_class_specifier()
         || in_first_type_specifier()
         || in_first_type_qualifier());
}

/* recursive parsing functions */
static ExternDecl *translation_unit(void);
static ExternDecl *external_declaration(void);
static Declaration *function_definition(TypeExp *decl_specs, TypeExp *header);
static Declaration *declaration(TypeExp *decl_specs, TypeExp *first_declarator);
static TypeExp *declaration_specifiers(int type_spec_seen);
static TypeExp *init_declarator_list(TypeExp *decl_specs, TypeExp *first_declarator);
static TypeExp *init_declarator(TypeExp *decl_specs, TypeExp *first_declarator);
static TypeExp *storage_class_specifier(void);
static TypeExp *type_specifier(void);
static TypeExp *struct_or_union_specifier(void);
static TypeExp *struct_or_union(void);
static DeclList *struct_declaration_list(void);
static Declaration *struct_declaration(void);
static TypeExp *specifier_qualifier_list(int type_spec_seen);
static TypeExp *struct_declarator_list(TypeExp *sql);
static TypeExp *struct_declarator(TypeExp *sql);
static TypeExp *enum_specifier(void);
static TypeExp *enumerator_list(void);
static TypeExp *enumerator(void);
static TypeExp *enumeration_constant(void);
static TypeExp *type_qualifier(void);
static TypeExp *direct_declarator_postfix(void);
static TypeExp *pointer(void);
static TypeExp *type_qualifier_list(void);
static DeclList *parameter_type_list(void);
static DeclList *parameter_list(void);
static Declaration *parameter_declaration(void);
/*void identifier_list(void);*/
static Declaration *type_name(void);
static TypeExp *typedef_name(void);
static ExecNode *initializer(void);
static ExecNode *initializer_list(void);

typedef enum {
    ABSTRACT_DECLARATOR,
    CONCRETE_DECLARATOR,
    EITHER_DECLARATOR
} DeclaratorCategory;
static TypeExp *concrete_declarator(void);
static TypeExp *abstract_declarator(void);
static TypeExp *declarator(DeclaratorCategory dc);
static TypeExp *direct_declarator(DeclaratorCategory dc);

static ExecNode *statement(int in_loop, int in_switch);
static ExecNode *labeled_statement(int in_loop, int in_switch);
static ExecNode *compound_statement(int new_scope, int in_loop, int in_switch);
static DeclList *declaration_list(void);
static ExecNode *statement_list(int in_loop, int in_switch);
static ExecNode *expression_statement(void);
static ExecNode *selection_statement(int in_loop, int in_switch);
static ExecNode *iteration_statement(int in_switch);
static ExecNode *jump_statement(int in_loop, int in_switch);

static ExecNode *conditional_expression(void);
static ExecNode *assignment_expression(void);
static ExecNode *constant_expression(void);
static ExecNode *expression(void);
static ExecNode *logical_OR_expression(void);
static ExecNode *logical_AND_expression(void);
static ExecNode *inclusive_OR_expression(void);
static ExecNode *exclusive_OR_expression(void);
static ExecNode *AND_expression(void);
static ExecNode *equality_expression(void);
static ExecNode *relational_expression(void);
static ExecNode *shift_expression(void);
static ExecNode *additive_expression(void);
static ExecNode *multiplicative_expression(void);
static ExecNode *cast_expression(void);
static ExecNode *unary_expression(void);
static ExecNode *postfix_expression(void);
static ExecNode *postfix(void);
static ExecNode *primary_expression(void);
static ExecNode *argument_expression_list(void);

// =============================================================================
// External definitions
// =============================================================================

/*
 * translation_unit = external_declaration { external_declaration } EOF
 */
ExternDecl *translation_unit(void)
{
    ExternDecl *n, *temp;

    n = temp = external_declaration();
    while (lookahead(1) != TOK_EOF) {
        temp->sibling = external_declaration();
        temp = temp->sibling;
    }
    match(TOK_EOF);
    analyze_translation_unit();
    return n;
}

/*
 * external_declaration = function_definition |
 *                        declaration
 */
ExternDecl *external_declaration(void)
{
    ExternDecl *e;
    TypeExp *p, *q;

    e = new_extern_decl_node();
    e->sibling = NULL;

    p = declaration_specifiers(FALSE);
    analyze_decl_specs(p);
    q = (lookahead(1) != TOK_SEMICOLON) ? concrete_declarator() : NULL;

    if (lookahead(1) == TOK_LBRACE) {
        e->kind = FUNCTION_DEFINITION;
        e->d = function_definition(p, q);
    } else {
        e->kind = DECLARATION;
        e->d = declaration(p, q);
    }
    return e;
}

/*
 * function_definition = declaration_specifiers declarator compound_statement
 */
Declaration *function_definition(TypeExp *decl_specs, TypeExp *header)
{
    /*ExternId *ed;*/
    Declaration *f;

    f = new_declaration_node();
    f->decl_specs = decl_specs;
    f->idl = header;
    restore_scope(); /* restore parameters' scope */
    analyze_function_definition(f);
    f->idl->attr.e = compound_statement(FALSE, FALSE, FALSE);

    /*if ((ed=lookup_external_id(f->idl->str)) != NULL)
        ed->declarator->attr.e = f->idl->attr.e;*/

    pop_scope();
    resolve_gotos();
    empty_label_table();

    return f;
}

// =============================================================================
// Declarations
// =============================================================================

/*
 * declaration = declaration_specifiers [ init_declarator_list ] ";"
 */
Declaration *declaration(TypeExp *decl_specs, TypeExp *first_declarator)
{
    Declaration *d;

    d = new_declaration_node();
    d->idl = NULL;
    if (decl_specs != NULL) { /* declaration() was called from external_declaration() */
        d->decl_specs = decl_specs;
    } else {
        d->decl_specs = declaration_specifiers(FALSE);
        analyze_decl_specs(d->decl_specs);
    }
    if (first_declarator!=NULL || lookahead(1)!=TOK_SEMICOLON)
        d->idl = init_declarator_list(d->decl_specs, first_declarator);
    else
        ; /* empty declaration */
    match(TOK_SEMICOLON);
    return d;
}

/*
 * declaration_specifiers = storage_class_specifier [ declaration_specifiers ] |
 *                          type_specifier [ declaration_specifiers ] |
 *                          type_qualifier [ declaration_specifiers ]
 */
TypeExp *declaration_specifiers(int type_spec_seen)
{
    TypeExp *n;

    if (in_first_storage_class_specifier())
        n = storage_class_specifier();
    else if (in_first_type_specifier())
        n = type_specifier(), type_spec_seen = TRUE;
    else if (in_first_type_qualifier())
        n = type_qualifier();
    else
        ERROR("expecting declaration-specifier");
    /*
     * static const type_t; // null declaration
     *                 ^
     *             typedef name
     *
     * static const int type_t; // `int' disables typedef names
     *                    ^
     *                identifier
     *
     * If a typedef name is redeclared the declaration-specifiers
     * of the declaration must contain a type-specifier.
     */
    if (in_first_declaration_specifiers() && (lookahead(1)!=TOK_ID || !type_spec_seen))
        n->child = declaration_specifiers(type_spec_seen);
    return n;
}

/*
 * init_declarator_list =  init_declarator { "," init_declarator }
 */
TypeExp *init_declarator_list(TypeExp *decl_specs, TypeExp *first_declarator)
{
    TypeExp *n, *temp;

    if (get_type_spec(decl_specs)->op != TOK_TYPEDEFNAME) {
        n = temp = init_declarator(decl_specs, first_declarator);
        while (lookahead(1) == TOK_COMMA) {
            match(TOK_COMMA);
            temp->sibling = init_declarator(decl_specs, NULL);
            temp = temp->sibling;
        }
    } else {
        TypeExp *unmod_ds = dup_decl_specs(decl_specs);

        n = temp = init_declarator(decl_specs, first_declarator);
        while (lookahead(1) == TOK_COMMA) {
            match(TOK_COMMA);
            temp->sibling = init_declarator(dup_decl_specs(unmod_ds), NULL);
            temp = temp->sibling;
        }
    }
    return n;
}

/*
 * init_declarator = declarator [ "=" initializer ]
 */
TypeExp *init_declarator(TypeExp *decl_specs, TypeExp *first_declarator)
{

    TypeExp *n;

    n = (first_declarator == NULL) ? concrete_declarator() : first_declarator;
    analyze_declarator(decl_specs, n, TRUE);
    if (lookahead(1) == TOK_ASSIGN) {
        match(TOK_ASSIGN);
        n->attr.e = initializer();
    }
    analyze_init_declarator(decl_specs, n, FALSE);
    return n;
}

/*
 * storage_class_specifier = "typedef" |
 *                           "extern" |
 *                           "static" |
 *                           "auto" |
 *                           "register"
 *
 * Assume in_first_storage_class_specifier() returned TRUE.
 */
TypeExp *storage_class_specifier(void)
{
    TypeExp *s;

    s = new_type_exp_node();
    s->op = lookahead(1);
    match(s->op);
    return s;
}

/*
 * type_specifier = "void" |
 *                  "char" |
 *                  "short" |
 *                  "int" |
 *                  "long" |
 *                  "float" |
 *                  "double" |
 *                  "signed" |
 *                  "unsigned" |
 *                  struct_or_union_specifier |
 *                  enum_specifier |
 *                  typedef_name
 *
 * Assume in_first_type_specifier() returned TRUE.
 */
TypeExp *type_specifier(void)
{
    TypeExp *n;

    switch (lookahead(1)) {
    case TOK_VOID:
    case TOK_CHAR:
    case TOK_SHORT:
    case TOK_INT:
    case TOK_LONG:
    case TOK_SIGNED:
    case TOK_UNSIGNED:
        n = new_type_exp_node();
        n->op = lookahead(1);
        match(n->op);
        break;
    case TOK_STRUCT:
    case TOK_UNION:
        n = struct_or_union_specifier();
        break;
    case TOK_ENUM:
        n = enum_specifier();
        break;
    case TOK_ID:
        n = typedef_name();
        break;
    default:
        assert(0);
        break;
    }
    return n;
}

/*
 * struct_or_union_specifier = struct_or_union [ identifier ] "{" struct_declaration_list "}" |
 *                             struct_or_union identifier
 */
TypeExp *struct_or_union_specifier(void)
{
    TypeExp *n;

    n = struct_or_union();
    if (lookahead(1) == TOK_ID) {
        TypeTag *cur, *all;

        n->str = get_lexeme(1);

        cur = lookup_tag(n->str, FALSE);
        all = lookup_tag(n->str, TRUE);
        if (all != NULL) {
            /*
             * A declaration of the identifier as a tag
             * is visible in this or an enclosing scope.
             */
            if (cur==NULL && (lookahead(2)==TOK_SEMICOLON||lookahead(2)==TOK_LBRACE)) {
                /*
                 * A declaration of the identifier as a tag is not visible in the current
                 * scope, and the declaration is of the form
                 *      struct-or-union identifier ";"
                 * or
                 *      struct-or-union identifier "{" struct-declaration-list "}"
                 */
                install_tag(n); /* new incomplete type */
            } else {
                if (n->op != all->type->op)
                    ERROR("use of `%s' with tag type that does not match previous declaration", n->str);
                n->str = all->type->str; /* this allows to check for type compatibility through pointers comparison */
            }
        } else {
            install_tag(n); /* new incomplete type */
        }
        match(TOK_ID);
        if (lookahead(1) == TOK_LBRACE) {
            if (cur!=NULL && cur->type->attr.dl!=NULL)
                ERROR("redefinition of `%s %s'", tok2lex(n->op), n->str);
            push_struct_descriptor(n);
            match(TOK_LBRACE);
            n->attr.dl = struct_declaration_list();
            match(TOK_RBRACE); /* the type is complete now */
            if (cur != NULL)
                cur->type = n; /* update the previous incomplete declaration */
            pop_struct_descriptor();
        }
    } else if (lookahead(1) == TOK_LBRACE) {
        n->str = arena_alloc(parser_str_arena, sizeof("<anonymous>"));
        strcpy(n->str, "<anonymous>");
        push_struct_descriptor(n);
        match(TOK_LBRACE);
        n->attr.dl = struct_declaration_list();
        match(TOK_RBRACE);
        pop_struct_descriptor();
    } else {
        ERROR("expecting identifier or struct-declaration-list");
    }
    return n;
}

/*
 * struct_or_union = "struct" | "union"
 */
TypeExp *struct_or_union(void)
{
    TypeExp *n;

    n = new_type_exp_node();
    n->op = lookahead(1);
    if (n->op == TOK_STRUCT)
        match(TOK_STRUCT);
    else
        match(TOK_UNION);
    return n;
}

/*
 * struct_declaration_list = struct_declaration { struct_declaration }
 */
DeclList *struct_declaration_list(void)
{
    DeclList *n, *temp;

    n = temp = new_decl_list_node();
    n->decl = struct_declaration();
    n->next = NULL;
    while (in_first_specifier_qualifier_list()) {
        temp->next = new_decl_list_node();
        temp = temp->next;
        temp->decl = struct_declaration();
        temp->next = NULL;
    }
    return n;
}

/*
 * struct_declaration = specifier_qualifier_list struct_declarator_list ";"
 */
Declaration *struct_declaration(void)
{
    Declaration *n;

    n = new_declaration_node();
    n->decl_specs = specifier_qualifier_list(FALSE);
    analyze_decl_specs(n->decl_specs);
    n->idl = struct_declarator_list(n->decl_specs);
    match(TOK_SEMICOLON);
    return n;
}

/*
 * specifier_qualifier_list = ( type_specifier | type_qualifier ) [ specifier_qualifier_list ]
 */
TypeExp *specifier_qualifier_list(int type_spec_seen)
{
    TypeExp *n;

    if (in_first_type_specifier())
        n = type_specifier(), type_spec_seen = TRUE;
    else if (in_first_type_qualifier())
        n = type_qualifier();
    else
        ERROR("expecting type specifier or qualifier; found `%s'", get_lexeme(1));
    if (in_first_specifier_qualifier_list() && (lookahead(1)!=TOK_ID || !type_spec_seen))
        n->child = specifier_qualifier_list(type_spec_seen);
    return n;
}

/*
 * struct_declarator_list = struct_declarator { "," struct_declarator }
 */
TypeExp *struct_declarator_list(TypeExp *sql)
{
    TypeExp *n, *temp;

    if (get_type_spec(sql)->op != TOK_TYPEDEFNAME) {
        n = temp = struct_declarator(sql);
        while (lookahead(1) == TOK_COMMA) {
            match(TOK_COMMA);
            temp->sibling = struct_declarator(sql);
            temp = temp->sibling;
        }
    } else {
        TypeExp *unmod_sql = dup_decl_specs(sql);

        n = temp = struct_declarator(sql);
        while (lookahead(1) == TOK_COMMA) {
            match(TOK_COMMA);
            temp->sibling = struct_declarator(dup_decl_specs(unmod_sql));
            temp = temp->sibling;
        }
    }
    return n;
}

/*
 * struct_declarator = declarator |
 *                     [ declarator ] ":" constant_expression
 */
TypeExp *struct_declarator(TypeExp *sql)
{
    TypeExp *n;

    n = concrete_declarator();
    analyze_struct_declarator(sql, n);
    return n;
}

/*
 * enum_specifier = "enum" [ identifier ] "{" enumerator_list [ "," ] "}" |
 *                  "enum" identifier
 */
TypeExp *enum_specifier(void)
{
    /*
     * Notes:
     *  - Incomplete enums are not standard, but they allow
     *    to handle enums the same way as struct and unions.
     *    GCC also accepts this as an extension.
     *  - The allowing of a trailing comma after an enumerator_list
     *    was added with C99.
     */
    TypeExp *n;

    n = new_type_exp_node();
    n->op = lookahead(1);

    match(TOK_ENUM);
    if (lookahead(1) == TOK_ID) {
        TypeTag *cur, *all;

        n->str = get_lexeme(1);

        cur = lookup_tag(n->str, FALSE);
        all = lookup_tag(n->str, TRUE);
        if (all != NULL) {
            /*
             * A declaration of the identifier as a tag
             * is visible in this or an enclosing scope.
             */
            if (cur==NULL && (lookahead(2)==TOK_SEMICOLON||lookahead(2)==TOK_LBRACE)) {
                /*
                 * A declaration of the identifier as a tag is not visible in the current
                 * scope, and the declaration is of the form
                 *      enum identifier ";"
                 * or
                 *      enum identifier "{" enumerator-list "}"
                 */
                install_tag(n); /* new incomplete type */
            } else {
                if (n->op != all->type->op)
                    ERROR("use of `%s' with tag type that does not match previous declaration", n->str);
                n->str = all->type->str;
            }
        } else {
            install_tag(n); /* new incomplete type */
        }
        match(TOK_ID);
        if (lookahead(1) == TOK_LBRACE) {
            if (cur!=NULL && cur->type->attr.el!=NULL)
                ERROR("redefinition of `enum %s'", n->str);
            match(TOK_LBRACE);
            n->attr.el = enumerator_list();
            if (lookahead(1) == TOK_COMMA)
                match(TOK_COMMA);
            match(TOK_RBRACE);
            if (cur != NULL)
                cur->type = n;

        }
    } else if (lookahead(1) == TOK_LBRACE) {
        n->str = arena_alloc(parser_str_arena, sizeof("<anonymous>"));
        strcpy(n->str, "<anonymous>");
        match(TOK_LBRACE);
        n->attr.el = enumerator_list();
        if (lookahead(1) == TOK_COMMA)
            match(TOK_COMMA);
        match(TOK_RBRACE);
    } else {
        ERROR("expecting identifier or enumerator-list");
    }
    return n;
}

/*
 * enumerator_list = enumerator { "," enumerator }
 */
TypeExp *enumerator_list(void)
{
    TypeExp *n, *temp;

    n = temp = enumerator();
    while (lookahead(1)==TOK_COMMA && lookahead(2)!=TOK_RBRACE) {
        match(TOK_COMMA);
        temp->sibling = enumerator();
        temp = temp->sibling;
    }
    reset_enum_val();
    return n;
}

/*
 * enumerator = enumeration_constant [ "=" constant_expression ]
 */
TypeExp *enumerator(void)
{
    TypeExp *n;

    n = enumeration_constant();
    if (lookahead(1) == TOK_ASSIGN) {
        match(TOK_ASSIGN);
        n->attr.e = constant_expression();
    }
    analyze_enumerator(n);
    return n;
}

/*
 * enumeration_constant = identifier
 */
TypeExp *enumeration_constant(void)
{
    TypeExp *n;

    n = new_type_exp_node();
    n->str = get_lexeme(1);
    n->op = TOK_ENUM_CONST;
    match(TOK_ID);
    return n;
}

/*
 * type_qualifier = "const" | "volatile"
 */
TypeExp *type_qualifier(void)
{
    TypeExp *n;

    n = new_type_exp_node();
    n->op = lookahead(1);
    if (n->op == TOK_CONST)
        match(TOK_CONST);
    else
        match(TOK_VOLATILE);
    return n;
}

TypeExp *concrete_declarator(void)
{
    return declarator(CONCRETE_DECLARATOR);
}

TypeExp *abstract_declarator(void)
{
    return declarator(ABSTRACT_DECLARATOR);
}

/*
 * declarator = [ pointer ] direct_declarator
 */
TypeExp *declarator(DeclaratorCategory dc)
{
    TypeExp *n;

    if (lookahead(1) == TOK_STAR) {
        TypeExp *p, *temp;

        p = pointer();
        n = temp = direct_declarator(dc);
        if (temp != NULL) {
            while (temp->child != NULL)
                temp = temp->child;
            temp->child = p;
        } else {
            n = p;
        }
    } else {
        n = direct_declarator(dc);
    }
    return n;
}

/*
 * direct_declarator = [ identifier | "(" declarator ")" ] { direct_declarator_postfix }
 */
TypeExp *direct_declarator(DeclaratorCategory dc)
{
    Token la2;
    TypeExp *n = NULL, *temp = NULL;

    if (lookahead(1) == TOK_ID) {
        if (dc == ABSTRACT_DECLARATOR)
            ERROR("identifier not allowed in abstract-declarator");
        n = temp = new_type_exp_node();
        n->op = TOK_ID;
        n->str = get_lexeme(1);
        match(TOK_ID);
    } else if (lookahead(1)==TOK_LPAREN
    && (la2=lookahead(2))!=TOK_RPAREN
    && (la2==TOK_LPAREN
    || la2==TOK_LBRACKET
    || la2==TOK_STAR
    || la2==TOK_ID && (dc==CONCRETE_DECLARATOR || !is_typedef_name(get_lexeme(2))))) {
        match(TOK_LPAREN);
        n = temp = declarator(dc);
        match(TOK_RPAREN);
    }
    if (n==NULL && dc==CONCRETE_DECLARATOR)
        ERROR("missing identifier in non-abstract-declarator");
    if (lookahead(1)==TOK_LBRACKET || lookahead(1)==TOK_LPAREN) {
        if (temp == NULL) {
            n = temp = direct_declarator_postfix();
            while (lookahead(1)==TOK_LBRACKET || lookahead(1)==TOK_LPAREN) {
                temp->child = direct_declarator_postfix();
                temp = temp->child;
            }
        } else {
            while (temp->child != NULL)
                temp = temp->child;
            do {
                temp->child = direct_declarator_postfix();
                temp = temp->child;
            } while (lookahead(1)==TOK_LBRACKET || lookahead(1)==TOK_LPAREN);
        }
    }
    return n;
}

/*
 * direct_declarator_postfix = "[" [ constant_expression ] "]" |
 *                             "(" parameter_type_list ")"
 */
TypeExp *direct_declarator_postfix(void)
{
    TypeExp *n;

    n = new_type_exp_node();

    if (lookahead(1) == TOK_LBRACKET) {
        n->op = TOK_SUBSCRIPT;
        match(TOK_LBRACKET);
        if (lookahead(1) != TOK_RBRACKET)
            n->attr.e = constant_expression();
        match(TOK_RBRACKET);
    } else /*if (lookahead(1) == TOK_LPAREN)*/ {
        n->op = TOK_FUNCTION;
        match(TOK_LPAREN);
        if (lookahead(1) != TOK_RPAREN) {
            n->attr.dl = parameter_type_list();
        } else {
            /* fake a "(void)" */
            push_scope();
            n->attr.dl = &void_param;
            pop_scope();
        }
        match(TOK_RPAREN);
    }
    return n;
}

/*
 * pointer = "*" [ type_qualifier_list ] [ pointer ]
 */
TypeExp *pointer(void)
{
    TypeExp *n;

    n = new_type_exp_node();
    n->op = lookahead(1);

    /*
     * Example: the declaration
     *      int *const*volatile*z;
     * has the following syntax tree
     * TOK_ID (z)
     *    |
     * TOK_STAR
     *    |
     * TOK_STAR (volatile)
     *    |
     * TOK_STAR (const)
     */
    match(TOK_STAR);
    if (in_first_type_qualifier())
        n->attr.el = type_qualifier_list();
    if (lookahead(1) == TOK_STAR) {
        TypeExp *p, *temp;

        p = temp = pointer();
        while (temp->child != NULL)
            temp = temp->child;
        temp->child = n;
        n = p;
    }
    return n;
}

/*
 * type_qualifier_list = type_qualifier { type_qualifier }
 */
TypeExp *type_qualifier_list(void)
{
    TypeExp *n, *temp;

    n = type_qualifier();
    while (in_first_type_qualifier()) {
        /* condense all qualifiers in a single node */
        temp = type_qualifier();
        if (temp->op != n->op)
            n->op = TOK_CONST_VOLATILE;
    }
    return n;
}

/*
 * parameter_type_list = parameter_list [ "," "..." ]
 */
DeclList *parameter_type_list(void)
{
    DeclList *n, *temp;

    push_scope();
    n = temp = parameter_list();
    pop_scope(); /* restored if function definition */
    if (lookahead(1) == TOK_COMMA) {
        match(TOK_COMMA);
        match(TOK_ELLIPSIS);
        /*
         * Add a node at the end of the parameter list
         * that has TOK_ELLIPSIS as its operator.
         */
        while (temp->next != NULL)
            temp = temp->next;
        temp->next = new_decl_list_node();
        temp = temp->next;
        temp->decl = new_declaration_node();
        temp->decl->idl = new_type_exp_node();
        temp->decl->idl->op = TOK_ELLIPSIS;
        temp->decl->decl_specs = NULL;
    }
    return n;
}

/*
 * parameter_list = parameter_declaration { "," parameter_declaration }
 */
DeclList *parameter_list(void)
{
    DeclList *n, *temp;

    n = temp = new_decl_list_node();
    n->next = NULL;

    n->decl = parameter_declaration();
    while (lookahead(1)==TOK_COMMA && lookahead(2)!=TOK_ELLIPSIS) {
        match(TOK_COMMA);
        temp->next = new_decl_list_node();
        temp = temp->next;
        temp->next = NULL;
        temp->decl = parameter_declaration();
    }
    return n;
}

/*
 * parameter_declaration = declaration_specifiers declarator |
 *                         declaration_specifiers [ abstract_declarator ]
 */
Declaration *parameter_declaration(void)
{
    Declaration *n;

    n = new_declaration_node();
    n->idl = NULL;

    n->decl_specs = declaration_specifiers(FALSE);
    if (lookahead(1)!=TOK_COMMA && lookahead(1)!=TOK_RPAREN) /* FOLLOW(parameter_declaration) = { ",", ")" } */
        n->idl = declarator(EITHER_DECLARATOR);
    analyze_parameter_declaration(n);
    return n;
}

/*
 * identifier_list = identifier { "," identifier }
 */
/*void identifier_list(void)
{
    match(TOK_ID);
    while (lookahead(1) == TOK_COMMA) {
        match(TOK_COMMA);
        match(TOK_ID);
    }
}*/

/*
 * type_name = specifier_qualifier_list [ abstract_declarator ]
 */
Declaration *type_name(void)
{
    Declaration *n;

    n = new_declaration_node();
    n->idl = NULL;

    n->decl_specs = specifier_qualifier_list(FALSE);
    if (lookahead(1) != TOK_RPAREN) /* FOLLOW(type_name) = { ")" } */
        n->idl = abstract_declarator();
    analyze_type_name(n);
    return n;
}

/*
 * typedef_name = identifier
 *
 * Assume in_first_type_specifier() returned TRUE.
 */
TypeExp *typedef_name(void)
{
    TypeExp *n;

    n = new_type_exp_node();
    n->op = TOK_TYPEDEFNAME;
    n->str = get_lexeme(1);
    DEBUG_PRINTF("typedef-name found: `%s'\n", get_lexeme(1));
    match(TOK_ID);
    return n;
}

/*
 * initializer = assignment_expression |
 *               "{" initializer_list [ "," ] "}"
 */
ExecNode *initializer(void)
{
    ExecNode *n;

    if (lookahead(1) == TOK_LBRACE) {
        match(TOK_LBRACE);
        n = new_op_node(TOK_INIT_LIST);
        n->child[0] = initializer_list();
        if (lookahead(1) == TOK_COMMA)
            match(TOK_COMMA);
        match(TOK_RBRACE);
    } else {
        n = assignment_expression();
    }
    return n;
}

/*
 * initializer_list = initializer { "," initializer }
 */
ExecNode *initializer_list(void)
{
    ExecNode *n, *temp;

    n = temp = initializer();
    while (lookahead(1)==TOK_COMMA && lookahead(2)!=TOK_RBRACE) {
        match(TOK_COMMA);
        temp->sibling = initializer();
        temp = temp->sibling;
    }
    return n;
}

// =============================================================================
// Statements
// =============================================================================

/*
 * static_assert_statement = "__static_assert" "(" constant "," ssexpr ")" ";"
 * ssexpr = assignment_expression |
 *          assignment_expression "," type_name
 */
static void static_assert_statement(void)
{
    long c;
    char *ep;
    ExecNode *e;
    Declaration *ty;
    TokenNode *assert_tok;
    int is_modif_lvalue(ExecNode *e);

    assert_tok = curr_tok;
    match(TOK_STATIC_ASSERT);
    match(TOK_LPAREN);
    c = strtol(get_lexeme(1), &ep, 0);
    match(TOK_ICONST_D);
    match(TOK_COMMA);

    switch (c) {
    case _ASSERT_TYPE:
        e = assignment_expression();
        match(TOK_COMMA);
        ty = type_name();
        if (!are_compatible(e->type.decl_specs, e->type.idl, ty->decl_specs, ty->idl, TRUE, FALSE)) {
            curr_tok = assert_tok;
            ERROR("static assertion failed: the types are different");
        }
        break;
    case _ASSERT_IMMUTABLE:
        e = assignment_expression();
        if (is_modif_lvalue(e)) {
            curr_tok = assert_tok;
            ERROR("static assertion failed: the expression is not immutable");
        }
        break;
    default:
        break;
    }

    match(TOK_RPAREN);
    match(TOK_SEMICOLON);
}

/*
 * asm_statement = "__asm" "(" string-literal ")" ";"
 */
static ExecNode *asm_statement(void)
{
    ExecNode *n;

    match(TOK_ASM);
    match(TOK_LPAREN);
    n = new_stmt_node(AsmStmt);
    if (lookahead(1) == TOK_STRLIT)
        n->attr.str = get_lexeme(1);
    match(TOK_STRLIT);
    match(TOK_RPAREN);
    match(TOK_SEMICOLON);
    return n;
}

/*
 * va_buitin_start_statement = "__builtin_va_start" "(" identifier ")" ";"
 */
static ExecNode *va_buitin_start_statement(void)
{
    ExecNode *n;
    TokenNode *va_start_tok;

    va_start_tok = curr_tok;
    match(TOK_BUILTIN_VA_START);
    match(TOK_LPAREN);
    n = new_stmt_node(BuiltinVaStartStmt);
    if ((n->child[0]=assignment_expression())->kind.exp != IdExp) {
        curr_tok = va_start_tok;
        ERROR("__builtin_va_start: va_list object expected");
    }
    match(TOK_RPAREN);
    match(TOK_SEMICOLON);
    return n;
}

/*
 * statement = labeled_statement |
 *             compound_statement |
 *             expression_statement |
 *             selection_statement |
 *             iteration_statement |
 *             jump_statement
 */
ExecNode *statement(int in_loop, int in_switch)
{
start:
    switch (lookahead(1)) {
    case TOK_ASM:
        return asm_statement();
    case TOK_BUILTIN_VA_START:
        return va_buitin_start_statement();
    case TOK_STATIC_ASSERT:
        static_assert_statement();
        goto start;
    case TOK_LBRACE:
        return compound_statement(TRUE, in_loop, in_switch);
    case TOK_IF:
    case TOK_SWITCH:
        return selection_statement(in_loop, in_switch);
    case TOK_WHILE:
    case TOK_DO:
    case TOK_FOR:
        return iteration_statement(in_switch);
    case TOK_GOTO:
    case TOK_CONTINUE:
    case TOK_BREAK:
    case TOK_RETURN:
        return jump_statement(in_loop, in_switch);
    case TOK_CASE:
    case TOK_DEFAULT:
        return labeled_statement(in_loop, in_switch);
    case TOK_ID:
        if (lookahead(2) == TOK_COLON)
            return labeled_statement(in_loop, in_switch);
        /* fall through */
    default: /* expression statement or error */
        return expression_statement();
    }
}

/*
 * labeled_statement = identifier ":" statement |
 *                     "case" constant_expression ":" statement |
 *                     "default" ":" statement
 */
ExecNode *labeled_statement(int in_loop, int in_switch)
{
    ExecNode *n;

    switch (lookahead(1)) {
    case TOK_ID:
        n = new_stmt_node(LabelStmt);
        n->attr.str = get_lexeme(1);
        match(TOK_ID);
        match(TOK_COLON);
        n->child[0] = statement(in_loop, in_switch);
        break;
    case TOK_CASE:
        n = new_stmt_node(CaseStmt);
        match(TOK_CASE);
        n->child[0] = constant_expression();
        match(TOK_COLON);
        n->child[1] = statement(in_loop, in_switch);
        break;
    case TOK_DEFAULT:
        n = new_stmt_node(DefaultStmt);
        match(TOK_DEFAULT);
        match(TOK_COLON);
        n->child[0] = statement(in_loop, in_switch);
        break;
    }
    analyze_labeled_statement(n, in_switch);
    return n;
}

/*
 * compound_statement = "{" [ declaration_list ] [ statement_list ] "}"
 */
ExecNode *compound_statement(int new_scope, int in_loop, int in_switch)
{
    ExecNode *n;

    n = new_stmt_node(CmpndStmt);

    match(TOK_LBRACE);
    if (in_first_declaration_specifiers()) {
        if (new_scope)
            push_scope();
        n->locals = declaration_list();
        n->attr.var.scope = get_curr_scope_id();
    }
    if (lookahead(1) != TOK_RBRACE)
        n->child[0] = statement_list(in_loop, in_switch);
    match(TOK_RBRACE);
    if (new_scope && n->locals!=NULL)
        pop_scope();
    return n;
}

/*
 * declaration_list = declaration { declaration }
 */
DeclList *declaration_list(void)
{
    DeclList *n, *temp;

    n = temp = new_decl_list_node();
    n->next = NULL;

    n->decl = declaration(NULL, NULL);
    while (in_first_declaration_specifiers()) {
        temp->next = new_decl_list_node();
        temp->next->next = NULL;
        temp->next->decl = declaration(NULL, NULL);
        temp = temp->next;
    }
    return n;
}

/*
 * statement_list = statement { statement }
 */
ExecNode *statement_list(int in_loop, int in_switch)
{
    ExecNode *n, *temp;

    n = temp = statement(in_loop, in_switch);
    while (lookahead(1) != TOK_RBRACE) { /* FOLLOW(statement_list) = { "}" } */
        temp->sibling = statement(in_loop, in_switch);
        temp = temp->sibling;
    }
    return n;
}

/*
 * expression_statement = [ expression ] ";"
 */
ExecNode *expression_statement(void)
{
    ExecNode *n;

    n = new_stmt_node(ExpStmt);
    if (lookahead(1) != TOK_SEMICOLON)
        n->child[0] = expression();
    match(TOK_SEMICOLON);
    return n;
}

/*
 * selection_statement = "if" "(" expression ")" statement [ "else" statement ] |
 *                       "switch" "(" expression ")" statement
 */
ExecNode *selection_statement(int in_loop, int in_switch)
{
    ExecNode *n;

    switch (lookahead(1)) {
    case TOK_IF:
        n = new_stmt_node(IfStmt);
        match(TOK_IF);
        match(TOK_LPAREN);
        n->child[0] = expression();
        match(TOK_RPAREN);
        n->child[1] = statement(in_loop, in_switch);
        if (lookahead(1) == TOK_ELSE) {
            match(TOK_ELSE);
            n->child[2] = statement(in_loop, in_switch);
        }
        break;
    case TOK_SWITCH:
        n = new_stmt_node(SwitchStmt);
        match(TOK_SWITCH);
        match(TOK_LPAREN);
        n->child[0] = expression();
        match(TOK_RPAREN);
        increase_switch_nesting_level(n->child[0]);
        n->child[1] = statement(in_loop, TRUE);
        n->attr.val = decrease_switch_nesting_level();
        break;
    }
    analyze_selection_statement(n);
    return n;
}

/*
 * iteration_statement = "while" "(" expression ")" statement |
 *                       "do" statement "while" "(" expression ")" ";" |
 *                       "for" "(" [ expression ] ";" [ expression ] ";" [ expression ] ")" statement
 */
ExecNode *iteration_statement(int in_switch)
{
    ExecNode *n;

    switch (lookahead(1)) {
    case TOK_WHILE:
        n = new_stmt_node(WhileStmt);
        match(TOK_WHILE);
        match(TOK_LPAREN);
        n->child[0] = expression();
        match(TOK_RPAREN);
        n->child[1] = statement(TRUE, in_switch);
        break;
    case TOK_DO:
        n = new_stmt_node(DoStmt);
        match(TOK_DO);
        n->child[1] = statement(TRUE, in_switch);
        match(TOK_WHILE);
        match(TOK_LPAREN);
        n->child[0] = expression();
        match(TOK_RPAREN);
        match(TOK_SEMICOLON);
        break;
    case TOK_FOR:
        n = new_stmt_node(ForStmt);
        match(TOK_FOR);
        match(TOK_LPAREN);
        if (lookahead(1) != TOK_SEMICOLON)
            n->child[1] = expression();
        match(TOK_SEMICOLON);
        if (lookahead(1) != TOK_SEMICOLON)
            n->child[0] = expression();
        match(TOK_SEMICOLON);
        if (lookahead(1) != TOK_RPAREN)
            n->child[2] = expression();
        match(TOK_RPAREN);
        n->child[3] = statement(TRUE, in_switch);
        break;
    }
    analyze_iteration_statement(n);
    return n;
}

/*
 * jump_statement = "goto" identifier ";" |
 *                  "continue" ";" |
 *                  "break" ";" |
 *                  "return" [ expression ] ";"
 */
ExecNode *jump_statement(int in_loop, int in_switch)
{
    ExecNode *n;

    switch (lookahead(1)) {
    case TOK_GOTO:
        n = new_stmt_node(GotoStmt);
        match(TOK_GOTO);
        n->attr.str = get_lexeme(1);
        match(TOK_ID);
        break;
    case TOK_CONTINUE:
        n = new_stmt_node(ContinueStmt);
        match(TOK_CONTINUE);
        break;
    case TOK_BREAK:
        n = new_stmt_node(BreakStmt);
        match(TOK_BREAK);
        break;
    case TOK_RETURN:
        n = new_stmt_node(ReturnStmt);
        match(TOK_RETURN);
        if (lookahead(1) != TOK_SEMICOLON)
            n->child[0] = expression();
        break;
    }
    match(TOK_SEMICOLON);
    analyze_jump_statement(n, in_loop, in_switch);
    return n;
}

// =============================================================================
// Expressions
// =============================================================================

/*
 * constant_expression = conditional_expression
 */
ExecNode *constant_expression(void)
{
    return conditional_expression();
}

/*
 * expression = assignment_expression { "," assignment_expression }
 */
ExecNode *expression(void)
{
    ExecNode *n, *temp;

    n = assignment_expression();
    while (lookahead(1) == TOK_COMMA) {
        temp = new_op_node(TOK_COMMA);
        match(TOK_COMMA);
        temp->child[0] = n;
        temp->child[1] = assignment_expression();
        n = temp;
        analyze_expression(n);
    }
    return n;
}

/*
 * assignment_operator = "=" | "*=" | "/=" | "%=" | "+=" | "-=" | "<<=" | ">>=" | "&=" | "^=" | "|="
 */
#define IS_ASSIGNMENT_OP(tok) (tok>=TOK_ASSIGN && tok<=TOK_BW_OR_ASSIGN)

/*
 * assignment_expression = conditional_expression [ assignment_operator assignment_expression ]
 */
ExecNode *assignment_expression(void)
{
    ExecNode *n, *temp;

    n = conditional_expression();
    if (IS_ASSIGNMENT_OP(lookahead(1))) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = assignment_expression();
        n = temp;
        analyze_assignment_expression(n);
    }
    return n;
}

/*
 * conditional_expression = logical_OR_expression [ "?" expression ":" conditional_expression ]
 */
ExecNode *conditional_expression(void)
{
    ExecNode *n, *temp;

    n = logical_OR_expression();
    if (lookahead(1) == TOK_CONDITIONAL) {
        temp = new_op_node(TOK_CONDITIONAL);
        match(TOK_CONDITIONAL);
        temp->child[0] = n;
        temp->child[1] = expression();
        match(TOK_COLON);
        temp->child[2] = conditional_expression();
        n = temp;
        analyze_conditional_expression(n);
    }
    return n;
}

/*
 * logical_OR_expression = logical_AND_expression { "||" logical_AND_expression }
 */
ExecNode *logical_OR_expression(void)
{
    ExecNode *n, *temp;

    n = logical_AND_expression();
    while (lookahead(1) == TOK_OR) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = logical_AND_expression();
        n = temp;
        analyze_logical_operator(n);
    }
    return n;
}

/*
 * logical_AND_expression = inclusive_OR_expression { "&&" inclusive_OR_expression }
 */
ExecNode *logical_AND_expression(void)
{
    ExecNode *n, *temp;

    n = inclusive_OR_expression();
    while (lookahead(1) == TOK_AND) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = inclusive_OR_expression();
        n = temp;
        analyze_logical_operator(n);
    }
    return n;
}

/*
 * inclusive_OR_expression = exclusive_OR_expression { "|" exclusive_OR_expression }
 */
ExecNode *inclusive_OR_expression(void)
{
    ExecNode *n, *temp;

    n = exclusive_OR_expression();
    while (lookahead(1) == TOK_BW_OR) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = exclusive_OR_expression();
        n = temp;
        analyze_bitwise_operator(n);
    }
    return n;
}

/*
 * exclusive_OR_expression = AND_expression { "^" AND_expression }
 */
ExecNode *exclusive_OR_expression(void)
{
    ExecNode *n, *temp;

    n = AND_expression();
    while (lookahead(1) == TOK_BW_XOR) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = AND_expression();
        n = temp;
        analyze_bitwise_operator(n);
    }
    return n;
}

/*
 * AND_expression = equality_expression { "&" equality_expression }
 */
ExecNode *AND_expression(void)
{
    ExecNode *n, *temp;

    n = equality_expression();
    while (lookahead(1) == TOK_AMPERSAND) {
        temp = new_op_node(TOK_BW_AND);
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = equality_expression();
        n = temp;
        analyze_bitwise_operator(n);
    }
    return n;
}

/*
 * equality_expression = relational_expression { equop relational_expression }
 * equop = "==" | "!="
 */
ExecNode *equality_expression(void)
{
    ExecNode *n, *temp;

    n = relational_expression();
    while (lookahead(1)==TOK_EQ || lookahead(1)==TOK_NEQ) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = relational_expression();
        n = temp;
        analyze_relational_equality_expression(n);
    }
    return n;
}

/*
 * relop = "<" | ">" | "<=" | ">=
 */
#define IS_RELOP(tok) (tok>=TOK_LT && tok<=TOK_GET)

/*
 * relational_expression = shift_expression { relop shift_expression }
 */
ExecNode *relational_expression(void)
{
    ExecNode *n, *temp;

    n = shift_expression();
    while (IS_RELOP(lookahead(1))) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = shift_expression();
        n = temp;
        analyze_relational_equality_expression(n);
    }
    return n;
}

/*
 * shift_expression = additive_expression { shiftop additive_expression }
 * shiftop = "<<" | ">>"
 */
ExecNode *shift_expression(void)
{
    ExecNode *n, *temp;

    n = additive_expression();
    while (lookahead(1)==TOK_LSHIFT || lookahead(1)==TOK_RSHIFT) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = additive_expression();
        n = temp;
        analyze_bitwise_operator(n);
    }
    return n;
}

/*
 * additive_expression = multiplicative_expression { addop multiplicative_expression }
 * addop = "+" | "-"
 */
ExecNode *additive_expression(void)
{
    ExecNode *n, *temp;

    n = multiplicative_expression();
    while (lookahead(1)==TOK_PLUS || lookahead(1)==TOK_MINUS) {
        temp = new_op_node(lookahead(1));
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = multiplicative_expression();
        n = temp;
        analyze_additive_expression(n);
    }
    return n;
}

/*
 * multiplicative_expression = cast_expression { mulop cast_expression }
 * mulop = "*" | "/" | "%"
 */
ExecNode *multiplicative_expression(void)
{
    ExecNode *n, *temp;

    n = cast_expression();
    while (lookahead(1)==TOK_STAR || lookahead(1)==TOK_DIV || lookahead(1)==TOK_REM) {
        temp = new_op_node((lookahead(1)!=TOK_STAR)?lookahead(1):TOK_MUL);
        match(lookahead(1));
        temp->child[0] = n;
        temp->child[1] = cast_expression();
        n = temp;
        analyze_multiplicative_expression(n);
    }
    return n;
}

/*
 * cast_expression = unary_expression |
 *                  "(" type_name ")" cast_expression
 */
ExecNode *cast_expression(void)
{
    ExecNode *n;

    if (lookahead(1) == TOK_LPAREN) {
        TokenNode *temp;

        temp = curr_tok; /* save */
        match(TOK_LPAREN);
        if (in_first_specifier_qualifier_list()) {
            n = new_op_node(TOK_CAST);
            n->child[1] = (ExecNode *)type_name();
            match(TOK_RPAREN);
            n->child[0] = cast_expression();
            analyze_cast_expression(n);
        } else {
            curr_tok = temp; /* restore */
            n = unary_expression();
        }
    } else {
        n = unary_expression();
    }
    return n;
}

/*
 * unary_operator = "&" | "*" | "+" | "-" | "~" | "!"
 */
#define IS_UNARY_OP(tok) (tok>=TOK_AMPERSAND && tok<=TOK_NEGATION)

/*
 * unary_expression = postfix_expression |
 *                    "++" unary_expression |
 *                    "--" unary_expression |
 *                    unary_operator cast_expression |
 *                    "sizeof" unary_expression |
 *                    "sizeof" "(" type_name ")"
 */
ExecNode *unary_expression(void)
{
    ExecNode *n;

    switch (lookahead(1)) {
    case TOK_INC:
        n = new_op_node(TOK_PRE_INC);
        match(TOK_INC);
        n->child[0] = unary_expression();
        break;
    case TOK_DEC:
        n = new_op_node(TOK_PRE_DEC);
        match(TOK_DEC);
        n->child[0] = unary_expression();
        break;
    case TOK_ALIGNOF:
    case TOK_SIZEOF: {
        n = new_op_node(lookahead(1));
        match(lookahead(1));
        if (lookahead(1) == TOK_LPAREN) {
            TokenNode *temp;

            temp = curr_tok; /* save */
            match(TOK_LPAREN);
            if (in_first_specifier_qualifier_list()) {
                n->child[1] = (ExecNode *)type_name();
                match(TOK_RPAREN);
            } else { /* sizeof applied to a parenthesized expression */
                curr_tok = temp; /* restore */
                n->child[0] = unary_expression();
            }
        } else {
            n->child[0] = unary_expression();
        }
        break;
    }
    case TOK_AMPERSAND:
        n = new_op_node(TOK_ADDRESS_OF);
        match(TOK_AMPERSAND);
        n->child[0] = cast_expression();
        break;
    case TOK_STAR:
        n = new_op_node(TOK_INDIRECTION);
        match(TOK_STAR);
        n->child[0] = cast_expression();
        break;
    case TOK_PLUS:
        n = new_op_node(TOK_UNARY_PLUS);
        match(TOK_PLUS);
        n->child[0] = cast_expression();
        break;
    case TOK_MINUS:
        n = new_op_node(TOK_UNARY_MINUS);
        match(TOK_MINUS);
        n->child[0] = cast_expression();
        break;
    case TOK_COMPLEMENT:
    case TOK_NEGATION:
        n = new_op_node(lookahead(1));
        match(lookahead(1));
        n->child[0] = cast_expression();
        break;
    default:
        n = postfix_expression();
        return n;
    }
    analyze_unary_expression(n);
    return n;
}

#define IS_POSTFIX_OP(t) (t==TOK_LBRACKET||t==TOK_LPAREN||t==TOK_DOT||t==TOK_ARROW||t==TOK_INC||t==TOK_DEC)

/*
 * postfix_expression = primary_expression { postfix }
 */
ExecNode *postfix_expression(void)
{
    ExecNode *n, *temp;

    n = temp = primary_expression();
    while (IS_POSTFIX_OP(lookahead(1))) {
        n = postfix();
        n->child[0] = temp;
        analyze_postfix_expression(n);
        temp = n;
    }
    return n;
}

/*
 * postfix = "[" expression "]" |
 *           "(" [ argument_expression_list ] ")" |
 *           "." identifier |
 *           "->" identifier |
 *           "++" |
 *           "--"
 */
ExecNode *postfix(void)
{
    ExecNode *n;

    switch (lookahead(1)) {
    case TOK_LBRACKET:
        n = new_op_node(TOK_SUBSCRIPT);
        match(TOK_LBRACKET);
        n->child[1] = expression();
        match(TOK_RBRACKET);
        break;
    case TOK_LPAREN:
        n = new_op_node(TOK_FUNCTION);
        match(TOK_LPAREN);
        if (lookahead(1) != TOK_RPAREN)
            n->child[1] = argument_expression_list();
        match(TOK_RPAREN);
        break;
    case TOK_DOT:
        n = new_op_node(TOK_DOT);
        match(TOK_DOT);
        n->child[1] = new_pri_exp_node(IdExp);
        n->child[1]->attr.str = get_lexeme(1);
        match(TOK_ID);
        break;
    case TOK_ARROW:
        n = new_op_node(TOK_ARROW);
        match(TOK_ARROW);
        n->child[1] = new_pri_exp_node(IdExp);
        n->child[1]->attr.str = get_lexeme(1);
        match(TOK_ID);
        break;
    case TOK_INC:
        n = new_op_node(TOK_POS_INC);
        match(TOK_INC);
        break;
    case TOK_DEC:
        n = new_op_node(TOK_POS_DEC);
        match(TOK_DEC);
        break;
    }
    return n;
}

/*static void print_attrs(ExecNode *n)
{
    printf("Id Attributes:\n");
    printf("\tidentifier `%s'\n", n->attr.str);
    printf("\tscope=%d\n", n->attr.var.scope);
    printf("\tlinkage=%s\n", (n->attr.var.linkage == LINKAGE_NONE) ? "none"
    : (n->attr.var.linkage == LINKAGE_EXTERNAL) ? "external" : "internal");
    printf("\tstorage duration=%s\n", (n->attr.var.duration == DURATION_AUTO) ? "auto" : "static");
    printf("\tis_param=%d\n", n->attr.var.is_param);
}*/

/*
 * primary_expression = identifier |
 *                      constant |
 *                      string_literal |
 *                      "(" expression ")"
 */
ExecNode *primary_expression(void)
{
    ExecNode *n;

    switch (lookahead(1)) {
#define NON_FATAL_ERROR(...) emit_error(FALSE, curr_tok->src_file, curr_tok->src_line, curr_tok->src_column, __VA_ARGS__)
    case TOK_ID: {
        /*
         * 6.5.1.2:
         * An identifier is a primary expression, provided it has been declared as designating an
         * object (in which case it is an lvalue) or a function (in which case it is a function
         * designator).79)
         * 79) Thus, an undeclared identifier is a violation of the syntax.
         */
        Symbol *s;

        n = new_pri_exp_node(IdExp);
        n->attr.str = get_lexeme(1);
        match(TOK_ID);

        if ((s=lookup_ordinary_id(n->attr.str, TRUE)) != NULL) {
            TypeExp *scs;

            if ((scs=get_sto_class_spec(s->decl_specs))==NULL || scs->op!=TOK_TYPEDEF) {
                set_attributes(n, s);
                /*print_attrs(n);*/
            } else {
                NON_FATAL_ERROR("expecting primary-expression; found typedef-name `%s'", n->attr.str);
                n->type.decl_specs = get_type_node(TOK_ERROR);
            }
        } else {
            NON_FATAL_ERROR("undeclared identifier `%s'", n->attr.str);
            n->type.decl_specs = get_type_node(TOK_ERROR);
        }
        break;
    }
#undef NON_FATAL_ERROR
    case TOK_ICONST_D:      case TOK_ICONST_DL:     case TOK_ICONST_DLL:
    case TOK_ICONST_DU:     case TOK_ICONST_DUL:    case TOK_ICONST_DULL:
    case TOK_ICONST_OH:     case TOK_ICONST_OHL:    case TOK_ICONST_OHLL:
    case TOK_ICONST_OHU:    case TOK_ICONST_OHUL:   case TOK_ICONST_OHULL:
        n = new_pri_exp_node(IConstExp);
        n->attr.str = get_lexeme(1);
        n->child[0] = (ExecNode *)curr_tok->token;
        match(curr_tok->token);
        break;
    case TOK_STRLIT:
        n = new_pri_exp_node(StrLitExp);
        n->attr.str = get_lexeme(1);
        match(TOK_STRLIT);
        break;
    case TOK_FUNC_NAME:
        n = new_pri_exp_node(StrLitExp);
        n->attr.str = arena_alloc(parser_str_arena, strlen(current_function_name)+1);
        strcpy(n->attr.str, current_function_name);
        match(TOK_FUNC_NAME);
        break;
    case TOK_LPAREN:
        match(TOK_LPAREN);
        n = expression();
        match(TOK_RPAREN);
        return n;
    default:
        ERROR("expecting primary-expression; found `%s'", get_lexeme(1));
        break;
    }
    analyze_primary_expression(n);
    return n;
}

/*
 * argument_expression_list = assignment_expression { "," assignment_expression }
 */
ExecNode *argument_expression_list(void)
{
    ExecNode *n, *temp;

    n = temp = assignment_expression();
    while (lookahead(1) == TOK_COMMA) {
        match(TOK_COMMA);
        temp->sibling = assignment_expression();
        temp = temp->sibling;
    }
    return n;
}

static void print_ast(ExternDecl *n);
static FILE *dotfile;

/*
 * Main function of the parser.
 */
ExternDecl *parse(TokenNode *tokens, char *ast_outpath)
{
    ExternDecl *n;

    void_ty.decl_specs = get_type_node(TOK_VOID);
    void_param.decl = &void_ty;
    curr_tok = tokens;
    decl_init();
    stmt_init();
    parser_node_arena = arena_new(4096, TRUE);
    parser_str_arena = arena_new(1024, FALSE);
    n = translation_unit();
    stmt_done();
    if (ast_outpath != NULL) {
        dotfile = fopen(ast_outpath, "wb");
        print_ast(n);
        fclose(dotfile);
    }
    return n;
}

/*
 * AST printer.
 * Emit a DOT definition of an AST.
 */
static int vertex_counter;

static void print_vertex(int vertex, char *label);
static void print_edge(int src_vertex, int dst_vertex, char *label);
static void print_TypeExp_node(TypeExp *n);
static void print_ExecNode_node(ExecNode *n);
static void print_DeclList(DeclList *n);
static void print_initializer_list(ExecNode *n);
static void print_initializer(ExecNode *n);
static void print_declarator(TypeExp *n);
static void print_init_declarator(TypeExp *n);
static void print_init_declarator_list(TypeExp *n);
static void print_declaration_specifiers(TypeExp *n);
static void print_Declaration(Declaration *n);
static void print_function_definition(Declaration *n);

void print_vertex(int vertex, char *label)
{
    if (label != NULL)
        fprintf(dotfile, "V%d[label=\"%s\"];\n", vertex, label);
    else
        fprintf(dotfile, "V%d;\n", vertex);
}

void print_edge(int src_vertex, int dst_vertex, char *label)
{
    if (label != NULL)
        fprintf(dotfile, "V%d -> V%d [label=\" %s\"];\n", src_vertex, dst_vertex, label);
    else
        fprintf(dotfile, "V%d -> V%d;\n", src_vertex, dst_vertex);
}

void print_TypeExp_node(TypeExp *n)
{
    char buf[128];

    switch (n->op) {
    case TOK_ID:
        sprintf(buf, "TypeExp\\n(%s)", n->str);
        break;
    case TOK_STAR:
        sprintf(buf, "TypeExp\\n(*)");
        if (n->attr.el != NULL) {
            print_vertex(++vertex_counter, buf);
            print_edge(vertex_counter, vertex_counter+1, "attr.el");
            print_TypeExp_node(n->attr.el);
            return;
        }
        break;
    case TOK_SUBSCRIPT:
        sprintf(buf, "TypeExp\\n([])");
        if (n->attr.e != NULL) {
            print_vertex(++vertex_counter, buf);
            print_edge(vertex_counter, vertex_counter+1, "attr.e");
            print_ExecNode_node(n->attr.e);
            return;
        }
        break;
    case TOK_FUNCTION:
        sprintf(buf, "TypeExp\\n(())");
        if (n->attr.e != NULL) {
            print_vertex(++vertex_counter, buf);
            print_edge(vertex_counter, vertex_counter+1, "attr.dl");
            print_DeclList(n->attr.dl);
            return;
        }
        break;
    default:
        sprintf(buf, "TypeExp\\n(%s)", tok2lex(n->op));
        break;
    }
    print_vertex(++vertex_counter, buf);
}

void print_ExecNode_node(ExecNode *n)
{
    char buf[128];
    int tmp_vertex;

    if (n->node_kind == StmtNode) {
        switch (n->kind.stmt) {
        case IfStmt:
        case SwitchStmt:
        case WhileStmt:
        case DoStmt:
        case ForStmt:
        case ExpStmt:
        case BreakStmt:
        case ContinueStmt:
        case ReturnStmt:
        case CaseStmt:
        case DefaultStmt: {
            char *lab;

            tmp_vertex = ++vertex_counter;
            switch (n->kind.stmt) {
            case IfStmt:        lab = "ExecNode\\n(if)";        break;
            case SwitchStmt:    lab = "ExecNode\\n(switch)";    break;
            case WhileStmt:     lab = "ExecNode\\n(while)";     break;
            case DoStmt:        lab = "ExecNode\\n(do)";        break;
            case ForStmt:       lab = "ExecNode\\n(for)";       break;
            case ExpStmt:       lab = "ExecNode\\n(exp-stmt)";  break;
            case BreakStmt:     lab = "ExecNode\\n(break)";     break;
            case ContinueStmt:  lab = "ExecNode\\n(continue)";  break;
            case ReturnStmt:    lab = "ExecNode\\n(return)";    break;
            case CaseStmt:      lab = "ExecNode\\n(case)";      break;
            case DefaultStmt:   lab = "ExecNode\\n(default)";   break;
            }
            print_vertex(tmp_vertex, lab);
            if (n->child[0] != NULL) {
                print_edge(tmp_vertex, vertex_counter+1, "child[0]");
                print_ExecNode_node(n->child[0]);
            }
            if (n->child[1]!=NULL && n->kind.stmt!=ReturnStmt) {
                print_edge(tmp_vertex, vertex_counter+1, "child[1]");
                print_ExecNode_node(n->child[1]);
            }
            if (n->child[2] != NULL) {
                print_edge(tmp_vertex, vertex_counter+1, "child[2]");
                print_ExecNode_node(n->child[2]);
            }
            if (n->child[3] != NULL) {
                print_edge(tmp_vertex, vertex_counter+1, "child[3]");
                print_ExecNode_node(n->child[3]);
            }
        }
            return;
        case CmpndStmt:
            tmp_vertex = ++vertex_counter;
            print_vertex(tmp_vertex, "ExecNode\\n({})");
            if (n->locals != NULL) {
                print_edge(tmp_vertex, vertex_counter+1, "locals");
                print_DeclList(n->locals);
            }
            if (n->child[0] != NULL) {
                ExecNode *n2;

                print_edge(tmp_vertex, vertex_counter+1, "child[0]");
                for (n2 = n->child[0]; n2 != NULL; n2 = n2->sibling) {
                    int stmt_vertex = vertex_counter+1;

                    print_ExecNode_node(n2);
                    if (n2->sibling != NULL)
                        print_edge(stmt_vertex, vertex_counter+1, "sibling");
                }
            }
            return;
        case LabelStmt:
            sprintf(buf, "ExecNode\\n(%s:)", n->attr.str);
            print_vertex(++vertex_counter, buf);
            print_edge(vertex_counter, vertex_counter+1, "child[0]");
            print_ExecNode_node(n->child[0]);
            return;
        case GotoStmt:
            sprintf(buf, "ExecNode\\n(goto %s)", n->attr.str);
            print_vertex(++vertex_counter, buf);
            return;
        }
    } else {
        switch (n->kind.exp) {
        case OpExp:
            switch (n->attr.op) {
            case TOK_FUNCTION:
                tmp_vertex = ++vertex_counter;
                print_vertex(tmp_vertex, "ExecNode\\n(())");
                print_edge(tmp_vertex, vertex_counter+1, "child[0]");
                print_ExecNode_node(n->child[0]);
                if (n->child[1] != NULL) {
                    ExecNode *n2;

                    print_edge(tmp_vertex, vertex_counter+1, "child[1]");
                    for (n2 = n->child[1]; n2 != NULL; n2 = n2->sibling) {
                        int arg_vertex = vertex_counter+1;

                        print_ExecNode_node(n2);
                        if (n2->sibling != NULL)
                            print_edge(arg_vertex, vertex_counter+1, "sibling");
                    }
                }
                return;
            case TOK_POS_INC:
            case TOK_POS_DEC:
            case TOK_PRE_INC:
            case TOK_PRE_DEC:
            case TOK_ADDRESS_OF:
            case TOK_INDIRECTION:
            case TOK_UNARY_PLUS:
            case TOK_UNARY_MINUS:
            case TOK_COMPLEMENT:
            case TOK_NEGATION:
                sprintf(buf, "ExecNode\\n(%s)", tok2lex(n->attr.op));
                print_vertex(++vertex_counter, buf);
                print_edge(vertex_counter, vertex_counter+1, "child[0]");
                print_ExecNode_node(n->child[0]);
                return;
            case TOK_CAST:
                tmp_vertex = ++vertex_counter;
                print_vertex(tmp_vertex, "ExecNode\\n(cast)");
                print_edge(tmp_vertex, vertex_counter+1, "child[0]");
                print_ExecNode_node(n->child[0]);
                print_edge(tmp_vertex, vertex_counter+1, "child[1]");
                print_Declaration((Declaration *)n->child[1]);
                return;
            default: /* operator with two/three children */
                tmp_vertex = ++vertex_counter;
                sprintf(buf, "ExecNode\\n(%s)", tok2lex(n->attr.op));
                print_vertex(tmp_vertex, buf);
                print_edge(tmp_vertex, vertex_counter+1, "child[0]");
                print_ExecNode_node(n->child[0]);
                print_edge(tmp_vertex, vertex_counter+1, "child[1]");
                print_ExecNode_node(n->child[1]);
                if (n->attr.op == TOK_CONDITIONAL) {
                    print_edge(tmp_vertex, vertex_counter+1, "child[2]");
                    print_ExecNode_node(n->child[2]);
                }
                return;
            } /* switch (n->attr.op) */
        case IConstExp:
            sprintf(buf, "ExecNode\\n(%llu)", n->attr.uval);
            print_vertex(++vertex_counter, buf);
            return;
        case StrLitExp:
            print_vertex(++vertex_counter, "ExecNode\\n(string-literal)");
            return;
        case IdExp:
            sprintf(buf, "ExecNode\\n(%s)", n->attr.str);
            print_vertex(++vertex_counter, buf);
            return;
        } /* (n->kind.exp) */
    }
}

void print_DeclList(DeclList *n)
{
    for (; n != NULL; n = n->next) {
        int tmp_vertex = ++vertex_counter;

        print_vertex(tmp_vertex, "DeclList");
        print_edge(tmp_vertex, vertex_counter+1, "decl");
        print_Declaration(n->decl);
        if (n->next != NULL)
            print_edge(tmp_vertex, vertex_counter+1, "next");
    }
}

void print_initializer_list(ExecNode *n)
{
    for (; n != NULL; n = n->sibling) {
        int tmp_vertex = vertex_counter+1;

        print_initializer(n);
        if (n->sibling != NULL)
            print_edge(tmp_vertex, vertex_counter+1, "sibling");
    }
}

void print_initializer(ExecNode *n)
{
    if (n->kind.exp==OpExp && n->attr.op==TOK_INIT_LIST) {
        print_vertex(++vertex_counter, "initializer-list");
        print_edge(vertex_counter, vertex_counter+1, "child[0]");
        print_initializer_list(n->child[0]);
    } else {
        print_ExecNode_node(n);
    }
}

void print_declarator(TypeExp *n)
{
    int tmp_vertex = vertex_counter+1;

    print_TypeExp_node(n);
    if (n->child != NULL) {
        print_edge(tmp_vertex, vertex_counter+1, "child");
        print_declarator(n->child);
    }
}

void print_init_declarator(TypeExp *n)
{
    int tmp_vertex = vertex_counter+1;

    print_declarator(n);
    if (n->op==TOK_ID && n->attr.e!=NULL) {
        print_edge(tmp_vertex, vertex_counter+1, "attr.e");
        print_initializer(n->attr.e);
    }
}

void print_init_declarator_list(TypeExp *n)
{
    for (; n != NULL; n = n->sibling) {
        int tmp_vertex = vertex_counter+1;

        print_init_declarator(n);
        if (n->sibling != NULL)
            print_edge(tmp_vertex, vertex_counter+1, "sibling");
    }
}

void print_declaration_specifiers(TypeExp *n)
{
    int tmp_vertex = vertex_counter+1;

    print_TypeExp_node(n);
    if (n->child != NULL) {
        print_edge(tmp_vertex, vertex_counter+1, "child");
        print_declaration_specifiers(n->child);
    }
}

void print_Declaration(Declaration *n)
{
    int tmp_vertex = ++vertex_counter;

    print_vertex(tmp_vertex, "Declaration");
    if (n->decl_specs != NULL) {
        print_edge(tmp_vertex, vertex_counter+1, "decl_specs");
        print_declaration_specifiers(n->decl_specs);
    } else {
        ; /* ellipsis ("...") */
    }
    if (n->idl != NULL) {
        print_edge(tmp_vertex, vertex_counter+1, "idl");
        print_init_declarator_list(n->idl);
    }
}

void print_function_definition(Declaration *n)
{
    int tmp_vertex = ++vertex_counter;

    print_vertex(tmp_vertex, "Declaration");
    print_edge(tmp_vertex, vertex_counter+1, "decl_specs");
    print_declaration_specifiers(n->decl_specs);
    print_edge(tmp_vertex, vertex_counter+1, "idl");
    tmp_vertex = vertex_counter+1;
    print_declarator(n->idl);
    print_edge(tmp_vertex, vertex_counter+1, "attr.e");
    print_ExecNode_node(n->idl->attr.e);
}

void print_ast(ExternDecl *n)
{
    fprintf(dotfile, "digraph {\n");
    for (; n != NULL; n = n->sibling) {
        int tmp_vertex = ++vertex_counter;

        print_vertex(tmp_vertex, "ExternDecl");
        print_edge(tmp_vertex, vertex_counter+1, "d");
        if (n->kind == FUNCTION_DEFINITION)
            print_function_definition(n->d);
        else
            print_Declaration(n->d);
        if (n->sibling != NULL)
            print_edge(tmp_vertex, vertex_counter+1, "sibling");
    }
    fprintf(dotfile, "}\n");
}
