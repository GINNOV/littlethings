#ifndef PRE_H_
#define PRE_H_

typedef enum {
    PRE_TOK_EOF,
    PRE_TOK_PUNCTUATOR,
    PRE_TOK_NUM,
    PRE_TOK_ID,
    PRE_TOK_CHACON,
    PRE_TOK_STRLIT,
    PRE_TOK_NL,
    PRE_TOK_OTHER,
    PRE_TOK_MACRO_REENABLER
} PreToken;

typedef struct PreTokenNode PreTokenNode;
struct PreTokenNode {
    PreToken token;
    char *lexeme, *src_file;
    int src_line, src_column;
    char next_char; /* needed to distinguish between
                      "name(" and "name (" in #define */
    char deleted; /* TRUE/FALSE */
    PreTokenNode *next;
};
typedef enum {
    SIMPLE_MACRO,
    PARAMETERIZED_MACRO
} MacroKind;

PreTokenNode *preprocess(char *source_file);
void install_macro(MacroKind kind, char *name, PreTokenNode *rep, PreTokenNode *params);
void add_angle_dir(char *dir);
void add_quote_dir(char *dir);

#endif
