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


MODULE WindowFunction;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       bt : BasicTypes,
       st : Strings,
       lrc: LongRealConversions,
       ac : AnalayCatalog,
       tt : TextTools,
       rt : RequesterTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       go : GraphicObjects,
       m  : Multitasking,
       mem: MemoryManager,
       mg : MathGUI,
       fb : FunctionBasics,
       t  : Terms,
       fg : FunctionGraph,
       w  : Window,
       io,
       NoGuruRq;

TYPE WindowFunction * = POINTER TO WindowFunctionDesc;
     WindowFunctionDesc * = RECORD(m.MTNodeDesc)
       window  * : w.Window;    (* Window this WindowFunction belongs to *)
       func    * : t.Function;
       graphs  * : l.List;      (* List of fg.FunctionGraph *)
       changed * : BOOLEAN;
     END;

PROCEDURE (windfunc:WindowFunction) Init*;

BEGIN
  windfunc.window:=NIL;
  windfunc.func:=NIL;
  windfunc.graphs:=l.Create();
  windfunc.Init^;
END Init;

PROCEDURE (windfunc:WindowFunction) Destruct*;

BEGIN
  io.WriteString("WF1\n");
  IF windfunc.func#NIL THEN
    io.WriteString("WF2\n");
    windfunc.func.FreeUser(windfunc.window);
    io.WriteString("WF3\n");
  END;
  io.WriteString("WF4\n");
  windfunc.graphs.Destruct;
  io.WriteString("WF5\n");
  windfunc.Destruct^;
  io.WriteString("WF6\n");
END Destruct;

PROCEDURE * PrintWindowFunction*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF datalist#NIL THEN
    node:=datalist.GetNode(num);
    IF node#NIL THEN
      WITH node: WindowFunction DO
        NEW(str);
        COPY(node.func(t.Function).name,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str);
      END;
    END;
  END;
END PrintWindowFunction;

PROCEDURE (windfunc:WindowFunction) SetToRecalc*;

VAR node : l.Node;

BEGIN
  node:=windfunc.graphs.head;
  WHILE node#NIL DO
    node(fg.FunctionGraph).calced:=FALSE;
    node:=node.next;
  END;
END SetToRecalc;



TYPE Value = POINTER TO ValueDesc;
     ValueDesc = RECORD(l.NodeDesc)
       real    : LONGREAL;
       defined : BOOLEAN;
     END;

PROCEDURE SnapToFunction*(windfunclist:l.List;VAR x,y:LONGREAL);

(* List of WindowFunctions. *)

VAR node,
    node2: l.Node;
    list : l.List; (* Should be replaced by an array. *)
    pos  : INTEGER;
    dist : LONGREAL;

PROCEDURE CheckGraphs(func,node:l.Node);

VAR node2,node3 : l.Node;

BEGIN
  node2:=node(t.Depend).var;
  WITH node2: fb.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF node.next#NIL THEN
        CheckGraphs(func,node.next);
      ELSE
        NEW(node3(Value));
        pos:=0;
        node3(Value).real:=func(t.Function).GetFunctionValue(x,0,pos);
        IF pos=0 THEN
          node3(Value).defined:=TRUE;
        ELSE
          node3(Value).defined:=FALSE;
        END;
        list.AddTail(node3);
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
END CheckGraphs;

BEGIN
  list:=l.Create();
  node:=windfunclist.head;
  WHILE node#NIL DO
    IF node(WindowFunction).func.depend.isEmpty() THEN
      NEW(node2(Value));
      pos:=0;
      node2(Value).real:=node(WindowFunction).func.GetFunctionValue(x,0,pos);
      IF pos=0 THEN
        node2(Value).defined:=TRUE;
      ELSE
        node2(Value).defined:=FALSE;
      END;
      list.AddTail(node2);
    ELSE
      CheckGraphs(node(WindowFunction).func,node(WindowFunction).func.depend.head);
    END;
    node:=node.next;
  END;
  dist:=1000000;
  node2:=NIL;
  node:=list.head;
  WHILE node#NIL DO
    IF (ABS(node(Value).real-y)<dist) AND (node(Value).defined) THEN
      dist:=ABS(node(Value).real-y);
      node2:=node;
    END;
    node:=node.next;
  END;
  IF node2#NIL THEN
    y:=node2(Value).real;
  END;
  list.Destruct;
END SnapToFunction;



VAR graphdesignwind * : wm.Window;

PROCEDURE ChangeGraphDesign*(changedesigntask:m.Task;funcs:l.List;graphwind:w.Window):BOOLEAN;

VAR subwind  : wm.SubWindow;
    wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    root     : gmb.Root;
    palette  : gmo.PaletteGadget;
    pattern,
    thickness: gmo.SelectBox;
    funclv,
    graphlv  : gmo.ListView;
    gadobj   : gmb.Object;
    glist    : I.GadgetPtr;
    mes      : I.IntuiMessagePtr;
    class    : LONGSET;
    msg      : m.Message;
    actfunc  : WindowFunction;
    actgraph : fg.FunctionGraph;
    depth    : INTEGER;
    bool,ret,
    didchange: BOOLEAN;

PROCEDURE CreateGraphStrings;

VAR windfunc   : l.Node;
    depend     : l.Node;
    graph      : l.Node;

  PROCEDURE WriteParts(windfunc:WindowFunction;depend:l.Node;VAR graph:l.Node);
  
  VAR var : fb.Variable;
  
    PROCEDURE CreateName;
    
    VAR depend : l.Node;
        str    : ARRAY 20 OF CHAR;
        length : INTEGER;
        bool   : BOOLEAN;
    
    BEGIN
      WITH graph: fg.FunctionGraph DO
        IF graph.varstr#NIL THEN
          DISPOSE(graph.varstr);
          graph.varstr:=NIL;
        END;
  
  (* Getting length of varstr *)
  
        length:=0;
        depend:=windfunc.func.depend.head;
        WHILE depend#NIL DO
          bool:=lrc.RealToString(depend(t.Depend).var(fb.Variable).real,str,7,7,FALSE);
          tt.Clear(str);
          length:=length+SHORT(st.Length(depend(t.Depend).var(fb.Variable).name^)+1+st.Length(str));
          IF depend.next#NIL THEN
            INC(length);
          END;
          depend:=depend.next;
        END;
  
        NEW(graph.varstr,length+1);
  
        IF graph.varstr#NIL THEN
          graph.varstr^:="";
          depend:=windfunc.func.depend.head;
          WHILE depend#NIL DO
            st.Append(graph.varstr^,depend(t.Depend).var(fb.Variable).name^);
            st.AppendChar(graph.varstr^,"=");
            bool:=lrc.RealToString(depend(t.Depend).var(fb.Variable).real,str,7,7,FALSE);
            tt.Clear(str);
            st.Append(graph.varstr^,str);
            IF depend.next#NIL THEN
              st.AppendChar(graph.varstr^,",");
            END;
            depend:=depend.next;
          END;
        END;
      END;
    END CreateName;
    
  BEGIN
    var:=depend(t.Depend).var(fb.Variable);
    var.real:=var.startx;
    LOOP
      IF depend.next#NIL THEN
        WriteParts(windfunc,depend.next(t.Depend),graph);
      ELSE
        CreateName;
        graph:=graph.next;
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
  graphwind.Lock(FALSE);
  windfunc:=funcs.head;
  WHILE windfunc#NIL DO
    graph:=windfunc(WindowFunction).graphs.head;
    WHILE graph#NIL DO
      graph(fg.FunctionGraph).Backup;
      graph:=graph.next;
    END;

    depend:=windfunc(WindowFunction).func(t.Function).depend.head;
    graph:=windfunc(WindowFunction).graphs.head;
    IF depend#NIL THEN
      WriteParts(windfunc(WindowFunction),depend,graph);
    END;
    windfunc:=windfunc.next;
  END;
  graphwind.UnLock;
END CreateGraphStrings;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    funclv.SetValue(funcs.GetNodeNumber(actfunc));
  ELSE
    funclv.Refresh;
  END;
END RefreshFunc;

PROCEDURE RefreshGraph;

BEGIN
  IF actfunc.func(t.Function).depend.nbElements()>0 THEN
    graphlv.ChangeListView(actfunc.graphs,SHORT(graphlv.GetValue()));
  ELSE
    graphlv.ChangeListView(NIL,0);
  END;
END RefreshGraph;

PROCEDURE NewGraph;

BEGIN
  palette.SetValue(actgraph.color);
  pattern.SetValue(actgraph.pattern);
  thickness.SetValue(actgraph.thickness-1);
END NewGraph;

PROCEDURE NewFunction;

BEGIN
  RefreshGraph;
  NewGraph;
END NewFunction;

PROCEDURE GetInput;

BEGIN
  actgraph.color:=SHORT(palette.GetValue());
  actgraph.pattern:=SHORT(pattern.GetValue());
  actgraph.thickness:=SHORT(thickness.GetValue())+1;
END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF funcs.isEmpty() THEN
    bool:=rt.RequestWin(ac.GetString(ac.InThisWindowNo),ac.GetString(ac.FunctionsAreDisplayed),s.ADR(""),ac.GetString(ac.OK),mg.window);
  ELSE
    IF graphdesignwind=NIL THEN
      graphdesignwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.FunctionDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
    END;
    subwind:=graphdesignwind.InitSub(mg.screen);
  
    root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
      depth:=s.LSH(1,mg.screenmode.depth); IF depth>16 THEN depth:=16; END;
      gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Design));
        palette:=gmo.SetPaletteGadget(ac.GetString(ac.Color),mg.screenmode.depth,depth,0);
        pattern:=gmo.SetSelectBox(ac.GetString(ac.LinePattern),10,0,5,2,16,mg.window.rPort.txHeight*3 DIV 8,-1,gmo.horizOrient,go.PlotPatternLine);
        thickness:=gmo.SetSelectBox(ac.GetString(ac.LineThickness),5,0,2,3,16*4,mg.window.rPort.txHeight*7 DIV 8,-1,gmo.vertOrient,go.PlotThicknessLine);
      gmb.EndBox;
      funclv:=gmo.SetListView(ac.GetString(ac.Functions),funcs,t.PrintFunction,0,FALSE,255);
      graphlv:=gmo.SetListView(ac.GetString(ac.FunctionFamilies),NIL,fg.PrintFunctionGraph,0,FALSE,255);
    glist:=root.EndRoot();
    funclv.SetNoEntryText(s.ADR("No funcitons!"));
    graphlv.SetNoEntryText(s.ADR("No family!"));

    root.Init;
  
    wind:=subwind.Open(glist);
    IF wind#NIL THEN
      rast:=wind.rPort;
      root.Resize;

      CreateGraphStrings; (* Also calls FunctionGraph.Backup *)

      actfunc:=funcs.head(WindowFunction);
      IF actfunc#NIL THEN
        actgraph:=actfunc.graphs.head(fg.FunctionGraph);
      ELSE
        actgraph:=NIL;
      END;

      NewFunction;
      RefreshFunc;

      didchange:=FALSE;
      LOOP
        class:=e.Wait(LONGSET{0..31});
        IF changedesigntask.msgsig IN class THEN
          REPEAT
            msg:=changedesigntask.ReceiveMsg();
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
                ELSE
                  msg.Reply;
                  EXIT;
                END;
              ELSIF msg.type=m.msgNodeChanged THEN
(*                SetData;*)
              ELSIF msg.type=m.msgActivate THEN
                subwind.ToFront;
              ELSIF msg.type=m.msgNewPriority THEN
                changedesigntask.SetPriority(m.taskdata.requesterpri);
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
              EXIT;
            ELSIF mes.iAddress=root.ca THEN
              actfunc:=funcs.head(WindowFunction);
              WHILE actfunc#NIL DO
                actgraph:=actfunc.graphs.head(fg.FunctionGraph);
                WHILE actgraph#NIL DO
                  actgraph.Restore;
                  IF actgraph#NIL THEN
                    actgraph:=actgraph.next(fg.FunctionGraph);
                  ELSE
                    actgraph:=NIL;
                  END;
                END;
                IF actfunc.next#NIL THEN
                  actfunc:=actfunc.next(WindowFunction);
                ELSE
                  actfunc:=NIL;
                END;
              END;
  
              IF didchange THEN
                graphwind.changed:=TRUE;
                graphwind.SendNewMsg(m.msgNodeChanged,NIL);
              END;
              EXIT;
            ELSIF mes.iAddress=funclv.scrollgad THEN
              IF mes.code=gmo.newActEntry THEN
                GetInput;
                actfunc:=funcs.GetNode(funclv.GetValue())(WindowFunction);
                actgraph:=actfunc.graphs.head(fg.FunctionGraph);
                NewFunction;
              END;
            ELSIF mes.iAddress=graphlv.scrollgad THEN
              IF mes.code=gmo.newActEntry THEN
                GetInput;
                actgraph:=actfunc.graphs.GetNode(graphlv.GetValue())(fg.FunctionGraph);
                NewGraph;
              END;
            ELSIF NOT(mes.iAddress=root.help) THEN
              GetInput;
            
              didchange:=TRUE;
              graphwind.changed:=TRUE;
              graphwind.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          END;
  (*        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
            ag.ShowFile(s1.analaydoc,"changefuncs",wind);
          END;*)
        UNTIL mes.class=LONGSET{};
      END;
  
      subwind.Destruct;
    END;
    root.Destruct;
  END;
  DISPOSE(mes);
  RETURN ret;
END ChangeGraphDesign;

TYPE ChangeGraphDesignData * = POINTER TO ChangeGraphDesignDataDesc;
     ChangeGraphDesignDataDesc * = RECORD(bt.ANYDesc)
       graphwind * : w.Window;
       funcs     * : l.List;
     END;

PROCEDURE ChangeGraphDesignTask*(changedesigntask:bt.ANY):bt.ANY;

VAR data : ChangeGraphDesignData;
    bool : BOOLEAN;

BEGIN
  WITH changedesigntask: m.Task DO
    changedesigntask.InitCommunication;
    data:=changedesigntask.data(ChangeGraphDesignData);
    bool:=ChangeGraphDesign(changedesigntask,data.funcs,data.graphwind);

    data.graphwind.RemTask(changedesigntask);
    changedesigntask.ReplyAllMessages;
    changedesigntask.DestructCommunication;
    mem.NodeToGarbage(changedesigntask);
    data.graphwind.FreeUser(changedesigntask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeGraphDesignTask;



BEGIN
  graphdesignwind:=NIL;
END WindowFunction.

