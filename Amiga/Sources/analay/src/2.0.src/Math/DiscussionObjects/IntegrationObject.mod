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


MODULE IntegrationObject;

(* The requester should recognize a Function, not only a term, when
   its name is entered. *)

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
       rt : RequesterTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       gb : GeneralBasics,
       mb : MathBasics,
       mg : MathGUI,
       fb : FunctionBasics,
       ft : FunctionTrees,
       do : DiscussionObject,
       w  : Window,
       t  : Terms,
       c  : Coords,
       fg : FunctionGraph,
       wf : WindowFunction,
       ac : AnalayCatalog,
       bt : BasicTypes,
       lio: LongRealInOut,
       io,
       NoGuruRq;

TYPE IntegrationObject * = POINTER TO IntegrationObjectDesc;
     IntegrationObjectDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

PROCEDURE GetNextValue(VAR r:LONGREAL);

BEGIN
  IF r>0.1 THEN r:=0.1;
  ELSIF r>0.01 THEN r:=0.01;
  ELSIF r>0.001 THEN r:=0.001;
  ELSIF r>0.0001 THEN r:=0.0001;
  ELSIF r>0.00001 THEN r:=0.00001;
  ELSIF r>0.000001 THEN r:=0.000001;
(*  ELSIF r>0.0000001 THEN r:=0.0000001;
  ELSIF r>0.00000001 THEN r:=0.00000001;*)
  END;
END GetNextValue;

PROCEDURE FindSchnitt(real,add:LONGREAL;func1,func2:t.Function):LONGREAL;

VAR error : INTEGER;
    wert,
    last  : LONGREAL;

BEGIN
  real:=real-add;
  wert:=func1.GetFunctionValue(real,add,error);
  wert:=wert-func2.GetFunctionValue(real,add,error);
  REPEAT
    GetNextValue(add);
    LOOP
      real:=real+add;
      error:=0;
      last:=wert;
      wert:=func1.GetFunctionValue(real,add,error);
      wert:=wert-func2.GetFunctionValue(real,add,error);
      IF ((last<0) AND (wert>0)) OR ((last>0) AND (wert<0)) OR (wert=0) THEN
        EXIT;
      END;
    END;
    IF add>0.00001 THEN
      real:=real-add;
      real:=real-add;
    END;
  UNTIL add<=0.00001;
  RETURN real;
END FindSchnitt;

PROCEDURE IntegrateFunc*(func1,func2:t.Function;xmin,xmax:LONGREAL;mode:INTEGER;step:LONGREAL;subwind:wm.SubWindow;VAR integerror:INTEGER):LONGREAL;

VAR integral,x,lx,nx,
    fv1,f2,fn,funcval: LONGREAL;
    error,i          : INTEGER;
    code             : INTEGER;
    class            : LONGSET;
    address          : s.ADDRESS;
    mes              : I.IntuiMessagePtr;

BEGIN
  NEW(mes);
  integerror:=0;
  integral:=0;
(*  step:=0.001;*)
  x:=xmin;
  error:=0;
  funcval:=func1.GetFunctionValue(x,step,error);
  IF mode=2 THEN
    funcval:=funcval*funcval;
  END;
  f2:=funcval;
  IF error#0 THEN
    integerror:=1;
    x:=xmax;
  END;
  funcval:=func2.GetFunctionValue(x,step,error);
  IF mode=2 THEN
    funcval:=funcval*funcval;
  END;
  f2:=f2-funcval;
  IF error#0 THEN
    integerror:=1;
    x:=xmax;
  END;
  i:=0;
  WHILE x<xmax DO
    lx:=x;
    x:=x+step;
    IF x>xmax THEN
      x:=xmax;
    END;
    fv1:=f2;
    error:=0;
    funcval:=func1.GetFunctionValue(x,-step,error);
    IF mode=2 THEN
      funcval:=funcval*funcval;
    END;
    f2:=funcval;
    IF error#0 THEN
      integerror:=1;
      x:=xmax;
    END;
    funcval:=func2.GetFunctionValue(x,-step,error);
    IF mode=2 THEN
      funcval:=funcval*funcval;
    END;
    f2:=f2-funcval;
    IF error#0 THEN
      integerror:=1;
      x:=xmax;
    END;
    IF ((fv1>=0) AND (f2>=0)) OR ((fv1<=0) AND (f2<=0)) OR (mode=1) THEN
      IF mode=0 THEN
        integral:=integral+((ABS(fv1)+ABS(f2))/2)*(x-lx);
      ELSE
        integral:=integral+((fv1+f2)/2)*(x-lx);
      END;
    ELSE
      nx:=FindSchnitt(lx,step,func1,func2);
(*      fn:=s2.GetFunctionValue(func,nx,nx,error);*)
      integral:=integral+(ABS(fv1)/2)*(nx-lx);
      integral:=integral+(ABS(f2)/2)*(x-nx);
    END;
    INC(i);
    IF (i MOD 100=0) AND (subwind#NIL) THEN
      i:=0;
      REPEAT
        subwind.GetIMes(mes);
        IF I.menuPick IN mes.class THEN
          integerror:=2;
          x:=xmax;
        END;
      UNTIL mes.class=LONGSET{};
    END;
  END;
  IF mode=2 THEN
    integral:=fb.PI*integral;
  END;
  DISPOSE(mes);
  RETURN integral;
END IntegrateFunc;

TYPE LastIntegObject * = POINTER TO LastIntegObjectDesc;
     LastIntegObjectDesc * = RECORD(m.LockAbleDesc);
       integtype     * ,
       stepsize      * ,
       hatchtype     * : INTEGER;
       hatchsurface  * : BOOLEAN;
       startx*,endx  * : ARRAY 80 OF CHAR;
       func1*,func2*   : t.Function;
       listfunc1     * ,
       listfunc2     * : BOOLEAN;
     END;

PROCEDURE (lastiobj:LastIntegObject) Init*;

VAR functerm : t.FuncTerm;

BEGIN
  lastiobj.func1:=t.CreateFunc("");
  lastiobj.listfunc1:=FALSE;
  lastiobj.func2:=t.CreateFunc("0");
  lastiobj.listfunc2:=FALSE;
  lastiobj.Init^;
END Init;

PROCEDURE (lastiobj:LastIntegObject) Destruct*;

BEGIN
  IF (~lastiobj.listfunc1) & (lastiobj.func1#NIL) THEN
    t.DestructFunc(lastiobj.func1);
  END;
  IF (~lastiobj.listfunc2) & (lastiobj.func2#NIL) THEN
    t.DestructFunc(lastiobj.func2);
  END;
  lastiobj.Destruct^;
END Destruct;

PROCEDURE (lastiobj:LastIntegObject) Copy*(dest:l.Node);

VAR term : t.Term;

BEGIN
  WITH dest: LastIntegObject DO
    dest.integtype:=lastiobj.integtype;
    dest.stepsize:=lastiobj.stepsize;
    dest.hatchtype:=lastiobj.hatchtype;
    dest.hatchsurface:=lastiobj.hatchsurface;
    COPY(lastiobj.startx,dest.startx);
    COPY(lastiobj.endx,dest.endx);
    dest.listfunc1:=lastiobj.listfunc1;
    dest.listfunc2:=lastiobj.listfunc2;
    IF (~dest.listfunc1) & (dest.func1#NIL) THEN
      t.DestructFunc(dest.func1);
    END;
    IF lastiobj.listfunc1 THEN
      dest.func1:=lastiobj.func1;
    ELSE
      term:=lastiobj.func1.GetTerm();
      dest.func1:=t.CreateFunc(term.term^);
    END;
    IF (~dest.listfunc2) & (dest.func2#NIL) THEN
      t.DestructFunc(dest.func2);
    END;
    IF lastiobj.listfunc2 THEN
      dest.func2:=lastiobj.func2;
    ELSE
      term:=lastiobj.func2.GetTerm();
      dest.func2:=t.CreateFunc(term.term^);
    END;
  END;
END Copy;



VAR integratewind   * : wm.Window;
    lastintegobj    * : LastIntegObject;

PROCEDURE (integobj:IntegrationObject) IntegrationRequester*;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    func1gad,
    func2gad   : gmo.StringGadget;
    func1sel,
    func2sel   : gmo.BooleanGadget;
    startx,endx: gmo.StringGadget;
    integtype,
    stepsize,
    hatchtype  : gmo.CycleGadget;
    calc       : gmo.BooleanGadget;
    resulttext : gmo.Text;
    hatching   : gmo.CheckboxGadget;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    class      : LONGSET;
    msg        : m.Message;
    integarray : ARRAY 4 OF e.STRPTR;
    steparray  : ARRAY 5 OF e.STRPTR;
    hatcharray : ARRAY 3 OF e.STRPTR;
    lastiobj   : LastIntegObject;
    xmin,xmax,
    real,
    stepreal   : LONGREAL;    (* Contains real step value *)
    resultstr  : ARRAY 20 OF CHAR;
    funcstr    : POINTER TO ARRAY OF CHAR;
    term       : t.Term;
    node       : l.Node;
    i,error    : INTEGER;
    ret,bool   : BOOLEAN;

  PROCEDURE GetInput(lastiobj:LastIntegObject);

  BEGIN
    func1gad.GetString(funcstr^);
    IF lastiobj.listfunc1 THEN
      IF ~tt.Compare(lastiobj.func1.name,funcstr^) THEN
        lastiobj.listfunc1:=FALSE;
        lastiobj.func1:=t.CreateFunc(funcstr^);
      END;
    ELSE
      lastiobj.func1.SetTerm(funcstr^);
    END;
    func2gad.GetString(funcstr^);
    IF lastiobj.listfunc2 THEN
      IF ~tt.Compare(lastiobj.func2.name,funcstr^) THEN
        lastiobj.listfunc2:=FALSE;
        lastiobj.func2:=t.CreateFunc(funcstr^);
      END;
    ELSE
      lastiobj.func2.SetTerm(funcstr^);
    END;
    lastiobj.integtype:=SHORT(integtype.GetValue());
    lastiobj.stepsize:=SHORT(stepsize.GetValue());
    stepreal:=do.GetAccuracy(lastiobj.stepsize+1);
    bool:=lio.WriteReal(stepreal,7,7,FALSE);
    do.GetNextValue(stepreal);
    bool:=lio.WriteReal(stepreal,7,7,FALSE);
    startx.GetString(lastiobj.startx);
      xmin:=ft.ExpressionToReal(lastiobj.startx);
    endx.GetString(lastiobj.endx);
      xmax:=ft.ExpressionToReal(lastiobj.endx);

    lastiobj.hatchtype:=SHORT(hatchtype.GetValue());
    lastiobj.hatchsurface:=hatching.Checked()
  END GetInput;

BEGIN
  io.WriteString("IO1\n");
  NEW(mes);
  io.WriteString("IO2\n");
  NEW(lastiobj); lastiobj.Init;
  io.WriteString("IO3\n");
(*  term:=lastiobj.func1.GetTerm();*)
  NEW(funcstr,t.maxtermchars+1);
  io.WriteString("IO4\n");
  ret:=FALSE;
  IF integratewind=NIL THEN
    integratewind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.CalcArea),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=integratewind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.SurfaceBetweenFunctions));
      gadobj:=gmo.SetText(ac.GetString(ac.Functions),-1);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        func1gad:=gmo.SetStringGadget(NIL,t.maxtermchars-1,gmo.stringType);
        IF lastintegobj.listfunc1 THEN
          func1gad.SetString(lastintegobj.func1.name);
        ELSE
          func1gad.SetString(lastintegobj.func1.terms.head(t.FuncTerm).term.term^);
        END;
        func1sel:=gmo.SetBooleanGadget(s.ADR("A"),FALSE);
        func1sel.SetOutValues(0,0);
        func1sel.SetSizeX(0);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        func2gad:=gmo.SetStringGadget(NIL,t.maxtermchars-1,gmo.stringType);
        IF lastintegobj.listfunc2 THEN
          func2gad.SetString(lastintegobj.func2.name);
        ELSE
          func2gad.SetString(lastintegobj.func2.terms.head(t.FuncTerm).term.term^);
        END;
        func2sel:=gmo.SetBooleanGadget(s.ADR("A"),FALSE);
        func2sel.SetOutValues(0,0);
        func2sel.SetSizeX(0);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        startx:=gmo.SetStringGadget(ac.GetString(ac.From),79,gmo.realType);
        startx.SetMinVisible(5);
        startx.SetString(lastintegobj.startx);
        endx:=gmo.SetStringGadget(ac.GetString(ac.To),79,gmo.realType);
        endx.SetMinVisible(5);
        endx.SetString(lastintegobj.endx);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        integarray[0]:=ac.GetString(ac.Absolute);
        integarray[1]:=ac.GetString(ac.Oriented);
        integarray[2]:=ac.GetString(ac.Rotation);
        integarray[3]:=NIL;
        integtype:=gmo.SetCycleGadget(NIL,s.ADR(integarray),SHORT(lastintegobj.integtype));
        steparray[0]:=s.ADR("0.1");;
        steparray[1]:=s.ADR("0.01");
        steparray[2]:=s.ADR("0.001");
        steparray[3]:=s.ADR("0.0001");
        steparray[4]:=NIL;
        stepsize:=gmo.SetCycleGadget(NIL,s.ADR(steparray),SHORT(lastintegobj.stepsize));
      gmb.EndBox;
      calc:=gmo.SetBooleanGadget(ac.GetString(ac.Calculate),FALSE);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        gadobj:=gmo.SetText(ac.GetString(ac.ResultDP),-1);
        gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,TRUE,NIL);
          resulttext:=gmo.SetText(s.ADR("0"),-1);
          resulttext.SetSizeX(1);
        gmb.EndBox;
        gadobj.SetSizeX(1);
      gmb.EndBox;
    gmb.EndBox;

    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.HatchSurface));
      hatching:=gmo.SetCheckboxGadget(ac.GetString(ac.HatchSurface),lastintegobj.hatchsurface);
      hatcharray[0]:=ac.GetString(ac.DefaultHatching);
      hatcharray[1]:=ac.GetString(ac.CustomHatching);
      hatcharray[2]:=NIL;
      hatchtype:=gmo.SetCycleGadget(NIL,s.ADR(hatcharray),SHORT(lastintegobj.hatchtype));
    gmb.EndBox;
  glist:=root.EndRoot();

  io.WriteString("IO5\n");
  root.Init;
  io.WriteString("IO6\n");

  wind:=subwind.Open(glist);
  io.WriteString("IO7\n");
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    io.WriteString("IO8\n");
    lastintegobj.Copy(lastiobj);
    io.WriteString("IO9\n");
    GetInput(lastiobj); (* Fill local LastIntegObject with proper values. *)
    io.WriteString("IO10\n");

    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF integobj.msgsig IN class THEN
        REPEAT
          msg:=integobj.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              subwind.Close;
            ELSIF msg.type=m.msgOpen THEN
              wind:=subwind.Open(glist);
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
            lastiobj.Copy(lastintegobj);
            GetInput(lastintegobj);
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
          ELSIF mes.iAddress=calc.gadget THEN
            GetInput(lastiobj);
            IF xmin<xmax THEN
              subwind.SetBusyPointer;
              real:=IntegrateFunc(lastiobj.func1,lastiobj.func2,xmin,xmax,lastiobj.integtype,stepreal,subwind,error);
              IF error=0 THEN
                bool:=lrc.RealToString(real,resultstr,7,7,FALSE);
                tt.Clear(resultstr);
                resulttext.SetText(s.ADR(resultstr));
                resulttext.Refresh;
              ELSIF error=1 THEN
                bool:=rt.RequestWin(ac.GetString(ac.ItCannotBeIntegrated),ac.GetString(ac.OverADefinitionGap),s.ADR(""),ac.GetString(ac.OK),mg.window);
              END;
              subwind.ClearPointer;
            ELSE
              bool:=rt.RequestWin(ac.GetString(ac.TheUpperLimitMustBe),ac.GetString(ac.HigherThanTheLowerLimit),s.ADR(""),ac.GetString(ac.OK),mg.window);
            END;
          ELSIF mes.iAddress=func1sel.gadget THEN
            node:=gb.SelectNode(t.functions,ac.GetString(ac.SelectFunction),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,subwind.GetWindow());
            IF node#NIL THEN
              IF ~lastiobj.listfunc1 THEN
                t.DestructFunc(lastiobj.func1);
              END;
              lastiobj.listfunc1:=TRUE;
              lastiobj.func1:=node(t.Function);
              func1gad.SetString(lastiobj.func1.name);
            END;
          ELSIF mes.iAddress=func2sel.gadget THEN
            node:=gb.SelectNode(t.functions,ac.GetString(ac.SelectFunction),ac.GetString(ac.Function),s.ADR("No functions are displayed in this window!"),mb.mathoptions.quickselect,wf.PrintWindowFunction,NIL,subwind.GetWindow());
            IF node#NIL THEN
              IF ~lastiobj.listfunc2 THEN
                t.DestructFunc(lastiobj.func1);
              END;
              lastiobj.listfunc2:=TRUE;
              lastiobj.func2:=node(t.Function);
              func1gad.SetString(lastiobj.func2.name);
            END;
          ELSIF NOT(mes.iAddress=root.help) THEN
(*            GetInput(lastiobj);(* didchange:=TRUE;*)*)
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
  DISPOSE(funcstr);
  lastiobj.Destruct;
  DISPOSE(mes);
END IntegrationRequester;

PROCEDURE IntegrationTask*(integtask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH integtask: IntegrationObject DO
    integtask.InitCommunication;
    integtask.IntegrationRequester;
  
    integtask.chable.RemTask(integtask);
    integtask.ReplyAllMessages;
    integtask.DestructCommunication;
    mem.NodeToGarbage(integtask);
    integtask.chable.FreeUser(integtask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END IntegrationTask;

PROCEDURE (integobj:IntegrationObject) Init*;

BEGIN
  integobj.chable:=m.taskdata.maintask;

  integobj.Init^;
  integobj.InitTask(IntegrationTask,integobj,10000,m.taskdata.requesterpri);
  integobj.SetID(tid.integTaskID);
END Init;

PROCEDURE (integobj:IntegrationObject) Destruct*;

BEGIN
  integobj.Destruct^;
END Destruct;

BEGIN
  integratewind:=NIL;
  NEW(lastintegobj); lastintegobj.Init;
CLOSE
  IF lastintegobj#NIL THEN lastintegobj.Destruct; END;
END IntegrationObject.

