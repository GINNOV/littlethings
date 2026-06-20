/*106:*/
#line 76 "ui.nw"

#ifndef INTERPRETER_CINT_H
#define INTERPRETER_CINT_H 1
/*110:*/
#line 152 "ui.nw"

#if !defined(_AMIGA) && !defined(IN_STDDEF_H)
#   include <in_stddef.h>
#endif

/*:110*//*111:*/
#line 170 "ui.nw"

#ifndef INTUITION_CLASSES_H
#   include <intuition/classes.h>
#endif
#ifndef INTUITION_CLASSUSR_H
#   include <intuition/classusr.h>
#endif
#ifndef TAGS_H
#   include <utility/tagitem.h>
#endif

/*:111*//*112:*/
#line 185 "ui.nw"

#ifndef TAGBASE_H
#   include <tagbase.h>
#endif

/*:112*//*113:*/
#line 193 "ui.nw"

#ifndef RETURN_H
#   include <return.h>
#endif

/*:113*/
#line 79 "ui.nw"

/*108:*/
#line 110 "ui.nw"

#ifndef _AMIGA
#   ifndef IFAMIGA
# define IFAMIGA(yes,no)      no
#   endif
/*156:*/
#line 239 "interpreter.nw"

extern BOOL InitCIntClass P((void));

/*:156*//*159:*/
#line 297 "interpreter.nw"

extern BOOL __libqual FreeCIntClass P((void));

/*:159*/
#line 115 "ui.nw"

#endif

/*:108*//*114:*/
#line 202 "ui.nw"

#define CINTCLASS "cintclass"
#define CINTNAME "cint.library"

/*:114*//*115:*/
#line 216 "ui.nw"

typedef LONG OFFSET;
#define INITIAL_MEMORY_SIZE 16384

/*:115*/
#line 80 "ui.nw"

/*19:*/
#line 169 "inside.nw"

typedef struct __Symbol*Symbol;

/*:19*//*23:*/
#line 222 "inside.nw"

typedef struct __Array*Array;

/*:23*//*30:*/
#line 399 "inside.nw"

typedef struct __TypeDesc TypeDesc;

/*:30*//*116:*/
#line 220 "ui.nw"

typedef UBYTE*MPTR;
#ifndef INTERN_H
typedef int ObjType;
#endif

/*:116*/
#line 81 "ui.nw"

/*21:*/
#line 204 "inside.nw"

struct __Array
{
ObjType objtype;
ULONG a_Size;
ULONG a_NumElements;
APTR a_Element[1];
};

/*:21*//*22:*/
#line 217 "inside.nw"

#define ACC_APPEND     (~0L)

/*:22*//*118:*/
#line 268 "ui.nw"

enum VFBit
{
VFB_CONSTANT,
VFB_SYMBOL,

VFB_FUNCTION,
VFB_C_FUNCTION,

VFB_DECLARED,

VFB_EMPTY,

VFB_REQ_IOBJ,
/*225:*/
#line 244 "intern.nw"

VFB_TREE,
VFB_STACK,

VFB_FIELD,

#define VF_TREE     (1L << VFB_TREE)
#define VF_STACK     (1L << VFB_STACK)
#define VF_FIELD     (1L << VFB_FIELD)

/*:225*/
#line 282 "ui.nw"

VFB_TYPE,
VFB_INIT,
};

#define VF_CONSTANT (1L << VFB_CONSTANT)
#define VF_SYMBOL (1L << VFB_SYMBOL)
#define VF_C_FUNCTION (1L << VFB_C_FUNCTION)
#define VF_FUNCTION (1L << VFB_FUNCTION)
#define VF_DECLARED (1L << VFB_DECLARED)
#define VF_EMPTY (1L << VFB_EMPTY)
#define VF_REQ_IOBJ (1L << VFB_REQ_IOBJ)

#define VF_TYPE  (1L << VFB_TYPE)
#define VF_INIT  (1L << VFB_INIT)

/*:118*//*120:*/
#line 306 "ui.nw"

typedef union{
BOOL c_Bool;
BYTE c_Char;
UBYTE c_UChar;
WORD c_Short;
UWORD c_UShort;
LONG c_Integer;
ULONG c_UInteger;
float c_Float;
double c_Double;
STRPTR c_String;
MPTR c_MPtr;


}Contents;

/*:120*//*122:*/
#line 339 "ui.nw"

typedef enum
{
VT_NONE,
VT_BOOL,
VT_CHAR,
VT_INT,
VT_DOUBLE,
VT_STRING,

VT_LAST,

VT_VOID,
VT_PTR,
VT_ARRAY,
VT_STRUCT,
VT_UNION,

VT_ENUM,
VT_LABEL,
VT_FUNC_PTR,
VT_ENUM_TAG,
VT_STRUCT_TAG,
VT_UNION_TAG,
VT_FUNC,
VT_UCHAR,
VT_USHORT,VT_SHORT,
VT_ULONG,VT_LONG,
VT_UINT,
VT_FLOAT,

VT_END
}ValueType;

/*:122*//*123:*/
#line 375 "ui.nw"

/*31:*/
#line 426 "inside.nw"

struct __TypeDesc
{
TypeDesc*td_Next;
ValueType td_Type;
union
{
Symbol td_structTag;
Array td_fields;
APTR td_arraySize;
}u;
ULONG td_Size;
};

/*:31*//*32:*/
#line 446 "inside.nw"

#define td_StructTag    u.td_structTag
#define td_Fields       u.td_fields
#define td_ArraySize    u.td_arraySize

/*:32*/
#line 376 "ui.nw"

/*34:*/
#line 471 "inside.nw"

typedef struct __Value
{
TypeDesc v_TypeDesc;
ULONG v_Flags;
Contents v_Contents;
MPTR v_Address;
}Value;

/*:34*//*36:*/
#line 483 "inside.nw"

#define v_Type     v_TypeDesc.td_Type
#define v_Bool     v_Contents.c_Bool
#define v_Char     v_Contents.c_Char
#define v_UChar     v_Contents.c_UChar
#define v_Short     v_Contents.c_Short
#define v_UShort    v_Contents.c_UShort
#define v_Int     v_Contents.c_Integer
#define v_UInt     v_Contents.c_UInteger
#define v_Float     v_Contents.c_Float
#define v_Double    v_Contents.c_Double
#define v_String    v_Contents.c_String
#define v_MPtr     v_Contents.c_MPtr

/*:36*/
#line 377 "ui.nw"


/*:123*//*125:*/
#line 403 "ui.nw"

typedef struct __Fparams{
union
{
double(*fp_dFunction)P((ULONG,...));
ULONG(*fp_function)P((ULONG,...));
ULONG(*fp_iFunction)P((APTR,Value*,...));
}fp_Func;

Array fp_Array;
int fp_NumParams;
ULONG fp_StackFrame;
}Fparams;

#define fp_IFunction     fp_Func.fp_iFunction
#define fp_Function      fp_Func.fp_function
#define fp_DFunction     fp_Func.fp_dFunction

/*:125*//*126:*/
#line 424 "ui.nw"

/*17:*/
#line 143 "inside.nw"

struct __Symbol
{
ObjType objtype;
Value s_Value;
Fparams*s_Param;

OFFSET s_Offset;
APTR s_Tree;
ULONG Line;
ULONG Column;
STRPTR Ptr;
UBYTE s_Name[1];
};

/*:17*//*18:*/
#line 161 "inside.nw"

#define s_TypeDesc    s_Value.v_TypeDesc
#define s_Type       s_Value.v_TypeDesc.td_Type
#define s_Flags       s_Value.v_Flags

/*:18*/
#line 425 "ui.nw"


/*:126*//*128:*/
#line 437 "ui.nw"

typedef struct
{
char*sd_Proto;
APTR sd_Address;
}SymDef;

/*:128*/
#line 82 "ui.nw"

/*6:*/
#line 251 "cint.nw"

enum CIM
{
CIM_Execute= CI_MethodBase,
CIM_SetSymbolValue
};

/*:6*//*7:*/
#line 265 "cint.nw"

struct cimExecute
{
ULONG MethodID;
Value*cime_Result;
};

struct cimSetSymbolValue
{
ULONG MethodID;
STRPTR cimssv_Name;
Value*cimssv_Wert;
};

/*:7*//*8:*/
#line 282 "cint.nw"

enum CIA
{
CIA_Replace= CI_TagBase,
CIA_IOMode,
CIA_Source,
CIA_StaticString,
CIA_ErrorCode,
CIA_ErrorMessage,
CIA_CurrentLine,
CIA_CurrentColumn,
CIA_CurrentPos,
CIA_UserData,
CIA_Version,
CIA_VersionString,

#ifdef DEBUG
CIA_LexDebug,
CIA_ExpDebug,
CIA_SymDebug,
CIA_StmtDebug
#endif
};

/*:8*//*9:*/
#line 308 "cint.nw"

#define IOM_STRING 0 
#define IOM_FILE 1

/*:9*/
#line 83 "ui.nw"

#endif

/*:106*/
