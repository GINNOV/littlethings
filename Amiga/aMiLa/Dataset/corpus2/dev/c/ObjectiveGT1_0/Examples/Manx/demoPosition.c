/*
** $Filename: demoPosition.c $
** $Release : 1.0            $
** $Revision: 1.047          $
** $Date    : 21/10/92       $
**
**
** (C) Copyright 1992 Davide Massarenti
**              All Rights Reserved
**
** MANX 5.2: cc -ps -wdrunpo -so <name>.c
**           ln -o <name> <name>.o -lOGTglue -lc16
**
*/

#include <OGT/ObjectiveGadTools.h>

#define ARGS_TEMPLATE "FONT/K,SIZE/N"
#define ARGS_FONT       (0)
#define ARGS_SIZE       (1)
#define ARGS_NUMOF      (2)

static LONG args[ ARGS_NUMOF ];


#define ID_X_POS        1
#define ID_X_HANDLE     2
#define ID_X_MODE       3
#define ID_X_VALUE      4

#define ID_Y_POS        5
#define ID_Y_HANDLE     6
#define ID_Y_MODE       7
#define ID_Y_VALUE      8

#define ID_W_DIM        9
#define ID_W_MODE       10
#define ID_W_VALUE      11
#define ID_W_POS        12

#define ID_H_DIM        13
#define ID_H_MODE       14
#define ID_H_VALUE      15
#define ID_H_POS        16

#define ID_REFERENCE    17
#define ID_DEMO         18


static char Class_Group [] =  GROUP_OGT_CLASS;
static char Class_Button[] = BUTTON_OGT_CLASS;
static char Class_String[] = STRING_OGT_CLASS;


struct TextAttr          MyAttr = { NULL, 8 };
struct TextFont         *MyFont;

APTR                     VInfo;
struct Window           *Win;
Object                 **Gads;
struct RDArgs           *Ra;

struct TagItem WindowDescTags[] =
{
   { OVI_GimmeZeroZero    , TRUE                                    },
   { OVI_AdaptWidthToFont , TRUE                                    },
   { OVI_AdaptHeightToFont, TRUE                                    },

   { OGT_ScaleLeft        , OGT_FontRelative                        },
   { OGT_ScaleTop         , OGT_FontRelative                        },
   { OGT_ScaleWidth       , OGT_FontRelative                        },
   { OGT_ScaleHeight      , OGT_FontRelative                        },
   { OGT_DomainXscale     , ~0                                      },
   { OGT_DomainYscale     , ~0                                      },

   { WA_Activate          , TRUE                                    },
   { WA_SmartRefresh      , TRUE                                    },
   { WA_NoCareRefresh     , TRUE                                    },
   { WA_DepthGadget       , TRUE                                    },
   { WA_SizeGadget        , TRUE                                    },
   { WA_DragBar           , TRUE                                    },
   { WA_Left              , 400                                     },
   { WA_Top               , 150                                     },
   { WA_InnerWidth        , 398                                     },
   { WA_InnerHeight       , 300                                     },
   { WA_MaxWidth          , -1                                      },
   { WA_MaxHeight         , -1                                      },
   { WA_IDCMP             , (IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE) },
   { WA_CloseGadget       , TRUE                                    },
   { WA_Title             , "Demo Dimensions"                       },

   { TAG_DONE                                                       },
};


STRPTR Labels1[] =
{
   "Left"  ,
   "Center",
   "Right" ,
   NULL    ,
};

STRPTR Labels2[] =
{
   "Top"   ,
   "Center",
   "Bottom",
   NULL    ,
};

STRPTR Labels3[] =
{
   "Free"     ,
   "Align"    ,
   "Center"   ,
   "In Border",
   NULL       ,
};

STRPTR Labels4[] =
{
   "Fixed"   ,
   "Relative",
   "As Coord",
   NULL      ,
};


struct TagItem Object1_0Desc[] = /* GROUP_OGT_CLASS */
{
   { GA_Left          , 2                     },
   { GA_Top           , 12                    },
   { GA_Width         , 394                   },
   { GA_Height        , 30                    },

   { GA_Text          , "Horizontal Position" },
   { OGT_TextPlacement, OGT_Text_ABOVE        },
   { OGT_DrawFrame    , TRUE                  },

   { TAG_DONE                                 },
};

struct TagItem Object1_1Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID            , ID_X_POS       },
   { GA_RelVerify     , TRUE           },

   { GA_Left          , 4              },
   { GA_Top           , 12             },
   { GA_Width         , 80             },
   { GA_Height        , 16             },

   { GA_Text          , "Pos"          },
   { OGT_TextPlacement, OGT_Text_ABOVE },
   { OGTBU_Labels     , Labels1        },
   { OGTBU_ActiveLabel, 0              },

   { TAG_DONE                          },
};

struct TagItem Object1_2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_X_HANDLE        },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Handle by"        },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels1            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};

struct TagItem Object1_3Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_X_MODE          },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Mode"             },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels3            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};

struct TagItem Object1_4Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID              , ID_X_VALUE         },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Value"            },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },

   { STRINGA_MaxChars   , 32                 },
   { STRINGA_LongVal    , 2                  },
   { GA_TabCycle        , TRUE               },

   { TAG_DONE                                },
};


struct TagItem Object2_0Desc[] = /* GROUP_OGT_CLASS */
{
   { GA_Left          , 2                   },
   { GA_Top           , 54                  },
   { GA_Width         , 394                 },
   { GA_Height        , 30                  },

   { GA_Text          , "Vertical Position" },
   { OGT_TextPlacement, OGT_Text_ABOVE      },
   { OGT_DrawFrame    , TRUE                },

   { TAG_DONE                               },
};

struct TagItem Object2_1Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID            , ID_Y_POS       },
   { GA_RelVerify     , TRUE           },

   { GA_Left          , 4              },
   { GA_Top           , 12             },
   { GA_Width         , 80             },
   { GA_Height        , 16             },

   { GA_Text          , "Pos"          },
   { OGT_TextPlacement, OGT_Text_ABOVE },
   { OGTBU_Labels     , Labels2        },
   { OGTBU_ActiveLabel, 0              },

   { TAG_DONE                          },
};

struct TagItem Object2_2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_Y_HANDLE        },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Handle by"        },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels2            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};

struct TagItem Object2_3Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_Y_MODE          },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Mode"             },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels3            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};

struct TagItem Object2_4Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID              , ID_Y_VALUE         },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Value"            },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },

   { STRINGA_MaxChars   , 32                 },
   { STRINGA_LongVal    , 1                  },
   { GA_TabCycle        , TRUE               },

   { TAG_DONE                                },
};


struct TagItem Object3_0Desc[] = /* GROUP_OGT_CLASS */
{
   { GA_Left          , 2                      },
   { GA_Top           , 96                     },
   { GA_Width         , 394                    },
   { GA_Height        , 30                     },

   { GA_Text          , "Horizontal Dimension" },
   { OGT_TextPlacement, OGT_Text_ABOVE         },
   { OGT_DrawFrame    , TRUE                   },

   { TAG_DONE                                  },
};

struct TagItem Object3_1Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID            , ID_W_DIM       },
   { GA_RelVerify     , TRUE           },

   { GA_Left          , 4              },
   { GA_Top           , 12             },
   { GA_Width         , 80             },
   { GA_Height        , 16             },

   { GA_Text          , "Dim"          },
   { OGT_TextPlacement, OGT_Text_ABOVE },
   { OGTBU_Labels     , Labels4        },
   { OGTBU_ActiveLabel, 0              },

   { TAG_DONE                          },
};

struct TagItem Object3_2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_W_MODE          },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Mode"             },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels3            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};

struct TagItem Object3_3Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID              , ID_W_VALUE         },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Value"            },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },

   { STRINGA_MaxChars   , 32                 },
   { STRINGA_LongVal    , 40                 },
   { GA_TabCycle        , TRUE               },

   { TAG_DONE                                },
};

struct TagItem Object3_4Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_W_POS           },
   { GA_RelVerify       , TRUE               },
   { GA_Disabled        , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 80                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Pos"              },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels1            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};


struct TagItem Object4_0Desc[] = /* GROUP_OGT_CLASS */
{
   { GA_Left          , 2                      },
   { GA_Top           , 138                    },
   { GA_Width         , 394                    },
   { GA_Height        , 30                     },

   { GA_Text          , "Vertical Dimension"   },
   { OGT_TextPlacement, OGT_Text_ABOVE         },
   { OGT_DrawFrame    , TRUE                   },

   { TAG_DONE                                  },
};

struct TagItem Object4_1Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID            , ID_H_DIM       },
   { GA_RelVerify     , TRUE           },

   { GA_Left          , 4              },
   { GA_Top           , 12             },
   { GA_Width         , 80             },
   { GA_Height        , 16             },

   { GA_Text          , "Dim"          },
   { OGT_TextPlacement, OGT_Text_ABOVE },
   { OGTBU_Labels     , Labels4        },
   { OGTBU_ActiveLabel, 0              },

   { TAG_DONE                          },
};

struct TagItem Object4_2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_H_MODE          },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Mode"             },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels3            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};

struct TagItem Object4_3Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID              , ID_H_VALUE         },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 94                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Value"            },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },

   { STRINGA_MaxChars   , 32                 },
   { STRINGA_LongVal    , 12                 },
   { GA_TabCycle        , TRUE               },

   { TAG_DONE                                },
};

struct TagItem Object4_4Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID              , ID_H_POS           },
   { GA_RelVerify       , TRUE               },
   { GA_Disabled        , TRUE               },

   { OGT_SetPosReference, (OGT_X_Mode_Align) },
   { GA_Left            , 8                  },
   { GA_Width           , 80                 },
   { GA_Height          , 16                 },

   { GA_Text            , "Pos"              },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },
   { OGTBU_Labels       , Labels2            },
   { OGTBU_ActiveLabel  , 0                  },

   { TAG_DONE                                },
};


struct TagItem Object5_0Desc[] = /* GROUP_OGT_CLASS */
{
   { GA_Top       , 180  },
   { GA_RelWidth  , -40  },
   { GA_RelHeight , -190 },

   { OGT_DrawFrame, TRUE },

   { TAG_DONE            },
};

struct TagItem Object5_1Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID          , ID_REFERENCE },
   { GA_Immediate   , TRUE         },
   { GA_FollowMouse , TRUE         },

   { OGT_ScaleLeft  , OGT_Fixed    },
   { OGT_ScaleTop   , OGT_Fixed    },
   { GA_Left        , 100          },
   { GA_Top         , 40           },
   { GA_Width       , 80           },
   { GA_Height      , 12           },

   { GA_Text        , "Reference"  },

   { TAG_DONE                      },
};

struct TagItem Object5_2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID     , ID_DEMO     },
   { GA_Left   , 2           },
   { GA_Top    , 1           },
   { GA_Width  , 40          },
   { GA_Height , 12          },

   { GA_Text   , "Demo"      },

   { TAG_DONE                },
};

struct OGT_ObjectSettings ListOfObjects[] =
{
   { Class_Group , Object1_0Desc, NULL , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button, Object1_1Desc, NULL , 0           , OGT_NOOBJECT },
   { Class_Button, Object1_2Desc, NULL , 0           , OGT_NOOBJECT },
   { Class_Button, Object1_3Desc, NULL , 0           , OGT_NOOBJECT },
   { Class_String, Object1_4Desc, NULL , 0           , OGT_NOOBJECT },

   { Class_Group , Object2_0Desc, NULL , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button, Object2_1Desc, NULL , 5           , OGT_NOOBJECT },
   { Class_Button, Object2_2Desc, NULL , 5           , OGT_NOOBJECT },
   { Class_Button, Object2_3Desc, NULL , 5           , OGT_NOOBJECT },
   { Class_String, Object2_4Desc, NULL , 5           , OGT_NOOBJECT },

   { Class_Group , Object3_0Desc, NULL , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button, Object3_1Desc, NULL , 10          , OGT_NOOBJECT },
   { Class_Button, Object3_2Desc, NULL , 10          , OGT_NOOBJECT },
   { Class_String, Object3_3Desc, NULL , 10          , OGT_NOOBJECT },
   { Class_Button, Object3_4Desc, NULL , 10          , OGT_NOOBJECT },

   { Class_Group , Object4_0Desc, NULL , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button, Object4_1Desc, NULL , 15          , OGT_NOOBJECT },
   { Class_Button, Object4_2Desc, NULL , 15          , OGT_NOOBJECT },
   { Class_String, Object4_3Desc, NULL , 15          , OGT_NOOBJECT },
   { Class_Button, Object4_4Desc, NULL , 15          , OGT_NOOBJECT },

   { Class_Group , Object5_0Desc, NULL , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button, Object5_1Desc, NULL , 20          , OGT_NOOBJECT },
   { Class_Button, Object5_2Desc, NULL , 20          , OGT_NOOBJECT },
   { NULL                                                           },
};

struct OGT_ObjectLink ListOfLinks[] =
{
   { OGT_NOOBJECT },
};

static void cleanup           ( char *str );
static void goHandleWindowWait( void      );
static BOOL goHandleWindow    ( void      );


void main( void )
{
   if(!OpenOGT()) cleanup( "no objectivegadtools library\n" );

   if(!(Ra = ReadArgs( ARGS_TEMPLATE, args, NULL ))) cleanup( "can't parse args\n" );

   if(args[ ARGS_FONT ]) MyAttr.ta_Name  =  (void  *)args[ ARGS_FONT ];
   if(args[ ARGS_SIZE ]) MyAttr.ta_YSize = *(ULONG *)args[ ARGS_SIZE ];

   if(MyAttr.ta_Name)
   {
      if(!(MyFont = OpenDiskFont( &MyAttr ))) cleanup( "can't open font!!\n" );
   }

   VInfo = OGT_GetVisualInfo( NULL, OGT_TextFont, (ULONG)MyFont         ,
                                    TAG_MORE    , (ULONG)WindowDescTags );

   if(VInfo == NULL) cleanup( "can't open my window.\n" );

   if(!OGT_BuildObjects( VInfo, ListOfObjects, ListOfLinks, &Gads )) cleanup( "can't create objects" );

   Win = OGT_GetWindowPtr( VInfo );

   goHandleWindowWait();

   cleanup( "all done" );
}

static void cleanup( char *str )
{
   if(str) Printf( "%s\n", str );

   if(Ra    ) FreeArgs          ( Ra     );
   if(Gads  ) FreeVec           ( Gads   );
   if(VInfo ) OGT_FreeVisualInfo( VInfo  );
   if(MyFont) CloseFont         ( MyFont );

   CloseOGT();

   Exit( 0 );
}

static void goHandleWindowWait( void )
{
   BOOL keeprunning = TRUE;

   while(keeprunning)
   {
      Wait( 1L << Win->UserPort->mp_SigBit );

      keeprunning = goHandleWindow();
   }
}

static BOOL goHandleWindow( void )
{
   BOOL                 keeprunning = TRUE;

   struct IntuiMessage *imsg;

   while(keeprunning && (imsg = OGT_GetMsg( VInfo )))
   {
      switch(imsg->Class)
      {
         case IDCMP_CLOSEWINDOW:
            keeprunning = FALSE;
            break;

         case IDCMP_IDCMPUPDATE:
            {
               struct dump_data
               {
                  ULONG pos;
                  ULONG handle;
                  ULONG dim;

                  LONG  left;
                  LONG  top;
                  LONG  width;
                  LONG  height;
               };

               struct TagItem *tags = imsg->IAddress;

               if(GetTagData( OGT_AskedHelp, FALSE, tags ))
               {
                  STRPTR node = NULL;

                  /* Do Help */
                  switch(GetTagData( OGT_ID, -1, tags ))
                  {
                     case ID_X_POS     :
                     case ID_Y_POS     : node = "pos_pos"         ; break;
                     case ID_X_HANDLE  :
                     case ID_Y_HANDLE  : node = "pos_handle"      ; break;
                     case ID_X_MODE    :
                     case ID_Y_MODE    : node = "pos_mode"        ; break;
                     case ID_X_VALUE   :
                     case ID_Y_VALUE   : node = "pos_value"       ; break;

                     case ID_W_DIM     :
                     case ID_H_DIM     : node = "dim_dim"         ; break;
                     case ID_W_MODE    :
                     case ID_H_MODE    : node = "dim_mode"        ; break;
                     case ID_W_VALUE   :
                     case ID_H_VALUE   : node = "dim_value"       ; break;
                     case ID_W_POS     :
                     case ID_H_POS     : node = "dim_dim"         ; break;


                     case ID_REFERENCE : node = "gadget_reference"; break;
                     case ID_DEMO      : node = "gadget_demo"     ; break;
                  }

                  if(node)
                  {
                     char buffer[ 512 ];

                     strcpy( buffer, "AmigaGuide demoPosition.guide doc " );
                     strcat( buffer, node                                 );

                     SystemTags( buffer, TAG_DONE );
                  }
               }
               else
               {
                  ULONG           data1 = GetTagData( OGTBU_ActiveLabel, -1, tags );
                  ULONG           data2 = GetTagData( STRINGA_LongVal  ,  0, tags );

                  struct dump_data new;
                  struct dump_data old;

                  GetAttr( OGT_SetPosReference, Gads[ 22 ], &old.pos    );
                  GetAttr( OGT_SetPosHandle   , Gads[ 22 ], &old.handle );
                  GetAttr( OGT_SetDimReference, Gads[ 22 ], &old.dim    );
                  GetAttr( GA_Left            , Gads[ 22 ], &old.left   );
                  GetAttr( GA_Top             , Gads[ 22 ], &old.top    );
                  GetAttr( GA_Width           , Gads[ 22 ], &old.width  );
                  GetAttr( GA_Height          , Gads[ 22 ], &old.height );

                  new = old;

                  switch( GetTagData( OGT_ID, -1, tags ) )
                  {
                     case ID_X_POS:
                        new.pos &= ~OGT_X_Pos_Mask;

                        switch(data1)
                        {
                           case 0: new.pos |= OGT_X_Left  ; break;
                           case 1: new.pos |= OGT_X_Center; break;
                           case 2: new.pos |= OGT_X_Right ; break;
                        }
                        break;

                     case ID_X_HANDLE:
                        new.handle &= ~OGT_X_Pos_Mask;

                        switch(data1)
                        {
                           case 0: new.handle |= OGT_X_Left  ; break;
                           case 1: new.handle |= OGT_X_Center; break;
                           case 2: new.handle |= OGT_X_Right ; break;
                        }
                        break;

                     case ID_X_MODE:
                        new.pos &= ~OGT_X_Mode_Mask;

                        switch(data1)
                        {
                           case 0: new.pos |= OGT_X_Mode_Free     ; break;
                           case 1: new.pos |= OGT_X_Mode_Align    ; break;
                           case 2: new.pos |= OGT_X_Mode_Center   ; break;
                           case 3: new.pos |= OGT_X_Mode_In_Border; break;
                        }
                        break;

                     case ID_X_VALUE:
                        new.left = data2;
                        break;


                     case ID_Y_POS:
                        new.pos &= ~OGT_Y_Pos_Mask;

                        switch(data1)
                        {
                           case 0: new.pos |= OGT_Y_Top   ; break;
                           case 1: new.pos |= OGT_Y_Center; break;
                           case 2: new.pos |= OGT_Y_Bottom; break;
                        }
                        break;

                     case ID_Y_HANDLE:
                        new.handle &= ~OGT_Y_Pos_Mask;

                        switch(data1)
                        {
                           case 0: new.handle |= OGT_Y_Top   ; break;
                           case 1: new.handle |= OGT_Y_Center; break;
                           case 2: new.handle |= OGT_Y_Bottom; break;
                        }
                        break;

                     case ID_Y_MODE:
                        new.pos &= ~OGT_Y_Mode_Mask;

                        switch(data1)
                        {
                           case 0: new.pos |= OGT_Y_Mode_Free     ; break;
                           case 1: new.pos |= OGT_Y_Mode_Align    ; break;
                           case 2: new.pos |= OGT_Y_Mode_Center   ; break;
                           case 3: new.pos |= OGT_Y_Mode_In_Border; break;
                        }
                        break;

                     case ID_Y_VALUE:
                        new.top  = data2;
                        break;



                     case ID_W_DIM:
                        if(((new.dim & OGT_X_Dim_Mask) == OGT_X_Dim_AsCoord) ^ (data1 == 2))
                        {
                           SetGadgetAttrs( Gads[ 14 ], Win, NULL, GA_Disabled, (ULONG)((data1 == 2) ? FALSE : TRUE),
                                                                  TAG_DONE                                         );
                        }

                        new.dim &= ~OGT_X_Dim_Mask;

                        switch(data1)
                        {
                           case 0: new.dim |= OGT_X_Dim_Fixed   ; break;
                           case 1: new.dim |= OGT_X_Dim_Relative; break;
                           case 2: new.dim |= OGT_X_Dim_AsCoord ; break;
                        }
                        break;

                     case ID_W_MODE:
                        new.dim &= ~OGT_X_Mode_Mask;

                        switch(data1)
                        {
                           case 0: new.dim |= OGT_X_Mode_Free     ; break;
                           case 1: new.dim |= OGT_X_Mode_Align    ; break;
                           case 2: new.dim |= OGT_X_Mode_Center   ; break;
                           case 3: new.dim |= OGT_X_Mode_In_Border; break;
                        }
                        break;

                     case ID_W_VALUE:
                        new.width  = data2;
                        break;

                     case ID_W_POS:
                        new.dim &= ~OGT_X_Pos_Mask;

                        switch(data1)
                        {
                           case 0: new.dim |= OGT_X_Left  ; break;
                           case 1: new.dim |= OGT_X_Center; break;
                           case 2: new.dim |= OGT_X_Right ; break;
                        }
                        break;


                     case ID_H_DIM:
                        if(((new.dim & OGT_Y_Dim_Mask) == OGT_Y_Dim_AsCoord) ^ (data1 == 2))
                        {
                           SetGadgetAttrs( Gads[ 19 ], Win, NULL, GA_Disabled, (ULONG)((data1 == 2) ? FALSE : TRUE),
                                                                  TAG_DONE                                         );
                        }

                        new.dim &= ~OGT_Y_Dim_Mask;

                        switch(data1)
                        {
                           case 0: new.dim |= OGT_Y_Dim_Fixed   ; break;
                           case 1: new.dim |= OGT_Y_Dim_Relative; break;
                           case 2: new.dim |= OGT_Y_Dim_AsCoord ; break;
                        }
                        break;

                     case ID_H_MODE:
                        new.dim &= ~OGT_Y_Mode_Mask;

                        switch(data1)
                        {
                           case 0: new.dim |= OGT_Y_Mode_Free     ; break;
                           case 1: new.dim |= OGT_Y_Mode_Align    ; break;
                           case 2: new.dim |= OGT_Y_Mode_Center   ; break;
                           case 3: new.dim |= OGT_Y_Mode_In_Border; break;
                        }
                        break;

                     case ID_H_VALUE:
                        new.height = data2;
                        break;

                     case ID_H_POS:
                        new.dim &= ~OGT_Y_Pos_Mask;

                        switch(data1)
                        {
                           case 0: new.dim |= OGT_Y_Top   ; break;
                           case 1: new.dim |= OGT_Y_Center; break;
                           case 2: new.dim |= OGT_Y_Bottom; break;
                        }
                        break;

                     case ID_REFERENCE:
                        {
                           static UWORD old_x;
                           static UWORD old_y;

                           UWORD x;
                           UWORD y;

                           {
                              x = imsg->MouseX;
                              y = imsg->MouseY;
                              x = Win->MouseX;
                              y = Win->MouseY;
                           }

                           if(GetTagData( OGT_GadgetDown, FALSE, tags ))
                           {
                              old_x = x;
                              old_y = y;
                           }
                           else if(GetTagData( OGT_GadgetMove, FALSE, tags ))
                           {
                              if(x != old_x || y != old_y)
                              {
                                 ULONG dump;

                                 GetAttr( GA_Left, Gads[ 21 ], &dump ); old_x = dump + x - old_x;
                                 GetAttr( GA_Top , Gads[ 21 ], &dump ); old_y = dump + y - old_y;

                                 SetGadgetAttrs( Gads[ 21 ], Win, NULL, GA_Left , (ULONG)old_x,
                                                                        GA_Top  , (ULONG)old_y,
                                                                        TAG_DONE              );

                                 old_x = x;
                                 old_y = y;
                              }
                           }
                        }
                        break;
                  }

                  if(old != new)
                  {
                     SetGadgetAttrs( Gads[ 22 ], Win, NULL, (old.pos    != new.pos   ) ? OGT_SetPosReference : TAG_IGNORE, (ULONG)new.pos   ,
                                                            (old.handle != new.handle) ? OGT_SetPosHandle    : TAG_IGNORE, (ULONG)new.handle,
                                                            (old.dim    != new.dim   ) ? OGT_SetDimReference : TAG_IGNORE, (ULONG)new.dim   ,
                                                            (old.left   != new.left  ) ? GA_Left             : TAG_IGNORE, (ULONG)new.left  ,
                                                            (old.top    != new.top   ) ? GA_Top              : TAG_IGNORE, (ULONG)new.top   ,
                                                            (old.width  != new.width ) ? GA_Width            : TAG_IGNORE, (ULONG)new.width ,
                                                            (old.height != new.height) ? GA_Height           : TAG_IGNORE, (ULONG)new.height,
                                                                                                               TAG_DONE                     );
                  }
               }
            }

            break;
      }

      OGT_ReplyMsg( imsg );
   }

   return( keeprunning );
}
