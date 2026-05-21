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


MODULE FunctionTrees;

IMPORT d  : Dos,
       e  : Exec,
       fb : FunctionBasics,
       fd : FunctionDerive,
       fs : FunctionSimplify,
       l  : LinkedLists,
       st : Strings,
       tt : TextTools,
       mt : MathTrans,
       ml : MATHLIB,
       mdt: MathIEEEDoubTrans,
       lrc: LongRealConversions,
(*       rio: RealInOut,
       lrio:LongRealInOut,*)
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR root   : fb.Node;
    string : ARRAY 256 OF CHAR;
    pos,
    bcount,
    error  : INTEGER;
    real   : REAL;
    long   : LONGREAL;
    bool   : BOOLEAN;
    ops    : UNTRACED POINTER TO ARRAY OF ARRAY 10 OF CHAR;
    opslen : UNTRACED POINTER TO ARRAY OF INTEGER;

PROCEDURE isNumber*(c:CHAR):BOOLEAN;

BEGIN
  IF c="0" THEN RETURN TRUE;
  ELSIF c="1" THEN RETURN TRUE;
  ELSIF c="2" THEN RETURN TRUE;
  ELSIF c="3" THEN RETURN TRUE;
  ELSIF c="4" THEN RETURN TRUE;
  ELSIF c="5" THEN RETURN TRUE;
  ELSIF c="6" THEN RETURN TRUE;
  ELSIF c="7" THEN RETURN TRUE;
  ELSIF c="8" THEN RETURN TRUE;
  ELSIF c="9" THEN RETURN TRUE;
  ELSE RETURN FALSE;
  END;
END isNumber;

PROCEDURE isSign*(c:CHAR):BOOLEAN;

BEGIN
  IF c="+" THEN RETURN TRUE;
  ELSIF c="-" THEN RETURN TRUE;
  ELSIF c="*" THEN RETURN TRUE;
  ELSIF c="/" THEN RETURN TRUE;
  ELSIF c="^" THEN RETURN TRUE;
  ELSE RETURN FALSE;
  END;
END isSign;

PROCEDURE isOperation*(str:ARRAY OF CHAR;pos:INTEGER;VAR ret,type:INTEGER):BOOLEAN;
(* $CopyArrays- *)

VAR i : INTEGER;

BEGIN
  i:=0;
  type:=-1;
  ret:=101;
  LOOP
    IF i>=LEN(ops^) THEN
      EXIT;
    END;
    ret:=0;
    WHILE ret<opslen[i] DO
      IF CAP(ops[i,ret])#CAP(str[pos+ret]) THEN
        ret:=100;
      END;
      INC(ret);
    END;
    IF ret<100 THEN
      type:=i;
    END;
    INC(i);
  END;
  IF type>=0 THEN
    ret:=opslen[type];
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END isOperation;

PROCEDURE isObject*(string:ARRAY OF CHAR;pos:INTEGER;VAR object:l.Node):BOOLEAN;
(* $CopyArrays- *)

VAR node : l.Node;
    str1,
    str2 : UNTRACED POINTER TO ARRAY OF CHAR;
    len  : INTEGER;

BEGIN
  NEW(str1,st.Length(string)+1);
  COPY(string,str1^);
  st.UpperIntl(str1^);
  object:=NIL;
  node:=fb.objects.head;
  WHILE node#NIL DO
    len:=SHORT(st.Length(node(fb.Object).name^));
    NEW(str2,len+1);
    COPY(node(fb.Object).name^,str2^);
    st.UpperIntl(str2^);
    IF (st.OccursPos(str1^,str2^,pos)=pos) AND ((isSign(str1[pos+len])) OR (str1[pos+len]="(") OR (str1[pos+len]=")") OR (str1[pos+len]=0X)) THEN
      object:=node;
    END;
    DISPOSE(str2);
    node:=node.next;
    IF object#NIL THEN
      node:=NIL;
    END;
  END;
  DISPOSE(str1);
  IF object#NIL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END isObject;

PROCEDURE GetNumber*(string:ARRAY OF CHAR;VAR pos:INTEGER):LONGREAL;
(* $CopyArrays- *)

VAR ub   : POINTER TO ARRAY OF CHAR;
    n    : INTEGER;
    bool,
    neg  : BOOLEAN;
    len  : INTEGER;
    real : LONGREAL;
    long : LONGREAL;

PROCEDURE Zahl(ch:CHAR):BOOLEAN;

VAR bool : BOOLEAN;

BEGIN
  bool:=FALSE;
  IF ch="0" THEN bool:=TRUE;
  ELSIF ch="1" THEN bool:=TRUE;
  ELSIF ch="2" THEN bool:=TRUE;
  ELSIF ch="3" THEN bool:=TRUE;
  ELSIF ch="4" THEN bool:=TRUE;
  ELSIF ch="5" THEN bool:=TRUE;
  ELSIF ch="6" THEN bool:=TRUE;
  ELSIF ch="7" THEN bool:=TRUE;
  ELSIF ch="8" THEN bool:=TRUE;
  ELSIF ch="9" THEN bool:=TRUE;
  ELSIF ch="." THEN bool:=TRUE;
  ELSIF ch="e" THEN bool:=TRUE;
  ELSIF ch="E" THEN bool:=TRUE;
  END;
  RETURN bool;
END Zahl;

BEGIN
  real:=0.0;
  len:=SHORT(st.Length(string));
  IF real=0.0 THEN
    n:=0;
    IF (string[pos]="+") OR (string[pos]="-") THEN
      n:=1;
    END;
    REPEAT
      n:=n+1;
      IF pos+n-1>=0 THEN
        IF ((string[pos+n]="+") OR (string[pos+n]="-")) AND (CAP(string[pos+n-1])="E") THEN
          bool:=TRUE;
        ELSE
          bool:=FALSE;
        END;
      ELSE
        bool:=FALSE;
      END;
    UNTIL (NOT(Zahl(string[pos+n])) AND NOT(bool)) OR (pos+n>=len);
    NEW(ub,n+1);
    ub[0]:=" ";
    n:=0;
    neg:=FALSE;
    IF string[pos]="+" THEN
      n:=1;
      neg:=FALSE;
    ELSIF string[pos]="-" THEN
      n:=1;
      neg:=TRUE;
    END;
    REPEAT
      ub^[n]:=string[pos+n];
      n:=n+1;
      IF pos+n-1>=0 THEN
        IF ((string[pos+n]="+") OR (string[pos+n]="-")) AND (CAP(string[pos+n-1])="E") THEN
          bool:=TRUE;
        ELSE
          bool:=FALSE;
        END;
      ELSE
        bool:=FALSE;
      END;
    UNTIL (NOT(Zahl(string[pos+n])) AND NOT(bool)) OR (pos+n>=len);
    bool:=lrc.StringToReal(ub^,real);
    IF neg THEN
      real:=-real;
    END;
    pos:=pos+n;
  END;
  RETURN real;
END GetNumber;

PROCEDURE GetName*(string:ARRAY OF CHAR;VAR pos:INTEGER;VAR str:ARRAY OF CHAR);
(* $CopyArrays- *)

VAR i : INTEGER;

BEGIN
  i:=0;
  WHILE (string[pos+i]#"(") AND (string[pos+i]#")") AND NOT(isSign(string[pos+i])) AND (string[pos+i]#0X) DO
    str[i]:=string[pos+i];
    INC(i);
    str[i]:=0X;
  END;
  INC(pos,i);
END GetName;

PROCEDURE RawParse*(string:ARRAY OF CHAR;VAR pos:INTEGER;one:BOOLEAN):fb.Node;
(* $CopyArrays- *)

VAR root,actnode,
    node,actpow  : fb.Node;
    object       : l.Node;
    str          : ARRAY 80 OF CHAR;
    real         : LONGREAL;
    len,type     : INTEGER;

BEGIN
  REPEAT
    IF isSign(string[pos]) (*AND NOT((root=NIL) AND (isNumber(string[pos+1])))*) THEN
      IF root=NIL THEN
        NEW(root(fb.Number));
        root(fb.Number).real:=0;
        actnode:=root;
        actpow:=root;
      END;
      IF (string[pos]="+") OR (string[pos]="-") THEN
        NEW(root.parent(fb.Sign));
        root.parent.left:=root;
        root:=root.parent;
        root(fb.Sign).sign:=string[pos];
        actnode:=root;
        actpow:=root;
      ELSIF (string[pos]="*") OR (string[pos]="/") THEN
        node:=NIL;
        NEW(node(fb.Sign));
        node(fb.Sign).sign:=string[pos];
        IF actnode.parent#NIL THEN
          actnode.parent.right:=node;
          node.parent:=actnode.parent;
          actnode.parent:=node;
          node.left:=actnode;
          actnode:=node;
          actpow:=node;
        ELSE
          actnode.parent:=node;
          node.left:=actnode;
          actnode:=node;
          actpow:=node;
          root:=actnode;
        END;
      ELSIF string[pos]="^" THEN
        node:=NIL;
        NEW(node(fb.Sign));
        node(fb.Sign).sign:=string[pos];
        IF actpow.parent#NIL THEN
          actpow.parent.right:=node;
          node.parent:=actpow.parent;
          actpow.parent:=node;
          node.left:=actpow;
          IF (actnode=NIL) OR (actnode=node.left)(*((actnode#NIL) AND NOT(actnode IS fb.Sign))*) THEN
            actnode:=node;
          END;
          actpow:=node;
        ELSE
          actpow.parent:=node;
          node.left:=actpow;
          actnode:=node;
          actpow:=node;
          root:=actnode;
        END;
        INC(pos);
        node(fb.Sign).right:=RawParse(string,pos,TRUE);
        DEC(pos);
      END;
      INC(pos);
(*    ELSIF string[pos]="(" THEN
      INC(pos);
      node:=RawParse(string,pos,FALSE);
      IF actnode#NIL THEN
        actnode.right:=node;
        actnode.right.parent:=actnode;
        actpow:=actnode.right;
        IF (actnode(Sign).sign#"/") AND (actnode(Sign).sign#"^") THEN
          actnode:=actnode.right;
        END;
      ELSE
        root:=node;
        actnode:=root;
        actpow:=root;
      END;
      INC(pos);*)
(*    ELSIF isOperation(string,pos,len,type) THEN
      INC(pos,len);
      node:=NIL;
      NEW(node(Operation));
      node(Operation).type:=type;
      IF (type=5) OR (type=13) THEN
        node(Operation).data:=RawParse(string,pos,TRUE);
      ELSE
        node(Operation).data:=NIL;
      END;
      INC(pos);
      node(Operation).root:=RawParse(string,pos,FALSE);
      IF actnode#NIL THEN
        actnode.right:=node;
        actnode.right.parent:=actnode;
        actpow:=actnode.right;
        IF (actnode(Sign).sign#"/") AND (actnode(Sign).sign#"^") THEN
          actnode:=actnode.right;
        END;
      ELSE
        root:=node;
        actnode:=root;
        actpow:=root;
      END;
      INC(pos);*)
    ELSE
      IF string[pos]="(" THEN
        INC(pos);
        node:=RawParse(string,pos,FALSE);
        INC(pos);
      ELSIF isObject(string,pos,object) THEN
        node:=NIL;
        NEW(node(fb.TreeObj));
        node(fb.TreeObj).object:=object;
        INC(pos,SHORT(st.Length(object(fb.Object).name^)));
      ELSIF (isNumber(string[pos])) OR ((root=NIL) AND ((string[pos]="-") OR (string[pos]="+"))) THEN
        node:=NIL;
        NEW(node(fb.Number));
        real:=GetNumber(string,pos);
        node(fb.Number).real:=real;
      ELSIF isOperation(string,pos,len,type) THEN
        INC(pos,len);
        node:=NIL;
        NEW(node(fb.Operation));
        node(fb.Operation).type:=type;
        IF (type=6) OR (type=16) THEN
          node(fb.Operation).data:=RawParse(string,pos,TRUE);
        ELSE
          node(fb.Operation).data:=NIL;
        END;
        INC(pos);
        node(fb.Operation).root:=RawParse(string,pos,FALSE);
        INC(pos);
      ELSE
        GetName(string,pos,str);
        node:=NIL;
        NEW(node(fb.TreeObj));
        IF (st.Length(str)=1) AND ((CAP(str[0])="X") OR (CAP(str[0])="Y")) THEN
          NEW(node(fb.TreeObj).object(fb.XYObject));
          IF CAP(str[0])="X" THEN
            node(fb.TreeObj).object(fb.XYObject).isX:=TRUE;
          ELSIF CAP(str[0])="Y" THEN
            node(fb.TreeObj).object(fb.XYObject).isY:=TRUE;
          END;
        ELSE
          NEW(node(fb.TreeObj).object(fb.Object));
        END;
        NEW(node(fb.TreeObj).object(fb.Object).name,st.Length(str)+1);
        COPY(str,node(fb.TreeObj).object(fb.Object).name^);
      END;
      IF actnode#NIL THEN
        IF (actpow#NIL) AND (actpow IS fb.Sign) AND (actpow(fb.Sign).sign="^") THEN
          actpow.right:=node;
          actpow.right.parent:=actnode;
        ELSE
          actnode.right:=node;
          actnode.right.parent:=actnode;
          actpow:=actnode.right;
        END;
        IF (actnode(fb.Sign).sign#"/") AND (actnode(fb.Sign).sign#"^") THEN
          actnode:=actnode.right;
        END;
      ELSE
        root:=node;
        actnode:=root;
        actpow:=root;
      END;
    END;
  UNTIL (string[pos]=0X) OR (string[pos]=")") OR (one) OR (pos>=st.Length(string));
  RETURN root;
END RawParse;

PROCEDURE PreParse*(VAR string:ARRAY OF CHAR;VAR recalcfield:ARRAY OF INTEGER);

VAR pos,rpos : INTEGER;

BEGIN
  pos:=0;
  rpos:=0;
  WHILE pos<st.Length(string) DO
    IF pos<LEN(recalcfield) THEN
      recalcfield[pos]:=rpos;
    END;
    IF string[pos]=" " THEN
      st.Delete(string,pos,1);
      DEC(pos);
    ELSIF pos<st.Length(string)-1 THEN
      IF (string[pos]="*") AND (string[pos+1]="*") THEN
        string[pos]:="^";
        st.Delete(string,pos+1,1);
        INC(rpos);
      END;
    END;
    INC(pos);
    INC(rpos);
  END;
  IF st.Length(string)=0 THEN
    string:="0";
  END;
END PreParse;

PROCEDURE RawSyntaxCheck*(string:ARRAY OF CHAR;VAR pos,bcount,error:INTEGER;one:BOOLEAN);
(* $CopyArrays- *)

VAR i,len,type  : INTEGER;
    lastsign,
    exit        : BOOLEAN;
    str         : ARRAY 1000 OF CHAR;

(* Error codes:
     1 : Illegal use of sign
     2 : Error in number format
     3 : Parameter missing, "(" expected
     4 : Sign expected
     5 : Operand expected*)

PROCEDURE CheckNumber(string:ARRAY OF CHAR;VAR pos:INTEGER;VAR error:INTEGER);
(* $CopyArrays- *)

BEGIN
  REPEAT
    INC(pos);
  UNTIL NOT(isNumber(string[pos]));
  IF string[pos]="." THEN
    REPEAT
      INC(pos);
    UNTIL NOT(isNumber(string[pos]));
  END;
  IF CAP(string[pos])="E" THEN
    REPEAT
      INC(pos);
    UNTIL NOT(isNumber(string[pos]));
    IF (string[pos]=".") OR (CAP(string[pos])="E") THEN
      error:=2;
    END;
  END;
END CheckNumber;

BEGIN
  lastsign:=TRUE;
  IF isSign(string[pos]) THEN
    IF (string[pos]#"+") AND (string[pos]#"-") THEN
      error:=1;
    END;
    INC(pos);
  END;
  IF error=0 THEN
    WHILE (pos<st.Length(string)) AND (error=0) AND NOT(exit) DO
      IF string[pos]="(" THEN
        IF NOT((pos>0) AND (string[pos-1]="(")) THEN
          IF NOT(lastsign) THEN
            error:=4;
          END;
        END;
        IF error=0 THEN
          INC(bcount);
          INC(pos);
          RawSyntaxCheck(string,pos,bcount,error,FALSE);
        END;
        lastsign:=FALSE;
      ELSIF string[pos]=")" THEN
        IF lastsign THEN
          error:=5;
        END;
        exit:=TRUE;
        DEC(bcount);
        DEC(pos);
        lastsign:=FALSE;
      ELSIF isSign(string[pos]) THEN
        IF lastsign THEN
          error:=1;
        END;
        lastsign:=TRUE;
      ELSIF lastsign THEN
        lastsign:=FALSE;
        IF isNumber(string[pos]) THEN
          CheckNumber(string,pos,error);
          DEC(pos);
        ELSIF isOperation(string,pos,len,type) THEN
          INC(pos,len);
          IF (type=6) OR (type=16) THEN
            IF isSign(string[pos]) THEN
              error:=1;
            ELSIF string[pos]="(" THEN
              INC(pos);
              INC(bcount);
              RawSyntaxCheck(string,pos,bcount,error,FALSE);
              INC(pos);
            ELSIF isOperation(string,pos,len,type) THEN
              RawSyntaxCheck(string,pos,bcount,error,TRUE);
              INC(pos);
            ELSIF isNumber(string[pos]) THEN
              CheckNumber(string,pos,error);
            ELSE
              GetName(string,pos,str);
            END;
          END;
          IF string[pos]#"(" THEN
            error:=3;
          ELSE
            INC(bcount);
            INC(pos);
            RawSyntaxCheck(string,pos,bcount,error,FALSE);
          END;
        ELSE
          GetName(string,pos,str);
          DEC(pos);
        END;
      ELSIF NOT(lastsign) THEN
        error:=4;
      END;
      INC(pos);
(*      IF one THEN
        exit:=TRUE;
      END;*)
    END;
  END;
  IF lastsign THEN
    error:=5;
  END;
  IF error#0 THEN
    DEC(pos);
    IF pos<0 THEN
      pos:=0;
    END;
  END;
END RawSyntaxCheck;

PROCEDURE SyntaxCheck*(string:ARRAY OF CHAR;VAR pos,bcount,error:INTEGER);
(* $CopyArrays *)

VAR recalcfield : ARRAY 1000 OF INTEGER;

BEGIN
  pos:=0;
  bcount:=0;
  error:=0;
  PreParse(string,recalcfield);
  RawSyntaxCheck(string,pos,bcount,error,FALSE);
  pos:=recalcfield[pos];
END SyntaxCheck;

PROCEDURE Parse*(string:ARRAY OF CHAR):fb.Node;
(* CopyArrays *)

VAR pos         : INTEGER;
    recalcfield : ARRAY 2 OF INTEGER;

BEGIN
  pos:=0;
  PreParse(string,recalcfield);
  RETURN RawParse(string,pos,FALSE);
END Parse;

PROCEDURE GetNextValue(VAR r:LONGREAL);

BEGIN
  IF r>0.1 THEN r:=0.1;
  ELSIF r>0.01 THEN r:=0.01;
  ELSIF r>0.001 THEN r:=0.001;
  ELSIF r>0.0001 THEN r:=0.0001;
  ELSIF r>0.00001 THEN r:=0.00001;
  ELSIF r>0.000001 THEN r:=0.000001;
  ELSIF r>0.0000001 THEN r:=0.0000001;
  ELSIF r>0.00000001 THEN r:=0.00000001;
  END;
END GetNextValue;

PROCEDURE GetNextValueShort(VAR r:REAL);

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
END GetNextValueShort;

PROCEDURE Calc*(root:fb.Node;x,xstep:REAL;VAR error:INTEGER):REAL;

VAR left,right : REAL;
    node       : fb.Node;

PROCEDURE isNull(root:fb.Node;x1,xstep:REAL;VAR error:INTEGER);

VAR y1,y2,y : REAL;
    err     : INTEGER;
    ret     : INTEGER;
    bool    : BOOLEAN;

PROCEDURE SearchNull(root:fb.Node;x:REAL):BOOLEAN;

VAR addx,
    y,oldy,
    oldy2,
    minx,
    maxx   : REAL;
    error  : INTEGER;
    isone  : BOOLEAN;

BEGIN
  isone:=TRUE;
  minx:=x-5*xstep;
  maxx:=x+5*xstep;
  x:=x+xstep;
  addx:=xstep;
  GetNextValueShort(addx);
  error:=0;
  oldy:=Calc(root,x+addx,addx,error);
  y:=Calc(root,x,addx,error);
  REPEAT
    oldy2:=oldy;
    oldy:=y;
    x:=x-addx;
    y:=Calc(root,x,addx,error);
  UNTIL ((y>oldy) AND (oldy2>=oldy)) OR ((y<oldy) AND (oldy2<=oldy)) OR (y=0) OR (x<minx);
  IF (error#0) OR (x<minx) THEN
    isone:=FALSE;
  END;
  IF isone THEN
    REPEAT
      x:=x-addx;
      GetNextValueShort(addx);
      error:=0;
      oldy:=Calc(root,x-addx,addx,error);
      y:=Calc(root,x,addx,error);
      LOOP
        oldy2:=oldy;
        oldy:=y;
        x:=x+addx;
        y:=Calc(root,x,addx,error);
        IF y>=0 THEN
          IF ((y>=oldy) AND (oldy2>oldy)) OR ((y<=oldy) AND (oldy2<oldy)) OR (y=0) OR (x>maxx) THEN
            x:=x-addx;
            EXIT;
          END;
        ELSE
          IF ((-(y)<=-(oldy)) AND (-(oldy2)<-(oldy))) OR ((-(y)>=-(oldy)) AND (-(oldy2)>-(oldy))) OR (y=0) OR (x>maxx) THEN
            x:=x-addx;
            EXIT;
          END;
        END;
      END;
      IF (error#0) OR (x>maxx) THEN
        isone:=FALSE;
      END;
(*      IF addx>0.00001 THEN
        x:=x-addx;
      END;*)
    UNTIL (addx<=0.00001) OR NOT(isone);
  END;
  error:=0;
  y:=Calc(root,x,xstep,error);
  IF (error#0) OR NOT((y>-0.00001) AND (y<0.00001)) THEN
    isone:=FALSE;
  END;
  RETURN isone;
END SearchNull;

BEGIN
  ret:=0;
  y1:=Calc(root,x1,xstep,err);
  IF err=0 THEN
    y2:=Calc(root,x1+xstep,-xstep,err);
    IF err=0 THEN
      IF (y1=0) THEN
        err:=1;
      ELSIF ((y1<0) AND (y2>0)) OR ((y1>0) AND (y2<0)) THEN
        err:=2;
      ELSIF (y1<0.5) AND (y1>-0.5) THEN
        y:=Calc(root,x1-xstep,xstep,err);
        IF err=0 THEN
          IF y>=0 THEN
            IF ((y<y1) AND (y2<=y1)) OR ((y>y1) AND (y2>=y1)) THEN
              bool:=SearchNull(root,x1);
              IF bool THEN
                err:=2;
              END;
            END;
          ELSE
            y:=-y;
            y1:=-y1;
            y2:=-y2;
            IF ((y>y1) AND (y2>=y1)) OR ((y<y1) AND (y2<=y1)) THEN
              bool:=SearchNull(root,x1);
              IF bool THEN
                err:=2;
              END;
            END;
          END;
        END;
      END;
    END;
  END;
  IF err#0 THEN
    error:=err;
  END;
END isNull;

BEGIN
  IF root IS fb.Number THEN
    RETURN SHORT(root(fb.Number).real);
  ELSIF root IS fb.TreeObj THEN
    IF root(fb.TreeObj).object IS fb.Constant THEN
      RETURN SHORT(root(fb.TreeObj).object(fb.Constant).real);
    ELSIF root(fb.TreeObj).object IS fb.Variable THEN
      RETURN SHORT(root(fb.TreeObj).object(fb.Variable).real);
    ELSIF root(fb.TreeObj).object IS fb.XYObject THEN
      IF root(fb.TreeObj).object(fb.XYObject).isX THEN
        RETURN x;
      END;
    END;
  ELSIF root IS fb.Sign THEN
    WITH root: fb.Sign DO
      left:=Calc(root.left,x,xstep,error);
      right:=Calc(root.right,x,xstep,error);
      IF root.sign="+" THEN
        RETURN left+right;
      ELSIF root.sign="-" THEN
        RETURN left-right;
      ELSIF root.sign="*" THEN
        RETURN left*right;
      ELSIF root.sign="/" THEN
        IF (right>-0.5) AND (right<0.5) THEN
          isNull(root.right,x,xstep,error);
        END;
        IF right#0 THEN
          RETURN left/right;
        END;
      ELSIF root.sign="^" THEN
        RETURN fb.Pow(right,left,error);
      END;
    END;
  ELSIF root IS fb.Operation THEN
    WITH root: fb.Operation DO
      IF root.data#NIL THEN
        left:=Calc(root.data,x,xstep,error);
      END;
      right:=Calc(root.root,x,xstep,error);
      IF root.type=0 THEN
        right:=mt.Sin(right);
      ELSIF root.type=1 THEN
        right:=mt.Cos(right);
      ELSIF root.type=2 THEN
        NEW(node(fb.Operation));
        node(fb.Operation).type:=1;
        node(fb.Operation).root:=root.root;
        isNull(node,x,xstep,error);
        IF error=0 THEN
          right:=mt.Tan(right);
        END;
      ELSIF root.type=3 THEN
        NEW(node(fb.Operation));
        node(fb.Operation).type:=0;
        node(fb.Operation).root:=root.root;
        isNull(node,x,xstep,error);
        IF error=0 THEN
          right:=mt.Cos(right)/mt.Sin(right);
        END;
      ELSIF root.type=4 THEN
        right:=mt.Exp(right);
      ELSIF root.type=5 THEN
        IF right>=0 THEN
          right:=mt.Sqrt(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=6 THEN
        right:=fb.Nrt(right,left,error);
      ELSIF root.type=7 THEN
        right:=mt.Sinh(right);
      ELSIF root.type=8 THEN
        right:=mt.Cosh(right);
      ELSIF root.type=9 THEN
        right:=mt.Tanh(right);
      ELSIF root.type=11 THEN
        IF (right>=-1) AND (right<=1) THEN
          right:=mt.Asin(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=12 THEN
        IF (right>=-1) AND (right<=1) THEN
          right:=mt.Acos(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=13 THEN
        right:=mt.Atan(right);
      ELSIF root.type=15 THEN
        IF (right>=-1) AND (right<=1) THEN
          right:=mt.Log((1+right)/(1-right))/2
        ELSE
          error:=3;
        END;
      ELSIF root.type=16 THEN
        IF (right>0) AND (left>0) AND (left#1) AND (mt.Log(left)#0) THEN
          right:=mt.Log(right)/mt.Log(left);
        ELSE
          error:=3;
        END;
      ELSIF root.type=17 THEN
        IF right>0 THEN
          right:=mt.Log(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=18 THEN
        right:=ABS(right);
      END;
      RETURN right;
    END;
  END;
  RETURN 0;
END Calc;

PROCEDURE CalcLong*(root:fb.Node;x,xstep:LONGREAL;VAR error:INTEGER):LONGREAL;

VAR left,right : LONGREAL;
    node       : fb.Node;

PROCEDURE isNull(root:fb.Node;x1,xstep:LONGREAL;VAR error:INTEGER);

VAR y1,y2,y : LONGREAL;
    err     : INTEGER;
    ret     : INTEGER;
    bool    : BOOLEAN;

PROCEDURE SearchNull(root:fb.Node;x:LONGREAL):BOOLEAN;

VAR addx,
    y,oldy,
    oldy2,
    minx,
    maxx   : LONGREAL;
    error  : INTEGER;
    isone  : BOOLEAN;

BEGIN
  isone:=TRUE;
  minx:=x-5*xstep;
  maxx:=x+5*xstep;
  x:=x+xstep;
  addx:=xstep;
  GetNextValue(addx);
  error:=0;
  oldy:=CalcLong(root,x+addx,addx,error);
  y:=CalcLong(root,x,addx,error);
  REPEAT
    oldy2:=oldy;
    oldy:=y;
    x:=x-addx;
    y:=CalcLong(root,x,addx,error);
  UNTIL ((y>oldy) AND (oldy2>=oldy)) OR ((y<oldy) AND (oldy2<=oldy)) OR (y=0) OR (x<minx);
  IF (error#0) OR (x<minx) THEN
    isone:=FALSE;
  END;
  IF isone THEN
    REPEAT
      x:=x-addx;
      GetNextValue(addx);
      error:=0;
      oldy:=CalcLong(root,x-addx,addx,error);
      y:=CalcLong(root,x,addx,error);
      LOOP
        oldy2:=oldy;
        oldy:=y;
        x:=x+addx;
        y:=CalcLong(root,x,addx,error);
        IF y>=0 THEN
          IF ((y>=oldy) AND (oldy2>oldy)) OR ((y<=oldy) AND (oldy2<oldy)) OR (y=0) OR (x>maxx) THEN
            x:=x-addx;
            EXIT;
          END;
        ELSE
          IF ((-(y)<=-(oldy)) AND (-(oldy2)<-(oldy))) OR ((-(y)>=-(oldy)) AND (-(oldy2)>-(oldy))) OR (y=0) OR (x>maxx) THEN
            x:=x-addx;
            EXIT;
          END;
        END;
      END;
      IF (error#0) OR (x>maxx) THEN
        isone:=FALSE;
      END;
(*      IF addx>0.0000001 THEN
        x:=x-addx;
      END;*)
    UNTIL (addx<=0.0000001) OR NOT(isone);
  END;
  error:=0;
  y:=CalcLong(root,x,xstep,error);
  IF (error#0) OR NOT((y>-0.00001) AND (y<0.00001)) THEN
    isone:=FALSE;
  END;
  RETURN isone;
END SearchNull;

BEGIN
  ret:=0;
  y1:=CalcLong(root,x1,xstep,err);
  IF err=0 THEN
    y2:=CalcLong(root,x1+xstep,-xstep,err);
    IF err=0 THEN
      IF (y1=0) THEN
        err:=1;
      ELSIF ((y1<0) AND (y2>0)) OR ((y1>0) AND (y2<0)) THEN
        err:=2;
      ELSIF (y1<0.5) AND (y1>-0.5) THEN
        y:=CalcLong(root,x1-xstep,xstep,err);
        IF err=0 THEN
          IF y>=0 THEN
            IF ((y<y1) AND (y2<=y1)) OR ((y>y1) AND (y2>=y1)) THEN
              bool:=SearchNull(root,x1);
              IF bool THEN
                err:=2;
              END;
            END;
          ELSE
            y:=-y;
            y1:=-y1;
            y2:=-y2;
            IF ((y>y1) AND (y2>=y1)) OR ((y<y1) AND (y2<=y1)) THEN
              bool:=SearchNull(root,x1);
              IF bool THEN
                err:=2;
              END;
            END;
          END;
        END;
      END;
    END;
  END;
  IF err#0 THEN
    error:=err;
  END;
END isNull;

BEGIN
  IF root IS fb.Number THEN
    RETURN root(fb.Number).real;
  ELSIF root IS fb.TreeObj THEN
    IF root(fb.TreeObj).object IS fb.Constant THEN
      RETURN root(fb.TreeObj).object(fb.Constant).real;
    ELSIF root(fb.TreeObj).object IS fb.Variable THEN
      RETURN root(fb.TreeObj).object(fb.Variable).real;
    ELSIF root(fb.TreeObj).object IS fb.XYObject THEN
      IF root(fb.TreeObj).object(fb.XYObject).isX THEN
        RETURN x;
      END;
    END;
  ELSIF root IS fb.Sign THEN
    WITH root: fb.Sign DO
      left:=CalcLong(root.left,x,xstep,error);
      right:=CalcLong(root.right,x,xstep,error);
      IF root.sign="+" THEN
        RETURN left+right;
      ELSIF root.sign="-" THEN
        RETURN left-right;
      ELSIF root.sign="*" THEN
        RETURN left*right;
      ELSIF root.sign="/" THEN
        IF (right>-0.5) AND (right<0.5) THEN
          isNull(root.right,x,xstep,error);
        END;
        IF right#0 THEN
          RETURN left/right;
        END;
      ELSIF root.sign="^" THEN
        RETURN fb.PowLong(right,left,error);
      END;
    END;
  ELSIF root IS fb.Operation THEN
    WITH root: fb.Operation DO
      IF root.data#NIL THEN
        left:=CalcLong(root.data,x,xstep,error);
      END;
      right:=CalcLong(root.root,x,xstep,error);
      IF root.type=0 THEN
        right:=ml.SIN(right);
      ELSIF root.type=1 THEN
        right:=ml.COS(right);
      ELSIF root.type=2 THEN
        NEW(node(fb.Operation));
        node(fb.Operation).type:=1;
        node(fb.Operation).root:=root.root;
        isNull(node,x,xstep,error);
        IF error=0 THEN
          right:=ml.TAN(right);
        END;
      ELSIF root.type=3 THEN
        NEW(node(fb.Operation));
        node(fb.Operation).type:=0;
        node(fb.Operation).root:=root.root;
        isNull(node,x,xstep,error);
        IF error=0 THEN
          right:=ml.COS(right)/ml.SIN(right);
        END;
      ELSIF root.type=4 THEN
        right:=ml.ETOX(right);
      ELSIF root.type=5 THEN
        IF right>=0 THEN
          right:=ml.SQRT(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=6 THEN
        right:=fb.NrtLong(right,left,error);
      ELSIF root.type=7 THEN
        right:=ml.SINH(right);
      ELSIF root.type=8 THEN
        right:=ml.COSH(right);
      ELSIF root.type=9 THEN
        right:=ml.TANH(right);
      ELSIF root.type=11 THEN
        IF (right>=-1) AND (right<=1) THEN
          right:=ml.ASIN(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=12 THEN
        IF (right>=-1) AND (right<=1) THEN
          right:=ml.ACOS(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=13 THEN
        right:=ml.ATAN(right);
      ELSIF root.type=15 THEN
        IF (right>=-1) AND (right<=1) THEN
          right:=ml.ATANH(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=16 THEN
        IF (right>0) AND (left>0) AND (left#1) AND (ml.LOGN(left)#0) THEN
          right:=ml.LOGN(right)/ml.LOGN(left);
        ELSE
          error:=3;
        END;
      ELSIF root.type=17 THEN
        IF right>0 THEN
          right:=ml.LOGN(right);
        ELSE
          error:=3;
        END;
      ELSIF root.type=18 THEN
        right:=ABS(right);
      END;
      RETURN right;
    END;
  END;
  RETURN 0;
END CalcLong;

PROCEDURE SecondLower*(sign1,sign2:fb.Node):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  WITH sign1: fb.Sign DO
    WITH sign2: fb.Sign DO
      IF sign2.sign#"^" THEN
        IF sign1.sign="^" THEN
          ret:=TRUE;
        END;
        IF sign2.sign#"/" THEN
          IF sign1.sign="/" THEN
            ret:=TRUE;
          END;
          IF sign2.sign#"*" THEN
            IF sign1.sign="*" THEN
              ret:=TRUE;
            END;
            IF sign2.sign#"-" THEN
              IF sign1.sign="-" THEN
                ret:=TRUE;
              END;
            END;
          END;
        END;
      END;
    END;
  END;
  RETURN ret;
END SecondLower;

PROCEDURE TreeToString*(root:fb.Node;VAR string:ARRAY OF CHAR);

VAR str  : UNTRACED POINTER TO ARRAY OF CHAR;
    str2 : ARRAY 20 OF CHAR;
    bool : BOOLEAN;

PROCEDURE AppendNode(last,node:fb.Node);

PROCEDURE SetBracket(bracket:CHAR);

BEGIN
  IF last#NIL THEN
    IF last IS fb.Sign THEN
      IF node IS fb.Number THEN
        IF node(fb.Number).real<0 THEN
          tt.AppendChar(str^,bracket);
        END;
      ELSIF (node IS fb.Sign) AND (last IS fb.Sign) THEN
        IF (SecondLower(last,node)) OR ((node(fb.Sign).sign=node(fb.Sign).sign) AND (last.right=node) AND ((node(fb.Sign).sign="-") OR (node(fb.Sign).sign="/") OR (node(fb.Sign).sign="^"))) (*((last(Sign).sign="*") OR (last(Sign).sign="/")) AND ((node(Sign).sign="+") OR (node(Sign).sign="-")) OR ((last(Sign).sign="^") AND (node(Sign).sign#"^"))*) THEN
          tt.AppendChar(str^,bracket);
        END;
      END;
    END;
  END;
END SetBracket;

BEGIN
  IF node#NIL THEN
    SetBracket("(");
    AppendNode(node,node.left);
    IF node IS fb.Number THEN
      bool:=lrc.RealToString(node(fb.Number).real,str2,7,7,node(fb.Number).exp);
      tt.Clear(str2);
      tt.Append(str^,str2);
    ELSIF node IS fb.TreeObj THEN
      tt.Append(str^,node(fb.TreeObj).object(fb.Object).name^);
    ELSIF node IS fb.Sign THEN
      tt.AppendChar(str^,node(fb.Sign).sign);
    ELSIF node IS fb.Operation THEN
      WITH node: fb.Operation DO
        tt.Append(str^,ops[node.type]);
        IF node.data#NIL THEN
          IF (node.data IS fb.Sign) OR (node.data IS fb.Operation) THEN
            tt.AppendChar(str^,"(");
          END;
          AppendNode(NIL,node.data);
          IF (node.data IS fb.Sign) OR (node.data IS fb.Operation) THEN
            tt.AppendChar(str^,")");
          END;
        END;
        tt.AppendChar(str^,"(");
        AppendNode(NIL,node.root);
        tt.AppendChar(str^,")");
      END;
    END;
    AppendNode(node,node.right);
    SetBracket(")");
  END;
END AppendNode;

BEGIN
  NEW(str,LEN(string));
  AppendNode(NIL,root);
  COPY(str^,string);
  DISPOSE(str);
END TreeToString;

PROCEDURE ExpressionToReal*(string:ARRAY OF CHAR):LONGREAL;
(* $CopyArrays- *)

VAR root  : fb.Node;
    error : INTEGER;

BEGIN
  root:=Parse(string);
  RETURN Calc(root,0,0,error);
END ExpressionToReal;

PROCEDURE AddStringConstant*(name,comment:ARRAY OF CHAR;realstr:ARRAY OF CHAR;internal:BOOLEAN);
(* $CopyArrays- *)

VAR node : l.Node;
    bool : BOOLEAN;

BEGIN
  NEW(node(fb.Constant));
  WITH node: fb.Constant DO
    NEW(node.name,st.Length(name)+1);
    COPY(name,node.name^);
    NEW(node.comment,st.Length(comment)+1);
    COPY(comment,node.comment^);
    node.real:=ExpressionToReal(realstr);
    IF (node.real<0.0001) OR (node.real>=10000000) THEN
      bool:=TRUE;
    ELSE
      bool:=FALSE;
    END;
    COPY(realstr,node.realstr);
    node.isInternal:=internal;
  END;
  fb.objects.AddTail(node);
END AddStringConstant;

BEGIN
(*  AddStringConstant("pi","Kreiszahl",fb.PIs,TRUE);
  AddStringConstant("e","Eulersche Zahl",fb.Es,TRUE);
  AddStringConstant("h","Planksches Wirkungsquantum",fb.Hs,TRUE);
  AddStringConstant("c","Vakuumlichtgeschwindigkeit",fb.Cs,TRUE);
  AddStringConstant("el","Elementarladung",fb.ELs,TRUE);
  AddStringConstant("me","Elektronenmasse",fb.MEs,TRUE);
  AddStringConstant("mn","Neutronenmasse",fb.MNs,TRUE);
  AddStringConstant("mp","Protonenmasse",fb.MPs,TRUE);
  AddStringConstant("u","Atomare Masseneinheit",fb.Us,TRUE);
  AddStringConstant("v0","Molvolumen idealer Gase bei NB",fb.Vs,TRUE);
  AddStringConstant("n","Avogadrosche Konstante",fb.Ns,TRUE);
  AddStringConstant("f","Gravitationskonstante",fb.Fs,TRUE);
  AddStringConstant("r0","Gaskonstante",fb.Rs,TRUE);
  AddStringConstant("p0","Physikalischer Normdruck",fb.Ps,TRUE);
  AddStringConstant("k","Boltzmannsche Konstante",fb.Ks,TRUE);
  AddStringConstant("e0","Elektrische Feldkonstante",fb.E0s,TRUE);
  AddStringConstant("m0","Magnetische Feldkonstante",fb.M0s,TRUE);*)

  NEW(ops,19);
  NEW(opslen,19);
  ops[0]:="sin";  opslen[0]:=3;
  ops[1]:="cos";  opslen[1]:=3;
  ops[2]:="tan";  opslen[2]:=3;
  ops[3]:="cot";  opslen[3]:=3;
  ops[4]:="exp";  opslen[4]:=3;
  ops[5]:="sqrt"; opslen[5]:=4;
  ops[6]:="root"; opslen[6]:=4;
  ops[7]:="sinh";  opslen[7]:=4;
  ops[8]:="cosh";  opslen[8]:=4;
  ops[9]:="tanh";  opslen[9]:=4;
  ops[10]:="coth";  opslen[10]:=4;
  ops[11]:="asin";  opslen[11]:=4;
  ops[12]:="acos";  opslen[12]:=4;
  ops[13]:="atan";  opslen[13]:=4;
  ops[14]:="acot";  opslen[14]:=4;
  ops[15]:="atanh";  opslen[15]:=5;
  ops[16]:="log";  opslen[16]:=3;
  ops[17]:="ln";  opslen[17]:=2;
  ops[18]:="abs";  opslen[18]:=3;

(*  io.WriteString("Funktions-Parser © 1994-1995 Marc Necker\nNur für Proxity-Beta-Tester\n");
  LOOP
    io.WriteString("in>");
    io.ReadString(string);
    IF string[0]=0X THEN
      EXIT;
    END;
    bcount:=0;
    error:=0;
    SyntaxCheck(string,pos,bcount,error);
    IF error>0 THEN
      io.WriteString(string);
      io.WriteLn;
      WHILE pos>0 DO
        DEC(pos);
        io.Write(" ");
      END;
      io.WriteString("^\n");
      IF error=1 THEN
        io.WriteString("Unzulässige Benutzung eines Rechenzeichens\n");
      ELSIF error=2 THEN
        io.WriteString("Fehler im Zahlenformat\n");
      ELSIF error=3 THEN
        io.WriteString("'(' erwartet\n");
      ELSIF error=4 THEN
        io.WriteString("Rechenzeichen erwartet\n");
      ELSIF error=5 THEN
        io.WriteString("Operand erwartet\n");
      END;
    ELSIF bcount#0 THEN
      io.WriteString("Warnung: ");
      IF bcount>0 THEN
        io.WriteInt(bcount,2);
        io.WriteString(" Klammer(n) nicht geschlossen!\n");
      ELSE
        io.WriteString("Zu viele Klammern geschlossen!\n");
      END;
    END;
    IF error=0 THEN
      pos:=0;
      root:=Parse(string);
      LockTree(root);
      real:=Calc(root,1,0.0001,pos);
      UnLockTree(root);
      bool:=rio.WriteReal(real,7,7,FALSE);
      LockTree(root);
      long:=CalcLong(root,1,0.0001,pos);
      UnLockTree(root);
      bool:=lrio.WriteReal(long,7,7,FALSE);
      io.WriteLn;
      io.WriteString("Term       : ");
      TreeToString(root,string);
      io.WriteString(string);
      io.WriteLn;
      io.WriteString("Vereinfacht: ");
      bool:=f2.Optimize(root);
      TreeToString(root,string);
      io.WriteString(string);
      io.WriteLn;
      io.WriteString("1.Ableitung: ");
      fb.Derive(root,"x");
      TreeToString(root,string);
      io.WriteString(string);
      io.WriteLn;
      io.WriteString("Vereinfacht: ");
      bool:=f2.Optimize(root);
      TreeToString(root,string);
      io.WriteString(string);
      io.WriteLn;
    END;
  END;*)

CLOSE
  DISPOSE(ops);
  DISPOSE(opslen);
END FunctionTrees.

