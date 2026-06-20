//**********************************************************************
//
//  REGCOM: Regimental Command
//  Copyright (C) 1997-2001 Randi J. Relander
//	<rjrelander@users.sourceforge.net>
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public
//  License along with this program; if not, write to the Free
//  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
//  MA 02111-1307, USA.
//  
//**********************************************************************

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "SDL.h"

#include "Game.h"

#ifndef PACKAGE
#define PACKAGE "regcom"
#endif

#ifndef VERSION
#define VERSION "0.0.4"
#endif

static struct
{
	int video_width;
	int video_height;
	int video_depth;
	int video_flags;

} options;

//----------------------------------------------------------------------
// FUNCTION: display_help
//----------------------------------------------------------------------

static const char* help_text[] =
{
	"                                                   \n",
	"Usage: regcom [OPTION] ...                         \n",
	"                                                   \n",
	"Options:                                           \n",
	"                                                   \n",
	"  --help      display help information             \n",
	"  --version   display version information          \n",
	"                                                   \n",
	"Video options:                                     \n",
	"                                                   \n",
	"  --width=WIDTH     set screen width               \n",
	"  --height=HEIGHT   set screen height              \n",
	"  --depth=DEPTH     set screen depth               \n",
	"  --fullscreen      enable full screen mode        \n",
	"  --resizable       enable window resizing         \n",
	"                                                   \n",
	"Report bugs to <regcom-bugs@lists.sourceforge.net>.\n",
	"                                                   \n",
	NULL
};

void display_help(void)
{
	const char** text = help_text;
	while (*text) printf(*text++);
	exit(0);
}

//----------------------------------------------------------------------
// FUNCTION: display_version
//----------------------------------------------------------------------

void display_version(void)
{
	printf("%s %s",PACKAGE,VERSION);
	exit(0);
}

//----------------------------------------------------------------------
// FUNCTION: report_invalid_option
//----------------------------------------------------------------------

void report_invalid_option(char* option)
{
	fprintf(stderr,
		"%s: invalid option '%s'\n",PACKAGE,option);
	fprintf(stderr,
		"Try '%s --help' for more information.\n",PACKAGE);
	exit(-1);
}

//----------------------------------------------------------------------
// FUNCTION: get_int_argument
//----------------------------------------------------------------------

int get_int_argument(char* option)
{
	// locate the argument

	char* arg = strchr(option,'=');
	if (arg == NULL) report_invalid_option(option);
	arg++;
	
	// validate the argument

	size_t len = strlen(arg);
	if ((len == 0) || (len != strspn(arg,"0123456789")))
		report_invalid_option(option);
	
	// return the argument

	return atoi(arg);
}

//----------------------------------------------------------------------
// FUNCTION: parse_options
//----------------------------------------------------------------------

void parse_options(int argc, char** argv)
{
	options.video_width		= 800;
	options.video_height	= 600;
	options.video_depth		= 8;
	options.video_flags		= 0;

	for (int n = 1; n < argc; n++) {
		
		if (strcmp(argv[n], "--help") == 0)
			display_help();
		else if (strcmp(argv[n], "--version") == 0)
			display_version();

		else if (strstr(argv[n],"--width=") == argv[n])
			options.video_width = get_int_argument(argv[n]);
		else if (strstr(argv[n],"--height=") == argv[n])
			options.video_height = get_int_argument(argv[n]);
		else if (strstr(argv[n],"--depth=") == argv[n])
			options.video_depth = get_int_argument(argv[n]);
		else if (strcmp(argv[n], "--fullscreen") == 0)
			options.video_flags |= SDL_FULLSCREEN;
		else if (strcmp(argv[n], "--resizable") == 0)
			options.video_flags |= SDL_RESIZABLE;

		else report_invalid_option(argv[n]);
	}
}

//----------------------------------------------------------------------
// FUNCTION: main
//----------------------------------------------------------------------

int main(int argc, char** argv)
{
	srand(time(NULL));

	if (SDL_Init(SDL_INIT_VIDEO) < 0) exit(-1);

	atexit(SDL_Quit);

	SDL_WM_SetCaption("Regimental Command","regcom");

	parse_options(argc,argv);
	
	SDL_Surface* screen = SDL_SetVideoMode(
		options.video_width,
		options.video_height,
		options.video_depth,
		options.video_flags);

	if (screen == NULL) exit(-1);

	Game::Instance()->Run();

	return 0;
}
