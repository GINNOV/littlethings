#include "pre.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include "util/util.h"
#include "imp_lim.h"
#include "error.h"
#include "util/arena.h"
#include "luxcc.h"

#define SRC_FILE            curr_source_file
#define SRC_LINE            curr_line
#define SRC_COLUMN          src_column
#define ERROR(...)          emit_error(TRUE, SRC_FILE, SRC_LINE, SRC_COLUMN, __VA_ARGS__)
#define MACRO_TABLE_SIZE    4093
#define HASH_VAL(s)         (hash(s)%MACRO_TABLE_SIZE)
#define ERR_BUF_SIZ         2048

/* get_token()'s possible states */
typedef enum {
    STATE_START,
    STATE_DONE,
    STATE_INID,
    STATE_INNUM,
    STATE_INCHAR,
    STATE_INSTR,
    STATE_INCOMMENT1,
    STATE_INCOMMENT2,
    STATE_INLINECOMMENT,
    /*STATE_INCMD*/
} State;
typedef enum {
    FIXED_LIST,
    VAR_LIST
} ParaListKind;
typedef struct Macro Macro;

static char *default_angle_dirs[] = {
    "include/",
    "src/lib/include/",
    "/usr/local/lib/luxcc/include/",
};
static int ndefault_angle_dirs = NELEMS(default_angle_dirs);
static char *angle_dirs[64];
static int nangle_dirs;
static char *quote_dirs[64];
static int nquote_dirs;

static struct Macro {
    char *name;
    MacroKind kind;
    PreTokenNode *rep, *params;
    int enabled;
    Macro *next;
} *macro_table[MACRO_TABLE_SIZE];

static char *buf, *curr, *curr_source_file;
static char token_string[MAX_LOG_LINE_LEN+1];
static PreTokenNode *curr_tok;
static int curr_line, curr_column;
static int src_column; /* token's first char column # */
static PreTokenNode *penultimate_node; /* used by #include's code */
static Arena *pre_str_arena;
Arena *pre_node_arena;

static char *dup_lexeme(const char *s)
{
    char *t;
    unsigned len;

    if (!s)
        return NULL;
    len = strlen(s);
    t = arena_alloc(pre_str_arena, len+1);
    memcpy(t, s, len+1);
    return t;
}

static PreTokenNode *new_node(PreToken token, char *lexeme)
{
    PreTokenNode *temp;

    temp = arena_alloc(pre_node_arena, sizeof(PreTokenNode));
    temp->token = token;
    temp->lexeme = dup_lexeme(lexeme);
    temp->next = NULL;
    temp->deleted = FALSE;
    temp->src_line = curr_line;
    temp->src_column = src_column;
    temp->src_file = curr_source_file;
    ++stat_number_of_pre_tokens;
    return temp;
}

static void init(char *file_path)
{
    FILE *fp;
    unsigned flen;

    fp = fopen(file_path, "rb");
    if (fp == NULL)
        TERMINATE("Error reading file `%s'", file_path);

    fseek(fp, 0, SEEK_END);
    flen = ftell(fp);
    rewind(fp);
    curr = buf = malloc(flen+2);
    flen = fread(buf, sizeof(char), flen, fp);
    buf[flen] = '\0';
    fclose(fp);

    /*
     * Set the current file global var. Each token has attached
     * the name of the file from where it was obtained. This is
     * used for diagnostic messages.
     */
    curr_source_file = dup_lexeme(file_path);
}

static char *dupdir(char *dir)
{
    int n;
    char *p;

    n = strlen(dir);
    if (dir[n-1] != '/') {
        p = malloc(n+2);
        strcpy(p, dir);
        strcat(p, "/");
    } else {
        p = malloc(n+1);
        strcpy(p, dir);
    }
    return p;
}

void add_angle_dir(char *dir)
{
    angle_dirs[nangle_dirs++] = dupdir(dir);
}

void add_quote_dir(char *dir)
{
    quote_dirs[nquote_dirs++] = dupdir(dir);
}

static char *search_angle(char *inc_arg)
{
    int i;
    char *path;

    /*
     * 1) Search in the directories specified
     * through '-I' options.
     */
    path = malloc(256);
    for (i = 0; i < nangle_dirs; i++) {
        strcpy(path, angle_dirs[i]);
        strcat(path, inc_arg);
        if (file_exists(path))
            return path;
    }

    /*
     * 2) Search in the default directories.
     */
    for (i = 0; i < ndefault_angle_dirs; i++) {
        strcpy(path, default_angle_dirs[i]);
        strcat(path, inc_arg);
        if (file_exists(path))
            return path;
    }

    /* not found */
    free(path);
    return NULL;
}

static char *search_quote(char *inc_arg)
{
    int i;
    char *p, *path;

    /*
     * 1) Search in the same directory as the file
     * that contains the #include directive.
     */
    p = strrchr(curr_source_file, '/');
    if (p == NULL) {
        /* the file being processed is in the compiler's working directory */
        path = strdup(inc_arg);
    } else {
        int n;

        /* Construct the path. For example if the file being processed
           is src/foo.c and the argument of #include is "foo.h", the
           resulting path is src/foo.h. */
        n = p-curr_source_file+1;
        path = malloc(n+strlen(inc_arg)+1);
        strncpy(path, curr_source_file, n);
        path[n] = '\0';
        strcat(path, inc_arg);
    }
    if (file_exists(path))
        return path;
    else
        free(path);

    /*
     * 2) Search in the directories specified
     * through '-i' options.
     */
    path = malloc(256);
    for (i = 0; i < nquote_dirs; i++) {
        strcpy(path, quote_dirs[i]);
        strcat(path, inc_arg);
        if (file_exists(path))
            return path;
    }

    /*
     * 3) Search in the same places as for "<...>".
     */
    return search_angle(inc_arg);
}

static PreToken lookahead(int i)
{
    PreTokenNode *p;

    p = curr_tok;
    while (/*p!=NULL && */--i)
        p = p->next;
    return p->token;
}

static char *get_lexeme(int i)
{
    PreTokenNode *p;

    p = curr_tok;
    while (/*p!=NULL && */--i)
        p = p->next;
    return p->lexeme;
}

static int get_next_char(void)
{
    if (*curr == '\0')
        return '\0';

    if (*curr == '\r') {
        ++curr;
        if (*curr == '\n') /* DOS EOL */
            ++curr;
        return '\n';
    }

    while (*curr=='\\' && (*(curr+1)=='\n' || *(curr+1)=='\r')) {
        ++curr;
        if (*curr=='\r' && *(curr+1)=='\n')
            ++curr;
        ++curr;
        ++curr_line, curr_column=0;
    }

    return *curr++;
}

static int peek(int n)
{
    char *cp = curr;

next:
    if (*curr == '\0')
        return '\0';

    if (*cp == '\r') {
        ++cp;
        if (*cp == '\n')
            ++cp;
        if (--n)
            goto next;
        return '\n';
    }

    while (*cp=='\\' && (*(cp+1)=='\n' || *(cp+1)=='\r')) {
        ++cp;
        if (*cp=='\r' && *(cp+1)=='\n')
            ++cp;
        ++cp;
    }

    if (--n) {
        ++cp;
        goto next;
    }
    return *cp;
}

/*
 * Return the next token.
 * Start to read at `curr'.
 * The lexeme is left into `token_string[]'.
 */
static PreToken get_token(void)
{
    State state;
    PreToken token;
    int tok_str_ind, save, cb;

    cb = 0; /* consecutive backslashes counter (even = stop, odd = don't stop) */
    tok_str_ind = 0;
    state = STATE_START;

    while (state != STATE_DONE) {
        int c;

        c = get_next_char();
        save = TRUE;
        ++curr_column;

        switch (state) {
        case STATE_START:
            src_column = curr_column-1;
            if (c==' ' || c=='\t' /* add other desired white space chars here */) {
                save = FALSE;
            } else if (isdigit(c)) {
                state = STATE_INNUM;
            } else if (isalpha(c) || (c=='_')) {
                state = STATE_INID;
            } else if (c == '\'') {
                save = FALSE;
                state = STATE_INCHAR;
            } else if (c == '\"') {
                state = STATE_INSTR;
            } else if ((c=='/') && ((peek(1)=='/')||(peek(1)=='*'))) { // /* or //
                save = FALSE;
                if (peek(1) == '/')
                    state = STATE_INLINECOMMENT;
                else
                    state = STATE_INCOMMENT1;
            } else {
                state = STATE_DONE;
                switch (c) {
                case '\0':
                    save = FALSE;
                    token = PRE_TOK_EOF;
                    break;
                case '\n':
                    token = PRE_TOK_NL;
                    ++curr_line, curr_column=0;
                    break;
                /*
                 * single-char punctuators
                 */
                case '(':
                case ')':
                case '[':
                case ']':
                case '{':
                case '}':
                case ';':
                case ',':
                case '\?':
                case ':':
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                /*
                 * multi-char punctuators
                 */
#define ADVANCE() (get_next_char())
#define REWIND()  (--curr_column, --curr)
#define SAVE_AND_ADVANCE() token_string[tok_str_ind++] = (char)c, c = ADVANCE()
                case '+': /* +, ++ or += */
                    if (peek(1)=='+' || peek(1)=='=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '-': /* -, --, -> or -= */
                    if (peek(1)=='-' || peek(1)=='>' || peek(1)=='=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '*': /* * or *= */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '/': /* / or /= */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '%': /* % or %= */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '^': /* ^ or ^= */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '~': /* ~ or ~= */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '=': /* = or == */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '|': /* |, || or |= */
                    if (peek(1)=='|' || peek(1)=='=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '&': /* &, && or &= */
                    if (peek(1)=='&' || peek(1)=='=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '!': /* ! or != */
                    if (peek(1) == '=')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '#': /* # or ## */
                    if (peek(1) == '#')
                        SAVE_AND_ADVANCE();
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '<': /* <, <=, << or <<= */
                    if (peek(1) == '=') {
                        SAVE_AND_ADVANCE();
                    } else if (peek(1) == '<') {
                        SAVE_AND_ADVANCE();
                        if (peek(1) == '=')
                            SAVE_AND_ADVANCE();
                    }
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '>': /* >, >=, >> or >>= */
                    if (peek(1) == '=') {
                        SAVE_AND_ADVANCE();
                    } else if (peek(1) == '>') {
                        SAVE_AND_ADVANCE();
                        if (peek(1) == '=')
                            SAVE_AND_ADVANCE();
                    }
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                case '.': /* . or ... */
                    if (peek(1)=='.' && peek(2)=='.') {
                        SAVE_AND_ADVANCE();
                        SAVE_AND_ADVANCE();
                    }
                    token = PRE_TOK_PUNCTUATOR;
                    break;
                default:
                    /*
                     * In ASCII, characters included in the 'other' group are @, $, `, and
                     * any control characters other than NUL.
                     */
                    token = PRE_TOK_OTHER;
                    break;
                } /* switch (c) */
            }
            break; /* STATE_START */
        case STATE_INNUM:
        case STATE_INID:
            if (!isalpha(c) && !isdigit(c) && (c!='_')) {
                save = FALSE;
                REWIND();
                token = (state==STATE_INNUM)?PRE_TOK_NUM:PRE_TOK_ID;
                state = STATE_DONE;
            }
            break;
        case STATE_INCHAR:
            if (c=='\0' || c=='\n') {
                ERROR("missing terminating \"'\" character");
            } else if (c=='\'' && cb%2==0) {
                if (tok_str_ind == 0) {
                    ERROR("empty character constant");
                } else {
                    save = FALSE;
                    state = STATE_DONE;
                    token = PRE_TOK_CHACON;
                }
            } else if (c == '\\') {
                ++cb;
            } else {
                cb = 0;
            }
            break;
        case STATE_INSTR:
            if (c=='\0' || c=='\n') {
                ERROR("missing terminating '\"' character");
            } if (c=='\"' && cb%2==0) {
                state = STATE_DONE;
                token = PRE_TOK_STRLIT;
            } else if (c == '\\') {
                ++cb;
            } else {
                cb = 0;
            }
            break;
        case STATE_INCOMMENT1:
            save = FALSE;
            if (c == '\0')
                ERROR("unterminated comment");
            else if (c == '*')
                state = STATE_INCOMMENT2;
            else if (c == '\n')
                ++curr_line, curr_column=0;
            break;
        case STATE_INCOMMENT2:
            save = FALSE;
            if (c == '\0') {
                ERROR("unterminated comment");
            } else if (c == '/') {
                state = STATE_START;
            } else if (c != '*') {
                state = STATE_INCOMMENT1;
                if (c == '\n')
                    ++curr_line, curr_column=0;
            }
            break;
        case STATE_INLINECOMMENT:
            save = FALSE;
            if (c == '\n') {
                REWIND();
                state = STATE_START;
            } else if (c == '\0') {
                REWIND();
                state = STATE_START;
            }
            break;
        case STATE_DONE:
        default:
            assert(0);
            break;
        } /* switch (state) */

        if (save) {
            if (tok_str_ind > MAX_LOG_LINE_LEN)
                TERMINATE("Logical line exceeds maximum length of %u characters", MAX_LOG_LINE_LEN);
            token_string[tok_str_ind++] = (char)c;
        }
        if (state == STATE_DONE)
            token_string[tok_str_ind] = '\0';
    } /* while (state != STATE_DONE) */

    return token;
}

/*
 * Tokenize the buffer `buf' and return
 * the resulting chain of tokens.
 */
static PreTokenNode *tokenize(void)
{
    PreToken tok;
    PreTokenNode *n, *p;

    curr_line = 1; /* initialize line counter */
    tok = get_token();
    n = p = penultimate_node = new_node(tok, token_string);
    p->next_char = *curr;

    while (tok != PRE_TOK_EOF) {
        tok = get_token();
        p->next = new_node(tok, token_string);
        p->next->next_char = *curr;
        penultimate_node = p;
        p = p->next;
    }

    /* the file buffer is not needed anymore */
    free(buf);

    return n;
}

#undef SRC_FILE
#undef SRC_LINE
#undef SRC_COLUMN
#define SRC_FILE    curr_tok->src_file
#define SRC_LINE    curr_tok->src_line
#define SRC_COLUMN  curr_tok->src_column

void install_macro(MacroKind kind, char *name, PreTokenNode *rep, PreTokenNode *params)
{
    Macro *np;
    unsigned h;

    h = HASH_VAL(name);
	for(np = macro_table[h]; np != NULL; np = np->next)
		if(np->enabled && equal(name, np->name))
			break;

    if (np == NULL) { /* not found */
        np = malloc(sizeof(Macro));
        np->kind = kind;
        np->name = name;
        np->rep = rep;
        np->enabled = TRUE;
        np->params = params;
        np->next = macro_table[h];
        macro_table[h] = np;
    } else {
        ERROR("macro `%s' redefined", name);
    }
}

static void uninstall_macro(char *name)
{
    unsigned h;
	Macro *np, *prev;

    h = HASH_VAL(name);
	for(np=macro_table[h], prev=NULL;
        np!=NULL && not_equal(name, np->name);
        prev=np, np=np->next);

	if (np == NULL)
        return; /* not found */
    if (prev == NULL)
        macro_table[h] = np->next;
    else
        prev->next = np->next;
    free(np);
}

static Macro *lookup_macro(char *name)
{
	Macro *np;

	for(np = macro_table[HASH_VAL(name)]; np != NULL; np = np->next)
		if(np->enabled && equal(name, np->name))
			return np;
	return NULL;
}

static void reenable_macro(char *name)
{
    Macro *m;

    for(m = macro_table[HASH_VAL(name)]; m != NULL; m = m->next) {
        if(equal(name, m->name)) {
            m->enabled = TRUE;
            break;
        }
    }
}

static char *pre_token_table[] = {
    "EOF", "punctuator",
    "preprocessor number", "identifier",
    "character constant", "string literal",
    "new line", "other"
};

static void match(PreToken x)
{
    if (curr_tok->token == x)
        curr_tok = curr_tok->next;
    else
        ERROR("expecting: `%s'; found: `%s'", pre_token_table[x], curr_tok->lexeme);
}

/* same as match but mark the token as deleted */
static void match2(PreToken x)
{
    if (curr_tok->token == x) {
        curr_tok->deleted = TRUE;
        curr_tok = curr_tok->next;
    } else {
        ERROR("expecting: `%s'; found: `%s'", pre_token_table[x], curr_tok->lexeme);
    }
}

static int is_group_part(void)
{
    /*
     * group_part cannot begin with neither EOF
     * nor #elif nor #else nor #endif.
     */
    if (lookahead(1) == PRE_TOK_EOF
    || (equal(get_lexeme(1), "#")
    && (equal(get_lexeme(2), "elif")
    ||  equal(get_lexeme(2), "else")
    ||  equal(get_lexeme(2), "endif"))))
        return FALSE;
    return TRUE;
}

/* recursive parser functions */
static void group(int skip);
static void group_part(int skip);
static void if_section(int skip);
static int if_group(int skip);
static int elif_groups(int skip);
static int elif_group(int skip);
static void else_group(int skip);
static void endif_line(void);
static void control_line(int skip);
static void pp_tokens(int skip);
static void preprocessing_token(int skip);

static long long pre_eval_expr(void);
static long long pre_eval_cond_expr(void);
static long long pre_eval_OR_expr(void);
static long long pre_eval_AND_expr(void);
static long long pre_eval_bwOR_expr(void);
static long long pre_eval_bwXOR_expr(void);
static long long pre_eval_bwAND_expr(void);
static long long pre_eval_equ_expr(void);
static long long pre_eval_rel_expr(void);
static long long pre_eval_shi_expr(void);
static long long pre_eval_add_expr(void);
static long long pre_eval_mul_expr(void);
static long long pre_eval_una_expr(void);
static long long pre_eval_pri_expr(void);

/*
 * preprocessing_file = [ group ] end_of_file
 */
static void preprocessing_file(void)
{
    if (lookahead(1) != PRE_TOK_EOF)
        group(FALSE);
    match(PRE_TOK_EOF);
}

/*
 * group = group_part { group_part }
 */
void group(int skip)
{
    group_part(skip);
    while (/*lookahead(1)!=PRE_TOK_EOF && */is_group_part())
        group_part(skip);
}

/*
 * group_part = [ pp_tokens ] new_line |
 *              if_section |
 *              control_line
 */
void group_part(int skip)
{
    if (equal(get_lexeme(1), "#")) {
        if (equal(get_lexeme(2), "if")
        ||  equal(get_lexeme(2), "ifdef")
        ||  equal(get_lexeme(2), "ifndef"))
            if_section(skip);
        else
            control_line(skip);
    } else {
        if (lookahead(1) != PRE_TOK_NL)
            pp_tokens(skip);
        match2(PRE_TOK_NL);
    }
}

/*
 * if_section = if_group [ elif_groups ] [ else_group ] endif_line
 */
void if_section(int skip)
{
    int if_cond, elif_cond = 0;

    if_cond = if_group(skip);
    if (equal(get_lexeme(1), "#") && equal(get_lexeme(2), "elif"))
        elif_cond = elif_groups(skip || if_cond);
    if (equal(get_lexeme(1), "#") && equal(get_lexeme(2), "else"))
        else_group(skip || if_cond || elif_cond);
    endif_line();
}

/*
 * if_group = "#" "if" constant_expression new_line [ group ] |
 *            "#" "ifdef" identifier new_line [ group ] |
 *            "#" "ifndef" identifier new_line [ group ]
 */
int if_group(int skip)
{
    long long cond_res;

    /*
     * group_part() confirmed either #if, #ifdef or #ifndef
     */
    match2(PRE_TOK_PUNCTUATOR); /* # */
    if (equal(get_lexeme(1), "if")) {
        match2(PRE_TOK_ID);
        cond_res = pre_eval_expr();
    } else if (equal(get_lexeme(1), "ifdef")) {
        match2(PRE_TOK_ID);
        cond_res = (lookup_macro(get_lexeme(1)) != NULL);
        match2(PRE_TOK_ID);
    } else { /* ifndef */
        match2(PRE_TOK_ID);
        cond_res = (lookup_macro(get_lexeme(1)) == NULL);
        match2(PRE_TOK_ID);
    }
    match2(PRE_TOK_NL);
    /*
     * Skip if the condition evaluated to false or if the
     * if/ifdef/ifndef already is within of a block being skipped.
     */
    skip = (cond_res==0)?1:skip;
    if (is_group_part())
        group(skip);

    return !!cond_res;
}

/*
 * elif_groups = elif_group { elif_group }
 */
int elif_groups(int skip)
{
    int cond_res;

    cond_res = elif_group(skip);
    while (equal(get_lexeme(1), "#") && equal(get_lexeme(2), "elif"))
        if (elif_group(skip || cond_res))
            cond_res = TRUE;

    return cond_res;
}

/*
 * elif_group = "#" "elif" constant_expression new_line [ group ]
 */
int elif_group(int skip)
{
    long long cond_res;

    /*
     * if_section()/elif_groups() confirmed # and elif
     */
    match2(PRE_TOK_PUNCTUATOR);
    match2(PRE_TOK_ID);
    cond_res = pre_eval_expr();
    match2(PRE_TOK_NL);

    skip = (cond_res==0)?1:skip;
    if (is_group_part())
        group(skip);

    return !!cond_res;
}

/*
 * else_group = "#" "else" new_line [ group ]
 */
void else_group(int skip)
{
    /*
     * if_section() confirmed # and else
     */
    match2(PRE_TOK_PUNCTUATOR); /* # */
    match2(PRE_TOK_ID); /* else */
    match2(PRE_TOK_NL);
    if (is_group_part())
        group(skip);
}

/*
 * endif_line = "#" "endif" new_line
 */
void endif_line(void)
{
    if (equal(get_lexeme(1), "#"))
        match2(PRE_TOK_PUNCTUATOR);
    else
        ERROR("`#endif' expected");
    if (equal(get_lexeme(1), "endif"))
        match2(PRE_TOK_ID);
    else
        ERROR("`#endif' expected");
    match2(PRE_TOK_NL);
}

static void simple_define(void);
static void parameterized_define(void);

/*
 * control_line = "#" "include" pp_tokens new_line |
 *                "#" "define" identifier replacement_list new_line |
 *                "#" "define" identifier lparen [ identifier_list ] ")" replacement_list new_line |
 *                "#" "undef" identifier new_line |
 *                "#" "line" pp_tokens new_line |
 *                "#" "error" [ pp_tokens ] new_line |
 *                "#" "pragma" [ pp_tokens ] new_line |
 *                "#" new_line
 */
void control_line(int skip)
{
    if (skip)
        goto bottom;

    /* by group_part() confirmed # */
    match2(PRE_TOK_PUNCTUATOR);

    /*
     * Identify and interpret directive.
     */
    if (equal(get_lexeme(1), "include")) {
        char inc_arg[256], *path;
        PreTokenNode *tokenized_file;

        match2(PRE_TOK_ID);
        /*
         * The only supported forms of the include directive are:
         *      #include "file.h"
         *      #include <file.h>
         */
        if (lookahead(1) == PRE_TOK_STRLIT) {
            curr_source_file = curr_tok->src_file; /* search_quote() uses curr_source_file */
            strcpy(inc_arg, curr_tok->lexeme+1);
            inc_arg[strlen(inc_arg)-1] = '\0';
            if ((path=search_quote(inc_arg)) == NULL)
                ERROR("include: cannot find file `%s'", inc_arg);
            init(path);
            free(path);
            match2(lookahead(1)); /* filename */
        } else if (equal(get_lexeme(1), "<")) {
            match2(PRE_TOK_PUNCTUATOR);
            if (equal(get_lexeme(1), ">"))
                ERROR("include: empty `<>'");
            inc_arg[0] = '\0';
            do {
                if (lookahead(1) == PRE_TOK_NL)
                    ERROR("include: missing closing `>'");
                strcat(inc_arg, get_lexeme(1));
                match2(lookahead(1));
            } while (not_equal(get_lexeme(1), ">"));
            if ((path=search_angle(inc_arg)) == NULL)
                ERROR("include: cannot find file `%s'", inc_arg);
            init(path);
            free(path);
            match2(PRE_TOK_PUNCTUATOR); /* > */
        } else {
            ERROR("include: \"file.h\" or <file.h> expected");
        }
        /* now at new-line... */

        /*
         * Tokenize the file's content and insert the
         * result right after the #include directive.
         */
        tokenized_file = tokenize();
        /* skip included file's EOF token */
        penultimate_node->next = curr_tok->next;
        curr_tok->next = tokenized_file;
    } else if (equal(get_lexeme(1), "define")) {
        match2(PRE_TOK_ID);
        if (lookahead(1) == PRE_TOK_ID) {
            if (curr_tok->next_char == '(')
                parameterized_define();
            else
                simple_define();
        } else {
            ERROR("define: name expected");
        }
    } else if (equal(get_lexeme(1), "undef")) {
        match2(PRE_TOK_ID);
        if (lookahead(1) == PRE_TOK_ID)
            uninstall_macro(get_lexeme(1));
        else
            ERROR("undef: name expected");
    } else if (equal(get_lexeme(1), "error")) {
        char buf[ERR_BUF_SIZ], *cp;

        buf[0] = '\0';
        match(PRE_TOK_ID);
        if (lookahead(1) != PRE_TOK_NL) {
            strcpy(buf, get_lexeme(1));
            cp = buf+strlen(get_lexeme(1));
            match(lookahead(1));
            while (lookahead(1) != PRE_TOK_NL) {
                strcat(cp++, " ");
                strcat(cp, get_lexeme(1));
                cp += strlen(get_lexeme(1));
                match(lookahead(1));
            }
        }
        ERROR("%s", buf);
    } else if (equal(get_lexeme(1), "\n")) {
        ; /* NULL directive */
    /* --> add the remaining directives here <-- */
    } else {
        ERROR("unknown directive `%s'", get_lexeme(1));
    }

bottom:
    /*
     * Mark the rest of the line as deleted.
     */
    while (lookahead(1) != PRE_TOK_NL)
        match2(lookahead(1));
    match2(PRE_TOK_NL);
}

void simple_define(void)
{
    install_macro(SIMPLE_MACRO, get_lexeme(1), curr_tok->next, NULL);
}

void parameterized_define(void)
{
    /*
     * TODO: check for duplicate parameter names.
     */

    PreTokenNode *rep;

    /*
     * #define ABC( a1, a2 ... an   )
     *          ^                   ^
     *    we are here           and must go here
     */
    for (rep = curr_tok->next->next; not_equal(rep->lexeme, ")"); ) {
        if (equal(rep->lexeme, "...")) {
            if (not_equal(rep->next->lexeme, ")"))
                ERROR("`...' not at the end of the parameter list");
        } else if (rep->token != PRE_TOK_ID) {
            ERROR("expecting parameter name");
        }

        rep = rep->next;
        if (equal(rep->lexeme, ",")) {
            rep = rep->next;
            if (equal(rep->lexeme, ")")) /* something like #define A(x,) */
                ERROR("missing parameter name");
        } else if (not_equal(rep->lexeme, ")")) {
            /* otherwise (a,b...) would be considered valid */
            ERROR("expecting parameter name");
        }
    }
    install_macro(PARAMETERIZED_MACRO, get_lexeme(1), rep->next, curr_tok->next->next);
}

/*
 * pp_tokens = preprocessing_token { preprocessing_token }
 */
void pp_tokens(int skip)
{
    preprocessing_token(skip);
    while (lookahead(1) != PRE_TOK_NL) /* FOLLOW(pp_tokens) = { "\n" } */
        preprocessing_token(skip);
}

static void expand_simple_macro(Macro *m);
static void expand_parameterized_macro(Macro *m);

/*
 * preprocessing_token = header_name
 *                       identifier
 *                       pp_number
 *                       character_constant
 *                       string_literal
 *                       punctuator
 *                       each non-white-space character that cannot be one of the above
 */
void preprocessing_token(int skip)
{
    if (skip) {
        match2(lookahead(1));
        return;
    }

    if (lookahead(1) == PRE_TOK_ID) {
        Macro *m;

        if (equal(curr_tok->lexeme, "__FILE__")) {
            /*
             * Note: __FILE__ depends on the compiler's working directory.
             * Example invocations and __FILE__'s value:
             *      (1) luxcc test.c         -> __FILE__="test.c"
             *      (2) luxcc src/test.c     -> __FILE__="src/test.c"
             *      (3) luxcc ../test_file.c -> __FILE__="../test_file.c"
             */
            unsigned n;

            n = strlen(curr_tok->src_file);
            curr_tok->lexeme = arena_alloc(pre_str_arena, n+2+1); /* +2 for "", +1 for '\0' */
            curr_tok->lexeme[0] = '\"';
            strcpy(curr_tok->lexeme+1, curr_tok->src_file);
            curr_tok->lexeme[n+1] = '\"';
            curr_tok->lexeme[n+2] = '\0';
            curr_tok->token = PRE_TOK_STRLIT;
            match(lookahead(1));
        } else if (equal(curr_tok->lexeme, "__LINE__")) {
            char n[11];

            sprintf(n, "%d", curr_tok->src_line);
            curr_tok->lexeme = dup_lexeme(n);
            curr_tok->token = PRE_TOK_NUM;
            match(lookahead(1));
        } else if ((m=lookup_macro(get_lexeme(1))) != NULL) {
            DEBUG_PRINTF("found macro `%s'\n", get_lexeme(1));
            if (m->kind == SIMPLE_MACRO)
                expand_simple_macro(m);
            else
                expand_parameterized_macro(m);
        } else {
            match(lookahead(1));
        }
    } else if (lookahead(1) == PRE_TOK_MACRO_REENABLER) {
        DEBUG_PRINTF("reenabling macro `%s'\n", get_lexeme(1));
        reenable_macro(get_lexeme(1));
        match2(PRE_TOK_MACRO_REENABLER);
    } else {
        match(lookahead(1));
    }
}

static void copy_node_info(PreTokenNode *dest, PreTokenNode *src)
{
    dest->src_file = src->src_file;
    dest->src_line = src->src_line;
    dest->src_column = src->src_column;
}

/* duplicate a replacement list */
static PreTokenNode *dup_rep_list(PreTokenNode *r)
{
    PreTokenNode *new_rep_list, *temp;

    /* test for empty replacement list */
    if (r->token == PRE_TOK_NL)
        return NULL;

    /* make the duplicate */
    new_rep_list = temp = new_node(r->token, r->lexeme);
    copy_node_info(new_rep_list, curr_tok);
    r = r->next;
    while (r->token != PRE_TOK_NL) {
        temp->next = new_node(r->token, r->lexeme);
        copy_node_info(temp->next, curr_tok);
        temp = temp->next;
        r = r->next;
    }
    return new_rep_list;
}

/* expand an object-like macro */
void expand_simple_macro(Macro *m)
{
    PreTokenNode *r, *old_next;

    /* test empty replacement list */
    if ((r=dup_rep_list(m->rep)) == NULL)
        goto empty_rep_list;
    /* insert the replacement list between the identifier and the next token */
    old_next = curr_tok->next;
    curr_tok->next = r;
    while (r->next != NULL)
        r = r->next;
    r->next = new_node(PRE_TOK_MACRO_REENABLER, m->name);
    r->next->next = old_next;
    m->enabled = FALSE; /* disable the macro temporally */
empty_rep_list:
    /* mark the identifier as deleted and advance. */
    match2(lookahead(1));
}

/*
 * Support function for parameterized macro calls.
 * Make a copy of the token string that conform an argument.
 * `kind' modifies the main loop stop condition.
 */
static PreTokenNode *copy_arg(PreTokenNode **a, ParaListKind kind)
{
    int pn; /* parenthesis nesting level counter */
    PreTokenNode *copy, *temp;

    if ((*a)->token==PRE_TOK_PUNCTUATOR && (equal((*a)->lexeme, ",") || equal((*a)->lexeme, ")")))
        ERROR("empty macro argument");

    pn = 0;
    if ((*a)->token==PRE_TOK_PUNCTUATOR && equal((*a)->lexeme, "("))
        ++pn;
    copy = temp = new_node((*a)->token, (*a)->lexeme);
    (*a) = (*a)->next;

    while (pn>0 || ((kind==VAR_LIST||not_equal((*a)->lexeme, ",")) && not_equal((*a)->lexeme, ")"))) {
        if ((*a)->token==PRE_TOK_PUNCTUATOR && equal((*a)->lexeme, "(")) pn++;
        else if ((*a)->token==PRE_TOK_PUNCTUATOR && equal((*a)->lexeme, ")")) pn--;
        else if ((*a)->token == PRE_TOK_EOF) ERROR("missing `)' in macro call");
        temp->next = new_node((*a)->token, (*a)->lexeme);
        temp = temp->next;
        *a = (*a)->next;
    }
    return copy;
}

/*
 * Second support function. Make a copy of an
 * argument created previously with copy_arg().
 */
static PreTokenNode *copy_arg2(PreTokenNode *a, PreTokenNode **last)
{
    PreTokenNode *copy;

    copy = *last = new_node(a->token, a->lexeme);
    a = a->next;

    while (a != NULL) {
        (*last)->next = new_node(a->token, a->lexeme);
        *last = (*last)->next;
        a = a->next;
    }
    return copy;
}

void expand_parameterized_macro(Macro *m)
{
    PreTokenNode *r, *p, *prev, *param, *arg;
    PreTokenNode *par_arg_tab[16][2] = { { NULL } };
    int tab_size = 0, i;

    /*
     * The name of a function-like macro not followed by
     * left parenthesis is not an invocation to the macro.
     */
    arg = curr_tok->next;
    while (arg->token==PRE_TOK_NL || arg->token==PRE_TOK_MACRO_REENABLER) arg = arg->next;
    if (not_equal(arg->lexeme, "(")) {
        match(lookahead(1));
        return;
    }

    // if ((r=dup_rep_list(m->rep)) == NULL)
        // goto empty_rep_list;
    r = dup_rep_list(m->rep);

    param = m->params;
    // arg = curr_tok->next->next; /* ID -> "(" -> first-argument */
    arg = arg->next; /* first-argument */

    /*
     * Associate actual argument token strings
     * with the corresponding formal parameter
     * names.
     */
    while (not_equal(param->lexeme, ")") && not_equal(arg->lexeme, ")")) {
        if (equal(param->lexeme, "...")) {
            par_arg_tab[tab_size][0] = new_node(PRE_TOK_ID, "__VA_ARGS__");
            par_arg_tab[tab_size][1] = copy_arg(&arg, VAR_LIST); /* arg is left pointing to ")" */
            ++tab_size;
            param = param->next; /* advance to ")" */
            break;
        }

        par_arg_tab[tab_size][0] = param;
        par_arg_tab[tab_size][1] = copy_arg(&arg, FIXED_LIST); /* arg is left pointing to "," or ")" */
        ++tab_size;

        param = param->next; /* advance to "," or ")" */

        if (not_equal(param->lexeme, arg->lexeme)) {
            /*
             * Check if it's the case where there are not
             * actual arguments corresponding to '...'.
             * For example:
             *      #define ABC(a,...) a+__VA_ARGS__
             *      ABC(123)
             */
            if (equal(param->lexeme, ",") && equal(param->next->lexeme, "...") /*&& equal(arg->lexeme, ")")*/)
                param = param->next;
            else
                ERROR("argument number mismatch in macro call");
        } else if (not_equal(param->lexeme, ")")) {
            param=param->next, arg=arg->next;
        }
    }

    if (not_equal(param->lexeme, arg->lexeme)) { /* both should be equal to ")" */
        if (not_equal(param->lexeme, "...")) { /* or '...' must not have matching arguments */
            ERROR("argument number mismatch in macro call");
        } else {
            par_arg_tab[tab_size][0] = new_node(PRE_TOK_ID, "__VA_ARGS__");
            par_arg_tab[tab_size][1] = NULL;
            ++tab_size;
        }
    }

    /*int i = 0;
    while (i < tab_size) {
        PreTokenNode *p;

        printf("par=%s ==> arg= ", par_arg_tab[i][0]->lexeme);
        p = par_arg_tab[i][1];
        while (p != NULL)
            printf("%s ->> ", p->lexeme), p=p->next;
        printf("\n");
        ++i;
    }*/

    /*
     * Replace every occurrence of a formal parameter
     * for a copy of the actual argument token sequence
     * associated with it (that is, build the 'expansion'
     * of the macro).
     */
    prev=NULL, p=r;
    while (p != NULL) {
        if (p->token != PRE_TOK_ID) {
            prev=p, p=p->next;
            continue;
        }

        for (i = 0; i < tab_size; i++) {
            if (equal(par_arg_tab[i][0]->lexeme, p->lexeme)) {
                // PreTokenNode *last;

                if (par_arg_tab[i][1] != NULL) {
                    PreTokenNode *last;

                    if (prev != NULL)
                        /* a -> <b -> x> -> c -> NULL */
                        prev->next = copy_arg2(par_arg_tab[i][1], &last);
                    else
                        /* <a -> x> -> b -> c -> NULL */
                        r = copy_arg2(par_arg_tab[i][1], &last);
                    last->next = p->next;
                    /*free(p->lexeme), free(p);*/
                    prev = last;
                    p = last->next;
                } else {
                    /*
                     * `...' doesn't correspond to nothing, make
                     * disappear __VA_ARGS__ from the replacement list.
                     */
                    if (prev != NULL) {
                        /* a -> <b -> > -> c -> NULL */
                        prev->next = p->next;
                        /*free(p->lexeme), free(p);*/
                        p = prev->next;
                    } else {
                        /* <a -> > -> b -> c -> NULL */
                        r = p->next;
                        /*free(p->lexeme), free(p);*/
                        p = r;
                    }
                }
                break;
            }
        }
        if (i == tab_size) /* no match */
            prev=p, p=p->next;
    }

    /*
     * Delete the original copies of the arguments.
     */
    /*for (i = 0; i < tab_size; i++) {
        PreTokenNode *temp;

        if (equal(par_arg_tab[i][0]->lexeme, "__VA_ARGS__")) {
            free(par_arg_tab[i][0]->lexeme);
            free(par_arg_tab[i][0]);
        }

        while (par_arg_tab[i][1] != NULL) {
            temp = par_arg_tab[i][1];
            par_arg_tab[i][1] = par_arg_tab[i][1]->next;
            free(temp->lexeme);
            free(temp);
        }
    }*/
    /*while (r != NULL) {
        printf("r=%s\n", r->lexeme);
        r = r->next;
    }
    exit(0);*/
// empty_rep_list:
    /*
     * Mark the macro call as deleted.
     */
    while (curr_tok != arg) {
        if (curr_tok->token == PRE_TOK_MACRO_REENABLER) {
            DEBUG_PRINTF("reenabling macro `%s'\n", curr_tok->lexeme);
            reenable_macro(curr_tok->lexeme);
        }
        match2(lookahead(1));
    }
    /*
     * Insert the replacement list next
     * to the macro call.
     */
    if (r != NULL) {
        prev->next = new_node(PRE_TOK_MACRO_REENABLER, m->name);
        prev->next->next = curr_tok->next;
        m->enabled = FALSE;
        // prev->next = curr_tok->next;
        curr_tok->next = r;
    }
    match2(lookahead(1)); /* ) */
}

/*
 * Preprocess the source file and any file
 * included through #include, and return a
 * sequence of preprocessing tokens.
 */
PreTokenNode *preprocess(char *source_file)
{
    PreTokenNode *token_list;

    pre_node_arena = arena_new(sizeof(PreTokenNode)*128, FALSE);
    pre_str_arena = arena_new(1024, FALSE);
    init(source_file);
    token_list = curr_tok = tokenize();
    preprocessing_file();
    return token_list;
}

/*                                 */
/* Expression evaluation functions */
/*                                 */

long long pre_eval_expr(void)
{
    return pre_eval_cond_expr();
}

long long pre_eval_cond_expr(void)
{
    long long r;

    r = pre_eval_OR_expr();
    if (equal(get_lexeme(1), "?")) {
        long long e1, e2;

        match2(PRE_TOK_PUNCTUATOR);
        /* [ TOFIX ] both expressions will be evaluated! */
        e1 = pre_eval_expr();
        if (!equal(get_lexeme(1), ":"))
            ERROR("expecting `:'; got `%s'", curr_tok->lexeme);
        match2(PRE_TOK_PUNCTUATOR);
        e2 = pre_eval_cond_expr();
        r = r ? e1 : e2;
    }
    return r;
}

long long pre_eval_OR_expr(void)
{
    long long r;

    /* [ TOFIX ] both expressions will be evaluated! */
    r = pre_eval_AND_expr();
    while (equal(get_lexeme(1), "||")) {
        long long r2;

        match2(PRE_TOK_PUNCTUATOR);
        r2 = pre_eval_AND_expr();
        r = r||r2;
    }
    return r;
}

long long pre_eval_AND_expr(void)
{
    long long r;

    /* [ TOFIX ] both expressions will be evaluated! */
    r = pre_eval_bwOR_expr();
    while (equal(get_lexeme(1), "&&")) {
        long long r2;

        match2(PRE_TOK_PUNCTUATOR);
        r2 = pre_eval_bwOR_expr();
        r = r&&r2;
    }
    return r;
}

long long pre_eval_bwOR_expr(void)
{
    long long r;

    r = pre_eval_bwXOR_expr();
    while (equal(get_lexeme(1), "|")) {
        match2(PRE_TOK_PUNCTUATOR);
        r = r|pre_eval_bwXOR_expr();
    }
    return r;
}

long long pre_eval_bwXOR_expr(void)
{
    long long r;

    r = pre_eval_bwAND_expr();
    while (equal(get_lexeme(1), "^")) {
        match2(PRE_TOK_PUNCTUATOR);
        r = r^pre_eval_bwAND_expr();
    }
    return r;
}

long long pre_eval_bwAND_expr(void)
{
    long long r;

    r = pre_eval_equ_expr();
    while (equal(get_lexeme(1), "&")) {
        match2(PRE_TOK_PUNCTUATOR);
        r = r&pre_eval_equ_expr();
    }
    return r;
}

long long pre_eval_equ_expr(void)
{
    long long r;

    r = pre_eval_rel_expr();
    while (lookahead(1) == PRE_TOK_PUNCTUATOR) {
        char *s;

        s = get_lexeme(1);
        if (equal(s, "==")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r==pre_eval_rel_expr();
        } else if (equal(s, "!=")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r!=pre_eval_rel_expr();
        } else {
            break;
        }
    }
    return r;
}

long long pre_eval_rel_expr(void)
{
    long long r;

    r = pre_eval_shi_expr();
    while (lookahead(1) == PRE_TOK_PUNCTUATOR) {
        char *s;

        s = get_lexeme(1);
        if (equal(s, "<")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r<pre_eval_shi_expr();
        } else if (equal(s, ">")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r>pre_eval_shi_expr();
        } else if (equal(s, "<=")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r<=pre_eval_shi_expr();
        } else if (equal(s, ">=")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r>=pre_eval_shi_expr();
        } else {
            break;
        }
    }
    return r;
}

long long pre_eval_shi_expr(void)
{
    long long r;

    r = pre_eval_add_expr();
    while (lookahead(1) == PRE_TOK_PUNCTUATOR) {
        char *s;

        s = get_lexeme(1);
        if (equal(s, "<<")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r<<pre_eval_add_expr();
        } else if (equal(s, ">>")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r>>pre_eval_add_expr();
        } else {
            break;
        }
    }
    return r;
}

long long pre_eval_add_expr(void)
{
    long long r;

    r = pre_eval_mul_expr();
    while (lookahead(1) == PRE_TOK_PUNCTUATOR) {
        char *s;

        s = get_lexeme(1);
        if (equal(s, "+")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r+pre_eval_mul_expr();
        } else if (equal(s, "-")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r-pre_eval_mul_expr();
        } else {
            break;
        }
    }
    return r;
}

long long pre_eval_mul_expr(void)
{
    long long r;

    r = pre_eval_una_expr();
    while (lookahead(1) == PRE_TOK_PUNCTUATOR) {
        char *s;

        s = get_lexeme(1);
        if (equal(s, "*")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r*pre_eval_una_expr();
        } else if (equal(s, "/")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r/pre_eval_una_expr();
        } else if (equal(s, "%")) {
            match2(PRE_TOK_PUNCTUATOR);
            r = r%pre_eval_una_expr();
        } else {
            break;
        }
    }
    return r;
}

long long pre_eval_una_expr(void)
{
    char *s;
    long long r;

    s = get_lexeme(1);
    if (equal(s, "defined")) {
        match2(PRE_TOK_ID);
        if (equal(get_lexeme(1), "(")) { /* "defined" "(" identifier ")" */
            match2(PRE_TOK_PUNCTUATOR);
            if (lookahead(1) == PRE_TOK_ID)
                r = (lookup_macro(get_lexeme(1)) != NULL);
            match2(PRE_TOK_ID);
            if (!equal(get_lexeme(1), ")"))
                ERROR("expecting `)'; got `%s'", curr_tok->lexeme);
            match2(PRE_TOK_PUNCTUATOR);
        } else { /* "defined" identifier */
            if (lookahead(1) == PRE_TOK_ID)
                r = (lookup_macro(get_lexeme(1)) != NULL);
            match2(PRE_TOK_ID);
        }
        return r;
    } else if (s[1] != '\0') {
        return pre_eval_pri_expr();
    }
    switch (s[0]) {
    case '+':
    case '-':
    case '~':
    case '!':
        match2(PRE_TOK_PUNCTUATOR);
        r = pre_eval_una_expr();
        return (s[0] == '+') ? r : (s[0] == '-') ? -r : (s[0] == '~') ? ~r : !r;
    default:
        return pre_eval_pri_expr();
    }
}

long long pre_eval_pri_expr(void)
{
    char *endp;
    long long r;

    switch (lookahead(1)) {
    case PRE_TOK_PUNCTUATOR:
        if (!equal(get_lexeme(1), "("))
            break;
        match2(PRE_TOK_PUNCTUATOR);
        r = pre_eval_expr();
        if (!equal(get_lexeme(1), ")"))
            ERROR("expecting `)'; got `%s'", curr_tok->lexeme);
        match2(PRE_TOK_PUNCTUATOR);
        return r;

    case PRE_TOK_ID: {
        Macro *m;

        if ((m=lookup_macro(get_lexeme(1))) != NULL)
            r = strtoll(m->rep->lexeme, &endp, 10);
        else
            r = 0; /* undefined macro names evaluate to zero */
        match2(PRE_TOK_ID);
        return r;
    }

    case PRE_TOK_NUM:
        r = strtoll(get_lexeme(1), &endp, 10);
        match2(PRE_TOK_NUM);
        return r;
    }

    ERROR("expecting primary-expression; got `%s'", curr_tok->lexeme);
}
