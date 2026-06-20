enum GadID {
   GD_Copyright,
   GD_Quit,
   GD_Load,
   GD_Save,
   GD_PicClipDimensions,
   GD_PicWidth,
   GD_PicHeight,
   GD_PicDepth,
   GD_PicSize,
   GD_ClipWidth,
   GD_ClipHeight,
   GD_ClipLeft,
   GD_ClipTop,
   GD_ClipSize,
   GD_FileMode,
   GD_RenderMode,
   GD_DrawCross,
   GD_Info,
   GD_ByteBoundry,
   GD_Sentinal
};

enum FileModeType {
   FM_Single,
   FM_Sequence,
   FM_Multiple,
   FM_Dir
};

enum RenderModeType {
   RM_Interleave,
   RM_Raw,
   RM_Copper,
   RM_Font8,
//   RM_Sprite    Think this one over. Should it be implemented?????
};

enum ByteBoundry {
   BB_None,
   BB_Type1,
   BB_Type2,
   BB_Type3,
};
