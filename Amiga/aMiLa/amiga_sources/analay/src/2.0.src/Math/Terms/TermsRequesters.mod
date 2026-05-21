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


MODULE TermsRequesters;

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
       bt : BasicTypes,
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)



VAR termwind    * ,
    definewind  * ,
    connectwind * ,
    processwind * ,
    mirrorwind  * : wm.Window;

(* Process functions *)

    derstr      : ARRAY 80 OF CHAR;
    pxs,pys     : ARRAY 80 OF CHAR;
(*    autopy      : BOOLEAN;*)
    xstr,ystr(*,
    pxstr,pystr*) : ARRAY 80 OF CHAR;



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

PROCEDURE * PrintVar*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List);

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

PROCEDURE EnterTerms*():BOOLEAN;

VAR subwind         : wm.SubWindow;
    wind            : I.WindowPtr;
    rast            : g.RastPortPtr;
    mes             : I.IntuiMessagePtr;
    root            : gmb.Root;
    term,var        : gmo.StringGadget;
    newterm,delterm,
    copyterm,appterm,
    derterm,newvar,
    delvar,copyvar  : gmo.BooleanGadget;
    termlv,varlv    : gmo.ListView;
    gadobj          : gmb.Object;
    glist           : I.GadgetPtr;
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
    termlv.SetString(actterm(t.Term).term^);
    termlv.SetValue(t.terms.GetNodeNumber(actterm));
  ELSE
    termlv.Refresh;
  END;
END RefreshTerm;

PROCEDURE RefreshVar;

BEGIN
  IF actvar#NIL THEN
    varlv.SetString(actvar(fb.Variable).string);
    varlv.SetValue(GetVarNumber(actvar));
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

BEGIN
  t.terms.NewUser(m.taskdata.maintask);
  t.functions.NewUser(m.taskdata.maintask);
  NEW(mes);
  ret:=FALSE;
  IF termwind=NIL THEN
    termwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.EnterFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=termwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      termlv:=gmo.SetListView(ac.GetString(ac.Functions),t.terms,t.PrintTerm,0,TRUE,t.maxtermchars);
      newterm:=gmo.SetBooleanGadget(ac.GetString(ac.NewFunction));
      delterm:=gmo.SetBooleanGadget(ac.GetString(ac.DelFunction));
      copyterm:=gmo.SetBooleanGadget(ac.GetString(ac.CopyFunction));
      appterm:=gmo.SetBooleanGadget(ac.GetString(ac.AppendFunction));
      derterm:=gmo.SetBooleanGadget(ac.GetString(ac.DeriveFunction));
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      varlv:=gmo.SetListView(ac.GetString(ac.Variables),fb.objects,PrintVar,0,TRUE,255);
      newvar:=gmo.SetBooleanGadget(ac.GetString(ac.NewVariable));
      delvar:=gmo.SetBooleanGadget(ac.GetString(ac.DelVariable));
      copyvar:=gmo.SetBooleanGadget(ac.GetString(ac.CopyVariable));
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
      subwind.WaitPort;
      root.GetIMes(mes);
      IF actterm#NIL THEN
        termlv.GetString(string);
        IF NOT(tt.Compare(string,actterm(t.Term).term^)) THEN
          COPY(string,actterm(t.Term).term^);
          actterm(t.Term).changed:=TRUE;
          actterm(t.Term).tree:=NIL;
          IF actterm(t.Term).basefunc#NIL THEN
            COPY(actterm(t.Term).term^,actterm(t.Term).basefunc(t.Function).name);
            actterm(t.Term).basefunc(t.Function).changed:=TRUE;
          END;
        END;
      END;
      IF actvar#NIL THEN
        varlv.GetString(string);
        IF NOT(tt.Compare(string,actvar(fb.Variable).string)) THEN
          COPY(string,actvar(fb.Variable).string);
          actvar(fb.Variable).changed:=TRUE;
        END;
      END;
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          subwind.SetBusyPointer;
          node:=t.functions.head;
          WHILE node#NIL DO
            node2:=node(t.Function).terms.head(t.FuncTerm).term;
            ft.SyntaxCheck(node2(t.Term).term^,pos,bcount,err);
            IF err=0 THEN
              IF bcount#0 THEN
                COPY(node2(t.Term).term^,text[0]);
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
              node:=node.next;
            ELSE
              node:=NIL;
            END;
          END;
          IF err#0 THEN
            oldpos:=pos;
            BuildUpFuncErrorReq(node2,err,pos,text^);
            bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
            actterm:=node2;
(*            sinfo:=term.specialInfo;
            sinfo.dispPos:=pos;
            sinfo.bufferPos:=pos;*)
            RefreshTerm;
          ELSE
  (*          f.varhead:=s1.variables.head;*)
            err:=0;
            node:=fb.objects.head;
            WHILE node#NIL DO
              IF node IS fb.Variable THEN
                err:=MakeVariable(node);
                IF err#0 THEN
                  actvar:=node;
                END;
              END;
              node:=node.next;
              IF err#0 THEN
                node:=NIL;
              END;
            END;
            IF err=0 THEN
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
  
              t.RemoveEmptyFunctions;
  
              subwind.ClearPointer;
              ret:=TRUE;
              EXIT;
            ELSE
              COPY(ac.GetString(ac.ErrorInVariableInput)^,text[0]);
              COPY(actvar(fb.Variable).string,text[1]);
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
          node(t.Term).NewUser;
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
            termlv.Refresh;
            termlv.Activate;
          END;
        ELSIF mes.iAddress=termlv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            node:=actterm;
            actterm:=t.terms.GetNode(termlv.GetValue());
            IF (node#NIL) AND (actterm#NIL) THEN
              IF copytb THEN
                COPY(node(t.Term).term^,actterm(t.Term).term^);
                actterm(t.Term).changed:=TRUE;
                actterm(t.Term).tree:=NIL;
                IF actterm(t.Term).basefunc#NIL THEN
                  COPY(actterm(t.Term).term^,actterm(t.Term).basefunc(t.Function).name);
                  actterm(t.Term).basefunc(t.Function).changed:=TRUE;
                END;
(*                gm.DeActivateBool(copyt,wind);*)
                copytb:=FALSE;
              ELSIF apptb THEN
                st.Append(actterm(t.Term).term^,node(t.Term).term^);
                actterm(t.Term).changed:=TRUE;
                actterm(t.Term).tree:=NIL;
                IF actterm(t.Term).basefunc#NIL THEN
                  COPY(actterm(t.Term).term^,actterm(t.Term).basefunc(t.Function).name);
                  actterm(t.Term).basefunc(t.Function).changed:=TRUE;
                END;
(*                gm.DeActivateBool(appt,wind);*)
                apptb:=FALSE;
              END;
            END;
            RefreshTerm;
          END;
        ELSIF mes.iAddress=varlv.stringgad THEN
          IF actvar#NIL THEN
            varlv.Refresh;
            varlv.Activate;
          END;
        ELSIF mes.iAddress=varlv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            node:=actvar;
            actvar:=GetVarNode(varlv.GetValue());
            IF (node#NIL) AND (actvar#NIL) THEN
              IF copyvb THEN
                COPY(node(fb.Variable).string,actvar(fb.Variable).string);
(*                gm.DeActivateBool(copyv,wind);*)
                copyvb:=FALSE;
              END;
            END;
            RefreshVar;
          END;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"enter",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(m.taskdata.maintask);
  t.terms.FreeUser(m.taskdata.maintask);
  RETURN ret;
END EnterTerms;

PROCEDURE EnterTermsTask*(entertask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH entertask: EnterTermsObject DO
    entertask.InitCommunication;
    entertask.IntegrationRequester;
  
    entertask.chable.RemTask(entertask);
    entertask.ReplyAllMessages;
    entertask.DestructCommunication;
    mem.NodeToGarbage(entertask);
    entertask.chable.FreeUser;
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END EnterTermsTask;

PROCEDURE (enterobj:EnterTermsObject) Init*;

BEGIN
  enterobj.chable:=m.taskdata.maintask;

  enterobj.InitTask(EnterTermsTask,enterobj,10000,m.taskdata.requesterpri);
  enterobj.SetID(tid.enterTermsTaskID);
  enterobj.Init^;
END Init;

PROCEDURE (enterobj:EnterTermsObject) Destruct*;

BEGIN
  enterobj.Destruct^;
END Destruct;



(* Additional Procedures for Define-Object *)

(* General procedures for Define *)

PROCEDURE ChangeDefine*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    ok,ca,
    help,
    newdefine,
    deldefine,
    copydefine : gmo.BooleanGadget;
    termlv,
    definelv   : gmo.ListView;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    actdefine,
    actterm,
    node,node2,
    node3      : l.Node;
    mes        : I.IntuiMessagePtr;
    text       : POINTER TO ARRAY OF ARRAY OF CHAR;
    oldstart,
    oldend     : LONGREAL;
    oldstartequal,
    oldendequal: BOOLEAN;
    oldtype    : INTEGER;
    bool,ret,
    copydb     : BOOLEAN;
    i          : INTEGER;

PROCEDURE RefreshDefine;

BEGIN
  IF actdefine#NIL THEN
    definelv.SetString(actdefine(t.Define).string);
    definelv.SetValue(actterm(t.Term).define.GetNodeNumber(actdefine));
  ELSE
    definelv.Refresh;
  END;
END RefreshDefine;

BEGIN
  t.terms.NewUser(m.taskdata.maintask);
  NEW(mes);
  ret:=FALSE;
  IF definewind=NIL THEN
    definewind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeUserDomain),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=definewind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      definelv:=gmo.SetListView(ac.GetString(ac.UserDefinitionDomain),NIL,t.PrintDefine,0,TRUE,255);
      newdefine:=gmo.SetBooleanGadget(ac.GetString(ac.NewDomain));
      deldefine:=gmo.SetBooleanGadget(ac.GetString(ac.DelDomain));
      copydefine:=gmo.SetBooleanGadget(ac.GetString(ac.CopyDomain));
    gmb.EndBox;
    termlv:=gmo.SetListView(ac.GetString(ac.Functions),t.terms,t.PrintTerm,0,FALSE,255);
  glist:=root.EndRoot();
  definelv.SetNoEntryText(s.ADR("Defined at all values x."));
  termlv.SetNoEntryText(s.ADR("No terms!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actterm:=t.terms.GetNode(termlv.GetValue());
    IF actterm#NIL THEN
      actdefine:=actterm(t.Term).define.head;
      definelv.ChangeListView(actterm(t.Term).define,0);
    END;

    RefreshDefine;

    NEW(text,4,50);

    copydb:=FALSE;
    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF actdefine#NIL THEN
        definelv.GetString(actdefine(t.Define).string);
      END;
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          i:=0;
          node:=t.terms.head;
          WHILE node#NIL DO
            node2:=node(t.Term).define.head;
            WHILE node2#NIL DO
              WITH node2: t.Define DO
                oldstart:=node2.start;
                oldend:=node2.end;
                oldstartequal:=node2.startequal;
                oldendequal:=node2.endequal;
                oldtype:=node2.type;
                i:=node2.MakeDefine();
                IF (node2.start#oldstart) OR (node2.end#oldend) OR (node2.startequal#oldstartequal) OR (node2.endequal#oldendequal) OR (node2.type#oldtype) THEN
                  node(t.Term).changed:=TRUE;
                  IF node(t.Term).basefunc#NIL THEN
                    node(t.Term).basefunc(t.Function).changed:=TRUE;
                  END;
                END;
                IF i#0 THEN
                  actterm:=node;
                  actdefine:=node2;
                END;
              END;
              node2:=node2.next;
              IF i#0 THEN
                node2:=NIL;
              END;
            END;
            node:=node.next;
            IF i#0 THEN
              node:=NIL;
            END;
          END;
          IF i=0 THEN
            ret:=TRUE;
            EXIT;
          ELSE
            COPY(ac.GetString(ac.ErrorInDomainInput)^,text[0]);
            COPY(actdefine(t.Define).string,text[1]);
            text[2]:="";
            IF i=1 THEN
              COPY(ac.GetString(ac.SymbolsMissing)^,text[3]);
            ELSIF (i=2) OR (i=3) THEN
              COPY(ac.GetString(ac.DomainMustContainAtLeast)^,text[2]);
              COPY(ac.GetString(ac.TwoLimits)^,text[3]);
            ELSIF i=3 THEN
              COPY(ac.GetString(ac.MissingFourth)^,text[3]);
            END;
            bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
            RefreshDefine;
          END;
        ELSIF mes.iAddress=newdefine.gadget THEN
          IF actterm#NIL THEN
            node:=NIL;
            NEW(node(t.Define));
            node(t.Define).Init;
            actdefine:=node;
            actterm(t.Term).define.AddTail(node);
            actterm(t.Term).changed:=TRUE;
            IF actterm(t.Term).basefunc#NIL THEN
              actterm(t.Term).basefunc(t.Function).changed:=TRUE;
            END;
            RefreshDefine;
          END;
        ELSIF mes.iAddress=deldefine.gadget THEN
          IF actdefine#NIL THEN
            node:=actdefine.next;
            IF node=NIL THEN
              node:=actdefine.prev;
            END;
            actdefine.Remove;
            actdefine:=node;
            actterm(t.Term).changed:=TRUE;
            IF actterm(t.Term).basefunc#NIL THEN
              actterm(t.Term).basefunc(t.Function).changed:=TRUE;
            END;
            RefreshDefine;
          END;
        ELSIF mes.iAddress=copydefine.gadget THEN
          copydb:=NOT(copydb);
        ELSIF mes.iAddress=definelv.stringgad THEN
          definelv.Refresh;
          definelv.Activate;
        ELSIF mes.iAddress=definelv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            IF actterm#NIL THEN
              node:=actdefine;
              actdefine:=actterm(t.Term).define.GetNode(definelv.GetValue());
              IF (node#NIL) AND (actdefine#NIL) THEN
                IF copydb THEN
                  COPY(node(t.Define).string,actdefine(t.Define).string);
(*                  gm.DeActivateBool(copyd,wind);*)
                  copydb:=FALSE;
                END;
              END;
              RefreshDefine;
            END;
          END;
        ELSIF mes.iAddress=termlv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            node:=actterm;
            actterm:=t.terms.GetNode(termlv.GetValue());
            IF actterm#NIL THEN
              actdefine:=actterm(t.Term).define.head;
              definelv.ChangeListView(actterm(t.Term).define,0);
            END;
            RefreshDefine;
          END;
        END;
      END;
(*      IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) OR ((I.rawKey IN mes.class) AND (mes.code=95)) THEN
        ag.ShowFile(s1.analaydoc,"defrange",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.terms.FreeUser(m.taskdata.maintask);
  RETURN ret;
END ChangeDefine;



PROCEDURE ConnectTerms*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    newfunc,
    delfunc,
    copyfunc,
    taketerm,
    delterm    : gmo.BooleanGadget;
    funclv,
    functermlv,
    termlv     : gmo.ListView;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    actfunc,
    actfuncterm,
    actterm,
    node,node2,
    node3      : l.Node;
    mes        : I.IntuiMessagePtr;
    bool,ret,
    copyfb     : BOOLEAN;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    funclv.SetString(actfunc(t.Function).name);
    funclv.ChangeListViewSpecial(SHORT(t.NumberNotBaseFuncs()),t.PrintNotBaseFunction);
    funclv.SetValue(t.GetFuncNodeNumber(t.functions,actfunc));

    functermlv.ChangeListView(actfunc(t.Function).terms,SHORT(actfunc(t.Function).terms.GetNodeNumber(actfuncterm)));
  ELSE
    funclv.ChangeListViewSpecial(0,t.PrintNotBaseFunction);
  END;
END RefreshFunc;

PROCEDURE RefreshFuncTerm;

BEGIN
  IF actfunc#NIL THEN
    functermlv.SetNoEntryText(s.ADR("No terms!"));
    functermlv.ChangeListViewSpecial(-1,t.PrintFunctionTerm);
    functermlv.ChangeListView(actfunc(t.Function).terms,SHORT(actfunc(t.Function).terms.GetNodeNumber(actfuncterm)));
  ELSE
    functermlv.SetNoEntryText(s.ADR("No connection!"));
    functermlv.ChangeListViewSpecial(0,t.PrintFunctionTerm);
  END;
END RefreshFuncTerm;

PROCEDURE RefreshTerm;

BEGIN
  IF actterm#NIL THEN
    termlv.SetValue(t.terms.GetNodeNumber(actterm));
  ELSE
    termlv.Refresh;
  END;
END RefreshTerm;

BEGIN
  t.terms.NewUser(m.taskdata.maintask);
  t.functions.NewUser(m.taskdata.maintask);
  NEW(mes);
  ret:=FALSE;
  IF connectwind=NIL THEN
    connectwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ConnectFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=connectwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      funclv:=gmo.SetListView(ac.GetString(ac.Connections),t.functions,t.PrintNotBaseFunction,0,TRUE,255);
      newfunc:=gmo.SetBooleanGadget(ac.GetString(ac.NewConnection));
      delfunc:=gmo.SetBooleanGadget(ac.GetString(ac.DelConnection));
      copyfunc:=gmo.SetBooleanGadget(ac.GetString(ac.CopyConnection));
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        functermlv:=gmo.SetListView(ac.GetString(ac.ConnectedFunctions),NIL,t.PrintFunctionTerm,0,FALSE,255);
        termlv:=gmo.SetListView(ac.GetString(ac.Functions),t.terms,t.PrintTerm,0,FALSE,255);
      gmb.EndBox;
      taketerm:=gmo.SetBooleanGadget(ac.GetString(ac.InsertFunction));
      delterm:=gmo.SetBooleanGadget(ac.GetString(ac.DelFunction)); (* DelFunctionCreateWindow? *)
    gmb.EndBox;
  glist:=root.EndRoot();
  funclv.SetNoEntryText(s.ADR("No connections!"));
  functermlv.SetNoEntryText(s.ADR("No terms!"));
  termlv.SetNoEntryText(s.ADR("No terms!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actfunc:=t.GetFuncNode(t.functions,funclv.GetValue());
    IF actfunc#NIL THEN
      actfuncterm:=actfunc(t.Function).terms.GetNode(functermlv.GetValue());
    END;
    actterm:=t.terms.GetNode(termlv.GetValue());

    RefreshFunc;
    RefreshFuncTerm;
    RefreshTerm;

    copyfb:=FALSE;
    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF actfunc#NIL THEN
        funclv.GetString(actfunc(t.Function).name);
      END;
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          node:=t.functions.head;
          WHILE node#NIL DO
            IF NOT(node(t.Function).isbase) THEN
              node(t.Function).MakeDepend;
            END;
            node:=node.next;
          END;
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=newfunc.gadget THEN
          node:=NIL;
          NEW(node(t.Function));
          node(t.Function).Init;
          COPY(ac.GetString(ac.Connection)^,node(t.Function).name);
          node(t.Function).isbase:=FALSE;
          actfunc:=node;
          t.functions.AddTail(actfunc);
          actfuncterm:=NIL;
          RefreshFunc;
          RefreshFuncTerm;
        ELSIF mes.iAddress=delfunc.gadget THEN
          IF actfunc#NIL THEN
            node:=actfunc;
            LOOP
              node:=node.next;
              IF node=NIL THEN
                EXIT;
              END;
              IF NOT(node(t.Function).isbase) THEN
                EXIT;
              END;
            END;
            IF node=NIL THEN
              node:=actfunc;
              LOOP
                node:=node.prev;
                IF node=NIL THEN
                  EXIT;
                END;
                IF NOT(node(t.Function).isbase) THEN
                  EXIT;
                END;
              END;
            END;
            actfunc.Remove;
            mem.NodeToGarbage(actfunc(t.Function));
            actfunc:=node;
            IF actfunc#NIL THEN
              actfuncterm:=actfunc(t.Function).terms.head;
            ELSE
              actfuncterm:=NIL;
            END;
            RefreshFunc;
            RefreshFuncTerm;
          END;
        ELSIF mes.iAddress=copyfunc.gadget THEN
          copyfb:=NOT(copyfb);
        ELSIF mes.iAddress=taketerm.gadget THEN
          IF (actfunc#NIL) AND (actterm#NIL) THEN
            actterm(t.Function).NewUser;
            node:=NIL;
            NEW(node(t.FuncTerm));
            node(t.FuncTerm).term:=actterm(t.Term);
            actfunc(t.Function).changed:=TRUE;
            actfuncterm:=node;
            actfunc(t.Function).terms.AddTail(node);
            RefreshFuncTerm;
          END;
        ELSIF mes.iAddress=delterm.gadget THEN
          IF actfuncterm#NIL THEN
            actfuncterm(t.FuncTerm).term.FreeUser;
            node:=actfuncterm.next;
            IF node=NIL THEN
              node:=actfuncterm.prev;
            END;
            actfuncterm.Remove;
            actfuncterm:=node;
            actfunc(t.Function).changed:=TRUE;
            RefreshFuncTerm;
          END;
        ELSIF mes.iAddress=funclv.stringgad THEN
          IF actfunc#NIL THEN
            funclv.Refresh;
            funclv.Activate;
          END;
        ELSIF mes.iAddress=funclv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            node:=actfunc;
            actfunc:=t.GetFuncNode(t.functions,funclv.GetValue());
            IF (node#NIL) AND (actfunc#NIL) THEN
              IF copyfb THEN
                COPY(node(t.Function).name,actfunc(t.Function).name);
                actfunc(t.Function).changed:=TRUE;
                actfunc(t.Function).isbase:=FALSE;

                IF actfunc(t.Function).depend#NIL THEN actfunc(t.Function).depend.Destruct; END;
                actfunc(t.Function).depend:=l.Create();
                node(t.Function).depend.Copy(actfunc(t.Function).depend);

                IF actfunc(t.Function).define#NIL THEN actfunc(t.Function).define.Destruct; END;
                actfunc(t.Function).define:=l.Create();
                node(t.Function).define.Copy(actfunc(t.Function).define);

                IF actfunc(t.Function).terms#NIL THEN actfunc(t.Function).terms.Destruct; END;
                actfunc(t.Function).terms.Init;
                node2:=node(t.Function).terms.head;
                WHILE node2#NIL DO
                  node3:=NIL;
                  NEW(node3(t.FuncTerm));
                  node3(t.FuncTerm).term:=node2(t.FuncTerm).term;
                  actfunc(t.Function).terms.AddTail(node3);
                  node2:=node2.next;
                END;
(*                gm.DeActivateBool(copyf,wind);*)
                copyfb:=FALSE;
              END;
            END;
            actfuncterm:=actfunc(t.Function).terms.head;
            RefreshFunc;
            RefreshFuncTerm;
          END;
        ELSIF mes.iAddress=functermlv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            IF actfunc#NIL THEN
              actfuncterm:=actfunc(t.Function).terms.GetNode(functermlv.GetValue());
            END;
          END;
        ELSIF mes.iAddress=termlv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            actterm:=t.terms.GetNode(termlv.GetValue());
          END;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"connectfuncs",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(m.taskdata.maintask);
  t.terms.FreeUser(m.taskdata.maintask);
  RETURN ret;
END ConnectTerms;



PROCEDURE MirrorFunction*(VAR x,y:ARRAY OF CHAR;VAR type:INTEGER):BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    xval,yval  : gmo.StringGadget;
    radio      : gmo.RadioButtons;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    textarray  : ARRAY 4 OF e.STRPTR;
    ret        : BOOLEAN;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF mirrorwind=NIL THEN
    mirrorwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,ac.GetString(ac.ReflectFunction),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=mirrorwind.InitSub(mg.screen);

  textarray[0]:=ac.GetString(ac.ThroughLineX);
  textarray[1]:=ac.GetString(ac.ThroughLineY);
  textarray[2]:=ac.GetString(ac.ThroughPoint);
  textarray[3]:=NIL;

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      gadobj:=gmo.SetText(ac.GetString(ac.ReflectFunction),-1);
      radio:=gmo.SetRadioButtons(s.ADR(textarray),type);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      xval:=gmo.SetStringGadget(s.ADR("x"),255);
      xval.SetMinVisible(5);
      yval:=gmo.SetStringGadget(s.ADR("y"),255);
      yval.SetMinVisible(5);
    gmb.EndBox;
  glist:=root.EndRoot();

  xval.SetString(x);
  yval.SetString(y);
  IF type=0 THEN
    yval.Disable(TRUE);
  ELSIF type=1 THEN
    xval.Disable(TRUE);
  END;

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          xval.GetString(x);
          yval.GetString(y);
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          EXIT;
        END;
      ELSIF I.gadgetDown IN mes.class THEN
        IF mes.iAddress=radio.gadget THEN
          type:=SHORT(radio.GetValue());
          IF type=0 THEN
            xval.Disable(FALSE);(* xval.Refresh;*)
            yval.Disable(TRUE); (* yval.Refresh;*)
            xval.Activate;
          ELSIF type=1 THEN
            xval.Disable(TRUE); (* xval.Refresh;*)
            yval.Disable(FALSE);(* yval.Refresh;*)
            yval.Activate;
          ELSIF type=2 THEN
            xval.Disable(FALSE);(* xval.Refresh;*)
            yval.Disable(FALSE);(* yval.Refresh;*)
            xval.Activate;
          END;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"mirrorfunc",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END MirrorFunction;

PROCEDURE ProcessFunctions*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    der,tang,
    norm,mir   : gmo.BooleanGadget;
    funclv     : gmo.ListView;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    actfunc,term,
    node,node2,
    node3      : l.Node;
    nodef,
    nodef2,
    nodef3,
    nodex      : fb.Node;
    bool,ret   : BOOLEAN;
    switchtext : ARRAY 2 OF ARRAY 80 OF CHAR;
    switchpos,
    pos,type   : INTEGER;
    string     : ARRAY 80 OF CHAR;
    px,py,alpha,
    dx1,dy1,
    dx2,dy2    : LONGREAL;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    funclv.SetValue(t.functions.GetNodeNumber(actfunc));
  ELSE
    funclv.Refresh;
  END;
END RefreshFunc;

PROCEDURE ReplaceX(VAR node,nodex:fb.Node);

VAR node2 : fb.Node;
(*    parent,
    right,
    left   : f1.NodePtr;*)

BEGIN
  IF node#NIL THEN
    IF (node IS fb.TreeObj) AND (node(fb.TreeObj).object#NIL) AND (node(fb.TreeObj).object IS fb.XYObject) AND (node(fb.TreeObj).object(fb.XYObject).isX) THEN
      node2:=node;
      node:=fb.CopyTree(nodex);
(*      node:=NIL;
      NEW(node(f1.Number));
      node(f1.Number).real:=x;*)
      node.parent:=node2.parent;
(*      node.left:=node2.left;
      node.right:=node2.right;*)
    END;
(*    IF node IS f2.X THEN
      parent:=node.parent;
      right:=node.right;
      left:=node.left;
      node:=NIL;
      NEW(node(f2.Number));
      node(f2.Number).real:=SHORT(x);
      node.parent:=parent;
      node.right:=right;
      node.left:=left;
      IF node.right#NIL THEN
        node.right.parent:=node;
      END;
      IF node.left#NIL THEN
        node.left.parent:=node;
      END;
    ELSIF node IS f2.Constant THEN
      IF node(f2.Constant).isX THEN
        parent:=node.parent;
        right:=node.right;
        left:=node.left;
        node:=NIL;
        NEW(node(f2.Number));
        node(f2.Number).real:=SHORT(x);
        node.parent:=parent;
        node.right:=right;
        node.left:=left;
        IF node.right#NIL THEN
          node.right.parent:=node;
        END;
        IF node.left#NIL THEN
          node.left.parent:=node;
        END;
      END;
    END;*)
    ReplaceX(node.left,nodex);
    ReplaceX(node.right,nodex);
    IF node IS fb.Operation THEN
      ReplaceX(node(fb.Operation).root,nodex);
      ReplaceX(node(fb.Operation).data,nodex);
    END;
  END;
END ReplaceX;

PROCEDURE MirrorNode(VAR node:fb.Node;offset:fb.Node);

VAR node2 : fb.Node;

BEGIN
  node2:=node.parent;
  node.parent:=NIL;
  NEW(node.parent(fb.Sign));
  node.parent.right:=node;
  node:=node.parent;
  node(fb.Sign).sign:="-";
  NEW(node.left(fb.Number));
  node.left.parent:=node;
  node.left(fb.Number).real:=0;
  NEW(node.parent(fb.Sign));
  node.parent.left:=node;
  node:=node.parent;
  node(fb.Sign).sign:="+";
  node.parent:=node2;
  NEW(node.right(fb.Sign));
  node.right.parent:=node;
  node2:=node.right;
  node2(fb.Sign).sign:="*";
  NEW(node2.left(fb.Number));
  node2.left.parent:=node2;
  node2.left(fb.Number).real:=2;
  node2.right:=fb.CopyTree(offset);
  node2.right.parent:=node2;
END MirrorNode;

PROCEDURE Mirror(VAR node:fb.Node;offset:fb.Node);

BEGIN
  IF node#NIL THEN
    Mirror(node.left,offset);
    Mirror(node.right,offset);
    IF node IS fb.Operation THEN
      Mirror(node(fb.Operation).root,offset);
      Mirror(node(fb.Operation).data,offset);
    END;
    IF (node IS fb.TreeObj) AND (node(fb.TreeObj).object#NIL) AND (node(fb.TreeObj).object IS fb.XYObject) AND (node(fb.TreeObj).object(fb.XYObject).isX) THEN
      MirrorNode(node,offset);
    END;
  END;
END Mirror;

BEGIN
  t.terms.NewUser(m.taskdata.maintask);
  t.functions.NewUser(m.taskdata.maintask);
  NEW(mes);
  ret:=FALSE;
  IF processwind=NIL THEN
    processwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ProcessFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=processwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    funclv:=gmo.SetListView(ac.GetString(ac.Functions),t.functions,t.PrintFunction,0,FALSE,255);
    der:=gmo.SetBooleanGadget(ac.GetString(ac.DeriveFunction));
    tang:=gmo.SetBooleanGadget(ac.GetString(ac.TangentAtPoint));
    norm:=gmo.SetBooleanGadget(ac.GetString(ac.NormalAtPoint));
    mir:=gmo.SetBooleanGadget(ac.GetString(ac.ReflectFunction));
  glist:=root.EndRoot();
  funclv.SetNoEntryText(s.ADR("No functions!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actfunc:=t.functions.GetNode(funclv.GetValue());

    RefreshFunc;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=der.gadget THEN
          IF actfunc#NIL THEN
            subwind.SetBusyPointer;
            bool:=gb.EnterString(mg.screen,ac.GetString(ac.Derivative),ac.GetString(ac.DeriveFor),derstr);
            IF bool THEN
              IF actfunc(t.Function).isbase THEN
                term:=actfunc(t.Function).terms.head(t.FuncTerm).term;
                node:=NIL;
                NEW(node(t.Term));
                node(t.Term).Init;
                COPY(term(t.Term).term^,node(t.Term).term^);
                actfunc(t.Function).terms.head(t.FuncTerm).term.AddBehind(node);
                pos:=0;
                node(t.Term).tree:=ft.Parse(node(t.Term).term^);
                bool:=fs.Optimize(node(t.Term).tree);
                fd.Derive(node(t.Term).tree,derstr);
                bool:=fs.Optimize(node(t.Term).tree);
                ft.TreeToString(node(t.Term).tree,node(t.Term).term^);
                node2:=NIL;
                NEW(node2(t.Function));
                node2(t.Function).Init;
                COPY(node(t.Term).term^,node2(t.Function).name);
                node2(t.Function).isbase:=TRUE;
                node3:=NIL;
                NEW(node3(t.FuncTerm));
                node3(t.FuncTerm).term:=node(t.Term);
                node2(t.Function).terms.AddTail(node3);
                node(t.Term).basefunc:=node2;
                node(t.Term).MakeDepend;
                actfunc.AddBehind(node2);
                actfunc:=node2;
              ELSE
                node:=actfunc(t.Function).AbleitFunction(derstr);
                actfunc.AddBehind(node);
                actfunc:=node;
              END;
              RefreshFunc;
            END;
            subwind.ClearPointer;
          END;
        ELSIF mes.iAddress=tang.gadget THEN
          IF actfunc#NIL THEN
            subwind.SetBusyPointer;
            bool:=gb.EnterPoint(mg.screen,pxs,pys,TRUE);
            IF bool THEN
              px:=ft.ExpressionToReal(pxs);
              term:=actfunc(t.Function).GetFunctionTerm(px);
              nodex:=ft.Parse(pxs);
              nodef:=NIL;
              nodef2:=NIL;
              nodef3:=NIL;
              pos:=0;
  (*            pos:=0;
              nodef:=f.Parse(pys,pos);
              py:=f.RechenLong(nodef,0,0,pos);*)
              pos:=0;
              nodef:=ft.Parse(term(t.Term).term^);
              pos:=0;
              py:=actfunc(t.Function).GetFunctionValue(px,0,pos);
              IF pos=0 THEN
                nodef2:=fb.CopyTree(nodef);
                fs.Simplify(nodef2);
                fd.Derive(nodef2,"x");
                fs.Simplify(nodef2);
                ReplaceX(nodef2,nodex);
                nodef2.parent:=NIL;
                NEW(nodef2.parent(fb.Sign));
                nodef2.parent.left:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(fb.Sign).sign:="*";
                nodef2.right:=NIL;
                NEW(nodef2.right(fb.Sign));
                nodef2.right.parent:=nodef2;
                nodef3:=nodef2.right;
                nodef3(fb.Sign).sign:="-";
                NEW(nodef3.left(fb.TreeObj));
                nodef3.left.parent:=nodef3;
                NEW(nodef3.left(fb.TreeObj).object(fb.XYObject));
                nodef3.left(fb.TreeObj).object(fb.XYObject).isX:=TRUE;
                NEW(nodef3.left(fb.TreeObj).object(fb.XYObject).name,2);
                COPY("x",nodef3.left(fb.TreeObj).object(fb.XYObject).name^);
                nodef3.right:=fb.CopyTree(nodex);
                nodef3.right.parent:=nodef3;
                NEW(nodef2.parent(fb.Sign));
                nodef2.parent.left:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(fb.Sign).sign:="+";
                nodef2.right:=fb.CopyTree(nodef);
                nodef2.right.parent:=nodef2;
                ReplaceX(nodef2.right,nodex);
                fs.Simplify(nodef2);
(*                alpha:=f.CalcLong(nodef,px,0,pos);
                ReplaceX(nodef,px);
                f.Simplify(nodef);
(*                NEW(nodef2(f2.Bracket));
                nodef2(f2.Bracket).root:=nodef;*)
                NEW(nodef2(f1.Sign));
                nodef2(f1.Sign).sign:="*";
                NEW(nodef2.right(f1.TreeObj));
                NEW(nodef2.right(f1.TreeObj).object(f1.XYObject));
                NEW(nodef2.right(f1.TreeObj).object(f1.Object).name,2);
                nodef2.right(f1.TreeObj).object(f1.Object).name^:="x";
                nodef2.right(f1.TreeObj).object(f1.XYObject).isX:=TRUE;
                nodef2.right.parent:=nodef2;
                nodef2.left:=nodef;
                nodef.parent:=nodef2;
                NEW(nodef3(f1.Sign));
                nodef3(f1.Sign).sign:="+";
                nodef3.left:=nodef2;
                nodef2.parent:=nodef3;
                NEW(nodef3.right(f1.Number));
                nodef3.right.parent:=nodef3;
                IF alpha#0 THEN
  (*                alpha:=mdt.Atan(alpha);*)
                  dy1:=py;
                  dx1:=py/alpha;
                  dx2:=px-dx1;
                  dy2:=-alpha*dx2;
                  IF dy2<0 THEN
                    dy2:=-dy2;
                    nodef3(f1.Sign).sign:="-";
                  END;
                  nodef3.right(f1.Number).real:=dy2;
                ELSE
                  nodef3:=NIL;
                  NEW(nodef3(f1.Number));
                  nodef3(f1.Number).real:=py;
                END;
                f.Simplify(nodef3);*)
(*                py:=f.CalcLong(nodef2,px,0.0001,pos);
                IF pos=0 THEN*)
                  node:=NIL;
                  NEW(node(t.Term));
                  node(t.Term).Init;
                  ft.TreeToString(nodef2,node(t.Term).term^);
                  IF (term.next#NIL) OR (term.prev#NIL) OR (t.terms.head=term) OR (t.terms.tail=term) THEN
                    term.AddBehind(node);
                  END;
                  node2:=NIL;
                  NEW(node2(t.Function));
                  node2(t.Function).Init;
                  COPY(node(t.Term).term^,node2(t.Function).name);
                  node2(t.Function).isbase:=TRUE;
                  node3:=NIL;
                  NEW(node3(t.FuncTerm));
                  node3(t.FuncTerm).term:=node(t.Term);
                  node2(t.Function).terms.AddTail(node3);
                  actfunc.AddBehind(node2);
                  node(t.Term).basefunc:=node2;
                  actfunc:=node2;
                  node(t.Term).MakeDepend;
                  RefreshFunc;
(*                ELSE
                  bool:=r.RequestWin("Tangente darf nicht","senkrecht sein!","","   OK   ",wind);
                END;*)
              ELSE
                bool:=rt.RequestWin(ac.GetString(ac.TangentCannotBe),ac.GetString(ac.DrawnAtAGapTangent),s.ADR(""),ac.GetString(ac.OK),wind);
              END;
            END;
            subwind.ClearPointer;
          END;
        ELSIF mes.iAddress=norm.gadget THEN
          IF actfunc#NIL THEN
            subwind.SetBusyPointer;
            bool:=gb.EnterPoint(mg.screen,pxs,pys,TRUE);
            IF bool THEN
              px:=ft.ExpressionToReal(pxs);
              term:=actfunc(t.Function).GetFunctionTerm(px);
              nodex:=ft.Parse(pxs);
              nodef:=NIL;
              nodef2:=NIL;
              nodef3:=NIL;
              pos:=0;
  (*            pos:=0;
              nodef:=f.Parse(pys,pos);
              py:=f.RechenLong(nodef,0,0,pos);*)
              pos:=0;
              nodef:=ft.Parse(term(t.Term).term^);
              pos:=0;
              py:=actfunc(t.Function).GetFunctionValue(px,0,pos);
              IF pos=0 THEN
                nodef2:=fb.CopyTree(nodef);
                fs.Simplify(nodef2);
                fd.Derive(nodef2,"x");
                fs.Simplify(nodef2);
                ReplaceX(nodef2,nodex);
                nodef2.parent:=NIL;
                NEW(nodef2.parent(fb.Sign));
                nodef2.parent.right:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(fb.Sign).sign:="/";
                NEW(nodef2.left(fb.Number));
                nodef2.left.parent:=nodef2;
                nodef2.left(fb.Number).real:=1;
                NEW(nodef2.parent(fb.Sign));
                nodef2.parent.right:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(fb.Sign).sign:="-";
                NEW(nodef2.left(fb.Number));
                nodef2.left.parent:=nodef2;
                nodef2.left(fb.Number).real:=0;
                NEW(nodef2.parent(fb.Sign));
                nodef2.parent.left:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(fb.Sign).sign:="*";
                nodef2.right:=NIL;
                NEW(nodef2.right(fb.Sign));
                nodef2.right.parent:=nodef2;
                nodef3:=nodef2.right;
                nodef3(fb.Sign).sign:="-";
                NEW(nodef3.left(fb.TreeObj));
                nodef3.left.parent:=nodef3;
                NEW(nodef3.left(fb.TreeObj).object(fb.XYObject));
                nodef3.left(fb.TreeObj).object(fb.XYObject).isX:=TRUE;
                NEW(nodef3.left(fb.TreeObj).object(fb.XYObject).name,2);
                COPY("x",nodef3.left(fb.TreeObj).object(fb.XYObject).name^);
                nodef3.right:=fb.CopyTree(nodex);
                nodef3.right.parent:=nodef3;
                NEW(nodef2.parent(fb.Sign));
                nodef2.parent.left:=nodef2;
                nodef2:=nodef2.parent;
                nodef2(fb.Sign).sign:="+";
                nodef2.right:=fb.CopyTree(nodef);
                nodef2.right.parent:=nodef2;
                ReplaceX(nodef2.right,nodex);
                fs.Simplify(nodef2);
(*(*                NEW(nodef2(f2.Bracket));
                nodef2(f2.Bracket).root:=nodef;*)
                NEW(nodef2(f1.Sign));
                nodef2(f1.Sign).sign:="/";
                nodef2.right:=nodef;
                nodef.parent:=nodef2;
                NEW(nodef2.left(f1.Number));
                nodef2.left(f1.Number).real:=-1;
                nodef2.left.parent:=nodef2;
                nodef:=nodef2;
                nodef2:=NIL;
                ReplaceX(nodef,px);
                f.Simplify(nodef);
                NEW(nodef2(f1.Sign));
                nodef2(f1.Sign).sign:="*";
                NEW(nodef2.right(f1.TreeObj));
                NEW(nodef2.right(f1.TreeObj).object(f1.XYObject));
                NEW(nodef2.right(f1.TreeObj).object(f1.Object).name,2);
                nodef2.right(f1.TreeObj).object(f1.Object).name^:="x";
                nodef2.right(f1.TreeObj).object(f1.XYObject).isX:=TRUE;
                nodef2.right.parent:=nodef2;
                nodef2.left:=nodef;
                NEW(nodef3(f1.Sign));
                nodef3(f1.Sign).sign:="+";
                nodef3.left:=nodef2;
                nodef2.parent:=nodef3;
                NEW(nodef3.right(f1.Number));
                nodef3.right.parent:=nodef3;
(*                NEW(nodef2(f2.Bracket));
                nodef2(f2.Bracket).root:=nodef;
                NEW(nodef2.parent(f2.Sign));
                nodef2.parent(f2.Sign).sign:="*";
                NEW(nodef2.parent.right(f2.Constant));
                nodef2.parent.right(f2.Constant).isX:=TRUE;
                nodef2.parent.right.parent:=nodef2.parent;
                nodef2.parent.left:=nodef2;
                NEW(nodef3(f2.Sign));
                nodef3(f2.Sign).sign:="+";
                nodef3.left:=nodef2.parent;
                nodef2.parent.parent:=nodef3;
                NEW(nodef3.right(f2.Number));
                nodef3.right.parent:=nodef3;*)
                alpha:=f.CalcLong(nodef,px,0,pos);
                IF alpha#0 THEN
  (*                alpha:=mdt.Atan(alpha);*)
                  dy1:=py;
                  dx1:=py/alpha;
                  dx2:=px-dx1;
                  dy2:=-alpha*dx2;
                  IF dy2<0 THEN
                    dy2:=-dy2;
                    nodef3(f1.Sign).sign:="-";
                  END;
                  nodef3.right(f1.Number).real:=dy2;
                ELSE
                  nodef3:=NIL;
                  NEW(nodef3(f1.Number));
                  nodef3(f1.Number).real:=py;
                END;
                f.Simplify(nodef3);*)
(*                py:=f.CalcLong(nodef2,px,0.0001,pos);
                IF pos=0 THEN*)
                  node:=NIL;
                  NEW(node(t.Term));
                  node(t.Term).Init;
                  ft.TreeToString(nodef2,node(t.Term).term^);
                  IF (term.next#NIL) OR (term.prev#NIL) OR (t.terms.head=term) OR (t.terms.tail=term) THEN
                    term.AddBehind(node);
                  END;
                  node2:=NIL;
                  NEW(node2(t.Function));
                  node2(t.Function).Init;
                  COPY(node(t.Term).term^,node2(t.Function).name);
                  node2(t.Function).isbase:=TRUE;
                  node3:=NIL;
                  NEW(node3(t.FuncTerm));
                  node3(t.FuncTerm).term:=node(t.Term);
                  node2(t.Function).terms.AddTail(node3);
                  actfunc.AddBehind(node2);
                  node(t.Term).basefunc:=node2;
                  actfunc:=node2;
                  node(t.Term).MakeDepend;
                  RefreshFunc;
(*                ELSE
                  bool:=r.RequestWin("Normale darf nicht","senkrecht sein!","","   OK   ",wind);
                END;*)
              ELSE
                bool:=rt.RequestWin(ac.GetString(ac.NormalCannotBe),ac.GetString(ac.DrawnAtAGapNormal),s.ADR(""),ac.GetString(ac.OK),wind);
              END;
            END;
            subwind.ClearPointer;
          END;
(*        ELSIF address=switch THEN
          gm.CyclePressed(switch,wind,switchtext,switchpos);
          listterms:=NOT(listterms);
          NewTermList;*)
        ELSIF mes.iAddress=mir.gadget THEN
          IF actfunc#NIL THEN
            bool:=MirrorFunction(xstr,ystr,type);
            IF bool THEN
              node:=NIL;
              NEW(node(t.Function));
              node(t.Function).Init;
              actfunc.Copy(node);
              WITH node: t.Function DO
                COPY(ac.GetString(ac.ReflectionOf)^,node.name);
                st.Append(node.name,actfunc(t.Function).name);
(*                s1.CopyList(actfunc(s1.Function).terms,node.terms);
                s1.CopyList(actfunc(s1.Function).define,node.define);
                s1.CopyList(actfunc(s1.Function).depend,node.depend);
                node.isbase:=actfunc(t.Function).isbase;*)
                node.CreateAllTrees;
                IF (type=0) OR (type=2) THEN
(*                  IF type=0 THEN*)
                    nodef3:=ft.Parse(xstr);
(*                  ELSE
                    nodef3:=ft.Parse(pxstr);
                  END;*)
                  fs.Simplify(nodef3);
                  node2:=node.terms.head;
                  WHILE node2#NIL DO
                    IF node2(t.FuncTerm).term(t.Term).basefunc=actfunc THEN
                      node2(t.FuncTerm).term(t.Term).basefunc:=node;
                    END;
                    term:=node2(t.FuncTerm).term;
                    fs.Simplify(term(t.Term).tree);
                    Mirror(term(t.Term).tree,nodef3);
                    fs.Simplify(term(t.Term).tree);
                    ft.TreeToString(term(t.Term).tree,term(t.Term).term^);
                    node2(t.FuncTerm).term.MakeDepend;
                    node2:=node2.next;
                  END;
                END;
                IF (type=1) OR (type=2) THEN
(*                  IF type=1 THEN*)
                    nodef3:=ft.Parse(ystr);
(*                  ELSE
                    nodef3:=ft.Parse(pystr);
                  END;*)
                  fs.Simplify(nodef3);
                  node2:=node.terms.head;
                  WHILE node2#NIL DO
                    IF node2(t.FuncTerm).term(t.Term).basefunc=actfunc THEN
                      node2(t.FuncTerm).term(t.Term).basefunc:=node;
                    END;
                    term:=node2(t.FuncTerm).term;
                    fs.Simplify(term(t.Term).tree);
                    MirrorNode(term(t.Term).tree,nodef3);
                    fs.Simplify(term(t.Term).tree);
                    ft.TreeToString(term(t.Term).tree,term(t.Term).term^);
                    node2(t.FuncTerm).term.MakeDepend;
                    node2:=node2.next;
                  END;
                END;
                IF node.isbase THEN
                  IF term#NIL THEN
                    COPY(node.terms.head(t.FuncTerm).term(t.Term).term^,node.name);
                    actfunc(t.Function).terms.head(t.FuncTerm).term.AddBehind(term);
                  END;
                END;
              END;
              actfunc.AddBehind(node);
              actfunc:=node;
              RefreshFunc;
            END;
          END;
        ELSIF mes.iAddress=funclv.scrollgad THEN
          IF mes.code=gmo.newActEntry THEN
            actfunc:=t.functions.GetNode(funclv.GetValue());
          END;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"funcsymb",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(m.taskdata.maintask);
  t.terms.FreeUser(m.taskdata.maintask);
  RETURN ret;
END ProcessFunctions;


BEGIN
  termwind:=NIL;
  definewind:=NIL;
  connectwind:=NIL;
  processwind:=NIL;
  mirrorwind:=NIL;

  derstr:="x";
  pxs:="0";
  COPY(ac.GetString(ac.Auto)^,pys);
(*  autopy:=TRUE;*)
  xstr:="0";
  ystr:="0";
(*  pxstr:="0";
  pystr:="0";*)
END TermsRequesters.

