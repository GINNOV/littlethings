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

/* $Id: main.c,v 1.11 2002/05/01 03:14:27 koeppen Exp $ */

#include <stdio.h>
#include <string.h>
#include "tox.h"

void element_callback (parser_state *);
void word_callback (parser_state *);
void ws_callback (parser_state *);

void element_callback (parser_state *parser)
{
	printf ("[%s]", parser->buffer);
}

void word_callback (parser_state *parser)
{
	printf ("%s", parser->buffer);
}

void ws_callback (parser_state *parser)
{
	printf ("%s", parser->buffer);
}

int main (int argc, char *argv[])
{
	FILE *f;
	parser_state parser;
	unsigned char buffer[128];
	int n;
	unsigned char localtext[100];

	memset (&parser, 0, sizeof (parser_state));
	parser.text = localtext;

   parser.char_width = 1;

   parser.little_endian = 0;
	
	parser.state = STATE_CONTENT;

	parser.buffer = buffer;
	parser.maxbuf = 127;
	parser.pump = 0;
	parser.bcurrent = 0;

	parser.element_callback = element_callback;
	parser.word_callback = word_callback;
	parser.ws_callback = ws_callback;


   f = fopen (argv[1], "rb");
	while (!feof (f) && parser.state != STATE_ERROR) {
		n = fread (localtext, 1, 1, f);
		localtext[n] = '\0';

		parser.current = 0;
		parser.maxtext = n;

		tox_parse (&parser);
	}
	printf ("%d %s\n", parser.state, &parser.text[parser.current]);

   fclose (f);
}

/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 */

