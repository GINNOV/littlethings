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


MODULE Legend;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       tt : TextTools,
       st : Strings,
       lrc: LongRealConversions,
       ag : AmigaGuideTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       fm : FontManager,
       fo : FontOrganizer,
       go : GraphicObjects,
       gb : GeneralBasics,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       dc : DisplayConversion,
       fb : FunctionBasics,
       mb : MathBasics,
       mg : MathGUI,
       t  : Terms,
       w  : Window,
       co : Coords,
       fg : FunctionGraph,
       wf : WindowFunction,
       gw : GraphWindow,
       ac : AnalayCatalog,
       bt : BasicTypes,
       NoGuruRq;

TYPE Legend * = POINTER TO LegendDesc;
     LegendDesc * = RECORD(w.WindowDesc)
       elements    * : l.List;
       outsame     * ,
       insame      * ,
       indent      * ,
       default     * : BOOLEAN; (* Set to TRUE to constantly adapt the legend to a window. *)
       defaultwind * : gw.GraphWindow;
       fontinfo    * : fo.FontInfo;
       font        * : fm.Font;
     END;

PROCEDURE (legend:Legend) Init*;

BEGIN
  legend.Init^;
  legend.elements:=l.Create();
  legend.outsame:=TRUE;
  legend.insame:=TRUE;
  legend.indent:=TRUE;
  legend.default:=FALSE;
  legend.defaultwind:=NIL;
  NEW(legend.fontinfo); legend.fontinfo.Init;
  legend.font:=NIL;
END Init;

PROCEDURE (legend:Legend) Destruct*;

BEGIN
  IF legend.elements#NIL THEN legend.elements.Destruct; END;
  IF legend.defaultwind#NIL THEN legend.defaultwind.FreeUser(legend); END;
  IF legend.font#NIL THEN legend.font.Destruct; END;
  IF legend.fontinfo#NIL THEN legend.fontinfo.Destruct; END;
  legend.Destruct^;
END Destruct;

PROCEDURE (legend:Legend) AllocNew*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(Legend)); RETURN node;
END AllocNew;

PROCEDURE (legend:Legend) SetDefaultWindow*(graphwind:gw.GraphWindow);

BEGIN
  IF legend.defaultwind#NIL THEN legend.defaultwind.FreeUser(legend); END;
  legend.defaultwind:=graphwind;
  IF legend.defaultwind#NIL THEN legend.defaultwind.NewUser(legend); END;
END SetDefaultWindow;

TYPE LegendElement * = POINTER TO LegendElementDesc;
     LegendElementDesc * = RECORD(l.NodeDesc);
       legend    * : Legend;               (* The legend this element belongs to. *)
       term      * : ARRAY 256 OF CHAR;
(*       func      * : l.Node;  (* Term.Function in a graphwind this legend element belongs to. Can be NIL. *)*)
       textcolor * ,          (* Color of text behind field *)
       color     * ,          (* Color of field *)
       pattern   * ,
       thickness * ,
       point     * : INTEGER;
       sub       * : BOOLEAN;
     END;

PROCEDURE (legendel:LegendElement) Init*;

BEGIN
  legendel.Init^;
  legendel.legend:=NIL;
  legendel.term:="";
  legendel.textcolor:=1;
  legendel.color:=1;
  legendel.pattern:=0;
  legendel.thickness:=1;
  legendel.point:=0;
  legendel.sub:=FALSE;
END Init;

PROCEDURE (legendel:LegendElement) Destruct*;

BEGIN
(*  IF legendel.func#NIL THEN legendel.func(m.ShareAble).FreeUser(legendel.legend); END;*)
  legendel.Destruct^;
END Destruct;

PROCEDURE (legendel:LegendElement) AllocNew*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(LegendElement)); RETURN node;
END AllocNew;

PROCEDURE (legendel:LegendElement) Copy*(dest:l.Node);

BEGIN
  WITH dest: LegendElement DO
    legendel.Copy^(dest);
    dest.legend:=legendel.legend;
    COPY(legendel.term,dest.term);
    dest.textcolor:=legendel.textcolor;
    dest.color:=legendel.color;
    dest.pattern:=legendel.pattern;
    dest.thickness:=legendel.thickness;
    dest.point:=legendel.point;
    dest.sub:=legendel.sub;
  END;
END Copy;

PROCEDURE (legend:Legend) Copy*(dest:l.Node);

VAR node : l.Node;

BEGIN
  WITH dest: Legend DO
    legend.Copy^(dest);
    legend.elements.Copy(dest.elements);
    node:=dest.elements.head;
    WHILE node#NIL DO
      node(LegendElement).legend:=dest;
      node:=node.next;
    END;
    dest.outsame:=legend.outsame;
    dest.insame:=legend.insame;
    dest.indent:=legend.indent;
    dest.default:=legend.default;
    dest.SetDefaultWindow(legend.defaultwind);
    legend.fontinfo.Copy(dest.fontinfo);
    dest.font:=NIL;
  END;
END Copy;

PROCEDURE * PrintLegendElement*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node    : l.Node;
    str     : e.STRPTR;
    fieldwi : INTEGER;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: LegendElement DO
      IF (node.sub) & (node.legend.indent) THEN
        INC(x,rast.txHeight*2);
        DEC(width,rast.txHeight*2);
      END;

      fieldwi:=SHORT(SHORT(rast.txHeight*1.5));
      go.PlotLegendField(rast,x,y-rast.txBaseline,fieldwi,rast.txHeight,1,node.thickness,node.pattern,node.color,node.point);

      DEC(width,fieldwi+rast.txHeight DIV 3);
      INC(x,fieldwi+rast.txHeight DIV 3);

      NEW(str);
      COPY(node.term,str^);
      tt.CutStringToLength(rast,str^,width);
      g.SetAPen(rast,node.textcolor);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintLegendElement;



(* Legend plotting methods *)

PROCEDURE (legend:Legend) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable;dragbarplot:BOOLEAN);
(* Set dragbarplot always to FALSE. dragbarplot is set to TRUE if
   DragBar want's to plot this window for an icon. *)

VAR real            : LONGREAL;
    element,node    : l.Node;
    font            : fm.Font;
    txHeight,txBaseline,
    xpos,ypos,
    x,y,width,height,
    maxwidth,addy,
    fieldwi,fieldhe : INTEGER;
    layoutplot,bool,
    getnextel       : BOOLEAN;

BEGIN
  IF rast=legend.rast THEN layoutplot:=FALSE;
                      ELSE layoutplot:=TRUE; END;
  IF ~dragbarplot THEN legend.subwindow.SetBusyPointer; END;

  IF (legend.fontinfo.changed) OR (legend.font=NIL) THEN
    IF legend.font#NIL THEN legend.font.Destruct; legend.font:=NIL; END;
    legend.font:=legend.fontinfo.Open();
  END;
  font:=legend.font;

  bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
  bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));

  fieldwi:=SHORT(SHORT(txHeight*2.0));
  fieldhe:=SHORT(SHORT(txHeight*1.2));
  IF fieldhe>txHeight THEN addy:=SHORT(SHORT(fieldhe*1.1));
                      ELSE addy:=SHORT(SHORT(txHeight*1.1)); END;

  xpos:=rect.xoff;
  ypos:=rect.yoff;
  maxwidth:=0;
  element:=legend.elements.head;
  WHILE element#NIL DO
    WITH element: LegendElement DO
      IF ypos+txHeight>rect.yoff+rect.height THEN
        (* Out of range! *)
        IF element=legend.elements.head THEN element:=NIL; END; (* Exit and plot nothing in this case. *)
        ypos:=rect.yoff;
        INC(maxwidth,SHORT(SHORT(txHeight*1.5)));
        INC(xpos,maxwidth);
        maxwidth:=0;
      END;

      x:=xpos;
      y:=ypos;

      IF (element.sub) & (legend.indent) THEN
        INC(x,txHeight*2);
        width:=txHeight*2;
      ELSE
        width:=0;
      END;

      go.PlotLegendField(rast,x,y,fieldwi,txHeight,1,conv.GetThicknessY(element.thickness),element.pattern,conv.GetColor(element.color,dc.standardType),element.point);

      INC(x,fieldwi+txHeight DIV 3);
      INC(width,fieldwi+txHeight DIV 3);

      g.SetAPen(rast,conv.GetColor(element.textcolor,dc.textType));
      font.Print(rast,x,y+txBaseline+((fieldhe-txHeight) DIV 2),s.ADR(element.term));

      width:=width+SHORT(SHORT(SHORT(font.TextWidthPix(rast,s.ADR(element.term)))));
      IF width>maxwidth THEN maxwidth:=width; END;
      INC(ypos,addy);
    END;
    IF element#NIL THEN element:=element.next; END;
  END;
  IF ~dragbarplot THEN
    legend.subwindow.ClearPointer;
    I.RefreshWindowFrame(legend.iwind);
  END;
  IF (font#NIL) & (font#legend.font) THEN font.Destruct; END;
END Plot;

PROCEDURE (legend:Legend) Refresh*;

BEGIN
  IF legend.changed THEN
    IF legend.subwindow#NIL THEN
      legend.subwindow.SetBusyPointer;
    END;
    legend.Refresh^;
    IF legend.subwindow#NIL THEN
      legend.subwindow.SetBusyPointer;
    END;
    IF legend.iwind#NIL THEN
      legend.Lock(FALSE);
      legend.Plot(legend.rast,legend.innerrect,mg.mathconv,FALSE);
      legend.UnLock;
    END;
    legend.changed:=FALSE;
    IF legend.subwindow#NIL THEN
      legend.subwindow.ClearPointer;
    END;
  END;
END Refresh;



(* Legend data methods *)

PROCEDURE (legend:Legend) AdaptToElement*(element:LegendElement);
(* Adapts whole legend to the given LegendElement (e.g. sets point
   of every element of the legend to point of the given element if
   legend.insame=TRUE OR legend.outsame=TRUE). *)

VAR node : l.Node;

BEGIN
  IF element#NIL THEN
    node:=legend.elements.head;
    WHILE node#NIL DO
      WITH node: LegendElement DO
        IF legend.outsame & ~element.sub & ~node.sub THEN
          node.point:=element.point;
          node.textcolor:=element.textcolor;
        ELSIF legend.insame & element.sub & node.sub THEN
          node.point:=element.point;
          node.textcolor:=element.textcolor;
        END;
      END;
      node:=node.next;
    END;
  END;
END AdaptToElement;

PROCEDURE (legend:Legend) InsertWindow*(graphwind:gw.GraphWindow;type,outpoint,inpoint:INTEGER;legendel:l.Node);
(* Inserts the contents of the given graphwind into the legend.
   Inputs: graphwind : This window's contents are inserted into the legend.
           type      : How to insert:
                       0 : Delete legend
                       1 : Append at the end of legend
                       2 : Insert before the given legendelement "legendel"
                       3 : Overwrite from the beginning using old legendelement nodes.
                           Thus no textcolors or point settings are touched.
           outpoint,
           inpoint   : Points to use for families and non-families. Meaningless
                       if type=3.
           legendel  : See "type".

   IMPORTANT: You have to lock legend and graphwind before calling
              this method!
*)

VAR windfunc   : l.Node;
    graph      : l.Node;
    actel,node : l.Node;

  PROCEDURE InitElement(el:LegendElement;graph:fg.FunctionGraph);

  BEGIN
    el.color:=graph.color;
    el.pattern:=graph.pattern;
    el.thickness:=graph.thickness;
    IF type#3 THEN
      IF el.sub THEN
        el.point:=inpoint;
      ELSE
        el.point:=outpoint;
      END;
    END;
  END InitElement;

  PROCEDURE WriteParts(windfunc:wf.WindowFunction;depend:l.Node;VAR graph:l.Node;VAR actel:l.Node);
  
  VAR var    : fb.Variable;

    PROCEDURE CreateName;
    
    VAR depend : l.Node;
        str    : ARRAY 20 OF CHAR;
        length : INTEGER;
        bool   : BOOLEAN;
    
    BEGIN
      IF type#3 THEN actel:=NIL; END;
      IF actel=NIL THEN
        NEW(actel(LegendElement)); actel.Init;
        actel(LegendElement).legend:=legend;
        IF (type=0) OR (type=1) OR (type=3) OR (legendel=NIL) THEN
          legend.elements.AddTail(actel);
        ELSIF type=2 THEN
          legendel.AddBefore(actel);
        END;
      END;

      WITH actel: LegendElement DO
        actel.sub:=TRUE;
        InitElement(actel,graph(fg.FunctionGraph));
        actel.term:="";
        depend:=windfunc.func.depend.head;
        WHILE depend#NIL DO
          st.Append(actel.term,depend(t.Depend).var(fb.Variable).name^);
          st.AppendChar(actel.term,"=");
          bool:=lrc.RealToString(depend(t.Depend).var(fb.Variable).real,str,7,7,FALSE);
          tt.Clear(str);
          st.Append(actel.term,str);
          IF depend.next#NIL THEN
            st.AppendChar(actel.term,",");
          END;
          depend:=depend.next;
        END;
      END;
    END CreateName;
    
  BEGIN
    var:=depend(t.Depend).var(fb.Variable);
    var.real:=var.startx;
    LOOP
      IF depend.next#NIL THEN
        WriteParts(windfunc,depend.next(t.Depend),graph,actel);
      ELSE
        CreateName;
        graph:=graph.next;
        IF ((type=0) OR (type=1) OR (type=3)) & (actel#NIL) THEN
          actel:=actel.next;
        END;
      END;
      var.real:=var.real+var.stepx;
      IF var.stepx>0 THEN
        IF var.real>var.endx THEN
          EXIT;
        END;
      ELSIF var.stepx<0 THEN
        IF var.real<var.endx THEN
          EXIT;
        END;
      END;
    END;
  END WriteParts;
  
BEGIN
  IF graphwind#NIL THEN
    actel:=NIL;
    IF type=0 THEN
      legend.elements.DestructNodes;
      legendel:=NIL;
    ELSIF type=1 THEN
      legendel:=NIL;
    ELSIF type=3 THEN
      IF legend.elements.head#NIL THEN
        legendel:=legend.elements.head(LegendElement);
      ELSE
        legendel:=NIL;
      END;
      actel:=legendel;
    END;

    windfunc:=graphwind.funcs.head;
    WHILE windfunc#NIL DO
      WITH windfunc: wf.WindowFunction DO
        IF type#3 THEN actel:=NIL; END;
        IF actel=NIL THEN
          NEW(actel(LegendElement)); actel.Init;
          actel(LegendElement).legend:=legend;
          IF (type=0) OR (type=1) OR (type=3) OR (legendel=NIL) THEN
            legend.elements.AddTail(actel);
          ELSIF type=2 THEN
            legendel.AddBefore(actel);
          END;
        END;
        actel(LegendElement).sub:=FALSE;
        InitElement(actel(LegendElement),windfunc.graphs.head(fg.FunctionGraph));
        COPY(windfunc.func.name,actel(LegendElement).term);
        actel:=actel.next;
        graph:=windfunc.graphs.head;
        IF windfunc.graphs.nbElements()>1 THEN
          WriteParts(windfunc,windfunc.func.depend.head,graph,actel);
        END;
      END;

      windfunc:=windfunc.next;
    END;

    IF (type=3) & (actel#NIL) THEN
      WHILE legend.elements.tail#actel DO
        node:=legend.elements.RemTail(); node.Destruct;
      END;
      node:=legend.elements.RemTail(); node.Destruct;
    END;
  END;
END InsertWindow;

PROCEDURE (legend:Legend) AdaptToDefaultWindow*;

BEGIN
  IF (legend.default) & (legend.defaultwind#NIL) THEN
    legend.Lock(FALSE);
    legend.defaultwind.Lock(FALSE);
    legend.InsertWindow(legend.defaultwind,3,0,0,NIL);
    legend.defaultwind.UnLock;
    legend.UnLock;
  END;
END AdaptToDefaultWindow;



VAR legends          * : m.MTList;
    standardlegend   * : Legend;
    changelegendwind * ,
    insertwindowwind * : wm.Window;
    lastinserttype   * ,
    lastoutpoint     * ,
    lastinpoint      * : INTEGER;   (* Used by Insertwindow-Requester *)

PROCEDURE (legend:Legend) Change*(changetask:m.Task):BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    appline,
    insline,
    delline,
    seldefault,
    selfont    : gmo.BooleanGadget;
    namegad    : gmo.StringGadget;
    outsame,
    insame,
    indent,      (* Indent families? *)
    default,
    isfamily   : gmo.CheckboxGadget;  (* LegendElement is part of a family? *)
    textpalette,
    palette    : gmo.PaletteGadget;
    point,
    pattern,
    thickness  : gmo.SelectBox;
    legendlv   : gmo.ListView;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    msg        : m.Message;
    class      : LONGSET;
    actel,node : l.Node;
    backup     : Legend;
    type,outpoint,         (* Used by insertwindow *)
    inpoint,
    depth      : INTEGER;
    bool,ret,
    didchange  : BOOLEAN;

  PROCEDURE RefreshElement;
  
  BEGIN
    IF actel#NIL THEN
      legendlv.SetString(actel(LegendElement).term);
      legendlv.SetValue(legend.elements.GetNodeNumber(actel));
    ELSE
      legendlv.Refresh;
    END;
  END RefreshElement;
  
  PROCEDURE SetData;
  
  BEGIN
    namegad.SetString(legend.windname);
    outsame.Check(legend.outsame);
    insame.Check(legend.insame);
    indent.Check(legend.indent);
    default.Check(legend.default);
    IF actel#NIL THEN
      WITH actel: LegendElement DO
        isfamily.Check(actel.sub);
        textpalette.SetValue(actel.textcolor);
        palette.SetValue(actel.color);
        pattern.SetValue(actel.pattern);
        thickness.SetValue(actel.thickness-1);
        point.SetValue(actel.point);
      END;
    END;
  END SetData;

  PROCEDURE GetInput;

  BEGIN
    namegad.GetString(legend.windname);
    legend.outsame:=outsame.Checked();
    legend.insame:=insame.Checked();
    legend.indent:=indent.Checked();
    legend.default:=default.Checked();
    IF actel#NIL THEN
      WITH actel:LegendElement DO
        actel.sub:=isfamily.Checked();
        actel.textcolor:=SHORT(textpalette.GetValue());
        actel.color:=SHORT(palette.GetValue());
        actel.pattern:=SHORT(pattern.GetValue());
        actel.thickness:=SHORT(thickness.GetValue()+1);
        actel.point:=SHORT(point.GetValue());
        legendlv.GetString(actel.term);
        legend.AdaptToElement(actel);
      END;
    END;
  END GetInput;

  PROCEDURE InsertWindow(VAR type,outpoint,inpoint:INTEGER):BOOLEAN;

  VAR subwind    : wm.SubWindow;
      wind       : I.WindowPtr;
      rast       : g.RastPortPtr;
      root       : gmb.Root;
      inserttype : gmo.CycleGadget;
      outpointgad,
      inpointgad : gmo.SelectBox;
      gadobj     : gmb.Object;
      glist      : I.GadgetPtr;
      mes        : I.IntuiMessagePtr;
      typearray  : ARRAY 4 OF e.STRPTR;
      bool,ret   : BOOLEAN;

  BEGIN
    NEW(mes);
    ret:=FALSE;
    IF insertwindowwind=NIL THEN
      insertwindowwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.AfterWindow),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
    END;
    subwind:=insertwindowwind.InitSub(mg.screen);
  
    root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
      typearray[0]:=ac.GetString(ac.DeleteListLegend);
      typearray[1]:=ac.GetString(ac.AppendWindowLegend);
      typearray[2]:=ac.GetString(ac.InsertWindowLegend);
      typearray[3]:=NIL;
      inserttype:=gmo.SetCycleGadget(NIL,s.ADR(typearray),lastinserttype);
      outpointgad:=gmo.SetSelectBox(ac.GetString(ac.FunctionSymbol),6,lastoutpoint,6,1,mg.window.rPort.txHeight,SHORT(SHORT(mg.window.rPort.txHeight*1.2)),-1,gmo.horizOrient,go.PlotLegendFieldSimple);
      inpointgad:=gmo.SetSelectBox(ac.GetString(ac.FamilySymbol),6,lastinpoint,6,1,mg.window.rPort.txHeight,SHORT(SHORT(mg.window.rPort.txHeight*1.2)),-1,gmo.horizOrient,go.PlotLegendFieldSimple);
    glist:=root.EndRoot();
  
    root.Init;
  
    wind:=subwind.Open(glist);
    IF wind#NIL THEN
      rast:=wind.rPort;
      root.Resize;

      LOOP
        class:=e.Wait(LONGSET{0..31});
        REPEAT
          root.GetIMes(mes);
          IF I.gadgetUp IN mes.class THEN
            IF mes.iAddress=root.ok THEN
              type:=SHORT(inserttype.GetValue());
              outpoint:=SHORT(outpointgad.GetValue());
              inpoint:=SHORT(inpointgad.GetValue());

              ret:=TRUE;
              EXIT;
            ELSIF mes.iAddress=root.ca THEN
              ret:=FALSE;
              EXIT;
            END;
          END;
(*          IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
            ag.ShowFile(ag.guidename,"changegrid",wind);
          END;*)
        UNTIL mes.class=LONGSET{};
      END;
  
      subwind.Destruct;
    END;
    root.Destruct;
    DISPOSE(mes);
    RETURN ret;
  END InsertWindow;

BEGIN
  NEW(backup); IF backup=NIL THEN RETURN FALSE; END;
  backup.Init;
  legend.Copy(backup);

  NEW(mes);
  ret:=FALSE;
  IF changelegendwind=NIL THEN
    changelegendwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeLegend),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changelegendwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    depth:=s.LSH(1,mg.screenmode.depth); IF depth>16 THEN depth:=16; END;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,ac.GetString(ac.LegendGeneral));
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
          appline:=gmo.SetBooleanGadget(ac.GetString(ac.AppendLine),FALSE);
          insline:=gmo.SetBooleanGadget(ac.GetString(ac.InsertLine),FALSE);
          delline:=gmo.SetBooleanGadget(ac.GetString(ac.DeleteLine),FALSE);
          seldefault:=gmo.SetBooleanGadget(ac.GetString(ac.AfterWindow),FALSE);
          selfont:=gmo.SetBooleanGadget(ac.GetString(ac.Font),FALSE);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
          namegad:=gmo.SetStringGadget(ac.GetString(ac.Name),255,gmo.stringType);
          outsame:=gmo.SetCheckboxGadget(ac.GetString(ac.FunctionsUniform),legend.outsame);
          insame:=gmo.SetCheckboxGadget(ac.GetString(ac.FamiliesUniform),legend.insame);
          indent:=gmo.SetCheckboxGadget(ac.GetString(ac.IndentFamilies),legend.indent);
          default:=gmo.SetCheckboxGadget(ac.GetString(ac.WindowModel),legend.default);
          root.NewSameTextWidth;
            root.AddSameTextWidth(outsame);
            root.AddSameTextWidth(insame);
            root.AddSameTextWidth(indent);
            root.AddSameTextWidth(default);
        gmb.EndBox;
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,ac.GetString(ac.CurrentLine));
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
          isfamily:=gmo.SetCheckboxGadget(ac.GetString(ac.Family),FALSE);
          textpalette:=gmo.SetPaletteGadget(s.ADR("Textfarbe"),mg.screenmode.depth,depth,0);
          palette:=gmo.SetPaletteGadget(s.ADR("Punktfarbe"),mg.screenmode.depth,depth,0);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
          point:=gmo.SetSelectBox(ac.GetString(ac.PointDesign),6,0,6,1,mg.window.rPort.txHeight,SHORT(SHORT(mg.window.rPort.txHeight*1.2)),-1,gmo.horizOrient,go.PlotLegendFieldSimple);
          pattern:=gmo.SetSelectBox(ac.GetString(ac.LinePattern),10,0,5,2,16,mg.window.rPort.txHeight*3 DIV 8,-1,gmo.horizOrient,go.PlotPatternLine);
          thickness:=gmo.SetSelectBox(ac.GetString(ac.LineThickness),5,0,2,3,16*4,mg.window.rPort.txHeight*7 DIV 8,-1,gmo.vertOrient,go.PlotThicknessLine);
        gmb.EndBox;
      gmb.EndBox;
    gmb.EndBox;
    legendlv:=gmo.SetListView(ac.GetString(ac.LegendPreview),legend.elements,PrintLegendElement,0,TRUE,255);
  glist:=root.EndRoot();

  root.Init;

  namegad.SetString(legend.windname);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    namegad.Activate;

    actel:=legend.elements.head;
    RefreshElement;
    SetData;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF changetask.msgsig IN class THEN
        REPEAT
          msg:=changetask.ReceiveMsg();
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
                namegad.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              RefreshElement;
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
            GetInput;
            ret:=TRUE;
            legend.changed:=TRUE;
            legend.SendNewMsg(m.msgNodeChanged,NIL);
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            IF didchange THEN
              backup.Copy(legend);
              legend.changed:=TRUE;
              legend.SendNewMsg(m.msgNodeChanged,NIL);
            END;
            ret:=FALSE;
            EXIT;
          ELSIF (mes.iAddress=appline.gadget) OR (mes.iAddress=insline.gadget) THEN
            subwind.SetBusyPointer;
            legend.Lock(FALSE);
            GetInput;
            node:=NIL;
            NEW(node(LegendElement)); node.Init;
            node(LegendElement).legend:=legend;
            IF (mes.iAddress=appline.gadget) OR (actel=NIL) THEN
              legend.elements.AddTail(node);
            ELSE
              actel.AddBefore(node);
            END;
            actel:=node;
            RefreshElement;
            SetData;
            legend.changed:=TRUE;
            legend.UnLock;
            legend.SendNewMsg(m.msgNodeChanged,NIL);
            subwind.ClearPointer;
          ELSIF mes.iAddress=delline.gadget THEN
            IF actel#NIL THEN
              subwind.SetBusyPointer;
              legend.Lock(FALSE);
              node:=actel.next;
              IF node=NIL THEN node:=actel.prev; END;
              actel.Remove;
              actel.Destruct;
              legend.UnLock;
              legend.SendNewMsg(m.msgNodeChanged,NIL);
              subwind.ClearPointer;
              RefreshElement;
              SetData;
            END;
          ELSIF mes.iAddress=selfont.gadget THEN
            bool:=legend.fontinfo.SelectFont(changetask,mg.screen);
            IF bool THEN
              didchange:=TRUE;
              legend.changed:=TRUE;
              legend.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          ELSIF mes.iAddress=legendlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              GetInput;
              actel:=legend.elements.GetNode(legendlv.GetValue());
              RefreshElement;
              SetData;
            END;
          ELSIF mes.iAddress=default.gadget THEN
            GetInput;
            IF (legend.default) & (legend.defaultwind#NIL) THEN
              legend.SendNewMsg(m.msgNodeChanged,legend.defaultwind);
            END;
          ELSIF mes.iAddress=seldefault.gadget THEN
            gw.graphwindows.NewUser(NIL,TRUE);
            node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
            IF node#NIL THEN
              bool:=InsertWindow(type,outpoint,inpoint);
              IF bool THEN
                subwind.SetBusyPointer;
                legend.Lock(FALSE);
                node(gw.GraphWindow).Lock(FALSE);
                legend.SetDefaultWindow(node(gw.GraphWindow));

                legend.InsertWindow(node(gw.GraphWindow),type,outpoint,inpoint,actel);
                IF type=0 THEN actel:=legend.elements.head; END;

                node(gw.GraphWindow).UnLock;
                legend.UnLock;
                legend.SendNewMsg(m.msgNodeChanged,NIL);
                subwind.ClearPointer;
                RefreshElement;
                SetData;
              END;
            END;
            gw.graphwindows.FreeUser(NIL);
          ELSIF NOT(mes.iAddress=root.help) THEN
            GetInput; didchange:=TRUE;
            legendlv.Refresh;

            legend.changed:=TRUE;
            legend.SendNewMsg(m.msgNodeChanged,NIL);
          END;
        END;
        IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"legends",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  IF backup#NIL THEN backup.Destruct; END;
  RETURN ret;
END Change;

PROCEDURE ChangeLegendTask*(changetask:bt.ANY):bt.ANY;

VAR data : Legend;
    bool : BOOLEAN;

BEGIN
  WITH changetask: m.Task DO
    changetask.InitCommunication;
    data:=changetask.data(Legend);
    bool:=data.Change(changetask);

    IF data.isRunning() THEN data.RemTask(changetask);
                        ELSE m.taskdata.maintask.RemTask(changetask); END;
    changetask.ReplyAllMessages;
    changetask.DestructCommunication;
    mem.NodeToGarbage(changetask);
    data.FreeUser(changetask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeLegendTask;



PROCEDURE (legend:Legend) CheckInput*(class:LONGSET):BOOLEAN;

VAR mes       : I.IntuiMessagePtr;
    msg       : m.Message;         (* Has to be NIL if no action is performed on a message. *)
    node      : l.Node;
    bool,quit : BOOLEAN;

  PROCEDURE DoMenu(code:INTEGER);

  VAR strip,item,sub : LONGINT;
      node           : l.Node;
      data           : bt.ANY;
      task           : m.Task;
      didmenu        : BOOLEAN;

  BEGIN
    strip:=I.MenuNum(code);
    item:=I.ItemNum(code);
    sub:=I.SubNum(code);

    didmenu:=FALSE;
    IF (mb.mathoptions.autoactive) OR (msg#NIL) THEN
      IF strip=4 THEN
        IF item=0 THEN
          IF sub=1 THEN (* Change Legend *)
            task:=legend.FindTask(tid.changeTaskID);
            IF task=NIL THEN
              NEW(task); task.Init;
              task.InitTask(ChangeLegendTask,legend,10000,m.taskdata.requesterpri);
              task.SetID(tid.changeTaskID);
              legend.AddTask(task);
              legend.NewUser(task);
              bool:=task.Start();
            ELSE
              task.SendNewMsg(m.msgActivate,NIL);
            END;
  
            didmenu:=TRUE;
          ELSIF sub=2 THEN (* Delete legend *)
            legend.SendNewMsg(m.msgQuit,NIL);
  
            didmenu:=TRUE;
          END;
        END;
      END;
    END;

    IF NOT(didmenu) THEN (* Tell Main task of menu action. *)
      m.taskdata.maintask.SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
    END;
  END DoMenu;

  PROCEDURE InputEvent(mes:I.IntuiMessagePtr);

  VAR node : l.Node;
      bool : BOOLEAN;

  BEGIN
    IF I.menuPick IN mes.class THEN
      DoMenu(mes.code);
    ELSIF I.vanillaKey IN mes.class THEN
      mg.ImitateMenu(mes.code);
      DoMenu(mes.code);
    ELSIF I.newSize IN mes.class THEN
      legend.changed:=TRUE;
      legend.sizechanged:=TRUE;
      legend.Refresh;
(*      legend.Changed;*)
    ELSIF I.closeWindow IN mes.class THEN
      quit:=TRUE;
    END;
  END InputEvent;
  
BEGIN
  legend.InitCommunication; (* Doesn't matter to call it over and over again. *)
  NEW(mes);
  quit:=FALSE;
  IF legend.subwindow#NIL THEN
    REPEAT
      legend.subwindow.GetIMes(mes);
      InputEvent(mes);
    UNTIL mes.class=LONGSET{};
  END;
  msg:=NIL;

(* Don't check for graphwind.msgsig here! *)

  REPEAT
    msg:=legend.ReceiveMsg();
    IF msg#NIL THEN
      IF msg.type=m.msgQuit THEN
        quit:=TRUE;
      ELSIF msg.type=m.msgClose THEN
        legend.SendNewMsgToAllTasks(m.msgClose,NIL);
        legend.Close;
      ELSIF msg.type=m.msgOpen THEN
        legend.SendNewMsgToAllTasks(m.msgOpen,NIL);
        legend.changed:=TRUE;
        legend.Refresh;
      ELSIF msg.type=m.msgActivate THEN
        IF legend.iwind#NIL THEN
          I.WindowToFront(legend.iwind);
          I.ActivateWindow(legend.iwind);
        END;
      ELSIF (msg.type=m.msgNodeChanged) OR (msg.type=m.msgSizeChanged) THEN
        IF msg.data=legend.defaultwind THEN
          legend.AdaptToDefaultWindow;
        END;
        legend.Changed;
        legend.changed:=TRUE; legend.Refresh;
      ELSIF msg.type=m.msgMenuAction THEN
        IF legend.iwind#NIL THEN
          DoMenu(SHORT(s.VAL(LONGINT,msg.data)));
        END;
      END;
      msg.Reply;
    END;
  UNTIL msg=NIL;

  DISPOSE(mes);
  IF quit THEN
    IF legend.list#NIL THEN
      legend.Remove;
    END;
    legend.SendNewMsgToAllTasks(m.msgQuit,NIL);
    legend.ReplyAllMessages;
    legend.DestructCommunication;
    legend.Close;
    legend.UnLock;
    mem.NodeToGarbage(legend);
  END;
  RETURN quit;
END CheckInput;

PROCEDURE LegendTask*(lg:bt.ANY):bt.ANY;

VAR class     : LONGSET;
    legend    : Legend;
    quit      : BOOLEAN;

BEGIN
  legend:=lg(Legend);
  quit:=FALSE;
  legend.Refresh; (* Open and refresh window *)

  REPEAT
    class:=e.Wait(LONGSET{0..31});

(* The window is locked because other tasks may use this window
   and thus also its IDCMP-Port (e.g. Area.ChangeArea when selecting
   a point or marker. *)

    legend.Lock(FALSE);
    quit:=legend.CheckInput(class);
    IF ~quit THEN legend.UnLock; END;
  UNTIL quit;

  RETURN NIL;
END LegendTask;

BEGIN
  changelegendwind:=NIL; insertwindowwind:=NIL;
  lastinserttype:=0; lastoutpoint:=0; lastinpoint:=0;
  legends:=m.Create();
  IF legends=NIL THEN HALT(20); END;
  standardlegend:=NIL; NEW(standardlegend);
  IF standardlegend#NIL THEN standardlegend.Init; END;
CLOSE
  IF legends#NIL THEN legends.Destruct; END;
  IF standardlegend#NIL THEN standardlegend.Destruct; END;
END Legend.

