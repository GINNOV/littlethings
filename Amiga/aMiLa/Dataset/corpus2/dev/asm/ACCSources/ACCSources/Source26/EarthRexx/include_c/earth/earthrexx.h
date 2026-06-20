#ifndef 	EARTH_EARTHREXX_H
#define 	EARTH_EARTHREXX_H

#include	"exec/types.h"
#include	"exec/ports.h"
#include	"exec/lists.h"
#include	"exec/nodes.h"
#include	"exec/libraries.h"

#include	"rexx/storage.h"
#include	"rexx/errors.h"

/*==================================================================
 *	Private structures
 *==================================================================
 *
 * Note that the REAL definitions of these structures are PRIVATE.
 * This is because the definitions may change from one library version to
 * another.
 *
 * The pseudo-definitions below are merely to allow you to declare
 * pointers to them.
 *
 * Note also that the sizeof() operator will give the wrong answer for
 * these structures. The REAL length may change from one library version
 * to another.
 */

struct MemoPad
{
  LONG		memp_Private;
};

struct RexxReplyInfo
{
  LONG		rri_Private;
};

struct GlobalRexxPort
{
  LONG		grp_Private;
};

/*==================================================================
 *	 EarthRexxBase
 *==================================================================
 */
struct EarthRexxBase
{
  struct Library	erb_Library;	/* The embedded Library structure */
  struct Library *	_ExecBase;	/* Base of exec.library */
  struct Library *	_ArpBase;	/* Base of arp.library */
  struct Library *	_IntuitionBase; /* Base of intuition.library */
  struct Library *	_RexxBase;	/* Base of rxsyslib.library [or NULL] */
  struct Resource *	erb_Resource;	/* Base of earthrexx.resource */
  BPTR			erb_SegList;	/* Library segment */
  BYTE			erb_AREXX[1];	/* Instance of string "AREXX" */
  BYTE			erb_REXX[5];	/* Instance of string "REXX" */
};

/*==================================================================
 *	 CmdEntry
 *==================================================================
 *
 * This is the default structure for specifying commands and functions.
 * You supply an array of these structures, terminated by a NULL longword.
 */

struct CmdEntry
{
  BYTE *cme_CmdName;		/* Pointer to command name */
  LONG (*cme_Handler)();        /* Pointer to handler entry point */
};

/*==================================================================
 *	 NewRexxPort
 *==================================================================
 *
 * The NewRexxPort structure....
 * Allocate or otherwise obtain one of these.
 * Fill in EVERY field.
 * Then call OpenRexxPort().
 * On return you get a struct RexxPort.
 * You are then free to deallocate or reuse the NewRexxPort.
 */
struct NewRexxPort
{
  BYTE *nrp_PortName;		/* Pointer to name of ARexx port */
  BYTE *nrp_Extension;		/* Pointer to extension string */
  struct CmdEntry *nrp_Commands;   /* Address of command table */
  struct CmdEntry *nrp_Functions;  /* Address of function table */
  UWORD nrp_UserFlags;		/* Various flags - see below */
  BYTE nrp_Priority;		/* Port priority */
  BYTE nrp_FHPriority;		/* Function host priority */
  LONG (*nrp_DispatchFn)();     /* Address of user dispatch function */
  LONG (*nrp_PassFn)();         /* Address of user pass function */
  LONG (*nrp_FailFn)();         /* Address of user fail function */
  ULONG nrp_StackSize;		/* Stack size for recursions */
};

/* Various flags may fill the nrp_UserFlags field. */
/* These are as follows: */
/* (first the bit numbers) */

#define RPB_OLDCAT	0	/* Set to use pre-existing MemoPad/ClipList */
#define RPB_ERRORS	1	/* Set to use default FailFn() routine */
#define RPB_COMPACT	2	/* Set to use compact cmd/func tables */
#define RPB_CASE	3	/* Set to use case sensitive comparisons */
#define RPB_ABBREV	4	/* Set to allow abbreviations */
#define RPB_SPACES	5	/* Set to allow embedded spaces */
#define RPB_CLIPLIST	6	/* Set to use cliplist for cmd/func tables */
#define RPB_MEMOPAD	7	/* Set to use memopads for cmd/func tables */
#define RPB_NONSTD	8	/* Set to allow nonstandard Rexx invokations */
#define RPB_DEADEND	9	/* Set to fail messages not understood */
#define RPB_SINGLE	10	/* Set to use single-port model */
#define RPB_ACTIVE	11	/* Set to come up active */
#define RPB_INACTIVE	12	/* Set to come up inactive */
#define RPB_NEWSTACK	13	/* Set to give recursions new stack */

/* (Then the fields) */

#define RPF_OLDCAT	(1<<RPB_OLDCAT)
#define RPF_ERRORS	(1<<RPB_ERRORS)
#define RPF_COMPACT	(1<<RPB_COMPACT)
#define RPF_CASE	(1<<RPB_CASE)
#define RPF_ABBREV	(1<<RPB_ABBREV)
#define RPF_SPACES	(1<<RPB_SPACES)
#define RPF_CLIPLIST	(1<<RPB_CLIPLIST)
#define RPF_MEMOPAD	(1<<RPB_MEMOPAD)
#define RPF_NONSTD	(1<<RPB_NONSTD)
#define RPF_DEADEND	(1<<RPB_DEADEND)
#define RPF_SINGLE	(1<<RPB_SINGLE)
#define RPF_ACTIVE	(1<<RPB_ACTIVE)
#define RPF_INACTIVE	(1<<RPB_INACTIVE)
#define RPF_NEWSTACK	(1<<RPB_NEWSTACK)

/*==================================================================
 *	 RexxPort
 *==================================================================
 *
 * The RexxPort structure....
 * Strictly READ-ONLY! No write access is allowed,
 * except through prescribed functions and macros.
 */
struct RexxPort
{
		/* The embedded message port */
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~ */

  struct MsgPort	rp_Port;	/* The port itself */

		/* The NewRexxPort copy */
		/* ~~~~~~~~~~~~~~~~~~~~ */

  BYTE *		rp_PortName;	/* Global port name */
  BYTE *		rp_Extension;	/* Pointer to extension string (or NULL) */
  APTR			rp_Commands;	/* Address of command table (or NULL) */
  APTR			rp_Functions;	/* Address of function table (or NULL) */
  UWORD 		rp_UserFlags;	/* Various flags - see above */
  BYTE			rp_GlobSigBit;	/* Global port signal bit */
  BYTE			rp_FHPriority;	/* Function host priority */
  APTR			rp_DispatchFn;	/* Address of user dispatch function (or NULL) */
  APTR			rp_PassFn;	/* Address of user pass function (or NULL) */
  APTR			rp_FailFn;	/* Address of user fail function (or NULL) */
  ULONG 		rp_StackSize;	/* Stack size for recursions (or zero) */

		/* Other fields of possible interest to user */
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  ULONG 		rp_UserData;	/* Anything you like */
  ULONG 		rp_WaitMask;	/* Mask to Wait() on for Rexx messages */
  BYTE *		rp_HostAddress1; /* Primary host address */
  BYTE *		rp_HostAddress2; /* Secondary host address */

		/* The rest of the structure - All this is private! */
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  ULONG 		rp_PrivSigMask; /* Signal mask for this port */
  ULONG 		rp_GlobSigMask; /* Signal mask for global port */
  struct MsgPort *	rp_GlobalPort;	/* Address of global port */
  UWORD 		rp_MsgCount;	/* Counts messages we haven't had replied yet */
  UWORD 		rp_SysFlags;	/* System flags - see below */
  struct MinNode	rp_Link;	/* Link to sibling ports */
};

/* Various flags may fill the rp_SysFlags field. */
/* These are as follows: */
/* (First the bit numbers) */

#define RPSB_READY	0	/* Set if port is ready to recieve */
#define RPSB_NOREPLY	1	/* Set to prevent msg from being replied */
#define RPSB_SHUTDOWN	2	/* Set if closing down the port */
#define RPSB_REQUEST	3	/* Set if StdFailFn wants requester */

/* (Then the fields) */

#define RPSF_READY	(1<<RPSB_READY)
#define RPSF_NOREPLY	(1<<RPSB_NOREPLY)
#define RPSF_SHUTDOWN	(1<<RPSB_SHUTDOWN)
#define RPSF_REQUEST	(1<<RPSB_REQUEST)

/*==================================================================
 *	 Action codes for messages expressed as bytes
 *==================================================================
 */

#define RX_COMM 	(RXCOMM>>24)
#define RX_FUNC 	(RXFUNC>>24)
#define RX_CLOSE	(RXCLOSE>>24)
#define RX_QUERY	(RXQUERY>>24)
#define RX_ADDFH	(RXADDFH>>24)
#define RX_ADDLIB	(RXADDLIB>>24)
#define RX_REMLIB	(RXREMLIB>>24)
#define RX_ADDCON	(RXADDCON>>24)
#define RX_REMCON	(RXREMCON>>24)
#define RX_TCOPN	(RXTCOPN>>24)
#define RX_TCCLS	(RXTCCLS>>24)

/*===================================================================
 *	  ARexx error codes
 *===================================================================
 */

#define RXERR_PROGRAM_NOT_FOUND 		ERR10_001
#define RXERR_EXECUTION_HALTED			ERR10_002
#define RXERR_NO_MEMORY 			ERR10_003
#define RXERR_INVALID_CHARACTER 		ERR10_004
#define RXERR_UNMATCHED_QUOTE			ERR10_005
#define RXERR_UNTERMINATED_COMMENT		ERR10_006
#define RXERR_CLAUSE_TOO_LONG			ERR10_007
#define RXERR_UNRECOGNISED_TOKEN		ERR10_008
#define RXERR_UNRECOGNIZED_TOKEN		ERR10_008
#define RXERR_SYMBOL_TOO_LONG			ERR10_009
#define RXERR_STRING_TOO_LONG			ERR10_009

#define RXERR_INVALID_MESSAGE_PACKET		ERR10_010
#define RXERR_COMMAND_STRING_ERROR		ERR10_011
#define RXERR_ERROR_RETURN			ERR10_012
#define RXERR_HOST_NOT_FOUND			ERR10_013
#define RXERR_LIBRARY_NOT_FOUND 		ERR10_014
#define RXERR_FUNCTION_NOT_FOUND		ERR10_015
#define RXERR_NO_RETURN_VALUE			ERR10_016
#define RXERR_WRONG_NUMBER_OF_ARGUMENTS 	ERR10_017
#define RXERR_INVALID_ARGUMENT			ERR10_018
#define RXERR_INVALID_PROCEEDURE		ERR10_019

#define RXERR_UNEXPECTED_THEN			ERR10_020
#define RXERR_UNEXPECTED_ELSE			ERR10_020
#define RXERR_UNEXPECTED_WHEN			ERR10_021
#define RXERR_UNEXPECTED_OTHERWISE		ERR10_021
#define RXERR_UNEXPECTED_LEAVE			ERR10_022
#define RXERR_UNEXPECTED_ITERATE		ERR10_022
#define RXERR_SELECT_ERROR			ERR10_023
#define RXERR_MISSING_THEN			ERR10_024
#define RXERR_MISSING_OTHERWISE 		ERR10_025
#define RXERR_MISSING_END			ERR10_026
#define RXERR_UNEXPECTED_END			ERR10_026
#define RXERR_SYMBOL_MISMATCH			ERR10_027
#define RXERR_INVALID_DO			ERR10_028
#define RXERR_INCOMPLETE_DO			ERR10_029
#define RXERR_INCOMPLETE_IF			ERR10_029
#define RXERR_INCOMPLETE_SELECT 		ERR10_029

#define RXERR_LABEL_NOT_FOUND			ERR10_030
#define RXERR_SYMBOL_EXPECTED			ERR10_031
#define RXERR_STRING_EXPECTED			ERR10_032
#define RXERR_INVALID_SUB_KEYWORD		ERR10_033
#define RXERR_KEYWORD_MISSING			ERR10_034
#define RXERR_EXTRANEOUS_CHARACTERS		ERR10_035
#define RXERR_SUB_KEYWORD_CONFLICT		ERR10_036
#define RXERR_INVALID_TEMPLATE			ERR10_037
#define RXERR_INVALID_TRACE_REQEST		ERR10_038
#define RXERR_UNINITIALISED_VARIABLE		ERR10_039

#define RXERR_INVALID_NAME			ERR10_040
#define RXERR_INVALID_EXPRESSION		ERR10_041
#define RXERR_UNBALANCED_PARENTHESES		ERR10_042
#define RXERR_NEST_TOO_DEEP			ERR10_043
#define RXERR_INVALID_RESULT			ERR10_044
#define RXERR_EXPRESSION_REQUIRED		ERR10_045
#define RXERR_INVALID_BOOLEAN			ERR10_046
#define RXERR_ARITHMETIC_ERROR			ERR10_047
#define RXERR_INVALID_OPERAND			ERR10_048

/*==================================================================
 *	 Useful defines
 *==================================================================
 */

#define EARTHREXXNAME	"earthrexx.library"     /* Library name */
#define EARTHREXXVERSION 2			/* Current library version */

#define RP_OK		0	/* All OK */
#define RP_NOREPLY	(-129)  /* Postpone reply of message */
#define RP_STRING	(-131)  /* Convert string to argstring */
#define RP_ARGSTRING	(-133)  /* Copy argstring */
#define RP_PACKED	(-135)  /* Convert address to packed argstring */
#define RP_DECIMAL	(-137)  /* Convert integer to decimal argstring */
#define RP_SYNC 	(-139)  /* Send synchronous message */

#define ASPack(x)       (NewCreateArgstring(&(x),4))
#define ASUnpack(x)     (*((LONG *)(x)))

/*==================================================================
 *	 That's All Folks!
 *==================================================================
 */

#endif

