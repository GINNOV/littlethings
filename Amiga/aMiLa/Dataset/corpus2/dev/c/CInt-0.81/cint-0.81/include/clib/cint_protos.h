/*107:*/
#line 90 "ui.nw"

#ifndef CLIB_CINT_PROTOS_H
#define CLIB_CINT_PROTOS_H 1
#ifndef EXEC_TYPES_H
#   include <exec/types.h>
#endif

#ifdef _AMIGA
#   define __libqual	 __asm __saveds
#else
#   define __libqual
#endif

/*131:*/
#line 53 "cint_i.nw"

extern int __libqual CInt_SetSymbolValue P((REG(a0)STRPTR,REG(a1)Value*));


/*:131*//*133:*/
#line 87 "cint_i.nw"

extern int __libqual CInt_ExecuteString P((REG(a0)STRPTR,REG(a1)STRPTR**));


/*:133*//*135:*/
#line 101 "cint_i.nw"

extern int __libqual CInt_AddGlobalSymbols P((REG(a0)SymDef*));


/*:135*//*137:*/
#line 122 "cint_i.nw"

extern void __libqual CInt_FreeErrorMessages P((REG(a0)STRPTR*));


/*:137*//*139:*/
#line 136 "cint_i.nw"

extern void __libqual CInt_InitValueStruct P((REG(a0)Value*ptr));

/*:139*//*141:*/
#line 153 "cint_i.nw"

#ifdef _AMIGA
extern ULONG __libqual CInt_DoMethodA(REG(a0)Object*obj,REG(a1)Msg msg);
extern ULONG CInt_DoMethod(Object*obj,...);
/*143:*/
#line 179 "cint_i.nw"

extern APTR __libqual CInt_NewObjectA(REG(a0)struct IClass*classPtr,
REG(a1)UBYTE*classID,
REG(a2)struct TagItem*tagList);
extern APTR CInt_NewObject(struct IClass*classPtr,
UBYTE*classID,
...);

/*:143*//*145:*/
#line 198 "cint_i.nw"

extern ULONG __libqual CInt_SetAttrsA(REG(a0)Object*obj,
REG(a1)struct TagItem*tagList);
extern ULONG CInt_SetAttrs(Object*obj,
...);

/*:145*//*147:*/
#line 218 "cint_i.nw"

extern ULONG __libqual CInt_GetAttr(REG(d0)ULONG attrID,
REG(a0)Object*obj,
REG(a1)ULONG*storagePtr);

/*:147*//*149:*/
#line 234 "cint_i.nw"

extern void __libqual CInt_DisposeObject(REG(a0)Object*obj);


/*:149*/
#line 156 "cint_i.nw"

#endif

/*:141*/
#line 103 "ui.nw"

#endif

/*:107*/
