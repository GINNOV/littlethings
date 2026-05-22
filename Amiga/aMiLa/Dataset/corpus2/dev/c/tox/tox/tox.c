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

#include "tox.h"

typedef enum {
	TYPE_RANGE,
	TYPE_EXACT,
	TYPE_CHAR,
	TYPE_SPECIAL,
	TYPE_END
} accept_type_values;

#define SPECIAL_SKIP_DTD 	0
#define SPECIAL_FIND_STRING 1

#define RANGE_LETTER     0
#define RANGE_CHAR       1
#define RANGE_WS         2
#define RANGE_NAMECHAR   3
#define RANGE_HEX        4
#define RANGE_DEC        5

typedef unsigned short char_t;

typedef struct
{
	accept_type_values accept_type;
	char_t accept_value;
	tokenizer_state next_state;
	unsigned char action;
} state_def;

typedef struct
{
	char_t start;
	char_t end;
} char_range;

const char_range range_table[][12] = {
    /* letter */
    {
        {0x0041, 0x005A},
        {0x0061, 0x007A},
        {0x00C0, 0x00D6},
        {0x00D8, 0x00F6},
        {0x00F8, 0x00FF}
    },
        /* character */
    {
        {0x0009, 0x0009},
        {0x000A, 0x000A},
        {0x000D, 0x000D},
        {0x0020, 0x00FF}
    },
        /* whitespace */
    {
        {0x0009, 0x0009},
        {0x000A, 0x000A},
        {0x000D, 0x000D},
        {0x0020, 0x0020},
    },
    /* name character */
    {
        {'.', '.'},
        {'-', '-'},
        {'_', '_'},
        {':', ':'},
        {0x0030, 0x0039},
        {0x0041, 0x005A},
        {0x0061, 0x007A},
        {0x00B7, 0x00B7},
        {0x00C0, 0x00D6},
        {0x00D8, 0x00F6},
        {0x00F8, 0x00FF}
    },
    /* hex numbers */
    {
        {'0', '9'},
        {'a', 'f'},
        {'A', 'F'}
    },
        /* digits */
    {
        {'0', '9'}
    },
};

#define ACTION_PUMP_START        1
#define ACTION_TAGNAME_END       2
#define ACTION_ATTRNAME_END      4
#define ACTION_ATTRVAL_END       8
#define ACTION_WORD_END         16
#define ACTION_WS_END           32
#define ACTION_ENTITY_END	   128

const state_def state_table[][9] = {
    /*  0: STATE_CONTENT */
    {
        {TYPE_EXACT, (char_t) '<', STATE_STARTTAG_START, 0},
        {TYPE_EXACT, (char_t) '&', STATE_REF_START, ACTION_PUMP_START},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_WS_CONTENT, ACTION_PUMP_START},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_WORD_CONTENT, ACTION_PUMP_START},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  1: STATE_STARTTAG_START */
    {
        {TYPE_EXACT, (char_t) '/', STATE_ENDTAG_START, ACTION_PUMP_START},
        {TYPE_EXACT, (char_t) '_', STATE_STARTTAG_NAME, ACTION_PUMP_START},
        {TYPE_EXACT, (char_t) ':', STATE_STARTTAG_NAME, ACTION_PUMP_START},
        {TYPE_EXACT, (char_t) '?', STATE_PI, 0},
        {TYPE_EXACT, (char_t) '!', STATE_MARKUPDECL_START, 0},
#ifdef HTML
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_STARTTAG_NAME, ACTION_PUMP_START},
#else
        {TYPE_RANGE, (char_t) RANGE_LETTER, STATE_STARTTAG_NAME, ACTION_PUMP_START},
#endif		
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  2: STATE_REF_START */
    {
        {TYPE_EXACT, (char_t) '_', STATE_REF_NAME, 0},
        {TYPE_EXACT, (char_t) ':', STATE_REF_NAME, 0},
        {TYPE_EXACT, (char_t) '#', STATE_REF_NUMBER, 0},
        {TYPE_RANGE, (char_t) RANGE_LETTER, STATE_REF_NAME, 0},
#ifdef HTML         
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_WS_CONTENT, ACTION_PUMP_START},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  3: STATE_CHARDATA */
    {
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  4: STATE_ENDTAG_START */
    {
        {TYPE_EXACT, (char_t) '_', STATE_ENDTAG_NAME, 0},
        {TYPE_EXACT, (char_t) ':', STATE_ENDTAG_NAME, 0},
        {TYPE_RANGE, (char_t) RANGE_LETTER, STATE_ENDTAG_NAME, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  5: STATE_STARTTAG_NAME */
    {
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_STARTTAG_NAME, 0},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_STARTTAG_NAMEEND, ACTION_TAGNAME_END},
        {TYPE_EXACT, (char_t) '/', STATE_EMPTYTAG_END, 0},
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, ACTION_TAGNAME_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  6: STATE_REF_NAME */
    {
        {TYPE_EXACT, (char_t) ';', STATE_CONTENT, ACTION_ENTITY_END},
#ifdef HTML         
        {TYPE_EXACT, (char_t) '&', STATE_CONTENT, ACTION_ENTITY_END},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_CONTENT, ACTION_ENTITY_END},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_REF_NAME, 0},
#else
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_REF_NAME, 0},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  7: STATE_ENDTAG_NAME */
    {
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_ENDTAG_NAME, 0},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_ENDTAG_NAMEEND, ACTION_TAGNAME_END},
        /*   {TYPE_EXACT, (char_t) '/', STATE_EMPTYTAG_END, 0}, ??? */
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, ACTION_TAGNAME_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  8: STATE_STARTTAG_NAMEEND */
    {
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_STARTTAG_NAMEEND,  0},
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT,  0},
        {TYPE_EXACT, (char_t) '/', STATE_EMPTYTAG_END, 0},
        {TYPE_EXACT, (char_t) '_', STATE_ATTR_NAME, ACTION_PUMP_START},
        {TYPE_EXACT, (char_t) ':', STATE_ATTR_NAME, ACTION_PUMP_START},
        {TYPE_RANGE, (char_t) RANGE_LETTER, STATE_ATTR_NAME, ACTION_PUMP_START},
#ifdef HTML
        {TYPE_EXACT, (char_t) '<', STATE_STARTTAG_START,  0}, /* Hack */
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_STARTTAG_NAMEEND,  0},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /*  9: STATE_ENDTAG_NAMEEND */
    {
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_ENDTAG_NAMEEND, 0},
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 10: STATE_ATTR_NAME */
    {
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_ATTR_NAMEEND, ACTION_ATTRNAME_END},
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_ATTR_NAME, 0},
        {TYPE_EXACT, (char_t) '=', STATE_ATTR_VALSTART, ACTION_ATTRNAME_END},
#ifdef HTML
        {TYPE_EXACT, (char_t) '/', STATE_EMPTYTAG_END, ACTION_ATTRNAME_END},
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, ACTION_ATTRNAME_END},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 11: STATE_ATTR_NAMEEND */
    {
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_ATTR_NAMEEND, 0},
        {TYPE_EXACT, (char_t) '=', STATE_ATTR_VALSTART, 0},
#ifdef HTML
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_ATTR_NAME, ACTION_PUMP_START},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 12: STATE_ATTR_VALSTART */
    {
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_ATTR_VALSTART, 0},
        {TYPE_EXACT, (char_t) '"', STATE_ATTR_VALDQUOT, 0},
        {TYPE_EXACT, (char_t) '\'', STATE_ATTR_VALSQUOT, 0},
#ifdef HTML
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_ATTR_VALTOKEN, 0},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 13: STATE_ATTR_VALDQUOT */
    {
        {TYPE_EXACT, (char_t) '"', STATE_STARTTAG_NAMEEND, ACTION_ATTRVAL_END},
#ifndef HTML         
        {TYPE_EXACT, (char_t) '<', STATE_ERROR, 0},
        {TYPE_EXACT, (char_t) '&', STATE_ATTR_VALDQUOT_REF, ACTION_PUMP_START},
#endif         
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_ATTR_VALDQUOT, ACTION_PUMP_START},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 14: STATE_EMPTYTAG_END */
    {
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, 0},
#ifdef HTML         
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_CONTENT, 0},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 15: STATE_ATTR_VALDQUOT_REF */
    {
        {TYPE_EXACT, (char_t) '_', STATE_ATTR_VDQ_REFNAME, 0},
        {TYPE_EXACT, (char_t) ':', STATE_ATTR_VDQ_REFNAME, 0},
        {TYPE_RANGE, (char_t) RANGE_LETTER, STATE_ATTR_VDQ_REFNAME, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 16: STATE_ATTR_VDQ_REFNAME */
    {
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_ATTR_VDQ_REFNAME, 0},
        {TYPE_EXACT, (char_t) ';', STATE_ATTR_VALDQUOT, ACTION_ENTITY_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 17: STATE_ATTR_VALSQUOT */
    {
        {TYPE_EXACT, (char_t) '\'', STATE_STARTTAG_NAMEEND, ACTION_ATTRVAL_END},
#ifndef HTML         
        {TYPE_EXACT, (char_t) '<', STATE_ERROR, 0},
        {TYPE_EXACT, (char_t) '&', STATE_ATTR_VALSQUOT_REF, ACTION_PUMP_START},
#endif         
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_ATTR_VALSQUOT, ACTION_PUMP_START},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 18: STATE_ATTR_VALSQUOT_REF */
    {
        {TYPE_EXACT, (char_t) '_', STATE_ATTR_VSQ_REFNAME, 0},
        {TYPE_EXACT, (char_t) ':', STATE_ATTR_VSQ_REFNAME, 0},
        {TYPE_RANGE, (char_t) RANGE_LETTER, STATE_ATTR_VSQ_REFNAME, 0},
#ifdef HTML
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_ATTR_VALSQUOT, 0},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 19: STATE_ATTR_VSQ_REFNAME */
    {
        {TYPE_RANGE, (char_t) RANGE_NAMECHAR, STATE_ATTR_VSQ_REFNAME, 0},
        {TYPE_EXACT, (char_t) ';', STATE_ATTR_VALSQUOT, ACTION_ENTITY_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 20: STATE_DTD_START */
    {
        {TYPE_SPECIAL, (char_t) SPECIAL_SKIP_DTD, STATE_CONTENT, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 21: STATE_MARKUPDECL_START */
    {
        {TYPE_EXACT, (char_t) '-', STATE_COMMENT_START_1ST, 0},
#ifdef HTML
        {TYPE_CHAR, (char_t) 'D', STATE_DOCTYPE_D, 0},
#else
        {TYPE_EXACT, (char_t) 'D', STATE_DOCTYPE_D, 0},
#endif         
        {TYPE_EXACT, (char_t) '[', STATE_CDATA_BRACKET, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 22: STATE_CDATA */
    {
        {TYPE_EXACT, (char_t) ']', STATE_CDATA_1ST_BRACKET, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_CDATA, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 23: STATE_CDATA_1ST_BRACKET */
    {
        {TYPE_EXACT, (char_t) ']', STATE_CDATA_2ND_BRACKET, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_CDATA, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 24: STATE_CDATA_2ND_BRACKET */
    {
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, 0},
        {TYPE_EXACT, (char_t) ']', STATE_CDATA_2ND_BRACKET, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_CDATA, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 25: STATE_PI */
    {
        {TYPE_EXACT, (char_t) '?', STATE_PI_END_QMARK, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_PI, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 26: STATE_PI_END_QMARK */
    {
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, 0},
        {TYPE_EXACT, (char_t) '?', STATE_PI_END_QMARK, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_PI, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 27: STATE_COMMENT */
    {
        {TYPE_EXACT, (char_t) '-', STATE_COMMENT_1ST_DASH, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_COMMENT, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 28: STATE_COMMENT_1ST_DASH */
    {
        {TYPE_EXACT, (char_t) '-', STATE_COMMENT_2ND_DASH, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_COMMENT, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 29: STATE_COMMENT_2ND_DASH */
    {
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, 0},
#ifdef HTML         
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_COMMENT_2ND_DASH, 0},
#endif         
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 30: STATE_REF_NUMBER */
    {
        {TYPE_EXACT, (char_t) 'x', STATE_REF_HEX_NUMBER_1, 0},
        {TYPE_RANGE, (char_t) RANGE_DEC, STATE_REF_DEC_NUMBER, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 31: STATE_REF_HEX_NUMBER_1 */
    {
        {TYPE_RANGE, (char_t) RANGE_HEX, STATE_REF_HEX_NUMBER, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 32: STATE_REF_HEX_NUMBER */
    {
        {TYPE_RANGE, (char_t) RANGE_HEX, STATE_REF_HEX_NUMBER, 0},
        {TYPE_EXACT, (char_t) ';', STATE_CONTENT, ACTION_ENTITY_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 33: STATE_REF_DEC_NUMBER */
    {
        {TYPE_RANGE, (char_t) RANGE_DEC, STATE_REF_DEC_NUMBER, 0},
        {TYPE_EXACT, (char_t) ';', STATE_CONTENT, ACTION_ENTITY_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 34: STATE_WS_CONTENT */
    {
        {TYPE_EXACT, (char_t) '<', STATE_STARTTAG_START, ACTION_WS_END},
        {TYPE_EXACT, (char_t) '&', STATE_REF_START, ACTION_PUMP_START | ACTION_WS_END},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_WS_CONTENT, 0},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_WORD_CONTENT, ACTION_PUMP_START | ACTION_WS_END},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 35: STATE_WORD_CONTENT */
    {
        {TYPE_EXACT, (char_t) '<', STATE_STARTTAG_START, ACTION_WORD_END},
        {TYPE_EXACT, (char_t) '&', STATE_REF_START, ACTION_PUMP_START | ACTION_WORD_END},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_WS_CONTENT, ACTION_PUMP_START | ACTION_WORD_END},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_WORD_CONTENT, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 36: STATE_COMMENT_START_1ST */
    {
        {TYPE_EXACT, (char_t) '-', STATE_COMMENT, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 37: STATE_DOCTYPE_D */
    {
        {TYPE_CHAR, (char_t) 'O', STATE_DOCTYPE_O, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 38: STATE_DOCTYPE_O */
    {
        {TYPE_CHAR, (char_t) 'C', STATE_DOCTYPE_C, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 39: STATE_DOCTYPE_C */
    {
        {TYPE_CHAR, (char_t) 'T', STATE_DOCTYPE_T, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 40: STATE_DOCTYPE_T */
    {
        {TYPE_CHAR, (char_t) 'Y', STATE_DOCTYPE_Y, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 41: STATE_DOCTYPE_Y */
    {
        {TYPE_CHAR, (char_t) 'P', STATE_DOCTYPE_P, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 42: STATE_DOCTYPE_P */
    {
        {TYPE_CHAR, (char_t) 'E', STATE_DTD_START, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 43: STATE_CDATA_BRACKET */
    {
        {TYPE_CHAR, (char_t) 'C', STATE_CDATA_C, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 44: STATE_CDATA_C */
    {
        {TYPE_CHAR, (char_t) 'D', STATE_CDATA_D, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 45: STATE_CDATA_D */
    {
        {TYPE_CHAR, (char_t) 'A', STATE_CDATA_A, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 46: STATE_CDATA_A */
    {
        {TYPE_CHAR, (char_t) 'T', STATE_CDATA_T, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 47: STATE_CDATA_T */
    {
        {TYPE_CHAR, (char_t) 'A', STATE_CDATA_A2, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 48: STATE_CDATA_A2 */
    {
        {TYPE_EXACT, (char_t) '[', STATE_CDATA, 0},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
        /* 49: STATE_ATTR_VALTOKEN */
    {
        {TYPE_EXACT, (char_t) '>', STATE_CONTENT, ACTION_ATTRVAL_END},
        {TYPE_RANGE, (char_t) RANGE_WS, STATE_STARTTAG_NAMEEND, ACTION_ATTRVAL_END},
        {TYPE_RANGE, (char_t) RANGE_CHAR, STATE_ATTR_VALTOKEN, ACTION_PUMP_START},
        {TYPE_END, 0, STATE_ERROR, 0}
    },
#ifdef HTML	
        /* 50: STATE_SKIP_TAG */
    {
        {TYPE_SPECIAL, (char_t) SPECIAL_FIND_STRING, STATE_CONTENT, 0},
    },
#endif	
};

int range_match (int range, char_t c);
void skip_dtd (parser_state *);
void action (parser_state *, int);

void tagname_end (parser_state *parser);
void attrname_end (parser_state *parser);
void attrval_end (parser_state *parser);
void word_end (parser_state *parser);
void ws_end (parser_state *parser);

int range_match (int range, char_t c)
{
	int i, r;

	r = 0;
	for (i = 0; range_table[range][i].start > 0; i++) {
		if (range_table[range][i].start <= c
		    && c <= range_table[range][i].end) {
			r = 1;
		}
	}
	return r;
}

#ifdef HTML
void find_string (parser_state *parser)
{
	char_t c;
	
	c = parser->text[parser->current];
	if (c >= 'A' && c <= 'Z') c |= 0x20;
	
    if (c == parser->find_string[parser->find_string_current]) {
        parser->find_string_current++;
    } else {
        parser->find_string_current = 0;
	}

    if (parser->find_string[parser->find_string_current] == '\0') {
        parser->find_string = 0;
        parser->find_string_current = 0;
    }
}
#endif

void skip_dtd (parser_state *parser)
{
	while (parser->current < parser->maxtext &&
		   parser->angleBracketLevel > -1) {
		switch (parser->text[parser->current]) {
		case '<':
			if (parser->squoteLevel == 0 && parser->dquoteLevel == 0)
				parser->angleBracketLevel++;
			break;
		case '>':
			if (parser->squoteLevel == 0 && parser->dquoteLevel == 0)
				parser->angleBracketLevel--;
			break;
		case '"':
			if (parser->dquoteLevel > 0)
				parser->dquoteLevel--;
			else if (parser->squoteLevel == 0)
				parser->dquoteLevel++;
			break;
		case '\'':
			if (parser->squoteLevel > 0)
				parser->squoteLevel--;
			else if (parser->dquoteLevel == 0)
				parser->squoteLevel++;
			break;
		}
		if (parser->angleBracketLevel > -1) parser->current++;
	}
}

void tagname_end (parser_state *parser)
{
	parser->pump = 0;
	*(char_t *) (parser->buffer + parser->bcurrent) = 0;
	parser->bcurrent = 0;
	if (parser->element_callback) (parser->element_callback)(parser);
}

void attrname_end (parser_state *parser)
{
	parser->pump = 0;
	*(char_t *) (parser->buffer + parser->bcurrent) = 0;
	parser->bcurrent = 0;
	if (parser->attrname_callback) (parser->attrname_callback)(parser);
}

void attrval_end (parser_state *parser)
{
	parser->pump = 0;
	*(char_t *) (parser->buffer + parser->bcurrent) = 0;
	parser->bcurrent = 0;
	if (parser->attrval_callback) (parser->attrval_callback)(parser);
}

void word_end (parser_state *parser)
{
	parser->pump = 0;
	*(char_t *) (parser->buffer + parser->bcurrent) = 0;
	parser->bcurrent = 0;
	if (parser->word_callback) (parser->word_callback)(parser);
}

void ws_end (parser_state *parser)
{
	parser->pump = 0;
	*(char_t *) (parser->buffer + parser->bcurrent) = 0;
	parser->bcurrent = 0;
	if (parser->ws_callback) (parser->ws_callback)(parser);
}

void entity_end (parser_state *parser)
{
	parser->pump = 0;
	*(char_t *) (parser->buffer + parser->bcurrent) = 0;
	parser->bcurrent = 0;
	if (parser->entity_callback) (parser->entity_callback)(parser);
}

void action (parser_state *parser, int variant)
{
	unsigned int action;
	
	action = state_table[parser->state][variant].action;
	if (action & ACTION_TAGNAME_END) tagname_end (parser);
	if (action & ACTION_ATTRNAME_END) attrname_end (parser);
	if (action & ACTION_ATTRVAL_END) attrval_end (parser);
	if (action & ACTION_WORD_END) word_end (parser);
	if (action & ACTION_WS_END) ws_end (parser);
	if (action & ACTION_ENTITY_END) entity_end (parser);
	if (action & ACTION_PUMP_START) parser->pump = 1;
}

void tox_parse (parser_state *parser)
{
    char_t c;
    int i, transition;
	tokenizer_state old_state;
    
    while (parser->current < parser->maxtext &&
        parser->state != STATE_ERROR && parser->state != STATE_END) {

        switch (parser->char_width) {
            case 1: c = *(unsigned char *)(parser->text + parser->current); break;
            case 2: c = *(char_t *) (parser->text + parser->current); break;
            default: c = 0; break;
        }
        
		old_state = parser->state;
        transition = 0;
        for (i = 0; !transition && parser->state != STATE_ERROR; i++) {
            switch (state_table[parser->state][i].accept_type) {
            case TYPE_EXACT:
#ifndef HTML                        
            case TYPE_CHAR:
#endif                        
                if ((unsigned int) state_table[parser->state][i].accept_value == (unsigned int) c) {
                    transition = 1;
                    action (parser, i);
                    if (parser->state == old_state) {
                        parser->state = state_table[parser->state][i].next_state;
                    }
                }
                break;
#ifdef HTML                        
            case TYPE_CHAR:
                if ((unsigned int) state_table[parser->state][i].accept_value == 
                                        (unsigned int) (c & 0xDF)) {
                    transition = 1;
                    action (parser, i);
                    if (parser->state == old_state) {
                        parser->state = state_table[parser->state][i].next_state;
                    }
                }
                break;
#endif                                        
            case TYPE_RANGE:
                if (range_match
                    ((int) state_table[parser->state][i].accept_value, c)) {
                    transition = 1;
                    action (parser, i);
                    if (parser->state == old_state) {
                        parser->state = state_table[parser->state][i].next_state;
                    }
                }
                break;
            case TYPE_SPECIAL:
                switch ((int) state_table[parser->state][i].accept_value) {
                    case SPECIAL_SKIP_DTD:
                        skip_dtd (parser);
                        transition = 1;
                        if (parser->angleBracketLevel == -1) {
                            parser->state = state_table[parser->state][i].next_state;
                            parser->squoteLevel = 0;
                            parser->dquoteLevel = 0;
                            parser->angleBracketLevel = 0;
                        }
                        break;
#ifdef HTML
                    case SPECIAL_FIND_STRING:
                        find_string (parser);
                        transition = 1;
                        if (parser->find_string == 0) {
                            parser->state = state_table[parser->state][i].next_state;
                        }
                        break;
#endif

                }
                break;
            case TYPE_END:
                parser->state = STATE_ERROR;
                break;
            }
        }

        if (parser->pump && parser->bcurrent < parser->maxbuf) {
            switch (parser->char_width) {
                case 1: *(unsigned char *) (parser->buffer + parser->bcurrent) =
                    (unsigned char) c; break;
                case 2: *(char_t *)(parser->buffer + parser->bcurrent) = c;
                    break;
            }
            parser->bcurrent += parser->char_width;
        }
        parser->current += parser->char_width;
    }
}
