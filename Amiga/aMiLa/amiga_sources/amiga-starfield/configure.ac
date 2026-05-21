
AC_INIT([starfield],[0.1])

AM_INIT_AUTOMAKE([dist-zip silent-rules subdir-objects])

AC_CONFIG_SRCDIR([src/main.c])

AC_PROG_CC([m68k-amigaos-gcc])
#AC_SUBST(CFLAGS,'-m68000 -msoft-float -fomit-frame-pointer -s -noixemul -ffast-math -DAMIGA -DACE_DEBUG=ON -Wall -Wextra -O3')

AC_SUBST(CFLAGS,'-m68000 -msoft-float -fomit-frame-pointer -s -noixemul -ffast-math -DAMIGA -Wall -Wextra -O3')


# Need ace include dir to build the prject
AC_CHECK_HEADERS([stdlib.h ace/managers/key.h ace/managers/game.h ace/utils/chunky.h ace/managers/viewport/simplebuffer.h],[have_ace_includes=yes],[have_ace_includes=no])
if test "" = no; then
  AC_MSG_ERROR([Unable to find required ACE include files]);
fi

AC_SEARCH_LIBS([viewCreate], [acerelease],[have_ace_lib=yes],[have_ace_lib=no])
if test "" = no; then
  AC_MSG_ERROR([Unable to find required ACE lib file]);
fi

AC_CHECK_PROG([bitmap_conv],[bitmap_conv],[yes],[no],,)
if test "" = no; then
  AC_MSG_ERROR([Unable to find bitmap_conv utility, this utility is part of ACE, you can find it under the tool directory]);
fi

AC_CHECK_PROG([palette_conv],[palette_conv],[yes],[no],,)
if test "" = no; then
  AC_MSG_ERROR([Unable to find palette_conv utility, this utility is part of ACE, you can find it under the tool directory]);
fi

AC_CHECK_PROG([assembler],[vasmm68k_mot],[vasmm68k_mot],[no],,)
if test "" = no; then
  AC_MSG_ERROR([Unable to find vasm68k_mot assembler]);
fi

AC_CHECK_PROG([dd],[dd],[yes],[no],,)
if test "" = no; then
  AC_MSG_ERROR([Unable to find dd utility]);
fi

AC_CONFIG_FILES([Makefile src/Makefile])
# asm=vasmm68k_mot

#AC_DEFINE([ACE_DEBUG], [ON], [Debug on])

AC_OUTPUT

echo "-------------------------------------------------
 Version 
Compiler: '  '
Bindir: ''
Execprefix: ''
Prefix: ''
--------------------------------------------------"

