#ifndef PARSER_H_
#define PARSER_H_

#include "lexer.h"

typedef struct ExecNode ExecNode;

/*
 * Nodes that represent non-executable code.
 */
typedef struct TypeExp TypeExp;
typedef struct Declaration Declaration;
typedef struct DeclList DeclList;
typedef struct ExternDecl ExternDecl;

struct TypeExp {
    Token op;
    char *str;        /* struct/union/enum tag or id */
    union {
        DeclList *dl; /* struct declaration list or function parameters */
        ExecNode *e;  /* array size exp, initializer, or function body */
        TypeExp *el;  /* enumerator list or pointer qualifiers */
    } attr;
    TypeExp *child, *sibling;
    TokenNode *info;
};

struct DeclList {
    Declaration *decl;
    DeclList *next;
};

struct Declaration {
    TypeExp *decl_specs;
    TypeExp *idl;     /* init declarator list */
};

typedef enum {
    DECLARATION,
    FUNCTION_DEFINITION
} EDKind;

struct ExternDecl {
    EDKind kind;
    Declaration *d;
    ExternDecl *sibling;
};


/*
 * Nodes representing executable code.
 */
typedef enum {
    StmtNode,
    ExpNode
} ENKind;

typedef enum {
    IfStmt, WhileStmt, DoStmt, ForStmt, BreakStmt, ContinueStmt,
    ReturnStmt, ExpStmt, CmpndStmt, SwitchStmt, CaseStmt, DefaultStmt,
    LabelStmt, GotoStmt, AsmStmt, BuiltinVaStartStmt,
} StmtKind;

typedef enum {
    OpExp, IConstExp, StrLitExp, IdExp
} ExpKind;

enum {
    DURATION_AUTO,
    DURATION_STATIC,
    /*DURATION_ALLOC,*/
    LINKAGE_NONE,
    LINKAGE_EXTERNAL,
    LINKAGE_INTERNAL
};

struct ExecNode {
    ExecNode *child[4];
    ExecNode *sibling;
    DeclList *locals;
    ENKind node_kind;
    union {
        StmtKind stmt;
        ExpKind exp;
    } kind;
    union {
        Token op;
        char *str; /* common to vars and string literals */
        struct {
            char *id;
            int scope;
            char linkage, duration, is_param;
        } var;
        long long val;
        unsigned long long uval;
    } attr;
    Declaration type;
    int nreg; /* number of registers needed to evaluate the expression represented by this node */
    TokenNode *info;
};

ExternDecl *parse(TokenNode *tokens, char *ast_outpath);

TypeExp *new_type_exp_node(void);
ExecNode *new_exec_node(void);
Declaration *new_declaration_node(void);
DeclList *new_decl_list_node(void);

#endif
