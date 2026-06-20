/*
** $Filename: demoGfx.c $
** $Release : 1.0       $
** $Revision: 1.260     $
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

#define ARGS_TEMPLATE "FILE/K,FONT/K,SIZE/N,SCANFONTS/S,DEMOSCROLL/S"
#define ARGS_FILE       (0)
#define ARGS_FONT       (1)
#define ARGS_SIZE       (2)
#define ARGS_SCANFONTS  (3)
#define ARGS_DEMOSCROLL (4)
#define ARGS_NUMOF      (5)

static LONG args[ ARGS_NUMOF ];


static char Class_Button  [] = BUTTON_OGT_CLASS  ;
static char Class_String  [] = STRING_OGT_CLASS  ;
static char Class_Prop    [] = PROP_OGT_CLASS    ;
static char Class_Scroller[] = SCROLLER_OGT_CLASS;
static char Class_Showlist[] = SHOWLIST_OGT_CLASS;


struct TextAttr  MyAttr = { NULL, 8 };
struct TextFont *MyFont;
struct Hook      ExtraRender;

APTR                     VInfo;
struct Window           *Win;
Object                 **Gads;
struct RDArgs           *Ra;
struct AvailFontsHeader *afh;
LONG                     afSize;


STRPTR Labels1[] =
{
   "1 OVI_GimmeZeroZero"    ,
   "2 OVI_AdaptWidthToFont" ,
   "3 OVI_AdaptHeightToFont",
   "4 OGT_ScaleLeft"        ,
   "5 OGT_ScaleTop"         ,
   "6 OGT_ScaleWidth"       ,
   "7 OGT_ScaleHeight"      ,
   "8 OGT_DomainXscale"     ,
   "9 OGT_DomainYscale"     ,
   "10 WA_Activate"         ,
   "11 WA_SimpleRefresh"    ,
   "12 WA_NoCareRefresh"    ,
   "13 WA_DepthGadget"      ,
   "14 WA_SizeGadget"       ,
   "15 WA_SizeBBottom"      ,
   "16 WA_SizeBRight"       ,
   "17 WA_DragBar"          ,
   "18 WA_Left"             ,
   "19 WA_Top"              ,
   "20 WA_InnerWidth"       ,
   "21 WA_InnerHeight"      ,
   "22 WA_IDCMP"            ,
   "23 WA_CloseGadget"      ,
   "24 TAG_DONE"            ,              
   NULL
};

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
   { WA_Left              , 400                                     },
   { WA_Top               , 150                                     },
   { WA_InnerWidth        , 306                                     },
   { WA_InnerHeight       , 120                                     },
   { WA_MaxWidth          , -1                                      },
   { WA_MaxHeight         , -1                                      },
   { WA_IDCMP             , (IDCMP_CLOSEWINDOW | IDCMP_IDCMPUPDATE) },
   { WA_CloseGadget       , TRUE                                    },

   { TAG_DONE                                                       },
};

struct OGT_VectorElement Obj1Data[] =
{
   { 40  , 21  , OGTBU_Act_X_Scale|OGTBU_Act_Y_Scale },
   {  0+1,  1+4, OGTBU_Act_Move|OGTBU_Act_StartFill  },
   {  6+1,  7+4, OGTBU_Act_Draw|OGTBU_Act_Shadow     },
   {  1+1, 12+4, OGTBU_Act_Draw                      },
   {  1+1, 13+4, OGTBU_Act_Draw                      },
   {  2+1, 14+4, OGTBU_Act_Draw                      },
   {  7+1,  9+4, OGTBU_Act_Draw                      },
   { 13+1, 15+4, OGTBU_Act_Draw                      },
   { 14+1, 14+4, OGTBU_Act_Draw                      },
   { 15+1, 14+4, OGTBU_Act_Draw                      },
   {  9+1,  8+4, OGTBU_Act_Draw                      },
   {  9+1,  7+4, OGTBU_Act_Draw                      },
   { 13+1,  3+4, OGTBU_Act_Draw                      },
   { 15+1,  2+4, OGTBU_Act_Draw                      },
   { 18+1,  3+4, OGTBU_Act_Draw                      },
   { 16+1,  0+4, OGTBU_Act_Draw                      },
   { 14+1,  0+4, OGTBU_Act_Draw                      },
   { 11+1,  2+4, OGTBU_Act_Draw                      },
   {  8+1,  5+4, OGTBU_Act_Draw                      },
   {  7+1,  5+4, OGTBU_Act_Draw                      },
   {  2+1,  0+4, OGTBU_Act_Draw                      },
   {  1+1,  0+4, OGTBU_Act_Draw|OGTBU_Act_EndFill    },
   {  0+0,  1+2, OGTBU_Act_Move|OGTBU_Act_StartFill  },
   {  6+0,  7+2, OGTBU_Act_Draw|OGTBU_Act_Shine      },
   {  1+0, 12+2, OGTBU_Act_Draw                      },
   {  1+0, 13+2, OGTBU_Act_Draw                      },
   {  2+0, 14+2, OGTBU_Act_Draw                      },
   {  7+0,  9+2, OGTBU_Act_Draw                      },
   { 13+0, 15+2, OGTBU_Act_Draw                      },
   { 14+0, 14+2, OGTBU_Act_Draw                      },
   { 15+0, 14+2, OGTBU_Act_Draw                      },
   {  9+0,  8+2, OGTBU_Act_Draw                      },
   {  9+0,  7+2, OGTBU_Act_Draw                      },
   { 13+0,  3+2, OGTBU_Act_Draw                      },
   { 15+0,  2+2, OGTBU_Act_Draw                      },
   { 18+0,  3+2, OGTBU_Act_Draw                      },
   { 16+0,  0+2, OGTBU_Act_Draw                      },
   { 14+0,  0+2, OGTBU_Act_Draw                      },
   { 11+0,  2+2, OGTBU_Act_Draw                      },
   {  8+0,  5+2, OGTBU_Act_Draw                      },
   {  7+0,  5+2, OGTBU_Act_Draw                      },
   {  2+0,  0+2, OGTBU_Act_Draw                      },
   {  1+0,  0+2, OGTBU_Act_Draw|OGTBU_Act_Last       }
};

struct OGT_VectorImage Obj1Shapes[] = { Obj1Data, Obj1Data, NULL, 4, -1, 80, 22, TRUE, TRUE };

struct TagItem Object1Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID            , 1                     },
   { GA_RelVerify     , TRUE                  },

   { GA_Left          , 2                     },
   { GA_Top           , 1                     },
   { GA_Width         , 80                    },
   { GA_Height        , 12                    },

   { GA_Text          , "_Cancel"             },
   { OGT_TextPlacement, OGT_Text_IN_RIGHTMOST },
   { OGTBU_VectorImage, Obj1Shapes            },
   { OGT_AppGadget    , TRUE                  },

   { TAG_DONE                                 },
};

struct TagItem Obj2toObj5[] =
{
   { OGTBU_ActiveLabel, PGA_Top },
   { TAG_DONE                   }
};

Tag Obj2toObj5Filter[] =
{
   OGTBU_ActiveLabel,
   TAG_DONE
};

struct TagItem Object2Desc[] = /* BUTTON_OGT_CLASS */
{
   { GA_ID            , 2                  },
   { GA_RelVerify     , TRUE               },
   { OGT_ClickRepeat  , TRUE               },

   { GA_Left          , 2                  },
   { GA_Top           , 17                 },
   { GA_Width         , 168                },
   { GA_Height        , 14                 },

   { OGTBU_Labels     , Labels1            },

   { TAG_DONE                              },
};

struct TagItem Obj3toObj2[] =
{
   { STRINGA_LongVal, OGTBU_ActiveLabel },
   { TAG_DONE                           }
};

Tag Obj3toObj2Filter[] =
{
   STRINGA_LongVal,
   TAG_DONE
};

struct TagItem Object3Desc[] = /* STRING_OGT_CLASS */
{
   { GA_ID            , 3                  },
   { GA_RelVerify     , TRUE               },

   { GA_Left          , 88                 },
   { GA_Top           , 1                  },
   { GA_Width         , 96                 },
   { GA_Height        , 14                 },

   { GA_Text          , "_String"          },
   { OGT_TextPlacement, OGT_Text_RIGHT     },

   { STRINGA_MaxChars , 32                 },
   { STRINGA_LongVal  , 10                 },
   { STRINGA_ExitHelp , TRUE               },
   { GA_TabCycle      , TRUE               },

   { TAG_DONE                              },
};

struct TagItem Object4Desc[] = /* PROP_OGT_CLASS */
{
   { GA_ID              , 4                },
   { GA_RelVerify       , TRUE             },

   { OGT_ScaleLeft      , OGT_FontRelative },
   { OGT_SetPosReference, OGT_Y_Bottom     },
   { GA_Left            , 46               },
   { GA_Top             , -19              },
   { GA_Width           , 96               },
   { GA_Height          , 9                },

   { GA_Text            , "_HProp"         },
   { OGT_TextPlacement  , OGT_Text_LEFT    },
   { PGA_Top            , 10               },
   { PGA_Visible        , 10               },
   { PGA_Total          , 100              },
   { PGA_Freedom        , FREEHORIZ        },

   { TAG_DONE                              },
};

struct TagItem Obj5toObj3[] =
{
   { PGA_Top, STRINGA_LongVal },
   { TAG_DONE                 }
};

Tag Obj5toObj3Filter[] =
{
   PGA_Top ,
   TAG_DONE
};

struct TagItem Object5Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_ID              , 5                },
   { GA_RelVerify       , TRUE             },

   { OGT_ScaleLeft      , OGT_FontRelative },
   { OGT_SetPosReference, OGT_Y_Bottom     },
   { GA_Left            , 46               },
   { GA_Top             , -9               },
   { GA_Width           , 96               },
   { GA_Height          , 9                },

   { GA_Text            , "_HScro"         },
   { OGT_TextPlacement  , OGT_Text_LEFT    },

   { PGA_Top            , 10               },
   { PGA_Visible        , 10               },
   { PGA_Total          , 100              },
   { PGA_Freedom        , FREEHORIZ        },

   { TAG_DONE                              },
};

struct TagItem Object6Desc[] = /* PROP_OGT_CLASS */
{
   { GA_ID              , 6                            },
   { GA_Immediate       , TRUE                         },
   { GA_FollowMouse     , TRUE                         },
   { GA_RelVerify       , TRUE                         },

   { OGT_SetPosReference, (OGT_X_Right | OGT_Y_Bottom) },
   { GA_Left            , -81                          },
   { GA_Top             , -52                          },
   { GA_Width           , 16                           },
   { GA_Height          , 51                           },

   { GA_Text            , "_VProp"                     },
   { OGT_TextPlacement  , OGT_Text_ABOVE               },

   { PGA_Top            , 10                           },
   { PGA_Visible        , 10                           },
   { PGA_Total          , 100                          },
   { PGA_Freedom        , FREEVERT                     },

   { TAG_DONE                                          },
};

struct TagItem Object7Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_ID              , 7                            },
   { GA_RelVerify       , TRUE                         },

   { OGT_SetPosReference, (OGT_X_Right | OGT_Y_Bottom) },
   { GA_Left            , -33                          },
   { GA_Top             , -52                          },
   { GA_Width           , 16                           },
   { GA_Height          , 51                           },

   { GA_Text            , "_VScro"                     },
   { OGT_TextPlacement  , OGT_Text_ABOVE               },

   { PGA_Top            , 10                           },
   { PGA_Visible        , 10                           },
   { PGA_Total          , 100                          },
   { PGA_Freedom        , FREEVERT                     },

   { TAG_DONE                                          },
};


struct TagItem Obj8toObj10[] =
{
   { PGA_Top , OGTSL_VertPos },
   { TAG_DONE                }
};

struct TagItem Object8Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_ID              , 8                                         },
   { GA_Immediate       , TRUE                                      },
   { GA_FollowMouse     , TRUE                                      },
   { GA_RelVerify       , TRUE                                      },

   { OGT_SetDimReference, (OGT_X_Dim_Relative | OGT_Y_Dim_Relative) },
   { GA_RightBorder     , TRUE                                      },

   { PGA_Freedom        , FREEVERT                                  },
   { PGA_Top            , 0                                         },
   { PGA_Visible        , 0                                         },
   { PGA_Total          , 0                                         },

   { TAG_DONE                                                       },
};


struct TagItem Obj9toObj10[] =
{
   { PGA_Top , OGTSL_HoriPos },
   { TAG_DONE                }
};

struct TagItem Object9Desc[] = /* SCROLLER_OGT_CLASS */
{
   { GA_ID              , 9                                         },
   { GA_Immediate       , TRUE                                      },
   { GA_FollowMouse     , TRUE                                      },
   { GA_RelVerify       , TRUE                                      },

   { OGT_SetDimReference, (OGT_X_Dim_Relative | OGT_Y_Dim_Relative) },
   { GA_BottomBorder    , TRUE                                      },

   { PGA_Freedom        , FREEHORIZ                                 },
   { PGA_Top            , 0                                         },
   { PGA_Visible        , 0                                         },
   { PGA_Total          , 0                                         },

   { TAG_DONE                                                       },
};


struct TagItem Obj10toObj8[] =
{
   { OGTSL_VertPos    , PGA_Top     },
   { OGTSL_VertTotal  , PGA_Total   },
   { OGTSL_VertVisible, PGA_Visible },
   { TAG_DONE                       }
};

Tag Obj10toObj8Filter[] =
{
   OGTSL_VertPos    ,
   OGTSL_VertTotal  ,
   OGTSL_VertVisible,
   TAG_DONE
};

struct TagItem Obj10toObj9[] =
{
   { OGTSL_HoriPos    , PGA_Top     },
   { OGTSL_HoriTotal  , PGA_Total   },
   { OGTSL_HoriVisible, PGA_Visible },
   { TAG_DONE                       }
};

Tag Obj10toObj9Filter[] =
{
   OGTSL_HoriPos    ,
   OGTSL_HoriTotal  ,
   OGTSL_HoriVisible,
   TAG_DONE
};

struct TagItem Object10Desc[] = /* SHOWLIST_OGT_CLASS */
{
   { GA_ID                 , 10              },
   { GA_Immediate          , TRUE            },
   { GA_FollowMouse        , TRUE            },
   { GA_RelVerify          , TRUE            },

   { GA_Left               , 2               },
   { GA_Top                , 33              },
   { GA_Width              , 168             },
   { GA_Height             , 66              },

   { GA_Text               , "_List"         },
   { OGT_TextPlacement     , OGT_Text_RIGHT  },

   { OGTSL_ExtraRendering  , &ExtraRender    },

   { TAG_DONE                                },
};

struct TagItem Object10Post[] =
{
   { OGTSL_FileToLoadByName },
   { TAG_DONE               }
};

struct OGT_ObjectSettings ListOfObjects[] =
{
   { Class_Button  , Object1Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Button  , Object2Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_String  , Object3Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Prop    , Object4Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Scroller, Object5Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Prop    , Object6Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Scroller, Object7Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Scroller, Object8Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Scroller, Object9Desc , NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
   { Class_Showlist, Object10Desc, Object10Post, OGT_NOOBJECT, OGT_NOOBJECT },
   { NULL                                                                   },
   { Class_Showlist, Object10Desc, NULL        , OGT_NOOBJECT, OGT_NOOBJECT },
};

struct OGT_ObjectLink ListOfLinks[] =
{
   { 1           , 4, Obj2toObj5 , Obj2toObj5Filter  },
   { 2           , 1, Obj3toObj2 , Obj3toObj2Filter  },
   { 4           , 2, Obj5toObj3 , Obj5toObj3Filter  },
   { 9           , 7, Obj10toObj8, Obj10toObj8Filter },
   { 9           , 8, Obj10toObj9, Obj10toObj9Filter },
   { 7           , 9, Obj8toObj10                    },
   { 8           , 9, Obj9toObj10                    },
   { OGT_NOOBJECT                                    },
};

static void cleanup           ( char *str );
static void goHandleWindowWait( void      );
static BOOL goHandleWindow    ( void      );


static ULONG ExtraDrawing( struct Hook                 *hook ,
                           Object                      *o    ,
                           struct ogmsl_ExtraRendering *msg  )
{
   struct RastPort *rp = msg->ogmsl_RPort;
   LONG             x  = msg->ogmsl_Domain.Left - msg->ogmsl_TextScrollLeft;
   LONG             y  = msg->ogmsl_Domain.Top  - msg->ogmsl_TextScrollTop ;

   if(msg->ogmsl_AfterText)
   {
      SetAPen( rp,   3              );
      Move   ( rp,   0 + x,   0 + y );
      Draw   ( rp, 400 + x, 300 + y );

      {
         struct IBox box;

         box.Left   = 100 + x;
         box.Top    = 100 + y;
         box.Width  = 100;
         box.Height = 100;

         OGT_DrawVectorImage( rp, NULL, &box, Obj1Data );
      }
   }
   else
   {
      {
         struct ogmsl_Node *ptr = OGT_GetANode( msg->ogmsl_Nodes, 7 );

         if(ptr) ptr->ogmsl_Flags = ogmsl_Flags_ReverseColors;
      }

      SetAPen    ( rp,   2                        );
      Move       ( rp, 200 + x,   0 + y           );
      Draw       ( rp,   0 + x, 600 + y           );
      DrawEllipse( rp, 400 + x, 300 + y, 100, 140 );
   }


   return( TRUE );
}

void main( void )
{
   struct AvailFonts *af;
   LONG               afShortage;

   if(!OpenOGT()) cleanup( "no objectivegadtools library\n" );

   if(!(Ra = ReadArgs( ARGS_TEMPLATE, args, NULL ))) cleanup( "can't parse args\n" );

   if(args[ ARGS_SCANFONTS ])
   {
      afSize = 10000;

      do
      {
         if(afh = (struct AvailFontsHeader *)AllocMem( afSize, 0 ))
         {
            if(afShortage = AvailFonts( afh, afSize, AFF_DISK ))
            {
               FreeMem( afh, afSize );

               afSize += afShortage;
            }
         }
         else
         {
            break;
         }

      } while(afShortage);

      if(!afh) cleanup( "can't scan fonts!\n" );

      af = (struct AvailFonts *)(&afh->afh_NumEntries + 1);
   }
   else
   {
      if(args[ ARGS_FONT ]) MyAttr.ta_Name  =  (void  *)args[ ARGS_FONT ];
      if(args[ ARGS_SIZE ]) MyAttr.ta_YSize = *(ULONG *)args[ ARGS_SIZE ];

      if(MyAttr.ta_Name)
      {
         if(!(MyFont = OpenDiskFont( &MyAttr ))) cleanup( "can't open font!!\n" );
      }
   }

   ExtraRender.h_Entry    = hookEntry;
   ExtraRender.h_SubEntry = ExtraDrawing;

   while(1)
   {
      STRPTR title = "Prova";

      if(args[ ARGS_SCANFONTS ])
      {
         if(!afh->afh_NumEntries) break;

         if(!(MyFont = OpenDiskFont( &af->af_Attr ))) cleanup( "can't open font!!\n" );

         title = af->af_Attr.ta_Name;
      }

      VInfo = OGT_GetVisualInfo( NULL, OGT_TextFont, (ULONG)MyFont         ,
                                       WA_Title    , (ULONG)title          ,
                                       TAG_MORE    , (ULONG)WindowDescTags );

      if(VInfo == NULL) cleanup( "can't open my window.\n" );

      Object10Post[ 0 ].ti_Data = args[ ARGS_FILE ];

      if(!OGT_BuildObjects( VInfo, ListOfObjects, ListOfLinks, &Gads )) cleanup( "can't create objects" );

      Win = OGT_GetWindowPtr( VInfo );

      {
         if(args[ ARGS_SCANFONTS ])
         {
            Delay( 50 );

            if(!goHandleWindow()) break;
         }
         else
         {
            goHandleWindowWait();
         }

         while(args[ ARGS_DEMOSCROLL ])
         {
            SHORT i = 0;

            while(i < 50)
            {
               SetGadgetAttrs( Gads[ 9 ], Win, NULL, OGTSL_HoriPos, (ULONG)i++, TAG_DONE );

               if(!goHandleWindow()) break;
            }

            if(i != 50 ) break;

            while(i >  0)
            {
               SetGadgetAttrs( Gads[ 9 ], Win, NULL, OGTSL_HoriPos, (ULONG)i--, TAG_DONE );

               if(!goHandleWindow()) break;
            }

            if(i != 0) break;
         }
      }

      if(args[ ARGS_SCANFONTS ])
      {
         if(VInfo ) { OGT_FreeVisualInfo( VInfo  ); VInfo  = NULL; }
         if(MyFont) { CloseFont         ( MyFont ); MyFont = NULL; }

         af++; afh->afh_NumEntries--;

         continue;
      }

      break;
   }

   cleanup( "all done" );
}

static void cleanup( char *str )
{
   if(str) Printf( "%s\n", str );

   if(afh   ) FreeMem           ( afh, afSize );
   if(Ra    ) FreeArgs          ( Ra          );
   if(Gads  ) FreeVec           ( Gads        );
   if(VInfo ) OGT_FreeVisualInfo( VInfo       );
   if(MyFont) CloseFont         ( MyFont      );

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
               struct TagItem *tags = imsg->IAddress;

               switch( GetTagData( OGT_ID, -1, tags ) )
               {
                  case 10: /* SHOWLIST */
                     {
                        static LONG        last_num    = -1;
                        static BOOL        last_status = FALSE;

                        LONG               num         = GetTagData( OGTSL_HitLabelNumFromList, -1, tags );

                        struct MinList    *list;
                        struct ogmsl_Node *ptr;

                        SetGadgetAttrs( Gads[ 9 ], Win, NULL, OGTSL_LockList, (ULONG)TRUE, TAG_DONE );

                        if(GetAttr( OGTSL_ListOfLabels, Gads[ 9 ], &list ))
                        {
                           if(GetTagData( OGT_GadgetDown, FALSE, tags ))
                           {
                              if(last_num != -1 && last_status)
                              {
                                 if(ptr = OGT_GetANode( list, last_num ))
                                 {
                                    ptr->ogmsl_Flags |=  ogmsl_Flags_Modified;
                                    ptr->ogmsl_Flags &= ~ogmsl_Flags_ReverseColors;
                                 }
                              }                                 

                              last_num    = num;
                              last_status = TRUE;

                              if(ptr = OGT_GetANode( list, last_num ))
                              {
                                 ptr->ogmsl_Flags |= ogmsl_Flags_Modified;
                                 ptr->ogmsl_Flags |= ogmsl_Flags_ReverseColors;
                              }
                              else
                              {
                                 last_num = -1;
                              }
                           }

                           if(GetTagData( OGT_GadgetMove, FALSE, tags ) && last_num != -1)
                           {
                              if(ptr = OGT_GetANode( list, last_num ))
                              {
                                 if(( last_status && last_num != num) ||
                                    (!last_status && last_num == num)  )
                                 {
                                    ptr->ogmsl_Flags |= ogmsl_Flags_Modified;
                                    ptr->ogmsl_Flags ^= ogmsl_Flags_ReverseColors;
                                    last_status       = TRUE - last_status;
                                 }
                              }
                           }

                           if(GetTagData( OGT_GadgetUp, FALSE, tags ))
                           {
                              if(ptr = OGT_GetANode( list, last_num ))
                              {
                                 ptr->ogmsl_Flags |=  ogmsl_Flags_Modified;
                                 ptr->ogmsl_Flags &= ~ogmsl_Flags_ReverseColors;
                              }

                              last_num = -1;
                           }
                        }

                        SetGadgetAttrs( Gads[ 9 ], Win, NULL, OGTSL_LockList, (ULONG)FALSE, TAG_DONE );
                     }
                     break;
               }
            }
                        
            break;
      }

      OGT_ReplyMsg( imsg );
   }

   return( keeprunning );
}
