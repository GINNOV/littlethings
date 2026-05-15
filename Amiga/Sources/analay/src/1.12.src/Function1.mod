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


MODULE Function1;

IMPORT l  : LinkedLists,
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

TYPE NodePtr * = POINTER TO Node;
     ObjectPtr * = POINTER TO Object;
     Node * = RECORD
       parent * ,
       left   * ,
       right  * : NodePtr;
     END;
     Number * = RECORD(Node)
       real * : LONGREAL;
       exp  * : BOOLEAN;
     END;
     Sign * = RECORD(Node)
       sign * : CHAR;
     END;
     Operation * = RECORD(Node)
       type * : INTEGER;
       root * ,
       data * : NodePtr;
     END;
     TreeObj * = RECORD(Node)
       object * : l.Node;
     END;

     Object * = RECORD(l.NodeDesc)
       name    * ,
       comment * : POINTER TO ARRAY OF CHAR;
     END;
     XYObject * = RECORD(Object)
       isX * ,
       isY * : BOOLEAN;
     END;
     Variable * = RECORD(Object)
       string * : ARRAY 256 OF CHAR;
       startx * ,
       endx   * ,
       stepx  * ,
       real   * : LONGREAL;
       changed* ,
       locked * : BOOLEAN;
     END;
     Constant * = RECORD(Object)
       real       * : LONGREAL;
       realstr    * : ARRAY 256 OF CHAR;
       internal   * : INTEGER;
       isInternal * : BOOLEAN;
     END;

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

PROCEDURE CopyTree*(root:NodePtr):NodePtr;

VAR node : NodePtr;

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

PROCEDURE DeriveOperation(VAR root:NodePtr);

VAR node,node2 : NodePtr;

BEGIN
  IF root(Operation).type=0 THEN
    root(Operation).type:=1;
  ELSIF root(Operation).type=1 THEN
    root(Operation).type:=0;
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="-";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=0;
    root.right:=node;
    root.right.parent:=root;
  ELSIF (root(Operation).type=2) OR (root(Operation).type=3) THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    NEW(root.right(Sign));
    root.right(Sign).sign:="^";
    root.right.parent:=root;
    root.right.left:=node;
    node.parent:=root.right;
    NEW(root.right.right(Number));
    root.right.right.parent:=root.right;
    root.right.right(Number).real:=2;
    IF node(Operation).type=2 THEN
      node(Operation).type:=1;
    ELSE
      node(Operation).type:=0;
      node:=root;
      root:=NIL;
      NEW(root(Sign));
      root.parent:=node.parent;
      root(Sign).sign:="-";
      NEW(root.left(Number));
      root.left.parent:=root;
      root.left(Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF root(Operation).type=5 THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    NEW(root.right(Sign));
    root.right(Sign).sign:="*";
    root.right.parent:=root;
    NEW(root.right.left(Number));
    root.right.left.parent:=root.right;
    root.right.left(Number).real:=2;
    root.right.right:=node;
    node.parent:=root.right;
  ELSIF root(Operation).type=6 THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="*";
    NEW(root.left(Sign));
    root.left.parent:=root;
    root.left(Sign).sign:="/";
    NEW(root.left.left(Number));
    root.left.left.parent:=root.left;
    root.left.left(Number).real:=1;
    root.left.right:=CopyTree(node(Operation).data);
    root.left.right.parent:=root.left;
    NEW(root.right(Sign));
    node2:=root.right;
    node2.parent:=root;
    node2(Sign).sign:="^";
    node2.left:=node;
    node2.left.parent:=root.right;
    NEW(node2.right(Sign));
    node2.right.parent:=node2;
    node2.right(Sign).sign:="/";
    NEW(node2.right.left(Number));
    node2.right.left.parent:=node2.right;
    node2.right.left(Number).real:=1;
    node2.right.right:=CopyTree(node(Operation).data);
    node2.right.right.parent:=node2.right;
  ELSIF root(Operation).type=7 THEN
    root(Operation).type:=8;
  ELSIF root(Operation).type=8 THEN
    root(Operation).type:=7;
  ELSIF (root(Operation).type=9) OR (root(Operation).type=10) THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    NEW(root.right(Sign));
    root.right.parent:=root;
    root.right(Sign).sign:="^";
    root.right.left:=node;
    node.parent:=root.right;
    NEW(root.right.right(Number));
    root.right.right.parent:=root.right;
    root.right.right(Number).real:=2;
    IF node(Operation).type=9 THEN
      node(Operation).type:=8;
    ELSE
      node(Operation).type:=7;
      node:=root;
      root:=NIL;
      NEW(root(Sign));
      root.parent:=node.parent;
      root(Sign).sign:="-";
      NEW(root.left(Number));
      root.left.parent:=root;
      root.left(Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF (root(Operation).type=11) OR (root(Operation).type=12) THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    NEW(root.right(Operation));
    root.right.parent:=root;
    root.right(Operation).type:=5;
    NEW(root.right(Operation).root(Sign));
    node2:=root.right(Operation).root;
    node2(Sign).sign:="-";
    NEW(node2.left(Number));
    node2.left.parent:=node2;
    node2.left(Number).real:=1;
    NEW(node2.right(Sign));
    node2.right.parent:=node2;
    node2.right(Sign).sign:="^";
    node2.right.left:=node(Operation).root;
    node2.right.left.parent:=node2.right;
    NEW(node2.right.right(Number));
    node2.right.right.parent:=node2.right;
    node2.right.right(Number).real:=2;
    IF node(Operation).type=12 THEN
      node:=root;
      root:=NIL;
      NEW(root(Sign));
      root.parent:=node.parent;
      root(Sign).sign:="-";
      NEW(root.left(Number));
      root.left.parent:=root;
      root.left(Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF (root(Operation).type=13) OR (root(Operation).type=14) THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    NEW(root.right(Sign));
    node2:=root.right;
    node2.parent:=root;
    node2(Sign).sign:="+";
    NEW(node2.left(Number));
    node2.left.parent:=node2;
    node2.left(Number).real:=1;
    NEW(node2.right(Sign));
    node2.right.parent:=node2;
    node2.right(Sign).sign:="^";
    node2.right.left:=node(Operation).root;
    node2.right.left.parent:=node2.right;
    NEW(node2.right.right(Number));
    node2.right.right.parent:=node2.right;
    node2.right.right(Number).real:=2;
    IF node(Operation).type=14 THEN
      node:=root;
      root:=NIL;
      NEW(root(Sign));
      root.parent:=node.parent;
      root(Sign).sign:="-";
      NEW(root.left(Number));
      root.left.parent:=root;
      root.left(Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF root(Operation).type=16 THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    NEW(root.right(Sign));
    node2:=root.right;
    node2.parent:=root;
    node2(Sign).sign:="*";
    node2.left:=node(Operation).root;
    node2.left.parent:=node2;
    NEW(node2.right(Operation));
    node2.right.parent:=node2;
    node2.right(Operation).type:=17;
    node2.right(Operation).root:=CopyTree(node(Operation).data);
  ELSIF root(Operation).type=17 THEN
    node:=root;
    root:=NIL;
    NEW(root(Sign));
    root.parent:=node.parent;
    root(Sign).sign:="/";
    NEW(root.left(Number));
    root.left.parent:=root;
    root.left(Number).real:=1;
    root.right:=node(Operation).root;
    root.right.parent:=root;
  END;
END DeriveOperation;

PROCEDURE Derive*(VAR root:NodePtr;var:ARRAY OF CHAR);
(* $CopyArrays- *)

VAR node,node2 : NodePtr;

PROCEDURE DeriveVar(root:NodePtr):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF root#NIL THEN
    IF (root IS TreeObj) AND (tt.Compare(root(TreeObj).object(Object).name^,var)) THEN
      ret:=TRUE;
    ELSIF root IS Operation THEN
      IF DeriveVar(root(Operation).data) THEN
        ret:=TRUE;
      ELSIF DeriveVar(root(Operation).root) THEN
        ret:=TRUE;
      END;
    ELSE
      IF DeriveVar(root.left) THEN
        ret:=TRUE;
      ELSIF DeriveVar(root.right) THEN
        ret:=TRUE;
      END;
    END;
  END;
  RETURN ret;
END DeriveVar;

BEGIN
  IF root#NIL THEN
    IF (root IS TreeObj) AND (DeriveVar(root)) THEN
      NEW(node(Number));
      node(Number).real:=1;
      node.parent:=root.parent;
      root:=node;
    ELSIF (root IS Number) OR (root IS TreeObj) THEN
      NEW(node(Number));
      node(Number).real:=0;
      node.parent:=root.parent;
      root:=node;
    ELSIF root IS Sign THEN
      IF (root(Sign).sign="+") OR (root(Sign).sign="-") THEN
        Derive(root.left,var);
        Derive(root.right,var);
      ELSIF root(Sign).sign="*" THEN
        NEW(node(Sign));
        node(Sign).sign:="+";
        node.parent:=root.parent;
        node2:=root;
        root:=node;
        root.left:=CopyTree(node2);
        root.left.parent:=root;
        root.right:=CopyTree(node2);
        root.right.parent:=root;
        Derive(root.left.left,var);
        Derive(root.right.right,var);
      ELSIF root(Sign).sign="/" THEN
        node2:=root.left;
        root.left:=NIL;
        NEW(root.left(Sign));
        node:=root.left;
        node(Sign).sign:="-";
        node.parent:=root;
        NEW(node.left(Sign));
        node.left(Sign).sign:="*";
        node.left.parent:=node;
        NEW(node.right(Sign));
        node.right(Sign).sign:="*";
        node.right.parent:=node;
        node.left.left:=CopyTree(node2);
        node.left.left.parent:=node.left;
        node.left.right:=CopyTree(root.right);
        node.left.right.parent:=node.left;
        Derive(node.left.left,var);
        node.right.left:=CopyTree(node2);
        node.right.left.parent:=node.right;
        node.right.right:=CopyTree(root.right);
        node.right.right.parent:=node.right;
        Derive(node.right.right,var);
        node2:=root.right;
        root.right:=NIL;
        NEW(root.right(Sign));
        node:=root.right;
        node.parent:=root;
        node(Sign).sign:="^";
        node.left:=node2;
        node.left.parent:=node;
        NEW(node.right(Number));
        node.right.parent:=node;
        node.right(Number).real:=2;
      ELSIF root(Sign).sign="^" THEN
        IF NOT(DeriveVar(root.right)) THEN
          IF NOT(DeriveVar(root.left)) THEN
            NEW(node(Number));
            node(Number).real:=0;
            node.parent:=root.parent;
            root:=node;
          ELSE
            node:=root;
            root:=NIL;
            NEW(root(Sign));
            root(Sign).sign:="*";
            root.parent:=node.parent;
            root.right:=node;
            root.right.parent:=root;
            root.left:=CopyTree(node.right);
            root.left.parent:=root;
            node2:=node.right;
            node.right:=NIL;
            NEW(node.right(Sign));
            node.right.parent:=node2;
            node.right(Sign).sign:="-";
            NEW(node.right.right(Number));
            node.right.right.parent:=node.right;
            node.right.right(Number).real:=1;
            node.right.left:=node2;
            node.right.left.parent:=node.right;
            node:=root;
            root:=NIL;
            NEW(root(Sign));
            root(Sign).sign:="*";
            root.parent:=node.parent;
            root.right:=node;
            root.right.parent:=root;
            root.left:=CopyTree(node.right.left);
            root.left.parent:=root;
            Derive(root.left,var);
          END;
        ELSE
          node:=root;
          root:=NIL;
          NEW(root(Sign));
          root.parent:=node.parent;
          root(Sign).sign:="*";
          root.left:=node;
          node.parent:=root;
          NEW(root.right(Sign));
          root.right.parent:=root;
          root.right(Sign).sign:="*";
          root.right.left:=CopyTree(node.right);
          root.right.left.parent:=root.right;
          NEW(root.right.right(Operation));
          root.right.right.parent:=root.right;
          root.right.right(Operation).type:=17;
          root.right.right(Operation).root:=CopyTree(node.left);
          Derive(root.right,var);
        END;
      END;
    ELSIF root IS Operation THEN
      node:=root;
      root:=NIL;
      NEW(root(Sign));
      root.parent:=node.parent;
      root(Sign).sign:="*";
      root.left:=node;
      root.left.parent:=root;
      DeriveOperation(root.left);
      root.right:=CopyTree(node(Operation).root);
      root.right.parent:=root;
      Derive(root.right,var);
    END;
  END;
END Derive;

END Function1.

