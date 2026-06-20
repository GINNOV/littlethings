/*
**      $VER: td.h 0.1 (20.6.1999)
**
**      Creation date : 11.4.1999
**
**      Description       :
**         Declaration of the library functions, and initialization functions.
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef INCLUDE_TD_H
#define INCLUDE_TD_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <exec/types.h>

/*
** Project includes
*/
#include "td_public.h"
#include "compiler.h"

/*************************** Functions ******************************/
extern ULONG initTDLibrary();
extern VOID freeTDLibrary();

extern ULONG __saveds ASM tdSpaceNew();
extern TDerrors __saveds ASM tdSpaceDelete(register __d1 ULONG spacehandle);
extern TDerrors __saveds ASM tdNameSet(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __d4 STRPTR name);
extern TDerrors __saveds ASM tdNameGet(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __d4 STRPTR *name);
extern TDerrors __saveds ASM tdAdd(register __d1 ULONG spacehandle,register __d2 TDenum type);
extern ULONG __saveds ASM tdNofGet(register __d1 ULONG spacehandle,register __d2 TDenum type);
extern TDerrors __saveds ASM tdMaterialSetuba(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 UBYTE *array);
extern TDerrors __saveds ASM tdMaterialGetuba(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 UBYTE *array);
extern TDerrors __saveds ASM tdMaterialSetfa(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 TDfloat *array);
extern TDerrors __saveds ASM tdMaterialGetfa(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 TDfloat *array);
extern TDerrors __saveds ASM tdMaterialSetf(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __d4 TDfloat value);
extern TDerrors __saveds ASM tdMaterialGetf(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __d4 TDfloat *value);
extern TDerrors __saveds ASM tdCTMReset(register __d1 ULONG spacehandle);
extern TDerrors __saveds ASM tdCTMChangedv(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDvectord *vector,register __d3 TDenum operation);
extern TDerrors __saveds ASM tdCTMChangefv(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDvectorf *vector,register __d3 TDenum operation);
extern TDerrors __saveds ASM tdCTMChange3da(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDdouble array[3],register __d3 TDenum operation);
extern TDerrors __saveds ASM tdCTMChange3fa(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDfloat array[3],register __d3 TDenum operation);
extern TDerrors __saveds ASM tdCTMGetfv(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDvectorf *vector);
extern TDerrors __saveds ASM tdCTMGet3da(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDdouble array[3]);
extern TDerrors __saveds ASM tdCTMGet3fa(register __d1 ULONG spacehandle,register __d2 TDenum type,register __a0 TDfloat array[3]);
extern TDerrors __saveds ASM tdObjectSetfa(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 TDfloat *array);
extern TDerrors __saveds ASM tdObjectGetfa(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 TDfloat *array);
extern TDerrors __saveds ASM tdObjectSetda(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 TDdouble *array);
extern TDerrors __saveds ASM tdObjectGetda(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __a0 TDdouble *array);
extern TDerrors __saveds ASM tdTypeGet(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index,register __d4 TDenum *rtype);
extern TDerrors __saveds ASM tdCurrent(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG index );
extern TDerrors __saveds ASM tdBegin(register __d1 ULONG spacehandle,register __d2 TDenum type);
extern TDerrors __saveds ASM tdEnd(register __d1 ULONG spacehandle,register __d2 TDenum type);
extern TDerrors __saveds ASM tdVertexAdd3f(register __d1 ULONG spacehandle,register __d2 TDfloat x,register __d3 TDfloat y,register __d4 TDfloat z);
extern TDerrors __saveds ASM tdVertexGet3d(register __d1 ULONG spacehandle,register __d2 ULONG vertexindex,register __d3 TDdouble *x,register __d4 TDdouble *y,register __d5 TDdouble *z);
extern TDerrors __saveds ASM tdVertexGet3f(register __d1 ULONG spacehandle,register __d2 ULONG vertexindex,register __d3 TDfloat *x,register __d4 TDfloat *y,register __d5 TDfloat *z);
extern TDerrors __saveds ASM tdVertexAdddv(register __d1 ULONG spacehandle,register __a0 TDvectord *vertex);
extern TDerrors __saveds ASM tdVertexAddfv(register __d1 ULONG spacehandle,register __a0 TDvectorf *vertex);
extern TDerrors __saveds ASM tdVertexAdd3da(register __d1 ULONG spacehandle,register __a0 TDdouble array[3]);
extern TDerrors __saveds ASM tdVertexAdd3fa(register __d1 ULONG spacehandle,register __a0 TDfloat array[3]);
extern TDerrors __saveds ASM tdVertexGetdv(register __d1 ULONG spacehandle,register __d2 ULONG vertexindex,register __a0 TDvectord *vertex);
extern TDerrors __saveds ASM tdVertexGetfv(register __d1 ULONG spacehandle,register __d2 ULONG vertexindex,register __a0 TDvectorf *vertex);
extern TDerrors __saveds ASM tdVertexGet3da(register __d1 ULONG spacehandle,register __d2 ULONG vertexindex,register __a0 TDdouble array[3]);
extern TDerrors __saveds ASM tdVertexGet3fa(register __d1 ULONG spacehandle,register __d2 ULONG vertexindex,register __a0 TDfloat array[3]);
extern TDerrors __saveds ASM tdQuadAdd4dv(register __d1 ULONG spacehandle,register __a0 TDvectord *vertex1,register __a1 TDvectord *vertex2,register __a2 TDvectord *vertex3,register __a3 TDvectord *vertex4);
extern TDerrors __saveds ASM tdQuadAdd4fv(register __d1 ULONG spacehandle,register __a0 TDvectorf *vertex1,register __a1 TDvectorf *vertex2,register __a2 TDvectorf *vertex3,register __a3 TDvectorf *vertex4);
extern TDerrors __saveds ASM tdQuadAdd12da(register __d1 ULONG spacehandle,register __a0 TDdouble array[12]);
extern TDerrors __saveds ASM tdQuadAdd12fa(register __d1 ULONG spacehandle,register __a0 TDfloat array[12]);
extern TDerrors __saveds ASM tdTriangleAdd4dv(register __d1 ULONG spacehandle,register __a0 TDvectord *vertex1,register __a1 TDvectord *vertex2,register __a2 TDvectord *vertex3);
extern TDerrors __saveds ASM tdTriangleAdd4df(register __d1 ULONG spacehandle,register __a0 TDvectorf *vertex1,register __a1 TDvectorf *vertex2,register __a2 TDvectorf *vertex3);
extern TDerrors __saveds ASM tdTriangleAdd9da(register __d1 ULONG spacehandle,register __a0 TDdouble array[9]);
extern TDerrors __saveds ASM tdTriangleAdd9fa(register __d1 ULONG spacehandle,register __a0 TDfloat array[9]);
extern TDerrors __saveds ASM tdVertexAssign(register __d1 ULONG spacehandle,register __d2 ULONG index);
extern TDerrors __saveds ASM tdVertexIndexGet(register __d1 ULONG spacehandle,register __d2 ULONG pindex,register __d3 ULONG *index);
extern TDerrors __saveds ASM tdChildSetl(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG value);
extern TDerrors __saveds ASM tdChildGetl(register __d1 ULONG spacehandle,register __d2 TDenum type,register __d3 ULONG *value);
extern ULONG __saveds ASM tdXNofGet(register __d1 TDenum type);
extern STRPTR __saveds ASM tdXExtGet(register __d1 TDenum type,register __d2 STRPTR name);
extern STRPTR __saveds ASM tdXNameGet(register __d1 TDenum type,register __d2 ULONG index);
extern TDenum * __saveds ASM tdXSupportedGet(register __d1 TDenum type,register __d2 STRPTR name);
extern STRPTR __saveds ASM tdXDescGet(register __d1 TDenum type);
extern STRPTR __saveds ASM tdXLibGet(register __d1 TDenum type,register __d2 STRPTR name);



extern ULONG __saveds ASM meshCameraLightDefaultSet(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM meshCameraPositionSetdv(register __d1 ULONG meshhandle,register __a0 TTDOVertexd *position);
extern ULONG __saveds ASM meshCameraPositionSetfv(register __d1 ULONG meshhandle,register __a0 TTDOVertexf *position);
extern ULONG __saveds ASM meshCameraPositionSet3da(register __d1 ULONG meshhandle,register __a0 TTDODouble position[3]);
extern ULONG __saveds ASM meshCameraPositionSet3fa(register __d1 ULONG meshhandle,register __a0 TTDOFloat position[3]);
extern ULONG __saveds ASM meshCameraPositionGetdv(register __d1 ULONG meshhandle,register __a0 TTDOVertexd *position);
extern ULONG __saveds ASM meshCameraPositionGetfv(register __d1 ULONG meshhandle,register __a0 TTDOVertexf *position);
extern ULONG __saveds ASM meshCameraPositionGet3da(register __d1 ULONG meshhandle,register __a0 TTDODouble position[3]);
extern ULONG __saveds ASM meshCameraPositionGet3fa(register __d1 ULONG meshhandle,register __a0 TTDOFloat position[3]);
extern ULONG __saveds ASM meshCameraLookAtSetdv(register __d1 ULONG meshhandle,register __a0 TTDOVertexd *lookat);
extern ULONG __saveds ASM meshCameraLookAtSetfv(register __d1 ULONG meshhandle,register __a0 TTDOVertexf *lookat);
extern ULONG __saveds ASM meshCameraLookAtSet3da(register __d1 ULONG meshhandle,register __a0 TTDODouble lookat[3]);
extern ULONG __saveds ASM meshCameraLookAtSet3fa(register __d1 ULONG meshhandle,register __a0 TTDOFloat lookat[3]);
extern ULONG __saveds ASM meshCameraLookAtGetdv(register __d1 ULONG meshhandle,register __a0 TTDOVertexd *lookat);
extern ULONG __saveds ASM meshCameraLookAtGetfv(register __d1 ULONG meshhandle,register __a0 TTDOVertexf *lookat);
extern ULONG __saveds ASM meshCameraLookAtGet3da(register __d1 ULONG meshhandle,register __a0 TTDODouble lookat[3]);
extern ULONG __saveds ASM meshCameraLookAtGet3fa(register __d1 ULONG meshhandle,register __a0 TTDOFloat lookat[3]);
extern ULONG __saveds ASM meshLightPositionSetdv(register __d1 ULONG meshhandle,register __a0 TTDOVertexd *position);
extern ULONG __saveds ASM meshLightPositionSetfv(register __d1 ULONG meshhandle,register __a0 TTDOVertexf *position);
extern ULONG __saveds ASM meshLightPositionSet3da(register __d1 ULONG meshhandle,register __a0 TTDODouble  position[3]);
extern ULONG __saveds ASM meshLightPositionSet3fa(register __d1 ULONG meshhandle,register __a0 TTDOFloat  position[3]);
extern ULONG __saveds ASM meshLightPositionGetdv(register __d1 ULONG meshhandle,register __a0 TTDOVertexd *position);
extern ULONG __saveds ASM meshLightPositionGetfv(register __d1 ULONG meshhandle,register __a0 TTDOVertexf *position);
extern ULONG __saveds ASM meshLightPositionGet3da(register __d1 ULONG meshhandle,register __a0 TTDODouble position[3]);
extern ULONG __saveds ASM meshLightPositionGet3fa(register __d1 ULONG meshhandle,register __a0 TTDOFloat position[3]);
//extern ULONG __saveds ASM meshLightColorSetubc(register __d1 ULONG meshhandle,register __a0 TTDOColorub *color);
//extern ULONG __saveds ASM meshLightColorGetubc(register __d1 ULONG meshhandle,register __a0 TTDOColorub *color);
extern ULONG __saveds ASM meshBoundingBoxGetd(register __d1 ULONG meshhandle,register __a0 TTDOBBoxd *bbox);
extern ULONG __saveds ASM meshBoundingBoxGetf(register __d1 ULONG meshhandle,register __a0 TTDOBBoxf *bbox);

extern ULONG __saveds ASM meshSave3D(register __d1 ULONG meshhandle,register __d2 STRPTR formatname,register __d3 STRPTR filename,register __a0 struct Screen *screen);
extern ULONG __saveds ASM meshLoad3D(register __d1 ULONG *meshhandle,register __d3 STRPTR filename,register __d4 ULONG *erroffset,register __a0 struct Screen *screen);

//=> tdXSave3D tdXLoad3D immer mit name !

extern ULONG fill3DFormatArrays();
extern VOID free3DFormatArrays();

#endif

/************************* End of file ******************************/
