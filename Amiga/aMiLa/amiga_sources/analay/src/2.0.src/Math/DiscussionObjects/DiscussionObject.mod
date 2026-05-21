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


MODULE DiscussionObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       st : Strings,
       lrc: LongRealConversions,
       tt : TextTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       gb : GeneralBasics,
       mb : MathBasics,
       mg : MathGUI,
       fb : FunctionBasics,
       w  : Window,
       t  : Terms,
       c  : Coords,
       fg : FunctionGraph,
       wf : WindowFunction,
       ac : AnalayCatalog,
       bt : BasicTypes,
       io,
       NoGuruRq;

TYPE DiscussionObject * = POINTER TO DiscussionObjectDesc;
     DiscussionObjectDesc * = RECORD(m.TaskDesc)
       window       * : w.Window;
       resultlist   * : l.List;
       func         * : t.Function;
       table        * : fg.FuncTable;
       coords       * : c.CoordSystem;
       pos          * : INTEGER;         (* Position in table *)
       xpos*,exact  * : LONGREAL;
       statusbar    * : gme.StatusBar;
       absctext     * ,
       ordtext      * ,
       commenttext  * : gmo.Text;
       resultlv     * : gmo.ListView;
       reqtitle     * ,
       discusstitle * ,
       statustitle  * : e.STRPTR;
     END;

TYPE Result * = POINTER TO ResultDesc;
     ResultDesc * = RECORD(l.NodeDesc)
       dobj      * : DiscussionObject;
       xstring   * ,
       ystring   * ,
       comment   * : ARRAY 256 OF CHAR;
       marked    * : BOOLEAN;
       xreal     * ,
       yreal     * ,
       left*,right*: LONGREAL; (* Left and right border values *)
     END;

PROCEDURE * PrintResult*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;
    dobj : DiscussionObject;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: Result DO
      dobj:=node.dobj;
      NEW(str);
      COPY(node.xstring,str^);
      tt.CutStringToLength(rast,str^,dobj.absctext.width);
      tt.Print(dobj.absctext.xpos,y,str,rast);

      COPY(node.ystring,str^);
      tt.CutStringToLength(rast,str^,dobj.ordtext.width);
      tt.Print(dobj.ordtext.xpos,y,str,rast);

      COPY(node.comment,str^);
      tt.CutStringToLength(rast,str^,dobj.commenttext.width-dobj.resultlv.scrollerwi);
      tt.Print(dobj.commenttext.xpos,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintResult;



PROCEDURE (discussobj:DiscussionObject) Destruct*;

BEGIN
  IF discussobj.resultlist#NIL THEN discussobj.resultlist.Destruct; END;
  IF discussobj.func#NIL THEN discussobj.func.Destruct; END;
  IF discussobj.table#NIL THEN DISPOSE(discussobj.table); END;
  IF discussobj.coords#NIL THEN discussobj.coords.Destruct; END;
  discussobj.Destruct^;
END Destruct;

PROCEDURE (discussobj:DiscussionObject) InitDiscussion*;

BEGIN
  discussobj.resultlist.Init;
  discussobj.xpos:=discussobj.coords(c.CartesianSystem).xmin;
  discussobj.pos:=-1;
END InitDiscussion;

PROCEDURE (discussobj:DiscussionObject) FindNext*():Result;
END FindNext;

PROCEDURE (discussobj:DiscussionObject) AddResult*(result:Result);

VAR node,next : l.Node;
    inserted  : BOOLEAN;

BEGIN
  inserted:=FALSE;
  node:=discussobj.resultlist.head;
  WHILE node#NIL DO
    next:=node.next;
    IF result.xreal<node(Result).xreal THEN
      node.AddBefore(result);
      inserted:=TRUE;
      next:=NIL;
    END;
    node:=next;
  END;
  IF ~inserted THEN
    discussobj.resultlist.AddTail(result);
  END;
END AddResult;

PROCEDURE (discussobj:DiscussionObject) SortResults*;
END SortResults;

VAR discusswind     * ,
    statuswind      * : wm.Window;
    lastprocresults,
    lastprocoptions   : INTEGER;

PROCEDURE (discussobj:DiscussionObject) DiscussionRequester;

VAR subwind      : wm.SubWindow;
    wind         : I.WindowPtr;
    rast         : g.RastPortPtr;
    root         : gmb.Root;
    titletext,
    functext,
    rangetext    : gmo.Text;
    resultlv     : gmo.ListView;
    procresults,                    (* Process results (e.g. List, Points, ...) *)
    procoptions  : gmo.CycleGadget;
    resultsarray : ARRAY 4 OF e.STRPTR;
    optionsarray : ARRAY 3 OF e.STRPTR;
    gadobj       : gmb.Object;
    glist        : I.GadgetPtr;
    mes          : I.IntuiMessagePtr;
    class        : LONGSET;
    msg          : m.Message;
    coords       : c.CoordSystem;
    func         : t.Function;
    funcstr,
    rangestr,str : ARRAY 256 OF CHAR;
    bool,ret     : BOOLEAN;

(* Status window *)

    statussubwind: wm.SubWindow;
    statusiwind  : I.WindowPtr;
    statusroot   : gmb.Root;
    statuscancel : gmo.BooleanGadget;


  PROCEDURE OpenStatusWindow;

  VAR xpos,ypos,i : INTEGER;

  BEGIN
    discusswind.GetDimensions(xpos,ypos,i,i);
    IF statuswind=NIL THEN
      statuswind:=wm.InitWindow(xpos+40,ypos+40,10,10,TRUE,discussobj.statustitle,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
    END;
    statussubwind:=statuswind.InitSub(mg.screen);
    statussubwind.SetTitle(discussobj.statustitle);
  
    statusroot:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{},statussubwind);
      discussobj.statusbar:=gme.SetStatusBar(s.ADR("Status"),0,100,0,-1,s.ADR("%d%%"));
      statuscancel:=gmo.SetBooleanGadget(ac.GetString(ac.Cancel),FALSE);
    glist:=statusroot.EndRoot();
  
    statusroot.Init;
  
    statusiwind:=statussubwind.Open(glist);
    IF statusiwind#NIL THEN
      statusroot.Resize;
    END;
  END OpenStatusWindow;

  PROCEDURE CloseStatusWindow;

  BEGIN
    IF statussubwind#NIL THEN statussubwind.Destruct; END;
    IF statusroot#NIL THEN statusroot.Destruct; END;
  END CloseStatusWindow;

  PROCEDURE GetResults;

  VAR result : Result;

  BEGIN
    subwind.SetBusyPointer;
    OpenStatusWindow;
(*    discussobj.window.Lock(TRUE);*)
    discussobj.InitDiscussion;

    REPEAT
      result:=discussobj.FindNext();
      IF result#NIL THEN
        result.dobj:=discussobj;
        discussobj.AddResult(result);
        resultlv.SetValue(discussobj.resultlist.nbElements()-1);
        resultlv.Refresh;
      END;
      REPEAT root.GetIMes(mes); UNTIL mes.class=LONGSET{};
      REPEAT
        statusroot.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=statuscancel.gadget THEN
            result:=NIL;
          END;
        END;
      UNTIL mes.class=LONGSET{};
    UNTIL result=NIL;

(*    discussobj.window.UnLock;*)
    CloseStatusWindow;
    discussobj.SortResults;
    resultlv.Refresh;
    subwind.ClearPointer;
  END GetResults;

  PROCEDURE GetInput;

  BEGIN
    lastprocresults:=SHORT(procresults.GetValue());
    lastprocoptions:=SHORT(procoptions.GetValue());
  END GetInput;

BEGIN
  io.WriteString("DR1\n");
  func:=discussobj.func;
  coords:=discussobj.coords;
  WITH coords: c.CartesianSystem DO
    NEW(mes);
  io.WriteString("DR2\n");
    ret:=FALSE;
    IF discusswind=NIL THEN
      discusswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,discussobj.reqtitle,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
    END;
    subwind:=discusswind.InitSub(mg.screen);
    subwind.SetTitle(discussobj.reqtitle);
  io.WriteString("DR3\n");

(* Creating funcstr *)
    COPY(func.name,funcstr);
    IF func.diffunc#NIL THEN
      st.Append(funcstr,"; ");
      st.Append(funcstr,func.diffunc.name);
    END;

(* Creating rangestr *)
    COPY(ac.GetString(ac.XAxisDomain)^,rangestr);
    st.Append(rangestr,": ");
    bool:=lrc.RealToString(coords(c.CartesianSystem).xmin,str,6,2,FALSE);
    tt.Clear(str);
    st.Append(rangestr,str);
    st.Append(rangestr,"..");
    bool:=lrc.RealToString(coords(c.CartesianSystem).xmax,str,6,2,FALSE);
    tt.Clear(str);
    st.Append(rangestr,str);
  
  io.WriteString("DR4\n");
    root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
      titletext:=gmo.SetText(discussobj.discusstitle,-1);
      functext:=gmo.SetText(s.ADR(funcstr),-1);
      functext.SetMinVisible(20);
      rangetext:=gmo.SetText(s.ADR(rangestr),-1);
      gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,NIL);
        discussobj.absctext:=gmo.SetText(ac.GetString(ac.Abscissa),-1);
        discussobj.absctext.SetMinVisible(15);
        discussobj.absctext.SetSizeX(1);
        discussobj.ordtext:=gmo.SetText(ac.GetString(ac.Ordinate),-1);
        discussobj.ordtext.SetMinVisible(15);
        discussobj.ordtext.SetSizeX(1);
        discussobj.commenttext:=gmo.SetText(ac.GetString(ac.Comment),-1);
        discussobj.commenttext.SetMinVisible(20);
        discussobj.commenttext.SetSizeX(4);
      gmb.EndBox;
      resultlv:=gmo.SetListView(NIL,discussobj.resultlist,PrintResult,0,FALSE,255);
      resultlv.SetOutValues(0,0);
      discussobj.resultlv:=resultlv;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        resultsarray[0]:=ac.GetString(ac.AsList);
        resultsarray[1]:=ac.GetString(ac.AsPoints);
        resultsarray[2]:=ac.GetString(ac.AsMarkers);
        resultsarray[3]:=NIL;
        procresults:=gmo.SetCycleGadget(NIL,s.ADR(resultsarray),lastprocresults);
  
        optionsarray[0]:=ac.GetString(ac.DefaultList);
        optionsarray[1]:=ac.GetString(ac.CustomList);
        optionsarray[2]:=NIL;
        procoptions:=gmo.SetCycleGadget(NIL,s.ADR(optionsarray),lastprocoptions);
      gmb.EndBox;
    glist:=root.EndRoot();
  
  io.WriteString("DR5\n");
    root.Init;
  io.WriteString("DR6\n");
  
    wind:=subwind.Open(glist);
  io.WriteString("DR7\n");
    IF wind#NIL THEN
      rast:=wind.rPort;
      root.Resize;
  io.WriteString("DR8\n");
  
      GetResults;
  io.WriteString("DR9\n");
  
      LOOP
        class:=e.Wait(LONGSET{0..31});
        IF discussobj.msgsig IN class THEN
          REPEAT
            msg:=discussobj.ReceiveMsg();
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
  (*            grid1.window.changed:=TRUE;
              grid1.window.SendNewMsg(m.msgNodeChanged,NIL);*)
              EXIT;
            ELSIF mes.iAddress=root.ca THEN
  (*            IF didchange THEN
                grid1.window.changed:=TRUE;
                grid1.window.SendNewMsg(m.msgNodeChanged,NIL);
              END;*)
              ret:=FALSE;
              EXIT;
            ELSIF NOT(mes.iAddress=root.help) THEN
              GetInput;(* didchange:=TRUE;*)
  (*            grid1.window.changed:=TRUE;
              grid1.window.SendNewMsg(m.msgNodeChanged,NIL);*)
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
  ELSE END;
END DiscussionRequester;

PROCEDURE DiscussionTask*(disctask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH disctask: DiscussionObject DO
    disctask.InitCommunication;
    disctask.DiscussionRequester;
  
    disctask.window.RemTask(disctask);
    disctask.ReplyAllMessages;
    disctask.DestructCommunication;
    mem.NodeToGarbage(disctask);
    disctask.window.FreeUser(disctask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END DiscussionTask;



PROCEDURE (discussobj:DiscussionObject) Init*;

BEGIN
  discussobj.window:=NIL;
  discussobj.resultlist:=l.Create(); discussobj.resultlist.Init;
  discussobj.exact:=0.0000001;
  discussobj.reqtitle:=s.ADR("Points of interest");
  discussobj.discusstitle:=s.ADR("Points of interest of function");
  discussobj.statustitle:=s.ADR("Status");

  discussobj.Init^;
  discussobj.InitTask(DiscussionTask,discussobj,10000,m.taskdata.requesterpri);
  discussobj.SetID(tid.noID);
END Init;

PROCEDURE (discussobj:DiscussionObject) InitDiscObject*(window:w.Window;funcs:l.List;coords:c.CoordSystem):BOOLEAN;

VAR func : l.Node;

BEGIN
  func:=gb.SelectNode(funcs,ac.GetString(ac.SelectFunction),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,mg.mainsub.GetWindow());
  IF func#NIL THEN
    WITH func: wf.WindowFunction DO
      discussobj.window:=window;
      discussobj.func:=func.func.CopyNew()(t.Function);
      IF func.graphs.nbElements()=1 THEN
        discussobj.table:=fg.CopyFuncTableNew(func.graphs.head(fg.FunctionGraph).table);
      END;
      discussobj.coords:=coords.CopyNew()(c.CoordSystem);
    END;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END InitDiscObject;



(* Discussion basics *)

PROCEDURE GetNextValue*(VAR r:LONGREAL);

BEGIN
  IF r>0.1 THEN r:=0.1;
  ELSIF r>0.01 THEN r:=0.01;
  ELSIF r>0.001 THEN r:=0.001;
  ELSIF r>0.0001 THEN r:=0.0001;
  ELSIF r>0.00001 THEN r:=0.00001;
  ELSIF r>0.000001 THEN r:=0.000001;
  ELSIF r>0.0000001 THEN r:=0.0000001;
  ELSIF r>0.00000001 THEN r:=0.00000001;
  ELSIF r>0.000000001 THEN r:=0.000000001;
  ELSIF r>0.0000000001 THEN r:=0.0000000001;
  END;
END GetNextValue;

PROCEDURE GetAccuracy*(numdigits:INTEGER):LONGREAL;

VAR i : INTEGER;

BEGIN
  IF numdigits=0 THEN RETURN 1.0D0;
  ELSIF numdigits=1 THEN RETURN 1.0D-1;
  ELSIF numdigits=2 THEN RETURN 1.0D-2;
  ELSIF numdigits=3 THEN RETURN 1.0D-3;
  ELSIF numdigits=4 THEN RETURN 1.0D-4;
  ELSIF numdigits=5 THEN RETURN 1.0D-5;
  ELSIF numdigits=6 THEN RETURN 1.0D-6;
  ELSIF numdigits=7 THEN RETURN 1.0D-7;
  ELSIF numdigits=8 THEN RETURN 1.0D-8;
  ELSIF numdigits=9 THEN RETURN 1.0D-9;
  ELSIF numdigits=10 THEN RETURN 1.0D-10;
  ELSE RETURN fb.PowLong(-numdigits,10,i);
  END;
END GetAccuracy;


BEGIN
  discusswind:=NIL;
  statuswind:=NIL;
END DiscussionObject.

