#include "ast2c.h"
#include <stdlib.h>
#include <string.h>
#include "decl.h"
#include "util/util.h"
#include "util/str.h"

static String *c_src;

static void conv2src(ExecNode *n, int paren)
{
    if (n->node_kind == StmtNode) {
        switch (n->kind.stmt) {
        case IfStmt:
            string_printf(c_src, "if(");
            conv2src(n->child[0], FALSE);
            string_printf(c_src, ")");
            return;
        case SwitchStmt:
            string_printf(c_src, "switch(");
            conv2src(n->child[0], FALSE);
            string_printf(c_src, ")");
            return;
        case WhileStmt:
            string_printf(c_src, "while(");
            conv2src(n->child[0], FALSE);
            string_printf(c_src, ")");
            return;
        case DoStmt:
            string_printf(c_src, "while(");
            conv2src(n->child[0], FALSE);
            string_printf(c_src, ");");
            return;
        case ExpStmt:
            conv2src(n->child[0], FALSE);
            string_printf(c_src, ";");
            return;
        case ReturnStmt:
            string_printf(c_src, "return ");
            if (n->child[0] != NULL)
                conv2src(n->child[0], FALSE);
            string_printf(c_src, ";");
            return;
        case CaseStmt:
            string_printf(c_src, "case %lld:", n->child[0]->attr.val);
            return;
        case LabelStmt:
            string_printf(c_src, "%s:", n->attr.str);
            return;
        case GotoStmt:
            string_printf(c_src, "goto %s;", n->attr.str);
            return;
        case ForStmt:
        case BreakStmt:
        case ContinueStmt:
        case CmpndStmt:
        case DefaultStmt:
            return;
        }
    } else {
        switch (n->kind.exp) {
        case OpExp:
            switch (n->attr.op) {
            case TOK_FUNCTION:
                conv2src(n->child[0], TRUE);
                string_printf(c_src, "(");
                if (n->child[1] != NULL) {
                    ExecNode *n2;

                    for (n2 = n->child[1]; n2 != NULL; n2 = n2->sibling) {
                        conv2src(n2, FALSE);
                        if (n2->sibling != NULL)
                            string_printf(c_src, ",");
                    }
                }
                string_printf(c_src, ")");
                return;
            case TOK_SUBSCRIPT:
                conv2src(n->child[0], TRUE);
                string_printf(c_src, "[");
                conv2src(n->child[1], FALSE);
                string_printf(c_src, "]");
                return;
            case TOK_DOT:
            case TOK_ARROW:
                conv2src(n->child[0], TRUE);
                string_printf(c_src, "%s", tok2lex(n->attr.op));
                conv2src(n->child[1], FALSE);
                return;
            case TOK_POS_INC:
            case TOK_POS_DEC:
                conv2src(n->child[0], TRUE);
                string_printf(c_src, "%s", tok2lex(n->attr.op));
                return;
            case TOK_PRE_INC:
            case TOK_PRE_DEC:
            case TOK_ADDRESS_OF:
            case TOK_INDIRECTION:
            case TOK_UNARY_PLUS:
            case TOK_UNARY_MINUS:
            case TOK_COMPLEMENT:
            case TOK_NEGATION:
                if (paren)
                    string_printf(c_src, "(");
                string_printf(c_src, "%s", tok2lex(n->attr.op));
                conv2src(n->child[0], TRUE);
                if (paren)
                    string_printf(c_src, ")");
                return;
            case TOK_CAST: {
                char *s;

                s = stringify_type_exp((Declaration *)n->child[1], FALSE);
                if (paren)
                    string_printf(c_src, "(");
                string_printf(c_src, "(%s)", s);
                if (paren)
                    string_printf(c_src, ")");
                free(s);
                conv2src(n->child[0], TRUE);
            }
                return;
            case TOK_CONDITIONAL:
                if (paren)
                    string_printf(c_src, "(");
                conv2src(n->child[0], TRUE);
                string_printf(c_src, "?");
                conv2src(n->child[1], TRUE);
                string_printf(c_src, ":");
                conv2src(n->child[2], TRUE);
                if (paren)
                    string_printf(c_src, ")");
                return;
            default: /* binary operator */
                if (paren)
                    string_printf(c_src, "(");
                conv2src(n->child[0], TRUE);
                string_printf(c_src, "%s", tok2lex(n->attr.op));
                conv2src(n->child[1], TRUE);
                if (paren)
                    string_printf(c_src, ")");
                return;
            } /* switch (n->attr.op) */
        case IConstExp:
            string_printf(c_src, "%llu", n->attr.uval);
            return;
        case StrLitExp:
            /*
             * TODO: replace special characters for the corresponding
             *       escape sequence: 0x0A => \n, etc.
             */
            string_printf(c_src, "<string-literal>");
            return;
        case IdExp:
            string_printf(c_src, "%s", n->attr.str);
            return;
        } /* (n->kind.exp) */
    }
}

/* Transform an AST to C source code. */
char *ast2c(ExecNode *n)
{
    char *s;

    if (c_src == NULL)
        c_src = string_new(256);
    conv2src(n, FALSE);
    s = malloc(string_get_pos(c_src)+1);
    string_set_pos(c_src, 0);
    strcpy(s, string_curr(c_src));
    return s;
}
