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


MODULE CompleteObject;

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
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       gb : GeneralBasics,
       fb : FunctionBasics,
       mb : MathBasics,
       mg : MathGUI,
       w  : Window,
       t  : Terms,
       c  : Coords,
       fg : FunctionGraph,
       wf : WindowFunction,
       do : DiscussionObject,
       zo : ZeroObject,
       mo : MinMaxObject,
       ifo: InflectionObject,
       sym: Symmetry,
       ac : AnalayCatalog,
       bt : BasicTypes,
       NoGuruRq;


TYPE String * = POINTER TO StringDesc;
     StringDesc * = RECORD(l.NodeDesc)
       string * : UNTRACED POINTER TO ARRAY OF CHAR;
       style  * : SHORTSET;
     END;

PROCEDURE (string:String) Destruct*;

BEGIN
  IF string.string#NIL THEN
    DISPOSE(string.string);
  END;
END Destruct;

PROCEDURE * PrintString*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node       : l.Node;
    str        : UNTRACED POINTER TO ARRAY OF CHAR;
    mask,style : SHORTSET;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: String DO
      NEW(str,st.Length(node.string^)+1);
      COPY(node.string^,str^);
      tt.CutStringToLength(rast,str^,width);
      mask:=g.AskSoftStyle(rast);
      style:=g.SetSoftStyle(rast,node.style,mask);
      tt.Print(x,y,s.ADR(str^),rast);
      mask:=g.AskSoftStyle(rast);
      style:=g.SetSoftStyle(rast,SHORTSET{},mask);
      DISPOSE(str);
    END;
  END;
END PrintString;

TYPE CompleteObject * = POINTER TO CompleteObjectDesc;
     CompleteObjectDesc * = RECORD(m.TaskDesc);
       window   * : w.Window;
       func     * : t.Function;
       funcder  * : l.List;        (* Derivatives of function *)
       table    * : fg.FuncTable;
       coords   * : c.CoordSystem;
       resultlist*: l.List;        (* Nodetype: String *)
       resultlv * : gmo.ListView;
     END;

TYPE CompleteOptions * = POINTER TO CompleteOptionsDesc;
     CompleteOptionsDesc * = RECORD
       derivatives,
       symmetry,
       zeros,
       extremes,
       inflections      : BOOLEAN;
       derivativenum,
       zerodigits,
       extremedigits,
       inflectiondigits : INTEGER;
     END;

PROCEDURE (copts:CompleteOptions) Init*;

BEGIN
  copts.derivatives:=TRUE;
  copts.symmetry:=TRUE;
  copts.zeros:=TRUE;
  copts.extremes:=TRUE;
  copts.inflections:=TRUE;
  copts.derivativenum:=3;
  copts.zerodigits:=7;
  copts.extremedigits:=4;
  copts.inflectiondigits:=7;
END Init;



VAR completewind * : wm.Window;
    completeopts * : CompleteOptions;

PROCEDURE (cobj:CompleteObject) AddResult*(string:ARRAY OF CHAR;style:SHORTSET);

VAR result : String;

BEGIN
  NEW(result);
  NEW(result.string,st.Length(string)+1);
  COPY(string,result.string^);
  result.style:=style;
  cobj.resultlist.AddTail(result);
  IF cobj.resultlv#NIL THEN cobj.resultlv.Refresh; END;
END AddResult;

PROCEDURE (cobj:CompleteObject) DiscussionRequester*;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    ok,ca,print,
    help,textbox: gmo.BooleanGadget;
    resultlv    : gmo.ListView;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    class       : LONGSET;
    msg         : m.Message;
    coords      : c.CoordSystem;
    func        : t.Function;
    bool,ret    : BOOLEAN;

  PROCEDURE PrintOut;
  
  VAR node  : l.Node;
      handle: d.FileHandlePtr;
      str   : ARRAY 1024 OF CHAR;
      long  : LONGINT;
  
  BEGIN
    handle:=NIL;
    handle:=d.Open("prt:",d.oldFile);
  
    IF handle#NIL THEN
      node:=cobj.resultlist.head;
      WHILE node#NIL DO
        WITH node: String DO
          str:="";
          IF g.bold IN node.style THEN
            str:="\[1m";
          END;
          st.Append(str,node.string^);
          IF g.bold IN node.style THEN
            st.Append(str,"\[22m");
          END;
          st.AppendChar(str,"\n");
          long:=d.Write(handle,str,st.Length(str));
        END;
        node:=node.next;
      END;
    END;
  
    bool:=d.Close(handle);
  END PrintOut;
  
  PROCEDURE CheckInput():BOOLEAN;

  BEGIN
    REPEAT
      root.GetIMes(mes);
      IF (I.gadgetUp IN mes.class) & (mes.iAddress=ca.gadget) THEN
        RETURN TRUE;
      END;
    UNTIL mes.class=LONGSET{};
    RETURN FALSE;
  END CheckInput;

  PROCEDURE PrintFunction(func:t.Function;anz:INTEGER);
  
  VAR term,node,
      firstnode,
      node2,
      functerm  : l.Node;
      max,a     : INTEGER;
      first     : BOOLEAN;
      string    : ARRAY 1024 OF CHAR;
  
  BEGIN
    max:=0;
    firstnode:=NIL;
    first:=TRUE;
    functerm:=func.terms.head;
    WHILE functerm#NIL DO
      term:=functerm(t.FuncTerm).term;
      IF first THEN
        string:="  f(x) = ";
      ELSE
        string:="         ";
      END;
(*      IF ableitung THEN*)
        IF (anz>0) AND (first) THEN
          FOR a:=1 TO anz DO
            st.InsertChar(string,3,"'");
          END;
          IF completeopts.derivativenum-anz>0 THEN
            FOR a:=1 TO completeopts.derivativenum-anz DO
              st.InsertChar(string,6+anz," ");
            END;
          END;
        ELSE
          FOR a:=1 TO completeopts.derivativenum DO
            st.InsertChar(string,6," ");
          END;
        END;
(*      END;*)
      st.Append(string,term(t.Term).term^);
      IF st.Length(string)>max THEN
        max:=SHORT(st.Length(string));
      END;
      cobj.AddResult(string,SHORTSET{});
      IF firstnode=NIL THEN
        firstnode:=cobj.resultlist.tail;
      END;
      node2:=term(t.Term).define.head;
      IF node2#NIL THEN
        node2:=node2.next;
      END;
      WHILE node2#NIL DO
        cobj.AddResult(string,SHORTSET{});
        string:="";
        node2:=node2.next;
      END;
      functerm:=functerm.next;
      first:=FALSE;
    END;
    INC(max,2);
    functerm:=func.terms.head;
    WHILE functerm#NIL DO
      IF NOT(term(t.Term).define.isEmpty()) THEN
        term:=functerm(t.FuncTerm).term;
        WHILE st.Length(firstnode(String).string^)<max DO
          st.AppendChar(firstnode(String).string^," ");
        END;
      END;
      node:=term(t.Term).define.head;
      WHILE node#NIL DO
        IF node=term(t.Term).define.head THEN
          st.Append(firstnode(String).string^,ac.GetString(ac.ForRange)^);
          st.AppendChar(firstnode(String).string^," ");
        ELSE
          st.Append(firstnode(String).string^,ac.GetString(ac.And)^);
          st.AppendChar(firstnode(String).string^," ");
        END;
        st.Append(firstnode(String).string^,node(t.Define).string);
        node:=node.next;
        IF node#NIL THEN
          firstnode:=firstnode.next;
        END;
      END;
      firstnode:=firstnode.next;
      functerm:=functerm.next;
    END;
  END PrintFunction;
  
  PROCEDURE GetResults():BOOLEAN;

  VAR funcder,new : t.Function;
      symdata     : sym.SymmetryData;
      dobj        : do.DiscussionObject;
      result      : do.Result;
      firststring : String;
      funcgraph   : fg.FunctionGraph;
      string,str  : ARRAY 256 OF CHAR;
      i,dernum,
      maxlen      : INTEGER;
      found       : BOOLEAN;

    PROCEDURE DestructDObj(dobj:do.DiscussionObject);

    BEGIN
      dobj.func:=NIL;    (* This prevents the dobj.Destruct-Method *)
      dobj.table:=NIL;   (* from Destructing func, table and coords. *)
      dobj.coords:=NIL;
      dobj.Destruct;
    END DestructDObj;

  BEGIN
(* Writing function *)

    cobj.resultlist.Init;
    cobj.AddResult(ac.GetString(ac.AnalysisOfFunction)^,SHORTSET{g.bold});
    PrintFunction(func,0);

(* Derivatives *)

    IF CheckInput() THEN RETURN FALSE; END;
    IF completeopts.derivatives THEN
      cobj.AddResult("",SHORTSET{});
      cobj.AddResult(ac.GetString(ac.Derivatives)^,SHORTSET{g.bold});
    END;
    dernum:=completeopts.derivativenum;
    IF dernum<2 THEN dernum:=2; END;
    funcder:=func;
    FOR i:=1 TO dernum DO
      new:=funcder.AbleitFunction("x");
      funcder:=new;
      cobj.funcder.AddTail(funcder);
      IF completeopts.derivatives THEN
        PrintFunction(funcder,i);
      END;
      IF CheckInput() THEN RETURN FALSE; END;
    END;
    IF i>1 THEN funcder.Destruct; END;

(* Symmetry *)

    IF CheckInput() THEN RETURN FALSE; END;
    IF completeopts.symmetry THEN
      cobj.AddResult("",SHORTSET{});
      symdata:=sym.FindSymmetry(func,TRUE);
      IF symdata#NIL THEN
        cobj.AddResult(ac.GetString(ac.Symmetry)^,SHORTSET{g.bold});
        string:="  ";
        CASE symdata.type OF
        | sym.noSymmetry    : st.Append(string,ac.GetString(ac.NoSimpleSymmetryFound)^);
        | sym.axisSymmetry  : st.Append(string,ac.GetString(ac.AxialSymmetryToYAxis)^);
        | sym.pointSymmetry : st.Append(string,ac.GetString(ac.PointSymmetryToOrigin)^);
        ELSE END;
        cobj.AddResult(string,SHORTSET{});
        symdata.Destruct;
      END;
    END;

(* Zeros *)

    IF CheckInput() THEN RETURN FALSE; END;
    IF completeopts.zeros THEN
      cobj.AddResult("",SHORTSET{});
      string:="";
      COPY(ac.GetString(ac.Zeros)^,string);
      st.AppendChar(string,":");
      cobj.AddResult(string,SHORTSET{g.bold});

      NEW(dobj(zo.ZeroObject)); dobj.Init;
      dobj.window:=cobj.window;
      dobj.func:=cobj.func;
      dobj.table:=cobj.table;
      dobj.coords:=cobj.coords;
      dobj.exact:=do.GetAccuracy(completeopts.zerodigits);
      do.GetNextValue(dobj.exact);

(*      dobj.window.Lock(TRUE);*)

      dobj.InitDiscussion;
      result:=dobj.FindNext();
      IF result#NIL THEN
        WHILE result#NIL DO
          IF CheckInput() THEN RETURN FALSE; END;
          bool:=lrc.RealToString(result.xreal,string,10,completeopts.zerodigits,FALSE);
          tt.Clear(string);
          st.Insert(string,0,"  x = ");
          cobj.AddResult(string,SHORTSET{});
          result:=dobj.FindNext();
        END;
      ELSE
        string:="  ";
        st.Append(string,ac.GetString(ac.NoZerosFound)^);
        cobj.AddResult(string,SHORTSET{});
      END;

(*      dobj.window.UnLock;*)
      DestructDObj(dobj);
    END;

(* Extremes *)

    IF CheckInput() THEN RETURN FALSE; END;
    IF completeopts.extremes THEN
      cobj.AddResult("",SHORTSET{});
      string:="";
      COPY(ac.GetString(ac.ExtremePoints)^,string);
      st.AppendChar(string,":");
      cobj.AddResult(string,SHORTSET{g.bold});

      dobj:=NIL;
      NEW(dobj(mo.MinMaxObject)); dobj.Init;
      dobj.window:=cobj.window;
      dobj.func:=cobj.func;
      dobj.table:=cobj.table;
      dobj.coords:=cobj.coords;
      dobj.exact:=do.GetAccuracy(completeopts.extremedigits);
      do.GetNextValue(dobj.exact);

(*      dobj.window.Lock(TRUE);*)

      dobj.InitDiscussion;
      firststring:=NIL;
      maxlen:=0;
      result:=dobj(mo.MinMaxObject).FindNextMax();
      found:=FALSE;
      IF result#NIL THEN
        found:=TRUE;
        WHILE result#NIL DO
          IF CheckInput() THEN RETURN FALSE; END;
          bool:=lrc.RealToString(result.xreal,string,10,completeopts.extremedigits,FALSE);
          tt.Clear(string);
          bool:=lrc.RealToString(result.yreal,str,10,completeopts.extremedigits,FALSE);
          tt.Clear(str);
          st.Insert(string,0," H(");
          st.Insert(string,0,ac.GetString(ac.MaximumPoint)^);
          st.Insert(string,0,"  ");
          st.AppendChar(string,"|");
          st.Append(string,str);
          st.AppendChar(string,")");
          IF st.Length(string)>maxlen THEN
            maxlen:=SHORT(st.Length(string));
          END;
          cobj.AddResult(string,SHORTSET{});
          DISPOSE(cobj.resultlist.tail(String).string);
          NEW(cobj.resultlist.tail(String).string,256);
          COPY(string,cobj.resultlist.tail(String).string^);
          IF firststring=NIL THEN firststring:=cobj.resultlist.tail(String); END;
          result:=dobj(mo.MinMaxObject).FindNextMax();
        END;
      END;
      dobj.InitDiscussion;
      result:=dobj(mo.MinMaxObject).FindNextMin();
      IF result#NIL THEN
        found:=TRUE;
        WHILE result#NIL DO
          IF CheckInput() THEN RETURN FALSE; END;
          bool:=lrc.RealToString(result.xreal,string,10,completeopts.extremedigits,FALSE);
          tt.Clear(string);
          bool:=lrc.RealToString(result.yreal,str,10,completeopts.extremedigits,FALSE);
          tt.Clear(str);
          st.Insert(string,0," T(");
          st.Insert(string,0,ac.GetString(ac.MinimumPoint)^);
          st.Insert(string,0,"  ");
          st.AppendChar(string,"|");
          st.Append(string,str);
          st.AppendChar(string,")");
          IF firststring=NIL THEN
            cobj.AddResult(string,SHORTSET{});
          ELSE
            WHILE st.Length(firststring.string^)<maxlen DO
              st.Append(firststring.string^," ");
            END;
            st.Append(firststring.string^,string);
            IF firststring.next#NIL THEN
              firststring:=firststring.next(String);
            ELSE
              firststring:=NIL;
            END;
          END;
          result:=dobj(mo.MinMaxObject).FindNextMin();
        END;
      END;
      IF ~found THEN
        string:="  ";
        st.Append(string,ac.GetString(ac.NoExtremePointsFound)^);
        cobj.AddResult(string,SHORTSET{});
      END;

(*      dobj.window.UnLock;*)
      DestructDObj(dobj);
    END;

(* Inflections *)

    IF CheckInput() THEN RETURN FALSE; END;
    IF (completeopts.inflections) & (cobj.funcder.nbElements()>=2) THEN
      cobj.AddResult("",SHORTSET{});
      string:="";
      COPY(ac.GetString(ac.PointsOfInflection)^,string);
      st.AppendChar(string,":");
      cobj.AddResult(string,SHORTSET{g.bold});

      dobj:=NIL;
      NEW(dobj(ifo.InflectionObject)); dobj.Init;
      dobj.window:=cobj.window;
      dobj.func:=cobj.funcder.head.next(t.Function);
      dobj.table:=cobj.table;
      dobj.coords:=cobj.coords;
      dobj.exact:=do.GetAccuracy(completeopts.inflectiondigits);
      dobj(ifo.InflectionObject).stutz:=LEN(cobj.table^);
      do.GetNextValue(dobj.exact);

(*      dobj.window.Lock(TRUE);*)

      dobj.InitDiscussion;
      result:=dobj.FindNext();
      IF result#NIL THEN
        WHILE result#NIL DO
          IF CheckInput() THEN RETURN FALSE; END;
          bool:=lrc.RealToString(result.xreal,string,10,completeopts.inflectiondigits,FALSE);
          tt.Clear(string);
          st.Insert(string,0,"  x = ");
          cobj.AddResult(string,SHORTSET{});
          result:=dobj.FindNext();
        END;
      ELSE
        string:="  ";
        st.Append(string,ac.GetString(ac.NoPointsOfInflectionFound)^);
        cobj.AddResult(string,SHORTSET{});
      END;

(*      dobj.window.UnLock;*)
      dobj.func:=NIL;     (* Otherwise dobj.Destruct will also destruct dobj.func! *)
      DestructDObj(dobj);
    END;
    RETURN TRUE;
  END GetResults;

BEGIN
  NEW(mes);
  ret:=FALSE;
  func:=cobj.func;
  coords:=cobj.coords;
  WITH coords: c.CartesianSystem DO
    IF completewind=NIL THEN
      completewind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.CompleteFunctionAnalysis),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
    END;
    subwind:=completewind.InitSub(mg.screen);

    root:=gmb.SetRootBox(gmb.vertBox,gmb.noBorder,FALSE,NIL,LONGSET{},subwind);
      gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,NIL);
        resultlv:=gmo.SetListView(NIL,cobj.resultlist,PrintString,0,FALSE,255);
        cobj.resultlv:=resultlv;
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        ok:=gmo.SetBooleanGadget(gmb.standard.oktext,FALSE);
        help:=gmo.SetBooleanGadget(gmb.standard.helptext,FALSE);
        print:=gmo.SetBooleanGadget(ac.GetString(ac.Print),FALSE);
        textbox:=gmo.SetBooleanGadget(ac.GetString(ac.TextBox),FALSE);
        ca:=gmo.SetBooleanGadget(gmb.standard.canceltext,FALSE);
      gmb.EndBox;
    glist:=root.EndRoot();
  
    root.Init;
  
    wind:=subwind.Open(glist);
    IF wind#NIL THEN
      rast:=wind.rPort;
      root.Resize;

      subwind.SetBusyPointer;
      bool:=GetResults();
      subwind.ClearPointer;
  
      LOOP
        class:=e.Wait(LONGSET{0..31});
        IF cobj.msgsig IN class THEN
          REPEAT
            msg:=cobj.ReceiveMsg();
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
            IF mes.iAddress=ok.gadget THEN
  (*            GetInput;
              ret:=TRUE;
              grid1.window.changed:=TRUE;
              grid1.window.SendNewMsg(m.msgNodeChanged,NIL);*)
              ret:=TRUE;
              EXIT;
            ELSIF mes.iAddress=ca.gadget THEN
  (*            IF didchange THEN
                grid1.window.changed:=TRUE;
                grid1.window.SendNewMsg(m.msgNodeChanged,NIL);
              END;*)
              ret:=FALSE;
              EXIT;
            ELSIF mes.iAddress=print.gadget THEN
              PrintOut;
            ELSIF NOT(mes.iAddress=help.gadget) THEN
  (*            GetInput; didchange:=TRUE;
              grid1.auto:=FALSE; grid2.auto:=FALSE;
              grid1.window.changed:=TRUE;
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
  ELSE END;
  DISPOSE(mes);
END DiscussionRequester;

PROCEDURE CompleteTask*(compltask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH compltask: CompleteObject DO
    compltask.InitCommunication;
    compltask.DiscussionRequester;
  
    compltask.window.RemTask(compltask);
    compltask.ReplyAllMessages;
    compltask.DestructCommunication;
    mem.NodeToGarbage(compltask);
    compltask.window.FreeUser(compltask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END CompleteTask;

PROCEDURE (cobj:CompleteObject) Init*;

BEGIN
  cobj.window:=NIL;
  cobj.resultlist:=l.Create();
  cobj.funcder:=l.Create();

  cobj.InitTask(CompleteTask,cobj,10000,m.taskdata.requesterpri);
  cobj.SetID(tid.noID);
  cobj.Init^;
END Init;

PROCEDURE (cobj:CompleteObject) Destruct*;

BEGIN
  IF cobj.resultlist#NIL THEN cobj.resultlist.Destruct; END;
  IF cobj.funcder#NIL THEN cobj.funcder.Destruct; END;
  IF cobj.func#NIL THEN cobj.func.Destruct; END;
  IF cobj.table#NIL THEN DISPOSE(cobj.table); END;
  IF cobj.coords#NIL THEN cobj.coords.Destruct; END;
  cobj.Destruct^;
END Destruct;

PROCEDURE (cobj:CompleteObject) InitDiscObject*(window:w.Window;funcs:l.List;coords:c.CoordSystem):BOOLEAN;

VAR func : l.Node;

BEGIN
  func:=gb.SelectNode(funcs,ac.GetString(ac.SelectFunction),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,mg.mainsub.GetWindow());
  IF func#NIL THEN
    WITH func: wf.WindowFunction DO
      cobj.window:=window;
      cobj.func:=func.func.CopyNew()(t.Function);
      IF func.graphs.nbElements()=1 THEN
        cobj.table:=fg.CopyFuncTableNew(func.graphs.head(fg.FunctionGraph).table);
      END;
      cobj.coords:=coords.CopyNew()(c.CoordSystem);
    END;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END InitDiscObject;

BEGIN
  completewind:=NIL;
  NEW(completeopts); completeopts.Init;
CLOSE
  DISPOSE(completeopts);
END CompleteObject.

