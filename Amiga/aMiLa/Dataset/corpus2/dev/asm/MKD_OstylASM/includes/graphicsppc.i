        IFND    GRAPHICPPC_I
GRAPHICPPC_I    SET     1

        INCDIR  INCLUDES:
        INCLUDE EXEC/TYPES.i
        INCLUDE EXEC/NODES.i
        INCLUDE INTUITION/SCREENS.i

;---- Chunky CkScreen -----------------------------------------

        STRUCTURE ChunkyScreen,0
        APTR    cks_Screen

        ULONG   cks_BitmapSize
        ULONG   cks_ChkmapSize
        ULONG   cks_BitmapLength

        UWORD   cks_ChunkyWidth
        UWORD   cks_ChunkyHeight
 
        APTR    cks_LogicalBitmap
        APTR    cks_PhysicalBitmap
        APTR    cks_DBufInfo

        UBYTE   cks_ChunkyMode
        APTR    cks_ChunkyMap

        APTR    cks_MouseDef
        UWORD   cks_Flags
        LABEL   cks_SIZEOF

;---- 3D Structures -----------------------------------------

        STRUCTURE LwTransform,0
        APTR    lwt_SourceVertices
        APTR    lwt_TargetVertices
        APTR    lwt_NewVertices
        UBYTE   lwt_Level
        LABEL   lwt_SIZEOF

        ;----

        STRUCTURE Transforms,0
        LONG    nobj_AngleX
        LONG    nobj_AngleY
        LONG    nobj_AngleZ
        APTR    nobj_3dVertices
        APTR    nobj_2dVertices
        APTR    nobj_VertNormals
        APTR    nobj_SurfNormals
        LONG    nobj_XCenter
        LONG    nobj_YCenter
        LONG    nobj_ZCenter
        UWORD   nobj_Flags
        APTR    nobj_SortList
        APTR    nobj_MergeList
        APTR    nobj_PolyZMoyList
        LABEL   nobj_SIZEOF

        ;----

        STRUCTURE LwObj,0
        STRUCT  lwo_Node,LN_SIZE
        APTR    lwo_VerticesPTR
        APTR    lwo_PolygonsPTR
        APTR    lwo_StructLwSurf
        UWORD   lwo_TotalVertices
        UWORD   lwo_TotalPolygons
        UWORD   lwo_Flags
        APTR    lwo_VerticesFP
        STRUCT  lwo_Transforms,nobj_SIZEOF
        APTR    lwo_SurfacesPTR
        UWORD   lwo_TotalSurfaces
        APTR    lwo_Targa
        STRUCT  lwo_Transform,lwt_SIZEOF
        LABEL   lwo_SIZEOF

        ;----

        STRUCTURE Render,0
        UWORD   rndr_MaxSegSize
        APTR    rndr_CoeffHB
        APTR    rndr_CoeffHM
        APTR    rndr_CoeffMB
        LABEL   rndr_SIZEOF

        ;----

        STRUCTURE LwScene,0
        STRUCT  lwsc_Render,rndr_SIZEOF
        APTR    lwsc_FirstLwo
        LABEL   lwsc_SIZEOF

        ;----

        STRUCTURE LwSurf,0
        STRUCT  lws_Node,LN_SIZE
        LONG    lws_XTxSize
        LONG    lws_YTxSize
        LONG    lws_ZTxSize
        LONG    lws_XTxCenter
        LONG    lws_YTxCenter
        LONG    lws_ZTxCenter
        UWORD   lws_Flags
        APTR    lws_UVList
        APTR    lws_Texture
        LABEL   lws_SIZEOF

        ;---- Flags

        BITDEF  LWS,TA_X,0
        BITDEF  LWS,TA_Y,1
        BITDEF  LWS,TA_Z,2

        BITDEF  LWS,TEXFMT_TGA24,15
        BITDEF  LWS,TEXFMT_CHNK8,14
        BITDEF  LWS,TEXFMT_RGB15,13

        BITDEF  LWO,FIXEDPOINT,15
        BITDEF  LWO,TRANSFORMABLE,14
        BITDEF  LWO,ENVMAPPED,13

;---- Sprites -----------------------------------------------

        STRUCTURE NewSprite,0
        STRUCT  nsp_NextSprite,LN_SIZE
        LONG    nsp_xBeg
        LONG    nsp_yBeg
        LONG    nsp_xEnd
        LONG    nsp_yEnd
        WORD    nsp_MidX
        WORD    nsp_MidY
        UWORD   nsp_LockedRGB           ;15b RGB value
        UWORD   nsp_Alpha               ;0 to 127 alpha value
        LONG    nsp_XYScale
        APTR    nsp_FrameList
        UWORD   nsp_FrameAmount
        UBYTE   nsp_Frame
        LABEL   nsp_SIZEOF

        STRUCTURE SpriteFrame,0
        APTR    spf_Map
        UWORD   spf_uBeg
        UWORD   spf_vBeg
        UWORD   spf_uEnd
        UWORD   spf_vEnd
        UWORD   spf_Delay
        LABEL   spf_SIZEOF

        STRUCTURE SpriteMap,0
        STRUCT  spm_NextMap,LN_SIZE
        APTR    spm_RawMapData
        APTR    spm_TgaMapData
        LABEL   spm_SIZEOF

;---- Targa -------------------------------------------------

        STRUCTURE Targa,0
        STRUCT  tga_Next,LN_SIZE
        APTR    tga_Header
        APTR    tga_Converted
        UWORD   tga_Flags
        UWORD   tga_ImageWidth
        UWORD   tga_ImageHeight
        ULONG   tga_Unused1
        ULONG   tga_Unused2
        LABEL   tga_SIZEOF

        ;Flags

LTGA_DONTCONVERT    EQU     0
LTGA_CONVERTCHK15   EQU     1

        ENDC    GRAPHICPPC_I            ;GRAPHICPPC_I
