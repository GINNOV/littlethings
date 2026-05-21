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


MODULE DefineRequester;

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

VAR definewind    * : wm.Window;

TYPE DefineObject * = POINTER TO DefineObjectDesc;
     DefineObjectDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

(* Additional Procedures for Define-Object *)

(* General procedures for Define *)

PROCEDURE (defineobj:DefineObject) ChangeDefine*():BOOLEAN;

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
    class      : LONGSET;
    msg        : m.Message;
    text       : POINTER TO ARRAY OF ARRAY OF CHAR;
    strptr     : POINTER TO ARRAY OF CHAR;
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

PROCEDURE CheckDefineError(actdefine:t.Define):BOOLEAN;
(* TRUE if error *)

VAR err : INTEGER;

BEGIN
  err:=actdefine.MakeDefine();
  IF err#0 THEN
    COPY(ac.GetString(ac.ErrorInDomainInput)^,text[0]);
    COPY(actdefine(t.Define).string,text[1]);
    text[2]:="";
    IF err=1 THEN
      COPY(ac.GetString(ac.SymbolsMissing)^,text[3]);
    ELSIF (err=2) OR (err=3) THEN
      COPY(ac.GetString(ac.DomainMustContainAtLeast)^,text[2]);
      COPY(ac.GetString(ac.TwoLimits)^,text[3]);
    ELSIF err=3 THEN
      COPY(ac.GetString(ac.MissingFourth)^,text[3]);
    END;
    bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
    RefreshDefine;
    RETURN TRUE;
  END;
  RETURN FALSE;
END CheckDefineError;

PROCEDURE CheckDefineChanged(actterm:t.Term;actdefine:t.Define):BOOLEAN;
(* Returns TRUE if error! *)

VAR string : POINTER TO ARRAY OF CHAR;
    bool   : BOOLEAN;

BEGIN
  NEW(string,LEN(actdefine.string)+1);
  COPY(actdefine.string,string^);
  definelv.GetString(actdefine.string);
  IF ~tt.Compare(actdefine.string,string^) THEN
    bool:=CheckDefineError(actdefine);
    IF bool THEN
      COPY(string^,actdefine.string);
    ELSE (* OK! *)
      IF actterm.basefunc#NIL THEN
        actterm.basefunc(t.Function).Changed;
      END;
    END;
    DISPOSE(string);
    RETURN bool;
  ELSE
    DISPOSE(string);
    RETURN FALSE;
  END;
END CheckDefineChanged;

BEGIN
  t.terms.NewUser(defineobj,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF definewind=NIL THEN
    definewind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeUserDomain),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=definewind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      definelv:=gmo.SetListView(ac.GetString(ac.UserDefinitionDomain),NIL,t.PrintDefine,0,TRUE,255);
      newdefine:=gmo.SetBooleanGadget(ac.GetString(ac.NewDomain),FALSE);
      deldefine:=gmo.SetBooleanGadget(ac.GetString(ac.DelDomain),FALSE);
      copydefine:=gmo.SetBooleanGadget(ac.GetString(ac.CopyDomain),TRUE);
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

    text:=NIL; NEW(text,4,50);

    copydb:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF defineobj.msgsig IN class THEN
        REPEAT
          msg:=defineobj.ReceiveMsg();
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
              termlv.Refresh;
            ELSIF msg.type=m.msgListChanged THEN
              IF (actterm#NIL) & mem.Garbaged(actterm) THEN (* Node has been removed from list. *)
                termlv.SetValue(0);
                actterm:=t.terms.GetNode(termlv.GetValue());
                IF actterm#NIL THEN
                  actdefine:=actterm(t.Term).define.head;
                  definelv.ChangeListView(actterm(t.Term).define,0);
                END;
              END;
              RefreshDefine;
              termlv.Refresh;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              defineobj.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;

      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            bool:=FALSE;
            IF actdefine#NIL THEN
              bool:=CheckDefineChanged(actterm(t.Term),actdefine(t.Define));
            END;
            IF ~bool THEN (* OK! *)
              ret:=TRUE;
              EXIT;
            END;
(*            i:=0;
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
            END;*)
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
                actterm(t.Term).basefunc(t.Function).Changed;
              END;
              RefreshDefine;
            END;
          ELSIF mes.iAddress=copydefine.gadget THEN
            copydb:=NOT(copydb);
          ELSIF mes.iAddress=definelv.stringgad THEN
            IF actdefine#NIL THEN
              bool:=CheckDefineChanged(actterm(t.Term),actdefine(t.Define));
              definelv.Refresh;
              definelv.Activate;
            END;
          ELSIF mes.iAddress=definelv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              IF actterm#NIL THEN
                bool:=CheckDefineChanged(actterm(t.Term),actdefine(t.Define));
                IF bool THEN (* Error *)
                  definelv.SetValue(actterm(t.Term).define.GetNodeNumber(actdefine));
                  definelv.Refresh;
                  definelv.Activate;
                ELSE
                  node:=actdefine;
                  actdefine:=actterm(t.Term).define.GetNode(definelv.GetValue());
                  IF (node#NIL) AND (actdefine#NIL) THEN
                    NEW(strptr,LEN(actdefine(t.Define).string)+1);
                    IF copydb THEN
                      COPY(node(t.Define).string,strptr^);
                      definelv.SetString(strptr^);
                      bool:=CheckDefineChanged(actterm(t.Term),actdefine(t.Define));
                      IF ~bool THEN RefreshDefine; END;
                      copydb:=FALSE;
                      copydefine.SetSelected(FALSE);
                    ELSE
                      RefreshDefine;
                    END;
                    DISPOSE(strptr);
                  ELSE
                    RefreshDefine;
                  END;
                END;
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
      UNTIL mes.class=LONGSET{};
    END;

    IF text#NIL THEN DISPOSE(text); END;
    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.terms.FreeUser(defineobj);
  RETURN ret;
END ChangeDefine;

PROCEDURE DefineTask*(definetask:bas.ANY):bas.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH definetask: DefineObject DO
    definetask.InitCommunication;
    bool:=definetask.ChangeDefine();

    definetask.chable.RemTask(definetask);
    definetask.ReplyAllMessages;
    definetask.DestructCommunication;
    mem.NodeToGarbage(definetask);
    definetask.chable.FreeUser(definetask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END DefineTask;

PROCEDURE (defineobj:DefineObject) Init*;

BEGIN
  defineobj.chable:=m.taskdata.maintask;

  defineobj.InitTask(DefineTask,defineobj,10000,m.taskdata.requesterpri);
  defineobj.SetID(tid.defineTaskID);
  defineobj.Init^;
END Init;

PROCEDURE (defineobj:DefineObject) Destruct*;

BEGIN
  defineobj.Destruct^;
END Destruct;

BEGIN
  definewind:=NIL;
END DefineRequester.

