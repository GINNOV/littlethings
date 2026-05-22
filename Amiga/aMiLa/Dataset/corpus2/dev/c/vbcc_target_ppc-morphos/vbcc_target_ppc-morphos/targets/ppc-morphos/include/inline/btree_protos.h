#ifndef _VBCCINLINE_BTREE_H
#define _VBCCINLINE_BTREE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __CreateTree(void *, ULONG Type, const struct BTArgArray * argArray) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define CreateTree(Type, argArray) __CreateTree(BTreeBase, (Type), (argArray))

void __DeleteTree(void *, APTR Tree) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define DeleteTree(Tree) __DeleteTree(BTreeBase, (Tree))

APTR __InsertTreeNode(void *, APTR Tree, const APTR Key, const APTR Data) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define InsertTreeNode(Tree, Key, Data) __InsertTreeNode(BTreeBase, (Tree), (Key), (Data))

void __DeleteTreeNode(void *, APTR Tree, APTR tNode) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define DeleteTreeNode(Tree, tNode) __DeleteTreeNode(BTreeBase, (Tree), (tNode))

APTR __GetTreeNodeKey(void *, const APTR Tree, const APTR tNode) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetTreeNodeKey(Tree, tNode) __GetTreeNodeKey(BTreeBase, (Tree), (tNode))

APTR __GetTreeNodeData(void *, const APTR Tree, const APTR tNode) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetTreeNodeData(Tree, tNode) __GetTreeNodeData(BTreeBase, (Tree), (tNode))

APTR __SuccTreeNode(void *, const APTR Tree, const APTR tNode) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SuccTreeNode(Tree, tNode) __SuccTreeNode(BTreeBase, (Tree), (tNode))

APTR __PredTreeNode(void *, const APTR Tree, const APTR tNode) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PredTreeNode(Tree, tNode) __PredTreeNode(BTreeBase, (Tree), (tNode))

APTR __MinTreeNode(void *, const APTR Tree) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MinTreeNode(Tree) __MinTreeNode(BTreeBase, (Tree))

APTR __MaxTreeNode(void *, const APTR Tree) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MaxTreeNode(Tree) __MaxTreeNode(BTreeBase, (Tree))

APTR __FindTreeNodeByKey(void *, const APTR Tree, const APTR Key) =
	"\tlwz\t0,-88(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindTreeNodeByKey(Tree, Key) __FindTreeNodeByKey(BTreeBase, (Tree), (Key))

APTR __FindTreeNodeByData(void *, const APTR Tree, const APTR Data) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindTreeNodeByData(Tree, Data) __FindTreeNodeByData(BTreeBase, (Tree), (Data))

ULONG __ForTreeNodes(void *, const APTR Tree, void (*nodeFunc)(APTR userData, const APTR Node), const APTR userData) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ForTreeNodes(Tree, nodeFunc, userData) __ForTreeNodes(BTreeBase, (Tree), (nodeFunc), (userData))

ULONG __EnumTreeNodes(void *, const APTR Tree, const APTR lowKey, const APTR highKey, LONG (*nodeFunc)(APTR userData, const APTR Node), const APTR userData) =
	"\tlwz\t0,-106(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define EnumTreeNodes(Tree, lowKey, highKey, nodeFunc, userData) __EnumTreeNodes(BTreeBase, (Tree), (lowKey), (highKey), (nodeFunc), (userData))

ULONG __GetTreeSize(void *, const APTR Tree) =
	"\tlwz\t0,-112(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetTreeSize(Tree) __GetTreeSize(BTreeBase, (Tree))

ULONG __GetTreeHeight(void *, const APTR Tree) =
	"\tlwz\t0,-118(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetTreeHeight(Tree) __GetTreeHeight(BTreeBase, (Tree))

void __FlushTree(void *, APTR Tree) =
	"\tlwz\t0,-124(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FlushTree(Tree) __FlushTree(BTreeBase, (Tree))

APTR __SetTreeNodeData(void *, const APTR Tree, APTR tNode, const APTR NewData) =
	"\tlwz\t0,-130(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SetTreeNodeData(Tree, tNode, NewData) __SetTreeNodeData(BTreeBase, (Tree), (tNode), (NewData))

#endif /*  _VBCCINLINE_BTREE_H  */
