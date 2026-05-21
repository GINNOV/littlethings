(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
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


MODULE SuperCalcTools6;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       it : IntuitionTools,
       tt : TextTools,
       rt : RequesterTools,
       ag : AmigaGuideTools,
       wm : WindowManager,
       gm : GadgetManager,
       ac : AnalayCatalog,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       s2 : SuperCalcTools2,
       s3 : SuperCalcTools3,
       s4 : SuperCalcTools4,
       s5 : SuperCalcTools5,
       NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

TYPE NewListEl = RECORD(l.NodeDesc)
       node : l.Node;
     END;

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    actwind,
    actterm,
    actfunc     : l.Node;
    plotId    * ,
    defineId  * ,
    connectId * : INTEGER;

PROCEDURE PlotMenu*():BOOLEAN;

VAR wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    ok,ca,
    help,
    windg,
    neww,delw,
    copyw,appw,
    takef,delf : I.GadgetPtr;
    windlist,
    windfunclist,
    funclist,
    actwindfunc,
    actfunc,
    node,node2,
    node3      : l.Node;
    dellist,
    newlist    : l.List;
    bool,ret,
    copywb,
    appwb      : BOOLEAN;
    pos        : INTEGER;

PROCEDURE RefreshWind;

BEGIN
  IF actwind#NIL THEN
    gm.PutGadgetText(windg,actwind(s1.Fenster).name);
    I.RefreshGList(windg,wind,NIL,1);
    bool:=I.ActivateGadget(windg^,wind,NIL);
  END;
END RefreshWind;

PROCEDURE NewWindList;

BEGIN
  gm.SetListViewParams(windlist,20,28,150,84,SHORT(s1.fenster.nbElements()),s1.GetNodeNumber(s1.fenster,actwind),s2.PrintWindow);
  gm.SetCorrectPosition(windlist);
  gm.RefreshListView(windlist);
END NewWindList;

PROCEDURE NewWindFuncList;

BEGIN
  IF actwind#NIL THEN
    gm.SetListViewParams(windfunclist,176,28,200,84,SHORT(actwind(s1.Fenster).funcs.nbElements()),s1.GetNodeNumber(actwind(s1.Fenster).funcs,actwindfunc),s2.PrintWindowFunction);
    gm.SetNoEntryText(windfunclist,ac.GetString(ac.None),ac.GetString(ac.FunctionsEx));
    gm.SetCorrectPosition(windfunclist);
  ELSE
    gm.SetListViewParams(windfunclist,176,28,200,84,0,0,s2.PrintWindowFunction);
    gm.SetNoEntryText(windfunclist,ac.GetString(ac.NoWindow),ac.GetString(ac.SelectedEx));
    gm.SetCorrectPosition(windfunclist);
  END;
  gm.RefreshListView(windfunclist);
END NewWindFuncList;

PROCEDURE NewFuncList;

BEGIN
  gm.SetListViewParams(funclist,382,28,200,84,SHORT(s1.functions.nbElements()),s1.GetNodeNumber(s1.functions,actfunc),s2.PrintFunction);
  gm.SetCorrectPosition(funclist);
  gm.RefreshListView(funclist);
END NewFuncList;

PROCEDURE InitFunc(node:l.Node);

BEGIN
  WITH node: s1.FensterFunc DO
    node.graphs:=l.Create();
  END;
END InitFunc;

BEGIN
  ret:=FALSE;
  IF plotId=-1 THEN
    plotId:=wm.InitWindow(20,10,602,214,ac.GetString(ac.CreateWindows),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,193,100,14,ac.GetString(ac.OK));
(*  ca:=gm.SetBooleanGadget(492,193,100,14,s.ADR("Abbrechen"));*)
  help:=gm.SetBooleanGadget(120,193,100,14,ac.GetString(ac.Help));
  neww:=gm.SetBooleanGadget(20,128,150,14,ac.GetString(ac.NewWindow));
  delw:=gm.SetBooleanGadget(20,143,150,14,ac.GetString(ac.DelWindow));
  copyw:=gm.SetBooleanGadget(20,158,150,14,ac.GetString(ac.CopyWindow));
  INCL(copyw.activation,I.toggleSelect);
  appw:=gm.SetBooleanGadget(20,173,150,14,ac.GetString(ac.AppendWindow));
  INCL(appw.activation,I.toggleSelect);
  takef:=gm.SetBooleanGadget(176,128,200,14,ac.GetString(ac.InsertFunction));
  delf:=gm.SetBooleanGadget(176,143,200,14,ac.GetString(ac.DelFunctionCreateWindows));
  windg:=gm.SetStringGadget(20,112,138,14,255);
  windlist:=gm.SetListView(20,28,150,84,0,0,s2.PrintWindow);
  windfunclist:=gm.SetListView(176,28,200,84,0,0,s2.PrintWindowFunction);
  funclist:=gm.SetListView(382,28,200,84,0,0,s2.PrintFunction);
  gm.EndGadgets;
  wm.SetGadgets(plotId,ok);
  wm.ChangeScreen(plotId,s1.screen);
  wind:=wm.OpenWindow(plotId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

    g.SetAPen(rast,2);
    tt.Print(20,25,ac.GetString(ac.Windows),rast);
    tt.Print(176,25,ac.GetString(ac.SelectedFunctions),rast);
    tt.Print(382,25,ac.GetString(ac.AvailableFunctions),rast);

    it.DrawBorder(rast,14,16,574,174);

    gm.SetCorrectWindow(windlist,wind);
    gm.SetCorrectWindow(windfunclist,wind);
    gm.SetCorrectWindow(funclist,wind);
    gm.SetNoEntryText(windlist,ac.GetString(ac.None),ac.GetString(ac.WindowsEx));
    gm.SetNoEntryText(windfunclist,ac.GetString(ac.None),ac.GetString(ac.FunctionsEx));
    gm.SetNoEntryText(funclist,ac.GetString(ac.None),ac.GetString(ac.FunctionsEx));
(*    gm.RefreshListView(termlist);
    gm.RefreshListView(varlist);*)

    actwind:=s1.GetNode(s1.fenster,gm.ActEl(windlist));
    IF actwind#NIL THEN
      actwindfunc:=s1.GetNode(actwind(s1.Fenster).funcs,gm.ActEl(windfunclist));
      gm.SetDataList(windfunclist,actwind(s1.Fenster).funcs);
    ELSE
      gm.SetDataList(windfunclist,NIL);
    END;
    actfunc:=s1.GetNode(s1.functions,gm.ActEl(funclist));

    NewWindList;
    NewWindFuncList;
    NewFuncList;
    RefreshWind;

    dellist:=l.Create();
    newlist:=l.Create();

    copywb:=FALSE;
    appwb:=FALSE;
    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF actwind#NIL THEN
        gm.GetGadgetText(windg,actwind(s1.Fenster).name);
      END;
      bool:=gm.CheckListView(windlist,class,code,address);
      IF bool THEN
        node:=actwind;
        actwind:=s1.GetNode(s1.fenster,gm.ActEl(windlist));
        IF (node#NIL) AND (actwind#NIL) THEN
          IF (copywb) OR (appwb) THEN
            IF copywb THEN
              gm.DeActivateBool(copyw,wind);
              copywb:=FALSE;
              actwind(s1.Fenster).funcs.Init;
            ELSIF appwb THEN
              gm.DeActivateBool(appw,wind);
              appwb:=FALSE;
            END;
            node2:=node(s1.Fenster).funcs.head;
            WHILE node2#NIL DO
              node:=NIL;
              NEW(node(s1.FensterFunc));
              node(s1.FensterFunc).func:=node2(s1.FensterFunc).func(s1.Function);
              node(s1.FensterFunc).changed:=TRUE;
              actwind(s1.Fenster).funcs.AddTail(node);
              InitFunc(node);
              node2:=node2.next;
            END;
            actwind(s1.Fenster).refresh:=TRUE;
            actwindfunc:=node;
            NewWindFuncList;
          END;
        END;
        actwindfunc:=actwind(s1.Fenster).funcs.head;
        gm.SetDataList(windfunclist,actwind(s1.Fenster).funcs);
        RefreshWind;
        NewWindFuncList;
      END;
      IF actwind#NIL THEN
        bool:=gm.CheckListView(windfunclist,class,code,address);
        IF bool THEN
          actwindfunc:=s1.GetNode(actwind(s1.Fenster).funcs,gm.ActEl(windfunclist));
        END;
      END;
      bool:=gm.CheckListView(funclist,class,code,address);
      IF bool THEN
        actfunc:=s1.GetNode(s1.functions,gm.ActEl(funclist));
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
(*          node:=dellist.RemHead();*)
          node:=dellist.head;
          WHILE node#NIL DO
            WITH node: s1.Fenster DO
              IF node.wind#NIL THEN
                I.ClearMenuStrip(node.wind);
                I.CloseWindow(node.wind);
                node.wind:=NIL;
              END;
            END;
            node2:=newlist.head;
            WHILE node2#NIL DO
              node3:=node2.next;
              IF node2(NewListEl).node=node THEN
                node2.Remove;
              END;
              node2:=node3;
            END;
            actwind:=node;
            node:=node.next;
            s1.NodeToGarbage(actwind);
(*            node:=dellist.RemHead();*)
          END;
          ret:=TRUE;
          EXIT;
        ELSIF address=neww THEN
          node:=NIL;
          NEW(node(s1.Fenster));
          s1.InitNode(node);
          s5.InitFenster(node);
          s1.fenster.AddTail(node);
          actwind:=node;
          actwindfunc:=NIL;
          gm.SetDataList(windfunclist,actwind(s1.Fenster).funcs);
          NewWindList;
          NewWindFuncList;
          RefreshWind;
          node:=NIL;
          NEW(node(NewListEl));
          node(NewListEl).node:=actwind;
          newlist.AddTail(node);
        ELSIF address=delw THEN
          IF actwind#NIL THEN
            node:=actwind.next;
            IF node=NIL THEN
              node:=actwind.prev;
            END;
            actwind.Remove;
            dellist.AddTail(actwind);
            actwind:=node;
            IF actwind#NIL THEN
              actwindfunc:=actwind(s1.Fenster).funcs.head;
              gm.SetDataList(windfunclist,actwind(s1.Fenster).funcs);
            ELSE
              actwindfunc:=NIL;
              gm.SetDataList(windfunclist,NIL);
            END;
            RefreshWind;
            NewWindList;
            NewWindFuncList;
          END;
        ELSIF address=copyw THEN
          copywb:=NOT(copywb);
          IF appwb THEN
            gm.DeActivateBool(appw,wind);
          END;
          appwb:=FALSE;
        ELSIF address=appw THEN
          appwb:=NOT(appwb);
          IF copywb THEN
            gm.DeActivateBool(copyw,wind);
          END;
          copywb:=FALSE;
        ELSIF address=takef THEN
          IF (actfunc#NIL) AND (actwind#NIL) THEN
            node:=NIL;
            NEW(node(s1.FensterFunc));
            node(s1.FensterFunc).func:=actfunc(s1.Function);
            node(s1.FensterFunc).changed:=TRUE;
            actwindfunc:=node;
            actwind(s1.Fenster).funcs.AddTail(node);
            actwind(s1.Fenster).refresh:=TRUE;
            InitFunc(node);
            NewWindFuncList;
          END;
        ELSIF address=delf THEN
          IF (actwindfunc#NIL) AND (actwind#NIL) THEN
            node:=actwindfunc(s1.FensterFunc).graphs.head;
            WHILE node#NIL DO
              DISPOSE(node(s1.FunctionGraph).table);
              node:=node.next;
            END;
            node:=actwindfunc.next;
            IF node=NIL THEN
              node:=actwindfunc.prev;
            END;
            actwindfunc.Remove;
            actwindfunc:=node;
            actwind(s1.Fenster).refresh:=TRUE;
            NewWindFuncList;
          END;
        ELSIF address=windg THEN
          gm.RefreshListView(windlist);
          bool:=I.ActivateGadget(windg^,wind,NIL);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"plotfuncs",wind);
      END;
    END;

    wm.CloseWindow(plotId);
  END;
  wm.FreeGadgets(plotId);
  node:=newlist.head;
  WHILE node#NIL DO
    s1.SendNewObject(node(NewListEl).node);
    node:=node.next;
  END;
  RETURN ret;
END PlotMenu;

PROCEDURE * PrintDefine(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF actterm#NIL THEN
    node:=s1.GetNode(actterm(s1.Term).define,num);
    IF node#NIL THEN
      WITH node: s1.Define DO
        NEW(str);
        COPY(node.string,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str)
      END;
    END;
  END;
END PrintDefine;

PROCEDURE MakeDefine*(node:l.Node):INTEGER;

VAR ret,i,
    pos   : INTEGER;
    node2 : l.Node;
    str1,
    str2,
    str3,
    sign1,
    sign2 : ARRAY 80 OF CHAR;
    real  : LONGREAL;
    root  : f1.NodePtr;

(* Error : 1 Kein Zeichen
           2 Kein Startwert
           3 Kein erster Endwert
           4 Kein zweiter Endwert *)

(* Type  : 00 x>a
           01 x<a
           02 x#a
           03 x=a
           10 a>x>b
           11 a<x<b
           12 a>x<b
           13 a<x>b *)

BEGIN
  ret:=0;
  IF node#NIL THEN
    WITH node: s1.Define DO
      pos:=0;
      i:=0;
      LOOP
        IF (node.string[pos]="#") OR (node.string[pos]="<") OR (node.string[pos]=">") OR (node.string[pos]="=") THEN
          EXIT;
        ELSIF pos>=st.Length(node.string) THEN
          ret:=1;
          EXIT;
        END;
        str1[i]:=node.string[pos];
        INC(pos);
        INC(i);
      END;
      IF pos=0 THEN
        ret:=2;
      END;
      IF ret=0 THEN
        i:=0;
        LOOP
          IF (node.string[pos]#"#") AND (node.string[pos]#"<") AND (node.string[pos]#">") AND (node.string[pos]#"=") THEN
            EXIT;
          ELSIF pos>=st.Length(node.string) THEN
            ret:=3;
            EXIT;
          END;
          sign1[i]:=node.string[pos];
          INC(pos);
          INC(i);
        END;
        IF ret=0 THEN
          i:=0;
          LOOP
            IF (node.string[pos]="#") OR (node.string[pos]="<") OR (node.string[pos]=">") OR (node.string[pos]="=") THEN
              EXIT;
            ELSIF pos>=st.Length(node.string) THEN
              IF i=0 THEN
                ret:=4;
              END;
              EXIT;
            END;
            str2[i]:=node.string[pos];
            INC(pos);
            INC(i);
          END;
          IF ret=0 THEN
            i:=0;
            LOOP
              IF (node.string[pos]#"#") AND (node.string[pos]#"<") AND (node.string[pos]#">") AND (node.string[pos]#"=") THEN
                EXIT;
              ELSIF pos>=st.Length(node.string) THEN
(*                ret:=3;*)
                EXIT;
              END;
              sign2[i]:=node.string[pos];
              INC(pos);
              INC(i);
            END;
            IF ret=0 THEN
              i:=0;
              LOOP
                IF pos>=st.Length(node.string) THEN
                  EXIT;
                END;
                str3[i]:=node.string[pos];
                INC(pos);
                INC(i);
              END;
              IF i=0 THEN
(*                ret:=4;*)
              END;
            END;
          END;
        END;
      END;
      IF ret=0 THEN
        IF CAP(str1[0])="X" THEN
          i:=0;
          root:=f.Parse(str2);
          node.start:=f.CalcLong(root,0,0,i);
          IF sign1[0]=">" THEN
            node.type:=0;
          ELSIF sign1[0]="<" THEN
            IF sign1[1]=">" THEN
              node.type:=2;
            ELSE
              node.type:=1;
            END;
          ELSIF sign1[0]="#" THEN
            node.type:=2;
          ELSIF sign1[0]="=" THEN
            node.type:=3;
          END;
          IF sign1[1]="=" THEN
            node.startequal:=TRUE;
          ELSE
            node.startequal:=FALSE;
          END;
        ELSIF CAP(str2[0])="X" THEN
          IF st.Length(str3)=0 THEN
            i:=0;
            root:=f.Parse(str1);
            node.start:=f.CalcLong(root,0,0,i);
            IF sign1[0]="<" THEN
              IF sign1[1]=">" THEN
                node.type:=2;
              ELSE
                node.type:=0;
              END;
            ELSIF sign1[0]=">" THEN
              node.type:=1;
            ELSIF sign1[0]="#" THEN
              node.type:=2;
            ELSIF sign1[0]="=" THEN
              node.type:=3;
            END;
            IF sign1[1]="=" THEN
              node.startequal:=TRUE;
            ELSE
              node.startequal:=FALSE;
            END;
          ELSE
            i:=0;
            root:=f.Parse(str1);
            node.start:=f.CalcLong(root,0,0,i);
            i:=0;
            root:=f.Parse(str3);
            node.end:=f.CalcLong(root,0,0,i);
            node.type:=10;
            IF (sign1[0]=">") AND (sign2[0]=">") THEN
              real:=node.start;
              node.start:=node.end;
              node.end:=real;
            ELSIF (sign1[0]="<") AND (sign2[0]="<") THEN
            ELSIF (sign1[0]=">") AND (sign2[0]="<") THEN
              node.type:=1;
              IF node.end<node.start THEN
                node.start:=node.end;
              END;
            ELSIF (sign1[0]="<") AND (sign2[0]=">") THEN
              node.type:=0;
              IF node.end>node.start THEN
                node.start:=node.end;
              END;
            END;
            IF sign1[1]="=" THEN
              node.startequal:=TRUE;
            ELSE
              node.startequal:=FALSE;
            END;
            IF sign2[1]="=" THEN
              node.endequal:=TRUE;
            ELSE
              node.endequal:=FALSE;
            END;
          END;
        ELSE
          ret:=4;
        END;
      END;
    END;
  END;
  RETURN ret;
END MakeDefine;

PROCEDURE ChangeDefine*():BOOLEAN;

VAR wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    ok,ca,
    help,
    define,
    newd,deld,
    copyd      : I.GadgetPtr;
    termlist,
    definelist,
    actdefine,
    node,node2,
    node3      : l.Node;
    bool,ret,
    copydb     : BOOLEAN;
    pos        : INTEGER;
    text       : POINTER TO ARRAY OF ARRAY OF CHAR;
    oldstart,
    oldend     : LONGREAL;
    oldstartequal,
    oldendequal: BOOLEAN;
    oldtype    : INTEGER;

PROCEDURE RefreshDefine;

BEGIN
  IF actdefine#NIL THEN
    gm.PutGadgetText(define,actdefine(s1.Define).string);
    I.RefreshGList(define,wind,NIL,1);
    bool:=I.ActivateGadget(define^,wind,NIL);
  END;
END RefreshDefine;

PROCEDURE NewDefineList;

BEGIN
  IF actterm#NIL THEN
    gm.SetListViewParams(definelist,20,28,340,84,SHORT(actterm(s1.Term).define.nbElements()),s1.GetNodeNumber(actterm(s1.Term).define,actdefine),PrintDefine);
  ELSE
    gm.SetListViewParams(definelist,20,28,340,84,0,0,PrintDefine);
  END;
  gm.SetCorrectPosition(definelist);
  gm.RefreshListView(definelist);
END NewDefineList;

PROCEDURE NewTermList;

BEGIN
  gm.SetListViewParams(termlist,366,28,220,84,SHORT(s1.terms.nbElements()),s1.GetNodeNumber(s1.terms,actterm),s2.PrintTerm);
  gm.SetCorrectPosition(termlist);
  gm.RefreshListView(termlist);
END NewTermList;

BEGIN
  ret:=FALSE;
  IF defineId=-1 THEN
    defineId:=wm.InitWindow(20,10,606,199,ac.GetString(ac.ChangeUserDomain),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,178,100,14,ac.GetString(ac.OK));
(*  ca:=gm.SetBooleanGadget(492,178,100,14,s.ADR("Abbrechen"));*)
  help:=gm.SetBooleanGadget(120,178,100,14,ac.GetString(ac.Help));
  newd:=gm.SetBooleanGadget(20,128,340,14,ac.GetString(ac.NewDomain));
  deld:=gm.SetBooleanGadget(20,143,340,14,ac.GetString(ac.DelDomain));
  copyd:=gm.SetBooleanGadget(20,158,340,14,ac.GetString(ac.CopyDomain));
  INCL(copyd.activation,I.toggleSelect);
  define:=gm.SetStringGadget(20,112,328,14,255);
  definelist:=gm.SetListView(20,28,340,84,0,0,PrintDefine);
  termlist:=gm.SetListView(366,28,220,84,0,0,s2.PrintTerm);
  gm.EndGadgets;
  wm.SetGadgets(defineId,ok);
  wm.ChangeScreen(defineId,s1.screen);
  wind:=wm.OpenWindow(defineId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

    g.SetAPen(rast,2);
    tt.Print(20,25,ac.GetString(ac.UserDefinitionDomain),rast);
    tt.Print(366,25,ac.GetString(ac.Functions),rast);

    it.DrawBorder(rast,14,16,578,159);

    gm.SetCorrectWindow(termlist,wind);
    gm.SetCorrectWindow(definelist,wind);
    gm.SetNoEntryText(definelist,ac.GetString(ac.DefinedAt),ac.GetString(ac.AllX));
    gm.SetNoEntryText(termlist,ac.GetString(ac.None),ac.GetString(ac.FunctionsEx));
(*    gm.RefreshListView(termlist);
    gm.RefreshListView(varlist);*)

    actterm:=s1.GetNode(s1.terms,gm.ActEl(termlist));
    IF actterm#NIL THEN
      actdefine:=actterm(s1.Term).define.head;
    END;
    NewDefineList;
    NewTermList;

    RefreshDefine;

    NEW(text,4,50);

    copydb:=FALSE;
    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF actdefine#NIL THEN
        gm.GetGadgetText(define,actdefine(s1.Define).string);
      END;
      bool:=gm.CheckListView(termlist,class,code,address);
      IF bool THEN
        node:=actterm;
        actterm:=s1.GetNode(s1.terms,gm.ActEl(termlist));
        IF actterm#NIL THEN
          actdefine:=actterm(s1.Term).define.head;
        END;
        RefreshDefine;
        NewDefineList;
      END;
      bool:=gm.CheckListView(definelist,class,code,address);
      IF bool THEN
        IF actterm#NIL THEN
          node:=actdefine;
          actdefine:=s1.GetNode(actterm(s1.Term).define,gm.ActEl(definelist));
          IF (node#NIL) AND (actdefine#NIL) THEN
            IF copydb THEN
              COPY(node(s1.Define).string,actdefine(s1.Define).string);
              gm.DeActivateBool(copyd,wind);
              copydb:=FALSE;
              NewDefineList;
            END;
          END;
          RefreshDefine;
        END;
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          i:=0;
          node:=s1.terms.head;
          WHILE node#NIL DO
            node2:=node(s1.Term).define.head;
            WHILE node2#NIL DO
              WITH node2: s1.Define DO
                oldstart:=node2.start;
                oldend:=node2.end;
                oldstartequal:=node2.startequal;
                oldendequal:=node2.endequal;
                oldtype:=node2.type;
                i:=MakeDefine(node2);
                IF (node2.start#oldstart) OR (node2.end#oldend) OR (node2.startequal#oldstartequal) OR (node2.endequal#oldendequal) OR (node2.type#oldtype) THEN
                  node(s1.Term).changed:=TRUE;
                  IF node(s1.Term).basefunc#NIL THEN
                    node(s1.Term).basefunc(s1.Function).changed:=TRUE;
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
            COPY(actdefine(s1.Define).string,text[1]);
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
            NewDefineList;
          END;
        ELSIF address=newd THEN
          IF actterm#NIL THEN
            node:=NIL;
            NEW(node(s1.Define));
            node(s1.Define).string:="";
            node(s1.Define).start:=0;
            node(s1.Define).end:=0;
            node(s1.Define).startequal:=FALSE;
            node(s1.Define).endequal:=FALSE;
            node(s1.Define).type:=0;
            actdefine:=node;
            actterm(s1.Term).define.AddTail(node);
            actterm(s1.Term).changed:=TRUE;
            IF actterm(s1.Term).basefunc#NIL THEN
              actterm(s1.Term).basefunc(s1.Function).changed:=TRUE;
            END;
            RefreshDefine;
            NewDefineList;
          END;
        ELSIF address=deld THEN
          IF actdefine#NIL THEN
            node:=actdefine.next;
            IF node=NIL THEN
              node:=actdefine.prev;
            END;
            actdefine.Remove;
            actdefine:=node;
            actterm(s1.Term).changed:=TRUE;
            IF actterm(s1.Term).basefunc#NIL THEN
              actterm(s1.Term).basefunc(s1.Function).changed:=TRUE;
            END;
            RefreshDefine;
            NewDefineList;
          END;
        ELSIF address=copyd THEN
          copydb:=NOT(copydb);
        ELSIF address=define THEN
          gm.RefreshListView(definelist);
          bool:=I.ActivateGadget(define^,wind,NIL);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"defrange",wind);
      END;
    END;

    wm.CloseWindow(defineId);
  END;
  wm.FreeGadgets(defineId);
  RETURN ret;
END ChangeDefine;

PROCEDURE * PrintFunctionTerm(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF actfunc#NIL THEN
    node:=s1.GetNode(actfunc(s1.Function).terms,num);
    IF node#NIL THEN
      node:=node(s1.FuncTerm).term;
      WITH node: s1.Term DO
        NEW(str);
        COPY(node.string,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str);
      END;
    END;
  END;
END PrintFunctionTerm;

PROCEDURE ConnectTerms*():BOOLEAN;

VAR wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    ok,ca,
    help,
    func,
    newf,delf,
    copyf,
    taket,delt : I.GadgetPtr;
    funclist,
    functermlist,
    termlist,
    actfuncterm,
    actterm,
    node,node2,
    node3      : l.Node;
    bool,ret,
    copyfb     : BOOLEAN;
    pos        : INTEGER;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    gm.PutGadgetText(func,actfunc(s1.Function).name);
    I.RefreshGList(func,wind,NIL,1);
    bool:=I.ActivateGadget(func^,wind,NIL);
  END;
END RefreshFunc;

PROCEDURE NewFuncList;

BEGIN
  gm.SetListViewParams(funclist,20,28,168,84,s1.NumberNotBaseFuncs(),s1.GetFuncNodeNumber(s1.functions,actfunc),s2.PrintNotBaseFunction);
  gm.SetCorrectPosition(funclist);
  gm.RefreshListView(funclist);
END NewFuncList;

PROCEDURE NewFuncTermList;

BEGIN
  IF actfunc#NIL THEN
    gm.SetListViewParams(functermlist,194,28,220,84,SHORT(actfunc(s1.Function).terms.nbElements()),s1.GetNodeNumber(actfunc(s1.Function).terms,actfuncterm),PrintFunctionTerm);
    gm.SetNoEntryText(functermlist,ac.GetString(ac.None),ac.GetString(ac.FunctionsEx));
    gm.SetCorrectPosition(functermlist);
  ELSE
    gm.SetListViewParams(functermlist,194,28,220,84,0,0,PrintFunctionTerm);
    gm.SetNoEntryText(functermlist,ac.GetString(ac.NoConnection),ac.GetString(ac.SelectedEx));
    gm.SetCorrectPosition(functermlist);
  END;
  gm.RefreshListView(functermlist);
END NewFuncTermList;

PROCEDURE NewTermList;

BEGIN
  gm.SetListViewParams(termlist,420,28,200,84,SHORT(s1.terms.nbElements()),s1.GetNodeNumber(s1.terms,actterm),s2.PrintTerm);
  gm.SetCorrectPosition(termlist);
  gm.RefreshListView(termlist);
END NewTermList;

BEGIN
  ret:=FALSE;
  IF connectId=-1 THEN
    connectId:=wm.InitWindow(20,10,640,199,ac.GetString(ac.ConnectFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,178,100,14,ac.GetString(ac.OK));
(*  ca:=gm.SetBooleanGadget(530,178,100,14,s.ADR("Abbrechen"));*)
  help:=gm.SetBooleanGadget(120,178,100,14,ac.GetString(ac.Help));
  newf:=gm.SetBooleanGadget(20,128,168,14,ac.GetString(ac.NewConnection));
  delf:=gm.SetBooleanGadget(20,143,168,14,ac.GetString(ac.DelConnection));
  copyf:=gm.SetBooleanGadget(20,158,168,14,ac.GetString(ac.CopyConnection));
  INCL(copyf.activation,I.toggleSelect);
  taket:=gm.SetBooleanGadget(194,128,220,14,ac.GetString(ac.InsertFunction));
  delt:=gm.SetBooleanGadget(194,143,220,14,ac.GetString(ac.DelFunctionCreateWindows));
  func:=gm.SetStringGadget(20,112,156,14,255);
  funclist:=gm.SetListView(20,28,168,84,0,0,s2.PrintWindow);
  functermlist:=gm.SetListView(194,28,220,84,0,0,s2.PrintWindowFunction);
  termlist:=gm.SetListView(420,28,200,84,0,0,s2.PrintTerm);
  gm.EndGadgets;
  wm.SetGadgets(connectId,ok);
  wm.ChangeScreen(connectId,s1.screen);
  wind:=wm.OpenWindow(connectId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetDrMd(rast,g.jam1);

    g.SetAPen(rast,2);
    tt.Print(20,25,ac.GetString(ac.Connections),rast);
    tt.Print(194,25,ac.GetString(ac.ConnectedFunctions),rast);
    tt.Print(420,25,ac.GetString(ac.AvailableFunctions),rast);

    it.DrawBorder(rast,14,16,612,159);

    gm.SetCorrectWindow(funclist,wind);
    gm.SetCorrectWindow(functermlist,wind);
    gm.SetCorrectWindow(termlist,wind);
    gm.SetNoEntryText(funclist,ac.GetString(ac.None),ac.GetString(ac.Connections));
    gm.SetNoEntryText(functermlist,ac.GetString(ac.None),ac.GetString(ac.Functions));
    gm.SetNoEntryText(termlist,ac.GetString(ac.None),ac.GetString(ac.Functions));
(*    gm.RefreshListView(termlist);
    gm.RefreshListView(varlist);*)

    actfunc:=s1.GetFuncNode(s1.functions,gm.ActEl(funclist));
    IF actfunc#NIL THEN
      actfuncterm:=s1.GetNode(actfunc(s1.Function).terms,gm.ActEl(functermlist));
    END;
    actterm:=s1.GetNode(s1.terms,gm.ActEl(termlist));

    NewFuncList;
    NewFuncTermList;
    NewTermList;
    RefreshFunc;

    copyfb:=FALSE;
    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF actfunc#NIL THEN
        gm.GetGadgetText(func,actfunc(s1.Function).name);
      END;
      bool:=gm.CheckListView(funclist,class,code,address);
      IF bool THEN
        node:=actfunc;
        actfunc:=s1.GetFuncNode(s1.functions,gm.ActEl(funclist));
        IF (node#NIL) AND (actfunc#NIL) THEN
          IF copyfb THEN
            COPY(node(s1.Function).name,actfunc(s1.Function).name);
            actfunc(s1.Function).changed:=TRUE;
            actfunc(s1.Function).isbase:=FALSE;
            actfunc(s1.Function).depend:=l.Create();
            s1.CopyList(node(s1.Function).depend,actfunc(s1.Function).depend);
            actfunc(s1.Function).define:=l.Create();
            s1.CopyList(node(s1.Function).define,actfunc(s1.Function).define);
            actfunc(s1.Function).terms.Init;
            node2:=node(s1.Function).terms.head;
            WHILE node2#NIL DO
              node3:=NIL;
              NEW(node3(s1.FuncTerm));
              node3(s1.FuncTerm).term:=node2(s1.FuncTerm).term;
              actfunc(s1.Function).terms.AddTail(node3);
              node2:=node2.next;
            END;
            gm.DeActivateBool(copyf,wind);
            copyfb:=FALSE;
          END;
        END;
        actfuncterm:=actfunc(s1.Function).terms.head;
        RefreshFunc;
        NewFuncTermList;
      END;
      IF actfunc#NIL THEN
        bool:=gm.CheckListView(functermlist,class,code,address);
        IF bool THEN
          actfuncterm:=s1.GetNode(actfunc(s1.Function).terms,gm.ActEl(functermlist));
        END;
      END;
      bool:=gm.CheckListView(termlist,class,code,address);
      IF bool THEN
        actterm:=s1.GetNode(s1.terms,gm.ActEl(termlist));
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          node:=s1.functions.head;
          WHILE node#NIL DO
            IF NOT(node(s1.Function).isbase) THEN
              s2.RefreshDepends(node);
            END;
            node:=node.next;
          END;
          ret:=TRUE;
          EXIT;
        ELSIF address=newf THEN
          node:=NIL;
          NEW(node(s1.Function));
          COPY(ac.GetString(ac.Connection)^,node(s1.Function).name);
          node(s1.Function).terms:=l.Create();
          node(s1.Function).depend:=l.Create();
          node(s1.Function).define:=l.Create();
          node(s1.Function).isbase:=FALSE;
          actfunc:=node;
          s1.functions.AddTail(actfunc);
          actfuncterm:=NIL;
          NewFuncList;
          NewFuncTermList;
          RefreshFunc;
        ELSIF address=delf THEN
          IF actfunc#NIL THEN
            node:=actfunc;
            LOOP
              node:=node.next;
              IF node=NIL THEN
                EXIT;
              END;
              IF NOT(node(s1.Function).isbase) THEN
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
                IF NOT(node(s1.Function).isbase) THEN
                  EXIT;
                END;
              END;
            END;
            actfunc.Remove;
            actfunc:=node;
            IF actfunc#NIL THEN
              actfuncterm:=actfunc(s1.Function).terms.head;
            ELSE
              actfuncterm:=NIL;
            END;
            RefreshFunc;
            NewFuncList;
            NewFuncTermList;
          END;
        ELSIF address=copyf THEN
          copyfb:=NOT(copyfb);
        ELSIF address=taket THEN
          IF (actfunc#NIL) AND (actterm#NIL) THEN
            node:=NIL;
            NEW(node(s1.FuncTerm));
            node(s1.FuncTerm).term:=actterm;
            actfunc(s1.Function).changed:=TRUE;
            actfuncterm:=node;
            actfunc(s1.Function).terms.AddTail(node);
            NewFuncTermList;
          END;
        ELSIF address=delt THEN
          IF actfuncterm#NIL THEN
            node:=actfuncterm.next;
            IF node=NIL THEN
              node:=actfuncterm.prev;
            END;
            actfuncterm.Remove;
            actfuncterm:=node;
            actfunc(s1.Function).changed:=TRUE;
            NewFuncTermList;
          END;
        ELSIF address=func THEN
          gm.RefreshListView(funclist);
          bool:=I.ActivateGadget(func^,wind,NIL);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"connectfuncs",wind);
      END;
    END;

    wm.CloseWindow(connectId);
  END;
  wm.FreeGadgets(connectId);
  RETURN ret;
END ConnectTerms;

BEGIN
  plotId:=-1;
  defineId:=-1;
  connectId:=-1;
END SuperCalcTools6.























































