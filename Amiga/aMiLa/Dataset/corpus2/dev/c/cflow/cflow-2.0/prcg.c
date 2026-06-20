
/* This file contains code for building and printing a directed cyclic
 * graph as part of the cflow program. */

/* Author: M.M. Taylor, DCIEM, Toronto, Canada.
 * 22/Jan/81, Alexis Kwan (HCR at DCIEM).
 * 12-Jun-84, Kevin Szabo
 * 8/8/84, Tony Hansen, AT&T-IS, pegasus!hansen. 
 * 
 * This file is contributed to the public domain by Andrew Moore of
 * Talke Studio */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "prcg.prototypes.h"
#ifndef PATH_MAX
#define PATH_MAX 1024		/* max pathname length */
#endif
#ifndef NAME_MAX
#define NAME_MAX 32
#endif

#define BUF_MAX (NAME_MAX * 2 + PATH_MAX + 20)	/* max line buffer length */
#define DEPTH_MAX 200		/* max path length */
#define TABSIZE 8		/* tab size */
#define MARGIN 20		/* right margin of paper */
#define PAPERWIDTH (14*TABSIZE + MARGIN)	/* tabbing limits */

#ifndef __P
#ifndef __STDC__
#define __P(proto) ()
#else
#define __P(proto) proto
#endif
#endif

/* name list node */
struct name_node {
	struct name_node *next;	/* next name list node */
	struct imm_node *imm_list;	/* node's immediate list */
	long name_visited;	/* set if node previously visited */
	int is_arc_head;	/* set if node is an arc head */
	char *imm_name;		/* name of first imm_list node */
	char *imm_ref;		/* reference to first imm_list node */
};

/* immediate list node */
struct imm_node {
	struct imm_node *next;	/* next immediate list node */
	struct name_node *name_node_p;	/* node's name node pointer */
};


/* The name list (nlist) contains names (e.g., function/variable) in
 * lexicographical order.  Each name node has its own  list (imm_list) of
 * immediates (e.g., callers/callees).  The immediate nodes do not
 * themselves have names;  instead, each node has a pointer to its name
 * (node) in the name list.  The nodes and pointers form the vertices and
 * edges, respectively, of a directed cyclic graph (DCG).
 * 
 * The prcg program builds a DCG by inserting names pairs from the input
 * as arcs into the graph.  Printing the DCG is done by a preorder
 * traversal from a root name node.   Paths are defined by the immediate
 * list of the root name node, and, recursively, by the immediate lists
 * of its immediates. */
/* where is this initialized? */

static struct name_node *nlist;
static char *dashes;		/* separators for deep nestings */

/* The following options are available :
 * 
 * -a       print a separate graph for each name (default: no)
 * -d nn    print graphs to at most depth `nn' (default: 200)
 * -r root  print graph only for `root' (default: each root name)
 * -x       print each sub-graph in full (default: no)
 * -w nn    print graph to fit in `nn' columns (default: 132 columns) */

/* option flags */
static int graph_all = 0;	/* print a graph for each name */
static int maxdepth = DEPTH_MAX;	/* print to at most depth `maxdepth' */
static int expand_all = 0;	/* print each sub-graph in full */
static int ntabs = ((PAPERWIDTH - MARGIN) / TABSIZE);	/* how wide to go */
static int select_roots = 0;	/* print graph for selected names */

static char *arglist = "ad:r:ixw:";	/* valid options */

static char *progname;		/* argv[0] */

extern char *optarg;
extern int optind;

static void usage(void)
{

	fprintf(stderr, "Usage: %s [-ax ] [-d depth] [-r root]\n", progname);
	exit(1);
}

main(int argc, char **argv)
{

	int c, i;
	int width = PAPERWIDTH;

	progname = argv[0];

	while ((c = getopt(argc, argv, arglist)) != EOF)
		switch (c) {
		    case 'a':
			    graph_all = 1;
			    break;
		    case 'd':
			    if ((maxdepth = atoi(optarg)) > DEPTH_MAX)
				    maxdepth = DEPTH_MAX;
			    break;
		    case 'i':
			    expand_all = 1;
			    graph_all = 1;
			    maxdepth = 2;
			    break;
		    case 'r':
			    select_roots = 1;
			    break;
		    case 'w':
			    if ((width = atoi(optarg)) <= 0)
				    width = PAPERWIDTH;
			    break;
		    case 'x':
			    expand_all = 1;
			    break;
		    case '?':
		    default:
			    usage();
		}
	ntabs = (width - MARGIN) / TABSIZE;

	build_dcg();
	print_dcg(argc, argv);
	exit(0);
}

/* Name pairs in the input are expected in blocks of the form:
 * 
 * name1a --> name2aa
 * name1a --> name2ab
 * name1a --> name2ac
 * .
 * .
 * .
 * name1b --> name2ba
 * name1b --> name2bb
 * name1b --> name2bc
 * .
 * .
 * .
 * 
 * For a distinct name1, only the first block of name pairs is valid.  A
 * graph can be inverted by reversing the relation between name pairs,
 * i.e., by putting name2 first:
 * 
 * name2 --> name1
 * 
 * Unless a block contains only a single name pair, then an initial
 * name1-name1 pair is effectively ignored.  A name1-name1 pair after the
 * first represents a cycle - i.e., a node which points to itself.  A
 * block consisting of a single name1-name1 pair represents a non-cyclic,
 * possibly disconnected, node. */

static struct imm_node *imm_tail;	/* immediate list tail */

/* Get name pairs from the input, and  insert them as arcs to the DCG: an
 * arc tail is the head of a linearly linked list (the immediate list) of
 * arc heads to which it is connected (logically).  */
static void build_dcg(void)
{
	char arc_tail[BUF_MAX];	/* line buffer and arc tail name */
	char *arc_head;		/* arc head name */
	char *arc_ref;		/* arc reference */
	register int connected;

	while ((connected = get_arc(arc_tail, &arc_head, &arc_ref)) != -1)
		if (!connected)
			imm_tail = create_arc_node(arc_tail, arc_ref);
		else if (connected && imm_tail)
			imm_tail = link_arc_node(arc_head, imm_tail);
		else
			fprintf(stderr, "%s: cannot redefine: %s\n", progname, arc_tail);
}


char tail_name[NAME_MAX] = "";	/* previous arc tail name */

/* Read from stdin a name pair and a reference in the form
 * `name1<tab>name2<tab>reference<newline>.' Return 1 if the tail of arc
 * name1 --> name2 (i.e., name1) is the tail the previous arc,
 * otherwise 0. */
get_arc(char *buf, char **ip, char **rp)
{

	/* line read and data format okay */
	if (fgets(buf, BUF_MAX, stdin) != NULL
	    && (*ip = strchr(buf, '\t')) != NULL
	    && (*rp = strchr(*ip + 1, '\t')) != NULL) {
		/* null-terminate name1 and name2 substrings */
		*(*rp)++ = *(*ip)++ = '\0';

		/* arc tail not previous tail */
		if (strcmp(buf, tail_name)) {
			/* update arc tail name */
			strcpy(tail_name, buf);

			/* name pair is an arc (as opposed to a node) */
			if (strcmp(buf, *ip)) {
				/* create an arc tail node */
				imm_tail = create_arc_node(buf, *rp);

				/* arc */
				return 1;
			}
			/* node */
			return 0;
		}
		/* arc */
		return 1;
	}
	/* eof */
	return -1;
}


/* Given a name (s), if it is not already on the name list, create a node
 * for it there.  Otherwise, retrieve the name list node.  Create an arc
 * tail (i.e., imm_list) node and link it to the new/retrieved name
 * node (via the name node's imm_list pointer).  Return a pointer to the
 * arc tail node. */
struct imm_node *
 create_arc_node(char *s, char *t)
{
	struct name_node *np;
	struct imm_node *ip;

	/* name already on name list */
	if (np = nlist_contains(s)) {
		/* arc tail node installed && arc reference realloc'd */
		if ((ip = node_to_arc(np, (struct imm_node *) 0)) != 0
		    && (np->imm_ref = realloc(np->imm_ref, strlen(t) + 1)) != NULL) {
			/* update arc reference */

			strcpy(np->imm_ref, t);
			return ip;
		}
		return (struct imm_node *) 0;
	}
	/* add name to name list and install arc tail node */
	return node_to_arc(name_to_nlist(s, t), (struct imm_node *) 0);
}


char *nil = "    ";		/* should be "", but 386BSD 0.1 bus errors XXX */

/* Given a name (s), if it is not already on the name list, create a node
 * for it there.  Otherwise, retrieve the name list node.  Create an arc
 * head (i.e., imm_list) node and link it to the tail of the current
 * immediate list.  Return a pointer to the arc head node.  */
struct imm_node *
 link_arc_node(char *s, struct imm_node *tail)
{
	register struct name_node *p;
	register struct imm_node *ip = 0;

	/* (name already on name list or added name) and installed new arc
	 * and name != arc tail's name */
	if (((p = nlist_contains(s)) != 0 || (p = name_to_nlist(s, nil)) != 0)
	    && (ip = node_to_arc(p, tail)) != 0 && strcmp(s, tail_name))
		p->is_arc_head = 1;	/* arc head node */
	return ip;
}

/* Allocate memory for a name list node.  Insert the node  in the name
 * list in lexicographical order by name. Return a pointer to the node. */
struct name_node *
 name_to_nlist(char *s, char *t)
{
	register struct name_node *np, *p;

	/* name structure, name and arc reference alloc'd */
	if ((np = (struct name_node *) malloc(sizeof (struct name_node))) != 0
	    && (np->imm_name = (char *) malloc(strlen(s) + 1)) != NULL
	    && (np->imm_ref = (char *) malloc(strlen(t) + 1)) != NULL) {
		/* initialize name structure */
		strcpy(np->imm_name, s);
		strcpy(np->imm_ref, t);
		np->imm_list = (struct imm_node *) 0;
		np->is_arc_head = 0;
		np->name_visited = 0;

		/* no name list, or name less than head of name list */
		if (nlist == 0 || strcmp(nlist->imm_name, s) > 0) {
			/* add node to head of name list */
			np->next = nlist;
			nlist = np;
		} else {
			/* insert node in lexicographical order in name list */
			for (p = nlist; p->next; p = p->next)
				if (strcmp(p->next->imm_name, s) > 0)
					break;
			np->next = p->next;
			p->next = np;
		}
		return np;
	}
	return (struct name_node *) 0;
}


/* Create an immediate node (imm_p)  with a pointer (name_node_p) to its
 * name list node (np).  If the given immediate list pointer (ip) is NULL,
 * the new immediate node is an arc tail, and  it is pointed to by its
 * name list node.  Otherwise, the new immediate node is an arc head and
 * is linked after the given immediate list pointer.  Return a pointer to
 * the new immediate node. */
struct imm_node *
 node_to_arc(struct name_node *np, struct imm_node *ip)
{
	register struct imm_node *imm_p;

	/* null name or (dummy && an immediate exists) or null immediate */
	if (np == 0 || (!ip && np->imm_list) || (imm_p = get_imm_node()) == 0)
		return (struct imm_node *) 0;
	imm_p->name_node_p = np;
	return ip ? (ip->next = imm_p) : (np->imm_list = imm_p);
}

/* Return pointer to alloc'd and initialized immediate node. */
static struct imm_node *
 get_imm_node(void)
{
	register struct imm_node *rp;

	/* immediate node alloc'd */
	if ((rp = (struct imm_node *) malloc(sizeof (struct imm_node))) != 0) {
		/* initialize immediate node */
		rp->next = (struct imm_node *) 0;
		return rp;
	}
	return (struct imm_node *) 0;
}

/* Preorder traverse the DCG, printing the names of nodes as they
 * are visited. */
print_dcg(int argc, char **argv)
{
	register int c;
	register struct name_node *root_p;

	/* root node(s) specified */
	if (select_roots)
		/* restart argument list; print only specified names */
		for (optind = 1; (c = getopt(argc, argv, arglist)) != EOF;) {
			if (c == 'r')
				if (root_p = nlist_contains(optarg))
					print_name(root_p, 1);
				else
					(void) fprintf(stderr, "%s: not found: %s\n", progname, optarg);
	} else
		/* print_name everything */
		for (root_p = nlist; root_p; root_p = root_p->next)
			if (graph_all || !root_p->is_arc_head)
				print_name(root_p, 1);
}


/* Print one tab for each level of recursion, then the name of an unvisited
 * immediate.  Go to the immediate's immediate list and, recursively,
 * print the name of an unvisited immediate.  When the current path is
 * exhausted, back track to an immediate list with unvisited nodes and
 * continue with the next unvisited immediate.
 * 
 * While travering the DCG, maintain an active list of nodes in the current
 * path.  If an active node is revisited, terminate the path and print a
 * `cycle' mark. */
print_name(struct name_node *node, int tabc)
{
	static long line = 0;	/* line number */

	register int i, tabd, tabstar, tflag;
	register struct imm_node *imm_p;

	if (tabc > maxdepth)
		return;
	printf("%ld", ++line);
	if (!makeactive(node))
		printf("   * nesting is too deep\n");
	else {
		tabstar = 0;
		tabd = tabc;
		for (; tabd > ntabs; tabstar++)
			tabd = tabd - ntabs;
		if (tabstar > 0) {
			printf(" ");
			for (i = 0; i < tabstar; i++)
				printf("<");
		}
		if (tabd == 0)
			printf("   ");
		else
			for (i = 0; i < tabd; i++)
				printf("\t");

		/* cycle found */
		if (active(node))
			printf("... %s ... {%ld}\n", node->imm_name, node->name_visited);
		else {
			if (node->imm_list) {
				printf("%s", node->imm_name);
				imm_p = node->imm_list->next;
				if (expand_all || !node->name_visited) {
					printf(" %s", node->imm_ref);
					++tabc;
					if (!node->name_visited)
						node->name_visited = line;
/*                  if (tabc > ntabs && tabc%ntabs==1 && imm_p)
 * {
 * printf("%s\n", dashes);
 * tflag = 1;
 * }
 * else
 * tflag = 0;
 */
					for (; imm_p; imm_p = imm_p->next)
						print_name(imm_p->name_node_p, tabc);
/*                  if (tflag)
 * {
 * printf("%s\n", dashes);
 * tflag = 0;
 * }
 */
				} else
					printf(" ... {%ld}\n", node->name_visited);
			}
			/* library or external call */
			else
				printf("%s {}\n", node->imm_name);
		}
		backup();
	}
	return;
}

struct name_node *active_node[DEPTH_MAX];	/* current path */
int active_p = 0;		/* current path size */

/* makeactive simply puts a pointer to the nameblock into a stack with
 * maximum depth DEPTH_MAX. the error return only happens for stack
 * overflow. */
makeactive(struct name_node *node)
{
	if (active_p < DEPTH_MAX) {
		active_node[active_p] = node;
		active_p++;
		return 1;
	}
	return 0;
}

/* backup removes an item from the active stack */
backup(void)
{
	if (active_p)
		active_node[active_p--] = 0;
}

/* active checks whether the pointer which is its argument has already
 * occurred on the active list, and returns 1 if so.  */
active(struct name_node *node)
{
	register int i;

	for (i = 0; i < active_p - 1; i++)
		if (node == active_node[i])
			return 1;
	return 0;
}

/* accepts a pointer to a name and sees if the name is on the name list.
 * If so, it returns a pointer to the nameblock. Otherwise it returns
 * zero. If the name from argv is > NAME_MAX-1, then it is truncated.  */
struct name_node *
 nlist_contains(char *s)
{
	struct name_node *np = nlist;

	if (strlen(s) > NAME_MAX - 1)
		s[NAME_MAX - 1] = '\0';

	for (np = nlist; np; np = np->next)
		if (strcmp(s, np->imm_name) == 0)
			return np;
	return 0;
}
