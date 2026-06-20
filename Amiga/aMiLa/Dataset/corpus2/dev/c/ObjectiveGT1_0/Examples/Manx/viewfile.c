/*
** $Filename: viewfile.c $
** $Release : 1.0        $
** $Revision: 1.280      $
** $Date    : 21/10/92   $
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

#define ARGS_TEMPLATE "FILE/K,FONT/K,SIZE/N"
#define ARGS_FILE       (0)
#define ARGS_FONT       (1)
#define ARGS_SIZE       (2)
#define ARGS_NUMOF      (3)

static LONG args[ ARGS_NUMOF ];

#define GADGETID_SHOWLIST  (1)

static char Class_AslReq  [] =   ASLREQ_OGT_CLASS;
static char Class_Scroller[] = SCROLLER_OGT_CLASS;
static char Class_Showlist[] = SHOWLIST_OGT_CLASS;

struct TextAttr   MyAttr = { NULL, 8 };
struct TextFont  *MyFont;

APTR              VInfo;
struct Window    *Win;
Object          **Gads;
struct RDArgs    *Ra;

struct IBox zoom = { 0, 0, 80, 30 };

struct TagItem WindowDescTags[] =
{
   { OVI_GimmeZeroZero    , TRUE                                  },
   { OVI_AdaptWidthToFont , TRUE                                  },
   { OVI_AdaptHeightToFont, TRUE                                  },
   { OGT_ScaleLeft        , OGT_FontRelative                      },
   { OGT_ScaleTop         , OGT_FontRelative                      },
   { OGT_ScaleWidth       , OGT_FontRelative                      },
   { OGT_ScaleHeight      , OGT_FontRelative                      },
   { OGT_DomainXscale     , ~0                                    },
   { OGT_DomainYscale     , ~0                                    },
   { WA_Title             , "ViewFile"                            },
   { WA_Activate          , TRUE                                  },
   { WA_SmartRefresh      , TRUE                                  },
   { WA_NoCareRefresh     , TRUE                                  },
   { WA_DepthGadget       , TRUE                                  },
   { WA_SizeGadget        , TRUE                                  },
   { WA_SizeBBottom       , TRUE                                  },
   { WA_SizeBRight        , TRUE                                  },
   { WA_DragBar           , TRUE                                  },
   { WA_Left              , 400                                   },
   { WA_Top               , 150                                   },
   { WA_InnerWidth        , 306                                   },
   { WA_InnerHeight       , 120                                   },
   { WA_MinWidth          , 80                                    },
   { WA_MinHeight         , 20                                    },
   { WA_MaxWidth          , 306                                   },
   { WA_MaxHeight         , 140                                   },
   { WA_Zoom              , &zoom                                 },
   { WA_IDCMP             , IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE },
   { WA_CloseGadget       , TRUE                                  },
   { TAG_DONE                                                     }
};


struct TagItem Object1Desc[] = /* ASLREQ_OGT_CLASS */
{
   { OGT_SetDimReference, OGT_X_Dim_Relative },
   { OGT_SetPosHandle   , OGT_Y_Bottom       },
   { GA_RelBottom       , 0                  },
   { GA_Height          , 14                 },

   { GA_Text            , "_F"               },
   { OGT_TextPlacement  , OGT_Text_HIDE      },

   { OGTAR_Type         , ASL_FileRequest    },
   { OGTAR_ShowSelected , TRUE               },
   { TAG_DONE                                }
};

struct TagItem Object1Post[] =
{
   { OGTAR_FullFileName },
   { TAG_DONE           }
};


struct TagItem Object2Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_Immediate       , TRUE                                    },
   { GA_FollowMouse     , TRUE                                    },
   { GA_RelVerify       , TRUE                                    },
   { ICA_TARGET         , NULL                                    },

   { OGT_SetDimReference, OGT_X_Dim_Relative | OGT_Y_Dim_Relative },
   { GA_RightBorder     , TRUE                                    },

   { PGA_Freedom        , FREEVERT                                },
   { TAG_DONE                                                     }
};


struct TagItem Object3Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_Immediate       , TRUE                                    },
   { GA_FollowMouse     , TRUE                                    },
   { GA_RelVerify       , TRUE                                    },
   { ICA_TARGET         , NULL                                    },

   { OGT_SetDimReference, OGT_X_Dim_Relative | OGT_Y_Dim_Relative },
   { GA_BottomBorder    , TRUE                                    },

   { PGA_Freedom        , FREEHORIZ                               },
   { TAG_DONE                                                     }
};


struct TagItem Object4Desc[] = /* SHOWLIST_OGT_CLASS */
{
   { GA_ID              , GADGETID_SHOWLIST                     },
   { OGT_AppGadget      , TRUE                                  },
   { GA_Immediate       , TRUE                                  },
   { GA_FollowMouse     , TRUE                                  },
   { GA_RelVerify       , TRUE                                  },

   { OGT_SetDimReference, OGT_X_Dim_Relative|OGT_Y_Dim_Relative },
   { GA_Height          , -14                                   },

   { OGTSL_UseNumPad    , TRUE                                  },
   { TAG_DONE                                                   }
};

struct OGT_ObjectSettings ListOfObjects[] =
{
   { Class_AslReq  , Object1Desc, Object1Post, OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Scroller, Object2Desc, NULL       , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Scroller, Object3Desc, NULL       , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Showlist, Object4Desc, NULL       , OGT_NOOBJECT, OGT_NOOBJECT },
   { NULL                                                                 },
};



struct TagItem Obj2toObj4[] =    /* SCROLLER_OGT_CLASS to SHOWLIST_OGT_CLASS */
{
   { PGA_Top , OGTSL_VertPos },
   { TAG_DONE                }
};


struct TagItem Obj3toObj4[] =    /* SCROLLER_OGT_CLASS to SHOWLIST_OGT_CLASS */
{
   { PGA_Top , OGTSL_HoriPos },
   { TAG_DONE                }
};


struct TagItem Obj4toObj2[] =    /* SHOWLIST_OGT_CLASS to SCROLLER_OGT_CLASS */
{
   { OGTSL_VertPos    , PGA_Top     },
   { OGTSL_VertTotal  , PGA_Total   },
   { OGTSL_VertVisible, PGA_Visible },
   { TAG_DONE                       }
};

Tag Obj4toObj2Filter[] =
{
   OGTSL_VertPos    ,
   OGTSL_VertTotal  ,
   OGTSL_VertVisible,
   TAG_DONE
};


struct TagItem Obj4toObj3[] =    /* SHOWLIST_OGT_CLASS to SCROLLER_OGT_CLASS */
{
   { OGTSL_HoriPos    , PGA_Top     },
   { OGTSL_HoriTotal  , PGA_Total   },
   { OGTSL_HoriVisible, PGA_Visible },
   { TAG_DONE                       }
};

Tag Obj4toObj3Filter[] =
{
   OGTSL_HoriPos    ,
   OGTSL_HoriTotal  ,
   OGTSL_HoriVisible,
   TAG_DONE
};


struct TagItem Obj1toObj4[] =    /* ASLREQ_OGT_CLASS to SHOWLIST_OGT_CLASS */
{
   { OGTAR_FullFileName, OGTSL_FileToLoadByName },
   { TAG_DONE                                   }
};

Tag Obj1toObj4Filter[] =
{
   OGTAR_FullFileName,
   TAG_DONE
};


struct OGT_ObjectLink ListOfLinks[] =
{
   { 3           , 1, Obj4toObj2, Obj4toObj2Filter },
   { 3           , 2, Obj4toObj3, Obj4toObj3Filter },
   { 1           , 3, Obj2toObj4                   },
   { 2           , 3, Obj3toObj4                   },

   { 0           , 3, Obj1toObj4, Obj1toObj4Filter },

   { OGT_NOOBJECT                                  },
};


static int cleanup( char *str );

int main( void )
{
   if(!OpenOGT()) cleanup( "no objectivegadtools.library!\n" );

   if(!(Ra = ReadArgs( ARGS_TEMPLATE, args, NULL ))) return( cleanup( "Can't parse args\n" ) );

   if(args[ ARGS_FONT ]) MyAttr.ta_Name  =  (STRPTR )args[ ARGS_FONT ];
   if(args[ ARGS_SIZE ]) MyAttr.ta_YSize = *(ULONG *)args[ ARGS_SIZE ];

   if(MyAttr.ta_Name)
   {
      if(!(MyFont = OpenDiskFont( &MyAttr ))) return( cleanup( "Can't open font!!\n" ) );
   }

   while(1)
   {
      VInfo = OGT_GetVisualInfo( NULL, OGT_TextFont, (ULONG)MyFont         ,
                                       TAG_MORE    , (ULONG)WindowDescTags );

      if(VInfo == NULL) return( cleanup( "Can't open my window.\n" ) );

      Object1Post[ 0 ].ti_Data = args[ ARGS_FILE ];

      if(!OGT_BuildObjects( VInfo, ListOfObjects, ListOfLinks, &Gads )) return( cleanup( "can't create objects" ) );

      Win = OGT_GetWindowPtr( VInfo );

      {
         BOOL keeprunning = TRUE;

         while(keeprunning)
         {
            struct IntuiMessage *imsg;

            Wait( 1L << Win->UserPort->mp_SigBit );

            while(keeprunning && (imsg = OGT_GetMsg( VInfo )))
            {
               switch(imsg->Class)
               {
                  case IDCMP_CLOSEWINDOW:
                     keeprunning = FALSE;
                     break;

                  case IDCMP_IDCMPUPDATE:
                     if(OGT_GetLastTagData( OGT_ID, 0, imsg->IAddress ) == GADGETID_SHOWLIST) /* SHOWLIST_OGT_CLASS */
                     {
                        STRPTR icon = (APTR)OGT_GetLastTagData( OGT_DroppedIcon, NULL, imsg->IAddress );

                        if(icon) SetGadgetAttrs( Gads[ 0 ], Win, NULL, OGTAR_FullFileName, (ULONG)icon, TAG_DONE );
                     }

                     break;
               }

               OGT_ReplyMsg( imsg );
            }
         }
      }

      break;
   }

   return( cleanup( NULL ) );
}

static int cleanup( char *str )
{
   if(str) Printf( "%s\n", str );

   if(Ra    ) FreeArgs          ( Ra     );
   if(Gads  ) FreeVec           ( Gads   );
   if(VInfo ) OGT_FreeVisualInfo( VInfo  );
   if(MyFont) CloseFont         ( MyFont );

   CloseOGT();

   return( str ? 10 : 0 );
}
