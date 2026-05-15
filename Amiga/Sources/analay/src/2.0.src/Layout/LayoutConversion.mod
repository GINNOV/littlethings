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


MODULE LayoutConversion;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       l  : LinkedLists,
       gd : GadTools,
       ag : AmigaGuideTools,
       fm : FontManager,
       fo : FontOrganizer,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       gb : GeneralBasics,
       m  : Multitasking,
       mem: MemoryManager,
       mg : MathGUI,
       go : GraphicObjects,
       lb : LayoutBasics,
       col: Colors,
       dc : DisplayConversion,
       pc : PageCoords,
       pi : PlotInfo,
       ac : AnalayCatalog,
       bas: BasicTypes,
       io,
       NoGuruRq;

TYPE LayoutConversionTable * = POINTER TO LayoutConversionTableDesc;
     LayoutConversionTableDesc * = RECORD(dc.ConversionTableDesc)
       plotinfo       * : pi.PlotInfo;      (* Always must contain a valid pointer! *)
       linethickness  * : POINTER TO ARRAY OF LONGREAL;
       colors         * : POINTER TO ARRAY OF col.Color;
       fontlist       * : l.List;

(* Used instead of normal conversion table when #NIL (see also GraphWindowBox for example). *)
       privatefont    * : fo.FontInfo; (* Must be allocated via AllocPrivateFont by calling task but gets destructed automatically by this object when #NIL. *)
       textcolor      * ,
       graphcolor     * : col.Color;
     END;

     GridLabelsConversionTable * = POINTER TO GridLabelsConversionTableDesc;
     GridLabelsConversionTableDesc * = RECORD(LayoutConversionTableDesc)
       convtable      * : LayoutConversionTable; (* The table this gridlabelstable belongs to. *)
       thickness      * : LONGREAL;
       color          * : col.Color;
       fontinfo       * : fo.FontInfo;
       usestdcolor    * ,
       usestdfont     * ,
       usestdthickness* : BOOLEAN;
     END;

TYPE FontNode * = POINTER TO FontNodeDesc;
     FontNodeDesc * = RECORD(l.NodeDesc)
       origname * ,
       convname * : ARRAY 128 OF CHAR;
       origpath * ,
       convpath * : ARRAY 128 OF CHAR;
     END;

PROCEDURE (convtable:LayoutConversionTable) Init*(task:m.Task);

VAR i : INTEGER;

BEGIN
  convtable.Init^(task);
  convtable.plotinfo:=NIL;
  NEW(convtable.linethickness,10);
  FOR i:=0 TO 9 DO convtable.linethickness[i]:=i; END;
  NEW(convtable.colors,16); (* Was very slow when using 256 entries. *)
  FOR i:=0 TO SHORT(LEN(convtable.colors^)-1) DO
    convtable.colors[i]:=col.black;
    convtable.colors[i].NewUser(task);
  END;
  convtable.stdpicx:=10;
  convtable.stdpicy:=10;
  convtable.fontlist:=NIL;

  IF ~(convtable IS GridLabelsConversionTable) THEN
    NEW(convtable.gridconv(GridLabelsConversionTable)); convtable.gridconv.Init(task);
    convtable.gridconv(GridLabelsConversionTable).convtable:=convtable;
    convtable.gridconv(GridLabelsConversionTable).plotinfo:=convtable.plotinfo;
    convtable.gridconv(GridLabelsConversionTable).usestdcolor:=FALSE;
    convtable.gridconv(GridLabelsConversionTable).thickness:=0;
    NEW(convtable.labelsconv(GridLabelsConversionTable)); convtable.labelsconv.Init(task);
    convtable.labelsconv(GridLabelsConversionTable).convtable:=convtable;
    convtable.labelsconv(GridLabelsConversionTable).plotinfo:=convtable.plotinfo;
  END;
END Init;

  PROCEDURE (convtable:GridLabelsConversionTable) Init*(task:m.Task);
  
  BEGIN
    convtable.Init^(task);
    convtable.thickness:=2;
    convtable.color:=col.black; convtable.color.NewUser(task);
    NEW(convtable.fontinfo); convtable.fontinfo.Init;
    convtable.usestdfont:=TRUE;
    convtable.usestdcolor:=TRUE;
    convtable.usestdthickness:=FALSE;
  END Init;
  
  PROCEDURE (convtable:GridLabelsConversionTable) Destruct*(task:m.Task);
  
  BEGIN
    IF convtable.color#NIL THEN convtable.color.FreeUser(task); END;
    IF convtable.fontinfo#NIL THEN convtable.fontinfo.Destruct; END;
    convtable.Destruct^(task);
  END Destruct;

PROCEDURE (convtable:LayoutConversionTable) Destruct*(task:m.Task);

VAR i : INTEGER;

BEGIN
  IF convtable.linethickness#NIL THEN DISPOSE(convtable.linethickness) END;
  IF convtable.colors#NIL THEN
    FOR i:=0 TO SHORT(LEN(convtable.colors^)-1) DO
      IF convtable.colors[i]#NIL THEN
        convtable.colors[i].FreeUser(task);
      END;
    END;
    DISPOSE(convtable.colors);
  END;
  IF convtable.fontlist#NIL THEN convtable.fontlist.Destruct; END;

  IF convtable.privatefont#NIL THEN convtable.privatefont.Destruct; END;
  convtable.Destruct^(task);
END Destruct;

PROCEDURE (convtable:LayoutConversionTable) SetColor*(num:LONGINT;color:l.Node);

BEGIN
  IF num<LEN(convtable.colors^) THEN
    IF convtable.colors[num]#NIL THEN convtable.colors[num].FreeUser(convtable.task); END;
    IF color#NIL THEN convtable.colors[num]:=color(col.Color);
                 ELSE convtable.colors[num]:=NIL; END;
    IF convtable.colors[num]#NIL THEN convtable.colors[num].NewUser(convtable.task); END;
  END;
END SetColor;

PROCEDURE (convtable:LayoutConversionTable) Copy*(dest:dc.ConversionTable);

VAR i : LONGINT;

BEGIN
  WITH dest: LayoutConversionTable DO
    IF convtable.linethickness#NIL THEN
      FOR i:=0 TO LEN(convtable.linethickness^)-1 DO
        dest.linethickness[i]:=convtable.linethickness[i];
      END;
    ELSE
      dest.linethickness:=NIL;
    END;
    IF convtable.colors#NIL THEN
      FOR i:=0 TO LEN(convtable.colors^)-1 DO
        dest.SetColor(i,convtable.colors[i]);
      END;
    ELSE
      dest.colors:=NIL;
    END;
    dest.stdpicx:=convtable.stdpicx;
    dest.stdpicy:=convtable.stdpicy;
    IF (convtable.gridconv#NIL) & (dest.gridconv#NIL) THEN
      convtable.gridconv.Copy(dest.gridconv);
    END;
    IF (convtable.labelsconv#NIL) & (dest.labelsconv#NIL) THEN
      convtable.labelsconv.Copy(dest.labelsconv);
    END;
  END;
END Copy;

PROCEDURE (convtable:GridLabelsConversionTable) Copy*(dest:dc.ConversionTable);

BEGIN
  WITH dest: GridLabelsConversionTable DO
    convtable.Copy^(dest);
    dest.thickness:=convtable.thickness;
    IF dest.color#NIL THEN dest.color.FreeUser(dest.task); END;
    dest.color:=convtable.color;
    IF dest.color#NIL THEN dest.color.FreeUser(dest.task); END;
    convtable.fontinfo.Copy(dest.fontinfo);
    dest.usestdthickness:=convtable.usestdthickness;
    dest.usestdcolor:=convtable.usestdcolor;
    dest.usestdfont:=convtable.usestdfont;
  END;
END Copy;

PROCEDURE (convtable:LayoutConversionTable) AllocPrivateFont*;

BEGIN
  NEW(convtable.privatefont); convtable.privatefont.Init;
END AllocPrivateFont;

PROCEDURE (convtable:LayoutConversionTable) SetPlotInfo*(plotinfo:pi.PlotInfo);

BEGIN
  convtable.plotinfo:=plotinfo;
  IF convtable.gridconv#NIL THEN convtable.gridconv(GridLabelsConversionTable).plotinfo:=plotinfo; END;
  IF convtable.labelsconv#NIL THEN convtable.labelsconv(GridLabelsConversionTable).plotinfo:=plotinfo; END;
END SetPlotInfo;

PROCEDURE (convtable:LayoutConversionTable) Changed*;
(* This procedure will copy the contents of the LayoutConversionTable record
   to the LayoutConversionTable.gridconv and .labelsconv records, since
   they must contain the same values!

   It will also send a msgNodeChanged to the ownder. *)

BEGIN
  IF convtable.gridconv#NIL THEN convtable.Copy(convtable.gridconv); END;
  IF convtable.labelsconv#NIL THEN convtable.Copy(convtable.labelsconv); END;
  IF convtable.task#NIL THEN convtable.task.SendNewMsg(m.msgNodeChanged,convtable); END;
END Changed;

PROCEDURE (convtable:GridLabelsConversionTable) Changed*;
(* This procedure will copy the contents of the LayoutConversionTable record
   to the LayoutConversionTable.gridconv and .labelsconv records, since
   they must contain the same values!

   It will also send a msgNodeChanged to the ownder. *)

BEGIN
  IF convtable.task#NIL THEN convtable.task.SendNewMsg(m.msgNodeChanged,convtable.convtable); END;
END Changed;

PROCEDURE (convtable:LayoutConversionTable) GetThicknessX*(thick:INTEGER):INTEGER;

VAR x,y : LONGINT;

BEGIN
  IF convtable.linethickness#NIL THEN
    IF LEN(convtable.linethickness^)>thick THEN
      convtable.plotinfo.CMToPic(pc.PtToCM(convtable.linethickness[thick]),0,x,y);
    ELSE
      convtable.plotinfo.CMToPic(pc.PtToCM(convtable.linethickness[0]),0,x,y);
    END;
  ELSE
    convtable.plotinfo.CMToPic(pc.PtToCM(thick),0,x,y);
  END;
  IF x=0 THEN x:=1; END;
  RETURN SHORT(x);
END GetThicknessX;

PROCEDURE (convtable:LayoutConversionTable) GetThicknessY*(thick:INTEGER):INTEGER;

VAR x,y : LONGINT;

BEGIN
  IF convtable.linethickness#NIL THEN
    IF LEN(convtable.linethickness^)>thick THEN
      convtable.plotinfo.CMToPic(pc.PtToCM(convtable.linethickness[thick]),0,x,y);
    ELSE
      convtable.plotinfo.CMToPic(pc.PtToCM(convtable.linethickness[0]),0,x,y);
    END;
  ELSE
    convtable.plotinfo.CMToPic(0,thick,x,y);
  END;
  IF y=0 THEN y:=1; END;
  RETURN SHORT(y);
END GetThicknessY;

PROCEDURE (convtable:LayoutConversionTable) GetColor*(pen:INTEGER;type:INTEGER):INTEGER;

VAR color : col.Color;

BEGIN
  IF (type=dc.textType) & (convtable.textcolor#NIL) THEN
    RETURN convtable.textcolor.SetColor(convtable.plotinfo,col.setNoPen);
  ELSIF (type=dc.graphType) & (convtable.graphcolor#NIL) THEN
    RETURN convtable.graphcolor.SetColor(convtable.plotinfo,col.setNoPen);
  ELSIF convtable.colors#NIL THEN
    IF LEN(convtable.colors^)>pen THEN
      color:=convtable.colors[pen];
    ELSE
      color:=convtable.colors[0];
    END;
    IF color#NIL THEN
      RETURN color.SetColor(convtable.plotinfo,col.setNoPen);
    ELSE
      RETURN pen;
    END;
  ELSE
    RETURN pen;
  END;
END GetColor;

PROCEDURE (convtable:LayoutConversionTable) GetStdPicX*():INTEGER;

BEGIN
  RETURN convtable.stdpicx;
END GetStdPicX;

PROCEDURE (convtable:LayoutConversionTable) GetStdPicY*():INTEGER;

BEGIN
  RETURN convtable.stdpicy;
END GetStdPicY;

PROCEDURE (convtable:LayoutConversionTable) GetFont*(font:fm.Font):fm.Font;

BEGIN
  IF convtable.privatefont#NIL THEN
    RETURN convtable.privatefont.Open();
  ELSIF convtable.fontlist=NIL THEN
    RETURN font;
  ELSE
    RETURN font;
  END;
END GetFont;



(* GridLabelsConversionTable methods *)

PROCEDURE (convtable:GridLabelsConversionTable) GetThicknessX*(thick:INTEGER):INTEGER;
(* Ignores given thick value! *)

VAR x,y : LONGINT;

BEGIN
  convtable.plotinfo.CMToPic(pc.PtToCM(convtable.thickness),0,x,y);
  IF x=0 THEN x:=1; END;
  RETURN SHORT(x);
END GetThicknessX;

PROCEDURE (convtable:GridLabelsConversionTable) GetThicknessY*(thick:INTEGER):INTEGER;
(* Ignores given thick value! *)

VAR x,y : LONGINT;

BEGIN
  convtable.plotinfo.CMToPic(0,pc.PtToCM(convtable.thickness),x,y);
  IF y=0 THEN y:=1; END;
  RETURN SHORT(y);
END GetThicknessY;

PROCEDURE (convtable:GridLabelsConversionTable) GetColor*(pen:INTEGER;type:INTEGER):INTEGER;
(* Ignores given pen number *)

VAR color : col.Color;

BEGIN
  IF convtable.color#NIL THEN
    color:=convtable.color;
    IF color#NIL THEN
      RETURN color.SetColor(convtable.plotinfo,col.setNoPen);
    ELSE
      RETURN pen;
    END;
  ELSE
    RETURN convtable.GetColor^(pen,type);
  END;
END GetColor;

PROCEDURE (convtable:GridLabelsConversionTable) GetFont*(font:fm.Font):fm.Font;

VAR newfont : fm.Font;

BEGIN
  IF convtable.fontinfo#NIL THEN
    newfont:=convtable.fontinfo.Open();
    IF newfont=NIL THEN
      newfont:=convtable.GetFont^(font);
    END;
  ELSE
    newfont:=convtable.GetFont^(font);
  END;
  RETURN newfont;
END GetFont;



(* Change conversion *)

VAR colorconvwind     * ,
    thicknessconvwind * ,
    gridconvwind      * ,
    labelsconvwind    * : wm.Window;

PROCEDURE (convtable:LayoutConversionTable) ChangeColor*(colortask:m.Task):BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    palette   : gmo.PaletteGadget;
    colorlv   : gmo.ListView;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    msg       : m.Message;
    class     : LONGSET;
    plotinfo  : pi.PlotInfo;
    actpen    : LONGINT;
    actcolor  : l.Node;
    savecols  : POINTER TO ARRAY OF col.Color;
    i         : INTEGER;
    ret,bool,
    didchange : BOOLEAN;

PROCEDURE RefreshColor;

BEGIN
  IF actcolor#NIL THEN
    colorlv.SetValue(col.colors.GetNodeNumber(actcolor));
  ELSE
    colorlv.Refresh;
  END;
END RefreshColor;

BEGIN
  col.colors.NewUser(colortask,TRUE);
  plotinfo:=col.AllocMinPlotInfo();
  NEW(mes);
  ret:=FALSE;
  IF colorconvwind=NIL THEN
    colorconvwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ColorConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=colorconvwind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    i:=s.LSH(1,mg.screenmode.depth); IF i>16 THEN i:=16; END;
    palette:=gmo.SetPaletteGadget(ac.GetString(ac.MathModeColor),mg.screenmode.depth,i,0);
    palette.SetSizeY(1);
    colorlv:=gmo.SetListView(ac.GetString(ac.DocumentColor),col.colors,col.PrintColor,0,FALSE,255);
    colorlv.SetUser(plotinfo);
    colorlv.SetSizeY(10);
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    plotinfo.rast:=rast;
    root.Resize;

    NEW(savecols,LEN(convtable.colors^));
    FOR i:=0 TO SHORT(LEN(savecols^)-1) DO
      savecols[i]:=convtable.colors[i];
      IF savecols[i]#NIL THEN savecols[i].NewUser(convtable.task); END;
    END;

    actpen:=0;
    actcolor:=convtable.colors[actpen];
    palette.SetValue(actpen);
    RefreshColor;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF colortask.msgsig IN class THEN
        REPEAT
          msg:=colortask.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              col.DestructMinPlotInfo(plotinfo); plotinfo:=NIL;
              subwind.Close;
              root.Resize;
            ELSIF msg.type=m.msgOpen THEN
              plotinfo:=col.AllocMinPlotInfo(); colorlv.SetUser(plotinfo);
              subwind.SetScreen(lb.screen);
              wind:=subwind.Open(NIL);
              IF wind#NIL THEN
                rast:=wind.rPort;
                root.Resize;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF (msg.type=m.msgNodeChanged) & (msg.data=convtable) THEN
              RefreshColor;
            ELSIF (msg.type=m.msgListChanged) & (msg.data=col.colors) THEN
              IF ((actcolor#NIL) & mem.Garbaged(actcolor)) OR (actcolor=NIL) THEN
                actcolor:=col.colors.head;
                convtable.colors[actpen]:=actcolor(col.Color);
              END;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            FOR i:=0 TO SHORT(LEN(savecols^)-1) DO
              IF convtable.colors[i]#NIL THEN convtable.colors[i].FreeUser(convtable.task); END;
              convtable.colors[i]:=savecols[i];
              IF convtable.colors[i]#NIL THEN convtable.colors[i].NewUser(convtable.task); END;
            END;
            IF didchange THEN convtable.Changed; END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=palette.gadget THEN
            actpen:=palette.GetValue();
            actcolor:=convtable.colors[actpen];
            RefreshColor;
            didchange:=TRUE; convtable.Changed;
          ELSIF mes.iAddress=colorlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actcolor:=col.colors.GetNode(colorlv.GetValue());
              IF convtable.colors[actpen]#NIL THEN convtable.colors[actpen].FreeUser(convtable.task); END;
              IF actcolor#NIL THEN
                convtable.colors[actpen]:=actcolor(col.Color);
              ELSIF col.colors.nbElements()>0 THEN
                convtable.colors[actpen]:=col.colors.head(col.Color);
              ELSE
                convtable.colors[actpen]:=NIL;
              END;
              IF convtable.colors[actpen]#NIL THEN convtable.colors[actpen].FreeUser(convtable.task); END;
              didchange:=TRUE; convtable.Changed;
            END;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"colorconvert",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;

    IF savecols#NIL THEN
      FOR i:=0 TO SHORT(LEN(savecols^)-1) DO
        IF savecols[i]#NIL THEN savecols[i].FreeUser(convtable.task); END;
      END;
    END;
  END;
  root.Destruct;
  DISPOSE(mes);
  IF plotinfo#NIL THEN col.DestructMinPlotInfo(plotinfo); END;
  col.colors.FreeUser(colortask);
  RETURN ret;
END ChangeColor;

PROCEDURE ChangeColorTask*(colortask:bas.ANY):bas.ANY;

VAR data : LayoutConversionTable;
    bool : BOOLEAN;

BEGIN
  WITH colortask: m.Task DO
    colortask.InitCommunication;
    data:=colortask.data(LayoutConversionTable);
    bool:=data.ChangeColor(colortask);

    m.taskdata.layouttask.RemTask(colortask);
    colortask.ReplyAllMessages;
    colortask.DestructCommunication;
    mem.NodeToGarbage(colortask);
    m.taskdata.layouttask.FreeUser(colortask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeColorTask;

PROCEDURE (convtable:LayoutConversionTable) ChangeThickness*(thicknesstask:m.Task):BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    maththick : gmo.SelectBox;
    thickstr  : gmo.StringGadget;
    thickslide: gmo.SliderGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    msg       : m.Message;
    class     : LONGSET;
    savethickness : POINTER TO ARRAY OF LONGREAL;
    actthick,
    i         : INTEGER;
    ret,bool,
    didchange : BOOLEAN;

  PROCEDURE SetData;
  
  BEGIN
    thickstr.SetReal(convtable.linethickness[actthick]);
    thickslide.SetValue(SHORT(SHORT(convtable.linethickness[actthick])));
  END SetData;
  
  PROCEDURE GetStringInput;
  
  BEGIN
    convtable.linethickness[actthick]:=thickstr.GetReal();
    thickslide.SetValue(SHORT(SHORT(convtable.linethickness[actthick])));
  END GetStringInput;
  
  PROCEDURE Backup;

  BEGIN
    FOR i:=0 TO SHORT(LEN(convtable.linethickness^)-1) DO
      savethickness[i]:=convtable.linethickness[i];
    END;
  END Backup;

  PROCEDURE Restore;

  BEGIN
    FOR i:=0 TO SHORT(LEN(convtable.linethickness^)-1) DO
      convtable.linethickness[i]:=savethickness[i];;
    END;
  END Restore;

BEGIN
  actthick:=0;
  savethickness:=NIL;
  NEW(savethickness,LEN(convtable.linethickness^));
  NEW(mes);
  ret:=FALSE;
  IF thicknessconvwind=NIL THEN
    thicknessconvwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.LineThicknessConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=thicknessconvwind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    maththick:=gmo.SetSelectBox(ac.GetString(ac.MathModeThickness),5,0,2,3,16*4,mg.window.rPort.txHeight*7 DIV 8,-1,gmo.vertOrient,go.PlotThicknessLine);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.PrintThickness));
      thickstr:=gmo.SetStringGadget(NIL,5,gmo.realType);
      thickstr.SetMinVisible(4);
      thickstr.SetSizeX(0);
      thickstr.SetMinMaxReal(0,10);
      thickslide:=gmo.SetSliderGadget(0,10,SHORT(SHORT(convtable.linethickness[actthick])),0,NIL);
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    SetData;
    thickstr.Activate;

    Backup;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF thicknesstask.msgsig IN class THEN
        REPEAT
          msg:=thicknesstask.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              subwind.Close;
              root.Resize;
            ELSIF msg.type=m.msgOpen THEN
              subwind.SetScreen(lb.screen);
              wind:=subwind.Open(NIL);
              IF wind#NIL THEN
                rast:=wind.rPort;
                root.Resize;
                thickstr.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF (msg.type=m.msgNodeChanged) & (msg.data=convtable) THEN
              SetData;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetStringInput;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            Restore;
            IF didchange THEN convtable.Changed; END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=maththick THEN
            actthick:=SHORT(maththick.GetValue());
            SetData;
            didchange:=TRUE; convtable.Changed;
          ELSIF mes.iAddress=thickslide.gadget THEN
            convtable.linethickness[actthick]:=thickslide.GetValue();
            SetData;
            didchange:=TRUE; convtable.Changed;
          ELSIF ~(mes.iAddress=root.help) THEN
            GetStringInput;
            didchange:=TRUE; convtable.Changed;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"widthconvert",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  IF savethickness#NIL THEN DISPOSE(savethickness); END;
  RETURN ret;
END ChangeThickness;

PROCEDURE ChangeThicknessTask*(thicknesstask:bas.ANY):bas.ANY;

VAR data : LayoutConversionTable;
    bool : BOOLEAN;

BEGIN
  WITH thicknesstask: m.Task DO
    thicknesstask.InitCommunication;
    data:=thicknesstask.data(LayoutConversionTable);
    bool:=data.ChangeThickness(thicknesstask);

    m.taskdata.layouttask.RemTask(thicknesstask);
    thicknesstask.ReplyAllMessages;
    thicknesstask.DestructCommunication;
    mem.NodeToGarbage(thicknesstask);
    m.taskdata.layouttask.FreeUser(thicknesstask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeThicknessTask;



PROCEDURE (convtable:GridLabelsConversionTable) ChangeGrid*(gridtask:m.Task):BOOLEAN;

(* gridtask should be NIL when not started as separate task! *)

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    colorgad  : gme.FieldSelect;
    colorstd  : gmo.CheckboxGadget;
    thickstr  : gmo.StringGadget;
    thickslide: gmo.SliderGadget;
    thickstd  : gmo.CheckboxGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    msg       : m.Message;
    class     : LONGSET;
    node      : l.Node;
    plotinfo  : pi.PlotInfo;
    i         : INTEGER;
    savethickness : LONGREAL;
    savecolor : col.Color;
    saveusestdcolor,
    saveusestdthickness : BOOLEAN;
    ret,bool,
    didchange : BOOLEAN;

  PROCEDURE SetData;
  
  BEGIN
    io.WriteString("LConvGC1\n");
    colorgad.SetValue(col.colors.GetNodeNumber(convtable.color));
    io.WriteString("LConvGC2\n");
    colorstd.Check(convtable.usestdcolor);
    io.WriteString("LConvGC3\n");
    thickstr.SetReal(convtable.thickness);
    io.WriteString("LConvGC4\n");
    thickslide.SetValue(SHORT(SHORT(convtable.thickness)));
    io.WriteString("LConvGC5\n");
    thickstd.Check(convtable.usestdthickness);
    io.WriteString("LConvGC6\n");
  END SetData;
  
  PROCEDURE GetStringInput;
  
  BEGIN
    convtable.thickness:=thickstr.GetReal();
    thickslide.SetValue(SHORT(SHORT(convtable.thickness)));
  END GetStringInput;

  PROCEDURE GetInput;

  BEGIN
    convtable.usestdcolor:=colorstd.Checked();
    convtable.usestdthickness:=thickstd.Checked();
  END GetInput;

  PROCEDURE Backup;

  BEGIN
    savethickness:=convtable.thickness;
    savecolor:=convtable.color;
    IF savecolor#NIL THEN savecolor.NewUser(convtable.task); END;
    saveusestdcolor:=convtable.usestdcolor;
    saveusestdthickness:=convtable.usestdthickness;
  END Backup;

  PROCEDURE Restore;

  BEGIN
    convtable.thickness:=savethickness;
    IF convtable.color#NIL THEN convtable.color.FreeUser(convtable.task); END;
    convtable.color:=savecolor;
    IF convtable.color#NIL THEN convtable.color.NewUser(convtable.task); END;
    convtable.usestdcolor:=saveusestdcolor;
    convtable.usestdthickness:=saveusestdthickness;
  END Restore;

BEGIN
  plotinfo:=col.AllocMinPlotInfo();
  NEW(mes);
  ret:=FALSE;
  IF gridconvwind=NIL THEN
    gridconvwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.BackgroundGridConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=gridconvwind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Color));
      colorgad:=gme.SetFieldSelect(NIL,col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(convtable.color)),FALSE,plotinfo);
      colorgad.SetMinVisible(10);
      colorstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),convtable.usestdcolor);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.LineThickness));
      thickstr:=gmo.SetStringGadget(NIL,5,gmo.realType);
      thickstr.SetMinVisible(4);
      thickstr.SetSizeX(0);
      thickstr.SetMinMaxReal(0,10);
      thickslide:=gmo.SetSliderGadget(0,10,SHORT(SHORT(convtable.thickness)),0,NIL);
      thickstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),convtable.usestdthickness);
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    SetData;
    thickstr.Activate;

    Backup;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF gridtask#NIL THEN
        IF gridtask.msgsig IN class THEN
          REPEAT
            msg:=gridtask.ReceiveMsg();
            IF msg#NIL THEN
              IF msg.type=m.msgQuit THEN
                msg.Reply;
                EXIT;
              ELSIF msg.type=m.msgClose THEN
                col.DestructMinPlotInfo(plotinfo); plotinfo:=NIL;
                subwind.Close;
                root.Resize;
              ELSIF msg.type=m.msgOpen THEN
                plotinfo:=col.AllocMinPlotInfo(); colorgad.SetUser(plotinfo);
                subwind.SetScreen(lb.screen);
                wind:=subwind.Open(NIL);
                IF wind#NIL THEN
                  rast:=wind.rPort;
                  root.Resize;
                  thickstr.Activate;
                ELSE
                  msg.Reply;
                  EXIT;
                END;
              ELSIF (msg.type=m.msgNodeChanged) & (msg.data=convtable) THEN
                SetData;
              ELSIF msg.type=m.msgActivate THEN
                subwind.ToFront;
              END;
              msg.Reply;
            END;
          UNTIL msg=NIL;
        END;
      END;
      REPEAT
        root.GetIMes(mes);
        GetInput;
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetStringInput;
            convtable.Changed;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            Restore;
            IF didchange THEN convtable.Changed; END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=colorgad.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectGridColor),ac.GetString(ac.Color),s.ADR("No colors found!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              IF convtable.color#NIL THEN convtable.color.FreeUser(convtable.task); END;
              convtable.color:=node(col.Color);
              IF convtable.color#NIL THEN convtable.color.FreeUser(convtable.task); END;
              SetData;
              didchange:=TRUE; convtable.Changed;
            END;
          ELSIF mes.iAddress=thickslide.gadget THEN
            convtable.thickness:=thickslide.GetValue();
            SetData;
            didchange:=TRUE; convtable.Changed;
          ELSIF ~(mes.iAddress=root.help) THEN
            GetStringInput;
            didchange:=TRUE; convtable.Changed;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"gridconvert",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
    IF savecolor#NIL THEN savecolor.FreeUser(convtable.task); END;
  END;
  root.Destruct;
  DISPOSE(mes);
  IF plotinfo#NIL THEN col.DestructMinPlotInfo(plotinfo); END;
  RETURN ret;
END ChangeGrid;

PROCEDURE ChangeGridTask*(gridtask:bas.ANY):bas.ANY;

VAR data : LayoutConversionTable;
    bool : BOOLEAN;

BEGIN
  WITH gridtask: m.Task DO
    gridtask.InitCommunication;
    data:=gridtask.data(LayoutConversionTable);
    bool:=data.gridconv(GridLabelsConversionTable).ChangeGrid(gridtask);

    m.taskdata.layouttask.RemTask(gridtask);
    gridtask.ReplyAllMessages;
    gridtask.DestructCommunication;
    mem.NodeToGarbage(gridtask);
    m.taskdata.layouttask.FreeUser(gridtask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeGridTask;

PROCEDURE (convtable:GridLabelsConversionTable) ChangeLabels*(labelstask:m.Task):BOOLEAN;

(* gridtask should be NIL when not started as separate task! *)

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    fontgad,
    colorgad  : gme.FieldSelect;
    fontstd,
    colorstd  : gmo.CheckboxGadget;
    thickstr  : gmo.StringGadget;
    thickslide: gmo.SliderGadget;
    thickstd  : gmo.CheckboxGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    msg       : m.Message;
    class     : LONGSET;
    node      : l.Node;
    plotinfo  : pi.PlotInfo;
    i         : INTEGER;
    savefontinfo        : fo.FontInfo;
    savethickness       : LONGREAL;
    savecolor           : col.Color;
    saveusestdfont,
    saveusestdcolor,
    saveusestdthickness : BOOLEAN;
    ret,bool,
    didchange : BOOLEAN;

  PROCEDURE SetData;
  
  BEGIN
    fontgad.SetUser(convtable.fontinfo);
    fontstd.Check(convtable.usestdfont);
    colorgad.SetValue(col.colors.GetNodeNumber(convtable.color));
    colorstd.Check(convtable.usestdcolor);
    thickstr.SetReal(convtable.thickness);
    thickslide.SetValue(SHORT(SHORT(convtable.thickness)));
    thickstd.Check(convtable.usestdthickness);
  END SetData;
  
  PROCEDURE GetStringInput;
  
  BEGIN
    convtable.thickness:=thickstr.GetReal();
    thickslide.SetValue(SHORT(SHORT(convtable.thickness)));
  END GetStringInput;

  PROCEDURE GetInput;

  BEGIN
    convtable.usestdfont:=fontstd.Checked();
    convtable.usestdcolor:=colorstd.Checked();
    convtable.usestdthickness:=thickstd.Checked();
  END GetInput;

  PROCEDURE Backup;

  BEGIN
    convtable.fontinfo.Copy(savefontinfo);
    savethickness:=convtable.thickness;
    savecolor:=convtable.color;
    IF savecolor#NIL THEN savecolor.NewUser(convtable.task); END;
    saveusestdfont:=convtable.usestdfont;
    saveusestdcolor:=convtable.usestdcolor;
    saveusestdthickness:=convtable.usestdthickness;
  END Backup;

  PROCEDURE Restore;

  BEGIN
    savefontinfo.Copy(convtable.fontinfo);
    convtable.thickness:=savethickness;
    IF convtable.color#NIL THEN convtable.color.FreeUser(convtable.task); END;
    convtable.color:=savecolor;
    IF convtable.color#NIL THEN convtable.color.NewUser(convtable.task); END;
    convtable.usestdfont:=saveusestdfont;
    convtable.usestdcolor:=saveusestdcolor;
    convtable.usestdthickness:=saveusestdthickness;
  END Restore;

BEGIN
  plotinfo:=col.AllocMinPlotInfo();
  NEW(mes);
  ret:=FALSE;
  IF labelsconvwind=NIL THEN
    labelsconvwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.AxisSystemConversion),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=labelsconvwind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Font));
      fontgad:=gme.SetFieldSelect(NIL,NIL,fo.PrintFontInfo,0,FALSE,convtable.fontinfo);
      fontgad.SetMinVisible(10);
      fontstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),convtable.usestdfont);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Color));
      colorgad:=gme.SetFieldSelect(NIL,col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(convtable.color)),FALSE,plotinfo);
      colorgad.SetMinVisible(10);
      colorstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),convtable.usestdcolor);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.LineThickness));
      thickstr:=gmo.SetStringGadget(NIL,5,gmo.realType);
      thickstr.SetMinVisible(4);
      thickstr.SetSizeX(0);
      thickstr.SetMinMaxReal(0,10);
      thickslide:=gmo.SetSliderGadget(0,10,SHORT(SHORT(convtable.thickness)),0,NIL);
      thickstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),convtable.usestdthickness);
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    SetData;
    thickstr.Activate;

    NEW(savefontinfo); savefontinfo.Init;
    Backup;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF labelstask#NIL THEN
        IF labelstask.msgsig IN class THEN
          REPEAT
            msg:=labelstask.ReceiveMsg();
            IF msg#NIL THEN
              IF msg.type=m.msgQuit THEN
                msg.Reply;
                EXIT;
              ELSIF msg.type=m.msgClose THEN
                col.DestructMinPlotInfo(plotinfo); plotinfo:=NIL;
                subwind.Close;
                root.Resize;
              ELSIF msg.type=m.msgOpen THEN
                plotinfo:=col.AllocMinPlotInfo(); colorgad.SetUser(plotinfo);
                subwind.SetScreen(lb.screen);
                wind:=subwind.Open(NIL);
                IF wind#NIL THEN
                  rast:=wind.rPort;
                  root.Resize;
                  thickstr.Activate;
                ELSE
                  msg.Reply;
                  EXIT;
                END;
              ELSIF (msg.type=m.msgNodeChanged) & (msg.data=convtable) THEN
                SetData;
              ELSIF msg.type=m.msgActivate THEN
                subwind.ToFront;
              END;
              msg.Reply;
            END;
          UNTIL msg=NIL;
        END;
      END;
      REPEAT
        root.GetIMes(mes);
        GetInput;
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetStringInput;
            convtable.Changed;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            Restore;
            IF didchange THEN convtable.Changed; END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=fontgad.gadget THEN
            bool:=convtable.fontinfo.SelectFont(labelstask,lb.screen);
            fontgad.Refresh;
            didchange:=TRUE; convtable.Changed;
          ELSIF mes.iAddress=colorgad.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectGridColor),ac.GetString(ac.Color),s.ADR("No colors found!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              IF convtable.color#NIL THEN convtable.color.FreeUser(convtable.task); END;
              convtable.color:=node(col.Color);
              IF convtable.color#NIL THEN convtable.color.FreeUser(convtable.task); END;
              SetData;
              didchange:=TRUE; convtable.Changed;
            END;
          ELSIF mes.iAddress=thickslide.gadget THEN
            convtable.thickness:=thickslide.GetValue();
            SetData;
            didchange:=TRUE; convtable.Changed;
          ELSIF ~(mes.iAddress=root.help) THEN
            GetStringInput;
            didchange:=TRUE; convtable.Changed;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"gridconvert",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
    IF savefontinfo#NIL THEN savefontinfo.Destruct; END;
    IF savecolor#NIL THEN savecolor.FreeUser(convtable.task); END;
  END;
  root.Destruct;
  DISPOSE(mes);
  IF plotinfo#NIL THEN col.DestructMinPlotInfo(plotinfo); END;
  RETURN ret;
END ChangeLabels;

PROCEDURE ChangeLabelsTask*(labelstask:bas.ANY):bas.ANY;

VAR data : LayoutConversionTable;
    bool : BOOLEAN;

BEGIN
  WITH labelstask: m.Task DO
    labelstask.InitCommunication;
    data:=labelstask.data(LayoutConversionTable);
    bool:=data.gridconv(GridLabelsConversionTable).ChangeLabels(labelstask);

    m.taskdata.layouttask.RemTask(labelstask);
    labelstask.ReplyAllMessages;
    labelstask.DestructCommunication;
    mem.NodeToGarbage(labelstask);
    m.taskdata.layouttask.FreeUser(labelstask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeLabelsTask;

BEGIN
  colorconvwind:=NIL;
  thicknessconvwind:=NIL;
  gridconvwind:=NIL;
  labelsconvwind:=NIL;
END LayoutConversion.

