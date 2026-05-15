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


MODULE GraphWindowBox;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       gd : GadTools,
       s  : SYSTEM,
       l  : LinkedLists,
       ag : AmigaGuideTools,
       wm : WindowManager,
       fo : FontOrganizer,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       m  : Multitasking,
       gb : GeneralBasics,
       co : Coords,
       gw : GraphWindow,
       lg : LayoutGUI,
       lc : LayoutConversion,
       col: Colors,
       pi : PlotInfo,
       bo : Box,
       ac : AnalayCatalog,
       io,
       NoGuruRq;

TYPE GraphWindowBox * = POINTER TO GraphWindowBoxDesc;
     GraphWindowBoxDesc * = RECORD(bo.BoxDesc)
       graphwind   * : gw.GraphWindow;
       unitx,unity,                    (* See Adapt-Requester *)
       cmx,cmy       : LONGREAL;
       unitxs,unitys,
       cmxs,cmys     : ARRAY 256 OF CHAR;
       textfont      : fo.FontInfo;    (* The bo.Box.stdfontinfo field is used to store a copy of the axis labels font! Therefore this new entry keeps the font of all other texts. *)
       textcolor,
       graphcolor    : col.Color;
       gridconv,
       labelsconv    : lc.GridLabelsConversionTable;
       usestdtextfont,
       usestdtextcol,
       usestdgraphcol,
       usestdgrid,
       usestdlabels  : BOOLEAN;
     END;

PROCEDURE (gwbox:GraphWindowBox) Init*;

BEGIN
  gwbox.Init^;
  NEW(gwbox.textfont); gwbox.textfont.Init;
  gwbox.textcolor:=col.stdcolor;
  gwbox.graphcolor:=col.stdcolor;
  IF gwbox.textcolor#NIL THEN gwbox.textcolor.NewUser(gwbox.task); END;
  IF gwbox.graphcolor#NIL THEN gwbox.graphcolor.NewUser(gwbox.task); END;
  NEW(gwbox.gridconv); gwbox.gridconv.Init(gwbox.task);
  NEW(gwbox.labelsconv); gwbox.labelsconv.Init(gwbox.task);
  gwbox.usestdtextfont:=TRUE;
  gwbox.usestdtextcol:=TRUE;
  gwbox.usestdgraphcol:=TRUE;
  gwbox.usestdgrid:=TRUE;
  gwbox.usestdlabels:=TRUE;
  gwbox.unitx:=1; gwbox.unity:=1;
  gwbox.cmx:=1;   gwbox.cmy:=1;
  gwbox.unitxs:="1"; gwbox.unitys:="1";
  gwbox.cmxs:="1";   gwbox.cmys:="1";
END Init;

PROCEDURE (gwbox:GraphWindowBox) Destruct*;

BEGIN
  IF gwbox.textfont#NIL THEN gwbox.textfont.Destruct; END;
  IF gwbox.textcolor#NIL THEN gwbox.textcolor.FreeUser(gwbox.task); END;
  IF gwbox.graphcolor#NIL THEN gwbox.graphcolor.FreeUser(gwbox.task); END;
  IF gwbox.gridconv#NIL THEN gwbox.gridconv.Destruct(gwbox.task); END;
  IF gwbox.labelsconv#NIL THEN gwbox.labelsconv.Destruct(gwbox.task); END;

  IF gwbox.graphwind#NIL THEN gwbox.graphwind.FreeUser(gwbox.task); END; (* gwbox.task=Document *)
  gwbox.Destruct^;
END Destruct;

PROCEDURE (gwbox:GraphWindowBox) InitCoords*(maxwidth,maxheight:LONGREAL);

BEGIN
  gwbox.width:=SHORT(SHORT(ABS(gwbox.graphwind.coordsystem(co.CartesianSystem).xmax-gwbox.graphwind.coordsystem(co.CartesianSystem).xmin)));
  gwbox.height:=SHORT(SHORT(ABS(gwbox.graphwind.coordsystem(co.CartesianSystem).ymax-gwbox.graphwind.coordsystem(co.CartesianSystem).ymin)));
  WHILE (gwbox.width>maxwidth) OR (gwbox.width>10) DO
    gwbox.width:=gwbox.width/2;
  END;
  WHILE (gwbox.height>maxheight) OR (gwbox.height>10) DO
    gwbox.height:=gwbox.height/2;
  END;
END InitCoords;

PROCEDURE (gwbox:GraphWindowBox) SetTextColor*(color:col.Color);

BEGIN
  IF gwbox.textcolor#NIL THEN gwbox.textcolor.FreeUser(gwbox.task); END;
  gwbox.textcolor:=color;
  IF gwbox.textcolor#NIL THEN gwbox.textcolor.NewUser(gwbox.task); END;
END SetTextColor;

PROCEDURE (gwbox:GraphWindowBox) SetGraphColor*(color:col.Color);

BEGIN
  IF gwbox.graphcolor#NIL THEN gwbox.graphcolor.FreeUser(gwbox.task); END;
  gwbox.graphcolor:=color;
  IF gwbox.graphcolor#NIL THEN gwbox.graphcolor.NewUser(gwbox.task); END;
END SetGraphColor;

PROCEDURE (box:GraphWindowBox) SetUseStdFont*(usestdfont:BOOLEAN);

BEGIN
  box.labelsconv.usestdfont:=usestdfont;
END SetUseStdFont;

PROCEDURE (box:GraphWindowBox) GetUseStdFont*():BOOLEAN;

BEGIN
  RETURN box.labelsconv.usestdfont;
END GetUseStdFont;

PROCEDURE (box:GraphWindowBox) SetFontInfo*(fontinfo:fo.FontInfo);
(* COPIES the contents of the given fontinfo record to the boxes
   local stdfontinfo element. Does NOT store the pointer to given fontinfo!
   -> given fontinfo has to be allocated before calling this method!

   Redefinition of this method may store the data anywhere else than
   box.stdfontinfo. *)

BEGIN
  IF (box.stdfontinfo#NIL) & (fontinfo#NIL) THEN
    fontinfo.Copy(box.labelsconv.fontinfo);
    box.labelsconv.usestdfont:=FALSE;
  END;
END SetFontInfo;

PROCEDURE (box:GraphWindowBox) GetFontInfo*(fontinfo:fo.FontInfo);
(* COPIES the contents of stdfontinfo to the given fontinfo record.
   Does NOT changethe given pointer!
   -> given fontinfo has to be allocated before calling this method!

   Redefinition of this method may store the data anywhere else than
   box.stdfontinfo. *)

BEGIN
  IF (box.labelsconv.fontinfo#NIL) & (fontinfo#NIL) THEN
    box.labelsconv.fontinfo.Copy(fontinfo);
  END;
END GetFontInfo;

PROCEDURE (gwbox:GraphWindowBox) FontAble*():BOOLEAN;

BEGIN
  RETURN TRUE;
END FontAble;

PROCEDURE (gwbox:GraphWindowBox) Plot*(plotinfo:pi.PlotInfo);

VAR rast        : g.RastPortPtr;
    rect        : co.Rectangle;
    conv        : lc.LayoutConversionTable;
    picx,picy,
    picwi,piche : INTEGER;
    x,y         : LONGINT;

BEGIN
  IF gwbox.graphwind#NIL THEN
    IF gwbox.quickdisp THEN
      gwbox.QuickPlot(plotinfo);
    ELSE

(* Initializing conversion table (local one for proper use of font, color, etc. ) *)

      NEW(conv); conv.Init(NIL);
      conv.SetPlotInfo(plotinfo);
      plotinfo.conv.Copy(conv);
      IF ~gwbox.usestdgrid THEN
        io.WriteString("Using private grid\n");
        gwbox.gridconv.Copy(conv.gridconv);
      END;
      IF ~gwbox.usestdlabels THEN
        gwbox.gridconv.Copy(conv.labelsconv);
      END;
      IF ~gwbox.usestdtextfont THEN
        conv.AllocPrivateFont;
        gwbox.textfont.Copy(conv.privatefont);
      END;
      IF ~gwbox.usestdtextcol THEN
        conv.textcolor:=gwbox.textcolor;
      END;
      IF ~gwbox.usestdgraphcol THEN
        conv.graphcolor:=gwbox.graphcolor;
      END;
(*      IF (~gwbox.usestdfont) & (gwbox.stdfontinfo#NIL) THEN
        gwbox.stdfontinfo.Copy(conv.labelsconv(lc.GridLabelsConversionTable).fontinfo);
        conv.labelsconv(lc.GridLabelsConversionTable).usestdfont:=FALSE;
      END;*) (* Now directly stored in gwbox.labelsconv.fontinfo! *)

      gwbox.graphwind.Lock(FALSE);
      NEW(rect);
      rast:=plotinfo.rast;
      plotinfo.CMToPicRect(gwbox.xpos,gwbox.ypos,x,y,NIL);
      rect.xoff:=SHORT(x); rect.yoff:=SHORT(y);
      plotinfo.CMToPic(gwbox.width,gwbox.height,x,y);
      rect.width:=SHORT(x)+1; rect.height:=SHORT(y)+1;
  
      gwbox.graphwind.Plot(plotinfo.rast,rect,conv,FALSE);
    
      DISPOSE(rect);
      IF conv#NIL THEN conv.Destruct(NIL); END;
      gwbox.graphwind.UnLock;
    END;
  END;
END Plot;

PROCEDURE (box:GraphWindowBox) AdaptCoords*(unitx,unity,cmx,cmy:LONGREAL);
(* The width and height of the box is calculated so that the
   a unitx of the graph will be exactly cmx centimeters on the paper
   (similar to y). *)

VAR distx,disty : LONGREAL;
    coords      : co.CoordSystem;

BEGIN
  coords:=box.graphwind.coordsystem;
  WITH coords: co.CartesianSystem DO
    distx:=coords.xmax-coords.xmin;
    disty:=coords.ymax-coords.ymin;
    box.width:=cmx/unitx*distx;
    box.height:=cmy/unity*disty;
    box.UpdateCoordStrings;
  END;
END AdaptCoords;

VAR adaptcoordswind    * ,
    changegraphwindbox * : wm.Window;


PROCEDURE (box:GraphWindowBox) ChangeAdaptCoords*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    text       : gmo.Text;
    unitxgad,
    unitygad,
    cmxgad,
    cmygad     : gmo.StringGadget;
    gadobj     : gmb.Object;
    gadbox1,
    gadbox2    : gmb.Box;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    msg        : m.Message;
    class      : LONGSET;
    unitx,unity,
    cmx,cmy    : LONGREAL;
    bool,ret,
    didchange  : BOOLEAN;

  PROCEDURE GetInput;

  BEGIN
    unitxgad.GetString(box.unitxs); box.unitx:=unitxgad.real;
    unitygad.GetString(box.unitys); box.unity:=unitygad.real;
    cmxgad.GetString(box.cmxs); box.cmx:=cmxgad.real;
    cmygad.GetString(box.cmys); box.cmy:=cmygad.real;
  END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF adaptcoordswind=NIL THEN
    adaptcoordswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.AdaptBoxSize),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=adaptcoordswind.InitSub(lg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadbox1:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.XAxis));
      unitxgad:=gmo.SetStringGadget(NIL,255,gmo.realType);
      unitxgad.SetMinVisible(5);
      unitxgad.SetMinMaxReal(0.1,1000);
      text:=gmo.SetText(ac.GetString(ac.units),-1);
      text:=gmo.SetText(s.ADR(" ->"),-1);
      cmxgad:=gmo.SetStringGadget(NIL,255,gmo.realType);
      cmxgad.SetMinVisible(5);
      cmxgad.SetMinMaxReal(0.1,1000);
      text:=gmo.SetText(ac.GetString(ac.cm),-1);
    gmb.EndBox;
    gadbox2:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.YAxis));
      unitygad:=gmo.SetStringGadget(NIL,255,gmo.realType);
      unitygad.SetMinVisible(5);
      unitygad.SetMinMaxReal(0.1,1000);
      text:=gmo.SetText(ac.GetString(ac.units),-1);
      text:=gmo.SetText(s.ADR(" ->"),-1);
      cmygad:=gmo.SetStringGadget(NIL,255,gmo.realType);
      cmygad.SetMinVisible(5);
      cmygad.SetMinMaxReal(0.1,1000);
      text:=gmo.SetText(ac.GetString(ac.cm),-1);
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;
  gadbox1.SetSizeY(-1);
  gadbox2.SetSizeY(-1);

  unitxgad.SetString(box.unitxs);
  unitygad.SetString(box.unitys);
  cmxgad.SetString(box.cmxs);
  cmygad.SetString(box.cmys);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    unitxgad.Activate;

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
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetInput;
            box.AdaptCoords(box.unitx,box.unity,box.cmx,box.cmy);
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            ret:=FALSE;
            EXIT;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"changegrid",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END ChangeAdaptCoords;

PROCEDURE (gwbox:GraphWindowBox) ChangeContents*(changetask:m.Task):BOOLEAN;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    labelsgad,
    gridgad     : gmo.BooleanGadget;
    fontgad,
    textcolgad,
    graphcolgad : gme.FieldSelect;
    fontstd,
    textcolstd,
    graphcolstd,
    labelsstd,
    gridstd     : gmo.CheckboxGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    msg         : m.Message;
    class       : LONGSET;
    plotinfo    : pi.PlotInfo;
    node        : l.Node;
    bool,ret    : BOOLEAN;

PROCEDURE GetInput;

BEGIN
  gwbox.usestdtextfont:=fontstd.Checked();
  gwbox.usestdtextcol:=textcolstd.Checked();
  gwbox.usestdgraphcol:=graphcolstd.Checked();
  gwbox.usestdlabels:=labelsstd.Checked();
  gwbox.usestdgrid:=gridstd.Checked();
END GetInput;

BEGIN
  plotinfo:=col.AllocMinPlotInfo();
  NEW(mes);
  ret:=FALSE;
  IF changegraphwindbox=NIL THEN
    changegraphwindbox:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeBoxContents),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changegraphwindbox.InitSub(lg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.BoxContents));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Font));
        fontgad:=gme.SetFieldSelect(NIL,NIL,fo.PrintFontInfo,0,FALSE,gwbox.textfont);
        fontgad.SetMinVisible(10);
        fontstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),gwbox.usestdtextfont);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.TextColor));
        textcolgad:=gme.SetFieldSelect(NIL,col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(gwbox.textcolor)),FALSE,plotinfo);
        textcolgad.SetMinVisible(10);
        textcolstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),gwbox.usestdtextcol);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.GraphicColor));
        graphcolgad:=gme.SetFieldSelect(NIL,col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(gwbox.graphcolor)),FALSE,plotinfo);
        graphcolgad.SetMinVisible(10);
        graphcolstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),gwbox.usestdgraphcol);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        labelsgad:=gmo.SetBooleanGadget(ac.GetString(ac.AxisSystem),FALSE);
        labelsstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),gwbox.usestdlabels);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        gridgad:=gmo.SetBooleanGadget(ac.GetString(ac.BackgroundGrid),FALSE);
        gridstd:=gmo.SetCheckboxGadget(ac.GetString(ac.Default),gwbox.usestdgrid);
      gmb.EndBox;
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    plotinfo.rast:=rast;
    root.Resize;

    LOOP
      class:=e.Wait(LONGSET{0..31});
(*      IF gridtask.msgsig IN class THEN (* Care of plotinfo when reactivating this passage (screen change etc.) *)
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
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetInput;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=fontgad.gadget THEN
            bool:=gwbox.textfont.SelectFont(changetask,lg.screen);
            fontgad.Refresh;
          ELSIF mes.iAddress=textcolgad.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectTextColor),ac.GetString(ac.TextColor),s.ADR("No colors are entered at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              IF gwbox.textcolor#NIL THEN
                gwbox.textcolor.FreeUser(gwbox.task);
              END;
              gwbox.textcolor:=node(col.Color);
              gwbox.textcolor.NewUser(gwbox.task);
            END;
            textcolgad.SetValue(col.colors.GetNodeNumber(gwbox.textcolor));
          ELSIF mes.iAddress=graphcolgad.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectGraphicColor),ac.GetString(ac.GraphicColor),s.ADR("No colors are entered at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              IF gwbox.graphcolor#NIL THEN
                gwbox.graphcolor.FreeUser(gwbox.task);
              END;
              gwbox.graphcolor:=node(col.Color);
              gwbox.graphcolor.NewUser(gwbox.task);
            END;
            graphcolgad.SetValue(col.colors.GetNodeNumber(gwbox.graphcolor));
          ELSIF mes.iAddress=gridgad.gadget THEN
            bool:=gwbox.gridconv.ChangeGrid(NIL);
          ELSIF mes.iAddress=labelsgad.gadget THEN
            bool:=gwbox.labelsconv.ChangeLabels(NIL);
          END;
        END;
        IF (I.gadgetUp IN mes.class) AND (mes.iAddress=root.help) THEN
          ag.ShowFile(ag.guidename,"graphiccontents",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  col.DestructMinPlotInfo(plotinfo);
  RETURN ret;
END ChangeContents;

END GraphWindowBox.

