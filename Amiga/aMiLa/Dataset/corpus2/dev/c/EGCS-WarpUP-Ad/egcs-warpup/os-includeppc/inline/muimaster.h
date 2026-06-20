#ifndef _INLINE_MUIMASTER_H
#define _INLINE_MUIMASTER_H

#include <sys/cdefs.h>
#include <inline/stubs.h>

__BEGIN_DECLS

#ifndef BASE_EXT_DECL
#define BASE_EXT_DECL /*extern struct Library* MUIMasterBase;*/
#endif
#ifndef BASE_PAR_DECL
#define BASE_PAR_DECL
#define BASE_PAR_DECL0 void
#endif
#ifndef BASE_NAME
#define BASE_NAME MUIMasterBase
#endif

extern struct Library* MUIMasterBase;

  __inline
APTR MUI_AllocAslRequest( BASE_PAR_DECL unsigned long type, struct TagItem *tagList)

{
  BASE_EXT_DECL
  register APTR res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register unsigned long d0 __asm("d0") = type;
  register struct TagItem* a0 __asm("a0") = tagList;

  __asm volatile ("jsr a6@(-0x30)"
  : "=r" (res)
  : "r" (a6), "r" (d0), "r" (a0)
  : "d0","d1", "a0", "a1", "memory" );
  return res;
}

  APTR MUI_AllocAslRequestTags(ULONG type, Tag tag1, ...)
{
 return(MUI_AllocAslRequest(type, (struct TagItem *) &tag1));
}



__inline
BOOL MUI_AslRequest( BASE_PAR_DECL APTR requester, struct TagItem *tagList)
{
  BASE_EXT_DECL
  register BOOL res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register APTR a0 __asm("a0") = requester;
  register struct TagItem* a1 __asm("a1") = tagList;

  __asm volatile ("
  jsr a6@(-0x36)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1)
  : "d0", "d1", "a0", "a1" );
  return res;
}
  BOOL MUI_AslRequestTags(APTR req, Tag tag1, ...)
{
 return(MUI_AslRequest(req, (struct TagItem *) &tag1));
}




__inline
struct MUI_CustomClass*
MUI_CreateCustomClass( BASE_PAR_DECL struct Library *base, char *supername, struct MUI_CustomClass *supermcc, int datasize, APTR dispatcher)
{
  BASE_EXT_DECL
  register struct MUI_CustomClass* res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct Library* a0 __asm("a0") = base;
  register char* a1 __asm("a1") = supername;
  register struct MUI_CustomClass* a2 __asm("a2") = supermcc;
  register int d0 __asm("d0") = datasize;
  register APTR a3 __asm("a3") = dispatcher;

  __asm volatile ("
  jsr a6@(-0x6c)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1), "r" (a2), "r" (d0), "r" (a3)
  : "d0", "d1", "a0", "a1", "a2", "a3" );
  return res;
}
  __inline
BOOL MUI_DeleteCustomClass( BASE_PAR_DECL struct MUI_CustomClass* mcc)
{
  BASE_EXT_DECL
  register BOOL res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_CustomClass* a0 __asm("a0") = mcc;

  __asm volatile ("
  jsr a6@(-0x72)"
  : "=r" (res)
  : "r" (a6), "r" (a0)
  : "d0", "d1", "a0", "a1" );
  return res;
}
  __inline void MUI_DisposeObject( BASE_PAR_DECL Object *obj)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register Object* a0 __asm("a0") = obj;

  __asm volatile ("
  jsr a6@(-0x24)"
  : "=r" (res)
  : "r" (a6), "r" (a0)
  : "d0", "d1", "a0", "a1" );
}
  __inline LONG MUI_Error( BASE_PAR_DECL0 )
{
  BASE_EXT_DECL
  register LONG res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;

  __asm volatile ("
  jsr a6@(-0x42)"
  : "=r" (res)
  : "r" (a6)
  : "d0", "d1", "a0", "a1" );
  return res;
}
  __inline void MUI_FreeAslRequest( BASE_PAR_DECL APTR requester)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register APTR a0 __asm("a0") = requester;

  __asm volatile ("
  jsr a6@(-0x3c)"
  : "=r" (res)
  : "r" (a6), "r" (a0)
  : "d0", "d1", "a0", "a1" );
}
  __inline void MUI_FreeClass( BASE_PAR_DECL struct IClass *classptr)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct IClass* a0 __asm("a0")=classptr;

  __asm volatile ("
  jsr a6@(-0x54)"
  : "=r" (res)
  : "r" (a6), "r" (a0)
  : "d0", "d1", "a0", "a1" );
}
  __inline struct IClass* MUI_GetClass( BASE_PAR_DECL char *classname)
{
  BASE_EXT_DECL
  register struct IClass* res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register char* a0 __asm("a0")=classname;

  __asm volatile ("
  jsr a6@(-0x4e)"
  : "=r" (res)
  : "r" (a6), "r" (a0)
  : "d0", "d1", "a0", "a1" );
  return res;
}
  __inline Object* MUI_MakeObjectA( BASE_PAR_DECL LONG type, ULONG *params)
{
  BASE_EXT_DECL
  register Object* res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register LONG d0 __asm("d0")=type;
  register ULONG* a0 __asm("a0")=params;

  __asm volatile ("
  jsr a6@(-0x78)"
  : "=r" (res)
  : "r" (a6), "r" (d0), "r" (a0)
  : "d0", "d1", "a0", "a1" );
  return res;
}

  Object *MUI_MakeObject(LONG type, ...)
{
  return(MUI_MakeObjectA(type, (ULONG *)(((ULONG)&type)+4)));
}

  __inline Object* MUI_NewObjectA( BASE_PAR_DECL char *classname, struct TagItem *tags)
{
  BASE_EXT_DECL
  register Object* res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register char* a0 __asm("a0") = classname;
  register struct TagItem* a1 __asm("a1")=tags;

  __asm volatile ("
  jsr a6@(-0x1e)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1)
  : "d0", "d1", "a0", "a1" );
  return res;
}
  Object* MUI_NewObject(char *classname, Tag tag1, ...)
{
 return(MUI_NewObjectA(classname, (struct TagItem *) &tag1));
}


  __inline void MUI_Redraw( BASE_PAR_DECL Object *obj, ULONG flags)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register Object * a0 __asm("a0")=obj;
  register ULONG d0 __asm("d0")=flags;

  __asm volatile ("
  jsr a6@(-0x66)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0)
  : "d0", "d1", "a0", "a1" );
}
  __inline void MUI_RejectIDCMP( BASE_PAR_DECL Object *obj, ULONG flags)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register Object* a0 __asm("a0")=obj;
  register ULONG  d0 __asm("d0")=flags;

  __asm volatile ("
  jsr a6@(-0x60)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0)
  : "d0", "d1", "a0", "a1" );
}
  __inline LONG MUI_RequestA( BASE_PAR_DECL APTR app, APTR win,
LONGBITS flags, char *title,char *gadgets,char *format,APTR params)
{
  BASE_EXT_DECL
  register LONG res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register APTR d0 __asm("d0")=app;
  register APTR d1 __asm("d1")=win;
  register LONGBITS d2 __asm("d2")=flags;
  register char * a0 __asm("a0")=title;
  register char * a1 __asm("a1")=gadgets;
  register char * a2 __asm("a2")=format;
  register APTR  a3 __asm("a3")=params;

  __asm volatile ("
  jsr a6@(-0x2a)"
  : "=r" (res)
  : "r" (a6), "r" (d0), "r" (d1), "r" (d2), "r" (a0), "r" (a1), "r" (a2), "r" (a3)
  : "d0", "d1", "a0", "a1", "d2", "a2", "a3" );
  return res;
}

  LONG MUI_Request(APTR app, APTR win, LONGBITS flags, char *title, char *gadgets, char *format, ...)
{
 return(MUI_RequestA(app, win, flags, title, gadgets, format, (APTR) (((ULONG)&format)+4) ));
}




  __inline void MUI_RequestIDCMP( BASE_PAR_DECL Object *obj, ULONG flags)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register Object * a0 __asm("a0")=obj;
  register ULONG  d0 __asm("d0")=flags;

  __asm volatile ("
  jsr a6@(-0x5a)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0)
  : "d0", "d1", "a0", "a1" );
}
  __inline LONG MUI_SetError( BASE_PAR_DECL LONG num)
{
  BASE_EXT_DECL
  register LONG res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register LONG d0 __asm("d0")=num;

  __asm volatile ("
  jsr a6@(-0x48)"
  : "=r" (res)
  : "r" (a6), "r" (d0)
  : "d0", "d1", "a0", "a1" );
  return res;
}





__inline
APTR MUI_AddClipping( BASE_PAR_DECL struct MUI_RenderInfo *mri, WORD left,WORD
top,WORD width,WORD height)
{
  BASE_EXT_DECL
  register APTR res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register WORD d0 __asm("d0") = left;
  register WORD d1 __asm("d1") = top;
  register WORD d2 __asm("d2") = width;
  register WORD d3 __asm("d3") = height;

  __asm volatile ("
  jsr a6@(-0xa8)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0), "r" (d1), "r" (d2), "r" (d3)
  : "d0", "d1", "d2", "d3", "a0", "a1" );
  return res;
}

__inline
void MUI_RemoveClipping( BASE_PAR_DECL struct MUI_RenderInfo *mri, APTR handle)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register APTR a1 __asm("a1") = handle;

  __asm volatile ("
  jsr a6@(-0xae)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1)
  : "d0", "d1", "a0", "a1" );
}

__inline
APTR MUI_AddClipRegion( BASE_PAR_DECL struct MUI_RenderInfo *mri, struct 
Region *r)
{
  BASE_EXT_DECL
  register APTR res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register struct Region * a1 __asm("a1") = r;

  __asm volatile ("
  jsr a6@(-0xb4)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1)
  : "d0", "d1", "a0", "a1" );
  return res;
}

__inline
void MUI_RemoveClipRegion( BASE_PAR_DECL struct MUI_RenderInfo *mri, APTR 
handle)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register APTR a1 __asm("a1") = handle;

  __asm volatile ("
  jsr a6@(-0xba)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1)
  : "d0", "d1", "a0", "a1" );
}

__inline
BOOL MUI_BeginRefresh( BASE_PAR_DECL struct MUI_RenderInfo *mri, ULONG flags)
{
  BASE_EXT_DECL
  register BOOL res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register ULONG d0 __asm("d0") = flags;

  __asm volatile ("
  jsr a6@(-0xc0)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0)
  : "d0", "d1", "a0", "a1" );
  return res;
}

__inline
void MUI_EndRefresh( BASE_PAR_DECL struct MUI_RenderInfo *mri, ULONG flags)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register ULONG d0 __asm("d0") = flags;

  __asm volatile ("
  jsr a6@(-0xc6)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0)
  : "d0", "d1", "a0", "a1" );
}

__inline
LONG MUI_ObtainPen( BASE_PAR_DECL struct MUI_RenderInfo *mri, struct 
MUI_PenSpec *spec,ULONG flags)
{
  BASE_EXT_DECL
  register LONG res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register struct MUI_PenSpec * a1 __asm("a1") = spec;
  register ULONG d0 __asm("d0") = flags;

  __asm volatile ("
  jsr a6@(-0x9c)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (a1), "r" (d0)
  : "d0", "d1", "a0", "a1" );
  return res;
}

__inline
void MUI_ReleasePen( BASE_PAR_DECL struct MUI_RenderInfo *mri, LONG pen)
{
  BASE_EXT_DECL
  register res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register struct MUI_RenderInfo* a0 __asm("a0") = mri;
  register LONG d0 __asm("d0") = pen;

  __asm volatile ("
  jsr a6@(-0xa2)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0)
  : "d0", "d1", "a0", "a1" );
}

__inline
BOOL MUI_Layout( BASE_PAR_DECL Object *obj,LONG left,LONG top,LONG width,LONG 
height,ULONG flags)
{
  BASE_EXT_DECL
  register BOOL res __asm("d0");
  register struct Library* a6 __asm("a6") = BASE_NAME;
  register Object * a0 __asm("a0") = obj;
  register LONG d0 __asm("d0") = left;
  register LONG d1 __asm("d1") = top;
  register LONG d2 __asm("d2") = width;
  register LONG d3 __asm("d3") = height;
  register ULONG d4 __asm("d4") = flags;

  __asm volatile ("
  jsr a6@(-0x7e)"
  : "=r" (res)
  : "r" (a6), "r" (a0), "r" (d0), "r" (d1), "r" (d2), "r" (d3), "r" (d4)
  : "d0", "d1", "d2", "d3", "d4", "a0", "a1" );
  return res;
}



#undef BASE_EXT_DECL
#undef BASE_PAR_DECL
#undef BASE_PAR_DECL0
#undef BASE_NAME

__END_DECLS

#endif /* _INLINE_MUIMASTER_H */


