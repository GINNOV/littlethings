#ifndef	EARTH_EARTHBASE_H
#define EARTH_EARTHBASE_H

/* $VER: earth_earthbase_i 1.0 (05.09.92) */

#include "earth/libraries.h"
#include "exec/semaphores.h"

#ifdef LIBRARY_MINIMUM
#include "utility/hooks.h"
#endif

/*
 * Define the library base structure.
 */

struct EarthBase
{
  struct StdLibrary		earth_Library;
  struct Library		*earth_ArpBase;
  struct Library		*earth_UtilityBase;
  struct Library		*earth_IconBase;
  UBYTE				earth_CharTable[256];
  struct SignalSemaphore	earth_Semaphore;
  ULONG				earth_RandSeed;
};

/*
 * Name and version.
 */

#define EARTHNAME	"earth.library"
#define EARTHVERSION	1

/*==========================
 * Character attribute flags
 *==========================
 */

#define	CHRB_CTRL	0
#define	CHRB_SPACE	1
#define	CHRB_DIGIT	2
#define	CHRB_HEX	3
#define	CHRB_LOWER	4
#define	CHRB_UPPER	5
#define	CHRB_PUNCT	6
#define	CHRB_GRAPH	7

#define	CHRF_CTRL	(1<<CHRB_CTRL)
#define	CHRF_SPACE	(1<<CHRB_SPACE)
#define	CHRF_DIGIT	(1<<CHRB_DIGIT)
#define	CHRF_HEX	(1<<CHRB_HEX)
#define	CHRF_LOWER	(1<<CHRB_LOWER)
#define	CHRF_UPPER	(1<<CHRB_UPPER)
#define	CHRF_PUNCT	(1<<CHRB_PUNCT)
#define	CHRF_GRAPH	(1<<CHRB_GRAPH)

/*========================================================
 * Hook structure (for users who don't have release 2.0+)
 *========================================================
 */

#ifndef LIBRARY_MINIMUM			/* ie. if WB1.3 or less */
struct Hook_WB1Compatable
{
  struct MinNode	h_MinNode;	/* Node for linked list */
  APTR			h_Entry;	/* Function entry point */
  APTR			h_SubEntry;	/* High-Level-Language entry point */
  APTR			h_Data;		/* Address of private data */
};
#define Hook Hook_WB1Compatable
#endif

/*=======================
 * Binary tree structures
 *=======================
 */

/*------------------*/
/**** TreeHeader ****/
/*------------------*/

struct TreeHeader
{
  struct TreeNode	*th_Head;	/* Address of first node in tree */
  struct MinList	th_MinList;	/* List of callback hooks */
};

/*----------------*/
/**** TreeNode ****/
/*----------------*/

struct TreeNode
{
  struct TreeNode	*tn_Less;	/* Address of less-than node */
  struct TreeNode	*tn_Greater;	/* Address of greater-than-or-equal-to node */
  union
  {
    ULONG		tnu_Value;	/* Node value */
    char		*tnu_Name;	/* Node name */
  }			tn_Union;
};

#define tn_Value	tn_Union.tnu_Value
#define tn_Name		tn_Union.tnu_Name

/*-------------------*/
/**** MinTreeNode ****/
/*-------------------*/

struct MinTreeNode
{
  struct MinTreeNode	*tn_Less;	/* Address of less-than node */
  struct MinTreeNode	*tn_Greater;	/* Address of greater-than-or-equal-to node */
};

/* Constants to pass to ForEachTreeNode()... */

#define	ORDER_DEPTHFIRST	0
#define	ORDER_DEPTHLAST		1
#define	ORDER_ASCENDING		2
#define	ORDER_DESCENDING	3

#endif
