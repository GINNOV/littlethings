
/* The executable was created by compiling this file to object code,
 * and then linking with "earth.lib", like so:
 *
 * PPLink c.o TestEarth.o LIB link:earth.lib link:amiga.lib
 *
 * You should, however, be able to recompile this on your own setup.
 * Don't forget to move "earth.lib" into the appropriate directory.
 */

#include "stdio.h"
#include "exec/types.h"
#include "earth/earthbase.h"

char VERSIONSTRING[] = "$VER: TestEarth 1.0 (05.09.92)";

struct EarthBase *EarthBase;
struct Hook myHook;
struct TreeHeader myTree;

/* Declare the LVO constant */
extern LVO LVONodeValueCmp;

/* Declare some functions (to be defined below) */
PrintTreeNode();
DeleteTreeNode();

main()
{
  int i;
  struct TreeNode *node;

  EarthBase = (struct EarthBase *) OpenLibrary(EARTHNAME,EARTHVERSION);
  if (EarthBase == NULL) printf("Couldn't open earth.library\n");
  else
  {
    /* Initialise a Tree structure */
    InitLibraryHook( &myHook, EarthBase, LVONodeValueCmp );
    InitTree( &myTree, &myHook );

    /* Add fifteen items to the tree */
    for (i=0; i<15; i++)
    {
      node = (struct TreeNode *) AllocMem( sizeof(struct TreeNode), 0 );
      if (node == NULL) break;
      node->tn_Value = i;
      AddTreeNode(&myTree, node, FALSE);
    }

    /* Print the tree in its original form */
    printf("Before:\n");
    ForEachTreeNode( &myTree, &PrintTreeNode, 0, ORDER_DEPTHLAST );

    /* Balance the tree */
    BalanceTree( &myTree );

    /* Now print the tree in its new form */
    printf("\nAfter:\n");
    ForEachTreeNode( &myTree, &PrintTreeNode, 0, ORDER_DEPTHLAST );

    /* Finally, delete the tree */
    ForEachTreeNode( &myTree, &DeleteTreeNode, 0, ORDER_DEPTHFIRST );

    CloseLibrary(EarthBase);
  }
}

/*==============================================================
 * Now for a function to print an individual node.
 * We will indent each value according to the depth of the node,
 * so that the output looks pretty.
 */

PrintTreeNode(node,userdata,depth)
struct TreeNode *node;
LONG userdata;
ULONG depth;
{
  int i;
  for (i=0; i<depth; i++) printf("--");		/* Indent the line */
  printf("> %d\n", node->tn_Value);		/* Print the value */
  return 0;		/* Important! */
}

/*==============================================================
 * And a function to delete an individual node.
 * Note that since the nodes are processed depth first,
 * it is guaranteed that this node will not have any descendants.
 */

DeleteTreeNode(node,userdata,depth)
struct TreeNode *node;
LONG userdata;
ULONG depth;
{
  FreeMem( node, sizeof(struct TreeNode) );	/* Free the node */
  return 0;		/* Important! */
}

