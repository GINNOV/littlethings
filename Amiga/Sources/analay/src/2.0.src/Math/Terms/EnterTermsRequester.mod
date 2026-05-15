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


MODULE EnterTermsRequester;

(* Function.trees maybe not created properly! *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gd : GadTools,
       st : Strings,
       c  : Conversions,
       bt : BasicTools,
       tt : TextTools,
       rt : RequesterTools,
       ac : AnalayCatalog,
       gb : GeneralBasics,
       mg : MathGUI,
       fb : FunctionBasics,
       ft : FunctionTrees,
       fd : FunctionDerive,
       fs : FunctionSimplify,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       t  : Terms,
       bas: BasicTypes,
       io,
       NoGuruRq;

VAR termwind    * : wm.Window;

TYPE EnterTermsObject * = POINTER TO EnterTermsObjectDesc;
     EnterTermsObjectDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

PROCEDURE MakeVariable*(node:l.Node):INTEGER;

VAR i,a,ret : INTEGER;
    str     : ARRAY 100 OF CHAR;
    endreal : BOOLEAN;
    oldstart,
    oldend,
    oldstep : LONGREAL;
    oldname : POINTER TO ARRAY OF CHAR;
    changed : BOOLEAN;
    node2,
    node3   : l.Node;

BEGIN
  ret:=0;
  WITH node: fb.Variable DO
    oldstart:=node.startx;
    oldend:=node.endx;
    oldstep:=node.stepx;
    IF node.name#NIL THEN
      NEW(oldname,st.Length(node.name^)+1);
      COPY(node.name^,oldname^);
    ELSE
      NEW(oldname,1);
      oldname^[0]:=0X;
    END;
    i:=-1;
    LOOP
      INC(i);
      IF i>=st.Length(node.string) THEN
        ret:=1;
        EXIT;
      END;
      IF node.string[i]="=" THEN
        IF i=0 THEN
          ret:=1;
        END;
        str[i]:=0X;
        EXIT;
      END;
      str[i]:=node.string[i];
    END;
    NEW(node.name,st.Length(str)+1);
    COPY(str,node.name^);
    endreal:=TRUE;
    IF ret=0 THEN
      st.Delete(str,0,100);
      a:=-1;
      LOOP
        INC(i);
        INC(a);
        IF i>=st.Length(node.string) THEN
          IF a=0 THEN
            ret:=2;
          ELSE
            str[a]:=0X;
            endreal:=FALSE;
          END;
          EXIT;
        END;
        IF (node.string[i]=".") AND (node.string[i+1]=".") THEN
          IF a=0 THEN
            ret:=2;
          END;
          str[a]:=0X;
          endreal:=TRUE;
          EXIT;
        END;
        str[a]:=node.string[i];
      END;
(*      bool:=lrc.StringToReal(str,node.startx);*)
      a:=0;
      node.startx:=ft.ExpressionToReal(str);
      IF NOT(endreal) THEN
        node.endx:=node.startx;
        node.stepx:=0;
      END;
      IF (ret=0) AND (endreal) THEN
        st.Delete(str,0,100);
        INC(i);
        a:=-1;
        LOOP
          INC(i);
          INC(a);
          IF i>=st.Length(node.string) THEN
            IF a=0 THEN
              ret:=3;
            END;
            str[a]:=0X;
            EXIT;
          END;
          IF i<=st.Length(node.string)-1 THEN
            IF CAP(node.string[i])="," (*AND (CAP(node.string[i+1])="Y") *)THEN
              IF a=0 THEN
                ret:=3;
              END;
              str[a]:=0X;
              EXIT;
            END;
          END;
          str[a]:=node.string[i];
        END;
(*        bool:=lrc.StringToReal(str,node.endx);*)
        a:=0;
        node.endx:=ft.ExpressionToReal(str);
        node.stepx:=1;
        IF ret=0 THEN
          IF i<=st.Length(node.string)-1 THEN
            IF CAP(node.string[i])="," (*AND (CAP(node.string[i+1])="Y")*) THEN
              st.Delete(str,0,100);
(*              INC(i);*)
              a:=-1;
              LOOP
                INC(i);
                INC(a);
                IF i>=st.Length(node.string) THEN
                  str[a]:=0X;
                  EXIT;
                END;
                str[a]:=node.string[i];
              END;
              IF a#0 THEN
(*                bool:=lrc.StringToReal(str,node.stepx);*)
                a:=0;
                node.stepx:=ft.ExpressionToReal(str);
              END;
            END;
          END;
        END;
      END;
    END;
    IF ret=0 THEN
      changed:=TRUE;
      node.changed:=TRUE;
      IF (oldstart=node.startx) AND (oldend=node.endx) AND (oldstep=node.stepx) THEN
        st.Upper(oldname^);
        COPY(node.name^,str);
        st.Upper(str);
        IF tt.Compare(str,oldname^) THEN
          changed:=FALSE;
          node.changed:=FALSE;
        END;
(*        IF st.Length(str)=st.Length(oldname^) THEN
          IF st.Occurs(oldname^,str)#-1 THEN
            changed:=FALSE;
            node.changed:=TRUE;
          END;
        END;*)
      END;
    END;
  END;
  RETURN ret;
END MakeVariable;

PROCEDURE BuildUpFuncErrorReq*(term:l.Node;err,pos:INTEGER;VAR text:ARRAY OF ARRAY OF CHAR);

VAR i : INTEGER;

BEGIN
  COPY(term(t.Term).term^,text[0]);
  text[0,62]:=0X;
  i:=0;
  WHILE (pos>0) AND (i<60) DO
    text[1,i]:=" ";
    DEC(pos);
    INC(i);
  END;
  IF i<60 THEN
    text[1,i]:="^";
    text[1,i+1]:=0X;
  ELSE
    text[1,i]:="-";
    text[1,i+1]:=">";
    text[1,i+2]:=0X;
  END;
  COPY(ac.GetString(ac.ErrorInFunctionInput)^,text[2]);
  IF err=1 THEN
    COPY(ac.GetString(ac.IllegalUseOfMathematicalSign)^,text[3]);
  ELSIF err=2 THEN
    COPY(ac.GetString(ac.ErrorInNumberFormat)^,text[3]);
  ELSIF err=3 THEN
    COPY(ac.GetString(ac.OpeningBracketExpected)^,text[3]);
  ELSIF err=4 THEN
    COPY(ac.GetString(ac.MathematicalSignExpected)^,text[3]);
  ELSIF err=5 THEN
    COPY(ac.GetString(ac.OperandExpected)^,text[3]);
  END;
END BuildUpFuncErrorReq;

PROCEDURE * PrintVar*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;
    i    : INTEGER;

BEGIN
  node:=fb.objects.head;
  i:=-1;
  LOOP
    IF node=NIL THEN
      EXIT;
    END;
    IF node IS fb.Variable THEN
      INC(i);
    END;
    IF i=num THEN
      EXIT;
    END;
    node:=node.next;
  END;
  IF node#NIL THEN
    WITH node: fb.Variable DO
      NEW(str);
      COPY(node.string,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintVar;

PROCEDURE (enterobj:EnterTermsObject) EnterTerms*():BOOLEAN;

VAR subwind         : wm.SubWindow;
    wind            : I.WindowPtr;
    rast            : g.RastPortPtr;
    root            : gmb.Root;
    term,var        : gmo.StringGadget;
    newterm,delterm,
    copyterm,appterm,
    derterm,newvar,
    delvar,copyvar  : gmo.BooleanGadget;
    termlv,varlv    : gmo.ListView;
    gadobj          : gmb.Object;
    glist           : I.GadgetPtr;
    mes             : I.IntuiMessagePtr;
    class           : LONGSET;
    msg             : m.Message;
    actterm,
    actvar,
    node,node2,
    node3      : l.Node;
    bool,ret,
    copytb,apptb,
    copyvb     : BOOLEAN;
    pos,err,
    bcount,
    oldpos     : INTEGER;
    text       : POINTER TO ARRAY OF ARRAY OF CHAR;
    strptr     : POINTER TO ARRAY OF CHAR;
    string     : ARRAY 256 OF CHAR;
    sinfo      : I.StringInfoPtr;

PROCEDURE VarNumber():INTEGER;

VAR i    : INTEGER;
    node : l.Node;

BEGIN
  i:=0;
  node:=fb.objects.head;
  WHILE node#NIL DO
    IF node IS fb.Variable THEN
      INC(i);
    END;
    node:=node.next;
  END;
  RETURN i;
END VarNumber;

PROCEDURE GetVarNumber(actvar:l.Node):INTEGER;

VAR i    : INTEGER;
    node : l.Node;

BEGIN
  i:=0;
  node:=fb.objects.head;
  WHILE (node#NIL) AND (node#actvar) DO
    IF node IS fb.Variable THEN
      INC(i);
    END;
    node:=node.next;
  END;
  RETURN i;
END GetVarNumber;

PROCEDURE GetVarNode(num:LONGINT):l.Node;

VAR node : l.Node;
    i    : LONGINT;

BEGIN
  i:=-1;
  node:=fb.objects.head;
  LOOP
    IF node=NIL THEN
      EXIT;
    END;
    IF node IS fb.Variable THEN
      INC(i);
    END;
    IF i=num THEN
      EXIT;
    END;
    node:=node.next;
  END;
  RETURN node;
END GetVarNode;

PROCEDURE RefreshTerm;

BEGIN
  IF actterm#NIL THEN
    termlv.SetValue(t.terms.GetNodeNumber(actterm));
    termlv.SetString(actterm(t.Term).term^);
  ELSE
    termlv.Refresh;
  END;
END RefreshTerm;

PROCEDURE RefreshVar;

BEGIN
  IF actvar#NIL THEN
    varlv.SetValue(GetVarNumber(actvar));
    varlv.SetString(actvar(fb.Variable).string);
  ELSE
    varlv.Refresh;
  END;
END RefreshVar;

PROCEDURE CheckChanged(node:l.Node);

VAR node2 : l.Node;

BEGIN
  node2:=node(t.Term).depend.head;
  WHILE node2#NIL DO
    IF node2(t.Depend).var(fb.Variable).changed THEN
      node(t.Term).changed:=TRUE;
    END;
    node2:=node2.next;
  END;
END CheckChanged;

PROCEDURE CheckTermError(term:t.Term):BOOLEAN;
(* TRUE if error. *)

VAR pos,bcount,err : INTEGER;

BEGIN
  io.WriteString("Starting syntax check...");
  ft.SyntaxCheck(term.term^,pos,bcount,err);
  io.WriteString("Ready with syntax check.\n");
  IF err=0 THEN
    IF bcount#0 THEN
      COPY(term.term^,text[0]);
      text[1]:="";
      COPY(ac.GetString(ac.WarningDP)^,text[2]);
      IF bcount>0 THEN
        bool:=c.IntToString(bcount,text[3],7);
        tt.Clear(text[3]);
        st.AppendChar(text[3]," ");
        st.Append(text[3],ac.GetString(ac.bracketsNotClosed)^);
      ELSE
        COPY(ac.GetString(ac.TooManyBracketsClosed)^,text[3]);
      END;
      bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
    END;
  ELSIF err#0 THEN
    oldpos:=pos;
    BuildUpFuncErrorReq(term,err,pos,text^);
    bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
    actterm:=term;
(*            sinfo:=term.specialInfo;
    sinfo.dispPos:=pos;
    sinfo.bufferPos:=pos;*)
    RefreshTerm;
    RETURN TRUE;
  END;
  io.WriteString("Exiting ChecktermError (successful).\n");
  RETURN FALSE;
END CheckTermError;

PROCEDURE CheckTermChanged(actterm:t.Term):BOOLEAN;
(* Returns TRUE if error! *)

VAR string : POINTER TO ARRAY OF CHAR;
    bool   : BOOLEAN;

BEGIN
  io.WriteString("Entering CheckTermChanged.\n");
  NEW(string,t.maxtermchars+1);
  COPY(actterm.term^,string^);
  termlv.GetString(actterm.term^);
  IF ~tt.Compare(actterm.term^,string^) THEN
    bool:=CheckTermError(actterm);
    IF bool THEN
      COPY(string^,actterm.term^);
    ELSE (* OK! *)
      COPY(actterm.term^,actterm.basefunc(t.Function).name);
      io.WriteString("CheckTermChanged1\n");
      actterm.MakeDepend;
      io.WriteString("CheckTermChanged2\n");
      actterm.basefunc(t.Function).MakeDepend;
      io.WriteString("CheckTermChanged3\n");
      actterm.basefunc(t.Function).changed:=FALSE;
  (*    actterm.basefunc(t.Function).changed:=TRUE;*)
      actterm.basefunc(t.Function).Changed;
      io.WriteString("CheckTermChanged4\n");
    END;
    DISPOSE(string);
    io.WriteString("Exiting ChecktermChanged.\n");
    RETURN bool;
  ELSE
    DISPOSE(string);
    io.WriteString("Exiting ChecktermChanged.\n");
    RETURN FALSE;
  END;
END CheckTermChanged;

PROCEDURE CheckVarError(var:fb.Variable):BOOLEAN;

VAR err : INTEGER;

BEGIN
  err:=MakeVariable(var);
  IF err#0 THEN
    COPY(ac.GetString(ac.ErrorInVariableInput)^,text[0]);
    COPY(var.string,text[1]);
    text[2]:="";
    IF err=1 THEN
      COPY(ac.GetString(ac.VariableNameMissing)^,text[3]);
    ELSIF err=2 THEN
      COPY(ac.GetString(ac.LowerLimitMissing)^,text[3]);
    ELSIF err=3 THEN
      COPY(ac.GetString(ac.UpperLimitMissing)^,text[3]);
    END;
    bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
    RefreshVar;
    RETURN TRUE;
  END;
  RETURN FALSE;
END CheckVarError;

PROCEDURE CheckVarChanged(actvar:fb.Variable):BOOLEAN;
(* Returns TRUE if error! *)

VAR string : POINTER TO ARRAY OF CHAR;
    bool   : BOOLEAN;

BEGIN
  NEW(string,LEN(actvar.string)+1);
  COPY(actvar.string,string^);
  varlv.GetString(actvar.string);
  IF ~tt.Compare(actvar.string,string^) THEN
    bool:=CheckVarError(actvar);
    IF bool THEN
      COPY(string^,actvar.string);
    ELSE (* OK! *)
      actvar.changed:=TRUE;
      node:=t.terms.head;
      WHILE node#NIL DO
        node(t.Term).MakeDepend;
        CheckChanged(node);
        node:=node.next;
      END;
      node:=fb.objects.head;
      WHILE node#NIL DO
        IF node IS fb.Variable THEN
          node(fb.Variable).changed:=FALSE;
        END;
        node:=node.next;
      END;
  
      node:=t.functions.head;
      WHILE node#NIL DO
        node2:=t.terms.head;
        WHILE node2#NIL DO
          IF node2(t.Term).changed THEN
            node3:=node(t.Function).terms.head;
            WHILE node3#NIL DO
              IF node3(t.FuncTerm).term=node2 THEN
                node(t.Function).changed:=TRUE;
              END;
              node3:=node3.next;
            END;
          END;
          node2:=node2.next;
        END;
        node(t.Function).MakeDepend;
        node:=node.next;
      END;
  
      node:=t.functions.head;
      WHILE node#NIL DO
        IF node(t.Function).changed THEN
          node(t.Function).Changed;
          node(t.Function).changed:=FALSE;
        END;
        node:=node.next;
      END;
      node:=t.terms.head;
      WHILE node#NIL DO
        node(t.Term).changed:=FALSE;
        node:=node.next;
      END;
    END;
    DISPOSE(string);
    RETURN bool;
  ELSE
    DISPOSE(string);
    RETURN FALSE;
  END;
END CheckVarChanged;

BEGIN
  t.terms.NewUser(enterobj,TRUE);
  t.functions.NewUser(enterobj,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF termwind=NIL THEN
    termwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.EnterFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=termwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      termlv:=gmo.SetListView(ac.GetString(ac.Functions),t.terms,t.PrintTerm,0,TRUE,t.maxtermchars);
      newterm:=gmo.SetBooleanGadget(ac.GetString(ac.NewFunction),FALSE);
      delterm:=gmo.SetBooleanGadget(ac.GetString(ac.DelFunction),FALSE);
      copyterm:=gmo.SetBooleanGadget(ac.GetString(ac.CopyFunction),TRUE);
      appterm:=gmo.SetBooleanGadget(ac.GetString(ac.AppendFunction),TRUE);
      derterm:=gmo.SetBooleanGadget(ac.GetString(ac.DeriveFunction),FALSE);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      varlv:=gmo.SetListView(ac.GetString(ac.Variables),fb.objects,PrintVar,0,TRUE,255);
      newvar:=gmo.SetBooleanGadget(ac.GetString(ac.NewVariable),FALSE);
      delvar:=gmo.SetBooleanGadget(ac.GetString(ac.DelVariable),FALSE);
      copyvar:=gmo.SetBooleanGadget(ac.GetString(ac.CopyVariable),TRUE);
    gmb.EndBox;
  glist:=root.EndRoot();
  termlv.SetNoEntryText(s.ADR("No terms!"));
  varlv.SetNoEntryText(s.ADR("No variables!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actterm:=t.terms.GetNode(termlv.GetValue());
    IF actterm=NIL THEN
      termlv.Refresh;
    ELSE
      RefreshTerm;
    END;
    actvar:=GetVarNode(varlv.GetValue());
    IF actvar=NIL THEN
      varlv.Refresh;
    ELSE
      RefreshVar;
    END;


    NEW(text,4,80);

    copytb:=FALSE;
    apptb:=FALSE;
    copyvb:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF enterobj.msgsig IN class THEN
        REPEAT
          msg:=enterobj.ReceiveMsg();
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
            ELSIF (msg.type=m.msgNodeChanged) OR (msg.type=m.msgListChanged) THEN
              IF (actterm#NIL) & (actterm.list=NIL) THEN
                termlv.SetValue(0);
                actterm:=t.terms.GetNode(termlv.GetValue());
              END;
              IF (actvar#NIL) & (actvar.list=NIL) THEN
                varlv.SetValue(0);
                actvar:=GetVarNode(varlv.GetValue());
              END;
              RefreshTerm;
              RefreshVar;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              enterobj.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;

      REPEAT
        root.GetIMes(mes);
(*        IF actterm#NIL THEN
          termlv.GetString(string);
          IF NOT(tt.Compare(string,actterm(t.Term).term^)) THEN
            COPY(string,actterm(t.Term).term^);
            actterm(t.Term).changed:=TRUE;
            actterm(t.Term).tree:=NIL;
            IF actterm(t.Term).basefunc#NIL THEN
              COPY(actterm(t.Term).term^,actterm(t.Term).basefunc(t.Function).name);
              actterm(t.Term).basefunc(t.Function).changed:=TRUE;
              actterm(t.Term).basefunc(t.Function).SendChangeMsg;
            END;
          END;
        END;
        IF actvar#NIL THEN
          varlv.GetString(string);
          IF NOT(tt.Compare(string,actvar(fb.Variable).string)) THEN
            COPY(string,actvar(fb.Variable).string);
            actvar(fb.Variable).changed:=TRUE;
          END;
        END;*)
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            subwind.SetBusyPointer;
            bool:=FALSE;
            IF actvar#NIL THEN
              bool:=CheckVarChanged(actvar(fb.Variable));
            END;
            IF ~bool THEN (* OK! *)
              bool:=FALSE;
              IF actterm#NIL THEN
                bool:=CheckTermChanged(actterm(t.Term));
              END;
              IF ~bool THEN (* OK! *)
                t.RemoveEmptyFunctions;
    
                subwind.ClearPointer;
                ret:=TRUE;
                EXIT;
              END;
            END;
            subwind.ClearPointer;
          ELSIF mes.iAddress=newterm.gadget THEN
            node:=NIL;
            NEW(node(t.Term));
            node(t.Term).Init;
            t.terms.AddTail(node);
  
            actterm:=node;
  
            node2:=NIL;
            NEW(node2(t.Function));
            node2(t.Function).Init;
  
            node3:=NIL;
            NEW(node3(t.FuncTerm));
            node3(t.FuncTerm).term:=actterm(t.Term);
            node2(t.Function).terms.AddTail(node3);
            t.functions.AddTail(node2);
            node(t.Term).basefunc:=node2;
            node(t.Term).NewUser(NIL);
            RefreshTerm;
          ELSIF mes.iAddress=delterm.gadget THEN
            IF actterm#NIL THEN
              node:=actterm.next;
              IF node=NIL THEN
                node:=actterm.prev;
              END;
              IF actterm(t.Term).basefunc#NIL THEN
                mem.NodeToGarbage(actterm(t.Term).basefunc(t.Function));
              END;
              mem.NodeToGarbage(actterm(t.Term));
              actterm:=node;
              RefreshTerm;
            END;
          ELSIF mes.iAddress=copyterm.gadget THEN
            copytb:=NOT(copytb);
  (*          IF apptb THEN
              gm.DeActivateBool(appt,wind);
            END;
            IF copyvb THEN
              gm.DeActivateBool(copyv,wind);
            END;*)
            apptb:=FALSE;
            copyvb:=FALSE;
          ELSIF mes.iAddress=appterm.gadget THEN
            apptb:=NOT(apptb);
  (*          IF copytb THEN
              gm.DeActivateBool(copyt,wind);
            END;
            IF copyvb THEN
              gm.DeActivateBool(copyv,wind);
            END;*)
            copytb:=FALSE;
            copyvb:=FALSE;
          ELSIF mes.iAddress=copyvar.gadget THEN
            copyvb:=NOT(copyvb);
  (*          IF copytb THEN
              gm.DeActivateBool(copyt,wind);
            END;
            IF apptb THEN
              gm.DeActivateBool(appt,wind);
            END;*)
            copytb:=FALSE;
            apptb:=FALSE;
          ELSIF mes.iAddress=derterm.gadget THEN
            IF actterm#NIL THEN
              subwind.SetBusyPointer;
              ft.SyntaxCheck(actterm(t.Term).term^,pos,bcount,err);
              IF err=0 THEN
                node:=NIL;
                NEW(node(t.Term));
                node(t.Term).Init;
                t.terms.AddTail(node);
                pos:=0;
                node(t.Term).tree:=ft.Parse(actterm(t.Term).term^);
                bool:=fs.Optimize(node(t.Term).tree);
                fd.Derive(node(t.Term).tree,"x");
                bool:=fs.Optimize(node(t.Term).tree);
                ft.TreeToString(node(t.Term).tree,node(t.Term).term^);
                actterm:=node;
                node2:=NIL;
                NEW(node2(t.Function));
                node2(t.Function).Init;
                COPY(node(t.Term).term^,node2(t.Function).name);
                node3:=NIL;
                NEW(node3(t.FuncTerm));
                node3(t.FuncTerm).term:=actterm(t.Term);
                node2(t.Function).terms.AddTail(node3);
                t.functions.AddTail(node2);
                node(t.Term).basefunc:=node2;
                RefreshTerm;
              ELSE
                oldpos:=pos;
                BuildUpFuncErrorReq(actterm,err,pos,text^);
                bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
  (*              sinfo:=term.specialInfo;
                sinfo.dispPos:=oldpos;
                sinfo.bufferPos:=oldpos;*)
                RefreshTerm;
              END;
              subwind.ClearPointer;
            END;
          ELSIF mes.iAddress=newvar.gadget THEN
            node:=NIL;
            NEW(node(fb.Variable));
            fb.objects.AddTail(node);
            actvar:=node;
            RefreshVar;
          ELSIF mes.iAddress=delvar.gadget THEN
            IF actvar#NIL THEN
              node:=actvar;
              REPEAT
                node:=node.next;
              UNTIL (node=NIL) OR (node IS fb.Variable);
              IF node=NIL THEN
                node:=actvar;
                REPEAT
                  node:=node.prev;
                UNTIL (node=NIL) OR (node IS fb.Variable);
              END;
              actvar.Remove;
              actvar:=node;
              RefreshVar;
            END;
          ELSIF mes.iAddress=termlv.stringgad THEN
            IF actterm#NIL THEN
              bool:=CheckTermChanged(actterm(t.Term));
              termlv.Refresh;
              termlv.Activate;
            END;
          ELSIF mes.iAddress=termlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              bool:=CheckTermChanged(actterm(t.Term));
              IF bool THEN (* Error *)
                termlv.SetValue(t.terms.GetNodeNumber(actterm));
                termlv.Refresh;
                termlv.Activate;
              ELSE
                node:=actterm;
                actterm:=t.terms.GetNode(termlv.GetValue());
                IF (node#NIL) AND (actterm#NIL) THEN
                  NEW(strptr,t.maxtermchars+1);
                  IF copytb THEN
                    COPY(node(t.Term).term^,strptr^);
                    termlv.SetString(strptr^);
                    bool:=CheckTermChanged(actterm(t.Term));
                    IF ~bool THEN RefreshTerm; END;
(*                    actterm(t.Term).changed:=TRUE;
                    actterm(t.Term).tree:=NIL;
                    IF actterm(t.Term).basefunc#NIL THEN
                      COPY(actterm(t.Term).term^,actterm(t.Term).basefunc(t.Function).name);
                      actterm(t.Term).basefunc(t.Function).changed:=TRUE;
                    END;*)
                    copytb:=FALSE;
                    copyterm.SetSelected(FALSE);
                  ELSIF apptb THEN
                    COPY(actterm(t.Term).term^,strptr^);
                    st.Append(strptr^,node(t.Term).term^);
                    termlv.SetString(strptr^);
                    bool:=CheckTermChanged(actterm(t.Term));
                    IF ~bool THEN RefreshTerm; END;
(*                    st.Append(actterm(t.Term).term^,node(t.Term).term^);
                    actterm(t.Term).changed:=TRUE;
                    actterm(t.Term).tree:=NIL;
                    IF actterm(t.Term).basefunc#NIL THEN
                      COPY(actterm(t.Term).term^,actterm(t.Term).basefunc(t.Function).name);
                      actterm(t.Term).basefunc(t.Function).changed:=TRUE;
                    END;*)
                    apptb:=FALSE;
                    appterm.SetSelected(FALSE);
                  ELSE
                    RefreshTerm;
                  END;
                  DISPOSE(strptr);
                ELSE
                  RefreshTerm;
                END;
              END;
            END;
          ELSIF mes.iAddress=varlv.stringgad THEN
            IF actvar#NIL THEN
              bool:=CheckVarChanged(actvar(fb.Variable));
              varlv.Refresh;
              varlv.Activate;
            END;
          ELSIF mes.iAddress=varlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              bool:=CheckVarChanged(actvar(fb.Variable));
              IF bool THEN (* Error *)
                varlv.SetValue(GetVarNumber(actvar));
                varlv.Refresh;
                varlv.Activate;
              ELSE
                node:=actvar;
                actvar:=GetVarNode(varlv.GetValue());
                IF (node#NIL) AND (actvar#NIL) THEN
                  IF copyvb THEN
                    varlv.SetString(node(fb.Variable).string);
                    bool:=CheckVarChanged(actvar(fb.Variable));
                    IF ~bool THEN RefreshVar; END;
(*                    COPY(node(fb.Variable).string,actvar(fb.Variable).string);*)
    (*                gm.DeActivateBool(copyv,wind);*)
                    copyvb:=FALSE;
                  ELSE
                    RefreshVar;
                  END;
                ELSE
                  RefreshVar;
                END;
              END;
            END;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"enter",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(enterobj);
  t.terms.FreeUser(enterobj);
  RETURN ret;
END EnterTerms;

PROCEDURE EnterTermsTask*(entertask:bas.ANY):bas.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH entertask: EnterTermsObject DO
    entertask.InitCommunication;
    bool:=entertask.EnterTerms();

    entertask.chable.RemTask(entertask);
    entertask.ReplyAllMessages;
    entertask.DestructCommunication;
    mem.NodeToGarbage(entertask);
    entertask.chable.FreeUser(entertask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END EnterTermsTask;

PROCEDURE (enterobj:EnterTermsObject) Init*;

BEGIN
  enterobj.Init^;
  enterobj.chable:=m.taskdata.maintask;

  enterobj.InitTask(EnterTermsTask,enterobj,20000,m.taskdata.requesterpri);
  enterobj.SetID(tid.enterTermsTaskID);
END Init;

PROCEDURE (enterobj:EnterTermsObject) Destruct*;

BEGIN
  enterobj.Destruct^;
END Destruct;

BEGIN
  termwind:=NIL;
END EnterTermsRequester.

