/*
** $Filename: demogadget2.c $
** $Release : 1.0           $
** $Revision: 1.274         $
** $Date    : 21/10/92      $
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


static char Class_Group   [] =    GROUP_OGT_CLASS;
static char Class_Button  [] =   BUTTON_OGT_CLASS;
static char Class_Scroller[] = SCROLLER_OGT_CLASS;

struct TextAttr  MyAttr = { "courier.font", 18 };
struct TextFont *MyFont;

APTR                     VInfo;
struct Window           *Win;
Object                 **Gads;
struct RDArgs           *Ra;


struct TagItem WindowDescTags[] =
{
   { OVI_GimmeZeroZero, TRUE                                    },
   { WA_Title         , "DemoGadget2"                           },
   { WA_Activate      , TRUE                                    },
   { WA_SimpleRefresh , TRUE                                    },
   { WA_NoCareRefresh , TRUE                                    },
   { WA_DepthGadget   , TRUE                                    },
   { WA_SizeGadget    , TRUE                                    },
   { WA_SizeBBottom   , TRUE                                    },
   { WA_SizeBRight    , TRUE                                    },
   { WA_DragBar       , TRUE                                    },
   { WA_Left          , 300                                     },
   { WA_Top           , 150                                     },
   { WA_Width         , 280                                     },
   { WA_Height        , 200                                     },
   { WA_MinWidth      , 180                                     },
   { WA_MinHeight     , 70                                      },
   { WA_MaxWidth      , 2000                                    },
   { WA_MaxHeight     , 2000                                    },
   { WA_IDCMP         , (IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE) },
   { WA_CloseGadget   , TRUE                                    },
   { TAG_DONE                                                   },
};


struct TagItem Object1Desc[] = /* GROUP_OGT_CLASS */
{
   { GA_ID          , 1                  },

   { OGT_ScaleTop   , OGT_FontRelative   },
   { OGT_ScaleWidth , OGT_DomainRelative },
   { OGT_ScaleHeight, OGT_DomainRelative },
   { GA_Left        , 2                  },
   { GA_Top         , 12                 },
   { GA_Width       , 50                 },
   { GA_Height      , 25                 },

   { GA_Text        , "Pro_va"           },
   { OGT_DrawFrame  , TRUE               },
   { TAG_DONE                            },
};

struct TagItem Object2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID               , 2                       },
   { GA_Immediate        , TRUE                    },
   { GA_Selected         , TRUE                    },

   { OGT_ScaleWidth      , OGT_DomainRelative      },
   { OGT_ScaleHeight     , OGT_DomainRelative      },
   { OGT_DomainXscale    , 140                     },
   { OGT_DomainYscale    , 50                      },
   { GA_Left             , 4                       },
   { GA_Top              , 2                       },
   { GA_Width            , 26                      },
   { GA_Height           , 11                      },

   { GA_Text             , "_Primo"                },
   { OGT_TextPlacement   , OGT_Text_RIGHT          },
   { OGTBU_VectorImageDef, OGTBU_VectorImage_Check },
   { TAG_DONE                                      },
};

struct TagItem Object3Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID               , 3                                     },
   { GA_Immediate        , TRUE                                  },
   { GA_Selected         , TRUE                                  },

   { OGT_SetPosReference , OGT_Y_Mode_Align                      },
   { OGT_SetDimReference , (OGT_X_Mode_Align | OGT_Y_Mode_Align) },
   { GA_Top              , 2                                     },

   { GA_Text             , "_Secondo"                            },
   { OGT_TextPlacement   , OGT_Text_RIGHT                        },
   { OGTBU_VectorImageDef, OGTBU_VectorImage_Check               },
   { TAG_DONE                                                    },
};

struct TagItem Object4Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID               , 4                                     },
   { GA_Immediate        , TRUE                                  },
   { GA_Selected         , TRUE                                  },

   { OGT_SetPosReference , OGT_Y_Mode_Align                      },
   { OGT_SetDimReference , (OGT_X_Mode_Align | OGT_Y_Mode_Align) },
   { GA_Top              , 2                                     },

   { GA_Text             , "_Terzo"                              },
   { OGT_TextPlacement   , OGT_Text_RIGHT                        },
   { OGTBU_VectorImageDef, OGTBU_VectorImage_Check               },
   { TAG_DONE                                                    },
};

struct TagItem Object5Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_ID              , 5                  },
   { GA_Immediate       , TRUE               },
   { GA_FollowMouse     , TRUE               },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosReference, OGT_Y_Mode_Align   },
   { OGT_SetDimReference, OGT_X_Dim_Relative },
   { OGT_DomainXscale   , 140                },
   { OGT_DomainYscale   , 50                 },
   { GA_Left            , 0                  },
   { GA_Top             , 2                  },
   { GA_Width           , -12                },
   { GA_Height          , 9                  },

   { GA_Text            , "_Quarto"          },
   { OGT_TextPlacement  , OGT_Text_RIGHT     },

   { PGA_Freedom        , FREEHORIZ          },
   { PGA_NewLook        , TRUE               },
   { PGA_Top            , 10                 },
   { PGA_Visible        , 10                 },
   { PGA_Total          , 100                },
   { TAG_DONE                                },
};


struct TagItem Obj6toObj2[] =
{
   { PGA_Top,  GA_Left },
   { TAG_DONE          },
};

struct TagItem Object6Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_ID              , 6                  },
   { GA_Immediate       , TRUE               },
   { GA_FollowMouse     , TRUE               },
   { GA_RelVerify       , TRUE               },

   { OGT_SetPosHandle   , OGT_Y_Bottom       },
   { OGT_SetDimReference, OGT_X_Dim_Relative },
   { GA_Left            , 0                  },
   { GA_RelBottom       , 0                  },
   { GA_Height          , 9                  },

   { GA_Text            , "_Muove"           },
   { OGT_TextPlacement  , OGT_Text_ABOVE     },

   { PGA_Freedom        , FREEHORIZ          },
   { PGA_Top            , 10                 },
   { PGA_Visible        , 10                 },
   { PGA_Total          , 100                },
   { TAG_DONE                                },
};

struct OGT_ObjectSettings ListOfObjects[] =
{
   { Class_Group   , Object1Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button  , Object2Desc, NULL, 0           , OGT_NOOBJECT },
   { Class_Button  , Object3Desc, NULL, 0           , OGT_NOOBJECT },
   { Class_Button  , Object4Desc, NULL, 0           , OGT_NOOBJECT },
   { Class_Scroller, Object5Desc, NULL, 0           , OGT_NOOBJECT },
   { Class_Scroller, Object6Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { NULL                                                          },
};

struct OGT_ObjectLink ListOfLinks[] =
{
   { 5           , 1, Obj6toObj2 },
   { OGT_NOOBJECT                },
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

   while(1)
   {
      VInfo = OGT_GetVisualInfo( NULL, OGT_TextFont, (ULONG)MyFont         ,
                                       TAG_MORE    , (ULONG)WindowDescTags );

      if(VInfo == NULL) cleanup( "can't open my window.\n" );

      if(!OGT_BuildObjects( VInfo, ListOfObjects, ListOfLinks, &Gads )) cleanup( "can't create objects" );

      Win = OGT_GetWindowPtr( VInfo );

      goHandleWindowWait();

      DisposeObject( Gads[ 4 ] ); Gads[ 4 ] = NULL;

      goHandleWindowWait();

      DisposeObject( Gads[ 2 ] ); Gads[ 2 ] = NULL;

      goHandleWindowWait();


      break;
   }

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
      }

      OGT_ReplyMsg( imsg );
   }

   return( keeprunning );
}
