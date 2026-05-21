(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


MODULE FontOrganizer;

(* Provides a font requester *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       st : Strings,
       lrc: LongRealConversions,
       l  : LinkedLists,
       tt : TextTools,
       ag : AmigaGuideTools,
       of : OutlineFonts,
       fm : FontManager,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gb : GeneralBasics,
       m  : Multitasking,
       mem: MemoryManager,
       ft : FunctionTrees,
       ac : AnalayCatalog,
       bt : BasicTypes,
       io,
       NoGuruRq;

TYPE Path * = POINTER TO PathDesc;
     PathDesc * = RECORD(m.ShareAbleDesc)
       path * : ARRAY 80 OF CHAR;
     END;

PROCEDURE * PrintPath*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: Path DO
      NEW(str);
      COPY(node.path,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintPath;

TYPE FontName * = POINTER TO FontNameDesc;
     FontNameDesc * = RECORD(m.ShareAbleDesc)
       name      * : ARRAY 80 OF CHAR; (* User defined name. Not equal to font filename! *)
       styles    * : ARRAY 5 OF ARRAY 80 OF CHAR; (* This array contains the filenames of the fonts
                                                     for various styles. See CONSTS for definitions. *)
       font      * : fm.Font; (* Pointer to font when opened *)
     END;

     FontSize * = POINTER TO FontSizeDesc;
     FontSizeDesc * = RECORD(m.ShareAbleDesc)
       real * : LONGREAL;
     END;

CONST normal     * = 0; (* Style types in FontName *)
      bold       * = 1;
      italic     * = 2;
      bolditalic * = 3;

PROCEDURE * PrintFontName*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: FontName DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFontName;

PROCEDURE * PrintFontSize*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;
    bool : BOOLEAN;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: FontSize DO
      NEW(str);
      bool:=tt.RealToString(node.real,str^,FALSE);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFontSize;



(* It's only save to call this requester once at a time! *)

VAR fonts           * : m.MTList;
    pathes          * : m.MTList;
    sizes           * : m.MTList; (* Userfriendly way to let him select the size of a font. This list used for every font. *)
    changefontswind * ,
    selectfontwind  * : wm.Window;

PROCEDURE AddSize*(real:LONGREAL):FontSize;

VAR node,newnode : l.Node;

BEGIN
  newnode:=NIL;
  node:=sizes.head;
  WHILE node#NIL DO
    IF node(FontSize).real=real THEN
      RETURN node(FontSize);
    ELSIF node(FontSize).real>real THEN
      NEW(newnode(FontSize)); newnode.Init;
      newnode(FontSize).real:=real;
      node.AddBefore(newnode);
      RETURN newnode(FontSize);
    END;
    node:=node.next;
  END;
  NEW(newnode(FontSize)); newnode.Init;
  newnode(FontSize).real:=real;
  sizes.AddTail(newnode);
  RETURN newnode(FontSize);
END AddSize;

PROCEDURE ChangeFonts*(changetask:m.Task;screen:I.ScreenPtr):BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    newfont,
    delfont,
    sortfonts,
    newpath,
    delpath   : gmo.BooleanGadget;
    fontlv,
    styleslv,
    pathlv    : gmo.ListView;
    stylename : gmo.StringGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    class     : LONGSET;
    msg       : m.Message;
    node      : l.Node;
    actfont   : l.Node;
    actstyle  : LONGINT;
    actpath   : l.Node;
    stylelist : l.List; (* Only used for display. No further functionality. *)
    bool,ret,
    didchange : BOOLEAN;

PROCEDURE RefreshFont;

BEGIN
  IF actfont#NIL THEN
    fontlv.SetString(actfont(FontName).name);
    fontlv.SetValue(fonts.GetNodeNumber(actfont));
    styleslv.ChangeListViewSpecial(-1,gb.PrintString);
    styleslv.SetValue(actstyle);
  ELSE
    fontlv.Refresh;
    styleslv.ChangeListViewSpecial(0,gb.PrintString);
  END;
END RefreshFont;

PROCEDURE RefreshPath;

BEGIN
  IF actpath#NIL THEN
    pathlv.SetString(actpath(Path).path);
    pathlv.SetValue(pathes.GetNodeNumber(actpath));
  ELSE
    pathlv.Refresh;
  END;
END RefreshPath;

PROCEDURE RefreshStyle;

BEGIN
  IF actfont#NIL THEN
    stylename.SetString(actfont(FontName).styles[actstyle]);
  ELSE
    stylename.SetString("");
  END;
END RefreshStyle;

PROCEDURE GetInput;

BEGIN
  IF actfont#NIL THEN
    fontlv.GetString(actfont(FontName).name);
    stylename.GetString(actfont(FontName).styles[actstyle]);
  END;
  IF actpath#NIL THEN pathlv.GetString(actpath(Path).path); END;
END GetInput;

BEGIN
  stylelist:=l.Create();
  IF stylelist=NIL THEN RETURN FALSE; END;
  gb.AddString(stylelist,"General",SHORTSET{});
  gb.AddString(stylelist,"Bold",SHORTSET{g.bold});
  gb.AddString(stylelist,"Italic",SHORTSET{g.italic});
  gb.AddString(stylelist,"BoldItalic",SHORTSET{g.bold,g.italic});

  fonts.NewUser(changetask,TRUE);
  pathes.NewUser(changetask,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF changefontswind=NIL THEN
    changefontswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.Fonts),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changefontswind.InitSub(screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      fontlv:=gmo.SetListView(ac.GetString(ac.Fonts),fonts,PrintFontName,0,TRUE,79);
      newfont:=gmo.SetBooleanGadget(ac.GetString(ac.NewFont),FALSE);
      delfont:=gmo.SetBooleanGadget(ac.GetString(ac.DelFont),FALSE);
      sortfonts:=gmo.SetBooleanGadget(ac.GetString(ac.SortFonts),TRUE);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      styleslv:=gmo.SetListView(s.ADR("Styles"),stylelist,gb.PrintString,0,FALSE,79);
      stylename:=gmo.SetStringGadget(s.ADR("Filename:"),79,gmo.stringType);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      pathlv:=gmo.SetListView(s.ADR("Pathes"),pathes,PrintPath,0,TRUE,79);
      newpath:=gmo.SetBooleanGadget(ac.GetString(ac.NewPath),FALSE);
      delpath:=gmo.SetBooleanGadget(ac.GetString(ac.DelPath),FALSE);
    gmb.EndBox;
  glist:=root.EndRoot();
  fontlv.SetNoEntryText(s.ADR("No fonts!"));
  styleslv.SetNoEntryText(s.ADR("No styles!"));
  pathlv.SetNoEntryText(s.ADR("No pathes!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actfont:=fonts.head;
    actstyle:=0;
    actpath:=pathes.head;
    RefreshFont;
    RefreshStyle;
    RefreshPath;

    fontlv.Activate;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
(*      IF gridtask.msgsig IN class THEN
        REPEAT
          msg:=gridtask.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              subwind.Close;
              root.Resize;
            ELSIF msg.type=m.msgOpen THEN
              subwind.SetScreen(mg.screen);
              wind:=subwind.Open(NIL);
              IF wind#NIL THEN
                rast:=wind.rPort;
                root.Resize;
                xspace1.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              SetData;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;*)
      REPEAT
        root.GetIMes(mes);
        GetInput;
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            (* Undo here! *)
            IF didchange THEN
              fonts.Changed;
              pathes.Changed;
            END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=newfont.gadget THEN
            node:=NIL; NEW(node(FontName));
            IF node#NIL THEN
              node.Init;
              fonts.AddTail(node);
              actfont:=node;
              RefreshFont;
              RefreshStyle;
            END;
          ELSIF mes.iAddress=delfont.gadget THEN
            IF actfont#NIL THEN
              node:=actfont.next;
              IF node=NIL THEN node:=actfont.prev; END;
              actfont.Remove;
              mem.NodeToGarbage(actfont(m.ShareAble));
              actfont:=node;
              RefreshFont;
              RefreshStyle;
            END;
          ELSIF mes.iAddress=newpath.gadget THEN
            node:=NIL; NEW(node(Path));
            IF node#NIL THEN
              node.Init;
              pathes.AddTail(node);
              actpath:=node;
              RefreshPath;
            END;
          ELSIF mes.iAddress=delpath.gadget THEN
            IF actpath#NIL THEN
              node:=actpath.next;
              IF node=NIL THEN node:=actpath.prev; END;
              actpath.Remove;
              mem.NodeToGarbage(actpath(m.ShareAble));
              actpath:=node;
              RefreshPath;
            END;
          ELSIF mes.iAddress=fontlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actfont:=fonts.GetNode(fontlv.GetValue());
              RefreshFont;
              RefreshStyle;
              RefreshPath;
              fontlv.Activate;
            END;
          ELSIF mes.iAddress=styleslv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              IF actfont#NIL THEN
                actstyle:=styleslv.GetValue();
                RefreshStyle;
                stylename.Activate;
              END;
            END;
          ELSIF mes.iAddress=pathlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actpath:=pathes.GetNode(pathlv.GetValue());
              RefreshPath;
              pathlv.Activate;
            END;
          ELSIF mes.iAddress=fontlv.stringgad THEN
            IF actfont#NIL THEN actfont(m.ShareAble).Changed; END;
            RefreshFont;
          ELSIF mes.iAddress=pathlv.stringgad THEN
            IF actpath#NIL THEN actpath(m.ShareAble).Changed; END;
            RefreshPath;
          ELSIF NOT(mes.iAddress=root.help) THEN
            didchange:=TRUE;
            (* Send change message*)
          END;
        END;
        IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"changegrid",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  pathes.FreeUser(changetask);
  fonts.FreeUser(changetask);
  stylelist.Destruct;
  RETURN ret;
END ChangeFonts;

PROCEDURE ChangeFontsTask*(changetask:bt.ANY):bt.ANY;

VAR screen : I.ScreenPtr;
    bool   : BOOLEAN;

BEGIN
  WITH changetask: m.Task DO
    changetask.InitCommunication;
    screen:=s.VAL(I.ScreenPtr,changetask.data);
    bool:=ChangeFonts(changetask,screen);

    m.taskdata.maintask.RemTask(changetask);
    changetask.ReplyAllMessages;
    changetask.DestructCommunication;
    mem.NodeToGarbage(changetask);
    m.taskdata.maintask.FreeUser(changetask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeFontsTask;



(* Used to describe an unloaded font.
   Call FontInfo.Open to open the font.
   Close this returned font-handle when finished using font.Destruct.
   Destruct this font info in the very end. It's no problem to call
   FontInfo.Open more than once. Don't forget to close each font. *)

TYPE FontInfo * = POINTER TO FontInfoDesc;
     FontInfoDesc * = RECORD(l.NodeDesc);
       path*,name * : ARRAY 128 OF CHAR;
       ySize      * : LONGREAL;
       style      * : SHORTSET;
       changed    * : BOOLEAN;
     END;

PROCEDURE (fontinfo:FontInfo) Init*;

BEGIN
  fontinfo.path:="fonts:";
  fontinfo.name:="topaz";
  fontinfo.ySize:=8;
END Init;

PROCEDURE (fontinfo:FontInfo) Copy*(dest:l.Node);

BEGIN
  WITH dest: FontInfo DO
    fontinfo.Copy^(dest);
    COPY(fontinfo.path,dest.path);
    COPY(fontinfo.name,dest.name);
    dest.ySize:=fontinfo.ySize;
    dest.style:=fontinfo.style;
  END;
END Copy;

PROCEDURE (fontinfo:FontInfo) BCopy*(dest:l.Node);

BEGIN
  fontinfo.Copy(dest);
END BCopy;

PROCEDURE (fontinfo:FontInfo) AllocNew*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(FontInfo));
  RETURN node;
END AllocNew;

PROCEDURE * PrintFontInfo*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;
    str2 : ARRAY 16 OF CHAR;
    bool : BOOLEAN;

BEGIN
  IF user#NIL THEN
    node:=s.VAL(l.Node,user);
    WITH node: FontInfo DO
      NEW(str);
      COPY(node.name,str^);
      st.AppendChar(str^," ");
      bool:=lrc.RealToString(node.ySize,str2,4,2,FALSE);
      tt.Clear(str2);
      st.Append(str^,str2);
      st.Append(str^,"pt");
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFontInfo;

PROCEDURE (fontinfo:FontInfo) Open*():fm.Font;

VAR font : fm.Font;

BEGIN
  fontinfo.changed:=FALSE;
  font:=fm.OpenFont(fontinfo.path,fontinfo.name,fontinfo.ySize);
  IF font=NIL THEN
    font:=fm.OpenFont("fonts:","topaz",fontinfo.ySize);
  END;
  RETURN font;
END Open;



PROCEDURE (fontinfo:FontInfo) SelectFont*(selecttask:m.Task;screen:I.ScreenPtr):BOOLEAN;
(* Though this procedure probably will not be started as a separate
   task: Always provide a pointer to the owning task (or a pointer
   to the SelectFont-Task when started as a separate task) in the
   selecttask-field. *)

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    fontlv,
    styleslv,
    sizelv    : gmo.ListView;
    sizegad   : gmo.StringGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    class     : LONGSET;
    msg       : m.Message;
    node      : l.Node;
    actfont   : l.Node;
    actstyle  : LONGINT;
    actsize   : LONGREAL;
    stylelist : l.List; (* Only used for display. No further functionality. *)
    backup    : FontInfo;
    str       : ARRAY 80 OF CHAR;
    bool,ret  : BOOLEAN;

PROCEDURE SetData;

VAR node : l.Node;
    str  : ARRAY 80 OF CHAR;

BEGIN
  IF actfont#NIL THEN
    fontlv.SetValue(fonts.GetNodeNumber(actfont));
    styleslv.ChangeListViewSpecial(-1,gb.PrintString);
    styleslv.SetValue(actstyle);
  ELSE
    fontlv.Refresh;
    styleslv.ChangeListViewSpecial(0,gb.PrintString);
  END;
  node:=AddSize(actsize);
  IF node#NIL THEN sizelv.SetValue(sizes.GetNodeNumber(node));
              ELSE sizelv.Refresh; END;
  bool:=tt.RealToString(actsize,str,FALSE);
  sizegad.SetString(str);
END SetData;

PROCEDURE GetInput;

VAR real      : LONGREAL;
    pos,bcount,
    error     : INTEGER;

BEGIN
  actfont:=fonts.GetNode(fontlv.GetValue());
  actstyle:=styleslv.GetValue();
  IF actstyle<0 THEN actstyle:=0; END;
  real:=sizegad.GetReal();
  IF real#actsize THEN
    actsize:=real;
    node:=AddSize(actsize);
    IF node#NIL THEN sizelv.SetValue(sizes.GetNodeNumber(node));
                ELSE sizelv.Refresh; END;
  END;
END GetInput;

PROCEDURE GetActFont;
(* Sets actfont, actsize and actstyle to proper values. *)

VAR node      : l.Node;
    style,max : LONGINT;

BEGIN
  actfont:=fonts.head; actstyle:=0; actsize:=fontinfo.ySize;
  node:=fonts.head;
  WHILE node#NIL DO
    style:=0;
    max:=LEN(node(FontName).styles);
    WHILE style<max DO
      IF tt.Compare(node(FontName).styles[style],fontinfo.name) THEN
        actfont:=node;
        actstyle:=style;
(* Exit *)
        style:=LEN(node(FontName).styles);
        node:=NIL;
      END;
      INC(style);
    END;
    IF node#NIL THEN node:=node.next; END;
  END;
END GetActFont;

BEGIN
  NEW(backup); IF backup=NIL THEN RETURN FALSE; END;
  backup.Init;
  fontinfo.BCopy(backup);

  stylelist:=l.Create();
  IF stylelist=NIL THEN RETURN FALSE; END;
  gb.AddString(stylelist,"General",SHORTSET{});
  gb.AddString(stylelist,"Bold",SHORTSET{g.bold});
  gb.AddString(stylelist,"Italic",SHORTSET{g.italic});
  gb.AddString(stylelist,"BoldItalic",SHORTSET{g.bold,g.italic});

  fonts.NewUser(selecttask,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF selectfontwind=NIL THEN
    selectfontwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.SelectFont),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=selectfontwind.InitSub(screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    fontlv:=gmo.SetListView(ac.GetString(ac.Font),fonts,PrintFontName,0,FALSE,80);
    fontlv.SetSizeX(10);
    styleslv:=gmo.SetListView(s.ADR("Styles"),stylelist,gb.PrintString,0,FALSE,80);
    styleslv.SetSizeX(8);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      sizelv:=gmo.SetListView(ac.GetString(ac.Size),sizes,PrintFontSize,0,FALSE,4);
(*      sizelv.SetMinVisible(3);*)
      sizelv.SetSizeX(2);
      sizegad:=gmo.SetStringGadget(NIL,79,gmo.realType);
      sizegad.SetMinVisible(5);
      sizegad.SetOutValues(0,0);
      sizegad.SetMinMaxReal(fm.minSize,fm.maxSize);
    gmb.EndBox;
  glist:=root.EndRoot();
  fontlv.SetNoEntryText(s.ADR("No fonts!"));
  styleslv.SetNoEntryText(s.ADR("No styles!"));
  sizelv.SetNoEntryText(s.ADR("No sizes!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    GetActFont;

    SetData;

    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF selecttask.msgsig IN class THEN
        REPEAT
          msg:=selecttask.ReceiveMsgTypeData(m.msgListChanged,fonts);
          IF msg=NIL THEN msg:=selecttask.ReceiveMsgType(m.msgNodeChanged); END;
          IF msg#NIL THEN
            IF msg.type=m.msgListChanged THEN
              IF msg.data=fonts THEN
                IF ((actfont#NIL) & mem.Garbaged(actfont)) OR (actfont=NIL) THEN
                  actfont:=fonts.head;
                END;
                SetData;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              fontlv.Refresh;
              SetData;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          GetInput;
          IF mes.iAddress=root.ok THEN
            IF actfont#NIL THEN
              COPY(actfont(FontName).styles[actstyle],fontinfo.name);
            END;
            fontinfo.ySize:=actsize;
            fontinfo.changed:=TRUE; (* Could be optimized. *)

            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            backup.BCopy(fontinfo);
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=sizelv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              node:=sizes.GetNode(sizelv.GetValue());
              IF node#NIL THEN actsize:=node(FontSize).real; END;
              SetData;
            END;
          END;
        END;
        IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"changegrid",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  fonts.FreeUser(selecttask);
  stylelist.Destruct;
  IF backup#NIL THEN backup.Destruct; END;
  RETURN ret;
END SelectFont;

VAR node : l.Node;

BEGIN
  changefontswind:=NIL; selectfontwind:=NIL;
  fonts:=m.Create();
  pathes:=m.Create();
  sizes:=m.Create();
  IF (fonts=NIL) OR (pathes=NIL) OR (sizes=NIL) THEN HALT(20); END;
  node:=AddSize(8);
  node:=AddSize(10);
  node:=AddSize(11);
  node:=AddSize(12);
  node:=AddSize(14);
  node:=AddSize(16);
  node:=AddSize(18);
  node:=AddSize(24);
  node:=AddSize(36);
  node:=AddSize(76);
CLOSE
  IF fonts#NIL THEN fonts.Destruct; END;
  IF pathes#NIL THEN pathes.Destruct; END;
  IF sizes#NIL THEN sizes.Destruct; END;
END FontOrganizer.

