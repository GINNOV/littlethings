/*
** $Filename: demogadget1.c $
** $Release : 1.0           $
** $Revision: 1.319         $
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

static char Class_ListView[] = LISTVIEW_OGT_CLASS;

struct TextAttr  MyAttr = { "courier.font", 18 };
struct TextFont *MyFont;
struct MsgPort  *MyPort;

APTR                     VInfo[ 2 ];
struct Window           *Win  [ 2 ];
Object                 **Gads [ 2 ];
struct RDArgs           *Ra;


struct TagItem WindowDescTags[] =
{
   { OVI_GimmeZeroZero    , TRUE                                    },
   { OVI_AdaptWidthToFont , TRUE                                    },
   { OVI_AdaptHeightToFont, TRUE                                    },
   { OGT_ScaleLeft        , OGT_DomainRelative                      },
   { OGT_ScaleTop         , OGT_DomainRelative                      },
   { OGT_ScaleWidth       , OGT_DomainRelative                      },
   { OGT_ScaleHeight      , OGT_DomainRelative                      },
   { OGT_DomainXscale     , ~0                                      },
   { OGT_DomainYscale     , ~0                                      },
   { WA_Activate          , TRUE                                    },
   { WA_SmartRefresh      , TRUE                                    },
   { WA_NoCareRefresh     , TRUE                                    },
   { WA_DepthGadget       , TRUE                                    },
   { WA_SizeGadget        , TRUE                                    },
   { WA_SizeBBottom       , TRUE                                    },
   { WA_SizeBRight        , TRUE                                    },
   { WA_DragBar           , TRUE                                    },
   { WA_Left              , 300                                     },
   { WA_Top               , 150                                     },
   { WA_Width             , 280                                     },
   { WA_Height            , 200                                     },
   { WA_MaxWidth          , ~0                                      },
   { WA_MaxHeight         , ~0                                      },
   { WA_IDCMP             , (IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE) },
   { WA_CloseGadget       , TRUE                                    },
   { TAG_DONE                                                       },
};

STRPTR Object1Labels[] =
{
   "OVI_GimmeZeroZero, (void *)TRUE",
   "WA_Title         , (void *)DemoGadget1",
   "WA_Activate      , (void *)TRUE",
   "WA_SimpleRefresh , (void *)TRUE",
   "WA_NoCareRefresh , (void *)TRUE",
   "WA_DepthGadget   , (void *)TRUE",
   "WA_SizeGadget    , (void *)TRUE",
   "WA_SizeBBottom   , (void *)TRUE",
   "WA_SizeBRight    , (void *)TRUE",
   "WA_DragBar       , (void *)TRUE",
   "WA_Left          , (void *)300",
   "WA_Top           , (void *)150",
   "WA_Width         , (void *)280",
   "WA_Height        , (void *)200",
   "WA_MinWidth      , (void *)180",
   "WA_MinHeight     , (void *)70",
   "WA_MaxWidth      , (void *)2000",
   "WA_MaxHeight     , (void *)2000",
   "WA_IDCMP         , (void *)(IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE)",
   "WA_CloseGadget   , (void *)TRUE",
   NULL
};

struct TagItem Object1Desc[] = /* LISTVIEW_OGT_CLASS */
{
   { GA_ID             , 1                },

   { OGT_ScaleWidth    , OGT_FontRelative },
   { OGT_ScaleHeight   , OGT_FontRelative },
   { GA_Left           , 2                },
   { GA_Top            , 12               },
   { OGT_Right         , 136              },
   { OGT_Bottom        , 80               },

   { GA_Text           , "_Primo"         },
   { OGT_DrawFrame     , TRUE             },

   { OGTLV_Labels      , Object1Labels    },
   { OGTLV_ActiveLabel , 2                },
   { OGTLV_ReadOnly    , TRUE             },
   { OGTLV_ToggleSelect, TRUE             },

   { TAG_DONE                             },
};

struct TagItem Object2Desc[] = /* LISTVIEW_OGT_CLASS */
{
   { GA_ID             , 2                  },

   { GA_Left           , 142                },
   { GA_Top            , 12                 },
   { GA_Width          , 136                },
   { GA_Height         , 80                 },

   { GA_Text           , "_Secondo"         },
   { OGT_DrawFrame     , TRUE               },

   { OGTLV_Labels      , Object1Labels      },
   { OGTLV_ActiveLabel , 2                  },
   { OGTLV_ShowSelected, TRUE               },
   { TAG_DONE                               },
};

struct TagItem Object3Desc[] = /* LISTVIEW_OGT_CLASS */
{
   { GA_ID             , 3                  },

   { GA_Left           , 2                  },
   { GA_Top            , 108                },
   { GA_Width          , 136                },
   { GA_Height         , 80                 },

   { GA_Text           , "_Terzo"           },
   { OGT_DrawFrame     , TRUE               },

   { OGTLV_Labels      , Object1Labels      },
   { OGTLV_ActiveLabel , 2                  },
   { TAG_DONE                               },
};

struct OGT_ObjectSettings ListOfObjects[] =
{
   { Class_ListView, Object1Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_ListView, Object2Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_ListView, Object3Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { NULL                                                          },
};

struct OGT_ObjectLink ListOfLinks[] =
{
   { OGT_NOOBJECT                }
};

static void cleanup           ( char *str );
static void goHandleWindowWait( void      );
static BOOL goHandleWindow    ( int   num );

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

   if(!(MyPort = CreateMsgPort())) cleanup( "can't open my port!!\n" );

   while(1)
   {
      VInfo[ 0 ] = OGT_GetVisualInfo( MyPort, OGT_TextFont, (ULONG)MyFont         ,
                                              WA_Title    , (ULONG)"DemoGadget1/1",
                                              TAG_MORE    , (ULONG)WindowDescTags );

      if(VInfo[ 0 ] == NULL) cleanup( "can't open window 1.\n" );

      if(!OGT_BuildObjects( VInfo[ 0 ], ListOfObjects, ListOfLinks, &Gads[ 0 ] )) cleanup( "can't create objects for window 1" );

      Win[ 0 ] = OGT_GetWindowPtr( VInfo[ 0 ] );

      VInfo[ 1 ] = OGT_GetVisualInfo( MyPort, OGT_TextFont, (ULONG)MyFont         ,
                                              WA_Title    , (ULONG)"DemoGadget1/2",
                                              WA_Left     , (ULONG)0              ,
                                              TAG_MORE    , (ULONG)WindowDescTags );

      if(VInfo[ 1 ] == NULL) cleanup( "can't open window 2.\n" );

      if(!OGT_BuildObjects( VInfo[ 1 ], ListOfObjects, ListOfLinks, &Gads[ 1 ] )) cleanup( "can't create objects for window 2" );

      Win[ 1 ] = OGT_GetWindowPtr( VInfo[ 1 ] );

      goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ][ 0 ], Win[ 0 ], NULL, OGTLV_LockList        , (ULONG)TRUE         ,
                                                      OGTLV_WorkLabelPos    , (ULONG)5            ,
                                                      OGTLV_InsertLabelAfter, (ULONG)"Prova AFTER",
                                                      OGTLV_LockList        , (ULONG)FALSE        ,
                                                      TAG_DONE                                    ); goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ][ 0 ], Win[ 0 ], NULL, OGTLV_LockList         , (ULONG)TRUE          ,
                                                      OGTLV_WorkLabelPos     , (ULONG)5             ,
                                                      OGTLV_InsertLabelBefore, (ULONG)"Prova BEFORE",
                                                      OGTLV_LockList         , (ULONG)FALSE         ,
                                                      TAG_DONE                                     ); goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ][ 0 ], Win[ 0 ], NULL, OGTLV_LockList         , (ULONG)TRUE          ,
                                                      OGTLV_WorkLabelPos     , (ULONG)6             ,
                                                      OGTLV_DeleteLabel      , (ULONG)0             ,
                                                      OGTLV_LockList         , (ULONG)FALSE         ,
                                                      TAG_DONE                                     ); goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ][ 0 ], Win[ 0 ], NULL, OGTLV_ActiveLabel, (ULONG)3    , TAG_DONE ); goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ][ 0 ], Win[ 0 ], NULL, GA_Disabled      , (ULONG)TRUE , TAG_DONE );
      SetGadgetAttrs( Gads[ 0 ][ 1 ], Win[ 0 ], NULL, GA_Disabled      , (ULONG)TRUE , TAG_DONE ); goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ][ 0 ], Win[ 0 ], NULL, GA_Disabled      , (ULONG)FALSE, TAG_DONE );
      SetGadgetAttrs( Gads[ 0 ][ 1 ], Win[ 0 ], NULL, GA_Disabled      , (ULONG)FALSE, TAG_DONE ); goHandleWindowWait();

      break;
   }

   cleanup( "all done" );
}

static void cleanup( char *str )
{
   if(str) Printf( "%s\n", str );

   if(Gads [ 0 ]) FreeVec           ( Gads [ 0 ] );
   if(Gads [ 1 ]) FreeVec           ( Gads [ 1 ] );
   if(VInfo[ 0 ]) OGT_FreeVisualInfo( VInfo[ 0 ] );
   if(VInfo[ 1 ]) OGT_FreeVisualInfo( VInfo[ 1 ] );

   if(Ra    ) FreeArgs     ( Ra     );
   if(MyFont) CloseFont    ( MyFont );
   if(MyPort) DeleteMsgPort( MyPort );

   CloseOGT();

   Exit( 0 );
}

static void goHandleWindowWait( void )
{
   BOOL  keeprunning = TRUE;
   ULONG mask        = 0;

   if(Win[ 0 ]) mask |= 1L << Win[ 0 ]->UserPort->mp_SigBit;
   if(Win[ 1 ]) mask |= 1L << Win[ 1 ]->UserPort->mp_SigBit;

   while(mask && keeprunning)
   {
      Wait( mask );

      keeprunning = goHandleWindow( 0 ) & goHandleWindow( 1 );
   }
}

static BOOL goHandleWindow( int num )
{
   BOOL                 keeprunning = TRUE;

   struct IntuiMessage *imsg;

   while(keeprunning && (imsg = OGT_GetMsg( VInfo[ num ] )))
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
