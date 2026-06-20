/*-------------------------------------------------------------------------
 * tox - an XML tokenizer
 *
 * Copyright (c) 2000 Eckhart Köppen
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *-----------------------------------------------------------------------*/

/* $Id: tox.h,v 1.11 2002/05/01 03:14:34 koeppen Exp $ */

#ifndef __TOX_H
#define __TOX_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
	STATE_ERROR = -2,
	STATE_END = -1,
	STATE_CONTENT = 0,
	STATE_STARTTAG_START = 1,
	STATE_REF_START = 2,
	STATE_CHARDATA = 3,
	STATE_ENDTAG_START = 4,
	STATE_STARTTAG_NAME = 5,
	STATE_REF_NAME = 6,
	STATE_ENDTAG_NAME = 7,
	STATE_STARTTAG_NAMEEND = 8,
	STATE_ENDTAG_NAMEEND = 9,
	STATE_ATTR_NAME = 10,
	STATE_ATTR_NAMEEND = 11,
	STATE_ATTR_VALSTART = 12,
	STATE_ATTR_VALDQUOT = 13,
	STATE_EMPTYTAG_END = 14,
	STATE_ATTR_VALDQUOT_REF = 15,
	STATE_ATTR_VDQ_REFNAME = 16,
	STATE_ATTR_VALSQUOT = 17,
	STATE_ATTR_VALSQUOT_REF = 18,
	STATE_ATTR_VSQ_REFNAME = 19,
	STATE_DTD_START = 20,
	STATE_MARKUPDECL_START = 21,
	STATE_CDATA = 22,
	STATE_CDATA_1ST_BRACKET = 23,
	STATE_CDATA_2ND_BRACKET = 24,
	STATE_PI = 25,
	STATE_PI_END_QMARK = 26,
	STATE_COMMENT = 27,
	STATE_COMMENT_1ST_DASH = 28,
	STATE_COMMENT_2ND_DASH = 29,
	STATE_REF_NUMBER = 30,
	STATE_REF_HEX_NUMBER_1 = 31,
	STATE_REF_HEX_NUMBER = 32,
	STATE_REF_DEC_NUMBER = 33,
	STATE_WS_CONTENT = 34,
	STATE_WORD_CONTENT = 35,
	STATE_COMMENT_START_1ST = 36,
	STATE_DOCTYPE_D = 37,
	STATE_DOCTYPE_O = 38,
	STATE_DOCTYPE_C = 39,
	STATE_DOCTYPE_T = 40,
	STATE_DOCTYPE_Y = 41,
	STATE_DOCTYPE_P = 42,
	STATE_CDATA_BRACKET = 43,
	STATE_CDATA_C = 44,
	STATE_CDATA_D = 45,
	STATE_CDATA_A = 46,
	STATE_CDATA_T = 47,
	STATE_CDATA_A2 = 48,
	STATE_ATTR_VALTOKEN = 49,
#ifdef HTML	
	STATE_FIND_STRING = 50
#endif	
} tokenizer_state;

#ifdef HTML
#define FONT_STYLE_MASK			0x0000000f
#define FONT_STYLE_PLAIN		0x00000000
#define FONT_STYLE_BOLD			0x00000001
#define FONT_STYLE_ITALIC		0x00000002
#define FONT_STYLE_UNDERLINE	0x00000004

#define FONT_SIZE_MASK			0x000000f0
#define FONT_SIZE_MEDIUM		0x00000000
#define FONT_SIZE_SMALL			0x00000010
#define FONT_SIZE_BIG			0x00000020

#define FONT_FACE_MASK			0x00000f00
#define FONT_FACE_PROPORTIONAL	0x00000000
#define FONT_FACE_MONOSPACED	0x00000100
#endif

struct _parser_state;

typedef void (callback)(struct _parser_state *);

typedef struct _parser_state
{
	char *text;
	int current;
	int maxtext;
	int char_width;
	int swap_bytes;

	tokenizer_state state;

	char pump;
	char *buffer;
	int bcurrent;
	int maxbuf;

	int squoteLevel;
	int dquoteLevel;
	int angleBracketLevel;
	
#ifdef HTML
	char preformatted;
	char saw_newline;
	char saw_whitespace;
	char *find_string;
	int find_string_current;
	char anchor_active;
	
	int block_style;
	int current_style;
#endif

	callback *element_callback;
	callback *attrname_callback;
	callback *attrval_callback;
	callback *word_callback;
	callback *ws_callback;
	callback *entity_callback;
	
	void *userdata;
} parser_state;

void tox_parse (parser_state *parser);

#ifdef __cplusplus
}
#endif

#endif
