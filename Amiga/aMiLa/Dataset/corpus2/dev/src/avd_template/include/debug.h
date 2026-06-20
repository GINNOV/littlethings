/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 9/25/2003
 *---------------------------------------------------------------------
 * Copyright (c) 2003 BITbyBIT Software Group, All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * BITbyBIT Software Group (Confidential Information).  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with BITbyBIT Software Group.
 *
 * BITbyBIT SOFTWARE GROUP MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
 * SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * BITbyBIT Software Group LLC SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
 * LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
 * SOFTWARE OR ITS DERIVATIVES.
 *---------------------------------------------------------------------
 *
 * Project: All
 *
 * Description: This file defines a useful set of DEBUG output C Macros
 *
 * $VER: debug.h 1.0
 * 
 */

#ifndef _DEBUG_H_INCLUDED_
#define _DEBUG_H_INCLUDED_

/* Define DEBUG Macro wrapper */
#ifdef DEBUG

#define D(x) x
#define DEBUG_ENTER(format,...)          printf("->%s" format " [from file %s,line #%d]\n",__FUNCTION__,##__VA_ARGS__,__FILE__,__LINE__);
#define DEBUG_TEXT(text)                 printf("%s(): " text " [from file %s,line #%d]\n",__FUNCTION__,__FILE__,__LINE__);
#define DEBUG_MSG(format,...)            printf("%s(): " format " [from file %s,line #%d]\n",__FUNCTION__,##__VA_ARGS__,__FILE__,__LINE__);
#define DEBUG_IF_MSG(if_true,format,...) if ( if_true ) printf("%s() Reports: " format " [from file %s,line #%d]\n",__FUNCTION__,##__VA_ARGS__,__FILE__,__LINE__);
#define DEBUG_PLAIN_IF_MSG(if_true,format,...) if ( if_true ) printf("" format "",##__VA_ARGS__);
#define DEBUG_PLAIN_MSG(format,...)      printf("" format "",##__VA_ARGS__);
#define DEBUG_EXIT(results,format,...)   printf("<-%s = %s" format " [from file %s,line #%d]\n",results,__FUNCTION__,##__VA_ARGS__,__FILE__,__LINE__);

#else

#define D(x)
#define DEBUG_ENTER(format,...)
#define DEBUG_TEXT(text)
#define DEBUG_MSG(format,...)
#define DEBUG_IF_MSG(if_true,format,...)
#define DEBUG_PLAIN_IF_MSG(if_true,format,...)
#define DEBUG_PLAIN_MSG(format,...)
#define DEBUG_EXIT(results,format,...)

#endif /* DEBUG */

#endif /* _DEBUG_H_INCLUDED */
