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


MODULE Terms;

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
       m  : Multitasking,
       mg : MathGUI,
       fb : FunctionBasics,
       ft : FunctionTrees,
       fd : FunctionDerive,
       fs : FunctionSimplify,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       io,
       NoGuruRq;



VAR terms        * : m.MTList;
    functions    * : m.MTList;
    maxtermchars * : INTEGER;      (* The maximum number of chars a term may
                                      consist of.                            *)



(* Every term contains a list of the variables it depends on. This is for
   setting proper values when discussing a function. *)

TYPE Depend * = POINTER TO DependDesc;
     DependDesc * = RECORD(l.NodeDesc)
       var * : l.Node;
     END;



(* Define is for setting the user domain of definition. *)

TYPE Define * = POINTER TO DefineDesc;
     DefineDesc * = RECORD(l.NodeDesc)
       start      * ,
       end        * : LONGREAL;
       startequal * ,
       endequal   * : BOOLEAN;
       string     * : ARRAY 256 OF CHAR;
       type       * : INTEGER;
     END;

PROCEDURE (define:Define) Init*;

BEGIN
  define.string:="";
  define.start:=0;
  define.end:=0;
  define.startequal:=FALSE;
  define.endequal:=FALSE;
  define.type:=0;
END Init;

PROCEDURE (define:Define) Copy*(dest:l.Node);

BEGIN
  WITH dest: Define DO
    dest.start:=define.start;
    dest.end:=define.end;
    dest.startequal:=define.startequal;
    dest.endequal:=define.endequal;
    COPY(define.string,dest.string);
    dest.type:=define.type;
  END;
  define.Copy^(dest);
END Copy;

PROCEDURE (define:Define) AllocNew*():l.Node;

VAR node : Define;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE * PrintDefine*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF datalist#NIL THEN
    node:=datalist.GetNode(num);
    IF node#NIL THEN
      WITH node: Define DO
        NEW(str);
        COPY(node.string,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str)
      END;
    END;
  END;
END PrintDefine;

PROCEDURE (node:Define) MakeDefine*():INTEGER;

VAR node2 : l.Node;
    str1,
    str2,
    str3,
    sign1,
    sign2 : ARRAY 80 OF CHAR;
    real  : LONGREAL;
    ret,i,
    pos   : INTEGER;

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
(*            ret:=3;*)
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
(*            ret:=4;*)
          END;
        END;
      END;
    END;
  END;
  IF ret=0 THEN
    IF CAP(str1[0])="X" THEN
      i:=0;
      node.start:=ft.ExpressionToReal(str2);
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
        node.start:=ft.ExpressionToReal(str1);
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
        node.start:=ft.ExpressionToReal(str1);
        i:=0;
        node.end:=ft.ExpressionToReal(str3);
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
  RETURN ret;
END MakeDefine;



(* The raw term, entered by the user. *)

TYPE Term * = POINTER TO TermDesc;
     TermDesc * = RECORD(m.LockAbleDesc)
       term     * : POINTER TO ARRAY OF CHAR;
       tree     * : fb.Node;
       depend   * : l.List;
       define   * : l.List;
       basefunc * : l.Node;        (* Should be Function *)
       changed  * : BOOLEAN;
     END;

PROCEDURE (term:Term) Init*;

BEGIN
  NEW(term.term,maxtermchars+1);
  term.depend:=l.Create();
  term.define:=l.Create();
  term.tree:=NIL;
  term.basefunc:=NIL;
  term.changed:=FALSE;
  term.Init^;
END Init;

PROCEDURE (term:Term) Destruct*;

BEGIN
  DISPOSE(term.term);
  term.depend.Destruct;
  term.define.Destruct;
  IF term.tree#NIL THEN
    term.tree.Destruct;
  END;
  term.Destruct^;
END Destruct;

PROCEDURE (term:Term) Copy*(dest:l.Node);

BEGIN
  WITH dest: Term DO
    COPY(term.term^,dest.term^);
    dest.tree:=fb.CopyTree(term.tree);
    term.depend.Copy(dest.depend);
    term.define.Copy(dest.define);
    dest.basefunc:=term.basefunc;
    dest.changed:=term.changed;
  END;
  term.Copy^(dest);
END Copy;

PROCEDURE (term:Term) AllocNew*():l.Node;

VAR node : Term;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE * PrintTerm*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=terms.GetNode(num);
  IF node#NIL THEN
    WITH node: Term DO
      NEW(str);
      COPY(node.term^,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintTerm;

PROCEDURE (node:Term) MakeDepend*;

VAR str,str2 : POINTER TO ARRAY OF CHAR;
    node2,
    newnode  : l.Node;
    long     : LONGINT;
    root     : fb.Node;

PROCEDURE CheckDepend(root:fb.Node);

VAR node2 : l.Node;
    bool  : BOOLEAN;

BEGIN
  IF root#NIL THEN
    IF (root IS fb.TreeObj) AND (root(fb.TreeObj).object IS fb.Variable) THEN
      bool:=FALSE;
      node2:=node(Term).depend.head;
      WHILE node2#NIL DO
        IF node2(Depend).var=root(fb.TreeObj).object THEN
          bool:=TRUE;
        END;
        node2:=node2.next;
      END;
      IF NOT(bool) THEN
        newnode:=NIL;
        NEW(newnode(Depend));
        newnode(Depend).var:=root(fb.TreeObj).object;
        node(Term).depend.AddTail(newnode);
      END;
    END;
    CheckDepend(root.left);
    CheckDepend(root.right);
    IF root IS fb.Operation THEN
      CheckDepend(root(fb.Operation).data);
      CheckDepend(root(fb.Operation).root);
    END;
  END;
END CheckDepend;

BEGIN
  node.depend.Init;
  root:=ft.Parse(node.term^);
  CheckDepend(root);
END MakeDepend;

PROCEDURE (node:Term) Defined*(x:LONGREAL):BOOLEAN;

(* Checks whether the term is defined at the value x. *)

VAR node2 : l.Node;
    ret,
    break : BOOLEAN;

BEGIN
  ret:=FALSE;
  break:=FALSE;
  node2:=node.define.head;
  IF node2=NIL THEN
    ret:=TRUE;
  END;
  WHILE node2#NIL DO
    WITH node2: Define DO
      IF node2.type=0 THEN
        IF (x>node2.start) OR ((x>=node2.start) AND (node2.startequal)) THEN
          ret:=TRUE;
(*        ELSE
          break:=TRUE;*)
        END;
      ELSIF node2.type=1 THEN
        IF (x<node2.start) OR ((x<=node2.start) AND (node2.startequal)) THEN
          ret:=TRUE;
(*        ELSE
          break:=TRUE;*)
        END;
      ELSIF node2.type=2 THEN
        IF x=node2.start THEN
          break:=TRUE;
        ELSE
          ret:=TRUE;
        END;
      ELSIF node2.type=3 THEN
        IF x=node2.start THEN
          ret:=TRUE;
        END;
      ELSIF node2.type=10 THEN
        IF (node2.start<x) AND (x<node2.end) THEN
          ret:=TRUE;
        ELSIF ((node2.start=x) AND (node2.startequal)) OR ((node2.end=x) AND (node2.endequal)) THEN
          ret:=TRUE;
        END;
      END;
    END;
    node2:=node2.next;
  END;
  IF break THEN
    ret:=FALSE;
  END;
  RETURN ret;
END Defined;

PROCEDURE (node:Term) NotDefinedBetween(x1,x2:LONGREAL):BOOLEAN;

(* Checks whether a function is defined or not between x1 and x2. *)

(* ATTENTION: This function is not yet implemented completely! *)

VAR node2   : l.Node;
    ret,
    break   : BOOLEAN;
    x1d,x2d : LONGREAL;
    x1e,x2e : BOOLEAN;

BEGIN
  ret:=TRUE;
  break:=FALSE;
  x1d:=x1;
  x2d:=x2;
  x1e:=FALSE;
  x2e:=FALSE;
  node2:=node.define.head;
  WHILE node2#NIL DO
    WITH node2: Define DO
      IF node2.type=0 THEN
        IF node2.start<=x2d THEN
          x2d:=node2.start;
          IF node2.startequal THEN
            x2e:=TRUE;
          END;
        END;
      ELSIF node2.type=1 THEN
        IF node2.start>=x1d THEN
          x1d:=node2.start;
          IF node2.startequal THEN
            x1e:=TRUE;
          END;
        END;
      ELSIF node2.type=2 THEN
        IF (x1<node2.start) AND (node2.start<x2) THEN
          break:=TRUE;
        END;
      ELSIF node2.type=10 THEN
      END;
    END;
    node2:=node2.next;
  END;
END NotDefinedBetween;



(* Since the terms are collected in their own list, but some terms need to
   be added to a list in a Function object, a FuncTerm object is added to
   the Funciton object's term-list, because a node may never be added to tow
   lists at the same time. *)

TYPE FuncTerm * = POINTER TO FuncTermDesc;
     FuncTermDesc * = RECORD(l.NodeDesc)
       term   * : Term;
       termnum* : INTEGER;
     END;

PROCEDURE (functerm:FuncTerm) Copy*(dest:l.Node);

(* FuncTerm.Copy duplicates the corresponding term automatically. The
   duplicated term is NOT appendet to the terms list. *)

BEGIN
  dest(FuncTerm).term:=functerm.term.CopyNew()(Term);
  dest(FuncTerm).termnum:=functerm.termnum;
  functerm.Copy^(dest);
END Copy;

PROCEDURE (functerm:FuncTerm) AllocNew*():l.Node;

VAR node : FuncTerm;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE * PrintFunctionTerm*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF datalist#NIL THEN
    node:=datalist.GetNode(num);
    IF node#NIL THEN
      node:=node(FuncTerm).term;
      WITH node: Term DO
        NEW(str);
        COPY(node.term^,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str);
      END;
    END;
  END;
END PrintFunctionTerm;



(* Terms are collected in Functions. *)

TYPE Function * = POINTER TO FunctionDesc;
     FunctionDesc * = RECORD(m.LockAbleDesc)
       name   * : ARRAY 256 OF CHAR;
       terms  * : l.List;  (* List of FuncTerms pointing to the terms. *)
       depend * : l.List;
       define * : l.List;
       changed* : BOOLEAN;
       isbase * : BOOLEAN; (* If terms contains only one term, this is set to TRUE. *)
       diffunc* : Function;
     END;

PROCEDURE (func:Function) Init*;

BEGIN
  func.name:="";
  func.terms:=l.Create();
  func.define:=l.Create();
  func.depend:=l.Create();
  func.changed:=FALSE;
  func.isbase:=TRUE;
  func.Init^;
END Init;

PROCEDURE (func:Function) Destruct*;

VAR node : l.Node;

BEGIN
  node:=func.terms.head;
  WHILE node#NIL DO
    node(FuncTerm).term.FreeUser(NIL);
    node:=node.next;
  END;
  IF func.terms#NIL THEN func.terms.Destruct; END;
  IF func.define#NIL THEN func.define.Destruct; END;
  IF func.depend#NIL THEN func.depend.Destruct; END;
  func.Destruct^;
END Destruct;

PROCEDURE (func:Function) Copy*(dest:l.Node);

BEGIN
  WITH dest: Function DO
    COPY(func.name,dest.name);
    func.terms.Copy(dest.terms);
    func.depend.Copy(dest.depend);
    func.define.Copy(dest.define);
    dest.changed:=func.changed;
    dest.isbase:=func.isbase;
    dest.diffunc:=func.diffunc;
  END;
  func.Copy^(dest);
END Copy;

PROCEDURE (func:Function) AllocNew*():l.Node;

VAR node : Function;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE * PrintFunction*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=functions.GetNode(num);
  IF node#NIL THEN
    WITH node: Function DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFunction;

PROCEDURE GetFuncNode*(list:l.List;num:LONGINT):l.Node;

VAR node : l.Node;
    i    : LONGINT;

BEGIN
  node:=list.head;
  i:=-1;
  LOOP
    IF node=NIL THEN
      EXIT;
    END;
    IF NOT(node(Function).isbase) THEN
      INC(i);
    END;
    IF i=num THEN
      EXIT;
    END;
    node:=node.next;
  END;
  RETURN node;
END GetFuncNode;

PROCEDURE NumberNotBaseFuncs*():LONGINT;

VAR node : l.Node;
    i    : LONGINT;

BEGIN
  node:=functions.head;
  i:=0;
  WHILE node#NIL DO
    IF NOT(node(Function).isbase) THEN
      INC(i);
    END;
    node:=node.next;
  END;
  RETURN i;
END NumberNotBaseFuncs;

PROCEDURE GetFuncNodeNumber*(list:l.List;node:l.Node):LONGINT;

VAR node2 : l.Node;
    i     : LONGINT;

BEGIN
  node2:=list.head;
  i:=0;
  WHILE (node2#NIL) AND (node2#node) DO
    IF NOT(node2(Function).isbase) THEN
      INC(i);
    END;
    node2:=node2.next;
  END;
  RETURN i;
END GetFuncNodeNumber;

PROCEDURE * PrintNotBaseFunction*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;
    i    : INTEGER;

BEGIN
(*  node:=s1.functions.head;
  i:=0;
  WHILE (node#NIL) AND (i<num) DO
    IF NOT(node(s1.Function).isbase) THEN
      INC(i);
    END;
    node:=node.next;
  END;*)
  node:=GetFuncNode(functions,num);
  IF node#NIL THEN
    WITH node: Function DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintNotBaseFunction;

PROCEDURE (node:Function) MakeDepend*; (* Was: RefreshDepends(func:Function) *)

(* Creates new depends for node(Function). Does not use the depend-pointers
   of node(Function).trems *)

VAR term,depend,depend2 : l.Node;
    bool                : BOOLEAN;

BEGIN
  node.depend.Init;
  term:=node.terms.head;
  WHILE term#NIL DO
    depend:=term(FuncTerm).term(Term).depend.head;
    WHILE depend#NIL DO
      bool:=TRUE;
      depend2:=node.depend.head;
      WHILE depend2#NIL DO
        IF depend2=depend THEN
          bool:=FALSE;
        END;
        depend2:=depend2.next;
      END;
      IF bool THEN
        NEW(depend2(Depend));
        depend2(Depend).var:=depend(Depend).var;
        node.depend.AddTail(depend2);
      END;
      depend:=depend.next;
    END;
    term:=term.next;
  END;
END MakeDepend;

PROCEDURE (node:Function) Defined*(x:LONGREAL):BOOLEAN;

(* Checks whether the function is defined at the value x. *)

VAR node2 : l.Node;
    ret   : BOOLEAN;

BEGIN
  ret:=FALSE;
  node2:=node.terms.head;
  WHILE node2#NIL DO
    IF node2(FuncTerm).term.Defined(x) THEN
      ret:=TRUE;
    END;
    node2:=node2.next;
  END;
  RETURN ret;
END Defined;

PROCEDURE (node:Function) GetFunctionTerm*(x:LONGREAL):Term;

(* Returns the term which represents the function at the value x. *)

VAR node2,ret : l.Node;

BEGIN
  ret:=NIL;
  node2:=node.terms.head;
  WHILE node2#NIL DO
    IF node2(FuncTerm).term.Defined(x) THEN
      ret:=node2(FuncTerm).term;
    END;
    node2:=node2.next;
  END;
  RETURN ret(Term);
END GetFunctionTerm;

(* Remember to lock function using Function.Lock before calling one of the
   following two methods, or any other task may change the function's tree(s)
   while performing any action on it (them). *)

PROCEDURE (node:Function) GetFunctionValue*(x,xstep:LONGREAL;VAR error:INTEGER):LONGREAL;

VAR node2 : l.Node;
    val   : LONGREAL;
    pos   : INTEGER;

BEGIN
  val:=0;
  node2:=node.GetFunctionTerm(x);
  IF node2#NIL THEN
    WITH node2: Term DO
      IF node2.tree=NIL THEN
        pos:=0;
        node2.tree:=ft.Parse(node2.term^);
      END;
      pos:=0;
      val:=ft.CalcLong(node2.tree,x,xstep,error);
    END;
    IF node.diffunc#NIL THEN
      val:=val-node.diffunc.GetFunctionValue(x,xstep,error);
    END;
  ELSE
    error:=3;
  END;
  RETURN val;
END GetFunctionValue;

PROCEDURE (node:Function) GetFunctionValueShort*(x,xstep:REAL;VAR error:INTEGER):REAL;

VAR node2 : l.Node;
    val   : REAL;
    pos   : INTEGER;

BEGIN
  val:=0;
  node2:=node.GetFunctionTerm(x);
  IF node2#NIL THEN
    WITH node2: Term DO
      IF node2.tree=NIL THEN
        pos:=0;
        node2.tree:=ft.Parse(node2.term^);
      END;
      pos:=0;
      error:=0;
(* $IF FPU *)
      val:=SHORT(ft.CalcLong(node2.tree,x,xstep,error));
(* $ELSE *)
      val:=ft.Calc(node2.tree,x,xstep,error);
(* $END *)
    END;
    IF node.diffunc#NIL THEN
      val:=val-node.diffunc.GetFunctionValueShort(x,xstep,error);
    END;
  ELSE
    error:=3;
  END;
  RETURN val;
END GetFunctionValueShort;

PROCEDURE (func:Function) CreateAllTrees*;

VAR node : l.Node;

BEGIN
  node:=func.terms.head;
  WHILE node#NIL DO
    node(FuncTerm).term(Term).tree:=ft.Parse(node(FuncTerm).term(Term).term^);
    node:=node.next;
  END;
END CreateAllTrees;

PROCEDURE RemoveEmptyFunctions*;

(* Removes functions from functions-list which contain no terms. *)

VAR node,node2 : l.Node;

BEGIN
  node:=functions.head;
  WHILE node#NIL DO
    node2:=node.next;
    IF node(Function).terms.isEmpty() THEN
      node.Destruct;
      node.Remove;
    END;
    node:=node2;
  END;
END RemoveEmptyFunctions;

PROCEDURE (func:Function) AbleitFunction*(ablstring:ARRAY OF CHAR):Function;

VAR func2 : Function;
    node  : l.Node;
    bool  : BOOLEAN;

BEGIN
  func2:=NIL;
  IF func#NIL THEN
    NEW(func2);
    func2.Init;
    func.Copy(func2);
    COPY(ac.GetString(ac.DerivativeOf)^,func2.name);
    st.AppendChar(func2.name," ");
    st.Append(func2.name,func.name);
    func2.diffunc:=NIL;
    func2.CreateAllTrees;
    node:=func2.terms.head;
    WHILE node#NIL DO
      IF node(FuncTerm).term(Term).basefunc=func THEN
        node(FuncTerm).term(Term).basefunc:=func2;
      END;
      bool:=fs.Optimize(node(FuncTerm).term(Term).tree);
      fd.Derive(node(FuncTerm).term(Term).tree,ablstring);
      bool:=fs.Optimize(node(FuncTerm).term(Term).tree);
      ft.TreeToString(node(FuncTerm).term(Term).tree,node(FuncTerm).term(Term).term^);
      node(FuncTerm).term.MakeDepend;
      node:=node.next;
    END;
  END;
  RETURN func2;
END AbleitFunction;

PROCEDURE (func:Function) Lock*(shared:BOOLEAN);

VAR node : l.Node;

BEGIN
  func.Lock^(shared);
  node:=func.terms.head;
  WHILE node#NIL DO
    fb.LockTree(node(FuncTerm).term(Term).tree);
    node:=node.next;
  END;
END Lock;

PROCEDURE (func:Function) UnLock*;

VAR node : l.Node;

BEGIN
  node:=func.terms.head;
  WHILE node#NIL DO
    fb.UnLockTree(node(FuncTerm).term(Term).tree);
    node:=node.next;
  END;
  func.UnLock^;
END UnLock;



(* For simple working with functions with ONE definition domain. *)

PROCEDURE CreateFunc*(string:ARRAY OF CHAR):Function;

VAR node,node2,node3 : l.Node;

BEGIN
  node:=NIL;
  NEW(node(Term));
  node(Term).Init;
  COPY(string,node(Term).term^);

  node2:=NIL;
  NEW(node2(Function));
  node2(Function).Init;
  COPY(string,node2(Function).name);

  node3:=NIL;
  NEW(node3(FuncTerm));
  node3(FuncTerm).term:=node(Term);
  node2(Function).terms.AddTail(node3);
  node(Term).basefunc:=node2;
  node(Term).NewUser(NIL);

  RETURN node2(Function);
END CreateFunc;

PROCEDURE DestructFunc*(func:Function);

VAR functerm,next : l.Node;

BEGIN
  functerm:=func.terms.head;
  WHILE functerm#NIL DO
    next:=functerm.next;
    IF functerm(FuncTerm).term#NIL THEN functerm(FuncTerm).term.Destruct; END;
    functerm.Remove; functerm.Destruct;
    functerm:=next;
  END;
  func.Destruct;
END DestructFunc;

PROCEDURE (func:Function) SetTerm*(string:ARRAY OF CHAR);

VAR term : Term;

BEGIN
  term:=func.terms.head(FuncTerm).term;
  COPY(string,term.term^);
  IF term.tree#NIL THEN term.tree.Destruct; END;
  term.tree:=ft.Parse(term.term^);
END SetTerm;

PROCEDURE (func:Function) GetTerm*():Term;

VAR term : Term;

BEGIN
  term:=func.terms.head(FuncTerm).term;
  RETURN term;
END GetTerm;



BEGIN
  maxtermchars:=2048;

  terms:=NIL; functions:=NIL;
  terms:=m.Create();
  functions:=m.Create();
CLOSE

  io.WriteString("CT1\n");
  IF functions#NIL THEN functions.Destruct; END;
  io.WriteString("CT2\n");
  IF terms#NIL THEN terms.Destruct; END;
  io.WriteString("CT3\n");
END Terms.

