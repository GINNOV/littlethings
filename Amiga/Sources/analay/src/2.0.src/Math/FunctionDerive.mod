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


MODULE FunctionDerive;

IMPORT l  : LinkedLists,
       fb : FunctionBasics,
       st : Strings,
       tt : TextTools,
       mt : MathTrans,
       mdt: MathIEEEDoubTrans,
       lrc: LongRealConversions,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

PROCEDURE DeriveOperation(VAR root:fb.Node);

VAR node,node2 : fb.Node;

BEGIN
  IF root(fb.Operation).type=0 THEN
    root(fb.Operation).type:=1;
  ELSIF root(fb.Operation).type=1 THEN
    root(fb.Operation).type:=0;
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="-";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=0;
    root.right:=node;
    root.right.parent:=root;
  ELSIF (root(fb.Operation).type=2) OR (root(fb.Operation).type=3) THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    NEW(root.right(fb.Sign));
    root.right(fb.Sign).sign:="^";
    root.right.parent:=root;
    root.right.left:=node;
    node.parent:=root.right;
    NEW(root.right.right(fb.Number));
    root.right.right.parent:=root.right;
    root.right.right(fb.Number).real:=2;
    IF node(fb.Operation).type=2 THEN
      node(fb.Operation).type:=1;
    ELSE
      node(fb.Operation).type:=0;
      node:=root;
      root:=NIL;
      NEW(root(fb.Sign));
      root.parent:=node.parent;
      root(fb.Sign).sign:="-";
      NEW(root.left(fb.Number));
      root.left.parent:=root;
      root.left(fb.Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF root(fb.Operation).type=5 THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    NEW(root.right(fb.Sign));
    root.right(fb.Sign).sign:="*";
    root.right.parent:=root;
    NEW(root.right.left(fb.Number));
    root.right.left.parent:=root.right;
    root.right.left(fb.Number).real:=2;
    root.right.right:=node;
    node.parent:=root.right;
  ELSIF root(fb.Operation).type=6 THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="*";
    NEW(root.left(fb.Sign));
    root.left.parent:=root;
    root.left(fb.Sign).sign:="/";
    NEW(root.left.left(fb.Number));
    root.left.left.parent:=root.left;
    root.left.left(fb.Number).real:=1;
    root.left.right:=fb.CopyTree(node(fb.Operation).data);
    root.left.right.parent:=root.left;
    NEW(root.right(fb.Sign));
    node2:=root.right;
    node2.parent:=root;
    node2(fb.Sign).sign:="^";
    node2.left:=node;
    node2.left.parent:=root.right;
    NEW(node2.right(fb.Sign));
    node2.right.parent:=node2;
    node2.right(fb.Sign).sign:="/";
    NEW(node2.right.left(fb.Number));
    node2.right.left.parent:=node2.right;
    node2.right.left(fb.Number).real:=1;
    node2.right.right:=fb.CopyTree(node(fb.Operation).data);
    node2.right.right.parent:=node2.right;
  ELSIF root(fb.Operation).type=7 THEN
    root(fb.Operation).type:=8;
  ELSIF root(fb.Operation).type=8 THEN
    root(fb.Operation).type:=7;
  ELSIF (root(fb.Operation).type=9) OR (root(fb.Operation).type=10) THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    NEW(root.right(fb.Sign));
    root.right.parent:=root;
    root.right(fb.Sign).sign:="^";
    root.right.left:=node;
    node.parent:=root.right;
    NEW(root.right.right(fb.Number));
    root.right.right.parent:=root.right;
    root.right.right(fb.Number).real:=2;
    IF node(fb.Operation).type=9 THEN
      node(fb.Operation).type:=8;
    ELSE
      node(fb.Operation).type:=7;
      node:=root;
      root:=NIL;
      NEW(root(fb.Sign));
      root.parent:=node.parent;
      root(fb.Sign).sign:="-";
      NEW(root.left(fb.Number));
      root.left.parent:=root;
      root.left(fb.Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF (root(fb.Operation).type=11) OR (root(fb.Operation).type=12) THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    NEW(root.right(fb.Operation));
    root.right.parent:=root;
    root.right(fb.Operation).type:=5;
    NEW(root.right(fb.Operation).root(fb.Sign));
    node2:=root.right(fb.Operation).root;
    node2(fb.Sign).sign:="-";
    NEW(node2.left(fb.Number));
    node2.left.parent:=node2;
    node2.left(fb.Number).real:=1;
    NEW(node2.right(fb.Sign));
    node2.right.parent:=node2;
    node2.right(fb.Sign).sign:="^";
    node2.right.left:=node(fb.Operation).root;
    node2.right.left.parent:=node2.right;
    NEW(node2.right.right(fb.Number));
    node2.right.right.parent:=node2.right;
    node2.right.right(fb.Number).real:=2;
    IF node(fb.Operation).type=12 THEN
      node:=root;
      root:=NIL;
      NEW(root(fb.Sign));
      root.parent:=node.parent;
      root(fb.Sign).sign:="-";
      NEW(root.left(fb.Number));
      root.left.parent:=root;
      root.left(fb.Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF (root(fb.Operation).type=13) OR (root(fb.Operation).type=14) THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    NEW(root.right(fb.Sign));
    node2:=root.right;
    node2.parent:=root;
    node2(fb.Sign).sign:="+";
    NEW(node2.left(fb.Number));
    node2.left.parent:=node2;
    node2.left(fb.Number).real:=1;
    NEW(node2.right(fb.Sign));
    node2.right.parent:=node2;
    node2.right(fb.Sign).sign:="^";
    node2.right.left:=node(fb.Operation).root;
    node2.right.left.parent:=node2.right;
    NEW(node2.right.right(fb.Number));
    node2.right.right.parent:=node2.right;
    node2.right.right(fb.Number).real:=2;
    IF node(fb.Operation).type=14 THEN
      node:=root;
      root:=NIL;
      NEW(root(fb.Sign));
      root.parent:=node.parent;
      root(fb.Sign).sign:="-";
      NEW(root.left(fb.Number));
      root.left.parent:=root;
      root.left(fb.Number).real:=0;
      root.right:=node;
      node.parent:=root;
    END;
  ELSIF root(fb.Operation).type=16 THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    NEW(root.right(fb.Sign));
    node2:=root.right;
    node2.parent:=root;
    node2(fb.Sign).sign:="*";
    node2.left:=node(fb.Operation).root;
    node2.left.parent:=node2;
    NEW(node2.right(fb.Operation));
    node2.right.parent:=node2;
    node2.right(fb.Operation).type:=17;
    node2.right(fb.Operation).root:=fb.CopyTree(node(fb.Operation).data);
  ELSIF root(fb.Operation).type=17 THEN
    node:=root;
    root:=NIL;
    NEW(root(fb.Sign));
    root.parent:=node.parent;
    root(fb.Sign).sign:="/";
    NEW(root.left(fb.Number));
    root.left.parent:=root;
    root.left(fb.Number).real:=1;
    root.right:=node(fb.Operation).root;
    root.right.parent:=root;
  END;
END DeriveOperation;

PROCEDURE Derive*(VAR root:fb.Node;var:ARRAY OF CHAR);
(* $CopyArrays- *)

VAR node,node2 : fb.Node;

PROCEDURE DeriveVar(root:fb.Node):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF root#NIL THEN
    IF (root IS fb.TreeObj) AND (tt.Compare(root(fb.TreeObj).object(fb.Object).name^,var)) THEN
      ret:=TRUE;
    ELSIF root IS fb.Operation THEN
      IF DeriveVar(root(fb.Operation).data) THEN
        ret:=TRUE;
      ELSIF DeriveVar(root(fb.Operation).root) THEN
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
    IF (root IS fb.TreeObj) AND (DeriveVar(root)) THEN
      NEW(node(fb.Number));
      node(fb.Number).real:=1;
      node.parent:=root.parent;
      root:=node;
    ELSIF (root IS fb.Number) OR (root IS fb.TreeObj) THEN
      NEW(node(fb.Number));
      node(fb.Number).real:=0;
      node.parent:=root.parent;
      root:=node;
    ELSIF root IS fb.Sign THEN
      IF (root(fb.Sign).sign="+") OR (root(fb.Sign).sign="-") THEN
        Derive(root.left,var);
        Derive(root.right,var);
      ELSIF root(fb.Sign).sign="*" THEN
        NEW(node(fb.Sign));
        node(fb.Sign).sign:="+";
        node.parent:=root.parent;
        node2:=root;
        root:=node;
        root.left:=fb.CopyTree(node2);
        root.left.parent:=root;
        root.right:=fb.CopyTree(node2);
        root.right.parent:=root;
        Derive(root.left.left,var);
        Derive(root.right.right,var);
      ELSIF root(fb.Sign).sign="/" THEN
        node2:=root.left;
        root.left:=NIL;
        NEW(root.left(fb.Sign));
        node:=root.left;
        node(fb.Sign).sign:="-";
        node.parent:=root;
        NEW(node.left(fb.Sign));
        node.left(fb.Sign).sign:="*";
        node.left.parent:=node;
        NEW(node.right(fb.Sign));
        node.right(fb.Sign).sign:="*";
        node.right.parent:=node;
        node.left.left:=fb.CopyTree(node2);
        node.left.left.parent:=node.left;
        node.left.right:=fb.CopyTree(root.right);
        node.left.right.parent:=node.left;
        Derive(node.left.left,var);
        node.right.left:=fb.CopyTree(node2);
        node.right.left.parent:=node.right;
        node.right.right:=fb.CopyTree(root.right);
        node.right.right.parent:=node.right;
        Derive(node.right.right,var);
        node2:=root.right;
        root.right:=NIL;
        NEW(root.right(fb.Sign));
        node:=root.right;
        node.parent:=root;
        node(fb.Sign).sign:="^";
        node.left:=node2;
        node.left.parent:=node;
        NEW(node.right(fb.Number));
        node.right.parent:=node;
        node.right(fb.Number).real:=2;
      ELSIF root(fb.Sign).sign="^" THEN
        IF NOT(DeriveVar(root.right)) THEN
          IF NOT(DeriveVar(root.left)) THEN
            NEW(node(fb.Number));
            node(fb.Number).real:=0;
            node.parent:=root.parent;
            root:=node;
          ELSE
            node:=root;
            root:=NIL;
            NEW(root(fb.Sign));
            root(fb.Sign).sign:="*";
            root.parent:=node.parent;
            root.right:=node;
            root.right.parent:=root;
            root.left:=fb.CopyTree(node.right);
            root.left.parent:=root;
            node2:=node.right;
            node.right:=NIL;
            NEW(node.right(fb.Sign));
            node.right.parent:=node2;
            node.right(fb.Sign).sign:="-";
            NEW(node.right.right(fb.Number));
            node.right.right.parent:=node.right;
            node.right.right(fb.Number).real:=1;
            node.right.left:=node2;
            node.right.left.parent:=node.right;
            node:=root;
            root:=NIL;
            NEW(root(fb.Sign));
            root(fb.Sign).sign:="*";
            root.parent:=node.parent;
            root.right:=node;
            root.right.parent:=root;
            root.left:=fb.CopyTree(node.right.left);
            root.left.parent:=root;
            Derive(root.left,var);
          END;
        ELSE
          node:=root;
          root:=NIL;
          NEW(root(fb.Sign));
          root.parent:=node.parent;
          root(fb.Sign).sign:="*";
          root.left:=node;
          node.parent:=root;
          NEW(root.right(fb.Sign));
          root.right.parent:=root;
          root.right(fb.Sign).sign:="*";
          root.right.left:=fb.CopyTree(node.right);
          root.right.left.parent:=root.right;
          NEW(root.right.right(fb.Operation));
          root.right.right.parent:=root.right;
          root.right.right(fb.Operation).type:=17;
          root.right.right(fb.Operation).root:=fb.CopyTree(node.left);
          Derive(root.right,var);
        END;
      END;
    ELSIF root IS fb.Operation THEN
      node:=root;
      root:=NIL;
      NEW(root(fb.Sign));
      root.parent:=node.parent;
      root(fb.Sign).sign:="*";
      root.left:=node;
      root.left.parent:=root;
      DeriveOperation(root.left);
      root.right:=fb.CopyTree(node(fb.Operation).root);
      root.right.parent:=root;
      Derive(root.right,var);
    END;
  END;
END Derive;

END FunctionDerive.

