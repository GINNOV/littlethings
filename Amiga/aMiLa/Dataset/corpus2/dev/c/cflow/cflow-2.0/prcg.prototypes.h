/* prcg.c */
static void usage(void);
int main(int argc, char **argv);
static void build_dcg(void);
int get_arc(char *buf, char **ip, char **rp);
struct imm_node *create_arc_node(char *s, char *t);
struct imm_node *link_arc_node(char *s, struct imm_node *tail);
struct name_node *name_to_nlist(char *s, char *t);
struct imm_node *node_to_arc(struct name_node *np, struct imm_node *ip);
static struct imm_node *get_imm_node(void);
int print_dcg(int argc, char **argv);
int print_name(struct name_node *node, int tabc);
int makeactive(struct name_node *node);
int backup(void);
int active(struct name_node *node);
struct name_node *nlist_contains(char *s);
