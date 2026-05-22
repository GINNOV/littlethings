/*
**      $VER: libfuncs.h 44.1 (11.2.2006)
**
**      datatype function header file
**
**      (C) Copyright 1996-2006 Andreas R. Kleinert
**      All Rights Reserved.
*/

#ifdef ALPHA_SUPPORT
#ifndef PDTA_AlphaChannel
#define PDTA_AlphaChannel     (DTA_Dummy + 256)
#endif
#endif

extern Class * __saveds __asm ObtainPicClass ( register __a6 struct ClassBase *cb);
extern ULONG setdtattrs (struct ClassBase * cb, Object * o, ULONG data,...);
extern ULONG getdtattrs (struct ClassBase * cb, Object * o, ULONG data,...);
extern Class *initClass (struct ClassBase * cb);
extern ULONG __saveds __asm Dispatch ( register __a0 Class * cl, register __a2 Object * o, register __a1 Msg msg);
extern ULONG __saveds __asm GetGfxData ( register __a6 struct ClassBase * cb, register __a0 Class * cl, register __a2 Object * o, register __a1 struct TagItem * attrs);
