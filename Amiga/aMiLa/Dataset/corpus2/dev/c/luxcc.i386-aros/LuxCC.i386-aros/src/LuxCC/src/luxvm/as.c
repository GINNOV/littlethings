/*
    Small cross assembler for the Lux VM.

        ASM GRAMMAR
    program = statement { statement }
    statement = instruction | label | directive
    instruction = operation [ operand ] ";"
    operand = id | number
    label = id ":"
    directive = "." "text" |
                "." "data" |
                "." "bss"  |
                "." "global" id { "," id } |
                "." "extern" id { "," id } |
                "." "byte"  number |
                "." "word"  number |
                "." "dword" ( id [ "+" number ] | number ) |
                "." "qword" ( id [ "+" number ] | number ) |
                "." "res"   number |
                "." "align" number |
                "." "zero"  number
        TOKENS
    id = ( '_' | '@' | [A-Za-z] ) ( '_' | '@' | [0-9A-Za-z] )*
    number = [0-9]+
*/

#include "as.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "vm.h"
#include "../util/util.h"
#include "operations.h"

#define MAX_LINE_BUF        4096
#define MAX_LEXEME          512
#define HASH_SIZE           1009
#define HASH(s)             (hash(s)%HASH_SIZE)

typedef struct Reloc Reloc;
typedef struct Symbol Symbol;

typedef enum {
    TOK_ID,
    TOK_NUM,
    TOK_COMMA,
    TOK_COLON,
    TOK_DOT,
    TOK_SEMI,
    TOK_PLUS,
    TOK_EOF
} Token;

char *prog_name;
char *curr, *buf;
char line_buf[MAX_LINE_BUF];
char lexeme[MAX_LEXEME];
int lineno = 1;
Token curr_tok;
int targeting_vm64;
int reading_from_stdin;

#define ASSEMBLER_ERR(...)  fprintf(stderr, "%s: line %d: ", prog_name, lineno), TERMINATE(__VA_ARGS__)

Token get_token(void);
void match(Token expected);
void program(void);
void statement(void);
void instruction(char *operation);
void label(char *id);
void directive(void);
int read_line(void);
void init(char *file_path);

/*
 * Segments.
 */
char *text_seg;
char *data_seg;
int curr_segment = TEXT_SEG;
int text_size, data_size, bss_size;
int text_max, data_max;
#define CURR_OFFS() ((curr_segment==DATA_SEG)?data_size:(curr_segment==TEXT_SEG)?text_size:bss_size)

long long get_int(char *s)
{
    char *ep;

    return strtoll(s, &ep, 0);
}

void bss_err(void)
{
    ASSEMBLER_ERR("trying to write into .bss segment");
}

void expand_curr_segment(void)
{
    char *p;

    if (curr_segment == TEXT_SEG) {
        text_max *= 2;
        if ((p=realloc(text_seg, text_max)) != NULL) {
            text_seg = p;
            return;
        }
    } else {
        data_max *= 2;
        if ((p=realloc(data_seg, data_max)) != NULL) {
            data_seg = p;
            return;
        }
    }
    TERMINATE("out of memory");
}

void write_byte(int b)
{
    if (curr_segment == TEXT_SEG) {
        if (text_size+1 > text_max)
            expand_curr_segment();
        text_seg[text_size++] = (char)b;
    } else if (curr_segment == DATA_SEG) {
        if (data_size+1 > data_max)
            expand_curr_segment();
        data_seg[data_size++] = (char)b;
    } else {
        bss_err();
    }

}

void write_word(int w)
{
    if (curr_segment == TEXT_SEG) {
        if (text_size+2 > text_max)
            expand_curr_segment();
        *(short *)&text_seg[text_size] = (short)w;
        text_size += 2;
    } else if (curr_segment == DATA_SEG) {
        if (data_size+2 > data_max)
            expand_curr_segment();
        *(short *)&data_seg[data_size] = (short)w;
        data_size += 2;
    } else {
        bss_err();
    }
}

void write_dword(int d)
{
    if (curr_segment == TEXT_SEG) {
        if (text_size+4 > text_max)
            expand_curr_segment();
        *(int *)&text_seg[text_size] = d;
        text_size += 4;
    } else if (curr_segment == DATA_SEG) {
        if (data_size+4 > data_max)
            expand_curr_segment();
        *(int *)&data_seg[data_size] = d;
        data_size += 4;
    } else {
        bss_err();
    }
}

void write_qword(long long q)
{
    if (curr_segment == TEXT_SEG) {
        if (text_size+8 > text_max)
            expand_curr_segment();
        *(long long *)&text_seg[text_size] = q;
        text_size += 8;
    } else if (curr_segment == DATA_SEG) {
        if (data_size+8 > data_max)
            expand_curr_segment();
        *(long long *)&data_seg[data_size] = q;
        data_size += 8;
    } else {
        bss_err();
    }
}

/*
 * Symbols.
 */
struct Symbol {
    char *name;
    int segment, offset;
    int kind;
    Symbol *next;
} *symbols[HASH_SIZE];
int nsym;

Symbol *lookup_symbol(char *name)
{
    Symbol *np;

    for (np = symbols[HASH(name)]; np != NULL; np = np->next)
        if (equal(np->name, name))
            break;

    return np;
}

Symbol *define_symbol(char *name, int kind, int segment, int offset)
{
    unsigned h;
    Symbol *np;

    h = HASH(name);
    for (np = symbols[h]; np != NULL; np = np->next)
        if (equal(np->name, name))
            break;

    if (np == NULL) {
        np = malloc(sizeof(Symbol));
        /* set attributes */
        np->name = strdup(name);
        np->segment = segment;
        np->offset = offset;
        np->kind = kind;
        /* chain */
        np->next = symbols[h];
        symbols[h] = np;
        ++nsym;
    } else {
        /* allow a symbol to be declared extern more than once */
        if (np->kind==EXTERN_SYM && kind==EXTERN_SYM)
            return np;

        ASSEMBLER_ERR("symbol `%s' redefined", name);
    }

    return np;
}

/*
 * Relocations.
 */
struct Reloc {
    int segment, offset; /* segment+offset is where the fix must be made */
    char *symbol;        /* the information about what symbol must be fixed */
} *relocation_table;
int nreloc, reloc_max;

void append_reloc(int segment, int offset, char *symbol)
{
    if (nreloc >= reloc_max) {
        Reloc *p;

        reloc_max *= 2;
        if ((p=realloc(relocation_table, reloc_max*sizeof(Reloc))) == NULL)
            TERMINATE("out of memory");
        relocation_table = p;
    }
    relocation_table[nreloc].segment = segment;
    relocation_table[nreloc].offset = offset;
    relocation_table[nreloc].symbol = strdup(symbol);
    ++nreloc;
}

void err_no_input(void)
{
    fprintf(stderr, "%s: no input file\n", prog_name);
    exit(1);
}

void unk_opt(char *opt)
{
    fprintf(stderr, "%s: unknown option `%s'\n", prog_name, opt);
    exit(1);
}

int main(int argc, char *argv[])
{
    /*
                [ Object file format ]

    +-------------------------------------------------+ <-+
    | Number of entries in symbol table (4 bytes)     |   |
    +-------------------------------------------------+   |
    | Bss size in bytes (4 bytes)                     |   |
    +-------------------------------------------------+   |
    | Data size in bytes (4 bytes)                    |   |-> Header
    +-------------------------------------------------+   |
    | Text size in bytes (4 bytes)                    |   |
    +-------------------------------------------------+   |
    | Number of entries in relocation table (4 bytes) |   |
    +-------------------------------------------------+ <-+
    | Symbol table                                    |
    +-------------------------------------------------+
    | Data                                            |
    +-------------------------------------------------+
    | Text                                            |
    +-------------------------------------------------+
    | Relocation table                                |
    +-------------------------------------------------+

    Each entry of the relocation table:
        - segment: indicates if the fix must be made into the data or text segment.
        - offset: the offset from the start of the segment where the fix must be made.
        - symbol: indicates the location of what symbol must be corrected.
    The job of the linker is:
        for each entry of the reloc table do:
            *(segment+offset) = final (static) offset of symbol;
    */

    int i;
    FILE *fout;
    char *outpath, *inpath;
    int print_stats;

    prog_name = argv[0];
    if (argc == 1)
        err_no_input();
    outpath = NULL;
    print_stats = FALSE;
    targeting_vm64 = FALSE;
    for (i = 1; i < argc; i++) {
        if (argv[i][0]!='-' || argv[i][1]=='\0') {
            inpath = argv[i];
            continue;
        }
        switch (argv[i][1]) {
        case 'o':
            if (argv[i][2] != '\0') {
                outpath = argv[i]+2;
            } else if (argv[i+1] == NULL) {
                fprintf(stderr, "%s: option `o' requires an argument\n", prog_name);
                exit(1);
            } else {
                outpath = argv[++i];
            }
            break;
        case 's':
            print_stats = TRUE;
            break;
        case 'v':
            if (equal(argv[i]+1, "vm64"))
                targeting_vm64 = TRUE;
            else if (equal(argv[i]+1, "vm32"))
                ;
            else
                unk_opt(argv[i]);
            break;
        case 'h':
            printf("usage: %s [ options ] <input-file>\n"
                   "  The available options are:\n"
                   "    -o<file>    write output to <file>\n"
                   "    -s          print assembling stats\n"
                   "    -vm32       target the 32-bit VM (default)\n"
                   "    -vm64       target the 64-bit VM\n"
                   "    -h          print this help\n"
                   "\nnote: if the input file is - the program is read from the standard input\n", prog_name);
            exit(0);
            break;
        default:
            unk_opt(argv[i]);
            break;
        }
    }
    if (inpath == NULL)
        err_no_input();
    init(equal(inpath, "-") ? NULL : inpath);
    text_max = 65536;
    text_seg = malloc(text_max);
    data_max = 65536;
    data_seg = malloc(data_max);
    reloc_max = 8192;
    relocation_table = malloc(sizeof(Reloc)*reloc_max);

    curr_tok = get_token();
    program();
    match(TOK_EOF);

    if (outpath != NULL) {
        fout = fopen(outpath, "wb");
    } else {
        if (equal(inpath, "-")) {
            fout = fopen("a.o", "wb");
        } else {
            outpath = replace_extension(inpath, ".o");
            fout = fopen(outpath, "wb");
            free(outpath);
        }
    }
    fwrite(&nsym, sizeof(int), 1, fout);
    fwrite(&bss_size, sizeof(int), 1, fout);
    fwrite(&data_size, sizeof(int), 1, fout);
    fwrite(&text_size, sizeof(int), 1, fout);
    fwrite(&nreloc, sizeof(int), 1, fout);

    for (i = 0; i < HASH_SIZE; i++) {
        if (symbols[i] != NULL) {
            Symbol *np;

            for (np = symbols[i]; np != NULL; np = np->next) {
                fwrite(np->name, strlen(np->name)+1, 1, fout);
                fwrite(&np->segment, sizeof(int), 1, fout);
                fwrite(&np->offset, sizeof(int), 1, fout);
                fwrite(&np->kind, sizeof(int), 1, fout);
            }
        }
    }

    fwrite(data_seg, data_size, 1, fout);
    fwrite(text_seg, text_size, 1, fout);

    for (i = 0; i < nreloc; i++) {
        /*
         * If there is a reloc for a label but that label is not into the module's symbol
         * table, it means that the label was used into the code but not declared anywhere.
         */
        if (lookup_symbol(relocation_table[i].symbol) == NULL)
            TERMINATE("%s: symbol `%s' undefined", prog_name, relocation_table[i].symbol);

        fwrite(&relocation_table[i].segment, sizeof(int), 1, fout);
        fwrite(&relocation_table[i].offset, sizeof(int), 1, fout);
        fwrite(relocation_table[i].symbol, strlen(relocation_table[i].symbol)+1, 1, fout);
    }
    if (fout != stdout)
        fclose(fout);

    if (print_stats) {
        printf("Text size: %d\n", text_size);
        printf("Data size: %d\n", data_size);
        printf("Bss size: %d\n", bss_size);
        printf("Number of relocations: %d\n", nreloc);
    }

    free(text_seg);
    free(data_seg);
    free(relocation_table);

    return 0;
}

/* program = statement { statement } */
void program(void)
{
    statement();
    while (curr_tok != TOK_EOF)
        statement();
}

/* statement = instruction | label | directive */
void statement(void)
{
    if (curr_tok == TOK_DOT) {
        directive();
    } else if (curr_tok == TOK_ID) {
        char id[MAX_SYM_LEN];

        strcpy(id, lexeme);
        match(TOK_ID);
        if (curr_tok == TOK_COLON)
            label(id);
        else
            instruction(id);
    } else {
        ASSEMBLER_ERR("expecting instruction, label, or directive (got `%s')", lexeme);
    }
}

/* label = id ":" */
void label(char *id)
{
    define_symbol(id, LOCAL_SYM, curr_segment, CURR_OFFS());
    match(TOK_COLON);
}

/* instruction = operation [ operand ] ";" */
void instruction(char *operation)
{
    Operation *op_entry;

    if ((op_entry=lookup_operation(operation)) == NULL)
        ASSEMBLER_ERR("unknown operation `%s'", operation);
    write_byte(op_entry->opcode);
    if (op_entry->has_operand) {
        if (curr_tok == TOK_ID) {
            append_reloc(curr_segment, CURR_OFFS(), lexeme);
            match(TOK_ID);
            if (targeting_vm64)
                write_qword(0);
            else
                write_dword(0);
        } else if (curr_tok == TOK_NUM) {
            if (op_entry->opcode == OpLdIQW)
                write_qword(get_int(lexeme));
            else
                write_dword((int)get_int(lexeme));
            match(TOK_NUM);
        } else if (curr_tok == TOK_SEMI) {
            ASSEMBLER_ERR("operation `%s' requires an operand", operation);
        } else {
            ASSEMBLER_ERR("invalid operand to operation `%s'", operation);
        }
    }
    match(TOK_SEMI);
}

void globalize_symbol(char *name)
{
    Symbol *s;

    if ((s=lookup_symbol(name)) == NULL)
        ASSEMBLER_ERR("global directive applied to undefined symbol `%s'", name);

    if (s->kind == EXTERN_SYM) /* global can only be applied to local symbols */
        ASSEMBLER_ERR("symbol `%s' redefined", name);

    /* allow global to be applied to a symbol more than once */
    s->kind = GLOBAL_SYM;
}

/*
 * directive = "." "text" |
 *             "." "data" |
 *             "." "bss"  |
 *             "." "global" id { "," id } |
 *             "." "extern" id { "," id } |
 *             "." "byte"  number |
 *             "." "word"  number |
 *             "." "dword" ( id [ "+" number ] | number ) |
 *             "." "qword" ( id [ "+" number ] | number ) |
 *             "." "res"   number |
 *             "." "align" number |
 *             "." "zero"  number
 */
void directive(void)
{
    match(TOK_DOT);
    if (curr_tok != TOK_ID)
        ASSEMBLER_ERR("expecting directive (got `%s')", lexeme);

    /* dispatch directive */
    if (equal(lexeme, "text")) {
        match(TOK_ID);
        curr_segment = TEXT_SEG;
    } else if (equal(lexeme, "data")) {
        match(TOK_ID);
        curr_segment = DATA_SEG;
    } else if (equal(lexeme, "bss")) {
        match(TOK_ID);
        curr_segment = BSS_SEG;
    } else if (equal(lexeme, "global")) {
        match(TOK_ID);
        if (curr_tok == TOK_ID)
            globalize_symbol(lexeme);
        match(TOK_ID);
        while (curr_tok == TOK_COMMA) {
            match(TOK_COMMA);
            if (curr_tok == TOK_ID)
                globalize_symbol(lexeme);
            match(TOK_ID);
        }
    } else if (equal(lexeme, "extern")) {
        match(TOK_ID);
        if (curr_tok == TOK_ID)
            define_symbol(lexeme, EXTERN_SYM, 0, 0);
        match(TOK_ID);
        while (curr_tok == TOK_COMMA) {
            match(TOK_COMMA);
            if (curr_tok == TOK_ID)
                define_symbol(lexeme, EXTERN_SYM, 0, 0);
            match(TOK_ID);
        }
    } else if (equal(lexeme, "byte")) {
        match(TOK_ID);
        if (curr_tok == TOK_NUM)
            write_byte((int)get_int(lexeme));
        match(TOK_NUM);
    } else if (equal(lexeme, "word")) {
        match(TOK_ID);
        if (curr_tok == TOK_NUM)
            write_word((int)get_int(lexeme));
        match(TOK_NUM);
    } else if (equal(lexeme, "dword")) {
        match(TOK_ID);
        if (curr_tok == TOK_ID) {
            if (targeting_vm64)
                goto dword_bad_op; /* should be using .qword */
            append_reloc(curr_segment, CURR_OFFS(), lexeme);
            match(TOK_ID);
            if (curr_tok == TOK_PLUS) {
                match(TOK_PLUS);
                if (curr_tok == TOK_NUM)
                    write_dword((int)get_int(lexeme));
                match(TOK_NUM);
            } else {
                write_dword(0);
            }
        } else if (curr_tok == TOK_NUM) {
            write_dword((int)get_int(lexeme));
            match(TOK_NUM);
        } else {
dword_bad_op:
            ASSEMBLER_ERR("invalid operand to directive `.dword'");
        }
    } else if (equal(lexeme, "qword")) {
        match(TOK_ID);
        if (curr_tok == TOK_ID) {
            if (!targeting_vm64)
                goto qword_bad_op; /* should be using .dword */
            append_reloc(curr_segment, CURR_OFFS(), lexeme);
            match(TOK_ID);
            if (curr_tok == TOK_PLUS) {
                match(TOK_PLUS);
                if (curr_tok == TOK_NUM)
                    write_qword(get_int(lexeme));
                match(TOK_NUM);
            } else {
                write_qword(0);
            }
        } else if (curr_tok == TOK_NUM) {
            write_qword(get_int(lexeme));
            match(TOK_NUM);
        } else {
qword_bad_op:
            ASSEMBLER_ERR("invalid operand to directive `.qword'");
        }
    } else if (equal(lexeme, "res")) {
        match(TOK_ID);
        if (curr_tok == TOK_NUM) {
            if (curr_segment != BSS_SEG)
                ASSEMBLER_ERR("`.res' can only be used in the .bss segment");
            bss_size += get_int(lexeme);
        }
        match(TOK_NUM);
    } else if (equal(lexeme, "align")) {
        match(TOK_ID);
        if (curr_tok == TOK_NUM) {
            int curr_size, new_size;

            curr_size = CURR_OFFS();
            new_size = round_up(curr_size, (int)get_int(lexeme));
            while (curr_size++ < new_size)
                if (curr_segment == BSS_SEG)
                    ++bss_size;
                else
                    write_byte(OpNop);
        }
        match(TOK_NUM);
    } else if (equal(lexeme, "zero")) {
        match(TOK_ID);
        if (curr_tok == TOK_NUM) {
            unsigned n;

            for (n = (unsigned)get_int(lexeme); n != 0; n--)
                write_byte(0);
        }
        match(TOK_NUM);
    } else {
        ASSEMBLER_ERR("unknown directive `%s'", lexeme);
    }
}

Token get_token(void)
{
    enum {
        START,
        DONE,
        INID,
        INNUM,
        INCOMMENT
    };
    Token tok;
    int state;
    int save, cind;

    cind = 0;
    state = START;
    while (state != DONE) {
        int c;

        c = *curr++;
        save = 1;
        switch (state) {
        case START:
            if (c==' ' || c=='\t' || c=='\n') {
                save = 0;
                if (c == '\n')
                    ++lineno;
            } else if (isdigit(c) || c=='-') {
                state = INNUM;
            } else if (isalpha(c) || c=='_' || c=='@') {
                state = INID;
            } else if (c == '#') {
                save = 0;
                state = INCOMMENT;
            } else {
                state = DONE;
                switch (c) {
                case '\0':
                    save = 0;
                    if (reading_from_stdin && read_line())
                        state = START;
                    else
                        tok = TOK_EOF;
                    break;
                case ',':
                    tok = TOK_COMMA;
                    break;
                case ';':
                    tok = TOK_SEMI;
                    break;
                case ':':
                    tok = TOK_COLON;
                    break;
                case '.':
                    tok = TOK_DOT;
                    break;
                case '+':
                    tok = TOK_PLUS;
                    break;
                default:
                    /* ignore stray character */
                    save = 0;
                    state = START;
                    break;
                }
            }
            break;
        case INID:
            if (!isalnum(c) && c!='_' && c!='@') {
                save = 0;
                --curr;
                tok = TOK_ID;
                state = DONE;
            }
            break;
        case INNUM:
            if (!isdigit(c)) {
                save = 0;
                --curr;
                tok = TOK_NUM;
                state = DONE;
            }
            break;
        case INCOMMENT:
            save = 0;
            if (c == '\n') {
                ++lineno;
                state = START;
            } else if (c == '\0') {
                --curr;
                state = START;
            }
            break;
        default: /* unreachable */
            break;
        }
        if (save)
            lexeme[cind++] = (char)c;
        if (state == DONE)
            lexeme[cind] = '\0';
    }

    return tok;
}

void match(Token expected)
{
    if (curr_tok != expected)
        ASSEMBLER_ERR("syntax error: unexpected `%s'", lexeme);
    curr_tok = get_token();
}

int read_line(void)
{
    curr = line_buf;
    return (fgets(line_buf, MAX_LINE_BUF, stdin) != NULL);
}

void init(char *file_path)
{
    if (file_path != NULL) {
        FILE *fp;
        unsigned len;

        fp = fopen(file_path, "rb");
        if (fp == NULL)
            TERMINATE("%s: error reading file `%s'", prog_name, file_path);
        fseek(fp, 0, SEEK_END);
        len = ftell(fp);
        rewind(fp);
        curr = buf = malloc(len+2);
        len = fread(buf, 1, len, fp);
        buf[len] = buf[len+1] = '\0';
    } else {
        reading_from_stdin = TRUE;
        read_line();
    }
}
