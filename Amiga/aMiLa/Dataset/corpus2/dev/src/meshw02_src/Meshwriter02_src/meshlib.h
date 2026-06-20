#include <exec/types.h>
#include "meshwriter_public.h"
#include "compiler.h"

/********************************************************************/

extern ULONG __saveds ASM MWLMeshNew();
extern ULONG __saveds ASM MWLMeshDelete(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM MWLMeshNameSet(register __d1 ULONG meshhandle,register __d2 STRPTR name );
extern ULONG __saveds ASM MWLMeshNameGet(register __d1 ULONG meshhandle, register __d2 STRPTR *name);
extern ULONG __saveds ASM MWLMeshCopyrightSet(register __d1 ULONG meshhandle,register __d2 STRPTR copyright);
extern ULONG __saveds ASM MWLMeshCopyrightGet(register __d1 ULONG meshhandle, register __d2 STRPTR *copyright);
extern ULONG __saveds ASM MWLMeshMaterialAdd(register __d1 ULONG meshhandle, register __d2 ULONG *materialhandle);
extern ULONG __saveds ASM MWLMeshMaterialNameSet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __d3 STRPTR materialname);
extern ULONG __saveds ASM MWLMeshMaterialNameGet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __d3 STRPTR *name);
extern ULONG __saveds ASM MWLMeshMaterialAmbientColorSet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __a0 TOCLColor *color);
extern ULONG __saveds ASM MWLMeshMaterialAmbientColorGet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __a0 TOCLColor *color);
extern ULONG __saveds ASM MWLMeshMaterialShininessSet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __d3 TOCLFloat shininess);
extern ULONG __saveds ASM MWLMeshMaterialShininessGet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __d3 TOCLFloat *shininess);
extern ULONG __saveds ASM MWLMeshMaterialTransparencySet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __d3 TOCLFloat transparency);
extern ULONG __saveds ASM MWLMeshMaterialTransparencyGet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __d3 TOCLFloat *transparency);
extern ULONG __saveds ASM MWLMeshPolygonAdd(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle);
extern ULONG __saveds ASM MWLMeshPolygonMaterialSet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle);
extern ULONG __saveds ASM MWLMeshPolygonVertexAdd(register __d1 ULONG meshhandle,register __a0 TOCLVertex *vertex);
extern ULONG __saveds ASM MWLMeshTriangleAdd(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __a0 TOCLVertex *vertex1,register __a1 TOCLVertex *vertex2,register __a2 TOCLVertex *vertex3);
extern ULONG __saveds ASM MWLMeshNumberOfMaterialsGet(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM MWLMeshNumberOfPolygonsGet(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM MWLMeshNumberOfVerticesGet(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM MWLMeshCameraLightDefaultSet(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM MWLMeshCameraPositionSet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *position);
extern ULONG __saveds ASM MWLMeshCameraPositionGet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *position);
extern ULONG __saveds ASM MWLMeshCameraLookAtSet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *lookat);
extern ULONG __saveds ASM MWLMeshCameraLookAtGet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *lookat);
extern ULONG __saveds ASM MWLMeshLightPositionSet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *position);
extern ULONG __saveds ASM MWLMeshLightPositionGet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *position);
extern ULONG __saveds ASM MWLMeshLightColorSet(register __d1 ULONG meshhandle,register __a0 TOCLColor *color);
extern ULONG __saveds ASM MWLMeshLightColorGet(register __d1 ULONG meshhandle,register __a0 TOCLColor *color);
extern STRPTR * __saveds ASM MWL3DFileFormatNamesGet();
extern ULONG __saveds ASM MWL3DFileFormatIDGet(register __d1 STRPTR ffname);
extern STRPTR __saveds ASM MWL3DFileFormatExtensionGet(register __d1 ULONG ffid);
extern ULONG __saveds ASM MWL3DFileFormatNumberOfGet();
extern ULONG __saveds ASM MWLMeshSave3D(register __d1 ULONG meshhandle,register __d2 ULONG id,register __d3 STRPTR filename,register __a0 struct TagItem *taglist);
extern STRPTR * __saveds ASM MWL2DFileFormatNamesGet();
extern ULONG __saveds ASM MWL2DFileFormatIDGet(register __d1 STRPTR ffname);
extern STRPTR __saveds ASM MWL2DFileFormatExtensionGet(register __d1 ULONG ffid);
extern ULONG __saveds ASM MWL2DFileFormatNumberOfGet();
extern ULONG __saveds ASM MWLMeshSave2D(register __d1 ULONG meshhandle,register __d2 ULONG id,register __d3 STRPTR filename,register __d4 ULONG viewtype,register __d5 ULONG drawmode,register __a0 struct TagItem *taglist);
extern STRPTR * __saveds ASM MWLDrawModeNamesGet();
extern ULONG __saveds ASM MWLDrawModeIDGet(register __d1 STRPTR ffname);
extern ULONG __saveds ASM MWLDrawModeNumberOfGet();

extern ULONG __saveds ASM MWLMeshVertexAdd(register __d1 ULONG meshhandle,register __a0 TOCLVertex *vertex,register __d2 ULONG *index);
extern ULONG __saveds ASM MWLMeshPolygonVertexAssign(register __d1 ULONG meshhandle,register __d2 ULONG index);

extern ULONG __saveds ASM MWLMeshCTMReset(register __d1 ULONG meshhandle);
extern ULONG __saveds ASM MWLMeshTranslationChange(register __d1 ULONG meshhandle,register __a0 TOCLVertex *translation,register __d2 ULONG operation);
extern ULONG __saveds ASM MWLMeshTranslationGet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *translation);
extern ULONG __saveds ASM MWLMeshScaleChange(register __d1 ULONG meshhandle,register __a0 TOCLVertex *scale,register __d2 ULONG operation);
extern ULONG __saveds ASM MWLMeshScaleGet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *scale);
extern ULONG __saveds ASM MWLMeshRotationChange(register __d1 ULONG meshhandle,register __a0 TOCLVertex *rotation,register __d2 ULONG operation);                                
extern ULONG __saveds ASM MWLMeshRotationGet(register __d1 ULONG meshhandle,register __a0 TOCLVertex *rotation);

extern ULONG __saveds ASM MWLMeshMaterialDiffuseColorSet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __a0 TOCLColor *color);
extern ULONG __saveds ASM MWLMeshMaterialDiffuseColorGet(register __d1 ULONG meshhandle,register __d2 ULONG materialhandle,register __a0 TOCLColor *color);


/************************* End of file ******************************/
