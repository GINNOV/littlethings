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


MODULE FunctionBasics;

IMPORT e  : Exec,
       d  : Dos,
       l  : LinkedLists,
       st : Strings,
       tt : TextTools,
       mt : MathTrans,
       mdt: MathIEEEDoubTrans,
       lrc: LongRealConversions,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

CONST PI * = 3.14159265358979323846;
      E  * = 2.718281828;
      H  * = 6.62618E-34;
      C  * = 2.99792458E8; (* Vakuumlichtgeschwindigkeit *)
      EL * = 1.6022E-19;
      ME * = 9.1095E-31;     (* Elektronenmasse *)
      MN * = 1.6749E-27;    (* Neutronenmasse *)
      MP * = 1.6726E-27;    (* Protonenmasse *)
      IK * = 8.854E-12;
      RY * = 3.2898E15;
      F  * = 6.670E-11; (* Gravitationskonstante *)
      G  * = 9.80665;   (* Normfallbeschleunigung *)
      V  * = 22.414;    (* Molvolumen idealer Gase bei NB *)
      R  * = 8.3143;    (* Gaskonstante *)
      P  * = 1013.25;   (* Physikalischer Normdruck *)
(*      N  * = 6.02252E23;(* Avogadrosche Konstante *)*)
      U  * = 1.6605519E-27;  (* atomare Masseneinheit *)
      K  * = 1.38062E-23;     (* Boltzmannsche Konstante *)
      E0 * = 8.85419E-12;     (* Elektrische Feldkonstante *)
      M0 * = 1.25664E-6;      (* Magnetische Feldkonstante *)

      PIs * = "3.14159265358979323846";
      Es  * = "2.718281828";
      Hs  * = "6.62618E-34";
      Cs  * = "2.99792458E8"; (* Vakuumlichtgeschwindigkeit *)
      ELs * = "1.6022E-19";
      MEs * = "9.1095E-31";     (* Elektronenmasse *)
      MNs * = "1.6749E-27";    (* Neutronenmasse *)
      MPs * = "1.6726E-27";    (* Protonenmasse *)
      IKs * = "8.854E-12";
      RYs * = "3.2898E15";
      Fs  * = "6.670E-11"; (* Gravitationskonstante *)
      Gs  * = "9.80665";   (* Normfallbeschleunigung *)
      Vs  * = "22.414";    (* Molvolumen idealer Gase bei NB *)
      Rs  * = "8.3143";    (* Gaskonstante *)
      Ps  * = "1013.25";   (* Physikalischer Normdruck *)
      Ns  * = "6.02252E23";(* Avogadrosche Konstante *)
      Us  * = "1.6605519E-27";  (* atomare Masseneinheit *)
      Ks  * = "1.38062E-23";     (* Boltzmannsche Konstante *)
      E0s * = "8.85419E-12";     (* Elektrische Feldkonstante *)
      M0s * = "1.25664E-6";      (* Magnetische Feldkonstante *)

      picode * = 1;
      ecode  * = 2;

TYPE Node * = POINTER TO NodeDesc;
     Object * = POINTER TO ObjectDesc;
     NodeDesc * = RECORD
       parent * ,
       left   * ,
       right  * : Node;
     END;
     Number * = POINTER TO NumberDesc;
     NumberDesc * = RECORD(NodeDesc)
       real * : LONGREAL;
       exp  * : BOOLEAN;
     END;
     Sign * = POINTER TO SignDesc;
     SignDesc * = RECORD(NodeDesc)
       sign * : CHAR;
     END;
     Operation * = POINTER TO OperationDesc;
     OperationDesc * = RECORD(NodeDesc)
       type * : INTEGER;
       root * ,
       data * : Node;
     END;
     TreeObj * = POINTER TO TreeObjDesc;
     TreeObjDesc * = RECORD(NodeDesc)
       object * : l.Node;
     END;

     ObjectDesc * = RECORD(l.NodeDesc)
       name    * ,
       comment * : POINTER TO ARRAY OF CHAR;
     END;
     XYObject * = POINTER TO XYObjectDesc;
     XYObjectDesc * = RECORD(ObjectDesc)
       isX * ,
       isY * : BOOLEAN;
     END;
     Variable * = POINTER TO VariableDesc;
     VariableDesc * = RECORD(ObjectDesc)
       string * : ARRAY 256 OF CHAR;
       startx * ,
       endx   * ,
       stepx  * ,
       real   * : LONGREAL;
       changed* ,
       locked * : BOOLEAN;
     END;
     Constant * = POINTER TO ConstantDesc;
     ConstantDesc * = RECORD(ObjectDesc)
       real       * : LONGREAL;
       realstr    * : ARRAY 256 OF CHAR;
       internal   * : INTEGER;
       isInternal * : BOOLEAN;
     END;

VAR objects * : l.List;

PROCEDURE AddConstant*(name,comment:ARRAY OF CHAR;real:LONGREAL;internal:BOOLEAN);
(* $CopyArrays- *)

VAR node : l.Node;
    bool : BOOLEAN;

BEGIN
  NEW(node(Constant));
  WITH node: Constant DO
    NEW(node.name,st.Length(name)+1);
    COPY(name,node.name^);
    NEW(node.comment,st.Length(comment)+1);
    COPY(comment,node.comment^);
    node.real:=real;
    IF (real<0.0001) OR (real>=10000000) THEN
      bool:=TRUE;
    ELSE
      bool:=FALSE;
    END;
    bool:=lrc.RealToString(real,node.realstr,7,9,bool);
    tt.Clear(node.realstr);
    node.isInternal:=internal;
  END;
  objects.AddTail(node);
END AddConstant;

PROCEDURE SetLock*(root:Node;lock:BOOLEAN);

BEGIN
  IF root#NIL THEN
    IF (root IS TreeObj) AND (root(TreeObj).object#NIL) AND (root(TreeObj).object IS Variable) THEN
      root(TreeObj).object(Variable).locked:=lock;
    END;
    SetLock(root.left,lock);
    SetLock(root.right,lock);
    IF root IS Operation THEN
      SetLock(root(Operation).data,lock);
      SetLock(root(Operation).root,lock);
    END;
  END;
END SetLock;

PROCEDURE LockTree*(root:Node);

VAR exit,lock : BOOLEAN;

PROCEDURE CheckLock(root:Node);

BEGIN
  IF root#NIL THEN
    IF (root IS TreeObj) AND (root(TreeObj).object#NIL) AND (root(TreeObj).object IS Variable) THEN
      IF root(TreeObj).object(Variable).locked THEN
        lock:=TRUE;
      END;
    END;
    CheckLock(root.left);
    CheckLock(root.right);
    IF root IS Operation THEN
      CheckLock(root(Operation).data);
      CheckLock(root(Operation).root);
    END;
  END;
END CheckLock;

BEGIN
  exit:=FALSE;
  REPEAT
    LOOP
      lock:=FALSE;
      CheckLock(root);
      IF NOT(lock) THEN
        EXIT;
      END;
      d.Delay(10);
    END;
    lock:=FALSE;
    e.Forbid();
    CheckLock(root);
    IF NOT(lock) THEN
      SetLock(root,TRUE);
      exit:=TRUE;
    END;
    e.Permit();
  UNTIL exit;
END LockTree;

PROCEDURE UnLockTree*(root:Node);

BEGIN
  SetLock(root,FALSE);
END UnLockTree;

PROCEDURE Pow*(e,b:REAL;VAR error:INTEGER):REAL;

VAR r : REAL;
    i : INTEGER;

BEGIN
  IF e=0 THEN
    r:=1;
  ELSE
    IF SHORT(e)=e THEN
      IF (b<0) AND ODD(SHORT(e)) THEN
        r:=-mt.Pow(e,b);
      ELSE
        r:=mt.Pow(e,b);
      END;
    ELSIF b>0 THEN
      r:=mt.Pow(e,b);
    ELSE
      r:=0;
      error:=3;
    END;
  END;
  RETURN r;
(*  IF e=0 THEN
    r:=1;
  ELSE
    r:=1/e;
    IF SHORT(e)=e THEN
      IF e>0 THEN
        r:=e+0.5;
      ELSE
        r:=e-0.5;
      END;
      IF (b<0) AND ODD(SHORT(r)) THEN
        r:=-mt.Pow(e,b);
      ELSE
        r:=mt.Pow(e,b);
      END;
    ELSIF (b>0) OR (SHORT(r)=r) THEN
      IF r>0 THEN
        r:=r+0.5;
      ELSE
        r:=r-0.5;
      END;
      IF (b>0) OR ODD(SHORT(r)) THEN
        IF (b<0) AND ODD(SHORT(r)) THEN
          r:=-mt.Pow(e,b);
        ELSE
          r:=mt.Pow(e,b);
        END;
      ELSE
        r:=0;
      END;
    ELSE
      r:=0;
    END;
  END;
  RETURN r;*)
END Pow;

PROCEDURE PowLong*(e,b:LONGREAL;VAR error:INTEGER):LONGREAL;

VAR r : LONGREAL;
    i : INTEGER;

BEGIN
  IF e=0 THEN
    r:=1;
  ELSE
    IF SHORT(SHORT(e))=e THEN
(*      IF (b<0) AND ODD(SHORT(SHORT(e))) THEN
        r:=-mdt.Pow(e,b);
      ELSE
        r:=mdt.Pow(e,b);
      END;*)
      r:=mdt.Pow(e,b);
    ELSIF b>0 THEN
      r:=mdt.Pow(e,b);
    ELSE
      r:=0;
      error:=3;
    END;
  END;
(*  IF (b<0) AND ODD(SHORT(SHORT(SHORT(e+0.5)))) THEN
    r:=0-r;
  END;*)
  RETURN r;
(*  IF e=0 THEN
    r:=1;
  ELSE
    r:=1/e;
    IF SHORT(SHORT(e))=e THEN
      IF e>0 THEN
        r:=e+0.5;
      ELSE
        r:=e-0.5;
      END;
      IF (b<0) AND ODD(SHORT(SHORT(r))) THEN
        r:=-mdt.Pow(e,b);
      ELSE
        r:=mdt.Pow(e,b);
      END;
      r:=mdt.Pow(e,b);
    ELSIF (b>0) OR (SHORT(SHORT(r))=r) THEN
      IF r>0 THEN
        r:=r+0.5;
      ELSE
        r:=r-0.5;
      END;
      IF (b>0) OR ODD(SHORT(SHORT(r))) THEN
        IF (b<0) AND ODD(SHORT(SHORT(r))) THEN
          r:=-mdt.Pow(e,ABS(b));
        ELSE
          r:=mdt.Pow(e,b);
        END;
      ELSE
        r:=0;
      END;
    ELSE
      r:=0;
    END;
  END;
(*  IF (b<0) AND ODD(SHORT(SHORT(SHORT(e+0.5)))) THEN
    r:=0-r;
  END;*)
  RETURN r;*)
END PowLong;

PROCEDURE Nrt*(r,n:REAL;VAR error:INTEGER):REAL;

BEGIN
  RETURN Pow(1/n,r,error);
END Nrt;

PROCEDURE NrtLong*(r,n:LONGREAL;VAR error:INTEGER):LONGREAL;

BEGIN
  RETURN PowLong(1/n,r,error);
END NrtLong;

PROCEDURE CopyTree*(root:Node):Node;

VAR node : Node;

BEGIN
  IF root#NIL THEN
    IF root IS Number THEN
      NEW(node(Number));
      node(Number).real:=root(Number).real;
      node(Number).exp:=root(Number).exp;
    ELSIF root IS Sign THEN
      NEW(node(Sign));
      node(Sign).sign:=root(Sign).sign;
    ELSIF root IS Operation THEN
      NEW(node(Operation));
      node(Operation).type:=root(Operation).type;
      node(Operation).data:=CopyTree(root(Operation).data);
      node(Operation).root:=CopyTree(root(Operation).root);
    ELSIF root IS TreeObj THEN
      NEW(node(TreeObj));
      node(TreeObj).object:=root(TreeObj).object;
    END;
    IF root.right#NIL THEN
      node.right:=CopyTree(root.right);
      node.right.parent:=node;
    END;
    IF root.left#NIL THEN
      node.left:=CopyTree(root.left);
      node.left.parent:=node;
    END;
  END;
  RETURN node;
END CopyTree;



PROCEDURE (node:Node) Destruct*;

BEGIN
  IF node.left#NIL THEN
    node.left.Destruct;
  END;
  IF node.right#NIL THEN
    node.right.Destruct;
  END;
  DISPOSE(node);
END Destruct;

PROCEDURE (node:Operation) Destruct*;

BEGIN
  IF node.data#NIL THEN
    node.data.Destruct;
  END;
  IF node.root#NIL THEN
    node.root.Destruct;
  END;
  node.Destruct^;
END Destruct;

PROCEDURE (node:TreeObj) Destruct*;

BEGIN
  IF NOT(node.object IS Variable) AND NOT(node.object IS Constant) THEN
    DISPOSE(node.object(Object).name);
    DISPOSE(node.object(Object).comment);
    node.object.Destruct;
  END;
  node.Destruct^;
END Destruct;

BEGIN
  objects:=l.Create();
CLOSE
  IF objects#NIL THEN
    objects.Destruct;
  END;
END FunctionBasics.

