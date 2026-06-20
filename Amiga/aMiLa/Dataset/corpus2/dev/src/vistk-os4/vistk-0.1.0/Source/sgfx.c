/*
-----------------------------------------------------------
   sgfx.c - Simple graphics library for use with
            svgalib and similar libraries and drivers
            that present the video RAM as a linear array.
-----------------------------------------------------------
 * (C) 2000 David Olofson
 * Reologica Instruments AB
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "sgfx.h"

//struct sg_font_t default_font = {
//	width = 8;
//	height = 8;
//};

#if 0
#define FONT_W	8
#define FONT_H	8
static char df[32][8][8] = {
	{
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	},
	{
	"   ##   ",
	"   ##   ",
	"   ##   ",
	"   ##   ",
	"   ##   ",
	"        ",
	"   ##   ",
	"        ",
	},
	{
	" ## ##  ",
	" ## ##  ",
	"  #  #  ",
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	},
	{
	" ## ##  ",
	"####### ",
	" ## ##  ",
	" ## ##  ",
	" ## ##  ",
	"####### ",
	" ## ##  ",
	"        ",
	},
	{
	"   ##   ",
	"  ##### ",
	" ##     ",
	"  ####  ",
	"     ## ",
	" #####  ",
	"   ##   ",
	"        ",
	},
	{
	" ##   # ",
	"#  # #  ",
	" ## #   ",
	"   #    ",
	"  # ##  ",
	" # #  # ",
	"#   ##  ",
	"        ",
	},
	{
	"  ####  ",
	" ##  ## ",
	" ##     ",
	"## ##   ",
	"##  ### ",
	"##  ### ",
	" ###### ",
	"        ",
	},
	{
	"   ##   ",
	"   ##   ",
	"   #    ",
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	},
	{
	"    ##  ",
	"   ##   ",
	"  ##    ",
	"  ##    ",
	"  ##    ",
	"   ##   ",
	"    ##  ",
	"        ",
	},
	{
	"  ##    ",
	"   ##   ",
	"    ##  ",
	"    ##  ",
	"    ##  ",
	"   ##   ",
	"  ##    ",
	"        ",
	},
	{
	"        ",
	" ##  ## ",
	"  ####  ",
	" ###### ",
	"  ####  ",
	" ##  ## ",
	"        ",
	"        ",
	},
	{
	"        ",
	"   ##   ",
	"   ##   ",
	" ###### ",
	"   ##   ",
	"   ##   ",
	"        ",
	"        ",
	},
	{
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	"   ##   ",
	"   ##   ",
	"   #    ",
	},
	{
	"        ",
	"        ",
	"        ",
	" ###### ",
	"        ",
	"        ",
	"        ",
	"        ",
	},
	{
	"        ",
	"        ",
	"        ",
	"        ",
	"        ",
	"   ##   ",
	"   ##   ",
	"        ",
	},
	{
	"      # ",
	"     ## ",
	"    ##  ",
	"   ##   ",
	"  ##    ",
	" ##     ",
	"##      ",
	"#       ",
	},
	{
	" #####  ",
	"##   ## ",
	"## # ## ",
	"## # ## ",
	"## # ## ",
	"##   ## ",
	" #####  ",
	"        ",
	},
	{
	"   ##   ",
	"  ###   ",
	"   ##   ",
	"   ##   ",
	"   ##   ",
	"   ##   ",
	"  ####  ",
	"        ",
	},
	{
	" #####  ",
	"##   ## ",
	"     ## ",
	"    ##  ",
	"   ##   ",
	"  ##    ",
	"####### ",
	"        ",
	},
	{
	" #####  ",
	"##   ## ",
	"     ## ",
	"  ####  ",
	"     ## ",
	"##   ## ",
	" #####  ",
	"        ",
	},
	{
	"   ###  ",
	"  ####  ",
	" ## ##  ",
	"##  ##  ",
	"####### ",
	"    ##  ",
	"   #### ",
	"        ",
	},
	{
	"####### ",
	"##      ",
	"######  ",
	"     ## ",
	"     ## ",
	"##   ## ",
	" #####  ",
	"        ",
	},
	{
	" #####  ",
	"##      ",
	"##      ",
	"######  ",
	"##   ## ",
	"##   ## ",
	" #####  ",
	"        ",
	},
	{
	"####### ",
	"     ## ",
	"    ##  ",
	"   ##   ",
	"  ##    ",
	"  ##    ",
	"  ##    ",
	"        ",
	},
	{
	" #####  ",
	"##   ## ",
	"##   ## ",
	" #####  ",
	"##   ## ",
	"##   ## ",
	" #####  ",
	"        ",
	},
	{
	" #####  ",
	"##   ## ",
	"##   ## ",
	" ###### ",
	"     ## ",
	"     ## ",
	" #####  ",
	"        ",
	}
};
#else
#define FONT_W	6
#define FONT_H	8
static char df[128][FONT_H][FONT_W] = {
	{		/* 0 */
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	"      ",	/* \201 */
	"      ",
	"  #   ",
	" ###  ",
	"##### ",
	"      ",
	"      ",
	"      "
	},
	{		/* \202 */
	"      ",
	"      ",
	"##### ",
	" ###  ",
	"  #   ",
	"      ",
	"      ",
	"      "
	},
	{		/* \203 */
	"    # ",
	"   ## ",
	"  ### ",
	" #### ",
	"  ### ",
	"   ## ",
	"    # ",
	"      "
	},
	{		/* \204 */
	" #    ",
	" ##   ",
	" ###  ",
	" #### ",
	" ###  ",
	" ##   ",
	" #    ",
	"      "
	},
	{		/* \205 */
	"      ",
	"##### ",
	"      ",
	"  #   ",
	" ###  ",
	"##### ",
	"      ",
	"      "
	},
	{		/* \206 */
	"      ",
	"      ",
	"##### ",
	" ###  ",
	"  #   ",
	"      ",
	"##### ",
	"      "
	},
	{		/* \207 */
	"#    #",
	"#   ##",
	"#  ###",
	"# ####",
	"#  ###",
	"#   ##",
	"#    #",
	"      "
	},
	{		/* \210 */
	"#    #",
	"##   #",
	"###  #",
	"#### #",
	"###  #",
	"##   #",
	"#    #",
	"      "
	},
	{		/* \211 */
	"##### ",
	" ###  ",
	"  #   ",
	"##### ",
	"  #   ",
	" ###  ",
	"##### ",
	"      "
	},
	{		/* \212 */
	"#    #",
	"##   #",
	"###  #",
	"#### #",
	"###  #",
	"##   #",
	"#    #",
	"      "
	},
	{		/* \213 */
	"    # ",
	"   ## ",
	"  ### ",
	" #### ",
	"  ### ",
	"   ## ",
	"    # ",
	"      "
	},
	{		/* \214 */
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{		/* \215 */
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{		/* \216 */
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{		/* \217 */
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{		/* 16 */
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
	{		/* 32 */
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"      ",
	"  #   ",
	"      "
	},
	{
	" # #  ",
	" # #  ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	" # #  ",
	"##### ",
	" # #  ",
	" # #  ",
	" # #  ",
	"##### ",
	" # #  ",
	"      "
	},
	{
	"  #   ",
	" #### ",
	"##    ",
	" ###  ",
	"   ## ",
	"####  ",
	"  #   ",
	"      "
	},
	{
	"##    ",
	"##  # ",
	"   #  ",
	"  #   ",
	" #    ",
	"#  ## ",
	"   ## ",
	"      "
	},
	{
	"  ##  ",
	" #  # ",
	" #  # ",
	" ###  ",
	"#   # ",
	"#     ",
	" #### ",
	"      "
	},
	{
	"   #  ",
	"  #   ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	"   #  ",
	"  #   ",
	" #    ",
	" #    ",
	" #    ",
	"  #   ",
	"   #  ",
	"      "
	},
	{
	" #    ",
	"  #   ",
	"   #  ",
	"   #  ",
	"   #  ",
	"  #   ",
	" #    ",
	"      "
	},
	{
	"      ",
	" #  # ",
	"  ##  ",
	" #### ",
	"  ##  ",
	" #  # ",
	"      ",
	"      "
	},
	{
	"      ",
	"  #   ",
	"  #   ",
	"##### ",
	"  #   ",
	"  #   ",
	"      ",
	"      "
	},
	{
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"  #   ",
	" #    "
	},
	{
	"      ",
	"      ",
	"      ",
	"##### ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"  #   ",
	"      "
	},
	{
	"      ",
	"     #",
	"    # ",
	"   #  ",
	"  #   ",
	" #    ",
	"#     ",
	"      "
	},
	{		/* 48 */
	" ###  ",
	"#   # ",
	"#  ## ",
	"# # # ",
	"##  # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"  #   ",
	" ##   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	" ###  ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"    # ",
	"   #  ",
	"  #   ",
	" #    ",
	"##### ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"    # ",
	" ###  ",
	"    # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"   #  ",
	"  ##  ",
	" # #  ",
	"#  #  ",
	"##### ",
	"   #  ",
	"   #  ",
	"      "
	},
	{
	"##### ",
	"#     ",
	"####  ",
	"    # ",
	"    # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	" ###  ",
	"#     ",
	"#     ",
	"####  ",
	"#   # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"##### ",
	"    # ",
	"   #  ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#   # ",
	" ###  ",
	"#   # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#   # ",
	" #### ",
	"    # ",
	"    # ",
	" ###  ",
	"      "
	},
	{
	"      ",
	"  #   ",
	"      ",
	"      ",
	"      ",
	"      ",
	"  #   ",
	"      "
	},
	{
	"      ",
	"  #   ",
	"      ",
	"      ",
	"      ",
	"      ",
	"  #   ",
	" #    "
	},
	{
	"      ",
	"   #  ",
	"  #   ",
	" #    ",
	"  #   ",
	"   #  ",
	"      ",
	"      "
	},
	{
	"      ",
	"      ",
	"##### ",
	"      ",
	"##### ",
	"      ",
	"      ",
	"      "
	},
	{
	"      ",
	" #    ",
	"  #   ",
	"   #  ",
	"  #   ",
	" #    ",
	"      ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"    # ",
	"   #  ",
	"  #   ",
	"      ",
	"  #   ",
	"      "
	},
	{		/* 64 */
	" ###  ",
	"#   # ",
	"#  ## ",
	"# # # ",
	"#  ## ",
	"#     ",
	" ###  ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#   # ",
	"##### ",
	"#   # ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	"####  ",
	"#   # ",
	"#   # ",
	"####  ",
	"#   # ",
	"#   # ",
	"####  ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#     ",
	"#     ",
	"#     ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"####  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"####  ",
	"      "
	},
	{
	"##### ",
	"#     ",
	"#     ",
	"####  ",
	"#     ",
	"#     ",
	"##### ",
	"      "
	},
	{
	"##### ",
	"#     ",
	"#     ",
	"####  ",
	"#     ",
	"#     ",
	"#     ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#     ",
	"# ### ",
	"#   # ",
	"#   # ",
	" #### ",
	"      "
	},
	{		/* 72 */
	"#   # ",
	"#   # ",
	"#   # ",
	"##### ",
	"#   # ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	" ###  ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	" ###  ",
	"      "
	},
	{
	"##### ",
	"    # ",
	"    # ",
	"    # ",
	"    # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"#   # ",
	"#  #  ",
	"# #   ",
	"##    ",
	"# #   ",
	"#  #  ",
	"#   # ",
	"      "
	},
	{
	"#     ",
	"#     ",
	"#     ",
	"#     ",
	"#     ",
	"#     ",
	"##### ",
	"      "
	},
	{
	"#   # ",
	"## ## ",
	"# # # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	"#   # ",
	"#   # ",
	"##  # ",
	"# # # ",
	"#  ## ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{		/* 80 */
	"####  ",
	"#   # ",
	"#   # ",
	"####  ",
	"#     ",
	"#     ",
	"#     ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"# # # ",
	"#  ## ",
	" #### ",
	"      "
	},
	{
	"####  ",
	"#   # ",
	"#   # ",
	"####  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	" ###  ",
	"#   # ",
	"#     ",
	" ###  ",
	"    # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"##### ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"      "
	},
	{
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"#   # ",
	"#   # ",
	"#   # ",
	" # #  ",
	" # #  ",
	"  #   ",
	"  #   ",
	"      "
	},
	{
	"#   # ",
	"#   # ",
	"#   # ",
	"# # # ",
	"# # # ",
	"# # # ",
	" # #  ",
	"      "
	},
	{		/* 88 */
	"#   # ",
	"#   # ",
	" # #  ",
	"  #   ",
	" # #  ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	"#   # ",
	"#   # ",
	" # #  ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"      "
	},
	{
	"##### ",
	"    # ",
	"   #  ",
	"  #   ",
	" #    ",
	"#     ",
	"##### ",
	"      "
	},
	{
	"  ##  ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  ##  ",
	"      "
	},
	{
	"      ",
	"#     ",
	" #    ",
	"  #   ",
	"   #  ",
	"    # ",
	"     #",
	"      "
	},
	{
	"  ##  ",
	"   #  ",
	"   #  ",
	"   #  ",
	"   #  ",
	"   #  ",
	"  ##  ",
	"      "
	},
	{
	"  #   ",
	" # #  ",
	"#   # ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"##### "
	},
	{		/* 96 */
	"  #   ",
	"   #  ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{
	"      ",
	"      ",
	" ###  ",
	"    # ",
	" #### ",
	"#   # ",
	" #### ",
	"      "
	},
	{
	"#     ",
	"#     ",
	"####  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"####  ",
	"      "
	},
	{
	"      ",
	"      ",
	" ###  ",
	"#   # ",
	"#     ",
	"#   # ",
	" ###  ",
	"      "
	},
	{
	"    # ",
	"    # ",
	" #### ",
	"#   # ",
	"#   # ",
	"#   # ",
	" #### ",
	"      "
	},
	{
	"      ",
	"      ",
	" ###  ",
	"#   # ",
	"##### ",
	"#     ",
	" ###  ",
	"      "
	},
	{
	"  ##  ",
	" #  # ",
	"###   ",
	" #    ",
	" #    ",
	" #    ",
	" #    ",
	"      "
	},
	{
	"      ",
	"      ",
	" #### ",
	"#   # ",
	"#   # ",
	" #### ",
	"    # ",
	" ###  "
	},
	{		/* 104 */
	"#     ",
	"#     ",
	"####  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	"   #  ",
	"      ",
	"  ##  ",
	"   #  ",
	"   #  ",
	"   #  ",
	"   #  ",
	"      "
	},
	{
	"   #  ",
	"      ",
	"  ##  ",
	"   #  ",
	"   #  ",
	"   #  ",
	"#  #  ",
	" ##   "
	},
	{
	"#     ",
	"#     ",
	"#   # ",
	"#  #  ",
	"# #   ",
	"## #  ",
	"#   # ",
	"      "
	},
	{
	" ##   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"      "
	},
	{
	"      ",
	"      ",
	"## #  ",
	"# # # ",
	"# # # ",
	"# # # ",
	"# # # ",
	"      "
	},
	{
	"      ",
	"      ",
	"####  ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	"      "
	},
	{
	"      ",
	"      ",
	" ###  ",
	"#   # ",
	"#   # ",
	"#   # ",
	" ###  ",
	"      "
	},
	{		/* 112 */
	"      ",
	"      ",
	"####  ",
	"#   # ",
	"#   # ",
	"####  ",
	"#     ",
	"#     "
	},
	{
	"      ",
	"      ",
	" #### ",
	"#   # ",
	"#   # ",
	" #### ",
	"    # ",
	"    # "
	},
	{
	"      ",
	"      ",
	"# ##  ",
	"##  # ",
	"#     ",
	"#     ",
	"#     ",
	"      "
	},
	{
	"      ",
	"      ",
	" #### ",
	"#     ",
	" ###  ",
	"    # ",
	"####  ",
	"      "
	},
	{
	" #    ",
	" #    ",
	"####  ",
	" #    ",
	" #    ",
	" #  # ",
	"  ##  ",
	"      "
	},
	{
	"      ",
	"      ",
	"#   # ",
	"#   # ",
	"#   # ",
	"#   # ",
	" #### ",
	"      "
	},
	{
	"      ",
	"      ",
	"#   # ",
	"#   # ",
	"#   # ",
	" # #  ",
	"  #   ",
	"      "
	},
	{
	"      ",
	"      ",
	"#   # ",
	"#   # ",
	"# # # ",
	"# # # ",
	" # #  ",
	"      "
	},
	{		/* 120 */
	"      ",
	"      ",
	"#   # ",
	" # #  ",
	"  #   ",
	" # #  ",
	"#   # ",
	"      "
	},
	{
	"      ",
	"      ",
	"#   # ",
	"#   # ",
	"#   # ",
	" #### ",
	"    # ",
	" ###  "
	},
	{
	"      ",
	"      ",
	"##### ",
	"   #  ",
	"  #   ",
	" #    ",
	"##### ",
	"      "
	},
	{
	"   ## ",
	"  #   ",
	"  #   ",
	"##    ",
	"  #   ",
	"  #   ",
	"   ## ",
	"      "
	},
	{
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   ",
	"  #   "
	},
	{
	"##    ",
	"  #   ",
	"  #   ",
	"   ## ",
	"  #   ",
	"  #   ",
	"##    ",
	"      "
	},
	{
	" ## # ",
	"#  #  ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      ",
	"      "
	},
	{		/* 127 */
	"######",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"#    #",
	"######"
	},
};
#endif

/*
 * Print a decimal number at the current cursor pos
 */
void sg_print_num(sg_context_t *sgc, double num)
{
	char buf[128];
	snprintf(buf, 128, "%.4f", num);
	sg_print(sgc, buf);
}

/*
 * Quick hack...
 */
void sg_putc(sg_context_t *sgc, char c)
{
	char buf[2];
	buf[0] = c;
	buf[1] = 0;
	sg_print(sgc, buf);
}

/*
 * Print a NULL terminated string at the current cursor pos
 */
void sg_print(sg_context_t *sgc, const char *s)
{
	int p = 0, x, y;
	int w = FONT_W;
	int h = FONT_H;
	int xx = sgc->pen.x;
	int yy = sgc->pen.y;
	char *sp = &sgc->buffer[sgc->pitch*yy + xx];
	char *sp_start = sp;
	int xx_start = xx;
	char c = sgc->pen.fgcolor | sgc->pen.fgmod;
	while(s[p])
	{
		if(s[p] > ' ' || s[p] < 0)
		{
			char *_fp = &df[(s[p] & 0x7f)][0][0];
			char *_sp = sp;
			if( (xx <= sgc->w - w) && (yy <= sgc->h - h)
					&& (xx >= 0) && (yy >= 0) )
			{
				for(y=0; y<h; ++y)
				{
					for(x=0; x<w; ++x)
						if(*_fp++ != ' ')
							_sp[x] = c;
					_sp += sgc->pitch;
				}
			}
			sp += w;
			xx += w;
		}
		else if('\n' == s[p])	/* CR+LF */
		{
			sp_start += sgc->pitch*h;
			sp = sp_start;
			xx = xx_start;
			yy += h;
		}
		else if( 31 == s[p] )	/* Micro space */
		{
			++sp;
			++xx;
		}
		else
		{
			sp += w;
			xx += w;
		}
		++p;
	}
/*	sgc->pen.y = (int)(sp - sgc->buffer) / sgc->pitch;
	sgc->pen.x = (int)(sp - sgc->buffer) % sgc->pitch;
*/
	sgc->pen.x = xx;
	sgc->pen.y = yy;
}

/*
 * Print a NULL terminated string at the current cursor pos
 * using reversed video. An extra pixel row is added above
 * the font for a complete outline. Use the micro space (31)
 * To add an outline pixel column at the start of a string.
 */
void sg_print_rvs(sg_context_t *sgc, const char *s)
{
	int p = 0, x, y;
	int w = FONT_W;
	int h = FONT_H;
	int xx = sgc->pen.x;
	int yy = sgc->pen.y - 1;
	char *sp = &sgc->buffer[sgc->pitch*yy + xx];
	char *sp_start = sp;
	int xx_start = xx;
	char c = sgc->pen.fgcolor | sgc->pen.fgmod;
	while(s[p])
	{
		if(s[p] >= ' ' || s[p] < 0)
		{
			char *_fp = &df[(s[p] & 0x7f)][0][0];
			char *_sp = sp;
			if( (xx <= sgc->w - w) && (yy <= sgc->h - h - 1)
					&& (xx >= 0) && (yy >= 0) )
			{
				for(x=0; x<w; ++x)
					_sp[x] = c;
				_sp += sgc->pitch;
				for(y=0; y<h; ++y)
				{
					for(x=0; x<w; ++x)
						if(*_fp++ == ' ')
							_sp[x] = c;
					_sp += sgc->pitch;
				}
			}
			sp += w;
			xx += w;
		}
		else if('\n' == s[p])	/* CR+LF */
		{
			sp_start += sgc->pitch*(h+2);
			sp = sp_start;
			xx = xx_start;
			yy += h;
		}
		else if( 31 == s[p] )	/* Micro space */
		{
			char *_sp = sp;
			for(y=0; y<=h; ++y)
			{
				_sp[0] = c;
				_sp += sgc->pitch;
			}
			++sp;
			++xx;
		}
		else
		{
			sp += w;
			xx += w;
		}
		++p;
	}
/*	sgc->pen.y = (int)(sp - sgc->buffer) / sgc->pitch + 1;
	sgc->pen.x = (int)(sp - sgc->buffer) % sgc->pitch;
*/
	sgc->pen.x = xx;
	sgc->pen.y = yy + 1;
}

void sg_init(sg_context_t *sgc, void *buf, int ps, int pch, int w, int h)
{
	memset(sgc, 0, sizeof(sg_context_t));
	sgc->buffer = buf;
	sgc->pitch = w;
	sgc->x = 0;
	sgc->y = 0;
	sgc->w = w;
	sgc->h = h;
	sgc->pen.x = 0;
	sgc->pen.y = 0;
	sgc->pen.fgcolor = 1;
	sgc->pen.fgmod = 0;
	sgc->pen.bgcolor = 0;
	sgc->pen.bgmod = 0;
}

void sg_init_window(sg_context_t *sgc, sg_context_t *from,
					int x, int y, int w, int h)
{
	memcpy(sgc, from, sizeof(sg_context_t));

	/*
	 * Clipping
	 */
	if(x < 0)
	{
		w += x;
		x = 0;
	}
	if(x > sgc->x + sgc->w - 1)
		x = sgc->x + sgc->w - 1;
	if(w < 0)
		w = 0;
	if(w > sgc->w - x)
		w = sgc->w - x;
	if(y < 0)
	{
		h += y;
		y = 0;
	}
	if(y > sgc->y + sgc->h - 1)
		y = sgc->y + sgc->h - 1;
	if(h < 0)
		h = 0;
	if(h > sgc->h - y)
		h = sgc->h - y;

	sgc->buffer += y*sgc->pitch + x;
	sgc->x = x;
	sgc->y = y;
	sgc->w = w;
	sgc->h = h;
}

void sg_locate(sg_context_t *sgc, int x, int y)
{
	sgc->pen.x = x;
	sgc->pen.y = y;
}

void sg_bump(struct sg_context_t *sgc, int x, int y)
{
	sgc->pen.x += x;
	sgc->pen.y += y;
}

void sg_capture(sg_context_t *sgc, sg_pen_t *pen)
{
	memcpy(pen, &sgc->pen, sizeof(sg_pen_t));
}

void sg_restore(sg_context_t *sgc, sg_pen_t *pen)
{
	memcpy(&sgc->pen, pen, sizeof(sg_pen_t));
}

void sg_cls(sg_context_t *sgc)
{
	sg_pen_t p;
	sg_capture(sgc, &p);
	sgc->pen.fgcolor = sgc->pen.bgcolor;
	sg_bar(sgc, 0, 0, sgc->w-1, sgc->h-1);
	sg_restore(sgc, &p);
}

void sg_pixel(sg_context_t *sgc, int x, int y)
{
	sg_pixel_t c;

	sgc->pen.x = x;
	sgc->pen.y = y;

	if(x < 0)
		return;
	if(x >= sgc->w)
		return;
	if(y < 0)
		return;
	if(y >= sgc->h)
		return;

	c = sgc->pen.fgcolor | sgc->pen.fgmod;
	sgc->buffer[sgc->pitch*y + x] = c;
}

void sg_qdraw_h(sg_context_t *sgc, int x,  int y)
{
	int fy, fdy;
	int sx = sgc->pen.x;
	int sy = sgc->pen.y;
	int ex = x;
	int ey = y;
	char c;
	sgc->pen.x = x;
	sgc->pen.y = y;

	if(sx>ex)
	{
		int s;
		s=sx; sx=ex; ex=s;
		s=sy; sy=ey; ey=s;
	}

	/*
	 * fixpoint sy + slope
	 */
	fy = (sy<<16) + 32768;
	fdy = ((ey-sy)<<16)/(ex-sx);

	/*
	 * Clipping
	 */
	if(ex < 0)
		return;
	if(sx > sgc->w)
		return;
	if(sx < 0)
	{
		fy += -sx*fdy;
		sx = 0;
	}
	if(ex >= sgc->w-1)
		ex = sgc->w-1;

	/*
	 * Draw!
	 */
	c = sgc->pen.fgcolor | sgc->pen.fgmod;
	for(; sx <= ex; ++sx)
	{
		if( ((fy>>16)<sgc->h) && (fy>0) )
			sgc->buffer[sgc->pitch*(fy>>16) + sx] = c;
		fy+=fdy;
	}
}

void sg_qdraw_v(sg_context_t *sgc, int x,  int y)
{
	int fx, fdx;
	int sx = sgc->pen.x;
	int sy = sgc->pen.y;
	int ex = x;
	int ey = y;
	char c;
	sgc->pen.x = x;
	sgc->pen.y = y;

	if(sy>ey)
	{
		int s;
		s=sx; sx=ex; ex=s;
		s=sy; sy=ey; ey=s;
	}

	/*
	 * fixpoint sx + slope
	 */
	fx = (sx<<16) + 32768;
	fdx = ((ex-sx)<<16)/(ey-sy);

	/*
	 * Clipping
	 */
	if(ey < 0)
		return;
	if(sy > sgc->h)
		return;
	if(sy < 0)
	{
		fx += -sy*fdx;
		sy = 0;
	}
	if(ey >= sgc->h-1)
		ey = sgc->h-1;

	/*
	 * Draw!
	 */
	c = sgc->pen.fgcolor | sgc->pen.fgmod;
	for(; sy <= ey; ++sy)
	{
		if( ((fx>>16) < sgc->w) && (fx>0) )
			sgc->buffer[sgc->pitch*sy + (fx>>16)] = c;
		fx+=fdx;
	}
}

void sg_line(sg_context_t *sgc, int x,  int y)
{
	if(x == sgc->pen.x)
		sg_vline(sgc, y);
	else if(y == sgc->pen.y)
		sg_hline(sgc, x);
	else if(labs(x-sgc->pen.x) > labs(y-sgc->pen.y))
		sg_qdraw_h(sgc, x, y);
	else
		sg_qdraw_v(sgc, x, y);
}

void sg_vline(sg_context_t *sgc, int y)
{
	int sy = sgc->pen.y;
	sg_pixel_t c;
	sgc->pen.y = y;

	if(sgc->pen.x < 0)
		return;
	if(sgc->pen.x >= sgc->w)
		return;
	if(sy>y)
	{
		int s;
		s=sy; sy=y; y=s;
	}
	if(sy > sgc->h - 1)
		return;
	if(y < 0)
		return;
	if(sy < 0)
		sy = 0;
	if(y > sgc->h - 1)
		y = sgc->h - 1;

	c = sgc->pen.fgcolor | sgc->pen.fgmod;
	for(; sy <= y; ++sy)
		sgc->buffer[sgc->pitch*sy + sgc->pen.x] = c;
}

void sg_hline(sg_context_t *sgc, int x)
{
	int sx = sgc->pen.x;
	sg_pixel_t c;
	sgc->pen.x = x;

	if(sgc->pen.y < 0)
		return;
	if(sgc->pen.y >= sgc->h)
		return;
	if(sx>x)
	{
		int s;
		s=sx; sx=x; x=s;
	}
	if(sx > sgc->w - 1)
		return;
	if(x < 0)
		return;
	if(sx < 0)
		sx = 0;
	if(x > sgc->w - 1)
		x = sgc->w - 1;

	c = sgc->pen.fgcolor | sgc->pen.fgmod;
	memset(sgc->buffer + sgc->pitch*sgc->pen.y + sx, c, x - sx + 1);
}

void sg_bar(sg_context_t *sgc, int x1, int y1, int x2, int y2)
{
	sg_pixel_t *s;
	char c;
	/* sort */
	if(x1>x2)
	{
		int s;
		s=x1; x1=x2; x2=s;
	}
	if(y1>y2)
	{
		int s;
		s=y1; y1=y2; y2=s;
	}
	/* off-screen */
	if(x2 < 0)
		return;
	if(y2 < 0)
		return;
	if(x1 >= sgc->w - 1)
		return;
	if(y1 >= sgc->h - 1)
		return;

	/* clip */
	if(x1 < 0)
		x1 = 0;
	if(x2 > sgc->w - 1)
		x2 = sgc->w - 1;
	if(y1 < 0)
		y1 = 0;
	if(y2 > sgc->h - 1)
		y2 = sgc->h - 1;

	s = sgc->buffer + sgc->w * y1 + x1;
	c = sgc->pen.fgcolor | sgc->pen.fgmod;
	while(y1 <= y2)
	{
		memset(s, c, x2 - x1 + 1);
		s += sgc->pitch;
		++y1;
	}
}

void sg_box(sg_context_t *sgc, int x1, int y1, int x2, int y2)
{
	sg_locate(sgc, x1, y1);
	sg_hline(sgc, x2);
	sg_vline(sgc, y2);
	sg_hline(sgc, x1);
	sg_vline(sgc, y1);
}

int sg_visible(sg_context_t *sgc, int x1, int y1, int x2, int y2)
{
	int res = 1;

	/* sort */
	if(x1>x2)
	{
		int s;
		s=x1; x1=x2; x2=s;
	}
	if(y1>y2)
	{
		int s;
		s=y1; y1=y2; y2=s;
	}

	/* off-screen */
	if(x2<0  ||  y2<0  ||  x1>=sgc->w-1  ||  y1>=sgc->h-1)
		return 0;

	/* clip */
	if(x1 < 0)
		res |= 2;
	if(x2 > sgc->w - 1)
		res |= 4;
	if(y1 < 0)
		res |= 8;
	if(y2 > sgc->h - 1)
		res |= 16;

	return res;
}
