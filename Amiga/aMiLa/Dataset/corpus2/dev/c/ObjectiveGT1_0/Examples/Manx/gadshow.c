/*
** $Filename: gadshow.c $
** $Release : 1.0       $
** $Revision: 1.281     $
** $Date    : 21/10/92  $
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

#define ARGS_TEMPLATE "FONT/K,SIZE/N,USESCREEN/S"
#define ARGS_FONT       (0)
#define ARGS_SIZE       (1)
#define ARGS_USESCREEN  (2)
#define ARGS_NUMOF      (3)

static LONG args[ ARGS_NUMOF ];


static char Class_MultiWay[] = MULTIWAY_OGT_CLASS;
static char Class_String  [] =   STRING_OGT_CLASS;
static char Class_AslReq  [] =   ASLREQ_OGT_CLASS;
static char Class_Button  [] =   BUTTON_OGT_CLASS;
static char Class_ShowText[] = SHOWTEXT_OGT_CLASS;
static char Class_Menu    [] =     MENU_OGT_CLASS;


struct TextAttr  MyAttr = { NULL, 8 };
struct TextFont *MyFont;

struct Screen           *Scr;
APTR                     VInfo;
struct Window           *Win;
Object                 **Gads;
struct RDArgs           *Ra;
struct Hook              StringHook;


struct TagItem WindowDescTags[] =
{
   { OVI_GimmeZeroZero    , TRUE                                                     },
   { OVI_AdaptWidthToFont , TRUE                                                     },
   { OVI_AdaptHeightToFont, TRUE                                                     },

   { OGT_ScaleLeft        , OGT_DomainRelative                                       },
   { OGT_ScaleTop         , OGT_DomainRelative                                       },
   { OGT_ScaleWidth       , OGT_DomainRelative                                       },
   { OGT_ScaleHeight      , OGT_DomainRelative                                       },
   { OGT_DomainXscale     , ~0                                                       },
   { OGT_DomainYscale     , ~0                                                       },

   { WA_Activate          , TRUE                                                     },
   { WA_SimpleRefresh     , TRUE                                                     },
   { WA_NoCareRefresh     , TRUE                                                     },
   { WA_DepthGadget       , TRUE                                                     },
   { WA_SizeGadget        , TRUE                                                     },
   { WA_SizeBBottom       , TRUE                                                     },
   { WA_SizeBRight        , TRUE                                                     },
   { WA_DragBar           , TRUE                                                     },
   { WA_Left              , 400                                                      },
   { WA_Top               , 150                                                      },
   { WA_InnerWidth        , 306                                                      },
   { WA_InnerHeight       , 120                                                      },
   { WA_MaxWidth          , -1                                                       },
   { WA_MaxHeight         , -1                                                       },
   { WA_IDCMP             , IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE | IDCMP_VANILLAKEY },
   { WA_CloseGadget       , TRUE                                                     },
   { WA_MenuHelp          , TRUE                                                     },
   { WA_Title             , "GadShow2"                                               },

   { TAG_DONE                                                                        },
};


STRPTR Object1Labels[] =
{
   "Prova_1",
   "Prova_2",
   "Pe_nultimo",
   "_Ultimo",
   NULL
};

struct TagItem Object1Desc[] = /* MULTIWAY_OGT_CLASS */
{
   { GA_ID            , 1                },
   { GA_Disabled      , TRUE             },

   { OGT_ScaleLeft    , OGT_FontRelative },
   { OGT_ScaleTop     , OGT_FontRelative },
   { OGT_ScaleWidth   , OGT_FontRelative },
   { OGT_ScaleHeight  , OGT_FontRelative },
   { GA_Left          , 80               },
   { GA_Top           , 12               },

   { GA_Text          , "Prova"          },
   { OGT_TextPlacement, OGT_Text_LEFT    },

   { OGTMW_Labels     , Object1Labels    },
   { OGTMW_ActiveLabel, 1                },

   { TAG_DONE                            },
};

struct TagItem Object2Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID            , 2                           },
   { GA_RelVerify     , TRUE                        },

   { OGT_SetPosHandle , (OGT_X_Left | OGT_Y_Bottom) },
   { GA_Left          , 2                           },
   { GA_RelBottom     , -1                          },
   { GA_Width         , 70                          },
   { GA_Height        , 12                          },

   { GA_Text          , "Ri_tmo"                    },
   { OGT_TextPlacement, OGT_Text_RIGHT              },

   { STRINGA_MaxChars , 16                          },
   { STRINGA_TextVal  , "primo"                     },
   { STRINGA_ExitHelp , TRUE                        },
   { STRINGA_EditHook , &StringHook                 },
   { GA_TabCycle      , TRUE                        },

   { TAG_DONE                                       },
};

struct TagItem Object3Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID           , 3                            },
   { GA_RelVerify    , TRUE                         },
   { OGT_AppGadget   , TRUE                         },

   { OGT_SetPosHandle, (OGT_X_Right | OGT_Y_Bottom) },
   { GA_RelRight     , -1                           },
   { GA_RelBottom    , -1                           },
   { GA_Width        , 70                           },
   { GA_Height       , 12                           },

   { GA_Text         , "Ch_ip"                      },

   { STRINGA_MaxChars, 16                           },
   { STRINGA_TextVal , "secondo"                    },
   { STRINGA_ExitHelp, TRUE                         },
   { GA_TabCycle     , TRUE                         },

   { TAG_DONE                                       },
};

struct TagItem Object4Desc[] = /* ASLREQ_OGT_CLASS */
{
   { GA_ID             , 4               },
   { GA_RelVerify      , TRUE            },

   { OGT_SetPosHandle  , OGT_X_Right     },
   { GA_RelRight       , -1              },
   { GA_Top            , 1               },
   { GA_Width          , 132             },
   { GA_Height         , 14              },

   { GA_Text           , "Fon_t"         },
   { OGT_TextPlacement , OGT_Text_LEFT   },

   { OGTAR_Type        , ASL_FontRequest },
   { OGTAR_ShowSelected, TRUE            },

   { TAG_DONE                            },
};

struct TagItem Object5Desc[] = /* ASLREQ_OGT_CLASS */
{
   { GA_ID             , 5               },
   { GA_RelVerify      , TRUE            },

   { OGT_SetPosHandle  , OGT_X_Right     },
   { GA_RelRight       , -1              },
   { GA_Top            , 17              },
   { GA_Width          , 132             },
   { GA_Height         , 14              },

   { GA_Text           , "_File"         },
   { OGT_TextPlacement , OGT_Text_LEFT   },

   { OGTAR_Type        , ASL_FileRequest },
   { OGTAR_ShowSelected, TRUE            },

   { TAG_DONE                            },
};

struct TagItem Object6Desc[] = /* ASLREQ_OGT_CLASS */
{
   { GA_ID             , 6                },
   { GA_RelVerify      , TRUE             },

   { OGT_SetPosHandle  , OGT_X_Right      },
   { GA_RelRight       , -1               },
   { GA_Top            , 33               },
   { GA_Width          , 132              },
   { GA_Height         , 14               },

   { GA_Text           , "_Dir"           },
   { OGT_TextPlacement , OGT_Text_LEFT    },

   { OGTAR_Type        , ASL_FileRequest  },
   { ASL_FuncFlags     , FILF_MULTISELECT },

   { TAG_DONE                             },
};

struct TagItem Object7Desc[] = /* SHOWTEXT_OGT_CLASS */
{
   { GA_ID             , 7                                            },

   { OGT_SetPosHandle  , OGT_X_Right                                  },
   { GA_RelRight       , -1                                           },
   { GA_Top            , 49                                           },
   { GA_Width          , 132                                          },
   { GA_Height         , 25                                           },

   { GA_Text           , "Text"                                       },
   { OGT_TextPlacement , OGT_Text_LEFT                                },
   { OGT_DrawFrame     , TRUE                                         },

   { OGTST_Format      , "\001\002Prova\n\002Di\n\003Piu'\n\004Righe" },

   { TAG_DONE                                                         },
};

struct TagItem Object8Desc[] = /* MENU_OGT_CLASS */
{
   { OGTMN_Menu         , "Primo"               },
   { OGTMN_Item         , "Primo Primo"         },
   { OGTMN_ShortCut     , 'P'                   },
   { OGTMN_Item         , "Primo Secondo"       },
   { GA_Selected        , TRUE                  },
   { OGTMN_BarLabel                             },
   { OGTMN_Item         , "Primo Terzo"         },
   { OGTMN_ShortCut     , 'T'                   },
   { OGTMN_SubItem      , "Primo Terzo Primo"   },
   { OGTMN_MutualExclude, ~1                    },
   { GA_Selected        , TRUE                  },
   { OGTMN_SubItem      , "Primo Terzo Secondo" },
   { OGTMN_MutualExclude, ~2                    },
   { GA_Selected        , FALSE                 },
   { OGTMN_Menu         , "Secondo"             },
   { OGTMN_Item         , "Secondo Primo"       },
   { OGTMN_Menu         , "Terzo"               },
   { OGTMN_Item         , "Terzo Primo"         },

   { TAG_DONE                                   },
};


struct OGT_ObjectSettings ListOfObjects[] =
{
   { Class_MultiWay, Object1Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_String  , Object2Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_String  , Object3Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_AslReq  , Object4Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_AslReq  , Object5Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_AslReq  , Object6Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_ShowText, Object7Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Menu    , Object8Desc, NULL, OGT_NOOBJECT, OGT_NOOBJECT },
   { NULL                                                          },
};

struct OGT_ObjectLink ListOfLinks[] =
{
   { OGT_NOOBJECT },
};

static void cleanup           ( char *str );
static void goHandleWindowWait( void      );
static BOOL goHandleWindow    ( void      );

static ULONG StringEdit( struct Hook   *hook ,
                         struct SGWork *sgw  ,
                         ULONG         *msg  )
{
   ULONG  ret_val = ~0;

   switch( *msg )
   {
      case SGH_KEY:
         switch( sgw->EditOp )
         {
            case EO_REPLACECHAR:
            case EO_INSERTCHAR :
               if(!isxdigit( sgw->Code ))
               {
                  sgw->Actions |=  SGA_BEEP;
                  sgw->Actions &= ~SGA_USE;
               }
               else
               {
                  sgw->WorkBuffer[ sgw->BufferPos - 1 ] = ToUpper( sgw->Code );
               }
               break;
         }
         break;

      case SGH_CLICK:
         if(sgw->BufferPos < sgw->NumChars)
         {
            sgw->WorkBuffer[ sgw->BufferPos ] = '0';
         }
         break;

      default:
         ret_val = 0;
         break;
   }

   return( ret_val );
}

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

   StringHook.h_Entry    = hookEntry;
   StringHook.h_SubEntry = StringEdit;

   while(1)
   {
      if(args[ ARGS_USESCREEN ])
      {
         static UWORD pens[] = { ~0 };

         Scr = OpenScreenTags( NULL, SA_Width    , (ULONG)STDSCREENWIDTH ,
                                     SA_Height   , (ULONG)STDSCREENHEIGHT,
                                     SA_Depth    , (ULONG)2              ,
                                     SA_Pens     , (ULONG)pens           ,
                                     SA_Type     , (ULONG)CUSTOMSCREEN   ,
                                     SA_DisplayID, (ULONG)HIRESLACE_KEY  ,
                                     SA_SysFont  , (ULONG)1              ,
                                     TAG_DONE                            );

         if(Scr == NULL) cleanup( "can't open my screen.\n" );
      }


      VInfo = OGT_GetVisualInfo( NULL,       OGT_TextFont                , (ULONG)MyFont         ,
                                       Scr ? WA_CustomScreen : TAG_IGNORE, (ULONG)Scr            ,
                                                               TAG_MORE  , (ULONG)WindowDescTags );

      if(VInfo == NULL) cleanup( "can't open my window.\n" );

      if(!OGT_BuildObjects( VInfo, ListOfObjects, ListOfLinks, &Gads )) cleanup( "can't create objects" );

      Win = OGT_GetWindowPtr( VInfo );

      goHandleWindowWait();

      SetGadgetAttrs( Gads[ 7 ], Win, NULL, OGTMN_Menu   , (ULONG)"Secondo"      ,
                                            OGTMN_Item   , (ULONG)"Secondo Primo",
                                            OGTMN_NewName, (ULONG)"Second"       ,
                                            TAG_DONE                             );

      DisposeObject( Gads[ 0 ] ); Gads[ 0 ] = NULL;

      goHandleWindowWait();

      Gads[ 0 ] = (APTR)NewObject( NULL, Class_MultiWay, OGT_VisualInfo, (ULONG)VInfo       ,
                                                         TAG_MORE      , (ULONG)Object1Desc );

      OGT_RefreshWindow( VInfo );

      goHandleWindowWait();

      SetGadgetAttrs( Gads[ 0 ], Win, NULL, OGTMW_ActiveLabel, (ULONG)3,
                                            TAG_DONE                   );

      SetGadgetAttrs( Gads[ 7 ], Win, NULL, OGTMN_Menu      , (ULONG)"Secondo"       ,
                                            OGTMN_ClearMenus, (ULONG)TRUE            ,
                                            OGTMN_Menu      , (ULONG)"Terzo"         ,
                                            OGTMN_ClearMenus, (ULONG)FALSE           ,
                                            OGTMN_Menu      , (ULONG)"Quarto"        ,
                                            OGTMN_Item      , (ULONG)"Quarto Primo"  ,
                                            OGTMN_Item      , (ULONG)"Quarto Secondo",
                                            GA_Disabled     , (ULONG)TRUE            ,
                                            TAG_DONE                                 );

      goHandleWindowWait();

      {
         int i;

         for(i = 0;i < 8;i++) SetGadgetAttrs( Gads[ i ], Win, NULL, GA_Disabled, (ULONG)TRUE, TAG_DONE );

         goHandleWindowWait();
      }

      {
         int i;

         for(i = 0;i < 8;i++) SetGadgetAttrs( Gads[ i ], Win, NULL, GA_Disabled, (ULONG)FALSE, TAG_DONE );

         goHandleWindowWait();
      }

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
   if(Scr   ) CloseScreen       ( Scr    );
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

         case IDCMP_VANILLAKEY:
            Printf( "Vanilla Key: %04x %04x\n", imsg->Code, imsg->Qualifier );
            break;
      }

      OGT_ReplyMsg( imsg );
   }

   return( keeprunning );
}
