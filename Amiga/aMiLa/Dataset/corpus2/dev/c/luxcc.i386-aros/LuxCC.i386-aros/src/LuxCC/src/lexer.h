#ifndef LEXER_H_
#define LEXER_H_

#include "pre.h"

typedef enum {
    /*
     * Punctuators:
     *   [ ] ( ) { } . ->
     *   ++ -- & * + - ~ !
     *   / % << >> < > <= >= == != ^ | && ||
     *   ? : ; ... ,
     *   = *= /= %= += -= <<= >>= &= ^= |=
     */
    TOK_LBRACKET,
    TOK_RBRACKET,
    TOK_LPAREN,
    TOK_RPAREN,
    TOK_LBRACE,
    TOK_RBRACE,
    TOK_DOT,
    TOK_ARROW,
    TOK_INC,
    TOK_DEC,
    TOK_AMPERSAND,
    TOK_STAR,
    TOK_PLUS,
    TOK_MINUS,
    TOK_COMPLEMENT,
    TOK_NEGATION,
    TOK_DIV,
    TOK_REM,
    TOK_LSHIFT,
    TOK_RSHIFT,
    TOK_LT,
    TOK_GT,
    TOK_LET,
    TOK_GET,
    TOK_EQ,
    TOK_NEQ,
    TOK_BW_XOR,
    TOK_BW_OR,
    TOK_AND,
    TOK_OR,
    TOK_CONDITIONAL,
    TOK_COLON,
    TOK_SEMICOLON,
    TOK_ELLIPSIS,
    TOK_COMMA,
    TOK_ASSIGN,
    TOK_MUL_ASSIGN,
    TOK_DIV_ASSIGN,
    TOK_REM_ASSIGN,
    TOK_PLUS_ASSIGN,
    TOK_MINUS_ASSIGN,
    TOK_LSHIFT_ASSIGN,
    TOK_RSHIFT_ASSIGN,
    TOK_BW_AND_ASSIGN,
    TOK_BW_XOR_ASSIGN,
    TOK_BW_OR_ASSIGN,
    /*
     * Keywords.
     */
    TOK_AUTO,
    TOK_BREAK,
    TOK_CASE,
    TOK_CHAR,
    TOK_CONST,
    TOK_CONTINUE,
    TOK_DEFAULT,
    TOK_DO,
    /*TOK_DOUBLE,*/
    TOK_ELSE,
    TOK_ENUM,
    TOK_EXTERN,
    /*TOK_FLOAT,*/
    TOK_FOR,
    TOK_GOTO,
    TOK_IF,
    /*TOK_INLINE,*/
    TOK_INT,
    TOK_LONG,
    TOK_REGISTER,
    /*TOK_RESTRICT,*/
    TOK_RETURN,
    TOK_SHORT,
    TOK_SIGNED,
    TOK_SIZEOF,
    TOK_STATIC,
    TOK_STRUCT,
    TOK_SWITCH,
    TOK_TYPEDEF,
    TOK_UNION,
    TOK_UNSIGNED,
    TOK_VOID,
    TOK_VOLATILE,
    TOK_WHILE,
    /*
     * Others
     */
    TOK_ID,
    TOK_STRLIT,
    // TOK_ICONST,
    TOK_ICONST_D,
    TOK_ICONST_DL,
    TOK_ICONST_DLL,
    TOK_ICONST_DU,
    TOK_ICONST_DUL,
    TOK_ICONST_DULL,
    TOK_ICONST_OH,
    TOK_ICONST_OHL,
    TOK_ICONST_OHLL,
    TOK_ICONST_OHU,
    TOK_ICONST_OHUL,
    TOK_ICONST_OHULL,
    TOK_ERROR,
    TOK_EOF,
    TOK_TYPEDEFNAME,
    /*
     * These are declared here for
     * convenience (the lexer doesn't use them).
     */
    /* ++ */
    TOK_PRE_INC,
    TOK_POS_INC,
    /* -- */
    TOK_PRE_DEC,
    TOK_POS_DEC,
    /* [ ] */
    TOK_SUBSCRIPT,
    /* () */
    TOK_FUNCTION,
    /* + */
    TOK_UNARY_PLUS,
    /* - */
    TOK_UNARY_MINUS,
    /* * */
    TOK_INDIRECTION,
    TOK_MUL,
    /* & */
    TOK_ADDRESS_OF,
    TOK_BW_AND,
    /* ( type-name ) */
    TOK_CAST,
    /* types composed of several tokens */
    TOK_SIGNED_CHAR,
    TOK_UNSIGNED_CHAR,
    TOK_UNSIGNED_SHORT,
    TOK_UNSIGNED_LONG,
    TOK_LONG_LONG,
    TOK_UNSIGNED_LONG_LONG,
    TOK_CONST_VOLATILE,
    /* --- */
    TOK_ENUM_CONST,
    TOK_INIT_LIST,
    TOK_FUNC_NAME,
    TOK_STATIC_ASSERT,
    TOK_ASM,
    TOK_BUILTIN_VA_START,
    TOK_ALIGNOF,
} Token;

typedef struct TokenNode TokenNode;
struct TokenNode {
    Token token;
    char *lexeme, *src_file;
    int src_line, src_column;
    TokenNode *next;
};

extern const char *token_table[];
#define tok2lex(tok) (token_table[tok*2+1])

TokenNode *tokenize(PreTokenNode *pre_token_list);

#endif
