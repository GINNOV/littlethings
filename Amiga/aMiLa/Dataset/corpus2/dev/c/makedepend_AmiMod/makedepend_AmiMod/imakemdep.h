/*

Copyright (c) 1993, 1994, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from The Open Group.

*/


/*
 * This file contains machine-dependent constants for the makedepend utility.
 * When porting makedepend, add in any necessary definitions for selecting
 * the right headers to include on your platform.
 */

struct predef_symtab {
    const char *s_name;
    const char *s_value;
};

/* predefs:
 *     If your compiler and/or preprocessor define any specific symbols, add
 *     them to the the following table.
 */
#undef DEF_EVALUATE
#undef DEF_STRINGIFY
#define DEF_EVALUATE(__x) #__x
#define DEF_STRINGIFY(_x) DEF_EVALUATE(_x)
static const struct predef_symtab predefs[] = {
    {"_AMIGA", "1"},
    {"_M68000", "1"},
    {"__SASC", "1"},
    /* add any additional symbols before this line */
    {NULL, NULL}
};

#undef DEF_EVALUATE
#undef DEF_STRINGIFY
