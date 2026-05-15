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


MODULE FunctionSimplify;

IMPORT fb : FunctionBasics,
       l  : LinkedLists,
       st : Strings,
       tt : TextTools,
       mt : MathTrans,
       lrc: LongRealConversions,
(*       rio: RealInOut,
       io,*)
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

PROCEDURE Calc(root:fb.Node;VAR error:BOOLEAN):LONGREAL;

VAR left,right : LONGREAL;
    err        : INTEGER;

BEGIN
  error:=TRUE;
  IF (root#NIL) AND (root IS fb.Sign) AND (root.left#NIL) AND (root.right#NIL) AND (root.left IS fb.Number) AND (root.right IS fb.Number) THEN
    error:=FALSE;
    WITH root: fb.Sign DO
      left:=root.left(fb.Number).real;
      right:=root.right(fb.Number).real;
      IF root.sign="+" THEN
        left:=left+right;
      ELSIF root.sign="-" THEN
        left:=left-right;
      ELSIF root.sign="*" THEN
        left:=left*right;
      ELSIF root.sign="/" THEN
        IF right=0 THEN
          error:=TRUE;
        ELSE
          left:=left/right;
        END;
      ELSIF root.sign="^" THEN
        err:=0;
        left:=fb.PowLong(right,left,err);
        IF err#0 THEN
          error:=TRUE;
        END;
      END;
    END;
  END;
  RETURN left;
END Calc;

PROCEDURE Optimize*(VAR root:fb.Node):BOOLEAN;

VAR node : fb.Node;
    ret,
    bool : BOOLEAN;
    real : LONGREAL;

PROCEDURE CheckRemove(node:fb.Node;real:LONGREAL):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF node#NIL THEN
    IF node IS fb.Number THEN
      IF node(fb.Number).real=real THEN
        ret:=TRUE;
        IF root.left=node THEN
          root.right.parent:=root.parent;
          root:=root.right;
        ELSE
          root.left.parent:=root.parent;
          root:=root.left;
        END;
      END;
    END;
  END;
  RETURN ret;
END CheckRemove;

PROCEDURE CheckRemoveOther(node:fb.Node;real:LONGREAL):BOOLEAN;

VAR ret : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF node#NIL THEN
    IF node IS fb.Number THEN
      IF node(fb.Number).real=real THEN
        ret:=TRUE;
        node.parent:=root.parent;
        root:=node;
      END;
    END;
  END;
  RETURN ret;
END CheckRemoveOther;

BEGIN
  IF root#NIL THEN
    ret:=Optimize(root.left);
    ret:=Optimize(root.right);
    IF root IS fb.Operation THEN
      ret:=Optimize(root(fb.Operation).root);
      ret:=Optimize(root(fb.Operation).data);
    END;
    IF root IS fb.Sign THEN
      IF (root(fb.Sign).sign="+") OR (root(fb.Sign).sign="-") THEN
        bool:=CheckRemove(root.right,0);
        IF NOT(bool) AND (root(fb.Sign).sign#"-") THEN
          bool:=CheckRemove(root.left,0);
        END;
      ELSIF root(fb.Sign).sign="*" THEN
        bool:=CheckRemove(root.left,1);
        IF NOT(bool) THEN
          bool:=CheckRemove(root.right,1);
          IF NOT(bool) THEN
            bool:=CheckRemoveOther(root.left,0);
            IF NOT(bool) THEN
              bool:=CheckRemoveOther(root.right,0);
            END;
          END;
        END;
      ELSIF root(fb.Sign).sign="/" THEN
        bool:=CheckRemove(root.right,1);
        IF NOT(bool) THEN
          bool:=CheckRemoveOther(root.left,0);
        END;
      END;
    END;
    IF root IS fb.Sign THEN
      real:=Calc(root,bool);
      IF NOT(bool) THEN
        IF SHORT(SHORT(real*10))=real*10 THEN
          node:=root;
          root:=NIL;
          NEW(root(fb.Number));
          root.parent:=node.parent;
          root(fb.Number).real:=real;
        END;
      END;
    END;
    IF root IS fb.Sign THEN
      IF root(fb.Sign).sign="^" THEN
        bool:=CheckRemove(root.right,1);
        IF NOT(bool) THEN
          bool:=CheckRemoveOther(root.right,0);
          IF bool THEN
            root(fb.Number).real:=1;
          END;
        END;
      END;
    END;
  END;
  ret:=FALSE;
  RETURN ret;
END Optimize;

PROCEDURE Simplify*(VAR root:fb.Node);

VAR bool : BOOLEAN;

BEGIN
  bool:=Optimize(root);
END Simplify;

END FunctionSimplify.

