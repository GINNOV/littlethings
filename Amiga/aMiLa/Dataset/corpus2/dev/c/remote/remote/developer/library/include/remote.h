#ifndef REMOTE_H
#define REMOTE_H
/*
**      $Filename: fd/api.h
**      $Release: 1.0
**
**      remote.library definitions
**
**      (C) Copyright 1997 Dietmar Eilert
**          All Rights Reserved
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef WORKBENCH_WORKBENCH_H
#include <workbench/workbench.h>
#endif

/* error codes */

#define REMOTE_ERR_SCANDISK         1L
#define REMOTE_ERR_INVALID_CLASS    2L
#define REMOTE_ERR_INVALID_NAME     3L
#define REMOTE_ERR_INVALID_FILE     4L
#define REMOTE_ERR_INVALID_PATH     5L
#define REMOTE_ERR_INVALID_PATTERN  6L
#define REMOTE_ERR_INVALID_SYNTAX   7L
#define REMOTE_ERR_INVALID_LF       8L
#define REMOTE_ERR_INVALID_CONFIG   9L
#define REMOTE_ERR_INVALID_PORT     10L
#define REMOTE_ERR_INVALID_SAVE     11L
#define REMOTE_ERR_NOMEMORY         12L
#define REMOTE_ERR_STARTUP          13L
#define REMOTE_ERR_APPNOTFOUND      14L
#define REMOTE_ERR_VALIDATE         15L
#define REMOTE_ERR_STACKOVERFLOW    16L

/* flags for RemoteValidate() */

#define REMOTE_VALIDATE_SMART       (1L<<1)
#define REMOTE_VALIDATE_DEEP        (1L<<2)

/* flags for RemoteOpen() (don't depend on the REMOTE_OPEN_SYNC flag - some apps always detach) */

#define REMOTE_OPEN_SYNC            (1L<<1)
#define REMOTE_OPEN_ASYNC           (1L<<2)

#endif
