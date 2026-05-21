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


MODULE GraphWindow;

(* LOOK AROUND line 835 *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gd : GadTools,
       st : Strings,
       c  : Conversions,
       lrc: LongRealConversions,
       ac : AnalayCatalog,
       wm : WindowManager,
       tt : TextTools,
       rt : RequesterTools,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       go : GraphicObjects,
       fb : FunctionBasics,
       ft : FunctionTrees,
       geb: GeneralBasics,
       mb : MathBasics,
       mg : MathGUI,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       w  : Window,
       t  : Terms,
       fg : FunctionGraph,
       gr : Grid,
       al : AxisLabels,
       co : Coords,
       wf : WindowFunction,
       gb : GraphObject,
       to : TextObject,
       pmo: PointMarkObject,
       ao : Area,
       do : DiscussionObject,
       zo : ZeroObject,
       ifo: InflectionObject,
       iso: IntersectionObject,
       mo : MinMaxObject,
       gp : GapObject,
       cmo: CompleteObject,
       dc : DisplayConversion,
       cc : Concurrency,
       bt : BasicTypes,
       io,
       NoGuruRq;

TYPE GraphWindow * = POINTER TO GraphWindowDesc;
     GraphWindowDesc * = RECORD(w.WindowDesc)
       coordsystem       * : co.CoordSystem;
       grid1*,grid2      * : gr.Grid;
       axislabels        * : al.AxisLabels;
       funcs             * : m.MTList;  (* Nodetype is wf.WindowFunction *)
       graphobjects      * : gb.GraphObjectList;
(*       texts             * ,
       points            * ,
       marks             * ,*)
       areas             * ,
       lines             * : m.MTList;
       mode              * : INTEGER;
       drawmode          * : INTEGER;
       transparent       * ,
       freeborder        * ,
       autofuncscale     * :BOOLEAN;    (* Change y-range of axis to current functions *)
(*       autoaxisscale     * ,          (* Change steps on axis to current window size *)
       autogridscale     * : BOOLEAN; (* Adapt grid to current axis steps *)*)
       stutz             * : INTEGER; (* Number of points calculated *)
     END;

TYPE GraphWindowList * = POINTER TO GraphWindowListDesc;
     GraphWindowListDesc * = RECORD(w.WindowListDesc)
     END;

PROCEDURE Create * (): GraphWindowList;
VAR
  list: GraphWindowList;
BEGIN
  NEW(list); list.Init;
  RETURN list;
END Create;

PROCEDURE (wlist:GraphWindowList) Refresh*;

VAR node,wfunc : l.Node;

BEGIN
  node:=wlist.head;
  WHILE node#NIL DO
    wfunc:=node(GraphWindow).funcs.head;
    WHILE wfunc#NIL DO
      IF wfunc(wf.WindowFunction).func(t.Function).changed THEN
        node(GraphWindow).changed:=TRUE;
      END;
      wfunc:=wfunc.next;
    END;
    node:=node.next;
  END;
  node:=wlist.head;
  WHILE node#NIL DO
    node(GraphWindow).Refresh;
    node:=node.next;
  END;
  node:=t.terms.head;
  WHILE node#NIL DO
    node(t.Term).changed:=FALSE;
    node:=node.next;
  END;
  node:=t.functions.head;
  WHILE node#NIL DO
    node(t.Function).changed:=FALSE;
    node:=node.next;
  END;
END Refresh;



VAR graphwindows * : GraphWindowList; (* List containing all graph windows *)

PROCEDURE (wind:GraphWindow) Init*;

BEGIN
  NEW(wind.coordsystem(co.CartesianSystem)); wind.coordsystem.Init; wind.coordsystem.window:=wind;
  NEW(wind.grid1);       wind.grid1.Init(FALSE); wind.grid1.window:=wind;
  NEW(wind.grid2);       wind.grid2.Init(TRUE);  wind.grid2.window:=wind;
  NEW(wind.axislabels);  wind.axislabels.Init;   wind.axislabels.window:=wind;
  wind.funcs:=m.Create();
  wind.graphobjects:=gb.Create();
(*  wind.texts:=l.Create();
  wind.points:=l.Create();
  wind.marks:=l.Create();*)
  wind.areas:=m.Create();
  wind.lines:=m.Create();

  wind.stutz:=640;
(*  node.scale.attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
  COPY("topaz.font",node.scale.attr.name^);
  node.scale.attr.ySize:=8;*)

  wind.Init^;
END Init;

PROCEDURE (wind:GraphWindow) Destruct*;

BEGIN
  wind.lines.Destruct;
  wind.areas.Destruct;
(*  wind.marks.Destruct;
  wind.points.Destruct;
  wind.texts.Destruct;*)
  wind.graphobjects.Destruct;
  io.WriteString("GW1\n");
  wind.funcs.Destruct;
  io.WriteString("GW2\n");
  wind.axislabels.Destruct;
  wind.grid2.Destruct;
  wind.grid1.Destruct;
  wind.coordsystem.Destruct;

  io.WriteString("GW3\n");
  wind.Destruct^;
  io.WriteString("GW4\n");
END Destruct;

PROCEDURE (graphwind:GraphWindow) Lock*(shareable:BOOLEAN);

BEGIN
  graphwind.funcs.Lock(shareable);
  graphwind.graphobjects.Lock(shareable);
  graphwind.areas.Lock(shareable);
  graphwind.Lock^(shareable);
END Lock;

PROCEDURE (graphwind:GraphWindow) UnLock*;

BEGIN
  graphwind.UnLock^;
  graphwind.areas.UnLock;
  graphwind.graphobjects.UnLock;
  graphwind.funcs.UnLock;
END UnLock;



(* Additional graph window methods *)

PROCEDURE (graphwind:GraphWindow) Auto*;

VAR task : m.Task;

BEGIN
(*  IF p.autofuncscale THEN
    AutoFuncScale(p);
  END;*)
  IF graphwind.sizechanged THEN
    IF graphwind.axislabels.auto THEN
      graphwind.axislabels.Auto(graphwind.rast,graphwind.coordsystem,graphwind.rect);
      task:=graphwind.FindTask(tid.axisLabelsTaskID);
      IF task#NIL THEN
        task.SendNewMsg(m.msgNodeChanged,NIL);
      END;
    END;
    IF graphwind.grid1.auto THEN
      graphwind.grid1.Auto(graphwind.grid2,graphwind.axislabels);
      task:=graphwind.FindTask(tid.gridTaskID);
      IF task#NIL THEN
        task.SendNewMsg(m.msgNodeChanged,NIL);
      END;
    END;
    graphwind.sizechanged:=FALSE;
  END;
END Auto;

PROCEDURE (graphwind:GraphWindow) CheckChanged*(checksize:BOOLEAN):BOOLEAN;

VAR bool : BOOLEAN;

BEGIN
  bool:=graphwind.CheckChanged^(checksize);
  IF bool THEN
    graphwind.Auto;
  END;
  RETURN bool;
END CheckChanged;

PROCEDURE (window:GraphWindow) CreateGraphs*(windfunc:wf.WindowFunction;depend:t.Depend;VAR funcgraph:fg.FunctionGraph);

(* Set depend and funcgraph to windfunc.graphs.head. *)

VAR node2     : l.Node;

BEGIN
  IF depend=NIL THEN
    depend:=windfunc.func.depend.head(t.Depend);
  END;
  node2:=depend.var;
  WITH node2: fb.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF depend.next#NIL THEN
        window.CreateGraphs(windfunc,depend.next(t.Depend),funcgraph);
      ELSE
        IF funcgraph=NIL THEN
          NEW(funcgraph); funcgraph.Init;
          windfunc.graphs.AddTail(funcgraph);
        END;
        funcgraph.InitGraph(window.stutz);
        funcgraph.calced:=FALSE;
        funcgraph:=funcgraph.next(fg.FunctionGraph);
      END;
      node2.real:=node2.real+node2.stepx;
      IF node2.stepx>0 THEN
        IF node2.real>node2.endx THEN
          EXIT;
        END;
      ELSIF node2.stepx<0 THEN
        IF node2.real<node2.endx THEN
          EXIT;
        END;
      ELSE
        EXIT;
      END;
    END;
  END;
END CreateGraphs;

PROCEDURE (window:GraphWindow) PlotGraphs*(windfunc:wf.WindowFunction;depend:t.Depend;VAR funcgraph:fg.FunctionGraph;rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable):BOOLEAN;

(* Set funcgraph to windfunc.graphs.head. *)

VAR node2,newnode : l.Node;
    sizebool,
    sizechanged   : BOOLEAN;

BEGIN
  IF depend=NIL THEN
    depend:=windfunc.func.depend.head(t.Depend);
  END;
  sizebool:=FALSE;
  sizechanged:=FALSE;
  node2:=depend.var;
  WITH node2: fb.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF depend.next#NIL THEN
        sizebool:=window.PlotGraphs(windfunc,depend.next(t.Depend),funcgraph,rast,rect,conv);
      ELSE
        IF NOT(funcgraph(fg.FunctionGraph).calced) THEN
          sizebool:=funcgraph.Plot(rast,window.coordsystem,rect,conv,window,windfunc.func,TRUE,TRUE);
        ELSE
          sizebool:=funcgraph.Plot(rast,window.coordsystem,rect,conv,window,windfunc.func,FALSE,TRUE);
        END;
        funcgraph:=funcgraph.next(fg.FunctionGraph);
      END;
      IF sizebool THEN
        sizechanged:=TRUE;
        EXIT;
      END;
      node2.real:=node2.real+node2.stepx;
      IF node2.stepx>0 THEN
        IF node2.real>node2.endx THEN
          EXIT;
        END;
      ELSIF node2.stepx<0 THEN
        IF node2.real<node2.endx THEN
          EXIT;
        END;
      ELSE
        EXIT;
      END;
    END;
  END;
  RETURN sizechanged;
END PlotGraphs;

PROCEDURE (window:GraphWindow) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable;dragbarplot:BOOLEAN);
(* Set dragbarplot always to FALSE. dragbarplot is set to TRUE if
   DragBar want's to plot this window for an icon. *)

VAR windfunc        : wf.WindowFunction;         (* node *)
    funcgraph       : fg.FunctionGraph;       (* actgraph *)
    node,next       : l.Node;
    layoutplot,
    sizechanged,
    sizebool,bool   : BOOLEAN;
    highest,acthigh : INTEGER;

BEGIN
  IF rast=window.rast THEN layoutplot:=FALSE;
                      ELSE layoutplot:=TRUE; END;
  highest:=0;
  IF ~dragbarplot THEN window.subwindow.SetBusyPointer; END;
  REPEAT

(* ATTENTION: This actually is the Window.Window.Refresh-Method, NOT the
              GraphWindow.Refresh-Method! This could end in an endless loop
              if GraphWindow.Refresh is redefined before GraphWindow.Plot! *)

    IF ~dragbarplot & ~layoutplot THEN window.ClearBack; END;

    IF ~dragbarplot THEN
      IF window.grid2.active THEN
        window.grid2.Plot(rast,window.coordsystem,rect,conv);
      END;
      IF window.grid1.active THEN
        window.grid1.Plot(rast,window.coordsystem,rect,conv);
      END;
  
      node:=window.areas.head;
      WHILE node#NIL DO
        IF node(ao.Area).areab THEN
          IF ~layoutplot THEN
            node(ao.Area).Plot(rast,window.coordsystem,rect,conv,FALSE);
          ELSE
            node(ao.Area).Plot(rast,window.coordsystem,rect,conv,TRUE);
          END;
        END;
        node:=node.next;
      END;
    END;

    IF window.axislabels.active THEN
      window.axislabels.Plot(rast,window.coordsystem,rect,conv,dragbarplot);
    END;

    windfunc:=window.funcs.head(wf.WindowFunction);
    bool:=FALSE;
    sizechanged:=FALSE;
    acthigh:=0;
    WHILE windfunc#NIL DO

(* Every time the user resizes the window the program restarts this WHILE loop.
   To avoid that all wf.WindowFunctions are initialized over and over again each
   time the loop is executed a wf.WindowFunction is only initialized if the
   acthighest-value is bigger than the highest-value.
   That means: The highest-value deters, how many of the wf.WindowFunctions are
   already initialized all right. *)

      windfunc.func.CreateAllTrees; (* To prevent problems with Lock and UnLock. *)
      windfunc.func.Lock(FALSE);
      sizebool:=FALSE;
      INC(acthigh);
      IF (windfunc.changed) AND (acthigh>highest) THEN
        INC(highest);
        windfunc.changed:=FALSE;
        IF windfunc.func(t.Function).depend.isEmpty() THEN
          io.WriteString("GP1\n");
          funcgraph:=windfunc.graphs.head(fg.FunctionGraph);
          io.WriteString("GP2\n");
          IF funcgraph=NIL THEN
            io.WriteString("GP3\n");
            NEW(funcgraph); funcgraph.Init;
            windfunc.graphs.AddTail(funcgraph);
          END;
          io.WriteString("GP4\n");
          funcgraph.InitGraph(window.stutz);
          funcgraph.calced:=FALSE;
          bool:=TRUE;
        ELSE
          funcgraph:=windfunc.graphs.head(fg.FunctionGraph);
          window.CreateGraphs(windfunc,NIL,funcgraph);
          WHILE funcgraph#NIL DO
            next:=funcgraph.next;
            funcgraph.Destruct;
            funcgraph:=next(fg.FunctionGraph);
          END;
          bool:=TRUE;
        END;
      END;
      IF windfunc.func(t.Function).depend.isEmpty() THEN
        io.WriteString("GP5\n");
        IF NOT(windfunc.graphs.head(fg.FunctionGraph).calced) THEN
          io.WriteString("GP6\n");
          sizebool:=windfunc.graphs.head(fg.FunctionGraph).Plot(rast,window.coordsystem,rect,conv,window,windfunc.func,TRUE,(~layoutplot)&(~dragbarplot));
        ELSE
          io.WriteString("GP7\n");
          sizebool:=windfunc.graphs.head(fg.FunctionGraph).Plot(rast,window.coordsystem,rect,conv,window,windfunc.func,FALSE,(~layoutplot)&(~dragbarplot));
        END;
        io.WriteString("GP8\n");
      ELSE
        funcgraph:=windfunc.graphs.head(fg.FunctionGraph);
        sizebool:=window.PlotGraphs(windfunc,NIL,funcgraph,rast,rect,conv);
      END;
      IF sizebool THEN
        sizechanged:=TRUE;
      END;

      windfunc.func.UnLock;
      windfunc:=windfunc.next(wf.WindowFunction);
      IF sizechanged THEN
        window.Resize;
        windfunc:=NIL;
      END;
    END;

    IF ~dragbarplot THEN
      window.graphobjects.Lock(FALSE);
      node:=window.graphobjects.head;
      WHILE node#NIL DO
        node(gb.GraphObject).Lock(FALSE);
        IF node(gb.GraphObject).list#NIL THEN
          node(gb.GraphObject).Plot(rast,rect,conv);
        END;
        node(gb.GraphObject).UnLock;
        node:=node.next;
      END;
      window.graphobjects.UnLock;

      node:=window.areas.head;
      WHILE node#NIL DO
        IF ~node(ao.Area).areab THEN
          IF ~layoutplot THEN
            node(ao.Area).Plot(rast,window.coordsystem,rect,conv,FALSE);
          ELSE
            node(ao.Area).Plot(rast,window.coordsystem,rect,conv,TRUE);
          END;
        END;
        node:=node.next;
      END;
    END;

  (*  node:=p.texts.head;
    WHILE node#NIL DO
      s4.PlotObject(p,node,TRUE);
      node:=node.next;
    END;
    node:=p.marks.head;
    WHILE node#NIL DO
      s4.PlotObject(p,node,TRUE);
      node:=node.next;
    END;
    node:=p.points.head;
    WHILE node#NIL DO
      s4.PlotObject(p,node,TRUE);
      node:=node.next;
    END;
    node:=p.areas.head;
    WHILE node#NIL DO
      IF NOT(node(s1.Area).areab) THEN
        s4.PlotArea(p,node);
      END;
      node:=node.next;
    END;*)
(*    IF sizechanged THEN
      s2.SetAllPointers(TRUE);
    END;*)
  UNTIL NOT(sizechanged);
  IF ~dragbarplot THEN
    window.subwindow.ClearPointer;
    I.RefreshWindowFrame(window.iwind);
  END;
END Plot;

PROCEDURE (window:GraphWindow) Refresh*;

BEGIN
  IF window.changed THEN
    IF window.subwindow#NIL THEN
      window.subwindow.SetBusyPointer;
    END;
    window.Refresh^;
    IF window.subwindow#NIL THEN
      window.subwindow.SetBusyPointer;
    END;
    IF window.iwind#NIL THEN
      window.Lock(FALSE);
      window.Auto;
      window.Plot(window.rast,window.rect,mg.mathconv,FALSE);
      window.UnLock;
    END;
    window.changed:=FALSE;
    IF window.subwindow#NIL THEN
      window.subwindow.ClearPointer;
    END;
  END;
END Refresh;

PROCEDURE (graphwind:GraphWindow) SnapToFunction*(VAR xcoord,ycoord:LONGREAL);

BEGIN
  wf.SnapToFunction(graphwind.funcs,xcoord,ycoord);
END SnapToFunction;

PROCEDURE (graphwind:GraphWindow) SnapToGrid*(VAR xcoord,ycoord:LONGREAL);
END SnapToGrid;



(* Requesters *)

VAR changegraphwind * : wm.Window;

PROCEDURE (graphwind:GraphWindow) Change*(changetask:m.Task):BOOLEAN;

VAR subwind      : wm.SubWindow;
    wind         : I.WindowPtr;
    rast         : g.RastPortPtr;
    root         : gmb.Root;
    titletext,
    numfunctext,
    modetext     : gmo.Text;
    autoy,
    autolabels,
    autogrid     : gmo.CheckboxGadget;
    backcol      : gmo.PaletteGadget;
    numstutz     : gmo.StringGadget;
    gadobj       : gmb.Object;
    glist        : I.GadgetPtr;
    mes          : I.IntuiMessagePtr;
    msg          : m.Message;
    class        : LONGSET;
    titlestr     : ARRAY 256 OF CHAR;
    numfuncstr,
    modestr,str  : ARRAY 80 OF CHAR;
    bool,ret,
    didchange    : BOOLEAN;
    saveautofuncscale,
    saveautolabels,
    saveautogrid : BOOLEAN;
    oldstutz,                (* Needed to recognize whether the functions have to be recalculated or only redisplayed! *)
    savebackcol,
    savestutz    : INTEGER;

  PROCEDURE GetInput;

  VAR i : LONGINT;

  BEGIN
    graphwind.autofuncscale:=autoy.Checked();
    graphwind.axislabels.auto:=autolabels.Checked();
    graphwind.grid1.auto:=autogrid.Checked();
    graphwind.grid2.auto:=autogrid.Checked();
    graphwind.backcol:=SHORT(backcol.GetValue());
    graphwind.stutz:=SHORT(numstutz.GetInteger());
  END GetInput;

  PROCEDURE Backup;

  BEGIN
    saveautofuncscale:=graphwind.autofuncscale;
    saveautolabels:=graphwind.axislabels.auto;
    saveautogrid:=graphwind.grid1.auto;
    savebackcol:=graphwind.backcol;
    savestutz:=graphwind.stutz;
  END Backup;

  PROCEDURE Restore;

  BEGIN
    graphwind.autofuncscale:=saveautofuncscale;
    graphwind.axislabels.auto:=saveautolabels;
    graphwind.grid1.auto:=saveautogrid;
    graphwind.grid2.auto:=saveautogrid;
    graphwind.backcol:=savebackcol;
    graphwind.stutz:=savestutz;
  END Restore;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF changegraphwind=NIL THEN
    changegraphwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.WindowSettings),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changegraphwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    COPY(ac.GetString(ac.Window)^,titlestr);
    st.Append(titlestr,": ");
    st.Append(titlestr,graphwind.windname);
    titletext:=gmo.SetText(s.ADR(titlestr),-1);
    IF st.Length(titlestr)>30 THEN titletext.SetMinVisible(30); END;

    bool:=c.IntToString(graphwind.funcs.nbElements(),numfuncstr,5);
    tt.Clear(numfuncstr);
    st.AppendChar(numfuncstr," ");
    IF graphwind.funcs.nbElements()=1 THEN
      st.Append(numfuncstr,ac.GetString(ac.FunctionDisplayed)^);
    ELSE
      st.Append(numfuncstr,ac.GetString(ac.FunctionsDisplayed)^);
    END;
    numfunctext:=gmo.SetText(s.ADR(numfuncstr),-1);

    COPY(ac.GetString(ac.ModeDP)^,modestr);
(*    st.Append(modestr,": ");*)
    st.Append(modestr,ac.GetString(ac.Cartesian2D)^);
    modetext:=gmo.SetText(s.ADR(modestr),-1);

    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        autoy:=gmo.SetCheckboxGadget(ac.GetString(ac.AutoYRange),graphwind.autofuncscale);
        autolabels:=gmo.SetCheckboxGadget(ac.GetString(ac.AutoAxisLabels),graphwind.axislabels.auto);
        autogrid:=gmo.SetCheckboxGadget(ac.GetString(ac.AutoGrid),graphwind.grid1.auto);
        root.NewSameTextWidth;
          root.AddSameTextWidth(autoy);
          root.AddSameTextWidth(autolabels);
          root.AddSameTextWidth(autogrid);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        backcol:=gmo.SetPaletteGadget(ac.GetString(ac.BackgroundColor),mg.screenmode.depth,s.LSH(1,mg.screenmode.depth),graphwind.backcol);
        numstutz:=gmo.SetStringGadget(ac.GetString(ac.NumberOfSegments),5,gmo.integerType);
        numstutz.SetMinVisible(5);
        numstutz.SetMinMaxInt(50,30000);
      gmb.EndBox;
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  numstutz.SetInteger(graphwind.stutz);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    numstutz.Activate;

    Backup;

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
                numstutz.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
(*              SetData;*)
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              changetask.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            oldstutz:=graphwind.stutz;
            GetInput;
            ret:=TRUE;
            graphwind.changed:=TRUE;
            graphwind.sizechanged:=TRUE;
            IF graphwind.stutz#oldstutz THEN
              graphwind.SendNewMsg(m.msgNodeChanged,m.typeRecalc);
            ELSE
              graphwind.SendNewMsg(m.msgNodeChanged,NIL);
            END;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            oldstutz:=graphwind.stutz;
            Restore;
            IF didchange THEN
              graphwind.changed:=TRUE;
              graphwind.sizechanged:=TRUE;
              IF graphwind.stutz#oldstutz THEN
                graphwind.SendNewMsg(m.msgNodeChanged,m.typeRecalc);
              ELSE
                graphwind.SendNewMsg(m.msgNodeChanged,NIL);
              END;
            END;
            ret:=FALSE;
            EXIT;
          ELSIF NOT(mes.iAddress=root.help) THEN
            oldstutz:=graphwind.stutz;
            GetInput; didchange:=TRUE;
            graphwind.changed:=TRUE;
            graphwind.sizechanged:=TRUE;
            IF graphwind.stutz#oldstutz THEN
              graphwind.SendNewMsg(m.msgNodeChanged,m.typeRecalc);
            ELSE
              graphwind.SendNewMsg(m.msgNodeChanged,NIL);
            END;
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
END Change;

PROCEDURE ChangeGraphWindowTask*(changetask:bt.ANY):bt.ANY;

VAR data : GraphWindow;
    bool : BOOLEAN;

BEGIN
  WITH changetask: m.Task DO
    changetask.InitCommunication;
    data:=changetask.data(GraphWindow);
    bool:=data.Change(changetask);

    data.RemTask(changetask);
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
END ChangeGraphWindowTask;



(* Graph procedure started as task *)

PROCEDURE (graphwind:GraphWindow) MouseRange*(x1,y1:INTEGER):BOOLEAN;
(* TRUE=success *)

VAR coords    : co.CoordSystem;
    task      : m.Task;
    xmin,xmax,
    ymin,ymax : LONGREAL;
    x2,y2     : INTEGER;
    bool      : BOOLEAN;

BEGIN
  bool:=graphwind.SelectBox(x1,y1,x2,y2);
  IF bool THEN
    coords:=graphwind.coordsystem;
    WITH coords: co.CartesianSystem DO
      coords.CurrentToUndo;
      coords.PicToWorld(graphwind.rect,x1,y1,xmin,ymax);
      coords.PicToWorld(graphwind.rect,x2,y2,xmax,ymin);
      coords.xmin:=xmin; coords.xmax:=xmax;
      coords.ymin:=ymin; coords.ymax:=ymax;
      coords.CreateStrings;
      coords.Check;
    END;
    graphwind.SendNewMsg(m.msgSizeChanged,m.typeRecalc);
    task:=graphwind.FindTask(tid.axisRangeTaskID);
    IF task#NIL THEN
      task.SendNewMsg(m.msgNodeChanged,NIL);
    END;
  END;
  RETURN bool;
END MouseRange;

PROCEDURE (graphwind:GraphWindow) CheckInput*(class:LONGSET):BOOLEAN;

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

    PROCEDURE CreateGraphObject(node:gb.GraphObject);
    (* Attention: graphobject has to be allocated already! *)

    (* Copy changes to same procedure in ResultsToPointMarks below. *)

    BEGIN
      node.Init; node(gb.GraphObject).InitGraphObject(graphwind,graphwind.coordsystem);
      graphwind.graphobjects.AddTail(node);
      node(gb.GraphObject).StartChangeTask;
    END CreateGraphObject;

    PROCEDURE ChangeGraphObject;

    BEGIN
      node:=graphwind.graphobjects.Select();
      IF node#NIL THEN
        node(gb.GraphObject).StartChangeTask;
      END;
    END ChangeGraphObject;

    PROCEDURE DeleteGraphObject;

    BEGIN
      node:=graphwind.graphobjects.Select();
      IF node#NIL THEN
        node.Remove;

(* Was a simple node.Destruct. *)

        node(m.ChangeAble).SendNewMsgToAllTasks(m.msgQuit,NIL);
        mem.NodeToGarbage(node(m.ChangeAble));
        graphwind.changed:=TRUE;
        graphwind.Refresh;
      END;
    END DeleteGraphObject;

  BEGIN
    strip:=I.MenuNum(code);
    item:=I.ItemNum(code);
    sub:=I.SubNum(code);

    didmenu:=FALSE;
    IF (mb.mathoptions.autoactive) OR (msg#NIL) THEN
      IF strip=2 THEN
        IF item=1 THEN (* Window settings *)
          task:=graphwind.FindTask(tid.changeTaskID);
          IF task=NIL THEN
            NEW(task); task.Init;
            task.InitTask(ChangeGraphWindowTask,graphwind,10000,m.taskdata.requesterpri);
            task.SetID(tid.changeTaskID);
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.SendNewMsg(m.msgActivate,NIL);
          END;

          didmenu:=TRUE;
        ELSIF item=3 THEN (* Axisrange *)
          task:=graphwind.FindTask(tid.axisRangeTaskID);
          IF task=NIL THEN
            NEW(task); task.Init;
            task.InitTask(co.ChangeCoordsTask,graphwind.coordsystem,10000,m.taskdata.requesterpri);
            task.SetID(tid.axisRangeTaskID);
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.SendNewMsg(m.msgActivate,NIL);
          END;

          didmenu:=TRUE;
        ELSIF item=4 THEN (* Axislabels *)
          task:=graphwind.FindTask(tid.axisLabelsTaskID);
          IF task=NIL THEN
            NEW(task); task.Init;
            task.InitTask(al.ChangeAxisLabelsTask,graphwind.axislabels,10000,m.taskdata.requesterpri);
            task.SetID(tid.axisLabelsTaskID);
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.SendNewMsg(m.msgActivate,NIL);
          END;

          didmenu:=TRUE;
        ELSIF item=5 THEN (* Grid *)
          task:=graphwind.FindTask(tid.gridTaskID);
          IF task=NIL THEN
            NEW(data(gr.ChangeGridData));
            data(gr.ChangeGridData).grid1:=graphwind.grid1;
            data(gr.ChangeGridData).grid2:=graphwind.grid2;
    
            NEW(task); task.Init;
            task.InitTask(gr.ChangeGridTask,data,10000,m.taskdata.requesterpri);
            task.SetID(tid.gridTaskID);
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.SendNewMsg(m.msgActivate,NIL);
          END;

          didmenu:=TRUE;
        ELSIF item=6 THEN (* Graph design *)
          task:=graphwind.FindTask(tid.graphDesignTaskID);
          IF task=NIL THEN
            NEW(data(wf.ChangeGraphDesignData));
            data(wf.ChangeGraphDesignData).graphwind:=graphwind;
            data(wf.ChangeGraphDesignData).funcs:=graphwind.funcs;

            NEW(task); task.Init;
            task.InitTask(wf.ChangeGraphDesignTask,data,10000,m.taskdata.requesterpri);
            task.SetID(tid.graphDesignTaskID);
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.SendNewMsg(m.msgActivate,NIL);
          END;

          didmenu:=TRUE;
        ELSIF item=8 THEN (* Textobject *)
          IF sub=0 THEN   (* Create *)
            NEW(node(to.TextObject));
            CreateGraphObject(node(gb.GraphObject));

            didmenu:=TRUE;
          ELSIF sub=1 THEN (* Change *)
            ChangeGraphObject;

            didmenu:=TRUE;
          ELSIF sub=2 THEN (* Delete *)
            DeleteGraphObject;

            didmenu:=TRUE;
          END;
        ELSIF item=9 THEN (* Pointobject *)
          IF sub=0 THEN   (* Create *)
            NEW(node(pmo.PointObject));
            CreateGraphObject(node(gb.GraphObject));

            didmenu:=TRUE;
          ELSIF sub=1 THEN (* Change *)
            ChangeGraphObject;

            didmenu:=TRUE;
          ELSIF sub=2 THEN (* Delete *)
            DeleteGraphObject;

            didmenu:=TRUE;
          END;
        ELSIF item=11 THEN (* Area *)
          IF sub=0 THEN    (* Create *)
            NEW(node(ao.Area));
            node.Init; node(ao.Area).InitArea(graphwind,graphwind.coordsystem,graphwind.graphobjects);
            graphwind.areas.AddTail(node);
            node(ao.Area).StartChangeTask;

            didmenu:=TRUE;
          ELSIF sub=1 THEN (* Change *)
            node:=geb.SelectNode(graphwind.areas,ac.GetString(ac.SelectHatching),ac.GetString(ac.Hatching),s.ADR("This window does not contain any hatchings!"),mb.mathoptions.quickselect,ao.PrintArea,NIL,mg.mainsub.GetWindow());
            IF node#NIL THEN
              node(ao.Area).StartChangeTask;
            END;

            didmenu:=TRUE;
          ELSIF sub=2 THEN (* Change *)
            node:=geb.SelectNode(graphwind.areas,ac.GetString(ac.SelectHatching),ac.GetString(ac.Hatching),s.ADR("This window does not contain any hatchings!"),mb.mathoptions.quickselect,ao.PrintArea,NIL,mg.mainsub.GetWindow());
            IF node#NIL THEN
              node.Remove;
              node(m.ChangeAble).SendNewMsgToAllTasks(m.msgQuit,NIL);
              mem.NodeToGarbage(node(m.ChangeAble));
              graphwind.changed:=TRUE;
              graphwind.Refresh;
            END;

            didmenu:=TRUE;
          END;
        END;
      ELSIF strip=3 THEN
        IF item=0 THEN (* Find zeros *)
          NEW(task(zo.ZeroObject)); task.Init;
          bool:=task(do.DiscussionObject).InitDiscObject(graphwind,graphwind.funcs,graphwind.coordsystem);
          IF bool THEN
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.Destruct;
          END;

          didmenu:=TRUE;
        ELSIF item=1 THEN (* Find minmax *)
          NEW(task(mo.MinMaxObject)); task.Init;
          bool:=task(do.DiscussionObject).InitDiscObject(graphwind,graphwind.funcs,graphwind.coordsystem);
          IF bool THEN
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.Destruct;
          END;

          didmenu:=TRUE;
        ELSIF item=2 THEN (* Find gaps *)
          NEW(task(gp.GapObject)); task.Init;
          bool:=task(do.DiscussionObject).InitDiscObject(graphwind,graphwind.funcs,graphwind.coordsystem);
          IF bool THEN
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.Destruct;
          END;

          didmenu:=TRUE;
        ELSIF item=3 THEN (* Find points of inflection *)
          NEW(task(ifo.InflectionObject)); task.Init;
          bool:=task(do.DiscussionObject).InitDiscObject(graphwind,graphwind.funcs,graphwind.coordsystem);
          IF bool THEN
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.Destruct;
          END;

          didmenu:=TRUE;
        ELSIF item=4 THEN (* Find points of intersection *)
          NEW(task(iso.IntersectionObject)); task.Init;
          bool:=task(do.DiscussionObject).InitDiscObject(graphwind,graphwind.funcs,graphwind.coordsystem);
          IF bool THEN
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.Destruct;
          END;

          didmenu:=TRUE;
        ELSIF item=6 THEN (* Complete discussion *)
          NEW(task(cmo.CompleteObject)); task.Init;
          bool:=task(cmo.CompleteObject).InitDiscObject(graphwind,graphwind.funcs,graphwind.coordsystem);
          IF bool THEN
            graphwind.AddTask(task);
            graphwind.NewUser(task);
            bool:=task.Start();
          ELSE
            task.Destruct;
          END;

          didmenu:=TRUE;
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
      graphwind.changed:=TRUE;
      graphwind.sizechanged:=TRUE;
      graphwind.Refresh;
      graphwind.SendNewMsgToAllUsers(m.msgSizeChanged,graphwind);
(*      graphwind.Changed;*)
    ELSIF I.closeWindow IN mes.class THEN
      quit:=TRUE;
    END;

    bool:=FALSE;
    node:=graphwind.graphobjects.head;
    WHILE node#NIL DO
      bool:=node(gb.GraphObject).InputEvent(mes);
(* Note: The graph objects sends a change message to the graphwindow
         of it was moved so that the graphwindow refreshes itself
         as soon as it reads the message. *)
      node:=node.next;
      IF bool THEN node:=NIL; END;
    END;
    IF ~bool THEN
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectDown) THEN
        bool:=graphwind.MouseRange(mes.mouseX,mes.mouseY);
      END;
    END;
  END InputEvent;
  
BEGIN
  graphwind.InitCommunication; (* Doesn't matter to call it over and over again. *)
  NEW(mes);
  quit:=FALSE;
  IF graphwind.subwindow#NIL THEN
    REPEAT
      graphwind.subwindow.GetIMes(mes);
      InputEvent(mes);
    UNTIL mes.class=LONGSET{};
  END;
  msg:=NIL;

(* Don't check for graphwind.msgsig here! *)

  REPEAT
    msg:=graphwind.ReceiveMsg();
    IF msg#NIL THEN
      IF msg.type=m.msgQuit THEN
        quit:=TRUE;
      ELSIF msg.type=m.msgClose THEN
        graphwind.SendNewMsgToAllTasks(m.msgClose,NIL);
        graphwind.Close;
      ELSIF msg.type=m.msgOpen THEN
        graphwind.SendNewMsgToAllTasks(m.msgOpen,NIL);
        graphwind.changed:=TRUE;
        graphwind.Refresh;
      ELSIF msg.type=m.msgActivate THEN
        IF graphwind.iwind#NIL THEN
          I.WindowToFront(graphwind.iwind);
          I.ActivateWindow(graphwind.iwind);
        END;
      ELSIF (msg.type=m.msgNodeChanged) OR (msg.type=m.msgSizeChanged) THEN
        IF msg.data#NIL THEN

(*         !!!!!!             *)
(* s.VAL Could cause problems *)
(*         !!!!!!             *)

          IF (msg.data=m.typeRecalc) OR (s.VAL(l.Node,msg.data) IS t.Function) THEN
            node:=graphwind.funcs.head;
            WHILE node#NIL DO
              IF node(wf.WindowFunction).func=msg.data THEN
                node(wf.WindowFunction).changed:=TRUE;
              ELSIF msg.data=m.typeRecalc THEN
                node(wf.WindowFunction).changed:=TRUE;
              END;
              node:=node.next;
            END;
          ELSIF (s.VAL(l.Node,msg.data) IS pmo.PointMarkObject) OR (s.VAL(l.Node,msg.data) IS t.Function) THEN
            node:=graphwind.areas.head;
            WHILE node#NIL DO
              node(ao.Area).GraphObjectChanged(s.VAL(m.ShareAble,msg.data));
              node:=node.next;
            END;
          END;
        END;
        IF graphwind.iwind#NIL THEN
          graphwind.changed:=TRUE;
          IF msg.type=m.msgSizeChanged THEN graphwind.sizechanged:=TRUE; END;
          graphwind.Refresh;
        END;
(*        graphwind.SendNewMsgToAllTasks(m.msgNodeChanged,graphwind);*)
        graphwind.Changed;
      ELSIF msg.type=m.msgMenuAction THEN
        IF graphwind.iwind#NIL THEN
          DoMenu(SHORT(s.VAL(LONGINT,msg.data)));
        END;
      ELSIF msg.type=m.msgNewPriority THEN
        graphwind.SetPriority(m.taskdata.windowpri);
        graphwind.SendNewMsgToAllTasks(m.msgNewPriority,NIL);
      END;
      msg.Reply;
    END;
  UNTIL msg=NIL;

  DISPOSE(mes);
  IF quit THEN
    IF graphwind.list#NIL THEN
      graphwind.Remove;
    END;
    graphwind.SendNewMsgToAllTasks(m.msgQuit,NIL);
    graphwind.ReplyAllMessages;
    graphwind.DestructCommunication;
    graphwind.Close;
(*    graphwind.UnLock;*)
    mem.NodeToGarbage(graphwind);
  END;
  RETURN quit;
END CheckInput;

PROCEDURE GraphWindTask*(gw:bt.ANY):bt.ANY;

VAR class     : LONGSET;
    graphwind : GraphWindow;
    quit      : BOOLEAN;

BEGIN
  graphwind:=gw(GraphWindow);
  quit:=FALSE;
  graphwind.Refresh; (* Open and refresh window *)

  REPEAT
    class:=e.Wait(LONGSET{0..31});
(*    class:=e.Wait(LONGSET{e.sigIntuition,graphwind.msgsig});*)

(* The window is locked because other tasks may use this window
   and thus also its IDCMP-Port (e.g. Area.ChangeArea when selecting
   a point or marker. *)

(*    graphwind.Lock(FALSE);*)
    quit:=graphwind.CheckInput(class);
(*    IF ~quit THEN graphwind.UnLock; END;*)
  UNTIL quit;

  RETURN NIL;
END GraphWindTask;



PROCEDURE (graphwind:GraphWindow) ResultsToPointMarks(list:l.List;type:LONGINT);

VAR graphobj : gb.GraphObject;
    result   : l.Node;

  PROCEDURE CreateGraphObject(node:gb.GraphObject);
  (* Attention: graphobject has to be allocated already! *)

  BEGIN
    node.Init; node(gb.GraphObject).InitGraphObject(graphwind,graphwind.coordsystem);
    graphwind.graphobjects.AddTail(node);
    node(gb.GraphObject).StartChangeTask;
  END CreateGraphObject;

BEGIN
  result:=list.head;
  WHILE result#NIL DO
    IF type=0 THEN NEW(graphobj(pmo.PointObject));
    ELSIF type=1 THEN NEW(graphobj(pmo.MarkObject)); END;
    CreateGraphObject(graphobj);
    graphobj.SetCoordsWorld(graphwind.rect,result(do.Result).xreal,result(do.Result).yreal);
    result:=result.next;
  END;
END ResultsToPointMarks;

PROCEDURE (graphwind:GraphWindow) ResultsToObjects*(list:l.List;type:LONGINT);

VAR result : l.Node;

BEGIN
  IF (type=0) OR (type=1) THEN
    graphwind.ResultsToPointMarks(list,type);
  END;
END ResultsToObjects;



BEGIN
  graphwindows:=Create();
  changegraphwind:=NIL;
CLOSE
  IF graphwindows#NIL THEN graphwindows.Destruct; END;
END GraphWindow.

