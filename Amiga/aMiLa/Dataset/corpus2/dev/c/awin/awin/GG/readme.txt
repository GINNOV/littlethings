These are files needed to compile with egcs and egcs ppc ixemul
bridge (http://www.ph-cip.uni-koeln.de/~jakob/).

Also SAS/C users might want to copy GG/os-include/libraries/xpk.h
to their include:libraries/.

macros.h are fixed to also have LP10 macro. My modifications are
marked with -HS-. Keep the original macros.h too.

proper xpk protos were missing so I collected this from xpx.h:

/*t:xpkmaster_protos.h*/
LONG XpkExamine      ( XFIB *fib, TAGS *tags);
LONG XpkPack         ( TAGS *tags );
LONG XpkUnpack       ( TAGS *tags );
LONG XpkOpen         ( XFH **xfh, TAGS  *tags );
LONG XpkRead         ( XFH  *xfh, UBYTE *buf, LONG len  );
LONG XpkWrite        ( XFH  *xfh, UBYTE *buf, LONG ulen );
LONG XpkSeek         ( XFH  *xfh, LONG  dist, LONG mode );
LONG XpkClose        ( XFH  *xfh  );
LONG XpkQuery        ( TAGS *tags );
LONG XpkExamineTags  ( XFIB *fib, ULONG, ... );
LONG XpkPackTags     ( ULONG, ... );
LONG XpkUnpackTags   ( ULONG, ... );
LONG XpkQueryTags    ( ULONG, ... );
LONG XpkOpenTags     ( XFH **xfh, ULONG, ... );
/**/

cybergraphics.h, cgxvideo.h and xpkmaster.h were generated with
PPCRelease/FD2Inline/fd2inline (it generates PowerUP PPCCallOS
wrapped inlines for gcc ppc ixemul, if you don't need --powerpc
you can use GG:bin/fd2inline --new):

fd2inline --powerup GG:os-include/fd/cybergraphics_lib.fd \
  GG:os-include/clib/cybergraphics_protos.h \
  -o GG:ppc-amigaos/os-include/powerup/ppcinline/cybergraphics.h

fd2inline --powerup GG:os-include/fd/cgxvideo_lib.fd \
  GG:os-include/clib/cgxvideo_protos.h \
  -o GG:ppc-amigaos/os-include/powerup/ppcinline/cgxvideo.h

fd2inline --powerup GG:os-include/fd/xpkmaster_lib.fd \
  t:xpkmaster_protos.h \
  -o GG:ppc-amigaos/os-include/powerup/ppcinline/xpkmaster.h

m68k egcs:

fd2inline --new GG:os-include/fd/cgxvideo_lib.fd \
  GG:os-include/clib/cgxvideo_protos.h \
  -o GG:include/inline/cgxvideo.h

fd2inline --new GG:os-include/fd/xpkmaster_lib.fd \
  t:xpkmaster_protos.h \
  -o GG:include/inline/xpkmaster.h


For SAS/C:

pragmas/cybergraphics_pragmas.h:

"#ifdef __PPC__
#include <ppcpragmas/cybergraphics_pragmas.h>
#else"
+
[pragmas/cybergraphics_pragmas.h]
+
"#endif"

pragmas/cgxvideo_pragmas.h:

"#ifdef __PPC__
#include <ppcpragmas/cgxvideo_pragmas.h>
#else"
+
[pragmas/cybergraphics_pragmas.h]
+
"#endif"

fd2inline --old --pragma --powerup
  GG:os-include/fd/cybergraphics_lib.fd \
  GG:os-include/clib/cybergraphics_protos.h \
  -o sc:ppcinclude/ppcpragmas/cybergraphics_pragmas.h

fd2inline --old --pragma --powerup
  GG:os-include/fd/cybergraphics_lib.fd \
  GG:os-include/clib/cybergraphics_protos.h \
  -o sc:ppcinclude/ppcpragmas/cgxvideo_pragmas.h


