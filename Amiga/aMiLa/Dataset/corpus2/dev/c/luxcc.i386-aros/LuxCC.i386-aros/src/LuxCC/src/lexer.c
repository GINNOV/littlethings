#include "lexer.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "util/util.h"
#include "error.h"
#include "util/arena.h"
#include "luxcc.h"

extern Arena *pre_node_arena;

static PreTokenNode *pre_tok; /* declared global so ERROR can access it */
Arena *lexer_node_arena;
static Arena *lexer_str_arena;

#define ERROR(...)   emit_error(TRUE, pre_tok->src_file, pre_tok->src_line, pre_tok->src_column, __VA_ARGS__)
#define WARNING(...) emit_warning(pre_tok->src_file, pre_tok->src_line, pre_tok->src_column, __VA_ARGS__)

/*
 * Table that contains token-name/lexeme pairs.
 * It's indexed by `Token' enumeration constants.
 * Mainly used for diagnostic messages.
 */
const char *token_table[] = {
    "LBRACKET", "[",
    "RBRACKET", "]",
    "LPAREN", "(",
    "RPAREN", ")",
    "LBRACE", "{",
    "RBRACE", "}",
    "DOT", ".",
    "ARROW", "->",
    "INC", "++",
    "DEC", "--",
    "AMPERSAND", "&",
    "STAR", "*",
    "PLUS", "+",
    "MINUS", "-",
    "COMPLEMENT", "~",
    "NEGATION", "!",
    "DIV", "/",
    "MOD", "%",
    "LSHIFT", "<<",
    "RSHIFT", ">>",
    "LT", "<",
    "GT", ">",
    "LET", "<=",
    "GET", ">=",
    "EQ", "==",
    "NEQ", "!=",
    "BW_XOR", "^",
    "BW_OR", "|",
    "AND", "&&",
    "OR", "||",
    "CONDITIONAL", "?:",
    "COLON", ":",
    "SEMICOLON", ";",
    "ELLIPSIS", "...",
    "COMMA", ",",
    "ASSIGN", "=",
    "MUL_ASSIGN", "*=",
    "DIV_ASSIGN", "/=",
    "MOD_ASSIGN", "%=",
    "PLUS_ASSIGN", "+=",
    "MINUS_ASSIGN", "-=",
    "LSHIFT_ASSIGN", "<<=",
    "RSHIFT_ASSIGN", ">>=",
    "BW_AND_ASSIGN", "&=",
    "BW_XOR_ASSIGN", "^=",
    "BW_OR_ASSIGN", "|=",
    "AUTO", "auto",
    "BREAK", "break",
    "CASE", "case",
    "CHAR", "char",
    "CONST", "const",
    "CONTINUE", "continue",
    "DEFAULT", "default",
    "DO", "do",
    /*"DOUBLE", "double",*/
    "ELSE", "else",
    "ENUM", "enum",
    "EXTERN", "extern",
    /*"FLOAT", "float",*/
    "FOR", "for",
    "GOTO", "goto",
    "IF", "if",
    /*"INLINE", "inline",*/
    "INT", "int",
    "LONG", "long",
    "REGISTER", "register",
    /*"RESTRICT", "restrict",*/
    "RETURN", "return",
    "SHORT", "short",
    "SIGNED", "signed",
    "SIZEOF", "sizeof",
    "STATIC", "static",
    "STRUCT", "struct",
    "SWITCH", "switch",
    "TYPEDEF", "typedef",
    "UNION", "union",
    "UNSIGNED", "unsigned",
    "VOID", "void",
    "VOLATILE", "volatile",
    "WHILE", "while",
    "ID", "identifier",
    "STRLIT", "string literal",
    // "ICONST", "integer constant",
    "ICONST_D", "integer constant",
    "ICONST_DL", "integer constant",
    "ICONST_DLL", "integer constant",
    "ICONST_DU", "integer constant",
    "ICONST_DUL", "integer constant",
    "ICONST_DULL", "integer constant",
    "ICONST_OH", "integer constant",
    "ICONST_OHL", "integer constant",
    "ICONST_OHLL", "integer constant",
    "ICONST_OHU", "integer constant",
    "ICONST_OHUL", "integer constant",
    "ICONST_OHULL", "integer constant",
    "ERROR", "error",
    "EOF", "end-of-file",
    "TYPEDEFNAME", "typedef-name",
    "PRE_INC", "++",
    "POS_INC", "++",
    "PRE_DEC", "--",
    "POS_DEC", "--",
    "SUBSCRIPT", "[]",
    "FUNCTION", "()",
    "UNARY_PLUS", "+",
    "UNARY_MINUS", "-",
    "INDIRECTION", "*",
    "MUL", "*",
    "ADDRESS_OF", "&",
    "BW_AND", "&",
    "CAST", "(type-name)",
    "SIGNED_CHAR", "signed char",
    "UNSIGNED_CHAR", "unsigned char",
    "UNSIGNED_SHORT", "unsigned short",
    "UNSIGNED_LONG", "unsigned long",
    "LONG_LONG", "long long",
    "UNSIGNED_LONG_LONG", "unsigned long long",
    "CONST_VOLATILE", "const volatile",
    "ENUM_CONST", "enumeration constant",
    "INIT_LIST", "initializer list",
    "FUNC_NAME", "__func__",
    "STATIC_ASSERT", "__static_assert",
    "ASM", "__asm",
    "BUILTIN_VA_START", "__builtin_va_start",
    "ALIGNOF", "__alignof__",
};

static const struct Keyword {
    char *str;
    Token tok;
} keywords_table[] = { /* sorted for bsearch() */
    {"__alignof__", TOK_ALIGNOF},
    {"__asm", TOK_ASM},
    {"__builtin_va_start", TOK_BUILTIN_VA_START},
    {"__func__", TOK_FUNC_NAME},
    {"__static_assert", TOK_STATIC_ASSERT},
    {"auto", TOK_AUTO},
    {"break", TOK_BREAK},
    {"case", TOK_CASE},
    {"char", TOK_CHAR},
    {"const", TOK_CONST},
    {"continue", TOK_CONTINUE},
    {"default", TOK_DEFAULT},
    {"do", TOK_DO},
    /*{"double", TOK_DOUBLE},*/
    {"else", TOK_ELSE},
    {"enum", TOK_ENUM},
    {"extern", TOK_EXTERN},
    /*{"float", TOK_FLOAT},*/
    {"for", TOK_FOR},
    {"goto", TOK_GOTO},
    {"if", TOK_IF},
    /*{"inline", TOK_INLINE},*/
    {"int", TOK_INT},
    {"long", TOK_LONG},
    {"register", TOK_REGISTER},
    /*{"restrict", TOK_RESTRICT},*/
    {"return", TOK_RETURN},
    {"short", TOK_SHORT},
    {"signed", TOK_SIGNED},
    {"sizeof", TOK_SIZEOF},
    {"static", TOK_STATIC},
    {"struct", TOK_STRUCT},
    {"switch", TOK_SWITCH},
    {"typedef", TOK_TYPEDEF},
    {"union", TOK_UNION},
    {"unsigned", TOK_UNSIGNED},
    {"void", TOK_VOID},
    {"volatile", TOK_VOLATILE},
    {"while", TOK_WHILE}
};

static int cmp_kw(const void *p1, const void *p2)
{
   struct Keyword *x1 = (struct Keyword *)p1;
   struct Keyword *x2 = (struct Keyword *)p2;

   return strcmp(x1->str, x2->str);
}

static Token lookup_id(char *s)
{
    struct Keyword key, *res;

    key.str = s;
    res = bsearch(&key, keywords_table, NELEMS(keywords_table), sizeof(keywords_table[0]), cmp_kw);
    if (res == NULL)
        return TOK_ID;
    else
        return res->tok;
}

static const struct Punctuator {
    char *str;
    Token tok;
} punctuators_table[] = { /* sorted for bsearch() */
    {"!", TOK_NEGATION},
    {"!=", TOK_NEQ},
    {"%", TOK_REM},
    {"%=", TOK_REM_ASSIGN},
    {"&", TOK_AMPERSAND},
    {"&&", TOK_AND},
    {"&=", TOK_BW_AND_ASSIGN},
    {"(", TOK_LPAREN},
    {")", TOK_RPAREN},
    {"*", TOK_STAR},
    {"*=", TOK_MUL_ASSIGN},
    {"+", TOK_PLUS},
    {"++", TOK_INC},
    {"+=", TOK_PLUS_ASSIGN},
    {",", TOK_COMMA},
    {"-", TOK_MINUS},
    {"--", TOK_DEC},
    {"-=", TOK_MINUS_ASSIGN},
    {"->", TOK_ARROW},
    {".", TOK_DOT},
    {"...", TOK_ELLIPSIS},
    {"/", TOK_DIV},
    {"/=", TOK_DIV_ASSIGN},
    {":", TOK_COLON},
    {";", TOK_SEMICOLON},
    {"<", TOK_LT},
    {"<<", TOK_LSHIFT},
    {"<<=", TOK_LSHIFT_ASSIGN},
    {"<=", TOK_LET},
    {"=", TOK_ASSIGN},
    {"==", TOK_EQ},
    {">", TOK_GT},
    {">=", TOK_GET},
    {">>", TOK_RSHIFT},
    {">>=", TOK_RSHIFT_ASSIGN},
    {"?", TOK_CONDITIONAL},
    {"[", TOK_LBRACKET},
    {"]", TOK_RBRACKET},
    {"^", TOK_BW_XOR},
    {"^=", TOK_BW_XOR_ASSIGN},
    {"{", TOK_LBRACE},
    {"|", TOK_BW_OR},
    {"|=", TOK_BW_OR_ASSIGN},
    {"||", TOK_OR},
    {"}", TOK_RBRACE},
    {"~", TOK_COMPLEMENT},
};

static int cmp_punct(const void *p1, const void *p2)
{
   struct Punctuator *x1 = (struct Punctuator *)p1;
   struct Punctuator *x2 = (struct Punctuator *)p2;

   return strcmp(x1->str, x2->str);
}

static int isodigit(int c)
{
    return (c!='8')&&(c!='9')&&(isdigit(c));
}

static int get_esc_seq_val(char **c)
{
    switch (*(*c)++) {
    case 'n':
        return '\n';
    case 't':
        return '\t';
    case 'v':
        return '\v';
    case 'b':
        return '\b';
    case 'r':
        return '\r';
    case 'f':
        return '\f';
    case 'a':
        return '\a';
    case '\\':
        return '\\';
    case '\?':
        return '\?';
    case '\'':
        return '\'';
    case '\"':
        return '\"';
    case 'x': {
        char buf[16], *p = buf;
        int val;

        if (isxdigit(**c)) {
            do
                *p++=*(*c)++;
            while (isxdigit(**c));
            *p = '\0';
            sscanf(buf, "%x", &val);
            return (char)val; /* See: 6.4.4.4#10 & #12 */
        } else {
            ERROR("expecting hexadecimal digits after \\x");
        }
    }
    default:
        --*c;
        if (isodigit(**c)) {
            char buf[16], *p = buf;
            int val;

            do
                *p++=*(*c)++;
            while (isodigit(**c));
            *p = '\0';
            sscanf(buf, "%o", &val);
            return (char)val; /* See: 6.4.4.4#10 & #12 */
        } else {
            return *(*c)++; /* unknown escape sequence, the backslash is ignored */
        }
    }
}

/* convert escape sequences embedded in a string literal */
static void convert_string(char *s)
{
    unsigned slen;
    char *src, *dest;

    /* remove "" */
    slen = strlen(s);
    memmove(s, s+1, slen-1);
    s[slen-2] = '\0';

    src = dest = s;
    while (*src != '\0') {
        if (*src == '\\') {
            ++src; /* skip \ */
            *dest++ = (char)get_esc_seq_val(&src);
        } else {
            *dest++ = *src++;
        }
    }
    *dest = *src; /* copy '\0' */
}

static Token get_iconst_kind(char *ic)
{
    /*
     * Note: for simplicity, ignore the case of suffixes
     *       and accept 'Ll' and 'lL' as valid.
     */

    enum {
        START,
        INDEC,
        INZOH, /* zero, octal, or hexadecimal */
        INHEX1,
        INHEX2,
        INOCT,
        INLSUF,
        INLLSUF,
        INLLUSUF,
        INUSUF,
        INLUSUF,
        INULSUF,
        INULLSUF,
        INERROR
    };
    char *c;
    int state;
    Token tok;

    c = ic;
    state = START;
    while (TRUE) {
        switch (state) {
        case START: /* the first char is always a digit */
            state = (*c!='0')?INDEC:INZOH;
            break;
        case INDEC:
            tok = TOK_ICONST_D;
            if (isdigit(*c))
                ;
            else if (*c=='l' || *c=='L')
                state = INLSUF;
            else if (*c=='u' || *c=='U')
                state = INUSUF;
            else if (*c=='\0')
                return tok;
            else
                state = INERROR;
            break;
        case INZOH:
            if (isodigit(*c))
                state = INOCT;
            else if (*c=='x' || *c=='X')
                state = INHEX1;
            else if (*c=='l' || *c=='L')
                state = INLSUF;
            else if (*c=='u' || *c=='U')
                state = INUSUF;
            else if (*c=='\0')
                return TOK_ICONST_D;
            else
                state = INERROR;
            break;
        case INHEX1:
            tok = TOK_ICONST_OH;
            if (isxdigit(*c))
                state = INHEX2;
            else
                state = INERROR;
            break;
        case INHEX2:
            if (isxdigit(*c))
                ;
            else if (*c=='l' || *c=='L')
                state = INLSUF;
            else if (*c=='u' || *c=='U')
                state = INUSUF;
            else if (*c == '\0')
                return tok;
            else
                state = INERROR;
            break;
        case INOCT:
            tok = TOK_ICONST_OH;
            if (isodigit(*c))
                ;
            else if (*c=='l' || *c=='L')
                state = INLSUF;
            else if (*c=='u' || *c=='U')
                state = INUSUF;
            else if (*c == '\0')
                return tok;
            else
                state = INERROR;
            break;
        case INLSUF:
            tok = (tok == TOK_ICONST_D) ? TOK_ICONST_DL : TOK_ICONST_OHL;
            if (*c=='u' || *c=='U')
                state = INLUSUF;
            else if (*c=='l' || *c=='L')
                state = INLLSUF;
            else if (*c == '\0')
                return tok;
            else
                state = INERROR;
            break;
        case INLLSUF:
            tok = (tok == TOK_ICONST_DL) ? TOK_ICONST_DLL : TOK_ICONST_OHLL;
            if (*c=='u' || *c=='U')
                state = INLLUSUF;
            else if (*c == '\0')
                return tok;
            else
                state = INERROR;
            break;
        case INUSUF:
            tok = (tok == TOK_ICONST_D) ? TOK_ICONST_DU : TOK_ICONST_OHU;
            if (*c=='l' || *c=='L')
                state = INULSUF;
            else if (*c == '\0')
                return tok;
            else
                state = INERROR;
            break;
        case INULSUF:
            tok = (tok == TOK_ICONST_DU) ? TOK_ICONST_DUL : TOK_ICONST_OHUL;
            if (*c=='l' || *c=='L')
                state = INULLSUF;
            else if (*c == '\0')
                return tok;
            else
                state = INERROR;
            break;
        case INLUSUF:
        case INLLUSUF:
        case INULLSUF:
            if (*c != '\0')
                state = INERROR;
            else if (state == INLUSUF)
                return (tok == TOK_ICONST_DL) ? TOK_ICONST_DUL : TOK_ICONST_OHUL;
            else
                return (tok==TOK_ICONST_DLL||tok==TOK_ICONST_DUL) ? TOK_ICONST_DULL : TOK_ICONST_OHULL;
            break;
        case INERROR:
            ERROR("invalid integer constant `%s'", ic);
            break;
        } /* switch (state) */
        c++;
    } /* while (TRUE) */
}

static TokenNode *new_token(Token token, PreTokenNode *ptok)
{
    TokenNode *temp;

    temp = arena_alloc(lexer_node_arena, sizeof(TokenNode));
    temp->token = token;
    temp->lexeme = ptok->lexeme;
    temp->src_line = ptok->src_line;
    temp->src_column = ptok->src_column;
    temp->src_file = ptok->src_file;
    temp->next = NULL;
    ++stat_number_of_c_tokens;
    return temp;
}

/*
 * Take a sequence of preprocessing tokens and convert it in a sequence
 * of C tokens (roughly translation phases 5, 6, and part of 7 of the
 * standard).
 */
TokenNode *tokenize(PreTokenNode *pre_token_list)
{
    TokenNode *first, *tok;

    lexer_node_arena = arena_new(stat_number_of_pre_tokens*sizeof(TokenNode), FALSE);
    lexer_str_arena = arena_new(1024, FALSE);

    pre_tok = pre_token_list;
    first = tok = malloc(sizeof(TokenNode)); /* dummy node, it's removed before return */
    while (pre_tok != NULL) {
        if (pre_tok->deleted) {
            pre_tok = pre_tok->next;
            continue;
        }

        switch (pre_tok->token) {
        case PRE_TOK_EOF:
            tok->next = new_token(TOK_EOF, pre_tok);
            break;
        case PRE_TOK_PUNCTUATOR: {
            struct Punctuator key, *res;

            key.str = pre_tok->lexeme;
            res = bsearch(&key, punctuators_table, NELEMS(punctuators_table), sizeof(punctuators_table[0]), cmp_punct);
            assert(res != NULL);
            tok->next = new_token(res->tok, pre_tok);
            break;
        }
        case PRE_TOK_NUM:
            tok->next = new_token(get_iconst_kind(pre_tok->lexeme), pre_tok);
            break;
        case PRE_TOK_ID:
            tok->next = new_token(TOK_ID, pre_tok);
            tok->next->token = lookup_id(pre_tok->lexeme);
            break;
        case PRE_TOK_CHACON: {
            char buf[16], *p;

            /*
             * If the character constant has more than
             * one character, set its value to the value
             * of the rightmost character.
             */
            p = pre_tok->lexeme;
            while (*p != '\0') {
                if (*p == '\\') {
                    ++p; /* skip \ */
                    sprintf(buf, "%d", get_esc_seq_val(&p));
                } else {
                    sprintf(buf, "%d", *p);
                    ++p;
                }
            }
            tok->next = new_token(TOK_ICONST_D, pre_tok);
            tok->next->lexeme = arena_alloc(lexer_str_arena, strlen(buf)+1); /* replace prev lexeme */
            strcpy(tok->next->lexeme, buf);
        }
            break;
        case PRE_TOK_STRLIT: {
            PreTokenNode *p;

            tok->next = new_token(TOK_STRLIT, pre_tok);

            /*
             * Concatenate any adjacent strings.
             */
            p = pre_tok->next;
            while (p!=NULL && p->deleted)
                p = p->next;
            if (p!=NULL && p->token==PRE_TOK_STRLIT) {
                int new_len;

                /* get length of concatenated strings */
                new_len = 0, p = pre_tok;
                while (p!=NULL && (p->deleted || p->token==PRE_TOK_STRLIT)) {
                    if (p->token == PRE_TOK_STRLIT) {
                        convert_string(p->lexeme);
                        new_len += strlen(p->lexeme);
                    }
                    p = p->next;
                }
                ++new_len; /* make room for '\0' */

                /* allocate all at one time */
                tok->next->lexeme = arena_alloc(lexer_str_arena, new_len);
                tok->next->lexeme[0] = '\0';

                /* copy the strings to the buffer (pre_tok is
                   left pointing to the last string concatenated) */
                new_len = 0, p = pre_tok;
                while (p!=NULL && (p->deleted || p->token==PRE_TOK_STRLIT)) {
                    if (p->token == PRE_TOK_STRLIT)
                        strcat(tok->next->lexeme, p->lexeme);
                    pre_tok = p;
                    p = p->next;
                }
            } else { /* no adjacent string */
                convert_string(tok->next->lexeme);
            }
            break;
        }
        case PRE_TOK_NL:
            /* new-line token not deleted during preprocessing */
            assert(0);
            break;
        case PRE_TOK_OTHER:
            /*
             * Ignore `other' tokens (`, $, etc).
             */
            if (isprint(*pre_tok->lexeme))
                WARNING("stray `%c' found; ignoring...", *pre_tok->lexeme);
            else
                WARNING("stray `0x%02x' found; ignoring...", *pre_tok->lexeme);
            pre_tok = pre_tok->next;
            continue;
        }
        pre_tok = pre_tok->next;
        tok = tok->next;
    }
    tok = first->next;
    free(first); /* delete dummy node */
    arena_destroy(pre_node_arena);

    return tok;
}
